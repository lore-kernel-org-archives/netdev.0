From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: [PATCH] macb: Fix section mismatch and shrink runtime footprint
Date: Thu, 31 Jan 2008 13:10:22 +0100
Message-ID: <1201781422-30181-1-git-send-email-hskinnemoen@atmel.com>
Cc: netdev@vger.kernel.org, David Brownell <david-b@pacbell.net>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:65284 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932376AbYAaMKs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 07:10:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macb devices are only found integrated on SoCs, so they can't be
hotplugged. Thus, the probe() and exit() functions can be __init and
__exit, respectively. By using platform_driver_probe() instead of
platform_driver_register(), there won't be any references to the
discarded probe() function after the driver has loaded.

This also fixes a section mismatch due to macb_probe(), defined as
__devinit, calling macb_get_hwaddr, defined as __init.

Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
---
 drivers/net/macb.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index e10528e..81bf005 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1084,7 +1084,7 @@ static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
 }
 
-static int __devinit macb_probe(struct platform_device *pdev)
+static int __init macb_probe(struct platform_device *pdev)
 {
 	struct eth_platform_data *pdata;
 	struct resource *regs;
@@ -1248,7 +1248,7 @@ err_out:
 	return err;
 }
 
-static int __devexit macb_remove(struct platform_device *pdev)
+static int __exit macb_remove(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct macb *bp;
@@ -1276,8 +1276,7 @@ static int __devexit macb_remove(struct platform_device *pdev)
 }
 
 static struct platform_driver macb_driver = {
-	.probe		= macb_probe,
-	.remove		= __devexit_p(macb_remove),
+	.remove		= __exit_p(macb_remove),
 	.driver		= {
 		.name		= "macb",
 	},
@@ -1285,7 +1284,7 @@ static struct platform_driver macb_driver = {
 
 static int __init macb_init(void)
 {
-	return platform_driver_register(&macb_driver);
+	return platform_driver_probe(&macb_driver, macb_probe);
 }
 
 static void __exit macb_exit(void)
-- 
1.5.3.8

