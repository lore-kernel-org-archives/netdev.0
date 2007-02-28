From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] bonding: make IGMP flooding on active-backup bonds configurable
Date: Wed, 28 Feb 2007 17:23:32 -0500
Message-ID: <20070228222331.GA28813@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60369 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932535AbXB1WYn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 17:24:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A while back the following change was made to the bonding code:

commit df49898a47061e82219c991dfbe9ac6ddf7a866b
Author: John W. Linville <linville@tuxdriver.com>
Date:   Tue Oct 18 21:30:58 2005 -0400

    [PATCH] bonding: cleanup comment for mode 1 IGMP xmit hack
    
    Expand comment explaining MAC address selection for replicated IGMP
    frames transmitted in bonding mode 1 (active-backup).  Also, a small
    whitespace cleanup.
    
    Signed-off-by: John W. Linville <linville@tuxdriver.com>
    Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

In general this patch is good, but this tweaks that feature by allowing
that functionality to be enabled and disabled.  This patch adds a new
module option as well as a sysfs entry.  It sets the default to be the
current behavior so existing users shouldn't notice any difference.



Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 drivers/net/bonding/bond_main.c  |   65 +++++++++++++++++++++++++++++++--------
 drivers/net/bonding/bond_sysfs.c |   46 +++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h    |    1
 include/linux/if_bonding.h       |    3 +
 4 files changed, 102 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a7c8f98..b531d4a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -96,6 +96,7 @@ static char *xmit_hash_policy = NULL;
 static int arp_interval = BOND_LINK_ARP_INTERV;
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS] = { NULL, };
 static char *arp_validate = NULL;
+static char *igmp_flood = NULL;
 struct bond_params bonding_defaults;
 
 module_param(max_bonds, int, 0);
@@ -129,6 +130,8 @@ module_param_array(arp_ip_target, charp, NULL, 0);
 MODULE_PARM_DESC(arp_ip_target, "arp targets in n.n.n.n form");
 module_param(arp_validate, charp, 0);
 MODULE_PARM_DESC(arp_validate, "validate src/dst of ARP probes: none (default), active, backup or all");
+module_param(igmp_flood, charp, 0);
+MODULE_PARM_DESC(igmp_flood, "flood IGMP control traffic on active-backup bonding: yes (default) or no");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -180,6 +183,12 @@ struct bond_parm_tbl arp_validate_tbl[] = {
 {	NULL,			-1},
 };
 
+struct bond_parm_tbl igmp_flood_tbl[] = {
+{	"no",			BOND_IGMP_ACTIVEONLY},
+{	"yes",			BOND_IGMP_ALLMEMBERS},
+{	NULL,			-1},
+};
+
 /*-------------------------- Forward declarations ---------------------------*/
 
 static void bond_send_gratuitous_arp(struct bonding *bond);
@@ -3070,6 +3079,9 @@ static void bond_info_show_slave(struct seq_file *seq, const struct slave *slave
 		   slave->perm_hwaddr[2], slave->perm_hwaddr[3],
 		   slave->perm_hwaddr[4], slave->perm_hwaddr[5]);
 
+	seq_printf(seq, "IGMP Flood: %s\n", (bond->params.igmp_flood) ? 
+					    "yes" : "no");
+						
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		const struct aggregator *agg
 			= SLAVE_AD_INFO(slave).port.aggregator;
@@ -4067,19 +4079,24 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
 	if (!bond->curr_active_slave)
 		goto out;
 
