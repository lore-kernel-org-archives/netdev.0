From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 03/25] bonding: convert packets_per_slave to use the new option API
Date: Wed, 22 Jan 2014 14:53:18 +0100
Message-ID: <1390398820-5355-4-git-send-email-nikolay@redhat.com>
References: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5239 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755537AbaAVNx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:53:56 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0MDrsUR020757
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 08:53:55 -0500
In-Reply-To: <1390398820-5355-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so packets_per_slave would use the
new bonding option API.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v2: rebase on the changes that got in while waiting and use the new code

 drivers/net/bonding/bond_main.c    |  3 ++-
 drivers/net/bonding/bond_netlink.c |  4 ++--
 drivers/net/bonding/bond_options.c | 33 ++++++++++++++++++---------------
 drivers/net/bonding/bond_options.h |  2 ++
 drivers/net/bonding/bond_sysfs.c   | 15 +++------------
 drivers/net/bonding/bonding.h      |  2 --
 6 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7a04f0f..a50577b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4145,7 +4145,8 @@ static int bond_check_params(struct bond_params *params)
 		resend_igmp = BOND_DEFAULT_RESEND_IGMP;
 	}
 
-	if (packets_per_slave < 0 || packets_per_slave > USHRT_MAX) {
+	bond_opt_initval(&newval, packets_per_slave);
+	if (!bond_opt_parse(bond_opt_get(BOND_OPT_PACKETS_PER_SLAVE), &newval)) {
 		pr_warn("Warning: packets_per_slave (%d) should be between 0 and %u resetting to 1\n",
 			packets_per_slave, USHRT_MAX);
 		packets_per_slave = 1;
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index db3f672..8936a91 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -287,8 +287,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		int packets_per_slave =
 			nla_get_u32(data[IFLA_BOND_PACKETS_PER_SLAVE]);
 
-		err = bond_option_packets_per_slave_set(bond,
-							packets_per_slave);
+		bond_opt_initval(&newval, packets_per_slave);
+		err = __bond_opt_set(bond, BOND_OPT_PACKETS_PER_SLAVE, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 5696b2f..6d2a7d9 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -30,6 +30,12 @@ static struct bond_opt_value bond_mode_tbl[] = {
 	{ NULL,            -1,                     0},
 };
 
+static struct bond_opt_value bond_pps_tbl[] = {
+	{ "default", 1,         BOND_VALFLAG_DEFAULT},
+	{ "maxval",  USHRT_MAX, BOND_VALFLAG_MAX},
+	{ NULL,      -1,        0},
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -39,6 +45,14 @@ static struct bond_option bond_opts[] = {
 		.values = bond_mode_tbl,
 		.set = bond_option_mode_set
 	},
+	[BOND_OPT_PACKETS_PER_SLAVE] = {
+		.id = BOND_OPT_PACKETS_PER_SLAVE,
+		.name = "packets_per_slave",
+		.desc = "Packets to send per slave in RR mode",
+		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_ROUNDROBIN)),
+		.values = bond_pps_tbl,
+		.set = bond_option_pps_set
+	},
 	{ }
 };
 
@@ -934,23 +948,12 @@ int bond_option_lp_interval_set(struct bonding *bond, int lp_interval)
 	return 0;
 }
 
-int bond_option_packets_per_slave_set(struct bonding *bond,
-				      int packets_per_slave)
+int bond_option_pps_set(struct bonding *bond, struct bond_opt_value *newval)
 {
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
-	bond->params.packets_per_slave = packets_per_slave;
-	if (packets_per_slave > 0) {
+	bond->params.packets_per_slave = newval->value;
+	if (newval->value > 0) {
 		bond->params.reciprocal_packets_per_slave =
-			reciprocal_value(packets_per_slave);
+			reciprocal_value(newval->value);
 	} else {
 		/* reciprocal_packets_per_slave is unused if
 		 * packets_per_slave is 0 or 1, just initialize it
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 11e6c06..f859076 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -39,6 +39,7 @@ enum {
 /* Option IDs, their bit positions correspond to their IDs */
 enum {
 	BOND_OPT_MODE,
+	BOND_OPT_PACKETS_PER_SLAVE,
 	BOND_OPT_LAST
 };
 
@@ -100,4 +101,5 @@ static inline void __bond_opt_init(struct bond_opt_value *optval,
 #define bond_opt_initstr(optval, str) __bond_opt_init(optval, str, ULLONG_MAX)
 
 int bond_option_mode_set(struct bonding *bond, struct bond_opt_value *newval);
+int bond_option_pps_set(struct bonding *bond, struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 3e537e7..3481584 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1368,22 +1368,13 @@ static ssize_t bonding_store_packets_per_slave(struct device *d,
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
-
-	if (!rtnl_trylock())
-		return restart_syscall();
+	int ret;
 
-	ret = bond_option_packets_per_slave_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_PACKETS_PER_SLAVE,
+				   (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index f8e2cab..f9c8a7a 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -476,8 +476,6 @@ int bond_option_all_slaves_active_set(struct bonding *bond,
 				      int all_slaves_active);
 int bond_option_min_links_set(struct bonding *bond, int min_links);
 int bond_option_lp_interval_set(struct bonding *bond, int min_links);
-int bond_option_packets_per_slave_set(struct bonding *bond,
-				      int packets_per_slave);
 int bond_option_lacp_rate_set(struct bonding *bond, int lacp_rate);
 int bond_option_ad_select_set(struct bonding *bond, int ad_select);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
-- 
1.8.4.2
