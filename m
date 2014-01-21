From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 08/25] bonding: convert arp_interval to use the new option API
Date: Tue, 21 Jan 2014 15:54:57 +0100
Message-ID: <1390316114-17815-9-git-send-email-nikolay@redhat.com>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64144 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754824AbaAUOzx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 09:55:53 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0LEtq2l008515
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 09:55:53 -0500
In-Reply-To: <1390316114-17815-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes so arp_interval would use
the new bonding option API. The "default" definition has been removed as
it was 0.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c    |  9 ++++-----
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/bonding/bond_options.c | 37 +++++++++++++++++++++----------------
 drivers/net/bonding/bond_options.h |  3 +++
 drivers/net/bonding/bond_sysfs.c   | 14 ++------------
 drivers/net/bonding/bonding.h      |  1 -
 6 files changed, 32 insertions(+), 35 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f4da76e..9de3d35 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -88,7 +88,6 @@
 
 /* monitor all links that often (in milliseconds). <=0 disables monitoring */
 #define BOND_LINK_MON_INTERV	0
-#define BOND_LINK_ARP_INTERV	0
 
 static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
 static int tx_queues	= BOND_DEFAULT_TX_QUEUES;
@@ -104,7 +103,7 @@ static char *lacp_rate;
 static int min_links;
 static char *ad_select;
 static char *xmit_hash_policy;
-static int arp_interval = BOND_LINK_ARP_INTERV;
+static int arp_interval;
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS];
 static char *arp_validate;
 static char *arp_all_targets;
@@ -4160,9 +4159,9 @@ static int bond_check_params(struct bond_params *params)
 	}
 
 	if (arp_interval < 0) {
-		pr_warning("Warning: arp_interval module parameter (%d) , not in range 0-%d, so it was reset to %d\n",
-			   arp_interval, INT_MAX, BOND_LINK_ARP_INTERV);
-		arp_interval = BOND_LINK_ARP_INTERV;
+		pr_warning("Warning: arp_interval module parameter (%d) , not in range 0-%d, so it was reset to 0\n",
+			   arp_interval, INT_MAX);
+		arp_interval = 0;
 	}
 
 	for (arp_ip_count = 0, i = 0;
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index a1b72ac..c9264107 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -167,7 +167,8 @@ static int bond_changelink(struct net_device *bond_dev,
 			return -EINVAL;
 		}
 
-		err = bond_option_arp_interval_set(bond, arp_interval);
+		bond_opt_initval(&newval, arp_interval);
+		err = __bond_opt_set(bond, BOND_OPT_ARP_INTERVAL, &newval);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 7e082e0..c3eb617 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -67,6 +67,11 @@ static struct bond_opt_value bond_fail_over_mac_tbl[] = {
 	{ NULL,     -1,              0},
 };
 
+static struct bond_opt_value bond_intmax_tbl[] = {
+	{ "off",     0,       BOND_VALFLAG_DEFAULT},
+	{ "maxval",  INT_MAX, BOND_VALFLAG_MAX},
+};
+
 static struct bond_option bond_opts[] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -114,6 +119,15 @@ static struct bond_option bond_opts[] = {
 		.values = bond_fail_over_mac_tbl,
 		.set = bond_option_fail_over_mac_set
 	},
+	[BOND_OPT_ARP_INTERVAL] = {
+		.id = BOND_OPT_ARP_INTERVAL,
+		.name = "arp_interval",
+		.desc = "arp interval in milliseconds",
+		.unsuppmodes = BIT(BOND_MODE_8023AD) | BIT(BOND_MODE_TLB) |
+			       BIT(BOND_MODE_ALB),
+		.values = bond_intmax_tbl,
+		.set = bond_option_arp_interval_set
+	},
 	{ }
 };
 
@@ -602,22 +616,13 @@ int bond_option_use_carrier_set(struct bonding *bond, int use_carrier)
 	return 0;
 }
 
-int bond_option_arp_interval_set(struct bonding *bond, int arp_interval)
+int bond_option_arp_interval_set(struct bonding *bond,
+				 struct bond_opt_value *newval)
 {
-	if (arp_interval < 0) {
-		pr_err("%s: Invalid arp_interval value %d not in range 0-%d; rejected.\n",
-		       bond->dev->name, arp_interval, INT_MAX);
-		return -EINVAL;
-	}
-	if (BOND_NO_USES_ARP(bond->params.mode)) {
-		pr_info("%s: ARP monitoring cannot be used with ALB/TLB/802.3ad. Only MII monitoring is supported on %s.\n",
-			bond->dev->name, bond->dev->name);
-		return -EINVAL;
-	}
-	pr_info("%s: Setting ARP monitoring interval to %d.\n",
-		bond->dev->name, arp_interval);
-	bond->params.arp_interval = arp_interval;
-	if (arp_interval) {
+	pr_info("%s: Setting ARP monitoring interval to %llu.\n",
+		bond->dev->name, newval->value);
+	bond->params.arp_interval = newval->value;
+	if (newval->value) {
 		if (bond->params.miimon) {
 			pr_info("%s: ARP monitoring cannot be used with MII monitoring. %s Disabling MII monitoring.\n",
 				bond->dev->name, bond->dev->name);
@@ -633,7 +638,7 @@ int bond_option_arp_interval_set(struct bonding *bond, int arp_interval)
 		 * timer will get fired off when the open function
 		 * is called.
 		 */
-		if (!arp_interval) {
+		if (!newval->value) {
 			if (bond->params.arp_validate)
 				bond->recv_probe = NULL;
 			cancel_delayed_work_sync(&bond->arp_work);
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
index e80a031..f02b857 100644
--- a/drivers/net/bonding/bond_options.h
+++ b/drivers/net/bonding/bond_options.h
@@ -44,6 +44,7 @@ enum {
 	BOND_OPT_ARP_VALIDATE,
 	BOND_OPT_ARP_ALL_TARGETS,
 	BOND_OPT_FAIL_OVER_MAC,
+	BOND_OPT_ARP_INTERVAL,
 	BOND_OPT_LAST
 };
 
@@ -114,4 +115,6 @@ int bond_option_arp_all_targets_set(struct bonding *bond,
 				    struct bond_opt_value *newval);
 int bond_option_fail_over_mac_set(struct bonding *bond,
 				  struct bond_opt_value *newval);
+int bond_option_arp_interval_set(struct bonding *bond,
+				 struct bond_opt_value *newval);
 #endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index e300190..414d713 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -437,22 +437,12 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 					  const char *buf, size_t count)
 {
 	struct bonding *bond = to_bond(d);
-	int new_value, ret;
-
-	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err("%s: no arp_interval value specified.\n",
-		bond->dev->name);
-		return -EINVAL;
-	}
-
-	if (!rtnl_trylock())
-		return restart_syscall();
+	int ret;
 
-	ret = bond_option_arp_interval_set(bond, new_value);
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_ARP_INTERVAL, (char *)buf);
 	if (!ret)
 		ret = count;
 
-	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(arp_interval, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 0550615..af065af 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -454,7 +454,6 @@ int bond_option_miimon_set(struct bonding *bond, int miimon);
 int bond_option_updelay_set(struct bonding *bond, int updelay);
 int bond_option_downdelay_set(struct bonding *bond, int downdelay);
 int bond_option_use_carrier_set(struct bonding *bond, int use_carrier);
-int bond_option_arp_interval_set(struct bonding *bond, int arp_interval);
 int bond_option_arp_ip_targets_set(struct bonding *bond, __be32 *targets,
 				   int count);
 int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
-- 
1.8.4.2