-	/* Xmit IGMP frames on all slaves to ensure rapid fail-over
-	   for multicast traffic on snooping switches */
-	if (skb->protocol == __constant_htons(ETH_P_IP) &&
-	    skb->nh.iph->protocol == IPPROTO_IGMP) {
-		struct slave *slave, *active_slave;
-		int i;
-
-		active_slave = bond->curr_active_slave;
-		bond_for_each_slave_from_to(bond, slave, i, active_slave->next,
-		                            active_slave->prev)
-			if (IS_UP(slave->dev) &&
-			    (slave->link == BOND_LINK_UP))
-				bond_activebackup_xmit_copy(skb, bond, slave);
+	/* Let's make this behavior optional since it causes problems
+	   when the links are connected to different switches. */
+	if (bond->params.igmp_flood) {
+
+		/* Xmit IGMP frames on all slaves to ensure rapid fail-over
+		   for multicast traffic on snooping switches */
+		if (skb->protocol == __constant_htons(ETH_P_IP) &&
+		    skb->nh.iph->protocol == IPPROTO_IGMP) {
+			struct slave *slave, *active_slave;
+			int i;
+
+			active_slave = bond->curr_active_slave;
+			bond_for_each_slave_from_to(bond, slave, i, active_slave->next,
+			                            active_slave->prev)
+				if (IS_UP(slave->dev) &&
+				    (slave->link == BOND_LINK_UP))
+					bond_activebackup_xmit_copy(skb, bond, slave);
+		}
 	}
 
 	res = bond_dev_queue_xmit(bond, skb, bond->curr_active_slave->dev);
@@ -4409,6 +4426,7 @@ int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl)
 static int bond_check_params(struct bond_params *params)
 {
 	int arp_validate_value;
+	int igmp_flood_value;
 
 	/*
 	 * Convert string parameters.
@@ -4636,6 +4654,26 @@ static int bond_check_params(struct bond_params *params)
 	} else
 		arp_validate_value = 0;
 
+	if (igmp_flood) {
+		if (bond_mode != BOND_MODE_ACTIVEBACKUP) {
+			printk(KERN_WARNING DRV_NAME
+		": igmp_flood only supported in active-backup mode\n");
+			return -EINVAL;
+		}
+		igmp_flood_value = bond_parse_parm(igmp_flood,
+						   igmp_flood_tbl);
+
+		if (igmp_flood_value == -1) {
+			printk(KERN_ERR DRV_NAME
+			       ": Error: invalid igmp_flood \"%s\"\n",
+			       igmp_flood == NULL ? "NULL" : igmp_flood);
+			return -EINVAL;
+		}	
+	}
+	else
+		igmp_flood_value = 1;
+
+
 	if (miimon) {
 		printk(KERN_INFO DRV_NAME
 		       ": MII link monitoring set to %d ms\n",
@@ -4687,6 +4725,7 @@ static int bond_check_params(struct bond_params *params)
 	params->use_carrier = use_carrier;
 	params->lacp_fast = lacp_fast;
 	params->primary[0] = 0;
+	params->igmp_flood = igmp_flood_value;
 
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 41aa78b..abb34d5 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -131,6 +131,7 @@ struct bond_params {
 	int updelay;
 	int downdelay;
 	int lacp_fast;
+	int igmp_flood;
 	char primary[IFNAMSIZ];
 	u32 arp_targets[BOND_MAX_ARP_TARGETS];
 };
diff --git a/include/linux/if_bonding.h b/include/linux/if_bonding.h
index 84598fa..3be5598 100644
--- a/include/linux/if_bonding.h
+++ b/include/linux/if_bonding.h
@@ -87,6 +87,9 @@
 #define BOND_XMIT_POLICY_LAYER2		0 /* layer 2 (MAC only), default */
 #define BOND_XMIT_POLICY_LAYER34	1 /* layer 3+4 (IP ^ MAC) */
 
+#define BOND_IGMP_ACTIVEONLY		0
+#define BOND_IGMP_ALLMEMBERS		1
+
 typedef struct ifbond {
 	__s32 bond_mode;
 	__s32 num_slaves;
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index a122baa..6a4d892 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -50,6 +50,7 @@ extern struct bond_parm_tbl bond_mode_tbl[];
 extern struct bond_parm_tbl bond_lacp_tbl[];
 extern struct bond_parm_tbl xmit_hashtype_tbl[];
 extern struct bond_parm_tbl arp_validate_tbl[];
+extern struct bond_parm_tbl igmp_flood_tbl[];
 
 static int expected_refcount = -1;
 static struct class *netdev_class;
@@ -563,6 +564,50 @@ static ssize_t bonding_store_arp_validate(struct device *d,
 static DEVICE_ATTR(arp_validate, S_IRUGO | S_IWUSR, bonding_show_arp_validate, bonding_store_arp_validate);
 
 /*
+ * Show and set igmp_flood.
+ */
+static ssize_t bonding_show_igmp_flood(struct device *d,
+				       struct device_attribute *attr,
+				       char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%s %d\n",
+		       igmp_flood_tbl[bond->params.igmp_flood].modename,
+		       bond->params.igmp_flood) + 1;
+}
+
+static ssize_t bonding_store_igmp_flood(struct device *d,
+					struct device_attribute *attr,
+					const char *buf, size_t count)
+{
+	int new_value;
+	struct bonding *bond = to_bond(d);
+
+	new_value = bond_parse_parm((char *)buf, igmp_flood_tbl);
+	if (new_value < 0) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Ignoring invalid igmp_flood value %s\n",
+		       bond->dev->name, buf);
+		return -EINVAL;
+	}
+	if (new_value && (bond->params.mode != BOND_MODE_ACTIVEBACKUP)) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: igmp_flood only supported in active-backup mode.\n",
+		       bond->dev->name);
+		return -EINVAL;
+	}
+	printk(KERN_INFO DRV_NAME ": %s: setting igmp_flood to %s (%d).\n",
+	       bond->dev->name, igmp_flood_tbl[new_value].modename,
+	       new_value);
+
+	bond->params.igmp_flood = new_value;
+
+	return count;
+}
+
+static DEVICE_ATTR(igmp_flood, S_IRUGO | S_IWUSR, bonding_show_igmp_flood, bonding_store_igmp_flood);
+/*
  * Show and set the arp timer interval.  There are two tricky bits
  * here.  First, if ARP monitoring is activated, then we must disable
  * MII monitoring.  Second, if the ARP timer isn't running, we must
@@ -1387,6 +1432,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
 	&dev_attr_arp_validate.attr,
+	&dev_attr_igmp_flood.attr,
 	&dev_attr_arp_interval.attr,
 	&dev_attr_arp_ip_target.attr,
 	&dev_attr_downdelay.attr,
