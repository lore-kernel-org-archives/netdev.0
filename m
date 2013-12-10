From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/12] i40e: complain about out-of-range descriptor request
Date: Tue, 10 Dec 2013 02:22:32 -0800
Message-ID: <1386670961-20392-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7804 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752700Ab3LJKXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 05:23:11 -0500
In-Reply-To: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Instead of silently clamping the descriptor change request into
the proper range, fail the request and complain in the log file.

Change-Id: Id55ef59255d93c04bedffa8e25fe7ea796c90f32
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index b04e433..fd3e379 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -422,15 +422,19 @@ static int i40e_set_ringparam(struct net_device *netdev,
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
 
-	new_tx_count = clamp_t(u32, ring->tx_pending,
-			       I40E_MIN_NUM_DESCRIPTORS,
-			       I40E_MAX_NUM_DESCRIPTORS);
-	new_tx_count = ALIGN(new_tx_count, I40E_REQ_DESCRIPTOR_MULTIPLE);
-
-	new_rx_count = clamp_t(u32, ring->rx_pending,
-			       I40E_MIN_NUM_DESCRIPTORS,
-			       I40E_MAX_NUM_DESCRIPTORS);
-	new_rx_count = ALIGN(new_rx_count, I40E_REQ_DESCRIPTOR_MULTIPLE);
+	if (ring->tx_pending > I40E_MAX_NUM_DESCRIPTORS ||
+	    ring->tx_pending < I40E_MIN_NUM_DESCRIPTORS ||
+	    ring->rx_pending > I40E_MAX_NUM_DESCRIPTORS ||
+	    ring->rx_pending < I40E_MIN_NUM_DESCRIPTORS) {
+		netdev_info(netdev,
+			    "Descriptors requested (Tx: %d / Rx: %d) out of range [%d-%d]\n",
+			    ring->tx_pending, ring->rx_pending,
+			    I40E_MIN_NUM_DESCRIPTORS, I40E_MAX_NUM_DESCRIPTORS);
+		return -EINVAL;
+	}
+
+	new_tx_count = ALIGN(ring->tx_pending, I40E_REQ_DESCRIPTOR_MULTIPLE);
+	new_rx_count = ALIGN(ring->rx_pending, I40E_REQ_DESCRIPTOR_MULTIPLE);
 
 	/* if nothing to do return success */
 	if ((new_tx_count == vsi->tx_rings[0]->count) &&
-- 
1.8.3.1
