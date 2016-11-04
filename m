From: Rafal Ozieblo <rafalo@cadence.com>
Subject: [PATCH net-next v3] cadence: Add LSO support.
Date: Fri, 4 Nov 2016 11:40:18 +0000
Message-ID: <1478259618-23474-1-git-send-email-rafalo@cadence.com>
References: <1477397130-24250-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rafal Ozieblo <rafalo@cadence.com>
To: <nicolas.ferre@atmel.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477397130-24250-1-git-send-email-rafalo@cadence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New Cadence GEM hardware support Large Segment Offload (LSO):
TCP segmentation offload (TSO) as well as UDP fragmentation
offload (UFO). Support for those features was added to the driver.

Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>
---
Changed in v2:
macb_lso_check_compatibility() changed to macb_features_check()
(with little modifications) and bind to .ndo_features_check.
(after Eric Dumazet suggestion)
---
Changed in v3:
Respin to net-next.
---
 drivers/net/ethernet/cadence/macb.c | 142 +++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/cadence/macb.h |  14 ++++
 2 files changed, 144 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index e1847ce..1eeaa4b 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -32,7 +32,9 @@
 #include <linux/of_gpio.h>
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
-
+#include <linux/ip.h>
+#include <linux/udp.h>
+#include <linux/tcp.h>
 #include "macb.h"
 
 #define MACB_RX_BUFFER_SIZE	128
@@ -60,10 +62,13 @@
 					| MACB_BIT(TXERR))
 #define MACB_TX_INT_FLAGS	(MACB_TX_ERR_FLAGS | MACB_BIT(TCOMP))
 
-#define MACB_MAX_TX_LEN		((unsigned int)((1 << MACB_TX_FRMLEN_SIZE) - 1))
-#define GEM_MAX_TX_LEN		((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1))
+/* Max length of transmit frame must be a multiple of 8 bytes */
+#define MACB_TX_LEN_ALIGN	8
+#define MACB_MAX_TX_LEN		((unsigned int)((1 << MACB_TX_FRMLEN_SIZE) - 1) & ~((unsigned int)(MACB_TX_LEN_ALIGN - 1)))
+#define GEM_MAX_TX_LEN		((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1) & ~((unsigned int)(MACB_TX_LEN_ALIGN - 1)))
 
 #define GEM_MTU_MIN_SIZE	ETH_MIN_MTU
+#define MACB_NETIF_LSO		(NETIF_F_TSO | NETIF_F_UFO)
 
 #define MACB_WOL_HAS_MAGIC_PACKET	(0x1 << 0)
 #define MACB_WOL_ENABLED		(0x1 << 1)
