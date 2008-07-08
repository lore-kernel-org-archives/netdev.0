From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 01/25] ixgb: maybe stop tx port missed a piece
Date: Tue, 08 Jul 2008 15:51:07 -0700
Message-ID: <20080708225107.6925.57805.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8067 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752984AbYGHWvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:51:08 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

back when maybe stop tx was added to the ixgb driver some mistakes
were made and the driver
a) didn't remove the tx lock, which is now un-necessary
b) didn't change the restart code to be compliant with maybe_stop

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 41f3adf..04cac41 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1855,12 +1855,17 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 
 	tx_ring->next_to_clean = i;
 
-	if (unlikely(netif_queue_stopped(netdev))) {
-		spin_lock(&adapter->tx_lock);
-		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev) &&
-		    (IXGB_DESC_UNUSED(tx_ring) >= DESC_NEEDED))
+	if (unlikely(cleaned && netif_carrier_ok(netdev) &&
+		     IXGB_DESC_UNUSED(tx_ring) >= DESC_NEEDED)) {
+		/* Make sure that anybody stopping the queue after this
+		 * sees the new next_to_clean. */
+		smp_mb();
+
+		if (netif_queue_stopped(netdev) &&
+		    !(test_bit(__IXGB_DOWN, &adapter->flags))) {
 			netif_wake_queue(netdev);
-		spin_unlock(&adapter->tx_lock);
+			++adapter->restart_queue;
+		}
 	}
 
 	if(adapter->detect_tx_hung) {

