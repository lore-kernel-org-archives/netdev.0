From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/2] afs: Make afs_fs_fetch_data() take a list of
 pages
Date: Fri, 06 Jan 2017 17:08:46 +0000
Message-ID: <148372252682.8578.3784367374662008573.stgit@warthog.procyon.org.uk>
References: <148372251997.8578.5117118854142528477.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148372251997.8578.5117118854142528477.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make afs_fs_fetch_data() take a list of pages for bulk data transfer.  This
will allow afs_readpages() to be made more efficient.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/file.c     |   37 ++++++++++++++---
 fs/afs/fsclient.c |  117 ++++++++++++++++++++++++++++++++++-------------------
 fs/afs/internal.h |   21 +++++++++-
 fs/afs/vnode.c    |    6 +--
 fs/afs/write.c    |   19 +++++++--
 5 files changed, 145 insertions(+), 55 deletions(-)

diff --git a/fs/afs/file.c b/fs/afs/file.c
index 6344aee4ac4b..6c262ceef32d 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -101,6 +101,21 @@ int afs_release(struct inode *inode, struct file *file)
 	return 0;
 }
 
+/*
+ * Dispose of a ref to a read record.
+ */
+void afs_put_read(struct afs_read *req)
+{
+	int i;
+
+	if (atomic_dec_and_test(&req->usage)) {
+		for (i = 0; i < req->nr_pages; i++)
+			if (req->pages[i])
+				put_page(req->pages[i]);
+		kfree(req);
+	}
+}
+
 #ifdef CONFIG_AFS_FSCACHE
 /*
  * deal with notification that a page was read from the cache
@@ -126,9 +141,8 @@ int afs_page_filler(void *data, struct page *page)
 {
 	struct inode *inode = page->mapping->host;
 	struct afs_vnode *vnode = AFS_FS_I(inode);
+	struct afs_read *req;
 	struct key *key = data;
-	size_t len;
-	off_t offset;
 	int ret;
 
 	_enter("{%x},{%lu},{%lu}", key_serial(key), inode->i_ino, page->index);
@@ -164,12 +178,23 @@ int afs_page_filler(void *data, struct page *page)
 		_debug("cache said ENOBUFS");
 	default:
 	go_on:
-		offset = page->index << PAGE_SHIFT;
-		len = min_t(size_t, i_size_read(inode) - offset, PAGE_SIZE);
+		req = kzalloc(sizeof(struct afs_read) + sizeof(struct page *),
+			      GFP_KERNEL);
+		if (!req)
+			goto enomem;
+
+		atomic_set(&req->usage, 1);
+		req->pos = (loff_t)page->index << PAGE_SHIFT;
+		req->len = min_t(size_t, i_size_read(inode) - req->pos,
+				 PAGE_SIZE);
+		req->nr_pages = 1;
+		req->pages[0] = page;
+		get_page(page);
 
 		/* read the contents of the file from the server into the
 		 * page */
