From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 10/25] bonding: convert downdelay to use the new option API
Date: Wed, 22 Jan 2014 14:53:25 +0100
Message-ID: <1390398820-5355-11-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23186 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755707AbaAVNyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:54:02 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDs2DQ022486
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:54:02 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so downdelay would use
the new bonding option API. Also some trivial style fixes.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 39 +++++++++++++++++++-------------------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 13 ++-----------
 drivers/net/bonding/bonding.h      |  1 -
 5 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 9164a5a..f30397e 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -146,7 +146,8 @@ static int bond_changelink(struct net_device *bond_dev,
 	if (data[IFLA_BOND_DOWNDELAY]) {
 		int downdelay = nla_get_u32(data[IFLA_BOND_DOWNDELAY]);
 
-		err = bond_option_downdelay_set(bond, downdelay);
+		bond_opt_initval(&newval, downdelay);
+		err = __bond_opt_set(bond, BOND_OPT_DOWNDELAY, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index df5f007..03514f7 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -135,6 +135,13 @@ static struct bond_option bond_opts[] = {
 		.flags = BOND_OPTFLAG_RAWVAL,
 		.set = bond_option_arp_ip_targets_set
 	},
+	[BOND_OPT_DOWNDELAY] = {
+		.id = BOND_OPT_DOWNDELAY,
+		.name = "downdelay",
+		.desc = "Delay before considering link down, in milliseconds",
+		.values = bond_intmax_tbl,
+		.set = bond_option_downdelay_set
+	},
 	{ }
 };
 
@@ -580,31 +587,25 @@ int bond_option_updelay_set(struct bonding *bond, int updelay)
 	return 0;
 }
 
-int bond_option_downdelay_set(struct bonding *bond, int downdelay)
+int bond_option_downdelay_set(struct bonding *bond,
+			      struct bond_opt_value *newval)
 {
-	if (!(bond->params.miimon)) {
+	if (!bond->params.miimon) {
 		pr_err("%s: Unable to set down delay as MII monitoring is disabled\n",
 		       bond->dev->name);
 		return -EPERM;
 	}
-
-	if (downdelay < 0) {
-		pr_err("%s: Invalid down delay value %d not in range %d-%d; rejected.\n",
-		       bond->dev->name, downdelay, 0, INT_MAX);
-		return -EINVAL;
-	} else {
-		if ((downdelay % bond->params.miimon) != 0) {
-			pr_warn("%s: Warning: down delay (%d) is not a multiple of miimon (%d), delay rounded to %d ms\n",
-				bond->dev->name, downdelay,
-				bond->params.miimon,
-				(downdelay / bond->params.miimon) *
-				bond->params.miimon);
-		}
-		bond->params.downdelay = downdelay / bond->params.miimon;
-		pr_info("%s: Setting down delay to %d.\n",
-			bond->dev->name,
-			bond->params.downdelay * bond->params.miimon);
+	if ((newval->value % bond->params.miimon) != 0) {
+		pr_warn("%s: Warning: down delay (%llu) is not a multiple of miimon (%d), delay rounded to %llu ms\n",
+			bond->dev->name, newval->value,
+			bond->params.miimon,
+			(newval->value / bond->params.miimon) *
+			bond->params.miimon);
 	}
+	bond->params.downdelay = newval->value / bond->params.miimon;
+	pr_info("%s: Setting down delay to %d.\n",
+		bond->dev->name,
+		bond->params.downdelay * bond->params.miimon);
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index da35148..5a3f405 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -46,6 +46,7 @@ enum {
 	BOND_OPT_FAIL_OVER_MAC,
 	BOND_OPT_ARP_INTERVAL,
 	BOND_OPT_ARP_TARGETS,
+	BOND_OPT_DOWNDELAY,
 	BOND_OPT_LAST
 };
 
@@ -121,4 +122,6 @@ int bond_option_arp_interval_set(struct bonding *bond,
 int bond_option_arp_ip_targets_set(struct bonding *bond,
 				   struct bond_opt_value *newval);
 void bond_option_arp_ip_targets_clear(struct bonding *bond);
+int bond_option_downdelay_set(struct bonding *bond,
+			      struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 5eeb3a2..b4f6713 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -501,22 +501,13 @@ static ssize_t bonding_store_downdelay(struct device *d,
 				       struct device_attribute *attr,
 				       const char *buf, size_t count)
 {
-	int new_value, ret;
 	struct bonding *bond = to_bond(d);
+	int ret;
 
-	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err("%s: no down delay value specified.\n", bond->dev->name);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = bond_option_downdelay_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_DOWNDELAY, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(downdelay, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 5a63c0e..6286bb7 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -455,7 +455,6 @@ void bond_netlink_fini(void);
 int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_dev);
 int bond_option_miimon_set(struct bonding *bond, int miimon);
 int bond_option_updelay_set(struct bonding *bond, int updelay);
-int bond_option_downdelay_set(struct bonding *bond, int downdelay);
 int bond_option_use_carrier_set(struct bonding *bond, int use_carrier);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
-- 
1.8.4.2
