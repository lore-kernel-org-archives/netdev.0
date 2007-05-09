From: David Howells <dhowells@redhat.com>
Subject: [PATCH] AFS: Write support fixes
Date: Wed, 09 May 2007 13:42:59 +0100
Message-ID: <20070509124259.12319.62090.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	dhowells@redhat.com
To: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758118AbXEIMoA@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

AFS write support fixes:

 (1) Support large files using the 64-bit file access operations if available
     on the server.

 (2) Use kmap_atomic() rather than kmap() in afs_prepare_page().

 (3) Don't do stuff in afs_writepage() that's done by the caller.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/afs_fs.h   |    2 
 fs/afs/fsclient.c |  217 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/afs/write.c    |   14 +--
 3 files changed, 216 insertions(+), 17 deletions(-)

diff --git a/fs/afs/afs_fs.h b/fs/afs/afs_fs.h
index 2198006..d963ef4 100644
--- a/fs/afs/afs_fs.h
+++ b/fs/afs/afs_fs.h
@@ -31,6 +31,8 @@ enum AFS_FS_Operations {
 	FSGETVOLUMEINFO		= 148,	/* AFS Get root volume information */
 	FSGETROOTVOLUME		= 151,	/* AFS Get root volume name */
 	FSLOOKUP		= 161,	/* AFS lookup file in directory */
+	FSFETCHDATA64		= 65537, /* AFS Fetch file data */
+	FSSTOREDATA64		= 65538, /* AFS Store file data */
 };
 
 enum AFS_FS_Errors {
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index a552699..8817076 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -293,9 +293,33 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 	case 0:
 		call->offset = 0;
 		call->unmarshall++;
+		if (call->operation_ID != FSFETCHDATA64) {
+			call->unmarshall++;
+			goto no_msw;
+		}
 
-		/* extract the returned data length */
+		/* extract the upper part of the returned data length of an
+		 * FSFETCHDATA64 op (which should always be 0 using this
+		 * client) */
 	case 1:
+		_debug("extract data length (MSW)");
+		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
+		}
+
+		call->count = ntohl(call->tmp);
+		_debug("DATA length MSW: %u", call->count);
+		if (call->count > 0)
+			return -EBADMSG;
+		call->offset = 0;
+		call->unmarshall++;
+
+	no_msw:
+		/* extract the returned data length */
+	case 2:
 		_debug("extract data length");
 		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
 		switch (ret) {
@@ -312,7 +336,7 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 		call->unmarshall++;
 
 		/* extract the returned data */
-	case 2:
+	case 3:
 		_debug("extract data");
 		if (call->count > 0) {
 			page = call->reply3;
@@ -331,7 +355,7 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 		call->unmarshall++;
 
 		/* extract the metadata */
-	case 3:
+	case 4:
 		ret = afs_extract_data(call, skb, last, call->buffer,
 				       (21 + 3 + 6) * 4);
 		switch (ret) {
@@ -349,7 +373,7 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 		call->offset = 0;
 		call->unmarshall++;
 
-	case 4:
+	case 5:
 		_debug("trailer");
 		if (skb->len != 0)
 			return -EBADMSG;
@@ -381,6 +405,56 @@ static const struct afs_call_type afs_RXFSFetchData = {
 	.destructor	= afs_flat_call_destructor,
 };
 
+static const struct afs_call_type afs_RXFSFetchData64 = {
+	.name		= "FS.FetchData64",
+	.deliver	= afs_deliver_fs_fetch_data,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_flat_call_destructor,
+};
+
+/*
+ * fetch data from a very large file
+ */
+static int afs_fs_fetch_data64(struct afs_server *server,
+			       struct key *key,
+			       struct afs_vnode *vnode,
+			       off_t offset, size_t length,
+			       struct page *buffer,
+			       const struct afs_wait_mode *wait_mode)
+{
+	struct afs_call *call;
+	__be32 *bp;
+
+	_enter("");
+
+	ASSERTCMP(length, <, ULONG_MAX);
+
+	call = afs_alloc_flat_call(&afs_RXFSFetchData64, 32, (21 + 3 + 6) * 4);
+	if (!call)
+		return -ENOMEM;
+
+	call->key = key;
+	call->reply = vnode;
+	call->reply2 = NULL; /* volsync */
+	call->reply3 = buffer;
+	call->service_id = FS_SERVICE;
+	call->port = htons(AFS_FS_PORT);
+	call->operation_ID = FSFETCHDATA64;
+
+	/* marshall the parameters */
+	bp = call->request;
+	bp[0] = htonl(FSFETCHDATA64);
+	bp[1] = htonl(vnode->fid.vid);
+	bp[2] = htonl(vnode->fid.vnode);
+	bp[3] = htonl(vnode->fid.unique);
+	bp[4] = htonl(offset >> 32);
+	bp[5] = htonl((u32) offset);
+	bp[6] = 0;
+	bp[7] = htonl((u32) length);
+
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+}
+
 /*
  * fetch data from a file
  */
@@ -394,6 +468,10 @@ int afs_fs_fetch_data(struct afs_server *server,
 	struct afs_call *call;
 	__be32 *bp;
 
+	if (offset >> 32 || (offset + length) >> 32)
+		return afs_fs_fetch_data64(server, key, vnode, offset, length,
+					   buffer, wait_mode);
+
 	_enter("");
 
 	call = afs_alloc_flat_call(&afs_RXFSFetchData, 24, (21 + 3 + 6) * 4);
@@ -406,6 +484,7 @@ int afs_fs_fetch_data(struct afs_server *server,
 	call->reply3 = buffer;
 	call->service_id = FS_SERVICE;
 	call->port = htons(AFS_FS_PORT);
+	call->operation_ID = FSFETCHDATA;
 
 	/* marshall the parameters */
 	bp = call->request;
@@ -1032,6 +1111,73 @@ static const struct afs_call_type afs_RXFSStoreData = {
 	.destructor	= afs_flat_call_destructor,
 };
 
+static const struct afs_call_type afs_RXFSStoreData64 = {
+	.name		= "FS.StoreData64",
+	.deliver	= afs_deliver_fs_store_data,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_flat_call_destructor,
+};
+
+/*
+ * store a set of pages to a very large file
+ */
+static int afs_fs_store_data64(struct afs_server *server,
+			       struct afs_writeback *wb,
+			       pgoff_t first, pgoff_t last,
+			       unsigned offset, unsigned to,
+			       loff_t size, loff_t pos, loff_t i_size,
+			       const struct afs_wait_mode *wait_mode)
+{
+	struct afs_vnode *vnode = wb->vnode;
+	struct afs_call *call;
+	__be32 *bp;
+
+	_enter(",%x,{%x:%u},,",
+	       key_serial(wb->key), vnode->fid.vid, vnode->fid.vnode);
+
+	call = afs_alloc_flat_call(&afs_RXFSStoreData64,
+				   (4 + 6 + 3 * 2) * 4,
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
+	*bp++ = htonl(FSSTOREDATA64);
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
+	*bp++ = htonl(pos >> 32);
+	*bp++ = htonl((u32) pos);
+	*bp++ = htonl(size >> 32);
+	*bp++ = htonl((u32) size);
+	*bp++ = htonl(i_size >> 32);
+	*bp++ = htonl((u32) i_size);
+
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+}
+
 /*
  * store a set of pages
  */
@@ -1062,7 +1208,9 @@ int afs_fs_store_data(struct afs_server *server, struct afs_writeback *wb,
 	       (unsigned long long) size, (unsigned long long) pos,
 	       (unsigned long long) i_size);
 
-	BUG_ON(i_size > 0xffffffff); // TODO: use 64-bit store
+	if (pos >> 32 || i_size >> 32 || size >> 32 || (pos + size) >> 32)
+		return afs_fs_store_data64(server, wb, first, last, offset, to,
+					   size, pos, i_size, wait_mode);
 
 	call = afs_alloc_flat_call(&afs_RXFSStoreData,
 				   (4 + 6 + 3) * 4,
@@ -1158,6 +1306,61 @@ static const struct afs_call_type afs_RXFSStoreData_as_Status = {
 	.destructor	= afs_flat_call_destructor,
 };
 
+static const struct afs_call_type afs_RXFSStoreData64_as_Status = {
+	.name		= "FS.StoreData64",
+	.deliver	= afs_deliver_fs_store_status,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_flat_call_destructor,
+};
+
+/*
+ * set the attributes on a very large file, using FS.StoreData rather than
+ * FS.StoreStatus so as to alter the file size also
+ */
+static int afs_fs_setattr_size64(struct afs_server *server, struct key *key,
+				 struct afs_vnode *vnode, struct iattr *attr,
+				 const struct afs_wait_mode *wait_mode)
+{
+	struct afs_call *call;
+	__be32 *bp;
+
+	_enter(",%x,{%x:%u},,",
+	       key_serial(key), vnode->fid.vid, vnode->fid.vnode);
+
+	ASSERT(attr->ia_valid & ATTR_SIZE);
+
+	call = afs_alloc_flat_call(&afs_RXFSStoreData64_as_Status,
+				   (4 + 6 + 3 * 2) * 4,
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
+	*bp++ = htonl(FSSTOREDATA64);
+	*bp++ = htonl(vnode->fid.vid);
+	*bp++ = htonl(vnode->fid.vnode);
+	*bp++ = htonl(vnode->fid.unique);
+
+	xdr_encode_AFS_StoreStatus(&bp, attr);
+
+	*bp++ = 0;				/* position of start of write */
+	*bp++ = 0;
+	*bp++ = 0;				/* size of write */
+	*bp++ = 0;
+	*bp++ = htonl(attr->ia_size >> 32);	/* new file length */
+	*bp++ = htonl((u32) attr->ia_size);
+
+	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+}
+
 /*
  * set the attributes on a file, using FS.StoreData rather than FS.StoreStatus
  * so as to alter the file size also
@@ -1173,7 +1376,9 @@ static int afs_fs_setattr_size(struct afs_server *server, struct key *key,
 	       key_serial(key), vnode->fid.vid, vnode->fid.vnode);
 
 	ASSERT(attr->ia_valid & ATTR_SIZE);
-	ASSERTCMP(attr->ia_size, <=, 0xffffffff); // TODO: use 64-bit store
+	if (attr->ia_size >> 32)
+		return afs_fs_setattr_size64(server, key, vnode, attr,
+					     wait_mode);
 
 	call = afs_alloc_flat_call(&afs_RXFSStoreData_as_Status,
 				   (4 + 6 + 3) * 4,
diff --git a/fs/afs/write.c b/fs/afs/write.c
index 83ff292..aa03d43 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -122,7 +122,7 @@ static int afs_prepare_page(struct afs_vnode *vnode, struct page *page,
 	if (offset == 0 && to == PAGE_SIZE)
 		return 0;
 
-	p = kmap(page);
+	p = kmap_atomic(page, KM_USER0);
 
 	i_size = i_size_read(&vnode->vfs_inode);
 	pos = (loff_t) page->index << PAGE_SHIFT;
@@ -133,7 +133,7 @@ static int afs_prepare_page(struct afs_vnode *vnode, struct page *page,
 			memset(p, 0, offset);
 		if (to < PAGE_SIZE)
 			memset(p + to, 0, PAGE_SIZE - to);
-		kunmap(page);
+		kunmap_atomic(p, KM_USER0);
 		return 0;
 	}
 
@@ -152,7 +152,7 @@ static int afs_prepare_page(struct afs_vnode *vnode, struct page *page,
 			memset(p + eof, 0, PAGE_SIZE - eof);
 	}
 
-	kunmap(p);
+	kunmap_atomic(p, KM_USER0);
 
 	ret = 0;
 	if (offset > 0 || eof > to) {
@@ -489,14 +489,6 @@ int afs_writepage(struct page *page, struct writeback_control *wbc)
 
 	_enter("{%lx},", page->index);
 
-	if (wbc->sync_mode != WB_SYNC_NONE)
-		wait_on_page_writeback(page);
-
-	if (PageWriteback(page) || !PageDirty(page)) {
-		unlock_page(page);
-		return 0;
-	}
-
 	wb = (struct afs_writeback *) page_private(page);
 	ASSERT(wb != NULL);
 
