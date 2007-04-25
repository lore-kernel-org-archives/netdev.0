From: David Howells <dhowells@redhat.com>
Subject: [PATCH 16/16] AFS: Add "directory write" support [try #4]
Date: Wed, 25 Apr 2007 16:50:19 +0100
Message-ID: <20070425155019.26581.8741.stgit@warthog.cambridge.redhat.com>
References: <20070425154854.26581.97692.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031129AbXDYPus (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 11:50:48 -0400
In-Reply-To: <20070425154854.26581.97692.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for the create, link, symlink, unlink, mkdir, rmdir and rename VFS
operations to the in-kernel AFS filesystem.

Also:

 (1) Fix dentry and inode revalidation.  d_revalidate should only look at
     state of the dentry.  Revalidation of the contents of an inode pointed to
     by a dentry is now separate.

 (2) Fix afs_lookup() to hash negative dentries as well as positive ones.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 fs/afs/afs.h      |   26 ++
 fs/afs/afs_fs.h   |   11 +
 fs/afs/callback.c |   36 +++
 fs/afs/dir.c      |  676 ++++++++++++++++++++++++++++++++++++++++++-----------
 fs/afs/file.c     |    7 +
 fs/afs/fsclient.c |  625 +++++++++++++++++++++++++++++++++++++++++++++----
 fs/afs/inode.c    |  115 ++++++++-
 fs/afs/internal.h |   54 ++++
 fs/afs/misc.c     |   21 ++
 fs/afs/security.c |   31 ++
 fs/afs/server.c   |    2 
 fs/afs/super.c    |    6 
 fs/afs/vnode.c    |  422 +++++++++++++++++++++++++++++++--
 fs/afs/volume.c   |   14 +
 14 files changed, 1778 insertions(+), 268 deletions(-)

diff --git a/fs/afs/afs.h b/fs/afs/afs.h
index 3f255d6..085cf60 100644
--- a/fs/afs/afs.h
+++ b/fs/afs/afs.h
@@ -106,19 +106,37 @@ struct afs_file_status {
 
 	afs_file_type_t		type;		/* file type */
 	unsigned		nlink;		/* link count */
-	size_t			size;		/* file size */
+	u64			size;		/* file size */
 	afs_dataversion_t	data_version;	/* current data version */
-	unsigned		author;		/* author ID */
-	unsigned		owner;		/* owner ID */
+	u32			author;		/* author ID */
+	u32			owner;		/* owner ID */
+	u32			group;		/* group ID */
 	afs_access_t		caller_access;	/* access rights for authenticated caller */
 	afs_access_t		anon_access;	/* access rights for unauthenticated caller */
 	umode_t			mode;		/* UNIX mode */
-	struct afs_fid		parent;		/* parent file ID */
+	struct afs_fid		parent;		/* parent dir ID for non-dirs only */
 	time_t			mtime_client;	/* last time client changed data */
 	time_t			mtime_server;	/* last time server changed data */
 };
 
 /*
+ * AFS file status change request
+ */
+struct afs_store_status {
+	u32			mask;		/* which bits of the struct are set */
+	u32			mtime_client;	/* last time client changed data */
+	u32			owner;		/* owner ID */
+	u32			group;		/* group ID */
+	umode_t			mode;		/* UNIX mode */
+};
+
+#define AFS_SET_MTIME		0x01		/* set the mtime */
+#define AFS_SET_OWNER		0x02		/* set the owner ID */
+#define AFS_SET_GROUP		0x04		/* set the group ID (unsupported?) */
+#define AFS_SET_MODE		0x08		/* set the UNIX mode */
+#define AFS_SET_SEG_SIZE	0x10		/* set the segment size (unsupported) */
+
+/*
  * AFS volume synchronisation information
  */
 struct afs_volsync {
diff --git a/fs/afs/afs_fs.h b/fs/afs/afs_fs.h
index fd38595..89e0d16 100644
--- a/fs/afs/afs_fs.h
+++ b/fs/afs/afs_fs.h
@@ -16,12 +16,19 @@
 #define FS_SERVICE		1	/* AFS File Service ID */
 
 enum AFS_FS_Operations {
-	FSFETCHSTATUS		= 132,	/* AFS Fetch file status */
 	FSFETCHDATA		= 130,	/* AFS Fetch file data */
+	FSFETCHSTATUS		= 132,	/* AFS Fetch file status */
+	FSREMOVEFILE		= 136,	/* AFS Remove a file */
+	FSCREATEFILE		= 137,	/* AFS Create a file */
+	FSRENAME		= 138,	/* AFS Rename or move a file or directory */
+	FSSYMLINK		= 139,	/* AFS Create a symbolic link */
+	FSLINK			= 140,	/* AFS Create a hard link */
+	FSMAKEDIR		= 141,	/* AFS Create a directory */
+	FSREMOVEDIR		= 142,	/* AFS Remove a directory */
 	FSGIVEUPCALLBACKS	= 147,	/* AFS Discard callback promises */
 	FSGETVOLUMEINFO		= 148,	/* AFS Get root volume information */
 	FSGETROOTVOLUME		= 151,	/* AFS Get root volume name */
-	FSLOOKUP		= 161	/* AFS lookup file in directory */
+	FSLOOKUP		= 161,	/* AFS lookup file in directory */
 };
 
 enum AFS_FS_Errors {
diff --git a/fs/afs/callback.c b/fs/afs/callback.c
index e674beb..639399f 100644
--- a/fs/afs/callback.c
+++ b/fs/afs/callback.c
@@ -44,7 +44,8 @@ void afs_init_callback_state(struct afs_server *server)
 	while (!RB_EMPTY_ROOT(&server->cb_promises)) {
 		vnode = rb_entry(server->cb_promises.rb_node,
 				 struct afs_vnode, cb_promise);
-		printk("\nUNPROMISE on %p\n", vnode);
+		_debug("UNPROMISE { vid=%x vn=%u uq=%u}",
+		       vnode->fid.vid, vnode->fid.vnode, vnode->fid.unique);
 		rb_erase(&vnode->cb_promise, &server->cb_promises);
 		vnode->cb_promised = false;
 	}
@@ -68,7 +69,7 @@ void afs_broken_callback_work(struct work_struct *work)
 
 	/* we're only interested in dealing with a broken callback on *this*
 	 * vnode and only if no-one else has dealt with it yet */
-	if (!mutex_trylock(&vnode->cb_broken_lock))
+	if (!mutex_trylock(&vnode->validate_lock))
 		return; /* someone else is dealing with it */
 
 	if (test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags)) {
@@ -84,13 +85,14 @@ void afs_broken_callback_work(struct work_struct *work)
 		/* if the vnode's data version number changed then its contents
 		 * are different */
 		if (test_and_clear_bit(AFS_VNODE_ZAP_DATA, &vnode->flags)) {
-			_debug("zap data");
+			_debug("zap data {%x:%u}",
+			       vnode->fid.vid, vnode->fid.vnode);
 			invalidate_remote_inode(&vnode->vfs_inode);
 		}
 	}
 
 out:
-	mutex_unlock(&vnode->cb_broken_lock);
+	mutex_unlock(&vnode->validate_lock);
 
 	/* avoid the potential race whereby the mutex_trylock() in this
 	 * function happens again between the clear_bit() and the
@@ -252,6 +254,32 @@ static void afs_do_give_up_callback(struct afs_server *server,
 }
 
 /*
+ * discard the callback on a deleted item
+ */
+void afs_discard_callback_on_delete(struct afs_vnode *vnode)
+{
+	struct afs_server *server = vnode->server;
+
+	_enter("%d", vnode->cb_promised);
+
+	if (!vnode->cb_promised) {
+		_leave(" [not promised]");
+		return;
+	}
+
+	ASSERT(server != NULL);
+
+	spin_lock(&server->cb_lock);
+	if (vnode->cb_promised) {
+		ASSERT(server->cb_promises.rb_node != NULL);
+		rb_erase(&vnode->cb_promise, &server->cb_promises);
+		vnode->cb_promised = false;
+	}
+	spin_unlock(&server->cb_lock);
+	_leave("");
+}
+
+/*
  * give up the callback registered for a vnode on the file server when the
  * inode is being cleared
  */
diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index 8736841..dbbe75d 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -18,40 +18,50 @@
 #include <linux/ctype.h>
 #include "internal.h"
 
-static struct dentry *afs_dir_lookup(struct inode *dir, struct dentry *dentry,
-				     struct nameidata *nd);
+static struct dentry *afs_lookup(struct inode *dir, struct dentry *dentry,
+				 struct nameidata *nd);
 static int afs_dir_open(struct inode *inode, struct file *file);
-static int afs_dir_readdir(struct file *file, void *dirent, filldir_t filldir);
+static int afs_readdir(struct file *file, void *dirent, filldir_t filldir);
 static int afs_d_revalidate(struct dentry *dentry, struct nameidata *nd);
 static int afs_d_delete(struct dentry *dentry);
-static int afs_dir_lookup_filldir(void *_cookie, const char *name, int nlen,
+static void afs_d_release(struct dentry *dentry);
+static int afs_lookup_filldir(void *_cookie, const char *name, int nlen,
 				  loff_t fpos, u64 ino, unsigned dtype);
+static int afs_create(struct inode *dir, struct dentry *dentry, int mode,
+		      struct nameidata *nd);
+static int afs_mkdir(struct inode *dir, struct dentry *dentry, int mode);
+static int afs_rmdir(struct inode *dir, struct dentry *dentry);
+static int afs_unlink(struct inode *dir, struct dentry *dentry);
+static int afs_link(struct dentry *from, struct inode *dir,
+		    struct dentry *dentry);
+static int afs_symlink(struct inode *dir, struct dentry *dentry,
+		       const char *content);
+static int afs_rename(struct inode *old_dir, struct dentry *old_dentry,
+		      struct inode *new_dir, struct dentry *new_dentry);
 
 const struct file_operations afs_dir_file_operations = {
 	.open		= afs_dir_open,
 	.release	= afs_release,
-	.readdir	= afs_dir_readdir,
+	.readdir	= afs_readdir,
 };
 
 const struct inode_operations afs_dir_inode_operations = {
-	.lookup		= afs_dir_lookup,
+	.create		= afs_create,
+	.lookup		= afs_lookup,
+	.link		= afs_link,
+	.unlink		= afs_unlink,
+	.symlink	= afs_symlink,
+	.mkdir		= afs_mkdir,
+	.rmdir		= afs_rmdir,
+	.rename		= afs_rename,
 	.permission	= afs_permission,
 	.getattr	= afs_inode_getattr,
-#if 0 /* TODO */
-	.create		= afs_dir_create,
-	.link		= afs_dir_link,
-	.unlink		= afs_dir_unlink,
-	.symlink	= afs_dir_symlink,
-	.mkdir		= afs_dir_mkdir,
-	.rmdir		= afs_dir_rmdir,
-	.mknod		= afs_dir_mknod,
-	.rename		= afs_dir_rename,
-#endif
 };
 
 static struct dentry_operations afs_fs_dentry_operations = {
 	.d_revalidate	= afs_d_revalidate,
 	.d_delete	= afs_d_delete,
+	.d_release	= afs_d_release,
 };
 
 #define AFS_DIR_HASHTBL_SIZE	128
@@ -103,7 +113,7 @@ struct afs_dir_page {
 	union afs_dir_block blocks[PAGE_SIZE / sizeof(union afs_dir_block)];
 };
 
-struct afs_dir_lookup_cookie {
+struct afs_lookup_cookie {
 	struct afs_fid	fid;
 	const char	*name;
 	size_t		nlen;
@@ -299,7 +309,7 @@ static int afs_dir_iterate_block(unsigned *fpos,
 			      nlen,
 			      blkoff + offset * sizeof(union afs_dirent),
 			      ntohl(dire->u.vnode),
-			      filldir == afs_dir_lookup_filldir ?
+			      filldir == afs_lookup_filldir ?
 			      ntohl(dire->u.unique) : DT_UNKNOWN);
 		if (ret < 0) {
 			_leave(" = 0 [full]");
@@ -379,7 +389,7 @@ out:
 /*
  * read an AFS directory
  */
-static int afs_dir_readdir(struct file *file, void *cookie, filldir_t filldir)
+static int afs_readdir(struct file *file, void *cookie, filldir_t filldir)
 {
 	unsigned fpos;
 	int ret;
@@ -403,10 +413,10 @@ static int afs_dir_readdir(struct file *file, void *cookie, filldir_t filldir)
  * - if afs_dir_iterate_block() spots this function, it'll pass the FID
  *   uniquifier through dtype
  */
-static int afs_dir_lookup_filldir(void *_cookie, const char *name, int nlen,
-				  loff_t fpos, u64 ino, unsigned dtype)
+static int afs_lookup_filldir(void *_cookie, const char *name, int nlen,
+			      loff_t fpos, u64 ino, unsigned dtype)
 {
-	struct afs_dir_lookup_cookie *cookie = _cookie;
+	struct afs_lookup_cookie *cookie = _cookie;
 
 	_enter("{%s,%Zu},%s,%u,,%llu,%u",
 	       cookie->name, cookie->nlen, name, nlen, ino, dtype);
@@ -430,11 +440,12 @@ static int afs_dir_lookup_filldir(void *_cookie, const char *name, int nlen,
 
 /*
  * do a lookup in a directory
+ * - just returns the FID the dentry name maps to if found
  */
 static int afs_do_lookup(struct inode *dir, struct dentry *dentry,
 			 struct afs_fid *fid, struct key *key)
 {
-	struct afs_dir_lookup_cookie cookie;
+	struct afs_lookup_cookie cookie;
 	struct afs_super_info *as;
 	unsigned fpos;
 	int ret;
@@ -450,7 +461,7 @@ static int afs_do_lookup(struct inode *dir, struct dentry *dentry,
 	cookie.found	= 0;
 
 	fpos = 0;
-	ret = afs_dir_iterate(dir, &fpos, &cookie, afs_dir_lookup_filldir,
+	ret = afs_dir_iterate(dir, &fpos, &cookie, afs_lookup_filldir,
 			      key);
 	if (ret < 0) {
 		_leave(" = %d [iter]", ret);
@@ -471,8 +482,8 @@ static int afs_do_lookup(struct inode *dir, struct dentry *dentry,
 /*
  * look up an entry in a directory
  */
-static struct dentry *afs_dir_lookup(struct inode *dir, struct dentry *dentry,
-				     struct nameidata *nd)
+static struct dentry *afs_lookup(struct inode *dir, struct dentry *dentry,
+				 struct nameidata *nd)
 {
 	struct afs_vnode *vnode;
 	struct afs_fid fid;
@@ -480,14 +491,18 @@ static struct dentry *afs_dir_lookup(struct inode *dir, struct dentry *dentry,
 	struct key *key;
 	int ret;
 
-	_enter("{%lu},%p{%s}", dir->i_ino, dentry, dentry->d_name.name);
+	vnode = AFS_FS_I(dir);
+
+	_enter("{%x:%d},%p{%s},",
+	       vnode->fid.vid, vnode->fid.vnode, dentry, dentry->d_name.name);
+
+	ASSERTCMP(dentry->d_inode, ==, NULL);
 
 	if (dentry->d_name.len > 255) {
 		_leave(" = -ENAMETOOLONG");
 		return ERR_PTR(-ENAMETOOLONG);
 	}
 
-	vnode = AFS_FS_I(dir);
 	if (test_bit(AFS_VNODE_DELETED, &vnode->flags)) {
 		_leave(" = -ESTALE");
 		return ERR_PTR(-ESTALE);
@@ -499,15 +514,28 @@ static struct dentry *afs_dir_lookup(struct inode *dir, struct dentry *dentry,
 		return ERR_PTR(PTR_ERR(key));
 	}
 
+	ret = afs_validate(vnode, key);
+	if (ret < 0) {
+		key_put(key);
+		_leave(" = %d [val]", ret);
+		return ERR_PTR(ret);
+	}
+
 	ret = afs_do_lookup(dir, dentry, &fid, key);
 	if (ret < 0) {
 		key_put(key);
+		if (ret == -ENOENT) {
+			d_add(dentry, NULL);
+			_leave(" = NULL [negative]");
+			return NULL;
+		}
 		_leave(" = %d [do]", ret);
 		return ERR_PTR(ret);
 	}
+	dentry->d_fsdata = (void *)(unsigned long) vnode->status.data_version;
 
 	/* instantiate the dentry */
-	inode = afs_iget(dir->i_sb, key, &fid);
+	inode = afs_iget(dir->i_sb, key, &fid, NULL, NULL);
 	key_put(key);
 	if (IS_ERR(inode)) {
 		_leave(" = %ld", PTR_ERR(inode));
@@ -527,105 +555,64 @@ static struct dentry *afs_dir_lookup(struct inode *dir, struct dentry *dentry,
 }
 
 /*
- * propagate changed and modified flags on a directory to all the children of
- * that directory as they may indicate that the ACL on the dir has changed,
- * potentially rendering the child inaccessible or that a file has been deleted
- * or renamed
- */
-static void afs_propagate_dir_changes(struct dentry *dir)
-{
-	struct dentry *child;
-	bool c, m;
-
-	c = test_bit(AFS_VNODE_CHANGED, &AFS_FS_I(dir->d_inode)->flags);
-	m = test_bit(AFS_VNODE_MODIFIED, &AFS_FS_I(dir->d_inode)->flags);
-
-	_enter("{%d,%d}", c, m);
-
-	spin_lock(&dir->d_lock);
-
-	list_for_each_entry(child, &dir->d_subdirs, d_u.d_child) {
-		if (child->d_inode) {
-			struct afs_vnode *vnode;
-
-			_debug("tag %s", child->d_name.name);
-			vnode = AFS_FS_I(child->d_inode);
-			if (c)
-				set_bit(AFS_VNODE_DIR_CHANGED, &vnode->flags);
-			if (m)
-				set_bit(AFS_VNODE_DIR_MODIFIED, &vnode->flags);
-		}
-	}
-
-	spin_unlock(&dir->d_lock);
-}
-
-/*
  * check that a dentry lookup hit has found a valid entry
  * - NOTE! the hit can be a negative hit too, so we can't assume we have an
  *   inode
- * - there are several things we need to check
- *   - parent dir data changes (rm, rmdir, rename, mkdir, create, link,
- *     symlink)
- *   - parent dir metadata changed (security changes)
- *   - dentry data changed (write, truncate)
- *   - dentry metadata changed (security changes)
  */
 static int afs_d_revalidate(struct dentry *dentry, struct nameidata *nd)
 {
-	struct afs_vnode *vnode;
+	struct afs_vnode *vnode, *dir;
 	struct afs_fid fid;
 	struct dentry *parent;
-	struct inode *inode, *dir;
 	struct key *key;
+	void *dir_version;
 	int ret;
 
 	vnode = AFS_FS_I(dentry->d_inode);
 
-	_enter("{sb=%p n=%s fl=%lx},",
-	       dentry->d_sb, dentry->d_name.name, vnode->flags);
+	if (dentry->d_inode)
+		_enter("{v={%x:%u} n=%s fl=%lx},",
+		       vnode->fid.vid, vnode->fid.vnode, dentry->d_name.name,
+		       vnode->flags);
+	else
+		_enter("{neg n=%s}", dentry->d_name.name);
 
-	key = afs_request_key(vnode->volume->cell);
+	key = afs_request_key(AFS_FS_S(dentry->d_sb)->volume->cell);
 	if (IS_ERR(key))
 		key = NULL;
 
 	/* lock down the parent dentry so we can peer at it */
 	parent = dget_parent(dentry);
-
-	dir = parent->d_inode;
-	inode = dentry->d_inode;
-
-	/* handle a negative dentry */
-	if (!inode)
+	if (!parent->d_inode)
 		goto out_bad;
 
-	/* handle a bad inode */
-	if (is_bad_inode(inode)) {
-		printk("kAFS: afs_d_revalidate: %s/%s has bad inode\n",
-		       parent->d_name.name, dentry->d_name.name);
-		goto out_bad;
-	}
+	dir = AFS_FS_I(parent->d_inode);
 
-	/* check that this dirent still exists if the directory's contents were
-	 * modified */
-	if (test_bit(AFS_VNODE_DELETED, &AFS_FS_I(dir)->flags)) {
+	/* validate the parent directory */
+	if (test_bit(AFS_VNODE_MODIFIED, &dir->flags))
+		afs_validate(dir, key);
+
+	if (test_bit(AFS_VNODE_DELETED, &dir->flags)) {
 		_debug("%s: parent dir deleted", dentry->d_name.name);
 		goto out_bad;
 	}
 
-	if (test_and_clear_bit(AFS_VNODE_DIR_MODIFIED, &vnode->flags)) {
-		/* rm/rmdir/rename may have occurred */
-		_debug("dir modified");
+	dir_version = (void *) (unsigned long) dir->status.data_version;
+	if (dentry->d_fsdata == dir_version)
+		goto out_valid; /* the dir contents are unchanged */
 
-		/* search the directory for this vnode */
-		ret = afs_do_lookup(dir, dentry, &fid, key);
-		if (ret == -ENOENT) {
-			_debug("%s: dirent not found", dentry->d_name.name);
-			goto not_found;
-		}
-		if (ret < 0) {
-			_debug("failed to iterate dir %s: %d",
-			       parent->d_name.name, ret);
+	_debug("dir modified");
+
+	/* search the directory for this vnode */
+	ret = afs_do_lookup(&dir->vfs_inode, dentry, &fid, key);
+	switch (ret) {
+	case 0:
+		/* the filename maps to something */
+		if (!dentry->d_inode)
+			goto out_bad;
+		if (is_bad_inode(dentry->d_inode)) {
+			printk("kAFS: afs_d_revalidate: %s/%s has bad inode\n",
+			       parent->d_name.name, dentry->d_name.name);
 			goto out_bad;
 		}
 
@@ -639,56 +626,35 @@ static int afs_d_revalidate(struct dentry *dentry, struct nameidata *nd)
 		}
 
 		/* if the vnode ID uniqifier has changed, then the file has
-		 * been deleted */
+		 * been deleted and replaced, and the original vnode ID has
+		 * been reused */
 		if (fid.unique != vnode->fid.unique) {
 			_debug("%s: file deleted (uq %u -> %u I:%lu)",
 			       dentry->d_name.name, fid.unique,
-			       vnode->fid.unique, inode->i_version);
+			       vnode->fid.unique, dentry->d_inode->i_version);
 			spin_lock(&vnode->lock);
 			set_bit(AFS_VNODE_DELETED, &vnode->flags);
 			spin_unlock(&vnode->lock);
-			invalidate_remote_inode(inode);
-			goto out_bad;
+			goto not_found;
 		}
-	}
+		goto out_valid;
 
-	/* if the directory's metadata were changed then the security may be
-	 * different and we may no longer have access */
-	mutex_lock(&vnode->cb_broken_lock);
-
-	if (test_and_clear_bit(AFS_VNODE_DIR_CHANGED, &vnode->flags) ||
-	    test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags)) {
-		_debug("%s: changed", dentry->d_name.name);
-		set_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
-		if (afs_vnode_fetch_status(vnode, NULL, key) < 0) {
-			mutex_unlock(&vnode->cb_broken_lock);
-			goto out_bad;
-		}
-	}
+	case -ENOENT:
+		/* the filename is unknown */
+		_debug("%s: dirent not found", dentry->d_name.name);
+		if (dentry->d_inode)
+			goto not_found;
+		goto out_valid;
 
-	if (test_bit(AFS_VNODE_DELETED, &vnode->flags)) {
-		_debug("%s: file already deleted", dentry->d_name.name);
-		mutex_unlock(&vnode->cb_broken_lock);
+	default:
+		_debug("failed to iterate dir %s: %d",
+		       parent->d_name.name, ret);
 		goto out_bad;
 	}
 
-	/* if the vnode's data version number changed then its contents are
-	 * different */
-	if (test_and_clear_bit(AFS_VNODE_ZAP_DATA, &vnode->flags)) {
-		_debug("zap data");
-		invalidate_remote_inode(inode);
-	}
-
-	if (S_ISDIR(inode->i_mode) &&
-	    (test_bit(AFS_VNODE_CHANGED, &vnode->flags) ||
-	     test_bit(AFS_VNODE_MODIFIED, &vnode->flags)))
-		afs_propagate_dir_changes(dentry);
-
-	clear_bit(AFS_VNODE_CHANGED, &vnode->flags);
-	clear_bit(AFS_VNODE_MODIFIED, &vnode->flags);
-	mutex_unlock(&vnode->cb_broken_lock);
-
 out_valid:
+	dentry->d_fsdata = dir_version;
+out_skip:
 	dput(parent);
 	key_put(key);
 	_leave(" = 1 [valid]");
@@ -701,10 +667,10 @@ not_found:
 	spin_unlock(&dentry->d_lock);
 
 out_bad:
-	if (inode) {
+	if (dentry->d_inode) {
 		/* don't unhash if we have submounts */
 		if (have_submounts(dentry))
-			goto out_valid;
+			goto out_skip;
 	}
 
 	_debug("dropping dentry %s/%s",
@@ -742,3 +708,433 @@ zap:
 	_leave(" = 1 [zap]");
 	return 1;
 }
+
+/*
+ * handle dentry release
+ */
+static void afs_d_release(struct dentry *dentry)
+{
+	_enter("%s", dentry->d_name.name);
+}
+
+/*
+ * create a directory on an AFS filesystem
+ */
+static int afs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
+{
+	struct afs_file_status status;
+	struct afs_callback cb;
+	struct afs_server *server;
+	struct afs_vnode *dvnode, *vnode;
+	struct afs_fid fid;
+	struct inode *inode;
+	struct key *key;
+	int ret;
+
+	dvnode = AFS_FS_I(dir);
+
+	_enter("{%x:%d},{%s},%o",
+	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name, mode);
+
+	ret = -ENAMETOOLONG;
+	if (dentry->d_name.len > 255)
+		goto error;
+
+	key = afs_request_key(dvnode->volume->cell);
+	if (IS_ERR(key)) {
+		ret = PTR_ERR(key);
+		goto error;
+	}
+
+	mode |= S_IFDIR;
+	ret = afs_vnode_create(dvnode, key, dentry->d_name.name,
+			       mode, &fid, &status, &cb, &server);
+	if (ret < 0)
+		goto mkdir_error;
+
+	inode = afs_iget(dir->i_sb, key, &fid, &status, &cb);
+	if (IS_ERR(inode)) {
+		/* ENOMEM at a really inconvenient time - just abandon the new
+		 * directory on the server */
+		ret = PTR_ERR(inode);
+		goto iget_error;
+	}
+
+	/* apply the status report we've got for the new vnode */
+	vnode = AFS_FS_I(inode);
+	spin_lock(&vnode->lock);
+	vnode->update_cnt++;
+	spin_unlock(&vnode->lock);
+	afs_vnode_finalise_status_update(vnode, server);
+	afs_put_server(server);
+
+	d_instantiate(dentry, inode);
+	if (d_unhashed(dentry)) {
+		_debug("not hashed");
+		d_rehash(dentry);
+	}
+	key_put(key);
+	_leave(" = 0");
+	return 0;
+
+iget_error:
+	afs_put_server(server);
+mkdir_error:
+	key_put(key);
+error:
+	d_drop(dentry);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * remove a directory from an AFS filesystem
+ */
+static int afs_rmdir(struct inode *dir, struct dentry *dentry)
+{
+	struct afs_vnode *dvnode, *vnode;
+	struct key *key;
+	int ret;
+
+	dvnode = AFS_FS_I(dir);
+
+	_enter("{%x:%d},{%s}",
+	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name);
+
+	ret = -ENAMETOOLONG;
+	if (dentry->d_name.len > 255)
+		goto error;
+
+	key = afs_request_key(dvnode->volume->cell);
+	if (IS_ERR(key)) {
+		ret = PTR_ERR(key);
+		goto error;
+	}
+
+	ret = afs_vnode_remove(dvnode, key, dentry->d_name.name, true);
+	if (ret < 0)
+		goto rmdir_error;
+
+	if (dentry->d_inode) {
+		vnode = AFS_FS_I(dentry->d_inode);
+		clear_nlink(&vnode->vfs_inode);
+		set_bit(AFS_VNODE_DELETED, &vnode->flags);
+		afs_discard_callback_on_delete(vnode);
+	}
+
+	key_put(key);
+	_leave(" = 0");
+	return 0;
+
+rmdir_error:
+	key_put(key);
+error:
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * remove a file from an AFS filesystem
+ */
+static int afs_unlink(struct inode *dir, struct dentry *dentry)
+{
+	struct afs_vnode *dvnode, *vnode;
+	struct key *key;
+	int ret;
+
+	dvnode = AFS_FS_I(dir);
+
+	_enter("{%x:%d},{%s}",
+	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name);
+
+	ret = -ENAMETOOLONG;
+	if (dentry->d_name.len > 255)
+		goto error;
+
+	key = afs_request_key(dvnode->volume->cell);
+	if (IS_ERR(key)) {
+		ret = PTR_ERR(key);
+		goto error;
+	}
+
+	if (dentry->d_inode) {
+		vnode = AFS_FS_I(dentry->d_inode);
+
+		/* make sure we have a callback promise on the victim */
+		ret = afs_validate(vnode, key);
+		if (ret < 0)
+			goto error;
+	}
+
+	ret = afs_vnode_remove(dvnode, key, dentry->d_name.name, false);
+	if (ret < 0)
+		goto remove_error;
+
+	if (dentry->d_inode) {
+		/* if the file wasn't deleted due to excess hard links, the
+		 * fileserver will break the callback promise on the file - if
+		 * it had one - before it returns to us, and if it was deleted,
+		 * it won't
+		 *
+		 * however, if we didn't have a callback promise outstanding,
+		 * or it was outstanding on a different server, then it won't
+		 * break it either...
+		 */
+		vnode = AFS_FS_I(dentry->d_inode);
+		if (test_bit(AFS_VNODE_DELETED, &vnode->flags))
+			_debug("AFS_VNODE_DELETED");
+		if (test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags))
+			_debug("AFS_VNODE_CB_BROKEN");
+		set_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
+		ret = afs_validate(vnode, key);
+		_debug("nlink %d [val %d]", vnode->vfs_inode.i_nlink, ret);
+	}
+
+	key_put(key);
+	_leave(" = 0");
+	return 0;
+
+remove_error:
+	key_put(key);
+error:
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * create a regular file on an AFS filesystem
+ */
+static int afs_create(struct inode *dir, struct dentry *dentry, int mode,
+		      struct nameidata *nd)
+{
+	struct afs_file_status status;
+	struct afs_callback cb;
+	struct afs_server *server;
+	struct afs_vnode *dvnode, *vnode;
+	struct afs_fid fid;
+	struct inode *inode;
+	struct key *key;
+	int ret;
+
+	dvnode = AFS_FS_I(dir);
+
+	_enter("{%x:%d},{%s},%o,",
+	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name, mode);
+
+	ret = -ENAMETOOLONG;
+	if (dentry->d_name.len > 255)
+		goto error;
+
+	key = afs_request_key(dvnode->volume->cell);
+	if (IS_ERR(key)) {
+		ret = PTR_ERR(key);
+		goto error;
+	}
+
+	mode |= S_IFREG;
+	ret = afs_vnode_create(dvnode, key, dentry->d_name.name,
+			       mode, &fid, &status, &cb, &server);
+	if (ret < 0)
+		goto create_error;
+
+	inode = afs_iget(dir->i_sb, key, &fid, &status, &cb);
+	if (IS_ERR(inode)) {
+		/* ENOMEM at a really inconvenient time - just abandon the new
+		 * directory on the server */
+		ret = PTR_ERR(inode);
+		goto iget_error;
+	}
+
+	/* apply the status report we've got for the new vnode */
+	vnode = AFS_FS_I(inode);
+	spin_lock(&vnode->lock);
+	vnode->update_cnt++;
+	spin_unlock(&vnode->lock);
+	afs_vnode_finalise_status_update(vnode, server);
+	afs_put_server(server);
+
+	d_instantiate(dentry, inode);
+	if (d_unhashed(dentry)) {
+		_debug("not hashed");
+		d_rehash(dentry);
+	}
+	key_put(key);
+	_leave(" = 0");
+	return 0;
+
+iget_error:
+	afs_put_server(server);
+create_error:
+	key_put(key);
+error:
+	d_drop(dentry);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * create a hard link between files in an AFS filesystem
+ */
+static int afs_link(struct dentry *from, struct inode *dir,
+		    struct dentry *dentry)
+{
+	struct afs_vnode *dvnode, *vnode;
+	struct key *key;
+	int ret;
+
+	vnode = AFS_FS_I(from->d_inode);
+	dvnode = AFS_FS_I(dir);
+
+	_enter("{%x:%d},{%x:%d},{%s}",
+	       vnode->fid.vid, vnode->fid.vnode,
+	       dvnode->fid.vid, dvnode->fid.vnode,
+	       dentry->d_name.name);
+
+	ret = -ENAMETOOLONG;
+	if (dentry->d_name.len > 255)
+		goto error;
+
+	key = afs_request_key(dvnode->volume->cell);
+	if (IS_ERR(key)) {
+		ret = PTR_ERR(key);
+		goto error;
+	}
+
+	ret = afs_vnode_link(dvnode, vnode, key, dentry->d_name.name);
+	if (ret < 0)
+		goto link_error;
+
+	atomic_inc(&vnode->vfs_inode.i_count);
+	d_instantiate(dentry, &vnode->vfs_inode);
+	key_put(key);
+	_leave(" = 0");
+	return 0;
+
+link_error:
+	key_put(key);
+error:
+	d_drop(dentry);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * create a symlink in an AFS filesystem
+ */
+static int afs_symlink(struct inode *dir, struct dentry *dentry,
+		       const char *content)
+{
+	struct afs_file_status status;
+	struct afs_server *server;
+	struct afs_vnode *dvnode, *vnode;
+	struct afs_fid fid;
+	struct inode *inode;
+	struct key *key;
+	int ret;
+
+	dvnode = AFS_FS_I(dir);
+
+	_enter("{%x:%d},{%s},%s",
+	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name,
+	       content);
+
+	ret = -ENAMETOOLONG;
+	if (dentry->d_name.len > 255)
+		goto error;
+
+	ret = -EINVAL;
+	if (strlen(content) > 1023)
+		goto error;
+
+	key = afs_request_key(dvnode->volume->cell);
+	if (IS_ERR(key)) {
+		ret = PTR_ERR(key);
+		goto error;
+	}
+
+	ret = afs_vnode_symlink(dvnode, key, dentry->d_name.name, content,
+				&fid, &status, &server);
+	if (ret < 0)
+		goto create_error;
+
+	inode = afs_iget(dir->i_sb, key, &fid, &status, NULL);
+	if (IS_ERR(inode)) {
+		/* ENOMEM at a really inconvenient time - just abandon the new
+		 * directory on the server */
+		ret = PTR_ERR(inode);
+		goto iget_error;
+	}
+
+	/* apply the status report we've got for the new vnode */
+	vnode = AFS_FS_I(inode);
+	spin_lock(&vnode->lock);
+	vnode->update_cnt++;
+	spin_unlock(&vnode->lock);
+	afs_vnode_finalise_status_update(vnode, server);
+	afs_put_server(server);
+
+	d_instantiate(dentry, inode);
+	if (d_unhashed(dentry)) {
+		_debug("not hashed");
+		d_rehash(dentry);
+	}
+	key_put(key);
+	_leave(" = 0");
+	return 0;
+
+iget_error:
+	afs_put_server(server);
+create_error:
+	key_put(key);
+error:
+	d_drop(dentry);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * rename a file in an AFS filesystem and/or move it between directories
+ */
+static int afs_rename(struct inode *old_dir, struct dentry *old_dentry,
+		      struct inode *new_dir, struct dentry *new_dentry)
+{
+	struct afs_vnode *orig_dvnode, *new_dvnode, *vnode;
+	struct key *key;
+	int ret;
+
+	vnode = AFS_FS_I(old_dentry->d_inode);
+	orig_dvnode = AFS_FS_I(old_dir);
+	new_dvnode = AFS_FS_I(new_dir);
+
+	_enter("{%x:%d},{%x:%d},{%x:%d},{%s}",
+	       orig_dvnode->fid.vid, orig_dvnode->fid.vnode,
+	       vnode->fid.vid, vnode->fid.vnode,
+	       new_dvnode->fid.vid, new_dvnode->fid.vnode,
+	       new_dentry->d_name.name);
+
+	ret = -ENAMETOOLONG;
+	if (new_dentry->d_name.len > 255)
+		goto error;
+
+	key = afs_request_key(orig_dvnode->volume->cell);
+	if (IS_ERR(key)) {
+		ret = PTR_ERR(key);
+		goto error;
+	}
+
+	ret = afs_vnode_rename(orig_dvnode, new_dvnode, key,
+			       old_dentry->d_name.name,
+			       new_dentry->d_name.name);
+	if (ret < 0)
+		goto rename_error;
+	key_put(key);
+	_leave(" = 0");
+	return 0;
+
+rename_error:
+	key_put(key);
+error:
+	d_drop(new_dentry);
+	_leave(" = %d", ret);
+	return ret;
+}
diff --git a/fs/afs/file.c b/fs/afs/file.c
index 101bbb8..59cd955 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -50,6 +50,7 @@ int afs_open(struct inode *inode, struct file *file)
 {
 	struct afs_vnode *vnode = AFS_FS_I(inode);
 	struct key *key;
+	int ret;
 
 	_enter("{%x:%x},", vnode->fid.vid, vnode->fid.vnode);
 
@@ -58,6 +59,12 @@ int afs_open(struct inode *inode, struct file *file)
 		_leave(" = %ld [key]", PTR_ERR(key));
 		return PTR_ERR(key);
 	}
+	
+	ret = afs_validate(vnode, key);
+	if (ret < 0) {
+		_leave(" = %d [val]", ret);
+		return ret;
+	}
 
 	file->private_data = key;
 	_leave(" = 0");
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index 321b489..f036b4c 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -16,14 +16,28 @@
 #include "afs_fs.h"
 
 /*
+ * decode an AFSFid block
+ */
+static void xdr_decode_AFSFid(const __be32 **_bp, struct afs_fid *fid)
+{
+	const __be32 *bp = *_bp;
+
+	fid->vid		= ntohl(*bp++);
+	fid->vnode		= ntohl(*bp++);
+	fid->unique		= ntohl(*bp++);
+	*_bp = bp;
+}
+
+/*
  * decode an AFSFetchStatus block
  */
 static void xdr_decode_AFSFetchStatus(const __be32 **_bp,
+				      struct afs_file_status *status,
 				      struct afs_vnode *vnode)
 {
 	const __be32 *bp = *_bp;
 	umode_t mode;
-	u64 data_version;
+	u64 data_version, size;
 	u32 changed = 0; /* becomes non-zero if ctime-type changes seen */
 
 #define EXTRACT(DST)				\
@@ -33,55 +47,68 @@ static void xdr_decode_AFSFetchStatus(const __be32 **_bp,
 		DST = x;			\
 	} while (0)
 
-	vnode->status.if_version = ntohl(*bp++);
-	EXTRACT(vnode->status.type);
-	vnode->status.nlink = ntohl(*bp++);
-	EXTRACT(vnode->status.size);
+	status->if_version = ntohl(*bp++);
+	EXTRACT(status->type);
+	EXTRACT(status->nlink);
+	size = ntohl(*bp++);
 	data_version = ntohl(*bp++);
-	EXTRACT(vnode->status.author);
-	EXTRACT(vnode->status.owner);
-	EXTRACT(vnode->status.caller_access); /* call ticket dependent */
-	EXTRACT(vnode->status.anon_access);
-	EXTRACT(vnode->status.mode);
-	vnode->status.parent.vid = vnode->fid.vid;
-	EXTRACT(vnode->status.parent.vnode);
-	EXTRACT(vnode->status.parent.unique);
+	EXTRACT(status->author);
+	EXTRACT(status->owner);
+	EXTRACT(status->caller_access); /* call ticket dependent */
+	EXTRACT(status->anon_access);
+	EXTRACT(status->mode);
+	EXTRACT(status->parent.vnode);
+	EXTRACT(status->parent.unique);
 	bp++; /* seg size */
-	vnode->status.mtime_client = ntohl(*bp++);
-	vnode->status.mtime_server = ntohl(*bp++);
-	bp++; /* group */
+	status->mtime_client = ntohl(*bp++);
+	status->mtime_server = ntohl(*bp++);
+	EXTRACT(status->group);
 	bp++; /* sync counter */
 	data_version |= (u64) ntohl(*bp++) << 32;
-	bp++; /* spare2 */
-	bp++; /* spare3 */
-	bp++; /* spare4 */
+	bp++; /* lock count */
+	size |= (u64) ntohl(*bp++) << 32;
+	bp++; /* spare 4 */
 	*_bp = bp;
 
-	if (changed) {
-		_debug("vnode changed");
-		set_bit(AFS_VNODE_CHANGED, &vnode->flags);
-		vnode->vfs_inode.i_uid		= vnode->status.owner;
-		vnode->vfs_inode.i_size		= vnode->status.size;
-		vnode->vfs_inode.i_version	= vnode->fid.unique;
-
-		vnode->status.mode &= S_IALLUGO;
-		mode = vnode->vfs_inode.i_mode;
-		mode &= ~S_IALLUGO;
-		mode |= vnode->status.mode;
-		vnode->vfs_inode.i_mode = mode;
+	if (size != status->size) {
+		status->size = size;
+		changed |= true;
 	}
+	status->mode &= S_IALLUGO;
 
 	_debug("vnode time %lx, %lx",
-	       vnode->status.mtime_client, vnode->status.mtime_server);
-	vnode->vfs_inode.i_ctime.tv_sec	= vnode->status.mtime_server;
-	vnode->vfs_inode.i_mtime	= vnode->vfs_inode.i_ctime;
-	vnode->vfs_inode.i_atime	= vnode->vfs_inode.i_ctime;
-
-	if (vnode->status.data_version != data_version) {
-		_debug("vnode modified %llx", data_version);
-		vnode->status.data_version = data_version;
-		set_bit(AFS_VNODE_MODIFIED, &vnode->flags);
-		set_bit(AFS_VNODE_ZAP_DATA, &vnode->flags);
+	       status->mtime_client, status->mtime_server);
+
+	if (vnode) {
+		status->parent.vid = vnode->fid.vid;
+		if (changed && !test_bit(AFS_VNODE_UNSET, &vnode->flags)) {
+			_debug("vnode changed");
+			i_size_write(&vnode->vfs_inode, size);
+			vnode->vfs_inode.i_uid = status->owner;
+			vnode->vfs_inode.i_gid = status->group;
+			vnode->vfs_inode.i_version = vnode->fid.unique;
+			vnode->vfs_inode.i_nlink = status->nlink;
+
+			mode = vnode->vfs_inode.i_mode;
+			mode &= ~S_IALLUGO;
+			mode |= status->mode;
+			barrier();
+			vnode->vfs_inode.i_mode = mode;
+		}
+
+		vnode->vfs_inode.i_ctime.tv_sec	= status->mtime_server;
+		vnode->vfs_inode.i_mtime	= vnode->vfs_inode.i_ctime;
+		vnode->vfs_inode.i_atime	= vnode->vfs_inode.i_ctime;
+	}
+
+	if (status->data_version != data_version) {
+		status->data_version = data_version;
+		if (vnode && !test_bit(AFS_VNODE_UNSET, &vnode->flags)) {
+			_debug("vnode modified %llx on {%x:%u}",
+			       data_version, vnode->fid.vid, vnode->fid.vnode);
+			set_bit(AFS_VNODE_MODIFIED, &vnode->flags);
+			set_bit(AFS_VNODE_ZAP_DATA, &vnode->flags);
+		}
 	}
 }
 
@@ -99,6 +126,17 @@ static void xdr_decode_AFSCallBack(const __be32 **_bp, struct afs_vnode *vnode)
 	*_bp = bp;
 }
 
+static void xdr_decode_AFSCallBack_raw(const __be32 **_bp,
+				       struct afs_callback *cb)
+{
+	const __be32 *bp = *_bp;
+
+	cb->version	= ntohl(*bp++);
+	cb->expiry	= ntohl(*bp++);
+	cb->type	= ntohl(*bp++);
+	*_bp = bp;
+}
+
 /*
  * decode an AFSVolSync block
  */
@@ -122,6 +160,7 @@ static void xdr_decode_AFSVolSync(const __be32 **_bp,
 static int afs_deliver_fs_fetch_status(struct afs_call *call,
 				       struct sk_buff *skb, bool last)
 {
+	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
 
 	_enter(",,%u", last);
@@ -135,8 +174,8 @@ static int afs_deliver_fs_fetch_status(struct afs_call *call,
 
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
-	xdr_decode_AFSFetchStatus(&bp, call->reply);
-	xdr_decode_AFSCallBack(&bp, call->reply);
+	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode);
+	xdr_decode_AFSCallBack(&bp, vnode);
 	if (call->reply2)
 		xdr_decode_AFSVolSync(&bp, call->reply2);
 
@@ -166,9 +205,10 @@ int afs_fs_fetch_file_status(struct afs_server *server,
 	struct afs_call *call;
 	__be32 *bp;
 
-	_enter(",%x,,,", key_serial(key));
+	_enter(",%x,{%x:%d},,",
+	       key_serial(key), vnode->fid.vid, vnode->fid.vnode);
 
-	call = afs_alloc_flat_call(&afs_RXFSFetchStatus, 16, 120);
+	call = afs_alloc_flat_call(&afs_RXFSFetchStatus, 16, (21 + 3 + 6) * 4);
 	if (!call)
 		return -ENOMEM;
 
@@ -194,6 +234,7 @@ int afs_fs_fetch_file_status(struct afs_server *server,
 static int afs_deliver_fs_fetch_data(struct afs_call *call,
 				     struct sk_buff *skb, bool last)
 {
+	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
 	struct page *page;
 	void *buffer;
@@ -248,7 +289,8 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 
 		/* extract the metadata */
 	case 3:
-		ret = afs_extract_data(call, skb, last, call->buffer, 120);
+		ret = afs_extract_data(call, skb, last, call->buffer,
+				       (21 + 3 + 6) * 4);
 		switch (ret) {
 		case 0:		break;
 		case -EAGAIN:	return 0;
@@ -256,8 +298,8 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 		}
 
 		bp = call->buffer;
-		xdr_decode_AFSFetchStatus(&bp, call->reply);
-		xdr_decode_AFSCallBack(&bp, call->reply);
+		xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode);
+		xdr_decode_AFSCallBack(&bp, vnode);
 		if (call->reply2)
 			xdr_decode_AFSVolSync(&bp, call->reply2);
 
@@ -296,7 +338,6 @@ int afs_fs_fetch_data(struct afs_server *server,
 		      struct afs_vnode *vnode,
 		      off_t offset, size_t length,
 		      struct page *buffer,
-		      struct afs_volsync *volsync,
 		      const struct afs_wait_mode *wait_mode)
 {
 	struct afs_call *call;
@@ -304,13 +345,13 @@ int afs_fs_fetch_data(struct afs_server *server,
 
 	_enter("");
 
-	call = afs_alloc_flat_call(&afs_RXFSFetchData, 24, 120);
+	call = afs_alloc_flat_call(&afs_RXFSFetchData, 24, (21 + 3 + 6) * 4);
 	if (!call)
 		return -ENOMEM;
 
 	call->key = key;
 	call->reply = vnode;
-	call->reply2 = volsync;
+	call->reply2 = NULL; /* volsync */
 	call->reply3 = buffer;
 	call->service_id = FS_SERVICE;
 	call->port = htons(AFS_FS_PORT);
@@ -411,3 +452,485 @@ int afs_fs_give_up_callbacks(struct afs_server *server,
 
 	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
 }
+
+/*
+ * deliver reply data to an FS.CreateFile or an FS.MakeDir
+ */
+static int afs_deliver_fs_create_vnode(struct afs_call *call,
+				       struct sk_buff *skb, bool last)
+{
+	struct afs_vnode *vnode = call->reply;
+	const __be32 *bp;
+
+	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+
+	afs_transfer_reply(call, skb);
+	if (!last)
+		return 0;
+
+	if (call->reply_size != call->reply_max)
+		return -EBADMSG;
+
+	/* unmarshall the reply once we've received all of it */
+	bp = call->buffer;
+	xdr_decode_AFSFid(&bp, call->reply2);
+	xdr_decode_AFSFetchStatus(&bp, call->reply3, NULL);
+	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode);
+	xdr_decode_AFSCallBack_raw(&bp, call->reply4);
+	/* xdr_decode_AFSVolSync(&bp, call->replyX); */
+
+	_leave(" = 0 [done]");
+	return 0;
+}
+
+/*
+ * FS.CreateFile and FS.MakeDir operation type
+ */
+static const struct afs_call_type afs_RXFSCreateXXXX = {
+	.name		= "FS.CreateXXXX",
+	.deliver	= afs_deliver_fs_create_vnode,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_flat_call_destructor,
+};
+
+/*
+ * create a file or make a directory
+ */
+int afs_fs_create(struct afs_server *server,
+		  struct key *key,
+		  struct afs_vnode *vnode,
+		  const char *name,
+		  umode_t mode,
+		  struct afs_fid *newfid,
+		  struct afs_file_status *newstatus,
+		  struct afs_callback *newcb,
+		  const struct afs_wait_mode *wait_mode)
+{
+	struct afs_call *call;
+	size_t namesz, reqsz, padsz;
+	__be32 *bp;
+
+	_enter("");
+
+	namesz = strlen(name);
+	padsz = (4 - (namesz & 3)) & 3;
+	reqsz = (5 * 4) + namesz + padsz + (6 * 4);
+
+	call = afs_alloc_flat_call(&afs_RXFSCreateXXXX, reqsz,
+				   (3 + 21 + 21 + 3 + 6) * 4);
+	if (!call)
+		return -ENOMEM;
+
+	call->key = key;
+	call->reply = vnode;
+	call->reply2 = newfid;
+	call->reply3 = newstatus;
+	call->reply4 = newcb;
+	call->service_id = FS_SERVICE;
+	call->port = htons(AFS_FS_PORT);
+
+	/* marshall the parameters */
+	bp = call->request;
+	*bp++ = htonl(S_ISDIR(mode) ? FSMAKEDIR : FSCREATEFILE);
+	*bp++ = htonl(vnode->fid.vid);
+	*bp++ = htonl(vnode->fid.vnode);
+	*bp++ = htonl(vnode->fid.unique);
+	*bp++ = htonl(namesz);
+	memcpy(bp, name, namesz);
+	bp = (void *) bp + namesz;
+	if (padsz > 0) {
+		memset(bp, 0, padsz);
+		bp = (void *) bp + padsz;
+	}
+	*bp++ = htonl(AFS_SET_MODE);
+	*bp++ = 0; /* mtime */
+	*bp++ = 0; /* owner */
+	*bp++ = 0; /* group */
+	*bp++ = htonl(mode & S_IALLUGO); /* unix mode */
+	*bp++ = 0; /* segment size */
+
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+}
+
+/*
+ * deliver reply data to an FS.RemoveFile or FS.RemoveDir
+ */
+static int afs_deliver_fs_remove(struct afs_call *call,
+				 struct sk_buff *skb, bool last)
+{
+	struct afs_vnode *vnode = call->reply;
+	const __be32 *bp;
+
+	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+
+	afs_transfer_reply(call, skb);
+	if (!last)
+		return 0;
+
+	if (call->reply_size != call->reply_max)
+		return -EBADMSG;
+
+	/* unmarshall the reply once we've received all of it */
+	bp = call->buffer;
+	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode);
+	/* xdr_decode_AFSVolSync(&bp, call->replyX); */
+
+	_leave(" = 0 [done]");
+	return 0;
+}
+
+/*
+ * FS.RemoveDir/FS.RemoveFile operation type
+ */
+static const struct afs_call_type afs_RXFSRemoveXXXX = {
+	.name		= "FS.RemoveXXXX",
+	.deliver	= afs_deliver_fs_remove,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_flat_call_destructor,
+};
+
+/*
+ * remove a file or directory
+ */
+int afs_fs_remove(struct afs_server *server,
+		  struct key *key,
+		  struct afs_vnode *vnode,
+		  const char *name,
+		  bool isdir,
+		  const struct afs_wait_mode *wait_mode)
+{
+	struct afs_call *call;
+	size_t namesz, reqsz, padsz;
+	__be32 *bp;
+
+	_enter("");
+
+	namesz = strlen(name);
+	padsz = (4 - (namesz & 3)) & 3;
+	reqsz = (5 * 4) + namesz + padsz;
+
+	call = afs_alloc_flat_call(&afs_RXFSRemoveXXXX, reqsz, (21 + 6) * 4);
+	if (!call)
+		return -ENOMEM;
+
+	call->key = key;
+	call->reply = vnode;
+	call->service_id = FS_SERVICE;
+	call->port = htons(AFS_FS_PORT);
+
+	/* marshall the parameters */
+	bp = call->request;
+	*bp++ = htonl(isdir ? FSREMOVEDIR : FSREMOVEFILE);
+	*bp++ = htonl(vnode->fid.vid);
+	*bp++ = htonl(vnode->fid.vnode);
+	*bp++ = htonl(vnode->fid.unique);
+	*bp++ = htonl(namesz);
+	memcpy(bp, name, namesz);
+	bp = (void *) bp + namesz;
+	if (padsz > 0) {
+		memset(bp, 0, padsz);
+		bp = (void *) bp + padsz;
+	}
+
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+}
+
+/*
+ * deliver reply data to an FS.Link
+ */
+static int afs_deliver_fs_link(struct afs_call *call,
+			       struct sk_buff *skb, bool last)
+{
+	struct afs_vnode *dvnode = call->reply, *vnode = call->reply2;
+	const __be32 *bp;
+
+	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+
+	afs_transfer_reply(call, skb);
+	if (!last)
+		return 0;
+
+	if (call->reply_size != call->reply_max)
+		return -EBADMSG;
+
+	/* unmarshall the reply once we've received all of it */
+	bp = call->buffer;
+	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode);
+	xdr_decode_AFSFetchStatus(&bp, &dvnode->status, dvnode);
+	/* xdr_decode_AFSVolSync(&bp, call->replyX); */
+
+	_leave(" = 0 [done]");
+	return 0;
+}
+
+/*
+ * FS.Link operation type
+ */
+static const struct afs_call_type afs_RXFSLink = {
+	.name		= "FS.Link",
+	.deliver	= afs_deliver_fs_link,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_flat_call_destructor,
+};
+
+/*
+ * make a hard link
+ */
+int afs_fs_link(struct afs_server *server,
+		struct key *key,
+		struct afs_vnode *dvnode,
+		struct afs_vnode *vnode,
+		const char *name,
+		const struct afs_wait_mode *wait_mode)
+{
+	struct afs_call *call;
+	size_t namesz, reqsz, padsz;
+	__be32 *bp;
+
+	_enter("");
+
+	namesz = strlen(name);
+	padsz = (4 - (namesz & 3)) & 3;
+	reqsz = (5 * 4) + namesz + padsz + (3 * 4);
+
+	call = afs_alloc_flat_call(&afs_RXFSLink, reqsz, (21 + 21 + 6) * 4);
+	if (!call)
+		return -ENOMEM;
+
+	call->key = key;
+	call->reply = dvnode;
+	call->reply2 = vnode;
+	call->service_id = FS_SERVICE;
+	call->port = htons(AFS_FS_PORT);
+
+	/* marshall the parameters */
+	bp = call->request;
+	*bp++ = htonl(FSLINK);
+	*bp++ = htonl(dvnode->fid.vid);
+	*bp++ = htonl(dvnode->fid.vnode);
+	*bp++ = htonl(dvnode->fid.unique);
+	*bp++ = htonl(namesz);
+	memcpy(bp, name, namesz);
+	bp = (void *) bp + namesz;
+	if (padsz > 0) {
+		memset(bp, 0, padsz);
+		bp = (void *) bp + padsz;
+	}
+	*bp++ = htonl(vnode->fid.vid);
+	*bp++ = htonl(vnode->fid.vnode);
+	*bp++ = htonl(vnode->fid.unique);
+
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+}
+
+/*
+ * deliver reply data to an FS.Symlink
+ */
+static int afs_deliver_fs_symlink(struct afs_call *call,
+				  struct sk_buff *skb, bool last)
+{
+	struct afs_vnode *vnode = call->reply;
+	const __be32 *bp;
+
+	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+
+	afs_transfer_reply(call, skb);
+	if (!last)
+		return 0;
+
+	if (call->reply_size != call->reply_max)
+		return -EBADMSG;
+
+	/* unmarshall the reply once we've received all of it */
+	bp = call->buffer;
+	xdr_decode_AFSFid(&bp, call->reply2);
+	xdr_decode_AFSFetchStatus(&bp, call->reply3, NULL);
+	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode);
+	/* xdr_decode_AFSVolSync(&bp, call->replyX); */
+
+	_leave(" = 0 [done]");
+	return 0;
+}
+
+/*
+ * FS.Symlink operation type
+ */
+static const struct afs_call_type afs_RXFSSymlink = {
+	.name		= "FS.Symlink",
+	.deliver	= afs_deliver_fs_symlink,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_flat_call_destructor,
+};
+
+/*
+ * create a symbolic link
+ */
+int afs_fs_symlink(struct afs_server *server,
+		   struct key *key,
+		   struct afs_vnode *vnode,
+		   const char *name,
+		   const char *contents,
+		   struct afs_fid *newfid,
+		   struct afs_file_status *newstatus,
+		   const struct afs_wait_mode *wait_mode)
+{
+	struct afs_call *call;
+	size_t namesz, reqsz, padsz, c_namesz, c_padsz;
+	__be32 *bp;
+
+	_enter("");
+
+	namesz = strlen(name);
+	padsz = (4 - (namesz & 3)) & 3;
+
+	c_namesz = strlen(contents);
+	c_padsz = (4 - (c_namesz & 3)) & 3;
+
+	reqsz = (6 * 4) + namesz + padsz + c_namesz + c_padsz + (6 * 4);
+
+	call = afs_alloc_flat_call(&afs_RXFSSymlink, reqsz,
+				   (3 + 21 + 21 + 6) * 4);
+	if (!call)
+		return -ENOMEM;
+
+	call->key = key;
+	call->reply = vnode;
+	call->reply2 = newfid;
+	call->reply3 = newstatus;
+	call->service_id = FS_SERVICE;
+	call->port = htons(AFS_FS_PORT);
+
+	/* marshall the parameters */
+	bp = call->request;
+	*bp++ = htonl(FSSYMLINK);
+	*bp++ = htonl(vnode->fid.vid);
+	*bp++ = htonl(vnode->fid.vnode);
+	*bp++ = htonl(vnode->fid.unique);
+	*bp++ = htonl(namesz);
+	memcpy(bp, name, namesz);
+	bp = (void *) bp + namesz;
+	if (padsz > 0) {
+		memset(bp, 0, padsz);
+		bp = (void *) bp + padsz;
+	}
+	*bp++ = htonl(c_namesz);
+	memcpy(bp, contents, c_namesz);
+	bp = (void *) bp + c_namesz;
+	if (c_padsz > 0) {
+		memset(bp, 0, c_padsz);
+		bp = (void *) bp + c_padsz;
+	}
+	*bp++ = htonl(AFS_SET_MODE);
+	*bp++ = 0; /* mtime */
+	*bp++ = 0; /* owner */
+	*bp++ = 0; /* group */
+	*bp++ = htonl(S_IRWXUGO); /* unix mode */
+	*bp++ = 0; /* segment size */
+
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+}
+
+/*
+ * deliver reply data to an FS.Rename
+ */
+static int afs_deliver_fs_rename(struct afs_call *call,
+				  struct sk_buff *skb, bool last)
+{
+	struct afs_vnode *orig_dvnode = call->reply, *new_dvnode = call->reply2;
+	const __be32 *bp;
+
+	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+
+	afs_transfer_reply(call, skb);
+	if (!last)
+		return 0;
+
+	if (call->reply_size != call->reply_max)
+		return -EBADMSG;
+
+	/* unmarshall the reply once we've received all of it */
+	bp = call->buffer;
+	xdr_decode_AFSFetchStatus(&bp, &orig_dvnode->status, orig_dvnode);
+	if (new_dvnode != orig_dvnode)
+		xdr_decode_AFSFetchStatus(&bp, &new_dvnode->status, new_dvnode);
+	/* xdr_decode_AFSVolSync(&bp, call->replyX); */
+
+	_leave(" = 0 [done]");
+	return 0;
+}
+
+/*
+ * FS.Rename operation type
+ */
+static const struct afs_call_type afs_RXFSRename = {
+	.name		= "FS.Rename",
+	.deliver	= afs_deliver_fs_rename,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_flat_call_destructor,
+};
+
+/*
+ * create a symbolic link
+ */
+int afs_fs_rename(struct afs_server *server,
+		  struct key *key,
+		  struct afs_vnode *orig_dvnode,
+		  const char *orig_name,
+		  struct afs_vnode *new_dvnode,
+		  const char *new_name,
+		  const struct afs_wait_mode *wait_mode)
+{
+	struct afs_call *call;
+	size_t reqsz, o_namesz, o_padsz, n_namesz, n_padsz;
+	__be32 *bp;
+
+	_enter("");
+
+	o_namesz = strlen(orig_name);
+	o_padsz = (4 - (o_namesz & 3)) & 3;
+
+	n_namesz = strlen(new_name);
+	n_padsz = (4 - (n_namesz & 3)) & 3;
+
+	reqsz = (4 * 4) +
+		4 + o_namesz + o_padsz +
+		(3 * 4) +
+		4 + n_namesz + n_padsz;
+
+	call = afs_alloc_flat_call(&afs_RXFSRename, reqsz, (21 + 21 + 6) * 4);
+	if (!call)
+		return -ENOMEM;
+
+	call->key = key;
+	call->reply = orig_dvnode;
+	call->reply2 = new_dvnode;
+	call->service_id = FS_SERVICE;
+	call->port = htons(AFS_FS_PORT);
+
+	/* marshall the parameters */
+	bp = call->request;
+	*bp++ = htonl(FSRENAME);
+	*bp++ = htonl(orig_dvnode->fid.vid);
+	*bp++ = htonl(orig_dvnode->fid.vnode);
+	*bp++ = htonl(orig_dvnode->fid.unique);
+	*bp++ = htonl(o_namesz);
+	memcpy(bp, orig_name, o_namesz);
+	bp = (void *) bp + o_namesz;
+	if (o_padsz > 0) {
+		memset(bp, 0, o_padsz);
+		bp = (void *) bp + o_padsz;
+	}
+
+	*bp++ = htonl(new_dvnode->fid.vid);
+	*bp++ = htonl(new_dvnode->fid.vnode);
+	*bp++ = htonl(new_dvnode->fid.unique);
+	*bp++ = htonl(n_namesz);
+	memcpy(bp, new_name, n_namesz);
+	bp = (void *) bp + n_namesz;
+	if (n_padsz > 0) {
+		memset(bp, 0, n_padsz);
+		bp = (void *) bp + n_padsz;
+	}
+
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+}
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 2273362..56ca858 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -33,7 +33,7 @@ static int afs_inode_map_status(struct afs_vnode *vnode, struct key *key)
 {
 	struct inode *inode = AFS_VNODE_TO_I(vnode);
 
-	_debug("FS: ft=%d lk=%d sz=%Zu ver=%Lu mod=%hu",
+	_debug("FS: ft=%d lk=%d sz=%llu ver=%Lu mod=%hu",
 	       vnode->status.type,
 	       vnode->status.nlink,
 	       vnode->status.size,
@@ -115,8 +115,9 @@ static int afs_iget5_set(struct inode *inode, void *opaque)
 /*
  * inode retrieval
  */
-inline struct inode *afs_iget(struct super_block *sb, struct key *key,
-			      struct afs_fid *fid)
+struct inode *afs_iget(struct super_block *sb, struct key *key,
+		       struct afs_fid *fid, struct afs_file_status *status,
+		       struct afs_callback *cb)
 {
 	struct afs_iget_data data = { .fid = *fid };
 	struct afs_super_info *as;
@@ -156,16 +157,37 @@ inline struct inode *afs_iget(struct super_block *sb, struct key *key,
 			       &vnode->cache);
 #endif
 
-	/* okay... it's a new inode */
-	set_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
-	ret = afs_vnode_fetch_status(vnode, NULL, key);
-	if (ret < 0)
-		goto bad_inode;
+	if (!status) {
+		/* it's a remotely extant inode */
+		set_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
+		ret = afs_vnode_fetch_status(vnode, NULL, key);
+		if (ret < 0)
+			goto bad_inode;
+	} else {
+		/* it's an inode we just created */
+		memcpy(&vnode->status, status, sizeof(vnode->status));
+
+		if (!cb) {
+			/* it's a symlink we just created (the fileserver
+			 * didn't give us a callback) */
+			vnode->cb_version = 0;
+			vnode->cb_expiry = 0;
+			vnode->cb_type = 0;
+			vnode->cb_expires = get_seconds();
+		} else {
+			vnode->cb_version = cb->version;
+			vnode->cb_expiry = cb->expiry;
+			vnode->cb_type = cb->type;
+			vnode->cb_expires = vnode->cb_expiry + get_seconds();
+		}
+	}
+
 	ret = afs_inode_map_status(vnode, key);
 	if (ret < 0)
 		goto bad_inode;
 
 	/* success */
+	clear_bit(AFS_VNODE_UNSET, &vnode->flags);
 	inode->i_flags |= S_NOATIME;
 	unlock_new_inode(inode);
 	_leave(" = %p [CB { v=%u t=%u }]", inode, vnode->cb_version, vnode->cb_type);
@@ -182,6 +204,78 @@ bad_inode:
 }
 
 /*
+ * validate a vnode/inode
+ * - there are several things we need to check
+ *   - parent dir data changes (rm, rmdir, rename, mkdir, create, link,
+ *     symlink)
+ *   - parent dir metadata changed (security changes)
+ *   - dentry data changed (write, truncate)
+ *   - dentry metadata changed (security changes)
+ */
+int afs_validate(struct afs_vnode *vnode, struct key *key)
+{
+	int ret;
+
+	_enter("{v={%x:%u} fl=%lx},%x",
+	       vnode->fid.vid, vnode->fid.vnode, vnode->flags,
+	       key_serial(key));
+
+	if (vnode->cb_promised &&
+	    !test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags) &&
+	    !test_bit(AFS_VNODE_MODIFIED, &vnode->flags) &&
+	    !test_bit(AFS_VNODE_ZAP_DATA, &vnode->flags)) {
+		if (vnode->cb_expires < get_seconds() + 10) {
+			_debug("callback expired");
+			set_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
+		} else {
+			goto valid;
+		}
+	}
+
+	if (test_bit(AFS_VNODE_DELETED, &vnode->flags))
+		goto valid;
+
+	mutex_lock(&vnode->validate_lock);
+
+	/* if the promise has expired, we need to check the server again to get
+	 * a new promise - note that if the (parent) directory's metadata was
+	 * changed then the security may be different and we may no longer have
+	 * access */
+	if (!vnode->cb_promised ||
+	    test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags)) {
+		_debug("not promised");
+		ret = afs_vnode_fetch_status(vnode, NULL, key);
+		if (ret < 0)
+			goto error_unlock;
+		_debug("new promise [fl=%lx]", vnode->flags);
+	}
+
+	if (test_bit(AFS_VNODE_DELETED, &vnode->flags)) {
+		_debug("file already deleted");
+		ret = -ESTALE;
+		goto error_unlock;
+	}
+
+	/* if the vnode's data version number changed then its contents are
+	 * different */
+	if (test_and_clear_bit(AFS_VNODE_ZAP_DATA, &vnode->flags)) {
+		_debug("zap data {%x:%d}", vnode->fid.vid, vnode->fid.vnode);
+		invalidate_remote_inode(&vnode->vfs_inode);
+	}
+
+	clear_bit(AFS_VNODE_MODIFIED, &vnode->flags);
+	mutex_unlock(&vnode->validate_lock);
+valid:
+	_leave(" = 0");
+	return 0;
+
+error_unlock:
+	mutex_unlock(&vnode->validate_lock);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
  * read the attributes of an inode
  */
 int afs_inode_getattr(struct vfsmount *mnt, struct dentry *dentry,
@@ -207,9 +301,10 @@ void afs_clear_inode(struct inode *inode)
 
 	vnode = AFS_FS_I(inode);
 
-	_enter("ino=%lu { vn=%08x v=%u x=%u t=%u }",
-	       inode->i_ino,
+	_enter("{%x:%d.%d} v=%u x=%u t=%u }",
+	       vnode->fid.vid,
 	       vnode->fid.vnode,
+	       vnode->fid.unique,
 	       vnode->cb_version,
 	       vnode->cb_expiry,
 	       vnode->cb_type);
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 6120d4b..73bfa0b 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -80,6 +80,7 @@ struct afs_call {
 	void			*reply;		/* reply buffer (first part) */
 	void			*reply2;	/* reply buffer (second part) */
 	void			*reply3;	/* reply buffer (third part) */
+	void			*reply4;	/* reply buffer (fourth part) */
 	enum {					/* call state */
 		AFS_CALL_REQUESTING,	/* request is being sent for outgoing call */
 		AFS_CALL_AWAIT_REPLY,	/* awaiting reply to outgoing call */
@@ -300,19 +301,18 @@ struct afs_vnode {
 #endif
 	struct afs_permits	*permits;	/* cache of permits so far obtained */
 	struct mutex		permits_lock;	/* lock for altering permits list */
+	struct mutex		validate_lock;	/* lock for validating this vnode */
 	wait_queue_head_t	update_waitq;	/* status fetch waitqueue */
-	unsigned		update_cnt;	/* number of outstanding ops that will update the
+	int			update_cnt;	/* number of outstanding ops that will update the
 						 * status */
 	spinlock_t		lock;		/* waitqueue/flags lock */
 	unsigned long		flags;
 #define AFS_VNODE_CB_BROKEN	0		/* set if vnode's callback was broken */
-#define AFS_VNODE_CHANGED	1		/* set if vnode's metadata changed */
+#define AFS_VNODE_UNSET		1		/* set if vnode attributes not yet set */
 #define AFS_VNODE_MODIFIED	2		/* set if vnode's data modified */
 #define AFS_VNODE_ZAP_DATA	3		/* set if vnode's data should be invalidated */
 #define AFS_VNODE_DELETED	4		/* set if vnode deleted on server */
 #define AFS_VNODE_MOUNTPOINT	5		/* set if vnode is a mountpoint symlink */
-#define AFS_VNODE_DIR_CHANGED	6		/* set if vnode's parent dir metadata changed */
-#define AFS_VNODE_DIR_MODIFIED	7		/* set if vnode's parent dir data modified */
 
 	long			acl_order;	/* ACL check count (callback break count) */
 
@@ -320,7 +320,6 @@ struct afs_vnode {
 	struct rb_node		server_rb;	/* link in server->fs_vnodes */
 	struct rb_node		cb_promise;	/* link in server->cb_promises */
 	struct work_struct	cb_broken_work;	/* work to be done on callback break */
-	struct mutex		cb_broken_lock;	/* lock against multiple attempts to fix break */
 	time_t			cb_expires;	/* time at which callback expires */
 	time_t			cb_expires_at;	/* time used to order cb_promise */
 	unsigned		cb_version;	/* callback version */
@@ -388,6 +387,7 @@ extern void afs_init_callback_state(struct afs_server *);
 extern void afs_broken_callback_work(struct work_struct *);
 extern void afs_break_callbacks(struct afs_server *, size_t,
 				struct afs_callback[]);
+extern void afs_discard_callback_on_delete(struct afs_vnode *);
 extern void afs_give_up_callback(struct afs_vnode *);
 extern void afs_dispatch_give_up_callbacks(struct work_struct *);
 extern void afs_flush_callback_breaks(struct afs_server *);
@@ -448,14 +448,34 @@ extern int afs_fs_give_up_callbacks(struct afs_server *,
 				    const struct afs_wait_mode *);
 extern int afs_fs_fetch_data(struct afs_server *, struct key *,
 			     struct afs_vnode *, off_t, size_t, struct page *,
-			     struct afs_volsync *,
 			     const struct afs_wait_mode *);
+extern int afs_fs_create(struct afs_server *, struct key *,
+			 struct afs_vnode *, const char *, umode_t,
+			 struct afs_fid *, struct afs_file_status *,
+			 struct afs_callback *,
+			 const struct afs_wait_mode *);
+extern int afs_fs_remove(struct afs_server *, struct key *,
+			 struct afs_vnode *, const char *, bool,
+			 const struct afs_wait_mode *);
+extern int afs_fs_link(struct afs_server *, struct key *, struct afs_vnode *,
+		       struct afs_vnode *, const char *,
+		       const struct afs_wait_mode *);
+extern int afs_fs_symlink(struct afs_server *, struct key *,
+			  struct afs_vnode *, const char *, const char *,
+			  struct afs_fid *, struct afs_file_status *,
+			  const struct afs_wait_mode *);
+extern int afs_fs_rename(struct afs_server *, struct key *,
+			 struct afs_vnode *, const char *,
+			 struct afs_vnode *, const char *,
+			 const struct afs_wait_mode *);
 
 /*
  * inode.c
  */
 extern struct inode *afs_iget(struct super_block *, struct key *,
-			      struct afs_fid *);
+			      struct afs_fid *, struct afs_file_status *,
+			      struct afs_callback *);
+extern int afs_validate(struct afs_vnode *, struct key *);
 extern int afs_inode_getattr(struct vfsmount *, struct dentry *,
 			     struct kstat *);
 extern void afs_zap_permits(struct rcu_head *);
@@ -522,7 +542,11 @@ extern int afs_permission(struct inode *, int, struct nameidata *);
  */
 extern spinlock_t afs_server_peer_lock;
 
-#define afs_get_server(S) do { atomic_inc(&(S)->usage); } while(0)
+#define afs_get_server(S)					\
+do {								\
+	_debug("GET SERVER %d", atomic_read(&(S)->usage));	\
+	atomic_inc(&(S)->usage);				\
+} while(0)
 
 extern struct afs_server *afs_lookup_server(struct afs_cell *,
 					    const struct in_addr *);
@@ -588,10 +612,24 @@ static inline struct inode *AFS_VNODE_TO_I(struct afs_vnode *vnode)
 	return &vnode->vfs_inode;
 }
 
+extern void afs_vnode_finalise_status_update(struct afs_vnode *,
+					     struct afs_server *);
 extern int afs_vnode_fetch_status(struct afs_vnode *, struct afs_vnode *,
 				  struct key *);
 extern int afs_vnode_fetch_data(struct afs_vnode *, struct key *,
 				off_t, size_t, struct page *);
+extern int afs_vnode_create(struct afs_vnode *, struct key *, const char *,
+			    umode_t, struct afs_fid *, struct afs_file_status *,
+			    struct afs_callback *, struct afs_server **);
+extern int afs_vnode_remove(struct afs_vnode *, struct key *, const char *,
+			    bool);
+extern int afs_vnode_link(struct afs_vnode *, struct afs_vnode *, struct key *,
+			  const char *);
+extern int afs_vnode_symlink(struct afs_vnode *, struct key *, const char *,
+			     const char *, struct afs_fid *,
+			     struct afs_file_status *, struct afs_server **);
+extern int afs_vnode_rename(struct afs_vnode *, struct afs_vnode *,
+			    struct key *, const char *, const char *);
 
 /*
  * volume.c
diff --git a/fs/afs/misc.c b/fs/afs/misc.c
index 98e9276..cdb9792 100644
--- a/fs/afs/misc.c
+++ b/fs/afs/misc.c
@@ -22,6 +22,7 @@ int afs_abort_to_error(u32 abort_code)
 {
 	switch (abort_code) {
 	case 13:		return -EACCES;
+	case 30:		return -EROFS;
 	case VSALVAGE:		return -EIO;
 	case VNOVNODE:		return -ENOENT;
 	case VNOVOL:		return -ENOMEDIUM;
@@ -33,6 +34,24 @@ int afs_abort_to_error(u32 abort_code)
 	case VOVERQUOTA:	return -EDQUOT;
 	case VBUSY:		return -EBUSY;
 	case VMOVED:		return -ENXIO;
-	default:		return -EIO;
+	case 0x2f6df0c:		return -EACCES;
+	case 0x2f6df0f:		return -EBUSY;
+	case 0x2f6df10:		return -EEXIST;
+	case 0x2f6df11:		return -EXDEV;
+	case 0x2f6df13:		return -ENOTDIR;
+	case 0x2f6df14:		return -EISDIR;
+	case 0x2f6df15:		return -EINVAL;
+	case 0x2f6df1a:		return -EFBIG;
+	case 0x2f6df1b:		return -ENOSPC;
+	case 0x2f6df1d:		return -EROFS;
+	case 0x2f6df1e:		return -EMLINK;
+	case 0x2f6df20:		return -EDOM;
+	case 0x2f6df21:		return -ERANGE;
+	case 0x2f6df22:		return -EDEADLK;
+	case 0x2f6df23:		return -ENAMETOOLONG;
+	case 0x2f6df24:		return -ENOLCK;
+	case 0x2f6df26:		return -ENOTEMPTY;
+	case 0x2f6df78:		return -EDQUOT;
+	default:		return -EREMOTEIO;
 	}
 }
diff --git a/fs/afs/security.c b/fs/afs/security.c
index cbdd7f7..f9f424d 100644
--- a/fs/afs/security.c
+++ b/fs/afs/security.c
@@ -92,7 +92,7 @@ static struct afs_vnode *afs_get_auth_inode(struct afs_vnode *vnode,
 		ASSERT(auth_inode != NULL);
 	} else {
 		auth_inode = afs_iget(vnode->vfs_inode.i_sb, key,
-				      &vnode->status.parent);
+				      &vnode->status.parent, NULL, NULL);
 		if (IS_ERR(auth_inode))
 			return ERR_PTR(PTR_ERR(auth_inode));
 	}
@@ -288,7 +288,8 @@ int afs_permission(struct inode *inode, int mask, struct nameidata *nd)
 	struct key *key;
 	int ret;
 
-	_enter("{%x:%x},%x,", vnode->fid.vid, vnode->fid.vnode, mask);
+	_enter("{{%x:%x},%lx},%x,",
+	       vnode->fid.vid, vnode->fid.vnode, vnode->flags, mask);
 
 	key = afs_request_key(vnode->volume->cell);
 	if (IS_ERR(key)) {
@@ -296,13 +297,19 @@ int afs_permission(struct inode *inode, int mask, struct nameidata *nd)
 		return PTR_ERR(key);
 	}
 
+	/* if the promise has expired, we need to check the server again */
+	if (!vnode->cb_promised) {
+		_debug("not promised");
+		ret = afs_vnode_fetch_status(vnode, NULL, key);
+		if (ret < 0)
+			goto error;
+		_debug("new promise [fl=%lx]", vnode->flags);
+	}
+
 	/* check the permits to see if we've got one yet */
 	ret = afs_check_permit(vnode, key, &access);
-	if (ret < 0) {
-		key_put(key);
-		_leave(" = %d [check]", ret);
-		return ret;
-	}
+	if (ret < 0)
+		goto error;
 
 	/* interpret the access mask */
 	_debug("REQ %x ACC %x on %s",
@@ -336,10 +343,14 @@ int afs_permission(struct inode *inode, int mask, struct nameidata *nd)
 	}
 
 	key_put(key);
-	return generic_permission(inode, mask, NULL);
+	ret = generic_permission(inode, mask, NULL);
+	_leave(" = %d", ret);
+	return ret;
 
 permission_denied:
+	ret = -EACCES;
+error:
 	key_put(key);
-	_leave(" = -EACCES");
-	return -EACCES;
+	_leave(" = %d", ret);
+	return ret;
 }
diff --git a/fs/afs/server.c b/fs/afs/server.c
index d44bba3..1654e90 100644
--- a/fs/afs/server.c
+++ b/fs/afs/server.c
@@ -223,6 +223,8 @@ void afs_put_server(struct afs_server *server)
 
 	_enter("%p{%d}", server, atomic_read(&server->usage));
 
+	_debug("PUT SERVER %d", atomic_read(&server->usage));
+
 	ASSERTCMP(atomic_read(&server->usage), >, 0);
 
 	if (likely(!atomic_dec_and_test(&server->usage))) {
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 17d7092..441f583 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -331,7 +331,7 @@ static int afs_fill_super(struct super_block *sb, void *data)
 	fid.vid		= as->volume->vid;
 	fid.vnode	= 1;
 	fid.unique	= 1;
-	inode = afs_iget(sb, params->key, &fid);
+	inode = afs_iget(sb, params->key, &fid, NULL, NULL);
 	if (IS_ERR(inode))
 		goto error_inode;
 
@@ -473,9 +473,9 @@ static void afs_i_init_once(void *_vnode, struct kmem_cache *cachep,
 		inode_init_once(&vnode->vfs_inode);
 		init_waitqueue_head(&vnode->update_waitq);
 		mutex_init(&vnode->permits_lock);
+		mutex_init(&vnode->validate_lock);
 		spin_lock_init(&vnode->lock);
 		INIT_WORK(&vnode->cb_broken_work, afs_broken_callback_work);
-		mutex_init(&vnode->cb_broken_lock);
 	}
 }
 
@@ -497,7 +497,7 @@ static struct inode *afs_alloc_inode(struct super_block *sb)
 
 	vnode->volume		= NULL;
 	vnode->update_cnt	= 0;
-	vnode->flags		= 0;
+	vnode->flags		= 1 << AFS_VNODE_UNSET;
 	vnode->cb_promised	= false;
 
 	return &vnode->vfs_inode;
diff --git a/fs/afs/vnode.c b/fs/afs/vnode.c
index 1600976..a1904ab 100644
--- a/fs/afs/vnode.c
+++ b/fs/afs/vnode.c
@@ -30,7 +30,7 @@ static noinline bool dump_tree_aux(struct rb_node *node, struct rb_node *parent,
 		bad = dump_tree_aux(node->rb_left, node, depth + 2, '/');
 
 	vnode = rb_entry(node, struct afs_vnode, cb_promise);
-	kdebug("%c %*.*s%c%p {%d}",
+	_debug("%c %*.*s%c%p {%d}",
 	       rb_is_red(node) ? 'R' : 'B',
 	       depth, depth, "", lr,
 	       vnode, vnode->cb_expires_at);
@@ -47,7 +47,7 @@ static noinline bool dump_tree_aux(struct rb_node *node, struct rb_node *parent,
 
 static noinline void dump_tree(const char *name, struct afs_server *server)
 {
-	kenter("%s", name);
+	_enter("%s", name);
 	if (dump_tree_aux(server->cb_promises.rb_node, NULL, 0, '-'))
 		BUG();
 }
@@ -187,47 +187,61 @@ static void afs_vnode_deleted_remotely(struct afs_vnode *vnode)
 		spin_unlock(&server->cb_lock);
 	}
 
+	spin_lock(&vnode->server->fs_lock);
+	rb_erase(&vnode->server_rb, &vnode->server->fs_vnodes);
+	spin_unlock(&vnode->server->fs_lock);
+
+	vnode->server = NULL;
 	afs_put_server(server);
 }
 
 /*
- * finish off updating the recorded status of a file
+ * finish off updating the recorded status of a file after a successful
+ * operation completion
  * - starts callback expiry timer
  * - adds to server's callback list
  */
-static void afs_vnode_finalise_status_update(struct afs_vnode *vnode,
-					     struct afs_server *server,
-					     int ret)
+void afs_vnode_finalise_status_update(struct afs_vnode *vnode,
+				      struct afs_server *server)
 {
 	struct afs_server *oldserver = NULL;
 
-	_enter("%p,%p,%d", vnode, server, ret);
+	_enter("%p,%p", vnode, server);
+
+	spin_lock(&vnode->lock);
+	clear_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
+	afs_vnode_note_promise(vnode, server);
+	vnode->update_cnt--;
+	ASSERTCMP(vnode->update_cnt, >=, 0);
+	spin_unlock(&vnode->lock);
+
+	wake_up_all(&vnode->update_waitq);
+	afs_put_server(oldserver);
+	_leave("");
+}
+
+/*
+ * finish off updating the recorded status of a file after an operation failed
+ */
+static void afs_vnode_status_update_failed(struct afs_vnode *vnode, int ret)
+{
+	_enter("%p,%d", vnode, ret);
 
 	spin_lock(&vnode->lock);
 
 	clear_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
 
-	switch (ret) {
-	case 0:
-		afs_vnode_note_promise(vnode, server);
-		break;
-	case -ENOENT:
+	if (ret == -ENOENT) {
 		/* the file was deleted on the server */
 		_debug("got NOENT from server - marking file deleted");
 		afs_vnode_deleted_remotely(vnode);
-		break;
-	default:
-		break;
 	}
 
 	vnode->update_cnt--;
-
+	ASSERTCMP(vnode->update_cnt, >=, 0);
 	spin_unlock(&vnode->lock);
 
 	wake_up_all(&vnode->update_waitq);
-
-	afs_put_server(oldserver);
-
 	_leave("");
 }
 
@@ -275,8 +289,12 @@ int afs_vnode_fetch_status(struct afs_vnode *vnode,
 		return 0;
 	}
 
+	ASSERTCMP(vnode->update_cnt, >=, 0);
+
 	if (vnode->update_cnt > 0) {
 		/* someone else started a fetch */
+		_debug("wait on fetch %d", vnode->update_cnt);
+
 		set_current_state(TASK_UNINTERRUPTIBLE);
 		ASSERT(myself.func != NULL);
 		add_wait_queue(&vnode->update_waitq, &myself);
@@ -325,7 +343,7 @@ get_anyway:
 		/* pick a server to query */
 		server = afs_volume_pick_fileserver(vnode);
 		if (IS_ERR(server))
-			return PTR_ERR(server);
+			goto no_server;
 
 		_debug("USING SERVER: %p{%08x}",
 		       server, ntohl(server->addr.s_addr));
@@ -336,17 +354,34 @@ get_anyway:
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
 	/* adjust the flags */
-	if (ret == 0 && auth_vnode)
-		afs_cache_permit(vnode, key, acl_order);
-	afs_vnode_finalise_status_update(vnode, server, ret);
+	if (ret == 0) {
+		_debug("adjust");
+		if (auth_vnode)
+			afs_cache_permit(vnode, key, acl_order);
+		afs_vnode_finalise_status_update(vnode, server);
+		afs_put_server(server);
+	} else {
+		_debug("failed [%d]", ret);
+		afs_vnode_status_update_failed(vnode, ret);
+	}
 
-	_leave(" = %d", ret);
+	ASSERTCMP(vnode->update_cnt, >=, 0);
+
+	_leave(" = %d [cnt %d]", ret, vnode->update_cnt);
 	return ret;
+
+no_server:
+	spin_lock(&vnode->lock);
+	vnode->update_cnt--;
+	ASSERTCMP(vnode->update_cnt, >=, 0);
+	spin_unlock(&vnode->lock);
+	_leave(" = %ld [cnt %d]", PTR_ERR(server), vnode->update_cnt);
+	return PTR_ERR(server);
 }
 
 /*
  * fetch file data from the volume
- * - TODO implement caching and server failover
+ * - TODO implement caching
  */
 int afs_vnode_fetch_data(struct afs_vnode *vnode, struct key *key,
 			 off_t offset, size_t length, struct page *page)
@@ -372,18 +407,349 @@ int afs_vnode_fetch_data(struct afs_vnode *vnode, struct key *key,
 		/* pick a server to query */
 		server = afs_volume_pick_fileserver(vnode);
 		if (IS_ERR(server))
-			return PTR_ERR(server);
+			goto no_server;
 
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
 		ret = afs_fs_fetch_data(server, key, vnode, offset, length,
-					page, NULL, &afs_sync_call);
+					page, &afs_sync_call);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
 	/* adjust the flags */
-	afs_vnode_finalise_status_update(vnode, server, ret);
+	if (ret == 0) {
+		afs_vnode_finalise_status_update(vnode, server);
+		afs_put_server(server);
+	} else {
+		afs_vnode_status_update_failed(vnode, ret);
+	}
 
 	_leave(" = %d", ret);
 	return ret;
+
+no_server:
+	spin_lock(&vnode->lock);
+	vnode->update_cnt--;
+	ASSERTCMP(vnode->update_cnt, >=, 0);
+	spin_unlock(&vnode->lock);
+	return PTR_ERR(server);
+}
+
+/*
+ * make a file or a directory
+ */
+int afs_vnode_create(struct afs_vnode *vnode, struct key *key,
+		     const char *name, umode_t mode, struct afs_fid *newfid,
+		     struct afs_file_status *newstatus,
+		     struct afs_callback *newcb, struct afs_server **_server)
+{
+	struct afs_server *server;
+	int ret;
+
+	_enter("%s{%u,%u,%u},%x,%s,,",
+	       vnode->volume->vlocation->vldb.name,
+	       vnode->fid.vid,
+	       vnode->fid.vnode,
+	       vnode->fid.unique,
+	       key_serial(key),
+	       name);
+
+	/* this op will fetch the status on the directory we're creating in */
+	spin_lock(&vnode->lock);
+	vnode->update_cnt++;
+	spin_unlock(&vnode->lock);
+
+	do {
+		/* pick a server to query */
+		server = afs_volume_pick_fileserver(vnode);
+		if (IS_ERR(server))
+			goto no_server;
+
+		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
+
+		ret = afs_fs_create(server, key, vnode, name, mode, newfid,
+				    newstatus, newcb, &afs_sync_call);
+
+	} while (!afs_volume_release_fileserver(vnode, server, ret));
+
+	/* adjust the flags */
+	if (ret == 0) {
+		afs_vnode_finalise_status_update(vnode, server);
+		*_server = server;
+	} else {
+		afs_vnode_status_update_failed(vnode, ret);
+		*_server = NULL;
+	}
+
+	_leave(" = %d [cnt %d]", ret, vnode->update_cnt);
+	return ret;
+
+no_server:
+	spin_lock(&vnode->lock);
+	vnode->update_cnt--;
+	ASSERTCMP(vnode->update_cnt, >=, 0);
+	spin_unlock(&vnode->lock);
+	_leave(" = %ld [cnt %d]", PTR_ERR(server), vnode->update_cnt);
+	return PTR_ERR(server);
+}
+
+/*
+ * remove a file or directory
+ */
+int afs_vnode_remove(struct afs_vnode *vnode, struct key *key, const char *name,
+		     bool isdir)
+{
+	struct afs_server *server;
+	int ret;
+
+	_enter("%s{%u,%u,%u},%x,%s",
+	       vnode->volume->vlocation->vldb.name,
+	       vnode->fid.vid,
+	       vnode->fid.vnode,
+	       vnode->fid.unique,
+	       key_serial(key),
+	       name);
+
+	/* this op will fetch the status on the directory we're removing from */
+	spin_lock(&vnode->lock);
+	vnode->update_cnt++;
+	spin_unlock(&vnode->lock);
+
+	do {
+		/* pick a server to query */
+		server = afs_volume_pick_fileserver(vnode);
+		if (IS_ERR(server))
+			goto no_server;
+
+		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
+
+		ret = afs_fs_remove(server, key, vnode, name, isdir,
+				    &afs_sync_call);
+
+	} while (!afs_volume_release_fileserver(vnode, server, ret));
+
+	/* adjust the flags */
+	if (ret == 0) {
+		afs_vnode_finalise_status_update(vnode, server);
+		afs_put_server(server);
+	} else {
+		afs_vnode_status_update_failed(vnode, ret);
+	}
+
+	_leave(" = %d [cnt %d]", ret, vnode->update_cnt);
+	return ret;
+
+no_server:
+	spin_lock(&vnode->lock);
+	vnode->update_cnt--;
+	ASSERTCMP(vnode->update_cnt, >=, 0);
+	spin_unlock(&vnode->lock);
+	_leave(" = %ld [cnt %d]", PTR_ERR(server), vnode->update_cnt);
+	return PTR_ERR(server);
+}
+
+/*
+ * create a hard link
+ */
+extern int afs_vnode_link(struct afs_vnode *dvnode, struct afs_vnode *vnode,
+			  struct key *key, const char *name)
+{
+	struct afs_server *server;
+	int ret;
+
+	_enter("%s{%u,%u,%u},%s{%u,%u,%u},%x,%s",
+	       dvnode->volume->vlocation->vldb.name,
+	       dvnode->fid.vid,
+	       dvnode->fid.vnode,
+	       dvnode->fid.unique,
+	       vnode->volume->vlocation->vldb.name,
+	       vnode->fid.vid,
+	       vnode->fid.vnode,
+	       vnode->fid.unique,
+	       key_serial(key),
+	       name);
+
+	/* this op will fetch the status on the directory we're removing from */
+	spin_lock(&vnode->lock);
+	vnode->update_cnt++;
+	spin_unlock(&vnode->lock);
+	spin_lock(&dvnode->lock);
+	dvnode->update_cnt++;
+	spin_unlock(&dvnode->lock);
+
+	do {
+		/* pick a server to query */
+		server = afs_volume_pick_fileserver(dvnode);
+		if (IS_ERR(server))
+			goto no_server;
+
+		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
+
+		ret = afs_fs_link(server, key, dvnode, vnode, name,
+				  &afs_sync_call);
+
+	} while (!afs_volume_release_fileserver(dvnode, server, ret));
+
+	/* adjust the flags */
+	if (ret == 0) {
+		afs_vnode_finalise_status_update(vnode, server);
+		afs_vnode_finalise_status_update(dvnode, server);
+		afs_put_server(server);
+	} else {
+		afs_vnode_status_update_failed(vnode, ret);
+		afs_vnode_status_update_failed(dvnode, ret);
+	}
+
+	_leave(" = %d [cnt %d]", ret, vnode->update_cnt);
+	return ret;
+
+no_server:
+	spin_lock(&vnode->lock);
+	vnode->update_cnt--;
+	ASSERTCMP(vnode->update_cnt, >=, 0);
+	spin_unlock(&vnode->lock);
+	spin_lock(&dvnode->lock);
+	dvnode->update_cnt--;
+	ASSERTCMP(dvnode->update_cnt, >=, 0);
+	spin_unlock(&dvnode->lock);
+	_leave(" = %ld [cnt %d]", PTR_ERR(server), vnode->update_cnt);
+	return PTR_ERR(server);
+}
+
+/*
+ * create a symbolic link
+ */
+int afs_vnode_symlink(struct afs_vnode *vnode, struct key *key,
+		      const char *name, const char *content,
+		      struct afs_fid *newfid,
+		      struct afs_file_status *newstatus,
+		      struct afs_server **_server)
+{
+	struct afs_server *server;
+	int ret;
+
+	_enter("%s{%u,%u,%u},%x,%s,%s,,,",
+	       vnode->volume->vlocation->vldb.name,
+	       vnode->fid.vid,
+	       vnode->fid.vnode,
+	       vnode->fid.unique,
+	       key_serial(key),
+	       name, content);
+
+	/* this op will fetch the status on the directory we're creating in */
+	spin_lock(&vnode->lock);
+	vnode->update_cnt++;
+	spin_unlock(&vnode->lock);
+
+	do {
+		/* pick a server to query */
+		server = afs_volume_pick_fileserver(vnode);
+		if (IS_ERR(server))
+			goto no_server;
+
+		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
+
+		ret = afs_fs_symlink(server, key, vnode, name, content,
+				     newfid, newstatus, &afs_sync_call);
+
+	} while (!afs_volume_release_fileserver(vnode, server, ret));
+
+	/* adjust the flags */
+	if (ret == 0) {
+		afs_vnode_finalise_status_update(vnode, server);
+		*_server = server;
+	} else {
+		afs_vnode_status_update_failed(vnode, ret);
+		*_server = NULL;
+	}
+
+	_leave(" = %d [cnt %d]", ret, vnode->update_cnt);
+	return ret;
+
+no_server:
+	spin_lock(&vnode->lock);
+	vnode->update_cnt--;
+	ASSERTCMP(vnode->update_cnt, >=, 0);
+	spin_unlock(&vnode->lock);
+	_leave(" = %ld [cnt %d]", PTR_ERR(server), vnode->update_cnt);
+	return PTR_ERR(server);
+}
+
+/*
+ * rename a file
+ */
+int afs_vnode_rename(struct afs_vnode *orig_dvnode,
+		     struct afs_vnode *new_dvnode,
+		     struct key *key,
+		     const char *orig_name,
+		     const char *new_name)
+{
+	struct afs_server *server;
+	int ret;
+
+	_enter("%s{%u,%u,%u},%s{%u,%u,%u},%x,%s,%s",
+	       orig_dvnode->volume->vlocation->vldb.name,
+	       orig_dvnode->fid.vid,
+	       orig_dvnode->fid.vnode,
+	       orig_dvnode->fid.unique,
+	       new_dvnode->volume->vlocation->vldb.name,
+	       new_dvnode->fid.vid,
+	       new_dvnode->fid.vnode,
+	       new_dvnode->fid.unique,
+	       key_serial(key),
+	       orig_name,
+	       new_name);
+
+	/* this op will fetch the status on both the directories we're dealing
+	 * with */
+	spin_lock(&orig_dvnode->lock);
+	orig_dvnode->update_cnt++;
+	spin_unlock(&orig_dvnode->lock);
+	if (new_dvnode != orig_dvnode) {
+		spin_lock(&new_dvnode->lock);
+		new_dvnode->update_cnt++;
+		spin_unlock(&new_dvnode->lock);
+	}
+
+	do {
+		/* pick a server to query */
+		server = afs_volume_pick_fileserver(orig_dvnode);
+		if (IS_ERR(server))
+			goto no_server;
+
+		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
+
+		ret = afs_fs_rename(server, key, orig_dvnode, orig_name,
+				    new_dvnode, new_name, &afs_sync_call);
+
+	} while (!afs_volume_release_fileserver(orig_dvnode, server, ret));
+
+	/* adjust the flags */
+	if (ret == 0) {
+		afs_vnode_finalise_status_update(orig_dvnode, server);
+		if (new_dvnode != orig_dvnode)
+			afs_vnode_finalise_status_update(new_dvnode, server);
+		afs_put_server(server);
+	} else {
+		afs_vnode_status_update_failed(orig_dvnode, ret);
+		if (new_dvnode != orig_dvnode)
+			afs_vnode_status_update_failed(new_dvnode, ret);
+	}
+
+	_leave(" = %d [cnt %d]", ret, orig_dvnode->update_cnt);
+	return ret;
+
+no_server:
+	spin_lock(&orig_dvnode->lock);
+	orig_dvnode->update_cnt--;
+	ASSERTCMP(orig_dvnode->update_cnt, >=, 0);
+	spin_unlock(&orig_dvnode->lock);
+	if (new_dvnode != orig_dvnode) {
+		spin_lock(&new_dvnode->lock);
+		new_dvnode->update_cnt--;
+		ASSERTCMP(new_dvnode->update_cnt, >=, 0);
+		spin_unlock(&new_dvnode->lock);
+	}
+	_leave(" = %ld [cnt %d]", PTR_ERR(server), orig_dvnode->update_cnt);
+	return PTR_ERR(server);
 }
diff --git a/fs/afs/volume.c b/fs/afs/volume.c
index 15e1367..dd160ca 100644
--- a/fs/afs/volume.c
+++ b/fs/afs/volume.c
@@ -295,6 +295,7 @@ struct afs_server *afs_volume_pick_fileserver(struct afs_vnode *vnode)
  * - releases the ref on the server struct that was acquired by picking
  * - records result of using a particular server to access a volume
  * - return 0 to try again, 1 if okay or to issue error
+ * - the caller must release the server struct if result was 0
  */
 int afs_volume_release_fileserver(struct afs_vnode *vnode,
 				  struct afs_server *server,
@@ -312,7 +313,8 @@ int afs_volume_release_fileserver(struct afs_vnode *vnode,
 	case 0:
 		server->fs_act_jif = jiffies;
 		server->fs_state = 0;
-		break;
+		_leave("");
+		return 1;
 
 		/* the fileserver denied all knowledge of the volume */
 	case -ENOMEDIUM:
@@ -377,14 +379,12 @@ int afs_volume_release_fileserver(struct afs_vnode *vnode,
 		server->fs_act_jif = jiffies;
 	case -ENOMEM:
 	case -ENONET:
-		break;
+		/* tell the caller to accept the result */
+		afs_put_server(server);
+		_leave(" [local failure]");
+		return 1;
 	}
 
-	/* tell the caller to accept the result */
-	afs_put_server(server);
-	_leave("");
-	return 1;
-
 	/* tell the caller to loop around and try the next server */
 try_next_server_upw:
 	up_write(&volume->server_sem);

