From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/3] AFS: Implement basic file write support
Date: Tue, 08 May 2007 20:44:11 +0100
Message-ID: <20070508194411.27477.7552.stgit@warthog.cambridge.redhat.com>
References: <20070508194358.27477.74888.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	dhowells@redhat.com
To: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48299 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967998AbXEHTpE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 15:45:04 -0400
In-Reply-To: <20070508194358.27477.74888.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement support for writing to regular AFS files, including:

 (1) write

 (2) truncate

 (3) fsync, fdatasync

 (4) chmod, chown, chgrp, utime.

AFS writeback attempts to batch writes into as chunks as large as it can manage
up to the point that it writes back 65535 pages in one chunk or it meets a
locked page.

Furthermore, if a page has been written to using a particular key, then should
another write to that page use some other key, the first write will be flushed
before the second is allowed to take place.  If the first write fails due to a
security error, then the page will be scrapped and reread before the second
write takes place.

If a page is dirty and the callback on it is broken by the server, then the
dirty data is not discarded (same behaviour as NFS).

Shared-writable mappings are not supported by this patch.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 fs/afs/Makefile   |    3 
 fs/afs/afs_fs.h   |    2 
 fs/afs/dir.c      |    1 
 fs/afs/file.c     |   32 ++
 fs/afs/fsclient.c |  332 ++++++++++++++++++++-
 fs/afs/inode.c    |   47 +++
 fs/afs/internal.h |   66 ++++
 fs/afs/rxrpc.c    |   80 +++++
 fs/afs/super.c    |    3 
 fs/afs/vnode.c    |  107 +++++++
 fs/afs/write.c    |  835 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 11 files changed, 1482 insertions(+), 26 deletions(-)

diff --git a/fs/afs/Makefile b/fs/afs/Makefile
index cf83e5d..73ce561 100644
--- a/fs/afs/Makefile
+++ b/fs/afs/Makefile
@@ -22,6 +22,7 @@ kafs-objs := \
 	vlclient.o \
 	vlocation.o \
 	vnode.o \
-	volume.o
+	volume.o \
+	write.o
 
 obj-$(CONFIG_AFS_FS)  := kafs.o
diff --git a/fs/afs/afs_fs.h b/fs/afs/afs_fs.h
index 89e0d16..2198006 100644
--- a/fs/afs/afs_fs.h
+++ b/fs/afs/afs_fs.h
@@ -18,6 +18,8 @@
 enum AFS_FS_Operations {
 	FSFETCHDATA		= 130,	/* AFS Fetch file data */
 	FSFETCHSTATUS		= 132,	/* AFS Fetch file status */
+	FSSTOREDATA		= 133,	/* AFS Store file data */
+	FSSTORESTATUS		= 135,	/* AFS Store file status */
 	FSREMOVEFILE		= 136,	/* AFS Remove a file */
 	FSCREATEFILE		= 137,	/* AFS Create a file */
 	FSRENAME		= 138,	/* AFS Rename or move a file or directory */
diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index eca7bf8..ac982a8 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -56,6 +56,7 @@ const struct inode_operations afs_dir_inode_operations = {
 	.rename		= afs_rename,
 	.permission	= afs_permission,
 	.getattr	= afs_getattr,
+	.setattr	= afs_setattr,
 };
 
 static struct dentry_operations afs_fs_dentry_operations = {
diff --git a/fs/afs/file.c b/fs/afs/file.c
index 3eb3fc7..3e25795 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -15,32 +15,43 @@
 #include <linux/slab.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
+#include <linux/writeback.h>
 #include "internal.h"
 
 static int afs_readpage(struct file *file, struct page *page);
 static void afs_invalidatepage(struct page *page, unsigned long offset);
 static int afs_releasepage(struct page *page, gfp_t gfp_flags);
+static int afs_launder_page(struct page *page);
 
 const struct file_operations afs_file_operations = {
 	.open		= afs_open,
 	.release	= afs_release,
 	.llseek		= generic_file_llseek,
 	.read		= do_sync_read,
+	.write		= do_sync_write,
 	.aio_read	= generic_file_aio_read,
+	.aio_write	= afs_file_write,
 	.mmap		= generic_file_readonly_mmap,
 	.sendfile	= generic_file_sendfile,
+	.fsync		= afs_fsync,
 };
 
 const struct inode_operations afs_file_inode_operations = {
 	.getattr	= afs_getattr,
+	.setattr	= afs_setattr,
 	.permission	= afs_permission,
 };
 
 const struct address_space_operations afs_fs_aops = {
 	.readpage	= afs_readpage,
-	.set_page_dirty	= __set_page_dirty_nobuffers,
+	.set_page_dirty	= afs_set_page_dirty,
+	.launder_page	= afs_launder_page,
 	.releasepage	= afs_releasepage,
 	.invalidatepage	= afs_invalidatepage,
+	.prepare_write	= afs_prepare_write,
+	.commit_write	= afs_commit_write,
+	.writepage	= afs_writepage,
+	.writepages	= afs_writepages,
 };
 
 /*
@@ -230,11 +241,6 @@ static void afs_invalidatepage(struct page *page, unsigned long offset)
 	BUG_ON(!PageLocked(page));
 
 	if (PagePrivate(page)) {
-#ifdef AFS_CACHING_SUPPORT
-		struct afs_vnode *vnode = AFS_FS_I(page->mapping->host);
-		cachefs_uncache_page(vnode->cache,page);
-#endif
-
 		/* We release buffers only if the entire page is being
 		 * invalidated.
 		 * The get_block cached value has been unconditionally
@@ -255,19 +261,33 @@ static void afs_invalidatepage(struct page *page, unsigned long offset)
 }
 
 /*
+ * write back a dirty page
+ */
+static int afs_launder_page(struct page *page)
+{
+	_enter("{%lu}", page->index);
+
+	return 0;
+}
+
+/*
  * release a page and cleanup its private data
  */
 static int afs_releasepage(struct page *page, gfp_t gfp_flags)
 {
 	struct afs_vnode *vnode = AFS_FS_I(page->mapping->host);
+	struct afs_writeback *wb;
 
 	_enter("{{%x:%u}[%lu],%lx},%x",
 	       vnode->fid.vid, vnode->fid.vnode, page->index, page->flags,
 	       gfp_flags);
 
 	if (PagePrivate(page)) {
+		wb = (struct afs_writeback *) page_private(page);
+		ASSERT(wb != NULL);
 		set_page_private(page, 0);
 		ClearPagePrivate(page);
+		afs_put_writeback(wb);
 	}
 
 	_leave(" = 0");
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index 1e65fee..a552699 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -33,8 +33,10 @@ static void xdr_decode_AFSFid(const __be32 **_bp, struct afs_fid *fid)
  */
 static void xdr_decode_AFSFetchStatus(const __be32 **_bp,
 				      struct afs_file_status *status,
-				      struct afs_vnode *vnode)
+				      struct afs_vnode *vnode,
+				      afs_dataversion_t *store_version)
 {
+	afs_dataversion_t expected_version;
 	const __be32 *bp = *_bp;
 	umode_t mode;
 	u64 data_version, size;
@@ -101,7 +103,11 @@ static void xdr_decode_AFSFetchStatus(const __be32 **_bp,
 		vnode->vfs_inode.i_atime	= vnode->vfs_inode.i_ctime;
 	}
 
-	if (status->data_version != data_version) {
+	expected_version = status->data_version;
+	if (store_version)
+		expected_version = *store_version;
+
+	if (expected_version != data_version) {
 		status->data_version = data_version;
 		if (vnode && !test_bit(AFS_VNODE_UNSET, &vnode->flags)) {
 			_debug("vnode modified %llx on {%x:%u}",
@@ -110,6 +116,8 @@ static void xdr_decode_AFSFetchStatus(const __be32 **_bp,
 			set_bit(AFS_VNODE_MODIFIED, &vnode->flags);
 			set_bit(AFS_VNODE_ZAP_DATA, &vnode->flags);
 		}
+	} else if (store_version) {
+		status->data_version = data_version;
 	}
 }
 
@@ -156,6 +164,44 @@ static void xdr_decode_AFSVolSync(const __be32 **_bp,
 }
 
 /*
+ * encode the requested attributes into an AFSStoreStatus block
+ */
+static void xdr_encode_AFS_StoreStatus(__be32 **_bp, struct iattr *attr)
+{
+	__be32 *bp = *_bp;
+	u32 mask = 0, mtime = 0, owner = 0, group = 0, mode = 0;
+
+	mask = 0;
+	if (attr->ia_valid & ATTR_MTIME) {
+		mask |= AFS_SET_MTIME;
+		mtime = attr->ia_mtime.tv_sec;
+	}
+
+	if (attr->ia_valid & ATTR_UID) {
+		mask |= AFS_SET_OWNER;
+		owner = attr->ia_uid;
+	}
+
+	if (attr->ia_valid & ATTR_GID) {
+		mask |= AFS_SET_GROUP;
+		group = attr->ia_gid;
+	}
+
+	if (attr->ia_valid & ATTR_MODE) {
+		mask |= AFS_SET_MODE;
+		mode = attr->ia_mode & S_IALLUGO;
+	}
+
+	*bp++ = htonl(mask);
+	*bp++ = htonl(mtime);
+	*bp++ = htonl(owner);
+	*bp++ = htonl(group);
+	*bp++ = htonl(mode);	
+	*bp++ = 0;		/* segment size */
+	*_bp = bp;
+}
+
+/*
  * deliver reply data to an FS.FetchStatus
  */
 static int afs_deliver_fs_fetch_status(struct afs_call *call,
@@ -175,7 +221,7 @@ static int afs_deliver_fs_fetch_status(struct afs_call *call,
 
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
-	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode);
+	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode, NULL);
 	xdr_decode_AFSCallBack(&bp, vnode);
 	if (call->reply2)
 		xdr_decode_AFSVolSync(&bp, call->reply2);
@@ -295,7 +341,7 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 		}
 
 		bp = call->buffer;
-		xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode);
+		xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode, NULL);
 		xdr_decode_AFSCallBack(&bp, vnode);
 		if (call->reply2)
 			xdr_decode_AFSVolSync(&bp, call->reply2);
@@ -479,8 +525,8 @@ static int afs_deliver_fs_create_vnode(struct afs_call *call,
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
 	xdr_decode_AFSFid(&bp, call->reply2);
-	xdr_decode_AFSFetchStatus(&bp, call->reply3, NULL);
-	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode);
+	xdr_decode_AFSFetchStatus(&bp, call->reply3, NULL, NULL);
+	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode, NULL);
 	xdr_decode_AFSCallBack_raw(&bp, call->reply4);
 	/* xdr_decode_AFSVolSync(&bp, call->replyX); */
 
@@ -577,7 +623,7 @@ static int afs_deliver_fs_remove(struct afs_call *call,
 
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
-	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode);
+	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode, NULL);
 	/* xdr_decode_AFSVolSync(&bp, call->replyX); */
 
 	_leave(" = 0 [done]");
