From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 10/32] net: dsa: Add basic support for component master support
Date: Sun, 28 Feb 2016 17:41:18 +0100
Message-ID: <1456677700-23027-11-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44897 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759177AbcB1QmA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:00 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Start using the component framework. The DSA device will be the
master, and the switch drivers will be slaves. Add basic component
master support to the DSA framework.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 54 ++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 40 insertions(+), 14 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 5062ca91852d..a139c35061a1 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -9,6 +9,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/component.h>
 #include <linux/ctype.h>
 #include <linux/device.h>
 #include <linux/hwmon.h>
@@ -28,7 +29,7 @@
 #include "dsa_priv.h"
 
 char dsa_driver_version[] = "0.1";
-
+static const struct component_master_ops dsa_ops;
 
 /* switch driver registration ***********************************************/
 static DEFINE_MUTEX(dsa_switch_drivers_mutex);
@@ -820,13 +821,12 @@ static inline void dsa_of_remove(struct device *dev,
 #endif
 
 static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
-			 struct device *parent, struct dsa_platform_data *pd)
+			 struct device *parent)
 {
 	int i;
 	unsigned configured = 0;
+	struct dsa_platform_data *pd = dst->pd;
 
-	dst->pd = pd;
-	dst->master_netdev = dev;
 	dst->cpu_switch = -1;
 	dst->cpu_port = -1;
 
@@ -885,6 +885,7 @@ static void dsa_finish_dst(struct dsa_switch_tree *dst, struct device *parent,
 static int dsa_probe(struct platform_device *pdev)
 {
 	struct dsa_platform_data *pd = pdev->dev.platform_data;
+	struct component_match *match = NULL;
 	struct net_device *dev;
 	struct dsa_switch_tree *dst;
 	int ret;
@@ -931,15 +932,13 @@ static int dsa_probe(struct platform_device *pdev)
 		goto out;
 	}
 
+	dst->pd = pd;
+	dst->master_netdev = dev;
+
 	platform_set_drvdata(pdev, dst);
 
-	ret = dsa_setup_dst(dst, dev, &pdev->dev, pd);
-	if (ret) {
-		dev_put(dev);
-		goto out;
-	}
 
-	return 0;
+	return component_master_add_with_match(&pdev->dev, &dsa_ops, match);
 
 out:
 	dsa_of_remove(&pdev->dev, pd);
@@ -947,22 +946,49 @@ out:
 	return ret;
 }
 
-static int dsa_remove(struct platform_device *pdev)
+static int dsa_bind(struct device *dev)
 {
+	struct dsa_switch_tree *dst = dev_get_drvdata(dev);
+	int ret;
+
+	ret = component_bind_all(dev, dst);
+	if (ret)
+		return ret;
+
+	return dsa_setup_dst(dst, dst->master_netdev, dev);
+}
+
+static void dsa_unbind(struct device *dev)
+{
+	struct platform_device *pdev = to_platform_device(dev);
 	struct dsa_switch_tree *dst = platform_get_drvdata(pdev);
 	struct dsa_platform_data *pd = pdev->dev.platform_data;
 
 	dsa_finish_dst(dst, &pdev->dev, pd);
-	dsa_of_remove(&pdev->dev, pd);
-	dev_put(dst->master_netdev);
 
-	return 0;
+	dev_put(dst->master_netdev);
 }
 
+static const struct component_master_ops dsa_ops = {
+	.bind = dsa_bind,
+	.unbind = dsa_unbind,
+};
+
 static void dsa_shutdown(struct platform_device *pdev)
 {
 }
 
+static int dsa_remove(struct platform_device *pdev)
+{
+	struct dsa_platform_data *pd = pdev->dev.platform_data;
+
+	component_master_del(&pdev->dev, &dsa_ops);
+
+	dsa_of_remove(&pdev->dev, pd);
+
+	return 0;
+}
+
 static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 			  struct packet_type *pt, struct net_device *orig_dev)
 {
-- 
2.7.0
