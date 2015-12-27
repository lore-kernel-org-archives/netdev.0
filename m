From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: get rid of {cpu|edmac}_to_{edmac|cpu}()
Date: Mon, 28 Dec 2015 02:10:47 +0300
Message-ID: <7645144.Pie2WFS3t2@wasted.cogentembedded.com>
References: <27915743.MLN0FvErP3@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <27915743.MLN0FvErP3@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that {cpu|edmac}_to_{edmac|cpu}() functions boiled down to the mere
{cpu|le32}_to_{le32|cpu}() calls, there's no need for these functions
anymore, so just get rid of them.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   72 +++++++++++++---------------------
 1 file changed, 29 insertions(+), 43 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -967,18 +967,6 @@ static void sh_eth_set_receive_align(str
 		skb_reserve(skb, SH_ETH_RX_ALIGN - reserve);
 }
 
-
-/* CPU <-> EDMAC endian convert */
-static inline __u32 cpu_to_edmac(struct sh_eth_private *mdp, u32 x)
-{
-	return cpu_to_le32(x);
-}
-
-static inline __u32 edmac_to_cpu(struct sh_eth_private *mdp, u32 x)
-{
-	return le32_to_cpu(x);
-}
-
 /* Program the hardware MAC address from dev->dev_addr. */
 static void update_mac_address(struct net_device *ndev)
 {
@@ -1152,7 +1140,7 @@ static void sh_eth_ring_format(struct ne
 		rxdesc = &mdp->rx_ring[i];
 		/* The size of the buffer is a multiple of 32 bytes. */
 		buf_len = ALIGN(mdp->rx_buf_sz, 32);
-		rxdesc->len = cpu_to_edmac(mdp, buf_len << 16);
+		rxdesc->len = cpu_to_le32(buf_len << 16);
 		dma_addr = dma_map_single(&ndev->dev, skb->data, buf_len,
 					  DMA_FROM_DEVICE);
 		if (dma_mapping_error(&ndev->dev, dma_addr)) {
@@ -1160,8 +1148,8 @@ static void sh_eth_ring_format(struct ne
 			break;
 		}
 		mdp->rx_skbuff[i] = skb;
-		rxdesc->addr = cpu_to_edmac(mdp, dma_addr);
-		rxdesc->status = cpu_to_edmac(mdp, RD_RACT | RD_RFP);
+		rxdesc->addr = cpu_to_le32(dma_addr);
+		rxdesc->status = cpu_to_le32(RD_RACT | RD_RFP);
 
 		/* Rx descriptor address set */
 		if (i == 0) {
@@ -1175,7 +1163,7 @@ static void sh_eth_ring_format(struct ne
 	mdp->dirty_rx = (u32) (i - mdp->num_rx_ring);
 
 	/* Mark the last entry as wrapping the ring. */
-	rxdesc->status |= cpu_to_edmac(mdp, RD_RDLE);
+	rxdesc->status |= cpu_to_le32(RD_RDLE);
 
 	memset(mdp->tx_ring, 0, tx_ringsize);
 
@@ -1183,8 +1171,8 @@ static void sh_eth_ring_format(struct ne
 	for (i = 0; i < mdp->num_tx_ring; i++) {
 		mdp->tx_skbuff[i] = NULL;
 		txdesc = &mdp->tx_ring[i];
-		txdesc->status = cpu_to_edmac(mdp, TD_TFP);
-		txdesc->len = cpu_to_edmac(mdp, 0);
+		txdesc->status = cpu_to_le32(TD_TFP);
+		txdesc->len = cpu_to_le32(0);
 		if (i == 0) {
 			/* Tx descriptor address set */
 			sh_eth_write(ndev, mdp->tx_desc_dma, TDLAR);
@@ -1194,7 +1182,7 @@ static void sh_eth_ring_format(struct ne
 		}
 	}
 
-	txdesc->status |= cpu_to_edmac(mdp, TD_TDLE);
+	txdesc->status |= cpu_to_le32(TD_TDLE);
 }
 
 /* Get skb and descriptor buffer */
@@ -1350,7 +1338,7 @@ static void sh_eth_dev_exit(struct net_d
 	 * packet boundary if it's currently running
 	 */
 	for (i = 0; i < mdp->num_tx_ring; i++)
-		mdp->tx_ring[i].status &= ~cpu_to_edmac(mdp, TD_TACT);
+		mdp->tx_ring[i].status &= ~cpu_to_le32(TD_TACT);
 
 	/* Disable TX FIFO egress to MAC */
 	sh_eth_rcv_snd_disable(ndev);
@@ -1382,29 +1370,28 @@ static int sh_eth_txfree(struct net_devi
 	for (; mdp->cur_tx - mdp->dirty_tx > 0; mdp->dirty_tx++) {
 		entry = mdp->dirty_tx % mdp->num_tx_ring;
 		txdesc = &mdp->tx_ring[entry];
-		if (txdesc->status & cpu_to_edmac(mdp, TD_TACT))
+		if (txdesc->status & cpu_to_le32(TD_TACT))
 			break;
 		/* TACT bit must be checked before all the following reads */
 		dma_rmb();
 		netif_info(mdp, tx_done, ndev,
 			   "tx entry %d status 0x%08x\n",
-			   entry, edmac_to_cpu(mdp, txdesc->status));
+			   entry, le32_to_cpu(txdesc->status));
 		/* Free the original skb. */
 		if (mdp->tx_skbuff[entry]) {
-			dma_unmap_single(&ndev->dev,
-					 edmac_to_cpu(mdp, txdesc->addr),
-					 edmac_to_cpu(mdp, txdesc->len) >> 16,
+			dma_unmap_single(&ndev->dev, le32_to_cpu(txdesc->addr),
+					 le32_to_cpu(txdesc->len) >> 16,
 					 DMA_TO_DEVICE);
 			dev_kfree_skb_irq(mdp->tx_skbuff[entry]);
 			mdp->tx_skbuff[entry] = NULL;
 			free_num++;
 		}
-		txdesc->status = cpu_to_edmac(mdp, TD_TFP);
+		txdesc->status = cpu_to_le32(TD_TFP);
 		if (entry >= mdp->num_tx_ring - 1)
-			txdesc->status |= cpu_to_edmac(mdp, TD_TDLE);
+			txdesc->status |= cpu_to_le32(TD_TDLE);
 
 		ndev->stats.tx_packets++;
-		ndev->stats.tx_bytes += edmac_to_cpu(mdp, txdesc->len) >> 16;
+		ndev->stats.tx_bytes += le32_to_cpu(txdesc->len) >> 16;
 	}
 	return free_num;
 }
@@ -1428,11 +1415,11 @@ static int sh_eth_rx(struct net_device *
 	boguscnt = min(boguscnt, *quota);
 	limit = boguscnt;
 	rxdesc = &mdp->rx_ring[entry];
-	while (!(rxdesc->status & cpu_to_edmac(mdp, RD_RACT))) {
+	while (!(rxdesc->status & cpu_to_le32(RD_RACT))) {
 		/* RACT bit must be checked before all the following reads */
 		dma_rmb();
-		desc_status = edmac_to_cpu(mdp, rxdesc->status);
-		pkt_len = edmac_to_cpu(mdp, rxdesc->len) & RD_RFL;
+		desc_status = le32_to_cpu(rxdesc->status);
+		pkt_len = le32_to_cpu(rxdesc->len) & RD_RFL;
 
 		if (--boguscnt < 0)
 			break;
@@ -1470,7 +1457,7 @@ static int sh_eth_rx(struct net_device *
 			if (desc_status & RD_RFS10)
 				ndev->stats.rx_over_errors++;
 		} else	if (skb) {
-			dma_addr = edmac_to_cpu(mdp, rxdesc->addr);
+			dma_addr = le32_to_cpu(rxdesc->addr);
 			if (!mdp->cd->hw_swap)
 				sh_eth_soft_swap(
 					phys_to_virt(ALIGN(dma_addr, 4)),
@@ -1499,7 +1486,7 @@ static int sh_eth_rx(struct net_device *
 		rxdesc = &mdp->rx_ring[entry];
 		/* The size of the buffer is 32 byte boundary. */
 		buf_len = ALIGN(mdp->rx_buf_sz, 32);
-		rxdesc->len = cpu_to_edmac(mdp, buf_len << 16);
+		rxdesc->len = cpu_to_le32(buf_len << 16);
 
 		if (mdp->rx_skbuff[entry] == NULL) {
 			skb = netdev_alloc_skb(ndev, skbuff_size);
@@ -1515,15 +1502,14 @@ static int sh_eth_rx(struct net_device *
 			mdp->rx_skbuff[entry] = skb;
 
 			skb_checksum_none_assert(skb);
-			rxdesc->addr = cpu_to_edmac(mdp, dma_addr);
+			rxdesc->addr = cpu_to_le32(dma_addr);
 		}
 		dma_wmb(); /* RACT bit must be set after all the above writes */
 		if (entry >= mdp->num_rx_ring - 1)
 			rxdesc->status |=
-				cpu_to_edmac(mdp, RD_RACT | RD_RFP | RD_RDLE);
+				cpu_to_le32(RD_RACT | RD_RFP | RD_RDLE);
 		else
-			rxdesc->status |=
-				cpu_to_edmac(mdp, RD_RACT | RD_RFP);
+			rxdesc->status |= cpu_to_le32(RD_RACT | RD_RFP);
 	}
 
 	/* Restart Rx engine if stopped. */
@@ -2323,8 +2309,8 @@ static void sh_eth_tx_timeout(struct net
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < mdp->num_rx_ring; i++) {
 		rxdesc = &mdp->rx_ring[i];
-		rxdesc->status = cpu_to_edmac(mdp, 0);
-		rxdesc->addr = cpu_to_edmac(mdp, 0xBADF00D0);
+		rxdesc->status = cpu_to_le32(0);
+		rxdesc->addr = cpu_to_le32(0xBADF00D0);
 		dev_kfree_skb(mdp->rx_skbuff[i]);
 		mdp->rx_skbuff[i] = NULL;
 	}
@@ -2372,14 +2358,14 @@ static int sh_eth_start_xmit(struct sk_b
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
-	txdesc->addr = cpu_to_edmac(mdp, dma_addr);
-	txdesc->len  = cpu_to_edmac(mdp, skb->len << 16);
+	txdesc->addr = cpu_to_le32(dma_addr);
+	txdesc->len  = cpu_to_le32(skb->len << 16);
 
 	dma_wmb(); /* TACT bit must be set after all the above writes */
 	if (entry >= mdp->num_tx_ring - 1)
-		txdesc->status |= cpu_to_edmac(mdp, TD_TACT | TD_TDLE);
+		txdesc->status |= cpu_to_le32(TD_TACT | TD_TDLE);
 	else
-		txdesc->status |= cpu_to_edmac(mdp, TD_TACT);
+		txdesc->status |= cpu_to_le32(TD_TACT);
 
 	mdp->cur_tx++;
 

