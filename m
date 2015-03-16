From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH v2 net-next 4/4] crypto: algif - change algif_skcipher to be
 asynchronous
Date: Mon, 16 Mar 2015 09:15:31 -0700
Message-ID: <20150316161531.16418.36380.stgit@tstruk-mobl1>
References: <20150316161508.16418.23674.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-aio@kvack.org, herbert@gondor.apana.org.au, netdev@vger.kernel.org,
 ying.xue@windriver.com, bcrl@kvack.org, viro@ZenIV.linux.org.uk,
 linux-fsdevel@vger.kernel.org, hch@lst.de, linux-crypto@vger.kernel.org
To: davem@davemloft.net
Return-path: <owner-linux-aio@kvack.org>
In-Reply-To: <20150316161508.16418.23674.stgit@tstruk-mobl1>
Sender: owner-linux-aio@kvack.org
List-Id: netdev.vger.kernel.org

From: Tadeusz Struk <tadeusz.struk@intel.com>

The way the algif_skcipher works currently is that on sendmsg/sendpage it
builds an sgl for the input data and then on read/recvmsg it sends the job
for encryption putting the user to sleep till the data is processed.
This way it can only handle one job at a given time.
This patch changes it to be asynchronous by adding AIO support.

Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
---
 crypto/algif_skcipher.c |  224 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 218 insertions(+), 6 deletions(-)

diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index b9743dc..5664c2b 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -39,6 +39,7 @@ struct skcipher_ctx {
 
 	struct af_alg_completion completion;
 
+	atomic_t inflight;
 	unsigned used;
 
 	unsigned int len;
@@ -49,9 +50,65 @@ struct skcipher_ctx {
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
+	struct skcipher_async_rsgl *rsgl, *tmp;
+	struct scatterlist *sgl;
+	struct scatterlist *sg;
+	int i, n;
+
+	list_for_each_entry_safe(rsgl, tmp, &sreq->list, list) {
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
+	kfree(req);
+	aio_complete(iocb, err, err);
+}
+
 static inline int skcipher_sndbuf(struct sock *sk)
 {
 	struct alg_sock *ask = alg_sk(sk);
@@ -96,7 +153,7 @@ static int skcipher_alloc_sgl(struct sock *sk)
 	return 0;
 }
 
-static void skcipher_pull_sgl(struct sock *sk, int used)
+static void skcipher_pull_sgl(struct sock *sk, int used, int put)
 {
 	struct alg_sock *ask = alg_sk(sk);
 	struct skcipher_ctx *ctx = ask->private;
@@ -123,8 +180,8 @@ static void skcipher_pull_sgl(struct sock *sk, int used)
 
 			if (sg[i].length)
 				return;
-
-			put_page(sg_page(sg + i));
+			if (put)
+				put_page(sg_page(sg + i));
 			sg_assign_page(sg + i, NULL);
 		}
 
@@ -143,7 +200,7 @@ static void skcipher_free_sgl(struct sock *sk)
 	struct alg_sock *ask = alg_sk(sk);
 	struct skcipher_ctx *ctx = ask->private;
 
-	skcipher_pull_sgl(sk, ctx->used);
+	skcipher_pull_sgl(sk, ctx->used, 1);
 }
 
 static int skcipher_wait_for_wmem(struct sock *sk, unsigned flags)
@@ -424,6 +481,147 @@ unlock:
 	return err ?: size;
 }
 
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
+	struct skcipher_sg_list *sgl;
+	struct scatterlist *sg;
+	struct skcipher_async_req *sreq;
+	struct ablkcipher_request *req;
+	struct skcipher_async_rsgl *last_rsgl = NULL;
+	unsigned int len = 0, tx_nents = skcipher_all_sg_nents(ctx);
+	unsigned int reqlen = sizeof(struct skcipher_async_req) +
+				GET_REQ_SIZE(ctx) + GET_IV_SIZE(ctx);
+	int i = 0;
+	int err = -ENOMEM;
+
+	lock_sock(sk);
+	req = kmalloc(reqlen, GFP_KERNEL);
+	if (unlikely(!req))
+		goto unlock;
+
+	sreq = GET_SREQ(req, ctx);
+	sreq->iocb = iocb;
+	memset(&sreq->first_sgl, '\0', sizeof(struct skcipher_async_rsgl));
+	INIT_LIST_HEAD(&sreq->list);
+	sreq->tsg = kcalloc(tx_nents, sizeof(*sg), GFP_KERNEL);
+	if (unlikely(!sreq->tsg)) {
+		kfree(req);
+		goto unlock;
+	}
+	sg_init_table(sreq->tsg, tx_nents);
+	memcpy(sreq->iv, ctx->iv, GET_IV_SIZE(ctx));
+	ablkcipher_request_set_tfm(req, crypto_ablkcipher_reqtfm(&ctx->req));
+	ablkcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
+					skcipher_async_cb, sk);
+
+	while (iov_iter_count(&msg->msg_iter)) {
+		struct skcipher_async_rsgl *rsgl;
+		unsigned long used;
+
+		if (!ctx->used) {
+			err = skcipher_wait_for_data(sk, flags);
+			if (err)
+				goto free;
+		}
+		sgl = list_first_entry(&ctx->tsgl,
+				       struct skcipher_sg_list, list);
+		sg = sgl->sg;
+
+		while (!sg->length)
+			sg++;
+
+		used = min_t(unsigned long, ctx->used,
+			     iov_iter_count(&msg->msg_iter));
+		used = min_t(unsigned long, used, sg->length);
+
+		if (i == tx_nents) {
+			struct scatterlist *tmp;
+			int x;
+			/* Ran out of tx slots in async request
+			 * need to expand */
+			tmp = kcalloc(tx_nents * 2, sizeof(*tmp),
+				      GFP_KERNEL);
+			if (!tmp)
+				goto free;
+
+			sg_init_table(tmp, tx_nents * 2);
+			for (x = 0; x < tx_nents; x++)
+				sg_set_page(&tmp[x], sg_page(&sreq->tsg[x]),
+					    sreq->tsg[x].length,
+					    sreq->tsg[x].offset);
+			kfree(sreq->tsg);
+			sreq->tsg = tmp;
+			tx_nents *= 2;
+		}
+		/* Need to take over the tx sgl from ctx
+		 * to the asynch req - these sgls will be freed later */
+		sg_set_page(sreq->tsg + i++, sg_page(sg), sg->length,
+			    sg->offset);
+
+		if (list_empty(&sreq->list)) {
+			rsgl = &sreq->first_sgl;
+			list_add_tail(&rsgl->list, &sreq->list);
+		} else {
+			rsgl = kzalloc(sizeof(*rsgl), GFP_KERNEL);
+			if (!rsgl) {
+				err = -ENOMEM;
+				goto free;
+			}
+			list_add_tail(&rsgl->list, &sreq->list);
+		}
+
+		used = af_alg_make_sg(&rsgl->sgl, &msg->msg_iter, used);
+		err = used;
+		if (used < 0)
+			goto free;
+		if (last_rsgl)
+			af_alg_link_sg(&last_rsgl->sgl, &rsgl->sgl);
+
+		last_rsgl = rsgl;
+		len += used;
+		skcipher_pull_sgl(sk, used, 0);
+		iov_iter_advance(&msg->msg_iter, used);
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
+	kfree(req);
+unlock:
+	skcipher_wmem_wakeup(sk);
+	release_sock(sk);
+	return err;
+}
+
 static int skcipher_recvmsg(struct socket *sock, struct msghdr *msg,
 			    size_t ignored, int flags)
 {
@@ -484,7 +682,7 @@ free:
 			goto unlock;
 
 		copied += used;
-		skcipher_pull_sgl(sk, used);
+		skcipher_pull_sgl(sk, used, 1);
 		iov_iter_advance(&msg->msg_iter, used);
 	}
 
