From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 6/6] bonding: use RCU protection for alb xmit path
Date: Fri, 30 Aug 2013 18:05:08 +0800
Message-ID: <52206E54.4040001@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:55036 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755130Ab3H3KFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 06:05:34 -0400
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
 drivers/net/bonding/bond_alb.c | 20 +++++++++-----------
 drivers/net/bonding/bonding.h  |  2 +-
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index d266c56..e94a5d0 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -229,7 +229,7 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
 	max_gap = LLONG_MIN;
 
 	/* Find the slave with the largest gap */
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave_rcu(bond, slave) {
 		if (SLAVE_IS_OK(slave)) {
 			long long gap = compute_gap(slave);
 
@@ -625,10 +625,12 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct arp_pkt *arp = arp_pkt(skb);
-	struct slave *assigned_slave;
+	struct slave *assigned_slave, *curr_active_slave;
 	struct rlb_client_info *client_info;
 	u32 hash_index = 0;
 
+	curr_active_slave = rcu_dereference(bond->curr_active_slave);
+
 	_lock_rx_hashtbl(bond);
 
 	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_dst));
@@ -654,9 +656,9 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
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
@@ -1336,8 +1338,6 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 
 	/* make sure that the curr_active_slave do not change during tx
 	 */
-	read_lock(&bond->lock);
-	read_lock(&bond->curr_slave_lock);
 
 	switch (ntohs(skb->protocol)) {
 	case ETH_P_IP: {
@@ -1420,12 +1420,12 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 
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
@@ -1440,8 +1440,6 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		}
 	}
 
-	read_unlock(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
 	if (res) {
 		/* no suitable interface, frame not sent */
 		kfree_skb(skb);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a3ab47f..9bc3af0 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -536,7 +536,7 @@ static inline struct slave *bond_slave_has_mac(struct bonding *bond,
 {
 	struct slave *tmp;
 
-	bond_for_each_slave(bond, tmp)
+	bond_for_each_slave_rcu(bond, tmp)
 		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
 			return tmp;
 
-- 
1.8.2.1
