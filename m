From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 3/4 v2] gianfar: Use ndev, more Rx path cleanup
Date: Mon, 13 Jul 2015 16:22:05 +0300
Message-ID: <1436793726-13310-4-git-send-email-claudiu.manoil@freescale.com>
References: <1436793726-13310-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0105.outbound.protection.outlook.com ([157.56.111.105]:23659
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752650AbbGMNYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 09:24:12 -0400
In-Reply-To: <1436793726-13310-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use "ndev" instead of "dev", as the rx queue back pointer
to a net_device struct, to avoid name clashing with a
"struct device" reference.  This prepares the addition of a
"struct device" back pointer to the rx queue structure.

Remove duplicated rxq registration in the process.
Move napi_gro_receive() outside gfar_process_frame().

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
v2: merge lstatus as u32

 drivers/net/ethernet/freescale/gianfar.c | 54 ++++++++++++++------------------
 drivers/net/ethernet/freescale/gianfar.h |  4 +--
 2 files changed, 26 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index c839e76..7654d5e 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -141,8 +141,7 @@ static void gfar_netpoll(struct net_device *dev);
 #endif
 int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit);
 static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue);
-static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
-			       struct napi_struct *napi);
+static void gfar_process_frame(struct net_device *ndev, struct sk_buff *skb);
 static void gfar_halt_nodisable(struct gfar_private *priv);
 static void gfar_clear_exact_match(struct net_device *dev);
 static void gfar_set_mac_for_addr(struct net_device *dev, int num,
@@ -262,7 +261,7 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 		rx_queue = priv->rx_queue[i];
 		rx_queue->rx_bd_base = vaddr;
 		rx_queue->rx_bd_dma_base = addr;
-		rx_queue->dev = ndev;
+		rx_queue->ndev = ndev;
 		addr  += sizeof(struct rxbd8) * rx_queue->rx_ring_size;
 		vaddr += sizeof(struct rxbd8) * rx_queue->rx_ring_size;
 	}
@@ -593,7 +592,7 @@ static int gfar_alloc_rx_queues(struct gfar_private *priv)
 
 		priv->rx_queue[i]->rx_skbuff = NULL;
 		priv->rx_queue[i]->qindex = i;
-		priv->rx_queue[i]->dev = priv->ndev;
+		priv->rx_queue[i]->ndev = priv->ndev;
 	}
 	return 0;
 }
