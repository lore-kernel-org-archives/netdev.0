From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/19] netfilter: tproxy: remove nf_tproxy_core.h
Date: Tue, 20 Aug 2013 12:54:39 +0200
Message-ID: <1376996091-3964-8-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

We've removed nf_tproxy_core.ko, so also remove its header.
The lookup helpers are split and then moved to tproxy target/socket match.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tproxy_core.h |  206 --------------------------------
 net/netfilter/xt_TPROXY.c              |  160 ++++++++++++++++++++++++-
 net/netfilter/xt_socket.c              |   66 +++++++++-
 3 files changed, 220 insertions(+), 212 deletions(-)
 delete mode 100644 include/net/netfilter/nf_tproxy_core.h

diff --git a/include/net/netfilter/nf_tproxy_core.h b/include/net/netfilter/nf_tproxy_core.h
deleted file mode 100644
index 975ffa4..0000000
--- a/include/net/netfilter/nf_tproxy_core.h
+++ /dev/null
@@ -1,206 +0,0 @@
-#ifndef _NF_TPROXY_CORE_H
-#define _NF_TPROXY_CORE_H
-
-#include <linux/types.h>
-#include <linux/in.h>
-#include <linux/skbuff.h>
-#include <net/sock.h>
-#include <net/inet_hashtables.h>
-#include <net/inet6_hashtables.h>
-#include <net/tcp.h>
-
-#define NFT_LOOKUP_ANY         0
-#define NFT_LOOKUP_LISTENER    1
-#define NFT_LOOKUP_ESTABLISHED 2
-
-/* look up and get a reference to a matching socket */
-
-
-/* This function is used by the 'TPROXY' target and the 'socket'
- * match. The following lookups are supported:
- *
- * Explicit TProxy target rule
- * ===========================
- *
- * This is used when the user wants to intercept a connection matching
- * an explicit iptables rule. In this case the sockets are assumed
- * matching in preference order:
- *
- *   - match: if there's a fully established connection matching the
- *     _packet_ tuple, it is returned, assuming the redirection
- *     already took place and we process a packet belonging to an
- *     established connection
- *
- *   - match: if there's a listening socket matching the redirection
- *     (e.g. on-port & on-ip of the connection), it is returned,
- *     regardless if it was bound to 0.0.0.0 or an explicit
- *     address. The reasoning is that if there's an explicit rule, it
- *     does not really matter if the listener is bound to an interface
- *     or to 0. The user already stated that he wants redirection
- *     (since he added the rule).
- *
- * "socket" match based redirection (no specific rule)
- * ===================================================
- *
- * There are connections with dynamic endpoints (e.g. FTP data
- * connection) that the user is unable to add explicit rules
- * for. These are taken care of by a generic "socket" rule. It is
- * assumed that the proxy application is trusted to open such
- * connections without explicit iptables rule (except of course the
- * generic 'socket' rule). In this case the following sockets are
- * matched in preference order:
- *
- *   - match: if there's a fully established connection matching the
- *     _packet_ tuple
- *
- *   - match: if there's a non-zero bound listener (possibly with a
- *     non-local address) We don't accept zero-bound listeners, since
- *     then local services could intercept traffic going through the
- *     box.
- *
- * Please note that there's an overlap between what a TPROXY target
- * and a socket match will match. Normally if you have both rules the
- * "socket" match will be the first one, effectively all packets
- * belonging to established connections going through that one.
- */
-static inline struct sock *
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
-						    saddr, sport,
-						    daddr, dport,
-						    in->ifindex);
-
-			/* NOTE: we return listeners even if bound to
-			 * 0.0.0.0, those are filtered out in
-			 * xt_socket, since xt_TPROXY needs 0 bound
-			 * listeners too */
-
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
-		if (sk && lookup_type != NFT_LOOKUP_ANY) {
-			int connected = (sk->sk_state == TCP_ESTABLISHED);
-			int wildcard = (inet_sk(sk)->inet_rcv_saddr == 0);
-
-			/* NOTE: we return listeners even if bound to
-			 * 0.0.0.0, those are filtered out in
-			 * xt_socket, since xt_TPROXY needs 0 bound
-			 * listeners too */
-			if ((lookup_type == NFT_LOOKUP_ESTABLISHED && (!connected || wildcard)) ||
-			    (lookup_type == NFT_LOOKUP_LISTENER && connected)) {
-				sock_put(sk);
-				sk = NULL;
-			}
-		}
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
-
-#if IS_ENABLED(CONFIG_IPV6)
-static inline struct sock *
-nf_tproxy_get_sock_v6(struct net *net, const u8 protocol,
-		      const struct in6_addr *saddr, const struct in6_addr *daddr,
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
-			sk = inet6_lookup(net, &tcp_hashinfo,
-					  saddr, sport, daddr, dport,
-					  in->ifindex);
-			break;
-		case NFT_LOOKUP_LISTENER:
-			sk = inet6_lookup_listener(net, &tcp_hashinfo,
-						   saddr, sport,
-						   daddr, ntohs(dport),
-						   in->ifindex);
-
-			/* NOTE: we return listeners even if bound to
-			 * 0.0.0.0, those are filtered out in
-			 * xt_socket, since xt_TPROXY needs 0 bound
-			 * listeners too */
-
-			break;
-		case NFT_LOOKUP_ESTABLISHED:
-			sk = __inet6_lookup_established(net, &tcp_hashinfo,
-							saddr, sport, daddr, ntohs(dport),
-							in->ifindex);
-			break;
-		default:
-			WARN_ON(1);
-			sk = NULL;
-			break;
-		}
-		break;
-	case IPPROTO_UDP:
-		sk = udp6_lib_lookup(net, saddr, sport, daddr, dport,
-				     in->ifindex);
-		if (sk && lookup_type != NFT_LOOKUP_ANY) {
-			int connected = (sk->sk_state == TCP_ESTABLISHED);
-			int wildcard = ipv6_addr_any(&inet6_sk(sk)->rcv_saddr);
-
-			/* NOTE: we return listeners even if bound to
-			 * 0.0.0.0, those are filtered out in
-			 * xt_socket, since xt_TPROXY needs 0 bound
-			 * listeners too */
-			if ((lookup_type == NFT_LOOKUP_ESTABLISHED && (!connected || wildcard)) ||
-			    (lookup_type == NFT_LOOKUP_LISTENER && connected)) {
-				sock_put(sk);
-				sk = NULL;
-			}
-		}
-		break;
-	default:
-		WARN_ON(1);
-		sk = NULL;
-	}
-
-	pr_debug("tproxy socket lookup: proto %u %pI6:%u -> %pI6:%u, lookup type: %d, sock %p\n",
-		 protocol, saddr, ntohs(sport), daddr, ntohs(dport), lookup_type, sk);
-
-	return sk;
-}
-#endif
-
-#endif
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 17c40de..851383a 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -15,7 +15,9 @@
 #include <linux/ip.h>
 #include <net/checksum.h>
 #include <net/udp.h>
