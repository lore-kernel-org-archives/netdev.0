From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 1/1] bonding: eliminate RTNL assertion spew
Date: Tue, 9 Jan 2007 17:59:01 -0500
Message-ID: <20070109225900.GA11755@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43440 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932486AbXAIW7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 17:59:09 -0500
To: fubar@us.ibm.com, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


These changes eliminate the messages indicating that the rtnetlink lock
isn't held when bonding tries to change the MAC address of an interface.
These calls generally come from timer-pops, but also from sysfs events
since neither hold the rtnl lock.  

The spew generally looks something like this:

RTNL: assertion failed at net/core/fib_rules.c (391)
 [<c028d12e>] fib_rules_event+0x3a/0xeb
 [<c02da576>] notifier_call_chain+0x19/0x29
 [<c0280ce6>] dev_set_mac_address+0x46/0x4b
 [<f8a2a686>] alb_set_slave_mac_addr+0x5d/0x88 [bonding]
 [<f8a2aa7e>] alb_swap_mac_addr+0x88/0x134 [bonding]
 [<f8a25ed9>] bond_change_active_slave+0x1a1/0x2c5 [bonding]
 [<f8a262e8>] bond_select_active_slave+0xa8/0xe1 [bonding]
 [<f8a27ecb>] bond_mii_monitor+0x3af/0x3fd [bonding]
 [<c0121896>] run_workqueue+0x85/0xc5
 [<f8a27b1c>] bond_mii_monitor+0x0/0x3fd [bonding]
 [<c0121d83>] worker_thread+0xe8/0x119
 [<c0111179>] default_wake_function+0x0/0xc
 [<c0121c9b>] worker_thread+0x0/0x119
 [<c0124099>] kthread+0xad/0xd8
 [<c0123fec>] kthread+0x0/0xd8
 .....

This patch was mostly inspired from parts of some potential bonding
updates Jay Vosburgh <fubar@us.ibm.com> and I discussed in December, so
he deserves most of the credit for the idea.

I've tested it on several systems and it works as I expect.  Deadlocks
between the rtnl and global bond lock are avoided since we drop the
global bond lock before taking the rtnl lock.


Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 bond_alb.c   |   16 +++++++++++++++-
 bond_alb.h   |    2 +-
 bond_main.c  |   32 +++++++++++++++++---------------
 bond_sysfs.c |    8 ++++----
 bonding.h    |    7 +++++--
 5 files changed, 42 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 3292316..150b787 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1557,13 +1557,14 @@ void bond_alb_handle_link_change(struct 
  * bond_alb_handle_active_change - assign new curr_active_slave
  * @bond: our bonding struct
  * @new_slave: new slave to assign
+ * @rtnl_locked: current rtnl lock status 
  *
  * Set the bond->curr_active_slave to @new_slave and handle
  * mac address swapping and promiscuity changes as needed.
  *
  * Caller must hold bond curr_slave_lock for write (or bond lock for write)
  */
-void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave)
+void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave, int rtnl_locked)
 {
 	struct slave *swap_slave;
 	int i;
@@ -1585,6 +1586,7 @@ void bond_alb_handle_active_change(struc
 		return;
 	}
 
+
 	/* set the new curr_active_slave to the bonds mac address
 	 * i.e. swap mac addresses of old curr_active_slave and new curr_active_slave
 	 */
@@ -1600,6 +1602,12 @@ void bond_alb_handle_active_change(struc
 		}
 	}
 
+	/* need to hold rtnl_lock here, but unlock at least bond lock  */
+	if (!rtnl_locked) {
+		write_unlock_bh(&bond->lock);
+		rtnl_lock();
+	}
+
 	/* curr_active_slave must be set before calling alb_swap_mac_addr */
 	if (swap_slave) {
 		/* swap mac address */
@@ -1611,6 +1619,12 @@ void bond_alb_handle_active_change(struc
 		/* fasten bond mac on new current slave */
 		alb_send_learning_packets(new_slave, bond->dev->dev_addr);
 	}
+
+	/* drop rtnl_lock, take back others */
+	if (!rtnl_locked) {
+		rtnl_unlock();
+		write_lock_bh(&bond->lock);
+	}
 }
 
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 28f2a2f..af72dd8 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -123,7 +123,7 @@ void bond_alb_deinitialize(struct bondin
 int bond_alb_init_slave(struct bonding *bond, struct slave *slave);
 void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave);
 void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char link);
-void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave);
+void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave, int rtnl_locked);
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
 void bond_alb_monitor(struct bonding *bond);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6482aed..0134dd0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1029,6 +1029,7 @@ static struct slave *bond_find_best_slav
  * change_active_interface - change the active slave into the specified one
  * @bond: our bonding struct
  * @new: the new slave to make the active one
