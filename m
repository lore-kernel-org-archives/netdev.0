From: shmulik.hen@intel.com
Subject: [bonding][patch] Change locking scheme
Date: Thu, 3 Apr 2003 17:38:37 +0300 (IDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0304031357180.317-100000@jrslxjul4.npdj.intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: bond-devel <bonding-devel@lists.sourceforge.net>,
   bond-announce <bonding-announce@lists.sourceforge.net>,
   linux-netdev <netdev@oss.sgi.com>, linux-net <linux-net@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch replaces the use of lock_irqsave/unlock_irqrestore in bonding
with lock/unlock or lock_bh/unlock_bh as appropriate according to context.  
This change is based on last week's discussion regarding the fact that
holding a lock_irqsave doesn't prevent softirqs from running which can
cause deadlocks in certain situations.

This version has undergone rigorous testing by our QA lab for the past
week or so, and so far problems were detected. It was tested in all
supported modes with heavy outgoing and incoming traffic stress using
various protocols, while performing continuous configuration changes, link
disconnections, getting/setting bond's parameters periodically with
ifconfig and polling status via proc file system. Performance data is 
available yet.

There is also a change to the versioning scheme as follows:
The driver version will be a number instead of the release date since this 
info is repeated in another field. The version number has 3 fields.
X - Major version - big behavior changes
Y - Minor version - addition of features
Z - Extra version - minor changes and bug fixes
The current version (1.0.6) is based on turning to 1.0.0 on 1/1/03 plus 6 
bug fixes.

Patch is against latest bonding drop from source forge (2.4.20-20030320).


diff -Nuarp linux-2.4.20-bonding-20030320/drivers/net/bonding.c linux-2.4.20-bonding-20030320-devel/drivers/net/bonding.c
--- linux-2.4.20-bonding-20030320/drivers/net/bonding.c	2003-04-01 17:38:31.000000000 +0300
+++ linux-2.4.20-bonding-20030320-devel/drivers/net/bonding.c	2003-04-01 17:38:31.000000000 +0300
@@ -278,7 +278,7 @@
  *	  bonding round-robin mode ignoring links after failover/recovery
  *
  * 2003/03/17 - Jay Vosburgh <fubar at us dot ibm dot com>
- *	- kmalloc fix (GPF_KERNEL to GPF_ATOMIC) reported by
+ *	- kmalloc fix (GFP_KERNEL to GFP_ATOMIC) reported by
  *	  Shmulik dot Hen at intel.com.
  *	- Based on discussion on mailing list, changed use of
  *	  update_slave_cnt(), created wrapper functions for adding/removing
@@ -292,13 +292,30 @@
  *	- Make sure only bond_attach_slave() and bond_detach_slave() can
  *	  manipulate the slave list, including slave_cnt, even when in
  *	  bond_release_all().
- *	- Fixed hang in bond_release() while traffic is running.
+ *	- Fixed hang in bond_release() while traffic is running:
  *	  netdev_set_master() must not be called from within the bond lock.
  *
  * 2003/03/18 - Tsippy Mendelson <tsippy.mendelson at intel dot com> and
  *		Shmulik Hen <shmulik.hen at intel dot com>
- *	- Fixed hang in bond_enslave(): netdev_set_master() must not be
- *	  called from within the bond lock while traffic is running.
+ *	- Fixed hang in bond_enslave() while traffic is running:
+ *	  netdev_set_master() must not be called from within the bond lock.
+ *
+ * 2003/04/01 - Shmulik Hen <shmulik.hen at intel dot com>
+ *	- Based on discussion on mailing list, changed locking scheme
+ *	  to use lock/unlock or lock_bh/unlock_bh appropriately instead
+ *	  of lock_irqsave/unlock_irqrestore. The new scheme helps exposing
+ *	  hidden bugs and solves system hangs that occurred due to the fact
+ *	  that holding lock_irqsave doesn't prevent softirqs from running.
+ *	  This also increases total throughput since interrupts are not
+ *	  blocked on each transmitted packets or monitor timeout.
+ *	- Changed driver versioning scheme to include version number instead
+ *	  of release date (that is already in another field). There are 3
+ *	  fields X.Y.Z where:
+ *		X - Major version - big behavior changes
+ *		Y - Minor version - addition of features
+ *		Z - Extra version - minor changes and bug fixes
+ *	  The current version (1.0.6) is based on turning to 1.0.0 on 1/1/03
+ *	  plus 6 bug fixes.
  */
 
 #include <linux/config.h>
@@ -339,8 +356,8 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 
-#define DRV_VERSION		"2.4.20-20030320"
-#define DRV_RELDATE		"March 20, 2003"
+#define DRV_VERSION		"1.0.6"
+#define DRV_RELDATE		"April 1, 2003"
 #define DRV_NAME		"bonding"
 #define DRV_DESCRIPTION		"Ethernet Channel Bonding Driver"
 
@@ -553,7 +570,7 @@ update_slave_cnt(bonding_t *bond, int in
  * If the bond->current_slave pointer was pointing to <slave>,
  * it's replaced with slave->next, or <bond> if not applicable.
  *
- * bond->lock held by caller.
+ * bond->lock held for writing by caller.
  */
 static slave_t *
 bond_detach_slave(bonding_t *bond, slave_t *slave)
@@ -568,20 +585,11 @@ bond_detach_slave(bonding_t *bond, slave
 
 	if (bond->next == slave) {  /* is the slave at the head ? */
 		if (bond->prev == slave) {  /* is the slave alone ? */
-			write_lock(&bond->ptrlock);
-			bond->current_slave = NULL; /* no slave anymore */
-			write_unlock(&bond->ptrlock);
 			bond->prev = bond->next = (slave_t *)bond;
 		} else { /* not alone */
 			bond->next        = slave->next;
 			slave->next->prev = (slave_t *)bond;
 			bond->prev->next  = slave->next;
-
-			write_lock(&bond->ptrlock);
-			if (bond->current_slave == slave) {
-				bond->current_slave = slave->next;
-			}
-			write_unlock(&bond->ptrlock);
 		}
 	} else {
 		slave->prev->next = slave->next;
@@ -590,19 +598,24 @@ bond_detach_slave(bonding_t *bond, slave
 		} else {
 			slave->next->prev = slave->prev;
 		}
-
-		write_lock(&bond->ptrlock);
-		if (bond->current_slave == slave) {
-			bond->current_slave = slave->next;
-		}
-		write_unlock(&bond->ptrlock);
 	}
 
 	update_slave_cnt(bond, -1);
 
+	if (bond->next != (slave_t *)bond) {  /* found one slave */
+		bond->current_slave = bond->next;
+	} else {
+		bond->current_slave = NULL;
+	}
+
 	return slave;
 }
 
+/* 
+ * This function attaches the slave <slave> to the list <bond>.
+ *
+ * bond->lock held for writing by caller.
+ */
 static void
 bond_attach_slave(struct bonding *bond, struct slave *new_slave)
 {
@@ -731,13 +744,12 @@ bond_check_dev_link(struct net_device *d
 static u16 bond_check_mii_link(bonding_t *bond)
 {
 	int has_active_interface = 0;
-	unsigned long flags;
 
-	read_lock_irqsave(&bond->lock, flags);
+	read_lock_bh(&bond->lock);
 	read_lock(&bond->ptrlock);
 	has_active_interface = (bond->current_slave != NULL);
 	read_unlock(&bond->ptrlock);
-	read_unlock_irqrestore(&bond->lock, flags);
+	read_unlock_bh(&bond->lock);
 
 	return (has_active_interface ? BMSR_LSTATUS : 0);
 }
@@ -773,9 +785,8 @@ static int bond_open(struct net_device *
 static int bond_close(struct net_device *master)
 {
 	bonding_t *bond = (struct bonding *) master->priv;
-	unsigned long flags;
 
-	write_lock_irqsave(&bond->lock, flags);
+	write_lock_bh(&bond->lock);
 
 	if (miimon > 0) {  /* link check interval, in milliseconds. */
 		del_timer(&bond->mii_timer);
@@ -788,11 +799,12 @@ static int bond_close(struct net_device 
 		}
 	}
 
-	/* Release the bonded slaves */
-	bond_release_all(master);
 	bond_mc_list_destroy (bond);
 
-	write_unlock_irqrestore(&bond->lock, flags);
+	write_unlock_bh(&bond->lock);
+
+	/* Release the bonded slaves */
+	bond_release_all(master);
 
 	MOD_DEC_USE_COUNT;
 	return 0;
@@ -963,14 +975,13 @@ static void set_multicast_list(struct ne
 {
 	bonding_t *bond = master->priv;
 	struct dev_mc_list *dmi;
-	unsigned long flags = 0;
 
 	if (multicast_mode == BOND_MULTICAST_DISABLED)
 		return;
 	/*
 	 * Lock the private data for the master
 	 */
-	write_lock_irqsave(&bond->lock, flags);
+	write_lock_bh(&bond->lock);
 
 	/* set promiscuity flag to slaves */
 	if ( (master->flags & IFF_PROMISC) && !(bond->flags & IFF_PROMISC) )
@@ -1005,7 +1016,7 @@ static void set_multicast_list(struct ne
 	bond_mc_list_destroy (bond);
 	bond_mc_list_copy (master->mc_list, bond, GFP_ATOMIC);
 
-	write_unlock_irqrestore(&bond->lock, flags);
+	write_unlock_bh(&bond->lock);
 }
 
 /*
@@ -1051,7 +1062,6 @@ static int bond_enslave(struct net_devic
 {
 	bonding_t *bond = NULL;
 	slave_t *new_slave = NULL;
-	unsigned long flags = 0;
 	unsigned long rflags = 0;
 	int ndx = 0;
 	int err = 0;
@@ -1087,7 +1097,7 @@ static int bond_enslave(struct net_devic
 		return -EBUSY;
 	}
 		   
-	if ((new_slave = kmalloc(sizeof(slave_t), GFP_ATOMIC)) == NULL) {
+	if ((new_slave = kmalloc(sizeof(slave_t), GFP_KERNEL)) == NULL) {
 		return -ENOMEM;
 	}
 	memset(new_slave, 0, sizeof(slave_t));
@@ -1119,7 +1129,7 @@ static int bond_enslave(struct net_devic
 			dev_mc_add (slave_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 	}
 
-	write_lock_irqsave(&bond->lock, flags);
+	write_lock_bh(&bond->lock);
 	
 	bond_attach_slave(bond, new_slave);
 	new_slave->delay = 0;
@@ -1206,9 +1216,11 @@ static int bond_enslave(struct net_devic
 		read_unlock_irqrestore(&(((struct in_device *)slave_dev->ip_ptr)->lock), rflags);
 
 		/* if there is a primary slave, remember it */
-		if (primary != NULL)
-		  if( strcmp(primary, new_slave->dev->name) == 0) 
-			bond->primary_slave = new_slave;
+		if (primary != NULL) {
+			if (strcmp(primary, new_slave->dev->name) == 0) {
+				bond->primary_slave = new_slave;
+			}
+		}
 	} else {
 #ifdef BONDING_DEBUG
 		printk(KERN_CRIT "This slave is always active in trunk mode\n");
@@ -1219,7 +1231,7 @@ static int bond_enslave(struct net_devic
 			bond->current_slave = new_slave;
 	}
 
-	write_unlock_irqrestore(&bond->lock, flags);
+	write_unlock_bh(&bond->lock);
 
 	/*
 	 * !!! This is to support old versions of ifenslave.  We can remove
@@ -1283,7 +1295,6 @@ static int bond_change_active(struct net
 	slave_t *slave;
 	slave_t *oldactive = NULL;
 	slave_t *newactive = NULL;
-	unsigned long flags;
 	int ret = 0;
 
 	if (master_dev == NULL || slave_dev == NULL) {
@@ -1291,7 +1302,7 @@ static int bond_change_active(struct net
 	}
 
 	bond = (struct bonding *) master_dev->priv;
-	write_lock_irqsave(&bond->lock, flags);
+	write_lock_bh(&bond->lock);
 	slave = (slave_t *)bond;
 	oldactive = bond->current_slave;
 
@@ -1318,7 +1329,7 @@ static int bond_change_active(struct net
 	else {
 		ret = -EINVAL;
 	}
-	write_unlock_irqrestore(&bond->lock, flags);
+	write_unlock_bh(&bond->lock);
 	return ret;
 }
 
@@ -1332,7 +1343,7 @@ static int bond_change_active(struct net
  * Since this function sends messages tails through printk, the caller
  * must have started something like `printk(KERN_INFO "xxxx ");'.
  *
- * Warning: must put locks around the call to this function if needed.
+ * Warning: Caller must hold ptrlock for writing.
  */
 slave_t *change_active_interface(bonding_t *bond)
 {
@@ -1340,22 +1351,16 @@ slave_t *change_active_interface(bonding
 	slave_t *bestslave = NULL;
 	int mintime;
 
-	read_lock(&bond->ptrlock);
 	newslave = oldslave = bond->current_slave;
-	read_unlock(&bond->ptrlock);
 
 	if (newslave == NULL) { /* there were no active slaves left */
 		if (bond->next != (slave_t *)bond) {  /* found one slave */
-			write_lock(&bond->ptrlock);
 			newslave = bond->current_slave = bond->next;
-			write_unlock(&bond->ptrlock);
 		} else {
 
 			printk (" but could not find any %s interface.\n",
 				(bond_mode == BOND_MODE_ACTIVEBACKUP) ? "backup":"other");
-			write_lock(&bond->ptrlock);
 			bond->current_slave = (slave_t *)NULL;
-			write_unlock(&bond->ptrlock);
 			return NULL; /* still no slave, return NULL */
 		}
 	} else if (bond_mode == BOND_MODE_ACTIVEBACKUP) {
@@ -1398,9 +1403,7 @@ slave_t *change_active_interface(bonding
 						newslave->dev->name);
 				}
 
-				write_lock(&bond->ptrlock);
 				bond->current_slave = newslave;
-				write_unlock(&bond->ptrlock);
 				return newslave;
 			}
 			else if (newslave->link == BOND_LINK_BACK) {
@@ -1428,9 +1431,7 @@ slave_t *change_active_interface(bonding
 		bestslave->jiffies = jiffies;
 		bond_set_slave_active_flags(bestslave);
 		bond_mc_update(bond, bestslave, oldslave);
-		write_lock(&bond->ptrlock);
 		bond->current_slave = bestslave;
-		write_unlock(&bond->ptrlock);
 		return bestslave;
 	}
 
@@ -1453,9 +1454,7 @@ slave_t *change_active_interface(bonding
 		(bond_mode == BOND_MODE_ACTIVEBACKUP) ? "backup":"other");
 	
 	/* absolutely nothing found. let's return NULL */
-	write_lock(&bond->ptrlock);
 	bond->current_slave = (slave_t *)NULL;
-	write_unlock(&bond->ptrlock);
 	return NULL;
 }
 
@@ -1474,7 +1473,6 @@ static int bond_release(struct net_devic
 {
 	bonding_t *bond;
 	slave_t *our_slave, *old_current;
-	unsigned long flags;
 	
 	if (master == NULL || slave == NULL)  {
 		return -ENODEV;
@@ -1489,7 +1487,7 @@ static int bond_release(struct net_devic
 		return -EINVAL;
 	}
 
-	write_lock_irqsave(&bond->lock, flags);
+	write_lock_bh(&bond->lock);
 	bond->current_arp_slave = NULL;
 	our_slave = (slave_t *)bond;
 	old_current = bond->current_slave;
@@ -1523,7 +1521,7 @@ static int bond_release(struct net_devic
 		}
 
 	}
-	write_unlock_irqrestore(&bond->lock, flags);
+	write_unlock_bh(&bond->lock);
 	
 	if (our_slave == (slave_t *)bond) {
 		/* if we get here, it's because the device was not found */
@@ -1568,13 +1566,13 @@ static int bond_release(struct net_devic
 
 /* 
  * This function releases all slaves.
- * Warning: must put write-locks around the call to this function.
  */
 static int bond_release_all(struct net_device *master)
 {
 	bonding_t *bond;
-	slave_t *our_slave;
+	slave_t *our_slave, *old_current;
 	struct net_device *slave_dev;
+	int err = 0;
 
 	if (master == NULL)  {
 		return -ENODEV;
@@ -1585,25 +1583,39 @@ static int bond_release_all(struct net_d
 	}
 
 	bond = (struct bonding *) master->priv;
-	bond->current_arp_slave = NULL;
+
+	write_lock_bh(&bond->lock);
+	if (bond->next == (struct slave *) bond) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	old_current = bond->current_slave;
 	bond->current_slave = NULL;
+	bond->current_arp_slave = NULL;
 	bond->primary_slave = NULL;
 
 	while ((our_slave = bond->prev) != (slave_t *)bond) {
 		slave_dev = our_slave->dev;
 		bond_detach_slave(bond, our_slave);
 
+		/* now that the slave is detached, unlock and perform
+		 * all the undo steps that should not be called from
+		 * within a lock.
+		 */
+		write_unlock_bh(&bond->lock);
+
 		if (multicast_mode == BOND_MULTICAST_ALL 
 		    || (multicast_mode == BOND_MULTICAST_ACTIVE 
-			&& bond->current_slave == our_slave)) {
+			&& old_current == our_slave)) {
 
 			/* flush master's mc_list from slave */ 
 			bond_mc_list_flush (slave_dev, master); 
-			
+
 			/* unset promiscuity level from slave */
 			if (master->flags & IFF_PROMISC) 
 				dev_set_promiscuity(slave_dev, -1); 
-			
+
 			/* unset allmulti level from slave */ 
 			if (master->flags & IFF_ALLMULTI)
 				dev_set_allmulti(slave_dev, -1); 
@@ -1611,10 +1623,6 @@ static int bond_release_all(struct net_d
 
 		kfree(our_slave);
 
-		/*
-		 * Can be safely called from inside the bond lock
-		 * since traffic and timers have already stopped
-		 */
 		netdev_set_master(slave_dev, NULL);
 
 		/* only restore its RUNNING flag if monitoring set it down */
@@ -1623,11 +1631,17 @@ static int bond_release_all(struct net_d
 
 		if (slave_dev->flags & IFF_NOARP)
 			dev_close(slave_dev);
+
+		/* re-acquire the lock before getting the next slave */
+		write_lock_bh(&bond->lock);
 	}
 
 	printk (KERN_INFO "%s: released all slaves\n", master->name);
 
-	return 0;
+out:
+	write_unlock_bh(&bond->lock);
+
+	return err;
 }
 
 /* this function is called regularly to monitor each slave's link. */
@@ -1635,10 +1649,9 @@ static void bond_mii_monitor(struct net_
 {
 	bonding_t *bond = (struct bonding *) master->priv;
 	slave_t *slave, *bestslave, *oldcurrent;
-	unsigned long flags;
 	int slave_died = 0;
 
-	read_lock_irqsave(&bond->lock, flags);
+	read_lock(&bond->lock);
 
 	/* we will try to read the link status of each of our slaves, and
 	 * set their IFF_RUNNING flag appropriately. For each slave not
@@ -1715,15 +1728,14 @@ static void bond_mii_monitor(struct net_
 						master->name,
 						dev->name);
 
-					read_lock(&bond->ptrlock);
+					write_lock(&bond->ptrlock);
 					if (slave == bond->current_slave) {
-						read_unlock(&bond->ptrlock);
 						/* find a new interface and be verbose */
 						change_active_interface(bond);
 					} else {
-						read_unlock(&bond->ptrlock);
 						printk(".\n");
 					}
+					write_unlock(&bond->ptrlock);
 					slave_died = 1;
 				} else {
 					slave->delay--;
@@ -1800,9 +1812,11 @@ static void bond_mii_monitor(struct net_
 						master->name,
 						dev->name);
 	
+					write_lock(&bond->ptrlock);
 					if ( (bond->primary_slave != NULL)	 
 					  && (slave == bond->primary_slave) )
 						change_active_interface(bond); 
+					write_unlock(&bond->ptrlock);
 				}
 				else
 					slave->delay--;
@@ -1868,7 +1882,7 @@ static void bond_mii_monitor(struct net_
 		}
 	}
 
-	read_unlock_irqrestore(&bond->lock, flags);
+	read_unlock(&bond->lock);
 	/* re-arm the timer */
 	mod_timer(&bond->mii_timer, jiffies + (miimon * HZ / 1000));
 }
@@ -1883,7 +1897,6 @@ static void bond_mii_monitor(struct net_
 static void loadbalance_arp_monitor(struct net_device *master)
 {
 	bonding_t *bond;
-	unsigned long flags;
 	slave_t *slave;
 	int the_delta_in_ticks =  arp_interval * HZ / 1000;
 	int next_timer = jiffies + (arp_interval * HZ / 1000);
@@ -1894,24 +1907,22 @@ static void loadbalance_arp_monitor(stru
 		return;
 	}
 
-	read_lock_irqsave(&bond->lock, flags);
-
 	/* TODO: investigate why rtnl_shlock_nowait and rtnl_exlock_nowait
 	 * are called below and add comment why they are required... 
 	 */
 	if ((!IS_UP(master)) || rtnl_shlock_nowait()) {
 		mod_timer(&bond->arp_timer, next_timer);
-		read_unlock_irqrestore(&bond->lock, flags);
 		return;
 	}
 
 	if (rtnl_exlock_nowait()) {
 		rtnl_shunlock();
 		mod_timer(&bond->arp_timer, next_timer);
-		read_unlock_irqrestore(&bond->lock, flags);
 		return;
 	}
 
+	read_lock(&bond->lock);
+
 	/* see if any of the previous devices are up now (i.e. they have
 	 * xmt and rcv traffic). the current_slave does not come into
 	 * the picture unless it is null. also, slave->jiffies is not needed
@@ -1938,9 +1949,8 @@ static void loadbalance_arp_monitor(stru
 				 * current_slave being null after enslaving
 				 * is closed.
 				 */
-				read_lock(&bond->ptrlock);
+				write_lock(&bond->ptrlock);
 				if (bond->current_slave == NULL) {
-					read_unlock(&bond->ptrlock);
 					printk(KERN_INFO
 						"%s: link status definitely up "
 						"for interface %s, ",
@@ -1948,12 +1958,12 @@ static void loadbalance_arp_monitor(stru
 						slave->dev->name);
 					change_active_interface(bond); 
 				} else {
-					read_unlock(&bond->ptrlock);
 					printk(KERN_INFO
 						"%s: interface %s is now up\n",
 						master->name,
 						slave->dev->name);
 				}
+				write_unlock(&bond->ptrlock);
 			} 
 		} else {
 			/* slave->link == BOND_LINK_UP */
@@ -1976,13 +1986,11 @@ static void loadbalance_arp_monitor(stru
 				       master->name,
 				       slave->dev->name);
 
-				read_lock(&bond->ptrlock);
+				write_lock(&bond->ptrlock);
 				if (slave == bond->current_slave) {
-					read_unlock(&bond->ptrlock);
 					change_active_interface(bond);
-				} else {
-					read_unlock(&bond->ptrlock);
 				}
+				write_unlock(&bond->ptrlock);
 			}
 		} 
 
@@ -1998,9 +2006,9 @@ static void loadbalance_arp_monitor(stru
 		}
 	}
 
+	read_unlock(&bond->lock);
 	rtnl_exunlock();
 	rtnl_shunlock();
-	read_unlock_irqrestore(&bond->lock, flags);
 
 	/* re-arm the timer */
 	mod_timer(&bond->arp_timer, next_timer);
@@ -2024,7 +2032,6 @@ static void loadbalance_arp_monitor(stru
 static void activebackup_arp_monitor(struct net_device *master)
 {
 	bonding_t *bond;
-	unsigned long flags;
 	slave_t *slave;
 	int the_delta_in_ticks =  arp_interval * HZ / 1000;
 	int next_timer = jiffies + (arp_interval * HZ / 1000);
@@ -2035,14 +2042,13 @@ static void activebackup_arp_monitor(str
 		return;
 	}
 
-	read_lock_irqsave(&bond->lock, flags);
-
 	if (!IS_UP(master)) {
 		mod_timer(&bond->arp_timer, next_timer);
-	        read_unlock_irqrestore(&bond->lock, flags);
 		return;
 	}
 
+	read_lock(&bond->lock);
+
 	/* determine if any slave has come up or any backup slave has 
 	 * gone down 
 	 * TODO: what about up/down delay in arp mode? it wasn't here before
@@ -2151,7 +2157,9 @@ static void activebackup_arp_monitor(str
 					 "active interface %s, disabling it",
 			       master->name,
 			       slave->dev->name);
+			write_lock(&bond->ptrlock);
 			slave = change_active_interface(bond);
+			write_unlock(&bond->ptrlock);
 			bond->current_arp_slave = slave;
 			if (slave != NULL) {
 				slave->jiffies = jiffies;
@@ -2243,8 +2251,8 @@ static void activebackup_arp_monitor(str
 		}
 	}
 
+	read_unlock(&bond->lock);
 	mod_timer(&bond->arp_timer, next_timer);
-	read_unlock_irqrestore(&bond->lock, flags);
 }
 
 typedef uint32_t in_addr_t;
@@ -2340,17 +2348,16 @@ static int bond_info_query(struct net_de
 {
 	bonding_t *bond = (struct bonding *) master->priv;
 	slave_t *slave;
-	unsigned long flags;
 
 	info->bond_mode = bond_mode;
 	info->num_slaves = 0;
 	info->miimon = miimon;
 
-	read_lock_irqsave(&bond->lock, flags);
+	read_lock_bh(&bond->lock);
 	for (slave = bond->prev; slave != (slave_t *)bond; slave = slave->prev) {
 		info->num_slaves++;
 	}
-	read_unlock_irqrestore(&bond->lock, flags);
+	read_unlock_bh(&bond->lock);
 
 	return 0;
 }
@@ -2361,19 +2368,18 @@ static int bond_slave_info_query(struct 
 	bonding_t *bond = (struct bonding *) master->priv;
 	slave_t *slave;
 	int cur_ndx = 0;
-	unsigned long flags;
 
 	if (info->slave_id < 0) {
 		return -ENODEV;
 	}
 
-	read_lock_irqsave(&bond->lock, flags);
+	read_lock_bh(&bond->lock);
 	for (slave = bond->prev; 
 		 slave != (slave_t *)bond && cur_ndx < info->slave_id; 
 		 slave = slave->prev) {
 		cur_ndx++;
 	}
-	read_unlock_irqrestore(&bond->lock, flags);
+	read_unlock_bh(&bond->lock);
 
 	if (slave != (slave_t *)bond) {
 		strcpy(info->slave_name, slave->dev->name);
@@ -2508,7 +2514,6 @@ static int bond_xmit_broadcast(struct sk
 {
 	slave_t *slave, *start_at;
 	struct bonding *bond = (struct bonding *) dev->priv;
-	unsigned long flags;
 	struct net_device *device_we_should_send_to = 0;
 
 	if (!IS_UP(dev)) { /* bond down */
@@ -2516,7 +2521,7 @@ static int bond_xmit_broadcast(struct sk
 		return 0;
 	}
 
-	read_lock_irqsave(&bond->lock, flags);
+	read_lock(&bond->lock);
 
 	read_lock(&bond->ptrlock);
 	slave = start_at = bond->current_slave;
@@ -2524,7 +2529,7 @@ static int bond_xmit_broadcast(struct sk
 
 	if (slave == NULL) { /* we're at the root, get the first slave */
 		/* no suitable interface, frame not sent */
-		read_unlock_irqrestore(&bond->lock, flags);
+		read_unlock(&bond->lock);
 		dev_kfree_skb(skb);
 		return 0;
 	}
@@ -2556,7 +2561,7 @@ static int bond_xmit_broadcast(struct sk
 		dev_kfree_skb(skb);
 
 	/* frame sent to all suitable interfaces */
-	read_unlock_irqrestore(&bond->lock, flags);
+	read_unlock(&bond->lock);
 	return 0;
 }
 
@@ -2564,14 +2569,13 @@ static int bond_xmit_roundrobin(struct s
 {
 	slave_t *slave, *start_at;
 	struct bonding *bond = (struct bonding *) dev->priv;
-	unsigned long flags;
 
 	if (!IS_UP(dev)) { /* bond down */
 		dev_kfree_skb(skb);
 		return 0;
 	}
 
-	read_lock_irqsave(&bond->lock, flags);
+	read_lock(&bond->lock);
 
 	read_lock(&bond->ptrlock);
 	slave = start_at = bond->current_slave;
@@ -2580,7 +2584,7 @@ static int bond_xmit_roundrobin(struct s
 	if (slave == NULL) { /* we're at the root, get the first slave */
 		/* no suitable interface, frame not sent */
 		dev_kfree_skb(skb);
-		read_unlock_irqrestore(&bond->lock, flags);
+		read_unlock(&bond->lock);
 		return 0;
 	}
 
@@ -2597,14 +2601,14 @@ static int bond_xmit_roundrobin(struct s
 			bond->current_slave = slave->next;
 			write_unlock(&bond->ptrlock);
 
-			read_unlock_irqrestore(&bond->lock, flags);
+			read_unlock(&bond->lock);
 			return 0;
 		}
 	} while ((slave = slave->next) != start_at);
 
 	/* no suitable interface, frame not sent */
 	dev_kfree_skb(skb);
-	read_unlock_irqrestore(&bond->lock, flags);
+	read_unlock(&bond->lock);
 	return 0;
 }
 
@@ -2617,7 +2621,6 @@ static int bond_xmit_xor(struct sk_buff 
 {
 	slave_t *slave, *start_at;
 	struct bonding *bond = (struct bonding *) dev->priv;
-	unsigned long flags;
 	struct ethhdr *data = (struct ethhdr *)skb->data;
 	int slave_no;
 
@@ -2626,14 +2629,14 @@ static int bond_xmit_xor(struct sk_buff 
 		return 0;
 	}
 
-	read_lock_irqsave(&bond->lock, flags);
+	read_lock(&bond->lock);
 	slave = bond->prev;
 
 	/* we're at the root, get the first slave */
 	if (bond->slave_cnt == 0) {
 		/* no suitable interface, frame not sent */
 		dev_kfree_skb(skb);
-		read_unlock_irqrestore(&bond->lock, flags);
+		read_unlock(&bond->lock);
 		return 0;
 	}
 
@@ -2654,14 +2657,14 @@ static int bond_xmit_xor(struct sk_buff 
 			skb->priority = 1;
 			dev_queue_xmit(skb);
 
-			read_unlock_irqrestore(&bond->lock, flags);
+			read_unlock(&bond->lock);
 			return 0;
 		}
 	} while ((slave = slave->next) != start_at);
 
 	/* no suitable interface, frame not sent */
 	dev_kfree_skb(skb);
-	read_unlock_irqrestore(&bond->lock, flags);
+	read_unlock(&bond->lock);
 	return 0;
 }
 
@@ -2672,7 +2675,6 @@ static int bond_xmit_xor(struct sk_buff 
 static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bonding *bond = (struct bonding *) dev->priv;
-	unsigned long flags;
 	int ret;
 
 	if (!IS_UP(dev)) { /* bond down */
@@ -2713,7 +2715,7 @@ static int bond_xmit_activebackup(struct
 		}
 	}
 
-	read_lock_irqsave(&bond->lock, flags);
+	read_lock(&bond->lock);
 
 	read_lock(&bond->ptrlock);
 	if (bond->current_slave != NULL) { /* one usable interface */
@@ -2721,7 +2723,7 @@ static int bond_xmit_activebackup(struct
 		read_unlock(&bond->ptrlock);
 		skb->priority = 1;
 		ret = dev_queue_xmit(skb);
-		read_unlock_irqrestore(&bond->lock, flags);
+		read_unlock(&bond->lock);
 		return 0;
 	}
 	else {
@@ -2733,7 +2735,7 @@ static int bond_xmit_activebackup(struct
 	printk(KERN_INFO "There was no suitable interface, so we don't transmit\n");
 #endif
 	dev_kfree_skb(skb);
-	read_unlock_irqrestore(&bond->lock, flags);
+	read_unlock(&bond->lock);
 	return 0;
 }
 
@@ -2742,11 +2744,10 @@ static struct net_device_stats *bond_get
 	bonding_t *bond = dev->priv;
 	struct net_device_stats *stats = bond->stats, *sstats;
 	slave_t *slave;
-	unsigned long flags;
 
 	memset(bond->stats, 0, sizeof(struct net_device_stats));
 
-	read_lock_irqsave(&bond->lock, flags);
+	read_lock_bh(&bond->lock);
 
 	for (slave = bond->prev; slave != (slave_t *)bond; slave = slave->prev) {
 		sstats = slave->dev->get_stats(slave->dev);
@@ -2779,7 +2780,7 @@ static struct net_device_stats *bond_get
 
 	}
 
-	read_unlock_irqrestore(&bond->lock, flags);
+	read_unlock_bh(&bond->lock);
 	return stats;
 }
 
@@ -2790,7 +2791,6 @@ static int bond_get_info(char *buf, char
 	off_t begin = 0;
 	u16 link;
 	slave_t *slave = NULL;
-	unsigned long flags;
 
 	while (bond != NULL) {
 		/*
@@ -2803,7 +2803,7 @@ static int bond_get_info(char *buf, char
 			       bond_mode_name());
 
 		if (bond_mode == BOND_MODE_ACTIVEBACKUP) {
-			read_lock_irqsave(&bond->lock, flags);
+			read_lock_bh(&bond->lock);
 			read_lock(&bond->ptrlock);
 			if (bond->current_slave != NULL) {
 				len += sprintf(buf + len, 
@@ -2811,7 +2811,7 @@ static int bond_get_info(char *buf, char
 					bond->current_slave->dev->name);
 			}
 			read_unlock(&bond->ptrlock);
-			read_unlock_irqrestore(&bond->lock, flags);
+			read_unlock_bh(&bond->lock);
 		}
 
 		len += sprintf(buf + len, "MII Status: ");
@@ -2826,7 +2826,7 @@ static int bond_get_info(char *buf, char
 		len += sprintf(buf + len, "Multicast Mode: %s\n",
 			       multicast_mode_name());
 
-		read_lock_irqsave(&bond->lock, flags);
+		read_lock_bh(&bond->lock);
 		for (slave = bond->prev; slave != (slave_t *)bond; 
 		     slave = slave->prev) {
 			len += sprintf(buf + len, "\nSlave Interface: %s\n", slave->dev->name);
@@ -2839,7 +2839,7 @@ static int bond_get_info(char *buf, char
 			len += sprintf(buf + len, "Link Failure Count: %d\n", 
 				slave->link_failure_count);
 		}
-		read_unlock_irqrestore(&bond->lock, flags);
+		read_unlock_bh(&bond->lock);
 
 		/*
 		 * Figure out the calcs for the /proc/net interface
@@ -3239,7 +3239,7 @@ static int __init bonding_init(void)
 		 */
 		printk(KERN_WARNING 
 		       "bonding_init(): %s primary device specified but has "
-		       " no effect in %s mode\n",
+		       "no effect in %s mode\n",
 		       primary, bond_mode_name());
 		primary = NULL;
 	}

-- 
| Shmulik Hen                             |
| Israel Design Center (Jerusalem)        |
| LAN Access Division                     |
| Intel Communications Group, Intel corp. |
