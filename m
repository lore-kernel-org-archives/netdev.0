From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 4/4] bonding: fix multiple 3ad mode sysfs race conditions
Date: Wed, 15 May 2013 14:32:42 +0200
Message-ID: <1368621162-6807-5-git-send-email-nikolay@redhat.com>
References: <1368621162-6807-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29969 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758624Ab3EOMhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 08:37:38 -0400
In-Reply-To: <1368621162-6807-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bond_3ad_get_active_agg_info() is used in all show_ad_ functions
it is not protected against slave manipulation and since it walks over
the slaves and uses them, this can easily result in NULL pointer
dereference or use of freed memory.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 77ea237..81ef36a 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1319,6 +1319,17 @@ static ssize_t bonding_show_mii_status(struct device *d,
 }
 static DEVICE_ATTR(mii_status, S_IRUGO, bonding_show_mii_status, NULL);
 
+/* Wrapper used to hold bond->lock so no slave manipulation can occur */
+static int get_active_agg_info(struct bonding *bond, struct ad_info *ad)
+{
+	int ret;
+
+	read_lock(&bond->lock);
+	ret = bond_3ad_get_active_agg_info(bond, ad);
+	read_unlock(&bond->lock);
+
+	return ret;
+}
 
 /*
  * Show current 802.3ad aggregator ID.
@@ -1333,7 +1344,7 @@ static ssize_t bonding_show_ad_aggregator(struct device *d,
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
-				(bond_3ad_get_active_agg_info(bond, &ad_info))
+				(get_active_agg_info(bond, &ad_info))
 				?  0 : ad_info.aggregator_id);
 	}
 
@@ -1355,7 +1366,7 @@ static ssize_t bonding_show_ad_num_ports(struct device *d,
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
-				(bond_3ad_get_active_agg_info(bond, &ad_info))
+				(get_active_agg_info(bond, &ad_info))
 				?  0 : ad_info.ports);
 	}
 
@@ -1377,7 +1388,7 @@ static ssize_t bonding_show_ad_actor_key(struct device *d,
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
-				(bond_3ad_get_active_agg_info(bond, &ad_info))
+				(get_active_agg_info(bond, &ad_info))
 				?  0 : ad_info.actor_key);
 	}
 
@@ -1399,7 +1410,7 @@ static ssize_t bonding_show_ad_partner_key(struct device *d,
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
-				(bond_3ad_get_active_agg_info(bond, &ad_info))
+				(get_active_agg_info(bond, &ad_info))
 				?  0 : ad_info.partner_key);
 	}
 
@@ -1420,7 +1431,7 @@ static ssize_t bonding_show_ad_partner_mac(struct device *d,
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		if (!bond_3ad_get_active_agg_info(bond, &ad_info))
+		if (!get_active_agg_info(bond, &ad_info))
 			count = sprintf(buf, "%pM\n", ad_info.partner_system);
 	}
 
-- 
1.8.1.4
