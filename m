From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 3/6] tg3: Make tg3_rings_reset() more concise
Date: Thu, 23 May 2013 14:11:24 -0700
Message-ID: <1369343487-6453-4-git-send-email-nsujir@broadcom.com>
References: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2125 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759184Ab3EWVLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 17:11:47 -0400
In-Reply-To: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify the rings reset function and increase readability by moving the
control block disable code into separate functions.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 81 ++++++++++++++++++++++---------------
 1 file changed, 48 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e96e888..3906327 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9203,6 +9203,28 @@ static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 }
 
 /* tp->lock is held. */
+static void tg3_tx_rcbs_disable(struct tg3 *tp)
+{
+	u32 txrcb, limit;
+
+	/* Disable all transmit rings but the first. */
+	if (!tg3_flag(tp, 5705_PLUS))
+		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 16;
+	else if (tg3_flag(tp, 5717_PLUS))
+		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 4;
+	else if (tg3_flag(tp, 57765_CLASS) ||
+		 tg3_asic_rev(tp) == ASIC_REV_5762)
+		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 2;
+	else
+		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE;
+
+	for (txrcb = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE;
+	     txrcb < limit; txrcb += TG3_BDINFO_SIZE)
+		tg3_write_mem(tp, txrcb + TG3_BDINFO_MAXLEN_FLAGS,
+			      BDINFO_FLAGS_DISABLED);
+}
+
+/* tp->lock is held. */
 static void tg3_tx_rcbs_init(struct tg3 *tp)
 {
 	int i = 0;
@@ -9224,6 +9246,29 @@ static void tg3_tx_rcbs_init(struct tg3 *tp)
 }
 
 /* tp->lock is held. */
+static void tg3_rx_ret_rcbs_disable(struct tg3 *tp)
+{
+	u32 rxrcb, limit;
+
+	/* Disable all receive return rings but the first. */
+	if (tg3_flag(tp, 5717_PLUS))
+		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 17;
+	else if (!tg3_flag(tp, 5705_PLUS))
+		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 16;
+	else if (tg3_asic_rev(tp) == ASIC_REV_5755 ||
+		 tg3_asic_rev(tp) == ASIC_REV_5762 ||
+		 tg3_flag(tp, 57765_CLASS))
+		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 4;
+	else
+		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE;
+
+	for (rxrcb = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE;
+	     rxrcb < limit; rxrcb += TG3_BDINFO_SIZE)
+		tg3_write_mem(tp, rxrcb + TG3_BDINFO_MAXLEN_FLAGS,
+			      BDINFO_FLAGS_DISABLED);
+}
+
+/* tp->lock is held. */
 static void tg3_rx_ret_rcbs_init(struct tg3 *tp)
 {
 	int i = 0;
@@ -9248,42 +9293,12 @@ static void tg3_rx_ret_rcbs_init(struct tg3 *tp)
 static void tg3_rings_reset(struct tg3 *tp)
 {
 	int i;
-	u32 stblk, txrcb, rxrcb, limit;
+	u32 stblk;
 	struct tg3_napi *tnapi = &tp->napi[0];
 
-	/* Disable all transmit rings but the first. */
-	if (!tg3_flag(tp, 5705_PLUS))
-		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 16;
-	else if (tg3_flag(tp, 5717_PLUS))
-		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 4;
-	else if (tg3_flag(tp, 57765_CLASS) ||
-		 tg3_asic_rev(tp) == ASIC_REV_5762)
-		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 2;
-	else
-		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE;
-
-	for (txrcb = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE;
-	     txrcb < limit; txrcb += TG3_BDINFO_SIZE)
-		tg3_write_mem(tp, txrcb + TG3_BDINFO_MAXLEN_FLAGS,
-			      BDINFO_FLAGS_DISABLED);
-
-
-	/* Disable all receive return rings but the first. */
-	if (tg3_flag(tp, 5717_PLUS))
-		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 17;
-	else if (!tg3_flag(tp, 5705_PLUS))
-		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 16;
-	else if (tg3_asic_rev(tp) == ASIC_REV_5755 ||
-		 tg3_asic_rev(tp) == ASIC_REV_5762 ||
-		 tg3_flag(tp, 57765_CLASS))
-		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 4;
-	else
-		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE;
+	tg3_tx_rcbs_disable(tp);
 
-	for (rxrcb = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE;
-	     rxrcb < limit; rxrcb += TG3_BDINFO_SIZE)
-		tg3_write_mem(tp, rxrcb + TG3_BDINFO_MAXLEN_FLAGS,
-			      BDINFO_FLAGS_DISABLED);
+	tg3_rx_ret_rcbs_disable(tp);
 
 	/* Disable interrupts */
 	tw32_mailbox_f(tp->napi[0].int_mbox, 1);
-- 
1.8.1.4
