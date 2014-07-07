From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH A 12/12] net: fec: fix missing kmalloc() failure check in
 fec_enet_alloc_buffers()
Date: Tue, 08 Jul 2014 00:23:30 +0100
Message-ID: <E1X4IFu-0004xQ-5y@rmk-PC.arm.linux.org.uk>
References: <20140707232148.GG21766@n2100.arm.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:58002 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752903AbaGGXXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 19:23:32 -0400
In-Reply-To: <20140707232148.GG21766@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec_enet_alloc_buffers() assumes that kmalloc() will never fail, which
is an invalid assumption.  Fix this by implementing a common error
cleanup path, and use it to also clean up after failed bounce buffer
allocation.

Acked-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 5499bd8ad0a5..f43c388e2eb9 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2100,19 +2100,16 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
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
@@ -2134,6 +2131,8 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 	bdp = fep->tx_bd_base;
 	for (i = 0; i < fep->tx_ring_size; i++) {
 		fep->tx_bounce[i] = kmalloc(FEC_ENET_TX_FRSIZE, GFP_KERNEL);
+		if (!fep->tx_bounce[i])
+			goto err_alloc;
 
 		bdp->cbd_sc = 0;
 		bdp->cbd_bufaddr = 0;
@@ -2151,6 +2150,10 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
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
