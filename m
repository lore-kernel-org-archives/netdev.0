From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/3] AFS: AFS fixups
Date: Tue, 08 May 2007 20:44:06 +0100
Message-ID: <20070508194406.27477.22965.stgit@warthog.cambridge.redhat.com>
References: <20070508194358.27477.74888.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	dhowells@redhat.com
To: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1031583AbXEHTpO@vger.kernel.org>
In-Reply-To: <20070508194358.27477.74888.stgit@warthog.cambridge.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make some miscellaneous changes to the AFS filesystem:

 (1) Assert RCU barriers on module exit to make sure RCU has finished with
     callbacks in this module.

 (2) Correctly handle the AFS server returning a zero-length read.

 (3) Split out data zapping calls into one function (afs_zap_data).

 (4) Rename some afs_file_*() functions to afs_*() where they apply to
     non-regular files too.

 (5) Be consistent about the presentation of volume ID:vnode ID in debugging
     output.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/callback.c |    9 ++----
 fs/afs/dir.c      |   18 ++++++-------
 fs/afs/file.c     |   75 ++++++++++++++++++-----------------------------------
 fs/afs/fsclient.c |   37 ++++++++++++++------------
 fs/afs/inode.c    |   25 +++++++++++++-----
 fs/afs/internal.h |   29 ++++++++++++++++----
 fs/afs/main.c     |    2 +
 fs/afs/misc.c     |    1 +
 fs/afs/mntpt.c    |    5 ++--
 fs/afs/security.c |   12 +++++---
 fs/afs/server.c   |    3 ++
 fs/afs/vnode.c    |   14 +++++-----
 12 files changed, 121 insertions(+), 109 deletions(-)

