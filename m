From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/4] sky2: check for more work before leaving NAPI
Date: Thu, 16 Aug 2007 09:12:47 -0400
Message-ID: <20070816131348.583665704@linux-foundation.org>
References: <20070816131244.726293914@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34523 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757078AbXHPNOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 09:14:43 -0400
Content-Disposition: inline; filename=sky2-napi-fill.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Backport of commit 5c11ce700f77fada15b6264417d72462da4bbb1c
    
This patch avoids generating another IRQ if more packets
arrive while in the NAPI poll routine. Before marking device as
finished, it rechecks that the status ring is empty.
    
Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-08-08 22:01:11.000000000 +0100
+++ b/drivers/net/sky2.c	2007-08-08 22:01:28.000000000 +0100
@@ -2428,8 +2428,7 @@ static void sky2_err_intr(struct sky2_hw
 static int sky2_poll(struct net_device *dev0, int *budget)
 {
 	struct sky2_hw *hw = ((struct sky2_port *) netdev_priv(dev0))->hw;
-	int work_limit = min(dev0->quota, *budget);
-	int work_done = 0;
+	int work_done;
 	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
 
 	if (unlikely(status & Y2_IS_ERROR))
@@ -2441,25 +2440,25 @@ static int sky2_poll(struct net_device *
 	if (status & Y2_IS_IRQ_PHY2)
 		sky2_phy_intr(hw, 1);
 
-	work_done = sky2_status_intr(hw, work_limit);
-	if (work_done < work_limit) {
-		/* Bug/Errata workaround?
-		 * Need to kick the TX irq moderation timer.
-		 */
-		if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
-			sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
-			sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
-		}
-		netif_rx_complete(dev0);
+	work_done = sky2_status_intr(hw, min(dev0->quota, *budget));
+	*budget -= work_done;
+	dev0->quota -= work_done;
 
-		/* end of interrupt, re-enables also acts as I/O synchronization */
-		sky2_read32(hw, B0_Y2_SP_LISR);
-		return 0;
-	} else {
-		*budget -= work_done;
-		dev0->quota -= work_done;
+	/* More work? */
+ 	if (hw->st_idx != sky2_read16(hw, STAT_PUT_IDX))
 		return 1;
+
+	/* Bug/Errata workaround?
+	 * Need to kick the TX irq moderation timer.
+	 */
+	if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
+		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
+		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
 	}
+	netif_rx_complete(dev0);
+
+	sky2_read32(hw, B0_Y2_SP_LISR);
+	return 0;
 }
 
 static irqreturn_t sky2_intr(int irq, void *dev_id)

-- 

