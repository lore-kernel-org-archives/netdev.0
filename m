From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/4] rxrpc: Add IPv6 support
Date: Tue, 13 Sep 2016 23:41:59 +0100
Message-ID: <147380651897.30728.3183323952152113744.stgit@warthog.procyon.org.uk>
References: <147380649153.30728.6717292274642860064.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147380649153.30728.6717292274642860064.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add IPv6 support to AF_RXRPC.  With this, AF_RXRPC sockets can be created:

	service = socket(AF_RXRPC, SOCK_DGRAM, PF_INET6);

instead of:

	service = socket(AF_RXRPC, SOCK_DGRAM, PF_INET);

The AFS filesystem doesn't support IPv6 at the moment, though, since that
requires upgrades to some of the RPC calls.

Note that a good portion of this patch is replacing "%pI4:%u" in print
statements with "%pISpc" which is able to handle both protocols and print
the port.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c     |   15 +++++-
 net/rxrpc/conn_object.c  |    8 +++
 net/rxrpc/local_object.c |   35 ++++++---------
 net/rxrpc/output.c       |   16 +++++++
 net/rxrpc/peer_event.c   |   24 ++++++++++
 net/rxrpc/peer_object.c  |  109 +++++++++++++++++++++++++++++-----------------
 net/rxrpc/proc.c         |   30 +++++--------
 7 files changed, 154 insertions(+), 83 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 741b0d8d2e8c..f61f7b2d1ca4 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -106,19 +106,23 @@ static int rxrpc_validate_address(struct rxrpc_sock *rx,
 	case AF_INET:
 		if (srx->transport_len < sizeof(struct sockaddr_in))
 			return -EINVAL;
-		_debug("INET: %x @ %pI4",
-		       ntohs(srx->transport.sin.sin_port),
-		       &srx->transport.sin.sin_addr);
 		tail = offsetof(struct sockaddr_rxrpc, transport.sin.__pad);
 		break;
 
 	case AF_INET6:
+		if (srx->transport_len < sizeof(struct sockaddr_in6))
+			return -EINVAL;
+		tail = offsetof(struct sockaddr_rxrpc, transport) +
+			sizeof(struct sockaddr_in6);
+		break;
+
 	default:
 		return -EAFNOSUPPORT;
 	}
 
 	if (tail < len)
 		memset((void *)srx + tail, 0, len - tail);
+	_debug("INET: %pISp", &srx->transport);
 	return 0;
 }
 
@@ -409,6 +413,9 @@ static int rxrpc_sendmsg(struct socket *sock, struct msghdr *m, size_t len)
 		case AF_INET:
 			rx->srx.transport_len = sizeof(struct sockaddr_in);
 			break;
+		case AF_INET6:
+			rx->srx.transport_len = sizeof(struct sockaddr_in6);
+			break;
 		default:
 			ret = -EAFNOSUPPORT;
 			goto error_unlock;
@@ -563,7 +570,7 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 		return -EAFNOSUPPORT;
 
 	/* we support transport protocol UDP/UDP6 only */
-	if (protocol != PF_INET)
+	if (protocol != PF_INET && protocol != PF_INET6)
 		return -EPROTONOSUPPORT;
 
 	if (sock->type != SOCK_DGRAM)
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index ffa9addb97b2..c0ddba787fd4 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -134,6 +134,14 @@ struct rxrpc_connection *rxrpc_find_connection_rcu(struct rxrpc_local *local,
 			    srx.transport.sin.sin_addr.s_addr)
 				goto not_found;
 			break;
+		case AF_INET6:
+			if (peer->srx.transport.sin6.sin6_port !=
+			    srx.transport.sin6.sin6_port ||
+			    memcmp(&peer->srx.transport.sin6.sin6_addr,
+				   &srx.transport.sin6.sin6_addr,
+				   sizeof(struct in6_addr)) != 0)
+				goto not_found;
+			break;
 		default:
 			BUG();
 		}
diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index 8720be2a6250..f5b9bb0d3f98 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -58,6 +58,15 @@ static long rxrpc_local_cmp_key(const struct rxrpc_local *local,
 			memcmp(&local->srx.transport.sin.sin_addr,
 			       &srx->transport.sin.sin_addr,
 			       sizeof(struct in_addr));
+	case AF_INET6:
+		/* If the choice of UDP6 port is left up to the transport, then
+		 * the endpoint record doesn't match.
+		 */
+		return ((u16 __force)local->srx.transport.sin6.sin6_port -
+			(u16 __force)srx->transport.sin6.sin6_port) ?:
+			memcmp(&local->srx.transport.sin6.sin6_addr,
+			       &srx->transport.sin6.sin6_addr,
+			       sizeof(struct in6_addr));
 	default:
 		BUG();
 	}
@@ -100,7 +109,8 @@ static int rxrpc_open_socket(struct rxrpc_local *local)
 	struct sock *sock;
 	int ret, opt;
 
-	_enter("%p{%d}", local, local->srx.transport_type);
+	_enter("%p{%d,%d}",
+	       local, local->srx.transport_type, local->srx.transport.family);
 
 	/* create a socket to represent the local endpoint */
 	ret = sock_create_kern(&init_net, local->srx.transport.family,
@@ -169,18 +179,8 @@ struct rxrpc_local *rxrpc_lookup_local(const struct sockaddr_rxrpc *srx)
 	long diff;
 	int ret;
 
-	if (srx->transport.family == AF_INET) {
-		_enter("{%d,%u,%pI4+%hu}",
-		       srx->transport_type,
-		       srx->transport.family,
-		       &srx->transport.sin.sin_addr,
-		       ntohs(srx->transport.sin.sin_port));
-	} else {
-		_enter("{%d,%u}",
-		       srx->transport_type,
-		       srx->transport.family);
-		return ERR_PTR(-EAFNOSUPPORT);
-	}
+	_enter("{%d,%d,%pISp}",
+	       srx->transport_type, srx->transport.family, &srx->transport);
 
 	mutex_lock(&rxrpc_local_mutex);
 
@@ -233,13 +233,8 @@ struct rxrpc_local *rxrpc_lookup_local(const struct sockaddr_rxrpc *srx)
 found:
 	mutex_unlock(&rxrpc_local_mutex);
 
-	_net("LOCAL %s %d {%d,%u,%pI4+%hu}",
-	     age,
-	     local->debug_id,
-	     local->srx.transport_type,
-	     local->srx.transport.family,
-	     &local->srx.transport.sin.sin_addr,
-	     ntohs(local->srx.transport.sin.sin_port));
+	_net("LOCAL %s %d {%pISp}",
+	     age, local->debug_id, &local->srx.transport);
 
 	_leave(" = %p", local);
 	return local;
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index ec3621f2c5c8..d7cd87f17f0d 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -258,6 +258,22 @@ send_fragmentable:
 					  (char *)&opt, sizeof(opt));
 		}
 		break;
+
+	case AF_INET6:
+		opt = IPV6_PMTUDISC_DONT;
+		ret = kernel_setsockopt(conn->params.local->socket,
+					SOL_IPV6, IPV6_MTU_DISCOVER,
+					(char *)&opt, sizeof(opt));
+		if (ret == 0) {
+			ret = kernel_sendmsg(conn->params.local->socket, &msg,
+					     iov, 1, iov[0].iov_len);
+
+			opt = IPV6_PMTUDISC_DO;
+			kernel_setsockopt(conn->params.local->socket,
+					  SOL_IPV6, IPV6_MTU_DISCOVER,
+					  (char *)&opt, sizeof(opt));
+		}
+		break;
 	}
 
 	up_write(&conn->params.local->defrag_sem);
diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index c8948936c6fc..74217589cf44 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -66,6 +66,30 @@ static struct rxrpc_peer *rxrpc_lookup_peer_icmp_rcu(struct rxrpc_local *local,
 		}
 		break;
 
