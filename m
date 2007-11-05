From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [4/4] Distributed storage. Core interfaces.
Date: Mon, 5 Nov 2007 21:42:29 +0300
Message-ID: <20071105184228.GE26175@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55009 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756095AbXKESmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 13:42:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This one contains core interfaces of the distributed storage, storage
and node initialization and cleanup code, block layer callbacks and the
like. It also contains Kconfig and Makefile changes.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index b4c8319..ca6592d 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -451,6 +451,8 @@ config ATA_OVER_ETH
 	This driver provides Support for ATA over Ethernet block
 	devices like the Coraid EtherDrive (R) Storage Blade.
 
+source "drivers/block/dst/Kconfig"
+
 source "drivers/s390/block/Kconfig"
 
 endmenu
diff --git a/drivers/block/Makefile b/drivers/block/Makefile
index dd88e33..fcf042d 100644
--- a/drivers/block/Makefile
+++ b/drivers/block/Makefile
@@ -29,3 +29,4 @@ obj-$(CONFIG_VIODASD)		+= viodasd.o
 obj-$(CONFIG_BLK_DEV_SX8)	+= sx8.o
 obj-$(CONFIG_BLK_DEV_UB)	+= ub.o
 
+obj-$(CONFIG_DST)		+= dst/
diff --git a/drivers/block/dst/Kconfig b/drivers/block/dst/Kconfig
new file mode 100644
index 0000000..d35e0cc
--- /dev/null
+++ b/drivers/block/dst/Kconfig
@@ -0,0 +1,21 @@
+config DST
+	tristate "Distributed storage"
+	depends on NET
+	select CONNECTOR
+	select LIBCRC32C
+	---help---
+	This driver allows to create a distributed storage.
+
+config DST_ALG_LINEAR
+	tristate "Linear distribution algorithm"
+	depends on DST
+	---help---
+	This module allows to create linear mapping of the nodes
+	in the distributed storage.
+
+config DST_ALG_MIRROR
+	tristate "Mirror distribution algorithm"
+	depends on DST
+	---help---
+	This module allows to create a mirror of the noes in the
+	distributed storage.
diff --git a/drivers/block/dst/Makefile b/drivers/block/dst/Makefile
new file mode 100644
index 0000000..1400e94
--- /dev/null
+++ b/drivers/block/dst/Makefile
@@ -0,0 +1,6 @@
+obj-$(CONFIG_DST) += dst.o
+
+dst-y := dcore.o kst.o
+
+obj-$(CONFIG_DST_ALG_LINEAR) += alg_linear.o
+obj-$(CONFIG_DST_ALG_MIRROR) += alg_mirror.o

