From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 2/6] tg3: Simplify ring control block setup
Date: Thu, 23 May 2013 14:11:23 -0700
Message-ID: <1369343487-6453-3-git-send-email-nsujir@broadcom.com>
References: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1134 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758993Ab3EWVLn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 17:11:43 -0400
In-Reply-To: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code calls tg3_set_bdinfo() separately on napi0, followed by
a loop that does napi1+. Simplify it by setting bdinfo in the loop for
all napi contexts.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 79 +++++++++++++++++++++----------------
 1 file changed, 46 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 77b51c2..e96e888 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9203,6 +9203,48 @@ static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 }
 
 /* tp->lock is held. */
+static void tg3_tx_rcbs_init(struct tg3 *tp)
+{
+	int i = 0;
+	u32 txrcb = NIC_SRAM_SEND_RCB;
+
+	if (tg3_flag(tp, ENABLE_TSS))
+		i++;
+
+	for (; i < tp->irq_max; i++, txrcb += TG3_BDINFO_SIZE) {
+		struct tg3_napi *tnapi = &tp->napi[i];
+
+		if (!tnapi->tx_ring)
+			continue;
+
+		tg3_set_bdinfo(tp, txrcb, tnapi->tx_desc_mapping,
+			       (TG3_TX_RING_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT),
+			       NIC_SRAM_TX_BUFFER_DESC);
+	}
+}
+
+/* tp->lock is held. */
+static void tg3_rx_ret_rcbs_init(struct tg3 *tp)
+{
+	int i = 0;
+	u32 rxrcb = NIC_SRAM_RCV_RET_RCB;
+
+	if (tg3_flag(tp, ENABLE_RSS))
+		i++;
+
+	for (; i < tp->irq_max; i++, rxrcb += TG3_BDINFO_SIZE) {
+		struct tg3_napi *tnapi = &tp->napi[i];
+
+		if (!tnapi->rx_rcb)
+			continue;
+
+		tg3_set_bdinfo(tp, rxrcb, tnapi->rx_rcb_mapping,
+			       (tp->rx_ret_ring_mask + 1) <<
+				BDINFO_FLAGS_MAXLEN_SHIFT, 0);
+	}
+}
+
+/* tp->lock is held. */
 static void tg3_rings_reset(struct tg3 *tp)
 {
 	int i;
@@ -9278,9 +9320,6 @@ static void tg3_rings_reset(struct tg3 *tp)
 			tw32_tx_mbox(mbox + i * 8, 0);
 	}
 
-	txrcb = NIC_SRAM_SEND_RCB;
-	rxrcb = NIC_SRAM_RCV_RET_RCB;
-
 	/* Clear status block in ram. */
 	memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
 
@@ -9290,46 +9329,20 @@ static void tg3_rings_reset(struct tg3 *tp)
 	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_LOW,
 	     ((u64) tnapi->status_mapping & 0xffffffff));
 
-	if (tnapi->tx_ring) {
-		tg3_set_bdinfo(tp, txrcb, tnapi->tx_desc_mapping,
-			       (TG3_TX_RING_SIZE <<
-				BDINFO_FLAGS_MAXLEN_SHIFT),
-			       NIC_SRAM_TX_BUFFER_DESC);
-		txrcb += TG3_BDINFO_SIZE;
-	}
-
-	if (tnapi->rx_rcb) {
-		tg3_set_bdinfo(tp, rxrcb, tnapi->rx_rcb_mapping,
-			       (tp->rx_ret_ring_mask + 1) <<
-				BDINFO_FLAGS_MAXLEN_SHIFT, 0);
-		rxrcb += TG3_BDINFO_SIZE;
-	}
-
 	stblk = HOSTCC_STATBLCK_RING1;
 
 	for (i = 1, tnapi++; i < tp->irq_cnt; i++, tnapi++) {
 		u64 mapping = (u64)tnapi->status_mapping;
 		tw32(stblk + TG3_64BIT_REG_HIGH, mapping >> 32);
 		tw32(stblk + TG3_64BIT_REG_LOW, mapping & 0xffffffff);
+		stblk += 8;
 
 		/* Clear status block in ram. */
 		memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
-
-		if (tnapi->tx_ring) {
-			tg3_set_bdinfo(tp, txrcb, tnapi->tx_desc_mapping,
-				       (TG3_TX_RING_SIZE <<
-					BDINFO_FLAGS_MAXLEN_SHIFT),
-				       NIC_SRAM_TX_BUFFER_DESC);
-			txrcb += TG3_BDINFO_SIZE;
-		}
-
-		tg3_set_bdinfo(tp, rxrcb, tnapi->rx_rcb_mapping,
-			       ((tp->rx_ret_ring_mask + 1) <<
-				BDINFO_FLAGS_MAXLEN_SHIFT), 0);
-
-		stblk += 8;
-		rxrcb += TG3_BDINFO_SIZE;
 	}
+
+	tg3_tx_rcbs_init(tp);
+	tg3_rx_ret_rcbs_init(tp);
 }
 
 static void tg3_setup_rxbd_thresholds(struct tg3 *tp)
-- 
1.8.1.4
