From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 11/25] bonding: convert updelay to use the new option API
Date: Tue, 21 Jan 2014 15:55:00 +0100
Message-ID: <1390316114-17815-12-git-send-email-nikolay@redhat.com>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36577 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754827AbaAUOz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 09:55:57 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0LEtu0h021175
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 09:55:56 -0500
In-Reply-To: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so updelay would use
the new bonding option API. Also some trivial style fixes.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 39 +++++++++++++++++++-------------------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 14 ++------------
 drivers/net/bonding/bonding.h      |  1 -
 5 files changed, 27 insertions(+), 33 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 089bb1f..a40a2ec 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -140,7 +140,8 @@ static int bond_changelink(struct net_device *bond_dev,
 	if (data[IFLA_BOND_UPDELAY]) {
 		int updelay = nla_get_u32(data[IFLA_BOND_UPDELAY]);
 
-		err = bond_option_updelay_set(bond, updelay);
+		bond_opt_initval(&newval, updelay);
+		err = __bond_opt_set(bond, BOND_OPT_UPDELAY, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index f3449cf..abf6a0d 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -143,6 +143,14 @@ static struct bond_option bond_opts[] = {
 		.values = bond_intmax_tbl,
 		.set = bond_option_downdelay_set
 	},
+	[BOND_OPT_UPDELAY] = {
+		.id = BOND_OPT_UPDELAY,
+		.name = "updelay",
+		.desc = "Delay before considering link up, in milliseconds",
+		.values = bond_intmax_tbl,
+		.set = bond_option_updelay_set
+	},
+
 	{ }
 };
 
@@ -559,31 +567,24 @@ int bond_option_miimon_set(struct bonding *bond, int miimon)
 	return 0;
 }
 
-int bond_option_updelay_set(struct bonding *bond, int updelay)
+int bond_option_updelay_set(struct bonding *bond, struct bond_opt_value *newval)
 {
-	if (!(bond->params.miimon)) {
+	if (!bond->params.miimon) {
 		pr_err("%s: Unable to set up delay as MII monitoring is disabled\n",
 		       bond->dev->name);
 		return -EPERM;
 	}
-
-	if (updelay < 0) {
-		pr_err("%s: Invalid up delay value %d not in range %d-%d; rejected.\n",
-		       bond->dev->name, updelay, 0, INT_MAX);
-		return -EINVAL;
-	} else {
-		if ((updelay % bond->params.miimon) != 0) {
-			pr_warn("%s: Warning: up delay (%d) is not a multiple of miimon (%d), updelay rounded to %d ms\n",
-				bond->dev->name, updelay,
-				bond->params.miimon,
-				(updelay / bond->params.miimon) *
-				bond->params.miimon);
-		}
-		bond->params.updelay = updelay / bond->params.miimon;
-		pr_info("%s: Setting up delay to %d.\n",
-			bond->dev->name,
-			bond->params.updelay * bond->params.miimon);
+	if ((newval->value % bond->params.miimon) != 0) {
+		pr_warn("%s: Warning: up delay (%llu) is not a multiple of miimon (%d), updelay rounded to %llu ms\n",
+			bond->dev->name, newval->value,
+			bond->params.miimon,
+			(newval->value / bond->params.miimon) *
+			bond->params.miimon);
 	}
+	bond->params.updelay = newval->value / bond->params.miimon;
+	pr_info("%s: Setting up delay to %d.\n",
+		bond->dev->name,
+		bond->params.updelay * bond->params.miimon);
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 5a3f405..594046c 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -47,6 +47,7 @@ enum {
 	BOND_OPT_ARP_INTERVAL,
 	BOND_OPT_ARP_TARGETS,
 	BOND_OPT_DOWNDELAY,
+	BOND_OPT_UPDELAY,
 	BOND_OPT_LAST
 };
 
@@ -124,4 +125,6 @@ int bond_option_arp_ip_targets_set(struct bonding *bond,
 void bond_option_arp_ip_targets_clear(struct bonding *bond);
 int bond_option_downdelay_set(struct bonding *bond,
 			      struct bond_opt_value *newval);
+int bond_option_updelay_set(struct bonding *bond,
+			    struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 8eab0b9..7acc1bb 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -528,23 +528,13 @@ static ssize_t bonding_store_updelay(struct device *d,
 				     struct device_attribute *attr,
 				     const char *buf, size_t count)
 {
-	int new_value, ret;
 	struct bonding *bond = to_bond(d);
+	int ret;
 
-	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err("%s: no up delay value specified.\n",
-		bond->dev->name);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = bond_option_updelay_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_UPDELAY, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(updelay, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 93854cc..e8d4e11 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -451,7 +451,6 @@ int bond_netlink_init(void);
 void bond_netlink_fini(void);
 int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_dev);
 int bond_option_miimon_set(struct bonding *bond, int miimon);
-int bond_option_updelay_set(struct bonding *bond, int updelay);
 int bond_option_use_carrier_set(struct bonding *bond, int use_carrier);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
-- 
1.8.4.2
