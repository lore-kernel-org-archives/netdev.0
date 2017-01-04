From: John Crispin <john@phrozen.org>
Subject: [PATCH] net-next: korina: Fix NAPI versus resources freeing
Date: Wed,  4 Jan 2017 10:31:18 +0100
Message-ID: <1483522278-36891-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, John Crispin <john@phrozen.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:33607 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967228AbdADJcl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 04:32:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>

Commit beb0babfb77e ("korina: disable napi on close and restart")
introduced calls to napi_disable() that were missing before,
unfortunately this leaves a small window during which NAPI has a chance
to run, yet we just freed resources since korina_free_ring() has been
called:

Fix this by disabling NAPI first then freeing resource, and make sure
that we also cancel the restart taks before doing the resource freeing.

Fixes: beb0babfb77e ("korina: disable napi on close and restart")

Reported-by: Alexandros C. Couloumbis <alex@ozo.com>
Tested-by: John Crispin <john@phrozen.org>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/korina.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 1799fe1..c051987 100644
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
1.7.10.4
