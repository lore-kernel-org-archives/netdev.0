From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/7] ixgbe: Fix incorrect disabling of Tx hang check in case of PFC
Date: Wed, 28 Nov 2012 05:06:16 -0800
Message-ID: <1354107978-24731-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354107978-24731-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Neerav Parikh <Neerav.Parikh@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22067 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932105Ab2K1NGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 08:06:25 -0500
In-Reply-To: <1354107978-24731-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

The XOFF received statistic registers are per priority based and not per
traffic class. The ixgbe driver was incorrectly considering them to be for
each traffic class; and then disabling the "Tx hang" check for the queues
that belonged to the particular traffic class that had received PFC frames.

The above logic worked fine in scenario where the user priority and traffic
class number matched e.g. priority 0 is mapped to traffic class 0 and so on.
But, when multiple user priorities are mapped to a single traffic class or
when user priorities and traffic class numbers do not line up; the ixgbe
driver may disable the "Tx hang" check for queues belonging to a traffic
class that did not receive PFC frames and keep the "Tx hang" check enabled
for the queues that did receive the PFC frames.

This patch corrects the above in the code by considering the statistics
on a per priority basis; then getting the traffic class the user priority
belongs to and disabling the "Tx hang" check for queues that belong
to that traffic class.

Signed-off-by: Neerav Parikh <Neerav.Parikh@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Marcus Dennis <marcusx.e.dennis@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e6e1245..fc8cfad 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -703,6 +703,7 @@ static void ixgbe_update_xoff_received(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbe_hw_stats *hwstats = &adapter->stats;
 	u32 xoff[8] = {0};
+	u8 tc;
 	int i;
 	bool pfc_en = adapter->dcb_cfg.pfc_mode_enable;
 
@@ -716,21 +717,26 @@ static void ixgbe_update_xoff_received(struct ixgbe_adapter *adapter)
 
 	/* update stats for each tc, only valid with PFC enabled */
 	for (i = 0; i < MAX_TX_PACKET_BUFFERS; i++) {
+		u32 pxoffrxc;
+
 		switch (hw->mac.type) {
 		case ixgbe_mac_82598EB:
-			xoff[i] = IXGBE_READ_REG(hw, IXGBE_PXOFFRXC(i));
+			pxoffrxc = IXGBE_READ_REG(hw, IXGBE_PXOFFRXC(i));
 			break;
 		default:
-			xoff[i] = IXGBE_READ_REG(hw, IXGBE_PXOFFRXCNT(i));
+			pxoffrxc = IXGBE_READ_REG(hw, IXGBE_PXOFFRXCNT(i));
 		}
-		hwstats->pxoffrxc[i] += xoff[i];
+		hwstats->pxoffrxc[i] += pxoffrxc;
+		/* Get the TC for given UP */
+		tc = netdev_get_prio_tc_map(adapter->netdev, i);
+		xoff[tc] += pxoffrxc;
 	}
 
 	/* disarm tx queues that have received xoff frames */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		struct ixgbe_ring *tx_ring = adapter->tx_ring[i];
-		u8 tc = tx_ring->dcb_tc;
 
+		tc = tx_ring->dcb_tc;
 		if (xoff[tc])
 			clear_bit(__IXGBE_HANG_CHECK_ARMED, &tx_ring->state);
 	}
-- 
1.7.11.7
