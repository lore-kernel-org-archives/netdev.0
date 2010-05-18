From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6 2/2] bonding: allow user-controlled output slave selection
Date: Mon, 17 May 2010 18:21:54 -0700
Message-ID: <12958.1274145714@death.nxdomain.ibm.com>
References: <20100511003245.GB7497@gospo.rdu.redhat.com> <17897.1273608579@death.nxdomain.ibm.com> <20100512002725.GA2460@localhost.localdomain> <25238.1273693314@death.nxdomain.ibm.com> <20100512221408.GI7497@gospo.rdu.redhat.com> <20100513171504.GD21535@shamino.rdu.redhat.com> <20100517184508.GD17419@hmsreliant.think-freely.org> <17188.1274124341@death.nxdomain.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:35227 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348Ab0ERBV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 21:21:58 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o4I1BrXC024723
	for <netdev@vger.kernel.org>; Mon, 17 May 2010 19:11:53 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4I1LvNS175524
	for <netdev@vger.kernel.org>; Mon, 17 May 2010 19:21:57 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4I1LuUS015862
	for <netdev@vger.kernel.org>; Mon, 17 May 2010 19:21:57 -0600
In-reply-to: <17188.1274124341@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh <fubar@us.ibm.com> wrote:
[...]
>	For your patch, I'm exploring the idea of not setting
>IFF_SLAVE_INACTIVE on "inactive" slaves for an "all_slaves_active"
>option (I think that's a more descriptive name than "keep_all") instead
>of adding a new KEEP_ALL flag bit to priv_flags.  Did you consider this
>methodology and exclude it for some reason?

	Following up to myself, I coded up approximately what I was
talking about.  This doesn't require the extra priv_flag, and the sysfs
_store is a little more complicated, but this appears to work (testing
with ping -f after clearing the switch's MAC table to induce traffic
flooding).  I didn't change the option name from "keep_all" here, but as
far as the functionality goes, this seems to do what I think you want it
to.

	-J

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5e12462..c80d2ff 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -106,6 +106,7 @@ static int arp_interval = BOND_LINK_ARP_INTERV;
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS];
 static char *arp_validate;
 static char *fail_over_mac;
+static int keep_all	= 0;
 static struct bond_params bonding_defaults;
 
 module_param(max_bonds, int, 0);
@@ -155,6 +156,9 @@ module_param(arp_validate, charp, 0);
 MODULE_PARM_DESC(arp_validate, "validate src/dst of ARP probes: none (default), active, backup or all");
 module_param(fail_over_mac, charp, 0);
 MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to the same MAC.  none (default), active or follow");
+module_param(keep_all, int, 0);
+MODULE_PARM_DESC(keep_all, "Keep all frames received on an interface"
+			   "0 for never (default), 1 for always.");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -4756,6 +4760,13 @@ static int bond_check_params(struct bond_params *params)
 		}
 	}
 
+	if ((keep_all != 0) && (keep_all != 1)) {
+		pr_warning("Warning: keep_all module parameter (%d), "
+			   "not of valid value (0/1), so it was set to "
+			   "0\n", keep_all);
+		keep_all = 0;
+	}
+
 	/* reset values for TLB/ALB */
 	if ((bond_mode == BOND_MODE_TLB) ||
 	    (bond_mode == BOND_MODE_ALB)) {
@@ -4926,6 +4937,7 @@ static int bond_check_params(struct bond_params *params)
 	params->primary[0] = 0;
 	params->primary_reselect = primary_reselect_value;
 	params->fail_over_mac = fail_over_mac_value;
+	params->keep_all = keep_all;
 
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index b8bec08..73b3c03 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -339,7 +339,6 @@ out:
 
 static DEVICE_ATTR(slaves, S_IRUGO | S_IWUSR, bonding_show_slaves,
 		   bonding_store_slaves);
-
 /*
  * Show and set the bonding mode.  The bond interface must be down to
  * change the mode.
@@ -1472,6 +1471,59 @@ static ssize_t bonding_show_ad_partner_mac(struct device *d,
 }
 static DEVICE_ATTR(ad_partner_mac, S_IRUGO, bonding_show_ad_partner_mac, NULL);
 
+/*
+ * Show and set the keep_all flag.
+ */
+static ssize_t bonding_show_keep(struct device *d,
+				 struct device_attribute *attr,
+				 char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.keep_all);
+}
+
+static ssize_t bonding_store_keep(struct device *d,
+				  struct device_attribute *attr,
+				  const char *buf, size_t count)
+{
+	int i, new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+	struct slave *slave;
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		pr_err("%s: no keep_all value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (new_value == bond->params.keep_all)
+		goto out;
+
+	if ((new_value == 0) || (new_value == 1)) {
+		bond->params.keep_all = new_value;
+	} else {
+		pr_info("%s: Ignoring invalid keep_all value %d.\n",
+			bond->dev->name, new_value);
+		ret = -EINVAL;
+		goto out;
+	}
+
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
+static DEVICE_ATTR(keep_all, S_IRUGO | S_IWUSR,
+		   bonding_show_keep, bonding_store_keep);
+
 
 
 static struct attribute *per_bond_attrs[] = {
@@ -1499,6 +1551,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_ad_actor_key.attr,
 	&dev_attr_ad_partner_key.attr,
 	&dev_attr_ad_partner_mac.attr,
+	&dev_attr_keep_all.attr,
 	NULL,
 };
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 2aa3367..ef7969b 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -131,6 +131,7 @@ struct bond_params {
 	char primary[IFNAMSIZ];
 	int primary_reselect;
 	__be32 arp_targets[BOND_MAX_ARP_TARGETS];
+	int keep_all;
 };
 
 struct bond_parm_tbl {
@@ -291,7 +292,8 @@ static inline void bond_set_slave_inactive_flags(struct slave *slave)
 	struct bonding *bond = netdev_priv(slave->dev->master);
 	if (!bond_is_lb(bond))
 		slave->state = BOND_STATE_BACKUP;
-	slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
+	if (!bond->params.keep_all)
+		slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
 	if (slave_do_arp_validate(bond, slave))
 		slave->dev->priv_flags |= IFF_SLAVE_NEEDARP;
 }


---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
