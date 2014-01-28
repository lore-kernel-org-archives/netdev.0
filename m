From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next] bonding: fix locking in bond_loadbalance_arp_mon()
Date: Tue, 28 Jan 2014 11:48:53 +0800
Message-ID: <52E728A5.5070701@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:3377 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754425AbaA1Dt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 22:49:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 1d3ee88ae0d605629bf369
(bonding: add netlink attributes to slave link dev)
has add rtmsg_ifinfo() in bond_set_active_slave() and
bond_set_backup_slave(), so the two function need to
called in RTNL lock, but bond_loadbalance_arp_mon()
only calling these functions in RCU, warning message
will occurs.

fix this by add a new function bond_slave_state_change(),
which will reset the slave's state after slave link check,
so remove the bond_set_xxx_slave() from the cycle and only
record the slave_state_changed, this will call the new
function to set all slaves to new state in RTNL later.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 29 +++++++++++++++++------------
 drivers/net/bonding/bonding.h   | 13 +++++++++++++
 2 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f9e0c8b..dd2dcc6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2346,7 +2346,7 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 					    arp_work.work);
 	struct slave *slave, *oldcurrent;
 	struct list_head *iter;
-	int do_failover = 0;
+	int do_failover = 0, slave_state_changed = 0;
 
 	if (!bond_has_slaves(bond))
 		goto re_arm;
@@ -2370,7 +2370,7 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 			    bond_time_in_interval(bond, slave->dev->last_rx, 1)) {
 
 				slave->link  = BOND_LINK_UP;
-				bond_set_active_slave(slave);
+				slave_state_changed = 1;
 
 				/* primary_slave has no meaning in round-robin
 				 * mode. the window of a slave being up and
@@ -2399,7 +2399,7 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 			    !bond_time_in_interval(bond, slave->dev->last_rx, 2)) {
 
 				slave->link  = BOND_LINK_DOWN;
-				bond_set_backup_slave(slave);
+				slave_state_changed = 1;
 
 				if (slave->link_failure_count < UINT_MAX)
 					slave->link_failure_count++;
@@ -2426,19 +2426,24 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 
 	rcu_read_unlock();
 
-	if (do_failover) {
-		/* the bond_select_active_slave must hold RTNL
-		 * and curr_slave_lock for write.
-		 */
+	if (do_failover || slave_state_changed) {
 		if (!rtnl_trylock())
 			goto re_arm;
-		block_netpoll_tx();
-		write_lock_bh(&bond->curr_slave_lock);
 
-		bond_select_active_slave(bond);
+		if (slave_state_changed) {
+			bond_slave_state_change(bond);
+		} else if (do_failover) {
+			/* the bond_select_active_slave must hold RTNL
+			 * and curr_slave_lock for write.
+			 */
+			block_netpoll_tx();
+			write_lock_bh(&bond->curr_slave_lock);
 
-		write_unlock_bh(&bond->curr_slave_lock);
-		unblock_netpoll_tx();
+			bond_select_active_slave(bond);
+
+			write_unlock_bh(&bond->curr_slave_lock);
+			unblock_netpoll_tx();
+		}
 		rtnl_unlock();
 	}
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 1a9062f..86ccfb9 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -303,6 +303,19 @@ static inline void bond_set_backup_slave(struct slave *slave)
 	}
 }
 
+static inline void bond_slave_state_change(struct bonding *bond)
+{
+	struct list_head *iter;
+	struct slave *tmp;
+
+	bond_for_each_slave(bond, tmp, iter) {
+		if (tmp->link == BOND_LINK_UP)
+			bond_set_active_slave(tmp);
+		else if (tmp->link == BOND_LINK_DOWN)
+			bond_set_backup_slave(tmp);
+	}
+}
+
 static inline int bond_slave_state(struct slave *slave)
 {
 	return slave->backup;
-- 
1.8.0
