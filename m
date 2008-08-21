From: adobriyan@gmail.com
Subject: [PATCH 3/6] netns brnetfilter: per-netns broute table
Date: Fri, 22 Aug 2008 02:21:47 +0400
Message-ID: <20080821222147.GQ31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:9716 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758312AbYHUWUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:20:25 -0400
Received: by yw-out-2324.google.com with SMTP id 9so10671ywe.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:20:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netns/bridge.h            |    1 
 net/bridge/netfilter/ebtable_broute.c |   36 +++++++++++++++++++++++++---------
 2 files changed, 28 insertions(+), 9 deletions(-)

--- a/include/net/netns/bridge.h
+++ b/include/net/netns/bridge.h
@@ -5,5 +5,6 @@
 
 struct netns_br {
 	struct list_head	ebt_tables;
+	struct ebt_table	*broute_table;
 };
 #endif
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -41,33 +41,52 @@ static int check(const struct ebt_table_info *info, unsigned int valid_hooks)
 	return 0;
 }
 
-static struct ebt_table __broute_table =
+static struct ebt_table broute_table =
 {
 	.name		= "broute",
 	.table		= &initial_table,
 	.valid_hooks	= 1 << NF_BR_BROUTING,
-	.lock		= __RW_LOCK_UNLOCKED(__broute_table.lock),
+	.lock		= __RW_LOCK_UNLOCKED(broute_table.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
-static struct ebt_table *broute_table;
 
 static int ebt_broute(struct sk_buff *skb)
 {
 	int ret;
 
 	ret = ebt_do_table(NF_BR_BROUTING, skb, skb->dev, NULL,
-	   broute_table);
+			   dev_net(skb->dev)->br.broute_table);
 	if (ret == NF_DROP)
 		return 1; /* route it */
 	return 0; /* bridge it */
 }
 
+static int ebtable_broute_net_init(struct net *net)
+{
+	net->br.broute_table = ebt_register_table(net, &broute_table);
+	if (IS_ERR(net->br.broute_table))
+		return PTR_ERR(net->br.broute_table);
+	return 0;
+}
+
+static void ebtable_broute_net_exit(struct net *net)
+{
+	ebt_unregister_table(net->br.broute_table);
+}
+
+static struct pernet_operations ebtable_broute_net_ops = {
+	.init = ebtable_broute_net_init,
+	.exit = ebtable_broute_net_exit,
+};
+
 static int __init ebtable_broute_init(void)
 {
-	broute_table = ebt_register_table(&init_net, &__broute_table);
-	if (IS_ERR(broute_table))
-		return PTR_ERR(broute_table);
+	int ret;
+
+	ret = register_pernet_subsys(&ebtable_broute_net_ops);
+	if (ret < 0)
+		return ret;
 	/* see br_input.c */
 	rcu_assign_pointer(br_should_route_hook, ebt_broute);
 	return 0;
@@ -77,7 +96,7 @@ static void __exit ebtable_broute_fini(void)
 {
 	rcu_assign_pointer(br_should_route_hook, NULL);
 	synchronize_net();
-	ebt_unregister_table(broute_table);
+	unregister_pernet_subsys(&ebtable_broute_net_ops);
 }
 
 module_init(ebtable_broute_init);
-- 
1.5.6.3


