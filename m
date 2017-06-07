Return-Path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59572 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751682AbdFGVNK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 17:13:10 -0400
Subject: [PATCH net-next 3/3] rxrpc: Provide a cmsg to specify the amount of
 Tx data for a call
From: David Howells <dhowells@redhat.com>
To: netdev@vger.kernel.org
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
Date: Wed, 07 Jun 2017 22:12:52 +0100
Message-ID: <149686997270.21359.9167134783033151421.stgit@warthog.procyon.org.uk>
In-Reply-To: <149686995195.21359.17550471913376009423.stgit@warthog.procyon.org.uk>
References: <149686995195.21359.17550471913376009423.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide a control message that can be specified on the first sendmsg() of a
client call or the first sendmsg() of a service response to indicate the
total length of the data to be transmitted for that call.

Currently, because the length of the payload of an encrypted DATA packet is
encrypted in front of the data, the packet cannot be encrypted until we
know how much data it will hold.

By specifying the length at the beginning of the transmit phase, each DATA
packet length can be set before we start loading data from userspace (where
several sendmsg() calls may contribute to a particular packet).

An error will be returned if too little or too much data is presented in
the Tx phase.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |   34 +++++++++++++++++++++++
 fs/afs/rxrpc.c                     |   18 +++++++++++-
 include/linux/rxrpc.h              |    1 +
 include/net/af_rxrpc.h             |    2 +
 net/rxrpc/af_rxrpc.c               |    5 +++
 net/rxrpc/ar-internal.h            |    3 +-
 net/rxrpc/call_object.c            |    3 ++
 net/rxrpc/sendmsg.c                |   54 +++++++++++++++++++++++++++++++++++-
 8 files changed, 115 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index bce8e10a2a8e..8c70ba5dee4d 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -327,6 +327,7 @@ calls, to invoke certain actions and to report certain conditions.  These are:
 	RXRPC_ACCEPT		s-- n/a		Accept new call
 	RXRPC_EXCLUSIVE_CALL	s-- n/a		Make an exclusive client call
 	RXRPC_UPGRADE_SERVICE	s-- n/a		Client call can be upgraded
+	RXRPC_TX_LENGTH		s-- data len	Total length of Tx data
 
 	(SRT = usable in Sendmsg / delivered by Recvmsg / Terminal message)
 
@@ -406,6 +407,19 @@ calls, to invoke certain actions and to report certain conditions.  These are:
      future communication to that server and RXRPC_UPGRADE_SERVICE should no
      longer be set.
 
+ (*) RXRPC_TX_LENGTH
+
+     This is used to inform the kernel of the total amount of data that is
+     going to be transmitted by a call (whether in a client request or a
+     service response).  If given, it allows the kernel to encrypt from the
+     userspace buffer directly to the packet buffers, rather than copying into
+     the buffer and then encrypting in place.  This may only be given with the
+     first sendmsg() providing data for a call.  EMSGSIZE will be generated if
+     the amount of data actually given is different.
+
+     This takes a parameter of __s64 type that indicates how much will be
+     transmitted.  This may not be less than zero.
+
 The symbol RXRPC__SUPPORTED is defined as one more than the highest control
 message type supported.  At run time this can be queried by means of the
 RXRPC_SUPPORTED_CMSG socket option (see below).
@@ -577,6 +591,9 @@ A client would issue an operation by:
      MSG_MORE should be set in msghdr::msg_flags on all but the last part of
      the request.  Multiple requests may be made simultaneously.
 
+     An RXRPC_TX_LENGTH control message can also be specified on the first
+     sendmsg() call.
+
      If a call is intended to go to a destination other than the default
      specified through connect(), then msghdr::msg_name should be set on the
      first request message of that call.
@@ -764,6 +781,7 @@ The kernel interface functions are as follows:
 				struct sockaddr_rxrpc *srx,
 				struct key *key,
 				unsigned long user_call_ID,
+				s64 tx_total_len,
 				gfp_t gfp);
 
      This allocates the infrastructure to make a new RxRPC call and assigns
@@ -780,6 +798,11 @@ The kernel interface functions are as follows:
      control data buffer.  It is entirely feasible to use this to point to a
      kernel data structure.
 
