From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/4] afs: Kill afs_wait_mode
Date: Mon, 09 Jan 2017 14:53:02 +0000
Message-ID: <148397358294.20445.15566807598357291015.stgit@warthog.procyon.org.uk>
References: <148397356909.20445.15077871371099721338.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54334 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752744AbdAIOxG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 09:53:06 -0500
In-Reply-To: <148397356909.20445.15077871371099721338.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The afs_wait_mode struct isn't really necessary.  Client calls only use one
of a choice of two (synchronous or the asynchronous) and incoming calls
don't use the wait at all.  Replace with a boolean parameter.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/callback.c  |    2 +
 fs/afs/fsclient.c  |   80 ++++++++++++++++++++++++++--------------------------
 fs/afs/internal.h  |   68 ++++++++++++--------------------------------
 fs/afs/rxrpc.c     |   51 ++++++++-------------------------
 fs/afs/vlclient.c  |    8 +++--
 fs/afs/vlocation.c |    4 +--
 fs/afs/vnode.c     |   26 ++++++++---------
 7 files changed, 90 insertions(+), 149 deletions(-)

diff --git a/fs/afs/callback.c b/fs/afs/callback.c
index 1e9d2f84e5b5..b29447e03ede 100644
--- a/fs/afs/callback.c
+++ b/fs/afs/callback.c
@@ -343,7 +343,7 @@ void afs_dispatch_give_up_callbacks(struct work_struct *work)
 	 *   had callbacks entirely, and the server will call us later to break
 	 *   them
 	 */
