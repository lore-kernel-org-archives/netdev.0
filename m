From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/7] rxrpc: Fix IPv6 support
Date: Tue, 29 Aug 2017 13:27:07 +0100
Message-ID: <150400962771.21371.5301539169789284670.stgit@warthog.procyon.org.uk>
References: <150400960745.21371.15455867950162722742.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150400960745.21371.15455867950162722742.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix IPv6 support in AF_RXRPC in the following ways:

 (1) When extracting the address from a received IPv4 packet, if the local
     transport socket is open for IPv6 then fill out the sockaddr_rxrpc
     struct for an IPv4-mapped-to-IPv6 AF_INET6 transport address instead
     of an AF_INET one.

 (2) When sending CHALLENGE or RESPONSE packets, the transport length needs
     to be set from the sockaddr_rxrpc::transport_len field rather than
     sizeof() on the IPv4 transport address.

 (3) When processing an IPv4 ICMP packet received by an IPv6 socket, set up
     the address correctly before searching for the affected peer.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    4 ++--
 net/rxrpc/call_accept.c |    2 +-
 net/rxrpc/conn_object.c |    2 +-
 net/rxrpc/local_event.c |    2 +-
 net/rxrpc/output.c      |    2 +-
 net/rxrpc/peer_event.c  |    6 ++++--
 net/rxrpc/rxkad.c       |    8 ++++----
 net/rxrpc/utils.c       |   23 +++++++++++++++++------
 8 files changed, 31 insertions(+), 18 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 8cac66774de1..227e24794055 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -830,7 +830,6 @@ void rxrpc_process_connection(struct work_struct *);
  */
 extern unsigned int rxrpc_connection_expiry;
 
-int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *, struct sk_buff *);
 struct rxrpc_connection *rxrpc_alloc_connection(gfp_t);
 struct rxrpc_connection *rxrpc_find_connection_rcu(struct rxrpc_local *,
 						   struct sk_buff *);
@@ -1060,7 +1059,8 @@ static inline void rxrpc_sysctl_exit(void) {}
 /*
  * utils.c
  */
