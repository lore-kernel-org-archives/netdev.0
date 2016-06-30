From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 18/19] rxrpc: Move data_ready peer lookup into
 rxrpc_find_connection()
Date: Thu, 30 Jun 2016 15:12:51 +0100
Message-ID: <146729597140.26306.10071829222462684822.stgit@warthog.procyon.org.uk>
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

Move the peer lookup done in input.c by data_ready into
rxrpc_find_connection().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    3 --
 net/rxrpc/conn_object.c |   73 ++++++++++++++++++++++++++++++++++++-----------
 net/rxrpc/input.c       |   30 ++-----------------
 net/rxrpc/utils.c       |   27 -----------------
 4 files changed, 59 insertions(+), 74 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index db866552877e..f7f85151b399 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -566,7 +566,6 @@ void rxrpc_extract_conn_params(struct rxrpc_conn_proto *,
 			       struct rxrpc_local *, struct sk_buff *);
 struct rxrpc_connection *rxrpc_alloc_connection(gfp_t);
 struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *,
-					       struct rxrpc_peer *,
 					       struct sk_buff *);
 void __rxrpc_disconnect_call(struct rxrpc_call *);
 void rxrpc_disconnect_call(struct rxrpc_call *);
@@ -770,8 +769,6 @@ static inline void rxrpc_sysctl_exit(void) {}
 /*
  * utils.c
  */
-void rxrpc_get_addr_from_skb(struct rxrpc_local *, const struct sk_buff *,
-			     struct sockaddr_rxrpc *);
 int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *, struct sk_buff *);
 
 /*
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 83cd3548ec10..ff19ee123a9b 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -70,52 +70,91 @@ struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
  * packet
  */
 struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_local *local,
-					       struct rxrpc_peer *peer,
 					       struct sk_buff *skb)
 {
 	struct rxrpc_connection *conn;
+	struct rxrpc_conn_proto k;
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	struct sockaddr_rxrpc srx;
+	struct rxrpc_peer *peer;
 	struct rb_node *p;
-	u32 epoch, cid;
 
 	_enter(",{%x,%x}", sp->hdr.cid, sp->hdr.flags);
 
-	read_lock_bh(&peer->conn_lock);
+	if (rxrpc_extract_addr_from_skb(&srx, skb) < 0)
+		goto not_found;
 
-	cid	= sp->hdr.cid & RXRPC_CIDMASK;
-	epoch	= sp->hdr.epoch;
+	/* We may have to handle mixing IPv4 and IPv6 */
+	if (srx.transport.family != local->srx.transport.family) {
+		pr_warn_ratelimited("AF_RXRPC: Protocol mismatch %u not %u\n",
+				    srx.transport.family,
+				    local->srx.transport.family);
+		goto not_found;
+	}
+
+	k.epoch	= sp->hdr.epoch;
+	k.cid	= sp->hdr.cid & RXRPC_CIDMASK;
 
 	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED) {
+		/* We need to look up service connections by the full protocol
+		 * parameter set.  We look up the peer first as an intermediate
+		 * step and then the connection from the peer's tree.
+		 */
+		peer = rxrpc_lookup_peer_rcu(local, &srx);
+		if (!peer)
+			goto not_found;
+
+		read_lock_bh(&peer->conn_lock);
+
 		p = peer->service_conns.rb_node;
 		while (p) {
 			conn = rb_entry(p, struct rxrpc_connection, service_node);
 
 			_debug("maybe %x", conn->proto.cid);
 
-			if (epoch < conn->proto.epoch)
+			if (k.epoch < conn->proto.epoch)
 				p = p->rb_left;
-			else if (epoch > conn->proto.epoch)
+			else if (k.epoch > conn->proto.epoch)
 				p = p->rb_right;
-			else if (cid < conn->proto.cid)
+			else if (k.cid < conn->proto.cid)
 				p = p->rb_left;
-			else if (cid > conn->proto.cid)
+			else if (k.cid > conn->proto.cid)
 				p = p->rb_right;
 			else
-				goto found;
+				goto found_service_conn;
 		}
+		read_unlock_bh(&peer->conn_lock);
 	} else {
-		conn = idr_find(&rxrpc_client_conn_ids, cid >> RXRPC_CIDSHIFT);
-		if (conn &&
-		    conn->proto.epoch == epoch &&
-		    conn->params.peer == peer)
-			goto found;
+		conn = idr_find(&rxrpc_client_conn_ids,
+				k.cid >> RXRPC_CIDSHIFT);
+		if (!conn ||
+		    conn->proto.epoch != k.epoch ||
+		    conn->params.local != local)
+			goto not_found;
+
+		peer = conn->params.peer;
+		switch (srx.transport.family) {
+		case AF_INET:
+			if (peer->srx.transport.sin.sin_port !=
+			    srx.transport.sin.sin_port ||
+			    peer->srx.transport.sin.sin_addr.s_addr !=
+			    srx.transport.sin.sin_addr.s_addr)
+				goto not_found;
+			break;
+		default:
+			BUG();
+		}
+
+		conn = rxrpc_get_connection_maybe(conn);
+		_leave(" = %p", conn);
+		return conn;
 	}
 
