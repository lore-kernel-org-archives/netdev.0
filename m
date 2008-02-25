From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH resend 2.6.25 6/12][BNX2X]: MSI-X / INT#A errata
Date: Mon, 25 Feb 2008 12:33:01 +0200
Message-ID: <1203935581.8232.210.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1670 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636AbYBYKe6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 05:34:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: MSI-X / INT#A errata - workaround for a HW bug when moving from MSI-X to INT#A without a reboot

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index a35feee..6f987fa 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -443,7 +443,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 	DP(BNX2X_MSG_STATS, "stats_state - DISABLE\n");
 }
 
-static void bnx2x_enable_int(struct bnx2x *bp)
+static void bnx2x_int_enable(struct bnx2x *bp)
 {
 	int port = bp->port;
 	u32 addr = port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
@@ -456,18 +456,26 @@ static void bnx2x_enable_int(struct bnx2x *bp)
 			HC_CONFIG_0_REG_ATTN_BIT_EN_0);
 	} else {
 		val |= (HC_CONFIG_0_REG_SINGLE_ISR_EN_0 |
+			HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0 |
 			HC_CONFIG_0_REG_INT_LINE_EN_0 |
 			HC_CONFIG_0_REG_ATTN_BIT_EN_0);
+
+		/* Errata A0.158 workaround */
+		DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)  MSI-X %d\n",
+		   val, port, addr, msix);
+
+		REG_WR(bp, addr, val);
+
 		val &= ~HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0;
 	}
 
-	DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)  msi %d\n",
+	DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)  MSI-X %d\n",
 	   val, port, addr, msix);
 
 	REG_WR(bp, addr, val);
 }
 
-static void bnx2x_disable_int(struct bnx2x *bp)
+static void bnx2x_int_disable(struct bnx2x *bp)
 {
 	int port = bp->port;
 	u32 addr = port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
@@ -486,7 +494,7 @@ static void bnx2x_disable_int(struct bnx2x *bp)
 		BNX2X_ERR("BUG! proper val not read from IGU!\n");
 }
 
-static void bnx2x_disable_int_sync(struct bnx2x *bp)
+static void bnx2x_int_disable_sync(struct bnx2x *bp)
 {
 
 	int msix = (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
@@ -494,7 +502,7 @@ static void bnx2x_disable_int_sync(struct bnx2x *bp)
 
 	atomic_inc(&bp->intr_sem);
 	/* prevent the HW from sending interrupts */
-	bnx2x_disable_int(bp);
+	bnx2x_int_disable(bp);
 
 	/* make sure all ISRs are done */
 	if (msix) {
@@ -5710,7 +5718,7 @@ static void bnx2x_nic_init(struct bnx2x *bp)
 	bnx2x_init_internal(bp);
 	bnx2x_init_stats(bp);
 	bnx2x_init_ind_table(bp);
-	bnx2x_enable_int(bp);
+	bnx2x_int_enable(bp);
 
 }
 
@@ -7154,7 +7162,7 @@ stop_netif:
 		napi_disable(&bnx2x_fp(bp, i, napi));
 
 int_disable:
-	bnx2x_disable_int_sync(bp);
+	bnx2x_int_disable_sync(bp);
 
 	bnx2x_free_skbs(bp);
 	bnx2x_free_irq(bp);
@@ -7174,7 +7182,7 @@ static void bnx2x_netif_stop(struct bnx2x *bp)
 	bp->rx_mode = BNX2X_RX_MODE_NONE;
 	bnx2x_set_storm_rx_mode(bp);
 
-	bnx2x_disable_int_sync(bp);
+	bnx2x_int_disable_sync(bp);
 	bnx2x_link_reset(bp);
 
 	for_each_queue(bp, i)
-- 
1.5.3.2




