From: Krisztian Ivancso <github-ivan@ivancso.net>
Subject: bonding lacp port id parameter
Date: Mon, 27 May 2013 01:58:58 +0200
Message-ID: <51A2A1C2.4040407@ivancso.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010705010908090604030507"
Cc: Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhandler.info ([217.116.47.195]:37151 "EHLO mailhandler.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755600Ab3E0ATf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 May 2013 20:19:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010705010908090604030507
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi All,

I would like to introduce a new feature to bonding driver.
It makes possible to attach more Linux boxes (as member) to a dynamic 
LAG port (802.1ax or 802.3ad) on a switch.

The patch adds port id setting feature by lacp_port_id module parameter 
and it's possible to set it by sysfs.

Adding more linux boxes to a LAG makes possible to do load-balancing by 
using port channel load balancing of switch (eg. by source-dest-ip or 
src-ip).

It's essential to set the same MAC address to bonding interface and to 
set different port ids on different Linux boxes for a working solution.

Possible use cases:
1. Redundant DNS servers with same IP address
2. Reverse proxies with same IP address
3. "multi-master" LVS

Beside redundancy it provides scalability, scalability depends on 
hardware capability.
(E.g. a LAG port with 4 members - linux LVS servers - using a Cisco 
switch/router splits traffic to ports equally by src IP (2-2-2-2). If a 
link fails, switch forwards traffic to 3 switch ports (3-3-3). It means 
you can utilize overall bandwith as much as 66% with full redundancy. 
It's better with 16% than using 2 master-slave LVS and you use just 1 IP 
and can handle 100% more peak traffic.)

Using this feature with vPC (virtual portchannel) or similar solution it 
provides a physically redundant service from network devices to servers. 
(Nowadays it's available in cheaper network devices - e.g. distributed 
link aggregation in HP switches.)

-- 
Best regards,
Krisztian IVANCSO
github-ivan@ivancso.net
https://www.ivancso.net

--------------010705010908090604030507
Content-Type: text/x-patch;
 name="bonding_lacp_port_id.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="bonding_lacp_port_id.patch"

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 435984a..bffd8c3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -108,6 +108,7 @@ static char *fail_over_mac;
 static int all_slaves_active = 0;
 static struct bond_params bonding_defaults;
 static int resend_igmp = BOND_DEFAULT_RESEND_IGMP;
+static int lacp_port_id = 1;
 
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -148,7 +149,7 @@ module_param(lacp_rate, charp, 0);
 MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner; "
 			    "0 for slow, 1 for fast");
 module_param(ad_select, charp, 0);
-MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic; "
+MODULE_PARM_DESC(ad_select, "802.3ad aggregation selection logic; "
 			    "0 for stable (default), 1 for bandwidth, "
 			    "2 for count");
 module_param(min_links, int, 0);
@@ -177,6 +178,8 @@ MODULE_PARM_DESC(all_slaves_active, "Keep all frames received on an interface"
 module_param(resend_igmp, int, 0);
 MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on "
 			      "link failure");
+module_param(lacp_port_id, int, 0);
+MODULE_PARM_DESC(lacp_port_id, "802.3ad port id to send to switch in LACPDU");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -1775,7 +1778,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		bond_set_slave_inactive_flags(new_slave);
 		/* if this is the first slave */
 		if (bond->slave_cnt == 1) {
-			SLAVE_AD_INFO(new_slave).id = 1;
+			SLAVE_AD_INFO(new_slave).id = lacp_port_id;
 			/* Initialize AD with the number of times that the AD timer is called in 1 second
 			 * can be called only after the mac address of the bond is set
 			 */
@@ -4561,6 +4564,16 @@ static int bond_check_params(struct bond_params *params)
 		resend_igmp = BOND_DEFAULT_RESEND_IGMP;
 	}
 
+	if (bond_mode == BOND_MODE_8023AD) {
+		/* we set upper limit to 65000 because new slave will increase port
+                   id so we don't want id to overflow */
+		if (lacp_port_id < 1 || lacp_port_id > 65000) {
+			pr_warning("Warning: lacp_port_id (%d) should be between "
+				   "1 and 65000, resetting to 1\n", lacp_port_id);
+			lacp_port_id = 1;
+		}
+	}
+
 	/* reset values for TLB/ALB */
 	if ((bond_mode == BOND_MODE_TLB) ||
 	    (bond_mode == BOND_MODE_ALB)) {
@@ -4734,6 +4747,7 @@ static int bond_check_params(struct bond_params *params)
 	params->all_slaves_active = all_slaves_active;
 	params->resend_igmp = resend_igmp;
 	params->min_links = min_links;
+	params->lacp_port_id = lacp_port_id;
 
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index ad284ba..ef36021 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -129,6 +129,7 @@ static void bond_info_show_master(struct seq_file *seq)
 		seq_printf(seq, "Min links: %d\n", bond->params.min_links);
 		seq_printf(seq, "Aggregator selection policy (ad_select): %s\n",
 			   ad_select_tbl[bond->params.ad_select].modename);
+		seq_printf(seq, "802.3ad starting port id: %d\n", bond->params.lacp_port_id);
 
 		if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
 			seq_printf(seq, "bond %s has no active aggregator\n",
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index aef42f0..caeb868 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -872,6 +872,38 @@ static ssize_t bonding_store_min_links(struct device *d,
 static DEVICE_ATTR(min_links, S_IRUGO | S_IWUSR,
 		   bonding_show_min_links, bonding_store_min_links);
 
+static ssize_t bonding_show_lacp_port_id(struct device *d,
+				      struct device_attribute *attr,
+				      char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.lacp_port_id);
+}
+
+static ssize_t bonding_store_lacp_port_id(struct device *d,
+				       struct device_attribute *attr,
+				       const char *buf, size_t count)
+{
+	struct bonding *bond = to_bond(d);
+	int ret;
+	unsigned int new_value;
+
+	ret = kstrtouint(buf, 0, &new_value);
+	if ((ret < 0) || (new_value < 1) || (new_value > 65000)) {
+		pr_err("%s: Ignoring invalid 802.3ad port id value %s.\n",
+		       bond->dev->name, buf);
+		return -EINVAL;
+	}
+
+	pr_info("%s: Setting 802.3ad port id value to %u\n",
+		bond->dev->name, new_value);
+	bond->params.lacp_port_id = new_value;
+	return count;
+}
+static DEVICE_ATTR(lacp_port_id, S_IRUGO | S_IWUSR,
+		   bonding_show_lacp_port_id, bonding_store_lacp_port_id);
+
 static ssize_t bonding_show_ad_select(struct device *d,
 				      struct device_attribute *attr,
 				      char *buf)
@@ -1664,6 +1696,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_all_slaves_active.attr,
 	&dev_attr_resend_igmp.attr,
 	&dev_attr_min_links.attr,
+	&dev_attr_lacp_port_id.attr,
 	NULL,
 };
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 1aecc37..bc3ca35 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -155,6 +155,7 @@ struct bond_params {
 	int tx_queues;
 	int all_slaves_active;
 	int resend_igmp;
+	int lacp_port_id;
 };
 
 struct bond_parm_tbl {

--------------010705010908090604030507--
