From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 1/2] net: ethernet: sxgbe: do not use xmit_lock in tx completion handler
Date: Sat,  3 Dec 2016 00:06:05 +0100
Message-ID: <1480719966-12839-2-git-send-email-LinoSanfilippo@gmx.de>
References: <1480719966-12839-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:59430 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756435AbcLBXGc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 18:06:32 -0500
In-Reply-To: <1480719966-12839-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver already uses its private lock for synchronization between the
xmit function and the xmit completion handler, making the additional use of
the xmit_lock unnecessary.
Furthermore the driver does not set NETIF_F_LLTX resulting in xmit to be
called with the xmit_lock held and then taking the private lock.
On the other hand the xmit completion handler uses the reverse locking
order, by first taking the private lock, and then the xmit_lock, which
leads to the potential danger of a deadlock.

Fix this issue by not taking the xmit_lock in the completion handler.
By doing this also remove an unnecessary double check for a stopped tx
queue.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

Please note that this patch is only compile tested.

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 5dbe406..578cbec 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -782,14 +782,9 @@ static void sxgbe_tx_queue_clean(struct sxgbe_tx_queue *tqueue)
 	/* wake up queue */
 	if (unlikely(netif_tx_queue_stopped(dev_txq) &&
 		     sxgbe_tx_avail(tqueue, tx_rsize) > SXGBE_TX_THRESH(priv))) {
-		netif_tx_lock(priv->dev);
-		if (netif_tx_queue_stopped(dev_txq) &&
-		    sxgbe_tx_avail(tqueue, tx_rsize) > SXGBE_TX_THRESH(priv)) {
-			if (netif_msg_tx_done(priv))
-				pr_debug("%s: restart transmit\n", __func__);
-			netif_tx_wake_queue(dev_txq);
-		}
-		netif_tx_unlock(priv->dev);
+		if (netif_msg_tx_done(priv))
+			pr_debug("%s: restart transmit\n", __func__);
+		netif_tx_wake_queue(dev_txq);
 	}
 
 	spin_unlock(&tqueue->tx_lock);
-- 
1.9.1
