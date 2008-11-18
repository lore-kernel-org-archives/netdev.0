From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [2/5] POHMELFS: core functionality.
Date: Tue, 18 Nov 2008 22:33:47 +0300
Message-ID: <12270368304071-git-send-email-zbr@ioremap.net>
References: <12270368303809-git-send-email-zbr@ioremap.net>
 <12270368303340-git-send-email-zbr@ioremap.net>
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Evgeniy Polyakov <zbr@ioremap.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <12270368303340-git-send-email-zbr@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/fs/pohmelfs/config.c b/fs/pohmelfs/config.c
new file mode 100644
index 0000000..1da032c
--- /dev/null
+++ b/fs/pohmelfs/config.c
@@ -0,0 +1,471 @@
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
+#include <linux/in.h>
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
+	g->num_entry = 0;
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
+	if (!g)
+		goto err_out_exit;
+
+	err = -ENOMEM;
+	psb->hash_string = kstrdup(g->hash_string, GFP_KERNEL);
+	if (!psb->hash_string)
+		goto err_out_exit;
+
+	psb->hash_strlen = g->hash_strlen;
+
+	psb->cipher_string = kstrdup(g->cipher_string, GFP_KERNEL);
+	if (!psb->cipher_string)
+		goto err_out_free_hash_string;
+	psb->cipher_strlen = g->cipher_strlen;
+
+	psb->hash_key = kmalloc(g->hash_keysize, GFP_KERNEL);
+	if (!psb->hash_key)
+		goto err_out_free_cipher_string;
+	memcpy(psb->hash_key, g->hash_key, g->hash_keysize);
+	psb->hash_keysize = g->hash_keysize;
+
+	psb->cipher_key = kmalloc(g->cipher_keysize, GFP_KERNEL);
+	if (!psb->cipher_key)
+		goto err_out_free_hash;
+	memcpy(psb->cipher_key, g->cipher_key, g->cipher_keysize);
+	psb->cipher_keysize = g->cipher_keysize;
+
+	mutex_unlock(&pohmelfs_config_lock);
+
+	return 0;
+
+err_out_free_hash:
+	kfree(psb->hash_key);
+err_out_free_cipher_string:
+	kfree(psb->cipher_string);
+err_out_free_hash_string:
+	kfree(psb->hash_string);
+err_out_exit:
+	mutex_unlock(&pohmelfs_config_lock);
+	return err;
+}
+
+static int pohmelfs_send_reply(int err, int msg_num, int action, struct cn_msg *msg, struct pohmelfs_ctl *ctl)
+{
+	struct pohmelfs_cn_ack *ack;
+
+	ack = kmalloc(sizeof(struct pohmelfs_cn_ack), GFP_KERNEL);
+	if (!ack)
+		return -ENOMEM;
+
+	memset(ack, 0, sizeof(struct pohmelfs_cn_ack));
+	memcpy(&ack->msg, msg, sizeof(struct cn_msg));
+
+	if (action == POHMELFS_CTLINFO_ACK)
+		memcpy(&ack->ctl, ctl, sizeof(struct pohmelfs_ctl));
+
+	ack->msg.len = sizeof(struct pohmelfs_cn_ack) - sizeof(struct cn_msg);
+	ack->msg.ack = msg->ack + 1;
+	ack->error = err;
+	ack->msg_num = msg_num;
+
+	cn_netlink_send(&ack->msg, 0, GFP_KERNEL);
+	kfree(ack);
+	return 0;
+}
+
+static int pohmelfs_cn_disp(struct cn_msg *msg)
+{
+	struct pohmelfs_config_group *g;
+	struct pohmelfs_ctl *ctl = (struct pohmelfs_ctl *)msg->data;
+	struct pohmelfs_config *c, *tmp;
+	int err = 0, i = 1;
+
+	if (msg->len != sizeof(struct pohmelfs_ctl))
+		return -EBADMSG;
+
+	mutex_lock(&pohmelfs_config_lock);
+
+	g = pohmelfs_find_config_group(ctl->idx);
+	if (!g) {
+		pohmelfs_send_reply(err, 0, POHMELFS_NOINFO_ACK, msg, NULL);
+		goto out_unlock;
+	}
+
+	list_for_each_entry_safe(c, tmp, &g->config_list, config_entry) {
+		struct pohmelfs_ctl *sc = &c->state.ctl;
+		if (pohmelfs_send_reply(err, g->num_entry - i, POHMELFS_CTLINFO_ACK, msg, sc)) {
+			err = -ENOMEM;
+			goto out_unlock;
+		}
+		i += 1;
+	}
+
+out_unlock:
+        mutex_unlock(&pohmelfs_config_lock);
+        return err;
+}
+
+static int pohmelfs_cn_ctl(struct cn_msg *msg, int action)
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
+			if (action == POHMELFS_FLAGS_ADD) {
+				err = -EEXIST;
+				goto out_unlock;
+			} else if (action == POHMELFS_FLAGS_DEL) {
+				list_del(&c->config_entry);
+				g->num_entry--;
+				kfree(c);
+				goto out_unlock;
+			} else {
+				err = -EEXIST;
+				goto out_unlock;
+			}
+		}
+	}
+	if (action == POHMELFS_FLAGS_DEL) {
+		err = -EBADMSG;
+		goto out_unlock;
+	}
+
+	c = kzalloc(sizeof(struct pohmelfs_config), GFP_KERNEL);
+	if (!c) {
+		err = -ENOMEM;
+		goto out_unlock;
+	}
+	memcpy(&c->state.ctl, ctl, sizeof(struct pohmelfs_ctl));
+	g->num_entry++;
+	list_add_tail(&c->config_entry, &g->config_list);
+
+out_unlock:
+	mutex_unlock(&pohmelfs_config_lock);
+	if (pohmelfs_send_reply(err, 0, POHMELFS_NOINFO_ACK, msg, NULL))
+		err = -ENOMEM;
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
+	if (pohmelfs_send_reply(err, 0, POHMELFS_NOINFO_ACK, msg, NULL))
+		err = -ENOMEM;
+
+	return err;
+}
+
+static void pohmelfs_cn_callback(void *data)
+{
+	struct cn_msg *msg = data;
+	int err;
+	
+	switch (msg->flags) {
+		case POHMELFS_FLAGS_ADD:
+			err = pohmelfs_cn_ctl(msg, POHMELFS_FLAGS_ADD);
+			break;
+		case POHMELFS_FLAGS_DEL:
+			err = pohmelfs_cn_ctl(msg, POHMELFS_FLAGS_DEL);
+			break;
+		case POHMELFS_FLAGS_SHOW:
+			err = pohmelfs_cn_disp(msg);
+			break;
+		case POHMELFS_FLAGS_CRYPTO:
+			err = pohmelfs_cn_crypto(msg);
+			break;
+		default:
+			err = -ENOSYS;
+			break;
+	}
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
+void pohmelfs_config_exit(void)
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
diff --git a/fs/pohmelfs/inode.c b/fs/pohmelfs/inode.c
new file mode 100644
index 0000000..19a6549
--- /dev/null
+++ b/fs/pohmelfs/inode.c
@@ -0,0 +1,1993 @@
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
+int pohmelfs_write_inode_create(struct inode *inode, struct netfs_trans *trans)
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
+		/* dprintk("%s: %3u/%u: page: %p.\n", __func__, i, page_num, page); */
+	}
+	return err;
+}
+
+static int pohmelfs_inode_has_dirty_pages(struct address_space *mapping, pgoff_t index)
+{
+	int ret;
+	struct page *page;
+
+	rcu_read_lock();
+	ret = radix_tree_gang_lookup_tag(&mapping->page_tree,
+				(void **)&page, index, 1, PAGECACHE_TAG_DIRTY);
+	rcu_read_unlock();
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
+ * Sync all not-yet-created children in given directory to the server.
+ */
+static int pohmelfs_write_inode_create_children(struct inode *inode)
+{
+	struct pohmelfs_inode *parent = POHMELFS_I(inode);
+	struct super_block *sb = inode->i_sb;
+	struct pohmelfs_name *n;
+
+	while (!list_empty(&parent->sync_create_list)) {
+		n = NULL;
+		mutex_lock(&parent->offset_lock);
+		if (!list_empty(&parent->sync_create_list)) {
+			n = list_first_entry(&parent->sync_create_list,
+				struct pohmelfs_name, sync_create_entry);
+			list_del_init(&n->sync_create_entry);
+		}
+		mutex_unlock(&parent->offset_lock);
+
+		if (!n)
+			break;
+
+		inode = ilookup(sb, n->ino);
+
+		dprintk("%s: parent: %llu, ino: %llu, inode: %p.\n",
+				__func__, parent->ino, n->ino, inode);
+
+		if (inode) {
+			sb->s_op->write_inode(inode, 0);
+			pohmelfs_meta_command(POHMELFS_I(inode),
+				NETFS_INODE_INFO, 0, NULL, NULL, 0);
+			iput(inode);
+		}
+	}
+
+	return 0;
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
+	return pohmelfs_meta_command_data(parent, parent->ino, NETFS_REMOVE, n->data, 0, NULL, NULL, 0);
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
+	pohmelfs_write_inode_create_children(inode);
+	pohmelfs_write_inode_remove_children(inode);
+
+	return 0;
+
+err_out_put:
+	t->result = err;
+	netfs_trans_put(t);
+err_out_remove:
+	pohmelfs_write_inode_create_children(inode);
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
+	err = pohmelfs_data_lock(pi, page->index << PAGE_CACHE_SHIFT,
+			PAGE_SIZE, POHMELFS_READ_LOCK);
+	if (err)
+		goto err_out_exit;
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
+	if (pos + copied > inode->i_size)
+		i_size_write(inode, pos + copied);
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
+	err = pohmelfs_data_lock(pi, first->index << PAGE_CACHE_SHIFT,
+			num * PAGE_SIZE, POHMELFS_READ_LOCK);
+	if (err)
+		goto err_out_exit;
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
+	pohmelfs_data_unlock(pi, 0, inode->i_size, POHMELFS_READ_LOCK);
+
+	pohmelfs_inode_del_inode(psb, pi);
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
+	pi->hash_root = RB_ROOT;
+	mutex_init(&pi->offset_lock);
+
+	INIT_LIST_HEAD(&pi->sync_del_list);
+	INIT_LIST_HEAD(&pi->sync_create_list);
+
+	INIT_LIST_HEAD(&pi->inode_entry);
+
+	pi->lock_type = 0;
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
+ssize_t pohmelfs_write(struct file *file, const char __user *buf,
+		size_t len, loff_t *ppos)
+{
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	struct iovec iov = { .iov_base = (void __user *)buf, .iov_len = len };
+	struct kiocb kiocb;
+	ssize_t ret;
+	loff_t pos = *ppos;
+
+	init_sync_kiocb(&kiocb, file);
+	kiocb.ki_pos = pos;
+	kiocb.ki_left = len;
+
+	dprintk("%s: len: %u, pos: %llu.\n", __func__, len, pos);
+
+	mutex_lock(&inode->i_mutex);
+	ret = pohmelfs_data_lock(pi, pos, len, POHMELFS_WRITE_LOCK);
+	if (ret)
+		goto err_out_unlock;
+
+	ret = generic_file_aio_write_nolock(&kiocb, &iov, 1, pos);
+	*ppos = kiocb.ki_pos;
+
+	mutex_unlock(&inode->i_mutex);
+	WARN_ON(ret < 0);
+
+	if (ret > 0 && ((file->f_flags & O_SYNC) || IS_SYNC(inode))) {
+		ssize_t err;
+
+		err = sync_page_range(inode, mapping, pos, ret);
+		if (err < 0)
+			ret = err;
+		WARN_ON(ret < 0);
+	}
+
+	return ret;
+
+err_out_unlock:
+	mutex_unlock(&inode->i_mutex);
+	return ret;
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
+	.write		= pohmelfs_write,
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
+	err = pohmelfs_data_lock(pi, 0, ~0, POHMELFS_WRITE_LOCK);
+	if (err)
+		goto err_out_exit;
+
+	err = security_inode_setattr(dentry, attr);
+	if (err)
+		goto err_out_exit;
+
+	err = pohmelfs_setattr_raw(inode, attr);
+	if (err)
+		goto err_out_exit;
+
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+static int pohmelfs_send_xattr_req(struct pohmelfs_inode *pi, u64 id, u64 start,
+		const char *name, const void *value, size_t attrsize, int command)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(pi->vfs_inode.i_sb);
+	int err, path_len, namelen = strlen(name) + 1; /* 0-byte */
+	struct netfs_trans *t;
+	struct netfs_cmd *cmd;
+	void *data;
+
+	dprintk("%s: id: %llu, start: %llu, name: '%s', attrsize: %u, cmd: %d.\n",
+			__func__, id, start, name, attrsize, command);
+
+	mutex_lock(&psb->path_lock);
+	path_len = pohmelfs_path_length(pi);
+	mutex_unlock(&psb->path_lock);
+	if (path_len < 0) {
+		err = path_len;
+		goto err_out_exit;
+	}
+
+	t = netfs_trans_alloc(psb, namelen + path_len + attrsize, 0, 0);
+	if (!t) {
+		err = -ENOMEM;
+		goto err_out_exit;
+	}
+
+	cmd = netfs_trans_current(t);
+	data = cmd + 1;
+
+	mutex_lock(&psb->path_lock);
+	path_len = pohmelfs_construct_path_string(pi, data, path_len);
+	mutex_unlock(&psb->path_lock);
+	if (path_len < 0) {
+		err = path_len;
+		goto err_out_put;
+	}
+	path_len++; /* 0-byte */
+	data += path_len;
+
+	/*
+	 * 'name' is a NUL-terminated string already and
+	 * 'namelen' includes 0-byte.
+	 */
+	memcpy(data, name, namelen);
+	data += namelen;
+
+	memcpy(data, value, attrsize);
+
+	cmd->cmd = command;
+	cmd->id = id;
+	cmd->start = start;
+	cmd->size = attrsize + namelen + path_len;
+	cmd->ext = path_len;
+	cmd->csize = 0;
+	cmd->cpad = 0;
+
+	netfs_convert_cmd(cmd);
+	netfs_trans_update(cmd, t, namelen + path_len + attrsize);
+
+	return netfs_trans_finish(t, psb);
+
+err_out_put:
+	t->result = err;
+	netfs_trans_put(t);
+err_out_exit:
+	return err;
+}
+
+static int pohmelfs_setxattr(struct dentry *dentry, const char *name,
+		const void *value, size_t attrsize, int flags)
+{
+	struct inode *inode = dentry->d_inode;
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+
+	return pohmelfs_send_xattr_req(pi, flags, attrsize, name,
+			value, attrsize, NETFS_XATTR_SET);
+}
+
+static ssize_t pohmelfs_getxattr(struct dentry *dentry, const char *name,
+		void *value, size_t attrsize)
+{
+	struct inode *inode = dentry->d_inode;
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	struct pohmelfs_mcache *m;
+	int err;
+	long timeout = psb->mcache_timeout;
+
+	m = pohmelfs_mcache_alloc(psb, 0, attrsize, value);
+	if (IS_ERR(m))
+		return PTR_ERR(m);
+
+	dprintk("%s: ino: %llu, name: '%s', size: %zu.\n",
+			__func__, pi->ino, name, attrsize);
+
+	err = pohmelfs_send_xattr_req(pi, m->gen, attrsize, name, value, 0, NETFS_XATTR_GET);
+	if (err)
+		goto err_out_put;
+
+	do {
+		err = wait_for_completion_timeout(&m->complete, timeout);
+		if (err) {
+			err = m->err;
+			break;
+		}
+
+		/*
+		 * This loop is a bit ugly, since it waits until reference counter
+		 * hits 1 and then put object here. Main goal is to prevent race with
+		 * network thread, when it can start processing given request, i.e.
+		 * increase its reference counter but yet not complete it, while
+		 * we will exit from ->getxattr() with timeout, and although request
+		 * will not be freed (its reference counter was increased by network
+		 * thread), data pointer provided by user may be released, so we will
+		 * overwrite already freed area in network thread.
+		 *
+		 * Now after timeout we remove request from the cache, so it can not be
+		 * found by network thread, and wait for its reference counter to hit 1,
+		 * i.e. if network thread already started to process this request, we wait
+		 * it to finish, and then free object locally. If reference counter is
+		 * already 1, i.e. request is not used by anyone else, we can free it without
+		 * problem.
+		 */
+		err = -ETIMEDOUT;
+		timeout = HZ;
+
+		pohmelfs_mcache_remove_locked(psb, m);
+	} while (atomic_read(&m->refcnt) != 1);
+
+	pohmelfs_mcache_put(psb, m);
+
+	dprintk("%s: ino: %llu, err: %d.\n", __func__, pi->ino, err);
+
+	return err;
+
+err_out_put:
+	pohmelfs_mcache_put(psb, m);
+	return err;
+}
+
+static int pohmelfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
+{
+	struct inode *inode = dentry->d_inode;
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	int err;
+
+	err = pohmelfs_data_lock(pi, 0, ~0, POHMELFS_READ_LOCK);
+	if (err)
+		return err;
+
+	generic_fillattr(inode, stat);
+	return 0;
+}
+
+const struct inode_operations pohmelfs_file_inode_operations = {
+	.setattr	= pohmelfs_setattr,
+	.getattr	= pohmelfs_getattr,
+	.setxattr	= pohmelfs_setxattr,
+	.getxattr	= pohmelfs_getxattr,
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
+	dprintk("%s.\n", __func__);
+
+	psb->trans_scan_timeout = psb->drop_scan_timeout = 0;
+	cancel_rearming_delayed_work(&psb->dwork);
+	cancel_rearming_delayed_work(&psb->drop_dwork);
+	flush_scheduled_work();
+	
+	dprintk("%s: stopped workqueues.\n", __func__);
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
+	pohmelfs_crypto_exit(psb);
+	pohmelfs_state_exit(psb);
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
+	seq_printf(seq, ",mcache_timeout=%u", jiffies_to_msecs(psb->mcache_timeout));
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
+	pohmelfs_opt_mcache_timeout,
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
+	{pohmelfs_opt_mcache_timeout, "mcache_timeout=%u"},
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
+			case pohmelfs_opt_mcache_timeout:
+				psb->mcache_timeout = msecs_to_jiffies(option);
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
+static void pohmelfs_flush_inode(struct pohmelfs_inode *pi, unsigned int count)
+{
+	struct inode *inode = &pi->vfs_inode;
+
+	dprintk("%s: %p: ino: %llu, owned: %d.\n",
+		__func__, inode, pi->ino, test_bit(NETFS_INODE_OWNED, &pi->state));
+
+	mutex_lock(&inode->i_mutex);
+	if (test_and_clear_bit(NETFS_INODE_OWNED, &pi->state)) {
+		filemap_fdatawrite(inode->i_mapping);
+		inode->i_sb->s_op->write_inode(inode, 0);
+	}
+
+	truncate_inode_pages(inode->i_mapping, 0);
+
+	pohmelfs_data_unlock(pi, 0, ~0, POHMELFS_WRITE_LOCK);
+	mutex_unlock(&inode->i_mutex);
+}
+
+static void pohmelfs_put_inode_count(struct pohmelfs_inode *pi, unsigned int count)
+{
+	dprintk("%s: ino: %llu, pi: %p, inode: %p, count: %u.\n",
+			__func__, pi->ino, pi, &pi->vfs_inode, count);
+
+	if (test_and_clear_bit(NETFS_INODE_NEED_FLUSH, &pi->state))
+		pohmelfs_flush_inode(pi, count);
+
+	while (count--)
+		iput(&pi->vfs_inode);
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
+		pohmelfs_put_inode_count(pi, count);
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
+int pohmelfs_meta_command_data(struct pohmelfs_inode *pi, u64 id, unsigned int cmd_op, char *addon,
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
+	cmd->id = id;
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
+	return pohmelfs_meta_command_data(pi, pi->ino, cmd_op, NULL, flags, complete, priv, start);
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
+	mutex_init(&psb->mcache_lock);
+	psb->mcache_root = RB_ROOT;
+	psb->mcache_timeout = msecs_to_jiffies(5000);
+	atomic_long_set(&psb->mcache_gen, 0);
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
+static void pohmelfs_init_once(void *data)
+{
+	struct pohmelfs_inode *pi = data;
+
+	inode_init_once(&pi->vfs_inode);
+}
+
+static int __init pohmelfs_init_inodecache(void)
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
+	err = pohmelfs_mcache_init();
+	if (err)
+		goto err_out_destroy;
+
+	err = netfs_trans_init();
+	if (err)
+		goto err_out_mcache_exit;
+
+	err = register_filesystem(&pohmel_fs_type);
+	if (err)
+		goto err_out_trans;
+
+	return 0;
+
+err_out_trans:
+	netfs_trans_exit();
+err_out_mcache_exit:
+	pohmelfs_mcache_exit();
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
+	pohmelfs_mcache_exit();
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

diff --git a/fs/pohmelfs/dir.c b/fs/pohmelfs/dir.c
new file mode 100644
index 0000000..b0dddbe
--- /dev/null
+++ b/fs/pohmelfs/dir.c
@@ -0,0 +1,1136 @@
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
+#include <linux/namei.h>
+#include <linux/pagemap.h>
+
+#include "netfs.h"
+
+static int pohmelfs_cmp_hash(struct pohmelfs_name *n, u32 hash)
+{
+	if (n->hash > hash)
+		return -1;
+	if (n->hash < hash)
+		return 1;
+
+	return 0;
+}
+
+static struct pohmelfs_name *pohmelfs_search_hash_unprecise(struct pohmelfs_inode *pi, u32 hash)
+{
+	struct rb_node *n = pi->hash_root.rb_node;
+	struct pohmelfs_name *tmp = NULL;
+	int cmp;
+
+	while (n) {
+		tmp = rb_entry(n, struct pohmelfs_name, hash_node);
+
+		cmp = pohmelfs_cmp_hash(tmp, hash);
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else
+			break;
+
+	}
+
+	return tmp;
+}
+
+static struct pohmelfs_name *pohmelfs_search_hash(struct pohmelfs_inode *pi, u32 hash)
+{
+	struct pohmelfs_name *tmp;
+
+	tmp = pohmelfs_search_hash_unprecise(pi, hash);
+	if (tmp && (tmp->hash == hash))
+		return tmp;
+
+	return NULL;
+}
+
+static void __pohmelfs_name_del(struct pohmelfs_inode *parent, struct pohmelfs_name *node)
+{
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
+		cmp = pohmelfs_cmp_hash(tmp, new->hash);
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
+	for (rb_node = rb_first(&parent->hash_root); rb_node;) {
+		n = rb_entry(rb_node, struct pohmelfs_name, hash_node);
+		rb_node = rb_next(rb_node);
+
+		pohmelfs_name_free(parent, n);
+	}
+}
+
+static void pohmelfs_fix_offset(struct pohmelfs_inode *parent, struct pohmelfs_name *node)
+{
+	parent->total_len -= node->len;
+}
+
+/*
+ * Free name cache entry helper.
+ */
+void pohmelfs_name_del(struct pohmelfs_inode *parent, struct pohmelfs_name *node)
+{
+	pohmelfs_fix_offset(parent, node);
+	pohmelfs_name_free(parent, node);
+}
+
+/*
+ * Insert new name cache entry into all hash cache.
+ */
+static int pohmelfs_insert_name(struct pohmelfs_inode *parent, struct pohmelfs_name *n)
+{
+	struct pohmelfs_name *name;
+
+	name = pohmelfs_insert_hash(parent, n);
+	if (name)
+		return -EEXIST;
+
+	parent->total_len += n->len;
+	list_add_tail(&n->sync_create_entry, &parent->sync_create_list);
+
+	return 0;
+}
+
+/*
+ * Allocate new name cache entry.
+ */
+static struct pohmelfs_name *pohmelfs_name_alloc(unsigned int len)
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
+	n = pohmelfs_name_alloc(str->len + 1);
+	if (!n)
+		goto err_out_exit;
+
+	n->ino = npi->ino;
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
+static int pohmelfs_dir_open(struct inode *inode, struct file *file)
+{
+	file->private_data = NULL;
+	return 0;
+}
+
+/*
+ * VFS readdir callback. Syncs directory content from server if needed,
+ * and provides direntry info to the userspace.
+ */
+static int pohmelfs_readdir(struct file *file, void *dirent, filldir_t filldir)
+{
+	struct inode *inode = file->f_path.dentry->d_inode;
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	struct pohmelfs_name *n;
+	struct rb_node *rb_node;
+	int err = 0, mode;
+	u64 len;
+
+	dprintk("%s: parent: %llu, fpos: %llu, hash: %08lx.\n",
+			__func__, pi->ino, (u64)file->f_pos,
+			(unsigned long)file->private_data);
+
+	err = pohmelfs_data_lock(pi, 0, ~0, POHMELFS_READ_LOCK);
+	if (err)
+		return err;
+
+	err = pohmelfs_sync_remote_dir(pi);
+	if (err)
+		return err;
+
+	if (file->private_data && (file->private_data == (void *)(unsigned long)file->f_pos))
+		return 0;
+
+	mutex_lock(&pi->offset_lock);
+	n = pohmelfs_search_hash_unprecise(pi, (unsigned long)file->private_data);
+
+	while (n) {
+		mode = (n->mode >> 12) & 15;
+
+		dprintk("%s: offset: %llu, parent ino: %llu, name: '%s', len: %u, ino: %llu, "
+				"mode: %o/%o, fpos: %llu, hash: %08x.\n",
+				__func__, file->f_pos, pi->ino, n->data, n->len,
+				n->ino, n->mode, mode, file->f_pos, n->hash);
+
+		file->private_data = (void *)n->hash;
+
+		len = n->len;
+		err = filldir(dirent, n->data, n->len, file->f_pos, n->ino, mode);
+
+		if (err < 0) {
+			dprintk("%s: err: %d.\n", __func__, err);
+			err = 0;
+			break;
+		}
+
+		file->f_pos += len;
+
+		rb_node = rb_next(&n->hash_node);
+
+		if (!rb_node || (rb_node == &n->hash_node)) {
+			file->private_data = (void *)(unsigned long)file->f_pos;
+			break;
+		}
+
+		n = rb_entry(rb_node, struct pohmelfs_name, hash_node);
+	}
+	mutex_unlock(&pi->offset_lock);
+
+	return err;
+}
+
+static loff_t pohmelfs_dir_lseek(struct file *file, loff_t offset, int origin)
+{
+	file->f_pos = offset;
+	file->private_data = NULL;
+	return offset;
+}
+
+const struct file_operations pohmelfs_dir_fops = {
+	.open = pohmelfs_dir_open,
+	.read = generic_read_dir,
+	.llseek = pohmelfs_dir_lseek,
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
+	err = pohmelfs_meta_command_data(parent, parent->ino, NETFS_LOOKUP,
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
+	int err, lock_type = POHMELFS_READ_LOCK;
+	struct qstr str = dentry->d_name;
+
+	if ((nd->intent.open.flags & O_ACCMODE) > 1)
+		lock_type = POHMELFS_WRITE_LOCK;
+
+	err = pohmelfs_data_lock(parent, 0, ~0, lock_type);
+	if (err)
+		goto out;
+
+	str.hash = jhash(dentry->d_name.name, dentry->d_name.len, 0);
+
+	mutex_lock(&parent->offset_lock);
+	n = pohmelfs_search_hash(parent, str.hash);
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
+		n = pohmelfs_search_hash(parent, str.hash);
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
+	struct pohmelfs_inode *npi, *parent;
+	struct qstr str = dentry->d_name;
+	int err;
+
+	parent = POHMELFS_I(dir);
+
+	err = pohmelfs_data_lock(parent, 0, ~0, POHMELFS_WRITE_LOCK);
+	if (err)
+		return err;
+
+	str.hash = jhash(dentry->d_name.name, dentry->d_name.len, 0);
+
+	npi = pohmelfs_create_entry_local(psb, parent, &str, start, mode);
+	if (IS_ERR(npi))
+		return PTR_ERR(npi);
+
+	d_instantiate(dentry, &npi->vfs_inode);
+
+	dprintk("%s: parent: %llu, inode: %llu, name: '%s', parent_nlink: %d, nlink: %d.\n",
+			__func__, parent->ino, npi->ino, dentry->d_name.name,
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
+	err = pohmelfs_data_lock(parent, 0, ~0, POHMELFS_WRITE_LOCK);
+	if (err)
+		return err;
+
+	str.hash = jhash(dentry->d_name.name, dentry->d_name.len, 0);
+
+	dprintk("%s: dir_ino: %llu, inode: %llu, name: '%s', nlink: %d.\n",
+			__func__, parent->ino, pi->ino,
+			str.name, (signed)inode->i_nlink);
+
+	mutex_lock(&parent->offset_lock);
+	n = pohmelfs_search_hash(parent, str.hash);
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
+	err = pohmelfs_data_lock(parent, 0, ~0, POHMELFS_WRITE_LOCK);
+	if (err)
+		return err;
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
+	n = pohmelfs_name_alloc(str.len + 1);
+	if (!n)
+		goto err_out_exit;
+
+	mutex_lock(&new_parent->offset_lock);
+	n->ino = old->ino;
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
+	n = pohmelfs_search_hash(old_parent, old_hash);
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

