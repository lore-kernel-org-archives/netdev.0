From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 07/30] net: fec: ensure that a disconnected phy isn't
 configured
Date: Fri, 27 Jun 2014 16:19:29 +0100
Message-ID: <E1X0Xw1-0001NF-3k@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45195 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753439AbaF0PTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:19:32 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we disconnect from a phy, we should forget our pointer to it so we
don't accidentally try to configure it.  We handle a NULL phy pointer
correctly in most places, except fec_enet_set_pauseparam().  Fix this
too.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 6a03d7eced4d..cf805468eecc 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1875,6 +1875,9 @@ static int fec_enet_set_pauseparam(struct net_device *ndev,
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
+	if (!fep->phy_dev)
+		return -ENODEV;
+
 	if (pause->tx_pause != pause->rx_pause) {
 		netdev_info(ndev,
 			"hardware only support enable/disable both tx and rx");
@@ -2186,6 +2189,7 @@ fec_enet_close(struct net_device *ndev)
 
 	phy_stop(fep->phy_dev);
 	phy_disconnect(fep->phy_dev);
+	fep->phy_dev = NULL;
 
 	fec_enet_clk_enable(ndev, false);
 	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
-- 
1.8.3.1
