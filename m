From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 37/62: xtables: use xt_table for hook instantiation
Date: Tue, 16 Feb 2010 15:56:10 +0100 (MET)
Message-ID: <20100216145607.2796.11981.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52026 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932623Ab0BPO4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:11 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 2b95efe7f6bb750256a702cc32d33b0cb2cd8223
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Jun 17 13:57:48 2009 +0200

    netfilter: xtables: use xt_table for hook instantiation
    
    The respective xt_table structures already have most of the metadata
    needed for hook setup. Add a 'priority' field to struct xt_table so
    that xt_hook_link() can be called with a reduced number of arguments.
    
    So should we be having more tables in the future, it comes at no
    static cost (only runtime, as before) - space saved:
    6807373->6806555.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 365fabe..fdd3342 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -361,6 +361,7 @@ struct xt_table {
 	struct module *me;
 
 	u_int8_t af;		/* address/protocol family */
+	int priority;		/* hook order */
 
 	/* A unique name... */
 	const char name[XT_TABLE_MAXNAMELEN];
@@ -522,6 +523,9 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
 	return ret;
 }
 
+extern struct nf_hook_ops *xt_hook_link(const struct xt_table *, nf_hookfn *);
+extern void xt_hook_unlink(const struct xt_table *, struct nf_hook_ops *);
+
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
 
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index deeda9b..b361de0 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -50,6 +50,7 @@ static const struct xt_table packet_filter = {
 	.valid_hooks	= FILTER_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_ARP,
+	.priority	= NF_IP_PRI_FILTER,
 };
 
 /* The work comes in here from netfilter.c */
@@ -63,29 +64,7 @@ arptable_filter_hook(unsigned int hook, struct sk_buff *skb,
 	return arpt_do_table(skb, hook, in, out, net->ipv4.arptable_filter);
 }
 
-static struct nf_hook_ops arpt_ops[] __read_mostly = {
-	{
-		.hook		= arptable_filter_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_ARP,
-		.hooknum	= NF_ARP_IN,
-		.priority	= NF_IP_PRI_FILTER,
-	},
-	{
-		.hook		= arptable_filter_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_ARP,
-		.hooknum	= NF_ARP_OUT,
-		.priority	= NF_IP_PRI_FILTER,
-	},
-	{
-		.hook		= arptable_filter_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_ARP,
-		.hooknum	= NF_ARP_FORWARD,
-		.priority	= NF_IP_PRI_FILTER,
-	},
-};
+static struct nf_hook_ops *arpfilter_ops __read_mostly;
 
 static int __net_init arptable_filter_net_init(struct net *net)
 {
@@ -115,9 +94,11 @@ static int __init arptable_filter_init(void)
 	if (ret < 0)
 		return ret;
 
-	ret = nf_register_hooks(arpt_ops, ARRAY_SIZE(arpt_ops));
-	if (ret < 0)
+	arpfilter_ops = xt_hook_link(&packet_filter, arptable_filter_hook);
+	if (IS_ERR(arpfilter_ops)) {
+		ret = PTR_ERR(arpfilter_ops);
 		goto cleanup_table;
+	}
 	return ret;
 
 cleanup_table:
@@ -127,7 +108,7 @@ cleanup_table:
 
 static void __exit arptable_filter_fini(void)
 {
-	nf_unregister_hooks(arpt_ops, ARRAY_SIZE(arpt_ops));
+	xt_hook_unlink(&packet_filter, arpfilter_ops);
 	unregister_pernet_subsys(&arptable_filter_net_ops);
 }
 
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 1bfeaae..c14bb85 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -58,6 +58,7 @@ static const struct xt_table packet_filter = {
 	.valid_hooks	= FILTER_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_IPV4,
+	.priority	= NF_IP_PRI_FILTER,
 };
 
 static unsigned int
@@ -77,29 +78,7 @@ iptable_filter_hook(unsigned int hook, struct sk_buff *skb,
 	return ipt_do_table(skb, hook, in, out, net->ipv4.iptable_filter);
 }
 
-static struct nf_hook_ops ipt_ops[] __read_mostly = {
-	{
-		.hook		= iptable_filter_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= NF_IP_PRI_FILTER,
-	},
-	{
-		.hook		= iptable_filter_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_FORWARD,
-		.priority	= NF_IP_PRI_FILTER,
-	},
-	{
-		.hook		= iptable_filter_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= NF_IP_PRI_FILTER,
-	},
-};
+static struct nf_hook_ops *filter_ops __read_mostly;
 
 /* Default to forward because I got too much mail already. */
 static int forward = NF_ACCEPT;
@@ -142,9 +121,11 @@ static int __init iptable_filter_init(void)
 		return ret;
 
 	/* Register hooks */
-	ret = nf_register_hooks(ipt_ops, ARRAY_SIZE(ipt_ops));
-	if (ret < 0)
+	filter_ops = xt_hook_link(&packet_filter, iptable_filter_hook);
+	if (IS_ERR(filter_ops)) {
+		ret = PTR_ERR(filter_ops);
 		goto cleanup_table;
+	}
 
 	return ret;
 
@@ -155,7 +136,7 @@ static int __init iptable_filter_init(void)
 
 static void __exit iptable_filter_fini(void)
 {
-	nf_unregister_hooks(ipt_ops, ARRAY_SIZE(ipt_ops));
+	xt_hook_unlink(&packet_filter, filter_ops);
 	unregister_pernet_subsys(&iptable_filter_net_ops);
 }
 
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 4e699cd..2355a22 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -69,6 +69,7 @@ static const struct xt_table packet_mangler = {
 	.valid_hooks	= MANGLE_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_IPV4,
+	.priority	= NF_IP_PRI_MANGLE,
 };
 
 static unsigned int
@@ -129,43 +130,7 @@ iptable_mangle_hook(unsigned int hook,
 			    dev_net(in)->ipv4.iptable_mangle);
 }
 
