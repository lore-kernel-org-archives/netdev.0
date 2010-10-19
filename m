From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/4] crypto: algif_hash - User-space interface for hash operations
Date: Tue, 19 Oct 2010 21:46:02 +0800
Message-ID: <E1P8CVu-0003ZJ-43@gondolin.me.apana.org.au>
References: <20100907084213.GA4610@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

crypto: algif_hash - User-space interface for hash operations

This patch adds the af_alg plugin for hash, corresponding to
the ahash kernel operation type.

Keys can optionally be set through the setsockopt interface.

Each sendmsg call will finalise the hash unless sent with a MSG_MORE
flag.

Partial hash states can be cloned using accept(2).

The interface is completely synchronous, all operations will
complete prior to the system call returning.

Both sendmsg(2) and splice(2) support reading the user-space
data directly without copying (except that the Crypto API itself
may copy the data if alignment is off).

For now only the splice(2) interface supports performing digest
instead of init/update/final.  In future the sendmsg(2) interface
will also be modified to use digest/finup where possible so that
hardware that cannot return a partial hash state can still benefit
from this interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/Kconfig      |    8 +
 crypto/Makefile     |    1 
 crypto/algif_hash.c |  345 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 354 insertions(+)

diff --git a/crypto/Kconfig b/crypto/Kconfig
index 357e3ca..6db27d7 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -844,6 +844,14 @@ config CRYPTO_ANSI_CPRNG
 config CRYPTO_USER_API
 	tristate
 
+config CRYPTO_USER_API_HASH
+	tristate "User-space interface for hash algorithms"
+	select CRYPTO_HASH
+	select CRYPTO_USER_API
+	help
+	  This option enables the user-spaces interface for hash
+	  algorithms.
+
 source "drivers/crypto/Kconfig"
 
 endif	# if CRYPTO
diff --git a/crypto/Makefile b/crypto/Makefile
index 0b13197..14ab405 100644
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -86,6 +86,7 @@ obj-$(CONFIG_CRYPTO_ANSI_CPRNG) += ansi_cprng.o
 obj-$(CONFIG_CRYPTO_TEST) += tcrypt.o
 obj-$(CONFIG_CRYPTO_GHASH) += ghash-generic.o
 obj-$(CONFIG_CRYPTO_USER_API) += af_alg.o
+obj-$(CONFIG_CRYPTO_USER_API_HASH) += algif_hash.o
 
 #
 # generic algorithms and the async_tx api
diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
new file mode 100644
index 0000000..28f29aa
--- /dev/null
+++ b/crypto/algif_hash.c
@@ -0,0 +1,345 @@
+/*
+ * algif_hash: User-space interface for hash algorithms
+ *
+ * This file provides the user-space API for hash algorithms.
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
+#include <crypto/hash.h>
+#include <crypto/if_alg.h>
+#include <linux/completion.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/net.h>
+#include <net/sock.h>
+
+struct hash_ctx {
+	struct af_alg_sgl sgl;
+
+	struct completion completion;
+	u8 *result;
+
+	unsigned int len;
+	int err;
+	bool more;
+
+	struct ahash_request req;
+};
+
+static void hash_done(struct crypto_async_request *req, int err)
+{
+	struct sock *sk = req->data;
+	struct alg_sock *ask = alg_sk(sk);
+	struct hash_ctx *ctx = ask->private;
+
+	ctx->err = err;
+	complete(&ctx->completion);
+}
+
+static int hash_sendmsg(struct kiocb *unused, struct socket *sock,
+			struct msghdr *msg, size_t ignored)
+{
+	int limit = ALG_MAX_PAGES * PAGE_SIZE;
+	struct sock *sk = sock->sk;
+	struct alg_sock *ask = alg_sk(sk);
+	struct hash_ctx *ctx = ask->private;
+	unsigned long iovlen;
+	struct iovec *iov;
+	long copied = 0;
+	int err;
+
+	if (limit > sk->sk_sndbuf)
+		limit = sk->sk_sndbuf;
+
+	lock_sock(sk);
+	if (!ctx->more) {
+		err = crypto_ahash_init(&ctx->req);
+		if (err)
+			goto unlock;
+	}
+
+	ctx->more = 0;
+
+	for (iov = msg->msg_iov, iovlen = msg->msg_iovlen; iovlen > 0;
+	     iovlen--, iov++) {
+		unsigned long seglen = iov->iov_len;
+		char *from = iov->iov_base;
+
+		while (seglen) {
+			int len = min_t(unsigned long, seglen, limit);
+			int newlen;
+
+			newlen = af_alg_make_sg(&ctx->sgl, from, len, 0);
+			if (newlen < 0)
+				goto unlock;
+
+			ahash_request_set_crypt(&ctx->req, ctx->sgl.sg, NULL,
+						newlen);
+
+			err = crypto_ahash_update(&ctx->req);
+			switch (err) {
+			case -EINPROGRESS:
+			case -EBUSY:
+				wait_for_completion(&ctx->completion);
+				INIT_COMPLETION(ctx->completion);
+				err = ctx->err;
+				break;
+			}
+
+			af_alg_free_sg(&ctx->sgl);
+
+			if (err)
+				goto unlock;
+
+			seglen -= newlen;
+			from += newlen;
+			copied += newlen;
+		}
+	}
+
+	err = 0;
+
+	ctx->more = msg->msg_flags & MSG_MORE;
+	if (!ctx->more) {
+		ahash_request_set_crypt(&ctx->req, NULL, ctx->result, 0);
+		err = crypto_ahash_final(&ctx->req);
+
+		switch (err) {
+		case -EINPROGRESS:
+		case -EBUSY:
+			wait_for_completion(&ctx->completion);
+			INIT_COMPLETION(ctx->completion);
+			err = ctx->err;
+			break;
+		}
+	}
+
+unlock:
+	release_sock(sk);
+
+	return err ?: copied;
+}
+
+static ssize_t hash_sendpage(struct socket *sock, struct page *page,
+			     int offset, size_t size, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct alg_sock *ask = alg_sk(sk);
+	struct hash_ctx *ctx = ask->private;
+	int err;
+
+	lock_sock(sk);
+	sg_init_table(ctx->sgl.sg, 1);
+	sg_set_page(ctx->sgl.sg, page, size, offset);
+
+	ahash_request_set_callback(&ctx->req, CRYPTO_TFM_REQ_MAY_BACKLOG,
+				   hash_done, sk);
+	ahash_request_set_crypt(&ctx->req, ctx->sgl.sg, ctx->result, size);
+
+	if (!(flags & MSG_MORE)) {
+		if (ctx->more)
+			err = crypto_ahash_finup(&ctx->req);
+		else
+			err = crypto_ahash_digest(&ctx->req);
+	} else {
+		if (!ctx->more) {
+			err = crypto_ahash_init(&ctx->req);
+			if (err)
+				goto unlock;
+		}
+
+		err = crypto_ahash_update(&ctx->req);
+	}
+
+	switch (err) {
+	case -EINPROGRESS:
+	case -EBUSY:
+		wait_for_completion(&ctx->completion);
+		INIT_COMPLETION(ctx->completion);
+		err = ctx->err;
+		if (err)
+			goto unlock;
+		break;
+	}
+
+	err = 0;
+
+	ctx->more = flags & MSG_MORE;
+
+unlock:
+	release_sock(sk);
+
+	return err ?: size;
+}
+
+static int hash_recvmsg(struct kiocb *unused, struct socket *sock,
+			struct msghdr *msg, size_t len, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct alg_sock *ask = alg_sk(sk);
+	struct hash_ctx *ctx = ask->private;
+	unsigned ds = crypto_ahash_digestsize(crypto_ahash_reqtfm(&ctx->req));
+	int err = -EINVAL;
+
+	if (len > ds)
+		len = ds;
+	else if (len < ds)
+		msg->msg_flags |= MSG_TRUNC;
+
+	lock_sock(sk);
+	if (!ctx->more)
+		err = memcpy_toiovec(msg->msg_iov, ctx->result, len);
+	release_sock(sk);
+
+	return err ?: len;
+}
+
+static int hash_accept(struct socket *sock, struct socket *newsock, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct alg_sock *ask = alg_sk(sk);
+	struct hash_ctx *ctx = ask->private;
+	struct ahash_request *req = &ctx->req;
+	char state[crypto_ahash_statesize(crypto_ahash_reqtfm(req))];
+	struct sock *sk2;
+	struct alg_sock *ask2;
+	struct hash_ctx *ctx2;
+	int err;
+
+	err = crypto_ahash_export(req, state);
+	if (err)
+		return err;
+
+	err = af_alg_accept(sk, newsock);
+	if (err)
+		return err;
+
+	sk2 = newsock->sk;
+	ask2 = alg_sk(sk2);
+	ctx2 = ask2->private;
+
+	err = crypto_ahash_import(&ctx2->req, state);
+	if (err) {
+		sock_orphan(sk2);
+		sock_put(sk2);
+	}
+
+	return err;
+}
+
+static struct proto_ops algif_hash_ops = {
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
+	.setsockopt	=	sock_no_setsockopt,
+	.poll		=	sock_no_poll,
+
+	.release	=	af_alg_release,
+	.sendmsg	=	hash_sendmsg,
+	.sendpage	=	hash_sendpage,
+	.recvmsg	=	hash_recvmsg,
+	.accept		=	hash_accept,
+};
+
+static void *hash_bind(const char *name, u32 type, u32 mask)
+{
+	return crypto_alloc_ahash(name, type, mask);
+}
+
+static void hash_release(void *private)
+{
+	crypto_free_ahash(private);
+}
+
+static int hash_setkey(void *private, const u8 *key, unsigned int keylen)
+{
+	return crypto_ahash_setkey(private, key, keylen);
+}
+
+static void hash_sock_destruct(struct sock *sk)
+{
+	struct alg_sock *ask = alg_sk(sk);
+	struct hash_ctx *ctx = ask->private;
+
+	sock_kfree_s(sk, ctx->result,
+		     crypto_ahash_digestsize(crypto_ahash_reqtfm(&ctx->req)));
+	sock_kfree_s(sk, ctx, ctx->len);
+	af_alg_release_parent(sk);
+}
+
+static int hash_accept_parent(void *private, struct sock *sk)
+{
+	struct hash_ctx *ctx;
+	struct alg_sock *ask = alg_sk(sk);
+	unsigned len = sizeof(*ctx) + crypto_ahash_reqsize(private);
+	unsigned ds = crypto_ahash_digestsize(private);
+
+	ctx = sock_kmalloc(sk, len, GFP_KERNEL);
+	if (!ctx)
+		return -ENOMEM;
+
+	ctx->result = sock_kmalloc(sk, ds, GFP_KERNEL);
+	if (!ctx->result) {
+		sock_kfree_s(sk, ctx, len);
+		return -ENOMEM;
+	}
+
+	memset(ctx->result, 0, ds);
+
+	ctx->len = len;
+	ctx->more = 0;
+	init_completion(&ctx->completion);
+
+	ask->private = ctx;
+
+	ahash_request_set_tfm(&ctx->req, private);
+	ahash_request_set_callback(&ctx->req, CRYPTO_TFM_REQ_MAY_BACKLOG,
+				   hash_done, sk);
+
+	sk->sk_destruct = hash_sock_destruct;
+
+	return 0;
+}
+
+static const struct af_alg_type algif_type_hash = {
+	.bind		=	hash_bind,
+	.release	=	hash_release,
+	.setkey		=	hash_setkey,
+	.accept		=	hash_accept_parent,
+	.ops		=	&algif_hash_ops,
+	.name		=	"hash",
+	.owner		=	THIS_MODULE
+};
+
+static int __init algif_hash_init(void)
+{
+	return af_alg_register_type(&algif_type_hash);
+}
+
+static void __exit algif_hash_exit(void)
+{
+	int err = af_alg_unregister_type(&algif_type_hash);
+	BUG_ON(err);
+}
+
+module_init(algif_hash_init);
+module_exit(algif_hash_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(AF_ALG);
