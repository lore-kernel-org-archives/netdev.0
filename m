From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 5/10] [bonding 2.6] fix change active command
Date: Thu, 4 Sep 2003 20:44:55 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309042044.55232.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep  4 20:18:02 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep  4 20:18:03 2003
@@ -1720,20 +1720,29 @@ static int bond_change_active(struct net
 		}
 	}
 
+	/*
+	 * Changing to the current active: do nothing; return success.
+	 */
+	if (newactive && (newactive == oldactive)) {
+		write_unlock_bh(&bond->lock);
+		return 0;
+	}
+
 	if ((newactive != NULL)&&
 	    (oldactive != NULL)&&
-	    (newactive != oldactive)&&
 	    (newactive->link == BOND_LINK_UP)&&
 	    IS_UP(newactive->dev)) {
-		bond_set_slave_inactive_flags(oldactive);
-		bond_set_slave_active_flags(newactive);
+		if (bond_mode == BOND_MODE_ACTIVEBACKUP) {
+			bond_set_slave_inactive_flags(oldactive);
+			bond_set_slave_active_flags(newactive);
+		}
+
 		bond_mc_update(bond, newactive, oldactive);
 		bond_assign_current_slave(bond, newactive);
 		printk("%s : activate %s(old : %s)\n",
 			master_dev->name, newactive->dev->name, 
 			oldactive->dev->name);
-	}
-	else {
+	} else {
 		ret = -EINVAL;
 	}
 	write_unlock_bh(&bond->lock);
