From: Zumeng Chen <zumeng.chen@windriver.com>
Subject: [PATCH v2 1/1] net: macb: ensure ordering write to re-enable RX smoothly
Date: Mon, 28 Nov 2016 21:55:00 +0800
Message-ID: <1480341300-17384-1-git-send-email-zumeng.chen@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:56165 "EHLO
        mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932666AbcK1NzH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 08:55:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a hardware issue happened as described by inline comments, the register
write pattern looks like the following:

<write ~MACB_BIT(RE)>
+ wmb();
<write MACB_BIT(RE)>

There might be a memory barrier between these two write operations, so add wmb
to ensure an flip from 0 to 1 for NCR.

Signed-off-by: Zumeng Chen <zumeng.chen@windriver.com>
---

V2 changes:

Add the same wmb for at91ether as well based on reviewer's suggestion.

Cheers,
 drivers/net/ethernet/cadence/macb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 533653b..6d7cfa7 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1156,6 +1156,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		if (status & MACB_BIT(RXUBR)) {
 			ctrl = macb_readl(bp, NCR);
 			macb_writel(bp, NCR, ctrl & ~MACB_BIT(RE));
+			wmb();
 			macb_writel(bp, NCR, ctrl | MACB_BIT(RE));
 
 			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
@@ -2770,6 +2771,7 @@ static irqreturn_t at91ether_interrupt(int irq, void *dev_id)
 	if (intstatus & MACB_BIT(RXUBR)) {
 		ctl = macb_readl(lp, NCR);
 		macb_writel(lp, NCR, ctl & ~MACB_BIT(RE));
+		wmb();
 		macb_writel(lp, NCR, ctl | MACB_BIT(RE));
 	}
 
-- 
2.4.11
