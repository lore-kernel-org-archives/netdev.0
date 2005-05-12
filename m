From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] use lookup_create in af_unix
Date: Thu, 12 May 2005 12:23:36 +0200
Message-ID: <20050512102336.GA26628@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

currently it opencodes it, but that's in the way of chaning the
lookup_hash interface.

I'd prefer to disallow modular af_unix over exporting lookup_create,
but I'll leave that to you.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: fs/namei.c
===================================================================
--- eed337ef5e9ae7d62caa84b7974a11fddc7f06e0/fs/namei.c  (mode:100644 sha1:defe6781e003c208fc0a4b6e92bcf1dc2a0465de)
+++ uncommitted/fs/namei.c  (mode:100644)
@@ -1580,6 +1580,7 @@
 fail:
 	return dentry;
 }
+EXPORT_SYMBOL_GPL(lookup_create);
 
 int vfs_mknod(struct inode *dir, struct dentry *dentry, int mode, dev_t dev)
 {
Index: net/unix/af_unix.c
===================================================================
--- eed337ef5e9ae7d62caa84b7974a11fddc7f06e0/net/unix/af_unix.c  (mode:100644 sha1:c478fc8db7768428580d23381856fa53fa31add2)
+++ uncommitted/net/unix/af_unix.c  (mode:100644)
@@ -770,33 +770,12 @@
 		err = path_lookup(sunaddr->sun_path, LOOKUP_PARENT, &nd);
 		if (err)
 			goto out_mknod_parent;
-		/*
-		 * Yucky last component or no last component at all?
-		 * (foo/., foo/.., /////)
-		 */
-		err = -EEXIST;
-		if (nd.last_type != LAST_NORM)
-			goto out_mknod;
-		/*
-		 * Lock the directory.
-		 */
-		down(&nd.dentry->d_inode->i_sem);
-		/*
-		 * Do the final lookup.
-		 */
-		dentry = lookup_hash(&nd.last, nd.dentry);
+
+		dentry = lookup_create(&nd, 0);
 		err = PTR_ERR(dentry);
 		if (IS_ERR(dentry))
 			goto out_mknod_unlock;
-		err = -ENOENT;
-		/*
-		 * Special case - lookup gave negative, but... we had foo/bar/
-		 * From the vfs_mknod() POV we just have a negative dentry -
-		 * all is fine. Let's be bastards - you had / on the end, you've
-		 * been asking for (non-existent) directory. -ENOENT for you.
-		 */
-		if (nd.last.name[nd.last.len] && !dentry->d_inode)
-			goto out_mknod_dput;
+
 		/*
 		 * All right, let's create it.
 		 */
@@ -845,7 +824,6 @@
 	dput(dentry);
 out_mknod_unlock:
 	up(&nd.dentry->d_inode->i_sem);
-out_mknod:
 	path_release(&nd);
 out_mknod_parent:
 	if (err==-EEXIST)
