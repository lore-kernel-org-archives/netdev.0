From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 17/36] bnx2x: Configurable pause scheme
Date: Wed, 12 Aug 2009 21:23:26 +0300
Message-ID: <1250101406.27379.169.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3470 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753247AbZHLSYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a given ring is running out of space, the FW can send pause towards the
network. When working with multi-queues, when one queue is getting out of space
it can block all other queues. The preferred scheme is to send pause frames only
when running out of the shared internal chip buffers and if a given queue cannot
place a packet on the host, it will drop it. Since some users might want to work
in drop-less mode, allowing changing the behavior as a module parameter.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    2 ++
 drivers/net/bnx2x_main.c |   14 ++++++++++----
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 1d0b727..004f4a8 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -967,6 +967,8 @@ struct bnx2x {
 	dma_addr_t      	qm_mapping;
 #endif
 
+	int			dropless_fc;
+
 	int			dmae_ready;
 	/* used to synchronize dmae accesses */
 	struct mutex		dmae_mutex;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index c4427ef..e9e4349 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -101,6 +101,10 @@ static int int_mode;
 module_param(int_mode, int, 0);
 MODULE_PARM_DESC(int_mode, " Force interrupt mode (1 INT#x; 2 MSI)");
 
+static int dropless_fc;
+module_param(dropless_fc, int, 0);
+MODULE_PARM_DESC(dropless_fc, " Pause on exhausted host ring");
+
 static int poll;
 module_param(poll, int, 0);
 MODULE_PARM_DESC(poll, " Use polling (for debug)");
@@ -2368,7 +2372,7 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 	if (bp->link_vars.link_up) {
 
 		/* dropless flow control */
-		if (CHIP_IS_E1H(bp)) {
+		if (CHIP_IS_E1H(bp) && bp->dropless_fc) {
 			int port = BP_PORT(bp);
 			u32 pause_enabled = 0;
 
@@ -6358,9 +6362,6 @@ static int bnx2x_init_port(struct bnx2x *bp)
 		REG_WR(bp, NIG_REG_LLH0_BRB1_DRV_MASK_MF + port*4,
 		       (IS_E1HMF(bp) ? 0x1 : 0x2));
 
-		/* support pause requests from USDM, TSDM and BRB */
-		REG_WR(bp, NIG_REG_LLFC_EGRESS_SRC_ENABLE_0 + port*4, 0x7);
-
 		{
 			REG_WR(bp, NIG_REG_LLFC_ENABLE_0 + port*4, 0);
 			REG_WR(bp, NIG_REG_LLFC_OUT_EN_0 + port*4, 0);
@@ -8676,6 +8677,11 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 		bp->dev->features |= NETIF_F_LRO;
 	}
 
+	if (CHIP_IS_E1(bp))
+		bp->dropless_fc = 0;
+	else
+		bp->dropless_fc = dropless_fc;
+
 	bp->mrrs = mrrs;
 
 	bp->tx_ring_size = MAX_TX_AVAIL;
-- 
1.5.4.3




