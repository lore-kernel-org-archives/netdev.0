From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 5/7] netns ebtables: ebtable_filter in netns
Date: Wed, 15 Oct 2008 08:23:25 +0400
Message-ID: <20081015042325.GI24058@x200.localdomain>
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

 include/net/netns/x_tables.h          |    1 
 net/bridge/netfilter/ebtable_filter.c |   50 +++++++++++++++++++++++++---------
 2 files changed, 38 insertions(+), 13 deletions(-)

--- a/include/net/netns/x_tables.h
+++ b/include/net/netns/x_tables.h
@@ -10,5 +10,6 @@ struct netns_xt {
 	struct list_head tables[NPROTO];
 	struct list_head ebt_tables;
 	struct ebt_table *broute_table;
+	struct ebt_table *frame_filter;
 };
 #endif
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -50,41 +50,47 @@ static int check(const struct ebt_table_info *info, unsigned int valid_hooks)
 	return 0;
 }
 
-static struct ebt_table __frame_filter =
+static struct ebt_table frame_filter =
 {
 	.name		= "filter",
 	.table		= &initial_table,
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(__frame_filter.lock),
+	.lock		= __RW_LOCK_UNLOCKED(frame_filter.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
-static struct ebt_table *frame_filter;
 
 static unsigned int
-ebt_hook(unsigned int hook, struct sk_buff *skb, const struct net_device *in,
+ebt_in_hook(unsigned int hook, struct sk_buff *skb, const struct net_device *in,
    const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, skb, in, out, frame_filter);
+	return ebt_do_table(hook, skb, in, out, dev_net(in)->xt.frame_filter);
+}
+
+static unsigned int
+ebt_out_hook(unsigned int hook, struct sk_buff *skb, const struct net_device *in,
+   const struct net_device *out, int (*okfn)(struct sk_buff *))
+{
+	return ebt_do_table(hook, skb, in, out, dev_net(out)->xt.frame_filter);
 }
 
 static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
 	{
-		.hook		= ebt_hook,
+		.hook		= ebt_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_BRIDGE,
 		.hooknum	= NF_BR_LOCAL_IN,
 		.priority	= NF_BR_PRI_FILTER_BRIDGED,
 	},
 	{
-		.hook		= ebt_hook,
+		.hook		= ebt_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_BRIDGE,
 		.hooknum	= NF_BR_FORWARD,
 		.priority	= NF_BR_PRI_FILTER_BRIDGED,
 	},
 	{
-		.hook		= ebt_hook,
+		.hook		= ebt_out_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_BRIDGE,
 		.hooknum	= NF_BR_LOCAL_OUT,
@@ -92,23 +98,41 @@ static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
 	},
 };
 
+static int __net_init frame_filter_net_init(struct net *net)
+{
+	net->xt.frame_filter = ebt_register_table(net, &frame_filter);
+	if (IS_ERR(net->xt.frame_filter))
+		return PTR_ERR(net->xt.frame_filter);
+	return 0;
+}
+
+static void __net_exit frame_filter_net_exit(struct net *net)
+{
+	ebt_unregister_table(net->xt.frame_filter);
+}
+
+static struct pernet_operations frame_filter_net_ops = {
+	.init = frame_filter_net_init,
+	.exit = frame_filter_net_exit,
+};
+
 static int __init ebtable_filter_init(void)
 {
 	int ret;
 
-	frame_filter = ebt_register_table(&init_net, &__frame_filter);
-	if (IS_ERR(frame_filter))
-		return PTR_ERR(frame_filter);
+	ret = register_pernet_subsys(&frame_filter_net_ops);
+	if (ret < 0)
+		return ret;
 	ret = nf_register_hooks(ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
 	if (ret < 0)
-		ebt_unregister_table(frame_filter);
+		unregister_pernet_subsys(&frame_filter_net_ops);
 	return ret;
 }
 
 static void __exit ebtable_filter_fini(void)
 {
 	nf_unregister_hooks(ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
-	ebt_unregister_table(frame_filter);
+	unregister_pernet_subsys(&frame_filter_net_ops);
 }
 
 module_init(ebtable_filter_init);
