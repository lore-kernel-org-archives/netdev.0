From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH] drivers: net: ethernet: remove incorrect __exit markups
Date: Wed, 1 Mar 2017 17:24:47 -0800
Message-ID: <20170302012447.GA39241@dtor-ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36290 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753289AbdCBDHd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 22:07:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even if bus is not hot-pluggable, devices can be unbound from the
driver via sysfs, so we should not be using __exit annotations on
remove() methods. The only exception is drivers registered with
platform_driver_probe() which specifically disables sysfs bind/unbind
attributes.

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 drivers/net/ethernet/amd/declance.c        | 30 +++++++++++++++---------------
 drivers/net/ethernet/broadcom/sb1250-mac.c |  4 ++--
 drivers/net/ethernet/faraday/ftgmac100.c   |  4 ++--
 drivers/net/ethernet/faraday/ftmac100.c    |  4 ++--
 drivers/net/ethernet/seeq/sgiseeq.c        |  4 ++--
 drivers/net/ethernet/sgi/meth.c            |  4 ++--
 6 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index 76e5fc7adff5..6c98901f1b89 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -1276,18 +1276,6 @@ static int dec_lance_probe(struct device *bdev, const int type)
 	return ret;
 }
 
-static void __exit dec_lance_remove(struct device *bdev)
-{
-	struct net_device *dev = dev_get_drvdata(bdev);
-	resource_size_t start, len;
-
-	unregister_netdev(dev);
-	start = to_tc_dev(bdev)->resource.start;
-	len = to_tc_dev(bdev)->resource.end - start + 1;
-	release_mem_region(start, len);
-	free_netdev(dev);
-}
-
 /* Find all the lance cards on the system and initialize them */
 static int __init dec_lance_platform_probe(void)
 {
@@ -1320,7 +1308,7 @@ static void __exit dec_lance_platform_remove(void)
 
 #ifdef CONFIG_TC
 static int dec_lance_tc_probe(struct device *dev);
-static int __exit dec_lance_tc_remove(struct device *dev);
+static int dec_lance_tc_remove(struct device *dev);
 
 static const struct tc_device_id dec_lance_tc_table[] = {
 	{ "DEC     ", "PMAD-AA " },
@@ -1334,7 +1322,7 @@ static struct tc_driver dec_lance_tc_driver = {
 		.name	= "declance",
 		.bus	= &tc_bus_type,
 		.probe	= dec_lance_tc_probe,
-		.remove	= __exit_p(dec_lance_tc_remove),
+		.remove	= dec_lance_tc_remove,
 	},
 };
 
@@ -1346,7 +1334,19 @@ static int dec_lance_tc_probe(struct device *dev)
         return status;
 }
 
-static int __exit dec_lance_tc_remove(struct device *dev)
+static void dec_lance_remove(struct device *bdev)
+{
+	struct net_device *dev = dev_get_drvdata(bdev);
+	resource_size_t start, len;
+
+	unregister_netdev(dev);
+	start = to_tc_dev(bdev)->resource.start;
+	len = to_tc_dev(bdev)->resource.end - start + 1;
+	release_mem_region(start, len);
+	free_netdev(dev);
+}
+
+static int dec_lance_tc_remove(struct device *dev)
 {
         put_device(dev);
         dec_lance_remove(dev);
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index 435a2e4739d1..f82ec1e506e2 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2617,7 +2617,7 @@ static int sbmac_probe(struct platform_device *pldev)
 	return err;
 }
 
-static int __exit sbmac_remove(struct platform_device *pldev)
+static int sbmac_remove(struct platform_device *pldev)
 {
 	struct net_device *dev = platform_get_drvdata(pldev);
 	struct sbmac_softc *sc = netdev_priv(dev);
@@ -2634,7 +2634,7 @@ static int __exit sbmac_remove(struct platform_device *pldev)
 
 static struct platform_driver sbmac_driver = {
 	.probe = sbmac_probe,
-	.remove = __exit_p(sbmac_remove),
+	.remove = sbmac_remove,
 	.driver = {
 		.name = sbmac_string,
 	},
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 262587240c86..928b0df2b8e0 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1456,7 +1456,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	return err;
 }
 
-static int __exit ftgmac100_remove(struct platform_device *pdev)
+static int ftgmac100_remove(struct platform_device *pdev)
 {
 	struct net_device *netdev;
 	struct ftgmac100 *priv;
@@ -1483,7 +1483,7 @@ MODULE_DEVICE_TABLE(of, ftgmac100_of_match);
 
 static struct platform_driver ftgmac100_driver = {
 	.probe	= ftgmac100_probe,
-	.remove	= __exit_p(ftgmac100_remove),
+	.remove	= ftgmac100_remove,
 	.driver	= {
 		.name		= DRV_NAME,
 		.of_match_table	= ftgmac100_of_match,
diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index dce5f7b7f772..0f122a85a484 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -1154,7 +1154,7 @@ static int ftmac100_probe(struct platform_device *pdev)
 	return err;
 }
 
-static int __exit ftmac100_remove(struct platform_device *pdev)
+static int ftmac100_remove(struct platform_device *pdev)
 {
 	struct net_device *netdev;
 	struct ftmac100 *priv;
@@ -1174,7 +1174,7 @@ static int __exit ftmac100_remove(struct platform_device *pdev)
 
 static struct platform_driver ftmac100_driver = {
 	.probe		= ftmac100_probe,
-	.remove		= __exit_p(ftmac100_remove),
+	.remove		= ftmac100_remove,
 	.driver		= {
 		.name	= DRV_NAME,
 	},
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index ed34196028b8..70347720fdf9 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -807,7 +807,7 @@ static int sgiseeq_probe(struct platform_device *pdev)
 	return err;
 }
 
-static int __exit sgiseeq_remove(struct platform_device *pdev)
+static int sgiseeq_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct sgiseeq_private *sp = netdev_priv(dev);
@@ -822,7 +822,7 @@ static int __exit sgiseeq_remove(struct platform_device *pdev)
 
 static struct platform_driver sgiseeq_driver = {
 	.probe	= sgiseeq_probe,
-	.remove	= __exit_p(sgiseeq_remove),
+	.remove	= sgiseeq_remove,
 	.driver = {
 		.name	= "sgiseeq",
 	}
diff --git a/drivers/net/ethernet/sgi/meth.c b/drivers/net/ethernet/sgi/meth.c
index 69d2d30e5ef1..ea55abd62ec7 100644
--- a/drivers/net/ethernet/sgi/meth.c
+++ b/drivers/net/ethernet/sgi/meth.c
@@ -854,7 +854,7 @@ static int meth_probe(struct platform_device *pdev)
 	return 0;
 }
 
-static int __exit meth_remove(struct platform_device *pdev)
+static int meth_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 
@@ -866,7 +866,7 @@ static int __exit meth_remove(struct platform_device *pdev)
 
 static struct platform_driver meth_driver = {
 	.probe	= meth_probe,
-	.remove	= __exit_p(meth_remove),
+	.remove	= meth_remove,
 	.driver = {
 		.name	= "meth",
 	}
-- 
2.12.0.rc1.440.g5b76565f74-goog


-- 
Dmitry
