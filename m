From: David Howells <dhowells@redhat.com>
Subject: [PATCH 07/16] AF_RXRPC: Add an interface to the AF_RXRPC module for
	the AFS filesystem to use [try #4]
Date: Wed, 25 Apr 2007 16:49:33 +0100
Message-ID: <20070425154933.26581.87857.stgit@warthog.cambridge.redhat.com>
References: <20070425154854.26581.97692.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48089 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031132AbXDYPuU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 11:50:20 -0400
In-Reply-To: <20070425154854.26581.97692.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
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
 net/rxrpc/af_rxrpc.c               |  141 ++++++++++++++++++++++++--
 net/rxrpc/ar-accept.c              |  119 +++++++++++++++++++++-
 net/rxrpc/ar-ack.c                 |   10 +-
 net/rxrpc/ar-call.c                |   75 ++++++++------
 net/rxrpc/ar-connection.c          |   28 ++++-
 net/rxrpc/ar-connevent.c           |   20 +++-
 net/rxrpc/ar-error.c               |    6 +
 net/rxrpc/ar-input.c               |   60 ++++++-----
 net/rxrpc/ar-internal.h            |   44 +++-----
 net/rxrpc/ar-local.c               |    2 
 net/rxrpc/ar-output.c              |   84 +++++++++++++++
 net/rxrpc/ar-peer.c                |    2 
 net/rxrpc/ar-recvmsg.c             |   75 +++++++++++++-
 net/rxrpc/ar-skbuff.c              |   16 +++
 net/rxrpc/ar-transport.c           |    8 +
 18 files changed, 813 insertions(+), 129 deletions(-)

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
index 54b93d7..9e37e4f 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -41,6 +41,8 @@ atomic_t rxrpc_debug_id;
 /* count of skbs currently in use */
 atomic_t rxrpc_n_skbs;
 
+struct workqueue_struct *rxrpc_workqueue;
+
 static void rxrpc_sock_destructor(struct sock *);
 
 /*
@@ -214,7 +216,8 @@ static int rxrpc_listen(struct socket *sock, int backlog)
  */
 static struct rxrpc_transport *rxrpc_name_to_transport(struct socket *sock,
 						       struct sockaddr *addr,
-						       int addr_len, int flags)
+						       int addr_len, int flags,
+						       gfp_t gfp)
 {
 	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *) addr;
 	struct rxrpc_transport *trans;
