From: adobriyan@gmail.com
Subject: [PATCH 5/6] netns brnetfilter: per-netns nat table
Date: Fri, 22 Aug 2008 02:27:51 +0400
Message-ID: <20080821222751.GS31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:46518 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756348AbYHUW1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:27:37 -0400
Received: by yx-out-2324.google.com with SMTP id 8so107151yxm.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:27:36 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netns/bridge.h         |    1 
 net/bridge/netfilter/ebtable_nat.c |   48 ++++++++++++++++++++++++-------------
 2 files changed, 33 insertions(+), 16 deletions(-)

--- a/include/net/netns/bridge.h
+++ b/include/net/netns/bridge.h
@@ -7,5 +7,6 @@ struct netns_br {
 	struct list_head	ebt_tables;
 	struct ebt_table	*broute_table;
 	struct ebt_table	*frame_filter;
+	struct ebt_table	*frame_nat;
 };
 #endif
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -50,48 +50,47 @@ static int check(const struct ebt_table_info *info, unsigned int valid_hooks)
 	return 0;
 }
 
-static struct ebt_table __frame_nat =
+static struct ebt_table frame_nat =
 {
 	.name		= "nat",
 	.table		= &initial_table,
 	.valid_hooks	= NAT_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(__frame_nat.lock),
+	.lock		= __RW_LOCK_UNLOCKED(frame_nat.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
-static struct ebt_table *frame_nat;
 
 static unsigned int
-ebt_nat_dst(unsigned int hook, struct sk_buff *skb, const struct net_device *in
+ebt_nat_pre_routing(unsigned int hook, struct sk_buff *skb, const struct net_device *in
    , const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, skb, in, out, frame_nat);
+	return ebt_do_table(hook, skb, in, out, dev_net(in)->br.frame_nat);
 }
 
 static unsigned int
-ebt_nat_src(unsigned int hook, struct sk_buff *skb, const struct net_device *in
+ebt_nat_out(unsigned int hook, struct sk_buff *skb, const struct net_device *in
    , const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, skb, in, out, frame_nat);
+	return ebt_do_table(hook, skb, in, out, dev_net(out)->br.frame_nat);
 }
 
 static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
 	{
-		.hook		= ebt_nat_dst,
+		.hook		= ebt_nat_out,
 		.owner		= THIS_MODULE,
 		.pf		= PF_BRIDGE,
 		.hooknum	= NF_BR_LOCAL_OUT,
 		.priority	= NF_BR_PRI_NAT_DST_OTHER,
 	},
 	{
-		.hook		= ebt_nat_src,
+		.hook		= ebt_nat_out,
 		.owner		= THIS_MODULE,
 		.pf		= PF_BRIDGE,
 		.hooknum	= NF_BR_POST_ROUTING,
 		.priority	= NF_BR_PRI_NAT_SRC,
 	},
 	{
-		.hook		= ebt_nat_dst,
+		.hook		= ebt_nat_pre_routing,
 		.owner		= THIS_MODULE,
 		.pf		= PF_BRIDGE,
 		.hooknum	= NF_BR_PRE_ROUTING,
@@ -99,23 +98,41 @@ static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
 	},
 };
 
+static int frame_nat_net_init(struct net *net)
+{
+	net->br.frame_nat = ebt_register_table(net, &frame_nat);
+	if (IS_ERR(net->br.frame_nat))
+		return PTR_ERR(net->br.frame_nat);
+	return 0;
+}
+
+static void frame_nat_net_exit(struct net *net)
+{
+	ebt_unregister_table(net->br.frame_nat);
+}
+
+static struct pernet_operations frame_nat_net_ops = {
+	.init = frame_nat_net_init,
+	.exit = frame_nat_net_exit,
+};
+
 static int __init ebtable_nat_init(void)
 {
 	int ret;
 
-	frame_nat = ebt_register_table(&init_net, &__frame_nat);
-	if (IS_ERR(frame_nat))
-		return PTR_ERR(frame_nat);
+	ret = register_pernet_subsys(&frame_nat_net_ops);
+	if (ret < 0)
+		return ret;
 	ret = nf_register_hooks(ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
 	if (ret < 0)
-		ebt_unregister_table(frame_nat);
+		unregister_pernet_subsys(&frame_nat_net_ops);
 	return ret;
 }
 
 static void __exit ebtable_nat_fini(void)
 {
 	nf_unregister_hooks(ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
-	ebt_unregister_table(frame_nat);
+	unregister_pernet_subsys(&frame_nat_net_ops);
 }
 
 module_init(ebtable_nat_init);
-- 
1.5.6.3


