From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/2] POHMELFS - network filesystem with local coherent cache.
Date: Thu, 31 Jan 2008 22:17:16 +0300
Message-ID: <11972872493911@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

POHMELFS stands for Parallel Optimized Host Message Exchange
Layered File System. It allows to mount remote servers to local
directory via network. This filesystem supports local caching
and writeback flushing.
POHMELFS is a brick in a future distributed filesystem.

This set includes two patches:
 * network filesystem with write-through cache (slow, but works with
 	remote userspace server)
 * hack to show how local cache works and how faster it is compared
 	to async NFS (see below). hack disables writeback flush and
	performs local allocation of the objects only.

Now, some vaporware aka food for thoughts and your brains.

A small benchmark of the local cached mode (above hack):

$ time tar -xf /home/zbr/threading.tar

	POHMELFS	NFS v3 (async)
real    0m0.043s	0m1.679s

Which is damn 40 times!

Excited? Now get huge bucket with ice.

Generic problem with writeback cache is a fact, that all local objects
has to have IDs in sync with remote side. For example, if remote side
is ext3, local one should not overwrite inode with number 0.
Contrary write-through cache allows to request remote side about
what ID should given data have and be in sync. This one is slow.

Of course this will not be _that_ huge difference in a real world, when
tested archives are larger (this one if a git archive of my userspace
threading library), which is very small. Since it is so small there is
no writeback cache flushing, and thus remote side never receives data.

Actually one can consider this as tmpfs or something like that. Code supports
sync, but since inode generation process is very different, files and dirs
can not be blindly synced to the ext3. So, this release of POHMELFS consists of
two patches: first one is a network filesystem implementation with write-through
cache, when object is first created on the remote side and then populated to the
local cache. This one is slow.

Second patch is a hack to disable writeback caching and implement local caching
only, which is very fast.

Next task is to think about how to generically solve the problem with
syncing local changes with remote server, when remote server maintains inodes with
completely different numbers.
This, among others, will allow offline work with automatic syncing after reconnect.

This is not intended for inclusion, CRFS by Zach Brown is a bit ahead of POHMELFS,
but it is not generic enough (because of above problem), works only with BTRFS,
and was closed by Oracle so far :)
So, anyone who managed to read up to this and happend to be at LCA 08 just has to
move this Friday to his presentation.

POHMELFS TODO list includes:

 * mechanism of keeping it coherent with other users
 * unified method of syncing with various remote filesystems

Thank you.

P.S. POHMELFS is about one month old, so do not be so severe with it :)

Crappy-stuff-created-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/fs/Kconfig b/fs/Kconfig
index f9eed6d..c40f2c5 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1519,6 +1519,8 @@ endmenu
 menu "Network File Systems"
 	depends on NET
 
+source "fs/pohmelfs/Kconfig"
+
 config NFS_FS
 	tristate "NFS file system support"
 	depends on INET
diff --git a/fs/Makefile b/fs/Makefile
index 720c29d..8fff82a 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -118,3 +118,4 @@ obj-$(CONFIG_HPPFS)		+= hppfs/
 obj-$(CONFIG_DEBUG_FS)		+= debugfs/
 obj-$(CONFIG_OCFS2_FS)		+= ocfs2/
 obj-$(CONFIG_GFS2_FS)           += gfs2/
