From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [3/3] POHMELFS high performance network filesystem. POHMELFS core.
Date: Fri, 25 Jul 2008 23:04:11 +0400
Message-ID: <20080725190411.GD30685@2ka.mipt.ru>
References: <20080725190134.GA30685@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:56877 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755015AbYGYTFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 15:05:06 -0400
Content-Disposition: inline
In-Reply-To: <20080725190134.GA30685@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Core POHMELFS functionality.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/fs/Kconfig b/fs/Kconfig
index c509123..59935cd 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1566,6 +1566,8 @@ menuconfig NETWORK_FILESYSTEMS
 
 if NETWORK_FILESYSTEMS
 
+source "fs/pohmelfs/Kconfig"
+
 config NFS_FS
 	tristate "NFS file system support"
 	depends on INET
diff --git a/fs/Makefile b/fs/Makefile
index 1e7a11b..6ce6a35 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -119,3 +119,4 @@ obj-$(CONFIG_HPPFS)		+= hppfs/
 obj-$(CONFIG_DEBUG_FS)		+= debugfs/
 obj-$(CONFIG_OCFS2_FS)		+= ocfs2/
 obj-$(CONFIG_GFS2_FS)           += gfs2/
+obj-$(CONFIG_POHMELFS)		+= pohmelfs/
diff --git a/fs/pohmelfs/Kconfig b/fs/pohmelfs/Kconfig
new file mode 100644
index 0000000..61f66b0
--- /dev/null
+++ b/fs/pohmelfs/Kconfig
@@ -0,0 +1,33 @@
+config POHMELFS
+	tristate "POHMELFS filesystem support"
+	select CONNECTOR
+	help
+	  POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.
+	  This is a network filesystem which supports coherent caching of data and metadata
+	  on clients.
+
+config POHMELFS_DEBUG
+	bool "POHMELFS debugging"
+	depends on POHMELFS
+	default n
+	help
+	  Turns on excessive POHMELFS debugging facilities.
+	  You usually do not want to slow things down noticebly and get really lots of kernel
+	  messages in syslog.
+
+config POHMELFS_CC_GROUP
+	bool "POHMELFS cache coherency protocol"
+	depends on POHMELFS
+	default y
+	help
+	  This allows to broadcast data and metadata cache coherency messages between clients.
+	  Usually you want this facility, although without locking you can get different from
+	  POSIX expectation behaviour. For more details check POHMELFS homepage and development
+	  section.
+
+config POHMELFS_CRYPTO
+	bool "POHMELFS crypto support"
+	depends on CONFIG_CRYPTO_BLKCIPHER && CONFIG_CRYPTO_HASH
+	help
+	  This option allows to encrypt and/or protect with strong cryptographic hash all dataflow
+	  between server and clients. Each config group can have own keys.
diff --git a/fs/pohmelfs/Makefile b/fs/pohmelfs/Makefile
new file mode 100644
index 0000000..1d1325b
--- /dev/null
+++ b/fs/pohmelfs/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_POHMELFS)	+= pohmelfs.o
+
+pohmelfs-y := inode.o config.o dir.o net.o path_entry.o trans.o crypto.o
diff --git a/fs/pohmelfs/config.c b/fs/pohmelfs/config.c
new file mode 100644
index 0000000..f96dbc9
--- /dev/null
+++ b/fs/pohmelfs/config.c
@@ -0,0 +1,393 @@
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
+#include <linux/connector.h>
+#include <linux/crypto.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/string.h>
+
+#include "netfs.h"
+
+/*
+ * Global configuration list.
+ * Each client can be asked to get one of them.
+ *
+ * Allows to provide remote server address (ipv4/v6/whatever), port
+ * and so on via kernel connector.
+ */
+
+static struct cb_id pohmelfs_cn_id = {.idx = POHMELFS_CN_IDX, .val = POHMELFS_CN_VAL};
+static LIST_HEAD(pohmelfs_config_list);
+static DEFINE_MUTEX(pohmelfs_config_lock);
+
+static inline int pohmelfs_config_eql(struct pohmelfs_ctl *sc, struct pohmelfs_ctl *ctl)
+{
+	if (sc->idx == ctl->idx && sc->type == ctl->type &&
+			sc->proto == ctl->proto &&
+			sc->addrlen == ctl->addrlen &&
+			!memcmp(&sc->addr, &ctl->addr, ctl->addrlen))
+		return 1;
+
+	return 0;
+}
+
+static struct pohmelfs_config_group *pohmelfs_find_config_group(unsigned int idx)
+{
+	struct pohmelfs_config_group *g, *group = NULL;
+
+	list_for_each_entry(g, &pohmelfs_config_list, group_entry) {
+		if (g->idx == idx) {
+			group = g;
+			break;
+		}
+	}
+
+	return group;
+}
+
+static struct pohmelfs_config_group *pohmelfs_find_create_config_group(unsigned int idx)
+{
+	struct pohmelfs_config_group *g;
+	
+	g = pohmelfs_find_config_group(idx);
+	if (g)
+		return g;
+
+	g = kzalloc(sizeof(struct pohmelfs_config_group), GFP_KERNEL);
+	if (!g)
+		return NULL;
+
+	INIT_LIST_HEAD(&g->config_list);
+	g->idx = idx;
+
+	list_add_tail(&g->group_entry, &pohmelfs_config_list);
+
+	return g;
+}
+
+int pohmelfs_copy_config(struct pohmelfs_sb *psb)
+{
+	struct pohmelfs_config_group *g;
+	struct pohmelfs_config *c, *dst;
+	int err = -ENODEV;
+
+	mutex_lock(&pohmelfs_config_lock);
+
+	g = pohmelfs_find_config_group(psb->idx);
+	if (!g)
+		goto out_unlock;
+
+	/*
+	 * Run over all entries in given config group and try to crate and
+	 * initialize those, which do not exist in superblock list.
+	 * Skip all existing entries.
+	 */
+
+	list_for_each_entry(c, &g->config_list, config_entry) {
+		err = 0;
+		list_for_each_entry(dst, &psb->state_list, config_entry) {
+			if (pohmelfs_config_eql(&dst->state.ctl, &c->state.ctl)) {
+				err = -EEXIST;
+				break;
+			}
+		}
+
+		if (err)
+			continue;
+
+		dst = kzalloc(sizeof(struct pohmelfs_config), GFP_KERNEL);
+		if (!dst) {
+			err = -ENOMEM;
+			break;
+		}
+
+		memcpy(&dst->state.ctl, &c->state.ctl, sizeof(struct pohmelfs_ctl));
+
+		list_add_tail(&dst->config_entry, &psb->state_list);
+
+		err = pohmelfs_state_init_one(psb, dst);
+		if (err) {
+			list_del(&dst->config_entry);
+			kfree(dst);
+		}
+
+		err = 0;
+	}
+
+out_unlock:
+	mutex_unlock(&pohmelfs_config_lock);
+
+	return err;
+}
+
+int pohmelfs_copy_crypto(struct pohmelfs_sb *psb)
+{
+	struct pohmelfs_config_group *g;
+	int err = -ENOENT;
+
+	mutex_lock(&pohmelfs_config_lock);
+	g = pohmelfs_find_config_group(psb->idx);
+	if (g) {
+		psb->hash_string = g->hash_string;
+		psb->hash_strlen = g->hash_strlen;
+		g->hash_string = NULL;
+		g->hash_strlen = 0;
+
+		psb->cipher_string = g->cipher_string;
+		psb->cipher_strlen = g->cipher_strlen;
+		g->cipher_string = NULL;
+		g->cipher_strlen = 0;
+		
+		psb->hash_key = g->hash_key;
+		psb->hash_keysize = g->hash_keysize;
+		g->hash_key = NULL;
+		g->hash_keysize = 0;
+		
+		psb->cipher_key = g->cipher_key;
+		psb->cipher_keysize = g->cipher_keysize;
+		g->cipher_key = NULL;
+		g->cipher_keysize = 0;
+
+		err = 0;
+	}
+	mutex_unlock(&pohmelfs_config_lock);
+
+	return err;
+}
+
+static int pohmelfs_cn_ctl(struct cn_msg *msg)
+{
+	struct pohmelfs_config_group *g;
+	struct pohmelfs_ctl *ctl = (struct pohmelfs_ctl *)msg->data;
+	struct pohmelfs_config *c, *tmp;
+	int err = 0;
+
+	if (msg->len != sizeof(struct pohmelfs_ctl))
+		return -EBADMSG;
+
+	mutex_lock(&pohmelfs_config_lock);
+
+	g = pohmelfs_find_create_config_group(ctl->idx);
+	if (!g) {
+		err = -ENOMEM;
+		goto out_unlock;
+	}
+
+	list_for_each_entry_safe(c, tmp, &g->config_list, config_entry) {
+		struct pohmelfs_ctl *sc = &c->state.ctl;
+
+		if (pohmelfs_config_eql(sc, ctl)) {
+			list_del(&c->config_entry);
+			kfree(c);
+			err = -EEXIST;
+			goto out_unlock;
+		}
+	}
+
+	c = kzalloc(sizeof(struct pohmelfs_config), GFP_KERNEL);
+	if (!c) {
+		err = -ENOMEM;
+		goto out_unlock;
+	}
+
+	err = 0;
+	memcpy(&c->state.ctl, ctl, sizeof(struct pohmelfs_ctl));
+	list_add_tail(&c->config_entry, &g->config_list);
+
+out_unlock:
+	mutex_unlock(&pohmelfs_config_lock);
+
+	return err;
+}
+
+static int pohmelfs_crypto_hash_init(struct pohmelfs_config_group *g, struct pohmelfs_crypto *c)
+{
+	char *algo = (char *)c->data;
+	u8 *key = (u8 *)(algo + c->strlen);
+
+	if (g->hash_string)
+		return -EEXIST;
+
+	g->hash_string = kstrdup(algo, GFP_KERNEL);
+	if (!g->hash_string)
+		return -ENOMEM;
+	g->hash_strlen = c->strlen;
+	g->hash_keysize = c->keysize;
+
+	g->hash_key = kmalloc(c->keysize, GFP_KERNEL);
+	if (!g->hash_key) {
+		kfree(g->hash_string);
+		return -ENOMEM;
+	}
+
+	memcpy(g->hash_key, key, c->keysize);
+
+	return 0;
+}
+
+static int pohmelfs_crypto_cipher_init(struct pohmelfs_config_group *g, struct pohmelfs_crypto *c)
+{
+	char *algo = (char *)c->data;
+	u8 *key = (u8 *)(algo + c->strlen);
+
+	if (g->cipher_string)
+		return -EEXIST;
+
+	g->cipher_string = kstrdup(algo, GFP_KERNEL);
+	if (!g->cipher_string)
+		return -ENOMEM;
+	g->cipher_strlen = c->strlen;
+	g->cipher_keysize = c->keysize;
+
+	g->cipher_key = kmalloc(c->keysize, GFP_KERNEL);
+	if (!g->cipher_key) {
+		kfree(g->cipher_string);
+		return -ENOMEM;
+	}
+
+	memcpy(g->cipher_key, key, c->keysize);
+
+	return 0;
+}
+
+
+static int pohmelfs_cn_crypto(struct cn_msg *msg)
+{
+	struct pohmelfs_crypto *crypto = (struct pohmelfs_crypto *)msg->data;
+	struct pohmelfs_config_group *g;
+	int err = 0;
+
+	dprintk("%s: idx: %u, strlen: %u, type: %u, keysize: %u, algo: %s.\n",
+			__func__, crypto->idx, crypto->strlen, crypto->type,
+			crypto->keysize, (char *)crypto->data);
+
+	mutex_lock(&pohmelfs_config_lock);
+	g = pohmelfs_find_create_config_group(crypto->idx);
+	if (!g) {
+		err = -ENOMEM;
+		goto out_unlock;
+	}
+
+	switch (crypto->type) {
+		case POHMELFS_CRYPTO_HASH:
+			err = pohmelfs_crypto_hash_init(g, crypto);
+			break;
+		case POHMELFS_CRYPTO_CIPHER:
+			err = pohmelfs_crypto_cipher_init(g, crypto);
+			break;
+		default:
+			err = -ENOTSUPP;
+			break;
+	}
+
+out_unlock:
+	mutex_unlock(&pohmelfs_config_lock);
+
+	return err;
+}
+
+static void pohmelfs_cn_callback(void *data)
+{
+	struct cn_msg *msg = data;
+	struct pohmelfs_cn_ack *ack;
+	int err;
+
+	switch (msg->flags) {
+		case POHMELFS_FLAGS_CTL:
+			err = pohmelfs_cn_ctl(msg);
+			break;
+		case POHMELFS_FLAGS_CRYPTO:
+			err = pohmelfs_cn_crypto(msg);
+			break;
+		default:
+			err = -ENOSYS;
+			break;
+	}
+
+	ack = kmalloc(sizeof(struct pohmelfs_cn_ack), GFP_KERNEL);
+	if (!ack)
+		return;
+
+	memcpy(&ack->msg, msg, sizeof(struct cn_msg));
+
+	ack->msg.ack = msg->ack + 1;
+	ack->msg.len = sizeof(struct pohmelfs_cn_ack) - sizeof(struct cn_msg);
+
+	ack->error = err;
+
+	cn_netlink_send(&ack->msg, 0, GFP_KERNEL);
+	kfree(ack);
+}
+
+int pohmelfs_config_check(struct pohmelfs_config *config, int idx)
+{
+	struct pohmelfs_ctl *ctl = &config->state.ctl;
+	struct pohmelfs_config *tmp;
+	int err = -ENOENT;
+	struct pohmelfs_ctl *sc;
+	struct pohmelfs_config_group *g;
+
+	mutex_lock(&pohmelfs_config_lock);
+
+	g = pohmelfs_find_config_group(ctl->idx);
+	if (g) {
+		list_for_each_entry(tmp, &g->config_list, config_entry) {
+			sc = &tmp->state.ctl;
+
+			if (pohmelfs_config_eql(sc, ctl)) {
+				err = 0;
+				break;
+			}
+		}
+	}
+
+	mutex_unlock(&pohmelfs_config_lock);
+
+	return err;
+}
+
+int __init pohmelfs_config_init(void)
+{
+	return cn_add_callback(&pohmelfs_cn_id, "pohmelfs", pohmelfs_cn_callback);
+}
+
+void __exit pohmelfs_config_exit(void)
+{
+	struct pohmelfs_config *c, *tmp;
+	struct pohmelfs_config_group *g, *gtmp;
+
+	cn_del_callback(&pohmelfs_cn_id);
+
+	mutex_lock(&pohmelfs_config_lock);
+	list_for_each_entry_safe(g, gtmp, &pohmelfs_config_list, group_entry) {
+		list_for_each_entry_safe(c, tmp, &g->config_list, config_entry) {
+			list_del(&c->config_entry);
+			kfree(c);
+		}
+
+		list_del(&g->group_entry);
+
+		if (g->hash_string)
+			kfree(g->hash_string);
+
+		if (g->cipher_string)
+			kfree(g->cipher_string);
+
+		kfree(g);
+	}
+	mutex_unlock(&pohmelfs_config_lock);
+}
diff --git a/fs/pohmelfs/crypto.c b/fs/pohmelfs/crypto.c
new file mode 100644
index 0000000..bc5f010
--- /dev/null
+++ b/fs/pohmelfs/crypto.c
@@ -0,0 +1,862 @@
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
+#include <linux/crypto.h>
+#include <linux/highmem.h>
+#include <linux/kthread.h>
+#include <linux/pagemap.h>
+#include <linux/slab.h>
+
+#include "netfs.h"
+
+static struct crypto_hash *pohmelfs_init_hash(struct pohmelfs_sb *psb)
+{
+	int err;
+	struct crypto_hash *hash;
+
+	hash = crypto_alloc_hash(psb->hash_string, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(hash)) {
+		err = PTR_ERR(hash);
+		dprintk("%s: idx: %u: failed to allocate hash '%s', err: %d.\n",
+				__func__, psb->idx, psb->hash_string, err);
+		goto err_out_exit;
+	}
+
+	psb->crypto_attached_size = crypto_hash_digestsize(hash);
+
+	if (!psb->hash_keysize)
+		return hash;
+
+	err = crypto_hash_setkey(hash, psb->hash_key, psb->hash_keysize);
+	if (err) {
+		dprintk("%s: idx: %u: failed to set key for hash '%s', err: %d.\n",
+				__func__, psb->idx, psb->hash_string, err);
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
+static struct crypto_ablkcipher *pohmelfs_init_cipher(struct pohmelfs_sb *psb)
+{
+	int err = -EINVAL;
+	struct crypto_ablkcipher *cipher;
+
+	if (!psb->cipher_keysize)
+		goto err_out_exit;
+
+	cipher = crypto_alloc_ablkcipher(psb->cipher_string, 0, 0);
+	if (IS_ERR(cipher)) {
+		err = PTR_ERR(cipher);
+		dprintk("%s: idx: %u: failed to allocate cipher '%s', err: %d.\n",
+				__func__, psb->idx, psb->cipher_string, err);
+		goto err_out_exit;
+	}
+
+	crypto_ablkcipher_clear_flags(cipher, ~0);
+
+	err = crypto_ablkcipher_setkey(cipher, psb->cipher_key, psb->cipher_keysize);
+	if (err) {
+		dprintk("%s: idx: %u: failed to set key for cipher '%s', err: %d.\n",
+				__func__, psb->idx, psb->cipher_string, err);
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
+int pohmelfs_crypto_engine_init(struct pohmelfs_crypto_engine *e, struct pohmelfs_sb *psb)
+{
+	int err;
+
+	e->page_num = 0;
+
+	e->size = PAGE_SIZE;
+	e->data = kmalloc(e->size, GFP_KERNEL);
+	if (!e->data) {
+		err = -ENOMEM;
+		goto err_out_exit;
+	}
+
+	if (psb->hash_string) {
+		e->hash = pohmelfs_init_hash(psb);
+		if (IS_ERR(e->hash)) {
+			err = PTR_ERR(e->hash);
+			e->hash = NULL;
+			goto err_out_free;
+		}
+	}
+	
+	if (psb->cipher_string) {
+		e->cipher = pohmelfs_init_cipher(psb);
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
+err_out_exit:
+	return err;
+}
+
+void pohmelfs_crypto_engine_exit(struct pohmelfs_crypto_engine *e)
+{
+	if (e->hash)
+		crypto_free_hash(e->hash);
+	if (e->cipher)
+		crypto_free_ablkcipher(e->cipher);
+	kfree(e->data);
+}
+
+static void pohmelfs_crypto_complete(struct crypto_async_request *req, int err)
+{
+	struct pohmelfs_crypto_completion *c = req->data;
+
+	if (err == -EINPROGRESS)
+		return;
+
+	dprintk("%s: req: %p, err: %d.\n", __func__, req, err);
+	c->error = err;
+	complete(&c->complete);
+}
+
+static int pohmelfs_crypto_process(struct ablkcipher_request *req,
+		struct scatterlist *sg_dst, struct scatterlist *sg_src,
+		void *iv, int enc, unsigned long timeout)
+{
+	struct pohmelfs_crypto_completion complete;
+	int err;
+
+	init_completion(&complete.complete);
+	complete.error = -EINPROGRESS;
+
+	ablkcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
+					pohmelfs_crypto_complete, &complete);
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
+			err = wait_for_completion_interruptible_timeout(&complete.complete,
+					timeout);
+			if (!err)
+				err = -ETIMEDOUT;
+			else
+				err = complete.error;
+			break;
+		default:
+			break;
+	}
+
+	return err;
+}
+
+int pohmelfs_crypto_process_input_data(struct pohmelfs_crypto_engine *e, u64 cmd_iv,
+		void *data, struct page *page, unsigned int size)
+{
+	int err;
+	struct scatterlist sg;
+
+	dprintk("%s: eng: %p, iv: %llx, data: %p, page: %p/%lu, size: %u: ",
+		__func__, e, cmd_iv, data, page, (page)?page->index:0, size);
+
+	if (data) {
+		sg_init_one(&sg, data, size);
+	} else {
+		sg_init_table(&sg, 1);
+		sg_set_page(&sg, page, size, 0);
+	}
+
+	if (e->cipher) {
+		struct ablkcipher_request *req = e->data + crypto_hash_digestsize(e->hash);
+		u8 iv[32];
+
+		memset(iv, 0, sizeof(iv));
+		memcpy(iv, &cmd_iv, sizeof(cmd_iv));
+
+		ablkcipher_request_set_tfm(req, e->cipher);
+
+		err = pohmelfs_crypto_process(req, &sg, &sg, iv, 0, e->timeout);
+		if (err)
+			goto err_out_exit;
+	}
+
+	if (e->hash) {
+		struct hash_desc desc;
+		void *dst = e->data + e->size/2;
+
+		desc.tfm = e->hash;
+		desc.flags = 0;
+		
+		err = crypto_hash_init(&desc);
+		if (err)
+			goto err_out_exit;
+
+		err = crypto_hash_update(&desc, &sg, size);
+		if (err)
+			goto err_out_exit;
+		
+		err = crypto_hash_final(&desc, dst);
+		if (err)
+			goto err_out_exit;
+
+		err = !!memcmp(dst, e->data, crypto_hash_digestsize(e->hash));
+
+		if (err) {
+#ifdef CONFIG_POHMELFS_DEBUG
+			unsigned int i;
+			unsigned char *recv = e->data, *calc = dst;
+
+			dprintk("%s: eng: %p, hash: %p, cipher: %p: iv : %llx, hash mismatch (recv/calc): ",
+					__func__, e, e->hash, e->cipher, cmd_iv);
+			for (i=0; i<crypto_hash_digestsize(e->hash); ++i) {
+#if 0
+				dprintk("%02x ", recv[i]);
+				if (recv[i] != calc[i]) {
+					dprintk("| calc byte: %02x.\n", calc[i]);
+					break;
+				}
+#else
+				dprintk("%02x/%02x ", recv[i], calc[i]);
+#endif
+			}
+			dprintk("\n");
+#endif
+			goto err_out_exit;
+		} else {
+			dprintk("%s: eng: %p, hash: %p, cipher: %p: hashes matched.\n",
+					__func__, e, e->hash, e->cipher);
+		}
+	}
+	
+	dprintk("%s: eng: %p, hash: %p, cipher: %p: completed.\n",
+			__func__, e, e->hash, e->cipher);
+
+	return 0;
+
+err_out_exit:
+	dprintk("%s: eng: %p, hash: %p, cipher: %p: err: %d.\n",
+			__func__, e, e->hash, e->cipher, err);
+	return err;
+}
+
+static int pohmelfs_trans_iter(struct netfs_trans *t, struct pohmelfs_crypto_engine *e,
+		int (* iterator) (struct pohmelfs_crypto_engine *e,
+				  struct scatterlist *dst,
+				  struct scatterlist *src))
+{
+	void *data = t->iovec.iov_base + sizeof(struct netfs_cmd) + t->psb->crypto_attached_size;
+	unsigned int size = t->iovec.iov_len - sizeof(struct netfs_cmd) - t->psb->crypto_attached_size;
+	struct netfs_cmd *cmd = data;
+	unsigned int sz, pages = t->attached_pages, i, csize, cmd_cmd, dpage_idx;
+	struct scatterlist sg_src, sg_dst;
+	int err;
+
+	while (size) {
+		cmd = data;
+		cmd_cmd = __be16_to_cpu(cmd->cmd);
+		csize = __be32_to_cpu(cmd->size);
+		cmd->iv = __cpu_to_be64(e->iv);
+
+		if (cmd_cmd == NETFS_READ_PAGES || cmd_cmd == NETFS_READ_PAGE)
+			csize = __be16_to_cpu(cmd->ext);
+
+		sz = csize + __be16_to_cpu(cmd->cpad) + sizeof(struct netfs_cmd);
+		
+		dprintk("%s: size: %u, sz: %u, cmd_size: %u, cmd_cpad: %u.\n",
+				__func__, size, sz, __be32_to_cpu(cmd->size), __be16_to_cpu(cmd->cpad));
+
+		data += sz;
+		size -= sz;
+		
+		sg_init_one(&sg_src, cmd->data, sz - sizeof(struct netfs_cmd));
+		sg_init_one(&sg_dst, cmd->data, sz - sizeof(struct netfs_cmd));
+
+		err = iterator(e, &sg_dst, &sg_src);
+		if (err)
+			return err;
+	}
+	
+	if (!pages)
+		return 0;
+
+	dpage_idx = 0;
+	for (i=0; i<t->page_num; ++i) {
+		struct page *page = t->pages[i];
+		struct page *dpage = e->pages[dpage_idx];
+
+		if (!page)
+			continue;
+
+		sg_init_table(&sg_src, 1);
+		sg_init_table(&sg_dst, 1);
+		sg_set_page(&sg_src, page, page_private(page), 0);
+		sg_set_page(&sg_dst, dpage, page_private(page), 0);
+
+		err = iterator(e, &sg_dst, &sg_src);
+		if (err)
+			return err;
+
+		pages--;
+		if (!pages)
+			break;
+		dpage_idx++;
+	}
+
+	return 0;
+}
+
+static int pohmelfs_encrypt_iterator(struct pohmelfs_crypto_engine *e,
+		struct scatterlist *sg_dst, struct scatterlist *sg_src)
+{
+	struct ablkcipher_request *req = e->data;
+	u8 iv[32];
+
+	memset(iv, 0, sizeof(iv));
+
+	memcpy(iv, &e->iv, sizeof(e->iv));
+
+	return pohmelfs_crypto_process(req, sg_dst, sg_src, iv, 1, e->timeout);
+}
+
+static int pohmelfs_encrypt(struct pohmelfs_crypto_thread *tc)
+{
+	struct netfs_trans *t = tc->trans;
+	struct pohmelfs_crypto_engine *e = &tc->eng;
+	struct ablkcipher_request *req = e->data;
+
+	memset(req, 0, sizeof(struct ablkcipher_request));
+	ablkcipher_request_set_tfm(req, e->cipher);
+
+	e->iv = pohmelfs_gen_iv(t);
+
+	return pohmelfs_trans_iter(t, e, pohmelfs_encrypt_iterator);
+}
+
+static int pohmelfs_hash_iterator(struct pohmelfs_crypto_engine *e,
+		struct scatterlist *sg_dst, struct scatterlist *sg_src)
+{
+	return crypto_hash_update(e->data, sg_src, sg_src->length);
+}
+
+static int pohmelfs_hash(struct pohmelfs_crypto_thread *tc)
+{
+	struct pohmelfs_crypto_engine *e = &tc->eng;
+	struct hash_desc *desc = e->data;
+	unsigned char *dst = tc->trans->iovec.iov_base + sizeof(struct netfs_cmd);
+	int err;
+
+	desc->tfm = e->hash;
+	desc->flags = 0;
+
+	err = crypto_hash_init(desc);
+	if (err)
+		return err;
+
+	err = pohmelfs_trans_iter(tc->trans, e, pohmelfs_hash_iterator);
+	if (err)
+		return err;
+
+	err = crypto_hash_final(desc, dst);
+	if (err)
+		return err;
+
+	{
+		unsigned int i;
+		dprintk("%s: ", __func__);
+		for (i=0; i<tc->psb->crypto_attached_size; ++i)
+			dprintk("%02x ", dst[i]);
+		dprintk("\n");
+	}
+
+	return 0;
+}
+
+static void pohmelfs_crypto_pages_free(struct pohmelfs_crypto_engine *e)
+{
+	unsigned int i;
+
+	for (i=0; i<e->page_num; ++i)
+		__free_page(e->pages[i]);
+	kfree(e->pages);
+}
+
+static int pohmelfs_crypto_pages_alloc(struct pohmelfs_crypto_engine *e, struct pohmelfs_sb *psb)
+{
+	unsigned int i;
+
+	e->pages = kmalloc(psb->trans_max_pages * sizeof(struct page *), GFP_KERNEL);
+	if (!e->pages)
+		return -ENOMEM;
+
+	for (i=0; i<psb->trans_max_pages; ++i) {
+		e->pages[i] = alloc_page(GFP_KERNEL);
+		if (!e->pages[i])
+			break;
+	}
+
+	e->page_num = i;
+	if (!e->page_num)
+		goto err_out_free;
+
+	return 0;
+
+err_out_free:
+	kfree(e->pages);
+	return -ENOMEM;
+}
+
+static void pohmelfs_sys_crypto_exit_one(struct pohmelfs_crypto_thread *t)
+{
+	if (t->thread)
+		kthread_stop(t->thread);
+	pohmelfs_crypto_engine_exit(&t->eng);
+	pohmelfs_crypto_pages_free(&t->eng);
+	kfree(t);
+}
+
+static int pohmelfs_crypto_finish(struct netfs_trans *t, struct pohmelfs_sb *psb, int err)
+{
+	if (likely(!err)) {
+		struct netfs_cmd *cmd = t->iovec.iov_base;
+		netfs_convert_cmd(cmd);
+
+		err = netfs_trans_finish_send(t, psb);
+	}
+	t->result = err;
+	netfs_trans_put(t);
+
+	return err;
+}
+
+void pohmelfs_crypto_thread_make_ready(struct pohmelfs_crypto_thread *th)
+{
+	struct pohmelfs_sb *psb = th->psb;
+
+	th->page = NULL;
+	th->trans = NULL;
+
+	mutex_lock(&psb->crypto_thread_lock);
+	list_move_tail(&th->thread_entry, &psb->crypto_ready_list);
+	mutex_unlock(&psb->crypto_thread_lock);
+	wake_up(&psb->wait);
+}
+
+static int pohmelfs_crypto_thread_trans(struct pohmelfs_crypto_thread *t)
+{
+	struct netfs_trans *trans;
+	int err = 0;
+
+	trans = t->trans;
+	trans->eng = NULL;
+
+	if (t->eng.hash) {
+		err = pohmelfs_hash(t);
+		if (err)
+			goto out_complete;
+	}
+
+	if (t->eng.cipher) {
+		err = pohmelfs_encrypt(t);
+		if (err)
+			goto out_complete;
+		trans->eng = &t->eng;
+	}
+
+out_complete:
+	t->page = NULL;
+	t->trans = NULL;
+
+	if (!trans->eng)
+		pohmelfs_crypto_thread_make_ready(t);
+
+	pohmelfs_crypto_finish(trans, t->psb, err);
+	return err;
+}
+
+static int pohmelfs_crypto_thread_page(struct pohmelfs_crypto_thread *t)
+{
+	struct pohmelfs_crypto_engine *e = &t->eng;
+	struct page *page = t->page;
+	int err;
+
+	WARN_ON(!PageChecked(page));
+
+	err = pohmelfs_crypto_process_input_data(e, e->iv, NULL, page, t->size);
+	if (!err)
+		SetPageUptodate(page);
+	else
+		SetPageError(page);
+	unlock_page(page);
+	page_cache_release(page);
+
+	pohmelfs_crypto_thread_make_ready(t);
+
+	return err;
+}
+
+static int pohmelfs_crypto_thread_func(void *data)
+{
+	struct pohmelfs_crypto_thread *t = data;
+
+	while (!kthread_should_stop()) {
+		wait_event_interruptible(t->wait, kthread_should_stop() ||
+				t->trans || t->page);
+
+		if (kthread_should_stop())
+			break;
+
+		if (!t->trans && !t->page)
+			continue;
+
+		dprintk("%s: thread: %p, trans: %p, page: %p.\n",
+				__func__, t, t->trans, t->page);
+
+		if (t->trans)
+			pohmelfs_crypto_thread_trans(t);
+		else if (t->page)
+			pohmelfs_crypto_thread_page(t);
+	}
+
+	return 0;
+}
+
+static void pohmelfs_sys_crypto_exit(struct pohmelfs_sb *psb)
+{
+	struct pohmelfs_crypto_thread *t, *tmp;
+
+	mutex_lock(&psb->crypto_thread_lock);
+	list_for_each_entry_safe(t, tmp, &psb->crypto_active_list, thread_entry) {
+		list_del(&t->thread_entry);
+
+		pohmelfs_sys_crypto_exit_one(t);
+	}
+
+	list_for_each_entry_safe(t, tmp, &psb->crypto_ready_list, thread_entry) {
+		list_del(&t->thread_entry);
+
+		pohmelfs_sys_crypto_exit_one(t);
+	}
+	mutex_unlock(&psb->crypto_thread_lock);
+}
+
+static int pohmelfs_sys_crypto_init(struct pohmelfs_sb *psb)
+{
+	unsigned int i;
+	struct pohmelfs_crypto_thread *t;
+	struct pohmelfs_config *c;
+	struct netfs_state *st;
+	int err;
+
+	list_for_each_entry(c, &psb->state_list, config_entry) {
+		st = &c->state;
+
+		err = pohmelfs_crypto_engine_init(&st->eng, psb);
+		if (err)
+			goto err_out_exit;
+
+		dprintk("%s: st: %p, eng: %p, hash: %p, cipher: %p.\n",
+				__func__, st, &st->eng, &st->eng.hash, &st->eng.cipher);
+	}
+
+	for (i=0; i<psb->crypto_thread_num; ++i) {
+		err = -ENOMEM;
+		t = kzalloc(sizeof(struct pohmelfs_crypto_thread), GFP_KERNEL);
+		if (!t)
+			goto err_out_free_state_engines;
+
+		init_waitqueue_head(&t->wait);
+
+		t->psb = psb;
+		t->trans = NULL;
+		t->eng.thread = t;
+
+		err = pohmelfs_crypto_engine_init(&t->eng, psb);
+		if (err)
+			goto err_out_free_state_engines;
+
+		err = pohmelfs_crypto_pages_alloc(&t->eng, psb);
+		if (err)
+			goto err_out_free;
+
+		t->thread = kthread_run(pohmelfs_crypto_thread_func, t,
+				"pohmelfs-crypto-%d-%d", psb->idx, i);
+		if (IS_ERR(t->thread)) {
+			err = PTR_ERR(t->thread);
+			t->thread = NULL;
+			goto err_out_free;
+		}
+
+		if (t->eng.cipher)
+			psb->crypto_align_size = crypto_ablkcipher_blocksize(t->eng.cipher);
+
+		mutex_lock(&psb->crypto_thread_lock);
+		list_add_tail(&t->thread_entry, &psb->crypto_ready_list);
+		mutex_unlock(&psb->crypto_thread_lock);
+	}
+	
+	psb->crypto_thread_num = i;
+	return 0;
+
+err_out_free:
+	pohmelfs_sys_crypto_exit_one(t);
+err_out_free_state_engines:
+	list_for_each_entry(c, &psb->state_list, config_entry) {
+		st = &c->state;
+		pohmelfs_crypto_engine_exit(&st->eng);
+	}
+err_out_exit:
+	pohmelfs_sys_crypto_exit(psb);
+	return err;
+}
+
+void pohmelfs_crypto_exit(struct pohmelfs_sb *psb)
+{
+	pohmelfs_sys_crypto_exit(psb);
+
+	kfree(psb->hash_string);
+	kfree(psb->cipher_string);
+}
+
+static int pohmelfs_crypt_init_complete(struct page **pages, unsigned int page_num,
+		void *private, int err)
+{
+	struct pohmelfs_sb *psb = private;
+
+	psb->flags = -err;
+	dprintk("%s: err: %d, flags: %lx.\n", __func__, err, psb->flags);
+
+	wake_up(&psb->wait);
+
+	return err;
+}
+
+static int pohmelfs_crypto_init_handshake(struct pohmelfs_sb *psb)
+{
+	struct netfs_trans *t;
+	struct netfs_capabilities *cap;
+	struct netfs_cmd *cmd;
+	char *str;
+	int err = -ENOMEM, size;
+
+	size = sizeof(struct netfs_capabilities) +
+		psb->cipher_strlen + psb->hash_strlen + 2; /* 0 bytes */
+
+	t = netfs_trans_alloc(psb, size, 0, 0);
+	if (!t)
+		goto err_out_exit;
+
+	t->complete = pohmelfs_crypt_init_complete;
+	t->private = psb;
+
+	cmd = netfs_trans_current(t);
+	cap = (struct netfs_capabilities *)(cmd + 1);
+	str = (char *)(cap + 1);
+
+	cmd->cmd = NETFS_CAPABILITIES;
+	cmd->id = psb->idx;
+	cmd->size = size;
+	cmd->start = 0;
+	cmd->ext = 0;
+	cmd->csize = 0;
+
+	netfs_convert_cmd(cmd);
+	netfs_trans_update(cmd, t, size);
+
+	cap->hash_strlen = psb->hash_strlen;
+	if (cap->hash_strlen) {
+		sprintf(str, "%s", psb->hash_string);
+		str += cap->hash_strlen;
+	}
+
+	cap->cipher_strlen = psb->cipher_strlen;
+	cap->cipher_keysize = psb->cipher_keysize;
+	if (cap->cipher_strlen)
+		sprintf(str, "%s", psb->cipher_string);
+
+	netfs_convert_capabilities(cap);
+
+	psb->flags = ~0;
+	err = netfs_trans_finish(t, psb);
+	if (err)
+		goto err_out_exit;
+
+	err = wait_event_interruptible_timeout(psb->wait, (psb->flags != ~0),
+			psb->wait_on_page_timeout);
+	if (!err)
+		err = -ETIMEDOUT;
+	else
+		err = -psb->flags;
+
+	if (!err)
+		psb->perform_crypto = 1;
+	psb->flags = 0;
+
+	/*
+	 * At this point NETFS_CAPABILITIES response command
+	 * should setup superblock in a way, which is acceptible
+	 * for both client and server, so if server refuses connection,
+	 * it will send error in transaction response.
+	 */
+
+	if (err)
+		goto err_out_exit;
+
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+int pohmelfs_crypto_init(struct pohmelfs_sb *psb)
+{
+	int err;
+
+	if (!psb->cipher_string && !psb->hash_string)
+		return 0;
+
+	err = pohmelfs_crypto_init_handshake(psb);
+	if (err)
+		return err;
+
+	err = pohmelfs_sys_crypto_init(psb);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+static int pohmelfs_crypto_thread_get(struct pohmelfs_sb *psb,
+		int (* action)(struct pohmelfs_crypto_thread *t, void *data), void *data)
+{
+	struct pohmelfs_crypto_thread *t = NULL;
+	int err;
+
+	while (!t) {
+		err = wait_event_interruptible_timeout(psb->wait,
+				!list_empty(&psb->crypto_ready_list),
+				psb->wait_on_page_timeout);
+
+		t = NULL;
+		err = 0;
+		mutex_lock(&psb->crypto_thread_lock);
+		if (!list_empty(&psb->crypto_ready_list)) {
+			t = list_entry(psb->crypto_ready_list.prev,
+					struct pohmelfs_crypto_thread,
+					thread_entry);
+
+			list_move_tail(&t->thread_entry,
+					&psb->crypto_active_list);
+
+			action(t, data);
+			wake_up(&t->wait);
+
+		}
+		mutex_unlock(&psb->crypto_thread_lock);
+	}
+
+	return err;
+}
+
+static int pohmelfs_trans_crypt_action(struct pohmelfs_crypto_thread *t, void *data)
+{
+	struct netfs_trans *trans = data;
+
+	netfs_trans_get(trans);
+	t->trans = trans;
+
+	dprintk("%s: t: %p, gen: %u, thread: %p.\n", __func__, trans, trans->gen, t);
+	return 0;
+}
+
+int pohmelfs_trans_crypt(struct netfs_trans *trans, struct pohmelfs_sb *psb)
+{
+	if ((!psb->hash_string && !psb->cipher_string) || !psb->perform_crypto) {
+		netfs_trans_get(trans);
+		return pohmelfs_crypto_finish(trans, psb, 0);
+	}
+
+	return pohmelfs_crypto_thread_get(psb, pohmelfs_trans_crypt_action, trans);
+}
+
+struct pohmelfs_crypto_input_action_data
+{
+	struct page			*page;
+	struct pohmelfs_crypto_engine	*e;
+	u64				iv;
+	unsigned int			size;
+};
+
+static int pohmelfs_crypt_input_page_action(struct pohmelfs_crypto_thread *t, void *data)
+{
+	struct pohmelfs_crypto_input_action_data *act = data;
+
+	memcpy(t->eng.data, act->e->data, t->psb->crypto_attached_size);
+
+	t->size = act->size;
+	t->eng.iv = act->iv;
+
+	t->page = act->page;
+	return 0;
+}
+
+int pohmelfs_crypto_process_input_page(struct pohmelfs_crypto_engine *e,
+		struct page *page, unsigned int size, u64 iv)
+{
+	struct inode *inode = page->mapping->host;
+	struct pohmelfs_crypto_input_action_data act;
+	int err = -ENOENT;
+
+	act.page = page;
+	act.e = e;
+	act.size = size;
+	act.iv = iv;
+
+	err = pohmelfs_crypto_thread_get(POHMELFS_SB(inode->i_sb),
+			pohmelfs_crypt_input_page_action, &act);
+	if (err)
+		goto err_out_exit;
+
+	return 0;
+
+err_out_exit:
+	SetPageUptodate(page);
+	page_cache_release(page);
+
+	return err;
+}
diff --git a/fs/pohmelfs/dir.c b/fs/pohmelfs/dir.c
new file mode 100644
index 0000000..9fec116
--- /dev/null
+++ b/fs/pohmelfs/dir.c
@@ -0,0 +1,1180 @@
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
+#include <linux/fs.h>
+#include <linux/jhash.h>
+#include <linux/pagemap.h>
+
+#include "netfs.h"
+
+/*
+ * Each pohmelfs directory inode contains a tree of childrens indexed
+ * by offset (in the dir reading stream) and name hash and len. Entries
+ * of that hashes are called pohmelfs_name.
+ *
+ * This routings deal with it.
+ */
+static int pohmelfs_cmp_offset(struct pohmelfs_name *n, u64 offset)
+{
+	if (n->offset > offset)
+		return -1;
+	if (n->offset < offset)
+		return 1;
+	return 0;
+}
+
+static struct pohmelfs_name *pohmelfs_search_offset(struct pohmelfs_inode *pi, u64 offset)
+{
+	struct rb_node *n = pi->offset_root.rb_node;
+	struct pohmelfs_name *tmp;
+	int cmp;
+
+	while (n) {
+		tmp = rb_entry(n, struct pohmelfs_name, offset_node);
+
+		cmp = pohmelfs_cmp_offset(tmp, offset);
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else
+			return tmp;
+	}
+
+	return NULL;
+}
+
+static struct pohmelfs_name *pohmelfs_insert_offset(struct pohmelfs_inode *pi,
+		struct pohmelfs_name *new)
+{
+	struct rb_node **n = &pi->offset_root.rb_node, *parent = NULL;
+	struct pohmelfs_name *ret = NULL, *tmp;
+	int cmp;
+
+	while (*n) {
+		parent = *n;
+
+		tmp = rb_entry(parent, struct pohmelfs_name, offset_node);
+
+		cmp = pohmelfs_cmp_offset(tmp, new->offset);
+		if (cmp < 0)
+			n = &parent->rb_left;
+		else if (cmp > 0)
+			n = &parent->rb_right;
+		else {
+			ret = tmp;
+			break;
+		}
+	}
+
+	if (ret)
+		return ret;
+
+	rb_link_node(&new->offset_node, parent, n);
+	rb_insert_color(&new->offset_node, &pi->offset_root);
+
+	pi->total_len += new->len;
+
+	return NULL;
+}
+
+static int pohmelfs_cmp_hash(struct pohmelfs_name *n, u32 hash, u32 len)
+{
+	if (n->hash > hash)
+		return -1;
+	if (n->hash < hash)
+		return 1;
+
+	if (n->len > len)
+		return -1;
+	if (n->len < len)
+		return 1;
+
+	return 0;
+}
+
+static struct pohmelfs_name *pohmelfs_search_hash(struct pohmelfs_inode *pi, u32 hash, u32 len)
+{
+	struct rb_node *n = pi->hash_root.rb_node;
+	struct pohmelfs_name *tmp;
+	int cmp;
+
+	while (n) {
+		tmp = rb_entry(n, struct pohmelfs_name, hash_node);
+
+		cmp = pohmelfs_cmp_hash(tmp, hash, len);
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else
+			return tmp;
+	}
+
+	return NULL;
+}
+
+static void __pohmelfs_name_del(struct pohmelfs_inode *parent, struct pohmelfs_name *node)
+{
+	rb_erase(&node->offset_node, &parent->offset_root);
+	rb_erase(&node->hash_node, &parent->hash_root);
+}
+
+/*
+ * Remove name cache entry from its caches and free it.
+ */
+static void pohmelfs_name_free(struct pohmelfs_inode *parent, struct pohmelfs_name *node)
+{
+	__pohmelfs_name_del(parent, node);
+	list_del(&node->sync_del_entry);
+	list_del(&node->sync_create_entry);
+	kfree(node);
+}
+
+static struct pohmelfs_name *pohmelfs_insert_hash(struct pohmelfs_inode *pi,
+		struct pohmelfs_name *new)
+{
+	struct rb_node **n = &pi->hash_root.rb_node, *parent = NULL;
+	struct pohmelfs_name *ret = NULL, *tmp;
+	int cmp;
+
+	while (*n) {
+		parent = *n;
+
+		tmp = rb_entry(parent, struct pohmelfs_name, hash_node);
+
+		cmp = pohmelfs_cmp_hash(tmp, new->hash, new->len);
+		if (cmp < 0)
+			n = &parent->rb_left;
+		else if (cmp > 0)
+			n = &parent->rb_right;
+		else {
+			ret = tmp;
+			break;
+		}
+	}
+
+	if (ret) {
+		printk("%s: exist: ino: %llu, hash: %x, len: %u, data: '%s', new: ino: %llu, hash: %x, len: %u, data: '%s'.\n",
+				__func__, ret->ino, ret->hash, ret->len, ret->data,
+				new->ino, new->hash, new->len, new->data);
+		ret->ino = new->ino;
+		return ret;
+	}
+
+	rb_link_node(&new->hash_node, parent, n);
+	rb_insert_color(&new->hash_node, &pi->hash_root);
+
+	return NULL;
+}
+
+/*
+ * Free name cache for given inode.
+ */
+void pohmelfs_free_names(struct pohmelfs_inode *parent)
+{
+	struct rb_node *rb_node;
+	struct pohmelfs_name *n;
+
+	for (rb_node = rb_first(&parent->offset_root); rb_node;) {
+		n = rb_entry(rb_node, struct pohmelfs_name, offset_node);
+		rb_node = rb_next(rb_node);
+
+		pohmelfs_name_free(parent, n);
+	}
+}
+
+/*
+ * When name cache entry is removed (for example when object is removed),
+ * offset for all subsequent childrens has to be fixed to match new reality.
+ */
+static int pohmelfs_fix_offset(struct pohmelfs_inode *parent, struct pohmelfs_name *node)
+{
+	struct rb_node *rb_node;
+	int decr = 0;
+
+	for (rb_node = rb_next(&node->offset_node); rb_node; rb_node = rb_next(rb_node)) {
+		struct pohmelfs_name *n = container_of(rb_node, struct pohmelfs_name, offset_node);
+
+		n->offset -= node->len;
+		decr++;
+	}
+
+	parent->total_len -= node->len;
+
+	return decr;
+}
+
+/*
+ * Fix offset and free name cache entry helper.
+ */
+void pohmelfs_name_del(struct pohmelfs_inode *parent, struct pohmelfs_name *node)
+{
+	int decr;
+
+	decr = pohmelfs_fix_offset(parent, node);
+
+	dprintk("%s: parent: %llu, ino: %llu, decr: %d.\n",
+			__func__, parent->ino, node->ino, decr);
+
+	pohmelfs_name_free(parent, node);
+}
+
+/*
+ * Insert new name cache entry into all caches (offset and name hash).
+ */
+static int pohmelfs_insert_name(struct pohmelfs_inode *parent, struct pohmelfs_name *n)
+{
+	struct pohmelfs_name *name;
+
+	name = pohmelfs_insert_offset(parent, n);
+	if (name)
+		return -EEXIST;
+
+	name = pohmelfs_insert_hash(parent, n);
+	if (name) {
+		parent->total_len -= n->len;
+		rb_erase(&n->offset_node, &parent->offset_root);
+		return -EEXIST;
+	}
+
+	list_add_tail(&n->sync_create_entry, &parent->sync_create_list);
+
+	return 0;
+}
+
+/*
+ * Allocate new name cache entry.
+ */
+static struct pohmelfs_name *pohmelfs_name_clone(unsigned int len)
+{
+	struct pohmelfs_name *n;
+
+	n = kzalloc(sizeof(struct pohmelfs_name) + len, GFP_KERNEL);
+	if (!n)
+		return NULL;
+
+	INIT_LIST_HEAD(&n->sync_create_entry);
+	INIT_LIST_HEAD(&n->sync_del_entry);
+
+	n->data = (char *)(n+1);
+
+	return n;
+}
+
+/*
+ * Add new name entry into directory's cache.
+ */
+static int pohmelfs_add_dir(struct pohmelfs_sb *psb, struct pohmelfs_inode *parent,
+		struct pohmelfs_inode *npi, struct qstr *str, unsigned int mode, int link)
+{
+	int err = -ENOMEM;
+	struct pohmelfs_name *n;
+	struct pohmelfs_path_entry *e = NULL;
+
+	n = pohmelfs_name_clone(str->len + 1);
+	if (!n)
+		goto err_out_exit;
+
+	n->ino = npi->ino;
+	n->offset = parent->total_len;
+	n->mode = mode;
+	n->len = str->len;
+	n->hash = str->hash;
+	sprintf(n->data, str->name);
+
+	if (!(str->len == 1 && str->name[0] == '.') &&
+			!(str->len == 2 && str->name[0] == '.' && str->name[1] == '.')) {
+		mutex_lock(&psb->path_lock);
+		e = pohmelfs_add_path_entry(psb, parent->ino, npi->ino, str, link, mode);
+		mutex_unlock(&psb->path_lock);
+		if (IS_ERR(e)) {
+			err = PTR_ERR(e);
+			goto err_out_free;
+		}
+	}
+
+	mutex_lock(&parent->offset_lock);
+	err = pohmelfs_insert_name(parent, n);
+	mutex_unlock(&parent->offset_lock);
+
+	if (err) {
+		if (err != -EEXIST)
+			goto err_out_remove;
+		kfree(n);
+	}
+
+	return 0;
+
+err_out_remove:
+	if (e) {
+		mutex_lock(&psb->path_lock);
+		pohmelfs_remove_path_entry(psb, e);
+		mutex_unlock(&psb->path_lock);
+	}
+err_out_free:
+	kfree(n);
+err_out_exit:
+	return err;
+}
+
+/*
+ * Create new inode for given parameters (name, inode info, parent).
+ * This does not create object on the server, it will be synced there during writeback.
+ */
+struct pohmelfs_inode *pohmelfs_new_inode(struct pohmelfs_sb *psb,
+		struct pohmelfs_inode *parent, struct qstr *str,
+		struct netfs_inode_info *info, int link)
+{
+	struct inode *new = NULL;
+	struct pohmelfs_inode *npi;
+	int err = -EEXIST;
+
+	dprintk("%s: creating inode: parent: %llu, ino: %llu, str: %p.\n",
+			__func__, (parent)?parent->ino:0, info->ino, str);
+
+	err = -ENOMEM;
+	new = iget_locked(psb->sb, info->ino);
+	if (!new)
+		goto err_out_exit;
+
+	npi = POHMELFS_I(new);
+	npi->ino = info->ino;
+	err = 0;
+
+	if (new->i_state & I_NEW) {
+		dprintk("%s: filling VFS inode: %lu/%llu.\n",
+				__func__, new->i_ino, info->ino);
+		pohmelfs_fill_inode(new, info);
+
+		if (S_ISDIR(info->mode)) {
+			struct qstr s;
+
+			s.name = ".";
+			s.len = 1;
+			s.hash = jhash(s.name, s.len, 0);
+
+			err = pohmelfs_add_dir(psb, npi, npi, &s, info->mode, 0);
+			if (err)
+				goto err_out_put;
+
+			s.name = "..";
+			s.len = 2;
+			s.hash = jhash(s.name, s.len, 0);
+
+			err = pohmelfs_add_dir(psb, npi, (parent)?parent:npi, &s,
+					(parent)?parent->vfs_inode.i_mode:npi->vfs_inode.i_mode, 0);
+			if (err)
+				goto err_out_put;
+		}
+	}
+
+	if (str) {
+		if (parent) {
+			err = pohmelfs_add_dir(psb, parent, npi, str, info->mode, link);
+
+			dprintk("%s: %s inserted name: '%s', new_offset: %llu, ino: %llu, parent: %llu.\n",
+					__func__, (err)?"unsuccessfully":"successfully",
+					str->name, parent->total_len, info->ino, parent->ino);
+
+			if (err && err != -EEXIST)
+				goto err_out_put;
+		} else {
+			mutex_lock(&psb->path_lock);
+			pohmelfs_add_path_entry(psb, npi->ino, npi->ino, str, link, info->mode);
+			mutex_unlock(&psb->path_lock);
+		}
+	}
+
+	if (new->i_state & I_NEW) {
+		if (parent)
+			mark_inode_dirty(&parent->vfs_inode);
+		mark_inode_dirty(new);
+
+#ifdef POHMELFS_CC_GROUP
+		pohmelfs_meta_command(npi, NETFS_JOIN_GROUP, 0, NULL, NULL, 0);
+#endif
+	}
+	unlock_new_inode(new);
+
+	return npi;
+
+err_out_put:
+	printk("%s: putting inode: %p, npi: %p, error: %d.\n", __func__, new, npi, err);
+	iput(new);
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+static int pohmelfs_remote_sync_complete(struct page **pages, unsigned int page_num,
+		void *private, int err)
+{
+	struct pohmelfs_inode *pi = private;
+	struct pohmelfs_sb *psb = POHMELFS_SB(pi->vfs_inode.i_sb);
+
+	dprintk("%s: ino: %llu, err: %d.\n", __func__, pi->ino, err);
+
+	if (err)
+		pi->error = err;
+	wake_up(&psb->wait);
+	pohmelfs_put_inode(pi);
+
+	return err;
+}
+
+/*
+ * Receive directory content from the server.
+ * This should be only done for objects, which were not created locally,
+ * and which were not synced previously.
+ */
+static int pohmelfs_sync_remote_dir(struct pohmelfs_inode *pi)
+{
+	struct inode *inode = &pi->vfs_inode;
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	long ret = msecs_to_jiffies(25000);
+	int err;
+
+	dprintk("%s: dir: %llu, state: %lx: created: %d, remote_synced: %d.\n",
+			__func__, pi->ino, pi->state, test_bit(NETFS_INODE_CREATED, &pi->state),
+			test_bit(NETFS_INODE_REMOTE_SYNCED, &pi->state));
+
+	if (!test_bit(NETFS_INODE_CREATED, &pi->state))
+		return 0;
+
+	if (test_bit(NETFS_INODE_REMOTE_SYNCED, &pi->state))
+		return 0;
+
+	if (!igrab(inode)) {
+		err = -ENOENT;
+		goto err_out_exit;
+	}
+
+	err = pohmelfs_meta_command(pi, NETFS_READDIR, NETFS_TRANS_SINGLE_DST,
+			pohmelfs_remote_sync_complete, pi, 0);
+	if (err)
+		goto err_out_exit;
+
+	pi->error = 0;
+	ret = wait_event_interruptible_timeout(psb->wait,
+			test_bit(NETFS_INODE_REMOTE_SYNCED, &pi->state) || pi->error, ret);
+	dprintk("%s: awake dir: %llu, ret: %ld, err: %d.\n", __func__, pi->ino, ret, pi->error);
+	if (ret <= 0) {
+		err = -ETIMEDOUT;
+		goto err_out_exit;
+	}
+
+	if (pi->error)
+		return pi->error;
+
+	return 0;
+
+err_out_exit:
+	clear_bit(NETFS_INODE_REMOTE_SYNCED, &pi->state);
+
+	return err;
+}
+
+/*
+ * VFS readdir callback. Syncs directory content from server if needed,
+ * and provide info to userspace.
+ */
+static int pohmelfs_readdir(struct file *file, void *dirent, filldir_t filldir)
+{
+	struct inode *inode = file->f_path.dentry->d_inode;
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	struct pohmelfs_name *n;
+	int err = 0, mode;
+	u64 len;
+
+	dprintk("%s: parent: %llu.\n", __func__, pi->ino);
+
+	err = pohmelfs_sync_remote_dir(pi);
+	if (err)
+		return err;
+
+	while (1) {
+		mutex_lock(&pi->offset_lock);
+		n = pohmelfs_search_offset(pi, file->f_pos);
+		if (!n) {
+			mutex_unlock(&pi->offset_lock);
+			err = 0;
+			break;
+		}
+
+		mode = (n->mode >> 12) & 15;
+
+		dprintk("%s: offset: %llu, parent ino: %llu, name: '%s', len: %u, ino: %llu, mode: %o/%o.\n",
+				__func__, file->f_pos, pi->ino, n->data, n->len,
+				n->ino, n->mode, mode);
+
+		len = n->len;
+		err = filldir(dirent, n->data, n->len, file->f_pos, n->ino, mode);
+		mutex_unlock(&pi->offset_lock);
+
+		if (err < 0) {
+			dprintk("%s: err: %d.\n", __func__, err);
+			err = 0;
+			break;
+		}
+
+		file->f_pos += len;
+	}
+
+	return err;
+}
+
+const struct file_operations pohmelfs_dir_fops = {
+	.read = generic_read_dir,
+	.readdir = pohmelfs_readdir,
+};
+
+/*
+ * Lookup single object on server.
+ */
+static int pohmelfs_lookup_single(struct pohmelfs_inode *parent,
+		struct qstr *str, u64 ino)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(parent->vfs_inode.i_sb);
+	long ret = msecs_to_jiffies(5000);
+	int err;
+
+	set_bit(NETFS_COMMAND_PENDING, &parent->state);
+	err = pohmelfs_meta_command_data(parent, NETFS_LOOKUP,
+			(char *)str->name, NETFS_TRANS_SINGLE_DST, NULL, NULL, ino);
+	if (err)
+		goto err_out_exit;
+
+	err = 0;
+	ret = wait_event_interruptible_timeout(psb->wait,
+			!test_bit(NETFS_COMMAND_PENDING, &parent->state), ret);
+	if (ret == 0)
+		err = -ETIMEDOUT;
+	else if (signal_pending(current))
+		err = -EINTR;
+
+	if (err)
+		goto err_out_exit;
+
+	return 0;
+
+err_out_exit:
+	clear_bit(NETFS_COMMAND_PENDING, &parent->state);
+
+	printk("%s: failed: parent: %llu, ino: %llu, name: '%s', err: %d.\n",
+			__func__, parent->ino, ino, str->name, err);
+
+	return err;
+}
+
+/*
+ * VFS lookup callback.
+ * We first try to get inode number from local name cache, if we have one,
+ * then inode can be found in inode cache. If there is no inode or no object in
+ * local cache, try to lookup it on server. This only should be done for directories,
+ * which were not created locally, otherwise remote server does not know about dir at all,
+ * so no need to try to know that.
+ */
+struct dentry *pohmelfs_lookup(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
+{
+	struct pohmelfs_inode *parent = POHMELFS_I(dir);
+	struct pohmelfs_name *n;
+	struct inode *inode = NULL;
+	unsigned long ino = 0;
+	int err;
+	struct qstr str = dentry->d_name;
+
+	str.hash = jhash(dentry->d_name.name, dentry->d_name.len, 0);
+
+	mutex_lock(&parent->offset_lock);
+	n = pohmelfs_search_hash(parent, str.hash, str.len);
+	if (n)
+		ino = n->ino;
+	mutex_unlock(&parent->offset_lock);
+
+	dprintk("%s: 1 ino: %lu, inode: %p, name: '%s', hash: %x, parent_state: %lx.\n",
+			__func__, ino, inode, str.name, str.hash, parent->state);
+
+	if (ino) {
+		inode = ilookup(dir->i_sb, ino);
+		if (inode)
+			goto out;
+	}
+
+	dprintk("%s: dir: %p, dir_ino: %llu, name: '%s', len: %u, dir_state: %lx, ino: %lu.\n",
+			__func__, dir, parent->ino,
+			str.name, str.len, parent->state, ino);
+
+	if (!ino) {
+		if (!test_bit(NETFS_INODE_CREATED, &parent->state))
+			goto out;
+
+		if (test_bit(NETFS_INODE_REMOTE_SYNCED, &parent->state))
+			goto out;
+	}
+
+	err = pohmelfs_lookup_single(parent, &str, ino);
+	if (err)
+		goto out;
+
+	if (!ino) {
+		mutex_lock(&parent->offset_lock);
+		n = pohmelfs_search_hash(parent, str.hash, str.len);
+		if (n)
+			ino = n->ino;
+		mutex_unlock(&parent->offset_lock);
+	}
+
+	if (ino) {
+		inode = ilookup(dir->i_sb, ino);
+		printk("%s: second lookup ino: %lu, inode: %p, name: '%s', hash: %x.\n",
+				__func__, ino, inode, str.name, str.hash);
+		if (!inode) {
+			printk("%s: No inode for ino: %lu, name: '%s', hash: %x.\n",
+				__func__, ino, str.name, str.hash);
+			//return NULL;
+			return ERR_PTR(-EACCES);
+		}
+	} else {
+		printk("%s: No inode number : name: '%s', hash: %x.\n",
+			__func__, str.name, str.hash);
+	}
+out:
+	return d_splice_alias(inode, dentry);
+}
+
+/*
+ * Create new object in local cache. Object will be synced to server
+ * during writeback for given inode.
+ */
+struct pohmelfs_inode *pohmelfs_create_entry_local(struct pohmelfs_sb *psb,
+	struct pohmelfs_inode *parent, struct qstr *str, u64 start, int mode)
+{
+	struct pohmelfs_inode *npi;
+	int err = -ENOMEM;
+	struct netfs_inode_info info;
+
+	dprintk("%s: name: '%s', mode: %o, start: %llu.\n",
+			__func__, str->name, mode, start);
+
+	info.mode = mode;
+	info.ino = start;
+
+	if (!start)
+		info.ino = pohmelfs_new_ino(psb);
+
+	info.nlink = S_ISDIR(mode)?2:1;
+	info.uid = current->uid;
+	info.gid = current->gid;
+	info.size = 0;
+	info.blocksize = 512;
+	info.blocks = 0;
+	info.rdev = 0;
+	info.version = 0;
+
+	npi = pohmelfs_new_inode(psb, parent, str, &info, !!start);
+	if (IS_ERR(npi)) {
+		err = PTR_ERR(npi);
+		goto err_out_unlock;
+	}
+
+	set_bit(NETFS_INODE_REMOTE_SYNCED, &npi->state);
+
+	return npi;
+
+err_out_unlock:
+	dprintk("%s: err: %d.\n", __func__, err);
+	return ERR_PTR(err);
+}
+
+/*
+ * Create local object and bind it to dentry.
+ */
+static int pohmelfs_create_entry(struct inode *dir, struct dentry *dentry, u64 start, int mode)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(dir->i_sb);
+	struct pohmelfs_inode *npi;
+	struct qstr str = dentry->d_name;
+
+	str.hash = jhash(dentry->d_name.name, dentry->d_name.len, 0);
+
+	npi = pohmelfs_create_entry_local(psb, POHMELFS_I(dir), &str, start, mode);
+	if (IS_ERR(npi))
+		return PTR_ERR(npi);
+
+	d_instantiate(dentry, &npi->vfs_inode);
+
+	dprintk("%s: parent: %llu, inode: %llu, name: '%s', parent_nlink: %d, nlink: %d.\n",
+			__func__, POHMELFS_I(dir)->ino, npi->ino, dentry->d_name.name,
+			(signed)dir->i_nlink, (signed)npi->vfs_inode.i_nlink);
+
+	return 0;
+}
+
+/*
+ * VFS create and mkdir callbacks.
+ */
+static int pohmelfs_create(struct inode *dir, struct dentry *dentry, int mode,
+		struct nameidata *nd)
+{
+	return pohmelfs_create_entry(dir, dentry, 0, mode);
+}
+
+static int pohmelfs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
+{
+	int err;
+
+	inode_inc_link_count(dir);
+	err = pohmelfs_create_entry(dir, dentry, 0, mode | S_IFDIR);
+	if (err)
+		inode_dec_link_count(dir);
+
+	return err;
+}
+
+/*
+ * Remove entry from local cache.
+ * Object will not be removed from server, instead it will be queued into parent
+ * to-be-removed queue, which will be processed during parent writeback (parent
+ * also marked as dirty). Writeback will send remove request to server.
+ * Such approach allows to remove vey huge directories (like 2.6.24 kernel tree)
+ * with only single network command.
+ */
+static int pohmelfs_remove_entry(struct inode *dir, struct dentry *dentry)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(dir->i_sb);
+	struct inode *inode = dentry->d_inode;
+	struct pohmelfs_inode *parent = POHMELFS_I(dir), *pi = POHMELFS_I(inode);
+	struct pohmelfs_name *n;
+	int err = -ENOENT;
+	struct qstr str = dentry->d_name;
+
+	str.hash = jhash(dentry->d_name.name, dentry->d_name.len, 0);
+
+	dprintk("%s: dir_ino: %llu, inode: %llu, name: '%s', nlink: %d.\n",
+			__func__, parent->ino, pi->ino,
+			str.name, (signed)inode->i_nlink);
+
+	mutex_lock(&parent->offset_lock);
+	n = pohmelfs_search_hash(parent, str.hash, str.len);
+	if (n) {
+		pohmelfs_fix_offset(parent, n);
+		if (test_bit(NETFS_INODE_CREATED, &pi->state)) {
+			__pohmelfs_name_del(parent, n);
+			list_add_tail(&n->sync_del_entry, &parent->sync_del_list);
+		} else
+			pohmelfs_name_free(parent, n);
+		err = 0;
+	}
+	mutex_unlock(&parent->offset_lock);
+
+	if (!err) {
+		mutex_lock(&psb->path_lock);
+		pohmelfs_remove_path_entry_by_ino(psb, pi->ino);
+		mutex_unlock(&psb->path_lock);
+
+		pohmelfs_inode_del_inode(psb, pi);
+
+		mark_inode_dirty(dir);
+
+		inode->i_ctime = dir->i_ctime;
+		if (inode->i_nlink)
+			inode_dec_link_count(inode);
+	}
+	dprintk("%s: inode: %p, lock: %ld, unhashed: %d.\n",
+		__func__, pi, inode->i_state & I_LOCK, hlist_unhashed(&inode->i_hash));
+
+	return err;
+}
+
+/*
+ * Unlink and rmdir VFS callbacks.
+ */
+static int pohmelfs_unlink(struct inode *dir, struct dentry *dentry)
+{
+	return pohmelfs_remove_entry(dir, dentry);
+}
+
+static int pohmelfs_rmdir(struct inode *dir, struct dentry *dentry)
+{
+	int err;
+	struct inode *inode = dentry->d_inode;
+
+	dprintk("%s: parent: %llu, inode: %llu, name: '%s', parent_nlink: %d, nlink: %d.\n",
+			__func__, POHMELFS_I(dir)->ino, POHMELFS_I(inode)->ino,
+			dentry->d_name.name, (signed)dir->i_nlink, (signed)inode->i_nlink);
+
+	err = pohmelfs_remove_entry(dir, dentry);
+	if (!err) {
+		inode_dec_link_count(dir);
+		inode_dec_link_count(inode);
+	}
+
+	return err;
+}
+
+/*
+ * Link creation is synchronous.
+ * I'm lazy.
+ * Earth is somewhat round.
+ */
+static int pohmelfs_create_link(struct pohmelfs_inode *parent, struct qstr *obj,
+		struct pohmelfs_inode *target, struct qstr *tstr)
+{
+	struct super_block *sb = parent->vfs_inode.i_sb;
+	struct pohmelfs_sb *psb = POHMELFS_SB(sb);
+	struct netfs_cmd *cmd;
+	struct netfs_trans *t;
+	void *data;
+	int err, parent_len, target_len = 0, cur_len, path_size = 0;
+
+	err = sb->s_op->write_inode(&parent->vfs_inode, 0);
+	if (err)
+		goto err_out_exit;
+
+	if (tstr)
+		target_len = tstr->len;
+
+	mutex_lock(&psb->path_lock);
+	parent_len = pohmelfs_path_length(parent);
+	if (target)
+		target_len += pohmelfs_path_length(target);
+	mutex_unlock(&psb->path_lock);
+
+	if (parent_len < 0) {
+		err = parent_len;
+		goto err_out_exit;
+	}
+	
+	if (target_len < 0) {
+		err = target_len;
+		goto err_out_exit;
+	}
+
+	t = netfs_trans_alloc(psb, parent_len + target_len + obj->len + 2, 0, 0);
+	if (!t) {
+		err = -ENOMEM;
+		goto err_out_exit;
+	}
+	cur_len = netfs_trans_cur_len(t);
+
+	cmd = netfs_trans_current(t);
+	if (IS_ERR(cmd)) {
+		err = PTR_ERR(cmd);
+		goto err_out_free;
+	}
+
+	data = (void *)(cmd + 1);
+	cur_len -= sizeof(struct netfs_cmd);
+
+	mutex_lock(&psb->path_lock);
+	err = pohmelfs_construct_path_string(parent, data, parent_len);
+	if (err > 0) {
+		path_size = err;
+		cur_len -= path_size;
+
+		err = snprintf(data + path_size, cur_len, "/%s|", obj->name);
+
+		path_size += err;
+		cur_len -= err;
+
+		cmd->ext = path_size - 1; /* No | symbol */
+
+		if (target) {
+			err = pohmelfs_construct_path_string(target, data + path_size, target_len);
+			if (err > 0) {
+				path_size += err + 1;
+				cur_len -= err + 1;
+			}
+		}
+	}
+	mutex_unlock(&psb->path_lock);
+
+	if (err < 0)
+		goto err_out_free;
+
+	cmd->start = 0;
+
+	if (!target && tstr) {
+		if (tstr->len > cur_len - 1) {
+			err = -ENAMETOOLONG;
+			goto err_out_free;
+		}
+
+		err = snprintf(data + path_size, cur_len, "%s", tstr->name) + 1 /* 0-byte */;
+		path_size += err;
+		cur_len -= err;
+		cmd->start = 1;
+	}
+
+	dprintk("%s: parent: %llu, obj: '%s', target_inode: %llu, target_str: '%s', full: '%s'.\n",
+			__func__, parent->ino, obj->name, (target)?target->ino:0, (tstr)?tstr->name:NULL,
+			(char *)data);
+
+	cmd->cmd = NETFS_LINK;
+	cmd->size = path_size;
+	cmd->id = parent->ino;
+
+	netfs_convert_cmd(cmd);
+	
+	netfs_trans_update(cmd, t, path_size);
+
+	err = netfs_trans_finish(t, psb);
+	if (err)
+		goto err_out_exit;
+
+	return 0;
+
+err_out_free:
+	t->result = err;
+	netfs_trans_put(t);
+err_out_exit:
+	return err;
+}
+
+/*
+ *  VFS hard and soft link callbacks.
+ */
+static int pohmelfs_link(struct dentry *old_dentry, struct inode *dir,
+	struct dentry *dentry)
+{
+	struct inode *inode = old_dentry->d_inode;
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	int err;
+	struct qstr str = dentry->d_name;
+
+	str.hash = jhash(dentry->d_name.name, dentry->d_name.len, 0);
+
+	err = inode->i_sb->s_op->write_inode(inode, 0);
+	if (err)
+		return err;
+
+	err = pohmelfs_create_link(POHMELFS_I(dir), &str, pi, NULL);
+	if (err)
+		return err;
+
+	return pohmelfs_create_entry(dir, dentry, pi->ino, inode->i_mode);
+}
+
+static int pohmelfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
+{
+	struct qstr sym_str;
+	struct qstr str = dentry->d_name;
+	struct inode *inode;
+	int err;
+
+	str.hash = jhash(dentry->d_name.name, dentry->d_name.len, 0);
+
+	sym_str.name = symname;
+	sym_str.len = strlen(symname);
+
+	err = pohmelfs_create_link(POHMELFS_I(dir), &str, NULL, &sym_str);
+	if (err)
+		goto err_out_exit;
+
+	err = pohmelfs_create_entry(dir, dentry, 0, S_IFLNK | S_IRWXU | S_IRWXG | S_IRWXO);
+	if (err)
+		goto err_out_exit;
+
+	inode = dentry->d_inode;
+
+	err = page_symlink(inode, symname, sym_str.len + 1);
+	if (err)
+		goto err_out_put;
+
+	return 0;
+
+err_out_put:
+	iput(inode);
+err_out_exit:
+	return err;
+}
+
+static int pohmelfs_send_rename(struct pohmelfs_inode *pi, struct pohmelfs_inode *parent,
+		struct qstr *str)
+{
+	int path_len, err, total_len = 0, inode_len, parent_len;
+	char *path;
+	struct netfs_trans *t;
+	struct netfs_cmd *cmd;
+	struct pohmelfs_sb *psb = POHMELFS_SB(pi->vfs_inode.i_sb);
+
+	mutex_lock(&psb->path_lock);
+	parent_len = pohmelfs_path_length(parent);
+	inode_len = pohmelfs_path_length(pi);
+	mutex_unlock(&psb->path_lock);
+
+	if (parent_len < 0 || inode_len < 0)
+		return -EINVAL;
+
+	path_len = parent_len + inode_len + str->len + 3;
+
+	t = netfs_trans_alloc(psb, path_len, 0, 0);
+	if (!t)
+		return -ENOMEM;
+
+	cmd = netfs_trans_current(t);
+	path = (char *)(cmd + 1);
+
+	mutex_lock(&psb->path_lock);
+	err = pohmelfs_construct_path_string(pi, path, inode_len + 1);
+	if (err < 0)
+		goto err_out_unlock;
+
+	cmd->ext = err;
+
+	path += err;
+	total_len += err;
+	path_len -= err;
+
+	*path = '|';
+	path++;
+	total_len++;
+	path_len--;
+
+	err = pohmelfs_construct_path_string(parent, path, parent_len + 1);
+	if (err < 0)
+		goto err_out_unlock;
+	mutex_unlock(&psb->path_lock);
+
+	path += err;
+	total_len += err;
+	path_len -= err;
+
+	err = snprintf(path, path_len - 1, "/%s", str->name);
+
+	total_len += err + 1; /* 0 symbol */
+	path_len -= err + 1;
+
+	cmd->cmd = NETFS_RENAME;
+	cmd->id = pi->ino;
+	cmd->start = parent->ino;
+	cmd->size = total_len;
+
+	netfs_convert_cmd(cmd);
+	
+	netfs_trans_update(cmd, t, total_len);
+
+	return netfs_trans_finish(t, psb);
+
+err_out_unlock:
+	mutex_unlock(&psb->path_lock);
+	netfs_trans_free(t);
+	return err;
+}
+
+static int pohmelfs_rename(struct inode *old_dir, struct dentry *old_dentry,
+			struct inode *new_dir, struct dentry *new_dentry)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(old_dir->i_sb);
+	struct inode *old_inode = old_dentry->d_inode;
+	struct pohmelfs_inode *old_parent, *old, *new_parent;
+	struct qstr str = new_dentry->d_name;
+	struct pohmelfs_name *n;
+	unsigned int old_hash;
+	int err = -ENOENT;
+	
+	if (new_dir) {
+		err = new_dir->i_sb->s_op->write_inode(new_dir, 0);
+		if (err)
+			return err;
+	}
+
+	err = old_inode->i_sb->s_op->write_inode(old_inode, 0);
+	if (err)
+		return err;
+
+	old_hash = jhash(old_dentry->d_name.name, old_dentry->d_name.len, 0);
+	str.hash = jhash(new_dentry->d_name.name, new_dentry->d_name.len, 0);
+
+	old = POHMELFS_I(old_inode);
+	old_parent = POHMELFS_I(old_dir);
+
+	str.len = new_dentry->d_name.len;
+	str.name = new_dentry->d_name.name;
+	str.hash = jhash(new_dentry->d_name.name, new_dentry->d_name.len, 0);
+
+	if (new_dir) {
+		new_parent = POHMELFS_I(new_dir);
+		err = -ENOTEMPTY;
+
+		if (S_ISDIR(old_inode->i_mode) &&
+				new_parent->total_len <= 3)
+			goto err_out_exit;
+	} else {
+		new_parent = old_parent;
+	}
+
+	dprintk("%s: ino: %llu, parent: %llu, name: '%s' -> parent: %llu, name: '%s'.\n",
+			__func__, old->ino, old_parent->ino, old_dentry->d_name.name,
+			new_parent->ino, new_dentry->d_name.name);
+
+	err = pohmelfs_send_rename(old, new_parent, &str);
+	if (err)
+		goto err_out_exit;
+
+	mutex_lock(&psb->path_lock);
+	err = pohmelfs_rename_path_entry(psb, old->ino, new_parent->ino, &str);
+	mutex_unlock(&psb->path_lock);
+	if (err)
+		goto err_out_exit;
+
+	n = pohmelfs_name_clone(str.len + 1);
+	if (!n)
+		goto err_out_exit;
+
+	mutex_lock(&new_parent->offset_lock);
+	n->ino = old->ino;
+	n->offset = new_parent->total_len;
+	n->mode = old_inode->i_mode;
+	n->len = str.len;
+	n->hash = str.hash;
+	sprintf(n->data, str.name);
+	
+	err = pohmelfs_insert_name(new_parent, n);
+	mutex_unlock(&new_parent->offset_lock);
+
+	if (err)
+		goto err_out_exit;
+
+	mutex_lock(&old_parent->offset_lock);
+	n = pohmelfs_search_hash(old_parent, old_hash, old_dentry->d_name.len);
+	if (n)
+		pohmelfs_name_del(old_parent, n);
+	mutex_unlock(&old_parent->offset_lock);
+
+	mark_inode_dirty(old_inode);
+	mark_inode_dirty(&new_parent->vfs_inode);
+
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+/*
+ * POHMELFS directory inode operations.
+ */
+const struct inode_operations pohmelfs_dir_inode_ops = {
+	.link		= pohmelfs_link,
+	.symlink	= pohmelfs_symlink,
+	.unlink		= pohmelfs_unlink,
+	.mkdir		= pohmelfs_mkdir,
+	.rmdir		= pohmelfs_rmdir,
+	.create		= pohmelfs_create,
+	.lookup 	= pohmelfs_lookup,
+	.setattr	= pohmelfs_setattr,
+	.rename		= pohmelfs_rename,
+};
diff --git a/fs/pohmelfs/inode.c b/fs/pohmelfs/inode.c
new file mode 100644
index 0000000..f9109dd
--- /dev/null
+++ b/fs/pohmelfs/inode.c
@@ -0,0 +1,1712 @@
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
+#include <linux/backing-dev.h>
+#include <linux/crypto.h>
+#include <linux/fs.h>
+#include <linux/jhash.h>
+#include <linux/hash.h>
+#include <linux/ktime.h>
+#include <linux/mm.h>
+#include <linux/mount.h>
+#include <linux/pagemap.h>
+#include <linux/pagevec.h>
+#include <linux/parser.h>
+#include <linux/swap.h>
+#include <linux/slab.h>
+#include <linux/statfs.h>
+#include <linux/writeback.h>
+#include <linux/quotaops.h>
+
+#include "netfs.h"
+
+#define POHMELFS_MAGIC_NUM	0x504f482e
+
+static struct kmem_cache *pohmelfs_inode_cache;
+
+/*
+ * Removes inode from all trees, drops local name cache and removes all queued
+ * requests for object removal.
+ */
+void pohmelfs_inode_del_inode(struct pohmelfs_sb *psb, struct pohmelfs_inode *pi)
+{
+	struct pohmelfs_name *n, *tmp;
+
+	mutex_lock(&pi->offset_lock);
+	pohmelfs_free_names(pi);
+
+	list_for_each_entry_safe(n, tmp, &pi->sync_create_list, sync_create_entry) {
+		list_del_init(&n->sync_create_entry);
+		list_del_init(&n->sync_del_entry);
+		kfree(n);
+	}
+
+	list_for_each_entry_safe(n, tmp, &pi->sync_del_list, sync_del_entry) {
+		list_del_init(&n->sync_create_entry);
+		list_del_init(&n->sync_del_entry);
+		kfree(n);
+	}
+	mutex_unlock(&pi->offset_lock);
+
+	dprintk("%s: deleted stuff in ino: %llu.\n", __func__, pi->ino);
+}
+
+/*
+ * Sync inode to server.
+ * Returns zero in success and negative error value otherwise.
+ * It will gather path to root directory into structures containing
+ * creation mode, permissions and names, so that the whole path
+ * to given inode could be created using only single network command.
+ */
+static int pohmelfs_write_inode_create(struct inode *inode, struct netfs_trans *trans)
+{
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	int err = -ENOMEM, size;
+	struct netfs_cmd *cmd;
+	void *data;
+	int cur_len = netfs_trans_cur_len(trans);
+
+	if (unlikely(cur_len < 0))
+		return -ETOOSMALL;
+
+	cmd = netfs_trans_current(trans);
+	cur_len -= sizeof(struct netfs_cmd);
+
+	data = (void *)(cmd + 1);
+
+	mutex_lock(&psb->path_lock);
+	err = pohmelfs_construct_path(pi, data, cur_len);
+	mutex_unlock(&psb->path_lock);
+
+	dprintk("%s: cmd: %p, data: %p, len: %u, err: %u.\n",
+			__func__, cmd, data, cur_len, err);
+
+	if (err < 0)
+		goto err_out_exit;
+
+	size = err;
+
+	if (size) {
+		cmd->start = 0;
+		cmd->cmd = NETFS_CREATE;
+		cmd->size = size;
+		cmd->id = pi->ino;
+		cmd->ext = 0;
+
+		netfs_convert_cmd(cmd);
+	}
+
+	netfs_trans_update(cmd, trans, size);
+
+	return 0;
+
+err_out_exit:
+	clear_bit(NETFS_INODE_CREATED, &pi->state);
+	printk("%s: completed ino: %llu, err: %d.\n", __func__, pi->ino, err);
+	return err;
+}
+
+static int pohmelfs_write_trans_complete(struct page **pages, unsigned int page_num,
+		void *private, int err)
+{
+	unsigned i;
+
+	dprintk("%s: pages: %lu-%lu, page_num: %u, err: %d.\n",
+			__func__, pages[0]->index, pages[page_num-1]->index,
+			page_num, err);
+
+	for (i = 0; i < page_num; i++) {
+		struct page *page = pages[i];
+
+		if (!page)
+			continue;
+
+		end_page_writeback(page);
+
+		if (err < 0) {
+			SetPageError(page);
+			set_page_dirty(page);
+		}
+
+		unlock_page(page);
+		page_cache_release(page);
+
+		//dprintk("%s: %3u/%u: page: %p.\n", __func__, i, page_num, page);
+	}
+	return err;
+}
+
+static int pohmelfs_inode_has_dirty_pages(struct address_space *mapping, pgoff_t index)
+{
+	int ret;
+	struct page *page;
+
+	read_lock_irq(&mapping->tree_lock);
+	ret = radix_tree_gang_lookup_tag(&mapping->page_tree,
+				(void **)&page, index, 1, PAGECACHE_TAG_DIRTY);
+	read_unlock_irq(&mapping->tree_lock);
+	return ret;
+}
+
+static int pohmelfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
+{
+	struct inode *inode = mapping->host;
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	int err = 0;
+	int done = 0;
+	int nr_pages;
+	int created = 0;
+	pgoff_t index;
+	pgoff_t end;		/* Inclusive */
+	int scanned = 0;
+	int range_whole = 0;
+
+	if (wbc->nonblocking && bdi_write_congested(bdi)) {
+		wbc->encountered_congestion = 1;
+		return 0;
+	}
+
+	if (wbc->range_cyclic) {
+		index = mapping->writeback_index; /* Start from prev offset */
+		end = -1;
+	} else {
+		index = wbc->range_start >> PAGE_CACHE_SHIFT;
+		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
+			range_whole = 1;
+		scanned = 1;
+	}
+retry:
+	while (!done && (index <= end)) {
+		unsigned int i = min(end - index, (pgoff_t)psb->trans_max_pages);
+		unsigned int path_len;
+		struct netfs_trans *trans;
+
+		err = pohmelfs_inode_has_dirty_pages(mapping, index);
+		if (!err)
+			break;
+
+		mutex_lock(&psb->path_lock);
+		if (!test_bit(NETFS_INODE_CREATED, &pi->state))
+			err = pohmelfs_path_length_create(pi);
+		else
+			err = pohmelfs_path_length(pi);
+		mutex_unlock(&psb->path_lock);
+
+		if (err < 0)
+			break;
+
+		path_len = err;
+
+		trans = netfs_trans_alloc(psb, path_len, 0, i);
+		if (!trans) {
+			err = -ENOMEM;
+			break;
+		}
+		trans->complete = &pohmelfs_write_trans_complete;
+
+		trans->page_num = nr_pages = find_get_pages_tag(mapping, &index,
+				PAGECACHE_TAG_DIRTY, trans->page_num,
+				trans->pages);
+
+		dprintk("%s: t: %p, nr_pages: %u, end: %lu, index: %lu, max: %u.\n",
+				__func__, trans, nr_pages, end, index, trans->page_num);
+
+		if (!nr_pages)
+			goto err_out_reset;
+		
+		if (!test_bit(NETFS_INODE_CREATED, &pi->state)) {
+			err = pohmelfs_write_inode_create(inode, trans);
+			if (err)
+				goto err_out_reset;
+			created = 1;
+		} else {
+			void *data;
+			struct netfs_cmd *cmd = netfs_trans_current(trans);
+
+			data = (void *)(cmd + 1);
+
+			mutex_lock(&psb->path_lock);
+			err = pohmelfs_construct_path_string(pi, data, path_len);
+			mutex_unlock(&psb->path_lock);
+			if (err < 0)
+				goto err_out_reset;
+
+			cmd->id = pi->ino;
+			cmd->start = 0;
+			cmd->size = err + 1;
+			cmd->cmd = NETFS_OPEN;
+			cmd->ext = O_RDWR | O_LARGEFILE;
+			cmd->csize = 0;
+			cmd->cpad = 0;
+
+			netfs_convert_cmd(cmd);
+			netfs_trans_update(cmd, trans, err + 1);
+		}
+
+		err = 0;
+		scanned = 1;
+		for (i = 0; i < trans->page_num; i++) {
+			struct page *page = trans->pages[i];
+
+			lock_page(page);
+
+			if (unlikely(page->mapping != mapping))
+				goto out_continue;
+
+			if (!wbc->range_cyclic && page->index > end) {
+				done = 1;
+				goto out_continue;
+			}
+
+			if (wbc->sync_mode != WB_SYNC_NONE)
+				wait_on_page_writeback(page);
+
+			if (PageWriteback(page) ||
+			    !clear_page_dirty_for_io(page)) {
+				dprintk("%s: not clear for io page: %p, writeback: %d.\n",
+						__func__, page, PageWriteback(page));
+				goto out_continue;
+			}
+
+			set_page_writeback(page);
+
+			trans->attached_size += page_private(page);
+			trans->attached_pages++;
+#if 0
+			dprintk("%s: %u/%u added trans: %p, gen: %u, page: %p, [High: %d], size: %lu, idx: %lu.\n",
+					__func__, i, trans->page_num, trans, trans->gen, page,
+					!!PageHighMem(page), page_private(page), page->index);
+#endif
+			wbc->nr_to_write--;
+
+			if (wbc->nr_to_write <= 0)
+				done = 1;
+			if (wbc->nonblocking && bdi_write_congested(bdi)) {
+				wbc->encountered_congestion = 1;
+				done = 1;
+			}
+
+			continue;
+out_continue:
+			unlock_page(page);
+			trans->pages[i] = NULL;
+		}
+
+		if (trans->attached_size || created) {
+			err = netfs_trans_finish(trans, psb);
+		} else {
+			netfs_trans_reset(trans);
+			netfs_trans_put(trans);
+		}
+
+		if (err)
+			break;
+
+		continue;
+
+err_out_reset:
+		trans->result = err;
+		netfs_trans_reset(trans);
+		netfs_trans_put(trans);
+		break;
+	}
+
+	if (!scanned && !done) {
+		/*
+		 * We hit the last page and there is more work to be done: wrap
+		 * back to the start of the file
+		 */
+		scanned = 1;
+		index = 0;
+		goto retry;
+	}
+
+	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))
+		mapping->writeback_index = index;
+
+	return err;
+}
+
+/*
+ * Removes given child from given inode on server.
+ */
+static int pohmelfs_remove_child(struct pohmelfs_inode *parent, struct pohmelfs_name *n)
+{
+	dprintk("%s: parent: %llu, ino: %llu, name: '%s'.\n",
+			__func__, parent->ino, n->ino, n->data);
+
+	return pohmelfs_meta_command_data(parent, NETFS_REMOVE, n->data, 0, NULL, NULL, 0);
+}
+
+/*
+ * Removes all childs, marked for deletion, on server.
+ */
+static int pohmelfs_write_inode_remove_children(struct inode *inode)
+{
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	int err, error = 0;
+	struct pohmelfs_name *n, *tmp;
+
+	if (!list_empty(&pi->sync_del_list)) {
+		dprintk("%s: parent: %llu.\n", __func__, pi->ino);
+
+		mutex_lock(&pi->offset_lock);
+		list_for_each_entry_safe(n, tmp, &pi->sync_del_list, sync_del_entry) {
+			list_del_init(&n->sync_del_entry);
+			list_del_init(&n->sync_create_entry);
+
+			err = pohmelfs_remove_child(pi, n);
+			if (err)
+				error = err;
+
+			kfree(n);
+		}
+		mutex_unlock(&pi->offset_lock);
+	}
+
+	return error;
+}
+
+/*
+ * Inode writeback creation completion callback.
+ * Only invoked for just created inodes, which do not have pages attached,
+ * like dirs and empty files.
+ */
+static int pohmelfs_write_inode_complete(struct page **pages, unsigned int page_num,
+		void *private, int err)
+{
+	struct inode *inode = private;
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+
+	if (inode) {
+		if (err) {
+			mark_inode_dirty(inode);
+			clear_bit(NETFS_INODE_CREATED, &pi->state);
+		} else
+			set_bit(NETFS_INODE_CREATED, &pi->state);
+
+		pohmelfs_put_inode(pi);
+	}
+
+	return err;
+}
+
+/*
+ * Writeback for given inode.
+ */
+static int pohmelfs_write_inode(struct inode *inode, int sync)
+{
+	int err;
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	struct netfs_trans *t;
+
+	if (!test_bit(NETFS_INODE_CREATED, &pi->state)) {
+		dprintk("%s: started ino: %llu.\n", __func__, pi->ino);
+
+		mutex_lock(&psb->path_lock);
+		err = pohmelfs_path_length_create(pi);
+		mutex_unlock(&psb->path_lock);
+		if (err < 0)
+			goto err_out_remove;
+
+		t = netfs_trans_alloc(psb, err + 1, 0, 0);
+		if (!t) {
+			err = -ENOMEM;
+			goto err_out_put;
+		}
+		t->complete = pohmelfs_write_inode_complete;
+		t->private = igrab(inode);
+		if (!t->private) {
+			err = -ENOENT;
+			goto err_out_put;
+		}
+
+		err = pohmelfs_write_inode_create(inode, t);
+		if (err)
+			goto err_out_put;
+
+		err = netfs_trans_finish(t, POHMELFS_SB(inode->i_sb));
+		if (err)
+			goto err_out_remove;
+	}
+
+	pohmelfs_write_inode_remove_children(inode);
+
+	return 0;
+
+err_out_put:
+	t->result = err;
+	netfs_trans_put(t);
+err_out_remove:
+	pohmelfs_write_inode_remove_children(inode);
+
+	return err;
+}
+
+/*
+ * It is not exported, sorry...
+ */
+static inline wait_queue_head_t *page_waitqueue(struct page *page)
+{
+	const struct zone *zone = page_zone(page);
+
+	return &zone->wait_table[hash_ptr(page, zone->wait_table_bits)];
+}
+
+static int pohmelfs_wait_on_page_locked(struct page *page)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(page->mapping->host->i_sb);
+	long ret = psb->wait_on_page_timeout;
+	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+	int err = 0;
+
+	if (!PageLocked(page))
+		return 0;
+
+	for (;;) {
+		prepare_to_wait(page_waitqueue(page),
+				&wait.wait, TASK_INTERRUPTIBLE);
+
+		dprintk("%s: page: %p, locked: %d, uptodate: %d, error: %d, flags: %lx.\n",
+				__func__, page, PageLocked(page), PageUptodate(page),
+				PageError(page), page->flags);
+
+		if (!PageLocked(page))
+			break;
+
+		if (!signal_pending(current)) {
+			ret = schedule_timeout(ret);
+			if (!ret)
+				break;
+			continue;
+		}
+		ret = -ERESTARTSYS;
+		break;
+	}
+	finish_wait(page_waitqueue(page), &wait.wait);
+
+	if (!ret)
+		err = -ETIMEDOUT;
+
+
+	if (!err)
+		SetPageUptodate(page);
+
+	dprintk("%s: page: %p, uptodate: %d, locked: %d, err: %d.\n",
+			__func__, page, PageUptodate(page), PageLocked(page), err);
+
+	return err;
+}
+
+static int pohmelfs_read_page_complete(struct page **pages, unsigned int page_num,
+		void *private, int err)
+{
+	struct page *page = private;
+	
+	if (PageChecked(page))
+		return err;
+
+	if (err < 0)
+		SetPageError(page);
+
+	unlock_page(page);
+
+	return err;
+}
+
+/*
+ * Read a page from remote server.
+ * Function will wait until page is unlocked.
+ */
+static int pohmelfs_readpage(struct file *file, struct page *page)
+{
+	struct inode *inode = page->mapping->host;
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	struct netfs_trans *t;
+	struct netfs_cmd *cmd;
+	int err, path_len;
+	void *data;
+
+	mutex_lock(&psb->path_lock);
+	path_len = pohmelfs_path_length(pi);
+	mutex_unlock(&psb->path_lock);
+
+	if (path_len < 0) {
+		err = path_len;
+		goto err_out_exit;
+	}
+
+	t = netfs_trans_alloc(psb, path_len, NETFS_TRANS_SINGLE_DST, 0);
+	if (!t) {
+		err = -ENOMEM;
+		goto err_out_exit;
+	}
+
+	t->complete = pohmelfs_read_page_complete;
+	t->private = page;
+
+	cmd = netfs_trans_current(t);
+	data = (void *)(cmd + 1);
+
+	mutex_lock(&psb->path_lock);
+	err = pohmelfs_construct_path_string(pi, data, path_len);
+	mutex_unlock(&psb->path_lock);
+	if (err < 0)
+		goto err_out_free;
+
+	path_len = err + 1;
+
+	cmd->id = pi->ino;
+	cmd->start = page->index;
+	cmd->start <<= PAGE_CACHE_SHIFT;
+	cmd->size = PAGE_CACHE_SIZE + path_len;
+	cmd->cmd = NETFS_READ_PAGE;
+	cmd->ext = path_len;
+
+	dprintk("%s: path: '%s', page: %p, ino: %llu, start: %llu, size: %lu.\n",
+			__func__, (char *)data, page, pi->ino, cmd->start, PAGE_CACHE_SIZE);
+
+	netfs_convert_cmd(cmd);
+	netfs_trans_update(cmd, t, path_len);
+
+	err = netfs_trans_finish(t, psb);
+	if (err)
+		goto err_out_return;
+
+	return pohmelfs_wait_on_page_locked(page);
+
+err_out_free:
+	t->result = err;
+	netfs_trans_put(t);
+err_out_exit:
+	SetPageError(page);
+	if (PageLocked(page))
+		unlock_page(page);
+err_out_return:
+	printk("%s: page: %p, start: %lu, size: %lu, err: %d.\n",
+		__func__, page, page->index << PAGE_CACHE_SHIFT, PAGE_CACHE_SIZE, err);
+
+	return err;
+}
+
+/*
+ * Write begin/end magic.
+ * Allocates a page and writes inode if it was not synced to server before.
+ */
+static int pohmelfs_write_begin(struct file *file, struct address_space *mapping,
+		loff_t pos, unsigned len, unsigned flags,
+		struct page **pagep, void **fsdata)
+{
+	struct inode *inode = mapping->host;
+	struct page *page;
+	pgoff_t index;
+	unsigned start, end;
+	int err;
+
+	*pagep = NULL;
+
+	index = pos >> PAGE_CACHE_SHIFT;
+	start = pos & (PAGE_CACHE_SIZE - 1);
+	end = start + len;
+
+	page = __grab_cache_page(mapping, index);
+
+	dprintk("%s: page: %p pos: %llu, len: %u, index: %lu, start: %u, end: %u, uptodate: %d.\n",
+			__func__, page,	pos, len, index, start, end, PageUptodate(page));
+
+	if (!page) {
+		err = -ENOMEM;
+		goto err_out_exit;
+	}
+
+	while (!PageUptodate(page)) {
+		if (start && test_bit(NETFS_INODE_CREATED, &POHMELFS_I(inode)->state)) {
+			err = pohmelfs_readpage(file, page);
+			if (err)
+				goto err_out_exit;
+
+			lock_page(page);
+			continue;
+		}
+
+		if (len != PAGE_CACHE_SIZE) {
+			void *kaddr = kmap_atomic(page, KM_USER0);
+
+			memset(kaddr + start, 0, PAGE_CACHE_SIZE - start);
+			flush_dcache_page(page);
+			kunmap_atomic(kaddr, KM_USER0);
+		}
+		SetPageUptodate(page);
+	}
+
+	set_page_private(page, end);
+
+	*pagep = page;
+
+	return 0;
+
+err_out_exit:
+	page_cache_release(page);
+	*pagep = NULL;
+
+	return err;
+}
+
+static int pohmelfs_write_end(struct file *file, struct address_space *mapping,
+			loff_t pos, unsigned len, unsigned copied,
+			struct page *page, void *fsdata)
+{
+	struct inode *inode = mapping->host;
+
+	if (copied != len) {
+		unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+		void *kaddr = kmap_atomic(page, KM_USER0);
+
+		memset(kaddr + from + copied, 0, len - copied);
+		flush_dcache_page(page);
+		kunmap_atomic(kaddr, KM_USER0);
+	}
+
+	SetPageUptodate(page);
+	set_page_dirty(page);
+
+	dprintk("%s: page: %p [U: %d, D: %d, L: %d], pos: %llu, len: %u, copied: %u.\n",
+			__func__, page,
+			PageUptodate(page), PageDirty(page), PageLocked(page),
+			pos, len, copied);
+
+	flush_dcache_page(page);
+
+	unlock_page(page);
+	page_cache_release(page);
+
+	if (pos + copied > inode->i_size) {
+		i_size_write(inode, pos + copied);
+#if 0
+		if (test_bit(NETFS_INODE_CREATED, &POHMELFS_I(inode)->state)) {
+			int err = pohmelfs_meta_command(POHMELFS_I(inode), NETFS_INODE_INFO,
+				0, NULL, NULL, 0);
+			if (err)
+				return err;
+		}
+#endif
+	}
+
+	return copied;
+}
+
+static int pohmelfs_readpages_trans_complete(struct page **__pages, unsigned int page_num,
+		void *private, int err)
+{
+	struct pohmelfs_inode *pi = private;
+	unsigned int i, num;
+	struct page **pages, *page = (struct page *)__pages;
+	loff_t index = page->index;
+
+	pages = kzalloc(sizeof(void *) * page_num, GFP_NOIO);
+	if (!pages)
+		return -ENOMEM;
+
+	num = find_get_pages_contig(pi->vfs_inode.i_mapping, index, page_num, pages);
+	if (num <= 0) {
+		err = num;
+		goto err_out_free;
+	}
+
+	for (i=0; i<num; ++i) {
+		page = pages[i];
+
+		if (err)
+			printk("%s: %u/%u: page: %p, index: %lu, uptodate: %d, locked: %d, err: %d.\n",
+				__func__, i, num, page, page->index,
+				PageUptodate(page), PageLocked(page), err);
+
+		if (!PageChecked(page)) {
+			if (err < 0)
+				SetPageError(page);
+			unlock_page(page);
+		}
+		page_cache_release(page);
+	}
+
+err_out_free:
+	kfree(pages);
+	return err;
+}
+
+static int pohmelfs_send_readpages(struct pohmelfs_inode *pi, struct page *first, unsigned int num)
+{
+	struct netfs_trans *t;
+	struct netfs_cmd *cmd;
+	struct pohmelfs_sb *psb = POHMELFS_SB(pi->vfs_inode.i_sb);
+	int err, path_len;
+	void *data;
+
+	mutex_lock(&psb->path_lock);
+	path_len = pohmelfs_path_length(pi);
+	mutex_unlock(&psb->path_lock);
+
+	if (path_len < 0) {
+		err = path_len;
+		goto err_out_exit;
+	}
+
+	t = netfs_trans_alloc(psb, path_len, NETFS_TRANS_SINGLE_DST, 0);
+	if (!t) {
+		err = -ENOMEM;
+		goto err_out_exit;
+	}
+
+	cmd = netfs_trans_current(t);
+	data = (void *)(cmd + 1);
+
+	t->complete = pohmelfs_readpages_trans_complete;
+	t->private = pi;
+	t->page_num = num;
+	t->pages = (struct page **)first;
+
+	mutex_lock(&psb->path_lock);
+	err = pohmelfs_construct_path_string(pi, data, path_len);
+	mutex_unlock(&psb->path_lock);
+	if (err < 0)
+		goto err_out_put;
+
+	path_len = err + 1;
+
+	cmd->cmd = NETFS_READ_PAGES;
+	cmd->start = first->index;
+	cmd->start <<= PAGE_CACHE_SHIFT;
+	cmd->size = (num << 8 | PAGE_CACHE_SHIFT);
+	cmd->id = pi->ino;
+	cmd->ext = path_len;
+
+	dprintk("%s: t: %p, gen: %u, path: '%s', path_len: %u, "
+			"start: %lu, num: %u.\n",
+			__func__, t, t->gen, (char *)data, path_len,
+			first->index, num);
+
+	netfs_convert_cmd(cmd);
+	netfs_trans_update(cmd, t, path_len);
+
+	return netfs_trans_finish(t, psb);
+
+err_out_put:
+	netfs_trans_free(t);
+err_out_exit:
+	pohmelfs_readpages_trans_complete((struct page **)first, num, pi, err);
+	return err;
+}
+
+#define list_to_page(head) (list_entry((head)->prev, struct page, lru))
+
+static int pohmelfs_readpages(struct file *file, struct address_space *mapping,
+			struct list_head *pages, unsigned nr_pages)
+{
+	unsigned int page_idx, num = 0;
+	struct page *page = NULL, *first = NULL;
+
+	for (page_idx = 0; page_idx < nr_pages; page_idx++) {
+		page = list_to_page(pages);
+
+		prefetchw(&page->flags);
+		list_del(&page->lru);
+
+		if (!add_to_page_cache_lru(page, mapping,
+					page->index, GFP_KERNEL)) {
+
+			if (!num) {
+				num = 1;
+				first = page;
+				page_cache_release(page);
+				continue;
+			}
+
+			dprintk("%s: added to lru page: %p, page_index: %lu, first_index: %lu.\n",
+					__func__, page, page->index, first->index);
+
+			if (unlikely(first->index + num != page->index) || (num > 500)) {
+				pohmelfs_send_readpages(POHMELFS_I(mapping->host),
+						first, num);
+				first = page;
+				num = 0;
+			}
+
+			num++;
+		}
+		page_cache_release(page);
+	}
+	pohmelfs_send_readpages(POHMELFS_I(mapping->host), first, num);
+
+	/*
+	 * This will be sync read, so when last page is processed,
+	 * all previous are alerady unlocked and ready to be used.
+	 */
+	return 0;
+}
+
+/*
+ * Small addres space operations for POHMELFS.
+ */
+const struct address_space_operations pohmelfs_aops = {
+	.readpage		= pohmelfs_readpage,
+	.readpages		= pohmelfs_readpages,
+	.writepages		= pohmelfs_writepages,
+	.write_begin		= pohmelfs_write_begin,
+	.write_end		= pohmelfs_write_end,
+	.set_page_dirty 	= __set_page_dirty_nobuffers,
+};
+
+static atomic_t inodes_allocated = ATOMIC_INIT(0);
+static atomic_t inodes_destroyed = ATOMIC_INIT(0);
+
+/*
+ * ->detroy_inode() callback. Deletes inode from the caches
+ *  and frees private data.
+ */
+static void pohmelfs_destroy_inode(struct inode *inode)
+{
+	struct super_block *sb = inode->i_sb;
+	struct pohmelfs_sb *psb = POHMELFS_SB(sb);
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+
+	pohmelfs_inode_del_inode(psb, pi);
+#ifdef POHMELFS_CC_GROUP
+	pohmelfs_meta_command(pi, NETFS_LEAVE_GROUP, 0, NULL, NULL, 0);
+#endif
+
+	dprintk("%s: pi: %p, inode: %p, ino: %llu.\n",
+		__func__, pi, &pi->vfs_inode, pi->ino);
+	kmem_cache_free(pohmelfs_inode_cache, pi);
+	atomic_inc(&inodes_destroyed);
+}
+
+/*
+ * ->alloc_inode() callback. Allocates inode and initilizes private data.
+ */
+static struct inode *pohmelfs_alloc_inode(struct super_block *sb)
+{
+	struct pohmelfs_inode *pi;
+
+	pi = kmem_cache_alloc(pohmelfs_inode_cache, GFP_NOIO);
+	if (!pi)
+		return NULL;
+
+	pi->offset_root = RB_ROOT;
+	pi->hash_root = RB_ROOT;
+	mutex_init(&pi->offset_lock);
+
+	INIT_LIST_HEAD(&pi->sync_del_list);
+	INIT_LIST_HEAD(&pi->sync_create_list);
+
+	INIT_LIST_HEAD(&pi->inode_entry);
+
+	pi->state = 0;
+	pi->total_len = 0;
+	pi->drop_count = 0;
+
+	dprintk("%s: pi: %p, inode: %p.\n", __func__, pi, &pi->vfs_inode);
+
+	atomic_inc(&inodes_allocated);
+
+	return &pi->vfs_inode;
+}
+
+/*
+ * We want fsync() to work on POHMELFS.
+ */
+static int pohmelfs_fsync(struct file *file, struct dentry *dentry, int datasync)
+{
+	struct inode *inode = file->f_mapping->host;
+	struct writeback_control wbc = {
+		.sync_mode = WB_SYNC_ALL,
+		.nr_to_write = 0,	/* sys_fsync did this */
+	};
+
+	return sync_inode(inode, &wbc);
+}
+
+const static struct file_operations pohmelfs_file_ops = {
+	.open		= generic_file_open,
+	.fsync		= pohmelfs_fsync,
+
+	.llseek		= generic_file_llseek,
+
+	.read		= do_sync_read,
+	.aio_read	= generic_file_aio_read,
+
+	.mmap		= generic_file_mmap,
+
+	.splice_read	= generic_file_splice_read,
+	.splice_write	= generic_file_splice_write,
+
+	.write		= do_sync_write,
+	.aio_write	= generic_file_aio_write,
+};
+
+const struct inode_operations pohmelfs_symlink_inode_operations = {
+	.readlink	= generic_readlink,
+	.follow_link	= page_follow_link_light,
+	.put_link	= page_put_link,
+};
+
+int pohmelfs_setattr_raw(struct inode *inode, struct iattr *attr)
+{
+	int err;
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+
+	err = inode_change_ok(inode, attr);
+	if (err)
+		goto err_out_exit;
+
+	if ((attr->ia_valid & ATTR_UID && attr->ia_uid != inode->i_uid) ||
+	    (attr->ia_valid & ATTR_GID && attr->ia_gid != inode->i_gid)) {
+		err = DQUOT_TRANSFER(inode, attr) ? -EDQUOT : 0;
+		if (err)
+			goto err_out_exit;
+	}
+
+	err = inode_setattr(inode, attr);
+	if (err)
+		goto err_out_exit;
+
+	if (attr->ia_valid & ATTR_MODE) {
+		mutex_lock(&psb->path_lock);
+		pohmelfs_change_path_entry(psb, pi->ino, inode->i_mode);
+		mutex_unlock(&psb->path_lock);
+	}
+	
+	dprintk("%s: ino: %llu, mode: %o -> %o, uid: %u -> %u, gid: %u -> %u, size: %llu -> %llu.\n",
+			__func__, pi->ino, inode->i_mode, attr->ia_mode,
+			inode->i_uid, attr->ia_uid, inode->i_gid, attr->ia_gid, inode->i_size, attr->ia_size);
+
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+int pohmelfs_setattr(struct dentry *dentry, struct iattr *attr)
+{
+	struct inode *inode = dentry->d_inode;
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	int err;
+
+	err = security_inode_setattr(dentry, attr);
+	if (err)
+		goto err_out_exit;
+
+	err = pohmelfs_setattr_raw(inode, attr);
+	if (err)
+		goto err_out_exit;
+
+	if (!test_bit(NETFS_INODE_CREATED, &pi->state))
+		return 0;
+
+	err = pohmelfs_meta_command(pi, NETFS_INODE_INFO, 0, NULL, NULL, 0);
+	if (err)
+		return err;
+
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+const struct inode_operations pohmelfs_file_inode_operations = {
+	.setattr	= pohmelfs_setattr,
+};
+
+/*
+ * Fill inode data: mode, size, operation callbacks and so on...
+ */
+void pohmelfs_fill_inode(struct inode *inode, struct netfs_inode_info *info)
+{
+	inode->i_mode = info->mode;
+	inode->i_nlink = info->nlink;
+	inode->i_uid = info->uid;
+	inode->i_gid = info->gid;
+	inode->i_blocks = info->blocks;
+	inode->i_rdev = info->rdev;
+	inode->i_size = info->size;
+	inode->i_version = info->version;
+	inode->i_blkbits = ffs(info->blocksize);
+
+	dprintk("%s: inode: %p, num: %lu/%llu inode is regular: %d, dir: %d, link: %d, mode: %o, size: %llu.\n",
+			__func__, inode, inode->i_ino, info->ino,
+			S_ISREG(inode->i_mode), S_ISDIR(inode->i_mode),
+			S_ISLNK(inode->i_mode), inode->i_mode, inode->i_size);
+
+	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME_SEC;
+
+	/*
+	 * i_mapping is a pointer to i_data during inode initialization.
+	 */
+	inode->i_data.a_ops = &pohmelfs_aops;
+
+	if (S_ISREG(inode->i_mode)) {
+		inode->i_fop = &pohmelfs_file_ops;
+		inode->i_op = &pohmelfs_file_inode_operations;
+	} else if (S_ISDIR(inode->i_mode)) {
+		inode->i_fop = &pohmelfs_dir_fops;
+		inode->i_op = &pohmelfs_dir_inode_ops;
+	} else if (S_ISLNK(inode->i_mode)) {
+		inode->i_op = &pohmelfs_symlink_inode_operations;
+		inode->i_fop = &pohmelfs_file_ops;
+	} else {
+		inode->i_fop = &generic_ro_fops;
+	}
+}
+
+static void pohmelfs_drop_inode(struct inode *inode)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+
+	spin_lock(&psb->ino_lock);
+	list_del_init(&pi->inode_entry);
+	spin_unlock(&psb->ino_lock);
+
+	generic_drop_inode(inode);
+}
+
+static struct pohmelfs_inode *pohmelfs_get_inode_from_list(struct pohmelfs_sb *psb,
+		struct list_head *head, unsigned int *count)
+{
+	struct pohmelfs_inode *pi = NULL;
+
+	spin_lock(&psb->ino_lock);
+	if (!list_empty(head)) {
+		pi = list_entry(head->next, struct pohmelfs_inode,
+					inode_entry);
+		list_del_init(&pi->inode_entry);
+		*count = pi->drop_count;
+		pi->drop_count = 0;
+	}
+	spin_unlock(&psb->ino_lock);
+
+	return pi;
+}
+
+/*
+ * ->put_super() callback. Invoked before superblock is destroyed,
+ *  so it has to clean all private data.
+ */
+static void pohmelfs_put_super(struct super_block *sb)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(sb);
+	struct rb_node *rb_node;
+	struct pohmelfs_path_entry *e;
+	struct pohmelfs_inode *pi;
+	unsigned int count;
+	unsigned int in_drop_list = 0;
+	struct inode *inode, *tmp;
+
+	dprintk("\n%s.\n", __func__);
+
+	psb->trans_scan_timeout = psb->drop_scan_timeout = 0;
+	cancel_rearming_delayed_work(&psb->dwork);
+	cancel_rearming_delayed_work(&psb->drop_dwork);
+	flush_scheduled_work();
+	
+	dprintk("\n%s: stopped workqueues.\n", __func__);
+
+	pohmelfs_state_exit(psb);
+
+	while ((pi = pohmelfs_get_inode_from_list(psb, &psb->drop_list, &count))) {
+		inode = &pi->vfs_inode;
+
+		dprintk("%s: ino: %llu, pi: %p, inode: %p, count: %u.\n",
+				__func__, pi->ino, pi, inode, count);
+
+		if (atomic_read(&inode->i_count) != count) {
+			printk("%s: ino: %llu, pi: %p, inode: %p, count: %u, i_count: %d.\n",
+					__func__, pi->ino, pi, inode, count,
+					atomic_read(&inode->i_count));
+			count = atomic_read(&inode->i_count);
+			in_drop_list++;
+		}
+
+		while (count--)
+			iput(&pi->vfs_inode);
+	}
+
+	list_for_each_entry_safe(inode, tmp, &sb->s_inodes, i_sb_list) {
+		pi = POHMELFS_I(inode);
+
+		dprintk("%s: ino: %llu, pi: %p, inode: %p, i_count: %u.\n",
+				__func__, pi->ino, pi, inode, atomic_read(&inode->i_count));
+
+		/*
+		 * These are special inodes, they were created during
+		 * directory reading or lookup, and were not bound to dentry,
+		 * so they live here with reference counter being 1 and prevent
+		 * umount from succeed since it believes that they are busy.
+		 */
+		if (atomic_read(&inode->i_count)) {
+			list_del_init(&inode->i_sb_list);
+			iput(inode);
+		}
+	}
+
+	for (rb_node = rb_first(&psb->path_root); rb_node; ) {
+		e = rb_entry(rb_node, struct pohmelfs_path_entry, path_entry);
+		rb_node = rb_next(rb_node);
+
+		pohmelfs_remove_path_entry(psb, e);
+	}
+
+	printk("%s: inodes allocated: %d, destroyed: %d.\n", __func__,
+		atomic_read(&inodes_allocated), atomic_read(&inodes_destroyed));
+
+	pohmelfs_crypto_exit(psb);
+	kfree(psb);
+	sb->s_fs_info = NULL;
+}
+
+static int pohmelfs_remount(struct super_block *sb, int *flags, char *data)
+{
+	*flags |= MS_RDONLY;
+	return 0;
+}
+
+static int pohmelfs_statfs(struct dentry *dentry, struct kstatfs *buf)
+{
+	struct super_block *sb = dentry->d_sb;
+	struct pohmelfs_sb *psb = POHMELFS_SB(sb);
+
+	/*
+	 * There are no filesystem size limits yet.
+	 */
+	memset(buf, 0, sizeof(struct kstatfs));
+
+	buf->f_type = POHMELFS_MAGIC_NUM; /* 'POH.' */
+	buf->f_bsize = sb->s_blocksize;
+	buf->f_files = psb->ino;
+	buf->f_namelen = 255;
+
+	return 0;
+}
+
+static int pohmelfs_show_options(struct seq_file *seq, struct vfsmount *vfs)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(vfs->mnt_sb);
+
+	seq_printf(seq, ",idx=%u", psb->idx);
+	seq_printf(seq, ",trans_scan_timeout=%u", jiffies_to_msecs(psb->trans_scan_timeout));
+	seq_printf(seq, ",drop_scan_timeout=%u", jiffies_to_msecs(psb->drop_scan_timeout));
+	seq_printf(seq, ",wait_on_page_timeout=%u", jiffies_to_msecs(psb->wait_on_page_timeout));
+	seq_printf(seq, ",trans_retries=%u", psb->trans_retries);
+	seq_printf(seq, ",crypto_thread_num=%u", psb->crypto_thread_num);
+	seq_printf(seq, ",trans_max_pages=%u", psb->trans_max_pages);
+	if (psb->crypto_fail_unsupported)
+		seq_printf(seq, ",crypto_fail_unsupported");
+
+	return 0;
+}
+
+static const struct super_operations pohmelfs_sb_ops = {
+	.alloc_inode	= pohmelfs_alloc_inode,
+	.destroy_inode	= pohmelfs_destroy_inode,
+	.drop_inode	= pohmelfs_drop_inode,
+	.write_inode	= pohmelfs_write_inode,
+	.put_super	= pohmelfs_put_super,
+	.remount_fs	= pohmelfs_remount,
+	.statfs		= pohmelfs_statfs,
+	.show_options	= pohmelfs_show_options,
+};
+
+enum {
+	pohmelfs_opt_idx,
+	pohmelfs_opt_trans_scan_timeout,
+	pohmelfs_opt_drop_scan_timeout,
+	pohmelfs_opt_wait_on_page_timeout,
+	pohmelfs_opt_trans_retries,
+	pohmelfs_opt_crypto_thread_num,
+	pohmelfs_opt_trans_max_pages,
+	pohmelfs_opt_crypto_fail_unsupported,
+};
+
+static struct match_token pohmelfs_tokens[] = {
+	{pohmelfs_opt_idx, "idx=%u"},
+	{pohmelfs_opt_trans_scan_timeout, "trans_scan_timeout=%u"},
+	{pohmelfs_opt_drop_scan_timeout, "drop_scan_timeout=%u"},
+	{pohmelfs_opt_wait_on_page_timeout, "wait_on_page_timeout=%u"},
+	{pohmelfs_opt_trans_retries, "trans_retries=%u"},
+	{pohmelfs_opt_crypto_thread_num, "crypto_thread_num=%u"},
+	{pohmelfs_opt_trans_max_pages, "trans_max_pages=%u"},
+	{pohmelfs_opt_crypto_fail_unsupported, "crypto_fail_unsupported"},
+};
+
+static int pohmelfs_parse_options(char *options, struct pohmelfs_sb *psb)
+{
+	char *p;
+	substring_t args[MAX_OPT_ARGS];
+	int option, err;
+
+	if (!options)
+		return 0;
+
+	while ((p = strsep(&options, ",")) != NULL) {
+		int token;
+		if (!*p)
+			continue;
+
+		token = match_token(p, pohmelfs_tokens, args);
+
+		err = match_int(&args[0], &option);
+		if (err)
+			return err;
+
+		switch (token) {
+			case pohmelfs_opt_idx:
+				psb->idx = option;
+				break;
+			case pohmelfs_opt_trans_scan_timeout:
+				psb->trans_scan_timeout = msecs_to_jiffies(option);
+				break;
+			case pohmelfs_opt_drop_scan_timeout:
+				psb->drop_scan_timeout = msecs_to_jiffies(option);
+				break;
+			case pohmelfs_opt_wait_on_page_timeout:
+				psb->wait_on_page_timeout = msecs_to_jiffies(option);
+				break;
+			case pohmelfs_opt_trans_retries:
+				psb->trans_retries = option;
+				break;
+			case pohmelfs_opt_crypto_thread_num:
+				psb->crypto_thread_num = option;
+				break;
+			case pohmelfs_opt_trans_max_pages:
+				psb->trans_max_pages = option;
+				break;
+			case pohmelfs_opt_crypto_fail_unsupported:
+				psb->crypto_fail_unsupported = 1;
+				break;
+			default:
+				return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
+static void pohmelfs_drop_scan(struct work_struct *work)
+{
+	struct pohmelfs_sb *psb =
+		container_of(work, struct pohmelfs_sb, drop_dwork.work);
+	struct pohmelfs_inode *pi;
+	unsigned int count = 0;
+
+	while ((pi = pohmelfs_get_inode_from_list(psb, &psb->drop_list, &count))) {
+		dprintk("%s: ino: %llu, pi: %p, inode: %p, count: %u.\n",
+					__func__, pi->ino, pi, &pi->vfs_inode, count);
+		while (count--)
+			iput(&pi->vfs_inode);
+	}
+	pohmelfs_check_states(psb);
+
+	if (psb->drop_scan_timeout)
+		schedule_delayed_work(&psb->drop_dwork, psb->drop_scan_timeout);
+}
+
+/*
+ * Run through all transactions starting from the oldest,
+ * drop transaction from current state and try to send it
+ * to all remote nodes, which are currently installed.
+ */
+static void pohmelfs_trans_scan_state(struct netfs_state *st)
+{
+	struct rb_node *rb_node;
+	struct netfs_trans_dst *dst;
+	struct pohmelfs_sb *psb = st->psb;
+	unsigned int timeout = psb->trans_scan_timeout;
+	struct netfs_trans *t;
+	int err;
+
+	mutex_lock(&st->trans_lock);
+	for (rb_node = rb_first(&st->trans_root); rb_node; ) {
+		dst = rb_entry(rb_node, struct netfs_trans_dst, state_entry);
+		t = dst->trans;
+
+		if (timeout && time_after(dst->send_time + timeout, jiffies)
+				&& dst->retries == 0)
+			break;
+
+		dprintk("%s: t: %p, gen: %u, st: %p, retries: %u, max: %u.\n",
+			__func__, t, t->gen, st, dst->retries, psb->trans_retries);
+		netfs_trans_get(t);
+
+		rb_node = rb_next(rb_node);
+
+		err = -ETIMEDOUT;
+		if (timeout && (++dst->retries < psb->trans_retries)) {
+			err = netfs_trans_resend(t, psb);
+		}
+
+		if (err || (t->flags & NETFS_TRANS_SINGLE_DST)) {
+			netfs_trans_remove_nolock(dst, st);
+			netfs_trans_drop_dst_nostate(dst);
+		}
+
+		t->result = err;
+		netfs_trans_put(t);
+	}
+	mutex_unlock(&st->trans_lock);
+}
+
+/*
+ * Walk through all installed network states and resend all
+ * transactions, which are old enough.
+ */
+static void pohmelfs_trans_scan(struct work_struct *work)
+{
+	struct pohmelfs_sb *psb =
+		container_of(work, struct pohmelfs_sb, dwork.work);
+	struct netfs_state *st;
+	struct pohmelfs_config *c;
+
+	mutex_lock(&psb->state_lock);
+	list_for_each_entry(c, &psb->state_list, config_entry) {
+		st = &c->state;
+
+		pohmelfs_trans_scan_state(st);
+	}
+	mutex_unlock(&psb->state_lock);
+
+	/*
+	 * If no timeout specified then system is in the middle of umount process,
+	 * so no need to reschedule scanning process again.
+	 */
+	if (psb->trans_scan_timeout)
+		schedule_delayed_work(&psb->dwork, psb->trans_scan_timeout);
+}
+
+int pohmelfs_meta_command_data(struct pohmelfs_inode *pi, unsigned int cmd_op, char *addon,
+		unsigned int flags, netfs_trans_complete_t complete, void *priv, u64 start)
+{
+	struct inode *inode = &pi->vfs_inode;
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	int err, sz, diff;
+	struct netfs_trans *t;
+	unsigned int path_len, addon_len = 0;
+	void *data;
+	struct netfs_inode_info *info;
+	struct netfs_cmd *cmd;
+
+	dprintk("%s: ino: %llu, cmd: %u, addon: %p.\n", __func__, pi->ino, cmd_op, addon);
+	
+	mutex_lock(&psb->path_lock);
+	sz = path_len = pohmelfs_path_length(pi);
+	mutex_unlock(&psb->path_lock);
+
+	if (path_len < 0) {
+		err = path_len;
+		goto err_out_exit;
+	}
+
+	if (addon)
+		addon_len = strlen(addon) + 1; /* 0-byte */
+	sz += addon_len;
+
+	if (cmd_op == NETFS_INODE_INFO)
+		sz += sizeof(struct netfs_inode_info);
+
+	t = netfs_trans_alloc(psb, sz, flags, 0);
+	if (!t) {
+		err = -ENOMEM;
+		goto err_out_exit;
+	}
+	t->complete = complete;
+	t->private = priv;
+
+	cmd = netfs_trans_current(t);
+	data = (void *)(cmd + 1);
+
+	if (cmd_op == NETFS_INODE_INFO) {
+		info = (struct netfs_inode_info *)(cmd + 1);
+		data = (void *)(info + 1);
+
+		/*
+		 * We are under i_mutex, can read and change whatever we want...
+		 */
+		info->mode = inode->i_mode;
+		info->nlink = inode->i_nlink;
+		info->uid = inode->i_uid;
+		info->gid = inode->i_gid;
+		info->blocks = inode->i_blocks;
+		info->rdev = inode->i_rdev;
+		info->size = inode->i_size;
+		info->version = inode->i_version;
+
+		netfs_convert_inode_info(info);
+	}
+
+	mutex_lock(&psb->path_lock);
+	err = pohmelfs_construct_path_string(pi, data, path_len);
+	mutex_unlock(&psb->path_lock);
+	if (err < 0)
+		goto err_out_free;
+
+	dprintk("%s: err: %d, path_len: %d.\n", __func__, err, path_len);
+
+	diff = err + 1 - path_len;
+	sz += diff;
+	path_len += diff;
+
+	if (addon)
+		path_len += sprintf(data + err, "/%s", addon) + 1 /* 0 - byte */;
+
+	cmd->cmd = cmd_op;
+	cmd->ext = path_len;
+	cmd->size = sz;
+	cmd->id = pi->ino;
+	cmd->start = start;
+
+	netfs_convert_cmd(cmd);
+	netfs_trans_update(cmd, t, sz);
+
+	/*
+	 * Note, that it is possible to leak error here: transaction callback will not
+	 * be invoked for allocation path failure.
+	 */
+	return netfs_trans_finish(t, psb);
+
+err_out_free:
+	netfs_trans_free(t);
+err_out_exit:
+	if (complete)
+		complete(NULL, 0, priv, err);
+	return err;
+}
+
+int pohmelfs_meta_command(struct pohmelfs_inode *pi, unsigned int cmd_op, unsigned int flags,
+		netfs_trans_complete_t complete, void *priv, u64 start)
+{
+	return pohmelfs_meta_command_data(pi, cmd_op, NULL, flags, complete, priv, start);
+}
+
+/*
+ * Allocate private superblock and create root dir.
+ */
+static int pohmelfs_fill_super(struct super_block *sb, void *data, int silent)
+{
+	struct pohmelfs_sb *psb;
+	int err = -ENOMEM;
+	struct inode *root;
+	struct pohmelfs_inode *npi;
+	struct qstr str;
+
+	psb = kzalloc(sizeof(struct pohmelfs_sb), GFP_NOIO);
+	if (!psb)
+		goto err_out_exit;
+
+	sb->s_fs_info = psb;
+	sb->s_op = &pohmelfs_sb_ops;
+	sb->s_magic = POHMELFS_MAGIC_NUM;
+	sb->s_maxbytes = MAX_LFS_FILESIZE;
+
+	psb->sb = sb;
+	psb->path_root = RB_ROOT;
+
+	psb->ino = 2;
+	psb->idx = 0;
+	psb->active_state = NULL;
+	psb->trans_retries = 5;
+	psb->trans_data_size = PAGE_SIZE;
+	psb->drop_scan_timeout = msecs_to_jiffies(1000);
+	psb->trans_scan_timeout = msecs_to_jiffies(5000);
+	psb->wait_on_page_timeout = msecs_to_jiffies(5000);
+	init_waitqueue_head(&psb->wait);
+
+	spin_lock_init(&psb->ino_lock);
+
+	mutex_init(&psb->path_lock);
+	INIT_LIST_HEAD(&psb->drop_list);
+
+	psb->trans_max_pages = 100;
+
+	psb->crypto_align_size = 16;
+	psb->crypto_attached_size = 0;
+	psb->hash_strlen = 0;
+	psb->cipher_strlen = 0;
+	psb->perform_crypto = 0;
+	psb->crypto_thread_num = 2;
+	psb->crypto_fail_unsupported = 0;
+	mutex_init(&psb->crypto_thread_lock);
+	INIT_LIST_HEAD(&psb->crypto_ready_list);
+	INIT_LIST_HEAD(&psb->crypto_active_list);
+
+	atomic_set(&psb->trans_gen, 1);
+
+	mutex_init(&psb->state_lock);
+	INIT_LIST_HEAD(&psb->state_list);
+
+	err = pohmelfs_parse_options((char *) data, psb);
+	if (err)
+		goto err_out_free_sb;
+
+	err = pohmelfs_copy_crypto(psb);
+	if (err)
+		goto err_out_free_sb;
+
+	err = pohmelfs_state_init(psb);
+	if (err)
+		goto err_out_free_strings;
+
+	err = pohmelfs_crypto_init(psb);
+	if (err)
+		goto err_out_state_exit;
+
+	str.name = "/";
+	str.hash = jhash("/", 1, 0);
+	str.len = 1;
+
+	npi = pohmelfs_create_entry_local(psb, NULL, &str, 0, 0755|S_IFDIR);
+	if (IS_ERR(npi)) {
+		err = PTR_ERR(npi);
+		goto err_out_crypto_exit;
+	}
+	set_bit(NETFS_INODE_CREATED, &npi->state);
+	clear_bit(NETFS_INODE_REMOTE_SYNCED, &npi->state);
+
+	root = &npi->vfs_inode;
+
+	sb->s_root = d_alloc_root(root);
+	if (!sb->s_root)
+		goto err_out_put_root;
+	
+	INIT_DELAYED_WORK(&psb->drop_dwork, pohmelfs_drop_scan);
+	schedule_delayed_work(&psb->drop_dwork, psb->drop_scan_timeout);
+
+	INIT_DELAYED_WORK(&psb->dwork, pohmelfs_trans_scan);
+	schedule_delayed_work(&psb->dwork, psb->trans_scan_timeout);
+
+	return 0;
+
+err_out_put_root:
+	iput(root);
+err_out_crypto_exit:
+	pohmelfs_crypto_exit(psb);
+err_out_state_exit:
+	pohmelfs_state_exit(psb);
+err_out_free_strings:
+	kfree(psb->cipher_string);
+	kfree(psb->hash_string);
+err_out_free_sb:
+	kfree(psb);
+err_out_exit:
+
+	dprintk("%s: err: %d.\n", __func__, err);
+	return err;
+}
+
+/*
+ * Some VFS magic here...
+ */
+static int pohmelfs_get_sb(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
+{
+	return get_sb_nodev(fs_type, flags, data, pohmelfs_fill_super,
+				mnt);
+}
+
+static struct file_system_type pohmel_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "pohmel",
+	.get_sb		= pohmelfs_get_sb,
+	.kill_sb 	= kill_anon_super,
+};
+
+/*
+ * Cache and module initializations and freeing routings.
+ */
+static void pohmelfs_init_once(struct kmem_cache *cachep, void *data)
+{
+	struct pohmelfs_inode *inode = data;
+
+	inode_init_once(&inode->vfs_inode);
+}
+
+static int pohmelfs_init_inodecache(void)
+{
+	pohmelfs_inode_cache = kmem_cache_create("pohmelfs_inode_cache",
+				sizeof(struct pohmelfs_inode),
+				0, (SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD),
+				pohmelfs_init_once);
+	if (!pohmelfs_inode_cache)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void pohmelfs_destroy_inodecache(void)
+{
+	kmem_cache_destroy(pohmelfs_inode_cache);
+}
+
+static int __init init_pohmel_fs(void)
+{
+	int err;
+
+	err = pohmelfs_config_init();
+	if (err)
+		goto err_out_exit;
+
+	err = pohmelfs_init_inodecache();
+	if (err)
+		goto err_out_config_exit;
+
+	err = netfs_trans_init();
+	if (err)
+		goto err_out_destroy;
+
+	err = register_filesystem(&pohmel_fs_type);
+	if (err)
+		goto err_out_trans;
+
+	return 0;
+
+err_out_trans:
+	netfs_trans_exit();
+err_out_destroy:
+	pohmelfs_destroy_inodecache();
+err_out_config_exit:
+	pohmelfs_config_exit();
+err_out_exit:
+	return err;
+}
+
+static void __exit exit_pohmel_fs(void)
+{
+        unregister_filesystem(&pohmel_fs_type);
+	pohmelfs_destroy_inodecache();
+	pohmelfs_config_exit();
+	netfs_trans_exit();
+}
+
+module_init(init_pohmel_fs);
+module_exit(exit_pohmel_fs);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
+MODULE_DESCRIPTION("Pohmel filesystem");
diff --git a/fs/pohmelfs/net.c b/fs/pohmelfs/net.c
new file mode 100644
index 0000000..7610bce
--- /dev/null
+++ b/fs/pohmelfs/net.c
@@ -0,0 +1,1059 @@
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
+#include <linux/fsnotify.h>
+#include <linux/jhash.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/kthread.h>
+#include <linux/pagemap.h>
+#include <linux/poll.h>
+#include <linux/swap.h>
+#include <linux/syscalls.h>
+
+#include "netfs.h"
+
+/*
+ * Async machinery lives here.
+ * All commands being sent to server do _not_ require sync reply,
+ * instead, if it is really needed, like readdir or readpage, caller
+ * sleeps waiting for data, which will be placed into provided buffer
+ * and caller will be awakened.
+ *
+ * Every command response can come without some listener. For example
+ * readdir response will add new objects into cache without appropriate
+ * request from userspace. This is used in cache coherency.
+ *
+ * If object is not found for given data, it is discarded.
+ *
+ * All requests are received by dedicated kernel thread.
+ */
+
+/*
+ * Basic network sending/receiving functions.
+ * Blocked mode is used.
+ */
+static int netfs_data_recv(struct netfs_state *st, void *buf, u64 size)
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
+		printk("%s: failed to recv data: size: %llu, err: %d.\n", __func__, size, err);
+		if (err == 0)
+			err = -ECONNRESET;
+
+		netfs_state_exit(st);
+	}
+
+	return err;
+}
+
+static int pohmelfs_data_recv(struct netfs_state *st, void *data, unsigned int size)
+{
+	unsigned int revents = 0;
+	unsigned int err_mask = POLLERR | POLLHUP | POLLRDHUP;
+	unsigned int mask = err_mask | POLLIN;
+	int err = 0;
+
+	while (size && !err) {
+		revents = netfs_state_poll(st);
+
+		if (!(revents & mask)) {
+			DEFINE_WAIT(wait);
+
+			for (;;) {
+				prepare_to_wait(&st->thread_wait, &wait, TASK_INTERRUPTIBLE);
+				if (kthread_should_stop())
+					break;
+
+				revents = netfs_state_poll(st);
+
+				if (revents & mask)
+					break;
+
+				if (signal_pending(current))
+					break;
+
+				schedule();
+				continue;
+			}
+			finish_wait(&st->thread_wait, &wait);
+		}
+
+		err = -ECONNRESET;
+		netfs_state_lock(st);
+
+		if (st->socket && (st->read_socket == st->socket) && (revents & POLLIN)) {
+			err = netfs_data_recv(st, data, size);
+			if (err > 0) {
+				data += err;
+				size -= err;
+				err = 0;
+			}
+		}
+
+		if (revents & err_mask) {
+			printk("%s: revents: %x, socket: %p, size: %u, err: %d.\n",
+					__func__, revents, st->socket, size, err);
+			netfs_state_exit(st);
+			err = -ECONNRESET;
+		}
+
+		if (!st->socket) {
+			err = netfs_state_init(st);
+			if (!err)
+				err = -EAGAIN;
+		}
+
+		netfs_state_unlock(st);
+
+		if (kthread_should_stop())
+			err = -ENODEV;
+
+		if (err)
+			printk("%s: socket: %p, read_socket: %p, revents: %x, rev_error: %d, "
+					"should_stop: %d, size: %u, err: %d.\n",
+				__func__, st->socket, st->read_socket,
+				revents, revents & err_mask, kthread_should_stop(), size, err);
+	}
+
+	return err;
+}
+
+static int pohmelfs_data_recv_and_check(struct netfs_state *st, void *data, unsigned int size)
+{
+	struct netfs_cmd *cmd = &st->cmd;
+	int err;
+	
+	err = pohmelfs_data_recv(st, data, size);
+	if (err)
+		return err;
+	
+	return pohmelfs_crypto_process_input_data(&st->eng, cmd->iv, data, NULL, size);
+}
+
+/*
+ * Polling machinery.
+ */
+
+struct netfs_poll_helper
+{
+	poll_table 		pt;
+	struct netfs_state	*st;
+};
+
+static int netfs_queue_wake(wait_queue_t *wait, unsigned mode, int sync, void *key)
+{
+	struct netfs_state *st = container_of(wait, struct netfs_state, wait);
+
+	wake_up(&st->thread_wait);
+	return 1;
+}
+
+static void netfs_queue_func(struct file *file, wait_queue_head_t *whead,
+				 poll_table *pt)
+{
+	struct netfs_state *st = container_of(pt, struct netfs_poll_helper, pt)->st;
+
+	st->whead = whead;
+	init_waitqueue_func_entry(&st->wait, netfs_queue_wake);
+	add_wait_queue(whead, &st->wait);
+}
+
+static void netfs_poll_exit(struct netfs_state *st)
+{
+	if (st->whead) {
+		remove_wait_queue(st->whead, &st->wait);
+		st->whead = NULL;
+	}
+}
+
+static int netfs_poll_init(struct netfs_state *st)
+{
+	struct netfs_poll_helper ph;
+
+	ph.st = st;
+	init_poll_funcptr(&ph.pt, &netfs_queue_func);
+
+	st->socket->ops->poll(NULL, st->socket, &ph.pt);
+	return 0;
+}
+
+/*
+ * Get response for readpage command. We search inode and page in its mapping
+ * and copy data into. If it was async request, then we queue page into shared
+ * data and wakeup listener, who will copy it to userspace.
+ *
+ * There is a work in progress of allowing to call copy_to_user() directly from
+ * async receiving kernel thread.
+ */
+static int pohmelfs_read_page_response(struct netfs_state *st)
+{
+	struct pohmelfs_sb *psb = st->psb;
+	struct netfs_cmd *cmd = &st->cmd;
+	struct inode *inode;
+	struct page *page;
+	void *addr;
+	int err = 0;
+
+	if (cmd->size > PAGE_CACHE_SIZE) {
+		err = -EINVAL;
+		goto err_out_exit;
+	}
+
+	if (!cmd->size)
+		goto err_out_exit;
+
+	inode = ilookup(st->psb->sb, cmd->id);
+	if (!inode) {
+		printk("%s: failed to find inode: id: %llu.\n", __func__, cmd->id);
+		err = -ENOENT;
+		goto err_out_exit;
+	}
+
+	page = find_get_page(inode->i_mapping, cmd->start >> PAGE_CACHE_SHIFT);
+	if (!page || !PageLocked(page)) {
+		printk("%s: failed to find/lock page: page: %p, id: %llu, start: %llu, index: %llu.\n",
+				__func__, page, cmd->id, cmd->start, cmd->start >> PAGE_CACHE_SHIFT);
+
+		while (cmd->size) {
+			unsigned int sz = min(cmd->size, st->size);
+
+			err = pohmelfs_data_recv(st, st->data, sz);
+			if (err)
+				break;
+
+			cmd->size -= sz;
+		}
+
+		err = -ENODEV;
+		if (page)
+			goto err_out_page_put;
+		goto err_out_put;
+	}
+
+	addr = kmap(page);
+	err = pohmelfs_data_recv(st, addr, cmd->size);
+	kunmap(page);
+
+	if (err)
+		goto err_out_page_unlock;
+
+	dprintk("%s: page: %p, start: %llu, size: %u, locked: %d.\n",
+		__func__, page, cmd->start, cmd->size, PageLocked(page));
+
+	SetPageChecked(page);
+	if ((psb->hash_string || psb->cipher_string) && psb->perform_crypto) {
+		err = pohmelfs_crypto_process_input_page(&st->eng, page, cmd->size, cmd->iv);
+		if (err < 0)
+			goto err_out_page_unlock;
+	} else {
+		SetPageUptodate(page);
+		unlock_page(page);
+		page_cache_release(page);
+	}
+
+	pohmelfs_put_inode(POHMELFS_I(inode));
+	wake_up(&st->psb->wait);
+
+	return 0;
+
+err_out_page_unlock:
+	SetPageError(page);
+	unlock_page(page);
+err_out_page_put:
+	page_cache_release(page);
+err_out_put:
+	pohmelfs_put_inode(POHMELFS_I(inode));
+err_out_exit:
+	wake_up(&st->psb->wait);
+	return err;
+}
+
+/*
+ * Readdir response from server. If special field is set, we wakeup
+ * listener (readdir() call), which will copy data to userspace.
+ */
+static int pohmelfs_readdir_response(struct netfs_state *st)
+{
+	struct inode *inode;
+	struct netfs_cmd *cmd = &st->cmd;
+	struct netfs_inode_info *info;
+	struct pohmelfs_inode *parent = NULL, *npi;
+	int err = 0, last = cmd->ext;
+	struct qstr str;
+
+	if (cmd->size > st->size)
+		return -EINVAL;
+
+	inode = ilookup(st->psb->sb, cmd->id);
+	if (!inode)
+		return -ENOENT;
+	parent = POHMELFS_I(inode);
+
+	if (!cmd->size && cmd->start) {
+		err = -cmd->start;
+		goto out;
+	}
+
+	if (cmd->size) {
+		err = pohmelfs_data_recv_and_check(st, st->data, cmd->size);
+		if (err)
+			goto err_out_put;
+
+		info = (struct netfs_inode_info *)(st->data);
+
+		str.name = (char *)(info + 1);
+		str.len = cmd->size - sizeof(struct netfs_inode_info) - 1 - cmd->cpad;
+		str.hash = jhash(str.name, str.len, 0);
+
+		netfs_convert_inode_info(info);
+
+		info->ino = cmd->start;
+		if (!info->ino)
+			info->ino = pohmelfs_new_ino(st->psb);
+
+		dprintk("%s: parent: %llu, ino: %llu, name: '%s', hash: %x, len: %u, mode: %o.\n",
+				__func__, parent->ino, info->ino, str.name, str.hash, str.len,
+				info->mode);
+
+		npi = pohmelfs_new_inode(st->psb, parent, &str, info, 0);
+		if (IS_ERR(npi)) {
+			err = PTR_ERR(npi);
+
+			if (err != -EEXIST)
+				goto err_out_put;
+		} else {
+			set_bit(NETFS_INODE_CREATED, &npi->state);
+		}
+	}
+out:
+	if (last) {
+		set_bit(NETFS_INODE_REMOTE_SYNCED, &parent->state);
+		wake_up(&st->psb->wait);
+	}
+	pohmelfs_put_inode(parent);
+
+	return err;
+
+err_out_put:
+	clear_bit(NETFS_INODE_REMOTE_SYNCED, &parent->state);
+	printk("%s: parent: %llu, ino: %llu, cmd_id: %llu.\n", __func__, parent->ino, cmd->start, cmd->id);
+	pohmelfs_put_inode(parent);
+	wake_up(&st->psb->wait);
+	return err;
+}
+
+/*
+ * Lookup command response.
+ * It searches for inode to be looked at (if it exists) and substitutes
+ * its inode information (size, permission, mode and so on), if inode does
+ * not exist, new one will be created and inserted into caches.
+ */
+static int pohmelfs_lookup_response(struct netfs_state *st)
+{
+	struct inode *inode = NULL;
+	struct netfs_cmd *cmd = &st->cmd;
+	struct netfs_inode_info *info;
+	struct pohmelfs_inode *parent = NULL, *npi;
+	int err = -EINVAL;
+	char *name;
+
+	inode = ilookup(st->psb->sb, cmd->id);
+	if (!inode) {
+		printk("%s: lookup response: id: %llu, start: %llu, size: %u.\n",
+				__func__, cmd->id, cmd->start, cmd->size);
+		err = -ENOENT;
+		goto err_out_exit;
+	}
+	parent = POHMELFS_I(inode);
+
+	if (!cmd->size) {
+		err = -cmd->start;
+		goto err_out_put;
+	}
+
+	if (cmd->size < sizeof(struct netfs_inode_info)) {
+		printk("%s: broken lookup response: id: %llu, start: %llu, size: %u.\n",
+				__func__, cmd->id, cmd->start, cmd->size);
+		err = -EINVAL;
+		goto err_out_put;
+	}
+
+	err = pohmelfs_data_recv_and_check(st, st->data, cmd->size);
+	if (err)
+		goto err_out_put;
+
+	info = (struct netfs_inode_info *)(st->data);
+	name = (char *)(info + 1);
+
+	netfs_convert_inode_info(info);
+
+	info->ino = cmd->start;
+	if (!info->ino)
+		info->ino = pohmelfs_new_ino(st->psb);
+
+	dprintk("%s: parent: %llu, ino: %llu, name: '%s', start: %llu.\n",
+			__func__, parent->ino, info->ino, name, cmd->start);
+
+	if (cmd->start)
+		npi = pohmelfs_new_inode(st->psb, parent, NULL, info, 0);
+	else {
+		struct qstr str;
+
+		str.name = name;
+		str.len = cmd->size - sizeof(struct netfs_inode_info) - 1 - cmd->cpad;
+		str.hash = jhash(name, str.len, 0);
+
+		npi = pohmelfs_new_inode(st->psb, parent, &str, info, 0);
+	}
+	if (IS_ERR(npi)) {
+		err = PTR_ERR(npi);
+
+		if (err != -EEXIST)
+			goto err_out_put;
+	} else {
+		set_bit(NETFS_INODE_CREATED, &npi->state);
+	}
+
+	clear_bit(NETFS_COMMAND_PENDING, &parent->state);
+	pohmelfs_put_inode(parent);
+
+	wake_up(&st->psb->wait);
+
+	return 0;
+
+err_out_put:
+	pohmelfs_put_inode(parent);
+err_out_exit:
+	clear_bit(NETFS_COMMAND_PENDING, &parent->state);
+	wake_up(&st->psb->wait);
+	printk("%s: inode: %p, id: %llu, start: %llu, size: %u, err: %d.\n",
+			__func__, inode, cmd->id, cmd->start, cmd->size, err);
+	return err;
+}
+
+/*
+ * Create response, just marks local inode as 'created', so that writeback
+ * for any of its children (or own) would not try to sync it again.
+ */
+static int pohmelfs_create_response(struct netfs_state *st)
+{
+	struct inode *inode;
+	struct netfs_cmd *cmd = &st->cmd;
+
+	inode = ilookup(st->psb->sb, cmd->id);
+	if (!inode) {
+		printk("%s: failed to find inode: id: %llu, start: %llu.\n",
+				__func__, cmd->id, cmd->start);
+		goto err_out_exit;
+	}
+
+	/*
+	 * To lock or not to lock?
+	 * We actually do not care if it races...
+	 */
+	if (cmd->start)
+		make_bad_inode(inode);
+
+	set_bit(NETFS_INODE_CREATED, &POHMELFS_I(inode)->state);
+
+	pohmelfs_put_inode(POHMELFS_I(inode));
+
+	wake_up(&st->psb->wait);
+	return 0;
+
+err_out_exit:
+	wake_up(&st->psb->wait);
+	return -ENOENT;
+}
+
+/*
+ * Object remove response. Just says that remove request has been received.
+ * Used in cache coherency protocol.
+ */
+static int pohmelfs_remove_response(struct netfs_state *st)
+{
+	struct netfs_cmd *cmd = &st->cmd;
+	int err;
+
+	err = pohmelfs_data_recv_and_check(st, st->data, cmd->size);
+	if (err)
+		return err;
+
+	dprintk("%s: parent: %llu, path: '%s'.\n", __func__, cmd->id, (char *)st->data);
+
+	return 0;
+}
+
+/*
+ * Transaction reply processing.
+ *
+ * Find transaction based on its generation number, bump its reference counter,
+ * so that none could free it under us, drop from the trees and lists and
+ * drop reference counter. When it hits zero (when all destinations replied
+ * and all timeout handled by async scanning code), completion will be called
+ * and transaction will be freed.
+ */
+static int pohmelfs_transaction_response(struct netfs_state *st)
+{
+	struct netfs_trans_dst *dst;
+	struct netfs_trans *t = NULL;
+	struct netfs_cmd *cmd = &st->cmd;
+	short err = (signed)cmd->ext;
+
+	mutex_lock(&st->trans_lock);
+	dst = netfs_trans_search(st, cmd->start);
+	if (dst) {
+		netfs_trans_remove_nolock(dst, st);
+		t = dst->trans;
+	}
+	mutex_unlock(&st->trans_lock);
+
+	if (!t) {
+		printk("%s: failed to find transaction: start: %llu: id: %llu, size: %u, ext: %u.\n",
+				__func__, cmd->start, cmd->id, cmd->size, cmd->ext);
+		err = -EINVAL;
+		goto out;
+	}
+
+	dprintk("%s: sync transaction reply: t: %p, refcnt: %d, gen: %u, flags: %x, err: %d.\n",
+			__func__, t, atomic_read(&t->refcnt), t->gen, t->flags, err);
+
+	t->result = err;
+	netfs_trans_drop_dst_nostate(dst);
+
+out:
+	wake_up(&st->psb->wait);
+	return err;
+}
+
+/*
+ * Inode metadata cache coherency message.
+ */
+static int pohmelfs_inode_info_response(struct netfs_state *st)
+{
+	struct netfs_cmd *cmd = &st->cmd;
+	struct netfs_inode_info *info;
+	struct inode *inode;
+	struct iattr iattr;
+	struct dentry *dentry;
+	int err = -EINVAL;
+
+	err = pohmelfs_data_recv_and_check(st, st->data, cmd->size);
+	if (err)
+		return err;
+
+	info = st->data;
+
+	netfs_convert_inode_info(info);
+
+	inode = ilookup(st->psb->sb, cmd->id);
+	if (!inode) {
+		dprintk("%s: failed to find inode: id: %llu.\n", __func__, cmd->id);
+		err = -ENOENT;
+		goto err_out_exit;
+	}
+
+	iattr.ia_valid = ATTR_MODE | ATTR_UID | ATTR_GID | ATTR_SIZE | ATTR_ATIME;
+	iattr.ia_mode = info->mode;
+	iattr.ia_uid = info->uid;
+	iattr.ia_gid = info->gid;
+	iattr.ia_size = info->size;
+	iattr.ia_atime = CURRENT_TIME;
+
+	mutex_lock(&inode->i_mutex);
+
+	dprintk("%s: ino: %llu, mode: %o -> %o, uid: %u -> %u, gid: %u -> %u, size: %llu -> %llu.\n",
+			__func__, POHMELFS_I(inode)->ino, inode->i_mode, info->mode,
+			inode->i_uid, info->uid, inode->i_gid, info->gid, inode->i_size, info->size);
+
+	err = pohmelfs_setattr_raw(inode, &iattr);
+	if (err)
+		goto err_out_unlock;
+
+	dentry = d_find_alias(inode);
+	if (dentry) {
+		fsnotify_change(dentry, iattr.ia_valid);
+		dput(dentry);
+	}
+	mutex_unlock(&inode->i_mutex);
+
+	pohmelfs_put_inode(POHMELFS_I(inode));
+
+	return 0;
+
+err_out_unlock:
+	mutex_unlock(&inode->i_mutex);
+	pohmelfs_put_inode(POHMELFS_I(inode));
+err_out_exit:
+	return err;
+}
+
+/*
+ * Inode metadata cache coherency message.
+ */
+static int pohmelfs_page_cache_response(struct netfs_state *st)
+{
+	struct netfs_cmd *cmd = &st->cmd;
+	struct inode *inode;
+	int err = 0;
+	u64 isize = cmd->start;
+
+	inode = ilookup(st->psb->sb, cmd->id);
+	if (!inode) {
+		dprintk("%s: failed to find inode: id: %llu.\n", __func__, cmd->id);
+		return -ENOENT;
+	}
+
+	if (i_size_read(inode) != cmd->start) {
+		mutex_lock(&inode->i_mutex);
+		if (inode->i_size != cmd->start) {
+			isize = inode->i_size;
+			err = vmtruncate(inode, cmd->start);
+		}
+		mutex_unlock(&inode->i_mutex);
+	}
+
+	dprintk("%s: ino: %llu, isize: %llu, new_size: %llu.\n",
+			__func__, POHMELFS_I(inode)->ino, isize, cmd->start);
+	
+	if ((cmd->start >> PAGE_CACHE_SHIFT) <= (isize >> PAGE_CACHE_SHIFT))
+		invalidate_inode_pages2_range(inode->i_mapping, cmd->start, cmd->start + 1);
+
+	pohmelfs_put_inode(POHMELFS_I(inode));
+
+	return err;
+}
+
+/*
+ * Capabilities handshake response.
+ */
+static int pohmelfs_capabilities_response(struct netfs_state *st)
+{
+	struct netfs_cmd *cmd = &st->cmd;
+	struct netfs_capabilities *cap;
+	struct pohmelfs_sb *psb = st->psb;
+	int err = 0;
+
+	err = pohmelfs_data_recv(st, st->data, cmd->size);
+	if (err)
+		return err;
+
+	if (cmd->size != sizeof(struct netfs_capabilities)) {
+		psb->flags = EPROTO;
+		wake_up(&psb->wait);
+		return -EPROTO;
+	}
+
+	cap = st->data;
+
+	dprintk("%s: cipher '%s': %s, hash: '%s': %s.\n",
+			__func__,
+			psb->cipher_string, (cap->cipher_strlen)?"SUPPORTED":"NOT SUPPORTED",
+			psb->hash_string, (cap->hash_strlen)?"SUPPORTED":"NOT SUPPORTED");
+
+	if (!cap->hash_strlen) {
+		if (psb->hash_strlen && psb->crypto_fail_unsupported)
+			err = -ENOTSUPP;
+		psb->hash_strlen = 0;
+		kfree(psb->hash_string);
+		psb->hash_string = NULL;
+	}
+
+	if (!cap->cipher_strlen) {
+		if (psb->cipher_strlen && psb->crypto_fail_unsupported)
+			err = -ENOTSUPP;
+		psb->cipher_strlen = 0;
+		kfree(psb->cipher_string);
+		psb->cipher_string = NULL;
+	}
+
+	return err;
+}
+
+static void __inline__ netfs_state_reset(struct netfs_state *st)
+{
+	netfs_state_lock(st);
+	netfs_state_exit(st);
+	netfs_state_init(st);
+	netfs_state_unlock(st);
+}
+
+/*
+ * Main receiving function, called from dedicated kernel thread.
+ */
+static int pohmelfs_recv(void *data)
+{
+	int err = -EINTR;
+	struct netfs_state *st = data;
+	struct netfs_cmd *cmd = &st->cmd;
+
+	while (!kthread_should_stop()) {
+		/*
+		 * If socket will be reset after this statement, then
+		 * pohmelfs_data_recv() will just fail and loop will
+		 * start again, so it can be done without any locks.
+		 *
+		 * st->read_socket is needed to prevents state machine
+		 * breaking between this data reading and subsequent one
+		 * in protocol specific functions during connection reset.
+		 * In case of reset we have to read next command and do
+		 * not expect data for old command to magically appear in
+		 * new connection.
+		 */
+		st->read_socket = st->socket;
+		err = pohmelfs_data_recv(st, cmd, sizeof(struct netfs_cmd));
+		if (err) {
+			msleep(1000);
+			continue;
+		}
+
+		netfs_convert_cmd(cmd);
+
+		dprintk("%s: cmd: %u, id: %llu, start: %llu, size: %u, "
+				"ext: %u, csize: %u, cpad: %u.\n",
+				__func__, cmd->cmd, cmd->id, cmd->start,
+				cmd->size, cmd->ext, cmd->csize, cmd->cpad);
+
+		if (cmd->csize) {
+			struct pohmelfs_crypto_engine *e = &st->eng;
+
+			if (unlikely(cmd->csize > e->size/2)) {
+				netfs_state_reset(st);
+				continue;
+			}
+
+			if (e->hash && unlikely(cmd->csize != st->psb->crypto_attached_size)) {
+				dprintk("%s: cmd: cmd: %u, id: %llu, start: %llu, size: %u, "
+						"csize: %u != digest size %u.\n",
+						__func__, cmd->cmd, cmd->id, cmd->start, cmd->size,
+						cmd->csize, st->psb->crypto_attached_size);
+				netfs_state_reset(st);
+				continue;
+			}
+
+			err = pohmelfs_data_recv(st, e->data, cmd->csize);
+			if (err) {
+				netfs_state_reset(st);
+				continue;
+			}
+
+			{
+				unsigned int i;
+				unsigned char *hash = e->data;
+
+				dprintk("%s: received hash: ", __func__);
+				for (i=0; i<cmd->csize; ++i) {
+					dprintk("%02x ", hash[i]);
+				}
+				dprintk("\n");
+			}
+
+			cmd->size -= cmd->csize;
+		}
+
+		/*
+		 * This should catch protocol breakage and random garbage instead of commands.
+		 */
+		if (unlikely(cmd->size > st->size)) {
+			netfs_state_reset(st);
+			continue;
+		}
+
+		switch (cmd->cmd) {
+			case NETFS_READ_PAGE:
+				err = pohmelfs_read_page_response(st);
+				break;
+			case NETFS_READDIR:
+				err = pohmelfs_readdir_response(st);
+				break;
+			case NETFS_LOOKUP:
+				err = pohmelfs_lookup_response(st);
+				break;
+			case NETFS_CREATE:
+				err = pohmelfs_create_response(st);
+				break;
+			case NETFS_REMOVE:
+				err = pohmelfs_remove_response(st);
+				break;
+			case NETFS_TRANS:
+				err = pohmelfs_transaction_response(st);
+				break;
+			case NETFS_INODE_INFO:
+				err = pohmelfs_inode_info_response(st);
+				break;
+			case NETFS_PAGE_CACHE:
+				err = pohmelfs_page_cache_response(st);
+				break;
+			case NETFS_CAPABILITIES:
+				err = pohmelfs_capabilities_response(st);
+				break;
+			default:
+				printk("%s: wrong cmd: %u, id: %llu, start: %llu, size: %u, ext: %u.\n",
+					__func__, cmd->cmd, cmd->id, cmd->start, cmd->size, cmd->ext);
+				netfs_state_lock(st);
+				netfs_state_exit(st);
+				netfs_state_init(st);
+				netfs_state_unlock(st);
+				break;
+		}
+	}
+
+	while (!kthread_should_stop())
+		schedule_timeout_uninterruptible(msecs_to_jiffies(10));
+
+	return err;
+}
+
+int netfs_state_init(struct netfs_state *st)
+{
+	int err;
+	struct pohmelfs_ctl *ctl = &st->ctl;
+
+	err = sock_create(ctl->addr.sa_family, ctl->type, ctl->proto, &st->socket);
+	if (err)
+		goto err_out_exit;
+
+	st->socket->sk->sk_allocation = GFP_NOIO;
+	st->socket->sk->sk_sndtimeo = st->socket->sk->sk_rcvtimeo = msecs_to_jiffies(60000);
+
+	err = kernel_connect(st->socket, (struct sockaddr *)&ctl->addr, ctl->addrlen, 0);
+	if (err) {
+		printk("%s: failed to connect to server: idx: %u, err: %d.\n",
+				__func__, st->psb->idx, err);
+		goto err_out_release;
+	}
+	st->socket->sk->sk_sndtimeo = st->socket->sk->sk_rcvtimeo = msecs_to_jiffies(10000);
+
+	err = netfs_poll_init(st);
+	if (err)
+		goto err_out_release;
+
+	if (st->socket->ops->family == AF_INET) {
+		struct sockaddr_in *sin = (struct sockaddr_in *)&ctl->addr;
+		printk(KERN_INFO "%s: (re)connected to peer %u.%u.%u.%u:%d.\n", __func__,
+			NIPQUAD(sin->sin_addr.s_addr), ntohs(sin->sin_port));
+	} else if (st->socket->ops->family == AF_INET6) {
+		struct sockaddr_in6 *sin = (struct sockaddr_in6 *)&ctl->addr;
+		printk(KERN_INFO "%s: (re)connected to peer "
+			"%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%d",
+			__func__, NIP6(sin->sin6_addr), ntohs(sin->sin6_port));
+	}
+
+	return 0;
+
+err_out_release:
+	sock_release(st->socket);
+err_out_exit:
+	st->socket = NULL;
+	return err;
+}
+
+void netfs_state_exit(struct netfs_state *st)
+{
+	if (st->socket) {
+		netfs_poll_exit(st);
+		st->socket->ops->shutdown(st->socket, 2);
+
+		if (st->socket->ops->family == AF_INET) {
+			struct sockaddr_in *sin = (struct sockaddr_in *)&st->ctl.addr;
+			printk(KERN_INFO "%s: disconnected from peer %u.%u.%u.%u:%d.\n", __func__,
+				NIPQUAD(sin->sin_addr.s_addr), ntohs(sin->sin_port));
+		} else if (st->socket->ops->family == AF_INET6) {
+			struct sockaddr_in6 *sin = (struct sockaddr_in6 *)&st->ctl.addr;
+			printk(KERN_INFO "%s: disconnected from peer "
+				"%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%d",
+				__func__, NIP6(sin->sin6_addr), ntohs(sin->sin6_port));
+		}
+
+		sock_release(st->socket);
+		st->socket = NULL;
+		st->read_socket = NULL;
+	}
+}
+
+int pohmelfs_state_init_one(struct pohmelfs_sb *psb, struct pohmelfs_config *conf)
+{
+	struct netfs_state *st = &conf->state;
+	int err = -ENOMEM;
+
+	mutex_init(&st->__state_lock);
+	init_waitqueue_head(&st->thread_wait);
+
+	st->psb = psb;
+	st->trans_root = RB_ROOT;
+	mutex_init(&st->trans_lock);
+
+	st->size = psb->trans_data_size;
+	st->data = kmalloc(st->size, GFP_KERNEL);
+	if (!st->data)
+		goto err_out_exit;
+
+	if (psb->perform_crypto) {
+		err = pohmelfs_crypto_engine_init(&st->eng, psb);
+		if (err)
+			goto err_out_free_data;
+	}
+
+	err = netfs_state_init(st);
+	if (err)
+		goto err_out_free_engine;
+
+	st->thread = kthread_run(pohmelfs_recv, st, "pohmelfs/%u", psb->idx);
+	if (IS_ERR(st->thread)) {
+		err = PTR_ERR(st->thread);
+		goto err_out_netfs_exit;
+	}
+
+	if (!psb->active_state)
+		psb->active_state = conf;
+
+	dprintk("%s: conf: %p, st: %p, socket: %p.\n",
+			__func__, conf, st, st->socket);
+	return 0;
+
+err_out_netfs_exit:
+	netfs_state_exit(st);
+err_out_free_engine:
+	pohmelfs_crypto_engine_exit(&st->eng);
+err_out_free_data:
+	kfree(st->data);
+err_out_exit:
+	return err;
+
+}
+
+static void pohmelfs_state_exit_one(struct pohmelfs_config *c)
+{
+	struct netfs_state *st = &c->state;
+	struct rb_node *rb_node;
+	struct netfs_trans_dst *dst;
+
+	dprintk("%s: exiting, st: %p.\n", __func__, st);
+	st->socket->sk->sk_sndtimeo = st->socket->sk->sk_rcvtimeo = 0;
+	if (st->thread) {
+		kthread_stop(st->thread);
+		st->thread = NULL;
+	}
+
+	netfs_state_lock(st);
+	netfs_state_exit(st);
+	netfs_state_unlock(st);
+
+	for (rb_node = rb_first(&st->trans_root); rb_node; ) {
+		dst = rb_entry(rb_node, struct netfs_trans_dst, state_entry);
+		rb_node = rb_next(rb_node);
+
+		dst->trans->result = -EINVAL;
+		netfs_trans_remove_nolock(dst, st);
+		netfs_trans_finish_send(dst->trans, st->psb);
+
+		netfs_trans_drop_dst_nostate(dst);
+	}
+
+	pohmelfs_crypto_engine_exit(&st->eng);
+	kfree(st->data);
+
+	kfree(c);
+}
+
+/*
+ * Initialize network stack. It searches for given ID in global
+ * configuration table, this contains information of the remote server
+ * (address (any supported by socket interface) and port, protocol and so on).
+ */
+int pohmelfs_state_init(struct pohmelfs_sb *psb)
+{
+	int err = -ENOMEM;
+
+	err = pohmelfs_copy_config(psb);
+	if (err) {
+		pohmelfs_state_exit(psb);
+		return err;
+	}
+
+	return 0;
+}
+
+void pohmelfs_state_exit(struct pohmelfs_sb *psb)
+{
+	struct pohmelfs_config *c, *tmp;
+
+	list_for_each_entry_safe(c, tmp, &psb->state_list, config_entry) {
+		list_del(&c->config_entry);
+		pohmelfs_state_exit_one(c);
+	}
+}
+
+void pohmelfs_switch_active(struct pohmelfs_sb *psb)
+{
+	struct pohmelfs_config *c = psb->active_state;
+
+	if (!list_empty(&psb->state_list)) {
+		if (c->config_entry.next != &psb->state_list) {
+			psb->active_state = list_entry(c->config_entry.next,
+				struct pohmelfs_config, config_entry);
+		} else {
+			psb->active_state = list_entry(psb->state_list.next,
+				struct pohmelfs_config, config_entry);
+		}
+	} else
+		psb->active_state = NULL;
+
+	dprintk("%s: empty: %d, active %p -> %p.\n",
+		__func__, list_empty(&psb->state_list), c,
+		psb->active_state);
+}
+
+void pohmelfs_check_states(struct pohmelfs_sb *psb)
+{
+	struct pohmelfs_config *c, *tmp;
+	LIST_HEAD(delete_list);
+
+	mutex_lock(&psb->state_lock);
+	list_for_each_entry_safe(c, tmp, &psb->state_list, config_entry) {
+		if (pohmelfs_config_check(c, psb->idx)) {
+
+			if (psb->active_state == c)
+				pohmelfs_switch_active(psb);
+			list_move(&c->config_entry, &delete_list);
+		}
+	}
+	pohmelfs_copy_config(psb);
+	mutex_unlock(&psb->state_lock);
+	
+	list_for_each_entry_safe(c, tmp, &delete_list, config_entry) {
+		list_del(&c->config_entry);
+		pohmelfs_state_exit_one(c);
+	}
+}
diff --git a/fs/pohmelfs/netfs.h b/fs/pohmelfs/netfs.h
new file mode 100644
index 0000000..0323d5b
--- /dev/null
+++ b/fs/pohmelfs/netfs.h
@@ -0,0 +1,794 @@
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
+#ifndef __NETFS_H
+#define __NETFS_H
+
+#include <linux/types.h>
+#include <linux/connector.h>
+
+#define POHMELFS_CN_IDX			5
+#define POHMELFS_CN_VAL			0
+
+/*
+ * Network command structure.
+ * Will be extended.
+ */
+struct netfs_cmd
+{
+	__u16			cmd;	/* Command number */
+	__u16			csize;	/* Attached crypto information size */
+	__u16			cpad;	/* Attached padding size */
+	__u16			ext;	/* External flags */
+	__u32			size;	/* Size of the attached data */
+	__u32			trans;	/* Transaction id */
+	__u64			id;	/* Object ID to operate on. Used for feedback.*/
+	__u64			start;	/* Start of the object. */
+	__u64			iv;	/* IV sequence */
+	__u8			data[0];
+};
+
+static inline void netfs_convert_cmd(struct netfs_cmd *cmd)
+{
+	cmd->id = __be64_to_cpu(cmd->id);
+	cmd->start = __be64_to_cpu(cmd->start);
+	cmd->iv = __be64_to_cpu(cmd->iv);
+	cmd->cmd = __be16_to_cpu(cmd->cmd);
+	cmd->ext = __be16_to_cpu(cmd->ext);
+	cmd->csize = __be16_to_cpu(cmd->csize);
+	cmd->cpad = __be16_to_cpu(cmd->cpad);
+	cmd->size = __be32_to_cpu(cmd->size);
+}
+
+#define NETFS_TRANS_SINGLE_DST		(1<<0)
+
+enum {
+	NETFS_READDIR	= 1,	/* Read directory for given inode number */
+	NETFS_READ_PAGE,	/* Read data page from the server */
+	NETFS_WRITE_PAGE,	/* Write data page to the server */
+	NETFS_CREATE,		/* Create directory entry */
+	NETFS_REMOVE,		/* Remove directory entry */
+	NETFS_LOOKUP,		/* Lookup single object */
+	NETFS_LINK,		/* Create a link */
+	NETFS_TRANS,		/* Transaction */
+	NETFS_OPEN,		/* Open intent */
+	NETFS_INODE_INFO,	/* Metadata cache coherency synchronization message */
+	NETFS_JOIN_GROUP,	/* Joing metadata update group */
+	NETFS_LEAVE_GROUP,	/* Leave metadata update group */
+	NETFS_PAGE_CACHE,	/* Page cache invalidation message */
+	NETFS_READ_PAGES,	/* Read multiple contiguous pages in one go */
+	NETFS_RENAME,		/* Rename object */
+	NETFS_CAPABILITIES,	/* Capabilities of the client, for example supported crypto */
+	NETFS_CMD_MAX
+};
+
+enum {
+	POHMELFS_FLAGS_CTL = 0,	/* Network state control message */
+	POHMELFS_FLAGS_CRYPTO,	/* Crypto data control message */
+};
+
+/*
+ * Always wanted to copy it from socket headers into public one,
+ * since they are __KERNEL__ protected there.
+ */
+#define _K_SS_MAXSIZE	128
+
+struct saddr
+{
+	unsigned short		sa_family;
+	char			addr[_K_SS_MAXSIZE];
+};
+
+enum {
+	POHMELFS_CRYPTO_HASH = 0,
+	POHMELFS_CRYPTO_CIPHER,
+};
+
+struct pohmelfs_crypto
+{
+	unsigned int		idx;		/* Config index */
+	unsigned short		strlen;		/* Size of the attached crypto string including 0-byte
+						 * "cbc(aes)" for example */
+	unsigned short		type;		/* HMAC, cipher, both */
+	unsigned int		keysize;	/* Key size */
+	unsigned char		data[0];	/* Algorithm string, key and IV */
+};
+
+/*
+ * Configuration command used to create table of different remote servers.
+ */
+struct pohmelfs_ctl
+{
+	unsigned int		idx;		/* Config index */
+	unsigned int		type;		/* Socket type */
+	unsigned int		proto;		/* Socket protocol */
+	unsigned int		addrlen;	/* Size of the address */
+	struct saddr		addr;		/* Remote server address */
+};
+
+/*
+ * Ack for userspace about requested command.
+ */
+struct pohmelfs_cn_ack
+{
+	struct cn_msg		msg;
+	int			error;
+	int			unused[3];
+};
+
+/*
+ * Inode info structure used to sync with server.
+ * Check what stat() returns.
+ */
+struct netfs_inode_info
+{
+	unsigned int		mode;
+	unsigned int		nlink;
+	unsigned int		uid;
+	unsigned int		gid;
+	unsigned int		blocksize;
+	unsigned int		padding;
+	__u64			ino;
+	__u64			blocks;
+	__u64			rdev;
+	__u64			size;
+	__u64			version;
+};
+
+static inline void netfs_convert_inode_info(struct netfs_inode_info *info)
+{
+	info->mode = __cpu_to_be32(info->mode);
+	info->nlink = __cpu_to_be32(info->nlink);
+	info->uid = __cpu_to_be32(info->uid);
+	info->gid = __cpu_to_be32(info->gid);
+	info->blocksize = __cpu_to_be32(info->blocksize);
+	info->blocks = __cpu_to_be64(info->blocks);
+	info->rdev = __cpu_to_be64(info->rdev);
+	info->size = __cpu_to_be64(info->size);
+	info->version = __cpu_to_be64(info->version);
+	info->ino = __cpu_to_be64(info->ino);
+}
+
+/*
+ * Cache state machine.
+ */
+enum {
+	NETFS_COMMAND_PENDING = 0,	/* Command is being executed */
+	NETFS_INODE_CREATED,		/* Inode was created locally */
+	NETFS_INODE_REMOTE_SYNCED,	/* Inode was synced to server */
+};
+
+/*
+ * Path entry, used to create full path to object by single command.
+ */
+struct netfs_path_entry
+{
+	__u8			len;		/* Data length, if less than 5 */
+	__u8			unused[5];	/* then data is embedded here */
+
+	__u16			mode;		/* mode of the object (dir, file and so on) */
+
+	char			data[];
+};
+
+static inline void netfs_convert_path_entry(struct netfs_path_entry *e)
+{
+	e->mode = __cpu_to_be16(e->mode);
+};
+
+struct netfs_capabilities
+{
+	unsigned short		hash_strlen;	/* Hash string length, like "hmac(sha1) including 0 byte "*/
+	unsigned short		cipher_strlen;	/* Cipher string length with the same format */
+	unsigned int		cipher_keysize;	/* Cipher key size */
+};
+
+static inline void netfs_convert_capabilities(struct netfs_capabilities *cap)
+{
+	cap->hash_strlen = __cpu_to_be16(cap->hash_strlen);
+	cap->cipher_strlen = __cpu_to_be16(cap->cipher_strlen);
+	cap->cipher_keysize = __cpu_to_be32(cap->cipher_keysize);
+}
+
+#ifdef __KERNEL__
+
+#include <linux/kernel.h>
+#include <linux/completion.h>
+#include <linux/rbtree.h>
+#include <linux/net.h>
+#include <linux/poll.h>
+
+/*
+ * Private POHMELFS cache of objects in directory.
+ */
+struct pohmelfs_name
+{
+	struct rb_node		offset_node;
+	struct rb_node		hash_node;
+
+	struct list_head	sync_del_entry, sync_create_entry;
+
+	u64			ino;
+
+	u64			offset;
+
+	u32			hash;
+	u32			mode;
+	u32			len;
+
+	char			*data;
+};
+
+/*
+ * POHMELFS inode. Main object.
+ */
+struct pohmelfs_inode
+{
+	struct list_head	inode_entry;		/* Entry in superblock list.
+							 * Objects which are not bound to dentry require to be dropped
+							 * in ->put_super()
+							 */
+	struct rb_root		offset_root;		/* Local cache for names in dir */
+	struct rb_root		hash_root;		/* The same, but indexed by name hash and len */
+	struct mutex		offset_lock;		/* Protect both above trees */
+
+	struct list_head	sync_del_list, sync_create_list;	/* Sync list (create is not used).
+									 * It contains children scheduled to be removed
+									 */
+
+	unsigned int		drop_count;
+
+	int			error;			/* Transaction error for given inode */
+
+	long			state;			/* State machine above */
+
+	u64			ino;			/* Inode number */
+	u64			total_len;		/* Total length of all children names, used to create offsets */
+
+	struct inode		vfs_inode;
+};
+
+struct netfs_trans;
+typedef int (* netfs_trans_complete_t)(struct page **pages, unsigned int page_num,
+		void *private, int err);
+
+struct netfs_state;
+struct pohmelfs_sb;
+
+struct netfs_trans
+{
+	/*
+	 * Transaction header and attached contiguous data live here.
+	 */
+	struct iovec			iovec;
+
+	/*
+	 * Pages attached to transaction.
+	 */
+	struct page			**pages;
+
+	/*
+	 * List and protecting lock for transaction destination
+	 * network states.
+	 */
+	struct mutex			dst_lock;
+	struct list_head		dst_list;
+
+	/*
+	 * Number of users for given transaction.
+	 * For example each network state attached to transaction
+	 * via dst_list increases it.
+	 */
+	atomic_t			refcnt;
+
+	/*
+	 * Number of pages attached to given transaction.
+	 * Some slots in above page array can be NULL, since
+	 * for example page can be under writeback already,
+	 * so we skip it in this transaction.
+	 */
+	unsigned int			page_num;
+
+	/*
+	 * Transaction flags: single dst or broadcast and so on.
+	 */
+	unsigned int			flags;
+
+	/*
+	 * Size of the data, which can be placed into
+	 * iovec.iov_base area.
+	 */
+	unsigned int			total_size;
+
+	/*
+	 * Number of pages to be sent to remote server.
+	 * Usually equal to above page_num, but in case of partial
+	 * writeback it can accumulate only pages already completed
+	 * previous writeback.
+	 */
+	unsigned int			attached_pages;
+
+	/*
+	 * Attached number of bytes in all above pages.
+	 */
+	unsigned int			attached_size;
+
+	/*
+	 * Unique transacton generation number.
+	 * Used as identity in the network state tree of transactions.
+	 */
+	unsigned int			gen;
+
+	/*
+	 * Transaction completion status.
+	 */
+	int				result;
+	
+	/*
+	 * Superblock this transaction belongs to
+	 */
+	struct pohmelfs_sb		*psb;
+
+	/*
+	 * Crypto engine, which processed this transaction.
+	 * Can be not NULL only if crypto engine holds encrypted pages.
+	 */
+	struct pohmelfs_crypto_engine	*eng;
+
+	/* Private data */
+	void				*private;
+
+	/* Completion callback, invoked just before transaction is destroyed */
+	netfs_trans_complete_t		complete;
+};
+
+static inline int netfs_trans_cur_len(struct netfs_trans *t)
+{
+	return (signed)(t->total_size - t->iovec.iov_len);
+}
+
+static inline void *netfs_trans_current(struct netfs_trans *t)
+{
+	return t->iovec.iov_base + t->iovec.iov_len;
+}
+
+struct netfs_trans *netfs_trans_alloc(struct pohmelfs_sb *psb, unsigned int size,
+		unsigned int flags, unsigned int nr);
+void netfs_trans_free(struct netfs_trans *t);
+int netfs_trans_finish(struct netfs_trans *t, struct pohmelfs_sb *psb);
+int netfs_trans_finish_send(struct netfs_trans *t, struct pohmelfs_sb *psb);
+
+static inline void netfs_trans_reset(struct netfs_trans *t)
+{
+	t->complete = NULL;
+}
+
+struct netfs_trans_dst
+{
+	struct list_head		trans_entry;
+	struct rb_node			state_entry;
+
+	unsigned long			send_time;
+
+	/*
+	 * Times this transaction was resent to its old or new,
+	 * depending on flags, destinations. When it reaches maximum
+	 * allowed number, specified in superblock->trans_retries,
+	 * transaction will be freed with ETIMEDOUT error.
+	 */
+	unsigned int			retries;
+
+	struct netfs_trans		*trans;
+	struct netfs_state		*state;
+};
+
+struct netfs_trans_dst *netfs_trans_search(struct netfs_state *st, unsigned int gen);
+void netfs_trans_drop_dst(struct netfs_trans_dst *dst);
+void netfs_trans_drop_dst_nostate(struct netfs_trans_dst *dst);
+void netfs_trans_drop_trans(struct netfs_trans *t, struct netfs_state *st);
+void netfs_trans_drop_last(struct netfs_trans *t, struct netfs_state *st);
+int netfs_trans_resend(struct netfs_trans *t, struct pohmelfs_sb *psb);
+int netfs_trans_remove_nolock(struct netfs_trans_dst *dst, struct netfs_state *st);
+
+int netfs_trans_init(void);
+void netfs_trans_exit(void);
+
+struct pohmelfs_crypto_engine
+{
+	u64				iv;		/* Crypto IV for current operation */
+	unsigned long			timeout;	/* Crypto waiting timeout */
+	unsigned int			size;		/* Size of crypto scratchpad */
+	void				*data;		/* Temporal crypto scratchpad */
+	/*
+	 * Crypto operations performed on objects.
+	 */
+	struct crypto_hash		*hash;
+	struct crypto_ablkcipher	*cipher;
+
+	struct pohmelfs_crypto_thread	*thread;	/* Crypto thread which hosts this engine */
+
+	struct page			**pages;
+	unsigned int			page_num;
+};
+
+struct pohmelfs_crypto_thread
+{
+	struct list_head		thread_entry;
+
+	struct task_struct		*thread;
+	struct pohmelfs_sb		*psb;
+
+	struct pohmelfs_crypto_engine	eng;
+
+	struct netfs_trans		*trans;
+
+	wait_queue_head_t		wait;
+	int				error;
+
+	unsigned int			size;
+	struct page			*page;
+};
+
+void pohmelfs_crypto_thread_make_ready(struct pohmelfs_crypto_thread *th);
+
+/*
+ * Network state, attached to one server.
+ */
+struct netfs_state
+{
+	struct mutex		__state_lock;		/* Can not allow to use the same socket simultaneously */
+	struct netfs_cmd 	cmd;			/* Cached command */
+	struct netfs_inode_info	info;			/* Cached inode info */
+
+	void			*data;			/* Cached some data */
+	unsigned int		size;			/* Size of that data */
+
+	struct pohmelfs_sb	*psb;			/* Superblock */
+
+	struct task_struct	*thread;		/* Async receiving thread */
+
+	/* Waiting/polling machinery */
+	wait_queue_t 		wait;
+	wait_queue_head_t 	*whead;
+	wait_queue_head_t 	thread_wait;
+
+	struct mutex		trans_lock;
+	struct rb_root		trans_root;
+
+	struct pohmelfs_ctl	ctl;			/* Remote peer */
+
+	struct socket		*socket;		/* Socket object */
+	struct socket		*read_socket;		/* Cached pointer to socket object.
+							 * Used to determine if between lock drops socket was changed.
+							 * Never used to read data or any kind of access.
+							 */
+	/*
+	 * Crypto engines to process incoming data.
+	 */
+	struct pohmelfs_crypto_engine	eng;
+};
+
+int netfs_state_init(struct netfs_state *st);
+void netfs_state_exit(struct netfs_state *st);
+
+static inline void netfs_state_lock(struct netfs_state *st)
+{
+	mutex_lock(&st->__state_lock);
+}
+
+static inline void netfs_state_unlock(struct netfs_state *st)
+{
+	BUG_ON(!mutex_is_locked(&st->__state_lock));
+
+	mutex_unlock(&st->__state_lock);
+}
+
+static inline unsigned int netfs_state_poll(struct netfs_state *st)
+{
+	unsigned int revents = POLLHUP | POLLERR;
+
+	netfs_state_lock(st);
+	if (st->socket)
+		revents = st->socket->ops->poll(NULL, st->socket, NULL);
+	netfs_state_unlock(st);
+
+	return revents;
+}
+
+struct pohmelfs_config;
+
+struct pohmelfs_sb
+{
+	struct rb_root		path_root;
+	struct mutex		path_lock;
+
+	unsigned int		idx;
+
+	unsigned int		trans_retries;
+
+	atomic_t		trans_gen;
+
+	unsigned int		crypto_attached_size;
+	unsigned int		crypto_align_size;
+
+	unsigned int		crypto_fail_unsupported;
+
+	unsigned int		crypto_thread_num;
+	struct list_head	crypto_active_list, crypto_ready_list;
+	struct mutex		crypto_thread_lock;
+
+	unsigned int		trans_max_pages;
+	unsigned long		trans_data_size;
+	unsigned long		trans_timeout;
+
+	unsigned long		drop_scan_timeout;
+	unsigned long		trans_scan_timeout;
+
+	unsigned long		wait_on_page_timeout;
+
+	long			flags;
+
+	struct list_head	drop_list;
+	spinlock_t		ino_lock;
+	u64			ino;
+
+	struct list_head	state_list;
+	struct mutex		state_lock;
+	
+	wait_queue_head_t	wait;
+
+	struct delayed_work 	dwork;
+	
+	struct delayed_work 	drop_dwork;
+
+	struct pohmelfs_config	*active_state;
+
+	struct super_block	*sb;
+
+	/*
+	 * Algorithm strings.
+	 */
+	char			*hash_string;
+	char			*cipher_string;
+
+	u8			*hash_key;
+	u8			*cipher_key;
+
+	/*
+	 * Algorithm string lengths.
+	 */
+	unsigned int		hash_strlen;
+	unsigned int		cipher_strlen;
+	unsigned int		hash_keysize;
+	unsigned int		cipher_keysize;
+
+	/*
+	 * Controls whether to perfrom crypto processing or not.
+	 */
+	int			perform_crypto;
+};
+
+static inline void netfs_trans_update(struct netfs_cmd *cmd,
+		struct netfs_trans *t, unsigned int size)
+{
+	unsigned int sz = ALIGN(size, t->psb->crypto_align_size);
+
+	t->iovec.iov_len += sizeof(struct netfs_cmd) + sz;
+	cmd->cpad = __cpu_to_be16(sz - size);
+}
+
+static inline struct pohmelfs_sb *POHMELFS_SB(struct super_block *sb)
+{
+	return sb->s_fs_info;
+}
+
+static inline struct pohmelfs_inode *POHMELFS_I(struct inode *inode)
+{
+	return container_of(inode, struct pohmelfs_inode, vfs_inode);
+}
+
+static inline u64 pohmelfs_new_ino(struct pohmelfs_sb *psb)
+{
+	u64 ino;
+
+	spin_lock(&psb->ino_lock);
+	ino = psb->ino++;
+	spin_unlock(&psb->ino_lock);
+
+	return ino;
+}
+
+static inline void pohmelfs_put_inode(struct pohmelfs_inode *pi)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(pi->vfs_inode.i_sb);
+
+	spin_lock(&psb->ino_lock);
+	list_move_tail(&pi->inode_entry, &psb->drop_list);
+	pi->drop_count++;
+	spin_unlock(&psb->ino_lock);
+}
+
+struct pohmelfs_config
+{
+	struct list_head	config_entry;
+
+	struct netfs_state	state;
+};
+
+struct pohmelfs_config_group
+{
+	/*
+	 * Entry in the global config group list.
+	 */
+	struct list_head	group_entry;
+
+	/*
+	 * Index of the current group.
+	 */
+	unsigned int		idx;
+
+	/*
+	 * Algorithm strings.
+	 */
+	char			*hash_string;
+	char			*cipher_string;
+
+	/*
+	 * Algorithm string lengths.
+	 */
+	unsigned int		hash_strlen;
+	unsigned int		cipher_strlen;
+
+	/*
+	 * Key and its size.
+	 */
+	unsigned int		hash_keysize;
+	unsigned int		cipher_keysize;
+	u8			*hash_key;
+	u8			*cipher_key;
+
+	/*
+	 * List of config entries (network state info) for given idx.
+	 */
+	struct list_head	config_list;
+};
+
+int __init pohmelfs_config_init(void);
+void __exit pohmelfs_config_exit(void);
+int pohmelfs_copy_config(struct pohmelfs_sb *psb);
+int pohmelfs_copy_crypto(struct pohmelfs_sb *psb);
+int pohmelfs_config_check(struct pohmelfs_config *config, int idx);
+int pohmelfs_state_init_one(struct pohmelfs_sb *psb, struct pohmelfs_config *conf);
+
+extern const struct file_operations pohmelfs_dir_fops;
+extern const struct inode_operations pohmelfs_dir_inode_ops;
+
+int pohmelfs_state_init(struct pohmelfs_sb *psb);
+void pohmelfs_state_exit(struct pohmelfs_sb *psb);
+
+void pohmelfs_fill_inode(struct inode *inode, struct netfs_inode_info *info);
+
+void pohmelfs_name_del(struct pohmelfs_inode *parent, struct pohmelfs_name *n);
+void pohmelfs_free_names(struct pohmelfs_inode *parent);
+
+void pohmelfs_inode_del_inode(struct pohmelfs_sb *psb, struct pohmelfs_inode *pi);
+
+struct pohmelfs_inode *pohmelfs_create_entry_local(struct pohmelfs_sb *psb,
+	struct pohmelfs_inode *parent, struct qstr *str, u64 start, int mode);
+
+struct pohmelfs_inode *pohmelfs_new_inode(struct pohmelfs_sb *psb,
+		struct pohmelfs_inode *parent, struct qstr *str,
+		struct netfs_inode_info *info, int link);
+
+int pohmelfs_setattr(struct dentry *dentry, struct iattr *attr);
+int pohmelfs_setattr_raw(struct inode *inode, struct iattr *attr);
+
+int pohmelfs_meta_command(struct pohmelfs_inode *pi, unsigned int cmd_op, unsigned int flags,
+		netfs_trans_complete_t complete, void *priv, u64 start);
+int pohmelfs_meta_command_data(struct pohmelfs_inode *pi, unsigned int cmd_op, char *addon,
+		unsigned int flags, netfs_trans_complete_t complete, void *priv, u64 start);
+
+void pohmelfs_check_states(struct pohmelfs_sb *psb);
+void pohmelfs_switch_active(struct pohmelfs_sb *psb);
+
+struct pohmelfs_path_entry
+{
+	struct rb_node			path_entry;
+	struct list_head		entry;
+	u8				len, link;
+	u8				unused[2];
+	atomic_t			refcnt;
+	u32				mode;
+	u32				hash;
+	u64				ino;
+	struct pohmelfs_path_entry	*parent;
+	char				*name;
+};
+
+void pohmelfs_remove_path_entry(struct pohmelfs_sb *psb, struct pohmelfs_path_entry *e);
+void pohmelfs_remove_path_entry_by_ino(struct pohmelfs_sb *psb, u64 ino);
+struct pohmelfs_path_entry * pohmelfs_add_path_entry(struct pohmelfs_sb *psb,
+	u64 parent_ino, u64 ino, struct qstr *str, int link, unsigned int mode);
+int pohmelfs_rename_path_entry(struct pohmelfs_sb *psb, u64 ino, u64 parent_ino, struct qstr *str);
+int pohmelfs_change_path_entry(struct pohmelfs_sb *psb, u64 ino, unsigned int mode);
+int pohmelfs_construct_path(struct pohmelfs_inode *pi, void *data, int len);
+int pohmelfs_construct_path_string(struct pohmelfs_inode *pi, void *data, int len);
+
+int pohmelfs_path_length(struct pohmelfs_inode *pi);
+int pohmelfs_path_length_create(struct pohmelfs_inode *pi);
+
+struct pohmelfs_crypto_completion
+{
+	struct completion	complete;
+	int			error;
+};
+
+int pohmelfs_trans_crypt(struct netfs_trans *t, struct pohmelfs_sb *psb);
+void pohmelfs_crypto_exit(struct pohmelfs_sb *psb);
+int pohmelfs_crypto_init(struct pohmelfs_sb *psb);
+
+int pohmelfs_crypto_engine_init(struct pohmelfs_crypto_engine *e, struct pohmelfs_sb *psb);
+void pohmelfs_crypto_engine_exit(struct pohmelfs_crypto_engine *e);
+
+int pohmelfs_crypto_process_input_data(struct pohmelfs_crypto_engine *e, u64 iv,
+		void *data, struct page *page, unsigned int size);
+int pohmelfs_crypto_process_input_page(struct pohmelfs_crypto_engine *e,
+		struct page *page, unsigned int size, u64 iv);
+
+static inline u64 pohmelfs_gen_iv(struct netfs_trans *t)
+{
+	u64 iv = t->gen;
+
+	iv <<= 32;
+	iv |= ((unsigned long)t) & 0xffffffff;
+
+	return iv;
+}
+
+#ifdef CONFIG_POHMELFS_CC_GROUP
+#define POHMELFS_CC_GROUP
+#endif
+
+#define CONFIG_POHMELFS_DEBUG
+
+#ifdef CONFIG_POHMELFS_DEBUG
+#define dprintk(f, a...) printk(f, ##a)
+#else
+#define dprintk(f, a...) do {} while (0)
+#endif
+
+static inline void netfs_trans_get(struct netfs_trans *t)
+{
+	dprintk("%s: t: %p, gen: %u, refcnt: %d.\n",
+		__func__, t, t->gen, atomic_read(&t->refcnt));
+	atomic_inc(&t->refcnt);
+}
+
+static inline void netfs_trans_put(struct netfs_trans *t)
+{
+	dprintk("%s: t: %p, gen: %u, refcnt: %d, err: %d.\n",
+		__func__, t, t->gen, atomic_read(&t->refcnt), t->result);
+	if (atomic_dec_and_test(&t->refcnt)) {
+		if (t->complete)
+			t->complete(t->pages, t->page_num,
+				t->private, t->result);
+		netfs_trans_free(t);
+	}
+}
+
+
+#endif /* __KERNEL__*/
+
+#endif /* __NETFS_H */
diff --git a/fs/pohmelfs/path_entry.c b/fs/pohmelfs/path_entry.c
new file mode 100644
index 0000000..884e7c3
--- /dev/null
+++ b/fs/pohmelfs/path_entry.c
@@ -0,0 +1,356 @@
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
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/ktime.h>
+#include <linux/fs.h>
+#include <linux/pagemap.h>
+#include <linux/writeback.h>
+#include <linux/mm.h>
+
+#include "netfs.h"
+
+/*
+ * Path cache.
+ *
+ * Used to create pathes to root, strings (or structures,
+ * containing name, mode, permissions and so on) used by userspace
+ * server to process data.
+ *
+ * Cache is local for client, and its inode numbers are never synced
+ * with anyone else, server operates on names and pathes, not some obscure ids.
+ */
+
+static void pohmelfs_free_path_entry(struct pohmelfs_path_entry *e)
+{
+	kfree(e);
+}
+
+static struct pohmelfs_path_entry *pohmelfs_alloc_path_entry(unsigned int len)
+{
+	struct pohmelfs_path_entry *e;
+
+	e = kzalloc(len + 1 + sizeof(struct pohmelfs_path_entry), GFP_KERNEL);
+	if (!e)
+		return NULL;
+
+	e->name = (char *)((struct pohmelfs_path_entry *)(e + 1));
+	e->len = len;
+	atomic_set(&e->refcnt, 1);
+
+	return e;
+}
+
+static inline int pohmelfs_cmp_path_entry(u64 path_ino, u64 new_ino)
+{
+	if (path_ino > new_ino)
+		return -1;
+	if (path_ino < new_ino)
+		return 1;
+	return 0;
+}
+
+static struct pohmelfs_path_entry *pohmelfs_search_path_entry(struct rb_root *root, u64 ino)
+{
+	struct rb_node *n = root->rb_node;
+	struct pohmelfs_path_entry *tmp;
+	int cmp;
+
+	while (n) {
+		tmp = rb_entry(n, struct pohmelfs_path_entry, path_entry);
+
+		cmp = pohmelfs_cmp_path_entry(tmp->ino, ino);
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else
+			return tmp;
+	}
+
+	dprintk("%s: Failed to find path entry for ino: %llu.\n", __func__, ino);
+	return NULL;
+}
+
+static struct pohmelfs_path_entry *pohmelfs_insert_path_entry(struct rb_root *root,
+		struct pohmelfs_path_entry *new)
+{
+	struct rb_node **n = &root->rb_node, *parent = NULL;
+	struct pohmelfs_path_entry *ret = NULL, *tmp;
+	int cmp;
+
+	while (*n) {
+		parent = *n;
+
+		tmp = rb_entry(parent, struct pohmelfs_path_entry, path_entry);
+
+		cmp = pohmelfs_cmp_path_entry(tmp->ino, new->ino);
+		if (cmp < 0)
+			n = &parent->rb_left;
+		else if (cmp > 0)
+			n = &parent->rb_right;
+		else {
+			ret = tmp;
+			break;
+		}
+	}
+
+	if (ret) {
+		printk("%s: exist: ino: %llu, data: '%s', new: ino: %llu, data: '%s'.\n",
+			__func__, ret->ino, ret->name, new->ino, new->name);
+		return ret;
+	}
+
+	rb_link_node(&new->path_entry, parent, n);
+	rb_insert_color(&new->path_entry, root);
+
+	dprintk("%s: inserted: ino: %llu, data: '%s', parent: ino: %llu, data: '%s'.\n",
+		__func__, new->ino, new->name, new->parent->ino, new->parent->name);
+
+	return new;
+}
+
+void pohmelfs_remove_path_entry(struct pohmelfs_sb *psb, struct pohmelfs_path_entry *e)
+{
+	if (atomic_dec_and_test(&e->refcnt)) {
+		rb_erase(&e->path_entry, &psb->path_root);
+
+		if (e->parent != e)
+			pohmelfs_remove_path_entry(psb, e->parent);
+		pohmelfs_free_path_entry(e);
+	}
+}
+
+void pohmelfs_remove_path_entry_by_ino(struct pohmelfs_sb *psb, u64 ino)
+{
+	struct pohmelfs_path_entry *e;
+
+	e = pohmelfs_search_path_entry(&psb->path_root, ino);
+	if (e)
+		pohmelfs_remove_path_entry(psb, e);
+}
+
+int pohmelfs_change_path_entry(struct pohmelfs_sb *psb, u64 ino, unsigned int mode)
+{
+	struct pohmelfs_path_entry *e;
+
+	e = pohmelfs_search_path_entry(&psb->path_root, ino);
+	if (!e)
+		return -ENOENT;
+
+	e->mode = mode;
+	return 0;
+}
+
+int pohmelfs_rename_path_entry(struct pohmelfs_sb *psb, u64 ino, u64 parent_ino, struct qstr *str)
+{
+	struct pohmelfs_path_entry *e;
+	unsigned int mode, link;
+
+	e = pohmelfs_search_path_entry(&psb->path_root, ino);
+	if (!e)
+		return -ENOENT;
+
+	if ((e->len >= str->len) && (parent_ino == e->parent->ino)) {
+		sprintf(e->name, "%s", str->name);
+		e->len = str->len;
+		e->hash = str->hash;
+
+		return 0;
+	}
+
+	mode = e->mode;
+	link = e->link;
+
+	pohmelfs_remove_path_entry(psb, e);
+
+	e = pohmelfs_add_path_entry(psb, parent_ino, ino, str, link, mode);
+	if (IS_ERR(e))
+		return PTR_ERR(e);
+
+	return 0;
+}
+
+struct pohmelfs_path_entry * pohmelfs_add_path_entry(struct pohmelfs_sb *psb,
+	u64 parent_ino, u64 ino, struct qstr *str, int link, unsigned int mode)
+{
+	struct pohmelfs_path_entry *e, *ret, *parent;
+
+	parent = pohmelfs_search_path_entry(&psb->path_root, parent_ino);
+
+	e = pohmelfs_alloc_path_entry(str->len);
+	if (!e)
+		return ERR_PTR(-ENOMEM);
+
+	e->parent = e;
+	if (parent) {
+		e->parent = parent;
+		atomic_inc(&parent->refcnt);
+	}
+
+	e->ino = ino;
+	e->hash = str->hash;
+	e->link = link;
+	e->mode = mode;
+
+	sprintf(e->name, "%s", str->name);
+
+	ret = pohmelfs_insert_path_entry(&psb->path_root, e);
+	if (ret != e) {
+		pohmelfs_free_path_entry(e);
+		e = ret;
+	}
+
+	dprintk("%s: parent: %llu, ino: %llu, name: '%s', len: %u.\n",
+			__func__, parent_ino, ino, e->name, e->len);
+
+	return e;
+}
+
+static int pohmelfs_prepare_path(struct pohmelfs_inode *pi, struct list_head *list, int len, int create)
+{
+	struct pohmelfs_path_entry *e;
+	struct pohmelfs_sb *psb = POHMELFS_SB(pi->vfs_inode.i_sb);
+
+	e = pohmelfs_search_path_entry(&psb->path_root, pi->ino);
+	if (!e)
+		return -ENOENT;
+
+	while (e && e->parent != e) {
+		if (len < e->len + create)
+			return -ETOOSMALL;
+
+		len -= e->len + create;
+
+		list_add(&e->entry, list);
+		e = e->parent;
+	}
+
+	return 0;
+}
+
+/*
+ * Create path from root for given inode.
+ * Path is formed as set of stuctures, containing name of the object
+ * and its inode data (mode, permissions and so on).
+ */
+int pohmelfs_construct_path(struct pohmelfs_inode *pi, void *data, int len)
+{
+	struct pohmelfs_path_entry *e;
+	struct netfs_path_entry *ne = data;
+	int used = 0, err;
+	LIST_HEAD(list);
+
+	err = pohmelfs_prepare_path(pi, &list, len, sizeof(struct netfs_path_entry));
+	if (err)
+		return err;
+
+	list_for_each_entry(e, &list, entry) {
+		ne = data;
+		ne->mode = e->mode;
+		ne->len = e->len;
+
+		used += sizeof(struct netfs_path_entry);
+		data += sizeof(struct netfs_path_entry);
+
+		if (ne->len <= sizeof(ne->unused)) {
+			memcpy(ne->unused, e->name, ne->len);
+		} else {
+			memcpy(data, e->name, ne->len);
+			data += ne->len;
+			used += ne->len;
+		}
+
+		dprintk("%s: ino: %llu, mode: %o, is_link: %d, name: '%s', used: %d, ne_len: %u.\n",
+				__func__, e->ino, ne->mode, e->link, e->name, used, ne->len);
+
+		netfs_convert_path_entry(ne);
+	}
+
+	return used;
+}
+
+/*
+ * Create path from root for given inode.
+ */
+int pohmelfs_construct_path_string(struct pohmelfs_inode *pi, void *data, int len)
+{
+	struct pohmelfs_path_entry *e;
+	int used = 0, err;
+	char *ptr = data;
+	LIST_HEAD(list);
+
+	err = pohmelfs_prepare_path(pi, &list, len, 0);
+	if (err)
+		return err;
+
+	if (list_empty(&list)) {
+		err = sprintf(ptr, "/");
+		ptr += err;
+		used += err;
+	} else {
+		list_for_each_entry(e, &list, entry) {
+			err = sprintf(ptr, "/%s", e->name);
+
+			BUG_ON(!e->name);
+
+			ptr += err;
+			used += err;
+		}
+	}
+
+	dprintk("%s: inode: %llu, full path: '%s', used: %d.\n",
+			__func__, pi->ino, (char *)data, used);
+
+	return used;
+}
+
+static int pohmelfs_get_path_length(struct pohmelfs_inode *pi, int create)
+{
+	struct pohmelfs_path_entry *e;
+	struct pohmelfs_sb *psb = POHMELFS_SB(pi->vfs_inode.i_sb);
+	int len = 1 + create;
+
+	e = pohmelfs_search_path_entry(&psb->path_root, pi->ino);
+
+	/*
+	 * This should never happen actually.
+	 */
+	if (!e)
+		return -ENOENT;
+
+	while (e && e->parent != e) {
+		len += e->len + create + 1;
+		e = e->parent;
+	}
+
+	return len;
+}
+
+int pohmelfs_path_length(struct pohmelfs_inode *pi)
+{
+	int len = pohmelfs_get_path_length(pi, 0);
+
+	if (len < 0)
+		return len;
+	return len + 1;
+}
+
+int pohmelfs_path_length_create(struct pohmelfs_inode *pi)
+{
+	return pohmelfs_get_path_length(pi, sizeof(struct netfs_path_entry));
+}
diff --git a/fs/pohmelfs/trans.c b/fs/pohmelfs/trans.c
new file mode 100644
index 0000000..f82b651
--- /dev/null
+++ b/fs/pohmelfs/trans.c
@@ -0,0 +1,719 @@
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
+#include <linux/crypto.h>
+#include <linux/fs.h>
+#include <linux/jhash.h>
+#include <linux/hash.h>
+#include <linux/ktime.h>
+#include <linux/mempool.h>
+#include <linux/mm.h>
+#include <linux/mount.h>
+#include <linux/pagemap.h>
+#include <linux/parser.h>
+#include <linux/poll.h>
+#include <linux/swap.h>
+#include <linux/slab.h>
+#include <linux/statfs.h>
+#include <linux/writeback.h>
+
+#include "netfs.h"
+
+static struct kmem_cache *netfs_trans_dst;
+static mempool_t *netfs_trans_dst_pool;
+
+static void netfs_trans_init_static(struct netfs_trans *t, int num, int size)
+{
+	t->page_num = num;
+	t->total_size = size;
+	atomic_set(&t->refcnt, 1);
+
+	mutex_init(&t->dst_lock);
+	INIT_LIST_HEAD(&t->dst_list);
+}
+
+static int netfs_trans_send_pages(struct netfs_trans *t, struct netfs_state *st)
+{
+	int err = 0;
+	unsigned int i, attached_pages = t->attached_pages, ci;
+	struct msghdr msg;
+	struct page **pages = (t->eng)?t->eng->pages:t->pages;
+	struct page *p;
+	unsigned int size;
+
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_WAITALL | MSG_MORE;
+
+	ci = 0;
+	for (i=0; i<t->page_num; ++i) {
+		struct page *page = pages[ci];
+		struct netfs_cmd cmd;
+		struct iovec io;
+
+		p = t->pages[i];
+
+		if (!p)
+			continue;
+
+		size = page_private(p);
+
+		io.iov_base = &cmd;
+		io.iov_len = sizeof(struct netfs_cmd);
+
+		cmd.cmd = NETFS_WRITE_PAGE;
+		cmd.ext = 0;
+		cmd.id = 0;
+		cmd.size = size;
+		cmd.start = p->index;
+		cmd.start <<= PAGE_CACHE_SHIFT;
+		cmd.csize = 0;
+		cmd.cpad = 0;
+		cmd.iv = pohmelfs_gen_iv(t);
+
+		netfs_convert_cmd(&cmd);
+
+		msg.msg_iov = &io;
+		msg.msg_iovlen = 1;
+		msg.msg_flags = MSG_WAITALL | MSG_MORE;
+
+		err = kernel_sendmsg(st->socket, &msg, (struct kvec *)msg.msg_iov, 1, sizeof(struct netfs_cmd));
+		if (err <= 0) {
+			printk("%s: %d/%d failed to send transaction header: t: %p, gen: %u, err: %d.\n",
+					__func__, i, t->page_num, t, t->gen, err);
+			if (err == 0)
+				err = -ECONNRESET;
+			goto err_out;
+		}
+
+		msg.msg_flags = MSG_WAITALL|(attached_pages == 1)?0:MSG_MORE;
+
+		err = kernel_sendpage(st->socket, page, 0, size, msg.msg_flags);
+		if (err <= 0) {
+			printk("%s: %d/%d failed to send transaction page: t: %p, gen: %u, size: %u, err: %d.\n",
+					__func__, i, t->page_num, t, t->gen, size, err);
+			if (err == 0)
+				err = -ECONNRESET;
+			goto err_out;
+		}
+
+		dprintk("%s: %d/%d sent t: %p, gen: %u, page: %p/%p, size: %u.\n",
+			__func__, i, t->page_num, t, t->gen, page, p, size);
+
+		err = 0;
+		attached_pages--;
+		if (!attached_pages)
+			break;
+		ci++;
+
+		continue;
+
+err_out:
+		printk("%s: t: %p, gen: %u, err: %d.\n", __func__, t, t->gen, err);
+		netfs_state_exit(st);
+		break;
+	}
+
+	return err;
+}
+
+int netfs_trans_send(struct netfs_trans *t, struct netfs_state *st)
+{
+	int err;
+	struct msghdr msg;
+
+	netfs_state_lock(st);
+	if (!st->socket) {
+		err = netfs_state_init(st);
+		if (err)
+			goto err_out_unlock_return;
+	}
+
+	msg.msg_iov = &t->iovec;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_WAITALL;
+
+	if (t->attached_pages)
+		msg.msg_flags |= MSG_MORE;
+
+	err = kernel_sendmsg(st->socket, &msg, (struct kvec *)msg.msg_iov, 1, t->iovec.iov_len);
+	if (err <= 0) {
+		printk("%s: failed to send contig transaction: t: %p, gen: %u, size: %u, err: %d.\n",
+				__func__, t, t->gen, t->iovec.iov_len, err);
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_unlock_return;
+	}
+
+	dprintk("%s: sent %s transaction: t: %p, gen: %u, size: %u, page_num: %u.\n",
+			__func__, (t->page_num)?"partial":"full",
+			t, t->gen, t->iovec.iov_len, t->page_num);
+
+	err = 0;
+	if (t->attached_pages)
+		err = netfs_trans_send_pages(t, st);
+
+err_out_unlock_return:
+	netfs_state_unlock(st);
+	
+	dprintk("%s: t: %p, gen: %u, err: %d.\n",
+		__func__, t, t->gen, err);
+
+	t->result = err;
+	return err;
+}
+
+static inline int netfs_trans_cmp(unsigned int gen, unsigned int new)
+{
+	if (gen < new)
+		return 1;
+	if (gen > new)
+		return -1;
+	return 0;
+}
+
+struct netfs_trans_dst *netfs_trans_search(struct netfs_state *st, unsigned int gen)
+{
+	struct rb_root *root = &st->trans_root;
+	struct rb_node *n = root->rb_node;
+	struct netfs_trans_dst *tmp, *ret = NULL;
+	struct netfs_trans *t;
+	int cmp;
+
+	while (n) {
+		tmp = rb_entry(n, struct netfs_trans_dst, state_entry);
+		t = tmp->trans;
+
+		cmp = netfs_trans_cmp(t->gen, gen);
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else {
+			ret = tmp;
+			break;
+		}
+	}
+
+	return ret;
+}
+
+static int netfs_trans_insert(struct netfs_trans_dst *ndst, struct netfs_state *st)
+{
+	struct rb_root *root = &st->trans_root;
+	struct rb_node **n = &root->rb_node, *parent = NULL;
+	struct netfs_trans_dst *ret = NULL, *tmp;
+	struct netfs_trans *t = NULL, *new = ndst->trans;
+	int cmp;
+
+	while (*n) {
+		parent = *n;
+
+		tmp = rb_entry(parent, struct netfs_trans_dst, state_entry);
+		t = tmp->trans;
+
+		cmp = netfs_trans_cmp(t->gen, new->gen);
+		if (cmp < 0)
+			n = &parent->rb_left;
+		else if (cmp > 0)
+			n = &parent->rb_right;
+		else {
+			ret = tmp;
+			break;
+		}
+	}
+
+	if (ret) {
+		printk("%s: exist: old: gen: %u, flags: %x, send_time: %lu, "
+				"new: gen: %u, flags: %x, send_time: %lu.\n",
+			__func__, t->gen, t->flags, ret->send_time,
+			new->gen, new->flags, ndst->send_time);
+		return -EEXIST;
+	}
+
+	rb_link_node(&ndst->state_entry, parent, n);
+	rb_insert_color(&ndst->state_entry, root);
+	ndst->send_time = jiffies;
+
+	dprintk("%s: inserted: gen: %u, flags: %x, send_time: %lu.\n",
+		__func__, new->gen, new->flags, ndst->send_time);
+
+	return 0;
+}
+
+int netfs_trans_remove_nolock(struct netfs_trans_dst *dst, struct netfs_state *st)
+{
+	if (dst && dst->state_entry.rb_parent_color) {
+		rb_erase(&dst->state_entry, &st->trans_root);
+		dst->state_entry.rb_parent_color = 0;
+		return 1;
+	}
+	return 0;
+}
+
+static int netfs_trans_remove_state(struct netfs_trans_dst *dst)
+{
+	int ret;
+	struct netfs_state *st = dst->state;
+
+	mutex_lock(&st->trans_lock);
+	ret = netfs_trans_remove_nolock(dst, st);
+	mutex_unlock(&st->trans_lock);
+
+	return ret;
+}
+
+/*
+ * Create new destination for given transaction associated with given network state.
+ * Transaction's reference counter is bumped and will be dropped when either
+ * reply is received or when async timeout detection task will fail resending
+ * and drop transaction.
+ */
+static int netfs_trans_push_dst(struct netfs_trans *t, struct netfs_state *st)
+{
+	struct netfs_trans_dst *dst;
+	int err;
+
+	dst = mempool_alloc(netfs_trans_dst_pool, GFP_KERNEL);
+	if (!dst)
+		return -ENOMEM;
+
+	dst->retries = 0;
+	dst->send_time = 0;
+	dst->state = st;
+	dst->trans = t;
+	netfs_trans_get(t);
+
+	mutex_lock(&st->trans_lock);
+	err = netfs_trans_insert(dst, st);
+	mutex_unlock(&st->trans_lock);
+
+	if (err)
+		goto err_out_free;
+
+	mutex_lock(&t->dst_lock);
+	list_add_tail(&dst->trans_entry, &t->dst_list);
+	mutex_unlock(&t->dst_lock);
+
+	dprintk("%s: t: %p, gen: %u, state: %p, dst: %p.\n",
+			__func__, t, t->gen, st, dst);
+
+	return 0;
+
+err_out_free:
+	t->result = err;
+	netfs_trans_put(t);
+	mempool_free(dst, netfs_trans_dst_pool);
+	return err;
+}
+
+static void netfs_trans_free_dst(struct netfs_trans_dst *dst)
+{
+	dprintk("%s: t: %p, gen: %u, state: %p, dst: %p.\n",
+		__func__, dst->trans, dst->trans->gen, dst->state, dst);
+
+	netfs_trans_put(dst->trans);
+	mempool_free(dst, netfs_trans_dst_pool);
+}
+
+static void netfs_trans_remove_dst(struct netfs_trans_dst *dst)
+{
+	netfs_trans_remove_state(dst);
+	netfs_trans_free_dst(dst);
+}
+
+/*
+ * Drop destination transaction entry when we know it.
+ */
+void netfs_trans_drop_dst(struct netfs_trans_dst *dst)
+{
+	struct netfs_trans *t = dst->trans;
+
+	mutex_lock(&t->dst_lock);
+	list_del_init(&dst->trans_entry);
+	mutex_unlock(&t->dst_lock);
+
+	netfs_trans_remove_dst(dst);
+}
+
+/*
+ * Drop destination transaction entry when we know it and when we
+ * already removed dst from state tree.
+ */
+void netfs_trans_drop_dst_nostate(struct netfs_trans_dst *dst)
+{
+	struct netfs_trans *t = dst->trans;
+
+	dprintk("%s: t: %p, gen: %u, state: %p, dst: %p.\n",
+			__func__, t, t->gen, dst->state, dst);
+
+	mutex_lock(&t->dst_lock);
+	list_del_init(&dst->trans_entry);
+	mutex_unlock(&t->dst_lock);
+	
+	netfs_trans_free_dst(dst);
+}
+
+/*
+ * This drops destination transaction entry from appropriate network state
+ * tree and drops related reference counter. It is possible that transaction
+ * will be freed here if its reference counter hits zero.
+ * Destination transaction entry will be freed.
+ */
+void netfs_trans_drop_trans(struct netfs_trans *t, struct netfs_state *st)
+{
+	struct netfs_trans_dst *dst, *tmp, *ret = NULL;
+
+	mutex_lock(&t->dst_lock);
+	list_for_each_entry_safe(dst, tmp, &t->dst_list, trans_entry) {
+		if (dst->state == st) {
+			ret = dst;
+			list_del(&dst->trans_entry);
+			break;
+		}
+	}
+	mutex_unlock(&t->dst_lock);
+
+	if (ret)
+		netfs_trans_remove_dst(ret);
+}
+
+/*
+ * This drops destination transaction entry from appropriate network state
+ * tree and drops related reference counter. It is possible that transaction
+ * will be freed here if its reference counter hits zero.
+ * Destination transaction entry will be freed.
+ */
+void netfs_trans_drop_last(struct netfs_trans *t, struct netfs_state *st)
+{
+	struct netfs_trans_dst *dst, *tmp, *ret;
+
+	mutex_lock(&t->dst_lock);
+	ret = list_entry(t->dst_list.prev, struct netfs_trans_dst, trans_entry);
+	if (ret->state != st) {
+		ret = NULL;
+		list_for_each_entry_safe(dst, tmp, &t->dst_list, trans_entry) {
+			if (dst->state == st) {
+				ret = dst;
+				list_del_init(&dst->trans_entry);
+				break;
+			}
+		}
+	} else {
+		list_del(&ret->trans_entry);
+	}
+	mutex_unlock(&t->dst_lock);
+
+	if (ret)
+		netfs_trans_remove_dst(ret);
+}
+
+static int netfs_trans_push(struct netfs_trans *t, struct netfs_state *st)
+{
+	int err;
+
+	err = netfs_trans_push_dst(t, st);
+	if (err)
+		return err;
+
+	err = netfs_trans_send(t, st);
+	if (err)
+		goto err_out_free;
+
+	if (t->flags & NETFS_TRANS_SINGLE_DST)
+		pohmelfs_switch_active(st->psb);
+
+	return 0;
+
+err_out_free:
+	t->result = err;
+	netfs_trans_drop_last(t, st);
+
+	return err;
+}
+
+int netfs_trans_finish_send(struct netfs_trans *t, struct pohmelfs_sb *psb)
+{
+	struct pohmelfs_config *c;
+	int err = -ENODEV;
+	struct netfs_state *st;
+
+	dprintk("%s: t: %p, gen: %u, size: %u, page_num: %u, active: %p.\n",
+		__func__, t, t->gen, t->iovec.iov_len, t->page_num, psb->active_state);
+
+	mutex_lock(&psb->state_lock);
+	if ((t->flags & NETFS_TRANS_SINGLE_DST) && psb->active_state) {
+		st = &psb->active_state->state;
+
+		err = -EPIPE;
+		if (netfs_state_poll(st) & POLLOUT) {
+			err = netfs_trans_push_dst(t, st);
+			if (!err) {
+				err = netfs_trans_send(t, st);
+				if (err) {
+					netfs_trans_drop_last(t, st);
+				} else {
+					pohmelfs_switch_active(psb);
+					goto out;
+				}
+			}
+		}
+		pohmelfs_switch_active(psb);
+	}
+
+	list_for_each_entry(c, &psb->state_list, config_entry) {
+		st = &c->state;
+
+		err = netfs_trans_push(t, st);
+		if (!err && (t->flags & NETFS_TRANS_SINGLE_DST))
+			break;
+	}
+out:
+	mutex_unlock(&psb->state_lock);
+
+	dprintk("%s: fully sent t: %p, gen: %u, size: %u, page_num: %u, err: %d.\n",
+		__func__, t, t->gen, t->iovec.iov_len, t->page_num, err);
+
+	if (err)
+		t->result = err;
+	return err;
+}
+
+int netfs_trans_finish(struct netfs_trans *t, struct pohmelfs_sb *psb)
+{
+	int err;
+	struct netfs_cmd *cmd = t->iovec.iov_base;
+
+	t->gen = atomic_inc_return(&psb->trans_gen);
+
+	cmd->size = t->iovec.iov_len - sizeof(struct netfs_cmd) +
+		t->attached_size + t->attached_pages * sizeof(struct netfs_cmd);
+	cmd->cmd = NETFS_TRANS;
+	cmd->start = t->gen;
+	cmd->id = 0;
+
+	if (psb->perform_crypto) {
+		cmd->ext = psb->crypto_attached_size;
+		cmd->csize = psb->crypto_attached_size;
+	}
+
+	dprintk("%s: crypto_attached_size: %u.\n", __func__, psb->crypto_attached_size);
+
+	err = pohmelfs_trans_crypt(t, psb);
+	dprintk("%s: putting transaction %p, gen: %u, err: %d.\n", __func__, t, t->gen, err);
+	if (err)
+		t->result = err;
+	netfs_trans_put(t);
+	return err;
+}
+
+/*
+ * Resend transaction to remote server(s).
+ * If new servers were added into superblock, we can try to send data
+ * to them too.
+ *
+ * It is called under superblock's state_lock, so we can safely
+ * dereference psb->state_list. Also, transaction's reference counter is
+ * bumped, so it can not go away under us, thus we can safely access all
+ * its members. State is locked.
+ *
+ * This function returns 0 if transaction was successfully sent to at
+ * least one destination target. 
+ */
+int netfs_trans_resend(struct netfs_trans *t, struct pohmelfs_sb *psb)
+{
+	struct netfs_trans_dst *dst;
+	struct netfs_state *st;
+	struct pohmelfs_config *c;
+	int err, exist, error = -ENODEV;
+
+	list_for_each_entry(c, &psb->state_list, config_entry) {
+		st = &c->state;
+
+		exist = 0;
+		mutex_lock(&t->dst_lock);
+		list_for_each_entry(dst, &t->dst_list, trans_entry) {
+			if (st == dst->state) {
+				exist = 1;
+				break;
+			}
+		}
+		mutex_unlock(&t->dst_lock);
+
+		if (exist) {
+			if (!(t->flags & NETFS_TRANS_SINGLE_DST)) {
+				dprintk("%s: resending st: %p, t: %p, gen: %u.\n",
+						__func__, st, t, t->gen);
+				err = netfs_trans_send(t, st);
+				if (!err)
+					error = 0;
+			}
+			continue;
+		}
+
+		dprintk("%s: pushing/resending st: %p, t: %p, gen: %u.\n",
+				__func__, st, t, t->gen);
+		err = netfs_trans_push(t, st);
+		if (err)
+			continue;
+		error = 0;
+		if (t->flags & NETFS_TRANS_SINGLE_DST)
+			break;
+	}
+
+	t->result = error;
+	return error;
+}
+
+void *netfs_trans_add(struct netfs_trans *t, unsigned int size)
+{
+	struct iovec *io = &t->iovec;
+	void *ptr;
+
+	if (size > t->total_size) {
+		ptr = ERR_PTR(-EINVAL);
+		goto out;
+	}
+
+	if (io->iov_len + size > t->total_size) {
+		dprintk("%s: too big size t: %p, gen: %u, iov_len: %u, size: %u, total: %u.\n",
+				__func__, t, t->gen, io->iov_len, size, t->total_size);
+		ptr = ERR_PTR(-E2BIG);
+		goto out;
+	}
+
+	ptr = io->iov_base + io->iov_len;
+	io->iov_len += size;
+
+out:
+	dprintk("%s: t: %p, gen: %u, size: %u, total: %u.\n",
+		__func__, t, t->gen, size, io->iov_len);
+	return ptr;
+}
+
+void netfs_trans_free(struct netfs_trans *t)
+{
+	dprintk("%s: t: %p, gen: %u.\n", __func__, t, t->gen);
+	if (t->eng)
+		pohmelfs_crypto_thread_make_ready(t->eng->thread);
+	kfree(t);
+}
+
+struct netfs_trans *netfs_trans_alloc(struct pohmelfs_sb *psb, unsigned int size,
+		unsigned int flags, unsigned int nr)
+{
+	struct netfs_trans *t;
+	unsigned int num, cont, pad, size_no_trans;
+	unsigned int crypto_added = 0;
+	struct netfs_cmd *cmd;
+
+	if (psb->perform_crypto)
+		crypto_added = psb->crypto_attached_size;
+
+	/*
+	 * |sizeof(struct netfs_trans)|
+	 * |sizeof(struct netfs_cmd)| - transaction header
+	 * |size| - buffer with requested size
+	 * |padding| - crypto padding, zero bytes
+	 * |nr * sizeof(struct page *)| - array of page pointers
+	 *
+	 * Overall size should be less than PAGE_SIZE for guaranteed allocation.
+	 */
+
+	cont = size;
+	size = ALIGN(size, psb->crypto_align_size);
+	pad = size - cont;
+
+	size_no_trans = size + sizeof(struct netfs_cmd) * 2 + crypto_added;
+
+	cont = sizeof(struct netfs_trans) + size_no_trans;
+
+	dprintk("%s: size: %u, padding: %u, align_size: %u, cont: %u.\n",
+		__func__, size, pad, psb->crypto_align_size, cont);
+
+	num = (PAGE_SIZE - cont)/sizeof(struct page *);
+
+	if (nr > num)
+		nr = num;
+
+	t = kzalloc(cont + nr*sizeof(struct page *), GFP_NOIO);
+	if (!t)
+		goto err_out_exit;
+
+	memset(t, 0, sizeof(struct netfs_trans));
+
+	t->iovec.iov_base = (void *)(t + 1);
+	t->pages = (struct page **)(t->iovec.iov_base + size_no_trans);
+
+	/*
+	 * Reserving space for transaction header.
+	 */
+	t->iovec.iov_len = sizeof(struct netfs_cmd) + crypto_added;
+
+	t->page_num = nr;
+	netfs_trans_init_static(t, nr, size_no_trans);
+
+	t->flags = flags;
+	t->psb = psb;
+
+	cmd = (struct netfs_cmd *)t->iovec.iov_base;
+
+	cmd->size = size;
+	cmd->cpad = pad;
+	cmd->csize = crypto_added;
+
+	dprintk("%s: t: %p, gen: %u, size: %u, flags: %x, page_num: %u, base: %p, pages: %p.\n",
+			__func__, t, t->gen, size, flags, nr,
+			t->iovec.iov_base, t->pages);
+
+	return t;
+
+err_out_exit:
+	return NULL;
+}
+
+int netfs_trans_init(void)
+{
+	int err = -ENOMEM;
+
+	netfs_trans_dst = kmem_cache_create("netfs_trans_dst", sizeof(struct netfs_trans_dst),
+			0, 0, NULL);
+	if (!netfs_trans_dst)
+		goto err_out_exit;
+
+	netfs_trans_dst_pool = mempool_create_slab_pool(256, netfs_trans_dst);
+	if (!netfs_trans_dst_pool)
+		goto err_out_free;
+
+	return 0;
+
+err_out_free:
+	kmem_cache_destroy(netfs_trans_dst);
+err_out_exit:
+	return err;
+}
+
+void netfs_trans_exit(void)
+{
+	mempool_destroy(netfs_trans_dst_pool);
+	kmem_cache_destroy(netfs_trans_dst);
+}



-- 
	Evgeniy Polyakov
