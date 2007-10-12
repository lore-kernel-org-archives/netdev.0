From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/6] sky2: status polling loop
Date: Thu, 11 Oct 2007 18:19:52 -0700
Message-ID: <20071012012124.965282742@linux-foundation.org>
References: <20071012011951.575936605@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34817 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753261AbXJLBWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 21:22:24 -0400
Content-Disposition: inline; filename=sky2-status-loop.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handle the corner case where budget is exhausted correctly.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-10-11 18:11:44.000000000 -0700
+++ b/drivers/net/sky2.c	2007-10-11 18:12:50.000000000 -0700
@@ -2245,15 +2245,13 @@ static inline void sky2_tx_done(struct n
 }
 
 /* Process status response ring */
-static int sky2_status_intr(struct sky2_hw *hw, int to_do)
+static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
 {
 	int work_done = 0;
 	unsigned rx[2] = { 0, 0 };
-	u16 hwidx = sky2_read16(hw, STAT_PUT_IDX);
 
 	rmb();
-
-	while (hw->st_idx != hwidx) {
+	do {
 		struct sky2_port *sky2;
 		struct sky2_status_le *le  = hw->st_le + hw->st_idx;
 		unsigned port = le->css & CSS_LINK_BIT;
@@ -2364,7 +2362,7 @@ static int sky2_status_intr(struct sky2_
 				printk(KERN_WARNING PFX
 				       "unknown status opcode 0x%x\n", le->opcode);
 		}
-	}
+	} while (hw->st_idx != idx);
 
 	/* Fully processed status ring so clear irq */
 	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
@@ -2606,7 +2604,8 @@ static int sky2_poll(struct napi_struct 
 {
 	struct sky2_hw *hw = container_of(napi, struct sky2_hw, napi);
 	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
-	int work_done;
+	int work_done = 0;
+	u16 idx;
 
 	if (unlikely(status & Y2_IS_ERROR))
 		sky2_err_intr(hw, status);
@@ -2617,21 +2616,24 @@ static int sky2_poll(struct napi_struct 
 	if (status & Y2_IS_IRQ_PHY2)
 		sky2_phy_intr(hw, 1);
 
-	work_done = sky2_status_intr(hw, work_limit);
+	while ((idx = sky2_read16(hw, STAT_PUT_IDX)) != hw->st_idx) {
+		work_done += sky2_status_intr(hw, work_limit - work_done, idx);
 
-	/* More work? */
-	if (hw->st_idx == sky2_read16(hw, STAT_PUT_IDX)) {
-		/* Bug/Errata workaround?
-		 * Need to kick the TX irq moderation timer.
-		 */
-		if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
-			sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
-			sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
-		}
+		if (work_done >= work_limit)
+			goto done;
+	}
 
-		napi_complete(napi);
-		sky2_read32(hw, B0_Y2_SP_LISR);
+	/* Bug/Errata workaround?
+	 * Need to kick the TX irq moderation timer.
+	 */
+	if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
+		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
+		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
 	}
+	napi_complete(napi);
+	sky2_read32(hw, B0_Y2_SP_LISR);
+done:
+
 	return work_done;
 }
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