@@ -232,17 +235,129 @@ static struct rxrpc_transport *rxrpc_name_to_transport(struct socket *sock,
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
+	if (key && !key->payload.data)
+		key = NULL; /* a no-security key */
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
@@ -294,7 +409,8 @@ static int rxrpc_connect(struct socket *sock, struct sockaddr *addr,
 		return -EBUSY; /* server sockets can't connect as well */
 	}
 
-	trans = rxrpc_name_to_transport(sock, addr, addr_len, flags);
+	trans = rxrpc_name_to_transport(sock, addr, addr_len, flags,
+					GFP_KERNEL);
 	if (IS_ERR(trans)) {
 		release_sock(&rx->sk);
 		_leave(" = %ld", PTR_ERR(trans));
@@ -344,7 +460,7 @@ static int rxrpc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (m->msg_name) {
 		ret = -EISCONN;
 		trans = rxrpc_name_to_transport(sock, m->msg_name,
-						m->msg_namelen, 0);
+						m->msg_namelen, 0, GFP_KERNEL);
 		if (IS_ERR(trans)) {
 			ret = PTR_ERR(trans);
 			trans = NULL;
@@ -576,7 +692,7 @@ static int rxrpc_release_sock(struct sock *sk)
 
 	/* try to flush out this socket */
 	rxrpc_release_calls_on_socket(rx);
-	flush_scheduled_work();
+	flush_workqueue(rxrpc_workqueue);
 	rxrpc_purge_queue(&sk->sk_receive_queue);
 
 	if (rx->conn) {
@@ -673,15 +789,21 @@ static int __init af_rxrpc_init(void)
 
 	rxrpc_epoch = htonl(xtime.tv_sec);
 
+	ret = -ENOMEM;
 	rxrpc_call_jar = kmem_cache_create(
 		"rxrpc_call_jar", sizeof(struct rxrpc_call), 0,
 		SLAB_HWCACHE_ALIGN, NULL, NULL);
 	if (!rxrpc_call_jar) {
 		printk(KERN_NOTICE "RxRPC: Failed to allocate call jar\n");
-		ret = -ENOMEM;
 		goto error_call_jar;
 	}
 
+	rxrpc_workqueue = create_workqueue("krxrpcd");
+	if (!rxrpc_workqueue) {
+		printk(KERN_NOTICE "RxRPC: Failed to allocate work queue\n");
+		goto error_work_queue;
+	}
+
 	ret = proto_register(&rxrpc_proto, 1);
         if (ret < 0) {
                 printk(KERN_CRIT "RxRPC: Cannot register protocol\n");
@@ -719,6 +841,8 @@ error_key_type:
 error_sock:
 	proto_unregister(&rxrpc_proto);
 error_proto:
+	destroy_workqueue(rxrpc_workqueue);
+error_work_queue:
 	kmem_cache_destroy(rxrpc_call_jar);
 error_call_jar:
 	return ret;
@@ -743,9 +867,10 @@ static void __exit af_rxrpc_exit(void)
 	ASSERTCMP(atomic_read(&rxrpc_n_skbs), ==, 0);
 
 	_debug("flush scheduled work");
-	flush_scheduled_work();
+	flush_workqueue(rxrpc_workqueue);
 	proc_net_remove("rxrpc_conns");
 	proc_net_remove("rxrpc_calls");
+	destroy_workqueue(rxrpc_workqueue);
 	kmem_cache_destroy(rxrpc_call_jar);
 	_leave("");
 }
diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
index b988e0f..73243ab 100644
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -139,7 +139,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 			call->conn->state = RXRPC_CONN_SERVER_CHALLENGING;
 			atomic_inc(&call->conn->usage);
 			set_bit(RXRPC_CONN_CHALLENGE, &call->conn->events);
-			schedule_work(&call->conn->processor);
+			rxrpc_queue_conn(call->conn);
 		} else {
 			_debug("conn ready");
 			call->state = RXRPC_CALL_SERVER_ACCEPTING;
@@ -183,7 +183,7 @@ invalid_service:
 	if (!test_bit(RXRPC_CALL_RELEASE, &call->flags) &&
 	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events)) {
 		rxrpc_get_call(call);
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 	read_unlock_bh(&call->state_lock);
 	rxrpc_put_call(call);
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
@@ -374,12 +375,76 @@ int rxrpc_accept_call(struct rxrpc_sock *rx, unsigned long user_call_ID)
 		BUG();
 	if (test_and_set_bit(RXRPC_CALL_ACCEPTED, &call->events))
 		BUG();
-	schedule_work(&call->processor);
+	rxrpc_queue_call(call);
 
+	rxrpc_get_call(call);
 	write_unlock_bh(&call->state_lock);
 	write_unlock(&rx->call_lock);
-	_leave(" = 0");
-	return 0;
+	_leave(" = %p{%d}", call, call->debug_id);
+	return call;
+
+	/* if the call is already dying or dead, then we leave the socket's ref
+	 * on it to be released by rxrpc_dead_call_expired() as induced by
+	 * rxrpc_release_call() */
+out_release:
+	_debug("release %p", call);
+	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
+	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
+		rxrpc_queue_call(call);
+out_discard:
+	write_unlock_bh(&call->state_lock);
+	_debug("discard %p", call);
+out:
+	write_unlock(&rx->call_lock);
+	_leave(" = %d", ret);
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
+			rxrpc_queue_call(call);
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
 
 	/* if the call is already dying or dead, then we leave the socket's ref
 	 * on it to be released by rxrpc_dead_call_expired() as induced by
@@ -388,7 +453,7 @@ out_release:
 	_debug("release %p", call);
 	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
 	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 out_discard:
 	write_unlock_bh(&call->state_lock);
 	_debug("discard %p", call);
@@ -397,3 +462,43 @@ out:
 	_leave(" = %d", ret);
 	return ret;
 }
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
+	return ret;
+}
+
+EXPORT_SYMBOL(rxrpc_kernel_reject_call);
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 8f7764e..fc07a92 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -113,7 +113,7 @@ cancel_timer:
 	read_lock_bh(&call->state_lock);
 	if (call->state <= RXRPC_CALL_COMPLETE &&
 	    !test_and_set_bit(RXRPC_CALL_ACK, &call->events))
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
 }
 
@@ -1166,7 +1166,7 @@ send_message_2:
 		_debug("sendmsg failed: %d", ret);
 		read_lock_bh(&call->state_lock);
 		if (call->state < RXRPC_CALL_DEAD)
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		read_unlock_bh(&call->state_lock);
 		goto error;
 	}
@@ -1210,7 +1210,7 @@ maybe_reschedule:
 	if (call->events || !skb_queue_empty(&call->rx_queue)) {
 		read_lock_bh(&call->state_lock);
 		if (call->state < RXRPC_CALL_DEAD)
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		read_unlock_bh(&call->state_lock);
 	}
 
@@ -1224,7 +1224,7 @@ maybe_reschedule:
 		read_lock_bh(&call->state_lock);
 		if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
 		    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		read_unlock_bh(&call->state_lock);
 	}
 
@@ -1238,7 +1238,7 @@ error:
 	 * work pending bit and the work item being processed again */
 	if (call->events && !work_pending(&call->processor)) {
 		_debug("jumpstart %x", ntohl(call->conn->cid));
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 
 	_leave("");
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index ac31cce..4d92d88 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -19,7 +19,7 @@ struct kmem_cache *rxrpc_call_jar;
 LIST_HEAD(rxrpc_calls);
 DEFINE_RWLOCK(rxrpc_call_lock);
 static unsigned rxrpc_call_max_lifetime = 60;
-static unsigned rxrpc_dead_call_timeout = 10;
+static unsigned rxrpc_dead_call_timeout = 2;
 
 static void rxrpc_destroy_call(struct work_struct *work);
 static void rxrpc_call_life_expired(unsigned long _call);
@@ -264,7 +264,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 		switch (call->state) {
 		case RXRPC_CALL_LOCALLY_ABORTED:
 			if (!test_and_set_bit(RXRPC_CALL_ABORT, &call->events))
-				schedule_work(&call->processor);
+				rxrpc_queue_call(call);
 		case RXRPC_CALL_REMOTELY_ABORTED:
 			read_unlock(&call->state_lock);
 			goto aborted_call;
@@ -398,6 +398,7 @@ found_extant_call:
  */
 void rxrpc_release_call(struct rxrpc_call *call)
 {
+	struct rxrpc_connection *conn = call->conn;
 	struct rxrpc_sock *rx = call->socket;
 
 	_enter("{%d,%d,%d,%d}",
@@ -413,8 +414,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	/* dissociate from the socket
 	 * - the socket's ref on the call is passed to the death timer
 	 */
-	_debug("RELEASE CALL %p (%d CONN %p)",
-	       call, call->debug_id, call->conn);
+	_debug("RELEASE CALL %p (%d CONN %p)", call, call->debug_id, conn);
 
 	write_lock_bh(&rx->call_lock);
 	if (!list_empty(&call->accept_link)) {
@@ -430,24 +430,42 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	}
 	write_unlock_bh(&rx->call_lock);
 
-	if (call->conn->out_clientflag)
-		spin_lock(&call->conn->trans->client_lock);
-	write_lock_bh(&call->conn->lock);
-
 	/* free up the channel for reuse */
-	if (call->conn->out_clientflag) {
-		call->conn->avail_calls++;
-		if (call->conn->avail_calls == RXRPC_MAXCALLS)
-			list_move_tail(&call->conn->bundle_link,
-				       &call->conn->bundle->unused_conns);
-		else if (call->conn->avail_calls == 1)
-			list_move_tail(&call->conn->bundle_link,
-				       &call->conn->bundle->avail_conns);
+	spin_lock(&conn->trans->client_lock);
+	write_lock_bh(&conn->lock);
+	write_lock(&call->state_lock);
+
+	if (conn->channels[call->channel] == call)
+		conn->channels[call->channel] = NULL;
+
+	if (conn->out_clientflag && conn->bundle) {
+		conn->avail_calls++;
+		switch (conn->avail_calls) {
+		case 1:
+			list_move_tail(&conn->bundle_link,
+				       &conn->bundle->avail_conns);
+		case 2 ... RXRPC_MAXCALLS - 1:
+			ASSERT(conn->channels[0] == NULL ||
+			       conn->channels[1] == NULL ||
+			       conn->channels[2] == NULL ||
+			       conn->channels[3] == NULL);
+			break;
+		case RXRPC_MAXCALLS:
+			list_move_tail(&conn->bundle_link,
+				       &conn->bundle->unused_conns);
+			ASSERT(conn->channels[0] == NULL &&
+			       conn->channels[1] == NULL &&
+			       conn->channels[2] == NULL &&
+			       conn->channels[3] == NULL);
+			break;
+		default:
+			printk(KERN_ERR "RxRPC: conn->avail_calls=%d\n",
+			       conn->avail_calls);
+			BUG();
+		}
 	}
 
-	write_lock(&call->state_lock);
-	if (call->conn->channels[call->channel] == call)
-		call->conn->channels[call->channel] = NULL;
+	spin_unlock(&conn->trans->client_lock);
 
 	if (call->state < RXRPC_CALL_COMPLETE &&
 	    call->state != RXRPC_CALL_CLIENT_FINAL_ACK) {
@@ -455,13 +473,12 @@ void rxrpc_release_call(struct rxrpc_call *call)
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
 		call->abort_code = RX_CALL_DEAD;
 		set_bit(RXRPC_CALL_ABORT, &call->events);
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 	write_unlock(&call->state_lock);
-	write_unlock_bh(&call->conn->lock);
-	if (call->conn->out_clientflag)
-		spin_unlock(&call->conn->trans->client_lock);
+	write_unlock_bh(&conn->lock);
 
+	/* clean up the Rx queue */
 	if (!skb_queue_empty(&call->rx_queue) ||
 	    !skb_queue_empty(&call->rx_oos_queue)) {
 		struct rxrpc_skb_priv *sp;
@@ -538,7 +555,7 @@ static void rxrpc_mark_call_released(struct rxrpc_call *call)
 		if (!test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
 			sched = true;
 		if (sched)
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 	}
 	write_unlock(&call->state_lock);
 }
@@ -588,7 +605,7 @@ void __rxrpc_put_call(struct rxrpc_call *call)
 	if (atomic_dec_and_test(&call->usage)) {
 		_debug("call %d dead", call->debug_id);
 		ASSERTCMP(call->state, ==, RXRPC_CALL_DEAD);
-		schedule_work(&call->destroyer);
+		rxrpc_queue_work(&call->destroyer);
 	}
 	_leave("");
 }
@@ -613,7 +630,7 @@ static void rxrpc_cleanup_call(struct rxrpc_call *call)
 	ASSERTCMP(call->events, ==, 0);
 	if (work_pending(&call->processor)) {
 		_debug("defer destroy");
-		schedule_work(&call->destroyer);
+		rxrpc_queue_work(&call->destroyer);
 		return;
 	}
 
@@ -742,7 +759,7 @@ static void rxrpc_call_life_expired(unsigned long _call)
 	read_lock_bh(&call->state_lock);
 	if (call->state < RXRPC_CALL_COMPLETE) {
 		set_bit(RXRPC_CALL_LIFE_TIMER, &call->events);
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 	read_unlock_bh(&call->state_lock);
 }
@@ -763,7 +780,7 @@ static void rxrpc_resend_time_expired(unsigned long _call)
 	clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
 	if (call->state < RXRPC_CALL_COMPLETE &&
 	    !test_and_set_bit(RXRPC_CALL_RESEND_TIMER, &call->events))
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
 }
 
@@ -782,6 +799,6 @@ static void rxrpc_ack_time_expired(unsigned long _call)
 	read_lock_bh(&call->state_lock);
 	if (call->state < RXRPC_CALL_COMPLETE &&
 	    !test_and_set_bit(RXRPC_CALL_ACK, &call->events))
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
 }
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 01eb33c..43cb3e0 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -356,7 +356,7 @@ static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
 		conn->out_clientflag = RXRPC_CLIENT_INITIATED;
 		conn->cid = 0;
 		conn->state = RXRPC_CONN_CLIENT;
-		conn->avail_calls = RXRPC_MAXCALLS;
+		conn->avail_calls = RXRPC_MAXCALLS - 1;
 		conn->security_level = rx->min_sec_level;
 		conn->key = key_get(rx->key);
 
@@ -447,6 +447,11 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 			if (--conn->avail_calls == 0)
 				list_move(&conn->bundle_link,
 					  &bundle->busy_conns);
+			ASSERTCMP(conn->avail_calls, <, RXRPC_MAXCALLS);
+			ASSERT(conn->channels[0] == NULL ||
+			       conn->channels[1] == NULL ||
+			       conn->channels[2] == NULL ||
+			       conn->channels[3] == NULL);
 			atomic_inc(&conn->usage);
 			break;
 		}
@@ -456,6 +461,12 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 			conn = list_entry(bundle->unused_conns.next,
 					  struct rxrpc_connection,
 					  bundle_link);
+			ASSERTCMP(conn->avail_calls, ==, RXRPC_MAXCALLS);
+			conn->avail_calls = RXRPC_MAXCALLS - 1;
+			ASSERT(conn->channels[0] == NULL &&
+			       conn->channels[1] == NULL &&
+			       conn->channels[2] == NULL &&
+			       conn->channels[3] == NULL);
 			atomic_inc(&conn->usage);
 			list_move(&conn->bundle_link, &bundle->avail_conns);
 			break;
@@ -512,7 +523,7 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 		candidate->state = RXRPC_CONN_CLIENT;
 		candidate->avail_calls = RXRPC_MAXCALLS;
 		candidate->security_level = rx->min_sec_level;
-		candidate->key = key_get(rx->key);
+		candidate->key = key_get(bundle->key);
 
 		ret = rxrpc_init_client_conn_security(candidate);
 		if (ret < 0) {
@@ -555,6 +566,10 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 	for (chan = 0; chan < RXRPC_MAXCALLS; chan++)
 		if (!conn->channels[chan])
 			goto found_channel;
+	ASSERT(conn->channels[0] == NULL ||
+	       conn->channels[1] == NULL ||
+	       conn->channels[2] == NULL ||
+	       conn->channels[3] == NULL);
 	BUG();
 
 found_channel:
@@ -567,6 +582,7 @@ found_channel:
 	_net("CONNECT client on conn %d chan %d as call %x",
 	     conn->debug_id, chan, ntohl(call->call_id));
 
+	ASSERTCMP(conn->avail_calls, <, RXRPC_MAXCALLS);
 	spin_unlock(&trans->client_lock);
 
 	rxrpc_add_call_ID_to_conn(conn, call);
@@ -778,7 +794,7 @@ void rxrpc_put_connection(struct rxrpc_connection *conn)
 	conn->put_time = xtime.tv_sec;
 	if (atomic_dec_and_test(&conn->usage)) {
 		_debug("zombie");
-		schedule_delayed_work(&rxrpc_connection_reap, 0);
+		rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
 	}
 
 	_leave("");
@@ -862,8 +878,8 @@ void rxrpc_connection_reaper(struct work_struct *work)
 	if (earliest != ULONG_MAX) {
 		_debug("reschedule reaper %ld", (long) earliest - now);
 		ASSERTCMP(earliest, >, now);
-		schedule_delayed_work(&rxrpc_connection_reap,
-				      (earliest - now) * HZ);
+		rxrpc_queue_delayed_work(&rxrpc_connection_reap,
+					 (earliest - now) * HZ);
 	}
 
 	/* then destroy all those pulled out */
@@ -889,7 +905,7 @@ void __exit rxrpc_destroy_all_connections(void)
 
 	rxrpc_connection_timeout = 0;
 	cancel_delayed_work(&rxrpc_connection_reap);
-	schedule_delayed_work(&rxrpc_connection_reap, 0);
+	rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
 
 	_leave("");
 }
diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/ar-connevent.c
index 1957d2f..434c1de 100644
--- a/net/rxrpc/ar-connevent.c
+++ b/net/rxrpc/ar-connevent.c
@@ -45,7 +45,7 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn, int state,
 				set_bit(RXRPC_CALL_CONN_ABORT, &call->events);
 			else
 				set_bit(RXRPC_CALL_RCVD_ABORT, &call->events);
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		}
 		write_unlock(&call->state_lock);
 	}
@@ -133,7 +133,7 @@ void rxrpc_call_is_secure(struct rxrpc_call *call)
 		read_lock(&call->state_lock);
 		if (call->state < RXRPC_CALL_COMPLETE &&
 		    !test_and_set_bit(RXRPC_CALL_SECURED, &call->events))
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		read_unlock(&call->state_lock);
 	}
 }
@@ -308,6 +308,22 @@ protocol_error:
 }
 
 /*
+ * put a packet up for transport-level abort
+ */
+void rxrpc_reject_packet(struct rxrpc_local *local, struct sk_buff *skb)
+{
+	CHECK_SLAB_OKAY(&local->usage);
+
+	if (!atomic_inc_not_zero(&local->usage)) {
+		printk("resurrected on reject\n");
+		BUG();
+	}
+
+	skb_queue_tail(&local->reject_queue, skb);
+	rxrpc_queue_work(&local->rejecter);
+}
+
+/*
  * reject packets through the local endpoint
  */
 void rxrpc_reject_packets(struct work_struct *work)
diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
index 8554c44..c28001b 100644
--- a/net/rxrpc/ar-error.c
+++ b/net/rxrpc/ar-error.c
@@ -111,7 +111,7 @@ void rxrpc_UDP_error_report(struct sock *sk)
 
 	/* pass the transport ref to error_handler to release */
 	skb_queue_tail(&trans->error_queue, skb);
-	schedule_work(&trans->error_handler);
+	rxrpc_queue_work(&trans->error_handler);
 
 	/* reset and regenerate socket error */
 	spin_lock_bh(&sk->sk_error_queue.lock);
@@ -235,7 +235,7 @@ void rxrpc_UDP_error_handler(struct work_struct *work)
 			    call->state < RXRPC_CALL_NETWORK_ERROR) {
 				call->state = RXRPC_CALL_NETWORK_ERROR;
 				set_bit(RXRPC_CALL_RCVD_ERROR, &call->events);
-				schedule_work(&call->processor);
+				rxrpc_queue_call(call);
 			}
 			write_unlock(&call->state_lock);
 			list_del_init(&call->error_link);
