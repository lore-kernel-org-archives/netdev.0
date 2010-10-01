From: "Ian Munsie" <imunsie@au1.ibm.com>
Subject: [PATCH 17/18] net: Fix endianess issues in IBM newemac driver
Date: Fri,  1 Oct 2010 17:06:10 +1000
Message-ID: <1285916771-18033-18-git-send-email-imunsie@au1.ibm.com>
References: <1285916771-18033-1-git-send-email-imunsie@au1.ibm.com>
Cc: paulus@samba.org, Ian Munsie <imunsie@au1.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>,
	Jiri Pirko <jpirko@redhat.com>,
	Sean MacLennan <smaclennan@pikatech.com>,
	Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	benh@kernel.crashing.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285916771-18033-1-git-send-email-imunsie@au1.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Munsie <imunsie@au1.ibm.com>

This patch fixes all the device tree and ring buffer accesses in the IBM
newemac driver.

Signed-off-by: Ian Munsie <imunsie@au1.ibm.com>
---
 drivers/net/ibm_newemac/core.c |   68 ++++++++++++++++++++--------------------
 drivers/net/ibm_newemac/mal.c  |    6 ++--
 drivers/net/ibm_newemac/mal.h  |    6 ++--
 3 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 3506fd6..67238b8 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -981,12 +981,12 @@ static int emac_resize_rx_ring(struct emac_instance *dev, int new_mtu)
 	 * to simplify error recovery in the case of allocation failure later.
 	 */
 	for (i = 0; i < NUM_RX_BUFF; ++i) {
-		if (dev->rx_desc[i].ctrl & MAL_RX_CTRL_FIRST)
+		if (dev->rx_desc[i].ctrl & cpu_to_be16(MAL_RX_CTRL_FIRST))
 			++dev->estats.rx_dropped_resize;
 
 		dev->rx_desc[i].data_len = 0;
-		dev->rx_desc[i].ctrl = MAL_RX_CTRL_EMPTY |
-		    (i == (NUM_RX_BUFF - 1) ? MAL_RX_CTRL_WRAP : 0);
+		dev->rx_desc[i].ctrl = cpu_to_be16(MAL_RX_CTRL_EMPTY |
+		    (i == (NUM_RX_BUFF - 1) ? MAL_RX_CTRL_WRAP : 0));
 	}
 
 	/* Reallocate RX ring only if bigger skb buffers are required */
@@ -1005,9 +1005,9 @@ static int emac_resize_rx_ring(struct emac_instance *dev, int new_mtu)
 		dev_kfree_skb(dev->rx_skb[i]);
 
 		skb_reserve(skb, EMAC_RX_SKB_HEADROOM + 2);
-		dev->rx_desc[i].data_ptr =
+		dev->rx_desc[i].data_ptr = cpu_to_be32(
 		    dma_map_single(&dev->ofdev->dev, skb->data - 2, rx_sync_size,
-				   DMA_FROM_DEVICE) + 2;
+				   DMA_FROM_DEVICE) + 2);
 		dev->rx_skb[i] = skb;
 	}
  skip:
@@ -1067,7 +1067,7 @@ static void emac_clean_tx_ring(struct emac_instance *dev)
 		if (dev->tx_skb[i]) {
 			dev_kfree_skb(dev->tx_skb[i]);
 			dev->tx_skb[i] = NULL;
-			if (dev->tx_desc[i].ctrl & MAL_TX_CTRL_READY)
+			if (dev->tx_desc[i].ctrl & cpu_to_be16(MAL_TX_CTRL_READY))
 				++dev->estats.tx_dropped;
 		}
 		dev->tx_desc[i].ctrl = 0;
