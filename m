From: David Miller <davem@davemloft.net>
Subject: Re: Regression in net-2.6.24?
Date: Thu, 11 Oct 2007 17:17:43 -0700 (PDT)
Message-ID: <20071011.171743.118962219.davem@davemloft.net>
References: <20071011.225146.94718703.takano@axe-inc.co.jp>
	<20071011.164827.64988925.davem@davemloft.net>
	<20071011165548.6545b207@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: takano@axe-inc.co.jp, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, mchan@broadcom.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44888
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751571AbXJLARl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 20:17:41 -0400
In-Reply-To: <20071011165548.6545b207@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 11 Oct 2007 16:55:48 -0700

> On Thu, 11 Oct 2007 16:48:27 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > Alternatively we could loop in tg3_poll() until either budget
> > is exhausted or tg3_has_work() returns false.  Actually, this sounds
> > like a cleaner scheme the more I think about it.
> > 
> > BNX2 likely has a similar issue.
> 
> sky2 as well.

Thanks for the heads up Stephen.

Here is a patch that implements the looping idea in tg3, bnx2, and
sky2.

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index bbfbdaf..b015d52 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2633,15 +2633,11 @@ bnx2_has_work(struct bnx2 *bp)
 	return 0;
 }
 
-static int
-bnx2_poll(struct napi_struct *napi, int budget)
+static int bnx2_poll_work(struct bnx2 *bp, int work_done, int budget)
 {
-	struct bnx2 *bp = container_of(napi, struct bnx2, napi);
-	struct net_device *dev = bp->dev;
 	struct status_block *sblk = bp->status_blk;
 	u32 status_attn_bits = sblk->status_attn_bits;
 	u32 status_attn_bits_ack = sblk->status_attn_bits_ack;
-	int work_done = 0;
 
 	if ((status_attn_bits & STATUS_ATTN_EVENTS) !=
 	    (status_attn_bits_ack & STATUS_ATTN_EVENTS)) {
@@ -2660,27 +2656,43 @@ bnx2_poll(struct napi_struct *napi, int budget)
 		bnx2_tx_int(bp);
 
 	if (bp->status_blk->status_rx_quick_consumer_index0 != bp->hw_rx_cons)
-		work_done = bnx2_rx_int(bp, budget);
+		work_done += bnx2_rx_int(bp, budget - work_done);
 
-	bp->last_status_idx = bp->status_blk->status_idx;
-	rmb();
+	return work_done;
+}
+
+static int bnx2_poll(struct napi_struct *napi, int budget)
+{
+	struct bnx2 *bp = container_of(napi, struct bnx2, napi);
+	int work_done = 0;
+
+	while (1) {
+		work_done += bnx2_poll_work(bp, work_done, budget);
 
-	if (!bnx2_has_work(bp)) {
-		netif_rx_complete(dev, napi);
-		if (likely(bp->flags & USING_MSI_FLAG)) {
+		if (unlikely(work_done >= budget))
+			break;
+
+		if (likely(!bnx2_has_work(bp))) {
+			bp->last_status_idx = bp->status_blk->status_idx;
+			rmb();
+
+			netif_rx_complete(bp->dev, napi);
+			if (likely(bp->flags & USING_MSI_FLAG)) {
+				REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
+				       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
+				       bp->last_status_idx);
+				return 0;
+			}
 			REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 			       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
+			       BNX2_PCICFG_INT_ACK_CMD_MASK_INT |
 			       bp->last_status_idx);
-			return 0;
-		}
-		REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
-		       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
-		       BNX2_PCICFG_INT_ACK_CMD_MASK_INT |
-		       bp->last_status_idx);
 
-		REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
-		       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
-		       bp->last_status_idx);
+			REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
+			       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
+			       bp->last_status_idx);
+			break;
+		}
 	}
 
 	return work_done;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index fe0e756..25da238 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2605,33 +2605,41 @@ static void sky2_err_intr(struct sky2_hw *hw, u32 status)
 static int sky2_poll(struct napi_struct *napi, int work_limit)
 {
 	struct sky2_hw *hw = container_of(napi, struct sky2_hw, napi);
-	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
-	int work_done;
+	int work_done = 0;
 
-	if (unlikely(status & Y2_IS_ERROR))
-		sky2_err_intr(hw, status);
+	while (1) {
+		u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
 
-	if (status & Y2_IS_IRQ_PHY1)
-		sky2_phy_intr(hw, 0);
+		if (unlikely(status & Y2_IS_ERROR))
+			sky2_err_intr(hw, status);
 
-	if (status & Y2_IS_IRQ_PHY2)
-		sky2_phy_intr(hw, 1);
+		if (status & Y2_IS_IRQ_PHY1)
+			sky2_phy_intr(hw, 0);
 
-	work_done = sky2_status_intr(hw, work_limit);
+		if (status & Y2_IS_IRQ_PHY2)
+			sky2_phy_intr(hw, 1);
 
-	/* More work? */
-	if (hw->st_idx == sky2_read16(hw, STAT_PUT_IDX)) {
-		/* Bug/Errata workaround?
-		 * Need to kick the TX irq moderation timer.
-		 */
-		if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
-			sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
-			sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
-		}
+		work_done += sky2_status_intr(hw, work_limit - work_done);
 
-		napi_complete(napi);
-		sky2_read32(hw, B0_Y2_SP_LISR);
+		if (unlikely(work_done >= work_limit))
+			break;
+
+		/* More work? */
+		if (likely(hw->st_idx == sky2_read16(hw, STAT_PUT_IDX))) {
+			/* Bug/Errata workaround?
+			 * Need to kick the TX irq moderation timer.
+			 */
+			if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
+				sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
+				sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
+			}
+
+			napi_complete(napi);
+			sky2_read32(hw, B0_Y2_SP_LISR);
+			break;
+		}
 	}
