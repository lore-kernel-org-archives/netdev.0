From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 24/25] bonding: convert lp_interval to use the new option API
Date: Wed, 22 Jan 2014 14:53:39 +0100
Message-ID: <1390398820-5355-25-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38483 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755989AbaAVNyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:54:17 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDsGWR018624
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:54:17 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so lp_interval would use
the new bonding option API.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 23 +++++++++++++++--------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 14 ++------------
 drivers/net/bonding/bonding.h      |  1 -
 5 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 1e099c6..a8fa725 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -301,7 +301,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		int lp_interval =
 			nla_get_u32(data[IFLA_BOND_LP_INTERVAL]);
 
-		err = bond_option_lp_interval_set(bond, lp_interval);
+		bond_opt_initval(&newval, lp_interval);
+		err = __bond_opt_set(bond, BOND_OPT_LP_INTERVAL, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 1373093..60d7001 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -118,6 +118,11 @@ static struct bond_opt_value bond_resend_igmp_tbl[] = {
 	{ NULL,      -1,  0}
 };
 
+static struct bond_opt_value bond_lp_interval_tbl[] = {
+	{ "minval",  1,       BOND_VALFLAG_MIN | BOND_VALFLAG_DEFAULT},
+	{ "maxval",  INT_MAX, BOND_VALFLAG_MAX},
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -288,6 +293,13 @@ static struct bond_option bond_opts[] = {
 		.values = bond_resend_igmp_tbl,
 		.set = bond_option_resend_igmp_set
 	},
+	[BOND_OPT_LP_INTERVAL] = {
+		.id = BOND_OPT_LP_INTERVAL,
+		.name = "lp_interval",
+		.desc = "The number of seconds between instances where the bonding driver sends learning packets to each slave's peer switch",
+		.values = bond_lp_interval_tbl,
+		.set = bond_option_lp_interval_set
+	},
 	{ }
 };
 
@@ -1101,15 +1113,10 @@ int bond_option_min_links_set(struct bonding *bond,
 	return 0;
 }
 
-int bond_option_lp_interval_set(struct bonding *bond, int lp_interval)
+int bond_option_lp_interval_set(struct bonding *bond,
+				struct bond_opt_value *newval)
 {
-	if (lp_interval <= 0) {
-		pr_err("%s: lp_interval must be between 1 and %d\n",
-		       bond->dev->name, INT_MAX);
-		return -EINVAL;
-	}
-
-	bond->params.lp_interval = lp_interval;
+	bond->params.lp_interval = newval->value;
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index f0c2cbb..eb3a773 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -60,6 +60,7 @@ enum {
 	BOND_OPT_QUEUE_ID,
 	BOND_OPT_ALL_SLAVES_ACTIVE,
 	BOND_OPT_RESEND_IGMP,
+	BOND_OPT_LP_INTERVAL,
 	BOND_OPT_LAST
 };
 
@@ -162,4 +163,6 @@ int bond_option_all_slaves_active_set(struct bonding *bond,
 				      struct bond_opt_value *newval);
 int bond_option_resend_igmp_set(struct bonding *bond,
 				struct bond_opt_value *newval);
+int bond_option_lp_interval_set(struct bonding *bond,
+				struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 1693ebd..f7bc791 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1070,22 +1070,12 @@ static ssize_t bonding_store_lp_interval(struct device *d,
 					 const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value, ret;
-
-	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err("%s: no lp interval value specified.\n",
-			bond->dev->name);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
+	int ret;
 
-	ret = bond_option_lp_interval_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_LP_INTERVAL, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 1683e40..8032e07 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -454,7 +454,6 @@ int bond_netlink_init(void);
 void bond_netlink_fini(void);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
-int bond_option_lp_interval_set(struct bonding *bond, int min_links);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 const char *bond_slave_link_status(s8 link);
-- 
1.8.4.2