@@ -1104,12 +1104,12 @@ static inline int emac_alloc_rx_skb(struct emac_instance *dev, int slot,
 	dev->rx_desc[slot].data_len = 0;
 
 	skb_reserve(skb, EMAC_RX_SKB_HEADROOM + 2);
-	dev->rx_desc[slot].data_ptr =
+	dev->rx_desc[slot].data_ptr = cpu_to_be32(
 	    dma_map_single(&dev->ofdev->dev, skb->data - 2, dev->rx_sync_size,
-			   DMA_FROM_DEVICE) + 2;
+			   DMA_FROM_DEVICE) + 2);
 	wmb();
-	dev->rx_desc[slot].ctrl = MAL_RX_CTRL_EMPTY |
-	    (slot == (NUM_RX_BUFF - 1) ? MAL_RX_CTRL_WRAP : 0);
+	dev->rx_desc[slot].ctrl = cpu_to_be16(MAL_RX_CTRL_EMPTY |
+	    (slot == (NUM_RX_BUFF - 1) ? MAL_RX_CTRL_WRAP : 0));
 
 	return 0;
 }
@@ -1373,12 +1373,12 @@ static int emac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	DBG2(dev, "xmit(%u) %d" NL, len, slot);
 
 	dev->tx_skb[slot] = skb;
-	dev->tx_desc[slot].data_ptr = dma_map_single(&dev->ofdev->dev,
+	dev->tx_desc[slot].data_ptr = cpu_to_be32(dma_map_single(&dev->ofdev->dev,
 						     skb->data, len,
-						     DMA_TO_DEVICE);
-	dev->tx_desc[slot].data_len = (u16) len;
+						     DMA_TO_DEVICE));
+	dev->tx_desc[slot].data_len = cpu_to_be16(len);
 	wmb();
-	dev->tx_desc[slot].ctrl = ctrl;
+	dev->tx_desc[slot].ctrl = cpu_to_be16(ctrl);
 
 	return emac_xmit_finish(dev, len);
 }
