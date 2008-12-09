From: holger@eitzenberger.org
Subject: [patch 1/7] bonding: add and use bond_is_lb()
Date: Tue, 09 Dec 2008 21:07:51 +0100
Message-ID: <20081209201444.964037720@eitzenberger.org>
References: <20081209200750.490739902@eitzenberger.org>
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:50754 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515AbYLIUOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 15:14:50 -0500
Content-Disposition: inline; filename=bonding-add-n-use-bond_is_lb.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce and use bond_is_lb(), it is usefull to shorten the repetitive
check for either ALB or TLB mode.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6-out/drivers/net/bonding/bond_main.c
===================================================================
--- bonding-2.6-out.orig/drivers/net/bonding/bond_main.c	2008-12-09 20:42:55.000000000 +0100
+++ bonding-2.6-out/drivers/net/bonding/bond_main.c	2008-12-09 20:44:21.000000000 +0100
@@ -294,10 +294,8 @@
 		if (vlan->vlan_id == vlan_id) {
 			list_del(&vlan->vlan_list);
 
-			if ((bond->params.mode == BOND_MODE_TLB) ||
-			    (bond->params.mode == BOND_MODE_ALB)) {
+			if (bond_is_lb(bond))
 				bond_alb_clear_vlan(bond, vlan_id);
-			}
 
 			dprintk("removed VLAN ID %d from bond %s\n", vlan_id,
 				bond->dev->name);
@@ -1174,10 +1172,8 @@
 				bond_3ad_handle_link_change(new_active, BOND_LINK_UP);
 			}
 
-			if ((bond->params.mode == BOND_MODE_TLB) ||
-			    (bond->params.mode == BOND_MODE_ALB)) {
+			if (bond_is_lb(bond))
 				bond_alb_handle_link_change(bond, new_active, BOND_LINK_UP);
-			}
 		} else {
 			if (USES_PRIMARY(bond->params.mode)) {
 				printk(KERN_INFO DRV_NAME
@@ -1192,8 +1188,7 @@
 		bond_mc_swap(bond, new_active, old_active);
 	}
 
-	if ((bond->params.mode == BOND_MODE_TLB) ||
-	    (bond->params.mode == BOND_MODE_ALB)) {
+	if (bond_is_lb(bond)) {
 		bond_alb_handle_active_change(bond, new_active);
 		if (old_active)
 			bond_set_slave_inactive_flags(old_active);
@@ -1554,8 +1549,7 @@
 	new_slave->dev = slave_dev;
 	slave_dev->priv_flags |= IFF_BONDING;
 
-	if ((bond->params.mode == BOND_MODE_TLB) ||
-	    (bond->params.mode == BOND_MODE_ALB)) {
+	if (bond_is_lb(bond)) {
 		/* bond_alb_init_slave() must be called before all other stages since
 		 * it might fail and we do not want to have to undo everything
 		 */
@@ -1871,8 +1865,7 @@
 		bond_change_active_slave(bond, NULL);
 	}
 
-	if ((bond->params.mode == BOND_MODE_TLB) ||
-	    (bond->params.mode == BOND_MODE_ALB)) {
+	if (bond_is_lb(bond)) {
 		/* Must be called only after the slave has been
 		 * detached from the list and the curr_active_slave
 		 * has been cleared (if our_slave == old_current),
@@ -2061,8 +2054,7 @@
 		 */
 		write_unlock_bh(&bond->lock);
 
-		if ((bond->params.mode == BOND_MODE_TLB) ||
-		    (bond->params.mode == BOND_MODE_ALB)) {
+		if (bond_is_lb(bond)) {
 			/* must be called only after the slave
 			 * has been detached from the list
 			 */
@@ -2389,8 +2381,7 @@
 			if (bond->params.mode == BOND_MODE_8023AD)
 				bond_3ad_handle_link_change(slave, BOND_LINK_UP);
 
-			if ((bond->params.mode == BOND_MODE_TLB) ||
-			    (bond->params.mode == BOND_MODE_ALB))
+			if (bond_is_lb(bond))
 				bond_alb_handle_link_change(bond, slave,
 							    BOND_LINK_UP);
 
@@ -3796,8 +3787,7 @@
 
 	bond->kill_timers = 0;
 
-	if ((bond->params.mode == BOND_MODE_TLB) ||
-	    (bond->params.mode == BOND_MODE_ALB)) {
+	if (bond_is_lb(bond)) {
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
 		 */
@@ -3882,8 +3872,7 @@
 	}
 
 
-	if ((bond->params.mode == BOND_MODE_TLB) ||
-	    (bond->params.mode == BOND_MODE_ALB)) {
+	if (bond_is_lb(bond)) {
 		/* Must be called only after all
 		 * slaves have been released
 		 */
Index: bonding-2.6-out/drivers/net/bonding/bonding.h
===================================================================
--- bonding-2.6-out.orig/drivers/net/bonding/bonding.h	2008-12-09 20:42:55.000000000 +0100
+++ bonding-2.6-out/drivers/net/bonding/bonding.h	2008-12-09 20:44:21.000000000 +0100
@@ -260,6 +260,12 @@
 	return (struct bonding *)netdev_priv(slave->dev->master);
 }
 
+static inline bool bond_is_lb(const struct bonding *bond)
+{
+	return bond->params.mode == BOND_MODE_TLB
+		|| bond->params.mode == BOND_MODE_ALB;
+}
+
 #define BOND_FOM_NONE			0
 #define BOND_FOM_ACTIVE			1
 #define BOND_FOM_FOLLOW			2

-- 
