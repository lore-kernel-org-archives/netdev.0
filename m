From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/31: xtables: remove xt_TOS v0
Date: Thu, 10 Sep 2009 18:11:50 +0200 (MEST)
Message-ID: <20090910161146.31179.89454.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64628 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbZIJQLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:11:48 -0400
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 7cd1837b5d24417eca667d674a97bea936849785
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Jun 12 18:36:33 2009 +0200

    netfilter: xtables: remove xt_TOS v0
    
    Superseded by xt_TOS v1 (v2.6.24-2396-g5c350e5).
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index f8cd450..3aa4a77 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -235,9 +235,6 @@ Who:	Thomas Gleixner <tglx@linutronix.de>
 ---------------------------
 
 What (Why):
-	- include/linux/netfilter_ipv4/ipt_TOS.h ipt_tos.h header files
-	  (superseded by xt_TOS/xt_tos target & match)
-
 	- "forwarding" header files like ipt_mac.h in
 	  include/linux/netfilter_ipv4/ and include/linux/netfilter_ipv6/
 
diff --git a/include/linux/netfilter_ipv4/Kbuild b/include/linux/netfilter_ipv4/Kbuild
index 3a7105b..86d81a2 100644
--- a/include/linux/netfilter_ipv4/Kbuild
+++ b/include/linux/netfilter_ipv4/Kbuild
@@ -9,7 +9,6 @@ header-y += ipt_NFQUEUE.h
 header-y += ipt_REJECT.h
 header-y += ipt_SAME.h
 header-y += ipt_TCPMSS.h
-header-y += ipt_TOS.h
 header-y += ipt_TTL.h
 header-y += ipt_ULOG.h
 header-y += ipt_addrtype.h
@@ -40,7 +39,6 @@ header-y += ipt_sctp.h
 header-y += ipt_state.h
 header-y += ipt_string.h
 header-y += ipt_tcpmss.h
-header-y += ipt_tos.h
 header-y += ipt_ttl.h
 
 unifdef-y += ip_queue.h
diff --git a/include/linux/netfilter_ipv4/ipt_TOS.h b/include/linux/netfilter_ipv4/ipt_TOS.h
deleted file mode 100644
index 6bf9e1f..0000000
--- a/include/linux/netfilter_ipv4/ipt_TOS.h
+++ /dev/null
@@ -1,12 +0,0 @@
-#ifndef _IPT_TOS_H_target
-#define _IPT_TOS_H_target
-
-#ifndef IPTOS_NORMALSVC
-#define IPTOS_NORMALSVC 0
-#endif
-
-struct ipt_tos_target_info {
-	u_int8_t tos;
-};
-
-#endif /*_IPT_TOS_H_target*/
diff --git a/include/linux/netfilter_ipv4/ipt_tos.h b/include/linux/netfilter_ipv4/ipt_tos.h
deleted file mode 100644
index a21f5df..0000000
--- a/include/linux/netfilter_ipv4/ipt_tos.h
+++ /dev/null
@@ -1,13 +0,0 @@
-#ifndef _IPT_TOS_H
-#define _IPT_TOS_H
-
-struct ipt_tos_info {
-    u_int8_t tos;
-    u_int8_t invert;
-};
-
-#ifndef IPTOS_NORMALSVC
-#define IPTOS_NORMALSVC 0
-#endif
-
-#endif /*_IPT_TOS_H*/
diff --git a/net/netfilter/xt_DSCP.c b/net/netfilter/xt_DSCP.c
index 6a347e7..74ce892 100644
--- a/net/netfilter/xt_DSCP.c
+++ b/net/netfilter/xt_DSCP.c
@@ -18,7 +18,6 @@
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_DSCP.h>
-#include <linux/netfilter_ipv4/ipt_TOS.h>
 
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
 MODULE_DESCRIPTION("Xtables: DSCP/TOS field modification");
@@ -73,41 +72,6 @@ static bool dscp_tg_check(const struct xt_tgchk_param *par)
 }
 
 static unsigned int
-tos_tg_v0(struct sk_buff *skb, const struct xt_target_param *par)
-{
-	const struct ipt_tos_target_info *info = par->targinfo;
-	struct iphdr *iph = ip_hdr(skb);
-	u_int8_t oldtos;
-
-	if ((iph->tos & IPTOS_TOS_MASK) != info->tos) {
-		if (!skb_make_writable(skb, sizeof(struct iphdr)))
-			return NF_DROP;
-
-		iph      = ip_hdr(skb);
-		oldtos   = iph->tos;
-		iph->tos = (iph->tos & IPTOS_PREC_MASK) | info->tos;
-		csum_replace2(&iph->check, htons(oldtos), htons(iph->tos));
-	}
-
-	return XT_CONTINUE;
-}
-
-static bool tos_tg_check_v0(const struct xt_tgchk_param *par)
-{
-	const struct ipt_tos_target_info *info = par->targinfo;
-	const uint8_t tos = info->tos;
-
-	if (tos != IPTOS_LOWDELAY && tos != IPTOS_THROUGHPUT &&
-	    tos != IPTOS_RELIABILITY && tos != IPTOS_MINCOST &&
-	    tos != IPTOS_NORMALSVC) {
-		printk(KERN_WARNING "TOS: bad tos value %#x\n", tos);
-		return false;
-	}
-
-	return true;
-}
-
-static unsigned int
 tos_tg(struct sk_buff *skb, const struct xt_target_param *par)
 {
 	const struct xt_tos_target_info *info = par->targinfo;
@@ -168,16 +132,6 @@ static struct xt_target dscp_tg_reg[] __read_mostly = {
 	},
 	{
 		.name		= "TOS",
-		.revision	= 0,
-		.family		= NFPROTO_IPV4,
-		.table		= "mangle",
-		.target		= tos_tg_v0,
-		.targetsize	= sizeof(struct ipt_tos_target_info),
-		.checkentry	= tos_tg_check_v0,
-		.me		= THIS_MODULE,
-	},
-	{
-		.name		= "TOS",
 		.revision	= 1,
 		.family		= NFPROTO_IPV4,
 		.table		= "mangle",
diff --git a/net/netfilter/xt_dscp.c b/net/netfilter/xt_dscp.c
index c3f8085..0280d3a 100644
--- a/net/netfilter/xt_dscp.c
+++ b/net/netfilter/xt_dscp.c
@@ -15,7 +15,6 @@
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_dscp.h>
-#include <linux/netfilter_ipv4/ipt_tos.h>
 
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
 MODULE_DESCRIPTION("Xtables: DSCP/TOS field match");
@@ -55,14 +54,6 @@ static bool dscp_mt_check(const struct xt_mtchk_param *par)
 	return true;
 }
 
-static bool
-tos_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
-{
-	const struct ipt_tos_info *info = par->matchinfo;
-
-	return (ip_hdr(skb)->tos == info->tos) ^ info->invert;
-}
-
 static bool tos_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
 	const struct xt_tos_match_info *info = par->matchinfo;
@@ -94,14 +85,6 @@ static struct xt_match dscp_mt_reg[] __read_mostly = {
 	},
 	{
 		.name		= "tos",
-		.revision	= 0,
-		.family		= NFPROTO_IPV4,
-		.match		= tos_mt_v0,
-		.matchsize	= sizeof(struct ipt_tos_info),
-		.me		= THIS_MODULE,
-	},
-	{
-		.name		= "tos",
 		.revision	= 1,
 		.family		= NFPROTO_IPV4,
 		.match		= tos_mt,