@@ -660,8 +706,8 @@ static int afs_deliver_fs_link(struct afs_call *call,
 
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
-	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode);
-	xdr_decode_AFSFetchStatus(&bp, &dvnode->status, dvnode);
+	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode, NULL);
+	xdr_decode_AFSFetchStatus(&bp, &dvnode->status, dvnode, NULL);
 	/* xdr_decode_AFSVolSync(&bp, call->replyX); */
 
 	_leave(" = 0 [done]");
@@ -749,8 +795,8 @@ static int afs_deliver_fs_symlink(struct afs_call *call,
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
 	xdr_decode_AFSFid(&bp, call->reply2);
-	xdr_decode_AFSFetchStatus(&bp, call->reply3, NULL);
-	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode);
+	xdr_decode_AFSFetchStatus(&bp, call->reply3, NULL, NULL);
+	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode, NULL);
 	/* xdr_decode_AFSVolSync(&bp, call->replyX); */
 
 	_leave(" = 0 [done]");
@@ -855,9 +901,10 @@ static int afs_deliver_fs_rename(struct afs_call *call,
 
 	/* unmarshall the reply once we've received all of it */
 	bp = call->buffer;
-	xdr_decode_AFSFetchStatus(&bp, &orig_dvnode->status, orig_dvnode);
+	xdr_decode_AFSFetchStatus(&bp, &orig_dvnode->status, orig_dvnode, NULL);
 	if (new_dvnode != orig_dvnode)
-		xdr_decode_AFSFetchStatus(&bp, &new_dvnode->status, new_dvnode);
+		xdr_decode_AFSFetchStatus(&bp, &new_dvnode->status, new_dvnode,
+					  NULL);
 	/* xdr_decode_AFSVolSync(&bp, call->replyX); */
 
 	_leave(" = 0 [done]");
@@ -939,3 +986,262 @@ int afs_fs_rename(struct afs_server *server,
 
 	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
 }
+
+/*
+ * deliver reply data to an FS.StoreData
+ */
+static int afs_deliver_fs_store_data(struct afs_call *call,
+				     struct sk_buff *skb, bool last)
+{
+	struct afs_vnode *vnode = call->reply;
+	const __be32 *bp;
+
+	_enter(",,%u", last);
+
+	afs_transfer_reply(call, skb);
+	if (!last) {
+		_leave(" = 0 [more]");
+		return 0;
+	}
+
+	if (call->reply_size != call->reply_max) {
+		_leave(" = -EBADMSG [%u != %u]",
+		       call->reply_size, call->reply_max);
+		return -EBADMSG;
+	}
+
+	/* unmarshall the reply once we've received all of it */
+	bp = call->buffer;
+	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode,
+				  &call->store_version);
+	/* xdr_decode_AFSVolSync(&bp, call->replyX); */
+
+	afs_pages_written_back(vnode, call);
+
+	_leave(" = 0 [done]");
+	return 0;
+}
+
+/*
+ * FS.StoreData operation type
+ */
+static const struct afs_call_type afs_RXFSStoreData = {
+	.name		= "FS.StoreData",
+	.deliver	= afs_deliver_fs_store_data,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_flat_call_destructor,
+};
+
+/*
+ * store a set of pages
+ */
+int afs_fs_store_data(struct afs_server *server, struct afs_writeback *wb,
+		      pgoff_t first, pgoff_t last,
+		      unsigned offset, unsigned to,
+		      const struct afs_wait_mode *wait_mode)
+{
+	struct afs_vnode *vnode = wb->vnode;
+	struct afs_call *call;
+	loff_t size, pos, i_size;
+	__be32 *bp;
+
+	_enter(",%x,{%x:%u},,",
+	       key_serial(wb->key), vnode->fid.vid, vnode->fid.vnode);
+
+	size = to - offset;
+	if (first != last)
+		size += (loff_t)(last - first) << PAGE_SHIFT;
+	pos = (loff_t)first << PAGE_SHIFT;
+	pos += offset;
+
+	i_size = i_size_read(&vnode->vfs_inode);
+	if (pos + size > i_size)
+		i_size = size + pos;
+
+	_debug("size %llx, at %llx, i_size %llx",
+	       (unsigned long long) size, (unsigned long long) pos,
+	       (unsigned long long) i_size);
+
+	BUG_ON(i_size > 0xffffffff); // TODO: use 64-bit store
+
+	call = afs_alloc_flat_call(&afs_RXFSStoreData,
+				   (4 + 6 + 3) * 4,
+				   (21 + 6) * 4);
+	if (!call)
+		return -ENOMEM;
+
+	call->wb = wb;
+	call->key = wb->key;
+	call->reply = vnode;
+	call->service_id = FS_SERVICE;
+	call->port = htons(AFS_FS_PORT);
+	call->mapping = vnode->vfs_inode.i_mapping;
+	call->first = first;
+	call->last = last;
+	call->first_offset = offset;
+	call->last_to = to;
+	call->send_pages = true;
+	call->store_version = vnode->status.data_version + 1;
+
+	/* marshall the parameters */
+	bp = call->request;
+	*bp++ = htonl(FSSTOREDATA);
+	*bp++ = htonl(vnode->fid.vid);
+	*bp++ = htonl(vnode->fid.vnode);
+	*bp++ = htonl(vnode->fid.unique);
+
+	*bp++ = 0; /* mask */
+	*bp++ = 0; /* mtime */
+	*bp++ = 0; /* owner */
+	*bp++ = 0; /* group */
+	*bp++ = 0; /* unix mode */
+	*bp++ = 0; /* segment size */
+
+	*bp++ = htonl(pos);
+	*bp++ = htonl(size);
+	*bp++ = htonl(i_size);
+
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+}
+
+/*
+ * deliver reply data to an FS.StoreStatus
+ */
+static int afs_deliver_fs_store_status(struct afs_call *call,
+				       struct sk_buff *skb, bool last)
+{
+	afs_dataversion_t *store_version;
+	struct afs_vnode *vnode = call->reply;
+	const __be32 *bp;
+
+	_enter(",,%u", last);
+
+	afs_transfer_reply(call, skb);
+	if (!last) {
+		_leave(" = 0 [more]");
+		return 0;
+	}
+
+	if (call->reply_size != call->reply_max) {
+		_leave(" = -EBADMSG [%u != %u]",
+		       call->reply_size, call->reply_max);
+		return -EBADMSG;
+	}
+
+	/* unmarshall the reply once we've received all of it */
+	store_version = NULL;
+	if (call->operation_ID == FSSTOREDATA)
+		store_version = &call->store_version;
+
+	bp = call->buffer;
+	xdr_decode_AFSFetchStatus(&bp, &vnode->status, vnode, store_version);
+	/* xdr_decode_AFSVolSync(&bp, call->replyX); */
+
+	_leave(" = 0 [done]");
+	return 0;
+}
+
+/*
+ * FS.StoreStatus operation type
+ */
+static const struct afs_call_type afs_RXFSStoreStatus = {
+	.name		= "FS.StoreStatus",
+	.deliver	= afs_deliver_fs_store_status,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_flat_call_destructor,
+};
+
+static const struct afs_call_type afs_RXFSStoreData_as_Status = {
+	.name		= "FS.StoreData",
+	.deliver	= afs_deliver_fs_store_status,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_flat_call_destructor,
+};
+
+/*
+ * set the attributes on a file, using FS.StoreData rather than FS.StoreStatus
+ * so as to alter the file size also
+ */
+static int afs_fs_setattr_size(struct afs_server *server, struct key *key,
+			       struct afs_vnode *vnode, struct iattr *attr,
+			       const struct afs_wait_mode *wait_mode)
+{
+	struct afs_call *call;
+	__be32 *bp;
+
+	_enter(",%x,{%x:%u},,",
+	       key_serial(key), vnode->fid.vid, vnode->fid.vnode);
+
+	ASSERT(attr->ia_valid & ATTR_SIZE);
+	ASSERTCMP(attr->ia_size, <=, 0xffffffff); // TODO: use 64-bit store
+
+	call = afs_alloc_flat_call(&afs_RXFSStoreData_as_Status,
+				   (4 + 6 + 3) * 4,
+				   (21 + 6) * 4);
+	if (!call)
+		return -ENOMEM;
+
+	call->key = key;
+	call->reply = vnode;
+	call->service_id = FS_SERVICE;
+	call->port = htons(AFS_FS_PORT);
+	call->store_version = vnode->status.data_version + 1;
+	call->operation_ID = FSSTOREDATA;
+
+	/* marshall the parameters */
+	bp = call->request;
+	*bp++ = htonl(FSSTOREDATA);
+	*bp++ = htonl(vnode->fid.vid);
+	*bp++ = htonl(vnode->fid.vnode);
+	*bp++ = htonl(vnode->fid.unique);
+
+	xdr_encode_AFS_StoreStatus(&bp, attr);
+
+	*bp++ = 0;				/* position of start of write */
+	*bp++ = 0;				/* size of write */
+	*bp++ = htonl(attr->ia_size);		/* new file length */
+
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+}
+
+/*
+ * set the attributes on a file, using FS.StoreData if there's a change in file
+ * size, and FS.StoreStatus otherwise
+ */
+int afs_fs_setattr(struct afs_server *server, struct key *key,
+		   struct afs_vnode *vnode, struct iattr *attr,
+		   const struct afs_wait_mode *wait_mode)
+{
+	struct afs_call *call;
+	__be32 *bp;
+
+	if (attr->ia_valid & ATTR_SIZE)
+		return afs_fs_setattr_size(server, key, vnode, attr,
+					   wait_mode);
+
+	_enter(",%x,{%x:%u},,",
+	       key_serial(key), vnode->fid.vid, vnode->fid.vnode);
+
+	call = afs_alloc_flat_call(&afs_RXFSStoreStatus,
+				   (4 + 6) * 4,
+				   (21 + 6) * 4);
+	if (!call)
+		return -ENOMEM;
+
+	call->key = key;
+	call->reply = vnode;
+	call->service_id = FS_SERVICE;
+	call->port = htons(AFS_FS_PORT);
+	call->operation_ID = FSSTORESTATUS;
+
+	/* marshall the parameters */
+	bp = call->request;
+	*bp++ = htonl(FSSTORESTATUS);
+	*bp++ = htonl(vnode->fid.vid);
+	*bp++ = htonl(vnode->fid.vnode);
+	*bp++ = htonl(vnode->fid.unique);
+
+	xdr_encode_AFS_StoreStatus(&bp, attr);
+
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+}
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 9c984cc..515a5d1 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -209,7 +209,7 @@ bad_inode:
  */
 void afs_zap_data(struct afs_vnode *vnode)
 {
-	kenter("zap data {%x:%u}", vnode->fid.vid, vnode->fid.vnode);
+	_enter("zap data {%x:%u}", vnode->fid.vid, vnode->fid.vnode);
 
 	/* nuke all the non-dirty pages that aren't locked, mapped or being
 	 * written back */
@@ -334,6 +334,7 @@ void afs_clear_inode(struct inode *inode)
 		vnode->server = NULL;
 	}
 
