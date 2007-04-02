From: David Howells <dhowells@redhat.com>
Subject: [PATCH 7/9] AF_RXRPC: Add an interface to the AF_RXRPC module for the
	AFS filesystem to use
Date: Mon, 02 Apr 2007 23:45:29 +0100
Message-ID: <20070402224529.31568.79990.stgit@warthog.cambridge.redhat.com>
References: <20070402224449.31568.17833.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070402224449.31568.17833.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add an interface to the AF_RXRPC module so that the AFS filesystem module can
more easily make use of the services available.  AFS still opens a socket but
then uses the action functions in lieu of sendmsg() and registers an intercept
functions to grab messages before they're queued on the socket Rx queue.

This permits AFS (or whatever) to:

 (1) Avoid the overhead of using the recvmsg() call.

 (2) Use different keys directly on individual client calls on one socket
     rather than having to open a whole slew of sockets, one for each key it
     might want to use.

 (3) Avoid calling request_key() at the point of issue of a call or opening of
     a socket.  This is done instead by AFS at the point of open(), unlink() or
     other VFS operation and the key handed through.

 (4) Request the use of something other than GFP_KERNEL to allocate memory.

Furthermore:

 (*) The socket buffer markings used by RxRPC are made available for AFS so
     that it can interpret the cooked RxRPC messages itself.

 (*) rxgen (un)marshalling abort codes are made available.


The following documentation for the kernel interface is added to
Documentation/networking/rxrpc.txt:

=========================
AF_RXRPC KERNEL INTERFACE
=========================

The AF_RXRPC module also provides an interface for use by in-kernel utilities
such as the AFS filesystem.  This permits such a utility to:

 (1) Use different keys directly on individual client calls on one socket
     rather than having to open a whole slew of sockets, one for each key it
     might want to use.

 (2) Avoid having RxRPC call request_key() at the point of issue of a call or
     opening of a socket.  Instead the utility is responsible for requesting a
     key at the appropriate point.  AFS, for instance, would do this during VFS
     operations such as open() or unlink().  The key is then handed through
     when the call is initiated.

 (3) Request the use of something other than GFP_KERNEL to allocate memory.

 (4) Avoid the overhead of using the recvmsg() call.  RxRPC messages can be
     intercepted before they get put into the socket Rx queue and the socket
     buffers manipulated directly.

To use the RxRPC facility, a kernel utility must still open an AF_RXRPC socket,
bind an addess as appropriate and listen if it's to be a server socket, but
then it passes this to the kernel interface functions.

The kernel interface functions are as follows:

 (*) Begin a new client call.

	struct rxrpc_call *
	rxrpc_kernel_begin_call(struct socket *sock,
				struct sockaddr_rxrpc *srx,
				struct key *key,
				unsigned long user_call_ID,
				gfp_t gfp);

     This allocates the infrastructure to make a new RxRPC call and assigns
     call and connection numbers.  The call will be made on the UDP port that
     the socket is bound to.  The call will go to the destination address of a
     connected client socket unless an alternative is supplied (srx is
     non-NULL).

     If a key is supplied then this will be used to secure the call instead of
     the key bound to the socket with the RXRPC_SECURITY_KEY sockopt.  Calls
     secured in this way will still share connections if at all possible.

     The user_call_ID is equivalent to that supplied to sendmsg() in the
     control data buffer.  It is entirely feasible to use this to point to a
     kernel data structure.

     If this function is successful, an opaque reference to the RxRPC call is
     returned.  The caller now holds a reference on this and it must be
     properly ended.

 (*) End a client call.

	void rxrpc_kernel_end_call(struct rxrpc_call *call);

     This is used to end a previously begun call.  The user_call_ID is expunged
     from AF_RXRPC's knowledge and will not be seen again in association with
     the specified call.

 (*) Send data through a call.

	int rxrpc_kernel_send_data(struct rxrpc_call *call, struct msghdr *msg,
				   size_t len);

     This is used to supply either the request part of a client call or the
     reply part of a server call.  msg.msg_iovlen and msg.msg_iov specify the
     data buffers to be used.  msg_iov may not be NULL and must point
     exclusively to in-kernel virtual addresses.  msg.msg_flags may be given
     MSG_MORE if there will be subsequent data sends for this call.

     The msg must not specify a destination address, control data or any flags
     other than MSG_MORE.  len is the total amount of data to transmit.

 (*) Abort a call.

	void rxrpc_kernel_abort_call(struct rxrpc_call *call, u32 abort_code);

     This is used to abort a call if it's still in an abortable state.  The
     abort code specified will be placed in the ABORT message sent.

 (*) Intercept received RxRPC messages.

	typedef void (*rxrpc_interceptor_t)(struct sock *sk,
					    unsigned long user_call_ID,
					    struct sk_buff *skb);

	void
	rxrpc_kernel_intercept_rx_messages(struct socket *sock,
					   rxrpc_interceptor_t interceptor);

     This installs an interceptor function on the specified AF_RXRPC socket.
     All messages that would otherwise wind up in the socket's Rx queue are
     then diverted to this function.  Note that care must be taken to process
     the messages in the right order to maintain DATA message sequentiality.

     The interceptor function itself is provided with the address of the socket
     and handling the incoming message, the ID assigned by the kernel utility
     to the call and the socket buffer containing the message.

     The skb->mark field indicates the type of message:

	MARK				MEANING
	===============================	=======================================
	RXRPC_SKB_MARK_DATA		Data message
	RXRPC_SKB_MARK_FINAL_ACK	Final ACK received for an incoming call
	RXRPC_SKB_MARK_BUSY		Client call rejected as server busy
	RXRPC_SKB_MARK_REMOTE_ABORT	Call aborted by peer
	RXRPC_SKB_MARK_NET_ERROR	Network error detected
	RXRPC_SKB_MARK_LOCAL_ERROR	Local error encountered
	RXRPC_SKB_MARK_NEW_CALL		New incoming call awaiting acceptance

     The remote abort message can be probed with rxrpc_kernel_get_abort_code().
     The two error messages can be probed with rxrpc_kernel_get_error_number().
     A new call can be accepted with rxrpc_kernel_accept_call().

     Data messages can have their contents extracted with the usual bunch of
     socket buffer manipulation functions.  A data message can be determined to
     be the last one in a sequence with rxrpc_kernel_is_data_last().  When a
     data message has been used up, rxrpc_kernel_data_delivered() should be
     called on it..

     Non-data messages should be handled to rxrpc_kernel_free_skb() to dispose
     of.  It is possible to get extra refs on all types of message for later
     freeing, but this may pin the state of a call until the message is finally
     freed.

 (*) Accept an incoming call.

	struct rxrpc_call *
	rxrpc_kernel_accept_call(struct socket *sock,
				 unsigned long user_call_ID);

     This is used to accept an incoming call and to assign it a call ID.  This
     function is similar to rxrpc_kernel_begin_call() and calls accepted must
     be ended in the same way.

     If this function is successful, an opaque reference to the RxRPC call is
     returned.  The caller now holds a reference on this and it must be
     properly ended.

 (*) Reject an incoming call.

	int rxrpc_kernel_reject_call(struct socket *sock);

     This is used to reject the first incoming call on the socket's queue with
     a BUSY message.  -ENODATA is returned if there were no incoming calls.
     Other errors may be returned if the call had been aborted (-ECONNABORTED)
     or had timed out (-ETIME).

 (*) Record the delivery of a data message and free it.

	void rxrpc_kernel_data_delivered(struct sk_buff *skb);

     This is used to record a data message as having been delivered and to
     update the ACK state for the call.  The socket buffer will be freed.

 (*) Free a message.

	void rxrpc_kernel_free_skb(struct sk_buff *skb);

     This is used to free a non-DATA socket buffer intercepted from an AF_RXRPC
     socket.

 (*) Determine if a data message is the last one on a call.

	bool rxrpc_kernel_is_data_last(struct sk_buff *skb);

     This is used to determine if a socket buffer holds the last data message
     to be received for a call (true will be returned if it does, false
     if not).

     The data message will be part of the reply on a client call and the
     request on an incoming call.  In the latter case there will be more
     messages, but in the former case there will not.

 (*) Get the abort code from an abort message.

	u32 rxrpc_kernel_get_abort_code(struct sk_buff *skb);

     This is used to extract the abort code from a remote abort message.

 (*) Get the error number from a local or network error message.

	int rxrpc_kernel_get_error_number(struct sk_buff *skb);

     This is used to extract the error number from a message indicating either
     a local error occurred or a network error occurred.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |  196 ++++++++++++++++++++++++++++++++++++
 include/net/af_rxrpc.h             |   44 ++++++++
 include/rxrpc/packet.h             |   12 ++
 net/rxrpc/af_rxrpc.c               |  122 +++++++++++++++++++++-
 net/rxrpc/ar-accept.c              |  111 ++++++++++++++++++++
 net/rxrpc/ar-connection.c          |   24 +++-
 net/rxrpc/ar-input.c               |   36 ++++---
 net/rxrpc/ar-internal.h            |   17 +--
 net/rxrpc/ar-output.c              |   83 +++++++++++++++
 net/rxrpc/ar-recvmsg.c             |   73 +++++++++++++
 net/rxrpc/ar-skbuff.c              |   14 +++
 11 files changed, 682 insertions(+), 50 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index 146a73e..21ea5fa 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -25,6 +25,8 @@ Contents of this document:
 
  (*) Example server usage.
 
