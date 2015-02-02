From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH] net: fs_enet: Implement NETIF_F_SG feature
Date: Mon,  2 Feb 2015 18:06:54 +0100 (CET)
Message-ID: <20150202170654.D5EE21A5E90@localhost.localdomain>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Freescale ethernet controllers have the capability to re-assemble fragmented
data into a single ethernet frame. This patch uses this capability and
implements NETIP_F_SG feature into the fs_enet ethernet driver.

On a MPC885, I get 53% performance improvement on a ftp transfer of a 15Mb file:
  * Without the patch : 2,8 Mbps
  * With the patch : 4,3 Mbps

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

---
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  | 95 +++++++++++++++-------
 drivers/net/ethernet/freescale/fs_enet/fs_enet.h   |  1 +
 2 files changed, 66 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 9e2bcb8..a176287 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -278,14 +278,20 @@ static int fs_enet_tx_napi(struct napi_struct *napi, int budget)
 			fep->stats.collisions++;
 
 		/* unmap */
-		dma_unmap_single(fep->dev, CBDR_BUFADDR(bdp),
-				skb->len, DMA_TO_DEVICE);
+		if (fep->mapped_as_page[dirtyidx])
+			dma_unmap_page(fep->dev, CBDR_BUFADDR(bdp),
+				       CBDR_DATLEN(bdp), DMA_TO_DEVICE);
+		else
+			dma_unmap_single(fep->dev, CBDR_BUFADDR(bdp),
+					 CBDR_DATLEN(bdp), DMA_TO_DEVICE);
 
 		/*
 		 * Free the sk buffer associated with this last transmit.
 		 */
-		dev_kfree_skb(skb);
-		fep->tx_skbuff[dirtyidx] = NULL;
+		if (skb) {
+			dev_kfree_skb(skb);
+			fep->tx_skbuff[dirtyidx] = NULL;
+		}
 
 		/*
 		 * Update pointer to next buffer descriptor to be transmitted.
@@ -299,7 +305,7 @@ static int fs_enet_tx_napi(struct napi_struct *napi, int budget)
 		 * Since we have freed up a buffer, the ring is no longer
 		 * full.
 		 */
-		if (!fep->tx_free++)
+		if (++fep->tx_free >= MAX_SKB_FRAGS)
 			do_wake = 1;
 		has_tx_work = 1;
 	}
@@ -509,6 +515,9 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	cbd_t __iomem *bdp;
 	int curidx;
 	u16 sc;
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+	skb_frag_t *frag;
+	int len;
 
 #ifdef CONFIG_FS_ENET_MPC5121_FEC
 	if (((unsigned long)skb->data) & 0x3) {
@@ -530,7 +539,7 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	bdp = fep->cur_tx;
 
-	if (!fep->tx_free || (CBDR_SC(bdp) & BD_ENET_TX_READY)) {
+	if (fep->tx_free <= nr_frags || (CBDR_SC(bdp) & BD_ENET_TX_READY)) {
 		netif_stop_queue(dev);
 		spin_unlock(&fep->tx_lock);
 
@@ -543,35 +552,42 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	curidx = bdp - fep->tx_bd_base;
-	/*
-	 * Clear all of the status flags.
-	 */
-	CBDC_SC(bdp, BD_ENET_TX_STATS);
-
-	/*
-	 * Save skb pointer.
-	 */
-	fep->tx_skbuff[curidx] = skb;
-
-	fep->stats.tx_bytes += skb->len;
 
+	len = skb->len;
+	fep->stats.tx_bytes += len;
+	if (nr_frags)
+		len -= skb->data_len;
+	fep->tx_free -= nr_frags + 1;
 	/*
 	 * Push the data cache so the CPM does not get stale memory data.
 	 */
 	CBDW_BUFADDR(bdp, dma_map_single(fep->dev,
-				skb->data, skb->len, DMA_TO_DEVICE));
-	CBDW_DATLEN(bdp, skb->len);
+				skb->data, len, DMA_TO_DEVICE));
+	CBDW_DATLEN(bdp, len);
+
+	fep->mapped_as_page[curidx] = 0;
+	frag = skb_shinfo(skb)->frags;
+	while (nr_frags) {
+		CBDC_SC(bdp,
+			BD_ENET_TX_STATS | BD_ENET_TX_LAST | BD_ENET_TX_TC);
+		CBDS_SC(bdp, BD_ENET_TX_READY);
+
+		if ((CBDR_SC(bdp) & BD_ENET_TX_WRAP) == 0)
+			bdp++, curidx++;
+		else
+			bdp = fep->tx_bd_base, curidx = 0;
 
-	/*
-	 * If this was the last BD in the ring, start at the beginning again.
-	 */
-	if ((CBDR_SC(bdp) & BD_ENET_TX_WRAP) == 0)
-		fep->cur_tx++;
-	else
-		fep->cur_tx = fep->tx_bd_base;
+		len = skb_frag_size(frag);
+		CBDW_BUFADDR(bdp, skb_frag_dma_map(fep->dev, frag, 0, len,
+						   DMA_TO_DEVICE));
+		CBDW_DATLEN(bdp, len);
 
-	if (!--fep->tx_free)
-		netif_stop_queue(dev);
+		fep->tx_skbuff[curidx] = NULL;
+		fep->mapped_as_page[curidx] = 1;
+
+		frag++;
+		nr_frags--;
+	}
 
 	/* Trigger transmission start */
 	sc = BD_ENET_TX_READY | BD_ENET_TX_INTR |
@@ -582,8 +598,22 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * yay for hw reuse :) */
 	if (skb->len <= 60)
 		sc |= BD_ENET_TX_PAD;
