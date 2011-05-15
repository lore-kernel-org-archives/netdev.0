From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 11/13] ixgbe: cleanup some minor issues in ixgbe_down()
Date: Sat, 14 May 2011 18:23:45 -0700
Message-ID: <1305422627-9583-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52581 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759570Ab1EOBXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 21:23:54 -0400
In-Reply-To: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch cleans up two minor issues in ixgbe_down.  Specifically it
addresses the fact that the VFs should not be pinged until after interrupts
are disabled otherwise they might still get a response.  It also drops the
use of the txdctl temporary variable since the only bit we should be
writing to the TXDCTL registers during a shutdown is the flush bit.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   34 ++++++++++++++++------------------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index dad56e1..4be2af2 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4182,26 +4182,12 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 rxctrl;
-	u32 txdctl;
 	int i;
 	int num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
 	/* signal that we are down to the interrupt handler */
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
-	/* disable receive for all VFs and wait one second */
-	if (adapter->num_vfs) {
-		/* ping all the active vfs to let them know we are going down */
-		ixgbe_ping_all_vfs(adapter);
-
-		/* Disable all VFTE/VFRE TX/RX */
-		ixgbe_disable_tx_rx(adapter);
-
-		/* Mark all the VFs as inactive */
-		for (i = 0 ; i < adapter->num_vfs; i++)
-			adapter->vfinfo[i].clear_to_send = 0;
-	}
-
 	/* disable receives */
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
@@ -4229,6 +4215,19 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	del_timer_sync(&adapter->service_timer);
 
+	/* disable receive for all VFs and wait one second */
+	if (adapter->num_vfs) {
+		/* ping all the active vfs to let them know we are going down */
+		ixgbe_ping_all_vfs(adapter);
+
+		/* Disable all VFTE/VFRE TX/RX */
+		ixgbe_disable_tx_rx(adapter);
+
+		/* Mark all the VFs as inactive */
+		for (i = 0 ; i < adapter->num_vfs; i++)
+			adapter->vfinfo[i].clear_to_send = 0;
+	}
+
 	/* Cleanup the affinity_hint CPU mask memory and callback */
 	for (i = 0; i < num_q_vectors; i++) {
 		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
@@ -4241,11 +4240,10 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	/* disable transmits in the hardware now that interrupts are off */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		u8 reg_idx = adapter->tx_ring[i]->reg_idx;
-		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(reg_idx));
-		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(reg_idx),
-				(txdctl & ~IXGBE_TXDCTL_ENABLE));
+		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(reg_idx), IXGBE_TXDCTL_SWFLSH);
 	}
-	/* Disable the Tx DMA engine on 82599 */
+
+	/* Disable the Tx DMA engine on 82599 and X540 */
 	switch (hw->mac.type) {
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
-- 
1.7.4.4

