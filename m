From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 2/7] netns ebtables: part 2
Date: Wed, 15 Oct 2008 08:22:18 +0400
Message-ID: <20081015042218.GF24058@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@osdl.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* return ebt_table from ebt_register_table(), module code will save it into
  per-netns data for unregistration
* duplicate ebt_table at the very beginning of registration -- it's added into list,
  so one ebt_table wouldn't end up in many lists (and each netns has different one)
* introduce underscored tables in individual modules, this is temporary.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/netfilter_bridge/ebtables.h |    2 +-
 net/bridge/netfilter/ebtable_broute.c     |   19 +++++++++----------
 net/bridge/netfilter/ebtable_filter.c     |   17 +++++++++--------
 net/bridge/netfilter/ebtable_nat.c        |   19 ++++++++++---------
 net/bridge/netfilter/ebtables.c           |   23 +++++++++++++++++------
 5 files changed, 46 insertions(+), 34 deletions(-)

--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -300,7 +300,7 @@ struct ebt_table
 
 #define EBT_ALIGN(s) (((s) + (__alignof__(struct ebt_replace)-1)) & \
 		     ~(__alignof__(struct ebt_replace)-1))
-extern int ebt_register_table(struct net *net, struct ebt_table *table);
+extern struct ebt_table *ebt_register_table(struct net *net, struct ebt_table *table);
 extern void ebt_unregister_table(struct ebt_table *table);
 extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
    const struct net_device *in, const struct net_device *out,
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -41,22 +41,23 @@ static int check(const struct ebt_table_info *info, unsigned int valid_hooks)
 	return 0;
 }
 
