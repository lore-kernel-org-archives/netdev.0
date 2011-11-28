From: Joe Perches <joe@perches.com>
Subject: [PATCH V2] 9p: Reduce object size with CONFIG_NET_9P_DEBUG
Date: Mon, 28 Nov 2011 10:40:46 -0800
Message-ID: <1322505646.26920.2.camel@Joe-Laptop>
References: <1321661394.5917.7.camel@Joe-Laptop>
	 <CAFkjPTmyn9POfTjYYjjYEaPt6M6Wdu-P=SEc=ZeTsbA+1=VraA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFkjPTmyn9POfTjYYjjYEaPt6M6Wdu-P=SEc=ZeTsbA+1=VraA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce object size by deduplicating formats.

Use vsprintf extension %pV.
Rename P9_DPRINTK uses to p9_debug, align arguments.
Add function for _p9_debug and macro to add __func__.
Add missing "\n"s to p9_debug uses.
Remove embedded function names as p9_debug adds it.
Remove P9_EPRINTK macro and convert use to pr_<level>.
Add and use pr_fmt and pr_<level>.

$ size fs/9p/built-in.o*
   text	   data	    bss	    dec	    hex	filename
  62133	    984	  16000	  79117	  1350d	fs/9p/built-in.o.new
  67342	    984	  16928	  85254	  14d06	fs/9p/built-in.o.old
$ size net/9p/built-in.o*
   text	   data	    bss	    dec	    hex	filename
  88792	   4148	  22024	 114964	  1c114	net/9p/built-in.o.new
  94072	   4148	  23232	 121452	  1da6c	net/9p/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
V2: Add net/9p/ files

 fs/9p/cache.c          |   64 +++++++-------
 fs/9p/fid.c            |    8 +-
 fs/9p/v9fs.c           |   83 +++++++++++------
 fs/9p/vfs_addr.c       |   13 +--
 fs/9p/vfs_dentry.c     |   12 +-
 fs/9p/vfs_dir.c        |   13 +--
 fs/9p/vfs_file.c       |   31 +++---
 fs/9p/vfs_inode.c      |   86 +++++++++---------
 fs/9p/vfs_inode_dotl.c |   85 ++++++++---------
 fs/9p/vfs_super.c      |   12 +-
 fs/9p/xattr.c          |   16 ++--
 include/net/9p/9p.h    |   28 ++----
 net/9p/client.c        |  242 ++++++++++++++++++++++++------------------------
 net/9p/error.c         |    6 +-
 net/9p/mod.c           |    6 +-
 net/9p/protocol.c      |    8 +-
 net/9p/trans_fd.c      |  113 ++++++++++++-----------
 net/9p/trans_rdma.c    |   26 +++---
 net/9p/trans_virtio.c  |   34 ++++----
 net/9p/util.c          |    4 +-
 20 files changed, 451 insertions(+), 439 deletions(-)

diff --git a/fs/9p/cache.c b/fs/9p/cache.c
index 945aa5f..a9ea73d 100644
--- a/fs/9p/cache.c
+++ b/fs/9p/cache.c
@@ -62,8 +62,8 @@ static uint16_t v9fs_cache_session_get_key(const void *cookie_netfs_data,
 	uint16_t klen = 0;
 
 	v9ses = (struct v9fs_session_info *)cookie_netfs_data;
-	P9_DPRINTK(P9_DEBUG_FSC, "session %p buf %p size %u", v9ses,
-		   buffer, bufmax);
+	p9_debug(P9_DEBUG_FSC, "session %p buf %p size %u\n",
+		 v9ses, buffer, bufmax);
 
 	if (v9ses->cachetag)
 		klen = strlen(v9ses->cachetag);
@@ -72,7 +72,7 @@ static uint16_t v9fs_cache_session_get_key(const void *cookie_netfs_data,
 		return 0;
 
 	memcpy(buffer, v9ses->cachetag, klen);
-	P9_DPRINTK(P9_DEBUG_FSC, "cache session tag %s", v9ses->cachetag);
+	p9_debug(P9_DEBUG_FSC, "cache session tag %s\n", v9ses->cachetag);
 	return klen;
 }
 
@@ -91,14 +91,14 @@ void v9fs_cache_session_get_cookie(struct v9fs_session_info *v9ses)
 	v9ses->fscache = fscache_acquire_cookie(v9fs_cache_netfs.primary_index,
 						&v9fs_cache_session_index_def,
 						v9ses);
-	P9_DPRINTK(P9_DEBUG_FSC, "session %p get cookie %p", v9ses,
-		   v9ses->fscache);
+	p9_debug(P9_DEBUG_FSC, "session %p get cookie %p\n",
+		 v9ses, v9ses->fscache);
 }
 
 void v9fs_cache_session_put_cookie(struct v9fs_session_info *v9ses)
 {
-	P9_DPRINTK(P9_DEBUG_FSC, "session %p put cookie %p", v9ses,
-		   v9ses->fscache);
+	p9_debug(P9_DEBUG_FSC, "session %p put cookie %p\n",
+		 v9ses, v9ses->fscache);
 	fscache_relinquish_cookie(v9ses->fscache, 0);
 	v9ses->fscache = NULL;
 }
@@ -109,8 +109,8 @@ static uint16_t v9fs_cache_inode_get_key(const void *cookie_netfs_data,
 {
 	const struct v9fs_inode *v9inode = cookie_netfs_data;
 	memcpy(buffer, &v9inode->qid.path, sizeof(v9inode->qid.path));
-	P9_DPRINTK(P9_DEBUG_FSC, "inode %p get key %llu", &v9inode->vfs_inode,
-		   v9inode->qid.path);
+	p9_debug(P9_DEBUG_FSC, "inode %p get key %llu\n",
+		 &v9inode->vfs_inode, v9inode->qid.path);
 	return sizeof(v9inode->qid.path);
 }
 
@@ -120,8 +120,8 @@ static void v9fs_cache_inode_get_attr(const void *cookie_netfs_data,
 	const struct v9fs_inode *v9inode = cookie_netfs_data;
 	*size = i_size_read(&v9inode->vfs_inode);
 
-	P9_DPRINTK(P9_DEBUG_FSC, "inode %p get attr %llu", &v9inode->vfs_inode,
-		   *size);
+	p9_debug(P9_DEBUG_FSC, "inode %p get attr %llu\n",
+		 &v9inode->vfs_inode, *size);
 }
 
 static uint16_t v9fs_cache_inode_get_aux(const void *cookie_netfs_data,
@@ -129,8 +129,8 @@ static uint16_t v9fs_cache_inode_get_aux(const void *cookie_netfs_data,
 {
 	const struct v9fs_inode *v9inode = cookie_netfs_data;
 	memcpy(buffer, &v9inode->qid.version, sizeof(v9inode->qid.version));
-	P9_DPRINTK(P9_DEBUG_FSC, "inode %p get aux %u", &v9inode->vfs_inode,
-		   v9inode->qid.version);
+	p9_debug(P9_DEBUG_FSC, "inode %p get aux %u\n",
+		 &v9inode->vfs_inode, v9inode->qid.version);
 	return sizeof(v9inode->qid.version);
 }
 
@@ -206,8 +206,8 @@ void v9fs_cache_inode_get_cookie(struct inode *inode)
 						  &v9fs_cache_inode_index_def,
 						  v9inode);
 
-	P9_DPRINTK(P9_DEBUG_FSC, "inode %p get cookie %p", inode,
-		   v9inode->fscache);
+	p9_debug(P9_DEBUG_FSC, "inode %p get cookie %p\n",
+		 inode, v9inode->fscache);
 }
 
 void v9fs_cache_inode_put_cookie(struct inode *inode)
@@ -216,8 +216,8 @@ void v9fs_cache_inode_put_cookie(struct inode *inode)
 
 	if (!v9inode->fscache)
 		return;
-	P9_DPRINTK(P9_DEBUG_FSC, "inode %p put cookie %p", inode,
-		   v9inode->fscache);
+	p9_debug(P9_DEBUG_FSC, "inode %p put cookie %p\n",
+		 inode, v9inode->fscache);
 
 	fscache_relinquish_cookie(v9inode->fscache, 0);
 	v9inode->fscache = NULL;
@@ -229,8 +229,8 @@ void v9fs_cache_inode_flush_cookie(struct inode *inode)
 
 	if (!v9inode->fscache)
 		return;
-	P9_DPRINTK(P9_DEBUG_FSC, "inode %p flush cookie %p", inode,
-		   v9inode->fscache);
+	p9_debug(P9_DEBUG_FSC, "inode %p flush cookie %p\n",
+		 inode, v9inode->fscache);
 
 	fscache_relinquish_cookie(v9inode->fscache, 1);
 	v9inode->fscache = NULL;
@@ -272,8 +272,8 @@ void v9fs_cache_inode_reset_cookie(struct inode *inode)
 	v9inode->fscache = fscache_acquire_cookie(v9ses->fscache,
 						  &v9fs_cache_inode_index_def,
 						  v9inode);
-	P9_DPRINTK(P9_DEBUG_FSC, "inode %p revalidating cookie old %p new %p",
-		   inode, old, v9inode->fscache);
+	p9_debug(P9_DEBUG_FSC, "inode %p revalidating cookie old %p new %p\n",
+		 inode, old, v9inode->fscache);
 
 	spin_unlock(&v9inode->fscache_lock);
 }
@@ -323,7 +323,7 @@ int __v9fs_readpage_from_fscache(struct inode *inode, struct page *page)
 	int ret;
 	const struct v9fs_inode *v9inode = V9FS_I(inode);
 
-	P9_DPRINTK(P9_DEBUG_FSC, "inode %p page %p", inode, page);
+	p9_debug(P9_DEBUG_FSC, "inode %p page %p\n", inode, page);
 	if (!v9inode->fscache)
 		return -ENOBUFS;
 
@@ -335,13 +335,13 @@ int __v9fs_readpage_from_fscache(struct inode *inode, struct page *page)
 	switch (ret) {
 	case -ENOBUFS:
 	case -ENODATA:
-		P9_DPRINTK(P9_DEBUG_FSC, "page/inode not in cache %d", ret);
+		p9_debug(P9_DEBUG_FSC, "page/inode not in cache %d\n", ret);
 		return 1;
 	case 0:
-		P9_DPRINTK(P9_DEBUG_FSC, "BIO submitted");
+		p9_debug(P9_DEBUG_FSC, "BIO submitted\n");
 		return ret;
 	default:
-		P9_DPRINTK(P9_DEBUG_FSC, "ret %d", ret);
+		p9_debug(P9_DEBUG_FSC, "ret %d\n", ret);
 		return ret;
 	}
 }
@@ -361,7 +361,7 @@ int __v9fs_readpages_from_fscache(struct inode *inode,
 	int ret;
 	const struct v9fs_inode *v9inode = V9FS_I(inode);
 
-	P9_DPRINTK(P9_DEBUG_FSC, "inode %p pages %u", inode, *nr_pages);
+	p9_debug(P9_DEBUG_FSC, "inode %p pages %u\n", inode, *nr_pages);
 	if (!v9inode->fscache)
 		return -ENOBUFS;
 
@@ -373,15 +373,15 @@ int __v9fs_readpages_from_fscache(struct inode *inode,
 	switch (ret) {
 	case -ENOBUFS:
 	case -ENODATA:
-		P9_DPRINTK(P9_DEBUG_FSC, "pages/inodes not in cache %d", ret);
+		p9_debug(P9_DEBUG_FSC, "pages/inodes not in cache %d\n", ret);
 		return 1;
 	case 0:
 		BUG_ON(!list_empty(pages));
 		BUG_ON(*nr_pages != 0);
-		P9_DPRINTK(P9_DEBUG_FSC, "BIO submitted");
+		p9_debug(P9_DEBUG_FSC, "BIO submitted\n");
 		return ret;
 	default:
-		P9_DPRINTK(P9_DEBUG_FSC, "ret %d", ret);
+		p9_debug(P9_DEBUG_FSC, "ret %d\n", ret);
 		return ret;
 	}
 }
@@ -396,9 +396,9 @@ void __v9fs_readpage_to_fscache(struct inode *inode, struct page *page)
 	int ret;
 	const struct v9fs_inode *v9inode = V9FS_I(inode);
 
-	P9_DPRINTK(P9_DEBUG_FSC, "inode %p page %p", inode, page);
+	p9_debug(P9_DEBUG_FSC, "inode %p page %p\n", inode, page);
 	ret = fscache_write_page(v9inode->fscache, page, GFP_KERNEL);
-	P9_DPRINTK(P9_DEBUG_FSC, "ret =  %d", ret);
+	p9_debug(P9_DEBUG_FSC, "ret =  %d\n", ret);
 	if (ret != 0)
 		v9fs_uncache_page(inode, page);
 }
@@ -409,7 +409,7 @@ void __v9fs_readpage_to_fscache(struct inode *inode, struct page *page)
 void __v9fs_fscache_wait_on_page_write(struct inode *inode, struct page *page)
 {
 	const struct v9fs_inode *v9inode = V9FS_I(inode);
-	P9_DPRINTK(P9_DEBUG_FSC, "inode %p page %p", inode, page);
+	p9_debug(P9_DEBUG_FSC, "inode %p page %p\n", inode, page);
 	if (PageFsCache(page))
 		fscache_wait_on_page_write(v9inode->fscache, page);
 }
