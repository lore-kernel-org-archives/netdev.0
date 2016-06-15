From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 6/8] rxrpc: Use the peer record to distribute
 network errors
Date: Wed, 15 Jun 2016 17:42:20 +0100
Message-ID: <146600894033.18270.8699495867676359103.stgit@warthog.procyon.org.uk>
References: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the peer record to distribute network errors rather than the transport
object (which I want to get rid of).  An error from a particular peer
terminates all calls on that peer.

For future consideration:

 (1) For ICMP-induced errors it might be worth trying to extract the RxRPC
     header from the offending packet, if one is returned attached to the
     ICMP packet, to better direct the error.

     This may be overkill, though, since an ICMP packet would be expected
     to be relating to the destination port, machine or network.  RxRPC
     ABORT and BUSY packets give notice at RxRPC level.

 (2) To also abort connection-level communications (such as CHALLENGE
     packets) where indicted by an error - but that requires some revamping
     of the connection event handling first.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |   16 +++----
 net/rxrpc/call_event.c  |   15 +++++-
 net/rxrpc/call_object.c |    6 +--
 net/rxrpc/output.c      |    4 +-
 net/rxrpc/peer_event.c  |  109 ++++++++++++++++++++++-------------------------
 net/rxrpc/peer_object.c |    6 ++-
 net/rxrpc/transport.c   |   17 -------
 7 files changed, 79 insertions(+), 94 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 1e5c15632f49..a63bb7518fb5 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -189,7 +189,6 @@ struct rxrpc_local {
 	rwlock_t		services_lock;	/* lock for services list */
 	atomic_t		usage;
 	int			debug_id;	/* debug ID for printks */
-	volatile char		error_rcvd;	/* T if received ICMP error outstanding */
 	struct sockaddr_rxrpc	srx;		/* local address */
 };
 
