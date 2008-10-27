From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 08/09]IPtablestng/KernelSpace - patch tables modules
Date: Mon, 27 Oct 2008 08:27:53 +0330 (IRST)
Message-ID: <20081027045753.B3302C64090@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [85.185.161.20] ([85.185.161.20]:39688 "EHLO host1.ystp.ac.ir"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751561AbYJ0FTi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 01:19:38 -0400
cc: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Patrick McHardy <kaber@trash.net>
cc: Jan Engelhardt <jengelh@medozas.de>
cc: David Miller <davem@davemloft.net>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Harald Welte <laforge@gnumonks.org>
cc: Eric Leblond <eric@inl.fr>
cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
cc: Amin Azez <azez@ufomechanic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

change the tables register/unregister methods and other features for compatiblity.

beacause of new structurs for table register/unregister processes, table modules(filter, nat, mangle, row) are changed to work with this new structures. 
by this modules thay will call "pktt_table_trigger" instead of "ipt_do_table".

diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 69f3d7e..aa56e89 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -8,6 +8,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  *
+ * Changed On 2008 to work with pkt_tables, Hamid Jafarian (hm.t.) <hamid.jafarian@gmail.com>
  */
 
 #include <linux/module.h>
@@ -23,42 +24,14 @@ MODULE_DESCRIPTION("iptables filter table");
 			    (1 << NF_INET_FORWARD) | \
 			    (1 << NF_INET_LOCAL_OUT))
 
-static struct
-{
-	struct ipt_replace repl;
-	struct ipt_standard entries[3];
-	struct ipt_error term;
-} initial_table __net_initdata = {
-	.repl = {
-		.name = "filter",
-		.valid_hooks = FILTER_VALID_HOOKS,
-		.num_entries = 4,
-		.size = sizeof(struct ipt_standard) * 3 + sizeof(struct ipt_error),
-		.hook_entry = {
-			[NF_INET_LOCAL_IN] = 0,
-			[NF_INET_FORWARD] = sizeof(struct ipt_standard),
-			[NF_INET_LOCAL_OUT] = sizeof(struct ipt_standard) * 2,
-		},
-		.underflow = {
-			[NF_INET_LOCAL_IN] = 0,
-			[NF_INET_FORWARD] = sizeof(struct ipt_standard),
-			[NF_INET_LOCAL_OUT] = sizeof(struct ipt_standard) * 2,
-		},
-	},
-	.entries = {
-		IPT_STANDARD_INIT(NF_ACCEPT),	/* LOCAL_IN */
-		IPT_STANDARD_INIT(NF_ACCEPT),	/* FORWARD */
-		IPT_STANDARD_INIT(NF_ACCEPT),	/* LOCAL_OUT */
-	},
-	.term = IPT_ERROR_INIT,			/* ERROR */
-};
-
-static struct xt_table packet_filter = {
+static struct pktt_regtable packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= RW_LOCK_UNLOCKED,
-	.me		= THIS_MODULE,
-	.af		= AF_INET,
+	.family		= AF_INET,
+	.owner		= THIS_MODULE,
+	.hooks_policy	= { 	[NF_INET_LOCAL_IN] = cACCEPT,
+				[NF_INET_LOCAL_OUT] = cACCEPT,
+				[NF_INET_FORWARD] = cACCEPT, },
 };
 
 /* The work comes in here from netfilter.c. */
@@ -69,7 +42,7 @@ ipt_hook(unsigned int hook,
 	 const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	return ipt_do_table(skb, hook, in, out, init_net.ipv4.iptable_filter);
+	return pktt_table_trigger(skb, hook, in, out, &packet_filter);
 }
 
 static unsigned int
@@ -88,7 +61,7 @@ ipt_local_out_hook(unsigned int hook,
 		return NF_ACCEPT;
 	}
 
