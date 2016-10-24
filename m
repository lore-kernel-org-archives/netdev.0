From: Rafal Ozieblo <rafalo@cadence.com>
Subject: [PATCH] LSO feature added to Cadence GEM driver
Date: Mon, 24 Oct 2016 14:18:08 +0100
Message-ID: <1477315088-28396-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rafal Ozieblo <rafalo@cadence.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0014ca01.pphosted.com ([208.86.201.193]:38329 "EHLO
        mx0a-0014ca01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934306AbcJXN6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 09:58:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New Cadence GEM hardware support Large Segment Offload (LSO):
TCP segmentation offload (TSO) as well as UDP fragmentation
offload (UFO). Support for those features was added to the driver.

Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>
---
 drivers/net/ethernet/cadence/macb.c | 141 +++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/cadence/macb.h |  14 ++++
 2 files changed, 143 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index b32444a..f659d57 100644
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
@@ -53,8 +55,10 @@
 					| MACB_BIT(TXERR))
 #define MACB_TX_INT_FLAGS	(MACB_TX_ERR_FLAGS | MACB_BIT(TCOMP))
 
-#define MACB_MAX_TX_LEN		((unsigned int)((1 << MACB_TX_FRMLEN_SIZE) - 1))
-#define GEM_MAX_TX_LEN		((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1))
+/* Max length of transmit frame must be a multiple of 8 bytes */
+#define MACB_TX_LEN_ALIGN	8
+#define MACB_MAX_TX_LEN		((unsigned int)((1 << MACB_TX_FRMLEN_SIZE) - 1) & ~((unsigned int)(MACB_TX_LEN_ALIGN - 1)))
+#define GEM_MAX_TX_LEN		((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1) & ~((unsigned int)(MACB_TX_LEN_ALIGN - 1)))
 
 #define GEM_MTU_MIN_SIZE	68
 
@@ -1212,7 +1216,8 @@ static void macb_poll_controller(struct net_device *dev)
 
 static unsigned int macb_tx_map(struct macb *bp,
 				struct macb_queue *queue,
-				struct sk_buff *skb)
+				struct sk_buff *skb,
+				unsigned int hdrlen)
 {
 	dma_addr_t mapping;
 	unsigned int len, entry, i, tx_head = queue->tx_head;
@@ -1220,14 +1225,27 @@ static unsigned int macb_tx_map(struct macb *bp,
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
 		entry = macb_tx_ring_wrap(tx_head);
 		tx_skb = &queue->tx_skb[entry];
 
@@ -1247,6 +1265,8 @@ static unsigned int macb_tx_map(struct macb *bp,
 		offset += size;
 		count++;
 		tx_head++;
+
+		size = min(len, bp->max_tx_length);
 	}
 
 	/* Then, map paged data from fragments */
@@ -1300,6 +1320,20 @@ static unsigned int macb_tx_map(struct macb *bp,
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
 		entry = macb_tx_ring_wrap(i);
@@ -1314,6 +1348,16 @@ static unsigned int macb_tx_map(struct macb *bp,
 		if (unlikely(entry == (TX_RING_SIZE - 1)))
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
@@ -1339,6 +1383,37 @@ static unsigned int macb_tx_map(struct macb *bp,
 	return 0;
 }
 
+static int macb_lso_check_compatibility(struct sk_buff *skb, unsigned int hdrlen)
+{
+	unsigned int nr_frags, f;
+
+	if (skb_shinfo(skb)->gso_size == 0)
+		/* not LSO */
+		return -EPERM;
+
+	/* there is only one buffer */
+	if (!skb_is_nonlinear(skb))
+		return 0;
+
+	/* For LSO:
+	 * When software supplies two or more payload buffers all payload buffers
+	 * apart from the last must be a multiple of 8 bytes in size.
+	 */
+	if (!IS_ALIGNED(skb_headlen(skb) - hdrlen, MACB_TX_LEN_ALIGN))
+		return -EPERM;
+
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	/* No need to check last fragment */
+	nr_frags--;
+	for (f = 0; f < nr_frags; f++) {
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[f];
+
+		if (!IS_ALIGNED(skb_frag_size(frag), MACB_TX_LEN_ALIGN))
+			return -EPERM;
+	}
+	return 0;
+}
+
 static inline int macb_clear_csum(struct sk_buff *skb)
 {
 	/* no change for packets without checksum offloading */
@@ -1363,7 +1438,33 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
+		if (macb_lso_check_compatibility(skb, hdrlen)) {
+			if (skb_linearize(skb)) {
+				netdev_err(bp->dev, "Can't linearize buffer\n");
+				return NETDEV_TX_BUSY;
+			}
+		}
+	} else
+		hdrlen = min(skb_headlen(skb), bp->max_tx_length);
 
 #if defined(DEBUG) && defined(VERBOSE_DEBUG)
 	netdev_vdbg(bp->dev,
@@ -1378,17 +1479,21 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
-	if (CIRC_SPACE(queue->tx_head, queue->tx_tail, TX_RING_SIZE) < count) {
+	if (CIRC_SPACE(queue->tx_head, queue->tx_tail, TX_RING_SIZE) < desc_cnt) {
 		netif_stop_subqueue(dev, queue_index);
 		spin_unlock_irqrestore(&bp->lock, flags);
 		netdev_dbg(bp->dev, "tx_head = %u, tx_tail = %u\n",
@@ -1396,13 +1501,19 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
@@ -2501,6 +2612,12 @@ static int macb_init(struct platform_device *pdev)
 
 	/* Set features */
 	dev->hw_features = NETIF_F_SG;
+
+	/* Check LSO capability */
+	if (GEM_BFEXT(PBUF_LSO, gem_readl(bp, DCFG6)))
+		dev->hw_features |= NETIF_F_TSO
+				| NETIF_F_UFO;
+
 	/* Checksum offload is only available on gem with packet buffer */
 	if (macb_is_gem(bp) && !(bp->caps & MACB_CAPS_FIFO_MODE))
 		dev->hw_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 8bed4b5..534aded 100644
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
