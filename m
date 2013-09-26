From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v5 1/6] bonding: simplify and use RCU protection
 for 3ad xmit path
Date: Thu, 26 Sep 2013 08:07:54 +0200
Message-ID: <20130926060754.GB2547@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:62676 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751477Ab3IZGJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 02:09:50 -0400
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

So here you are checking for any suitable slave from slave number
slave_agg_no+1 and till the last slave. Ok.

Some nitpicks, though not critical - slave_agg_no will always get
decremented, even if it's negative. It's ok though harder to
read/understand. The triple cascaded ifs can be omited, from (used the same
code):

if (agg && (agg->aggregator_identifier == agg_id)) {
	if (--slave_agg_no < 0) {
		if (SLAVE_IS_OK(slave)) {
			do_something();
			goto out;
		}
	}
}

to (again, used the same code):

if (!agg || agg->aggregator_identifier != agg_id)
	continue;

if (--slave_agg_no >= 0)
	continue;

if (SLAVE_IS_OK(slave)) {
	do_something();
	goto out;
}


Which is a lot easier to read/understand. Though, again, there are small
nitpicks and I'm ok with your approach.

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

Ok, so if the first approach fails - you loop through *all* the slaves
again, checking the slaves already checked by the first loop - i.e. the
slaves from slave number slave_agg_no and till the last slave.

It's suboptimal, but still should work. You can optimize this by storing a
'first ok slave' in the first loop, and if the first loop fails to find any
slave *after* slave_agg_no, you can use that first_ok_slave (if found) to
send. This way you'll drop the second loop entirely. It's the way that I've
done in my patch - pls consult my function :) :

http://patchwork.ozlabs.org/patch/277701/

bond_for_each_slave(bond, slave, iter) {
         agg = SLAVE_AD_INFO(slave).port.aggregator;
         if (!agg || agg->aggregator_identifier != agg_id)
                 continue;

         if (slave_agg_no >= 0) {
                 if (!first_ok_slave && SLAVE_IS_OK(slave))
                         first_ok_slave = slave;
                 slave_agg_no--;
                 continue;
         }

         if (SLAVE_IS_OK(slave)) {
                 res = bond_dev_queue_xmit(bond, skb, slave->dev);
                 goto out;
         }
}

...

if (first_ok_slave)
	res = bond_dev_queue_xmit(bond, skb, first_ok_slave->dev);

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
>+
> /**
>  * bond_for_each_slave_from - iterate the slaves list from a starting point
>  * @bond:	the bond holding this list.
>-- 
>1.8.0
>
>
>
