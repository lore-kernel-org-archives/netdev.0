From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 18/25] bonding: convert primary_reselect to use the new option API
Date: Wed, 22 Jan 2014 14:53:33 +0100
Message-ID: <1390398820-5355-19-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755923AbaAVNyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:54:10 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDsAbl001423
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:54:10 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so primary_reselect would use
the new bonding option API.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c    | 18 ++++++------------
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 30 +++++++++++++++++++-----------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_procfs.c  |  7 +++++--
 drivers/net/bonding/bond_sysfs.c   | 24 ++++++++----------------
 drivers/net/bonding/bonding.h      |  2 --
 7 files changed, 43 insertions(+), 44 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f606e2c..59edf18 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -206,13 +206,6 @@ static int bond_mode	= BOND_MODE_ROUNDROBIN;
 static int xmit_hashtype = BOND_XMIT_POLICY_LAYER2;
 static int lacp_fast;
 
-const struct bond_parm_tbl pri_reselect_tbl[] = {
-{	"always",		BOND_PRI_RESELECT_ALWAYS},
-{	"better",		BOND_PRI_RESELECT_BETTER},
-{	"failure",		BOND_PRI_RESELECT_FAILURE},
-{	NULL,			-1},
-};
-
 /*-------------------------- Forward declarations ---------------------------*/
 
 static int bond_init(struct net_device *bond_dev);
@@ -4248,14 +4241,15 @@ static int bond_check_params(struct bond_params *params)
 	}
 
 	if (primary && primary_reselect) {
-		primary_reselect_value = bond_parse_parm(primary_reselect,
-							 pri_reselect_tbl);
-		if (primary_reselect_value == -1) {
+		bond_opt_initstr(&newval, primary_reselect);
+		valptr = bond_opt_parse(bond_opt_get(BOND_OPT_PRIMARY_RESELECT),
+					&newval);
+		if (!valptr) {
 			pr_err("Error: Invalid primary_reselect \"%s\"\n",
-			       primary_reselect ==
-					NULL ? "NULL" : primary_reselect);
+			       primary_reselect);
 			return -EINVAL;
 		}
+		primary_reselect_value = valptr->value;
 	} else {
 		primary_reselect_value = BOND_PRI_RESELECT_ALWAYS;
 	}
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index b27e09d..709e938 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -236,7 +236,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		int primary_reselect =
 			nla_get_u8(data[IFLA_BOND_PRIMARY_RESELECT]);
 
-		err = bond_option_primary_reselect_set(bond, primary_reselect);
+		bond_opt_initval(&newval, primary_reselect);
+		err = __bond_opt_set(bond, BOND_OPT_PRIMARY_RESELECT, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index f094a31..eaa3d40 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -92,6 +92,13 @@ static struct bond_opt_value bond_num_peer_notif_tbl[] = {
 	{ NULL,      -1,  0}
 };
 
+static struct bond_opt_value bond_primary_reselect_tbl[] = {
+	{ "always",  BOND_PRI_RESELECT_ALWAYS,  BOND_VALFLAG_DEFAULT},
+	{ "better",  BOND_PRI_RESELECT_BETTER,  0},
+	{ "failure", BOND_PRI_RESELECT_FAILURE, 0},
+	{ NULL,      -1},
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -217,6 +224,13 @@ static struct bond_option bond_opts[] = {
 						BIT(BOND_MODE_ALB)),
 		.set = bond_option_primary_set
 	},
+	[BOND_OPT_PRIMARY_RESELECT] = {
+		.id = BOND_OPT_PRIMARY_RESELECT,
+		.name = "primary_reselect",
+		.desc = "Reselect primary slave once it comes up",
+		.values = bond_primary_reselect_tbl,
+		.set = bond_option_primary_reselect_set
+	},
 	{ }
 };
 
@@ -943,18 +957,12 @@ out:
 	return 0;
 }
 
