From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [3/3] Distributed storage. Documentation and algorithms.
Date: Thu, 18 Oct 2007 23:18:03 +0400
Message-ID: <20071018191803.GD848@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47688 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763039AbXJRTSv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 15:18:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/Documentation/dst/algorithms.txt b/Documentation/dst/algorithms.txt
new file mode 100644
index 0000000..1437a6a
--- /dev/null
+++ b/Documentation/dst/algorithms.txt
@@ -0,0 +1,115 @@
+Each storage by itself is just a set of contiguous logical blocks, with
+allowed number of operations. Nodes, each of which has own start and size,
+are placed into storage by appropriate algorithm, which remaps
+logical sector number into real node's sector. One can create
+own algorithms, since DST has pluggable interface for that.
+Currently mirrored and linear algorithms are supported.
+
+Let's briefly describe how they work.
+
+Linear algorithm.
+Simple approach of concatenating storages into single device with
+increased size is used in this algorithm. Essentially new device
+has size equal to sum of sizes of underlying nodes and nodes are
+placed one after another.
+
+  /----- Node 1 ---\                         /------ Node 3 ----\
+start              end                     start               end
+ |==================|========================|==================|
+ |                start                     end                 |
+ |                  \------- Node 2 ---------/                  |
+ |                                                              |
+start                                                          end
+ \-------------------------- DST storage ----------------------/
+
+			        /\
+			        ||
+			        ||
+
+			   IO operations
+
+			    Figure 1. 
+     3 nodes combined into single storage using linear algorithm.
+
+Mirror algorithm.
+In this algorithms nodes are placed under each other, so when
+operation comes to the first one, it can be mirrored to all
+underlying nodes. In case of reading, actual data is obtained from
+the nearest node - algoritm keeps track of previous operation
+and knows where it was stopped, so that subsequent seek to the 
+start of the new request will take the shortest time.
+Writing is always mirrored to all underlying nodes.
+
+                  IO operations
+                       ||
+                       ||
+                       \/
+
+|---------------- DST storage -------------------|
+|      prev position                             |
+|-------|------------ Node 1 --------------------|
+|                              prev pos          |
+|-------------------- Node 2 -----|--------------|
+|prev pos                                        |
+|---|---------------- Node 3 --------------------|
+
+		Figure 2.
+   3 nodes combined into single storage using mirror algorithm.
+
+Each algorithm must implement number of callbacks,
+which must be registered during initialization time.
+
+struct dst_alg_ops
+{
+	int			(*add_node)(struct dst_node *n);
+	void			(*del_node)(struct dst_node *n);
+	int 			(*remap)(struct dst_request *req);
+	int			(*error)(struct kst_state *state, int err);
+	struct module 		*owner;
+};
+
+@add_node.
+This callback is invoked when new node is being added into the storage,
+but before node is actually added into the storage, so that it could
+be accessed from it. When it is called, all appropriate initialization
+of the underlying device is already completed (system has been connected
+to remote node or got a reference to the local block device). At this
+stage algorithm can add node into private map. 
+It must return zero on success or negative value otherwise.
+
+@del_node.
+This callback is invoked when node is being deleted from the storage,
+i.e. when its reference counter hits zero. It is called before
+any cleaning is performed.
+It must return zero on success or negative value otherwise.
+
+@remap.
+This callback is invoked each time new bio hits the storage.
+Request structure contains BIO itself, pointer to the node, which originally
+stores the whole region under given IO request, and various parameters
+used by storage core to process this block request.
+It must return zero on success or negative value otherwise. It is upto
+this method to call all cleaning if remapping failed, for example it must
+call kst_bio_endio() for given callback in case of error, which in turn
+will call bio_endio(). Note, that dst_request structure provided in this
+callback is allocated on stack, so if there is a need to use it outside
+of the given function, it must be cloned (it will happen automatically
+in state's push callback, but that copy will not be shared by any other
+user).
+
+@error.
+This callback is invoked for each error, which happend when processed
+requests for remote nodes or when talking to remote size
+of the local export node (state contains data related to data
+transfers over the network).
+If this function has fixed given error, it must return 0 or negative
+error value otherwise.
+
+@owner.
+This is module reference counter updated automatically by DST core.
+
+Algorithm must provide its name and above structure to the 
+dst_alloc_alg() function, which will return a reference to the newly
+created algorithm.
+To remove it, one needs to call dst_remove_alg() with given algorithm
+pointer.
diff --git a/Documentation/dst/dst.txt b/Documentation/dst/dst.txt
new file mode 100644
index 0000000..3b326aa
--- /dev/null
+++ b/Documentation/dst/dst.txt
@@ -0,0 +1,66 @@
+Distributed storage. Design and implementation.
+http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst
+
+	     Evgeniy Polyakov
+
+This document is intended to briefly describe design and
+implementation details of the distributed storage project,
+aimed to create ability to group physically and/or logically
+distributed storages into single device.
+
+Main operational unit in the storage is node. Node can represent
+either remote storage, connected to local machine, or local
+device, or storage exported to the outside of the system.
+Here goes small explaination of basic therms.
+
+Local node.
+This node is just a logical link between block device (with given
+major and minor numbers) and structure in the DST hierarchy,
+which represents number of sectors on the area, corresponding to given
+block device. it can be a disk, a device mapper node or stacked
+block device on top of another underlying DST nodes.
+
+Local export node.
+Essentially the same as local node, but it allows to access
+to its data via network. Remote clients can connect to given local 
+export node and read or write blocks according to its size.
+Blocks are then forwarded to underlying local node and processed
+there accordingly to the nature of the local node.
+
+Remote node.
+This type of nodes contain remotely accessible devices. One can think
+about remote nodes as remote disks, which can be connected to
+local system and combined into single storage. Remote nodes
+are presented as number of sectors accessed over the network
+by the local machine, where distributed storage is being formed.
+
+
+Each node or set of them can be formed into single array, which
+in turn becomes a local node, which can be exported further by stacking
+a local export node on top of it.
+
+Each storage by itself is just a set of contiguous logical blocks, with
+allowed number of operations. Nodes, each of which has own start and size,
+are placed into storage by appropriate algorithm, which remaps
+logical sector number into real node's sector. One can create
+own algorithms, since DST has pluggable interface for that.
+Currently mirrored and linear algorithms are supported.
+One can find more details in Documentation/dst/algorithms.txt file.
+
+Main goal of the distributed storage is to combine remote nodes into
+single device, so each block IO request is being sent over the network
+(contrary requests for local nodes are handled by the gneric block
+layer features). Each network connection has number of variables which
+describe it (socket, list of requests, error handling and so on),
+which form kst_state structure. This network state is added into per-socket
+polling state machine, and can be processed by dedicated thread when
+becomes ready. This system forms asynchronous IO for given block
+requests. If block request can be processed without blocking, then
+no new structures are allocated and async part of the state is not used.
+
+When connection to the remote peer breaks, DST core tries to reconnect
+to failed node and no requests are marked as errorneous, instead
+they live in the queue until reconnectin is established.
+
+Userspace code, setup documentation and examples can be found on project's
+homepage above.
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

