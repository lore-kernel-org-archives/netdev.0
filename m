From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/4] crypto: algif_skcipher - User-space interface for skcipher operations
Date: Tue, 19 Oct 2010 21:46:02 +0800
Message-ID: <E1P8CVu-0003ZV-CL@gondolin.me.apana.org.au>
References: <20100907084213.GA4610@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:57810 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab0JSNqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 09:46:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

crypto: algif_skcipher - User-space interface for skcipher operations

This patch adds the af_alg plugin for symmetric key ciphers,
corresponding to the ablkcipher kernel operation type.

Keys can optionally be set through the setsockopt interface.

Once a sendmsg call occurs without MSG_MORE no further writes
may be made to the socket until all previous data has been read.

IVs and and whether encryption/decryption is performed can be
set through the setsockopt interface or as a control message
to sendmsg.

The interface is completely synchronous, all operations are
carried out in recvmsg(2) and will complete prior to the system
call returning.

The splice(2) interface support reading the user-space data directly
without copying (except that the Crypto API itself may copy the data
if alignment is off).

The recvmsg(2) interface supports directly writing to user-space
without additional copying, i.e., the kernel crypto interface will
receive the user-space address as its output SG list.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/Kconfig          |    8 
 crypto/Makefile         |    1 
 crypto/algif_skcipher.c |  664 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 673 insertions(+)

diff --git a/crypto/Kconfig b/crypto/Kconfig
index 6db27d7..69437e2 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -852,6 +852,14 @@ config CRYPTO_USER_API_HASH
 	  This option enables the user-spaces interface for hash
 	  algorithms.
 
+config CRYPTO_USER_API_SKCIPHER
+	tristate "User-space interface for symmetric key cipher algorithms"
+	select CRYPTO_BLKCIPHER
+	select CRYPTO_USER_API
+	help
+	  This option enables the user-spaces interface for symmetric
+	  key cipher algorithms.
+
 source "drivers/crypto/Kconfig"
 
 endif	# if CRYPTO
diff --git a/crypto/Makefile b/crypto/Makefile
index 14ab405..efc0f18 100644
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -87,6 +87,7 @@ obj-$(CONFIG_CRYPTO_TEST) += tcrypt.o
 obj-$(CONFIG_CRYPTO_GHASH) += ghash-generic.o
 obj-$(CONFIG_CRYPTO_USER_API) += af_alg.o
 obj-$(CONFIG_CRYPTO_USER_API_HASH) += algif_hash.o
