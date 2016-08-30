From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next] rxrpc: Don't expose skbs to in-kernel users
Date: Tue, 30 Aug 2016 16:52:39 +0100
Message-ID: <147257235952.6716.3613899854387213654.stgit@warthog.procyon.org.uk>
References: <147257235268.6716.12062621584578937716.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147257235268.6716.12062621584578937716.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't expose skbs to in-kernel users, such as the AFS filesystem, but
instead provide a notification hook the indicates that a call needs
attention and another that indicates that there's a new call to be
collected.

This makes the following possibilities more achievable:

 (1) Call refcounting can be made simpler if skbs don't hold refs to calls.

 (2) skbs referring to non-data events will be able to be freed much sooner
     rather than being queued for AFS to pick up as rxrpc_kernel_recv_data
     will be able to consult the call state.

 (3) We can shortcut the receive phase when a call is remotely aborted
     because we don't have to go through all the packets to get to the one
     cancelling the operation.

 (4) It makes it easier to do encryption/decryption directly between AFS's
     buffers and sk_buffs.

 (5) Encryption/decryption can more easily be done in the AFS's thread
     contexts - usually that of the userspace process that issued a syscall
     - rather than in one of rxrpc's background threads on a workqueue.

 (6) AFS will be able to wait synchronously on a call inside AF_RXRPC.

To make this work, the following interface function has been added:

     int rxrpc_kernel_recv_data(
		struct socket *sock, struct rxrpc_call *call,
		void *buffer, size_t bufsize, size_t *_offset,
		bool want_more, u32 *_abort_code);

This is the recvmsg equivalent.  It allows the caller to find out about the
state of a specific call and to transfer received data into a buffer
piecemeal.

afs_extract_data() and rxrpc_kernel_recv_data() now do all the extraction
logic between them.  They don't wait synchronously yet because the socket
lock needs to be dealt with.

Five interface functions have been removed:

	rxrpc_kernel_is_data_last()
    	rxrpc_kernel_get_abort_code()
    	rxrpc_kernel_get_error_number()
    	rxrpc_kernel_free_skb()
    	rxrpc_kernel_data_consumed()

As a temporary hack, sk_buffs going to an in-kernel call are queued on the
rxrpc_call struct (->knlrecv_queue) rather than being handed over to the
in-kernel user.  To process the queue internally, a temporary function,
temp_deliver_data() has been added.  This will be replaced with common code
between the rxrpc_recvmsg() path and the kernel_rxrpc_recv_data() path in a
future patch.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |   72 +++---
 fs/afs/cmservice.c                 |  142 ++++++------
 fs/afs/fsclient.c                  |  148 +++++-------
 fs/afs/internal.h                  |   34 +--
 fs/afs/rxrpc.c                     |  439 +++++++++++++-----------------------
 fs/afs/vlclient.c                  |    7 -
 include/net/af_rxrpc.h             |   35 +--
 net/rxrpc/af_rxrpc.c               |   29 +-
 net/rxrpc/ar-internal.h            |   23 ++
 net/rxrpc/call_accept.c            |   13 +
 net/rxrpc/call_object.c            |    5 
 net/rxrpc/conn_event.c             |    1 
 net/rxrpc/input.c                  |   10 +
 net/rxrpc/output.c                 |    2 
 net/rxrpc/recvmsg.c                |  195 +++++++++++++---
 net/rxrpc/skbuff.c                 |    1 
 16 files changed, 570 insertions(+), 586 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index cfc8cb91452f..1b63bbc6b94f 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -748,6 +748,37 @@ The kernel interface functions are as follows:
      The msg must not specify a destination address, control data or any flags
      other than MSG_MORE.  len is the total amount of data to transmit.
 
