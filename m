From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 14/25] bonding: convert ad_select to use the new option API
Date: Wed, 22 Jan 2014 14:53:29 +0100
Message-ID: <1390398820-5355-15-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31730 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755856AbaAVNyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:54:06 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDs6KA006628
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:54:06 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so ad_select would use
the new bonding option API.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c    | 21 +++++++--------------
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 37 ++++++++++++++++++++-----------------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_procfs.c  |  4 +++-
 drivers/net/bonding/bond_sysfs.c   | 22 ++++++----------------
 drivers/net/bonding/bonding.h      |  1 -
 7 files changed, 41 insertions(+), 50 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f3bfcaf..8f3f9f0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -214,13 +214,6 @@ const struct bond_parm_tbl pri_reselect_tbl[] = {
 {	NULL,			-1},
 };
 
-struct bond_parm_tbl ad_select_tbl[] = {
-{	"stable",	BOND_AD_STABLE},
-{	"bandwidth",	BOND_AD_BANDWIDTH},
-{	"count",	BOND_AD_COUNT},
-{	NULL,		-1},
-};
-
 /*-------------------------- Forward declarations ---------------------------*/
 
 static int bond_init(struct net_device *bond_dev);
@@ -4032,16 +4025,16 @@ static int bond_check_params(struct bond_params *params)
 	}
 
 	if (ad_select) {
-		params->ad_select = bond_parse_parm(ad_select, ad_select_tbl);
-		if (params->ad_select == -1) {
-			pr_err("Error: Invalid ad_select \"%s\"\n",
-			       ad_select == NULL ? "NULL" : ad_select);
+		bond_opt_initstr(&newval, lacp_rate);
+		valptr = bond_opt_parse(bond_opt_get(BOND_OPT_AD_SELECT),
+					&newval);
+		if (!valptr) {
+			pr_err("Error: Invalid ad_select \"%s\"\n", ad_select);
 			return -EINVAL;
 		}
-
-		if (bond_mode != BOND_MODE_8023AD) {
+		params->ad_select = valptr->value;
+		if (bond_mode != BOND_MODE_8023AD)
 			pr_warning("ad_select param only affects 802.3ad mode\n");
-		}
 	} else {
 		params->ad_select = BOND_AD_STABLE;
 	}
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index a85466c..830203d 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -320,7 +320,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		int ad_select =
 			nla_get_u8(data[IFLA_BOND_AD_SELECT]);
 
-		err = bond_option_ad_select_set(bond, ad_select);
+		bond_opt_initval(&newval, ad_select);
+		err = __bond_opt_set(bond, BOND_OPT_AD_SELECT, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index f882169..081ab9b 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -78,6 +78,13 @@ static struct bond_opt_value bond_lacp_rate_tbl[] = {
 	{ NULL,   -1,           0},
 };
 
+static struct bond_opt_value bond_ad_select_tbl[] = {
+	{ "stable",    BOND_AD_STABLE,    BOND_VALFLAG_DEFAULT},
+	{ "bandwidth", BOND_AD_BANDWIDTH, 0},
+	{ "count",     BOND_AD_COUNT,     0},
+	{ NULL,        -1,                0},
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -171,6 +178,14 @@ static struct bond_option bond_opts[] = {
 		.values = bond_intmax_tbl,
 		.set = bond_option_min_links_set
 	},
+	[BOND_OPT_AD_SELECT] = {
+		.id = BOND_OPT_AD_SELECT,
+		.name = "ad_select",
+		.desc = "803.ad aggregation selection logic",
+		.flags = BOND_OPTFLAG_IFDOWN,
+		.values = bond_ad_select_tbl,
+		.set = bond_option_ad_select_set
+	},
 	{ }
 };
 
@@ -1048,24 +1063,12 @@ int bond_option_lacp_rate_set(struct bonding *bond,
 	return 0;
 }
 
-int bond_option_ad_select_set(struct bonding *bond, int ad_select)
+int bond_option_ad_select_set(struct bonding *bond,
+			      struct bond_opt_value *newval)
 {
-	if (bond_parm_tbl_lookup(ad_select, ad_select_tbl) < 0) {
-		pr_err("%s: Ignoring invalid ad_select value %d.\n",
-		       bond->dev->name, ad_select);
-		return -EINVAL;
-	}
-
-	if (bond->dev->flags & IFF_UP) {
-		pr_err("%s: Unable to update ad_select because interface is up.\n",
-		       bond->dev->name);
-		return -EPERM;
-	}
-
-	bond->params.ad_select = ad_select;
-	pr_info("%s: Setting ad_select to %s (%d).\n",
-		bond->dev->name, ad_select_tbl[ad_select].modename,
-		ad_select);
+	pr_info("%s: Setting ad_select to %s (%llu).\n",
+		bond->dev->name, newval->string, newval->value);
+	bond->params.ad_select = newval->value;
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index cc8edef..53df176 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -50,6 +50,7 @@ enum {
 	BOND_OPT_UPDELAY,
 	BOND_OPT_LACP_RATE,
 	BOND_OPT_MINLINKS,
+	BOND_OPT_AD_SELECT,
 	BOND_OPT_LAST
 };
 
@@ -133,4 +134,6 @@ int bond_option_lacp_rate_set(struct bonding *bond,
 			      struct bond_opt_value *newval);
 int bond_option_min_links_set(struct bonding *bond,
 			      struct bond_opt_value *newval);
+int bond_option_ad_select_set(struct bonding *bond,
+			      struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 1a66310..d28c3d7 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -140,8 +140,10 @@ static void bond_info_show_master(struct seq_file *seq)
 		seq_printf(seq, "LACP rate: %s\n",
 			   (bond->params.lacp_fast) ? "fast" : "slow");
 		seq_printf(seq, "Min links: %d\n", bond->params.min_links);
+		optval = bond_opt_get_val(BOND_OPT_AD_SELECT,
+					  bond->params.ad_select);
 		seq_printf(seq, "Aggregator selection policy (ad_select): %s\n",
-			   ad_select_tbl[bond->params.ad_select].modename);
+			   optval->string);
 
 		if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
 			seq_printf(seq, "bond %s has no active aggregator\n",
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 3ae9bfd..02e493a 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -601,10 +601,11 @@ static ssize_t bonding_show_ad_select(struct device *d,
 				      char *buf)
 {
 	struct bonding *bond = to_bond(d);
+	struct bond_opt_value *val;
 
-	return sprintf(buf, "%s %d\n",
-		ad_select_tbl[bond->params.ad_select].modename,
-		bond->params.ad_select);
+	val = bond_opt_get_val(BOND_OPT_AD_SELECT, bond->params.ad_select);
+
+	return sprintf(buf, "%s %d\n", val->string, bond->params.ad_select);
 }
 
 
@@ -612,24 +613,13 @@ static ssize_t bonding_store_ad_select(struct device *d,
 				       struct device_attribute *attr,
 				       const char *buf, size_t count)
 {
-	int new_value, ret;
 	struct bonding *bond = to_bond(d);
+	int ret;
 
-	new_value = bond_parse_parm(buf, ad_select_tbl);
-	if (new_value < 0) {
-		pr_err("%s: Ignoring invalid ad_select value %.*s.\n",
-		       bond->dev->name, (int)strlen(buf) - 1, buf);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = bond_option_ad_select_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_AD_SELECT, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(ad_select, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index df8c5ae..235fb18 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -465,7 +465,6 @@ int bond_option_num_peer_notif_set(struct bonding *bond, int num_peer_notif);
 int bond_option_all_slaves_active_set(struct bonding *bond,
 				      int all_slaves_active);
 int bond_option_lp_interval_set(struct bonding *bond, int min_links);
-int bond_option_ad_select_set(struct bonding *bond, int ad_select);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 const char *bond_slave_link_status(s8 link);
-- 
1.8.4.2
