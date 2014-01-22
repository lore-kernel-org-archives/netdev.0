From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 06/25] bonding: convert arp_all_targets to use the new option API
Date: Wed, 22 Jan 2014 14:53:21 +0100
Message-ID: <1390398820-5355-7-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755581AbaAVNx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:53:58 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDrvHH013339
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:53:57 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so arp_all_targets would use the
new bonding option API.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c    | 16 ++++++----------
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 30 ++++++++++++++++++------------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 24 +++++++-----------------
 drivers/net/bonding/bonding.h      |  1 -
 6 files changed, 36 insertions(+), 41 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3903c87..103b6af 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -214,12 +214,6 @@ const struct bond_parm_tbl bond_lacp_tbl[] = {
 {	NULL,		-1},
 };
 
-const struct bond_parm_tbl arp_all_targets_tbl[] = {
-{	"any",			BOND_ARP_TARGETS_ANY},
-{	"all",			BOND_ARP_TARGETS_ALL},
-{	NULL,			-1},
-};
-
 const struct bond_parm_tbl fail_over_mac_tbl[] = {
 {	"none",			BOND_FOM_NONE},
 {	"active",		BOND_FOM_ACTIVE},
@@ -4231,13 +4225,15 @@ static int bond_check_params(struct bond_params *params)
 
 	arp_all_targets_value = 0;
 	if (arp_all_targets) {
-		arp_all_targets_value = bond_parse_parm(arp_all_targets,
-							arp_all_targets_tbl);
-
-		if (arp_all_targets_value == -1) {
+		bond_opt_initstr(&newval, arp_all_targets);
+		valptr = bond_opt_parse(bond_opt_get(BOND_OPT_ARP_ALL_TARGETS),
+					&newval);
+		if (!valptr) {
 			pr_err("Error: invalid arp_all_targets_value \"%s\"\n",
 			       arp_all_targets);
 			arp_all_targets_value = 0;
+		} else {
+			arp_all_targets_value = valptr->value;
 		}
 	}
 
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 588730c..ff1e3d3 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -202,7 +202,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		int arp_all_targets =
 			nla_get_u32(data[IFLA_BOND_ARP_ALL_TARGETS]);
 
-		err = bond_option_arp_all_targets_set(bond, arp_all_targets);
+		bond_opt_initval(&newval, arp_all_targets);
+		err = __bond_opt_set(bond, BOND_OPT_ARP_ALL_TARGETS, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index eff68a0..e136e75 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -53,6 +53,12 @@ static struct bond_opt_value bond_arp_validate_tbl[] = {
 	{ NULL,     -1,                       0},
 };
 
+static struct bond_opt_value bond_arp_all_targets_tbl[] = {
+	{ "any", BOND_ARP_TARGETS_ANY, BOND_VALFLAG_DEFAULT},
+	{ "all", BOND_ARP_TARGETS_ALL, 0},
+	{ NULL,  -1,                   0},
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -85,6 +91,13 @@ static struct bond_option bond_opts[] = {
 		.values = bond_arp_validate_tbl,
 		.set = bond_option_arp_validate_set
 	},
+	[BOND_OPT_ARP_ALL_TARGETS] = {
+		.id = BOND_OPT_ARP_ALL_TARGETS,
+		.name = "arp_all_targets",
+		.desc = "fail on any/all arp targets timeout",
+		.values = bond_arp_all_targets_tbl,
+		.set = bond_option_arp_all_targets_set
+	},
 	{ }
 };
 
@@ -767,19 +780,12 @@ int bond_option_arp_validate_set(struct bonding *bond,
 	return 0;
 }
 
-int bond_option_arp_all_targets_set(struct bonding *bond, int arp_all_targets)
+int bond_option_arp_all_targets_set(struct bonding *bond,
+				    struct bond_opt_value *newval)
 {
-	if (bond_parm_tbl_lookup(arp_all_targets, arp_all_targets_tbl) < 0) {
-		pr_err("%s: Ignoring invalid arp_all_targets value %d.\n",
-		       bond->dev->name, arp_all_targets);
-		return -EINVAL;
-	}
-
-	pr_info("%s: setting arp_all_targets to %s (%d).\n",
-		bond->dev->name, arp_all_targets_tbl[arp_all_targets].modename,
-		arp_all_targets);
-
-	bond->params.arp_all_targets = arp_all_targets;
+	pr_info("%s: setting arp_all_targets to %s (%llu).\n",
+		bond->dev->name, newval->string, newval->value);
+	bond->params.arp_all_targets = newval->value;
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 15c6c01..88f8c17 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -42,6 +42,7 @@ enum {
 	BOND_OPT_PACKETS_PER_SLAVE,
 	BOND_OPT_XMIT_HASH,
 	BOND_OPT_ARP_VALIDATE,
+	BOND_OPT_ARP_ALL_TARGETS,
 	BOND_OPT_LAST
 };
 
@@ -108,4 +109,6 @@ int bond_option_xmit_hash_policy_set(struct bonding *bond,
 				     struct bond_opt_value *newval);
 int bond_option_arp_validate_set(struct bonding *bond,
 				 struct bond_opt_value *newval);
+int bond_option_arp_all_targets_set(struct bonding *bond,
+				    struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index e1a4b63..83463fc 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -357,10 +357,12 @@ static ssize_t bonding_show_arp_all_targets(struct device *d,
 					 char *buf)
 {
 	struct bonding *bond = to_bond(d);
-	int value = bond->params.arp_all_targets;
+	struct bond_opt_value *val;
 
-	return sprintf(buf, "%s %d\n", arp_all_targets_tbl[value].modename,
-		       value);
+	val = bond_opt_get_val(BOND_OPT_ARP_ALL_TARGETS,
+			       bond->params.arp_all_targets);
+	return sprintf(buf, "%s %d\n",
+		       val->string, bond->params.arp_all_targets);
 }
 
 static ssize_t bonding_store_arp_all_targets(struct device *d,
@@ -368,24 +370,12 @@ static ssize_t bonding_store_arp_all_targets(struct device *d,
 					  const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value, ret;
-
-	new_value = bond_parse_parm(buf, arp_all_targets_tbl);
-	if (new_value < 0) {
-		pr_err("%s: Ignoring invalid arp_all_targets value %s\n",
-		       bond->dev->name, buf);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
+	int ret;
 
-	ret = bond_option_arp_all_targets_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_ARP_ALL_TARGETS, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
-
 	return ret;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 9af6171..18b948a 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -462,7 +462,6 @@ int bond_option_arp_ip_targets_set(struct bonding *bond, __be32 *targets,
 				   int count);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
-int bond_option_arp_all_targets_set(struct bonding *bond, int arp_all_targets);
 int bond_option_primary_set(struct bonding *bond, const char *primary);
 int bond_option_primary_reselect_set(struct bonding *bond,
 				     int primary_reselect);
-- 
1.8.4.2