+	ASSERT(list_empty(&vnode->writebacks));
 	ASSERT(!vnode->cb_promised);
 
 #ifdef AFS_CACHING_SUPPORT
@@ -350,3 +351,47 @@ void afs_clear_inode(struct inode *inode)
 
 	_leave("");
 }
+
+/*
+ * set the attributes of an inode
+ */
+int afs_setattr(struct dentry *dentry, struct iattr *attr)
+{
+	struct afs_vnode *vnode = AFS_FS_I(dentry->d_inode);
+	struct key *key;
+	int ret;
+
+	_enter("{%x:%u},{n=%s},%x",
+	       vnode->fid.vid, vnode->fid.vnode, dentry->d_name.name,
+	       attr->ia_valid);
+
+	if (!(attr->ia_valid & (ATTR_SIZE | ATTR_MODE | ATTR_UID | ATTR_GID |
+				ATTR_MTIME))) {
+		_leave(" = 0 [unsupported]");
+		return 0;
+	}
+
+	/* flush any dirty data outstanding on a regular file */
+	if (S_ISREG(vnode->vfs_inode.i_mode)) {
+		filemap_write_and_wait(vnode->vfs_inode.i_mapping);
+		afs_writeback_all(vnode);
+	}
+
+	if (attr->ia_valid & ATTR_FILE) {
+		key = attr->ia_file->private_data;
+	} else {
+		key = afs_request_key(vnode->volume->cell);
+		if (IS_ERR(key)) {
+			ret = PTR_ERR(key);
+			goto error;
+		}
+	}
+
+	ret = afs_vnode_setattr(vnode, key, attr);
+	if (!(attr->ia_valid & ATTR_FILE))
+		key_put(key);
+
+error:
+	_leave(" = %d", ret);
+	return ret;
+}
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 881b7dc..5545f90 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -21,6 +21,7 @@
 
 #define AFS_CELL_MAX_ADDRS 15
 
