From: Evgeniy Polyakov <zbe@ioremap.net>
Subject: [4/9] pohmelfs: directory operations.
Date: Fri, 26 Dec 2008 17:18:45 +0300
Message-ID: <1230301130-1325-5-git-send-email-zbe@ioremap.net>
References: <1230301130-1325-1-git-send-email-zbe@ioremap.net>
 <1230301130-1325-2-git-send-email-zbe@ioremap.net>
 <1230301130-1325-3-git-send-email-zbe@ioremap.net>
 <1230301130-1325-4-git-send-email-zbe@ioremap.net>
Cc: linux-kernel@vger.kernel.org, pohmelfs@ioremap.net,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1230301130-1325-4-git-send-email-zbe@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implementes all supported directory operations
like directory reading, object lookup, creation, removal
and so on.

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/fs/pohmelfs/dir.c b/fs/pohmelfs/dir.c
new file mode 100644
index 0000000..29eda12
--- /dev/null
+++ b/fs/pohmelfs/dir.c
@@ -0,0 +1,1139 @@
+/*
+ * 2007+ Copyright (c) Evgeniy Polyakov <zbr@ioremap.net>
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
+struct pohmelfs_name *pohmelfs_search_hash(struct pohmelfs_inode *pi, u32 hash)
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
+		printk("%s: exist: parent: %llu, ino: %llu, hash: %x, len: %u, data: '%s', "
+				           "new: ino: %llu, hash: %x, len: %u, data: '%s'.\n",
+				__func__, pi->ino,
+				ret->ino, ret->hash, ret->len, ret->data,
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
+	sprintf(n->data, "%s", str->name);
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
+		psb->avail_size += inode->i_size;
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
+	sprintf(n->data, "%s", str.name);
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
