From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 04/25] bonding: convert xmit_hash_policy to use the new option API
Date: Tue, 21 Jan 2014 15:54:53 +0100
Message-ID: <1390316114-17815-5-git-send-email-nikolay@redhat.com>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62535 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754827AbaAUOzs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 09:55:48 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0LEtmik008498
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 09:55:48 -0500
In-Reply-To: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so xmit_hash_policy would use the
new bonding option API. Also fix some trivial/style errors.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c    | 18 +++++-------------
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 32 +++++++++++++++++++++-----------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_procfs.c  |  6 ++++--
 drivers/net/bonding/bond_sysfs.c   | 23 ++++++-----------------
 drivers/net/bonding/bonding.h      |  2 --
 7 files changed, 41 insertions(+), 46 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1ac55f1..283afa1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -215,15 +215,6 @@ const struct bond_parm_tbl bond_lacp_tbl[] = {
 {	NULL,		-1},
 };
 
-const struct bond_parm_tbl xmit_hashtype_tbl[] = {
-{	"layer2",		BOND_XMIT_POLICY_LAYER2},
-{	"layer3+4",		BOND_XMIT_POLICY_LAYER34},
-{	"layer2+3",		BOND_XMIT_POLICY_LAYER23},
-{	"encap2+3",		BOND_XMIT_POLICY_ENCAP23},
-{	"encap3+4",		BOND_XMIT_POLICY_ENCAP34},
-{	NULL,			-1},
-};
-
 const struct bond_parm_tbl arp_all_targets_tbl[] = {
 {	"any",			BOND_ARP_TARGETS_ANY},
 {	"all",			BOND_ARP_TARGETS_ALL},
@@ -4037,14 +4028,15 @@ static int bond_check_params(struct bond_params *params)
 			pr_info("xmit_hash_policy param is irrelevant in mode %s\n",
 			       bond_mode_name(bond_mode));
 		} else {
-			xmit_hashtype = bond_parse_parm(xmit_hash_policy,
-							xmit_hashtype_tbl);
-			if (xmit_hashtype == -1) {
+			bond_opt_initstr(&newval, xmit_hash_policy);
+			valptr = bond_opt_parse(bond_opt_get(BOND_OPT_XMIT_HASH),
+						&newval);
+			if (!valptr) {
 				pr_err("Error: Invalid xmit_hash_policy \"%s\"\n",
-				       xmit_hash_policy == NULL ? "NULL" :
 				       xmit_hash_policy);
 				return -EINVAL;
 			}
+			xmit_hashtype = valptr->value;
 		}
 	}
 
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 554097b..bf3e8ea 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -239,7 +239,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		int xmit_hash_policy =
 			nla_get_u8(data[IFLA_BOND_XMIT_HASH_POLICY]);
 
-		err = bond_option_xmit_hash_policy_set(bond, xmit_hash_policy);
+		bond_opt_initval(&newval, xmit_hash_policy);
+		err = __bond_opt_set(bond, BOND_OPT_XMIT_HASH, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index ce003ca..ae5beba 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -37,6 +37,15 @@ static struct bond_opt_value bond_pps_tbl[] = {
 	{ NULL,      -1,        0},
 };
 
+static struct bond_opt_value bond_xmit_hashtype_tbl[] = {
+	{ "layer2",   BOND_XMIT_POLICY_LAYER2, BOND_VALFLAG_DEFAULT},
+	{ "layer3+4", BOND_XMIT_POLICY_LAYER34, 0},
+	{ "layer2+3", BOND_XMIT_POLICY_LAYER23, 0},
+	{ "encap2+3", BOND_XMIT_POLICY_ENCAP23, 0},
+	{ "encap3+4", BOND_XMIT_POLICY_ENCAP34, 0},
+	{ NULL,       -1,                       0},
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -54,6 +63,13 @@ static struct bond_option bond_opts[] = {
 		.values = bond_pps_tbl,
 		.set = bond_option_pps_set
 	},
+	[BOND_OPT_XMIT_HASH] = {
+		.id = BOND_OPT_XMIT_HASH,
+		.name = "xmit_hash_policy",
+		.desc = "balance-xor and 802.3ad hashing method",
+		.values = bond_xmit_hashtype_tbl,
+		.set = bond_option_xmit_hash_policy_set
+	},
 	{ }
 };
 
@@ -861,18 +877,12 @@ int bond_option_fail_over_mac_set(struct bonding *bond, int fail_over_mac)
 	return 0;
 }
 