@@ -203,14 +202,16 @@ struct rxrpc_peer {
 	unsigned long		hash_key;
 	struct hlist_node	hash_link;
 	struct rxrpc_local	*local;
-	struct list_head	error_targets;	/* targets for net error distribution */
+	struct hlist_head	error_targets;	/* targets for net error distribution */
+	struct work_struct	error_distributor;
 	spinlock_t		lock;		/* access lock */
 	unsigned int		if_mtu;		/* interface MTU for this peer */
 	unsigned int		mtu;		/* network MTU for this peer */
 	unsigned int		maxdata;	/* data size (MTU - hdrsize) */
 	unsigned short		hdrsize;	/* header size (IP + UDP + RxRPC) */
 	int			debug_id;	/* debug ID for printks */
-	int			net_error;	/* network error distributed */
+	int			error_report;	/* Net (+0) or local (+1000000) to distribute */
+#define RXRPC_LOCAL_ERROR_OFFSET 1000000
 	struct sockaddr_rxrpc	srx;		/* remote address */
 
 	/* calculated RTT cache */
@@ -229,12 +230,10 @@ struct rxrpc_peer {
 struct rxrpc_transport {
 	struct rxrpc_local	*local;		/* local transport endpoint */
 	struct rxrpc_peer	*peer;		/* remote transport endpoint */
-	struct work_struct	error_handler;	/* network error distributor */
 	struct rb_root		bundles;	/* client connection bundles on this transport */
 	struct rb_root		client_conns;	/* client connections on this transport */
 	struct rb_root		server_conns;	/* server connections on this transport */
 	struct list_head	link;		/* link in master session list */
-	struct sk_buff_head	error_queue;	/* error packets awaiting processing */
 	unsigned long		put_time;	/* time at which to reap */
 	spinlock_t		client_lock;	/* client connection allocation lock */
 	rwlock_t		conn_lock;	/* lock for active/dead connections */
@@ -393,7 +392,7 @@ struct rxrpc_call {
 	struct work_struct	destroyer;	/* call destroyer */
 	struct work_struct	processor;	/* packet processor and ACK generator */
 	struct list_head	link;		/* link in master call list */
-	struct list_head	error_link;	/* link in error distribution list */
+	struct hlist_node	error_link;	/* link in error distribution list */
 	struct list_head	accept_link;	/* calls awaiting acceptance */
 	struct rb_node		sock_node;	/* node in socket call tree */
 	struct rb_node		conn_node;	/* node in connection call tree */
@@ -411,7 +410,8 @@ struct rxrpc_call {
 	atomic_t		sequence;	/* Tx data packet sequence counter */
 	u32			local_abort;	/* local abort code */
 	u32			remote_abort;	/* remote abort code */
-	int			error;		/* local error incurred */
+	int			error_report;	/* Network error (ICMP/local transport) */
+	int			error;		/* Local error incurred */
 	enum rxrpc_call_state	state : 8;	/* current state of call */
 	int			debug_id;	/* debug ID for printks */
 	u8			channel;	/* connection channel occupied by this call */
@@ -609,7 +609,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *, struct msghdr *, size_t);
  * peer_event.c
  */
 void rxrpc_error_report(struct sock *);
-void rxrpc_UDP_error_handler(struct work_struct *);
+void rxrpc_peer_error_distributor(struct work_struct *);
 
 /*
  * peer_object.c
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 18381783c2b1..e610b106c913 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -864,17 +864,24 @@ void rxrpc_process_call(struct work_struct *work)
 	}
 
 	if (test_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events)) {
+		enum rxrpc_skb_mark mark;
 		int error;
 
 		clear_bit(RXRPC_CALL_EV_CONN_ABORT, &call->events);
 		clear_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events);
 		clear_bit(RXRPC_CALL_EV_ABORT, &call->events);
 
-		error = call->conn->trans->peer->net_error;
-		_debug("post net error %d", error);
+		error = call->error_report;
+		if (error < RXRPC_LOCAL_ERROR_OFFSET) {
+			mark = RXRPC_SKB_MARK_NET_ERROR;
+			_debug("post net error %d", error);
+		} else {
+			mark = RXRPC_SKB_MARK_LOCAL_ERROR;
+			error -= RXRPC_LOCAL_ERROR_OFFSET;
+			_debug("post net local error %d", error);
+		}
 
-		if (rxrpc_post_message(call, RXRPC_SKB_MARK_NET_ERROR,
-				       error, true) < 0)
+		if (rxrpc_post_message(call, mark, error, true) < 0)
 			goto no_mem;
 		clear_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events);
 		goto kill_ACKs;
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 68125dc4cb7c..8b4d47b3ccac 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -334,7 +334,7 @@ static struct rxrpc_call *rxrpc_alloc_client_call(
 	rxrpc_call_hash_add(call);
 
 	spin_lock(&call->conn->trans->peer->lock);
-	list_add(&call->error_link, &call->conn->trans->peer->error_targets);
+	hlist_add_head(&call->error_link, &call->conn->trans->peer->error_targets);
 	spin_unlock(&call->conn->trans->peer->lock);
 
 	call->lifetimer.expires = jiffies + rxrpc_max_call_lifetime;
@@ -516,7 +516,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	write_unlock_bh(&conn->lock);
 
 	spin_lock(&conn->trans->peer->lock);
-	list_add(&call->error_link, &conn->trans->peer->error_targets);
+	hlist_add_head(&call->error_link, &conn->trans->peer->error_targets);
 	spin_unlock(&conn->trans->peer->lock);
 
 	write_lock_bh(&rxrpc_call_lock);
@@ -812,7 +812,7 @@ static void rxrpc_cleanup_call(struct rxrpc_call *call)
 
 	if (call->conn) {
 		spin_lock(&call->conn->trans->peer->lock);
-		list_del(&call->error_link);
+		hlist_del_init(&call->error_link);
 		spin_unlock(&call->conn->trans->peer->lock);
 
 		write_lock_bh(&call->conn->lock);
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 2e3c4064e29c..e6fb3863b0bc 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -707,7 +707,9 @@ out:
 call_aborted:
 	rxrpc_free_skb(skb);
 	if (call->state == RXRPC_CALL_NETWORK_ERROR)
-		ret = call->conn->trans->peer->net_error;
+		ret = call->error_report < RXRPC_LOCAL_ERROR_OFFSET ?
+			call->error_report :
+			call->error_report - RXRPC_LOCAL_ERROR_OFFSET;
 	else
 		ret = -ECONNABORTED;
 	_leave(" = %d", ret);
diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index 31c440acd8c9..8940674b5e08 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -1,4 +1,4 @@
-/* Error message handling (ICMP)
+/* Peer event handling, typically ICMP messages.
  *
  * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -22,6 +22,8 @@
 #include <net/ip.h>
 #include "ar-internal.h"
 
+static void rxrpc_store_error(struct rxrpc_peer *, struct sock_exterr_skb *);
+
 /*
  * Find the peer associated with an ICMP packet.
  */
@@ -111,12 +113,11 @@ static void rxrpc_adjust_mtu(struct rxrpc_peer *peer, struct sock_exterr_skb *se
 }
 
 /*
- * handle an error received on the local endpoint
+ * Handle an error received on the local endpoint.
  */
 void rxrpc_error_report(struct sock *sk)
 {
 	struct sock_exterr_skb *serr;
-	struct rxrpc_transport *trans;
 	struct rxrpc_local *local = sk->sk_user_data;
 	struct rxrpc_peer *peer;
 	struct sk_buff *skb;
@@ -148,57 +149,37 @@ void rxrpc_error_report(struct sock *sk)
 		return;
 	}
 
-	trans = rxrpc_find_transport(local, peer);
-	if (!trans) {
-		rcu_read_unlock();
-		rxrpc_put_peer(peer);
-		rxrpc_free_skb(skb);
-		_leave(" [no trans]");
-		return;
-	}
-
 	if ((serr->ee.ee_origin == SO_EE_ORIGIN_ICMP &&
 	     serr->ee.ee_type == ICMP_DEST_UNREACH &&
 	     serr->ee.ee_code == ICMP_FRAG_NEEDED)) {
 		rxrpc_adjust_mtu(peer, serr);
+		rcu_read_unlock();
 		rxrpc_free_skb(skb);
-		skb = NULL;
-		goto out;
+		rxrpc_put_peer(peer);
+		_leave(" [MTU update]");
+		return;
 	}
 
-out:
+	rxrpc_store_error(peer, serr);
 	rcu_read_unlock();
-	rxrpc_put_peer(peer);
+	rxrpc_free_skb(skb);
 
-	if (skb) {
-		/* pass the transport ref to error_handler to release */
-		skb_queue_tail(&trans->error_queue, skb);
-		rxrpc_queue_work(&trans->error_handler);
-	} else {
-		rxrpc_put_transport(trans);
-	}
+	/* The ref we obtained is passed off to the work item */
+	rxrpc_queue_work(&peer->error_distributor);
 	_leave("");
 }
 
 /*
- * deal with UDP error messages
+ * Map an error report to error codes on the peer record.
  */
-void rxrpc_UDP_error_handler(struct work_struct *work)
+static void rxrpc_store_error(struct rxrpc_peer *peer,
+			      struct sock_exterr_skb *serr)
 {
 	struct sock_extended_err *ee;
-	struct sock_exterr_skb *serr;
-	struct rxrpc_transport *trans =
-		container_of(work, struct rxrpc_transport, error_handler);
-	struct sk_buff *skb;
 	int err;
 
 	_enter("");
 
-	skb = skb_dequeue(&trans->error_queue);
-	if (!skb)
-		return;
-
-	serr = SKB_EXT_ERR(skb);
 	ee = &serr->ee;
 
 	_net("Rx Error o=%d t=%d c=%d e=%d",
@@ -244,47 +225,57 @@ void rxrpc_UDP_error_handler(struct work_struct *work)
 		}
 		break;
 
+	case SO_EE_ORIGIN_NONE:
 	case SO_EE_ORIGIN_LOCAL:
 		_proto("Rx Received local error { error=%d }", err);
+		err += RXRPC_LOCAL_ERROR_OFFSET;
 		break;
 
-	case SO_EE_ORIGIN_NONE:
 	case SO_EE_ORIGIN_ICMP6:
 	default:
 		_proto("Rx Received error report { orig=%u }", ee->ee_origin);
 		break;
 	}
 
-	/* terminate all the affected calls if there's an unrecoverable
-	 * error */
-	if (err) {
-		struct rxrpc_call *call, *_n;
+	peer->error_report = err;
+}
+
+/*
+ * Distribute an error that occurred on a peer
+ */
+void rxrpc_peer_error_distributor(struct work_struct *work)
+{
+	struct rxrpc_peer *peer =
+		container_of(work, struct rxrpc_peer, error_distributor);
+	struct rxrpc_call *call;
+	int error_report;
+
+	_enter("");
 
-		_debug("ISSUE ERROR %d", err);
+	error_report = READ_ONCE(peer->error_report);
 
-		spin_lock_bh(&trans->peer->lock);
-		trans->peer->net_error = err;
+	_debug("ISSUE ERROR %d", error_report);
 
-		list_for_each_entry_safe(call, _n, &trans->peer->error_targets,
-					 error_link) {
-			write_lock(&call->state_lock);
-			if (call->state != RXRPC_CALL_COMPLETE &&
-			    call->state < RXRPC_CALL_NETWORK_ERROR) {
-				call->state = RXRPC_CALL_NETWORK_ERROR;
-				set_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events);
-				rxrpc_queue_call(call);
-			}
-			write_unlock(&call->state_lock);
-			list_del_init(&call->error_link);
-		}
+	spin_lock_bh(&peer->lock);
 
-		spin_unlock_bh(&trans->peer->lock);
+	while (!hlist_empty(&peer->error_targets)) {
+		call = hlist_entry(peer->error_targets.first,
+				   struct rxrpc_call, error_link);
+		hlist_del_init(&call->error_link);
+
+		write_lock(&call->state_lock);
+		if (call->state != RXRPC_CALL_COMPLETE &&
+		    call->state < RXRPC_CALL_NETWORK_ERROR) {
+			call->error_report = error_report;
+			call->state = RXRPC_CALL_NETWORK_ERROR;
+			set_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events);
+			rxrpc_queue_call(call);
+		}
+		write_unlock(&call->state_lock);
 	}
 
-	if (!skb_queue_empty(&trans->error_queue))
-		rxrpc_queue_work(&trans->error_handler);
+	spin_unlock_bh(&peer->lock);
 
-	rxrpc_free_skb(skb);
-	rxrpc_put_transport(trans);
+	rxrpc_put_peer(peer);
 	_leave("");
 }
diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index 7fc50dc7d333..faf222c21698 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -182,7 +182,9 @@ struct rxrpc_peer *rxrpc_alloc_peer(struct rxrpc_local *local, gfp_t gfp)
 	if (peer) {
 		atomic_set(&peer->usage, 1);
 		peer->local = local;
-		INIT_LIST_HEAD(&peer->error_targets);
+		INIT_HLIST_HEAD(&peer->error_targets);
+		INIT_WORK(&peer->error_distributor,
+			  &rxrpc_peer_error_distributor);
 		spin_lock_init(&peer->lock);
 		peer->debug_id = atomic_inc_return(&rxrpc_debug_id);
 	}
@@ -298,7 +300,7 @@ struct rxrpc_peer *rxrpc_lookup_peer(struct rxrpc_local *local,
  */
 void __rxrpc_put_peer(struct rxrpc_peer *peer)
 {
-	ASSERT(list_empty(&peer->error_targets));
+	ASSERT(hlist_empty(&peer->error_targets));
 
 	spin_lock(&rxrpc_peer_hash_lock);
 	hash_del_rcu(&peer->hash_link);
diff --git a/net/rxrpc/transport.c b/net/rxrpc/transport.c
index d33387dec0ce..24c71218a6f8 100644
--- a/net/rxrpc/transport.c
+++ b/net/rxrpc/transport.c
@@ -49,26 +49,11 @@ static struct rxrpc_transport *rxrpc_alloc_transport(struct rxrpc_local *local,
 		trans->bundles = RB_ROOT;
 		trans->client_conns = RB_ROOT;
 		trans->server_conns = RB_ROOT;
-		skb_queue_head_init(&trans->error_queue);
 		spin_lock_init(&trans->client_lock);
 		rwlock_init(&trans->conn_lock);
 		atomic_set(&trans->usage, 1);
 		trans->conn_idcounter = peer->srx.srx_service << 16;
 		trans->debug_id = atomic_inc_return(&rxrpc_debug_id);
-
-		if (peer->srx.transport.family == AF_INET) {
-			switch (peer->srx.transport_type) {
-			case SOCK_DGRAM:
-				INIT_WORK(&trans->error_handler,
-					  rxrpc_UDP_error_handler);
-				break;
-			default:
-				BUG();
-				break;
-			}
-		} else {
-			BUG();
-		}
 	}
 
 	_leave(" = %p", trans);
@@ -210,8 +195,6 @@ static void rxrpc_cleanup_transport(struct rxrpc_transport *trans)
 {
 	_net("DESTROY TRANS %d", trans->debug_id);
 
-	rxrpc_purge_queue(&trans->error_queue);
-
 	rxrpc_put_local(trans->local);
 	rxrpc_put_peer(trans->peer);
 	kfree(trans);
