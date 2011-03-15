From: kaber@trash.net
Subject: [PATCH 37/37] netfilter: xt_addrtype: ipv6 support
Date: Tue, 15 Mar 2011 20:44:17 +0100
Message-ID: <1300218257-26953-38-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49429 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758520Ab1COToe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:34 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fwestphal@astaro.com>

The kernel will refuse certain types that do not work in ipv6 mode.
We can then add these features incrementally without risk of userspace
breakage.

Signed-off-by: Florian Westphal <fwestphal@astaro.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/xt_addrtype.h |   17 ++++++
 net/netfilter/Kconfig                 |    1 +
 net/netfilter/xt_addrtype.c           |   98 ++++++++++++++++++++++++++++++++-
 3 files changed, 114 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/xt_addrtype.h b/include/linux/netfilter/xt_addrtype.h
index b492fc8..b156baa 100644
--- a/include/linux/netfilter/xt_addrtype.h
+++ b/include/linux/netfilter/xt_addrtype.h
@@ -10,6 +10,23 @@ enum {
 	XT_ADDRTYPE_LIMIT_IFACE_OUT	= 0x0008,
 };
 
+
+/* rtn_type enum values from rtnetlink.h, but shifted */
+enum {
+	XT_ADDRTYPE_UNSPEC = 1 << 0,
+	XT_ADDRTYPE_UNICAST = 1 << 1,	/* 1 << RTN_UNICAST */
+	XT_ADDRTYPE_LOCAL  = 1 << 2,	/* 1 << RTN_LOCAL, etc */
+	XT_ADDRTYPE_BROADCAST = 1 << 3,
+	XT_ADDRTYPE_ANYCAST = 1 << 4,
+	XT_ADDRTYPE_MULTICAST = 1 << 5,
+	XT_ADDRTYPE_BLACKHOLE = 1 << 6,
+	XT_ADDRTYPE_UNREACHABLE = 1 << 7,
+	XT_ADDRTYPE_PROHIBIT = 1 << 8,
+	XT_ADDRTYPE_THROW = 1 << 9,
+	XT_ADDRTYPE_NAT = 1 << 10,
+	XT_ADDRTYPE_XRESOLVE = 1 << 11,
+};
+
 struct xt_addrtype_info_v1 {
 	__u16	source;		/* source-type mask */
 	__u16	dest;		/* dest-type mask */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 32bff6d..c3f988a 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -652,6 +652,7 @@ comment "Xtables matches"
 config NETFILTER_XT_MATCH_ADDRTYPE
 	tristate '"addrtype" address type match support'
 	depends on NETFILTER_ADVANCED
+	depends on (IPV6 || IPV6=n)
 	---help---
 	  This option allows you to match what routing thinks of an address,
 	  eg. UNICAST, LOCAL, BROADCAST, ...
diff --git a/net/netfilter/xt_addrtype.c b/net/netfilter/xt_addrtype.c
index e89c0b8..2220b85 100644
--- a/net/netfilter/xt_addrtype.c
+++ b/net/netfilter/xt_addrtype.c
@@ -16,6 +16,12 @@
 #include <linux/ip.h>
 #include <net/route.h>
 
+#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
+#include <net/ipv6.h>
+#include <net/ip6_route.h>
+#include <net/ip6_fib.h>
+#endif
+
 #include <linux/netfilter/xt_addrtype.h>
 #include <linux/netfilter/x_tables.h>
 
@@ -23,6 +29,73 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
 MODULE_DESCRIPTION("Xtables: address type match");
 MODULE_ALIAS("ipt_addrtype");
+MODULE_ALIAS("ip6t_addrtype");
+
+#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
+static u32 xt_addrtype_rt6_to_type(const struct rt6_info *rt)
+{
+	u32 ret;
+
+	if (!rt)
+		return XT_ADDRTYPE_UNREACHABLE;
+
+	if (rt->rt6i_flags & RTF_REJECT)
+		ret = XT_ADDRTYPE_UNREACHABLE;
+	else
+		ret = 0;
+
+	if (rt->rt6i_flags & RTF_LOCAL)
+		ret |= XT_ADDRTYPE_LOCAL;
+	if (rt->rt6i_flags & RTF_ANYCAST)
+		ret |= XT_ADDRTYPE_ANYCAST;
+	return ret;
+}
+
+static bool match_type6(struct net *net, const struct net_device *dev,
+				const struct in6_addr *addr, u16 mask)
+{
+	int addr_type = ipv6_addr_type(addr);
+
+	if ((mask & XT_ADDRTYPE_MULTICAST) &&
+	    !(addr_type & IPV6_ADDR_MULTICAST))
+		return false;
+	if ((mask & XT_ADDRTYPE_UNICAST) && !(addr_type & IPV6_ADDR_UNICAST))
+		return false;
+	if ((mask & XT_ADDRTYPE_UNSPEC) && addr_type != IPV6_ADDR_ANY)
+		return false;
+
+	if ((XT_ADDRTYPE_LOCAL | XT_ADDRTYPE_ANYCAST |
+	     XT_ADDRTYPE_UNREACHABLE) & mask) {
+		struct rt6_info *rt;
+		u32 type;
+		int ifindex = dev ? dev->ifindex : 0;
+
+		rt = rt6_lookup(net, addr, NULL, ifindex, !!dev);
+
+		type = xt_addrtype_rt6_to_type(rt);
+
+		dst_release(&rt->dst);
+		return !!(mask & type);
+	}
+	return true;
+}
+
+static bool
+addrtype_mt6(struct net *net, const struct net_device *dev,
+	const struct sk_buff *skb, const struct xt_addrtype_info_v1 *info)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	bool ret = true;
+
+	if (info->source)
+		ret &= match_type6(net, dev, &iph->saddr, info->source) ^
+		       (info->flags & XT_ADDRTYPE_INVERT_SOURCE);
+	if (ret && info->dest)
+		ret &= match_type6(net, dev, &iph->daddr, info->dest) ^
+		       !!(info->flags & XT_ADDRTYPE_INVERT_DEST);
+	return ret;
+}
+#endif
 
 static inline bool match_type(struct net *net, const struct net_device *dev,
 			      __be32 addr, u_int16_t mask)
