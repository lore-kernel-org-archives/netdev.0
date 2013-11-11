From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 3/10] bonding: rebuild the lock use for bond_alb_monitor()
Date: Mon, 11 Nov 2013 20:36:33 +0800
Message-ID: <5280CF51.1030606@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:32934 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600Ab3KKMh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 07:37:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_alb_monitor use bond lock to protect the bond slave list,
it is no effect here, we need to use RTNL or RCU to replace bond lock,
the bond_alb_monitor will called 10 times one second, RTNL may loss
performance here, so the bond lock replace with RCU to protect the
bond slave list, also the RTNL is preserved, the logic of the monitor
did not changed.

Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_alb.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 1fae915..8a85064 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -816,7 +816,7 @@ static void rlb_rebalance(struct bonding *bond)
 	for (; hash_index != RLB_NULL_INDEX;
 	     hash_index = client_info->used_next) {
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
-		assigned_slave = rlb_next_rx_slave(bond);
+		assigned_slave = __rlb_next_rx_slave(bond);
 		if (assigned_slave && (client_info->slave != assigned_slave)) {
 			client_info->slave = assigned_slave;
 			client_info->ntt = 1;
@@ -1495,14 +1495,14 @@ void bond_alb_monitor(struct work_struct *work)
 	struct list_head *iter;
 	struct slave *slave;
 
-	read_lock(&bond->lock);
-
 	if (!bond_has_slaves(bond)) {
 		bond_info->tx_rebalance_counter = 0;
 		bond_info->lp_counter = 0;
 		goto re_arm;
 	}
 
+	rcu_read_lock();
+
 	bond_info->tx_rebalance_counter++;
 	bond_info->lp_counter++;
 
@@ -1515,7 +1515,7 @@ void bond_alb_monitor(struct work_struct *work)
 		 */
 		read_lock(&bond->curr_slave_lock);
 
-		bond_for_each_slave(bond, slave, iter)
+		bond_for_each_slave_rcu(bond, slave, iter)
 			alb_send_learning_packets(slave, slave->dev->dev_addr);
 
 		read_unlock(&bond->curr_slave_lock);
@@ -1528,7 +1528,7 @@ void bond_alb_monitor(struct work_struct *work)
 
 		read_lock(&bond->curr_slave_lock);
 
-		bond_for_each_slave(bond, slave, iter) {
+		bond_for_each_slave_rcu(bond, slave, iter) {
 			tlb_clear_slave(bond, slave, 1);
 			if (slave == bond->curr_active_slave) {
 				SLAVE_TLB_INFO(slave).load =
@@ -1552,11 +1552,9 @@ void bond_alb_monitor(struct work_struct *work)
 			 * dev_set_promiscuity requires rtnl and
 			 * nothing else.  Avoid race with bond_close.
 			 */
-			read_unlock(&bond->lock);
-			if (!rtnl_trylock()) {
-				read_lock(&bond->lock);
+			rcu_read_unlock();
+			if (!rtnl_trylock())
 				goto re_arm;
-			}
 
 			bond_info->rlb_promisc_timeout_counter = 0;
 
@@ -1568,7 +1566,7 @@ void bond_alb_monitor(struct work_struct *work)
 			bond_info->primary_is_promisc = 0;
 
 			rtnl_unlock();
-			read_lock(&bond->lock);
+			rcu_read_lock();
 		}
 
 		if (bond_info->rlb_rebalance) {
@@ -1590,11 +1588,9 @@ void bond_alb_monitor(struct work_struct *work)
 			}
 		}
 	}
-
+	rcu_read_unlock();
 re_arm:
 	queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
-
-	read_unlock(&bond->lock);
 }
 
 /* assumption: called before the slave is attached to the bond
-- 
1.8.2.1
