From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH 3/3] crypto: algif - change algif_skcipher to be asynchronous
Date: Thu, 29 Jan 2015 15:13:56 -0800
Message-ID: <20150129231356.25156.35978.stgit@tstruk-mobl1>
References: <20150129231338.25156.65450.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, qat-linux@intel.com,
	linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150129231338.25156.65450.stgit@tstruk-mobl1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The way the algif_skcipher works currently is that on sendmsg/sendpage it
builds an sgl for the input data and then on read/recvmsg it sends the job
for encryption putting the user to sleep till the data is processed.
This way it can only handle one job at a given time.
This patch changes it to be asynchronous by adding AIO support.

Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
---
 crypto/algif_skcipher.c |  315 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 309 insertions(+), 6 deletions(-)

diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 38a6757..c953200 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -19,9 +19,11 @@
 #include <linux/list.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include <linux/mempool.h>
 #include <linux/module.h>
 #include <linux/net.h>
 #include <net/sock.h>
+#include <linux/aio.h>
 
 struct skcipher_sg_list {
 	struct list_head list;
@@ -39,6 +41,9 @@ struct skcipher_ctx {
 
 	struct af_alg_completion completion;
 
+	struct kmem_cache *cache;
+	mempool_t *pool;
+	atomic_t inflight;
 	unsigned used;
 
 	unsigned int len;
@@ -49,9 +54,135 @@ struct skcipher_ctx {
 	struct ablkcipher_request req;
 };
 
+struct skcipher_async_rsgl {
+	struct af_alg_sgl sgl;
+	struct list_head list;
+};
+
+struct skcipher_async_req {
+	struct kiocb *iocb;
+	struct skcipher_async_rsgl first_sgl;
+	struct list_head list;
+	struct scatterlist *tsg;
+	char iv[];
+};
+
+#define GET_SREQ(areq, ctx) (struct skcipher_async_req *)((char *)areq + \
+	crypto_ablkcipher_reqsize(crypto_ablkcipher_reqtfm(&ctx->req)))
+
+#define GET_REQ_SIZE(ctx) \
+	crypto_ablkcipher_reqsize(crypto_ablkcipher_reqtfm(&ctx->req))
+
+#define GET_IV_SIZE(ctx) \
+	crypto_ablkcipher_ivsize(crypto_ablkcipher_reqtfm(&ctx->req))
+
 #define MAX_SGL_ENTS ((4096 - sizeof(struct skcipher_sg_list)) / \
 		      sizeof(struct scatterlist) - 1)
 
+static void skcipher_free_async_sgls(struct skcipher_async_req *sreq)
+{
+	struct skcipher_async_rsgl *rsgl;
+	struct scatterlist *sgl;
+	struct scatterlist *sg;
+	int i, n;
+
+	list_for_each_entry(rsgl, &sreq->list, list) {
+		af_alg_free_sg(&rsgl->sgl);
+		if (rsgl != &sreq->first_sgl)
+			kfree(rsgl);
+	}
+	sgl = sreq->tsg;
+	n = sg_nents(sgl);
+	for_each_sg(sgl, sg, n, i)
+		put_page(sg_page(sg));
+
+	kfree(sreq->tsg);
+}
+
+static void skcipher_async_cb(struct crypto_async_request *req, int err)
+{
+	struct sock *sk = req->data;
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	struct skcipher_async_req *sreq = GET_SREQ(req, ctx);
+	struct kiocb *iocb = sreq->iocb;
+
+	atomic_dec(&ctx->inflight);
+	skcipher_free_async_sgls(sreq);
+	mempool_free(req, ctx->pool);
+	sock_aio_complete(iocb, err, err);
+}
+
+static void skcipher_mempool_free(void *_req, void *_sk)
+{
+	struct sock *sk = _sk;
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	struct kmem_cache *cache = ctx->cache;
+
+	kmem_cache_free(cache, _req);
+}
+
+static void *skcipher_mempool_alloc(gfp_t gfp_mask, void *_sk)
+{
+	struct sock *sk = _sk;
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	struct kmem_cache *cache = ctx->cache;
+	struct ablkcipher_request *req;
+
+	req = kmem_cache_alloc(cache, gfp_mask);
+	if (req) {
+		ablkcipher_request_set_tfm(req,
+					   crypto_ablkcipher_reqtfm(&ctx->req));
+		ablkcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
+						skcipher_async_cb, sk);
+	}
+	return req;
+}
+
+static void skcipher_cache_constructor(void *v)
+{
+	memset(v, 0, sizeof(struct skcipher_async_req));
+}
+
+static int skcipher_mempool_create(struct sock *sk)
+{
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	unsigned int len = sizeof(struct skcipher_async_req) +
+		GET_REQ_SIZE(ctx) + GET_IV_SIZE(ctx);
+	char buf[32];
+
+	snprintf(buf, sizeof(buf), "skcipher_%p", ctx);
+	ctx->cache = kmem_cache_create(buf, len, 0, SLAB_HWCACHE_ALIGN |
+				       SLAB_TEMPORARY,
+				       skcipher_cache_constructor);
+	if (unlikely(!ctx->cache))
+		return -ENOMEM;
+
+	ctx->pool = mempool_create(128, skcipher_mempool_alloc,
+				   skcipher_mempool_free, sk);
+
+	if (unlikely(!ctx->pool)) {
+		kmem_cache_destroy(ctx->cache);
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+static void skcipher_mempool_destroy(struct skcipher_ctx *ctx)
+{
+	if (ctx->pool)
+		mempool_destroy(ctx->pool);
+
+	if (ctx->cache)
+		kmem_cache_destroy(ctx->cache);
+
+	ctx->cache = NULL;
+	ctx->pool = NULL;
+}
+
 static inline int skcipher_sndbuf(struct sock *sk)
 {
 	struct alg_sock *ask = alg_sk(sk);
@@ -96,7 +227,7 @@ static int skcipher_alloc_sgl(struct sock *sk)
 	return 0;
 }
 
-static void skcipher_pull_sgl(struct sock *sk, int used)
+static void skcipher_pull_sgl(struct sock *sk, int used, int put)
 {
 	struct alg_sock *ask = alg_sk(sk);
 	struct skcipher_ctx *ctx = ask->private;
@@ -124,7 +255,8 @@ static void skcipher_pull_sgl(struct sock *sk, int used)
 			if (sg[i].length)
 				return;
 
-			put_page(sg_page(sg + i));
+			if (put)
+				put_page(sg_page(sg + i));
 			sg_assign_page(sg + i, NULL);
 		}
 
@@ -143,7 +275,7 @@ static void skcipher_free_sgl(struct sock *sk)
 	struct alg_sock *ask = alg_sk(sk);
 	struct skcipher_ctx *ctx = ask->private;
 
-	skcipher_pull_sgl(sk, ctx->used);
+	skcipher_pull_sgl(sk, ctx->used, 1);
 }
 
 static int skcipher_wait_for_wmem(struct sock *sk, unsigned flags)
@@ -424,8 +556,152 @@ unlock:
 	return err ?: size;
 }
 
