From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 16/25] bonding: convert miimon to use the new option API
Date: Tue, 21 Jan 2014 15:55:05 +0100
Message-ID: <1390316114-17815-17-git-send-email-nikolay@redhat.com>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754858AbaAUO4B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 09:56:01 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0LEu0ud031007
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 09:56:01 -0500
In-Reply-To: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so miimon would use
the new bonding option API. The "default" definition has been removed as
it was 0.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c    |  9 ++++-----
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 25 ++++++++++++++-----------
 drivers/net/bonding/bond_options.h |  2 ++
 drivers/net/bonding/bond_sysfs.c   | 14 ++------------
 drivers/net/bonding/bonding.h      |  1 -
 6 files changed, 24 insertions(+), 30 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7335adf..5df75fc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -87,12 +87,11 @@
 /*---------------------------- Module parameters ----------------------------*/
 
 /* monitor all links that often (in milliseconds). <=0 disables monitoring */
-#define BOND_LINK_MON_INTERV	0
 
 static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
 static int tx_queues	= BOND_DEFAULT_TX_QUEUES;
 static int num_peer_notif = 1;
-static int miimon	= BOND_LINK_MON_INTERV;
+static int miimon;
 static int updelay;
 static int downdelay;
 static int use_carrier	= 1;
@@ -4044,9 +4043,9 @@ static int bond_check_params(struct bond_params *params)
 	}
 
 	if (miimon < 0) {
-		pr_warning("Warning: miimon module parameter (%d), not in range 0-%d, so it was reset to %d\n",
-			   miimon, INT_MAX, BOND_LINK_MON_INTERV);
-		miimon = BOND_LINK_MON_INTERV;
+		pr_warning("Warning: miimon module parameter (%d), not in range 0-%d, so it was reset to 0\n",
+			   miimon, INT_MAX);
+		miimon = 0;
 	}
 
 	if (updelay < 0) {
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index cbf1bb0..d6d4aa7 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -133,7 +133,8 @@ static int bond_changelink(struct net_device *bond_dev,
 	if (data[IFLA_BOND_MIIMON]) {
 		miimon = nla_get_u32(data[IFLA_BOND_MIIMON]);
 
-		err = bond_option_miimon_set(bond, miimon);
+		bond_opt_initval(&newval, miimon);
+		err = __bond_opt_set(bond, BOND_OPT_MIIMON, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 4a10a93..b48c9b6 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -201,6 +201,13 @@ static struct bond_option bond_opts[] = {
 		.values = bond_num_peer_notif_tbl,
 		.set = bond_option_num_peer_notif_set
 	},
+	[BOND_OPT_MIIMON] = {
+		.id = BOND_OPT_MIIMON,
+		.name = "miimon",
+		.desc = "Link check interval in milliseconds",
+		.values = bond_intmax_tbl,
+		.set = bond_option_miimon_set
+	},
 	{ }
 };
 
@@ -576,16 +583,11 @@ int bond_option_active_slave_set(struct bonding *bond,
 	return ret;
 }
 
-int bond_option_miimon_set(struct bonding *bond, int miimon)
+int bond_option_miimon_set(struct bonding *bond, struct bond_opt_value *newval)
 {
-	if (miimon < 0) {
-		pr_err("%s: Invalid miimon value %d not in range %d-%d; rejected.\n",
-		       bond->dev->name, miimon, 0, INT_MAX);
-		return -EINVAL;
-	}
-	pr_info("%s: Setting MII monitoring interval to %d.\n",
-		bond->dev->name, miimon);
-	bond->params.miimon = miimon;
+	pr_info("%s: Setting MII monitoring interval to %llu.\n",
+		bond->dev->name, newval->value);
+	bond->params.miimon = newval->value;
 	if (bond->params.updelay)
 		pr_info("%s: Note: Updating updelay (to %d) since it is a multiple of the miimon value.\n",
 			bond->dev->name,
@@ -594,7 +596,7 @@ int bond_option_miimon_set(struct bonding *bond, int miimon)
 		pr_info("%s: Note: Updating downdelay (to %d) since it is a multiple of the miimon value.\n",
 			bond->dev->name,
 			bond->params.downdelay * bond->params.miimon);
-	if (miimon && bond->params.arp_interval) {
+	if (newval->value && bond->params.arp_interval) {
 		pr_info("%s: MII monitoring cannot be used with ARP monitoring. Disabling ARP monitoring...\n",
 			bond->dev->name);
 		bond->params.arp_interval = 0;
@@ -607,13 +609,14 @@ int bond_option_miimon_set(struct bonding *bond, int miimon)
 		 * timer will get fired off when the open function
 		 * is called.
 		 */
-		if (!miimon) {
+		if (!newval->value) {
 			cancel_delayed_work_sync(&bond->mii_work);
 		} else {
 			cancel_delayed_work_sync(&bond->arp_work);
 			queue_delayed_work(bond->wq, &bond->mii_work, 0);
 		}
 	}
+
 	return 0;
 }
 
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 014a359..90f00c6 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -52,6 +52,7 @@ enum {
 	BOND_OPT_MINLINKS,
 	BOND_OPT_AD_SELECT,
 	BOND_OPT_NUM_PEER_NOTIF,
+	BOND_OPT_MIIMON,
 	BOND_OPT_LAST
 };
 
@@ -139,4 +140,5 @@ int bond_option_ad_select_set(struct bonding *bond,
 			      struct bond_opt_value *newval);
 int bond_option_num_peer_notif_set(struct bonding *bond,
 				   struct bond_opt_value *newval);
+int bond_option_miimon_set(struct bonding *bond, struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 3c0ce6f..029e323 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -674,23 +674,13 @@ static ssize_t bonding_store_miimon(struct device *d,
 				    struct device_attribute *attr,
 				    const char *buf, size_t count)
 {
-	int new_value, ret;
 	struct bonding *bond = to_bond(d);
+	int ret;
 
-	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err("%s: no miimon value specified.\n",
-		       bond->dev->name);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = bond_option_miimon_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_MIIMON, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(miimon, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 52ec73f..56d5510 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -450,7 +450,6 @@ unsigned int bond_get_num_tx_queues(void);
 int bond_netlink_init(void);
 void bond_netlink_fini(void);
 int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_dev);
-int bond_option_miimon_set(struct bonding *bond, int miimon);
 int bond_option_use_carrier_set(struct bonding *bond, int use_carrier);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
-- 
1.8.4.2