@@ -245,7 +245,7 @@ void rxrpc_UDP_error_handler(struct work_struct *work)
 	}
 
 	if (!skb_queue_empty(&trans->error_queue))
-		schedule_work(&trans->error_handler);
+		rxrpc_queue_work(&trans->error_handler);
 
 	rxrpc_free_skb(skb);
 	rxrpc_put_transport(trans);
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 64ae9fa..80c979d 100644
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
@@ -232,7 +238,7 @@ static int rxrpc_fast_process_data(struct rxrpc_call *call,
 		read_lock(&call->state_lock);
 		if (call->state < RXRPC_CALL_COMPLETE &&
 		    !test_and_set_bit(RXRPC_CALL_DRAIN_RX_OOS, &call->events))
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		read_unlock(&call->state_lock);
 	}
 
@@ -267,7 +273,7 @@ enqueue_packet:
 	atomic_inc(&call->ackr_not_idle);
 	read_lock(&call->state_lock);
 	if (call->state < RXRPC_CALL_DEAD)
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	read_unlock(&call->state_lock);
 	_leave(" = 0 [queued]");
 	return 0;
@@ -360,7 +366,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 			call->state = RXRPC_CALL_REMOTELY_ABORTED;
 			call->abort_code = abort_code;
 			set_bit(RXRPC_CALL_RCVD_ABORT, &call->events);
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		}
 		goto free_packet_unlock;
 
