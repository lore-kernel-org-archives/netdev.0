From: David Howells <dhowells@redhat.com>
Subject: [PATCH 8/8] AFS: Add security support
Date: Wed, 11 Apr 2007 20:10:37 +0100
Message-ID: <20070411191037.15499.67852.stgit@warthog.cambridge.redhat.com>
References: <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add security support to the AFS filesystem.  Kerberos IV tickets are added as
RxRPC keys are added to the session keyring with the klog program.  open() and
other VFS operations then find this ticket with request_key() and either use
it immediately (eg: mkdir, unlink) or attach it to a file descriptor (open).

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 fs/afs/AFS.h       |   27 +++-
 fs/afs/Makefile    |    1 
 fs/afs/callback.c  |    5 +
 fs/afs/cell.c      |   98 ++++++++++---
 fs/afs/cmservice.c |    3 
 fs/afs/dir.c       |   51 +++++--
 fs/afs/file.c      |   60 +++++++-
 fs/afs/fsclient.c  |    9 +
 fs/afs/inode.c     |   21 ++-
 fs/afs/internal.h  |  107 +++++++++++---
 fs/afs/mntpt.c     |   12 +-
 fs/afs/rxrpc.c     |  137 ++++++++++++++----
 fs/afs/security.c  |  400 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/afs/super.c     |  142 ++++++++++++++++--
 fs/afs/vlclient.c  |    6 +
 fs/afs/vlocation.c |   26 ++-
 fs/afs/vnode.c     |   25 ++-
 fs/afs/volume.c    |  109 +++-----------
 18 files changed, 1001 insertions(+), 238 deletions(-)

diff --git a/fs/afs/AFS.h b/fs/afs/AFS.h
index 0362e11..3f255d6 100644
--- a/fs/afs/AFS.h
+++ b/fs/afs/AFS.h
@@ -14,6 +14,9 @@
 
 #include <linux/in.h>
 
+#define AFS_MAXCELLNAME	64		/* maximum length of a cell name */
+#define AFS_MAXVOLNAME	64		/* maximum length of a volume name */
+
 typedef unsigned			afs_volid_t;
 typedef unsigned			afs_vnodeid_t;
 typedef unsigned long long		afs_dataversion_t;
