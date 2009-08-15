From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 02/13] TProxy: add lookup type checks for UDP in
 nf_tproxy_get_sock_v4()
Date: Sat, 15 Aug 2009 14:01:51 +0200
Message-ID: <1253548005.12519.2.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also, inline this function as the lookup_type is always a literal
and inlineing removes branches performed at runtime.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 include/net/netfilter/nf_tproxy_core.h |  116 +++++++++++++++++++++++++++++++-
 net/netfilter/nf_tproxy_core.c         |   48 -------------
 2 files changed, 114 insertions(+), 50 deletions(-)

diff --git a/include/net/netfilter/nf_tproxy_core.h b/include/net/netfilter/nf_tproxy_core.h
index b3a8942..4064f35 100644
--- a/include/net/netfilter/nf_tproxy_core.h
+++ b/include/net/netfilter/nf_tproxy_core.h
@@ -13,11 +13,123 @@
 #define NFT_LOOKUP_ESTABLISHED 2
 
 /* look up and get a reference to a matching socket */
-extern struct sock *
+
+
+/* This function is used by the 'TPROXY' target and the 'socket'
+ * match. The following lookups are supported:
+ *
+ * Explicit TProxy target rule
+ * ===========================
+ *
+ * This is used when the user wants to intercept a connection matching
+ * an explicit iptables rule. In this case the sockets are assumed
+ * matching in preference order:
+ *
+ *   - match: if there's a fully established connection matching the
+ *     _packet_ tuple, it is returned, assuming the redirection
+ *     already took place and we process a packet belonging to an
+ *     established connection
+ *
+ *   - match: if there's a listening socket matching the redirection
+ *     (e.g. on-port & on-ip of the connection), it is returned,
+ *     regardless if it was bound to 0.0.0.0 or an explicit
+ *     address. The reasoning is that if there's an explicit rule, it
+ *     does not really matter if the listener is bound to an interface
+ *     or to 0. The user already stated that he wants redirection
+ *     (since he added the rule).
+ *
+ * "socket" match based redirection (no specific rule)
+ * ===================================================
+ * 
+ * There are connections with dynamic endpoints (e.g. FTP data
+ * connection) that the user is unable to add explicit rules
+ * for. These are taken care of by a generic "socket" rule. It is
+ * assumed that the proxy application is trusted to open such
+ * connections without explicit iptables rule (except of course the
+ * generic 'socket' rule). In this case the following sockets are
+ * matched in preference order:
+ *
+ *   - match: if there's a fully established connection matching the
+ *     _packet_ tuple
+ * 
+ *   - match: if there's a non-zero bound listener (possibly with a
+ *     non-local address) We don't accept zero-bound listeners, since
+ *     then local services could intercept traffic going through the
+ *     box.
+ *
+ * Please note that there's an overlap between what a TPROXY target
+ * and a socket match will match. Normally if you have both rules the
+ * "socket" match will be the first one, effectively all packets
+ * belonging to established connections going through that one.
+ */
+static inline struct sock *
 nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
 		      const __be32 saddr, const __be32 daddr,
 		      const __be16 sport, const __be16 dport,
-		      const struct net_device *in, int lookup_type);
+		      const struct net_device *in, int lookup_type)
+{
+	struct sock *sk;
+
+	/* look up socket */
+	switch (protocol) {
+	case IPPROTO_TCP:
+		switch (lookup_type) {
+		case NFT_LOOKUP_ANY:
+			sk = __inet_lookup(net, &tcp_hashinfo,
+					   saddr, sport, daddr, dport,
+					   in->ifindex);
+			break;
+		case NFT_LOOKUP_LISTENER:
+			sk = inet_lookup_listener(net, &tcp_hashinfo,
+						    daddr, dport,
+						    in->ifindex);
+
+                        /* NOTE: we return listeners even if bound to
+                         * 0.0.0.0, those are filtered out in
+                         * xt_socket, since xt_TPROXY needs 0 bound
+                         * listeners too */
+
+			break;
+		case NFT_LOOKUP_ESTABLISHED:
+			sk = inet_lookup_established(net, &tcp_hashinfo,
+						    saddr, sport, daddr, dport,
+						    in->ifindex);
+			break;
+		default:
+			WARN_ON(1);
+			sk = NULL;
+			break;
+		}
+		break;
+	case IPPROTO_UDP:
+		sk = udp4_lib_lookup(net, saddr, sport, daddr, dport,
+				     in->ifindex);
+                if (sk && lookup_type != NFT_LOOKUP_ANY) {
+                        int connected = (sk->sk_state == TCP_ESTABLISHED);
+                        int wildcard = (inet_sk(sk)->rcv_saddr == 0);
+                        
+                        /* NOTE: we return listeners even if bound to
+                         * 0.0.0.0, those are filtered out in
+                         * xt_socket, since xt_TPROXY needs 0 bound
+                         * listeners too */
+                        if ((lookup_type == NFT_LOOKUP_ESTABLISHED && (!connected || wildcard)) ||
+			    (lookup_type == NFT_LOOKUP_LISTENER && connected)) {
+				sock_put(sk);
+				sk = NULL;
+                        }
+		}
+		break;
+	default:
+		WARN_ON(1);
+		sk = NULL;
+	}
+
+	pr_debug("tproxy socket lookup: proto %u %08x:%u -> %08x:%u, lookup type: %d, sock %p\n",
+		 protocol, ntohl(saddr), ntohs(sport), ntohl(daddr), ntohs(dport), lookup_type, sk);
+
+	return sk;
+}
+
 
 static inline void
 nf_tproxy_put_sock(struct sock *sk)
diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
index 8589e5e..db65563 100644
--- a/net/netfilter/nf_tproxy_core.c
+++ b/net/netfilter/nf_tproxy_core.c
@@ -18,54 +18,6 @@
 #include <net/udp.h>
 #include <net/netfilter/nf_tproxy_core.h>
 
-struct sock *
-nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
-		      const __be32 saddr, const __be32 daddr,
-		      const __be16 sport, const __be16 dport,
-		      const struct net_device *in, int lookup_type)
-{
-	struct sock *sk;
-
-	/* look up socket */
-	switch (protocol) {
-	case IPPROTO_TCP:
-		switch (lookup_type) {
-		case NFT_LOOKUP_ANY:
-			sk = __inet_lookup(net, &tcp_hashinfo,
-					   saddr, sport, daddr, dport,
-					   in->ifindex);
-			break;
-		case NFT_LOOKUP_LISTENER:
-			sk = inet_lookup_listener(net, &tcp_hashinfo,
-						    daddr, dport,
-						    in->ifindex);
-			break;
-		case NFT_LOOKUP_ESTABLISHED:
-			sk = inet_lookup_established(net, &tcp_hashinfo,
-						    saddr, sport, daddr, dport,
-						    in->ifindex);
-			break;
-		default:
-			WARN_ON(1);
-			sk = NULL;
-			break;
-		}
-		break;
-	case IPPROTO_UDP:
-		sk = udp4_lib_lookup(net, saddr, sport, daddr, dport,
-				     in->ifindex);
-		break;
-	default:
-		WARN_ON(1);
-		sk = NULL;
-	}
-
-	pr_debug("tproxy socket lookup: proto %u %08x:%u -> %08x:%u, lookup type: %d, sock %p\n",
-		 protocol, ntohl(saddr), ntohs(sport), ntohl(daddr), ntohs(dport), lookup_type, sk);
-
-	return sk;
-}
-EXPORT_SYMBOL_GPL(nf_tproxy_get_sock_v4);
 
 static void
 nf_tproxy_destructor(struct sk_buff *skb)
-- 
1.6.0.4