+#include <net/tcp.h>
 #include <net/inet_sock.h>
+#include <net/inet_hashtables.h>
 #include <linux/inetdevice.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
@@ -26,13 +28,18 @@
 #define XT_TPROXY_HAVE_IPV6 1
 #include <net/if_inet6.h>
 #include <net/addrconf.h>
+#include <net/inet6_hashtables.h>
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 #endif
 
-#include <net/netfilter/nf_tproxy_core.h>
 #include <linux/netfilter/xt_TPROXY.h>
 
+enum nf_tproxy_lookup_t {
+	 NFT_LOOKUP_LISTENER,
+	 NFT_LOOKUP_ESTABLISHED,
+};
+
 static bool tproxy_sk_is_transparent(struct sock *sk)
 {
 	if (sk->sk_state != TCP_TIME_WAIT) {
@@ -68,6 +75,157 @@ tproxy_laddr4(struct sk_buff *skb, __be32 user_laddr, __be32 daddr)
 	return laddr ? laddr : daddr;
 }
 
+/*
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
+ * Please note that there's an overlap between what a TPROXY target
+ * and a socket match will match. Normally if you have both rules the
+ * "socket" match will be the first one, effectively all packets
+ * belonging to established connections going through that one.
+ */
+static inline struct sock *
+nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
+		      const __be32 saddr, const __be32 daddr,
+		      const __be16 sport, const __be16 dport,
+		      const struct net_device *in,
+		      const enum nf_tproxy_lookup_t lookup_type)
+{
+	struct sock *sk;
+
+	switch (protocol) {
+	case IPPROTO_TCP:
+		switch (lookup_type) {
+		case NFT_LOOKUP_LISTENER:
+			sk = inet_lookup_listener(net, &tcp_hashinfo,
+						    saddr, sport,
+						    daddr, dport,
+						    in->ifindex);
+
+			/* NOTE: we return listeners even if bound to
+			 * 0.0.0.0, those are filtered out in
+			 * xt_socket, since xt_TPROXY needs 0 bound
+			 * listeners too
+			 */
+			break;
+		case NFT_LOOKUP_ESTABLISHED:
+			sk = inet_lookup_established(net, &tcp_hashinfo,
+						    saddr, sport, daddr, dport,
+						    in->ifindex);
+			break;
+		default:
+			BUG();
+		}
+		break;
+	case IPPROTO_UDP:
+		sk = udp4_lib_lookup(net, saddr, sport, daddr, dport,
+				     in->ifindex);
+		if (sk) {
+			int connected = (sk->sk_state == TCP_ESTABLISHED);
+			int wildcard = (inet_sk(sk)->inet_rcv_saddr == 0);
+
+			/* NOTE: we return listeners even if bound to
+			 * 0.0.0.0, those are filtered out in
+			 * xt_socket, since xt_TPROXY needs 0 bound
+			 * listeners too
+			 */
+			if ((lookup_type == NFT_LOOKUP_ESTABLISHED && (!connected || wildcard)) ||
+			    (lookup_type == NFT_LOOKUP_LISTENER && connected)) {
+				sock_put(sk);
+				sk = NULL;
+			}
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
+#if IS_ENABLED(CONFIG_IPV6)
+static inline struct sock *
+nf_tproxy_get_sock_v6(struct net *net, const u8 protocol,
+		      const struct in6_addr *saddr, const struct in6_addr *daddr,
+		      const __be16 sport, const __be16 dport,
+		      const struct net_device *in,
+		      const enum nf_tproxy_lookup_t lookup_type)
+{
+	struct sock *sk;
+
+	switch (protocol) {
+	case IPPROTO_TCP:
+		switch (lookup_type) {
+		case NFT_LOOKUP_LISTENER:
+			sk = inet6_lookup_listener(net, &tcp_hashinfo,
+						   saddr, sport,
+						   daddr, ntohs(dport),
+						   in->ifindex);
+
+			/* NOTE: we return listeners even if bound to
+			 * 0.0.0.0, those are filtered out in
+			 * xt_socket, since xt_TPROXY needs 0 bound
+			 * listeners too
+			 */
+			break;
+		case NFT_LOOKUP_ESTABLISHED:
+			sk = __inet6_lookup_established(net, &tcp_hashinfo,
+							saddr, sport, daddr, ntohs(dport),
+							in->ifindex);
+			break;
+		default:
+			BUG();
+		}
+		break;
+	case IPPROTO_UDP:
+		sk = udp6_lib_lookup(net, saddr, sport, daddr, dport,
+				     in->ifindex);
+		if (sk) {
+			int connected = (sk->sk_state == TCP_ESTABLISHED);
+			int wildcard = ipv6_addr_any(&inet6_sk(sk)->rcv_saddr);
+
+			/* NOTE: we return listeners even if bound to
+			 * 0.0.0.0, those are filtered out in
+			 * xt_socket, since xt_TPROXY needs 0 bound
+			 * listeners too
+			 */
+			if ((lookup_type == NFT_LOOKUP_ESTABLISHED && (!connected || wildcard)) ||
+			    (lookup_type == NFT_LOOKUP_LISTENER && connected)) {
+				sock_put(sk);
+				sk = NULL;
+			}
+		}
+		break;
+	default:
+		WARN_ON(1);
+		sk = NULL;
+	}
+
+	pr_debug("tproxy socket lookup: proto %u %pI6:%u -> %pI6:%u, lookup type: %d, sock %p\n",
+		 protocol, saddr, ntohs(sport), daddr, ntohs(dport), lookup_type, sk);
+
+	return sk;
+}
+#endif
+
 /**
  * tproxy_handle_time_wait4 - handle IPv4 TCP TIME_WAIT reopen redirections
  * @skb:	The skb being processed.
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index f8b7191..a7dd108 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -19,12 +19,12 @@
 #include <net/icmp.h>
 #include <net/sock.h>
 #include <net/inet_sock.h>
-#include <net/netfilter/nf_tproxy_core.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
 
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 #define XT_SOCKET_HAVE_IPV6 1
 #include <linux/netfilter_ipv6/ip6_tables.h>
+#include <net/inet6_hashtables.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 #endif
 
@@ -101,6 +101,43 @@ extract_icmp4_fields(const struct sk_buff *skb,
 	return 0;
 }
 
+/* "socket" match based redirection (no specific rule)
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
+ */
+static struct sock *
+xt_socket_get_sock_v4(struct net *net, const u8 protocol,
+		      const __be32 saddr, const __be32 daddr,
+		      const __be16 sport, const __be16 dport,
+		      const struct net_device *in)
+{
+	switch (protocol) {
+	case IPPROTO_TCP:
+		return __inet_lookup(net, &tcp_hashinfo,
+				     saddr, sport, daddr, dport,
+				     in->ifindex);
+	case IPPROTO_UDP:
+		return udp4_lib_lookup(net, saddr, sport, daddr, dport,
+				       in->ifindex);
+	}
+	return NULL;
+}
+
 static bool
 socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 	     const struct xt_socket_mtinfo1 *info)
@@ -156,9 +193,9 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 #endif
 
 	if (!sk)
-		sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), protocol,
+		sk = xt_socket_get_sock_v4(dev_net(skb->dev), protocol,
 					   saddr, daddr, sport, dport,
-					   par->in, NFT_LOOKUP_ANY);
+					   par->in);
 	if (sk) {
 		bool wildcard;
 		bool transparent = true;
@@ -261,6 +298,25 @@ extract_icmp6_fields(const struct sk_buff *skb,
 	return 0;
 }
 
+static struct sock *
+xt_socket_get_sock_v6(struct net *net, const u8 protocol,
+		      const struct in6_addr *saddr, const struct in6_addr *daddr,
+		      const __be16 sport, const __be16 dport,
+		      const struct net_device *in)
+{
+	switch (protocol) {
+	case IPPROTO_TCP:
+		return inet6_lookup(net, &tcp_hashinfo,
+				    saddr, sport, daddr, dport,
+				    in->ifindex);
+	case IPPROTO_UDP:
+		return udp6_lib_lookup(net, saddr, sport, daddr, dport,
+				       in->ifindex);
+	}
+
+	return NULL;
+}
+
 static bool
 socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
 {
@@ -298,9 +354,9 @@ socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
 	}
 
 	if (!sk)
-		sk = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
+		sk = xt_socket_get_sock_v6(dev_net(skb->dev), tproto,
 					   saddr, daddr, sport, dport,
-					   par->in, NFT_LOOKUP_ANY);
+					   par->in);
 	if (sk) {
 		bool wildcard;
 		bool transparent = true;
-- 
1.7.10.4

