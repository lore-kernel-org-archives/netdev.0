From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] b44: netpoll locking fix
Date: Tue, 29 May 2007 23:14:58 +0200
Message-ID: <20070529211458.GA31200@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39481 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbXE2VQF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 17:16:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The irq handling thread (b44_interrupt) uses the same lock as the NAPI
thread. This change should prevent a deadlock if something interrupts
the b44 NAPI thread and tries to printk through netconsole.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/b44.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 879a2ff..64d75e4 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -853,16 +853,18 @@ static int b44_rx(struct b44 *bp, int budget)
 static int b44_poll(struct net_device *netdev, int *budget)
 {
 	struct b44 *bp = netdev_priv(netdev);
+	unsigned long flags;
 	int done;
 
-	spin_lock_irq(&bp->lock);
+	spin_lock_irqsave(&bp->lock, flags);
 
 	if (bp->istat & (ISTAT_TX | ISTAT_TO)) {
 		/* spin_lock(&bp->tx_lock); */
 		b44_tx(bp);
 		/* spin_unlock(&bp->tx_lock); */
 	}
-	spin_unlock_irq(&bp->lock);
+
+	spin_unlock_irqrestore(&bp->lock, flags);
 
 	done = 1;
 	if (bp->istat & ISTAT_RX) {
@@ -882,8 +884,6 @@ static int b44_poll(struct net_device *netdev, int *budget)
 	}
 
 	if (bp->istat & ISTAT_ERRORS) {
-		unsigned long flags;
-
 		spin_lock_irqsave(&bp->lock, flags);
 		b44_halt(bp);
 		b44_init_rings(bp);
-- 
1.5.2

