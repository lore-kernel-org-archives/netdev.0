From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 2/10] [bonding 2.6] fix load balance problem with high UDP Tx stress
Date: Thu, 4 Sep 2003 20:44:07 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309042044.07510.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c	Thu Sep  4 20:17:54 2003
+++ b/drivers/net/bonding/bond_alb.c	Thu Sep  4 20:17:55 2003
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
