From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 8/8] bonding: Add "follow" option to fail_over_mac
Date: Sat, 17 May 2008 21:10:14 -0700
Message-ID: <12110838193155-git-send-email-fubar@us.ibm.com>
References: <12110838143907-git-send-email-fubar@us.ibm.com>
 <12110838151824-git-send-email-fubar@us.ibm.com>
 <12110838151104-git-send-email-fubar@us.ibm.com>
 <12110838162313-git-send-email-fubar@us.ibm.com>
 <1211083816660-git-send-email-fubar@us.ibm.com>
 <1211083817934-git-send-email-fubar@us.ibm.com>
 <1211083818228-git-send-email-fubar@us.ibm.com>
 <12110838181126-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:36679 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbYEREK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 00:10:26 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4I471ZR001141
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 00:07:01 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4I4AK4i068854
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:25 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4I4AJl9004674
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:20 -0600
In-Reply-To: <12110838181126-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Add a "follow" selection for fail_over_mac.  This option
causes the MAC address to move from slave to slave as the active
slave changes.  This is in addition to the existing fail_over_mac option
that causes the bond's MAC address to change during failover.

	This new option is useful for devices that cannot tolerate
multiple ports using the same MAC address simultaneously, either
because it confuses them or incurs a performance penalty (as is the
case with some LPAR-aware multiport devices).  Because the MAC of the
bond itself does not change, the "follow" option is slightly more
reliable during failover and doesn't change the MAC of the bond during
operation.

	This patch requires a previous ARP monitor change to properly
handle RTNL during failovers.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 Documentation/networking/bonding.txt |   96 ++++++++++++------
 drivers/net/bonding/bond_main.c      |  185 ++++++++++++++++++++++++++-------
 drivers/net/bonding/bond_sysfs.c     |   36 +++----
 drivers/net/bonding/bonding.h        |    4 +
 4 files changed, 232 insertions(+), 89 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index a0cda06..8e6b8d3 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -289,35 +289,73 @@ downdelay
 fail_over_mac
 
 	Specifies whether active-backup mode should set all slaves to
-	the same MAC address (the traditional behavior), or, when
-	enabled, change the bond's MAC address when changing the
-	active interface (i.e., fail over the MAC address itself).
-
-	Fail over MAC is useful for devices that cannot ever alter
-	their MAC address, or for devices that refuse incoming
-	broadcasts with their own source MAC (which interferes with
-	the ARP monitor).
-
-	The down side of fail over MAC is that every device on the
-	network must be updated via gratuitous ARP, vs. just updating
-	a switch or set of switches (which often takes place for any
-	traffic, not just ARP traffic, if the switch snoops incoming
-	traffic to update its tables) for the traditional method.  If
-	the gratuitous ARP is lost, communication may be disrupted.
-
-	When fail over MAC is used in conjuction with the mii monitor,
-	devices which assert link up prior to being able to actually
-	transmit and receive are particularly susecptible to loss of
-	the gratuitous ARP, and an appropriate updelay setting may be
-	required.
-
-	A value of 0 disables fail over MAC, and is the default.  A
-	value of 1 enables fail over MAC.  This option is enabled
-	automatically if the first slave added cannot change its MAC
-	address.  This option may be modified via sysfs only when no
-	slaves are present in the bond.
-
-	This option was added in bonding version 3.2.0.
+	the same MAC address at enslavement (the traditional
+	behavior), or, when enabled, perform special handling of the
+	bond's MAC address in accordance with the selected policy.
+
+	Possible values are:
+
+	none or 0
+
+		This setting disables fail_over_mac, and causes
+		bonding to set all slaves of an active-backup bond to
+		the same MAC address at enslavement time.  This is the
+		default.
+
+	active or 1
+
+		The "active" fail_over_mac policy indicates that the
+		MAC address of the bond should always be the MAC
+		address of the currently active slave.  The MAC
+		address of the slaves is not changed; instead, the MAC
+		address of the bond changes during a failover.
+
+		This policy is useful for devices that cannot ever
+		alter their MAC address, or for devices that refuse
+		incoming broadcasts with their own source MAC (which
+		interferes with the ARP monitor).
+
+		The down side of this policy is that every device on
+		the network must be updated via gratuitous ARP,
+		vs. just updating a switch or set of switches (which
+		often takes place for any traffic, not just ARP
+		traffic, if the switch snoops incoming traffic to
+		update its tables) for the traditional method.  If the
+		gratuitous ARP is lost, communication may be
+		disrupted.
+
+		When this policy is used in conjuction with the mii
+		monitor, devices which assert link up prior to being
+		able to actually transmit and receive are particularly
+		susecptible to loss of the gratuitous ARP, and an
+		appropriate updelay setting may be required.
+
+	follow or 2
+
+		The "follow" fail_over_mac policy causes the MAC
+		address of the bond to be selected normally (normally
+		the MAC address of the first slave added to the bond).
+		However, the second and subsequent slaves are not set
+		to this MAC address while they are in a backup role; a
+		slave is programmed with the bond's MAC address at
+		failover time (and the formerly active slave receives
+		the newly active slave's MAC address).
+
+		This policy is useful for multiport devices that
+		either become confused or incur a performance penalty
+		when multiple ports are programmed with the same MAC
+		address.
+
+
+	The default policy is none, unless the first slave cannot
+	change its MAC address, in which case the active policy is
+	selected by default.
+
+	This option may be modified via sysfs only when no slaves are
+	present in the bond.
+
+	This option was added in bonding version 3.2.0.  The "follow"
+	policy was added in bonding version 3.3.0.
 
 lacp_rate
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 51e0f2d..5b4af3c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -100,7 +100,7 @@ static char *xmit_hash_policy = NULL;
 static int arp_interval = BOND_LINK_ARP_INTERV;
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS] = { NULL, };
 static char *arp_validate = NULL;
