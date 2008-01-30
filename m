From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/7][BNX2]: Fine-tune flow control on 5709.
Date: Tue, 29 Jan 2008 16:20:00 -0800
Message-ID: <1201652400.19087.14.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1979 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754752AbYA2Xjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 18:39:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Fine-tune flow control on 5709.

Make use of the programmable high/low water marks in 5709 for
802.3 flow control.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 8af63b4..e41c723 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -992,6 +992,42 @@ bnx2_copper_linkup(struct bnx2 *bp)
 	return 0;
 }
 
+static void
+bnx2_init_rx_context0(struct bnx2 *bp)
+{
+	u32 val, rx_cid_addr = GET_CID_ADDR(RX_CID);
+
+	val = BNX2_L2CTX_CTX_TYPE_CTX_BD_CHN_TYPE_VALUE;
+	val |= BNX2_L2CTX_CTX_TYPE_SIZE_L2;
+	val |= 0x02 << 8;
+
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		u32 lo_water, hi_water;
+
+		if (bp->flow_ctrl & FLOW_CTRL_TX)
+			lo_water = BNX2_L2CTX_LO_WATER_MARK_DEFAULT;
+		else
+			lo_water = BNX2_L2CTX_LO_WATER_MARK_DIS;
+		if (lo_water >= bp->rx_ring_size)
+			lo_water = 0;
+
+		hi_water = bp->rx_ring_size / 4;
+
+		if (hi_water <= lo_water)
+			lo_water = 0;
+			
+		hi_water /= BNX2_L2CTX_HI_WATER_MARK_SCALE;
+		lo_water /= BNX2_L2CTX_LO_WATER_MARK_SCALE;
+
+		if (hi_water > 0xf)
+			hi_water = 0xf;
+		else if (hi_water == 0)
+			lo_water = 0;
+		val |= lo_water | (hi_water << BNX2_L2CTX_HI_WATER_MARK_SHIFT);
+	}
+	bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_CTX_TYPE, val);
+}
+
 static int
 bnx2_set_mac_link(struct bnx2 *bp)
 {
@@ -1056,6 +1092,9 @@ bnx2_set_mac_link(struct bnx2 *bp)
 	/* Acknowledge the interrupt. */
 	REG_WR(bp, BNX2_EMAC_STATUS, BNX2_EMAC_STATUS_LINK_CHANGE);
 
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		bnx2_init_rx_context0(bp);
+
 	return 0;
 }
 
@@ -4616,6 +4655,13 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 	bnx2_init_rxbd_rings(bp->rx_desc_ring, bp->rx_desc_mapping,
 			     bp->rx_buf_use_size, bp->rx_max_ring);
 
+	bnx2_init_rx_context0(bp);
+
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		val = REG_RD(bp, BNX2_MQ_MAP_L2_5);
+		REG_WR(bp, BNX2_MQ_MAP_L2_5, val | BNX2_MQ_MAP_L2_5_ARM);
+	}
+
 	bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_PG_BUF_SIZE, 0);
 	if (bp->rx_pg_ring_size) {
 		bnx2_init_rxbd_rings(bp->rx_pg_desc_ring,
@@ -4636,11 +4682,6 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 			REG_WR(bp, BNX2_MQ_MAP_L2_3, BNX2_MQ_MAP_L2_3_DEFAULT);
 	}
 
-	val = BNX2_L2CTX_CTX_TYPE_CTX_BD_CHN_TYPE_VALUE;
-	val |= BNX2_L2CTX_CTX_TYPE_SIZE_L2;
-	val |= 0x02 << 8;
-	bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_CTX_TYPE, val);
-
 	val = (u64) bp->rx_desc_mapping[0] >> 32;
 	bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_NX_BDHADDR_HI, val);
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index c5fe340..3aa0364 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -348,6 +348,12 @@ struct l2_fhdr {
 #define BNX2_L2CTX_BD_PRE_READ				0x00000000
 #define BNX2_L2CTX_CTX_SIZE				0x00000000
 #define BNX2_L2CTX_CTX_TYPE				0x00000000
+#define BNX2_L2CTX_LO_WATER_MARK_DEFAULT		 32
+#define BNX2_L2CTX_LO_WATER_MARK_SCALE			 4
+#define BNX2_L2CTX_LO_WATER_MARK_DIS			 0
+#define BNX2_L2CTX_HI_WATER_MARK_SHIFT			 4
+#define BNX2_L2CTX_HI_WATER_MARK_SCALE			 16
+#define BNX2_L2CTX_WATER_MARKS_MSK			 0x000000ff
 #define BNX2_L2CTX_CTX_TYPE_SIZE_L2			 ((0x20/20)<<16)
 #define BNX2_L2CTX_CTX_TYPE_CTX_BD_CHN_TYPE		 (0xf<<28)
 #define BNX2_L2CTX_CTX_TYPE_CTX_BD_CHN_TYPE_UNDEFINED	 (0<<28)
@@ -4494,6 +4500,9 @@ struct l2_fhdr {
 #define BNX2_MQ_MAP_L2_3_ENA				 (0x1L<<31)
 #define BNX2_MQ_MAP_L2_3_DEFAULT			 0x82004646
 
+#define BNX2_MQ_MAP_L2_5				0x00003d34
+#define BNX2_MQ_MAP_L2_5_ARM				 (0x3L<<26)
+
 /*
  *  tsch_reg definition
  *  offset: 0x4c00
@@ -6405,7 +6414,7 @@ struct l2_fhdr {
 
 #define RX_COPY_THRESH			128
 
-#define BNX2_MISC_ENABLE_DEFAULT	0x7ffffff
+#define BNX2_MISC_ENABLE_DEFAULT	0x17ffffff
 
 #define DMA_READ_CHANS	5
 #define DMA_WRITE_CHANS	3


