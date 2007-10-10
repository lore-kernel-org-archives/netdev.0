From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 9/9] net/bonding: Optionally allow ethernet slaves to keep own MAC
Date: Tue,  9 Oct 2007 19:43:44 -0700
Message-ID: <11919842282124-git-send-email-fubar@us.ibm.com>
References: <1191984224957-git-send-email-fubar@us.ibm.com>
 <1191984225129-git-send-email-fubar@us.ibm.com>
 <11919842261485-git-send-email-fubar@us.ibm.com>
 <11919842263810-git-send-email-fubar@us.ibm.com>
 <1191984226411-git-send-email-fubar@us.ibm.com>
 <11919842273755-git-send-email-fubar@us.ibm.com>
 <11919842272176-git-send-email-fubar@us.ibm.com>
 <11919842281663-git-send-email-fubar@us.ibm.com>
 <11919842281401-git-send-email-fubar@us.ibm.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:55285 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834AbXJJCnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 22:43:50 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l9A1ZCtO009827
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 21:35:12 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9A2hnNg480764
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:49 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9A2hnf1002158
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:49 -0600
In-Reply-To: <11919842281401-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 Documentation/networking/bonding.txt |   33 +++++++++++++++++++
 drivers/net/bonding/bond_main.c      |   57 +++++++++++++++++++++------------
 drivers/net/bonding/bond_sysfs.c     |   49 +++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h        |    6 ++--
 4 files changed, 121 insertions(+), 24 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 1da5666..1134062 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -281,6 +281,39 @@ downdelay
 	will be rounded down to the nearest multiple.  The default
 	value is 0.
 
+fail_over_mac
+
+	Specifies whether active-backup mode should set all slaves to
+	the same MAC address (the traditional behavior), or, when
+	enabled, change the bond's MAC address when changing the
+	active interface (i.e., fail over the MAC address itself).
+
+	Fail over MAC is useful for devices that cannot ever alter
+	their MAC address, or for devices that refuse incoming
+	broadcasts with their own source MAC (which interferes with
+	the ARP monitor).
+
+	The down side of fail over MAC is that every device on the
+	network must be updated via gratuitous ARP, vs. just updating
+	a switch or set of switches (which often takes place for any
+	traffic, not just ARP traffic, if the switch snoops incoming
+	traffic to update its tables) for the traditional method.  If
+	the gratuitous ARP is lost, communication may be disrupted.
+
+	When fail over MAC is used in conjuction with the mii monitor,
+	devices which assert link up prior to being able to actually
+	transmit and receive are particularly susecptible to loss of
+	the gratuitous ARP, and an appropriate updelay setting may be
+	required.
+
+	A value of 0 disables fail over MAC, and is the default.  A
+	value of 1 enables fail over MAC.  This option is enabled
+	automatically if the first slave added cannot change its MAC
+	address.  This option may be modified via sysfs only when no
+	slaves are present in the bond.
+
+	This option was added in bonding version 3.2.0.
+
 lacp_rate
 
 	Option specifying the rate in which we'll ask our link partner
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0e198dd..db80f24 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -98,6 +98,7 @@ static char *xmit_hash_policy = NULL;
 static int arp_interval = BOND_LINK_ARP_INTERV;
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS] = { NULL, };
 static char *arp_validate = NULL;
+static int fail_over_mac = 0;
 struct bond_params bonding_defaults;
 
 module_param(max_bonds, int, 0);
@@ -131,6 +132,8 @@ module_param_array(arp_ip_target, charp, NULL, 0);
 MODULE_PARM_DESC(arp_ip_target, "arp targets in n.n.n.n form");
 module_param(arp_validate, charp, 0);
 MODULE_PARM_DESC(arp_validate, "validate src/dst of ARP probes: none (default), active, backup or all");
+module_param(fail_over_mac, int, 0);
+MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to the same MAC.  0 of off (default), 1 for on.");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -1100,7 +1103,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 		/* when bonding does not set the slave MAC address, the bond MAC
 		 * address is the one of the active slave.
 		 */
