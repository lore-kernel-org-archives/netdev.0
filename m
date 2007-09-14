From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Distributed storage. Move away from char device ioctls.
Date: Fri, 14 Sep 2007 22:54:29 +0400
Message-ID: <20070914185429.GA9439@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51056 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755825AbXINSyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 14:54:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

I'm pleased to announce fourth release of the distributed storage
subsystem, which allows to form a storage on top of remote and local
nodes, which in turn can be exported to another storage as a node to
form tree-like storages.

This release includes new configuration interface (kernel connector over
netlink socket) and number of fixes of various bugs found during move 
to it (in error path).

Further TODO list includes:
* implement optional saving of mirroring/linear information on the remote
	nodes (simple)
* new redundancy algorithm (complex)
* some thoughts about distributed filesystem tightly connected to DST
	(far-far planes so far)

Homepage:
http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/Documentation/dst/algorithms.txt b/Documentation/dst/algorithms.txt
new file mode 100644
index 0000000..bfc6984
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
+|---------------- DST storate -------------------|
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
index 0000000..5bb9de8
--- /dev/null
+++ b/drivers/block/dst/Kconfig
@@ -0,0 +1,20 @@
+config DST
+	tristate "Distributed storage"
+	depends on NET
+	select CONNECTOR
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
index 0000000..190d130
--- /dev/null
+++ b/drivers/block/dst/alg_mirror.c
@@ -0,0 +1,768 @@
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
+
+#define DST_MIRROR_MAX_CHUNKS		4096
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
+/*
+ * This callback is invoked when node is added to storage.
+ */
+static int dst_mirror_add_node(struct dst_node *n)
+{
+	struct dst_storage *st = n->st;
+	struct dst_mirror_priv *priv;
+
+	if (st->disk_size)
+		st->disk_size = min(n->size, st->disk_size);
+	else
+		st->disk_size = n->size;
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
+	memset(priv->chunk, 0, priv->chunk_num/BITS_PER_LONG * sizeof(long));
+
+	spin_lock_init(&priv->backlog_lock);
+	INIT_LIST_HEAD(&priv->backlog_list);
+
+	dprintk("%s: %llu:%llu, chunk_num: %u, disk_size: %llu.\n",
+			__func__, n->start, n->size,
+			priv->chunk_num, st->disk_size);
+
+	n->priv_callback = &dst_mirror_handle_priv;
+	n->priv = priv;
+
+	return 0;
+
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
+				printk("%s: congestion [%c]: req: %p, "
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
+		clear_bit(DST_NODE_NOTSYNC, &n->flags);
+		printk("%s: node: %p, %llu:%llu synchronization "
+				"has been completed.\n",
+			__func__, n, n->start, n->size);
+	}
+}
+
+static void dst_mirror_mark_notsync(struct dst_node *n)
+{
+	if (!test_bit(DST_NODE_NOTSYNC, &n->flags)) {
+		set_bit(DST_NODE_NOTSYNC, &n->flags);
+		printk("%s: not synced node n: %p.\n", __func__, n);
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
+		printk("%s: %llu:%llu req: %p, start: %llu, orig_size: %llu, "
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
+	printk("%s: freeing bio: %p, bi_size: %u, "
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
+	printk("%s: bio: %p, err: %d, size: %u, req: %p.\n",
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
+	printk("%s: bit_start: %d, bit_num: %d, start: %llu, nr_pages: %u, "
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
+	printk("%s: node: %p, %llu:%llu synchronization has been started.\n",
+			__func__, n, n->start, n->size);
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
+static void dst_mirror_destructor(struct bio *bio)
+{
+	dprintk("%s: bio: %p.\n", __func__, bio);
+	bio_free(bio, dst_mirror_bio_set);
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
+			printk("%s: 1 req: %p, bio: %p, node: %p, err: %d.\n",
+				__func__, req, req->bio, min_dist_node, err);
+			dst_mirror_mark_notsync(req->node);
+		}
+	} while (err && min_dist_node);
+
+	if (err) {
+		printk("%s: req: %p, bio: %p, node: %p, err: %d.\n",
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
diff --git a/drivers/block/dst/dcore.c b/drivers/block/dst/dcore.c
new file mode 100644
index 0000000..d6374ff
--- /dev/null
+++ b/drivers/block/dst/dcore.c
@@ -0,0 +1,1527 @@
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
+/*
+ * DST sysfs tree. For device called 'storage' which is formed
+ * on top of two nodes this looks like this:
+ *
+ * /sys/devices/storage/
+ * /sys/devices/storage/alg : alg_linear
+ * /sys/devices/storage/n-800/type : R: 192.168.4.80:1025
+ * /sys/devices/storage/n-800/size : 800
+ * /sys/devices/storage/n-800/start : 800
+ * /sys/devices/storage/n-0/type : R: 192.168.4.81:1025
+ * /sys/devices/storage/n-0/size : 800
+ * /sys/devices/storage/n-0/start : 0
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
+				__func__, bio, bio->bi_sector);
+		return -ENODEV;
+	}
+
+	dprintk("%s: bio: %llu-%llu, dev: %llu-%llu, in sectors.\n",
+			__func__, bio->bi_sector, bio->bi_sector+bio_sectors,
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
+						__func__, bio, bio->bi_sector,
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
+static struct block_device_operations dst_blk_ops = {
+	.owner =	THIS_MODULE,
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
+	mutex_unlock(&dst_storage_lock);
+
+	if (rst || !alloc)
+		return rst;
+
+	st = kzalloc(sizeof(struct dst_storage), GFP_KERNEL);
+	if (!st)
+		return NULL;
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
+	mutex_lock(&dst_storage_lock);
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
+static void dst_free_alg(struct dst_alg *alg)
+{
+	dprintk("%s: alg: %p.\n", __func__, alg);
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
+	dprintk("%s: alg: %p, refcnt: %d.\n",
+			__func__, alg, atomic_read(&alg->refcnt));
+	module_put(alg->ops->owner);
+	if (atomic_dec_and_test(&alg->refcnt))
+		dst_free_alg(alg);
+}
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
+	n->st->alg->ops->del_node(n);
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
+	kfree(n);
+}
+
+static void dst_free_storage(struct dst_storage *st)
+{
+	dprintk("%s: st: %p.\n", __func__, st);
+
+	BUG_ON(rb_first(&st->tree_root) != NULL);
+
+	dst_put_alg(st->alg);
+	kfree(st);
+}
+
+static inline void dst_put_storage(struct dst_storage *st)
+{
+	dprintk("%s: st: %p, refcnt: %d.\n",
+			__func__, st, atomic_read(&st->refcnt));
+	if (atomic_dec_and_test(&st->refcnt))
+		dst_free_storage(st);
+}
+
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
+	if (!n->size)
+		n->size = get_capacity(n->bdev->bd_disk);
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
+	struct msghdr msg;
+	struct kvec iov;
+	int err;
+
+	memset(&cfg, 0, sizeof(struct dst_remote_request));
+	cfg.cmd = cpu_to_be32(DST_REMOTE_CFG);
+
+	iov.iov_base = &cfg;
+	iov.iov_len = sizeof(struct dst_remote_request);
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_WAITALL;
+
+	err = kernel_sendmsg(sock, &msg, &iov, 1, iov.iov_len);
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		return err;
+	}
+
+	iov.iov_base = &cfg;
+	iov.iov_len = sizeof(struct dst_remote_request);
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_WAITALL;
+
+	err = kernel_recvmsg(sock, &msg, &iov, 1, iov.iov_len, msg.msg_flags);
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		return err;
+	}
+
+	if (be32_to_cpu(cfg.cmd) != DST_REMOTE_CFG)
+		return -EINVAL;
+
+	n->size = be64_to_cpu(cfg.sector);
+
+	return 0;
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
+	if (!n->size) {
+		err = dst_request_remote_config(n, sock);
+		if (err)
+			goto err_out_destroy;
+	}
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
+		return err;
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
+		goto err_out_free;
+
+	return 0;
+
+err_out_free:
+	dst_node_put(n);
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
+	if (len != tmp.le->secure_attr_num * sizeof(struct dst_secure))
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
+		goto err_out_free;
+
+
+	return 0;
+
+err_out_free:
+	dst_node_put(n);
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
+		goto err_out_free;
+
+	return 0;
+
+err_out_free:
+	dst_node_put(n);
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
+
+	if (len)
+		return -EINVAL;
+
+	st = dst_get_storage(ctl->st, ctl->alg, 0);
+	if (!st)
+		return -ENODEV;
+
+	mutex_lock(&st->tree_lock);
+	if (!(st->flags & DST_ST_STARTED)) {
+		set_capacity(st->disk, st->disk_size);
+		add_disk(st->disk);
+		st->flags |= DST_ST_STARTED;
+		dprintk("%s: STARTED st: %p, disk_size: %llu.\n",
+				__func__, st, st->disk_size);
+	}
+	mutex_unlock(&st->tree_lock);
+
+	dst_put_storage(st);
+
+	return 0;
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
diff --git a/drivers/block/dst/kst.c b/drivers/block/dst/kst.c
new file mode 100644
index 0000000..b0608c9
--- /dev/null
+++ b/drivers/block/dst/kst.c
@@ -0,0 +1,1606 @@
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
+#include <linux/module.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/socket.h>
+#include <linux/kthread.h>
+#include <linux/net.h>
+#include <linux/in.h>
+#include <linux/poll.h>
+#include <linux/bio.h>
+#include <linux/dst.h>
+
+#include <net/sock.h>
+
+struct kst_poll_helper
+{
+	poll_table 		pt;
+	struct kst_state	*st;
+};
+
+static LIST_HEAD(kst_worker_list);
+static DEFINE_MUTEX(kst_worker_mutex);
+
+/*
+ * This function creates bound socket for local export node.
+ */
+static int kst_sock_create(struct kst_state *st, struct saddr *addr,
+		int type, int proto, int backlog)
+{
+	int err;
+
+	err = sock_create(addr->sa_family, type, proto, &st->socket);
+	if (err)
+		goto err_out_exit;
+
+	err = st->socket->ops->bind(st->socket, (struct sockaddr *)addr,
+			addr->sa_data_len);
+
+	err = st->socket->ops->listen(st->socket, backlog);
+	if (err)
+		goto err_out_release;
+
+	st->socket->sk->sk_allocation = GFP_NOIO;
+
+	return 0;
+
+err_out_release:
+	sock_release(st->socket);
+err_out_exit:
+	return err;
+}
+
+static void kst_sock_release(struct kst_state *st)
+{
+	if (st->socket) {
+		sock_release(st->socket);
+		st->socket = NULL;
+	}
+}
+
+void kst_wake(struct kst_state *st)
+{
+	if (st) {
+		struct kst_worker *w = st->node->w;
+		unsigned long flags;
+
+		spin_lock_irqsave(&w->ready_lock, flags);
+		if (list_empty(&st->ready_entry))
+			list_add_tail(&st->ready_entry, &w->ready_list);
+		spin_unlock_irqrestore(&w->ready_lock, flags);
+
+		wake_up(&w->wait);
+	}
+}
+EXPORT_SYMBOL_GPL(kst_wake);
+
+/*
+ * Polling machinery.
+ */
+static int kst_state_wake_callback(wait_queue_t *wait, unsigned mode,
+		int sync, void *key)
+{
+	struct kst_state *st = container_of(wait, struct kst_state, wait);
+	kst_wake(st);
+	return 1;
+}
+
+static void kst_queue_func(struct file *file, wait_queue_head_t *whead,
+				 poll_table *pt)
+{
+	struct kst_state *st = container_of(pt, struct kst_poll_helper, pt)->st;
+
+	st->whead = whead;
+	init_waitqueue_func_entry(&st->wait, kst_state_wake_callback);
+	add_wait_queue(whead, &st->wait);
+}
+
+static void kst_poll_exit(struct kst_state *st)
+{
+	if (st->whead) {
+		remove_wait_queue(st->whead, &st->wait);
+		st->whead = NULL;
+	}
+}
+
+/*
+ * This function removes request from state tree and ordering list.
+ */
+void kst_del_req(struct dst_request *req)
+{
+	struct kst_state *st = req->state;
+
+	rb_erase(&req->request_entry, &st->request_root);
+	RB_CLEAR_NODE(&req->request_entry);
+	list_del_init(&req->request_list_entry);
+}
+EXPORT_SYMBOL_GPL(kst_del_req);
+
+static struct dst_request *kst_req_first(struct kst_state *st)
+{
+	struct dst_request *req = NULL;
+
+	if (!list_empty(&st->request_list))
+		req = list_entry(st->request_list.next, struct dst_request,
+				request_list_entry);
+	return req;
+}
+
+/*
+ * This function dequeues first request from the queue and tree.
+ */
+static struct dst_request *kst_dequeue_req(struct kst_state *st)
+{
+	struct dst_request *req;
+
+	mutex_lock(&st->request_lock);
+	req = kst_req_first(st);
+	if (req)
+		kst_del_req(req);
+	mutex_unlock(&st->request_lock);
+	return req;
+}
+
+static inline int dst_compare_request_id(struct dst_request *old,
+		struct dst_request *new)
+{
+	int cmd = 0;
+
+	if (old->start + to_sector(old->orig_size) <= new->start)
+		cmd = 1;
+	if (old->start >= new->start + to_sector(new->orig_size))
+		cmd = -1;
+
+	dprintk("%s: old: op: %lu, start: %llu, size: %llu, off: %u, "
+		"new: op: %lu, start: %llu, size: %llu, off: %u, cmp: %d.\n",
+		__func__, bio_rw(old->bio), old->start, old->orig_size,
+		old->offset,
+		bio_rw(new->bio), new->start, new->orig_size,
+		new->offset, cmd);
+
+	return cmd;
+}
+
+/*
+ * This function enqueues request into tree, indexed by start of the request,
+ * and also puts request into ordered queue.
+ */
+int kst_enqueue_req(struct kst_state *st, struct dst_request *req)
+{
+	struct rb_node **n = &st->request_root.rb_node, *parent = NULL;
+	struct dst_request *old = NULL;
+	int cmp, err = 0;
+
+	while (*n) {
+		parent = *n;
+		old = rb_entry(parent, struct dst_request, request_entry);
+
+		cmp = dst_compare_request_id(old, req);
+		if (cmp < 0)
+			n = &parent->rb_left;
+		else if (cmp > 0)
+			n = &parent->rb_right;
+		else {
+			printk("%s: [%c] old_req: %p, start: %llu, "
+					"size: %llu.\n",
+					__func__, 
+					(bio_rw(old->bio) == WRITE)?'W':'R',
+					old, old->start, old->orig_size);
+			err = -EEXIST;
+			break;
+		}
+	}
+
+	if (!err) {
+		rb_link_node(&req->request_entry, parent, n);
+		rb_insert_color(&req->request_entry, &st->request_root);
+	}
+
+	if (req->size != req->orig_size)
+		list_add(&req->request_list_entry, &st->request_list);
+	else
+		list_add_tail(&req->request_list_entry, &st->request_list);
+	return err;
+}
+EXPORT_SYMBOL_GPL(kst_enqueue_req);
+
+/*
+ * BIOs for local exporting node are freed via this function.
+ */
+static void kst_export_put_bio(struct bio *bio)
+{
+	int i;
+	struct bio_vec *bv;
+
+	dprintk("%s: bio: %p, size: %u, idx: %d, num: %d.\n",
+			__func__, bio, bio->bi_size, bio->bi_idx,
+			bio->bi_vcnt);
+
+	bio_for_each_segment(bv, bio, i)
+		__free_page(bv->bv_page);
+	bio_put(bio);
+}
+
+/*
+ * This is a generic request completion function for requests,
+ * queued for async processing.
+ * If it is local export node, state machine is different,
+ * see details below.
+ */
+void kst_complete_req(struct dst_request *req, int err)
+{
+	dprintk("%s: bio: %p, req: %p, size: %llu, orig_size: %llu, "
+			"bi_size: %u, err: %d, flags: %u.\n",
+			__func__, req->bio, req, req->size, req->orig_size,
+			req->bio->bi_size, err, req->flags);
+
+	if (req->flags & DST_REQ_EXPORT) {
+		if (req->flags & DST_REQ_EXPORT_WRITE) {
+			req->bio->bi_rw = WRITE;
+			generic_make_request(req->bio);
+		} else
+			kst_export_put_bio(req->bio);
+	} else {
+		req->bio_endio(req, err);
+	}
+	dst_free_request(req);
+}
+EXPORT_SYMBOL_GPL(kst_complete_req);
+
+static void kst_flush_requests(struct kst_state *st)
+{
+	struct dst_request *req;
+
+	while ((req = kst_dequeue_req(st)) != NULL)
+		kst_complete_req(req, -EIO);
+}
+
+static int kst_poll_init(struct kst_state *st)
+{
+	struct kst_poll_helper ph;
+
+	ph.st = st;
+	init_poll_funcptr(&ph.pt, &kst_queue_func);
+
+	st->socket->ops->poll(NULL, st->socket, &ph.pt);
+	return 0;
+}
+
+/*
+ * Main state creation function.
+ * It creates new state according to given operations
+ * and links it into worker structure and node.
+ */
+static struct kst_state *kst_state_init(struct dst_node *node,
+		unsigned int permissions,
+		struct kst_state_ops *ops, void *data)
+{
+	struct kst_state *st;
+	int err;
+
+	st = kzalloc(sizeof(struct kst_state), GFP_KERNEL);
+	if (!st)
+		return ERR_PTR(-ENOMEM);
+
+	st->permissions = permissions;
+	st->node = node;
+	st->ops = ops;
+	INIT_LIST_HEAD(&st->ready_entry);
+	INIT_LIST_HEAD(&st->entry);
+	st->request_root.rb_node = NULL;
+	INIT_LIST_HEAD(&st->request_list);
+	mutex_init(&st->request_lock);
+
+	err = st->ops->init(st, data);
+	if (err)
+		goto err_out_free;
+	mutex_lock(&node->w->state_mutex);
+	list_add_tail(&st->entry, &node->w->state_list);
+	mutex_unlock(&node->w->state_mutex);
+
+	kst_wake(st);
+
+	return st;
+
+err_out_free:
+	kfree(st);
+	return ERR_PTR(err);
+}
+
+/*
+ * This function is called when node is removed,
+ * or when state is destroyed for connected to local exporting
+ * node client.
+ */
+void kst_state_exit(struct kst_state *st)
+{
+	struct kst_worker *w = st->node->w;
+
+	dprintk("%s: st: %p.\n", __func__, st);
+
+	mutex_lock(&w->state_mutex);
+	list_del_init(&st->entry);
+	mutex_unlock(&w->state_mutex);
+
+	st->ops->exit(st);
+
+	st->node->state = NULL;
+
+	kfree(st);
+}
+
+static int kst_error(struct kst_state *st, int err)
+{
+	if ((err == -ECONNRESET || err == -EPIPE) && st->ops->recovery(st, err))
+		err = st->ops->recovery(st, err);
+
+	return st->node->st->alg->ops->error(st, err);
+}
+
+/*
+ * This is main state processing function.
+ * It tries to complete request and invoke appropriate
+ * callbacks in case of errors or successfull operation finish.
+ */
+static int kst_thread_process_state(struct kst_state *st)
+{
+	int err, empty;
+	unsigned int revents;
+	struct dst_request *req, *tmp;
+
+	mutex_lock(&st->request_lock);
+	if (st->ops->ready) {
+		err = st->ops->ready(st);
+		if (err) {
+			mutex_unlock(&st->request_lock);
+			if (err < 0)
+				kst_state_exit(st);
+			return err;
+		}
+	}
+
+	err = 0;
+	empty = 1;
+	req = NULL;
+	list_for_each_entry_safe(req, tmp, &st->request_list,
+			request_list_entry) {
+		empty = 0;
+		revents = st->socket->ops->poll(st->socket->file,
+				st->socket, NULL);
+		dprintk("\n%s: st: %p, revents: %x.\n", __func__, st, revents);
+		if (!revents)
+			break;
+		err = req->callback(req, revents);
+		dprintk("%s: callback returned, st: %p, err: %d.\n",
+				__func__, st, err);
+		if (err)
+			break;
+	}
+	mutex_unlock(&st->request_lock);
+
+	dprintk("%s: req: %p, err: %d.\n", __func__, req, err);
+	if (err < 0) {
+		err = kst_error(st, err);
+		if (err && (st != st->node->state)) {
+			dprintk("%s: err: %d, st: %p, node->state: %p.\n",
+					__func__, err, st, st->node->state);
+			/*
+			 * Accepted client has state not related to storage
+			 * node, so it must be freed explicitely.
+			 */
+
+			kst_state_exit(st);
+			return err;
+		}
+
+		kst_wake(st);
+	}
+
+	if (list_empty(&st->request_list) && !empty)
+		kst_wake(st);
+
+	return err;
+}
+
+/*
+ * Main worker thread - one per storage.
+ */
+static int kst_thread_func(void *data)
+{
+	struct kst_worker *w = data;
+	struct kst_state *st;
+	unsigned long flags;
+	int err = 0;
+
+	while (!kthread_should_stop()) {
+		wait_event_interruptible_timeout(w->wait,
+				!list_empty(&w->ready_list) ||
+				kthread_should_stop(),
+				HZ);
+
+		st = NULL;
+		spin_lock_irqsave(&w->ready_lock, flags);
+		if (!list_empty(&w->ready_list)) {
+			st = list_entry(w->ready_list.next, struct kst_state,
+					ready_entry);
+			list_del_init(&st->ready_entry);
+		}
+		spin_unlock_irqrestore(&w->ready_lock, flags);
+
+		if (!st)
+			continue;
+
+		err = kst_thread_process_state(st);
+	}
+
+	return err;
+}
+
+/*
+ * Worker initialization - this object will host andprocess all states,
+ * which in turn host requests for remote targets.
+ */
+struct kst_worker *kst_worker_init(int id)
+{
+	struct kst_worker *w;
+	int err;
+
+	w = kzalloc(sizeof(struct kst_worker), GFP_KERNEL);
+	if (!w)
+		return ERR_PTR(-ENOMEM);
+
+	w->id = id;
+	init_waitqueue_head(&w->wait);
+	spin_lock_init(&w->ready_lock);
+	mutex_init(&w->state_mutex);
+
+	INIT_LIST_HEAD(&w->ready_list);
+	INIT_LIST_HEAD(&w->state_list);
+
+	w->req_pool = mempool_create_slab_pool(256, dst_request_cache);
+	if (!w->req_pool) {
+		err = -ENOMEM;
+		goto err_out_free;
+	}
+
+	w->thread = kthread_run(&kst_thread_func, w, "kst%d", w->id);
+	if (IS_ERR(w->thread)) {
+		err = PTR_ERR(w->thread);
+		goto err_out_destroy;
+	}
+
+	mutex_lock(&kst_worker_mutex);
+	list_add_tail(&w->entry, &kst_worker_list);
+	mutex_unlock(&kst_worker_mutex);
+
+	return w;
+
+err_out_destroy:
+	mempool_destroy(w->req_pool);
+err_out_free:
+	kfree(w);
+	return ERR_PTR(err);
+}
+
+void kst_worker_exit(struct kst_worker *w)
+{
+	struct kst_state *st, *n;
+
+	mutex_lock(&kst_worker_mutex);
+	list_del(&w->entry);
+	mutex_unlock(&kst_worker_mutex);
+
+	kthread_stop(w->thread);
+
+	list_for_each_entry_safe(st, n, &w->state_list, entry) {
+		kst_state_exit(st);
+	}
+
+	mempool_destroy(w->req_pool);
+	kfree(w);
+}
+
+/*
+ * Common state exit callback.
+ * Removes itself from worker's list of states,
+ * releases socket and flushes all requests.
+ */
+static void kst_common_exit(struct kst_state *st)
+{
+	unsigned long flags;
+
+	dprintk("%s: st: %p.\n", __func__, st);
+	kst_poll_exit(st);
+
+	spin_lock_irqsave(&st->node->w->ready_lock, flags);
+	list_del_init(&st->ready_entry);
+	spin_unlock_irqrestore(&st->node->w->ready_lock, flags);
+
+	kst_sock_release(st);
+	kst_flush_requests(st);
+}
+
+/*
+ * Listen socket contains security attributes in request_list,
+ * so it can not be flushed via usual way.
+ */
+static void kst_listen_flush(struct kst_state *st)
+{
+	struct dst_secure *s, *tmp;
+
+	list_for_each_entry_safe(s, tmp, &st->request_list, sec_entry) {
+		list_del(&s->sec_entry);
+		kfree(s);
+	}
+}
+
+static void kst_listen_exit(struct kst_state *st)
+{
+	kst_listen_flush(st);
+	kst_common_exit(st);
+}
+
+/*
+ * Header sending function - may block.
+ */
+static int kst_data_send_header(struct kst_state *st,
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
+	return kernel_sendmsg(st->socket, &msg, &iov, 1, iov.iov_len);
+}
+
+/*
+ * BIO vector receiving function - does not block, but may sleep because
+ * of scheduling policy.
+ */
+static int kst_data_recv_bio_vec(struct kst_state *st, struct bio_vec *bv,
+		unsigned int offset, unsigned int size)
+{
+	struct msghdr msg;
+	struct kvec iov;
+	void *kaddr;
+	int err;
+
+	kaddr = kmap(bv->bv_page);
+
+	iov.iov_base = kaddr + bv->bv_offset + offset;
+	iov.iov_len = size;
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_DONTWAIT | MSG_NOSIGNAL;
+
+	err = kernel_recvmsg(st->socket, &msg, &iov, 1, iov.iov_len,
+			msg.msg_flags);
+	kunmap(bv->bv_page);
+
+	return err;
+}
+
+/*
+ * BIO vector sending function - does not block, but may sleep because
+ * of scheduling policy.
+ */
+static int kst_data_send_bio_vec(struct kst_state *st, struct bio_vec *bv,
+		unsigned int offset, unsigned int size)
+{
+	return kernel_sendpage(st->socket, bv->bv_page,
+			bv->bv_offset + offset, size,
+			MSG_DONTWAIT | MSG_NOSIGNAL);
+}
+
+typedef int (*kst_data_process_bio_vec_t)(struct kst_state *st,
+		struct bio_vec *bv, unsigned int offset, unsigned int size);
+
+/*
+ * @req: processing request.
+ * Contains BIO and all related to its processing info.
+ *
+ * This function sends or receives requested number of pages from given BIO.
+ *
+ * In case of errors negative return value is returned and @size,
+ * @index and @off are set to the:
+ * - number of bytes not yet processed (i.e. the rest of the bytes to be
+ *   processed).
+ * - index of the last bio_vec started to be processed (header sent).
+ * - offset of the first byte to be processed in the bio_vec.
+ *
+ * If there are no errors, zero is returned.
+ * -EAGAIN is not an error and is transformed into zero return value,
+ * called must check if @size is zero, in that case whole BIO is processed
+ * and thus req->bio_endio() can be called, othervise new request must be allocated
+ * to be processed later.
+ */
+static int kst_data_process_bio(struct dst_request *req)
+{
+	int err = -ENOSPC, partial = (req->size != req->orig_size);
+	struct dst_remote_request r;
+	kst_data_process_bio_vec_t func;
+	unsigned int cur_size;
+
+	r.flags = cpu_to_be32(((unsigned long)req->bio) & 0xffffffff);
+
+	if (bio_rw(req->bio) == WRITE) {
+		r.cmd = cpu_to_be32(DST_WRITE);
+		func = kst_data_send_bio_vec;
+	} else {
+		r.cmd = cpu_to_be32(DST_READ);
+		func = kst_data_recv_bio_vec;
+	}
+
+	dprintk("%s: start: [%c], start: %llu, idx: %d, num: %d, "
+			"size: %llu, offset: %u.\n",
+			__func__, (bio_rw(req->bio) == WRITE)?'W':'R',
+			req->start, req->idx, req->num, req->size, req->offset);
+
+	while (req->idx < req->num) {
+		struct bio_vec *bv = bio_iovec_idx(req->bio, req->idx);
+
+		cur_size = min_t(u64, bv->bv_len - req->offset, req->size);
+
+		if (cur_size == 0) {
+			printk("%s: %d/%d: start: %llu, "
+				"bv_offset: %u, bv_len: %u, "
+				"req_offset: %u, req_size: %llu, "
+				"req: %p, bio: %p, err: %d.\n",
+				__func__, req->idx, req->num, req->start, 
+				bv->bv_offset, bv->bv_len,
+				req->offset, req->size,
+				req, req->bio, err);
+			BUG();
+		}
+
+		if (!(req->flags & DST_REQ_HEADER_SENT)) {
+			r.sector = cpu_to_be64(req->start);
+			r.offset = cpu_to_be32(bv->bv_offset + req->offset);
+			r.size = cpu_to_be32(cur_size);
+
+			err = kst_data_send_header(req->state, &r);
+			if (err != sizeof(struct dst_remote_request)) {
+				dprintk("%s: %d/%d: header: start: %llu, "
+					"bv_offset: %u, bv_len: %u, "
+					"a offset: %u, offset: %u, "
+					"cur_size: %u, err: %d.\n",
+					__func__, req->idx, req->num,
+					req->start, bv->bv_offset, bv->bv_len,
+					bv->bv_offset + req->offset,
+					req->offset, cur_size, err);
+				if (err >= 0)
+					err = -EINVAL;
+				break;
+			}
+
+			req->flags |= DST_REQ_HEADER_SENT;
+		}
+
+		err = func(req->state, bv, req->offset, cur_size);
+		if (err <= 0)
+			break;
+
+		req->offset += err;
+		req->size -= err;
+
+		if (req->offset != bv->bv_len) {
+			dprintk("%s: %d/%d: this: start: %llu, bv_offset: %u, "
+				"bv_len: %u, a offset: %u, offset: %u, "
+				"cur_size: %u, err: %d.\n",
+				__func__, req->idx, req->num, req->start,
+				bv->bv_offset, bv->bv_len,
+				bv->bv_offset + req->offset,
+				req->offset, cur_size, err);
+			err = -EAGAIN;
+			break;
+		}
+		req->offset = 0;
+		req->idx++;
+		req->flags &= ~DST_REQ_HEADER_SENT;
+
+		req->start += to_sector(bv->bv_len);
+	}
+
+	if (err <= 0 && err != -EAGAIN) {
+		if (err == 0)
+			err = -ECONNRESET;
+	} else
+		err = 0;
+
+	if (req->size) {
+		req->state->flags |= KST_FLAG_PARTIAL;
+	} else if (partial) {
+		req->state->flags &= ~KST_FLAG_PARTIAL;
+	}
+
+	if (err < 0 || (req->idx == req->num && req->size)) {
+		dprintk("%s: return: idx: %d, num: %d, offset: %u, "
+				"size: %llu, err: %d.\n",
+			__func__, req->idx, req->num, req->offset,
+			req->size, err);
+	}
+	dprintk("%s: end: start: %llu, idx: %d, num: %d, "
+			"size: %llu, offset: %u.\n",
+		__func__, req->start, req->idx, req->num,
+		req->size, req->offset);
+
+	return err;
+}
+
+void kst_bio_endio(struct dst_request *req, int err)
+{
+	if (err)
+		printk("%s: freeing bio: %p, bi_size: %u, "
+			"orig_size: %llu, req: %p.\n",
+		__func__, req->bio, req->bio->bi_size, req->orig_size, req);
+	bio_endio(req->bio, req->orig_size, err);
+}
+EXPORT_SYMBOL_GPL(kst_bio_endio);
+
+/*
+ * This callback is invoked by worker thread to process given request.
+ */
+int kst_data_callback(struct dst_request *req, unsigned int revents)
+{
+	int err;
+
+	dprintk("%s: req: %p, num: %d, idx: %d, bio: %p, "
+			"revents: %x, flags: %x.\n",
+			__func__, req, req->num, req->idx, req->bio,
+			revents, req->flags);
+
+	if (req->flags & DST_REQ_EXPORT_READ)
+		return 1;
+
+	err = kst_data_process_bio(req);
+	if (err < 0)
+		goto err_out;
+
+	if (!req->size) {
+		dprintk("%s: complete: req: %p, bio: %p.\n",
+				__func__, req, req->bio);
+		kst_del_req(req);
+		kst_complete_req(req, 0);
+		return 0;
+	}
+
+	if (revents & (POLLERR | POLLHUP | POLLRDHUP)) {
+		err = -EPIPE;
+		goto err_out;
+	}
+
+	return 1;
+
+err_out:
+	return err;
+}
+EXPORT_SYMBOL_GPL(kst_data_callback);
+
+#define KST_CONG_COMPLETED		(0)
+#define KST_CONG_NOT_FOUND		(1)
+#define KST_CONG_QUEUE			(-1)
+
+/*
+ * kst_congestion - checks for data congestion, i.e. the case, when given
+ * 	block request crosses an area of the another block request which
+ * 	is not yet sent to the remote node.
+ *
+ * @req: dst request containing block io related information.
+ *
+ * Return value:
+ * %KST_CONG_COMPLETED  - congestion was found and processed,
+ * 	bio must be ended, request is completed.
+ * %KST_CONG_NOT_FOUND  - no congestion found,
+ * 	request must be processed as usual
+ * %KST_CONG_QUEUE - congestion has been found, but bio is not completed,
+ * 	new request must be allocated and processed.
+ */
+static int kst_congestion(struct dst_request *req)
+{
+	int cmp, i;
+	struct kst_state *st = req->state;
+	struct rb_node *n = st->request_root.rb_node;
+	struct dst_request *old = NULL, *dst_req, *src_req;
+
+	while (n) {
+		src_req = rb_entry(n, struct dst_request, request_entry);
+		cmp = dst_compare_request_id(src_req, req);
+
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else {
+			old = src_req;
+			break;
+		}
+	}
+
+	if (likely(!old))
+		return KST_CONG_NOT_FOUND;
+
+	dprintk("%s: old: op: %lu, start: %llu, size: %llu, off: %u, "
+			"new: op: %lu, start: %llu, size: %llu, off: %u.\n",
+		__func__, bio_rw(old->bio), old->start, old->orig_size,
+		old->offset,
+		bio_rw(req->bio), req->start, req->orig_size, req->offset);
+
+	if ((bio_rw(old->bio) != WRITE) && (bio_rw(req->bio) != WRITE)) {
+		return KST_CONG_QUEUE;
+	}
+
+	if (unlikely(req->offset != old->offset))
+		return KST_CONG_QUEUE;
+
+	src_req = old;
+	dst_req = req;
+	if (bio_rw(req->bio) == WRITE) {
+		dst_req = old;
+		src_req = req;
+	}
+
+	/* Actually we could partially complete new request by copying
+	 * part of the first one, but not now, consider this as a
+	 * (low-priority) todo item.
+	 */
+	if (src_req->start + src_req->orig_size <
+			dst_req->start + dst_req->orig_size)
+		return KST_CONG_QUEUE;
+
+	/*
+	 * So, only process if new request is differnt from old one,
+	 * or subsequent write, i.e.:
+	 * - not completed write and request to read
+	 * - not completed read and request to write
+	 * - not completed write and request to (over)write
+	 */
+	for (i = old->idx; i < old->num; ++i) {
+		struct bio_vec *bv_src, *bv_dst;
+		void *src, *dst;
+		u64 len;
+
+		bv_src = bio_iovec_idx(src_req->bio, i);
+		bv_dst = bio_iovec_idx(dst_req->bio, i);
+
+		if (unlikely(bv_dst->bv_offset != bv_src->bv_offset))
+			return KST_CONG_QUEUE;
+
+		if (unlikely(bv_dst->bv_len != bv_src->bv_len))
+			return KST_CONG_QUEUE;
+
+		src = kmap_atomic(bv_src->bv_page, KM_USER0);
+		dst = kmap_atomic(bv_dst->bv_page, KM_USER1);
+
+		len = min_t(u64, bv_dst->bv_len, dst_req->size);
+
+		memcpy(dst + bv_dst->bv_offset, src + bv_src->bv_offset, len);
+
+		kunmap_atomic(src, KM_USER0);
+		kunmap_atomic(dst, KM_USER1);
+
+		dst_req->idx++;
+		dst_req->size -= len;
+		dst_req->offset = 0;
+		dst_req->start += to_sector(len);
+
+		if (!dst_req->size)
+			break;
+	}
+
+	if (req == dst_req)
+		return KST_CONG_COMPLETED;
+
+	kst_del_req(dst_req);
+	kst_complete_req(dst_req, 0);
+
+	return KST_CONG_NOT_FOUND;
+}
+
+struct dst_request *dst_clone_request(struct dst_request *req, mempool_t *pool)
+{
+	struct dst_request *new_req;
+
+	new_req = mempool_alloc(pool, GFP_NOIO);
+	if (!new_req)
+		return NULL;
+
+	memset(new_req, 0, sizeof(struct dst_request));
+
+	dprintk("%s: req: %p, new_req: %p, bio: %p.\n",
+			__func__, req, new_req, req->bio);
+
+	RB_CLEAR_NODE(&new_req->request_entry);
+
+	if (req) {
+		new_req->bio = req->bio;
+		new_req->state = req->state;
+		new_req->node = req->node;
+		new_req->idx = req->idx;
+		new_req->num = req->num;
+		new_req->size = req->size;
+		new_req->orig_size = req->orig_size;
+		new_req->offset = req->offset;
+		new_req->start = req->start;
+		new_req->flags = req->flags;
+		new_req->bio_endio = req->bio_endio;
+		new_req->priv = req->priv;
+	}
+
+	return new_req;
+}
+EXPORT_SYMBOL_GPL(dst_clone_request);
+
+void dst_free_request(struct dst_request *req)
+{
+	dprintk("%s: free req: %p, pool: %p, bio: %p, state: %p, node: %p.\n",
+			__func__, req, req->node->w->req_pool,
+			req->bio, req->state, req->node);
+	mempool_free(req, req->node->w->req_pool);
+}
+EXPORT_SYMBOL_GPL(dst_free_request);
+
+/*
+ * This is main data processing function, eventually invoked from block layer.
+ * It tries to complte request, but if it is about to block, it allocates
+ * new request and queues it to main worker to be processed when events allow.
+ */
+static int kst_data_push(struct dst_request *req)
+{
+	struct kst_state *st = req->state;
+	struct dst_request *new_req;
+	unsigned int revents;
+	int err, locked = 0;
+
+	dprintk("%s: start: %llu, size: %llu, bio: %p.\n",
+			__func__, req->start, req->size, req->bio);
+
+	if (mutex_trylock(&st->request_lock)) {
+		locked = 1;
+
+		if (st->flags & (KST_FLAG_PARTIAL | DST_REQ_ALWAYS_QUEUE))
+			goto alloc_new_req;
+
+		err = kst_congestion(req);
+		if (err == KST_CONG_COMPLETED) {
+			err = 0;
+			goto out_bio_endio;
+		}
+
+		if (err == KST_CONG_NOT_FOUND) {
+			revents = st->socket->ops->poll(NULL, st->socket, NULL);
+			dprintk("%s: st: %p, bio: %p, revents: %x.\n",
+					__func__, st, req->bio, revents);
+			if (revents & POLLOUT) {
+				err = kst_data_process_bio(req);
+				if (err < 0)
+					goto out_unlock;
+
+				if (!req->size) {
+					err = 0;
+					goto out_bio_endio;
+				}
+			}
+		}
+	}
+
+alloc_new_req:
+	err = -ENOMEM;
+	new_req = dst_clone_request(req, req->node->w->req_pool);
+	if (!new_req)
+		goto out_unlock;
+
+	new_req->callback = &kst_data_callback;
+
+	if (!locked)
+		mutex_lock(&st->request_lock);
+	locked = 1;
+
+	err = kst_enqueue_req(st, new_req);
+	mutex_unlock(&st->request_lock);
+	locked = 0;
+	if (err) {
+		printk(KERN_NOTICE "%s: congestion [%c], start: %llu, idx: %d,"
+				" num: %d, size: %llu, offset: %u, err: %d.\n",
+			__func__, (bio_rw(req->bio) == WRITE)?'W':'R',
+			req->start, req->idx, req->num, req->size,
+			req->offset, err);
+	}
+
+	kst_wake(st);
+
+	return 0;
+
+out_bio_endio:
+	req->bio_endio(req, err);
+out_unlock:
+	if (locked)
+		mutex_unlock(&st->request_lock);
+	locked = 0;
+
+	if (err) {
+		err = kst_error(st, err);
+		if (!err)
+			goto alloc_new_req;
+	}
+
+	if (err) {
+		printk("%s: error [%c], start: %llu, idx: %d, num: %d, "
+				"size: %llu, offset: %u, err: %d.\n",
+			__func__, (bio_rw(req->bio) == WRITE)?'W':'R',
+			req->start, req->idx, req->num, req->size,
+			req->offset, err);
+		req->bio_endio(req, err);
+	}
+
+	kst_wake(st);
+	return err;
+}
+
+/*
+ * Remote node initialization callback.
+ */
+static int kst_data_init(struct kst_state *st, void *data)
+{
+	int err;
+
+	st->socket = data;
+	st->socket->sk->sk_allocation = GFP_NOIO;
+	/*
+	 * Why not?
+	 */
+	st->socket->sk->sk_sndbuf = st->socket->sk->sk_sndbuf = 1024*1024*10;
+
+	err = kst_poll_init(st);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+/*
+ * Remote node recovery function - tries to reconnect to given target.
+ */
+static int kst_data_recovery(struct kst_state *st, int err)
+{
+	struct socket *sock;
+	struct sockaddr addr;
+	int addrlen;
+	struct dst_request *req;
+
+	if (err != -ECONNRESET && err != -EPIPE) {
+		dprintk("%s: state %p does not know how "
+				"to recover from error %d.\n",
+				__func__, st, err);
+		return err;
+	}
+
+	err = sock_create(st->socket->ops->family, st->socket->type,
+			st->socket->sk->sk_protocol, &sock);
+	if (err < 0)
+		goto err_out_exit;
+
+	sock->sk->sk_sndtimeo = sock->sk->sk_rcvtimeo =
+		msecs_to_jiffies(DST_DEFAULT_TIMEO);
+
+	err = sock->ops->getname(st->socket, &addr, &addrlen, 2);
+	if (err)
+		goto err_out_destroy;
+
+	err = sock->ops->connect(sock, &addr, addrlen, 0);
+	if (err)
+		goto err_out_destroy;
+
+	kst_poll_exit(st);
+	kst_sock_release(st);
+
+	mutex_lock(&st->request_lock);
+	err = st->ops->init(st, sock);
+	if (!err) {
+		/*
+		 * After reconnection is completed all requests
+		 * must be resent from the state they were finished previously,
+		 * but with new headers.
+		 */
+		list_for_each_entry(req, &st->request_list, request_list_entry)
+			req->flags &= ~DST_REQ_HEADER_SENT;
+	}
+	mutex_unlock(&st->request_lock);
+	if (err < 0)
+		goto err_out_destroy;
+
+	kst_wake(st);
+	dprintk("%s: recovery completed.\n", __func__);
+
+	return 0;
+
+err_out_destroy:
+	sock_release(sock);
+err_out_exit:
+	dprintk("%s: revovery failed: st: %p, err: %d.\n", __func__, st, err);
+	return err;
+}
+
+static inline void kst_convert_header(struct dst_remote_request *r)
+{
+	r->cmd = be32_to_cpu(r->cmd);
+	r->sector = be64_to_cpu(r->sector);
+	r->offset = be32_to_cpu(r->offset);
+	r->size = be32_to_cpu(r->size);
+	r->flags = be32_to_cpu(r->flags);
+}
+
+/*
+ * Local exporting node end IO callbacks.
+ */
+static int kst_export_write_end_io(struct bio *bio, unsigned int size, int err)
+{
+	dprintk("%s: bio: %p, size: %u, idx: %d, num: %d, err: %d.\n",
+		__func__, bio, bio->bi_size, bio->bi_idx, bio->bi_vcnt, err);
+
+	if (bio->bi_size)
+		return 1;
+
+	kst_export_put_bio(bio);
+	return 0;
+}
+
+static int kst_export_read_end_io(struct bio *bio, unsigned int size, int err)
+{
+	struct dst_request *req = bio->bi_private;
+	struct kst_state *st = req->state;
+
+	dprintk("%s: bio: %p, req: %p, size: %u, idx: %d, num: %d, err: %d.\n",
+		__func__, bio, req, bio->bi_size, bio->bi_idx,
+		bio->bi_vcnt, err);
+
+	if (bio->bi_size)
+		return 1;
+
+	bio->bi_size = req->size = req->orig_size;
+	bio->bi_rw = WRITE;
+	req->flags &= ~DST_REQ_EXPORT_READ;
+	kst_wake(st);
+	return 0;
+}
+
+/*
+ * This callback is invoked each time new request from remote
+ * node to given local export node is received.
+ * It allocates new block IO request and queues it for processing.
+ */
+static int kst_export_ready(struct kst_state *st)
+{
+	struct dst_remote_request r;
+	struct msghdr msg;
+	struct kvec iov;
+	struct bio *bio;
+	int err, nr, i;
+	struct dst_request *req;
+	sector_t data_size;
+	unsigned int revents = st->socket->ops->poll(NULL, st->socket, NULL);
+
+	if (revents & (POLLERR | POLLHUP)) {
+		err = -EPIPE;
+		goto err_out_exit;
+	}
+
+	if (!(revents & POLLIN) || !list_empty(&st->request_list))
+		return 0;
+
+	iov.iov_base = &r;
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
+	err = kernel_recvmsg(st->socket, &msg, &iov, 1,
+			iov.iov_len, msg.msg_flags);
+	if (err != sizeof(struct dst_remote_request)) {
+		err = -EINVAL;
+		goto err_out_exit;
+	}
+
+	kst_convert_header(&r);
+
+	dprintk("\n%s: cmd: %u, sector: %llu, size: %u, "
+			"flags: %x, offset: %u.\n",
+			__func__, r.cmd, r.sector, r.size, r.flags, r.offset);
+
+	err = -EINVAL;
+	if (r.cmd != DST_READ && r.cmd != DST_WRITE && r.cmd != DST_REMOTE_CFG)
+		goto err_out_exit;
+
+	data_size = get_capacity(st->node->bdev->bd_disk);
+	if ((signed)(r.sector + to_sector(r.size)) < 0 ||
+			(signed)(r.sector + to_sector(r.size)) > data_size ||
+			(signed)r.sector > data_size)
+		goto err_out_exit;
+
+	if (r.cmd == DST_REMOTE_CFG) {
+		r.sector = data_size;
+		kst_convert_header(&r);
+
+		iov.iov_base = &r;
+		iov.iov_len = sizeof(struct dst_remote_request);
+
+		msg.msg_iov = (struct iovec *)&iov;
+		msg.msg_iovlen = 1;
+		msg.msg_name = NULL;
+		msg.msg_namelen = 0;
+		msg.msg_control = NULL;
+		msg.msg_controllen = 0;
+		msg.msg_flags = MSG_WAITALL | MSG_NOSIGNAL;
+
+		err = kernel_sendmsg(st->socket, &msg, &iov, 1, iov.iov_len);
+		if (err != sizeof(struct dst_remote_request)) {
+			err = -EINVAL;
+			goto err_out_exit;
+		}
+		kst_wake(st);
+		return 0;
+	}
+
+	nr = r.size/PAGE_SIZE + 1;
+
+	while (r.size) {
+		int nr_pages = min(BIO_MAX_PAGES, nr);
+		unsigned int size;
+		struct page *page;
+
+		err = -ENOMEM;
+		req = dst_clone_request(NULL, st->node->w->req_pool);
+		if (!req)
+			goto err_out_exit;
+
+		dprintk("%s: alloc req: %p, pool: %p.\n",
+				__func__, req, st->node->w->req_pool);
+
+		bio = bio_alloc(GFP_NOIO, nr_pages);
+		if (!bio)
+			goto err_out_free_req;
+
+		req->flags = DST_REQ_EXPORT | DST_REQ_HEADER_SENT;
+		req->bio = bio;
+		req->state = st;
+		req->node = st->node;
+		req->callback = &kst_data_callback;
+		req->bio_endio = &kst_bio_endio;
+
+		/*
+		 * Yes, looks a bit weird.
+		 * Logic is simple - for local exporting node all operations
+		 * are reversed compared to usual nodes, since usual nodes
+		 * process remote data and local export node process remote
+		 * requests, so that writing data means sending data to
+		 * remote node and receiving on the local export one.
+		 *
+		 * So, to process writing to the exported node we need first 
+		 * to receive data from the net (i.e. to perform READ 
+		 * operationin terms of usual node), and then put it to the 
+		 * storage (WRITE command, so it will be changed before 
+		 * calling generic_make_request()).
+		 *
+		 * To process read request from the exported node we need
+		 * first to read it from storage (READ command for BIO)
+		 * and then send it over the net (perform WRITE operation
+		 * in terms of network).
+		 */
+		if (r.cmd == DST_WRITE) {
+			req->flags |= DST_REQ_EXPORT_WRITE;
+			bio->bi_end_io = kst_export_write_end_io;
+		} else {
+			req->flags |= DST_REQ_EXPORT_READ;
+			bio->bi_end_io = kst_export_read_end_io;
+		}
+		bio->bi_rw = READ;
+		bio->bi_private = req;
+		bio->bi_sector = r.sector;
+		bio->bi_bdev = st->node->bdev;
+
+		for (i = 0; i < nr_pages; ++i) {
+			page = alloc_page(GFP_NOIO);
+			if (!page)
+				break;
+
+			size = min_t(u32, PAGE_SIZE, r.size);
+
+			err = bio_add_page(bio, page, size, r.offset);
+			dprintk("%s: %d/%d: page: %p, size: %u, offset: %u, "
+					"err: %d.\n",
+					__func__, i, nr_pages, page, size,
+					r.offset, err);
+			if (err <= 0)
+				break;
+
+			if (err == size) {
+				r.offset = 0;
+				nr--;
+			} else {
+				r.offset += err;
+			}
+
+			r.size -= err;
+			r.sector += to_sector(err);
+
+			if (!r.size)
+				break;
+		}
+
+		if (!bio->bi_vcnt) {
+			err = -ENOMEM;
+			goto err_out_put;
+		}
+
+		req->size = req->orig_size = bio->bi_size;
+		req->start = bio->bi_sector;
+		req->idx = 0;
+		req->num = bio->bi_vcnt;
+
+		dprintk("%s: submitting: bio: %p, req: %p, start: %llu, "
+			"size: %llu, idx: %d, num: %d, offset: %u, err: %d.\n",
+			__func__, bio, req, req->start, req->size,
+			req->idx, req->num, req->offset, err);
+
+		err = kst_enqueue_req(st, req);
+		if (err)
+			goto err_out_put;
+
+		if (r.cmd == DST_READ) {
+			generic_make_request(bio);
+		}
+	}
+
+	kst_wake(st);
+	return 0;
+
+err_out_put:
+	bio_put(bio);
+err_out_free_req:
+	dst_free_request(req);
+err_out_exit:
+	dprintk("%s: error: %d.\n", __func__, err);
+	return err;
+}
+
+static void kst_export_exit(struct kst_state *st)
+{
+	struct dst_node *n = st->node;
+
+	dprintk("%s: st: %p.\n", __func__, st);
+
+	kst_common_exit(st);
+	dst_node_put(n);
+}
+
+static struct kst_state_ops kst_data_export_ops = {
+	.init = &kst_data_init,
+	.push = &kst_data_push,
+	.exit = &kst_export_exit,
+	.ready = &kst_export_ready,
+};
+
+/*
+ * This callback is invoked each time listening socket for
+ * given local export node becomes ready.
+ * It creates new state for connected client and queues for processing.
+ */
+static int kst_listen_ready(struct kst_state *st)
+{
+	struct socket *newsock;
+	struct saddr addr;
+	struct kst_state *newst;
+	int err;
+	unsigned int revents, permissions = 0;
+	struct dst_secure *s;
+
+	revents = st->socket->ops->poll(NULL, st->socket, NULL);
+	if (!(revents & POLLIN))
+		return 1;
+
+	err = sock_create(st->socket->ops->family, st->socket->type,
+			st->socket->sk->sk_protocol, &newsock);
+	if (err)
+		goto err_out_exit;
+
+	err = st->socket->ops->accept(st->socket, newsock, 0);
+	if (err)
+		goto err_out_put;
+
+	if (newsock->ops->getname(newsock, (struct sockaddr *)&addr,
+				  (int *)&addr.sa_data_len, 2) < 0) {
+		err = -ECONNABORTED;
+		goto err_out_put;
+	}
+
+	list_for_each_entry(s, &st->request_list, sec_entry) {
+		void *sec_addr, *new_addr;
+
+		sec_addr = ((void *)&s->sec.addr) + s->sec.check_offset;
+		new_addr = ((void *)&addr) + s->sec.check_offset;
+
+		if (!memcmp(sec_addr, new_addr,	
+				addr.sa_data_len - s->sec.check_offset)) {
+			permissions = s->sec.permissions;
+			break;
+		}
+	}
+
+	/*
+	 * So far only reading and writing are supported.
+	 * Block device does not know about anything else,
+	 * but as far as I recall, there was a prognosis,
+	 * that computer will never require more than 640kb of RAM.
+	 */
+	if (permissions == 0) {
+		err = -EPERM;
+		goto err_out_put;
+	}
+
+	if (st->socket->ops->family == AF_INET) {
+		struct sockaddr_in *sin = (struct sockaddr_in *)&addr;
+		printk(KERN_INFO "%s: Client: %u.%u.%u.%u:%d.\n", __func__,
+			NIPQUAD(sin->sin_addr.s_addr), ntohs(sin->sin_port));
+	} else if (st->socket->ops->family == AF_INET6) {
+		struct sockaddr_in6 *sin = (struct sockaddr_in6 *)&addr;
+		printk(KERN_INFO "%s: Client: "
+			"%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%d",
+			__func__, 
+			NIP6(sin->sin6_addr), ntohs(sin->sin6_port));
+	}
+
+	dst_node_get(st->node);
+	newst = kst_state_init(st->node, permissions,
+			&kst_data_export_ops, newsock);
+	if (IS_ERR(newst)) {
+		err = PTR_ERR(newst);
+		goto err_out_put;
+	}
+
+	/*
+	 * Negative return value means error, positive - stop this state 
+	 * processing. Zero allows to check state for pending requests.
+	 * Listening socket contains security objects in request list,
+	 * since it does not have any requests.
+	 */
+	return 1;
+
+err_out_put:
+	sock_release(newsock);
+err_out_exit:
+	return 1;
+}
+
+static int kst_listen_init(struct kst_state *st, void *data)
+{
+	int err = -ENOMEM, i;
+	struct dst_le_template *tmp = data;
+	struct dst_secure *s;
+
+	for (i=0; i<tmp->le->secure_attr_num; ++i) {
+		s = kmalloc(sizeof(struct dst_secure), GFP_KERNEL);
+		if (!s)
+			goto err_out_exit;
+
+		memcpy(&s->sec, tmp->data, sizeof(struct dst_secure_user));
+
+		list_add_tail(&s->sec_entry, &st->request_list);
+		tmp->data += sizeof(struct dst_secure_user);
+
+		if (s->sec.addr.sa_family == AF_INET) {
+			struct sockaddr_in *sin = 
+				(struct sockaddr_in *)&s->sec.addr;
+			printk(KERN_INFO "%s: Client: %u.%u.%u.%u:%d, "
+					"permissions: %x.\n", 
+				__func__, NIPQUAD(sin->sin_addr.s_addr), 
+				ntohs(sin->sin_port), s->sec.permissions);
+		} else if (s->sec.addr.sa_family == AF_INET6) {
+			struct sockaddr_in6 *sin = 
+				(struct sockaddr_in6 *)&s->sec.addr;
+			printk(KERN_INFO "%s: Client: "
+				"%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%d, "
+				"permissions: %x.\n", 
+				__func__, NIP6(sin->sin6_addr), 
+				ntohs(sin->sin6_port), s->sec.permissions);
+		}
+	}
+
+	err = kst_sock_create(st, &tmp->le->rctl.addr, tmp->le->rctl.type,
+			tmp->le->rctl.proto, tmp->le->backlog);
+	if (err)
+		goto err_out_exit;
+
+	err = kst_poll_init(st);
+	if (err)
+		goto err_out_release;
+
+	return 0;
+
+err_out_release:
+	kst_sock_release(st);
+err_out_exit:
+	kst_listen_flush(st);
+	return err;
+}
+
+/*
+ * Operations for different types of states.
+ * There are three:
+ * data state - created for remote node, when distributed storage connects
+ * 	to remote node, which contain data.
+ * listen state - created for local export node, when remote distributed
+ * 	storage's node connects to given node to get/put data.
+ * data export state - created for each client connected to above listen
+ * 	state.
+ */
+static struct kst_state_ops kst_listen_ops = {
+	.init = &kst_listen_init,
+	.exit = &kst_listen_exit,
+	.ready = &kst_listen_ready,
+};
+static struct kst_state_ops kst_data_ops = {
+	.init = &kst_data_init,
+	.push = &kst_data_push,
+	.exit = &kst_common_exit,
+	.recovery = &kst_data_recovery,
+};
+
+struct kst_state *kst_listener_state_init(struct dst_node *node,
+		struct dst_le_template *tmp)
+{
+	return kst_state_init(node, DST_PERM_READ | DST_PERM_WRITE,
+			&kst_listen_ops, tmp);
+}
+
+struct kst_state *kst_data_state_init(struct dst_node *node,
+		struct socket *newsock)
+{
+	return kst_state_init(node, DST_PERM_READ | DST_PERM_WRITE,
+			&kst_data_ops, newsock);
+}
+
+/*
+ * Remove all workers and associated states.
+ */
+void kst_exit_all(void)
+{
+	struct kst_worker *w, *n;
+
+	list_for_each_entry_safe(w, n, &kst_worker_list, entry) {
+		kst_worker_exit(w);
+	}
+}
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 10eb56b..9e67d58 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -36,9 +36,11 @@
 #define CN_VAL_CIFS                     0x1
 #define CN_W1_IDX			0x3	/* w1 communication */
 #define CN_W1_VAL			0x1
+#define CN_DST_IDX			0x4	/* Distributed storage */
+#define CN_DST_VAL			0x1
 
 
-#define CN_NETLINK_USERS		4
+#define CN_NETLINK_USERS		5
 
 /*
  * Maximum connector's message size.
diff --git a/include/linux/dst.h b/include/linux/dst.h
new file mode 100644
index 0000000..3fd41dd
--- /dev/null
+++ b/include/linux/dst.h
@@ -0,0 +1,354 @@
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
+
+#define DST_NAMELEN		32
+#define DST_NAME		"dst"
+#define DST_IOCTL		0xba
+
+enum {
+	DST_DEL_NODE	= 0,	/* Remove node with given id from storage */
+	DST_ADD_REMOTE,		/* Add remote node with given id to the storage */
+	DST_ADD_LOCAL,		/* Add local node with given id to the storage */
+	DST_ADD_LOCAL_EXPORT,	/* Add local node with given id to the storage to be exported and used by remote peers */
+	DST_START_STORAGE,	/* Array is ready and storage can be started, if there will be new nodes
+				 * added to the storage, they will be checked against existing size and
+				 * probably be dropped (for example in mirror format when new node has smaller
+				 * size than array created) or inserted.
+				 */
+	DST_STOP_STORAGE,	/* Remove array and all nodes. */
+	DST_CMD_MAX
+};
+
+#define DST_CTL_FLAGS_REMOTE	(1<<0)
+#define DST_CTL_FLAGS_EXPORT	(1<<1)
+
+struct dst_ctl
+{
+	char			st[DST_NAMELEN];
+	char			alg[DST_NAMELEN];
+	__u32			flags, cmd;
+	__u64			start, size;
+};
+
+struct dst_local_ctl
+{
+	char			name[DST_NAMELEN];
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
+struct dst_remote_ctl
+{
+	__u16			type;
+	__u16			proto;
+	struct saddr		addr;
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
+	unsigned short		check_offset;
+	struct saddr		addr;
+};
+
+struct dst_local_export_ctl
+{
+	__u32			backlog;
+	int			secure_attr_num;
+	struct dst_local_ctl	lctl;
+	struct dst_remote_ctl	rctl;
+};
+
+enum {
+	DST_REMOTE_CFG		= 1, 		/* Request remote configuration */
+	DST_WRITE,				/* Writing */
+	DST_READ,				/* Reading */
+	DST_NCMD_MAX,
+};
+
+struct dst_remote_request
+{
+	__u32			cmd;
+	__u32			flags;
+	__u64			sector;
+	__u32			offset;
+	__u32			size;
+};
+
+#ifdef __KERNEL__
+
+#include <linux/rbtree.h>
+#include <linux/net.h>
+#include <linux/blkdev.h>
+#include <linux/bio.h>
+#include <linux/mempool.h>
+#include <linux/device.h>
+
+//#define DST_DEBUG
+
+#ifdef DST_DEBUG
+#define dprintk(f, a...) printk(KERN_NOTICE f, ##a)
+#else
+#define dprintk(f, a...) do {} while (0)
+#endif
+
+struct kst_worker
+{
+	struct list_head	entry;
+
+	struct list_head	state_list;
+	struct mutex		state_mutex;
+
+	struct list_head	ready_list;
+	spinlock_t		ready_lock;
+
+	mempool_t		*req_pool;
+
+	struct task_struct	*thread;
+
+	wait_queue_head_t 	wait;
+
+	int			id;
+};
+
+struct kst_state;
+struct dst_node;
+
+#define DST_REQ_HEADER_SENT	(1<<0)
+#define DST_REQ_EXPORT		(1<<1)
+#define DST_REQ_EXPORT_WRITE	(1<<2)
+#define DST_REQ_EXPORT_READ	(1<<3)
+#define DST_REQ_ALWAYS_QUEUE	(1<<4)
+
+struct dst_request
+{
+	struct rb_node		request_entry;
+	struct list_head	request_list_entry;
+	struct bio		*bio;
+	struct kst_state 	*state;
+	struct dst_node 	*node;
+
+	u32			flags;
+
+	int 			(*callback)(struct dst_request *dst,
+						unsigned int revents);
+	void			(*bio_endio)(struct dst_request *dst, 
+						int err);
+
+	void			*priv;
+	atomic_t		refcnt;
+
+	u64			size, orig_size, start;
+	int			idx, num;
+	u32			offset;
+};
+
+struct kst_state_ops
+{
+	int 		(*init)(struct kst_state *, void *);
+	int 		(*push)(struct dst_request *req);
+	int		(*ready)(struct kst_state *);
+	int		(*recovery)(struct kst_state *, int err);
+	void 		(*exit)(struct kst_state *);
+};
+
+#define KST_FLAG_PARTIAL		(1<<0)
+
+struct kst_state
+{
+	struct list_head	entry;
+	struct list_head	ready_entry;
+
+	wait_queue_t 		wait;
+	wait_queue_head_t 	*whead;
+
+	struct dst_node		*node;
+	struct socket		*socket;
+
+	u32			flags, permissions;
+
+	struct rb_root		request_root;
+	struct mutex		request_lock;
+	struct list_head	request_list;
+
+	struct kst_state_ops	*ops;
+};
+
+#define DST_DEFAULT_TIMEO	2000
+
+struct dst_storage;
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
+struct dst_alg
+{
+	struct list_head	entry;
+	char			name[DST_NAMELEN];
+	atomic_t		refcnt;
+	struct dst_alg_ops	*ops;
+};
+
+#define DST_ST_STARTED		(1<<0)
+
+struct dst_storage
+{
+	struct list_head	entry;
+	char			name[DST_NAMELEN];
+	struct dst_alg		*alg;
+	atomic_t		refcnt;
+	struct mutex		tree_lock;
+	struct rb_root		tree_root;
+
+	request_queue_t		*queue;
+	struct gendisk		*disk;
+
+	long			flags;
+	u64			disk_size;
+
+	struct device		device;
+};
+
+#define DST_NODE_FROZEN		0
+#define DST_NODE_NOTSYNC	1
+
+struct dst_node
+{
+	struct rb_node		tree_node;
+
+	struct list_head	shared;
+	struct dst_node		*shared_head;
+
+	struct block_device 	*bdev;
+	struct dst_storage	*st;
+	struct kst_state	*state;
+	struct kst_worker	*w;
+
+	atomic_t		refcnt;
+	atomic_t		shared_num;
+
+	void			(*cleanup)(struct dst_node *);
+
+	long			flags;
+
+	u64			start, size;
+
+	void			(*priv_callback)(struct dst_node *);
+	void			*priv;
+
+	struct device		device;
+};
+
+struct dst_le_template
+{
+	struct dst_local_export_ctl	*le;
+	void 				*data;
+};
+
+struct dst_secure
+{
+	struct list_head	sec_entry;
+	struct dst_secure_user	sec;
+};
+
+void kst_state_exit(struct kst_state *st);
+
+struct kst_worker *kst_worker_init(int id);
+void kst_worker_exit(struct kst_worker *w);
+
+struct kst_state *kst_listener_state_init(struct dst_node *node,
+		struct dst_le_template *tmp);
+struct kst_state *kst_data_state_init(struct dst_node *node,
+		struct socket *newsock);
+
+void kst_wake(struct kst_state *st);
+
+void kst_exit_all(void);
+
+struct dst_alg *dst_alloc_alg(char *name, struct dst_alg_ops *ops);
+void dst_remove_alg(struct dst_alg *alg);
+
+struct dst_node *dst_storage_tree_search(struct dst_storage *st, u64 start);
+
+void dst_node_put(struct dst_node *n);
+
+static inline struct dst_node *dst_node_get(struct dst_node *n)
+{
+	atomic_inc(&n->refcnt);
+	return n;
+}
+
+struct dst_request *dst_clone_request(struct dst_request *req, mempool_t *pool);
+void dst_free_request(struct dst_request *req);
+
+void kst_complete_req(struct dst_request *req, int err);
+void kst_bio_endio(struct dst_request *req, int err);
+void kst_del_req(struct dst_request *req);
+int kst_enqueue_req(struct kst_state *st, struct dst_request *req);
+
+int kst_data_callback(struct dst_request *req, unsigned int revents);
+
+extern struct kmem_cache *dst_request_cache;
+
+static inline sector_t to_sector(unsigned long n)
+{
+	return (n >> 9);
+}
+
+static inline unsigned long to_bytes(sector_t n)
+{
+	return (n << 9);
+}
+
+/*
+ * Checks state's permissions.
+ * Returns -EPERM if check failed.
+ */
+static inline int kst_check_permissions(struct kst_state *st, struct bio *bio)
+{
+	if ((bio_rw(bio) == WRITE) && !(st->permissions & DST_PERM_WRITE))
+		return -EPERM;
+
+	return 0;
+}
+
+#endif /* __KERNEL__ */
+#endif /* __DST_H */

-- 
	Evgeniy Polyakov
