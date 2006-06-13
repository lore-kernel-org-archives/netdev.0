From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.18 3/6] bnx2: Use CPU native page size
Date: Mon, 12 Jun 2006 17:17:13 -0700
Message-ID: <1150157833.26173.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:10250 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932677AbWFMAUi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 20:20:38 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use CPU native page size to determine various ring sizes. This allows
order-0 memory allocations on all systems.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 49c09da..7a3d888 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -32,6 +32,7 @@
 #include <asm/irq.h>
 #include <linux/delay.h>
 #include <asm/byteorder.h>
+#include <asm/page.h>
 #include <linux/time.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
@@ -3270,13 +3271,13 @@ bnx2_init_chip(struct bnx2 *bp)
 	REG_WR(bp, BNX2_MQ_KNL_BYP_WIND_START, val);
 	REG_WR(bp, BNX2_MQ_KNL_WIND_END, val);
 
-	val = (BCM_PAGE_BITS - 8) << 24;
+	val = (PAGE_SHIFT - 8) << 24;
 	REG_WR(bp, BNX2_RV2P_CONFIG, val);
 
 	/* Configure page size. */
 	val = REG_RD(bp, BNX2_TBDR_CONFIG);
 	val &= ~BNX2_TBDR_CONFIG_PAGE_SIZE;
-	val |= (BCM_PAGE_BITS - 8) << 24 | 0x40;
+	val |= (PAGE_SHIFT - 8) << 24 | 0x40;
 	REG_WR(bp, BNX2_TBDR_CONFIG, val);
 
 	val = bp->mac_addr[0] +
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index ea1ab06..de2b58c 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -3750,14 +3750,11 @@ struct l2_fhdr {
 #define DMA_READ_CHANS	5
 #define DMA_WRITE_CHANS	3
 
-#define BCM_PAGE_BITS	12
-#define BCM_PAGE_SIZE	(1 << BCM_PAGE_BITS)
-
-#define TX_DESC_CNT  (BCM_PAGE_SIZE / sizeof(struct tx_bd))
+#define TX_DESC_CNT  (PAGE_SIZE / sizeof(struct tx_bd))
 #define MAX_TX_DESC_CNT (TX_DESC_CNT - 1)
 
 #define MAX_RX_RINGS	4
-#define RX_DESC_CNT  (BCM_PAGE_SIZE / sizeof(struct rx_bd))
+#define RX_DESC_CNT  (PAGE_SIZE / sizeof(struct rx_bd))
 #define MAX_RX_DESC_CNT (RX_DESC_CNT - 1)
 #define MAX_TOTAL_RX_DESC_CNT (MAX_RX_DESC_CNT * MAX_RX_RINGS)
 
@@ -3773,7 +3770,7 @@ struct l2_fhdr {
 
 #define RX_RING_IDX(x) ((x) & bp->rx_max_ring_idx)
 
-#define RX_RING(x) (((x) & ~MAX_RX_DESC_CNT) >> 8)
+#define RX_RING(x) (((x) & ~MAX_RX_DESC_CNT) >> (PAGE_SHIFT - 4))
 #define RX_IDX(x) ((x) & MAX_RX_DESC_CNT)
 
 /* Context size. */


