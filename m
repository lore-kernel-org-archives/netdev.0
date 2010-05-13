From: kaber@trash.net
Subject: [PATCH 08/12] netfilter: xtables: combine built-in extension structs
Date: Thu, 13 May 2010 18:16:21 +0200
Message-ID: <1273767385-18225-9-git-send-email-kaber@trash.net>
References: <1273767385-18225-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273767385-18225-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Prepare the arrays for use with the multiregister function. The
future layer-3 xt matches can then be easily added to it without
needing more (un)register code.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv4/netfilter/arp_tables.c |   41 +++++++++++--------------
 net/ipv4/netfilter/ip_tables.c  |   65 ++++++++++++++++++---------------------
 net/ipv6/netfilter/ip6_tables.c |   64 ++++++++++++++++++--------------------
 3 files changed, 78 insertions(+), 92 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 8cc56d2..03352fc 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1828,22 +1828,23 @@ void arpt_unregister_table(struct xt_table *table)
 }
 
 /* The built-in targets: standard (NULL) and error. */
-static struct xt_target arpt_standard_target __read_mostly = {
-	.name		= ARPT_STANDARD_TARGET,
-	.targetsize	= sizeof(int),
-	.family		= NFPROTO_ARP,
+static struct xt_target arpt_builtin_tg[] __read_mostly = {
+	{
+		.name             = ARPT_STANDARD_TARGET,
+		.targetsize       = sizeof(int),
+		.family           = NFPROTO_ARP,
 #ifdef CONFIG_COMPAT
-	.compatsize	= sizeof(compat_int_t),
-	.compat_from_user = compat_standard_from_user,
-	.compat_to_user	= compat_standard_to_user,
+		.compatsize       = sizeof(compat_int_t),
+		.compat_from_user = compat_standard_from_user,
+		.compat_to_user   = compat_standard_to_user,
 #endif
-};
-
-static struct xt_target arpt_error_target __read_mostly = {
-	.name		= ARPT_ERROR_TARGET,
-	.target		= arpt_error,
-	.targetsize	= ARPT_FUNCTION_MAXNAMELEN,
-	.family		= NFPROTO_ARP,
+	},
+	{
+		.name             = ARPT_ERROR_TARGET,
+		.target           = arpt_error,
+		.targetsize       = ARPT_FUNCTION_MAXNAMELEN,
+		.family           = NFPROTO_ARP,
+	},
 };
 
 static struct nf_sockopt_ops arpt_sockopts = {
@@ -1887,12 +1888,9 @@ static int __init arp_tables_init(void)
 		goto err1;
 
 	/* Noone else will be downing sem now, so we won't sleep */
-	ret = xt_register_target(&arpt_standard_target);
+	ret = xt_register_targets(arpt_builtin_tg, ARRAY_SIZE(arpt_builtin_tg));
 	if (ret < 0)
 		goto err2;
-	ret = xt_register_target(&arpt_error_target);
-	if (ret < 0)
-		goto err3;
 
 	/* Register setsockopt */
 	ret = nf_register_sockopt(&arpt_sockopts);
@@ -1903,9 +1901,7 @@ static int __init arp_tables_init(void)
 	return 0;
 
 err4:
-	xt_unregister_target(&arpt_error_target);
-err3:
-	xt_unregister_target(&arpt_standard_target);
+	xt_unregister_targets(arpt_builtin_tg, ARRAY_SIZE(arpt_builtin_tg));
 err2:
 	unregister_pernet_subsys(&arp_tables_net_ops);
 err1:
@@ -1915,8 +1911,7 @@ err1:
 static void __exit arp_tables_fini(void)
 {
 	nf_unregister_sockopt(&arpt_sockopts);
-	xt_unregister_target(&arpt_error_target);
-	xt_unregister_target(&arpt_standard_target);
+	xt_unregister_targets(arpt_builtin_tg, ARRAY_SIZE(arpt_builtin_tg));
 	unregister_pernet_subsys(&arp_tables_net_ops);
 }
 
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 607f89f..49b9e4f 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -2172,23 +2172,23 @@ static int icmp_checkentry(const struct xt_mtchk_param *par)
 	return (icmpinfo->invflags & ~IPT_ICMP_INV) ? -EINVAL : 0;
 }
 
-/* The built-in targets: standard (NULL) and error. */
-static struct xt_target ipt_standard_target __read_mostly = {
-	.name		= IPT_STANDARD_TARGET,
-	.targetsize	= sizeof(int),
-	.family		= NFPROTO_IPV4,
+static struct xt_target ipt_builtin_tg[] __read_mostly = {
+	{
+		.name             = IPT_STANDARD_TARGET,
+		.targetsize       = sizeof(int),
+		.family           = NFPROTO_IPV4,
 #ifdef CONFIG_COMPAT
-	.compatsize	= sizeof(compat_int_t),
-	.compat_from_user = compat_standard_from_user,
-	.compat_to_user	= compat_standard_to_user,
+		.compatsize       = sizeof(compat_int_t),
+		.compat_from_user = compat_standard_from_user,
+		.compat_to_user   = compat_standard_to_user,
 #endif
-};
-
-static struct xt_target ipt_error_target __read_mostly = {
-	.name		= IPT_ERROR_TARGET,
-	.target		= ipt_error,
-	.targetsize	= IPT_FUNCTION_MAXNAMELEN,
-	.family		= NFPROTO_IPV4,
+	},
+	{
+		.name             = IPT_ERROR_TARGET,
+		.target           = ipt_error,
+		.targetsize       = IPT_FUNCTION_MAXNAMELEN,
+		.family           = NFPROTO_IPV4,
+	},
 };
 
 static struct nf_sockopt_ops ipt_sockopts = {
@@ -2208,13 +2208,15 @@ static struct nf_sockopt_ops ipt_sockopts = {
 	.owner		= THIS_MODULE,
 };
 
-static struct xt_match icmp_matchstruct __read_mostly = {
-	.name		= "icmp",
-	.match		= icmp_match,
-	.matchsize	= sizeof(struct ipt_icmp),
-	.checkentry	= icmp_checkentry,
-	.proto		= IPPROTO_ICMP,
-	.family		= NFPROTO_IPV4,
+static struct xt_match ipt_builtin_mt[] __read_mostly = {
+	{
+		.name       = "icmp",
+		.match      = icmp_match,
+		.matchsize  = sizeof(struct ipt_icmp),
+		.checkentry = icmp_checkentry,
+		.proto      = IPPROTO_ICMP,
+		.family     = NFPROTO_IPV4,
+	},
 };
 
 static int __net_init ip_tables_net_init(struct net *net)
@@ -2241,13 +2243,10 @@ static int __init ip_tables_init(void)
 		goto err1;
 
 	/* Noone else will be downing sem now, so we won't sleep */
-	ret = xt_register_target(&ipt_standard_target);
+	ret = xt_register_targets(ipt_builtin_tg, ARRAY_SIZE(ipt_builtin_tg));
 	if (ret < 0)
 		goto err2;
-	ret = xt_register_target(&ipt_error_target);
-	if (ret < 0)
-		goto err3;
-	ret = xt_register_match(&icmp_matchstruct);
+	ret = xt_register_matches(ipt_builtin_mt, ARRAY_SIZE(ipt_builtin_mt));
 	if (ret < 0)
 		goto err4;
 
@@ -2260,11 +2259,9 @@ static int __init ip_tables_init(void)
 	return 0;
 
 err5:
-	xt_unregister_match(&icmp_matchstruct);
+	xt_unregister_matches(ipt_builtin_mt, ARRAY_SIZE(ipt_builtin_mt));
 err4:
-	xt_unregister_target(&ipt_error_target);
-err3:
-	xt_unregister_target(&ipt_standard_target);
+	xt_unregister_targets(ipt_builtin_tg, ARRAY_SIZE(ipt_builtin_tg));
 err2:
 	unregister_pernet_subsys(&ip_tables_net_ops);
 err1:
@@ -2275,10 +2272,8 @@ static void __exit ip_tables_fini(void)
 {
 	nf_unregister_sockopt(&ipt_sockopts);
 
-	xt_unregister_match(&icmp_matchstruct);
-	xt_unregister_target(&ipt_error_target);
-	xt_unregister_target(&ipt_standard_target);
-
+	xt_unregister_matches(ipt_builtin_mt, ARRAY_SIZE(ipt_builtin_mt));
+	xt_unregister_targets(ipt_builtin_tg, ARRAY_SIZE(ipt_builtin_tg));
 	unregister_pernet_subsys(&ip_tables_net_ops);
 }
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 557fac9..5678233 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -2190,22 +2190,23 @@ static int icmp6_checkentry(const struct xt_mtchk_param *par)
 }
 
 /* The built-in targets: standard (NULL) and error. */
-static struct xt_target ip6t_standard_target __read_mostly = {
-	.name		= IP6T_STANDARD_TARGET,
-	.targetsize	= sizeof(int),
-	.family		= NFPROTO_IPV6,
+static struct xt_target ip6t_builtin_tg[] __read_mostly = {
+	{
+		.name             = IP6T_STANDARD_TARGET,
+		.targetsize       = sizeof(int),
+		.family           = NFPROTO_IPV6,
 #ifdef CONFIG_COMPAT
-	.compatsize	= sizeof(compat_int_t),
-	.compat_from_user = compat_standard_from_user,
-	.compat_to_user	= compat_standard_to_user,
+		.compatsize       = sizeof(compat_int_t),
+		.compat_from_user = compat_standard_from_user,
+		.compat_to_user   = compat_standard_to_user,
 #endif
-};
-
-static struct xt_target ip6t_error_target __read_mostly = {
-	.name		= IP6T_ERROR_TARGET,
-	.target		= ip6t_error,
-	.targetsize	= IP6T_FUNCTION_MAXNAMELEN,
-	.family		= NFPROTO_IPV6,
+	},
+	{
+		.name             = IP6T_ERROR_TARGET,
+		.target           = ip6t_error,
+		.targetsize       = IP6T_FUNCTION_MAXNAMELEN,
+		.family           = NFPROTO_IPV6,
+	},
 };
 
 static struct nf_sockopt_ops ip6t_sockopts = {
@@ -2225,13 +2226,15 @@ static struct nf_sockopt_ops ip6t_sockopts = {
 	.owner		= THIS_MODULE,
 };
 
-static struct xt_match icmp6_matchstruct __read_mostly = {
-	.name		= "icmp6",
-	.match		= icmp6_match,
-	.matchsize	= sizeof(struct ip6t_icmp),
-	.checkentry	= icmp6_checkentry,
-	.proto		= IPPROTO_ICMPV6,
-	.family		= NFPROTO_IPV6,
+static struct xt_match ip6t_builtin_mt[] __read_mostly = {
+	{
+		.name       = "icmp6",
+		.match      = icmp6_match,
+		.matchsize  = sizeof(struct ip6t_icmp),
+		.checkentry = icmp6_checkentry,
+		.proto      = IPPROTO_ICMPV6,
+		.family     = NFPROTO_IPV6,
+	},
 };
 
 static int __net_init ip6_tables_net_init(struct net *net)
@@ -2258,13 +2261,10 @@ static int __init ip6_tables_init(void)
 		goto err1;
 
 	/* Noone else will be downing sem now, so we won't sleep */
-	ret = xt_register_target(&ip6t_standard_target);
+	ret = xt_register_targets(ip6t_builtin_tg, ARRAY_SIZE(ip6t_builtin_tg));
 	if (ret < 0)
 		goto err2;
-	ret = xt_register_target(&ip6t_error_target);
-	if (ret < 0)
-		goto err3;
-	ret = xt_register_match(&icmp6_matchstruct);
+	ret = xt_register_matches(ip6t_builtin_mt, ARRAY_SIZE(ip6t_builtin_mt));
 	if (ret < 0)
 		goto err4;
 
@@ -2277,11 +2277,9 @@ static int __init ip6_tables_init(void)
 	return 0;
 
 err5:
-	xt_unregister_match(&icmp6_matchstruct);
+	xt_unregister_matches(ip6t_builtin_mt, ARRAY_SIZE(ip6t_builtin_mt));
 err4:
-	xt_unregister_target(&ip6t_error_target);
-err3:
-	xt_unregister_target(&ip6t_standard_target);
+	xt_unregister_targets(ip6t_builtin_tg, ARRAY_SIZE(ip6t_builtin_tg));
 err2:
 	unregister_pernet_subsys(&ip6_tables_net_ops);
 err1:
@@ -2292,10 +2290,8 @@ static void __exit ip6_tables_fini(void)
 {
 	nf_unregister_sockopt(&ip6t_sockopts);
 
-	xt_unregister_match(&icmp6_matchstruct);
-	xt_unregister_target(&ip6t_error_target);
-	xt_unregister_target(&ip6t_standard_target);
-
+	xt_unregister_matches(ip6t_builtin_mt, ARRAY_SIZE(ip6t_builtin_mt));
+	xt_unregister_targets(ip6t_builtin_tg, ARRAY_SIZE(ip6t_builtin_tg));
 	unregister_pernet_subsys(&ip6_tables_net_ops);
 }
 
-- 
1.7.0.4

