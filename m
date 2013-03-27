From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH] bonding: fix disabling of arp_interval and miimon
Date: Wed, 27 Mar 2013 14:32:41 +0100
Message-ID: <1364391161-26605-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45676 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751035Ab3C0NfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 09:35:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently if either arp_interval or miimon is disabled, they both get
disabled, and upon disabling they get executed once more which is not
the proper behaviour. Also when doing a no-op and disabling an already
disabled one, the other again gets disabled.
Also fix the error messages with the proper valid ranges, and a small
typo fix in the up delay error message (outputting "down delay", instead
of "up delay").

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c | 92 +++++++++++++++++++++-------------------
 1 file changed, 48 insertions(+), 44 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index db103e0..ea7a388 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -527,7 +527,7 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 		goto out;
 	}
 	if (new_value < 0) {
-		pr_err("%s: Invalid arp_interval value %d not in range 1-%d; rejected.\n",
+		pr_err("%s: Invalid arp_interval value %d not in range 0-%d; rejected.\n",
 		       bond->dev->name, new_value, INT_MAX);
 		ret = -EINVAL;
 		goto out;
@@ -542,14 +542,15 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 	pr_info("%s: Setting ARP monitoring interval to %d.\n",
 		bond->dev->name, new_value);
 	bond->params.arp_interval = new_value;
-	if (bond->params.miimon) {
-		pr_info("%s: ARP monitoring cannot be used with MII monitoring. %s Disabling MII monitoring.\n",
-			bond->dev->name, bond->dev->name);
-		bond->params.miimon = 0;
-	}
-	if (!bond->params.arp_targets[0]) {
-		pr_info("%s: ARP monitoring has been set up, but no ARP targets have been specified.\n",
-			bond->dev->name);
+	if (new_value) {
+		if (bond->params.miimon) {
+			pr_info("%s: ARP monitoring cannot be used with MII monitoring. %s Disabling MII monitoring.\n",
+				bond->dev->name, bond->dev->name);
+			bond->params.miimon = 0;
+		}
+		if (!bond->params.arp_targets[0])
+			pr_info("%s: ARP monitoring has been set up, but no ARP targets have been specified.\n",
+				bond->dev->name);
 	}
 	if (bond->dev->flags & IFF_UP) {
 		/* If the interface is up, we may need to fire off
@@ -557,10 +558,13 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 		 * timer will get fired off when the open function
 		 * is called.
 		 */
-		cancel_delayed_work_sync(&bond->mii_work);
-		queue_delayed_work(bond->wq, &bond->arp_work, 0);
+		if (!new_value) {
+			cancel_delayed_work_sync(&bond->arp_work);
+		} else {
+			cancel_delayed_work_sync(&bond->mii_work);
+			queue_delayed_work(bond->wq, &bond->arp_work, 0);
+		}
 	}
-
 out:
 	rtnl_unlock();
 	return ret;
@@ -702,7 +706,7 @@ static ssize_t bonding_store_downdelay(struct device *d,
 	}
 	if (new_value < 0) {
 		pr_err("%s: Invalid down delay value %d not in range %d-%d; rejected.\n",
-		       bond->dev->name, new_value, 1, INT_MAX);
+		       bond->dev->name, new_value, 0, INT_MAX);
 		ret = -EINVAL;
 		goto out;
 	} else {
@@ -757,8 +761,8 @@ static ssize_t bonding_store_updelay(struct device *d,
 		goto out;
 	}
 	if (new_value < 0) {
-		pr_err("%s: Invalid down delay value %d not in range %d-%d; rejected.\n",
-		       bond->dev->name, new_value, 1, INT_MAX);
+		pr_err("%s: Invalid up delay value %d not in range %d-%d; rejected.\n",
+		       bond->dev->name, new_value, 0, INT_MAX);
 		ret = -EINVAL;
 		goto out;
 	} else {
@@ -968,37 +972,37 @@ static ssize_t bonding_store_miimon(struct device *d,
 	}
 	if (new_value < 0) {
 		pr_err("%s: Invalid miimon value %d not in range %d-%d; rejected.\n",
-		       bond->dev->name, new_value, 1, INT_MAX);
+		       bond->dev->name, new_value, 0, INT_MAX);
 		ret = -EINVAL;
 		goto out;
-	} else {
-		pr_info("%s: Setting MII monitoring interval to %d.\n",
-			bond->dev->name, new_value);
-		bond->params.miimon = new_value;
-		if (bond->params.updelay)
-			pr_info("%s: Note: Updating updelay (to %d) since it is a multiple of the miimon value.\n",
-				bond->dev->name,
-				bond->params.updelay * bond->params.miimon);
-		if (bond->params.downdelay)
-			pr_info("%s: Note: Updating downdelay (to %d) since it is a multiple of the miimon value.\n",
-				bond->dev->name,
-				bond->params.downdelay * bond->params.miimon);
-		if (bond->params.arp_interval) {
-			pr_info("%s: MII monitoring cannot be used with ARP monitoring. Disabling ARP monitoring...\n",
-				bond->dev->name);
-			bond->params.arp_interval = 0;
-			if (bond->params.arp_validate) {
-				bond->params.arp_validate =
-					BOND_ARP_VALIDATE_NONE;
-			}
-		}
-
-		if (bond->dev->flags & IFF_UP) {
-			/* If the interface is up, we may need to fire off
-			 * the MII timer. If the interface is down, the
-			 * timer will get fired off when the open function
-			 * is called.
-			 */
+	}
+	pr_info("%s: Setting MII monitoring interval to %d.\n",
+		bond->dev->name, new_value);
+	bond->params.miimon = new_value;
+	if (bond->params.updelay)
+		pr_info("%s: Note: Updating updelay (to %d) since it is a multiple of the miimon value.\n",
+			bond->dev->name,
+			bond->params.updelay * bond->params.miimon);
+	if (bond->params.downdelay)
+		pr_info("%s: Note: Updating downdelay (to %d) since it is a multiple of the miimon value.\n",
+			bond->dev->name,
+			bond->params.downdelay * bond->params.miimon);
+	if (new_value && bond->params.arp_interval) {
+		pr_info("%s: MII monitoring cannot be used with ARP monitoring. Disabling ARP monitoring...\n",
+			bond->dev->name);
+		bond->params.arp_interval = 0;
+		if (bond->params.arp_validate)
+			bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
+	}
+	if (bond->dev->flags & IFF_UP) {
+		/* If the interface is up, we may need to fire off
+		 * the MII timer. If the interface is down, the
+		 * timer will get fired off when the open function
+		 * is called.
+		 */
+		if (!new_value) {
+			cancel_delayed_work_sync(&bond->mii_work);
+		} else {
 			cancel_delayed_work_sync(&bond->arp_work);
 			queue_delayed_work(bond->wq, &bond->mii_work, 0);
 		}
-- 
1.7.11.7
