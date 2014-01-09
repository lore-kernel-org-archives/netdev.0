From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: add a comment on barrier and fix panic on reset
Date: Thu,  9 Jan 2014 04:52:14 -0800
Message-ID: <1389271944-26227-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44616 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754973AbaAIMwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:52:30 -0500
In-Reply-To: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The memory barrier used in maybe_stop_tx can use a comment.

Also add checks to VSI->rx_rings to ensure a kernel panic is not induced.

Change-ID: I48cc1bf1d6cf301818155b737edeef77c0d790c7
Change-ID: I1363a8445fbf521a26267849966296ed55f43ad8
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 15 +++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c |  1 +
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ea76134..5cdc67c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -422,7 +422,7 @@ void i40e_vsi_reset_stats(struct i40e_vsi *vsi)
 	memset(&vsi->net_stats_offsets, 0, sizeof(vsi->net_stats_offsets));
 	memset(&vsi->eth_stats, 0, sizeof(vsi->eth_stats));
 	memset(&vsi->eth_stats_offsets, 0, sizeof(vsi->eth_stats_offsets));
-	if (vsi->rx_rings)
+	if (vsi->rx_rings && vsi->rx_rings[0]) {
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
 			memset(&vsi->rx_rings[i]->stats, 0 ,
 			       sizeof(vsi->rx_rings[i]->stats));
@@ -433,6 +433,7 @@ void i40e_vsi_reset_stats(struct i40e_vsi *vsi)
 			memset(&vsi->tx_rings[i]->tx_stats, 0,
 			       sizeof(vsi->tx_rings[i]->tx_stats));
 		}
+	}
 	vsi->stat_offsets_loaded = false;
 }
 
@@ -2067,8 +2068,11 @@ static void i40e_vsi_free_tx_resources(struct i40e_vsi *vsi)
 {
 	int i;
 
+	if (!vsi->tx_rings)
+		return;
+
 	for (i = 0; i < vsi->num_queue_pairs; i++)
-		if (vsi->tx_rings[i]->desc)
+		if (vsi->tx_rings[i] && vsi->tx_rings[i]->desc)
 			i40e_free_tx_resources(vsi->tx_rings[i]);
 }
 
@@ -2101,8 +2105,11 @@ static void i40e_vsi_free_rx_resources(struct i40e_vsi *vsi)
 {
 	int i;
 
+	if (!vsi->rx_rings)
+		return;
+
 	for (i = 0; i < vsi->num_queue_pairs; i++)
-		if (vsi->rx_rings[i]->desc)
+		if (vsi->rx_rings[i] && vsi->rx_rings[i]->desc)
 			i40e_free_rx_resources(vsi->rx_rings[i]);
 }
 
@@ -5349,7 +5356,7 @@ static void i40e_vsi_clear_rings(struct i40e_vsi *vsi)
 {
 	int i;
 
-	if (vsi->tx_rings[0]) {
+	if (vsi->tx_rings && vsi->tx_rings[0]) {
 		for (i = 0; i < vsi->alloc_queue_pairs; i++) {
 			kfree_rcu(vsi->tx_rings[i], rcu);
 			vsi->tx_rings[i] = NULL;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index e81e5bf..bc72f4e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1715,6 +1715,7 @@ dma_error:
 static inline int __i40e_maybe_stop_tx(struct i40e_ring *tx_ring, int size)
 {
 	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
+	/* Memory barrier before checking head and tail */
 	smp_mb();
 
 	/* Check again in a case another CPU has just made room available. */
-- 
1.8.3.1
