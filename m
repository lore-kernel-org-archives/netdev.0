From: kaber@trash.net
Subject: [PATCH 64/72] tproxy: added IPv6 socket lookup function to nf_tproxy_core
Date: Thu, 21 Oct 2010 17:19:51 +0200
Message-ID: <1287674399-31455-65-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59988 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452Ab0JUPUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:17 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balazs Scheidler <bazsi@balabit.hu>

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_tproxy_core.h |   72 +++++++++++++++++++++++++++++++-
 1 files changed, 71 insertions(+), 1 deletions(-)

diff --git a/include/net/netfilter/nf_tproxy_core.h b/include/net/netfilter/nf_tproxy_core.h
index 1027d7f..cd85b3b 100644
--- a/include/net/netfilter/nf_tproxy_core.h
+++ b/include/net/netfilter/nf_tproxy_core.h
@@ -5,7 +5,8 @@
 #include <linux/in.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <net/inet_sock.h>
+#include <net/inet_hashtables.h>
+#include <net/inet6_hashtables.h>
 #include <net/tcp.h>
 
 #define NFT_LOOKUP_ANY         0
@@ -130,6 +131,75 @@ nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
 	return sk;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static inline struct sock *
+nf_tproxy_get_sock_v6(struct net *net, const u8 protocol,
+		      const struct in6_addr *saddr, const struct in6_addr *daddr,
+		      const __be16 sport, const __be16 dport,
+		      const struct net_device *in, int lookup_type)
+{
+	struct sock *sk;
+
+	/* look up socket */
+	switch (protocol) {
+	case IPPROTO_TCP:
+		switch (lookup_type) {
+		case NFT_LOOKUP_ANY:
+			sk = inet6_lookup(net, &tcp_hashinfo,
+					  saddr, sport, daddr, dport,
+					  in->ifindex);
+			break;
+		case NFT_LOOKUP_LISTENER:
+			sk = inet6_lookup_listener(net, &tcp_hashinfo,
+						   daddr, ntohs(dport),
+						   in->ifindex);
+
+			/* NOTE: we return listeners even if bound to
+			 * 0.0.0.0, those are filtered out in
+			 * xt_socket, since xt_TPROXY needs 0 bound
+			 * listeners too */
+
+			break;
+		case NFT_LOOKUP_ESTABLISHED:
+			sk = __inet6_lookup_established(net, &tcp_hashinfo,
+							saddr, sport, daddr, ntohs(dport),
+							in->ifindex);
+			break;
+		default:
+			WARN_ON(1);
+			sk = NULL;
+			break;
+		}
+		break;
+	case IPPROTO_UDP:
+		sk = udp6_lib_lookup(net, saddr, sport, daddr, dport,
+				     in->ifindex);
+		if (sk && lookup_type != NFT_LOOKUP_ANY) {
+			int connected = (sk->sk_state == TCP_ESTABLISHED);
+			int wildcard = ipv6_addr_any(&inet6_sk(sk)->rcv_saddr);
+
+			/* NOTE: we return listeners even if bound to
+			 * 0.0.0.0, those are filtered out in
+			 * xt_socket, since xt_TPROXY needs 0 bound
+			 * listeners too */
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
 
 static inline void
 nf_tproxy_put_sock(struct sock *sk)
-- 
1.7.1

