From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 1/10] [bonding 2.6] consolidate change_active operations
Date: Thu, 11 Sep 2003 17:37:24 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309111737.24606.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:11 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:12 2003
@@ -473,6 +473,11 @@ DRV_NAME ".c:v" DRV_VERSION " (" DRV_REL
 #define MAX_ARP_IP_TARGETS 16
 #endif
 
+#define USES_PRIMARY(mode) \
+		(((mode) == BOND_MODE_ACTIVEBACKUP) || \
+		 ((mode) == BOND_MODE_TLB) || \
+		 ((mode) == BOND_MODE_ALB))
+
 struct bond_parm_tbl {
 	char *modename;
 	int mode;
@@ -581,6 +586,9 @@ static int bond_enslave(struct net_devic
 static int bond_release(struct net_device *master, struct net_device *slave);
 static int bond_release_all(struct net_device *master);
 static int bond_sethwaddr(struct net_device *master, struct net_device *slave);
+static void change_active_interface(struct bonding *bond, struct slave *new);
+static void reselect_active_interface(struct bonding *bond);
+static struct slave *find_best_interface(struct bonding *bond);
 
 /* Caller must hold bond->ptrlock for write */
 static inline struct slave*
@@ -691,7 +699,7 @@ update_slave_cnt(bonding_t *bond, int in
  * belongs to <bond>. It returns <slave> in case it's needed.
  * Nothing is freed on return, structures are just unchained.
  * If the bond->current_slave pointer was pointing to <slave>,
- * it's replaced with bond->next, or NULL if not applicable.
+ * it should be changed by the calling function.
  *
  * bond->lock held for writing by caller.
  */
@@ -725,17 +733,6 @@ bond_detach_slave(bonding_t *bond, slave
 
 	update_slave_cnt(bond, -1);
 
-	/* no need to hold ptrlock since bond lock is
-	 * already held for writing
-	 */
-	if (slave == bond->current_slave) {
-		if ( bond->next != (slave_t *)bond) {  /* found one slave */
-			bond_assign_current_slave(bond, bond->next);
-		} else {
-			bond_assign_current_slave(bond, NULL);
-		}
-	}
-
 	return slave;
 }
 
@@ -1578,9 +1575,7 @@ static int bond_enslave(struct net_devic
 #endif
 			/* first slave or no active slave yet, and this link
 			   is OK, so make this interface the active one */
-			bond_assign_current_slave(bond, new_slave);
-			bond_set_slave_active_flags(new_slave);
-			bond_mc_update(bond, new_slave, NULL);
+			change_active_interface(bond, new_slave);
 		}
 		else {
 #ifdef BONDING_DEBUG
@@ -1630,7 +1625,7 @@ static int bond_enslave(struct net_devic
 			/* first slave or no active slave yet, and this link
 			 * is OK, so make this interface the active one
 			 */
-			bond_assign_current_slave(bond, new_slave);
+			change_active_interface(bond, new_slave);
 		}
 
 		/* if there is a primary slave, remember it */
@@ -1737,6 +1732,13 @@ static int bond_change_active(struct net
 		return -ENODEV;
 	}
 
+	/* Verify that master_dev is indeed the master of slave_dev */
+	if (!(slave_dev->flags & IFF_SLAVE) ||
+	    (slave_dev->master != master_dev)) {
+
+		return -EINVAL;
+	}
+
 	bond = (struct bonding *) master_dev->priv;
 	write_lock_bh(&bond->lock);
 	slave = (slave_t *)bond;
@@ -1761,16 +1763,7 @@ static int bond_change_active(struct net
 	    (oldactive != NULL)&&
 	    (newactive->link == BOND_LINK_UP)&&
 	    IS_UP(newactive->dev)) {
-		if (bond_mode == BOND_MODE_ACTIVEBACKUP) {
-			bond_set_slave_inactive_flags(oldactive);
-			bond_set_slave_active_flags(newactive);
-		}
-
-		bond_mc_update(bond, newactive, oldactive);
-		bond_assign_current_slave(bond, newactive);
-		printk("%s : activate %s(old : %s)\n",
-			master_dev->name, newactive->dev->name, 
-			oldactive->dev->name);
+		change_active_interface(bond, newactive);
 	} else {
 		ret = -EINVAL;
 	}
@@ -1778,47 +1771,26 @@ static int bond_change_active(struct net
 	return ret;
 }
 
-/* Choose a new valid interface from the pool, set it active
- * and make it the current slave. If no valid interface is
- * found, the oldest slave in BACK state is choosen and
- * activated. If none is found, it's considered as no
- * interfaces left so the current slave is set to NULL.
- * The result is a pointer to the current slave.
- *
- * Since this function sends messages tails through printk, the caller
- * must have started something like `printk(KERN_INFO "xxxx ");'.
+/**
+ * find_best_interface - select the best available slave to be the active one
+ * @bond: our bonding struct
  *
  * Warning: Caller must hold ptrlock for writing.
  */
-slave_t *change_active_interface(bonding_t *bond)
+static struct slave *find_best_interface(struct bonding *bond)
 {
-	slave_t *newslave, *oldslave;
-	slave_t *bestslave = NULL;
+	struct slave *newslave, *oldslave;
+	struct slave *bestslave = NULL;
 	int mintime;
 
 	newslave = oldslave = bond->current_slave;
 
 	if (newslave == NULL) { /* there were no active slaves left */
 		if (bond->next != (slave_t *)bond) {  /* found one slave */
-			newslave = bond_assign_current_slave(bond, bond->next);
+			newslave = bond->next;
 		} else {
-
-			printk (" but could not find any %s interface.\n",
-				(bond_mode == BOND_MODE_ACTIVEBACKUP) ? "backup":"other");
-			bond_assign_current_slave(bond, NULL);
 			return NULL; /* still no slave, return NULL */
 		}
-	} else if (bond_mode == BOND_MODE_ACTIVEBACKUP) {
-		/* make sure oldslave doesn't send arps - this could
-		 * cause a ping-pong effect between interfaces since they
-		 * would be able to tx arps - in active backup only one
-		 * slave should be able to tx arps, and that should be
-		 * the current_slave; the only exception is when all
-		 * slaves have gone down, then only one non-current slave can
-		 * send arps at a time; clearing oldslaves' mc list is handled
-		 * later in this function.
-		 */
-		bond_set_slave_inactive_flags(oldslave);
 	}
 
 	mintime = updelay;
@@ -1833,22 +1805,12 @@ slave_t *change_active_interface(bonding
 			newslave = bond->primary_slave;
 	}
 
+	/* remember where to stop iterating over the slaves */
+	oldslave = newslave;
+
 	do {
 		if (IS_UP(newslave->dev)) {
 			if (newslave->link == BOND_LINK_UP) {
-				/* this one is immediately usable */
-				if (bond_mode == BOND_MODE_ACTIVEBACKUP) {
-					bond_set_slave_active_flags(newslave);
-					bond_mc_update(bond, newslave, oldslave);
-					printk (" and making interface %s the active one.\n",
-						newslave->dev->name);
-				}
-				else {
-					printk (" and setting pointer to interface %s.\n",
-						newslave->dev->name);
-				}
-
-				bond_assign_current_slave(bond, newslave);
 				return newslave;
 			}
 			else if (newslave->link == BOND_LINK_BACK) {
@@ -1861,46 +1823,100 @@ slave_t *change_active_interface(bonding
 		}
 	} while ((newslave = newslave->next) != oldslave);
 
-	/* no usable backup found, we'll see if we at least got a link that was
-	   coming back for a long time, and could possibly already be usable.
-	*/
-
-	if (bestslave != NULL) {
-		/* early take-over. */
-		printk (" and making interface %s the active one %d ms earlier.\n",
-			bestslave->dev->name,
-			(updelay - bestslave->delay)*miimon);
-
-		bestslave->delay = 0;
-		bestslave->link = BOND_LINK_UP;
-		bestslave->jiffies = jiffies;
-		bond_set_slave_active_flags(bestslave);
-		bond_mc_update(bond, bestslave, oldslave);
-		bond_assign_current_slave(bond, bestslave);
-		return bestslave;
-	}
-
-	if ((bond_mode == BOND_MODE_ACTIVEBACKUP) &&
-	    (multicast_mode == BOND_MULTICAST_ACTIVE) &&
-	    (oldslave != NULL)) {
-		/* flush bonds (master's) mc_list from oldslave since it wasn't
-		 * updated (and deleted) above
-		 */ 
-		bond_mc_list_flush(oldslave->dev, bond->device); 
-		if (bond->device->flags & IFF_PROMISC) {
-			dev_set_promiscuity(oldslave->dev, -1);
+	return bestslave;
+}
+
+/**
+ * change_active_interface - change the active slave into the specified one
+ * @bond: our bonding struct
+ * @new: the new slave to make the active one
+ * 
+ * Set the new slave to the bond's settings and unset them on the old
+ * current_slave.
+ * Setting include flags, mc-list, promiscuity, allmulti, etc.
+ *
+ * If @new's link state is %BOND_LINK_BACK we'll set it to %BOND_LINK_UP,
+ * because it is apparently the best available slave we have, even though its
+ * updelay hasn't timed out yet.
+ *
+ * Warning: Caller must hold ptrlock for writing.
+ */
+static void change_active_interface(struct bonding *bond, struct slave *new)
+{
+	struct slave *old = bond->current_slave;
+
+	if (old == new) {
+		return;
+	}
+
+	if (new) {
+		if (new->link == BOND_LINK_BACK) {
+			if (USES_PRIMARY(bond_mode)) {
+				printk (KERN_INFO
+					"%s: making interface %s the new "
+					"active one %d ms earlier.\n",
+					bond->device->name, new->dev->name,
+					(updelay - new->delay) * miimon);
+			}
+
+			new->delay = 0;
+			new->link = BOND_LINK_UP;
+			new->jiffies = jiffies;
+
+			if (bond_mode == BOND_MODE_8023AD) {
+				bond_3ad_handle_link_change(new, BOND_LINK_UP);
+			}
+
+			if ((bond_mode == BOND_MODE_TLB) ||
+			    (bond_mode == BOND_MODE_ALB)) {
+				bond_alb_handle_link_change(bond, new, BOND_LINK_UP);
+			}
+		} else {
+			if (USES_PRIMARY(bond_mode)) {
+				printk (KERN_INFO
+					"%s: making interface %s the new active one.\n",
+					bond->device->name, new->dev->name);
+			}
 		}
-		if (bond->device->flags & IFF_ALLMULTI) {
-			dev_set_allmulti(oldslave->dev, -1);
+	}
+
+	if (bond_mode == BOND_MODE_ACTIVEBACKUP) {
+		if (old) {
+			bond_set_slave_inactive_flags(old);
+		}
+
+		if (new) {
+			bond_set_slave_active_flags(new);
 		}
 	}
 
-	printk (" but could not find any %s interface.\n",
-		(bond_mode == BOND_MODE_ACTIVEBACKUP) ? "backup":"other");
-	
-	/* absolutely nothing found. let's return NULL */
-	bond_assign_current_slave(bond, NULL);
-	return NULL;
+	if (USES_PRIMARY(bond_mode)) {
+		bond_mc_update(bond, new, old);
+	}
+
+	bond_assign_current_slave(bond, new);
+}
+
+/**
+ * reselect_active_interface - select a new active slave, if needed
+ * @bond: our bonding struct
+ *
+ * This functions shoud be called when one of the following occurs:
+ * - The old current_slave has been released or lost its link.
+ * - The primary_slave has got its link back.
+ * - A slave has got its link back and there's no old current_slave.
+ *
+ * Warning: Caller must hold ptrlock for writing.
+ */
+static void reselect_active_interface(struct bonding *bond)
+{
+	struct slave *best_slave;
+
+	best_slave = find_best_interface(bond);
+
+	if (best_slave != bond->current_slave) {
+		change_active_interface(bond, best_slave);
+	}
 }
 
 /*
@@ -1967,6 +1983,11 @@ static int bond_release(struct net_devic
 				bond_3ad_unbind_slave(our_slave);
 			}
 
+			printk (KERN_INFO "%s: releasing %s interface %s\n",
+				master->name,
+				(our_slave->state == BOND_STATE_ACTIVE) ? "active" : "backup",
+				slave->name);
+
 			/* release the slave from its bond */
 			bond_detach_slave(bond, our_slave);
 
@@ -1974,18 +1995,11 @@ static int bond_release(struct net_devic
 				bond->primary_slave = NULL;
 			}
 
-			printk (KERN_INFO "%s: releasing %s interface %s",
-				master->name,
-				(our_slave->state == BOND_STATE_ACTIVE) ? "active" : "backup",
-				slave->name);
-
-			if (our_slave == old_current) {
-				/* find a new interface and be verbose */
-				change_active_interface(bond); 
-			} else {
-				printk(".\n");
+			if (bond->current_slave == our_slave) {
+				change_active_interface(bond, NULL);
+				reselect_active_interface(bond);
 			}
-			
+
 			if (bond->current_slave == NULL) {
 				printk(KERN_INFO
 					"%s: now running without any active interface !\n",
@@ -2274,9 +2288,7 @@ static void bond_mii_monitor(struct net_
 					write_lock(&bond->ptrlock);
 					if (slave == bond->current_slave) {
 						/* find a new interface and be verbose */
-						change_active_interface(bond);
-					} else {
-						printk(".\n");
+						reselect_active_interface(bond);
 					}
 					write_unlock(&bond->ptrlock);
 					slave_died = 1;
@@ -2372,7 +2384,7 @@ static void bond_mii_monitor(struct net_
 					write_lock(&bond->ptrlock);
 					if ( (bond->primary_slave != NULL)
 					  && (slave == bond->primary_slave) )
-						change_active_interface(bond); 
+						reselect_active_interface(bond); 
 					write_unlock(&bond->ptrlock);
 				}
 				else
@@ -2418,40 +2430,8 @@ static void bond_mii_monitor(struct net_
 	/* no active interface at the moment or need to bring up the primary */
 	if (oldcurrent == NULL)  { /* no active interface at the moment */
 		if (bestslave != NULL) { /* last chance to find one ? */
-			if (bestslave->link == BOND_LINK_UP) {
-				printk (KERN_INFO
-					"%s: making interface %s the new active one.\n",
-					master->name, bestslave->dev->name);
-			} else {
-				printk (KERN_INFO
-					"%s: making interface %s the new "
-					"active one %d ms earlier.\n",
-					master->name, bestslave->dev->name,
-					(updelay - bestslave->delay) * miimon);
-
-				bestslave->delay = 0;
-				bestslave->link  = BOND_LINK_UP;
-				bestslave->jiffies = jiffies;
-
-				/* notify ad that the link status has changed */
-				if (bond_mode == BOND_MODE_8023AD) {
-					bond_3ad_handle_link_change(bestslave, BOND_LINK_UP);
-				}
-
-				if ((bond_mode == BOND_MODE_TLB) ||
-				    (bond_mode == BOND_MODE_ALB)) {
-					bond_alb_handle_link_change(bond, bestslave, BOND_LINK_UP);
-				}
-			}
-
-			if (bond_mode == BOND_MODE_ACTIVEBACKUP) {
-				bond_set_slave_active_flags(bestslave);
-				bond_mc_update(bond, bestslave, NULL);
-			} else if (bond_mode != BOND_MODE_8023AD) {
-				bestslave->state = BOND_STATE_ACTIVE;
-			}
 			write_lock(&bond->ptrlock);
-			bond_assign_current_slave(bond, bestslave);
+			change_active_interface(bond, bestslave);
 			write_unlock(&bond->ptrlock);
 		} else if (slave_died) {
 			/* print this message only once a slave has just died */
@@ -2535,7 +2515,7 @@ static void loadbalance_arp_monitor(stru
 						"for interface %s, ",
 						master->name,
 						slave->dev->name);
-					change_active_interface(bond); 
+					reselect_active_interface(bond); 
 				} else {
 					printk(KERN_INFO
 						"%s: interface %s is now up\n",
@@ -2567,7 +2547,7 @@ static void loadbalance_arp_monitor(stru
 
 				write_lock(&bond->ptrlock);
 				if (slave == bond->current_slave) {
-					change_active_interface(bond);
+					reselect_active_interface(bond);
 				}
 				write_unlock(&bond->ptrlock);
 			}
@@ -2645,9 +2625,7 @@ static void activebackup_arp_monitor(str
 				if ((bond->current_slave == NULL) &&
 				    ((jiffies - slave->dev->trans_start) <=
 				     the_delta_in_ticks)) {
-					bond_assign_current_slave(bond, slave);
-					bond_set_slave_active_flags(slave);
-			                bond_mc_update(bond, slave, NULL);
+					change_active_interface(bond, slave);
 					bond->current_arp_slave = NULL;
 				} else if (bond->current_slave != slave) {
 					/* this slave has just come up but we 
@@ -2737,7 +2715,8 @@ static void activebackup_arp_monitor(str
 			       master->name,
 			       slave->dev->name);
 			write_lock(&bond->ptrlock);
-			slave = change_active_interface(bond);
+			reselect_active_interface(bond);
+			slave = bond->current_slave;
 			write_unlock(&bond->ptrlock);
 			bond->current_arp_slave = slave;
 			if (slave != NULL) {
@@ -2756,13 +2735,10 @@ static void activebackup_arp_monitor(str
 			       bond->primary_slave->dev->name);
 			       
 			/* primary is up so switch to it */
-			bond_set_slave_inactive_flags(slave);
-			bond_mc_update(bond, bond->primary_slave, slave);
 			write_lock(&bond->ptrlock);
-			bond_assign_current_slave(bond, bond->primary_slave);
+			change_active_interface(bond, bond->primary_slave);
 			write_unlock(&bond->ptrlock);
 			slave = bond->primary_slave;
-			bond_set_slave_active_flags(slave);
 			slave->jiffies = jiffies;
 		} else {
 			bond->current_arp_slave = NULL;
@@ -2805,7 +2781,7 @@ static void activebackup_arp_monitor(str
 				/* if the link state is up at this point, we 
 				 * mark it down - this can happen if we have 
 				 * simultaneous link failures and 
-				 * change_active_interface doesn't make this 
+				 * reselect_active_interface doesn't make this 
 				 * one the current slave so it is still marked 
 				 * up when it is actually down
 				 */
@@ -3056,9 +3032,7 @@ static int bond_ioctl(struct net_device 
 			break;
 		case BOND_CHANGE_ACTIVE_OLD:
 		case SIOCBONDCHANGEACTIVE:
-			if ((bond_mode == BOND_MODE_ACTIVEBACKUP) ||
-			    (bond_mode == BOND_MODE_TLB) ||
-			    (bond_mode == BOND_MODE_ALB)) {
+			if (USES_PRIMARY(bond_mode)) {
 				ret = bond_change_active(master_dev, slave_dev);
 			}
 			else {
@@ -3388,9 +3362,7 @@ static int bond_read_proc(char *buf, cha
 	len += sprintf(buf + len, "Bonding Mode: %s\n",
 		       bond_mode_name());
 
-	if ((bond_mode == BOND_MODE_ACTIVEBACKUP) ||
-	    (bond_mode == BOND_MODE_TLB) ||
-	    (bond_mode == BOND_MODE_ALB)) {
+	if (USES_PRIMARY(bond_mode)) {
 		read_lock_bh(&bond->lock);
 		read_lock(&bond->ptrlock);
 		if (bond->current_slave != NULL) {
@@ -3905,9 +3877,7 @@ static int __init bonding_init(void)
 		       "link failures! see bonding.txt for details.\n");
 	}
 
-	if ((primary != NULL) && (bond_mode != BOND_MODE_ACTIVEBACKUP) &&
-	    (bond_mode != BOND_MODE_TLB) &&
-	    (bond_mode != BOND_MODE_ALB)){
+	if ((primary != NULL) && !USES_PRIMARY(bond_mode)) {
 		/* currently, using a primary only makes sense
 		 * in active backup, TLB or ALB modes
 		 */
