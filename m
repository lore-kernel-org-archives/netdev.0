From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 6/7] igb: check for packets on all tx rings when
	link is down
Date: Thu, 12 Nov 2009 20:38:16 -0800
Message-ID: <20091113043815.1240.48974.stgit@localhost.localdomain>
References: <20091113043604.1240.80142.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:57324
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755563AbZKMEi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 23:38:28 -0500
In-Reply-To: <20091113043604.1240.80142.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We were previously only checking the first tx ring to see if it had any
packets in it when the link when down.  However we should be checking all
of the rings so this patch makes it so that all of the rings are now being
checked.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 4d4ab87..9911b3a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2943,7 +2943,6 @@ static void igb_watchdog_task(struct work_struct *work)
                                                    watchdog_task);
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
-	struct igb_ring *tx_ring = adapter->tx_ring;
 	u32 link;
 	int i;
 
@@ -3013,22 +3012,24 @@ static void igb_watchdog_task(struct work_struct *work)
 	igb_update_stats(adapter);
 	igb_update_adaptive(hw);
 
-	if (!netif_carrier_ok(netdev)) {
-		if (igb_desc_unused(tx_ring) + 1 < tx_ring->count) {
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		struct igb_ring *tx_ring = &adapter->tx_ring[i];
+		if (!netif_carrier_ok(netdev)) {
 			/* We've lost link, so the controller stops DMA,
 			 * but we've got queued Tx work that's never going
 			 * to get done, so reset controller to flush Tx.
 			 * (Do the reset outside of interrupt context). */
-			adapter->tx_timeout_count++;
-			schedule_work(&adapter->reset_task);
-			/* return immediately since reset is imminent */
-			return;
+			if (igb_desc_unused(tx_ring) + 1 < tx_ring->count) {
+				adapter->tx_timeout_count++;
+				schedule_work(&adapter->reset_task);
+				/* return immediately since reset is imminent */
+				return;
+			}
 		}
-	}
 
-	/* Force detection of hung controller every watchdog period */
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		adapter->tx_ring[i].detect_tx_hung = true;
+		/* Force detection of hung controller every watchdog period */
+		tx_ring->detect_tx_hung = true;
+	}
 
 	/* Cause software interrupt to ensure rx ring is cleaned */
 	if (adapter->msix_entries) {

