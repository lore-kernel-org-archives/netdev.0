From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] net: lpc_eth: Check clk_prepare_enable() error
Date: Mon, 22 Aug 2016 23:01:18 -0300
Message-ID: <1471917678-9130-1-git-send-email-festevam@gmail.com>
Cc: vz@mleia.com, netdev@vger.kernel.org,
        Fabio Estevam <fabio.estevam@nxp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36611 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753509AbcHWCCY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 22:02:24 -0400
Received: by mail-qt0-f196.google.com with SMTP id u25so3352514qtb.3
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 19:02:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@nxp.com>

clk_prepare_enable() may fail, so we should better check its return
value and propagate it in the case of failure.

Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
---
 drivers/net/ethernet/nxp/lpc_eth.c | 29 ++++++++++++++++++++++-------
 1 file changed, 22 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 4d4ecba..7c796f7 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -475,12 +475,19 @@ static void __lpc_get_mac(struct netdata_local *pldat, u8 *mac)
 	mac[5] = tmp >> 8;
 }
 
-static void __lpc_eth_clock_enable(struct netdata_local *pldat, bool enable)
+static int __lpc_eth_clock_enable(struct netdata_local *pldat, bool enable)
 {
-	if (enable)
-		clk_prepare_enable(pldat->clk);
-	else
+	int ret;
+
+	if (enable) {
+		ret = clk_prepare_enable(pldat->clk);
+		if (ret)
+			return ret;
+	} else {
 		clk_disable_unprepare(pldat->clk);
+	}
+
+	return 0;
 }
 
 static void __lpc_params_setup(struct netdata_local *pldat)
@@ -1039,6 +1046,7 @@ static int lpc_eth_close(struct net_device *ndev)
 {
 	unsigned long flags;
 	struct netdata_local *pldat = netdev_priv(ndev);
+	int ret;
 
 	if (netif_msg_ifdown(pldat))
 		dev_dbg(&pldat->pdev->dev, "shutting down %s\n", ndev->name);
@@ -1056,7 +1064,9 @@ static int lpc_eth_close(struct net_device *ndev)
 	writel(0, LPC_ENET_MAC2(pldat->net_base));
 	spin_unlock_irqrestore(&pldat->lock, flags);
 
-	__lpc_eth_clock_enable(pldat, false);
+	ret = __lpc_eth_clock_enable(pldat, false);
+	if (ret)
+		return ret;
 
 	return 0;
 }
@@ -1197,11 +1207,14 @@ static int lpc_eth_ioctl(struct net_device *ndev, struct ifreq *req, int cmd)
 static int lpc_eth_open(struct net_device *ndev)
 {
 	struct netdata_local *pldat = netdev_priv(ndev);
+	int ret;
 
 	if (netif_msg_ifup(pldat))
 		dev_dbg(&pldat->pdev->dev, "enabling %s\n", ndev->name);
 
-	__lpc_eth_clock_enable(pldat, true);
+	ret = __lpc_eth_clock_enable(pldat, true);
+	if (ret)
+		return ret;
 
 	/* Suspended PHY makes LPC ethernet core block, so resume now */
 	phy_resume(ndev->phydev);
@@ -1320,7 +1333,9 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	}
 
 	/* Enable network clock */
-	__lpc_eth_clock_enable(pldat, true);
+	ret = __lpc_eth_clock_enable(pldat, true);
+	if (ret)
+		goto err_out_free_dev;
 
 	/* Map IO space */
 	pldat->net_base = ioremap(res->start, resource_size(res));
-- 
1.9.1