-	read_unlock_bh(&peer->conn_lock);
+not_found:
 	_leave(" = NULL");
 	return NULL;
 
-found:
+found_service_conn:
 	conn = rxrpc_get_connection_maybe(conn);
 	read_unlock_bh(&peer->conn_lock);
 	_leave(" = %p", conn);
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 710e55a5f569..51a7611dd2f6 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -626,32 +626,6 @@ int rxrpc_extract_header(struct rxrpc_skb_priv *sp, struct sk_buff *skb)
 	return 0;
 }
 
-static struct rxrpc_connection *rxrpc_conn_from_local(struct rxrpc_local *local,
-						      struct sk_buff *skb)
-{
-	struct rxrpc_peer *peer;
-	struct rxrpc_connection *conn;
-	struct sockaddr_rxrpc srx;
-
-	rxrpc_get_addr_from_skb(local, skb, &srx);
-	rcu_read_lock();
-	peer = rxrpc_lookup_peer_rcu(local, &srx);
-	if (!peer)
-		goto cant_find_peer;
-
-	conn = rxrpc_find_connection(local, peer, skb);
-	rcu_read_unlock();
-	if (!conn)
-		goto cant_find_conn;
-
-	return conn;
-
-cant_find_peer:
-	rcu_read_unlock();
-cant_find_conn:
-	return NULL;
-}
-
 /*
  * handle data received on the local endpoint
  * - may be called in interrupt context
@@ -731,7 +705,9 @@ void rxrpc_data_ready(struct sock *sk)
 		 * old-fashioned way doesn't really hurt */
 		struct rxrpc_connection *conn;
 
-		conn = rxrpc_conn_from_local(local, skb);
+		rcu_read_lock();
+		conn = rxrpc_find_connection(local, skb);
+		rcu_read_unlock();
 		if (!conn)
 			goto cant_route_call;
 
diff --git a/net/rxrpc/utils.c b/net/rxrpc/utils.c
index d3db02ecc37f..b88914d53ca5 100644
--- a/net/rxrpc/utils.c
+++ b/net/rxrpc/utils.c
@@ -15,33 +15,6 @@
 #include "ar-internal.h"
 
 /*
- * Set up an RxRPC address from a socket buffer.
- */
-void rxrpc_get_addr_from_skb(struct rxrpc_local *local,
-			     const struct sk_buff *skb,
-			     struct sockaddr_rxrpc *srx)
-{
-	memset(srx, 0, sizeof(*srx));
-	srx->transport_type = local->srx.transport_type;
-	srx->transport.family = local->srx.transport.family;
-
-	/* Can we see an ipv4 UDP packet on an ipv6 UDP socket?  and vice
-	 * versa?
-	 */
-	switch (srx->transport.family) {
-	case AF_INET:
-		srx->transport.sin.sin_port = udp_hdr(skb)->source;
-		srx->transport_len = sizeof(struct sockaddr_in);
-		memcpy(&srx->transport.sin.sin_addr, &ip_hdr(skb)->saddr,
-		       sizeof(struct in_addr));
-		break;
-
-	default:
-		BUG();
-	}
-}
-
-/*
  * Fill out a peer address from a socket buffer containing a packet.
  */
 int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *srx, struct sk_buff *skb)
