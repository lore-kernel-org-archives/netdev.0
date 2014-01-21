From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 15/25] bonding: convert num_peer_notif to use the new option API
Date: Tue, 21 Jan 2014 15:55:04 +0100
Message-ID: <1390316114-17815-16-git-send-email-nikolay@redhat.com>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4547 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754856AbaAUO4A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 09:56:00 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0LEtxYN013329
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 09:56:00 -0500
In-Reply-To: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so num_peer_notif would use
the new bonding option API.
When the auto-sysfs generation is done an alias should be added for
this option as there're currently 2 entries in sysfs for it.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 20 ++++++++++++++++++--
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 14 +-------------
 drivers/net/bonding/bonding.h      |  1 -
 5 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index f7be658..cbf1bb0 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -269,7 +269,8 @@ static int bond_changelink(struct net_device *bond_dev,
 		int num_peer_notif =
 			nla_get_u8(data[IFLA_BOND_NUM_PEER_NOTIF]);
 
-		err = bond_option_num_peer_notif_set(bond, num_peer_notif);
+		bond_opt_initval(&newval, num_peer_notif);
+		err = __bond_opt_set(bond, BOND_OPT_NUM_PEER_NOTIF, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 3deb9f3..4a10a93 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -86,6 +86,13 @@ static struct bond_opt_value bond_ad_select_tbl[] = {
 	{ NULL,        -1,                0},
 };
 
+static struct bond_opt_value bond_num_peer_notif_tbl[] = {
+	{ "off",     0,   0},
+	{ "maxval",  255, BOND_VALFLAG_MAX},
+	{ "default", 1,   BOND_VALFLAG_DEFAULT},
+	{ NULL,      -1,  0}
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -187,6 +194,13 @@ static struct bond_option bond_opts[] = {
 		.values = bond_ad_select_tbl,
 		.set = bond_option_ad_select_set
 	},
+	[BOND_OPT_NUM_PEER_NOTIF] = {
+		.id = BOND_OPT_NUM_PEER_NOTIF,
+		.name = "num_unsol_na",
+		.desc = "Number of peer notifications to send on failover event",
+		.values = bond_num_peer_notif_tbl,
+		.set = bond_option_num_peer_notif_set
+	},
 	{ }
 };
 
@@ -978,9 +992,11 @@ int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp)
 	return 0;
 }
 
-int bond_option_num_peer_notif_set(struct bonding *bond, int num_peer_notif)
+int bond_option_num_peer_notif_set(struct bonding *bond,
+				   struct bond_opt_value *newval)
 {
-	bond->params.num_peer_notif = num_peer_notif;
+	bond->params.num_peer_notif = newval->value;
+
 	return 0;
 }
 
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index 53df176..014a359 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -51,6 +51,7 @@ enum {
 	BOND_OPT_LACP_RATE,
 	BOND_OPT_MINLINKS,
 	BOND_OPT_AD_SELECT,
+	BOND_OPT_NUM_PEER_NOTIF,
 	BOND_OPT_LAST
 };
 
@@ -136,4 +137,6 @@ int bond_option_min_links_set(struct bonding *bond,
 			      struct bond_opt_value *newval);
 int bond_option_ad_select_set(struct bonding *bond,
 			      struct bond_opt_value *newval);
+int bond_option_num_peer_notif_set(struct bonding *bond,
+				   struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index e8081e8..3c0ce6f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -642,24 +642,12 @@ static ssize_t bonding_store_num_peer_notif(struct device *d,
 					    const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	u8 new_value;
 	int ret;
 
-	ret = kstrtou8(buf, 10, &new_value);
-	if (ret) {
-		pr_err("%s: invalid value %s specified.\n",
-		       bond->dev->name, buf);
-		return ret;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-
-	ret = bond_option_num_peer_notif_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_NUM_PEER_NOTIF, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 923f612..52ec73f 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -458,7 +458,6 @@ int bond_option_primary_set(struct bonding *bond, const char *primary);
 int bond_option_primary_reselect_set(struct bonding *bond,
 				     int primary_reselect);
 int bond_option_resend_igmp_set(struct bonding *bond, int resend_igmp);
-int bond_option_num_peer_notif_set(struct bonding *bond, int num_peer_notif);
 int bond_option_all_slaves_active_set(struct bonding *bond,
 				      int all_slaves_active);
 int bond_option_lp_interval_set(struct bonding *bond, int min_links);
-- 
1.8.4.2
