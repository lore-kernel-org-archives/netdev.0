From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/9] tg3: Workaround rx_discards stat bug
Date: Wed, 20 Apr 2011 10:57:35 -0700
Message-ID: <1303322263-18991-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1815 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318Ab1DTRsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 13:48:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5717, 5718, 5719 A0, and 5720 A0 has a bug where the rx_discards
statistic counter will increment when dropping unwanted multicast
frames.  This patch works around the problem by attempting to
recreate the data using other means.  The resulting value will not be
accurate, but it can still serve as a problem indicator.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   27 ++++++++++++++++++++++++++-
 drivers/net/tg3.h |    2 ++
 2 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9915734..58787ea 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -339,6 +339,7 @@ static const struct {
 	{ "dma_write_prioq_full" },
 	{ "rxbds_empty" },
 	{ "rx_discards" },
+	{ "mbuf_lwm_thresh_hit" },
 	{ "rx_errors" },
 	{ "rx_threshold_hit" },
 
@@ -8207,6 +8208,10 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	val = BUFMGR_MODE_ENABLE | BUFMGR_MODE_ATTN_ENABLE;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
 		val |= BUFMGR_MODE_NO_TX_UNDERRUN;
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+	    tp->pci_chip_rev_id == CHIPREV_ID_5719_A0 ||
+	    tp->pci_chip_rev_id == CHIPREV_ID_5720_A0)
+		val |= BUFMGR_MODE_MBLOW_ATTN_ENAB;
 	tw32(BUFMGR_MODE, val);
 	for (i = 0; i < 2000; i++) {
 		if (tr32(BUFMGR_MODE) & BUFMGR_MODE_ENABLE)
@@ -8870,7 +8875,19 @@ static void tg3_periodic_fetch_stats(struct tg3 *tp)
 	TG3_STAT_ADD32(&sp->rx_undersize_packets, MAC_RX_STATS_UNDERSIZE);
 
 	TG3_STAT_ADD32(&sp->rxbds_empty, RCVLPC_NO_RCV_BD_CNT);
-	TG3_STAT_ADD32(&sp->rx_discards, RCVLPC_IN_DISCARDS_CNT);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717) {
+		TG3_STAT_ADD32(&sp->rx_discards, RCVLPC_IN_DISCARDS_CNT);
+	} else {
+		u32 val = tr32(HOSTCC_FLOW_ATTN);
+		val = (val & HOSTCC_FLOW_ATTN_MBUF_LWM) ? 1 : 0;
+		if (val) {
+			tw32(HOSTCC_FLOW_ATTN, HOSTCC_FLOW_ATTN_MBUF_LWM);
+			sp->rx_discards.low += val;
+			if (sp->rx_discards.low < val)
+				sp->rx_discards.high += 1;
+		}
+		sp->mbuf_lwm_thresh_hit = sp->rx_discards;
+	}
 	TG3_STAT_ADD32(&sp->rx_errors, RCVLPC_IN_ERRORS_CNT);
 }
 
@@ -13973,6 +13990,14 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5700_BX)
 		tp->coalesce_mode |= HOSTCC_MODE_32BYTE;
 
+	/* Set these bits to enable statistics workaround. */
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+	    tp->pci_chip_rev_id == CHIPREV_ID_5719_A0 ||
+	    tp->pci_chip_rev_id == CHIPREV_ID_5720_A0) {
+		tp->coalesce_mode |= HOSTCC_MODE_ATTN;
+		tp->grc_mode |= GRC_MODE_IRQ_ON_FLOW_ATTN;
+	}
+
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 		tp->tg3_flags3 |= TG3_FLG3_USE_PHYLIB;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 224c3e0..db50bfe 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -147,6 +147,7 @@
 #define  CHIPREV_ID_5717_A0		 0x05717000
 #define  CHIPREV_ID_57765_A0		 0x57785000
 #define  CHIPREV_ID_5719_A0		 0x05719000
+#define  CHIPREV_ID_5720_A0		 0x05720000
 #define  GET_ASIC_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 12)
 #define   ASIC_REV_5700			 0x07
 #define   ASIC_REV_5701			 0x00
@@ -2602,6 +2603,7 @@ struct tg3_hw_stats {
 	tg3_stat64_t			dma_write_prioq_full;
 	tg3_stat64_t			rxbds_empty;
 	tg3_stat64_t			rx_discards;
+	tg3_stat64_t			mbuf_lwm_thresh_hit;
 	tg3_stat64_t			rx_errors;
 	tg3_stat64_t			rx_threshold_hit;
 
-- 
1.7.3.4