-static int skcipher_recvmsg(struct kiocb *unused, struct socket *sock,
-			    struct msghdr *msg, size_t ignored, int flags)
+static int skcipher_all_sg_nents(struct skcipher_ctx *ctx)
+{
+	struct skcipher_sg_list *sgl;
+	struct scatterlist *sg;
+	int nents = 0;
+
+	list_for_each_entry(sgl, &ctx->tsgl, list) {
+		sg = sgl->sg;
+
+		while (!sg->length)
+			sg++;
+
+		nents += sg_nents(sg);
+	}
+	return nents;
+}
+
+static int skcipher_recvmsg_async(struct kiocb *iocb, struct socket *sock,
+				  struct msghdr *msg, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	const struct iovec *iov;
+	unsigned long iovlen;
+	struct skcipher_sg_list *sgl;
+	struct scatterlist *sg;
+	struct skcipher_async_req *sreq;
+	struct ablkcipher_request *req;
+	struct skcipher_async_rsgl *last_rsgl = NULL;
+	unsigned int len = 0, tx_nents = skcipher_all_sg_nents(ctx);
+	int i = 0;
+	int err = -ENOMEM;
+
+	lock_sock(sk);
+	req = mempool_alloc(ctx->pool, GFP_KERNEL);
+	if (unlikely(!req))
+		goto unlock;
+
+	sreq = GET_SREQ(req, ctx);
+	sreq->iocb = iocb;
+	INIT_LIST_HEAD(&sreq->list);
+	memcpy(sreq->iv, ctx->iv, GET_IV_SIZE(ctx));
+	sreq->tsg = kcalloc(tx_nents, sizeof(*sg), GFP_KERNEL);
+	if (!sreq->tsg) {
+		mempool_free(req, ctx->pool);
+		goto unlock;
+	}
+	sg_init_table(sreq->tsg, tx_nents);
+	for (iov = msg->msg_iter.iov, iovlen = msg->msg_iter.nr_segs;
+	     iovlen > 0; iovlen--, iov++) {
+		unsigned long seglen = iov->iov_len;
+		char __user *from = iov->iov_base;
+		struct skcipher_async_rsgl *rsgl;
+
+		while (seglen) {
+			unsigned long used;
+
+			if (!ctx->used) {
+				err = skcipher_wait_for_data(sk, flags);
+				if (err)
+					goto free;
+			}
+			sgl = list_first_entry(&ctx->tsgl,
+					       struct skcipher_sg_list, list);
+			sg = sgl->sg;
+
+			while (!sg->length)
+				sg++;
+
+			used = min_t(unsigned long, ctx->used, seglen);
+			used = min_t(unsigned long, used, sg->length);
+
+			if (i == tx_nents) {
+				struct scatterlist *tmp;
+				int x;
+
+				/* Ran out of tx slots in async request
+				 * need to expand */
+				tmp = kcalloc(tx_nents * 2, sizeof(*tmp),
+					      GFP_KERNEL);
+				if (!tmp)
+					goto free;
+
+				sg_init_table(tmp, tx_nents * 2);
+				for (x = 0; x < tx_nents; x++)
+					sg_set_page(&tmp[x],
+						    sg_page(&sreq->tsg[x]),
+						    sreq->tsg[x].length,
+						    sreq->tsg[x].offset);
+				kfree(sreq->tsg);
+				sreq->tsg = tmp;
+				tx_nents *= 2;
+			}
+			/* Need to take over the tx sgl from ctx
+			 * to the asynch req - these sgls will be freed later */
+			sg_set_page(sreq->tsg + i++, sg_page(sg), sg->length,
+				    sg->offset);
+
+			if (list_empty(&sreq->list)) {
+				rsgl = &sreq->first_sgl;
+				list_add(&rsgl->list, &sreq->list);
+			} else {
+				rsgl = kzalloc(sizeof(*rsgl), GFP_KERNEL);
+				if (!rsgl) {
+					err = -ENOMEM;
+					goto free;
+				}
+				list_add(&rsgl->list, &sreq->list);
+			}
+
+			used = af_alg_make_sg(&rsgl->sgl, from, used, 1);
+			err = used;
+			if (used < 0)
+				goto free;
+			if (last_rsgl)
+				af_alg_link_sg(&last_rsgl->sgl, &rsgl->sgl);
+
+			last_rsgl = rsgl;
+			len += used;
+			from += used;
+			seglen -= used;
+			skcipher_pull_sgl(sk, used, 0);
+		}
+	}
+
+	ablkcipher_request_set_crypt(req, sreq->tsg, sreq->first_sgl.sgl.sg,
+				     len, sreq->iv);
+	err = ctx->enc ? crypto_ablkcipher_encrypt(req) :
+			 crypto_ablkcipher_decrypt(req);
+	if (err == -EINPROGRESS) {
+		atomic_inc(&ctx->inflight);
+		err = -EIOCBQUEUED;
+		goto unlock;
+	}
+free:
+	skcipher_free_async_sgls(sreq);
+	mempool_free(req, ctx->pool);
+unlock:
+	skcipher_wmem_wakeup(sk);
+	release_sock(sk);
+	return err;
+}
+
+static int skcipher_recvmsg_sync(struct socket *sock, struct msghdr *msg,
+				 int flags)
 {
 	struct sock *sk = sock->sk;
 	struct alg_sock *ask = alg_sk(sk);
@@ -493,7 +769,7 @@ free:
 			copied += used;
 			from += used;
 			seglen -= used;
-			skcipher_pull_sgl(sk, used);
+			skcipher_pull_sgl(sk, used, 1);
 		}
 	}
 
