From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 4/10] [bonding 2.6] Decouple promiscuous handling from multicast mode setting
Date: Thu, 11 Sep 2003 17:40:09 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309111740.09480.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:23 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:24 2003
@@ -1151,23 +1151,22 @@ static inline int dmi_same(struct dev_mc
 } 
 
 /*
- * Push the promiscuity flag down to all slaves
+ * Push the promiscuity flag down to appropriate slaves
  */
 static void bond_set_promiscuity(bonding_t *bond, int inc)
 { 
 	slave_t *slave; 
-	switch (multicast_mode) {
-	case BOND_MULTICAST_ACTIVE :
-		/* write lock already acquired */
-		if (bond->current_slave != NULL)
+
+	if (USES_PRIMARY(bond_mode)) {
+		if (bond->current_slave) {
 			dev_set_promiscuity(bond->current_slave->dev, inc);
-		break;
-	case BOND_MULTICAST_ALL :
-		for (slave = bond->prev; slave != (slave_t*)bond; slave = slave->prev)
+		}
+
+	} else { 
+		for (slave = bond->prev; slave != (slave_t*)bond;
+		     slave = slave->prev) {
 			dev_set_promiscuity(slave->dev, inc);
-		break;
-	case BOND_MULTICAST_DISABLED :
-		break;
+		}
 	}
 } 
 
@@ -1213,20 +1212,23 @@ static void set_multicast_list(struct ne
 	bonding_t *bond = master->priv;
 	struct dev_mc_list *dmi;
 
-	if (multicast_mode == BOND_MULTICAST_DISABLED)
-		return;
-	/*
-	 * Lock the private data for the master
-	 */
 	write_lock_bh(&bond->lock);
 
-	/* set promiscuity flag to slaves */
+	/*
+	 * Do promisc before checking multicast_mode
+	 */
 	if ( (master->flags & IFF_PROMISC) && !(bond->flags & IFF_PROMISC) )
 		bond_set_promiscuity(bond, 1); 
 
 	if ( !(master->flags & IFF_PROMISC) && (bond->flags & IFF_PROMISC) ) 
 		bond_set_promiscuity(bond, -1); 
 
+	if (multicast_mode == BOND_MULTICAST_DISABLED) {
+		bond->flags = master->flags;
+		write_unlock_bh(&bond->lock);
+		return;
+	}
+
 	/* set allmulti flag to slaves */ 
 	if ( (master->flags & IFF_ALLMULTI) && !(bond->flags & IFF_ALLMULTI) ) 
 		bond_set_allmulti(bond, 1); 
@@ -1258,32 +1260,40 @@ static void set_multicast_list(struct ne
 
 /*
  * Update the mc list and multicast-related flags for the new and 
- * old active slaves (if any) according to the multicast mode
+ * old active slaves (if any) according to the multicast mode, and
+ * promiscuous flags unconditionally.
  */
 static void bond_mc_update(bonding_t *bond, slave_t *new, slave_t *old)
 {
 	struct dev_mc_list *dmi;
 
-	switch(multicast_mode) {
-	case BOND_MULTICAST_ACTIVE :		
+	if (USES_PRIMARY(bond_mode)) {
 		if (bond->device->flags & IFF_PROMISC) {
-			if (old != NULL && new != old)
+			if (old)
 				dev_set_promiscuity(old->dev, -1);
-			dev_set_promiscuity(new->dev, 1);
+			if (new)
+				dev_set_promiscuity(new->dev, 1);
 		}
+	}
+
+	switch(multicast_mode) {
+	case BOND_MULTICAST_ACTIVE :		
 		if (bond->device->flags & IFF_ALLMULTI) {
-			if (old != NULL && new != old)
+			if (old)
 				dev_set_allmulti(old->dev, -1);
-			dev_set_allmulti(new->dev, 1);
+			if (new)
+				dev_set_allmulti(new->dev, 1);
 		}
 		/* first remove all mc addresses from old slave if any,
 		   and _then_ add them to new active slave */
-		if (old != NULL && new != old) {
+		if (old) {
 			for (dmi = bond->device->mc_list; dmi != NULL; dmi = dmi->next)
 				dev_mc_delete(old->dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 		}
-		for (dmi = bond->device->mc_list; dmi != NULL; dmi = dmi->next)
-			dev_mc_add(new->dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
+		if (new) {
+			for (dmi = bond->device->mc_list; dmi != NULL; dmi = dmi->next)
+				dev_mc_add(new->dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
+		}
 		break;
 	case BOND_MULTICAST_ALL :
 		/* nothing to do: mc list is already up-to-date on all slaves */
@@ -1445,11 +1455,19 @@ static int bond_enslave(struct net_devic
 		}
 	}
 
-	if (multicast_mode == BOND_MULTICAST_ALL) {
-		/* set promiscuity level to new slave */ 
-		if (master_dev->flags & IFF_PROMISC)
+	/* set promiscuity level to new slave */ 
+	if (master_dev->flags & IFF_PROMISC) {
+		/* If the mode USES_PRIMARY, then the new slave gets the
+		 * master's promisc (and mc) settings only if it becomes the
+		 * current_slave, and that is taken care of later when calling
+		 * bond_change_active()
+		 */
+		if (!USES_PRIMARY(bond_mode)) {
 			dev_set_promiscuity(slave_dev, 1); 
+		}
+	}
  
+	if (multicast_mode == BOND_MULTICAST_ALL) {
 		/* set allmulti level to new slave */
 		if (master_dev->flags & IFF_ALLMULTI) 
 			dev_set_allmulti(slave_dev, 1); 
@@ -2024,16 +2042,22 @@ static int bond_release(struct net_devic
 		return -EINVAL;
 	}
 
+	/* unset promiscuity level from slave */
+	if (master->flags & IFF_PROMISC) {
+		/* If the mode USES_PRIMARY, then we should only remove its
+		 * promisc settings if it was the current_slave, but that was
+		 * already taken care of above when we detached the slave
+		 */
+		if (!USES_PRIMARY(bond_mode)) {
+			dev_set_promiscuity(slave, -1); 
+		}
+	}
+
 	/* undo settings and restore original values */
-	
 	if (multicast_mode == BOND_MULTICAST_ALL) {
 		/* flush master's mc_list from slave */ 
 		bond_mc_list_flush (slave, master); 
 
-		/* unset promiscuity level from slave */
-		if (master->flags & IFF_PROMISC) 
-			dev_set_promiscuity(slave, -1); 
-
 		/* unset allmulti level from slave */ 
 		if (master->flags & IFF_ALLMULTI)
 			dev_set_allmulti(slave, -1); 
@@ -2129,17 +2153,17 @@ static int bond_release_all(struct net_d
 		 */
 		write_unlock_bh(&bond->lock);
 
-		if (multicast_mode == BOND_MULTICAST_ALL 
-		    || (multicast_mode == BOND_MULTICAST_ACTIVE 
-			&& old_current == our_slave)) {
+		/* unset promiscuity level from slave */
+		if (master->flags & IFF_PROMISC) {
+			if (!USES_PRIMARY(bond_mode)) {
+				dev_set_promiscuity(slave_dev, -1); 
+			}
+		}
 
+		if (multicast_mode == BOND_MULTICAST_ALL) {
 			/* flush master's mc_list from slave */ 
 			bond_mc_list_flush (slave_dev, master); 
 
-			/* unset promiscuity level from slave */
-			if (master->flags & IFF_PROMISC) 
-				dev_set_promiscuity(slave_dev, -1); 
-
 			/* unset allmulti level from slave */ 
 			if (master->flags & IFF_ALLMULTI)
 				dev_set_allmulti(slave_dev, -1); 
@@ -3634,6 +3658,12 @@ static int __init bonding_init(void)
 			       mode == NULL ? "NULL" : mode);
 			return -EINVAL;
 		}
+	}
+
+	if (USES_PRIMARY(bond_mode)) {
+		multicast_mode = BOND_MULTICAST_ACTIVE;
+	} else {
+		multicast_mode = BOND_MULTICAST_ALL;
 	}
 
 	if (multicast) {
