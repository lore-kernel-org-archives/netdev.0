From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 05/25] bonding: convert arp_validate to use the new option API
Date: Tue, 21 Jan 2014 15:54:54 +0100
Message-ID: <1390316114-17815-6-git-send-email-nikolay@redhat.com>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2471 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754601AbaAUOzt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 09:55:49 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0LEtnsL027142
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 09:55:49 -0500
In-Reply-To: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so arp_validate would use the
new bonding option API. Also fix some trivial/style errors.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c    | 27 +++++++++++--------------
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 40 +++++++++++++++++++++-----------------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 23 +++++++---------------
 drivers/net/bonding/bonding.h      |  1 -
 6 files changed, 45 insertions(+), 52 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 283afa1..81948d5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -221,14 +221,6 @@ const struct bond_parm_tbl arp_all_targets_tbl[] = {
 {	NULL,			-1},
 };
 
-const struct bond_parm_tbl arp_validate_tbl[] = {
-{	"none",			BOND_ARP_VALIDATE_NONE},
-{	"active",		BOND_ARP_VALIDATE_ACTIVE},
-{	"backup",		BOND_ARP_VALIDATE_BACKUP},
-{	"all",			BOND_ARP_VALIDATE_ALL},
-{	NULL,			-1},
-};
-
 const struct bond_parm_tbl fail_over_mac_tbl[] = {
 {	"none",			BOND_FOM_NONE},
 {	"active",		BOND_FOM_ACTIVE},
@@ -4222,15 +4214,18 @@ static int bond_check_params(struct bond_params *params)
 			return -EINVAL;
 		}
 
-		arp_validate_value = bond_parse_parm(arp_validate,
-						     arp_validate_tbl);
-		if (arp_validate_value == -1) {
+		bond_opt_initstr(&newval, arp_validate);
+		valptr = bond_opt_parse(bond_opt_get(BOND_OPT_ARP_VALIDATE),
+					&newval);
+		if (!valptr) {
 			pr_err("Error: invalid arp_validate \"%s\"\n",
-			       arp_validate == NULL ? "NULL" : arp_validate);
+			       arp_validate);
 			return -EINVAL;
 		}
-	} else
+		arp_validate_value = valptr->value;
+	} else {
 		arp_validate_value = 0;
+	}
 
 	arp_all_targets_value = 0;
 	if (arp_all_targets) {
@@ -4247,10 +4242,10 @@ static int bond_check_params(struct bond_params *params)
 	if (miimon) {
 		pr_info("MII link monitoring set to %d ms\n", miimon);
 	} else if (arp_interval) {
+		valptr = bond_opt_get_val(BOND_OPT_ARP_VALIDATE,
+					  arp_validate_value);
 		pr_info("ARP monitoring set to %d ms, validate %s, with %d target(s):",
-			arp_interval,
-			arp_validate_tbl[arp_validate_value].modename,
-			arp_ip_count);
+			arp_interval, valptr->string, arp_ip_count);
 
 		for (i = 0; i < arp_ip_count; i++)
 			pr_info(" %s", arp_ip_target[i]);
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index bf3e8ea..d5bcf29 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -194,7 +194,8 @@ static int bond_changelink(struct net_device *bond_dev,
 			return -EINVAL;
 		}
 
-		err = bond_option_arp_validate_set(bond, arp_validate);
+		bond_opt_initval(&newval, arp_validate);
+		err = __bond_opt_set(bond, BOND_OPT_ARP_VALIDATE, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index ae5beba..f082b6f 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -46,6 +46,14 @@ static struct bond_opt_value bond_xmit_hashtype_tbl[] = {
 	{ NULL,       -1,                       0},
 };
 
+static struct bond_opt_value bond_arp_validate_tbl[] = {
+	{ "none",   BOND_ARP_VALIDATE_NONE,   BOND_VALFLAG_DEFAULT},
+	{ "active", BOND_ARP_VALIDATE_ACTIVE, 0},
+	{ "backup", BOND_ARP_VALIDATE_BACKUP, 0},
+	{ "all",    BOND_ARP_VALIDATE_ALL,    0},
+	{ NULL,     -1,                       0},
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -70,6 +78,14 @@ static struct bond_option bond_opts[] = {
 		.values = bond_xmit_hashtype_tbl,
 		.set = bond_option_xmit_hash_policy_set
 	},
+	[BOND_OPT_ARP_VALIDATE] = {
+		.id = BOND_OPT_ARP_VALIDATE,
+		.name = "arp_validate",
+		.desc = "validate src/dst of ARP probes",
+		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_ACTIVEBACKUP)),
+		.values = bond_arp_validate_tbl,
+		.set = bond_option_arp_validate_set
+	},
 	{ }
 };
 
