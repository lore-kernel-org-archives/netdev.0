From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH 1/2] stmac: add dwmac glue for NXP 18xx/43xx family
Date: Mon,  4 May 2015 00:14:11 +0200
Message-ID: <1430691251-28119-1-git-send-email-manabian@gmail.com>
References: <3200125.o3jqXuyPfG@wuerfel>
Cc: linux-arm-kernel@lists.infradead.org, manabian@gmail.com,
	peppe.cavallaro@st.com, netdev@vger.kernel.org, davem@davemloft.net
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:36411 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbbECWOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 18:14:38 -0400
Received: by lagv1 with SMTP id v1so93300245lag.3
        for <netdev@vger.kernel.org>; Sun, 03 May 2015 15:14:36 -0700 (PDT)
In-Reply-To: <3200125.o3jqXuyPfG@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>On Saturday 02 May 2015 18:40:41 Joachim Eastwood wrote:
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> @@ -36,6 +36,7 @@ static const struct of_device_id stmmac_dt_ids[] = {
>>         { .compatible = "rockchip,rk3288-gmac", .data = &rk3288_gmac_data},
>>         { .compatible = "amlogic,meson6-dwmac", .data = &meson6_dwmac_data},
>>         { .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
>> +       { .compatible = "nxp,lpc1850-dwmac", .data = &lpc18xx_dwmac_data},
>>         { .compatible = "st,stih415-dwmac", .data = &stih4xx_dwmac_data},
>>         { .compatible = "st,stih416-dwmac", .data = &stih4xx_dwmac_data},
>>         { .compatible = "st,stid127-dwmac", .data = &stid127_dwmac_data},
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
>>
>
>Any chance you could turn this around and do the probing in the normal
>order, with a platform driver that registers to your compatible string
>and calls into a common base module?
>
>Unfortunately, something went wrong when we first started adding platform
>specific hacks to the driver. I tried to fix it up back then, and IIRC
>it was agreed that it should be changed but my patches for some reason
>missed out on getting merged and the mistake propagated afterwards.
>
>It should be fairly straightforward to split the probe function
>into two and export a function that takes a device and a stmmac_of_data
>pointer as arguments, and declare a module_platform_driver in your
>code.

How about something like the patch below. All it does is to play a
little trick with the of_match_device in the dt config function and
export the probe/remove/pm stuff for the driver.

The dwmac-lpc18xx would then become something like this:

static const struct stmmac_of_data lpc18xx_dwmac_data = {
	.has_gmac = 1,
	.setup = lpc18xx_dwmac_setup,
	.init = lpc18xx_dwmac_init,
};

static const struct of_device_id lpc18xx_dwmac_match[] = {
	{ .compatible = "nxp,lpc1850-dwmac", .data = &lpc18xx_dwmac_data },
	{ }
};
MODULE_DEVICE_TABLE(of, lpc18xx_dwmac_match);

static struct platform_driver lpc18xx_dwmac_driver = {
	.probe  = stmmac_pltfr_probe,
	.remove = stmmac_pltfr_remove,
	.driver = {
		.name           = "lpc18xx-dwmac",
		.pm             = &stmmac_pltfr_pm_ops,
		.of_match_table = lpc18xx_dwmac_match,
	},
};
module_platform_driver(lpc18xx_dwmac_driver);

All though this seem to work, stmmac_platform.c could benefit from
some refactoring. But this patch and then fixing the other DT users
could be a first step.

regards,
Joachim Eastwood

---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 14 +++++++++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h |  4 ++++
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index ccfa4fa02f6a..a7d8ae081b24 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -129,11 +129,12 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	struct device_node *np = pdev->dev.of_node;
 	struct stmmac_dma_cfg *dma_cfg;
 	const struct of_device_id *device;
+	struct device *dev = &pdev->dev;
 
 	if (!np)
 		return -ENODEV;
 
-	device = of_match_device(stmmac_dt_ids, &pdev->dev);
+	device = of_match_device(dev->driver->of_match_table, dev);
 	if (!device)
 		return -ENODEV;
 
@@ -264,7 +265,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
  * the necessary platform resources, invoke custom helper (if required) and
  * invoke the main probe function.
  */
-static int stmmac_pltfr_probe(struct platform_device *pdev)
+int stmmac_pltfr_probe(struct platform_device *pdev)
 {
 	int ret = 0;
 	struct resource *res;
@@ -370,6 +371,7 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(stmmac_pltfr_probe);
 
 /**
  * stmmac_pltfr_remove
@@ -377,7 +379,7 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
  * Description: this function calls the main to free the net resources
  * and calls the platforms hook and release the resources (e.g. mem).
  */
-static int stmmac_pltfr_remove(struct platform_device *pdev)
+int stmmac_pltfr_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
@@ -391,6 +393,7 @@ static int stmmac_pltfr_remove(struct platform_device *pdev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(stmmac_pltfr_remove);
 
 #ifdef CONFIG_PM_SLEEP
 /**
@@ -434,8 +437,9 @@ static int stmmac_pltfr_resume(struct device *dev)
 }
 #endif /* CONFIG_PM_SLEEP */
 
-static SIMPLE_DEV_PM_OPS(stmmac_pltfr_pm_ops,
-			 stmmac_pltfr_suspend, stmmac_pltfr_resume);
+SIMPLE_DEV_PM_OPS(stmmac_pltfr_pm_ops, stmmac_pltfr_suspend,
+				       stmmac_pltfr_resume);
+EXPORT_SYMBOL_GPL(stmmac_pltfr_pm_ops);
 
 static struct platform_driver stmmac_pltfr_driver = {
 	.probe = stmmac_pltfr_probe,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index 59fe8fb46a48..5be0b101bffd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -19,6 +19,10 @@
 #ifndef __STMMAC_PLATFORM_H__
 #define __STMMAC_PLATFORM_H__
 
+int stmmac_pltfr_probe(struct platform_device *pdev);
+int stmmac_pltfr_remove(struct platform_device *pdev);
+extern const struct dev_pm_ops stmmac_pltfr_pm_ops;
+
 extern const struct stmmac_of_data lpc18xx_dwmac_data;
 extern const struct stmmac_of_data meson6_dwmac_data;
 extern const struct stmmac_of_data sun7i_gmac_data;
-- 
1.8.0
