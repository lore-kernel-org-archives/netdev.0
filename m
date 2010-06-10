From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH] ethoc: Write bus addresses to registers
Date: Thu, 10 Jun 2010 16:59:18 +0200
Message-ID: <1276181958-31172-1-git-send-email-jonas@southpole.se>
References: <20100523.231712.165155558.davem@davemloft.net>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:43530 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589Ab0FJO71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 10:59:27 -0400
In-Reply-To: <20100523.231712.165155558.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethoc driver should be writing bus addresses to the ethoc registers, not
virtual addresses.  This patch adds an array to store the virtual addresses
in and references that array when manipulating the contents of the buffer
descriptors.
---

This patch mainly for review.  I've tested this on my architecture-specific
branch, but this patch specifically (rebased against 2.6.35 master) has not 
been tested.

 drivers/net/ethoc.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 6ed2df1..c1951f6 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -180,6 +180,7 @@ MODULE_PARM_DESC(buffer_size, "DMA buffer allocation size");
  * @dty_tx:	last buffer actually sent
  * @num_rx:	number of receive buffers
  * @cur_rx:	current receive buffer
+ * @vma:        pointer to array of virtual memory addresses for buffers
  * @netdev:	pointer to network device structure
  * @napi:	NAPI structure
  * @stats:	network device statistics
@@ -203,6 +204,8 @@ struct ethoc {
 	unsigned int num_rx;
 	unsigned int cur_rx;
 
+	void** vma;
+
 	struct net_device *netdev;
 	struct napi_struct napi;
 	struct net_device_stats stats;
@@ -285,18 +288,20 @@ static inline void ethoc_disable_rx_and_tx(struct ethoc *dev)
 	ethoc_write(dev, MODER, mode);
 }
 
-static int ethoc_init_ring(struct ethoc *dev)
+static int ethoc_init_ring(struct ethoc *dev, void* mem_start)
 {
 	struct ethoc_bd bd;
 	int i;
+	void* vma;
 
 	dev->cur_tx = 0;
 	dev->dty_tx = 0;
 	dev->cur_rx = 0;
 
 	/* setup transmission buffers */
-	bd.addr = virt_to_phys(dev->membase);
+	bd.addr = mem_start;
 	bd.stat = TX_BD_IRQ | TX_BD_CRC;
+	vma = dev->membase;
 
 	for (i = 0; i < dev->num_tx; i++) {
 		if (i == dev->num_tx - 1)
@@ -304,6 +309,9 @@ static int ethoc_init_ring(struct ethoc *dev)
 
 		ethoc_write_bd(dev, i, &bd);
 		bd.addr += ETHOC_BUFSIZ;
+
+		dev->vma[i] = vma;
+		vma += ETHOC_BUFSIZ;
 	}
 
 	bd.stat = RX_BD_EMPTY | RX_BD_IRQ;
@@ -314,6 +322,9 @@ static int ethoc_init_ring(struct ethoc *dev)
 
 		ethoc_write_bd(dev, dev->num_tx + i, &bd);
 		bd.addr += ETHOC_BUFSIZ;
+
+		dev->vma[dev->num_tx + i] = vma;
+		vma += ETHOC_BUFSIZ;
 	}
 
 	return 0;
@@ -415,7 +426,7 @@ static int ethoc_rx(struct net_device *dev, int limit)
 			skb = netdev_alloc_skb_ip_align(dev, size);
 
 			if (likely(skb)) {
-				void *src = phys_to_virt(bd.addr);
+				void *src = priv->vma[entry];
 				memcpy_fromio(skb_put(skb, size), src, size);
 				skb->protocol = eth_type_trans(skb, dev);
 				priv->stats.rx_packets++;
@@ -674,7 +685,7 @@ static int ethoc_open(struct net_device *dev)
 	priv->num_rx = num_bd - priv->num_tx;
 	ethoc_write(priv, TX_BD_NUM, priv->num_tx);
 
-	ethoc_init_ring(priv);
+	ethoc_init_ring(priv, (void*)dev->mem_start);
 	ethoc_reset(priv);
 
 	if (netif_queue_stopped(dev)) {
@@ -838,7 +849,7 @@ static netdev_tx_t ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	else
 		bd.stat &= ~TX_BD_PAD;
 
-	dest = phys_to_virt(bd.addr);
+	dest = priv->vma[entry];
 	memcpy_toio(dest, skb->data, skb->len);
 
 	bd.stat &= ~(TX_BD_STATS | TX_BD_LEN_MASK);
@@ -978,6 +989,12 @@ static int ethoc_probe(struct platform_device *pdev)
 		priv->dma_alloc = buffer_size;
 	}
 
+	priv->vma = devm_kzalloc(&pdev->dev, priv->num_tx*sizeof(void*), GFP_KERNEL);
+	if (!priv->vma) {
+		ret = -ENOMEM;
+		goto error;
+	}
+
 	/* Allow the platform setup code to pass in a MAC address. */
 	if (pdev->dev.platform_data) {
 		struct ethoc_platform_data *pdata =
-- 
1.7.0.4

