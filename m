From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH] arc_emac: fix compile-time errors & warnings on PPC64
Date: Wed, 26 Jun 2013 11:49:26 +0400
Message-ID: <1372232966-11507-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	<netdev@vger.kernel.org>,
	"Andy Shevchenko" <andy.shevchenko@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Joe Perches <joe@perches.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	<linux-kernel@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	Florian Fainelli <florian@openwrt.org>,
	David Laight <david.laight@aculab.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As reported by "kbuild test robot" there were some errors and warnings
on attempt to build kernel with "make ARCH=powerpc allmodconfig".

And this patch addresses both errors and warnings.
Below is a list of introduced changes:
1. Fix compile-time errors (misspellings in "dma_unmap_single") on PPC.
2. Use DMA address instead of "skb->data" as a pointer to data buffer.
This fixed warnings on pointer to int conversion on 64-bit systems.
3. Re-implemented initial allocation of Rx buffers in "arc_emac_open" in
the same way they're re-allocated during operation (receiving packets).
So once again DMA address could be used instead of "skb->data".
4. Explicitly use EMAC_BUFFER_SIZE for Rx buffers allocation.

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

Cc: netdev@vger.kernel.org
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Joe Perches <joe@perches.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: Mischa Jonker <mjonker@synopsys.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Grant Likely <grant.likely@linaro.org>
Cc: Rob Herring <rob.herring@calxeda.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: linux-kernel@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Florian Fainelli <florian@openwrt.org>
Cc: David Laight <david.laight@aculab.com>
---
 drivers/net/ethernet/arc/emac_main.c |   65 ++++++++++++++++++++--------------
 1 file changed, 39 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 20345f6..f1b121e 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -171,8 +171,8 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 			stats->tx_bytes += skb->len;
 		}
 
-		dma_unmap_single(&ndev->dev, dma_unmap_addr(&tx_buff, addr),
-				 dma_unmap_len(&tx_buff, len), DMA_TO_DEVICE);
+		dma_unmap_single(&ndev->dev, dma_unmap_addr(tx_buff, addr),
+				 dma_unmap_len(tx_buff, len), DMA_TO_DEVICE);
 
 		/* return the sk_buff to system */
 		dev_kfree_skb_irq(skb);
@@ -204,7 +204,6 @@ static int arc_emac_rx(struct net_device *ndev, int budget)
 		struct net_device_stats *stats = &priv->stats;
 		struct buffer_state *rx_buff = &priv->rx_buff[*last_rx_bd];
 		struct arc_emac_bd *rxbd = &priv->rxbd[*last_rx_bd];
-		unsigned int buflen = EMAC_BUFFER_SIZE;
 		unsigned int pktlen, info = le32_to_cpu(rxbd->info);
 		struct sk_buff *skb;
 		dma_addr_t addr;
@@ -226,7 +225,7 @@ static int arc_emac_rx(struct net_device *ndev, int budget)
 				netdev_err(ndev, "incomplete packet received\n");
 
 			/* Return ownership to EMAC */
-			rxbd->info = cpu_to_le32(FOR_EMAC | buflen);
+			rxbd->info = cpu_to_le32(FOR_EMAC | EMAC_BUFFER_SIZE);
 			stats->rx_errors++;
 			stats->rx_length_errors++;
 			continue;
@@ -240,11 +239,12 @@ static int arc_emac_rx(struct net_device *ndev, int budget)
 		skb->dev = ndev;
 		skb->protocol = eth_type_trans(skb, ndev);
 
-		dma_unmap_single(&ndev->dev, dma_unmap_addr(&rx_buff, addr),
-				 dma_unmap_len(&rx_buff, len), DMA_FROM_DEVICE);
+		dma_unmap_single(&ndev->dev, dma_unmap_addr(rx_buff, addr),
+				 dma_unmap_len(rx_buff, len), DMA_FROM_DEVICE);
 
 		/* Prepare the BD for next cycle */
-		rx_buff->skb = netdev_alloc_skb_ip_align(ndev, buflen);
+		rx_buff->skb = netdev_alloc_skb_ip_align(ndev,
+							 EMAC_BUFFER_SIZE);
 		if (unlikely(!rx_buff->skb)) {
 			stats->rx_errors++;
 			/* Because receive_skb is below, increment rx_dropped */
@@ -256,7 +256,7 @@ static int arc_emac_rx(struct net_device *ndev, int budget)
 		netif_receive_skb(skb);
 
 		addr = dma_map_single(&ndev->dev, (void *)rx_buff->skb->data,
-				      buflen, DMA_FROM_DEVICE);
+				      EMAC_BUFFER_SIZE, DMA_FROM_DEVICE);
 		if (dma_mapping_error(&ndev->dev, addr)) {
 			if (net_ratelimit())
 				netdev_err(ndev, "cannot dma map\n");
@@ -264,16 +264,16 @@ static int arc_emac_rx(struct net_device *ndev, int budget)
 			stats->rx_errors++;
 			continue;
 		}
