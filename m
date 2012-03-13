From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] ixgbe: Address issues with Tx WHTRESH value not being set correctly
Date: Mon, 12 Mar 2012 21:03:46 -0700
Message-ID: <1331611432-30109-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:31610 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766Ab2CMEEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:04:04 -0400
In-Reply-To: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to address the fact that the tx_itr_setting was
dropping to 0 when no separate Tx vectors were provided.  This had resulted
in the driver incorrectly configuring the Tx ring with a WTHRESH of 1 in
order to avoid Tx hangs even though that was not necessary. This change
makes it so that we instead take a look at the Tx ring's q_vector to
determine if the ring will have an ITR value less than 8us.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a2c14bf..fc3c33a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2595,12 +2595,15 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 	 * to or less than the number of on chip descriptors, which is
 	 * currently 40.
 	 */
-	if (!adapter->tx_itr_setting || !adapter->rx_itr_setting)
+	if (!ring->q_vector || (ring->q_vector->itr < 8))
 		txdctl |= (1 << 16);	/* WTHRESH = 1 */
 	else
 		txdctl |= (8 << 16);	/* WTHRESH = 8 */
 
-	/* PTHRESH=32 is needed to avoid a Tx hang with DFP enabled. */
+	/*
+	 * Setting PTHRESH to 32 both improves performance
+	 * and avoids a TX hang with DFP enabled
+	 */
 	txdctl |= (1 << 8) |	/* HTHRESH = 1 */
 		   32;		/* PTHRESH = 32 */
 
-- 
1.7.7.6
