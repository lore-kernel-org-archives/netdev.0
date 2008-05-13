From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Tue, 13 May 2008 21:45:24 +0400
Message-ID: <20080513174523.GA1677@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38289 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755112AbYEMRp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 13:45:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

I'm please to announce POHMEL high performance network filesystem.
POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.

Development status can be tracked in filesystem section [1].

This is a high performance network filesystem with local coherent cache of data
and metadata. Its main goal is distributed parallel processing of data. Network 
filesystem is a client transport. POHMELFS protocol was proven to be superior to
NFS in lots (if not all, then it is in a roadmap) operations.

This release brings following features:
 * Fast transactions. System will wrap all writings into transactions, which
 	will be resent to different (or the same) server in case of failure.
	Details in notes [1].
 * Failover. It is now possible to provide number of servers to be used in
 	round-robin fasion when one of them dies. System will automatically
	reconnect to others and send transactions to them.
 * Performance. Super fast (close to wire limit) metadata operations over
 	the network. By courtesy of writeback cache and transactions the whole
	kernel archive can be untarred by 2-3 seconds (including sync) over
	GigE link (wire limit! Not comparable to NFS).

Basic POHMELFS features:
    * Local coherent (notes [5]) cache for data and metadata.
    * Completely async processing of all events (hard and symlinks are the only 
    	exceptions) including object creation and data reading.
    * Flexible object architecture optimized for network processing. Ability to
    	create long pathes to object and remove arbitrary huge directoris in 
	single network command.
    * High performance is one of the main design goals.
    * Very fast and scalable multithreaded userspace server. Being in userspace
    	it works with any underlying filesystem and still is much faster than
	async ni-kernel NFS one.

Roadmap includes:
    * Server extension to allow storing data on multiple devices (like creating mirroring),
    	first by saving data in several local directories (think about server, which mounted
	remote dirs over POHMELFS or NFS, and local dirs).
    * Client/server extension to report lookup and readdir requests not only for local
    	destination, but also to different addresses, so that reading/writing could be
	done from different nodes in parallel.
    * Strong authentification and possible data encryption in network channel.
    * Async writing of the data from receiving kernel thread into
    	userspace pages via copy_to_user() (check development tracking
	blog for results).

One can grab sources from archive or git [2] or check homepage [3].
Benchmark section can be found in the blog [4].

The nearest roadmap (scheduled or the end of the month) includes:
 * Full transaction support for all operations (only writeback is
 	guarded by transactions currently, default network state
	just reconnects to the same server).
 * Data and metadata coherency extensions (in addition to existing
	commented object creation/removal messages). (next week)
 * Server redundancy.

Thank you.

1. POHMELFS development status.
http://tservice.net.ru/~s0mbre/blog/devel/fs/index.html

2. Source archive.
http://tservice.net.ru/~s0mbre/archive/pohmelfs/
Git tree.
http://tservice.net.ru/~s0mbre/archive/pohmelfs/pohmelfs.git/

3. POHMELFS homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=pohmelfs

4. POHMELFS vs NFS benchmark.
http://tservice.net.ru/~s0mbre/blog/devel/fs/2008_04_18.html
http://tservice.net.ru/~s0mbre/blog/devel/fs/2008_04_14.html
http://tservice.net.ru/~s0mbre/blog/devel/fs/2008_05_12.html

