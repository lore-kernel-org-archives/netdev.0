From: Zumeng Chen <zumeng.chen@windriver.com>
Subject: [PATCH 1/1] net: macb: ensure ordering write to re-enable RX smoothly
Date: Mon, 28 Nov 2016 15:57:30 +0800
Message-ID: <1480319850-15296-1-git-send-email-zumeng.chen@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a hardware issue happened as described by inline comments, the register
write pattern looks like the following:

  <write ~MACB_BIT(RE)>
  + wmb();
  <write MACB_BIT(RE)>

There might be a memory barrier between these two write operations, so add wmb
to ensure an flip from 0 to 1 for NCR.

Signed-off-by: Zumeng Chen <zumeng.chen@windriver.com>
---
 drivers/net/ethernet/cadence/macb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 533653b..2f9c5b2 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1156,6 +1156,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		if (status & MACB_BIT(RXUBR)) {
 			ctrl = macb_readl(bp, NCR);
 			macb_writel(bp, NCR, ctrl & ~MACB_BIT(RE));
+			wmb();
 			macb_writel(bp, NCR, ctrl | MACB_BIT(RE));
 
 			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
-- 
2.4.11