-		ret = afs_vnode_fetch_data(vnode, key, offset, len, page);
+		ret = afs_vnode_fetch_data(vnode, key, req);
+		afs_put_read(req);
 		if (ret < 0) {
 			if (ret == -ENOENT) {
 				_debug("got NOENT from server"
@@ -201,6 +226,8 @@ int afs_page_filler(void *data, struct page *page)
 	_leave(" = 0");
 	return 0;
 
+enomem:
+	ret = -ENOMEM;
 error:
 	SetPageError(page);
 	unlock_page(page);
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index 31c616ab9b40..7dc1f6fb3661 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -309,15 +309,19 @@ int afs_fs_fetch_file_status(struct afs_server *server,
 static int afs_deliver_fs_fetch_data(struct afs_call *call)
 {
 	struct afs_vnode *vnode = call->reply;
+	struct afs_read *req = call->reply3;
 	const __be32 *bp;
-	struct page *page;
+	unsigned int size;
 	void *buffer;
 	int ret;
 
-	_enter("{%u}", call->unmarshall);
+	_enter("{%u,%zu/%u;%u/%llu}",
+	       call->unmarshall, call->offset, call->count,
+	       req->remain, req->actual_len);
 
 	switch (call->unmarshall) {
 	case 0:
+		req->actual_len = 0;
 		call->offset = 0;
 		call->unmarshall++;
 		if (call->operation_ID != FSFETCHDATA64) {
@@ -334,10 +338,8 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call)
 		if (ret < 0)
 			return ret;
 
-		call->count = ntohl(call->tmp);
-		_debug("DATA length MSW: %u", call->count);
-		if (call->count > 0)
-			return -EBADMSG;
+		req->actual_len = ntohl(call->tmp);
+		req->actual_len <<= 32;
 		call->offset = 0;
 		call->unmarshall++;
 
@@ -349,26 +351,52 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call)
 		if (ret < 0)
 			return ret;
 
-		call->count = ntohl(call->tmp);
-		_debug("DATA length: %u", call->count);
-		if (call->count > PAGE_SIZE)
+		req->actual_len |= ntohl(call->tmp);
+		_debug("DATA length: %llu", req->actual_len);
+		/* Check that the server didn't want to send us extra.  We
+		 * might want to just discard instead, but that requires
+		 * cooperation from AF_RXRPC.
+		 */
+		if (req->actual_len > req->len)
 			return -EBADMSG;
-		call->offset = 0;
+
+		req->remain = req->actual_len;
+		call->offset = req->pos & (PAGE_SIZE - 1);
+		req->index = 0;
+		if (req->actual_len == 0)
+			goto no_more_data;
 		call->unmarshall++;
 
+	begin_page:
+		if (req->remain > PAGE_SIZE - call->offset)
+			size = PAGE_SIZE - call->offset;
+		else
+			size = req->remain;
+		call->count = call->offset + size;
+		ASSERTCMP(call->count, <=, PAGE_SIZE);
+		req->remain -= size;
+
 		/* extract the returned data */
 	case 3:
-		_debug("extract data");
-		if (call->count > 0) {
-			page = call->reply3;
-			buffer = kmap(page);
-			ret = afs_extract_data(call, buffer,
-					       call->count, true);
-			kunmap(page);
-			if (ret < 0)
-				return ret;
+		_debug("extract data %u/%llu %zu/%u",
+		       req->remain, req->actual_len, call->offset, call->count);
+
+		buffer = kmap(req->pages[req->index]);
+		ret = afs_extract_data(call, buffer, call->count, true);
+		kunmap(req->pages[req->index]);
+		if (ret < 0)
+			return ret;
+		if (call->offset == PAGE_SIZE) {
+			if (req->page_done)
+				req->page_done(call, req);
+			if (req->remain > 0) {
+				req->index++;
+				call->offset = 0;
+				goto begin_page;
+			}
 		}
 
+	no_more_data:
 		call->offset = 0;
 		call->unmarshall++;
 
@@ -393,17 +421,25 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call)
 	}
 
 	if (call->count < PAGE_SIZE) {
-		_debug("clear");
-		page = call->reply3;
-		buffer = kmap(page);
+		buffer = kmap(req->pages[req->index]);
 		memset(buffer + call->count, 0, PAGE_SIZE - call->count);
-		kunmap(page);
+		kunmap(req->pages[req->index]);
+		if (req->page_done)
+			req->page_done(call, req);
 	}
 
 	_leave(" = 0 [done]");
 	return 0;
 }
 
+static void afs_fetch_data_destructor(struct afs_call *call)
+{
+	struct afs_read *req = call->reply3;
+
+	afs_put_read(req);
+	afs_flat_call_destructor(call);
+}
+
 /*
  * FS.FetchData operation type
  */
@@ -411,14 +447,14 @@ static const struct afs_call_type afs_RXFSFetchData = {
 	.name		= "FS.FetchData",
 	.deliver	= afs_deliver_fs_fetch_data,
 	.abort_to_error	= afs_abort_to_error,
-	.destructor	= afs_flat_call_destructor,
+	.destructor	= afs_fetch_data_destructor,
 };
 
 static const struct afs_call_type afs_RXFSFetchData64 = {
 	.name		= "FS.FetchData64",
 	.deliver	= afs_deliver_fs_fetch_data,
 	.abort_to_error	= afs_abort_to_error,
-	.destructor	= afs_flat_call_destructor,
+	.destructor	= afs_fetch_data_destructor,
 };
 
 /*
@@ -427,8 +463,7 @@ static const struct afs_call_type afs_RXFSFetchData64 = {
 static int afs_fs_fetch_data64(struct afs_server *server,
 			       struct key *key,
 			       struct afs_vnode *vnode,
-			       off_t offset, size_t length,
-			       struct page *buffer,
+			       struct afs_read *req,
 			       const struct afs_wait_mode *wait_mode)
 {
 	struct afs_call *call;
@@ -436,8 +471,6 @@ static int afs_fs_fetch_data64(struct afs_server *server,
 
 	_enter("");
 
-	ASSERTCMP(length, <, ULONG_MAX);
-
 	call = afs_alloc_flat_call(&afs_RXFSFetchData64, 32, (21 + 3 + 6) * 4);
 	if (!call)
 		return -ENOMEM;
@@ -445,7 +478,7 @@ static int afs_fs_fetch_data64(struct afs_server *server,
 	call->key = key;
 	call->reply = vnode;
 	call->reply2 = NULL; /* volsync */
-	call->reply3 = buffer;
+	call->reply3 = req;
 	call->service_id = FS_SERVICE;
 	call->port = htons(AFS_FS_PORT);
 	call->operation_ID = FSFETCHDATA64;
@@ -456,11 +489,12 @@ static int afs_fs_fetch_data64(struct afs_server *server,
 	bp[1] = htonl(vnode->fid.vid);
 	bp[2] = htonl(vnode->fid.vnode);
 	bp[3] = htonl(vnode->fid.unique);
-	bp[4] = htonl(upper_32_bits(offset));
-	bp[5] = htonl((u32) offset);
+	bp[4] = htonl(upper_32_bits(req->pos));
+	bp[5] = htonl(lower_32_bits(req->pos));
 	bp[6] = 0;
-	bp[7] = htonl((u32) length);
+	bp[7] = htonl(lower_32_bits(req->len));
 
+	atomic_inc(&req->usage);
 	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
 }
 
@@ -470,16 +504,16 @@ static int afs_fs_fetch_data64(struct afs_server *server,
 int afs_fs_fetch_data(struct afs_server *server,
 		      struct key *key,
 		      struct afs_vnode *vnode,
-		      off_t offset, size_t length,
-		      struct page *buffer,
+		      struct afs_read *req,
 		      const struct afs_wait_mode *wait_mode)
 {
 	struct afs_call *call;
 	__be32 *bp;
 
-	if (upper_32_bits(offset) || upper_32_bits(offset + length))
-		return afs_fs_fetch_data64(server, key, vnode, offset, length,
-					   buffer, wait_mode);
+	if (upper_32_bits(req->pos) ||
+	    upper_32_bits(req->len) ||
+	    upper_32_bits(req->pos + req->len))
+		return afs_fs_fetch_data64(server, key, vnode, req, wait_mode);
 
 	_enter("");
 
@@ -490,7 +524,7 @@ int afs_fs_fetch_data(struct afs_server *server,
 	call->key = key;
 	call->reply = vnode;
 	call->reply2 = NULL; /* volsync */
-	call->reply3 = buffer;
+	call->reply3 = req;
 	call->service_id = FS_SERVICE;
 	call->port = htons(AFS_FS_PORT);
 	call->operation_ID = FSFETCHDATA;
@@ -501,9 +535,10 @@ int afs_fs_fetch_data(struct afs_server *server,
 	bp[1] = htonl(vnode->fid.vid);
 	bp[2] = htonl(vnode->fid.vnode);
 	bp[3] = htonl(vnode->fid.unique);
-	bp[4] = htonl(offset);
-	bp[5] = htonl(length);
+	bp[4] = htonl(lower_32_bits(req->pos));
+	bp[5] = htonl(lower_32_bits(req->len));
 
+	atomic_inc(&req->usage);
 	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
 }
 
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 535a38d2c1d0..6f7a9638ba1a 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -134,6 +134,22 @@ struct afs_call_type {
 };
 
 /*
+ * Record of an outstanding read operation on a vnode.
+ */
+struct afs_read {
+	loff_t			pos;		/* Where to start reading */
+	loff_t			len;		/* How much to read */
+	loff_t			actual_len;	/* How much we're actually getting */
+	atomic_t		usage;
+	unsigned int		remain;		/* Amount remaining */
+	unsigned int		index;		/* Which page we're reading into */
+	unsigned int		pg_offset;	/* Offset in page we're at */
+	unsigned int		nr_pages;
+	void (*page_done)(struct afs_call *, struct afs_read *);
+	struct page		*pages[];
+};
+
+/*
  * record of an outstanding writeback on a vnode
  */
 struct afs_writeback {
@@ -494,6 +510,7 @@ extern const struct file_operations afs_file_operations;
 extern int afs_open(struct inode *, struct file *);
 extern int afs_release(struct inode *, struct file *);
 extern int afs_page_filler(void *, struct page *);
+extern void afs_put_read(struct afs_read *);
 
 /*
  * flock.c
@@ -513,7 +530,7 @@ extern int afs_fs_fetch_file_status(struct afs_server *, struct key *,
 extern int afs_fs_give_up_callbacks(struct afs_server *,
 				    const struct afs_wait_mode *);
 extern int afs_fs_fetch_data(struct afs_server *, struct key *,
-			     struct afs_vnode *, off_t, size_t, struct page *,
+			     struct afs_vnode *, struct afs_read *,
 			     const struct afs_wait_mode *);
 extern int afs_fs_create(struct afs_server *, struct key *,
 			 struct afs_vnode *, const char *, umode_t,
@@ -699,7 +716,7 @@ extern void afs_vnode_finalise_status_update(struct afs_vnode *,
 extern int afs_vnode_fetch_status(struct afs_vnode *, struct afs_vnode *,
 				  struct key *);
 extern int afs_vnode_fetch_data(struct afs_vnode *, struct key *,
-				off_t, size_t, struct page *);
+				struct afs_read *);
 extern int afs_vnode_create(struct afs_vnode *, struct key *, const char *,
 			    umode_t, struct afs_fid *, struct afs_file_status *,
 			    struct afs_callback *, struct afs_server **);
diff --git a/fs/afs/vnode.c b/fs/afs/vnode.c
index 25cf4c3f4ff7..45aa874f5d32 100644
--- a/fs/afs/vnode.c
+++ b/fs/afs/vnode.c
@@ -393,7 +393,7 @@ int afs_vnode_fetch_status(struct afs_vnode *vnode,
  * - TODO implement caching
  */
 int afs_vnode_fetch_data(struct afs_vnode *vnode, struct key *key,
-			 off_t offset, size_t length, struct page *page)
+			 struct afs_read *desc)
 {
 	struct afs_server *server;
 	int ret;
@@ -420,8 +420,8 @@ int afs_vnode_fetch_data(struct afs_vnode *vnode, struct key *key,
 
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
-		ret = afs_fs_fetch_data(server, key, vnode, offset, length,
-					page, &afs_sync_call);
+		ret = afs_fs_fetch_data(server, key, vnode, desc,
+					&afs_sync_call);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
diff --git a/fs/afs/write.c b/fs/afs/write.c
index f865c3f05bea..c83c1a0e851f 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -86,19 +86,30 @@ void afs_put_writeback(struct afs_writeback *wb)
 static int afs_fill_page(struct afs_vnode *vnode, struct key *key,
 			 loff_t pos, struct page *page)
 {
+	struct afs_read *req;
 	loff_t i_size;
 	int ret;
-	int len;
 
 	_enter(",,%llu", (unsigned long long)pos);
 
+	req = kzalloc(sizeof(struct afs_read) + sizeof(struct page *),
+		      GFP_KERNEL);
+	if (!req)
+		return -ENOMEM;
+
+	atomic_set(&req->usage, 1);
+	req->pos = pos;
+	req->nr_pages = 1;
+	req->pages[0] = page;
+
 	i_size = i_size_read(&vnode->vfs_inode);
 	if (pos + PAGE_SIZE > i_size)
-		len = i_size - pos;
+		req->len = i_size - pos;
 	else
-		len = PAGE_SIZE;
+		req->len = PAGE_SIZE;
 
-	ret = afs_vnode_fetch_data(vnode, key, pos, len, page);
+	ret = afs_vnode_fetch_data(vnode, key, req);
+	afs_put_read(req);
 	if (ret < 0) {
 		if (ret == -ENOENT) {
 			_debug("got NOENT from server"
