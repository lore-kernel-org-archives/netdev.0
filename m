From: Fabio Estevam <festevam@gmail.com>
Subject: Re: Regulator support for smsc911x
Date: Tue, 7 Feb 2012 17:25:48 -0200
Message-ID: <CAOMZO5B2_yq=m8Mer=iV-HsXvF-MZJ-BV2=LTg1CZN+O=yepSQ@mail.gmail.com>
References: <CAOMZO5Bn4jMYjcBC87uD99qYgzXdiH6YxD5xakjftH-U6bbzMQ@mail.gmail.com>
	<CAOMZO5Be_0W6E7Vj7YDLwFUhrqt_7Q748rpj=J2Tbyh9+MP7gQ@mail.gmail.com>
	<20120203074408.GD1990@pengutronix.de>
	<20120203111133.GD3151@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sascha Hauer <s.hauer@pengutronix.de>,
	robert.marklund@stericsson.com, netdev@vger.kernel.org,
	Sascha Hauer <kernel@pengutronix.de>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55234 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756613Ab2BGTZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 14:25:49 -0500
Received: by eaah12 with SMTP id h12so2938261eaa.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 11:25:48 -0800 (PST)
In-Reply-To: <20120203111133.GD3151@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mark,

On Fri, Feb 3, 2012 at 9:11 AM, Mark Brown
<broonie@opensource.wolfsonmicro.com> wrote:

> There's also options c) set up the regulators for the board and d) don't
> enable the regulator API if the board doesn't use regulators.

Option c would require that we change every single board.

The patch below does option d.

What do you think?

diff --git a/arch/arm/mach-ux500/board-mop500.c
b/arch/arm/mach-ux500/board-mop500.c
index 5c00712..3fdd1c2 100644
--- a/arch/arm/mach-ux500/board-mop500.c
+++ b/arch/arm/mach-ux500/board-mop500.c
@@ -157,7 +157,8 @@ static struct platform_device snowball_key_dev = {
 static struct smsc911x_platform_config snowball_sbnet_cfg = {
 	.irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_HIGH,
 	.irq_type = SMSC911X_IRQ_TYPE_PUSH_PULL,
-	.flags = SMSC911X_USE_16BIT | SMSC911X_FORCE_INTERNAL_PHY,
+	.flags = SMSC911X_USE_16BIT | SMSC911X_FORCE_INTERNAL_PHY |
+							SMSC911X_USE_REGULATOR,
 	.shift = 1,
 };

diff --git a/drivers/net/ethernet/smsc/smsc911x.c
b/drivers/net/ethernet/smsc/smsc911x.c
index 6a1cd23..b9f6e67 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -377,8 +377,9 @@ static int smsc911x_enable_resources(struct
platform_device *pdev)
 	struct smsc911x_data *pdata = netdev_priv(ndev);
 	int ret = 0;

-	ret = regulator_bulk_enable(ARRAY_SIZE(pdata->supplies),
-			pdata->supplies);
+	if (pdata->config.flags & SMSC911X_USE_REGULATOR)
+		ret = regulator_bulk_enable(ARRAY_SIZE(pdata->supplies),
+				pdata->supplies);
 	if (ret)
 		netdev_err(ndev, "failed to enable regulators %d\n",
 				ret);
@@ -394,8 +395,9 @@ static int smsc911x_disable_resources(struct
platform_device *pdev)
 	struct smsc911x_data *pdata = netdev_priv(ndev);
 	int ret = 0;

-	ret = regulator_bulk_disable(ARRAY_SIZE(pdata->supplies),
-			pdata->supplies);
+	if (pdata->config.flags & SMSC911X_USE_REGULATOR)
+		ret = regulator_bulk_disable(ARRAY_SIZE(pdata->supplies),
+				pdata->supplies);
 	return ret;
 }

@@ -415,9 +417,11 @@ static int smsc911x_request_resources(struct
platform_device *pdev)
 	/* Request regulators */
 	pdata->supplies[0].supply = "vdd33a";
 	pdata->supplies[1].supply = "vddvario";
-	ret = regulator_bulk_get(&pdev->dev,
-			ARRAY_SIZE(pdata->supplies),
-			pdata->supplies);
+	
+	if (pdata->config.flags & SMSC911X_USE_REGULATOR)
+		ret = regulator_bulk_get(&pdev->dev,
+				ARRAY_SIZE(pdata->supplies),
+				pdata->supplies);
 	if (ret)
 		netdev_err(ndev, "couldn't get regulators %d\n",
 				ret);
@@ -434,8 +438,9 @@ static void smsc911x_free_resources(struct
platform_device *pdev)
 	struct smsc911x_data *pdata = netdev_priv(ndev);

 	/* Free regulators */
-	regulator_bulk_free(ARRAY_SIZE(pdata->supplies),
-			pdata->supplies);
+	if (pdata->config.flags & SMSC911X_USE_REGULATOR)	
+		regulator_bulk_free(ARRAY_SIZE(pdata->supplies),
+				pdata->supplies);
 }

 /* waits for MAC not busy, with timeout.  Only called by smsc911x_mac_read
diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
index 4dde70e..91c59d9 100644
--- a/include/linux/smsc911x.h
+++ b/include/linux/smsc911x.h
@@ -48,6 +48,7 @@ struct smsc911x_platform_config {
 #define SMSC911X_FORCE_INTERNAL_PHY		(BIT(2))
 #define SMSC911X_FORCE_EXTERNAL_PHY 		(BIT(3))
 #define SMSC911X_SAVE_MAC_ADDRESS		(BIT(4))
+#define SMSC911X_USE_REGULATOR			(BIT(5))		

 /*
  * SMSC911X_SWAP_FIFO:
--
