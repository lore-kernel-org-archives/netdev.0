From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/8] tg3: 5719: Prevent tx data corruption
Date: Thu, 30 Sep 2010 13:34:31 -0700
Message-ID: <1285878877-12148-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2217 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756626Ab0I3Uey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 16:34:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables a bit that prevents read DMA overflows and adjusts
the txmbuf margin from the hardware default.  The combination of these
modifications prevents a tx data corruption issue we were seeing on the
5719.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   12 +++++++++++-
 drivers/net/tg3.h |    8 +++++++-
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d64fec1..4f35a5c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7857,7 +7857,10 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32(BUFMGR_DMA_HIGH_WATER,
 	     tp->bufmgr_config.dma_high_water);
 
-	tw32(BUFMGR_MODE, BUFMGR_MODE_ENABLE | BUFMGR_MODE_ATTN_ENABLE);
+	val = BUFMGR_MODE_ENABLE | BUFMGR_MODE_ATTN_ENABLE;
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+		val |= BUFMGR_MODE_NO_TX_UNDERRUN;
+	tw32(BUFMGR_MODE, val);
 	for (i = 0; i < 2000; i++) {
 		if (tr32(BUFMGR_MODE) & BUFMGR_MODE_ENABLE)
 			break;
@@ -8037,6 +8040,13 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		     val | TG3_RDMA_RSRVCTRL_FIFO_OFLW_FIX);
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719) {
+		val = tr32(TG3_LSO_RD_DMA_CRPTEN_CTRL);
+		tw32(TG3_LSO_RD_DMA_CRPTEN_CTRL, val |
+		     TG3_LSO_RD_DMA_CRPTEN_CTRL_BLEN_BD_4K |
+		     TG3_LSO_RD_DMA_CRPTEN_CTRL_BLEN_LSO_4K);
+	}
+
 	/* Receive/send statistics. */
 	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
 		val = tr32(RCVLPC_STATS_ENABLE);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 44733e4..ec62f05 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1225,6 +1225,7 @@
 #define  BUFMGR_MODE_ATTN_ENABLE	 0x00000004
 #define  BUFMGR_MODE_BM_TEST		 0x00000008
 #define  BUFMGR_MODE_MBLOW_ATTN_ENAB	 0x00000010
+#define  BUFMGR_MODE_NO_TX_UNDERRUN	 0x80000000
 #define BUFMGR_STATUS			0x00004404
 #define  BUFMGR_STATUS_ERROR		 0x00000004
 #define  BUFMGR_STATUS_MBLOW		 0x00000010
@@ -1306,7 +1307,12 @@
 
 #define TG3_RDMA_RSRVCTRL_REG		0x00004900
 #define TG3_RDMA_RSRVCTRL_FIFO_OFLW_FIX	 0x00000004
-/* 0x4904 --> 0x4c00 unused */
+/* 0x4904 --> 0x4910 unused */
+
+#define TG3_LSO_RD_DMA_CRPTEN_CTRL	0x00004910
+#define TG3_LSO_RD_DMA_CRPTEN_CTRL_BLEN_BD_4K	 0x00030000
+#define TG3_LSO_RD_DMA_CRPTEN_CTRL_BLEN_LSO_4K	 0x000c0000
+/* 0x4914 --> 0x4c00 unused */
 
 /* Write DMA control registers */
 #define WDMAC_MODE			0x00004c00
-- 
1.7.2.2


