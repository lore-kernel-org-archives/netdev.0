From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 1/3][bonding 2.6] Cannot remove and re-enslave the original active slave
Date: Thu, 25 Dec 2003 17:05:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312251705.14755.amir.noam@intel.com>
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

In TLB/ALB modes, when enslaving a slave that has the bond's mac
address, allow the operation if no other slave has that address.

Should be applied after the cleanup patch set.


diff -Nuarp a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c	Thu Dec 25 15:31:02 2003
+++ b/drivers/net/bonding/bond_alb.c	Thu Dec 25 15:31:03 2003
@@ -992,6 +992,7 @@ static void alb_change_hw_addr_on_detach
 static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slave *slave)
 {
 	struct slave *tmp_slave1, *tmp_slave2, *free_mac_slave;
+	struct slave *has_bond_addr = bond->curr_active_slave;
 	int i, j, found = 0;
 
 	if (bond->slave_cnt == 0) {
@@ -1049,6 +1050,15 @@ static int alb_handle_addr_collision_on_
 			free_mac_slave = tmp_slave1;
 			break;
 		}
+
+		if (!has_bond_addr) {
+			if (!memcmp(tmp_slave1->dev->dev_addr,
+				    bond->dev->dev_addr,
+				    ETH_ALEN)) {
+
+				has_bond_addr = tmp_slave1;
+			}
+		}
 	}
 
 	if (free_mac_slave) {
@@ -1059,7 +1069,8 @@ static int alb_handle_addr_collision_on_
 		       ": Warning: the hw address of slave %s is in use by "
 		       "the bond; giving it the hw address of %s\n",
 		       slave->dev->name, free_mac_slave->dev->name);
-	} else {
+
+	} else if (has_bond_addr) {
 		printk(KERN_ERR DRV_NAME
 		       ": Error: the hw address of slave %s is in use by the "
 		       "bond; couldn't find a slave with a free hw address to "