+obj-$(CONFIG_CRYPTO_USER_API_SKCIPHER) += algif_skcipher.o
 
 #
 # generic algorithms and the async_tx api
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
new file mode 100644
index 0000000..af26040
--- /dev/null
+++ b/crypto/algif_skcipher.c
@@ -0,0 +1,664 @@
+/*
+ * algif_skcipher: User-space interface for skcipher algorithms
+ *
+ * This file provides the user-space API for symmetric key ciphers.
+ *
+ * Copyright (c) 2010 Herbert Xu <herbert@gondor.apana.org.au>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ */
+
+#include <crypto/skcipher.h>
+#include <crypto/if_alg.h>
+#include <linux/completion.h>
+#include <linux/init.h>
+#include <linux/list.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/net.h>
+#include <net/sock.h>
+
+struct skcipher_sg_list {
+	struct list_head list;
+
+	int cur;
+
+	struct scatterlist sg[0];
+};
+
+struct skcipher_ctx {
+	struct list_head tsgl;
+	struct af_alg_sgl rsgl;
+
+	struct completion completion;
+
+	void *iv;
+
+	unsigned used;
+
+	unsigned int len;
+	int err;
+	bool more;
+	bool merge;
+	bool enc;
+
+	struct ablkcipher_request req;
+};
+
+#define MAX_SGL_ENTS ((PAGE_SIZE - sizeof(struct skcipher_sg_list)) / \
+		      sizeof(struct scatterlist) - 1)
+
+static inline bool skcipher_writable(struct sock *sk)
+{
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+
+	return ctx->used + PAGE_SIZE <= max_t(int, sk->sk_sndbuf, PAGE_SIZE);
+}
+
+static void skcipher_done(struct crypto_async_request *req, int err)
+{
+	struct sock *sk = req->data;
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+
+	ctx->err = err;
+	complete(&ctx->completion);
+}
+
+static int skcipher_alloc_sgl(struct sock *sk, int size)
+{
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	struct skcipher_sg_list *sgl;
+	struct scatterlist *sg = NULL;
+
+	sgl = list_first_entry(&ctx->tsgl, struct skcipher_sg_list, list);
+	if (!list_empty(&ctx->tsgl))
+		sg = sgl->sg;
+
+	if (!sg || sgl->cur >= MAX_SGL_ENTS) {
+		sgl = sock_kmalloc(sk, sizeof(*sgl) +
+				       sizeof(sgl->sg[0]) * (MAX_SGL_ENTS + 1),
+				   GFP_KERNEL);
+		if (!sgl)
+			return -ENOMEM;
+
+		sg_init_table(sgl->sg, MAX_SGL_ENTS + 1);
+		sgl->cur = 0;
+
+		if (sg)
+			sg_chain(sg, MAX_SGL_ENTS + 1, sgl->sg);
+
+		list_add_tail(&sgl->list, &ctx->tsgl);
+	}
+
+	return 0;
+}
+
+static void skcipher_pull_sgl(struct sock *sk, int used)
+{
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	struct skcipher_sg_list *sgl;
+	struct scatterlist *sg;
+	int i;
+
+	while (!list_empty(&ctx->tsgl)) {
+		sgl = list_first_entry(&ctx->tsgl, struct skcipher_sg_list,
+				       list);
+		sg = sgl->sg;
+
+		for (i = 0; i < sgl->cur; i++) {
+			int plen = min_t(int, used, sg[i].length);
+
+			if (!sg_page(sg + i))
+				continue;
+
+			if (!used)
+				return;
+
+			sg[i].length -= plen;
+			sg[i].offset += plen;
+
+			if (!sg[i].length) {
+				put_page(sg_page(sg + i));
+				sg_assign_page(sg + i, NULL);
+			}
+
+			used -= plen;
+			ctx->used -= plen;
+		}
+
+		list_del(&sgl->list);
+		sock_kfree_s(sk, sgl,
+			     sizeof(*sgl) + sizeof(sgl->sg[0]) *
+					    (MAX_SGL_ENTS + 1));
+	}
+
+	if (!ctx->used)
+		ctx->merge = 0;
+}
+
+static void skcipher_free_sgl(struct sock *sk)
+{
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+
+	skcipher_pull_sgl(sk, ctx->used);
+}
+
+static int skcipher_wait_for_wmem(struct sock *sk, unsigned flags)
+{
+	DEFINE_WAIT(wait);
+	int err = -ERESTARTSYS;
+
+	if (flags & MSG_DONTWAIT)
+		return -EAGAIN;
+
+	set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+
+	for (;;) {
+		if (signal_pending(current))
+			break;
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		if (skcipher_writable(sk)) {
+			err = 0;
+			break;
+		}
+		schedule();
+	}
+	finish_wait(sk_sleep(sk), &wait);
+
+	return err;
+}
+
+static void skcipher_wmem_wakeup(struct sock *sk)
+{
+	struct socket_wq *wq;
+
+	if (!skcipher_writable(sk))
+		return;
+
+	rcu_read_lock();
+	wq = rcu_dereference(sk->sk_wq);
+	if (wq_has_sleeper(wq))
+		wake_up_interruptible_sync_poll(&wq->wait, POLLIN |
+							   POLLRDNORM |
+							   POLLRDBAND);
+	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
+	rcu_read_unlock();
+}
+
+static int skcipher_wait_for_data(struct sock *sk, unsigned flags)
+{
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	DEFINE_WAIT(wait);
+	int err = -ERESTARTSYS;
+
+	if (flags & MSG_DONTWAIT) {
+		return -EAGAIN;
+	}
+
+	set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+
+	for (;;) {
+		if (signal_pending(current))
+			break;
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		if (ctx->used) {
+			err = 0;
+			break;
+		}
+		schedule();
+	}
+	finish_wait(sk_sleep(sk), &wait);
+
+	clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+
+	return err;
+}
+
+static void skcipher_data_wakeup(struct sock *sk)
+{
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	struct socket_wq *wq;
+
+	if (!ctx->used);
+		return;
+
+	rcu_read_lock();
+	wq = rcu_dereference(sk->sk_wq);
+	if (wq_has_sleeper(wq))
+		wake_up_interruptible_sync_poll(&wq->wait, POLLOUT |
+							   POLLRDNORM |
+							   POLLRDBAND);
+	sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
+	rcu_read_unlock();
+}
+
+static int skcipher_sendmsg(struct kiocb *unused, struct socket *sock,
+			    struct msghdr *msg, size_t size)
+{
+	struct sock *sk = sock->sk;
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(&ctx->req);
+	unsigned ivsize = crypto_ablkcipher_ivsize(tfm);
+	struct skcipher_sg_list *sgl;
+	struct af_alg_control con = {};
+	long copied = 0;
+	bool enc = 0;
+	int limit;
+	int err;
+	int i;
+
+	if (msg->msg_controllen) {
+		err = af_alg_cmsg_send(msg, &con);
+		if (err)
+			return err;
+
+		switch (con.op) {
+		case ALG_OP_ENCRYPT:
+			enc = 1;
+			break;
+		case ALG_OP_DECRYPT:
+			enc = 0;
+			break;
+		default:
+			return -EINVAL;
+		}
+
+		if (con.iv && con.iv->ivlen != ivsize)
+			return -EINVAL;
+	}
+
+	err = -EINVAL;
+
+	lock_sock(sk);
+	if (!ctx->more && ctx->used)
+		goto unlock;
+
+	if (!ctx->used) {
+		ctx->enc = enc;
+		if (con.iv)
+			memcpy(ctx->iv, con.iv->iv, ivsize);
+	}
+
+	limit = max_t(int, sk->sk_sndbuf, PAGE_SIZE);
+	limit -= ctx->used;
+
+	while (size) {
+		struct scatterlist *sg;
+		unsigned long len = size;
+		int plen;
+
+		if (ctx->merge) {
+			sgl = list_entry(ctx->tsgl.prev,
+					 struct skcipher_sg_list, list);
+			sg = sgl->sg + sgl->cur - 1;
+			len = min_t(unsigned long, len, PAGE_SIZE - sg->length);
+
+			err = memcpy_fromiovec(page_address(sg_page(sg)) +
+					       sg->length, msg->msg_iov, len);
+			if (err)
+				goto unlock;
+
+			sg->length += len;
+			ctx->merge = sg->length & (PAGE_SIZE - 1);
+
+			size -= len;
+			copied += len;
+			continue;
+		}
+
+		if (limit < PAGE_SIZE) {
+			release_sock(sk);
+			err = skcipher_wait_for_wmem(sk, msg->msg_flags);
+			lock_sock(sk);
+			if (err)
+				goto unlock;
+
+			limit = max_t(int, sk->sk_sndbuf, PAGE_SIZE);
+			limit -= ctx->used;
+		}
+
+		len = min_t(unsigned long, len, limit);
+
+		err = skcipher_alloc_sgl(sk, len);
+		if (err)
+			goto unlock;
+
+		sgl = list_first_entry(&ctx->tsgl, struct skcipher_sg_list,
+				       list);
+		sg = sgl->sg;
+		do {
+			i = sgl->cur;
+			plen = min_t(int, len, PAGE_SIZE);
+
+			sg_assign_page(sg + i, alloc_page(GFP_KERNEL));
+			err = -ENOMEM;
+			if (!sg_page(sg + i))
+				goto unlock;
+
+			err = memcpy_fromiovec(page_address(sg_page(sg + i)),
+					       msg->msg_iov, plen);
+			if (err) {
+				__free_page(sg_page(sg + i));
+				sg_assign_page(sg + i, NULL);
+				goto unlock;
+			}
+
+			sg[i].length = plen;
+			len -= plen;
+			ctx->used += plen;
+			copied += plen;
+			size -= plen;
+			limit -= plen;
+			sgl->cur++;
+		} while (sg_page(sg + ++i));
+
+		ctx->merge = plen & (PAGE_SIZE - 1);
+		if (ctx->merge)
+			sgl->cur--;
+	}
+
+	err = 0;
+
+	ctx->more = msg->msg_flags & MSG_MORE;
+	if (!ctx->more && !list_empty(&ctx->tsgl)) {
+		sgl = list_entry(ctx->tsgl.prev, struct skcipher_sg_list, list);
+		sg_mark_end(sgl->sg + sgl->cur - 1);
+	}
+
+unlock:
+	skcipher_data_wakeup(sk);
+	release_sock(sk);
+
+	return copied ?: err;
+}
+
+static ssize_t skcipher_sendpage(struct socket *sock, struct page *page,
+				 int offset, size_t size, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	struct skcipher_sg_list *sgl;
+	int err = -EINVAL;
+	int limit;
+
+	lock_sock(sk);
+	if (!ctx->more && ctx->used)
+		goto unlock;
+
+	if (!size)
+		goto done;
+
+	limit = max_t(int, sk->sk_sndbuf, PAGE_SIZE);
+	limit -= ctx->used;
+
+	if (limit < PAGE_SIZE) {
+		release_sock(sk);
+		err = skcipher_wait_for_wmem(sk, flags);
+		lock_sock(sk);
+		if (err)
+			goto unlock;
+
+		limit = max_t(int, sk->sk_sndbuf, PAGE_SIZE);
+		limit -= ctx->used;
+	}
+
+	err = skcipher_alloc_sgl(sk, 0);
+	if (err)
+		goto unlock;
+
+	ctx->merge = 0;
+	sgl = list_entry(ctx->tsgl.prev, struct skcipher_sg_list, list);
+
+	sg_set_page(sgl->sg + sgl->cur, page, size, offset);
+	sgl->cur++;
+
+done:
+	ctx->more = flags & MSG_MORE;
+	if (!ctx->more && !list_empty(&ctx->tsgl)) {
+		sgl = list_entry(ctx->tsgl.prev, struct skcipher_sg_list, list);
+		sg_mark_end(sgl->sg + sgl->cur - 1);
+	}
+
+unlock:
+	skcipher_data_wakeup(sk);
+	release_sock(sk);
+
+	return err ?: size;
+}
+
+static int skcipher_recvmsg(struct kiocb *unused, struct socket *sock,
+			    struct msghdr *msg, size_t ignored, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	unsigned bs = crypto_ablkcipher_blocksize(crypto_ablkcipher_reqtfm(
+		&ctx->req));
+	struct skcipher_sg_list *sgl;
+	struct scatterlist *sg;
+	unsigned long iovlen;
+	struct iovec *iov;
+	int err = -EAGAIN;
+	int used;
+	long copied = 0;
+
+	lock_sock(sk);
+	for (iov = msg->msg_iov, iovlen = msg->msg_iovlen; iovlen > 0;
+	     iovlen--, iov++) {
+		unsigned long seglen = iov->iov_len;
+		char *from = iov->iov_base;
+
+		sgl = list_first_entry(&ctx->tsgl, struct skcipher_sg_list,
+				       list);
+		sg = sgl->sg;
+		while (!sg->length)
+			sg++;
+
+		while (seglen) {
+			used = ctx->used;
+			if (!used) {
+				release_sock(sk);
+				err = skcipher_wait_for_data(sk, flags);
+				lock_sock(sk);
+				if (err)
+					goto unlock;
+			}
+
+			used = min_t(unsigned long, used, seglen);
+
+			if (ctx->more || used < ctx->used)
+				used -= used % bs;
+
+			err = -EINVAL;
+			if (!used)
+				goto unlock;
+
+			used = af_alg_make_sg(&ctx->rsgl, from, used, 1);
+			if (used < 0)
+				goto unlock;
+
+			ablkcipher_request_set_crypt(&ctx->req, sg,
+						     ctx->rsgl.sg, used,
+						     ctx->iv);
+
+			err = ctx->enc ?
+			      crypto_ablkcipher_encrypt(&ctx->req) :
+			      crypto_ablkcipher_decrypt(&ctx->req);
+
+			switch (err) {
+			case -EINPROGRESS:
+			case -EBUSY:
+				wait_for_completion(&ctx->completion);
+				INIT_COMPLETION(ctx->completion);
+				err = ctx->err;
+				break;
+			}
+
+			af_alg_free_sg(&ctx->rsgl);
+
+			if (err)
+				goto unlock;
+
+			copied += used;
+			from += used;
+			seglen -= used;
+			skcipher_pull_sgl(sk, used);
+		}
+	}
+
+	err = 0;
+
+unlock:
+	skcipher_wmem_wakeup(sk);
+	release_sock(sk);
+
+	return copied ?: err;
+}
+
+
+unsigned int skcipher_poll(struct file *file, struct socket *sock,
+			   poll_table *wait)
+{
+	struct sock *sk = sock->sk;
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	unsigned int mask;
+
+	sock_poll_wait(file, sk_sleep(sk), wait);
+	mask = 0;
+
+	if (ctx->used)
+		mask |= POLLIN | POLLRDNORM;
+
+	if (skcipher_writable(sk))
+		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+
+	return mask;
+}
+
+static struct proto_ops algif_skcipher_ops = {
+	.family		=	PF_ALG,
+
+	.connect	=	sock_no_connect,
+	.socketpair	=	sock_no_socketpair,
+	.getname	=	sock_no_getname,
+	.ioctl		=	sock_no_ioctl,
+	.listen		=	sock_no_listen,
+	.shutdown	=	sock_no_shutdown,
+	.getsockopt	=	sock_no_getsockopt,
+	.mmap		=	sock_no_mmap,
+	.bind		=	sock_no_bind,
+	.accept		=	sock_no_accept,
+	.setsockopt	=	sock_no_setsockopt,
+
+	.release	=	af_alg_release,
+	.sendmsg	=	skcipher_sendmsg,
+	.sendpage	=	skcipher_sendpage,
+	.recvmsg	=	skcipher_recvmsg,
+	.poll		=	skcipher_poll,
+};
+
+static void *skcipher_bind(const char *name, u32 type, u32 mask)
+{
+	return crypto_alloc_ablkcipher(name, type, mask);
+}
+
+static void skcipher_release(void *private)
+{
+	crypto_free_ablkcipher(private);
+}
+
+static int skcipher_setkey(void *private, const u8 *key, unsigned int keylen)
+{
+	return crypto_ablkcipher_setkey(private, key, keylen);
+}
+
+static void skcipher_sock_destruct(struct sock *sk)
+{
+	struct alg_sock *ask = alg_sk(sk);
+	struct skcipher_ctx *ctx = ask->private;
+	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(&ctx->req);
+
+	skcipher_free_sgl(sk);
+	sock_kfree_s(sk, ctx->iv, crypto_ablkcipher_blocksize(tfm));
+	sock_kfree_s(sk, ctx, ctx->len);
+	af_alg_release_parent(sk);
+}
+
+static int skcipher_accept_parent(void *private, struct sock *sk)
+{
+	struct skcipher_ctx *ctx;
+	struct alg_sock *ask = alg_sk(sk);
+	unsigned int len = sizeof(*ctx) + crypto_ablkcipher_reqsize(private);
+
+	ctx = sock_kmalloc(sk, len, GFP_KERNEL);
+	if (!ctx)
+		return -ENOMEM;
+
+	ctx->iv = sock_kmalloc(sk, crypto_ablkcipher_ivsize(private),
+			       GFP_KERNEL);
+	if (!ctx->iv) {
+		sock_kfree_s(sk, ctx, len);
+		return -ENOMEM;
+	}
+
+	memset(ctx->iv, 0, crypto_ablkcipher_ivsize(private));
+
+	INIT_LIST_HEAD(&ctx->tsgl);
+	ctx->len = len;
+	ctx->used = 0;
+	ctx->more = 0;
+	ctx->merge = 0;
+	ctx->enc = 0;
+	init_completion(&ctx->completion);
+
+	ask->private = ctx;
+
+	ablkcipher_request_set_tfm(&ctx->req, private);
+	ablkcipher_request_set_callback(&ctx->req, CRYPTO_TFM_REQ_MAY_BACKLOG,
+					skcipher_done, sk);
+
+	sk->sk_destruct = skcipher_sock_destruct;
+
+	return 0;
+}
+
+static const struct af_alg_type algif_type_skcipher = {
+	.bind		=	skcipher_bind,
+	.release	=	skcipher_release,
+	.setkey		=	skcipher_setkey,
+	.accept		=	skcipher_accept_parent,
+	.ops		=	&algif_skcipher_ops,
+	.name		=	"skcipher",
+	.owner		=	THIS_MODULE
+};
+
+static int __init algif_skcipher_init(void)
+{
+	return af_alg_register_type(&algif_type_skcipher);
+}
+
+static void __exit algif_skcipher_exit(void)
+{
+	int err = af_alg_unregister_type(&algif_type_skcipher);
+	BUG_ON(err);
+}
+
+module_init(algif_skcipher_init);
+module_exit(algif_skcipher_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(AF_ALG);
