From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 3/10] [bonding 2.6] fix assign_current_slave
Date: Thu, 11 Sep 2003 17:38:40 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309111738.40325.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:17 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:18 2003
@@ -590,19 +590,6 @@ static void change_active_interface(stru
 static void reselect_active_interface(struct bonding *bond);
 static struct slave *find_best_interface(struct bonding *bond);
 
-/* Caller must hold bond->ptrlock for write */
-static inline struct slave*
-bond_assign_current_slave(struct bonding *bond,struct slave *newslave)
-{
-	if ((bond_mode == BOND_MODE_TLB) ||
-	    (bond_mode == BOND_MODE_ALB)) {
-		bond_alb_assign_current_slave(bond, newslave);
-	} else {
-		bond->current_slave = newslave;
-	}
-
-	return bond->current_slave;
-}
 
 /* #define BONDING_DEBUG 1 */
 
@@ -1640,8 +1627,13 @@ static int bond_enslave(struct net_devic
 #endif
 		/* always active in trunk mode */
 		new_slave->state = BOND_STATE_ACTIVE;
+
+		/* In trunking mode there is little meaning to current_slave
+		 * anyway (it holds no special properties of the bond device),
+		 * so we can change it without calling change_active_interface()
+		 */
 		if (bond->current_slave == NULL) 
-			bond_assign_current_slave(bond, new_slave);
+			bond->current_slave = new_slave;
 	}
 
 	write_unlock_bh(&bond->lock);
@@ -1894,7 +1886,12 @@ static void change_active_interface(stru
 		bond_mc_update(bond, new, old);
 	}
 
-	bond_assign_current_slave(bond, new);
+	if ((bond_mode == BOND_MODE_TLB) ||
+	    (bond_mode == BOND_MODE_ALB)) {
+		bond_alb_assign_current_slave(bond, new);
+	} else {
+		bond->current_slave = new;
+	}
 }
 
 /**
@@ -2103,7 +2100,7 @@ static int bond_release_all(struct net_d
 	}
 
 	old_current = bond->current_slave;
-	bond_assign_current_slave(bond, NULL);
+	change_active_interface(bond, NULL);
 	bond->current_arp_slave = NULL;
 	bond->primary_slave = NULL;
 
@@ -3128,7 +3125,7 @@ static int bond_xmit_roundrobin(struct s
 			dev_queue_xmit(skb);
 
 			write_lock(&bond->ptrlock);
-			bond_assign_current_slave(bond, slave->next);
+			bond->current_slave = slave->next;
 			write_unlock(&bond->ptrlock);
 
 			read_unlock(&bond->lock);
