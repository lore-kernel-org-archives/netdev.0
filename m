From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 1/10] bonding: remove the no effect lock for bond_select_active_slave()
Date: Fri, 8 Nov 2013 10:07:40 +0800
Message-ID: <527C476C.9020708@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:25825 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753806Ab3KHCIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:08:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond slave list was no longer protected by bond lock and only
protected by RTNL or RCU, so anywhere that use bond lock to protect
slave list is meaningless.

The curr_active_slave could only be changed in 3 place:

1. enslave slave.
2. release slave.
3. change_active_slave.

all above place were holding bond lock, RTNL and curr_slave_lock
together, it is tedious and meaningless, obviously bond lock is no
need here, but RTNL or curr_slave_lock is needed, so if you want
to access active slave, you have to choose one lock, RTNL or
curr_slave_lock, if RTNL is exist, no need to add curr_slave_lock,
otherwise curr_slave_lock is better, because of the performance.

there are several place calling bond_select_active_slave() and
bond_change_active_slave(), the next step I will clean these place
and remove the no effect lock.

there are some document changed together when update the function.

Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_alb.c  | 12 +++---------
 drivers/net/bonding/bond_main.c | 15 +++------------
 2 files changed, 6 insertions(+), 21 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 0287240..1fae915 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -470,7 +470,7 @@ static void rlb_teach_disabled_mac_on_primary(struct bonding *bond, u8 addr[])
 
 /* slave being removed should not be active at this point
  *
- * Caller must hold bond lock for read
+ * Caller must hold rtnl.
  */
 static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 {
@@ -1680,14 +1680,11 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
  * If new_slave is NULL, caller must hold curr_slave_lock or
  * bond->lock for write.
  *
- * If new_slave is not NULL, caller must hold RTNL, bond->lock for
- * read and curr_slave_lock for write.  Processing here may sleep, so
- * no other locks may be held.
+ * If new_slave is not NULL, caller must hold RTNL, curr_slave_lock
+ * for write.  Processing here may sleep, so no other locks may be held.
  */
 void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave)
 	__releases(&bond->curr_slave_lock)
-	__releases(&bond->lock)
-	__acquires(&bond->lock)
 	__acquires(&bond->curr_slave_lock)
 {
 	struct slave *swap_slave;
@@ -1723,7 +1720,6 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	tlb_clear_slave(bond, new_slave, 1);
 
 	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
 
 	ASSERT_RTNL();
 
@@ -1749,11 +1745,9 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 		/* swap mac address */
 		alb_swap_mac_addr(swap_slave, new_slave);
 		alb_fasten_mac_swap(bond, swap_slave, new_slave);
-		read_lock(&bond->lock);
 	} else {
 		/* set the new_slave to the bond mac address */
 		alb_set_slave_mac_addr(new_slave, bond->dev->dev_addr);
-		read_lock(&bond->lock);
 		alb_send_learning_packets(new_slave, bond->dev->dev_addr);
 	}
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a141f40..ba18719 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -691,14 +691,12 @@ static void bond_set_dev_addr(struct net_device *bond_dev,
  *
  * Perform special MAC address swapping for fail_over_mac settings
  *
- * Called with RTNL, bond->lock for read, curr_slave_lock for write_bh.
+ * Called with RTNL, curr_slave_lock for write_bh.
  */
 static void bond_do_fail_over_mac(struct bonding *bond,
 				  struct slave *new_active,
 				  struct slave *old_active)
 	__releases(&bond->curr_slave_lock)
-	__releases(&bond->lock)
-	__acquires(&bond->lock)
 	__acquires(&bond->curr_slave_lock)
 {
 	u8 tmp_mac[ETH_ALEN];
@@ -709,9 +707,7 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 	case BOND_FOM_ACTIVE:
 		if (new_active) {
 			write_unlock_bh(&bond->curr_slave_lock);
-			read_unlock(&bond->lock);
 			bond_set_dev_addr(bond->dev, new_active->dev);
-			read_lock(&bond->lock);
 			write_lock_bh(&bond->curr_slave_lock);
 		}
 		break;
@@ -725,7 +721,6 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 			return;
 
 		write_unlock_bh(&bond->curr_slave_lock);
-		read_unlock(&bond->lock);
 
 		if (old_active) {
 			memcpy(tmp_mac, new_active->dev->dev_addr, ETH_ALEN);
@@ -755,7 +750,6 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 			pr_err("%s: Error %d setting MAC of slave %s\n",
 			       bond->dev->name, -rv, new_active->dev->name);
 out:
-		read_lock(&bond->lock);
 		write_lock_bh(&bond->curr_slave_lock);
 		break;
 	default:
@@ -840,8 +834,7 @@ static bool bond_should_notify_peers(struct bonding *bond)
  * because it is apparently the best available slave we have, even though its
  * updelay hasn't timed out yet.
  *
- * If new_active is not NULL, caller must hold bond->lock for read and
- * curr_slave_lock for write_bh.
+ * If new_active is not NULL, caller must hold curr_slave_lock for write_bh.
  */
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 {
@@ -910,14 +903,12 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			}
 
 			write_unlock_bh(&bond->curr_slave_lock);
-			read_unlock(&bond->lock);
 
 			call_netdevice_notifiers(NETDEV_BONDING_FAILOVER, bond->dev);
 			if (should_notify_peers)
 				call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
 							 bond->dev);
 
-			read_lock(&bond->lock);
 			write_lock_bh(&bond->curr_slave_lock);
 		}
 	}
@@ -943,7 +934,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
  * - The primary_slave has got its link back.
  * - A slave has got its link back and there's no old curr_active_slave.
  *
- * Caller must hold bond->lock for read and curr_slave_lock for write_bh.
+ * Caller must hold curr_slave_lock for write_bh.
  */
 void bond_select_active_slave(struct bonding *bond)
 {
-- 
1.8.2.1
