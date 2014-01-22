From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 07/25] bonding: convert fail_over_mac to use the new option API
Date: Wed, 22 Jan 2014 14:53:22 +0100
Message-ID: <1390398820-5355-8-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11116 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755584AbaAVNx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:53:59 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDrwsJ018573
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:53:58 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so fail_over_mac would use
the new bonding option API. Also fixes a trivial copy/paste error in
bond_check_params where the wrong variable was used for the error msg.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c    | 18 ++++++------------
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 37 ++++++++++++++++++++-----------------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_procfs.c  |  8 +++++---
 drivers/net/bonding/bond_sysfs.c   | 23 +++++++----------------
 drivers/net/bonding/bonding.h      |  1 -
 7 files changed, 43 insertions(+), 50 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 103b6af..4fe3634 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -214,13 +214,6 @@ const struct bond_parm_tbl bond_lacp_tbl[] = {
 {	NULL,		-1},
 };
 
-const struct bond_parm_tbl fail_over_mac_tbl[] = {
-{	"none",			BOND_FOM_NONE},
-{	"active",		BOND_FOM_ACTIVE},
-{	"follow",		BOND_FOM_FOLLOW},
-{	NULL,			-1},
-};
-
 const struct bond_parm_tbl pri_reselect_tbl[] = {
 {	"always",		BOND_PRI_RESELECT_ALWAYS},
 {	"better",		BOND_PRI_RESELECT_BETTER},
@@ -4280,14 +4273,15 @@ static int bond_check_params(struct bond_params *params)
 	}
 
 	if (fail_over_mac) {
-		fail_over_mac_value = bond_parse_parm(fail_over_mac,
-						      fail_over_mac_tbl);
-		if (fail_over_mac_value == -1) {
+		bond_opt_initstr(&newval, fail_over_mac);
+		valptr = bond_opt_parse(bond_opt_get(BOND_OPT_FAIL_OVER_MAC),
+					&newval);
+		if (!valptr) {
 			pr_err("Error: invalid fail_over_mac \"%s\"\n",
-			       arp_validate == NULL ? "NULL" : arp_validate);
+			       fail_over_mac);
 			return -EINVAL;
 		}
-
+		fail_over_mac_value = valptr->value;
 		if (bond_mode != BOND_MODE_ACTIVEBACKUP)
 			pr_warning("Warning: fail_over_mac only affects active-backup mode.\n");
 	} else {
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index ff1e3d3..efdff6c 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -232,7 +232,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		int fail_over_mac =
 			nla_get_u8(data[IFLA_BOND_FAIL_OVER_MAC]);
 
-		err = bond_option_fail_over_mac_set(bond, fail_over_mac);
+		bond_opt_initval(&newval, fail_over_mac);
+		err = __bond_opt_set(bond, BOND_OPT_FAIL_OVER_MAC, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index e136e75..c73d3ac 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -59,6 +59,13 @@ static struct bond_opt_value bond_arp_all_targets_tbl[] = {
 	{ NULL,  -1,                   0},
 };
 
+static struct bond_opt_value bond_fail_over_mac_tbl[] = {
+	{ "none",   BOND_FOM_NONE,   BOND_VALFLAG_DEFAULT},
+	{ "active", BOND_FOM_ACTIVE, 0},
+	{ "follow", BOND_FOM_FOLLOW, 0},
+	{ NULL,     -1,              0},
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -98,6 +105,14 @@ static struct bond_option bond_opts[] = {
 		.values = bond_arp_all_targets_tbl,
 		.set = bond_option_arp_all_targets_set
 	},
+	[BOND_OPT_FAIL_OVER_MAC] = {
+		.id = BOND_OPT_FAIL_OVER_MAC,
+		.name = "fail_over_mac",
+		.desc = "For active-backup, do not set all slaves to the same MAC",
+		.flags = BOND_OPTFLAG_NOSLAVES,
+		.values = bond_fail_over_mac_tbl,
+		.set = bond_option_fail_over_mac_set
+	},
 	{ }
 };
 
@@ -864,24 +879,12 @@ int bond_option_primary_reselect_set(struct bonding *bond, int primary_reselect)
 	return 0;
 }
 
-int bond_option_fail_over_mac_set(struct bonding *bond, int fail_over_mac)
+int bond_option_fail_over_mac_set(struct bonding *bond,
+				  struct bond_opt_value *newval)
 {
-	if (bond_parm_tbl_lookup(fail_over_mac, fail_over_mac_tbl) < 0) {
-		pr_err("%s: Ignoring invalid fail_over_mac value %d.\n",
-		       bond->dev->name, fail_over_mac);
-		return -EINVAL;
-	}
-
-	if (bond_has_slaves(bond)) {
-		pr_err("%s: Can't alter fail_over_mac with slaves in bond.\n",
-		       bond->dev->name);
-		return -EPERM;
-	}
-
-	bond->params.fail_over_mac = fail_over_mac;
-	pr_info("%s: Setting fail_over_mac to %s (%d).\n",
-		bond->dev->name, fail_over_mac_tbl[fail_over_mac].modename,
-		fail_over_mac);
+	pr_info("%s: Setting fail_over_mac to %s (%llu).\n",
+		bond->dev->name, newval->string, newval->value);
+	bond->params.fail_over_mac = newval->value;
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 88f8c17..e80a031 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -43,6 +43,7 @@ enum {
 	BOND_OPT_XMIT_HASH,
 	BOND_OPT_ARP_VALIDATE,
 	BOND_OPT_ARP_ALL_TARGETS,
+	BOND_OPT_FAIL_OVER_MAC,
 	BOND_OPT_LAST
 };
 
@@ -111,4 +112,6 @@ int bond_option_arp_validate_set(struct bonding *bond,
 				 struct bond_opt_value *newval);
 int bond_option_arp_all_targets_set(struct bonding *bond,
 				    struct bond_opt_value *newval);
+int bond_option_fail_over_mac_set(struct bonding *bond,
+				  struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index edb7c18..1a66310 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -77,9 +77,11 @@ static void bond_info_show_master(struct seq_file *seq)
 		   bond_mode_name(bond->params.mode));
 
 	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP &&
-	    bond->params.fail_over_mac)
-		seq_printf(seq, " (fail_over_mac %s)",
-		   fail_over_mac_tbl[bond->params.fail_over_mac].modename);
+	    bond->params.fail_over_mac) {
+		optval = bond_opt_get_val(BOND_OPT_FAIL_OVER_MAC,
+					  bond->params.fail_over_mac);
+		seq_printf(seq, " (fail_over_mac %s)", optval->string);
+	}
 
 	seq_printf(seq, "\n");
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 83463fc..968c099 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -391,34 +391,25 @@ static ssize_t bonding_show_fail_over_mac(struct device *d,
 					  char *buf)
 {
 	struct bonding *bond = to_bond(d);
+	struct bond_opt_value *val;
 
-	return sprintf(buf, "%s %d\n",
-		       fail_over_mac_tbl[bond->params.fail_over_mac].modename,
-		       bond->params.fail_over_mac);
+	val = bond_opt_get_val(BOND_OPT_FAIL_OVER_MAC,
+			       bond->params.fail_over_mac);
+
+	return sprintf(buf, "%s %d\n", val->string, bond->params.fail_over_mac);
 }
 
 static ssize_t bonding_store_fail_over_mac(struct device *d,
 					   struct device_attribute *attr,
 					   const char *buf, size_t count)
 {
-	int new_value, ret;
 	struct bonding *bond = to_bond(d);
+	int ret;
 
-	new_value = bond_parse_parm(buf, fail_over_mac_tbl);
-	if (new_value < 0) {
-		pr_err("%s: Ignoring invalid fail_over_mac value %s.\n",
-		       bond->dev->name, buf);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = bond_option_fail_over_mac_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_FAIL_OVER_MAC, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 18b948a..86d464d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -465,7 +465,6 @@ int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
 int bond_option_primary_set(struct bonding *bond, const char *primary);
 int bond_option_primary_reselect_set(struct bonding *bond,
 				     int primary_reselect);
-int bond_option_fail_over_mac_set(struct bonding *bond, int fail_over_mac);
 int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
 int bond_option_num_peer_notif_set(struct bonding *bond, int num_peer_notif);
 int bond_option_all_slaves_active_set(struct bonding *bond,
-- 
1.8.4.2
