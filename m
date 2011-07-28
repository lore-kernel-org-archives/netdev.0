From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 8/9] tg3: Break larger frags into 4k chunks for
 5719
Date: Wed, 27 Jul 2011 17:20:53 -0700
Message-ID: <1311812454-18197-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4049 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752785Ab1G1AR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2011 20:17:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5719 has bug where RDMAs larger than 4k can cause problems.  This
patch works around the problem by dividing larger DMA requests into
something the hardware can handle.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++------
 drivers/net/tg3.h |    1 +
 2 files changed, 47 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b93ba3d..c77a39d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -190,6 +190,7 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 /* minimum number of free TX descriptors required to wake up TX process */
 #define TG3_TX_WAKEUP_THRESH(tnapi)		((tnapi)->tx_pending / 4)
+#define TG3_TX_BD_DMA_MAX		4096
 
 #define TG3_RAW_IP_ALIGN 2
 
@@ -5940,14 +5941,50 @@ static bool tg3_tx_frag_set(struct tg3_napi *tnapi, u32 *entry, u32 *budget,
 	if (tg3_40bit_overflow_test(tp, map, len))
 		hwbug = 1;
 
-	if (*budget) {
+	if (tg3_flag(tp, 4K_FIFO_LIMIT)) {
+		u32 tmp_flag = flags & ~TXD_FLAG_END;
+		while (len > TG3_TX_BD_DMA_MAX) {
+			u32 frag_len = TG3_TX_BD_DMA_MAX;
+			len -= TG3_TX_BD_DMA_MAX;
+
+			if (len) {
+				tnapi->tx_buffers[*entry].fragmented = true;
+				/* Avoid the 8byte DMA problem */
+				if (len <= 8) {
+					len += TG3_TX_BD_DMA_MAX / 2;
+					frag_len = TG3_TX_BD_DMA_MAX / 2;
+				}
+			} else
+				tmp_flag = flags;
+
+			if (*budget) {
+				tg3_tx_set_bd(&tnapi->tx_ring[*entry], map,
+					      frag_len, tmp_flag, mss, vlan);
+				(*budget)--;
+				*entry = NEXT_TX(*entry);
+			} else {
+				hwbug = 1;
+				break;
+			}
+
+			map += frag_len;
+		}
+
+		if (len) {
+			if (*budget) {
+				tg3_tx_set_bd(&tnapi->tx_ring[*entry], map,
+					      len, flags, mss, vlan);
+				(*budget)--;
+				*entry = NEXT_TX(*entry);
+			} else {
+				hwbug = 1;
+			}
+		}
+	} else {
 		tg3_tx_set_bd(&tnapi->tx_ring[*entry], map,
 			      len, flags, mss, vlan);
-		(*budget)--;
-	} else
-		hwbug = 1;
-
-	*entry = NEXT_TX(*entry);
+		*entry = NEXT_TX(*entry);
+	}
 
 	return hwbug;
 }
@@ -13899,6 +13936,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (tg3_flag(tp, 5755_PLUS))
 		tg3_flag_set(tp, SHORT_DMA_BUG);
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+		tg3_flag_set(tp, 4K_FIFO_LIMIT);
+
 	if (tg3_flag(tp, 5717_PLUS))
 		tg3_flag_set(tp, LRG_PROD_RING_CAP);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 466dd7a..2ea456d 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2905,6 +2905,7 @@ enum TG3_FLAGS {
 	TG3_FLAG_57765_PLUS,
 	TG3_FLAG_APE_HAS_NCSI,
 	TG3_FLAG_5717_PLUS,
+	TG3_FLAG_4K_FIFO_LIMIT,
 
 	/* Add new flags before this comment and TG3_FLAG_NUMBER_OF_FLAGS */
 	TG3_FLAG_NUMBER_OF_FLAGS,	/* Last entry in enum TG3_FLAGS */
-- 
1.7.3.4


