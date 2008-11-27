From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 07/29: netns ebtables: ebtable_broute in netns
Date: Thu, 27 Nov 2008 17:15:12 +0100 (MET)
Message-ID: <20081127161512.13891.85396.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 8157e6d16af86e4a8d31a035db7be02a8a171c26
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Tue Nov 4 14:29:03 2008 +0100

    netfilter: netns ebtables: ebtable_broute in netns
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.h
index b809397..055e684 100644
--- a/include/net/netns/x_tables.h
+++ b/include/net/netns/x_tables.h
@@ -4,7 +4,10 @@
 #include <linux/list.h>
 #include <linux/netfilter.h>
 
+struct ebt_table;
+
 struct netns_xt {
 	struct list_head tables[NFPROTO_NUMPROTO];
+	struct ebt_table *broute_table;
 };
 #endif
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index 3277d68..8604dfc 100644
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
+			   dev_net(skb->dev)->xt.broute_table);
 	if (ret == NF_DROP)
 		return 1; /* route it */
 	return 0; /* bridge it */
 }
 
+static int __net_init broute_net_init(struct net *net)
+{
+	net->xt.broute_table = ebt_register_table(net, &broute_table);
+	if (IS_ERR(net->xt.broute_table))
+		return PTR_ERR(net->xt.broute_table);
+	return 0;
+}
+
+static void __net_exit broute_net_exit(struct net *net)
+{
+	ebt_unregister_table(net->xt.broute_table);
+}
+
+static struct pernet_operations broute_net_ops = {
+	.init = broute_net_init,
+	.exit = broute_net_exit,
+};
+
 static int __init ebtable_broute_init(void)
 {
-	broute_table = ebt_register_table(&init_net, &__broute_table);
-	if (IS_ERR(broute_table))
-		return PTR_ERR(broute_table);
+	int ret;
+
+	ret = register_pernet_subsys(&broute_net_ops);
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
+	unregister_pernet_subsys(&broute_net_ops);
 }
 
 module_init(ebtable_broute_init);
