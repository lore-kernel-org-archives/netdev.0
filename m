From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 2/3] [bonding 2.6] Use the per-bond value of the bond_mode parameter
Date: Mon, 5 Jan 2004 17:30:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401051730.01365.amir.noam@intel.com>
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

Change usage of the global 'bond_mode' parameter to the per-bond
value.


diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Mon Jan  5 17:17:35 2004
+++ b/drivers/net/bonding/bond_main.c	Mon Jan  5 17:17:37 2004
@@ -595,9 +595,9 @@ static inline void bond_set_mode_ops(str
 
 /*---------------------------- General routines -----------------------------*/
 
-static const char *bond_mode_name(void)
+static const char *bond_mode_name(int mode)
 {
-	switch (bond_mode) {
+	switch (mode) {
 	case BOND_MODE_ROUNDROBIN :
 		return "load balancing (round-robin)";
 	case BOND_MODE_ACTIVEBACKUP :
@@ -803,7 +803,7 @@ static struct dev_mc_list *bond_mc_list_
  */
 static void bond_set_promiscuity(struct bonding *bond, int inc)
 {
-	if (USES_PRIMARY(bond_mode)) {
+	if (USES_PRIMARY(bond->params.mode)) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave) {
 			dev_set_promiscuity(bond->curr_active_slave->dev, inc);
@@ -822,7 +822,7 @@ static void bond_set_promiscuity(struct 
  */
 static void bond_set_allmulti(struct bonding *bond, int inc)
 {
-	if (USES_PRIMARY(bond_mode)) {
+	if (USES_PRIMARY(bond->params.mode)) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave) {
 			dev_set_allmulti(bond->curr_active_slave->dev, inc);
@@ -842,7 +842,7 @@ static void bond_set_allmulti(struct bon
  */
 static void bond_mc_add(struct bonding *bond, void *addr, int alen)
 {
-	if (USES_PRIMARY(bond_mode)) {
+	if (USES_PRIMARY(bond->params.mode)) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave) {
 			dev_mc_add(bond->curr_active_slave->dev, addr, alen, 0);
@@ -862,7 +862,7 @@ static void bond_mc_add(struct bonding *
  */
 static void bond_mc_delete(struct bonding *bond, void *addr, int alen)
 {
-	if (USES_PRIMARY(bond_mode)) {
+	if (USES_PRIMARY(bond->params.mode)) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave) {
 			dev_mc_delete(bond->curr_active_slave->dev, addr, alen, 0);
@@ -922,13 +922,14 @@ static int bond_mc_list_copy(struct dev_
  */
 static void bond_mc_list_flush(struct net_device *bond_dev, struct net_device *slave_dev)
 {
+	struct bonding *bond = bond_dev->priv;
 	struct dev_mc_list *dmi;
 
 	for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
 		dev_mc_delete(slave_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 	}
 
-	if (bond_mode == BOND_MODE_8023AD) {
+	if (bond->params.mode == BOND_MODE_8023AD) {
 		/* del lacpdu mc addr from mc list */
 		u8 lacpdu_multicast[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
 
@@ -947,7 +948,7 @@ static void bond_mc_swap(struct bonding 
 {
 	struct dev_mc_list *dmi;
 
-	if (!USES_PRIMARY(bond_mode)) {
+	if (!USES_PRIMARY(bond->params.mode)) {
 		/* nothing to do -  mc list is already up-to-date on
 		 * all slaves
 		 */
@@ -1064,7 +1065,7 @@ static void bond_change_active_slave(str
 
 	if (new_active) {
 		if (new_active->link == BOND_LINK_BACK) {
-			if (USES_PRIMARY(bond_mode)) {
+			if (USES_PRIMARY(bond->params.mode)) {
 				printk(KERN_INFO DRV_NAME
 				       ": %s: making interface %s the new "
 				       "active one %d ms earlier.\n",
@@ -1076,16 +1077,16 @@ static void bond_change_active_slave(str
 			new_active->link = BOND_LINK_UP;
 			new_active->jiffies = jiffies;
 
-			if (bond_mode == BOND_MODE_8023AD) {
+			if (bond->params.mode == BOND_MODE_8023AD) {
 				bond_3ad_handle_link_change(new_active, BOND_LINK_UP);
 			}
 
-			if ((bond_mode == BOND_MODE_TLB) ||
-			    (bond_mode == BOND_MODE_ALB)) {
+			if ((bond->params.mode == BOND_MODE_TLB) ||
+			    (bond->params.mode == BOND_MODE_ALB)) {
 				bond_alb_handle_link_change(bond, new_active, BOND_LINK_UP);
 			}
 		} else {
-			if (USES_PRIMARY(bond_mode)) {
+			if (USES_PRIMARY(bond->params.mode)) {
 				printk(KERN_INFO DRV_NAME
 				       ": %s: making interface %s the new "
 				       "active one.\n",
@@ -1094,7 +1095,7 @@ static void bond_change_active_slave(str
 		}
 	}
 
-	if (bond_mode == BOND_MODE_ACTIVEBACKUP) {
+	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
 		if (old_active) {
 			bond_set_slave_inactive_flags(old_active);
 		}
@@ -1104,12 +1105,12 @@ static void bond_change_active_slave(str
 		}
 	}
 
-	if (USES_PRIMARY(bond_mode)) {
+	if (USES_PRIMARY(bond->params.mode)) {
 		bond_mc_swap(bond, new_active, old_active);
 	}
 
-	if ((bond_mode == BOND_MODE_TLB) ||
-	    (bond_mode == BOND_MODE_ALB)) {
+	if ((bond->params.mode == BOND_MODE_TLB) ||
+	    (bond->params.mode == BOND_MODE_ALB)) {
 		bond_alb_handle_active_change(bond, new_active);
 	} else {
 		bond->curr_active_slave = new_active;
@@ -1264,13 +1265,13 @@ static int bond_enslave(struct net_devic
 			return -EINVAL;
 		}
 
-		if ((bond_mode == BOND_MODE_8023AD) ||
-		    (bond_mode == BOND_MODE_TLB)    ||
-		    (bond_mode == BOND_MODE_ALB)) {
+		if ((bond->params.mode == BOND_MODE_8023AD) ||
+		    (bond->params.mode == BOND_MODE_TLB)    ||
+		    (bond->params.mode == BOND_MODE_ALB)) {
 			printk(KERN_ERR DRV_NAME
 			       ": Error: to use %s mode, you must upgrade "
 			       "ifenslave.\n",
-			       bond_mode_name());
+			       bond_mode_name(bond->params.mode));
 			return -EOPNOTSUPP;
 		}
 	}
@@ -1326,8 +1327,8 @@ static int bond_enslave(struct net_devic
 
 	new_slave->dev = slave_dev;
 
-	if ((bond_mode == BOND_MODE_TLB) ||
-	    (bond_mode == BOND_MODE_ALB)) {
+	if ((bond->params.mode == BOND_MODE_TLB) ||
+	    (bond->params.mode == BOND_MODE_ALB)) {
 		/* bond_alb_init_slave() must be called before all other stages since
 		 * it might fail and we do not want to have to undo everything
 		 */
@@ -1342,7 +1343,7 @@ static int bond_enslave(struct net_devic
 	 * curr_active_slave, and that is taken care of later when calling
 	 * bond_change_active()
 	 */
-	if (!USES_PRIMARY(bond_mode)) {
+	if (!USES_PRIMARY(bond->params.mode)) {
 		/* set promiscuity level to new slave */
 		if (bond_dev->flags & IFF_PROMISC) {
 			dev_set_promiscuity(slave_dev, 1);
@@ -1359,7 +1360,7 @@ static int bond_enslave(struct net_devic
 		}
 	}
 
-	if (bond_mode == BOND_MODE_8023AD) {
+	if (bond->params.mode == BOND_MODE_8023AD) {
 		/* add lacpdu mc addr to mc list */
 		u8 lacpdu_multicast[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
 
@@ -1432,7 +1433,7 @@ static int bond_enslave(struct net_devic
 		       "forced to 100Mbps, duplex forced to Full.\n",
 		       new_slave->dev->name);
 
-		if (bond_mode == BOND_MODE_8023AD) {
+		if (bond->params.mode == BOND_MODE_8023AD) {
 			printk(KERN_WARNING
 			       "Operation of 802.3ad mode requires ETHTOOL "
 			       "support in base driver for proper aggregator "
@@ -1440,14 +1441,14 @@ static int bond_enslave(struct net_devic
 		}
 	}
 
-	if (USES_PRIMARY(bond_mode) && primary) {
+	if (USES_PRIMARY(bond->params.mode) && primary) {
 		/* if there is a primary slave, remember it */
 		if (strcmp(primary, new_slave->dev->name) == 0) {
 			bond->primary_slave = new_slave;
 		}
 	}
 
-	switch (bond_mode) {
+	switch (bond->params.mode) {
 	case BOND_MODE_ACTIVEBACKUP:
 		/* if we're in active-backup mode, we need one and only one active
 		 * interface. The backup interfaces will have their NOARP flag set
@@ -1637,7 +1638,7 @@ static int bond_release(struct net_devic
 	}
 
 	/* Inform AD package of unbinding of slave. */
-	if (bond_mode == BOND_MODE_8023AD) {
+	if (bond->params.mode == BOND_MODE_8023AD) {
 		/* must be called before the slave is
 		 * detached from the list
 		 */
@@ -1666,8 +1667,8 @@ static int bond_release(struct net_devic
 		bond_change_active_slave(bond, NULL);
 	}
 
-	if ((bond_mode == BOND_MODE_TLB) ||
-	    (bond_mode == BOND_MODE_ALB)) {
+	if ((bond->params.mode == BOND_MODE_TLB) ||
+	    (bond->params.mode == BOND_MODE_ALB)) {
 		/* Must be called only after the slave has been
 		 * detached from the list and the curr_active_slave
 		 * has been cleared (if our_slave == old_current),
@@ -1693,7 +1694,7 @@ static int bond_release(struct net_devic
 	 * promisc and mc settings if it was the curr_active_slave, but that was
 	 * already taken care of above when we detached the slave
 	 */
-	if (!USES_PRIMARY(bond_mode)) {
+	if (!USES_PRIMARY(bond->params.mode)) {
 		/* unset promiscuity level from slave */
 		if (bond_dev->flags & IFF_PROMISC) {
 			dev_set_promiscuity(slave_dev, -1);
@@ -1765,15 +1766,15 @@ static int bond_release_all(struct net_d
 		/* Inform AD package of unbinding of slave
 		 * before slave is detached from the list.
 		 */
-		if (bond_mode == BOND_MODE_8023AD) {
+		if (bond->params.mode == BOND_MODE_8023AD) {
 			bond_3ad_unbind_slave(slave);
 		}
 
 		slave_dev = slave->dev;
 		bond_detach_slave(bond, slave);
 
-		if ((bond_mode == BOND_MODE_TLB) ||
-		    (bond_mode == BOND_MODE_ALB)) {
+		if ((bond->params.mode == BOND_MODE_TLB) ||
+		    (bond->params.mode == BOND_MODE_ALB)) {
 			/* must be called only after the slave
 			 * has been detached from the list
 			 */
@@ -1790,7 +1791,7 @@ static int bond_release_all(struct net_d
 		 * promisc and mc settings if it was the curr_active_slave, but that was
 		 * already taken care of above when we detached the slave
 		 */
-		if (!USES_PRIMARY(bond_mode)) {
+		if (!USES_PRIMARY(bond->params.mode)) {
 			/* unset promiscuity level from slave */
 			if (bond_dev->flags & IFF_PROMISC) {
 				dev_set_promiscuity(slave_dev, -1);
@@ -1864,6 +1865,10 @@ static int bond_ioctl_change_active(stru
 	struct slave *new_active = NULL;
 	int res = 0;
 
+	if (!USES_PRIMARY(bond->params.mode)) {
+		return -EINVAL;
+	}
+
 	/* Verify that master_dev is indeed the master of slave_dev */
 	if (!(slave_dev->flags & IFF_SLAVE) ||
 	    (slave_dev->master != bond_dev)) {
@@ -1952,7 +1957,7 @@ static int bond_info_query(struct net_de
 {
 	struct bonding *bond = bond_dev->priv;
 
-	info->bond_mode = bond_mode;
+	info->bond_mode = bond->params.mode;
 	info->miimon = miimon;
 
 	read_lock_bh(&bond->lock);
@@ -2054,7 +2059,7 @@ static void bond_mii_monitor(struct net_
 					       "%d ms.\n",
 					       bond_dev->name,
 					       IS_UP(slave_dev)
-					       ? ((bond_mode == BOND_MODE_ACTIVEBACKUP)
+					       ? ((bond->params.mode == BOND_MODE_ACTIVEBACKUP)
 						  ? ((slave == oldcurrent)
 						     ? "active " : "backup ")
 						  : "")
@@ -2076,8 +2081,8 @@ static void bond_mii_monitor(struct net_
 					/* in active/backup mode, we must
 					 * completely disable this interface
 					 */
-					if ((bond_mode == BOND_MODE_ACTIVEBACKUP) ||
-					    (bond_mode == BOND_MODE_8023AD)) {
+					if ((bond->params.mode == BOND_MODE_ACTIVEBACKUP) ||
+					    (bond->params.mode == BOND_MODE_8023AD)) {
 						bond_set_slave_inactive_flags(slave);
 					}
 
@@ -2089,12 +2094,12 @@ static void bond_mii_monitor(struct net_
 					       slave_dev->name);
 
 					/* notify ad that the link status has changed */
-					if (bond_mode == BOND_MODE_8023AD) {
+					if (bond->params.mode == BOND_MODE_8023AD) {
 						bond_3ad_handle_link_change(slave, BOND_LINK_DOWN);
 					}
 
-					if ((bond_mode == BOND_MODE_TLB) ||
-					    (bond_mode == BOND_MODE_ALB)) {
+					if ((bond->params.mode == BOND_MODE_TLB) ||
+					    (bond->params.mode == BOND_MODE_ALB)) {
 						bond_alb_handle_link_change(bond, slave, BOND_LINK_DOWN);
 					}
 
@@ -2157,10 +2162,10 @@ static void bond_mii_monitor(struct net_
 					slave->link = BOND_LINK_UP;
 					slave->jiffies = jiffies;
 
-					if (bond_mode == BOND_MODE_8023AD) {
+					if (bond->params.mode == BOND_MODE_8023AD) {
 						/* prevent it from being the active one */
 						slave->state = BOND_STATE_BACKUP;
-					} else if (bond_mode != BOND_MODE_ACTIVEBACKUP) {
+					} else if (bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
 						/* make it immediately active */
 						slave->state = BOND_STATE_ACTIVE;
 					} else if (slave != bond->primary_slave) {
@@ -2175,12 +2180,12 @@ static void bond_mii_monitor(struct net_
 					       slave_dev->name);
 
 					/* notify ad that the link status has changed */
-					if (bond_mode == BOND_MODE_8023AD) {
+					if (bond->params.mode == BOND_MODE_8023AD) {
 						bond_3ad_handle_link_change(slave, BOND_LINK_UP);
 					}
 
-					if ((bond_mode == BOND_MODE_TLB) ||
-					    (bond_mode == BOND_MODE_ALB)) {
+					if ((bond->params.mode == BOND_MODE_TLB) ||
+					    (bond->params.mode == BOND_MODE_ALB)) {
 						bond_alb_handle_link_change(bond, slave, BOND_LINK_UP);
 					}
 
@@ -2202,7 +2207,7 @@ static void bond_mii_monitor(struct net_
 
 		bond_update_speed_duplex(slave);
 
-		if (bond_mode == BOND_MODE_8023AD) {
+		if (bond->params.mode == BOND_MODE_8023AD) {
 			if (old_speed != slave->speed) {
 				bond_3ad_adapter_speed_changed(slave);
 			}
@@ -2665,17 +2670,19 @@ static void bond_info_seq_stop(struct se
 	read_unlock(&dev_base_lock);
 }
 
-static void bond_info_show_master(struct seq_file *seq, struct bonding *bond)
+static void bond_info_show_master(struct seq_file *seq)
 {
+	struct bonding *bond = seq->private;
 	struct slave *curr;
 
 	read_lock(&bond->curr_slave_lock);
 	curr = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
 
-	seq_printf(seq, "Bonding Mode: %s\n", bond_mode_name());
+	seq_printf(seq, "Bonding Mode: %s\n",
+		   bond_mode_name(bond->params.mode));
 
-	if (USES_PRIMARY(bond_mode)) {
+	if (USES_PRIMARY(bond->params.mode)) {
 		if (curr) {
 			seq_printf(seq,
 				   "Currently Active Slave: %s\n",
@@ -2688,7 +2695,7 @@ static void bond_info_show_master(struct
 	seq_printf(seq, "Up Delay (ms): %d\n", updelay * miimon);
 	seq_printf(seq, "Down Delay (ms): %d\n", downdelay * miimon);
 
-	if (bond_mode == BOND_MODE_8023AD) {
+	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 
 		seq_puts(seq, "\n802.3ad info\n");
@@ -2720,6 +2727,8 @@ static void bond_info_show_master(struct
 
 static void bond_info_show_slave(struct seq_file *seq, const struct slave *slave)
 {
+	struct bonding *bond = seq->private;
+
 	seq_printf(seq, "\nSlave Interface: %s\n", slave->dev->name);
 	seq_printf(seq, "MII Status: %s\n",
 		   (slave->link == BOND_LINK_UP) ?  "up" : "down");
@@ -2737,7 +2746,7 @@ static void bond_info_show_slave(struct 
 			   slave->perm_hwaddr[5]);
 	}
 
-	if (bond_mode == BOND_MODE_8023AD) {
+	if (bond->params.mode == BOND_MODE_8023AD) {
 		const struct aggregator *agg
 			= SLAVE_AD_INFO(slave).port.aggregator;
 
@@ -2754,7 +2763,7 @@ static int bond_info_seq_show(struct seq
 {
 	if (v == SEQ_START_TOKEN) {
 		seq_printf(seq, "%s\n", version);
-		bond_info_show_master(seq, seq->private);
+		bond_info_show_master(seq);
 	} else {
 		bond_info_show_slave(seq, v);
 	}
@@ -3029,14 +3038,14 @@ static int bond_open(struct net_device *
 
 	bond->kill_timers = 0;
 
-	if ((bond_mode == BOND_MODE_TLB) ||
-	    (bond_mode == BOND_MODE_ALB)) {
+	if ((bond->params.mode == BOND_MODE_TLB) ||
+	    (bond->params.mode == BOND_MODE_ALB)) {
 		struct timer_list *alb_timer = &(BOND_ALB_INFO(bond).alb_timer);
 
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
 		 */
-		if (bond_alb_initialize(bond, (bond_mode == BOND_MODE_ALB))) {
+		if (bond_alb_initialize(bond, (bond->params.mode == BOND_MODE_ALB))) {
 			/* something went wrong - fail the open operation */
 			return -1;
 		}
@@ -3060,7 +3069,7 @@ static int bond_open(struct net_device *
 		init_timer(arp_timer);
 		arp_timer->expires  = jiffies + 1;
 		arp_timer->data     = (unsigned long)bond_dev;
-		if (bond_mode == BOND_MODE_ACTIVEBACKUP) {
+		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
 			arp_timer->function = (void *)&bond_activebackup_arp_mon;
 		} else {
 			arp_timer->function = (void *)&bond_loadbalance_arp_mon;
@@ -3068,7 +3077,7 @@ static int bond_open(struct net_device *
 		add_timer(arp_timer);
 	}
 
-	if (bond_mode == BOND_MODE_8023AD) {
+	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct timer_list *ad_timer = &(BOND_AD_INFO(bond).ad_timer);
 		init_timer(ad_timer);
 		ad_timer->expires  = jiffies + 1;
@@ -3091,7 +3100,7 @@ static int bond_close(struct net_device 
 
 	bond_mc_list_destroy(bond);
 
-	if (bond_mode == BOND_MODE_8023AD) {
+	if (bond->params.mode == BOND_MODE_8023AD) {
 		/* Unregister the receive of LACPDUs */
 		bond_unregister_lacpdu(bond);
 	}
@@ -3113,7 +3122,7 @@ static int bond_close(struct net_device 
 		del_timer_sync(&bond->arp_timer);
 	}
 
-	switch (bond_mode) {
+	switch (bond->params.mode) {
 	case BOND_MODE_8023AD:
 		del_timer_sync(&(BOND_AD_INFO(bond).ad_timer));
 		break;
@@ -3128,8 +3137,8 @@ static int bond_close(struct net_device 
 	/* Release the bonded slaves */
 	bond_release_all(bond_dev);
 
-	if ((bond_mode == BOND_MODE_TLB) ||
-	    (bond_mode == BOND_MODE_ALB)) {
+	if ((bond->params.mode == BOND_MODE_TLB) ||
+	    (bond->params.mode == BOND_MODE_ALB)) {
 		/* Must be called only after all
 		 * slaves have been released
 		 */
@@ -3309,11 +3318,7 @@ static int bond_do_ioctl(struct net_devi
 			break;
 		case BOND_CHANGE_ACTIVE_OLD:
 		case SIOCBONDCHANGEACTIVE:
-			if (USES_PRIMARY(bond_mode)) {
-				res = bond_ioctl_change_active(bond_dev, slave_dev);
-			} else {
-				res = -EINVAL;
-			}
+			res = bond_ioctl_change_active(bond_dev, slave_dev);
 			break;
 		default:
 			res = -EOPNOTSUPP;
@@ -3918,7 +3923,7 @@ static int bond_check_params(struct bond
 		if (bond_mode != BOND_MODE_8023AD) {
 			printk(KERN_INFO DRV_NAME
 			       ": lacp_rate param is irrelevant in mode %s\n",
-			       bond_mode_name());
+			       bond_mode_name(bond_mode));
 		} else {
 			lacp_fast = bond_parse_parm(lacp_rate, bond_lacp_tbl);
 			if (lacp_fast == -1) {
@@ -4119,7 +4124,7 @@ static int bond_check_params(struct bond
 		printk(KERN_WARNING DRV_NAME
 		       ": Warning: %s primary device specified but has no "
 		       "effect in %s mode\n",
-		       primary, bond_mode_name());
+		       primary, bond_mode_name(bond_mode));
 		primary = NULL;
 	}
 