-static int fail_over_mac = 0;
+static char *fail_over_mac = NULL;
 struct bond_params bonding_defaults;
 
 module_param(max_bonds, int, 0);
@@ -136,8 +136,8 @@ module_param_array(arp_ip_target, charp, NULL, 0);
 MODULE_PARM_DESC(arp_ip_target, "arp targets in n.n.n.n form");
 module_param(arp_validate, charp, 0);
 MODULE_PARM_DESC(arp_validate, "validate src/dst of ARP probes: none (default), active, backup or all");
-module_param(fail_over_mac, int, 0);
-MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to the same MAC.  0 of off (default), 1 for on.");
+module_param(fail_over_mac, charp, 0);
+MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to the same MAC.  none (default), active or follow");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -190,6 +190,13 @@ struct bond_parm_tbl arp_validate_tbl[] = {
 {	NULL,			-1},
 };
 
+struct bond_parm_tbl fail_over_mac_tbl[] = {
+{	"none",			BOND_FOM_NONE},
+{	"active",		BOND_FOM_ACTIVE},
+{	"follow",		BOND_FOM_FOLLOW},
+{	NULL,			-1},
+};
+
 /*-------------------------- Forward declarations ---------------------------*/
 
 static void bond_send_gratuitous_arp(struct bonding *bond);
@@ -973,6 +980,82 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active, struct
 	}
 }
 