5. Cache-coherency notes.
http://tservice.net.ru/~s0mbre/blog/devel/fs/2008_04_21.html
http://tservice.net.ru/~s0mbre/blog/devel/fs/2008_04_22.html

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

 fs/Kconfig               |    2 +
 fs/Makefile              |    1 +
 fs/pohmelfs/Kconfig      |    6 +
 fs/pohmelfs/Makefile     |    3 +
 fs/pohmelfs/config.c     |  148 +++++
 fs/pohmelfs/dir.c        | 1009 ++++++++++++++++++++++++++++++
 fs/pohmelfs/inode.c      | 1543 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/pohmelfs/net.c        |  800 ++++++++++++++++++++++++
 fs/pohmelfs/netfs.h      |  426 +++++++++++++
 fs/pohmelfs/path_entry.c |  278 +++++++++
 fs/pohmelfs/trans.c      |  469 ++++++++++++++
 11 files changed, 4685 insertions(+), 0 deletions(-)

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
index 0000000..ac19aac
--- /dev/null
+++ b/fs/pohmelfs/Kconfig
@@ -0,0 +1,6 @@
+config POHMELFS
+	tristate "POHMELFS filesystem support"
+	help
+	  POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.
+	  This is a network filesystem which supports coherent caching of data and metadata
+	  on clients.
diff --git a/fs/pohmelfs/Makefile b/fs/pohmelfs/Makefile
new file mode 100644
index 0000000..aa415a3
--- /dev/null
+++ b/fs/pohmelfs/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_POHMELFS)	+= pohmelfs.o
+
+pohmelfs-y := inode.o config.o dir.o net.o path_entry.o trans.o
diff --git a/fs/pohmelfs/config.c b/fs/pohmelfs/config.c
new file mode 100644
index 0000000..0f3503b
--- /dev/null
+++ b/fs/pohmelfs/config.c
@@ -0,0 +1,148 @@
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
+#include <linux/list.h>
+#include <linux/mutex.h>
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
+int pohmelfs_copy_config(struct pohmelfs_sb *psb)
+{
+	struct pohmelfs_config *c, *dst;
+	int err = -ENODEV;
+
+	mutex_lock(&pohmelfs_config_lock);
+	list_for_each_entry(c, &pohmelfs_config_list, config_entry) {
+		if (c->state.ctl.idx != psb->idx)
+			continue;
+
+		dst = kzalloc(sizeof(struct pohmelfs_config), GFP_KERNEL);
+		if (!dst) {
+			err = -ENOMEM;
+			goto err_out_unlock;
+		}
+
+		memcpy(&dst->state.ctl, &c->state.ctl, sizeof(struct pohmelfs_ctl));
+
+		mutex_lock(&psb->state_lock);
+		list_add_tail(&dst->config_entry, &psb->state_list);
+		mutex_unlock(&psb->state_lock);
+		err = 0;
+	}
+	mutex_unlock(&pohmelfs_config_lock);
+
+	return err;
+
+err_out_unlock:
+	mutex_unlock(&pohmelfs_config_lock);
+
+	mutex_lock(&psb->state_lock);
+	list_for_each_entry_safe(dst, c, &psb->state_list, config_entry) {
+		list_del(&dst->config_entry);
+		kfree(dst);
+	}
+	mutex_unlock(&psb->state_lock);
+
+	return err;
+}
+
+static void pohmelfs_cn_callback(void *data)
+{
+	struct cn_msg *msg = data;
+	struct pohmelfs_ctl *ctl;
+	struct pohmelfs_cn_ack *ack;
+	struct pohmelfs_config *c;
+	int err;
+
+	if (msg->len < sizeof(struct pohmelfs_ctl)) {
+		err = -EBADMSG;
+		goto out;
+	}
+
+	ctl = (struct pohmelfs_ctl *)msg->data;
+
+	err = 0;
+	mutex_lock(&pohmelfs_config_lock);
+	list_for_each_entry(c, &pohmelfs_config_list, config_entry) {
+		struct pohmelfs_ctl *sc = &c->state.ctl;
+
+		if (sc->idx == ctl->idx && sc->type == ctl->type &&
+				sc->proto == ctl->proto &&
+				sc->addrlen == ctl->addrlen &&
+				!memcmp(&sc->addr, &ctl->addr, ctl->addrlen)) {
+			err = -EEXIST;
+			break;
+		}
+	}
+	if (!err) {
+		c = kzalloc(sizeof(struct pohmelfs_config), GFP_KERNEL);
+		if (!c) {
+			err = -ENOMEM;
+			goto out;
+		}
+
+		memcpy(&c->state.ctl, ctl, sizeof(struct pohmelfs_ctl));
+		list_add_tail(&c->config_entry, &pohmelfs_config_list);
+	}
+	mutex_unlock(&pohmelfs_config_lock);
+
+out:
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
+int __init pohmelfs_config_init(void)
+{
+	return cn_add_callback(&pohmelfs_cn_id, "pohmelfs", pohmelfs_cn_callback);
+}
+
+void __exit pohmelfs_config_exit(void)
+{
+	struct pohmelfs_config *c, *tmp;
+
+	cn_del_callback(&pohmelfs_cn_id);
+
+	mutex_lock(&pohmelfs_config_lock);
+	list_for_each_entry_safe(c, tmp, &pohmelfs_config_list, config_entry) {
+		list_del(&c->config_entry);
+		kfree(c);
+	}
+	mutex_unlock(&pohmelfs_config_lock);
+}
diff --git a/fs/pohmelfs/dir.c b/fs/pohmelfs/dir.c
new file mode 100644
index 0000000..41e1f8f
--- /dev/null
+++ b/fs/pohmelfs/dir.c
@@ -0,0 +1,1009 @@
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
+				ret->ino, new->hash, new->len, new->data);
+		return ret;
+	}
+
+	rb_link_node(&new->hash_node, parent, n);
+	rb_insert_color(&new->hash_node, &pi->hash_root);
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
+		e = pohmelfs_add_path_entry(psb, parent->ino, npi->ino, str, link);
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
+	if (err)
+		goto err_out_remove;
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
+		pohmelfs_fill_inode(npi, info);
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
+			if (err)
+				goto err_out_put;
+		} else {
+			mutex_lock(&psb->path_lock);
+			pohmelfs_add_path_entry(psb, npi->ino, npi->ino, str, link);
+			mutex_unlock(&psb->path_lock);
+		}
+	}
+
+	if (new->i_state & I_NEW) {
+		mutex_lock(&psb->path_lock);
+		list_add_tail(&npi->inode_entry, &psb->inode_list);
+		mutex_unlock(&psb->path_lock);
+
+		unlock_new_inode(new);
+		if (parent)
+			mark_inode_dirty(&parent->vfs_inode);
+		mark_inode_dirty(new);
+	}
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
+/*
+ * Receive directory content from the server.
+ * This should be only done for objects, which were not created locally,
+ * and which were not synced previously.
+ */
+static int pohmelfs_sync_remote_dir(struct pohmelfs_inode *pi)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(pi->vfs_inode.i_sb);
+	struct netfs_state *st = pohmelfs_active_state(psb);
+	struct netfs_cmd *cmd = &st->cmd;
+	long ret = msecs_to_jiffies(25000);
+	unsigned path_size;
+	int err;
+
+	dprintk("%s: dir: %llu, state: %lx: created: %d, remote_syced: %d.\n",
+			__func__, pi->ino, pi->state, test_bit(NETFS_INODE_CREATED, &pi->state),
+			test_bit(NETFS_INODE_REMOTE_SYNCED, &pi->state));
+
+	if (!test_bit(NETFS_INODE_CREATED, &pi->state))
+		return -1;
+
+	if (test_bit(NETFS_INODE_REMOTE_SYNCED, &pi->state))
+		return 0;
+
+	mutex_lock(&st->state_lock);
+
+	mutex_lock(&st->psb->path_lock);
+	err = pohmelfs_construct_path_string(pi, st->data, st->size);
+	mutex_unlock(&st->psb->path_lock);
+	if (err < 0)
+		goto err_out_unlock;
+
+	dprintk("%s: syncing dir: %llu, data: '%s'.\n", __func__, pi->ino, (char *)st->data);
+
+	cmd->cmd = NETFS_READDIR;
+	cmd->start = 0;
+	path_size = cmd->size = err + 1;
+	cmd->ext = 0;
+	cmd->id = pi->ino;
+	netfs_convert_cmd(cmd);
+
+	err = netfs_data_send(st, cmd, sizeof(struct netfs_cmd), 1);
+	if (err)
+		goto err_out_unlock;
+
+	err = netfs_data_send(st, st->data, path_size, 0);
+	if (err)
+		goto err_out_unlock;
+
+	mutex_unlock(&st->state_lock);
+
+	ret = wait_event_interruptible_timeout(st->thread_wait,
+			test_bit(NETFS_INODE_REMOTE_SYNCED, &pi->state), ret);
+	dprintk("%s: awake dir: %llu, ret: %ld.\n", __func__, pi->ino, ret);
+	if (ret <= 0) {
+		err = -ETIMEDOUT;
+		goto err_out_exit;
+	}
+
+	return 0;
+
+err_out_unlock:
+	mutex_unlock(&st->state_lock);
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
+	struct netfs_state *st = pohmelfs_active_state(psb);
+	struct netfs_cmd *cmd = &st->cmd;
+	long ret = msecs_to_jiffies(25000);
+	unsigned path_size;
+	int err;
+
+	mutex_lock(&st->state_lock);
+	set_bit(NETFS_COMMAND_PENDING, &parent->state);
+
+	mutex_lock(&st->psb->path_lock);
+	err = pohmelfs_construct_path_string(parent, st->data, st->size - str->len - 2);
+	mutex_unlock(&st->psb->path_lock);
+	if (err < 0)
+		goto err_out_unlock;
+
+	path_size = err;
+	path_size += sprintf(st->data + path_size, "/%s", str->name) + 1 /* 0-byte */;
+
+	cmd->cmd = NETFS_LOOKUP;
+	cmd->size = path_size;
+	cmd->ext = 0;
+	cmd->id = parent->ino;
+	cmd->start = ino;
+	netfs_convert_cmd(cmd);
+
+	err = netfs_data_send(st, cmd, sizeof(struct netfs_cmd), 1);
+	if (err)
+		goto err_out_unlock;
+
+	err = netfs_data_send(st, st->data, path_size, 0);
+	if (err)
+		goto err_out_unlock;
+
+	mutex_unlock(&st->state_lock);
+
+	ret = wait_event_interruptible_timeout(st->thread_wait,
+			!test_bit(NETFS_COMMAND_PENDING, &parent->state), ret);
+	if (ret <= 0) {
+		err = -ETIMEDOUT;
+		goto err_out_exit;
+	}
+
+	return 0;
+
+err_out_unlock:
+	mutex_unlock(&st->state_lock);
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
+	dprintk("%s: dir: %p, dir_ino: %lu/%llu, dentry: %p, dinode: %p, "
+			"name: '%s', len: %u, dir_state: %lx.\n",
+			__func__, dir, dir->i_ino, parent->ino,
+			dentry, dentry->d_inode, str.name, str.len, parent->state);
+
+	mutex_lock(&parent->offset_lock);
+	n = pohmelfs_search_hash(parent, str.hash, str.len);
+	if (n)
+		ino = n->ino;
+	mutex_unlock(&parent->offset_lock);
+
+#ifdef POHMELFS_FULL_DIR_RESYNC_ON_LOOKUP
+	mutex_lock(&parent->offset_lock);
+	n = pohmelfs_search_offset(parent, 3);
+	if (n) {
+		struct rb_node *rb_node;
+		for (rb_node = &n->offset_node; rb_node;) {
+			n = rb_entry(rb_node, struct pohmelfs_name, offset_node);
+			rb_node = rb_next(rb_node);
+
+			pohmelfs_name_free(parent, n);
+		}
+	}
+
+	parent->total_len = 3;
+	mutex_unlock(&parent->offset_lock);
+
+	clear_bit(NETFS_INODE_REMOTE_SYNCED, &parent->state);
+
+	err = pohmelfs_sync_remote_dir(parent);
+	if (err)
+		return NULL;
+
+	mutex_unlock(&parent->offset_lock);
+	n = pohmelfs_search_hash(parent, str.hash, str.len);
+	if (n)
+		ino = n->ino;
+	mutex_unlock(&parent->offset_lock);
+
+	inode = ilookup(dir->i_sb, ino);
+	if (!inode)
+		return NULL;
+
+	dentry = d_splice_alias(inode, dentry);
+	iput(inode);
+
+	return dentry;
+#else
+	if (ino) {
+		inode = ilookup(dir->i_sb, ino);
+		dprintk("%s: first lookup ino: %lu, inode: %p, name: '%s', hash: %x.\n",
+				__func__, ino, inode, str.name, str.hash);
+		if (inode)
+			return d_splice_alias(inode, dentry);
+	}
+
+	if (!test_bit(NETFS_INODE_CREATED, &parent->state))
+		return NULL;
+
+	err = pohmelfs_lookup_single(parent, &str, ino);
+	if (err)
+		return NULL;
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
+		dprintk("%s: second lookup ino: %lu, inode: %p, name: '%s', hash: %x.\n",
+				__func__, ino, inode, str.name, str.hash);
+		if (!inode) {
+			printk("%s: No inode for ino: %lu, name: '%s', hash: %x.\n",
+				__func__, ino, str.name, str.hash);
+			//return NULL;
+			return ERR_PTR(-EACCES);
+		}
+	} else {
+		dprintk("%s: No inode number : name: '%s', hash: %x.\n",
+			__func__, str.name, str.hash);
+	}
+
+	return d_splice_alias(inode, dentry);
+#endif
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
+	struct netfs_state *st = pohmelfs_active_state(psb);
+	int err = -ENOMEM;
+
+	dprintk("%s: name: '%s', mode: %o, start: %llu.\n",
+			__func__, str->name, mode, start);
+
+	mutex_lock(&st->state_lock);
+
+	st->info.mode = mode;
+	st->info.ino = start;
+
+	if (!start)
+		st->info.ino = psb->ino++;
+
+	st->info.nlink = S_ISDIR(mode)?2:1;
+	st->info.uid = current->uid;
+	st->info.gid = current->gid;
+	st->info.size = 0;
+	st->info.blocksize = 512;
+	st->info.blocks = 0;
+	st->info.rdev = 0;
+	st->info.version = 0;
+
+	npi = pohmelfs_new_inode(psb, parent, str, &st->info, !!start);
+	if (IS_ERR(npi)) {
+		err = PTR_ERR(npi);
+		goto err_out_unlock;
+	}
+
+	mutex_unlock(&st->state_lock);
+
+	return npi;
+
+err_out_unlock:
+	mutex_unlock(&st->state_lock);
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
+	struct netfs_state *st = pohmelfs_active_state(psb);
+	struct netfs_cmd *cmd = &st->cmd;
+	unsigned path_size = 0;
+	struct inode *inode = &parent->vfs_inode;
+	int err;
+
+	err = sb->s_op->write_inode(inode, 0);
+	if (err)
+		return err;
+
+	mutex_lock(&st->state_lock);
+
+	mutex_lock(&st->psb->path_lock);
+	err = pohmelfs_construct_path_string(parent, st->data, st->size - obj->len - 1);
+	if (err > 0) {
+		path_size = err;
+
+		path_size += sprintf(st->data + path_size, "/%s|", obj->name);
+
+		cmd->ext = path_size - 1; /* No | symbol */
+
+		if (target) {
+			err = pohmelfs_construct_path_string(target, st->data + path_size, st->size - path_size - 1);
+			if (err > 0)
+				path_size += err + 1;
+		}
+	}
+	mutex_unlock(&st->psb->path_lock);
+
+	if (err < 0)
+		goto err_out_unlock;
+
+	cmd->start = 0;
+
+	if (!target) {
+		if (tstr->len > st->size - path_size - 1) {
+			err = -ENAMETOOLONG;
+			goto err_out_unlock;
+		}
+
+		path_size += sprintf(st->data + path_size, "%s", tstr->name) + 1 /* 0-byte */;
+		cmd->start = 1;
+	}
+
+	dprintk("%s: parent: %llu, obj: '%s', target_inode: %llu, target_str: '%s', full: '%s'.\n",
+			__func__, parent->ino, obj->name, (target)?target->ino:0, (tstr)?tstr->name:NULL,
+			(char *)st->data);
+
+	cmd->cmd = NETFS_LINK;
+	cmd->size = path_size;
+	cmd->id = parent->ino;
+	netfs_convert_cmd(cmd);
+
+	err = netfs_data_send(st, cmd, sizeof(struct netfs_cmd), 1);
+	if (err)
+		goto err_out_unlock;
+
+	err = netfs_data_send(st, st->data, path_size, 0);
+	if (err)
+		goto err_out_unlock;
+
+	mutex_unlock(&st->state_lock);
+
+	return 0;
+
+err_out_unlock:
+	mutex_unlock(&st->state_lock);
+
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
+	return pohmelfs_create_link(POHMELFS_I(dir), &str, pi, NULL);
+}
+
+static int pohmelfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
+{
+	struct qstr sym_str;
+	struct qstr str = dentry->d_name;
+
+	str.hash = jhash(dentry->d_name.name, dentry->d_name.len, 0);
+
+	sym_str.name = symname;
+	sym_str.len = strlen(symname);
+
+	return pohmelfs_create_link(POHMELFS_I(dir), &str, NULL, &sym_str);
+}
+
+/*
+ * POHMELFS inode operations.
+ */
+const struct inode_operations pohmelfs_dir_inode_ops = {
+	.link	= pohmelfs_link,
+	.symlink= pohmelfs_symlink,
+	.unlink	= pohmelfs_unlink,
+	.mkdir	= pohmelfs_mkdir,
+	.rmdir	= pohmelfs_rmdir,
+	.create	= pohmelfs_create,
+	.lookup = pohmelfs_lookup,
+};
diff --git a/fs/pohmelfs/inode.c b/fs/pohmelfs/inode.c
new file mode 100644
index 0000000..3fb11ac
--- /dev/null
+++ b/fs/pohmelfs/inode.c
@@ -0,0 +1,1543 @@
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
+
+#include "netfs.h"
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
+ * Sync inode to server. If @wait is set, it will wait for acknowledge.
+ * Returns zero in success and negative error value otherwise.
+ * It will gather path to root directory into structures containing
+ * creation mode, permissions and names, so that the whole path
+ * to given inode could be created using only single network command.
+ */
+static int pohmelfs_write_inode_create(struct inode *inode, struct netfs_trans *trans, int wait)
+{
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	int err = -ENOMEM, size;
+	struct netfs_cmd *cmd;
+	void *data;
+	unsigned int cur_len = trans->data_size - netfs_trans_cur_len(trans);
+
+	dprintk("%s: started ino: %llu, wait: %d.\n", __func__, pi->ino, wait);
+
+	cmd = netfs_trans_add(trans, cur_len);
+	if (IS_ERR(cmd)) {
+		err = PTR_ERR(cmd);
+		goto err_out_exit;
+	}
+
+	data = (void *)(cmd + 1);
+
+	mutex_lock(&psb->path_lock);
+	err = pohmelfs_construct_path(pi, data, cur_len - sizeof(struct netfs_cmd));
+	mutex_unlock(&psb->path_lock);
+	if (err < 0)
+		goto err_out_unroll;
+
+	size = err;
+
+	netfs_trans_fixup_last(trans, size + sizeof(struct netfs_cmd) - cur_len);
+
+	if (size) {
+		cmd->start = 0;
+		cmd->cmd = NETFS_CREATE;
+		cmd->size = size;
+		cmd->id = pi->ino;
+		cmd->ext = !!wait;
+
+		netfs_convert_cmd(cmd);
+	}
+
+	dprintk("%s: completed ino: %llu, size: %d.\n", __func__, pi->ino, size);
+	return 0;
+
+err_out_unroll:
+	netfs_trans_fixup_last(trans, cur_len);
+err_out_exit:
+	clear_bit(NETFS_INODE_CREATED, &pi->state);
+	dprintk("%s: completed ino: %llu, err: %d.\n", __func__, pi->ino, err);
+	return err;
+}
+
+static void pohmelfs_write_trans_complete(struct netfs_trans *t, int err)
+{
+	unsigned i;
+
+	dprintk("%s: t: %p, trans_gen: %u, trans_size: %u, data_size: %u, trans_idx: %u, iovec_num: %u, err: %d.\n",
+		__func__, t, t->trans_gen, t->trans_size, t->data_size, t->trans_idx, t->iovec_num, err);
+
+	for (i = 0; i < t->iovec_num-1; i++) {
+		struct page *page = t->data[i+1];
+
+		if (!page)
+			continue;
+
+		dprintk("%s: completed page: %p, size: %lu.\n",
+				__func__, page, page_private(page));
+
+		if (err) {
+			SetPageDirty(page);
+			TestClearPageWriteback(page);
+		}
+		end_page_writeback(page);
+		kunmap(page);
+		page_cache_release(page);
+	}
+	netfs_trans_exit(t);
+}
+
+static int pohmelfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
+{
+	struct inode *inode = mapping->host;
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	struct netfs_state *st = pohmelfs_active_state(psb);
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	int ret = 0;
+	int done = 0;
+	int nr_pages;
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
+		unsigned int i = min(end - index, (pgoff_t)1024);
+		unsigned int cur_len, added = 0;
+		void *data;
+		struct netfs_cmd *cmd, *cmds;
+		struct netfs_trans *trans;
+
+		trans = netfs_trans_alloc_for_pages(i);
+		if (!trans) {
+			ret = -ENOMEM;
+			goto err_out_break;
+		}
+
+		cmds = (struct netfs_cmd *)(trans->data + trans->iovec_num);
+
+		nr_pages = find_get_pages_tag(mapping, &index,
+				PAGECACHE_TAG_DIRTY, trans->iovec_num-1, (struct page **)&trans->data[1]);
+
+		dprintk("%s: t: %p, nr_pages: %u, end: %lu, index: %lu, max: %u.\n",
+				__func__, trans, nr_pages, end, index, trans->iovec_num);
+
+		if (!nr_pages)
+			goto err_out_break;
+
+		trans->complete = &pohmelfs_write_trans_complete;
+
+		ret = netfs_trans_start_empty(trans, NETFS_TRANS_SYNC);
+		if (ret)
+			goto err_out_break;
+
+		cmd = netfs_trans_add(trans, sizeof(struct netfs_cmd));
+		if (IS_ERR(cmd)) {
+			ret = PTR_ERR(cmd);
+			goto err_out_reset;
+		}
+
+		trans->trans_size -= sizeof(struct netfs_cmd);
+
+		if (!test_bit(NETFS_INODE_CREATED, &pi->state)) {
+			ret = pohmelfs_write_inode_create(inode, trans, 0);
+			if (ret)
+				goto err_out_reset;
+		}
+
+		cur_len = trans->data_size - netfs_trans_cur_len(trans);
+
+		cmd = netfs_trans_add(trans, cur_len);
+		if (IS_ERR(cmd)) {
+			ret = PTR_ERR(cmd);
+			goto err_out_reset;
+		}
+
+		data = (void *)(cmd + 1);
+
+		mutex_lock(&psb->path_lock);
+		ret = pohmelfs_construct_path_string(pi, data, cur_len - sizeof(struct netfs_cmd));
+		mutex_unlock(&psb->path_lock);
+		if (ret < 0)
+			goto err_out_reset;
+
+		netfs_trans_fixup_last(trans, ret + 1 + sizeof(struct netfs_cmd) - cur_len);
+
+		cmd->id = pi->ino;
+		cmd->start = 0;
+		cmd->size = ret + 1;
+		cmd->cmd = NETFS_OPEN;
+		cmd->ext = O_RDWR;
+
+		netfs_convert_cmd(cmd);
+
+		ret = 0;
+
+		scanned = 1;
+		for (i = 0; i < nr_pages; i++) {
+			struct page *page = trans->data[i+1];
+			struct iovec *io;
+
+			lock_page(page);
+
+			if (unlikely(page->mapping != mapping)) {
+				dprintk("%s: page: %p, page_mapping: %p, mapping: %p.\n",
+						__func__, page, page->mapping, mapping);
+				continue;
+			}
+
+			if (!wbc->range_cyclic && page->index > end) {
+				done = 1;
+				dprintk("%s: false.\n", __func__);
+				continue;
+			}
+
+			if (wbc->sync_mode != WB_SYNC_NONE)
+				wait_on_page_writeback(page);
+
+			if (PageWriteback(page) ||
+			    !clear_page_dirty_for_io(page)) {
+				dprintk("%s: page: %p, writeback: %d.\n", __func__, page, PageWriteback(page));
+				continue;
+			}
+
+			set_page_writeback(page);
+			unlock_page(page);
+
+			cmd = &cmds[i];
+
+			cmd->id = pi->ino;
+			cmd->start = page->index << PAGE_CACHE_SHIFT;
+			cmd->size = page_private(page);
+			cmd->cmd = NETFS_WRITE_PAGE;
+			cmd->ext = 0;
+
+			trans->trans_size += cmd->size + sizeof(struct netfs_cmd);
+
+			netfs_convert_cmd(cmd);
+
+			io = &trans->iovec[++trans->trans_idx];
+			io->iov_len = sizeof(struct netfs_cmd);
+			io->iov_base = cmd;
+
+			io = &trans->iovec[++trans->trans_idx];
+			io->iov_len = page_private(page);
+			io->iov_base = kmap(page);
+
+			added++;
+
+			dprintk("%s: added trans: %p, idx: %u, page: %p, addr: %p [High: %d], size: %lu.\n",
+					__func__, trans, trans->trans_idx, page, io->iov_base,
+					!!PageHighMem(page), page_private(page));
+
+			if (ret || (--(wbc->nr_to_write) <= 0))
+				done = 1;
+			if (wbc->nonblocking && bdi_write_congested(bdi)) {
+				wbc->encountered_congestion = 1;
+				done = 1;
+			}
+		}
+
+		if (added) {
+			ret = netfs_trans_finish(trans, st);
+			if (ret)
+				netfs_trans_exit(trans);
+		} else {
+			netfs_trans_reset(trans);
+			netfs_trans_exit(trans);
+		}
+
+		if (ret)
+			break;
+
+		continue;
+
+err_out_reset:
+		netfs_trans_reset(trans);
+err_out_break:
+		netfs_trans_exit(trans);
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
+	dprintk("%s: range_cyclic: %d, range_whole: %d, nr_to_write: %lu, index: %lu, ret: %d.\n",
+			__func__, wbc->range_cyclic, range_whole, wbc->nr_to_write, index, ret);
+
+	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))
+		mapping->writeback_index = index;
+
+	if (!ret)
+		set_bit(NETFS_INODE_CREATED, &pi->state);
+	return ret;
+}
+
+/*
+ * Removes given child from given inode on server.
+ */
+static int pohmelfs_remove_child(struct pohmelfs_inode *parent, struct pohmelfs_name *n)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(parent->vfs_inode.i_sb);
+	struct netfs_state *st = pohmelfs_active_state(psb);
+	int err, path_size;
+	struct netfs_cmd *cmd = &st->cmd;
+
+	mutex_lock(&st->state_lock);
+	mutex_lock(&psb->path_lock);
+	err = pohmelfs_construct_path_string(parent, st->data, st->size - n->len);
+	mutex_unlock(&psb->path_lock);
+	if (err < 0)
+		goto err_out_unlock;
+
+	path_size = err + sprintf(st->data + err, "/%s", n->data) + 1 /* 0-byte */;
+
+	dprintk("%s: dir: %llu, ino: %llu, path: '%s', len: %d, mode: %o, dir: %d.\n",
+			__func__, parent->ino, n->ino, (char *)st->data, path_size,
+			n->mode, S_ISDIR(n->mode));
+
+	cmd->cmd = NETFS_REMOVE;
+	cmd->id = n->ino;
+	cmd->start = parent->ino;
+	cmd->size = path_size;
+	cmd->ext = S_ISDIR(n->mode);
+
+	netfs_convert_cmd(cmd);
+
+	err = netfs_data_send(st, cmd, sizeof(struct netfs_cmd), 1);
+	if (err)
+		goto err_out_unlock;
+
+	err = netfs_data_send(st, st->data, path_size, 0);
+	if (err)
+		goto err_out_unlock;
+
+	mutex_unlock(&st->state_lock);
+
+	return 0;
+
+err_out_unlock:
+	mutex_unlock(&st->state_lock);
+
+	return err;
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
+	dprintk("%s: parent: %llu, del_list_empty: %d.\n",
+			__func__, pi->ino, list_empty(&pi->sync_del_list));
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
+ * Writeback for given inode.
+ */
+static int pohmelfs_write_inode(struct inode *inode, int sync)
+{
+	int err = 0;
+
+	dprintk("%s: started ino: %llu.\n", __func__, POHMELFS_I(inode)->ino);
+
+	if (!test_bit(NETFS_INODE_CREATED, &POHMELFS_I(inode)->state)) {
+		struct netfs_state *st = pohmelfs_active_state(POHMELFS_SB(inode->i_sb));
+		struct netfs_trans *trans = st->trans;
+
+		err = netfs_trans_start(trans, NETFS_TRANS_SYNC);
+		if (err)
+			goto out;
+
+		err = pohmelfs_write_inode_create(inode, trans, sync);
+		if (err) {
+			netfs_trans_reset(trans);
+			goto out;
+		}
+
+		err = netfs_trans_finish(trans, st);
+		if (err)
+			goto out;
+		set_bit(NETFS_INODE_CREATED, &POHMELFS_I(inode)->state);
+
+out:
+		netfs_trans_exit(trans);
+	}
+
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
+/*
+ * Read/write page request to remote server.
+ * If @wait is set and page is locked, it will wait until page is unlocked.
+ */
+static int netfs_process_page(struct page *page, __u32 cmd_op, __u32 size, int wait)
+{
+	struct inode *inode = page->mapping->host;
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	struct netfs_state *st = pohmelfs_active_state(psb);
+	struct netfs_cmd *cmd = &st->cmd;
+	int err, path_size;
+
+	if (unlikely(!size)) {
+		SetPageUptodate(page);
+		unlock_page(page);
+		return 0;
+	}
+
+#if 0
+	{
+		SetPageUptodate(page);
+		unlock_page(page);
+		return 0;
+	}
+#endif
+
+	mutex_lock(&st->state_lock);
+
+	mutex_lock(&psb->path_lock);
+	err = pohmelfs_construct_path_string(pi, st->data, st->size);
+	mutex_unlock(&psb->path_lock);
+	if (err < 0)
+		goto err_out_unlock;
+
+	path_size = err + 1;
+
+	cmd->id = pi->ino;
+	cmd->start = page->index << PAGE_CACHE_SHIFT;
+	cmd->size = size + path_size;
+	cmd->cmd = cmd_op;
+	cmd->ext = path_size;
+
+	dprintk("%s: path: '%s', page: %p, ino: %llu, start: %llu, idx: %lu, cmd: %u, size: %u.\n",
+			__func__, (char *)st->data, page, pi->ino, cmd->start, page->index, cmd_op, size);
+
+	netfs_convert_cmd(cmd);
+
+	err = netfs_data_send(st, cmd, sizeof(struct netfs_cmd), 1);
+	if (err)
+		goto err_out_unlock;
+
+	err = netfs_data_send(st, st->data, path_size, cmd_op == NETFS_WRITE_PAGE);
+	if (err)
+		goto err_out_unlock;
+
+	if (cmd_op == NETFS_WRITE_PAGE) {
+		err = kernel_sendpage(st->socket, page, 0, size, MSG_WAITALL | MSG_NOSIGNAL);
+		if (err < 0)
+			goto err_out_unlock;
+
+		SetPageUptodate(page);
+		unlock_page(page);
+
+		mutex_unlock(&st->state_lock);
+
+		return 0;
+	}
+
+	mutex_unlock(&st->state_lock);
+
+	err = 0;
+	if (wait && TestSetPageLocked(page)) {
+		long ret = msecs_to_jiffies(5000);
+		DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+
+		for (;;) {
+			prepare_to_wait(page_waitqueue(page), &wait.wait, TASK_INTERRUPTIBLE);
+
+			dprintk("%s: page: %p, locked: %d, uptodate: %d, error: %d.\n",
+					__func__, page, PageLocked(page), PageUptodate(page),
+					PageError(page));
+
+			if (!PageLocked(page))
+				break;
+
+			if (!signal_pending(current)) {
+				ret = schedule_timeout(ret);
+				if (!ret)
+					break;
+				continue;
+			}
+			ret = -ERESTARTSYS;
+			break;
+		}
+		finish_wait(page_waitqueue(page), &wait.wait);
+
+		if (!ret)
+			err = -ETIMEDOUT;
+
+		dprintk("%s: page: %p, uptodate: %d, locked: %d, err: %d.\n",
+				__func__, page, PageUptodate(page), PageLocked(page), err);
+
+		if (!PageUptodate(page))
+			err = -EIO;
+
+		if (PageLocked(page))
+			unlock_page(page);
+	}
+
+	return err;
+
+err_out_unlock:
+	mutex_unlock(&st->state_lock);
+
+	SetPageError(page);
+	unlock_page(page);
+
+	dprintk("%s: page: %p, start: %llu/%llx, size: %u, err: %d.\n",
+			__func__, page, cmd->start, cmd->start, cmd->size, err);
+
+	return err;
+}
+
+static int pohmelfs_readpage(struct file *file, struct page *page)
+{
+	ClearPageChecked(page);
+	return netfs_process_page(page, NETFS_READ_PAGE, PAGE_CACHE_SIZE, 1);
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
+	dprintk("%s: page: %p pos: %llu, len: %u, index: %lu, start: %u, end: %u.\n",
+			__func__, page,	pos, len, index, start, end);
+	if (!page) {
+		err = -ENOMEM;
+		goto err_out_exit;
+	}
+
+	if (!PageUptodate(page)) {
+		if (start && test_bit(NETFS_INODE_CREATED, &POHMELFS_I(inode)->state)) {
+			err = pohmelfs_readpage(file, page);
+			if (err)
+				goto err_out_exit;
+
+			lock_page(page);
+		}
+
+		if (len != PAGE_CACHE_SIZE) {
+			void *kaddr = kmap_atomic(page, KM_USER0);
+
+			memset(kaddr + start, 0, PAGE_CACHE_SIZE - start);
+			flush_dcache_page(page);
+			kunmap_atomic(kaddr, KM_USER0);
+		}
+	}
+
+	set_page_private(page, end);
+
+	*pagep = page;
+
+	return 0;
+
+err_out_exit:
+	ClearPageUptodate(page);
+	if (PageLocked(page))
+		unlock_page(page);
+	page_cache_release(page);
+	*pagep = NULL;
+
+	if (pos + len > inode->i_size)
+		vmtruncate(inode, inode->i_size);
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
+	if (!PageUptodate(page))
+		SetPageUptodate(page);
+	set_page_dirty(page);
+
+	dprintk("%s: page: %p [U: %d, D: %dd, L: %d], pos: %llu, len: %u, copied: %u.\n",
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
+/*
+ * Small addres space operations for POHMELFS.
+ */
+const struct address_space_operations pohmelfs_aops = {
+	.readpage		= pohmelfs_readpage,
+	.writepages		= pohmelfs_writepages,
+	.write_begin		= pohmelfs_write_begin,
+	.write_end		= pohmelfs_write_end,
+	.set_page_dirty 	= __set_page_dirty_nobuffers,
+};
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
+	mutex_lock(&psb->path_lock);
+	list_del_init(&pi->inode_entry);
+	mutex_unlock(&psb->path_lock);
+
+	dprintk("%s: inode: %p, vfs_inode: %p.\n",
+			__func__, pi, inode);
+	pohmelfs_inode_del_inode(psb, pi);
+	kmem_cache_free(pohmelfs_inode_cache, POHMELFS_I(inode));
+
+	dprintk("%s: completed inode: %p, vfs_inode: %p.\n",
+			__func__, pi, inode);
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
+	dprintk("%s: inode: %p, vfs_inode: %p.\n",
+			__func__, pi, &pi->vfs_inode);
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
+
+	return &pi->vfs_inode;
+}
+
+/*
+ * Here starts async POHMELFS reading magic.
+ * It is pretty trivial though.
+ * This actor just copies data to userspace.
+ */
+static int pohmelfs_file_read_actor(char __user *buf, struct page *page,
+			unsigned long offset, unsigned long size)
+{
+	char *kaddr;
+	unsigned long left;
+	int error, num = 10;
+
+	do {
+		error = 0;
+		/*
+		 * Faults on the destination of a read are common, so do it before
+		 * taking the kmap.
+		 */
+		if (!fault_in_pages_writeable(buf, size)) {
+			kaddr = kmap_atomic(page, KM_USER0);
+			left = __copy_to_user_inatomic(buf, kaddr + offset, size);
+			kunmap_atomic(kaddr, KM_USER0);
+			if (left == 0)
+				break;
+		}
+
+		/* Do it the slow way */
+		kaddr = kmap(page);
+		left = __copy_to_user(buf, kaddr + offset, size);
+		kunmap(page);
+
+		if (left)
+			error = -EFAULT;
+
+		dprintk("%s: page: %p, buf: %p, size: %lu, left: %lu, num: %d, err: %d.\n",
+				__func__, page, buf, size, left, num, error);
+
+		offset += size - left;
+		buf += size - left;
+		size = left;
+	} while (size && --num);
+
+	dprintk("%s: completed: page: %p, size: %lu, left: %lu, err: %d.\n",
+			__func__, page, size, left, error);
+
+	return error;
+}
+
+/*
+ * When page is not uptodate, it is queued to be completed when data is received from
+ * remote server. This shared info sructure holds that pages. When all pages are
+ * processed it has to be freed, which is done here.
+ */
+void pohmelfs_put_shared_info(struct pohmelfs_shared_info *sh)
+{
+	dprintk("%s: completed: %d, scheduled: %d.\n",
+		__func__, atomic_read(&sh->pages_completed), sh->pages_scheduled);
+
+	if (atomic_inc_return(&sh->pages_completed) == sh->pages_scheduled) {
+		dprintk("%s: freeing shared info.\n", __func__);
+
+		BUG_ON(!list_empty(&sh->page_list));
+		kfree(sh);
+	}
+}
+
+/*
+ * Simple async reading magic.
+ * If page is uptodate, it is copied to userspace, otherwise request is being sent
+ * to the server. This is done for all pages.
+ *
+ * When requests are received by async thread, this (now sync) thread awakes (at the very
+ * end) and copies data to userspace. There is a work in progress for async copy from
+ * receiving thread to 'our' userspace via copy_to_user(), so far it does not work
+ * reliably.
+ */
+static void pohmelfs_file_read(struct file *file, loff_t *ppos,
+		read_descriptor_t *desc)
+{
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	struct netfs_state *st = pohmelfs_active_state(psb);
+	pgoff_t index;
+	unsigned long offset;      /* offset into pagecache page */
+	int err;
+	struct pohmelfs_shared_info *sh = NULL;
+	unsigned long nr = PAGE_CACHE_SIZE;
+
+	index = *ppos >> PAGE_CACHE_SHIFT;
+	offset = *ppos & ~PAGE_CACHE_MASK;
+
+	while (desc->count && nr == PAGE_CACHE_SIZE) {
+		struct page *page;
+		pgoff_t end_index;
+		loff_t isize;
+
+		nr = PAGE_CACHE_SIZE;
+
+		dprintk("%s: index: %lu, count: %zu, written: %zu.\n", __func__, index, desc->count, desc->written);
+
+		isize = i_size_read(inode);
+		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+		if (unlikely(!isize || index > end_index))
+			break;
+
+		/* nr is the maximum number of bytes to copy from this page */
+		if (index == end_index) {
+			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
+			if (nr <= offset)
+				break;
+		}
+		nr = nr - offset;
+
+repeat:
+		page = find_get_page(mapping, index);
+		if (!page) {
+			page = page_cache_alloc_cold(mapping);
+			if (!page) {
+				desc->error = -ENOMEM;
+				break;
+			}
+
+			err = add_to_page_cache(page, mapping, index, GFP_NOIO);
+			if (unlikely(err)) {
+				page_cache_release(page);
+				if (err == -EEXIST)
+					goto repeat;
+				desc->error = err;
+				break;
+			}
+			//lru_cache_add(page);
+
+			goto readpage;
+		}
+
+		dprintk("%s: file: %p, page: %p [U: %d, L: %d], buf: %p, offset: %lu, index: %lu, nr: %lu, count: %zu, written: %zu.\n",
+				__func__, file, page, PageUptodate(page), PageLocked(page), desc->arg.buf,
+				offset, index, nr, desc->count, desc->written);
+
+		if (PageUptodate(page)) {
+page_ok:
+			/* If users can be writing to this page using arbitrary
+			 * virtual addresses, take care about potential aliasing
+			 * before reading the page on the kernel side.
+			 */
+			if (mapping_writably_mapped(mapping))
+				flush_dcache_page(page);
+
+			mark_page_accessed(page);
+
+			/*
+			 * Ok, we have the page, and it's up-to-date, so
+			 * now we can copy it to user space...
+			 */
+			err = pohmelfs_file_read_actor(desc->arg.buf, page, offset, nr);
+			page_cache_release(page);
+			if (err) {
+				desc->error = err;
+				break;
+			}
+		} else {
+			struct pohmelfs_page_private *priv;
+
+#if 0
+			/*
+			 * Waiting for __lock_page_killable to be exported.
+			 */
+			if (lock_page_killable(page)) {
+				err = -EIO;
+				goto readpage_error;
+			}
+#else
+			lock_page(page);
+#endif
+			if (PageUptodate(page)) {
+				unlock_page(page);
+				goto page_ok;
+			}
+
+			if (!page->mapping) {
+				unlock_page(page);
+				page_cache_release(page);
+				break;
+			}
+
+readpage:
+			if (unlikely(!sh)) {
+				sh = kzalloc(sizeof(struct pohmelfs_shared_info), GFP_NOFS);
+				if (!sh) {
+					desc->error = -ENOMEM;
+					page_cache_release(page);
+					break;
+				}
+				sh->pages_scheduled = 1;
+				atomic_set(&sh->pages_completed, 0);
+				INIT_LIST_HEAD(&sh->page_list);
+				mutex_init(&sh->page_lock);
+			}
+
+			priv = kmalloc(sizeof(struct pohmelfs_page_private), GFP_NOFS);
+			if (!priv) {
+				desc->error = -ENOMEM;
+				page_cache_release(page);
+				break;
+			}
+
+			priv->buf = desc->arg.buf;
+			priv->offset = offset;
+			priv->nr = nr;
+			priv->shared = sh;
+			priv->private = page_private(page);
+			priv->page = page;
+
+			set_page_private(page, (unsigned long)priv);
+			SetPageChecked(page);
+
+			sh->pages_scheduled++;
+			err = netfs_process_page(page, NETFS_READ_PAGE, nr, 0);
+			if (unlikely(err)) {
+				desc->error = err;
+				sh->pages_scheduled--;
+				page_cache_release(page);
+				break;
+			}
+
+			dprintk("%s: page: %p, completed: %d, scheduled: %d.\n",
+				__func__, page, atomic_read(&sh->pages_completed), sh->pages_scheduled);
+		}
+
+		desc->count -= nr;
+		desc->written += nr;
+		desc->arg.buf += nr;
+
+		offset += nr;
+		index += offset >> PAGE_CACHE_SHIFT;
+		offset &= ~PAGE_CACHE_MASK;
+
+		dprintk("%s: count: %zu, written: %zu, nr: %lu.\n", __func__, desc->count, desc->written, nr);
+	}
+
+	*ppos = ((loff_t)index << PAGE_CACHE_SHIFT) + offset;
+	if (file)
+		file_accessed(file);
+
+	if (sh) {
+		struct pohmelfs_page_private *p;
+
+		dprintk("%s: completed: %d, scheduled: %d.\n",
+			__func__, atomic_read(&sh->pages_completed), sh->pages_scheduled);
+
+		while (!sh->freeing) {
+			wait_event_interruptible(st->thread_wait,
+				(atomic_read(&sh->pages_completed) == sh->pages_scheduled - 1) ||
+				!list_empty(&sh->page_list));
+
+			dprintk("%s: completed: %d, scheduled: %d, signal: %d.\n",
+				__func__, atomic_read(&sh->pages_completed), sh->pages_scheduled, signal_pending(current));
+
+			if (signal_pending(current)) {
+				mutex_lock(&sh->page_lock);
+				sh->freeing = 1;
+				mutex_unlock(&sh->page_lock);
+			}
+
+			while (!list_empty(&sh->page_list)) {
+				mutex_lock(&sh->page_lock);
+				p = list_entry(sh->page_list.next, struct pohmelfs_page_private,
+						page_entry);
+				list_del(&p->page_entry);
+				mutex_unlock(&sh->page_lock);
+
+				err = pohmelfs_file_read_actor(p->buf, p->page, p->offset, p->nr);
+
+				if (err)
+					SetPageError(p->page);
+				else
+					SetPageUptodate(p->page);
+
+				unlock_page(p->page);
+				page_cache_release(p->page);
+				kfree(p);
+			}
+
+			if (atomic_read(&sh->pages_completed) == sh->pages_scheduled - 1)
+				sh->freeing = 1;
+		}
+
+		pohmelfs_put_shared_info(sh);
+	}
+}
+
+/*
+ * ->aio_read() callback. Just runs over segments and tries to read data.
+ */
+static ssize_t pohmelfs_aio_read(struct kiocb *iocb, const struct iovec *iov,
+		unsigned long nr_segs, loff_t pos)
+{
+	struct file *file = iocb->ki_filp;
+	ssize_t retval;
+	unsigned long seg;
+	size_t count;
+	loff_t *ppos = &iocb->ki_pos;
+
+	count = 0;
+	retval = generic_segment_checks(iov, &nr_segs, &count, VERIFY_WRITE);
+	if (retval)
+		return retval;
+
+	dprintk("%s: nr_segs: %lu, count: %zu.\n", __func__, nr_segs, count);
+	retval = 0;
+	if (count) {
+		for (seg = 0; seg < nr_segs; seg++) {
+			read_descriptor_t desc;
+
+			desc.written = 0;
+			desc.arg.buf = iov[seg].iov_base;
+			desc.count = iov[seg].iov_len;
+			if (desc.count == 0)
+				continue;
+			desc.error = 0;
+			pohmelfs_file_read(file, ppos, &desc);
+			retval += desc.written;
+			if (desc.error) {
+				retval = retval ?: desc.error;
+				break;
+			}
+
+			dprintk("%s: count: %zu, written: %zu, retval: %zu.\n", __func__, desc.count, desc.written, retval);
+			if (desc.count > 0)
+				break;
+		}
+	}
+
+	dprintk("%s: returning %zu.\n", __func__, retval);
+	return retval;
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
+	.fsync		= pohmelfs_fsync,
+
+	.llseek		= generic_file_llseek,
+
+	.read		= do_sync_read,
+	.aio_read	= pohmelfs_aio_read,
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
+/*
+ * Fill inode data: mode, size, operation callbacks and so on...
+ */
+void pohmelfs_fill_inode(struct pohmelfs_inode *pi, struct netfs_inode_info *info)
+{
+	struct inode *inode = &pi->vfs_inode;
+
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
+/*
+ * ->put_super() callback. Invoked before superblock is destroyed,
+ *  so it has to clean all private data.
+ */
+static void pohmelfs_put_super(struct super_block *sb)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(sb);
+	struct rb_node *rb_node;
+	struct pohmelfs_path_entry *e;
+	struct pohmelfs_inode *pi, *tmp;
+	struct netfs_trans *t;
+
+	for (rb_node = rb_first(&psb->path_root); rb_node; ) {
+		e = rb_entry(rb_node, struct pohmelfs_path_entry, path_entry);
+		rb_node = rb_next(rb_node);
+
+		pohmelfs_remove_path_entry(psb, e);
+	}
+
+	list_for_each_entry_safe(pi, tmp, &psb->inode_list, inode_entry) {
+		list_del_init(&pi->inode_entry);
+
+		iput(&pi->vfs_inode);
+	}
+
+	pohmelfs_state_exit(psb);
+
+	psb->trans_timeout = 0;
+	cancel_rearming_delayed_work(&psb->dwork);
+	flush_scheduled_work();
+
+	for (rb_node = rb_first(&psb->trans_root); rb_node; ) {
+		t = rb_entry(rb_node, struct netfs_trans, trans_entry);
+		rb_node = rb_next(rb_node);
+
+		rb_erase(&t->trans_entry, &psb->trans_root);
+		netfs_trans_exit(t);
+	}
+
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
+	buf->f_type = 0x504f482e; /* 'POH.' */
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
+	seq_printf(seq, ",trans_data_size=%u", psb->trans_data_size);
+	seq_printf(seq, ",trans_iovec_num=%u", psb->trans_iovec_num);
+
+	return 0;
+}
+
+static const struct super_operations pohmelfs_sb_ops = {
+	.alloc_inode	= pohmelfs_alloc_inode,
+	.destroy_inode	= pohmelfs_destroy_inode,
+	.write_inode	= pohmelfs_write_inode,
+	.put_super	= pohmelfs_put_super,
+	.remount_fs	= pohmelfs_remount,
+	.statfs		= pohmelfs_statfs,
+	.show_options	= pohmelfs_show_options,
+};
+
+enum {
+	pohmelfs_opt_idx,
+	pohmelfs_opt_trans_data_size,
+	pohmelfs_opt_trans_iovec_num,
+	pohmelfs_opt_trans_timeout,
+};
+
+static struct match_token pohmelfs_tokens[] = {
+	{pohmelfs_opt_idx, "idx=%u"},
+	{pohmelfs_opt_trans_data_size, "trans_data_size=%u"},
+	{pohmelfs_opt_trans_iovec_num, "trans_iovec_num=%u"},
+	{pohmelfs_opt_trans_timeout, "trans_timeout=%u"},
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
+		switch (token) {
+			case pohmelfs_opt_idx:
+				err = match_int(&args[0], &option);
+				if (err)
+					return err;
+				psb->idx = option;
+				break;
+			case pohmelfs_opt_trans_data_size:
+				err = match_int(&args[0], &option);
+				if (err)
+					return err;
+				psb->trans_data_size = option;
+				break;
+			case pohmelfs_opt_trans_iovec_num:
+				err = match_int(&args[0], &option);
+				if (err)
+					return err;
+				psb->trans_iovec_num = option;
+				break;
+			case pohmelfs_opt_trans_timeout:
+				err = match_int(&args[0], &option);
+				if (err)
+					return err;
+				psb->trans_timeout = option;
+				break;
+			default:
+				return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
+static void pohmelfs_trans_scan(struct work_struct *work)
+{
+	struct pohmelfs_sb *psb =
+		container_of(work, struct pohmelfs_sb, dwork.work);
+	unsigned int timeout = msecs_to_jiffies(psb->trans_timeout);
+	struct rb_node *rb_node;
+	struct netfs_trans *t;
+	int err;
+
+	if (!timeout)
+		return;
+
+	mutex_lock(&psb->trans_lock);
+	for (rb_node = rb_first(&psb->trans_root); rb_node; ) {
+		t = rb_entry(rb_node, struct netfs_trans, trans_entry);
+		rb_node = rb_next(rb_node);
+
+		if (time_after(t->send_time + timeout, jiffies))
+			break;
+
+		err = netfs_trans_finish_send(t, NULL, psb);
+		if (err) {
+			/*
+			 * Can not send transaction to any server
+			 * Completion callback can mark pages as
+			 * dirty or whatever we want...
+			 * Writeback callback even does that :)
+			 */
+
+			rb_erase(&t->trans_entry, &psb->trans_root);
+
+			if (t->complete)
+				t->complete(t, err);
+			netfs_trans_exit(t);
+		}
+	}
+	mutex_unlock(&psb->trans_lock);
+
+	schedule_delayed_work(&psb->dwork, msecs_to_jiffies(psb->trans_timeout));
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
+
+	psb->sb = sb;
+	psb->path_root = RB_ROOT;
+
+	psb->ino = 2;
+	psb->idx = 0;
+	psb->trans_data_size = PAGE_SIZE;
+	psb->trans_iovec_num = 32;
+	psb->trans_timeout = 5000;
+
+	mutex_init(&psb->path_lock);
+	INIT_LIST_HEAD(&psb->inode_list);
+
+	mutex_init(&psb->trans_lock);
+	psb->trans_root = RB_ROOT;
+	atomic_set(&psb->trans_gen, 1);
+
+	mutex_init(&psb->state_lock);
+	INIT_LIST_HEAD(&psb->state_list);
+
+	err = pohmelfs_parse_options((char *) data, psb);
+	if (err)
+		goto err_out_free_sb;
+
+	err = pohmelfs_state_init(psb);
+	if (err)
+		goto err_out_free_sb;
+
+	str.name = "/";
+	str.hash = jhash("/", 1, 0);
+	str.len = 1;
+
+	npi = pohmelfs_create_entry_local(psb, NULL, &str, 0, 0755|S_IFDIR);
+	if (IS_ERR(npi)) {
+		err = PTR_ERR(npi);
+		goto err_out_state_exit;
+	}
+	set_bit(NETFS_INODE_CREATED, &npi->state);
+
+	root = &npi->vfs_inode;
+
+	sb->s_root = d_alloc_root(root);
+	if (!sb->s_root)
+		goto err_out_put_root;
+
+	INIT_DELAYED_WORK(&psb->dwork, pohmelfs_trans_scan);
+	schedule_delayed_work(&psb->dwork, msecs_to_jiffies(psb->trans_timeout));
+
+	return 0;
+
+err_out_put_root:
+	iput(root);
+err_out_state_exit:
+	pohmelfs_state_exit(psb);
+err_out_free_sb:
+	kfree(psb);
+err_out_exit:
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
+	err = register_filesystem(&pohmel_fs_type);
+	if (err)
+		goto err_out_destroy;
+
+	return 0;
+
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
index 0000000..1840bfc
--- /dev/null
+++ b/fs/pohmelfs/net.c
@@ -0,0 +1,800 @@
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
+#include <linux/types.h>
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
+int netfs_data_recv(struct netfs_state *st, void *buf, u64 size)
+{
+	struct msghdr msg;
+	struct kvec iov;
+	int err, error = 0;
+
+	BUG_ON(!size);
+
+	if (!st->socket) {
+		err = netfs_state_init(st);
+		if (err)
+			return err;
+	}
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
+	msg.msg_flags = MSG_WAITALL;
+
+	err = kernel_recvmsg(st->socket, &msg, &iov, 1, iov.iov_len,
+			msg.msg_flags);
+	if (err <= 0) {
+		error = err;
+		printk("%s: failed to recv data: size: %llu, err: %d.\n", __func__, size, err);
+		if (err == 0)
+			error = -ECONNRESET;
+
+		netfs_state_exit(st);
+	}
+
+	return error;
+}
+
+int netfs_data_send(struct netfs_state *st, void *buf, u64 size, int more)
+{
+	struct msghdr msg;
+	struct kvec iov;
+	int err, error = 0;
+
+	BUG_ON(!size);
+
+	if (!st->socket) {
+		err = netfs_state_init(st);
+		if (err)
+			return err;
+	}
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
+	msg.msg_flags = MSG_WAITALL;
+
+	if (more)
+		msg.msg_flags |= MSG_MORE;
+
+	err = kernel_sendmsg(st->socket, &msg, &iov, 1, iov.iov_len);
+	if (err <= 0) {
+		error = err;
+		printk("%s: failed to send data: size: %llu, err: %d.\n", __func__, size, err);
+		if (err == 0)
+			error = -ECONNRESET;
+
+		netfs_state_exit(st);
+	}
+
+	return error;
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
+	return 0;
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
+	struct inode *inode;
+	struct page *page;
+	void *addr;
+	struct netfs_cmd *cmd = &st->cmd;
+	int err = 0;
+
+	if (cmd->size > PAGE_CACHE_SIZE) {
+		err = -EINVAL;
+		goto err_out_exit;
+	}
+
+	inode = ilookup(st->psb->sb, cmd->id);
+	if (!inode) {
+		dprintk("%s: failed to find inode: id: %llu.\n", __func__, cmd->id);
+		err = -ENOENT;
+		goto err_out_exit;
+	}
+
+	page = find_get_page(inode->i_mapping, cmd->start >> PAGE_CACHE_SHIFT);
+	if (!page) {
+		dprintk("%s: failed to find page: id: %llu, start: %llu, index: %llu.\n",
+				__func__, cmd->id, cmd->start, cmd->start >> PAGE_CACHE_SHIFT);
+		err = -ENOENT;
+		goto err_out_put;
+	}
+
+	if (cmd->size) {
+		addr = kmap(page);
+		err = netfs_data_recv(st, addr, cmd->size);
+		kunmap(page);
+	}
+
+	dprintk("%s: page: %p, size: %u, err: %d, lru: %p.%p.%p.\n",
+			__func__, page, cmd->size, err,
+			page->lru.prev, page->lru.next, &page->lru);
+
+	if (PageChecked(page)) {
+		struct pohmelfs_page_private *priv = (struct pohmelfs_page_private *)page_private(page);
+		struct pohmelfs_shared_info *sh = priv->shared;
+
+		set_page_private(page, priv->private);
+
+		if (mapping_writably_mapped(inode->i_mapping))
+			flush_dcache_page(page);
+		mark_page_accessed(page);
+		ClearPageChecked(page);
+
+		dprintk("%s: page: %p, completed: %d, scheduled: %d.\n",
+				__func__, page, atomic_read(&sh->pages_completed),
+				sh->pages_scheduled);
+
+		mutex_lock(&sh->page_lock);
+		if (likely(!err && !sh->freeing)) {
+			list_add_tail(&priv->page_entry, &sh->page_list);
+		} else {
+			SetPageError(page);
+			SetPageUptodate(page);
+			unlock_page(page);
+			page_cache_release(page);
+			kfree(priv);
+		}
+		mutex_unlock(&sh->page_lock);
+
+		pohmelfs_put_shared_info(sh);
+		wake_up(&st->thread_wait);
+	} else {
+		SetPageUptodate(page);
+		unlock_page(page);
+	}
+
+	if (err)
+		goto err_out_release;
+
+	page_cache_release(page);
+
+	iput(inode);
+
+	return 0;
+
+err_out_release:
+	SetPageError(page);
+	unlock_page(page);
+	page_cache_release(page);
+err_out_put:
+	iput(inode);
+err_out_exit:
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
+	int err = 0;
+	struct qstr str;
+
+	if (cmd->size > st->size)
+		return -EINVAL;
+
+	if (!cmd->size && cmd->start)
+		return -cmd->start;
+
+	inode = ilookup(st->psb->sb, cmd->id);
+	if (!inode)
+		return -ENOENT;
+
+	parent = POHMELFS_I(inode);
+
+	if (cmd->size) {
+		err = netfs_data_recv(st, st->data, cmd->size);
+		if (err)
+			goto err_out_put;
+
+		info = (struct netfs_inode_info *)(st->data);
+
+		str.name = (char *)(info + 1);
+		str.len = cmd->size - sizeof(struct netfs_inode_info) - 1;
+		str.hash = jhash(str.name, str.len, 0);
+
+		netfs_convert_inode_info(info);
+
+		info->ino = cmd->start;
+		if (!info->ino)
+			info->ino = st->psb->ino++;
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
+		} else
+			set_bit(NETFS_INODE_CREATED, &npi->state);
+	}
+
+	if (cmd->ext) {
+		set_bit(NETFS_INODE_REMOTE_SYNCED, &parent->state);
+		wake_up(&st->thread_wait);
+	}
+	iput(inode);
+
+	return 0;
+
+err_out_put:
+	clear_bit(NETFS_INODE_REMOTE_SYNCED, &parent->state);
+	iput(inode);
+	wake_up(&st->thread_wait);
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
+	if (cmd->size > st->size)
+		goto err_out_exit;
+
+	inode = ilookup(st->psb->sb, cmd->id);
+	if (!inode) {
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
+	err = netfs_data_recv(st, st->data, cmd->size);
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
+		info->ino = st->psb->ino++;
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
+		str.len = cmd->size - sizeof(struct netfs_inode_info) - 1;
+		str.hash = jhash(name, str.len, 0);
+
+		npi = pohmelfs_new_inode(st->psb, parent, &str, info, 0);
+	}
+	if (IS_ERR(npi)) {
+		err = PTR_ERR(npi);
+
+		if (err != -EEXIST)
+			goto err_out_put;
+	}
+
+	clear_bit(NETFS_COMMAND_PENDING, &parent->state);
+
+	set_bit(NETFS_INODE_CREATED, &npi->state);
+	iput(inode);
+
+	wake_up(&st->thread_wait);
+
+	return 0;
+
+err_out_put:
+	clear_bit(NETFS_COMMAND_PENDING, &parent->state);
+	iput(inode);
+err_out_exit:
+	wake_up(&st->thread_wait);
+	dprintk("%s: inode: %p, id: %llu, start: %llu, size: %u, err: %d.\n",
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
+		dprintk("%s: failed to find inode: id: %llu.\n", __func__, cmd->id);
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
+	iput(inode);
+
+	wake_up(&st->thread_wait);
+	return 0;
+
+err_out_exit:
+	wake_up(&st->thread_wait);
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
+	if (cmd->size > st->size) {
+		dprintk("%s: wrong data size: %u.\n", __func__, cmd->size);
+		return -EINVAL;
+	}
+
+	err = netfs_data_recv(st, st->data, cmd->size);
+	if (err)
+		return err;
+
+	dprintk("%s: parent: %llu, path: '%s'.\n", __func__, cmd->id, (char *)st->data);
+
+	return 0;
+}
+
+/*
+ * Transaction reply message.
+ */
+static int pohmelfs_transaction_response(struct netfs_state *st)
+{
+	struct netfs_trans *t;
+	struct netfs_cmd *cmd = &st->cmd;
+
+	t = netfs_trans_search(st->psb, cmd->start);
+	if (!t)
+		return -EINVAL;
+
+	if (t->trans_idx != cmd->id)
+		return -EINVAL;
+
+	dprintk("%s: sync transaction reply: t: %p, refcnt: %d, idx: %u, gen: %u, flags: %x, err: %d.\n",
+			__func__, t, atomic_read(&t->refcnt), t->trans_idx, t->trans_gen, t->flags, -cmd->ext);
+	t->trans_idx = cmd->ext;
+
+	t->flags &= ~NETFS_TRANS_SYNC;
+
+	netfs_trans_remove(t, st->psb);
+
+	if (t->complete)
+		t->complete(t, -t->trans_idx);
+	netfs_trans_exit(t);
+
+	wake_up(&st->thread_wait);
+
+	return 0;
+}
+
+/*
+ * Main receiving function, called from dedicated kernel thread.
+ */
+static int pohmelfs_recv(void *data)
+{
+	int err = -EINTR;
+	struct netfs_state *st = data;
+	unsigned int revents;
+	struct netfs_cmd *cmd = &st->cmd;
+
+	while (!kthread_should_stop()) {
+		DEFINE_WAIT(wait);
+
+		revents = 0;
+		for (;;) {
+			prepare_to_wait(&st->thread_wait, &wait, TASK_INTERRUPTIBLE);
+			if (kthread_should_stop())
+				break;
+
+			mutex_lock(&st->state_lock);
+			if (st->socket)
+				revents = st->socket->ops->poll(NULL, st->socket, NULL);
+			mutex_unlock(&st->state_lock);
+
+			if (revents & (POLLERR | POLLHUP | POLLIN | POLLRDHUP))
+				break;
+
+			if (signal_pending(current))
+				break;
+
+			schedule();
+			continue;
+		}
+		finish_wait(&st->thread_wait, &wait);
+
+		dprintk("%s: revents: %x, rev_error: %d, should_stop: %d.\n",
+			__func__, revents, revents & (POLLERR | POLLHUP | POLLRDHUP),
+			kthread_should_stop());
+
+		if (kthread_should_stop()) {
+			err = 0;
+			break;
+		}
+
+		mutex_lock(&st->state_lock);
+		err = netfs_data_recv(st, cmd, sizeof(struct netfs_cmd));
+		if (err) {
+			mutex_unlock(&st->state_lock);
+			continue;
+		}
+
+		netfs_convert_cmd(cmd);
+
+		dprintk("%s: cmd: %u, id: %llu, start: %llu, size: %u, ext: %u.\n",
+				__func__, cmd->cmd, cmd->id, cmd->start, cmd->size, cmd->ext);
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
+			default:
+				while (cmd->size) {
+					unsigned int sz = min_t(unsigned int, cmd->size, st->size);
+
+					err = netfs_data_recv(st, st->data, sz);
+					if (err)
+						break;
+
+					cmd->size -= sz;
+				}
+				break;
+		}
+
+		mutex_unlock(&st->state_lock);
+	}
+
+	mutex_lock(&st->state_lock);
+	if (err && st->socket && st->socket->sk) {
+		st->socket->sk->sk_err = -err;
+		st->socket->sk->sk_error_report(st->socket->sk);
+	}
+	mutex_unlock(&st->state_lock);
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
+	err = st->socket->ops->connect(st->socket,
+			(struct sockaddr *)&ctl->addr, ctl->addrlen, 0);
+	if (err) {
+		dprintk("%s: failed to connect to server: idx: %u, err: %d.\n",
+				__func__, st->psb->idx, err);
+		goto err_out_release;
+	}
+
+	st->socket->sk->sk_allocation = GFP_NOIO;
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
+		sock_release(st->socket);
+		st->socket = NULL;
+	}
+}
+
+static int pohmelfs_state_init_one(struct pohmelfs_sb *psb, struct pohmelfs_config *conf)
+{
+	struct netfs_state *st = &conf->state;
+	int err = -ENOMEM;
+
+	mutex_init(&st->state_lock);
+	init_waitqueue_head(&st->thread_wait);
+
+	st->psb = psb;
+
+	st->trans = kzalloc(sizeof(struct netfs_trans), GFP_KERNEL);
+	if (!st->trans)
+		goto err_out_exit;
+
+	err = netfs_trans_init(st->trans, psb->trans_iovec_num, psb->trans_data_size);
+	if (err) {
+		kfree(st->trans);
+		st->trans = NULL;
+		goto err_out_exit;
+	}
+	atomic_inc(&st->trans->refcnt);
+
+	st->size = PAGE_SIZE;
+	st->data = kmalloc(st->size, GFP_KERNEL);
+	if (!st->data)
+		goto err_out_close_trans;
+
+	err = netfs_state_init(st);
+	if (err)
+		goto err_out_free_data;
+
+	st->thread = kthread_run(pohmelfs_recv, st, "pohmelfs/%u", psb->idx);
+	if (IS_ERR(st->thread)) {
+		err = PTR_ERR(st->thread);
+		goto err_out_netfs_exit;
+	}
+
+	return 0;
+
+err_out_netfs_exit:
+	netfs_state_exit(st);
+err_out_free_data:
+	kfree(st->data);
+err_out_close_trans:
+	netfs_trans_exit(st->trans);
+	netfs_trans_exit(st->trans);
+err_out_exit:
+	return err;
+
+}
+
+static void pohmelfs_state_exit_one(struct pohmelfs_config *c)
+{
+	struct netfs_state *st = &c->state;
+
+	dprintk("%s: exiting.\n", __func__);
+	if (st->thread) {
+		kthread_stop(st->thread);
+		st->thread = NULL;
+	}
+
+	mutex_lock(&st->state_lock);
+	netfs_state_exit(st);
+	mutex_unlock(&st->state_lock);
+
+	kfree(st->data);
+	netfs_trans_exit(st->trans);
+	netfs_trans_exit(st->trans);
+	st->trans = NULL;
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
+	struct pohmelfs_config *c, *tmp;
+
+	err = pohmelfs_copy_config(psb);
+	if (err)
+		return err;
+
+	mutex_lock(&psb->state_lock);
+	list_for_each_entry_safe(c, tmp, &psb->state_list, config_entry) {
+		err = pohmelfs_state_init_one(psb, c);
+		if (err) {
+			list_del(&c->config_entry);
+			kfree(c);
+			continue;
+		}
+
+		if (!psb->active_state)
+			psb->active_state = &c->state;
+	}
+	mutex_unlock(&psb->state_lock);
+
+	if (!psb->active_state)
+		return err;
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
+struct netfs_state *pohmelfs_active_state(struct pohmelfs_sb *psb)
+{
+	return psb->active_state;
+}
diff --git a/fs/pohmelfs/netfs.h b/fs/pohmelfs/netfs.h
new file mode 100644
index 0000000..f852329
--- /dev/null
+++ b/fs/pohmelfs/netfs.h
@@ -0,0 +1,426 @@
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
+	__u16			ext;	/* External flags */
+	__u32			size;	/* Size of the attached data */
+	__u64			id;	/* Object ID to operate on. Used for feedback.*/
+	__u64			start;	/* Start of the object. */
+	__u8			data[];
+};
+
+static inline void netfs_convert_cmd(struct netfs_cmd *cmd)
+{
+	cmd->id = __be64_to_cpu(cmd->id);
+	cmd->start = __be64_to_cpu(cmd->start);
+	cmd->cmd = __be16_to_cpu(cmd->cmd);
+	cmd->ext = __be16_to_cpu(cmd->ext);
+	cmd->size = __be32_to_cpu(cmd->size);
+}
+
+#define NETFS_TRANS_SYNC		1
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
+	NETFS_SYNC_INFO,	/* Cache coherency synchronization message */
+	NETFS_CMD_MAX
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
+/*
+ * Configuration command used to create table of different remote servers.
+ */
+struct pohmelfs_ctl
+{
+	unsigned int		idx;		/* Config index */
+	unsigned int		type;		/* Socket type */
+	unsigned int		proto;		/* Socket protocol */
+	unsigned int		addrlen;	/* Size of the address*/
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
+#ifdef __KERNEL__
+
+#include <linux/kernel.h>
+#include <linux/rbtree.h>
+#include <linux/net.h>
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
+	long			state;			/* State machine above */
+
+	u64			ino;			/* Inode number */
+	u64			total_len;		/* Total length of all children names, used to create offsets */
+
+	struct inode		vfs_inode;
+};
+
+struct netfs_state;
+struct pohmelfs_sb;
+
+struct netfs_trans
+{
+	struct rb_node			trans_entry;
+
+	struct iovec			*iovec;
+	void				**data;
+
+	atomic_t			refcnt;
+
+	unsigned short			trans_idx, iovec_num;
+
+	unsigned int			flags;
+
+	unsigned int			data_size;
+	unsigned int			trans_size;
+
+	unsigned int			trans_gen;
+
+	unsigned long			send_time;
+
+	void				(*complete)(struct netfs_trans *t, int err);
+	void				(*destructor)(struct netfs_trans *t);
+};
+
+static inline unsigned int netfs_trans_cur_len(struct netfs_trans *t)
+{
+	BUG_ON(!t->iovec);
+
+	return t->iovec[t->trans_idx].iov_len;
+}
+
+struct netfs_trans *netfs_trans_alloc_for_pages(unsigned int nr);
+
+int netfs_trans_init(struct netfs_trans *t, int num, int data_size);
+void netfs_trans_exit(struct netfs_trans *t);
+static inline int netfs_trans_start_empty(struct netfs_trans *t, unsigned int flags)
+{
+	t->flags = flags;
+	return 0;
+}
+
+int netfs_trans_start(struct netfs_trans *t, unsigned int flags);
+int netfs_trans_finish(struct netfs_trans *t, struct netfs_state *st);
+int netfs_trans_finish_send(struct netfs_trans *t, struct netfs_state *st, struct pohmelfs_sb *psb);
+
+int netfs_trans_remove(struct netfs_trans *t, struct pohmelfs_sb *psb);
+struct netfs_trans *netfs_trans_search(struct pohmelfs_sb *psb, unsigned int id);
+
+void *netfs_trans_add(struct netfs_trans *t, unsigned int size);
+int netfs_trans_fixup_last(struct netfs_trans *t, int diff);
+
+static inline void netfs_trans_reset(struct netfs_trans *t)
+{
+	t->trans_size = 0;
+	t->trans_idx = 0;
+}
+
+/*
+ * Network state, attached to one server.
+ */
+struct netfs_state
+{
+	struct mutex		state_lock;		/* Can not allow to use the same socket simultaneously */
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
+	struct netfs_trans	*trans;			/* Transaction */
+
+	struct pohmelfs_ctl	ctl;			/* Remote peer */
+
+	struct socket		*socket;		/* Socket object */
+};
+
+int netfs_state_init(struct netfs_state *st);
+void netfs_state_exit(struct netfs_state *st);
+
+struct pohmelfs_sb
+{
+	struct list_head	inode_list;
+	struct rb_root		path_root;
+	struct mutex		path_lock;
+
+	unsigned int		idx;
+
+	unsigned int		trans_data_size, trans_iovec_num;
+	unsigned int		trans_timeout;
+
+	struct mutex		trans_lock;
+	struct rb_root		trans_root;
+	atomic_t		trans_gen;
+
+	u64			ino;
+
+	struct list_head	state_list;
+	struct mutex		state_lock;
+
+	struct netfs_state	*active_state;
+
+	struct delayed_work 	dwork;
+
+	struct super_block	*sb;
+};
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
+struct netfs_state *pohmelfs_active_state(struct pohmelfs_sb *psb);
+
+struct pohmelfs_config
+{
+	struct list_head	config_entry;
+
+	struct netfs_state	state;
+};
+
+int __init pohmelfs_config_init(void);
+void __exit pohmelfs_config_exit(void);
+int pohmelfs_copy_config(struct pohmelfs_sb *psb);
+
+extern const struct file_operations pohmelfs_dir_fops;
+extern const struct inode_operations pohmelfs_dir_inode_ops;
+
+int netfs_data_recv(struct netfs_state *st, void *buf, u64 size);
+int netfs_data_send(struct netfs_state *st, void *buf, u64 size, int more);
+
+int pohmelfs_state_init(struct pohmelfs_sb *psb);
+void pohmelfs_state_exit(struct pohmelfs_sb *psb);
+
+void pohmelfs_fill_inode(struct pohmelfs_inode *pi, struct netfs_inode_info *info);
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
+struct pohmelfs_path_entry
+{
+	struct rb_node			path_entry;
+	struct list_head		entry;
+	u8				len, link;
+	u8				unused[2];
+	u32				hash;
+	u64				ino;
+	struct pohmelfs_path_entry	*parent;
+	char				*name;
+};
+
+void pohmelfs_remove_path_entry(struct pohmelfs_sb *psb, struct pohmelfs_path_entry *e);
+void pohmelfs_remove_path_entry_by_ino(struct pohmelfs_sb *psb, u64 ino);
+struct pohmelfs_path_entry * pohmelfs_add_path_entry(struct pohmelfs_sb *psb,
+	u64 parent_ino, u64 ino, struct qstr *str, int link);
+int pohmelfs_construct_path(struct pohmelfs_inode *pi, void *data, int len);
+int pohmelfs_construct_path_string(struct pohmelfs_inode *pi, void *data, int len);
+
+struct pohmelfs_shared_info
+{
+	struct list_head		page_list;
+	struct mutex			page_lock;
+
+	int				freeing;
+	int				pages_scheduled;
+	atomic_t			pages_completed;
+};
+
+struct pohmelfs_page_private
+{
+	struct list_head		page_entry;
+	unsigned long			offset;
+	unsigned long			nr;
+	unsigned long			private;
+	struct page			*page;
+	char __user			*buf;
+	struct pohmelfs_shared_info	*shared;
+};
+
+void pohmelfs_put_shared_info(struct pohmelfs_shared_info *);
+
+#define CONFIG_POHMELFS_DEBUG
+
+#ifdef CONFIG_POHMELFS_DEBUG
+#define dprintk(f, a...) printk(f, ##a)
+#else
+#define dprintk(f, a...) do {} while (0)
+#endif
+
+#endif /* __KERNEL__*/
+
+#endif /* __NETFS_H */
diff --git a/fs/pohmelfs/path_entry.c b/fs/pohmelfs/path_entry.c
new file mode 100644
index 0000000..5b3464c
--- /dev/null
+++ b/fs/pohmelfs/path_entry.c
@@ -0,0 +1,278 @@
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
+	if (e && e->path_entry.rb_parent_color) {
+		rb_erase(&e->path_entry, &psb->path_root);
+	}
+	pohmelfs_free_path_entry(e);
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
+struct pohmelfs_path_entry * pohmelfs_add_path_entry(struct pohmelfs_sb *psb,
+	u64 parent_ino, u64 ino, struct qstr *str, int link)
+{
+	struct pohmelfs_path_entry *e, *ret, *parent;
+
+	parent = pohmelfs_search_path_entry(&psb->path_root, parent_ino);
+
+	e = pohmelfs_alloc_path_entry(str->len);
+	if (!e)
+		return ERR_PTR(-ENOMEM);
+
+	e->parent = (parent) ? parent : e;
+	e->ino = ino;
+	e->hash = str->hash;
+	e->link = link;
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
+static int pohmelfs_prepare_path(struct pohmelfs_inode *pi, struct list_head *list, int len)
+{
+	struct pohmelfs_path_entry *e;
+	struct pohmelfs_sb *psb = POHMELFS_SB(pi->vfs_inode.i_sb);
+
+	e = pohmelfs_search_path_entry(&psb->path_root, pi->ino);
+	if (!e)
+		return -ENOENT;
+
+	while (e && e->parent != e) {
+		if (len < sizeof(struct netfs_path_entry))
+			return -ETOOSMALL;
+
+		len -= sizeof(struct netfs_path_entry);
+
+		if (e->len > 5) {
+			if (len < e->len)
+				return -ETOOSMALL;
+			len -= e->len;
+		}
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
+	struct inode *inode;
+	struct pohmelfs_path_entry *e;
+	struct netfs_path_entry *ne = data;
+	int used = 0, err;
+	LIST_HEAD(list);
+
+	err = pohmelfs_prepare_path(pi, &list, len);
+	if (err)
+		return err;
+
+	list_for_each_entry(e, &list, entry) {
+		inode = ilookup(pi->vfs_inode.i_sb, e->ino);
+		if (!inode)
+			continue;
+
+		ne = data;
+		ne->mode = inode->i_mode;
+		ne->len = e->len;
+
+		iput(inode);
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
+	err = pohmelfs_prepare_path(pi, &list, len);
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
+			ptr += err;
+			used += err;
+		}
+	}
+
+	dprintk("%s: inode: %llu, full path: '%s'.\n", __func__, pi->ino, (char *)data);
+
+	return used;
+}
diff --git a/fs/pohmelfs/trans.c b/fs/pohmelfs/trans.c
new file mode 100644
index 0000000..233bcd0
--- /dev/null
+++ b/fs/pohmelfs/trans.c
@@ -0,0 +1,469 @@
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
+#include <linux/fs.h>
+#include <linux/jhash.h>
+#include <linux/hash.h>
+#include <linux/ktime.h>
+#include <linux/mm.h>
+#include <linux/mount.h>
+#include <linux/pagemap.h>
+#include <linux/parser.h>
+#include <linux/swap.h>
+#include <linux/slab.h>
+#include <linux/statfs.h>
+#include <linux/writeback.h>
+
+#include "netfs.h"
+
+static void netfs_trans_init_static(struct netfs_trans *t, int num, int data_size)
+{
+	t->iovec_num = num;
+	t->data_size = data_size;
+
+	t->trans_idx = 0;
+	t->trans_size = 0;
+	t->trans_entry.rb_parent_color = 0;
+	atomic_set(&t->refcnt, 1);
+	t->send_time = 0;
+}
+
+static void netfs_trans_free_whole(struct netfs_trans *t)
+{
+	int i;
+
+	for (i=0; i<t->iovec_num; ++i)
+		kfree(t->data[i]);
+	kfree(t->data);
+	kfree(t->iovec);
+}
+
+int netfs_trans_init(struct netfs_trans *t, int num, int data_size)
+{
+	int i, err = -ENOMEM;
+
+	t->iovec = kzalloc(num * sizeof(struct iovec), GFP_NOIO);
+	if (!t->iovec)
+		goto err_out_exit;
+
+	t->data = kzalloc(num * sizeof(void *), GFP_NOIO);
+	if (!t->data)
+		goto err_out_free_iovec;
+
+	for (i=0; i<num; ++i) {
+		t->data[i] = kmalloc(data_size, GFP_NOIO);
+		if (!t->data[i])
+			break;
+	}
+
+	if (!i)
+		goto err_out_free_data;
+
+	t->destructor = &netfs_trans_free_whole;
+	netfs_trans_init_static(t, i, data_size);
+
+	return 0;
+
+err_out_free_data:
+	kfree(t->data);
+err_out_free_iovec:
+	kfree(t->iovec);
+err_out_exit:
+	return err;
+}
+
+void netfs_trans_exit(struct netfs_trans *t)
+{
+	dprintk("%s: t: %p.\n", __func__, t);
+	dprintk("%s: t: %p, refcnt: %d.\n", __func__, t, atomic_read(&t->refcnt));
+	if (atomic_dec_and_test(&t->refcnt))
+		t->destructor(t);
+}
+
+int netfs_trans_start(struct netfs_trans *t, unsigned int flags)
+{
+	int i;
+
+	netfs_trans_start_empty(t, flags);
+	atomic_inc(&t->refcnt);
+
+	for (i=0; i<t->iovec_num; ++i) {
+		struct iovec *io = &t->iovec[i];
+
+		io->iov_len = 0;
+		io->iov_base = t->data[i];
+	}
+
+	t->iovec[0].iov_len = sizeof(struct netfs_cmd);
+
+	t->trans_idx = 1;
+	t->trans_size = 0;
+
+	return 0;
+}
+
+static int netfs_trans_send(struct netfs_trans *t, struct netfs_state *st, struct msghdr *msg)
+{
+	int err;
+
+	mutex_lock(&st->state_lock);
+	if (!st->socket) {
+		err = netfs_state_init(st);
+		if (err) {
+			mutex_unlock(&st->state_lock);
+			return err;
+		}
+	}
+
+	err = kernel_sendmsg(st->socket, msg, (struct kvec *)msg->msg_iov, msg->msg_iovlen, t->trans_size);
+	if (err <= 0) {
+		printk("%s: failed to send transaction: trans_size: %u, trans_idx: %u, err: %d.\n",
+				__func__, t->trans_size, t->trans_idx, err);
+		if (err == 0)
+			err = -ECONNRESET;
+		netfs_state_exit(st);
+	} else {
+		err = 0;
+	}
+	mutex_unlock(&st->state_lock);
+
+	return err;
+}
+
+static inline int netfs_trans_cmp(unsigned int trans_gen, unsigned int new)
+{
+	if (trans_gen < new)
+		return 1;
+	if (trans_gen > new)
+		return -1;
+	return 0;
+}
+
+struct netfs_trans *netfs_trans_search(struct pohmelfs_sb *psb, unsigned int gen)
+{
+	struct rb_root *root = &psb->trans_root;
+	struct rb_node *n = root->rb_node;
+	struct netfs_trans *tmp, *ret = NULL;
+	int cmp;
+
+	mutex_lock(&psb->trans_lock);
+	while (n) {
+		tmp = rb_entry(n, struct netfs_trans, trans_entry);
+
+		cmp = netfs_trans_cmp(tmp->trans_gen, gen);
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else {
+			ret = tmp;
+			atomic_inc(&ret->refcnt);
+			break;
+		}
+	}
+	mutex_unlock(&psb->trans_lock);
+
+	return ret;
+}
+
+int netfs_trans_insert(struct netfs_trans *new, struct pohmelfs_sb *psb)
+{
+	struct rb_root *root = &psb->trans_root;
+	struct rb_node **n = &root->rb_node, *parent = NULL;
+	struct netfs_trans *ret = NULL, *tmp;
+	int cmp, err;
+
+	mutex_lock(&psb->trans_lock);
+	while (*n) {
+		parent = *n;
+
+		tmp = rb_entry(parent, struct netfs_trans, trans_entry);
+
+		cmp = netfs_trans_cmp(tmp->trans_gen, new->trans_gen);
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
+		printk("%s: exist: old: gen: %u, idx: %d, flags: %x, trans_size: %u, send_time: %lu, "
+				"new: gen: %u, idx: %d, flags: %x, trans_size: %u, send_time: %lu.\n",
+			__func__, ret->trans_gen, ret->trans_idx, ret->flags, ret->trans_size, ret->send_time,
+			new->trans_gen, new->trans_idx, new->flags, new->trans_size, new->send_time);
+		err = -EEXIST;
+		goto out;
+	}
+
+	err = 0;
+
+	rb_link_node(&new->trans_entry, parent, n);
+	rb_insert_color(&new->trans_entry, root);
+	new->send_time = jiffies;
+
+	dprintk("%s: inserted: gen: %u, idx: %d, flags: %x, trans_size: %u, send_time: %lu.\n",
+		__func__, new->trans_gen, new->trans_idx, new->flags, new->trans_size, new->send_time);
+
+out:
+	mutex_unlock(&psb->trans_lock);
+	return err;
+}
+
+int netfs_trans_remove(struct netfs_trans *t, struct pohmelfs_sb *psb)
+{
+	mutex_lock(&psb->trans_lock);
+	if (t && t->trans_entry.rb_parent_color) {
+		rb_erase(&t->trans_entry, &psb->trans_root);
+		t->trans_entry.rb_parent_color = 0;
+	}
+	mutex_unlock(&psb->trans_lock);
+
+	return 0;
+}
+
+int netfs_trans_wait(struct netfs_trans *t, struct netfs_state *st)
+{
+	long timeout = msecs_to_jiffies(5000);
+	int err;
+
+	if (!(t->flags & NETFS_TRANS_SYNC))
+		return 0;
+
+	timeout = wait_event_interruptible_timeout(st->thread_wait,
+			!(t->flags & NETFS_TRANS_SYNC), timeout);
+	err = -t->trans_idx;
+	if (t->flags & NETFS_TRANS_SYNC) {
+		if (!timeout)
+			err = -ETIMEDOUT;
+		if (signal_pending(current))
+			err = -EINTR;
+	}
+
+	return err;
+}
+
+int netfs_trans_finish_send(struct netfs_trans *t, struct netfs_state *st, struct pohmelfs_sb *psb)
+{
+	struct pohmelfs_config *c;
+	struct msghdr msg;
+	int err = -ENODEV;
+
+	msg.msg_iov = t->iovec;
+	msg.msg_iovlen = t->trans_idx + 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_WAITALL;
+
+	dprintk("%s: t: %p, trans_gen: %u, trans_size: %u, data_size: %u, trans_idx: %u, iovec_num: %u.\n",
+		__func__, t, t->trans_gen, t->trans_size, t->data_size, t->trans_idx, t->iovec_num);
+
+	if (st) {
+		err = netfs_trans_send(t, st, &msg);
+		if (!err)
+			return 0;
+	}
+
+	mutex_lock(&psb->state_lock);
+	list_for_each_entry(c, &psb->state_list, config_entry) {
+		st = &c->state;
+
+		err = netfs_trans_send(t, st, &msg);
+		if (!err)
+			break;
+	}
+	mutex_unlock(&psb->state_lock);
+
+	if (err) {
+		dprintk("%s: Failed to send transaction to any remote server.\n", __func__);
+	} else if (psb->active_state != st) {
+		dprintk("%s: switch active state %p -> %p.\n", __func__, st->psb->active_state, st);
+		psb->active_state = st;
+	}
+
+	return err;
+}
+
+int netfs_trans_finish(struct netfs_trans *t, struct netfs_state *st)
+{
+	int err = 0;
+	struct pohmelfs_sb *psb = st->psb;
+
+	if (likely(t->trans_size)) {
+		struct netfs_cmd *cmd = t->data[0];
+
+		t->trans_gen = atomic_inc_return(&psb->trans_gen);
+
+		if (t->flags & NETFS_TRANS_SYNC) {
+			err = netfs_trans_insert(t, psb);
+			if (err)
+				return err;
+		}
+
+		cmd->size = t->trans_size;
+		cmd->cmd = NETFS_TRANS;
+		cmd->start = t->trans_gen;
+		cmd->ext = t->flags;
+		cmd->id = t->trans_idx;
+
+		netfs_convert_cmd(cmd);
+
+		err = netfs_trans_finish_send(t, st, psb);
+		if (!err)
+			return 0;
+	}
+
+	t->trans_size = 0;
+	t->trans_idx = 0;
+
+	if (err && (t->flags & NETFS_TRANS_SYNC))
+		netfs_trans_remove(t, psb);
+
+	return err;
+}
+
+void *netfs_trans_add(struct netfs_trans *t, unsigned int size)
+{
+	struct iovec *io = &t->iovec[t->trans_idx];
+	void *ptr;
+
+	if (size > t->data_size) {
+		ptr = ERR_PTR(-EINVAL);
+		goto out;
+	}
+
+	if (io->iov_len + size > t->data_size) {
+		if (t->trans_idx == t->iovec_num - 1) {
+			ptr = ERR_PTR(-E2BIG);
+			goto out;
+		}
+
+		t->trans_idx++;
+		io = &t->iovec[t->trans_idx];
+	}
+
+	ptr = io->iov_base + io->iov_len;
+	io->iov_len += size;
+	t->trans_size += size;
+
+out:
+	dprintk("%s: t: %p, trans_size: %u, trans_idx: %u, data_size: %u, size: %u, cur_io_len: %u, iovec_num: %u, base: %p, ptr: %p/%ld.\n",
+			__func__, t, t->trans_size, t->trans_idx, t->data_size, size, io->iov_len, t->iovec_num,
+			io->iov_base, ptr, IS_ERR(ptr)?PTR_ERR(ptr):0);
+	return ptr;
+}
+
+int netfs_trans_fixup_last(struct netfs_trans *t, int diff)
+{
+	struct iovec *io = &t->iovec[t->trans_idx];
+	int len;
+
+	if (unlikely((signed)io->iov_len + diff > (signed)t->data_size)) {
+		dprintk("%s: wrong fixup t: %p, trans_size: %u, trans_idx: %u, data_size: %u, cur_io_len: %u, diff: %d.\n",
+			__func__, t, t->trans_size, t->trans_idx, t->data_size, io->iov_len, diff);
+
+		return -EINVAL;
+	}
+
+	t->trans_size += diff;
+	while (diff) {
+		len = io->iov_len + diff;
+
+		dprintk("%s: t: %p, trans_size: %u, trans_idx: %u, data_size: %u, cur_io_len: %u, diff: %d.\n",
+			__func__, t, t->trans_size, t->trans_idx, t->data_size, io->iov_len, diff);
+
+		io->iov_len = len;
+		diff = 0;
+		if (len <= 0) {
+			if (len < 0)
+				io->iov_len = 0;
+			if (unlikely(t->trans_idx == 0))
+				return 0;
+
+			t->trans_idx--;
+			io = &t->iovec[t->trans_idx];
+			diff = len;
+		}
+	}
+
+	return 0;
+}
+
+static void netfs_trans_free_for_pages(struct netfs_trans *t)
+{
+	kfree(t->data[0]);
+	kfree(t);
+}
+
+struct netfs_trans *netfs_trans_alloc_for_pages(unsigned int nr)
+{
+	struct netfs_trans *t;
+	unsigned int num, size, i;
+	void *data;
+
+	size = sizeof(struct iovec)*2 + sizeof(struct netfs_cmd) + sizeof(void *);
+
+	num = (PAGE_SIZE - sizeof(struct netfs_trans) - sizeof(struct iovec))/size;
+
+	dprintk("%s: nr: %u, num: %u.\n", __func__, nr, num);
+
+	if (nr > num)
+		nr = num;
+
+	/*
+	 * At least one for headers and one for page.
+	 */
+	if (nr < 2)
+		nr = 2;
+
+	t = kmalloc(sizeof(struct netfs_trans) + nr*size, GFP_NOIO);
+	if (!t)
+		goto err_out_exit;
+
+	memset(t, 0, sizeof(struct netfs_trans));
+
+	data = kmalloc(PAGE_SIZE, GFP_NOIO);
+	if (!data)
+		goto err_out_free;
+
+	t->iovec = (struct iovec *)(t + 1);
+	t->data = (void **)(t->iovec + 2*nr);
+
+	for (i=0; i<nr*2; ++i) {
+		struct iovec *io = &t->iovec[i];
+
+		io->iov_len = 0;
+		io->iov_base = NULL;
+
+		t->data[i/2] = NULL;
+	}
+
+	t->iovec[0].iov_base = t->data[0] = data;
+	t->destructor = &netfs_trans_free_for_pages;
+	netfs_trans_init_static(t, nr, PAGE_CACHE_SIZE);
+
+	return t;
+
+err_out_free:
+	kfree(t);
+err_out_exit:
+	return NULL;
+}

-- 
	Evgeniy Polyakov
