From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/6] tg3: Make the TX BD DMA limit configurable
Date: Wed, 14 Dec 2011 13:09:58 -0800
Message-ID: <1323897002-17295-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2478 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758169Ab1LNVJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Dec 2011 16:09:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 57766 ASIC rev will impose a new TX BD DMA limit on the driver.
This patch prepares for 57766 support by making the tx BD DMA limit
tunable.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   16 ++++++++--------
 drivers/net/ethernet/broadcom/tg3.h |    1 +
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 8a6ea19..9c9a4b4 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -199,7 +199,7 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 /* minimum number of free TX descriptors required to wake up TX process */
 #define TG3_TX_WAKEUP_THRESH(tnapi)		((tnapi)->tx_pending / 4)
-#define TG3_TX_BD_DMA_MAX		4096
+#define TG3_TX_BD_DMA_MAX_4K		4096
 
 #define TG3_RAW_IP_ALIGN 2
 
@@ -6449,17 +6449,17 @@ static bool tg3_tx_frag_set(struct tg3_napi *tnapi, u32 *entry, u32 *budget,
 	if (tg3_40bit_overflow_test(tp, map, len))
 		hwbug = 1;
 
-	if (tg3_flag(tp, 4K_FIFO_LIMIT)) {
+	if (tp->dma_limit) {
 		u32 prvidx = *entry;
 		u32 tmp_flag = flags & ~TXD_FLAG_END;
-		while (len > TG3_TX_BD_DMA_MAX && *budget) {
-			u32 frag_len = TG3_TX_BD_DMA_MAX;
-			len -= TG3_TX_BD_DMA_MAX;
+		while (len > tp->dma_limit && *budget) {
+			u32 frag_len = tp->dma_limit;
+			len -= tp->dma_limit;
 
 			/* Avoid the 8byte DMA problem */
 			if (len <= 8) {
-				len += TG3_TX_BD_DMA_MAX / 2;
-				frag_len = TG3_TX_BD_DMA_MAX / 2;
+				len += tp->dma_limit / 2;
+				frag_len = tp->dma_limit / 2;
 			}
 
 			tnapi->tx_buffers[*entry].fragmented = true;
@@ -14041,7 +14041,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tg3_flag_set(tp, SHORT_DMA_BUG);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
-		tg3_flag_set(tp, 4K_FIFO_LIMIT);
+		tp->dma_limit = TG3_TX_BD_DMA_MAX_4K;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 9d9f634..2ba5be1 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2994,6 +2994,7 @@ struct tg3 {
 	/* begin "tx thread" cacheline section */
 	void				(*write32_tx_mbox) (struct tg3 *, u32,
 							    u32);
+	u32				dma_limit;
 
 	/* begin "rx thread" cacheline section */
 	struct tg3_napi			napi[TG3_IRQ_MAX_VECS];
-- 
1.7.3.4
