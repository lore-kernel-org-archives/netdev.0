From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v5 6/6] bonding: use RCU protection for alb xmit
 path
Date: Wed, 25 Sep 2013 17:52:35 +0800
Message-ID: <5242B263.7010908@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:27645 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899Ab3IYJyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 05:54:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 278b20837511776dc9d5f6ee1c7fabd5479838bb
(bonding: initial RCU conversion) has convert the roundrobin, active-backup,
broadcast and xor xmit path to rcu protection, the performance will be better
for these mode, so this time, convert xmit path for alb mode.

Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_alb.c | 32 ++++++++++++++------------------
 drivers/net/bonding/bonding.h  |  2 +-
 2 files changed, 15 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 4813dc6..619a611 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -229,7 +229,7 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
 	max_gap = LLONG_MIN;
 
 	/* Find the slave with the largest gap */
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave_rcu(bond, slave) {
 		if (SLAVE_IS_OK(slave)) {
 			long long gap = compute_gap(slave);
 
@@ -382,16 +382,14 @@ out:
 static struct slave *rlb_next_rx_slave(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
-	struct slave *rx_slave, *slave, *start_at;
+	struct slave *rx_slave, *slave;
 
 	if (bond_info->next_rx_slave)
-		start_at = bond_info->next_rx_slave;
+		rx_slave = bond_info->next_rx_slave;
 	else
-		start_at = bond_first_slave(bond);
-
-	rx_slave = NULL;
+		rx_slave = bond_first_slave_rcu(bond);
 
-	bond_for_each_slave_from(bond, slave, start_at) {
+	bond_for_each_slave_rcu(bond, slave) {
 		if (SLAVE_IS_OK(slave)) {
 			if (!rx_slave) {
 				rx_slave = slave;
@@ -402,7 +400,7 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
 	}
 
 	if (rx_slave) {
-		slave = bond_next_slave(bond, rx_slave);
+		slave = bond_next_slave_rcu(bond, rx_slave);
 		bond_info->next_rx_slave = slave;
 	}
 
@@ -625,12 +623,14 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct arp_pkt *arp = arp_pkt(skb);
-	struct slave *assigned_slave;
+	struct slave *assigned_slave, *curr_active_slave;
 	struct rlb_client_info *client_info;
 	u32 hash_index = 0;
 
 	_lock_rx_hashtbl(bond);
 
+	curr_active_slave = rcu_dereference(bond->curr_active_slave);
+
 	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_dst));
 	client_info = &(bond_info->rx_hashtbl[hash_index]);
 
@@ -654,9 +654,9 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 			 * move the old client to primary (curr_active_slave) so
 			 * that the new client can be assigned to this entry.
 			 */
-			if (bond->curr_active_slave &&
-			    client_info->slave != bond->curr_active_slave) {
-				client_info->slave = bond->curr_active_slave;
+			if (curr_active_slave &&
+			    client_info->slave != curr_active_slave) {
+				client_info->slave = curr_active_slave;
 				rlb_update_client(client_info);
 			}
 		}
@@ -1338,8 +1338,6 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 
 	/* make sure that the curr_active_slave do not change during tx
 	 */
-	read_lock(&bond->lock);
-	read_lock(&bond->curr_slave_lock);
 
 	switch (ntohs(skb->protocol)) {
 	case ETH_P_IP: {
@@ -1422,12 +1420,12 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 
 	if (!tx_slave) {
 		/* unbalanced or unassigned, send through primary */
-		tx_slave = bond->curr_active_slave;
+		tx_slave = rcu_dereference(bond->curr_active_slave);
 		bond_info->unbalanced_load += skb->len;
 	}
 
 	if (tx_slave && SLAVE_IS_OK(tx_slave)) {
-		if (tx_slave != bond->curr_active_slave) {
+		if (tx_slave != rcu_dereference(bond->curr_active_slave)) {
 			memcpy(eth_data->h_source,
 			       tx_slave->dev->dev_addr,
 			       ETH_ALEN);
@@ -1442,8 +1440,6 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		}
 	}
 
-	read_unlock(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
 	if (res) {
 		/* no suitable interface, frame not sent */
 		kfree_skb(skb);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index e5734ad..87782b4 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -522,7 +522,7 @@ static inline struct slave *bond_slave_has_mac(struct bonding *bond,
 {
 	struct slave *tmp;
 
-	bond_for_each_slave(bond, tmp)
+	bond_for_each_slave_rcu(bond, tmp)
 		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
 			return tmp;
 
-- 
1.8.0