@@ -375,7 +381,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		case RXRPC_CALL_CLIENT_SEND_REQUEST:
 			call->state = RXRPC_CALL_SERVER_BUSY;
 			set_bit(RXRPC_CALL_RCVD_BUSY, &call->events);
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		case RXRPC_CALL_SERVER_BUSY:
 			goto free_packet_unlock;
 		default:
@@ -419,7 +425,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		read_lock_bh(&call->state_lock);
 		if (call->state < RXRPC_CALL_DEAD) {
 			skb_queue_tail(&call->rx_queue, skb);
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 			skb = NULL;
 		}
 		read_unlock_bh(&call->state_lock);
@@ -434,7 +440,7 @@ protocol_error_locked:
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
 		call->abort_code = RX_PROTOCOL_ERROR;
 		set_bit(RXRPC_CALL_ABORT, &call->events);
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 free_packet_unlock:
 	write_unlock_bh(&call->state_lock);
@@ -506,7 +512,7 @@ protocol_error:
 		call->state = RXRPC_CALL_LOCALLY_ABORTED;
 		call->abort_code = RX_PROTOCOL_ERROR;
 		set_bit(RXRPC_CALL_ABORT, &call->events);
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 	write_unlock_bh(&call->state_lock);
 	_leave("");
@@ -542,7 +548,7 @@ static void rxrpc_post_packet_to_call(struct rxrpc_connection *conn,
 	switch (call->state) {
 	case RXRPC_CALL_LOCALLY_ABORTED:
 		if (!test_and_set_bit(RXRPC_CALL_ABORT, &call->events))
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 	case RXRPC_CALL_REMOTELY_ABORTED:
 	case RXRPC_CALL_NETWORK_ERROR:
 	case RXRPC_CALL_DEAD:
@@ -591,7 +597,7 @@ dead_call:
 	    sp->hdr.seq == __constant_cpu_to_be32(1)) {
 		_debug("incoming call");
 		skb_queue_tail(&conn->trans->local->accept_queue, skb);
-		schedule_work(&conn->trans->local->acceptor);
+		rxrpc_queue_work(&conn->trans->local->acceptor);
 		goto done;
 	}
 
@@ -630,7 +636,7 @@ found_completed_call:
 	_debug("final ack again");
 	rxrpc_get_call(call);
 	set_bit(RXRPC_CALL_ACK_FINAL, &call->events);
-	schedule_work(&call->processor);
+	rxrpc_queue_call(call);
 
 free_unlock:
 	read_unlock(&call->state_lock);
@@ -651,7 +657,7 @@ static void rxrpc_post_packet_to_conn(struct rxrpc_connection *conn,
 
 	atomic_inc(&conn->usage);
 	skb_queue_tail(&conn->rx_queue, skb);
-	schedule_work(&conn->processor);
+	rxrpc_queue_conn(conn);
 }
 
 /*
@@ -767,7 +773,7 @@ cant_route_call:
 		if (sp->hdr.seq == __constant_cpu_to_be32(1)) {
 			_debug("first packet");
 			skb_queue_tail(&local->accept_queue, skb);
-			schedule_work(&local->acceptor);
+			rxrpc_queue_work(&local->acceptor);
 			rxrpc_put_local(local);
 			_leave(" [incoming]");
 			return;
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 7bfbf47..cb1eb49 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -19,8 +19,6 @@
 #define CHECK_SLAB_OKAY(X) do {} while(0)
 #endif
 
-extern atomic_t rxrpc_n_skbs;
-
 #define FCRYPT_BSIZE 8
 struct rxrpc_crypt {
 	union {
@@ -29,8 +27,12 @@ struct rxrpc_crypt {
 	};
 } __attribute__((aligned(8)));
 
-extern __be32 rxrpc_epoch;		/* local epoch for detecting local-end reset */
-extern atomic_t rxrpc_debug_id;		/* current debugging ID */
+#define rxrpc_queue_work(WS)	queue_work(rxrpc_workqueue, (WS))
+#define rxrpc_queue_delayed_work(WS,D)	\
+	queue_delayed_work(rxrpc_workqueue, (WS), (D))
+
+#define rxrpc_queue_call(CALL)	rxrpc_queue_work(&(CALL)->processor)
+#define rxrpc_queue_conn(CONN)	rxrpc_queue_work(&(CONN)->processor)
 
 /*
  * sk_state for RxRPC sockets
@@ -50,6 +52,7 @@ enum {
 struct rxrpc_sock {
 	/* WARNING: sk has to be the first member */
 	struct sock		sk;
+	rxrpc_interceptor_t	interceptor;	/* kernel service Rx interceptor function */
 	struct rxrpc_local	*local;		/* local endpoint */
 	struct rxrpc_transport	*trans;		/* transport handler */
 	struct rxrpc_conn_bundle *bundle;	/* virtual connection bundle */
@@ -91,16 +94,6 @@ struct rxrpc_skb_priv {
 
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
@@ -439,25 +432,20 @@ static inline void rxrpc_abort_call(struct rxrpc_call *call, u32 abort_code)
 }
 
 /*
- * put a packet up for transport-level abort
+ * af_rxrpc.c
  */
-static inline
-void rxrpc_reject_packet(struct rxrpc_local *local, struct sk_buff *skb)
-{
-	CHECK_SLAB_OKAY(&local->usage);
-	if (!atomic_inc_not_zero(&local->usage)) {
-		printk("resurrected on reject\n");
-		BUG();
-	}
-	skb_queue_tail(&local->reject_queue, skb);
-	schedule_work(&local->rejecter);
-}
+extern atomic_t rxrpc_n_skbs;
+extern __be32 rxrpc_epoch;
+extern atomic_t rxrpc_debug_id;
+extern struct workqueue_struct *rxrpc_workqueue;
 
 /*
  * ar-accept.c
  */
 extern void rxrpc_accept_incoming_calls(struct work_struct *);
-extern int rxrpc_accept_call(struct rxrpc_sock *, unsigned long);
+extern struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *,
+					    unsigned long);
+extern int rxrpc_reject_call(struct rxrpc_sock *);
 
 /*
  * ar-ack.c
@@ -514,6 +502,7 @@ rxrpc_incoming_connection(struct rxrpc_transport *, struct rxrpc_header *,
  * ar-connevent.c
  */
 extern void rxrpc_process_connection(struct work_struct *);
