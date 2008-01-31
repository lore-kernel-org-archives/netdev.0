From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [2/2] POHMELFS: hack to disable writeback.
Date: Thu, 31 Jan 2008 22:17:31 +0300
Message-ID: <20080131191731.GA13476@2ka.mipt.ru>
References: <11972872493911@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:52943 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765903AbYAaTSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 14:18:15 -0500
Content-Disposition: inline
In-Reply-To: <11972872493911@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch disables writeback in POHMELFS and creates all objects
on behalf of its own without sync with remote side.
This mode is _very_ fast.

If POHEMLFS would be bound to single remote filesystem, it could
use its inode allocation policy and be very happy with write-back cache.
By design POHMELFS is a transport layer in distributed filesystem,
which will work with some or other remote filesystem (likely completely
new one), so instead of stupid algorithm shown here, it will contain
correct object creation.

Likely the way to go is to use name hash with parent inode number as
unique ID, which can be matched to filesystem path, so that remote side
could create objects without _any_ knowledge of inode numbers on the
local fs.

Crappy-stuff-created-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/fs/pohmelfs/dir.c b/fs/pohmelfs/dir.c
index 23f9ecd..5aec593 100644
--- a/fs/pohmelfs/dir.c
+++ b/fs/pohmelfs/dir.c
@@ -80,6 +80,8 @@ static struct pohmelfs_name *pohmelfs_insert_offset(struct pohmelfs_inode *pi,
 	rb_link_node(&new->offset_node, parent, n);
 	rb_insert_color(&new->offset_node, &pi->offset_root);
 
+	pi->total_len += new->len;
+
 	return NULL;
 }
 
@@ -647,6 +649,7 @@ static int pohmelfs_create_entry(struct inode *dir, struct dentry *dentry, u64 s
 	cmd->start = start;
 	netfs_set_cmd_flags(cmd, dentry->d_name.hash, mode);
 
+#if 0
 	netfs_convert_cmd(cmd);
 
 	err = netfs_data_send(st, cmd, sizeof(struct netfs_cmd));
@@ -666,6 +669,30 @@ static int pohmelfs_create_entry(struct inode *dir, struct dentry *dentry, u64 s
 	err = netfs_recv_inode_info(psb, POHMELFS_I(dir), &npi, data);
 	if (err < 0)
 		goto err_out_unlock;
+#else
+	{
+		static u64 pohmelfs_ino = 123;
+
+		st->info.mode = netfs_get_inode_mode(cmd);
+		st->info.ino = pohmelfs_ino++;
+		st->info.nlink = 2;
+		st->info.uid = 2319;
+		st->info.gid = 100;
+
+		cmd->ino = st->info.ino;
+		cmd->start = POHMELFS_I(dir)->total_len;
+	}
+
+	npi = pohmelfs_new_inode(psb, POHMELFS_I(dir), data, cmd, &st->info);
+	if (IS_ERR(npi)) {
+		err = PTR_ERR(npi);
+		if (err != -EEXIST)
+			goto err_out_unlock;
+		npi = NULL;
+	} else
+		err = 0;
+	npi->state = 1;
+#endif
 	mutex_unlock(&st->lock);
 
 	d_add(dentry, &npi->vfs_inode);
diff --git a/fs/pohmelfs/inode.c b/fs/pohmelfs/inode.c
index b0ee0b3..6a81bdc 100644
--- a/fs/pohmelfs/inode.c
+++ b/fs/pohmelfs/inode.c
@@ -125,6 +125,16 @@ static int netfs_process_page(struct file *file, struct page *page, __u64 cmd_op
 	int err;
 	void *addr;
 
+	{
+		if (cmd_op == NETFS_READ_PAGE) {
+			if (file)
+				file->f_pos += cmd->size;
+		}
+		SetPageUptodate(page);
+		unlock_page(page);
+		return 0;
+	}
+
 	mutex_lock(&st->lock);
 
 	cmd->ino = inode->i_ino;
@@ -305,6 +315,7 @@ static struct inode *pohmelfs_alloc_inode(struct super_block *sb)
 
 	inode->state = 0;
 	inode->parent = 0;
+	inode->total_len = 0;
 
 	return &inode->vfs_inode;
 }
diff --git a/fs/pohmelfs/netfs.h b/fs/pohmelfs/netfs.h
index 23aa953..b719fbe 100644
--- a/fs/pohmelfs/netfs.h
+++ b/fs/pohmelfs/netfs.h
@@ -163,6 +163,8 @@ struct pohmelfs_inode
 	u64			ino;
 	u64			parent;
 
+	u64			total_len;
+
 	struct pohmelfs_name	name;
 
 	struct inode		vfs_inode;
 

-- 
	Evgeniy Polyakov
