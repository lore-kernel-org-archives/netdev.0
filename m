From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [RFC net-next 2/3] bonding: convert mode setting to use the new option API
Date: Fri, 10 Jan 2014 14:11:34 +0100
Message-ID: <1389359495-9700-3-git-send-email-nikolay@redhat.com>
References: <1389359495-9700-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756746AbaAJNQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 08:16:51 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0ADGpG0002154
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 08:16:51 -0500
In-Reply-To: <1389359495-9700-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the bond's mode setting use the new option API and
adds support for dependency printing which relies on having an entry for
the mode option in the bond_opts[] array.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c    | 17 ++++----------
 drivers/net/bonding/bond_netlink.c |  2 +-
 drivers/net/bonding/bond_options.c | 45 ++++++++++++++++++++++----------------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 27 +++++++----------------
 drivers/net/bonding/bonding.h      |  2 --
 6 files changed, 42 insertions(+), 54 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e06c445..e102096 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -215,17 +215,6 @@ const struct bond_parm_tbl bond_lacp_tbl[] = {
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
@@ -3982,14 +3971,16 @@ int bond_parse_parm(const char *buf, const struct bond_parm_tbl *tbl)
 static int bond_check_params(struct bond_params *params)
 {
 	int arp_validate_value, fail_over_mac_value, primary_reselect_value, i;
+	struct bond_value_tbl *valptr;
 	int arp_all_targets_value;
 
 	/*
 	 * Convert string parameters.
 	 */
 	if (mode) {
-		bond_mode = bond_parse_parm(mode, bond_mode_tbl);
-		if (bond_mode == -1) {
+		valptr = bond_opt_parse(bond_opt_get(BOND_OPT_MODE), mode,
+					&bond_mode, true);
+		if (!valptr) {
 			pr_err("Error: Invalid bonding mode \"%s\"\n",
 			       mode == NULL ? "NULL" : mode);
 			return -EINVAL;
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 555c783..51a9be3 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -72,7 +72,7 @@ static int bond_changelink(struct net_device *bond_dev,
 	if (data[IFLA_BOND_MODE]) {
 		int mode = nla_get_u8(data[IFLA_BOND_MODE]);
 
-		err = bond_option_mode_set(bond, mode);
+		err = __bond_opt_intset(bond, BOND_OPT_MODE, mode);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 7765efb..4aa752f 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -20,7 +20,27 @@
 #include <linux/ctype.h>
 #include "bonding.h"
 
+static struct bond_value_tbl bond_mode_tbl[] = {
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
+		.valtype = BOND_OPTVAL_INTEGER,
+		.values = bond_mode_tbl,
+		.set = bond_option_mode_set
+	},
 	{ }
 };
 
@@ -336,29 +356,15 @@ struct bond_option *bond_opt_get(unsigned int option)
 	return &bond_opts[option];
 }
 
-int bond_option_mode_set(struct bonding *bond, int mode)
+int bond_option_mode_set(struct bonding *bond, void *newval)
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
+	int mode = *(int *)newval;
+	struct bond_option *opt;
 
 	if (BOND_NO_USES_ARP(mode) && bond->params.arp_interval) {
+		opt = bond_opt_get(BOND_OPT_MODE);
 		pr_info("%s: %s mode is incompatible with arp monitoring, start mii monitoring\n",
-			bond->dev->name, bond_mode_tbl[mode].modename);
+			bond->dev->name, opt->values[mode].name);
 		/* disable arp monitoring */
 		bond->params.arp_interval = 0;
 		/* set miimon to default value */
@@ -370,6 +376,7 @@ int bond_option_mode_set(struct bonding *bond, int mode)
 	/* don't cache arp_validate between modes */
 	bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
 	bond->params.mode = mode;
+
 	return 0;
 }
 
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index c72ecec..12c4d4f 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -41,6 +41,7 @@ enum {
 
 /* Option IDs, their bit positions correspond to their IDs */
 enum {
+	BOND_OPT_MODE,
 	BOND_OPT_LAST
 };
 
@@ -79,4 +80,6 @@ struct bond_value_tbl *bond_opt_parse(const struct bond_option *opt,
 				      void *bufarg, int *retval, bool string);
 struct bond_option *bond_opt_get(unsigned int option);
 struct bond_value_tbl *bond_opt_get_val(unsigned int option, int val);
+
+int bond_option_mode_set(struct bonding *bond, void *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 011f163..8ce5f4f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -264,37 +264,26 @@ static ssize_t bonding_show_mode(struct device *d,
 				 struct device_attribute *attr, char *buf)
 {
 	struct bonding *bond = to_bond(d);
+	struct bond_value_tbl *val;
 
-	return sprintf(buf, "%s %d\n",
-			bond_mode_tbl[bond->params.mode].modename,
-			bond->params.mode);
+	val = bond_opt_get_val(BOND_OPT_MODE, bond->params.mode);
+
+	return sprintf(buf, "%s %d\n", val->name, bond->params.mode);
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
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_MODE, (char *)buf);
+	if (ret == -EAGAIN)
 		return restart_syscall();
-
-	ret = bond_option_mode_set(bond, new_value);
-	if (!ret) {
-		pr_info("%s: setting mode to %s (%d).\n",
-			bond->dev->name, bond_mode_tbl[new_value].modename,
-			new_value);
+	else if (!ret)
 		ret = count;
-	}
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(mode, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 71e751a..50bbd28 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -439,7 +439,6 @@ void bond_setup(struct net_device *bond_dev);
 unsigned int bond_get_num_tx_queues(void);
 int bond_netlink_init(void);
 void bond_netlink_fini(void);
-int bond_option_mode_set(struct bonding *bond, int mode);
 int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_dev);
 int bond_option_miimon_set(struct bonding *bond, int miimon);
 int bond_option_updelay_set(struct bonding *bond, int updelay);
@@ -549,7 +548,6 @@ static inline int bond_get_targets_ip(__be32 *targets, __be32 ip)
 /* exported from bond_main.c */
 extern int bond_net_id;
 extern const struct bond_parm_tbl bond_lacp_tbl[];
-extern const struct bond_parm_tbl bond_mode_tbl[];
 extern const struct bond_parm_tbl xmit_hashtype_tbl[];
 extern const struct bond_parm_tbl arp_validate_tbl[];
 extern const struct bond_parm_tbl arp_all_targets_tbl[];
-- 
1.8.1.4
