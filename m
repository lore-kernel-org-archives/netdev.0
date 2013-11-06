From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 3/9] bonding: rebuild the lock use for bond_alb_monitor()
Date: Wed, 6 Nov 2013 14:52:48 +0800
Message-ID: <5279E740.5050102@huawei.com>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:6273 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568Ab3KFGyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 01:54:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_alb_monitor use bond lock to protect the bond slave list,
it is no effect here, we need to use RTNL or RCU to replace bond lock,
the bond_alb_monitor will called 10 times one second, so I think
RTNL is fit here, and move the rtnl to the top of the function, the
RTNL is being used when rlb_enabled is true.

remove the unwanted curr_slave_lock, because the curr_active_slave
will not be changed out the RTNL, so it is safe to sending the learning
packets.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_alb.c | 33 ++++++---------------------------
 1 file changed, 6 insertions(+), 27 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 7870e4e..4ed7fe4 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1491,11 +1491,13 @@ void bond_alb_monitor(struct work_struct *work)
 	struct list_head *iter;
 	struct slave *slave;
 
-	read_lock(&bond->lock);
+	if (!rtnl_trylock())
+		goto re_arm;
 
 	if (!bond_has_slaves(bond)) {
 		bond_info->tx_rebalance_counter = 0;
 		bond_info->lp_counter = 0;
+		rtnl_unlock();
 		goto re_arm;
 	}
 
@@ -1506,24 +1508,17 @@ void bond_alb_monitor(struct work_struct *work)
 	if (bond_info->lp_counter >= BOND_ALB_LP_TICKS(bond)) {
 		/* change of curr_active_slave involves swapping of mac addresses.
 		 * in order to avoid this swapping from happening while
-		 * sending the learning packets, the curr_slave_lock must be held for
-		 * read.
+		 * sending the learning packets, the RTNL or curr_slave_lock
+		 *  must be held for read.
 		 */
-		read_lock(&bond->curr_slave_lock);
-
 		bond_for_each_slave(bond, slave, iter)
 			alb_send_learning_packets(slave, slave->dev->dev_addr);
 
-		read_unlock(&bond->curr_slave_lock);
-
 		bond_info->lp_counter = 0;
 	}
 
 	/* rebalance tx traffic */
 	if (bond_info->tx_rebalance_counter >= BOND_TLB_REBALANCE_TICKS) {
-
-		read_lock(&bond->curr_slave_lock);
-
 		bond_for_each_slave(bond, slave, iter) {
 			tlb_clear_slave(bond, slave, 1);
 			if (slave == bond->curr_active_slave) {
@@ -1534,8 +1529,6 @@ void bond_alb_monitor(struct work_struct *work)
 			}
 		}
 
-		read_unlock(&bond->curr_slave_lock);
-
 		bond_info->tx_rebalance_counter = 0;
 	}
 
@@ -1544,16 +1537,6 @@ void bond_alb_monitor(struct work_struct *work)
 		if (bond_info->primary_is_promisc &&
 		    (++bond_info->rlb_promisc_timeout_counter >= RLB_PROMISC_TIMEOUT)) {
 
-			/*
-			 * dev_set_promiscuity requires rtnl and
-			 * nothing else.  Avoid race with bond_close.
-			 */
-			read_unlock(&bond->lock);
-			if (!rtnl_trylock()) {
-				read_lock(&bond->lock);
-				goto re_arm;
-			}
-
 			bond_info->rlb_promisc_timeout_counter = 0;
 
 			/* If the primary was set to promiscuous mode
@@ -1562,9 +1545,6 @@ void bond_alb_monitor(struct work_struct *work)
 			 */
 			dev_set_promiscuity(bond->curr_active_slave->dev, -1);
 			bond_info->primary_is_promisc = 0;
-
-			rtnl_unlock();
-			read_lock(&bond->lock);
 		}
 
 		if (bond_info->rlb_rebalance) {
@@ -1587,10 +1567,9 @@ void bond_alb_monitor(struct work_struct *work)
 		}
 	}
 
+	rtnl_unlock();
 re_arm:
 	queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
-
-	read_unlock(&bond->lock);
 }
 
 /* assumption: called before the slave is attached to the bond
-- 
1.8.2.1