+	CBDC_SC(bdp, BD_ENET_TX_STATS);
 	CBDS_SC(bdp, sc);
 
+	/* Save skb pointer. */
+	fep->tx_skbuff[curidx] = skb;
+
+	/* If this was the last BD in the ring, start at the beginning again. */
+	if ((CBDR_SC(bdp) & BD_ENET_TX_WRAP) == 0)
+		bdp++;
+	else
+		bdp = fep->tx_bd_base;
+	fep->cur_tx = bdp;
+
+	if (fep->tx_free < MAX_SKB_FRAGS)
+		netif_stop_queue(dev);
+
 	skb_tx_timestamp(skb);
 
 	(*fep->ops->tx_kickstart)(dev);
@@ -917,7 +947,7 @@ static int fs_enet_probe(struct platform_device *ofdev)
 	}
 
 	fpi->rx_ring = 32;
-	fpi->tx_ring = 32;
+	fpi->tx_ring = 64;
 	fpi->rx_copybreak = 240;
 	fpi->napi_weight = 17;
 	fpi->phy_node = of_parse_phandle(ofdev->dev.of_node, "phy-handle", 0);
@@ -955,7 +985,8 @@ static int fs_enet_probe(struct platform_device *ofdev)
 
 	privsize = sizeof(*fep) +
 	           sizeof(struct sk_buff **) *
-	           (fpi->rx_ring + fpi->tx_ring);
+		     (fpi->rx_ring + fpi->tx_ring) +
+		   sizeof(char) * fpi->tx_ring;
 
 	ndev = alloc_etherdev(privsize);
 	if (!ndev) {
@@ -978,6 +1009,8 @@ static int fs_enet_probe(struct platform_device *ofdev)
 
 	fep->rx_skbuff = (struct sk_buff **)&fep[1];
 	fep->tx_skbuff = fep->rx_skbuff + fpi->rx_ring;
+	fep->mapped_as_page = (char *)(fep->rx_skbuff + fpi->rx_ring +
+				       fpi->tx_ring);
 
 	spin_lock_init(&fep->lock);
 	spin_lock_init(&fep->tx_lock);
@@ -1007,6 +1040,8 @@ static int fs_enet_probe(struct platform_device *ofdev)
 
 	netif_carrier_off(ndev);
 
+	ndev->features |= NETIF_F_SG;
+
 	ret = register_netdev(ndev);
 	if (ret)
 		goto out_free_bd;
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet.h b/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
index 3a4b49e..f184d8f 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
@@ -134,6 +134,7 @@ struct fs_enet_private {
 	void __iomem *ring_base;
 	struct sk_buff **rx_skbuff;
 	struct sk_buff **tx_skbuff;
+	char *mapped_as_page;
 	cbd_t __iomem *rx_bd_base;	/* Address of Rx and Tx buffers.    */
 	cbd_t __iomem *tx_bd_base;
 	cbd_t __iomem *dirty_tx;	/* ring entries to be free()ed.     */
-- 
2.1.0
