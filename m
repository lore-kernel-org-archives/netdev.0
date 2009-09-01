From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 03/18] tg3: Create tg3_rings_reset()
Date: Tue, 1 Sep 2009 15:53:31 -0700
Message-ID: <1251867300.5920@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2619 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046AbZIBEzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves most of the chip ring setup logic into a separate
function.  This will make it easier to verify the multi ring setup
changes.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |  140 ++++++++++++++++++++++++++++++----------------------
 1 files changed, 81 insertions(+), 59 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ff65ae8..14cead6 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6818,6 +6818,76 @@ static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 }
 
 /* tp->lock is held. */
+static void tg3_rings_reset(struct tg3 *tp)
+{
+	int i;
+	u32 txrcb, rxrcb, limit;
+	struct tg3_napi *tnapi = &tp->napi[0];
+
+	/* Disable all transmit rings but the first. */
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 16;
+	else
+		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE;
+
+	for (txrcb = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE;
+	     txrcb < limit; txrcb += TG3_BDINFO_SIZE)
+		tg3_write_mem(tp, txrcb + TG3_BDINFO_MAXLEN_FLAGS,
+			      BDINFO_FLAGS_DISABLED);
+
+
+	/* Disable all receive return rings but the first. */
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 16;
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755)
+		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 4;
+	else
+		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE;
+
+	for (rxrcb = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE;
+	     rxrcb < limit; rxrcb += TG3_BDINFO_SIZE)
+		tg3_write_mem(tp, rxrcb + TG3_BDINFO_MAXLEN_FLAGS,
+			      BDINFO_FLAGS_DISABLED);
+
+	/* Disable interrupts */
+	tw32_mailbox_f(tp->napi[0].int_mbox, 1);
+
+	/* Zero mailbox registers. */
+	tp->napi[0].tx_prod = 0;
+	tp->napi[0].tx_cons = 0;
+	tw32_mailbox(tp->napi[0].prodmbox, 0);
+	tw32_rx_mbox(tp->napi[0].consmbox, 0);
+
+	/* Make sure the NIC-based send BD rings are disabled. */
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
+		u32 mbox = MAILBOX_SNDNIC_PROD_IDX_0 + TG3_64BIT_REG_LOW;
+		for (i = 0; i < 16; i++)
+			tw32_tx_mbox(mbox + i * 8, 0);
+	}
+
+	txrcb = NIC_SRAM_SEND_RCB;
+	rxrcb = NIC_SRAM_RCV_RET_RCB;
+
+	/* Clear status block in ram. */
+	memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
+
+	/* Set status block DMA address */
+	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_HIGH,
+	     ((u64) tnapi->status_mapping >> 32));
+	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_LOW,
+	     ((u64) tnapi->status_mapping & 0xffffffff));
+
+	tg3_set_bdinfo(tp, txrcb, tnapi->tx_desc_mapping,
+		       (TG3_TX_RING_SIZE <<
+			BDINFO_FLAGS_MAXLEN_SHIFT),
+		       NIC_SRAM_TX_BUFFER_DESC);
+
+	tg3_set_bdinfo(tp, rxrcb, tnapi->rx_rcb_mapping,
+		       (TG3_RX_RCB_RING_SIZE(tp) <<
+			BDINFO_FLAGS_MAXLEN_SHIFT), 0);
+}
+
+/* tp->lock is held. */
 static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 {
 	u32 val, rdmac_mode;
@@ -7091,48 +7161,6 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_MAXLEN_FLAGS, val);
 