@@ -1913,7 +1912,7 @@ static void free_skb_tx_queue(struct gfar_priv_tx_q *tx_queue)
 static void free_skb_rx_queue(struct gfar_priv_rx_q *rx_queue)
 {
 	struct rxbd8 *rxbdp;
-	struct gfar_private *priv = netdev_priv(rx_queue->dev);
+	struct gfar_private *priv = netdev_priv(rx_queue->ndev);
 	int i;
 
 	rxbdp = rx_queue->rx_bd_base;
@@ -2709,17 +2708,17 @@ static struct sk_buff *gfar_new_skb(struct net_device *ndev,
 
 static void gfar_rx_alloc_err(struct gfar_priv_rx_q *rx_queue)
 {
-	struct gfar_private *priv = netdev_priv(rx_queue->dev);
+	struct gfar_private *priv = netdev_priv(rx_queue->ndev);
 	struct gfar_extra_stats *estats = &priv->extra_stats;
 
-	netdev_err(rx_queue->dev, "Can't alloc RX buffers\n");
+	netdev_err(rx_queue->ndev, "Can't alloc RX buffers\n");
 	atomic64_inc(&estats->rx_alloc_err);
 }
 
 static void gfar_alloc_rx_buffs(struct gfar_priv_rx_q *rx_queue,
 				int alloc_cnt)
 {
-	struct net_device *ndev = rx_queue->dev;
+	struct net_device *ndev = rx_queue->ndev;
 	struct rxbd8 *bdp, *base;
 	dma_addr_t bufaddr;
 	int i;
@@ -2756,10 +2755,10 @@ static void gfar_alloc_rx_buffs(struct gfar_priv_rx_q *rx_queue,
 	rx_queue->next_to_use = i;
 }
 
-static void count_errors(u32 lstatus, struct net_device *dev)
+static void count_errors(u32 lstatus, struct net_device *ndev)
 {
-	struct gfar_private *priv = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
+	struct gfar_private *priv = netdev_priv(ndev);
+	struct net_device_stats *stats = &ndev->stats;
 	struct gfar_extra_stats *estats = &priv->extra_stats;
 
 	/* If the packet was truncated, none of the other errors matter */
@@ -2854,10 +2853,9 @@ static inline void gfar_rx_checksum(struct sk_buff *skb, struct rxfcb *fcb)
 }
 
 /* gfar_process_frame() -- handle one incoming packet if skb isn't NULL. */
-static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
-			       struct napi_struct *napi)
+static void gfar_process_frame(struct net_device *ndev, struct sk_buff *skb)
 {
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(ndev);
 	struct rxfcb *fcb = NULL;
 
 	/* fcb is at the beginning if exists */
@@ -2866,10 +2864,8 @@ static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	/* Remove the FCB from the skb
 	 * Remove the padded bytes, if there are any
 	 */
-	if (priv->uses_rxfcb) {
-		skb_record_rx_queue(skb, fcb->rq);
+	if (priv->uses_rxfcb)
 		skb_pull(skb, GMAC_FCB_LEN);
-	}
 
 	/* Get receive timestamp from the skb */
 	if (priv->hwts_rx_en) {
@@ -2883,24 +2879,20 @@ static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	if (priv->padding)
 		skb_pull(skb, priv->padding);
 
-	if (dev->features & NETIF_F_RXCSUM)
+	if (ndev->features & NETIF_F_RXCSUM)
 		gfar_rx_checksum(skb, fcb);
 
 	/* Tell the skb what kind of packet this is */
-	skb->protocol = eth_type_trans(skb, dev);
+	skb->protocol = eth_type_trans(skb, ndev);
 
 	/* There's need to check for NETIF_F_HW_VLAN_CTAG_RX here.
 	 * Even if vlan rx accel is disabled, on some chips
 	 * RXFCB_VLN is pseudo randomly set.
 	 */
-	if (dev->features & NETIF_F_HW_VLAN_CTAG_RX &&
+	if (ndev->features & NETIF_F_HW_VLAN_CTAG_RX &&
 	    be16_to_cpu(fcb->flags) & RXFCB_VLN)
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 				       be16_to_cpu(fcb->vlctl));
-
-	/* Send the packet up the stack */
-	napi_gro_receive(napi, skb);
-
 }
 
 /* gfar_clean_rx_ring() -- Processes each frame in the rx ring
@@ -2909,12 +2901,12 @@ static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
  */
 int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 {
-	struct net_device *dev = rx_queue->dev;
+	struct net_device *ndev = rx_queue->ndev;
 	struct rxbd8 *bdp, *base;
 	struct sk_buff *skb;
 	int i, howmany = 0;
 	int cleaned_cnt = gfar_rxbd_unused(rx_queue);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(ndev);
 
 	/* Get the first full descriptor */
 	base = rx_queue->rx_bd_base;
@@ -2948,7 +2940,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 
 		if (unlikely(!(lstatus & BD_LFLAG(RXBD_LAST)) ||
 			     (lstatus & BD_LFLAG(RXBD_ERR)))) {
-			count_errors(lstatus, dev);
+			count_errors(lstatus, ndev);
 
 			/* discard faulty buffer */
 			dev_kfree_skb(skb);
@@ -2965,11 +2957,13 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 				skb_put(skb, pkt_len);
 				rx_queue->stats.rx_bytes += pkt_len;
 				skb_record_rx_queue(skb, rx_queue->qindex);
-				gfar_process_frame(dev, skb,
-						   &rx_queue->grp->napi_rx);
+				gfar_process_frame(ndev, skb);
+
+				/* Send the packet up the stack */
+				napi_gro_receive(&rx_queue->grp->napi_rx, skb);
 
 			} else {
-				netif_warn(priv, rx_err, dev, "Missing skb!\n");
+				netif_warn(priv, rx_err, ndev, "Missing skb!\n");
 				rx_queue->stats.rx_dropped++;
 				atomic64_inc(&priv->extra_stats.rx_skbmissing);
 			}
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index cadb068..edf8529 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1022,7 +1022,7 @@ struct rx_q_stats {
  *	@next_to_use: index of the next buffer to be alloc'd
  *	@next_to_clean: index of the next buffer to be cleaned
  *	@qindex: index of this queue
- *	@dev: back pointer to the dev structure
+ *	@ndev: back pointer to net_device
  *	@rx_ring_size: Rx ring size
  *	@rxcoalescing: enable/disable rx-coalescing
  *	@rxic: receive interrupt coalescing vlaue
@@ -1031,7 +1031,7 @@ struct rx_q_stats {
 struct gfar_priv_rx_q {
 	struct	sk_buff **rx_skbuff __aligned(SMP_CACHE_BYTES);
 	struct	rxbd8 *rx_bd_base;
-	struct	net_device *dev;
+	struct	net_device *ndev;
 	struct	gfar_priv_grp *grp;
 	u16 rx_ring_size;
 	u16 qindex;
-- 
1.7.11.7
