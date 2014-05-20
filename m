From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 2/2] net: fec: use pinctrl PM helpers
Date: Tue, 20 May 2014 14:50:45 +0800
Message-ID: <1400568645-10214-3-git-send-email-b38611@freescale.com>
References: <1400568645-10214-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<kernel@pengutronix.de>, <B38611@freescale.com>,
	<b20596@freescale.com>
To: <davem@davemloft.net>, <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0144.outbound.protection.outlook.com ([207.46.163.144]:2307
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751966AbaETIMO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 04:12:14 -0400
In-Reply-To: <1400568645-10214-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when system suspend, need to set pins to low power state to
save IO power consumption, there are three states of pinctrl:
"default", "idle" and "sleep". Currently enet supports default
and sleep state.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index cb5c987..2053dac 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1816,6 +1816,7 @@ fec_enet_open(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int ret;
 
+	pinctrl_pm_select_default_state(&fep->pdev->dev);
 	ret = fec_enet_clk_enable(ndev, true);
 	if (ret)
 		return ret;
@@ -1859,6 +1860,7 @@ fec_enet_close(struct net_device *ndev)
 	}
 
 	fec_enet_clk_enable(ndev, false);
+	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
 	fec_enet_free_buffers(ndev);
 
 	return 0;
@@ -2162,6 +2164,9 @@ fec_probe(struct platform_device *pdev)
 		fep->pause_flag |= FEC_PAUSE_FLAG_AUTONEG;
 #endif
 
+	/* Select default pin state */
+	pinctrl_pm_select_default_state(&pdev->dev);
+
 	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	fep->hwp = devm_ioremap_resource(&pdev->dev, r);
 	if (IS_ERR(fep->hwp)) {
@@ -2258,6 +2263,7 @@ fec_probe(struct platform_device *pdev)
 	/* Carrier starts down, phylib will bring it up */
 	netif_carrier_off(ndev);
 	fec_enet_clk_enable(ndev, false);
+	pinctrl_pm_select_sleep_state(&pdev->dev);
 
 	ret = register_netdev(ndev);
 	if (ret)
@@ -2321,6 +2327,8 @@ fec_suspend(struct device *dev)
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
 
+	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
+
 	return 0;
 }
 
@@ -2331,6 +2339,8 @@ fec_resume(struct device *dev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int ret;
 
+	pinctrl_pm_select_default_state(&fep->pdev->dev);
+
 	if (fep->reg_phy) {
 		ret = regulator_enable(fep->reg_phy);
 		if (ret)
-- 
1.7.8
