From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/1] drivers: net: cpsw: irq not disabled in cpsw isr in particular sequence
Date: Thu, 2 May 2013 17:22:11 +0530
Message-ID: <1367495531-19470-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sebastian Siewior <bigeasy@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:52135 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757903Ab3EBLwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 07:52:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In CPSW NAPI, after processing all interrupts IRQ is enabled and then book
keeping irq_enabled is updated. In random cases when a packet is transmitted
or received between processing packets and IRQ enabled, then just after
enabled IRQ and before irq_enabled is updated, ISR is called so IRQs are
not disabled as irq_enabled is still false and CPU gets locked in CPSW ISR.

By changing the sequence as update the irq_enabled and then enable IRQ
fixes the issue. This issue is not captured always as it is a timing issue
whether Tx or Rx IRQ is invoked between packet processing and enable IRQ.

Cc: Sebastian Siewior <bigeasy@linutronix.de>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 59c4391..21a5b29 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -555,8 +555,8 @@ static int cpsw_poll(struct napi_struct *napi, int budget)
 		cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
 		prim_cpsw = cpsw_get_slave_priv(priv, 0);
 		if (prim_cpsw->irq_enabled == false) {
-			cpsw_enable_irq(priv);
 			prim_cpsw->irq_enabled = true;
+			cpsw_enable_irq(priv);
 		}
 	}
 
-- 
1.7.9.5
