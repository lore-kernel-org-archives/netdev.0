From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v2 13/16][BNX2]: Restructure PHY event handling.
Date: Thu, 03 May 2007 00:31:06 -0700
Message-ID: <1178177466.4909.76.camel@dell>
References: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2344 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161790AbXECGn6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 02:43:58 -0400
In-Reply-To: <1178068303.4820.35.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Restructure PHY event handling.

Restructure by adding bnx2_phy_event_is_set() to make code cleaner
and easier to understand.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index cb74f12..f072028 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1942,25 +1942,33 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, u16 index)
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
 }
 
@@ -2283,6 +2291,8 @@ bnx2_interrupt(int irq, void *dev_instance)
 	return IRQ_HANDLED;
 }
 
+#define STATUS_ATTN_EVENTS	STATUS_ATTN_BITS_LINK_STATE
+
 static inline int
 bnx2_has_work(struct bnx2 *bp)
 {
@@ -2292,8 +2302,8 @@ bnx2_has_work(struct bnx2 *bp)
 	    (sblk->status_tx_quick_consumer_index0 != bp->hw_tx_cons))
 		return 1;
 
-	if ((sblk->status_attn_bits & STATUS_ATTN_BITS_LINK_STATE) !=
-	    (sblk->status_attn_bits_ack & STATUS_ATTN_BITS_LINK_STATE))
+	if ((sblk->status_attn_bits & STATUS_ATTN_EVENTS) !=
+	    (sblk->status_attn_bits_ack & STATUS_ATTN_EVENTS))
 		return 1;
 
 	return 0;
@@ -2303,15 +2313,14 @@ static int
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
@@ -3760,7 +3769,7 @@ bnx2_init_chip(struct bnx2 *bp)
 	/* Clear internal stats counters. */
 	REG_WR(bp, BNX2_HC_COMMAND, BNX2_HC_COMMAND_CLR_STAT_NOW);
 
-	REG_WR(bp, BNX2_HC_ATTN_BITS_ENABLE, STATUS_ATTN_BITS_LINK_STATE);
+	REG_WR(bp, BNX2_HC_ATTN_BITS_ENABLE, STATUS_ATTN_EVENTS);
 
 	if (REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_FEATURE) &
 	    BNX2_PORT_FEATURE_ASF_ENABLED)