-	return ipt_do_table(skb, hook, in, out, init_net.ipv4.iptable_filter);
+	return pktt_table_trigger(skb, hook, in, out, &packet_filter);
 }
 
 static struct nf_hook_ops ipt_ops[] __read_mostly = {
@@ -122,16 +95,13 @@ module_param(forward, bool, 0000);
 static int __net_init iptable_filter_net_init(struct net *net)
 {
 	/* Register table */
-	net->ipv4.iptable_filter =
-		ipt_register_table(net, &packet_filter, &initial_table.repl);
-	if (IS_ERR(net->ipv4.iptable_filter))
-		return PTR_ERR(net->ipv4.iptable_filter);
-	return 0;
+	int ret = pktt_register_table(net, &packet_filter);
+	return ret;
 }
 
 static void __net_exit iptable_filter_net_exit(struct net *net)
 {
-	ipt_unregister_table(net->ipv4.iptable_filter);
+	pktt_unregister_table(&packet_filter);
 }
 
 static struct pernet_operations iptable_filter_net_ops = {
@@ -149,7 +119,8 @@ static int __init iptable_filter_init(void)
 	}
 
 	/* Entry 1 is the FORWARD hook */
-	initial_table.entries[1].target.verdict = -forward - 1;
+	//initial_table.entries[1].target.verdict = -forward - 1;
+	packet_filter.hooks_policy[NF_INET_FORWARD]= forward? cACCEPT:cDROP;	
 
 	ret = register_pernet_subsys(&iptable_filter_net_ops);
 	if (ret < 0)
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index c55a210..a759f35 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -7,6 +7,8 @@
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
+ *
+ * Changed On 2008 to work with pkt_tables, Hamid Jafarian (hm.t.) <hamid.jafarian@gmail.com>
  */
 #include <linux/module.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
@@ -27,49 +29,16 @@ MODULE_DESCRIPTION("iptables mangle table");
 			    (1 << NF_INET_LOCAL_OUT) | \
 			    (1 << NF_INET_POST_ROUTING))
 
