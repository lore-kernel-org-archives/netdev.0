From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/20] fm10k: avoid possible null pointer dereference in fm10k_update_stats
Date: Wed, 20 Jul 2016 15:23:40 -0700
Message-ID: <1469053438-85381-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21457 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755239AbcGTWYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:00 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

It's currently possible for fm10k_update_stats to be called during the
window when we go down and the rings are removed. This can result in
a null pointer dereference. In fm10k_get_stats64 we work around this by
using ACCESS_ONCE and a null pointer check inside the loop. Use this
same flow in the fm10k_update_stats to avoid the potential null pointer.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 610c313..be0b7de 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -377,7 +377,10 @@ void fm10k_update_stats(struct fm10k_intfc *interface)
 
 	/* gather some stats to the interface struct that are per queue */
 	for (bytes = 0, pkts = 0, i = 0; i < interface->num_tx_queues; i++) {
-		struct fm10k_ring *tx_ring = interface->tx_ring[i];
+		struct fm10k_ring *tx_ring = READ_ONCE(interface->tx_ring[i]);
+
+		if (!tx_ring)
+			continue;
 
 		restart_queue += tx_ring->tx_stats.restart_queue;
 		tx_busy += tx_ring->tx_stats.tx_busy;
@@ -396,7 +399,10 @@ void fm10k_update_stats(struct fm10k_intfc *interface)
 
 	/* gather some stats to the interface struct that are per queue */
 	for (bytes = 0, pkts = 0, i = 0; i < interface->num_rx_queues; i++) {
-		struct fm10k_ring *rx_ring = interface->rx_ring[i];
+		struct fm10k_ring *rx_ring = READ_ONCE(interface->rx_ring[i]);
+
+		if (!rx_ring)
+			continue;
 
 		bytes += rx_ring->stats.bytes;
 		pkts += rx_ring->stats.packets;
-- 
2.5.5
