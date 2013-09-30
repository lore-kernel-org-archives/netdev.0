From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 2/4] bonding: use RCU protection for alb xmit
 path
Date: Mon, 30 Sep 2013 12:52:33 +0200
Message-ID: <20130930105233.GA6096@redhat.com>
References: <524812C1.6070407@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37876 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540Ab3I3Kyc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Sep 2013 06:54:32 -0400
Content-Disposition: inline
In-Reply-To: <524812C1.6070407@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 29, 2013 at 07:45:05PM +0800, Ding Tianhong wrote:
>The commit 278b20837511776dc9d5f6ee1c7fabd5479838bb
>(bonding: initial RCU conversion) has convert the roundrobin,
>active-backup, broadcast and xor xmit path to rcu protection,
>the performance will be better for these mode, so this time,
>convert xmit path for alb mode.
>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>Cc: Nikolay Aleksandrov <nikolay@redhat.com>
>Cc: Veaceslav Falico <vfalico@redhat.com>
>---
> drivers/net/bonding/bond_alb.c | 23 +++++++++--------------
> drivers/net/bonding/bonding.h  |  2 +-
> 2 files changed, 10 insertions(+), 15 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index e960418..a1444d5 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -230,7 +230,7 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
> 	max_gap = LLONG_MIN;
>
> 	/* Find the slave with the largest gap */
>-	bond_for_each_slave(bond, slave, iter) {
>+	bond_for_each_slave_rcu(bond, slave, iter) {
> 		if (SLAVE_IS_OK(slave)) {
> 			long long gap = compute_gap(slave);
>
>@@ -387,7 +387,7 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
> 	struct list_head *iter;
> 	bool found = false;
>
>-	bond_for_each_slave(bond, slave, iter) {
>+	bond_for_each_slave_rcu(bond, slave, iter) {
> 		if (!SLAVE_IS_OK(slave))
> 			continue;
> 		if (!found) {
>@@ -628,12 +628,14 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
> {
> 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
> 	struct arp_pkt *arp = arp_pkt(skb);
>-	struct slave *assigned_slave;
>+	struct slave *assigned_slave, *curr_active_slave;
> 	struct rlb_client_info *client_info;
> 	u32 hash_index = 0;
>
> 	_lock_rx_hashtbl(bond);
>
>+	curr_active_slave = rcu_dereference(bond->curr_active_slave);
>+
> 	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_dst));
> 	client_info = &(bond_info->rx_hashtbl[hash_index]);
>
>@@ -658,8 +660,8 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
> 			 * that the new client can be assigned to this entry.
> 			 */
> 			if (bond->curr_active_slave &&
>-			    client_info->slave != bond->curr_active_slave) {
>-				client_info->slave = bond->curr_active_slave;
>+			    client_info->slave != curr_active_slave) {
>+				client_info->slave = curr_active_slave;
> 				rlb_update_client(client_info);
> 			}
> 		}
>@@ -1343,11 +1345,6 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
> 	skb_reset_mac_header(skb);
> 	eth_data = eth_hdr(skb);
>
>-	/* make sure that the curr_active_slave do not change during tx
>-	 */
>-	read_lock(&bond->lock);
>-	read_lock(&bond->curr_slave_lock);
>-
> 	switch (ntohs(skb->protocol)) {
> 	case ETH_P_IP: {
> 		const struct iphdr *iph = ip_hdr(skb);
>@@ -1429,12 +1426,12 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>
> 	if (!tx_slave) {
> 		/* unbalanced or unassigned, send through primary */
>-		tx_slave = bond->curr_active_slave;
>+		tx_slave = rcu_dereference(bond->curr_active_slave);
> 		bond_info->unbalanced_load += skb->len;
> 	}
>
> 	if (tx_slave && SLAVE_IS_OK(tx_slave)) {
>-		if (tx_slave != bond->curr_active_slave) {
>+		if (tx_slave != rcu_dereference(bond->curr_active_slave)) {
> 			memcpy(eth_data->h_source,
> 			       tx_slave->dev->dev_addr,
> 			       ETH_ALEN);
>@@ -1449,8 +1446,6 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
> 		}
> 	}
>
>-	read_unlock(&bond->curr_slave_lock);
>-	read_unlock(&bond->lock);
> 	if (res) {
> 		/* no suitable interface, frame not sent */
> 		kfree_skb(skb);
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 713b6af..1c7d559 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -459,7 +459,7 @@ static inline struct slave *bond_slave_has_mac(struct bonding *bond,
> 	struct list_head *iter;
> 	struct slave *tmp;
>
>-	bond_for_each_slave(bond, tmp, iter)
>+	bond_for_each_slave_rcu(bond, tmp, iter)

This suggests that rcu_read_lock() is always held here, however it's not
the case, as far as I can tell:

bond_release()/bond_uninit() ->
__bond_release_one() ->
bond_alb_deinit_slave() ->
alb_change_hw_addr_on_detach() ->
bond_slave_has_mac()

There is nobody that takes rcu_read_lock() there. And, for example, when
doing:

echo -$slave > /sys/class/net/$bond_int/bonding/slaves

nobody is holding it. And, btw, in bond_for_each_slave_rcu(), which is
actually a wrapper for netdev_for_each_lower_private_rcu(), which calls
netdev_lower_get_next_private_rcu(), which has:

4543 void *netdev_lower_get_next_private_rcu(struct net_device *dev,
4544                                         struct list_head **iter)
4545 {
4546         struct netdev_adjacent *lower;
4547 
4548         WARN_ON_ONCE(!rcu_read_lock_held());

so you should have seen that warning when trying to remove a slave in alb
mode.

> 		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
> 			return tmp;
>
>-- 
>1.8.2.1
>
>
>
