From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: korina: Fix NAPI versus resources freeing
Date: Fri, 23 Dec 2016 19:56:56 -0800
Message-ID: <20161224035656.11289-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, alex@ozo.com, phil@nwl.cc,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33820 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751671AbcLXD5A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 22:57:00 -0500
Received: by mail-oi0-f66.google.com with SMTP id 3so10275493oih.1
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2016 19:57:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit beb0babfb77e ("korina: disable napi on close and restart")
introduced calls to napi_disable() that were missing before,
unfortunately this leaves a small window during which NAPI has a chance
to run, yet we just freed resources since korina_free_ring() has been
called:

Fix this by disabling NAPI first then freeing resource, and make sure
that we also cancel the restart taks before doing the resource freeing.

Fixes: beb0babfb77e ("korina: disable napi on close and restart")
Reported-by: Alexandros C. Couloumbis <alex@ozo.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/korina.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index cbeea915f026..8037426ec50f 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -900,10 +900,10 @@ static void korina_restart_task(struct work_struct *work)
 				DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR,
 				&lp->rx_dma_regs->dmasm);
 
-	korina_free_ring(dev);
-
 	napi_disable(&lp->napi);
 
+	korina_free_ring(dev);
+
 	if (korina_init(dev) < 0) {
 		printk(KERN_ERR "%s: cannot restart device\n", dev->name);
 		return;
@@ -1064,12 +1064,12 @@ static int korina_close(struct net_device *dev)
 	tmp = tmp | DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR;
 	writel(tmp, &lp->rx_dma_regs->dmasm);
 
-	korina_free_ring(dev);
-
 	napi_disable(&lp->napi);
 
 	cancel_work_sync(&lp->restart_task);
 
+	korina_free_ring(dev);
+
 	free_irq(lp->rx_irq, dev);
 	free_irq(lp->tx_irq, dev);
 	free_irq(lp->ovr_irq, dev);
-- 
2.9.3