@@ -1399,9 +1399,9 @@ static inline int emac_xmit_split(struct emac_instance *dev, int slot,
 			ctrl |= MAL_TX_CTRL_WRAP;
 
 		dev->tx_skb[slot] = NULL;
-		dev->tx_desc[slot].data_ptr = pd;
-		dev->tx_desc[slot].data_len = (u16) chunk;
-		dev->tx_desc[slot].ctrl = ctrl;
+		dev->tx_desc[slot].data_ptr = cpu_to_be32(pd);
+		dev->tx_desc[slot].data_len = cpu_to_be16(chunk);
+		dev->tx_desc[slot].ctrl = cpu_to_be16(ctrl);
 		++dev->tx_cnt;
 
 		if (!len)
@@ -1442,9 +1442,9 @@ static int emac_start_xmit_sg(struct sk_buff *skb, struct net_device *ndev)
 	/* skb data */
 	dev->tx_skb[slot] = NULL;
 	chunk = min(len, MAL_MAX_TX_SIZE);
-	dev->tx_desc[slot].data_ptr = pd =
-	    dma_map_single(&dev->ofdev->dev, skb->data, len, DMA_TO_DEVICE);
-	dev->tx_desc[slot].data_len = (u16) chunk;
+	dev->tx_desc[slot].data_ptr = cpu_to_be32(pd =
+	    dma_map_single(&dev->ofdev->dev, skb->data, len, DMA_TO_DEVICE));
+	dev->tx_desc[slot].data_len = cpu_to_be16(chunk);
 	len -= chunk;
 	if (unlikely(len))
 		slot = emac_xmit_split(dev, slot, pd + chunk, len, !nr_frags,
@@ -1473,7 +1473,7 @@ static int emac_start_xmit_sg(struct sk_buff *skb, struct net_device *ndev)
 	if (dev->tx_slot == NUM_TX_BUFF - 1)
 		ctrl |= MAL_TX_CTRL_WRAP;
 	wmb();
-	dev->tx_desc[dev->tx_slot].ctrl = ctrl;
+	dev->tx_desc[dev->tx_slot].ctrl = cpu_to_be16(ctrl);
 	dev->tx_slot = (slot + 1) % NUM_TX_BUFF;
 
 	return emac_xmit_finish(dev, skb->len);
@@ -1541,7 +1541,7 @@ static void emac_poll_tx(void *param)
 		u16 ctrl;
 		int slot = dev->ack_slot, n = 0;
 	again:
-		ctrl = dev->tx_desc[slot].ctrl;
+		ctrl = be16_to_cpu(dev->tx_desc[slot].ctrl);
 		if (!(ctrl & MAL_TX_CTRL_READY)) {
 			struct sk_buff *skb = dev->tx_skb[slot];
 			++n;
@@ -1583,8 +1583,8 @@ static inline void emac_recycle_rx_skb(struct emac_instance *dev, int slot,
 
 	dev->rx_desc[slot].data_len = 0;
 	wmb();
-	dev->rx_desc[slot].ctrl = MAL_RX_CTRL_EMPTY |
-	    (slot == (NUM_RX_BUFF - 1) ? MAL_RX_CTRL_WRAP : 0);
+	dev->rx_desc[slot].ctrl = cpu_to_be16(MAL_RX_CTRL_EMPTY |
+	    (slot == (NUM_RX_BUFF - 1) ? MAL_RX_CTRL_WRAP : 0));
 }
 
 static void emac_parse_rx_error(struct emac_instance *dev, u16 ctrl)
@@ -1628,7 +1628,7 @@ static inline void emac_rx_csum(struct emac_instance *dev,
 static inline int emac_rx_sg_append(struct emac_instance *dev, int slot)
 {
 	if (likely(dev->rx_sg_skb != NULL)) {
-		int len = dev->rx_desc[slot].data_len;
+		int len = be16_to_cpu(dev->rx_desc[slot].data_len);
 		int tot_len = dev->rx_sg_skb->len + len;
 
 		if (unlikely(tot_len + 2 > dev->rx_skb_size)) {
@@ -1659,14 +1659,14 @@ static int emac_poll_rx(void *param, int budget)
 	while (budget > 0) {
 		int len;
 		struct sk_buff *skb;
-		u16 ctrl = dev->rx_desc[slot].ctrl;
+		u16 ctrl = be16_to_cpu(dev->rx_desc[slot].ctrl);
 
 		if (ctrl & MAL_RX_CTRL_EMPTY)
 			break;
 
 		skb = dev->rx_skb[slot];
 		mb();
-		len = dev->rx_desc[slot].data_len;
+		len = be16_to_cpu(dev->rx_desc[slot].data_len);
 
 		if (unlikely(!MAL_IS_SINGLE_RX(ctrl)))
 			goto sg;
@@ -1757,7 +1757,7 @@ static int emac_poll_rx(void *param, int budget)
 
 	if (unlikely(budget && test_bit(MAL_COMMAC_RX_STOPPED, &dev->commac.flags))) {
 		mb();
-		if (!(dev->rx_desc[slot].ctrl & MAL_RX_CTRL_EMPTY)) {
+		if (!(dev->rx_desc[slot].ctrl & cpu_to_be16(MAL_RX_CTRL_EMPTY))) {
 			DBG2(dev, "rx restart" NL);
 			received = 0;
 			goto again;
@@ -1783,7 +1783,7 @@ static int emac_peek_rx(void *param)
 {
 	struct emac_instance *dev = param;
 
-	return !(dev->rx_desc[dev->rx_slot].ctrl & MAL_RX_CTRL_EMPTY);
+	return !(dev->rx_desc[dev->rx_slot].ctrl & cpu_to_be16(MAL_RX_CTRL_EMPTY));
 }
 
 /* NAPI poll context */
@@ -1793,7 +1793,7 @@ static int emac_peek_rx_sg(void *param)
 
 	int slot = dev->rx_slot;
 	while (1) {
-		u16 ctrl = dev->rx_desc[slot].ctrl;
+		u16 ctrl = be16_to_cpu(dev->rx_desc[slot].ctrl);
 		if (ctrl & MAL_RX_CTRL_EMPTY)
 			return 0;
 		else if (ctrl & MAL_RX_CTRL_LAST)
@@ -2367,14 +2367,14 @@ static int __devinit emac_read_uint_prop(struct device_node *np, const char *nam
 					 u32 *val, int fatal)
 {
 	int len;
-	const u32 *prop = of_get_property(np, name, &len);
+	const __be32 *prop = of_get_property(np, name, &len);
 	if (prop == NULL || len < sizeof(u32)) {
 		if (fatal)
 			printk(KERN_ERR "%s: missing %s property\n",
 			       np->full_name, name);
 		return -ENODEV;
 	}
-	*val = *prop;
+	*val = be32_to_cpup(prop);
 	return 0;
 }
 
@@ -3013,7 +3013,7 @@ static void __init emac_make_bootlist(void)
 
 	/* Collect EMACs */
 	while((np = of_find_all_nodes(np)) != NULL) {
-		const u32 *idx;
+		const __be32 *idx;
 
 		if (of_match_node(emac_match, np) == NULL)
 			continue;
@@ -3022,7 +3022,7 @@ static void __init emac_make_bootlist(void)
 		idx = of_get_property(np, "cell-index", NULL);
 		if (idx == NULL)
 			continue;
-		cell_indices[i] = *idx;
+		cell_indices[i] = be32_to_cpup(idx);
 		emac_boot_list[i++] = of_node_get(np);
 		if (i >= EMAC_BOOT_LIST_SIZE) {
 			of_node_put(np);
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index d5717e2..9e4939e 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -524,7 +524,7 @@ static int __devinit mal_probe(struct platform_device *ofdev,
 	int err = 0, i, bd_size;
 	int index = mal_count++;
 	unsigned int dcr_base;
-	const u32 *prop;
+	const __be32 *prop;
 	u32 cfg;
 	unsigned long irqflags;
 	irq_handler_t hdlr_serr, hdlr_txde, hdlr_rxde;
@@ -550,7 +550,7 @@ static int __devinit mal_probe(struct platform_device *ofdev,
 		err = -ENODEV;
 		goto fail;
 	}
-	mal->num_tx_chans = prop[0];
+	mal->num_tx_chans = be32_to_cpu(prop[0]);
 
 	prop = of_get_property(ofdev->dev.of_node, "num-rx-chans", NULL);
 	if (prop == NULL) {
@@ -560,7 +560,7 @@ static int __devinit mal_probe(struct platform_device *ofdev,
 		err = -ENODEV;
 		goto fail;
 	}
-	mal->num_rx_chans = prop[0];
+	mal->num_rx_chans = be32_to_cpu(prop[0]);
 
 	dcr_base = dcr_resource_start(ofdev->dev.of_node, 0);
 	if (dcr_base == 0) {
diff --git a/drivers/net/ibm_newemac/mal.h b/drivers/net/ibm_newemac/mal.h
index 6608421..b8ee413 100644
--- a/drivers/net/ibm_newemac/mal.h
+++ b/drivers/net/ibm_newemac/mal.h
@@ -147,9 +147,9 @@ static inline int mal_tx_chunks(int len)
 
 /* MAL Buffer Descriptor structure */
 struct mal_descriptor {
-	u16 ctrl;		/* MAL / Commac status control bits */
-	u16 data_len;		/* Max length is 4K-1 (12 bits)     */
-	u32 data_ptr;		/* pointer to actual data buffer    */
+	__be16 ctrl;		/* MAL / Commac status control bits */
+	__be16 data_len;	/* Max length is 4K-1 (12 bits)     */
+	__be32 data_ptr;	/* pointer to actual data buffer    */
 };
 
 /* the following defines are for the MadMAL status and control registers. */
-- 
1.7.1
