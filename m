From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 03/28] net: dsa: Move platform data allocation for OF
Date: Wed, 23 Dec 2015 13:56:17 +0100
Message-ID: <1450875402-20740-4-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48665 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755444AbbLWM5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:57:15 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>

Do not have dsa_of_probe() allocate and assign struct dsa_platform_data,
but instead do this outside of this function such that we can control
exactly the storage of that data structure.

This is a preliminary change to allow multiple callers of dsa_of_probe()
not to clobber an existing dsa_platform_data and later, control where
this data structure is coming from.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 48 +++++++++++++++++++-----------------------------
 1 file changed, 19 insertions(+), 29 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 208d1b257194..704502c22306 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -651,13 +651,12 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 	kfree(pd->chip);
 }
 
-static int dsa_of_probe(struct device *dev)
+static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 {
 	struct device_node *np = dev->of_node;
 	struct device_node *child, *mdio, *ethernet, *port;
 	struct mii_bus *mdio_bus, *mdio_bus_switch;
 	struct net_device *ethernet_dev;
-	struct dsa_platform_data *pd;
 	struct dsa_chip_data *cd;
 	const char *port_name;
 	int chip_index, port_index;
@@ -666,7 +665,7 @@ static int dsa_of_probe(struct device *dev)
 	enum of_gpio_flags of_flags;
 	unsigned long flags;
 	u32 eeprom_len;
-	int ret;
+	int ret = 0;
 
 	mdio = of_parse_phandle(np, "dsa,mii-bus", 0);
 	if (!mdio)
@@ -688,13 +687,6 @@ static int dsa_of_probe(struct device *dev)
 		goto out_put_mdio;
 	}
 
-	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
-	if (!pd) {
-		ret = -ENOMEM;
-		goto out_put_ethernet;
-	}
-
-	dev->platform_data = pd;
 	pd->of_netdev = ethernet_dev;
 	pd->nr_chips = of_get_available_child_count(np);
 	if (pd->nr_chips > DSA_MAX_SWITCHES)
@@ -702,10 +694,8 @@ static int dsa_of_probe(struct device *dev)
 
 	pd->chip = kcalloc(pd->nr_chips, sizeof(struct dsa_chip_data),
 			   GFP_KERNEL);
-	if (!pd->chip) {
-		ret = -ENOMEM;
-		goto out_free;
-	}
+	if (!pd->chip)
+		goto out_put_mdio;
 
 	chip_index = -1;
 	for_each_available_child_of_node(np, child) {
@@ -795,34 +785,29 @@ static int dsa_of_probe(struct device *dev)
 
 out_free_chip:
 	dsa_of_free_platform_data(pd);
-out_free:
-	kfree(pd);
-	dev->platform_data = NULL;
-out_put_ethernet:
-	put_device(&ethernet_dev->dev);
+
 out_put_mdio:
 	put_device(&mdio_bus->dev);
 	return ret;
 }
 
-static void dsa_of_remove(struct device *dev)
+static void dsa_of_remove(struct device *dev, struct dsa_platform_data *pd)
 {
-	struct dsa_platform_data *pd = dev->platform_data;
-
 	if (!dev->of_node)
 		return;
 
 	dsa_of_free_platform_data(pd);
 	put_device(&pd->of_netdev->dev);
-	kfree(pd);
 }
 #else
-static inline int dsa_of_probe(struct device *dev)
+static inline int dsa_of_probe(struct device *dev,
+			       struct dsa_platform_data *pd)
 {
 	return 0;
 }
 
-static inline void dsa_of_remove(struct device *dev)
+static inline void dsa_of_remove(struct device *dev,
+				 struct dsa_platform_data *pd)
 {
 }
 #endif
@@ -881,11 +866,15 @@ static int dsa_probe(struct platform_device *pdev)
 		       dsa_driver_version);
 
 	if (pdev->dev.of_node) {
-		ret = dsa_of_probe(&pdev->dev);
+		pd = devm_kzalloc(&pdev->dev, sizeof(*pd), GFP_KERNEL);
+		if (!pd)
+			return -ENOMEM;
+
+		ret = dsa_of_probe(&pdev->dev, pd);
 		if (ret)
 			return ret;
 
-		pd = pdev->dev.platform_data;
+		pdev->dev.platform_data = pd;
 	}
 
 	if (pd == NULL || (pd->netdev == NULL && pd->of_netdev == NULL))
@@ -926,7 +915,7 @@ static int dsa_probe(struct platform_device *pdev)
 	return 0;
 
 out:
-	dsa_of_remove(&pdev->dev);
+	dsa_of_remove(&pdev->dev, pd);
 
 	return ret;
 }
@@ -948,9 +937,10 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 static int dsa_remove(struct platform_device *pdev)
 {
 	struct dsa_switch_tree *dst = platform_get_drvdata(pdev);
+	struct dsa_platform_data *pd = pdev->dev.platform_data;
 
 	dsa_remove_dst(dst);
-	dsa_of_remove(&pdev->dev);
+	dsa_of_remove(&pdev->dev, pd);
 
 	return 0;
 }
-- 
2.6.3
