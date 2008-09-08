From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 29/33] netns nat: per-netns NAT table
Date: Mon,  8 Sep 2008 07:03:06 +0400
Message-ID: <1220842990-30500-29-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Same story as with iptable_filter, iptables_raw tables.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index a6ed838..b286b84 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -38,6 +38,7 @@ struct netns_ipv4 {
 	struct xt_table		*iptable_raw;
 	struct xt_table		*arptable_filter;
 	struct xt_table		*iptable_security;
+	struct xt_table		*nat_table;
 #endif
 
 	int sysctl_icmp_echo_ignore_all;
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index e8b4d0d..0a02a8c 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -33,7 +33,7 @@ static struct
 	struct ipt_replace repl;
 	struct ipt_standard entries[3];
 	struct ipt_error term;
-} nat_initial_table __initdata = {
+} nat_initial_table __net_initdata = {
 	.repl = {
 		.name = "nat",
 		.valid_hooks = NAT_VALID_HOOKS,
@@ -58,14 +58,13 @@ static struct
 	.term = IPT_ERROR_INIT,			/* ERROR */
 };
 
-static struct xt_table __nat_table = {
+static struct xt_table nat_table = {
 	.name		= "nat",
 	.valid_hooks	= NAT_VALID_HOOKS,
 	.lock		= __RW_LOCK_UNLOCKED(__nat_table.lock),
 	.me		= THIS_MODULE,
 	.af		= AF_INET,
 };
-static struct xt_table *nat_table;
 
 /* Source NAT */
 static unsigned int ipt_snat_target(struct sk_buff *skb,
@@ -194,9 +193,10 @@ int nf_nat_rule_find(struct sk_buff *skb,
 		     const struct net_device *out,
 		     struct nf_conn *ct)
 {
+	struct net *net = nf_ct_net(ct);
 	int ret;
 
-	ret = ipt_do_table(skb, hooknum, in, out, nat_table);
+	ret = ipt_do_table(skb, hooknum, in, out, net->ipv4.nat_table);
 
 	if (ret == NF_ACCEPT) {
 		if (!nf_nat_initialized(ct, HOOK2MANIP(hooknum)))
@@ -226,14 +226,32 @@ static struct xt_target ipt_dnat_reg __read_mostly = {
 	.family		= AF_INET,
 };
 
+static int __net_init nf_nat_rule_net_init(struct net *net)
+{
+	net->ipv4.nat_table = ipt_register_table(net, &nat_table,
+						 &nat_initial_table.repl);
+	if (IS_ERR(net->ipv4.nat_table))
+		return PTR_ERR(net->ipv4.nat_table);
+	return 0;
+}
+
+static void __net_exit nf_nat_rule_net_exit(struct net *net)
+{
+	ipt_unregister_table(net->ipv4.nat_table);
+}
+
+static struct pernet_operations nf_nat_rule_net_ops = {
+	.init = nf_nat_rule_net_init,
+	.exit = nf_nat_rule_net_exit,
+};
+
 int __init nf_nat_rule_init(void)
 {
 	int ret;
 
-	nat_table = ipt_register_table(&init_net, &__nat_table,
-				       &nat_initial_table.repl);
-	if (IS_ERR(nat_table))
-		return PTR_ERR(nat_table);
+	ret = register_pernet_subsys(&nf_nat_rule_net_ops);
+	if (ret != 0)
+		goto out;
 	ret = xt_register_target(&ipt_snat_reg);
 	if (ret != 0)
 		goto unregister_table;
@@ -247,8 +265,8 @@ int __init nf_nat_rule_init(void)
  unregister_snat:
 	xt_unregister_target(&ipt_snat_reg);
  unregister_table:
-	ipt_unregister_table(nat_table);
-
+	unregister_pernet_subsys(&nf_nat_rule_net_ops);
+ out:
 	return ret;
 }
 
@@ -256,5 +274,5 @@ void nf_nat_rule_cleanup(void)
 {
 	xt_unregister_target(&ipt_dnat_reg);
 	xt_unregister_target(&ipt_snat_reg);
-	ipt_unregister_table(nat_table);
+	unregister_pernet_subsys(&nf_nat_rule_net_ops);
 }
