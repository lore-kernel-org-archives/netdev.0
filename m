From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 19/25] bonding: convert use_carrier to use the new option API
Date: Wed, 22 Jan 2014 14:53:34 +0100
Message-ID: <1390398820-5355-20-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11225 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755856AbaAVNyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:54:11 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDsB4M006641
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:54:11 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so use_carrier would use
the new bonding option API.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 27 ++++++++++++++++++---------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 14 ++------------
 drivers/net/bonding/bonding.h      |  1 -
 5 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 709e938..2175e19 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -156,7 +156,8 @@ static int bond_changelink(struct net_device *bond_dev,
 	if (data[IFLA_BOND_USE_CARRIER]) {
 		int use_carrier = nla_get_u8(data[IFLA_BOND_USE_CARRIER]);
 
-		err = bond_option_use_carrier_set(bond, use_carrier);
+		bond_opt_initval(&newval, use_carrier);
+		err = __bond_opt_set(bond, BOND_OPT_USE_CARRIER, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index eaa3d40..18b1cc0 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -99,6 +99,12 @@ static struct bond_opt_value bond_primary_reselect_tbl[] = {
 	{ NULL,      -1},
 };
 
+static struct bond_opt_value bond_use_carrier_tbl[] = {
+	{ "off", 0,  0},
+	{ "on",  1,  BOND_VALFLAG_DEFAULT},
+	{ NULL,  -1, 0}
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -231,6 +237,13 @@ static struct bond_option bond_opts[] = {
 		.values = bond_primary_reselect_tbl,
 		.set = bond_option_primary_reselect_set
 	},
+	[BOND_OPT_USE_CARRIER] = {
+		.id = BOND_OPT_USE_CARRIER,
+		.name = "use_carrier",
+		.desc = "Use netif_carrier_ok (vs MII ioctls) in miimon",
+		.values = bond_use_carrier_tbl,
+		.set = bond_option_use_carrier_set
+	},
 	{ }
 };
 
@@ -688,16 +701,12 @@ int bond_option_downdelay_set(struct bonding *bond,
 	return 0;
 }
 
-int bond_option_use_carrier_set(struct bonding *bond, int use_carrier)
+int bond_option_use_carrier_set(struct bonding *bond,
+				struct bond_opt_value *newval)
 {
-	if ((use_carrier == 0) || (use_carrier == 1)) {
-		bond->params.use_carrier = use_carrier;
-		pr_info("%s: Setting use_carrier to %d.\n",
-			bond->dev->name, use_carrier);
-	} else {
-		pr_info("%s: Ignoring invalid use_carrier value %d.\n",
-			bond->dev->name, use_carrier);
-	}
+	pr_info("%s: Setting use_carrier to %llu.\n",
+		bond->dev->name, newval->value);
+	bond->params.use_carrier = newval->value;
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 1de315c..229f5c1 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -55,6 +55,7 @@ enum {
 	BOND_OPT_MIIMON,
 	BOND_OPT_PRIMARY,
 	BOND_OPT_PRIMARY_RESELECT,
+	BOND_OPT_USE_CARRIER,
 	BOND_OPT_LAST
 };
 
@@ -147,4 +148,6 @@ int bond_option_primary_set(struct bonding *bond,
 			    struct bond_opt_value *newval);
 int bond_option_primary_reselect_set(struct bonding *bond,
 				     struct bond_opt_value *newval);
+int bond_option_use_carrier_set(struct bonding *bond,
+				struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 7f307bf..0040482 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -772,23 +772,13 @@ static ssize_t bonding_store_carrier(struct device *d,
 				     struct device_attribute *attr,
 				     const char *buf, size_t count)
 {
-	int new_value, ret;
 	struct bonding *bond = to_bond(d);
+	int ret;
 
-	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err("%s: no use_carrier value specified.\n",
-		       bond->dev->name);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = bond_option_use_carrier_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_USE_CARRIER, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(use_carrier, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index afa443d..51f3b0a 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -453,7 +453,6 @@ unsigned int bond_get_num_tx_queues(void);
 int bond_netlink_init(void);
 void bond_netlink_fini(void);
 int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_dev);
-int bond_option_use_carrier_set(struct bonding *bond, int use_carrier);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
 int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
-- 
1.8.4.2
