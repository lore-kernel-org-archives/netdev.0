From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 04/41]bnx2x: System-page alignment
Date: Thu, 12 Feb 2009 20:36:18 +0200
Message-ID: <1234463778.1863.135.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2685 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757835AbZBLSgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:36:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 04/41]bnx2x: System-page alignment

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    7 +++++--
 drivers/net/bnx2x_main.c |   11 ++++-------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 153cc95..89a72c8 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -158,8 +158,6 @@ struct sw_rx_page {
 #define SGE_PAGE_SHIFT			PAGE_SHIFT
 #define SGE_PAGE_ALIGN(addr)		PAGE_ALIGN(addr)
 
-#define BCM_RX_ETH_PAYLOAD_ALIGN	64
-
 /* SGE ring related macros */
 #define NUM_RX_SGE_PAGES		2
 #define RX_SGE_CNT		(BCM_PAGE_SIZE / sizeof(struct eth_rx_sge))
@@ -758,6 +756,11 @@ struct bnx2x {
 #define ETH_MAX_PACKET_SIZE		1500
 #define ETH_MAX_JUMBO_PACKET_SIZE	9600
 
+	/* Max supported alignment is 256 (8 shift) */
+#define BNX2X_RX_ALIGN_SHIFT		((L1_CACHE_SHIFT < 8) ? \
+					 L1_CACHE_SHIFT : 8)
+#define BNX2X_RX_ALIGN			(1 << BNX2X_RX_ALIGN_SHIFT)
+
 	struct host_def_status_block *def_status_blk;
 #define DEF_SB_ID			16
 	u16			def_c_idx;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index db8506d..312f652 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4296,14 +4296,11 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 	u16 ring_prod, cqe_ring_prod;
 	int i, j;
 
-	bp->rx_buf_size = bp->dev->mtu;
-	bp->rx_buf_size += bp->rx_offset + ETH_OVREHEAD +
-		BCM_RX_ETH_PAYLOAD_ALIGN;
+	bp->rx_buf_size += bp->rx_offset + ETH_OVREHEAD + BNX2X_RX_ALIGN;
+	DP(NETIF_MSG_IFUP,
+	   "mtu %d  rx_buf_size %d\n", bp->dev->mtu, bp->rx_buf_size);
 
 	if (bp->flags & TPA_ENABLE_FLAG) {
-		DP(NETIF_MSG_IFUP,
-		   "rx_buf_size %d  effective_mtu %d\n",
-		   bp->rx_buf_size, bp->dev->mtu + ETH_OVREHEAD);
 
 		for_each_rx_queue(bp, j) {
 			struct bnx2x_fastpath *fp = &bp->fp[j];
@@ -4502,7 +4499,7 @@ static void bnx2x_init_context(struct bnx2x *bp)
 		context->ustorm_st_context.common.flags =
 			USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT;
 		context->ustorm_st_context.common.mc_alignment_log_size =
-			6 /*BCM_RX_ETH_PAYLOAD_ALIGN*/;
+						BNX2X_RX_ALIGN_SHIFT;
 		context->ustorm_st_context.common.bd_buff_size =
 						bp->rx_buf_size;
 		context->ustorm_st_context.common.bd_page_base_hi =
-- 
1.5.4.3