-int bond_option_primary_reselect_set(struct bonding *bond, int primary_reselect)
+int bond_option_primary_reselect_set(struct bonding *bond,
+				     struct bond_opt_value *newval)
 {
-	if (bond_parm_tbl_lookup(primary_reselect, pri_reselect_tbl) < 0) {
-		pr_err("%s: Ignoring invalid primary_reselect value %d.\n",
-		       bond->dev->name, primary_reselect);
-		return -EINVAL;
-	}
-
-	bond->params.primary_reselect = primary_reselect;
-	pr_info("%s: setting primary_reselect to %s (%d).\n",
-		bond->dev->name, pri_reselect_tbl[primary_reselect].modename,
-		primary_reselect);
+	pr_info("%s: setting primary_reselect to %s (%llu).\n",
+		bond->dev->name, newval->string, newval->value);
+	bond->params.primary_reselect = newval->value;
 
 	block_netpoll_tx();
 	write_lock_bh(&bond->curr_slave_lock);
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 6ff83103..1de315c 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -54,6 +54,7 @@ enum {
 	BOND_OPT_NUM_PEER_NOTIF,
 	BOND_OPT_MIIMON,
 	BOND_OPT_PRIMARY,
+	BOND_OPT_PRIMARY_RESELECT,
 	BOND_OPT_LAST
 };
 
@@ -144,4 +145,6 @@ int bond_option_num_peer_notif_set(struct bonding *bond,
 int bond_option_miimon_set(struct bonding *bond, struct bond_opt_value *newval);
 int bond_option_primary_set(struct bonding *bond,
 			    struct bond_opt_value *newval);
+int bond_option_primary_reselect_set(struct bonding *bond,
+				     struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index d28c3d7..3ac20e7 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -97,9 +97,12 @@ static void bond_info_show_master(struct seq_file *seq)
 		seq_printf(seq, "Primary Slave: %s",
 			   (bond->primary_slave) ?
 			   bond->primary_slave->dev->name : "None");
-		if (bond->primary_slave)
+		if (bond->primary_slave) {
+			optval = bond_opt_get_val(BOND_OPT_PRIMARY_RESELECT,
+						  bond->params.primary_reselect);
 			seq_printf(seq, " (primary_reselect %s)",
-		   pri_reselect_tbl[bond->params.primary_reselect].modename);
+				   optval->string);
+		}
 
 		seq_printf(seq, "\nCurrently Active Slave: %s\n",
 			   (curr) ? curr->dev->name : "None");
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 10c58ef..7f307bf 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -729,35 +729,27 @@ static ssize_t bonding_show_primary_reselect(struct device *d,
 					     char *buf)
 {
 	struct bonding *bond = to_bond(d);
+	struct bond_opt_value *val;
+
+	val = bond_opt_get_val(BOND_OPT_PRIMARY_RESELECT,
+			       bond->params.primary_reselect);
 
 	return sprintf(buf, "%s %d\n",
-		       pri_reselect_tbl[bond->params.primary_reselect].modename,
-		       bond->params.primary_reselect);
+		       val->string, bond->params.primary_reselect);
 }
 
 static ssize_t bonding_store_primary_reselect(struct device *d,
 					      struct device_attribute *attr,
 					      const char *buf, size_t count)
 {
-	int new_value, ret;
 	struct bonding *bond = to_bond(d);
+	int ret;
 
-	new_value = bond_parse_parm(buf, pri_reselect_tbl);
-	if (new_value < 0)  {
-		pr_err("%s: Ignoring invalid primary_reselect value %.*s.\n",
-		       bond->dev->name,
-		       (int) strlen(buf) - 1, buf);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = bond_option_primary_reselect_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_PRIMARY_RESELECT,
+				   (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(primary_reselect, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 8916854..afa443d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -456,8 +456,6 @@ int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_
 int bond_option_use_carrier_set(struct bonding *bond, int use_carrier);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
-int bond_option_primary_reselect_set(struct bonding *bond,
-				     int primary_reselect);
 int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
 int bond_option_all_slaves_active_set(struct bonding *bond,
 				      int all_slaves_active);
-- 
1.8.4.2
