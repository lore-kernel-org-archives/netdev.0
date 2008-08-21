From: adobriyan@gmail.com
Subject: [PATCH 4/6] netns brnetfilter: per-netns filter table
Date: Fri, 22 Aug 2008 02:22:05 +0400
Message-ID: <20080821222205.GR31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.188]:3514 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761235AbYHUWYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:24:05 -0400
Received: by gv-out-0910.google.com with SMTP id e6so80694gvc.37
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:24:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netns/bridge.h            |    1 
 net/bridge/netfilter/ebtable_filter.c |   51 ++++++++++++++++++++++++----------
 2 files changed, 38 insertions(+), 14 deletions(-)

--- a/include/net/netns/bridge.h
+++ b/include/net/netns/bridge.h
@@ -6,5 +6,6 @@
 struct netns_br {
 	struct list_head	ebt_tables;
 	struct ebt_table	*broute_table;
+	struct ebt_table	*frame_filter;
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
+	return ebt_do_table(hook, skb, in, out, dev_net(in)->br.frame_filter);
+}
+
+static unsigned int
+ebt_out_hook(unsigned int hook, struct sk_buff *skb, const struct net_device *in,
+   const struct net_device *out, int (*okfn)(struct sk_buff *))
+{
+	return ebt_do_table(hook, skb, in, out, dev_net(out)->br.frame_filter);
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
 
+static int frame_filter_net_init(struct net *net)
+{
+	net->br.frame_filter = ebt_register_table(net, &frame_filter);
+	if (IS_ERR(net->br.frame_filter))
+		return PTR_ERR(net->br.frame_filter);
+	return 0;
+}
+
+static void frame_filter_net_exit(struct net *net)
+{
+	ebt_unregister_table(net->br.frame_filter);
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
-- 
1.5.6.3