@@ -75,6 +78,26 @@ struct afs_volume_info {
 };
 
 /*
+ * AFS security ACE access mask
+ */
+typedef u32 afs_access_t;
+#define AFS_ACE_READ		0x00000001U	/* - permission to read a file/dir */
+#define AFS_ACE_WRITE		0x00000002U	/* - permission to write/chmod a file */
+#define AFS_ACE_INSERT		0x00000004U	/* - permission to create dirent in a dir */
+#define AFS_ACE_LOOKUP		0x00000008U	/* - permission to lookup a file/dir in a dir */
+#define AFS_ACE_DELETE		0x00000010U	/* - permission to delete a dirent from a dir */
+#define AFS_ACE_LOCK		0x00000020U	/* - permission to lock a file */
+#define AFS_ACE_ADMINISTER	0x00000040U	/* - permission to change ACL */
+#define AFS_ACE_USER_A		0x01000000U	/* - 'A' user-defined permission */
+#define AFS_ACE_USER_B		0x02000000U	/* - 'B' user-defined permission */
+#define AFS_ACE_USER_C		0x04000000U	/* - 'C' user-defined permission */
+#define AFS_ACE_USER_D		0x08000000U	/* - 'D' user-defined permission */
+#define AFS_ACE_USER_E		0x10000000U	/* - 'E' user-defined permission */
+#define AFS_ACE_USER_F		0x20000000U	/* - 'F' user-defined permission */
+#define AFS_ACE_USER_G		0x40000000U	/* - 'G' user-defined permission */
+#define AFS_ACE_USER_H		0x80000000U	/* - 'H' user-defined permission */
+
+/*
  * AFS file status information
  */
 struct afs_file_status {
@@ -87,8 +110,8 @@ struct afs_file_status {
 	afs_dataversion_t	data_version;	/* current data version */
 	unsigned		author;		/* author ID */
 	unsigned		owner;		/* owner ID */
-	unsigned		caller_access;	/* access rights for authenticated caller */
-	unsigned		anon_access;	/* access rights for unauthenticated caller */
+	afs_access_t		caller_access;	/* access rights for authenticated caller */
+	afs_access_t		anon_access;	/* access rights for unauthenticated caller */
 	umode_t			mode;		/* UNIX mode */
 	struct afs_fid		parent;		/* parent file ID */
 	time_t			mtime_client;	/* last time client changed data */
diff --git a/fs/afs/Makefile b/fs/afs/Makefile
index 66bdc21..cca198b 100644
--- a/fs/afs/Makefile
+++ b/fs/afs/Makefile
@@ -15,6 +15,7 @@ kafs-objs := \
 	mntpt.o \
 	proc.o \
 	rxrpc.o \
+	security.o \
 	server.o \
 	super.o \
 	vlclient.o \
diff --git a/fs/afs/callback.c b/fs/afs/callback.c
index 1533b49..4dedb76 100644
--- a/fs/afs/callback.c
+++ b/fs/afs/callback.c
@@ -72,7 +72,10 @@ void afs_broken_callback_work(struct work_struct *work)
 		return; /* someone else is dealing with it */
 
 	if (test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags)) {
-		if (afs_vnode_fetch_status(vnode) < 0)
+		if (S_ISDIR(vnode->vfs_inode.i_mode))
+			afs_clear_permits(vnode);
+
+		if (afs_vnode_fetch_status(vnode, NULL, NULL) < 0)
 			goto out;
 
 		if (test_bit(AFS_VNODE_DELETED, &vnode->flags))
diff --git a/fs/afs/cell.c b/fs/afs/cell.c
index 733c602..9b1311a 100644
--- a/fs/afs/cell.c
+++ b/fs/afs/cell.c
@@ -11,6 +11,9 @@
 
 #include <linux/module.h>
 #include <linux/slab.h>
+#include <linux/key.h>
+#include <linux/ctype.h>
+#include <keys/rxrpc-type.h>
 #include "internal.h"
 
 DECLARE_RWSEM(afs_proc_cells_sem);
@@ -23,45 +26,43 @@ static DECLARE_WAIT_QUEUE_HEAD(afs_cells_freeable_wq);
 static struct afs_cell *afs_cell_root;
 
 /*
- * create a cell record
- * - "name" is the name of the cell
- * - "vllist" is a colon separated list of IP addresses in "a.b.c.d" format
+ * allocate a cell record and fill in its name, VL server address list and
+ * allocate an anonymous key
  */
-struct afs_cell *afs_cell_create(const char *name, char *vllist)
+static struct afs_cell *afs_cell_alloc(const char *name, char *vllist)
 {
 	struct afs_cell *cell;
-	char *next;
+	size_t namelen;
+	char keyname[4 + AFS_MAXCELLNAME + 1], *cp, *dp, *next;
 	int ret;
 
 	_enter("%s,%s", name, vllist);
 
 	BUG_ON(!name); /* TODO: want to look up "this cell" in the cache */
 
+	namelen = strlen(name);
+	if (namelen > AFS_MAXCELLNAME)
+		return ERR_PTR(-ENAMETOOLONG);
+
 	/* allocate and initialise a cell record */
-	cell = kmalloc(sizeof(struct afs_cell) + strlen(name) + 1, GFP_KERNEL);
+	cell = kzalloc(sizeof(struct afs_cell) + namelen + 1, GFP_KERNEL);
 	if (!cell) {
 		_leave(" = -ENOMEM");
 		return ERR_PTR(-ENOMEM);
 	}
 
-	down_write(&afs_cells_sem);
+	memcpy(cell->name, name, namelen);
+	cell->name[namelen] = 0;
 
-	memset(cell, 0, sizeof(struct afs_cell));
 	atomic_set(&cell->usage, 1);
-
 	INIT_LIST_HEAD(&cell->link);
-
 	rwlock_init(&cell->servers_lock);
 	INIT_LIST_HEAD(&cell->servers);
-
 	init_rwsem(&cell->vl_sem);
 	INIT_LIST_HEAD(&cell->vl_list);
 	spin_lock_init(&cell->vl_lock);
 
-	strcpy(cell->name, name);
-
 	/* fill in the VL server list from the rest of the string */
-	ret = -EINVAL;
 	do {
 		unsigned a, b, c, d;
 
@@ -70,18 +71,73 @@ struct afs_cell *afs_cell_create(const char *name, char *vllist)
 			*next++ = 0;
 
 		if (sscanf(vllist, "%u.%u.%u.%u", &a, &b, &c, &d) != 4)
-			goto badaddr;
+			goto bad_address;
 
 		if (a > 255 || b > 255 || c > 255 || d > 255)
-			goto badaddr;
+			goto bad_address;
 
 		cell->vl_addrs[cell->vl_naddrs++].s_addr =
 			htonl((a << 24) | (b << 16) | (c << 8) | d);
 
-		if (cell->vl_naddrs >= AFS_CELL_MAX_ADDRS)
-			break;
+	} while (cell->vl_naddrs < AFS_CELL_MAX_ADDRS && (vllist = next));
+
+	/* create a key to represent an anonymous user */
+	memcpy(keyname, "afs@", 4);
+	dp = keyname + 4;
+	cp = cell->name;
+	do {
+		*dp++ = toupper(*cp);
+	} while (*cp++);
+	cell->anonymous_key = key_alloc(&key_type_rxrpc, keyname, 0, 0, current,
+					KEY_POS_SEARCH, KEY_ALLOC_NOT_IN_QUOTA);
+	if (IS_ERR(cell->anonymous_key)) {
+		_debug("no key");
+		ret = PTR_ERR(cell->anonymous_key);
+		goto error;
+	}
+
+	ret = key_instantiate_and_link(cell->anonymous_key, NULL, 0,
+				       NULL, NULL);
+	if (ret < 0) {
+		_debug("instantiate failed");
+		goto error;
+	}
+
+	_debug("anon key %p{%x}",
+	       cell->anonymous_key, key_serial(cell->anonymous_key));
+
+	_leave(" = %p", cell);
+	return cell;
+
+bad_address:
+	printk(KERN_ERR "kAFS: bad VL server IP address\n");
+	ret = -EINVAL;
+error:
+	key_put(cell->anonymous_key);
+	kfree(cell);
+	_leave(" = %d", ret);
+	return ERR_PTR(ret);
+}
 
-	} while ((vllist = next));
+/*
+ * create a cell record
+ * - "name" is the name of the cell
+ * - "vllist" is a colon separated list of IP addresses in "a.b.c.d" format
+ */
+struct afs_cell *afs_cell_create(const char *name, char *vllist)
+{
+	struct afs_cell *cell;
+	int ret;
+
+	_enter("%s,%s", name, vllist);
+
+	cell = afs_cell_alloc(name, vllist);
+	if (IS_ERR(cell)) {
+		_leave(" = %ld", PTR_ERR(cell));
+		return cell;
+	}
+
+	down_write(&afs_cells_sem);
 
 	/* add a proc directory for this cell */
 	ret = afs_proc_cell_setup(cell);
@@ -109,10 +165,9 @@ struct afs_cell *afs_cell_create(const char *name, char *vllist)
 	_leave(" = %p", cell);
 	return cell;
 
-badaddr:
-	printk(KERN_ERR "kAFS: bad VL server IP address\n");
 error:
 	up_write(&afs_cells_sem);
+	key_put(cell->anonymous_key);
 	kfree(cell);
 	_leave(" = %d", ret);
 	return ERR_PTR(ret);
@@ -301,6 +356,7 @@ static void afs_cell_destroy(struct afs_cell *cell)
 	cachefs_relinquish_cookie(cell->cache, 0);
 #endif
 
+	key_put(cell->anonymous_key);
 	kfree(cell);
 
 	_leave(" [destroyed]");
diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index 0b6665e..9cb3ac5 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -28,6 +28,7 @@ static void afs_cm_destructor(struct afs_call *);
  * CB.CallBack operation type
  */
 static const struct afs_call_type afs_SRXCBCallBack = {
+	.name		= "CB.CallBack",
 	.deliver	= afs_deliver_cb_callback,
 	.abort_to_error	= afs_abort_to_error,
 	.destructor	= afs_cm_destructor,
@@ -37,6 +38,7 @@ static const struct afs_call_type afs_SRXCBCallBack = {
  * CB.InitCallBackState operation type
  */
 static const struct afs_call_type afs_SRXCBInitCallBackState = {
+	.name		= "CB.InitCallBackState",
 	.deliver	= afs_deliver_cb_init_call_back_state,
 	.abort_to_error	= afs_abort_to_error,
 	.destructor	= afs_cm_destructor,
@@ -46,6 +48,7 @@ static const struct afs_call_type afs_SRXCBInitCallBackState = {
  * CB.Probe operation type
  */
 static const struct afs_call_type afs_SRXCBProbe = {
+	.name		= "CB.Probe",
 	.deliver	= afs_deliver_cb_probe,
 	.abort_to_error	= afs_abort_to_error,
 	.destructor	= afs_cm_destructor,
diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index d7697f6..654f225 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -15,6 +15,7 @@
 #include <linux/slab.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
+#include <linux/ctype.h>
 #include "internal.h"
 
 static struct dentry *afs_dir_lookup(struct inode *dir, struct dentry *dentry,
@@ -28,11 +29,13 @@ static int afs_dir_lookup_filldir(void *_cookie, const char *name, int nlen,
 
 const struct file_operations afs_dir_file_operations = {
 	.open		= afs_dir_open,
+	.release	= afs_release,
 	.readdir	= afs_dir_readdir,
 };
 
 const struct inode_operations afs_dir_inode_operations = {
 	.lookup		= afs_dir_lookup,
+	.permission	= afs_permission,
 	.getattr	= afs_inode_getattr,
 #if 0 /* TODO */
 	.create		= afs_dir_create,
@@ -169,13 +172,17 @@ static inline void afs_dir_put_page(struct page *page)
 /*
  * get a page into the pagecache
  */
-static struct page *afs_dir_get_page(struct inode *dir, unsigned long index)
+static struct page *afs_dir_get_page(struct inode *dir, unsigned long index,
+				     struct key *key)
 {
 	struct page *page;
+	struct file file = {
+		.private_data = key,
+	};
 
 	_enter("{%lu},%lu", dir->i_ino, index);
 
-	page = read_mapping_page(dir->i_mapping, index, NULL);
+	page = read_mapping_page(dir->i_mapping, index, &file);
 	if (!IS_ERR(page)) {
 		wait_on_page_locked(page);
 		kmap(page);
@@ -207,8 +214,7 @@ static int afs_dir_open(struct inode *inode, struct file *file)
 	if (test_bit(AFS_VNODE_DELETED, &AFS_FS_I(inode)->flags))
 		return -ENOENT;
 
-	_leave(" = 0");
-	return 0;
+	return afs_open(inode, file);
 }
 
 /*
@@ -311,7 +317,7 @@ static int afs_dir_iterate_block(unsigned *fpos,
  * iterate through the data blob that lists the contents of an AFS directory
  */
 static int afs_dir_iterate(struct inode *dir, unsigned *fpos, void *cookie,
-			   filldir_t filldir)
+			   filldir_t filldir, struct key *key)
 {
 	union afs_dir_block *dblock;
 	struct afs_dir_page *dbuf;
@@ -336,7 +342,7 @@ static int afs_dir_iterate(struct inode *dir, unsigned *fpos, void *cookie,
 		blkoff = *fpos & ~(sizeof(union afs_dir_block) - 1);
 
 		/* fetch the appropriate page from the directory */
-		page = afs_dir_get_page(dir, blkoff / PAGE_SIZE);
+		page = afs_dir_get_page(dir, blkoff / PAGE_SIZE, key);
 		if (IS_ERR(page)) {
 			ret = PTR_ERR(page);
 			break;
@@ -381,9 +387,11 @@ static int afs_dir_readdir(struct file *file, void *cookie, filldir_t filldir)
 	_enter("{%Ld,{%lu}}",
 	       file->f_pos, file->f_path.dentry->d_inode->i_ino);
 
+	ASSERT(file->private_data != NULL);
+
 	fpos = file->f_pos;
 	ret = afs_dir_iterate(file->f_path.dentry->d_inode, &fpos,
-			      cookie, filldir);
+			      cookie, filldir, file->private_data);
 	file->f_pos = fpos;
 
 	_leave(" = %d", ret);
@@ -424,7 +432,7 @@ static int afs_dir_lookup_filldir(void *_cookie, const char *name, int nlen,
  * do a lookup in a directory
  */
 static int afs_do_lookup(struct inode *dir, struct dentry *dentry,
-			 struct afs_fid *fid)
+			 struct afs_fid *fid, struct key *key)
 {
 	struct afs_dir_lookup_cookie cookie;
 	struct afs_super_info *as;
@@ -442,7 +450,8 @@ static int afs_do_lookup(struct inode *dir, struct dentry *dentry,
 	cookie.found	= 0;
 
 	fpos = 0;
-	ret = afs_dir_iterate(dir, &fpos, &cookie, afs_dir_lookup_filldir);
+	ret = afs_dir_iterate(dir, &fpos, &cookie, afs_dir_lookup_filldir,
+			      key);
 	if (ret < 0) {
 		_leave(" = %d [iter]", ret);
 		return ret;
@@ -468,6 +477,7 @@ static struct dentry *afs_dir_lookup(struct inode *dir, struct dentry *dentry,
 	struct afs_vnode *vnode;
 	struct afs_fid fid;
 	struct inode *inode;
+	struct key *key;
 	int ret;
 
 	_enter("{%lu},%p{%s}", dir->i_ino, dentry, dentry->d_name.name);
@@ -483,14 +493,22 @@ static struct dentry *afs_dir_lookup(struct inode *dir, struct dentry *dentry,
 		return ERR_PTR(-ESTALE);
 	}
 
-	ret = afs_do_lookup(dir, dentry, &fid);
+	key = afs_request_key_nd(vnode->volume->cell, nd);
+	if (IS_ERR(key)) {
+		_leave(" = %ld [key]", PTR_ERR(key));
+		return ERR_PTR(PTR_ERR(key));
+	}
+
+	ret = afs_do_lookup(dir, dentry, &fid, nd->key);
 	if (ret < 0) {
+		key_put(key);
 		_leave(" = %d [do]", ret);
 		return ERR_PTR(ret);
 	}
 
 	/* instantiate the dentry */
-	inode = afs_iget(dir->i_sb, &fid);
+	inode = afs_iget(dir->i_sb, nd->key, &fid);
+	key_put(key);
 	if (IS_ERR(inode)) {
 		_leave(" = %ld", PTR_ERR(inode));
 		return ERR_PTR(PTR_ERR(inode));
@@ -559,6 +577,7 @@ static int afs_d_revalidate(struct dentry *dentry, struct nameidata *nd)
 	struct afs_fid fid;
 	struct dentry *parent;
 	struct inode *inode, *dir;
+	struct key *key;
 	int ret;
 
 	vnode = AFS_FS_I(dentry->d_inode);
@@ -566,6 +585,10 @@ static int afs_d_revalidate(struct dentry *dentry, struct nameidata *nd)
 	_enter("{sb=%p n=%s fl=%lx},",
 	       dentry->d_sb, dentry->d_name.name, vnode->flags);
 
+	key = afs_request_key_nd(vnode->volume->cell, nd);
+	if (IS_ERR(key))
+		key = NULL;
+
 	/* lock down the parent dentry so we can peer at it */
 	parent = dget_parent(dentry);
 
@@ -595,7 +618,7 @@ static int afs_d_revalidate(struct dentry *dentry, struct nameidata *nd)
 		_debug("dir modified");
 
 		/* search the directory for this vnode */
-		ret = afs_do_lookup(dir, dentry, &fid);
+		ret = afs_do_lookup(dir, dentry, &fid, key);
 		if (ret == -ENOENT) {
 			_debug("%s: dirent not found", dentry->d_name.name);
 			goto not_found;
@@ -637,7 +660,7 @@ static int afs_d_revalidate(struct dentry *dentry, struct nameidata *nd)
 	    test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags)) {
 		_debug("%s: changed", dentry->d_name.name);
 		set_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
-		if (afs_vnode_fetch_status(vnode) < 0) {
+		if (afs_vnode_fetch_status(vnode, NULL, key) < 0) {
 			mutex_unlock(&vnode->cb_broken_lock);
 			goto out_bad;
 		}
@@ -667,6 +690,7 @@ static int afs_d_revalidate(struct dentry *dentry, struct nameidata *nd)
 
 out_valid:
 	dput(parent);
+	key_put(key);
 	_leave(" = 1 [valid]");
 	return 1;
 
@@ -688,6 +712,7 @@ out_bad:
 	shrink_dcache_parent(dentry);
 	d_drop(dentry);
 	dput(parent);
+	key_put(key);
 
 	_leave(" = 0 [bad]");
 	return 0;
diff --git a/fs/afs/file.c b/fs/afs/file.c
index 6990327..101bbb8 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -17,17 +17,23 @@
 #include <linux/pagemap.h>
 #include "internal.h"
 
-#if 0
-static int afs_file_open(struct inode *inode, struct file *file);
-static int afs_file_release(struct inode *inode, struct file *file);
-#endif
-
 static int afs_file_readpage(struct file *file, struct page *page);
 static void afs_file_invalidatepage(struct page *page, unsigned long offset);
 static int afs_file_releasepage(struct page *page, gfp_t gfp_flags);
 
+const struct file_operations afs_file_operations = {
+	.open		= afs_open,
+	.release	= afs_release,
+	.llseek		= generic_file_llseek,
+	.read		= do_sync_read,
+	.aio_read	= generic_file_aio_read,
+	.mmap		= generic_file_readonly_mmap,
+	.sendfile	= generic_file_sendfile,
+};
+
 const struct inode_operations afs_file_inode_operations = {
 	.getattr	= afs_inode_getattr,
+	.permission	= afs_permission,
 };
 
 const struct address_space_operations afs_fs_aops = {
@@ -38,6 +44,41 @@ const struct address_space_operations afs_fs_aops = {
 };
 
 /*
+ * open an AFS file or directory and attach a key to it
+ */
+int afs_open(struct inode *inode, struct file *file)
+{
+	struct afs_vnode *vnode = AFS_FS_I(inode);
+	struct key *key;
+
+	_enter("{%x:%x},", vnode->fid.vid, vnode->fid.vnode);
+
+	key = afs_request_key(vnode->volume->cell);
+	if (IS_ERR(key)) {
+		_leave(" = %ld [key]", PTR_ERR(key));
+		return PTR_ERR(key);
+	}
+
+	file->private_data = key;
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * release an AFS file or directory and discard its key
+ */
+int afs_release(struct inode *inode, struct file *file)
+{
+	struct afs_vnode *vnode = AFS_FS_I(inode);
+
+	_enter("{%x:%x},", vnode->fid.vid, vnode->fid.vnode);
+
+	key_put(file->private_data);
+	_leave(" = 0");
+	return 0;
+}
+
+/*
  * deal with notification that a page was read from the cache
  */
 #ifdef AFS_CACHING_SUPPORT
@@ -79,13 +120,18 @@ static int afs_file_readpage(struct file *file, struct page *page)
 {
 	struct afs_vnode *vnode;
 	struct inode *inode;
+	struct key *key;
 	size_t len;
 	off_t offset;
 	int ret;
 
 	inode = page->mapping->host;
 
-	_enter("{%lu},{%lu}", inode->i_ino, page->index);
+	ASSERT(file != NULL);
+	key = file->private_data;
+	ASSERT(key != NULL);
+
+	_enter("{%x},{%lu},{%lu}", key_serial(key), inode->i_ino, page->index);
 
 	vnode = AFS_FS_I(inode);
 
@@ -124,7 +170,7 @@ static int afs_file_readpage(struct file *file, struct page *page)
 
 		/* read the contents of the file from the server into the
 		 * page */
-		ret = afs_vnode_fetch_data(vnode, offset, len, page);
+		ret = afs_vnode_fetch_data(vnode, key, offset, len, page);
 		if (ret < 0) {
 			if (ret == -ENOENT) {
 				_debug("got NOENT from server"
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index e2a36f8..8f20f1b 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -148,6 +148,7 @@ static int afs_deliver_fs_fetch_status(struct afs_call *call,
  * FS.FetchStatus operation type
  */
 static const struct afs_call_type afs_RXFSFetchStatus = {
+	.name		= "FS.FetchStatus",
 	.deliver	= afs_deliver_fs_fetch_status,
 	.abort_to_error	= afs_abort_to_error,
 	.destructor	= afs_flat_call_destructor,
@@ -157,6 +158,7 @@ static const struct afs_call_type afs_RXFSFetchStatus = {
  * fetch the status information for a file
  */
 int afs_fs_fetch_file_status(struct afs_server *server,
+			     struct key *key,
 			     struct afs_vnode *vnode,
 			     struct afs_volsync *volsync,
 			     const struct afs_wait_mode *wait_mode)
@@ -164,12 +166,13 @@ int afs_fs_fetch_file_status(struct afs_server *server,
 	struct afs_call *call;
 	__be32 *bp;
 
-	_enter("");
+	_enter(",%x,,,", key_serial(key));
 
 	call = afs_alloc_flat_call(&afs_RXFSFetchStatus, 16, 120);
 	if (!call)
 		return -ENOMEM;
 
+	call->key = key;
 	call->reply = vnode;
 	call->reply2 = volsync;
 	call->service_id = FS_SERVICE;
@@ -279,6 +282,7 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
  * FS.FetchData operation type
  */
 static const struct afs_call_type afs_RXFSFetchData = {
+	.name		= "FS.FetchData",
 	.deliver	= afs_deliver_fs_fetch_data,
 	.abort_to_error	= afs_abort_to_error,
 	.destructor	= afs_flat_call_destructor,
@@ -288,6 +292,7 @@ static const struct afs_call_type afs_RXFSFetchData = {
  * fetch data from a file
  */
 int afs_fs_fetch_data(struct afs_server *server,
+		      struct key *key,
 		      struct afs_vnode *vnode,
 		      off_t offset, size_t length,
 		      struct page *buffer,
@@ -303,6 +308,7 @@ int afs_fs_fetch_data(struct afs_server *server,
 	if (!call)
 		return -ENOMEM;
 
+	call->key = key;
 	call->reply = vnode;
 	call->reply2 = volsync;
 	call->reply3 = buffer;
@@ -338,6 +344,7 @@ static int afs_deliver_fs_give_up_callbacks(struct afs_call *call,
  * FS.GiveUpCallBacks operation type
  */
 static const struct afs_call_type afs_RXFSGiveUpCallBacks = {
+	.name		= "FS.GiveUpCallBacks",
 	.deliver	= afs_deliver_fs_give_up_callbacks,
 	.abort_to_error	= afs_abort_to_error,
 	.destructor	= afs_flat_call_destructor,
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 1886331..2273362 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -29,7 +29,7 @@ struct afs_iget_data {
 /*
  * map the AFS file status to the inode member variables
  */
-static int afs_inode_map_status(struct afs_vnode *vnode)
+static int afs_inode_map_status(struct afs_vnode *vnode, struct key *key)
 {
 	struct inode *inode = AFS_VNODE_TO_I(vnode);
 
@@ -44,7 +44,7 @@ static int afs_inode_map_status(struct afs_vnode *vnode)
 	case AFS_FTYPE_FILE:
 		inode->i_mode	= S_IFREG | vnode->status.mode;
 		inode->i_op	= &afs_file_inode_operations;
-		inode->i_fop	= &generic_ro_fops;
+		inode->i_fop	= &afs_file_operations;
 		break;
 	case AFS_FTYPE_DIR:
 		inode->i_mode	= S_IFDIR | vnode->status.mode;
@@ -73,7 +73,7 @@ static int afs_inode_map_status(struct afs_vnode *vnode)
 
 	/* check to see whether a symbolic link is really a mountpoint */
 	if (vnode->status.type == AFS_FTYPE_SYMLINK) {
-		afs_mntpt_check_symlink(vnode);
+		afs_mntpt_check_symlink(vnode, key);
 
 		if (test_bit(AFS_VNODE_MOUNTPOINT, &vnode->flags)) {
 			inode->i_mode	= S_IFDIR | vnode->status.mode;
@@ -115,7 +115,8 @@ static int afs_iget5_set(struct inode *inode, void *opaque)
 /*
  * inode retrieval
  */
-inline struct inode *afs_iget(struct super_block *sb, struct afs_fid *fid)
+inline struct inode *afs_iget(struct super_block *sb, struct key *key,
+			      struct afs_fid *fid)
 {
 	struct afs_iget_data data = { .fid = *fid };
 	struct afs_super_info *as;
@@ -157,10 +158,10 @@ inline struct inode *afs_iget(struct super_block *sb, struct afs_fid *fid)
 
 	/* okay... it's a new inode */
 	set_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
-	ret = afs_vnode_fetch_status(vnode);
+	ret = afs_vnode_fetch_status(vnode, NULL, key);
 	if (ret < 0)
 		goto bad_inode;
-	ret = afs_inode_map_status(vnode);
+	ret = afs_inode_map_status(vnode, key);
 	if (ret < 0)
 		goto bad_inode;
 
@@ -201,6 +202,7 @@ int afs_inode_getattr(struct vfsmount *mnt, struct dentry *dentry,
  */
 void afs_clear_inode(struct inode *inode)
 {
+	struct afs_permits *permits;
 	struct afs_vnode *vnode;
 
 	vnode = AFS_FS_I(inode);
@@ -233,5 +235,12 @@ void afs_clear_inode(struct inode *inode)
 	vnode->cache = NULL;
 #endif
 
+	mutex_lock(&vnode->permits_lock);
+	permits = vnode->permits;
+	rcu_assign_pointer(vnode->permits, NULL);
+	mutex_unlock(&vnode->permits_lock);
+	if (permits)
+		call_rcu(&permits->rcu, afs_zap_permits);
+
 	_leave("");
 }
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 12ad524..2a15b13 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -15,6 +15,7 @@
 #include <linux/pagemap.h>
 #include <linux/skbuff.h>
 #include <linux/rxrpc.h>
+#include <linux/key.h>
 #include "AFS.h"
 #include "AFS_VL.h"
 
@@ -32,6 +33,17 @@ typedef enum {
 	AFS_VL_UNCERTAIN,		/* uncertain state (update failed) */
 } __attribute__((packed)) afs_vlocation_state_t;
 
+struct afs_mount_params {
+	bool			rwpath;		/* T if the parent should be considered R/W */
+	bool			force;		/* T to force cell type */
+	afs_voltype_t		type;		/* type of volume requested */
+	int			volnamesz;	/* size of volume name */
+	const char		*volname;	/* name of volume to mount */
+	struct afs_cell		*cell;		/* cell in which to find volume */
+	struct afs_volume	*volume;	/* volume record */
+	struct key		*key;		/* key to use for secure mounting */
+};
+
 /*
  * definition of how to wait for the completion of an operation
  */
@@ -95,6 +107,8 @@ struct afs_call {
 };
 
 struct afs_call_type {
+	const char *name;
+
 	/* deliver request or reply data to an call
 	 * - returning an error will cause the call to be aborted
 	 */
@@ -128,8 +142,8 @@ extern struct file_system_type afs_fs_type;
  * entry in the cached cell catalogue
  */
 struct afs_cache_cell {
-	char			name[64];	/* cell name (padded with NULs) */
-	struct in_addr		vl_servers[15];	/* cached cell VL servers */
+	char		name[AFS_MAXCELLNAME];	/* cell name (padded with NULs) */
+	struct in_addr	vl_servers[15];		/* cached cell VL servers */
 };
 
 /*
@@ -138,6 +152,7 @@ struct afs_cache_cell {
 struct afs_cell {
 	atomic_t		usage;
 	struct list_head	link;		/* main cell list link */
+	struct key		*anonymous_key;	/* anonymous user key for this cell */
 	struct list_head	proc_link;	/* /proc cell list link */
 	struct proc_dir_entry	*proc_dir;	/* /proc dir for this cell */
 #ifdef AFS_CACHING_SUPPORT
@@ -163,7 +178,9 @@ struct afs_cell {
  * entry in the cached volume location catalogue
  */
 struct afs_cache_vlocation {
-	uint8_t			name[64 + 1];	/* volume name (lowercase, padded with NULs) */
+	/* volume name (lowercase, padded with NULs) */
+	uint8_t			name[AFS_MAXVOLNAME + 1];
+
 	uint8_t			nservers;	/* number of entries used in servers[] */
 	uint8_t			vidmask;	/* voltype mask for vid[] */
 	uint8_t			srvtmask[8];	/* voltype masks for servers[] */
@@ -281,7 +298,8 @@ struct afs_vnode {
 #ifdef AFS_CACHING_SUPPORT
 	struct cachefs_cookie	*cache;		/* caching cookie */
 #endif
-
+	struct afs_permits	*permits;	/* cache of permits so far obtained */
+	struct mutex		permits_lock;	/* lock for altering permits list */
 	wait_queue_head_t	update_waitq;	/* status fetch waitqueue */
 	unsigned		update_cnt;	/* number of outstanding ops that will update the
 						 * status */
@@ -296,12 +314,13 @@ struct afs_vnode {
 #define AFS_VNODE_DIR_CHANGED	6		/* set if vnode's parent dir metadata changed */
 #define AFS_VNODE_DIR_MODIFIED	7		/* set if vnode's parent dir data modified */
 
+	long			acl_order;	/* ACL check count (callback break count) */
+
 	/* outstanding callback notification on this file */
 	struct rb_node		server_rb;	/* link in server->fs_vnodes */
 	struct rb_node		cb_promise;	/* link in server->cb_promises */
 	struct work_struct	cb_broken_work;	/* work to be done on callback break */
 	struct mutex		cb_broken_lock;	/* lock against multiple attempts to fix break */
-//	struct list_head	cb_hash_link;	/* link in master callback hash */
 	time_t			cb_expires;	/* time at which callback expires */
 	time_t			cb_expires_at;	/* time used to order cb_promise */
 	unsigned		cb_version;	/* callback version */
@@ -310,6 +329,23 @@ struct afs_vnode {
 	bool			cb_promised;	/* true if promise still holds */
 };
 
+/*
+ * cached security record for one user's attempt to access a vnode
+ */
+struct afs_permit {
+	struct key		*key;		/* RxRPC ticket holding a security context */
+	afs_access_t		access_mask;	/* access mask for this key */
+};
+
+/*
+ * cache of security records from attempts to access a vnode
+ */
+struct afs_permits {
+	struct rcu_head		rcu;		/* disposal procedure */
+	int			count;		/* number of records */
+	struct afs_permit	permits[0];	/* the permits so far examined */
+};
+
 /*****************************************************************************/
 /*
  * callback.c
@@ -352,11 +388,17 @@ extern bool afs_cm_incoming_call(struct afs_call *);
 extern const struct inode_operations afs_dir_inode_operations;
 extern const struct file_operations afs_dir_file_operations;
 
+extern int afs_permission(struct inode *, int, struct nameidata *);
+
 /*
  * file.c
  */
 extern const struct address_space_operations afs_fs_aops;
 extern const struct inode_operations afs_file_inode_operations;
+extern const struct file_operations afs_file_operations;
+
+extern int afs_open(struct inode *, struct file *);
+extern int afs_release(struct inode *, struct file *);
 
 #ifdef AFS_CACHING_SUPPORT
 extern int afs_cache_get_page_cookie(struct page *, struct cachefs_page **);
@@ -365,22 +407,24 @@ extern int afs_cache_get_page_cookie(struct page *, struct cachefs_page **);
 /*
  * fsclient.c
  */
-extern int afs_fs_fetch_file_status(struct afs_server *,
-				    struct afs_vnode *,
-				    struct afs_volsync *,
+extern int afs_fs_fetch_file_status(struct afs_server *, struct key *,
+				    struct afs_vnode *, struct afs_volsync *,
 				    const struct afs_wait_mode *);
 extern int afs_fs_give_up_callbacks(struct afs_server *,
 				    const struct afs_wait_mode *);
-extern int afs_fs_fetch_data(struct afs_server *, struct afs_vnode *, off_t,
-			     size_t, struct page *, struct afs_volsync *,
+extern int afs_fs_fetch_data(struct afs_server *, struct key *,
+			     struct afs_vnode *, off_t, size_t, struct page *,
+			     struct afs_volsync *,
 			     const struct afs_wait_mode *);
 
 /*
  * inode.c
  */
-extern struct inode *afs_iget(struct super_block *, struct afs_fid *);
+extern struct inode *afs_iget(struct super_block *, struct key *,
+			      struct afs_fid *);
 extern int afs_inode_getattr(struct vfsmount *, struct dentry *,
 			     struct kstat *);
+extern void afs_zap_permits(struct rcu_head *);
 extern void afs_clear_inode(struct inode *);
 
 /*
@@ -402,17 +446,11 @@ extern const struct inode_operations afs_mntpt_inode_operations;
 extern const struct file_operations afs_mntpt_file_operations;
 extern unsigned long afs_mntpt_expiry_timeout;
 
-extern int afs_mntpt_check_symlink(struct afs_vnode *);
+extern int afs_mntpt_check_symlink(struct afs_vnode *, struct key *);
 extern void afs_mntpt_kill_timer(void);
 extern void afs_umount_begin(struct vfsmount *, int);
 
 /*
- * super.c
- */
-extern int afs_fs_init(void);
-extern void afs_fs_exit(void);
-
-/*
  * proc.c
  */
 extern int afs_proc_init(void);
@@ -436,6 +474,15 @@ extern int afs_extract_data(struct afs_call *, struct sk_buff *, bool, void *,
 			    size_t);
 
 /*
+ * security.c
+ */
+extern void afs_clear_permits(struct afs_vnode *);
+extern void afs_cache_permit(struct afs_vnode *, struct key *, long);
+extern struct key *afs_request_key(struct afs_cell *);
+extern struct key *afs_request_key_nd(struct afs_cell *, struct nameidata *);
+extern int afs_permission(struct inode *, int, struct nameidata *);
+
+/*
  * server.c
  */
 extern spinlock_t afs_server_peer_lock;
@@ -449,16 +496,23 @@ extern void afs_put_server(struct afs_server *);
 extern void __exit afs_purge_servers(void);
 
 /*
+ * super.c
+ */
+extern int afs_fs_init(void);
+extern void afs_fs_exit(void);
+
+/*
  * vlclient.c
  */
 #ifdef AFS_CACHING_SUPPORT
 extern struct cachefs_index_def afs_vlocation_cache_index_def;
 #endif
 
-extern int afs_vl_get_entry_by_name(struct in_addr *, const char *,
-				    struct afs_cache_vlocation *,
+extern int afs_vl_get_entry_by_name(struct in_addr *, struct key *,
+				    const char *, struct afs_cache_vlocation *,
 				    const struct afs_wait_mode *);
-extern int afs_vl_get_entry_by_id(struct in_addr *, afs_volid_t, afs_voltype_t,
+extern int afs_vl_get_entry_by_id(struct in_addr *, struct key *,
+				  afs_volid_t, afs_voltype_t,
 				  struct afs_cache_vlocation *,
 				  const struct afs_wait_mode *);
 
@@ -469,6 +523,7 @@ extern int afs_vl_get_entry_by_id(struct in_addr *, afs_volid_t, afs_voltype_t,
 
 extern int __init afs_vlocation_update_init(void);
 extern struct afs_vlocation *afs_vlocation_lookup(struct afs_cell *,
+						  struct key *,
 						  const char *, size_t);
 extern void afs_put_vlocation(struct afs_vlocation *);
 extern void __exit afs_vlocation_purge(void);
@@ -492,9 +547,10 @@ static inline struct inode *AFS_VNODE_TO_I(struct afs_vnode *vnode)
 	return &vnode->vfs_inode;
 }
 
-extern int afs_vnode_fetch_status(struct afs_vnode *);
-extern int afs_vnode_fetch_data(struct afs_vnode *vnode, off_t, size_t,
-				struct page *);
+extern int afs_vnode_fetch_status(struct afs_vnode *, struct afs_vnode *,
+				  struct key *);
+extern int afs_vnode_fetch_data(struct afs_vnode *, struct key *,
+				off_t, size_t, struct page *);
 
 /*
  * volume.c
@@ -506,8 +562,7 @@ extern struct cachefs_index_def afs_volume_cache_index_def;
 #define afs_get_volume(V) do { atomic_inc(&(V)->usage); } while(0)
 
 extern void afs_put_volume(struct afs_volume *);
-extern struct afs_volume *afs_volume_lookup(const char *, struct afs_cell *,
-					    int);
+extern struct afs_volume *afs_volume_lookup(struct afs_mount_params *);
 extern struct afs_server *afs_volume_pick_fileserver(struct afs_vnode *);
 extern int afs_volume_release_fileserver(struct afs_vnode *,
 					 struct afs_server *, int);
diff --git a/fs/afs/mntpt.c b/fs/afs/mntpt.c
index 08c11a0..b905ae3 100644
--- a/fs/afs/mntpt.c
+++ b/fs/afs/mntpt.c
@@ -48,8 +48,11 @@ unsigned long afs_mntpt_expiry_timeout = 10 * 60;
  * check a symbolic link to see whether it actually encodes a mountpoint
  * - sets the AFS_VNODE_MOUNTPOINT flag on the vnode appropriately
  */
-int afs_mntpt_check_symlink(struct afs_vnode *vnode)
+int afs_mntpt_check_symlink(struct afs_vnode *vnode, struct key *key)
 {
+	struct file file = {
+		.private_data = key,
+	};
 	struct page *page;
 	size_t size;
 	char *buf;
@@ -58,7 +61,7 @@ int afs_mntpt_check_symlink(struct afs_vnode *vnode)
 	_enter("{%u,%u}", vnode->fid.vnode, vnode->fid.unique);
 
 	/* read the contents of the symlink into the pagecache */
-	page = read_mapping_page(AFS_VNODE_TO_I(vnode)->i_mapping, 0, NULL);
+	page = read_mapping_page(AFS_VNODE_TO_I(vnode)->i_mapping, 0, &file);
 	if (IS_ERR(page)) {
 		ret = PTR_ERR(page);
 		goto out;
@@ -214,7 +217,7 @@ static void *afs_mntpt_follow_link(struct dentry *dentry, struct nameidata *nd)
 	struct vfsmount *newmnt;
 	int err;
 
-	_enter("%p{%s},{%s:%p{%s}}",
+	_enter("%p{%s},{%s:%p{%s},}",
 	       dentry,
 	       dentry->d_name.name,
 	       nd->mnt->mnt_devname,
@@ -234,7 +237,8 @@ static void *afs_mntpt_follow_link(struct dentry *dentry, struct nameidata *nd)
 	err = do_add_mount(newmnt, nd, MNT_SHRINKABLE, &afs_vfsmounts);
 	switch (err) {
 	case 0:
-		path_release(nd);
+		mntput(nd->mnt);
+		dput(nd->dentry);
 		nd->mnt = newmnt;
 		nd->dentry = dget(newmnt->mnt_root);
 		schedule_delayed_work(&afs_mntpt_expiry_timer,
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index e34634b..2d05d8a 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -17,6 +17,8 @@
 
 static struct socket *afs_socket; /* my RxRPC socket */
 static struct workqueue_struct *afs_async_calls;
+static atomic_t afs_outstanding_calls;
+static atomic_t afs_outstanding_skbs;
 
 static void afs_wake_up_call_waiter(struct afs_call *);
 static int afs_wait_for_call_to_complete(struct afs_call *);
@@ -45,6 +47,7 @@ static const struct afs_wait_mode afs_async_incoming_call = {
 
 /* asynchronous incoming call initial processing */
 static const struct afs_call_type afs_RXCMxxxx = {
+	.name		= "CB.xxxx",
 	.deliver	= afs_deliver_cm_op_id,
 	.abort_to_error	= afs_abort_to_error,
 };
@@ -118,10 +121,67 @@ void afs_close_socket(void)
 
 	_debug("dework");
 	destroy_workqueue(afs_async_calls);
+
+	ASSERTCMP(atomic_read(&afs_outstanding_skbs), ==, 0);
+	ASSERTCMP(atomic_read(&afs_outstanding_calls), ==, 0);
 	_leave("");
 }
 
 /*
+ * note that the data in a socket buffer is now delivered and that the buffer
+ * should be freed
+ */
+static void afs_data_delivered(struct sk_buff *skb)
+{
+	if (!skb) {
+		_debug("DLVR NULL [%d]", atomic_read(&afs_outstanding_skbs));
+		dump_stack();
+	} else {
+		_debug("DLVR %p{%u} [%d]",
+		       skb, skb->mark, atomic_read(&afs_outstanding_skbs));
+		if (atomic_dec_return(&afs_outstanding_skbs) == -1)
+			BUG();
+		rxrpc_kernel_data_delivered(skb);
+	}
+}
+
+/*
+ * free a socket buffer
+ */
+static void afs_free_skb(struct sk_buff *skb)
+{
+	if (!skb) {
+		_debug("FREE NULL [%d]", atomic_read(&afs_outstanding_skbs));
+		dump_stack();
+	} else {
+		_debug("FREE %p{%u} [%d]",
+		       skb, skb->mark, atomic_read(&afs_outstanding_skbs));
+		if (atomic_dec_return(&afs_outstanding_skbs) == -1)
+			BUG();
+		rxrpc_kernel_free_skb(skb);
+	}
+}
+
+/*
+ * free a call
+ */
+static void afs_free_call(struct afs_call *call)
+{
+	_debug("DONE %p{%s} [%d]",
+	       call, call->type->name, atomic_read(&afs_outstanding_calls));
+	if (atomic_dec_return(&afs_outstanding_calls) == -1)
+		BUG();
+
+	ASSERTCMP(call->rxcall, ==, NULL);
+	ASSERT(!work_pending(&call->async_work));
+	ASSERT(skb_queue_empty(&call->rx_queue));
+	ASSERT(call->type->name != NULL);
+
+	kfree(call->request);
+	kfree(call);
+}
+
+/*
  * allocate a call with flat request and reply buffers
  */
 struct afs_call *afs_alloc_flat_call(const struct afs_call_type *type,
@@ -133,30 +193,32 @@ struct afs_call *afs_alloc_flat_call(const struct afs_call_type *type,
 	if (!call)
 		goto nomem_call;
 
+	_debug("CALL %p{%s} [%d]",
+	       call, type->name, atomic_read(&afs_outstanding_calls));
+	atomic_inc(&afs_outstanding_calls);
+
+	call->type = type;
+	call->request_size = request_size;
+	call->reply_max = reply_size;
+
 	if (request_size) {
 		call->request = kmalloc(request_size, GFP_NOFS);
 		if (!call->request)
-			goto nomem_request;
+			goto nomem_free;
 	}
 
 	if (reply_size) {
 		call->buffer = kmalloc(reply_size, GFP_NOFS);
 		if (!call->buffer)
-			goto nomem_buffer;
+			goto nomem_free;
 	}
 
-	call->type = type;
-	call->request_size = request_size;
-	call->reply_max = reply_size;
-
 	init_waitqueue_head(&call->waitq);
 	skb_queue_head_init(&call->rx_queue);
 	return call;
 
-nomem_buffer:
-	kfree(call->request);
-nomem_request:
-	kfree(call);
+nomem_free:
+	afs_free_call(call);
 nomem_call:
 	return NULL;
 }
@@ -188,6 +250,12 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 
 	_enter("%x,{%d},", addr->s_addr, ntohs(call->port));
 
+	ASSERT(call->type != NULL);
+	ASSERT(call->type->name != NULL);
+
+	_debug("MAKE %p{%s} [%d]",
+	       call, call->type->name, atomic_read(&afs_outstanding_calls));
+
 	call->wait_mode = wait_mode;
 	INIT_WORK(&call->async_work, afs_process_async_call);
 
@@ -203,6 +271,7 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	/* create a call */
 	rxcall = rxrpc_kernel_begin_call(afs_socket, &srx, call->key,
 					 (unsigned long) call, gfp);
+	call->key = NULL;
 	if (IS_ERR(rxcall)) {
 		ret = PTR_ERR(rxcall);
 		goto error_kill_call;
@@ -237,10 +306,10 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 error_do_abort:
 	rxrpc_kernel_abort_call(rxcall, RX_USER_ABORT);
 	rxrpc_kernel_end_call(rxcall);
+	call->rxcall = NULL;
 error_kill_call:
 	call->type->destructor(call);
-	ASSERT(skb_queue_empty(&call->rx_queue));
-	kfree(call);
+	afs_free_call(call);
 	_leave(" = %d", ret);
 	return ret;
 }
@@ -257,15 +326,19 @@ static void afs_rx_interceptor(struct sock *sk, unsigned long user_call_ID,
 
 	_enter("%p,,%u", call, skb->mark);
 
+	_debug("ICPT %p{%u} [%d]",
+	       skb, skb->mark, atomic_read(&afs_outstanding_skbs));
+
 	ASSERTCMP(sk, ==, afs_socket->sk);
+	atomic_inc(&afs_outstanding_skbs);
 
 	if (!call) {
 		/* its an incoming call for our callback service */
-		__skb_queue_tail(&afs_incoming_calls, skb);
+		skb_queue_tail(&afs_incoming_calls, skb);
 		schedule_work(&afs_collect_incoming_call_work);
 	} else {
 		/* route the messages directly to the appropriate call */
-		__skb_queue_tail(&call->rx_queue, skb);
+		skb_queue_tail(&call->rx_queue, skb);
 		call->wait_mode->rx_wakeup(call);
 	}
 
@@ -317,9 +390,9 @@ static void afs_deliver_to_call(struct afs_call *call)
 				call->state = AFS_CALL_ERROR;
 				break;
 			}
-			rxrpc_kernel_data_delivered(skb);
+			afs_data_delivered(skb);
 			skb = NULL;
-			break;
+			continue;
 		case RXRPC_SKB_MARK_FINAL_ACK:
 			_debug("Rcv ACK");
 			call->state = AFS_CALL_COMPLETE;
@@ -350,19 +423,19 @@ static void afs_deliver_to_call(struct afs_call *call)
 			break;
 		}
 
-		rxrpc_kernel_free_skb(skb);
+		afs_free_skb(skb);
 	}
 
 	/* make sure the queue is empty if the call is done with (we might have
 	 * aborted the call early because of an unmarshalling error) */
 	if (call->state >= AFS_CALL_COMPLETE) {
 		while ((skb = skb_dequeue(&call->rx_queue)))
-			rxrpc_kernel_free_skb(skb);
+			afs_free_skb(skb);
 		if (call->incoming) {
 			rxrpc_kernel_end_call(call->rxcall);
+			call->rxcall = NULL;
 			call->type->destructor(call);
-			ASSERT(skb_queue_empty(&call->rx_queue));
-			kfree(call);
+			afs_free_call(call);
 		}
 	}
 
@@ -409,14 +482,14 @@ static int afs_wait_for_call_to_complete(struct afs_call *call)
 		_debug("call incomplete");
 		rxrpc_kernel_abort_call(call->rxcall, RX_CALL_DEAD);
 		while ((skb = skb_dequeue(&call->rx_queue)))
-			rxrpc_kernel_free_skb(skb);
+			afs_free_skb(skb);
 	}
 
 	_debug("call complete");
 	rxrpc_kernel_end_call(call->rxcall);
+	call->rxcall = NULL;
 	call->type->destructor(call);
-	ASSERT(skb_queue_empty(&call->rx_queue));
-	kfree(call);
+	afs_free_call(call);
 	_leave(" = %d", ret);
 	return ret;
 }
@@ -459,9 +532,7 @@ static void afs_delete_async_call(struct work_struct *work)
 
 	_enter("");
 
-	ASSERT(skb_queue_empty(&call->rx_queue));
-	ASSERT(!work_pending(&call->async_work));
-	kfree(call);
+	afs_free_call(call);
 
 	_leave("");
 }
@@ -489,6 +560,7 @@ static void afs_process_async_call(struct work_struct *work)
 
 		/* kill the call */
 		rxrpc_kernel_end_call(call->rxcall);
+		call->rxcall = NULL;
 		if (call->type->destructor)
 			call->type->destructor(call);
 
@@ -526,7 +598,7 @@ static void afs_collect_incoming_call(struct work_struct *work)
 		_debug("new call");
 
 		/* don't need the notification */
-		rxrpc_kernel_free_skb(skb);
+		afs_free_skb(skb);
 
 		if (!call) {
 			call = kzalloc(sizeof(struct afs_call), GFP_KERNEL);
@@ -541,6 +613,11 @@ static void afs_collect_incoming_call(struct work_struct *work)
 			init_waitqueue_head(&call->waitq);
 			skb_queue_head_init(&call->rx_queue);
 			call->state = AFS_CALL_AWAIT_OP_ID;
+
+			_debug("CALL %p{%s} [%d]",
+			       call, call->type->name,
+			       atomic_read(&afs_outstanding_calls));
+			atomic_inc(&afs_outstanding_calls);
 		}
 
 		rxcall = rxrpc_kernel_accept_call(afs_socket,
@@ -551,7 +628,8 @@ static void afs_collect_incoming_call(struct work_struct *work)
 		}
 	}
 
-	kfree(call);
+	if (call)
+		afs_free_call(call);
 }
 
 /*
@@ -629,8 +707,7 @@ void afs_send_empty_reply(struct afs_call *call)
 		rxrpc_kernel_end_call(call->rxcall);
 		call->rxcall = NULL;
 		call->type->destructor(call);
-		ASSERT(skb_queue_empty(&call->rx_queue));
-		kfree(call);
+		afs_free_call(call);
 		_leave(" [error]");
 		return;
 	}
diff --git a/fs/afs/security.c b/fs/afs/security.c
new file mode 100644
index 0000000..0ae9f2d
--- /dev/null
+++ b/fs/afs/security.c
@@ -0,0 +1,400 @@
+/* AFS security handling
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/ctype.h>
+#include <keys/rxrpc-type.h>
+#include "internal.h"
+
+/*
+ * get a key
+ */
+struct key *afs_request_key(struct afs_cell *cell)
+{
+	struct key *key;
+
+	_enter("{%x}", key_serial(cell->anonymous_key));
+
+	_debug("key %s", cell->anonymous_key->description);
+	key = request_key(&key_type_rxrpc, cell->anonymous_key->description,
+			  NULL);
+	if (IS_ERR(key)) {
+		if (PTR_ERR(key) != -ENOKEY) {
+			_leave(" = %ld", PTR_ERR(key));
+			return key;
+		}
+
+		/* act as anonymous user */
+		_leave(" = {%x} [anon]", key_serial(cell->anonymous_key));
+		return key_get(cell->anonymous_key);
+	} else {
+		/* act as authorised user */
+		_leave(" = {%x} [auth]", key_serial(key));
+		return key;
+	}
+}
+
+/*
+ * get a key and attach it to the nameidata record
+ */
+struct key *afs_request_key_nd(struct afs_cell *cell, struct nameidata *nd)
+{
+	struct key *key;
+	int ret;
+
+	_enter("{%x},{%x}",
+	       key_serial(cell->anonymous_key),
+	       key_serial(nd ? nd->key : NULL));
+
+	if (!nd)
+		return afs_request_key(cell);
+
+	/* if the key cached in the nameidata is the one we want, then use it
+	 * (the function fails if that key is now dead as it was used validly
+	 * in a previous step) */
+	if (nd->key && nd->key->type == &key_type_rxrpc &&
+	    strcmp(nd->key->description,
+		   cell->anonymous_key->description) == 0) {
+		_debug("cached %x", key_serial(nd->key));
+		ret = key_validate(nd->key);
+		if (ret < 0) {
+			key_put(nd->key);
+			nd->key = NULL;
+			_leave(" = %d", ret);
+			return ERR_PTR(ret);
+		}
+	} else {
+		key_put(nd->key);
+		nd->key = NULL;
+
+		_debug("key %s", cell->anonymous_key->description);
+		key = request_key(&key_type_rxrpc,
+				  cell->anonymous_key->description, NULL);
+		if (IS_ERR(key)) {
+			if (PTR_ERR(key) != -ENOKEY) {
+				_leave(" = %ld", PTR_ERR(key));
+				return key;
+			}
+
+			/* act as anonymous user */
+			_debug("anon %x", key_serial(cell->anonymous_key));
+			nd->key = key_get(cell->anonymous_key);
+		} else {
+			/* act as authorised user */
+			_debug("authorised %x", key_serial(key));
+			nd->key = key;
+		}
+	}
+	_leave(" = {%x}", key_serial(nd->key));
+	return key_get(nd->key);
+}
+
+/*
+ * dispose of a permits list
+ */
+void afs_zap_permits(struct rcu_head *rcu)
+{
+	struct afs_permits *permits =
+		container_of(rcu, struct afs_permits, rcu);
+	int loop;
+
+	_enter("{%d}", permits->count);
+
+	for (loop = permits->count - 1; loop >= 0; loop--)
+		key_put(permits->permits[loop].key);
+	kfree(permits);
+}
+
+/*
+ * dispose of a permits list in which all the key pointers have been copied
+ */
+static void afs_dispose_of_permits(struct rcu_head *rcu)
+{
+	struct afs_permits *permits =
+		container_of(rcu, struct afs_permits, rcu);
+
+	_enter("{%d}", permits->count);
+
+	kfree(permits);
+}
+
+/*
+ * get the authorising vnode - this is the specified inode itself if it's a
+ * directory or it's the parent directory if the specified inode is a file or
+ * symlink
+ * - the caller must release the ref on the inode
+ */
+static struct afs_vnode *afs_get_auth_inode(struct afs_vnode *vnode,
+					    struct key *key)
+{
+	struct afs_vnode *auth_vnode;
+	struct inode *auth_inode;
+
+	_enter("");
+
+	if (S_ISDIR(vnode->vfs_inode.i_mode)) {
+		auth_inode = igrab(&vnode->vfs_inode);
+		ASSERT(auth_inode != NULL);
+	} else {
+		auth_inode = afs_iget(vnode->vfs_inode.i_sb, key,
+				      &vnode->status.parent);
+		if (IS_ERR(auth_inode))
+			return ERR_PTR(PTR_ERR(auth_inode));
+	}
+
+	auth_vnode = AFS_FS_I(auth_inode);
+	_leave(" = {%x}", auth_vnode->fid.vnode);
+	return auth_vnode;
+}
+
+/*
+ * clear the permit cache on a directory vnode
+ */
+void afs_clear_permits(struct afs_vnode *vnode)
+{
+	struct afs_permits *permits;
+
+	_enter("{%x}", vnode->fid.vnode);
+
+	mutex_lock(&vnode->permits_lock);
+	permits = vnode->permits;
+	rcu_assign_pointer(vnode->permits, NULL);
+	mutex_unlock(&vnode->permits_lock);
+
+	if (permits)
+		call_rcu(&permits->rcu, afs_zap_permits);
+	_leave("");
+}
+
+/*
+ * add the result obtained for a vnode to its or its parent directory's cache
+ * for the key used to access it
+ */
+void afs_cache_permit(struct afs_vnode *vnode, struct key *key, long acl_order)
+{
+	struct afs_permits *permits, *xpermits;
+	struct afs_permit *permit;
+	struct afs_vnode *auth_vnode;
+	int count, loop;
+
+	_enter("{%x},%x,%lx", vnode->fid.vnode, key_serial(key), acl_order);
+
+	auth_vnode = afs_get_auth_inode(vnode, key);
+	if (IS_ERR(auth_vnode)) {
+		_leave(" [get error %ld]", PTR_ERR(auth_vnode));
+		return;
+	}
+
+	mutex_lock(&auth_vnode->permits_lock);
+
+	/* guard against a rename being detected whilst we waited for the
+	 * lock */
+	if (memcmp(&auth_vnode->fid, &vnode->status.parent,
+		   sizeof(struct afs_fid)) != 0) {
+		_debug("renamed");
+		goto out_unlock;
+	}
+
+	/* have to be careful as the directory's callback may be broken between
+	 * us receiving the status we're trying to cache and us getting the
+	 * lock to update the cache for the status */
+	if (auth_vnode->acl_order - acl_order > 0) {
+		_debug("ACL changed?");
+		goto out_unlock;
+	}
+
+	/* always update the anonymous mask */
+	_debug("anon access %x", vnode->status.anon_access);
+	auth_vnode->status.anon_access = vnode->status.anon_access;
+	if (key == vnode->volume->cell->anonymous_key)
+		goto out_unlock;
+
+	xpermits = auth_vnode->permits;
+	count = 0;
+	if (xpermits) {
+		/* see if the permit is already in the list
+		 * - if it is then we just amend the list
+		 */
+		count = xpermits->count;
+		permit = xpermits->permits;
+		for (loop = count; loop > 0; loop--) {
+			if (permit->key == key) {
+				permit->access_mask =
+					vnode->status.caller_access;
+				goto out_unlock;
+			}
+			permit++;
+		}
+	}
+
+	permits = kmalloc(sizeof(*permits) + sizeof(*permit) * (count + 1),
+			  GFP_NOFS);
+	if (!permits)
+		goto out_unlock;
+
+	memcpy(permits->permits, xpermits->permits,
+	       count * sizeof(struct afs_permit));
+
+	_debug("key %x access %x",
+	       key_serial(key), vnode->status.caller_access);
+	permits->permits[count].access_mask = vnode->status.caller_access;
+	permits->permits[count].key = key_get(key);
+	permits->count = count + 1;
+
+	rcu_assign_pointer(auth_vnode->permits, permits);
+	if (xpermits)
+		call_rcu(&xpermits->rcu, afs_dispose_of_permits);
+
+out_unlock:
+	mutex_unlock(&auth_vnode->permits_lock);
+	iput(&auth_vnode->vfs_inode);
+	_leave("");
+}
+
+/*
+ * check with the fileserver to see if the directory or parent directory is
+ * permitted to be accessed with this authorisation, and if so, what access it
+ * is granted
+ */
+static int afs_check_permit(struct afs_vnode *vnode, struct key *key,
+			    afs_access_t *_access)
+{
+	struct afs_permits *permits;
+	struct afs_permit *permit;
+	struct afs_vnode *auth_vnode;
+	bool valid;
+	int loop, ret;
+
+	_enter("");
+
+	auth_vnode = afs_get_auth_inode(vnode, key);
+	if (IS_ERR(auth_vnode)) {
+		*_access = 0;
+		_leave(" = %ld", PTR_ERR(auth_vnode));
+		return PTR_ERR(auth_vnode);
+	}
+
+	ASSERT(S_ISDIR(auth_vnode->vfs_inode.i_mode));
+
+	/* check the permits to see if we've got one yet */
+	if (key == auth_vnode->volume->cell->anonymous_key) {
+		_debug("anon");
+		*_access = auth_vnode->status.anon_access;
+		valid = true;
+	} else {
+		valid = false;
+		rcu_read_lock();
+		permits = rcu_dereference(auth_vnode->permits);
+		if (permits) {
+			permit = permits->permits;
+			for (loop = permits->count; loop > 0; loop--) {
+				if (permit->key == key) {
+					_debug("found in cache");
+					*_access = permit->access_mask;
+					valid = true;
+					break;
+				}
+				permit++;
+			}
+		}
+		rcu_read_unlock();
+	}
+
+	if (!valid) {
+		/* check the status on the file we're actually interested in
+		 * (the post-processing will cache the result on auth_vnode) */
+		_debug("no valid permit");
+
+		set_bit(AFS_VNODE_CB_BROKEN, &vnode->flags);
+		ret = afs_vnode_fetch_status(vnode, auth_vnode, key);
+		if (ret < 0) {
+			iput(&auth_vnode->vfs_inode);
+			*_access = 0;
+			_leave(" = %d", ret);
+			return ret;
+		}
+	}
+
+	*_access = vnode->status.caller_access;
+	iput(&auth_vnode->vfs_inode);
+	_leave(" = 0 [access %x]", *_access);
+	return 0;
+}
+
+/*
+ * check the permissions on an AFS file
+ * - AFS ACLs are attached to directories only, and a file is controlled by its
+ *   parent directory's ACL
+ */
+int afs_permission(struct inode *inode, int mask, struct nameidata *nd)
+{
+	struct afs_vnode *vnode = AFS_FS_I(inode);
+	afs_access_t access;
+	struct key *key;
+	int ret;
+
+	_enter("{%x:%x},%x,", vnode->fid.vid, vnode->fid.vnode, mask);
+
+	key = afs_request_key_nd(vnode->volume->cell, nd);
+	if (IS_ERR(key)) {
+		_leave(" = %ld [key]", PTR_ERR(key));
+		return PTR_ERR(key);
+	}
+
+	/* check the permits to see if we've got one yet */
+	ret = afs_check_permit(vnode, key, &access);
+	if (ret < 0) {
+		key_put(key);
+		_leave(" = %d [check]", ret);
+		return ret;
+	}
+
+	/* interpret the access mask */
+	_debug("REQ %x ACC %x on %s",
+	       mask, access, S_ISDIR(inode->i_mode) ? "dir" : "file");
+
+	if (S_ISDIR(inode->i_mode)) {
+		if (mask & MAY_EXEC) {
+			if (!(access & AFS_ACE_LOOKUP))
+				goto permission_denied;
+		} else if (mask & MAY_READ) {
+			if (!(access & AFS_ACE_READ))
+				goto permission_denied;
+		} else if (mask & MAY_WRITE) {
+			if (!(access & (AFS_ACE_DELETE | /* rmdir, unlink, rename from */
+					AFS_ACE_INSERT | /* create, mkdir, symlink, rename to */
+					AFS_ACE_WRITE))) /* chmod */
+				goto permission_denied;
+		} else {
+			BUG();
+		}
+	} else {
+		if (!(access & AFS_ACE_LOOKUP))
+			goto permission_denied;
+		if (mask & (MAY_EXEC | MAY_READ)) {
+			if (!(access & AFS_ACE_READ))
+				goto permission_denied;
+		} else if (mask & MAY_WRITE) {
+			if (!(access & AFS_ACE_WRITE))
+				goto permission_denied;
+		}
+	}
+
+	key_put(key);
+	return generic_permission(inode, mask, NULL);
+
+permission_denied:
+	key_put(key);
+	_leave(" = -EACCES");
+	return -EACCES;
+}
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 77e6875..17d7092 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -24,12 +24,6 @@
 
 #define AFS_FS_MAGIC 0x6B414653 /* 'kAFS' */
 
-struct afs_mount_params {
-	int			rwpath;
-	struct afs_cell		*default_cell;
-	struct afs_volume	*volume;
-};
-
 static void afs_i_init_once(void *foo, struct kmem_cache *cachep,
 			    unsigned long flags);
 
@@ -150,8 +144,8 @@ static int want_no_value(char *const *_value, const char *option)
  * - this function has been shamelessly adapted from the ext3 fs which
  *   shamelessly adapted it from the msdos fs
  */
-static int afs_super_parse_options(struct afs_mount_params *params,
-				   char *options, const char **devname)
+static int afs_parse_options(struct afs_mount_params *params,
+			     char *options, const char **devname)
 {
 	struct afs_cell *cell;
 	char *key, *value;
@@ -183,8 +177,8 @@ static int afs_super_parse_options(struct afs_mount_params *params,
 			cell = afs_cell_lookup(value, strlen(value));
 			if (IS_ERR(cell))
 				return PTR_ERR(cell);
-			afs_put_cell(params->default_cell);
-			params->default_cell = cell;
+			afs_put_cell(params->cell);
+			params->cell = cell;
 		} else {
 			printk("kAFS: Unknown mount option: '%s'\n",  key);
 			ret = -EINVAL;
@@ -199,6 +193,99 @@ error:
 }
 
 /*
+ * parse a device name to get cell name, volume name, volume type and R/W
+ * selector
+ * - this can be one of the following:
+ *	"%[cell:]volume[.]"		R/W volume
+ *	"#[cell:]volume[.]"		R/O or R/W volume (rwpath=0),
+ *					 or R/W (rwpath=1) volume
+ *	"%[cell:]volume.readonly"	R/O volume
+ *	"#[cell:]volume.readonly"	R/O volume
+ *	"%[cell:]volume.backup"		Backup volume
+ *	"#[cell:]volume.backup"		Backup volume
+ */
+static int afs_parse_device_name(struct afs_mount_params *params,
+				 const char *name)
+{
+	struct afs_cell *cell;
+	const char *cellname, *suffix;
+	int cellnamesz;
+
+	_enter(",%s", name);
+
+	if (!name) {
+		printk(KERN_ERR "kAFS: no volume name specified\n");
+		return -EINVAL;
+	}
+
+	if ((name[0] != '%' && name[0] != '#') || !name[1]) {
+		printk(KERN_ERR "kAFS: unparsable volume name\n");
+		return -EINVAL;
+	}
+
+	/* determine the type of volume we're looking for */
+	params->type = AFSVL_ROVOL;
+	params->force = false;
+	if (params->rwpath || name[0] == '%') {
+		params->type = AFSVL_RWVOL;
+		params->force = true;
+	}
+	name++;
+
+	/* split the cell name out if there is one */
+	params->volname = strchr(name, ':');
+	if (params->volname) {
+		cellname = name;
+		cellnamesz = params->volname - name;
+		params->volname++;
+	} else {
+		params->volname = name;
+		cellname = NULL;
+		cellnamesz = 0;
+	}
+
+	/* the volume type is further affected by a possible suffix */
+	suffix = strrchr(params->volname, '.');
+	if (suffix) {
+		if (strcmp(suffix, ".readonly") == 0) {
+			params->type = AFSVL_ROVOL;
+			params->force = true;
+		} else if (strcmp(suffix, ".backup") == 0) {
+			params->type = AFSVL_BACKVOL;
+			params->force = true;
+		} else if (suffix[1] == 0) {
+		} else {
+			suffix = NULL;
+		}
+	}
+
+	params->volnamesz = suffix ?
+		suffix - params->volname : strlen(params->volname);
+
+	_debug("cell %*.*s [%p]",
+	       cellnamesz, cellnamesz, cellname ?: "", params->cell);
+
+	/* lookup the cell record */
+	if (cellname || !params->cell) {
+		cell = afs_cell_lookup(cellname, cellnamesz);
+		if (IS_ERR(cell)) {
+			printk(KERN_ERR "kAFS: unable to lookup cell '%s'\n",
+			       cellname ?: "");
+			return PTR_ERR(cell);
+		}
+		afs_put_cell(params->cell);
+		params->cell = cell;
+	}
+
+	_debug("CELL:%s [%p] VOLUME:%*.*s SUFFIX:%s TYPE:%d%s",
+	       params->cell->name, params->cell,
+	       params->volnamesz, params->volnamesz, params->volname,
+	       suffix ?: "-", params->type, params->force ? " FORCE" : "");
+
+	return 0;
+}
+
+/*
  * check a superblock to see if it's the one we're looking for
  */
 static int afs_test_super(struct super_block *sb, void *data)
@@ -244,7 +331,7 @@ static int afs_fill_super(struct super_block *sb, void *data)
 	fid.vid		= as->volume->vid;
 	fid.vnode	= 1;
 	fid.unique	= 1;
-	inode = afs_iget(sb, &fid);
+	inode = afs_iget(sb, params->key, &fid);
 	if (IS_ERR(inode))
 		goto error_inode;
 
@@ -285,31 +372,40 @@ static int afs_get_sb(struct file_system_type *fs_type,
 	struct afs_mount_params params;
 	struct super_block *sb;
 	struct afs_volume *vol;
+	struct key *key;
 	int ret;
 
 	_enter(",,%s,%p", dev_name, options);
 
 	memset(&params, 0, sizeof(params));
 
-	/* parse the options */
+	/* parse the options and device name */
 	if (options) {
-		ret = afs_super_parse_options(&params, options, &dev_name);
+		ret = afs_parse_options(&params, options, &dev_name);
 		if (ret < 0)
 			goto error;
-		if (!dev_name) {
-			printk("kAFS: no volume name specified\n");
-			ret = -EINVAL;
-			goto error;
-		}
 	}
+		
+
+	ret = afs_parse_device_name(&params, dev_name);
+	if (ret < 0)
+		goto error;
+
+	/* try and do the mount securely */
+	key = afs_request_key(params.cell);
+	if (IS_ERR(key)) {
+		_leave(" = %ld [key]", PTR_ERR(key));
+		ret = PTR_ERR(key);
+		goto error;
+	}
+	params.key = key;
 
 	/* parse the device name */
-	vol = afs_volume_lookup(dev_name, params.default_cell, params.rwpath);
+	vol = afs_volume_lookup(&params);
 	if (IS_ERR(vol)) {
 		ret = PTR_ERR(vol);
 		goto error;
 	}
-
 	params.volume = vol;
 
 	/* allocate a deviceless superblock */
@@ -337,13 +433,14 @@ static int afs_get_sb(struct file_system_type *fs_type,
 
 	simple_set_mnt(mnt, sb);
 	afs_put_volume(params.volume);
-	afs_put_cell(params.default_cell);
+	afs_put_cell(params.cell);
 	_leave(" = 0 [%p]", sb);
 	return 0;
 
 error:
 	afs_put_volume(params.volume);
-	afs_put_cell(params.default_cell);
+	afs_put_cell(params.cell);
+	key_put(params.key);
 	_leave(" = %d", ret);
 	return ret;
 }
@@ -375,6 +472,7 @@ static void afs_i_init_once(void *_vnode, struct kmem_cache *cachep,
 		memset(vnode, 0, sizeof(*vnode));
 		inode_init_once(&vnode->vfs_inode);
 		init_waitqueue_head(&vnode->update_waitq);
+		mutex_init(&vnode->permits_lock);
 		spin_lock_init(&vnode->lock);
 		INIT_WORK(&vnode->cb_broken_work, afs_broken_callback_work);
 		mutex_init(&vnode->cb_broken_lock);
diff --git a/fs/afs/vlclient.c b/fs/afs/vlclient.c
index 0c7eba1..36c1306 100644
--- a/fs/afs/vlclient.c
+++ b/fs/afs/vlclient.c
@@ -127,6 +127,7 @@ static int afs_deliver_vl_get_entry_by_xxx(struct afs_call *call,
  * VL.GetEntryByName operation type
  */
 static const struct afs_call_type afs_RXVLGetEntryByName = {
+	.name		= "VL.GetEntryByName",
 	.deliver	= afs_deliver_vl_get_entry_by_xxx,
 	.abort_to_error	= afs_vl_abort_to_error,
 	.destructor	= afs_flat_call_destructor,
@@ -136,6 +137,7 @@ static const struct afs_call_type afs_RXVLGetEntryByName = {
  * VL.GetEntryById operation type
  */
 static const struct afs_call_type afs_RXVLGetEntryById = {
+	.name		= "VL.GetEntryById",
 	.deliver	= afs_deliver_vl_get_entry_by_xxx,
 	.abort_to_error	= afs_vl_abort_to_error,
 	.destructor	= afs_flat_call_destructor,
@@ -145,6 +147,7 @@ static const struct afs_call_type afs_RXVLGetEntryById = {
  * dispatch a get volume entry by name operation
  */
 int afs_vl_get_entry_by_name(struct in_addr *addr,
+			     struct key *key,
 			     const char *volname,
 			     struct afs_cache_vlocation *entry,
 			     const struct afs_wait_mode *wait_mode)
@@ -163,6 +166,7 @@ int afs_vl_get_entry_by_name(struct in_addr *addr,
 	if (!call)
 		return -ENOMEM;
 
+	call->key = key;
 	call->reply = entry;
 	call->service_id = VL_SERVICE;
 	call->port = htons(AFS_VL_PORT);
@@ -183,6 +187,7 @@ int afs_vl_get_entry_by_name(struct in_addr *addr,
  * dispatch a get volume entry by ID operation
  */
 int afs_vl_get_entry_by_id(struct in_addr *addr,
+			   struct key *key,
 			   afs_volid_t volid,
 			   afs_voltype_t voltype,
 			   struct afs_cache_vlocation *entry,
@@ -197,6 +202,7 @@ int afs_vl_get_entry_by_id(struct in_addr *addr,
 	if (!call)
 		return -ENOMEM;
 
+	call->key = key;
 	call->reply = entry;
 	call->service_id = VL_SERVICE;
 	call->port = htons(AFS_VL_PORT);
diff --git a/fs/afs/vlocation.c b/fs/afs/vlocation.c
index 9af1fe8..aa35412 100644
--- a/fs/afs/vlocation.c
+++ b/fs/afs/vlocation.c
@@ -33,6 +33,7 @@ static struct workqueue_struct *afs_vlocation_update_worker;
  * about the volume in question
  */
 static int afs_vlocation_access_vl_by_name(struct afs_vlocation *vl,
+					   struct key *key,
 					   struct afs_cache_vlocation *vldb)
 {
 	struct afs_cell *cell = vl->cell;
@@ -49,7 +50,7 @@ static int afs_vlocation_access_vl_by_name(struct afs_vlocation *vl,
 		_debug("CellServ[%hu]: %08x", cell->vl_curr_svix, addr.s_addr);
 
 		/* attempt to access the VL server */
-		ret = afs_vl_get_entry_by_name(&addr, vl->vldb.name, vldb,
+		ret = afs_vl_get_entry_by_name(&addr, key, vl->vldb.name, vldb,
 					       &afs_sync_call);
 		switch (ret) {
 		case 0:
@@ -86,6 +87,7 @@ out:
  * about the volume in question
  */
 static int afs_vlocation_access_vl_by_id(struct afs_vlocation *vl,
+					 struct key *key,
 					 afs_volid_t volid,
 					 afs_voltype_t voltype,
 					 struct afs_cache_vlocation *vldb)
@@ -104,7 +106,7 @@ static int afs_vlocation_access_vl_by_id(struct afs_vlocation *vl,
 		_debug("CellServ[%hu]: %08x", cell->vl_curr_svix, addr.s_addr);
 
 		/* attempt to access the VL server */
-		ret = afs_vl_get_entry_by_id(&addr, volid, voltype, vldb,
+		ret = afs_vl_get_entry_by_id(&addr, key, volid, voltype, vldb,
 					     &afs_sync_call);
 		switch (ret) {
 		case 0:
@@ -188,6 +190,7 @@ static struct afs_vlocation *afs_vlocation_alloc(struct afs_cell *cell,
  * update record if we found it in the cache
  */
 static int afs_vlocation_update_record(struct afs_vlocation *vl,
+				       struct key *key,
 				       struct afs_cache_vlocation *vldb)
 {
 	afs_voltype_t voltype;
@@ -228,7 +231,7 @@ static int afs_vlocation_update_record(struct afs_vlocation *vl,
 	/* contact the server to make sure the volume is still available
 	 * - TODO: need to handle disconnected operation here
 	 */
-	ret = afs_vlocation_access_vl_by_id(vl, vid, voltype, vldb);
+	ret = afs_vlocation_access_vl_by_id(vl, key, vid, voltype, vldb);
 	switch (ret) {
 		/* net error */
 	default:
@@ -287,7 +290,8 @@ static void afs_vlocation_apply_update(struct afs_vlocation *vl,
  * fill in a volume location record, consulting the cache and the VL server
  * both
  */
-static int afs_vlocation_fill_in_record(struct afs_vlocation *vl)
+static int afs_vlocation_fill_in_record(struct afs_vlocation *vl,
+					struct key *key)
 {
 	struct afs_cache_vlocation vldb;
 	int ret;
@@ -310,11 +314,11 @@ static int afs_vlocation_fill_in_record(struct afs_vlocation *vl)
 		/* try to update a known volume in the cell VL databases by
 		 * ID as the name may have changed */
 		_debug("found in cache");
-		ret = afs_vlocation_update_record(vl, &vldb);
+		ret = afs_vlocation_update_record(vl, key, &vldb);
 	} else {
 		/* try to look up an unknown volume in the cell VL databases by
 		 * name */
-		ret = afs_vlocation_access_vl_by_name(vl, &vldb);
+		ret = afs_vlocation_access_vl_by_name(vl, key, &vldb);
 		if (ret < 0) {
 			printk("kAFS: failed to locate '%s' in cell '%s'\n",
 			       vl->vldb.name, vl->cell->name);
@@ -366,14 +370,16 @@ void afs_vlocation_queue_for_updates(struct afs_vlocation *vl)
  * - insert/update in the local cache if did get a VL response
  */
 struct afs_vlocation *afs_vlocation_lookup(struct afs_cell *cell,
+					   struct key *key,
 					   const char *name,
 					   size_t namesz)
 {
 	struct afs_vlocation *vl;
 	int ret;
 
-	_enter("{%s},%*.*s,%zu",
-	       cell->name, (int) namesz, (int) namesz, name, namesz);
+	_enter("{%s},{%x},%*.*s,%zu",
+	       cell->name, key_serial(key),
+	       (int) namesz, (int) namesz, name, namesz);
 
 	if (namesz > sizeof(vl->vldb.name)) {
 		_leave(" = -ENAMETOOLONG");
@@ -405,7 +411,7 @@ struct afs_vlocation *afs_vlocation_lookup(struct afs_cell *cell,
 	up_write(&cell->vl_sem);
 
 fill_in_record:
-	ret = afs_vlocation_fill_in_record(vl);
+	ret = afs_vlocation_fill_in_record(vl, key);
 	if (ret < 0)
 		goto error_abandon;
 	vl->state = AFS_VL_VALID;
@@ -653,7 +659,7 @@ static void afs_vlocation_updater(struct work_struct *work)
 	vl->upd_rej_cnt = 0;
 	vl->upd_busy_cnt = 0;
 
-	ret = afs_vlocation_update_record(vl, &vldb);
+	ret = afs_vlocation_update_record(vl, NULL, &vldb);
 	switch (ret) {
 	case 0:
 		afs_vlocation_apply_update(vl, &vldb);
diff --git a/fs/afs/vnode.c b/fs/afs/vnode.c
index d2ca139..1600976 100644
--- a/fs/afs/vnode.c
+++ b/fs/afs/vnode.c
@@ -238,9 +238,11 @@ static void afs_vnode_finalise_status_update(struct afs_vnode *vnode,
  *   - there are any outstanding ops that will fetch the status
  * - TODO implement local caching
  */
-int afs_vnode_fetch_status(struct afs_vnode *vnode)
+int afs_vnode_fetch_status(struct afs_vnode *vnode,
+			   struct afs_vnode *auth_vnode, struct key *key)
 {
 	struct afs_server *server;
+	unsigned long acl_order;
 	int ret;
 
 	DECLARE_WAITQUEUE(myself, current);
@@ -260,6 +262,10 @@ int afs_vnode_fetch_status(struct afs_vnode *vnode)
 		return -ENOENT;
 	}
 
+	acl_order = 0;
+	if (auth_vnode)
+		acl_order = auth_vnode->acl_order;
+
 	spin_lock(&vnode->lock);
 
 	if (!test_bit(AFS_VNODE_CB_BROKEN, &vnode->flags) &&
@@ -324,12 +330,14 @@ get_anyway:
 		_debug("USING SERVER: %p{%08x}",
 		       server, ntohl(server->addr.s_addr));
 
-		ret = afs_fs_fetch_file_status(server, vnode, NULL,
+		ret = afs_fs_fetch_file_status(server, key, vnode, NULL,
 					       &afs_sync_call);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
 	/* adjust the flags */
+	if (ret == 0 && auth_vnode)
+		afs_cache_permit(vnode, key, acl_order);
 	afs_vnode_finalise_status_update(vnode, server, ret);
 
 	_leave(" = %d", ret);
@@ -340,17 +348,18 @@ get_anyway:
  * fetch file data from the volume
  * - TODO implement caching and server failover
  */
-int afs_vnode_fetch_data(struct afs_vnode *vnode, off_t offset, size_t length,
-			 struct page *page)
+int afs_vnode_fetch_data(struct afs_vnode *vnode, struct key *key,
+			 off_t offset, size_t length, struct page *page)
 {
 	struct afs_server *server;
 	int ret;
 
-	_enter("%s,{%u,%u,%u}",
+	_enter("%s{%u,%u,%u},%x,,,",
 	       vnode->volume->vlocation->vldb.name,
 	       vnode->fid.vid,
 	       vnode->fid.vnode,
-	       vnode->fid.unique);
+	       vnode->fid.unique,
+	       key_serial(key));
 
 	/* this op will fetch the status */
 	spin_lock(&vnode->lock);
@@ -367,8 +376,8 @@ int afs_vnode_fetch_data(struct afs_vnode *vnode, off_t offset, size_t length,
 
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
-		ret = afs_fs_fetch_data(server, vnode, offset, length, page,
-					NULL, &afs_sync_call);
+		ret = afs_fs_fetch_data(server, key, vnode, offset, length,
+					page, NULL, &afs_sync_call);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
diff --git a/fs/afs/volume.c b/fs/afs/volume.c
index 45491cf..15e1367 100644
--- a/fs/afs/volume.c
+++ b/fs/afs/volume.c
@@ -41,83 +41,20 @@ static const char *afs_voltypes[] = { "R/W", "R/O", "BAK" };
  * - Rule 3: If parent volume is R/W, then only mount R/W volume unless
  *           explicitly told otherwise
  */
-struct afs_volume *afs_volume_lookup(const char *name, struct afs_cell *cell,
-				     int rwpath)
+struct afs_volume *afs_volume_lookup(struct afs_mount_params *params)
 {
 	struct afs_vlocation *vlocation = NULL;
 	struct afs_volume *volume = NULL;
 	struct afs_server *server = NULL;
-	afs_voltype_t type;
-	const char *cellname, *volname, *suffix;
 	char srvtmask;
-	int force, ret, loop, cellnamesz, volnamesz;
+	int ret, loop;
 
-	_enter("%s,,%d,", name, rwpath);
-
-	if (!name || (name[0] != '%' && name[0] != '#') || !name[1]) {
-		printk("kAFS: unparsable volume name\n");
-		return ERR_PTR(-EINVAL);
-	}
-
-	/* determine the type of volume we're looking for */
-	force = 0;
-	type = AFSVL_ROVOL;
-
-	if (rwpath || name[0] == '%') {
-		type = AFSVL_RWVOL;
-		force = 1;
-	}
-
-	suffix = strrchr(name, '.');
-	if (suffix) {
-		if (strcmp(suffix, ".readonly") == 0) {
-			type = AFSVL_ROVOL;
-			force = 1;
-		} else if (strcmp(suffix, ".backup") == 0) {
-			type = AFSVL_BACKVOL;
-			force = 1;
-		} else if (suffix[1] == 0) {
-		} else {
-			suffix = NULL;
-		}
-	}
-
-	/* split the cell and volume names */
-	name++;
-	volname = strchr(name, ':');
-	if (volname) {
-		cellname = name;
-		cellnamesz = volname - name;
-		volname++;
-	} else {
-		volname = name;
-		cellname = NULL;
-		cellnamesz = 0;
-	}
-
-	volnamesz = suffix ? suffix - volname : strlen(volname);
-
-	_debug("CELL:%*.*s [%p] VOLUME:%*.*s SUFFIX:%s TYPE:%d%s",
-	       cellnamesz, cellnamesz, cellname ?: "", cell,
-	       volnamesz, volnamesz, volname, suffix ?: "-",
-	       type,
-	       force ? " FORCE" : "");
-
-	/* lookup the cell record */
-	if (cellname || !cell) {
-		cell = afs_cell_lookup(cellname, cellnamesz);
-		if (IS_ERR(cell)) {
-			ret = PTR_ERR(cell);
-			printk("kAFS: unable to lookup cell '%s'\n",
-			       cellname ?: "");
-			goto error;
-		}
-	} else {
-		afs_get_cell(cell);
-	}
+	_enter("{%*.*s,%d}",
+	       params->volnamesz, params->volnamesz, params->volname, params->rwpath);
 
 	/* lookup the volume location record */
-	vlocation = afs_vlocation_lookup(cell, volname, volnamesz);
+	vlocation = afs_vlocation_lookup(params->cell, params->key,
+					 params->volname, params->volnamesz);
 	if (IS_ERR(vlocation)) {
 		ret = PTR_ERR(vlocation);
 		vlocation = NULL;
@@ -126,30 +63,30 @@ struct afs_volume *afs_volume_lookup(const char *name, struct afs_cell *cell,
 
 	/* make the final decision on the type we want */
 	ret = -ENOMEDIUM;
-	if (force && !(vlocation->vldb.vidmask & (1 << type)))
+	if (params->force && !(vlocation->vldb.vidmask & (1 << params->type)))
 		goto error;
 
 	srvtmask = 0;
 	for (loop = 0; loop < vlocation->vldb.nservers; loop++)
 		srvtmask |= vlocation->vldb.srvtmask[loop];
 
-	if (force) {
-		if (!(srvtmask & (1 << type)))
+	if (params->force) {
+		if (!(srvtmask & (1 << params->type)))
 			goto error;
 	} else if (srvtmask & AFS_VOL_VTM_RO) {
-		type = AFSVL_ROVOL;
+		params->type = AFSVL_ROVOL;
 	} else if (srvtmask & AFS_VOL_VTM_RW) {
-		type = AFSVL_RWVOL;
+		params->type = AFSVL_RWVOL;
 	} else {
 		goto error;
 	}
 
-	down_write(&cell->vl_sem);
+	down_write(&params->cell->vl_sem);
 
 	/* is the volume already active? */
-	if (vlocation->vols[type]) {
+	if (vlocation->vols[params->type]) {
 		/* yes - re-use it */
-		volume = vlocation->vols[type];
+		volume = vlocation->vols[params->type];
 		afs_get_volume(volume);
 		goto success;
 	}
@@ -163,10 +100,10 @@ struct afs_volume *afs_volume_lookup(const char *name, struct afs_cell *cell,
 		goto error_up;
 
 	atomic_set(&volume->usage, 1);
-	volume->type		= type;
-	volume->type_force	= force;
-	volume->cell		= cell;
-	volume->vid		= vlocation->vldb.vid[type];
+	volume->type		= params->type;
+	volume->type_force	= params->force;
+	volume->cell		= params->cell;
+	volume->vid		= vlocation->vldb.vid[params->type];
 
 	init_rwsem(&volume->server_sem);
 
@@ -196,28 +133,26 @@ struct afs_volume *afs_volume_lookup(const char *name, struct afs_cell *cell,
 	afs_get_vlocation(vlocation);
 	volume->vlocation = vlocation;
 
-	vlocation->vols[type] = volume;
+	vlocation->vols[volume->type] = volume;
 
 success:
 	_debug("kAFS selected %s volume %08x",
 	       afs_voltypes[volume->type], volume->vid);
-	up_write(&cell->vl_sem);
+	up_write(&params->cell->vl_sem);
 	afs_put_vlocation(vlocation);
-	afs_put_cell(cell);
 	_leave(" = %p", volume);
 	return volume;
 
 	/* clean up */
 error_up:
-	up_write(&cell->vl_sem);
+	up_write(&params->cell->vl_sem);
 error:
 	afs_put_vlocation(vlocation);
-	afs_put_cell(cell);
 	_leave(" = %d", ret);
 	return ERR_PTR(ret);
 
 error_discard:
-	up_write(&cell->vl_sem);
+	up_write(&params->cell->vl_sem);
 
 	for (loop = volume->nservers - 1; loop >= 0; loop--)
 		afs_put_server(volume->servers[loop]);

