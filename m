From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 02/25] bonding: convert mode setting to use the new option API
Date: Wed, 22 Jan 2014 14:53:17 +0100
Message-ID: <1390398820-5355-3-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755279AbaAVNxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:53:54 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDrr1Z020750
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:53:53 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the bond's mode setting use the new option API and
adds support for dependency printing which relies on having an entry for
the mode option in the bond_opts[] array.
Also add the ability to print the mode name when mode dependency fails
and fix some trivial/style errors.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c    | 21 +++++----------
 drivers/net/bonding/bond_netlink.c |  4 ++-
 drivers/net/bonding/bond_options.c | 53 +++++++++++++++++++++-----------------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 27 +++++--------------
 drivers/net/bonding/bonding.h      |  2 --
 6 files changed, 48 insertions(+), 62 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f100bd9..7a04f0f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -214,17 +214,6 @@ const struct bond_parm_tbl bond_lacp_tbl[] = {
 {	NULL,		-1},
 };
 
-const struct bond_parm_tbl bond_mode_tbl[] = {
-{	"balance-rr",		BOND_MODE_ROUNDROBIN},
-{	"active-backup",	BOND_MODE_ACTIVEBACKUP},
-{	"balance-xor",		BOND_MODE_XOR},
-{	"broadcast",		BOND_MODE_BROADCAST},
-{	"802.3ad",		BOND_MODE_8023AD},
-{	"balance-tlb",		BOND_MODE_TLB},
-{	"balance-alb",		BOND_MODE_ALB},
-{	NULL,			-1},
-};
-
 const struct bond_parm_tbl xmit_hashtype_tbl[] = {
 {	"layer2",		BOND_XMIT_POLICY_LAYER2},
 {	"layer3+4",		BOND_XMIT_POLICY_LAYER34},
@@ -4028,18 +4017,20 @@ int bond_parse_parm(const char *buf, const struct bond_parm_tbl *tbl)
 static int bond_check_params(struct bond_params *params)
 {
 	int arp_validate_value, fail_over_mac_value, primary_reselect_value, i;
+	struct bond_opt_value newval, *valptr;
 	int arp_all_targets_value;
 
 	/*
 	 * Convert string parameters.
 	 */
 	if (mode) {
-		bond_mode = bond_parse_parm(mode, bond_mode_tbl);
-		if (bond_mode == -1) {
-			pr_err("Error: Invalid bonding mode \"%s\"\n",
-			       mode == NULL ? "NULL" : mode);
+		bond_opt_initstr(&newval, mode);
+		valptr = bond_opt_parse(bond_opt_get(BOND_OPT_MODE), &newval);
+		if (!valptr) {
+			pr_err("Error: Invalid bonding mode \"%s\"\n", mode);
 			return -EINVAL;
 		}
+		bond_mode = valptr->value;
 	}
 
 	if (xmit_hash_policy) {
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index e852655..db3f672 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -98,6 +98,7 @@ static int bond_changelink(struct net_device *bond_dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct bond_opt_value newval;
 	int miimon = 0;
 	int err;
 
@@ -107,7 +108,8 @@ static int bond_changelink(struct net_device *bond_dev,
 	if (data[IFLA_BOND_MODE]) {
 		int mode = nla_get_u8(data[IFLA_BOND_MODE]);
 
-		err = bond_option_mode_set(bond, mode);
+		bond_opt_initval(&newval, mode);
+		err = __bond_opt_set(bond, BOND_OPT_MODE, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 3ad140b..5696b2f 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -19,7 +19,26 @@
 #include <linux/ctype.h>
 #include "bonding.h"
 
+static struct bond_opt_value bond_mode_tbl[] = {
+	{ "balance-rr",    BOND_MODE_ROUNDROBIN,   BOND_VALFLAG_DEFAULT},
+	{ "active-backup", BOND_MODE_ACTIVEBACKUP, 0},
+	{ "balance-xor",   BOND_MODE_XOR,          0},
+	{ "broadcast",     BOND_MODE_BROADCAST,    0},
+	{ "802.3ad",       BOND_MODE_8023AD,       0},
+	{ "balance-tlb",   BOND_MODE_TLB,          0},
+	{ "balance-alb",   BOND_MODE_ALB,          0},
+	{ NULL,            -1,                     0},
+};
+
 static struct bond_option bond_opts[] = {
+	[BOND_OPT_MODE] = {
+		.id = BOND_OPT_MODE,
+		.name = "mode",
+		.desc = "bond device mode",
+		.flags = BOND_OPTFLAG_NOSLAVES | BOND_OPTFLAG_IFDOWN,
+		.values = bond_mode_tbl,
+		.set = bond_option_mode_set
+	},
 	{ }
 };
 
@@ -160,12 +179,15 @@ static int bond_opt_check_deps(struct bonding *bond,
 static void bond_opt_dep_print(struct bonding *bond,
 			       const struct bond_option *opt)
 {
+	struct bond_opt_value *modeval;
 	struct bond_params *params;
 
 	params = &bond->params;
+	modeval = bond_opt_get_val(BOND_OPT_MODE, params->mode);
 	if (test_bit(params->mode, &opt->unsuppmodes))
-		pr_err("%s: option %s: mode dependency failed\n",
-		       bond->dev->name, opt->name);
+		pr_err("%s: option %s: mode dependency failed, not supported in mode %s(%llu)\n",
+		       bond->dev->name, opt->name,
+		       modeval->string, modeval->value);
 }
 
 static void bond_opt_error_interpret(struct bonding *bond,
@@ -290,29 +312,11 @@ struct bond_option *bond_opt_get(unsigned int option)
 	return &bond_opts[option];
 }
 
-int bond_option_mode_set(struct bonding *bond, int mode)
+int bond_option_mode_set(struct bonding *bond, struct bond_opt_value *newval)
 {
-	if (bond_parm_tbl_lookup(mode, bond_mode_tbl) < 0) {
-		pr_err("%s: Ignoring invalid mode value %d.\n",
-		       bond->dev->name, mode);
-		return -EINVAL;
-	}
-
-	if (bond->dev->flags & IFF_UP) {
-		pr_err("%s: unable to update mode because interface is up.\n",
-		       bond->dev->name);
-		return -EPERM;
-	}
-
-	if (bond_has_slaves(bond)) {
-		pr_err("%s: unable to update mode because bond has slaves.\n",
-			bond->dev->name);
-		return -EPERM;
-	}
-
-	if (BOND_NO_USES_ARP(mode) && bond->params.arp_interval) {
+	if (BOND_NO_USES_ARP(newval->value) && bond->params.arp_interval) {
 		pr_info("%s: %s mode is incompatible with arp monitoring, start mii monitoring\n",
-			bond->dev->name, bond_mode_tbl[mode].modename);
+			bond->dev->name, newval->string);
 		/* disable arp monitoring */
 		bond->params.arp_interval = 0;
 		/* set miimon to default value */
@@ -323,7 +327,8 @@ int bond_option_mode_set(struct bonding *bond, int mode)
 
 	/* don't cache arp_validate between modes */
 	bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
-	bond->params.mode = mode;
+	bond->params.mode = newval->value;
+
 	return 0;
 }
 
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index e20f2eb..11e6c06 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -38,6 +38,7 @@ enum {
 
 /* Option IDs, their bit positions correspond to their IDs */
 enum {
+	BOND_OPT_MODE,
 	BOND_OPT_LAST
 };
 
@@ -97,4 +98,6 @@ static inline void __bond_opt_init(struct bond_opt_value *optval,
 }
 #define bond_opt_initval(optval, value) __bond_opt_init(optval, NULL, value)
 #define bond_opt_initstr(optval, str) __bond_opt_init(optval, str, ULLONG_MAX)
+
+int bond_option_mode_set(struct bonding *bond, struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index c083e9a..3e537e7 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -263,37 +263,24 @@ static ssize_t bonding_show_mode(struct device *d,
 				 struct device_attribute *attr, char *buf)
 {
 	struct bonding *bond = to_bond(d);
+	struct bond_opt_value *val;
 
-	return sprintf(buf, "%s %d\n",
-			bond_mode_tbl[bond->params.mode].modename,
-			bond->params.mode);
+	val = bond_opt_get_val(BOND_OPT_MODE, bond->params.mode);
+
+	return sprintf(buf, "%s %d\n", val->string, bond->params.mode);
 }
 
 static ssize_t bonding_store_mode(struct device *d,
 				  struct device_attribute *attr,
 				  const char *buf, size_t count)
 {
-	int new_value, ret;
 	struct bonding *bond = to_bond(d);
+	int ret;
 
-	new_value = bond_parse_parm(buf, bond_mode_tbl);
-	if (new_value < 0)  {
-		pr_err("%s: Ignoring invalid mode value %.*s.\n",
-		       bond->dev->name, (int)strlen(buf) - 1, buf);
-		return -EINVAL;
-	}
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = bond_option_mode_set(bond, new_value);
-	if (!ret) {
-		pr_info("%s: setting mode to %s (%d).\n",
-			bond->dev->name, bond_mode_tbl[new_value].modename,
-			new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_MODE, (char *)buf);
+	if (!ret)
 		ret = count;
-	}
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(mode, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 8c3c94a..f8e2cab 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -452,7 +452,6 @@ void bond_setup(struct net_device *bond_dev);
 unsigned int bond_get_num_tx_queues(void);
 int bond_netlink_init(void);
 void bond_netlink_fini(void);
-int bond_option_mode_set(struct bonding *bond, int mode);
 int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_dev);
 int bond_option_miimon_set(struct bonding *bond, int miimon);
 int bond_option_updelay_set(struct bonding *bond, int updelay);
@@ -563,7 +562,6 @@ static inline int bond_get_targets_ip(__be32 *targets, __be32 ip)
 /* exported from bond_main.c */
 extern int bond_net_id;
 extern const struct bond_parm_tbl bond_lacp_tbl[];
-extern const struct bond_parm_tbl bond_mode_tbl[];
 extern const struct bond_parm_tbl xmit_hashtype_tbl[];
 extern const struct bond_parm_tbl arp_validate_tbl[];
 extern const struct bond_parm_tbl arp_all_targets_tbl[];
-- 
1.8.4.2