@@ -735,31 +751,19 @@ int bond_option_arp_ip_targets_set(struct bonding *bond, __be32 *targets,
 	return ret;
 }
 
-int bond_option_arp_validate_set(struct bonding *bond, int arp_validate)
+int bond_option_arp_validate_set(struct bonding *bond,
+				 struct bond_opt_value *newval)
 {
-	if (bond_parm_tbl_lookup(arp_validate, arp_validate_tbl) < 0) {
-		pr_err("%s: Ignoring invalid arp_validate value %d.\n",
-		       bond->dev->name, arp_validate);
-		return -EINVAL;
-	}
-
-	if (bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
-		pr_err("%s: arp_validate only supported in active-backup mode.\n",
-		       bond->dev->name);
-		return -EINVAL;
-	}
-
-	pr_info("%s: setting arp_validate to %s (%d).\n",
-		bond->dev->name, arp_validate_tbl[arp_validate].modename,
-		arp_validate);
+	pr_info("%s: setting arp_validate to %s (%llu).\n",
+		bond->dev->name, newval->string, newval->value);
 
 	if (bond->dev->flags & IFF_UP) {
-		if (!arp_validate)
+		if (!newval->value)
 			bond->recv_probe = NULL;
 		else if (bond->params.arp_interval)
 			bond->recv_probe = bond_arp_rcv;
 	}
-	bond->params.arp_validate = arp_validate;
+	bond->params.arp_validate = newval->value;
 
 	return 0;
 }
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 2578f1b..15c6c01 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -41,6 +41,7 @@ enum {
 	BOND_OPT_MODE,
 	BOND_OPT_PACKETS_PER_SLAVE,
 	BOND_OPT_XMIT_HASH,
+	BOND_OPT_ARP_VALIDATE,
 	BOND_OPT_LAST
 };
 
@@ -105,4 +106,6 @@ int bond_option_mode_set(struct bonding *bond, struct bond_opt_value *newval);
 int bond_option_pps_set(struct bonding *bond, struct bond_opt_value *newval);
 int bond_option_xmit_hash_policy_set(struct bonding *bond,
 				     struct bond_opt_value *newval);
+int bond_option_arp_validate_set(struct bonding *bond,
+				 struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 1967038..592bb6d 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -326,10 +326,12 @@ static ssize_t bonding_show_arp_validate(struct device *d,
 					 char *buf)
 {
 	struct bonding *bond = to_bond(d);
+	struct bond_opt_value *val;
 
-	return sprintf(buf, "%s %d\n",
-		       arp_validate_tbl[bond->params.arp_validate].modename,
-		       bond->params.arp_validate);
+	val = bond_opt_get_val(BOND_OPT_ARP_VALIDATE,
+			       bond->params.arp_validate);
+
+	return sprintf(buf, "%s %d\n", val->string, bond->params.arp_validate);
 }
 
 static ssize_t bonding_store_arp_validate(struct device *d,
@@ -337,23 +339,12 @@ static ssize_t bonding_store_arp_validate(struct device *d,
 					  const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value, ret;
-
-	new_value = bond_parse_parm(buf, arp_validate_tbl);
-	if (new_value < 0) {
-		pr_err("%s: Ignoring invalid arp_validate value %s\n",
-		       bond->dev->name, buf);
-		return -EINVAL;
-	}
-	if (!rtnl_trylock())
-		return restart_syscall();
+	int ret;
 
-	ret = bond_option_arp_validate_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_ARP_VALIDATE, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
-
 	return ret;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 62431df..339c8cd 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -459,7 +459,6 @@ int bond_option_arp_ip_targets_set(struct bonding *bond, __be32 *targets,
 				   int count);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
-int bond_option_arp_validate_set(struct bonding *bond, int arp_validate);
 int bond_option_arp_all_targets_set(struct bonding *bond, int arp_all_targets);
 int bond_option_primary_set(struct bonding *bond, const char *primary);
 int bond_option_primary_reselect_set(struct bonding *bond,
-- 
1.8.4.2