-/* Ouch - five different hooks? Maybe this should be a config option..... -- BC */
-static struct
-{
-	struct ipt_replace repl;
-	struct ipt_standard entries[5];
-	struct ipt_error term;
-} initial_table __net_initdata = {
-	.repl = {
-		.name = "mangle",
-		.valid_hooks = MANGLE_VALID_HOOKS,
-		.num_entries = 6,
-		.size = sizeof(struct ipt_standard) * 5 + sizeof(struct ipt_error),
-		.hook_entry = {
-			[NF_INET_PRE_ROUTING] 	= 0,
-			[NF_INET_LOCAL_IN] 	= sizeof(struct ipt_standard),
-			[NF_INET_FORWARD] 	= sizeof(struct ipt_standard) * 2,
-			[NF_INET_LOCAL_OUT] 	= sizeof(struct ipt_standard) * 3,
-			[NF_INET_POST_ROUTING] 	= sizeof(struct ipt_standard) * 4,
-		},
-		.underflow = {
-			[NF_INET_PRE_ROUTING] 	= 0,
-			[NF_INET_LOCAL_IN] 	= sizeof(struct ipt_standard),
-			[NF_INET_FORWARD] 	= sizeof(struct ipt_standard) * 2,
-			[NF_INET_LOCAL_OUT] 	= sizeof(struct ipt_standard) * 3,
-			[NF_INET_POST_ROUTING]	= sizeof(struct ipt_standard) * 4,
-		},
-	},
-	.entries = {
-		IPT_STANDARD_INIT(NF_ACCEPT),	/* PRE_ROUTING */
-		IPT_STANDARD_INIT(NF_ACCEPT),	/* LOCAL_IN */
-		IPT_STANDARD_INIT(NF_ACCEPT),	/* FORWARD */
-		IPT_STANDARD_INIT(NF_ACCEPT),	/* LOCAL_OUT */
-		IPT_STANDARD_INIT(NF_ACCEPT),	/* POST_ROUTING */
-	},
-	.term = IPT_ERROR_INIT,			/* ERROR */
-};
-
-static struct xt_table packet_mangler = {
-	.name		= "mangle",
-	.valid_hooks	= MANGLE_VALID_HOOKS,
-	.lock		= RW_LOCK_UNLOCKED,
-	.me		= THIS_MODULE,
-	.af		= AF_INET,
+static struct pktt_regtable packet_mangler = {
+        .name           = "mangle",
+        .valid_hooks    = MANGLE_VALID_HOOKS,
+        .family         = AF_INET,
+        .owner          = THIS_MODULE,
+        .hooks_policy   = {     [NF_INET_LOCAL_IN] = cACCEPT,
+                                [NF_INET_LOCAL_OUT] = cACCEPT,
+                                [NF_INET_FORWARD] = cACCEPT,
+                                [NF_INET_POST_ROUTING] = cACCEPT,
+                                [NF_INET_PRE_ROUTING] = cACCEPT, },
 };
 
 /* The work comes in here from netfilter.c. */
@@ -80,7 +49,7 @@ ipt_route_hook(unsigned int hook,
 	 const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	return ipt_do_table(skb, hook, in, out, init_net.ipv4.iptable_mangle);
+	return pktt_table_trigger(skb, hook, in, out, &packet_mangler);
 }
 
 static unsigned int
@@ -112,7 +81,8 @@ ipt_local_hook(unsigned int hook,
 	daddr = iph->daddr;
 	tos = iph->tos;
 
-	ret = ipt_do_table(skb, hook, in, out, init_net.ipv4.iptable_mangle);
+	//ret = ipt_do_table(skb, hook, in, out, &packet_mangler);
+	ret = pktt_table_trigger(skb, hook, in, out, &packet_mangler);
 	/* Reroute for ANY change. */
 	if (ret != NF_DROP && ret != NF_STOLEN && ret != NF_QUEUE) {
 		iph = ip_hdr(skb);
@@ -169,16 +139,13 @@ static struct nf_hook_ops ipt_ops[] __read_mostly = {
 static int __net_init iptable_mangle_net_init(struct net *net)
 {
 	/* Register table */
-	net->ipv4.iptable_mangle =
-		ipt_register_table(net, &packet_mangler, &initial_table.repl);
-	if (IS_ERR(net->ipv4.iptable_mangle))
-		return PTR_ERR(net->ipv4.iptable_mangle);
-	return 0;
+	int ret = pktt_register_table(net, &packet_mangler);
+	return ret;
 }
 
 static void __net_exit iptable_mangle_net_exit(struct net *net)
 {
-	ipt_unregister_table(net->ipv4.iptable_mangle);
+	pktt_unregister_table(&packet_mangler);
 }
 
 static struct pernet_operations iptable_mangle_net_ops = {
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index e41fe8c..989b77f 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -2,6 +2,8 @@
  * 'raw' table, which is the very first hooked in at PRE_ROUTING and LOCAL_OUT .
  *
  * Copyright (C) 2003 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ *
+ * Changed On 2008 to work with pkt_tables, Hamid Jafarian (hm.t.) <hamid.jafarian@gmail.com>
  */
 #include <linux/module.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
@@ -9,39 +11,13 @@
 
 #define RAW_VALID_HOOKS ((1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT))
 
-static struct
-{
-	struct ipt_replace repl;
-	struct ipt_standard entries[2];
-	struct ipt_error term;
-} initial_table __net_initdata = {
-	.repl = {
-		.name = "raw",
-		.valid_hooks = RAW_VALID_HOOKS,
-		.num_entries = 3,
-		.size = sizeof(struct ipt_standard) * 2 + sizeof(struct ipt_error),
-		.hook_entry = {
-			[NF_INET_PRE_ROUTING] = 0,
-			[NF_INET_LOCAL_OUT] = sizeof(struct ipt_standard)
-		},
-		.underflow = {
-			[NF_INET_PRE_ROUTING] = 0,
-			[NF_INET_LOCAL_OUT]  = sizeof(struct ipt_standard)
-		},
-	},
-	.entries = {
-		IPT_STANDARD_INIT(NF_ACCEPT),	/* PRE_ROUTING */
-		IPT_STANDARD_INIT(NF_ACCEPT),	/* LOCAL_OUT */
-	},
-	.term = IPT_ERROR_INIT,			/* ERROR */
-};
-
-static struct xt_table packet_raw = {
-	.name = "raw",
-	.valid_hooks =  RAW_VALID_HOOKS,
-	.lock = RW_LOCK_UNLOCKED,
-	.me = THIS_MODULE,
-	.af = AF_INET,
+static struct pktt_regtable packet_raw = {
+	.name		= "raw",
+	.valid_hooks	= RAW_VALID_HOOKS,
+	.family		= AF_INET,
+	.owner		= THIS_MODULE,
+	.hooks_policy	= {	[NF_INET_LOCAL_OUT] = cACCEPT,
+				[NF_INET_PRE_ROUTING] = cACCEPT, },
 };
 
 /* The work comes in here from netfilter.c. */
@@ -52,7 +28,7 @@ ipt_hook(unsigned int hook,
 	 const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	return ipt_do_table(skb, hook, in, out, init_net.ipv4.iptable_raw);
+	return pktt_table_trigger(skb, hook, in, out, &packet_raw);
 }
 
 static unsigned int
@@ -70,7 +46,7 @@ ipt_local_hook(unsigned int hook,
 			       "packet.\n");
 		return NF_ACCEPT;
 	}
-	return ipt_do_table(skb, hook, in, out, init_net.ipv4.iptable_raw);
+	return pktt_table_trigger(skb, hook, in, out, &packet_raw);
 }
 
 /* 'raw' is the very first table. */
@@ -94,16 +70,13 @@ static struct nf_hook_ops ipt_ops[] __read_mostly = {
 static int __net_init iptable_raw_net_init(struct net *net)
 {
 	/* Register table */
-	net->ipv4.iptable_raw =
-		ipt_register_table(net, &packet_raw, &initial_table.repl);
-	if (IS_ERR(net->ipv4.iptable_raw))
-		return PTR_ERR(net->ipv4.iptable_raw);
-	return 0;
+	int ret = pktt_register_table(net, &packet_raw);
+	return ret;
 }
 
 static void __net_exit iptable_raw_net_exit(struct net *net)
 {
-	ipt_unregister_table(net->ipv4.iptable_raw);
+	pktt_unregister_table(&packet_raw);
 }
 
 static struct pernet_operations iptable_raw_net_ops = {
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index f8fda57..99bd6e6 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -4,6 +4,8 @@
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
+ *
+ * Changed On 2008 to work with pkt_tables, Hamid Jafarian (hm.t.) <hamid.jafarian@gmail.com>
  */
 
 /* Everything about the rules for NAT. */
@@ -28,44 +30,15 @@
 			 (1 << NF_INET_POST_ROUTING) | \
 			 (1 << NF_INET_LOCAL_OUT))
 
-static struct
-{
-	struct ipt_replace repl;
-	struct ipt_standard entries[3];
-	struct ipt_error term;
-} nat_initial_table __initdata = {
-	.repl = {
-		.name = "nat",
-		.valid_hooks = NAT_VALID_HOOKS,
-		.num_entries = 4,
-		.size = sizeof(struct ipt_standard) * 3 + sizeof(struct ipt_error),
-		.hook_entry = {
-			[NF_INET_PRE_ROUTING] = 0,
-			[NF_INET_POST_ROUTING] = sizeof(struct ipt_standard),
-			[NF_INET_LOCAL_OUT] = sizeof(struct ipt_standard) * 2
-		},
-		.underflow = {
-			[NF_INET_PRE_ROUTING] = 0,
-			[NF_INET_POST_ROUTING] = sizeof(struct ipt_standard),
-			[NF_INET_LOCAL_OUT] = sizeof(struct ipt_standard) * 2
-		},
-	},
-	.entries = {
-		IPT_STANDARD_INIT(NF_ACCEPT),	/* PRE_ROUTING */
-		IPT_STANDARD_INIT(NF_ACCEPT),	/* POST_ROUTING */
-		IPT_STANDARD_INIT(NF_ACCEPT),	/* LOCAL_OUT */
-	},
-	.term = IPT_ERROR_INIT,			/* ERROR */
-};
-
-static struct xt_table __nat_table = {
-	.name		= "nat",
-	.valid_hooks	= NAT_VALID_HOOKS,
-	.lock		= RW_LOCK_UNLOCKED,
-	.me		= THIS_MODULE,
-	.af		= AF_INET,
+static struct pktt_regtable nat_table = {
+        .name           = "nat",
+        .valid_hooks    = NAT_VALID_HOOKS,
+        .family         = AF_INET,
+        .owner          = THIS_MODULE,
+        .hooks_policy   = {     [NF_INET_PRE_ROUTING] = cACCEPT,
+                                [NF_INET_LOCAL_OUT] = cACCEPT,
+                                [NF_INET_POST_ROUTING] = cACCEPT, },
 };
-static struct xt_table *nat_table;
 
 /* Source NAT */
 static unsigned int ipt_snat_target(struct sk_buff *skb,
@@ -215,7 +188,7 @@ int nf_nat_rule_find(struct sk_buff *skb,
 {
 	int ret;
 
-	ret = ipt_do_table(skb, hooknum, in, out, nat_table);
+	ret = pktt_table_trigger(skb, hooknum, in, out, &nat_table);
 
 	if (ret == NF_ACCEPT) {
 		if (!nf_nat_initialized(ct, HOOK2MANIP(hooknum)))
@@ -249,10 +222,9 @@ int __init nf_nat_rule_init(void)
 {
 	int ret;
 
-	nat_table = ipt_register_table(&init_net, &__nat_table,
-				       &nat_initial_table.repl);
-	if (IS_ERR(nat_table))
-		return PTR_ERR(nat_table);
+	ret = pktt_register_table(&init_net, &nat_table);
+	if (ret)
+		return ret;
 	ret = xt_register_target(&ipt_snat_reg);
 	if (ret != 0)
 		goto unregister_table;
@@ -266,7 +238,7 @@ int __init nf_nat_rule_init(void)
  unregister_snat:
 	xt_unregister_target(&ipt_snat_reg);
  unregister_table:
-	ipt_unregister_table(nat_table);
+	pktt_unregister_table(&nat_table);
 
 	return ret;
 }
@@ -275,5 +247,5 @@ void nf_nat_rule_cleanup(void)
 {
 	xt_unregister_target(&ipt_dnat_reg);
 	xt_unregister_target(&ipt_snat_reg);
-	ipt_unregister_table(nat_table);
+	pktt_unregister_table(&nat_table);
 }