diff --git a/drivers/block/dst/dcore.c b/drivers/block/dst/dcore.c
new file mode 100644
index 0000000..2b3ef10
--- /dev/null
+++ b/drivers/block/dst/dcore.c
@@ -0,0 +1,1608 @@
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
+#include <linux/blkdev.h>
+#include <linux/bio.h>
+#include <linux/slab.h>
+#include <linux/connector.h>
+#include <linux/socket.h>
+#include <linux/dst.h>
+#include <linux/device.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/buffer_head.h>
+
+#include <net/sock.h>
+
+static LIST_HEAD(dst_storage_list);
+static LIST_HEAD(dst_alg_list);
+static DEFINE_MUTEX(dst_storage_lock);
+static DEFINE_MUTEX(dst_alg_lock);
+static int dst_major;
+static struct kst_worker *kst_main_worker;
+static struct cb_id cn_dst_id = { CN_DST_IDX, CN_DST_VAL };
+
+struct kmem_cache *dst_request_cache;
+
+static char dst_name[] = "Squizzed black-out of the dancing back-aching hippo";
+
+/*
+ * DST sysfs tree. For device called 'storage' which is formed
+ * on top of two nodes this looks like this:
+ *
+ * /sys/devices/storage/
+ * /sys/devices/storage/alg : alg_linear
+ * /sys/devices/storage/n-800/type : R: 192.168.4.80:1025
+ * /sys/devices/storage/n-800/size : 800
+ * /sys/devices/storage/n-800/start : 800
+ * /sys/devices/storage/n-800/clean
+ * /sys/devices/storage/n-800/dirty
+ * /sys/devices/storage/n-0/type : R: 192.168.4.81:1025
+ * /sys/devices/storage/n-0/size : 800
+ * /sys/devices/storage/n-0/start : 0
+ * /sys/devices/storage/n-0/clean
+ * /sys/devices/storage/n-0/dirty
+ * /sys/devices/storage/remove_all_nodes
+ * /sys/devices/storage/nodes : sectors (start [size]): 0 [800] | 800 [800]
+ * /sys/devices/storage/name : storage
+ */
+
+static int dst_dev_match(struct device *dev, struct device_driver *drv)
+{
+	return 1;
+}
+
+static void dst_dev_release(struct device *dev)
+{
+}
+
+static struct bus_type dst_dev_bus_type = {
+	.name 		= "dst",
+	.match 		= &dst_dev_match,
+};
+
+static struct device dst_dev = {
+	.bus 		= &dst_dev_bus_type,
+	.release 	= &dst_dev_release
+};
+
+static void dst_node_release(struct device *dev)
+{
+}
+
+static struct device dst_node_dev = {
+	.release 	= &dst_node_release
+};
+
+static void dst_free_alg(struct dst_alg *alg)
+{
+	kfree(alg);
+}
+
+/*
+ * Algorithm is never freed directly,
+ * since its module reference counter is increased
+ * by storage when it is created - just like network protocols.
+ */
+static inline void dst_put_alg(struct dst_alg *alg)
+{
+	module_put(alg->ops->owner);
+	if (atomic_dec_and_test(&alg->refcnt))
+		dst_free_alg(alg);
+}
+
+static void dst_free_storage(struct dst_storage *st)
+{
+	BUG_ON(rb_first(&st->tree_root) != NULL);
+
+	dst_put_alg(st->alg);
+	kfree(st);
+}
+
+static inline void dst_put_storage(struct dst_storage *st)
+{
+	if (atomic_dec_and_test(&st->refcnt))
+		dst_free_storage(st);
+}
+
+static struct bio_set *dst_bio_set;
+
+static void dst_destructor(struct bio *bio)
+{
+	bio_free(bio, dst_bio_set);
+}
+
+/*
+ * Internal callback for local requests (i.e. for local disk),
+ * which are splitted between nodes (part with local node destination
+ * ends up with this ->bi_end_io() callback).
+ */
+static int dst_end_io(struct bio *bio, unsigned int size, int err)
+{
+	struct bio *orig_bio = bio->bi_private;
+
+	if (bio->bi_size)
+		return 0;
+
+	dprintk("%s: bio: %p, orig_bio: %p, size: %u, orig_size: %u.\n",
+		__func__, bio, orig_bio, size, orig_bio->bi_size);
+
+	bio_endio(orig_bio, size, 0);
+	bio_put(bio);
+	return 0;
+}
+
+/*
+ * This function sends processing request down to block layer (for local node)
+ * or to network state machine (for remote node).
+ */
+static int dst_node_push(struct dst_request *req)
+{
+	int err = 0;
+	struct dst_node *n = req->node;
+
+	if (n->bdev) {
+		struct bio *bio = req->bio;
+
+		dprintk("%s: start: %llu, num: %d, idx: %d, offset: %u, "
+				"size: %llu, bi_idx: %d, bi_vcnt: %d.\n",
+			__func__, req->start, req->num, req->idx,
+			req->offset, req->size,	bio->bi_idx, bio->bi_vcnt);
+
+		if (likely(bio->bi_idx == req->idx &&
+					bio->bi_vcnt == req->num)) {
+			bio->bi_bdev = n->bdev;
+			bio->bi_sector = req->start;
+		} else {
+			struct bio *clone = bio_alloc_bioset(GFP_NOIO,
+					bio->bi_max_vecs, dst_bio_set);
+			struct bio_vec *bv;
+
+			err = -ENOMEM;
+			if (!clone)
+				goto out_put;
+
+			__bio_clone(clone, bio);
+
+			bv = bio_iovec_idx(clone, req->idx);
+			bv->bv_offset += req->offset;
+			clone->bi_idx = req->idx;
+			clone->bi_vcnt = req->num;
+			clone->bi_bdev = n->bdev;
+			clone->bi_sector = req->start;
+			clone->bi_destructor = dst_destructor;
+			clone->bi_private = bio;
+			clone->bi_size = req->orig_size;
+			clone->bi_end_io = &dst_end_io;
+			req->bio = clone;
+
+			dprintk("%s: start: %llu, num: %d, idx: %d, "
+				"offset: %u, size: %llu, "
+				"bi_idx: %d, bi_vcnt: %d, req: %p, bio: %p.\n",
+				__func__, req->start, req->num, req->idx,
+				req->offset, req->size,
+				clone->bi_idx, clone->bi_vcnt, req, req->bio);
+
+		}
+	}
+
+	err = n->st->alg->ops->remap(req);
+
+out_put:
+	dst_node_put(n);
+	return err;
+}
+
+/*
+ * This function is invoked from block layer request processing function,
+ * its task is to remap block request to different nodes.
+ */
+static int dst_remap(struct dst_storage *st, struct bio *bio)
+{
+	struct dst_node *n;
+	int err = -EINVAL, i, cnt;
+	unsigned int bio_sectors = bio->bi_size>>9;
+	struct bio_vec *bv;
+	struct dst_request req;
+	u64 rest_in_node, start, total_size;
+
+	mutex_lock(&st->tree_lock);
+	n = dst_storage_tree_search(st, bio->bi_sector);
+	mutex_unlock(&st->tree_lock);
+
+	if (!n) {
+		dprintk("%s: failed to find a node for bio: %p, "
+				"sector: %llu.\n",
+				__func__, bio, (u64)bio->bi_sector);
+		return -ENODEV;
+	}
+
+	dprintk("%s: bio: %llu-%llu, dev: %llu-%llu, in sectors.\n",
+			__func__, (u64)bio->bi_sector, (u64)bio->bi_sector+bio_sectors,
+			n->start, n->start+n->size);
+
+	memset(&req, 0, sizeof(struct dst_request));
+
+	start = bio->bi_sector;
+	total_size = bio->bi_size;
+
+	req.flags = (test_bit(DST_NODE_FROZEN, &n->flags))?
+				DST_REQ_ALWAYS_QUEUE:0;
+	req.start = start - n->start;
+	req.offset = 0;
+	req.state = n->state;
+	req.node = n;
+	req.bio = bio;
+
+	req.size = bio->bi_size;
+	req.orig_size = bio->bi_size;
+	req.idx = bio->bi_idx;
+	req.num = bio->bi_vcnt;
+
+	req.bio_endio = &kst_bio_endio;
+
+	/*
+	 * Common fast path - block request does not cross
+	 * boundaries between nodes.
+	 */
+	if (likely(bio->bi_sector + bio_sectors <= n->start + n->size))
+		return dst_node_push(&req);
+
+	req.size = 0;
+	req.idx = 0;
+	req.num = 1;
+
+	cnt = bio->bi_vcnt;
+
+	rest_in_node = to_bytes(n->size - req.start);
+
+	for (i = 0; i < cnt; ++i) {
+		bv = bio_iovec_idx(bio, i);
+
+		if (req.size + bv->bv_len >= rest_in_node) {
+			unsigned int diff = req.size + bv->bv_len -
+				rest_in_node;
+
+			req.size += bv->bv_len - diff;
+			req.start = start - n->start;
+			req.orig_size = req.size;
+			req.bio = bio;
+			req.bio_endio = &kst_bio_endio;
+
+			dprintk("%s: split: start: %llu/%llu, size: %llu, "
+					"total_size: %llu, diff: %u, idx: %d, "
+					"num: %d, bv_len: %u, bv_offset: %u.\n",
+					__func__, start, req.start, req.size,
+					total_size, diff, req.idx, req.num,
+					bv->bv_len, bv->bv_offset);
+
+			err = dst_node_push(&req);
+			if (err)
+				break;
+
+			total_size -= req.orig_size;
+
+			if (!total_size)
+				break;
+
+			start += to_sector(req.orig_size);
+
+			req.flags = (test_bit(DST_NODE_FROZEN, &n->flags))?
+				DST_REQ_ALWAYS_QUEUE:0;
+			req.orig_size = req.size = diff;
+
+			if (diff) {
+				req.offset = bv->bv_len - diff;
+				req.idx = req.num - 1;
+			} else {
+				req.idx = req.num;
+				req.offset = 0;
+			}
+
+			dprintk("%s: next: start: %llu, size: %llu, "
+				"total_size: %llu, diff: %u, idx: %d, "
+				"num: %d, offset: %u, bv_len: %u, "
+				"bv_offset: %u.\n",
+				__func__, start, req.size, total_size, diff,
+				req.idx, req.num, req.offset,
+				bv->bv_len, bv->bv_offset);
+
+			mutex_lock(&st->tree_lock);
+			n = dst_storage_tree_search(st, start);
+			mutex_unlock(&st->tree_lock);
+
+			if (!n) {
+				err = -ENODEV;
+				dprintk("%s: failed to find a split node for "
+				  "bio: %p, sector: %llu, start: %llu.\n",
+						__func__, bio, (u64)bio->bi_sector,
+						req.start);
+				break;
+			}
+
+			req.state = n->state;
+			req.node = n;
+			req.start = start - n->start;
+			rest_in_node = to_bytes(n->size - req.start);
+
+			dprintk("%s: req.start: %llu, start: %llu, "
+					"dev_start: %llu, dev_size: %llu, "
+					"rest_in_node: %llu.\n",
+				__func__, req.start, start, n->start,
+				n->size, rest_in_node);
+		} else {
+			req.size += bv->bv_len;
+			req.num++;
+		}
+	}
+
+	dprintk("%s: last request: start: %llu, size: %llu, "
+			"total_size: %llu.\n", __func__,
+			req.start, req.size, total_size);
+	if (total_size) {
+		req.orig_size = req.size;
+		req.bio = bio;
+		req.bio_endio = &kst_bio_endio;
+
+		dprintk("%s: last: start: %llu/%llu, size: %llu, "
+				"total_size: %llu, idx: %d, num: %d.\n",
+			__func__, start, req.start, req.size,
+			total_size, req.idx, req.num);
+
+		err = dst_node_push(&req);
+		if (!err) {
+			total_size -= req.orig_size;
+
+			BUG_ON(total_size != 0);
+		}
+	}
+
+	dprintk("%s: end bio: %p, err: %d.\n", __func__, bio, err);
+	return err;
+}
+
+/*
+ * Distributed storage erquest processing function.
+ * It calls algorithm spcific remapping code only.
+ */
+static int dst_request(request_queue_t *q, struct bio *bio)
+{
+	struct dst_storage *st = q->queuedata;
+	int err;
+
+	dprintk("\n%s: start: st: %p, bio: %p, cnt: %u.\n",
+			__func__, st, bio, bio->bi_vcnt);
+
+	err = dst_remap(st, bio);
+	if (err)
+		bio_endio(bio, bio->bi_size, err);
+
+	dprintk("%s: end: st: %p, bio: %p, err: %d.\n",
+			__func__, st, bio, err);
+	return 0;
+}
+
+static void dst_unplug(request_queue_t *q)
+{
+}
+
+static int dst_flush(request_queue_t *q, struct gendisk *disk, sector_t *sec)
+{
+	return 0;
+}
+
+static int dst_blk_open(struct inode *inode, struct file *file)
+{
+	struct dst_storage *st = inode->i_bdev->bd_disk->private_data;
+
+	dprintk("%s: storage: %p.\n", __func__, st);
+	atomic_inc(&st->refcnt);
+	return 0;
+}
+
+static int dst_blk_release(struct inode *inode, struct file *file)
+{
+	struct dst_storage *st = inode->i_bdev->bd_disk->private_data;
+
+	dprintk("%s: storage: %p.\n", __func__, st);
+	dst_put_storage(st);
+	return 0;
+}
+
+static struct block_device_operations dst_blk_ops = {
+	.open = &dst_blk_open,
+	.release = &dst_blk_release,
+	.owner = THIS_MODULE,
+};
+
+/*
+ * Block layer binding - disk is created when array is fully configured
+ * by userspace request.
+ */
+static int dst_create_disk(struct dst_storage *st)
+{
+	int err = -ENOMEM;
+
+	st->queue = blk_alloc_queue(GFP_KERNEL);
+	if (!st->queue)
+		goto err_out_exit;
+
+	st->queue->queuedata = st;
+	blk_queue_make_request(st->queue, dst_request);
+	blk_queue_bounce_limit(st->queue, BLK_BOUNCE_ANY);
+	st->queue->unplug_fn = dst_unplug;
+	st->queue->issue_flush_fn = dst_flush;
+
+	err = -EINVAL;
+	st->disk = alloc_disk(1);
+	if (!st->disk)
+		goto err_out_free_queue;
+
+	st->disk->major = dst_major;
+	st->disk->first_minor = (((unsigned long)st->disk) ^
+		(((unsigned long)st->disk) >> 31)) & 0xff;
+	st->disk->fops = &dst_blk_ops;
+	st->disk->queue = st->queue;
+	st->disk->private_data = st;
+	snprintf(st->disk->disk_name, sizeof(st->disk->disk_name),
+			"dst-%s-%d", st->name, st->disk->first_minor);
+
+	return 0;
+
+err_out_free_queue:
+	blk_cleanup_queue(st->queue);
+err_out_exit:
+	return err;
+}
+
+static void dst_remove_disk(struct dst_storage *st)
+{
+	del_gendisk(st->disk);
+	put_disk(st->disk);
+	blk_cleanup_queue(st->queue);
+}
+
+/*
+ * Shows node name in sysfs.
+ */
+static ssize_t dst_name_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct dst_storage *st = container_of(dev, struct dst_storage, device);
+
+	return sprintf(buf, "%s\n", st->name);
+}
+
+static void dst_remove_all_nodes(struct dst_storage *st)
+{
+	struct dst_node *n, *node, *tmp;
+	struct rb_node *rb_node;
+
+	mutex_lock(&st->tree_lock);
+	while ((rb_node = rb_first(&st->tree_root)) != NULL) {
+		n = rb_entry(rb_node, struct dst_node, tree_node);
+		dprintk("%s: n: %p, start: %llu, size: %llu.\n",
+				__func__, n, n->start, n->size);
+		rb_erase(&n->tree_node, &st->tree_root);
+		if (!n->shared_head && atomic_read(&n->shared_num)) {
+			list_for_each_entry_safe(node, tmp, &n->shared, shared) {
+				list_del(&node->shared);
+				atomic_dec(&node->shared_head->refcnt);
+				node->shared_head = NULL;
+				dst_node_put(node);
+			}
+		}
+		dst_node_put(n);
+	}
+	mutex_unlock(&st->tree_lock);
+}
+
+/*
+ * Shows node layout in syfs.
+ */
+static ssize_t dst_nodes_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct dst_storage *st = container_of(dev, struct dst_storage, device);
+	int size = PAGE_CACHE_SIZE, sz;
+	struct dst_node *n;
+	struct rb_node *rb_node;
+
+	sz = sprintf(buf, "sectors (start [size]): ");
+	size -= sz;
+	buf += sz;
+
+	mutex_lock(&st->tree_lock);
+	for (rb_node = rb_first(&st->tree_root); rb_node;
+			rb_node = rb_next(rb_node)) {
+		n = rb_entry(rb_node, struct dst_node, tree_node);
+		if (size < 32)
+			break;
+		sz = sprintf(buf, "%llu [%llu]", n->start, n->size);
+		buf += sz;
+		size -= sz;
+
+		if (!rb_next(rb_node))
+			break;
+
+		sz = sprintf(buf, " | ");
+		buf += sz;
+		size -= sz;
+	}
+	mutex_unlock(&st->tree_lock);
+	size -= sprintf(buf, "\n");
+	return PAGE_CACHE_SIZE - size;
+}
+
+/*
+ * Algorithm currently being used by given storage.
+ */
+static ssize_t dst_alg_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct dst_storage *st = container_of(dev, struct dst_storage, device);
+	return sprintf(buf, "%s\n", st->alg->name);
+}
+
+/*
+ * Writing to this sysfs file allows to remove all nodes
+ * and storage itself automatically.
+ */
+static ssize_t dst_remove_nodes(struct device *dev,
+		struct device_attribute *attr,
+		const char *buf, size_t count)
+{
+	struct dst_storage *st = container_of(dev, struct dst_storage, device);
+	dst_remove_all_nodes(st);
+	return count;
+}
+
+static DEVICE_ATTR(name, 0444, dst_name_show, NULL);
+static DEVICE_ATTR(nodes, 0444, dst_nodes_show, NULL);
+static DEVICE_ATTR(alg, 0444, dst_alg_show, NULL);
+static DEVICE_ATTR(remove_all_nodes, 0644, NULL, dst_remove_nodes);
+
+static int dst_create_storage_attributes(struct dst_storage *st)
+{
+	int err;
+
+	err = device_create_file(&st->device, &dev_attr_name);
+	err = device_create_file(&st->device, &dev_attr_nodes);
+	err = device_create_file(&st->device, &dev_attr_alg);
+	err = device_create_file(&st->device, &dev_attr_remove_all_nodes);
+	return 0;
+}
+
+static void dst_remove_storage_attributes(struct dst_storage *st)
+{
+	device_remove_file(&st->device, &dev_attr_name);
+	device_remove_file(&st->device, &dev_attr_nodes);
+	device_remove_file(&st->device, &dev_attr_alg);
+	device_remove_file(&st->device, &dev_attr_remove_all_nodes);
+}
+
+static void dst_storage_sysfs_exit(struct dst_storage *st)
+{
+	dst_remove_storage_attributes(st);
+	device_unregister(&st->device);
+}
+
+static int dst_storage_sysfs_init(struct dst_storage *st)
+{
+	int err;
+
+	memcpy(&st->device, &dst_dev, sizeof(struct device));
+	snprintf(st->device.bus_id, sizeof(st->device.bus_id), "%s", st->name);
+
+	err = device_register(&st->device);
+	if (err) {
+		dprintk(KERN_ERR "Failed to register dst device %s, err: %d.\n",
+			st->name, err);
+		goto err_out_exit;
+	}
+
+	dst_create_storage_attributes(st);
+
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+/*
+ * This functions shows size and start of the appropriate node.
+ * Both are in sectors.
+ */
+static ssize_t dst_show_start(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct dst_node *n = container_of(dev, struct dst_node, device);
+
+	return sprintf(buf, "%llu\n", n->start);
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
+	if (!n->state && !n->bdev)
+		return 0;
+
+	if (n->bdev)
+		return sprintf(buf, "L: %d:%d\n",
+				MAJOR(n->bdev->bd_dev), MINOR(n->bdev->bd_dev));
+
+	sock = n->state->socket;
+	if (sock->ops->getname(sock, &addr, &addrlen, 2))
+		return 0;
+
+	if (sock->ops->family == AF_INET) {
+		struct sockaddr_in *sin = (struct sockaddr_in *)&addr;
+		return sprintf(buf, "R: %u.%u.%u.%u:%d\n",
+			NIPQUAD(sin->sin_addr.s_addr), ntohs(sin->sin_port));
+	} else if (sock->ops->family == AF_INET6) {
+		struct sockaddr_in6 *sin = (struct sockaddr_in6 *)&addr;
+		return sprintf(buf,
+			"R: %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%d\n",
+			NIP6(sin->sin6_addr), ntohs(sin->sin6_port));
+	}
+	return 0;
+}
+
+static DEVICE_ATTR(start, 0444, dst_show_start, NULL);
+static DEVICE_ATTR(size, 0444, dst_show_size, NULL);
+static DEVICE_ATTR(type, 0444, dst_show_type, NULL);
+
+static int dst_create_node_attributes(struct dst_node *n)
+{
+	int err;
+
+	err = device_create_file(&n->device, &dev_attr_start);
+	err = device_create_file(&n->device, &dev_attr_size);
+	err = device_create_file(&n->device, &dev_attr_type);
+	return 0;
+}
+
+static void dst_remove_node_attributes(struct dst_node *n)
+{
+	device_remove_file(&n->device, &dev_attr_start);
+	device_remove_file(&n->device, &dev_attr_size);
+	device_remove_file(&n->device, &dev_attr_type);
+}
+
+static void dst_node_sysfs_exit(struct dst_node *n)
+{
+	if (n->device.parent == &n->st->device) {
+		dst_remove_node_attributes(n);
+		device_unregister(&n->device);
+		n->device.parent = NULL;
+	}
+}
+
+static int dst_node_sysfs_init(struct dst_node *n)
+{
+	int err;
+
+	memcpy(&n->device, &dst_node_dev, sizeof(struct device));
+
+	n->device.parent = &n->st->device;
+
+	snprintf(n->device.bus_id, sizeof(n->device.bus_id),
+			"n-%llu-%p", n->start, n);
+	err = device_register(&n->device);
+	if (err) {
+		dprintk(KERN_ERR "Failed to register node, err: %d.\n", err);
+		goto err_out_exit;
+	}
+
+	dst_create_node_attributes(n);
+
+	return 0;
+
+err_out_exit:
+	n->device.parent = NULL;
+	return err;
+}
+
+/*
+ * Gets a reference for given storage, if
+ * storage with given name and algorithm being used
+ * does not exist it is created.
+ */
+static struct dst_storage *dst_get_storage(char *name, char *aname, int alloc)
+{
+	struct dst_storage *st, *rst = NULL;
+	int err;
+	struct dst_alg *alg;
+
+	mutex_lock(&dst_storage_lock);
+	list_for_each_entry(st, &dst_storage_list, entry) {
+		if (!strcmp(name, st->name) && !strcmp(st->alg->name, aname)) {
+			rst = st;
+			atomic_inc(&st->refcnt);
+			break;
+		}
+	}
+
+	if (rst || !alloc) {
+		mutex_unlock(&dst_storage_lock);
+		return rst;
+	}
+
+	st = kzalloc(sizeof(struct dst_storage), GFP_KERNEL);
+	if (!st) {
+		mutex_unlock(&dst_storage_lock);
+		return NULL;
+	}
+
+	mutex_init(&st->tree_lock);
+	/*
+	 * One for storage itself,
+	 * another one for attached node below.
+	 */
+	atomic_set(&st->refcnt, 2);
+	snprintf(st->name, DST_NAMELEN, "%s", name);
+	st->tree_root.rb_node = NULL;
+
+	err = dst_storage_sysfs_init(st);
+	if (err)
+		goto err_out_free;
+
+	err = dst_create_disk(st);
+	if (err)
+		goto err_out_sysfs_exit;
+
+	mutex_lock(&dst_alg_lock);
+	list_for_each_entry(alg, &dst_alg_list, entry) {
+		if (!strcmp(alg->name, aname)) {
+			atomic_inc(&alg->refcnt);
+			try_module_get(alg->ops->owner);
+			st->alg = alg;
+			break;
+		}
+	}
+	mutex_unlock(&dst_alg_lock);
+
+	if (!st->alg)
+		goto err_out_disk_remove;
+
+	list_add_tail(&st->entry, &dst_storage_list);
+	mutex_unlock(&dst_storage_lock);
+
+	return st;
+
+err_out_disk_remove:
+	dst_remove_disk(st);
+err_out_sysfs_exit:
+	dst_storage_sysfs_init(st);
+err_out_free:
+	mutex_unlock(&dst_storage_lock);
+	kfree(st);
+	return NULL;
+}
+
+/*
+ * Allows to allocate and add new algorithm by external modules.
+ */
+struct dst_alg *dst_alloc_alg(char *name, struct dst_alg_ops *ops)
+{
+	struct dst_alg *alg;
+
+	alg = kzalloc(sizeof(struct dst_alg), GFP_KERNEL);
+	if (!alg)
+		return NULL;
+	snprintf(alg->name, DST_NAMELEN, "%s", name);
+	atomic_set(&alg->refcnt, 1);
+	alg->ops = ops;
+
+	mutex_lock(&dst_alg_lock);
+	list_add_tail(&alg->entry, &dst_alg_list);
+	mutex_unlock(&dst_alg_lock);
+
+	return alg;
+}
+EXPORT_SYMBOL_GPL(dst_alloc_alg);
+
+/*
+ * Removing algorithm from main list of supported algorithms.
+ */
+void dst_remove_alg(struct dst_alg *alg)
+{
+	mutex_lock(&dst_alg_lock);
+	list_del_init(&alg->entry);
+	mutex_unlock(&dst_alg_lock);
+
+	dst_put_alg(alg);
+}
+EXPORT_SYMBOL_GPL(dst_remove_alg);
+
+static void dst_cleanup_node(struct dst_node *n)
+{
+	struct dst_storage *st = n->st;
+
+	dprintk("%s: node: %p.\n", __func__, n);
+
+	if (n->shared_head) {
+		mutex_lock(&st->tree_lock);
+		list_del(&n->shared);
+		mutex_unlock(&st->tree_lock);
+
+		atomic_dec(&n->shared_head->refcnt);
+		dst_node_put(n->shared_head);
+		n->shared_head = NULL;
+	}
+
+	if (n->cleanup)
+		n->cleanup(n);
+	dst_node_sysfs_exit(n);
+	n->st->alg->ops->del_node(n);
+	kfree(n);
+}
+
+/*
+ * This can deadlock if called under st->tree_lock being held,
+ * so take care to only call this when reference counter can not
+ * hit zero and thus start node freeing.
+ */
+void dst_node_put(struct dst_node *n)
+{
+	dprintk("%s: node: %p, start: %llu, size: %llu, refcnt: %d.\n",
+			__func__, n, n->start, n->size,
+			atomic_read(&n->refcnt));
+
+	if (atomic_dec_and_test(&n->refcnt)) {
+		struct dst_storage *st = n->st;
+
+		dprintk("%s: freeing node: %p, start: %llu, size: %llu, "
+				"refcnt: %d.\n",
+				__func__, n, n->start, n->size,
+				atomic_read(&n->refcnt));
+
+		dst_cleanup_node(n);
+		dst_put_storage(st);
+	}
+}
+EXPORT_SYMBOL_GPL(dst_node_put);
+
+static inline int dst_compare_id(struct dst_node *old, u64 new)
+{
+	if (old->start + old->size <= new)
+		return 1;
+	if (old->start > new)
+		return -1;
+	return 0;
+}
+
+/*
+ * Tree of of the nodes, which form the storage.
+ * Tree is indexed via start of the node and its size.
+ * Comparison function above.
+ */
+struct dst_node *dst_storage_tree_search(struct dst_storage *st, u64 start)
+{
+	struct rb_node *n = st->tree_root.rb_node;
+	struct dst_node *dn;
+	int cmp;
+
+	while (n) {
+		dn = rb_entry(n, struct dst_node, tree_node);
+
+		cmp = dst_compare_id(dn, start);
+		dprintk("%s: tree: %llu-%llu, new: %llu.\n",
+			__func__, dn->start, dn->start+dn->size, start);
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else {
+			return dst_node_get(dn);
+		}
+	}
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(dst_storage_tree_search);
+
+/*
+ * This function allows to remove a node with given start address
+ * from the storage.
+ */
+static struct dst_node *dst_storage_tree_del(struct dst_storage *st, u64 start)
+{
+	struct dst_node *n = dst_storage_tree_search(st, start);
+
+	if (!n)
+		return NULL;
+
+	rb_erase(&n->tree_node, &st->tree_root);
+	dst_node_put(n);
+	return n;
+}
+
+/*
+ * This function allows to add given node to the storage.
+ * Returns -EEXIST if the same area is already covered by another node.
+ * This is return must be checked for redundancy algorithms.
+ */
+static struct dst_node *dst_storage_tree_add(struct dst_node *new,
+		struct dst_storage *st)
+{
+	struct rb_node **n = &st->tree_root.rb_node, *parent = NULL;
+	struct dst_node *dn;
+	int cmp;
+
+	while (*n) {
+		parent = *n;
+		dn = rb_entry(parent, struct dst_node, tree_node);
+
+		cmp = dst_compare_id(dn, new->start);
+		dprintk("%s: tree: %llu-%llu, new: %llu.\n",
+				__func__, dn->start, dn->start+dn->size,
+				new->start);
+		if (cmp < 0)
+			n = &parent->rb_left;
+		else if (cmp > 0)
+			n = &parent->rb_right;
+		else {
+			return dn;
+		}
+	}
+
+	rb_link_node(&new->tree_node, parent, n);
+	rb_insert_color(&new->tree_node, &st->tree_root);
+
+	return NULL;
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
+	inode = nd.dentry->d_inode;
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
+	path_release(&nd);
+	return err;
+}
+
+/*
+ * Cleanup routings for local, local exporting and remote nodes.
+ */
+static void dst_cleanup_remote(struct dst_node *n)
+{
+	if (n->state) {
+		kst_state_exit(n->state);
+		n->state = NULL;
+	}
+}
+
+static void dst_cleanup_local(struct dst_node *n)
+{
+	if (n->bdev) {
+		sync_blockdev(n->bdev);
+		blkdev_put(n->bdev);
+		n->bdev = NULL;
+	}
+}
+
+static void dst_cleanup_local_export(struct dst_node *n)
+{
+	dst_cleanup_local(n);
+	dst_cleanup_remote(n);
+}
+
+/*
+ * Header receiving function - may block.
+ */
+int dst_data_recv_header(struct socket *sock,
+		struct dst_remote_request *r, int block)
+{
+	struct msghdr msg;
+	struct kvec iov;
+
+	iov.iov_base = r;
+	iov.iov_len = sizeof(struct dst_remote_request);
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = (block)?MSG_WAITALL:MSG_DONTWAIT | MSG_NOSIGNAL;
+
+	return kernel_recvmsg(sock, &msg, &iov, 1, iov.iov_len,
+			msg.msg_flags);
+}
+
+/*
+ * Header sending function - may block.
+ */
+int dst_data_send_header(struct socket *sock,
+		struct dst_remote_request *r)
+{
+	struct msghdr msg;
+	struct kvec iov;
+
+	iov.iov_base = r;
+	iov.iov_len = sizeof(struct dst_remote_request);
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_WAITALL | MSG_NOSIGNAL;
+
+	return kernel_sendmsg(sock, &msg, &iov, 1, iov.iov_len);
+}
+
+static inline void dst_node_set_size(struct dst_node *n, u64 size)
+{
+	if (n->size)
+		n->size = min(size, n->size);
+	else
+		n->size = size;
+}
+
+/*
+ * Setup routings for local, local exporting and remote nodes.
+ */
+static int dst_setup_local(struct dst_node *n, struct dst_ctl *ctl,
+		struct dst_local_ctl *l)
+{
+	dev_t dev;
+	int err;
+
+	err = dst_lookup_device(l->name, &dev);
+	if (err)
+		return err;
+
+	n->bdev = open_by_devnum(dev, FMODE_READ|FMODE_WRITE);
+	if (!n->bdev)
+		return -ENODEV;
+
+	dst_node_set_size(n, n->bdev->bd_inode->i_size);
+
+	return 0;
+}
+
+static int dst_setup_local_export(struct dst_node *n, struct dst_ctl *ctl,
+		struct dst_le_template *tmp)
+{
+	int err;
+
+	err = dst_setup_local(n, ctl, &tmp->le->lctl);
+	if (err)
+		goto err_out_exit;
+
+	n->state = kst_listener_state_init(n, tmp);
+	if (IS_ERR(n->state)) {
+		err = PTR_ERR(n->state);
+		goto err_out_cleanup;
+	}
+
+	return 0;
+
+err_out_cleanup:
+	dst_cleanup_local(n);
+err_out_exit:
+	return err;
+}
+
+static int dst_request_remote_config(struct dst_node *n, struct socket *sock)
+{
+	struct dst_remote_request cfg;
+	int err = -EINVAL;
+
+	memset(&cfg, 0, sizeof(struct dst_remote_request));
+	cfg.cmd = cpu_to_be32(DST_REMOTE_CFG);
+
+	dprintk("%s: sending header.\n", __func__);
+	err = dst_data_send_header(sock, &cfg);
+	if (err != sizeof(struct dst_remote_request))
+		goto out;
+
+	dprintk("%s: receiving header.\n", __func__);
+	err = dst_data_recv_header(sock, &cfg, 1);
+	if (err != sizeof(struct dst_remote_request))
+		goto out;
+
+	err = -EINVAL;
+	dprintk("%s: checking result: cmd: %d, size reported: %llu.\n",
+			__func__, be32_to_cpu(cfg.cmd), be64_to_cpu(cfg.sector));
+	if (be32_to_cpu(cfg.cmd) != DST_REMOTE_CFG)
+		goto out;
+
+	err = 0;
+	dst_node_set_size(n, be64_to_cpu(cfg.sector));
+
+	if (cfg.csum)
+		set_bit(DST_NODE_USE_CSUM, &n->flags);
+
+out:
+	dprintk("%s: n: %p, err: %d.\n", __func__, n, err);
+	return err;
+}
+
+static int dst_setup_remote(struct dst_node *n, struct dst_ctl *ctl,
+		struct dst_remote_ctl *r)
+{
+	int err;
+	struct socket *sock;
+
+	err = sock_create(r->addr.sa_family, r->type, r->proto, &sock);
+	if (err < 0)
+		goto err_out_exit;
+
+	sock->sk->sk_sndtimeo = sock->sk->sk_rcvtimeo =
+		msecs_to_jiffies(DST_DEFAULT_TIMEO);
+
+	err = sock->ops->connect(sock, (struct sockaddr *)&r->addr,
+			r->addr.sa_data_len, 0);
+	if (err)
+		goto err_out_destroy;
+
+	err = dst_request_remote_config(n, sock);
+	if (err)
+		goto err_out_destroy;
+
+	n->state = kst_data_state_init(n, sock);
+	if (IS_ERR(n->state)) {
+		err = PTR_ERR(n->state);
+		goto err_out_destroy;
+	}
+
+	return 0;
+
+err_out_destroy:
+	sock_release(sock);
+err_out_exit:
+
+	dprintk("%s: n: %p, err: %d.\n", __func__, n, err);
+	return err;
+}
+
+/*
+ * This function inserts node into storage.
+ */
+static int dst_insert_node(struct dst_node *n)
+{
+	int err;
+	struct dst_storage *st = n->st;
+	struct dst_node *dn;
+
+	err = st->alg->ops->add_node(n);
+	if (err)
+		goto err_out_exit;
+
+	err = dst_node_sysfs_init(n);
+	if (err)
+		goto err_out_remove_node;
+
+	mutex_lock(&st->tree_lock);
+	dn = dst_storage_tree_add(n, st);
+	if (dn) {
+		err = -EINVAL;
+		dn->size = st->disk_size;
+		if (dn->start == n->start) {
+			err = 0;
+			n->shared_head = dst_node_get(dn);
+			atomic_inc(&dn->shared_num);
+			list_add_tail(&n->shared, &dn->shared);
+		}
+	}
+	mutex_unlock(&st->tree_lock);
+	if (err)
+		goto err_out_sysfs_exit;
+
+	if (n->priv_callback)
+		n->priv_callback(n);
+
+	return 0;
+
+err_out_sysfs_exit:
+	dst_node_sysfs_exit(n);
+err_out_remove_node:
+	st->alg->ops->del_node(n);
+err_out_exit:
+	return err;
+}
+
+static struct dst_node *dst_alloc_node(struct dst_ctl *ctl,
+		void (*cleanup)(struct dst_node *))
+{
+	struct dst_storage *st;
+	struct dst_node *n;
+
+	st = dst_get_storage(ctl->st, ctl->alg, 1);
+	if (!st)
+		goto err_out_exit;
+
+	n = kzalloc(sizeof(struct dst_node), GFP_KERNEL);
+	if (!n)
+		goto err_out_put_storage;
+
+	if (ctl->flags & DST_CTL_USE_CSUM)
+		__set_bit(DST_NODE_USE_CSUM, &n->flags);
+
+	n->w = kst_main_worker;
+	n->st = st;
+	n->cleanup = cleanup;
+	n->start = ctl->start;
+	n->size = ctl->size;
+	INIT_LIST_HEAD(&n->shared);
+	n->shared_head = NULL;
+	atomic_set(&n->shared_num, 0);
+	atomic_set(&n->refcnt, 1);
+
+	return n;
+
+err_out_put_storage:
+	mutex_lock(&dst_storage_lock);
+	list_del_init(&st->entry);
+	mutex_unlock(&dst_storage_lock);
+
+	dst_put_storage(st);
+err_out_exit:
+	return NULL;
+}
+
+/*
+ * Control callback for userspace commands to setup
+ * different nodes and start/stop array.
+ */
+static int dst_add_remote(struct dst_ctl *ctl, void *data, unsigned int len)
+{
+	struct dst_node *n;
+	int err;
+	struct dst_remote_ctl *rctl = data;
+
+	if (len != sizeof(struct dst_remote_ctl))
+		return -EINVAL;
+
+	n = dst_alloc_node(ctl, &dst_cleanup_remote);
+	if (!n)
+		return -ENOMEM;
+
+	err = dst_setup_remote(n, ctl, rctl);
+	if (err < 0)
+		goto err_out_free;
+
+	err = dst_insert_node(n);
+	if (err)
+		goto err_out_cleanup;
+
+	return 0;
+
+err_out_cleanup:
+	if (n->cleanup)
+		n->cleanup(n);
+err_out_free:
+	dst_put_storage(n->st);
+	kfree(n);
+	return err;
+}
+
+static int dst_add_local_export(struct dst_ctl *ctl, void *data, unsigned int len)
+{
+	struct dst_node *n;
+	int err;
+	struct dst_le_template tmp;
+
+	if (len < sizeof(struct dst_local_export_ctl))
+		return -EINVAL;
+
+	tmp.le = data;
+
+	len -= sizeof(struct dst_local_export_ctl);
+	data += sizeof(struct dst_local_export_ctl);
+
+	if (len != tmp.le->secure_attr_num * sizeof(struct dst_secure_user))
+		return -EINVAL;
+
+	tmp.data = data;
+
+	n = dst_alloc_node(ctl, &dst_cleanup_local_export);
+	if (!n)
+		return -EINVAL;
+
+	err = dst_setup_local_export(n, ctl, &tmp);
+	if (err < 0)
+		goto err_out_free;
+
+	err = dst_insert_node(n);
+	if (err)
+		goto err_out_cleanup;
+
+	return 0;
+
+err_out_cleanup:
+	if (n->cleanup)
+		n->cleanup(n);
+err_out_free:
+	dst_put_storage(n->st);
+	kfree(n);
+	return err;
+}
+
+static int dst_add_local(struct dst_ctl *ctl, void *data, unsigned int len)
+{
+	struct dst_node *n;
+	int err;
+	struct dst_local_ctl *lctl = data;
+
+	if (len != sizeof(struct dst_local_ctl))
+		return -EINVAL;
+
+	n = dst_alloc_node(ctl, &dst_cleanup_local);
+	if (!n)
+		return -EINVAL;
+
+	err = dst_setup_local(n, ctl, lctl);
+	if (err < 0)
+		goto err_out_free;
+
+	err = dst_insert_node(n);
+	if (err)
+		goto err_out_cleanup;
+
+	return 0;
+
+err_out_cleanup:
+	if (n->cleanup)
+		n->cleanup(n);
+err_out_free:
+	dst_put_storage(n->st);
+	kfree(n);
+	return err;
+}
+
+static int dst_del_node(struct dst_ctl *ctl, void *data, unsigned int len)
+{
+	struct dst_node *n;
+	struct dst_storage *st;
+	int err = -ENODEV;
+
+	if (len)
+		return -EINVAL;
+
+	st = dst_get_storage(ctl->st, ctl->alg, 0);
+	if (!st)
+		goto err_out_exit;
+
+	mutex_lock(&st->tree_lock);
+	n = dst_storage_tree_del(st, ctl->start);
+	mutex_unlock(&st->tree_lock);
+	if (!n)
+		goto err_out_put;
+
+	dst_node_put(n);
+	dst_put_storage(st);
+
+	return 0;
+
+err_out_put:
+	dst_put_storage(st);
+err_out_exit:
+	return err;
+}
+
+static int dst_start_storage(struct dst_ctl *ctl, void *data, unsigned int len)
+{
+	struct dst_storage *st;
+	int err = -ENXIO;
+
+	if (len)
+		return -EINVAL;
+
+	st = dst_get_storage(ctl->st, ctl->alg, 0);
+	if (!st)
+		return -ENODEV;
+
+	mutex_lock(&st->tree_lock);
+	if (!(st->flags & DST_ST_STARTED) && st->disk_size) {
+		set_capacity(st->disk, st->disk_size);
+		add_disk(st->disk);
+		st->flags |= DST_ST_STARTED;
+		dprintk("%s: STARTED name: '%s', st: %p, disk_size: %llu.\n",
+				__func__, st->name, st, st->disk_size);
+		err = 0;
+	}
+	mutex_unlock(&st->tree_lock);
+
+	dst_put_storage(st);
+
+	return err;
+}
+
+static int dst_stop_storage(struct dst_ctl *ctl, void *data, unsigned int len)
+{
+	struct dst_storage *st;
+
+	if (len)
+		return -EINVAL;
+
+	st = dst_get_storage(ctl->st, ctl->alg, 0);
+	if (!st)
+		return -ENODEV;
+
+	dprintk("%s: STOPPED storage: %s.\n", __func__, st->name);
+
+	dst_storage_sysfs_exit(st);
+
+	mutex_lock(&dst_storage_lock);
+	list_del_init(&st->entry);
+	mutex_unlock(&dst_storage_lock);
+
+	if (st->flags & DST_ST_STARTED)
+		dst_remove_disk(st);
+
+	dst_remove_all_nodes(st);
+	dst_put_storage(st); /* One reference got above */
+	dst_put_storage(st); /* Another reference set during initialization */
+
+	return 0;
+}
+
+typedef int (*dst_command_func)(struct dst_ctl *ctl, void *data, unsigned int len);
+
+/*
+ * List of userspace commands.
+ */
+static dst_command_func dst_commands[] = {
+	[DST_ADD_REMOTE] = &dst_add_remote,
+	[DST_ADD_LOCAL] = &dst_add_local,
+	[DST_ADD_LOCAL_EXPORT] = &dst_add_local_export,
+	[DST_DEL_NODE] = &dst_del_node,
+	[DST_START_STORAGE] = &dst_start_storage,
+	[DST_STOP_STORAGE] = &dst_stop_storage,
+};
+
+/*
+ * Configuration parser.
+ */
+static void cn_dst_callback(void *data)
+{
+	struct dst_ctl *ctl;
+	struct cn_msg *msg = data;
+
+	if (msg->len < sizeof(struct dst_ctl))
+		return;
+
+	ctl = (struct dst_ctl *)msg->data;
+
+	if (ctl->cmd >= DST_CMD_MAX)
+		return;
+
+	dst_commands[ctl->cmd](ctl, msg->data + sizeof(struct dst_ctl),
+			msg->len - sizeof(struct dst_ctl));
+}
+
+static int dst_sysfs_init(void)
+{
+	return bus_register(&dst_dev_bus_type);
+}
+
+static void dst_sysfs_exit(void)
+{
+	bus_unregister(&dst_dev_bus_type);
+}
+
+static int __init dst_sys_init(void)
+{
+	int err = -ENOMEM;
+
+	dst_request_cache = kmem_cache_create("dst", sizeof(struct dst_request),
+				       0, 0, NULL, NULL);
+	if (!dst_request_cache)
+		return -ENOMEM;
+
+	dst_bio_set = bioset_create(32, 32);
+	if (!dst_bio_set)
+		goto err_out_destroy;
+
+	err = register_blkdev(dst_major, DST_NAME);
+	if (err < 0)
+		goto err_out_destroy_bioset;
+	if (err)
+		dst_major = err;
+
+	err = dst_sysfs_init();
+	if (err)
+		goto err_out_unregister;
+
+	kst_main_worker = kst_worker_init(0);
+	if (IS_ERR(kst_main_worker)) {
+		err = PTR_ERR(kst_main_worker);
+		goto err_out_sysfs_exit;
+	}
+
+	err = cn_add_callback(&cn_dst_id, "DST", cn_dst_callback);
+	if (err)
+		goto err_out_worker_exit;
+
+	printk(KERN_INFO "Distributed storage, '%s' release.\n", dst_name);
+
+	return 0;
+
+err_out_worker_exit:
+	kst_worker_exit(kst_main_worker);
+err_out_sysfs_exit:
+	dst_sysfs_exit();
+err_out_unregister:
+	unregister_blkdev(dst_major, DST_NAME);
+err_out_destroy_bioset:
+	bioset_free(dst_bio_set);
+err_out_destroy:
+	kmem_cache_destroy(dst_request_cache);
+	return err;
+}
+
+static void __exit dst_sys_exit(void)
+{
+	cn_del_callback(&cn_dst_id);
+	dst_sysfs_exit();
+	unregister_blkdev(dst_major, DST_NAME);
+	kst_exit_all();
+	bioset_free(dst_bio_set);
+	kmem_cache_destroy(dst_request_cache);
+}
+
+module_init(dst_sys_init);
+module_exit(dst_sys_exit);
+
+MODULE_DESCRIPTION("Distributed storage");
+MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
+MODULE_LICENSE("GPL");

-- 
	Evgeniy Polyakov
