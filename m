From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, inode: add support for symlinks and fix mtime/ctime
Date: Sat, 29 Oct 2016 02:30:46 +0200
Message-ID: <f94e5717c5c494ac054365dee59bf71624702a4a.1477700084.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org, tgraf@suug.ch,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54121 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935767AbcJ2Aa6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 20:30:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While commit bb35a6ef7da4 ("bpf, inode: allow for rename and link ops")
added support for hard links that can be used for prog and map nodes,
this work adds simple symlink support, which can be used f.e. for
directories also when unpriviledged and works with cmdline tooling that
understands S_IFLNK anyway. Since the switch in e27f4a942a0e ("bpf: Use
mount_nodev not mount_ns to mount the bpf filesystem"), there can be
various mount instances with mount_nodev() and thus hierarchy can be
flattened to facilitate object sharing. Thus, we can keep bpf tooling
also working by repointing paths.

Most of the functionality can be used from vfs library operations. The
symlink is stored in the inode itself, that is in i_link, which is
sufficient in our case as opposed to storing it in the page cache.
While at it, I noticed that bpf_mkdir() and bpf_mkobj() don't update
the directories mtime and ctime, so add a common helper for it called
bpf_dentry_finalize() that takes care of it for all cases now.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/inode.c | 45 +++++++++++++++++++++++++++++++++++++++------
 1 file changed, 39 insertions(+), 6 deletions(-)

diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index 1ed8473..2565809 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -87,6 +87,7 @@ static struct inode *bpf_get_inode(struct super_block *sb,
 	switch (mode & S_IFMT) {
 	case S_IFDIR:
 	case S_IFREG:
+	case S_IFLNK:
 		break;
 	default:
 		return ERR_PTR(-EINVAL);
@@ -119,6 +120,16 @@ static int bpf_inode_type(const struct inode *inode, enum bpf_type *type)
 	return 0;
 }
 
+static void bpf_dentry_finalize(struct dentry *dentry, struct inode *inode,
+				struct inode *dir)
+{
+	d_instantiate(dentry, inode);
+	dget(dentry);
+
+	dir->i_mtime = current_time(dir);
+	dir->i_ctime = dir->i_mtime;
+}
+
 static int bpf_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 {
 	struct inode *inode;
@@ -133,9 +144,7 @@ static int bpf_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 	inc_nlink(inode);
 	inc_nlink(dir);
 
-	d_instantiate(dentry, inode);
-	dget(dentry);
-
+	bpf_dentry_finalize(dentry, inode, dir);
 	return 0;
 }
 
@@ -151,9 +160,7 @@ static int bpf_mkobj_ops(struct inode *dir, struct dentry *dentry,
 	inode->i_op = iops;
 	inode->i_private = dentry->d_fsdata;
 
-	d_instantiate(dentry, inode);
-	dget(dentry);
-
+	bpf_dentry_finalize(dentry, inode, dir);
 	return 0;
 }
 
@@ -181,13 +188,37 @@ static int bpf_mkobj(struct inode *dir, struct dentry *dentry, umode_t mode,
 {
 	if (strchr(dentry->d_name.name, '.'))
 		return ERR_PTR(-EPERM);
+
 	return simple_lookup(dir, dentry, flags);
 }
 
+static int bpf_symlink(struct inode *dir, struct dentry *dentry,
+		       const char *target)
+{
+	char *link = kstrdup(target, GFP_USER | __GFP_NOWARN);
+	struct inode *inode;
+
+	if (!link)
+		return -ENOMEM;
+
+	inode = bpf_get_inode(dir->i_sb, dir, S_IRWXUGO | S_IFLNK);
+	if (IS_ERR(inode)) {
+		kfree(link);
+		return PTR_ERR(inode);
+	}
+
+	inode->i_op = &simple_symlink_inode_operations;
+	inode->i_link = link;
+
+	bpf_dentry_finalize(dentry, inode, dir);
+	return 0;
+}
+
 static const struct inode_operations bpf_dir_iops = {
 	.lookup		= bpf_lookup,
 	.mknod		= bpf_mkobj,
 	.mkdir		= bpf_mkdir,
+	.symlink	= bpf_symlink,
 	.rmdir		= simple_rmdir,
 	.rename		= simple_rename,
 	.link		= simple_link,
@@ -324,6 +355,8 @@ static void bpf_evict_inode(struct inode *inode)
 	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 
+	if (S_ISLNK(inode->i_mode))
+		kfree(inode->i_link);
 	if (!bpf_inode_type(inode, &type))
 		bpf_any_put(inode->i_private, type);
 }
-- 
1.9.3