+obj-$(CONFIG_POHMELFS)          += pohmelfs/
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
index 0000000..8a87f46
--- /dev/null
+++ b/fs/pohmelfs/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_POHMELFS)	+= pohmelfs.o
+
+pohmelfs-y := inode.o config.o dir.o net.o
diff --git a/fs/pohmelfs/config.c b/fs/pohmelfs/config.c
new file mode 100644
index 0000000..10eabe1
--- /dev/null
+++ b/fs/pohmelfs/config.c
@@ -0,0 +1,120 @@
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
+struct pohmelfs_config
+{
+	struct list_head	config_entry;
+	struct pohmelfs_ctl	cmd;
+};
+
+static struct cb_id pohmelfs_cn_id = {.idx = POHMELFS_CN_IDX, .val = POHMELFS_CN_VAL};
+static LIST_HEAD(pohmelfs_config_list);
+static DEFINE_MUTEX(pohmelfs_config_lock);
+
+int pohmelfs_copy_config(struct pohmelfs_ctl *dst, unsigned int idx)
+{
+	struct pohmelfs_config *c;
+	int err = -ENODEV;
+
+	mutex_lock(&pohmelfs_config_lock);
+	list_for_each_entry(c, &pohmelfs_config_list, config_entry) {
+		if (c->cmd.idx != idx)
+			continue;
+
+		memcpy(dst, &c->cmd, sizeof(struct pohmelfs_ctl));
+		err = 0;
+		break;
+	}
+	mutex_unlock(&pohmelfs_config_lock);
+
+	return err;
+}
+
+static void pohmelfs_cn_callback(void *data)
+{
+	struct cn_msg *msg = data;
+	struct pohmelfs_ctl *cmd;
+	struct pohmelfs_cn_ack *ack;
+	struct pohmelfs_config *cfg, *c;
+	int err;
+
+	if (msg->len < sizeof(struct pohmelfs_ctl)) {
+		err = -EBADMSG;
+		goto out;
+	}
+
+	cfg = kmalloc(sizeof(struct pohmelfs_config), GFP_KERNEL);
+	if (!cfg) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	cmd = (struct pohmelfs_ctl *)msg->data;
+
+	memcpy(&cfg->cmd, cmd, sizeof(struct pohmelfs_ctl));
+
+	err = 0;
+	mutex_lock(&pohmelfs_config_lock);
+	list_for_each_entry(c, &pohmelfs_config_list, config_entry) {
+		if (c->cmd.idx == cmd->idx) {
+			err = -EEXIST;
+			break;
+		}
+	}
+	if (!err)
+		list_add_tail(&cfg->config_entry, &pohmelfs_config_list);
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
index 0000000..23f9ecd
--- /dev/null
+++ b/fs/pohmelfs/dir.c
@@ -0,0 +1,892 @@
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
+
+#include "netfs.h"
+
+static int pohmelfs_cmp_offset(struct pohmelfs_name *inode, u64 offset)
+{
+	if (inode->offset > offset)
+		return -1;
+	if (inode->offset < offset)
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
+	if (ret) {
+		dprintk("%s: exist: offset: %llu, ino: %llu, hash: %x, data: '%s', new: ino: %llu, hash: %x, data: '%s'.\n",
+			__func__, ret->offset, ret->ino, ret->hash, ret->data, new->ino, new->hash, new->data);
+		return ret;
+	}
+
+	rb_link_node(&new->offset_node, parent, n);
+	rb_insert_color(&new->offset_node, &pi->offset_root);
+
+	return NULL;
+}
+
+static struct pohmelfs_name *pohmelfs_insert_name_hash(struct rb_root *root,
+		struct pohmelfs_name *new)
+{
+	struct rb_node **n = &root->rb_node, *parent = NULL;
+	struct pohmelfs_name *ret = NULL, *tmp;
+	int cmp;
+
+	while (*n) {
+		parent = *n;
+
+		tmp = rb_entry(parent, struct pohmelfs_name, hash_node);
+
+		cmp = pohmelfs_cmp_hash(tmp, new->parent, new->hash, new->len);
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
+		dprintk("%s: exist: ino: %llu, hash: %x, data: '%s', new: ino: %llu, hash: %x, data: '%s'.\n",
+				__func__, ret->ino, ret->hash, ret->data, new->ino, new->hash, new->data);
+		return ret;
+	}
+
+	rb_link_node(&new->hash_node, parent, n);
+	rb_insert_color(&new->hash_node, root);
+	
+	dprintk("%s: inserted: ino: %llu, hash: %x, data: '%s'.\n",
+			__func__, new->ino, new->hash, new->data);
+
+	return NULL;
+}
+
+static struct pohmelfs_name *pohmelfs_search_name_hash(struct rb_root *root,
+		u64 parent, u32 hash, u32 len)
+{
+	struct rb_node *n = root->rb_node;
+	struct pohmelfs_name *tmp;
+	int cmp;
+
+	while (n) {
+		tmp = rb_entry(n, struct pohmelfs_name, hash_node);
+
+		cmp = pohmelfs_cmp_hash(tmp, parent, hash, len);
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else
+			return tmp;
+	}
+
+	dprintk("%s: Failed to find a name for parent %llu, hash: %x, len: %u.\n",
+			__func__, parent, hash, len);
+	return NULL;
+}
+
+
+void pohmelfs_name_del(struct pohmelfs_inode *parent, struct pohmelfs_name *node)
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
+	dprintk("%s: parent: '%s', name: %p/'%s', decr: %d.\n",
+			__func__, parent->name.data, node, node->data, decr);
+
+	rb_erase(&node->offset_node, &parent->offset_root);
+	rb_erase(&node->hash_node, &parent->hash_root);
+
+	kfree(node);
+}
+
+static struct pohmelfs_name *pohmelfs_name_clone(unsigned int len)
+{
+	struct pohmelfs_name *n;
+
+	n = kzalloc(sizeof(struct pohmelfs_name) + len, GFP_KERNEL);
+	if (!n)
+		return NULL;
+
+	n->data = (char *)(n+1);
+
+	return n;
+}
+
+//#define POHMELFS_NEW_INODES	1
+
+static struct pohmelfs_inode *pohmelfs_new_inode(struct pohmelfs_sb *psb, struct pohmelfs_inode *parent,
+		char *data, struct netfs_cmd *cmd, struct netfs_inode_info *info)
+{
+	struct inode *new;
+	struct pohmelfs_inode *npi, *ret;
+	int err = -ENOMEM;
+
+	dprintk("%s: creating inode for data: '%s', info_ino: %llu, cmd_ino: %llu, parent_ino: %llu.\n",
+			__func__, data, info->ino, cmd->ino, (parent)?parent->ino:0);
+#ifdef POHMELFS_NEW_INODES
+	new = new_inode(psb->sb);
+#else
+	new = iget_locked(psb->sb, cmd->ino);
+#endif
+	if (!new) {
+		kfree(data);
+		goto err_out_exit;
+	}
+
+	npi = POHMELFS_I(new);
+
+	new->i_ino = cmd->ino;
+
+#ifdef POHMELFS_NEW_INODES
+	if (1) {
+#else
+	if (new->i_state & I_NEW) {
+#endif
+		npi->name.ino = npi->ino = info->ino;
+		npi->name.parent = npi->parent = (parent)?parent->ino:0;
+		npi->name.hash = netfs_get_inode_hash(cmd);
+		npi->name.len = cmd->size;
+		npi->name.offset = cmd->start;
+		npi->name.data = data;
+		npi->name.mode = info->mode;
+
+		err = -EEXIST;
+		dprintk("%s: filling VFS inode for data: '%s'.\n", __func__, data);
+		ret = pohmelfs_fill_inode(npi, info);
+		if (ret != npi)
+			goto err_out_put;
+	}
+
+	if (parent) {
+		struct pohmelfs_name *n, *name;
+
+		err = -ENOMEM;
+		n = pohmelfs_name_clone(cmd->size);
+		if (!n)
+			goto err_out_put;
+
+		n->parent = parent->ino;
+		n->ino = npi->ino;
+		n->offset = cmd->start;
+		n->hash = netfs_get_inode_hash(cmd);
+		n->mode = info->mode;
+		n->len = cmd->size;
+		strncpy(n->data, data, n->len);
+
+		mutex_lock(&parent->offset_lock);
+		name = pohmelfs_insert_offset(parent, n);
+
+		if (!name) {
+			name = pohmelfs_insert_name_hash(&parent->hash_root, n);
+			if (name)
+				rb_erase(&n->offset_node, &parent->offset_root);
+		}
+		mutex_unlock(&parent->offset_lock);
+
+		dprintk("%s: %s inserted name: %p/'%s', offset: %llu, ino: %llu, parent: %llu.\n",
+				__func__, (name)?"unsuccessfully":"successfully",
+				n, n->data, n->offset, n->ino, n->parent);
+
+		err = 0;
+		if (name) {
+			err = -EEXIST;
+			kfree(n);
+			goto err_out_put;
+		}
+	}
+
+#ifdef POHMELFS_NEW_INODES
+	insert_inode_hash(new);
+#else
+	if (new->i_state & I_NEW)
+		unlock_new_inode(new);
+	else
+		iput(new);
+#endif
+	mark_inode_dirty(new);
+
+	if (parent)
+		mark_inode_dirty(&parent->vfs_inode);
+
+	return npi;
+
+err_out_put:
+	unlock_new_inode(new);
+	printk("%s: putting inode: %p, npi: %p, error: %d, count: %d, nlink: %u.\n",
+			__func__, new, npi, err, atomic_read(&new->i_count), new->i_nlink);
+	iput(new);
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+static int netfs_recv_inode_info(struct pohmelfs_sb *psb, struct pohmelfs_inode *parent,
+		struct pohmelfs_inode **newp, char *data)
+{
+	struct netfs_state *st = &psb->state;
+	struct netfs_cmd *cmd = &st->cmd;
+	struct pohmelfs_inode *npi;
+	int err, total_size = 0, alloc = 0;
+
+	dprintk("%s: receiving inode info, data: %p, parent: %llu, st: %p.\n",
+			__func__, data, (parent)?parent->ino:0, st);
+
+	err = netfs_data_recv(st, cmd, sizeof(struct netfs_cmd));
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_exit;
+	}
+
+	netfs_convert_cmd(cmd);
+	total_size += sizeof(struct netfs_cmd) + cmd->size;
+
+	dprintk("%s: start: %llu, size: %llu.\n", __func__, cmd->start, cmd->size);
+
+	if (cmd->start == ~0ULL) {
+		err = -cmd->size;
+		goto err_out_exit;
+	}
+
+	if (!cmd->size) {
+		err = 0;
+		goto err_out_exit;
+	}
+
+	/*
+	 * Each directory entry can not exceed 256 bytes for path
+	 * plus header overhead, so PAGE_SIZE is more than enough.
+	 */
+
+	if (cmd->size >= PAGE_SIZE) {
+		printk("%s: wrong received data size: %llu, ino: %llu.\n",
+			__func__, cmd->size, cmd->ino);
+		BUG_ON(1);
+		err = -E2BIG;
+		goto err_out_exit;
+	}
+
+	if (!data) {
+		err = -ENOMEM;
+		data = kzalloc(cmd->size + 1, GFP_KERNEL);
+		if (!data)
+			goto err_out_exit;
+		alloc = 1;
+
+		dprintk("%s: receiving data, size: %llu.\n", __func__, cmd->size);
+		err = netfs_data_recv(st, data, cmd->size);
+		if (err <= 0) {
+			if (err == 0)
+				err = -ECONNRESET;
+			goto err_out_free;
+		}
+		data[cmd->size] = '\0';
+	}
+
+	dprintk("%s: receiving info.\n", __func__);
+	err = netfs_data_recv(st, &st->info, sizeof(struct netfs_inode_info));
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_free;
+	}
+	
+	total_size += sizeof(struct netfs_inode_info);
+
+	netfs_convert_inode_info(&st->info);
+
+	npi = pohmelfs_new_inode(psb, parent, data, cmd, &st->info);
+	if (IS_ERR(npi)) {
+		err = PTR_ERR(npi);
+		if (err != -EEXIST)
+			goto err_out_exit;
+		npi = NULL;
+	} else
+		err = 0;
+	
+	dprintk("%s: all is ok, total_size: %d, err: %d.\n",
+			__func__, total_size, err);
+
+	*newp = npi;
+	return total_size;
+
+err_out_free:
+	if (alloc)
+		kfree(data);
+err_out_exit:
+	*newp = NULL;
+	dprintk("%s: returning err: %d.\n", __func__, err);
+	return err;
+}
+
+static int netfs_sync_inode(struct pohmelfs_inode *pi, u64 start)
+{
+	struct inode *inode = &pi->vfs_inode;
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	struct netfs_state *st = &psb->state;
+	struct netfs_cmd *cmd = &st->cmd;
+	struct pohmelfs_inode *npi;
+	int err, added = 0;
+	u64 size, ps;
+
+	dprintk("%s: start: %llu, inode: %p [%lu].\n",
+			__func__, start, inode, inode->i_ino);
+
+	mutex_lock(&st->lock);
+
+	while (1) {
+		cmd->cmd = NETFS_READDIR;
+		cmd->ino = inode->i_ino;
+		cmd->ts = 0;
+		cmd->size = PAGE_SIZE;
+		cmd->start = start;
+
+		netfs_convert_cmd(cmd);
+
+		err = netfs_data_send(st, cmd, sizeof(struct netfs_cmd));
+		if (err <= 0) {
+			if (err == 0)
+				err = -ECONNRESET;
+			goto err_out_unlock;
+		}
+
+		dprintk("%s: receiving reply.\n", __func__);
+		err = netfs_data_recv(st, cmd, sizeof(struct netfs_cmd));
+		if (err <= 0) {
+			if (err == 0)
+				err = -ECONNRESET;
+			goto err_out_unlock;
+		}
+
+		netfs_convert_cmd(cmd);
+
+		dprintk("%s: received size: %llu.\n", __func__, cmd->size);
+		ps = size = cmd->size;
+
+		if (!size)
+			break;
+
+		while (size != 0) {
+			err = netfs_recv_inode_info(psb, pi, &npi, NULL);
+			if (err < 0)
+				goto err_out_unlock;
+
+			size -= err;
+			start += err;
+			added++;
+		}
+
+		if (ps < PAGE_SIZE - 256 - sizeof(struct netfs_cmd) -
+				sizeof(struct netfs_inode_info))
+			break;
+	}
+
+	mutex_unlock(&st->lock);
+
+	return added;
+
+err_out_unlock:
+	mutex_unlock(&st->lock);
+	dprintk("%s: returning err: %d.\n", __func__, err);
+	return err;
+}
+
+static inline int pohmelfs_sync_inode(struct pohmelfs_inode *pi, u64 start)
+{
+	int err = 0;
+
+	dprintk("%s: start: %llu, state: %lu.\n", __func__, start, pi->state);
+
+	if (!test_and_set_bit(NETFS_STATE_SYNC, &pi->state)) {
+		err = netfs_sync_inode(pi, start);
+		if (err < 0) {
+			clear_bit(NETFS_STATE_SYNC, &pi->state);
+			return err;
+		}
+	}
+
+	return err;
+}
+
+static int pohmelfs_readdir(struct file *file, void *dirent, filldir_t filldir)
+{
+	struct inode *inode = file->f_path.dentry->d_inode;
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+	struct pohmelfs_name *n;
+	int err = 0;
+	u64 len;
+
+	pohmelfs_sync_inode(pi, file->f_pos);
+
+	while (1) {
+		mutex_lock(&pi->offset_lock);
+		n = pohmelfs_search_offset(pi, file->f_pos);
+		dprintk("%s: offset: %llu, parent ino: %lu, n: %p.\n",
+				__func__, file->f_pos, pi->vfs_inode.i_ino, n);
+		if (!n) {
+			mutex_unlock(&pi->offset_lock);
+			err = 0;
+			break;
+		}
+
+		len = n->len;
+		err = filldir(dirent, n->data, n->len, file->f_pos,
+				n->ino, (n->mode >> 12) & 15);
+		mutex_unlock(&pi->offset_lock);
+
+		if (err < 0) {
+			dprintk("%s: err: %d.\n", __func__, err);
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
+struct pohmelfs_inode *pohmelfs_process_lookup_request(struct pohmelfs_sb *psb,
+		struct pohmelfs_inode *parent, char *name, __u32 len, __u32 hash)
+{
+	struct pohmelfs_inode *npi;
+	void *data;
+	struct netfs_cmd *cmd;
+	struct netfs_state *st = &psb->state;
+	int err = -ENOMEM;
+
+	data = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!data)
+		goto err_out_exit;
+
+	cmd = data;
+
+	cmd->cmd = NETFS_LOOKUP;
+	cmd->ino = (parent)?parent->ino:0;
+	cmd->ts = 0;
+	cmd->size = len;
+	cmd->start = hash;
+	cmd->flags = 0;
+
+	memcpy(data + sizeof(struct netfs_cmd), name, len);
+	
+	netfs_convert_cmd(cmd);
+
+	mutex_lock(&st->lock);
+
+	err = netfs_data_send(st, cmd, sizeof(struct netfs_cmd) + len);
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_unlock;
+	}
+
+	npi = NULL;
+	err = netfs_recv_inode_info(psb, parent, &npi, NULL);
+	if (err < 0)
+		goto err_out_unlock;
+	
+	mutex_unlock(&st->lock);
+	kfree(data);
+
+	return npi;
+
+err_out_unlock:
+	mutex_unlock(&st->lock);
+	kfree(data);
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+struct dentry *pohmelfs_lookup(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
+{
+	struct inode *inode = NULL;
+	struct pohmelfs_sb *psb = POHMELFS_SB(dir->i_sb);
+	struct pohmelfs_inode *npi, *parent = POHMELFS_I(dir);
+	int err = -ENOMEM;
+	struct pohmelfs_name *n;
+
+	dentry->d_op = dir->i_sb->s_root->d_op;
+
+	dprintk("%s: dir: %p, dir_ino: %lu, dentry: %p, dinode: %p, "
+			"name: %s, len: %u.\n",
+			__func__, dir, dir->i_ino, dentry, dentry->d_inode,
+			dentry->d_name.name, dentry->d_name.len);
+
+	do {
+		mutex_lock(&psb->hash_lock);
+		npi = pohmelfs_search_hash(&psb->hash_root, dir->i_ino, dentry->d_name.hash, dentry->d_name.len);
+		if (npi) {
+			inode = &npi->vfs_inode;
+			mutex_unlock(&psb->hash_lock);
+			goto out_add;
+		}
+		mutex_unlock(&psb->hash_lock);
+
+		mutex_lock(&parent->offset_lock);
+		n = pohmelfs_search_name_hash(&parent->hash_root, parent->ino, dentry->d_name.hash, dentry->d_name.len);
+		if (n) {
+			inode = ilookup(dir->i_sb, n->ino);
+
+			if (inode) {
+				iput(inode);
+				mutex_unlock(&parent->offset_lock);
+				goto out_add;
+			}
+		}
+		mutex_unlock(&parent->offset_lock);
+
+		err = pohmelfs_sync_inode(POHMELFS_I(dir), 0);
+		if (err < 0)
+			goto err_out_exit;
+	} while (err > 0);
+
+	if (inode == NULL)
+		return NULL;
+
+out_add:
+	return d_splice_alias(inode, dentry);
+
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+static int pohmelfs_create_entry(struct inode *dir, struct dentry *dentry, u64 start, int mode)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(dir->i_sb);
+	struct pohmelfs_inode *npi;
+	struct netfs_state *st = &psb->state;
+	struct netfs_cmd *cmd = &st->cmd;
+	int err = -ENOMEM;
+	char *data;
+
+	dprintk("%s: dir_ino: %lu, name: '%s', mode: %o, start: %llu.\n",
+			__func__, dir->i_ino, dentry->d_name.name, mode, start);
+
+	data = kstrdup(dentry->d_name.name, GFP_KERNEL);
+	if (!data)
+		goto err_out_exit;
+
+	mutex_lock(&st->lock);
+
+	cmd->ino = dir->i_ino;
+	cmd->cmd = NETFS_CREATE;
+	cmd->ts = 0;
+	cmd->size = dentry->d_name.len;
+	cmd->start = start;
+	netfs_set_cmd_flags(cmd, dentry->d_name.hash, mode);
+
+	netfs_convert_cmd(cmd);
+
+	err = netfs_data_send(st, cmd, sizeof(struct netfs_cmd));
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_free;
+	}
+
+	err = netfs_data_send(st, data, dentry->d_name.len);
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_free;
+	}
+
+	err = netfs_recv_inode_info(psb, POHMELFS_I(dir), &npi, data);
+	if (err < 0)
+		goto err_out_unlock;
+	mutex_unlock(&st->lock);
+
+	d_add(dentry, &npi->vfs_inode);
+	dprintk("%s: dir: '%s', nlink: %u, inode: '%s', nlink: %u, d_count: %d, d_unhashed: %d, dentry: %p.\n",
+			__func__,
+			POHMELFS_I(dir)->name.data, dir->i_nlink,
+			npi->name.data, npi->vfs_inode.i_nlink,
+			atomic_read(&dentry->d_count), d_unhashed(dentry), dentry);
+
+	return 0;
+
+err_out_free:
+	kfree(data);
+err_out_unlock:
+	mutex_unlock(&st->lock);
+err_out_exit:
+	dprintk("%s: err: %d.\n", __func__, err);
+	return err;
+}
+
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
+static int pohmelfs_remove_entry(struct inode *dir, struct dentry *dentry)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(dir->i_sb);
+	struct netfs_state *st = &psb->state;
+	struct inode *inode = dentry->d_inode;
+	struct pohmelfs_inode *parent = POHMELFS_I(dir), *pi = POHMELFS_I(inode);
+	struct netfs_cmd *cmd = &st->cmd;
+	struct pohmelfs_name *n;
+	int err = -ENOENT;
+
+	dprintk("%s: dir_ino: %lu, inode: %lu, name: '%s', nlink: %u.\n",
+			__func__, dir->i_ino, inode->i_ino, dentry->d_name.name, inode->i_nlink);
+
+	mutex_lock(&st->lock);
+
+	cmd->ino = inode->i_ino;
+	cmd->cmd = NETFS_REMOVE;
+	cmd->ts = 0;
+	cmd->size = 0;
+	cmd->start = 0;
+	netfs_set_cmd_flags(cmd, dentry->d_name.hash, dentry->d_inode->i_mode);
+
+	netfs_convert_cmd(cmd);
+
+	err = netfs_data_send(st, cmd, sizeof(struct netfs_cmd));
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_unlock;
+	}
+	
+	err = netfs_data_recv(st, cmd, sizeof(struct netfs_cmd));
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_unlock;
+	}
+	
+	netfs_convert_cmd(cmd);
+
+	err = 0;
+	if (cmd->start == ~0ULL)
+		err = -cmd->size;
+	mutex_unlock(&st->lock);
+
+	dprintk("%s: dir_ino: %lu, inode: %lu, name: '%s', err: %d.\n",
+			__func__, dir->i_ino, inode->i_ino, dentry->d_name.name, err);
+
+	if (!err) {
+		inode->i_ctime = dir->i_ctime;
+
+		err = -ENOENT;
+		mutex_lock(&parent->offset_lock);
+		n = pohmelfs_search_name_hash(&parent->hash_root, parent->ino, pi->name.hash, pi->name.len);
+		if (n) {
+			pohmelfs_name_del(parent, n);
+			err = 0;
+		}
+		mutex_unlock(&parent->offset_lock);
+		
+		if (!err) {
+			pohmelfs_inode_del_inode(psb, pi);
+		}
+		
+		inode_dec_link_count(inode);
+		dprintk("%s: inode: %lu, lock: %ld, unhashed: %d.\n",
+				__func__, inode->i_ino, inode->i_state & I_LOCK, hlist_unhashed(&inode->i_hash));
+	}
+
+	return err;
+
+err_out_unlock:
+	mutex_unlock(&st->lock);
+	return err;
+}
+
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
+	err = pohmelfs_remove_entry(dir, dentry);
+	if (!err) {
+		inode_dec_link_count(dir);
+		inode_dec_link_count(inode);
+	}
+
+	dprintk("%s: dentry: %p, dir: '%s', nlink: %u, inode: '%s', nlink: %u, d_count: %d, d_unhashed: %d, err: %d.\n",
+			__func__, dentry,
+			POHMELFS_I(dir)->name.data, dir->i_nlink,
+			POHMELFS_I(inode)->name.data, inode->i_nlink,
+			atomic_read(&dentry->d_count), d_unhashed(dentry), err);
+
+	return err;
+}
+
+static int pohmelfs_link(struct dentry *old_dentry, struct inode *dir,
+	struct dentry *dentry)
+{
+	struct inode *inode = old_dentry->d_inode;
+
+	return pohmelfs_create_entry(dir, dentry, inode->i_ino, inode->i_mode);
+}
+
+static int pohmelfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(dir->i_sb);
+	struct pohmelfs_inode *npi;
+	struct netfs_state *st = &psb->state;
+	struct netfs_cmd *cmd = &st->cmd;
+	int err = -ENOMEM;
+	unsigned int len = strlen(symname);
+	char *data;
+
+	dprintk("%s: dir_ino: %lu, dentry: '%s', dino: %p, symname: '%s'.\n",
+			__func__, dir->i_ino, dentry->d_name.name, dentry->d_inode, symname);
+
+	data = kstrdup(dentry->d_name.name, GFP_KERNEL);
+	if (!data)
+		goto err_out_exit;
+
+	mutex_lock(&st->lock);
+
+	cmd->ino = dir->i_ino;
+	cmd->cmd = NETFS_CREATE;
+	cmd->ts = 0;
+	cmd->size = dentry->d_name.len + len;
+	cmd->start = dentry->d_name.len;
+	netfs_set_cmd_flags(cmd, dentry->d_name.hash, S_IFLNK | S_IRWXUGO);
+
+	netfs_convert_cmd(cmd);
+
+	err = netfs_data_send(st, cmd, sizeof(struct netfs_cmd));
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_free;
+	}
+
+	err = netfs_data_send(st, data, dentry->d_name.len);
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_free;
+	}
+
+	err = netfs_data_send(st, (void *)symname, len);
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_free;
+	}
+
+	err = netfs_recv_inode_info(psb, POHMELFS_I(dir), &npi, data);
+	if (err < 0)
+		goto err_out_unlock;
+	mutex_unlock(&st->lock);
+
+	d_add(dentry, &npi->vfs_inode);
+
+	return 0;
+
+err_out_free:
+	kfree(data);
+err_out_unlock:
+	mutex_unlock(&st->lock);
+err_out_exit:
+	dprintk("%s: err: %d.\n", __func__, err);
+	return err;
+}
+
+const struct inode_operations pohmelfs_dir_inode_ops = {
+	.link	= pohmelfs_link,
+	.symlink= pohmelfs_symlink,
+	.unlink	= pohmelfs_unlink,
+	.mkdir	= pohmelfs_mkdir,
+	.rmdir	= pohmelfs_rmdir,
+	.create	= pohmelfs_create,
+	.lookup = pohmelfs_lookup,
+};
+
diff --git a/fs/pohmelfs/inode.c b/fs/pohmelfs/inode.c
new file mode 100644
index 0000000..b0ee0b3
--- /dev/null
+++ b/fs/pohmelfs/inode.c
@@ -0,0 +1,603 @@
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
+#include <linux/jhash.h>
+#include <linux/pagemap.h>
+#include <linux/writeback.h>
+#include <linux/mm.h>
+
+#include "netfs.h"
+
+static struct kmem_cache *pohmelfs_inode_cache;
+
+struct pohmelfs_inode *pohmelfs_search_hash(struct rb_root *root, u64 parent,
+		u32 hash, u32 len)
+{
+	struct rb_node *n = root->rb_node;
+	struct pohmelfs_inode *tmp;
+	int cmp;
+
+	while (n) {
+		tmp = rb_entry(n, struct pohmelfs_inode, hash_node);
+
+		cmp = pohmelfs_cmp_hash(&tmp->name, parent, hash, len);
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else
+			return tmp;
+	}
+
+	dprintk("%s: Failed to find a name for parent %llu, hash: %x, len: %u.\n",
+			__func__, parent, hash, len);
+	return NULL;
+}
+
+static struct pohmelfs_inode *pohmelfs_insert_hash(struct rb_root *root,
+		struct pohmelfs_inode *new)
+{
+	struct rb_node **n = &root->rb_node, *parent = NULL;
+	struct pohmelfs_inode *ret = NULL, *tmp;
+	int cmp;
+
+	while (*n) {
+		parent = *n;
+
+		tmp = rb_entry(parent, struct pohmelfs_inode, hash_node);
+
+		cmp = pohmelfs_cmp_hash(&tmp->name, new->parent, new->name.hash, new->name.len);
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
+		dprintk("%s: exist: ino: %lu, hash: %x, data: '%s', new: ino: %lu, hash: %x, data: '%s'.\n",
+				__func__,
+				ret->vfs_inode.i_ino, ret->name.hash, ret->name.data,
+				new->vfs_inode.i_ino, new->name.hash, new->name.data);
+		return ret;
+	}
+
+	rb_link_node(&new->hash_node, parent, n);
+	rb_insert_color(&new->hash_node, root);
+	
+	dprintk("%s: inserted: ino: %lu, hash: %x, data: '%s'.\n",
+			__func__, new->vfs_inode.i_ino, new->name.hash, new->name.data);
+
+	return new;
+}
+
+void pohmelfs_inode_del_inode(struct pohmelfs_sb *psb, struct pohmelfs_inode *pi)
+{
+	struct pohmelfs_name *n;
+	struct rb_node *rb_node;
+
+	mutex_lock(&psb->hash_lock);
+	if (pi->hash_node.rb_parent_color) {
+		rb_erase(&pi->hash_node, &psb->hash_root);
+		pi->hash_node.rb_parent_color = 0;
+	}
+	mutex_unlock(&psb->hash_lock);
+
+	mutex_lock(&pi->offset_lock);
+	for (rb_node = rb_first(&pi->offset_root); rb_node;) {
+		n = rb_entry(rb_node, struct pohmelfs_name, offset_node);
+		rb_node = rb_next(rb_node);
+
+		pohmelfs_name_del(pi, n);
+	}
+	mutex_unlock(&pi->offset_lock);
+
+	dprintk("%s: pi: %p, ino: %llu, name: '%s'.\n",
+			__func__, pi, pi->ino, pi->name.data);
+}
+
+static int netfs_process_page(struct file *file, struct page *page, __u64 cmd_op, __u64 size)
+{
+	struct inode *inode = page->mapping->host;
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	struct netfs_state *st = &psb->state;
+	struct netfs_cmd *cmd = &st->cmd;
+	int err;
+	void *addr;
+
+	mutex_lock(&st->lock);
+
+	cmd->ino = inode->i_ino;
+	cmd->start = page->index << PAGE_CACHE_SHIFT;
+	cmd->size = size;
+	cmd->cmd = cmd_op;
+	cmd->ts = 0;
+
+	dprintk("%s: page: %p, ino: %lu, start: %llu, idx: %lu, cmd: %llu, size: %llu.\n",
+			__func__, page, inode->i_ino, cmd->start, page->index, cmd_op, size);
+
+	netfs_convert_cmd(cmd);
+
+	err = netfs_data_send(st, cmd, sizeof(struct netfs_cmd));
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto out_unlock;
+	}
+
+	addr = kmap(page);
+
+	if (cmd_op == NETFS_READ_PAGE) {
+		err = netfs_data_recv(st, cmd, sizeof(struct netfs_cmd));
+		if (err <= 0) {
+			if (err == 0)
+				err = -ECONNRESET;
+			goto out_unmap;
+		}
+
+		netfs_convert_cmd(cmd);
+
+		if (cmd->start == ~0ULL) {
+			err = -cmd->size;
+			goto out_unmap;
+		}
+
+		if (cmd->size == 0) {
+			err = -EINVAL;
+			goto out_unmap;
+		}
+
+		err = netfs_data_recv(st, addr, cmd->size);
+		if (err <= 0) {
+			if (err == 0)
+				err = -ECONNRESET;
+			goto out_unmap;
+		}
+		
+		if (file)
+			file->f_pos += cmd->size;
+	} else {
+		err = netfs_data_send(st, addr, size);
+		if (err <= 0) {
+			if (err == 0)
+				err = -ECONNRESET;
+			goto out_unmap;
+		}
+
+		err = netfs_data_recv(st, cmd, sizeof(struct netfs_cmd));
+		if (err <= 0) {
+			if (err == 0)
+				err = -ECONNRESET;
+			goto out_unmap;
+		}
+
+		netfs_convert_cmd(cmd);
+
+		if (cmd->start == ~0ULL) {
+			err = -cmd->size;
+			goto out_unmap;
+		}
+	}
+
+	err = 0;
+	SetPageUptodate(page);
+
+out_unmap:
+	kunmap(page);
+out_unlock:
+	mutex_unlock(&st->lock);
+
+	if (err)
+		SetPageError(page);
+	unlock_page(page);
+
+	dprintk("%s: page: %p, start: %llu/%llx, size: %llu, err: %d.\n",
+			__func__, page, cmd->start, cmd->start, cmd->size, err);
+
+	return err;
+}
+
+static int pohmelfs_readpage(struct file *file, struct page *page)
+{
+	return netfs_process_page(file, page, NETFS_READ_PAGE, PAGE_CACHE_SIZE);
+}
+
+static int pohmelfs_writepage(struct page *page, struct writeback_control *wbc)
+{
+	return netfs_process_page(NULL, page, NETFS_WRITE_PAGE, page_private(page));
+}
+
+static int pohmelfs_prepare_write(struct file *file, struct page *page,
+			unsigned from, unsigned to)
+{
+	dprintk("%s: ino: %lu, from: %u, to: %u.\n",
+			__func__, page->mapping->host->i_ino, from, to);
+	SetPagePrivate(page);
+	return 0;
+}
+
+static int pohmelfs_commit_write(struct file *file, struct page *page,
+		unsigned from, unsigned to)
+{
+	struct inode *inode = page->mapping->host;
+	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
+	unsigned end = page_private(page);
+
+	dprintk("%s: ino: %lu, from: %u, to: %u, end: %u, pos: %llu, i_size: %llu.\n",
+			__func__, inode->i_ino, from, to, end, pos, inode->i_size);
+
+	ClearPagePrivate(page);
+	SetPageUptodate(page);
+
+	if (to > end)
+		set_page_private(page, to);
+	set_page_dirty(page);
+
+	/*
+	 * No need to use i_size_read() here, the i_size
+	 * cannot change under us because we hold i_mutex.
+	 */
+	if (pos > inode->i_size) {
+		i_size_write(inode, pos);
+		mark_inode_dirty(inode);
+	}
+	return 0;
+}
+
+const struct address_space_operations pohmelfs_aops = {
+	.readpage		= pohmelfs_readpage,
+	.writepage		= pohmelfs_writepage,
+	.prepare_write		= pohmelfs_prepare_write,
+	.commit_write		= pohmelfs_commit_write,
+};
+
+static void pohmelfs_destroy_inode(struct inode *inode)
+{
+	struct super_block *sb = inode->i_sb;
+	struct pohmelfs_sb *psb = POHMELFS_SB(sb);
+	struct pohmelfs_inode *pi = POHMELFS_I(inode);
+
+	dprintk("%s: inode: %p, vfs_inode: %p.\n",
+			__func__, pi, inode);
+	pohmelfs_inode_del_inode(psb, pi);
+	if (pi->name.data)
+		kfree(pi->name.data);
+	kmem_cache_free(pohmelfs_inode_cache, POHMELFS_I(inode));
+}
+
+static struct inode *pohmelfs_alloc_inode(struct super_block *sb)
+{
+	struct pohmelfs_inode *inode;
+
+	inode = kmem_cache_alloc(pohmelfs_inode_cache, GFP_KERNEL);
+	if (!inode)
+		return NULL;
+	dprintk("%s: inode: %p, vfs_inode: %p.\n",
+			__func__, inode, &inode->vfs_inode);
+
+	inode->hash_node.rb_parent_color = 0;
+
+	inode->offset_root = RB_ROOT;
+	inode->hash_root = RB_ROOT;
+	mutex_init(&inode->offset_lock);
+
+	memset(&inode->name, 0, sizeof(struct pohmelfs_name));
+
+	inode->state = 0;
+	inode->parent = 0;
+
+	return &inode->vfs_inode;
+}
+
+const static struct file_operations pohmelfs_file_ops = {
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
+struct pohmelfs_inode *pohmelfs_fill_inode(struct pohmelfs_inode *pi, struct netfs_inode_info *info)
+{
+	struct inode *inode = &pi->vfs_inode;
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	struct pohmelfs_inode *ret;
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
+	dprintk("%s: inode: %p, num: %lu, parent: %llu hash: %x, data: '%s', "
+			"inode is regular: %d, dir: %d, link: %d, mode: %o.\n",
+			__func__, inode, inode->i_ino, pi->parent,
+			pi->name.hash, pi->name.data,
+			S_ISREG(inode->i_mode), S_ISDIR(inode->i_mode),
+			S_ISLNK(inode->i_mode), inode->i_mode);
+
+	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME_SEC;
+
+	inode->i_blocks = DIV_ROUND_UP(inode->i_size, 512);
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
+
+	mutex_lock(&psb->hash_lock);
+	ret = pohmelfs_insert_hash(&psb->hash_root, pi);
+	mutex_unlock(&psb->hash_lock);
+
+	return ret;
+}
+
+static void pohmelfs_read_inode(struct inode *inode)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(inode->i_sb);
+	struct netfs_state *st = &psb->state;
+	struct netfs_cmd *cmd = &st->cmd;
+	struct pohmelfs_inode *pi = POHMELFS_I(inode), *ret;
+	int err;
+
+	mutex_lock(&st->lock);
+	
+	cmd->ino = inode->i_ino;
+	cmd->cmd = NETFS_READ_INODE;
+	cmd->size = 0;
+	cmd->start = 0;
+	cmd->ts = 0;
+
+	netfs_convert_cmd(cmd);
+	
+	err = netfs_data_send(st, cmd, sizeof(struct netfs_cmd));
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_unlock;
+	}
+
+	err = netfs_data_recv(st, cmd, sizeof(struct netfs_cmd));
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_unlock;
+	}
+
+	netfs_convert_cmd(cmd);
+
+	err = -EINVAL;
+	if (cmd->size != sizeof(struct netfs_inode_info))
+		goto err_out_unlock;
+
+	err = netfs_data_recv(st, &st->info, sizeof(struct netfs_inode_info));
+	if (err <= 0) {
+		if (err == 0)
+			err = -ECONNRESET;
+		goto err_out_unlock;
+	}
+
+	err = -ENODEV;
+	if (cmd->start == ~0ULL)
+		goto err_out_unlock;
+
+	netfs_convert_inode_info(&st->info);
+
+	ret = pohmelfs_fill_inode(pi, &st->info);
+	if (ret != pi)
+		goto err_out_unlock;
+
+	mutex_unlock(&st->lock);
+
+	return;
+
+err_out_unlock:
+	mutex_unlock(&st->lock);
+	make_bad_inode(inode);
+	return;
+}
+
+static void pohmelfs_put_super(struct super_block *sb)
+{
+	struct pohmelfs_sb *psb = POHMELFS_SB(sb);
+	struct rb_node *rb_node;
+	struct pohmelfs_inode *pi;
+
+	while ((rb_node = rb_first(&psb->hash_root)) != NULL) {
+		pi = rb_entry(rb_node, struct pohmelfs_inode, hash_node);
+
+		iput(&pi->vfs_inode);
+	}
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
+static const struct super_operations pohmelfs_sb_ops = {
+	.alloc_inode	= pohmelfs_alloc_inode,
+	.destroy_inode	= pohmelfs_destroy_inode,
+	.read_inode	= pohmelfs_read_inode,
+	.put_super	= pohmelfs_put_super,
+	.remount_fs	= pohmelfs_remount,
+};
+
+static int pohmelfs_fill_super(struct super_block *sb, void *data, int silent)
+{
+	struct pohmelfs_sb *psb;
+	int err = -ENOMEM;
+	struct inode *root;
+	struct pohmelfs_inode *npi;
+
+	psb = kzalloc(sizeof(struct pohmelfs_sb), GFP_KERNEL);
+	if (!psb)
+		goto err_out_exit;
+
+	sb->s_fs_info = psb;
+	sb->s_op = &pohmelfs_sb_ops;
+
+	psb->sb = sb;
+	psb->hash_root = RB_ROOT;
+
+	mutex_init(&psb->hash_lock);
+
+	err = pohmelfs_state_init(&psb->state, 0);
+	if (err)
+		goto err_out_free_sb;
+
+	npi = pohmelfs_process_lookup_request(psb, NULL, "/", 1, full_name_hash("/", 1));
+	if (IS_ERR(npi) || !npi) {
+		err = PTR_ERR(npi);
+		if (!err)
+			err = -ENODEV;
+		goto err_out_state_exit;
+	}
+
+	root = &npi->vfs_inode;
+
+	sb->s_root = d_alloc_root(root);
+	if (!sb->s_root)
+		goto err_out_put_root;
+
+	return 0;
+
+err_out_put_root:
+	iput(root);
+err_out_state_exit:
+	pohmelfs_state_exit(&psb->state);
+err_out_free_sb:
+	kfree(psb);
+err_out_exit:
+	return err;
+}
+
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
+static void pohmelfs_init_once(void *data, struct kmem_cache *cachep, unsigned long flags)
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
index 0000000..b886ad3
--- /dev/null
+++ b/fs/pohmelfs/net.c
@@ -0,0 +1,112 @@
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
+#include "netfs.h"
+
+int netfs_data_recv(struct netfs_state *st, void *buf, u64 size)
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
+	msg.msg_flags = MSG_WAITALL;
+
+	err = kernel_recvmsg(st->socket, &msg, &iov, 1, iov.iov_len,
+			msg.msg_flags);
+	if (err <= 0) {
+		printk("%s: failed to receive data: size: %llu, err: %d.\n", __func__, size, err);
+	}
+
+	return err;
+}
+
+int netfs_data_send(struct netfs_state *st, void *buf, u64 size)
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
+	msg.msg_flags = MSG_WAITALL;
+
+	err = kernel_sendmsg(st->socket, &msg, &iov, 1, iov.iov_len);
+	if (err <= 0) {
+		printk("%s: failed to send data: size: %llu, err: %d.\n", __func__, size, err);
+	}
+
+	return err;
+}
+
+int pohmelfs_state_init(struct netfs_state *st, unsigned int idx)
+{
+	int err = -ENOMEM;
+	struct pohmelfs_ctl *ctl;
+
+	mutex_init(&st->lock);
+
+	ctl = kzalloc(sizeof(struct pohmelfs_ctl), GFP_KERNEL);
+	if (!ctl)
+		goto err_out_exit;
+
+	err = pohmelfs_copy_config(ctl, idx);
+	if (err)
+		goto err_out_exit;
+
+	err = sock_create(ctl->addr.sa_family, ctl->type, ctl->proto, &st->socket);
+	if (err)
+		goto err_out_free;
+
+	err = st->socket->ops->connect(st->socket,
+			(struct sockaddr *)&ctl->addr, ctl->addrlen, 0);
+	if (err)
+		goto err_out_release;
+
+	st->socket->sk->sk_allocation = GFP_NOIO;
+
+	return 0;
+
+err_out_release:
+	sock_release(st->socket);
+err_out_free:
+	kfree(ctl);
+err_out_exit:
+	return err;
+}
+
+void pohmelfs_state_exit(struct netfs_state *st)
+{
+	sock_release(st->socket);
+}
diff --git a/fs/pohmelfs/netfs.h b/fs/pohmelfs/netfs.h
new file mode 100644
index 0000000..23aa953
--- /dev/null
+++ b/fs/pohmelfs/netfs.h
@@ -0,0 +1,254 @@
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
+struct netfs_cmd
+{
+	__u64			cmd;
+	__u64			ino;
+	__u64			flags;
+	__u64			ts;
+	__u64			size;
+	__u64			start;
+	__u8			data[];
+};
+
+static inline void netfs_convert_cmd(struct netfs_cmd *cmd)
+{
+	cmd->cmd = __be64_to_cpu(cmd->cmd);
+	cmd->ino = __be64_to_cpu(cmd->ino);
+	cmd->ts = __be64_to_cpu(cmd->ts);
+	cmd->size = __be64_to_cpu(cmd->size);
+	cmd->start = __be64_to_cpu(cmd->start);
+	cmd->flags = __be64_to_cpu(cmd->flags);
+}
+
+enum {
+	NETFS_READDIR	= 1,	/* Read directory for given inode number */
+	NETFS_LOOKUP,		/* Lookup inode for given name */
+	NETFS_READ_INODE,	/* Read inode data */
+	NETFS_READ_PAGE,	/* Read data page from the server */
+	NETFS_WRITE_PAGE,	/* Write data page to the server */
+	NETFS_CREATE,		/* Create directory entry */
+	NETFS_REMOVE,		/* Remove directory entry */
+	NETFS_STATE,		/* State change message */
+	NETFS_CMD_MAX
+};
+
+#define _K_SS_MAXSIZE	128
+
+struct saddr
+{
+	unsigned short		sa_family;
+	char			addr[_K_SS_MAXSIZE];
+};
+
+struct pohmelfs_ctl
+{
+	unsigned int		idx;
+	unsigned int		type;
+	unsigned int		proto;
+	unsigned int		addrlen;
+	struct saddr		addr;
+};
+
+struct pohmelfs_cn_ack
+{
+	struct cn_msg		msg;
+	int			error;
+	int			unused[3];
+};
+
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
+static inline __u32 netfs_get_inode_hash(struct netfs_cmd *cmd)
+{
+	return cmd->flags >> 32;
+}
+
+static inline __u32 netfs_get_inode_mode(struct netfs_cmd *cmd)
+{
+	return cmd->flags & 0xffffffff;
+}
+
+static inline void netfs_set_cmd_flags(struct netfs_cmd *cmd, __u32 hash, __u32 type)
+{
+	cmd->flags = hash;
+	cmd->flags <<= 32;
+	cmd->flags |= type;
+}
+
+enum {
+	NETFS_STATE_SYNC = 0,		/* Inode is in sync */
+};
+
+#ifdef __KERNEL__
+
+#include <linux/kernel.h>
+#include <linux/rbtree.h>
+#include <linux/net.h>
+
+struct pohmelfs_name
+{
+	struct rb_node		offset_node;
+	struct rb_node		hash_node;
+
+	u64			ino, parent;
+
+	u64			offset;
+
+	u32			mode;
+	u32			hash;
+	u32			len;
+	char			*data;
+};
+
+struct pohmelfs_inode
+{
+	struct rb_node		hash_node;
+
+	struct rb_root		hash_root;
+	struct rb_root		offset_root;
+	struct mutex		offset_lock;
+
+	long			state;
+
+	u64			ino;
+	u64			parent;
+
+	struct pohmelfs_name	name;
+
+	struct inode		vfs_inode;
+};
+
+struct netfs_state
+{
+	struct mutex		lock;
+	struct netfs_cmd 	cmd;
+	struct netfs_inode_info	info;
+	struct socket		*socket;
+};
+
+struct pohmelfs_sb
+{
+	struct rb_root		hash_root;
+	struct mutex		hash_lock;
+
+	struct super_block	*sb;
+
+	struct netfs_state	state;
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
+extern int __init pohmelfs_config_init(void);
+extern void __exit pohmelfs_config_exit(void);
+extern int pohmelfs_copy_config(struct pohmelfs_ctl *dst, unsigned int idx);
+
+extern const struct file_operations pohmelfs_dir_fops;
+extern const struct inode_operations pohmelfs_dir_inode_ops;
+
+extern int netfs_data_recv(struct netfs_state *st, void *buf, u64 size);
+extern int netfs_data_send(struct netfs_state *st, void *buf, u64 size);
+extern int pohmelfs_state_init(struct netfs_state *st, unsigned int idx);
+extern void pohmelfs_state_exit(struct netfs_state *st);
+
+extern struct pohmelfs_inode *pohmelfs_fill_inode(struct pohmelfs_inode *pi,
+		struct netfs_inode_info *info);
+
+static inline int pohmelfs_cmp_hash(struct pohmelfs_name *n, u64 parent, u32 hash, u32 len)
+{
+	if (n->parent > parent)
+		return -1;
+	if (n->parent < parent)
+		return 1;
+
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
+extern struct pohmelfs_inode *pohmelfs_search_hash(struct rb_root *root,
+		u64 parent, u32 hash, u32 len);
+
+extern struct pohmelfs_inode *pohmelfs_process_lookup_request(struct pohmelfs_sb *psb,
+		struct pohmelfs_inode *parent, char *name, __u32 len, __u32 hash);
+
+void pohmelfs_name_del(struct pohmelfs_inode *parent, struct pohmelfs_name *n);
+
+void pohmelfs_inode_del_inode(struct pohmelfs_sb *psb, struct pohmelfs_inode *pi);
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

-- 
	Evgeniy Polyakov