+ (*) AF_RXRPC kernel interface.
+
 
 ========
 OVERVIEW
@@ -661,3 +663,197 @@ A server would be set up to accept operations in the following manner:
 Note that all the communications for a particular service take place through
 the one server socket, using control messages on sendmsg() and recvmsg() to
 determine the call affected.
+
+
+=========================
+AF_RXRPC KERNEL INTERFACE
+=========================
+
+The AF_RXRPC module also provides an interface for use by in-kernel utilities
+such as the AFS filesystem.  This permits such a utility to:
+
+ (1) Use different keys directly on individual client calls on one socket
+     rather than having to open a whole slew of sockets, one for each key it
+     might want to use.
+
+ (2) Avoid having RxRPC call request_key() at the point of issue of a call or
+     opening of a socket.  Instead the utility is responsible for requesting a
+     key at the appropriate point.  AFS, for instance, would do this during VFS
+     operations such as open() or unlink().  The key is then handed through
+     when the call is initiated.
+
+ (3) Request the use of something other than GFP_KERNEL to allocate memory.
+
+ (4) Avoid the overhead of using the recvmsg() call.  RxRPC messages can be
+     intercepted before they get put into the socket Rx queue and the socket
+     buffers manipulated directly.
+
+To use the RxRPC facility, a kernel utility must still open an AF_RXRPC socket,
+bind an addess as appropriate and listen if it's to be a server socket, but
+then it passes this to the kernel interface functions.
+
+The kernel interface functions are as follows:
+
+ (*) Begin a new client call.
+
+	struct rxrpc_call *
+	rxrpc_kernel_begin_call(struct socket *sock,
+				struct sockaddr_rxrpc *srx,
+				struct key *key,
+				unsigned long user_call_ID,
+				gfp_t gfp);
+
+     This allocates the infrastructure to make a new RxRPC call and assigns
+     call and connection numbers.  The call will be made on the UDP port that
+     the socket is bound to.  The call will go to the destination address of a
+     connected client socket unless an alternative is supplied (srx is
+     non-NULL).
+
+     If a key is supplied then this will be used to secure the call instead of
+     the key bound to the socket with the RXRPC_SECURITY_KEY sockopt.  Calls
+     secured in this way will still share connections if at all possible.
+
+     The user_call_ID is equivalent to that supplied to sendmsg() in the
+     control data buffer.  It is entirely feasible to use this to point to a
+     kernel data structure.
+
+     If this function is successful, an opaque reference to the RxRPC call is
+     returned.  The caller now holds a reference on this and it must be
+     properly ended.
+
+ (*) End a client call.
+
+	void rxrpc_kernel_end_call(struct rxrpc_call *call);
+
+     This is used to end a previously begun call.  The user_call_ID is expunged
+     from AF_RXRPC's knowledge and will not be seen again in association with
+     the specified call.
+
+ (*) Send data through a call.
+
+	int rxrpc_kernel_send_data(struct rxrpc_call *call, struct msghdr *msg,
+				   size_t len);
+
+     This is used to supply either the request part of a client call or the
+     reply part of a server call.  msg.msg_iovlen and msg.msg_iov specify the
+     data buffers to be used.  msg_iov may not be NULL and must point
+     exclusively to in-kernel virtual addresses.  msg.msg_flags may be given
+     MSG_MORE if there will be subsequent data sends for this call.
+
+     The msg must not specify a destination address, control data or any flags
+     other than MSG_MORE.  len is the total amount of data to transmit.
+
+ (*) Abort a call.
+
+	void rxrpc_kernel_abort_call(struct rxrpc_call *call, u32 abort_code);
+
+     This is used to abort a call if it's still in an abortable state.  The
+     abort code specified will be placed in the ABORT message sent.
+
+ (*) Intercept received RxRPC messages.
+
+	typedef void (*rxrpc_interceptor_t)(struct sock *sk,
+					    unsigned long user_call_ID,
+					    struct sk_buff *skb);
+
+	void
+	rxrpc_kernel_intercept_rx_messages(struct socket *sock,
+					   rxrpc_interceptor_t interceptor);
+
+     This installs an interceptor function on the specified AF_RXRPC socket.
+     All messages that would otherwise wind up in the socket's Rx queue are
+     then diverted to this function.  Note that care must be taken to process
+     the messages in the right order to maintain DATA message sequentiality.
+
+     The interceptor function itself is provided with the address of the socket
+     and handling the incoming message, the ID assigned by the kernel utility
+     to the call and the socket buffer containing the message.
+
+     The skb->mark field indicates the type of message:
+
+	MARK				MEANING
+	===============================	=======================================
+	RXRPC_SKB_MARK_DATA		Data message
+	RXRPC_SKB_MARK_FINAL_ACK	Final ACK received for an incoming call
+	RXRPC_SKB_MARK_BUSY		Client call rejected as server busy
+	RXRPC_SKB_MARK_REMOTE_ABORT	Call aborted by peer
+	RXRPC_SKB_MARK_NET_ERROR	Network error detected
+	RXRPC_SKB_MARK_LOCAL_ERROR	Local error encountered
+	RXRPC_SKB_MARK_NEW_CALL		New incoming call awaiting acceptance
+
+     The remote abort message can be probed with rxrpc_kernel_get_abort_code().
+     The two error messages can be probed with rxrpc_kernel_get_error_number().
+     A new call can be accepted with rxrpc_kernel_accept_call().
+
+     Data messages can have their contents extracted with the usual bunch of
+     socket buffer manipulation functions.  A data message can be determined to
+     be the last one in a sequence with rxrpc_kernel_is_data_last().  When a
+     data message has been used up, rxrpc_kernel_data_delivered() should be
+     called on it..
+
+     Non-data messages should be handled to rxrpc_kernel_free_skb() to dispose
+     of.  It is possible to get extra refs on all types of message for later
+     freeing, but this may pin the state of a call until the message is finally
+     freed.
+
+ (*) Accept an incoming call.
+
+	struct rxrpc_call *
+	rxrpc_kernel_accept_call(struct socket *sock,
+				 unsigned long user_call_ID);
+
+     This is used to accept an incoming call and to assign it a call ID.  This
+     function is similar to rxrpc_kernel_begin_call() and calls accepted must
+     be ended in the same way.
+
+     If this function is successful, an opaque reference to the RxRPC call is
+     returned.  The caller now holds a reference on this and it must be
+     properly ended.
+
+ (*) Reject an incoming call.
+
+	int rxrpc_kernel_reject_call(struct socket *sock);
+
+     This is used to reject the first incoming call on the socket's queue with
+     a BUSY message.  -ENODATA is returned if there were no incoming calls.
+     Other errors may be returned if the call had been aborted (-ECONNABORTED)
+     or had timed out (-ETIME).
+
+ (*) Record the delivery of a data message and free it.
+
+	void rxrpc_kernel_data_delivered(struct sk_buff *skb);
+
+     This is used to record a data message as having been delivered and to
+     update the ACK state for the call.  The socket buffer will be freed.
+
+ (*) Free a message.
+
+	void rxrpc_kernel_free_skb(struct sk_buff *skb);
+
+     This is used to free a non-DATA socket buffer intercepted from an AF_RXRPC
+     socket.
+
+ (*) Determine if a data message is the last one on a call.
+
+	bool rxrpc_kernel_is_data_last(struct sk_buff *skb);
+
+     This is used to determine if a socket buffer holds the last data message
+     to be received for a call (true will be returned if it does, false
+     if not).
+
+     The data message will be part of the reply on a client call and the
+     request on an incoming call.  In the latter case there will be more
+     messages, but in the former case there will not.
+
+ (*) Get the abort code from an abort message.
+
+	u32 rxrpc_kernel_get_abort_code(struct sk_buff *skb);
+
+     This is used to extract the abort code from a remote abort message.
+
+ (*) Get the error number from a local or network error message.
+
+	int rxrpc_kernel_get_error_number(struct sk_buff *skb);
+
+     This is used to extract the error number from a message indicating either
+     a local error occurred or a network error occurred.
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index b01ca25..00c2eaa 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -1,6 +1,6 @@
-/* RxRPC definitions
+/* RxRPC kernel service interface definitions
  *
- * Copyright (C) 2006 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -12,6 +12,46 @@
 #ifndef _NET_RXRPC_H
 #define _NET_RXRPC_H
 
+#ifdef __KERNEL__
+
 #include <linux/rxrpc.h>
 
+struct rxrpc_call;
+
+/*
+ * the mark applied to socket buffers that may be intercepted
+ */
+enum {
+	RXRPC_SKB_MARK_DATA,		/* data message */
+	RXRPC_SKB_MARK_FINAL_ACK,	/* final ACK received message */
+	RXRPC_SKB_MARK_BUSY,		/* server busy message */
+	RXRPC_SKB_MARK_REMOTE_ABORT,	/* remote abort message */
+	RXRPC_SKB_MARK_NET_ERROR,	/* network error message */
+	RXRPC_SKB_MARK_LOCAL_ERROR,	/* local error message */
+	RXRPC_SKB_MARK_NEW_CALL,	/* local error message */
+};
+
+typedef void (*rxrpc_interceptor_t)(struct sock *, unsigned long,
+				    struct sk_buff *);
+extern void rxrpc_kernel_intercept_rx_messages(struct socket *,
+					       rxrpc_interceptor_t);
+extern struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *,
+						  struct sockaddr_rxrpc *,
+						  struct key *,
+						  unsigned long,
+						  gfp_t);
+extern int rxrpc_kernel_send_data(struct rxrpc_call *, struct msghdr *,
+				  size_t);
+extern void rxrpc_kernel_abort_call(struct rxrpc_call *, u32);
+extern void rxrpc_kernel_end_call(struct rxrpc_call *);
+extern bool rxrpc_kernel_is_data_last(struct sk_buff *);
+extern u32 rxrpc_kernel_get_abort_code(struct sk_buff *);
+extern int rxrpc_kernel_get_error_number(struct sk_buff *);
+extern void rxrpc_kernel_data_delivered(struct sk_buff *);
+extern void rxrpc_kernel_free_skb(struct sk_buff *);
+extern struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *,
+						   unsigned long);
+extern int rxrpc_kernel_reject_call(struct socket *);
+
+#endif /* __KERNEL__ */
 #endif /* _NET_RXRPC_H */
