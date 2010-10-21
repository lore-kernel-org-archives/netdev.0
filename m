From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH v2 6/9] tproxy: added IPv6 socket lookup function to
 nf_tproxy_core
Date: Thu, 21 Oct 2010 12:47:09 +0200
Message-ID: <20101021104709.5192.34304.stgit@este.odu>
References: <20101021104709.5192.31249.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Balazs Scheidler <bazsi@balabit.hu>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20101021104709.5192.31249.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balazs Scheidler <bazsi@balabit.hu>

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
---
 include/net/netfilter/nf_tproxy_core.h |   72 ++++++++++++++++++++++++++++++++
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


