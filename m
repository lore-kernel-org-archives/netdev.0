From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/4] bnx2: Remove some unnecessary smp_mb() in
 tx fast path.
Date: Mon, 19 Jul 2010 17:15:04 -0700
Message-ID: <1279584905-15084-3-git-send-email-mchan@broadcom.com>
References: <1279584905-15084-1-git-send-email-mchan@broadcom.com>
 <1279584905-15084-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2074 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760883Ab0GTALw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jul 2010 20:11:52 -0400
In-Reply-To: <1279584905-15084-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smp_mb() inside bnx2_tx_avail() is used twice in the normal
bnx2_start_xmit() path (see illustration below).  The full memory
barrier is only necessary during race conditions with tx completion.
We can speed up the tx path by replacing smp_mb() in bnx2_tx_avail()
with a compiler barrier.  The compiler barrier is to force the
compiler to fetch the tx_prod and tx_cons from memory.

In the race condition between bnx2_start_xmit() and bnx2_tx_int(),
we have the following situation:

bnx2_start_xmit()                       bnx2_tx_int()
    if (!bnx2_tx_avail())
            BUG();

    ...

    if (!bnx2_tx_avail())
            netif_tx_stop_queue();          update_tx_index();
            smp_mb();                       smp_mb();
            if (bnx2_tx_avail())            if (netif_tx_queue_stopped() &&
                    netif_tx_wake_queue();      bnx2_tx_avail())

With smp_mb() removed from bnx2_tx_avail(), we need to add smp_mb() to
bnx2_start_xmit() as shown above to properly order netif_tx_stop_queue()
and bnx2_tx_avail() to check the ring index.  If it is not strictly
ordered, the tx queue can be stopped forever.

This improves performance by about 5% with 2 ports running bi-directional
64-byte packets.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d44ecc3..2af570d 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -253,7 +253,8 @@ static inline u32 bnx2_tx_avail(struct bnx2 *bp, struct bnx2_tx_ring_info *txr)
 {
 	u32 diff;
 
-	smp_mb();
+	/* Tell compiler to fetch tx_prod and tx_cons from memory. */
+	barrier();
 
 	/* The ring uses 256 indices for 255 entries, one of them
 	 * needs to be skipped.
@@ -6534,6 +6535,13 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (unlikely(bnx2_tx_avail(bp, txr) <= MAX_SKB_FRAGS)) {
 		netif_tx_stop_queue(txq);
+
+		/* netif_tx_stop_queue() must be done before checking
+		 * tx index in bnx2_tx_avail() below, because in
+		 * bnx2_tx_int(), we update tx index before checking for
+		 * netif_tx_queue_stopped().
+		 */
+		smp_mb();
 		if (bnx2_tx_avail(bp, txr) > bp->tx_wake_thresh)
 			netif_tx_wake_queue(txq);
 	}
-- 
1.6.4.GIT


