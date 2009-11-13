From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 17/20] tg3: Create aliases for rx producer mailbox regs
Date: Fri, 13 Nov 2009 15:03:49 -0800
Message-ID: <1258153432-7036-18-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3252 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932469AbZKMXEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rx producer mailbox registers are used in several spots in the code.
The addition of TG3_64BIT_REG_LOW makes register references
uncomfortably long.  This patch creates an alias for the standard and
jumbo ring producer index registers to make the code cleaner.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   18 ++++++------------
 drivers/net/tg3.h |    4 ++++
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 168a7ca..05fd42f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -402,7 +402,7 @@ static void tg3_write_indirect_mbox(struct tg3 *tp, u32 off, u32 val)
 				       TG3_64BIT_REG_LOW, val);
 		return;
 	}
-	if (off == (MAILBOX_RCV_STD_PROD_IDX + TG3_64BIT_REG_LOW)) {
+	if (off == TG3_RX_STD_PROD_IDX_REG) {
 		pci_write_config_dword(tp->pdev, TG3PCI_STD_RING_PROD_IDX +
 				       TG3_64BIT_REG_LOW, val);
 		return;
@@ -4684,9 +4684,7 @@ next_pkt:
 
 		if (unlikely(rx_std_posted >= tp->rx_std_max_post)) {
 			u32 idx = *post_ptr % TG3_RX_RING_SIZE;
-
-			tw32_rx_mbox(MAILBOX_RCV_STD_PROD_IDX +
-				     TG3_64BIT_REG_LOW, idx);
+			tw32_rx_mbox(TG3_RX_STD_PROD_IDX_REG, idx);
 			work_mask &= ~RXD_OPAQUE_RING_STD;
 			rx_std_posted = 0;
 		}
@@ -4708,13 +4706,11 @@ next_pkt_nopost:
 	/* Refill RX ring(s). */
 	if (work_mask & RXD_OPAQUE_RING_STD) {
 		tpr->rx_std_prod_idx = std_prod_idx % TG3_RX_RING_SIZE;
-		tw32_rx_mbox(MAILBOX_RCV_STD_PROD_IDX + TG3_64BIT_REG_LOW,
-			     tpr->rx_std_prod_idx);
+		tw32_rx_mbox(TG3_RX_STD_PROD_IDX_REG, tpr->rx_std_prod_idx);
 	}
 	if (work_mask & RXD_OPAQUE_RING_JUMBO) {
 		tpr->rx_jmb_prod_idx = jmb_prod_idx % TG3_RX_JUMBO_RING_SIZE;
-		tw32_rx_mbox(MAILBOX_RCV_JUMBO_PROD_IDX + TG3_64BIT_REG_LOW,
-			     tpr->rx_jmb_prod_idx);
+		tw32_rx_mbox(TG3_RX_JMB_PROD_IDX_REG, tpr->rx_jmb_prod_idx);
 	}
 	mmiowb();
 
@@ -7526,13 +7522,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_MAXLEN_FLAGS, val);
 
 	tpr->rx_std_prod_idx = tp->rx_pending;
-	tw32_rx_mbox(MAILBOX_RCV_STD_PROD_IDX + TG3_64BIT_REG_LOW,
-		     tpr->rx_std_prod_idx);
+	tw32_rx_mbox(TG3_RX_STD_PROD_IDX_REG, tpr->rx_std_prod_idx);
 
 	tpr->rx_jmb_prod_idx = (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) ?
 			  tp->rx_jumbo_pending : 0;
-	tw32_rx_mbox(MAILBOX_RCV_JUMBO_PROD_IDX + TG3_64BIT_REG_LOW,
-		     tpr->rx_jmb_prod_idx);
+	tw32_rx_mbox(TG3_RX_JMB_PROD_IDX_REG, tpr->rx_jmb_prod_idx);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
 		tw32(STD_REPLENISH_LWM, 32);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 715df2b..bbfbc5e 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -242,7 +242,11 @@
 #define MAILBOX_GENERAL_7		0x00000258 /* 64-bit */
 #define MAILBOX_RELOAD_STAT		0x00000260 /* 64-bit */
 #define MAILBOX_RCV_STD_PROD_IDX	0x00000268 /* 64-bit */
+#define TG3_RX_STD_PROD_IDX_REG		(MAILBOX_RCV_STD_PROD_IDX + \
+					 TG3_64BIT_REG_LOW)
 #define MAILBOX_RCV_JUMBO_PROD_IDX	0x00000270 /* 64-bit */
+#define TG3_RX_JMB_PROD_IDX_REG		(MAILBOX_RCV_JUMBO_PROD_IDX + \
+					 TG3_64BIT_REG_LOW)
 #define MAILBOX_RCV_MINI_PROD_IDX	0x00000278 /* 64-bit */
 #define MAILBOX_RCVRET_CON_IDX_0	0x00000280 /* 64-bit */
 #define MAILBOX_RCVRET_CON_IDX_1	0x00000288 /* 64-bit */
-- 
1.6.4.4