+extern void rxrpc_reject_packet(struct rxrpc_local *, struct sk_buff *);
 extern void rxrpc_reject_packets(struct work_struct *);
 
 /*
@@ -583,6 +572,7 @@ extern struct file_operations rxrpc_connection_seq_fops;
 /*
  * ar-recvmsg.c
  */
+extern void rxrpc_remove_user_ID(struct rxrpc_sock *, struct rxrpc_call *);
 extern int rxrpc_recvmsg(struct kiocb *, struct socket *, struct msghdr *,
 			 size_t, int);
 
diff --git a/net/rxrpc/ar-local.c b/net/rxrpc/ar-local.c
index a20a2c0..fe03f71 100644
--- a/net/rxrpc/ar-local.c
+++ b/net/rxrpc/ar-local.c
@@ -228,7 +228,7 @@ void rxrpc_put_local(struct rxrpc_local *local)
 	write_lock_bh(&rxrpc_local_lock);
 	if (unlikely(atomic_dec_and_test(&local->usage))) {
 		_debug("destroy local");
-		schedule_work(&local->destroyer);
+		rxrpc_queue_work(&local->destroyer);
 	}
 	write_unlock_bh(&rxrpc_local_lock);
 	_leave("");
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 491e47c..d2d0baa 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -113,7 +113,7 @@ static void rxrpc_send_abort(struct rxrpc_call *call, u32 abort_code)
 		clear_bit(RXRPC_CALL_RESEND_TIMER, &call->events);
 		clear_bit(RXRPC_CALL_ACK, &call->events);
 		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	}
 
 	write_unlock_bh(&call->state_lock);