+ (*) Receive data from a call.
+
+	int rxrpc_kernel_recv_data(struct socket *sock,
+				   struct rxrpc_call *call,
+				   void *buf,
+				   size_t size,
+				   size_t *_offset,
+				   bool want_more,
+				   u32 *_abort)
+
+      This is used to receive data from either the reply part of a client call
+      or the request part of a service call.  buf and size specify how much
+      data is desired and where to store it.  *_offset is added on to buf and
+      subtracted from size internally; the amount copied into the buffer is
+      added to *_offset before returning.
+
+      want_more should be true if further data will be required after this is
+      satisfied and false if this is the last item of the receive phase.
+
+      There are three normal returns: 0 if the buffer was filled and want_more
+      was true; 1 if the buffer was filled, the last DATA packet has been
+      emptied and want_more was false; and -EAGAIN if the function needs to be
+      called again.
+
+      If the last DATA packet is processed but the buffer contains less than
+      the amount requested, EBADMSG is returned.  If want_more wasn't set, but
+      more data was available, EMSGSIZE is returned.
+
+      If a remote ABORT is detected, the abort code received will be stored in
+      *_abort and ECONNABORTED will be returned.
+
  (*) Abort a call.
 
 	void rxrpc_kernel_abort_call(struct socket *sock,
@@ -825,47 +856,6 @@ The kernel interface functions are as follows:
      Other errors may be returned if the call had been aborted (-ECONNABORTED)
      or had timed out (-ETIME).
 
- (*) Record the delivery of a data message.
-
-	void rxrpc_kernel_data_consumed(struct rxrpc_call *call,
-					struct sk_buff *skb);
-
-     This is used to record a data message as having been consumed and to
-     update the ACK state for the call.  The message must still be passed to
-     rxrpc_kernel_free_skb() for disposal by the caller.
-
- (*) Free a message.
-
-	void rxrpc_kernel_free_skb(struct sk_buff *skb);
-
-     This is used to free a non-DATA socket buffer intercepted from an AF_RXRPC
-     socket.
-
- (*) Determine if a data message is the last one on a call.
-
-	bool rxrpc_kernel_is_data_last(struct sk_buff *skb);
-
-     This is used to determine if a socket buffer holds the last data message
-     to be received for a call (true will be returned if it does, false
-     if not).
-
-     The data message will be part of the reply on a client call and the
-     request on an incoming call.  In the latter case there will be more
-     messages, but in the former case there will not.
-
- (*) Get the abort code from an abort message.
-
-	u32 rxrpc_kernel_get_abort_code(struct sk_buff *skb);
-
-     This is used to extract the abort code from a remote abort message.
-
- (*) Get the error number from a local or network error message.
-
-	int rxrpc_kernel_get_error_number(struct sk_buff *skb);
-
-     This is used to extract the error number from a message indicating either
-     a local error occurred or a network error occurred.
-
  (*) Allocate a null key for doing anonymous security.
 
 	struct key *rxrpc_get_null_key(const char *keyname);
diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index 77ee481059ac..2037e7a77a37 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -17,15 +17,12 @@
 #include "internal.h"
 #include "afs_cm.h"
 
-static int afs_deliver_cb_init_call_back_state(struct afs_call *,
-					       struct sk_buff *, bool);
-static int afs_deliver_cb_init_call_back_state3(struct afs_call *,
-						struct sk_buff *, bool);
-static int afs_deliver_cb_probe(struct afs_call *, struct sk_buff *, bool);
-static int afs_deliver_cb_callback(struct afs_call *, struct sk_buff *, bool);
-static int afs_deliver_cb_probe_uuid(struct afs_call *, struct sk_buff *, bool);
-static int afs_deliver_cb_tell_me_about_yourself(struct afs_call *,
-						 struct sk_buff *, bool);
+static int afs_deliver_cb_init_call_back_state(struct afs_call *);
+static int afs_deliver_cb_init_call_back_state3(struct afs_call *);
+static int afs_deliver_cb_probe(struct afs_call *);
+static int afs_deliver_cb_callback(struct afs_call *);
+static int afs_deliver_cb_probe_uuid(struct afs_call *);
+static int afs_deliver_cb_tell_me_about_yourself(struct afs_call *);
 static void afs_cm_destructor(struct afs_call *);
 
 /*
@@ -130,7 +127,7 @@ static void afs_cm_destructor(struct afs_call *call)
 	 * received.  The step number here must match the final number in
 	 * afs_deliver_cb_callback().
 	 */
-	if (call->unmarshall == 6) {
+	if (call->unmarshall == 5) {
 		ASSERT(call->server && call->count && call->request);
 		afs_break_callbacks(call->server, call->count, call->request);
 	}
@@ -164,8 +161,7 @@ static void SRXAFSCB_CallBack(struct work_struct *work)
 /*
  * deliver request data to a CB.CallBack call
  */
-static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
-				   bool last)
+static int afs_deliver_cb_callback(struct afs_call *call)
 {
 	struct sockaddr_rxrpc srx;
 	struct afs_callback *cb;
@@ -174,7 +170,7 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 	u32 tmp;
 	int ret, loop;
 
-	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+	_enter("{%u}", call->unmarshall);
 
 	switch (call->unmarshall) {
 	case 0:
@@ -185,7 +181,7 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 		/* extract the FID array and its count in two steps */
 	case 1:
 		_debug("extract FID count");
-		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
+		ret = afs_extract_data(call, &call->tmp, 4, true);
 		if (ret < 0)
 			return ret;
 
@@ -202,8 +198,8 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 
 	case 2:
 		_debug("extract FID array");
-		ret = afs_extract_data(call, skb, last, call->buffer,
-				       call->count * 3 * 4);
+		ret = afs_extract_data(call, call->buffer,
+				       call->count * 3 * 4, true);
 		if (ret < 0)
 			return ret;
 
@@ -229,7 +225,7 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 		/* extract the callback array and its count in two steps */
 	case 3:
 		_debug("extract CB count");
-		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
+		ret = afs_extract_data(call, &call->tmp, 4, true);
 		if (ret < 0)
 			return ret;
 
@@ -239,13 +235,11 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 			return -EBADMSG;
 		call->offset = 0;
 		call->unmarshall++;
-		if (tmp == 0)
-			goto empty_cb_array;
 
 	case 4:
 		_debug("extract CB array");
-		ret = afs_extract_data(call, skb, last, call->request,
-				       call->count * 3 * 4);
+		ret = afs_extract_data(call, call->buffer,
+				       call->count * 3 * 4, false);
 		if (ret < 0)
 			return ret;
 
@@ -258,15 +252,9 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 			cb->type	= ntohl(*bp++);
 		}
 
-	empty_cb_array:
 		call->offset = 0;
 		call->unmarshall++;
 
-	case 5:
-		ret = afs_data_complete(call, skb, last);
-		if (ret < 0)
-			return ret;
-
 		/* Record that the message was unmarshalled successfully so
 		 * that the call destructor can know do the callback breaking
 		 * work, even if the final ACK isn't received.
@@ -275,7 +263,7 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 		 * updated also.
 		 */
 		call->unmarshall++;
-	case 6:
+	case 5:
 		break;
 	}
 
@@ -310,19 +298,17 @@ static void SRXAFSCB_InitCallBackState(struct work_struct *work)
 /*
  * deliver request data to a CB.InitCallBackState call
  */
-static int afs_deliver_cb_init_call_back_state(struct afs_call *call,
-					       struct sk_buff *skb,
-					       bool last)
+static int afs_deliver_cb_init_call_back_state(struct afs_call *call)
 {
 	struct sockaddr_rxrpc srx;
 	struct afs_server *server;
 	int ret;
 
-	_enter(",{%u},%d", skb->len, last);
+	_enter("");
 
 	rxrpc_kernel_get_peer(afs_socket, call->rxcall, &srx);
 
-	ret = afs_data_complete(call, skb, last);
+	ret = afs_extract_data(call, NULL, 0, false);
 	if (ret < 0)
 		return ret;
 
@@ -344,21 +330,61 @@ static int afs_deliver_cb_init_call_back_state(struct afs_call *call,
 /*
  * deliver request data to a CB.InitCallBackState3 call
  */
-static int afs_deliver_cb_init_call_back_state3(struct afs_call *call,
-						struct sk_buff *skb,
-						bool last)
+static int afs_deliver_cb_init_call_back_state3(struct afs_call *call)
 {
 	struct sockaddr_rxrpc srx;
 	struct afs_server *server;
+	struct afs_uuid *r;
+	unsigned loop;
+	__be32 *b;
+	int ret;
 
-	_enter(",{%u},%d", skb->len, last);
+	_enter("");
 
 	rxrpc_kernel_get_peer(afs_socket, call->rxcall, &srx);
 
-	/* There are some arguments that we ignore */
-	afs_data_consumed(call, skb);
-	if (!last)
-		return -EAGAIN;
+	_enter("{%u}", call->unmarshall);
+
+	switch (call->unmarshall) {
+	case 0:
+		call->offset = 0;
+		call->buffer = kmalloc(11 * sizeof(__be32), GFP_KERNEL);
+		if (!call->buffer)
+			return -ENOMEM;
+		call->unmarshall++;
+
+	case 1:
+		_debug("extract UUID");
+		ret = afs_extract_data(call, call->buffer,
+				       11 * sizeof(__be32), false);
+		switch (ret) {
+		case 0:		break;
+		case -EAGAIN:	return 0;
+		default:	return ret;
+		}
+
+		_debug("unmarshall UUID");
+		call->request = kmalloc(sizeof(struct afs_uuid), GFP_KERNEL);
+		if (!call->request)
+			return -ENOMEM;
+
+		b = call->buffer;
+		r = call->request;
+		r->time_low			= ntohl(b[0]);
+		r->time_mid			= ntohl(b[1]);
+		r->time_hi_and_version		= ntohl(b[2]);
+		r->clock_seq_hi_and_reserved 	= ntohl(b[3]);
+		r->clock_seq_low		= ntohl(b[4]);
+
+		for (loop = 0; loop < 6; loop++)
+			r->node[loop] = ntohl(b[loop + 5]);
+
+		call->offset = 0;
+		call->unmarshall++;
+
+	case 2:
+		break;
+	}
 
 	/* no unmarshalling required */
 	call->state = AFS_CALL_REPLYING;
@@ -390,14 +416,13 @@ static void SRXAFSCB_Probe(struct work_struct *work)
 /*
  * deliver request data to a CB.Probe call
  */
-static int afs_deliver_cb_probe(struct afs_call *call, struct sk_buff *skb,
-				bool last)
+static int afs_deliver_cb_probe(struct afs_call *call)
 {
 	int ret;
 
-	_enter(",{%u},%d", skb->len, last);
+	_enter("");
 
-	ret = afs_data_complete(call, skb, last);
+	ret = afs_extract_data(call, NULL, 0, false);
 	if (ret < 0)
 		return ret;
 
@@ -435,19 +460,14 @@ static void SRXAFSCB_ProbeUuid(struct work_struct *work)
 /*
  * deliver request data to a CB.ProbeUuid call
  */
-static int afs_deliver_cb_probe_uuid(struct afs_call *call, struct sk_buff *skb,
-				     bool last)
+static int afs_deliver_cb_probe_uuid(struct afs_call *call)
 {
 	struct afs_uuid *r;
 	unsigned loop;
 	__be32 *b;
 	int ret;
 
-	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
-
-	ret = afs_data_complete(call, skb, last);
-	if (ret < 0)
-		return ret;
+	_enter("{%u}", call->unmarshall);
 
 	switch (call->unmarshall) {
 	case 0:
@@ -459,8 +479,8 @@ static int afs_deliver_cb_probe_uuid(struct afs_call *call, struct sk_buff *skb,
 
 	case 1:
 		_debug("extract UUID");
-		ret = afs_extract_data(call, skb, last, call->buffer,
-				       11 * sizeof(__be32));
+		ret = afs_extract_data(call, call->buffer,
+				       11 * sizeof(__be32), false);
 		switch (ret) {
 		case 0:		break;
 		case -EAGAIN:	return 0;
@@ -487,16 +507,9 @@ static int afs_deliver_cb_probe_uuid(struct afs_call *call, struct sk_buff *skb,
 		call->unmarshall++;
 
 	case 2:
-		_debug("trailer");
-		if (skb->len != 0)
-			return -EBADMSG;
 		break;
 	}
 
-	ret = afs_data_complete(call, skb, last);
-	if (ret < 0)
-		return ret;
-
 	call->state = AFS_CALL_REPLYING;
 
 	INIT_WORK(&call->work, SRXAFSCB_ProbeUuid);
@@ -570,14 +583,13 @@ static void SRXAFSCB_TellMeAboutYourself(struct work_struct *work)
 /*
  * deliver request data to a CB.TellMeAboutYourself call
  */
-static int afs_deliver_cb_tell_me_about_yourself(struct afs_call *call,
-						 struct sk_buff *skb, bool last)
+static int afs_deliver_cb_tell_me_about_yourself(struct afs_call *call)
 {
 	int ret;
 
-	_enter(",{%u},%d", skb->len, last);
+	_enter("");
 
-	ret = afs_data_complete(call, skb, last);
+	ret = afs_extract_data(call, NULL, 0, false);
 	if (ret < 0)
 		return ret;
 
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index 9312b92e54be..96f4d764d1a6 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -235,16 +235,15 @@ static void xdr_decode_AFSFetchVolumeStatus(const __be32 **_bp,
 /*
  * deliver reply data to an FS.FetchStatus
  */
-static int afs_deliver_fs_fetch_status(struct afs_call *call,
-				       struct sk_buff *skb, bool last)
+static int afs_deliver_fs_fetch_status(struct afs_call *call)
 {
 	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
 	int ret;
 
-	_enter(",,%u", last);
+	_enter("");
 
-	ret = afs_transfer_reply(call, skb, last);
+	ret = afs_transfer_reply(call);
 	if (ret < 0)
 		return ret;
 
@@ -307,8 +306,7 @@ int afs_fs_fetch_file_status(struct afs_server *server,
 /*
  * deliver reply data to an FS.FetchData
  */
-static int afs_deliver_fs_fetch_data(struct afs_call *call,
-				     struct sk_buff *skb, bool last)
+static int afs_deliver_fs_fetch_data(struct afs_call *call)
 {
 	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
@@ -316,7 +314,7 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 	void *buffer;
 	int ret;
 
-	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+	_enter("{%u}", call->unmarshall);
 
 	switch (call->unmarshall) {
 	case 0:
@@ -332,7 +330,7 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 		 * client) */
 	case 1:
 		_debug("extract data length (MSW)");
-		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
+		ret = afs_extract_data(call, &call->tmp, 4, true);
 		if (ret < 0)
 			return ret;
 
@@ -347,7 +345,7 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 		/* extract the returned data length */
 	case 2:
 		_debug("extract data length");
-		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
+		ret = afs_extract_data(call, &call->tmp, 4, true);
 		if (ret < 0)
 			return ret;
 
@@ -363,10 +361,10 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 		_debug("extract data");
 		if (call->count > 0) {
 			page = call->reply3;
-			buffer = kmap_atomic(page);
-			ret = afs_extract_data(call, skb, last, buffer,
-					       call->count);
-			kunmap_atomic(buffer);
+			buffer = kmap(page);
+			ret = afs_extract_data(call, buffer,
+					       call->count, true);
+			kunmap(buffer);
 			if (ret < 0)
 				return ret;
 		}
@@ -376,8 +374,8 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 
 		/* extract the metadata */
 	case 4:
-		ret = afs_extract_data(call, skb, last, call->buffer,
-				       (21 + 3 + 6) * 4);
+		ret = afs_extract_data(call, call->buffer,
+				       (21 + 3 + 6) * 4, false);
 		if (ret < 0)
 			return ret;
 
@@ -391,18 +389,15 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 		call->unmarshall++;
 
 	case 5:
-		ret = afs_data_complete(call, skb, last);
-		if (ret < 0)
-			return ret;
 		break;
 	}
 
 	if (call->count < PAGE_SIZE) {
 		_debug("clear");
 		page = call->reply3;
-		buffer = kmap_atomic(page);
+		buffer = kmap(page);
 		memset(buffer + call->count, 0, PAGE_SIZE - call->count);
-		kunmap_atomic(buffer);
+		kunmap(buffer);
 	}
 
 	_leave(" = 0 [done]");
@@ -515,13 +510,12 @@ int afs_fs_fetch_data(struct afs_server *server,
 /*
  * deliver reply data to an FS.GiveUpCallBacks
  */
-static int afs_deliver_fs_give_up_callbacks(struct afs_call *call,
-					    struct sk_buff *skb, bool last)
+static int afs_deliver_fs_give_up_callbacks(struct afs_call *call)
 {
-	_enter(",{%u},%d", skb->len, last);
+	_enter("");
 
 	/* shouldn't be any reply data */
-	return afs_data_complete(call, skb, last);
+	return afs_extract_data(call, NULL, 0, false);
 }
 
 /*
@@ -599,16 +593,15 @@ int afs_fs_give_up_callbacks(struct afs_server *server,
 /*
  * deliver reply data to an FS.CreateFile or an FS.MakeDir
  */
-static int afs_deliver_fs_create_vnode(struct afs_call *call,
-				       struct sk_buff *skb, bool last)
+static int afs_deliver_fs_create_vnode(struct afs_call *call)
 {
 	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
 	int ret;
 
-	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+	_enter("{%u}", call->unmarshall);
 
-	ret = afs_transfer_reply(call, skb, last);
+	ret = afs_transfer_reply(call);
 	if (ret < 0)
 		return ret;
 
@@ -696,16 +689,15 @@ int afs_fs_create(struct afs_server *server,
 /*
  * deliver reply data to an FS.RemoveFile or FS.RemoveDir
  */
-static int afs_deliver_fs_remove(struct afs_call *call,
-				 struct sk_buff *skb, bool last)
+static int afs_deliver_fs_remove(struct afs_call *call)
 {
 	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
 	int ret;
 
-	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+	_enter("{%u}", call->unmarshall);
 
-	ret = afs_transfer_reply(call, skb, last);
+	ret = afs_transfer_reply(call);
 	if (ret < 0)
 		return ret;
 
@@ -777,16 +769,15 @@ int afs_fs_remove(struct afs_server *server,
 /*
  * deliver reply data to an FS.Link
  */
-static int afs_deliver_fs_link(struct afs_call *call,
-			       struct sk_buff *skb, bool last)
+static int afs_deliver_fs_link(struct afs_call *call)
 {
 	struct afs_vnode *dvnode = call->reply, *vnode = call->reply2;
 	const __be32 *bp;
 	int ret;
 
-	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+	_enter("{%u}", call->unmarshall);
 
-	ret = afs_transfer_reply(call, skb, last);
+	ret = afs_transfer_reply(call);
 	if (ret < 0)
 		return ret;
 
@@ -863,16 +854,15 @@ int afs_fs_link(struct afs_server *server,
 /*
  * deliver reply data to an FS.Symlink
  */
-static int afs_deliver_fs_symlink(struct afs_call *call,
-				  struct sk_buff *skb, bool last)
+static int afs_deliver_fs_symlink(struct afs_call *call)
 {
 	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
 	int ret;
 
-	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+	_enter("{%u}", call->unmarshall);
 
-	ret = afs_transfer_reply(call, skb, last);
+	ret = afs_transfer_reply(call);
 	if (ret < 0)
 		return ret;
 
@@ -968,16 +958,15 @@ int afs_fs_symlink(struct afs_server *server,
 /*
  * deliver reply data to an FS.Rename
  */
-static int afs_deliver_fs_rename(struct afs_call *call,
-				  struct sk_buff *skb, bool last)
+static int afs_deliver_fs_rename(struct afs_call *call)
 {
 	struct afs_vnode *orig_dvnode = call->reply, *new_dvnode = call->reply2;
 	const __be32 *bp;
 	int ret;
 
-	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+	_enter("{%u}", call->unmarshall);
 
-	ret = afs_transfer_reply(call, skb, last);
+	ret = afs_transfer_reply(call);
 	if (ret < 0)
 		return ret;
 
@@ -1072,16 +1061,15 @@ int afs_fs_rename(struct afs_server *server,
 /*
  * deliver reply data to an FS.StoreData
  */
-static int afs_deliver_fs_store_data(struct afs_call *call,
-				     struct sk_buff *skb, bool last)
+static int afs_deliver_fs_store_data(struct afs_call *call)
 {
 	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
 	int ret;
 
-	_enter(",,%u", last);
+	_enter("");
 
-	ret = afs_transfer_reply(call, skb, last);
+	ret = afs_transfer_reply(call);
 	if (ret < 0)
 		return ret;
 
@@ -1251,17 +1239,16 @@ int afs_fs_store_data(struct afs_server *server, struct afs_writeback *wb,
 /*
  * deliver reply data to an FS.StoreStatus
  */
-static int afs_deliver_fs_store_status(struct afs_call *call,
-				       struct sk_buff *skb, bool last)
+static int afs_deliver_fs_store_status(struct afs_call *call)
 {
 	afs_dataversion_t *store_version;
 	struct afs_vnode *vnode = call->reply;
 	const __be32 *bp;
 	int ret;
 
-	_enter(",,%u", last);
+	_enter("");
 
-	ret = afs_transfer_reply(call, skb, last);
+	ret = afs_transfer_reply(call);
 	if (ret < 0)
 		return ret;
 
@@ -1443,14 +1430,13 @@ int afs_fs_setattr(struct afs_server *server, struct key *key,
 /*
  * deliver reply data to an FS.GetVolumeStatus
  */
-static int afs_deliver_fs_get_volume_status(struct afs_call *call,
-					    struct sk_buff *skb, bool last)
+static int afs_deliver_fs_get_volume_status(struct afs_call *call)
 {
 	const __be32 *bp;
 	char *p;
 	int ret;
 
-	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+	_enter("{%u}", call->unmarshall);
 
 	switch (call->unmarshall) {
 	case 0:
@@ -1460,8 +1446,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 		/* extract the returned status record */
 	case 1:
 		_debug("extract status");
-		ret = afs_extract_data(call, skb, last, call->buffer,
-				       12 * 4);
+		ret = afs_extract_data(call, call->buffer,
+				       12 * 4, true);
 		if (ret < 0)
 			return ret;
 
@@ -1472,7 +1458,7 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 
 		/* extract the volume name length */
 	case 2:
-		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
+		ret = afs_extract_data(call, &call->tmp, 4, true);
 		if (ret < 0)
 			return ret;
 
@@ -1487,8 +1473,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 	case 3:
 		_debug("extract volname");
 		if (call->count > 0) {
-			ret = afs_extract_data(call, skb, last, call->reply3,
-					       call->count);
+			ret = afs_extract_data(call, call->reply3,
+					       call->count, true);
 			if (ret < 0)
 				return ret;
 		}
@@ -1508,8 +1494,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 		call->count = 4 - (call->count & 3);
 
 	case 4:
-		ret = afs_extract_data(call, skb, last, call->buffer,
-				       call->count);
+		ret = afs_extract_data(call, call->buffer,
+				       call->count, true);
 		if (ret < 0)
 			return ret;
 
@@ -1519,7 +1505,7 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 
 		/* extract the offline message length */
 	case 5:
-		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
+		ret = afs_extract_data(call, &call->tmp, 4, true);
 		if (ret < 0)
 			return ret;
 
@@ -1534,8 +1520,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 	case 6:
 		_debug("extract offline");
 		if (call->count > 0) {
-			ret = afs_extract_data(call, skb, last, call->reply3,
-					       call->count);
+			ret = afs_extract_data(call, call->reply3,
+					       call->count, true);
 			if (ret < 0)
 				return ret;
 		}
@@ -1555,8 +1541,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 		call->count = 4 - (call->count & 3);
 
 	case 7:
-		ret = afs_extract_data(call, skb, last, call->buffer,
-				       call->count);
+		ret = afs_extract_data(call, call->buffer,
+				       call->count, true);
 		if (ret < 0)
 			return ret;
 
@@ -1566,7 +1552,7 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 
 		/* extract the message of the day length */
 	case 8:
-		ret = afs_extract_data(call, skb, last, &call->tmp, 4);
+		ret = afs_extract_data(call, &call->tmp, 4, true);
 		if (ret < 0)
 			return ret;
 
@@ -1581,8 +1567,8 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 	case 9:
 		_debug("extract motd");
 		if (call->count > 0) {
-			ret = afs_extract_data(call, skb, last, call->reply3,
-					       call->count);
+			ret = afs_extract_data(call, call->reply3,
+					       call->count, true);
 			if (ret < 0)
 				return ret;
 		}
@@ -1595,26 +1581,17 @@ static int afs_deliver_fs_get_volume_status(struct afs_call *call,
 		call->unmarshall++;
 
 		/* extract the message of the day padding */
-		if ((call->count & 3) == 0) {
-			call->unmarshall++;
-			goto no_motd_padding;
-		}
-		call->count = 4 - (call->count & 3);
+		call->count = (4 - (call->count & 3)) & 3;
 
 	case 10:
-		ret = afs_extract_data(call, skb, last, call->buffer,
-				       call->count);
+		ret = afs_extract_data(call, call->buffer,
+				       call->count, false);
 		if (ret < 0)
 			return ret;
 
 		call->offset = 0;
 		call->unmarshall++;
-	no_motd_padding:
-
 	case 11:
-		ret = afs_data_complete(call, skb, last);
-		if (ret < 0)
-			return ret;
 		break;
 	}
 
@@ -1685,15 +1662,14 @@ int afs_fs_get_volume_status(struct afs_server *server,
 /*
  * deliver reply data to an FS.SetLock, FS.ExtendLock or FS.ReleaseLock
  */
-static int afs_deliver_fs_xxxx_lock(struct afs_call *call,
-				    struct sk_buff *skb, bool last)
+static int afs_deliver_fs_xxxx_lock(struct afs_call *call)
 {
 	const __be32 *bp;
 	int ret;
 
-	_enter("{%u},{%u},%d", call->unmarshall, skb->len, last);
+	_enter("{%u}", call->unmarshall);
 
-	ret = afs_transfer_reply(call, skb, last);
+	ret = afs_transfer_reply(call);
 	if (ret < 0)
 		return ret;
 
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index d97552de9c59..1c90d43228b4 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -13,7 +13,6 @@
 #include <linux/kernel.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
-#include <linux/skbuff.h>
 #include <linux/rxrpc.h>
 #include <linux/key.h>
 #include <linux/workqueue.h>
@@ -57,7 +56,7 @@ struct afs_mount_params {
  */
 struct afs_wait_mode {
 	/* RxRPC received message notification */
-	void (*rx_wakeup)(struct afs_call *call);
+	rxrpc_notify_rx_t notify_rx;
 
 	/* synchronous call waiter and call dispatched notification */
 	int (*wait)(struct afs_call *call);
@@ -76,10 +75,8 @@ struct afs_call {
 	const struct afs_call_type *type;	/* type of call */
 	const struct afs_wait_mode *wait_mode;	/* completion wait mode */
 	wait_queue_head_t	waitq;		/* processes awaiting completion */
-	void (*async_workfn)(struct afs_call *call); /* asynchronous work function */
 	struct work_struct	async_work;	/* asynchronous work processor */
 	struct work_struct	work;		/* actual work processor */
-	struct sk_buff_head	rx_queue;	/* received packets */
 	struct rxrpc_call	*rxcall;	/* RxRPC call handle */
 	struct key		*key;		/* security for this call */
 	struct afs_server	*server;	/* server affected by incoming CM call */
@@ -93,6 +90,7 @@ struct afs_call {
 	void			*reply4;	/* reply buffer (fourth part) */
 	pgoff_t			first;		/* first page in mapping to deal with */
 	pgoff_t			last;		/* last page in mapping to deal with */
+	size_t			offset;		/* offset into received data store */
 	enum {					/* call state */
 		AFS_CALL_REQUESTING,	/* request is being sent for outgoing call */
 		AFS_CALL_AWAIT_REPLY,	/* awaiting reply to outgoing call */
@@ -100,21 +98,18 @@ struct afs_call {
 		AFS_CALL_AWAIT_REQUEST,	/* awaiting request data on incoming call */
 		AFS_CALL_REPLYING,	/* replying to incoming call */
 		AFS_CALL_AWAIT_ACK,	/* awaiting final ACK of incoming call */
-		AFS_CALL_COMPLETE,	/* successfully completed */
-		AFS_CALL_BUSY,		/* server was busy */
-		AFS_CALL_ABORTED,	/* call was aborted */
-		AFS_CALL_ERROR,		/* call failed due to error */
+		AFS_CALL_COMPLETE,	/* Completed or failed */
 	}			state;
 	int			error;		/* error code */
+	u32			abort_code;	/* Remote abort ID or 0 */
 	unsigned		request_size;	/* size of request data */
 	unsigned		reply_max;	/* maximum size of reply */
-	unsigned		reply_size;	/* current size of reply */
 	unsigned		first_offset;	/* offset into mapping[first] */
 	unsigned		last_to;	/* amount of mapping[last] */
-	unsigned		offset;		/* offset into received data store */
 	unsigned char		unmarshall;	/* unmarshalling phase */
 	bool			incoming;	/* T if incoming call */
 	bool			send_pages;	/* T if data from mapping should be sent */
+	bool			need_attention;	/* T if RxRPC poked us */
 	u16			service_id;	/* RxRPC service ID to call */
 	__be16			port;		/* target UDP port */
 	__be32			operation_ID;	/* operation ID for an incoming call */
@@ -129,8 +124,7 @@ struct afs_call_type {
 	/* deliver request or reply data to an call
 	 * - returning an error will cause the call to be aborted
 	 */
-	int (*deliver)(struct afs_call *call, struct sk_buff *skb,
-		       bool last);
+	int (*deliver)(struct afs_call *call);
 
 	/* map an abort code to an error number */
 	int (*abort_to_error)(u32 abort_code);
@@ -612,27 +606,19 @@ extern struct socket *afs_socket;
 
 extern int afs_open_socket(void);
 extern void afs_close_socket(void);
-extern void afs_data_consumed(struct afs_call *, struct sk_buff *);
 extern int afs_make_call(struct in_addr *, struct afs_call *, gfp_t,
 			 const struct afs_wait_mode *);
 extern struct afs_call *afs_alloc_flat_call(const struct afs_call_type *,
 					    size_t, size_t);
 extern void afs_flat_call_destructor(struct afs_call *);
-extern int afs_transfer_reply(struct afs_call *, struct sk_buff *, bool);
 extern void afs_send_empty_reply(struct afs_call *);
 extern void afs_send_simple_reply(struct afs_call *, const void *, size_t);
-extern int afs_extract_data(struct afs_call *, struct sk_buff *, bool, void *,
-			    size_t);
+extern int afs_extract_data(struct afs_call *, void *, size_t, bool);
 
-static inline int afs_data_complete(struct afs_call *call, struct sk_buff *skb,
-				    bool last)
+static inline int afs_transfer_reply(struct afs_call *call)
 {
-	if (skb->len > 0)
-		return -EBADMSG;
-	afs_data_consumed(call, skb);
-	if (!last)
-		return -EAGAIN;
-	return 0;
+	return afs_extract_data(call, call->buffer + call->offset,
+				call->reply_max, false);
 }
 
 /*
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 7b0d18900f50..244896baf241 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -19,31 +19,31 @@
 struct socket *afs_socket; /* my RxRPC socket */
 static struct workqueue_struct *afs_async_calls;
 static atomic_t afs_outstanding_calls;
-static atomic_t afs_outstanding_skbs;
 
-static void afs_wake_up_call_waiter(struct afs_call *);
+static void afs_free_call(struct afs_call *);
+static void afs_wake_up_call_waiter(struct sock *, struct rxrpc_call *, unsigned long);
 static int afs_wait_for_call_to_complete(struct afs_call *);
-static void afs_wake_up_async_call(struct afs_call *);
+static void afs_wake_up_async_call(struct sock *, struct rxrpc_call *, unsigned long);
 static int afs_dont_wait_for_call_to_complete(struct afs_call *);
-static void afs_process_async_call(struct afs_call *);
-static void afs_rx_interceptor(struct sock *, unsigned long, struct sk_buff *);
-static int afs_deliver_cm_op_id(struct afs_call *, struct sk_buff *, bool);
+static void afs_process_async_call(struct work_struct *);
+static void afs_rx_new_call(struct sock *);
+static int afs_deliver_cm_op_id(struct afs_call *);
 
 /* synchronous call management */
 const struct afs_wait_mode afs_sync_call = {
-	.rx_wakeup	= afs_wake_up_call_waiter,
+	.notify_rx	= afs_wake_up_call_waiter,
 	.wait		= afs_wait_for_call_to_complete,
 };
 
 /* asynchronous call management */
 const struct afs_wait_mode afs_async_call = {
-	.rx_wakeup	= afs_wake_up_async_call,
+	.notify_rx	= afs_wake_up_async_call,
 	.wait		= afs_dont_wait_for_call_to_complete,
 };
 
 /* asynchronous incoming call management */
 static const struct afs_wait_mode afs_async_incoming_call = {
-	.rx_wakeup	= afs_wake_up_async_call,
+	.notify_rx	= afs_wake_up_async_call,
 };
 
 /* asynchronous incoming call initial processing */
@@ -55,16 +55,8 @@ static const struct afs_call_type afs_RXCMxxxx = {
 
 static void afs_collect_incoming_call(struct work_struct *);
 
-static struct sk_buff_head afs_incoming_calls;
 static DECLARE_WORK(afs_collect_incoming_call_work, afs_collect_incoming_call);
 
-static void afs_async_workfn(struct work_struct *work)
-{
-	struct afs_call *call = container_of(work, struct afs_call, async_work);
-
-	call->async_workfn(call);
-}
-
 static int afs_wait_atomic_t(atomic_t *p)
 {
 	schedule();
@@ -83,8 +75,6 @@ int afs_open_socket(void)
 
 	_enter("");
 
-	skb_queue_head_init(&afs_incoming_calls);
-
 	ret = -ENOMEM;
 	afs_async_calls = create_singlethread_workqueue("kafsd");
 	if (!afs_async_calls)
@@ -110,12 +100,12 @@ int afs_open_socket(void)
 	if (ret < 0)
 		goto error_2;
 
+	rxrpc_kernel_new_call_notification(socket, afs_rx_new_call);
+
 	ret = kernel_listen(socket, INT_MAX);
 	if (ret < 0)
 		goto error_2;
 
-	rxrpc_kernel_intercept_rx_messages(socket, afs_rx_interceptor);
-
 	afs_socket = socket;
 	_leave(" = 0");
 	return 0;
@@ -136,52 +126,20 @@ void afs_close_socket(void)
 {
 	_enter("");
 
+	_debug("outstanding %u", atomic_read(&afs_outstanding_calls));
 	wait_on_atomic_t(&afs_outstanding_calls, afs_wait_atomic_t,
 			 TASK_UNINTERRUPTIBLE);
 	_debug("no outstanding calls");
 
+	flush_workqueue(afs_async_calls);
 	sock_release(afs_socket);
 
 	_debug("dework");
 	destroy_workqueue(afs_async_calls);
-
-	ASSERTCMP(atomic_read(&afs_outstanding_skbs), ==, 0);
 	_leave("");
 }
 
 /*
- * Note that the data in a socket buffer is now consumed.
- */
-void afs_data_consumed(struct afs_call *call, struct sk_buff *skb)
-{
-	if (!skb) {
-		_debug("DLVR NULL [%d]", atomic_read(&afs_outstanding_skbs));
-		dump_stack();
-	} else {
-		_debug("DLVR %p{%u} [%d]",
-		       skb, skb->mark, atomic_read(&afs_outstanding_skbs));
-		rxrpc_kernel_data_consumed(call->rxcall, skb);
-	}
-}
-
-/*
- * free a socket buffer
- */
-static void afs_free_skb(struct sk_buff *skb)
-{
-	if (!skb) {
-		_debug("FREE NULL [%d]", atomic_read(&afs_outstanding_skbs));
-		dump_stack();
-	} else {
-		_debug("FREE %p{%u} [%d]",
-		       skb, skb->mark, atomic_read(&afs_outstanding_skbs));
-		if (atomic_dec_return(&afs_outstanding_skbs) == -1)
-			BUG();
-		rxrpc_kernel_free_skb(skb);
-	}
-}
-
-/*
  * free a call
  */
 static void afs_free_call(struct afs_call *call)
@@ -191,7 +149,6 @@ static void afs_free_call(struct afs_call *call)
 
 	ASSERTCMP(call->rxcall, ==, NULL);
 	ASSERT(!work_pending(&call->async_work));
-	ASSERT(skb_queue_empty(&call->rx_queue));
 	ASSERT(call->type->name != NULL);
 
 	kfree(call->request);
@@ -227,7 +184,7 @@ static void afs_end_call(struct afs_call *call)
  * allocate a call with flat request and reply buffers
  */
 struct afs_call *afs_alloc_flat_call(const struct afs_call_type *type,
-				     size_t request_size, size_t reply_size)
+				     size_t request_size, size_t reply_max)
 {
 	struct afs_call *call;
 
@@ -241,7 +198,7 @@ struct afs_call *afs_alloc_flat_call(const struct afs_call_type *type,
 
 	call->type = type;
 	call->request_size = request_size;
-	call->reply_max = reply_size;
+	call->reply_max = reply_max;
 
 	if (request_size) {
 		call->request = kmalloc(request_size, GFP_NOFS);
@@ -249,14 +206,13 @@ struct afs_call *afs_alloc_flat_call(const struct afs_call_type *type,
 			goto nomem_free;
 	}
 
-	if (reply_size) {
-		call->buffer = kmalloc(reply_size, GFP_NOFS);
+	if (reply_max) {
+		call->buffer = kmalloc(reply_max, GFP_NOFS);
 		if (!call->buffer)
 			goto nomem_free;
 	}
 
 	init_waitqueue_head(&call->waitq);
-	skb_queue_head_init(&call->rx_queue);
 	return call;
 
 nomem_free:
@@ -354,7 +310,6 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	struct msghdr msg;
 	struct kvec iov[1];
 	int ret;
-	struct sk_buff *skb;
 
 	_enter("%x,{%d},", addr->s_addr, ntohs(call->port));
 
@@ -366,8 +321,7 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	       atomic_read(&afs_outstanding_calls));
 
 	call->wait_mode = wait_mode;
-	call->async_workfn = afs_process_async_call;
-	INIT_WORK(&call->async_work, afs_async_workfn);
+	INIT_WORK(&call->async_work, afs_process_async_call);
 
 	memset(&srx, 0, sizeof(srx));
 	srx.srx_family = AF_RXRPC;
@@ -380,7 +334,8 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 
 	/* create a call */
 	rxcall = rxrpc_kernel_begin_call(afs_socket, &srx, call->key,
-					 (unsigned long) call, gfp);
+					 (unsigned long) call, gfp,
+					 wait_mode->notify_rx);
 	call->key = NULL;
 	if (IS_ERR(rxcall)) {
 		ret = PTR_ERR(rxcall);
@@ -423,8 +378,6 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 
 error_do_abort:
 	rxrpc_kernel_abort_call(afs_socket, rxcall, RX_USER_ABORT);
-	while ((skb = skb_dequeue(&call->rx_queue)))
-		afs_free_skb(skb);
 error_kill_call:
 	afs_end_call(call);
 	_leave(" = %d", ret);
@@ -432,141 +385,77 @@ error_kill_call:
 }
 
 /*
- * Handles intercepted messages that were arriving in the socket's Rx queue.
- *
- * Called from the AF_RXRPC call processor in waitqueue process context.  For
- * each call, it is guaranteed this will be called in order of packet to be
- * delivered.
- */
-static void afs_rx_interceptor(struct sock *sk, unsigned long user_call_ID,
-			       struct sk_buff *skb)
-{
-	struct afs_call *call = (struct afs_call *) user_call_ID;
-
-	_enter("%p,,%u", call, skb->mark);
-
-	_debug("ICPT %p{%u} [%d]",
-	       skb, skb->mark, atomic_read(&afs_outstanding_skbs));
-
-	ASSERTCMP(sk, ==, afs_socket->sk);
-	atomic_inc(&afs_outstanding_skbs);
-
-	if (!call) {
-		/* its an incoming call for our callback service */
-		skb_queue_tail(&afs_incoming_calls, skb);
-		queue_work(afs_wq, &afs_collect_incoming_call_work);
-	} else {
-		/* route the messages directly to the appropriate call */
-		skb_queue_tail(&call->rx_queue, skb);
-		call->wait_mode->rx_wakeup(call);
-	}
-
-	_leave("");
-}
-
-/*
  * deliver messages to a call
  */
 static void afs_deliver_to_call(struct afs_call *call)
 {
-	struct sk_buff *skb;
-	bool last;
 	u32 abort_code;
 	int ret;
 
-	_enter("");
-
-	while ((call->state == AFS_CALL_AWAIT_REPLY ||
-		call->state == AFS_CALL_AWAIT_OP_ID ||
-		call->state == AFS_CALL_AWAIT_REQUEST ||
-		call->state == AFS_CALL_AWAIT_ACK) &&
-	       (skb = skb_dequeue(&call->rx_queue))) {
-		switch (skb->mark) {
-		case RXRPC_SKB_MARK_DATA:
-			_debug("Rcv DATA");
-			last = rxrpc_kernel_is_data_last(skb);
-			ret = call->type->deliver(call, skb, last);
-			switch (ret) {
-			case -EAGAIN:
-				if (last) {
-					_debug("short data");
-					goto unmarshal_error;
-				}
-				break;
-			case 0:
-				ASSERT(last);
-				if (call->state == AFS_CALL_AWAIT_REPLY)
-					call->state = AFS_CALL_COMPLETE;
-				break;
-			case -ENOTCONN:
-				abort_code = RX_CALL_DEAD;
-				goto do_abort;
-			case -ENOTSUPP:
-				abort_code = RX_INVALID_OPERATION;
-				goto do_abort;
-			default:
-			unmarshal_error:
-				abort_code = RXGEN_CC_UNMARSHAL;
-				if (call->state != AFS_CALL_AWAIT_REPLY)
-					abort_code = RXGEN_SS_UNMARSHAL;
-			do_abort:
-				rxrpc_kernel_abort_call(afs_socket,
-							call->rxcall,
-							abort_code);
-				call->error = ret;
-				call->state = AFS_CALL_ERROR;
-				break;
+	_enter("%s", call->type->name);
+
+	while (call->state == AFS_CALL_AWAIT_REPLY ||
+	       call->state == AFS_CALL_AWAIT_OP_ID ||
+	       call->state == AFS_CALL_AWAIT_REQUEST ||
+	       call->state == AFS_CALL_AWAIT_ACK
+	       ) {
+		if (call->state == AFS_CALL_AWAIT_ACK) {
+			size_t offset = 0;
+			ret = rxrpc_kernel_recv_data(afs_socket, call->rxcall,
+						     NULL, 0, &offset, false,
+						     &call->abort_code);
+			if (ret == -EINPROGRESS || ret == -EAGAIN)
+				return;
+			if (ret == 1) {
+				call->state = AFS_CALL_COMPLETE;
+				goto done;
 			}
-			break;
-		case RXRPC_SKB_MARK_FINAL_ACK:
-			_debug("Rcv ACK");
-			call->state = AFS_CALL_COMPLETE;
-			break;
-		case RXRPC_SKB_MARK_BUSY:
-			_debug("Rcv BUSY");
-			call->error = -EBUSY;
-			call->state = AFS_CALL_BUSY;
-			break;
-		case RXRPC_SKB_MARK_REMOTE_ABORT:
-			abort_code = rxrpc_kernel_get_abort_code(skb);
-			call->error = call->type->abort_to_error(abort_code);
-			call->state = AFS_CALL_ABORTED;
-			_debug("Rcv ABORT %u -> %d", abort_code, call->error);
-			break;
-		case RXRPC_SKB_MARK_LOCAL_ABORT:
-			abort_code = rxrpc_kernel_get_abort_code(skb);
-			call->error = call->type->abort_to_error(abort_code);
-			call->state = AFS_CALL_ABORTED;
-			_debug("Loc ABORT %u -> %d", abort_code, call->error);
-			break;
-		case RXRPC_SKB_MARK_NET_ERROR:
-			call->error = -rxrpc_kernel_get_error_number(skb);
-			call->state = AFS_CALL_ERROR;
-			_debug("Rcv NET ERROR %d", call->error);
-			break;
-		case RXRPC_SKB_MARK_LOCAL_ERROR:
-			call->error = -rxrpc_kernel_get_error_number(skb);
-			call->state = AFS_CALL_ERROR;
-			_debug("Rcv LOCAL ERROR %d", call->error);
-			break;
-		default:
-			BUG();
-			break;
+			return;
 		}
 
-		afs_free_skb(skb);
-	}
-
-	/* make sure the queue is empty if the call is done with (we might have
-	 * aborted the call early because of an unmarshalling error) */
-	if (call->state >= AFS_CALL_COMPLETE) {
-		while ((skb = skb_dequeue(&call->rx_queue)))
-			afs_free_skb(skb);
-		if (call->incoming)
-			afs_end_call(call);
+		ret = call->type->deliver(call);
+		switch (ret) {
+		case 0:
+			if (call->state == AFS_CALL_AWAIT_REPLY)
+				call->state = AFS_CALL_COMPLETE;
+			goto done;
+		case -EINPROGRESS:
+		case -EAGAIN:
+			goto out;
+		case -ENOTCONN:
+			abort_code = RX_CALL_DEAD;
+			rxrpc_kernel_abort_call(afs_socket, call->rxcall,
+						abort_code);
+			goto do_abort;
+		case -ENOTSUPP:
+			abort_code = RX_INVALID_OPERATION;
+			rxrpc_kernel_abort_call(afs_socket, call->rxcall,
+						abort_code);
+			goto do_abort;
+		case -ENODATA:
+		case -EBADMSG:
+		case -EMSGSIZE:
+		default:
+			abort_code = RXGEN_CC_UNMARSHAL;
+			if (call->state != AFS_CALL_AWAIT_REPLY)
+				abort_code = RXGEN_SS_UNMARSHAL;
+			rxrpc_kernel_abort_call(afs_socket, call->rxcall,
+						abort_code);
+			goto do_abort;
+		}
 	}
 
+done:
+	if (call->state == AFS_CALL_COMPLETE && call->incoming)
+		afs_end_call(call);
+out:
 	_leave("");
+	return;
+
+do_abort:
+	call->error = ret;
+	call->state = AFS_CALL_COMPLETE;
+	goto done;
 }
 
 /*
@@ -574,7 +463,6 @@ static void afs_deliver_to_call(struct afs_call *call)
  */
 static int afs_wait_for_call_to_complete(struct afs_call *call)
 {
-	struct sk_buff *skb;
 	int ret;
 
 	DECLARE_WAITQUEUE(myself, current);
@@ -586,14 +474,15 @@ static int afs_wait_for_call_to_complete(struct afs_call *call)
 		set_current_state(TASK_INTERRUPTIBLE);
 
 		/* deliver any messages that are in the queue */
-		if (!skb_queue_empty(&call->rx_queue)) {
+		if (call->state < AFS_CALL_COMPLETE && call->need_attention) {
+			call->need_attention = false;
 			__set_current_state(TASK_RUNNING);
 			afs_deliver_to_call(call);
 			continue;
 		}
 
 		ret = call->error;
-		if (call->state >= AFS_CALL_COMPLETE)
+		if (call->state == AFS_CALL_COMPLETE)
 			break;
 		ret = -EINTR;
 		if (signal_pending(current))
@@ -607,9 +496,8 @@ static int afs_wait_for_call_to_complete(struct afs_call *call)
 	/* kill the call */
 	if (call->state < AFS_CALL_COMPLETE) {
 		_debug("call incomplete");
-		rxrpc_kernel_abort_call(afs_socket, call->rxcall, RX_CALL_DEAD);
-		while ((skb = skb_dequeue(&call->rx_queue)))
-			afs_free_skb(skb);
+		rxrpc_kernel_abort_call(afs_socket, call->rxcall,
+					RX_CALL_DEAD);
 	}
 
 	_debug("call complete");
@@ -621,17 +509,24 @@ static int afs_wait_for_call_to_complete(struct afs_call *call)
 /*
  * wake up a waiting call
  */
-static void afs_wake_up_call_waiter(struct afs_call *call)
+static void afs_wake_up_call_waiter(struct sock *sk, struct rxrpc_call *rxcall,
+				    unsigned long call_user_ID)
 {
+	struct afs_call *call = (struct afs_call *)call_user_ID;
+
+	call->need_attention = true;
 	wake_up(&call->waitq);
 }
 
 /*
  * wake up an asynchronous call
  */
-static void afs_wake_up_async_call(struct afs_call *call)
+static void afs_wake_up_async_call(struct sock *sk, struct rxrpc_call *rxcall,
+				   unsigned long call_user_ID)
 {
-	_enter("");
+	struct afs_call *call = (struct afs_call *)call_user_ID;
+
+	call->need_attention = true;
 	queue_work(afs_async_calls, &call->async_work);
 }
 
@@ -649,8 +544,10 @@ static int afs_dont_wait_for_call_to_complete(struct afs_call *call)
 /*
  * delete an asynchronous call
  */
-static void afs_delete_async_call(struct afs_call *call)
+static void afs_delete_async_call(struct work_struct *work)
 {
+	struct afs_call *call = container_of(work, struct afs_call, async_work);
+
 	_enter("");
 
 	afs_free_call(call);
@@ -660,17 +557,19 @@ static void afs_delete_async_call(struct afs_call *call)
 
 /*
  * perform processing on an asynchronous call
- * - on a multiple-thread workqueue this work item may try to run on several
- *   CPUs at the same time
  */
-static void afs_process_async_call(struct afs_call *call)
+static void afs_process_async_call(struct work_struct *work)
 {
+	struct afs_call *call = container_of(work, struct afs_call, async_work);
+
 	_enter("");
 
-	if (!skb_queue_empty(&call->rx_queue))
+	if (call->state < AFS_CALL_COMPLETE && call->need_attention) {
+		call->need_attention = false;
 		afs_deliver_to_call(call);
+	}
 
-	if (call->state >= AFS_CALL_COMPLETE && call->wait_mode) {
+	if (call->state == AFS_CALL_COMPLETE && call->wait_mode) {
 		if (call->wait_mode->async_complete)
 			call->wait_mode->async_complete(call->reply,
 							call->error);
@@ -681,7 +580,7 @@ static void afs_process_async_call(struct afs_call *call)
 
 		/* we can't just delete the call because the work item may be
 		 * queued */
-		call->async_workfn = afs_delete_async_call;
+		call->async_work.func = afs_delete_async_call;
 		queue_work(afs_async_calls, &call->async_work);
 	}
 
@@ -689,52 +588,16 @@ static void afs_process_async_call(struct afs_call *call)
 }
 
 /*
- * Empty a socket buffer into a flat reply buffer.
- */
-int afs_transfer_reply(struct afs_call *call, struct sk_buff *skb, bool last)
-{
-	size_t len = skb->len;
-
-	if (len > call->reply_max - call->reply_size) {
-		_leave(" = -EBADMSG [%zu > %u]",
-		       len, call->reply_max - call->reply_size);
-		return -EBADMSG;
-	}
-
-	if (len > 0) {
-		if (skb_copy_bits(skb, 0, call->buffer + call->reply_size,
-				  len) < 0)
-			BUG();
-		call->reply_size += len;
-	}
-
-	afs_data_consumed(call, skb);
-	if (!last)
-		return -EAGAIN;
-
-	if (call->reply_size != call->reply_max) {
-		_leave(" = -EBADMSG [%u != %u]",
-		       call->reply_size, call->reply_max);
-		return -EBADMSG;
-	}
-	return 0;
-}
-
-/*
  * accept the backlog of incoming calls
  */
 static void afs_collect_incoming_call(struct work_struct *work)
 {
 	struct rxrpc_call *rxcall;
 	struct afs_call *call = NULL;
-	struct sk_buff *skb;
-
-	while ((skb = skb_dequeue(&afs_incoming_calls))) {
-		_debug("new call");
 
-		/* don't need the notification */
-		afs_free_skb(skb);
+	_enter("");
 
+	do {
 		if (!call) {
 			call = kzalloc(sizeof(struct afs_call), GFP_KERNEL);
 			if (!call) {
@@ -742,12 +605,10 @@ static void afs_collect_incoming_call(struct work_struct *work)
 				return;
 			}
 
-			call->async_workfn = afs_process_async_call;
-			INIT_WORK(&call->async_work, afs_async_workfn);
+			INIT_WORK(&call->async_work, afs_process_async_call);
 			call->wait_mode = &afs_async_incoming_call;
 			call->type = &afs_RXCMxxxx;
 			init_waitqueue_head(&call->waitq);
-			skb_queue_head_init(&call->rx_queue);
 			call->state = AFS_CALL_AWAIT_OP_ID;
 
 			_debug("CALL %p{%s} [%d]",
@@ -757,46 +618,47 @@ static void afs_collect_incoming_call(struct work_struct *work)
 		}
 
 		rxcall = rxrpc_kernel_accept_call(afs_socket,
-						  (unsigned long) call);
+						  (unsigned long)call,
+						  afs_wake_up_async_call);
 		if (!IS_ERR(rxcall)) {
 			call->rxcall = rxcall;
+			call->need_attention = true;
+			queue_work(afs_async_calls, &call->async_work);
 			call = NULL;
 		}
-	}
+	} while (!call);
 
 	if (call)
 		afs_free_call(call);
 }
 
 /*
+ * Notification of an incoming call.
+ */
+static void afs_rx_new_call(struct sock *sk)
+{
+	queue_work(afs_wq, &afs_collect_incoming_call_work);
+}
+
+/*
  * Grab the operation ID from an incoming cache manager call.  The socket
  * buffer is discarded on error or if we don't yet have sufficient data.
  */
-static int afs_deliver_cm_op_id(struct afs_call *call, struct sk_buff *skb,
-				bool last)
+static int afs_deliver_cm_op_id(struct afs_call *call)
 {
-	size_t len = skb->len;
-	void *oibuf = (void *) &call->operation_ID;
+	int ret;
 
-	_enter("{%u},{%zu},%d", call->offset, len, last);
+	_enter("{%zu}", call->offset);
 
 	ASSERTCMP(call->offset, <, 4);
 
 	/* the operation ID forms the first four bytes of the request data */
-	len = min_t(size_t, len, 4 - call->offset);
-	if (skb_copy_bits(skb, 0, oibuf + call->offset, len) < 0)
-		BUG();
-	if (!pskb_pull(skb, len))
-		BUG();
-	call->offset += len;
-
-	if (call->offset < 4) {
-		afs_data_consumed(call, skb);
-		_leave(" = -EAGAIN");
-		return -EAGAIN;
-	}
+	ret = afs_extract_data(call, &call->operation_ID, 4, true);
+	if (ret < 0)
+		return ret;
 
 	call->state = AFS_CALL_AWAIT_REQUEST;
+	call->offset = 0;
 
 	/* ask the cache manager to route the call (it'll change the call type
 	 * if successful) */
@@ -805,7 +667,7 @@ static int afs_deliver_cm_op_id(struct afs_call *call, struct sk_buff *skb,
 
 	/* pass responsibility for the remainer of this message off to the
 	 * cache manager op */
-	return call->type->deliver(call, skb, last);
+	return call->type->deliver(call);
 }
 
 /*
@@ -881,25 +743,40 @@ void afs_send_simple_reply(struct afs_call *call, const void *buf, size_t len)
 /*
  * Extract a piece of data from the received data socket buffers.
  */
-int afs_extract_data(struct afs_call *call, struct sk_buff *skb,
-		     bool last, void *buf, size_t count)
+int afs_extract_data(struct afs_call *call, void *buf, size_t count,
+		     bool want_more)
 {
-	size_t len = skb->len;
+	int ret;
 
-	_enter("{%u},{%zu},%d,,%zu", call->offset, len, last, count);
+	_enter("{%s,%zu},,%zu,%d",
+	       call->type->name, call->offset, count, want_more);
 
-	ASSERTCMP(call->offset, <, count);
+	ASSERTCMP(call->offset, <=, count);
 
-	len = min_t(size_t, len, count - call->offset);
-	if (skb_copy_bits(skb, 0, buf + call->offset, len) < 0 ||
-	    !pskb_pull(skb, len))
-		BUG();
-	call->offset += len;
+	ret = rxrpc_kernel_recv_data(afs_socket, call->rxcall,
+				     buf, count, &call->offset,
+				     want_more, &call->abort_code);
+	if (ret == 0 || ret == -EAGAIN)
+		return ret;
 
-	if (call->offset < count) {
-		afs_data_consumed(call, skb);
-		_leave(" = -EAGAIN");
-		return -EAGAIN;
+	if (ret == 1) {
+		switch (call->state) {
+		case AFS_CALL_AWAIT_REPLY:
+			call->state = AFS_CALL_COMPLETE;
+			break;
+		case AFS_CALL_AWAIT_REQUEST:
+			call->state = AFS_CALL_REPLYING;
+			break;
+		default:
+			break;
+		}
+		return 0;
 	}
-	return 0;
+
+	if (ret == -ECONNABORTED)
+		call->error = call->type->abort_to_error(call->abort_code);
+	else
+		call->error = ret;
+	call->state = AFS_CALL_COMPLETE;
+	return ret;
 }
diff --git a/fs/afs/vlclient.c b/fs/afs/vlclient.c
index f94d1abdc3eb..94bcd97d22b8 100644
--- a/fs/afs/vlclient.c
+++ b/fs/afs/vlclient.c
@@ -58,17 +58,16 @@ static int afs_vl_abort_to_error(u32 abort_code)
 /*
  * deliver reply data to a VL.GetEntryByXXX call
  */
-static int afs_deliver_vl_get_entry_by_xxx(struct afs_call *call,
-					   struct sk_buff *skb, bool last)
+static int afs_deliver_vl_get_entry_by_xxx(struct afs_call *call)
 {
 	struct afs_cache_vlocation *entry;
 	__be32 *bp;
 	u32 tmp;
 	int loop, ret;
 
-	_enter(",,%u", last);
+	_enter("");
 
-	ret = afs_transfer_reply(call, skb, last);
+	ret = afs_transfer_reply(call);
 	if (ret < 0)
 		return ret;
 
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index f8d8079dc058..b4b6a3664dda 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -12,7 +12,6 @@
 #ifndef _NET_RXRPC_H
 #define _NET_RXRPC_H
 
-#include <linux/skbuff.h>
 #include <linux/rxrpc.h>
 
 struct key;
@@ -20,38 +19,26 @@ struct sock;
 struct socket;
 struct rxrpc_call;
 
-/*
- * the mark applied to socket buffers that may be intercepted
- */
-enum rxrpc_skb_mark {
-	RXRPC_SKB_MARK_DATA,		/* data message */
-	RXRPC_SKB_MARK_FINAL_ACK,	/* final ACK received message */
-	RXRPC_SKB_MARK_BUSY,		/* server busy message */
-	RXRPC_SKB_MARK_REMOTE_ABORT,	/* remote abort message */
-	RXRPC_SKB_MARK_LOCAL_ABORT,	/* local abort message */
-	RXRPC_SKB_MARK_NET_ERROR,	/* network error message */
-	RXRPC_SKB_MARK_LOCAL_ERROR,	/* local error message */
-	RXRPC_SKB_MARK_NEW_CALL,	/* local error message */
-};
+typedef void (*rxrpc_notify_rx_t)(struct sock *, struct rxrpc_call *,
+				  unsigned long);
+typedef void (*rxrpc_notify_new_call_t)(struct sock *);
 
-typedef void (*rxrpc_interceptor_t)(struct sock *, unsigned long,
-				    struct sk_buff *);
-void rxrpc_kernel_intercept_rx_messages(struct socket *, rxrpc_interceptor_t);
+void rxrpc_kernel_new_call_notification(struct socket *,
+					rxrpc_notify_new_call_t);
 struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *,
 					   struct sockaddr_rxrpc *,
 					   struct key *,
 					   unsigned long,
-					   gfp_t);
+					   gfp_t,
+					   rxrpc_notify_rx_t);
 int rxrpc_kernel_send_data(struct socket *, struct rxrpc_call *,
 			   struct msghdr *, size_t);
-void rxrpc_kernel_data_consumed(struct rxrpc_call *, struct sk_buff *);
+int rxrpc_kernel_recv_data(struct socket *, struct rxrpc_call *,
+			   void *, size_t, size_t *, bool, u32 *);
 void rxrpc_kernel_abort_call(struct socket *, struct rxrpc_call *, u32);
 void rxrpc_kernel_end_call(struct socket *, struct rxrpc_call *);
-bool rxrpc_kernel_is_data_last(struct sk_buff *);
-u32 rxrpc_kernel_get_abort_code(struct sk_buff *);
-int rxrpc_kernel_get_error_number(struct sk_buff *);
-void rxrpc_kernel_free_skb(struct sk_buff *);
-struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *, unsigned long);
+struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *, unsigned long,
+					    rxrpc_notify_rx_t);
 int rxrpc_kernel_reject_call(struct socket *);
 void rxrpc_kernel_get_peer(struct socket *, struct rxrpc_call *,
 			   struct sockaddr_rxrpc *);
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index e07c91acd904..32d544995dda 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -231,6 +231,8 @@ static int rxrpc_listen(struct socket *sock, int backlog)
  * @srx: The address of the peer to contact
  * @key: The security context to use (defaults to socket setting)
  * @user_call_ID: The ID to use
+ * @gfp: The allocation constraints
+ * @notify_rx: Where to send notifications instead of socket queue
  *
  * Allow a kernel service to begin a call on the nominated socket.  This just
  * sets up all the internal tracking structures and allocates connection and
@@ -243,7 +245,8 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 					   struct sockaddr_rxrpc *srx,
 					   struct key *key,
 					   unsigned long user_call_ID,
-					   gfp_t gfp)
+					   gfp_t gfp,
+					   rxrpc_notify_rx_t notify_rx)
 {
 	struct rxrpc_conn_parameters cp;
 	struct rxrpc_call *call;
@@ -270,6 +273,8 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 	cp.exclusive		= false;
 	cp.service_id		= srx->srx_service;
 	call = rxrpc_new_client_call(rx, &cp, srx, user_call_ID, gfp);
+	if (!IS_ERR(call))
+		call->notify_rx = notify_rx;
 
 	release_sock(&rx->sk);
 	_leave(" = %p", call);
@@ -289,31 +294,27 @@ void rxrpc_kernel_end_call(struct socket *sock, struct rxrpc_call *call)
 {
 	_enter("%d{%d}", call->debug_id, atomic_read(&call->usage));
 	rxrpc_remove_user_ID(rxrpc_sk(sock->sk), call);
+	rxrpc_purge_queue(&call->knlrecv_queue);
 	rxrpc_put_call(call);
 }
 EXPORT_SYMBOL(rxrpc_kernel_end_call);
 
 /**
- * rxrpc_kernel_intercept_rx_messages - Intercept received RxRPC messages
+ * rxrpc_kernel_new_call_notification - Get notifications of new calls
  * @sock: The socket to intercept received messages on
- * @interceptor: The function to pass the messages to
+ * @notify_new_call: Function to be called when new calls appear
  *
- * Allow a kernel service to intercept messages heading for the Rx queue on an
- * RxRPC socket.  They get passed to the specified function instead.
- * @interceptor should free the socket buffers it is given.  @interceptor is
- * called with the socket receive queue spinlock held and softirqs disabled -
- * this ensures that the messages will be delivered in the right order.
+ * Allow a kernel service to be given notifications about new calls.
  */
-void rxrpc_kernel_intercept_rx_messages(struct socket *sock,
-					rxrpc_interceptor_t interceptor)
+void rxrpc_kernel_new_call_notification(
+	struct socket *sock,
+	rxrpc_notify_new_call_t notify_new_call)
 {
 	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
 
-	_enter("");
-	rx->interceptor = interceptor;
+	rx->notify_new_call = notify_new_call;
 }
-
-EXPORT_SYMBOL(rxrpc_kernel_intercept_rx_messages);
+EXPORT_SYMBOL(rxrpc_kernel_new_call_notification);
 
 /*
  * connect an RxRPC socket
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 0c320b2b7b43..4e86d248dc5e 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -40,6 +40,20 @@ struct rxrpc_crypt {
 struct rxrpc_connection;
 
 /*
+ * Mark applied to socket buffers.
+ */
+enum rxrpc_skb_mark {
+	RXRPC_SKB_MARK_DATA,		/* data message */
+	RXRPC_SKB_MARK_FINAL_ACK,	/* final ACK received message */
+	RXRPC_SKB_MARK_BUSY,		/* server busy message */
+	RXRPC_SKB_MARK_REMOTE_ABORT,	/* remote abort message */
+	RXRPC_SKB_MARK_LOCAL_ABORT,	/* local abort message */
+	RXRPC_SKB_MARK_NET_ERROR,	/* network error message */
+	RXRPC_SKB_MARK_LOCAL_ERROR,	/* local error message */
+	RXRPC_SKB_MARK_NEW_CALL,	/* local error message */
+};
+
+/*
  * sk_state for RxRPC sockets
  */
 enum {
@@ -57,7 +71,7 @@ enum {
 struct rxrpc_sock {
 	/* WARNING: sk has to be the first member */
 	struct sock		sk;
-	rxrpc_interceptor_t	interceptor;	/* kernel service Rx interceptor function */
+	rxrpc_notify_new_call_t	notify_new_call; /* Func to notify of new call */
 	struct rxrpc_local	*local;		/* local endpoint */
 	struct list_head	listen_link;	/* link in the local endpoint's listen list */
 	struct list_head	secureq;	/* calls awaiting connection security clearance */
@@ -367,6 +381,7 @@ enum rxrpc_call_flag {
 	RXRPC_CALL_EXPECT_OOS,		/* expect out of sequence packets */
 	RXRPC_CALL_IS_SERVICE,		/* Call is service call */
 	RXRPC_CALL_EXPOSED,		/* The call was exposed to the world */
+	RXRPC_CALL_RX_NO_MORE,		/* Don't indicate MSG_MORE from recvmsg() */
 };
 
 /*
@@ -441,6 +456,7 @@ struct rxrpc_call {
 	struct timer_list	resend_timer;	/* Tx resend timer */
 	struct work_struct	destroyer;	/* call destroyer */
 	struct work_struct	processor;	/* packet processor and ACK generator */
+	rxrpc_notify_rx_t	notify_rx;	/* kernel service Rx notification function */
 	struct list_head	link;		/* link in master call list */
 	struct list_head	chan_wait_link;	/* Link in conn->waiting_calls */
 	struct hlist_node	error_link;	/* link in error distribution list */
@@ -448,6 +464,7 @@ struct rxrpc_call {
 	struct rb_node		sock_node;	/* node in socket call tree */
 	struct sk_buff_head	rx_queue;	/* received packets */
 	struct sk_buff_head	rx_oos_queue;	/* packets received out of sequence */
+	struct sk_buff_head	knlrecv_queue;	/* Queue for kernel_recv [TODO: replace this] */
 	struct sk_buff		*tx_pending;	/* Tx socket buffer being filled */
 	wait_queue_head_t	waitq;		/* Wait queue for channel or Tx */
 	__be32			crypto_buf[2];	/* Temporary packet crypto buffer */
@@ -512,7 +529,8 @@ extern struct workqueue_struct *rxrpc_workqueue;
  * call_accept.c
  */
 void rxrpc_accept_incoming_calls(struct rxrpc_local *);
-struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *, unsigned long);
+struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *, unsigned long,
+				     rxrpc_notify_rx_t);
 int rxrpc_reject_call(struct rxrpc_sock *);
 
 /*
@@ -874,6 +892,7 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *);
 /*
  * skbuff.c
  */
+void rxrpc_kernel_data_consumed(struct rxrpc_call *, struct sk_buff *);
 void rxrpc_packet_destructor(struct sk_buff *);
 void rxrpc_new_skb(struct sk_buff *);
 void rxrpc_see_skb(struct sk_buff *);
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 03af88fe798b..68a439e30df1 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -286,7 +286,8 @@ security_mismatch:
  * - assign the user call ID to the call at the front of the queue
  */
 struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
-				     unsigned long user_call_ID)
+				     unsigned long user_call_ID,
+				     rxrpc_notify_rx_t notify_rx)
 {
 	struct rxrpc_call *call;
 	struct rb_node *parent, **pp;
@@ -340,6 +341,7 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 	}
 
 	/* formalise the acceptance */
+	call->notify_rx = notify_rx;
 	call->user_call_ID = user_call_ID;
 	rb_link_node(&call->sock_node, parent, pp);
 	rb_insert_color(&call->sock_node, &rx->calls);
@@ -437,17 +439,20 @@ out:
  * rxrpc_kernel_accept_call - Allow a kernel service to accept an incoming call
  * @sock: The socket on which the impending call is waiting
  * @user_call_ID: The tag to attach to the call
+ * @notify_rx: Where to send notifications instead of socket queue
  *
  * Allow a kernel service to accept an incoming call, assuming the incoming
- * call is still valid.
+ * call is still valid.  The caller should immediately trigger their own
+ * notification as there must be data waiting.
  */
 struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *sock,
-					    unsigned long user_call_ID)
+					    unsigned long user_call_ID,
+					    rxrpc_notify_rx_t notify_rx)
 {
 	struct rxrpc_call *call;
 
 	_enter(",%lx", user_call_ID);
-	call = rxrpc_accept_call(rxrpc_sk(sock->sk), user_call_ID);
+	call = rxrpc_accept_call(rxrpc_sk(sock->sk), user_call_ID, notify_rx);
 	_leave(" = %p", call);
 	return call;
 }
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 104ee8b1de06..516d8ea82f02 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -136,6 +136,7 @@ static struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 	INIT_LIST_HEAD(&call->accept_link);
 	skb_queue_head_init(&call->rx_queue);
 	skb_queue_head_init(&call->rx_oos_queue);
+	skb_queue_head_init(&call->knlrecv_queue);
 	init_waitqueue_head(&call->waitq);
 	spin_lock_init(&call->lock);
 	rwlock_init(&call->state_lock);
@@ -552,8 +553,6 @@ void rxrpc_release_call(struct rxrpc_call *call)
 			spin_lock_bh(&call->lock);
 		}
 		spin_unlock_bh(&call->lock);
-
-		ASSERTCMP(call->state, !=, RXRPC_CALL_COMPLETE);
 	}
 
 	del_timer_sync(&call->resend_timer);
@@ -682,6 +681,7 @@ static void rxrpc_rcu_destroy_call(struct rcu_head *rcu)
 	struct rxrpc_call *call = container_of(rcu, struct rxrpc_call, rcu);
 
 	rxrpc_purge_queue(&call->rx_queue);
+	rxrpc_purge_queue(&call->knlrecv_queue);
 	rxrpc_put_peer(call->peer);
 	kmem_cache_free(rxrpc_call_jar, call);
 }
@@ -737,6 +737,7 @@ static void rxrpc_cleanup_call(struct rxrpc_call *call)
 
 	rxrpc_purge_queue(&call->rx_queue);
 	ASSERT(skb_queue_empty(&call->rx_oos_queue));
+	rxrpc_purge_queue(&call->knlrecv_queue);
 	sock_put(&call->socket->sk);
 	call_rcu(&call->rcu, rxrpc_rcu_destroy_call);
 }
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index bc9b05938ff5..9db90f4f768d 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -282,7 +282,6 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 	case RXRPC_PACKET_TYPE_DATA:
 	case RXRPC_PACKET_TYPE_ACK:
 		rxrpc_conn_retransmit_call(conn, skb);
-		rxrpc_free_skb(skb);
 		return 0;
 
 	case RXRPC_PACKET_TYPE_ABORT:
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 86bea9ad6c3d..72f016cfaaf5 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -90,9 +90,15 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 		}
 
 		/* allow interception by a kernel service */
-		if (rx->interceptor) {
-			rx->interceptor(sk, call->user_call_ID, skb);
+		if (skb->mark == RXRPC_SKB_MARK_NEW_CALL &&
+		    rx->notify_new_call) {
 			spin_unlock_bh(&sk->sk_receive_queue.lock);
+			skb_queue_tail(&call->knlrecv_queue, skb);
+			rx->notify_new_call(&rx->sk);
+		} else if (call->notify_rx) {
+			spin_unlock_bh(&sk->sk_receive_queue.lock);
+			skb_queue_tail(&call->knlrecv_queue, skb);
+			call->notify_rx(&rx->sk, call, call->user_call_ID);
 		} else {
 			_net("post skb %p", skb);
 			__skb_queue_tail(&sk->sk_receive_queue, skb);
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index b1e708a12151..817ae801e769 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -190,7 +190,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 	if (cmd == RXRPC_CMD_ACCEPT) {
 		if (rx->sk.sk_state != RXRPC_SERVER_LISTENING)
 			return -EINVAL;
-		call = rxrpc_accept_call(rx, user_call_ID);
+		call = rxrpc_accept_call(rx, user_call_ID, NULL);
 		if (IS_ERR(call))
 			return PTR_ERR(call);
 		rxrpc_put_call(call);
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index c9b38c7fb448..9acbf22da5f2 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -369,55 +369,182 @@ wait_error:
 
 }
 
-/**
- * rxrpc_kernel_is_data_last - Determine if data message is last one
- * @skb: Message holding data
+/*
+ * Deliver messages to a call.  This keeps processing packets until the buffer
+ * is filled and we find either more DATA (returns 0) or the end of the DATA
+ * (returns 1).  If more packets are required, it returns -EAGAIN.
  *
- * Determine if data message is last one for the parent call.
+ * TODO: Note that this is hacked in at the moment and will be replaced.
  */
-bool rxrpc_kernel_is_data_last(struct sk_buff *skb)
+static int temp_deliver_data(struct socket *sock, struct rxrpc_call *call,
+			     struct iov_iter *iter, size_t size,
+			     size_t *_offset)
 {
-	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	struct rxrpc_skb_priv *sp;
+	struct sk_buff *skb;
+	size_t remain;
+	int ret, copy;
+
+	_enter("%d", call->debug_id);
+
+next:
+	local_bh_disable();
+	skb = skb_dequeue(&call->knlrecv_queue);
+	local_bh_enable();
+	if (!skb) {
+		if (test_bit(RXRPC_CALL_RX_NO_MORE, &call->flags))
+			return 1;
+		_leave(" = -EAGAIN [empty]");
+		return -EAGAIN;
+	}
 
-	ASSERTCMP(skb->mark, ==, RXRPC_SKB_MARK_DATA);
+	sp = rxrpc_skb(skb);
+	_debug("dequeued %p %u/%zu", skb, sp->offset, size);
 
-	return sp->hdr.flags & RXRPC_LAST_PACKET;
-}
+	switch (skb->mark) {
+	case RXRPC_SKB_MARK_DATA:
+		remain = size - *_offset;
+		if (remain > 0) {
+			copy = skb->len - sp->offset;
+			if (copy > remain)
+				copy = remain;
+			ret = skb_copy_datagram_iter(skb, sp->offset, iter,
+						     copy);
+			if (ret < 0)
+				goto requeue_and_leave;
 
-EXPORT_SYMBOL(rxrpc_kernel_is_data_last);
+			/* handle piecemeal consumption of data packets */
+			sp->offset += copy;
+			*_offset += copy;
+		}
 
-/**
- * rxrpc_kernel_get_abort_code - Get the abort code from an RxRPC abort message
- * @skb: Message indicating an abort
- *
- * Get the abort code from an RxRPC abort message.
- */
-u32 rxrpc_kernel_get_abort_code(struct sk_buff *skb)
-{
-	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+		if (sp->offset < skb->len)
+			goto partially_used_skb;
+
+		/* We consumed the whole packet */
+		ASSERTCMP(sp->offset, ==, skb->len);
+		if (sp->hdr.flags & RXRPC_LAST_PACKET)
+			set_bit(RXRPC_CALL_RX_NO_MORE, &call->flags);
+		rxrpc_kernel_data_consumed(call, skb);
+		rxrpc_free_skb(skb);
+		goto next;
 
-	switch (skb->mark) {
-	case RXRPC_SKB_MARK_REMOTE_ABORT:
-	case RXRPC_SKB_MARK_LOCAL_ABORT:
-		return sp->call->abort_code;
 	default:
-		BUG();
+		rxrpc_free_skb(skb);
+		goto next;
 	}
-}
 
-EXPORT_SYMBOL(rxrpc_kernel_get_abort_code);
+partially_used_skb:
+	ASSERTCMP(*_offset, ==, size);
+	ret = 0;
+requeue_and_leave:
+	skb_queue_head(&call->knlrecv_queue, skb);
+	return ret;
+}
 
 /**
- * rxrpc_kernel_get_error - Get the error number from an RxRPC error message
- * @skb: Message indicating an error
+ * rxrpc_kernel_recv_data - Allow a kernel service to receive data/info
+ * @sock: The socket that the call exists on
+ * @call: The call to send data through
+ * @buf: The buffer to receive into
+ * @size: The size of the buffer, including data already read
+ * @_offset: The running offset into the buffer.
+ * @want_more: True if more data is expected to be read
+ * @_abort: Where the abort code is stored if -ECONNABORTED is returned
+ *
+ * Allow a kernel service to receive data and pick up information about the
+ * state of a call.  Returns 0 if got what was asked for and there's more
+ * available, 1 if we got what was asked for and we're at the end of the data
+ * and -EAGAIN if we need more data.
+ *
+ * Note that we may return -EAGAIN to drain empty packets at the end of the
+ * data, even if we've already copied over the requested data.
  *
- * Get the error number from an RxRPC error message.
+ * This function adds the amount it transfers to *_offset, so this should be
+ * precleared as appropriate.  Note that the amount remaining in the buffer is
+ * taken to be size - *_offset.
+ *
+ * *_abort should also be initialised to 0.
  */
-int rxrpc_kernel_get_error_number(struct sk_buff *skb)
+int rxrpc_kernel_recv_data(struct socket *sock, struct rxrpc_call *call,
+			   void *buf, size_t size, size_t *_offset,
+			   bool want_more, u32 *_abort)
 {
-	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	struct iov_iter iter;
+	struct kvec iov;
+	bool no_more;
+	int ret;
 
-	return sp->error;
-}
+	_enter("{%d,%s},%zu,%d",
+	       call->debug_id, rxrpc_call_states[call->state], size, want_more);
+
+	ASSERTCMP(*_offset, <=, size);
+	ASSERTCMP(call->state, !=, RXRPC_CALL_SERVER_ACCEPTING);
 
-EXPORT_SYMBOL(rxrpc_kernel_get_error_number);
+	iov.iov_base = buf + *_offset;
+	iov.iov_len = size - *_offset;
+	iov_iter_kvec(&iter, ITER_KVEC | READ, &iov, 1, size - *_offset);
+
+	lock_sock(sock->sk);
+
+	switch (call->state) {
+	case RXRPC_CALL_CLIENT_RECV_REPLY:
+	case RXRPC_CALL_SERVER_RECV_REQUEST:
+	case RXRPC_CALL_SERVER_ACK_REQUEST:
+		ret = temp_deliver_data(sock, call, &iter, size, _offset);
+		if (ret < 0)
+			goto out;
+
+		/* We can only reach here with a partially full buffer if we
+		 * have reached the end of the data.  We must otherwise have a
+		 * full buffer or have been given -EAGAIN.
+		 */
+		if (ret == 1) {
+			if (*_offset < size)
+				goto short_data;
+			if (!want_more)
+				goto read_phase_complete;
+			ret = 0;
+			goto out;
+		}
+
+		if (!want_more)
+			goto excess_data;
+		goto out;
+
+	case RXRPC_CALL_COMPLETE:
+		goto call_complete;
+
+	default:
+		*_offset = 0;
+		ret = -EINPROGRESS;
+		goto out;
+	}
+
+read_phase_complete:
+	ret = 1;
+out:
+	release_sock(sock->sk);
+	_leave(" = %d [%zu,%d]", ret, *_offset, *_abort);
+	return ret;
+
+need_more_data:
+	ret = -EAGAIN;
+	goto out;
+short_data:
+	ret = -EBADMSG;
+	goto out;
+excess_data:
+	ret = -EMSGSIZE;
+	goto out;
+call_complete:
+	*_abort = call->abort_code;
+	ret = call->error;
+	if (call->completion == RXRPC_CALL_SUCCEEDED) {
+		ret = 1;
+		if (size > 0)
+			ret = -ECONNRESET;
+	}
+	goto out;
+}
+EXPORT_SYMBOL(rxrpc_kernel_recv_data);
diff --git a/net/rxrpc/skbuff.c b/net/rxrpc/skbuff.c
index 20529205bb8c..9752f8b1fdd0 100644
--- a/net/rxrpc/skbuff.c
+++ b/net/rxrpc/skbuff.c
@@ -127,7 +127,6 @@ void rxrpc_kernel_data_consumed(struct rxrpc_call *call, struct sk_buff *skb)
 	call->rx_data_recv = sp->hdr.seq;
 	rxrpc_hard_ACK_data(call, skb);
 }
-EXPORT_SYMBOL(rxrpc_kernel_data_consumed);
 
 /*
  * Destroy a packet that has an RxRPC control buffer
