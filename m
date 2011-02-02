From: kaber@trash.net
Subject: [PATCH 24/26] netfilter: ipset: fix linking with CONFIG_IPV6=n
Date: Thu,  3 Feb 2011 00:12:02 +0100
Message-ID: <1296688324-7830-25-git-send-email-kaber@trash.net>
References: <1296688324-7830-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1296688324-7830-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Add a dummy ip_set_get_ip6_port function that unconditionally
returns false for CONFIG_IPV6=n and convert the real function
to ipv6_skip_exthdr() to avoid pulling in the ip6_tables module
when loading ipset.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set_getport.h |   10 ++++++++++
 net/netfilter/ipset/ip_set_getport.c           |   15 +++++++++------
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_getport.h b/include/linux/netfilter/ipset/ip_set_getport.h
index 694c433..3882a81 100644
--- a/include/linux/netfilter/ipset/ip_set_getport.h
+++ b/include/linux/netfilter/ipset/ip_set_getport.h
@@ -3,8 +3,18 @@
 
 extern bool ip_set_get_ip4_port(const struct sk_buff *skb, bool src,
 				__be16 *port, u8 *proto);
+
+#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
 extern bool ip_set_get_ip6_port(const struct sk_buff *skb, bool src,
 				__be16 *port, u8 *proto);
+#else
+static inline bool ip_set_get_ip6_port(const struct sk_buff *skb, bool src,
+				       __be16 *port, u8 *proto)
+{
+	return false;
+}
+#endif
+
 extern bool ip_set_get_ip_port(const struct sk_buff *skb, u8 pf, bool src,
 				__be16 *port);
 
diff --git a/net/netfilter/ipset/ip_set_getport.c b/net/netfilter/ipset/ip_set_getport.c
index 4dd2785..8d52272 100644
--- a/net/netfilter/ipset/ip_set_getport.c
+++ b/net/netfilter/ipset/ip_set_getport.c
@@ -13,6 +13,7 @@
 #include <linux/icmpv6.h>
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #include <net/ip.h>
+#include <net/ipv6.h>
 
 #include <linux/netfilter/ipset/ip_set_getport.h>
 
@@ -93,21 +94,23 @@ ip_set_get_ip4_port(const struct sk_buff *skb, bool src,
 }
 EXPORT_SYMBOL_GPL(ip_set_get_ip4_port);
 
+#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
 bool
 ip_set_get_ip6_port(const struct sk_buff *skb, bool src,
 		    __be16 *port, u8 *proto)
 {
-	unsigned int protooff = 0;
-	int protocol;
-	unsigned short fragoff;
+	int protoff;
+	u8 nexthdr;
 
-	protocol = ipv6_find_hdr(skb, &protooff, -1, &fragoff);
-	if (protocol <= 0 || fragoff)
+	nexthdr = ipv6_hdr(skb)->nexthdr;
+	protoff = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr), &nexthdr);
+	if (protoff < 0)
 		return false;
 
-	return get_port(skb, protocol, protooff, src, port, proto);
+	return get_port(skb, nexthdr, protoff, src, port, proto);
 }
 EXPORT_SYMBOL_GPL(ip_set_get_ip6_port);
+#endif
 
 bool
 ip_set_get_ip_port(const struct sk_buff *skb, u8 pf, bool src, __be16 *port)
-- 
1.7.2.3

