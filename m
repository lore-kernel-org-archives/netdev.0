From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 2/10] [bonding 2.6] fix monitoring functions
Date: Thu, 11 Sep 2003 17:38:20 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309111738.20957.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:14 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:15 2003
@@ -2191,8 +2191,9 @@ out:
 static void bond_mii_monitor(struct net_device *master)
 {
 	bonding_t *bond = (struct bonding *) master->priv;
-	slave_t *slave, *bestslave, *oldcurrent;
+	slave_t *slave, *oldcurrent;
 	int slave_died = 0;
+	int do_failover = 0;
 
 	read_lock(&bond->lock);
 
@@ -2202,7 +2203,6 @@ static void bond_mii_monitor(struct net_
 	 * program could monitor the link itself if needed.
 	 */
 
-	bestslave = NULL;
 	slave = (slave_t *)bond;
 
 	read_lock(&bond->ptrlock);
@@ -2210,8 +2210,6 @@ static void bond_mii_monitor(struct net_
 	read_unlock(&bond->ptrlock);
 
 	while ((slave = slave->prev) != (slave_t *)bond) {
-		/* use updelay+1 to match an UP slave even when updelay is 0 */
-		int mindelay = updelay + 1;
 		struct net_device *dev = slave->dev;
 		int link_state;
 		u16 old_speed = slave->speed;
@@ -2222,14 +2220,7 @@ static void bond_mii_monitor(struct net_
 		switch (slave->link) {
 		case BOND_LINK_UP:	/* the link was up */
 			if (link_state == BMSR_LSTATUS) {
-				/* link stays up, tell that this one
-				   is immediately available */
-				if (IS_UP(dev) && (mindelay > -2)) {
-					/* -2 is the best case :
-					   this slave was already up */
-					mindelay = -2;
-					bestslave = slave;
-				}
+				/* link stays up, nothing more to do */
 				break;
 			}
 			else { /* link going down */
@@ -2269,6 +2260,7 @@ static void bond_mii_monitor(struct net_
 					    (bond_mode == BOND_MODE_8023AD)) {
 						bond_set_slave_inactive_flags(slave);
 					}
+
 					printk(KERN_INFO
 						"%s: link status definitely down "
 						"for interface %s, disabling it",
@@ -2285,12 +2277,10 @@ static void bond_mii_monitor(struct net_
 						bond_alb_handle_link_change(bond, slave, BOND_LINK_DOWN);
 					}
 
-					write_lock(&bond->ptrlock);
-					if (slave == bond->current_slave) {
-						/* find a new interface and be verbose */
-						reselect_active_interface(bond);
+					if (slave == oldcurrent) {
+						do_failover = 1;
 					}
-					write_unlock(&bond->ptrlock);
+
 					slave_died = 1;
 				} else {
 					slave->delay--;
@@ -2305,13 +2295,6 @@ static void bond_mii_monitor(struct net_
 					master->name,
 					(downdelay - slave->delay) * miimon,
 					dev->name);
-
-				if (IS_UP(dev) && (mindelay > -1)) {
-					/* -1 is a good case : this slave went
-					   down only for a short time */
-					mindelay = -1;
-					bestslave = slave;
-				}
 			}
 			break;
 		case BOND_LINK_DOWN:	/* the link was down */
@@ -2381,26 +2364,12 @@ static void bond_mii_monitor(struct net_
 						bond_alb_handle_link_change(bond, slave, BOND_LINK_UP);
 					}
 
-					write_lock(&bond->ptrlock);
-					if ( (bond->primary_slave != NULL)
-					  && (slave == bond->primary_slave) )
-						reselect_active_interface(bond); 
-					write_unlock(&bond->ptrlock);
-				}
-				else
+					if ((oldcurrent == NULL) ||
+					    (slave == bond->primary_slave)) {
+						do_failover = 1;
+					}
+				} else {
 					slave->delay--;
-
-				/* we'll also look for the mostly eligible slave */
-				if (bond->primary_slave == NULL)  {
-				    if (IS_UP(dev) && (slave->delay < mindelay)) {
-					mindelay = slave->delay;
-					bestslave = slave;
-				    } 
-				} else if ( (IS_UP(bond->primary_slave->dev))  || 
-				          ( (!IS_UP(bond->primary_slave->dev))  && 
-				          (IS_UP(dev) && (slave->delay < mindelay)) ) ) {
-					mindelay = slave->delay;
-					bestslave = slave;
 				}
 			}
 			break;
@@ -2419,26 +2388,17 @@ static void bond_mii_monitor(struct net_
 
 	} /* end of while */
 
-	/* 
-	 * if there's no active interface and we discovered that one
-	 * of the slaves could be activated earlier, so we do it.
-	 */
-	read_lock(&bond->ptrlock);
-	oldcurrent = bond->current_slave;
-	read_unlock(&bond->ptrlock);
+	if (do_failover) {
+		write_lock(&bond->ptrlock);
 
-	/* no active interface at the moment or need to bring up the primary */
-	if (oldcurrent == NULL)  { /* no active interface at the moment */
-		if (bestslave != NULL) { /* last chance to find one ? */
-			write_lock(&bond->ptrlock);
-			change_active_interface(bond, bestslave);
-			write_unlock(&bond->ptrlock);
-		} else if (slave_died) {
-			/* print this message only once a slave has just died */
+		reselect_active_interface(bond);
+		if (oldcurrent && !bond->current_slave) {
 			printk(KERN_INFO
 				"%s: now running without any active interface !\n",
 				master->name);
 		}
+
+		write_unlock(&bond->ptrlock);
 	}
 
 	read_unlock(&bond->lock);
@@ -2456,9 +2416,10 @@ static void bond_mii_monitor(struct net_
 static void loadbalance_arp_monitor(struct net_device *master)
 {
 	bonding_t *bond;
-	slave_t *slave;
+	slave_t *slave, *oldcurrent;
 	int the_delta_in_ticks =  arp_interval * HZ / 1000;
 	int next_timer = jiffies + (arp_interval * HZ / 1000);
+	int do_failover = 0;
 
 	bond = (struct bonding *) master->priv; 
 	if (master->priv == NULL) {
@@ -2482,6 +2443,10 @@ static void loadbalance_arp_monitor(stru
 
 	read_lock(&bond->lock);
 
+	read_lock(&bond->ptrlock);
+	oldcurrent = bond->current_slave;
+	read_unlock(&bond->ptrlock);
+
 	/* see if any of the previous devices are up now (i.e. they have
 	 * xmt and rcv traffic). the current_slave does not come into
 	 * the picture unless it is null. also, slave->jiffies is not needed
@@ -2508,21 +2473,19 @@ static void loadbalance_arp_monitor(stru
 				 * current_slave being null after enslaving
 				 * is closed.
 				 */
-				write_lock(&bond->ptrlock);
-				if (bond->current_slave == NULL) {
+				if (oldcurrent == NULL) {
 					printk(KERN_INFO
 						"%s: link status definitely up "
 						"for interface %s, ",
 						master->name,
 						slave->dev->name);
-					reselect_active_interface(bond); 
+					do_failover = 1;
 				} else {
 					printk(KERN_INFO
 						"%s: interface %s is now up\n",
 						master->name,
 						slave->dev->name);
 				}
-				write_unlock(&bond->ptrlock);
 			} 
 		} else {
 			/* slave->link == BOND_LINK_UP */
@@ -2545,11 +2508,9 @@ static void loadbalance_arp_monitor(stru
 				       master->name,
 				       slave->dev->name);
 
-				write_lock(&bond->ptrlock);
-				if (slave == bond->current_slave) {
-					reselect_active_interface(bond);
+				if (slave == oldcurrent) {
+					do_failover = 1;
 				}
-				write_unlock(&bond->ptrlock);
 			}
 		} 
 
@@ -2563,6 +2524,19 @@ static void loadbalance_arp_monitor(stru
 		if (IS_UP(slave->dev)) {
 			arp_send_all(slave);
 		}
+	}
+
+	if (do_failover) {
+		write_lock(&bond->ptrlock);
+
+		reselect_active_interface(bond);
+		if (oldcurrent && !bond->current_slave) {
+			printk(KERN_INFO
+				"%s: now running without any active interface !\n",
+				master->name);
+		}
+
+		write_unlock(&bond->ptrlock);
 	}
 
 	read_unlock(&bond->lock);
