From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/5] net: dsa: update dsa_of_{probe,remove} to use a device pointer
Date: Thu,  5 Mar 2015 12:35:04 -0800
Message-ID: <1425587708-26786-2-git-send-email-f.fainelli@gmail.com>
References: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:45496 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754188AbbCEUgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 15:36:13 -0500
Received: by padbj1 with SMTP id bj1so11849936pad.12
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 12:36:13 -0800 (PST)
In-Reply-To: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for allowing a different mechanism to register DSA switch
devices and driver, update dsa_of_probe and dsa_of_remove to take a
struct device pointer since neither of these two functions uses the
struct platform_device pointer.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index a1d1f0775bea..d804364150bd 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -563,9 +563,9 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 	kfree(pd->chip);
 }
 
-static int dsa_of_probe(struct platform_device *pdev)
+static int dsa_of_probe(struct device *dev)
 {
-	struct device_node *np = pdev->dev.of_node;
+	struct device_node *np = dev->of_node;
 	struct device_node *child, *mdio, *ethernet, *port, *link;
 	struct mii_bus *mdio_bus;
 	struct platform_device *ethernet_dev;
@@ -597,7 +597,7 @@ static int dsa_of_probe(struct platform_device *pdev)
 	if (!pd)
 		return -ENOMEM;
 
-	pdev->dev.platform_data = pd;
+	dev->platform_data = pd;
 	pd->netdev = &ethernet_dev->dev;
 	pd->nr_chips = of_get_available_child_count(np);
 	if (pd->nr_chips > DSA_MAX_SWITCHES)
@@ -670,27 +670,27 @@ out_free_chip:
 	dsa_of_free_platform_data(pd);
 out_free:
 	kfree(pd);
-	pdev->dev.platform_data = NULL;
+	dev->platform_data = NULL;
 	return ret;
 }
 
-static void dsa_of_remove(struct platform_device *pdev)
+static void dsa_of_remove(struct device *dev)
 {
-	struct dsa_platform_data *pd = pdev->dev.platform_data;
+	struct dsa_platform_data *pd = dev->platform_data;
 
-	if (!pdev->dev.of_node)
+	if (!dev->of_node)
 		return;
 
 	dsa_of_free_platform_data(pd);
 	kfree(pd);
 }
 #else
-static inline int dsa_of_probe(struct platform_device *pdev)
+static inline int dsa_of_probe(struct device *dev)
 {
 	return 0;
 }
 
-static inline void dsa_of_remove(struct platform_device *pdev)
+static inline void dsa_of_remove(struct device *dev)
 {
 }
 #endif
@@ -706,7 +706,7 @@ static int dsa_probe(struct platform_device *pdev)
 		       dsa_driver_version);
 
 	if (pdev->dev.of_node) {
-		ret = dsa_of_probe(pdev);
+		ret = dsa_of_probe(&pdev->dev);
 		if (ret)
 			return ret;
 
@@ -777,7 +777,7 @@ static int dsa_probe(struct platform_device *pdev)
 	return 0;
 
 out:
-	dsa_of_remove(pdev);
+	dsa_of_remove(&pdev->dev);
 
 	return ret;
 }
@@ -799,7 +799,7 @@ static int dsa_remove(struct platform_device *pdev)
 			dsa_switch_destroy(ds);
 	}
 
-	dsa_of_remove(pdev);
+	dsa_of_remove(&pdev->dev);
 
 	return 0;
 }
-- 
2.1.0