-		dma_unmap_addr_set(&rx_buff, mapping, addr);
-		dma_unmap_len_set(&rx_buff, len, buflen);
+		dma_unmap_addr_set(rx_buff, addr, addr);
+		dma_unmap_len_set(rx_buff, len, EMAC_BUFFER_SIZE);
 
-		rxbd->data = cpu_to_le32(rx_buff->skb->data);
+		rxbd->data = cpu_to_le32(addr);
 
 		/* Make sure pointer to data buffer is set */
 		wmb();
 
 		/* Return ownership to EMAC */
-		rxbd->info = cpu_to_le32(FOR_EMAC | buflen);
+		rxbd->info = cpu_to_le32(FOR_EMAC | EMAC_BUFFER_SIZE);
 	}
 
 	return work_done;
@@ -376,8 +376,6 @@ static int arc_emac_open(struct net_device *ndev)
 {
 	struct arc_emac_priv *priv = netdev_priv(ndev);
 	struct phy_device *phy_dev = priv->phy_dev;
-	struct arc_emac_bd *bd;
-	struct sk_buff *skb;
 	int i;
 
 	phy_dev->autoneg = AUTONEG_ENABLE;
@@ -395,25 +393,40 @@ static int arc_emac_open(struct net_device *ndev)
 		}
 	}
 
+	priv->last_rx_bd = 0;
+
 	/* Allocate and set buffers for Rx BD's */
-	bd = priv->rxbd;
 	for (i = 0; i < RX_BD_NUM; i++) {
-		skb = netdev_alloc_skb_ip_align(ndev, EMAC_BUFFER_SIZE);
-		if (unlikely(!skb))
+		dma_addr_t addr;
+		unsigned int *last_rx_bd = &priv->last_rx_bd;
+		struct arc_emac_bd *rxbd = &priv->rxbd[*last_rx_bd];
+		struct buffer_state *rx_buff = &priv->rx_buff[*last_rx_bd];
+
+		rx_buff->skb = netdev_alloc_skb_ip_align(ndev,
+							 EMAC_BUFFER_SIZE);
+		if (unlikely(!rx_buff->skb))
+			return -ENOMEM;
+
+		addr = dma_map_single(&ndev->dev, (void *)rx_buff->skb->data,
+				      EMAC_BUFFER_SIZE, DMA_FROM_DEVICE);
+		if (dma_mapping_error(&ndev->dev, addr)) {
+			netdev_err(ndev, "cannot dma map\n");
+			dev_kfree_skb(rx_buff->skb);
 			return -ENOMEM;
+		}
+		dma_unmap_addr_set(rx_buff, addr, addr);
+		dma_unmap_len_set(rx_buff, len, EMAC_BUFFER_SIZE);
 
-		priv->rx_buff[i].skb = skb;
-		bd->data = cpu_to_le32(skb->data);
+		rxbd->data = cpu_to_le32(addr);
 
 		/* Make sure pointer to data buffer is set */
 		wmb();
 
-		/* Set ownership to EMAC */
-		bd->info = cpu_to_le32(FOR_EMAC | EMAC_BUFFER_SIZE);
-		bd++;
-	}
+		/* Return ownership to EMAC */
+		rxbd->info = cpu_to_le32(FOR_EMAC | EMAC_BUFFER_SIZE);
 
-	priv->last_rx_bd = 0;
+		*last_rx_bd = (*last_rx_bd + 1) % RX_BD_NUM;
+	}
 
 	/* Clean Tx BD's */
 	memset(priv->txbd, 0, TX_RING_SZ);
@@ -543,11 +556,11 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
-	dma_unmap_addr_set(&priv->tx_buff[*txbd_curr], mapping, addr);
+	dma_unmap_addr_set(&priv->tx_buff[*txbd_curr], addr, addr);
 	dma_unmap_len_set(&priv->tx_buff[*txbd_curr], len, len);
 
 	priv->tx_buff[*txbd_curr].skb = skb;
-	priv->txbd[*txbd_curr].data = cpu_to_le32(skb->data);
+	priv->txbd[*txbd_curr].data = cpu_to_le32(addr);
 
 	/* Make sure pointer to data buffer is set */
 	wmb();
-- 
1.7.10.4
