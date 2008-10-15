From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 4/7] netns ebtables: ebtable_broute in netns
Date: Wed, 15 Oct 2008 08:23:06 +0400
Message-ID: <20081015042306.GH24058@x200.localdomain>
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

 include/net/netns/x_tables.h          |    3 ++
 net/bridge/netfilter/ebtable_broute.c |   35 ++++++++++++++++++++++++++--------
 2 files changed, 30 insertions(+), 8 deletions(-)

--- a/include/net/netns/x_tables.h
+++ b/include/net/netns/x_tables.h
@@ -4,8 +4,11 @@
 #include <linux/list.h>
 #include <linux/net.h>
 
+struct ebt_table;
+
 struct netns_xt {
 	struct list_head tables[NPROTO];
 	struct list_head ebt_tables;
+	struct ebt_table *broute_table;
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
