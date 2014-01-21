From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 12/25] bonding: convert lacp_rate to use the new option API
Date: Tue, 21 Jan 2014 15:55:01 +0100
Message-ID: <1390316114-17815-13-git-send-email-nikolay@redhat.com>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18967 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754855AbaAUOz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 09:55:58 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0LEtuCZ030973
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 09:55:57 -0500
In-Reply-To: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so lacp_rate would use
the new bonding option API. Also some trivial/style error fixes.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c    | 15 ++++++-------
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 44 +++++++++++++++++---------------------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 22 ++++++-------------
 drivers/net/bonding/bonding.h      |  1 -
 6 files changed, 37 insertions(+), 51 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9de3d35..dd0778c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -208,12 +208,6 @@ static int bond_mode	= BOND_MODE_ROUNDROBIN;
 static int xmit_hashtype = BOND_XMIT_POLICY_LAYER2;
 static int lacp_fast;
 
-const struct bond_parm_tbl bond_lacp_tbl[] = {
-{	"slow",		AD_LACP_SLOW},
-{	"fast",		AD_LACP_FAST},
-{	NULL,		-1},
-};
-
 const struct bond_parm_tbl pri_reselect_tbl[] = {
 {	"always",		BOND_PRI_RESELECT_ALWAYS},
 {	"better",		BOND_PRI_RESELECT_BETTER},
@@ -4023,12 +4017,15 @@ static int bond_check_params(struct bond_params *params)
 			pr_info("lacp_rate param is irrelevant in mode %s\n",
 				bond_mode_name(bond_mode));
 		} else {
-			lacp_fast = bond_parse_parm(lacp_rate, bond_lacp_tbl);
-			if (lacp_fast == -1) {
+			bond_opt_initstr(&newval, lacp_rate);
+			valptr = bond_opt_parse(bond_opt_get(BOND_OPT_LACP_RATE),
+						&newval);
+			if (!valptr) {
 				pr_err("Error: Invalid lacp rate \"%s\"\n",
-				       lacp_rate == NULL ? "NULL" : lacp_rate);
+				       lacp_rate);
 				return -EINVAL;
 			}
+			lacp_fast = valptr->value;
 		}
 	}
 
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index a40a2ec..7737a91 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -311,7 +311,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		int lacp_rate =
 			nla_get_u8(data[IFLA_BOND_AD_LACP_RATE]);
 
-		err = bond_option_lacp_rate_set(bond, lacp_rate);
+		bond_opt_initval(&newval, lacp_rate);
+		err = __bond_opt_set(bond, BOND_OPT_LACP_RATE, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index abf6a0d..01cbc7f 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -73,6 +73,12 @@ static struct bond_opt_value bond_intmax_tbl[] = {
 	{ "maxval",  INT_MAX, BOND_VALFLAG_MAX},
 };
 
+static struct bond_opt_value bond_lacp_rate_tbl[] = {
+	{ "slow", AD_LACP_SLOW, 0},
+	{ "fast", AD_LACP_FAST, 0},
+	{ NULL,   -1,           0},
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -150,7 +156,15 @@ static struct bond_option bond_opts[] = {
 		.values = bond_intmax_tbl,
 		.set = bond_option_updelay_set
 	},
-
+	[BOND_OPT_LACP_RATE] = {
+		.id = BOND_OPT_LACP_RATE,
+		.name = "lacp_rate",
+		.desc = "LACPDU tx rate to request from 802.3ad partner",
+		.flags = BOND_OPTFLAG_IFDOWN,
+		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_8023AD)),
+		.values = bond_lacp_rate_tbl,
+		.set = bond_option_lacp_rate_set
+	},
 	{ }
 };
 
@@ -999,31 +1013,13 @@ int bond_option_lp_interval_set(struct bonding *bond, int lp_interval)
 	return 0;
 }
 
-int bond_option_lacp_rate_set(struct bonding *bond, int lacp_rate)
+int bond_option_lacp_rate_set(struct bonding *bond,
+			      struct bond_opt_value *newval)
 {
-	if (bond_parm_tbl_lookup(lacp_rate, bond_lacp_tbl) < 0) {
-		pr_err("%s: Ignoring invalid LACP rate value %d.\n",
-		       bond->dev->name, lacp_rate);
-		return -EINVAL;
-	}
-
-	if (bond->dev->flags & IFF_UP) {
-		pr_err("%s: Unable to update LACP rate because interface is up.\n",
-		       bond->dev->name);
-		return -EPERM;
-	}
-
-	if (bond->params.mode != BOND_MODE_8023AD) {
-		pr_err("%s: Unable to update LACP rate because bond is not in 802.3ad mode.\n",
-		       bond->dev->name);
-		return -EPERM;
-	}
-
-	bond->params.lacp_fast = lacp_rate;
+	pr_info("%s: Setting LACP rate to %s (%llu).\n",
+		bond->dev->name, newval->string, newval->value);
+	bond->params.lacp_fast = newval->value;
 	bond_3ad_update_lacp_rate(bond);
-	pr_info("%s: Setting LACP rate to %s (%d).\n",
-		bond->dev->name, bond_lacp_tbl[lacp_rate].modename,
-		lacp_rate);
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 594046c..7ee1a78 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -48,6 +48,7 @@ enum {
 	BOND_OPT_ARP_TARGETS,
 	BOND_OPT_DOWNDELAY,
 	BOND_OPT_UPDELAY,
+	BOND_OPT_LACP_RATE,
 	BOND_OPT_LAST
 };
 
@@ -127,4 +128,6 @@ int bond_option_downdelay_set(struct bonding *bond,
 			      struct bond_opt_value *newval);
 int bond_option_updelay_set(struct bonding *bond,
 			    struct bond_opt_value *newval);
+int bond_option_lacp_rate_set(struct bonding *bond,
+			      struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 7acc1bb..98288dc 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -549,10 +549,11 @@ static ssize_t bonding_show_lacp(struct device *d,
 				 char *buf)
 {
 	struct bonding *bond = to_bond(d);
+	struct bond_opt_value *val;
 
-	return sprintf(buf, "%s %d\n",
-		bond_lacp_tbl[bond->params.lacp_fast].modename,
-		bond->params.lacp_fast);
+	val = bond_opt_get_val(BOND_OPT_LACP_RATE, bond->params.lacp_fast);
+
+	return sprintf(buf, "%s %d\n", val->string, bond->params.lacp_fast);
 }
 
 static ssize_t bonding_store_lacp(struct device *d,
@@ -560,23 +561,12 @@ static ssize_t bonding_store_lacp(struct device *d,
 				  const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value, ret;
-
-	new_value = bond_parse_parm(buf, bond_lacp_tbl);
-	if (new_value < 0) {
-		pr_err("%s: Ignoring invalid LACP rate value %.*s.\n",
-		       bond->dev->name, (int)strlen(buf) - 1, buf);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
+	int ret;
 
-	ret = bond_option_lacp_rate_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_LACP_RATE, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index e8d4e11..05f4aa0 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -463,7 +463,6 @@ int bond_option_all_slaves_active_set(struct bonding *bond,
 				      int all_slaves_active);
 int bond_option_min_links_set(struct bonding *bond, int min_links);
 int bond_option_lp_interval_set(struct bonding *bond, int min_links);
-int bond_option_lacp_rate_set(struct bonding *bond, int lacp_rate);
 int bond_option_ad_select_set(struct bonding *bond, int ad_select);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
-- 
1.8.4.2
