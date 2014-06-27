From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 13/30] net: fec: fix missing kmalloc() failure check in
 fec_enet_alloc_buffers()
Date: Fri, 27 Jun 2014 16:19:59 +0100
Message-ID: <E1X0XwV-0001Ne-O0@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45214 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753446AbaF0PUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:20:02 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec_enet_alloc_buffers() assumes that kmalloc() will never fail, which
is an invalid assumption.  Fix this by implementing a common error
cleanup path, and use it to also clean up after failed bounce buffer
allocation.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 8024b7a8e7f4..5cc9eea6d8b3 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2101,19 +2101,16 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 		dma_addr_t addr;
 
 		skb = netdev_alloc_skb(ndev, FEC_ENET_RX_FRSIZE);
-		if (!skb) {
-			fec_enet_free_buffers(ndev);
-			return -ENOMEM;
-		}
+		if (!skb)
+			goto err_alloc;
 
 		addr = dma_map_single(&fep->pdev->dev, skb->data,
 				FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
 		if (dma_mapping_error(&fep->pdev->dev, addr)) {
 			dev_kfree_skb(skb);
-			fec_enet_free_buffers(ndev);
 			if (net_ratelimit())
 				netdev_err(ndev, "Rx DMA memory map failed\n");
-			return -ENOMEM;
+			goto err_alloc;
 		}
 
 		fep->rx_skbuff[i] = skb;
@@ -2135,6 +2132,8 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 	bdp = fep->tx_bd_base;
 	for (i = 0; i < fep->tx_ring_size; i++) {
 		fep->tx_bounce[i] = kmalloc(FEC_ENET_TX_FRSIZE, GFP_KERNEL);
+		if (!fep->tx_bounce[i])
+			goto err_alloc;
 
 		bdp->cbd_sc = 0;
 		bdp->cbd_bufaddr = 0;
@@ -2152,6 +2151,10 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 	bdp->cbd_sc |= BD_SC_WRAP;
 
 	return 0;
+
+ err_alloc:
+	fec_enet_free_buffers(ndev);
+	return -ENOMEM;
 }
 
 static int
-- 
1.8.3.1
