From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next-2.6 1/2][v2] bonding: add all_slaves_active
	parameter
Date: Wed, 2 Jun 2010 14:39:21 -0400
Message-ID: <20100602183921.GK7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13794 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752410Ab0FBSjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 14:39:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


v2: changed parameter name from 'keep_all' to 'all_slaves_active' and
skipped setting slaves to inactive rather than creating a new flag at
Jay's suggestion.

In an effort to suppress duplicate frames on certain bonding modes
(specifically the modes that do not require additional configuration on
the switch or switches connected to the host), code was added in the
generic receive patch in 2.6.16.  The current behavior works quite well
for most users, but there are some times it would be nice to restore old
functionality and allow all frames to make their way up the stack.

This patch adds support for a new module option and sysfs file called
'all_slaves_active' that will restore pre-2.6.16 functionality if the
user desires.  The default value is '0' and retains existing behavior,
but the user can set it to '1' and allow all frames up if desired.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 drivers/net/bonding/bond_main.c  |   13 +++++++++
 drivers/net/bonding/bond_sysfs.c |   52 ++++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h    |    4 ++-
 3 files changed, 68 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ef60244..f22f6bf 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -106,6 +106,7 @@ static int arp_interval = BOND_LINK_ARP_INTERV;
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS];
 static char *arp_validate;
 static char *fail_over_mac;
+static int all_slaves_active = 0;
 static struct bond_params bonding_defaults;
 
 module_param(max_bonds, int, 0);
@@ -155,6 +156,10 @@ module_param(arp_validate, charp, 0);
 MODULE_PARM_DESC(arp_validate, "validate src/dst of ARP probes: none (default), active, backup or all");
 module_param(fail_over_mac, charp, 0);
 MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to the same MAC.  none (default), active or follow");
+module_param(all_slaves_active, int, 0);
+MODULE_PARM_DESC(all_slaves_active, "Keep all frames received on an interface"
+				     "by setting active flag for all slaves.  "
+				     "0 for never (default), 1 for always.");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -4771,6 +4776,13 @@ static int bond_check_params(struct bond_params *params)
 		}
 	}
 
+	if ((all_slaves_active != 0) && (all_slaves_active != 1)) {
+		pr_warning("Warning: all_slaves_active module parameter (%d), "
+			   "not of valid value (0/1), so it was set to "
+			   "0\n", all_slaves_active);
+		all_slaves_active = 0;
+	}
+
 	/* reset values for TLB/ALB */
 	if ((bond_mode == BOND_MODE_TLB) ||
 	    (bond_mode == BOND_MODE_ALB)) {
@@ -4941,6 +4953,7 @@ static int bond_check_params(struct bond_params *params)
 	params->primary[0] = 0;
 	params->primary_reselect = primary_reselect_value;
 	params->fail_over_mac = fail_over_mac_value;
+	params->all_slaves_active = all_slaves_active;
 
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 496ac1e..066311a 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1411,7 +1411,58 @@ static ssize_t bonding_show_ad_partner_mac(struct device *d,
 }
 static DEVICE_ATTR(ad_partner_mac, S_IRUGO, bonding_show_ad_partner_mac, NULL);
 
+/*
+ * Show and set the all_slaves_active flag.
+ */
+static ssize_t bonding_show_slaves_active(struct device *d,
+					  struct device_attribute *attr,
+					  char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.all_slaves_active);
+}
+
+static ssize_t bonding_store_slaves_active(struct device *d,
+					   struct device_attribute *attr,
+					   const char *buf, size_t count)
+{
+	int i, new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+	struct slave *slave;
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		pr_err("%s: no all_slaves_active value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (new_value == bond->params.all_slaves_active)
+		goto out;
+
+	if ((new_value == 0) || (new_value == 1)) {
+		bond->params.all_slaves_active = new_value;
+	} else {
+		pr_info("%s: Ignoring invalid all_slaves_active value %d.\n",
+			bond->dev->name, new_value);
+		ret = -EINVAL;
+		goto out;
+	}
 
+	bond_for_each_slave(bond, slave, i) {
+		if (slave->state == BOND_STATE_BACKUP) {
+			if (new_value)
+				slave->dev->priv_flags &= ~IFF_SLAVE_INACTIVE;
+			else
+				slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
+		}
+	}
+out:
+	return count;
+}
+static DEVICE_ATTR(all_slaves_active, S_IRUGO | S_IWUSR,
+		   bonding_show_slaves_active, bonding_store_slaves_active);
 
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
@@ -1438,6 +1489,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_ad_actor_key.attr,
 	&dev_attr_ad_partner_key.attr,
 	&dev_attr_ad_partner_mac.attr,
+	&dev_attr_all_slaves_active.attr,
 	NULL,
 };
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index da80964..cecdea2 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -131,6 +131,7 @@ struct bond_params {
 	char primary[IFNAMSIZ];
 	int primary_reselect;
 	__be32 arp_targets[BOND_MAX_ARP_TARGETS];
+	int all_slaves_active;
 };
 
 struct bond_parm_tbl {
@@ -290,7 +291,8 @@ static inline void bond_set_slave_inactive_flags(struct slave *slave)
 	struct bonding *bond = netdev_priv(slave->dev->master);
 	if (!bond_is_lb(bond))
 		slave->state = BOND_STATE_BACKUP;
-	slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
+	if (!bond->params.all_slaves_active)
+		slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
 	if (slave_do_arp_validate(bond, slave))
 		slave->dev->priv_flags |= IFF_SLAVE_NEEDARP;
 }
-- 
1.7.0.1