-int bond_option_xmit_hash_policy_set(struct bonding *bond, int xmit_hash_policy)
+int bond_option_xmit_hash_policy_set(struct bonding *bond,
+				     struct bond_opt_value *newval)
 {
-	if (bond_parm_tbl_lookup(xmit_hash_policy, xmit_hashtype_tbl) < 0) {
-		pr_err("%s: Ignoring invalid xmit_hash_policy value %d.\n",
-		       bond->dev->name, xmit_hash_policy);
-		return -EINVAL;
-	}
-
-	bond->params.xmit_policy = xmit_hash_policy;
-	pr_info("%s: setting xmit hash policy to %s (%d).\n",
-		bond->dev->name,
-		xmit_hashtype_tbl[xmit_hash_policy].modename, xmit_hash_policy);
+	pr_info("%s: setting xmit hash policy to %s (%llu).\n",
+		bond->dev->name, newval->string, newval->value);
+	bond->params.xmit_policy = newval->value;
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index f859076..2578f1b 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -40,6 +40,7 @@ enum {
 enum {
 	BOND_OPT_MODE,
 	BOND_OPT_PACKETS_PER_SLAVE,
+	BOND_OPT_XMIT_HASH,
 	BOND_OPT_LAST
 };
 
@@ -102,4 +103,6 @@ static inline void __bond_opt_init(struct bond_opt_value *optval,
 
 int bond_option_mode_set(struct bonding *bond, struct bond_opt_value *newval);
 int bond_option_pps_set(struct bonding *bond, struct bond_opt_value *newval);
+int bond_option_xmit_hash_policy_set(struct bonding *bond,
+				     struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 8515b344..edb7c18 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -65,6 +65,7 @@ static void bond_info_seq_stop(struct seq_file *seq, void *v)
 static void bond_info_show_master(struct seq_file *seq)
 {
 	struct bonding *bond = seq->private;
+	struct bond_opt_value *optval;
 	struct slave *curr;
 	int i;
 
@@ -84,9 +85,10 @@ static void bond_info_show_master(struct seq_file *seq)
 
 	if (bond->params.mode == BOND_MODE_XOR ||
 		bond->params.mode == BOND_MODE_8023AD) {
+		optval = bond_opt_get_val(BOND_OPT_XMIT_HASH,
+					  bond->params.xmit_policy);
 		seq_printf(seq, "Transmit Hash Policy: %s (%d)\n",
-			xmit_hashtype_tbl[bond->params.xmit_policy].modename,
-			bond->params.xmit_policy);
+			   optval->string, bond->params.xmit_policy);
 	}
 
 	if (USES_PRIMARY(bond->params.mode)) {
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index fbf5174..1967038 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -295,35 +295,24 @@ static ssize_t bonding_show_xmit_hash(struct device *d,
 				      char *buf)
 {
 	struct bonding *bond = to_bond(d);
+	struct bond_opt_value *val;
 
-	return sprintf(buf, "%s %d\n",
-		       xmit_hashtype_tbl[bond->params.xmit_policy].modename,
-		       bond->params.xmit_policy);
+	val = bond_opt_get_val(BOND_OPT_XMIT_HASH, bond->params.xmit_policy);
+
+	return sprintf(buf, "%s %d\n", val->string, bond->params.xmit_policy);
 }
 
 static ssize_t bonding_store_xmit_hash(struct device *d,
 				       struct device_attribute *attr,
 				       const char *buf, size_t count)
 {
-	int new_value, ret;
 	struct bonding *bond = to_bond(d);
+	int ret;
 
-	new_value = bond_parse_parm(buf, xmit_hashtype_tbl);
-	if (new_value < 0)  {
-		pr_err("%s: Ignoring invalid xmit hash policy value %.*s.\n",
-		       bond->dev->name,
-		       (int)strlen(buf) - 1, buf);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = bond_option_xmit_hash_policy_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_XMIT_HASH, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(xmit_hash_policy, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index feecc4e..62431df 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -465,8 +465,6 @@ int bond_option_primary_set(struct bonding *bond, const char *primary);
 int bond_option_primary_reselect_set(struct bonding *bond,
 				     int primary_reselect);
 int bond_option_fail_over_mac_set(struct bonding *bond, int fail_over_mac);
-int bond_option_xmit_hash_policy_set(struct bonding *bond,
-				     int xmit_hash_policy);
 int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
 int bond_option_num_peer_notif_set(struct bonding *bond, int num_peer_notif);
 int bond_option_all_slaves_active_set(struct bonding *bond,
-- 
1.8.4.2
