From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/6] bonding: event driven carrier detection
Date: Fri, 17 Oct 2008 21:32:55 -0700
Message-ID: <20081018043323.557029112@vyatta.com>
References: <20081018043252.968940967@vyatta.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vousburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52214 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbYJREfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 00:35:55 -0400
Content-Disposition: inline; filename=bonding-carrier-notify.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than polling for carrier status changes, use existing netlink
notifier infrastracture to detect changes. This is enabled by leaving
mii_mon=0.  No matter what the detection method, if admin takes slave 
interface down, it should go down ASAP.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bonding/bond_main.c	2008-10-17 15:45:14.000000000 -0700
+++ b/drivers/net/bonding/bond_main.c	2008-10-17 16:50:37.000000000 -0700
@@ -1640,8 +1640,7 @@ int bond_enslave(struct net_device *bond
 	}
 
 	/* check for initial state */
-	if (!bond->params.miimon ||
-	    (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS)) {
+	if (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS) {
 		if (bond->params.updelay) {
 			dprintk("Initial state of slave_dev is "
 				"BOND_LINK_BACK\n");
@@ -3510,31 +3509,67 @@ static int bond_master_netdev_event(unsi
 	return NOTIFY_DONE;
 }
 
+static void bond_slave_down(struct bonding *bond, struct net_device *slave_dev)
+{
+	struct slave *slave = bond_get_slave_by_dev(bond, slave_dev);
+
+	if (slave && slave->link != BOND_LINK_DOWN) {
+		slave->link = BOND_LINK_DOWN;
+		read_lock(&bond->lock);
+		bond_miimon_commit(bond);
+		read_unlock(&bond->lock);
+	}
+}
+
+static void bond_slave_up(struct bonding *bond, struct net_device *slave_dev)
+{
+	struct slave *slave = bond_get_slave_by_dev(bond, slave_dev);
+
+	if (slave && slave->link == BOND_LINK_DOWN) {
+		if (bond->params.updelay) {
+			slave->link  = BOND_LINK_BACK;
+			slave->delay = bond->params.updelay;
+		} else
+			slave->link  = BOND_LINK_UP;
+
+		read_lock(&bond->lock);
+		bond_miimon_commit(bond);
+		read_unlock(&bond->lock);
+	}
+}
+
 static int bond_slave_netdev_event(unsigned long event, struct net_device *slave_dev)
 {
 	struct net_device *bond_dev = slave_dev->master;
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond;
+
+	if (!bond_dev)
+		goto out;
+
+	bond = bond_dev->priv;
 
 	switch (event) {
 	case NETDEV_UNREGISTER:
-		if (bond_dev) {
-			if (bond->setup_by_slave)
-				bond_release_and_destroy(bond_dev, slave_dev);
-			else
-				bond_release(bond_dev, slave_dev);
-		}
-		break;
-	case NETDEV_CHANGE:
-		/*
-		 * TODO: is this what we get if somebody
-		 * sets up a hierarchical bond, then rmmod's
-		 * one of the slave bonding devices?
-		 */
+		if (bond->setup_by_slave)
+			bond_release_and_destroy(bond_dev, slave_dev);
+		else
+			bond_release(bond_dev, slave_dev);
 		break;
 	case NETDEV_DOWN:
-		/*
-		 * ... Or is it this?
-		 */
+		bond_slave_down(bond, slave_dev);
+		break;
+	case NETDEV_UP:
+	case NETDEV_CHANGE:
+		if (bond->params.use_carrier && !bond->params.miimon) {
+			dprintk("%s: status change %s\n",
+				slave_dev->name,
+				IS_UP(slave_dev) ? "up" : "down");
+
+			if (IS_UP(slave_dev))
+				bond_slave_up(bond, slave_dev);
+			else
+				bond_slave_down(bond, slave_dev);
+		}
 		break;
 	case NETDEV_CHANGEMTU:
 		/*
@@ -3558,10 +3593,9 @@ static int bond_slave_netdev_event(unsig
 	case NETDEV_FEAT_CHANGE:
 		bond_compute_features(bond);
 		break;
-	default:
-		break;
 	}
 
+out:
 	return NOTIFY_DONE;
 }
 
@@ -4788,33 +4822,6 @@ static int bond_check_params(struct bond
 		num_grat_arp = 1;
 	}
 
-	/* reset values for 802.3ad */
-	if (bond_mode == BOND_MODE_8023AD) {
-		if (!miimon) {
-			printk(KERN_WARNING DRV_NAME
-			       ": Warning: miimon must be specified, "
-			       "otherwise bonding will not detect link "
-			       "failure, speed and duplex which are "
-			       "essential for 802.3ad operation\n");
-			printk(KERN_WARNING "Forcing miimon to 100msec\n");
-			miimon = 100;
-		}
-	}
-
-	/* reset values for TLB/ALB */
-	if ((bond_mode == BOND_MODE_TLB) ||
-	    (bond_mode == BOND_MODE_ALB)) {
-		if (!miimon) {
-			printk(KERN_WARNING DRV_NAME
-			       ": Warning: miimon must be specified, "
-			       "otherwise bonding will not detect link "
-			       "failure and link speed which are essential "
-			       "for TLB/ALB load balancing\n");
-			printk(KERN_WARNING "Forcing miimon to 100msec\n");
-			miimon = 100;
-		}
-	}
-
 	if (bond_mode == BOND_MODE_ALB) {
 		printk(KERN_NOTICE DRV_NAME
 		       ": In ALB mode you might experience client "
@@ -4825,19 +4832,7 @@ static int bond_check_params(struct bond
 		       updelay);
 	}
 
-	if (!miimon) {
-		if (updelay || downdelay) {
-			/* just warn the user the up/down delay will have
-			 * no effect since miimon is zero...
-			 */
-			printk(KERN_WARNING DRV_NAME
-			       ": Warning: miimon module parameter not set "
-			       "and updelay (%d) or downdelay (%d) module "
-			       "parameter is set; updelay and downdelay have "
-			       "no effect unless miimon is set\n",
-			       updelay, downdelay);
-		}
-	} else {
+	if (miimon) {
 		/* don't allow arp monitoring */
 		if (arp_interval) {
 			printk(KERN_WARNING DRV_NAME
@@ -4944,15 +4939,6 @@ static int bond_check_params(struct bond
 
 		printk("\n");
 
-	} else if (max_bonds) {
-		/* miimon and arp_interval not set, we need one so things
-		 * work as expected, see bonding.txt for details
-		 */
-		printk(KERN_WARNING DRV_NAME
-		       ": Warning: either miimon or arp_interval and "
-		       "arp_ip_target module parameters must be specified, "
-		       "otherwise bonding will not detect link failures! see "
-		       "bonding.txt for details.\n");
 	}
 
 	if (primary && !USES_PRIMARY(bond_mode)) {

-- 