+     tx_total_len is the amount of data the caller is intending to transmit
+     with this call (or -1 if unknown at this point).  Setting the data size
+     allows the kernel to encrypt directly to the packet buffers, thereby
+     saving a copy.  The value may not be less than -1.
+
      If this function is successful, an opaque reference to the RxRPC call is
      returned.  The caller now holds a reference on this and it must be
      properly ended.
@@ -931,6 +954,17 @@ The kernel interface functions are as follows:
 
      This is used to find the remote peer address of a call.
 
+ (*) Set the total transmit data size on a call.
+
+	void rxrpc_kernel_set_tx_length(struct socket *sock,
+					struct rxrpc_call *call,
+					s64 tx_total_len);
+
+     This sets the amount of data that the caller is intending to transmit on a
+     call.  It's intended to be used for setting the reply size as the request
+     size should be set when the call is begun.  tx_total_len may not be less
+     than zero.
+
 
 =======================
 CONFIGURABLE PARAMETERS
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index d5990eb160bd..02781e78ffb6 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -341,6 +341,7 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	struct msghdr msg;
 	struct kvec iov[1];
 	size_t offset;
+	s64 tx_total_len;
 	u32 abort_code;
 	int ret;
 
@@ -364,9 +365,20 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 	srx.transport.sin.sin_port = call->port;
 	memcpy(&srx.transport.sin.sin_addr, addr, 4);
 
+	/* Work out the length we're going to transmit.  This is awkward for
+	 * calls such as FS.StoreData where there's an extra injection of data
+	 * after the initial fixed part.
+	 */
+	tx_total_len = call->request_size;
+	if (call->send_pages) {
+		tx_total_len += call->last_to - call->first_offset;
+		tx_total_len += (call->last - call->first) * PAGE_SIZE;
+	}
+
 	/* create a call */
 	rxcall = rxrpc_kernel_begin_call(afs_socket, &srx, call->key,
-					 (unsigned long) call, gfp,
+					 (unsigned long)call,
+					 tx_total_len, gfp,
 					 (async ?
 					  afs_wake_up_async_call :
 					  afs_wake_up_call_waiter));
@@ -738,6 +750,8 @@ void afs_send_empty_reply(struct afs_call *call)
 
 	_enter("");
 
+	rxrpc_kernel_set_tx_length(afs_socket, call->rxcall, 0);
+
 	msg.msg_name		= NULL;
 	msg.msg_namelen		= 0;
 	iov_iter_kvec(&msg.msg_iter, WRITE | ITER_KVEC, NULL, 0, 0);
@@ -772,6 +786,8 @@ void afs_send_simple_reply(struct afs_call *call, const void *buf, size_t len)
 
 	_enter("");
 
+	rxrpc_kernel_set_tx_length(afs_socket, call->rxcall, len);
+
 	iov[0].iov_base		= (void *) buf;
 	iov[0].iov_len		= len;
 	msg.msg_name		= NULL;
diff --git a/include/linux/rxrpc.h b/include/linux/rxrpc.h
index bdd3175b9a48..7343f71783dc 100644
--- a/include/linux/rxrpc.h
+++ b/include/linux/rxrpc.h
@@ -57,6 +57,7 @@ enum rxrpc_cmsg_type {
 	RXRPC_ACCEPT		= 9,	/* s-: [Service] accept request */
 	RXRPC_EXCLUSIVE_CALL	= 10,	/* s-: Call should be on exclusive connection */
 	RXRPC_UPGRADE_SERVICE	= 11,	/* s-: Request service upgrade for client call */
+	RXRPC_TX_LENGTH		= 12,	/* s-: Total length of Tx data */
 	RXRPC__SUPPORTED
 };
 
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index b5f5187f488c..c172709787af 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -33,6 +33,7 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *,
 					   struct sockaddr_rxrpc *,
 					   struct key *,
 					   unsigned long,