@@ -194,6 +194,77 @@ int rxrpc_client_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
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
@@ -214,8 +285,13 @@ int rxrpc_server_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
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
@@ -363,7 +439,7 @@ static inline void rxrpc_instant_resend(struct rxrpc_call *call)
 		clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
 		if (call->state < RXRPC_CALL_COMPLETE &&
 		    !test_and_set_bit(RXRPC_CALL_RESEND_TIMER, &call->events))
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 	}
 	read_unlock_bh(&call->state_lock);
 }
diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/ar-peer.c
index 69ac355..d399de4 100644
--- a/net/rxrpc/ar-peer.c
+++ b/net/rxrpc/ar-peer.c
@@ -219,7 +219,7 @@ void rxrpc_put_peer(struct rxrpc_peer *peer)
 		return;
 	}
 
-	schedule_work(&peer->destroyer);
+	rxrpc_queue_work(&peer->destroyer);
 	_leave("");
 }
 
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index e947d5c..f19121d 100644
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
 
@@ -33,7 +33,7 @@ static void rxrpc_remove_user_ID(struct rxrpc_sock *rx, struct rxrpc_call *call)
 	read_lock_bh(&call->state_lock);
 	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
 	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
-		schedule_work(&call->processor);
+		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
 }
 
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
index d73f6fc..de755e0 100644
--- a/net/rxrpc/ar-skbuff.c
+++ b/net/rxrpc/ar-skbuff.c
@@ -36,7 +36,7 @@ static void rxrpc_request_final_ACK(struct rxrpc_call *call)
 		rxrpc_get_call(call);
 		set_bit(RXRPC_CALL_ACK_FINAL, &call->events);
 		if (try_to_del_timer_sync(&call->ack_timer) >= 0)