@@ -497,7 +695,6 @@ unlock:
 	return copied ?: err;
 }
 
-
 static unsigned int skcipher_poll(struct file *file, struct socket *sock,
 				  poll_table *wait)
 {
@@ -537,6 +734,7 @@ static struct proto_ops algif_skcipher_ops = {
 	.sendmsg	=	skcipher_sendmsg,
 	.sendpage	=	skcipher_sendpage,
 	.recvmsg	=	skcipher_recvmsg,
+	.aio_recvmsg	=	skcipher_recvmsg_async,
 	.poll		=	skcipher_poll,
 };
 
@@ -555,12 +753,25 @@ static int skcipher_setkey(void *private, const u8 *key, unsigned int keylen)
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
+
 	skcipher_free_sgl(sk);
 	sock_kzfree_s(sk, ctx->iv, crypto_ablkcipher_ivsize(tfm));
 	sock_kfree_s(sk, ctx, ctx->len);
@@ -592,6 +803,7 @@ static int skcipher_accept_parent(void *private, struct sock *sk)
 	ctx->more = 0;
 	ctx->merge = 0;
 	ctx->enc = 0;
+	atomic_set(&ctx->inflight, 0);
 	af_alg_init_completion(&ctx->completion);
 
 	ask->private = ctx;

--
To unsubscribe, send a message with 'unsubscribe linux-aio' in
the body to majordomo@kvack.org.  For more info on Linux AIO,
see: http://www.kvack.org/aio/
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
