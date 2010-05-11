From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next-2.6 1/2] bonding: add keep_all parameter
Date: Mon, 10 May 2010 20:29:49 -0400
Message-ID: <20100511002949.GA7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56345 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051Ab0EKA3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 20:29:50 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o4B0ToMi026550
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 10 May 2010 20:29:50 -0400
Received: from gospo.usersys.redhat.com (gospo.rdu.redhat.com [10.11.228.52])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with SMTP id o4B0Tngp008502
	for <netdev@vger.kernel.org>; Mon, 10 May 2010 20:29:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In an effort to suppress duplicate frames on certain bonding modes
(specifically the modes that do not require additional configuration on
the switch or switches connected to the host), code was added in the
generic receive patch in 2.6.16.  The current behavior works quite well
for most users, but there are some times it would be nice to restore old
functionality and allow all frames to make their way up the stack.

This patch adds support for a new module option and sysfs file called
'keep_all' that will restore pre-2.6.16 functionality if the user
desires.  The default value is '0' and retains existing behavior, but
the user can set it to '1' and allow all frames up if desired.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 Documentation/networking/bonding.txt |   15 ++++++++++++
 drivers/net/bonding/bond_main.c      |   15 ++++++++++++
 drivers/net/bonding/bond_sysfs.c     |   43 +++++++++++++++++++++++++++++++++-
 drivers/net/bonding/bonding.h        |    1 +
 include/linux/if.h                   |    1 +
 net/core/dev.c                       |   26 +++++++++++---------
 6 files changed, 88 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 61f516b..d64fd2f 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -399,6 +399,21 @@ fail_over_mac
 	This option was added in bonding version 3.2.0.  The "follow"
 	policy was added in bonding version 3.3.0.
 
+keep_all
+
+	Option to specify whether or not you will keep all frames
+	received on an interface that is a member of a bond.  Right
+	now checking is done to ensure that most frames ultimately
+	classified as duplicates are dropped to keep noise to a
+	minimum.  The feature to drop duplicates was added in kernel
+	version 2.6.16 (bonding driver version 3.0.2) and this will
+	allow that original behavior to be restored if desired.
+
+	A value of 0 (default) will preserve the current behavior and
+	will drop all duplicate frames the bond may receive.  A value
+	of 1 will not attempt to avoid duplicate frames and pass all
+	of them up the stack.
+
 lacp_rate
 
 	Option specifying the rate in which we'll ask our link partner
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5e12462..eb86363 100644
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
 
@@ -4542,6 +4546,9 @@ static void bond_setup(struct net_device *bond_dev)
 	if (bond->params.arp_interval)
 		bond_dev->priv_flags |= IFF_MASTER_ARPMON;
 
+	if (bond->params.keep_all)
+		bond_dev->priv_flags |= IFF_BONDING_KEEP_ALL;
+
 	/* At first, we block adding VLANs. That's the only way to
 	 * prevent problems that occur when adding VLANs over an
 	 * empty bond. The block will be removed once non-challenged
@@ -4756,6 +4763,13 @@ static int bond_check_params(struct bond_params *params)
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
@@ -4926,6 +4940,7 @@ static int bond_check_params(struct bond_params *params)
 	params->primary[0] = 0;
 	params->primary_reselect = primary_reselect_value;
 	params->fail_over_mac = fail_over_mac_value;
+	params->keep_all = keep_all;
 
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index b8bec08..44651ce 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -339,7 +339,6 @@ out:
 
 static DEVICE_ATTR(slaves, S_IRUGO | S_IWUSR, bonding_show_slaves,
 		   bonding_store_slaves);
-
 /*
  * Show and set the bonding mode.  The bond interface must be down to
  * change the mode.
@@ -1472,6 +1471,47 @@ static ssize_t bonding_show_ad_partner_mac(struct device *d,
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
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		pr_err("%s: no keep_all value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+	if ((new_value == 0) || (new_value == 1)) {
+		bond->params.keep_all = new_value;
+		if (bond->params.keep_all)
+			bond->dev->priv_flags |= IFF_BONDING_KEEP_ALL;
+		else
+			bond->dev->priv_flags &= ~IFF_BONDING_KEEP_ALL;
+	} else {
+		pr_info("%s: Ignoring invalid keep_all value %d.\n",
+			bond->dev->name, new_value);
+	}
+out:
+	return count;
+}
+static DEVICE_ATTR(keep_all, S_IRUGO | S_IWUSR,
+		   bonding_show_keep, bonding_store_keep);
+
 
 
 static struct attribute *per_bond_attrs[] = {
@@ -1499,6 +1539,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_ad_actor_key.attr,
 	&dev_attr_ad_partner_key.attr,
 	&dev_attr_ad_partner_mac.attr,
+	&dev_attr_keep_all.attr,
 	NULL,
 };
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 2aa3367..3b7532f 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -131,6 +131,7 @@ struct bond_params {
 	char primary[IFNAMSIZ];
 	int primary_reselect;
 	__be32 arp_targets[BOND_MAX_ARP_TARGETS];
+	int keep_all;
 };
 
 struct bond_parm_tbl {
diff --git a/include/linux/if.h b/include/linux/if.h
index be350e6..e9f6040 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -73,6 +73,7 @@
 #define IFF_DONT_BRIDGE 0x800		/* disallow bridging this ether dev */
 #define IFF_IN_NETPOLL	0x1000		/* whether we are processing netpoll */
 #define IFF_DISABLE_NETPOLL	0x2000	/* disable netpoll at run-time */
+#define IFF_BONDING_KEEP_ALL	0x4000	/* do not drop possible dup frames */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/net/core/dev.c b/net/core/dev.c
index 32611c8..9a9c01d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2758,21 +2758,23 @@ int __skb_bond_should_drop(struct sk_buff *skb, struct net_device *master)
 		skb_bond_set_mac_by_master(skb, master);
 	}
 
-	if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
-		if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
-		    skb->protocol == __cpu_to_be16(ETH_P_ARP))
-			return 0;
+	if (unlikely(!(master->priv_flags & IFF_BONDING_KEEP_ALL))) {
+		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
+			if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
+			    skb->protocol == __cpu_to_be16(ETH_P_ARP))
+				return 0;
 
-		if (master->priv_flags & IFF_MASTER_ALB) {
-			if (skb->pkt_type != PACKET_BROADCAST &&
-			    skb->pkt_type != PACKET_MULTICAST)
+			if (master->priv_flags & IFF_MASTER_ALB) {
+				if (skb->pkt_type != PACKET_BROADCAST &&
+				    skb->pkt_type != PACKET_MULTICAST)
+					return 0;
+			}
+			if (master->priv_flags & IFF_MASTER_8023AD &&
+			    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
 				return 0;
-		}
-		if (master->priv_flags & IFF_MASTER_8023AD &&
-		    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
-			return 0;
 
-		return 1;
+			return 1;
+		}
 	}
 	return 0;
 }
-- 
1.6.2.5