-	/* There is only one send ring on 5705/5750, no need to explicitly
-	 * disable the others.
-	 */
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
-		/* Clear out send RCB ring in SRAM. */
-		for (i = NIC_SRAM_SEND_RCB; i < NIC_SRAM_RCV_RET_RCB; i += TG3_BDINFO_SIZE)
-			tg3_write_mem(tp, i + TG3_BDINFO_MAXLEN_FLAGS,
-				      BDINFO_FLAGS_DISABLED);
-	}
-
-	tp->napi[0].tx_prod = 0;
-	tp->napi[0].tx_cons = 0;
-	tw32_tx_mbox(MAILBOX_SNDNIC_PROD_IDX_0 + TG3_64BIT_REG_LOW, 0);
-
-	val = MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW;
-	tw32_mailbox(val, 0);
-
-	tg3_set_bdinfo(tp, NIC_SRAM_SEND_RCB,
-		       tp->napi[0].tx_desc_mapping,
-		       (TG3_TX_RING_SIZE <<
-			BDINFO_FLAGS_MAXLEN_SHIFT),
-		       NIC_SRAM_TX_BUFFER_DESC);
-
-	/* There is only one receive return ring on 5705/5750, no need
-	 * to explicitly disable the others.
-	 */
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
-		for (i = NIC_SRAM_RCV_RET_RCB; i < NIC_SRAM_STATS_BLK;
-		     i += TG3_BDINFO_SIZE) {
-			tg3_write_mem(tp, i + TG3_BDINFO_MAXLEN_FLAGS,
-				      BDINFO_FLAGS_DISABLED);
-		}
-	}
-
-	tw32_rx_mbox(tp->napi[0].consmbox, 0);
-
-	tg3_set_bdinfo(tp, NIC_SRAM_RCV_RET_RCB,
-		       tp->napi[0].rx_rcb_mapping,
-		       (TG3_RX_RCB_RING_SIZE(tp) <<
-			BDINFO_FLAGS_MAXLEN_SHIFT),
-		       0);
-
 	tpr->rx_std_ptr = tp->rx_pending;
 	tw32_rx_mbox(MAILBOX_RCV_STD_PROD_IDX + TG3_64BIT_REG_LOW,
 		     tpr->rx_std_ptr);
@@ -7142,6 +7170,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_rx_mbox(MAILBOX_RCV_JUMBO_PROD_IDX + TG3_64BIT_REG_LOW,
 		     tpr->rx_jmb_ptr);
 
+	tg3_rings_reset(tp);
+
 	/* Initialize MAC address and backoff seed. */
 	__tg3_set_mac_addr(tp, 0);
 
@@ -7229,12 +7259,6 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	__tg3_set_coalesce(tp, &tp->coal);
 
-	/* set status block DMA address */
-	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_HIGH,
-	     ((u64) tp->napi[0].status_mapping >> 32));
-	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_LOW,
-	     ((u64) tp->napi[0].status_mapping & 0xffffffff));
-
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
 		/* Status/statistics block address.  See tg3_timer,
 		 * the tg3_periodic_fetch_stats call there, and
@@ -7245,7 +7269,16 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tw32(HOSTCC_STATS_BLK_HOST_ADDR + TG3_64BIT_REG_LOW,
 		     ((u64) tp->stats_mapping & 0xffffffff));
 		tw32(HOSTCC_STATS_BLK_NIC_ADDR, NIC_SRAM_STATS_BLK);
+
 		tw32(HOSTCC_STATUS_BLK_NIC_ADDR, NIC_SRAM_STATUS_BLK);
+
+		/* Clear statistics and status block memory areas */
+		for (i = NIC_SRAM_STATS_BLK;
+		     i < NIC_SRAM_STATUS_BLK + TG3_HW_STATUS_SIZE;
+		     i += sizeof(u32)) {
+			tg3_write_mem(tp, i, 0);
+			udelay(40);
+		}
 	}
 
 	tw32(HOSTCC_MODE, HOSTCC_MODE_ENABLE | tp->coalesce_mode);
@@ -7255,15 +7288,6 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
 		tw32(RCVLSC_MODE, RCVLSC_MODE_ENABLE | RCVLSC_MODE_ATTN_ENABLE);
 
-	/* Clear statistics/status block in chip, and status block in ram. */
-	for (i = NIC_SRAM_STATS_BLK;
-	     i < NIC_SRAM_STATUS_BLK + TG3_HW_STATUS_SIZE;
-	     i += sizeof(u32)) {
-		tg3_write_mem(tp, i, 0);
-		udelay(40);
-	}
-	memset(tp->napi[0].hw_status, 0, TG3_HW_STATUS_SIZE);
-
 	if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES) {
 		tp->tg3_flags2 &= ~TG3_FLG2_PARALLEL_DETECT;
 		/* reset to prevent losing 1st rx packet intermittently */
@@ -7315,8 +7339,6 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl);
 	udelay(100);
 
-	tw32_mailbox_f(tp->napi[0].int_mbox, 0);
-
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
 		tw32_f(DMAC_MODE, DMAC_MODE_ENABLE);
 		udelay(40);
-- 
1.6.3.3


