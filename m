From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [patch][bonding] fix kernel panic when removing the primary slave
Date: Wed, 20 Aug 2003 17:33:31 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308201733.31144.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When releasing the primary slave, there is a kernel panic because the
bond->primary_slave is not set to NULL until after calling
change_active_interface(), even though the slave was already detached
from the slave list.

Patch is against 2.4.22-rc2.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |



diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	2003-08-20 17:17:57.000000000 +0300
+++ b/drivers/net/bonding/bond_main.c	2003-08-20 17:19:11.000000000 +0300
@@ -1976,6 +1976,10 @@ static int bond_release(struct net_devic
 			/* release the slave from its bond */
 			bond_detach_slave(bond, our_slave);
 
+			if (bond->primary_slave == our_slave) {
+				bond->primary_slave = NULL;
+			}
+
 			printk (KERN_INFO "%s: releasing %s interface %s",
 				master->name,
 				(our_slave->state == BOND_STATE_ACTIVE) ? "active" : "backup",
@@ -1994,10 +1998,6 @@ static int bond_release(struct net_devic
 					master->name);
 			}
 
-			if (bond->primary_slave == our_slave) {
-				bond->primary_slave = NULL;
-			}
-
 			if ((bond_mode == BOND_MODE_TLB) ||
 			    (bond_mode == BOND_MODE_ALB)) {
 				/* must be called only after the slave has been
