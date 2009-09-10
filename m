From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 08/31: xtables: remove xt_iprange v0
Date: Thu, 10 Sep 2009 18:11:57 +0200 (MEST)
Message-ID: <20090910161152.31179.23526.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64643 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbZIJQLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:11:54 -0400
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 36d4084dc8eb7a9a3655a2041097a46aff3061e9
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Jun 12 18:58:19 2009 +0200

    netfilter: xtables: remove xt_iprange v0
    
    Superseded by xt_iprange v1 (v2.6.24-2928-g1a50c5a1).
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 6746473..8862b03 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -238,10 +238,6 @@ What (Why):
 	- "forwarding" header files like ipt_mac.h in
 	  include/linux/netfilter_ipv4/ and include/linux/netfilter_ipv6/
 
-	- xt_iprange match revision 0,
-	  include/linux/netfilter_ipv4/ipt_iprange.h
-	  (superseded by xt_iprange match revision 1)
-
 	- xt_mark match revision 0
 	  (superseded by xt_mark match revision 1)
 
diff --git a/include/linux/netfilter_ipv4/Kbuild b/include/linux/netfilter_ipv4/Kbuild
index 86d81a2..5e361ef 100644
--- a/include/linux/netfilter_ipv4/Kbuild
+++ b/include/linux/netfilter_ipv4/Kbuild
@@ -23,7 +23,6 @@ header-y += ipt_ecn.h
 header-y += ipt_esp.h
 header-y += ipt_hashlimit.h
 header-y += ipt_helper.h
-header-y += ipt_iprange.h
 header-y += ipt_length.h
 header-y += ipt_limit.h
 header-y += ipt_mac.h
diff --git a/include/linux/netfilter_ipv4/ipt_iprange.h b/include/linux/netfilter_ipv4/ipt_iprange.h
deleted file mode 100644
index 5f1aebd..0000000
--- a/include/linux/netfilter_ipv4/ipt_iprange.h
+++ /dev/null
@@ -1,21 +0,0 @@
-#ifndef _IPT_IPRANGE_H
-#define _IPT_IPRANGE_H
-
-#include <linux/types.h>
-#include <linux/netfilter/xt_iprange.h>
-
-struct ipt_iprange {
-	/* Inclusive: network order. */
-	__be32 min_ip, max_ip;
-};
-
-struct ipt_iprange_info
-{
-	struct ipt_iprange src;
-	struct ipt_iprange dst;
-
-	/* Flags from above */
-	u_int8_t flags;
-};
-
-#endif /* _IPT_IPRANGE_H */
diff --git a/net/netfilter/xt_iprange.c b/net/netfilter/xt_iprange.c
index 501f9b6..ffc9638 100644
--- a/net/netfilter/xt_iprange.c
+++ b/net/netfilter/xt_iprange.c
@@ -14,40 +14,6 @@
 #include <linux/ipv6.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_iprange.h>
-#include <linux/netfilter_ipv4/ipt_iprange.h>
-
-static bool
-iprange_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
-{
-	const struct ipt_iprange_info *info = par->matchinfo;
-	const struct iphdr *iph = ip_hdr(skb);
-
-	if (info->flags & IPRANGE_SRC) {
-		if ((ntohl(iph->saddr) < ntohl(info->src.min_ip)
-			  || ntohl(iph->saddr) > ntohl(info->src.max_ip))
-			 ^ !!(info->flags & IPRANGE_SRC_INV)) {
-			pr_debug("src IP %pI4 NOT in range %s%pI4-%pI4\n",
-				 &iph->saddr,
-				 info->flags & IPRANGE_SRC_INV ? "(INV) " : "",
-				 &info->src.min_ip,
-				 &info->src.max_ip);
-			return false;
-		}
-	}
-	if (info->flags & IPRANGE_DST) {
-		if ((ntohl(iph->daddr) < ntohl(info->dst.min_ip)
-			  || ntohl(iph->daddr) > ntohl(info->dst.max_ip))
-			 ^ !!(info->flags & IPRANGE_DST_INV)) {
-			pr_debug("dst IP %pI4 NOT in range %s%pI4-%pI4\n",
-				 &iph->daddr,
-				 info->flags & IPRANGE_DST_INV ? "(INV) " : "",
-				 &info->dst.min_ip,
-				 &info->dst.max_ip);
-			return false;
-		}
-	}
-	return true;
-}
 
 static bool
 iprange_mt4(const struct sk_buff *skb, const struct xt_match_param *par)
@@ -127,14 +93,6 @@ iprange_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 static struct xt_match iprange_mt_reg[] __read_mostly = {
 	{
 		.name      = "iprange",
-		.revision  = 0,
-		.family    = NFPROTO_IPV4,
-		.match     = iprange_mt_v0,
-		.matchsize = sizeof(struct ipt_iprange_info),
-		.me        = THIS_MODULE,
-	},
-	{
-		.name      = "iprange",
 		.revision  = 1,
 		.family    = NFPROTO_IPV4,
 		.match     = iprange_mt4,
@@ -164,7 +122,8 @@ static void __exit iprange_mt_exit(void)
 module_init(iprange_mt_init);
 module_exit(iprange_mt_exit);
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Jan Engelhardt <jengelh@computergmbh.de>");
+MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
+MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
 MODULE_DESCRIPTION("Xtables: arbitrary IPv4 range matching");
 MODULE_ALIAS("ipt_iprange");
 MODULE_ALIAS("ip6t_iprange");