+	case AF_INET6:
+		srx.transport.sin6.sin6_port = serr->port;
+		srx.transport_len = sizeof(struct sockaddr_in6);
+		switch (serr->ee.ee_origin) {
+		case SO_EE_ORIGIN_ICMP6:
+			_net("Rx ICMP6");
+			memcpy(&srx.transport.sin6.sin6_addr,
+			       skb_network_header(skb) + serr->addr_offset,
+			       sizeof(struct in6_addr));
+			break;
+		case SO_EE_ORIGIN_ICMP:
+			_net("Rx ICMP on v6 sock");
+			memcpy(&srx.transport.sin6.sin6_addr.s6_addr + 12,
+			       skb_network_header(skb) + serr->addr_offset,
+			       sizeof(struct in_addr));
+			break;
+		default:
+			memcpy(&srx.transport.sin6.sin6_addr,
+			       &ipv6_hdr(skb)->saddr,
+			       sizeof(struct in6_addr));
+			break;
+		}
+		break;
+
 	default:
 		BUG();
 	}
diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index 3e6cd174b53d..dfc07b41a472 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -16,12 +16,14 @@
 #include <linux/skbuff.h>
 #include <linux/udp.h>
 #include <linux/in.h>
+#include <linux/in6.h>
 #include <linux/slab.h>
 #include <linux/hashtable.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include <net/ip.h>
 #include <net/route.h>
+#include <net/ip6_route.h>
 #include "ar-internal.h"
 
 static DEFINE_HASHTABLE(rxrpc_peer_hash, 10);
