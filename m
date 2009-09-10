From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 05/31: xtables: remove xt_MARK v0, v1
Date: Thu, 10 Sep 2009 18:11:53 +0200 (MEST)
Message-ID: <20090910161148.31179.74444.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64635 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbZIJQLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:11:50 -0400
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c8001f7fd5a4684280fddceed9fae9ea2e4fb521
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Jun 12 18:47:32 2009 +0200

    netfilter: xtables: remove xt_MARK v0, v1
    
    Superseded by xt_MARK v2 (v2.6.24-2918-ge0a812a).
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 7eccf94..121e19c 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -238,9 +238,6 @@ What (Why):
 	- "forwarding" header files like ipt_mac.h in
 	  include/linux/netfilter_ipv4/ and include/linux/netfilter_ipv6/
 
-	- xt_MARK target revisions 0 and 1
-	  (superseded by xt_MARK match revision 2)
-
 	- xt_connmark match revision 0
 	  (superseded by xt_connmark match revision 1)
 
diff --git a/include/linux/netfilter/xt_MARK.h b/include/linux/netfilter/xt_MARK.h
index 028304b..bc9561b 100644
--- a/include/linux/netfilter/xt_MARK.h
+++ b/include/linux/netfilter/xt_MARK.h
@@ -3,23 +3,6 @@
 
 #include <linux/types.h>
 
-/* Version 0 */
-struct xt_mark_target_info {
-	unsigned long mark;
-};
-
-/* Version 1 */
-enum {
-	XT_MARK_SET=0,
-	XT_MARK_AND,
-	XT_MARK_OR,
-};
-
-struct xt_mark_target_info_v1 {
-	unsigned long mark;
-	__u8 mode;
-};
-
 struct xt_mark_tginfo2 {
 	__u32 mark, mask;
 };
diff --git a/net/netfilter/xt_MARK.c b/net/netfilter/xt_MARK.c
index 67574bc..225f8d1 100644
--- a/net/netfilter/xt_MARK.c
+++ b/net/netfilter/xt_MARK.c
@@ -25,39 +25,6 @@ MODULE_ALIAS("ipt_MARK");
 MODULE_ALIAS("ip6t_MARK");
 
 static unsigned int
-mark_tg_v0(struct sk_buff *skb, const struct xt_target_param *par)
-{
-	const struct xt_mark_target_info *markinfo = par->targinfo;
-
-	skb->mark = markinfo->mark;
-	return XT_CONTINUE;
-}
-
-static unsigned int
-mark_tg_v1(struct sk_buff *skb, const struct xt_target_param *par)
-{
-	const struct xt_mark_target_info_v1 *markinfo = par->targinfo;
-	int mark = 0;
-
-	switch (markinfo->mode) {
-	case XT_MARK_SET:
-		mark = markinfo->mark;
-		break;
-
-	case XT_MARK_AND:
-		mark = skb->mark & markinfo->mark;
-		break;
-
-	case XT_MARK_OR:
-		mark = skb->mark | markinfo->mark;
-		break;
-	}
-
-	skb->mark = mark;
-	return XT_CONTINUE;
-}
-
-static unsigned int
 mark_tg(struct sk_buff *skb, const struct xt_target_param *par)
 {
 	const struct xt_mark_tginfo2 *info = par->targinfo;
@@ -66,135 +33,23 @@ mark_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return XT_CONTINUE;
 }
 