-			schedule_work(&call->processor);
+			rxrpc_queue_call(call);
 		break;
 
 	case RXRPC_CALL_SERVER_RECV_REQUEST:
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
diff --git a/net/rxrpc/ar-transport.c b/net/rxrpc/ar-transport.c
index 9b4e5cb..d43d78f 100644
--- a/net/rxrpc/ar-transport.c
+++ b/net/rxrpc/ar-transport.c
@@ -189,7 +189,7 @@ void rxrpc_put_transport(struct rxrpc_transport *trans)
 		/* let the reaper determine the timeout to avoid a race with
 		 * overextending the timeout if the reaper is running at the
 		 * same time */
-		schedule_delayed_work(&rxrpc_transport_reap, 0);
+		rxrpc_queue_delayed_work(&rxrpc_transport_reap, 0);
 	_leave("");
 }
 
@@ -243,8 +243,8 @@ static void rxrpc_transport_reaper(struct work_struct *work)
 	if (earliest != ULONG_MAX) {
 		_debug("reschedule reaper %ld", (long) earliest - now);
 		ASSERTCMP(earliest, >, now);
-		schedule_delayed_work(&rxrpc_transport_reap,
-				      (earliest - now) * HZ);
+		rxrpc_queue_delayed_work(&rxrpc_transport_reap,
+					 (earliest - now) * HZ);
 	}
 
 	/* then destroy all those pulled out */
@@ -270,7 +270,7 @@ void __exit rxrpc_destroy_all_transports(void)
 
 	rxrpc_transport_timeout = 0;
 	cancel_delayed_work(&rxrpc_transport_reap);
-	schedule_delayed_work(&rxrpc_transport_reap, 0);
+	rxrpc_queue_delayed_work(&rxrpc_transport_reap, 0);
 
 	_leave("");
 }

