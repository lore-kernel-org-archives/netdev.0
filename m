From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 1/2] drivers: net: xgene: Preparatory patch for TSO support
Date: Wed, 26 Aug 2015 11:48:05 -0700
Message-ID: <1440614886-23566-2-git-send-email-isubramanian@apm.com>
References: <1440614886-23566-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35332 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608AbbHZSr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 14:47:59 -0400
Received: by pacdd16 with SMTP id dd16so168887627pac.2
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 11:47:59 -0700 (PDT)
In-Reply-To: <1440614886-23566-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Rearranged descriptor writes
- Moved increment command write to xgene_enet_setup_tx_desc

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 29 ++++++++++++++++++------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  1 +
 2 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 4f68d19..652b4c3 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -219,6 +219,11 @@ out:
 	return hopinfo;
 }
 
+static u16 xgene_enet_encode_len(u16 len)
+{
+	return (len == BUFLEN_16K) ? 0 : len;
+}
+
 static int xgene_enet_setup_tx_desc(struct xgene_enet_desc_ring *tx_ring,
 				    struct sk_buff *skb)
 {
@@ -227,27 +232,36 @@ static int xgene_enet_setup_tx_desc(struct xgene_enet_desc_ring *tx_ring,
 	dma_addr_t dma_addr;
 	u16 tail = tx_ring->tail;
 	u64 hopinfo;
+	u32 len, hw_len;
+	u8 count = 1;
 
 	raw_desc = &tx_ring->raw_desc[tail];
 	memset(raw_desc, 0, sizeof(struct xgene_enet_raw_desc));
 
-	dma_addr = dma_map_single(dev, skb->data, skb->len, DMA_TO_DEVICE);
+	len = skb_headlen(skb);
+	hw_len = xgene_enet_encode_len(len);
+
+	dma_addr = dma_map_single(dev, skb->data, len, DMA_TO_DEVICE);
 	if (dma_mapping_error(dev, dma_addr)) {
 		netdev_err(tx_ring->ndev, "DMA mapping error\n");
 		return -EINVAL;
 	}
 
 	/* Hardware expects descriptor in little endian format */
-	raw_desc->m0 = cpu_to_le64(tail);
 	raw_desc->m1 = cpu_to_le64(SET_VAL(DATAADDR, dma_addr) |
-				   SET_VAL(BUFDATALEN, skb->len) |
+				   SET_VAL(BUFDATALEN, hw_len) |
 				   SET_BIT(COHERENT));
+
+	raw_desc->m0 = cpu_to_le64(SET_VAL(USERINFO, tail));
 	hopinfo = xgene_enet_work_msg(skb);
 	raw_desc->m3 = cpu_to_le64(SET_VAL(HENQNUM, tx_ring->dst_ring_num) |
 				   hopinfo);
 	tx_ring->cp_ring->cp_skb[tail] = skb;
 
-	return 0;
+	tail = (tail + 1) & (tx_ring->slots - 1);
+	tx_ring->tail = tail;
+
+	return count;
 }
 
 static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
@@ -257,6 +271,7 @@ static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
 	struct xgene_enet_desc_ring *tx_ring = pdata->tx_ring;
 	struct xgene_enet_desc_ring *cp_ring = tx_ring->cp_ring;
 	u32 tx_level, cq_level;
+	int count;
 
 	tx_level = pdata->ring_ops->len(tx_ring);
 	cq_level = pdata->ring_ops->len(cp_ring);
@@ -266,14 +281,14 @@ static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-	if (xgene_enet_setup_tx_desc(tx_ring, skb)) {
+	count = xgene_enet_setup_tx_desc(tx_ring, skb);
+	if (count <= 0) {
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
-	pdata->ring_ops->wr_cmd(tx_ring, 1);
+	pdata->ring_ops->wr_cmd(tx_ring, count);
 	skb_tx_timestamp(skb);
-	tx_ring->tail = (tx_ring->tail + 1) & (tx_ring->slots - 1);
 
 	pdata->stats.tx_packets++;
 	pdata->stats.tx_bytes += skb->len;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 1c85fc8..2ac547e 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -40,6 +40,7 @@
 #define XGENE_DRV_VERSION	"v1.0"
 #define XGENE_ENET_MAX_MTU	1536
 #define SKB_BUFFER_SIZE		(XGENE_ENET_MAX_MTU - NET_IP_ALIGN)
+#define BUFLEN_16K	(16 * 1024)
 #define NUM_PKT_BUF	64
 #define NUM_BUFPOOL	32
 
-- 
1.9.1
