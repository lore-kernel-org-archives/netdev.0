From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net 3/5] tg3: Add New 5719 Read DMA workaround
Date: Sun, 29 Jul 2012 22:15:43 -0700
Message-ID: <1343625345-5155-3-git-send-email-mchan@broadcom.com>
References: <1343625345-5155-1-git-send-email-mchan@broadcom.com>
 <1343625345-5155-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2425 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751355Ab2G3FDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2012 01:03:44 -0400
In-Reply-To: <1343625345-5155-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After Power-on-reset, the 5719's TX DMA length registers may contain
uninitialized values and cause TX DMA to stall.  Check for invalid
values and set a register bit to flush the TX channels.  The bit
needs to be turned off after the DMA channels have been flushed.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   23 +++++++++++++++++++++++
 drivers/net/ethernet/broadcom/tg3.h |    7 ++++++-
 2 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index f0434df..50045ed 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9276,6 +9276,19 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_f(RDMAC_MODE, rdmac_mode);
 	udelay(40);
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+		for (i = 0; i < TG3_NUM_RDMA_CHANNELS; i++) {
+			if (tr32(TG3_RDMA_LENGTH + (i << 2)) > TG3_MAX_MTU(tp))
+				break;
+		}
+		if (i < TG3_NUM_RDMA_CHANNELS) {
+			val = tr32(TG3_LSO_RD_DMA_CRPTEN_CTRL);
+			val |= TG3_LSO_RD_DMA_TX_LENGTH_WA;
+			tw32(TG3_LSO_RD_DMA_CRPTEN_CTRL, val);
+			tg3_flag_set(tp, 5719_RDMA_BUG);
+		}
+	}
+
 	tw32(RCVDCC_MODE, RCVDCC_MODE_ENABLE | RCVDCC_MODE_ATTN_ENABLE);
 	if (!tg3_flag(tp, 5705_PLUS))
 		tw32(MBFREE_MODE, MBFREE_MODE_ENABLE);
@@ -9635,6 +9648,16 @@ static void tg3_periodic_fetch_stats(struct tg3 *tp)
 	TG3_STAT_ADD32(&sp->tx_ucast_packets, MAC_TX_STATS_UCAST);
 	TG3_STAT_ADD32(&sp->tx_mcast_packets, MAC_TX_STATS_MCAST);
 	TG3_STAT_ADD32(&sp->tx_bcast_packets, MAC_TX_STATS_BCAST);
+	if (unlikely(tg3_flag(tp, 5719_RDMA_BUG) &&
+		     (sp->tx_ucast_packets.low + sp->tx_mcast_packets.low +
+		      sp->tx_bcast_packets.low) > TG3_NUM_RDMA_CHANNELS)) {
+		u32 val;
+
+		val = tr32(TG3_LSO_RD_DMA_CRPTEN_CTRL);
+		val &= ~TG3_LSO_RD_DMA_TX_LENGTH_WA;
+		tw32(TG3_LSO_RD_DMA_CRPTEN_CTRL, val);
+		tg3_flag_clear(tp, 5719_RDMA_BUG);
+	}
 
 	TG3_STAT_ADD32(&sp->rx_octets, MAC_RX_STATS_OCTETS);
 	TG3_STAT_ADD32(&sp->rx_fragments, MAC_RX_STATS_FRAGMENTS);
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 6fb45a5..6d52cb2 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -1376,7 +1376,11 @@
 #define TG3_LSO_RD_DMA_CRPTEN_CTRL	0x00004910
 #define TG3_LSO_RD_DMA_CRPTEN_CTRL_BLEN_BD_4K	 0x00030000
 #define TG3_LSO_RD_DMA_CRPTEN_CTRL_BLEN_LSO_4K	 0x000c0000
-/* 0x4914 --> 0x4c00 unused */
+#define TG3_LSO_RD_DMA_TX_LENGTH_WA	 0x02000000
+/* 0x4914 --> 0x4be0 unused */
+
+#define TG3_NUM_RDMA_CHANNELS		4
+#define TG3_RDMA_LENGTH			0x00004be0
 
 /* Write DMA control registers */
 #define WDMAC_MODE			0x00004c00
@@ -2959,6 +2963,7 @@ enum TG3_FLAGS {
 	TG3_FLAG_L1PLLPD_EN,
 	TG3_FLAG_APE_HAS_NCSI,
 	TG3_FLAG_4K_FIFO_LIMIT,
+	TG3_FLAG_5719_RDMA_BUG,
 	TG3_FLAG_RESET_TASK_PENDING,
 	TG3_FLAG_5705_PLUS,
 	TG3_FLAG_IS_5788,
-- 
1.7.1
