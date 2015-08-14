From: Peter Chen <peter.chen@freescale.com>
Subject: [PATCH 1/1] Revert "net: fec: Ensure clocks are enabled while using mdio bus"
Date: Fri, 14 Aug 2015 13:47:34 +0800
Message-ID: <1439531254-13128-1-git-send-email-peter.chen@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Chen <peter.chen@freescale.com>, <netdev@vger.kernel.org>,
	"Fugang Duan" <B38611@freescale.com>, <shawn.guo@linaro.org>,
	<fabio.estevam@freescale.com>, <tyler.baker@linaro.org>,
	Lucas Stach <l.stach@pengutronix.de>,
	Andrew Lunn <andrew@lunn.ch>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0114.outbound.protection.outlook.com ([207.46.100.114]:61952
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752879AbbHNHas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2015 03:30:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It causes the i.mx6sx sdb board hang when using nfsroot during boots
up at v4.2-rc6.

This reverts commit 8fff755e9f8d0f70a595e79f248695ce6aef5cc3.

Cc: netdev@vger.kernel.org
Cc: Fugang Duan <B38611@freescale.com>
Cc: shawn.guo@linaro.org
Cc: fabio.estevam@freescale.com
Cc: tyler.baker@linaro.org
Cc: Lucas Stach <l.stach@pengutronix.de>
Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Peter Chen <peter.chen@freescale.com>
---

According to Fugang Duan, the i.mx series has different clock control
sequence among SoCs, this patch may only consider certain SoCs.

 drivers/net/ethernet/freescale/fec_main.c | 89 +++++--------------------------
 1 file changed, 13 insertions(+), 76 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 32e3807c..5e8b837 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -24,7 +24,6 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/pm_runtime.h>
 #include <linux/ptrace.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
@@ -78,7 +77,6 @@ static void fec_enet_itr_coal_init(struct net_device *ndev);
 #define FEC_ENET_RAEM_V	0x8
 #define FEC_ENET_RAFL_V	0x8
 #define FEC_ENET_OPD_V	0xFFF0
-#define FEC_MDIO_PM_TIMEOUT  100 /* ms */
 
 static struct platform_device_id fec_devtype[] = {
 	{
@@ -1769,13 +1767,7 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 {
 	struct fec_enet_private *fep = bus->priv;
-	struct device *dev = &fep->pdev->dev;
 	unsigned long time_left;
-	int ret = 0;
-
-	ret = pm_runtime_get_sync(dev);
-	if (IS_ERR_VALUE(ret))
-		return ret;
 
 	fep->mii_timeout = 0;
 	init_completion(&fep->mdio_done);
@@ -1791,30 +1783,18 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	if (time_left == 0) {
 		fep->mii_timeout = 1;
 		netdev_err(fep->netdev, "MDIO read timeout\n");
-		ret = -ETIMEDOUT;
-		goto out;
+		return -ETIMEDOUT;
 	}
 
-	ret = FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
-
-out:
-	pm_runtime_mark_last_busy(dev);
-	pm_runtime_put_autosuspend(dev);
-
-	return ret;
+	/* return value */
+	return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
 }
 
 static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 			   u16 value)
 {
 	struct fec_enet_private *fep = bus->priv;
-	struct device *dev = &fep->pdev->dev;
 	unsigned long time_left;
-	int ret = 0;
-
-	ret = pm_runtime_get_sync(dev);
-	if (IS_ERR_VALUE(ret))
-		return ret;
 
 	fep->mii_timeout = 0;
 	init_completion(&fep->mdio_done);
@@ -1831,13 +1811,10 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	if (time_left == 0) {
 		fep->mii_timeout = 1;
 		netdev_err(fep->netdev, "MDIO write timeout\n");
-		ret  = -ETIMEDOUT;
+		return -ETIMEDOUT;
 	}
 
-	pm_runtime_mark_last_busy(dev);
-	pm_runtime_put_autosuspend(dev);
-
-	return ret;
+	return 0;
 }
 
 static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
@@ -1849,6 +1826,9 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 		ret = clk_prepare_enable(fep->clk_ahb);
 		if (ret)
 			return ret;
+		ret = clk_prepare_enable(fep->clk_ipg);
+		if (ret)
+			goto failed_clk_ipg;
 		if (fep->clk_enet_out) {
 			ret = clk_prepare_enable(fep->clk_enet_out);
 			if (ret)
@@ -1872,6 +1852,7 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 		}
 	} else {
 		clk_disable_unprepare(fep->clk_ahb);
+		clk_disable_unprepare(fep->clk_ipg);
 		if (fep->clk_enet_out)
 			clk_disable_unprepare(fep->clk_enet_out);
 		if (fep->clk_ptp) {
@@ -1893,6 +1874,8 @@ failed_clk_ptp:
 	if (fep->clk_enet_out)
 		clk_disable_unprepare(fep->clk_enet_out);
 failed_clk_enet_out:
+		clk_disable_unprepare(fep->clk_ipg);
+failed_clk_ipg:
 		clk_disable_unprepare(fep->clk_ahb);
 
 	return ret;
@@ -2864,14 +2847,10 @@ fec_enet_open(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int ret;
 
-	ret = pm_runtime_get_sync(&fep->pdev->dev);
-	if (IS_ERR_VALUE(ret))
-		return ret;
-
 	pinctrl_pm_select_default_state(&fep->pdev->dev);
 	ret = fec_enet_clk_enable(ndev, true);
 	if (ret)
-		goto clk_enable;
+		return ret;
 
 	/* I should reset the ring buffers here, but I don't yet know
 	 * a simple way to do that.
@@ -2902,9 +2881,6 @@ err_enet_mii_probe:
 	fec_enet_free_buffers(ndev);
 err_enet_alloc:
 	fec_enet_clk_enable(ndev, false);
-clk_enable:
-	pm_runtime_mark_last_busy(&fep->pdev->dev);
-	pm_runtime_put_autosuspend(&fep->pdev->dev);
 	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
 	return ret;
 }
@@ -2927,9 +2903,6 @@ fec_enet_close(struct net_device *ndev)
 
 	fec_enet_clk_enable(ndev, false);
 	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
-	pm_runtime_mark_last_busy(&fep->pdev->dev);
-	pm_runtime_put_autosuspend(&fep->pdev->dev);
-
 	fec_enet_free_buffers(ndev);
 
 	return 0;
@@ -3415,10 +3388,6 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_clk;
 
-	ret = clk_prepare_enable(fep->clk_ipg);
-	if (ret)
-		goto failed_clk_ipg;
-
 	fep->reg_phy = devm_regulator_get(&pdev->dev, "phy");
 	if (!IS_ERR(fep->reg_phy)) {
 		ret = regulator_enable(fep->reg_phy);
@@ -3431,11 +3400,6 @@ fec_probe(struct platform_device *pdev)
 		fep->reg_phy = NULL;
 	}
 
-	pm_runtime_set_autosuspend_delay(&pdev->dev, FEC_MDIO_PM_TIMEOUT);
-	pm_runtime_use_autosuspend(&pdev->dev);
-	pm_runtime_set_active(&pdev->dev);
-	pm_runtime_enable(&pdev->dev);
-
 	fec_reset_phy(pdev);
 
 	if (fep->bufdesc_ex)
@@ -3483,10 +3447,6 @@ fec_probe(struct platform_device *pdev)
 
 	fep->rx_copybreak = COPYBREAK_DEFAULT;
 	INIT_WORK(&fep->tx_timeout_work, fec_enet_timeout_work);
-
-	pm_runtime_mark_last_busy(&pdev->dev);
-	pm_runtime_put_autosuspend(&pdev->dev);
-
 	return 0;
 
 failed_register:
@@ -3498,8 +3458,6 @@ failed_init:
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
 failed_regulator:
-	clk_disable_unprepare(fep->clk_ipg);
-failed_clk_ipg:
 	fec_enet_clk_enable(ndev, false);
 failed_clk:
 failed_phy:
@@ -3609,28 +3567,7 @@ failed_clk:
 	return ret;
 }
 
-static int __maybe_unused fec_runtime_suspend(struct device *dev)
-{
-	struct net_device *ndev = dev_get_drvdata(dev);
-	struct fec_enet_private *fep = netdev_priv(ndev);
-
-	clk_disable_unprepare(fep->clk_ipg);
-
-	return 0;
-}
-
-static int __maybe_unused fec_runtime_resume(struct device *dev)
-{
-	struct net_device *ndev = dev_get_drvdata(dev);
-	struct fec_enet_private *fep = netdev_priv(ndev);
-
-	return clk_prepare_enable(fep->clk_ipg);
-}
-
-static const struct dev_pm_ops fec_pm_ops = {
-	SET_SYSTEM_SLEEP_PM_OPS(fec_suspend, fec_resume)
-	SET_RUNTIME_PM_OPS(fec_runtime_suspend, fec_runtime_resume, NULL)
-};
+static SIMPLE_DEV_PM_OPS(fec_pm_ops, fec_suspend, fec_resume);
 
 static struct platform_driver fec_driver = {
 	.driver	= {
-- 
1.9.1
