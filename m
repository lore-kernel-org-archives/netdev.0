From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH v2 4/5] net: sh_eth: add support for set_ringparam/get_ringparam
Date: Fri, 11 May 2012 17:38:29 +0900
Message-ID: <4FACD005.3010800@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch supports the ethtool's set_ringparam() and get_ringparam().

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 about v2:
  - the previous patch decided the ring size at compile time

 drivers/net/ethernet/renesas/sh_eth.c |  111 +++++++++++++++++++++++++-------
 drivers/net/ethernet/renesas/sh_eth.h |    6 ++
 2 files changed, 92 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 906e410..1bcf205 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -739,7 +739,7 @@ static void sh_eth_ring_free(struct net_device *ndev)

 	/* Free Rx skb ringbuffer */
 	if (mdp->rx_skbuff) {
-		for (i = 0; i < RX_RING_SIZE; i++) {
+		for (i = 0; i < mdp->num_rx_ring; i++) {
 			if (mdp->rx_skbuff[i])
 				dev_kfree_skb(mdp->rx_skbuff[i]);
 		}
@@ -748,7 +748,7 @@ static void sh_eth_ring_free(struct net_device *ndev)

 	/* Free Tx skb ringbuffer */
 	if (mdp->tx_skbuff) {
-		for (i = 0; i < TX_RING_SIZE; i++) {
+		for (i = 0; i < mdp->num_tx_ring; i++) {
 			if (mdp->tx_skbuff[i])
 				dev_kfree_skb(mdp->tx_skbuff[i]);
 		}
@@ -764,8 +764,8 @@ static void sh_eth_ring_format(struct net_device *ndev)
 	struct sk_buff *skb;
 	struct sh_eth_rxdesc *rxdesc = NULL;
 	struct sh_eth_txdesc *txdesc = NULL;
-	int rx_ringsize = sizeof(*rxdesc) * RX_RING_SIZE;
-	int tx_ringsize = sizeof(*txdesc) * TX_RING_SIZE;
+	int rx_ringsize = sizeof(*rxdesc) * mdp->num_rx_ring;
+	int tx_ringsize = sizeof(*txdesc) * mdp->num_tx_ring;

 	mdp->cur_rx = mdp->cur_tx = 0;
 	mdp->dirty_rx = mdp->dirty_tx = 0;
@@ -773,7 +773,7 @@ static void sh_eth_ring_format(struct net_device *ndev)
 	memset(mdp->rx_ring, 0, rx_ringsize);

 	/* build Rx ring buffer */
-	for (i = 0; i < RX_RING_SIZE; i++) {
+	for (i = 0; i < mdp->num_rx_ring; i++) {
 		/* skb */
 		mdp->rx_skbuff[i] = NULL;
 		skb = netdev_alloc_skb(ndev, mdp->rx_buf_sz);
@@ -799,7 +799,7 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		}
 	}

-	mdp->dirty_rx = (u32) (i - RX_RING_SIZE);
+	mdp->dirty_rx = (u32) (i - mdp->num_rx_ring);

 	/* Mark the last entry as wrapping the ring. */
 	rxdesc->status |= cpu_to_edmac(mdp, RD_RDEL);
@@ -807,7 +807,7 @@ static void sh_eth_ring_format(struct net_device *ndev)
 	memset(mdp->tx_ring, 0, tx_ringsize);

 	/* build Tx ring buffer */
-	for (i = 0; i < TX_RING_SIZE; i++) {
+	for (i = 0; i < mdp->num_tx_ring; i++) {
 		mdp->tx_skbuff[i] = NULL;
 		txdesc = &mdp->tx_ring[i];
 		txdesc->status = cpu_to_edmac(mdp, TD_TFP);
@@ -841,7 +841,7 @@ static int sh_eth_ring_init(struct net_device *ndev)
 		mdp->rx_buf_sz += NET_IP_ALIGN;

 	/* Allocate RX and TX skb rings */
-	mdp->rx_skbuff = kmalloc(sizeof(*mdp->rx_skbuff) * RX_RING_SIZE,
+	mdp->rx_skbuff = kmalloc(sizeof(*mdp->rx_skbuff) * mdp->num_rx_ring,
 				GFP_KERNEL);
 	if (!mdp->rx_skbuff) {
 		dev_err(&ndev->dev, "Cannot allocate Rx skb\n");
@@ -849,7 +849,7 @@ static int sh_eth_ring_init(struct net_device *ndev)
 		return ret;
 	}

-	mdp->tx_skbuff = kmalloc(sizeof(*mdp->tx_skbuff) * TX_RING_SIZE,
+	mdp->tx_skbuff = kmalloc(sizeof(*mdp->tx_skbuff) * mdp->num_tx_ring,
 				GFP_KERNEL);
 	if (!mdp->tx_skbuff) {
 		dev_err(&ndev->dev, "Cannot allocate Tx skb\n");
@@ -858,7 +858,7 @@ static int sh_eth_ring_init(struct net_device *ndev)
 	}

 	/* Allocate all Rx descriptors. */
-	rx_ringsize = sizeof(struct sh_eth_rxdesc) * RX_RING_SIZE;
+	rx_ringsize = sizeof(struct sh_eth_rxdesc) * mdp->num_rx_ring;
 	mdp->rx_ring = dma_alloc_coherent(NULL, rx_ringsize, &mdp->rx_desc_dma,
 			GFP_KERNEL);

@@ -872,7 +872,7 @@ static int sh_eth_ring_init(struct net_device *ndev)
 	mdp->dirty_rx = 0;

 	/* Allocate all Tx descriptors. */
-	tx_ringsize = sizeof(struct sh_eth_txdesc) * TX_RING_SIZE;
+	tx_ringsize = sizeof(struct sh_eth_txdesc) * mdp->num_tx_ring;
 	mdp->tx_ring = dma_alloc_coherent(NULL, tx_ringsize, &mdp->tx_desc_dma,
 			GFP_KERNEL);
 	if (!mdp->tx_ring) {
@@ -985,7 +985,7 @@ static int sh_eth_txfree(struct net_device *ndev)
 	int entry = 0;

 	for (; mdp->cur_tx - mdp->dirty_tx > 0; mdp->dirty_tx++) {
-		entry = mdp->dirty_tx % TX_RING_SIZE;
+		entry = mdp->dirty_tx % mdp->num_tx_ring;
 		txdesc = &mdp->tx_ring[entry];
 		if (txdesc->status & cpu_to_edmac(mdp, TD_TACT))
 			break;
@@ -998,7 +998,7 @@ static int sh_eth_txfree(struct net_device *ndev)
 			freeNum++;
 		}
 		txdesc->status = cpu_to_edmac(mdp, TD_TFP);
-		if (entry >= TX_RING_SIZE - 1)
+		if (entry >= mdp->num_tx_ring - 1)
 			txdesc->status |= cpu_to_edmac(mdp, TD_TDLE);

 		ndev->stats.tx_packets++;
@@ -1013,8 +1013,8 @@ static int sh_eth_rx(struct net_device *ndev)
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_rxdesc *rxdesc;

-	int entry = mdp->cur_rx % RX_RING_SIZE;
-	int boguscnt = (mdp->dirty_rx + RX_RING_SIZE) - mdp->cur_rx;
+	int entry = mdp->cur_rx % mdp->num_rx_ring;
+	int boguscnt = (mdp->dirty_rx + mdp->num_rx_ring) - mdp->cur_rx;
 	struct sk_buff *skb;
 	u16 pkt_len = 0;
 	u32 desc_status;
@@ -1065,13 +1065,13 @@ static int sh_eth_rx(struct net_device *ndev)
 			ndev->stats.rx_bytes += pkt_len;
 		}
 		rxdesc->status |= cpu_to_edmac(mdp, RD_RACT);
-		entry = (++mdp->cur_rx) % RX_RING_SIZE;
+		entry = (++mdp->cur_rx) % mdp->num_rx_ring;
 		rxdesc = &mdp->rx_ring[entry];
 	}

 	/* Refill the Rx ring buffers. */
 	for (; mdp->cur_rx - mdp->dirty_rx > 0; mdp->dirty_rx++) {
-		entry = mdp->dirty_rx % RX_RING_SIZE;
+		entry = mdp->dirty_rx % mdp->num_rx_ring;
 		rxdesc = &mdp->rx_ring[entry];
 		/* The size of the buffer is 16 byte boundary. */
 		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
@@ -1088,7 +1088,7 @@ static int sh_eth_rx(struct net_device *ndev)
 			skb_checksum_none_assert(skb);
 			rxdesc->addr = virt_to_phys(PTR_ALIGN(skb->data, 4));
 		}
-		if (entry >= RX_RING_SIZE - 1)
+		if (entry >= mdp->num_rx_ring - 1)
 			rxdesc->status |=
 				cpu_to_edmac(mdp, RD_RACT | RD_RFP | RD_RDEL);
 		else
@@ -1486,6 +1486,63 @@ static void sh_eth_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
 	}
 }

+static void sh_eth_get_ringparam(struct net_device *ndev,
+				 struct ethtool_ringparam *ring)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	ring->rx_max_pending = RX_RING_MAX;
+	ring->tx_max_pending = TX_RING_MAX;
+	ring->rx_pending = mdp->num_rx_ring;
+	ring->tx_pending = mdp->num_tx_ring;
+}
+
+static int sh_eth_set_ringparam(struct net_device *ndev,
+				struct ethtool_ringparam *ring)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int ringsize;
+
+	if (ring->tx_pending > TX_RING_MAX ||
+	    ring->rx_pending > RX_RING_MAX ||
+	    ring->tx_pending < TX_RING_MIN ||
+	    ring->rx_pending < RX_RING_MIN)
+		return -EINVAL;
+	if (ring->rx_mini_pending || ring->rx_jumbo_pending)
+		return -EINVAL;
+
+	if (netif_running(ndev)) {
+		/* Disable interrupts by clearing the interrupt mask. */
+		sh_eth_write(ndev, 0x0000, EESIPR);
+		/* Stop the chip's Tx and Rx processes. */
+		sh_eth_write(ndev, 0, EDTRR);
+		sh_eth_write(ndev, 0, EDRRR);
+	}
+
+	/* Free all the skbuffs in the Rx queue. */
+	sh_eth_ring_free(ndev);
+	/* Free DMA buffer */
+	ringsize = sizeof(struct sh_eth_rxdesc) * mdp->num_rx_ring;
+	dma_free_coherent(NULL, ringsize, mdp->rx_ring, mdp->rx_desc_dma);
+	ringsize = sizeof(struct sh_eth_txdesc) * mdp->num_tx_ring;
+	dma_free_coherent(NULL, ringsize, mdp->tx_ring, mdp->tx_desc_dma);
+
+	/* Set new parameters */
+	mdp->num_rx_ring = ring->rx_pending;
+	mdp->num_tx_ring = ring->tx_pending;
+
+	sh_eth_ring_init(ndev);
+	sh_eth_dev_init(ndev);
+
+	if (netif_running(ndev)) {
+		sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
+		/* Setting the Rx mode will start the Rx process. */
+		sh_eth_write(ndev, EDRRR_R, EDRRR);
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops sh_eth_ethtool_ops = {
 	.get_settings	= sh_eth_get_settings,
 	.set_settings	= sh_eth_set_settings,
@@ -1496,6 +1553,8 @@ static const struct ethtool_ops sh_eth_ethtool_ops = {
 	.get_strings	= sh_eth_get_strings,
 	.get_ethtool_stats  = sh_eth_get_ethtool_stats,
 	.get_sset_count     = sh_eth_get_sset_count,
+	.get_ringparam	= sh_eth_get_ringparam,
+	.set_ringparam	= sh_eth_set_ringparam,
 };

 /* network device open function */
@@ -1560,7 +1619,7 @@ static void sh_eth_tx_timeout(struct net_device *ndev)
 	ndev->stats.tx_errors++;

 	/* Free all the skbuffs in the Rx queue. */
-	for (i = 0; i < RX_RING_SIZE; i++) {
+	for (i = 0; i < mdp->num_rx_ring; i++) {
 		rxdesc = &mdp->rx_ring[i];
 		rxdesc->status = 0;
 		rxdesc->addr = 0xBADF00D0;
@@ -1568,7 +1627,7 @@ static void sh_eth_tx_timeout(struct net_device *ndev)
 			dev_kfree_skb(mdp->rx_skbuff[i]);
 		mdp->rx_skbuff[i] = NULL;
 	}
-	for (i = 0; i < TX_RING_SIZE; i++) {
+	for (i = 0; i < mdp->num_tx_ring; i++) {
 		if (mdp->tx_skbuff[i])
 			dev_kfree_skb(mdp->tx_skbuff[i]);
 		mdp->tx_skbuff[i] = NULL;
@@ -1587,7 +1646,7 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	unsigned long flags;

 	spin_lock_irqsave(&mdp->lock, flags);
-	if ((mdp->cur_tx - mdp->dirty_tx) >= (TX_RING_SIZE - 4)) {
+	if ((mdp->cur_tx - mdp->dirty_tx) >= (mdp->num_tx_ring - 4)) {
 		if (!sh_eth_txfree(ndev)) {
 			if (netif_msg_tx_queued(mdp))
 				dev_warn(&ndev->dev, "TxFD exhausted.\n");
@@ -1598,7 +1657,7 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	}
 	spin_unlock_irqrestore(&mdp->lock, flags);

-	entry = mdp->cur_tx % TX_RING_SIZE;
+	entry = mdp->cur_tx % mdp->num_tx_ring;
 	mdp->tx_skbuff[entry] = skb;
 	txdesc = &mdp->tx_ring[entry];
 	/* soft swap. */
@@ -1612,7 +1671,7 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	else
 		txdesc->buffer_length = skb->len;

-	if (entry >= TX_RING_SIZE - 1)
+	if (entry >= mdp->num_tx_ring - 1)
 		txdesc->status |= cpu_to_edmac(mdp, TD_TACT | TD_TDLE);
 	else
 		txdesc->status |= cpu_to_edmac(mdp, TD_TACT);
@@ -1652,11 +1711,11 @@ static int sh_eth_close(struct net_device *ndev)
 	sh_eth_ring_free(ndev);

 	/* free DMA buffer */
-	ringsize = sizeof(struct sh_eth_rxdesc) * RX_RING_SIZE;
+	ringsize = sizeof(struct sh_eth_rxdesc) * mdp->num_rx_ring;
 	dma_free_coherent(NULL, ringsize, mdp->rx_ring, mdp->rx_desc_dma);

 	/* free DMA buffer */
-	ringsize = sizeof(struct sh_eth_txdesc) * TX_RING_SIZE;
+	ringsize = sizeof(struct sh_eth_txdesc) * mdp->num_tx_ring;
 	dma_free_coherent(NULL, ringsize, mdp->tx_ring, mdp->tx_desc_dma);

 	pm_runtime_put_sync(&mdp->pdev->dev);
@@ -2248,6 +2307,8 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	ether_setup(ndev);

 	mdp = netdev_priv(ndev);
+	mdp->num_tx_ring = TX_RING_SIZE;
+	mdp->num_rx_ring = RX_RING_SIZE;
 	mdp->addr = ioremap(res->start, resource_size(res));
 	if (mdp->addr == NULL) {
 		ret = -ENOMEM;
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 9525199..f1dbc27 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -27,6 +27,10 @@
 #define TX_TIMEOUT	(5*HZ)
 #define TX_RING_SIZE	64	/* Tx ring size */
 #define RX_RING_SIZE	64	/* Rx ring size */
+#define TX_RING_MIN	64
+#define RX_RING_MIN	64
+#define TX_RING_MAX	1024
+#define RX_RING_MAX	1024
 #define ETHERSMALL		60
 #define PKT_BUF_SZ		1538
 #define SH_ETH_TSU_TIMEOUT_MS	500
@@ -700,6 +704,8 @@ struct sh_eth_private {
 	const u16 *reg_offset;
 	void __iomem *addr;
 	void __iomem *tsu_addr;
+	u32 num_rx_ring;
+	u32 num_tx_ring;
 	dma_addr_t rx_desc_dma;
 	dma_addr_t tx_desc_dma;
 	struct sh_eth_rxdesc *rx_ring;
-- 
1.7.1
