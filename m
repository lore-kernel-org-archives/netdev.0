From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [SET 2][PATCH 2/8][bonding] Propagating master's settings to slaves
Date: Fri, 8 Aug 2003 17:44:58 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308081744.58946.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

2 - Change monitoring function use the new functionality.

diff -Nuarp linux-2.4.22-rc1/drivers/net/bonding/bond_main.c linux-2.4.22-rc1-devel/drivers/net/bonding/bond_main.c
--- linux-2.4.22-rc1/drivers/net/bonding/bond_main.c	Fri Aug  8 14:03:16 2003
+++ linux-2.4.22-rc1-devel/drivers/net/bonding/bond_main.c	Fri Aug  8 14:03:17 2003
@@ -2207,8 +2207,9 @@ out:
 static void bond_mii_monitor(struct net_device *master)
 {
 	bonding_t *bond = (struct bonding *) master->priv;
-	slave_t *slave, *bestslave, *oldcurrent;
+	slave_t *slave, *oldcurrent;
 	int slave_died = 0;
+	int do_failover = 0;
 
 	read_lock(&bond->lock);
 
@@ -2218,7 +2219,6 @@ static void bond_mii_monitor(struct net_
 	 * program could monitor the link itself if needed.
 	 */
 
-	bestslave = NULL;
 	slave = (slave_t *)bond;
 
 	read_lock(&bond->ptrlock);
@@ -2226,8 +2226,6 @@ static void bond_mii_monitor(struct net_
 	read_unlock(&bond->ptrlock);
 
 	while ((slave = slave->prev) != (slave_t *)bond) {
-		/* use updelay+1 to match an UP slave even when updelay is 0 */
-		int mindelay = updelay + 1;
 		struct net_device *dev = slave->dev;
 		int link_state;
 		u16 old_speed = slave->speed;
@@ -2238,14 +2236,7 @@ static void bond_mii_monitor(struct net_
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
@@ -2285,6 +2276,7 @@ static void bond_mii_monitor(struct net_
 					    (bond_mode == BOND_MODE_8023AD)) {
 						bond_set_slave_inactive_flags(slave);
 					}
+
 					printk(KERN_INFO
 						"%s: link status definitely down "
 						"for interface %s, disabling it",
@@ -2301,12 +2293,10 @@ static void bond_mii_monitor(struct net_
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
@@ -2321,13 +2311,6 @@ static void bond_mii_monitor(struct net_
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
@@ -2397,26 +2380,12 @@ static void bond_mii_monitor(struct net_
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
@@ -2435,26 +2404,17 @@ static void bond_mii_monitor(struct net_
 
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
@@ -2472,9 +2432,10 @@ static void bond_mii_monitor(struct net_
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
@@ -2498,6 +2459,10 @@ static void loadbalance_arp_monitor(stru
 
 	read_lock(&bond->lock);
 
+	read_lock(&bond->ptrlock);
+	oldcurrent = bond->current_slave;
+	read_unlock(&bond->ptrlock);
+
 	/* see if any of the previous devices are up now (i.e. they have
 	 * xmt and rcv traffic). the current_slave does not come into
 	 * the picture unless it is null. also, slave->jiffies is not needed
@@ -2524,21 +2489,19 @@ static void loadbalance_arp_monitor(stru
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
@@ -2561,11 +2524,9 @@ static void loadbalance_arp_monitor(stru
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
 
@@ -2579,6 +2540,19 @@ static void loadbalance_arp_monitor(stru
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

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
