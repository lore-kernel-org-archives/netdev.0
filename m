From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [4/4] DST: Algorithms used in distributed storage.
Date: Mon, 17 Dec 2007 18:03:40 +0300
Message-ID: <11979038203812@2ka.mipt.ru>
References: <1197903819903@2ka.mipt.ru>
Reply-To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1197903819903@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Algorithms used in distributed storage.
Mirror and linear mapping code.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>


diff --git a/drivers/block/dst/alg_linear.c b/drivers/block/dst/alg_linear.c
new file mode 100644
index 0000000..836764d
--- /dev/null
+++ b/drivers/block/dst/alg_linear.c
@@ -0,0 +1,114 @@
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
+#include <linux/init.h>
+#include <linux/dst.h>
+
+static struct dst_alg *alg_linear;
+
+/*
+ * This callback is invoked when node is removed from storage.
+ */
+static void dst_linear_del_node(struct dst_node *n)
+{
+}
+
+/*
+ * This callback is invoked when node is added to storage.
+ */
+static int dst_linear_add_node(struct dst_node *n)
+{
+	struct dst_storage *st = n->st;
+	struct block_device *bdev;
+
+	dprintk("%s: disk_size: %llu, node_size: %llu.\n",
+			__func__, st->disk_size, n->size);
+
+	mutex_lock(&st->tree_lock);
+	n->start = st->disk_size;
+	st->disk_size += n->size;
+	set_capacity(st->disk, st->disk_size);
+	
+	bdev = bdget_disk(st->disk, 0);
+	if (bdev) {
+		mutex_lock(&bdev->bd_inode->i_mutex);
+		i_size_write(bdev->bd_inode, to_bytes(st->disk_size));
+		mutex_unlock(&bdev->bd_inode->i_mutex);
+		bdput(bdev);
+	}
+	mutex_unlock(&st->tree_lock);
+
+	return 0;
+}
+
+static int dst_linear_remap(struct dst_request *req)
+{
+	int err;
+
+	if (req->node->bdev) {
+		generic_make_request(req->bio);
+		return 0;
+	}
+
+	err = kst_check_permissions(req->state, req->bio);
+	if (err)
+		return err;
+
+	return req->state->ops->push(req);
+}
+
+/*
+ * Failover callback - it is invoked each time error happens during
+ * request processing.
+ */
+static int dst_linear_error(struct kst_state *st, int err)
+{
+	if (err)
+		set_bit(DST_NODE_FROZEN, &st->node->flags);
+	else
+		clear_bit(DST_NODE_FROZEN, &st->node->flags);
+	return 0;
+}
+
+static struct dst_alg_ops alg_linear_ops = {
+	.remap		= dst_linear_remap,
+	.add_node 	= dst_linear_add_node,
+	.del_node 	= dst_linear_del_node,
+	.error		= dst_linear_error,
+	.owner		= THIS_MODULE,
+};
+
+static int __devinit alg_linear_init(void)
+{
+	alg_linear = dst_alloc_alg("alg_linear", &alg_linear_ops);
+	if (!alg_linear)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void __devexit alg_linear_exit(void)
+{
+	dst_remove_alg(alg_linear);
+}
+
+module_init(alg_linear_init);
+module_exit(alg_linear_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
+MODULE_DESCRIPTION("Linear distributed algorithm.");
diff --git a/drivers/block/dst/alg_mirror.c b/drivers/block/dst/alg_mirror.c
new file mode 100644
index 0000000..c10d582
--- /dev/null
+++ b/drivers/block/dst/alg_mirror.c
@@ -0,0 +1,1536 @@
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
+#include <linux/init.h>
+#include <linux/poll.h>
+#include <linux/dst.h>
+#include <linux/vmstat.h>
+
+struct dst_write_entry
+{
+	int		error;
+	u32		size;
+	u64		start;
+};
+#define DST_LOG_ENTRIES_PER_PAGE	(PAGE_SIZE/sizeof(struct dst_write_entry))
+
+struct dst_mirror_node_data
+{
+	u64			age;
+	u64			num, write_idx, resync_idx;
+};
+
+struct dst_mirror_log
+{
+	unsigned int		nr_pages;
+	struct dst_write_entry	**entries;
+};
+
+struct dst_mirror_priv
+{
+	u64			resync_start, resync_size;
+	atomic_t		resync_num;
+	struct completion	resync_complete;
+	struct delayed_work	resync_work;
+	unsigned int		resync_timeout;
+
+	u64			last_start;
+	
+	spinlock_t		resync_wait_lock;
+	struct list_head	resync_wait_list;
+	int			resync_wait_num;
+	int			full_resync;
+
+	spinlock_t		backlog_lock;
+	struct list_head	backlog_list;
+
+	struct dst_node		*node;
+
+	u64			old_age, ndp_sector;
+	struct dst_mirror_node_data	data;
+
+	spinlock_t		log_lock;
+	struct dst_mirror_log	log;
+};
+
+struct dst_mirror_sync_container
+{
+	struct list_head	sync_entry;
+	u64			start, size;
+	struct dst_node		*node;
+	struct bio		*bio;
+};
+
+static struct dst_alg *alg_mirror;
+static struct bio_set *dst_mirror_bio_set;
+
+static int dst_mirror_resync(struct dst_node *n, int ndp);
+
+static int dst_mirror_mark_notsync(struct dst_node *n)
+{
+	if (!test_and_set_bit(DST_NODE_NOTSYNC, &n->flags)) {
+		struct dst_mirror_priv *priv = n->priv;
+		printk(KERN_NOTICE "%s: not synced node n: %p.\n", __func__, n);
+
+		priv->data.resync_idx = priv->data.write_idx;
+		return 1;
+	}
+
+	return 0;
+}
+
+static void dst_mirror_mark_node_sync(struct dst_node *n)
+{
+	struct dst_mirror_priv *priv = n->priv;
+
+	if (test_and_clear_bit(DST_NODE_NOTSYNC, &n->flags))
+		printk(KERN_NOTICE "%s: node: %p, %llu:%llu synchronization "
+				"has been completed.\n",
+			__func__, n, n->start, n->size);
+
+	priv->full_resync = 0;
+	complete(&priv->resync_complete);
+}
+
+static ssize_t dst_mirror_mark_dirty(struct device *dev, struct device_attribute *attr,
+			 const char *buf, size_t count)
+{
+	struct dst_node *n = container_of(dev, struct dst_node, device);
+
+	dst_mirror_mark_notsync(n);
+	return count;
+}
+
+static ssize_t dst_mirror_mark_clean(struct device *dev, struct device_attribute *attr,
+			 const char *buf, size_t count)
+{
+	struct dst_node *n = container_of(dev, struct dst_node, device);
+
+	dst_mirror_mark_node_sync(n);
+	return count;
+}
+
+static ssize_t dst_mirror_show_state(struct device *dev, struct device_attribute *attr,
+			char *buf)
+{
+	struct dst_node *n = container_of(dev, struct dst_node, device);
+
+	return sprintf(buf, "%s\n", test_bit(DST_NODE_NOTSYNC, &n->flags) ? "notsync" : "sync");
+}
+
+static ssize_t dst_mirror_show_resync_timeout(struct device *dev, struct device_attribute *attr,
+			char *buf)
+{
+	struct dst_node *n = container_of(dev, struct dst_node, device);
+	struct dst_mirror_priv *priv = n->priv;
+
+	return sprintf(buf, "%u\n", priv->resync_timeout);
+}
+
+static ssize_t dst_mirror_show_resync_size(struct device *dev, struct device_attribute *attr,
+			char *buf)
+{
+	struct dst_node *n = container_of(dev, struct dst_node, device);
+	struct dst_mirror_priv *priv = n->priv;
+
+	return sprintf(buf, "%llu\n", priv->resync_size);
+}
+
+static ssize_t dst_mirror_set_resync_size(struct device *dev, struct device_attribute *attr,
+			 const char *buf, size_t count)
+{
+	struct dst_node *n = container_of(dev, struct dst_node, device);
+	struct dst_mirror_priv *priv = n->priv;
+	unsigned long size;
+
+	size = simple_strtoul(buf, NULL, 0);
+
+	if (size > n->st->disk_size)
+		return -E2BIG;
+
+	priv->resync_size = size;
+
+	return count;
+}
+
+static ssize_t dst_mirror_show_log_num(struct device *dev, struct device_attribute *attr,
+			char *buf)
+{
+	struct dst_node *n = container_of(dev, struct dst_node, device);
+	struct dst_mirror_priv *priv = n->priv;
+
+	return sprintf(buf, "%llu\n", priv->data.num);
+}
+
+static ssize_t dst_mirror_set_resync_timeout(struct device *dev, struct device_attribute *attr,
+			 const char *buf, size_t count)
+{
+	struct dst_node *n = container_of(dev, struct dst_node, device);
+	struct dst_mirror_priv *priv = n->priv;
+	unsigned long tm;
+
+	tm = simple_strtoul(buf, NULL, 0);
+
+	if (tm < 100 || tm > 30000)
+		return -EINVAL;
+
+	priv->resync_timeout = (unsigned int)tm;
+
+	return count;
+}
+
+static struct device_attribute dst_mirror_attrs[] = {
+	__ATTR(dirty, S_IWUSR, NULL, dst_mirror_mark_dirty),
+	__ATTR(clean, S_IWUSR, NULL, dst_mirror_mark_clean),
+	__ATTR(resync_size, S_IWUSR | S_IRUGO, dst_mirror_show_resync_size,
+			dst_mirror_set_resync_size),
+	__ATTR(resync_timeout, S_IWUSR | S_IRUGO, dst_mirror_show_resync_timeout,
+			dst_mirror_set_resync_timeout),
+	__ATTR(state, S_IRUSR, dst_mirror_show_state, NULL),
+	__ATTR(log_num, S_IRUSR, dst_mirror_show_log_num, NULL),
+};
+
+static void dst_mirror_handle_priv(struct dst_node *n)
+{
+	if (n->priv) {
+		int err, i;
+
+		for (i=0; i<ARRAY_SIZE(dst_mirror_attrs); ++i)
+			err = device_create_file(&n->device,
+					&dst_mirror_attrs[i]);
+	}
+}
+
+static void dst_mirror_destructor(struct bio *bio)
+{
+	dprintk("%s: bio: %p.\n", __func__, bio);
+	bio_free(bio, dst_mirror_bio_set);
+}
+
+struct dst_mirror_ndp
+{
+	int			err;
+	struct page		*page;
+	struct completion	complete;
+};
+
+static void dst_mirror_ndb_complete(struct dst_mirror_ndp *cmp, int err)
+{
+	cmp->err = err;
+	dprintk("%s: completing request: cmp: %p, err: %d.\n",
+			__func__, cmp, err);
+	complete(&cmp->complete);
+}
+
+static void dst_mirror_ndp_bio_endio(struct dst_request *req, int err)
+{
+	struct dst_mirror_ndp *cmp = req->bio->bi_private;
+
+	dst_mirror_ndb_complete(cmp, err);
+}
+
+static int dst_mirror_ndp_end_io(struct bio *bio, unsigned int size, int err)
+{
+	struct dst_mirror_ndp *cmp = bio->bi_private;
+
+	if (bio->bi_size)
+		return 0;
+
+	dst_mirror_ndb_complete(cmp, err);
+	return 0;
+}
+
+/*
+ * This function reads or writes node's private data from underlying media.
+ */
+static int dst_mirror_process_node_data(struct dst_node *n,
+		struct dst_mirror_node_data *ndata, int op)
+{
+	struct bio *bio;
+	int err = -ENOMEM;
+	struct dst_mirror_ndp *cmp;
+	struct dst_mirror_priv *priv = n->priv;
+	void *addr;
+
+	cmp = kzalloc(sizeof(struct dst_mirror_ndp), GFP_KERNEL);
+	if (!cmp)
+		goto err_out_exit;
+
+	cmp->page = alloc_page(GFP_NOIO);
+	if (!cmp->page)
+		goto err_out_free_cmp;
+
+	addr = kmap(cmp->page);
+
+	init_completion(&cmp->complete);
+
+	if (op == WRITE)
+		memcpy(addr, ndata, sizeof(struct dst_mirror_node_data));
+
+	bio = bio_alloc_bioset(GFP_NOIO, 1, dst_mirror_bio_set);
+	if (!bio)
+		goto err_out_free_page;
+
+	bio->bi_rw = op;
+	bio->bi_private = cmp;
+	bio->bi_sector = priv->ndp_sector;
+	bio->bi_bdev = n->bdev;
+	bio->bi_destructor = dst_mirror_destructor;
+	bio->bi_end_io = dst_mirror_ndp_end_io;
+
+	err = bio_add_pc_page(n->st->queue, bio, cmp->page, 512, 0);
+	if (err <= 0)
+		goto err_out_free_bio;
+
+	if (n->bdev) {
+		generic_make_request(bio);
+	} else {
+		struct dst_request req;
+
+		memset(&req, 0, sizeof(struct dst_request));
+		dst_fill_request(&req, bio, bio->bi_sector, n,
+				&dst_mirror_ndp_bio_endio);
+
+		err = req.state->ops->push(&req);
+		if (err)
+			req.bio_endio(&req, err);
+	}
+
+	dprintk("%s: waiting for completion: bio: %p, cmp: %p.\n",
+			__func__, bio, cmp);
+
+	wait_for_completion(&cmp->complete);
+
+	err = cmp->err;
+	if (!err && (op != WRITE))
+		memcpy(ndata, addr, sizeof(struct dst_mirror_node_data));
+
+	kunmap(cmp->page);
+
+	dprintk("%s: freeing bio: %p, err: %d.\n", __func__, bio, err);
+
+err_out_free_bio:
+	bio_put(bio);
+err_out_free_page:
+	kunmap(cmp->page);
+	__free_page(cmp->page);
+err_out_free_cmp:
+	kfree(cmp);
+err_out_exit:
+	return err;
+}
+
+/*
+ * This function reads node's private data from underlying media.
+ */
+static int dst_mirror_read_node_data(struct dst_node *n,
+		struct dst_mirror_node_data *ndata)
+{
+	return dst_mirror_process_node_data(n, ndata, READ);
+}
+
+/*
+ * This function writes node's private data from underlying media.
+ */
+static int dst_mirror_write_node_data(struct dst_node *n,
+		struct dst_mirror_node_data *ndata)
+{
+	dprintk("%s: writing new age: %llx, node: %p %llu-%llu.\n",
+			__func__, ndata->age, n, n->start, n->size);
+	return dst_mirror_process_node_data(n, ndata, WRITE);
+}
+
+static int dst_mirror_process_log_on_disk(struct dst_node *n, int op)
+{
+	struct dst_mirror_priv *priv = n->priv;
+	struct dst_mirror_log *log = &priv->log;
+	int err = -ENOMEM;
+	unsigned int i;
+	struct bio *bio;
+	struct dst_mirror_ndp *cmp;
+
+	cmp = kzalloc(sizeof(struct dst_mirror_ndp), GFP_KERNEL);
+	if (!cmp)
+		goto err_out_exit;
+
+	bio = bio_alloc_bioset(GFP_NOIO, 1, dst_mirror_bio_set);
+	if (!bio)
+		goto err_out_free_cmp;
+
+	bio->bi_rw = op;
+	bio->bi_private = cmp;
+	bio->bi_bdev = n->bdev;
+	bio->bi_destructor = dst_mirror_destructor;
+	bio->bi_end_io = dst_mirror_ndp_end_io;
+
+	for (i=0; i<log->nr_pages; ++i) {
+		bio->bi_sector = n->size + to_sector(i*PAGE_SIZE);
+
+		err = bio_add_pc_page(n->st->queue, bio,
+				virt_to_page(log->entries[i]), PAGE_SIZE,
+				offset_in_page(log->entries[i]));
+		if (err <= 0)
+			goto err_out_free_bio;
+
+		init_completion(&cmp->complete);
+
+		if (n->bdev) {
+			generic_make_request(bio);
+		} else {
+			struct dst_request req;
+
+			memset(&req, 0, sizeof(struct dst_request));
+			dst_fill_request(&req, bio, bio->bi_sector, n,
+					&dst_mirror_ndp_bio_endio);
+
+			err = req.state->ops->push(&req);
+			if (err)
+				req.bio_endio(&req, err);
+		}
+
+		dprintk("%s: waiting for completion: bio: %p, cmp: %p.\n",
+			__func__, bio, cmp);
+
+		wait_for_completion(&cmp->complete);
+		if (cmp->err) {
+			err = cmp->err;
+			goto err_out_free_bio;
+		}
+	}
+
+	err = dst_mirror_write_node_data(n, &priv->data);
+	if (err)
+		goto err_out_free_cmp;
+
+err_out_free_bio:
+	bio_put(bio);
+err_out_free_cmp:
+	kfree(cmp);
+err_out_exit:
+	if (err)
+		dst_mirror_mark_notsync(n);
+	return err;
+}
+
+static int dst_mirror_ndp_setup(struct dst_node *n, int first_node, int clean_on_sync)
+{
+	struct dst_mirror_priv *p = n->priv;
+	int sync = 1, err;
+	struct dst_mirror_priv *fp = p;
+	struct dst_node *first;
+
+	p->full_resync = 0;
+
+	if (first_node) {
+		u64 new_age = *(u64 *)&n->st;
+
+		p->old_age = p->data.age;
+		printk(KERN_NOTICE "%s: first age: %llx -> %llx. "
+			"Old will be set to new for the first node.\n",
+				__func__, p->old_age, new_age);
+		p->data.age = new_age;
+
+		err = dst_mirror_write_node_data(n, &p->data);
+		if (err)
+			return err;
+	} else {
+		mutex_lock(&n->st->tree_lock);
+		first = dst_storage_tree_search(n->st, n->start);
+		if (!first) {
+			mutex_unlock(&n->st->tree_lock);
+			dprintk("%s: there are no nodes in the storage.\n", __func__);
+			return -ENODEV;
+		}
+
+		fp = first->priv;
+
+		if (fp->old_age != p->data.age) {
+			p->full_resync = 1;
+			sync = 0;
+		}
+
+		p->old_age = fp->old_age;
+
+		n->shared_head = first;
+		atomic_inc(&first->shared_num);
+		list_add_tail(&n->shared, &first->shared);
+		mutex_unlock(&n->st->tree_lock);
+
+		if (sync) {
+			unsigned long flags;
+			unsigned int pidx, pnum;
+
+			err = dst_mirror_process_log_on_disk(n, READ);
+			if (err)
+				goto err_out_put;
+
+			spin_lock_irqsave(&fp->log_lock, flags);
+			if (fp->data.write_idx != p->data.write_idx)
+				sync = 0;
+			spin_unlock_irqrestore(&fp->log_lock, flags);
+			
+			pnum = p->data.resync_idx / DST_LOG_ENTRIES_PER_PAGE;
+			pidx = p->data.resync_idx % DST_LOG_ENTRIES_PER_PAGE;
+
+			if (p->log.entries[pnum][pidx].error)
+				sync = 0;
+		}
+	}
+
+	if (!sync) {
+		printk(KERN_NOTICE "%s: node %llu:%llu is not synced with the first one: "
+					"first_age: %llx, new_age: %llx, indexes %s.\n",
+					__func__, n->start, n->start+n->size,
+					p->data.age, p->old_age,
+					p->full_resync ? "does not match" : "match");
+		dst_mirror_mark_notsync(n);
+	} else {
+	       	if (clean_on_sync)
+			dst_mirror_mark_node_sync(n);
+		complete(&p->resync_complete);
+
+		printk(KERN_NOTICE "%s: node %llu:%llu is in sync with the first node.\n",
+				__func__, n->start, n->start+n->size);
+	}
+
+	dprintk("%s: age: old: %llx, new: %llx.\n", __func__, p->old_age, fp->data.age);
+
+	return 0;
+
+err_out_put:
+	first = n->shared_head;
+	atomic_dec(&first->shared_num);
+	mutex_lock(&n->st->tree_lock);
+	list_del(&n->shared);
+	n->shared_head = NULL;
+	mutex_unlock(&n->st->tree_lock);
+	dst_node_put(first);
+
+	return err;
+}
+
+static int dst_mirror_end_io(struct bio *bio, unsigned int size, int err)
+{
+	struct dst_request *req = bio->bi_private;
+
+	if (bio->bi_size)
+		return 0;
+
+	dprintk("%s: req: %p, bio: %p, req->bio: %p, err: %d.\n",
+			__func__, req, bio, req->bio, err);
+	req->bio_endio(req, err);
+	bio_put(bio);
+	return 0;
+}
+
+static int dst_mirror_process_request_nosync(struct dst_request *req,
+		struct dst_node *n)
+{
+	int err = 0;
+
+	/*
+	 * Block layer requires to clone a bio.
+	 */
+	if (n->bdev) {
+		struct bio *clone = bio_alloc_bioset(GFP_NOIO,
+			req->bio->bi_max_vecs, dst_mirror_bio_set);
+
+		__bio_clone(clone, req->bio);
+
+		clone->bi_bdev = n->bdev;
+		clone->bi_destructor = dst_mirror_destructor;
+		clone->bi_private = req;
+		clone->bi_end_io = &dst_mirror_end_io;
+
+		dprintk("%s: clone: %p, bio: %p, req: %p.\n",
+				__func__, clone, req->bio, req);
+
+		generic_make_request(clone);
+		err = 1;
+	} else {
+		struct dst_request nr;
+		/*
+		 * Network state processing engine will clone request
+		 * by itself if needed. We can not use the same structure
+		 * here, since number of its fields will be modified.
+		 */
+		memcpy(&nr, req, sizeof(struct dst_request));
+
+		nr.node = n;
+		nr.state = n->state;
+		nr.priv = req;
+
+		err = kst_check_permissions(n->state, req->bio);
+		if (!err)
+			err = n->state->ops->push(&nr);
+	}
+
+	dprintk("%s: req: %p, n: %p, bdev: %p, err: %d.\n",
+			__func__, req, n, n->bdev, err);
+
+	return err;
+}
+
+static int dst_mirror_sync_requeue(struct dst_node *n, int exiting)
+{
+	struct dst_mirror_priv *p = n->priv;
+	struct dst_mirror_sync_container *sc;
+	struct dst_request req;
+	unsigned long flags;
+	int err, num = 0;
+
+	if (!list_empty(&p->backlog_list))
+		dprintk("%s: n: %p, backlog_empty: %d, resync_num: %d.\n",
+			__func__, n, list_empty(&p->backlog_list),
+			atomic_read(&p->resync_num));
+
+	while (!list_empty(&p->backlog_list)) {
+		sc = NULL;
+		spin_lock_irqsave(&p->backlog_lock, flags);
+		if (!list_empty(&p->backlog_list)) {
+			sc = list_entry(p->backlog_list.next,
+					struct dst_mirror_sync_container,
+					sync_entry);
+			if (bio_rw(sc->bio) == WRITE)
+				list_del(&sc->sync_entry);
+			else
+				sc = NULL;
+		}
+		spin_unlock_irqrestore(&p->backlog_lock, flags);
+
+		if (!sc)
+			break;
+
+		sc->bio->bi_private = n;
+		if (sc->bio->bi_size == 0 || exiting) {
+			err = -EIO;
+			goto out;
+		}
+
+		memset(&req, 0, sizeof(struct dst_request));
+		dst_fill_request(&req, sc->bio, sc->start - n->start,
+				n, &kst_bio_endio);
+
+		err = dst_mirror_process_request_nosync(&req, n);
+out:
+		if (err < 0)
+			bio_endio(sc->bio, sc->bio->bi_size, err);
+		kfree(sc);
+		num++;
+	}
+
+	return num;
+}
+
+
+static void dst_mirror_resync_work(struct work_struct *work)
+{
+	struct dst_mirror_priv *priv = container_of(work,
+			struct dst_mirror_priv, resync_work.work);
+	struct dst_node *n = priv->node;
+
+	dst_mirror_resync(n, 0);
+	dst_mirror_sync_requeue(n, 0);
+	schedule_delayed_work(&priv->resync_work, priv->resync_timeout);
+}
+
+/*
+ * Mirroring log is used to store write request information.
+ * It is allocated on disk and in memory (sync happens each time
+ * resync work queue fires), and eats about 1% of free RAM or disk
+ * (what is less). Each write updates log, so when node goes offline,
+ * its log will be updated with error values, so that this entries
+ * could be resynced when node will be back online. When number of
+ * failed writes becomes equal to number of entries in the write log,
+ * recovery becomes impossible (since old log entries were overwritten)
+ * and full resync is scheduled. 
+ *
+ * This does not work well with the situation, when there are multiple
+ * writes to the same locations - they are considered as different
+ * writes and thus will be resynced multiple times.
+ * The right solution is to check log for each write, better if log
+ * would be not array, but tree.
+ */
+static int dst_mirror_log_init(struct dst_node *n)
+{
+	struct dst_mirror_priv *priv = n->priv;
+	struct dst_mirror_log *log = &priv->log;
+	struct dst_mirror_node_data *pd = &priv->data;
+	u64 allowed_ram = DIV_ROUND_UP(global_page_state(NR_FREE_PAGES), 100);
+	u64 allowed_disk = DIV_ROUND_UP(to_bytes(n->size), 100);
+	u64 num;
+	unsigned int nr_pages, i;
+	int err;
+
+	err = dst_mirror_read_node_data(n, pd);
+	if (err)
+		return err;
+
+	allowed_ram <<= PAGE_SHIFT;
+
+	num = min(allowed_disk, allowed_ram)/sizeof(struct dst_write_entry);
+	nr_pages = min(allowed_disk, allowed_ram) >> PAGE_SHIFT;
+
+	log->entries = kzalloc(nr_pages * sizeof(void *), GFP_KERNEL);
+	if (!log->entries)
+		return -ENOMEM;
+
+	for (i=0; i<nr_pages; ++i) {
+		log->entries[i] = kzalloc(PAGE_SIZE, GFP_KERNEL);
+		if (!log->entries[i])
+			goto err_out_free;
+	}
+
+	log->nr_pages = nr_pages;
+
+	pd->num = num;
+	pd->write_idx = pd->resync_idx = 0;
+
+	printk(KERN_INFO "%s: mirror write log contains %llu entries (%u pages).\n",
+			__func__, num, nr_pages);
+
+	return 0;
+
+err_out_free:
+	while (i-- != 0)
+		kfree(log->entries[i]);
+	kfree(log->entries);
+
+	return -ENOMEM;
+}
+
+static void dst_mirror_log_exit(struct dst_node *n)
+{
+	struct dst_mirror_priv *priv = n->priv;
+	unsigned int i;
+
+	for (i=0; i<priv->log.nr_pages; ++i)
+		kfree(priv->log.entries[i]);
+	kfree(priv->log.entries);
+}
+
+/*
+ * This callback is invoked when node is added to storage.
+ */
+static int dst_mirror_add_node(struct dst_node *n)
+{
+	struct dst_storage *st = n->st;
+	struct dst_mirror_priv *priv;
+	int err = -ENOMEM, first_node = 0;
+	u64 disk_size;
+
+	n->size--; /* A sector size actually. */
+
+	priv = kzalloc(sizeof(struct dst_mirror_priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	priv->ndp_sector = n->size;
+	priv->node = n;
+	priv->resync_start = 0;
+	priv->resync_size = to_sector(1024*1024*100ULL);
+	init_completion(&priv->resync_complete);
+	atomic_set(&priv->resync_num, 0);
+	INIT_DELAYED_WORK(&priv->resync_work, dst_mirror_resync_work);
+	priv->resync_timeout = 1000;
+
+	spin_lock_init(&priv->resync_wait_lock);
+	INIT_LIST_HEAD(&priv->resync_wait_list);
+	priv->resync_wait_num = 0;
+
+	spin_lock_init(&priv->backlog_lock);
+	INIT_LIST_HEAD(&priv->backlog_list);
+
+	n->priv_callback = &dst_mirror_handle_priv;
+	n->priv = priv;
+
+	spin_lock_init(&priv->log_lock);
+	
+	err = dst_mirror_log_init(n);
+	if (err)
+		goto err_out_free;
+
+	n->size -= to_sector(priv->log.nr_pages << PAGE_SHIFT);
+
+	mutex_lock(&st->tree_lock);
+	disk_size = st->disk_size;
+	if (st->disk_size) {
+		st->disk_size = min(n->size, st->disk_size);
+	} else {
+		st->disk_size = n->size;
+		first_node = 1;
+	}
+	mutex_unlock(&st->tree_lock);
+
+	err = dst_mirror_ndp_setup(n, first_node, 1);
+	if (err)
+		goto err_out_free_log;
+
+	schedule_delayed_work(&priv->resync_work, priv->resync_timeout);
+
+	dprintk("%s: n: %p, %llu:%llu, disk_size: %llu.\n",
+		__func__, n, n->start, n->size, st->disk_size);
+
+	return 0;
+
+err_out_free_log:
+	mutex_lock(&st->tree_lock);
+	st->disk_size = disk_size;
+	mutex_unlock(&st->tree_lock);
+	dst_mirror_log_exit(n);
+err_out_free:
+	kfree(priv);
+	n->priv = NULL;
+	return err;
+}
+
+static void dst_mirror_sync_destructor(struct bio *bio)
+{
+	struct bio_vec *bv;
+	int i;
+
+	bio_for_each_segment(bv, bio, i)
+		__free_page(bv->bv_page);
+	bio_free(bio, dst_mirror_bio_set);
+}
+
+static void dst_mirror_check_resync_complete(struct dst_node *n, int num_completed)
+{
+	struct dst_mirror_priv *priv = n->priv;
+
+	if (atomic_sub_return(num_completed, &priv->resync_num) == 0) {
+		dprintk("%s: completing resync request, start: %llu, size: %llu.\n",
+				__func__, priv->resync_start, priv->resync_size);
+		complete(&priv->resync_complete);
+		if (!priv->full_resync)
+			schedule_delayed_work(&priv->resync_work, 0);
+	}
+}
+
+static int dst_mirror_sync_check(struct dst_node *n)
+{
+	struct dst_mirror_priv *priv = n->priv;
+	struct dst_mirror_node_data *pd = &priv->data;
+	unsigned int pidx, pnum, i, j;
+	struct dst_write_entry *e;
+
+	pnum = pd->resync_idx / DST_LOG_ENTRIES_PER_PAGE;
+	pidx = pd->resync_idx % DST_LOG_ENTRIES_PER_PAGE;
+
+	for (i=pnum; i<priv->log.nr_pages; ++i) {
+		for (j=pidx; j<DST_LOG_ENTRIES_PER_PAGE; ++j) {
+			e = &priv->log.entries[i][j];
+
+			if (e->error) {
+				pd->resync_idx = i*DST_LOG_ENTRIES_PER_PAGE + j;
+				return 1;
+			}
+		}
+
+		pidx = 0;
+	}
+
+	dst_mirror_mark_node_sync(n);
+	return 0;
+}
+
+static int dst_mirror_sync_endio(struct bio *bio, unsigned int size, int err)
+{
+	dprintk("%s: bio: %p, err: %d, size: %u, op: %s.\n",
+			__func__, bio, err, bio->bi_size,
+			(bio_rw(bio) != WRITE)?"read":"write");
+
+	if (bio->bi_size)
+		return 1;
+
+	if (bio_rw(bio) != WRITE) {
+		struct dst_mirror_sync_container *sc = bio->bi_private;
+
+		if (err)
+			dst_mirror_mark_notsync(sc->node);
+
+		if (!err) {
+			bio->bi_size = sc->size;
+			bio->bi_sector = sc->start;
+		}
+		bio->bi_rw = WRITE;
+	} else {
+		struct dst_node *n = bio->bi_private;
+		struct dst_mirror_priv *priv = n->priv;
+		
+		if (err)
+			dst_mirror_mark_notsync(n);
+		else if (!priv->full_resync) {
+			struct dst_mirror_node_data *pd = &priv->data;
+			unsigned long flags;
+
+			spin_lock_irqsave(&priv->log_lock, flags);
+			pd->resync_idx = (pd->resync_idx + 1) % pd->num;
+			dst_mirror_sync_check(n);
+			spin_unlock_irqrestore(&priv->log_lock, flags);
+		}
+		bio_put(bio);
+		dst_mirror_check_resync_complete(n, 1);
+	}
+
+	return 0;
+}
+
+static int dst_mirror_sync_block(struct dst_node *n,
+		u64 start, u32 size)
+{
+	struct bio *bio;
+	unsigned int nr_pages = DIV_ROUND_UP(size, PAGE_SIZE), i, nr;
+	struct page *page;
+	int err = -ENOMEM;
+	unsigned long flags;
+	struct dst_mirror_sync_container *sc;
+	struct dst_mirror_priv *priv = n->priv;
+
+	dprintk("%s: [all in sectors] start: %llu, size: %u, nr_pages: %u, disk_size: %llu.\n",
+			__func__, (u64)to_sector(start), (unsigned int)to_sector(size),
+			nr_pages, n->st->disk_size);
+
+	atomic_set(&priv->resync_num, nr_pages);
+
+	while (nr_pages) {
+		nr = min_t(unsigned int, nr_pages, BIO_MAX_PAGES);
+
+		sc = kmalloc(sizeof(struct dst_mirror_sync_container), GFP_KERNEL);
+		if (!sc)
+			return -ENOMEM;
+
+		bio = bio_alloc_bioset(GFP_NOIO, nr, dst_mirror_bio_set);
+		if (!bio)
+			goto err_out_free_sc;
+
+		bio->bi_rw = READ;
+		bio->bi_private = sc;
+		bio->bi_sector = to_sector(start);
+		bio->bi_bdev = NULL;
+		bio->bi_destructor = dst_mirror_sync_destructor;
+		bio->bi_end_io = dst_mirror_sync_endio;
+
+		for (i = 0; i < nr; ++i) {
+			page = alloc_page(GFP_NOIO);
+			if (!page)
+				break;
+
+			err = bio_add_pc_page(n->st->queue, bio, page,
+					min_t(u32, PAGE_SIZE, size), 0);
+			if (err <= 0)
+				break;
+			size -= err;
+			err = 0;
+		}
+
+		if (!bio->bi_vcnt) {
+			err = -ENOMEM;
+			goto err_out_put_bio;
+		}
+
+		sc->node = n;
+		sc->bio = bio;
+		sc->start = bio->bi_sector;
+		sc->size = bio->bi_size;
+
+		dst_mirror_check_resync_complete(n, i-1);
+
+		spin_lock_irqsave(&priv->backlog_lock, flags);
+		list_add_tail(&sc->sync_entry, &priv->backlog_list);
+		spin_unlock_irqrestore(&priv->backlog_lock, flags);
+
+		nr_pages -= bio->bi_vcnt;
+		dprintk("%s: start: %llu, size: %u/%u, bio: %p, rest_pages: %u, rest_bytes: %u.\n",
+			__func__, start, bio->bi_size, nr, bio, nr_pages, size);
+
+		start += bio->bi_size;
+
+		err = n->st->queue->make_request_fn(n->st->queue, bio);
+		if (err)
+			goto err_out_del;
+	}
+
+	return 0;
+
+err_out_del:
+	spin_lock_irqsave(&priv->backlog_lock, flags);
+	list_del(&sc->sync_entry);
+	spin_unlock_irqrestore(&priv->backlog_lock, flags);
+err_out_put_bio:
+	bio_put(bio);
+err_out_free_sc:
+	kfree(sc);
+	return err;
+}
+
+static void dst_mirror_read_endio(struct dst_request *req, int err)
+{
+	if (err)
+		dst_mirror_mark_notsync(req->node);
+
+	if (err && req->state)
+		kst_wake(req->state);
+
+	if (!err || req->callback)
+		kst_bio_endio(req, err);
+}
+
+static void dst_mirror_update_write_log(struct dst_request *req, int err)
+{
+	struct dst_mirror_priv *priv = req->node->priv;
+	struct dst_mirror_log *log = &priv->log;
+	struct dst_mirror_node_data *pd = &priv->data;
+	unsigned long flags;
+	struct dst_write_entry *e;
+	unsigned int pnum, idx;
+
+	spin_lock_irqsave(&priv->log_lock, flags);
+
+	pnum = pd->write_idx / DST_LOG_ENTRIES_PER_PAGE;
+	idx = pd->write_idx % DST_LOG_ENTRIES_PER_PAGE;
+
+	e = &log->entries[pnum][idx];
+	e->error = err;
+	e->start = req->start - to_sector(req->orig_size);
+	e->size = req->orig_size;
+
+	if (++pd->write_idx == pd->num)
+		pd->write_idx = 0;
+
+	if (test_bit(DST_NODE_NOTSYNC, &req->node->flags) &&
+			pd->write_idx == pd->resync_idx)
+		priv->full_resync = 1;
+
+	spin_unlock_irqrestore(&priv->log_lock, flags);
+}
+
+static void dst_mirror_write_endio(struct dst_request *req, int err)
+{
+	if (err) {
+		dst_mirror_mark_notsync(req->node);
+		if (req->state)
+			kst_wake(req->state);
+	}
+	dst_mirror_update_write_log(req, err);
+
+	req = req->priv;
+
+	dprintk("%s: req: %p, priv: %p err: %d, bio: %p, "
+			"cnt: %d, orig_size: %llu.\n",
+		__func__, req, req->priv, err, req->bio,
+		atomic_read(&req->refcnt), req->orig_size);
+
+	if (atomic_dec_and_test(&req->refcnt)) {
+		bio_endio(req->bio, req->orig_size, 0);
+		dst_free_request(req);
+	}
+}
+
+static int dst_mirror_process_request(struct dst_request *req,
+		struct dst_node *n)
+{
+	int err;
+
+	dst_mirror_sync_requeue(n, 0);
+	err = dst_mirror_process_request_nosync(req, n);
+	if (err > 0)
+		err = 0;
+	if (err)
+		req->bio_endio(req, err);
+
+	return err;
+}
+
+static int dst_mirror_write(struct dst_request *oreq)
+{
+	struct dst_node *n, *node = oreq->node;
+	struct dst_request *req = oreq;
+	int num, err = 0, err_num = 0, orig_num;
+	struct dst_mirror_priv *priv = node->priv;
+	unsigned long flags;
+
+	/*
+	 * This check is for requests which fell into resync window.
+	 * Such requests are written when resync window moves forward.
+	 */
+	if (oreq->bio_endio != &dst_mirror_write_endio) {
+		req = dst_clone_request(oreq, oreq->node->w->req_pool);
+		if (!req) {
+			err = -ENOMEM;
+			goto err_out_exit;
+		}
+
+		req->priv = req;
+		req->bio_endio = &dst_mirror_write_endio;
+	}
+
+	if (test_bit(DST_NODE_NOTSYNC, &node->flags) &&
+			oreq->start >= priv->resync_start &&
+			to_sector(oreq->orig_size) <= priv->resync_size &&
+			priv->full_resync) {
+		dprintk("%s: queueing request: start: %llu, size: %llu, resync window start: %llu, size: %llu.\n",
+				__func__, oreq->start, (u64)to_sector(oreq->orig_size),
+				priv->resync_start, priv->resync_size);
+		spin_lock_irqsave(&priv->resync_wait_lock, flags);
+		list_add_tail(&req->request_list_entry, &priv->resync_wait_list);
+		priv->resync_wait_num++;
+		spin_unlock_irqrestore(&priv->resync_wait_lock, flags);
+		return 0;
+	}
+
+	/*
+	 * This logic is pretty simple - req->bio_endio will not
+	 * call bio_endio() until all mirror devices completed
+	 * processing of the request (no matter with or without error).
+	 * Mirror's req->bio_endio callback will take care of that.
+	 */
+	orig_num = num = atomic_read(&req->node->shared_num) + 1;
+	atomic_set(&req->refcnt, num);
+
+	dprintk("\n%s: req: %p, mirror to %d nodes.\n",
+			__func__, req, num);
+
+	err = dst_mirror_process_request(req, node);
+	if (err)
+		err_num++;
+
+	if (--num) {
+		list_for_each_entry(n, &node->shared, shared) {
+			dprintk("\n%s: req: %p, start: %llu, size: %llu, "
+					"num: %d, n: %p, state: %p.\n",
+				__func__, req, req->start,
+				req->size, num, n, n->state);
+
+			err = dst_mirror_process_request(req, n);
+			if (err)
+				err_num++;
+
+			if (--num <= 0)
+				break;
+		}
+	}
+
+	if (err_num == orig_num)
+		dprintk("%s: req: %p, num: %d, err: %d.\n",
+				__func__, req, num, err);
+
+	err = 0;
+
+err_out_exit:
+	return err;
+}
+
+static int dst_mirror_read(struct dst_request *req)
+{
+	struct dst_node *node = req->node, *n, *min_dist_node;
+	struct dst_mirror_priv *priv = node->priv;
+	u64 dist, d;
+	int err;
+
+	req->bio_endio = &dst_mirror_read_endio;
+
+	do {
+		err = -ENODEV;
+		min_dist_node = NULL;
+		dist = -1ULL;
+
+		/*
+		 * Reading is never performed from the node under resync.
+		 */
+
+		if (!test_bit(DST_NODE_NOTSYNC, &node->flags)) {
+			priv = node->priv;
+			if (req->start > priv->last_start)
+				dist = req->start - priv->last_start;
+			else
+				dist = priv->last_start - req->start;
+			min_dist_node = req->node;
+		}
+
+		list_for_each_entry(n, &node->shared, shared) {
+			if (test_bit(DST_NODE_NOTSYNC, &n->flags))
+				continue;
+
+			priv = n->priv;
+
+			if (req->start > priv->last_start)
+				d = req->start - priv->last_start;
+			else
+				d = priv->last_start - req->start;
+
+			if (d < dist)
+				min_dist_node = n;
+		}
+
+		if (!min_dist_node)
+			break;
+
+		priv = min_dist_node->priv;
+		priv->last_start = req->start;
+
+		req->node = min_dist_node;
+		req->state = req->node->state;
+
+		if (req->node->bdev) {
+			req->bio->bi_bdev = req->node->bdev;
+			generic_make_request(req->bio);
+			err = 0;
+			break;
+		}
+
+		err = req->state->ops->push(req);
+		if (err) {
+			dprintk("%s: req: %p, bio: %p, node: %p, err: %d.\n",
+				__func__, req, req->bio, min_dist_node, err);
+			dst_mirror_mark_notsync(req->node);
+		}
+	} while (err && min_dist_node);
+
+	if (err || !min_dist_node) {
+		dprintk("%s: req: %p, bio: %p, node: %p, err: %d.\n",
+			__func__, req, req->bio, min_dist_node, err);
+		if (!err)
+			err = -ENODEV;
+	}
+	dprintk("%s: req: %p, err: %d.\n", __func__, req, err);
+	return err;
+}
+
+/*
+ * This callback is invoked from block layer request processing function,
+ * its task is to remap block request to different nodes.
+ */
+static int dst_mirror_remap(struct dst_request *req)
+{
+	int (*remap[])(struct dst_request *) =
+		{&dst_mirror_read, &dst_mirror_write};
+
+	return remap[bio_rw(req->bio) == WRITE](req);
+}
+
+static void dst_mirror_write_queued(struct dst_node *n)
+{
+	struct dst_mirror_priv *priv = n->priv;
+	unsigned long flags;
+	struct dst_request *req;
+	int num = priv->resync_wait_num, err;
+
+	while (!list_empty(&priv->resync_wait_list) && num != 0) {
+		req = NULL;
+		spin_lock_irqsave(&priv->resync_wait_lock, flags);
+		if (!list_empty(&priv->resync_wait_list)) {
+			req = list_entry(priv->resync_wait_list.next,
+					struct dst_request,
+					request_list_entry);
+			list_del_init(&req->request_list_entry);
+			num--;
+		}
+		spin_unlock_irqrestore(&priv->resync_wait_lock, flags);
+
+		if (!req)
+			break;
+
+		dprintk("%s: queued request n: %p, req: %p, start: %llu, size: %llu, num: %d.\n",
+				__func__, n, req, req->start, (u64)to_sector(req->size), num);
+		err = dst_mirror_process_request(req, n);
+		if (err)
+			break;
+	}
+}
+
+static int dst_mirror_resync_partial(struct dst_node *node)
+{
+	struct dst_storage *st = node->st;
+	struct dst_node *first = node->shared_head, *n, *sync;
+	struct dst_mirror_priv *p = node->priv, *sp;
+	struct dst_mirror_node_data *pd = &p->data;
+	struct dst_mirror_node_data *spd;
+	struct dst_write_entry *e, *ep;
+	unsigned long flags;
+	unsigned int pnum, idx;
+	u64 start;
+	u32 size;
+
+	if (!first)
+		first = node;
+
+	sync = NULL;
+	mutex_lock(&st->tree_lock);
+	list_for_each_entry(n, &first->shared, shared) {
+		if (!test_bit(DST_NODE_NOTSYNC, &n->flags)) {
+			sync = n;
+			dst_node_get(sync);
+			break;
+		}
+	}
+	mutex_unlock(&st->tree_lock);
+	dprintk("%s: n: %p, first: %p, sync: %p.\n", __func__, node, first, sync);
+
+	if (!sync)
+		return -ENODEV;
+
+	sp = sync->priv;
+	spd = &sp->data;
+
+	spin_lock_irqsave(&sp->log_lock, flags);
+	spin_lock(&p->log_lock);
+
+	pnum = pd->resync_idx / DST_LOG_ENTRIES_PER_PAGE;
+	idx = pd->resync_idx % DST_LOG_ENTRIES_PER_PAGE;
+
+	ep = sp->log.entries[pnum];
+	e = &ep[idx];
+
+	start = e->start;
+	size = e->size;
+
+	spin_unlock(&p->log_lock);
+	spin_unlock_irqrestore(&sp->log_lock, flags);
+
+	dprintk("%s: node write_idx: %llu, resync_idx: %llu, num: %llu, sync write_idx: %llu, num: %llu.\n",
+			__func__, pd->write_idx, pd->resync_idx, pd->num, spd->write_idx, spd->num);
+	dprintk("%s: sync request: start: %llu, size: %llu.\n",
+			__func__, start, (u64)to_sector(size));
+
+	dst_node_put(sync);
+
+	return dst_mirror_sync_block(node, to_bytes(start), size);
+}
+
+/*
+ * Resync logic - sliding window algorithm.
+ *
+ * At startup system checks age (unique cookie) of the node and if it
+ * does not match first node it resyncs all data from the first node in
+ * the mirror to others (non-sync nodes), each non-synced node has a
+ * window, which slides from the start of the node to the end. 
+ * During resync all requests, which enter the window are queued, thus
+ * window has to be sufficiently small. When window is synced from the
+ * other nodes, queued requests are written and window moves forward,
+ * thus subsequent resync is started when previous window is fully completed.
+ * When window reaches end of the node, it is marked as synchronized.
+ *
+ * If age of the node matches the first one, but log contains different
+ * number of write log entries compared to the first node (first node always
+ * stands as a clean), then partial resync is scheduled.
+ * Partial resync will also be scheduled when log entry pointed by resync
+ * index of the node contains error.
+ *
+ * Mechanism of this resync type is following: system selects a sync node
+ * (checking each node's flags) and fetches a log entry pointed by resync
+ * index of the given node and resync data from other nodes to given one.
+ * Then it checks the rest of the write log and checks if there are
+ * another failed writes, so that next resync block would be fetched for
+ * them.
+ */
+static int dst_mirror_resync(struct dst_node *n, int ndp)
+{
+	struct dst_mirror_priv *priv = n->priv;
+	struct dst_mirror_priv *fp = priv;
+	u64 total, allowed, size;
+	int err;
+	
+	if (n->shared_head)
+		fp = n->shared_head->priv;
+
+	if (!test_bit(DST_NODE_NOTSYNC, &n->flags))
+		return 0;
+	if (atomic_read(&priv->resync_num) != 0) {
+		dprintk("%s: n: %p, resync_num: %d.\n",
+			__func__, n, atomic_read(&priv->resync_num));
+		return -EAGAIN;
+	}
+
+	allowed = global_page_state(NR_FREE_PAGES) +
+		global_page_state(NR_FILE_PAGES);
+	allowed /= 2;
+	allowed = to_sector(allowed << PAGE_SHIFT);
+
+	size = min(priv->resync_size, n->size - priv->resync_start);
+
+	total = min(allowed, size);
+
+	printk(KERN_NOTICE "%s: node: %p, %llu:%llu %s synchronization has been started "
+			"from %llu, allowed: %llu, total: %llu.\n",
+			__func__, n, n->start, n->size,
+			(priv->data.age == fp->data.age) ? "partial" : "full",
+			priv->resync_start, allowed, total);
+
+	if (!priv->full_resync)
+		return dst_mirror_resync_partial(n);
+
+	dst_mirror_write_queued(n);
+
+	if (priv->resync_start == n->size) {
+		dst_mirror_mark_node_sync(n);
+		priv->data.age = fp->data.age;
+		dst_mirror_write_node_data(n, &priv->data);
+		return 0;
+	}
+
+	if (ndp) {
+		err = dst_mirror_ndp_setup(n, 0, 0);
+		if (err)
+			return err;
+	}
+
+	err = dst_mirror_sync_block(n, to_bytes(priv->resync_start),
+			to_bytes(total));
+	if (!err)
+		priv->resync_start += total;
+
+	return err;
+}
+
+static int dst_mirror_error(struct kst_state *st, int err)
+{
+	struct dst_request *req, *tmp;
+	unsigned int revents = st->socket->ops->poll(NULL, st->socket, NULL);
+
+	dprintk("%s: err: %d, revents: %x, notsync: %d.\n",
+			__func__, err, revents,
+			test_bit(DST_NODE_NOTSYNC, &st->node->flags));
+
+	if (err == -EEXIST)
+		return err;
+
+	if (!(revents & (POLLERR | POLLHUP)) &&
+		   	(err == -EPIPE || err == -ECONNRESET)) {
+		if (test_bit(DST_NODE_NOTSYNC, &st->node->flags))
+			return dst_mirror_resync(st->node, 1);
+		return 0;
+	}
+
+	if (atomic_read(&st->node->shared_num) == 0 &&
+			!st->node->shared_head) {
+		dprintk("%s: this node is the only one in the mirror, "
+				"can not mark it notsync.\n", __func__);
+		return err;
+	}
+
+	dst_mirror_mark_notsync(st->node);
+
+	mutex_lock(&st->request_lock);
+	list_for_each_entry_safe(req, tmp, &st->request_list,
+					request_list_entry) {
+		kst_del_req(req);
+		dprintk("%s: requeue [%c], start: %llu, idx: %d,"
+				" num: %d, size: %llu, offset: %u, err: %d.\n",
+			__func__, (bio_rw(req->bio) == WRITE)?'W':'R',
+			req->start, req->idx, req->num, req->size,
+			req->offset, err);
+
+		if (bio_rw(req->bio) != WRITE) {
+			req->start -= to_sector(req->orig_size - req->size);
+			req->size = req->orig_size;
+			req->flags &= ~(DST_REQ_HEADER_SENT | DST_REQ_CHEKSUM_RECV);
+			req->idx = 0;
+			if (dst_mirror_read(req))
+				dst_free_request(req);
+		} else {
+			kst_complete_req(req, err);
+		}
+	}
+	mutex_unlock(&st->request_lock);
+	return err;
+}
+
+/*
+ * This callback is invoked when node is removed from storage.
+ */
+static void dst_mirror_del_node(struct dst_node *n)
+{
+	struct dst_mirror_priv *priv = n->priv;
+
+	priv->full_resync = 1;
+	cancel_rearming_delayed_work(&priv->resync_work);
+	flush_scheduled_work();
+
+	dprintk("%s: n: %p, backlog_empty: %d, resync_num: %d.\n",
+		__func__, n, list_empty(&priv->backlog_list),
+		atomic_read(&priv->resync_num));
+
+	/*
+	 * This strange-looking loop waits until all resync read requests
+	 * are completed, this happens in dst_mirror_sync_requeue().
+	 */
+	while (atomic_read(&priv->resync_num)) {
+		dst_mirror_sync_requeue(n, 1);
+		if (printk_ratelimit())
+			dprintk("%s: n: %p, backlog_empty: %d, resync_num: %d.\n",
+				__func__, n, list_empty(&priv->backlog_list),
+				atomic_read(&priv->resync_num));
+		msleep(100);
+	}
+
+	wait_for_completion(&priv->resync_complete);
+	dst_mirror_sync_requeue(n, 1);
+
+	if (priv) {
+		dst_mirror_log_exit(n);
+		kfree(priv);
+		n->priv = NULL;
+	}
+
+	if (n->device.parent == &n->st->device) {
+		int i;
+
+		for (i=0; i<ARRAY_SIZE(dst_mirror_attrs); ++i)
+			device_remove_file(&n->device, &dst_mirror_attrs[i]);
+	}
+}
+
+static struct dst_alg_ops alg_mirror_ops = {
+	.remap		= dst_mirror_remap,
+	.add_node	= dst_mirror_add_node,
+	.del_node	= dst_mirror_del_node,
+	.error		= dst_mirror_error,
+	.owner		= THIS_MODULE,
+};
+
+static int __devinit alg_mirror_init(void)
+{
+	int err = -ENOMEM;
+
+	dst_mirror_bio_set = bioset_create(256, 256);
+	if (!dst_mirror_bio_set)
+		return -ENOMEM;
+
+	alg_mirror = dst_alloc_alg("alg_mirror", &alg_mirror_ops);
+	if (!alg_mirror)
+		goto err_out;
+
+	return 0;
+
+err_out:
+	bioset_free(dst_mirror_bio_set);
+	return err;
+}
+
+static void __devexit alg_mirror_exit(void)
+{
+	dst_remove_alg(alg_mirror);
+	bioset_free(dst_mirror_bio_set);
+}
+
+module_init(alg_mirror_init);
+module_exit(alg_mirror_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
+MODULE_DESCRIPTION("Mirror distributed algorithm.");