@@ -50,6 +52,11 @@ static unsigned long rxrpc_peer_hash_key(struct rxrpc_local *local,
 		size = sizeof(srx->transport.sin.sin_addr);
 		p = (u16 *)&srx->transport.sin.sin_addr;
 		break;
+	case AF_INET6:
+		hash_key += (u16 __force)srx->transport.sin.sin_port;
+		size = sizeof(srx->transport.sin6.sin6_addr);
+		p = (u16 *)&srx->transport.sin6.sin6_addr;
+		break;
 	default:
 		WARN(1, "AF_RXRPC: Unsupported transport address family\n");
 		return 0;
@@ -93,6 +100,12 @@ static long rxrpc_peer_cmp_key(const struct rxrpc_peer *peer,
 			memcmp(&peer->srx.transport.sin.sin_addr,
 			       &srx->transport.sin.sin_addr,
 			       sizeof(struct in_addr));
+	case AF_INET6:
+		return ((u16 __force)peer->srx.transport.sin6.sin6_port -
+			(u16 __force)srx->transport.sin6.sin6_port) ?:
+			memcmp(&peer->srx.transport.sin6.sin6_addr,
+			       &srx->transport.sin6.sin6_addr,
+			       sizeof(struct in6_addr));
 	default:
 		BUG();
 	}
@@ -130,17 +143,7 @@ struct rxrpc_peer *rxrpc_lookup_peer_rcu(struct rxrpc_local *local,
 
 	peer = __rxrpc_lookup_peer_rcu(local, srx, hash_key);
 	if (peer) {
-		switch (srx->transport.family) {
-		case AF_INET:
-			_net("PEER %d {%d,%u,%pI4+%hu}",
-			     peer->debug_id,
-			     peer->srx.transport_type,
-			     peer->srx.transport.family,
-			     &peer->srx.transport.sin.sin_addr,
-			     ntohs(peer->srx.transport.sin.sin_port));
-			break;
-		}
-
+		_net("PEER %d {%pISp}", peer->debug_id, &peer->srx.transport);
 		_leave(" = %p {u=%d}", peer, atomic_read(&peer->usage));
 	}
 	return peer;
@@ -152,22 +155,49 @@ struct rxrpc_peer *rxrpc_lookup_peer_rcu(struct rxrpc_local *local,
  */
 static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
 {
+	struct dst_entry *dst;
 	struct rtable *rt;
-	struct flowi4 fl4;
+	struct flowi fl;
+	struct flowi4 *fl4 = &fl.u.ip4;
+	struct flowi6 *fl6 = &fl.u.ip6;
 
 	peer->if_mtu = 1500;
 
-	rt = ip_route_output_ports(&init_net, &fl4, NULL,
-				   peer->srx.transport.sin.sin_addr.s_addr, 0,
-				   htons(7000), htons(7001),
-				   IPPROTO_UDP, 0, 0);
-	if (IS_ERR(rt)) {
-		_leave(" [route err %ld]", PTR_ERR(rt));
-		return;
+	memset(&fl, 0, sizeof(fl));
+	switch (peer->srx.transport.family) {
+	case AF_INET:
+		rt = ip_route_output_ports(
+			&init_net, fl4, NULL,
+			peer->srx.transport.sin.sin_addr.s_addr, 0,
+			htons(7000), htons(7001), IPPROTO_UDP, 0, 0);
+		if (IS_ERR(rt)) {
+			_leave(" [route err %ld]", PTR_ERR(rt));
+			return;
+		}
+		dst = &rt->dst;
+		break;
+
+	case AF_INET6:
+		fl6->flowi6_iif = LOOPBACK_IFINDEX;
+		fl6->flowi6_scope = RT_SCOPE_UNIVERSE;
+		fl6->flowi6_proto = IPPROTO_UDP;
+		memcpy(&fl6->daddr, &peer->srx.transport.sin6.sin6_addr,
+		       sizeof(struct in6_addr));
+		fl6->fl6_dport = htons(7001);
+		fl6->fl6_sport = htons(7000);
+		dst = ip6_route_output(&init_net, NULL, fl6);
+		if (IS_ERR(dst)) {
+			_leave(" [route err %ld]", PTR_ERR(dst));
+			return;
+		}
+		break;
+
+	default:
+		BUG();
 	}
 
-	peer->if_mtu = dst_mtu(&rt->dst);
-	dst_release(&rt->dst);
+	peer->if_mtu = dst_mtu(dst);
+	dst_release(dst);
 
 	_leave(" [if_mtu %u]", peer->if_mtu);
 }
@@ -207,17 +237,22 @@ static void rxrpc_init_peer(struct rxrpc_peer *peer, unsigned long hash_key)
 	rxrpc_assess_MTU_size(peer);
 	peer->mtu = peer->if_mtu;
 
-	if (peer->srx.transport.family == AF_INET) {
+	switch (peer->srx.transport.family) {
+	case AF_INET:
 		peer->hdrsize = sizeof(struct iphdr);
-		switch (peer->srx.transport_type) {
-		case SOCK_DGRAM:
-			peer->hdrsize += sizeof(struct udphdr);
-			break;
-		default:
-			BUG();
-			break;
-		}
-	} else {
+		break;
+	case AF_INET6:
+		peer->hdrsize = sizeof(struct ipv6hdr);
+		break;
+	default:
+		BUG();
+	}
+
+	switch (peer->srx.transport_type) {
+	case SOCK_DGRAM:
+		peer->hdrsize += sizeof(struct udphdr);
+		break;
+	default:
 		BUG();
 	}
 
@@ -285,11 +320,7 @@ struct rxrpc_peer *rxrpc_lookup_peer(struct rxrpc_local *local,
 	struct rxrpc_peer *peer, *candidate;
 	unsigned long hash_key = rxrpc_peer_hash_key(local, srx);
 
-	_enter("{%d,%d,%pI4+%hu}",
-	       srx->transport_type,
-	       srx->transport_len,
-	       &srx->transport.sin.sin_addr,
-	       ntohs(srx->transport.sin.sin_port));
+	_enter("{%pISp}", &srx->transport);
 
 	/* search the peer list first */
 	rcu_read_lock();
@@ -326,11 +357,7 @@ struct rxrpc_peer *rxrpc_lookup_peer(struct rxrpc_local *local,
 			peer = candidate;
 	}
 
-	_net("PEER %d {%d,%pI4+%hu}",
-	     peer->debug_id,
-	     peer->srx.transport_type,
-	     &peer->srx.transport.sin.sin_addr,
-	     ntohs(peer->srx.transport.sin.sin_port));
+	_net("PEER %d {%pISp}", peer->debug_id, &peer->srx.transport);
 
 	_leave(" = %p {u=%d}", peer, atomic_read(&peer->usage));
 	return peer;
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index d529d1b4021c..65cd980767fa 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -52,11 +52,12 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 	struct rxrpc_sock *rx;
 	struct rxrpc_peer *peer;
 	struct rxrpc_call *call;
-	char lbuff[4 + 4 + 4 + 4 + 5 + 1], rbuff[4 + 4 + 4 + 4 + 5 + 1];
+	char lbuff[50], rbuff[50];
 
 	if (v == &rxrpc_calls) {
 		seq_puts(seq,
-			 "Proto Local                  Remote                "
+			 "Proto Local                                          "
+			 " Remote                                         "
 			 " SvID ConnID   CallID   End Use State    Abort   "
 			 " UserID\n");
 		return 0;
@@ -68,9 +69,7 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 	if (rx) {
 		local = READ_ONCE(rx->local);
 		if (local)
-			sprintf(lbuff, "%pI4:%u",
-				&local->srx.transport.sin.sin_addr,
-				ntohs(local->srx.transport.sin.sin_port));
+			sprintf(lbuff, "%pISpc", &local->srx.transport);
 		else
 			strcpy(lbuff, "no_local");
 	} else {
@@ -79,14 +78,12 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 
 	peer = call->peer;
 	if (peer)
-		sprintf(rbuff, "%pI4:%u",
-			&peer->srx.transport.sin.sin_addr,
-			ntohs(peer->srx.transport.sin.sin_port));
+		sprintf(rbuff, "%pISpc", &peer->srx.transport);
 	else
 		strcpy(rbuff, "no_connection");
 
 	seq_printf(seq,
-		   "UDP   %-22.22s %-22.22s %4x %08x %08x %s %3u"
+		   "UDP   %-47.47s %-47.47s %4x %08x %08x %s %3u"
 		   " %-8.8s %08x %lx\n",
 		   lbuff,
 		   rbuff,
@@ -145,11 +142,12 @@ static void rxrpc_connection_seq_stop(struct seq_file *seq, void *v)
 static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 {
 	struct rxrpc_connection *conn;
-	char lbuff[4 + 4 + 4 + 4 + 5 + 1], rbuff[4 + 4 + 4 + 4 + 5 + 1];
+	char lbuff[50], rbuff[50];
 
 	if (v == &rxrpc_connection_proc_list) {
 		seq_puts(seq,
-			 "Proto Local                  Remote                "
+			 "Proto Local                                          "
+			 " Remote                                         "
 			 " SvID ConnID   End Use State    Key     "
 			 " Serial   ISerial\n"
 			 );
@@ -163,16 +161,12 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 		goto print;
 	}
 
-	sprintf(lbuff, "%pI4:%u",
-		&conn->params.local->srx.transport.sin.sin_addr,
-		ntohs(conn->params.local->srx.transport.sin.sin_port));
+	sprintf(lbuff, "%pISpc", &conn->params.local->srx.transport);
 
-	sprintf(rbuff, "%pI4:%u",
-		&conn->params.peer->srx.transport.sin.sin_addr,
-		ntohs(conn->params.peer->srx.transport.sin.sin_port));
+	sprintf(rbuff, "%pISpc", &conn->params.peer->srx.transport);
 print:
 	seq_printf(seq,
-		   "UDP   %-22.22s %-22.22s %4x %08x %s %3u"
+		   "UDP   %-47.47s %-47.47s %4x %08x %s %3u"
 		   " %s %08x %08x %08x\n",
 		   lbuff,
 		   rbuff,
