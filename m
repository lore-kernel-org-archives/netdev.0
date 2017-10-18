From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/3] rxrpc: Support service upgrade from a kernel
 service
Date: Wed, 18 Oct 2017 12:55:56 +0100
Message-ID: <150832775686.7695.6694404160450084063.stgit@warthog.procyon.org.uk>
References: <150832775000.7695.7720685597577836060.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150832775000.7695.7720685597577836060.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Provide support for a kernel service to make use of the service upgrade
facility.  This involves:

 (1) Pass an upgrade request flag to rxrpc_kernel_begin_call().

 (2) Make rxrpc_kernel_recv_data() return the call's current service ID so
     that the caller can detect service upgrade and see what the service
     was upgraded to.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |   17 +++++++++++++++--
 fs/afs/internal.h                  |    1 +
 fs/afs/rxrpc.c                     |   11 +++++++----
 include/net/af_rxrpc.h             |    5 +++--
 net/rxrpc/af_rxrpc.c               |    5 ++++-
 net/rxrpc/recvmsg.c                |    5 ++++-
 6 files changed, 34 insertions(+), 10 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index 810620153a44..9fb61a6bc7cf 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -782,7 +782,9 @@ The kernel interface functions are as follows:
 				struct key *key,
 				unsigned long user_call_ID,
 				s64 tx_total_len,
-				gfp_t gfp);
+				gfp_t gfp,
+				rxrpc_notify_rx_t notify_rx,
+				bool upgrade);
 
      This allocates the infrastructure to make a new RxRPC call and assigns
      call and connection numbers.  The call will be made on the UDP port that
@@ -803,6 +805,13 @@ The kernel interface functions are as follows:
      allows the kernel to encrypt directly to the packet buffers, thereby
      saving a copy.  The value may not be less than -1.
 
+     notify_rx is a pointer to a function to be called when events such as
+     incoming data packets or remote aborts happen.
+
+     upgrade should be set to true if a client operation should request that
+     the server upgrade the service to a better one.  The resultant service ID
+     is returned by rxrpc_kernel_recv_data().
+
      If this function is successful, an opaque reference to the RxRPC call is
      returned.  The caller now holds a reference on this and it must be
      properly ended.
@@ -850,7 +859,8 @@ The kernel interface functions are as follows:
 				   size_t size,
 				   size_t *_offset,
 				   bool want_more,
-				   u32 *_abort)
+				   u32 *_abort,
+				   u16 *_service)
 
       This is used to receive data from either the reply part of a client call
       or the request part of a service call.  buf and size specify how much
@@ -873,6 +883,9 @@ The kernel interface functions are as follows:
       If a remote ABORT is detected, the abort code received will be stored in
       *_abort and ECONNABORTED will be returned.
 
+      The service ID that the call ended up with is returned into *_service.
+      This can be used to see if a call got a service upgrade.
+
  (*) Abort a call.
 
 	void rxrpc_kernel_abort_call(struct socket *sock,
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 82e16556afea..3f03f7888302 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -100,6 +100,7 @@ struct afs_call {
 	bool			send_pages;	/* T if data from mapping should be sent */
 	bool			need_attention;	/* T if RxRPC poked us */
 	bool			async;		/* T if asynchronous */
+	bool			upgrade;	/* T to request service upgrade */
 	u16			service_id;	/* RxRPC service ID to call */
 	__be16			port;		/* target UDP port */
 	u32			operation_ID;	/* operation ID for an incoming call */
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 0bf191f0dbaf..172a4f9747ac 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -387,7 +387,8 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 					 tx_total_len, gfp,
 					 (async ?
 					  afs_wake_up_async_call :
-					  afs_wake_up_call_waiter));
+					  afs_wake_up_call_waiter),
+					 call->upgrade);
 	call->key = NULL;
 	if (IS_ERR(rxcall)) {
 		ret = PTR_ERR(rxcall);
@@ -443,7 +444,7 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 		abort_code = 0;
 		offset = 0;
 		rxrpc_kernel_recv_data(afs_socket, rxcall, NULL, 0, &offset,
-				       false, &abort_code);
+				       false, &abort_code, &call->service_id);
 		ret = call->type->abort_to_error(abort_code);
 	}
 error_kill_call:
