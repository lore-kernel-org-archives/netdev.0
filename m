From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/17] i40e/i40evf: fix Tx hang workaround code
Date: Wed, 30 Sep 2015 05:52:30 -0700
Message-ID: <1443617561-40490-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48753 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932207AbbI3Mwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:44 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The arm writeback (arm_wb) code is used for kicking the Tx ring to
make sure any pending work is completed even if interrupts are
disabled. It was running when it didn't need to, and not clearing
the ring->arm_wb state after it was set.  This caused Tx hangs
to still occur occasionally when there really was no hang.
Fix this by resetting the variable right after it was used.

Change-ID: I7bf75d552ba9c4bd203d40615213861a24bb5594
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 3ce4900..47dba9b0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1842,6 +1842,7 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	i40e_for_each_ring(ring, q_vector->tx) {
 		clean_complete &= i40e_clean_tx_irq(ring, vsi->work_limit);
 		arm_wb |= ring->arm_wb;
+		ring->arm_wb = false;
 	}
 
 	/* We attempt to distribute budget to each Rx queue fairly, but don't
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 8309793..aaee89f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -254,8 +254,6 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 	    !test_bit(__I40E_DOWN, &tx_ring->vsi->state) &&
 	    (I40E_DESC_UNUSED(tx_ring) != tx_ring->count))
 		tx_ring->arm_wb = true;
-	else
-		tx_ring->arm_wb = false;
 
 	netdev_tx_completed_queue(netdev_get_tx_queue(tx_ring->netdev,
 						      tx_ring->queue_index),
@@ -1288,6 +1286,7 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 	i40e_for_each_ring(ring, q_vector->tx) {
 		clean_complete &= i40e_clean_tx_irq(ring, vsi->work_limit);
 		arm_wb |= ring->arm_wb;
+		ring->arm_wb = false;
 	}
 
 	/* We attempt to distribute budget to each Rx queue fairly, but don't
-- 
2.4.3
