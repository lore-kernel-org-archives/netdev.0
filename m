From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 3/3] [bonding 2.4] Use the per-bond values of all remaining parameters
Date: Mon, 5 Jan 2004 17:28:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401051728.42301.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>, "Jay Vosburgh" <fubar@us.ibm.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change usage of the all remaining global parameters to the per-bond
values.


diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Mon Jan  5 17:05:08 2004
+++ b/drivers/net/bonding/bond_main.c	Mon Jan  5 17:05:10 2004
@@ -458,6 +458,9 @@
  *	- Fixed: Releasing the original active slave causes mac address duplication.
  *	- Add support for slaves that use ethtool_ops.
  *	  Set version to 2.5.3.
+ *
+ * 2004/01/05 - Amir Noam <amir.noam at intel dot com>
+ *	- Save bonding parameters per bond instead of using the global values.
  */
 
 //#define BONDING_DEBUG 1
@@ -699,14 +702,14 @@ verify:
  * It'd be nice if there was a good way to tell if a driver supports
  * netif_carrier, but there really isn't.
  */
-static int bond_check_dev_link(struct net_device *slave_dev, int reporting)
+static int bond_check_dev_link(struct bonding *bond, struct net_device *slave_dev, int reporting)
 {
 	static int (* ioctl)(struct net_device *, struct ifreq *, int);
 	struct ifreq ifr;
 	struct mii_ioctl_data *mii;
 	struct ethtool_value etool;
 
-	if (use_carrier) {
+	if (bond->params.use_carrier) {
 		return netif_carrier_ok(slave_dev) ? BMSR_LSTATUS : 0;
 	}
 
@@ -994,7 +997,7 @@ static struct slave *bond_find_best_slav
 {
 	struct slave *new_active, *old_active;
 	struct slave *bestslave = NULL;
-	int mintime;
+	int mintime = bond->params.updelay;
 	int i;
 
 	new_active = old_active = bond->curr_active_slave;
@@ -1007,15 +1010,13 @@ static struct slave *bond_find_best_slav
 		}
 	}
 
-	mintime = updelay;
-
 	/* first try the primary link; if arping, a link must tx/rx traffic
 	 * before it can be considered the curr_active_slave - also, we would skip
 	 * slaves between the curr_active_slave and primary_slave that may be up
 	 * and able to arp
 	 */
 	if ((bond->primary_slave) &&
-	    (!arp_interval) &&
+	    (!bond->params.arp_interval) &&
 	    (IS_UP(bond->primary_slave->dev))) {
 		new_active = bond->primary_slave;
 	}
@@ -1070,7 +1071,7 @@ static void bond_change_active_slave(str
 				       ": %s: making interface %s the new "
 				       "active one %d ms earlier.\n",
 				       bond->dev->name, new_active->dev->name,
-				       (updelay - new_active->delay) * miimon);
+				       (bond->params.updelay - new_active->delay) * bond->params.miimon);
 			}
 
 			new_active->delay = 0;