@@ -1223,7 +1228,8 @@ static void macb_poll_controller(struct net_device *dev)
 
 static unsigned int macb_tx_map(struct macb *bp,
 				struct macb_queue *queue,
-				struct sk_buff *skb)
+				struct sk_buff *skb,
+				unsigned int hdrlen)
 {
 	dma_addr_t mapping;
 	unsigned int len, entry, i, tx_head = queue->tx_head;
@@ -1231,14 +1237,27 @@ static unsigned int macb_tx_map(struct macb *bp,
 	struct macb_dma_desc *desc;
 	unsigned int offset, size, count = 0;
 	unsigned int f, nr_frags = skb_shinfo(skb)->nr_frags;
-	unsigned int eof = 1;
-	u32 ctrl;
+	unsigned int eof = 1, mss_mfs = 0;
+	u32 ctrl, lso_ctrl = 0, seq_ctrl = 0;
+
+	/* LSO */
+	if (skb_shinfo(skb)->gso_size != 0) {
+		if (IPPROTO_UDP == (((struct iphdr *)skb_network_header(skb))->protocol))
+			/* UDP - UFO */
+			lso_ctrl = MACB_LSO_UFO_ENABLE;
+		else
+			/* TCP - TSO */
+			lso_ctrl = MACB_LSO_TSO_ENABLE;
+	}
 
 	/* First, map non-paged data */
 	len = skb_headlen(skb);
+
+	/* first buffer length */
+	size = hdrlen;
+
 	offset = 0;
 	while (len) {
-		size = min(len, bp->max_tx_length);
 		entry = macb_tx_ring_wrap(bp, tx_head);
 		tx_skb = &queue->tx_skb[entry];
 
@@ -1258,6 +1277,8 @@ static unsigned int macb_tx_map(struct macb *bp,
 		offset += size;
 		count++;
 		tx_head++;
+
+		size = min(len, bp->max_tx_length);
 	}
 
 	/* Then, map paged data from fragments */
@@ -1311,6 +1332,20 @@ static unsigned int macb_tx_map(struct macb *bp,
 	desc = &queue->tx_ring[entry];
 	desc->ctrl = ctrl;
 
+	if (lso_ctrl) {
+		if (lso_ctrl == MACB_LSO_UFO_ENABLE)
+			/* include header and FCS in value given to h/w */
+			mss_mfs = skb_shinfo(skb)->gso_size +
+					skb_transport_offset(skb) + 4;
+		else /* TSO */ {
+			mss_mfs = skb_shinfo(skb)->gso_size;
+			/* TCP Sequence Number Source Select
+			 * can be set only for TSO
+			 */
+			seq_ctrl = 0;
+		}
+	}
+
 	do {
 		i--;
 		entry = macb_tx_ring_wrap(bp, i);
@@ -1325,6 +1360,16 @@ static unsigned int macb_tx_map(struct macb *bp,
 		if (unlikely(entry == (bp->tx_ring_size - 1)))
 			ctrl |= MACB_BIT(TX_WRAP);
 
+		/* First descriptor is header descriptor */
+		if (i == queue->tx_head) {
+			ctrl |= MACB_BF(TX_LSO, lso_ctrl);
+			ctrl |= MACB_BF(TX_TCP_SEQ_SRC, seq_ctrl);
+		} else
+			/* Only set MSS/MFS on payload descriptors
+			 * (second or later descriptor)
+			 */
+			ctrl |= MACB_BF(MSS_MFS, mss_mfs);
+
 		/* Set TX buffer descriptor */
 		macb_set_addr(desc, tx_skb->mapping);
 		/* desc->addr must be visible to hardware before clearing
@@ -1350,6 +1395,43 @@ static unsigned int macb_tx_map(struct macb *bp,
 	return 0;
 }
 
+static netdev_features_t macb_features_check(struct sk_buff *skb,
+					     struct net_device *dev,
+					     netdev_features_t features)
+{
+	unsigned int nr_frags, f;
+	unsigned int hdrlen;
+
+	/* Validate LSO compatibility */
+
+	/* there is only one buffer */
+	if (!skb_is_nonlinear(skb))
+		return features;
+
+	/* length of header */
+	hdrlen = skb_transport_offset(skb);
+	if (IPPROTO_TCP == (((struct iphdr *)skb_network_header(skb))->protocol))
+		hdrlen += tcp_hdrlen(skb);
+
+	/* For LSO:
+	 * When software supplies two or more payload buffers all payload buffers
+	 * apart from the last must be a multiple of 8 bytes in size.
+	 */
+	if (!IS_ALIGNED(skb_headlen(skb) - hdrlen, MACB_TX_LEN_ALIGN))
+		return features & ~MACB_NETIF_LSO;
+
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	/* No need to check last fragment */
+	nr_frags--;
+	for (f = 0; f < nr_frags; f++) {
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[f];
+
+		if (!IS_ALIGNED(skb_frag_size(frag), MACB_TX_LEN_ALIGN))
+			return features & ~MACB_NETIF_LSO;
+	}
+	return features;
+}
+
 static inline int macb_clear_csum(struct sk_buff *skb)
 {
 	/* no change for packets without checksum offloading */
@@ -1374,7 +1456,27 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct macb *bp = netdev_priv(dev);
 	struct macb_queue *queue = &bp->queues[queue_index];
 	unsigned long flags;
-	unsigned int count, nr_frags, frag_size, f;
+	unsigned int desc_cnt, nr_frags, frag_size, f;
+	unsigned int is_lso = 0, is_udp, hdrlen;
+
+	is_lso = (skb_shinfo(skb)->gso_size != 0);
+
+	if (is_lso) {
+		is_udp = (IPPROTO_UDP == (((struct iphdr *)skb_network_header(skb))->protocol));
+
+		/* length of headers */
+		if (is_udp)
+			/* only queue eth + ip headers separately for UDP */
+			hdrlen = skb_transport_offset(skb);
+		else
+			hdrlen = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		if (skb_headlen(skb) < hdrlen) {
+			netdev_err(bp->dev, "Error - LSO headers fragmented!!!\n");
+			/* if this is required, would need to copy to single buffer */
+			return NETDEV_TX_BUSY;
+		}
+	} else
+		hdrlen = min(skb_headlen(skb), bp->max_tx_length);
 
 #if defined(DEBUG) && defined(VERBOSE_DEBUG)
 	netdev_vdbg(bp->dev,
@@ -1389,18 +1491,22 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * socket buffer: skb fragments of jumbo frames may need to be
 	 * split into many buffer descriptors.
 	 */
-	count = DIV_ROUND_UP(skb_headlen(skb), bp->max_tx_length);
+	if (is_lso && (skb_headlen(skb) > hdrlen))
+		/* extra header descriptor if also payload in first buffer */
+		desc_cnt = DIV_ROUND_UP((skb_headlen(skb) - hdrlen), bp->max_tx_length) + 1;
+	else
+		desc_cnt = DIV_ROUND_UP(skb_headlen(skb), bp->max_tx_length);
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	for (f = 0; f < nr_frags; f++) {
 		frag_size = skb_frag_size(&skb_shinfo(skb)->frags[f]);
-		count += DIV_ROUND_UP(frag_size, bp->max_tx_length);
+		desc_cnt += DIV_ROUND_UP(frag_size, bp->max_tx_length);
 	}
 
 	spin_lock_irqsave(&bp->lock, flags);
 
 	/* This is a hard error, log it. */
 	if (CIRC_SPACE(queue->tx_head, queue->tx_tail,
-		       bp->tx_ring_size) < count) {
+		       bp->tx_ring_size) < desc_cnt) {
 		netif_stop_subqueue(dev, queue_index);
 		spin_unlock_irqrestore(&bp->lock, flags);
 		netdev_dbg(bp->dev, "tx_head = %u, tx_tail = %u\n",
@@ -1408,13 +1514,19 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
+	if (is_lso) {
+		if (is_udp)
+			/* zero UDP checksum, not calculated by h/w for UFO */
+			udp_hdr(skb)->check = 0;
+	}
+
 	if (macb_clear_csum(skb)) {
 		dev_kfree_skb_any(skb);
 		goto unlock;
 	}
 
 	/* Map socket buffer for DMA transfer */
-	if (!macb_tx_map(bp, queue, skb)) {
+	if (!macb_tx_map(bp, queue, skb, hdrlen)) {
 		dev_kfree_skb_any(skb);
 		goto unlock;
 	}
@@ -2354,6 +2466,7 @@ static const struct net_device_ops macb_netdev_ops = {
 	.ndo_poll_controller	= macb_poll_controller,
 #endif
 	.ndo_set_features	= macb_set_features,
+	.ndo_features_check	= macb_features_check,
 };
 
 /* Configure peripheral capabilities according to device tree
@@ -2560,6 +2673,11 @@ static int macb_init(struct platform_device *pdev)
 
 	/* Set features */
 	dev->hw_features = NETIF_F_SG;
+
+	/* Check LSO capability */
+	if (GEM_BFEXT(PBUF_LSO, gem_readl(bp, DCFG6)))
+		dev->hw_features |= MACB_NETIF_LSO;
+
 	/* Checksum offload is only available on gem with packet buffer */
 	if (macb_is_gem(bp) && !(bp->caps & MACB_CAPS_FIFO_MODE))
 		dev->hw_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 1216950..d67adad 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -382,6 +382,10 @@
 #define GEM_TX_PKT_BUFF_OFFSET			21
 #define GEM_TX_PKT_BUFF_SIZE			1
 
+/* Bitfields in DCFG6. */
+#define GEM_PBUF_LSO_OFFSET			27
+#define GEM_PBUF_LSO_SIZE			1
+
 /* Constants for CLK */
 #define MACB_CLK_DIV8				0
 #define MACB_CLK_DIV16				1
@@ -414,6 +418,10 @@
 #define MACB_CAPS_SG_DISABLED			0x40000000
 #define MACB_CAPS_MACB_IS_GEM			0x80000000
 
+/* LSO settings */
+#define MACB_LSO_UFO_ENABLE			0x01
+#define MACB_LSO_TSO_ENABLE			0x02
+
 /* Bit manipulation macros */
 #define MACB_BIT(name)					\
 	(1 << MACB_##name##_OFFSET)
@@ -545,6 +553,12 @@ struct macb_dma_desc {
 #define MACB_TX_LAST_SIZE			1
 #define MACB_TX_NOCRC_OFFSET			16
 #define MACB_TX_NOCRC_SIZE			1
+#define MACB_MSS_MFS_OFFSET			16
+#define MACB_MSS_MFS_SIZE			14
+#define MACB_TX_LSO_OFFSET			17
+#define MACB_TX_LSO_SIZE			2
+#define MACB_TX_TCP_SEQ_SRC_OFFSET		19
+#define MACB_TX_TCP_SEQ_SRC_SIZE		1
 #define MACB_TX_BUF_EXHAUSTED_OFFSET		27
 #define MACB_TX_BUF_EXHAUSTED_SIZE		1
 #define MACB_TX_UNDERRUN_OFFSET			28
-- 
2.4.5