diff --git a/drivers/block/dst/alg_linear.c b/drivers/block/dst/alg_linear.c
new file mode 100644
index 0000000..584f99e
--- /dev/null
+++ b/drivers/block/dst/alg_linear.c
@@ -0,0 +1,99 @@
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
+
+	n->start = st->disk_size;
+	st->disk_size += n->size;
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
index 0000000..9d14edb
--- /dev/null
+++ b/drivers/block/dst/alg_mirror.c
@@ -0,0 +1,993 @@
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
+
+#define DST_DEBUG
+#include <linux/dst.h>
+
+struct dst_mirror_node_data
+{
+	u64		age;
+};
+
+struct dst_mirror_priv
+{
+	unsigned int		chunk_num;
+
+	u64			last_start;
+
+	spinlock_t		backlog_lock;
+	struct list_head	backlog_list;
+
+	struct dst_mirror_node_data	old_data, new_data;
+
+	unsigned long		*chunk;
+};
+
+static struct dst_alg *alg_mirror;
+static struct bio_set *dst_mirror_bio_set;
+
+static ssize_t dst_mirror_chunk_mask_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct dst_node *n = container_of(dev, struct dst_node, device);
+	struct dst_mirror_priv *priv = n->priv;
+	unsigned int i;
+	int rest = PAGE_SIZE;
+
+	for (i = 0; i < priv->chunk_num/BITS_PER_LONG; ++i) {
+		int bit, j;
+
+		for (j = 0; j < BITS_PER_LONG; ++j) {
+			bit = (priv->chunk[i] >> j) & 1;
+			sprintf(buf, "%c", (bit)?'+':'-');
+			buf++;
+		}
+
+		rest -= BITS_PER_LONG;
+
+		if (rest < BITS_PER_LONG)
+			break;
+	}
+
+	return PAGE_SIZE - rest;
+}
+
+static DEVICE_ATTR(chunks, 0444, dst_mirror_chunk_mask_show, NULL);
+
+/*
+ * This callback is invoked when node is removed from storage.
+ */
+static void dst_mirror_del_node(struct dst_node *n)
+{
+	struct dst_mirror_priv *priv = n->priv;
+
+	if (priv) {
+		vfree(priv->chunk);
+		kfree(priv);
+		n->priv = NULL;
+	}
+
+	if (n->device.parent == &n->st->device)
+		device_remove_file(&n->device, &dev_attr_chunks);
+}
+
+static void dst_mirror_handle_priv(struct dst_node *n)
+{
+	if (n->priv) {
+		int err;
+		err = device_create_file(&n->device, &dev_attr_chunks);
+	}
+}
+
+static void dst_mirror_destructor(struct bio *bio)
+{
+	dprintk("%s: bio: %p.\n", __func__, bio);
+	bio_free(bio, dst_mirror_bio_set);
+}
+
+/*
+ * This function copies node's private on-disk data from first node
+ * to the new one.
+ */
+static int dst_mirror_get_node_data(struct dst_node *n,
+		struct dst_mirror_node_data *ndata, int old)
+{
+	struct dst_node *first;
+	struct dst_mirror_priv *p;
+
+	mutex_lock(&n->st->tree_lock);
+	first = dst_storage_tree_search(n->st, n->start);
+	mutex_unlock(&n->st->tree_lock);
+	if (!first) {
+		dprintk("%s: there are no nodes in the storage.\n", __func__);
+		return -ENODEV;
+	}
+
+	p = first->priv;
+	memcpy(ndata, (old)?&p->old_data:&p->new_data, sizeof(struct dst_mirror_node_data));
+
+	dst_node_put(first);
+	return 0;
+}
+
+struct dst_mirror_ndp
+{
+	u8			sector[512];
+	struct completion	complete;
+};
+
+static void dst_mirror_ndp_bio_endio(struct dst_request *req, int err)
+{
+	struct dst_mirror_ndp *cmp = req->bio->bi_private;
+
+	dprintk("%s: completing request: bio: %p, cmp: %p.\n",
+			__func__, req->bio, cmp);
+	complete(&cmp->complete);
+}
+
+static int dst_mirror_ndp_end_io(struct bio *bio, unsigned int size, int err)
+{
+	struct dst_mirror_ndp *cmp = bio->bi_private;
+
+	if (bio->bi_size)
+		return 0;
+
+	dprintk("%s: completing request: bio: %p, cmp: %p.\n", __func__, bio, cmp);
+	complete(&cmp->complete);
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
+
+	cmp = kzalloc(sizeof(struct dst_mirror_ndp), GFP_KERNEL);
+	if (!cmp)
+		goto err_out_exit;
+
+	init_completion(&cmp->complete);
+
+	if (op == WRITE)
+		memcpy(cmp->sector, ndata, sizeof(struct dst_mirror_node_data));
+
+	bio = bio_alloc_bioset(GFP_NOIO, 1, dst_mirror_bio_set);
+	if (!bio)
+		goto err_out_free_page;
+
+	bio->bi_rw = op;
+	bio->bi_private = cmp;
+	bio->bi_sector = n->size;
+	bio->bi_bdev = n->bdev;
+	bio->bi_destructor = dst_mirror_destructor;
+	bio->bi_end_io = dst_mirror_ndp_end_io;
+
+	err = bio_add_pc_page(n->st->queue, bio,
+			virt_to_page(cmp->sector), sizeof(cmp->sector),
+			offset_in_page(cmp->sector));
+	if (err <= 0)
+		goto err_out_free_bio;
+
+	if (n->bdev) {
+		generic_make_request(bio);
+	} else {
+		struct dst_request req;
+
+		req.node = n;
+		req.state = n->state;
+		req.start = bio->bi_sector;
+		req.size = req.orig_size = bio->bi_size;
+		req.bio = bio;
+		req.idx = bio->bi_idx;
+		req.num = bio->bi_vcnt;
+		req.flags = 0;
+		req.offset = 0;
+		req.bio_endio = &dst_mirror_ndp_bio_endio;
+		req.callback = &kst_data_callback;
+	
+		err = req.state->ops->push(&req);
+		if (err) {
+			dprintk("%s: failed to push request: err: %d.\n", __func__, err);
+			goto err_out_free_bio;
+		}
+	}
+
+	dprintk("%s: waiting for completion: bio: %p, cmp: %p.\n", __func__, bio, cmp);
+
+	wait_for_completion(&cmp->complete);
+
+	if (op == READ)
+		memcpy(ndata, cmp->sector, sizeof(struct dst_mirror_node_data));
+
+	err = 0;
+
+err_out_free_bio:
+	bio_put(bio);
+err_out_free_page:
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
+	return dst_mirror_process_node_data(n, ndata, WRITE);
+}
+
+static int dst_mirror_ndp_setup(struct dst_node *n, int first_node, int clean_on_sync)
+{
+	struct dst_mirror_priv *p = n->priv;
+	int sync = 1, err;
+
+	err = dst_mirror_read_node_data(n, &p->old_data);
+	if (err)
+		return err;
+
+	if (first_node) {
+		p->new_data.age = (u64)n->st;
+
+		dprintk("%s: first age: %llx -> %llx.\n",
+				__func__, p->old_data.age, p->new_data.age);
+
+		err = dst_mirror_write_node_data(n, &p->new_data);
+		if (err)
+			return err;
+	} else {
+		err = dst_mirror_get_node_data(n, &p->new_data, 1);
+		if (err)
+			return err;
+
+		if (p->new_data.age != p->old_data.age) {
+			sync = 0;
+			dprintk("%s: node %llu:%llu is not synced with the first "
+					"node (old != new): %llx != %llx.\n",
+					__func__, n->start, n->start+n->size,
+					p->old_data.age, p->new_data.age);
+		} else {
+			err = dst_mirror_get_node_data(n, &p->new_data, 0);
+			if (err)
+				return err;
+			
+			dprintk("%s: node %llu:%llu is in sync with the first node.\n",
+					__func__, n->start, n->start+n->size);
+		}
+	}
+
+	if (!sync)
+		memset(p->chunk, 0xff, p->chunk_num/BITS_PER_LONG * sizeof(long));
+	else if (clean_on_sync)
+		memset(p->chunk, 0, p->chunk_num/BITS_PER_LONG * sizeof(long));
+
+	dprintk("%s: age: old: %llx, new: %llx.\n", __func__, p->old_data.age, p->new_data.age);
+
+	return 0;
+}
+
+/*
+ * This callback is invoked when node is added to storage.
+ */
+static int dst_mirror_add_node(struct dst_node *n)
+{
+	struct dst_storage *st = n->st;
+	struct dst_mirror_priv *priv;
+	int err, first_node = 0;
+
+	n->size -= 512; /* A sector size actually. */
+
+	n->size = ALIGN(n->size, 512);
+
+	mutex_lock(&st->tree_lock);
+	if (st->disk_size) {
+		st->disk_size = min(n->size, st->disk_size);
+	} else {
+		st->disk_size = n->size;
+		first_node = 1;
+	}
+	mutex_unlock(&st->tree_lock);
+
+	priv = kzalloc(sizeof(struct dst_mirror_priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	priv->chunk_num = st->disk_size;
+
+	priv->chunk = vmalloc(priv->chunk_num/BITS_PER_LONG * sizeof(long));
+	if (!priv->chunk)
+		goto err_out_free;
+
+	spin_lock_init(&priv->backlog_lock);
+	INIT_LIST_HEAD(&priv->backlog_list);
+
+	dprintk("%s: %llu:%llu, chunk_num: %u, disk_size: %llu.\n\n",
+			__func__, n->start, n->size,
+			priv->chunk_num, st->disk_size);
+
+	n->priv_callback = &dst_mirror_handle_priv;
+	n->priv = priv;
+
+	err = dst_mirror_ndp_setup(n, first_node, 1);
+	if (err)
+		goto err_out_free_chunk;
+
+	return 0;
+
+err_out_free_chunk:
+	vfree(priv->chunk);
+err_out_free:
+	kfree(priv);
+	return -ENOMEM;
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
+static void dst_mirror_sync_requeue(struct dst_node *n)
+{
+	struct dst_mirror_priv *p = n->priv;
+	struct dst_request *req;
+	unsigned int num, idx, i;
+	u64 start;
+	unsigned long flags;
+	int err;
+
+	while (!list_empty(&p->backlog_list)) {
+		req = NULL;
+		spin_lock_irqsave(&p->backlog_lock, flags);
+		if (!list_empty(&p->backlog_list)) {
+			req = list_entry(p->backlog_list.next,
+					struct dst_request,
+					request_list_entry);
+			list_del(&req->request_list_entry);
+		}
+		spin_unlock_irqrestore(&p->backlog_lock, flags);
+
+		if (!req)
+			break;
+
+		start = req->start - to_sector(req->orig_size - req->size);
+
+		idx = start;
+		num = to_sector(req->orig_size);
+
+		for (i=0; i<num; ++i)
+			if (test_bit(idx+i, p->chunk))
+				break;
+
+		dprintk("%s: idx: %u, num: %u, i: %u, req: %p, "
+				"start: %llu, size: %llu.\n",
+				__func__, idx, num, i, req, 
+				req->start, req->orig_size);
+
+		err = -1;
+		if (i != num) {
+			err = kst_enqueue_req(n->state, req);
+			if (err) {
+				dprintk("%s: congestion [%c]: req: %p, "
+						"start: %llu, size: %llu.\n",
+					__func__,
+					(bio_rw(req->bio) == WRITE)?'W':'R',
+					req, req->start, req->size);
+				kst_del_req(req);
+			}
+		}
+		if (err) {
+			req->bio_endio(req, err);
+			dst_free_request(req);
+		}
+	}
+
+	kst_wake(n->state);
+}
+
+static void dst_mirror_mark_sync(struct dst_node *n)
+{
+	if (test_bit(DST_NODE_NOTSYNC, &n->flags)) {
+		struct dst_mirror_priv *priv = n->priv;
+
+		clear_bit(DST_NODE_NOTSYNC, &n->flags);
+		dprintk("%s: node: %p, %llu:%llu synchronization "
+				"has been completed.\n",
+			__func__, n, n->start, n->size);
+		dst_mirror_write_node_data(n, &priv->new_data);
+	}
+}
+
+static void dst_mirror_mark_notsync(struct dst_node *n)
+{
+	if (!test_bit(DST_NODE_NOTSYNC, &n->flags)) {
+		set_bit(DST_NODE_NOTSYNC, &n->flags);
+		dprintk("%s: not synced node n: %p.\n", __func__, n);
+	}
+}
+
+/*
+ * Without errors it is always called under node's request lock,
+ * so it is safe to requeue them.
+ */
+static void dst_mirror_bio_error(struct dst_request *req, int err)
+{
+	int i;
+	struct dst_mirror_priv *priv = req->node->priv;
+	unsigned int num, idx;
+	void (*process_bit[])(int nr, volatile void *addr) =
+		{&__clear_bit, &__set_bit};
+	u64 start = req->start - to_sector(req->orig_size - req->size);
+
+	if (err)
+		dst_mirror_mark_notsync(req->node);
+	else
+		dst_mirror_sync_requeue(req->node);
+
+	priv->last_start = req->start;
+
+	idx = start;
+	num = to_sector(req->orig_size);
+
+	dprintk("%s: req_priv: %p, chunk %p, %llu:%llu start: %llu, size: %llu, "
+		"chunk_num: %u, idx: %d, num: %d, err: %d.\n",
+		__func__, req->priv, priv->chunk, req->node->start, 
+		req->node->size, start, req->orig_size, priv->chunk_num, 
+		idx, num, err);
+
+	if (unlikely(idx >= priv->chunk_num || idx + num > priv->chunk_num)) {
+		dprintk("%s: %llu:%llu req: %p, start: %llu, orig_size: %llu, "
+			"req_start: %llu, req_size: %llu, "
+			"chunk_num: %u, idx: %d, num: %d, err: %d.\n",
+			__func__, req->node->start, req->node->size, req,
+			start, req->orig_size, 
+			req->start, req->size,
+			priv->chunk_num, idx, num, err);
+		return;
+	}
+
+	for (i=0; i<num; ++i)
+		process_bit[!!err](idx+i, priv->chunk);
+}
+
+static void dst_mirror_sync_req_endio(struct dst_request *req, int err)
+{
+	unsigned long notsync = 0;
+	struct dst_mirror_priv *priv = req->node->priv;
+	int i;
+
+	dst_mirror_bio_error(req, err);
+
+	dprintk("%s: freeing bio: %p, bi_size: %u, "
+			"orig_size: %llu, req: %p, node: %p.\n",
+		__func__, req->bio, req->bio->bi_size, req->orig_size, req,
+		req->node);
+
+	bio_put(req->bio);
+
+	for (i = 0; i < priv->chunk_num/BITS_PER_LONG; ++i) {
+		notsync = priv->chunk[i];
+
+		if (notsync)
+			break;
+	}
+
+	if (!notsync)
+		dst_mirror_mark_sync(req->node);
+}
+
+static int dst_mirror_sync_endio(struct bio *bio, unsigned int size, int err)
+{
+	struct dst_request *req = bio->bi_private;
+	struct dst_node *n = req->node;
+	struct dst_mirror_priv *priv = n->priv;
+	unsigned long flags;
+
+	dprintk("%s: bio: %p, err: %d, size: %u, req: %p.\n",
+			__func__, bio, err, bio->bi_size, req);
+
+	if (bio->bi_size)
+		return 1;
+
+	bio->bi_rw = WRITE;
+	bio->bi_size = req->orig_size;
+	bio->bi_sector = req->start;
+
+	if (!err) {
+		spin_lock_irqsave(&priv->backlog_lock, flags);
+		list_add_tail(&req->request_list_entry, &priv->backlog_list);
+		spin_unlock_irqrestore(&priv->backlog_lock, flags);
+		kst_wake(req->state);
+	} else {
+		req->bio_endio(req, err);
+		dst_free_request(req);
+	}
+	return 0;
+}
+
+static int dst_mirror_sync_block(struct dst_node *n,
+		int bit_start, int bit_num)
+{
+	u64 start = to_bytes(bit_start);
+	struct bio *bio;
+	unsigned int nr_pages = to_bytes(bit_num)/PAGE_SIZE, i;
+	struct page *page;
+	int err = -ENOMEM;
+	struct dst_request *req;
+
+	dprintk("%s: bit_start: %d, bit_num: %d, start: %llu, nr_pages: %u, "
+			"disk_size: %llu.\n",
+			__func__, bit_start, bit_num, start, nr_pages,
+			n->st->disk_size);
+
+	while (nr_pages) {
+		req = dst_clone_request(NULL, n->w->req_pool);
+		if (!req)
+			return -ENOMEM;
+
+		bio = bio_alloc_bioset(GFP_NOIO, nr_pages, dst_mirror_bio_set);
+		if (!bio)
+			goto err_out_free_req;
+
+		bio->bi_rw = READ;
+		bio->bi_private = req;
+		bio->bi_sector = to_sector(start);
+		bio->bi_bdev = NULL;
+		bio->bi_destructor = dst_mirror_sync_destructor;
+		bio->bi_end_io = dst_mirror_sync_endio;
+
+		for (i = 0; i < nr_pages; ++i) {
+			err = -ENOMEM;
+
+			page = alloc_page(GFP_NOIO);
+			if (!page)
+				break;
+
+			err = bio_add_pc_page(n->st->queue, bio,
+					page, PAGE_SIZE, 0);
+			if (err <= 0)
+				break;
+			err = 0;
+		}
+
+		if (err && !bio->bi_vcnt)
+			goto err_out_put_bio;
+
+		req->node = n;
+		req->state = n->state;
+		req->start = bio->bi_sector;
+		req->size = req->orig_size = bio->bi_size;
+		req->bio = bio;
+		req->idx = bio->bi_idx;
+		req->num = bio->bi_vcnt;
+		req->flags = 0;
+		req->offset = 0;
+		req->bio_endio = &dst_mirror_sync_req_endio;
+		req->callback = &kst_data_callback;
+
+		dprintk("%s: start: %llu, size(pages): %u, bio: %p, "
+				"size: %u, cnt: %d, req: %p, size: %llu.\n",
+				__func__, bio->bi_sector, nr_pages, bio,
+				bio->bi_size, bio->bi_vcnt, req, req->size);
+
+		err = n->st->queue->make_request_fn(n->st->queue, bio);
+		if (err)
+			goto err_out_put_bio;
+
+		nr_pages -= bio->bi_vcnt;
+		start += bio->bi_size;
+	}
+
+	return 0;
+
+err_out_put_bio:
+	bio_put(bio);
+err_out_free_req:
+	dst_free_request(req);
+	return err;
+}
+
+/*
+ * Resync logic.
+ *
+ * System allocates and queues requests for number of regions.
+ * Each request initially is reading from the one of the nodes.
+ * When it is completed, system checks if given region was already
+ * written to, and in such case just drops read request, otherwise
+ * it writes it to the node being updated. Any write clears not-uptodate
+ * bit, which is used as a flag that region must be synchronized or not.
+ * Reading is never performed from the node under resync.
+ */
+static int dst_mirror_resync(struct dst_node *n)
+{
+	int err = 0, sync = 0;
+	struct dst_mirror_priv *priv = n->priv;
+	unsigned int i;
+
+	dprintk("%s: node: %p, %llu:%llu synchronization has been started.\n",
+			__func__, n, n->start, n->size);
+
+	err = dst_mirror_ndp_setup(n, 0, 0);
+	if (err)
+		return err;
+
+	for (i = 0; i < priv->chunk_num/BITS_PER_LONG; ++i) {
+		int bit, num, start;
+		unsigned long word = priv->chunk[i];
+
+		if (!word)
+			continue;
+
+		num = 0;
+		start = -1;
+		while (word && num < BITS_PER_LONG) {
+			bit = __ffs(word);
+			if (start == -1)
+				start = bit;
+			num++;
+			word >>= (bit+1);
+		}
+
+		if (start != -1) {
+			err = dst_mirror_sync_block(n, start + i*BITS_PER_LONG,
+					num);
+			if (err)
+				break;
+			sync++;
+		}
+	}
+
+	if (!sync && !err)
+		dst_mirror_mark_sync(n);
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
+static void dst_mirror_read_endio(struct dst_request *req, int err)
+{
+	dst_mirror_bio_error(req, err);
+
+	if (!err)
+		kst_bio_endio(req, 0);
+}
+
+static void dst_mirror_write_endio(struct dst_request *req, int err)
+{
+	dst_mirror_bio_error(req, err);
+
+	req = req->priv;
+
+	dprintk("%s: req: %p, priv: %p err: %d, bio: %p, "
+			"cnt: %d, orig_size: %llu.\n",
+		__func__, req, req->priv, err, req->bio,
+		atomic_read(&req->refcnt), req->orig_size);
+
+	if (atomic_dec_and_test(&req->refcnt)) {
+		dprintk("%s: freeing bio %p.\n", __func__, req->bio);
+		bio_endio(req->bio, req->orig_size, 0);
+		dst_free_request(req);
+	}
+}
+
+static int dst_mirror_process_request(struct dst_request *req,
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
+	return err;
+}
+
+static int dst_mirror_write(struct dst_request *oreq)
+{
+	struct dst_node *n, *node = oreq->node;
+	struct dst_request *req;
+	int num, err = 0, err_num = 0, orig_num;
+
+	req = dst_clone_request(oreq, oreq->node->w->req_pool);
+	if (!req) {
+		kst_bio_endio(oreq, -ENOMEM);
+		return -ENOMEM;
+	}
+
+	req->priv = req;
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
+	req->bio_endio = &dst_mirror_write_endio;
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
+	if (err_num == orig_num) {
+		dprintk("%s: req: %p, num: %d, err: %d.\n",
+				__func__, req, num, err);
+		return -ENODEV;
+	}
+
+	return 0;
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
+		 * If this will cause any troubles (like all nodes must be
+		 * resynced between each other), this check can be removed
+		 * and per-chunk dirty bit can be tested instead.
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
+			dprintk("%s: 1 req: %p, bio: %p, node: %p, err: %d.\n",
+				__func__, req, req->bio, min_dist_node, err);
+			dst_mirror_mark_notsync(req->node);
+		}
+	} while (err && min_dist_node);
+
+	if (err) {
+		dprintk("%s: req: %p, bio: %p, node: %p, err: %d.\n",
+			__func__, req, req->bio, min_dist_node, err);
+		kst_bio_endio(req, err);
+	}
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
+static int dst_mirror_error(struct kst_state *st, int err)
+{
+	struct dst_request *req, *tmp;
+	unsigned int revents = st->socket->ops->poll(NULL, st->socket, NULL);
+
+	if (err == -EEXIST)
+		return err;
+
+	if (!(revents & (POLLERR | POLLHUP))) {
+		if (test_bit(DST_NODE_NOTSYNC, &st->node->flags)) {
+			return dst_mirror_resync(st->node);
+		}
+		return 0;
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
+		if (bio_rw(req->bio) == READ) {
+			req->start -= to_sector(req->orig_size - req->size);
+			req->size = req->orig_size;
+			req->flags &= ~DST_REQ_HEADER_SENT;
+			req->idx = 0;
+			if (dst_mirror_read(req))
+				kst_complete_req(req, err);
+			else
+				dst_free_request(req);
+		} else {
+			kst_complete_req(req, err);
+		}
+	}
+	mutex_unlock(&st->request_lock);
+	return err;
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


-- 
	Evgeniy Polyakov
