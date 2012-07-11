From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/5] ixgbe: Clean up a useless switch statement and dead code in configure_srrctl
Date: Wed, 11 Jul 2012 02:09:28 -0700
Message-ID: <1341997769-22034-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1341997769-22034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47130 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754356Ab2GKJJj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 05:09:39 -0400
In-Reply-To: <1341997769-22034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch replaces a switch statement for an 82598 workaround with an if
statement that only applies to 82598. In addition I am pulling out several
dead pieces of code and instead of reading the SRRCTL register and then
modifying it we are just writing a value which we generate from scratch.
Finally I am also removing any drop enable related code since that was
moved to a function of its own.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   36 +++++++++++--------------
 1 file changed, 15 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3a807ff..d3cf887 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2847,40 +2847,34 @@ static void ixgbe_set_rx_drop_en(struct ixgbe_adapter *adapter)
 static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 				   struct ixgbe_ring *rx_ring)
 {
+	struct ixgbe_hw *hw = &adapter->hw;
 	u32 srrctl;
 	u8 reg_idx = rx_ring->reg_idx;
 
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82598EB: {
-		struct ixgbe_ring_feature *feature = adapter->ring_feature;
-		const int mask = feature[RING_F_RSS].mask;
-		reg_idx = reg_idx & mask;
-	}
-		break;
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-	default:
-		break;
-	}
-
-	srrctl = IXGBE_READ_REG(&adapter->hw, IXGBE_SRRCTL(reg_idx));
+	if (hw->mac.type == ixgbe_mac_82598EB) {
+		u16 mask = adapter->ring_feature[RING_F_RSS].mask;
 
-	srrctl &= ~IXGBE_SRRCTL_BSIZEHDR_MASK;
-	srrctl &= ~IXGBE_SRRCTL_BSIZEPKT_MASK;
-	if (adapter->num_vfs)
-		srrctl |= IXGBE_SRRCTL_DROP_EN;
+		/*
+		 * if VMDq is not active we must program one srrctl register
+		 * per RSS queue since we have enabled RDRXCTL.MVMEN
+		 */
+		reg_idx &= mask;
+	}
 
-	srrctl |= (IXGBE_RX_HDR_SIZE << IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
-		  IXGBE_SRRCTL_BSIZEHDR_MASK;
+	/* configure header buffer length, needed for RSC */
+	srrctl = IXGBE_RX_HDR_SIZE << IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT;
 
+	/* configure the packet buffer length */
 #if PAGE_SIZE > IXGBE_MAX_RXBUFFER
 	srrctl |= IXGBE_MAX_RXBUFFER >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 #else
 	srrctl |= ixgbe_rx_bufsz(rx_ring) >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 #endif
+
+	/* configure descriptor type */
 	srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
 
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(reg_idx), srrctl);
+	IXGBE_WRITE_REG(hw, IXGBE_SRRCTL(reg_idx), srrctl);
 }
 
 static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
-- 
1.7.10.4