-static bool mark_tg_check_v0(const struct xt_tgchk_param *par)
-{
-	const struct xt_mark_target_info *markinfo = par->targinfo;
-
-	if (markinfo->mark > 0xffffffff) {
-		printk(KERN_WARNING "MARK: Only supports 32bit wide mark\n");
-		return false;
-	}
-	return true;
-}
-
-static bool mark_tg_check_v1(const struct xt_tgchk_param *par)
-{
-	const struct xt_mark_target_info_v1 *markinfo = par->targinfo;
-
-	if (markinfo->mode != XT_MARK_SET
-	    && markinfo->mode != XT_MARK_AND
-	    && markinfo->mode != XT_MARK_OR) {
-		printk(KERN_WARNING "MARK: unknown mode %u\n",
-		       markinfo->mode);
-		return false;
-	}
-	if (markinfo->mark > 0xffffffff) {
-		printk(KERN_WARNING "MARK: Only supports 32bit wide mark\n");
-		return false;
-	}
-	return true;
-}
-
-#ifdef CONFIG_COMPAT
-struct compat_xt_mark_target_info {
-	compat_ulong_t	mark;
-};
-
-static void mark_tg_compat_from_user_v0(void *dst, void *src)
-{
-	const struct compat_xt_mark_target_info *cm = src;
-	struct xt_mark_target_info m = {
-		.mark	= cm->mark,
-	};
-	memcpy(dst, &m, sizeof(m));
-}
-
-static int mark_tg_compat_to_user_v0(void __user *dst, void *src)
-{
-	const struct xt_mark_target_info *m = src;
-	struct compat_xt_mark_target_info cm = {
-		.mark	= m->mark,
-	};
-	return copy_to_user(dst, &cm, sizeof(cm)) ? -EFAULT : 0;
-}
-
-struct compat_xt_mark_target_info_v1 {
-	compat_ulong_t	mark;
-	u_int8_t	mode;
-	u_int8_t	__pad1;
-	u_int16_t	__pad2;
-};
-
-static void mark_tg_compat_from_user_v1(void *dst, void *src)
-{
-	const struct compat_xt_mark_target_info_v1 *cm = src;
-	struct xt_mark_target_info_v1 m = {
-		.mark	= cm->mark,
-		.mode	= cm->mode,
-	};
-	memcpy(dst, &m, sizeof(m));
-}
-
-static int mark_tg_compat_to_user_v1(void __user *dst, void *src)
-{
-	const struct xt_mark_target_info_v1 *m = src;
-	struct compat_xt_mark_target_info_v1 cm = {
-		.mark	= m->mark,
-		.mode	= m->mode,
-	};
-	return copy_to_user(dst, &cm, sizeof(cm)) ? -EFAULT : 0;
-}
-#endif /* CONFIG_COMPAT */
-
-static struct xt_target mark_tg_reg[] __read_mostly = {
-	{
-		.name		= "MARK",
-		.family		= NFPROTO_UNSPEC,
-		.revision	= 0,
-		.checkentry	= mark_tg_check_v0,
-		.target		= mark_tg_v0,
-		.targetsize	= sizeof(struct xt_mark_target_info),
-#ifdef CONFIG_COMPAT
-		.compatsize	= sizeof(struct compat_xt_mark_target_info),
-		.compat_from_user = mark_tg_compat_from_user_v0,
-		.compat_to_user	= mark_tg_compat_to_user_v0,
-#endif
-		.table		= "mangle",
-		.me		= THIS_MODULE,
-	},
-	{
-		.name		= "MARK",
-		.family		= NFPROTO_UNSPEC,
-		.revision	= 1,
-		.checkentry	= mark_tg_check_v1,
-		.target		= mark_tg_v1,
-		.targetsize	= sizeof(struct xt_mark_target_info_v1),
-#ifdef CONFIG_COMPAT
-		.compatsize	= sizeof(struct compat_xt_mark_target_info_v1),
-		.compat_from_user = mark_tg_compat_from_user_v1,
-		.compat_to_user	= mark_tg_compat_to_user_v1,
-#endif
-		.table		= "mangle",
-		.me		= THIS_MODULE,
-	},
-	{
-		.name           = "MARK",
-		.revision       = 2,
-		.family         = NFPROTO_UNSPEC,
-		.target         = mark_tg,
-		.targetsize     = sizeof(struct xt_mark_tginfo2),
-		.me             = THIS_MODULE,
-	},
+static struct xt_target mark_tg_reg __read_mostly = {
+	.name           = "MARK",
+	.revision       = 2,
+	.family         = NFPROTO_UNSPEC,
+	.target         = mark_tg,
+	.targetsize     = sizeof(struct xt_mark_tginfo2),
+	.me             = THIS_MODULE,
 };
 
 static int __init mark_tg_init(void)
 {
-	return xt_register_targets(mark_tg_reg, ARRAY_SIZE(mark_tg_reg));
+	return xt_register_target(&mark_tg_reg);
 }
 
 static void __exit mark_tg_exit(void)
 {
-	xt_unregister_targets(mark_tg_reg, ARRAY_SIZE(mark_tg_reg));
+	xt_unregister_target(&mark_tg_reg);
 }
 
 module_init(mark_tg_init);