diff --git a/fs/afs/callback.c b/fs/afs/callback.c
index 9bdbf36..f64e40f 100644
--- a/fs/afs/callback.c
+++ b/fs/afs/callback.c
@@ -44,7 +44,7 @@ void afs_init_callback_state(struct afs_server *server)
 	while (!RB_EMPTY_ROOT(&server->cb_promises)) {
 		vnode = rb_entry(server->cb_promises.rb_node,
 				 struct afs_vnode, cb_promise);
-		_debug("UNPROMISE { vid=%x vn=%u uq=%u}",
+		_debug("UNPROMISE { vid=%x:%u uq=%u}",
 		       vnode->fid.vid, vnode->fid.vnode, vnode->fid.unique);
 		rb_erase(&vnode->cb_promise, &server->cb_promises);
 		vnode->cb_promised = false;
@@ -84,11 +84,8 @@ void afs_broken_callback_work(struct work_struct *work)
 
 		/* if the vnode's data version number changed then its contents
 		 * are different */
-		if (test_and_clear_bit(AFS_VNODE_ZAP_DATA, &vnode->flags)) {
-			_debug("zap data {%x:%u}",
-			       vnode->fid.vid, vnode->fid.vnode);
-			invalidate_remote_inode(&vnode->vfs_inode);
-		}
+		if (test_and_clear_bit(AFS_VNODE_ZAP_DATA, &vnode->flags))
+			afs_zap_data(vnode);
 	}
 
 out:
diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index ba88cc4..eca7bf8 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -55,7 +55,7 @@ const struct inode_operations afs_dir_inode_operations = {
 	.rmdir		= afs_rmdir,
 	.rename		= afs_rename,
 	.permission	= afs_permission,
-	.getattr	= afs_inode_getattr,
+	.getattr	= afs_getattr,
 };
 
 static struct dentry_operations afs_fs_dentry_operations = {
@@ -491,7 +491,7 @@ static struct dentry *afs_lookup(struct inode *dir, struct dentry *dentry,
 
 	vnode = AFS_FS_I(dir);
 
-	_enter("{%x:%d},%p{%s},",
+	_enter("{%x:%u},%p{%s},",
 	       vnode->fid.vid, vnode->fid.vnode, dentry, dentry->d_name.name);
 
 	ASSERTCMP(dentry->d_inode, ==, NULL);
@@ -731,7 +731,7 @@ static int afs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
 
 	dvnode = AFS_FS_I(dir);
 
-	_enter("{%x:%d},{%s},%o",
+	_enter("{%x:%u},{%s},%o",
 	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name, mode);
 
 	ret = -ENAMETOOLONG;
@@ -796,7 +796,7 @@ static int afs_rmdir(struct inode *dir, struct dentry *dentry)
 
 	dvnode = AFS_FS_I(dir);
 
-	_enter("{%x:%d},{%s}",
+	_enter("{%x:%u},{%s}",
 	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name);
 
 	ret = -ENAMETOOLONG;
@@ -842,7 +842,7 @@ static int afs_unlink(struct inode *dir, struct dentry *dentry)
 
 	dvnode = AFS_FS_I(dir);
 
-	_enter("{%x:%d},{%s}",
+	_enter("{%x:%u},{%s}",
 	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name);
 
 	ret = -ENAMETOOLONG;
@@ -916,7 +916,7 @@ static int afs_create(struct inode *dir, struct dentry *dentry, int mode,
 
 	dvnode = AFS_FS_I(dir);
 
-	_enter("{%x:%d},{%s},%o,",
+	_enter("{%x:%u},{%s},%o,",
 	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name, mode);
 
 	ret = -ENAMETOOLONG;
@@ -983,7 +983,7 @@ static int afs_link(struct dentry *from, struct inode *dir,
 	vnode = AFS_FS_I(from->d_inode);
 	dvnode = AFS_FS_I(dir);
 
-	_enter("{%x:%d},{%x:%d},{%s}",
+	_enter("{%x:%u},{%x:%u},{%s}",
 	       vnode->fid.vid, vnode->fid.vnode,
 	       dvnode->fid.vid, dvnode->fid.vnode,
 	       dentry->d_name.name);
@@ -1032,7 +1032,7 @@ static int afs_symlink(struct inode *dir, struct dentry *dentry,
 
 	dvnode = AFS_FS_I(dir);
 
-	_enter("{%x:%d},{%s},%s",
+	_enter("{%x:%u},{%s},%s",
 	       dvnode->fid.vid, dvnode->fid.vnode, dentry->d_name.name,
 	       content);
 
@@ -1104,7 +1104,7 @@ static int afs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	orig_dvnode = AFS_FS_I(old_dir);
 	new_dvnode = AFS_FS_I(new_dir);
 
-	_enter("{%x:%d},{%x:%d},{%x:%d},{%s}",
+	_enter("{%x:%u},{%x:%u},{%x:%u},{%s}",
 	       orig_dvnode->fid.vid, orig_dvnode->fid.vnode,
 	       vnode->fid.vid, vnode->fid.vnode,
 	       new_dvnode->fid.vid, new_dvnode->fid.vnode,
diff --git a/fs/afs/file.c b/fs/afs/file.c
index ae25649..3eb3fc7 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -17,9 +17,9 @@
 #include <linux/pagemap.h>
 #include "internal.h"
 
-static int afs_file_readpage(struct file *file, struct page *page);
-static void afs_file_invalidatepage(struct page *page, unsigned long offset);
-static int afs_file_releasepage(struct page *page, gfp_t gfp_flags);
+static int afs_readpage(struct file *file, struct page *page);
+static void afs_invalidatepage(struct page *page, unsigned long offset);
+static int afs_releasepage(struct page *page, gfp_t gfp_flags);
 
 const struct file_operations afs_file_operations = {
 	.open		= afs_open,
@@ -32,15 +32,15 @@ const struct file_operations afs_file_operations = {
 };
 
 const struct inode_operations afs_file_inode_operations = {
-	.getattr	= afs_inode_getattr,
+	.getattr	= afs_getattr,
 	.permission	= afs_permission,
 };
 
 const struct address_space_operations afs_fs_aops = {
-	.readpage	= afs_file_readpage,
+	.readpage	= afs_readpage,
 	.set_page_dirty	= __set_page_dirty_nobuffers,
-	.releasepage	= afs_file_releasepage,
-	.invalidatepage	= afs_file_invalidatepage,
+	.releasepage	= afs_releasepage,
+	.invalidatepage	= afs_invalidatepage,
 };
 
 /*
@@ -52,7 +52,7 @@ int afs_open(struct inode *inode, struct file *file)
 	struct key *key;
 	int ret;
 
-	_enter("{%x:%x},", vnode->fid.vid, vnode->fid.vnode);
+	_enter("{%x:%u},", vnode->fid.vid, vnode->fid.vnode);
 
 	key = afs_request_key(vnode->volume->cell);
 	if (IS_ERR(key)) {
@@ -78,7 +78,7 @@ int afs_release(struct inode *inode, struct file *file)
 {
 	struct afs_vnode *vnode = AFS_FS_I(inode);
 
-	_enter("{%x:%x},", vnode->fid.vid, vnode->fid.vnode);
+	_enter("{%x:%u},", vnode->fid.vid, vnode->fid.vnode);
 
 	key_put(file->private_data);
 	_leave(" = 0");
@@ -89,10 +89,10 @@ int afs_release(struct inode *inode, struct file *file)
  * deal with notification that a page was read from the cache
  */
 #ifdef AFS_CACHING_SUPPORT
-static void afs_file_readpage_read_complete(void *cookie_data,
-					    struct page *page,
-					    void *data,
-					    int error)
+static void afs_readpage_read_complete(void *cookie_data,
+				       struct page *page,
+				       void *data,
+				       int error)
 {
 	_enter("%p,%p,%p,%d", cookie_data, page, data, error);
 
@@ -109,10 +109,10 @@ static void afs_file_readpage_read_complete(void *cookie_data,
  * deal with notification that a page was written to the cache
  */
 #ifdef AFS_CACHING_SUPPORT
-static void afs_file_readpage_write_complete(void *cookie_data,
-					     struct page *page,
-					     void *data,
-					     int error)
+static void afs_readpage_write_complete(void *cookie_data,
+					struct page *page,
+					void *data,
+					int error)
 {
 	_enter("%p,%p,%p,%d", cookie_data, page, data, error);
 
@@ -121,9 +121,9 @@ static void afs_file_readpage_write_complete(void *cookie_data,
 #endif
 
 /*
- * AFS read page from file (or symlink)
+ * AFS read page from file, directory or symlink
  */
-static int afs_file_readpage(struct file *file, struct page *page)
+static int afs_readpage(struct file *file, struct page *page)
 {
 	struct afs_vnode *vnode;
 	struct inode *inode;
@@ -219,30 +219,13 @@ error:
 }
 
 /*
- * get a page cookie for the specified page
- */
-#ifdef AFS_CACHING_SUPPORT
-int afs_cache_get_page_cookie(struct page *page,
-			      struct cachefs_page **_page_cookie)
-{
-	int ret;
-
-	_enter("");
-	ret = cachefs_page_get_private(page,_page_cookie, GFP_NOIO);
-
-	_leave(" = %d", ret);
-	return ret;
-}
-#endif
-
-/*
  * invalidate part or all of a page
  */
-static void afs_file_invalidatepage(struct page *page, unsigned long offset)
+static void afs_invalidatepage(struct page *page, unsigned long offset)
 {
 	int ret = 1;
 
-	_enter("{%lu},%lu", page->index, offset);
+	kenter("{%lu},%lu", page->index, offset);
 
 	BUG_ON(!PageLocked(page));
 
@@ -274,23 +257,17 @@ static void afs_file_invalidatepage(struct page *page, unsigned long offset)
 /*
  * release a page and cleanup its private data
  */
-static int afs_file_releasepage(struct page *page, gfp_t gfp_flags)
+static int afs_releasepage(struct page *page, gfp_t gfp_flags)
 {
-	struct cachefs_page *pageio;
+	struct afs_vnode *vnode = AFS_FS_I(page->mapping->host);
 
-	_enter("{%lu},%x", page->index, gfp_flags);
+	_enter("{{%x:%u}[%lu],%lx},%x",
+	       vnode->fid.vid, vnode->fid.vnode, page->index, page->flags,
+	       gfp_flags);
 
 	if (PagePrivate(page)) {
-#ifdef AFS_CACHING_SUPPORT
-		struct afs_vnode *vnode = AFS_FS_I(page->mapping->host);
-		cachefs_uncache_page(vnode->cache, page);
-#endif
-
-		pageio = (struct cachefs_page *) page_private(page);
 		set_page_private(page, 0);
 		ClearPagePrivate(page);
-
-		kfree(pageio);
 	}
 
 	_leave(" = 0");
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index e54e6c2..1e65fee 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -206,7 +206,7 @@ int afs_fs_fetch_file_status(struct afs_server *server,
 	struct afs_call *call;
 	__be32 *bp;
 
-	_enter(",%x,{%x:%d},,",
+	_enter(",%x,{%x:%u},,",
 	       key_serial(key), vnode->fid.vid, vnode->fid.vnode);
 
 	call = afs_alloc_flat_call(&afs_RXFSFetchStatus, 16, (21 + 3 + 6) * 4);
@@ -265,25 +265,20 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 		call->offset = 0;
 		call->unmarshall++;
 
-		if (call->count < PAGE_SIZE) {
-			page = call->reply3;
-			buffer = kmap_atomic(page, KM_USER0);
-			memset(buffer + PAGE_SIZE - call->count, 0,
-			       call->count);
-			kunmap_atomic(buffer, KM_USER0);
-		}
-
 		/* extract the returned data */
 	case 2:
 		_debug("extract data");
-		page = call->reply3;
-		buffer = kmap_atomic(page, KM_USER0);
-		ret = afs_extract_data(call, skb, last, buffer, call->count);
-		kunmap_atomic(buffer, KM_USER0);
-		switch (ret) {
-		case 0:		break;
-		case -EAGAIN:	return 0;
-		default:	return ret;
+		if (call->count > 0) {
+			page = call->reply3;
+			buffer = kmap_atomic(page, KM_USER0);
+			ret = afs_extract_data(call, skb, last, buffer,
+					       call->count);
+			kunmap_atomic(buffer, KM_USER0);
+			switch (ret) {
+			case 0:		break;
+			case -EAGAIN:	return 0;
+			default:	return ret;
+			}
 		}
 
 		call->offset = 0;
@@ -318,6 +313,14 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 	if (!last)
 		return 0;
 
+	if (call->count < PAGE_SIZE) {
+		_debug("clear");
+		page = call->reply3;
+		buffer = kmap_atomic(page, KM_USER0);
+		memset(buffer + call->count, 0, PAGE_SIZE - call->count);
+		kunmap_atomic(buffer, KM_USER0);
+	}
+
 	_leave(" = 0 [done]");
 	return 0;
 }
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index c184a4e..9c984cc 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -125,7 +125,7 @@ struct inode *afs_iget(struct super_block *sb, struct key *key,
 	struct inode *inode;
 	int ret;
 
-	_enter(",{%u,%u,%u},,", fid->vid, fid->vnode, fid->unique);
+	_enter(",{%x:%u.%u},,", fid->vid, fid->vnode, fid->unique);
 
 	as = sb->s_fs_info;
 	data.volume = as->volume;
@@ -204,6 +204,19 @@ bad_inode:
 }
 
 /*
+ * mark the data attached to an inode as obsolete due to a write on the server
+ * - might also want to ditch all the outstanding writes and dirty pages
+ */
+void afs_zap_data(struct afs_vnode *vnode)
+{
+	kenter("zap data {%x:%u}", vnode->fid.vid, vnode->fid.vnode);
+
+	/* nuke all the non-dirty pages that aren't locked, mapped or being
+	 * written back */
+	invalidate_remote_inode(&vnode->vfs_inode);
+}
+
+/*
  * validate a vnode/inode
  * - there are several things we need to check
  *   - parent dir data changes (rm, rmdir, rename, mkdir, create, link,
@@ -258,10 +271,8 @@ int afs_validate(struct afs_vnode *vnode, struct key *key)
 
 	/* if the vnode's data version number changed then its contents are
 	 * different */
-	if (test_and_clear_bit(AFS_VNODE_ZAP_DATA, &vnode->flags)) {
-		_debug("zap data {%x:%d}", vnode->fid.vid, vnode->fid.vnode);
-		invalidate_remote_inode(&vnode->vfs_inode);
-	}
+	if (test_and_clear_bit(AFS_VNODE_ZAP_DATA, &vnode->flags))
+		afs_zap_data(vnode);
 
 	clear_bit(AFS_VNODE_MODIFIED, &vnode->flags);
 	mutex_unlock(&vnode->validate_lock);
@@ -278,7 +289,7 @@ error_unlock:
 /*
  * read the attributes of an inode
  */
-int afs_inode_getattr(struct vfsmount *mnt, struct dentry *dentry,
+int afs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 		      struct kstat *stat)
 {
 	struct inode *inode;
@@ -301,7 +312,7 @@ void afs_clear_inode(struct inode *inode)
 
 	vnode = AFS_FS_I(inode);
 
-	_enter("{%x:%d.%d} v=%u x=%u t=%u }",
+	_enter("{%x:%u.%d} v=%u x=%u t=%u }",
 	       vnode->fid.vid,
 	       vnode->fid.vnode,
 	       vnode->fid.unique,
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 671239e..881b7dc 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -433,10 +433,6 @@ extern const struct file_operations afs_file_operations;
 extern int afs_open(struct inode *, struct file *);
 extern int afs_release(struct inode *, struct file *);
 
-#ifdef AFS_CACHING_SUPPORT
-extern int afs_cache_get_page_cookie(struct page *, struct cachefs_page **);
-#endif
-
 /*
  * fsclient.c
  */
@@ -474,10 +470,9 @@ extern int afs_fs_rename(struct afs_server *, struct key *,
 extern struct inode *afs_iget(struct super_block *, struct key *,
 			      struct afs_fid *, struct afs_file_status *,
 			      struct afs_callback *);
+extern void afs_zap_data(struct afs_vnode *);
 extern int afs_validate(struct afs_vnode *, struct key *);
-extern int afs_inode_getattr(struct vfsmount *, struct dentry *,
-			     struct kstat *);
-extern void afs_zap_permits(struct rcu_head *);
+extern int afs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
 extern void afs_clear_inode(struct inode *);
 
 /*
@@ -533,6 +528,7 @@ extern int afs_extract_data(struct afs_call *, struct sk_buff *, bool, void *,
  */
 extern void afs_clear_permits(struct afs_vnode *);
 extern void afs_cache_permit(struct afs_vnode *, struct key *, long);
+extern void afs_zap_permits(struct rcu_head *);
 extern struct key *afs_request_key(struct afs_cell *);
 extern struct key *afs_request_key_nd(struct afs_cell *, struct nameidata *);
 extern int afs_permission(struct inode *, int, struct nameidata *);
@@ -727,6 +723,21 @@ do {									\
 	}								\
 } while(0)
 
+#define ASSERTRANGE(L, OP1, N, OP2, H)					\
+do {									\
+	if (unlikely(!((L) OP1 (N)) || !((N) OP2 (H)))) {		\
+		printk(KERN_ERR "\n");					\
+		printk(KERN_ERR "AFS: Assertion failed\n");		\
+		printk(KERN_ERR "%lu "#OP1" %lu "#OP2" %lu is false\n",	\
+		       (unsigned long)(L), (unsigned long)(N),		\
+		       (unsigned long)(H));				\
+		printk(KERN_ERR "0x%lx "#OP1" 0x%lx "#OP2" 0x%lx is false\n", \
+		       (unsigned long)(L), (unsigned long)(N),		\
+		       (unsigned long)(H));				\
+		BUG();							\
+	}								\
+} while(0)
+
 #define ASSERTIF(C, X)						\
 do {								\
 	if (unlikely((C) && !(X))) {				\
@@ -759,6 +770,10 @@ do {						\
 do {						\
 } while(0)
 
+#define ASSERTRANGE(L, OP1, N, OP2, H)		\
+do {						\
+} while(0)
+
 #define ASSERTIF(C, X)				\
 do {						\
 } while(0)
diff --git a/fs/afs/main.c b/fs/afs/main.c
index 80ec6fd..f1f71ff 100644
--- a/fs/afs/main.c
+++ b/fs/afs/main.c
@@ -149,6 +149,7 @@ error_cache:
 	afs_vlocation_purge();
 	afs_cell_purge();
 	afs_proc_cleanup();
+	rcu_barrier();
 	printk(KERN_ERR "kAFS: failed to register: %d\n", ret);
 	return ret;
 }
@@ -176,6 +177,7 @@ static void __exit afs_exit(void)
 	cachefs_unregister_netfs(&afs_cache_netfs);
 #endif
 	afs_proc_cleanup();
+	rcu_barrier();
 }
 
 module_exit(afs_exit);
diff --git a/fs/afs/misc.c b/fs/afs/misc.c
index cdb9792..d1a889c 100644
--- a/fs/afs/misc.c
+++ b/fs/afs/misc.c
@@ -22,6 +22,7 @@ int afs_abort_to_error(u32 abort_code)
 {
 	switch (abort_code) {
 	case 13:		return -EACCES;
+	case 27:		return -EFBIG;
 	case 30:		return -EROFS;
 	case VSALVAGE:		return -EIO;
 	case VNOVNODE:		return -ENOENT;
diff --git a/fs/afs/mntpt.c b/fs/afs/mntpt.c
index 034fcfd..a3684dc 100644
--- a/fs/afs/mntpt.c
+++ b/fs/afs/mntpt.c
@@ -36,7 +36,7 @@ const struct inode_operations afs_mntpt_inode_operations = {
 	.lookup		= afs_mntpt_lookup,
 	.follow_link	= afs_mntpt_follow_link,
 	.readlink	= page_readlink,
-	.getattr	= afs_inode_getattr,
+	.getattr	= afs_getattr,
 };
 
 static LIST_HEAD(afs_vfsmounts);
@@ -58,7 +58,8 @@ int afs_mntpt_check_symlink(struct afs_vnode *vnode, struct key *key)
 	char *buf;
 	int ret;
 
-	_enter("{%u,%u}", vnode->fid.vnode, vnode->fid.unique);
+	_enter("{%x:%u,%u}",
+	       vnode->fid.vid, vnode->fid.vnode, vnode->fid.unique);
 
 	/* read the contents of the symlink into the pagecache */
 	page = read_mapping_page(AFS_VNODE_TO_I(vnode)->i_mapping, 0, &file);
diff --git a/fs/afs/security.c b/fs/afs/security.c
index 006c952..c728269 100644
--- a/fs/afs/security.c
+++ b/fs/afs/security.c
@@ -164,7 +164,7 @@ void afs_clear_permits(struct afs_vnode *vnode)
 {
 	struct afs_permits *permits;
 
-	_enter("{%x}", vnode->fid.vnode);
+	_enter("{%x:%u}", vnode->fid.vid, vnode->fid.vnode);
 
 	mutex_lock(&vnode->permits_lock);
 	permits = vnode->permits;
@@ -187,7 +187,8 @@ void afs_cache_permit(struct afs_vnode *vnode, struct key *key, long acl_order)
 	struct afs_vnode *auth_vnode;
 	int count, loop;
 
-	_enter("{%x},%x,%lx", vnode->fid.vnode, key_serial(key), acl_order);
+	_enter("{%x:%u},%x,%lx",
+	       vnode->fid.vid, vnode->fid.vnode, key_serial(key), acl_order);
 
 	auth_vnode = afs_get_auth_inode(vnode, key);
 	if (IS_ERR(auth_vnode)) {
@@ -275,7 +276,8 @@ static int afs_check_permit(struct afs_vnode *vnode, struct key *key,
 	bool valid;
 	int loop, ret;
 
-	_enter("");
+	_enter("{%x:%u},%x",
+	       vnode->fid.vid, vnode->fid.vnode, key_serial(key));
 
 	auth_vnode = afs_get_auth_inode(vnode, key);
 	if (IS_ERR(auth_vnode)) {
@@ -323,9 +325,9 @@ static int afs_check_permit(struct afs_vnode *vnode, struct key *key,
 			_leave(" = %d", ret);
 			return ret;
 		}
+		*_access = vnode->status.caller_access;
 	}
 
-	*_access = vnode->status.caller_access;
 	iput(&auth_vnode->vfs_inode);
 	_leave(" = 0 [access %x]", *_access);
 	return 0;
@@ -343,7 +345,7 @@ int afs_permission(struct inode *inode, int mask, struct nameidata *nd)
 	struct key *key;
 	int ret;
 
-	_enter("{{%x:%x},%lx},%x,",
+	_enter("{{%x:%u},%lx},%x,",
 	       vnode->fid.vid, vnode->fid.vnode, vnode->flags, mask);
 
 	key = afs_request_key_nd(vnode->volume->cell, nd);
diff --git a/fs/afs/server.c b/fs/afs/server.c
index 96bb23b..231ae41 100644
--- a/fs/afs/server.c
+++ b/fs/afs/server.c
@@ -252,6 +252,9 @@ static void afs_destroy_server(struct afs_server *server)
 {
 	_enter("%p", server);
 
+	ASSERTIF(server->cb_break_head != server->cb_break_tail,
+		 delayed_work_pending(&server->cb_break_work));
+
 	ASSERTCMP(server->fs_vnodes.rb_node, ==, NULL);
 	ASSERTCMP(server->cb_promises.rb_node, ==, NULL);
 	ASSERTCMP(server->cb_break_head, ==, server->cb_break_tail);
diff --git a/fs/afs/vnode.c b/fs/afs/vnode.c
index a1904ab..0e37f99 100644
--- a/fs/afs/vnode.c
+++ b/fs/afs/vnode.c
@@ -261,7 +261,7 @@ int afs_vnode_fetch_status(struct afs_vnode *vnode,
 
 	DECLARE_WAITQUEUE(myself, current);
 
-	_enter("%s,{%u,%u,%u}",
+	_enter("%s,{%x:%u.%u}",
 	       vnode->volume->vlocation->vldb.name,
 	       vnode->fid.vid, vnode->fid.vnode, vnode->fid.unique);
 
@@ -389,7 +389,7 @@ int afs_vnode_fetch_data(struct afs_vnode *vnode, struct key *key,
 	struct afs_server *server;
 	int ret;
 
-	_enter("%s{%u,%u,%u},%x,,,",
+	_enter("%s{%x:%u.%u},%x,,,",
 	       vnode->volume->vlocation->vldb.name,
 	       vnode->fid.vid,
 	       vnode->fid.vnode,
@@ -446,7 +446,7 @@ int afs_vnode_create(struct afs_vnode *vnode, struct key *key,
 	struct afs_server *server;
 	int ret;
 
-	_enter("%s{%u,%u,%u},%x,%s,,",
+	_enter("%s{%x:%u.%u},%x,%s,,",
 	       vnode->volume->vlocation->vldb.name,
 	       vnode->fid.vid,
 	       vnode->fid.vnode,
@@ -502,7 +502,7 @@ int afs_vnode_remove(struct afs_vnode *vnode, struct key *key, const char *name,
 	struct afs_server *server;
 	int ret;
 
-	_enter("%s{%u,%u,%u},%x,%s",
+	_enter("%s{%x:%u.%u},%x,%s",
 	       vnode->volume->vlocation->vldb.name,
 	       vnode->fid.vid,
 	       vnode->fid.vnode,
@@ -557,7 +557,7 @@ extern int afs_vnode_link(struct afs_vnode *dvnode, struct afs_vnode *vnode,
 	struct afs_server *server;
 	int ret;
 
-	_enter("%s{%u,%u,%u},%s{%u,%u,%u},%x,%s",
+	_enter("%s{%x:%u.%u},%s{%x:%u.%u},%x,%s",
 	       dvnode->volume->vlocation->vldb.name,
 	       dvnode->fid.vid,
 	       dvnode->fid.vnode,
@@ -628,7 +628,7 @@ int afs_vnode_symlink(struct afs_vnode *vnode, struct key *key,
 	struct afs_server *server;
 	int ret;
 
-	_enter("%s{%u,%u,%u},%x,%s,%s,,,",
+	_enter("%s{%x:%u.%u},%x,%s,%s,,,",
 	       vnode->volume->vlocation->vldb.name,
 	       vnode->fid.vid,
 	       vnode->fid.vnode,
@@ -687,7 +687,7 @@ int afs_vnode_rename(struct afs_vnode *orig_dvnode,
 	struct afs_server *server;
 	int ret;
 
-	_enter("%s{%u,%u,%u},%s{%u,%u,%u},%x,%s,%s",
+	_enter("%s{%x:%u.%u},%s{%u,%u,%u},%x,%s,%s",
 	       orig_dvnode->volume->vlocation->vldb.name,
 	       orig_dvnode->fid.vid,
 	       orig_dvnode->fid.vnode,
