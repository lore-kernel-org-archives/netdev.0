From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 2/3][bonding 2.6] Releasing the original active slave causes mac address duplication
Date: Thu, 25 Dec 2003 17:05:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312251705.25881.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>, jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When releasing the active slave in TLB/ALB modes,
bond_alb_deinit_slave() must be called before trying to select a new
active slave.


diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Dec 25 15:31:05 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Dec 25 15:31:06 2003
@@ -1557,7 +1557,7 @@ err_free:
 static int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 {
 	struct bonding *bond = bond_dev->priv;
-	struct slave *slave;
+	struct slave *slave, *oldcurrent;
 	struct sockaddr addr;
 	int mac_addr_differ;
 
@@ -1617,6 +1617,8 @@ static int bond_release(struct net_devic
 	       ? "active" : "backup",
 	       slave_dev->name);
 
+	oldcurrent = bond->curr_active_slave;
+
 	bond->current_arp_slave = NULL;
 
 	/* release the slave from its bond */
@@ -1626,27 +1628,31 @@ static int bond_release(struct net_devic
 		bond->primary_slave = NULL;
 	}
 
-	if (bond->curr_active_slave == slave) {
+	if (oldcurrent == slave) {
 		bond_change_active_slave(bond, NULL);
-		bond_select_active_slave(bond);
-	}
-
-	if (!bond->curr_active_slave) {
-		printk(KERN_INFO DRV_NAME
-		       ": %s: now running without any active "
-		       "interface !\n",
-		       bond_dev->name);
 	}
 
-	if ((bond_mode == BOND_MODE_TLB) ||
-	    (bond_mode == BOND_MODE_ALB)) {
-		/* must be called only after the slave has been
+	if ((bond->params.mode == BOND_MODE_TLB) ||
+	    (bond->params.mode == BOND_MODE_ALB)) {
+		/* Must be called only after the slave has been
 		 * detached from the list and the curr_active_slave
-		 * has been replaced (if our_slave == old_current)
+		 * has been cleared (if our_slave == old_current),
+		 * but before a new active slave is selected.
 		 */
 		bond_alb_deinit_slave(bond, slave);
 	}
 
+	if (oldcurrent == slave) {
+		bond_select_active_slave(bond);
+
+		if (!bond->curr_active_slave) {
+			printk(KERN_INFO DRV_NAME
+			       ": %s: now running without any active "
+			       "interface !\n",
+			       bond_dev->name);
+		}
+	}
+
 	write_unlock_bh(&bond->lock);
 
 	/* If the mode USES_PRIMARY, then we should only remove its
