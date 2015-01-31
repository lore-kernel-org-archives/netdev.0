From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 12/18] switch af_alg_make_sg() to iov_iter
Date: Sat, 31 Jan 2015 03:56:38 +0000
Message-ID: <1422676604-18533-12-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55003 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758063AbbAaD4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 22:56:46 -0500
In-Reply-To: <20150131035513.GK29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 crypto/af_alg.c         | 40 ++++++++------------------
 crypto/algif_hash.c     | 45 ++++++++++++------------------
 crypto/algif_skcipher.c | 74 ++++++++++++++++++++++---------------------------
 include/crypto/if_alg.h |  3 +-
 4 files changed, 62 insertions(+), 100 deletions(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index 4665b79c..eb78fe8 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -338,49 +338,31 @@ static const struct net_proto_family alg_family = {
 	.owner	=	THIS_MODULE,
 };
 
-int af_alg_make_sg(struct af_alg_sgl *sgl, void __user *addr, int len,
-		   int write)
+int af_alg_make_sg(struct af_alg_sgl *sgl, struct iov_iter *iter, int len)
 {
-	unsigned long from = (unsigned long)addr;
-	unsigned long npages;
-	unsigned off;
-	int err;
-	int i;
-
-	err = -EFAULT;
-	if (!access_ok(write ? VERIFY_READ : VERIFY_WRITE, addr, len))
-		goto out;
-
-	off = from & ~PAGE_MASK;
-	npages = (off + len + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	if (npages > ALG_MAX_PAGES)
-		npages = ALG_MAX_PAGES;
+	size_t off;
+	ssize_t n;
+	int npages, i;
 
-	err = get_user_pages_fast(from, npages, write, sgl->pages);
-	if (err < 0)
-		goto out;
+	n = iov_iter_get_pages(iter, sgl->pages, len, ALG_MAX_PAGES, &off);
+	if (n < 0)
+		return n;
 
-	npages = err;
-	err = -EINVAL;
+	npages = PAGE_ALIGN(off + n);
 	if (WARN_ON(npages == 0))
-		goto out;
-
-	err = 0;
+		return -EINVAL;
 
 	sg_init_table(sgl->sg, npages);
 
-	for (i = 0; i < npages; i++) {
+	for (i = 0, len = n; i < npages; i++) {
 		int plen = min_t(int, len, PAGE_SIZE - off);
 
 		sg_set_page(sgl->sg + i, sgl->pages[i], plen, off);
 
 		off = 0;
 		len -= plen;
-		err += plen;
 	}
-
-out:
-	return err;
+	return n;
 }
 EXPORT_SYMBOL_GPL(af_alg_make_sg);
 
diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
index 01f56eb..01da360 100644
--- a/crypto/algif_hash.c
+++ b/crypto/algif_hash.c
@@ -41,8 +41,6 @@ static int hash_sendmsg(struct kiocb *unused, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct alg_sock *ask = alg_sk(sk);
 	struct hash_ctx *ctx = ask->private;
-	unsigned long iovlen;
-	const struct iovec *iov;
 	long copied = 0;
 	int err;
 
@@ -58,37 +56,28 @@ static int hash_sendmsg(struct kiocb *unused, struct socket *sock,
 
 	ctx->more = 0;
 
-	for (iov = msg->msg_iter.iov, iovlen = msg->msg_iter.nr_segs; iovlen > 0;
-	     iovlen--, iov++) {
-		unsigned long seglen = iov->iov_len;
-		char __user *from = iov->iov_base;
+	while (iov_iter_count(&msg->msg_iter)) {
+		int len = iov_iter_count(&msg->msg_iter);
 
-		while (seglen) {
-			int len = min_t(unsigned long, seglen, limit);
-			int newlen;
+		if (len > limit)
+			len = limit;
 
-			newlen = af_alg_make_sg(&ctx->sgl, from, len, 0);
-			if (newlen < 0) {
-				err = copied ? 0 : newlen;
-				goto unlock;
-			}
-
-			ahash_request_set_crypt(&ctx->req, ctx->sgl.sg, NULL,
-						newlen);
-
-			err = af_alg_wait_for_completion(
-				crypto_ahash_update(&ctx->req),
-				&ctx->completion);
+		len = af_alg_make_sg(&ctx->sgl, &msg->msg_iter, len);
+		if (len < 0) {
+			err = copied ? 0 : len;
+			goto unlock;
+		}
 
-			af_alg_free_sg(&ctx->sgl);
+		ahash_request_set_crypt(&ctx->req, ctx->sgl.sg, NULL, len);
 
-			if (err)
-				goto unlock;
+		err = af_alg_wait_for_completion(crypto_ahash_update(&ctx->req),
+						 &ctx->completion);
+		af_alg_free_sg(&ctx->sgl);
+		if (err)
+			goto unlock;
 
-			seglen -= newlen;
-			from += newlen;
-			copied += newlen;
-		}
+		copied += len;
+		iov_iter_advance(&msg->msg_iter, len);
 	}
 
 	err = 0;
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index c12207c..37110fd 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -426,67 +426,59 @@ static int skcipher_recvmsg(struct kiocb *unused, struct socket *sock,
 		&ctx->req));
 	struct skcipher_sg_list *sgl;
 	struct scatterlist *sg;
-	unsigned long iovlen;
-	const struct iovec *iov;
 	int err = -EAGAIN;
 	int used;
 	long copied = 0;
 
 	lock_sock(sk);
-	for (iov = msg->msg_iter.iov, iovlen = msg->msg_iter.nr_segs; iovlen > 0;
-	     iovlen--, iov++) {
-		unsigned long seglen = iov->iov_len;
-		char __user *from = iov->iov_base;
-
-		while (seglen) {
-			sgl = list_first_entry(&ctx->tsgl,
-					       struct skcipher_sg_list, list);
-			sg = sgl->sg;
-
-			while (!sg->length)
-				sg++;
-
-			if (!ctx->used) {
-				err = skcipher_wait_for_data(sk, flags);
-				if (err)
-					goto unlock;
-			}
+	while (iov_iter_count(&msg->msg_iter)) {
+		sgl = list_first_entry(&ctx->tsgl,
+				       struct skcipher_sg_list, list);
+		sg = sgl->sg;
 
-			used = min_t(unsigned long, ctx->used, seglen);
+		while (!sg->length)
+			sg++;
 
-			used = af_alg_make_sg(&ctx->rsgl, from, used, 1);
-			err = used;
-			if (err < 0)
+		used = ctx->used;
+		if (!used) {
+			err = skcipher_wait_for_data(sk, flags);
+			if (err)
 				goto unlock;
+		}
+
+		used = min_t(unsigned long, used, iov_iter_count(&msg->msg_iter));
+
+		used = af_alg_make_sg(&ctx->rsgl, &msg->msg_iter, used);
+		err = used;
+		if (err < 0)
+			goto unlock;
 
-			if (ctx->more || used < ctx->used)
-				used -= used % bs;
+		if (ctx->more || used < ctx->used)
+			used -= used % bs;
 
-			err = -EINVAL;
-			if (!used)
-				goto free;
+		err = -EINVAL;
+		if (!used)
+			goto free;
 
-			ablkcipher_request_set_crypt(&ctx->req, sg,
-						     ctx->rsgl.sg, used,
-						     ctx->iv);
+		ablkcipher_request_set_crypt(&ctx->req, sg,
+					     ctx->rsgl.sg, used,
+					     ctx->iv);
 
-			err = af_alg_wait_for_completion(
+		err = af_alg_wait_for_completion(
 				ctx->enc ?
 					crypto_ablkcipher_encrypt(&ctx->req) :
 					crypto_ablkcipher_decrypt(&ctx->req),
 				&ctx->completion);
 
 free:
-			af_alg_free_sg(&ctx->rsgl);
+		af_alg_free_sg(&ctx->rsgl);
 
-			if (err)
-				goto unlock;
+		if (err)
+			goto unlock;
 
-			copied += used;
-			from += used;
-			seglen -= used;
-			skcipher_pull_sgl(sk, used);
-		}
+		copied += used;
+		skcipher_pull_sgl(sk, used);
+		iov_iter_advance(&msg->msg_iter, used);
 	}
 
 	err = 0;
diff --git a/include/crypto/if_alg.h b/include/crypto/if_alg.h
index cd62bf4..88ea64e 100644
--- a/include/crypto/if_alg.h
+++ b/include/crypto/if_alg.h
@@ -67,8 +67,7 @@ int af_alg_unregister_type(const struct af_alg_type *type);
 int af_alg_release(struct socket *sock);
 int af_alg_accept(struct sock *sk, struct socket *newsock);
 
-int af_alg_make_sg(struct af_alg_sgl *sgl, void __user *addr, int len,
-		   int write);
+int af_alg_make_sg(struct af_alg_sgl *sgl, struct iov_iter *iter, int len);
 void af_alg_free_sg(struct af_alg_sgl *sgl);
 
 int af_alg_cmsg_send(struct msghdr *msg, struct af_alg_control *con);
-- 
2.1.4