+					   s64,
 					   gfp_t,
 					   rxrpc_notify_rx_t);
 int rxrpc_kernel_send_data(struct socket *, struct rxrpc_call *,
@@ -46,5 +47,6 @@ void rxrpc_kernel_get_peer(struct socket *, struct rxrpc_call *,
 			   struct sockaddr_rxrpc *);
 int rxrpc_kernel_charge_accept(struct socket *, rxrpc_notify_rx_t,
 			       rxrpc_user_attach_call_t, unsigned long, gfp_t);
+void rxrpc_kernel_set_tx_length(struct socket *, struct rxrpc_call *, s64);
 
 #endif /* _NET_RXRPC_H */
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 44a52b82bb5d..58ae0db52ea1 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -262,6 +262,7 @@ static int rxrpc_listen(struct socket *sock, int backlog)
  * @srx: The address of the peer to contact
  * @key: The security context to use (defaults to socket setting)
  * @user_call_ID: The ID to use
+ * @tx_total_len: Total length of data to transmit during the call (or -1)
  * @gfp: The allocation constraints
  * @notify_rx: Where to send notifications instead of socket queue
  *
@@ -276,6 +277,7 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 					   struct sockaddr_rxrpc *srx,
 					   struct key *key,
 					   unsigned long user_call_ID,
+					   s64 tx_total_len,
 					   gfp_t gfp,
 					   rxrpc_notify_rx_t notify_rx)
 {
@@ -303,7 +305,8 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 	cp.security_level	= 0;
 	cp.exclusive		= false;
 	cp.service_id		= srx->srx_service;
-	call = rxrpc_new_client_call(rx, &cp, srx, user_call_ID, gfp);
+	call = rxrpc_new_client_call(rx, &cp, srx, user_call_ID, tx_total_len,
+				     gfp);
 	/* The socket has been unlocked. */
 	if (!IS_ERR(call))
 		call->notify_rx = notify_rx;
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index e9b536cb0acf..adbf37946450 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -528,6 +528,7 @@ struct rxrpc_call {
 	struct rb_node		sock_node;	/* Node in rx->calls */
 	struct sk_buff		*tx_pending;	/* Tx socket buffer being filled */
 	wait_queue_head_t	waitq;		/* Wait queue for channel or Tx */
+	s64			tx_total_len;	/* Total length left to be transmitted (or -1) */
 	__be32			crypto_buf[2];	/* Temporary packet crypto buffer */
 	unsigned long		user_call_ID;	/* user-defined call ID */
 	unsigned long		flags;
@@ -683,7 +684,7 @@ struct rxrpc_call *rxrpc_alloc_call(gfp_t);
 struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *,
 					 struct rxrpc_conn_parameters *,
 					 struct sockaddr_rxrpc *,
-					 unsigned long, gfp_t);
+					 unsigned long, s64, gfp_t);
 void rxrpc_incoming_call(struct rxrpc_sock *, struct rxrpc_call *,
 			 struct sk_buff *);
 void rxrpc_release_call(struct rxrpc_sock *, struct rxrpc_call *);
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 692110808baa..423030fd93be 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -127,6 +127,7 @@ struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 	rwlock_init(&call->state_lock);
 	atomic_set(&call->usage, 1);
 	call->debug_id = atomic_inc_return(&rxrpc_debug_id);
+	call->tx_total_len = -1;
 
 	memset(&call->sock_node, 0xed, sizeof(call->sock_node));
 
@@ -201,6 +202,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 					 struct rxrpc_conn_parameters *cp,
 					 struct sockaddr_rxrpc *srx,
 					 unsigned long user_call_ID,
+					 s64 tx_total_len,
 					 gfp_t gfp)
 	__releases(&rx->sk.sk_lock.slock)
 {
@@ -219,6 +221,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 		return call;
 	}
 
