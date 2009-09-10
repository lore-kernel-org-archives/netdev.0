From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 06/31: xtables: remove xt_connmark v0
Date: Thu, 10 Sep 2009 18:11:54 +0200 (MEST)
Message-ID: <20090910161150.31179.47207.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 84899a2b9adaf6c2e20d198d7c24562ce6b391d8
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Jun 12 18:50:33 2009 +0200

    netfilter: xtables: remove xt_connmark v0
    
    Superseded by xt_connmark v1 (v2.6.24-2919-g96e3227).
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 121e19c..54f9357 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -238,9 +238,6 @@ What (Why):
 	- "forwarding" header files like ipt_mac.h in
 	  include/linux/netfilter_ipv4/ and include/linux/netfilter_ipv6/
 
-	- xt_connmark match revision 0
-	  (superseded by xt_connmark match revision 1)
-
 	- xt_conntrack match revision 0
 	  (superseded by xt_conntrack match revision 1)
 
diff --git a/include/linux/netfilter/xt_connmark.h b/include/linux/netfilter/xt_connmark.h
index 571e266..619e47c 100644
--- a/include/linux/netfilter/xt_connmark.h
+++ b/include/linux/netfilter/xt_connmark.h
@@ -12,11 +12,6 @@
  * (at your option) any later version.
  */
 
-struct xt_connmark_info {
-	unsigned long mark, mask;
-	__u8 invert;
-};
-
 struct xt_connmark_mtinfo1 {
 	__u32 mark, mask;
 	__u8 invert;
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index 86cacab..122aa8b 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -47,36 +47,6 @@ connmark_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return ((ct->mark & info->mask) == info->mark) ^ info->invert;
 }
 
-static bool
-connmark_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
-{
-	const struct xt_connmark_info *info = par->matchinfo;
-	const struct nf_conn *ct;
-	enum ip_conntrack_info ctinfo;
-
-	ct = nf_ct_get(skb, &ctinfo);
-	if (!ct)
-		return false;
-
-	return ((ct->mark & info->mask) == info->mark) ^ info->invert;
-}
-
-static bool connmark_mt_check_v0(const struct xt_mtchk_param *par)
-{
-	const struct xt_connmark_info *cm = par->matchinfo;
-
-	if (cm->mark > 0xffffffff || cm->mask > 0xffffffff) {
-		printk(KERN_WARNING "connmark: only support 32bit mark\n");
-		return false;
-	}
-	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->family);
-		return false;
-	}
-	return true;
-}
-
 static bool connmark_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
@@ -92,74 +62,25 @@ static void connmark_mt_destroy(const struct xt_mtdtor_param *par)
 	nf_ct_l3proto_module_put(par->family);
 }
 
-#ifdef CONFIG_COMPAT
-struct compat_xt_connmark_info {
-	compat_ulong_t	mark, mask;
-	u_int8_t	invert;
-	u_int8_t	__pad1;
-	u_int16_t	__pad2;
-};
-
-static void connmark_mt_compat_from_user_v0(void *dst, void *src)
-{
-	const struct compat_xt_connmark_info *cm = src;
-	struct xt_connmark_info m = {
-		.mark	= cm->mark,
-		.mask	= cm->mask,
-		.invert	= cm->invert,
-	};
-	memcpy(dst, &m, sizeof(m));
-}
-
-static int connmark_mt_compat_to_user_v0(void __user *dst, void *src)
-{
-	const struct xt_connmark_info *m = src;
-	struct compat_xt_connmark_info cm = {
-		.mark	= m->mark,
-		.mask	= m->mask,
-		.invert	= m->invert,
-	};
-	return copy_to_user(dst, &cm, sizeof(cm)) ? -EFAULT : 0;
-}
-#endif /* CONFIG_COMPAT */
-
-static struct xt_match connmark_mt_reg[] __read_mostly = {
-	{
-		.name		= "connmark",
-		.revision	= 0,
-		.family		= NFPROTO_UNSPEC,
-		.checkentry	= connmark_mt_check_v0,
-		.match		= connmark_mt_v0,
-		.destroy	= connmark_mt_destroy,
-		.matchsize	= sizeof(struct xt_connmark_info),
-#ifdef CONFIG_COMPAT
-		.compatsize	= sizeof(struct compat_xt_connmark_info),
-		.compat_from_user = connmark_mt_compat_from_user_v0,
-		.compat_to_user	= connmark_mt_compat_to_user_v0,
-#endif
-		.me		= THIS_MODULE
-	},
-	{
-		.name           = "connmark",
-		.revision       = 1,
-		.family         = NFPROTO_UNSPEC,
-		.checkentry     = connmark_mt_check,
-		.match          = connmark_mt,
-		.matchsize      = sizeof(struct xt_connmark_mtinfo1),
-		.destroy        = connmark_mt_destroy,
-		.me             = THIS_MODULE,
-	},
+static struct xt_match connmark_mt_reg __read_mostly = {
+	.name           = "connmark",
+	.revision       = 1,
+	.family         = NFPROTO_UNSPEC,
+	.checkentry     = connmark_mt_check,
+	.match          = connmark_mt,
+	.matchsize      = sizeof(struct xt_connmark_mtinfo1),
+	.destroy        = connmark_mt_destroy,
+	.me             = THIS_MODULE,
 };
 
 static int __init connmark_mt_init(void)
 {
-	return xt_register_matches(connmark_mt_reg,
-	       ARRAY_SIZE(connmark_mt_reg));
+	return xt_register_match(&connmark_mt_reg);
 }
 
 static void __exit connmark_mt_exit(void)
 {
-	xt_unregister_matches(connmark_mt_reg, ARRAY_SIZE(connmark_mt_reg));
+	xt_unregister_match(&connmark_mt_reg);
 }
 
 module_init(connmark_mt_init);
