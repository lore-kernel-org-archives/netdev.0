From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [patch][bonding] Fix change active for ALB/TLB
Date: Tue, 1 Jul 2003 16:44:11 +0300 (IDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0307011628160.7001-100000@jrslxjul1.npdj.intel.com>
Reply-To: Shmulik Hen <shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Amir Noam <amir.noam@intel.com>, Noam Marom <noam.marom@intel.com>,
   Shmulik Hen <shmulik.hen@intel.com>,
   Tsippy Mendelson <tsippy.mendelson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: bond-devel <bonding-devel@lists.sourceforge.net>,
   "Chad N. Tindel" <ctindel@calma.pair.com>, Jay Vosburgh <fubar@us.ibm.com>,
   Jeff Garzik <jgarzik@pobox.com>, linux-netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

	The following patch fixes bonding's change active interface
operation for ALB/TLB modes. It used to incorrectly set the old active
interface's state to BACKUP (which is required only for active-backup
mode) and would cause that slave not to take part in load sharing.

It should be applied on latest net-drivers-2.4 BK tree.

-- 
| Shmulik Hen                             |
| Israel Design Center (Jerusalem)        |
| LAN Access Division                     |
| Intel Communications Group, Intel corp. |


diff -Nuarp linux-2.4.22-pre1-netdrvr1/drivers/net/bonding/bond_main.c linux-2.4.22-pre1-netdrvr1-devel/drivers/net/bonding/bond_main.c
--- linux-2.4.22-pre1-netdrvr1/drivers/net/bonding/bond_main.c	Mon Jun 30 15:29:56 2003
+++ linux-2.4.22-pre1-netdrvr1-devel/drivers/net/bonding/bond_main.c	Mon Jun 30 15:29:57 2003
@@ -385,6 +385,9 @@
  *	- In conjunction with fix for ifenslave -c, in
  *	  bond_change_active(), changing to the already active slave
  *	  is no longer an error (it successfully does nothing).
+ *
+ * 2003/06/30 - Amir Noam <amir.noam at intel dot com>
+ * 	- Fixed bond_change_active() for ALB/TLB modes.
  */

 #include <linux/config.h>
@@ -429,8 +432,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"

-#define DRV_VERSION		"2.2.13"
-#define DRV_RELDATE		"June 25, 2003"
+#define DRV_VERSION		"2.2.14"
+#define DRV_RELDATE		"June 30, 2003"
 #define DRV_NAME		"bonding"
 #define DRV_DESCRIPTION		"Ethernet Channel Bonding Driver"

@@ -1761,8 +1764,11 @@ static int bond_change_active(struct net
 	    (oldactive != NULL)&&
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
