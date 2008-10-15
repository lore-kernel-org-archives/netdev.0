From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 6/7] netns ebtables: ebtable_nat in netns
Date: Wed, 15 Oct 2008 08:23:41 +0400
Message-ID: <20081015042341.GJ24058@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@osdl.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netns/x_tables.h       |    1 
 net/bridge/netfilter/ebtable_nat.c |   47 +++++++++++++++++++++++++------------
 2 files changed, 33 insertions(+), 15 deletions(-)

--- a/include/net/netns/x_tables.h
+++ b/include/net/netns/x_tables.h
@@ -11,5 +11,6 @@ struct netns_xt {
 	struct list_head ebt_tables;
 	struct ebt_table *broute_table;
 	struct ebt_table *frame_filter;
+	struct ebt_table *frame_nat;
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
+ebt_nat_in(unsigned int hook, struct sk_buff *skb, const struct net_device *in
    , const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, skb, in, out, frame_nat);
+	return ebt_do_table(hook, skb, in, out, dev_net(in)->xt.frame_nat);
 }
 
 static unsigned int
-ebt_nat_src(unsigned int hook, struct sk_buff *skb, const struct net_device *in
+ebt_nat_out(unsigned int hook, struct sk_buff *skb, const struct net_device *in
    , const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, skb, in, out, frame_nat);
+	return ebt_do_table(hook, skb, in, out, dev_net(out)->xt.frame_nat);
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
+		.hook		= ebt_nat_in,
 		.owner		= THIS_MODULE,
 		.pf		= PF_BRIDGE,
 		.hooknum	= NF_BR_PRE_ROUTING,
@@ -99,23 +98,41 @@ static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
 	},
 };
 
+static int __net_init frame_nat_net_init(struct net *net)
+{
+	net->xt.frame_nat = ebt_register_table(net, &frame_nat);
+	if (IS_ERR(net->xt.frame_nat))
+		return PTR_ERR(net->xt.frame_nat);
+	return 0;
+}
+
+static void __net_exit frame_nat_net_exit(struct net *net)
+{
+	ebt_unregister_table(net->xt.frame_nat);
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