diff --git a/include/rxrpc/packet.h b/include/rxrpc/packet.h
index 452a9bb..09b11a1 100644
--- a/include/rxrpc/packet.h
+++ b/include/rxrpc/packet.h
@@ -186,6 +186,18 @@ struct rxkad_response {
 #define RX_DEBUGI_BADTYPE	-8	/* bad debugging packet type */
 
 /*
+ * (un)marshalling abort codes (rxgen)
+ */
+#define	RXGEN_CC_MARSHAL    -450
+#define	RXGEN_CC_UNMARSHAL  -451
+#define	RXGEN_SS_MARSHAL    -452
+#define	RXGEN_SS_UNMARSHAL  -453
+#define	RXGEN_DECODE	    -454
+#define	RXGEN_OPCODE	    -455
+#define	RXGEN_SS_XDRFREE    -456
+#define	RXGEN_CC_XDRFREE    -457
+
+/*
  * Rx kerberos security abort codes
  * - unfortunately we have no generalised security abort codes to say things
  *   like "unsupported security", so we have to use these instead and hope the
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 54b93d7..fb35998 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -214,7 +214,8 @@ static int rxrpc_listen(struct socket *sock, int backlog)
  */
 static struct rxrpc_transport *rxrpc_name_to_transport(struct socket *sock,
 						       struct sockaddr *addr,
-						       int addr_len, int flags)
+						       int addr_len, int flags,
+						       gfp_t gfp)
 {
 	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *) addr;
 	struct rxrpc_transport *trans;