-static struct nf_hook_ops ipt_ops[] __read_mostly = {
-	{
-		.hook		= iptable_mangle_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_PRE_ROUTING,
-		.priority	= NF_IP_PRI_MANGLE,
-	},
-	{
-		.hook		= iptable_mangle_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= NF_IP_PRI_MANGLE,
-	},
-	{
-		.hook		= iptable_mangle_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_FORWARD,
-		.priority	= NF_IP_PRI_MANGLE,
-	},
-	{
-		.hook		= iptable_mangle_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= NF_IP_PRI_MANGLE,
-	},
-	{
-		.hook		= iptable_mangle_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_POST_ROUTING,
-		.priority	= NF_IP_PRI_MANGLE,
-	},
-};
+static struct nf_hook_ops *mangle_ops __read_mostly;
 
 static int __net_init iptable_mangle_net_init(struct net *net)
 {
@@ -196,9 +161,11 @@ static int __init iptable_mangle_init(void)
 		return ret;
 
 	/* Register hooks */
-	ret = nf_register_hooks(ipt_ops, ARRAY_SIZE(ipt_ops));
-	if (ret < 0)
+	mangle_ops = xt_hook_link(&packet_mangler, iptable_mangle_hook);
+	if (IS_ERR(mangle_ops)) {
+		ret = PTR_ERR(mangle_ops);
 		goto cleanup_table;
+	}
 
 	return ret;
 
@@ -209,7 +176,7 @@ static int __init iptable_mangle_init(void)
 
 static void __exit iptable_mangle_fini(void)
 {
-	nf_unregister_hooks(ipt_ops, ARRAY_SIZE(ipt_ops));
+	xt_hook_unlink(&packet_mangler, mangle_ops);
 	unregister_pernet_subsys(&iptable_mangle_net_ops);
 }
 
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index d16e437..62a9915 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -41,6 +41,7 @@ static const struct xt_table packet_raw = {
 	.valid_hooks =  RAW_VALID_HOOKS,
 	.me = THIS_MODULE,
 	.af = NFPROTO_IPV4,
+	.priority = NF_IP_PRI_RAW,
 };
 
 /* The work comes in here from netfilter.c. */
@@ -61,23 +62,7 @@ iptable_raw_hook(unsigned int hook, struct sk_buff *skb,
 	return ipt_do_table(skb, hook, in, out, net->ipv4.iptable_raw);
 }
 
-/* 'raw' is the very first table. */
-static struct nf_hook_ops ipt_ops[] __read_mostly = {
-	{
-		.hook = iptable_raw_hook,
-		.pf = NFPROTO_IPV4,
-		.hooknum = NF_INET_PRE_ROUTING,
-		.priority = NF_IP_PRI_RAW,
-		.owner = THIS_MODULE,
-	},
-	{
-		.hook = iptable_raw_hook,
-		.pf = NFPROTO_IPV4,
-		.hooknum = NF_INET_LOCAL_OUT,
-		.priority = NF_IP_PRI_RAW,
-		.owner = THIS_MODULE,
-	},
-};
+static struct nf_hook_ops *rawtable_ops __read_mostly;
 
 static int __net_init iptable_raw_net_init(struct net *net)
 {
@@ -108,9 +93,11 @@ static int __init iptable_raw_init(void)
 		return ret;
 
 	/* Register hooks */
-	ret = nf_register_hooks(ipt_ops, ARRAY_SIZE(ipt_ops));
-	if (ret < 0)
+	rawtable_ops = xt_hook_link(&packet_raw, iptable_raw_hook);
+	if (IS_ERR(rawtable_ops)) {
+		ret = PTR_ERR(rawtable_ops);
 		goto cleanup_table;
+	}
 
 	return ret;
 
@@ -121,7 +108,7 @@ static int __init iptable_raw_init(void)
 
 static void __exit iptable_raw_fini(void)
 {
-	nf_unregister_hooks(ipt_ops, ARRAY_SIZE(ipt_ops));
+	xt_hook_unlink(&packet_raw, rawtable_ops);
 	unregister_pernet_subsys(&iptable_raw_net_ops);
 }
 
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index 324505a..b1bf3ca 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -62,6 +62,7 @@ static const struct xt_table security_table = {
 	.valid_hooks	= SECURITY_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_IPV4,
+	.priority	= NF_IP_PRI_SECURITY,
 };
 
 static unsigned int
@@ -82,29 +83,7 @@ iptable_security_hook(unsigned int hook, struct sk_buff *skb,
 	return ipt_do_table(skb, hook, in, out, net->ipv4.iptable_security);
 }
 
-static struct nf_hook_ops ipt_ops[] __read_mostly = {
-	{
-		.hook		= iptable_security_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= NF_IP_PRI_SECURITY,
-	},
-	{
-		.hook		= iptable_security_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_FORWARD,
-		.priority	= NF_IP_PRI_SECURITY,
-	},
-	{
-		.hook		= iptable_security_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= NF_IP_PRI_SECURITY,
-	},
-};
+static struct nf_hook_ops *sectbl_ops __read_mostly;
 
 static int __net_init iptable_security_net_init(struct net *net)
 {
@@ -135,9 +114,11 @@ static int __init iptable_security_init(void)
         if (ret < 0)
 		return ret;
 
-	ret = nf_register_hooks(ipt_ops, ARRAY_SIZE(ipt_ops));
-	if (ret < 0)
+	sectbl_ops = xt_hook_link(&security_table, iptable_security_hook);
+	if (IS_ERR(sectbl_ops)) {
+		ret = PTR_ERR(sectbl_ops);
 		goto cleanup_table;
+	}
 
 	return ret;
 
@@ -148,7 +129,7 @@ cleanup_table:
 
 static void __exit iptable_security_fini(void)
 {
-	nf_unregister_hooks(ipt_ops, ARRAY_SIZE(ipt_ops));
+	xt_hook_unlink(&security_table, sectbl_ops);
 	unregister_pernet_subsys(&iptable_security_net_ops);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 866f34a..6e95d06 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -56,6 +56,7 @@ static const struct xt_table packet_filter = {
 	.valid_hooks	= FILTER_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_IPV6,
+	.priority	= NF_IP6_PRI_FILTER,
 };
 
 /* The work comes in here from netfilter.c. */
@@ -69,29 +70,7 @@ ip6table_filter_hook(unsigned int hook, struct sk_buff *skb,
 	return ip6t_do_table(skb, hook, in, out, net->ipv6.ip6table_filter);
 }
 
-static struct nf_hook_ops ip6t_ops[] __read_mostly = {
-	{
-		.hook		= ip6table_filter_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= NF_IP6_PRI_FILTER,
-	},
-	{
-		.hook		= ip6table_filter_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_FORWARD,
-		.priority	= NF_IP6_PRI_FILTER,
-	},
-	{
-		.hook		= ip6table_filter_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= NF_IP6_PRI_FILTER,
-	},
-};
+static struct nf_hook_ops *filter_ops __read_mostly;
 
 /* Default to forward because I got too much mail already. */
 static int forward = NF_ACCEPT;
@@ -134,9 +113,11 @@ static int __init ip6table_filter_init(void)
 		return ret;
 
 	/* Register hooks */
-	ret = nf_register_hooks(ip6t_ops, ARRAY_SIZE(ip6t_ops));
-	if (ret < 0)
+	filter_ops = xt_hook_link(&packet_filter, ip6table_filter_hook);
+	if (IS_ERR(filter_ops)) {
+		ret = PTR_ERR(filter_ops);
 		goto cleanup_table;
+	}
 
 	return ret;
 
@@ -147,7 +128,7 @@ static int __init ip6table_filter_init(void)
 
 static void __exit ip6table_filter_fini(void)
 {
-	nf_unregister_hooks(ip6t_ops, ARRAY_SIZE(ip6t_ops));
+	xt_hook_unlink(&packet_filter, filter_ops);
 	unregister_pernet_subsys(&ip6table_filter_net_ops);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 405ac1f..5023ac5 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -62,6 +62,7 @@ static const struct xt_table packet_mangler = {
 	.valid_hooks	= MANGLE_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_IPV6,
+	.priority	= NF_IP6_PRI_MANGLE,
 };
 
 static unsigned int
@@ -122,44 +123,7 @@ ip6table_mangle_hook(unsigned int hook, struct sk_buff *skb,
 			     dev_net(in)->ipv6.ip6table_mangle);
 }
 
-static struct nf_hook_ops ip6t_ops[] __read_mostly = {
-	{
-		.hook		= ip6table_mangle_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_PRE_ROUTING,
-		.priority	= NF_IP6_PRI_MANGLE,
-	},
-	{
-		.hook		= ip6table_mangle_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= NF_IP6_PRI_MANGLE,
-	},
-	{
-		.hook		= ip6table_mangle_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_FORWARD,
-		.priority	= NF_IP6_PRI_MANGLE,
-	},
-	{
-		.hook		= ip6table_mangle_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= NF_IP6_PRI_MANGLE,
-	},
-	{
-		.hook		= ip6table_mangle_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_POST_ROUTING,
-		.priority	= NF_IP6_PRI_MANGLE,
-	},
-};
-
+static struct nf_hook_ops *mangle_ops __read_mostly;
 static int __net_init ip6table_mangle_net_init(struct net *net)
 {
 	/* Register table */
@@ -189,9 +153,11 @@ static int __init ip6table_mangle_init(void)
 		return ret;
 
 	/* Register hooks */
-	ret = nf_register_hooks(ip6t_ops, ARRAY_SIZE(ip6t_ops));
-	if (ret < 0)
+	mangle_ops = xt_hook_link(&packet_mangler, ip6table_mangle_hook);
+	if (IS_ERR(mangle_ops)) {
+		ret = PTR_ERR(mangle_ops);
 		goto cleanup_table;
+	}
 
 	return ret;
 
@@ -202,7 +168,7 @@ static int __init ip6table_mangle_init(void)
 
 static void __exit ip6table_mangle_fini(void)
 {
-	nf_unregister_hooks(ip6t_ops, ARRAY_SIZE(ip6t_ops));
+	xt_hook_unlink(&packet_mangler, mangle_ops);
 	unregister_pernet_subsys(&ip6table_mangle_net_ops);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 5451a36..3bfa695 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -40,6 +40,7 @@ static const struct xt_table packet_raw = {
 	.valid_hooks = RAW_VALID_HOOKS,
 	.me = THIS_MODULE,
 	.af = NFPROTO_IPV6,
+	.priority = NF_IP6_PRI_FIRST,
 };
 
 /* The work comes in here from netfilter.c. */
@@ -53,22 +54,7 @@ ip6table_raw_hook(unsigned int hook, struct sk_buff *skb,
 	return ip6t_do_table(skb, hook, in, out, net->ipv6.ip6table_raw);
 }
 
-static struct nf_hook_ops ip6t_ops[] __read_mostly = {
-	{
-	  .hook = ip6table_raw_hook,
-	  .pf = NFPROTO_IPV6,
-	  .hooknum = NF_INET_PRE_ROUTING,
-	  .priority = NF_IP6_PRI_FIRST,
-	  .owner = THIS_MODULE,
-	},
-	{
-	  .hook = ip6table_raw_hook,
-	  .pf = NFPROTO_IPV6,
-	  .hooknum = NF_INET_LOCAL_OUT,
-	  .priority = NF_IP6_PRI_FIRST,
-	  .owner = THIS_MODULE,
-	},
-};
+static struct nf_hook_ops *rawtable_ops __read_mostly;
 
 static int __net_init ip6table_raw_net_init(struct net *net)
 {
@@ -99,9 +85,11 @@ static int __init ip6table_raw_init(void)
 		return ret;
 
 	/* Register hooks */
-	ret = nf_register_hooks(ip6t_ops, ARRAY_SIZE(ip6t_ops));
-	if (ret < 0)
+	rawtable_ops = xt_hook_link(&packet_raw, ip6table_raw_hook);
+	if (IS_ERR(rawtable_ops)) {
+		ret = PTR_ERR(rawtable_ops);
 		goto cleanup_table;
+	}
 
 	return ret;
 
@@ -112,7 +100,7 @@ static int __init ip6table_raw_init(void)
 
 static void __exit ip6table_raw_fini(void)
 {
-	nf_unregister_hooks(ip6t_ops, ARRAY_SIZE(ip6t_ops));
+	xt_hook_unlink(&packet_raw, rawtable_ops);
 	unregister_pernet_subsys(&ip6table_raw_net_ops);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index 841ea77..dd2200f 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -61,6 +61,7 @@ static const struct xt_table security_table = {
 	.valid_hooks	= SECURITY_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_IPV6,
+	.priority	= NF_IP6_PRI_SECURITY,
 };
 
 static unsigned int
@@ -74,29 +75,7 @@ ip6table_security_hook(unsigned int hook, struct sk_buff *skb,
 	return ip6t_do_table(skb, hook, in, out, net->ipv6.ip6table_security);
 }
 
-static struct nf_hook_ops ip6t_ops[] __read_mostly = {
-	{
-		.hook		= ip6table_security_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= NF_IP6_PRI_SECURITY,
-	},
-	{
-		.hook		= ip6table_security_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_FORWARD,
-		.priority	= NF_IP6_PRI_SECURITY,
-	},
-	{
-		.hook		= ip6table_security_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= NF_IP6_PRI_SECURITY,
-	},
-};
+static struct nf_hook_ops *sectbl_ops __read_mostly;
 
 static int __net_init ip6table_security_net_init(struct net *net)
 {
@@ -127,9 +106,11 @@ static int __init ip6table_security_init(void)
 	if (ret < 0)
 		return ret;
 
-	ret = nf_register_hooks(ip6t_ops, ARRAY_SIZE(ip6t_ops));
-	if (ret < 0)
+	sectbl_ops = xt_hook_link(&security_table, ip6table_security_hook);
+	if (IS_ERR(sectbl_ops)) {
+		ret = PTR_ERR(sectbl_ops);
 		goto cleanup_table;
+	}
 
 	return ret;
 
@@ -140,7 +121,7 @@ cleanup_table:
 
 static void __exit ip6table_security_fini(void)
 {
-	nf_unregister_hooks(ip6t_ops, ARRAY_SIZE(ip6t_ops));
+	xt_hook_unlink(&security_table, sectbl_ops);
 	unregister_pernet_subsys(&ip6table_security_net_ops);
 }
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index f01955c..b51cb0d 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1091,6 +1091,60 @@ static const struct file_operations xt_target_ops = {
 
 #endif /* CONFIG_PROC_FS */
 
+/**
+ * xt_hook_link - set up hooks for a new table
+ * @table:	table with metadata needed to set up hooks
+ * @fn:		Hook function
+ *
+ * This function will take care of creating and registering the necessary
+ * Netfilter hooks for XT tables.
+ */
+struct nf_hook_ops *xt_hook_link(const struct xt_table *table, nf_hookfn *fn)
+{
+	unsigned int hook_mask = table->valid_hooks;
+	uint8_t i, num_hooks = hweight32(hook_mask);
+	uint8_t hooknum;
+	struct nf_hook_ops *ops;
+	int ret;
+
+	ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
+	if (ops == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	for (i = 0, hooknum = 0; i < num_hooks && hook_mask != 0;
+	     hook_mask >>= 1, ++hooknum) {
+		if (!(hook_mask & 1))
+			continue;
+		ops[i].hook     = fn;
+		ops[i].owner    = table->me;
+		ops[i].pf       = table->af;
+		ops[i].hooknum  = hooknum;
+		ops[i].priority = table->priority;
+		++i;
+	}
+
+	ret = nf_register_hooks(ops, num_hooks);
+	if (ret < 0) {
+		kfree(ops);
+		return ERR_PTR(ret);
+	}
+
+	return ops;
+}
+EXPORT_SYMBOL_GPL(xt_hook_link);
+
+/**
+ * xt_hook_unlink - remove hooks for a table
+ * @ops:	nf_hook_ops array as returned by nf_hook_link
+ * @hook_mask:	the very same mask that was passed to nf_hook_link
+ */
+void xt_hook_unlink(const struct xt_table *table, struct nf_hook_ops *ops)
+{
+	nf_unregister_hooks(ops, hweight32(table->valid_hooks));
+	kfree(ops);
+}
+EXPORT_SYMBOL_GPL(xt_hook_unlink);
+
 int xt_proto_init(struct net *net, u_int8_t af)
 {
 #ifdef CONFIG_PROC_FS
