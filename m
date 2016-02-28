From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 08/32] net: dsa: dsa.c: Refactor to increase symmetry
Date: Sun, 28 Feb 2016 17:41:16 +0100
Message-ID: <1456677700-23027-9-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45041 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757958AbcB1QoU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:44:20 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a dsa_switch_finish() which does the opposite of dsa_switch_setup().
Create a dsa_finish_dst() which does the opposite of dsa_setup_dst().

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 44 +++++++++++++++++++++++++++++---------------
 1 file changed, 29 insertions(+), 15 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 6c9d1d812873..5062ca91852d 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -462,6 +462,13 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	return ds;
 }
 
+static void dsa_switch_finish(struct dsa_switch *ds, struct device *parent)
+{
+	dsa_switch_finish_one(ds);
+
+	devm_kfree(parent, ds);
+}
+
 #ifdef CONFIG_PM_SLEEP
 static int dsa_switch_suspend(struct dsa_switch *ds)
 {
@@ -855,6 +862,26 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	return 0;
 }
 
+static void dsa_finish_dst(struct dsa_switch_tree *dst, struct device *parent,
+			   struct dsa_platform_data *pd)
+{
+	struct net_device *dev = dst->master_netdev;
+	int i;
+
+	dev->dsa_ptr = NULL;
+	/* Ensure no more packets get sent to the tag receive
+	 * function.
+	 */
+	wmb();
+
+	for (i = 0; i < pd->nr_chips; i++) {
+		struct dsa_switch *ds = dst->ds[i];
+
+		dsa_switch_finish(ds, parent);
+		dst->ds[i] = NULL;
+	}
+}
+
 static int dsa_probe(struct platform_device *pdev)
 {
 	struct dsa_platform_data *pd = pdev->dev.platform_data;
@@ -920,27 +947,14 @@ out:
 	return ret;
 }
 
-static void dsa_remove_dst(struct dsa_switch_tree *dst)
-{
-	int i;
-
-	for (i = 0; i < dst->pd->nr_chips; i++) {
-		struct dsa_switch *ds = dst->ds[i];
-
-		if (ds)
-			dsa_switch_finish_one(ds);
-	}
-
-	dev_put(dst->master_netdev);
-}
-
 static int dsa_remove(struct platform_device *pdev)
 {
 	struct dsa_switch_tree *dst = platform_get_drvdata(pdev);
 	struct dsa_platform_data *pd = pdev->dev.platform_data;
 
-	dsa_remove_dst(dst);
+	dsa_finish_dst(dst, &pdev->dev, pd);
 	dsa_of_remove(&pdev->dev, pd);
+	dev_put(dst->master_netdev);
 
 	return 0;
 }
-- 
2.7.0
