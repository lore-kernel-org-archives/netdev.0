From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 38/62: xtables: generate initial table on-demand
Date: Tue, 16 Feb 2010 15:56:11 +0100 (MET)
Message-ID: <20100216145609.2796.96341.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit e3eaa9910b380530cfd2c0670fcd3f627674da8a
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Jun 17 22:14:54 2009 +0200

    netfilter: xtables: generate initial table on-demand
    
    The static initial tables are pretty large, and after the net
    namespace has been instantiated, they just hang around for nothing.
    This commit removes them and creates tables on-demand at runtime when
    needed.
    
    Size shrinks by 7735 bytes (x86_64).
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
index f233652..0b33980 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -258,6 +258,7 @@ struct arpt_error {
 	.target.errorname = "ERROR",					       \
 }
 
+extern void *arpt_alloc_initial_table(const struct xt_table *);
 extern struct xt_table *arpt_register_table(struct net *net,
 					    const struct xt_table *table,
 					    const struct arpt_replace *repl);
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index 8d1f273..364973b 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -282,6 +282,7 @@ struct ipt_error {
 	.target.errorname = "ERROR",					       \
 }
 
+extern void *ipt_alloc_initial_table(const struct xt_table *);
 extern unsigned int ipt_do_table(struct sk_buff *skb,
 				 unsigned int hook,
 				 const struct net_device *in,
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index d2952d2..8031eb4 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -297,6 +297,7 @@ ip6t_get_target(struct ip6t_entry *e)
 #include <linux/init.h>
 extern void ip6t_init(void) __init;
 
+extern void *ip6t_alloc_initial_table(const struct xt_table *);
 extern struct xt_table *ip6t_register_table(struct net *net,
 					    const struct xt_table *table,
 					    const struct ip6t_replace *repl);
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 90203e1..72723ea 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -27,6 +27,7 @@
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_arp/arp_tables.h>
+#include "../../netfilter/xt_repldata.h"
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("David S. Miller <davem@redhat.com>");
@@ -58,6 +59,12 @@ do {								\
 #define ARP_NF_ASSERT(x)
 #endif
 
+void *arpt_alloc_initial_table(const struct xt_table *info)
+{
+	return xt_alloc_initial_table(arpt, ARPT);
+}
+EXPORT_SYMBOL_GPL(arpt_alloc_initial_table);
+
 static inline int arp_devaddr_compare(const struct arpt_devaddr_info *ap,
 				      const char *hdr_addr, int len)
 {
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index b361de0..bfe26f3 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -6,6 +6,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_arp/arp_tables.h>
 
 MODULE_LICENSE("GPL");
@@ -15,36 +16,6 @@ MODULE_DESCRIPTION("arptables filter table");
 #define FILTER_VALID_HOOKS ((1 << NF_ARP_IN) | (1 << NF_ARP_OUT) | \
 			   (1 << NF_ARP_FORWARD))
 
-static const struct
-{
-	struct arpt_replace repl;
-	struct arpt_standard entries[3];
-	struct arpt_error term;
-} initial_table __net_initdata = {
-	.repl = {
-		.name = "filter",
-		.valid_hooks = FILTER_VALID_HOOKS,
-		.num_entries = 4,
-		.size = sizeof(struct arpt_standard) * 3 + sizeof(struct arpt_error),
-		.hook_entry = {
-			[NF_ARP_IN] = 0,
-			[NF_ARP_OUT] = sizeof(struct arpt_standard),
-			[NF_ARP_FORWARD] = 2 * sizeof(struct arpt_standard),
-		},
-		.underflow = {
-			[NF_ARP_IN] = 0,
-			[NF_ARP_OUT] = sizeof(struct arpt_standard),
-			[NF_ARP_FORWARD] = 2 * sizeof(struct arpt_standard),
-		},
-	},
-	.entries = {
-		ARPT_STANDARD_INIT(NF_ACCEPT),	/* ARP_IN */
-		ARPT_STANDARD_INIT(NF_ACCEPT),	/* ARP_OUT */
-		ARPT_STANDARD_INIT(NF_ACCEPT),	/* ARP_FORWARD */
-	},
-	.term = ARPT_ERROR_INIT,
-};
-
 static const struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
@@ -68,9 +39,14 @@ static struct nf_hook_ops *arpfilter_ops __read_mostly;
 
 static int __net_init arptable_filter_net_init(struct net *net)
 {
-	/* Register table */
+	struct arpt_replace *repl;
+
+	repl = arpt_alloc_initial_table(&packet_filter);
+	if (repl == NULL)
+		return -ENOMEM;
 	net->ipv4.arptable_filter =
-		arpt_register_table(net, &packet_filter, &initial_table.repl);
+		arpt_register_table(net, &packet_filter, repl);
+	kfree(repl);
 	if (IS_ERR(net->ipv4.arptable_filter))
 		return PTR_ERR(net->ipv4.arptable_filter);
 	return 0;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 5bf7de1..2057b1b 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -28,6 +28,7 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <net/netfilter/nf_log.h>
+#include "../../netfilter/xt_repldata.h"
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
@@ -66,6 +67,12 @@ do {								\
 #define inline
 #endif
 
+void *ipt_alloc_initial_table(const struct xt_table *info)
+{
+	return xt_alloc_initial_table(ipt, IPT);
+}
+EXPORT_SYMBOL_GPL(ipt_alloc_initial_table);
+
 /*
    We keep a set of rules for each CPU, so we can avoid write-locking
    them in the softirq when updating the counters and therefore
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index c14bb85..c8dc980 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -23,36 +23,6 @@ MODULE_DESCRIPTION("iptables filter table");
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
 static const struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
@@ -86,9 +56,18 @@ module_param(forward, bool, 0000);
 
 static int __net_init iptable_filter_net_init(struct net *net)
 {
-	/* Register table */
+	struct ipt_replace *repl;
+
+	repl = ipt_alloc_initial_table(&packet_filter);
+	if (repl == NULL)
+		return -ENOMEM;
+	/* Entry 1 is the FORWARD hook */
+	((struct ipt_standard *)repl->entries)[1].target.verdict =
+		-forward - 1;
+
 	net->ipv4.iptable_filter =
-		ipt_register_table(net, &packet_filter, &initial_table.repl);
+		ipt_register_table(net, &packet_filter, repl);
+	kfree(repl);
 	if (IS_ERR(net->ipv4.iptable_filter))
 		return PTR_ERR(net->ipv4.iptable_filter);
 	return 0;
@@ -113,9 +92,6 @@ static int __init iptable_filter_init(void)
 		return -EINVAL;
 	}
 
-	/* Entry 1 is the FORWARD hook */
-	initial_table.entries[1].target.verdict = -forward - 1;
-
 	ret = register_pernet_subsys(&iptable_filter_net_ops);
 	if (ret < 0)
 		return ret;
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 2355a22..58d7097 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -27,43 +27,6 @@ MODULE_DESCRIPTION("iptables mangle table");
 			    (1 << NF_INET_LOCAL_OUT) | \
 			    (1 << NF_INET_POST_ROUTING))
 
-/* Ouch - five different hooks? Maybe this should be a config option..... -- BC */
-static const struct
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
 static const struct xt_table packet_mangler = {
 	.name		= "mangle",
 	.valid_hooks	= MANGLE_VALID_HOOKS,
@@ -134,9 +97,14 @@ static struct nf_hook_ops *mangle_ops __read_mostly;
 
 static int __net_init iptable_mangle_net_init(struct net *net)
 {
-	/* Register table */
+	struct ipt_replace *repl;
+
+	repl = ipt_alloc_initial_table(&packet_mangler);
+	if (repl == NULL)
+		return -ENOMEM;
 	net->ipv4.iptable_mangle =
-		ipt_register_table(net, &packet_mangler, &initial_table.repl);
+		ipt_register_table(net, &packet_mangler, repl);
+	kfree(repl);
 	if (IS_ERR(net->ipv4.iptable_mangle))
 		return PTR_ERR(net->ipv4.iptable_mangle);
 	return 0;
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 62a9915..06fb9d1 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -9,33 +9,6 @@
 
 #define RAW_VALID_HOOKS ((1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT))
 
-static const struct
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
 static const struct xt_table packet_raw = {
 	.name = "raw",
 	.valid_hooks =  RAW_VALID_HOOKS,
@@ -66,9 +39,14 @@ static struct nf_hook_ops *rawtable_ops __read_mostly;
 
 static int __net_init iptable_raw_net_init(struct net *net)
 {
-	/* Register table */
+	struct ipt_replace *repl;
+
+	repl = ipt_alloc_initial_table(&packet_raw);
+	if (repl == NULL)
+		return -ENOMEM;
 	net->ipv4.iptable_raw =
-		ipt_register_table(net, &packet_raw, &initial_table.repl);
+		ipt_register_table(net, &packet_raw, repl);
+	kfree(repl);
 	if (IS_ERR(net->ipv4.iptable_raw))
 		return PTR_ERR(net->ipv4.iptable_raw);
 	return 0;
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index b1bf3ca..cce2f64 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -27,36 +27,6 @@ MODULE_DESCRIPTION("iptables security table, for MAC rules");
 				(1 << NF_INET_FORWARD) | \
 				(1 << NF_INET_LOCAL_OUT)
 
-static const struct
-{
-	struct ipt_replace repl;
-	struct ipt_standard entries[3];
-	struct ipt_error term;
-} initial_table __net_initdata = {
-	.repl = {
-		.name = "security",
-		.valid_hooks = SECURITY_VALID_HOOKS,
-		.num_entries = 4,
-		.size = sizeof(struct ipt_standard) * 3 + sizeof(struct ipt_error),
-		.hook_entry = {
-			[NF_INET_LOCAL_IN] 	= 0,
-			[NF_INET_FORWARD] 	= sizeof(struct ipt_standard),
-			[NF_INET_LOCAL_OUT] 	= sizeof(struct ipt_standard) * 2,
-		},
-		.underflow = {
-			[NF_INET_LOCAL_IN] 	= 0,
-			[NF_INET_FORWARD] 	= sizeof(struct ipt_standard),
-			[NF_INET_LOCAL_OUT] 	= sizeof(struct ipt_standard) * 2,
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
 static const struct xt_table security_table = {
 	.name		= "security",
 	.valid_hooks	= SECURITY_VALID_HOOKS,
@@ -87,9 +57,14 @@ static struct nf_hook_ops *sectbl_ops __read_mostly;
 
 static int __net_init iptable_security_net_init(struct net *net)
 {
-	net->ipv4.iptable_security =
-		ipt_register_table(net, &security_table, &initial_table.repl);
+	struct ipt_replace *repl;
 
+	repl = ipt_alloc_initial_table(&security_table);
+	if (repl == NULL)
+		return -ENOMEM;
+	net->ipv4.iptable_security =
+		ipt_register_table(net, &security_table, repl);
+	kfree(repl);
 	if (IS_ERR(net->ipv4.iptable_security))
 		return PTR_ERR(net->ipv4.iptable_security);
 
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index 85da34f..ab74cc0 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -28,36 +28,6 @@
 			 (1 << NF_INET_POST_ROUTING) | \
 			 (1 << NF_INET_LOCAL_OUT))
 
-static const struct
-{
-	struct ipt_replace repl;
-	struct ipt_standard entries[3];
-	struct ipt_error term;
-} nat_initial_table __net_initdata = {
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
 static const struct xt_table nat_table = {
 	.name		= "nat",
 	.valid_hooks	= NAT_VALID_HOOKS,
@@ -186,8 +156,13 @@ static struct xt_target ipt_dnat_reg __read_mostly = {
 
 static int __net_init nf_nat_rule_net_init(struct net *net)
 {
-	net->ipv4.nat_table = ipt_register_table(net, &nat_table,
-						 &nat_initial_table.repl);
+	struct ipt_replace *repl;
+
+	repl = ipt_alloc_initial_table(&nat_table);
+	if (repl == NULL)
+		return -ENOMEM;
+	net->ipv4.nat_table = ipt_register_table(net, &nat_table, repl);
+	kfree(repl);
 	if (IS_ERR(net->ipv4.nat_table))
 		return PTR_ERR(net->ipv4.nat_table);
 	return 0;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 4332f45..dcd7825 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -29,6 +29,7 @@
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #include <linux/netfilter/x_tables.h>
 #include <net/netfilter/nf_log.h>
+#include "../../netfilter/xt_repldata.h"
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
@@ -67,6 +68,12 @@ do {								\
 #define inline
 #endif
 
+void *ip6t_alloc_initial_table(const struct xt_table *info)
+{
+	return xt_alloc_initial_table(ip6t, IP6T);
+}
+EXPORT_SYMBOL_GPL(ip6t_alloc_initial_table);
+
 /*
    We keep a set of rules for each CPU, so we can avoid write-locking
    them in the softirq when updating the counters and therefore
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 6e95d06..36b72ca 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -21,36 +21,6 @@ MODULE_DESCRIPTION("ip6tables filter table");
 			    (1 << NF_INET_FORWARD) | \
 			    (1 << NF_INET_LOCAL_OUT))
 
-static struct
-{
-	struct ip6t_replace repl;
-	struct ip6t_standard entries[3];
-	struct ip6t_error term;
-} initial_table __net_initdata = {
-	.repl = {
-		.name = "filter",
-		.valid_hooks = FILTER_VALID_HOOKS,
-		.num_entries = 4,
-		.size = sizeof(struct ip6t_standard) * 3 + sizeof(struct ip6t_error),
-		.hook_entry = {
-			[NF_INET_LOCAL_IN] = 0,
-			[NF_INET_FORWARD] = sizeof(struct ip6t_standard),
-			[NF_INET_LOCAL_OUT] = sizeof(struct ip6t_standard) * 2
-		},
-		.underflow = {
-			[NF_INET_LOCAL_IN] = 0,
-			[NF_INET_FORWARD] = sizeof(struct ip6t_standard),
-			[NF_INET_LOCAL_OUT] = sizeof(struct ip6t_standard) * 2
-		},
-	},
-	.entries = {
-		IP6T_STANDARD_INIT(NF_ACCEPT),	/* LOCAL_IN */
-		IP6T_STANDARD_INIT(NF_ACCEPT),	/* FORWARD */
-		IP6T_STANDARD_INIT(NF_ACCEPT),	/* LOCAL_OUT */
-	},
-	.term = IP6T_ERROR_INIT,		/* ERROR */
-};
-
 static const struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
@@ -78,9 +48,18 @@ module_param(forward, bool, 0000);
 
 static int __net_init ip6table_filter_net_init(struct net *net)
 {
-	/* Register table */
+	struct ip6t_replace *repl;
+
+	repl = ip6t_alloc_initial_table(&packet_filter);
+	if (repl == NULL)
+		return -ENOMEM;
+	/* Entry 1 is the FORWARD hook */
+	((struct ip6t_standard *)repl->entries)[1].target.verdict =
+		-forward - 1;
+
 	net->ipv6.ip6table_filter =
-		ip6t_register_table(net, &packet_filter, &initial_table.repl);
+		ip6t_register_table(net, &packet_filter, repl);
+	kfree(repl);
 	if (IS_ERR(net->ipv6.ip6table_filter))
 		return PTR_ERR(net->ipv6.ip6table_filter);
 	return 0;
@@ -105,9 +84,6 @@ static int __init ip6table_filter_init(void)
 		return -EINVAL;
 	}
 
-	/* Entry 1 is the FORWARD hook */
-	initial_table.entries[1].target.verdict = -forward - 1;
-
 	ret = register_pernet_subsys(&ip6table_filter_net_ops);
 	if (ret < 0)
 		return ret;
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 5023ac5..dc803b7 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -21,42 +21,6 @@ MODULE_DESCRIPTION("ip6tables mangle table");
 			    (1 << NF_INET_LOCAL_OUT) | \
 			    (1 << NF_INET_POST_ROUTING))
 
-static const struct
-{
-	struct ip6t_replace repl;
-	struct ip6t_standard entries[5];
-	struct ip6t_error term;
-} initial_table __net_initdata = {
-	.repl = {
-		.name = "mangle",
-		.valid_hooks = MANGLE_VALID_HOOKS,
-		.num_entries = 6,
-		.size = sizeof(struct ip6t_standard) * 5 + sizeof(struct ip6t_error),
-		.hook_entry = {
-			[NF_INET_PRE_ROUTING] 	= 0,
-			[NF_INET_LOCAL_IN]	= sizeof(struct ip6t_standard),
-			[NF_INET_FORWARD]	= sizeof(struct ip6t_standard) * 2,
-			[NF_INET_LOCAL_OUT] 	= sizeof(struct ip6t_standard) * 3,
-			[NF_INET_POST_ROUTING]	= sizeof(struct ip6t_standard) * 4,
-		},
-		.underflow = {
-			[NF_INET_PRE_ROUTING] 	= 0,
-			[NF_INET_LOCAL_IN]	= sizeof(struct ip6t_standard),
-			[NF_INET_FORWARD]	= sizeof(struct ip6t_standard) * 2,
-			[NF_INET_LOCAL_OUT] 	= sizeof(struct ip6t_standard) * 3,
-			[NF_INET_POST_ROUTING]	= sizeof(struct ip6t_standard) * 4,
-		},
-	},
-	.entries = {
-		IP6T_STANDARD_INIT(NF_ACCEPT),	/* PRE_ROUTING */
-		IP6T_STANDARD_INIT(NF_ACCEPT),	/* LOCAL_IN */
-		IP6T_STANDARD_INIT(NF_ACCEPT),	/* FORWARD */
-		IP6T_STANDARD_INIT(NF_ACCEPT),	/* LOCAL_OUT */
-		IP6T_STANDARD_INIT(NF_ACCEPT),	/* POST_ROUTING */
-	},
-	.term = IP6T_ERROR_INIT,		/* ERROR */
-};
-
 static const struct xt_table packet_mangler = {
 	.name		= "mangle",
 	.valid_hooks	= MANGLE_VALID_HOOKS,
@@ -126,9 +90,14 @@ ip6table_mangle_hook(unsigned int hook, struct sk_buff *skb,
 static struct nf_hook_ops *mangle_ops __read_mostly;
 static int __net_init ip6table_mangle_net_init(struct net *net)
 {
-	/* Register table */
+	struct ip6t_replace *repl;
+
+	repl = ip6t_alloc_initial_table(&packet_mangler);
+	if (repl == NULL)
+		return -ENOMEM;
 	net->ipv6.ip6table_mangle =
-		ip6t_register_table(net, &packet_mangler, &initial_table.repl);
+		ip6t_register_table(net, &packet_mangler, repl);
+	kfree(repl);
 	if (IS_ERR(net->ipv6.ip6table_mangle))
 		return PTR_ERR(net->ipv6.ip6table_mangle);
 	return 0;
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 3bfa695..aef31a2 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -8,33 +8,6 @@
 
 #define RAW_VALID_HOOKS ((1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT))
 
-static const struct
-{
-	struct ip6t_replace repl;
-	struct ip6t_standard entries[2];
-	struct ip6t_error term;
-} initial_table __net_initdata = {
-	.repl = {
-		.name = "raw",
-		.valid_hooks = RAW_VALID_HOOKS,
-		.num_entries = 3,
-		.size = sizeof(struct ip6t_standard) * 2 + sizeof(struct ip6t_error),
-		.hook_entry = {
-			[NF_INET_PRE_ROUTING] = 0,
-			[NF_INET_LOCAL_OUT] = sizeof(struct ip6t_standard)
-		},
-		.underflow = {
-			[NF_INET_PRE_ROUTING] = 0,
-			[NF_INET_LOCAL_OUT] = sizeof(struct ip6t_standard)
-		},
-	},
-	.entries = {
-		IP6T_STANDARD_INIT(NF_ACCEPT),	/* PRE_ROUTING */
-		IP6T_STANDARD_INIT(NF_ACCEPT),	/* LOCAL_OUT */
-	},
-	.term = IP6T_ERROR_INIT,		/* ERROR */
-};
-
 static const struct xt_table packet_raw = {
 	.name = "raw",
 	.valid_hooks = RAW_VALID_HOOKS,
@@ -58,9 +31,14 @@ static struct nf_hook_ops *rawtable_ops __read_mostly;
 
 static int __net_init ip6table_raw_net_init(struct net *net)
 {
-	/* Register table */
+	struct ip6t_replace *repl;
+
+	repl = ip6t_alloc_initial_table(&packet_raw);
+	if (repl == NULL)
+		return -ENOMEM;
 	net->ipv6.ip6table_raw =
-		ip6t_register_table(net, &packet_raw, &initial_table.repl);
+		ip6t_register_table(net, &packet_raw, repl);
+	kfree(repl);
 	if (IS_ERR(net->ipv6.ip6table_raw))
 		return PTR_ERR(net->ipv6.ip6table_raw);
 	return 0;
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index dd2200f..0824d86 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -26,36 +26,6 @@ MODULE_DESCRIPTION("ip6tables security table, for MAC rules");
 				(1 << NF_INET_FORWARD) | \
 				(1 << NF_INET_LOCAL_OUT)
 
-static const struct
-{
-	struct ip6t_replace repl;
-	struct ip6t_standard entries[3];
-	struct ip6t_error term;
-} initial_table __net_initdata = {
-	.repl = {
-		.name = "security",
-		.valid_hooks = SECURITY_VALID_HOOKS,
-		.num_entries = 4,
-		.size = sizeof(struct ip6t_standard) * 3 + sizeof(struct ip6t_error),
-		.hook_entry = {
-			[NF_INET_LOCAL_IN] 	= 0,
-			[NF_INET_FORWARD] 	= sizeof(struct ip6t_standard),
-			[NF_INET_LOCAL_OUT] 	= sizeof(struct ip6t_standard) * 2,
-		},
-		.underflow = {
-			[NF_INET_LOCAL_IN] 	= 0,
-			[NF_INET_FORWARD] 	= sizeof(struct ip6t_standard),
-			[NF_INET_LOCAL_OUT] 	= sizeof(struct ip6t_standard) * 2,
-		},
-	},
-	.entries = {
-		IP6T_STANDARD_INIT(NF_ACCEPT),	/* LOCAL_IN */
-		IP6T_STANDARD_INIT(NF_ACCEPT),	/* FORWARD */
-		IP6T_STANDARD_INIT(NF_ACCEPT),	/* LOCAL_OUT */
-	},
-	.term = IP6T_ERROR_INIT,		/* ERROR */
-};
-
 static const struct xt_table security_table = {
 	.name		= "security",
 	.valid_hooks	= SECURITY_VALID_HOOKS,
@@ -79,9 +49,14 @@ static struct nf_hook_ops *sectbl_ops __read_mostly;
 
 static int __net_init ip6table_security_net_init(struct net *net)
 {
-	net->ipv6.ip6table_security =
-		ip6t_register_table(net, &security_table, &initial_table.repl);
+	struct ip6t_replace *repl;
 
+	repl = ip6t_alloc_initial_table(&security_table);
+	if (repl == NULL)
+		return -ENOMEM;
+	net->ipv6.ip6table_security =
+		ip6t_register_table(net, &security_table, repl);
+	kfree(repl);
 	if (IS_ERR(net->ipv6.ip6table_security))
 		return PTR_ERR(net->ipv6.ip6table_security);
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index b51cb0d..dc2e05c 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -26,7 +26,9 @@
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_arp.h>
-
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#include <linux/netfilter_arp/arp_tables.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
diff --git a/net/netfilter/xt_repldata.h b/net/netfilter/xt_repldata.h
new file mode 100644
index 0000000..6efe4e5
--- /dev/null
+++ b/net/netfilter/xt_repldata.h
@@ -0,0 +1,35 @@
+/*
+ * Today's hack: quantum tunneling in structs
+ *
+ * 'entries' and 'term' are never anywhere referenced by word in code. In fact,
+ * they serve as the hanging-off data accessed through repl.data[].
+ */
+
+#define xt_alloc_initial_table(type, typ2) ({ \
+	unsigned int hook_mask = info->valid_hooks; \
+	unsigned int nhooks = hweight32(hook_mask); \
+	unsigned int bytes = 0, hooknum = 0, i = 0; \
+	struct { \
+		struct type##_replace repl; \
+		struct type##_standard entries[nhooks]; \
+		struct type##_error term; \
+	} *tbl = kzalloc(sizeof(*tbl), GFP_KERNEL); \
+	if (tbl == NULL) \
+		return NULL; \
+	strncpy(tbl->repl.name, info->name, sizeof(tbl->repl.name)); \
+	tbl->term = (struct type##_error)typ2##_ERROR_INIT;  \
+	tbl->repl.valid_hooks = hook_mask; \
+	tbl->repl.num_entries = nhooks + 1; \
+	tbl->repl.size = nhooks * sizeof(struct type##_standard) + \
+	                 sizeof(struct type##_error); \
+	for (; hook_mask != 0; hook_mask >>= 1, ++hooknum) { \
+		if (!(hook_mask & 1)) \
+			continue; \
+		tbl->repl.hook_entry[hooknum] = bytes; \
+		tbl->repl.underflow[hooknum]  = bytes; \
+		tbl->entries[i++] = (struct type##_standard) \
+			typ2##_STANDARD_INIT(NF_ACCEPT); \
+		bytes += sizeof(struct type##_standard); \
+	} \
+	tbl; \
+})