+/*
+ * bond_do_fail_over_mac
+ *
+ * Perform special MAC address swapping for fail_over_mac settings
+ *
+ * Called with RTNL, bond->lock for read, curr_slave_lock for write_bh.
+ */
+static void bond_do_fail_over_mac(struct bonding *bond,
+				  struct slave *new_active,
+				  struct slave *old_active)
+{
+	u8 tmp_mac[ETH_ALEN];
+	struct sockaddr saddr;
+	int rv;
+
+	switch (bond->params.fail_over_mac) {
+	case BOND_FOM_ACTIVE:
+		if (new_active)
+			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
+			       new_active->dev->addr_len);
+		break;
+	case BOND_FOM_FOLLOW:
+		/*
+		 * if new_active && old_active, swap them
+		 * if just old_active, do nothing (going to no active slave)
+		 * if just new_active, set new_active to bond's MAC
+		 */
+		if (!new_active)
+			return;
+
+		write_unlock_bh(&bond->curr_slave_lock);
+		read_unlock(&bond->lock);
+
+		if (old_active) {
+			memcpy(tmp_mac, new_active->dev->dev_addr, ETH_ALEN);
+			memcpy(saddr.sa_data, old_active->dev->dev_addr,
+			       ETH_ALEN);
+			saddr.sa_family = new_active->dev->type;
+		} else {
+			memcpy(saddr.sa_data, bond->dev->dev_addr, ETH_ALEN);
+			saddr.sa_family = bond->dev->type;
+		}
+
+		rv = dev_set_mac_address(new_active->dev, &saddr);
+		if (rv) {
+			printk(KERN_ERR DRV_NAME
+			       ": %s: Error %d setting MAC of slave %s\n",
+			       bond->dev->name, -rv, new_active->dev->name);
+			goto out;
+		}
+
+		if (!old_active)
+			goto out;
+
+		memcpy(saddr.sa_data, tmp_mac, ETH_ALEN);
+		saddr.sa_family = old_active->dev->type;
+
+		rv = dev_set_mac_address(old_active->dev, &saddr);
+		if (rv)
+			printk(KERN_ERR DRV_NAME
+			       ": %s: Error %d setting MAC of slave %s\n",
+			       bond->dev->name, -rv, new_active->dev->name);
+out:
+		read_lock(&bond->lock);
+		write_lock_bh(&bond->curr_slave_lock);
+		break;
+	default:
+		printk(KERN_ERR DRV_NAME
+		       ": %s: bond_do_fail_over_mac impossible: bad policy %d\n",
+		       bond->dev->name, bond->params.fail_over_mac);
+		break;
+	}
+
+}
+
+
 /**
  * find_best_interface - select the best available slave to be the active one
  * @bond: our bonding struct
@@ -1040,7 +1123,8 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
  * because it is apparently the best available slave we have, even though its
  * updelay hasn't timed out yet.
  *
- * Warning: Caller must hold curr_slave_lock for writing.
+ * If new_active is not NULL, caller must hold bond->lock for read and
+ * curr_slave_lock for write_bh.
  */
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 {
@@ -1107,12 +1191,9 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			bond_set_slave_active_flags(new_active);
 		}
 
-		/* when bonding does not set the slave MAC address, the bond MAC
-		 * address is the one of the active slave.
-		 */
 		if (new_active && bond->params.fail_over_mac)