-	afs_fs_give_up_callbacks(server, &afs_async_call);
+	afs_fs_give_up_callbacks(server, true);
 }
 
 /*
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index 7dc1f6fb3661..ac8e766978dc 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -275,7 +275,7 @@ int afs_fs_fetch_file_status(struct afs_server *server,
 			     struct key *key,
 			     struct afs_vnode *vnode,
 			     struct afs_volsync *volsync,
-			     const struct afs_wait_mode *wait_mode)
+			     bool async)
 {
 	struct afs_call *call;
 	__be32 *bp;
@@ -300,7 +300,7 @@ int afs_fs_fetch_file_status(struct afs_server *server,
 	bp[2] = htonl(vnode->fid.vnode);
 	bp[3] = htonl(vnode->fid.unique);
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -464,7 +464,7 @@ static int afs_fs_fetch_data64(struct afs_server *server,
 			       struct key *key,
 			       struct afs_vnode *vnode,
 			       struct afs_read *req,
-			       const struct afs_wait_mode *wait_mode)
+			       bool async)
 {
 	struct afs_call *call;
 	__be32 *bp;
@@ -495,7 +495,7 @@ static int afs_fs_fetch_data64(struct afs_server *server,
 	bp[7] = htonl(lower_32_bits(req->len));
 
 	atomic_inc(&req->usage);
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -505,7 +505,7 @@ int afs_fs_fetch_data(struct afs_server *server,
 		      struct key *key,
 		      struct afs_vnode *vnode,
 		      struct afs_read *req,
-		      const struct afs_wait_mode *wait_mode)
+		      bool async)
 {
 	struct afs_call *call;
 	__be32 *bp;
@@ -513,7 +513,7 @@ int afs_fs_fetch_data(struct afs_server *server,
 	if (upper_32_bits(req->pos) ||
 	    upper_32_bits(req->len) ||
 	    upper_32_bits(req->pos + req->len))
-		return afs_fs_fetch_data64(server, key, vnode, req, wait_mode);
+		return afs_fs_fetch_data64(server, key, vnode, req, async);
 
 	_enter("");
 
@@ -539,7 +539,7 @@ int afs_fs_fetch_data(struct afs_server *server,
 	bp[5] = htonl(lower_32_bits(req->len));
 
 	atomic_inc(&req->usage);
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -568,7 +568,7 @@ static const struct afs_call_type afs_RXFSGiveUpCallBacks = {
  * - the callbacks are held in the server->cb_break ring
  */
 int afs_fs_give_up_callbacks(struct afs_server *server,
-			     const struct afs_wait_mode *wait_mode)
+			     bool async)
 {
 	struct afs_call *call;
 	size_t ncallbacks;
@@ -622,7 +622,7 @@ int afs_fs_give_up_callbacks(struct afs_server *server,
 	ASSERT(ncallbacks > 0);
 	wake_up_nr(&server->cb_break_waitq, ncallbacks);
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -673,7 +673,7 @@ int afs_fs_create(struct afs_server *server,
 		  struct afs_fid *newfid,
 		  struct afs_file_status *newstatus,
 		  struct afs_callback *newcb,
-		  const struct afs_wait_mode *wait_mode)
+		  bool async)
 {
 	struct afs_call *call;
 	size_t namesz, reqsz, padsz;
@@ -718,7 +718,7 @@ int afs_fs_create(struct afs_server *server,
 	*bp++ = htonl(mode & S_IALLUGO); /* unix mode */
 	*bp++ = 0; /* segment size */
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -763,7 +763,7 @@ int afs_fs_remove(struct afs_server *server,
 		  struct afs_vnode *vnode,
 		  const char *name,
 		  bool isdir,
-		  const struct afs_wait_mode *wait_mode)
+		  bool async)
 {
 	struct afs_call *call;
 	size_t namesz, reqsz, padsz;
@@ -798,7 +798,7 @@ int afs_fs_remove(struct afs_server *server,
 		bp = (void *) bp + padsz;
 	}
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -844,7 +844,7 @@ int afs_fs_link(struct afs_server *server,
 		struct afs_vnode *dvnode,
 		struct afs_vnode *vnode,
 		const char *name,
-		const struct afs_wait_mode *wait_mode)
+		bool async)
 {
 	struct afs_call *call;
 	size_t namesz, reqsz, padsz;
@@ -883,7 +883,7 @@ int afs_fs_link(struct afs_server *server,
 	*bp++ = htonl(vnode->fid.vnode);
 	*bp++ = htonl(vnode->fid.unique);
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -932,7 +932,7 @@ int afs_fs_symlink(struct afs_server *server,
 		   const char *contents,
 		   struct afs_fid *newfid,
 		   struct afs_file_status *newstatus,
-		   const struct afs_wait_mode *wait_mode)
+		   bool async)
 {
 	struct afs_call *call;
 	size_t namesz, reqsz, padsz, c_namesz, c_padsz;
@@ -987,7 +987,7 @@ int afs_fs_symlink(struct afs_server *server,
 	*bp++ = htonl(S_IRWXUGO); /* unix mode */
 	*bp++ = 0; /* segment size */
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -1036,7 +1036,7 @@ int afs_fs_rename(struct afs_server *server,
 		  const char *orig_name,
 		  struct afs_vnode *new_dvnode,
 		  const char *new_name,
-		  const struct afs_wait_mode *wait_mode)
+		  bool async)
 {
 	struct afs_call *call;
 	size_t reqsz, o_namesz, o_padsz, n_namesz, n_padsz;
@@ -1090,7 +1090,7 @@ int afs_fs_rename(struct afs_server *server,
 		bp = (void *) bp + n_padsz;
 	}
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -1145,7 +1145,7 @@ static int afs_fs_store_data64(struct afs_server *server,
 			       pgoff_t first, pgoff_t last,
 			       unsigned offset, unsigned to,
 			       loff_t size, loff_t pos, loff_t i_size,
-			       const struct afs_wait_mode *wait_mode)
+			       bool async)
 {
 	struct afs_vnode *vnode = wb->vnode;
 	struct afs_call *call;
@@ -1194,7 +1194,7 @@ static int afs_fs_store_data64(struct afs_server *server,
 	*bp++ = htonl(i_size >> 32);
 	*bp++ = htonl((u32) i_size);
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -1203,7 +1203,7 @@ static int afs_fs_store_data64(struct afs_server *server,
 int afs_fs_store_data(struct afs_server *server, struct afs_writeback *wb,
 		      pgoff_t first, pgoff_t last,
 		      unsigned offset, unsigned to,
-		      const struct afs_wait_mode *wait_mode)
+		      bool async)
 {
 	struct afs_vnode *vnode = wb->vnode;
 	struct afs_call *call;
@@ -1229,7 +1229,7 @@ int afs_fs_store_data(struct afs_server *server, struct afs_writeback *wb,
 
 	if (pos >> 32 || i_size >> 32 || size >> 32 || (pos + size) >> 32)
 		return afs_fs_store_data64(server, wb, first, last, offset, to,
-					   size, pos, i_size, wait_mode);
+					   size, pos, i_size, async);
 
 	call = afs_alloc_flat_call(&afs_RXFSStoreData,
 				   (4 + 6 + 3) * 4,
@@ -1268,7 +1268,7 @@ int afs_fs_store_data(struct afs_server *server, struct afs_writeback *wb,
 	*bp++ = htonl(size);
 	*bp++ = htonl(i_size);
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -1330,7 +1330,7 @@ static const struct afs_call_type afs_RXFSStoreData64_as_Status = {
  */
 static int afs_fs_setattr_size64(struct afs_server *server, struct key *key,
 				 struct afs_vnode *vnode, struct iattr *attr,
-				 const struct afs_wait_mode *wait_mode)
+				 bool async)
 {
 	struct afs_call *call;
 	__be32 *bp;
@@ -1369,7 +1369,7 @@ static int afs_fs_setattr_size64(struct afs_server *server, struct key *key,
 	*bp++ = htonl(attr->ia_size >> 32);	/* new file length */
 	*bp++ = htonl((u32) attr->ia_size);
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -1378,7 +1378,7 @@ static int afs_fs_setattr_size64(struct afs_server *server, struct key *key,
  */
 static int afs_fs_setattr_size(struct afs_server *server, struct key *key,
 			       struct afs_vnode *vnode, struct iattr *attr,
-			       const struct afs_wait_mode *wait_mode)
+			       bool async)
 {
 	struct afs_call *call;
 	__be32 *bp;
@@ -1389,7 +1389,7 @@ static int afs_fs_setattr_size(struct afs_server *server, struct key *key,
 	ASSERT(attr->ia_valid & ATTR_SIZE);
 	if (attr->ia_size >> 32)
 		return afs_fs_setattr_size64(server, key, vnode, attr,
-					     wait_mode);
+					     async);
 
 	call = afs_alloc_flat_call(&afs_RXFSStoreData_as_Status,
 				   (4 + 6 + 3) * 4,
@@ -1417,7 +1417,7 @@ static int afs_fs_setattr_size(struct afs_server *server, struct key *key,
 	*bp++ = 0;				/* size of write */
 	*bp++ = htonl(attr->ia_size);		/* new file length */
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -1426,14 +1426,14 @@ static int afs_fs_setattr_size(struct afs_server *server, struct key *key,
  */
 int afs_fs_setattr(struct afs_server *server, struct key *key,
 		   struct afs_vnode *vnode, struct iattr *attr,
-		   const struct afs_wait_mode *wait_mode)
+		   bool async)
 {
 	struct afs_call *call;
 	__be32 *bp;
 
 	if (attr->ia_valid & ATTR_SIZE)
 		return afs_fs_setattr_size(server, key, vnode, attr,
-					   wait_mode);
+					   async);
 
 	_enter(",%x,{%x:%u},,",
 	       key_serial(key), vnode->fid.vid, vnode->fid.vnode);
@@ -1459,7 +1459,7 @@ int afs_fs_setattr(struct afs_server *server, struct key *key,
 
 	xdr_encode_AFS_StoreStatus(&bp, attr);
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -1661,7 +1661,7 @@ int afs_fs_get_volume_status(struct afs_server *server,
 			     struct key *key,
 			     struct afs_vnode *vnode,
 			     struct afs_volume_status *vs,
-			     const struct afs_wait_mode *wait_mode)
+			     bool async)
 {
 	struct afs_call *call;
 	__be32 *bp;
@@ -1691,7 +1691,7 @@ int afs_fs_get_volume_status(struct afs_server *server,
 	bp[0] = htonl(FSGETVOLUMESTATUS);
 	bp[1] = htonl(vnode->fid.vid);
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -1753,7 +1753,7 @@ int afs_fs_set_lock(struct afs_server *server,
 		    struct key *key,
 		    struct afs_vnode *vnode,
 		    afs_lock_type_t type,
-		    const struct afs_wait_mode *wait_mode)
+		    bool async)
 {
 	struct afs_call *call;
 	__be32 *bp;
@@ -1777,7 +1777,7 @@ int afs_fs_set_lock(struct afs_server *server,
 	*bp++ = htonl(vnode->fid.unique);
 	*bp++ = htonl(type);
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -1786,7 +1786,7 @@ int afs_fs_set_lock(struct afs_server *server,
 int afs_fs_extend_lock(struct afs_server *server,
 		       struct key *key,
 		       struct afs_vnode *vnode,
-		       const struct afs_wait_mode *wait_mode)
+		       bool async)
 {
 	struct afs_call *call;
 	__be32 *bp;
@@ -1809,7 +1809,7 @@ int afs_fs_extend_lock(struct afs_server *server,
 	*bp++ = htonl(vnode->fid.vnode);
 	*bp++ = htonl(vnode->fid.unique);
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
 
 /*
@@ -1818,7 +1818,7 @@ int afs_fs_extend_lock(struct afs_server *server,
 int afs_fs_release_lock(struct afs_server *server,
 			struct key *key,
 			struct afs_vnode *vnode,
-			const struct afs_wait_mode *wait_mode)
+			bool async)
 {
 	struct afs_call *call;
 	__be32 *bp;
@@ -1841,5 +1841,5 @@ int afs_fs_release_lock(struct afs_server *server,
 	*bp++ = htonl(vnode->fid.vnode);
 	*bp++ = htonl(vnode->fid.unique);
 
-	return afs_make_call(&server->addr, call, GFP_NOFS, wait_mode);
+	return afs_make_call(&server->addr, call, GFP_NOFS, async);
 }
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index f71e58fcc2f2..b411670d5f67 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -51,23 +51,6 @@ struct afs_mount_params {
 	struct key		*key;		/* key to use for secure mounting */
 };
 
-/*
- * definition of how to wait for the completion of an operation
- */
-struct afs_wait_mode {
-	/* RxRPC received message notification */
-	rxrpc_notify_rx_t notify_rx;
-
-	/* synchronous call waiter and call dispatched notification */
-	int (*wait)(struct afs_call *call);
-
-	/* asynchronous call completion */
-	void (*async_complete)(void *reply, int error);
-};
-
-extern const struct afs_wait_mode afs_sync_call;
-extern const struct afs_wait_mode afs_async_call;
-
 enum afs_call_state {
 	AFS_CALL_REQUESTING,	/* request is being sent for outgoing call */
 	AFS_CALL_AWAIT_REPLY,	/* awaiting reply to outgoing call */
@@ -82,7 +65,6 @@ enum afs_call_state {
  */
 struct afs_call {
 	const struct afs_call_type *type;	/* type of call */
-	const struct afs_wait_mode *wait_mode;	/* completion wait mode */
 	wait_queue_head_t	waitq;		/* processes awaiting completion */
 	struct work_struct	async_work;	/* asynchronous work processor */
 	struct work_struct	work;		/* actual work processor */
@@ -111,6 +93,7 @@ struct afs_call {
 	bool			incoming;	/* T if incoming call */
 	bool			send_pages;	/* T if data from mapping should be sent */
 	bool			need_attention;	/* T if RxRPC poked us */
+	bool			async;		/* T if asynchronous */
 	u16			service_id;	/* RxRPC service ID to call */
 	__be16			port;		/* target UDP port */
 	u32			operation_ID;	/* operation ID for an incoming call */
@@ -527,50 +510,37 @@ extern int afs_flock(struct file *, int, struct file_lock *);
  */
 extern int afs_fs_fetch_file_status(struct afs_server *, struct key *,
 				    struct afs_vnode *, struct afs_volsync *,
-				    const struct afs_wait_mode *);
-extern int afs_fs_give_up_callbacks(struct afs_server *,
-				    const struct afs_wait_mode *);
+				    bool);
+extern int afs_fs_give_up_callbacks(struct afs_server *, bool);
 extern int afs_fs_fetch_data(struct afs_server *, struct key *,
-			     struct afs_vnode *, struct afs_read *,
-			     const struct afs_wait_mode *);
+			     struct afs_vnode *, struct afs_read *, bool);
 extern int afs_fs_create(struct afs_server *, struct key *,
 			 struct afs_vnode *, const char *, umode_t,
 			 struct afs_fid *, struct afs_file_status *,
-			 struct afs_callback *,
-			 const struct afs_wait_mode *);
+			 struct afs_callback *, bool);
 extern int afs_fs_remove(struct afs_server *, struct key *,
-			 struct afs_vnode *, const char *, bool,
-			 const struct afs_wait_mode *);
+			 struct afs_vnode *, const char *, bool, bool);
 extern int afs_fs_link(struct afs_server *, struct key *, struct afs_vnode *,
-		       struct afs_vnode *, const char *,
-		       const struct afs_wait_mode *);
+		       struct afs_vnode *, const char *, bool);
 extern int afs_fs_symlink(struct afs_server *, struct key *,
 			  struct afs_vnode *, const char *, const char *,
-			  struct afs_fid *, struct afs_file_status *,
-			  const struct afs_wait_mode *);
+			  struct afs_fid *, struct afs_file_status *, bool);
 extern int afs_fs_rename(struct afs_server *, struct key *,
 			 struct afs_vnode *, const char *,
-			 struct afs_vnode *, const char *,
-			 const struct afs_wait_mode *);
+			 struct afs_vnode *, const char *, bool);
 extern int afs_fs_store_data(struct afs_server *, struct afs_writeback *,
-			     pgoff_t, pgoff_t, unsigned, unsigned,
-			     const struct afs_wait_mode *);
+			     pgoff_t, pgoff_t, unsigned, unsigned, bool);
 extern int afs_fs_setattr(struct afs_server *, struct key *,
-			  struct afs_vnode *, struct iattr *,
-			  const struct afs_wait_mode *);
+			  struct afs_vnode *, struct iattr *, bool);
 extern int afs_fs_get_volume_status(struct afs_server *, struct key *,
 				    struct afs_vnode *,
-				    struct afs_volume_status *,
-				    const struct afs_wait_mode *);
+				    struct afs_volume_status *, bool);
 extern int afs_fs_set_lock(struct afs_server *, struct key *,
-			   struct afs_vnode *, afs_lock_type_t,
-			   const struct afs_wait_mode *);
+			   struct afs_vnode *, afs_lock_type_t, bool);
 extern int afs_fs_extend_lock(struct afs_server *, struct key *,
-			      struct afs_vnode *,
-			      const struct afs_wait_mode *);
+			      struct afs_vnode *, bool);
 extern int afs_fs_release_lock(struct afs_server *, struct key *,
-			       struct afs_vnode *,
-			       const struct afs_wait_mode *);
+			       struct afs_vnode *, bool);
 
 /*
  * inode.c
@@ -624,8 +594,7 @@ extern struct socket *afs_socket;
 
 extern int afs_open_socket(void);
 extern void afs_close_socket(void);
-extern int afs_make_call(struct in_addr *, struct afs_call *, gfp_t,
-			 const struct afs_wait_mode *);
+extern int afs_make_call(struct in_addr *, struct afs_call *, gfp_t, bool);
 extern struct afs_call *afs_alloc_flat_call(const struct afs_call_type *,
 					    size_t, size_t);
 extern void afs_flat_call_destructor(struct afs_call *);
@@ -681,11 +650,10 @@ extern int afs_get_MAC_address(u8 *, size_t);
  */
 extern int afs_vl_get_entry_by_name(struct in_addr *, struct key *,
 				    const char *, struct afs_cache_vlocation *,
-				    const struct afs_wait_mode *);
+				    bool);
 extern int afs_vl_get_entry_by_id(struct in_addr *, struct key *,
 				  afs_volid_t, afs_voltype_t,
-				  struct afs_cache_vlocation *,
-				  const struct afs_wait_mode *);
+				  struct afs_cache_vlocation *, bool);
 
 /*
  * vlocation.c
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index f26344a8c029..ec1e41f929d1 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -25,29 +25,11 @@ static void afs_free_call(struct afs_call *);
 static void afs_wake_up_call_waiter(struct sock *, struct rxrpc_call *, unsigned long);
 static int afs_wait_for_call_to_complete(struct afs_call *);
 static void afs_wake_up_async_call(struct sock *, struct rxrpc_call *, unsigned long);
-static int afs_dont_wait_for_call_to_complete(struct afs_call *);
 static void afs_process_async_call(struct work_struct *);
 static void afs_rx_new_call(struct sock *, struct rxrpc_call *, unsigned long);
 static void afs_rx_discard_new_call(struct rxrpc_call *, unsigned long);
 static int afs_deliver_cm_op_id(struct afs_call *);
 
-/* synchronous call management */
-const struct afs_wait_mode afs_sync_call = {
-	.notify_rx	= afs_wake_up_call_waiter,
-	.wait		= afs_wait_for_call_to_complete,
-};
-
-/* asynchronous call management */
-const struct afs_wait_mode afs_async_call = {
-	.notify_rx	= afs_wake_up_async_call,
-	.wait		= afs_dont_wait_for_call_to_complete,
-};
-
-/* asynchronous incoming call management */
-static const struct afs_wait_mode afs_async_incoming_call = {
-	.notify_rx	= afs_wake_up_async_call,
-};
-
 /* asynchronous incoming call initial processing */
 static const struct afs_call_type afs_RXCMxxxx = {
 	.name		= "CB.xxxx",
@@ -315,7 +297,7 @@ static int afs_send_pages(struct afs_call *call, struct msghdr *msg,
  * initiate a call
  */
 int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
-		  const struct afs_wait_mode *wait_mode)
+		  bool async)
 {
 	struct sockaddr_rxrpc srx;
 	struct rxrpc_call *rxcall;
@@ -332,7 +314,7 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	       call, call->type->name, key_serial(call->key),
 	       atomic_read(&afs_outstanding_calls));
 
-	call->wait_mode = wait_mode;
+	call->async = async;
 	INIT_WORK(&call->async_work, afs_process_async_call);
 
 	memset(&srx, 0, sizeof(srx));
@@ -347,7 +329,9 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	/* create a call */
 	rxcall = rxrpc_kernel_begin_call(afs_socket, &srx, call->key,
 					 (unsigned long) call, gfp,
-					 wait_mode->notify_rx);
+					 (async ?
+					  afs_wake_up_async_call :
+					  afs_wake_up_call_waiter));
 	call->key = NULL;
 	if (IS_ERR(rxcall)) {
 		ret = PTR_ERR(rxcall);
@@ -386,7 +370,10 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 
 	/* at this point, an async call may no longer exist as it may have
 	 * already completed */
-	return wait_mode->wait(call);
+	if (call->async)
+		return -EINPROGRESS;
+
+	return afs_wait_for_call_to_complete(call);
 
 error_do_abort:
 	rxrpc_kernel_abort_call(afs_socket, rxcall, RX_USER_ABORT, -ret, "KSD");
@@ -549,17 +536,6 @@ static void afs_wake_up_async_call(struct sock *sk, struct rxrpc_call *rxcall,
 }
 
 /*
- * put a call into asynchronous mode
- * - mustn't touch the call descriptor as the call my have completed by the
- *   time we get here
- */
-static int afs_dont_wait_for_call_to_complete(struct afs_call *call)
-{
-	_enter("");
-	return -EINPROGRESS;
-}
-
-/*
  * delete an asynchronous call
  */
 static void afs_delete_async_call(struct work_struct *work)
@@ -587,10 +563,7 @@ static void afs_process_async_call(struct work_struct *work)
 		afs_deliver_to_call(call);
 	}
 
-	if (call->state == AFS_CALL_COMPLETE && call->wait_mode) {
-		if (call->wait_mode->async_complete)
-			call->wait_mode->async_complete(call->reply,
-							call->error);
+	if (call->state == AFS_CALL_COMPLETE) {
 		call->reply = NULL;
 
 		/* kill the call */
@@ -626,10 +599,10 @@ static void afs_charge_preallocation(struct work_struct *work)
 				break;
 
 			INIT_WORK(&call->async_work, afs_process_async_call);
-			call->wait_mode = &afs_async_incoming_call;
 			call->type = &afs_RXCMxxxx;
-			init_waitqueue_head(&call->waitq);
+			call->async = true;
 			call->state = AFS_CALL_AWAIT_OP_ID;
+			init_waitqueue_head(&call->waitq);
 		}
 
 		if (rxrpc_kernel_charge_accept(afs_socket,
diff --git a/fs/afs/vlclient.c b/fs/afs/vlclient.c
index 94bcd97d22b8..a5e4cc561b6c 100644
--- a/fs/afs/vlclient.c
+++ b/fs/afs/vlclient.c
@@ -147,7 +147,7 @@ int afs_vl_get_entry_by_name(struct in_addr *addr,
 			     struct key *key,
 			     const char *volname,
 			     struct afs_cache_vlocation *entry,
-			     const struct afs_wait_mode *wait_mode)
+			     bool async)
 {
 	struct afs_call *call;
 	size_t volnamesz, reqsz, padsz;
@@ -177,7 +177,7 @@ int afs_vl_get_entry_by_name(struct in_addr *addr,
 		memset((void *) bp + volnamesz, 0, padsz);
 
 	/* initiate the call */
-	return afs_make_call(addr, call, GFP_KERNEL, wait_mode);
+	return afs_make_call(addr, call, GFP_KERNEL, async);
 }
 
 /*
@@ -188,7 +188,7 @@ int afs_vl_get_entry_by_id(struct in_addr *addr,
 			   afs_volid_t volid,
 			   afs_voltype_t voltype,
 			   struct afs_cache_vlocation *entry,
-			   const struct afs_wait_mode *wait_mode)
+			   bool async)
 {
 	struct afs_call *call;
 	__be32 *bp;
@@ -211,5 +211,5 @@ int afs_vl_get_entry_by_id(struct in_addr *addr,
 	*bp   = htonl(voltype);
 
 	/* initiate the call */
-	return afs_make_call(addr, call, GFP_KERNEL, wait_mode);
+	return afs_make_call(addr, call, GFP_KERNEL, async);
 }
diff --git a/fs/afs/vlocation.c b/fs/afs/vlocation.c
index 45a86396fd2d..d7d8dd8c0b31 100644
--- a/fs/afs/vlocation.c
+++ b/fs/afs/vlocation.c
@@ -53,7 +53,7 @@ static int afs_vlocation_access_vl_by_name(struct afs_vlocation *vl,
 
 		/* attempt to access the VL server */
 		ret = afs_vl_get_entry_by_name(&addr, key, vl->vldb.name, vldb,
-					       &afs_sync_call);
+					       false);
 		switch (ret) {
 		case 0:
 			goto out;
@@ -111,7 +111,7 @@ static int afs_vlocation_access_vl_by_id(struct afs_vlocation *vl,
 
 		/* attempt to access the VL server */
 		ret = afs_vl_get_entry_by_id(&addr, key, volid, voltype, vldb,
-					     &afs_sync_call);
+					     false);
 		switch (ret) {
 		case 0:
 			goto out;
diff --git a/fs/afs/vnode.c b/fs/afs/vnode.c
index 45aa874f5d32..dcb956143c86 100644
--- a/fs/afs/vnode.c
+++ b/fs/afs/vnode.c
@@ -358,7 +358,7 @@ int afs_vnode_fetch_status(struct afs_vnode *vnode,
 		       server, ntohl(server->addr.s_addr));
 
 		ret = afs_fs_fetch_file_status(server, key, vnode, NULL,
-					       &afs_sync_call);
+					       false);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
@@ -421,7 +421,7 @@ int afs_vnode_fetch_data(struct afs_vnode *vnode, struct key *key,
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
 		ret = afs_fs_fetch_data(server, key, vnode, desc,
-					&afs_sync_call);
+					false);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
@@ -477,7 +477,7 @@ int afs_vnode_create(struct afs_vnode *vnode, struct key *key,
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
 		ret = afs_fs_create(server, key, vnode, name, mode, newfid,
-				    newstatus, newcb, &afs_sync_call);
+				    newstatus, newcb, false);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
@@ -533,7 +533,7 @@ int afs_vnode_remove(struct afs_vnode *vnode, struct key *key, const char *name,
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
 		ret = afs_fs_remove(server, key, vnode, name, isdir,
-				    &afs_sync_call);
+				    false);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
@@ -595,7 +595,7 @@ int afs_vnode_link(struct afs_vnode *dvnode, struct afs_vnode *vnode,
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
 		ret = afs_fs_link(server, key, dvnode, vnode, name,
-				  &afs_sync_call);
+				  false);
 
 	} while (!afs_volume_release_fileserver(dvnode, server, ret));
 
@@ -659,7 +659,7 @@ int afs_vnode_symlink(struct afs_vnode *vnode, struct key *key,
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
 		ret = afs_fs_symlink(server, key, vnode, name, content,
-				     newfid, newstatus, &afs_sync_call);
+				     newfid, newstatus, false);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
@@ -729,7 +729,7 @@ int afs_vnode_rename(struct afs_vnode *orig_dvnode,
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
 		ret = afs_fs_rename(server, key, orig_dvnode, orig_name,
-				    new_dvnode, new_name, &afs_sync_call);
+				    new_dvnode, new_name, false);
 
 	} while (!afs_volume_release_fileserver(orig_dvnode, server, ret));
 
@@ -795,7 +795,7 @@ int afs_vnode_store_data(struct afs_writeback *wb, pgoff_t first, pgoff_t last,
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
 		ret = afs_fs_store_data(server, wb, first, last, offset, to,
-					&afs_sync_call);
+					false);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
@@ -847,7 +847,7 @@ int afs_vnode_setattr(struct afs_vnode *vnode, struct key *key,
 
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
-		ret = afs_fs_setattr(server, key, vnode, attr, &afs_sync_call);
+		ret = afs_fs_setattr(server, key, vnode, attr, false);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
@@ -894,7 +894,7 @@ int afs_vnode_get_volume_status(struct afs_vnode *vnode, struct key *key,
 
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
-		ret = afs_fs_get_volume_status(server, key, vnode, vs, &afs_sync_call);
+		ret = afs_fs_get_volume_status(server, key, vnode, vs, false);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
@@ -933,7 +933,7 @@ int afs_vnode_set_lock(struct afs_vnode *vnode, struct key *key,
 
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
-		ret = afs_fs_set_lock(server, key, vnode, type, &afs_sync_call);
+		ret = afs_fs_set_lock(server, key, vnode, type, false);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
@@ -971,7 +971,7 @@ int afs_vnode_extend_lock(struct afs_vnode *vnode, struct key *key)
 
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
-		ret = afs_fs_extend_lock(server, key, vnode, &afs_sync_call);
+		ret = afs_fs_extend_lock(server, key, vnode, false);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
@@ -1009,7 +1009,7 @@ int afs_vnode_release_lock(struct afs_vnode *vnode, struct key *key)
 
 		_debug("USING SERVER: %08x\n", ntohl(server->addr.s_addr));
 
-		ret = afs_fs_release_lock(server, key, vnode, &afs_sync_call);
+		ret = afs_fs_release_lock(server, key, vnode, false);
 
 	} while (!afs_volume_release_fileserver(vnode, server, ret));
 
