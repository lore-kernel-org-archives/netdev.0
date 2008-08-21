From: adobriyan@gmail.com
Subject: [PATCH 34/38] netns nat: per-netns nat table
Date: Fri, 22 Aug 2008 02:09:49 +0400
Message-ID: <20080821220949.GH31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.190]:3530 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760002AbYHUWI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:08:29 -0400
Received: by gv-out-0910.google.com with SMTP id e6so78594gvc.37
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:08:27 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netns/ipv4.h         |    1 
 net/ipv4/netfilter/nf_nat_rule.c |   40 +++++++++++++++++++++++++++------------
 2 files changed, 29 insertions(+), 12 deletions(-)

--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -38,6 +38,7 @@ struct netns_ipv4 {
 	struct xt_table		*iptable_raw;
 	struct xt_table		*arptable_filter;
 	struct xt_table		*iptable_security;
+	struct xt_table		*nat_table;
 #endif
 
 	int sysctl_icmp_echo_ignore_all;
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
@@ -196,7 +195,7 @@ int nf_nat_rule_find(struct sk_buff *skb,
 {
 	int ret;
 
-	ret = ipt_do_table(skb, hooknum, in, out, nat_table);
+	ret = ipt_do_table(skb, hooknum, in, out, nf_ct_net(ct)->ipv4.nat_table);
 
 	if (ret == NF_ACCEPT) {
 		if (!nf_nat_initialized(ct, HOOK2MANIP(hooknum)))
@@ -226,14 +225,32 @@ static struct xt_target ipt_dnat_reg __read_mostly = {
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
@@ -247,8 +264,8 @@ int __init nf_nat_rule_init(void)
  unregister_snat:
 	xt_unregister_target(&ipt_snat_reg);
  unregister_table:
-	ipt_unregister_table(nat_table);
-
+	unregister_pernet_subsys(&nf_nat_rule_net_ops);
+ out:
 	return ret;
 }
 
@@ -256,5 +273,5 @@ void nf_nat_rule_cleanup(void)
 {
 	xt_unregister_target(&ipt_dnat_reg);
 	xt_unregister_target(&ipt_snat_reg);
-	ipt_unregister_table(nat_table);
+	unregister_pernet_subsys(&nf_nat_rule_net_ops);
 }
-- 
1.5.6.3