-		if (new_active && !bond->do_set_mac_addr)
+		if (new_active && bond->params.fail_over_mac)
 			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
 				new_active->dev->addr_len);
 		if (bond->curr_active_slave &&
@@ -1367,16 +1370,16 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (slave_dev->set_mac_address == NULL) {
 		if (bond->slave_cnt == 0) {
 			printk(KERN_WARNING DRV_NAME
-				": %s: Warning: The first slave device you "
-				"specified does not support setting the MAC "
-				"address. This bond MAC address would be that "
-				"of the active slave.\n", bond_dev->name);
-			bond->do_set_mac_addr = 0;
-		} else if (bond->do_set_mac_addr) {
+			       ": %s: Warning: The first slave device "
+			       "specified does not support setting the MAC "
+			       "address. Enabling the fail_over_mac option.",
+			       bond_dev->name);
+			bond->params.fail_over_mac = 1;
+		} else if (!bond->params.fail_over_mac) {
 			printk(KERN_ERR DRV_NAME
-				": %s: Error: The slave device you specified "
-				"does not support setting the MAC addres,."
-				"but this bond uses this practice. \n"
+				": %s: Error: The slave device specified "
+				"does not support setting the MAC address, "
+				"but fail_over_mac is not enabled.\n"
 				, bond_dev->name);
 			res = -EOPNOTSUPP;
 			goto err_undo_flags;
@@ -1401,7 +1404,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 */
 	memcpy(new_slave->perm_hwaddr, slave_dev->dev_addr, ETH_ALEN);
 
-	if (bond->do_set_mac_addr) {
+	if (!bond->params.fail_over_mac) {
 		/*
 		 * Set slave to master's mac address.  The application already
 		 * set the master's mac address to that of the first slave
@@ -1637,7 +1640,7 @@ err_close:
 	dev_close(slave_dev);
 
 err_restore_mac:
-	if (bond->do_set_mac_addr) {
+	if (!bond->params.fail_over_mac) {
 		memcpy(addr.sa_data, new_slave->perm_hwaddr, ETH_ALEN);
 		addr.sa_family = slave_dev->type;
 		dev_set_mac_address(slave_dev, &addr);
@@ -1814,7 +1817,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	/* close slave before restoring its mac address */
 	dev_close(slave_dev);
 
-	if (bond->do_set_mac_addr) {
+	if (!bond->params.fail_over_mac) {
 		/* restore original ("permanent") mac address */
 		memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
 		addr.sa_family = slave_dev->type;
@@ -1935,7 +1938,7 @@ static int bond_release_all(struct net_device *bond_dev)
 		/* close slave before restoring its mac address */
 		dev_close(slave_dev);
 
-		if (bond->do_set_mac_addr) {
+		if (!bond->params.fail_over_mac) {
 			/* restore original ("permanent") mac address*/
 			memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
 			addr.sa_family = slave_dev->type;
@@ -3060,9 +3063,15 @@ static void bond_info_show_master(struct seq_file *seq)
 	curr = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
 
-	seq_printf(seq, "Bonding Mode: %s\n",
+	seq_printf(seq, "Bonding Mode: %s",
 		   bond_mode_name(bond->params.mode));
 
+	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP &&
+	    bond->params.fail_over_mac)
+		seq_printf(seq, " (fail_over_mac)");
+
+	seq_printf(seq, "\n");
+
 	if (bond->params.mode == BOND_MODE_XOR ||
 		bond->params.mode == BOND_MODE_8023AD) {
 		seq_printf(seq, "Transmit Hash Policy: %s (%d)\n",
@@ -3994,8 +4003,12 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 
 	dprintk("bond=%p, name=%s\n", bond, (bond_dev ? bond_dev->name : "None"));
 
-	if (!bond->do_set_mac_addr)
-		return -EOPNOTSUPP;
+	/*
+	 * If fail_over_mac is enabled, do nothing and return success.
+	 * Returning an error causes ifenslave to fail.
+	 */
+	if (bond->params.fail_over_mac)
+		return 0;
 
 	if (!is_valid_ether_addr(sa->sa_data)) {
 		return -EADDRNOTAVAIL;
@@ -4384,10 +4397,6 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 #ifdef CONFIG_PROC_FS
 	bond_create_proc_entry(bond);
 #endif
-
-	/* set do_set_mac_addr to true on startup */
-	bond->do_set_mac_addr = 1;
-
 	list_add_tail(&bond->bond_list, &bond_dev_list);
 
 	return 0;
@@ -4721,6 +4730,11 @@ static int bond_check_params(struct bond_params *params)
 		primary = NULL;
 	}
 
+	if (fail_over_mac && (bond_mode != BOND_MODE_ACTIVEBACKUP))
+		printk(KERN_WARNING DRV_NAME
+		       ": Warning: fail_over_mac only affects "
+		       "active-backup mode.\n");
+
 	/* fill params struct with the proper values */
 	params->mode = bond_mode;
 	params->xmit_policy = xmit_hashtype;
@@ -4732,6 +4746,7 @@ static int bond_check_params(struct bond_params *params)
 	params->use_carrier = use_carrier;
 	params->lacp_fast = lacp_fast;
 	params->primary[0] = 0;
+	params->fail_over_mac = fail_over_mac;
 
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index b5d2a13..80c0c8c 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -568,6 +568,54 @@ static ssize_t bonding_store_arp_validate(struct device *d,
 static DEVICE_ATTR(arp_validate, S_IRUGO | S_IWUSR, bonding_show_arp_validate, bonding_store_arp_validate);
 
 /*
+ * Show and store fail_over_mac.  User only allowed to change the
+ * value when there are no slaves.
+ */
+static ssize_t bonding_show_fail_over_mac(struct device *d, struct device_attribute *attr, char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.fail_over_mac) + 1;
+}
+
+static ssize_t bonding_store_fail_over_mac(struct device *d, struct device_attribute *attr, const char *buf, size_t count)
+{
+	int new_value;
+	int ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (bond->slave_cnt != 0) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Can't alter fail_over_mac with slaves in bond.\n",
+		       bond->dev->name);
+		ret = -EPERM;
+		goto out;
+	}
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: no fail_over_mac value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if ((new_value == 0) || (new_value == 1)) {
+		bond->params.fail_over_mac = new_value;
+		printk(KERN_INFO DRV_NAME ": %s: Setting fail_over_mac to %d.\n",
+		       bond->dev->name, new_value);
+	} else {
+		printk(KERN_INFO DRV_NAME
+		       ": %s: Ignoring invalid fail_over_mac value %d.\n",
+		       bond->dev->name, new_value);
+	}
+out:
+	return ret;
+}
+
+static DEVICE_ATTR(fail_over_mac, S_IRUGO | S_IWUSR, bonding_show_fail_over_mac, bonding_store_fail_over_mac);
+
+/*
  * Show and set the arp timer interval.  There are two tricky bits
  * here.  First, if ARP monitoring is activated, then we must disable
  * MII monitoring.  Second, if the ARP timer isn't running, we must
@@ -1388,6 +1436,7 @@ static DEVICE_ATTR(ad_partner_mac, S_IRUGO, bonding_show_ad_partner_mac, NULL);
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
+	&dev_attr_fail_over_mac.attr,
 	&dev_attr_arp_validate.attr,
 	&dev_attr_arp_interval.attr,
 	&dev_attr_arp_ip_target.attr,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 85e579b..a8bbd56 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.1.3"
-#define DRV_RELDATE	"June 13, 2007"
+#define DRV_VERSION	"3.2.0"
+#define DRV_RELDATE	"September 13, 2007"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
@@ -128,6 +128,7 @@ struct bond_params {
 	int arp_interval;
 	int arp_validate;
 	int use_carrier;
+	int fail_over_mac;
 	int updelay;
 	int downdelay;
 	int lacp_fast;
@@ -186,7 +187,6 @@ struct bonding {
 	struct   timer_list mii_timer;
 	struct   timer_list arp_timer;
 	s8       kill_timers;
-	s8       do_set_mac_addr;
 	s8	 send_grat_arp;
 	s8	 setup_by_slave;
 	struct   net_device_stats stats;
-- 
1.5.3.1