-static struct ebt_table broute_table =
+static struct ebt_table __broute_table =
 {
 	.name		= "broute",
 	.table		= &initial_table,
 	.valid_hooks	= 1 << NF_BR_BROUTING,
-	.lock		= __RW_LOCK_UNLOCKED(broute_table.lock),
+	.lock		= __RW_LOCK_UNLOCKED(__broute_table.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
+static struct ebt_table *broute_table;
 
 static int ebt_broute(struct sk_buff *skb)
 {
 	int ret;
 
 	ret = ebt_do_table(NF_BR_BROUTING, skb, skb->dev, NULL,
-	   &broute_table);
+	   broute_table);
 	if (ret == NF_DROP)
 		return 1; /* route it */
 	return 0; /* bridge it */
@@ -64,21 +65,19 @@ static int ebt_broute(struct sk_buff *skb)
 
 static int __init ebtable_broute_init(void)
 {
-	int ret;
-
-	ret = ebt_register_table(&init_net, &broute_table);
-	if (ret < 0)
-		return ret;
+	broute_table = ebt_register_table(&init_net, &__broute_table);
+	if (IS_ERR(broute_table))
+		return PTR_ERR(broute_table);
 	/* see br_input.c */
 	rcu_assign_pointer(br_should_route_hook, ebt_broute);
-	return ret;
+	return 0;
 }
 
 static void __exit ebtable_broute_fini(void)
 {
 	rcu_assign_pointer(br_should_route_hook, NULL);
 	synchronize_net();
-	ebt_unregister_table(&broute_table);
+	ebt_unregister_table(broute_table);
 }
 
 module_init(ebtable_broute_init);
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -50,21 +50,22 @@ static int check(const struct ebt_table_info *info, unsigned int valid_hooks)
 	return 0;
 }
 
-static struct ebt_table frame_filter =
+static struct ebt_table __frame_filter =
 {
 	.name		= "filter",
 	.table		= &initial_table,
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(frame_filter.lock),
+	.lock		= __RW_LOCK_UNLOCKED(__frame_filter.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
+static struct ebt_table *frame_filter;
 
 static unsigned int
 ebt_hook(unsigned int hook, struct sk_buff *skb, const struct net_device *in,
    const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, skb, in, out, &frame_filter);
+	return ebt_do_table(hook, skb, in, out, frame_filter);
 }
 
 static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
@@ -95,19 +96,19 @@ static int __init ebtable_filter_init(void)
 {
 	int ret;
 
-	ret = ebt_register_table(&init_net, &frame_filter);
-	if (ret < 0)
-		return ret;
+	frame_filter = ebt_register_table(&init_net, &__frame_filter);
+	if (IS_ERR(frame_filter))
+		return PTR_ERR(frame_filter);
 	ret = nf_register_hooks(ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
 	if (ret < 0)
-		ebt_unregister_table(&frame_filter);
+		ebt_unregister_table(frame_filter);
 	return ret;
 }
 
 static void __exit ebtable_filter_fini(void)
 {
 	nf_unregister_hooks(ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
-	ebt_unregister_table(&frame_filter);
+	ebt_unregister_table(frame_filter);
 }
 
 module_init(ebtable_filter_init);
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -50,28 +50,29 @@ static int check(const struct ebt_table_info *info, unsigned int valid_hooks)
 	return 0;
 }
 
-static struct ebt_table frame_nat =
+static struct ebt_table __frame_nat =
 {
 	.name		= "nat",
 	.table		= &initial_table,
 	.valid_hooks	= NAT_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(frame_nat.lock),
+	.lock		= __RW_LOCK_UNLOCKED(__frame_nat.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
+static struct ebt_table *frame_nat;
 
 static unsigned int
 ebt_nat_dst(unsigned int hook, struct sk_buff *skb, const struct net_device *in
    , const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, skb, in, out, &frame_nat);
+	return ebt_do_table(hook, skb, in, out, frame_nat);
 }
 
 static unsigned int
 ebt_nat_src(unsigned int hook, struct sk_buff *skb, const struct net_device *in
    , const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, skb, in, out, &frame_nat);
+	return ebt_do_table(hook, skb, in, out, frame_nat);
 }
 
 static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
@@ -102,19 +103,19 @@ static int __init ebtable_nat_init(void)
 {
 	int ret;
 
-	ret = ebt_register_table(&init_net, &frame_nat);
-	if (ret < 0)
-		return ret;
+	frame_nat = ebt_register_table(&init_net, &__frame_nat);
+	if (IS_ERR(frame_nat))
+		return PTR_ERR(frame_nat);
 	ret = nf_register_hooks(ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
 	if (ret < 0)
-		ebt_unregister_table(&frame_nat);
+		ebt_unregister_table(frame_nat);
 	return ret;
 }
 
 static void __exit ebtable_nat_fini(void)
 {
 	nf_unregister_hooks(ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
-	ebt_unregister_table(&frame_nat);
+	ebt_unregister_table(frame_nat);
 }
 
 module_init(ebtable_nat_init);
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1105,7 +1105,7 @@ free_newinfo:
 	return ret;
 }
 
-int ebt_register_table(struct net *net, struct ebt_table *table)
+struct ebt_table *ebt_register_table(struct net *net, struct ebt_table *table)
 {
 	struct ebt_table_info *newinfo;
 	struct ebt_table *t;
@@ -1117,14 +1117,21 @@ int ebt_register_table(struct net *net, struct ebt_table *table)
 	    repl->entries_size == 0 ||
 	    repl->counters || table->private) {
 		BUGPRINT("Bad table data for ebt_register_table!!!\n");
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
+	}
+
+	/* Don't add one table to multiple lists. */
+	table = kmemdup(table, sizeof(struct ebt_table), GFP_KERNEL);
+	if (!table) {
+		ret = -ENOMEM;
+		goto out;
 	}
 
 	countersize = COUNTER_OFFSET(repl->nentries) * nr_cpu_ids;
 	newinfo = vmalloc(sizeof(*newinfo) + countersize);
 	ret = -ENOMEM;
 	if (!newinfo)
-		return -ENOMEM;
+		goto free_table;
 
 	p = vmalloc(repl->entries_size);
 	if (!p)
@@ -1156,7 +1163,7 @@ int ebt_register_table(struct net *net, struct ebt_table *table)
 
 	if (table->check && table->check(newinfo, table->valid_hooks)) {
 		BUGPRINT("The table doesn't like its own initial data, lol\n");
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
 	}
 
 	table->private = newinfo;
@@ -1180,7 +1187,7 @@ int ebt_register_table(struct net *net, struct ebt_table *table)
 	}
 	list_add(&table->list, &net->xt.ebt_tables);
 	mutex_unlock(&ebt_mutex);
-	return 0;
+	return table;
 free_unlock:
 	mutex_unlock(&ebt_mutex);
 free_chainstack:
@@ -1192,7 +1199,10 @@ free_chainstack:
 	vfree(newinfo->entries);
 free_newinfo:
 	vfree(newinfo);
-	return ret;
+free_table:
+	kfree(table);
+out:
+	return ERR_PTR(ret);
 }
 
 void ebt_unregister_table(struct ebt_table *table)
@@ -1213,6 +1223,7 @@ void ebt_unregister_table(struct ebt_table *table)
 		vfree(table->private->chainstack);
 	}
 	vfree(table->private);
+	kfree(table);
 }
 
 /* userspace just supplied us with counters */
