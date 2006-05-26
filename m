From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 5/9] ixgb: remove lock access in the fast path
Date: Fri, 26 May 2006 09:52:05 -0700
Message-ID: <20060526165204.30514.19446.stgit@gitlost.site>
References: <20060526165124.30514.78477.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        "Kok, Auke" <auke-jan.h.kok@intel.com>,
        "Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:32774 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751134AbWEZQrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 12:47:00 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060526165124.30514.78477.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This mimics a change made in the e1000 driver that imitates a slick
tg3 way of avoiding grabbing the lock around restarting the tx queue.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index b825850..a714c4d 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1800,13 +1800,13 @@ ixgb_clean_tx_irq(struct ixgb_adapter *a
 
 	tx_ring->next_to_clean = i;
 
-	spin_lock(&adapter->tx_lock);
-	if(cleaned && netif_queue_stopped(netdev) && netif_carrier_ok(netdev) &&
-	   (IXGB_DESC_UNUSED(tx_ring) > IXGB_TX_QUEUE_WAKE)) {
-
-		netif_wake_queue(netdev);
+	if (unlikely(netif_queue_stopped(netdev))) {
+		spin_lock(&adapter->tx_lock);
+		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev) &&
+		    (IXGB_DESC_UNUSED(tx_ring) > IXGB_TX_QUEUE_WAKE))
+			netif_wake_queue(netdev);
+		spin_unlock(&adapter->tx_lock);
 	}
-	spin_unlock(&adapter->tx_lock);
 
 	if(adapter->detect_tx_hung) {
 		/* detect a transmit hang in hardware, this serializes the



--
Auke Kok <auke-jan.h.kok@intel.com>
