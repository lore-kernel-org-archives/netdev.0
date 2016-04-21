From: Babu Moger <babu.moger@oracle.com>
Subject: [PATCH] ixgbevf: Fix relaxed order settings in VF driver
Date: Thu, 21 Apr 2016 10:21:16 -0700
Message-ID: <1461259276-54151-1-git-send-email-babu.moger@oracle.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, babu.moger@oracle.com,
	sowmini.varadhan@oracle.com
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current code writes the tx/rx relaxed order without reading it first.
This can lead to unintended consequences as we are forcibly writing
other bits.

We noticed this problem while testing VF driver on sparc. Relaxed
order settings for rx queue were all messed up which was causing
performance drop with VF interface.

Fixed it by reading the registers first and setting the specific
bit of interest. With this change we are able to match the bandwidth
equivalent to PF interface.

Signed-off-by: Babu Moger <babu.moger@oracle.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 0ea14c0..51abff1 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1545,6 +1545,7 @@ static inline void ixgbevf_irq_enable(struct ixgbevf_adapter *adapter)
 static void ixgbevf_configure_tx_ring(struct ixgbevf_adapter *adapter,
 				      struct ixgbevf_ring *ring)
 {
+	u32 regval;
 	struct ixgbe_hw *hw = &adapter->hw;
 	u64 tdba = ring->dma;
 	int wait_loop = 10;
@@ -1565,8 +1566,10 @@ static void ixgbevf_configure_tx_ring(struct ixgbevf_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_VFTDWBAL(reg_idx), 0);
 
 	/* enable relaxed ordering */
+	regval = IXGBE_READ_REG(hw, IXGBE_VFDCA_TXCTRL(reg_idx));
+
 	IXGBE_WRITE_REG(hw, IXGBE_VFDCA_TXCTRL(reg_idx),
-			(IXGBE_DCA_TXCTRL_DESC_RRO_EN |
+			(regval | IXGBE_DCA_TXCTRL_DESC_RRO_EN |
 			 IXGBE_DCA_TXCTRL_DATA_RRO_EN));
 
 	/* reset head and tail pointers */
@@ -1734,6 +1737,7 @@ static void ixgbevf_setup_vfmrqc(struct ixgbevf_adapter *adapter)
 static void ixgbevf_configure_rx_ring(struct ixgbevf_adapter *adapter,
 				      struct ixgbevf_ring *ring)
 {
+	u32 regval;
 	struct ixgbe_hw *hw = &adapter->hw;
 	u64 rdba = ring->dma;
 	u32 rxdctl;
@@ -1749,8 +1753,9 @@ static void ixgbevf_configure_rx_ring(struct ixgbevf_adapter *adapter,
 			ring->count * sizeof(union ixgbe_adv_rx_desc));
 
 	/* enable relaxed ordering */
+	regval = IXGBE_READ_REG(hw, IXGBE_VFDCA_RXCTRL(reg_idx));
 	IXGBE_WRITE_REG(hw, IXGBE_VFDCA_RXCTRL(reg_idx),
-			IXGBE_DCA_RXCTRL_DESC_RRO_EN);
+			regval | IXGBE_DCA_RXCTRL_DESC_RRO_EN);
 
 	/* reset head and tail pointers */
 	IXGBE_WRITE_REG(hw, IXGBE_VFRDH(reg_idx), 0);
-- 
1.7.1
