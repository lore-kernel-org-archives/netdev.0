From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 9/10] [bonding 2.6] make each bond device use its own /proc entry
Date: Thu, 4 Sep 2003 20:45:38 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309042045.38523.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep  4 20:18:13 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep  4 20:18:14 2003
@@ -545,14 +545,6 @@ static int bond_release(struct net_devic
 static int bond_release_all(struct net_device *master);
 static int bond_sethwaddr(struct net_device *master, struct net_device *slave);
 
-/*
- * bond_get_info is the interface into the /proc filesystem.  This is
- * a different interface than the BOND_INFO_QUERY ioctl.  That is done
- * through the generic networking ioctl interface, and bond_info_query
- * is the internal function which provides that information.
- */
-static int bond_get_info(char *buf, char **start, off_t offset, int length);
-
 /* Caller must hold bond->ptrlock for write */
 static inline struct slave*
 bond_assign_current_slave(struct bonding *bond,struct slave *newslave)
@@ -3337,132 +3329,136 @@ static struct net_device_stats *bond_get
 	return stats;
 }
 
-static int bond_get_info(char *buf, char **start, off_t offset, int length)
+#ifdef CONFIG_PROC_FS
+static int bond_read_proc(char *buf, char **start, off_t off, int count, int *eof, void *data)
 {
-	bonding_t *bond;
+	struct bonding *bond = (struct bonding *) data;
 	int len = 0;
-	off_t begin = 0;
 	u16 link;
 	slave_t *slave = NULL;
 
+	/* make sure the bond won't be taken away */
+	read_lock(&dev_base_lock);
+
 	len += sprintf(buf + len, "%s\n", version);
 
-	read_lock(&dev_base_lock);
-	list_for_each_entry(bond, &bond_dev_list, bond_list) {
-		/*
-		 * This function locks the mutex, so we can't lock it until 
-		 * afterwards
-		 */
-		link = bond_check_mii_link(bond);
+	/*
+	 * This function locks the mutex, so we can't lock it until
+	 * afterwards
+	 */
+	link = bond_check_mii_link(bond);
 
-		len += sprintf(buf + len, "Bonding Mode: %s\n",
-			       bond_mode_name());
+	len += sprintf(buf + len, "Bonding Mode: %s\n",
+		       bond_mode_name());
 
-		if ((bond_mode == BOND_MODE_ACTIVEBACKUP) ||
-		    (bond_mode == BOND_MODE_TLB) ||
-		    (bond_mode == BOND_MODE_ALB)) {
-			read_lock_bh(&bond->lock);
-			read_lock(&bond->ptrlock);
-			if (bond->current_slave != NULL) {
-				len += sprintf(buf + len, 
-					"Currently Active Slave: %s\n", 
-					bond->current_slave->dev->name);
-			}
-			read_unlock(&bond->ptrlock);
-			read_unlock_bh(&bond->lock);
+	if ((bond_mode == BOND_MODE_ACTIVEBACKUP) ||
+	    (bond_mode == BOND_MODE_TLB) ||
+	    (bond_mode == BOND_MODE_ALB)) {
+		read_lock_bh(&bond->lock);
+		read_lock(&bond->ptrlock);
+		if (bond->current_slave != NULL) {
+			len += sprintf(buf + len,
+				"Currently Active Slave: %s\n",
+				bond->current_slave->dev->name);
 		}
+		read_unlock(&bond->ptrlock);
+		read_unlock_bh(&bond->lock);
+	}
 
-		len += sprintf(buf + len, "MII Status: ");
-		len += sprintf(buf + len, 
-				link == BMSR_LSTATUS ? "up\n" : "down\n");
-		len += sprintf(buf + len, "MII Polling Interval (ms): %d\n", 
-				miimon);
-		len += sprintf(buf + len, "Up Delay (ms): %d\n", 
-				updelay * miimon);
-		len += sprintf(buf + len, "Down Delay (ms): %d\n", 
-				downdelay * miimon);
-		len += sprintf(buf + len, "Multicast Mode: %s\n",
-			       multicast_mode_name());
+	len += sprintf(buf + len, "MII Status: ");
+	len += sprintf(buf + len,
+			link == BMSR_LSTATUS ? "up\n" : "down\n");
+	len += sprintf(buf + len, "MII Polling Interval (ms): %d\n",
+			miimon);
+	len += sprintf(buf + len, "Up Delay (ms): %d\n",
+			updelay * miimon);
+	len += sprintf(buf + len, "Down Delay (ms): %d\n",
+			downdelay * miimon);
+	len += sprintf(buf + len, "Multicast Mode: %s\n",
+		       multicast_mode_name());
 
-		read_lock_bh(&bond->lock);
+	read_lock_bh(&bond->lock);
 
-		if (bond_mode == BOND_MODE_8023AD) {
-			struct ad_info ad_info;
+	if (bond_mode == BOND_MODE_8023AD) {
+		struct ad_info ad_info;
 
-			len += sprintf(buf + len, "\n802.3ad info\n");
+		len += sprintf(buf + len, "\n802.3ad info\n");
 
-			if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
-				len += sprintf(buf + len, "bond %s has no active aggregator\n", bond->device->name);
-			} else {
-				len += sprintf(buf + len, "Active Aggregator Info:\n");
+		if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
+			len += sprintf(buf + len, "bond %s has no active aggregator\n", bond->device->name);
+		} else {
+			len += sprintf(buf + len, "Active Aggregator Info:\n");
 
-				len += sprintf(buf + len, "\tAggregator ID: %d\n", ad_info.aggregator_id);
-				len += sprintf(buf + len, "\tNumber of ports: %d\n", ad_info.ports);
-				len += sprintf(buf + len, "\tActor Key: %d\n", ad_info.actor_key);
-				len += sprintf(buf + len, "\tPartner Key: %d\n", ad_info.partner_key);
-				len += sprintf(buf + len, "\tPartner Mac Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
-					       ad_info.partner_system[0],
-					       ad_info.partner_system[1],
-					       ad_info.partner_system[2],
-					       ad_info.partner_system[3],
-					       ad_info.partner_system[4],
-					       ad_info.partner_system[5]);
-			}
+			len += sprintf(buf + len, "\tAggregator ID: %d\n", ad_info.aggregator_id);
+			len += sprintf(buf + len, "\tNumber of ports: %d\n", ad_info.ports);
+			len += sprintf(buf + len, "\tActor Key: %d\n", ad_info.actor_key);
+			len += sprintf(buf + len, "\tPartner Key: %d\n", ad_info.partner_key);
+			len += sprintf(buf + len, "\tPartner Mac Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
+				       ad_info.partner_system[0],
+				       ad_info.partner_system[1],
+				       ad_info.partner_system[2],
+				       ad_info.partner_system[3],
+				       ad_info.partner_system[4],
+				       ad_info.partner_system[5]);
 		}
+	}
 
-		for (slave = bond->prev; slave != (slave_t *)bond; 
-		     slave = slave->prev) {
-			len += sprintf(buf + len, "\nSlave Interface: %s\n", slave->dev->name);
-
-			len += sprintf(buf + len, "MII Status: ");
-
-			len += sprintf(buf + len, 
-				slave->link == BOND_LINK_UP ? 
-				"up\n" : "down\n");
-			len += sprintf(buf + len, "Link Failure Count: %d\n", 
-				slave->link_failure_count);
-
-			if (app_abi_ver >= 1) {
-				len += sprintf(buf + len,
-					       "Permanent HW addr: %02x:%02x:%02x:%02x:%02x:%02x\n",
-					       slave->perm_hwaddr[0],
-					       slave->perm_hwaddr[1],
-					       slave->perm_hwaddr[2],
-					       slave->perm_hwaddr[3],
-					       slave->perm_hwaddr[4],
-					       slave->perm_hwaddr[5]);
-			}
+	for (slave = bond->prev; slave != (slave_t *)bond;
+	     slave = slave->prev) {
+		len += sprintf(buf + len, "\nSlave Interface: %s\n", slave->dev->name);
 
-			if (bond_mode == BOND_MODE_8023AD) {
-				struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
+		len += sprintf(buf + len, "MII Status: ");
 
-				if (agg) {
-					len += sprintf(buf + len, "Aggregator ID: %d\n",
-						       agg->aggregator_identifier);
-				} else {
-					len += sprintf(buf + len, "Aggregator ID: N/A\n");
-				}
-			}
-		}
-		read_unlock_bh(&bond->lock);
+		len += sprintf(buf + len,
+			slave->link == BOND_LINK_UP ?
+			"up\n" : "down\n");
+		len += sprintf(buf + len, "Link Failure Count: %d\n",
+			slave->link_failure_count);
 
-		/*
-		 * Figure out the calcs for the /proc/net interface
-		 */
-		*start = buf + (offset - begin);
-		len -= (offset - begin);
-		if (len > length) {
-			len = length;
+		if (app_abi_ver >= 1) {
+			len += sprintf(buf + len,
+				       "Permanent HW addr: %02x:%02x:%02x:%02x:%02x:%02x\n",
+				       slave->perm_hwaddr[0],
+				       slave->perm_hwaddr[1],
+				       slave->perm_hwaddr[2],
+				       slave->perm_hwaddr[3],
+				       slave->perm_hwaddr[4],
+				       slave->perm_hwaddr[5]);
 		}
-		if (len < 0) {
-			len = 0;
+
+		if (bond_mode == BOND_MODE_8023AD) {
+			struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
+
+			if (agg) {
+				len += sprintf(buf + len, "Aggregator ID: %d\n",
+					       agg->aggregator_identifier);
+			} else {
+				len += sprintf(buf + len, "Aggregator ID: N/A\n");
+			}
 		}
+	}
+	read_unlock_bh(&bond->lock);
 
+	/*
+	 * Figure out the calcs for the /proc/net interface
+	 */
+	if (len <= off + count) {
+		*eof = 1;
 	}
+	*start = buf + off;
+	len -= off;
+	if (len > count) {
+		len = count;
+	}
+	if (len < 0) {
+		len = 0;
+	}
+
 	read_unlock(&dev_base_lock);
 
 	return len;
 }
+#endif /* CONFIG_PROC_FS */
 
 static int bond_event(struct notifier_block *this, unsigned long event, 
 			void *ptr)
@@ -3594,8 +3590,8 @@ static int __init bond_init(struct net_d
 	bond->bond_proc_dir->owner = THIS_MODULE;
 
 	bond->bond_proc_info_file = 
-		create_proc_info_entry("info", 0, bond->bond_proc_dir, 
-					bond_get_info);
+		create_proc_read_entry("info", 0, bond->bond_proc_dir,
+					bond_read_proc, bond);
 	if (bond->bond_proc_info_file == NULL) {
 		printk(KERN_ERR "%s: Cannot init /proc/net/%s/info\n", 
 			dev->name, dev->name);
