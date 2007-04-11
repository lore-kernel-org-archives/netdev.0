From: David Howells <dhowells@redhat.com>
Subject: [PATCH 7/8] AFS: Permit key to be cached in nameidata
Date: Wed, 11 Apr 2007 20:10:32 +0100
Message-ID: <20070411191032.15499.78083.stgit@warthog.cambridge.redhat.com>
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

Permit a key to be cached in the nameidata struct so that it only needs to be
looked up once when doing the sequence of d_revalidate(), permission(),
follow_link() and lookup() calls involved in a pathwalk.

This is used by the AFS filesystem to avoid repeatedly having to call
request_key().  Once looked up, the key is then available as the kernel walks
to the tree until such a time as the kernel crosses to a non-AFS mountpoint or
an AFS mountpoint in a different cell.

The cache works like this:

 (1) The nameidata::key pointer is initialised to NULL at the start of the
     pathwalk (do_path_lookup()).  path_release() and co. release the key it
     points to.

 (2) Any filesystem operation performed during the pathwalk that has access to
     the nameidata (lookup, permission, follow_link, d_revalidate) can look at
     the key - if non-NULL - and if it's what they're looking for they can use
     it.

     If there's a key there of potential interest, the key's type and
     description should be checked to make sure the key is permissible.

     If of interest, key_validate() should be called to make sure the key is
     still usable.  If it isn't, the error should be passed back rather than
     the key lookup being redone on the basis that some earlier step is now no
     longer valid.

 (3) Any operation that is not interested in the key can either ignore it or
     release it and clear the pointer.

 (4) If an operation wants to put its own key there, it should release the old
     key and set the pointer to point to its own key with the key's usage count
     incremented.  This could be encapsulated in a function something like
     this:

	void set_nd_key(struct nameidata *nd, struct key *key)
	{
		key_put(nd->key);
		nd->key = key_get(key);
	}

Unfortunately there isn't currently a way to pass the key onto the inode
operations for create(), link(), unlink(), and suchlike, nor is there a way to
pass it to the open() file op without adding a struct key pointer argument to
each of these.

This might also be useful for NFS and CIFS.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 fs/namei.c            |    5 +++++
 fs/open.c             |    7 +++++--
 include/linux/namei.h |    1 +
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index ee60cc4..7a59d12 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -350,6 +350,8 @@ void path_release(struct nameidata *nd)
 {
 	dput(nd->dentry);
 	mntput(nd->mnt);
+	key_put(nd->key);
+	nd->key = NULL;
 }
 
 /*
@@ -360,6 +362,8 @@ void path_release_on_umount(struct nameidata *nd)
 {
 	dput(nd->dentry);
 	mntput_no_expire(nd->mnt);
+	key_put(nd->key);
+	nd->key = NULL;
 }
 
 /**
@@ -1108,6 +1112,7 @@ static int fastcall do_path_lookup(int dfd, const char *name,
 	struct file *file;
 	struct fs_struct *fs = current->fs;
 
+	nd->key = NULL;
 	nd->last_type = LAST_ROOT; /* if there are only slashes... */
 	nd->flags = flags;
 	nd->depth = 0;
diff --git a/fs/open.c b/fs/open.c
index c989fb4..77bd2a5 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -822,10 +822,13 @@ struct file *nameidata_to_filp(struct nameidata *nd, int flags)
 	/* Pick up the filp from the open intent */
 	filp = nd->intent.open.file;
 	/* Has the filesystem initialised the file for us? */
-	if (filp->f_path.dentry == NULL)
+	if (filp->f_path.dentry == NULL) {
 		filp = __dentry_open(nd->dentry, nd->mnt, flags, filp, NULL);
-	else
+		key_put(nd->key);
+		nd->key = NULL;
+	} else {
 		path_release(nd);
+	}
 	return filp;
 }
 
diff --git a/include/linux/namei.h b/include/linux/namei.h
index d39a5a6..d677408 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -17,6 +17,7 @@ enum { MAX_NESTED_LINKS = 8 };
 struct nameidata {
 	struct dentry	*dentry;
 	struct vfsmount *mnt;
+	struct key	*key;
 	struct qstr	last;
 	unsigned int	flags;
 	int		last_type;

