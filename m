From: Joel Stanley <joel@jms.id.au>
Subject: [PATCH net-next v2 6/6] net/faraday: Mask out PHYSTS_CHG interrupt
Date: Thu, 22 Sep 2016 08:35:03 +0930
Message-ID: <20160921230503.23309-7-joel@jms.id.au>
References: <20160921230503.23309-1-joel@jms.id.au>
Cc: clg@kaod.org, gwshan@linux.vnet.ibm.com, andrew@lunn.ch,
        andrew@aj.id.au, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, benh@kernel.crashing.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34984 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934062AbcIUXGM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 19:06:12 -0400
In-Reply-To: <20160921230503.23309-1-joel@jms.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHYSTS_CHG (the ftgmac100's PHY IRQ) is telling the system to go
look at the PHY registers for a link status change.

The interrupt was causing issues on Aspeed SoC where some board designs
had an active high configuration, some active low, and in some cases
repurposed for other functions. When misconfigured Linux would chew 100%
of CPU cycles servicing interrupts:

 [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
 [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
 [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
 [   20.300000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG

While in the ftgmac100 IP can be configured for high, low and edge
sensitivity the current driver always polls the PHY, so we chose to mask
out the interrupt.

See https://patchwork.ozlabs.org/patch/672099/ for more discussion.

Signed-off-by: Joel Stanley <joel@jms.id.au>
---
v2:
 - Reworked to mask out PHYSTS_CHG instead of trying to determine the IRQ line
   level

 drivers/net/ethernet/faraday/ftgmac100.c | 10 +++-------
 drivers/net/ethernet/faraday/ftgmac100.h |  1 +
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index e3653b14008a..90f9c5481290 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1075,14 +1075,12 @@ static int ftgmac100_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (status & priv->int_mask_all & (FTGMAC100_INT_NO_RXBUF |
-			FTGMAC100_INT_RPKT_LOST | FTGMAC100_INT_AHB_ERR |
-			FTGMAC100_INT_PHYSTS_CHG)) {
+			FTGMAC100_INT_RPKT_LOST | FTGMAC100_INT_AHB_ERR)) {
 		if (net_ratelimit())
-			netdev_info(netdev, "[ISR] = 0x%x: %s%s%s%s\n", status,
+			netdev_info(netdev, "[ISR] = 0x%x: %s%s%s\n", status,
 				    status & FTGMAC100_INT_NO_RXBUF ? "NO_RXBUF " : "",
 				    status & FTGMAC100_INT_RPKT_LOST ? "RPKT_LOST " : "",
-				    status & FTGMAC100_INT_AHB_ERR ? "AHB_ERR " : "",
-				    status & FTGMAC100_INT_PHYSTS_CHG ? "PHYSTS_CHG" : "");
+				    status & FTGMAC100_INT_AHB_ERR ? "AHB_ERR " : "");
 
 		if (status & FTGMAC100_INT_NO_RXBUF) {
 			/* RX buffer unavailable */
@@ -1390,7 +1388,6 @@ static int ftgmac100_probe(struct platform_device *pdev)
 			      FTGMAC100_INT_XPKT_ETH |
 			      FTGMAC100_INT_XPKT_LOST |
 			      FTGMAC100_INT_AHB_ERR |
-			      FTGMAC100_INT_PHYSTS_CHG |
 			      FTGMAC100_INT_RPKT_BUF |
 			      FTGMAC100_INT_NO_RXBUF);
 
@@ -1412,7 +1409,6 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 		dev_info(&pdev->dev, "Using NCSI interface\n");
 		priv->use_ncsi = true;
-		priv->int_mask_all &= ~FTGMAC100_INT_PHYSTS_CHG;
 		priv->ndev = ncsi_register_dev(netdev, ftgmac100_ncsi_handler);
 		if (!priv->ndev)
 			goto err_ncsi_dev;
diff --git a/drivers/net/ethernet/faraday/ftgmac100.h b/drivers/net/ethernet/faraday/ftgmac100.h
index 8a377ab1d127..a7ce0ac8858a 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.h
+++ b/drivers/net/ethernet/faraday/ftgmac100.h
@@ -157,6 +157,7 @@
 #define FTGMAC100_MACCR_FULLDUP		(1 << 8)
 #define FTGMAC100_MACCR_GIGA_MODE	(1 << 9)
 #define FTGMAC100_MACCR_CRC_APD		(1 << 10)
+#define FTGMAC100_MACCR_PHY_LINK_LEVEL	(1 << 11)
 #define FTGMAC100_MACCR_RX_RUNT		(1 << 12)
 #define FTGMAC100_MACCR_JUMBO_LF	(1 << 13)
 #define FTGMAC100_MACCR_RX_ALL		(1 << 14)
-- 
2.9.3