@@ -232,17 +233,127 @@ static struct rxrpc_transport *rxrpc_name_to_transport(struct socket *sock,
 		return ERR_PTR(-EAFNOSUPPORT);
 
 	/* find a remote transport endpoint from the local one */
-	peer = rxrpc_get_peer(srx, GFP_KERNEL);
+	peer = rxrpc_get_peer(srx, gfp);
 	if (IS_ERR(peer))
 		return ERR_PTR(PTR_ERR(peer));
 
 	/* find a transport */
-	trans = rxrpc_get_transport(rx->local, peer, GFP_KERNEL);
+	trans = rxrpc_get_transport(rx->local, peer, gfp);
 	rxrpc_put_peer(peer);
 	_leave(" = %p", trans);
 	return trans;
 }
 
+/**
+ * rxrpc_kernel_begin_call - Allow a kernel service to begin a call
+ * @sock: The socket on which to make the call
+ * @srx: The address of the peer to contact (defaults to socket setting)
+ * @key: The security context to use (defaults to socket setting)
+ * @user_call_ID: The ID to use
+ *
+ * Allow a kernel service to begin a call on the nominated socket.  This just
+ * sets up all the internal tracking structures and allocates connection and
+ * call IDs as appropriate.  The call to be used is returned.
+ *
+ * The default socket destination address and security may be overridden by
+ * supplying @srx and @key.
+ */
+struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
+					   struct sockaddr_rxrpc *srx,
+					   struct key *key,
+					   unsigned long user_call_ID,
+					   gfp_t gfp)
+{
+	struct rxrpc_conn_bundle *bundle;
+	struct rxrpc_transport *trans;
+	struct rxrpc_call *call;
+	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
+	__be16 service_id;
+
+	_enter(",,%x,%lx", key_serial(key), user_call_ID);
+
+	lock_sock(&rx->sk);
+
+	if (srx) {
+		trans = rxrpc_name_to_transport(sock, (struct sockaddr *) srx,
+						sizeof(*srx), 0, gfp);
+		if (IS_ERR(trans)) {
+			call = ERR_PTR(PTR_ERR(trans));
+			trans = NULL;
+			goto out;
+		}
+	} else {
+		trans = rx->trans;
+		if (!trans) {
+			call = ERR_PTR(-ENOTCONN);
+			goto out;
+		}
+		atomic_inc(&trans->usage);
+	}
+
+	service_id = rx->service_id;
+	if (srx)
+		service_id = htons(srx->srx_service);
+
+	if (!key)
+		key = rx->key;
+
+	bundle = rxrpc_get_bundle(rx, trans, key, service_id, gfp);
+	if (IS_ERR(bundle)) {
+		call = ERR_PTR(PTR_ERR(bundle));
+		goto out;
+	}
+
+	call = rxrpc_get_client_call(rx, trans, bundle, user_call_ID, true,
+				     gfp);
+	rxrpc_put_bundle(trans, bundle);
+out:
+	rxrpc_put_transport(trans);
+	release_sock(&rx->sk);
+	_leave(" = %p", call);
+	return call;
+}
+
+EXPORT_SYMBOL(rxrpc_kernel_begin_call);
+
+/**
+ * rxrpc_kernel_end_call - Allow a kernel service to end a call it was using
+ * @call: The call to end
+ *
+ * Allow a kernel service to end a call it was using.  The call must be
+ * complete before this is called (the call should be aborted if necessary).
+ */
+void rxrpc_kernel_end_call(struct rxrpc_call *call)
+{
+	_enter("%d{%d}", call->debug_id, atomic_read(&call->usage));
+	rxrpc_remove_user_ID(call->socket, call);
+	rxrpc_put_call(call);
+}
+
+EXPORT_SYMBOL(rxrpc_kernel_end_call);
+
+/**
+ * rxrpc_kernel_intercept_rx_messages - Intercept received RxRPC messages
+ * @sock: The socket to intercept received messages on
+ * @interceptor: The function to pass the messages to
+ *
+ * Allow a kernel service to intercept messages heading for the Rx queue on an
+ * RxRPC socket.  They get passed to the specified function instead.
+ * @interceptor should free the socket buffers it is given.  @interceptor is
+ * called with the socket receive queue spinlock held and softirqs disabled -
+ * this ensures that the messages will be delivered in the right order.
+ */
+void rxrpc_kernel_intercept_rx_messages(struct socket *sock,
+					rxrpc_interceptor_t interceptor)
+{
+	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
+
+	_enter("");
+	rx->interceptor = interceptor;
+}
+
+EXPORT_SYMBOL(rxrpc_kernel_intercept_rx_messages);
+
 /*
  * connect an RxRPC socket
  * - this just targets it at a specific destination; no actual connection
@@ -294,7 +405,8 @@ static int rxrpc_connect(struct socket *sock, struct sockaddr *addr,
 		return -EBUSY; /* server sockets can't connect as well */
 	}
 
