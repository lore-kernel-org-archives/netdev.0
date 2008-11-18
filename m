From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [3/5] POHMELFS: transactions and network.
Date: Tue, 18 Nov 2008 22:33:48 +0300
Message-ID: <12270368313854-git-send-email-zbr@ioremap.net>
References: <12270368303809-git-send-email-zbr@ioremap.net>
 <12270368303340-git-send-email-zbr@ioremap.net>
 <12270368304071-git-send-email-zbr@ioremap.net>
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Evgeniy Polyakov <zbr@ioremap.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zbr.yandex.ru ([213.180.219.33]:50993 "EHLO gavana.yandex.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752391AbYKRTaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 14:30:39 -0500
In-Reply-To: <12270368304071-git-send-email-zbr@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/fs/pohmelfs/trans.c b/fs/pohmelfs/trans.c
new file mode 100644
index 0000000..d11ce6e
--- /dev/null
+++ b/fs/pohmelfs/trans.c
@@ -0,0 +1,703 @@
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
+#if 0
+	dprintk("%s: t: %p, gen: %u, size: %u, page_num: %u, active: %p.\n",
+		__func__, t, t->gen, t->iovec.iov_len, t->page_num, psb->active_state);
+#endif
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
+#if 0
+	dprintk("%s: fully sent t: %p, gen: %u, size: %u, page_num: %u, err: %d.\n",
+		__func__, t, t->gen, t->iovec.iov_len, t->page_num, err);
+#endif
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
+#if 0
+	dprintk("%s: trans: %llu, crypto_attached_size: %u, attached_size: %u, attached_pages: %d, trans_size: %u.\n",
+		__func__, cmd->start, psb->crypto_attached_size, t->attached_size, t->attached_pages, cmd->size);
+#endif
+	err = pohmelfs_trans_crypt(t, psb);
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
+	dprintk("%s: t: %p, gen: %u, size: %u, padding: %u, align_size: %u, flags: %x, "
+			"page_num: %u, base: %p, pages: %p.\n",
+			__func__, t, t->gen, size, pad, psb->crypto_align_size, flags, nr,
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

diff --git a/fs/pohmelfs/net.c b/fs/pohmelfs/net.c
new file mode 100644
index 0000000..72d4278
--- /dev/null
+++ b/fs/pohmelfs/net.c
@@ -0,0 +1,1070 @@
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
+int pohmelfs_data_recv_and_check(struct netfs_state *st, void *data, unsigned int size)
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
+	int err = 0;
+
+	if (cmd->size > PAGE_CACHE_SIZE) {
+		err = -EINVAL;
+		goto err_out_exit;
+	}
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
+	if (cmd->size) {
+		void *addr;
+
+		addr = kmap(page);
+		err = pohmelfs_data_recv(st, addr, cmd->size);
+		kunmap(page);
+
+		if (err)
+			goto err_out_page_unlock;
+	}
+
+	dprintk("%s: page: %p, start: %llu, size: %u, locked: %d.\n",
+		__func__, page, cmd->start, cmd->size, PageLocked(page));
+
+	SetPageChecked(page);
+	if ((psb->hash_string || psb->cipher_string) && psb->perform_crypto && cmd->size) {
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
+		char *name;
+
+		err = pohmelfs_data_recv_and_check(st, st->data, cmd->size);
+		if (err)
+			goto err_out_put;
+
+		info = (struct netfs_inode_info *)(st->data);
+
+		name = (char *)(info + 1);
+		str.len = cmd->size - sizeof(struct netfs_inode_info) - 1 - cmd->cpad;
+		name[str.len] = 0;
+		str.name = name;
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
+static int pohmelfs_page_cache_response(struct netfs_state *st)
+{
+	struct netfs_cmd *cmd = &st->cmd;
+	struct inode *inode;
+
+	dprintk("%s: st: %p, id: %llu, start: %llu, size: %u.\n", __func__, st, cmd->id, cmd->start, cmd->size);
+
+	inode = ilookup(st->psb->sb, cmd->id);
+	if (!inode) {
+		printk("%s: failed to find inode: id: %llu.\n", __func__, cmd->id);
+		return -ENOENT;
+	}
+
+	set_bit(NETFS_INODE_NEED_FLUSH, &POHMELFS_I(inode)->state);
+	pohmelfs_put_inode(POHMELFS_I(inode));
+
+	return 0;
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
+/*
+ * Receiving extended attribute.
+ * Does not work properly if received size is more than requested one,
+ * it should not happen with current request/reply model though.
+ */
+static int pohmelfs_getxattr_response(struct netfs_state *st)
+{
+	struct pohmelfs_sb *psb = st->psb;
+	struct netfs_cmd *cmd = &st->cmd;
+	struct pohmelfs_mcache *m;
+	short error = (signed short)cmd->ext, err;
+	unsigned int sz, total_size;
+
+	m = pohmelfs_mcache_search(psb, cmd->id);
+
+	dprintk("%s: id: %llu, gen: %llu, err: %d.\n",
+		__func__, cmd->id, (m)?m->gen:0, error);
+
+	if (!m)
+		return -ENOENT;
+
+	if (cmd->size) {
+		sz = min_t(unsigned int, cmd->size, m->size);
+		err = pohmelfs_data_recv_and_check(st, m->data, sz);
+		if (err) {
+			error = err;
+			goto out;
+		}
+
+		m->size = sz;
+		total_size = cmd->size - sz;
+
+		while (total_size) {
+			sz = min(total_size, st->size);
+
+			err = pohmelfs_data_recv_and_check(st, st->data, sz);
+			if (err) {
+				error = err;
+				break;
+			}
+
+			total_size -= sz;
+		}
+	}
+
+out:
+	m->err = error;
+	complete(&m->complete);
+	pohmelfs_mcache_put(psb, m);
+
+	return error;
+}
+
+int pohmelfs_data_lock_response(struct netfs_state *st)
+{
+	struct pohmelfs_sb *psb = st->psb;
+	struct netfs_cmd *cmd = &st->cmd;
+	struct pohmelfs_mcache *m;
+	int err = -(int)(cmd->ext & ~POHMELFS_LOCK_GRAB);
+	u64 id = cmd->id;
+
+	m = pohmelfs_mcache_search(psb, id);
+
+	dprintk("%s: id: %llu, gen: %llu, err: %d.\n",
+		__func__, cmd->id, (m)?m->gen:0, err);
+
+	if (!m) {
+		pohmelfs_data_recv(st, st->data, cmd->size);
+		return -ENOENT;
+	}
+
+	err = pohmelfs_data_recv_and_check(st, &m->info, cmd->size);
+
+	m->err = err;
+	complete(&m->complete);
+	pohmelfs_mcache_put(psb, m);
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
+#ifdef CONFIG_POHMELFS_DEBUG
+			{
+				unsigned int i;
+				unsigned char *hash = e->data;
+
+				dprintk("%s: received hash: ", __func__);
+				for (i=0; i<cmd->csize; ++i) {
+					printk("%02x ", hash[i]);
+				}
+				printk("\n");
+			}
+#endif
+			cmd->size -= cmd->csize;
+		}
+
+		/*
+		 * This should catch protocol breakage and random garbage instead of commands.
+		 */
+		if (unlikely((cmd->size > st->size) && (cmd->cmd != NETFS_XATTR_GET))) {
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
+			case NETFS_PAGE_CACHE:
+				err = pohmelfs_page_cache_response(st);
+				break;
+			case NETFS_CAPABILITIES:
+				err = pohmelfs_capabilities_response(st);
+				break;
+			case NETFS_LOCK:
+				err = pohmelfs_data_lock_response(st);
+				break;
+			case NETFS_XATTR_GET:
+				err = pohmelfs_getxattr_response(st);
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
+			dprintk("%s: disconnected from peer %u.%u.%u.%u:%d.\n", __func__,
+				NIPQUAD(sin->sin_addr.s_addr), ntohs(sin->sin_port));
+		} else if (st->socket->ops->family == AF_INET6) {
+			struct sockaddr_in6 *sin = (struct sockaddr_in6 *)&st->ctl.addr;
+			dprintk("%s: disconnected from peer "
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
+
+		dprintk("%s: empty: %d, active %p -> %p.\n",
+			__func__, list_empty(&psb->state_list), c,
+			psb->active_state);
+	} else
+		psb->active_state = NULL;
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
index 0000000..641738b
--- /dev/null
+++ b/fs/pohmelfs/netfs.h
@@ -0,0 +1,877 @@
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
+#define POHMELFS_CTLINFO_ACK		1
+#define POHMELFS_NOINFO_ACK		2
+
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
+
+	NETFS_LOOKUP,		/* Lookup single object */
+	NETFS_LINK,		/* Create a link */
+	NETFS_TRANS,		/* Transaction */
+	NETFS_OPEN,		/* Open intent */
+	NETFS_INODE_INFO,	/* Metadata cache coherency synchronization message */
+
+	NETFS_PAGE_CACHE,	/* Page cache invalidation message */
+	NETFS_READ_PAGES,	/* Read multiple contiguous pages in one go */
+	NETFS_RENAME,		/* Rename object */
+	NETFS_CAPABILITIES,	/* Capabilities of the client, for example supported crypto */
+	NETFS_LOCK,		/* Distributed lock message */
+
+	NETFS_XATTR_SET,	/* Set extended attribute */
+	NETFS_XATTR_GET,	/* Get extended attribute */
+	NETFS_CMD_MAX
+};
+
+enum {
+	POHMELFS_FLAGS_ADD = 0, /* Network state control message for ADD */
+	POHMELFS_FLAGS_DEL,     /* Network state control message for DEL */
+	POHMELFS_FLAGS_SHOW,    /* Network state control message for SHOW */
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
+	int			msg_num;
+	int			unused[3];
+	struct pohmelfs_ctl	ctl;
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
+	NETFS_INODE_OWNED,		/* Inode is owned by given host */
+	NETFS_INODE_NEED_FLUSH,		/* Inode has to be flushed to the server */
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
+enum pohmelfs_lock_type {
+	POHMELFS_LOCK_GRAB	= (1<<15),
+
+	POHMELFS_READ_LOCK	= 0,
+	POHMELFS_WRITE_LOCK,
+};
+
+struct netfs_lock
+{
+	__u64			start;
+	__u64			ino;
+	__u32			size;
+	__u32			type;
+};
+
+static inline void netfs_convert_lock(struct netfs_lock *lock)
+{
+	lock->start = __cpu_to_be64(lock->start);
+	lock->ino = __cpu_to_be64(lock->ino);
+	lock->size = __cpu_to_be32(lock->size);
+	lock->type = __cpu_to_be32(lock->type);
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
+	struct rb_node		hash_node;
+
+	struct list_head	sync_del_entry, sync_create_entry;
+
+	u64			ino;
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
+	struct rb_root		hash_root;		/* The same, but indexed by name hash and len */
+	struct mutex		offset_lock;		/* Protect both above trees */
+
+	struct list_head	sync_del_list, sync_create_list;	/* Sync list (create is not used).
+									 * It contains children scheduled to be removed
+									 */
+
+	unsigned int		drop_count;
+
+	int			lock_type;		/* How this inode is locked: read or write */
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
+	struct rb_root		mcache_root;
+	struct mutex		mcache_lock;
+	atomic_long_t		mcache_gen;
+	unsigned long		mcache_timeout;
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
+	struct list_head	flush_list;
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
+	/*
+	 * Number of config_list entries in this group entry.
+	 */
+	unsigned int		num_entry;
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
+void pohmelfs_config_exit(void);
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
+int pohmelfs_write_inode_create(struct inode *inode, struct netfs_trans *trans);
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
+int pohmelfs_meta_command_data(struct pohmelfs_inode *pi, u64 id, unsigned int cmd_op, char *addon,
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
+int pohmelfs_data_lock(struct pohmelfs_inode *pi, u64 start, u32 size, int type);
+int pohmelfs_data_unlock(struct pohmelfs_inode *pi, u64 start, u32 size, int type);
+int pohmelfs_data_lock_response(struct netfs_state *st);
+
+int __init pohmelfs_mcache_init(void);
+void pohmelfs_mcache_exit(void);
+
+//#define CONFIG_POHMELFS_DEBUG
+
+#ifdef CONFIG_POHMELFS_DEBUG
+#define dprintka(f, a...) printk(f, ##a)
+#define dprintk(f, a...) printk("%d: " f, task_pid_vnr(current), ##a)
+#else
+#define dprintka(f, a...) do {} while (0)
+#define dprintk(f, a...) do {} while (0)
+#endif
+
+static inline void netfs_trans_get(struct netfs_trans *t)
+{
+	atomic_inc(&t->refcnt);
+}
+
+static inline void netfs_trans_put(struct netfs_trans *t)
+{
+	if (atomic_dec_and_test(&t->refcnt)) {
+		dprintk("%s: t: %p, gen: %u, err: %d.\n",
+			__func__, t, t->gen, t->result);
+		if (t->complete)
+			t->complete(t->pages, t->page_num,
+				t->private, t->result);
+		netfs_trans_free(t);
+	}
+}
+
+struct pohmelfs_mcache
+{
+	struct rb_node			mcache_entry;
+	struct completion		complete;
+
+	atomic_t			refcnt;
+
+	u64				gen;
+
+	void				*data;
+	u64				start;
+	u32				size;
+	int				err;
+
+	struct netfs_inode_info		info;
+};
+
+struct pohmelfs_mcache *pohmelfs_mcache_alloc(struct pohmelfs_sb *psb, u64 start,
+		unsigned int size, void *data);
+void pohmelfs_mcache_free(struct pohmelfs_sb *psb, struct pohmelfs_mcache *m);
+struct pohmelfs_mcache *pohmelfs_mcache_search(struct pohmelfs_sb *psb, u64 gen);
+void pohmelfs_mcache_remove_locked(struct pohmelfs_sb *psb, struct pohmelfs_mcache *m);
+
+static inline void pohmelfs_mcache_get(struct pohmelfs_mcache *m)
+{
+	atomic_inc(&m->refcnt);
+}
+
+static inline void pohmelfs_mcache_put(struct pohmelfs_sb *psb,
+		struct pohmelfs_mcache *m)
+{
+	if (atomic_dec_and_test(&m->refcnt))
+		pohmelfs_mcache_free(psb, m);
+}
+
+#endif /* __KERNEL__*/
+
+#endif /* __NETFS_H */
