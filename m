From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [4/5] POHMELFS: crypto, locking, path and cmd caches.
Date: Tue, 18 Nov 2008 22:33:49 +0300
Message-ID: <12270368313997-git-send-email-zbr@ioremap.net>
References: <12270368303809-git-send-email-zbr@ioremap.net>
 <12270368303340-git-send-email-zbr@ioremap.net>
 <12270368304071-git-send-email-zbr@ioremap.net>
 <12270368313854-git-send-email-zbr@ioremap.net>
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Evgeniy Polyakov <zbr@ioremap.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <12270368313854-git-send-email-zbr@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/fs/pohmelfs/crypto.c b/fs/pohmelfs/crypto.c
new file mode 100644
index 0000000..249bed1
--- /dev/null
+++ b/fs/pohmelfs/crypto.c
@@ -0,0 +1,880 @@
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
+	if (!e->cipher && !e->hash)
+		return 0;
+
+	dprintk("%s: eng: %p, iv: %llx, data: %p, page: %p/%lu, size: %u.\n",
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
+				dprintka("%02x ", recv[i]);
+				if (recv[i] != calc[i]) {
+					dprintka("| calc byte: %02x.\n", calc[i]);
+					break;
+				}
+#else
+				dprintka("%02x/%02x ", recv[i], calc[i]);
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
+	dprintk("%s: eng: %p, size: %u, hash: %p, cipher: %p: completed.\n",
+			__func__, e, e->size, e->hash, e->cipher);
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
+			dprintka("%02x ", dst[i]);
+		dprintka("\n");
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
+	struct pohmelfs_sb *psb = t->psb;
+
+	if (t->thread)
+		kthread_stop(t->thread);
+
+	mutex_lock(&psb->crypto_thread_lock);
+	list_del(&t->thread_entry);
+	psb->crypto_thread_num--;
+	mutex_unlock(&psb->crypto_thread_lock);
+
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
+static void pohmelfs_crypto_flush(struct pohmelfs_sb *psb, struct list_head *head)
+{
+	while (!list_empty(head)) {
+		struct pohmelfs_crypto_thread *t = NULL;
+
+		mutex_lock(&psb->crypto_thread_lock);
+		if (!list_empty(head)) {
+			t = list_first_entry(head, struct pohmelfs_crypto_thread, thread_entry);
+			list_del_init(&t->thread_entry);
+		}
+		mutex_unlock(&psb->crypto_thread_lock);
+
+		if (t)
+			pohmelfs_sys_crypto_exit_one(t);
+	}
+}
+
+static void pohmelfs_sys_crypto_exit(struct pohmelfs_sb *psb)
+{
+	while (!list_empty(&psb->crypto_active_list) || !list_empty(&psb->crypto_ready_list)) {
+		dprintk("%s: crypto_thread_num: %u.\n", __func__, psb->crypto_thread_num);
+		pohmelfs_crypto_flush(psb, &psb->crypto_active_list);
+		pohmelfs_crypto_flush(psb, &psb->crypto_ready_list);
+	}
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

diff --git a/fs/pohmelfs/lock.c b/fs/pohmelfs/lock.c
new file mode 100644
index 0000000..0f8b49e
--- /dev/null
+++ b/fs/pohmelfs/lock.c
@@ -0,0 +1,168 @@
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
+#include <linux/fs.h>
+#include <linux/fsnotify.h>
+#include <linux/slab.h>
+#include <linux/mempool.h>
+
+#include "netfs.h"
+
+static int pohmelfs_send_lock_trans(struct pohmelfs_inode *pi,
+		u64 id, u64 start, u32 size, int type)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(pi->vfs_inode.i_sb);
+	struct netfs_trans *t;
+	struct netfs_cmd *cmd;
+	int path_len, err;
+	void *data;
+	struct netfs_lock *l;
+
+	mutex_lock(&psb->path_lock);
+	err = pohmelfs_path_length(pi);
+	mutex_unlock(&psb->path_lock);
+
+	if (err < 0)
+		goto err_out_exit;
+
+	path_len = err;
+
+	err = -ENOMEM;
+	t = netfs_trans_alloc(psb, path_len + sizeof(struct netfs_lock), 0, 0);
+	if (!t)
+		goto err_out_exit;
+
+	cmd = netfs_trans_current(t);
+	data = cmd + 1;
+	l = data + path_len;
+
+	cmd->cmd = NETFS_LOCK;
+	cmd->start = 0;
+	cmd->id = id;
+	cmd->size = sizeof(struct netfs_lock) + path_len;
+	cmd->ext = path_len;
+	cmd->csize = 0;
+
+	netfs_convert_cmd(cmd);
+
+	mutex_lock(&psb->path_lock);
+	err = pohmelfs_construct_path_string(pi, cmd+1, path_len);
+	mutex_unlock(&psb->path_lock);
+	if (err < 0)
+		goto err_out_free;
+
+	l->start = start;
+	l->size = size;
+	l->type = type;
+	l->ino = pi->ino;
+
+	netfs_convert_lock(l);
+
+	netfs_trans_update(cmd, t, path_len + sizeof(struct netfs_lock));
+
+	return netfs_trans_finish(t, psb);
+
+err_out_free:
+	netfs_trans_free(t);
+err_out_exit:
+	return err;
+}
+
+int pohmelfs_data_lock(struct pohmelfs_inode *pi, u64 start, u32 size, int type)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(pi->vfs_inode.i_sb);
+	struct pohmelfs_mcache *m;
+	int err = -ENOMEM;
+	struct iattr iattr;
+	struct inode *inode = &pi->vfs_inode;
+
+	dprintk("%s: %p: ino: %llu, start: %llu, size: %u, "
+			"type: %d, locked as: %d, owned: %d.\n",
+			__func__, &pi->vfs_inode, pi->ino,
+			start, size, type, pi->lock_type,
+			!!test_bit(NETFS_INODE_OWNED, &pi->state));
+
+	if (test_bit(NETFS_INODE_OWNED, &pi->state) && (type == pi->lock_type))
+		return 0;
+
+	if ((type == POHMELFS_READ_LOCK) && (pi->lock_type == POHMELFS_WRITE_LOCK))
+		return 0;
+
+	clear_bit(NETFS_INODE_OWNED, &pi->state);
+	clear_bit(NETFS_INODE_REMOTE_SYNCED, &pi->state);
+
+	m = pohmelfs_mcache_alloc(psb, start, size, NULL);
+	if (IS_ERR(m))
+		return PTR_ERR(m);
+
+	err = pohmelfs_send_lock_trans(pi, m->gen, start, size,
+			type | POHMELFS_LOCK_GRAB);
+	if (err)
+		goto err_out_put;
+
+	err = wait_for_completion_timeout(&m->complete, psb->mcache_timeout);
+	if (err)
+		err = m->err;
+	else
+		err = -ETIMEDOUT;
+
+	dprintk("%s: %p: ino: %llu, mgen: %llu, start: %llu, size: %u, err: %d.\n",
+		__func__, &pi->vfs_inode, pi->ino, m->gen, start, size, err);
+
+	if (err)
+		goto err_out_put;
+
+	netfs_convert_inode_info(&m->info);
+
+	iattr.ia_valid = ATTR_MODE | ATTR_UID | ATTR_GID | ATTR_SIZE | ATTR_ATIME;
+	iattr.ia_mode = m->info.mode;
+	iattr.ia_uid = m->info.uid;
+	iattr.ia_gid = m->info.gid;
+	iattr.ia_size = m->info.size;
+	iattr.ia_atime = CURRENT_TIME;
+
+	err = pohmelfs_setattr_raw(inode, &iattr);
+	if (!err) {
+		struct dentry *dentry = d_find_alias(inode);
+		if (dentry) {
+			fsnotify_change(dentry, iattr.ia_valid);
+			dput(dentry);
+		}
+	}
+
+	pi->lock_type = type;
+	set_bit(NETFS_INODE_OWNED, &pi->state);
+
+	pohmelfs_mcache_put(psb, m);
+
+	return 0;
+
+err_out_put:
+	pohmelfs_mcache_put(psb, m);
+	return err;
+}
+
+int pohmelfs_data_unlock(struct pohmelfs_inode *pi, u64 start, u32 size, int type)
+{
+	dprintk("%s: %p: ino: %llu, start: %llu, size: %u, type: %d.\n",
+			__func__, &pi->vfs_inode, pi->ino, start, size, type);
+	pi->lock_type = 0;
+	clear_bit(NETFS_INODE_OWNED, &pi->state);
+	clear_bit(NETFS_INODE_REMOTE_SYNCED, &pi->state);
+	pohmelfs_meta_command(pi, NETFS_INODE_INFO, 0, NULL, NULL, 0);
+	return pohmelfs_send_lock_trans(pi, pi->ino, start, size, type);
+}
diff --git a/fs/pohmelfs/mcache.c b/fs/pohmelfs/mcache.c
new file mode 100644
index 0000000..5a7d799
--- /dev/null
+++ b/fs/pohmelfs/mcache.c
@@ -0,0 +1,178 @@
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
+#include <linux/mempool.h>
+
+#include "netfs.h"
+
+static struct kmem_cache *pohmelfs_mcache_cache;
+static mempool_t *pohmelfs_mcache_pool;
+
+static void pohmelfs_mcache_init_once(void *data)
+{
+	struct pohmelfs_mcache *m = data;
+
+	atomic_set(&m->refcnt, 1);
+	init_completion(&m->complete);
+	m->err = 0;
+}
+
+static inline int pohmelfs_mcache_cmp(u64 gen, u64 new)
+{
+	if (gen < new)
+		return 1;
+	if (gen > new)
+		return -1;
+	return 0;
+}
+
+struct pohmelfs_mcache *pohmelfs_mcache_search(struct pohmelfs_sb *psb, u64 gen)
+{
+	struct rb_root *root = &psb->mcache_root;
+	struct rb_node *n = root->rb_node;
+	struct pohmelfs_mcache *tmp, *ret = NULL;
+	int cmp;
+
+	while (n) {
+		tmp = rb_entry(n, struct pohmelfs_mcache, mcache_entry);
+
+		cmp = pohmelfs_mcache_cmp(tmp->gen, gen);
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else {
+			ret = tmp;
+			pohmelfs_mcache_get(ret);
+			break;
+		}
+	}
+
+	return ret;
+}
+
+static int pohmelfs_mcache_insert(struct pohmelfs_sb *psb, struct pohmelfs_mcache *m)
+{
+	struct rb_root *root = &psb->mcache_root;
+	struct rb_node **n = &root->rb_node, *parent = NULL;
+	struct pohmelfs_mcache *ret = NULL, *tmp;
+	int cmp;
+
+	while (*n) {
+		parent = *n;
+
+		tmp = rb_entry(parent, struct pohmelfs_mcache, mcache_entry);
+
+		cmp = pohmelfs_mcache_cmp(tmp->gen, m->gen);
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
+		return -EEXIST;
+
+	rb_link_node(&m->mcache_entry, parent, n);
+	rb_insert_color(&m->mcache_entry, root);
+
+	return 0;
+}
+
+static int pohmelfs_mcache_remove(struct pohmelfs_sb *psb, struct pohmelfs_mcache *m)
+{
+	if (m && m->mcache_entry.rb_parent_color) {
+		rb_erase(&m->mcache_entry, &psb->mcache_root);
+		m->mcache_entry.rb_parent_color = 0;
+		return 1;
+	}
+	return 0;
+}
+
+void pohmelfs_mcache_remove_locked(struct pohmelfs_sb *psb, struct pohmelfs_mcache *m)
+{
+	mutex_lock(&psb->mcache_lock);
+	pohmelfs_mcache_remove(psb, m);
+	mutex_unlock(&psb->mcache_lock);
+}
+
+struct pohmelfs_mcache *pohmelfs_mcache_alloc(struct pohmelfs_sb *psb, u64 start,
+		unsigned int size, void *data)
+{
+	struct pohmelfs_mcache *m;
+	int err = -ENOMEM;
+
+	m = mempool_alloc(pohmelfs_mcache_pool, GFP_KERNEL);
+	if (!m)
+		goto err_out_exit;
+
+	m->data = data;
+	m->start = start;
+	m->size = size;
+	m->gen = atomic_long_inc_return(&psb->mcache_gen);
+
+	mutex_lock(&psb->mcache_lock);
+	err = pohmelfs_mcache_insert(psb, m);
+	mutex_unlock(&psb->mcache_lock);
+	if (err)
+		goto err_out_free;
+
+	return m;
+
+err_out_free:
+	mempool_free(m, pohmelfs_mcache_pool);
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+void pohmelfs_mcache_free(struct pohmelfs_sb *psb, struct pohmelfs_mcache *m)
+{
+	pohmelfs_mcache_remove_locked(psb, m);
+
+	mempool_free(m, pohmelfs_mcache_pool);
+}
+
+int __init pohmelfs_mcache_init(void)
+{
+	pohmelfs_mcache_cache = kmem_cache_create("pohmelfs_mcache_cache",
+				sizeof(struct pohmelfs_mcache),
+				0, (SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD),
+				pohmelfs_mcache_init_once);
+	if (!pohmelfs_mcache_cache)
+		goto err_out_exit;
+
+	pohmelfs_mcache_pool = mempool_create_slab_pool(256, pohmelfs_mcache_cache);
+	if (!pohmelfs_mcache_pool)
+		goto err_out_free;
+
+	return 0;
+
+err_out_free:
+	kmem_cache_destroy(pohmelfs_mcache_cache);
+err_out_exit:
+	return -ENOMEM;
+}
+
+void pohmelfs_mcache_exit(void)
+{
+	mempool_destroy(pohmelfs_mcache_pool);
+	kmem_cache_destroy(pohmelfs_mcache_cache);
+}

diff --git a/fs/pohmelfs/path_entry.c b/fs/pohmelfs/path_entry.c
new file mode 100644
index 0000000..2dcbce7
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
+	return len;
+}
+
+int pohmelfs_path_length_create(struct pohmelfs_inode *pi)
+{
+	return pohmelfs_get_path_length(pi, sizeof(struct netfs_path_entry));
+}