@@ -471,7 +472,8 @@ static void afs_deliver_to_call(struct afs_call *call)
 			size_t offset = 0;
 			ret = rxrpc_kernel_recv_data(afs_socket, call->rxcall,
 						     NULL, 0, &offset, false,
-						     &call->abort_code);
+						     &call->abort_code,
+						     &call->service_id);
 			trace_afs_recv_data(call, 0, offset, false, ret);
 
 			if (ret == -EINPROGRESS || ret == -EAGAIN)
@@ -851,7 +853,8 @@ int afs_extract_data(struct afs_call *call, void *buf, size_t count,
 
 	ret = rxrpc_kernel_recv_data(afs_socket, call->rxcall,
 				     buf, count, &call->offset,
-				     want_more, &call->abort_code);
+				     want_more, &call->abort_code,
+				     &call->service_id);
 	trace_afs_recv_data(call, count, call->offset, want_more, ret);
 	if (ret == 0 || ret == -EAGAIN)
 		return ret;
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index 3ac79150291f..820dd365a08e 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -49,12 +49,13 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *,
 					   unsigned long,
 					   s64,
 					   gfp_t,
-					   rxrpc_notify_rx_t);
+					   rxrpc_notify_rx_t,
+					   bool);
 int rxrpc_kernel_send_data(struct socket *, struct rxrpc_call *,
 			   struct msghdr *, size_t,
 			   rxrpc_notify_end_tx_t);
 int rxrpc_kernel_recv_data(struct socket *, struct rxrpc_call *,
-			   void *, size_t, size_t *, bool, u32 *);
+			   void *, size_t, size_t *, bool, u32 *, u16 *);
 bool rxrpc_kernel_abort_call(struct socket *, struct rxrpc_call *,
 			     u32, int, const char *);
 void rxrpc_kernel_end_call(struct socket *, struct rxrpc_call *);
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index fb17552fd292..481f7dc90ba2 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -265,6 +265,7 @@ static int rxrpc_listen(struct socket *sock, int backlog)
  * @tx_total_len: Total length of data to transmit during the call (or -1)
  * @gfp: The allocation constraints
  * @notify_rx: Where to send notifications instead of socket queue
+ * @upgrade: Request service upgrade for call
  *
  * Allow a kernel service to begin a call on the nominated socket.  This just
  * sets up all the internal tracking structures and allocates connection and
@@ -279,7 +280,8 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 					   unsigned long user_call_ID,
 					   s64 tx_total_len,
 					   gfp_t gfp,
-					   rxrpc_notify_rx_t notify_rx)
+					   rxrpc_notify_rx_t notify_rx,
+					   bool upgrade)
 {
 	struct rxrpc_conn_parameters cp;
 	struct rxrpc_call *call;
@@ -304,6 +306,7 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 	cp.key			= key;
 	cp.security_level	= 0;
 	cp.exclusive		= false;
+	cp.upgrade		= upgrade;
 	cp.service_id		= srx->srx_service;
 	call = rxrpc_new_client_call(rx, &cp, srx, user_call_ID, tx_total_len,
 				     gfp);
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index bdece21f313d..e4937b3f3685 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -607,6 +607,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
  * @_offset: The running offset into the buffer.
  * @want_more: True if more data is expected to be read
  * @_abort: Where the abort code is stored if -ECONNABORTED is returned
+ * @_service: Where to store the actual service ID (may be upgraded)
  *
  * Allow a kernel service to receive data and pick up information about the
  * state of a call.  Returns 0 if got what was asked for and there's more
@@ -624,7 +625,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
  */
 int rxrpc_kernel_recv_data(struct socket *sock, struct rxrpc_call *call,
 			   void *buf, size_t size, size_t *_offset,
-			   bool want_more, u32 *_abort)
+			   bool want_more, u32 *_abort, u16 *_service)
 {
 	struct iov_iter iter;
 	struct kvec iov;
@@ -680,6 +681,8 @@ int rxrpc_kernel_recv_data(struct socket *sock, struct rxrpc_call *call,
 read_phase_complete:
 	ret = 1;
 out:
+	if (_service)
+		*_service = call->service_id;
 	mutex_unlock(&call->user_mutex);
 	_leave(" = %d [%zu,%d]", ret, *_offset, *_abort);
 	return ret;
