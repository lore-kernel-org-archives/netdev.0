From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH v2 4/4] bonding: fix multiple 3ad mode sysfs race conditions
Date: Sat, 18 May 2013 13:18:31 +0200
Message-ID: <1368875911-4952-5-git-send-email-nikolay@redhat.com>
References: <1368875911-4952-1-git-send-email-nikolay@redhat.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25828 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753453Ab3ERLVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 May 2013 07:21:40 -0400
In-Reply-To: <1368875911-4952-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bond_3ad_get_active_agg_info() is used in all show_ad_ functions
it is not protected against slave manipulation and since it walks over
the slaves and uses them, this can easily result in NULL pointer
dereference or use of freed memory. Both the new wrapper and the
internal function are exported to the bonding as they're needed in
different places.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v2: Make the wrapper global and move it to bond_3ad.c, also fix the naming
    of the functions, and remove the extra brackets.

 drivers/net/bonding/bond_3ad.c    | 21 +++++++++++++++++----
 drivers/net/bonding/bond_3ad.h    |  2 ++
 drivers/net/bonding/bond_procfs.c |  2 +-
 drivers/net/bonding/bond_sysfs.c  |  9 ++++-----
 4 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index fc58d11..390061d 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2360,14 +2360,15 @@ int bond_3ad_set_carrier(struct bonding *bond)
 }
 
 /**
- * bond_3ad_get_active_agg_info - get information of the active aggregator
+ * __bond_3ad_get_active_agg_info - get information of the active aggregator
  * @bond: bonding struct to work on
  * @ad_info: ad_info struct to fill with the bond's info
  *
  * Returns:   0 on success
  *          < 0 on error
  */
-int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
+int __bond_3ad_get_active_agg_info(struct bonding *bond,
+				   struct ad_info *ad_info)
 {
 	struct aggregator *aggregator = NULL;
 	struct port *port;
@@ -2391,6 +2392,18 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
 	return -1;
 }
 
+/* Wrapper used to hold bond->lock so no slave manipulation can occur */
+int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
+{
+	int ret;
+
+	read_lock(&bond->lock);
+	ret = __bond_3ad_get_active_agg_info(bond, ad_info);
+	read_unlock(&bond->lock);
+
+	return ret;
+}
+
 int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 {
 	struct slave *slave, *start_at;
@@ -2402,8 +2415,8 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	struct ad_info ad_info;
 	int res = 1;
 
-	if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
-		pr_debug("%s: Error: bond_3ad_get_active_agg_info failed\n",
+	if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
+		pr_debug("%s: Error: __bond_3ad_get_active_agg_info failed\n",
 			 dev->name);
 		goto out;
 	}
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 0cfaa4a..5d91ad0 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -273,6 +273,8 @@ void bond_3ad_adapter_speed_changed(struct slave *slave);
 void bond_3ad_adapter_duplex_changed(struct slave *slave);
 void bond_3ad_handle_link_change(struct slave *slave, char link);
 int  bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info);
+int  __bond_3ad_get_active_agg_info(struct bonding *bond,
+				    struct ad_info *ad_info);
 int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev);
 int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 			 struct slave *slave);
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 94d06f1..4060d41 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -130,7 +130,7 @@ static void bond_info_show_master(struct seq_file *seq)
 		seq_printf(seq, "Aggregator selection policy (ad_select): %s\n",
 			   ad_select_tbl[bond->params.ad_select].modename);
 
-		if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
+		if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
 			seq_printf(seq, "bond %s has no active aggregator\n",
 				   bond->dev->name);
 		} else {
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 77ea237..d7434e0 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1319,7 +1319,6 @@ static ssize_t bonding_show_mii_status(struct device *d,
 }
 static DEVICE_ATTR(mii_status, S_IRUGO, bonding_show_mii_status, NULL);
 
-
 /*
  * Show current 802.3ad aggregator ID.
  */
@@ -1333,7 +1332,7 @@ static ssize_t bonding_show_ad_aggregator(struct device *d,
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
-				(bond_3ad_get_active_agg_info(bond, &ad_info))
+				bond_3ad_get_active_agg_info(bond, &ad_info)
 				?  0 : ad_info.aggregator_id);
 	}
 
@@ -1355,7 +1354,7 @@ static ssize_t bonding_show_ad_num_ports(struct device *d,
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
-				(bond_3ad_get_active_agg_info(bond, &ad_info))
+				bond_3ad_get_active_agg_info(bond, &ad_info)
 				?  0 : ad_info.ports);
 	}
 
@@ -1377,7 +1376,7 @@ static ssize_t bonding_show_ad_actor_key(struct device *d,
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
-				(bond_3ad_get_active_agg_info(bond, &ad_info))
+				bond_3ad_get_active_agg_info(bond, &ad_info)
 				?  0 : ad_info.actor_key);
 	}
 
@@ -1399,7 +1398,7 @@ static ssize_t bonding_show_ad_partner_key(struct device *d,
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
-				(bond_3ad_get_active_agg_info(bond, &ad_info))
+				bond_3ad_get_active_agg_info(bond, &ad_info)
 				?  0 : ad_info.partner_key);
 	}
 
-- 
1.8.1.4
