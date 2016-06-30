From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 15/19] rxrpc: Move peer lookup from call-accept to
 new-incoming-conn
Date: Thu, 30 Jun 2016 15:12:29 +0100
Message-ID: <146729594992.26306.7455044215916160739.stgit@warthog.procyon.org.uk>
References: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the lookup of a peer from a call that's being accepted into the
function that creates a new incoming connection.  This will allow us to
avoid incrementing the peer's usage count in some cases in future.

Note that I haven't bother to integrate rxrpc_get_addr_from_skb() with
rxrpc_extract_addr_from_skb() as I'm going to delete the former in the very
near future.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h  |    3 ++-
 net/rxrpc/call_accept.c  |   31 +++++++------------------------
 net/rxrpc/conn_service.c |   11 ++++++++++-
 net/rxrpc/utils.c        |   32 ++++++++++++++++++++++++++++++++
 4 files changed, 51 insertions(+), 26 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 2495c4facf51..7d87cace0177 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -609,7 +609,7 @@ static inline void rxrpc_queue_conn(struct rxrpc_connection *conn)
  * conn_service.c
  */
 struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *,
-						   struct rxrpc_peer *,
+						   struct sockaddr_rxrpc *,
 						   struct sk_buff *);
 
 /*
@@ -775,6 +775,7 @@ static inline void rxrpc_sysctl_exit(void) {}
  */
 void rxrpc_get_addr_from_skb(struct rxrpc_local *, const struct sk_buff *,
 			     struct sockaddr_rxrpc *);
+int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *, struct sk_buff *);
 
 /*
  * debug tracing
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 5367dbe9b96f..0b2832141bd0 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -75,7 +75,6 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 {
 	struct rxrpc_connection *conn;
 	struct rxrpc_skb_priv *sp, *nsp;
-	struct rxrpc_peer *peer;
 	struct rxrpc_call *call;
 	struct sk_buff *notification;
 	int ret;
@@ -94,15 +93,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 	rxrpc_new_skb(notification);
 	notification->mark = RXRPC_SKB_MARK_NEW_CALL;
 
-	peer = rxrpc_lookup_peer(local, srx, GFP_NOIO);
-	if (!peer) {
-		_debug("no peer");
-		ret = -EBUSY;
-		goto error;
-	}
-
-	conn = rxrpc_incoming_connection(local, peer, skb);
-	rxrpc_put_peer(peer);
+	conn = rxrpc_incoming_connection(local, srx, skb);
 	if (IS_ERR(conn)) {
 		_debug("no conn");
 		ret = PTR_ERR(conn);
@@ -226,20 +217,8 @@ void rxrpc_accept_incoming_calls(struct rxrpc_local *local)
 	whdr._rsvd	= 0;
 	whdr.serviceId	= htons(sp->hdr.serviceId);
 
-	/* determine the remote address */
-	memset(&srx, 0, sizeof(srx));
-	srx.srx_family = AF_RXRPC;
-	srx.transport.family = local->srx.transport.family;
-	srx.transport_type = local->srx.transport_type;
-	switch (srx.transport.family) {
-	case AF_INET:
-		srx.transport_len = sizeof(struct sockaddr_in);
-		srx.transport.sin.sin_port = udp_hdr(skb)->source;
-		srx.transport.sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
-		break;
-	default:
-		goto busy;
-	}
+	if (rxrpc_extract_addr_from_skb(&srx, skb) < 0)
+		goto drop;
 
 	/* get the socket providing the service */
 	read_lock_bh(&local->services_lock);
@@ -285,6 +264,10 @@ busy:
 	rxrpc_free_skb(skb);
 	return;
 
+drop:
+	rxrpc_free_skb(skb);
+	return;
+
 invalid_service:
 	skb->priority = RX_INVALID_OPERATION;
 	rxrpc_reject_packet(local, skb);
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index 2536d5276f67..3f0242423a66 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -16,11 +16,12 @@
  * get a record of an incoming connection
  */
 struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
-						   struct rxrpc_peer *peer,
+						   struct sockaddr_rxrpc *srx,
 						   struct sk_buff *skb)
 {
 	struct rxrpc_connection *conn, *candidate = NULL;
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	struct rxrpc_peer *peer;
 	struct rb_node *p, **pp;
 	const char *new = "old";
 	__be32 epoch;
@@ -28,6 +29,12 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
 
 	_enter("");
 
+	peer = rxrpc_lookup_peer(local, srx, GFP_NOIO);
+	if (!peer) {
+		_debug("no peer");
+		return ERR_PTR(-EBUSY);
+	}
+
 	ASSERT(sp->hdr.flags & RXRPC_CLIENT_INITIATED);
 
 	epoch = sp->hdr.epoch;
@@ -59,6 +66,7 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
 	 * redo the search */
 	candidate = rxrpc_alloc_connection(GFP_NOIO);
 	if (!candidate) {
+		rxrpc_put_peer(peer);
 		_leave(" = -ENOMEM");
 		return ERR_PTR(-ENOMEM);
 	}
@@ -115,6 +123,7 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
 success:
 	_net("CONNECTION %s %d {%x}", new, conn->debug_id, conn->proto.cid);
 
+	rxrpc_put_peer(peer);
 	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
 	return conn;
 
diff --git a/net/rxrpc/utils.c b/net/rxrpc/utils.c
index f28122a15a24..d3db02ecc37f 100644
--- a/net/rxrpc/utils.c
+++ b/net/rxrpc/utils.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/ip.h>
+#include <linux/ipv6.h>
 #include <linux/udp.h>
 #include "ar-internal.h"
 
@@ -39,3 +40,34 @@ void rxrpc_get_addr_from_skb(struct rxrpc_local *local,
 		BUG();
 	}
 }
+
+/*
+ * Fill out a peer address from a socket buffer containing a packet.
+ */
+int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *srx, struct sk_buff *skb)
+{
+	memset(srx, 0, sizeof(*srx));
+
+	switch (ntohs(skb->protocol)) {
+	case ETH_P_IP:
+		srx->transport_type = SOCK_DGRAM;
+		srx->transport_len = sizeof(srx->transport.sin);
+		srx->transport.sin.sin_family = AF_INET;
+		srx->transport.sin.sin_port = udp_hdr(skb)->source;
+		srx->transport.sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
+		return 0;
+
+	case ETH_P_IPV6:
+		srx->transport_type = SOCK_DGRAM;
+		srx->transport_len = sizeof(srx->transport.sin6);
+		srx->transport.sin6.sin6_family = AF_INET6;
+		srx->transport.sin6.sin6_port = udp_hdr(skb)->source;
+		srx->transport.sin6.sin6_addr = ipv6_hdr(skb)->saddr;
+		return 0;
+
+	default:
+		pr_warn_ratelimited("AF_RXRPC: Unknown eth protocol %u\n",
+				    ntohs(skb->protocol));
+		return -EAFNOSUPPORT;
+	}
+}
