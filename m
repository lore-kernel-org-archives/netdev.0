From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/2] AFS: Fix a couple of problems with unlinking AFS files
Date: Thu, 10 May 2007 15:33:39 +0100
Message-ID: <20070510143339.19485.28659.stgit@warthog.cambridge.redhat.com>
References: <20070510143334.19485.26042.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	dhowells@redhat.com
To: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070510143334.19485.26042.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a couple of problems with unlinking AFS files.

 (1) The parent directory wasn't being updated properly between unlink() and
     the following lookup().

     It seems that, for some reason, invalidate_remote_inode() wasn't
     discarding the directory contents correctly, so this patch calls
     invalidate_inode_pages2() instead on non-regular files.

 (2) afs_vnode_deleted_remotely() should handle vnodes that don't have a
     source server recorded without oopsing.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/file.c  |    2 +-
 fs/afs/inode.c |   10 +++++++---
 fs/afs/super.c |    3 ++-
 fs/afs/vnode.c |   33 +++++++++++++++++++++------------
 4 files changed, 31 insertions(+), 17 deletions(-)

diff --git a/fs/afs/file.c b/fs/afs/file.c
index 3e25795..9c0e721 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -236,7 +236,7 @@ static void afs_invalidatepage(struct page *page, unsigned long offset)
 {
 	int ret = 1;
 
-	kenter("{%lu},%lu", page->index, offset);
+	_enter("{%lu},%lu", page->index, offset);
 
 	BUG_ON(!PageLocked(page));
 
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 515a5d1..47f5fed 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -209,11 +209,15 @@ bad_inode:
  */
 void afs_zap_data(struct afs_vnode *vnode)
 {
-	_enter("zap data {%x:%u}", vnode->fid.vid, vnode->fid.vnode);
+	_enter("{%x:%u}", vnode->fid.vid, vnode->fid.vnode);
 
 	/* nuke all the non-dirty pages that aren't locked, mapped or being
-	 * written back */
-	invalidate_remote_inode(&vnode->vfs_inode);
+	 * written back in a regular file and completely discard the pages in a
+	 * directory or symlink */
+	if (S_ISREG(vnode->vfs_inode.i_mode))
+		invalidate_remote_inode(&vnode->vfs_inode);
+	else
+		invalidate_inode_pages2(vnode->vfs_inode.i_mapping);
 }
 
 /*
diff --git a/fs/afs/super.c b/fs/afs/super.c
index d24be33..422f532 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -488,6 +488,7 @@ static struct inode *afs_alloc_inode(struct super_block *sb)
 	vnode->flags		= 1 << AFS_VNODE_UNSET;
 	vnode->cb_promised	= false;
 
+	_leave(" = %p", &vnode->vfs_inode);
 	return &vnode->vfs_inode;
 }
 
@@ -498,7 +499,7 @@ static void afs_destroy_inode(struct inode *inode)
 {
 	struct afs_vnode *vnode = AFS_FS_I(inode);
 
-	_enter("{%lu}", inode->i_ino);
+	_enter("%p{%x:%u}", inode, vnode->fid.vid, vnode->fid.vnode);
 
 	_debug("DESTROY INODE %p", inode);
 
diff --git a/fs/afs/vnode.c b/fs/afs/vnode.c
index ec81466..bea8bd9 100644
--- a/fs/afs/vnode.c
+++ b/fs/afs/vnode.c
@@ -175,24 +175,33 @@ static void afs_vnode_deleted_remotely(struct afs_vnode *vnode)
 {
 	struct afs_server *server;
 
+	_enter("{%p}", vnode->server);
+
 	set_bit(AFS_VNODE_DELETED, &vnode->flags);
 
 	server = vnode->server;
-	if (vnode->cb_promised) {
-		spin_lock(&server->cb_lock);
+	if (server) {
 		if (vnode->cb_promised) {
-			rb_erase(&vnode->cb_promise, &server->cb_promises);
-			vnode->cb_promised = false;
+			spin_lock(&server->cb_lock);
+			if (vnode->cb_promised) {
+				rb_erase(&vnode->cb_promise,
+					 &server->cb_promises);
+				vnode->cb_promised = false;
+			}
+			spin_unlock(&server->cb_lock);
 		}
-		spin_unlock(&server->cb_lock);
-	}
 
-	spin_lock(&vnode->server->fs_lock);
-	rb_erase(&vnode->server_rb, &vnode->server->fs_vnodes);
-	spin_unlock(&vnode->server->fs_lock);
+		spin_lock(&server->fs_lock);
+		rb_erase(&vnode->server_rb, &server->fs_vnodes);
+		spin_unlock(&server->fs_lock);
 
-	vnode->server = NULL;
-	afs_put_server(server);
+		vnode->server = NULL;
+		afs_put_server(server);
+	} else {
+		ASSERT(!vnode->cb_promised);
+	}
+
+	_leave("");
 }
 
 /*
@@ -225,7 +234,7 @@ void afs_vnode_finalise_status_update(struct afs_vnode *vnode,
  */
 static void afs_vnode_status_update_failed(struct afs_vnode *vnode, int ret)
 {
-	_enter("%p,%d", vnode, ret);
+	_enter("{%x:%u},%d", vnode->fid.vid, vnode->fid.vnode, ret);
 
 	spin_lock(&vnode->lock);
 

