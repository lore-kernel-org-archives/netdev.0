From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [bonding][patch] Fix load balance problem with high UDP Tx stress
Date: Thu, 26 Jun 2003 17:57:52 +0300 (IDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0306261502090.18704-100000@jrslxjul1.npdj.intel.com>
Reply-To: Shmulik Hen <shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Amir Noam <amir.noam@intel.com>, "Chad N. Tindel" <ctindel@calma.pair.com>,
   Jay Vosburgh <fubar@us.ibm.com>, Jeff Garzik <jgarzik@pobox.com>,
   Noam Marom <noam.marom@intel.com>, Shmulik Hen <shmulik.hen@intel.com>,
   Tsippy Mendelson <tsippy.mendelson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: bond-devel <bonding-devel@lists.sourceforge.net>,
   linux-net <linux-net@vger.kernel.org>, linux-netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

	This patch fixes a problem detected by our QA group. On very high
UDP Tx stress traffic on 10/100 adapters, load sharing would collapse to
only one slave after very short time. The bug is due to unsigned to signed
conversions that caused calculation errors (outgoing traffic "exceeds"
adapter's actual capability).

	Since we still don't use bitkeeper, this patch should be applied
on top of Marcelo's 2.4.22-pre1 patch plus Jeff Garzik's 2.4 net driver
updates from from June 20Th (2.4.22-pre1-netdrvr1).

-- 
| Shmulik Hen                             |
| Israel Design Center (Jerusalem)        |
| LAN Access Division                     |
| Intel Communications Group, Intel corp. |


diff -Nuarp linux-2.4.22-pre1-netdrvr1/drivers/net/bonding/bond_alb.c linux-2.4.22-pre1-netdrvr1-devel/drivers/net/bonding/bond_alb.c
--- linux-2.4.22-pre1-netdrvr1/drivers/net/bonding/bond_alb.c	Wed Jun 25 16:33:19 2003
+++ linux-2.4.22-pre1-netdrvr1-devel/drivers/net/bonding/bond_alb.c	Wed Jun 25 16:33:20 2003
@@ -17,6 +17,13 @@
  *
  * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
+ *
+ *
+ * Changes:
+ *
+ * 2003/06/25 - Shmulik Hen <shmulik.hen at intel dot com>
+ *	- Fixed signed/unsigned calculation errors that caused load sharing
+ *	  to collapse to one slave under very heavy UDP Tx stress.
  */

 #include <linux/skbuff.h>
@@ -246,7 +253,7 @@ tlb_get_least_loaded_slave(struct bondin
 {
 	struct slave *slave;
 	struct slave *least_loaded;
-	u32 curr_gap, max_gap;
+	s64 curr_gap, max_gap;

 	/* Find the first enabled slave */
 	slave = bond_get_first_slave(bond);
@@ -262,15 +269,15 @@ tlb_get_least_loaded_slave(struct bondin
 	}

 	least_loaded = slave;
-	max_gap = (slave->speed * 1000000) -
-		  (SLAVE_TLB_INFO(slave).load * 8);
+	max_gap = (s64)(slave->speed * 1000000) -
+			(s64)(SLAVE_TLB_INFO(slave).load * 8);

 	/* Find the slave with the largest gap */
 	slave = bond_get_next_slave(bond, slave);
 	while (slave) {
 		if (SLAVE_IS_OK(slave)) {
-			curr_gap = (slave->speed * 1000000) -
-				   (SLAVE_TLB_INFO(slave).load * 8);
+			curr_gap = (s64)(slave->speed * 1000000) -
+					(s64)(SLAVE_TLB_INFO(slave).load * 8);
 			if (max_gap < curr_gap) {
 				least_loaded = slave;
 				max_gap = curr_gap;
diff -Nuarp linux-2.4.22-pre1-netdrvr1/drivers/net/bonding/bond_main.c linux-2.4.22-pre1-netdrvr1-devel/drivers/net/bonding/bond_main.c
--- linux-2.4.22-pre1-netdrvr1/drivers/net/bonding/bond_main.c	Wed Jun 25 16:33:19 2003
+++ linux-2.4.22-pre1-netdrvr1-devel/drivers/net/bonding/bond_main.c	Wed Jun 25 16:33:20 2003
@@ -429,8 +429,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"

-#define DRV_VERSION		"2.2.11"
-#define DRV_RELDATE		"May 29, 2003"
+#define DRV_VERSION		"2.2.12"
+#define DRV_RELDATE		"June 25, 2003"
 #define DRV_NAME		"bonding"
 #define DRV_DESCRIPTION		"Ethernet Channel Bonding Driver"
