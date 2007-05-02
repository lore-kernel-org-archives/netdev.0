From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 17/20][BNX2]: Enhance the heartbeat.
Date: Tue, 01 May 2007 18:17:36 -0700
Message-ID: <1178068656.4820.53.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2323 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992485AbXEBAam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 20:30:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Enhance the heartbeat.

In addition to the periodic heartbeat, we're adding a heartbeat
request interrupt when the heartbeat is late.  This is useful
especially in -rt kernels where the timer frequently runs late.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 34ae3e9..3d41357 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1152,6 +1152,17 @@ bnx2_set_link(struct bnx2 *bp)
 	return 0;
 }
 
+static void
+bnx2_send_heart_beat(struct bnx2 *bp)
+{
+	u32 msg;
+
+	spin_lock_bh(&bp->phy_lock);
+	msg = (u32) ++bp->fw_drv_pulse_wr_seq;
+	spin_unlock_bh(&bp->phy_lock);
+	REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_PULSE_MB, msg);
+}
+
 static int
 bnx2_reset_phy(struct bnx2 *bp)
 {
@@ -1939,26 +1950,37 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, u16 index)
 	return 0;
 }
 
-static void
-bnx2_phy_int(struct bnx2 *bp)
+static int
+bnx2_phy_event_is_set(struct bnx2 *bp, u32 event)
 {
+	struct status_block *sblk = bp->status_blk;
 	u32 new_link_state, old_link_state;
+	int is_set = 1;
 
-	new_link_state = bp->status_blk->status_attn_bits &
-		STATUS_ATTN_BITS_LINK_STATE;
-	old_link_state = bp->status_blk->status_attn_bits_ack &
-		STATUS_ATTN_BITS_LINK_STATE;
+	new_link_state = sblk->status_attn_bits & event;
+	old_link_state = sblk->status_attn_bits_ack & event;
 	if (new_link_state != old_link_state) {
-		if (new_link_state) {
-			REG_WR(bp, BNX2_PCICFG_STATUS_BIT_SET_CMD,
-				STATUS_ATTN_BITS_LINK_STATE);
-		}
-		else {
-			REG_WR(bp, BNX2_PCICFG_STATUS_BIT_CLEAR_CMD,
-				STATUS_ATTN_BITS_LINK_STATE);
-		}
+		if (new_link_state)
+			REG_WR(bp, BNX2_PCICFG_STATUS_BIT_SET_CMD, event);
+		else
+			REG_WR(bp, BNX2_PCICFG_STATUS_BIT_CLEAR_CMD, event);
+	} else
+		is_set = 0;
+
+	return is_set;
+}
+
+static void
+bnx2_phy_int(struct bnx2 *bp)
+{
+	if (bnx2_phy_event_is_set(bp, STATUS_ATTN_BITS_LINK_STATE)) {
+		spin_lock(&bp->phy_lock);
 		bnx2_set_link(bp);
+		spin_unlock(&bp->phy_lock);
 	}
+	if (bnx2_phy_event_is_set(bp, STATUS_ATTN_BITS_TIMER_ABORT))
+		bnx2_send_heart_beat(bp);
+
 }
 
 static void
@@ -2280,6 +2302,8 @@ bnx2_interrupt(int irq, void *dev_instance)
 	return IRQ_HANDLED;
 }
 
+#define STATUS_ATTN_EVENTS	(STATUS_ATTN_BITS_LINK_STATE | \
+				 STATUS_ATTN_BITS_TIMER_ABORT)
 static inline int
 bnx2_has_work(struct bnx2 *bp)
 {
@@ -2289,8 +2313,8 @@ bnx2_has_work(struct bnx2 *bp)
 	    (sblk->status_tx_quick_consumer_index0 != bp->hw_tx_cons))
 		return 1;
 
-	if ((sblk->status_attn_bits & STATUS_ATTN_BITS_LINK_STATE) !=
-	    (sblk->status_attn_bits_ack & STATUS_ATTN_BITS_LINK_STATE))
+	if ((sblk->status_attn_bits & STATUS_ATTN_EVENTS) !=
+	    (sblk->status_attn_bits_ack & STATUS_ATTN_EVENTS))
 		return 1;
 
 	return 0;
@@ -2300,15 +2324,14 @@ static int
 bnx2_poll(struct net_device *dev, int *budget)
 {
 	struct bnx2 *bp = netdev_priv(dev);
+	struct status_block *sblk = bp->status_blk;
+	u32 status_attn_bits = sblk->status_attn_bits;
+	u32 status_attn_bits_ack = sblk->status_attn_bits_ack;
 
-	if ((bp->status_blk->status_attn_bits &
-		STATUS_ATTN_BITS_LINK_STATE) !=
-		(bp->status_blk->status_attn_bits_ack &
-		STATUS_ATTN_BITS_LINK_STATE)) {
+	if ((status_attn_bits & STATUS_ATTN_EVENTS) !=
+	    (status_attn_bits_ack & STATUS_ATTN_EVENTS)) {
 
-		spin_lock(&bp->phy_lock);
 		bnx2_phy_int(bp);
-		spin_unlock(&bp->phy_lock);
 
 		/* This is needed to take care of transient status
 		 * during link changes.
@@ -3757,7 +3780,7 @@ bnx2_init_chip(struct bnx2 *bp)
 	/* Clear internal stats counters. */
 	REG_WR(bp, BNX2_HC_COMMAND, BNX2_HC_COMMAND_CLR_STAT_NOW);
 
-	REG_WR(bp, BNX2_HC_ATTN_BITS_ENABLE, STATUS_ATTN_BITS_LINK_STATE);
+	REG_WR(bp, BNX2_HC_ATTN_BITS_ENABLE, STATUS_ATTN_EVENTS);
 
 	if (REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_FEATURE) &
 	    BNX2_PORT_FEATURE_ASF_ENABLED)
@@ -3769,7 +3792,7 @@ bnx2_init_chip(struct bnx2 *bp)
 	rc = bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT2 | BNX2_DRV_MSG_CODE_RESET,
 			  0);
 
-	REG_WR(bp, BNX2_MISC_ENABLE_SET_BITS, 0x5ffffff);
+	REG_WR(bp, BNX2_MISC_ENABLE_SET_BITS, 0x7ffffff);
 	REG_RD(bp, BNX2_MISC_ENABLE_SET_BITS);
 
 	udelay(20);
@@ -4574,7 +4597,6 @@ static void
 bnx2_timer(unsigned long data)
 {
 	struct bnx2 *bp = (struct bnx2 *) data;
-	u32 msg;
 
 	if (!netif_running(bp->dev))
 		return;
@@ -4582,8 +4604,7 @@ bnx2_timer(unsigned long data)
 	if (atomic_read(&bp->intr_sem) != 0)
 		goto bnx2_restart_timer;
 
-	msg = (u32) ++bp->fw_drv_pulse_wr_seq;
-	REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_PULSE_MB, msg);
+	bnx2_send_heart_beat(bp);
 
 	bp->stats_blk->stat_FwRxDrop = REG_RD_IND(bp, BNX2_FW_RX_DROP_COUNT);
 