-	trans = rxrpc_name_to_transport(sock, addr, addr_len, flags);
+	trans = rxrpc_name_to_transport(sock, addr, addr_len, flags,
+					GFP_KERNEL);
 	if (IS_ERR(trans)) {
 		release_sock(&rx->sk);
 		_leave(" = %ld", PTR_ERR(trans));
@@ -344,7 +456,7 @@ static int rxrpc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (m->msg_name) {
 		ret = -EISCONN;
 		trans = rxrpc_name_to_transport(sock, m->msg_name,
-						m->msg_namelen, 0);
+						m->msg_namelen, 0, GFP_KERNEL);
 		if (IS_ERR(trans)) {
 			ret = PTR_ERR(trans);
 			trans = NULL;
diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
index b988e0f..405092d 100644
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -310,7 +310,8 @@ security_mismatch:
  * handle acceptance of a call by userspace
  * - assign the user call ID to the call at the front of the queue
  */
-int rxrpc_accept_call(struct rxrpc_sock *rx, unsigned long user_call_ID)
+struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
+				     unsigned long user_call_ID)
 {
 	struct rxrpc_call *call;
 	struct rb_node *parent, **pp;
@@ -376,10 +377,11 @@ int rxrpc_accept_call(struct rxrpc_sock *rx, unsigned long user_call_ID)
 		BUG();
 	schedule_work(&call->processor);
 
+	rxrpc_get_call(call);
 	write_unlock_bh(&call->state_lock);
 	write_unlock(&rx->call_lock);
-	_leave(" = 0");
-	return 0;
+	_leave(" = %p{%d}", call, call->debug_id);
+	return call;
 
 	/* if the call is already dying or dead, then we leave the socket's ref
 	 * on it to be released by rxrpc_dead_call_expired() as induced by
@@ -395,5 +397,108 @@ out_discard:
 out:
 	write_unlock(&rx->call_lock);
 	_leave(" = %d", ret);
+	return ERR_PTR(ret);
+}
+
+/*
+ * handle rejectance of a call by userspace
+ * - reject the call at the front of the queue
+ */
+int rxrpc_reject_call(struct rxrpc_sock *rx)
+{
+	struct rxrpc_call *call;
+	int ret;
+
+	_enter("");
+
+	ASSERT(!irqs_disabled());
+
+	write_lock(&rx->call_lock);
+
+	ret = -ENODATA;
+	if (list_empty(&rx->acceptq))
+		goto out;
+
+	/* dequeue the first call and check it's still valid */
+	call = list_entry(rx->acceptq.next, struct rxrpc_call, accept_link);
+	list_del_init(&call->accept_link);
+	sk_acceptq_removed(&rx->sk);
+
+	write_lock_bh(&call->state_lock);
+	switch (call->state) {
+	case RXRPC_CALL_SERVER_ACCEPTING:
+		call->state = RXRPC_CALL_SERVER_BUSY;
+		if (test_and_set_bit(RXRPC_CALL_REJECT_BUSY, &call->events))
+			schedule_work(&call->processor);
+		ret = 0;
+		goto out_release;
+	case RXRPC_CALL_REMOTELY_ABORTED:
+	case RXRPC_CALL_LOCALLY_ABORTED:
+		ret = -ECONNABORTED;
+		goto out_release;
+	case RXRPC_CALL_NETWORK_ERROR:
+		ret = call->conn->error;
+		goto out_release;
+	case RXRPC_CALL_DEAD:
+		ret = -ETIME;
+		goto out_discard;
+	default:
+		BUG();
+	}
+
+	/* if the call is already dying or dead, then we leave the socket's ref
+	 * on it to be released by rxrpc_dead_call_expired() as induced by
+	 * rxrpc_release_call() */
+out_release:
+	_debug("release %p", call);
+	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
+	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
+		schedule_work(&call->processor);
+out_discard:
+	write_unlock_bh(&call->state_lock);
+	_debug("discard %p", call);
+out:
+	write_unlock(&rx->call_lock);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/**
+ * rxrpc_kernel_accept_call - Allow a kernel service to accept an incoming call
+ * @sock: The socket on which the impending call is waiting
+ * @user_call_ID: The tag to attach to the call
+ *
+ * Allow a kernel service to accept an incoming call, assuming the incoming
+ * call is still valid.
+ */
+struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *sock,
+					    unsigned long user_call_ID)
+{
+	struct rxrpc_call *call;
+
+	_enter(",%lx", user_call_ID);
+	call = rxrpc_accept_call(rxrpc_sk(sock->sk), user_call_ID);
+	_leave(" = %p", call);
+	return call;
+}
+
+EXPORT_SYMBOL(rxrpc_kernel_accept_call);
+
+/**
+ * rxrpc_kernel_reject_call - Allow a kernel service to reject an incoming call
+ * @sock: The socket on which the impending call is waiting
+ *
+ * Allow a kernel service to reject an incoming call with a BUSY message,
+ * assuming the incoming call is still valid.
+ */
+int rxrpc_kernel_reject_call(struct socket *sock)
+{
+	int ret;
+
+	_enter("");
+	ret = rxrpc_reject_call(rxrpc_sk(sock->sk));
+	_leave(" = %d", ret);
 	return ret;
 }
+
+EXPORT_SYMBOL(rxrpc_kernel_reject_call);
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index a24d0fc..093af56 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -21,7 +21,7 @@ static void rxrpc_connection_reaper(struct work_struct *work);
 
 LIST_HEAD(rxrpc_connections);
 DEFINE_RWLOCK(rxrpc_connection_lock);
-static unsigned long rxrpc_connection_timeout = 5;
+static unsigned long rxrpc_connection_timeout = 10 * 60;
 static DECLARE_DELAYED_WORK(rxrpc_connection_reap, rxrpc_connection_reaper);
 
 /*
@@ -52,10 +52,10 @@ static struct rxrpc_conn_bundle *rxrpc_alloc_bundle(gfp_t gfp)
  */
 static inline
 int rxrpc_cmp_bundle(const struct rxrpc_conn_bundle *bundle,
-		     const struct rxrpc_sock *rx)
+		     struct key *key, __be16 service_id)
 {
-	return (bundle->service_id - rx->service_id) ?:
-		((unsigned long) bundle->key - (unsigned long) rx->key);
+	return (bundle->service_id - service_id) ?:
+		((unsigned long) bundle->key - (unsigned long) key);
 }
 
 /*
@@ -63,6 +63,7 @@ int rxrpc_cmp_bundle(const struct rxrpc_conn_bundle *bundle,
  */
 struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *rx,
 					   struct rxrpc_transport *trans,
+					   struct key *key,
 					   __be16 service_id,
 					   gfp_t gfp)
 {
@@ -70,7 +71,7 @@ struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *rx,
 	struct rb_node *p, *parent, **pp;
 
 	_enter("%p{%x},%x,%hx,",
-	       rx, key_serial(rx->key), trans->debug_id, ntohl(service_id));
+	       rx, key_serial(key), trans->debug_id, ntohl(service_id));
 
 	if (rx->trans == trans && rx->bundle) {
 		atomic_inc(&rx->bundle->usage);
@@ -85,9 +86,9 @@ struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *rx,
 	while (p) {
 		bundle = rb_entry(p, struct rxrpc_conn_bundle, node);
 
-		if (rxrpc_cmp_bundle(bundle, rx) < 0)
+		if (rxrpc_cmp_bundle(bundle, key, service_id) < 0)
 			p = p->rb_left;
-		else if (rxrpc_cmp_bundle(bundle, rx) > 0)
+		else if (rxrpc_cmp_bundle(bundle, key, service_id) > 0)
 			p = p->rb_right;
 		else
 			goto found_extant_bundle;
@@ -103,7 +104,7 @@ struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *rx,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	candidate->key = key_get(rx->key);
+	candidate->key = key_get(key);
 	candidate->service_id = service_id;
 
 	spin_lock(&trans->client_lock);
@@ -114,9 +115,9 @@ struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *rx,
 		parent = *pp;
 		bundle = rb_entry(parent, struct rxrpc_conn_bundle, node);
 
-		if (rxrpc_cmp_bundle(bundle, rx) < 0)
+		if (rxrpc_cmp_bundle(bundle, key, service_id) < 0)
 			pp = &(*pp)->rb_left;
-		else if (rxrpc_cmp_bundle(bundle, rx) > 0)
+		else if (rxrpc_cmp_bundle(bundle, key, service_id) > 0)
 			pp = &(*pp)->rb_right;
 		else
 			goto found_extant_second;
@@ -129,6 +130,7 @@ struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *rx,
 	rb_link_node(&bundle->node, parent, pp);
 	rb_insert_color(&bundle->node, &trans->bundles);
 	spin_unlock(&trans->client_lock);
+	_net("BUNDLE new on trans %d", trans->debug_id);
 	if (!rx->bundle && rx->sk.sk_state == RXRPC_CLIENT_CONNECTED) {
 		atomic_inc(&bundle->usage);
 		rx->bundle = bundle;
@@ -140,6 +142,7 @@ struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *rx,
 found_extant_bundle:
 	atomic_inc(&bundle->usage);
 	spin_unlock(&trans->client_lock);
+	_net("BUNDLE old on trans %d", trans->debug_id);
 	if (!rx->bundle && rx->sk.sk_state == RXRPC_CLIENT_CONNECTED) {
 		atomic_inc(&bundle->usage);
 		rx->bundle = bundle;
@@ -152,6 +155,7 @@ found_extant_second:
 	atomic_inc(&bundle->usage);
 	spin_unlock(&trans->client_lock);
 	kfree(candidate);
+	_net("BUNDLE old2 on trans %d", trans->debug_id);
 	if (!rx->bundle && rx->sk.sk_state == RXRPC_CLIENT_CONNECTED) {
 		atomic_inc(&bundle->usage);
 		rx->bundle = bundle;
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 64ae9fa..9269786 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -42,6 +42,7 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 			bool force, bool terminal)
 {
 	struct rxrpc_skb_priv *sp;
+	struct rxrpc_sock *rx = call->socket;
 	struct sock *sk;
 	int skb_len, ret;
 
@@ -64,7 +65,7 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 		return 0;
 	}
 
-	sk = &call->socket->sk;
+	sk = &rx->sk;
 
 	if (!force) {
 		/* cast skb->rcvbuf to unsigned...  It's pointless, but
@@ -89,25 +90,30 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 		skb->sk = sk;
 		atomic_add(skb->truesize, &sk->sk_rmem_alloc);
 
-		/* Cache the SKB length before we tack it onto the receive
-		 * queue.  Once it is added it no longer belongs to us and
-		 * may be freed by other threads of control pulling packets
-		 * from the queue.
-		 */
-		skb_len = skb->len;
-
-		_net("post skb %p", skb);
-		__skb_queue_tail(&sk->sk_receive_queue, skb);
-		spin_unlock_bh(&sk->sk_receive_queue.lock);
-
-		if (!sock_flag(sk, SOCK_DEAD))
-			sk->sk_data_ready(sk, skb_len);
-
 		if (terminal) {
 			_debug("<<<< TERMINAL MESSAGE >>>>");
 			set_bit(RXRPC_CALL_TERMINAL_MSG, &call->flags);
 		}
 
+		/* allow interception by a kernel service */
+		if (rx->interceptor) {
+			rx->interceptor(sk, call->user_call_ID, skb);
+			spin_unlock_bh(&sk->sk_receive_queue.lock);
+		} else {
+
+			/* Cache the SKB length before we tack it onto the
+			 * receive queue.  Once it is added it no longer
+			 * belongs to us and may be freed by other threads of
+			 * control pulling packets from the queue */
+			skb_len = skb->len;
+
+			_net("post skb %p", skb);
+			__skb_queue_tail(&sk->sk_receive_queue, skb);
+			spin_unlock_bh(&sk->sk_receive_queue.lock);
+
+			if (!sock_flag(sk, SOCK_DEAD))
+				sk->sk_data_ready(sk, skb_len);
+		}
 		skb = NULL;
 	} else {
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index d6a667e..7c1887a 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -50,6 +50,7 @@ enum {
 struct rxrpc_sock {
 	/* WARNING: sk has to be the first member */
 	struct sock		sk;
+	rxrpc_interceptor_t	interceptor;	/* kernel service Rx interceptor function */
 	struct rxrpc_local	*local;		/* local endpoint */
 	struct rxrpc_transport	*trans;		/* transport handler */
 	struct rxrpc_conn_bundle *bundle;	/* virtual connection bundle */
@@ -91,16 +92,6 @@ struct rxrpc_skb_priv {
 
 #define rxrpc_skb(__skb) ((struct rxrpc_skb_priv *) &(__skb)->cb)
 
-enum {
-	RXRPC_SKB_MARK_DATA,		/* data message */
-	RXRPC_SKB_MARK_FINAL_ACK,	/* final ACK received message */
-	RXRPC_SKB_MARK_BUSY,		/* server busy message */
-	RXRPC_SKB_MARK_REMOTE_ABORT,	/* remote abort message */
-	RXRPC_SKB_MARK_NET_ERROR,	/* network error message */
-	RXRPC_SKB_MARK_LOCAL_ERROR,	/* local error message */
-	RXRPC_SKB_MARK_NEW_CALL,	/* local error message */
-};
-
 enum rxrpc_command {
 	RXRPC_CMD_SEND_DATA,		/* send data message */
 	RXRPC_CMD_SEND_ABORT,		/* request abort generation */
@@ -457,7 +448,9 @@ void rxrpc_reject_packet(struct rxrpc_local *local, struct sk_buff *skb)
  * ar-accept.c
  */
 extern void rxrpc_accept_incoming_calls(struct work_struct *);
-extern int rxrpc_accept_call(struct rxrpc_sock *, unsigned long);
+extern struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *,
+					    unsigned long);
+extern int rxrpc_reject_call(struct rxrpc_sock *);
 
 /*
  * ar-ack.c
@@ -495,6 +488,7 @@ extern rwlock_t rxrpc_connection_lock;
 
 extern struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *,
 						  struct rxrpc_transport *,
+						  struct key *,
 						  __be16, gfp_t);
 extern void rxrpc_put_bundle(struct rxrpc_transport *,
 			     struct rxrpc_conn_bundle *);
@@ -582,6 +576,7 @@ extern struct file_operations rxrpc_connection_seq_fops;
 /*
  * ar-recvmsg.c
  */
+extern void rxrpc_remove_user_ID(struct rxrpc_sock *, struct rxrpc_call *);
 extern int rxrpc_recvmsg(struct kiocb *, struct socket *, struct msghdr *,
 			 size_t, int);
 
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index c5ee56e..a79576f 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -153,7 +153,8 @@ int rxrpc_client_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
 				(struct sockaddr_rxrpc *) msg->msg_name;
 			service_id = htons(srx->srx_service);
 		}
-		bundle = rxrpc_get_bundle(rx, trans, service_id, GFP_KERNEL);
+		bundle = rxrpc_get_bundle(rx, trans, rx->key, service_id,
+					  GFP_KERNEL);
 		if (IS_ERR(bundle))
 			return PTR_ERR(bundle);
 	}
@@ -189,6 +190,77 @@ int rxrpc_client_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
 	return ret;
 }
 
+/**
+ * rxrpc_kernel_send_data - Allow a kernel service to send data on a call
+ * @call: The call to send data through
+ * @msg: The data to send
+ * @len: The amount of data to send
+ *
+ * Allow a kernel service to send data on a call.  The call must be in an state
+ * appropriate to sending data.  No control data should be supplied in @msg,
+ * nor should an address be supplied.  MSG_MORE should be flagged if there's
+ * more data to come, otherwise this data will end the transmission phase.
+ */
+int rxrpc_kernel_send_data(struct rxrpc_call *call, struct msghdr *msg,
+			   size_t len)
+{
+	int ret;
+
+	_enter("{%d,%s},", call->debug_id, rxrpc_call_states[call->state]);
+
+	ASSERTCMP(msg->msg_name, ==, NULL);
+	ASSERTCMP(msg->msg_control, ==, NULL);
+
+	lock_sock(&call->socket->sk);
+
+	_debug("CALL %d USR %lx ST %d on CONN %p",
+	       call->debug_id, call->user_call_ID, call->state, call->conn);
+
+	if (call->state >= RXRPC_CALL_COMPLETE) {
+		ret = -ESHUTDOWN; /* it's too late for this call */
+	} else if (call->state != RXRPC_CALL_CLIENT_SEND_REQUEST &&
+		   call->state != RXRPC_CALL_SERVER_ACK_REQUEST &&
+		   call->state != RXRPC_CALL_SERVER_SEND_REPLY) {
+		ret = -EPROTO; /* request phase complete for this client call */
+	} else {
+		mm_segment_t oldfs = get_fs();
+		set_fs(KERNEL_DS);
+		ret = rxrpc_send_data(NULL, call->socket, call, msg, len);
+		set_fs(oldfs);
+	}
+
+	release_sock(&call->socket->sk);
+	_leave(" = %d", ret);
+	return ret;
+}
+
+EXPORT_SYMBOL(rxrpc_kernel_send_data);
+
+/*
+ * rxrpc_kernel_abort_call - Allow a kernel service to abort a call
+ * @call: The call to be aborted
+ * @abort_code: The abort code to stick into the ABORT packet
+ *
+ * Allow a kernel service to abort a call, if it's still in an abortable state.
+ */
+void rxrpc_kernel_abort_call(struct rxrpc_call *call, u32 abort_code)
+{
+	_enter("{%d},%d", call->debug_id, abort_code);
+
+	lock_sock(&call->socket->sk);
+
+	_debug("CALL %d USR %lx ST %d on CONN %p",
+	       call->debug_id, call->user_call_ID, call->state, call->conn);
+
+	if (call->state < RXRPC_CALL_COMPLETE)
+		rxrpc_send_abort(call, abort_code);
+
+	release_sock(&call->socket->sk);
+	_leave("");
+}
+
+EXPORT_SYMBOL(rxrpc_kernel_abort_call);
+
 /*
  * send a message through a server socket
  * - caller holds the socket locked
@@ -209,8 +281,13 @@ int rxrpc_server_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
 	if (ret < 0)
 		return ret;
 
-	if (cmd == RXRPC_CMD_ACCEPT)
-		return rxrpc_accept_call(rx, user_call_ID);
+	if (cmd == RXRPC_CMD_ACCEPT) {
+		call = rxrpc_accept_call(rx, user_call_ID);
+		if (IS_ERR(call))
+			return PTR_ERR(call);
+		rxrpc_put_call(call);
+		return 0;
+	}
 
 	call = rxrpc_find_server_call(rx, user_call_ID);
 	if (!call)
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index e947d5c..6fab099 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -19,7 +19,7 @@
  * removal a call's user ID from the socket tree to make the user ID available
  * again and so that it won't be seen again in association with that call
  */
-static void rxrpc_remove_user_ID(struct rxrpc_sock *rx, struct rxrpc_call *call)
+void rxrpc_remove_user_ID(struct rxrpc_sock *rx, struct rxrpc_call *call)
 {
 	_debug("RELEASE CALL %d", call->debug_id);
 
@@ -364,3 +364,74 @@ wait_error:
 	return copied;
 
 }
+
+/**
+ * rxrpc_kernel_data_delivered - Record delivery of data message
+ * @skb: Message holding data
+ *
+ * Record the delivery of a data message.  This permits RxRPC to keep its
+ * tracking correct.  The socket buffer will be deleted.
+ */
+void rxrpc_kernel_data_delivered(struct sk_buff *skb)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	struct rxrpc_call *call = sp->call;
+
+	ASSERTCMP(ntohl(sp->hdr.seq), >=, call->rx_data_recv);
+	ASSERTCMP(ntohl(sp->hdr.seq), <=, call->rx_data_recv + 1);
+	call->rx_data_recv = ntohl(sp->hdr.seq);
+
+	ASSERTCMP(ntohl(sp->hdr.seq), >, call->rx_data_eaten);
+	rxrpc_free_skb(skb);
+}
+
+EXPORT_SYMBOL(rxrpc_kernel_data_delivered);
+
+/**
+ * rxrpc_kernel_is_data_last - Determine if data message is last one
+ * @skb: Message holding data
+ *
+ * Determine if data message is last one for the parent call.
+ */
+bool rxrpc_kernel_is_data_last(struct sk_buff *skb)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+
+	ASSERTCMP(skb->mark, ==, RXRPC_SKB_MARK_DATA);
+
+	return sp->hdr.flags & RXRPC_LAST_PACKET;
+}
+
+EXPORT_SYMBOL(rxrpc_kernel_is_data_last);
+
+/**
+ * rxrpc_kernel_get_abort_code - Get the abort code from an RxRPC abort message
+ * @skb: Message indicating an abort
+ *
+ * Get the abort code from an RxRPC abort message.
+ */
+u32 rxrpc_kernel_get_abort_code(struct sk_buff *skb)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+
+	ASSERTCMP(skb->mark, ==, RXRPC_SKB_MARK_REMOTE_ABORT);
+
+	return sp->call->abort_code;
+}
+
+EXPORT_SYMBOL(rxrpc_kernel_get_abort_code);
+
+/**
+ * rxrpc_kernel_get_error - Get the error number from an RxRPC error message
+ * @skb: Message indicating an error
+ *
+ * Get the error number from an RxRPC error message.
+ */
+int rxrpc_kernel_get_error_number(struct sk_buff *skb)
+{
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+
+	return sp->error;
+}
+
+EXPORT_SYMBOL(rxrpc_kernel_get_error_number);
diff --git a/net/rxrpc/ar-skbuff.c b/net/rxrpc/ar-skbuff.c
index d73f6fc..487e689 100644
--- a/net/rxrpc/ar-skbuff.c
+++ b/net/rxrpc/ar-skbuff.c
@@ -116,3 +116,17 @@ void rxrpc_packet_destructor(struct sk_buff *skb)
 		sock_rfree(skb);
 	_leave("");
 }
+
+/**
+ * rxrpc_kernel_free_skb - Free an RxRPC socket buffer
+ * @skb: The socket buffer to be freed
+ *
+ * Let RxRPC free its own socket buffer, permitting it to maintain debug
+ * accounting.
+ */
+void rxrpc_kernel_free_skb(struct sk_buff *skb)
+{
+	rxrpc_free_skb(skb);
+}
+
+EXPORT_SYMBOL(rxrpc_kernel_free_skb);