@@ -53,7 +126,7 @@ addrtype_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct net *net = dev_net(par->in ? par->in : par->out);
 	const struct xt_addrtype_info_v1 *info = par->matchinfo;
-	const struct iphdr *iph = ip_hdr(skb);
+	const struct iphdr *iph;
 	const struct net_device *dev = NULL;
 	bool ret = true;
 
@@ -62,6 +135,11 @@ addrtype_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
 	else if (info->flags & XT_ADDRTYPE_LIMIT_IFACE_OUT)
 		dev = par->out;
 
+#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
+	if (par->family == NFPROTO_IPV6)
+		return addrtype_mt6(net, dev, skb, info);
+#endif
+	iph = ip_hdr(skb);
 	if (info->source)
 		ret &= match_type(net, dev, iph->saddr, info->source) ^
 		       (info->flags & XT_ADDRTYPE_INVERT_SOURCE);
@@ -98,6 +176,22 @@ static int addrtype_mt_checkentry_v1(const struct xt_mtchk_param *par)
 		return -EINVAL;
 	}
 
+#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
+	if (par->family == NFPROTO_IPV6) {
+		if ((info->source | info->dest) & XT_ADDRTYPE_BLACKHOLE) {
+			pr_err("ipv6 BLACKHOLE matching not supported\n");
+			return -EINVAL;
+		}
+		if ((info->source | info->dest) >= XT_ADDRTYPE_PROHIBIT) {
+			pr_err("ipv6 PROHIBT (THROW, NAT ..) matching not supported\n");
+			return -EINVAL;
+		}
+		if ((info->source | info->dest) & XT_ADDRTYPE_BROADCAST) {
+			pr_err("ipv6 does not support BROADCAST matching\n");
+			return -EINVAL;
+		}
+	}
+#endif
 	return 0;
 }
 
@@ -111,7 +205,7 @@ static struct xt_match addrtype_mt_reg[] __read_mostly = {
 	},
 	{
 		.name		= "addrtype",
-		.family		= NFPROTO_IPV4,
+		.family		= NFPROTO_UNSPEC,
 		.revision	= 1,
 		.match		= addrtype_mt_v1,
 		.checkentry	= addrtype_mt_checkentry_v1,
-- 
1.7.2.3

