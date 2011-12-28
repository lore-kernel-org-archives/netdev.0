From: pablo@netfilter.org
Subject: [PATCH 3/5] netfilter: xtables: add an IPv6 capable version of the ECN match
Date: Wed, 28 Dec 2011 14:39:31 +0100
Message-ID: <1325079573-6120-4-git-send-email-pablo@netfilter.org>
References: <1325079573-6120-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, jengelh@medozas.de,
	kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1325079573-6120-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

References: http://www.spinics.net/lists/netfilter-devel/msg18875.html

Augment xt_ecn by facilities to match on IPv6 packets' DSCP/TOS field
similar to how it is already done for the IPv4 packet field.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_ecn.c |  106 ++++++++++++++++++++++++++++++++++++------------
 1 files changed, 80 insertions(+), 26 deletions(-)

diff --git a/net/netfilter/xt_ecn.c b/net/netfilter/xt_ecn.c
index 3ebb3dc..6ccc35d 100644
--- a/net/netfilter/xt_ecn.c
+++ b/net/netfilter/xt_ecn.c
@@ -1,6 +1,8 @@
-/* IP tables module for matching the value of the IPv4 and TCP ECN bits
+/*
+ * Xtables module for matching the value of the IPv4/IPv6 and TCP ECN bits
  *
  * (C) 2002 by Harald Welte <laforge@gnumonks.org>
+ * (C) 2011 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -17,32 +19,25 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_ecn.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
 
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
-MODULE_DESCRIPTION("Xtables: Explicit Congestion Notification (ECN) flag match for IPv4");
+MODULE_DESCRIPTION("Xtables: Explicit Congestion Notification (ECN) flag match");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_ecn");
+MODULE_ALIAS("ip6t_ecn");
 
-static inline bool match_ip(const struct sk_buff *skb,
-			    const struct xt_ecn_info *einfo)
-{
-	return ((ip_hdr(skb)->tos & XT_ECN_IP_MASK) == einfo->ip_ect) ^
-	       !!(einfo->invert & XT_ECN_OP_MATCH_IP);
-}
-
-static inline bool match_tcp(const struct sk_buff *skb,
-			     const struct xt_ecn_info *einfo,
-			     bool *hotdrop)
+static bool match_tcp(const struct sk_buff *skb, struct xt_action_param *par)
 {
+	const struct xt_ecn_info *einfo = par->matchinfo;
 	struct tcphdr _tcph;
 	const struct tcphdr *th;
 
 	/* In practice, TCP match does this, so can't fail.  But let's
 	 * be good citizens.
 	 */
-	th = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_tcph), &_tcph);
+	th = skb_header_pointer(skb, par->thoff, sizeof(_tcph), &_tcph);
 	if (th == NULL) {
-		*hotdrop = false;
 		return false;
 	}
 
@@ -69,7 +64,14 @@ static inline bool match_tcp(const struct sk_buff *skb,
 	return true;
 }
 
-static bool ecn_mt(const struct sk_buff *skb, struct xt_action_param *par)
+static inline bool match_ip(const struct sk_buff *skb,
+			    const struct xt_ecn_info *einfo)
+{
+	return ((ip_hdr(skb)->tos & XT_ECN_IP_MASK) == einfo->ip_ect) ^
+	       !!(einfo->invert & XT_ECN_OP_MATCH_IP);
+}
+
+static bool ecn_mt4(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_ecn_info *info = par->matchinfo;
 
@@ -78,14 +80,14 @@ static bool ecn_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			return false;
 
 	if (info->operation & (XT_ECN_OP_MATCH_ECE | XT_ECN_OP_MATCH_CWR)) {
-		if (!match_tcp(skb, info, &par->hotdrop))
+		if (!match_tcp(skb, par))
 			return false;
 	}
 
 	return true;
 }
 
-static int ecn_mt_check(const struct xt_mtchk_param *par)
+static int ecn_mt_check4(const struct xt_mtchk_param *par)
 {
 	const struct xt_ecn_info *info = par->matchinfo;
 	const struct ipt_ip *ip = par->entryinfo;
@@ -105,23 +107,75 @@ static int ecn_mt_check(const struct xt_mtchk_param *par)
 	return 0;
 }
 
-static struct xt_match ecn_mt_reg __read_mostly = {
-	.name		= "ecn",
-	.family		= NFPROTO_IPV4,
-	.match		= ecn_mt,
-	.matchsize	= sizeof(struct xt_ecn_info),
-	.checkentry	= ecn_mt_check,
-	.me		= THIS_MODULE,
+static inline bool match_ipv6(const struct sk_buff *skb,
+			      const struct xt_ecn_info *einfo)
+{
+	return (((ipv6_hdr(skb)->flow_lbl[0] >> 4) & XT_ECN_IP_MASK) ==
+	        einfo->ip_ect) ^
+	       !!(einfo->invert & XT_ECN_OP_MATCH_IP);
+}
+
+static bool ecn_mt6(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_ecn_info *info = par->matchinfo;
+
+	if (info->operation & XT_ECN_OP_MATCH_IP && !match_ipv6(skb, info))
+		return false;
+
+	if (info->operation & (XT_ECN_OP_MATCH_ECE | XT_ECN_OP_MATCH_CWR) &&
+	    !match_tcp(skb, par))
+		return false;
+
+	return true;
+}
+
+static int ecn_mt_check6(const struct xt_mtchk_param *par)
+{
+	const struct xt_ecn_info *info = par->matchinfo;
+	const struct ip6t_ip6 *ip = par->entryinfo;
+
+	if (info->operation & XT_ECN_OP_MATCH_MASK)
+		return -EINVAL;
+
+	if (info->invert & XT_ECN_OP_MATCH_MASK)
+		return -EINVAL;
+
+	if (info->operation & (XT_ECN_OP_MATCH_ECE | XT_ECN_OP_MATCH_CWR) &&
+	    (ip->proto != IPPROTO_TCP || ip->invflags & IP6T_INV_PROTO)) {
+		pr_info("cannot match TCP bits in rule for non-tcp packets\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static struct xt_match ecn_mt_reg[] __read_mostly = {
+	{
+		.name		= "ecn",
+		.family		= NFPROTO_IPV4,
+		.match		= ecn_mt4,
+		.matchsize	= sizeof(struct xt_ecn_info),
+		.checkentry	= ecn_mt_check4,
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "ecn",
+		.family		= NFPROTO_IPV6,
+		.match		= ecn_mt6,
+		.matchsize	= sizeof(struct xt_ecn_info),
+		.checkentry	= ecn_mt_check6,
+		.me		= THIS_MODULE,
+	},
 };
 
 static int __init ecn_mt_init(void)
 {
-	return xt_register_match(&ecn_mt_reg);
+	return xt_register_matches(ecn_mt_reg, ARRAY_SIZE(ecn_mt_reg));
 }
 
 static void __exit ecn_mt_exit(void)
 {
-	xt_unregister_match(&ecn_mt_reg);
+	xt_unregister_matches(ecn_mt_reg, ARRAY_SIZE(ecn_mt_reg));
 }
 
 module_init(ecn_mt_init);
-- 
1.7.7.3

