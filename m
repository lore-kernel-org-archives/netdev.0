From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v5 1/6] bonding: simplify and use RCU protection
 for 3ad xmit path
Date: Wed, 25 Sep 2013 12:50:00 +0200
Message-ID: <20130925105000.GC23575@redhat.com>
References: <5242B24F.5000309@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753657Ab3IYKv5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 06:51:57 -0400
Content-Disposition: inline
In-Reply-To: <5242B24F.5000309@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 25, 2013 at 05:52:15PM +0800, Ding Tianhong wrote:
>The commit 278b20837511776dc9d5f6ee1c7fabd5479838bb
>(bonding: initial RCU conversion) has convert the roundrobin, active-backup,
>broadcast and xor xmit path to rcu protection, the performance will be better
>for these mode, so this time, convert xmit path for 3ad mode.
>
>Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
>Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>Signed-off-by: Wang Yufen <wangyufen@huawei.com>
>Cc: Nikolay Aleksandrov <nikolay@redhat.com>
>Cc: Veaceslav Falico <vfalico@redhat.com>
>---
> drivers/net/bonding/bond_3ad.c | 32 ++++++++++++++------------------
> drivers/net/bonding/bonding.h  | 30 +++++++++++++++++++++++++++++-
> 2 files changed, 43 insertions(+), 19 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index 0d8f427..13f1deb 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -143,7 +143,7 @@ static inline struct bonding *__get_bond_by_port(struct port *port)
>  */
> static inline struct port *__get_first_port(struct bonding *bond)
> {
>-	struct slave *first_slave = bond_first_slave(bond);
>+	struct slave *first_slave = bond_first_slave_rcu(bond);
>
> 	return first_slave ? &(SLAVE_AD_INFO(first_slave).port) : NULL;
> }
>@@ -163,7 +163,7 @@ static inline struct port *__get_next_port(struct port *port)
> 	// If there's no bond for this port, or this is the last slave
> 	if (bond == NULL)
> 		return NULL;
>-	slave_next = bond_next_slave(bond, slave);
>+	slave_next = bond_next_slave_rcu(bond, slave);
> 	if (!slave_next || bond_is_first_slave(bond, slave_next))
> 		return NULL;
>
>@@ -2417,16 +2417,14 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
>
> int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
> {
>-	struct slave *slave, *start_at;
> 	struct bonding *bond = netdev_priv(dev);
>+	struct slave *slave;
> 	int slave_agg_no;
> 	int slaves_in_agg;
> 	int agg_id;
>-	int i;
> 	struct ad_info ad_info;
> 	int res = 1;
>
>-	read_lock(&bond->lock);
> 	if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
> 		pr_debug("%s: Error: __bond_3ad_get_active_agg_info failed\n",
> 			 dev->name);
>@@ -2444,13 +2442,17 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
>
> 	slave_agg_no = bond->xmit_hash_policy(skb, slaves_in_agg);
>
>-	bond_for_each_slave(bond, slave) {
>+	bond_for_each_slave_rcu(bond, slave) {
> 		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
>
> 		if (agg && (agg->aggregator_identifier == agg_id)) {
>-			slave_agg_no--;
>-			if (slave_agg_no < 0)
>-				break;
>+			if (--slave_agg_no < 0) {
>+				if (SLAVE_IS_OK(slave)) {
>+					res = bond_dev_queue_xmit(bond,
>+						skb, slave->dev);
>+					goto out;
>+				}
>+			}
> 		}
> 	}
>
>@@ -2460,23 +2462,17 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
> 		goto out;
> 	}
>
>-	start_at = slave;
>-
>-	bond_for_each_slave_from(bond, slave, i, start_at) {
>-		int slave_agg_id = 0;
>+	bond_for_each_slave_rcu(bond, slave) {
> 		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
>
>-		if (agg)
>-			slave_agg_id = agg->aggregator_identifier;
>-
>-		if (SLAVE_IS_OK(slave) && agg && (slave_agg_id == agg_id)) {
>+		if (SLAVE_IS_OK(slave) && agg &&
>+			agg->aggregator_identifier == agg_id) {
> 			res = bond_dev_queue_xmit(bond, skb, slave->dev);
> 			break;
> 		}
> 	}
>
> out:
>-	read_unlock(&bond->lock);
> 	if (res) {
> 		/* no suitable interface, frame not sent */
> 		kfree_skb(skb);
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 03cf3fd..eb36f57 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -74,13 +74,31 @@
> /* slave list primitives */
> #define bond_to_slave(ptr) list_entry(ptr, struct slave, list)
>
>+/* slave list primitives, Caller must hold rcu_read_lock */
>+#define bond_to_slave_rcu(ptr) list_entry_rcu(ptr, struct slave, list)
>+
>+/* bond_is_empty return NULL if slave list is empty*/
>+#define bond_is_empty(bond) \
>+	(list_empty(&(bond)->slave_list))
>+
>+/* bond_is_empty_rcu return NULL if slave list is empty*/
>+#define bond_is_empty_rcu(bond) \
>+	(!list_first_or_null_rcu(&(bond)->slave_list, struct slave, list))

Useless/dangerous function. It's not used in this patch and there can be no
constructs like:

1 if (!bond_is_empty_rcu(bond)) {
2 	slave = bond_first_slave_rcu(bond);
3 	do_something(slave);

because between 1) and 2) the slave can go away, and we'll end up with
slave == NULL.

>+
> /* IMPORTANT: bond_first/last_slave can return NULL in case of an empty list */
> #define bond_first_slave(bond) \
> 	list_first_entry_or_null(&(bond)->slave_list, struct slave, list)
> #define bond_last_slave(bond) \
>-	(list_empty(&(bond)->slave_list) ? NULL : \
>+	(bond_is_empty(bond) ? NULL : \
> 					   bond_to_slave((bond)->slave_list.prev))
>
>+/**
>+ * IMPORTANT: bond_first/last_slave_rcu can return NULL in case of an empty list
>+ * Caller must hold rcu_read_lock
>+ */
>+#define bond_first_slave_rcu(bond) \
>+	list_first_or_null_rcu(&(bond)->slave_list, struct slave, list);

bond_first_slave_or_null_rcu() ?

>+
> #define bond_is_first_slave(bond, pos) ((pos)->list.prev == &(bond)->slave_list)
> #define bond_is_last_slave(bond, pos) ((pos)->list.next == &(bond)->slave_list)
>
>@@ -93,6 +111,16 @@
> 	(bond_is_first_slave(bond, pos) ? bond_last_slave(bond) : \
> 					  bond_to_slave((pos)->list.prev))
>
>+/* Since bond_first/last_slave_rcu can return NULL, these can return NULL too */
>+#define bond_next_slave_rcu(bond, pos) \
>+	({struct list_head *__slave_list = &(bond)->slave_list; \
>+	 struct list_head __rcu *__next = list_next_rcu(__slave_list); \
>+	 struct list_head __rcu *__pos_next = list_next_rcu(&(pos)->list); \
>+	 likely(__pos_next != __slave_list) ? \
>+	 container_of(__pos_next, struct slave, list) : \
>+	 container_of(__next, struct slave, list); \
>+	 })

And if bond has no slaves, whilst pos being the slave that has just
detached? Then bond->slave_list->next == pos->list->next ==
&bond->slave_list, and we'll return the container_of(bond->slave_list),
which is garbage, but not NULL.

>+
> /**
>  * bond_for_each_slave_from - iterate the slaves list from a starting point
>  * @bond:	the bond holding this list.
>-- 
>1.8.0
>
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
