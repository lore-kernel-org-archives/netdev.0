From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 4/10] [bonding 2.6] fix kernel panic when optional feature used
Date: Thu, 4 Sep 2003 20:44:41 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309042044.41209.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep  4 20:17:59 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep  4 20:18:01 2003
@@ -1559,11 +1559,14 @@ static int bond_enslave(struct net_devic
 #endif
 			bond_set_slave_inactive_flags(new_slave);
 		}
-		read_lock_irqsave(&(((struct in_device *)slave_dev->ip_ptr)->lock), rflags);
-		ifap= &(((struct in_device *)slave_dev->ip_ptr)->ifa_list);
-		ifa = *ifap;
-		my_ip = ifa->ifa_address;
-		read_unlock_irqrestore(&(((struct in_device *)slave_dev->ip_ptr)->lock), rflags);
+		if (((struct in_device *)slave_dev->ip_ptr) != NULL) {
+			read_lock_irqsave(&(((struct in_device *)slave_dev->ip_ptr)->lock), rflags);
+			ifap= &(((struct in_device *)slave_dev->ip_ptr)->ifa_list);
+			ifa = *ifap;
+			if (ifa != NULL)
+				my_ip = ifa->ifa_address;
+			read_unlock_irqrestore(&(((struct in_device *)slave_dev->ip_ptr)->lock), rflags);
+		}
 
 		/* if there is a primary slave, remember it */
 		if (primary != NULL) {
@@ -2730,10 +2733,8 @@ static void activebackup_arp_monitor(str
 		/* the current slave must tx an arp to ensure backup slaves
 		 * rx traffic
 		 */
-		if ((slave != NULL) &&
-		    (((jiffies - slave->dev->last_rx) >= the_delta_in_ticks) &&
-		     (my_ip != 0))) {
-		  arp_send_all(slave);
+		if ((slave != NULL) && (my_ip != 0)) {
+			arp_send_all(slave);
 		}
 	}
 