+ * @rtnl_locked: current rtnl lock status
  *
  * Set the new slave to the bond's settings and unset them on the old
  * curr_active_slave.
@@ -1040,7 +1041,7 @@ static struct slave *bond_find_best_slav
  *
  * Warning: Caller must hold curr_slave_lock for writing.
  */
-void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
+void bond_change_active_slave(struct bonding *bond, struct slave *new_active, int rtnl_locked)
 {
 	struct slave *old_active = bond->curr_active_slave;
 
@@ -1086,7 +1087,7 @@ void bond_change_active_slave(struct bon
 
 	if ((bond->params.mode == BOND_MODE_TLB) ||
 	    (bond->params.mode == BOND_MODE_ALB)) {
-		bond_alb_handle_active_change(bond, new_active);
+		bond_alb_handle_active_change(bond, new_active, rtnl_locked);
 		if (old_active)
 			bond_set_slave_inactive_flags(old_active);
 		if (new_active)
@@ -1110,6 +1111,7 @@ void bond_change_active_slave(struct bon
 /**
  * bond_select_active_slave - select a new active slave, if needed
  * @bond: our bonding struct
+ * @rtnl_locked: indicates rtnl lock status
  *
  * This functions shoud be called when one of the following occurs:
  * - The old curr_active_slave has been released or lost its link.
@@ -1118,14 +1120,14 @@ void bond_change_active_slave(struct bon
  *
  * Warning: Caller must hold curr_slave_lock for writing.
  */
-void bond_select_active_slave(struct bonding *bond)
+void bond_select_active_slave(struct bonding *bond, int rtnl_locked)
 {
 	struct slave *best_slave;
 	int rv;
 
 	best_slave = bond_find_best_slave(bond);
 	if (best_slave != bond->curr_active_slave) {
-		bond_change_active_slave(bond, best_slave);
+		bond_change_active_slave(bond, best_slave, rtnl_locked);
 		rv = bond_set_carrier(bond);
 		if (!rv)
 			return;
@@ -1521,7 +1523,7 @@ int bond_enslave(struct net_device *bond
 	switch (bond->params.mode) {
 	case BOND_MODE_ACTIVEBACKUP:
 		bond_set_slave_inactive_flags(new_slave);
-		bond_select_active_slave(bond);
+		bond_select_active_slave(bond, BOND_RTNL_LOCKED);
 		break;
 	case BOND_MODE_8023AD:
 		/* in 802.3ad mode, the internal mechanism
@@ -1552,7 +1554,7 @@ int bond_enslave(struct net_device *bond
 			/* first slave or no active slave yet, and this link
 			 * is OK, so make this interface the active one
 			 */
-			bond_change_active_slave(bond, new_slave);
+			bond_change_active_slave(bond, new_slave, BOND_RTNL_LOCKED);
 		} else {
 			bond_set_slave_inactive_flags(new_slave);
 		}
@@ -1701,7 +1703,7 @@ int bond_release(struct net_device *bond
 	}
 
 	if (oldcurrent == slave) {
-		bond_change_active_slave(bond, NULL);
+		bond_change_active_slave(bond, NULL,BOND_RTNL_LOCKED);
 	}
 
 	if ((bond->params.mode == BOND_MODE_TLB) ||
@@ -1715,7 +1717,7 @@ int bond_release(struct net_device *bond
 	}
 
 	if (oldcurrent == slave)
-		bond_select_active_slave(bond);
+		bond_select_active_slave(bond,BOND_RTNL_LOCKED);
 
 	if (bond->slave_cnt == 0) {
 		bond_set_carrier(bond);
@@ -1812,7 +1814,7 @@ static int bond_release_all(struct net_d
 
 	bond->current_arp_slave = NULL;
 	bond->primary_slave = NULL;
-	bond_change_active_slave(bond, NULL);
+	bond_change_active_slave(bond, NULL,BOND_RTNL_LOCKED);
 
 	while ((slave = bond->first_slave) != NULL) {
 		/* Inform AD package of unbinding of slave
@@ -1956,7 +1958,7 @@ static int bond_ioctl_change_active(stru
 	    (old_active) &&
 	    (new_active->link == BOND_LINK_UP) &&
 	    IS_UP(new_active->dev)) {
-		bond_change_active_slave(bond, new_active);
+		bond_change_active_slave(bond, new_active, BOND_RTNL_LOCKED);
 	} else {
 		res = -EINVAL;
 	}
@@ -2240,7 +2242,7 @@ void bond_mii_monitor(struct net_device 
 	if (do_failover) {
 		write_lock(&bond->curr_slave_lock);
 
-		bond_select_active_slave(bond);
+		bond_select_active_slave(bond,BOND_RTNL_UNLOCKED);
 
 		write_unlock(&bond->curr_slave_lock);
 	} else
@@ -2652,7 +2654,7 @@ void bond_loadbalance_arp_mon(struct net
 	if (do_failover) {
 		write_lock(&bond->curr_slave_lock);
 
-		bond_select_active_slave(bond);
+		bond_select_active_slave(bond,BOND_RTNL_UNLOCKED);
 
 		write_unlock(&bond->curr_slave_lock);
 	}
@@ -2715,7 +2717,7 @@ void bond_activebackup_arp_mon(struct ne
 
 				if ((!bond->curr_active_slave) &&
 				    ((jiffies - slave->dev->trans_start) <= delta_in_ticks)) {
-					bond_change_active_slave(bond, slave);
+					bond_change_active_slave(bond, slave, BOND_RTNL_UNLOCKED);
 					bond->current_arp_slave = NULL;
 				} else if (bond->curr_active_slave != slave) {
 					/* this slave has just come up but we
@@ -2817,7 +2819,7 @@ void bond_activebackup_arp_mon(struct ne
 
 			write_lock(&bond->curr_slave_lock);
 
-			bond_select_active_slave(bond);
+			bond_select_active_slave(bond,BOND_RTNL_UNLOCKED);
 			slave = bond->curr_active_slave;
 
 			write_unlock(&bond->curr_slave_lock);
@@ -2840,7 +2842,7 @@ void bond_activebackup_arp_mon(struct ne
 
 			/* primary is up so switch to it */
 			write_lock(&bond->curr_slave_lock);
-			bond_change_active_slave(bond, bond->primary_slave);
+			bond_change_active_slave(bond, bond->primary_slave, BOND_RTNL_UNLOCKED);
 			write_unlock(&bond->curr_slave_lock);
 
 			slave = bond->primary_slave;
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ced9ed8..0633c92 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1042,7 +1042,7 @@ static ssize_t bonding_store_primary(str
 				       ": %s: Setting %s as primary slave.\n",
 				       bond->dev->name, slave->dev->name);
 				bond->primary_slave = slave;
-				bond_select_active_slave(bond);
+				bond_select_active_slave(bond, BOND_RTNL_UNLOCKED);
 				goto out;
 			}
 		}
@@ -1054,7 +1054,7 @@ static ssize_t bonding_store_primary(str
 			       ": %s: Setting primary slave to None.\n",
 			       bond->dev->name);
 			bond->primary_slave = NULL;
-				bond_select_active_slave(bond);
+				bond_select_active_slave(bond, BOND_RTNL_UNLOCKED);
 		} else {
 			printk(KERN_INFO DRV_NAME
 			       ": %s: Unable to set %.*s as primary slave as it is not a slave.\n",
@@ -1161,7 +1161,7 @@ static ssize_t bonding_store_active_slav
 						printk(KERN_INFO DRV_NAME
 				       	              ": %s: Setting %s as active slave.\n",
 				                      bond->dev->name, slave->dev->name);
-                				bond_change_active_slave(bond, new_active);
+                				bond_change_active_slave(bond, new_active, BOND_RTNL_UNLOCKED);
         				}
 					else {
 						printk(KERN_INFO DRV_NAME
@@ -1182,7 +1182,7 @@ static ssize_t bonding_store_active_slav
 			       ": %s: Setting active slave to None.\n",
 			       bond->dev->name);
 			bond->primary_slave = NULL;
-				bond_select_active_slave(bond);
+				bond_select_active_slave(bond, BOND_RTNL_UNLOCKED);
 		} else {
 			printk(KERN_INFO DRV_NAME
 			       ": %s: Unable to set %.*s as active slave as it is not a slave.\n",
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index dc434fb..f7ec89d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -29,6 +29,9 @@ #define DRV_DESCRIPTION	"Ethernet Channe
 
 #define BOND_MAX_ARP_TARGETS	16
 
+#define BOND_RTNL_LOCKED	1
+#define BOND_RTNL_UNLOCKED	0
+
 #ifdef BONDING_DEBUG
 #define dprintk(fmt, args...) \
 	printk(KERN_DEBUG     \
@@ -306,8 +309,8 @@ void bond_activebackup_arp_mon(struct ne
 void bond_set_mode_ops(struct bonding *bond, int mode);
 int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl);
 const char *bond_mode_name(int mode);
-void bond_select_active_slave(struct bonding *bond);
-void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
+void bond_select_active_slave(struct bonding *bond, int rtnl_locked);
+void bond_change_active_slave(struct bonding *bond, struct slave *new_active, int rtnl_locked);
 void bond_register_arp(struct bonding *);
 void bond_unregister_arp(struct bonding *);
 
