From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/6] ixgbe: fix default setting of TXDCTL.WTHRESH
Date: Thu,  1 Nov 2012 03:44:23 -0700
Message-ID: <1351766667-28489-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351766667-28489-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51802 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756249Ab2KAKob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 06:44:31 -0400
In-Reply-To: <1351766667-28489-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

The q_vector->itr check in ixgbe_configure_tx_ring() was done prior to it
being set, which resulted in TXDCTL.WTHRESH always being set to 1 on driver
load, while consequent resets would set it to 8.

This patch moves the setting of q_vector->itr in ixgbe_alloc_q_vector() to
make sure that TXDCTL.WTHRESH is set to 8 by default.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  | 15 +++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 20 --------------------
 2 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 5e508b6..8c74f73 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -824,6 +824,21 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 	/* initialize pointer to rings */
 	ring = q_vector->ring;
 
+	/* intialize ITR */
+	if (txr_count && !rxr_count) {
+		/* tx only vector */
+		if (adapter->tx_itr_setting == 1)
+			q_vector->itr = IXGBE_10K_ITR;
+		else
+			q_vector->itr = adapter->tx_itr_setting;
+	} else {
+		/* rx or rx/tx vector */
+		if (adapter->rx_itr_setting == 1)
+			q_vector->itr = IXGBE_20K_ITR;
+		else
+			q_vector->itr = adapter->rx_itr_setting;
+	}
+
 	while (txr_count) {
 		/* assign generic ring traits */
 		ring->dev = &adapter->pdev->dev;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 26bfaae..8b1a38b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1976,20 +1976,6 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 		ixgbe_for_each_ring(ring, q_vector->tx)
 			ixgbe_set_ivar(adapter, 1, ring->reg_idx, v_idx);
 
-		if (q_vector->tx.ring && !q_vector->rx.ring) {
-			/* tx only vector */
-			if (adapter->tx_itr_setting == 1)
-				q_vector->itr = IXGBE_10K_ITR;
-			else
-				q_vector->itr = adapter->tx_itr_setting;
-		} else {
-			/* rx or rx/tx vector */
-			if (adapter->rx_itr_setting == 1)
-				q_vector->itr = IXGBE_20K_ITR;
-			else
-				q_vector->itr = adapter->rx_itr_setting;
-		}
-
 		ixgbe_write_eitr(q_vector);
 	}
 
@@ -2761,12 +2747,6 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_q_vector *q_vector = adapter->q_vector[0];
 
-	/* rx/tx vector */
-	if (adapter->rx_itr_setting == 1)
-		q_vector->itr = IXGBE_20K_ITR;
-	else
-		q_vector->itr = adapter->rx_itr_setting;
-
 	ixgbe_write_eitr(q_vector);
 
 	ixgbe_set_ivar(adapter, 0, 0, 0);
-- 
1.7.11.7
