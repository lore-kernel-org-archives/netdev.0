From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next] bnx2: Use netif_carrier_off() to prevent timeout.
Date: Thu, 13 May 2010 07:48:35 -0700
Message-ID: <1273762115-13412-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3547 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758777Ab0EMPoR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 11:44:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on original patch from Stanislaw Gruszka <sgruszka@redhat.com>.

Using netif_carrier_off() is better than updating all the ->trans_start
on all the tx queues.

netif_carrier_off() needs to be called after bnx2_disable_int_sync()
to guarantee no race conditions with the serdes timers that can
modify the carrier state.

If the chip or phy is reset, carrier will turn back on when we get the
link interrupt.  If there is no reset, we need to turn carrier back on
in bnx2_netif_start().  Again, the phy_lock prevents race conditions with
the serdes timers.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/bnx2.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ab0068c..188e356 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -656,19 +656,11 @@ bnx2_netif_stop(struct bnx2 *bp, bool stop_cnic)
 	if (stop_cnic)
 		bnx2_cnic_stop(bp);
 	if (netif_running(bp->dev)) {
-		int i;
-
 		bnx2_napi_disable(bp);
 		netif_tx_disable(bp->dev);
-		/* prevent tx timeout */
-		for (i = 0; i <  bp->dev->num_tx_queues; i++) {
-			struct netdev_queue *txq;
-
-			txq = netdev_get_tx_queue(bp->dev, i);
-			txq->trans_start = jiffies;
-		}
 	}
 	bnx2_disable_int_sync(bp);
+	netif_carrier_off(bp->dev);	/* prevent tx timeout */
 }
 
 static void
@@ -677,6 +669,10 @@ bnx2_netif_start(struct bnx2 *bp, bool start_cnic)
 	if (atomic_dec_and_test(&bp->intr_sem)) {
 		if (netif_running(bp->dev)) {
 			netif_tx_wake_all_queues(bp->dev);
+			spin_lock_bh(&bp->phy_lock);
+			if (bp->link_up)
+				netif_carrier_on(bp->dev);
+			spin_unlock_bh(&bp->phy_lock);
 			bnx2_napi_enable(bp);
 			bnx2_enable_int(bp);
 			if (start_cnic)
-- 
1.6.4.GIT


