From: David Brownell <david-b@pacbell.net>
Subject: Re: [RESEND/UPDATED patch 2.6.25] smc91x section fix
Date: Fri, 25 Jul 2008 13:11:59 -0700
Message-ID: <200807251311.59329.david-b@pacbell.net>
References: <20080225033411.941C328DEAA@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <200802242233.12764.david-b@pacbell.net> <200804182001.18234.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp117.sbc.mail.sp1.yahoo.com ([69.147.64.90]:33020 "HELO
	smtp117.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751345AbYGYUMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 16:12:03 -0400
In-Reply-To: <200804182001.18234.david-b@pacbell.net>
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

Also switch to platform_driver_probe(), and mark the exit code as such.
Total footprint shrinkage is about 2KB on ARMv5.

Note that few platform devices are actually hotpluggable, and these
smc devices are evidently not exceptions to that rule ... else there
would have been oopsing in this driver from the smc_probe() problem.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
I thought this was queued for 2.6.26, or (later) 2.6.27 ...

 drivers/net/smc91x.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- a/drivers/net/smc91x.c	2008-07-24 21:27:38.000000000 -0700
+++ b/drivers/net/smc91x.c	2008-07-24 21:42:15.000000000 -0700
@@ -2096,7 +2096,8 @@ static inline void smc_request_datacs(st
 	}
 }
 
-static void smc_release_datacs(struct platform_device *pdev, struct net_device *ndev)
+static void __exit smc_release_datacs(struct platform_device *pdev,
+		struct net_device *ndev)
 {
 	if (SMC_CAN_USE_DATACS) {
 		struct smc_local *lp = netdev_priv(ndev);
@@ -2123,7 +2124,7 @@ static void smc_release_datacs(struct pl
  *	0 --> there is a device
  *	anything else, error
  */
-static int smc_drv_probe(struct platform_device *pdev)
+static int __init smc_drv_probe(struct platform_device *pdev)
 {
 	struct smc91x_platdata *pd = pdev->dev.platform_data;
 	struct smc_local *lp;
@@ -2232,7 +2233,7 @@ static int smc_drv_probe(struct platform
 	return ret;
 }
 
-static int smc_drv_remove(struct platform_device *pdev)
+static int __exit smc_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct smc_local *lp = netdev_priv(ndev);
@@ -2296,8 +2297,7 @@ static int smc_drv_resume(struct platfor
 }
 
 static struct platform_driver smc_driver = {
-	.probe		= smc_drv_probe,
-	.remove		= smc_drv_remove,
+	.remove		= __exit_p(smc_drv_remove),
 	.suspend	= smc_drv_suspend,
 	.resume		= smc_drv_resume,
 	.driver		= {
@@ -2317,7 +2317,7 @@ static int __init smc_init(void)
 #endif
 #endif
 
-	return platform_driver_register(&smc_driver);
+	return platform_driver_probe(&smc_driver, smc_drv_probe);
 }
 
 static void __exit smc_cleanup(void)
