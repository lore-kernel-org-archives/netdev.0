From: David Brownell <david-b@pacbell.net>
Subject: [RESEND/UPDATED patch 2.6.25] smc91x section fix
Date: Fri, 18 Apr 2008 20:01:17 -0700
Message-ID: <200804182001.18234.david-b@pacbell.net>
References: <20080225033411.941C328DEAA@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <20080225060220.GA12459@uranus.ravnborg.org> <200802242233.12764.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.sbc.mail.sp1.yahoo.com ([69.147.64.94]:28412 "HELO
	smtp121.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751808AbYDSDBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 23:01:20 -0400
In-Reply-To: <200802242233.12764.david-b@pacbell.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <dbrownell@users.sourceforge.net>

Section fixup:

  WARNING: drivers/net/built-in.o(.text+0x1a2c): Section mismatch
	in reference from the function smc_drv_probe()
	to the function .init.text:smc_probe()
  The function smc_drv_probe() references
  the function __init smc_probe().
  This is often because smc_drv_probe lacks a __init
  annotation or the annotation of smc_probe is wrong.

Also switch to platform_driver_probe(), and mark exit code as such.
Total footprint shrinkage is about 2KB on ARMv5.

Note that few platform devices are actually hotpluggable, and these
smc devices are evidently not exceptions to that rule ... else there
would have been oopsing in this driver from the smc_probe() problem.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
Changes since earlier version:  use platform_driver_probe(), add
the __exit annotations, not how we can know this driver doesn't
need to use hotplug-supporting "__devinit" annotations.

 drivers/net/smc91x.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- g26.orig/drivers/net/smc91x.c	2008-04-18 19:13:57.000000000 -0700
+++ g26/drivers/net/smc91x.c	2008-04-18 19:15:57.000000000 -0700
@@ -2097,7 +2097,8 @@ static inline void smc_request_datacs(st
 	}
 }
 
-static void smc_release_datacs(struct platform_device *pdev, struct net_device *ndev)
+static void __exit smc_release_datacs(struct platform_device *pdev,
+		struct net_device *ndev)
 {
 	if (SMC_CAN_USE_DATACS) {
 		struct smc_local *lp = netdev_priv(ndev);
@@ -2124,7 +2125,7 @@ static void smc_release_datacs(struct pl
  *	0 --> there is a device
  *	anything else, error
  */
-static int smc_drv_probe(struct platform_device *pdev)
+static int __init smc_drv_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
 	struct resource *res, *ires;
@@ -2214,7 +2215,7 @@ static int smc_drv_probe(struct platform
 	return ret;
 }
 
-static int smc_drv_remove(struct platform_device *pdev)
+static int __exit smc_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct smc_local *lp = netdev_priv(ndev);
@@ -2278,8 +2279,7 @@ static int smc_drv_resume(struct platfor
 }
 
 static struct platform_driver smc_driver = {
-	.probe		= smc_drv_probe,
-	.remove		= smc_drv_remove,
+	.remove		= __exit_p(smc_drv_remove),
 	.suspend	= smc_drv_suspend,
 	.resume		= smc_drv_resume,
 	.driver		= {
@@ -2299,7 +2299,7 @@ static int __init smc_init(void)
 #endif
 #endif
 
-	return platform_driver_register(&smc_driver);
+	return platform_driver_probe(&smc_driver, smc_drv_probe);
 }
 
 static void __exit smc_cleanup(void)
