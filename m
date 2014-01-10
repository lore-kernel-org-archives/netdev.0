From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [RFC net-next 3/3] bonding: convert packets_per_slave to use the new option API
Date: Fri, 10 Jan 2014 14:11:35 +0100
Message-ID: <1389359495-9700-4-git-send-email-nikolay@redhat.com>
References: <1389359495-9700-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23888 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756819AbaAJNQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 08:16:52 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0ADGqkU002158
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 08:16:52 -0500
In-Reply-To: <1389359495-9700-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so packets_per_slave would use the
new bonding option API.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_netlink.c |  4 ++--
 drivers/net/bonding/bond_options.c | 49 +++++++++++++++++++++-----------------
 drivers/net/bonding/bond_options.h |  2 ++
 drivers/net/bonding/bond_sysfs.c   | 17 ++++---------
 drivers/net/bonding/bonding.h      |  2 --
 5 files changed, 36 insertions(+), 38 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 51a9be3..ee01d8f 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -250,8 +250,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		int packets_per_slave =
 			nla_get_u32(data[IFLA_BOND_PACKETS_PER_SLAVE]);
 
-		err = bond_option_packets_per_slave_set(bond,
-							packets_per_slave);
+		err = __bond_opt_intset(bond, BOND_OPT_PACKETS_PER_SLAVE,
+					packets_per_slave);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 4aa752f..88b5338 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -31,6 +31,12 @@ static struct bond_value_tbl bond_mode_tbl[] = {
 	{ NULL,            -1,                     0},
 };
 
+static struct bond_value_tbl bond_pps_tbl[] = {
+	{ "default", 1,         BOND_VALFLAG_DEFAULT},
+	{ "maxval",  USHRT_MAX, BOND_VALFLAG_MAX},
+	{ NULL,      -1,        0},
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -41,6 +47,15 @@ static struct bond_option bond_opts[] = {
 		.values = bond_mode_tbl,
 		.set = bond_option_mode_set
 	},
+	[BOND_OPT_PACKETS_PER_SLAVE] = {
+		.id = BOND_OPT_PACKETS_PER_SLAVE,
+		.name = "packets_per_slave",
+		.desc = "Packets to send per slave in RR mode",
+		.valtype = BOND_OPTVAL_INTEGER,
+		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_ROUNDROBIN)),
+		.values = bond_pps_tbl,
+		.set = bond_option_pps_set
+	},
 	{ }
 };
 
@@ -982,28 +997,6 @@ int bond_option_lp_interval_set(struct bonding *bond, int lp_interval)
 	return 0;
 }
 
-int bond_option_packets_per_slave_set(struct bonding *bond,
-				      int packets_per_slave)
-{
-	if (packets_per_slave < 0 || packets_per_slave > USHRT_MAX) {
-		pr_err("%s: packets_per_slave must be between 0 and %u\n",
-		       bond->dev->name, USHRT_MAX);
-		return -EINVAL;
-	}
-
-	if (bond->params.mode != BOND_MODE_ROUNDROBIN)
-		pr_warn("%s: Warning: packets_per_slave has effect only in balance-rr mode\n",
-			bond->dev->name);
-
-	if (packets_per_slave > 1)
-		bond->params.packets_per_slave =
-			reciprocal_value(packets_per_slave);
-	else
-		bond->params.packets_per_slave = packets_per_slave;
-
-	return 0;
-}
-
 int bond_option_lacp_rate_set(struct bonding *bond, int lacp_rate)
 {
 	if (bond_parm_tbl_lookup(lacp_rate, bond_lacp_tbl) < 0) {
@@ -1054,3 +1047,15 @@ int bond_option_ad_select_set(struct bonding *bond, int ad_select)
 
 	return 0;
 }
+
+int bond_option_pps_set(struct bonding *bond, void *newval)
+{
+	int *new_value = newval;
+
+	if (*new_value > 1)
+		bond->params.packets_per_slave = reciprocal_value(*new_value);
+	else
+		bond->params.packets_per_slave = *new_value;
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 12c4d4f..9a3a647 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -42,6 +42,7 @@ enum {
 /* Option IDs, their bit positions correspond to their IDs */
 enum {
 	BOND_OPT_MODE,
+	BOND_OPT_PACKETS_PER_SLAVE,
 	BOND_OPT_LAST
 };
 
@@ -82,4 +83,5 @@ struct bond_option *bond_opt_get(unsigned int option);
 struct bond_value_tbl *bond_opt_get_val(unsigned int option, int val);
 
 int bond_option_mode_set(struct bonding *bond, void *newval);
+int bond_option_pps_set(struct bonding *bond, void *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 8ce5f4f..2de1bab 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1375,22 +1375,15 @@ static ssize_t bonding_store_packets_per_slave(struct device *d,
 					       const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value, ret;
-
-	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err("%s: no packets_per_slave value specified.\n",
-		       bond->dev->name);
-		return -EINVAL;
-	}
+	int ret;
 
-	if (!rtnl_trylock())
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_PACKETS_PER_SLAVE,
+				   (char *)buf);
+	if (ret == -EAGAIN)
 		return restart_syscall();
-
-	ret = bond_option_packets_per_slave_set(bond, new_value);
-	if (!ret)
+	else if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 50bbd28..88cd7d7 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -463,8 +463,6 @@ int bond_option_all_slaves_active_set(struct bonding *bond,
 				      int all_slaves_active);
 int bond_option_min_links_set(struct bonding *bond, int min_links);
 int bond_option_lp_interval_set(struct bonding *bond, int min_links);
-int bond_option_packets_per_slave_set(struct bonding *bond,
-				      int packets_per_slave);
 int bond_option_lacp_rate_set(struct bonding *bond, int lacp_rate);
 int bond_option_ad_select_set(struct bonding *bond, int ad_select);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
-- 
1.8.1.4
