From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/18] ixgbe: Correct several flaws with with DCA setup
Date: Wed, 23 Sep 2015 23:59:37 -0700
Message-ID: <1443077981-55791-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Alex Duyck <aduyck@mirantis.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31471 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932711AbbIXG75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 02:59:57 -0400
In-Reply-To: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

This change does two things. First, it makes it so that we always
set the relaxed ordering bits related to the DCA registers even if
DCA is not enabled. Second, it moves the configuration out of the
ixgbe_down function and into the ixgbe_configure function before
enabling the Rx and Tx rings. This ensures that DCA is configured
correctly before starting to process packets.

Thanks to Alex Duyck for this fix.

CC: Alex Duyck <aduyck@mirantis.com>
Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 40 +++++++++++++++++----------
 1 file changed, 26 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 28b8594..97cded3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1245,9 +1245,12 @@ static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
 				int cpu)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 txctrl = dca3_get_tag(tx_ring->dev, cpu);
+	u32 txctrl = 0;
 	u16 reg_offset;
 
+	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+		txctrl = dca3_get_tag(tx_ring->dev, cpu);
+
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
 		reg_offset = IXGBE_DCA_TXCTRL(tx_ring->reg_idx);
@@ -1279,9 +1282,11 @@ static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 				int cpu)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 rxctrl = dca3_get_tag(rx_ring->dev, cpu);
+	u32 rxctrl = 0;
 	u8 reg_idx = rx_ring->reg_idx;
 
+	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+		rxctrl = dca3_get_tag(rx_ring->dev, cpu);
 
 	switch (hw->mac.type) {
 	case ixgbe_mac_82599EB:
@@ -1298,6 +1303,7 @@ static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 	 * which will cause the DCA tag to be cleared.
 	 */
 	rxctrl |= IXGBE_DCA_RXCTRL_DESC_RRO_EN |
+		  IXGBE_DCA_RXCTRL_DATA_DCA_EN |
 		  IXGBE_DCA_RXCTRL_DESC_DCA_EN;
 
 	IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(reg_idx), rxctrl);
@@ -1327,11 +1333,13 @@ static void ixgbe_setup_dca(struct ixgbe_adapter *adapter)
 {
 	int i;
 
-	if (!(adapter->flags & IXGBE_FLAG_DCA_ENABLED))
-		return;
-
 	/* always use CB2 mode, difference is masked in the CB driver */
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
+	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL,
+				IXGBE_DCA_CTRL_DCA_MODE_CB2);
+	else
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL,
+				IXGBE_DCA_CTRL_DCA_DISABLE);
 
 	for (i = 0; i < adapter->num_q_vectors; i++) {
 		adapter->q_vector[i]->cpu = -1;
@@ -1354,7 +1362,8 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 			break;
 		if (dca_add_requester(dev) == 0) {
 			adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
-			ixgbe_setup_dca(adapter);
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL,
+					IXGBE_DCA_CTRL_DCA_MODE_CB2);
 			break;
 		}
 		/* Fall Through since DCA is disabled. */
@@ -1362,7 +1371,8 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 			dca_remove_requester(dev);
 			adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 1);
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL,
+					IXGBE_DCA_CTRL_DCA_DISABLE);
 		}
 		break;
 	}
@@ -4783,6 +4793,12 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 		break;
 	}
 
+#ifdef CONFIG_IXGBE_DCA
+	/* configure DCA */
+	if (adapter->flags & IXGBE_FLAG_DCA_CAPABLE)
+		ixgbe_setup_dca(adapter);
+#endif /* CONFIG_IXGBE_DCA */
+
 #ifdef IXGBE_FCOE
 	/* configure FCoE L2 filters, redirection table, and Rx control */
 	ixgbe_configure_fcoe(adapter);
@@ -5243,11 +5259,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	ixgbe_clean_all_tx_rings(adapter);
 	ixgbe_clean_all_rx_rings(adapter);
-
-#ifdef CONFIG_IXGBE_DCA
-	/* since we reset the hardware DCA settings were cleared */
-	ixgbe_setup_dca(adapter);
-#endif
 }
 
 /**
@@ -9036,7 +9047,8 @@ static void ixgbe_remove(struct pci_dev *pdev)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
 		dca_remove_requester(&pdev->dev);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 1);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL,
+				IXGBE_DCA_CTRL_DCA_DISABLE);
 	}
 
 #endif
-- 
2.4.3