diff --git a/fs/9p/fid.c b/fs/9p/fid.c
index 85b67ff..da8eefb 100644
--- a/fs/9p/fid.c
+++ b/fs/9p/fid.c
@@ -45,8 +45,8 @@ int v9fs_fid_add(struct dentry *dentry, struct p9_fid *fid)
 {
 	struct v9fs_dentry *dent;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "fid %d dentry %s\n",
-					fid->fid, dentry->d_name.name);
+	p9_debug(P9_DEBUG_VFS, "fid %d dentry %s\n",
+		 fid->fid, dentry->d_name.name);
 
 	dent = dentry->d_fsdata;
 	if (!dent) {
@@ -79,8 +79,8 @@ static struct p9_fid *v9fs_fid_find(struct dentry *dentry, u32 uid, int any)
 	struct v9fs_dentry *dent;
 	struct p9_fid *fid, *ret;
 
-	P9_DPRINTK(P9_DEBUG_VFS, " dentry: %s (%p) uid %d any %d\n",
-		dentry->d_name.name, dentry, uid, any);
+	p9_debug(P9_DEBUG_VFS, " dentry: %s (%p) uid %d any %d\n",
+		 dentry->d_name.name, dentry, uid, any);
 	dent = (struct v9fs_dentry *) dentry->d_fsdata;
 	ret = NULL;
 	if (dent) {
diff --git a/fs/9p/v9fs.c b/fs/9p/v9fs.c
index 2b78014..4afc182 100644
--- a/fs/9p/v9fs.c
+++ b/fs/9p/v9fs.c
@@ -23,6 +23,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/fs.h>
@@ -85,15 +87,15 @@ static int get_cache_mode(char *s)
 
 	if (!strcmp(s, "loose")) {
 		version = CACHE_LOOSE;
-		P9_DPRINTK(P9_DEBUG_9P, "Cache mode: loose\n");
+		p9_debug(P9_DEBUG_9P, "Cache mode: loose\n");
 	} else if (!strcmp(s, "fscache")) {
 		version = CACHE_FSCACHE;
-		P9_DPRINTK(P9_DEBUG_9P, "Cache mode: fscache\n");
+		p9_debug(P9_DEBUG_9P, "Cache mode: fscache\n");
 	} else if (!strcmp(s, "none")) {
 		version = CACHE_NONE;
-		P9_DPRINTK(P9_DEBUG_9P, "Cache mode: none\n");
+		p9_debug(P9_DEBUG_9P, "Cache mode: none\n");
 	} else
-		printk(KERN_INFO "9p: Unknown Cache mode %s.\n", s);
+		pr_info("Unknown Cache mode %s\n", s);
 	return version;
 }
 
@@ -140,8 +142,8 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 		case Opt_debug:
 			r = match_int(&args[0], &option);
 			if (r < 0) {
-				P9_DPRINTK(P9_DEBUG_ERROR,
-					   "integer field, but no integer?\n");
+				p9_debug(P9_DEBUG_ERROR,
+					 "integer field, but no integer?\n");
 				ret = r;
 				continue;
 			}
@@ -154,8 +156,8 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 		case Opt_dfltuid:
 			r = match_int(&args[0], &option);
 			if (r < 0) {
-				P9_DPRINTK(P9_DEBUG_ERROR,
-					   "integer field, but no integer?\n");
+				p9_debug(P9_DEBUG_ERROR,
+					 "integer field, but no integer?\n");
 				ret = r;
 				continue;
 			}
@@ -164,8 +166,8 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 		case Opt_dfltgid:
 			r = match_int(&args[0], &option);
 			if (r < 0) {
-				P9_DPRINTK(P9_DEBUG_ERROR,
-					   "integer field, but no integer?\n");
+				p9_debug(P9_DEBUG_ERROR,
+					 "integer field, but no integer?\n");
 				ret = r;
 				continue;
 			}
@@ -174,8 +176,8 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 		case Opt_afid:
 			r = match_int(&args[0], &option);
 			if (r < 0) {
-				P9_DPRINTK(P9_DEBUG_ERROR,
-					   "integer field, but no integer?\n");
+				p9_debug(P9_DEBUG_ERROR,
+					 "integer field, but no integer?\n");
 				ret = r;
 				continue;
 			}
@@ -205,8 +207,8 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 			s = match_strdup(&args[0]);
 			if (!s) {
 				ret = -ENOMEM;
-				P9_DPRINTK(P9_DEBUG_ERROR,
-				  "problem allocating copy of cache arg\n");
+				p9_debug(P9_DEBUG_ERROR,
+					 "problem allocating copy of cache arg\n");
 				goto free_and_return;
 			}
 			ret = get_cache_mode(s);
@@ -223,8 +225,8 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 			s = match_strdup(&args[0]);
 			if (!s) {
 				ret = -ENOMEM;
-				P9_DPRINTK(P9_DEBUG_ERROR,
-				  "problem allocating copy of access arg\n");
+				p9_debug(P9_DEBUG_ERROR,
+					 "problem allocating copy of access arg\n");
 				goto free_and_return;
 			}
 
@@ -240,8 +242,8 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 				v9ses->uid = simple_strtoul(s, &e, 10);
 				if (*e != '\0') {
 					ret = -EINVAL;
-					printk(KERN_INFO "9p: Unknown access "
-							"argument %s.\n", s);
+					pr_info("Unknown access argument %s\n",
+						s);
 					kfree(s);
 					goto free_and_return;
 				}
@@ -254,9 +256,8 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
 #ifdef CONFIG_9P_FS_POSIX_ACL
 			v9ses->flags |= V9FS_POSIX_ACL;
 #else
-			P9_DPRINTK(P9_DEBUG_ERROR,
-					"Not defined CONFIG_9P_FS_POSIX_ACL. "
-					"Ignoring posixacl option\n");
+			p9_debug(P9_DEBUG_ERROR,
+				 "Not defined CONFIG_9P_FS_POSIX_ACL. Ignoring posixacl option\n");
 #endif
 			break;
 
@@ -318,7 +319,7 @@ struct p9_fid *v9fs_session_init(struct v9fs_session_info *v9ses,
 	if (IS_ERR(v9ses->clnt)) {
 		retval = PTR_ERR(v9ses->clnt);
 		v9ses->clnt = NULL;
-		P9_DPRINTK(P9_DEBUG_ERROR, "problem initializing 9p client\n");
+		p9_debug(P9_DEBUG_ERROR, "problem initializing 9p client\n");
 		goto error;
 	}
 
@@ -371,7 +372,7 @@ struct p9_fid *v9fs_session_init(struct v9fs_session_info *v9ses,
 	if (IS_ERR(fid)) {
 		retval = PTR_ERR(fid);
 		fid = NULL;
-		P9_DPRINTK(P9_DEBUG_ERROR, "cannot attach\n");
+		p9_debug(P9_DEBUG_ERROR, "cannot attach\n");
 		goto error;
 	}
 
@@ -429,7 +430,7 @@ void v9fs_session_close(struct v9fs_session_info *v9ses)
  */
 
 void v9fs_session_cancel(struct v9fs_session_info *v9ses) {
-	P9_DPRINTK(P9_DEBUG_ERROR, "cancel session %p\n", v9ses);
+	p9_debug(P9_DEBUG_ERROR, "cancel session %p\n", v9ses);
 	p9_client_disconnect(v9ses->clnt);
 }
 
@@ -442,7 +443,7 @@ void v9fs_session_cancel(struct v9fs_session_info *v9ses) {
 
 void v9fs_session_begin_cancel(struct v9fs_session_info *v9ses)
 {
-	P9_DPRINTK(P9_DEBUG_ERROR, "begin cancel session %p\n", v9ses);
+	p9_debug(P9_DEBUG_ERROR, "begin cancel session %p\n", v9ses);
 	p9_client_begin_disconnect(v9ses->clnt);
 }
 
@@ -591,23 +592,23 @@ static void v9fs_cache_unregister(void)
 static int __init init_v9fs(void)
 {
 	int err;
-	printk(KERN_INFO "Installing v9fs 9p2000 file system support\n");
+	pr_info("Installing v9fs 9p2000 file system support\n");
 	/* TODO: Setup list of registered trasnport modules */
 	err = register_filesystem(&v9fs_fs_type);
 	if (err < 0) {
-		printk(KERN_ERR "Failed to register filesystem\n");
+		pr_err("Failed to register filesystem\n");
 		return err;
 	}
 
 	err = v9fs_cache_register();
 	if (err < 0) {
-		printk(KERN_ERR "Failed to register v9fs for caching\n");
+		pr_err("Failed to register v9fs for caching\n");
 		goto out_fs_unreg;
 	}
 
 	err = v9fs_sysfs_init();
 	if (err < 0) {
-		printk(KERN_ERR "Failed to register with sysfs\n");
+		pr_err("Failed to register with sysfs\n");
 		goto out_sysfs_cleanup;
 	}
 
@@ -637,6 +638,30 @@ static void __exit exit_v9fs(void)
 module_init(init_v9fs)
 module_exit(exit_v9fs)
 
+#ifdef CONFIG_NET_9P_DEBUG
+void _p9_debug(enum p9_debug_flags level, const char *func,
+	       const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	if ((p9_debug_level & level) != level)
+		return;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	if (level == P9_DEBUG_9P)
+		pr_notice("(%8.8d) %pV", task_pid_nr(current), &vaf);
+	else
+		pr_notice("-- %s (%d): %pV", func, task_pid_nr(current), &vaf);
+
+	va_end(args);
+}
+#endif
+
 MODULE_AUTHOR("Latchesar Ionkov <lucho@ionkov.net>");
 MODULE_AUTHOR("Eric Van Hensbergen <ericvh@gmail.com>");
 MODULE_AUTHOR("Ron Minnich <rminnich@lanl.gov>");
diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index 2524e4c..0ad61c6 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -56,7 +56,7 @@ static int v9fs_fid_readpage(struct p9_fid *fid, struct page *page)
 	struct inode *inode;
 
 	inode = page->mapping->host;
-	P9_DPRINTK(P9_DEBUG_VFS, "\n");
+	p9_debug(P9_DEBUG_VFS, "\n");
 
 	BUG_ON(!PageLocked(page));
 
@@ -116,14 +116,14 @@ static int v9fs_vfs_readpages(struct file *filp, struct address_space *mapping,
 	struct inode *inode;
 
 	inode = mapping->host;
-	P9_DPRINTK(P9_DEBUG_VFS, "inode: %p file: %p\n", inode, filp);
+	p9_debug(P9_DEBUG_VFS, "inode: %p file: %p\n", inode, filp);
 
 	ret = v9fs_readpages_from_fscache(inode, mapping, pages, &nr_pages);
 	if (ret == 0)
 		return ret;
 
 	ret = read_cache_pages(mapping, pages, (void *)v9fs_vfs_readpage, filp);
-	P9_DPRINTK(P9_DEBUG_VFS, "  = %d\n", ret);
+	p9_debug(P9_DEBUG_VFS, "  = %d\n", ret);
 	return ret;
 }
 
@@ -263,10 +263,9 @@ v9fs_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov,
 	 * Now that we do caching with cache mode enabled, We need
 	 * to support direct IO
 	 */
-	P9_DPRINTK(P9_DEBUG_VFS, "v9fs_direct_IO: v9fs_direct_IO (%s) "
-			"off/no(%lld/%lu) EINVAL\n",
-			iocb->ki_filp->f_path.dentry->d_name.name,
-			(long long) pos, nr_segs);
+	p9_debug(P9_DEBUG_VFS, "v9fs_direct_IO: v9fs_direct_IO (%s) off/no(%lld/%lu) EINVAL\n",
+		 iocb->ki_filp->f_path.dentry->d_name.name,
+		 (long long)pos, nr_segs);
 
 	return -EINVAL;
 }
diff --git a/fs/9p/vfs_dentry.c b/fs/9p/vfs_dentry.c
index e022890..d529437 100644
--- a/fs/9p/vfs_dentry.c
+++ b/fs/9p/vfs_dentry.c
@@ -53,8 +53,8 @@
 
 static int v9fs_dentry_delete(const struct dentry *dentry)
 {
-	P9_DPRINTK(P9_DEBUG_VFS, " dentry: %s (%p)\n", dentry->d_name.name,
-									dentry);
+	p9_debug(P9_DEBUG_VFS, " dentry: %s (%p)\n",
+		 dentry->d_name.name, dentry);
 
 	return 1;
 }
@@ -66,8 +66,8 @@ static int v9fs_dentry_delete(const struct dentry *dentry)
  */
 static int v9fs_cached_dentry_delete(const struct dentry *dentry)
 {
-	P9_DPRINTK(P9_DEBUG_VFS, " dentry: %s (%p)\n",
-		   dentry->d_name.name, dentry);
+	p9_debug(P9_DEBUG_VFS, " dentry: %s (%p)\n",
+		 dentry->d_name.name, dentry);
 
 	/* Don't cache negative dentries */
 	if (!dentry->d_inode)
@@ -86,8 +86,8 @@ static void v9fs_dentry_release(struct dentry *dentry)
 	struct v9fs_dentry *dent;
 	struct p9_fid *temp, *current_fid;
 
-	P9_DPRINTK(P9_DEBUG_VFS, " dentry: %s (%p)\n", dentry->d_name.name,
-									dentry);
+	p9_debug(P9_DEBUG_VFS, " dentry: %s (%p)\n",
+		 dentry->d_name.name, dentry);
 	dent = dentry->d_fsdata;
 	if (dent) {
 		list_for_each_entry_safe(current_fid, temp, &dent->fidlist,
diff --git a/fs/9p/vfs_dir.c b/fs/9p/vfs_dir.c
index 598fff1..ff911e7 100644
--- a/fs/9p/vfs_dir.c
+++ b/fs/9p/vfs_dir.c
@@ -140,7 +140,7 @@ static int v9fs_dir_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	int reclen = 0;
 	struct p9_rdir *rdir;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "name %s\n", filp->f_path.dentry->d_name.name);
+	p9_debug(P9_DEBUG_VFS, "name %s\n", filp->f_path.dentry->d_name.name);
 	fid = filp->private_data;
 
 	buflen = fid->clnt->msize - P9_IOHDRSZ;
@@ -168,7 +168,7 @@ static int v9fs_dir_readdir(struct file *filp, void *dirent, filldir_t filldir)
 			err = p9stat_read(fid->clnt, rdir->buf + rdir->head,
 					  rdir->tail - rdir->head, &st);
 			if (err) {
-				P9_DPRINTK(P9_DEBUG_VFS, "returned %d\n", err);
+				p9_debug(P9_DEBUG_VFS, "returned %d\n", err);
 				err = -EIO;
 				p9stat_free(&st);
 				goto unlock_and_exit;
@@ -213,7 +213,7 @@ static int v9fs_dir_readdir_dotl(struct file *filp, void *dirent,
 	struct p9_dirent curdirent;
 	u64 oldoffset = 0;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "name %s\n", filp->f_path.dentry->d_name.name);
+	p9_debug(P9_DEBUG_VFS, "name %s\n", filp->f_path.dentry->d_name.name);
 	fid = filp->private_data;
 
 	buflen = fid->clnt->msize - P9_READDIRHDRSZ;
@@ -244,7 +244,7 @@ static int v9fs_dir_readdir_dotl(struct file *filp, void *dirent,
 					    rdir->tail - rdir->head,
 					    &curdirent);
 			if (err < 0) {
-				P9_DPRINTK(P9_DEBUG_VFS, "returned %d\n", err);
+				p9_debug(P9_DEBUG_VFS, "returned %d\n", err);
 				err = -EIO;
 				goto unlock_and_exit;
 			}
@@ -290,9 +290,8 @@ int v9fs_dir_release(struct inode *inode, struct file *filp)
 	struct p9_fid *fid;
 
 	fid = filp->private_data;
-	P9_DPRINTK(P9_DEBUG_VFS,
-			"v9fs_dir_release: inode: %p filp: %p fid: %d\n",
-			inode, filp, fid ? fid->fid : -1);
+	p9_debug(P9_DEBUG_VFS, "inode: %p filp: %p fid: %d\n",
+		 inode, filp, fid ? fid->fid : -1);
 	if (fid)
 		p9_client_clunk(fid);
 	return 0;
diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index 62857a8..8947f9f 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -61,7 +61,7 @@ int v9fs_file_open(struct inode *inode, struct file *file)
 	struct p9_fid *fid;
 	int omode;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "inode: %p file: %p\n", inode, file);
+	p9_debug(P9_DEBUG_VFS, "inode: %p file: %p\n", inode, file);
 	v9inode = V9FS_I(inode);
 	v9ses = v9fs_inode2v9ses(inode);
 	if (v9fs_proto_dotl(v9ses))
@@ -135,7 +135,7 @@ static int v9fs_file_lock(struct file *filp, int cmd, struct file_lock *fl)
 	int res = 0;
 	struct inode *inode = filp->f_path.dentry->d_inode;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "filp: %p lock: %p\n", filp, fl);
+	p9_debug(P9_DEBUG_VFS, "filp: %p lock: %p\n", filp, fl);
 
 	/* No mandatory locks */
 	if (__mandatory_lock(inode) && fl->fl_type != F_UNLCK)
@@ -304,8 +304,8 @@ static int v9fs_file_lock_dotl(struct file *filp, int cmd, struct file_lock *fl)
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	int ret = -ENOLCK;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "filp: %p cmd:%d lock: %p name: %s\n", filp,
-				cmd, fl, filp->f_path.dentry->d_name.name);
+	p9_debug(P9_DEBUG_VFS, "filp: %p cmd:%d lock: %p name: %s\n",
+		 filp, cmd, fl, filp->f_path.dentry->d_name.name);
 
 	/* No mandatory locks */
 	if (__mandatory_lock(inode) && fl->fl_type != F_UNLCK)
@@ -340,8 +340,8 @@ static int v9fs_file_flock_dotl(struct file *filp, int cmd,
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	int ret = -ENOLCK;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "filp: %p cmd:%d lock: %p name: %s\n", filp,
-				cmd, fl, filp->f_path.dentry->d_name.name);
+	p9_debug(P9_DEBUG_VFS, "filp: %p cmd:%d lock: %p name: %s\n",
+		 filp, cmd, fl, filp->f_path.dentry->d_name.name);
 
 	/* No mandatory locks */
 	if (__mandatory_lock(inode) && fl->fl_type != F_UNLCK)
@@ -384,8 +384,8 @@ v9fs_fid_readn(struct p9_fid *fid, char *data, char __user *udata, u32 count,
 {
 	int n, total, size;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "fid %d offset %llu count %d\n", fid->fid,
-		   (long long unsigned) offset, count);
+	p9_debug(P9_DEBUG_VFS, "fid %d offset %llu count %d\n",
+		 fid->fid, (long long unsigned)offset, count);
 	n = 0;
 	total = 0;
 	size = fid->iounit ? fid->iounit : fid->clnt->msize - P9_IOHDRSZ;
@@ -443,7 +443,7 @@ v9fs_file_read(struct file *filp, char __user *udata, size_t count,
 	struct p9_fid *fid;
 	size_t size;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "count %zu offset %lld\n", count, *offset);
+	p9_debug(P9_DEBUG_VFS, "count %zu offset %lld\n", count, *offset);
 	fid = filp->private_data;
 
 	size = fid->iounit ? fid->iounit : fid->clnt->msize - P9_IOHDRSZ;
@@ -470,8 +470,8 @@ v9fs_file_write_internal(struct inode *inode, struct p9_fid *fid,
 	loff_t origin = *offset;
 	unsigned long pg_start, pg_end;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "data %p count %d offset %x\n", data,
-		(int)count, (int)*offset);
+	p9_debug(P9_DEBUG_VFS, "data %p count %d offset %x\n",
+		 data, (int)count, (int)*offset);
 
 	clnt = fid->clnt;
 	do {
@@ -552,7 +552,7 @@ static int v9fs_file_fsync(struct file *filp, loff_t start, loff_t end,
 		return retval;
 
 	mutex_lock(&inode->i_mutex);
-	P9_DPRINTK(P9_DEBUG_VFS, "filp %p datasync %x\n", filp, datasync);
+	p9_debug(P9_DEBUG_VFS, "filp %p datasync %x\n", filp, datasync);
 
 	fid = filp->private_data;
 	v9fs_blank_wstat(&wstat);
@@ -575,8 +575,7 @@ int v9fs_file_fsync_dotl(struct file *filp, loff_t start, loff_t end,
 		return retval;
 
 	mutex_lock(&inode->i_mutex);
-	P9_DPRINTK(P9_DEBUG_VFS, "v9fs_file_fsync_dotl: filp %p datasync %x\n",
-			filp, datasync);
+	p9_debug(P9_DEBUG_VFS, "filp %p datasync %x\n", filp, datasync);
 
 	fid = filp->private_data;
 
@@ -607,8 +606,8 @@ v9fs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct inode *inode = filp->f_path.dentry->d_inode;
 
 
-	P9_DPRINTK(P9_DEBUG_VFS, "page %p fid %lx\n",
-		   page, (unsigned long)filp->private_data);
+	p9_debug(P9_DEBUG_VFS, "page %p fid %lx\n",
+		 page, (unsigned long)filp->private_data);
 
 	v9inode = V9FS_I(inode);
 	/* make sure the cache has finished storing the page */
diff --git a/fs/9p/vfs_inode.c b/fs/9p/vfs_inode.c
index 879ed88..85c2973 100644
--- a/fs/9p/vfs_inode.c
+++ b/fs/9p/vfs_inode.c
@@ -23,6 +23,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/fs.h>
@@ -133,9 +135,8 @@ static int p9mode2unixmode(struct v9fs_session_info *v9ses,
 			res |= S_IFBLK;
 			break;
 		default:
-			P9_DPRINTK(P9_DEBUG_ERROR,
-				"Unknown special type %c %s\n", type,
-				stat->extension);
+			p9_debug(P9_DEBUG_ERROR, "Unknown special type %c %s\n",
+				 type, stat->extension);
 		};
 		*rdev = MKDEV(major, minor);
 	} else
@@ -281,8 +282,8 @@ int v9fs_init_inode(struct v9fs_session_info *v9ses,
 		} else if (v9fs_proto_dotu(v9ses)) {
 			inode->i_op = &v9fs_file_inode_operations;
 		} else {
-			P9_DPRINTK(P9_DEBUG_ERROR,
-				   "special files without extended mode\n");
+			p9_debug(P9_DEBUG_ERROR,
+				 "special files without extended mode\n");
 			err = -EINVAL;
 			goto error;
 		}
@@ -307,8 +308,8 @@ int v9fs_init_inode(struct v9fs_session_info *v9ses,
 		break;
 	case S_IFLNK:
 		if (!v9fs_proto_dotu(v9ses) && !v9fs_proto_dotl(v9ses)) {
-			P9_DPRINTK(P9_DEBUG_ERROR, "extended modes used with "
-						"legacy protocol.\n");
+			p9_debug(P9_DEBUG_ERROR,
+				 "extended modes used with legacy protocol\n");
 			err = -EINVAL;
 			goto error;
 		}
@@ -335,8 +336,8 @@ int v9fs_init_inode(struct v9fs_session_info *v9ses,
 
 		break;
 	default:
-		P9_DPRINTK(P9_DEBUG_ERROR, "BAD mode 0x%x S_IFMT 0x%x\n",
-			   mode, mode & S_IFMT);
+		p9_debug(P9_DEBUG_ERROR, "BAD mode 0x%x S_IFMT 0x%x\n",
+			 mode, mode & S_IFMT);
 		err = -EINVAL;
 		goto error;
 	}
@@ -358,11 +359,12 @@ struct inode *v9fs_get_inode(struct super_block *sb, int mode, dev_t rdev)
 	struct inode *inode;
 	struct v9fs_session_info *v9ses = sb->s_fs_info;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "super block: %p mode: %o\n", sb, mode);
+	p9_debug(P9_DEBUG_VFS, "super block: %p mode: %o\n", sb, mode);
 
 	inode = new_inode(sb);
 	if (!inode) {
-		P9_EPRINTK(KERN_WARNING, "Problem allocating inode\n");
+		pr_warn("%s (%d): Problem allocating inode\n",
+			__func__, task_pid_nr(current));
 		return ERR_PTR(-ENOMEM);
 	}
 	err = v9fs_init_inode(v9ses, inode, mode, rdev);
@@ -578,15 +580,15 @@ static int v9fs_remove(struct inode *dir, struct dentry *dentry, int flags)
 	struct p9_fid *v9fid, *dfid;
 	struct v9fs_session_info *v9ses;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "inode: %p dentry: %p rmdir: %x\n",
-		   dir, dentry, flags);
+	p9_debug(P9_DEBUG_VFS, "inode: %p dentry: %p rmdir: %x\n",
+		 dir, dentry, flags);
 
 	v9ses = v9fs_inode2v9ses(dir);
 	inode = dentry->d_inode;
 	dfid = v9fs_fid_lookup(dentry->d_parent);
 	if (IS_ERR(dfid)) {
 		retval = PTR_ERR(dfid);
-		P9_DPRINTK(P9_DEBUG_VFS, "fid lookup failed %d\n", retval);
+		p9_debug(P9_DEBUG_VFS, "fid lookup failed %d\n", retval);
 		return retval;
 	}
 	if (v9fs_proto_dotl(v9ses))
@@ -635,7 +637,7 @@ v9fs_create(struct v9fs_session_info *v9ses, struct inode *dir,
 	struct p9_fid *dfid, *ofid, *fid;
 	struct inode *inode;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "name %s\n", dentry->d_name.name);
+	p9_debug(P9_DEBUG_VFS, "name %s\n", dentry->d_name.name);
 
 	err = 0;
 	ofid = NULL;
@@ -644,7 +646,7 @@ v9fs_create(struct v9fs_session_info *v9ses, struct inode *dir,
 	dfid = v9fs_fid_lookup(dentry->d_parent);
 	if (IS_ERR(dfid)) {
 		err = PTR_ERR(dfid);
-		P9_DPRINTK(P9_DEBUG_VFS, "fid lookup failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "fid lookup failed %d\n", err);
 		return ERR_PTR(err);
 	}
 
@@ -652,13 +654,13 @@ v9fs_create(struct v9fs_session_info *v9ses, struct inode *dir,
 	ofid = p9_client_walk(dfid, 0, NULL, 1);
 	if (IS_ERR(ofid)) {
 		err = PTR_ERR(ofid);
-		P9_DPRINTK(P9_DEBUG_VFS, "p9_client_walk failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "p9_client_walk failed %d\n", err);
 		return ERR_PTR(err);
 	}
 
 	err = p9_client_fcreate(ofid, name, perm, mode, extension);
 	if (err < 0) {
-		P9_DPRINTK(P9_DEBUG_VFS, "p9_client_fcreate failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "p9_client_fcreate failed %d\n", err);
 		goto error;
 	}
 
@@ -666,7 +668,7 @@ v9fs_create(struct v9fs_session_info *v9ses, struct inode *dir,
 	fid = p9_client_walk(dfid, 1, &name, 1);
 	if (IS_ERR(fid)) {
 		err = PTR_ERR(fid);
-		P9_DPRINTK(P9_DEBUG_VFS, "p9_client_walk failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "p9_client_walk failed %d\n", err);
 		fid = NULL;
 		goto error;
 	}
@@ -675,7 +677,7 @@ v9fs_create(struct v9fs_session_info *v9ses, struct inode *dir,
 	inode = v9fs_get_new_inode_from_fid(v9ses, fid, dir->i_sb);
 	if (IS_ERR(inode)) {
 		err = PTR_ERR(inode);
-		P9_DPRINTK(P9_DEBUG_VFS, "inode creation failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "inode creation failed %d\n", err);
 		goto error;
 	}
 	err = v9fs_fid_add(dentry, fid);
@@ -793,7 +795,7 @@ static int v9fs_vfs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
 	struct p9_fid *fid;
 	struct v9fs_session_info *v9ses;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "name %s\n", dentry->d_name.name);
+	p9_debug(P9_DEBUG_VFS, "name %s\n", dentry->d_name.name);
 	err = 0;
 	v9ses = v9fs_inode2v9ses(dir);
 	perm = unixmode2p9mode(v9ses, mode | S_IFDIR);
@@ -831,8 +833,8 @@ struct dentry *v9fs_vfs_lookup(struct inode *dir, struct dentry *dentry,
 	char *name;
 	int result = 0;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "dir: %p dentry: (%s) %p nameidata: %p\n",
-		dir, dentry->d_name.name, dentry, nameidata);
+	p9_debug(P9_DEBUG_VFS, "dir: %p dentry: (%s) %p nameidata: %p\n",
+		 dir, dentry->d_name.name, dentry, nameidata);
 
 	if (dentry->d_name.len > NAME_MAX)
 		return ERR_PTR(-ENAMETOOLONG);
@@ -938,7 +940,7 @@ v9fs_vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	struct p9_fid *newdirfid;
 	struct p9_wstat wstat;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "\n");
+	p9_debug(P9_DEBUG_VFS, "\n");
 	retval = 0;
 	old_inode = old_dentry->d_inode;
 	new_inode = new_dentry->d_inode;
@@ -974,8 +976,7 @@ v9fs_vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		 * 9P .u can only handle file rename in the same directory
 		 */
 
-		P9_DPRINTK(P9_DEBUG_ERROR,
-				"old dir and new dir are different\n");
+		p9_debug(P9_DEBUG_ERROR, "old dir and new dir are different\n");
 		retval = -EXDEV;
 		goto clunk_newdir;
 	}
@@ -1031,7 +1032,7 @@ v9fs_vfs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 	struct p9_fid *fid;
 	struct p9_wstat *st;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "dentry: %p\n", dentry);
+	p9_debug(P9_DEBUG_VFS, "dentry: %p\n", dentry);
 	err = -EPERM;
 	v9ses = v9fs_dentry2v9ses(dentry);
 	if (v9ses->cache == CACHE_LOOSE || v9ses->cache == CACHE_FSCACHE) {
@@ -1068,7 +1069,7 @@ static int v9fs_vfs_setattr(struct dentry *dentry, struct iattr *iattr)
 	struct p9_fid *fid;
 	struct p9_wstat wstat;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "\n");
+	p9_debug(P9_DEBUG_VFS, "\n");
 	retval = inode_change_ok(dentry->d_inode, iattr);
 	if (retval)
 		return retval;
@@ -1213,7 +1214,7 @@ static int v9fs_readlink(struct dentry *dentry, char *buffer, int buflen)
 	struct p9_fid *fid;
 	struct p9_wstat *st;
 
-	P9_DPRINTK(P9_DEBUG_VFS, " %s\n", dentry->d_name.name);
+	p9_debug(P9_DEBUG_VFS, " %s\n", dentry->d_name.name);
 	retval = -EPERM;
 	v9ses = v9fs_dentry2v9ses(dentry);
 	fid = v9fs_fid_lookup(dentry);
@@ -1235,8 +1236,8 @@ static int v9fs_readlink(struct dentry *dentry, char *buffer, int buflen)
 	/* copy extension buffer into buffer */
 	strncpy(buffer, st->extension, buflen);
 
-	P9_DPRINTK(P9_DEBUG_VFS,
-		"%s -> %s (%s)\n", dentry->d_name.name, st->extension, buffer);
+	p9_debug(P9_DEBUG_VFS, "%s -> %s (%s)\n",
+		 dentry->d_name.name, st->extension, buffer);
 
 	retval = strnlen(buffer, buflen);
 done:
@@ -1257,7 +1258,7 @@ static void *v9fs_vfs_follow_link(struct dentry *dentry, struct nameidata *nd)
 	int len = 0;
 	char *link = __getname();
 
-	P9_DPRINTK(P9_DEBUG_VFS, "%s n", dentry->d_name.name);
+	p9_debug(P9_DEBUG_VFS, "%s\n", dentry->d_name.name);
 
 	if (!link)
 		link = ERR_PTR(-ENOMEM);
@@ -1288,8 +1289,8 @@ v9fs_vfs_put_link(struct dentry *dentry, struct nameidata *nd, void *p)
 {
 	char *s = nd_get_link(nd);
 
-	P9_DPRINTK(P9_DEBUG_VFS, " %s %s\n", dentry->d_name.name,
-		IS_ERR(s) ? "<error>" : s);
+	p9_debug(P9_DEBUG_VFS, " %s %s\n",
+		 dentry->d_name.name, IS_ERR(s) ? "<error>" : s);
 	if (!IS_ERR(s))
 		__putname(s);
 }
@@ -1312,7 +1313,7 @@ static int v9fs_vfs_mkspecial(struct inode *dir, struct dentry *dentry,
 
 	v9ses = v9fs_inode2v9ses(dir);
 	if (!v9fs_proto_dotu(v9ses)) {
-		P9_DPRINTK(P9_DEBUG_ERROR, "not extended\n");
+		p9_debug(P9_DEBUG_ERROR, "not extended\n");
 		return -EPERM;
 	}
 
@@ -1340,8 +1341,8 @@ static int v9fs_vfs_mkspecial(struct inode *dir, struct dentry *dentry,
 static int
 v9fs_vfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 {
-	P9_DPRINTK(P9_DEBUG_VFS, " %lu,%s,%s\n", dir->i_ino,
-					dentry->d_name.name, symname);
+	p9_debug(P9_DEBUG_VFS, " %lu,%s,%s\n",
+		 dir->i_ino, dentry->d_name.name, symname);
 
 	return v9fs_vfs_mkspecial(dir, dentry, S_IFLNK, symname);
 }
@@ -1362,9 +1363,8 @@ v9fs_vfs_link(struct dentry *old_dentry, struct inode *dir,
 	char *name;
 	struct p9_fid *oldfid;
 
-	P9_DPRINTK(P9_DEBUG_VFS,
-		" %lu,%s,%s\n", dir->i_ino, dentry->d_name.name,
-		old_dentry->d_name.name);
+	p9_debug(P9_DEBUG_VFS, " %lu,%s,%s\n",
+		 dir->i_ino, dentry->d_name.name, old_dentry->d_name.name);
 
 	oldfid = v9fs_fid_clone(old_dentry);
 	if (IS_ERR(oldfid))
@@ -1403,9 +1403,9 @@ v9fs_vfs_mknod(struct inode *dir, struct dentry *dentry, int mode, dev_t rdev)
 	int retval;
 	char *name;
 
-	P9_DPRINTK(P9_DEBUG_VFS,
-		" %lu,%s mode: %x MAJOR: %u MINOR: %u\n", dir->i_ino,
-		dentry->d_name.name, mode, MAJOR(rdev), MINOR(rdev));
+	p9_debug(P9_DEBUG_VFS, " %lu,%s mode: %x MAJOR: %u MINOR: %u\n",
+		 dir->i_ino, dentry->d_name.name, mode,
+		 MAJOR(rdev), MINOR(rdev));
 
 	if (!new_valid_dev(rdev))
 		return -EINVAL;
diff --git a/fs/9p/vfs_inode_dotl.c b/fs/9p/vfs_inode_dotl.c
index 0b5745e..73488fb 100644
--- a/fs/9p/vfs_inode_dotl.c
+++ b/fs/9p/vfs_inode_dotl.c
@@ -283,13 +283,13 @@ v9fs_vfs_create_dotl(struct inode *dir, struct dentry *dentry, int omode,
 	}
 
 	name = (char *) dentry->d_name.name;
-	P9_DPRINTK(P9_DEBUG_VFS, "v9fs_vfs_create_dotl: name:%s flags:0x%x "
-			"mode:0x%x\n", name, flags, omode);
+	p9_debug(P9_DEBUG_VFS, "name:%s flags:0x%x mode:0x%x\n",
+		 name, flags, omode);
 
 	dfid = v9fs_fid_lookup(dentry->d_parent);
 	if (IS_ERR(dfid)) {
 		err = PTR_ERR(dfid);
-		P9_DPRINTK(P9_DEBUG_VFS, "fid lookup failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "fid lookup failed %d\n", err);
 		return err;
 	}
 
@@ -297,7 +297,7 @@ v9fs_vfs_create_dotl(struct inode *dir, struct dentry *dentry, int omode,
 	ofid = p9_client_walk(dfid, 0, NULL, 1);
 	if (IS_ERR(ofid)) {
 		err = PTR_ERR(ofid);
-		P9_DPRINTK(P9_DEBUG_VFS, "p9_client_walk failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "p9_client_walk failed %d\n", err);
 		return err;
 	}
 
@@ -307,16 +307,15 @@ v9fs_vfs_create_dotl(struct inode *dir, struct dentry *dentry, int omode,
 	/* Update mode based on ACL value */
 	err = v9fs_acl_mode(dir, &mode, &dacl, &pacl);
 	if (err) {
-		P9_DPRINTK(P9_DEBUG_VFS,
-			   "Failed to get acl values in creat %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "Failed to get acl values in creat %d\n",
+			 err);
 		goto error;
 	}
 	err = p9_client_create_dotl(ofid, name, v9fs_open_to_dotl_flags(flags),
 				    mode, gid, &qid);
 	if (err < 0) {
-		P9_DPRINTK(P9_DEBUG_VFS,
-				"p9_client_open_dotl failed in creat %d\n",
-				err);
+		p9_debug(P9_DEBUG_VFS, "p9_client_open_dotl failed in creat %d\n",
+			 err);
 		goto error;
 	}
 	v9fs_invalidate_inode_attr(dir);
@@ -325,14 +324,14 @@ v9fs_vfs_create_dotl(struct inode *dir, struct dentry *dentry, int omode,
 	fid = p9_client_walk(dfid, 1, &name, 1);
 	if (IS_ERR(fid)) {
 		err = PTR_ERR(fid);
-		P9_DPRINTK(P9_DEBUG_VFS, "p9_client_walk failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "p9_client_walk failed %d\n", err);
 		fid = NULL;
 		goto error;
 	}
 	inode = v9fs_get_new_inode_from_fid(v9ses, fid, dir->i_sb);
 	if (IS_ERR(inode)) {
 		err = PTR_ERR(inode);
-		P9_DPRINTK(P9_DEBUG_VFS, "inode creation failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "inode creation failed %d\n", err);
 		goto error;
 	}
 	err = v9fs_fid_add(dentry, fid);
@@ -408,7 +407,7 @@ static int v9fs_vfs_mkdir_dotl(struct inode *dir,
 	struct dentry *dir_dentry;
 	struct posix_acl *dacl = NULL, *pacl = NULL;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "name %s\n", dentry->d_name.name);
+	p9_debug(P9_DEBUG_VFS, "name %s\n", dentry->d_name.name);
 	err = 0;
 	v9ses = v9fs_inode2v9ses(dir);
 
@@ -420,7 +419,7 @@ static int v9fs_vfs_mkdir_dotl(struct inode *dir,
 	dfid = v9fs_fid_lookup(dir_dentry);
 	if (IS_ERR(dfid)) {
 		err = PTR_ERR(dfid);
-		P9_DPRINTK(P9_DEBUG_VFS, "fid lookup failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "fid lookup failed %d\n", err);
 		dfid = NULL;
 		goto error;
 	}
@@ -430,8 +429,8 @@ static int v9fs_vfs_mkdir_dotl(struct inode *dir,
 	/* Update mode based on ACL value */
 	err = v9fs_acl_mode(dir, &mode, &dacl, &pacl);
 	if (err) {
-		P9_DPRINTK(P9_DEBUG_VFS,
-			   "Failed to get acl values in mkdir %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "Failed to get acl values in mkdir %d\n",
+			 err);
 		goto error;
 	}
 	name = (char *) dentry->d_name.name;
@@ -444,8 +443,8 @@ static int v9fs_vfs_mkdir_dotl(struct inode *dir,
 		fid = p9_client_walk(dfid, 1, &name, 1);
 		if (IS_ERR(fid)) {
 			err = PTR_ERR(fid);
-			P9_DPRINTK(P9_DEBUG_VFS, "p9_client_walk failed %d\n",
-				err);
+			p9_debug(P9_DEBUG_VFS, "p9_client_walk failed %d\n",
+				 err);
 			fid = NULL;
 			goto error;
 		}
@@ -453,8 +452,8 @@ static int v9fs_vfs_mkdir_dotl(struct inode *dir,
 		inode = v9fs_get_new_inode_from_fid(v9ses, fid, dir->i_sb);
 		if (IS_ERR(inode)) {
 			err = PTR_ERR(inode);
-			P9_DPRINTK(P9_DEBUG_VFS, "inode creation failed %d\n",
-				err);
+			p9_debug(P9_DEBUG_VFS, "inode creation failed %d\n",
+				 err);
 			goto error;
 		}
 		err = v9fs_fid_add(dentry, fid);
@@ -495,7 +494,7 @@ v9fs_vfs_getattr_dotl(struct vfsmount *mnt, struct dentry *dentry,
 	struct p9_fid *fid;
 	struct p9_stat_dotl *st;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "dentry: %p\n", dentry);
+	p9_debug(P9_DEBUG_VFS, "dentry: %p\n", dentry);
 	err = -EPERM;
 	v9ses = v9fs_dentry2v9ses(dentry);
 	if (v9ses->cache == CACHE_LOOSE || v9ses->cache == CACHE_FSCACHE) {
@@ -537,7 +536,7 @@ int v9fs_vfs_setattr_dotl(struct dentry *dentry, struct iattr *iattr)
 	struct p9_fid *fid;
 	struct p9_iattr_dotl p9attr;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "\n");
+	p9_debug(P9_DEBUG_VFS, "\n");
 
 	retval = inode_change_ok(dentry->d_inode, iattr);
 	if (retval)
@@ -670,14 +669,13 @@ v9fs_vfs_symlink_dotl(struct inode *dir, struct dentry *dentry,
 	struct v9fs_session_info *v9ses;
 
 	name = (char *) dentry->d_name.name;
-	P9_DPRINTK(P9_DEBUG_VFS, "v9fs_vfs_symlink_dotl : %lu,%s,%s\n",
-			dir->i_ino, name, symname);
+	p9_debug(P9_DEBUG_VFS, "%lu,%s,%s\n", dir->i_ino, name, symname);
 	v9ses = v9fs_inode2v9ses(dir);
 
 	dfid = v9fs_fid_lookup(dentry->d_parent);
 	if (IS_ERR(dfid)) {
 		err = PTR_ERR(dfid);
-		P9_DPRINTK(P9_DEBUG_VFS, "fid lookup failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "fid lookup failed %d\n", err);
 		return err;
 	}
 
@@ -687,7 +685,7 @@ v9fs_vfs_symlink_dotl(struct inode *dir, struct dentry *dentry,
 	err = p9_client_symlink(dfid, name, (char *)symname, gid, &qid);
 
 	if (err < 0) {
-		P9_DPRINTK(P9_DEBUG_VFS, "p9_client_symlink failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "p9_client_symlink failed %d\n", err);
 		goto error;
 	}
 
@@ -697,8 +695,8 @@ v9fs_vfs_symlink_dotl(struct inode *dir, struct dentry *dentry,
 		fid = p9_client_walk(dfid, 1, &name, 1);
 		if (IS_ERR(fid)) {
 			err = PTR_ERR(fid);
-			P9_DPRINTK(P9_DEBUG_VFS, "p9_client_walk failed %d\n",
-					err);
+			p9_debug(P9_DEBUG_VFS, "p9_client_walk failed %d\n",
+				 err);
 			fid = NULL;
 			goto error;
 		}
@@ -707,8 +705,8 @@ v9fs_vfs_symlink_dotl(struct inode *dir, struct dentry *dentry,
 		inode = v9fs_get_new_inode_from_fid(v9ses, fid, dir->i_sb);
 		if (IS_ERR(inode)) {
 			err = PTR_ERR(inode);
-			P9_DPRINTK(P9_DEBUG_VFS, "inode creation failed %d\n",
-					err);
+			p9_debug(P9_DEBUG_VFS, "inode creation failed %d\n",
+				 err);
 			goto error;
 		}
 		err = v9fs_fid_add(dentry, fid);
@@ -751,9 +749,8 @@ v9fs_vfs_link_dotl(struct dentry *old_dentry, struct inode *dir,
 	struct p9_fid *dfid, *oldfid;
 	struct v9fs_session_info *v9ses;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "dir ino: %lu, old_name: %s, new_name: %s\n",
-			dir->i_ino, old_dentry->d_name.name,
-			dentry->d_name.name);
+	p9_debug(P9_DEBUG_VFS, "dir ino: %lu, old_name: %s, new_name: %s\n",
+		 dir->i_ino, old_dentry->d_name.name, dentry->d_name.name);
 
 	v9ses = v9fs_inode2v9ses(dir);
 	dir_dentry = v9fs_dentry_from_dir_inode(dir);
@@ -770,7 +767,7 @@ v9fs_vfs_link_dotl(struct dentry *old_dentry, struct inode *dir,
 	err = p9_client_link(dfid, oldfid, (char *)dentry->d_name.name);
 
 	if (err < 0) {
-		P9_DPRINTK(P9_DEBUG_VFS, "p9_client_link failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "p9_client_link failed %d\n", err);
 		return err;
 	}
 
@@ -813,9 +810,9 @@ v9fs_vfs_mknod_dotl(struct inode *dir, struct dentry *dentry, int omode,
 	struct dentry *dir_dentry;
 	struct posix_acl *dacl = NULL, *pacl = NULL;
 
-	P9_DPRINTK(P9_DEBUG_VFS,
-		" %lu,%s mode: %x MAJOR: %u MINOR: %u\n", dir->i_ino,
-		dentry->d_name.name, omode, MAJOR(rdev), MINOR(rdev));
+	p9_debug(P9_DEBUG_VFS, " %lu,%s mode: %x MAJOR: %u MINOR: %u\n",
+		 dir->i_ino, dentry->d_name.name, omode,
+		 MAJOR(rdev), MINOR(rdev));
 
 	if (!new_valid_dev(rdev))
 		return -EINVAL;
@@ -825,7 +822,7 @@ v9fs_vfs_mknod_dotl(struct inode *dir, struct dentry *dentry, int omode,
 	dfid = v9fs_fid_lookup(dir_dentry);
 	if (IS_ERR(dfid)) {
 		err = PTR_ERR(dfid);
-		P9_DPRINTK(P9_DEBUG_VFS, "fid lookup failed %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "fid lookup failed %d\n", err);
 		dfid = NULL;
 		goto error;
 	}
@@ -835,8 +832,8 @@ v9fs_vfs_mknod_dotl(struct inode *dir, struct dentry *dentry, int omode,
 	/* Update mode based on ACL value */
 	err = v9fs_acl_mode(dir, &mode, &dacl, &pacl);
 	if (err) {
-		P9_DPRINTK(P9_DEBUG_VFS,
-			   "Failed to get acl values in mknod %d\n", err);
+		p9_debug(P9_DEBUG_VFS, "Failed to get acl values in mknod %d\n",
+			 err);
 		goto error;
 	}
 	name = (char *) dentry->d_name.name;
@@ -851,8 +848,8 @@ v9fs_vfs_mknod_dotl(struct inode *dir, struct dentry *dentry, int omode,
 		fid = p9_client_walk(dfid, 1, &name, 1);
 		if (IS_ERR(fid)) {
 			err = PTR_ERR(fid);
-			P9_DPRINTK(P9_DEBUG_VFS, "p9_client_walk failed %d\n",
-				err);
+			p9_debug(P9_DEBUG_VFS, "p9_client_walk failed %d\n",
+				 err);
 			fid = NULL;
 			goto error;
 		}
@@ -860,8 +857,8 @@ v9fs_vfs_mknod_dotl(struct inode *dir, struct dentry *dentry, int omode,
 		inode = v9fs_get_new_inode_from_fid(v9ses, fid, dir->i_sb);
 		if (IS_ERR(inode)) {
 			err = PTR_ERR(inode);
-			P9_DPRINTK(P9_DEBUG_VFS, "inode creation failed %d\n",
-				err);
+			p9_debug(P9_DEBUG_VFS, "inode creation failed %d\n",
+				 err);
 			goto error;
 		}
 		err = v9fs_fid_add(dentry, fid);
@@ -905,7 +902,7 @@ v9fs_vfs_follow_link_dotl(struct dentry *dentry, struct nameidata *nd)
 	char *link = __getname();
 	char *target;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "%s\n", dentry->d_name.name);
+	p9_debug(P9_DEBUG_VFS, "%s\n", dentry->d_name.name);
 
 	if (!link) {
 		link = ERR_PTR(-ENOMEM);
diff --git a/fs/9p/vfs_super.c b/fs/9p/vfs_super.c
index c70251d..06d19735 100644
--- a/fs/9p/vfs_super.c
+++ b/fs/9p/vfs_super.c
@@ -121,7 +121,7 @@ static struct dentry *v9fs_mount(struct file_system_type *fs_type, int flags,
 	struct p9_fid *fid;
 	int retval = 0;
 
-	P9_DPRINTK(P9_DEBUG_VFS, " \n");
+	p9_debug(P9_DEBUG_VFS, "\n");
 
 	v9ses = kzalloc(sizeof(struct v9fs_session_info), GFP_KERNEL);
 	if (!v9ses)
@@ -191,7 +191,7 @@ static struct dentry *v9fs_mount(struct file_system_type *fs_type, int flags,
 		goto release_sb;
 	v9fs_fid_add(root, fid);
 
-	P9_DPRINTK(P9_DEBUG_VFS, " simple set mount, return 0\n");
+	p9_debug(P9_DEBUG_VFS, " simple set mount, return 0\n");
 	return dget(sb->s_root);
 
 clunk_fid:
@@ -223,7 +223,7 @@ static void v9fs_kill_super(struct super_block *s)
 {
 	struct v9fs_session_info *v9ses = s->s_fs_info;
 
-	P9_DPRINTK(P9_DEBUG_VFS, " %p\n", s);
+	p9_debug(P9_DEBUG_VFS, " %p\n", s);
 
 	kill_anon_super(s);
 
@@ -231,7 +231,7 @@ static void v9fs_kill_super(struct super_block *s)
 	v9fs_session_close(v9ses);
 	kfree(v9ses);
 	s->s_fs_info = NULL;
-	P9_DPRINTK(P9_DEBUG_VFS, "exiting kill_super\n");
+	p9_debug(P9_DEBUG_VFS, "exiting kill_super\n");
 }
 
 static void
@@ -303,7 +303,7 @@ static int v9fs_write_inode(struct inode *inode,
 	 * send an fsync request to server irrespective of
 	 * wbc->sync_mode.
 	 */
-	P9_DPRINTK(P9_DEBUG_VFS, "%s: inode %p\n", __func__, inode);
+	p9_debug(P9_DEBUG_VFS, "%s: inode %p\n", __func__, inode);
 	v9inode = V9FS_I(inode);
 	if (!v9inode->writeback_fid)
 		return 0;
@@ -326,7 +326,7 @@ static int v9fs_write_inode_dotl(struct inode *inode,
 	 * send an fsync request to server irrespective of
 	 * wbc->sync_mode.
 	 */
-	P9_DPRINTK(P9_DEBUG_VFS, "%s: inode %p\n", __func__, inode);
+	p9_debug(P9_DEBUG_VFS, "%s: inode %p\n", __func__, inode);
 	v9inode = V9FS_I(inode);
 	if (!v9inode->writeback_fid)
 		return 0;
diff --git a/fs/9p/xattr.c b/fs/9p/xattr.c
index d288773..29653b7 100644
--- a/fs/9p/xattr.c
+++ b/fs/9p/xattr.c
@@ -32,8 +32,8 @@ ssize_t v9fs_fid_xattr_get(struct p9_fid *fid, const char *name,
 	attr_fid = p9_client_xattrwalk(fid, name, &attr_size);
 	if (IS_ERR(attr_fid)) {
 		retval = PTR_ERR(attr_fid);
-		P9_DPRINTK(P9_DEBUG_VFS,
-			"p9_client_attrwalk failed %zd\n", retval);
+		p9_debug(P9_DEBUG_VFS, "p9_client_attrwalk failed %zd\n",
+			 retval);
 		attr_fid = NULL;
 		goto error;
 	}
@@ -87,8 +87,8 @@ ssize_t v9fs_xattr_get(struct dentry *dentry, const char *name,
 {
 	struct p9_fid *fid;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "%s: name = %s value_len = %zu\n",
-		__func__, name, buffer_size);
+	p9_debug(P9_DEBUG_VFS, "name = %s value_len = %zu\n",
+		 name, buffer_size);
 	fid = v9fs_fid_lookup(dentry);
 	if (IS_ERR(fid))
 		return PTR_ERR(fid);
@@ -115,8 +115,8 @@ int v9fs_xattr_set(struct dentry *dentry, const char *name,
 	int retval, msize, write_count;
 	struct p9_fid *fid = NULL;
 
-	P9_DPRINTK(P9_DEBUG_VFS, "%s: name = %s value_len = %zu flags = %d\n",
-		__func__, name, value_len, flags);
+	p9_debug(P9_DEBUG_VFS, "name = %s value_len = %zu flags = %d\n",
+		 name, value_len, flags);
 
 	fid = v9fs_fid_clone(dentry);
 	if (IS_ERR(fid)) {
@@ -129,8 +129,8 @@ int v9fs_xattr_set(struct dentry *dentry, const char *name,
 	 */
 	retval = p9_client_xattrcreate(fid, name, value_len, flags);
 	if (retval < 0) {
-		P9_DPRINTK(P9_DEBUG_VFS,
-			"p9_client_xattrcreate failed %d\n", retval);
+		p9_debug(P9_DEBUG_VFS, "p9_client_xattrcreate failed %d\n",
+			 retval);
 		goto error;
 	}
 	msize = fid->clnt->msize;
diff --git a/include/net/9p/9p.h b/include/net/9p/9p.h
index 2d70b95..7184853 100644
--- a/include/net/9p/9p.h
+++ b/include/net/9p/9p.h
@@ -63,30 +63,16 @@ enum p9_debug_flags {
 
 #ifdef CONFIG_NET_9P_DEBUG
 extern unsigned int p9_debug_level;
-
-#define P9_DPRINTK(level, format, arg...) \
-do {  \
-	if ((p9_debug_level & level) == level) {\
-		if (level == P9_DEBUG_9P) \
-			printk(KERN_NOTICE "(%8.8d) " \
-			format , task_pid_nr(current) , ## arg); \
-		else \
-			printk(KERN_NOTICE "-- %s (%d): " \
-			format , __func__, task_pid_nr(current) , ## arg); \
-	} \
-} while (0)
-
+__printf(3, 4)
+void _p9_debug(enum p9_debug_flags level, const char *func,
+	       const char *fmt, ...);
+#define p9_debug(level, fmt, ...)			\
+	_p9_debug(level, __func__, fmt, ##__VA_ARGS__)
 #else
-#define P9_DPRINTK(level, format, arg...)  do { } while (0)
+#define p9_debug(level, fmt, ...)			\
+	no_printk(fmt, ##__VA_ARGS__)
 #endif
 
-
-#define P9_EPRINTK(level, format, arg...) \
-do { \
-	printk(level "9p: %s (%d): " \
-		format , __func__, task_pid_nr(current), ## arg); \
-} while (0)
-
 /**
  * enum p9_msg_t - 9P message types
  * @P9_TLERROR: not used
diff --git a/net/9p/client.c b/net/9p/client.c
index 854ca7a..776618c 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -23,6 +23,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/fs.h>
@@ -81,15 +83,15 @@ static int get_protocol_version(char *s)
 
 	if (!strcmp(s, "9p2000")) {
 		version = p9_proto_legacy;
-		P9_DPRINTK(P9_DEBUG_9P, "Protocol version: Legacy\n");
+		p9_debug(P9_DEBUG_9P, "Protocol version: Legacy\n");
 	} else if (!strcmp(s, "9p2000.u")) {
 		version = p9_proto_2000u;
-		P9_DPRINTK(P9_DEBUG_9P, "Protocol version: 9P2000.u\n");
+		p9_debug(P9_DEBUG_9P, "Protocol version: 9P2000.u\n");
 	} else if (!strcmp(s, "9p2000.L")) {
 		version = p9_proto_2000L;
-		P9_DPRINTK(P9_DEBUG_9P, "Protocol version: 9P2000.L\n");
+		p9_debug(P9_DEBUG_9P, "Protocol version: 9P2000.L\n");
 	} else
-		printk(KERN_INFO "9p: Unknown protocol version %s.\n", s);
+		pr_info("Unknown protocol version %s\n", s);
 
 	return version;
 }
@@ -119,8 +121,8 @@ static int parse_opts(char *opts, struct p9_client *clnt)
 
 	tmp_options = kstrdup(opts, GFP_KERNEL);
 	if (!tmp_options) {
-		P9_DPRINTK(P9_DEBUG_ERROR,
-				"failed to allocate copy of option string\n");
+		p9_debug(P9_DEBUG_ERROR,
+			 "failed to allocate copy of option string\n");
 		return -ENOMEM;
 	}
 	options = tmp_options;
@@ -134,8 +136,8 @@ static int parse_opts(char *opts, struct p9_client *clnt)
 		case Opt_msize:
 			r = match_int(&args[0], &option);
 			if (r < 0) {
-				P9_DPRINTK(P9_DEBUG_ERROR,
-					   "integer field, but no integer?\n");
+				p9_debug(P9_DEBUG_ERROR,
+					 "integer field, but no integer?\n");
 				ret = r;
 				continue;
 			}
@@ -145,15 +147,14 @@ static int parse_opts(char *opts, struct p9_client *clnt)
 			s = match_strdup(&args[0]);
 			if (!s) {
 				ret = -ENOMEM;
-				P9_DPRINTK(P9_DEBUG_ERROR,
-					"problem allocating copy of trans arg\n");
+				p9_debug(P9_DEBUG_ERROR,
+					 "problem allocating copy of trans arg\n");
 				goto free_and_return;
 			 }
 			clnt->trans_mod = v9fs_get_trans_by_name(s);
 			if (clnt->trans_mod == NULL) {
-				printk(KERN_INFO
-					"9p: Could not find "
-					"request transport: %s\n", s);
+				pr_info("Could not find request transport: %s\n",
+					s);
 				ret = -EINVAL;
 				kfree(s);
 				goto free_and_return;
@@ -167,8 +168,8 @@ static int parse_opts(char *opts, struct p9_client *clnt)
 			s = match_strdup(&args[0]);
 			if (!s) {
 				ret = -ENOMEM;
-				P9_DPRINTK(P9_DEBUG_ERROR,
-					"problem allocating copy of version arg\n");
+				p9_debug(P9_DEBUG_ERROR,
+					 "problem allocating copy of version arg\n");
 				goto free_and_return;
 			}
 			ret = get_protocol_version(s);
@@ -225,7 +226,7 @@ p9_tag_alloc(struct p9_client *c, u16 tag, unsigned int max_size)
 					sizeof(struct p9_req_t), GFP_ATOMIC);
 
 			if (!c->reqs[row]) {
-				printk(KERN_ERR "Couldn't grow tag array\n");
+				pr_err("Couldn't grow tag array\n");
 				spin_unlock_irqrestore(&c->lock, flags);
 				return ERR_PTR(-ENOMEM);
 			}
@@ -244,7 +245,7 @@ p9_tag_alloc(struct p9_client *c, u16 tag, unsigned int max_size)
 	if (!req->tc) {
 		req->wq = kmalloc(sizeof(wait_queue_head_t), GFP_NOFS);
 		if (!req->wq) {
-			printk(KERN_ERR "Couldn't grow tag array\n");
+			pr_err("Couldn't grow tag array\n");
 			return ERR_PTR(-ENOMEM);
 		}
 		init_waitqueue_head(req->wq);
@@ -253,7 +254,7 @@ p9_tag_alloc(struct p9_client *c, u16 tag, unsigned int max_size)
 		req->rc = kmalloc(sizeof(struct p9_fcall) + alloc_msize,
 				  GFP_NOFS);
 		if ((!req->tc) || (!req->rc)) {
-			printk(KERN_ERR "Couldn't grow tag array\n");
+			pr_err("Couldn't grow tag array\n");
 			kfree(req->tc);
 			kfree(req->rc);
 			kfree(req->wq);
@@ -343,9 +344,9 @@ static void p9_tag_cleanup(struct p9_client *c)
 	for (row = 0; row < (c->max_tag/P9_ROW_MAXTAG); row++) {
 		for (col = 0; col < P9_ROW_MAXTAG; col++) {
 			if (c->reqs[row][col].status != REQ_STATUS_IDLE) {
-				P9_DPRINTK(P9_DEBUG_MUX,
-				  "Attempting to cleanup non-free tag %d,%d\n",
-				  row, col);
+				p9_debug(P9_DEBUG_MUX,
+					 "Attempting to cleanup non-free tag %d,%d\n",
+					 row, col);
 				/* TODO: delay execution of cleanup */
 				return;
 			}
@@ -379,7 +380,7 @@ static void p9_tag_cleanup(struct p9_client *c)
 static void p9_free_req(struct p9_client *c, struct p9_req_t *r)
 {
 	int tag = r->tc->tag;
-	P9_DPRINTK(P9_DEBUG_MUX, "clnt %p req %p tag: %d\n", c, r, tag);
+	p9_debug(P9_DEBUG_MUX, "clnt %p req %p tag: %d\n", c, r, tag);
 
 	r->status = REQ_STATUS_IDLE;
 	if (tag != P9_NOTAG && p9_idpool_check(tag, c->tagpool))
@@ -394,9 +395,9 @@ static void p9_free_req(struct p9_client *c, struct p9_req_t *r)
  */
 void p9_client_cb(struct p9_client *c, struct p9_req_t *req)
 {
-	P9_DPRINTK(P9_DEBUG_MUX, " tag %d\n", req->tc->tag);
+	p9_debug(P9_DEBUG_MUX, " tag %d\n", req->tc->tag);
 	wake_up(req->wq);
-	P9_DPRINTK(P9_DEBUG_MUX, "wakeup: %d\n", req->tc->tag);
+	p9_debug(P9_DEBUG_MUX, "wakeup: %d\n", req->tc->tag);
 }
 EXPORT_SYMBOL(p9_client_cb);
 
@@ -431,8 +432,8 @@ p9_parse_header(struct p9_fcall *pdu, int32_t *size, int8_t *type, int16_t *tag,
 	pdu->id = r_type;
 	pdu->tag = r_tag;
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< size=%d type: %d tag: %d\n", pdu->size,
-							pdu->id, pdu->tag);
+	p9_debug(P9_DEBUG_9P, "<<< size=%d type: %d tag: %d\n",
+		 pdu->size, pdu->id, pdu->tag);
 
 	if (type)
 		*type = r_type;
@@ -473,7 +474,7 @@ static int p9_check_errors(struct p9_client *c, struct p9_req_t *req)
 	 */
 	trace_9p_protocol_dump(c, req->rc);
 	if (err) {
-		P9_DPRINTK(P9_DEBUG_ERROR, "couldn't parse header %d\n", err);
+		p9_debug(P9_DEBUG_ERROR, "couldn't parse header %d\n", err);
 		return err;
 	}
 	if (type != P9_RERROR && type != P9_RLERROR)
@@ -492,21 +493,21 @@ static int p9_check_errors(struct p9_client *c, struct p9_req_t *req)
 		if (!err || !IS_ERR_VALUE(err)) {
 			err = p9_errstr2errno(ename, strlen(ename));
 
-			P9_DPRINTK(P9_DEBUG_9P, "<<< RERROR (%d) %s\n",
-				   -ecode, ename);
+			p9_debug(P9_DEBUG_9P, "<<< RERROR (%d) %s\n",
+				 -ecode, ename);
 		}
 		kfree(ename);
 	} else {
 		err = p9pdu_readf(req->rc, c->proto_version, "d", &ecode);
 		err = -ecode;
 
-		P9_DPRINTK(P9_DEBUG_9P, "<<< RLERROR (%d)\n", -ecode);
+		p9_debug(P9_DEBUG_9P, "<<< RLERROR (%d)\n", -ecode);
 	}
 
 	return err;
 
 out_err:
-	P9_DPRINTK(P9_DEBUG_ERROR, "couldn't parse error%d\n", err);
+	p9_debug(P9_DEBUG_ERROR, "couldn't parse error%d\n", err);
 
 	return err;
 }
@@ -538,7 +539,7 @@ static int p9_check_zc_errors(struct p9_client *c, struct p9_req_t *req,
 	 */
 	trace_9p_protocol_dump(c, req->rc);
 	if (err) {
-		P9_DPRINTK(P9_DEBUG_ERROR, "couldn't parse header %d\n", err);
+		p9_debug(P9_DEBUG_ERROR, "couldn't parse header %d\n", err);
 		return err;
 	}
 
@@ -601,22 +602,22 @@ static int p9_check_zc_errors(struct p9_client *c, struct p9_req_t *req,
 		if (!err || !IS_ERR_VALUE(err)) {
 			err = p9_errstr2errno(ename, strlen(ename));
 
-			P9_DPRINTK(P9_DEBUG_9P, "<<< RERROR (%d) %s\n",
-				   -ecode, ename);
+			p9_debug(P9_DEBUG_9P, "<<< RERROR (%d) %s\n",
+				 -ecode, ename);
 		}
 		kfree(ename);
 	} else {
 		err = p9pdu_readf(req->rc, c->proto_version, "d", &ecode);
 		err = -ecode;
 
-		P9_DPRINTK(P9_DEBUG_9P, "<<< RLERROR (%d)\n", -ecode);
+		p9_debug(P9_DEBUG_9P, "<<< RLERROR (%d)\n", -ecode);
 	}
 	return err;
 
 out_free:
 	kfree(ename);
 out_err:
-	P9_DPRINTK(P9_DEBUG_ERROR, "couldn't parse error%d\n", err);
+	p9_debug(P9_DEBUG_ERROR, "couldn't parse error%d\n", err);
 	return err;
 }
 
@@ -645,7 +646,7 @@ static int p9_client_flush(struct p9_client *c, struct p9_req_t *oldreq)
 	if (err)
 		return err;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TFLUSH tag %d\n", oldtag);
+	p9_debug(P9_DEBUG_9P, ">>> TFLUSH tag %d\n", oldtag);
 
 	req = p9_client_rpc(c, P9_TFLUSH, "w", oldtag);
 	if (IS_ERR(req))
@@ -670,7 +671,7 @@ static struct p9_req_t *p9_client_prepare_req(struct p9_client *c,
 	int tag, err;
 	struct p9_req_t *req;
 
-	P9_DPRINTK(P9_DEBUG_MUX, "client %p op %d\n", c, type);
+	p9_debug(P9_DEBUG_MUX, "client %p op %d\n", c, type);
 
 	/* we allow for any status other than disconnected */
 	if (c->status == Disconnected)
@@ -744,11 +745,11 @@ p9_client_rpc(struct p9_client *c, int8_t type, const char *fmt, ...)
 				       req->status >= REQ_STATUS_RCVD);
 
 	if (req->status == REQ_STATUS_ERROR) {
-		P9_DPRINTK(P9_DEBUG_ERROR, "req_status error %d\n", req->t_err);
+		p9_debug(P9_DEBUG_ERROR, "req_status error %d\n", req->t_err);
 		err = req->t_err;
 	}
 	if ((err == -ERESTARTSYS) && (c->status == Connected)) {
-		P9_DPRINTK(P9_DEBUG_MUX, "flushing\n");
+		p9_debug(P9_DEBUG_MUX, "flushing\n");
 		sigpending = 1;
 		clear_thread_flag(TIF_SIGPENDING);
 
@@ -827,11 +828,11 @@ static struct p9_req_t *p9_client_zc_rpc(struct p9_client *c, int8_t type,
 		goto reterr;
 	}
 	if (req->status == REQ_STATUS_ERROR) {
-		P9_DPRINTK(P9_DEBUG_ERROR, "req_status error %d\n", req->t_err);
+		p9_debug(P9_DEBUG_ERROR, "req_status error %d\n", req->t_err);
 		err = req->t_err;
 	}
 	if ((err == -ERESTARTSYS) && (c->status == Connected)) {
-		P9_DPRINTK(P9_DEBUG_MUX, "flushing\n");
+		p9_debug(P9_DEBUG_MUX, "flushing\n");
 		sigpending = 1;
 		clear_thread_flag(TIF_SIGPENDING);
 
@@ -865,7 +866,7 @@ static struct p9_fid *p9_fid_create(struct p9_client *clnt)
 	struct p9_fid *fid;
 	unsigned long flags;
 
-	P9_DPRINTK(P9_DEBUG_FID, "clnt %p\n", clnt);
+	p9_debug(P9_DEBUG_FID, "clnt %p\n", clnt);
 	fid = kmalloc(sizeof(struct p9_fid), GFP_KERNEL);
 	if (!fid)
 		return ERR_PTR(-ENOMEM);
@@ -898,7 +899,7 @@ static void p9_fid_destroy(struct p9_fid *fid)
 	struct p9_client *clnt;
 	unsigned long flags;
 
-	P9_DPRINTK(P9_DEBUG_FID, "fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_FID, "fid %d\n", fid->fid);
 	clnt = fid->clnt;
 	p9_idpool_put(fid->fid, clnt->fidpool);
 	spin_lock_irqsave(&clnt->lock, flags);
@@ -915,8 +916,8 @@ static int p9_client_version(struct p9_client *c)
 	char *version;
 	int msize;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TVERSION msize %d protocol %d\n",
-						c->msize, c->proto_version);
+	p9_debug(P9_DEBUG_9P, ">>> TVERSION msize %d protocol %d\n",
+		 c->msize, c->proto_version);
 
 	switch (c->proto_version) {
 	case p9_proto_2000L:
@@ -941,12 +942,12 @@ static int p9_client_version(struct p9_client *c)
 
 	err = p9pdu_readf(req->rc, c->proto_version, "ds", &msize, &version);
 	if (err) {
-		P9_DPRINTK(P9_DEBUG_9P, "version error %d\n", err);
+		p9_debug(P9_DEBUG_9P, "version error %d\n", err);
 		trace_9p_protocol_dump(c, req->rc);
 		goto error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RVERSION msize %d %s\n", msize, version);
+	p9_debug(P9_DEBUG_9P, "<<< RVERSION msize %d %s\n", msize, version);
 	if (!strncmp(version, "9P2000.L", 8))
 		c->proto_version = p9_proto_2000L;
 	else if (!strncmp(version, "9P2000.u", 8))
@@ -996,8 +997,8 @@ struct p9_client *p9_client_create(const char *dev_name, char *options)
 
 	if (clnt->trans_mod == NULL) {
 		err = -EPROTONOSUPPORT;
-		P9_DPRINTK(P9_DEBUG_ERROR,
-				"No transport defined or default transport\n");
+		p9_debug(P9_DEBUG_ERROR,
+			 "No transport defined or default transport\n");
 		goto destroy_tagpool;
 	}
 
@@ -1007,8 +1008,8 @@ struct p9_client *p9_client_create(const char *dev_name, char *options)
 		goto put_trans;
 	}
 
-	P9_DPRINTK(P9_DEBUG_MUX, "clnt %p trans %p msize %d protocol %d\n",
-		clnt, clnt->trans_mod, clnt->msize, clnt->proto_version);
+	p9_debug(P9_DEBUG_MUX, "clnt %p trans %p msize %d protocol %d\n",
+		 clnt, clnt->trans_mod, clnt->msize, clnt->proto_version);
 
 	err = clnt->trans_mod->create(clnt, dev_name, options);
 	if (err)
@@ -1041,7 +1042,7 @@ void p9_client_destroy(struct p9_client *clnt)
 {
 	struct p9_fid *fid, *fidptr;
 
-	P9_DPRINTK(P9_DEBUG_MUX, "clnt %p\n", clnt);
+	p9_debug(P9_DEBUG_MUX, "clnt %p\n", clnt);
 
 	if (clnt->trans_mod)
 		clnt->trans_mod->close(clnt);
@@ -1049,7 +1050,7 @@ void p9_client_destroy(struct p9_client *clnt)
 	v9fs_put_trans(clnt->trans_mod);
 
 	list_for_each_entry_safe(fid, fidptr, &clnt->fidlist, flist) {
-		printk(KERN_INFO "Found fid %d not clunked\n", fid->fid);
+		pr_info("Found fid %d not clunked\n", fid->fid);
 		p9_fid_destroy(fid);
 	}
 
@@ -1064,14 +1065,14 @@ EXPORT_SYMBOL(p9_client_destroy);
 
 void p9_client_disconnect(struct p9_client *clnt)
 {
-	P9_DPRINTK(P9_DEBUG_9P, "clnt %p\n", clnt);
+	p9_debug(P9_DEBUG_9P, "clnt %p\n", clnt);
 	clnt->status = Disconnected;
 }
 EXPORT_SYMBOL(p9_client_disconnect);
 
 void p9_client_begin_disconnect(struct p9_client *clnt)
 {
-	P9_DPRINTK(P9_DEBUG_9P, "clnt %p\n", clnt);
+	p9_debug(P9_DEBUG_9P, "clnt %p\n", clnt);
 	clnt->status = BeginDisconnect;
 }
 EXPORT_SYMBOL(p9_client_begin_disconnect);
@@ -1085,8 +1086,8 @@ struct p9_fid *p9_client_attach(struct p9_client *clnt, struct p9_fid *afid,
 	struct p9_qid qid;
 
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TATTACH afid %d uname %s aname %s\n",
-		   afid ? afid->fid : -1, uname, aname);
+	p9_debug(P9_DEBUG_9P, ">>> TATTACH afid %d uname %s aname %s\n",
+		 afid ? afid->fid : -1, uname, aname);
 	fid = p9_fid_create(clnt);
 	if (IS_ERR(fid)) {
 		err = PTR_ERR(fid);
@@ -1108,10 +1109,8 @@ struct p9_fid *p9_client_attach(struct p9_client *clnt, struct p9_fid *afid,
 		goto error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RATTACH qid %x.%llx.%x\n",
-					qid.type,
-					(unsigned long long)qid.path,
-					qid.version);
+	p9_debug(P9_DEBUG_9P, "<<< RATTACH qid %x.%llx.%x\n",
+		 qid.type, (unsigned long long)qid.path, qid.version);
 
 	memmove(&fid->qid, &qid, sizeof(struct p9_qid));
 
@@ -1151,8 +1150,8 @@ struct p9_fid *p9_client_walk(struct p9_fid *oldfid, uint16_t nwname,
 		fid = oldfid;
 
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TWALK fids %d,%d nwname %ud wname[0] %s\n",
-		oldfid->fid, fid->fid, nwname, wnames ? wnames[0] : NULL);
+	p9_debug(P9_DEBUG_9P, ">>> TWALK fids %d,%d nwname %ud wname[0] %s\n",
+		 oldfid->fid, fid->fid, nwname, wnames ? wnames[0] : NULL);
 
 	req = p9_client_rpc(clnt, P9_TWALK, "ddT", oldfid->fid, fid->fid,
 								nwname, wnames);
@@ -1169,7 +1168,7 @@ struct p9_fid *p9_client_walk(struct p9_fid *oldfid, uint16_t nwname,
 	}
 	p9_free_req(clnt, req);
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RWALK nwqid %d:\n", nwqids);
+	p9_debug(P9_DEBUG_9P, "<<< RWALK nwqid %d:\n", nwqids);
 
 	if (nwqids != nwname) {
 		err = -ENOENT;
@@ -1177,7 +1176,7 @@ struct p9_fid *p9_client_walk(struct p9_fid *oldfid, uint16_t nwname,
 	}
 
 	for (count = 0; count < nwqids; count++)
-		P9_DPRINTK(P9_DEBUG_9P, "<<<     [%d] %x.%llx.%x\n",
+		p9_debug(P9_DEBUG_9P, "<<<     [%d] %x.%llx.%x\n",
 			count, wqids[count].type,
 			(unsigned long long)wqids[count].path,
 			wqids[count].version);
@@ -1212,7 +1211,7 @@ int p9_client_open(struct p9_fid *fid, int mode)
 	int iounit;
 
 	clnt = fid->clnt;
-	P9_DPRINTK(P9_DEBUG_9P, ">>> %s fid %d mode %d\n",
+	p9_debug(P9_DEBUG_9P, ">>> %s fid %d mode %d\n",
 		p9_is_proto_dotl(clnt) ? "TLOPEN" : "TOPEN", fid->fid, mode);
 	err = 0;
 
@@ -1234,7 +1233,7 @@ int p9_client_open(struct p9_fid *fid, int mode)
 		goto free_and_error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< %s qid %x.%llx.%x iounit %x\n",
+	p9_debug(P9_DEBUG_9P, "<<< %s qid %x.%llx.%x iounit %x\n",
 		p9_is_proto_dotl(clnt) ? "RLOPEN" : "ROPEN",  qid.type,
 		(unsigned long long)qid.path, qid.version, iounit);
 
@@ -1256,7 +1255,7 @@ int p9_client_create_dotl(struct p9_fid *ofid, char *name, u32 flags, u32 mode,
 	struct p9_req_t *req;
 	int iounit;
 
-	P9_DPRINTK(P9_DEBUG_9P,
+	p9_debug(P9_DEBUG_9P,
 			">>> TLCREATE fid %d name %s flags %d mode %d gid %d\n",
 			ofid->fid, name, flags, mode, gid);
 	clnt = ofid->clnt;
@@ -1277,7 +1276,7 @@ int p9_client_create_dotl(struct p9_fid *ofid, char *name, u32 flags, u32 mode,
 		goto free_and_error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RLCREATE qid %x.%llx.%x iounit %x\n",
+	p9_debug(P9_DEBUG_9P, "<<< RLCREATE qid %x.%llx.%x iounit %x\n",
 			qid->type,
 			(unsigned long long)qid->path,
 			qid->version, iounit);
@@ -1301,7 +1300,7 @@ int p9_client_fcreate(struct p9_fid *fid, char *name, u32 perm, int mode,
 	struct p9_qid qid;
 	int iounit;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TCREATE fid %d name %s perm %d mode %d\n",
+	p9_debug(P9_DEBUG_9P, ">>> TCREATE fid %d name %s perm %d mode %d\n",
 						fid->fid, name, perm, mode);
 	err = 0;
 	clnt = fid->clnt;
@@ -1322,7 +1321,7 @@ int p9_client_fcreate(struct p9_fid *fid, char *name, u32 perm, int mode,
 		goto free_and_error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RCREATE qid %x.%llx.%x iounit %x\n",
+	p9_debug(P9_DEBUG_9P, "<<< RCREATE qid %x.%llx.%x iounit %x\n",
 				qid.type,
 				(unsigned long long)qid.path,
 				qid.version, iounit);
@@ -1344,7 +1343,7 @@ int p9_client_symlink(struct p9_fid *dfid, char *name, char *symtgt, gid_t gid,
 	struct p9_client *clnt;
 	struct p9_req_t *req;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TSYMLINK dfid %d name %s  symtgt %s\n",
+	p9_debug(P9_DEBUG_9P, ">>> TSYMLINK dfid %d name %s  symtgt %s\n",
 			dfid->fid, name, symtgt);
 	clnt = dfid->clnt;
 
@@ -1361,7 +1360,7 @@ int p9_client_symlink(struct p9_fid *dfid, char *name, char *symtgt, gid_t gid,
 		goto free_and_error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RSYMLINK qid %x.%llx.%x\n",
+	p9_debug(P9_DEBUG_9P, "<<< RSYMLINK qid %x.%llx.%x\n",
 			qid->type, (unsigned long long)qid->path, qid->version);
 
 free_and_error:
@@ -1376,7 +1375,7 @@ int p9_client_link(struct p9_fid *dfid, struct p9_fid *oldfid, char *newname)
 	struct p9_client *clnt;
 	struct p9_req_t *req;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TLINK dfid %d oldfid %d newname %s\n",
+	p9_debug(P9_DEBUG_9P, ">>> TLINK dfid %d oldfid %d newname %s\n",
 			dfid->fid, oldfid->fid, newname);
 	clnt = dfid->clnt;
 	req = p9_client_rpc(clnt, P9_TLINK, "dds", dfid->fid, oldfid->fid,
@@ -1384,7 +1383,7 @@ int p9_client_link(struct p9_fid *dfid, struct p9_fid *oldfid, char *newname)
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RLINK\n");
+	p9_debug(P9_DEBUG_9P, "<<< RLINK\n");
 	p9_free_req(clnt, req);
 	return 0;
 }
@@ -1396,7 +1395,7 @@ int p9_client_fsync(struct p9_fid *fid, int datasync)
 	struct p9_client *clnt;
 	struct p9_req_t *req;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TFSYNC fid %d datasync:%d\n",
+	p9_debug(P9_DEBUG_9P, ">>> TFSYNC fid %d datasync:%d\n",
 			fid->fid, datasync);
 	err = 0;
 	clnt = fid->clnt;
@@ -1407,7 +1406,7 @@ int p9_client_fsync(struct p9_fid *fid, int datasync)
 		goto error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RFSYNC fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P, "<<< RFSYNC fid %d\n", fid->fid);
 
 	p9_free_req(clnt, req);
 
@@ -1423,12 +1422,13 @@ int p9_client_clunk(struct p9_fid *fid)
 	struct p9_req_t *req;
 
 	if (!fid) {
-		P9_EPRINTK(KERN_WARNING, "Trying to clunk with NULL fid\n");
+		pr_warn("%s (%d): Trying to clunk with NULL fid\n",
+			__func__, task_pid_nr(current));
 		dump_stack();
 		return 0;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TCLUNK fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P, ">>> TCLUNK fid %d\n", fid->fid);
 	err = 0;
 	clnt = fid->clnt;
 
@@ -1438,7 +1438,7 @@ int p9_client_clunk(struct p9_fid *fid)
 		goto error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RCLUNK fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P, "<<< RCLUNK fid %d\n", fid->fid);
 
 	p9_free_req(clnt, req);
 error:
@@ -1456,7 +1456,7 @@ int p9_client_remove(struct p9_fid *fid)
 	struct p9_client *clnt;
 	struct p9_req_t *req;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TREMOVE fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P, ">>> TREMOVE fid %d\n", fid->fid);
 	err = 0;
 	clnt = fid->clnt;
 
@@ -1466,7 +1466,7 @@ int p9_client_remove(struct p9_fid *fid)
 		goto error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RREMOVE fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P, "<<< RREMOVE fid %d\n", fid->fid);
 
 	p9_free_req(clnt, req);
 error:
@@ -1481,7 +1481,7 @@ int p9_client_unlinkat(struct p9_fid *dfid, const char *name, int flags)
 	struct p9_req_t *req;
 	struct p9_client *clnt;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TUNLINKAT fid %d %s %d\n",
+	p9_debug(P9_DEBUG_9P, ">>> TUNLINKAT fid %d %s %d\n",
 		   dfid->fid, name, flags);
 
 	clnt = dfid->clnt;
@@ -1490,7 +1490,7 @@ int p9_client_unlinkat(struct p9_fid *dfid, const char *name, int flags)
 		err = PTR_ERR(req);
 		goto error;
 	}
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RUNLINKAT fid %d %s\n", dfid->fid, name);
+	p9_debug(P9_DEBUG_9P, "<<< RUNLINKAT fid %d %s\n", dfid->fid, name);
 
 	p9_free_req(clnt, req);
 error:
@@ -1509,7 +1509,7 @@ p9_client_read(struct p9_fid *fid, char *data, char __user *udata, u64 offset,
 	int err, rsize, non_zc = 0;
 
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TREAD fid %d offset %llu %d\n",
+	p9_debug(P9_DEBUG_9P, ">>> TREAD fid %d offset %llu %d\n",
 		   fid->fid, (long long unsigned) offset, count);
 	err = 0;
 	clnt = fid->clnt;
@@ -1552,7 +1552,7 @@ p9_client_read(struct p9_fid *fid, char *data, char __user *udata, u64 offset,
 		goto free_and_error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RREAD count %d\n", count);
+	p9_debug(P9_DEBUG_9P, "<<< RREAD count %d\n", count);
 
 	if (non_zc) {
 		if (data) {
@@ -1584,7 +1584,7 @@ p9_client_write(struct p9_fid *fid, char *data, const char __user *udata,
 	struct p9_client *clnt;
 	struct p9_req_t *req;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TWRITE fid %d offset %llu count %d\n",
+	p9_debug(P9_DEBUG_9P, ">>> TWRITE fid %d offset %llu count %d\n",
 				fid->fid, (long long unsigned) offset, count);
 	err = 0;
 	clnt = fid->clnt;
@@ -1626,7 +1626,7 @@ p9_client_write(struct p9_fid *fid, char *data, const char __user *udata,
 		goto free_and_error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RWRITE count %d\n", count);
+	p9_debug(P9_DEBUG_9P, "<<< RWRITE count %d\n", count);
 
 	p9_free_req(clnt, req);
 	return count;
@@ -1646,7 +1646,7 @@ struct p9_wstat *p9_client_stat(struct p9_fid *fid)
 	struct p9_req_t *req;
 	u16 ignored;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TSTAT fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P, ">>> TSTAT fid %d\n", fid->fid);
 
 	if (!ret)
 		return ERR_PTR(-ENOMEM);
@@ -1667,7 +1667,7 @@ struct p9_wstat *p9_client_stat(struct p9_fid *fid)
 		goto error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P,
+	p9_debug(P9_DEBUG_9P,
 		"<<< RSTAT sz=%x type=%x dev=%x qid=%x.%llx.%x\n"
 		"<<<    mode=%8.8x atime=%8.8x mtime=%8.8x length=%llx\n"
 		"<<<    name=%s uid=%s gid=%s muid=%s extension=(%s)\n"
@@ -1696,7 +1696,7 @@ struct p9_stat_dotl *p9_client_getattr_dotl(struct p9_fid *fid,
 								GFP_KERNEL);
 	struct p9_req_t *req;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TGETATTR fid %d, request_mask %lld\n",
+	p9_debug(P9_DEBUG_9P, ">>> TGETATTR fid %d, request_mask %lld\n",
 							fid->fid, request_mask);
 
 	if (!ret)
@@ -1718,7 +1718,7 @@ struct p9_stat_dotl *p9_client_getattr_dotl(struct p9_fid *fid,
 		goto error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P,
+	p9_debug(P9_DEBUG_9P,
 		"<<< RGETATTR st_result_mask=%lld\n"
 		"<<< qid=%x.%llx.%x\n"
 		"<<< st_mode=%8.8x st_nlink=%llu\n"
@@ -1784,8 +1784,8 @@ int p9_client_wstat(struct p9_fid *fid, struct p9_wstat *wst)
 	err = 0;
 	clnt = fid->clnt;
 	wst->size = p9_client_statsize(wst, clnt->proto_version);
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TWSTAT fid %d\n", fid->fid);
-	P9_DPRINTK(P9_DEBUG_9P,
+	p9_debug(P9_DEBUG_9P, ">>> TWSTAT fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P,
 		"     sz=%x type=%x dev=%x qid=%x.%llx.%x\n"
 		"     mode=%8.8x atime=%8.8x mtime=%8.8x length=%llx\n"
 		"     name=%s uid=%s gid=%s muid=%s extension=(%s)\n"
@@ -1802,7 +1802,7 @@ int p9_client_wstat(struct p9_fid *fid, struct p9_wstat *wst)
 		goto error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RWSTAT fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P, "<<< RWSTAT fid %d\n", fid->fid);
 
 	p9_free_req(clnt, req);
 error:
@@ -1818,8 +1818,8 @@ int p9_client_setattr(struct p9_fid *fid, struct p9_iattr_dotl *p9attr)
 
 	err = 0;
 	clnt = fid->clnt;
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TSETATTR fid %d\n", fid->fid);
-	P9_DPRINTK(P9_DEBUG_9P,
+	p9_debug(P9_DEBUG_9P, ">>> TSETATTR fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P,
 		"    valid=%x mode=%x uid=%d gid=%d size=%lld\n"
 		"    atime_sec=%lld atime_nsec=%lld\n"
 		"    mtime_sec=%lld mtime_nsec=%lld\n",
@@ -1833,7 +1833,7 @@ int p9_client_setattr(struct p9_fid *fid, struct p9_iattr_dotl *p9attr)
 		err = PTR_ERR(req);
 		goto error;
 	}
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RSETATTR fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P, "<<< RSETATTR fid %d\n", fid->fid);
 	p9_free_req(clnt, req);
 error:
 	return err;
@@ -1849,7 +1849,7 @@ int p9_client_statfs(struct p9_fid *fid, struct p9_rstatfs *sb)
 	err = 0;
 	clnt = fid->clnt;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TSTATFS fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P, ">>> TSTATFS fid %d\n", fid->fid);
 
 	req = p9_client_rpc(clnt, P9_TSTATFS, "d", fid->fid);
 	if (IS_ERR(req)) {
@@ -1866,7 +1866,7 @@ int p9_client_statfs(struct p9_fid *fid, struct p9_rstatfs *sb)
 		goto error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RSTATFS fid %d type 0x%lx bsize %ld "
+	p9_debug(P9_DEBUG_9P, "<<< RSTATFS fid %d type 0x%lx bsize %ld "
 		"blocks %llu bfree %llu bavail %llu files %llu ffree %llu "
 		"fsid %llu namelen %ld\n",
 		fid->fid, (long unsigned int)sb->type, (long int)sb->bsize,
@@ -1889,7 +1889,7 @@ int p9_client_rename(struct p9_fid *fid,
 	err = 0;
 	clnt = fid->clnt;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TRENAME fid %d newdirfid %d name %s\n",
+	p9_debug(P9_DEBUG_9P, ">>> TRENAME fid %d newdirfid %d name %s\n",
 			fid->fid, newdirfid->fid, name);
 
 	req = p9_client_rpc(clnt, P9_TRENAME, "dds", fid->fid,
@@ -1899,7 +1899,7 @@ int p9_client_rename(struct p9_fid *fid,
 		goto error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RRENAME fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P, "<<< RRENAME fid %d\n", fid->fid);
 
 	p9_free_req(clnt, req);
 error:
@@ -1917,7 +1917,7 @@ int p9_client_renameat(struct p9_fid *olddirfid, const char *old_name,
 	err = 0;
 	clnt = olddirfid->clnt;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TRENAMEAT olddirfid %d old name %s"
+	p9_debug(P9_DEBUG_9P, ">>> TRENAMEAT olddirfid %d old name %s"
 		   " newdirfid %d new name %s\n", olddirfid->fid, old_name,
 		   newdirfid->fid, new_name);
 
@@ -1928,7 +1928,7 @@ int p9_client_renameat(struct p9_fid *olddirfid, const char *old_name,
 		goto error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RRENAMEAT newdirfid %d new name %s\n",
+	p9_debug(P9_DEBUG_9P, "<<< RRENAMEAT newdirfid %d new name %s\n",
 		   newdirfid->fid, new_name);
 
 	p9_free_req(clnt, req);
@@ -1956,7 +1956,7 @@ struct p9_fid *p9_client_xattrwalk(struct p9_fid *file_fid,
 		attr_fid = NULL;
 		goto error;
 	}
-	P9_DPRINTK(P9_DEBUG_9P,
+	p9_debug(P9_DEBUG_9P,
 		">>> TXATTRWALK file_fid %d, attr_fid %d name %s\n",
 		file_fid->fid, attr_fid->fid, attr_name);
 
@@ -1973,7 +1973,7 @@ struct p9_fid *p9_client_xattrwalk(struct p9_fid *file_fid,
 		goto clunk_fid;
 	}
 	p9_free_req(clnt, req);
-	P9_DPRINTK(P9_DEBUG_9P, "<<<  RXATTRWALK fid %d size %llu\n",
+	p9_debug(P9_DEBUG_9P, "<<<  RXATTRWALK fid %d size %llu\n",
 		attr_fid->fid, *attr_size);
 	return attr_fid;
 clunk_fid:
@@ -1994,7 +1994,7 @@ int p9_client_xattrcreate(struct p9_fid *fid, const char *name,
 	struct p9_req_t *req;
 	struct p9_client *clnt;
 
-	P9_DPRINTK(P9_DEBUG_9P,
+	p9_debug(P9_DEBUG_9P,
 		">>> TXATTRCREATE fid %d name  %s size %lld flag %d\n",
 		fid->fid, name, (long long)attr_size, flags);
 	err = 0;
@@ -2005,7 +2005,7 @@ int p9_client_xattrcreate(struct p9_fid *fid, const char *name,
 		err = PTR_ERR(req);
 		goto error;
 	}
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RXATTRCREATE fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P, "<<< RXATTRCREATE fid %d\n", fid->fid);
 	p9_free_req(clnt, req);
 error:
 	return err;
@@ -2019,7 +2019,7 @@ int p9_client_readdir(struct p9_fid *fid, char *data, u32 count, u64 offset)
 	struct p9_req_t *req;
 	char *dataptr;
 
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TREADDIR fid %d offset %llu count %d\n",
+	p9_debug(P9_DEBUG_9P, ">>> TREADDIR fid %d offset %llu count %d\n",
 				fid->fid, (long long unsigned) offset, count);
 
 	err = 0;
@@ -2056,7 +2056,7 @@ int p9_client_readdir(struct p9_fid *fid, char *data, u32 count, u64 offset)
 		goto free_and_error;
 	}
 
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RREADDIR count %d\n", count);
+	p9_debug(P9_DEBUG_9P, "<<< RREADDIR count %d\n", count);
 
 	if (non_zc)
 		memmove(data, dataptr, count);
@@ -2080,7 +2080,7 @@ int p9_client_mknod_dotl(struct p9_fid *fid, char *name, int mode,
 
 	err = 0;
 	clnt = fid->clnt;
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TMKNOD fid %d name %s mode %d major %d "
+	p9_debug(P9_DEBUG_9P, ">>> TMKNOD fid %d name %s mode %d major %d "
 		"minor %d\n", fid->fid, name, mode, MAJOR(rdev), MINOR(rdev));
 	req = p9_client_rpc(clnt, P9_TMKNOD, "dsdddd", fid->fid, name, mode,
 		MAJOR(rdev), MINOR(rdev), gid);
@@ -2092,7 +2092,7 @@ int p9_client_mknod_dotl(struct p9_fid *fid, char *name, int mode,
 		trace_9p_protocol_dump(clnt, req->rc);
 		goto error;
 	}
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RMKNOD qid %x.%llx.%x\n", qid->type,
+	p9_debug(P9_DEBUG_9P, "<<< RMKNOD qid %x.%llx.%x\n", qid->type,
 				(unsigned long long)qid->path, qid->version);
 
 error:
@@ -2111,7 +2111,7 @@ int p9_client_mkdir_dotl(struct p9_fid *fid, char *name, int mode,
 
 	err = 0;
 	clnt = fid->clnt;
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TMKDIR fid %d name %s mode %d gid %d\n",
+	p9_debug(P9_DEBUG_9P, ">>> TMKDIR fid %d name %s mode %d gid %d\n",
 		 fid->fid, name, mode, gid);
 	req = p9_client_rpc(clnt, P9_TMKDIR, "dsdd", fid->fid, name, mode,
 		gid);
@@ -2123,7 +2123,7 @@ int p9_client_mkdir_dotl(struct p9_fid *fid, char *name, int mode,
 		trace_9p_protocol_dump(clnt, req->rc);
 		goto error;
 	}
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RMKDIR qid %x.%llx.%x\n", qid->type,
+	p9_debug(P9_DEBUG_9P, "<<< RMKDIR qid %x.%llx.%x\n", qid->type,
 				(unsigned long long)qid->path, qid->version);
 
 error:
@@ -2141,7 +2141,7 @@ int p9_client_lock_dotl(struct p9_fid *fid, struct p9_flock *flock, u8 *status)
 
 	err = 0;
 	clnt = fid->clnt;
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TLOCK fid %d type %i flags %d "
+	p9_debug(P9_DEBUG_9P, ">>> TLOCK fid %d type %i flags %d "
 			"start %lld length %lld proc_id %d client_id %s\n",
 			fid->fid, flock->type, flock->flags, flock->start,
 			flock->length, flock->proc_id, flock->client_id);
@@ -2158,7 +2158,7 @@ int p9_client_lock_dotl(struct p9_fid *fid, struct p9_flock *flock, u8 *status)
 		trace_9p_protocol_dump(clnt, req->rc);
 		goto error;
 	}
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RLOCK status %i\n", *status);
+	p9_debug(P9_DEBUG_9P, "<<< RLOCK status %i\n", *status);
 error:
 	p9_free_req(clnt, req);
 	return err;
@@ -2174,7 +2174,7 @@ int p9_client_getlock_dotl(struct p9_fid *fid, struct p9_getlock *glock)
 
 	err = 0;
 	clnt = fid->clnt;
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TGETLOCK fid %d, type %i start %lld "
+	p9_debug(P9_DEBUG_9P, ">>> TGETLOCK fid %d, type %i start %lld "
 		"length %lld proc_id %d client_id %s\n", fid->fid, glock->type,
 		glock->start, glock->length, glock->proc_id, glock->client_id);
 
@@ -2191,7 +2191,7 @@ int p9_client_getlock_dotl(struct p9_fid *fid, struct p9_getlock *glock)
 		trace_9p_protocol_dump(clnt, req->rc);
 		goto error;
 	}
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RGETLOCK type %i start %lld length %lld "
+	p9_debug(P9_DEBUG_9P, "<<< RGETLOCK type %i start %lld length %lld "
 		"proc_id %d client_id %s\n", glock->type, glock->start,
 		glock->length, glock->proc_id, glock->client_id);
 error:
@@ -2208,7 +2208,7 @@ int p9_client_readlink(struct p9_fid *fid, char **target)
 
 	err = 0;
 	clnt = fid->clnt;
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TREADLINK fid %d\n", fid->fid);
+	p9_debug(P9_DEBUG_9P, ">>> TREADLINK fid %d\n", fid->fid);
 
 	req = p9_client_rpc(clnt, P9_TREADLINK, "d", fid->fid);
 	if (IS_ERR(req))
@@ -2219,7 +2219,7 @@ int p9_client_readlink(struct p9_fid *fid, char **target)
 		trace_9p_protocol_dump(clnt, req->rc);
 		goto error;
 	}
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RREADLINK target %s\n", *target);
+	p9_debug(P9_DEBUG_9P, "<<< RREADLINK target %s\n", *target);
 error:
 	p9_free_req(clnt, req);
 	return err;
diff --git a/net/9p/error.c b/net/9p/error.c
index 5251851..2ab2de7 100644
--- a/net/9p/error.c
+++ b/net/9p/error.c
@@ -27,6 +27,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/list.h>
 #include <linux/jhash.h>
@@ -237,8 +239,8 @@ int p9_errstr2errno(char *errstr, int len)
 	if (errno == 0) {
 		/* TODO: if error isn't found, add it dynamically */
 		errstr[len] = 0;
-		printk(KERN_ERR "%s: server reported unknown error %s\n",
-			__func__, errstr);
+		pr_err("%s: server reported unknown error %s\n",
+		       __func__, errstr);
 		errno = ESERVERFAULT;
 	}
 
diff --git a/net/9p/mod.c b/net/9p/mod.c
index 2664d12..47df3bd 100644
--- a/net/9p/mod.c
+++ b/net/9p/mod.c
@@ -24,6 +24,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <net/9p/9p.h>
@@ -147,7 +149,7 @@ static int __init init_p9(void)
 	int ret = 0;
 
 	p9_error_init();
-	printk(KERN_INFO "Installing 9P2000 support\n");
+	pr_info("Installing 9P2000 support\n");
 	p9_trans_fd_init();
 
 	return ret;
@@ -160,7 +162,7 @@ static int __init init_p9(void)
 
 static void __exit exit_p9(void)
 {
-	printk(KERN_INFO "Unloading 9P2000 support\n");
+	pr_info("Unloading 9P2000 support\n");
 
 	p9_trans_fd_exit();
 }
diff --git a/net/9p/protocol.c b/net/9p/protocol.c
index 55e10a9..9ee48cb 100644
--- a/net/9p/protocol.c
+++ b/net/9p/protocol.c
@@ -534,7 +534,7 @@ int p9stat_read(struct p9_client *clnt, char *buf, int len, struct p9_wstat *st)
 
 	ret = p9pdu_readf(&fake_pdu, clnt->proto_version, "S", st);
 	if (ret) {
-		P9_DPRINTK(P9_DEBUG_9P, "<<< p9stat_read failed: %d\n", ret);
+		p9_debug(P9_DEBUG_9P, "<<< p9stat_read failed: %d\n", ret);
 		trace_9p_protocol_dump(clnt, &fake_pdu);
 	}
 
@@ -558,8 +558,8 @@ int p9pdu_finalize(struct p9_client *clnt, struct p9_fcall *pdu)
 	pdu->size = size;
 
 	trace_9p_protocol_dump(clnt, pdu);
-	P9_DPRINTK(P9_DEBUG_9P, ">>> size=%d type: %d tag: %d\n", pdu->size,
-							pdu->id, pdu->tag);
+	p9_debug(P9_DEBUG_9P, ">>> size=%d type: %d tag: %d\n",
+		 pdu->size, pdu->id, pdu->tag);
 
 	return err;
 }
@@ -585,7 +585,7 @@ int p9dirent_read(struct p9_client *clnt, char *buf, int len,
 	ret = p9pdu_readf(&fake_pdu, clnt->proto_version, "Qqbs", &dirent->qid,
 			  &dirent->d_off, &dirent->d_type, &nameptr);
 	if (ret) {
-		P9_DPRINTK(P9_DEBUG_9P, "<<< p9dirent_read failed: %d\n", ret);
+		p9_debug(P9_DEBUG_9P, "<<< p9dirent_read failed: %d\n", ret);
 		trace_9p_protocol_dump(clnt, &fake_pdu);
 		goto out;
 	}
diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index fdfdb57..fccae26 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -25,6 +25,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/in.h>
 #include <linux/module.h>
 #include <linux/net.h>
@@ -191,7 +193,7 @@ static void p9_conn_cancel(struct p9_conn *m, int err)
 	unsigned long flags;
 	LIST_HEAD(cancel_list);
 
-	P9_DPRINTK(P9_DEBUG_ERROR, "mux %p err %d\n", m, err);
+	p9_debug(P9_DEBUG_ERROR, "mux %p err %d\n", m, err);
 
 	spin_lock_irqsave(&m->client->lock, flags);
 
@@ -217,7 +219,7 @@ static void p9_conn_cancel(struct p9_conn *m, int err)
 	spin_unlock_irqrestore(&m->client->lock, flags);
 
 	list_for_each_entry_safe(req, rtmp, &cancel_list, req_list) {
-		P9_DPRINTK(P9_DEBUG_ERROR, "call back req %p\n", req);
+		p9_debug(P9_DEBUG_ERROR, "call back req %p\n", req);
 		list_del(&req->req_list);
 		p9_client_cb(m->client, req);
 	}
@@ -275,7 +277,7 @@ static int p9_fd_read(struct p9_client *client, void *v, int len)
 		return -EREMOTEIO;
 
 	if (!(ts->rd->f_flags & O_NONBLOCK))
-		P9_DPRINTK(P9_DEBUG_ERROR, "blocking read ...\n");
+		p9_debug(P9_DEBUG_ERROR, "blocking read ...\n");
 
 	ret = kernel_read(ts->rd, ts->rd->f_pos, v, len);
 	if (ret <= 0 && ret != -ERESTARTSYS && ret != -EAGAIN)
@@ -299,7 +301,7 @@ static void p9_read_work(struct work_struct *work)
 	if (m->err < 0)
 		return;
 
-	P9_DPRINTK(P9_DEBUG_TRANS, "start mux %p pos %d\n", m, m->rpos);
+	p9_debug(P9_DEBUG_TRANS, "start mux %p pos %d\n", m, m->rpos);
 
 	if (!m->rbuf) {
 		m->rbuf = m->tmp_buf;
@@ -308,11 +310,11 @@ static void p9_read_work(struct work_struct *work)
 	}
 
 	clear_bit(Rpending, &m->wsched);
-	P9_DPRINTK(P9_DEBUG_TRANS, "read mux %p pos %d size: %d = %d\n", m,
-					m->rpos, m->rsize, m->rsize-m->rpos);
+	p9_debug(P9_DEBUG_TRANS, "read mux %p pos %d size: %d = %d\n",
+		 m, m->rpos, m->rsize, m->rsize-m->rpos);
 	err = p9_fd_read(m->client, m->rbuf + m->rpos,
 						m->rsize - m->rpos);
-	P9_DPRINTK(P9_DEBUG_TRANS, "mux %p got %d bytes\n", m, err);
+	p9_debug(P9_DEBUG_TRANS, "mux %p got %d bytes\n", m, err);
 	if (err == -EAGAIN) {
 		clear_bit(Rworksched, &m->wsched);
 		return;
@@ -325,25 +327,25 @@ static void p9_read_work(struct work_struct *work)
 
 	if ((!m->req) && (m->rpos == m->rsize)) { /* header read in */
 		u16 tag;
-		P9_DPRINTK(P9_DEBUG_TRANS, "got new header\n");
+		p9_debug(P9_DEBUG_TRANS, "got new header\n");
 
 		n = le32_to_cpu(*(__le32 *) m->rbuf); /* read packet size */
 		if (n >= m->client->msize) {
-			P9_DPRINTK(P9_DEBUG_ERROR,
-				"requested packet size too big: %d\n", n);
+			p9_debug(P9_DEBUG_ERROR,
+				 "requested packet size too big: %d\n", n);
 			err = -EIO;
 			goto error;
 		}
 
 		tag = le16_to_cpu(*(__le16 *) (m->rbuf+5)); /* read tag */
-		P9_DPRINTK(P9_DEBUG_TRANS,
-			"mux %p pkt: size: %d bytes tag: %d\n", m, n, tag);
+		p9_debug(P9_DEBUG_TRANS,
+			 "mux %p pkt: size: %d bytes tag: %d\n", m, n, tag);
 
 		m->req = p9_tag_lookup(m->client, tag);
 		if (!m->req || (m->req->status != REQ_STATUS_SENT &&
 					m->req->status != REQ_STATUS_FLSH)) {
-			P9_DPRINTK(P9_DEBUG_ERROR, "Unexpected packet tag %d\n",
-								 tag);
+			p9_debug(P9_DEBUG_ERROR, "Unexpected packet tag %d\n",
+				 tag);
 			err = -EIO;
 			goto error;
 		}
@@ -364,7 +366,7 @@ static void p9_read_work(struct work_struct *work)
 
 	/* not an else because some packets (like clunk) have no payload */
 	if ((m->req) && (m->rpos == m->rsize)) { /* packet is read in */
-		P9_DPRINTK(P9_DEBUG_TRANS, "got new packet\n");
+		p9_debug(P9_DEBUG_TRANS, "got new packet\n");
 		spin_lock(&m->client->lock);
 		if (m->req->status != REQ_STATUS_ERROR)
 			m->req->status = REQ_STATUS_RCVD;
@@ -384,7 +386,7 @@ static void p9_read_work(struct work_struct *work)
 			n = p9_fd_poll(m->client, NULL);
 
 		if (n & POLLIN) {
-			P9_DPRINTK(P9_DEBUG_TRANS, "sched read work %p\n", m);
+			p9_debug(P9_DEBUG_TRANS, "sched read work %p\n", m);
 			schedule_work(&m->rq);
 		} else
 			clear_bit(Rworksched, &m->wsched);
@@ -418,7 +420,7 @@ static int p9_fd_write(struct p9_client *client, void *v, int len)
 		return -EREMOTEIO;
 
 	if (!(ts->wr->f_flags & O_NONBLOCK))
-		P9_DPRINTK(P9_DEBUG_ERROR, "blocking write ...\n");
+		p9_debug(P9_DEBUG_ERROR, "blocking write ...\n");
 
 	oldfs = get_fs();
 	set_fs(get_ds());
@@ -460,7 +462,7 @@ static void p9_write_work(struct work_struct *work)
 		req = list_entry(m->unsent_req_list.next, struct p9_req_t,
 			       req_list);
 		req->status = REQ_STATUS_SENT;
-		P9_DPRINTK(P9_DEBUG_TRANS, "move req %p\n", req);
+		p9_debug(P9_DEBUG_TRANS, "move req %p\n", req);
 		list_move_tail(&req->req_list, &m->req_list);
 
 		m->wbuf = req->tc->sdata;
@@ -469,11 +471,11 @@ static void p9_write_work(struct work_struct *work)
 		spin_unlock(&m->client->lock);
 	}
 
-	P9_DPRINTK(P9_DEBUG_TRANS, "mux %p pos %d size %d\n", m, m->wpos,
-								m->wsize);
+	p9_debug(P9_DEBUG_TRANS, "mux %p pos %d size %d\n",
+		 m, m->wpos, m->wsize);
 	clear_bit(Wpending, &m->wsched);
 	err = p9_fd_write(m->client, m->wbuf + m->wpos, m->wsize - m->wpos);
-	P9_DPRINTK(P9_DEBUG_TRANS, "mux %p sent %d bytes\n", m, err);
+	p9_debug(P9_DEBUG_TRANS, "mux %p sent %d bytes\n", m, err);
 	if (err == -EAGAIN) {
 		clear_bit(Wworksched, &m->wsched);
 		return;
@@ -497,7 +499,7 @@ static void p9_write_work(struct work_struct *work)
 			n = p9_fd_poll(m->client, NULL);
 
 		if (n & POLLOUT) {
-			P9_DPRINTK(P9_DEBUG_TRANS, "sched write work %p\n", m);
+			p9_debug(P9_DEBUG_TRANS, "sched write work %p\n", m);
 			schedule_work(&m->wq);
 		} else
 			clear_bit(Wworksched, &m->wsched);
@@ -551,7 +553,7 @@ p9_pollwait(struct file *filp, wait_queue_head_t *wait_address, poll_table *p)
 	}
 
 	if (!pwait) {
-		P9_DPRINTK(P9_DEBUG_ERROR, "not enough wait_address slots\n");
+		p9_debug(P9_DEBUG_ERROR, "not enough wait_address slots\n");
 		return;
 	}
 
@@ -573,8 +575,7 @@ static struct p9_conn *p9_conn_create(struct p9_client *client)
 	int n;
 	struct p9_conn *m;
 
-	P9_DPRINTK(P9_DEBUG_TRANS, "client %p msize %d\n", client,
-								client->msize);
+	p9_debug(P9_DEBUG_TRANS, "client %p msize %d\n", client, client->msize);
 	m = kzalloc(sizeof(struct p9_conn), GFP_KERNEL);
 	if (!m)
 		return ERR_PTR(-ENOMEM);
@@ -591,12 +592,12 @@ static struct p9_conn *p9_conn_create(struct p9_client *client)
 
 	n = p9_fd_poll(client, &m->pt);
 	if (n & POLLIN) {
-		P9_DPRINTK(P9_DEBUG_TRANS, "mux %p can read\n", m);
+		p9_debug(P9_DEBUG_TRANS, "mux %p can read\n", m);
 		set_bit(Rpending, &m->wsched);
 	}
 
 	if (n & POLLOUT) {
-		P9_DPRINTK(P9_DEBUG_TRANS, "mux %p can write\n", m);
+		p9_debug(P9_DEBUG_TRANS, "mux %p can write\n", m);
 		set_bit(Wpending, &m->wsched);
 	}
 
@@ -618,7 +619,7 @@ static void p9_poll_mux(struct p9_conn *m)
 
 	n = p9_fd_poll(m->client, NULL);
 	if (n < 0 || n & (POLLERR | POLLHUP | POLLNVAL)) {
-		P9_DPRINTK(P9_DEBUG_TRANS, "error mux %p err %d\n", m, n);
+		p9_debug(P9_DEBUG_TRANS, "error mux %p err %d\n", m, n);
 		if (n >= 0)
 			n = -ECONNRESET;
 		p9_conn_cancel(m, n);
@@ -626,19 +627,19 @@ static void p9_poll_mux(struct p9_conn *m)
 
 	if (n & POLLIN) {
 		set_bit(Rpending, &m->wsched);
-		P9_DPRINTK(P9_DEBUG_TRANS, "mux %p can read\n", m);
+		p9_debug(P9_DEBUG_TRANS, "mux %p can read\n", m);
 		if (!test_and_set_bit(Rworksched, &m->wsched)) {
-			P9_DPRINTK(P9_DEBUG_TRANS, "sched read work %p\n", m);
+			p9_debug(P9_DEBUG_TRANS, "sched read work %p\n", m);
 			schedule_work(&m->rq);
 		}
 	}
 
 	if (n & POLLOUT) {
 		set_bit(Wpending, &m->wsched);
-		P9_DPRINTK(P9_DEBUG_TRANS, "mux %p can write\n", m);
+		p9_debug(P9_DEBUG_TRANS, "mux %p can write\n", m);
 		if ((m->wsize || !list_empty(&m->unsent_req_list)) &&
 		    !test_and_set_bit(Wworksched, &m->wsched)) {
-			P9_DPRINTK(P9_DEBUG_TRANS, "sched write work %p\n", m);
+			p9_debug(P9_DEBUG_TRANS, "sched write work %p\n", m);
 			schedule_work(&m->wq);
 		}
 	}
@@ -661,8 +662,8 @@ static int p9_fd_request(struct p9_client *client, struct p9_req_t *req)
 	struct p9_trans_fd *ts = client->trans;
 	struct p9_conn *m = ts->conn;
 
-	P9_DPRINTK(P9_DEBUG_TRANS, "mux %p task %p tcall %p id %d\n", m,
-						current, req->tc, req->tc->id);
+	p9_debug(P9_DEBUG_TRANS, "mux %p task %p tcall %p id %d\n",
+		 m, current, req->tc, req->tc->id);
 	if (m->err < 0)
 		return m->err;
 
@@ -686,7 +687,7 @@ static int p9_fd_cancel(struct p9_client *client, struct p9_req_t *req)
 {
 	int ret = 1;
 
-	P9_DPRINTK(P9_DEBUG_TRANS, "client %p req %p\n", client, req);
+	p9_debug(P9_DEBUG_TRANS, "client %p req %p\n", client, req);
 
 	spin_lock(&client->lock);
 
@@ -726,8 +727,8 @@ static int parse_opts(char *params, struct p9_fd_opts *opts)
 
 	tmp_options = kstrdup(params, GFP_KERNEL);
 	if (!tmp_options) {
-		P9_DPRINTK(P9_DEBUG_ERROR,
-				"failed to allocate copy of option string\n");
+		p9_debug(P9_DEBUG_ERROR,
+			 "failed to allocate copy of option string\n");
 		return -ENOMEM;
 	}
 	options = tmp_options;
@@ -741,8 +742,8 @@ static int parse_opts(char *params, struct p9_fd_opts *opts)
 		if (token != Opt_err) {
 			r = match_int(&args[0], &option);
 			if (r < 0) {
-				P9_DPRINTK(P9_DEBUG_ERROR,
-				"integer field, but no integer?\n");
+				p9_debug(P9_DEBUG_ERROR,
+					 "integer field, but no integer?\n");
 				continue;
 			}
 		}
@@ -801,7 +802,8 @@ static int p9_socket_open(struct p9_client *client, struct socket *csocket)
 	csocket->sk->sk_allocation = GFP_NOIO;
 	fd = sock_map_fd(csocket, 0);
 	if (fd < 0) {
-		P9_EPRINTK(KERN_ERR, "p9_socket_open: failed to map fd\n");
+		pr_err("%s (%d): failed to map fd\n",
+		       __func__, task_pid_nr(current));
 		sock_release(csocket);
 		kfree(p);
 		return fd;
@@ -837,8 +839,8 @@ static int p9_socket_open(struct p9_client *client, struct socket *csocket)
 
 static void p9_conn_destroy(struct p9_conn *m)
 {
-	P9_DPRINTK(P9_DEBUG_TRANS, "mux %p prev %p next %p\n", m,
-		m->mux_list.prev, m->mux_list.next);
+	p9_debug(P9_DEBUG_TRANS, "mux %p prev %p next %p\n",
+		 m, m->mux_list.prev, m->mux_list.next);
 
 	p9_mux_poll_stop(m);
 	cancel_work_sync(&m->rq);
@@ -919,7 +921,8 @@ p9_fd_create_tcp(struct p9_client *client, const char *addr, char *args)
 	err = __sock_create(read_pnet(&current->nsproxy->net_ns), PF_INET,
 			    SOCK_STREAM, IPPROTO_TCP, &csocket, 1);
 	if (err) {
-		P9_EPRINTK(KERN_ERR, "p9_trans_tcp: problem creating socket\n");
+		pr_err("%s (%d): problem creating socket\n",
+		       __func__, task_pid_nr(current));
 		return err;
 	}
 
@@ -927,9 +930,8 @@ p9_fd_create_tcp(struct p9_client *client, const char *addr, char *args)
 				    (struct sockaddr *)&sin_server,
 				    sizeof(struct sockaddr_in), 0);
 	if (err < 0) {
-		P9_EPRINTK(KERN_ERR,
-			"p9_trans_tcp: problem connecting socket to %s\n",
-			addr);
+		pr_err("%s (%d): problem connecting socket to %s\n",
+		       __func__, task_pid_nr(current), addr);
 		sock_release(csocket);
 		return err;
 	}
@@ -947,8 +949,8 @@ p9_fd_create_unix(struct p9_client *client, const char *addr, char *args)
 	csocket = NULL;
 
 	if (strlen(addr) >= UNIX_PATH_MAX) {
-		P9_EPRINTK(KERN_ERR, "p9_trans_unix: address too long: %s\n",
-			addr);
+		pr_err("%s (%d): address too long: %s\n",
+		       __func__, task_pid_nr(current), addr);
 		return -ENAMETOOLONG;
 	}
 
@@ -957,15 +959,16 @@ p9_fd_create_unix(struct p9_client *client, const char *addr, char *args)
 	err = __sock_create(read_pnet(&current->nsproxy->net_ns), PF_UNIX,
 			    SOCK_STREAM, 0, &csocket, 1);
 	if (err < 0) {
-		P9_EPRINTK(KERN_ERR, "p9_trans_unix: problem creating socket\n");
+		pr_err("%s (%d): problem creating socket\n",
+		       __func__, task_pid_nr(current));
+
 		return err;
 	}
 	err = csocket->ops->connect(csocket, (struct sockaddr *)&sun_server,
 			sizeof(struct sockaddr_un) - 1, 0);
 	if (err < 0) {
-		P9_EPRINTK(KERN_ERR,
-			"p9_trans_unix: problem connecting socket: %s: %d\n",
-			addr, err);
+		pr_err("%s (%d): problem connecting socket: %s: %d\n",
+		       __func__, task_pid_nr(current), addr, err);
 		sock_release(csocket);
 		return err;
 	}
@@ -983,7 +986,7 @@ p9_fd_create(struct p9_client *client, const char *addr, char *args)
 	parse_opts(args, &opts);
 
 	if (opts.rfd == ~0 || opts.wfd == ~0) {
-		printk(KERN_ERR "v9fs: Insufficient options for proto=fd\n");
+		pr_err("Insufficient options for proto=fd\n");
 		return -ENOPROTOOPT;
 	}
 
@@ -1050,7 +1053,7 @@ static void p9_poll_workfn(struct work_struct *work)
 {
 	unsigned long flags;
 
-	P9_DPRINTK(P9_DEBUG_TRANS, "start %p\n", current);
+	p9_debug(P9_DEBUG_TRANS, "start %p\n", current);
 
 	spin_lock_irqsave(&p9_poll_lock, flags);
 	while (!list_empty(&p9_poll_pending_list)) {
@@ -1066,7 +1069,7 @@ static void p9_poll_workfn(struct work_struct *work)
 	}
 	spin_unlock_irqrestore(&p9_poll_lock, flags);
 
-	P9_DPRINTK(P9_DEBUG_TRANS, "finish\n");
+	p9_debug(P9_DEBUG_TRANS, "finish\n");
 }
 
 int p9_trans_fd_init(void)
diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 159c50f..2c69ddd 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -26,6 +26,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/in.h>
 #include <linux/module.h>
 #include <linux/net.h>
@@ -178,8 +180,8 @@ static int parse_opts(char *params, struct p9_rdma_opts *opts)
 
 	tmp_options = kstrdup(params, GFP_KERNEL);
 	if (!tmp_options) {
-		P9_DPRINTK(P9_DEBUG_ERROR,
-			   "failed to allocate copy of option string\n");
+		p9_debug(P9_DEBUG_ERROR,
+			 "failed to allocate copy of option string\n");
 		return -ENOMEM;
 	}
 	options = tmp_options;
@@ -192,8 +194,8 @@ static int parse_opts(char *params, struct p9_rdma_opts *opts)
 		token = match_token(p, tokens, args);
 		r = match_int(&args[0], &option);
 		if (r < 0) {
-			P9_DPRINTK(P9_DEBUG_ERROR,
-				   "integer field, but no integer?\n");
+			p9_debug(P9_DEBUG_ERROR,
+				 "integer field, but no integer?\n");
 			continue;
 		}
 		switch (token) {
@@ -301,8 +303,7 @@ handle_recv(struct p9_client *client, struct p9_trans_rdma *rdma,
 	return;
 
  err_out:
-	P9_DPRINTK(P9_DEBUG_ERROR, "req %p err %d status %d\n",
-		   req, err, status);
+	p9_debug(P9_DEBUG_ERROR, "req %p err %d status %d\n", req, err, status);
 	rdma->state = P9_RDMA_FLUSHING;
 	client->status = Disconnected;
 }
@@ -318,8 +319,8 @@ handle_send(struct p9_client *client, struct p9_trans_rdma *rdma,
 
 static void qp_event_handler(struct ib_event *event, void *context)
 {
-	P9_DPRINTK(P9_DEBUG_ERROR, "QP event %d context %p\n", event->event,
-								context);
+	p9_debug(P9_DEBUG_ERROR, "QP event %d context %p\n",
+		 event->event, context);
 }
 
 static void cq_comp_handler(struct ib_cq *cq, void *cq_context)
@@ -345,8 +346,7 @@ static void cq_comp_handler(struct ib_cq *cq, void *cq_context)
 			break;
 
 		default:
-			printk(KERN_ERR "9prdma: unexpected completion type, "
-			       "c->wc_op=%d, wc.opcode=%d, status=%d\n",
+			pr_err("unexpected completion type, c->wc_op=%d, wc.opcode=%d, status=%d\n",
 			       c->wc_op, wc.opcode, wc.status);
 			break;
 		}
@@ -356,7 +356,7 @@ static void cq_comp_handler(struct ib_cq *cq, void *cq_context)
 
 static void cq_event_handler(struct ib_event *e, void *v)
 {
-	P9_DPRINTK(P9_DEBUG_ERROR, "CQ event %d context %p\n", e->event, v);
+	p9_debug(P9_DEBUG_ERROR, "CQ event %d context %p\n", e->event, v);
 }
 
 static void rdma_destroy_trans(struct p9_trans_rdma *rdma)
@@ -407,7 +407,7 @@ post_recv(struct p9_client *client, struct p9_rdma_context *c)
 	return ib_post_recv(rdma->qp, &wr, &bad_wr);
 
  error:
-	P9_DPRINTK(P9_DEBUG_ERROR, "EIO\n");
+	p9_debug(P9_DEBUG_ERROR, "EIO\n");
 	return -EIO;
 }
 
@@ -500,7 +500,7 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 	kfree(c);
 	kfree(rpl_context->rc);
 	kfree(rpl_context);
-	P9_DPRINTK(P9_DEBUG_ERROR, "EIO\n");
+	p9_debug(P9_DEBUG_ERROR, "EIO\n");
 	return -EIO;
  err_free1:
 	kfree(rpl_context->rc);
diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index 177a9ff..3d43206 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -26,6 +26,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/in.h>
 #include <linux/module.h>
 #include <linux/net.h>
@@ -145,7 +147,7 @@ static void req_done(struct virtqueue *vq)
 	struct p9_req_t *req;
 	unsigned long flags;
 
-	P9_DPRINTK(P9_DEBUG_TRANS, ": request done\n");
+	p9_debug(P9_DEBUG_TRANS, ": request done\n");
 
 	while (1) {
 		spin_lock_irqsave(&chan->lock, flags);
@@ -158,8 +160,8 @@ static void req_done(struct virtqueue *vq)
 		spin_unlock_irqrestore(&chan->lock, flags);
 		/* Wakeup if anyone waiting for VirtIO ring space. */
 		wake_up(chan->vc_wq);
-		P9_DPRINTK(P9_DEBUG_TRANS, ": rc %p\n", rc);
-		P9_DPRINTK(P9_DEBUG_TRANS, ": lookup tag %d\n", rc->tag);
+		p9_debug(P9_DEBUG_TRANS, ": rc %p\n", rc);
+		p9_debug(P9_DEBUG_TRANS, ": lookup tag %d\n", rc->tag);
 		req = p9_tag_lookup(chan->client, rc->tag);
 		req->status = REQ_STATUS_RCVD;
 		p9_client_cb(chan->client, req);
@@ -257,7 +259,7 @@ p9_virtio_request(struct p9_client *client, struct p9_req_t *req)
 	unsigned long flags;
 	struct virtio_chan *chan = client->trans;
 
-	P9_DPRINTK(P9_DEBUG_TRANS, "9p debug: virtio request\n");
+	p9_debug(P9_DEBUG_TRANS, "9p debug: virtio request\n");
 
 	req->status = REQ_STATUS_SENT;
 req_retry:
@@ -281,20 +283,19 @@ req_retry:
 			if (err  == -ERESTARTSYS)
 				return err;
 
-			P9_DPRINTK(P9_DEBUG_TRANS, "9p:Retry virtio request\n");
+			p9_debug(P9_DEBUG_TRANS, "Retry virtio request\n");
 			goto req_retry;
 		} else {
 			spin_unlock_irqrestore(&chan->lock, flags);
-			P9_DPRINTK(P9_DEBUG_TRANS,
-					"9p debug: "
-					"virtio rpc add_buf returned failure");
+			p9_debug(P9_DEBUG_TRANS,
+				 "virtio rpc add_buf returned failure\n");
 			return -EIO;
 		}
 	}
 	virtqueue_kick(chan->vq);
 	spin_unlock_irqrestore(&chan->lock, flags);
 
-	P9_DPRINTK(P9_DEBUG_TRANS, "9p debug: virtio request kicked\n");
+	p9_debug(P9_DEBUG_TRANS, "virtio request kicked\n");
 	return 0;
 }
 
@@ -355,7 +356,7 @@ p9_virtio_zc_request(struct p9_client *client, struct p9_req_t *req,
 	struct page **in_pages = NULL, **out_pages = NULL;
 	struct virtio_chan *chan = client->trans;
 
-	P9_DPRINTK(P9_DEBUG_TRANS, "9p debug: virtio request\n");
+	p9_debug(P9_DEBUG_TRANS, "virtio request\n");
 
 	if (uodata) {
 		out_nr_pages = p9_nr_pages(uodata, outlen);
@@ -425,20 +426,19 @@ req_retry_pinned:
 			if (err  == -ERESTARTSYS)
 				goto err_out;
 
-			P9_DPRINTK(P9_DEBUG_TRANS, "9p:Retry virtio request\n");
+			p9_debug(P9_DEBUG_TRANS, "Retry virtio request\n");
 			goto req_retry_pinned;
 		} else {
 			spin_unlock_irqrestore(&chan->lock, flags);
-			P9_DPRINTK(P9_DEBUG_TRANS,
-				   "9p debug: "
-				   "virtio rpc add_buf returned failure");
+			p9_debug(P9_DEBUG_TRANS,
+				 "virtio rpc add_buf returned failure\n");
 			err = -EIO;
 			goto err_out;
 		}
 	}
 	virtqueue_kick(chan->vq);
 	spin_unlock_irqrestore(&chan->lock, flags);
-	P9_DPRINTK(P9_DEBUG_TRANS, "9p debug: virtio request kicked\n");
+	p9_debug(P9_DEBUG_TRANS, "virtio request kicked\n");
 	err = wait_event_interruptible(*req->wq,
 				       req->status >= REQ_STATUS_RCVD);
 	/*
@@ -493,7 +493,7 @@ static int p9_virtio_probe(struct virtio_device *vdev)
 
 	chan = kmalloc(sizeof(struct virtio_chan), GFP_KERNEL);
 	if (!chan) {
-		printk(KERN_ERR "9p: Failed to allocate virtio 9P channel\n");
+		pr_err("Failed to allocate virtio 9P channel\n");
 		err = -ENOMEM;
 		goto fail;
 	}
@@ -594,7 +594,7 @@ p9_virtio_create(struct p9_client *client, const char *devname, char *args)
 	mutex_unlock(&virtio_9p_lock);
 
 	if (!found) {
-		printk(KERN_ERR "9p: no channels available\n");
+		pr_err("no channels available\n");
 		return ret;
 	}
 
diff --git a/net/9p/util.c b/net/9p/util.c
index 9c1c934..6ceeeb3 100644
--- a/net/9p/util.c
+++ b/net/9p/util.c
@@ -106,7 +106,7 @@ retry:
 	else if (error)
 		return -1;
 
-	P9_DPRINTK(P9_DEBUG_MUX, " id %d pool %p\n", i, p);
+	p9_debug(P9_DEBUG_MUX, " id %d pool %p\n", i, p);
 	return i;
 }
 EXPORT_SYMBOL(p9_idpool_get);
@@ -124,7 +124,7 @@ void p9_idpool_put(int id, struct p9_idpool *p)
 {
 	unsigned long flags;
 
-	P9_DPRINTK(P9_DEBUG_MUX, " id %d pool %p\n", id, p);
+	p9_debug(P9_DEBUG_MUX, " id %d pool %p\n", id, p);
 
 	spin_lock_irqsave(&p->lock, flags);
 	idr_remove(&p->pool, id);
-- 
1.7.6.405.gc1be0
