From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/9] bonding: remove the no effect lock for bond_select_active_slave()
Date: Wed, 6 Nov 2013 14:52:35 +0800
Message-ID: <5279E733.3070602@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:59647 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568Ab3KFGyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 01:54:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond slave list was no longer protected by bond lock and only
protected by RTNL or RCU, so anywhere that use bond lock to protect
slave list is meaningless.

The curr_active_slave could only be changed in 3 place:

1. enslave slave.
2. release slave.
3. change_active_slave.

all above place were holding bond lock, RTNL and curr_slave_lock together,
it is tedious and meaningless, only RTNL is enough, so remove the
bond lock and curr_slave_lock for change_active_slave.

when read the curr_active_slave, if it has RTNL yet, no need to add any
protection, otherwise we could use RCU dereference to ensure that no
problems occurs.

there are several place calling bond_select_active_slave() and
bond_change_active_slave(), the next step I will clean these place
and remove the no effect lock.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_alb.c  | 22 +++-------------------
 drivers/net/bonding/bond_main.c | 26 ++------------------------
 2 files changed, 5 insertions(+), 43 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 0287240..7870e4e 100644
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
@@ -512,13 +512,9 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 
 	_unlock_rx_hashtbl_bh(bond);
 
-	write_lock_bh(&bond->curr_slave_lock);
-
 	if (slave != bond->curr_active_slave) {
 		rlb_teach_disabled_mac_on_primary(bond, slave->dev->dev_addr);
 	}
-
-	write_unlock_bh(&bond->curr_slave_lock);
 }
 
 static void rlb_update_client(struct rlb_client_info *client_info)
@@ -1680,15 +1676,10 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
  * If new_slave is NULL, caller must hold curr_slave_lock or
  * bond->lock for write.
  *
- * If new_slave is not NULL, caller must hold RTNL, bond->lock for
- * read and curr_slave_lock for write.  Processing here may sleep, so
- * no other locks may be held.
+ * If new_slave is not NULL, caller must hold RTNL, Processing
+ * here may sleep, so no other locks may be held.
  */
 void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave)
-	__releases(&bond->curr_slave_lock)
-	__releases(&bond->lock)
-	__acquires(&bond->lock)
-	__acquires(&bond->curr_slave_lock)
 {
 	struct slave *swap_slave;
 
@@ -1722,9 +1713,6 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 		tlb_clear_slave(bond, swap_slave, 1);
 	tlb_clear_slave(bond, new_slave, 1);
 
-	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
-
 	ASSERT_RTNL();
 
 	/* in TLB mode, the slave might flip down/up with the old dev_addr,
@@ -1749,15 +1737,11 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
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
-
-	write_lock_bh(&bond->curr_slave_lock);
 }
 
 /*
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a141f40..9c9803c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -691,15 +691,11 @@ static void bond_set_dev_addr(struct net_device *bond_dev,
  *
  * Perform special MAC address swapping for fail_over_mac settings
  *
- * Called with RTNL, bond->lock for read, curr_slave_lock for write_bh.
+ * Called with RTNL.
  */
 static void bond_do_fail_over_mac(struct bonding *bond,
 				  struct slave *new_active,
 				  struct slave *old_active)
-	__releases(&bond->curr_slave_lock)
-	__releases(&bond->lock)
-	__acquires(&bond->lock)
-	__acquires(&bond->curr_slave_lock)
 {
 	u8 tmp_mac[ETH_ALEN];
 	struct sockaddr saddr;
@@ -708,11 +704,7 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 	switch (bond->params.fail_over_mac) {
 	case BOND_FOM_ACTIVE:
 		if (new_active) {
-			write_unlock_bh(&bond->curr_slave_lock);
-			read_unlock(&bond->lock);
 			bond_set_dev_addr(bond->dev, new_active->dev);
-			read_lock(&bond->lock);
-			write_lock_bh(&bond->curr_slave_lock);
 		}
 		break;
 	case BOND_FOM_FOLLOW:
@@ -724,9 +716,6 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 		if (!new_active)
 			return;
 
-		write_unlock_bh(&bond->curr_slave_lock);
-		read_unlock(&bond->lock);
-
 		if (old_active) {
 			memcpy(tmp_mac, new_active->dev->dev_addr, ETH_ALEN);
 			memcpy(saddr.sa_data, old_active->dev->dev_addr,
@@ -755,8 +744,6 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 			pr_err("%s: Error %d setting MAC of slave %s\n",
 			       bond->dev->name, -rv, new_active->dev->name);
 out:
-		read_lock(&bond->lock);
-		write_lock_bh(&bond->curr_slave_lock);
 		break;
 	default:
 		pr_err("%s: bond_do_fail_over_mac impossible: bad policy %d\n",
@@ -839,9 +826,6 @@ static bool bond_should_notify_peers(struct bonding *bond)
  * If @new's link state is %BOND_LINK_BACK we'll set it to %BOND_LINK_UP,
  * because it is apparently the best available slave we have, even though its
  * updelay hasn't timed out yet.
- *
- * If new_active is not NULL, caller must hold bond->lock for read and
- * curr_slave_lock for write_bh.
  */
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 {
@@ -909,16 +893,10 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 					bond_should_notify_peers(bond);
 			}
 
-			write_unlock_bh(&bond->curr_slave_lock);
-			read_unlock(&bond->lock);
-
 			call_netdevice_notifiers(NETDEV_BONDING_FAILOVER, bond->dev);
 			if (should_notify_peers)
 				call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
 							 bond->dev);
-
-			read_lock(&bond->lock);
-			write_lock_bh(&bond->curr_slave_lock);
 		}
 	}
 
@@ -943,7 +921,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
  * - The primary_slave has got its link back.
  * - A slave has got its link back and there's no old curr_active_slave.
  *
- * Caller must hold bond->lock for read and curr_slave_lock for write_bh.
+ * Caller must hold RTNL.
  */
 void bond_select_active_slave(struct bonding *bond)
 {
-- 
1.8.2.1
