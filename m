From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Distributed storage release.
Date: Tue, 9 Sep 2008 15:38:18 +0400
Message-ID: <20080909113817.GA14005@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

I am pleased to announce new Distributed Storage (DST) project release.

DST is a block layer network device, which among others has following
features:

 * Kernel-side client and server. No need for any special tools for
	data processing (like special userspace applications) except
	for configuration.
 * Bullet-proof memory allocations via memory pools for all temporary
 	objects (transaction and so on).
 * Zero-copy sending (except header) if supported by device
 	using sendpage().
 * Failover recovery in case of broken link
 	(reconnection if remote node is down).
 * Full transaction support (resending of the failed transactions
 	on timeout of after reconnect to failed node).
 * Dynamically resizeable pool of threads used for data receiving
 	and crypto processing.
 * Initial autoconfiguration. Ability to extend it with additional
 	attributes if needed.
 * Support for any kind of network media (not limited to tcp or inet
 	protocols) higher MAC layer (socket layer). Out of the box
	kernel-side IPv6 support (needs to extend configuration utility,
	check how it was done in POHMELFS [1]).
 * Security attributes for local export nodes (list of allowed to
 	connect addresses with permissions).
 * Ability to use any supported cryptographically strong checksums.
 	Ability to encrypt data channel.

This release brings following changes:
 * compilation warnings removed
 * space, init, alloc, config, debug cleanups
 * s o m e c h e c k p a t c h . p l m a s t u r b a t i o n
 * new DST name

Consider for inclusion.

One can grab sources (various configuration examples can be found
in 'userspace' dir) from archive, or via kernel and userspace GIT trees.

1. POHMELFS homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=pohmelfs

2. DST homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst

3. DST archive.
http://tservice.net.ru/~s0mbre/archive/dst/

4. DST git trees.
http://tservice.net.ru/~s0mbre/archive/dst/dst.git/
http://tservice.net.ru/~s0mbre/archive/dst/dst-userspace.git/

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index 0d1d213..56a64fe 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -433,4 +433,6 @@ config VIRTIO_BLK
 	  This is the virtual block driver for virtio.  It can be used with
           lguest or QEMU based VMMs (like KVM or Xen).  Say Y or M.
 
+source "drivers/block/dst/Kconfig"
+
 endif # BLK_DEV
diff --git a/drivers/block/Makefile b/drivers/block/Makefile
index 5e58430..26bcf8a 100644
--- a/drivers/block/Makefile
+++ b/drivers/block/Makefile
@@ -31,3 +31,5 @@ obj-$(CONFIG_BLK_DEV_SX8)	+= sx8.o
 obj-$(CONFIG_BLK_DEV_UB)	+= ub.o
 
 obj-$(CONFIG_XEN_BLKDEV_FRONTEND)	+= xen-blkfront.o