@@ -1374,10 +1375,10 @@ static int bond_enslave(struct net_devic
 	new_slave->delay = 0;
 	new_slave->link_failure_count = 0;
 
-	if (miimon && !use_carrier) {
-		link_reporting = bond_check_dev_link(slave_dev, 1);
+	if (bond->params.miimon && !bond->params.use_carrier) {
+		link_reporting = bond_check_dev_link(bond, slave_dev, 1);
 
-		if ((link_reporting == -1) && !arp_interval) {
+		if ((link_reporting == -1) && !bond->params.arp_interval) {
 			/*
 			 * miimon is set but a bonded network driver
 			 * does not support ETHTOOL/MII and
@@ -1407,13 +1408,13 @@ static int bond_enslave(struct net_devic
 	}
 
 	/* check for initial state */
-	if (!miimon ||
-	    (bond_check_dev_link(slave_dev, 0) == BMSR_LSTATUS)) {
-		if (updelay) {
+	if (!bond->params.miimon ||
+	    (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS)) {
+		if (bond->params.updelay) {
 			dprintk("Initial state of slave_dev is "
 				"BOND_LINK_BACK\n");
 			new_slave->link  = BOND_LINK_BACK;
-			new_slave->delay = updelay;
+			new_slave->delay = bond->params.updelay;
 		} else {
 			dprintk("Initial state of slave_dev is "
 				"BOND_LINK_UP\n");
@@ -1441,9 +1442,9 @@ static int bond_enslave(struct net_devic
 		}
 	}
 
-	if (USES_PRIMARY(bond->params.mode) && primary) {
+	if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
 		/* if there is a primary slave, remember it */
-		if (strcmp(primary, new_slave->dev->name) == 0) {
+		if (strcmp(bond->params.primary, new_slave->dev->name) == 0) {
 			bond->primary_slave = new_slave;
 		}
 	}
@@ -1482,7 +1483,7 @@ static int bond_enslave(struct net_devic
 			 * can be called only after the mac address of the bond is set
 			 */
 			bond_3ad_initialize(bond, 1000/AD_TIMER_INTERVAL,
-					    lacp_fast);
+					    bond->params.lacp_fast);
 		} else {
 			SLAVE_AD_INFO(new_slave).id =
 				SLAVE_AD_INFO(new_slave->prev).id + 1;
@@ -1958,7 +1959,7 @@ static int bond_info_query(struct net_de
 	struct bonding *bond = bond_dev->priv;
 
 	info->bond_mode = bond->params.mode;
-	info->miimon = miimon;
+	info->miimon = bond->params.miimon;
 
 	read_lock_bh(&bond->lock);
 	info->num_slaves = bond->slave_cnt;
@@ -2008,11 +2009,13 @@ static void bond_mii_monitor(struct net_
 	struct bonding *bond = bond_dev->priv;
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
-	int delta_in_ticks = (miimon * HZ) / 1000;
+	int delta_in_ticks;
 	int i;
 
 	read_lock(&bond->lock);
 
+	delta_in_ticks = (bond->params.miimon * HZ) / 1000;
+
 	if (bond->kill_timers) {
 		goto out;
 	}
@@ -2037,7 +2040,7 @@ static void bond_mii_monitor(struct net_
 		u16 old_speed = slave->speed;
 		u8 old_duplex = slave->duplex;
 
-		link_state = bond_check_dev_link(slave_dev, 0);
+		link_state = bond_check_dev_link(bond, slave_dev, 0);
 
 		switch (slave->link) {
 		case BOND_LINK_UP:	/* the link was up */
@@ -2046,13 +2049,13 @@ static void bond_mii_monitor(struct net_
 				break;
 			} else { /* link going down */
 				slave->link  = BOND_LINK_FAIL;
-				slave->delay = downdelay;
+				slave->delay = bond->params.downdelay;
 
 				if (slave->link_failure_count < UINT_MAX) {
 					slave->link_failure_count++;
 				}
 
-				if (downdelay) {
+				if (bond->params.downdelay) {
 					printk(KERN_INFO DRV_NAME
 					       ": %s: link status down for %s "
 					       "interface %s, disabling it in "
@@ -2065,7 +2068,7 @@ static void bond_mii_monitor(struct net_
 						  : "")
 					       : "idle ",
 					       slave_dev->name,
-					       downdelay * miimon);
+					       bond->params.downdelay * bond->params.miimon);
 				}
 			}
 			/* no break ! fall through the BOND_LINK_FAIL test to
@@ -2117,7 +2120,7 @@ static void bond_mii_monitor(struct net_
 				       ": %s: link status up again after %d "
 				       "ms for interface %s.\n",
 				       bond_dev->name,
-				       (downdelay - slave->delay) * miimon,
+				       (bond->params.downdelay - slave->delay) * bond->params.miimon,
 				       slave_dev->name);
 			}
 			break;
@@ -2127,9 +2130,9 @@ static void bond_mii_monitor(struct net_
 				break;
 			} else {	/* link going up */
 				slave->link  = BOND_LINK_BACK;
-				slave->delay = updelay;
+				slave->delay = bond->params.updelay;
 
-				if (updelay) {
+				if (bond->params.updelay) {
 					/* if updelay == 0, no need to
 					   advertise about a 0 ms delay */
 					printk(KERN_INFO DRV_NAME
@@ -2138,7 +2141,7 @@ static void bond_mii_monitor(struct net_
 					       "in %d ms.\n",
 					       bond_dev->name,
 					       slave_dev->name,
-					       updelay * miimon);
+					       bond->params.updelay * bond->params.miimon);
 				}
 			}
 			/* no break ! fall through the BOND_LINK_BACK state in
@@ -2153,7 +2156,7 @@ static void bond_mii_monitor(struct net_
 				       ": %s: link status down again after %d "
 				       "ms for interface %s.\n",
 				       bond_dev->name,
-				       (updelay - slave->delay) * miimon,
+				       (bond->params.updelay - slave->delay) * bond->params.miimon,
 				       slave_dev->name);
 			} else {
 				/* link stays up */
@@ -2235,17 +2238,20 @@ static void bond_mii_monitor(struct net_
 	}
 
 re_arm:
-	mod_timer(&bond->mii_timer, jiffies + delta_in_ticks);
+	if (bond->params.miimon) {
+		mod_timer(&bond->mii_timer, jiffies + delta_in_ticks);
+	}
 out:
 	read_unlock(&bond->lock);
 }
 
-static void bond_arp_send_all(struct slave *slave)
+static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 {
 	int i;
+	u32 *targets = bond->params.arp_targets;
 
-	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && arp_target[i]; i++) {
-		arp_send(ARPOP_REQUEST, ETH_P_ARP, arp_target[i], slave->dev,
+	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && targets[i]; i++) {
+		arp_send(ARPOP_REQUEST, ETH_P_ARP, targets[i], slave->dev,
 			 my_ip, NULL, slave->dev->dev_addr,
 			 NULL);
 	}
@@ -2263,11 +2269,13 @@ static void bond_loadbalance_arp_mon(str
 	struct bonding *bond = bond_dev->priv;
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
-	int delta_in_ticks = (arp_interval * HZ) / 1000;
+	int delta_in_ticks;
 	int i;
 
 	read_lock(&bond->lock);
 
+	delta_in_ticks = (bond->params.arp_interval * HZ) / 1000;
+
 	if (bond->kill_timers) {
 		goto out;
 	}
@@ -2352,7 +2360,7 @@ static void bond_loadbalance_arp_mon(str
 		 * to be unstable during low/no traffic periods
 		 */
 		if (IS_UP(slave->dev)) {
-			bond_arp_send_all(slave);
+			bond_arp_send_all(bond, slave);
 		}
 	}
 
@@ -2372,7 +2380,9 @@ static void bond_loadbalance_arp_mon(str
 	}
 
 re_arm:
-	mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
+	if (bond->params.arp_interval) {
+		mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
+	}
 out:
 	read_unlock(&bond->lock);
 }
@@ -2396,11 +2406,13 @@ static void bond_activebackup_arp_mon(st
 {
 	struct bonding *bond = bond_dev->priv;
 	struct slave *slave;
-	int delta_in_ticks = (arp_interval * HZ) / 1000;
+	int delta_in_ticks;
 	int i;
 
 	read_lock(&bond->lock);
 
+	delta_in_ticks = (bond->params.arp_interval * HZ) / 1000;
+
 	if (bond->kill_timers) {
 		goto out;
 	}
@@ -2559,7 +2571,7 @@ static void bond_activebackup_arp_mon(st
 		 * rx traffic
 		 */
 		if (slave && my_ip) {
-			bond_arp_send_all(slave);
+			bond_arp_send_all(bond, slave);
 		}
 	}
 
@@ -2580,7 +2592,7 @@ static void bond_activebackup_arp_mon(st
 				if (IS_UP(slave->dev)) {
 					slave->link = BOND_LINK_BACK;
 					bond_set_slave_active_flags(slave);
-					bond_arp_send_all(slave);
+					bond_arp_send_all(bond, slave);
 					slave->jiffies = jiffies;
 					bond->current_arp_slave = slave;
 					break;
@@ -2612,7 +2624,9 @@ static void bond_activebackup_arp_mon(st
 	}
 
 re_arm:
-	mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
+	if (bond->params.arp_interval) {
+		mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
+	}
 out:
 	read_unlock(&bond->lock);
 }
@@ -2683,22 +2697,27 @@ static void bond_info_show_master(struct
 		   bond_mode_name(bond->params.mode));
 
 	if (USES_PRIMARY(bond->params.mode)) {
-		if (curr) {
-			seq_printf(seq,
-				   "Currently Active Slave: %s\n",
-				   curr->dev->name);
-		}
+		seq_printf(seq, "Primary Slave: %s\n",
+			   (bond->params.primary[0]) ?
+			   	bond->params.primary : "None");
+
+		seq_printf(seq, "Currently Active Slave: %s\n",
+			   (curr) ? curr->dev->name : "None");
 	}
 
 	seq_printf(seq, "MII Status: %s\n", (curr) ? "up" : "down");
-	seq_printf(seq, "MII Polling Interval (ms): %d\n", miimon);
-	seq_printf(seq, "Up Delay (ms): %d\n", updelay * miimon);
-	seq_printf(seq, "Down Delay (ms): %d\n", downdelay * miimon);
+	seq_printf(seq, "MII Polling Interval (ms): %d\n", bond->params.miimon);
+	seq_printf(seq, "Up Delay (ms): %d\n",
+		   bond->params.updelay * bond->params.miimon);
+	seq_printf(seq, "Down Delay (ms): %d\n",
+		   bond->params.downdelay * bond->params.miimon);
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 
 		seq_puts(seq, "\n802.3ad info\n");
+		seq_printf(seq, "LACP rate: %s\n",
+			   (bond->params.lacp_fast) ? "fast" : "slow");
 
 		if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
 			seq_printf(seq, "bond %s has no active aggregator\n",
@@ -3058,7 +3077,7 @@ static int bond_open(struct net_device *
 		add_timer(alb_timer);
 	}
 
-	if (miimon) {  /* link check interval, in milliseconds. */
+	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
 		init_timer(mii_timer);
 		mii_timer->expires  = jiffies + 1;
 		mii_timer->data     = (unsigned long)bond_dev;
@@ -3066,7 +3085,7 @@ static int bond_open(struct net_device *
 		add_timer(mii_timer);
 	}
 
-	if (arp_interval) {  /* arp interval, in milliseconds. */
+	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
 		init_timer(arp_timer);
 		arp_timer->expires  = jiffies + 1;
 		arp_timer->data     = (unsigned long)bond_dev;
@@ -3115,11 +3134,11 @@ static int bond_close(struct net_device 
 	 * because a running timer might be trying to hold it too
 	 */
 
-	if (miimon) {  /* link check interval, in milliseconds. */
+	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
 		del_timer_sync(&bond->mii_timer);
 	}
 
-	if (arp_interval) {  /* arp interval, in milliseconds. */
+	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
 		del_timer_sync(&bond->arp_timer);
 	}
 
@@ -3602,7 +3621,7 @@ static int bond_xmit_activebackup(struct
 
 	/* if we are sending arp packets, try to at least
 	   identify our own ip address */
-	if (arp_interval && !my_ip &&
+	if (bond->params.arp_interval && !my_ip &&
 		(skb->protocol == __constant_htons(ETH_P_ARP))) {
 		char *the_ip = (char *)skb->data +
 				sizeof(struct ethhdr) +
