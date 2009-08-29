From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 09/17] tg3: Use ext rx bds
Date: Fri, 28 Aug 2009 17:00:55 -0700
Message-ID: <1251585286.29687@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2416 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752640AbZH2We4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5717 only uses extended buffer descriptors for the jumbo producer
ring.  Extended buffer descriptors are available on all devices that
support a separate jumbo producer ring so make the change universal.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   17 +++++++++--------
 drivers/net/tg3.h |    2 +-
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 053d4e8..3725ac8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -117,10 +117,10 @@
 
 #define TG3_RX_RING_BYTES	(sizeof(struct tg3_rx_buffer_desc) * \
 				 TG3_RX_RING_SIZE)
-#define TG3_RX_JUMBO_RING_BYTES	(sizeof(struct tg3_rx_buffer_desc) * \
-			         TG3_RX_JUMBO_RING_SIZE)
+#define TG3_RX_JUMBO_RING_BYTES	(sizeof(struct tg3_ext_rx_buffer_desc) * \
+				 TG3_RX_JUMBO_RING_SIZE)
 #define TG3_RX_RCB_RING_BYTES(tp) (sizeof(struct tg3_rx_buffer_desc) * \
-			           TG3_RX_RCB_RING_SIZE(tp))
+				 TG3_RX_RCB_RING_SIZE(tp))
 #define TG3_TX_RING_BYTES	(sizeof(struct tg3_tx_buffer_desc) * \
 				 TG3_TX_RING_SIZE)
 #define NEXT_TX(N)		(((N) + 1) & (TG3_TX_RING_SIZE - 1))
@@ -4367,7 +4367,7 @@ static int tg3_alloc_rx_skb(struct tg3 *tp, u32 opaque_key,
 
 	case RXD_OPAQUE_RING_JUMBO:
 		dest_idx = dest_idx_unmasked % TG3_RX_JUMBO_RING_SIZE;
-		desc = &tpr->rx_jmb[dest_idx];
+		desc = &tpr->rx_jmb[dest_idx].std;
 		map = &tpr->rx_jmb_buffers[dest_idx];
 		if (src_idx >= 0)
 			src_map = &tpr->rx_jmb_buffers[src_idx];
@@ -4428,9 +4428,9 @@ static void tg3_recycle_rx(struct tg3 *tp, u32 opaque_key,
 
 	case RXD_OPAQUE_RING_JUMBO:
 		dest_idx = dest_idx_unmasked % TG3_RX_JUMBO_RING_SIZE;
-		dest_desc = &tpr->rx_jmb[dest_idx];
+		dest_desc = &tpr->rx_jmb[dest_idx].std;
 		dest_map = &tpr->rx_jmb_buffers[dest_idx];
-		src_desc = &tpr->rx_jmb[src_idx];
+		src_desc = &tpr->rx_jmb[src_idx].std;
 		src_map = &tpr->rx_jmb_buffers[src_idx];
 		break;
 
@@ -5614,7 +5614,7 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 		for (i = 0; i < TG3_RX_JUMBO_RING_SIZE; i++) {
 			struct tg3_rx_buffer_desc *rxd;
 
-			rxd = &tpr->rx_jmb[i];
+			rxd = &tpr->rx_jmb[i].std;
 			rxd->idx_len = TG3_RX_JMB_DMA_SZ << RXD_LEN_SHIFT;
 			rxd->type_flags = (RXD_FLAG_END << RXD_FLAGS_SHIFT) |
 				RXD_FLAG_JUMBO;
@@ -7053,7 +7053,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW,
 			     ((u64) tpr->rx_jmb_mapping & 0xffffffff));
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_MAXLEN_FLAGS,
-			     RX_JUMBO_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT);
+			     (RX_JUMBO_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT) |
+			     BDINFO_FLAGS_USE_EXT_RECV);
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_NIC_ADDR,
 			     NIC_SRAM_RX_JUMBO_BUFFER_DESC);
 		} else {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 7a27cff..982171f 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2480,7 +2480,7 @@ struct tg3_rx_prodring_set {
 	u32				rx_std_ptr;
 	u32				rx_jmb_ptr;
 	struct tg3_rx_buffer_desc	*rx_std;
-	struct tg3_rx_buffer_desc	*rx_jmb;
+	struct tg3_ext_rx_buffer_desc	*rx_jmb;
 	struct ring_info		*rx_std_buffers;
 	struct ring_info		*rx_jmb_buffers;
 	dma_addr_t			rx_std_mapping;
-- 
1.6.3.3