+struct pagevec;
 struct afs_call;
 
 typedef enum {
@@ -75,12 +76,15 @@ struct afs_call {
 	struct key		*key;		/* security for this call */
 	struct afs_server	*server;	/* server affected by incoming CM call */
 	void			*request;	/* request data (first part) */
-	void			*request2;	/* request data (second part) */
+	struct address_space	*mapping;	/* page set */
+	struct afs_writeback	*wb;		/* writeback being performed */
 	void			*buffer;	/* reply receive buffer */
 	void			*reply;		/* reply buffer (first part) */
 	void			*reply2;	/* reply buffer (second part) */
 	void			*reply3;	/* reply buffer (third part) */
 	void			*reply4;	/* reply buffer (fourth part) */
+	pgoff_t			first;		/* first page in mapping to deal with */
+	pgoff_t			last;		/* last page in mapping to deal with */
 	enum {					/* call state */
 		AFS_CALL_REQUESTING,	/* request is being sent for outgoing call */
 		AFS_CALL_AWAIT_REPLY,	/* awaiting reply to outgoing call */
@@ -97,14 +101,18 @@ struct afs_call {
 	unsigned		request_size;	/* size of request data */
 	unsigned		reply_max;	/* maximum size of reply */
 	unsigned		reply_size;	/* current size of reply */
+	unsigned		first_offset;	/* offset into mapping[first] */
+	unsigned		last_to;	/* amount of mapping[last] */
 	unsigned short		offset;		/* offset into received data store */
 	unsigned char		unmarshall;	/* unmarshalling phase */
 	bool			incoming;	/* T if incoming call */
+	bool			send_pages;	/* T if data from mapping should be sent */
 	u16			service_id;	/* RxRPC service ID to call */
 	__be16			port;		/* target UDP port */
 	__be32			operation_ID;	/* operation ID for an incoming call */
 	u32			count;		/* count for use in unmarshalling */
 	__be32			tmp;		/* place to extract temporary data */
+	afs_dataversion_t	store_version;	/* updated version expected from store */
 };
 
 struct afs_call_type {
@@ -124,6 +132,32 @@ struct afs_call_type {
 };
 
 /*
+ * record of an outstanding writeback on a vnode
+ */
+struct afs_writeback {
+	struct list_head	link;		/* link in vnode->writebacks */
+	struct work_struct	writer;		/* work item to perform the writeback */
+	struct afs_vnode	*vnode;		/* vnode to which this write applies */
+	struct key		*key;		/* owner of this write */
+	wait_queue_head_t	waitq;		/* completion and ready wait queue */
+	pgoff_t			first;		/* first page in batch */
+	pgoff_t			point;		/* last page in current store op */
+	pgoff_t			last;		/* last page in batch (inclusive) */
+	unsigned		offset_first;	/* offset into first page of start of write */
+	unsigned		to_last;	/* offset into last page of end of write */
+	int			num_conflicts;	/* count of conflicting writes in list */
+	int			usage;
+	bool			conflicts;	/* T if has dependent conflicts */
+	enum {
+		AFS_WBACK_SYNCING,		/* synchronisation being performed */
+		AFS_WBACK_PENDING,		/* write pending */
+		AFS_WBACK_CONFLICTING,		/* conflicting writes posted */
+		AFS_WBACK_WRITING,		/* writing back */
+		AFS_WBACK_COMPLETE		/* the writeback record has been unlinked */
+	} state __attribute__((packed));
+};
+
+/*
  * AFS superblock private data
  * - there's one superblock per volume
  */
@@ -305,6 +339,7 @@ struct afs_vnode {
 	wait_queue_head_t	update_waitq;	/* status fetch waitqueue */
 	int			update_cnt;	/* number of outstanding ops that will update the
 						 * status */
+	spinlock_t		writeback_lock;	/* lock for writebacks */
 	spinlock_t		lock;		/* waitqueue/flags lock */
 	unsigned long		flags;
 #define AFS_VNODE_CB_BROKEN	0		/* set if vnode's callback was broken */
@@ -316,6 +351,8 @@ struct afs_vnode {
 
 	long			acl_order;	/* ACL check count (callback break count) */
 
+	struct list_head	writebacks;	/* alterations in pagecache that need writing */
+
 	/* outstanding callback notification on this file */
 	struct rb_node		server_rb;	/* link in server->fs_vnodes */
 	struct rb_node		cb_promise;	/* link in server->cb_promises */
@@ -463,6 +500,12 @@ extern int afs_fs_rename(struct afs_server *, struct key *,
 			 struct afs_vnode *, const char *,
 			 struct afs_vnode *, const char *,
 			 const struct afs_wait_mode *);
+extern int afs_fs_store_data(struct afs_server *, struct afs_writeback *,
+			     pgoff_t, pgoff_t, unsigned, unsigned,
+			     const struct afs_wait_mode *);
+extern int afs_fs_setattr(struct afs_server *, struct key *,
+			  struct afs_vnode *, struct iattr *,
+			  const struct afs_wait_mode *);
 
 /*
  * inode.c
@@ -473,6 +516,7 @@ extern struct inode *afs_iget(struct super_block *, struct key *,
 extern void afs_zap_data(struct afs_vnode *);
 extern int afs_validate(struct afs_vnode *, struct key *);
 extern int afs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+extern int afs_setattr(struct dentry *, struct iattr *);
 extern void afs_clear_inode(struct inode *);
 
 /*
@@ -626,6 +670,9 @@ extern int afs_vnode_symlink(struct afs_vnode *, struct key *, const char *,
 			     struct afs_file_status *, struct afs_server **);
 extern int afs_vnode_rename(struct afs_vnode *, struct afs_vnode *,
 			    struct key *, const char *, const char *);
+extern int afs_vnode_store_data(struct afs_writeback *, pgoff_t, pgoff_t,
+				unsigned, unsigned);
+extern int afs_vnode_setattr(struct afs_vnode *, struct key *, struct iattr *);
 
 /*
  * volume.c
@@ -642,6 +689,23 @@ extern struct afs_server *afs_volume_pick_fileserver(struct afs_vnode *);
 extern int afs_volume_release_fileserver(struct afs_vnode *,
 					 struct afs_server *, int);
 
+/*
+ * write.c
+ */
+extern int afs_set_page_dirty(struct page *);
+extern void afs_put_writeback(struct afs_writeback *);
+extern int afs_prepare_write(struct file *, struct page *, unsigned, unsigned);
+extern int afs_commit_write(struct file *, struct page *, unsigned, unsigned);
+extern int afs_writepage(struct page *, struct writeback_control *);
+extern int afs_writepages(struct address_space *, struct writeback_control *);
+extern int afs_write_inode(struct inode *, int);
+extern void afs_pages_written_back(struct afs_vnode *, struct afs_call *);
+extern ssize_t afs_file_write(struct kiocb *, const struct iovec *,
+			      unsigned long, loff_t);
+extern int afs_writeback_all(struct afs_vnode *);
+extern int afs_fsync(struct file *, struct dentry *, int);
+
+
 /*****************************************************************************/
 /*
  * debug tracing
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 222c1a3..04189c4 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -237,6 +237,70 @@ void afs_flat_call_destructor(struct afs_call *call)
 }
 
 /*
+ * attach the data from a bunch of pages on an inode to a call
+ */
+int afs_send_pages(struct afs_call *call, struct msghdr *msg, struct kvec *iov)
+{
+	struct page *pages[8];
+	unsigned count, n, loop, offset, to;
+	pgoff_t first = call->first, last = call->last;
+	int ret;
+
+	_enter("");
+
+	offset = call->first_offset;
+	call->first_offset = 0;
+
+	do {
+		_debug("attach %lx-%lx", first, last);
+
+		count = last - first + 1;
+		if (count > ARRAY_SIZE(pages))
+			count = ARRAY_SIZE(pages);
+		n = find_get_pages_contig(call->mapping, first, count, pages);
+		ASSERTCMP(n, ==, count);
+
+		loop = 0;
+		do {
+			msg->msg_flags = 0;
+			to = PAGE_SIZE;
+			if (first + loop >= last)
+				to = call->last_to;
+			else
+				msg->msg_flags = MSG_MORE;
+			iov->iov_base = kmap(pages[loop]) + offset;
+			iov->iov_len = to - offset;
+			offset = 0;
+
+			_debug("- range %u-%u%s",
+			       offset, to, msg->msg_flags ? " [more]" : "");
+			msg->msg_iov = (struct iovec *) iov;
+			msg->msg_iovlen = 1;
+
+			/* have to change the state *before* sending the last
+			 * packet as RxRPC might give us the reply before it
+			 * returns from sending the request */
+			if (first + loop >= last)
+				call->state = AFS_CALL_AWAIT_REPLY;
+			ret = rxrpc_kernel_send_data(call->rxcall, msg,
+						     to - offset);
+			kunmap(pages[loop]);
+			if (ret < 0)
+				break;
+		} while (++loop < count);
+		first += count;
+
+		for (loop = 0; loop < count; loop++)
+			put_page(pages[loop]);
+		if (ret < 0)
+			break;
+	} while (first < last);
+
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
  * initiate a call
  */
 int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
@@ -253,8 +317,9 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	ASSERT(call->type != NULL);
 	ASSERT(call->type->name != NULL);
 
-	_debug("MAKE %p{%s} [%d]",
-	       call, call->type->name, atomic_read(&afs_outstanding_calls));
+	_debug("____MAKE %p{%s,%x} [%d]____",
+	       call, call->type->name, key_serial(call->key),
+	       atomic_read(&afs_outstanding_calls));
 
 	call->wait_mode = wait_mode;
 	INIT_WORK(&call->async_work, afs_process_async_call);
@@ -289,16 +354,23 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	msg.msg_iovlen		= 1;
 	msg.msg_control		= NULL;
 	msg.msg_controllen	= 0;
-	msg.msg_flags		= 0;
+	msg.msg_flags		= (call->send_pages ? MSG_MORE : 0);
 
 	/* have to change the state *before* sending the last packet as RxRPC
 	 * might give us the reply before it returns from sending the
 	 * request */
-	call->state = AFS_CALL_AWAIT_REPLY;
+	if (!call->send_pages)
+		call->state = AFS_CALL_AWAIT_REPLY;
 	ret = rxrpc_kernel_send_data(rxcall, &msg, call->request_size);
 	if (ret < 0)
 		goto error_do_abort;
 
+	if (call->send_pages) {
+		ret = afs_send_pages(call, &msg, iov);
+		if (ret < 0)
+			goto error_do_abort;
+	}
+
 	/* at this point, an async call may no longer exist as it may have
 	 * already completed */
 	return wait_mode->wait(call);
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 7030d76..b9b9eed 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -50,6 +50,7 @@ static const struct super_operations afs_super_ops = {
 	.statfs		= simple_statfs,
 	.alloc_inode	= afs_alloc_inode,
 	.drop_inode	= generic_delete_inode,
+	.write_inode	= afs_write_inode,
 	.destroy_inode	= afs_destroy_inode,
 	.clear_inode	= afs_clear_inode,
 	.umount_begin	= afs_umount_begin,
@@ -459,7 +460,9 @@ static void afs_i_init_once(void *_vnode, struct kmem_cache *cachep,
 		init_waitqueue_head(&vnode->update_waitq);
 		mutex_init(&vnode->permits_lock);
 		mutex_init(&vnode->validate_lock);
+		spin_lock_init(&vnode->writeback_lock);
 		spin_lock_init(&vnode->lock);
+		INIT_LIST_HEAD(&vnode->writebacks);
 		INIT_WORK(&vnode->cb_broken_work, afs_broken_callback_work);
 	}
 }
diff --git a/fs/afs/vnode.c b/fs/afs/vnode.c
index 0e37f99..ec81466 100644
--- a/fs/afs/vnode.c
+++ b/fs/afs/vnode.c
@@ -753,3 +753,110 @@ no_server:
 	_leave(" = %ld [cnt %d]", PTR_ERR(server), orig_dvnode->update_cnt);
 	return PTR_ERR(server);
 }
+
+/*
+ * write to a file
+ */
+int afs_vnode_store_data(struct afs_writeback *wb, pgoff_t first, pgoff_t last,
+			 unsigned offset, unsigned to)
+{
+	struct afs_server *server;
+	struct afs_vnode *vnode = wb->vnode;
+	int ret;
+
+	_enter("%s{%x:%u.%u},%x,%lx,%lx,%x,%x",
+	       vnode->volume->vlocation->vldb.name,
+	       vnode->fid.vid,
+	       vnode->fid.vnode,
+	       vnode->fid.unique,
+	       key_serial(wb->key),
+	       first, last, offset, to);
+
+	/* this op will fetch the status */
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
+		ret = afs_fs_store_data(server, wb, first, last, offset, to,
+					&afs_sync_call);
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
+	_leave(" = %d", ret);
+	return ret;
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
+ * set the attributes on a file
+ */
+int afs_vnode_setattr(struct afs_vnode *vnode, struct key *key,
+		      struct iattr *attr)
+{
+	struct afs_server *server;
+	int ret;
+
+	_enter("%s{%x:%u.%u},%x",
+	       vnode->volume->vlocation->vldb.name,
+	       vnode->fid.vid,
+	       vnode->fid.vnode,
+	       vnode->fid.unique,
+	       key_serial(key));
+
+	/* this op will fetch the status */
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
+		ret = afs_fs_setattr(server, key, vnode, attr, &afs_sync_call);
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
+	_leave(" = %d", ret);
+	return ret;
+
+no_server:
+	spin_lock(&vnode->lock);
+	vnode->update_cnt--;
+	ASSERTCMP(vnode->update_cnt, >=, 0);
+	spin_unlock(&vnode->lock);
+	return PTR_ERR(server);
+}
diff --git a/fs/afs/write.c b/fs/afs/write.c
new file mode 100644
index 0000000..256d0a9
--- /dev/null
+++ b/fs/afs/write.c
@@ -0,0 +1,835 @@
+/* handling of writes to regular files and writing back to the server
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
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/pagemap.h>
+#include <linux/writeback.h>
+#include <linux/pagevec.h>
+#include "internal.h"
+
+static int afs_write_back_from_locked_page(struct afs_writeback *wb,
+					   struct page *page);
+
+/*
+ * mark a page as having been made dirty and thus needing writeback
+ */
+int afs_set_page_dirty(struct page *page)
+{
+	_enter("");
+	return __set_page_dirty_nobuffers(page);
+}
+
+/*
+ * unlink a writeback record because its usage has reached zero
+ * - must be called with the wb->vnode->writeback_lock held
+ */
+static void afs_unlink_writeback(struct afs_writeback *wb)
+{
+	struct afs_writeback *front;
+	struct afs_vnode *vnode = wb->vnode;
+
+	list_del_init(&wb->link);
+	if (!list_empty(&vnode->writebacks)) {
+		/* if an fsync rises to the front of the queue then wake it
+		 * up */
+		front = list_entry(vnode->writebacks.next,
+				   struct afs_writeback, link);
+		if (front->state == AFS_WBACK_SYNCING) {
+			_debug("wake up sync");
+			front->state = AFS_WBACK_COMPLETE;
+			wake_up(&front->waitq);
+		}
+	}
+}
+
+/*
+ * free a writeback record
+ */
+static void afs_free_writeback(struct afs_writeback *wb)
+{
+	_enter("");
+	key_put(wb->key);
+	kfree(wb);
+}
+
+/*
+ * dispose of a reference to a writeback record
+ */
+void afs_put_writeback(struct afs_writeback *wb)
+{
+	struct afs_vnode *vnode = wb->vnode;
+
+	_enter("{%d}", wb->usage);
+
+	spin_lock(&vnode->writeback_lock);
+	if (--wb->usage == 0)
+		afs_unlink_writeback(wb);
+	else
+		wb = NULL;
+	spin_unlock(&vnode->writeback_lock);
+	if (wb)
+		afs_free_writeback(wb);
+}
+
+/*
+ * partly or wholly fill a page that's under preparation for writing
+ */
+static int afs_fill_page(struct afs_vnode *vnode, struct key *key,
+			 unsigned start, unsigned len, struct page *page)
+{
+	int ret;
+
+	_enter(",,%u,%u", start, len);
+
+	ASSERTCMP(start + len, <=, PAGE_SIZE);
+
+	ret = afs_vnode_fetch_data(vnode, key, start, len, page);
+	if (ret < 0) {
+		if (ret == -ENOENT) {
+			_debug("got NOENT from server"
+			       " - marking file deleted and stale");
+			set_bit(AFS_VNODE_DELETED, &vnode->flags);
+			ret = -ESTALE;
+		}
+	}
+
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * prepare a page for being written to
+ */
+static int afs_prepare_page(struct afs_vnode *vnode, struct page *page,
+			    struct key *key, unsigned offset, unsigned to)
+{
+	unsigned eof, tail, start, stop, len;
+	loff_t i_size, pos;
+	void *p;
+	int ret;
+
+	_enter("");
+
+	if (offset == 0 && to == PAGE_SIZE)
+		return 0;
+
+	p = kmap(page);
+
+	i_size = i_size_read(&vnode->vfs_inode);
+	pos = (loff_t) page->index << PAGE_SHIFT;
+	if (pos >= i_size) {
+		/* partial write, page beyond EOF */
+		_debug("beyond");
+		if (offset > 0)
+			memset(p, 0, offset);
+		if (to < PAGE_SIZE)
+			memset(p + to, 0, PAGE_SIZE - to);
+		kunmap(page);
+		return 0;
+	}
+
+	if (i_size - pos >= PAGE_SIZE) {
+		/* partial write, page entirely before EOF */
+		_debug("before");
+		tail = eof = PAGE_SIZE;
+	} else {
+		/* partial write, page overlaps EOF */
+		eof = i_size - pos;
+		_debug("overlap %u", eof);
+		tail = max(eof, to);
+		if (tail < PAGE_SIZE)
+			memset(p + tail, 0, PAGE_SIZE - tail);
+		if (offset > eof)
+			memset(p + eof, 0, PAGE_SIZE - eof);
+	}
+
+	kunmap(p);
+
+	ret = 0;
+	if (offset > 0 || eof > to) {
+		/* need to fill one or two bits that aren't going to be written
+		 * (cover both fillers in one read if there are two) */
+		start = (offset > 0) ? 0 : to;
+		stop = (eof > to) ? eof : offset;
+		len = stop - start;
+		_debug("wr=%u-%u av=0-%u rd=%u@%u",
+		       offset, to, eof, start, len);
+		ret = afs_fill_page(vnode, key, start, len, page);
+	}
+
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * prepare to perform part of a write to a page
+ * - the caller holds the page locked, preventing it from being written out or
+ *   modified by anyone else
+ */
+int afs_prepare_write(struct file *file, struct page *page,
+		      unsigned offset, unsigned to)
+{
+	struct afs_writeback *candidate, *wb;
+	struct afs_vnode *vnode = AFS_FS_I(file->f_dentry->d_inode);
+	struct key *key = file->private_data;
+	pgoff_t index;
+	int ret;
+
+	_enter("{%x:%u},{%lx},%u,%u",
+	       vnode->fid.vid, vnode->fid.vnode, page->index, offset, to);
+
+	candidate = kzalloc(sizeof(*candidate), GFP_KERNEL);
+	if (!candidate)
+		return -ENOMEM;
+	candidate->vnode = vnode;
+	candidate->first = candidate->last = page->index;
+	candidate->offset_first = offset;
+	candidate->to_last = to;
+	candidate->usage = 1;
+	candidate->state = AFS_WBACK_PENDING;
+	init_waitqueue_head(&candidate->waitq);
+
+	if (!PageUptodate(page)) {
+		_debug("not up to date");
+		ret = afs_prepare_page(vnode, page, key, offset, to);
+		if (ret < 0) {
+			kfree(candidate);
+			_leave(" = %d [prep]", ret);
+			return ret;
+		}
+		SetPageUptodate(page);
+	}
+
+try_again:
+	index = page->index;
+	spin_lock(&vnode->writeback_lock);
+
+	/* see if this page is already pending a writeback under a suitable key
+	 * - if so we can just join onto that one */
+	wb = (struct afs_writeback *) page_private(page);
+	if (wb) {
+		if (wb->key == key && wb->state == AFS_WBACK_PENDING)
+			goto subsume_in_current_wb;
+		goto flush_conflicting_wb;
+	}
+
+	if (index > 0) {
+		/* see if we can find an already pending writeback that we can
+		 * append this page to */
+		list_for_each_entry(wb, &vnode->writebacks, link) {
+			if (wb->last == index - 1 && wb->key == key &&
+			    wb->state == AFS_WBACK_PENDING)
+				goto append_to_previous_wb;
+		}
+	}
+
+	list_add_tail(&candidate->link, &vnode->writebacks);
+	candidate->key = key_get(key);
+	spin_unlock(&vnode->writeback_lock);
+	SetPagePrivate(page);
+	set_page_private(page, (unsigned long) candidate);
+	_leave(" = 0 [new]");
+	return 0;
+
+subsume_in_current_wb:
+	_debug("subsume");
+	ASSERTRANGE(wb->first, <=, index, <=, wb->last);
+	if (index == wb->first && offset < wb->offset_first)
+		wb->offset_first = offset;
+	if (index == wb->last && to > wb->to_last)
+		wb->to_last = to;
+	spin_unlock(&vnode->writeback_lock);
+	kfree(candidate);
+	_leave(" = 0 [sub]");
+	return 0;
+
+append_to_previous_wb:
+	_debug("append into %lx-%lx", wb->first, wb->last);
+	wb->usage++;
+	wb->last++;
+	wb->to_last = to;
+	spin_unlock(&vnode->writeback_lock);
+	SetPagePrivate(page);
+	set_page_private(page, (unsigned long) wb);
+	kfree(candidate);
+	_leave(" = 0 [app]");
+	return 0;
+
+	/* the page is currently bound to another context, so if it's dirty we
+	 * need to flush it before we can use the new context */
+flush_conflicting_wb:
+	_debug("flush conflict");
+	if (wb->state == AFS_WBACK_PENDING)
+		wb->state = AFS_WBACK_CONFLICTING;
+	spin_unlock(&vnode->writeback_lock);
+	if (PageDirty(page)) {
+		ret = afs_write_back_from_locked_page(wb, page);
+		if (ret < 0) {
+			afs_put_writeback(candidate);
+			_leave(" = %d", ret);
+			return ret;
+		}
+	}
+
+	/* the page holds a ref on the writeback record */
+	afs_put_writeback(wb);
+	set_page_private(page, 0);
+	ClearPagePrivate(page);
+	goto try_again;
+}
+
+/*
+ * finalise part of a write to a page
+ */
+int afs_commit_write(struct file *file, struct page *page,
+		     unsigned offset, unsigned to)
+{
+	struct afs_vnode *vnode = AFS_FS_I(file->f_dentry->d_inode);
+	loff_t i_size, maybe_i_size;
+
+	_enter("{%x:%u},{%lx},%u,%u",
+	       vnode->fid.vid, vnode->fid.vnode, page->index, offset, to);
+
+	maybe_i_size = (loff_t) page->index << PAGE_SHIFT;
+	maybe_i_size += to;
+
+	i_size = i_size_read(&vnode->vfs_inode);
+	if (maybe_i_size > i_size) {
+		spin_lock(&vnode->writeback_lock);
+		i_size = i_size_read(&vnode->vfs_inode);
+		if (maybe_i_size > i_size)
+			i_size_write(&vnode->vfs_inode, maybe_i_size);
+		spin_unlock(&vnode->writeback_lock);
+	}
+
+	set_page_dirty(page);
+
+	if (PageDirty(page))
+		_debug("dirtied");
+
+	return 0;
+}
+
+/*
+ * kill all the pages in the given range
+ */
+static void afs_kill_pages(struct afs_vnode *vnode, bool error,
+			   pgoff_t first, pgoff_t last)
+{
+	struct pagevec pv;
+	unsigned count, loop;
+
+	_enter("{%x:%u},%lx-%lx",
+	       vnode->fid.vid, vnode->fid.vnode, first, last);
+
+	pagevec_init(&pv, 0);
+
+	do {
+		_debug("kill %lx-%lx", first, last);
+
+		count = last - first + 1;
+		if (count > PAGEVEC_SIZE)
+			count = PAGEVEC_SIZE;
+		pv.nr = find_get_pages_contig(vnode->vfs_inode.i_mapping,
+					      first, count, pv.pages);
+		ASSERTCMP(pv.nr, ==, count);
+
+		for (loop = 0; loop < count; loop++) {
+			ClearPageUptodate(pv.pages[loop]);
+			if (error)
+				SetPageError(pv.pages[loop]);
+			end_page_writeback(pv.pages[loop]);
+		}
+
+		__pagevec_release(&pv);
+	} while (first < last);
+
+	_leave("");
+}
+
+/*
+ * synchronously write back the locked page and any subsequent non-locked dirty
+ * pages also covered by the same writeback record
+ */
+static int afs_write_back_from_locked_page(struct afs_writeback *wb,
+					   struct page *primary_page)
+{
+	struct page *pages[8], *page;
+	unsigned long count;
+	unsigned n, offset, to;
+	pgoff_t start, first, last;
+	int loop, ret;
+
+	_enter(",%lx", primary_page->index);
+
+	count = 1;
+	if (!clear_page_dirty_for_io(primary_page))
+		BUG();
+	if (test_set_page_writeback(primary_page))
+		BUG();
+
+	/* find all consecutive lockable dirty pages, stopping when we find a
+	 * page that is not immediately lockable, is not dirty or is missing,
+	 * or we reach the end of the range */
+	start = primary_page->index;
+	if (start >= wb->last)
+		goto no_more;
+	start++;
+	do {
+		_debug("more %lx [%lx]", start, count);
+		n = wb->last - start + 1;
+		if (n > ARRAY_SIZE(pages))
+			n = ARRAY_SIZE(pages);
+		n = find_get_pages_contig(wb->vnode->vfs_inode.i_mapping,
+					  start, n, pages);
+		_debug("fgpc %u", n);
+		if (n == 0)
+			goto no_more;
+		if (pages[0]->index != start) {
+			for (n--; n >= 0; n--)
+				put_page(pages[n]);
+			goto no_more;
+		}
+
+		for (loop = 0; loop < n; loop++) {
+			page = pages[loop];
+			if (page->index > wb->last)
+				break;
+			if (TestSetPageLocked(page))
+				break;
+			if (!PageDirty(page) ||
+			    page_private(page) != (unsigned long) wb) {
+				unlock_page(page);
+				break;
+			}
+			if (!clear_page_dirty_for_io(page))
+				BUG();
+			if (test_set_page_writeback(page))
+				BUG();
+			unlock_page(page);
+			put_page(page);
+		}
+		count += loop;
+		if (loop < n) {
+			for (; loop < n; loop++)
+				put_page(pages[loop]);
+			goto no_more;
+		}
+
+		start += loop;
+	} while (start <= wb->last && count < 65536);
+
+no_more:
+	/* we now have a contiguous set of dirty pages, each with writeback set
+	 * and the dirty mark cleared; the first page is locked and must remain
+	 * so, all the rest are unlocked */
+	first = primary_page->index;
+	last = first + count - 1;
+
+	offset = (first == wb->first) ? wb->offset_first : 0;
+	to = (last == wb->last) ? wb->to_last : PAGE_SIZE;
+
+	_debug("write back %lx[%u..] to %lx[..%u]", first, offset, last, to);
+
+	ret = afs_vnode_store_data(wb, first, last, offset, to);
+	if (ret < 0) {
+		switch (ret) {
+		case -EDQUOT:
+		case -ENOSPC:
+			set_bit(AS_ENOSPC,
+				&wb->vnode->vfs_inode.i_mapping->flags);
+			break;
+		case -EROFS:
+		case -EIO:
+		case -EREMOTEIO:
+		case -EFBIG:
+		case -ENOENT:
+		case -ENOMEDIUM:
+		case -ENXIO:
+			afs_kill_pages(wb->vnode, true, first, last);
+			set_bit(AS_EIO, &wb->vnode->vfs_inode.i_mapping->flags);
+			break;
+		case -EACCES:
+		case -EPERM:
+		case -ENOKEY:
+		case -EKEYEXPIRED:
+		case -EKEYREJECTED:
+		case -EKEYREVOKED:
+			afs_kill_pages(wb->vnode, false, first, last);
+			break;
+		default:
+			break;
+		}
+	} else {
+		ret = count;
+	}
+
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * write a page back to the server
+ * - the caller locked the page for us
+ */
+int afs_writepage(struct page *page, struct writeback_control *wbc)
+{
+	struct backing_dev_info *bdi = page->mapping->backing_dev_info;
+	struct afs_writeback *wb;
+	int ret;
+
+	_enter("{%lx},", page->index);
+
+	if (wbc->sync_mode != WB_SYNC_NONE)
+		wait_on_page_writeback(page);
+
+	if (PageWriteback(page) || !PageDirty(page)) {
+		unlock_page(page);
+		return 0;
+	}
+
+	wb = (struct afs_writeback *) page_private(page);
+	ASSERT(wb != NULL);
+
+	ret = afs_write_back_from_locked_page(wb, page);
+	unlock_page(page);
+	if (ret < 0) {
+		_leave(" = %d", ret);
+		return 0;
+	}
+
+	wbc->nr_to_write -= ret;
+	if (wbc->nonblocking && bdi_write_congested(bdi))
+		wbc->encountered_congestion = 1;
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * write a region of pages back to the server
+ */
+int afs_writepages_region(struct address_space *mapping,
+			  struct writeback_control *wbc,
+			  pgoff_t index, pgoff_t end, pgoff_t *_next)
+{
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	struct afs_writeback *wb;
+	struct page *page;
+	int ret, n;
+
+	_enter(",,%lx,%lx,", index, end);
+
+	do {
+		n = find_get_pages_tag(mapping, &index, PAGECACHE_TAG_DIRTY,
+				       1, &page);
+		if (!n)
+			break;
+
+		_debug("wback %lx", page->index);
+
+		if (page->index > end) {
+			*_next = index;
+			page_cache_release(page);
+			_leave(" = 0 [%lx]", *_next);
+			return 0;
+		}
+
+		/* at this point we hold neither mapping->tree_lock nor lock on
+		 * the page itself: the page may be truncated or invalidated
+		 * (changing page->mapping to NULL), or even swizzled back from
+		 * swapper_space to tmpfs file mapping
+		 */
+		lock_page(page);
+
+		if (page->mapping != mapping) {
+			unlock_page(page);
+			page_cache_release(page);
+			continue;
+		}
+
+		if (wbc->sync_mode != WB_SYNC_NONE)
+			wait_on_page_writeback(page);
+
+		if (PageWriteback(page) || !PageDirty(page)) {
+			unlock_page(page);
+			continue;
+		}
+
+		wb = (struct afs_writeback *) page_private(page);
+		ASSERT(wb != NULL);
+
+		spin_lock(&wb->vnode->writeback_lock);
+		wb->state = AFS_WBACK_WRITING;
+		spin_unlock(&wb->vnode->writeback_lock);
+
+		ret = afs_write_back_from_locked_page(wb, page);
+		unlock_page(page);
+		page_cache_release(page);
+		if (ret < 0) {
+			_leave(" = %d", ret);
+			return ret;
+		}
+
+		wbc->nr_to_write -= ret;
+
+		if (wbc->nonblocking && bdi_write_congested(bdi)) {
+			wbc->encountered_congestion = 1;
+			break;
+		}
+
+		cond_resched();
+	} while (index < end && wbc->nr_to_write > 0);
+
+	*_next = index;
+	_leave(" = 0 [%lx]", *_next);
+	return 0;
+}
+
+/*
+ * write some of the pending data back to the server
+ */
+int afs_writepages(struct address_space *mapping,
+		   struct writeback_control *wbc)
+{
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	pgoff_t start, end, next;
+	int ret;
+
+	_enter("");
+
+	if (wbc->nonblocking && bdi_write_congested(bdi)) {
+		wbc->encountered_congestion = 1;
+		_leave(" = 0 [congest]");
+		return 0;
+	}
+
+	if (wbc->range_cyclic) {
+		start = mapping->writeback_index;
+		end = -1;
+		ret = afs_writepages_region(mapping, wbc, start, end, &next);
+		if (start > 0 && wbc->nr_to_write > 0 && ret == 0 &&
+		    !(wbc->nonblocking && wbc->encountered_congestion))
+			ret = afs_writepages_region(mapping, wbc, 0, start,
+						    &next);
+		mapping->writeback_index = next;
+	} else if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX) {
+		end = LLONG_MAX >> PAGE_CACHE_SHIFT;
+		ret = afs_writepages_region(mapping, wbc, 0, end, &next);
+		if (wbc->nr_to_write > 0)
+			mapping->writeback_index = next;
+	} else {
+		start = wbc->range_start >> PAGE_CACHE_SHIFT;
+		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		ret = afs_writepages_region(mapping, wbc, start, end, &next);
+	}
+
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * write an inode back
+ */
+int afs_write_inode(struct inode *inode, int sync)
+{
+	struct afs_vnode *vnode = AFS_FS_I(inode);
+	int ret;
+
+	_enter("{%x:%u},", vnode->fid.vid, vnode->fid.vnode);
+
+	ret = 0;
+	if (sync) {
+		ret = filemap_fdatawait(inode->i_mapping);
+		if (ret < 0)
+			__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
+	}
+
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * completion of write to server
+ */
+void afs_pages_written_back(struct afs_vnode *vnode, struct afs_call *call)
+{
+	struct afs_writeback *wb = call->wb;
+	struct pagevec pv;
+	unsigned count, loop;
+	pgoff_t first = call->first, last = call->last;
+	bool free_wb;
+
+	_enter("{%x:%u},{%lx-%lx}",
+	       vnode->fid.vid, vnode->fid.vnode, first, last);
+
+	ASSERT(wb != NULL);
+
+	pagevec_init(&pv, 0);
+
+	do {
+		_debug("attach %lx-%lx", first, last);
+
+		count = last - first + 1;
+		if (count > PAGEVEC_SIZE)
+			count = PAGEVEC_SIZE;
+		pv.nr = find_get_pages_contig(call->mapping, first, count,
+					      pv.pages);
+		ASSERTCMP(pv.nr, ==, count);
+
+		spin_lock(&vnode->writeback_lock);
+		for (loop = 0; loop < count; loop++) {
+			struct page *page = pv.pages[loop];
+			end_page_writeback(page);
+			if (page_private(page) == (unsigned long) wb) {
+				set_page_private(page, 0);
+				ClearPagePrivate(page);
+				wb->usage--;
+			}
+		}
+		free_wb = false;
+		if (wb->usage == 0) {
+			afs_unlink_writeback(wb);
+			free_wb = true;
+		}
+		spin_unlock(&vnode->writeback_lock);
+		first += count;
+		if (free_wb) {
+			afs_free_writeback(wb);
+			wb = NULL;
+		}
+
+		__pagevec_release(&pv);
+	} while (first < last);
+
+	_leave("");
+}
+
+/*
+ * write to an AFS file
+ */
+ssize_t afs_file_write(struct kiocb *iocb, const struct iovec *iov,
+		       unsigned long nr_segs, loff_t pos)
+{
+	struct dentry *dentry = iocb->ki_filp->f_path.dentry;
+	struct afs_vnode *vnode = AFS_FS_I(dentry->d_inode);
+	ssize_t result;
+	size_t count = iov_length(iov, nr_segs);
+	int ret;
+
+	_enter("{%x.%u},{%lu},%lu,",
+	       vnode->fid.vid, vnode->fid.vnode, count, nr_segs);
+
+	if (IS_SWAPFILE(&vnode->vfs_inode)) {
+		printk(KERN_INFO
+		       "AFS: Attempt to write to active swap file!\n");
+		return -EBUSY;
+	}
+
+	if (!count)
+		return 0;
+
+	result = generic_file_aio_write(iocb, iov, nr_segs, pos);
+	if (IS_ERR_VALUE(result)) {
+		_leave(" = %ld", result);
+		return result;
+	}
+
+	/* return error values for O_SYNC and IS_SYNC() */
+	if (IS_SYNC(&vnode->vfs_inode) || iocb->ki_filp->f_flags & O_SYNC) {
+		ret = afs_fsync(iocb->ki_filp, dentry, 1);
+		if (ret < 0)
+			result = ret;
+	}
+
+	_leave(" = %ld", result);
+	return result;
+}
+
+/*
+ * flush the vnode to the fileserver
+ */
+int afs_writeback_all(struct afs_vnode *vnode)
+{
+	struct address_space *mapping = vnode->vfs_inode.i_mapping;
+	struct writeback_control wbc = {
+		.bdi		= mapping->backing_dev_info,
+		.sync_mode	= WB_SYNC_ALL,
+		.nr_to_write	= LONG_MAX,
+		.for_writepages = 1,
+		.range_cyclic	= 1,
+	};
+	int ret;
+
+	_enter("");
+
+	ret = mapping->a_ops->writepages(mapping, &wbc);
+	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * flush any dirty pages for this process, and check for write errors.
+ * - the return status from this call provides a reliable indication of
+ *   whether any write errors occurred for this process.
+ */
+int afs_fsync(struct file *file, struct dentry *dentry, int datasync)
+{
+	struct afs_writeback *wb, *xwb;
+	struct afs_vnode *vnode = AFS_FS_I(dentry->d_inode);
+	int ret;
+
+	_enter("{%x:%u},{n=%s},%d",
+	       vnode->fid.vid, vnode->fid.vnode, dentry->d_name.name,
+	       datasync);
+
+	/* use a writeback record as a marker in the queue - when this reaches
+	 * the front of the queue, all the outstanding writes are either
+	 * completed or rejected */
+	wb = kzalloc(sizeof(*wb), GFP_KERNEL);
+	if (!wb)
+		return -ENOMEM;
+	wb->vnode = vnode;
+	wb->first = 0;
+	wb->last = -1;
+	wb->offset_first = 0;
+	wb->to_last = PAGE_SIZE;
+	wb->usage = 1;
+	wb->state = AFS_WBACK_SYNCING;
+	init_waitqueue_head(&wb->waitq);
+
+	spin_lock(&vnode->writeback_lock);
+	list_for_each_entry(xwb, &vnode->writebacks, link) {
+		if (xwb->state == AFS_WBACK_PENDING)
+			xwb->state = AFS_WBACK_CONFLICTING;
+	}
+	list_add_tail(&wb->link, &vnode->writebacks);
+	spin_unlock(&vnode->writeback_lock);
+
+	/* push all the outstanding writebacks to the server */
+	ret = afs_writeback_all(vnode);
+	if (ret < 0) {
+		afs_put_writeback(wb);
+		_leave(" = %d [wb]", ret);
+		return ret;
+	}
+
+	/* wait for the preceding writes to actually complete */
+	ret = wait_event_interruptible(wb->waitq,
+				       wb->state == AFS_WBACK_COMPLETE ||
+				       vnode->writebacks.next == &wb->link);
+	afs_put_writeback(wb);
+	_leave(" = %d", ret);
+	return ret;
+}