@@ -506,6 +782,13 @@ unlock:
 	return copied ?: err;
 }
 
+static int skcipher_recvmsg(struct kiocb *iocb, struct socket *sock,
+			    struct msghdr *msg, size_t ignored, int flags)
+{
+	return is_sync_kiocb(iocb) ?
+		skcipher_recvmsg_sync(sock, msg, flags) :
+		skcipher_recvmsg_async(iocb, sock, msg, flags);
+}
 
 static unsigned int skcipher_poll(struct file *file, struct socket *sock,
 				  poll_table *wait)
@@ -564,12 +847,25 @@ static int skcipher_setkey(void *private, const u8 *key, unsigned int keylen)
 	return crypto_ablkcipher_setkey(private, key, keylen);
 }
 
+static void skcipher_wait(struct sock *sk)
+{
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	int ctr = 0;
+
+	while (atomic_read(&ctx->inflight) && ctr++ < 100)
+		msleep(100);
+}
+
 static void skcipher_sock_destruct(struct sock *sk)
 {
 	struct alg_sock *ask = alg_sk(sk);
 	struct skcipher_ctx *ctx = ask->private;
 	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(&ctx->req);
 
+	if (atomic_read(&ctx->inflight))
+		skcipher_wait(sk);
+	skcipher_mempool_destroy(ctx);
 	skcipher_free_sgl(sk);
 	sock_kzfree_s(sk, ctx->iv, crypto_ablkcipher_ivsize(tfm));
 	sock_kfree_s(sk, ctx, ctx->len);
@@ -601,6 +897,7 @@ static int skcipher_accept_parent(void *private, struct sock *sk)
 	ctx->more = 0;
 	ctx->merge = 0;
 	ctx->enc = 0;
+	atomic_set(&ctx->inflight, 0);
 	af_alg_init_completion(&ctx->completion);
 
 	ask->private = ctx;
@@ -609,6 +906,12 @@ static int skcipher_accept_parent(void *private, struct sock *sk)
 	ablkcipher_request_set_callback(&ctx->req, CRYPTO_TFM_REQ_MAY_BACKLOG,
 					af_alg_complete, &ctx->completion);
 
+	if (skcipher_mempool_create(sk)) {
+		sock_kzfree_s(sk, ctx->iv, crypto_ablkcipher_ivsize(private));
+		sock_kfree_s(sk, ctx, ctx->len);
+		return -ENOMEM;
+	}
+
 	sk->sk_destruct = skcipher_sock_destruct;
 
 	return 0;