-int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *, struct sk_buff *);
+int rxrpc_extract_addr_from_skb(struct rxrpc_local *, struct sockaddr_rxrpc *,
+				struct sk_buff *);
 
 static inline bool before(u32 seq1, u32 seq2)
 {
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index ec3383f97d4c..cbd1701e813a 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -277,7 +277,7 @@ static struct rxrpc_call *rxrpc_alloc_incoming_call(struct rxrpc_sock *rx,
 		 * anticipation - and to save on stack space.
 		 */
 		xpeer = b->peer_backlog[peer_tail];
-		if (rxrpc_extract_addr_from_skb(&xpeer->srx, skb) < 0)
+		if (rxrpc_extract_addr_from_skb(local, &xpeer->srx, skb) < 0)
 			return NULL;
 
 		peer = rxrpc_lookup_incoming_peer(local, xpeer);
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 929b50d5afe8..fe575798592f 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -72,7 +72,7 @@ struct rxrpc_connection *rxrpc_find_connection_rcu(struct rxrpc_local *local,
 
 	_enter(",%x", sp->hdr.cid & RXRPC_CIDMASK);
 
-	if (rxrpc_extract_addr_from_skb(&srx, skb) < 0)
+	if (rxrpc_extract_addr_from_skb(local, &srx, skb) < 0)
 		goto not_found;
 
 	k.epoch	= sp->hdr.epoch;
diff --git a/net/rxrpc/local_event.c b/net/rxrpc/local_event.c
index 540d3955c1bc..93b5d910b4a1 100644
--- a/net/rxrpc/local_event.c
+++ b/net/rxrpc/local_event.c
@@ -39,7 +39,7 @@ static void rxrpc_send_version_request(struct rxrpc_local *local,
 
 	_enter("");
 
-	if (rxrpc_extract_addr_from_skb(&srx, skb) < 0)
+	if (rxrpc_extract_addr_from_skb(local, &srx, skb) < 0)
 		return;
 
 	msg.msg_name	= &srx.transport;
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 5bd2d0fa4a03..71e6f713fbe7 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -444,7 +444,7 @@ void rxrpc_reject_packets(struct rxrpc_local *local)
 		rxrpc_see_skb(skb, rxrpc_skb_rx_seen);
 		sp = rxrpc_skb(skb);
 
-		if (rxrpc_extract_addr_from_skb(&srx, skb) == 0) {
+		if (rxrpc_extract_addr_from_skb(local, &srx, skb) == 0) {
 			msg.msg_namelen = srx.transport_len;
 
 			code = htonl(skb->priority);
diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index 1ed9c0c2e94f..7f749505e699 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -37,6 +37,7 @@ static struct rxrpc_peer *rxrpc_lookup_peer_icmp_rcu(struct rxrpc_local *local,
 
 	memset(&srx, 0, sizeof(srx));
 	srx.transport_type = local->srx.transport_type;
+	srx.transport_len = local->srx.transport_len;
 	srx.transport.family = local->srx.transport.family;
 
 	/* Can we see an ICMP4 packet on an ICMP6 listening socket?  and vice
@@ -45,7 +46,6 @@ static struct rxrpc_peer *rxrpc_lookup_peer_icmp_rcu(struct rxrpc_local *local,
 	switch (srx.transport.family) {
 	case AF_INET:
 		srx.transport.sin.sin_port = serr->port;
-		srx.transport_len = sizeof(struct sockaddr_in);
 		switch (serr->ee.ee_origin) {
 		case SO_EE_ORIGIN_ICMP:
 			_net("Rx ICMP");
@@ -69,7 +69,6 @@ static struct rxrpc_peer *rxrpc_lookup_peer_icmp_rcu(struct rxrpc_local *local,
 #ifdef CONFIG_AF_RXRPC_IPV6
 	case AF_INET6:
 		srx.transport.sin6.sin6_port = serr->port;
-		srx.transport_len = sizeof(struct sockaddr_in6);
 		switch (serr->ee.ee_origin) {
 		case SO_EE_ORIGIN_ICMP6:
 			_net("Rx ICMP6");
@@ -79,6 +78,9 @@ static struct rxrpc_peer *rxrpc_lookup_peer_icmp_rcu(struct rxrpc_local *local,
 			break;
 		case SO_EE_ORIGIN_ICMP:
 			_net("Rx ICMP on v6 sock");
+			srx.transport.sin6.sin6_addr.s6_addr32[0] = 0;
+			srx.transport.sin6.sin6_addr.s6_addr32[1] = 0;
+			srx.transport.sin6.sin6_addr.s6_addr32[2] = htonl(0xffff);
 			memcpy(srx.transport.sin6.sin6_addr.s6_addr + 12,
 			       skb_network_header(skb) + serr->addr_offset,
 			       sizeof(struct in_addr));
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 34c86d2bcae5..c38b3a1de56c 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -634,8 +634,8 @@ static int rxkad_issue_challenge(struct rxrpc_connection *conn)
 	challenge.min_level	= htonl(0);
 	challenge.__padding	= 0;
 
-	msg.msg_name	= &conn->params.peer->srx.transport.sin;
-	msg.msg_namelen	= sizeof(conn->params.peer->srx.transport.sin);
+	msg.msg_name	= &conn->params.peer->srx.transport;
+	msg.msg_namelen	= conn->params.peer->srx.transport_len;
 	msg.msg_control	= NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
@@ -689,8 +689,8 @@ static int rxkad_send_response(struct rxrpc_connection *conn,
 
 	_enter("");
 
-	msg.msg_name	= &conn->params.peer->srx.transport.sin;
-	msg.msg_namelen	= sizeof(conn->params.peer->srx.transport.sin);
+	msg.msg_name	= &conn->params.peer->srx.transport;
+	msg.msg_namelen	= conn->params.peer->srx.transport_len;
 	msg.msg_control	= NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
diff --git a/net/rxrpc/utils.c b/net/rxrpc/utils.c
index ff7af71c4b49..e801171fa351 100644
--- a/net/rxrpc/utils.c
+++ b/net/rxrpc/utils.c
@@ -17,17 +17,28 @@
 /*
  * Fill out a peer address from a socket buffer containing a packet.
  */
-int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *srx, struct sk_buff *skb)
+int rxrpc_extract_addr_from_skb(struct rxrpc_local *local,
+				struct sockaddr_rxrpc *srx,
+				struct sk_buff *skb)
 {
 	memset(srx, 0, sizeof(*srx));
 
 	switch (ntohs(skb->protocol)) {
 	case ETH_P_IP:
-		srx->transport_type = SOCK_DGRAM;
-		srx->transport_len = sizeof(srx->transport.sin);
-		srx->transport.sin.sin_family = AF_INET;
-		srx->transport.sin.sin_port = udp_hdr(skb)->source;
-		srx->transport.sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
+		if (local->srx.transport.family == AF_INET6) {
+			srx->transport_type = SOCK_DGRAM;
+			srx->transport_len = sizeof(srx->transport.sin6);
+			srx->transport.sin6.sin6_family = AF_INET6;
+			srx->transport.sin6.sin6_port = udp_hdr(skb)->source;
+			srx->transport.sin6.sin6_addr.s6_addr32[2] = htonl(0xffff);
+			srx->transport.sin6.sin6_addr.s6_addr32[3] = ip_hdr(skb)->saddr;
+		} else {
+			srx->transport_type = SOCK_DGRAM;
+			srx->transport_len = sizeof(srx->transport.sin);
+			srx->transport.sin.sin_family = AF_INET;
+			srx->transport.sin.sin_port = udp_hdr(skb)->source;
+			srx->transport.sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
+		}
 		return 0;
 
 #ifdef CONFIG_AF_RXRPC_IPV6
