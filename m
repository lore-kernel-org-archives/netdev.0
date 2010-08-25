From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH -next-2.6] r6040: Free irq line on error path
Date: Wed, 25 Aug 2010 09:57:55 +0000
Message-ID: <20100825095755.GA8103@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: florian@openwrt.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:49862 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753009Ab0HYJ6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 05:58:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free irq line on error path.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/r6040.c |   33 ++++++++++++++++++++-------------
 1 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 7d482a2..dc54aff 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -751,7 +751,7 @@ static int r6040_open(struct net_device *dev)
 	ret = request_irq(dev->irq, r6040_interrupt,
 		IRQF_SHARED, dev->name, dev);
 	if (ret)
-		return ret;
+		goto out;
 
 	/* Set MAC address */
 	r6040_mac_address(dev);
@@ -759,30 +759,37 @@ static int r6040_open(struct net_device *dev)
 	/* Allocate Descriptor memory */
 	lp->rx_ring =
 		pci_alloc_consistent(lp->pdev, RX_DESC_SIZE, &lp->rx_ring_dma);
-	if (!lp->rx_ring)
-		return -ENOMEM;
+	if (!lp->rx_ring) {
+		ret = -ENOMEM;
+		goto err_free_irq;
+	}
 
 	lp->tx_ring =
 		pci_alloc_consistent(lp->pdev, TX_DESC_SIZE, &lp->tx_ring_dma);
 	if (!lp->tx_ring) {
-		pci_free_consistent(lp->pdev, RX_DESC_SIZE, lp->rx_ring,
-				     lp->rx_ring_dma);
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto err_free_rx_ring;
 	}
 
 	ret = r6040_up(dev);
-	if (ret) {
-		pci_free_consistent(lp->pdev, TX_DESC_SIZE, lp->tx_ring,
-							lp->tx_ring_dma);
-		pci_free_consistent(lp->pdev, RX_DESC_SIZE, lp->rx_ring,
-							lp->rx_ring_dma);
-		return ret;
-	}
+	if (ret)
+		goto err_free_tx_ring;
 
 	napi_enable(&lp->napi);
 	netif_start_queue(dev);
 
 	return 0;
+
+err_free_tx_ring:
+	pci_free_consistent(lp->pdev, TX_DESC_SIZE, lp->tx_ring,
+			lp->tx_ring_dma);
+err_free_rx_ring:
+	pci_free_consistent(lp->pdev, RX_DESC_SIZE, lp->rx_ring,
+			lp->rx_ring_dma);
+err_free_irq:
+	free_irq(dev->irq, dev);
+out:
+	return ret;
 }
 
 static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
-- 
1.6.4.4

