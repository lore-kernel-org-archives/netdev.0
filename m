From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 09/30] net: fec: remove useless fep->opened
Date: Fri, 20 Jun 2014 13:12:29 +0100
Message-ID: <E1WxxgD-0005XP-5K@rmk-PC.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36341 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S967320AbaFTMMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:12:31 -0400
In-Reply-To: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

napi_disable() waits until the NAPI processing has completed, and then
prevents any further polls.  At this point, the driver then clears
fep->opened.  The NAPI poll function uses this to stop processing in
the receive path.  Hence, it will never see this variable cleared,
because the NAPI poll has to complete before it will be cleared.

Therefore, this variable serves no purpose, so let's remove it.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec.h      | 1 -
 drivers/net/ethernet/freescale/fec_main.c | 5 -----
 2 files changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 671d080105a7..96d2a18f1b99 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -308,7 +308,6 @@ struct fec_enet_private {
 
 	struct	platform_device *pdev;
 
-	int	opened;
 	int	dev_id;
 
 	/* Phylib and MDIO interface */
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e0a1ac1826b7..309aa2ff8cc9 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1215,9 +1215,6 @@ fec_enet_rx(struct net_device *ndev, int budget)
 		if ((status & BD_ENET_RX_LAST) == 0)
 			netdev_err(ndev, "rcv is not +last\n");
 
-		if (!fep->opened)
-			goto rx_processing_done;
-
 		/* Check for errors. */
 		if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH | BD_ENET_RX_NO |
 			   BD_ENET_RX_CR | BD_ENET_RX_OV)) {
@@ -2172,7 +2169,6 @@ fec_enet_open(struct net_device *ndev)
 	napi_enable(&fep->napi);
 	phy_start(fep->phy_dev);
 	netif_start_queue(ndev);
-	fep->opened = 1;
 	return 0;
 }
 
@@ -2185,7 +2181,6 @@ fec_enet_close(struct net_device *ndev)
 
 	/* Don't know what to do yet. */
 	napi_disable(&fep->napi);
-	fep->opened = 0;
 	netif_tx_disable(ndev);
 	fec_stop(ndev);
 
-- 
1.8.3.1