+	call->tx_total_len = tx_total_len;
 	trace_rxrpc_call(call, rxrpc_call_new_client, atomic_read(&call->usage),
 			 here, (const void *)user_call_ID);
 
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index d939a5b1abc3..2e636a525a65 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -29,6 +29,7 @@ enum rxrpc_command {
 };
 
 struct rxrpc_send_params {
+	s64			tx_total_len;	/* Total Tx data length (if send data) */
 	unsigned long		user_call_ID;	/* User's call ID */
 	u32			abort_code;	/* Abort code to Tx (if abort) */
 	enum rxrpc_command	command : 8;	/* The command to implement */
@@ -207,6 +208,13 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 	more = msg->msg_flags & MSG_MORE;
 
+	if (call->tx_total_len != -1) {
+		if (len > call->tx_total_len)
+			return -EMSGSIZE;
+		if (!more && len != call->tx_total_len)
+			return -EMSGSIZE;
+	}
+
 	skb = call->tx_pending;
 	call->tx_pending = NULL;
 	rxrpc_see_skb(skb, rxrpc_skb_tx_seen);
@@ -299,6 +307,8 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 			sp->remain -= copy;
 			skb->mark += copy;
 			copied += copy;
+			if (call->tx_total_len != -1)
+				call->tx_total_len -= copy;
 		}
 
 		/* check for the far side aborting the call or a network error
@@ -436,6 +446,14 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg, struct rxrpc_send_params *p)
 				return -EINVAL;
 			break;
 
+		case RXRPC_TX_LENGTH:
+			if (p->tx_total_len != -1 || len != sizeof(__s64))
+				return -EINVAL;
+			p->tx_total_len = *(__s64 *)CMSG_DATA(cmsg);
+			if (p->tx_total_len < 0)
+				return -EINVAL;
+			break;
+
 		default:
 			return -EINVAL;
 		}
@@ -443,6 +461,8 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg, struct rxrpc_send_params *p)
 
 	if (!got_user_ID)
 		return -EINVAL;
+	if (p->tx_total_len != -1 && p->command != RXRPC_CMD_SEND_DATA)
+		return -EINVAL;
 	_leave(" = 0");
 	return 0;
 }
@@ -481,7 +501,8 @@ rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 	cp.exclusive		= rx->exclusive | p->exclusive;
 	cp.upgrade		= p->upgrade;
 	cp.service_id		= srx->srx_service;
-	call = rxrpc_new_client_call(rx, &cp, srx, p->user_call_ID, GFP_KERNEL);
+	call = rxrpc_new_client_call(rx, &cp, srx, p->user_call_ID,
+				     p->tx_total_len, GFP_KERNEL);
 	/* The socket is now unlocked */
 
 	_leave(" = %p\n", call);
@@ -501,6 +522,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 	int ret;
 
 	struct rxrpc_send_params p = {
+		.tx_total_len	= -1,
 		.user_call_ID	= 0,
 		.abort_code	= 0,
 		.command	= RXRPC_CMD_SEND_DATA,
@@ -555,6 +577,15 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 			ret = -ERESTARTSYS;
 			goto error_put;
 		}
+
+		if (p.tx_total_len != -1) {
+			ret = -EINVAL;
+			if (call->tx_total_len != -1 ||
+			    call->tx_pending ||
+			    call->tx_top != 0)
+				goto error_put;
+			call->tx_total_len = p.tx_total_len;
+		}
 	}
 
 	state = READ_ONCE(call->state);
@@ -672,5 +703,24 @@ bool rxrpc_kernel_abort_call(struct socket *sock, struct rxrpc_call *call,
 	mutex_unlock(&call->user_mutex);
 	return aborted;
 }
-
 EXPORT_SYMBOL(rxrpc_kernel_abort_call);
+
+/**
+ * rxrpc_kernel_set_tx_length - Set the total Tx length on a call
+ * @sock: The socket the call is on
+ * @call: The call to be informed
+ * @tx_total_len: The amount of data to be transmitted for this call
+ *
+ * Allow a kernel service to set the total transmit length on a call.  This
+ * allows buffer-to-packet encrypt-and-copy to be performed.
+ *
+ * This function is primarily for use for setting the reply length since the
+ * request length can be set when beginning the call.
+ */
+void rxrpc_kernel_set_tx_length(struct socket *sock, struct rxrpc_call *call,
+				s64 tx_total_len)
+{
+	WARN_ON(call->tx_total_len != -1);
+	call->tx_total_len = tx_total_len;
+}
+EXPORT_SYMBOL(rxrpc_kernel_set_tx_length);