-			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
-				new_active->dev->addr_len);
+			bond_do_fail_over_mac(bond, new_active, old_active);
+
 		bond->send_grat_arp = bond->params.num_grat_arp;
 		if (bond->curr_active_slave &&
 			test_bit(__LINK_STATE_LINKWATCH_PENDING,
@@ -1137,7 +1218,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
  * - The primary_slave has got its link back.
  * - A slave has got its link back and there's no old curr_active_slave.
  *
- * Warning: Caller must hold curr_slave_lock for writing.
+ * Caller must hold bond->lock for read and curr_slave_lock for write_bh.
  */
 void bond_select_active_slave(struct bonding *bond)
 {
@@ -1384,14 +1465,14 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			printk(KERN_WARNING DRV_NAME
 			       ": %s: Warning: The first slave device "
 			       "specified does not support setting the MAC "
-			       "address. Enabling the fail_over_mac option.",
+			       "address. Setting fail_over_mac to active.",
 			       bond_dev->name);
-			bond->params.fail_over_mac = 1;
-		} else if (!bond->params.fail_over_mac) {
+			bond->params.fail_over_mac = BOND_FOM_ACTIVE;
+		} else if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
 			printk(KERN_ERR DRV_NAME
 				": %s: Error: The slave device specified "
 				"does not support setting the MAC address, "
-				"but fail_over_mac is not enabled.\n"
+				"but fail_over_mac is not set to active.\n"
 				, bond_dev->name);
 			res = -EOPNOTSUPP;
 			goto err_undo_flags;
@@ -1498,6 +1579,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	bond_compute_features(bond);
 
+	write_unlock_bh(&bond->lock);
+
+	read_lock(&bond->lock);
+
 	new_slave->last_arp_rx = jiffies;
 
 	if (bond->params.miimon && !bond->params.use_carrier) {
@@ -1574,6 +1659,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		}
 	}
 
+	write_lock_bh(&bond->curr_slave_lock);
+
 	switch (bond->params.mode) {
 	case BOND_MODE_ACTIVEBACKUP:
 		bond_set_slave_inactive_flags(new_slave);
@@ -1621,9 +1708,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		break;
 	} /* switch(bond_mode) */
 
+	write_unlock_bh(&bond->curr_slave_lock);
+
 	bond_set_carrier(bond);
 
-	write_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	res = bond_create_slave_symlinks(bond_dev, slave_dev);
 	if (res)
@@ -1647,6 +1736,10 @@ err_unset_master:
 
 err_restore_mac:
 	if (!bond->params.fail_over_mac) {
+		/* XXX TODO - fom follow mode needs to change master's
+		 * MAC if this slave's MAC is in use by the bond, or at
+		 * least print a warning.
+		 */
 		memcpy(addr.sa_data, new_slave->perm_hwaddr, ETH_ALEN);
 		addr.sa_family = slave_dev->type;
 		dev_set_mac_address(slave_dev, &addr);
@@ -1701,20 +1794,18 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		return -EINVAL;
 	}
 
-	mac_addr_differ = memcmp(bond_dev->dev_addr,
-				 slave->perm_hwaddr,
-				 ETH_ALEN);
-	if (!mac_addr_differ && (bond->slave_cnt > 1)) {
-		printk(KERN_WARNING DRV_NAME
-		       ": %s: Warning: the permanent HWaddr of %s - "
-		       "%s - is still in use by %s. "
-		       "Set the HWaddr of %s to a different address "
-		       "to avoid conflicts.\n",
-		       bond_dev->name,
-		       slave_dev->name,
-		       print_mac(mac, slave->perm_hwaddr),
-		       bond_dev->name,
-		       slave_dev->name);
+	if (!bond->params.fail_over_mac) {
+		mac_addr_differ = memcmp(bond_dev->dev_addr, slave->perm_hwaddr,
+					 ETH_ALEN);
+		if (!mac_addr_differ && (bond->slave_cnt > 1))
+			printk(KERN_WARNING DRV_NAME
+			       ": %s: Warning: the permanent HWaddr of %s - "
+			       "%s - is still in use by %s. "
+			       "Set the HWaddr of %s to a different address "
+			       "to avoid conflicts.\n",
+			       bond_dev->name, slave_dev->name,
+			       print_mac(mac, slave->perm_hwaddr),
+			       bond_dev->name, slave_dev->name);
 	}
 
 	/* Inform AD package of unbinding of slave. */
@@ -1841,7 +1932,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	/* close slave before restoring its mac address */
 	dev_close(slave_dev);
 
-	if (!bond->params.fail_over_mac) {
+	if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
 		/* restore original ("permanent") mac address */
 		memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
 		addr.sa_family = slave_dev->type;
@@ -3164,7 +3255,8 @@ static void bond_info_show_master(struct seq_file *seq)
 
 	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP &&
 	    bond->params.fail_over_mac)
-		seq_printf(seq, " (fail_over_mac)");
+		seq_printf(seq, " (fail_over_mac %s)",
+		   fail_over_mac_tbl[bond->params.fail_over_mac].modename);
 
 	seq_printf(seq, "\n");
 
@@ -4092,10 +4184,10 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	dprintk("bond=%p, name=%s\n", bond, (bond_dev ? bond_dev->name : "None"));
 
 	/*
-	 * If fail_over_mac is enabled, do nothing and return success.
-	 * Returning an error causes ifenslave to fail.
+	 * If fail_over_mac is set to active, do nothing and return
+	 * success.  Returning an error causes ifenslave to fail.
 	 */
-	if (bond->params.fail_over_mac)
+	if (bond->params.fail_over_mac == BOND_FOM_ACTIVE)
 		return 0;
 
 	if (!is_valid_ether_addr(sa->sa_data)) {
@@ -4600,7 +4692,7 @@ int bond_parse_parm(const char *buf, struct bond_parm_tbl *tbl)
 
 static int bond_check_params(struct bond_params *params)
 {
-	int arp_validate_value;
+	int arp_validate_value, fail_over_mac_value;
 
 	/*
 	 * Convert string parameters.
@@ -4875,10 +4967,23 @@ static int bond_check_params(struct bond_params *params)
 		primary = NULL;
 	}
 
-	if (fail_over_mac && (bond_mode != BOND_MODE_ACTIVEBACKUP))
-		printk(KERN_WARNING DRV_NAME
-		       ": Warning: fail_over_mac only affects "
-		       "active-backup mode.\n");
+	if (fail_over_mac) {
+		fail_over_mac_value = bond_parse_parm(fail_over_mac,
+						      fail_over_mac_tbl);
+		if (fail_over_mac_value == -1) {
+			printk(KERN_ERR DRV_NAME
+			       ": Error: invalid fail_over_mac \"%s\"\n",
+			       arp_validate == NULL ? "NULL" : arp_validate);
+			return -EINVAL;
+		}
+
+		if (bond_mode != BOND_MODE_ACTIVEBACKUP)
+			printk(KERN_WARNING DRV_NAME
+			       ": Warning: fail_over_mac only affects "
+			       "active-backup mode.\n");
+	} else {
+		fail_over_mac_value = BOND_FOM_NONE;
+	}
 
 	/* fill params struct with the proper values */
 	params->mode = bond_mode;
@@ -4892,7 +4997,7 @@ static int bond_check_params(struct bond_params *params)
 	params->use_carrier = use_carrier;
 	params->lacp_fast = lacp_fast;
 	params->primary[0] = 0;
-	params->fail_over_mac = fail_over_mac;
+	params->fail_over_mac = fail_over_mac_value;
 
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 7a61e9a..dd265c6 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -50,6 +50,7 @@ extern struct bond_parm_tbl bond_mode_tbl[];
 extern struct bond_parm_tbl bond_lacp_tbl[];
 extern struct bond_parm_tbl xmit_hashtype_tbl[];
 extern struct bond_parm_tbl arp_validate_tbl[];
+extern struct bond_parm_tbl fail_over_mac_tbl[];
 
 static int expected_refcount = -1;
 static struct class *netdev_class;
@@ -547,42 +548,37 @@ static ssize_t bonding_show_fail_over_mac(struct device *d, struct device_attrib
 {
 	struct bonding *bond = to_bond(d);
 
-	return sprintf(buf, "%d\n", bond->params.fail_over_mac) + 1;
+	return sprintf(buf, "%s %d\n",
+		       fail_over_mac_tbl[bond->params.fail_over_mac].modename,
+		       bond->params.fail_over_mac);
 }
 
 static ssize_t bonding_store_fail_over_mac(struct device *d, struct device_attribute *attr, const char *buf, size_t count)
 {
 	int new_value;
-	int ret = count;
 	struct bonding *bond = to_bond(d);
 
 	if (bond->slave_cnt != 0) {
 		printk(KERN_ERR DRV_NAME
 		       ": %s: Can't alter fail_over_mac with slaves in bond.\n",
 		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
+		return -EPERM;
 	}
 
-	if (sscanf(buf, "%d", &new_value) != 1) {
+	new_value = bond_parse_parm(buf, fail_over_mac_tbl);
+	if (new_value < 0) {
 		printk(KERN_ERR DRV_NAME
-		       ": %s: no fail_over_mac value specified.\n",
-		       bond->dev->name);
-		ret = -EINVAL;
-		goto out;
+		       ": %s: Ignoring invalid fail_over_mac value %s.\n",
+		       bond->dev->name, buf);
+		return -EINVAL;
 	}
 
-	if ((new_value == 0) || (new_value == 1)) {
-		bond->params.fail_over_mac = new_value;
-		printk(KERN_INFO DRV_NAME ": %s: Setting fail_over_mac to %d.\n",
-		       bond->dev->name, new_value);
-	} else {
-		printk(KERN_INFO DRV_NAME
-		       ": %s: Ignoring invalid fail_over_mac value %d.\n",
-		       bond->dev->name, new_value);
-	}
-out:
-	return ret;
+	bond->params.fail_over_mac = new_value;
+	printk(KERN_INFO DRV_NAME ": %s: Setting fail_over_mac to %s (%d).\n",
+	       bond->dev->name, fail_over_mac_tbl[new_value].modename,
+	       new_value);
+
+	return count;
 }
 
 static DEVICE_ATTR(fail_over_mac, S_IRUGO | S_IWUSR, bonding_show_fail_over_mac, bonding_store_fail_over_mac);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 8766b12..89fd996 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -248,6 +248,10 @@ static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
 	return (struct bonding *)slave->dev->master->priv;
 }
 
+#define BOND_FOM_NONE			0
+#define BOND_FOM_ACTIVE			1
+#define BOND_FOM_FOLLOW			2
+
 #define BOND_ARP_VALIDATE_NONE		0
 #define BOND_ARP_VALIDATE_ACTIVE	(1 << BOND_STATE_ACTIVE)
 #define BOND_ARP_VALIDATE_BACKUP	(1 << BOND_STATE_BACKUP)
-- 
1.5.2.4