+
+obj-$(CONFIG_DST)	+= dst/
diff --git a/drivers/block/dst/Kconfig b/drivers/block/dst/Kconfig
new file mode 100644
index 0000000..2f42f98
--- /dev/null
+++ b/drivers/block/dst/Kconfig
@@ -0,0 +1,14 @@
+config DST
+	tristate "Distributed storage"
+	depends on NET
+	select CONNECTOR
+	select LIBCRC32C
+	---help---
+	This driver allows to create a distributed storage block device.
+
+config DST_DEBUG
+	bool "DST debug"
+	depends on DST
+	---help---
+	This option will turn HEAVY debugging of the DST.
+	Turn it on ONLY if you have to debug some really obscure problem.
diff --git a/drivers/block/dst/Makefile b/drivers/block/dst/Makefile
new file mode 100644
index 0000000..526fc62
--- /dev/null
+++ b/drivers/block/dst/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_DST) += dst.o
+
+dst-y := dcore.o state.o export.o thread_pool.o crypto.o trans.o
diff --git a/drivers/block/dst/crypto.c b/drivers/block/dst/crypto.c
new file mode 100644
index 0000000..67817a3
--- /dev/null
+++ b/drivers/block/dst/crypto.c
@@ -0,0 +1,678 @@
+/*
+ * 2007+ Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/bio.h>
+#include <linux/crypto.h>
+#include <linux/dst.h>
+#include <linux/kernel.h>
+#include <linux/scatterlist.h>
+#include <linux/slab.h>
+
+static inline u64 dst_gen_iv(struct dst_trans *t)
+{
+	return t->gen;
+}
+
+static struct crypto_hash *dst_init_hash(struct dst_crypto_ctl *ctl, u8 *key)
+{
+	int err;
+	struct crypto_hash *hash;
+
+	hash = crypto_alloc_hash(ctl->hash_algo, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(hash)) {
+		err = PTR_ERR(hash);
+		dprintk("%s: failed to allocate hash '%s', err: %d.\n",
+				__func__, ctl->hash_algo, err);
+		goto err_out_exit;
+	}
+
+	ctl->crypto_attached_size = crypto_hash_digestsize(hash);
+
+#if defined CONFIG_DST_DEBUG
+	dprintk("%s: keysize: %u, key: ", __func__, ctl->hash_keysize);
+	for (err = 0; err < ctl->hash_keysize; ++err)
+		printk("%02x ", key[err]);
+	printk("\n");
+#endif
+	if (!ctl->hash_keysize)
+		return hash;
+
+	err = crypto_hash_setkey(hash, key, ctl->hash_keysize);
+	if (err) {
+		dprintk("%s: failed to set key for hash '%s', err: %d.\n",
+				__func__, ctl->hash_algo, err);
+		goto err_out_free;
+	}
+
+	return hash;
+
+err_out_free:
+	crypto_free_hash(hash);
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+static struct crypto_ablkcipher *dst_init_cipher(struct dst_crypto_ctl *ctl, u8 *key)
+{
+	int err = -EINVAL;
+	struct crypto_ablkcipher *cipher;
+
+	if (!ctl->cipher_keysize)
+		goto err_out_exit;
+
+	cipher = crypto_alloc_ablkcipher(ctl->cipher_algo, 0, 0);
+	if (IS_ERR(cipher)) {
+		err = PTR_ERR(cipher);
+		dprintk("%s: failed to allocate cipher '%s', err: %d.\n",
+				__func__, ctl->cipher_algo, err);
+		goto err_out_exit;
+	}
+
+	crypto_ablkcipher_clear_flags(cipher, ~0);
+
+	err = crypto_ablkcipher_setkey(cipher, key, ctl->cipher_keysize);
+	if (err) {
+		dprintk("%s: failed to set key for cipher '%s', err: %d.\n",
+				__func__, ctl->cipher_algo, err);
+		goto err_out_free;
+	}
+
+	return cipher;
+
+err_out_free:
+	crypto_free_ablkcipher(cipher);
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+static void dst_crypto_pages_free(struct dst_crypto_engine *e)
+{
+	unsigned int i;
+
+	for (i=0; i<e->page_num; ++i)
+		__free_page(e->pages[i]);
+	kfree(e->pages);
+}
+
+static int dst_crypto_pages_alloc(struct dst_crypto_engine *e, int num)
+{
+	int i;
+
+	e->pages = kmalloc(num * sizeof(struct page **), GFP_KERNEL);
+	if (!e->pages)
+		return -ENOMEM;
+
+	for (i=0; i<num; ++i) {
+		e->pages[i] = alloc_page(GFP_KERNEL);
+		if (!e->pages[i])
+			goto err_out_free_pages;
+	}
+
+	e->page_num = num;
+	return 0;
+
+err_out_free_pages:
+	while (--i >= 0)
+		__free_page(e->pages[i]);
+
+	kfree(e->pages);
+	return -ENOMEM;
+}
+
+static int dst_crypto_engine_init(struct dst_crypto_engine *e, struct dst_node *n)
+{
+	int err;
+	struct dst_crypto_ctl *ctl = &n->crypto;
+
+	err = dst_crypto_pages_alloc(e, n->max_pages);
+	if (err)
+		goto err_out_exit;
+
+	e->size = PAGE_SIZE;
+	e->data = kmalloc(e->size, GFP_KERNEL);
+	if (!e->data) {
+		err = -ENOMEM;
+		goto err_out_free_pages;
+	}
+
+	if (ctl->hash_algo[0]) {
+		e->hash = dst_init_hash(ctl, n->hash_key);
+		if (IS_ERR(e->hash)) {
+			err = PTR_ERR(e->hash);
+			e->hash = NULL;
+			goto err_out_free;
+		}
+	}
+
+	if (ctl->cipher_algo[0]) {
+		e->cipher = dst_init_cipher(ctl, n->cipher_key);
+		if (IS_ERR(e->cipher)) {
+			err = PTR_ERR(e->cipher);
+			e->cipher = NULL;
+			goto err_out_free_hash;
+		}
+	}
+
+	return 0;
+
+err_out_free_hash:
+	crypto_free_hash(e->hash);
+err_out_free:
+	kfree(e->data);
+err_out_free_pages:
+	dst_crypto_pages_free(e);
+err_out_exit:
+	return err;
+}
+
+static void dst_crypto_engine_exit(struct dst_crypto_engine *e)
+{
+	if (e->hash)
+		crypto_free_hash(e->hash);
+	if (e->cipher)
+		crypto_free_ablkcipher(e->cipher);
+	dst_crypto_pages_free(e);
+	kfree(e->data);
+}
+
+struct dst_crypto_completion
+{
+	struct completion		complete;
+	int				error;
+};
+
+static void dst_crypto_complete(struct crypto_async_request *req, int err)
+{
+	struct dst_crypto_completion *c = req->data;
+
+	if (err == -EINPROGRESS)
+		return;
+
+	dprintk("%s: req: %p, err: %d.\n", __func__, req, err);
+	c->error = err;
+	complete(&c->complete);
+}
+
+static int dst_crypto_process(struct ablkcipher_request *req,
+		struct scatterlist *sg_dst, struct scatterlist *sg_src,
+		void *iv, int enc, unsigned long timeout)
+{
+	struct dst_crypto_completion c;
+	int err;
+
+	init_completion(&c.complete);
+	c.error = -EINPROGRESS;
+
+	ablkcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
+					dst_crypto_complete, &c);
+
+	ablkcipher_request_set_crypt(req, sg_src, sg_dst, sg_src->length, iv);
+
+	if (enc)
+		err = crypto_ablkcipher_encrypt(req);
+	else
+		err = crypto_ablkcipher_decrypt(req);
+
+	switch (err) {
+		case -EINPROGRESS:
+		case -EBUSY:
+			err = wait_for_completion_interruptible_timeout(&c.complete,
+					timeout);
+			if (!err)
+				err = -ETIMEDOUT;
+			else
+				err = c.error;
+			break;
+		default:
+			break;
+	}
+
+	return err;
+}
+
+static int dst_trans_iter_out(struct bio *bio, struct dst_crypto_engine *e,
+		int (* iterator) (struct dst_crypto_engine *e,
+				  struct scatterlist *dst,
+				  struct scatterlist *src))
+{
+	struct bio_vec *bv;
+	int err, i;
+
+	sg_init_table(e->src, bio->bi_vcnt);
+	sg_init_table(e->dst, bio->bi_vcnt);
+
+	bio_for_each_segment(bv, bio, i) {
+		sg_set_page(&e->src[i], bv->bv_page, bv->bv_len, bv->bv_offset);
+		sg_set_page(&e->dst[i], e->pages[i], bv->bv_len, bv->bv_offset);
+
+		err = iterator(e, &e->dst[i], &e->src[i]);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int dst_trans_iter_in(struct bio *bio, struct dst_crypto_engine *e,
+		int (* iterator) (struct dst_crypto_engine *e,
+				  struct scatterlist *dst,
+				  struct scatterlist *src))
+{
+	struct bio_vec *bv;
+	int err, i;
+
+	sg_init_table(e->src, bio->bi_vcnt);
+	sg_init_table(e->dst, bio->bi_vcnt);
+
+	bio_for_each_segment(bv, bio, i) {
+		sg_set_page(&e->src[i], bv->bv_page, bv->bv_len, bv->bv_offset);
+		sg_set_page(&e->dst[i], bv->bv_page, bv->bv_len, bv->bv_offset);
+
+		err = iterator(e, &e->dst[i], &e->src[i]);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int dst_crypt_iterator(struct dst_crypto_engine *e,
+		struct scatterlist *sg_dst, struct scatterlist *sg_src)
+{
+	struct ablkcipher_request *req = e->data;
+	u8 iv[32];
+
+	memset(iv, 0, sizeof(iv));
+
+	memcpy(iv, &e->iv, sizeof(e->iv));
+
+	return dst_crypto_process(req, sg_dst, sg_src, iv, e->enc, e->timeout);
+}
+
+static int dst_crypt(struct dst_crypto_engine *e, struct bio *bio)
+{
+	struct ablkcipher_request *req = e->data;
+
+	memset(req, 0, sizeof(struct ablkcipher_request));
+	ablkcipher_request_set_tfm(req, e->cipher);
+
+	if (e->enc)
+		return dst_trans_iter_out(bio, e, dst_crypt_iterator);
+	else
+		return dst_trans_iter_in(bio, e, dst_crypt_iterator);
+}
+
+static int dst_hash_iterator(struct dst_crypto_engine *e,
+		struct scatterlist *sg_dst, struct scatterlist *sg_src)
+{
+	return crypto_hash_update(e->data, sg_src, sg_src->length);
+}
+
+static int dst_hash(struct dst_crypto_engine *e, struct bio *bio, void *dst)
+{
+	struct hash_desc *desc = e->data;
+	int err;
+
+	desc->tfm = e->hash;
+	desc->flags = 0;
+
+	err = crypto_hash_init(desc);
+	if (err)
+		return err;
+
+	err = dst_trans_iter_in(bio, e, dst_hash_iterator);
+	if (err)
+		return err;
+
+	err = crypto_hash_final(desc, dst);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+static void *dst_crypto_thread_init(void *data)
+{
+	struct dst_node *n = data;
+	struct dst_crypto_engine *e;
+	int err = -ENOMEM;
+
+	e = kzalloc(sizeof(struct dst_crypto_engine), GFP_KERNEL);
+	if (!e)
+		goto err_out_exit;
+	e->src = kzalloc(sizeof(struct scatterlist) * 2 * n->max_pages,
+			GFP_KERNEL);
+	if (!e->src)
+		goto err_out_free;
+
+	e->dst = e->src + n->max_pages;
+
+	err = dst_crypto_engine_init(e, n);
+	if (err)
+		goto err_out_free;
+
+	return e;
+
+err_out_free:
+	kfree(e->src);
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+static void dst_crypto_thread_cleanup(void *private)
+{
+	struct dst_crypto_engine *e = private;
+
+	dst_crypto_engine_exit(e);
+	kfree(e->src);
+	kfree(e);
+}
+
+int dst_node_crypto_init(struct dst_node *n, struct dst_crypto_ctl *ctl)
+{
+	void *key = (ctl + 1);
+	int err = -ENOMEM, i;
+	char name[32];
+
+	if (ctl->hash_keysize) {
+		n->hash_key = kmalloc(ctl->hash_keysize, GFP_KERNEL);
+		if (!n->hash_key)
+			goto err_out_exit;
+		memcpy(n->hash_key, key, ctl->hash_keysize);
+	}
+
+	if (ctl->cipher_keysize) {
+		n->cipher_key = kmalloc(ctl->cipher_keysize, GFP_KERNEL);
+		if (!n->cipher_key)
+			goto err_out_free_hash;
+		memcpy(n->cipher_key, key, ctl->cipher_keysize);
+	}
+	memcpy(&n->crypto, ctl, sizeof(struct dst_crypto_ctl));
+
+	for (i=0; i<ctl->thread_num; ++i) {
+		snprintf(name, sizeof(name), "%s-crypto-%d", n->name, i);
+		/* Unique ids... */
+		err = thread_pool_add_worker(n->pool, name, i+10,
+			dst_crypto_thread_init, dst_crypto_thread_cleanup, n);
+		if (err)
+			goto err_out_free_threads;
+	}
+
+	return 0;
+
+err_out_free_threads:
+	while (--i >= 0)
+		thread_pool_del_worker_id(n->pool, i+10);
+
+	if (ctl->cipher_keysize)
+		kfree(n->cipher_key);
+	ctl->cipher_keysize = 0;
+err_out_free_hash:
+	if (ctl->hash_keysize)
+		kfree(n->hash_key);
+	ctl->hash_keysize = 0;
+err_out_exit:
+	return err;
+}
+
+void dst_node_crypto_exit(struct dst_node *n)
+{
+	struct dst_crypto_ctl *ctl = &n->crypto;
+
+	if (ctl->cipher_algo[0] || ctl->hash_algo[0]) {
+		kfree(n->hash_key);
+		kfree(n->cipher_key);
+	}
+}
+
+static int dst_trans_crypto_setup(void *crypto_engine, void *trans)
+{
+	struct dst_crypto_engine *e = crypto_engine;
+
+	e->private = trans;
+	return 0;
+}
+
+#if 0
+static void dst_dump_bio(struct bio *bio)
+{
+	u8 *p;
+	struct bio_vec *bv;
+	int i;
+
+	bio_for_each_segment(bv, bio, i) {
+		dprintk("%s: %llu/%u: size: %u, offset: %u, data: ",
+				__func__, bio->bi_sector, bio->bi_size,
+				bv->bv_len, bv->bv_offset);
+
+		p = kmap(bv->bv_page) + bv->bv_offset;
+		for (i=0; i<bv->bv_len; ++i)
+			printk("%02x ", p[i]);
+		kunmap(bv->bv_page);
+		printk("\n");
+	}
+}
+#endif
+
+static int dst_crypto_process_sending(struct dst_crypto_engine *e,
+		struct bio *bio, u8 *hash)
+{
+	int err;
+
+	if (e->cipher) {
+		err = dst_crypt(e, bio);
+		if (err)
+			goto err_out_exit;
+	}
+
+	if (e->hash) {
+		err = dst_hash(e, bio, hash);
+		if (err)
+			goto err_out_exit;
+
+#if defined CONFIG_DST_DEBUG
+		{
+			unsigned int i;
+
+			//dst_dump_bio(bio);
+
+			printk("%s: bio: %llu/%u, rw: %lu, hash: ",
+				__func__, (u64)bio->bi_sector,
+				bio->bi_size, bio_data_dir(bio));
+			for (i=0; i<crypto_hash_digestsize(e->hash); ++i)
+					printk("%02x ", hash[i]);
+			printk("\n");
+		}
+#endif
+	}
+
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+static int dst_crypto_process_receiving(struct dst_crypto_engine *e,
+		struct bio *bio, u8 *hash, u8 *recv_hash)
+{
+	int err;
+
+	if (e->hash) {
+		int mismatch;
+
+		err = dst_hash(e, bio, hash);
+		if (err)
+			goto err_out_exit;
+
+		mismatch = !!memcmp(recv_hash, hash,
+				crypto_hash_digestsize(e->hash));
+#if defined CONFIG_DST_DEBUG
+		//dst_dump_bio(bio);
+
+		printk("%s: bio: %llu/%u, rw: %lu, hash mismatch: %d",
+			__func__, (u64)bio->bi_sector, bio->bi_size,
+			bio_data_dir(bio), mismatch);
+		if (mismatch) {
+			unsigned int i;
+
+			printk(", recv/calc: ");
+			for (i=0; i<crypto_hash_digestsize(e->hash); ++i) {
+				printk("%02x/%02x ", recv_hash[i], hash[i]);
+			}
+		}
+		printk("\n");
+#endif
+		err = -1;
+		if (mismatch)
+			goto err_out_exit;
+	}
+
+	if (e->cipher) {
+		err = dst_crypt(e, bio);
+		if (err)
+			goto err_out_exit;
+	}
+
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+static int dst_trans_crypto_action(void *crypto_engine, void *schedule_data)
+{
+	struct dst_crypto_engine *e = crypto_engine;
+	struct dst_trans *t = schedule_data;
+	struct bio *bio = t->bio;
+	int err;
+
+	dprintk("%s: t: %p, gen: %llu, cipher: %p, hash: %p.\n",
+			__func__, t, t->gen, e->cipher, e->hash);
+
+	e->enc = t->enc;
+	e->iv = dst_gen_iv(t);
+
+	if (bio_data_dir(bio) == WRITE) {
+		err = dst_crypto_process_sending(e, bio, t->cmd.hash);
+		if (err)
+			goto err_out_exit;
+
+		if (e->hash) {
+			t->cmd.csize = crypto_hash_digestsize(e->hash);
+			t->cmd.size += t->cmd.csize;
+		}
+
+		return dst_trans_send(t);
+	} else {
+		u8 *hash = e->data + e->size/2;
+
+		err = dst_crypto_process_receiving(e, bio, hash, t->cmd.hash);
+		if (err)
+			goto err_out_exit;
+
+		dst_trans_remove(t);
+		dst_trans_put(t);
+	}
+
+	return 0;
+
+err_out_exit:
+	t->error = err;
+	dst_trans_put(t);
+	return err;
+}
+
+int dst_trans_crypto(struct dst_trans *t)
+{
+	struct dst_node *n = t->n;
+	int err;
+
+	err = thread_pool_schedule(n->pool,
+		dst_trans_crypto_setup, dst_trans_crypto_action,
+		t, MAX_SCHEDULE_TIMEOUT);
+	if (err)
+		goto err_out_exit;
+
+	return 0;
+
+err_out_exit:
+	dst_trans_put(t);
+	return err;
+}
+
+static int dst_export_crypto_setup(void *crypto_engine, void *bio)
+{
+	struct dst_crypto_engine *e = crypto_engine;
+
+	e->private = bio;
+	return 0;
+}
+
+static int dst_export_crypto_action(void *crypto_engine, void *schedule_data)
+{
+	struct dst_crypto_engine *e = crypto_engine;
+	struct bio *bio = schedule_data;
+	struct dst_export_priv *p = bio->bi_private;
+	int err;
+
+	dprintk("%s: e: %p, data: %p, bio: %llu/%u, dir: %lu.\n", __func__,
+		e, e->data, (u64)bio->bi_sector, bio->bi_size, bio_data_dir(bio));
+
+	e->enc = (bio_data_dir(bio) == READ);
+	e->iv = p->cmd.id;
+
+	if (bio_data_dir(bio) == WRITE) {
+		u8 *hash = e->data + e->size/2;
+
+		err = dst_crypto_process_receiving(e, bio, hash, p->cmd.hash);
+		if (err)
+			goto err_out_exit;
+
+		generic_make_request(bio);
+	} else {
+		err = dst_crypto_process_sending(e, bio, p->cmd.hash);
+		if (err)
+			goto err_out_exit;
+
+		if (e->hash) {
+			p->cmd.csize = crypto_hash_digestsize(e->hash);
+			p->cmd.size += p->cmd.csize;
+		}
+
+		err = dst_export_send_bio(bio);
+	}
+	return 0;
+
+err_out_exit:
+	bio_put(bio);
+	return err;
+}
+
+int dst_export_crypto(struct dst_node *n, struct bio *bio)
+{
+	int err;
+
+	err = thread_pool_schedule(n->pool,
+		dst_export_crypto_setup, dst_export_crypto_action,
+		bio, MAX_SCHEDULE_TIMEOUT);
+	if (err)
+		goto err_out_exit;
+
+	return 0;
+
+err_out_exit:
+	bio_put(bio);
+	return err;
+}
diff --git a/drivers/block/dst/dcore.c b/drivers/block/dst/dcore.c
new file mode 100644
index 0000000..e0744d3
--- /dev/null
+++ b/drivers/block/dst/dcore.c
@@ -0,0 +1,833 @@
+/*
+ * 2007+ Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/blkdev.h>
+#include <linux/bio.h>
+#include <linux/buffer_head.h>
+#include <linux/connector.h>
+#include <linux/dst.h>
+#include <linux/device.h>
+#include <linux/jhash.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/socket.h>
+
+#include <linux/in.h>
+#include <linux/in6.h>
+
+#include <net/sock.h>
+
+static int dst_major;
+
+static DEFINE_MUTEX(dst_hash_lock);
+static struct list_head *dst_hashtable;
+static unsigned int dst_hashtable_size = 128;
+module_param(dst_hashtable_size, uint, 0644);
+
+static char dst_name[] = "Linux benevolent dictator said: there is no spoon, black and white";
+
+/*
+ * DST sysfs tree for device called 'storage':
+ *
+ * /sys/bus/dst/devices/storage/
+ * /sys/bus/dst/devices/storage/type : 192.168.4.80:1025
+ * /sys/bus/dst/devices/storage/size : 800
+ * /sys/bus/dst/devices/storage/name : storage
+ */
+
+static int dst_dev_match(struct device *dev, struct device_driver *drv)
+{
+	return 1;
+}
+
+static struct bus_type dst_dev_bus_type = {
+	.name 		= "dst",
+	.match 		= &dst_dev_match,
+};
+
+static void dst_node_release(struct device *dev)
+{
+}
+
+static struct device dst_node_dev = {
+	.bus 		= &dst_dev_bus_type,
+	.release 	= &dst_node_release
+};
+
+static void dst_node_set_size(struct dst_node *n)
+{
+	struct block_device *bdev;
+
+	set_capacity(n->disk, n->size >> 9);
+
+	bdev = bdget_disk(n->disk, 0);
+	if (bdev) {
+		mutex_lock(&bdev->bd_inode->i_mutex);
+		i_size_write(bdev->bd_inode, n->size);
+		mutex_unlock(&bdev->bd_inode->i_mutex);
+		bdput(bdev);
+	}
+}
+
+/*
+ * Distributed storage request processing function.
+ */
+static int dst_request(struct request_queue *q, struct bio *bio)
+{
+	struct dst_node *n = q->queuedata;
+
+	bio_get(bio);
+
+	return dst_process_bio(n, bio);
+}
+
+static int dst_bdev_open(struct inode *inode, struct file *filp)
+{
+	struct dst_node *n = inode->i_bdev->bd_disk->private_data;
+
+	dst_node_get(n);
+	return 0;
+}
+
+static int dst_bdev_release(struct inode *inode, struct file *filp)
+{
+	struct dst_node *n = inode->i_bdev->bd_disk->private_data;
+
+	dst_node_put(n);
+	return 0;
+}
+
+static struct block_device_operations dst_blk_ops = {
+	.open		= dst_bdev_open,
+	.release	= dst_bdev_release,
+	.owner		= THIS_MODULE,
+};
+
+/*
+ * Block layer binding - disk is created when array is fully configured
+ * by userspace request.
+ */
+static int dst_node_create_disk(struct dst_node *n)
+{
+	int err = -ENOMEM;
+
+	n->queue = blk_alloc_queue(GFP_KERNEL);
+	if (!n->queue)
+		goto err_out_exit;
+
+	n->queue->queuedata = n;
+	blk_queue_max_phys_segments(n->queue, n->max_pages);
+	blk_queue_make_request(n->queue, dst_request);
+	blk_queue_bounce_limit(n->queue, BLK_BOUNCE_ANY);
+
+	err = -EINVAL;
+	n->disk = alloc_disk(1);
+	if (!n->disk)
+		goto err_out_free_queue;
+
+	if (n->state->permissions != DST_PERM_WRITE) {
+		printk(KERN_INFO "DST node %s attached read-only.\n", n->name);
+		set_disk_ro(n->disk, 1);
+	}
+
+	n->disk->major = dst_major;
+	n->disk->first_minor = (((unsigned long)n->disk) ^
+		(((unsigned long)n->disk) >> 31)) & 0xff;
+	n->disk->fops = &dst_blk_ops;
+	n->disk->queue = n->queue;
+	n->disk->private_data = n;
+	snprintf(n->disk->disk_name, sizeof(n->disk->disk_name),
+			"dst-%s-%d", n->name, n->disk->first_minor);
+
+	return 0;
+
+err_out_free_queue:
+	blk_cleanup_queue(n->queue);
+err_out_exit:
+	return err;
+}
+
+static ssize_t dst_show_size(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct dst_node *n = container_of(dev, struct dst_node, device);
+
+	return sprintf(buf, "%llu\n", n->size);
+}
+
+/*
+ * Shows type of the remote node - device major/minor number
+ * for local nodes and address (af_inet ipv4/ipv6 only) for remote nodes.
+ */
+static ssize_t dst_show_type(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct dst_node *n = container_of(dev, struct dst_node, device);
+	struct sockaddr addr;
+	struct socket *sock;
+	int addrlen;
+
+	sock = n->state->socket;
+	if (sock->ops->getname(sock, &addr, &addrlen, 2))
+		return 0;
+
+	if (sock->ops->family == AF_INET) {
+		struct sockaddr_in *sin = (struct sockaddr_in *)&addr;
+		return sprintf(buf, "%u.%u.%u.%u:%d\n",
+			NIPQUAD(sin->sin_addr.s_addr), ntohs(sin->sin_port));
+	} else if (sock->ops->family == AF_INET6) {
+		struct sockaddr_in6 *sin = (struct sockaddr_in6 *)&addr;
+		return sprintf(buf,
+			"%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%d\n",
+			NIP6(sin->sin6_addr), ntohs(sin->sin6_port));
+	} else {
+		int i, sz = PAGE_SIZE - 2; /* 0 symbol and '\n' below */
+		int size;
+		unsigned char *a = (unsigned char *)&addr;
+		char *buf_orig = buf;
+
+		size = snprintf(buf, sz, "family: %d, addrlen: %u, addr: ",
+				addr.sa_family, addrlen);
+		sz -= size;
+		buf += size;
+
+		for (i=0; i<addrlen; ++i) {
+			if (sz < 3)
+				break;
+
+			size = snprintf(buf, sz, "%02x ", a[i]);
+			sz -= size;
+			buf += size;
+		}
+		buf += sprintf(buf, "\n");
+
+		return buf - buf_orig;
+	}
+	return 0;
+}
+
+static struct device_attribute dst_node_attrs[] = {
+	__ATTR(size, 0444, dst_show_size, NULL),
+	__ATTR(type, 0444, dst_show_type, NULL),
+};
+
+static int dst_create_node_attributes(struct dst_node *n)
+{
+	int err, i;
+
+	for (i=0; i<ARRAY_SIZE(dst_node_attrs); ++i) {
+		err = device_create_file(&n->device,
+				&dst_node_attrs[i]);
+		if (err)
+			goto err_out_remove_all;
+	}
+	return 0;
+
+err_out_remove_all:
+	while (--i >= 0)
+		device_remove_file(&n->device,
+				&dst_node_attrs[i]);
+
+	return err;
+}
+
+static void dst_remove_node_attributes(struct dst_node *n)
+{
+	int i;
+
+	for (i=0; i<ARRAY_SIZE(dst_node_attrs); ++i)
+		device_remove_file(&n->device,
+				&dst_node_attrs[i]);
+}
+
+static void dst_node_sysfs_exit(struct dst_node *n)
+{
+	if (n->device.bus_id[0]) {
+		dst_remove_node_attributes(n);
+		device_unregister(&n->device);
+		memset(&n->device, 0, sizeof(n->device));
+	}
+}
+
+static int dst_node_sysfs_init(struct dst_node *n)
+{
+	int err;
+
+	memcpy(&n->device, &dst_node_dev, sizeof(struct device));
+
+	snprintf(n->device.bus_id, sizeof(n->device.bus_id), "dst-%s", n->name);
+	err = device_register(&n->device);
+	if (err) {
+		dprintk(KERN_ERR "Failed to register node '%s', err: %d.\n",
+				n->name, err);
+		goto err_out_exit;
+	}
+
+	dst_create_node_attributes(n);
+
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+static inline unsigned int dst_hash(char *str, unsigned int size)
+{
+	return (jhash(str, size, 0) % dst_hashtable_size);
+}
+
+static void dst_node_remove(struct dst_node *n)
+{
+	mutex_lock(&dst_hash_lock);
+	list_del_init(&n->node_entry);
+	mutex_unlock(&dst_hash_lock);
+}
+
+static void dst_node_add(struct dst_node *n)
+{
+	unsigned hash = dst_hash(n->name, sizeof(n->name));
+
+	mutex_lock(&dst_hash_lock);
+	list_add_tail(&n->node_entry, &dst_hashtable[hash]);
+	mutex_unlock(&dst_hash_lock);
+}
+
+static void dst_node_cleanup(struct dst_node *n)
+{
+	struct dst_state *st = n->state;
+
+	if (!st)
+		return;
+
+	if (n->queue) {
+		blk_cleanup_queue(n->queue);
+		put_disk(n->disk);
+	}
+
+	if (n->bdev) {
+		sync_blockdev(n->bdev);
+		blkdev_put(n->bdev);
+	}
+
+	dst_state_lock(st);
+	st->need_exit = 1;
+	dst_state_exit_connected(st);
+	dst_state_unlock(st);
+
+	wake_up(&st->thread_wait);
+
+	dst_state_put(st);
+	n->state = NULL;
+}
+
+static void dst_security_exit(struct dst_node *n)
+{
+	struct dst_secure *s, *tmp;
+
+	list_for_each_entry_safe(s, tmp, &n->security_list, sec_entry) {
+		list_del(&s->sec_entry);
+		kfree(s);
+	}
+}
+
+void dst_node_put(struct dst_node *n)
+{
+	if (unlikely(!n))
+		return;
+
+	dprintk("%s: n: %p, refcnt: %d.\n",
+			__func__, n, atomic_read(&n->refcnt));
+
+	if (atomic_dec_and_test(&n->refcnt)) {
+		dst_node_remove(n);
+		n->trans_scan_timeout = 0;
+		dst_node_cleanup(n);
+		thread_pool_destroy(n->pool);
+		dst_node_sysfs_exit(n);
+		dst_node_crypto_exit(n);
+		dst_security_exit(n);
+		dst_node_trans_exit(n);
+
+		kfree(n);
+
+		dprintk("%s: freed n: %p.\n", __func__, n);
+	}
+}
+
+/*
+ * This function finds devices major/minor numbers for given pathname.
+ */
+static int dst_lookup_device(const char *path, dev_t *dev)
+{
+	int err;
+	struct nameidata nd;
+	struct inode *inode;
+
+	err = path_lookup(path, LOOKUP_FOLLOW, &nd);
+	if (err)
+		return err;
+
+	inode = nd.path.dentry->d_inode;
+	if (!inode) {
+		err = -ENOENT;
+		goto out;
+	}
+
+	if (!S_ISBLK(inode->i_mode)) {
+		err = -ENOTBLK;
+		goto out;
+	}
+
+	*dev = inode->i_rdev;
+
+out:
+	path_put(&nd.path);
+	return err;
+}
+
+static int dst_setup_export(struct dst_node *n, struct dst_ctl *ctl,
+		struct dst_export_ctl *le)
+{
+	int err;
+	dev_t dev;
+
+	err = dst_lookup_device(le->device, &dev);
+	if (err)
+		return err;
+
+	n->bdev = open_by_devnum(dev, FMODE_READ|FMODE_WRITE);
+	if (!n->bdev)
+		return -ENODEV;
+
+	if (n->size != 0)
+		n->size = min_t(loff_t, n->bdev->bd_inode->i_size, n->size);
+	else
+		n->size = n->bdev->bd_inode->i_size;
+
+	err = dst_node_init_listened(n, le);
+	if (err)
+		goto err_out_cleanup;
+
+	return 0;
+
+err_out_cleanup:
+	sync_blockdev(n->bdev);
+	blkdev_put(n->bdev);
+	n->bdev = NULL;
+
+	return err;
+}
+
+static inline void *dst_thread_network_init(void *data)
+{
+	dprintk("%s: data: %p.\n", __func__, data);
+	return data;
+}
+
+static inline void dst_thread_network_cleanup(void *data)
+{
+	dprintk("%s: data: %p.\n", __func__, data);
+}
+
+static struct dst_node *dst_alloc_node(struct dst_ctl *ctl,
+		int (*start)(struct dst_node *),
+		int num)
+{
+	struct dst_node *n;
+	int err;
+
+	n = kzalloc(sizeof(struct dst_node), GFP_KERNEL);
+	if (!n)
+		return NULL;
+
+	INIT_LIST_HEAD(&n->node_entry);
+
+	INIT_LIST_HEAD(&n->security_list);
+	mutex_init(&n->security_lock);
+
+	n->trans_scan_timeout = msecs_to_jiffies(ctl->trans_scan_timeout);
+	if (!n->trans_scan_timeout)
+		n->trans_scan_timeout = HZ;
+
+	n->trans_max_retries = ctl->trans_max_retries;
+	if (!n->trans_max_retries)
+		n->trans_max_retries = 10;
+
+	n->max_pages = ctl->max_pages;
+	if (!n->max_pages)
+		n->max_pages = 30;
+
+	n->start = start;
+	n->size = ctl->size;
+
+	atomic_set(&n->refcnt, 1);
+	atomic_long_set(&n->gen, 0);
+	snprintf(n->name, sizeof(n->name), "%s", ctl->name);
+
+	err = dst_node_sysfs_init(n);
+	if (err)
+		goto err_out_free;
+
+	n->pool = thread_pool_create(num, n->name, dst_thread_network_init,
+			dst_thread_network_cleanup, n);
+	if (IS_ERR(n->pool)) {
+		err = PTR_ERR(n->pool);
+		goto err_out_sysfs_exit;
+	}
+
+	dprintk("%s: n: %p, name: %s.\n", __func__, n, n->name);
+
+	return n;
+
+err_out_sysfs_exit:
+	dst_node_sysfs_exit(n);
+err_out_free:
+	kfree(n);
+	return NULL;
+}
+
+static int dst_start_remote(struct dst_node *n)
+{
+	int err;
+
+	err = dst_node_trans_init(n, sizeof(struct dst_trans));
+	if (err)
+		return err;
+
+	err = dst_node_create_disk(n);
+	if (err)
+		return err;
+
+	dst_node_set_size(n);
+	add_disk(n->disk);
+	return 0;
+}
+
+/*
+ * Control callback for userspace commands to setup
+ * different nodes and start/stop array.
+ */
+static int dst_add_remote(struct dst_node *n, struct dst_ctl *ctl,
+		void *data, unsigned int size)
+{
+	int err;
+	struct dst_network_ctl *rctl = data;
+
+	if (n)
+		return -EEXIST;
+
+	if (size != sizeof(struct dst_network_ctl))
+		return -EINVAL;
+
+	n = dst_alloc_node(ctl, dst_start_remote, 1);
+	if (!n)
+		return -ENOMEM;
+
+	err = dst_node_init_connected(n, rctl);
+	if (err)
+		goto err_out_free;
+
+	dst_node_add(n);
+
+	return 0;
+
+err_out_free:
+	dst_node_put(n);
+	return err;
+}
+
+static int dst_add_export(struct dst_node *n, struct dst_ctl *ctl,
+		void *data, unsigned int size)
+{
+	int err;
+	struct dst_export_ctl *le = data;
+
+	if (n)
+		return -EEXIST;
+
+	if (size != sizeof(struct dst_export_ctl))
+		return -EINVAL;
+
+	n = dst_alloc_node(ctl, dst_start_export, 2);
+	if (!n)
+		return -EINVAL;
+
+	err = dst_setup_export(n, ctl, le);
+	if (err)
+		goto err_out_free;
+
+	dst_node_add(n);
+
+	return 0;
+
+err_out_free:
+	dst_node_put(n);
+	return err;
+}
+
+static int dst_node_remove_unload(struct dst_node *n)
+{
+	printk(KERN_INFO "STOPPED name: '%s', size: %llu.\n",
+			n->name, n->size);
+
+	if (n->disk)
+		del_gendisk(n->disk);
+
+	dst_node_remove(n);
+	dst_node_sysfs_exit(n);
+
+	dst_node_put(n);
+	return 0;
+}
+
+static int dst_del_node(struct dst_node *n, struct dst_ctl *ctl,
+		void *data, unsigned int size)
+{
+	if (!n)
+		return -ENODEV;
+
+	return dst_node_remove_unload(n);
+}
+
+static int dst_crypto_init(struct dst_node *n, struct dst_ctl *ctl,
+		void *data, unsigned int size)
+{
+	struct dst_crypto_ctl *crypto = data;
+
+	if (!n)
+		return -ENODEV;
+
+	if (size != sizeof(struct dst_crypto_ctl) + crypto->hash_keysize +
+			crypto->cipher_keysize)
+		return -EINVAL;
+
+	if (n->trans_cache)
+		return -EEXIST;
+
+	return dst_node_crypto_init(n, crypto);
+}
+
+static int dst_security_init(struct dst_node *n, struct dst_ctl *ctl,
+		void *data, unsigned int size)
+{
+	struct dst_secure *s;
+
+	if (!n)
+		return -ENODEV;
+
+	if (size != sizeof(struct dst_secure_user))
+		return -EINVAL;
+
+	s = kmalloc(sizeof(struct dst_secure), GFP_KERNEL);
+	if (!s)
+		return -ENOMEM;
+
+	memcpy(&s->sec, data, size);
+
+	mutex_lock(&n->security_lock);
+	list_add_tail(&s->sec_entry, &n->security_list);
+	mutex_unlock(&n->security_lock);
+
+	return 0;
+}
+
+static int dst_start_node(struct dst_node *n, struct dst_ctl *ctl,
+		void *data, unsigned int size)
+{
+	int err;
+
+	if (!n)
+		return -ENODEV;
+
+	if (n->trans_cache)
+		return 0;
+
+	err = n->start(n);
+	if (err)
+		return err;
+
+	printk(KERN_INFO "STARTED name: '%s', size: %llu.\n",
+			n->name, n->size);
+	return 0;
+}
+
+
+typedef int (*dst_command_func)(struct dst_node *n, struct dst_ctl *ctl,
+		void *data, unsigned int size);
+
+/*
+ * List of userspace commands.
+ */
+static dst_command_func dst_commands[] = {
+	[DST_ADD_REMOTE] = &dst_add_remote,
+	[DST_ADD_EXPORT] = &dst_add_export,
+	[DST_DEL_NODE] = &dst_del_node,
+	[DST_CRYPTO] = &dst_crypto_init,
+	[DST_SECURITY] = &dst_security_init,
+	[DST_START] = &dst_start_node,
+};
+
+/*
+ * Configuration parser.
+ */
+static void cn_dst_callback(void *data)
+{
+	struct dst_ctl *ctl;
+	struct cn_msg *msg = data;
+	int err;
+	struct dst_ctl_ack ack;
+	struct dst_node *n = NULL, *tmp;
+	unsigned int hash;
+
+
+	if (msg->len < sizeof(struct dst_ctl)) {
+		err = -EBADMSG;
+		goto out;
+	}
+
+	ctl = (struct dst_ctl *)msg->data;
+
+	if (ctl->cmd >= DST_CMD_MAX) {
+		err = -EINVAL;
+		goto out;
+	}
+	hash = dst_hash(ctl->name, sizeof(ctl->name));
+
+	mutex_lock(&dst_hash_lock);
+	list_for_each_entry(tmp, &dst_hashtable[hash], node_entry) {
+		if (!memcmp(tmp->name, ctl->name, sizeof(tmp->name))) {
+			n = tmp;
+			dst_node_get(n);
+			break;
+		}
+	}
+	mutex_unlock(&dst_hash_lock);
+
+	err = dst_commands[ctl->cmd](n, ctl, msg->data + sizeof(struct dst_ctl),
+			msg->len - sizeof(struct dst_ctl));
+
+	dst_node_put(n);
+out:
+	memcpy(&ack.msg, msg, sizeof(struct cn_msg));
+
+	ack.msg.ack = msg->ack + 1;
+	ack.msg.len = sizeof(struct dst_ctl_ack) - sizeof(struct cn_msg);
+
+	ack.error = err;
+
+	cn_netlink_send(&ack.msg, 0, GFP_KERNEL);
+}
+
+static int __init dst_sysfs_init(void)
+{
+	return bus_register(&dst_dev_bus_type);
+}
+
+static void dst_sysfs_exit(void)
+{
+	bus_unregister(&dst_dev_bus_type);
+}
+
+static int __init dst_hashtable_init(void)
+{
+	unsigned int i;
+
+	dst_hashtable = kzalloc(sizeof(struct list_head) * dst_hashtable_size,
+			GFP_KERNEL);
+	if (!dst_hashtable)
+		return -ENOMEM;
+
+	for (i=0; i<dst_hashtable_size; ++i)
+		INIT_LIST_HEAD(&dst_hashtable[i]);
+
+	return 0;
+}
+
+static void dst_hashtable_exit(void)
+{
+	unsigned int i;
+	struct dst_node *n, *tmp;
+
+	for (i=0; i<dst_hashtable_size; ++i) {
+		list_for_each_entry_safe(n, tmp, &dst_hashtable[i], node_entry) {
+			dst_node_remove_unload(n);
+		}
+	}
+
+	kfree(dst_hashtable);
+}
+
+static int __init dst_sys_init(void)
+{
+	int err = -ENOMEM;
+	struct cb_id cn_dst_id = { CN_DST_IDX, CN_DST_VAL };
+
+	err = dst_hashtable_init();
+	if (err)
+		goto err_out_exit;
+
+	err = dst_export_init();
+	if (err)
+		goto err_out_hashtable_exit;
+
+	err = register_blkdev(dst_major, DST_NAME);
+	if (err < 0)
+		goto err_out_export_exit;
+	if (err)
+		dst_major = err;
+
+	err = dst_sysfs_init();
+	if (err)
+		goto err_out_unregister;
+
+	err = cn_add_callback(&cn_dst_id, "DST", cn_dst_callback);
+	if (err)
+		goto err_out_sysfs_exit;
+
+	printk(KERN_INFO "Distributed storage, '%s' release.\n", dst_name);
+
+	return 0;
+
+err_out_sysfs_exit:
+	dst_sysfs_exit();
+err_out_unregister:
+	unregister_blkdev(dst_major, DST_NAME);
+err_out_export_exit:
+	dst_export_exit();
+err_out_hashtable_exit:
+	dst_hashtable_exit();
+err_out_exit:
+	return err;
+}
+
+static void __exit dst_sys_exit(void)
+{
+	struct cb_id cn_dst_id = { CN_DST_IDX, CN_DST_VAL };
+
+	cn_del_callback(&cn_dst_id);
+	unregister_blkdev(dst_major, DST_NAME);
+	dst_hashtable_exit();
+	dst_sysfs_exit();
+	dst_export_exit();
+}
+
+module_init(dst_sys_init);
+module_exit(dst_sys_exit);
+
+MODULE_DESCRIPTION("Distributed storage");
+MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
+MODULE_LICENSE("GPL");
diff --git a/drivers/block/dst/export.c b/drivers/block/dst/export.c
new file mode 100644
index 0000000..700e1ee
--- /dev/null
+++ b/drivers/block/dst/export.c
@@ -0,0 +1,584 @@
+/*
+ * 2007+ Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/blkdev.h>
+#include <linux/bio.h>
+#include <linux/dst.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/poll.h>
+#include <linux/slab.h>
+#include <linux/socket.h>
+
+#include <net/sock.h>
+
+static struct bio_set *dst_bio_set;
+
+int __init dst_export_init(void)
+{
+	int err = -ENOMEM;
+
+	dst_bio_set = bioset_create(32, 32);
+	if (!dst_bio_set)
+		goto err_out_exit;
+
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+void dst_export_exit(void)
+{
+	bioset_free(dst_bio_set);
+}
+
+static unsigned int dst_check_permissions(struct dst_state *main, struct dst_state *st)
+{
+	struct dst_node *n = main->node;
+	struct dst_secure *sentry;
+	struct dst_secure_user *s;
+	struct saddr *sa = &st->ctl.addr;
+	unsigned int perm = 0;
+
+	mutex_lock(&n->security_lock);
+	list_for_each_entry(sentry, &n->security_list, sec_entry) {
+		s = &sentry->sec;
+
+		if (s->addr.sa_family != sa->sa_family)
+			continue;
+
+		if (s->addr.sa_data_len != sa->sa_data_len)
+			continue;
+
+		/*
+		 * This '2' below is a port field. This may be very wrong to do
+		 * in atalk for example though. If there will be any need to extent
+		 * protocol to something else, I can create per-family helpers and
+		 * use them instead of this memcmp.
+		 */
+		if (memcmp(s->addr.sa_data + 2, sa->sa_data + 2,
+					sa->sa_data_len - 2))
+			continue;
+
+		perm = s->permissions;
+	}
+	mutex_unlock(&n->security_lock);
+
+	return perm;
+}
+
+static struct dst_state *dst_accept_client(struct dst_state *st)
+{
+	unsigned int revents = 0;
+	unsigned int err_mask = POLLERR | POLLHUP | POLLRDHUP;
+	unsigned int mask = err_mask | POLLIN;
+	struct dst_node *n = st->node;
+	int err = 0;
+	struct socket *sock = NULL;
+	struct dst_state *new;
+
+	while (!err && !sock) {
+		revents = dst_state_poll(st);
+
+		if (!(revents & mask)) {
+			DEFINE_WAIT(wait);
+
+			for (;;) {
+				prepare_to_wait(&st->thread_wait,
+						&wait, TASK_INTERRUPTIBLE);
+				if (!n->trans_scan_timeout || st->need_exit)
+					break;
+
+				revents = dst_state_poll(st);
+
+				if (revents & mask)
+					break;
+
+				if (signal_pending(current))
+					break;
+
+				schedule_timeout(HZ);
+			}
+			finish_wait(&st->thread_wait, &wait);
+		}
+
+		err = -ECONNRESET;
+		dst_state_lock(st);
+
+		dprintk("%s: st: %p, revents: %x [err: %d, in: %d].\n",
+			__func__, st, revents, revents & err_mask,
+			revents & POLLIN);
+
+		if (revents & err_mask) {
+			printk("%s: revents: %x, socket: %p, err: %d.\n",
+					__func__, revents, st->socket, err);
+			err = -ECONNRESET;
+		}
+
+		if (!n->trans_scan_timeout || st->need_exit)
+			err = -ENODEV;
+
+		if (st->socket && (revents & POLLIN))
+			err = kernel_accept(st->socket, &sock, 0);
+
+		dst_state_unlock(st);
+	}
+
+	if (err)
+		goto err_out_exit;
+
+	new = dst_state_alloc(st->node);
+	if (!new) {
+		err = -ENOMEM;
+		goto err_out_release;
+	}
+	new->socket = sock;
+
+	new->ctl.addr.sa_data_len = sizeof(struct sockaddr);
+	err = kernel_getpeername(sock, (struct sockaddr *)&new->ctl.addr,
+			(int *)&new->ctl.addr.sa_data_len);
+	if (err)
+		goto err_out_put;
+
+	new->permissions = dst_check_permissions(st, new);
+	if (new->permissions == 0) {
+		err = -EPERM;
+		dst_dump_addr(sock, (struct sockaddr *)&new->ctl.addr,
+				"Client is not allowed to connect");
+		goto err_out_put;
+	}
+
+	err = dst_poll_init(new);
+	if (err)
+		goto err_out_put;
+
+	dst_dump_addr(sock, (struct sockaddr *)&new->ctl.addr,
+			"Connected client");
+
+	return new;
+
+err_out_put:
+	dst_state_put(new);
+err_out_release:
+	sock_release(sock);
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+static int dst_export_process_request_queue(struct dst_state *st)
+{
+	unsigned long flags;
+	struct dst_export_priv *p = NULL;
+	struct bio *bio;
+	int err = 0;
+
+	while (!list_empty(&st->request_list)) {
+		spin_lock_irqsave(&st->request_lock, flags);
+		if (!list_empty(&st->request_list)) {
+			p = list_first_entry(&st->request_list,
+				struct dst_export_priv, request_entry);
+			list_del(&p->request_entry);
+		}
+		spin_unlock_irqrestore(&st->request_lock, flags);
+
+		if (!p)
+			break;
+
+		bio = p->bio;
+
+		if (dst_need_crypto(st->node) && (bio_data_dir(bio) == READ))
+			err = dst_export_crypto(st->node, bio);
+		else
+			err = dst_export_send_bio(bio);
+
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+static void dst_state_cleanup_export(struct dst_state *st)
+{
+	struct dst_export_priv *p;
+	unsigned long flags;
+
+	/*
+	 * This loop waits for all pending bios to be completed and freed.
+	 */
+	while (atomic_read(&st->refcnt) > 1) {
+		dprintk("%s: st: %p, refcnt: %d, list_empty: %d.\n",
+				__func__, st, atomic_read(&st->refcnt),
+				list_empty(&st->request_list));
+		wait_event_timeout(st->thread_wait,
+				(atomic_read(&st->refcnt) == 1) ||
+				!list_empty(&st->request_list),
+				HZ/2);
+
+		while (!list_empty(&st->request_list)) {
+			p = NULL;
+			spin_lock_irqsave(&st->request_lock, flags);
+			if (!list_empty(&st->request_list)) {
+				p = list_first_entry(&st->request_list,
+					struct dst_export_priv, request_entry);
+				list_del(&p->request_entry);
+			}
+			spin_unlock_irqrestore(&st->request_lock, flags);
+
+			if (p)
+				bio_put(p->bio);
+			
+			dprintk("%s: st: %p, refcnt: %d, list_empty: %d, p: %p.\n",
+				__func__, st, atomic_read(&st->refcnt),
+				list_empty(&st->request_list), p);
+		}
+	}
+	
+	dst_state_put(st);
+}
+
+static int dst_accept(void *init_data, void *schedule_data)
+{
+	struct dst_state *main = schedule_data;
+	struct dst_node *n = init_data;
+	struct dst_state *st;
+	int err;
+
+	while (n->trans_scan_timeout && !main->need_exit) {
+		dprintk("%s: main: %p, n: %p.\n", __func__, main, n);
+		st = dst_accept_client(main);
+		if (IS_ERR(st))
+			continue;
+
+		err = dst_state_schedule_receiver(st);
+		if (!err) {
+			while (n->trans_scan_timeout) {
+				err = wait_event_interruptible_timeout(st->thread_wait,
+						!list_empty(&st->request_list) ||
+						!n->trans_scan_timeout ||
+						st->need_exit,
+					HZ);
+
+				if (!n->trans_scan_timeout || st->need_exit)
+					break;
+
+				if (list_empty(&st->request_list))
+					continue;
+
+				err = dst_export_process_request_queue(st);
+				if (err)
+					break;
+			}
+
+			st->need_exit = 1;
+			wake_up(&st->thread_wait);
+		}
+
+		dst_state_cleanup_export(st);
+	}
+
+	dprintk("%s: freeing listening socket st: %p.\n", __func__, main);
+	
+	dst_state_lock(main);
+	dst_poll_exit(main);
+	dst_state_socket_release(main);
+	dst_state_unlock(main);
+	dst_state_put(main);
+	dprintk("%s: freed listening socket st: %p.\n", __func__, main);
+
+	return 0;
+}
+
+int dst_start_export(struct dst_node *n)
+{
+	return dst_node_trans_init(n, sizeof(struct dst_export_priv));
+}
+
+int dst_node_init_listened(struct dst_node *n, struct dst_export_ctl *le)
+{
+	struct dst_state *st;
+	int err = -ENOMEM;
+	struct dst_network_ctl *ctl = &le->ctl;
+
+	st = dst_state_alloc(n);
+	if (IS_ERR(st)) {
+		err = PTR_ERR(st);
+		goto err_out_exit;
+	}
+	memcpy(&st->ctl, ctl, sizeof(struct dst_network_ctl));
+
+	err = dst_state_socket_create(st);
+	if (err)
+		goto err_out_put;
+
+	err = kernel_bind(st->socket, (struct sockaddr *)&ctl->addr,
+			ctl->addr.sa_data_len);
+	if (err)
+		goto err_out_socket_release;
+
+	err = kernel_listen(st->socket, 1024);
+	if (err)
+		goto err_out_socket_release;
+	n->state = st;
+
+	err = dst_poll_init(st);
+	if (err)
+		goto err_out_socket_release;
+
+	dst_state_get(st);
+
+	err = thread_pool_schedule(n->pool, dst_thread_setup,
+			dst_accept, st, MAX_SCHEDULE_TIMEOUT);
+	if (err)
+		goto err_out_poll_exit;
+
+	return 0;
+
+err_out_poll_exit:
+	dst_poll_exit(st);
+err_out_socket_release:
+	dst_state_socket_release(st);
+err_out_put:
+	dst_state_put(st);
+err_out_exit:
+	n->state = NULL;
+	return err;
+}
+
+static void dst_bio_destructor(struct bio *bio)
+{
+	struct bio_vec *bv;
+	struct dst_export_priv *priv = bio->bi_private;
+	int i;
+
+	bio_for_each_segment(bv, bio, i) {
+		if (!bv->bv_page)
+			break;
+
+		__free_page(bv->bv_page);
+	}
+
+	if (priv) {
+		struct dst_node *n = priv->state->node;
+
+		dst_state_put(priv->state);
+		mempool_free(priv, n->trans_pool);
+	}
+	bio_free(bio, dst_bio_set);
+}
+
+static void dst_bio_end_io(struct bio *bio, int err)
+{
+	struct dst_export_priv *p = bio->bi_private;
+	struct dst_state *st = p->state;
+	unsigned long flags;
+
+	spin_lock_irqsave(&st->request_lock, flags);
+	list_add_tail(&p->request_entry, &st->request_list);
+	spin_unlock_irqrestore(&st->request_lock, flags);
+
+	wake_up(&st->thread_wait);
+}
+
+static int dst_export_read_request(struct bio *bio, unsigned int total_size)
+{
+	unsigned int size;
+	struct page *page;
+	int err;
+
+	while (total_size) {
+		err = -ENOMEM;
+		page = alloc_page(GFP_KERNEL);
+		if (!page)
+			goto err_out_exit;
+
+		size = min_t(unsigned int, PAGE_SIZE, total_size);
+
+		err = bio_add_page(bio, page, size, 0);
+		dprintk("%s: bio: %llu/%u, size: %u, err: %d.\n",
+				__func__, (u64)bio->bi_sector, bio->bi_size,
+				size, err);
+		if (err <= 0)
+			goto err_out_free_page;
+
+		total_size -= size;
+	}
+
+	return 0;
+
+err_out_free_page:
+	__free_page(page);
+err_out_exit:
+	return err;
+}
+
+static int dst_export_write_request(struct dst_state *st,
+		struct bio *bio, unsigned int total_size)
+{
+	unsigned int size;
+	struct page *page;
+	void *data;
+	int err;
+
+	while (total_size) {
+		err = -ENOMEM;
+		page = alloc_page(GFP_KERNEL);
+		if (!page)
+			goto err_out_exit;
+
+		data = kmap(page);
+		if (!data)
+			goto err_out_free_page;
+
+		size = min_t(unsigned int, PAGE_SIZE, total_size);
+
+		err = dst_data_recv(st, data, size);
+		if (err)
+			goto err_out_unmap_page;
+
+		err = bio_add_page(bio, page, size, 0);
+		if (err <= 0)
+			goto err_out_unmap_page;
+
+		kunmap(page);
+
+		total_size -= size;
+	}
+
+	return 0;
+
+err_out_unmap_page:
+	kunmap(page);
+err_out_free_page:
+	__free_page(page);
+err_out_exit:
+	return err;
+}
+
+int dst_process_io(struct dst_state *st)
+{
+	struct dst_node *n = st->node;
+	struct dst_cmd *cmd = st->data;
+	struct bio *bio;
+	struct dst_export_priv *priv;
+	int err = -ENOMEM;
+
+	if (unlikely(!n->bdev)) {
+		err = -EINVAL;
+		goto err_out_exit;
+	}
+
+	bio = bio_alloc_bioset(GFP_KERNEL,
+			PAGE_ALIGN(cmd->size) >> PAGE_SHIFT,
+			dst_bio_set);
+	if (!bio)
+		goto err_out_exit;
+	bio->bi_private = NULL;
+
+	priv = mempool_alloc(st->node->trans_pool, GFP_KERNEL);
+	if (!priv)
+		goto err_out_free;
+
+	priv->state = dst_state_get(st);
+	priv->bio = bio;
+
+	bio->bi_private = priv;
+	bio->bi_end_io = dst_bio_end_io;
+	bio->bi_destructor = dst_bio_destructor;
+	bio->bi_bdev = n->bdev;
+	bio->bi_flags |= cmd->flags;
+	bio->bi_rw = cmd->rw;
+	bio->bi_size = 0;
+	bio->bi_sector = cmd->sector;
+
+	dst_bio_to_cmd(bio, &priv->cmd, DST_IO_RESPONSE, cmd->id);
+
+	priv->cmd.flags = 0;
+	priv->cmd.size = cmd->size;
+
+	if (bio_data_dir(bio) == WRITE) {
+		err = dst_recv_cdata(st, priv->cmd.hash);
+		if (err)
+			goto err_out_free;
+
+		err = dst_export_write_request(st, bio, cmd->size);
+		if (err)
+			goto err_out_free;
+
+		if (dst_need_crypto(n))
+			return dst_export_crypto(n, bio);
+	} else {
+		err = dst_export_read_request(bio, cmd->size);
+		if (err)
+			goto err_out_free;
+	}
+
+	dprintk("%s: bio: %llu/%u, rw: %lu, dir: %lu.\n",
+			__func__, (u64)bio->bi_sector, bio->bi_size,
+			bio->bi_rw, bio_data_dir(bio));
+
+	generic_make_request(bio);
+
+	return 0;
+
+err_out_free:
+	bio_put(bio);
+err_out_exit:
+	return err;
+}
+
+int dst_export_send_bio(struct bio *bio)
+{
+	struct dst_export_priv *p = bio->bi_private;
+	struct dst_state *st = p->state;
+	struct dst_cmd *cmd = &p->cmd;
+	int err;
+
+	dprintk("%s: id: %llu, bio: %llu/%u, csize: %u, flags: %lu, rw: %lu.\n",
+			__func__, cmd->id, (u64)bio->bi_sector, bio->bi_size,
+			cmd->csize, bio->bi_flags, bio->bi_rw);
+
+	dst_convert_cmd(cmd);
+
+	dst_state_lock(st);
+	if (!st->socket) {
+		err = -ECONNRESET;
+		goto err_out_unlock;
+	}
+
+	if (bio_data_dir(bio) == WRITE) {
+		cmd->size = cmd->csize = 0;
+		err = dst_data_send_header(st->socket, cmd,
+				sizeof(struct dst_cmd), 0);
+		if (err)
+			goto err_out_unlock;
+	} else {
+		err = dst_send_bio(st, cmd, bio);
+		if (err)
+			goto err_out_unlock;
+	}
+
+	dst_state_unlock(st);
+
+	bio_put(bio);
+	return 0;
+
+err_out_unlock:
+	dst_state_unlock(st);
+
+	bio_put(bio);
+	return err;
+}
diff --git a/drivers/block/dst/state.c b/drivers/block/dst/state.c
new file mode 100644
index 0000000..a540550
--- /dev/null
+++ b/drivers/block/dst/state.c
@@ -0,0 +1,755 @@
+/*
+ * 2007+ Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/buffer_head.h>
+#include <linux/blkdev.h>
+#include <linux/bio.h>
+#include <linux/connector.h>
+#include <linux/dst.h>
+#include <linux/device.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/socket.h>
+#include <linux/slab.h>
+
+#include <net/sock.h>
+
+/*
+ * Polling machinery.
+ */
+
+struct dst_poll_helper
+{
+	poll_table 		pt;
+	struct dst_state	*st;
+};
+
+static int dst_queue_wake(wait_queue_t *wait, unsigned mode, int sync, void *key)
+{
+	struct dst_state *st = container_of(wait, struct dst_state, wait);
+
+	wake_up(&st->thread_wait);
+	return 1;
+}
+
+static void dst_queue_func(struct file *file, wait_queue_head_t *whead,
+				 poll_table *pt)
+{
+	struct dst_state *st = container_of(pt, struct dst_poll_helper, pt)->st;
+
+	st->whead = whead;
+	init_waitqueue_func_entry(&st->wait, dst_queue_wake);
+	add_wait_queue(whead, &st->wait);
+}
+
+void dst_poll_exit(struct dst_state *st)
+{
+	if (st->whead) {
+		remove_wait_queue(st->whead, &st->wait);
+		st->whead = NULL;
+	}
+}
+
+int dst_poll_init(struct dst_state *st)
+{
+	struct dst_poll_helper ph;
+
+	ph.st = st;
+	init_poll_funcptr(&ph.pt, &dst_queue_func);
+
+	st->socket->ops->poll(NULL, st->socket, &ph.pt);
+	return 0;
+}
+
+/*
+ * Header receiving function - may block.
+ */
+static int dst_data_recv_header(struct socket *sock,
+		void *data, unsigned int size, int block)
+{
+	struct msghdr msg;
+	struct kvec iov;
+	int err;
+
+	iov.iov_base = data;
+	iov.iov_len = size;
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = (block)?MSG_WAITALL:MSG_DONTWAIT;
+
+	err = kernel_recvmsg(sock, &msg, &iov, 1, iov.iov_len,
+			msg.msg_flags);
+	if (err != size)
+		return -1;
+
+	return 0;
+}
+
+/*
+ * Header sending function - may block.
+ */
+int dst_data_send_header(struct socket *sock,
+		void *data, unsigned int size, int more)
+{
+	struct msghdr msg;
+	struct kvec iov;
+	int err;
+
+	iov.iov_base = data;
+	iov.iov_len = size;
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_WAITALL | (more)?MSG_MORE:0;
+
+	err = kernel_sendmsg(sock, &msg, &iov, 1, iov.iov_len);
+	if (err != size) {
+		dprintk("%s: size: %u, more: %d, err: %d.\n",
+				__func__, size, more, err);
+		return -1;
+	}
+
+	return 0;
+}
+
+static int dst_request_remote_config(struct dst_state *st)
+{
+	struct dst_node *n = st->node;
+	int err = -EINVAL;
+	struct dst_cmd *cmd = st->data;
+
+	memset(cmd, 0, sizeof(struct dst_cmd));
+	cmd->cmd = DST_CFG;
+
+	dst_convert_cmd(cmd);
+
+	err = dst_data_send_header(st->socket, cmd, sizeof(struct dst_cmd), 0);
+	if (err)
+		goto out;
+
+	err = dst_data_recv_header(st->socket, cmd, sizeof(struct dst_cmd), 1);
+	if (err)
+		goto out;
+
+	dst_convert_cmd(cmd);
+
+	if (cmd->cmd != DST_CFG) {
+		err = -EINVAL;
+		printk("%s: checking result: cmd: %d, size reported: %llu.\n",
+			__func__, cmd->cmd, cmd->sector);
+		goto out;
+	}
+
+	if (n->size != 0)
+		n->size = min_t(loff_t, n->size, cmd->sector);
+	else
+		n->size = cmd->sector;
+
+	st->permissions = cmd->rw;
+
+out:
+	dprintk("%s: n: %p, err: %d, size: %llu, permission: %x.\n",
+			__func__, n, err, n->size, st->permissions);
+	return err;
+}
+
+#define DST_DEFAULT_TIMEO	20000
+
+int dst_state_socket_create(struct dst_state *st)
+{
+	int err;
+	struct socket *sock;
+	struct dst_network_ctl *ctl = &st->ctl;
+
+	err = sock_create(ctl->addr.sa_family, ctl->type, ctl->proto, &sock);
+	if (err < 0)
+		return err;
+
+	sock->sk->sk_sndtimeo = sock->sk->sk_rcvtimeo =
+		msecs_to_jiffies(DST_DEFAULT_TIMEO);
+	sock->sk->sk_allocation = GFP_NOIO;
+
+	st->socket = st->read_socket = sock;
+	return 0;
+}
+
+void dst_state_socket_release(struct dst_state *st)
+{
+	dprintk("%s: st: %p, socket: %p, n: %p.\n",
+			__func__, st, st->socket, st->node);
+	if (st->socket) {
+		sock_release(st->socket);
+		st->socket = NULL;
+		st->read_socket = NULL;
+	}
+}
+
+void dst_dump_addr(struct socket *sk, struct sockaddr *sa, char *str)
+{
+	if (sk->ops->family == AF_INET) {
+		struct sockaddr_in *sin = (struct sockaddr_in *)sa;
+		printk(KERN_INFO "%s %u.%u.%u.%u:%d.\n",
+			str, NIPQUAD(sin->sin_addr.s_addr), ntohs(sin->sin_port));
+	} else if (sk->ops->family == AF_INET6) {
+		struct sockaddr_in6 *sin = (struct sockaddr_in6 *)sa;
+		printk(KERN_INFO "%s %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%d",
+			str, NIP6(sin->sin6_addr), ntohs(sin->sin6_port));
+	}
+}
+
+void dst_state_exit_connected(struct dst_state *st)
+{
+	if (st->socket) {
+		dst_poll_exit(st);
+		st->socket->ops->shutdown(st->socket, 2);
+
+		dst_dump_addr(st->socket, (struct sockaddr *)&st->ctl.addr,
+				"Disconnected peer");
+		dst_state_socket_release(st);
+	}
+}
+
+static int dst_state_init_connected(struct dst_state *st)
+{
+	int err;
+	struct dst_network_ctl *ctl = &st->ctl;
+
+	err = dst_state_socket_create(st);
+	if (err)
+		goto err_out_exit;
+
+	err = kernel_connect(st->socket, (struct sockaddr *)&st->ctl.addr,
+			st->ctl.addr.sa_data_len, 0);
+	if (err)
+		goto err_out_release;
+
+	err = dst_poll_init(st);
+	if (err)
+		goto err_out_release;
+
+	dst_dump_addr(st->socket, (struct sockaddr *)&ctl->addr,
+			"Connected to peer");
+
+	return 0;
+
+err_out_release:
+	dst_state_socket_release(st);
+err_out_exit:
+	return err;
+}
+
+static void __inline__ dst_state_reset_nolock(struct dst_state *st)
+{
+	dst_state_exit_connected(st);
+	dst_state_init_connected(st);
+}
+
+static void __inline__ dst_state_reset(struct dst_state *st)
+{
+	dst_state_lock(st);
+	dst_state_reset_nolock(st);
+	dst_state_unlock(st);
+}
+
+/*
+ * Basic network sending/receiving functions.
+ * Blocked mode is used.
+ */
+static int dst_data_recv_raw(struct dst_state *st, void *buf, u64 size)
+{
+	struct msghdr msg;
+	struct kvec iov;
+	int err;
+
+	BUG_ON(!size);
+
+	iov.iov_base = buf;
+	iov.iov_len = size;
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_DONTWAIT;
+
+	err = kernel_recvmsg(st->socket, &msg, &iov, 1, iov.iov_len,
+			msg.msg_flags);
+	if (err <= 0) {
+		printk("%s: failed to recv data: size: %llu, err: %d.\n",
+				__func__, size, err);
+		if (err == 0)
+			err = -ECONNRESET;
+
+		dst_state_exit_connected(st);
+	}
+
+	return err;
+}
+
+int dst_data_recv(struct dst_state *st, void *data, unsigned int size)
+{
+	unsigned int revents = 0;
+	unsigned int err_mask = POLLERR | POLLHUP | POLLRDHUP;
+	unsigned int mask = err_mask | POLLIN;
+	struct dst_node *n = st->node;
+	int err = 0;
+
+	while (size && !err) {
+		revents = dst_state_poll(st);
+
+		if (!(revents & mask)) {
+			DEFINE_WAIT(wait);
+
+			for (;;) {
+				prepare_to_wait(&st->thread_wait, &wait,
+						TASK_INTERRUPTIBLE);
+				if (!n->trans_scan_timeout || st->need_exit)
+					break;
+
+				revents = dst_state_poll(st);
+
+				if (revents & mask)
+					break;
+
+				if (signal_pending(current))
+					break;
+
+				schedule_timeout(HZ);
+				continue;
+			}
+			finish_wait(&st->thread_wait, &wait);
+		}
+
+		err = -ECONNRESET;
+		dst_state_lock(st);
+
+		if (		st->socket &&
+				(st->read_socket == st->socket) &&
+				(revents & POLLIN)) {
+			err = dst_data_recv_raw(st, data, size);
+			if (err > 0) {
+				data += err;
+				size -= err;
+				err = 0;
+			}
+		}
+
+		if (revents & err_mask || !st->socket) {
+			printk("%s: revents: %x, socket: %p, size: %u, err: %d.\n",
+					__func__, revents, st->socket, size, err);
+			err = -ECONNRESET;
+		}
+
+		dst_state_unlock(st);
+
+		if (!n->trans_scan_timeout)
+			err = -ENODEV;
+	}
+
+	return err;
+}
+
+static int dst_process_cfg(struct dst_state *st)
+{
+	struct dst_node *n = st->node;
+	struct dst_cmd *cmd = st->data;
+	int err;
+
+	cmd->sector = n->size;
+	cmd->rw = st->permissions;
+
+	dst_convert_cmd(cmd);
+
+	dst_state_lock(st);
+	err = dst_data_send_header(st->socket, cmd, sizeof(struct dst_cmd), 0);
+	dst_state_unlock(st);
+
+	return err;
+}
+
+static int dst_recv_bio(struct dst_state *st, struct bio *bio, unsigned int total_size)
+{
+	struct bio_vec *bv;
+	int i, err;
+	void *data;
+	unsigned int sz;
+
+	bio_for_each_segment(bv, bio, i) {
+		sz = min(total_size, bv->bv_len);
+
+		dprintk("%s: bio: %llu/%u, total: %u, len: %u, sz: %u, off: %u.\n",
+			__func__, (u64)bio->bi_sector, bio->bi_size, total_size,
+			bv->bv_len, sz, bv->bv_offset);
+
+		data = kmap(bv->bv_page) + bv->bv_offset;
+		err = dst_data_recv(st, data, sz);
+		kunmap(bv->bv_page);
+
+		bv->bv_len = sz;
+
+		if (err)
+			return err;
+
+		total_size -= sz;
+		if (total_size == 0)
+			break;
+	}
+
+	return 0;
+}
+
+static int dst_process_io_response(struct dst_state *st)
+{
+	struct dst_node *n = st->node;
+	struct dst_cmd *cmd = st->data;
+	struct dst_trans *t;
+	int err = 0;
+	struct bio *bio;
+
+	mutex_lock(&n->trans_lock);
+	t = dst_trans_search(n, cmd->id);
+	mutex_unlock(&n->trans_lock);
+
+	if (!t)
+		goto err_out_exit;
+
+	bio = t->bio;
+
+	dprintk("%s: bio: %llu/%u, cmd_size: %u, csize: %u, dir: %lu.\n",
+		__func__, (u64)bio->bi_sector, bio->bi_size, cmd->size,
+		cmd->csize, bio_data_dir(bio));
+
+	if (bio_data_dir(bio) == READ) {
+		if (bio->bi_size != cmd->size - cmd->csize)
+			goto err_out_exit;
+
+		if (dst_need_crypto(n)) {
+			err = dst_recv_cdata(st, t->cmd.hash);
+			if (err)
+				goto err_out_exit;
+		}
+
+		err = dst_recv_bio(st, t->bio, bio->bi_size);
+		if (err)
+			goto err_out_exit;
+
+		if (dst_need_crypto(n))
+			return dst_trans_crypto(t);
+	} else {
+		err = -EBADMSG;
+		if (cmd->size || cmd->csize)
+			goto err_out_exit;
+	}
+
+	dst_trans_remove(t);
+	dst_trans_put(t);
+
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+int dst_recv_cdata(struct dst_state *st, void *cdata)
+{
+	struct dst_cmd *cmd = st->data;
+	struct dst_node *n = st->node;
+	struct dst_crypto_ctl *c = &n->crypto;
+	int err;
+
+	if (cmd->csize != c->crypto_attached_size) {
+		dprintk("%s: cmd: cmd: %u, sector: %llu, size: %u, "
+				"csize: %u != digest size %u.\n",
+				__func__, cmd->cmd, cmd->sector, cmd->size,
+				cmd->csize, c->crypto_attached_size);
+		err = -EINVAL;
+		goto err_out_exit;
+	}
+
+	err = dst_data_recv(st, cdata, cmd->csize);
+	if (err)
+		goto err_out_exit;
+
+	cmd->size -= cmd->csize;
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+static int dst_recv_processing(struct dst_state *st)
+{
+	int err = -EINTR;
+	struct dst_cmd *cmd = st->data;
+
+	/*
+	 * If socket will be reset after this statement, then
+	 * dst_data_recv() will just fail and loop will
+	 * start again, so it can be done without any locks.
+	 *
+	 * st->read_socket is needed to prevents state machine
+	 * breaking between this data reading and subsequent one
+	 * in protocol specific functions during connection reset.
+	 * In case of reset we have to read next command and do
+	 * not expect data for old command to magically appear in
+	 * new connection.
+	 */
+	st->read_socket = st->socket;
+	err = dst_data_recv(st, cmd, sizeof(struct dst_cmd));
+	if (err)
+		goto out_exit;
+
+	dst_convert_cmd(cmd);
+
+	dprintk("%s: cmd: %u, size: %u, csize: %u, id: %llu, "
+			"sector: %llu, flags: %llx, rw: %llx.\n",
+			__func__, cmd->cmd, cmd->size,
+			cmd->csize, cmd->id, cmd->sector,
+			cmd->flags, cmd->rw);
+
+	/*
+	 * This should catch protocol breakage and random garbage instead of commands.
+	 */
+	if (unlikely(cmd->csize > st->size - sizeof(struct dst_cmd))) {
+		err = -EBADMSG;
+		goto out_exit;
+	}
+
+	err = -EPROTO;
+	switch (cmd->cmd) {
+		case DST_IO_RESPONSE:
+			err = dst_process_io_response(st);
+			break;
+		case DST_IO:
+			err = dst_process_io(st);
+			break;
+		case DST_CFG:
+			err = dst_process_cfg(st);
+			break;
+		default:
+			break;
+	}
+
+out_exit:
+	return err;
+}
+
+static int dst_recv(void *init_data, void *schedule_data)
+{
+	struct dst_state *st = schedule_data;
+	struct dst_node *n = init_data;
+	int err = 0;
+
+	dprintk("%s: start st: %p, n: %p, scan: %lu, need_exit: %d.\n",
+			__func__, st, n, n->trans_scan_timeout, st->need_exit);
+
+	while (n->trans_scan_timeout && !st->need_exit) {
+		err = dst_recv_processing(st);
+		if (err < 0) {
+			if (!st->ctl.type)
+				break;
+
+			if (!n->trans_scan_timeout || st->need_exit)
+				break;
+
+			dst_state_reset(st);
+			msleep(1000);
+		}
+	}
+
+	st->need_exit = 1;
+	wake_up(&st->thread_wait);
+
+	dprintk("%s: freeing receiving socket st: %p.\n", __func__, st);
+	dst_state_exit_connected(st);
+	dst_state_put(st);
+
+	dprintk("%s: freed receiving socket st: %p.\n", __func__, st);
+
+	return err;
+}
+
+static void dst_state_free(struct dst_state *st)
+{
+	dprintk("%s: st: %p.\n", __func__, st);
+	if (st->cleanup)
+		st->cleanup(st);
+	kfree(st->data);
+	kfree(st);
+}
+
+struct dst_state *dst_state_alloc(struct dst_node *n)
+{
+	struct dst_state *st;
+	int err = -ENOMEM;
+
+	st = kzalloc(sizeof(struct dst_state), GFP_KERNEL);
+	if (!st)
+		goto err_out_exit;
+
+	st->node = n;
+	st->need_exit = 0;
+
+	st->size = PAGE_SIZE;
+	st->data = kmalloc(st->size, GFP_KERNEL);
+	if (!st->data)
+		goto err_out_free;
+
+	spin_lock_init(&st->request_lock);
+	INIT_LIST_HEAD(&st->request_list);
+
+	mutex_init(&st->state_lock);
+	init_waitqueue_head(&st->thread_wait);
+
+	/*
+	 * One for processing thread, another one for node itself.
+	 */
+	atomic_set(&st->refcnt, 2);
+
+	dprintk("%s: st: %p, n: %p.\n", __func__, st, st->node);
+
+	return st;
+
+err_out_free:
+	kfree(st);
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+int dst_state_schedule_receiver(struct dst_state *st)
+{
+	return thread_pool_schedule_private(st->node->pool, dst_thread_setup,
+			dst_recv, st, MAX_SCHEDULE_TIMEOUT, st->node);
+}
+
+int dst_node_init_connected(struct dst_node *n, struct dst_network_ctl *r)
+{
+	struct dst_state *st;
+	int err = -ENOMEM;
+
+	st = dst_state_alloc(n);
+	if (IS_ERR(st)) {
+		err = PTR_ERR(st);
+		goto err_out_exit;
+	}
+	memcpy(&st->ctl, r, sizeof(struct dst_network_ctl));
+
+	err = dst_state_init_connected(st);
+	if (err)
+		goto err_out_free_data;
+
+	err = dst_request_remote_config(st);
+	if (err)
+		goto err_out_exit_connected;
+	n->state = st;
+
+	err = dst_state_schedule_receiver(st);
+	if (err)
+		goto err_out_exit_connected;
+
+	return 0;
+
+err_out_exit_connected:
+	dst_state_exit_connected(st);
+err_out_free_data:
+	dst_state_free(st);
+err_out_exit:
+	n->state = NULL;
+	return err;
+}
+
+void dst_state_put(struct dst_state *st)
+{
+	dprintk("%s: st: %p, refcnt: %d.\n",
+			__func__, st, atomic_read(&st->refcnt));
+	if (atomic_dec_and_test(&st->refcnt))
+		dst_state_free(st);
+}
+
+int dst_send_bio(struct dst_state *st, struct dst_cmd *cmd, struct bio *bio)
+{
+	struct bio_vec *bv;
+	struct dst_crypto_ctl *c = &st->node->crypto;
+	int err, i = 0;
+	int flags = MSG_WAITALL;
+
+	err = dst_data_send_header(st->socket, cmd,
+		sizeof(struct dst_cmd) + c->crypto_attached_size, bio->bi_vcnt);
+	if (err)
+		goto err_out_exit;
+
+	bio_for_each_segment(bv, bio, i) {
+		if (i < bio->bi_vcnt - 1)
+			flags |= MSG_MORE;
+
+		err = kernel_sendpage(st->socket, bv->bv_page, bv->bv_offset,
+				bv->bv_len, flags);
+		if (err <= 0)
+			goto err_out_exit;
+	}
+
+	return 0;
+
+err_out_exit:
+	dprintk("%s: %d/%d, flags: %x, err: %d.\n",
+			__func__, i, bio->bi_vcnt, flags, err);
+	return err;
+}
+
+int dst_trans_send(struct dst_trans *t)
+{
+	int err;
+	struct dst_state *st = t->n->state;
+	struct bio *bio = t->bio;
+
+	dst_convert_cmd(&t->cmd);
+	
+	dst_state_lock(st);
+	if (!st->socket) {
+		err = dst_state_init_connected(st);
+		if (err)
+			goto err_out_unlock;
+	}
+
+	if (bio_data_dir(bio) == WRITE) {
+		err = dst_send_bio(st, &t->cmd, t->bio);
+	} else {
+		err = dst_data_send_header(st->socket, &t->cmd,
+				sizeof(struct dst_cmd), 0);
+	}
+	if (err)
+		goto err_out_reset;
+
+	dst_state_unlock(st);
+	return 0;
+	
+err_out_reset:
+	dst_state_reset_nolock(st);
+err_out_unlock:
+	dst_state_unlock(st);
+
+	return err;
+}
diff --git a/drivers/block/dst/thread_pool.c b/drivers/block/dst/thread_pool.c
new file mode 100644
index 0000000..e3c5d25
--- /dev/null
+++ b/drivers/block/dst/thread_pool.c
@@ -0,0 +1,306 @@
+/*
+ * 2007+ Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/dst.h>
+#include <linux/kthread.h>
+#include <linux/slab.h>
+
+struct thread_pool_worker
+{
+	struct list_head	worker_entry;
+
+	struct task_struct	*thread;
+
+	struct thread_pool	*pool;
+
+	int			error;
+	int			has_data;
+	int			need_exit;
+	unsigned int		id;
+	
+	wait_queue_head_t	wait;
+
+	void			*private;
+	void			*schedule_data;
+
+	int			(* action)(void *private, void *schedule_data);
+	void			(* cleanup)(void *private);
+};
+
+static void thread_pool_exit_worker(struct thread_pool_worker *w)
+{
+	dprintk("%s: 1 w: %p, need_exit: %d.\n", __func__, w, w->need_exit);
+	kthread_stop(w->thread);
+	dprintk("%s: 2 w: %p, need_exit: %d.\n", __func__, w, w->need_exit);
+
+	w->cleanup(w->private);
+	kfree(w);
+}
+
+static void thread_pool_worker_make_ready(struct thread_pool_worker *w)
+{
+	struct thread_pool *p = w->pool;
+
+	dprintk("%s: w: %p, need_exit: %d.\n", __func__, w, w->need_exit);
+
+	mutex_lock(&p->thread_lock);
+
+	if (!w->need_exit) {
+		list_move_tail(&w->worker_entry, &p->ready_list);
+		w->has_data = 0;
+		mutex_unlock(&p->thread_lock);
+
+		wake_up(&p->wait);
+	} else {
+		p->thread_num--;
+		list_del(&w->worker_entry);
+		mutex_unlock(&p->thread_lock);
+
+		thread_pool_exit_worker(w);
+	}
+	
+	dprintk("%s: w: %p.\n", __func__, w);
+}
+
+static int thread_pool_worker_func(void *data)
+{
+	struct thread_pool_worker *w = data;
+
+	while (!kthread_should_stop()) {
+		wait_event_interruptible(w->wait,
+			kthread_should_stop() || w->has_data);
+
+		if (kthread_should_stop())
+			break;
+
+		if (!w->has_data)
+			continue;
+
+		w->action(w->private, w->schedule_data);
+		thread_pool_worker_make_ready(w);
+	}
+
+	return 0;
+}
+
+void thread_pool_del_worker(struct thread_pool *p)
+{
+	struct thread_pool_worker *w = NULL;
+
+	while (!w) {
+		wait_event(p->wait, !list_empty(&p->ready_list) || !p->thread_num);
+
+		dprintk("%s: locking list_empty: %d, thread_num: %d.\n",
+				__func__, list_empty(&p->ready_list), p->thread_num);
+
+		mutex_lock(&p->thread_lock);
+		if (!list_empty(&p->ready_list)) {
+			w = list_first_entry(&p->ready_list,
+					struct thread_pool_worker,
+					worker_entry);
+
+			dprintk("%s: deleting w: %p, thread_num: %d, list: %p [%p.%p].\n",
+					__func__, w, p->thread_num, &p->ready_list,
+					p->ready_list.prev, p->ready_list.next);
+
+			p->thread_num--;
+			list_del(&w->worker_entry);
+		}
+		mutex_unlock(&p->thread_lock);
+	}
+
+	if (w)
+		thread_pool_exit_worker(w);
+	dprintk("%s: deleted w: %p, thread_num: %d.\n",
+			__func__, w, p->thread_num);
+}
+
+void thread_pool_del_worker_id(struct thread_pool *p, unsigned int id)
+{
+	struct thread_pool_worker *w;
+	int found = 0;
+
+	mutex_lock(&p->thread_lock);
+	list_for_each_entry(w, &p->ready_list, worker_entry) {
+		if (w->id == id) {
+			found = 1;
+			p->thread_num--;
+			list_del(&w->worker_entry);
+			break;
+		}
+	}
+
+	if (!found) {
+		list_for_each_entry(w, &p->active_list, worker_entry) {
+			if (w->id == id) {
+				w->need_exit = 1;
+				break;
+			}
+		}
+	}
+	mutex_unlock(&p->thread_lock);
+	
+	if (found)
+		thread_pool_exit_worker(w);
+}
+
+int thread_pool_add_worker(struct thread_pool *p,
+		char *name,
+		unsigned int id,
+		void *(* init)(void *private),
+		void (* cleanup)(void *private),
+		void *private)
+{
+	struct thread_pool_worker *w;
+	int err = -ENOMEM;
+
+	w = kzalloc(sizeof(struct thread_pool_worker), GFP_KERNEL);
+	if (!w)
+		goto err_out_exit;
+
+	w->pool = p;
+	init_waitqueue_head(&w->wait);
+	w->cleanup = cleanup;
+	w->id = id;
+
+	w->thread = kthread_run(thread_pool_worker_func, w, "%s", name);
+	if (IS_ERR(w->thread)) {
+		err = PTR_ERR(w->thread);
+		goto err_out_free;
+	}
+
+	w->private = init(private);
+	if (IS_ERR(w->private)) {
+		err = PTR_ERR(w->private);
+		goto err_out_stop_thread;
+	}
+
+	mutex_lock(&p->thread_lock);
+	list_add_tail(&w->worker_entry, &p->ready_list);
+	p->thread_num++;
+	mutex_unlock(&p->thread_lock);
+
+	return 0;
+
+err_out_stop_thread:
+	kthread_stop(w->thread);
+err_out_free:
+	kfree(w);
+err_out_exit:
+	return err;
+}
+
+void thread_pool_destroy(struct thread_pool *p)
+{
+	while (p->thread_num) {
+		dprintk("%s: num: %d.\n", __func__, p->thread_num);
+		thread_pool_del_worker(p);
+	}
+}
+
+struct thread_pool *thread_pool_create(int num, char *name,
+		void *(* init)(void *private),
+		void (* cleanup)(void *private),
+		void *private)
+{
+	struct thread_pool_worker *w, *tmp;
+	struct thread_pool *p;
+	int err = -ENOMEM;
+	int i;
+
+	p = kzalloc(sizeof(struct thread_pool), GFP_KERNEL);
+	if (!p)
+		goto err_out_exit;
+
+	init_waitqueue_head(&p->wait);
+	mutex_init(&p->thread_lock);
+	INIT_LIST_HEAD(&p->ready_list);
+	INIT_LIST_HEAD(&p->active_list);
+	p->thread_num = 0;
+
+	for (i=0; i<num; ++i) {
+		err = thread_pool_add_worker(p, name, i, init,
+				cleanup, private);
+		if (err)
+			goto err_out_free_all;
+	}
+
+	return p;
+
+err_out_free_all:
+	list_for_each_entry_safe(w, tmp, &p->ready_list, worker_entry) {
+		list_del(&w->worker_entry);
+		thread_pool_exit_worker(w);
+	}
+	kfree(p);
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+int thread_pool_schedule_private(struct thread_pool *p,
+		int (* setup)(void *private, void *data),
+		int (* action)(void *private, void *data),
+		void *data, long timeout, void *id)
+{
+	struct thread_pool_worker *w, *tmp, *worker = NULL;
+	int err = 0;
+
+	while (!worker && !err) {
+		timeout = wait_event_interruptible_timeout(p->wait,
+				!list_empty(&p->ready_list),
+				timeout);
+
+		if (!timeout) {
+			err = -ETIMEDOUT;
+			break;
+		}
+
+		worker = NULL;
+		mutex_lock(&p->thread_lock);
+		list_for_each_entry_safe(w, tmp, &p->ready_list, worker_entry) {
+			if (id && id != w->private)
+				continue;
+
+			worker = w;
+
+			list_move_tail(&w->worker_entry, &p->active_list);
+
+			err = setup(w->private, data);
+			if (!err) {
+				w->schedule_data = data;
+				w->action = action;
+				w->has_data = 1;
+				wake_up(&w->wait);
+			} else {
+				list_move_tail(&w->worker_entry, &p->ready_list);
+			}
+
+			break;
+		}
+		mutex_unlock(&p->thread_lock);
+	}
+
+	return err;
+}
+
+int thread_pool_schedule(struct thread_pool *p,
+		int (* setup)(void *private, void *data),
+		int (* action)(void *private, void *data),
+		void *data, long timeout)
+{
+	return thread_pool_schedule_private(p, setup,
+			action, data, timeout, NULL);
+}
diff --git a/drivers/block/dst/trans.c b/drivers/block/dst/trans.c
new file mode 100644
index 0000000..86b8cc9
--- /dev/null
+++ b/drivers/block/dst/trans.c
@@ -0,0 +1,291 @@
+/*
+ * 2007+ Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/bio.h>
+#include <linux/dst.h>
+#include <linux/slab.h>
+#include <linux/mempool.h>
+
+static int dst_mempool_num = 32;
+module_param(dst_mempool_num, int, 0644);
+
+static inline int dst_trans_cmp(dst_gen_t gen, dst_gen_t new)
+{
+	if (gen < new)
+		return 1;
+	if (gen > new)
+		return -1;
+	return 0;
+}
+
+struct dst_trans *dst_trans_search(struct dst_node *node, dst_gen_t gen)
+{
+	struct rb_root *root = &node->trans_root;
+	struct rb_node *n = root->rb_node;
+	struct dst_trans *t, *ret = NULL;
+	int cmp;
+
+	while (n) {
+		t = rb_entry(n, struct dst_trans, trans_entry);
+
+		cmp = dst_trans_cmp(t->gen, gen);
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else {
+			ret = t;
+			break;
+		}
+	}
+
+	dprintk("%s: %s transaction: id: %llu.\n", __func__,
+			(ret)?"found":"not found", gen);
+
+	return ret;
+}
+
+static int dst_trans_insert(struct dst_trans *new)
+{
+	struct rb_root *root = &new->n->trans_root;
+	struct rb_node **n = &root->rb_node, *parent = NULL;
+	struct dst_trans *ret = NULL, *t;
+	int cmp;
+
+	while (*n) {
+		parent = *n;
+
+		t = rb_entry(parent, struct dst_trans, trans_entry);
+
+		cmp = dst_trans_cmp(t->gen, new->gen);
+		if (cmp < 0)
+			n = &parent->rb_left;
+		else if (cmp > 0)
+			n = &parent->rb_right;
+		else {
+			ret = t;
+			break;
+		}
+	}
+
+	new->send_time = jiffies;
+	if (ret) {
+		printk("%s: exist: old: gen: %llu, bio: %llu/%u, send_time: %lu, "
+				"new: gen: %llu, bio: %llu/%u, send_time: %lu.\n",
+			__func__, t->gen, (u64)t->bio->bi_sector,
+			t->bio->bi_size, ret->send_time, new->gen,
+			(u64)new->bio->bi_sector, new->bio->bi_size, new->send_time);
+		return -EEXIST;
+	}
+
+	rb_link_node(&new->trans_entry, parent, n);
+	rb_insert_color(&new->trans_entry, root);
+
+	dprintk("%s: inserted: gen: %llu, bio: %llu/%u, send_time: %lu.\n",
+		__func__, new->gen, (u64)new->bio->bi_sector,
+		new->bio->bi_size, new->send_time);
+
+	return 0;
+}
+
+int dst_trans_remove_nolock(struct dst_trans *t)
+{
+	struct dst_node *n = t->n;
+
+	rb_erase(&t->trans_entry, &n->trans_root);
+	return 0;
+}
+
+int dst_trans_remove(struct dst_trans *t)
+{
+	int ret;
+	struct dst_node *n = t->n;
+
+	mutex_lock(&n->trans_lock);
+	ret = dst_trans_remove_nolock(t);
+	mutex_unlock(&n->trans_lock);
+
+	return ret;
+}
+
+void dst_trans_put(struct dst_trans *t)
+{
+	if (atomic_dec_and_test(&t->refcnt)) {
+		struct bio *bio = t->bio;
+
+		dprintk("%s: completed t: %p, gen: %llu, bio: %p.\n",
+				__func__, t, t->gen, bio);
+
+		bio_endio(bio, t->error);
+		bio_put(bio);
+
+		dst_node_put(t->n);
+		mempool_free(t, t->n->trans_pool);
+	}
+}
+
+int dst_process_bio(struct dst_node *n, struct bio *bio)
+{
+	struct dst_trans *t;
+	int err = -ENOMEM;
+
+	t = mempool_alloc(n->trans_pool, GFP_NOFS);
+	if (!t)
+		goto err_out_exit;
+
+	t->n = dst_node_get(n);
+	t->bio = bio;
+	t->error = 0;
+	t->retries = 0;
+	atomic_set(&t->refcnt, 1);
+	t->gen = atomic_long_inc_return(&n->gen);
+
+	t->enc = bio_data_dir(bio);
+	dst_bio_to_cmd(bio, &t->cmd, DST_IO, t->gen);
+
+	err = dst_trans_insert(t);
+	if (err)
+		goto err_out_free;
+
+	dprintk("%s: gen: %llu, bio: %llu/%u, dir/enc: %d, need_crypto: %d.\n",
+			__func__, t->gen, (u64)bio->bi_sector,
+			bio->bi_size, t->enc, dst_need_crypto(n));
+
+	if (dst_need_crypto(n) && t->enc)
+		dst_trans_crypto(t);
+	else
+		dst_trans_send(t);
+
+	return 0;
+
+err_out_free:
+	dst_node_put(n);
+	mempool_free(t, n->trans_pool);
+err_out_exit:
+	bio_endio(bio, err);
+	bio_put(bio);
+	return err;
+}
+
+static void dst_trans_scan(struct work_struct *work)
+{
+	struct dst_node *n = container_of(work, struct dst_node, trans_work.work);
+	struct rb_node *rb_node;
+	struct dst_trans *t;
+	unsigned long timeout = n->trans_scan_timeout;
+	int num = 10 * n->trans_max_retries;
+	
+	mutex_lock(&n->trans_lock);
+
+	for (rb_node = rb_first(&n->trans_root); rb_node; ) {
+		t = rb_entry(rb_node, struct dst_trans, trans_entry);
+
+		if (timeout && time_after(t->send_time + timeout, jiffies)
+				&& t->retries == 0)
+			break;
+#if 0
+		dprintk("%s: t: %p, gen: %llu, n: %s, retries: %u, max: %u.\n",
+			__func__, t, t->gen, n->name,
+			t->retries, n->trans_max_retries);
+#endif
+		if (--num == 0)
+			break;
+
+		dst_trans_get(t);
+
+		rb_node = rb_next(rb_node);
+
+		if (timeout && (++t->retries < n->trans_max_retries)) {
+			dst_trans_send(t);
+		} else {
+			t->error = -ETIMEDOUT;
+			dst_trans_remove_nolock(t);
+			dst_trans_put(t);
+		}
+
+		dst_trans_put(t);
+	}
+
+	mutex_unlock(&n->trans_lock);
+
+	/*
+	 * If no timeout specified then system is in the middle of exiting process,
+	 * so no need to reschedule scanning process again.
+	 */
+	if (timeout) {
+		if (!num)
+			timeout = HZ;
+		schedule_delayed_work(&n->trans_work, timeout);
+	}
+}
+
+void dst_node_trans_exit(struct dst_node *n)
+{
+	struct dst_trans *t;
+	struct rb_node *rb_node;
+
+	if (!n->trans_cache)
+		return;
+
+	dprintk("%s: n: %p, cancelling the work.\n", __func__, n);
+	cancel_delayed_work_sync(&n->trans_work);
+	flush_scheduled_work();
+	dprintk("%s: n: %p, work has been cancelled.\n", __func__, n);
+
+	for (rb_node = rb_first(&n->trans_root); rb_node; ) {
+		t = rb_entry(rb_node, struct dst_trans, trans_entry);
+
+		dprintk("%s: t: %p, gen: %llu, n: %s.\n",
+			__func__, t, t->gen, n->name);
+
+		rb_node = rb_next(rb_node);
+
+		t->error = -ETIMEDOUT;
+		dst_trans_remove_nolock(t);
+		dst_trans_put(t);
+	}
+
+	mempool_destroy(n->trans_pool);
+	kmem_cache_destroy(n->trans_cache);
+}
+
+int dst_node_trans_init(struct dst_node *n, unsigned int size)
+{
+	n->trans_cache = kmem_cache_create(n->name,
+			size + n->crypto.crypto_attached_size,
+			0, 0, NULL);
+	if (!n->trans_cache)
+		goto err_out_exit;
+
+	n->trans_pool = mempool_create_slab_pool(dst_mempool_num, n->trans_cache);
+	if (!n->trans_pool)
+		goto err_out_cache_destroy;
+
+	mutex_init(&n->trans_lock);
+	n->trans_root = RB_ROOT;
+
+	INIT_DELAYED_WORK(&n->trans_work, dst_trans_scan);
+	schedule_delayed_work(&n->trans_work, n->trans_scan_timeout);
+
+	dprintk("%s: n: %p, size: %u, crypto: %u.\n",
+		__func__, n, size, n->crypto.crypto_attached_size);
+
+	return 0;
+
+err_out_cache_destroy:
+	kmem_cache_destroy(n->trans_cache);
+err_out_exit:
+	return -ENOMEM;
+}
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 96a89d3..cfc5ce7 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -38,8 +38,10 @@
 #define CN_W1_VAL			0x1
 #define CN_IDX_V86D			0x4
 #define CN_VAL_V86D_UVESAFB		0x1
+#define CN_DST_IDX			0x5
+#define CN_DST_VAL			0x1
 
-#define CN_NETLINK_USERS		5
+#define CN_NETLINK_USERS		6
 
 /*
  * Maximum connector's message size.
diff --git a/include/linux/dst.h b/include/linux/dst.h
new file mode 100644
index 0000000..3562c28
--- /dev/null
+++ b/include/linux/dst.h
@@ -0,0 +1,431 @@
+/*
+ * 2007+ Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __DST_H
+#define __DST_H
+
+#include <linux/types.h>
+#include <linux/connector.h>
+
+#define DST_NAMELEN		32
+#define DST_NAME		"dst"
+
+enum {
+	DST_DEL_NODE	= 0,	/* Remove node with given id from storage */
+	DST_ADD_REMOTE,		/* Add remote node with given id to the storage */
+	DST_ADD_EXPORT,		/* Add local node with given id to the storage to be exported and used by remote peers */
+	DST_CRYPTO,		/* Crypto initialization command (hash/cipher used to protect the connection) */
+	DST_SECURITY,		/* Security attributes for given connection (permissions for example) */
+	DST_START,		/* Register given node in the block layer subsystem */
+	DST_CMD_MAX
+};
+
+struct dst_ctl
+{
+	char			name[DST_NAMELEN];
+	__u32			flags;
+	__u32			cmd;
+	__u32			max_pages;
+	__u32			trans_scan_timeout;
+	__u32			trans_max_retries;
+	__u64			size;
+};
+
+struct dst_ctl_ack
+{
+	struct cn_msg		msg;
+	int			error;
+	int			unused[3];
+};
+
+#define SADDR_MAX_DATA	128
+
+struct saddr {
+	unsigned short		sa_family;			/* address family, AF_xxx	*/
+	char			sa_data[SADDR_MAX_DATA];	/* 14 bytes of protocol address	*/
+	unsigned short		sa_data_len;			/* Number of bytes used in sa_data */
+};
+
+struct dst_network_ctl
+{
+	unsigned int		type;
+	unsigned int		proto;
+	struct saddr		addr;
+};
+
+struct dst_crypto_ctl
+{
+	char			cipher_algo[DST_NAMELEN];
+	char			hash_algo[DST_NAMELEN];
+
+	unsigned int		cipher_keysize, hash_keysize;
+	unsigned int		crypto_attached_size;
+	int			thread_num;
+};
+
+#define DST_PERM_READ		(1<<0)
+#define DST_PERM_WRITE		(1<<1)
+
+/*
+ * Right now it is simple model, where each remote address
+ * is assigned to set of permissions it is allowed to perform.
+ * In real world block device does not know anything but
+ * reading and writing, so it should be more than enough.
+ */
+struct dst_secure_user
+{
+	unsigned int		permissions;
+	struct saddr		addr;
+};
+
+struct dst_export_ctl
+{
+	char			device[DST_NAMELEN];
+	struct dst_network_ctl	ctl;
+};
+
+enum {
+	DST_CFG	= 1, 		/* Request remote configuration */
+	DST_IO,			/* IO command */
+	DST_IO_RESPONSE,	/* IO response */
+	DST_NCMD_MAX,
+};
+
+struct dst_cmd
+{
+	__u32			cmd;
+	__u32			size;
+	__u32			csize;
+	__u64			rw;
+	__u64			flags;
+	__u64			id;
+	__u64			sector;
+	__u8			hash[0];
+};
+
+static inline void dst_convert_cmd(struct dst_cmd *c)
+{
+	c->cmd = __cpu_to_be32(c->cmd);
+	c->csize = __cpu_to_be32(c->csize);
+	c->size = __cpu_to_be32(c->size);
+	c->sector = __cpu_to_be64(c->sector);
+	c->id = __cpu_to_be64(c->id);
+	c->flags = __cpu_to_be64(c->flags);
+	c->rw = __cpu_to_be64(c->rw);
+}
+
+typedef __u64 dst_gen_t;
+
+#ifdef __KERNEL__
+
+#include <linux/blkdev.h>
+#include <linux/bio.h>
+#include <linux/device.h>
+#include <linux/mempool.h>
+#include <linux/net.h>
+#include <linux/poll.h>
+#include <linux/rbtree.h>
+
+#ifdef CONFIG_DST_DEBUG
+#define dprintk(f, a...) printk(KERN_NOTICE f, ##a)
+#else
+static inline void __attribute__ ((format (printf, 1, 2)))
+	dprintk(const char *fmt, ...) {}
+#endif
+
+struct dst_node;
+
+struct dst_trans
+{
+	struct dst_node		*n;
+
+	struct rb_node		trans_entry;
+
+	atomic_t		refcnt;
+
+	short			enc;
+	short			retries;
+	int			error;
+
+	long			send_time;
+
+	dst_gen_t		gen;
+
+	struct bio		*bio;
+
+	struct dst_cmd		cmd;
+};
+
+struct dst_crypto_engine
+{
+	struct crypto_hash	*hash;
+	struct crypto_ablkcipher	*cipher;
+
+	int			page_num;
+	struct page		**pages;
+
+	int			enc;
+	struct scatterlist	*src, *dst;
+
+	long			timeout;
+	u64			iv;
+
+	void			*private;
+
+	int			size;
+	void			*data;
+};
+
+struct dst_state
+{
+	struct mutex		state_lock;
+
+	wait_queue_t 		wait;
+	wait_queue_head_t 	*whead;
+	wait_queue_head_t 	thread_wait;
+
+	struct dst_node		*node;
+
+	struct dst_network_ctl	ctl;
+
+	u32			permissions;
+
+	void			(* cleanup)(struct dst_state *st);
+
+	struct list_head	request_list;
+	spinlock_t		request_lock;
+
+	atomic_t		refcnt;
+
+	int			need_exit;
+
+	struct socket		*socket, *read_socket;
+
+	void			*data;
+	unsigned int		size;
+
+	struct dst_cmd		cmd;
+};
+
+struct dst_node
+{
+	struct list_head	node_entry;
+
+	char			name[DST_NAMELEN];
+
+	struct block_device 	*bdev;
+	struct dst_state	*state;
+
+	struct request_queue	*queue;
+	struct gendisk		*disk;
+
+	int			thread_num;
+	int			max_pages;
+
+	loff_t			size;
+
+	struct device		device;
+
+	struct list_head	security_list;
+	struct mutex		security_lock;
+
+	atomic_t		refcnt;
+
+	int 			(*start)(struct dst_node *);
+
+	struct dst_crypto_ctl	crypto;
+	u8			*hash_key;
+	u8			*cipher_key;
+
+	struct thread_pool	*pool;
+
+	atomic_long_t		gen;
+
+	long			trans_scan_timeout;
+	int			trans_max_retries;
+
+	struct rb_root		trans_root;
+	struct mutex		trans_lock;
+
+	struct kmem_cache	*trans_cache;
+	mempool_t		*trans_pool;
+	struct delayed_work 	trans_work;
+};
+
+struct dst_secure
+{
+	struct list_head	sec_entry;
+	struct dst_secure_user	sec;
+};
+
+int dst_process_bio(struct dst_node *n, struct bio *bio);
+
+int dst_node_init_connected(struct dst_node *n, struct dst_network_ctl *r);
+int dst_node_init_listened(struct dst_node *n, struct dst_export_ctl *le);
+
+static inline struct dst_state *dst_state_get(struct dst_state *st)
+{
+	BUG_ON(atomic_read(&st->refcnt) == 0);
+	atomic_inc(&st->refcnt);
+	return st;
+}
+
+void dst_state_put(struct dst_state *st);
+
+struct dst_state *dst_state_alloc(struct dst_node *n);
+int dst_state_socket_create(struct dst_state *st);
+void dst_state_socket_release(struct dst_state *st);
+
+void dst_state_exit_connected(struct dst_state *st);
+
+int dst_state_schedule_receiver(struct dst_state *st);
+
+void dst_dump_addr(struct socket *sk, struct sockaddr *sa, char *str);
+
+static inline void dst_state_lock(struct dst_state *st)
+{
+	mutex_lock(&st->state_lock);
+}
+
+static inline void dst_state_unlock(struct dst_state *st)
+{
+	BUG_ON(!mutex_is_locked(&st->state_lock));
+
+	mutex_unlock(&st->state_lock);
+}
+
+void dst_poll_exit(struct dst_state *st);
+int dst_poll_init(struct dst_state *st);
+
+static inline unsigned int dst_state_poll(struct dst_state *st)
+{
+	unsigned int revents = POLLHUP | POLLERR;
+
+	dst_state_lock(st);
+	if (st->socket)
+		revents = st->socket->ops->poll(NULL, st->socket, NULL);
+	dst_state_unlock(st);
+
+	return revents;
+}
+
+static inline int dst_thread_setup(void *private, void *data)
+{
+	return 0;
+}
+
+void dst_node_put(struct dst_node *n);
+
+static inline struct dst_node *dst_node_get(struct dst_node *n)
+{
+	atomic_inc(&n->refcnt);
+	return n;
+}
+
+int dst_data_recv(struct dst_state *st, void *data, unsigned int size);
+int dst_recv_cdata(struct dst_state *st, void *cdata);
+int dst_data_send_header(struct socket *sock,
+		void *data, unsigned int size, int more);
+
+int dst_send_bio(struct dst_state *st, struct dst_cmd *cmd, struct bio *bio);
+
+int dst_process_io(struct dst_state *st);
+int dst_export_crypto(struct dst_node *n, struct bio *bio);
+int dst_export_send_bio(struct bio *bio);
+int dst_start_export(struct dst_node *n);
+
+int __init dst_export_init(void);
+void dst_export_exit(void);
+
+struct dst_export_priv
+{
+	struct list_head		request_entry;
+	struct dst_state		*state;
+	struct bio			*bio;
+	struct dst_cmd			cmd;
+};
+
+static inline void dst_trans_get(struct dst_trans *t)
+{
+	atomic_inc(&t->refcnt);
+}
+
+struct dst_trans *dst_trans_search(struct dst_node *node, dst_gen_t gen);
+int dst_trans_remove(struct dst_trans *t);
+int dst_trans_remove_nolock(struct dst_trans *t);
+void dst_trans_put(struct dst_trans *t);
+
+static inline void dst_bio_to_cmd(struct bio *bio, struct dst_cmd *cmd,
+		u32 command, u64 id)
+{
+	cmd->cmd = command;
+	cmd->flags = (bio->bi_flags << BIO_POOL_BITS) >> BIO_POOL_BITS;
+	cmd->rw = bio->bi_rw;
+	cmd->size = bio->bi_size;
+	cmd->csize = 0;
+	cmd->id = id;
+	cmd->sector = bio->bi_sector;
+};
+
+int dst_trans_send(struct dst_trans *t);
+int dst_trans_crypto(struct dst_trans *t);
+
+int dst_node_crypto_init(struct dst_node *n, struct dst_crypto_ctl *ctl);
+void dst_node_crypto_exit(struct dst_node *n);
+
+static inline int dst_need_crypto(struct dst_node *n)
+{
+	struct dst_crypto_ctl *c = &n->crypto;
+	return (c->hash_algo[0] || c->cipher_algo[0]);
+}
+
+int dst_node_trans_init(struct dst_node *n, unsigned int size);
+void dst_node_trans_exit(struct dst_node *n);
+
+struct thread_pool
+{
+	int			thread_num;
+	struct mutex		thread_lock;
+	struct list_head	ready_list, active_list;
+
+	wait_queue_head_t	wait;
+};
+
+void thread_pool_del_worker(struct thread_pool *p);
+void thread_pool_del_worker_id(struct thread_pool *p, unsigned int id);
+int thread_pool_add_worker(struct thread_pool *p,
+		char *name,
+		unsigned int id,
+		void *(* init)(void *data),
+		void (* cleanup)(void *data),
+		void *data);
+
+void thread_pool_destroy(struct thread_pool *p);
+struct thread_pool *thread_pool_create(int num, char *name,
+		void *(* init)(void *data),
+		void (* cleanup)(void *data),
+		void *data);
+
+int thread_pool_schedule(struct thread_pool *p,
+		int (* setup)(void *stored_private, void *setup_data),
+		int (* action)(void *stored_private, void *setup_data),
+		void *setup_data, long timeout);
+int thread_pool_schedule_private(struct thread_pool *p,
+		int (* setup)(void *private, void *data),
+		int (* action)(void *private, void *data),
+		void *data, long timeout, void *id);
+
+#endif /* __KERNEL__ */
+#endif /* __DST_H */


-- 
	Evgeniy Polyakov