+
 	return work_done;
 }
 
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d2b30fb..ae08dda 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3555,12 +3555,9 @@ next_pkt_nopost:
 	return received;
 }
 
-static int tg3_poll(struct napi_struct *napi, int budget)
+static int tg3_poll_work(struct tg3 *tp, int work_done, int budget)
 {
-	struct tg3 *tp = container_of(napi, struct tg3, napi);
-	struct net_device *netdev = tp->dev;
 	struct tg3_hw_status *sblk = tp->hw_status;
-	int work_done = 0;
 
 	/* handle link change and other phy events */
 	if (!(tp->tg3_flags &
@@ -3578,11 +3575,8 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 	/* run TX completion thread */
 	if (sblk->idx[0].tx_consumer != tp->tx_cons) {
 		tg3_tx(tp);
-		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING)) {
-			netif_rx_complete(netdev, napi);
-			schedule_work(&tp->reset_task);
+		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING))
 			return 0;
-		}
 	}
 
 	/* run RX thread, within the bounds set by NAPI.
@@ -3590,21 +3584,46 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 	 * code synchronizes with tg3->napi.poll()
 	 */
 	if (sblk->idx[0].rx_producer != tp->rx_rcb_ptr)
-		work_done = tg3_rx(tp, budget);
+		work_done += tg3_rx(tp, budget - work_done);
 
-	if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
-		tp->last_tag = sblk->status_tag;
-		rmb();
-	} else
-		sblk->status &= ~SD_STATUS_UPDATED;
+	return work_done;
+}
 
-	/* if no more work, tell net stack and NIC we're done */
-	if (!tg3_has_work(tp)) {
-		netif_rx_complete(netdev, napi);
-		tg3_restart_ints(tp);
+static int tg3_poll(struct napi_struct *napi, int budget)
+{
+	struct tg3 *tp = container_of(napi, struct tg3, napi);
+	int work_done = 0;
+
+	while (1) {
+		work_done += tg3_poll_work(tp, work_done, budget);
+
+		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING))
+			goto tx_recovery;
+
+		if (unlikely(work_done >= budget))
+			break;
+
+		if (likely(!tg3_has_work(tp))) {
+			struct tg3_hw_status *sblk = tp->hw_status;
+
+			if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
+				tp->last_tag = sblk->status_tag;
+				rmb();
+			} else
+				sblk->status &= ~SD_STATUS_UPDATED;
+
+			netif_rx_complete(tp->dev, napi);
+			tg3_restart_ints(tp);
+			break;
+		}
 	}
 
 	return work_done;
+
+tx_recovery:
+	netif_rx_complete(tp->dev, napi);
+	schedule_work(&tp->reset_task);
+	return 0;
 }
 
 static void tg3_irq_quiesce(struct tg3 *tp)
