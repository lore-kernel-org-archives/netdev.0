From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/5] net: ixgbe: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Mon,  9 Oct 2017 08:12:50 -0700
Message-ID: <20171009151251.53939-5-jeffrey.t.kirsher@intel.com>
References: <20171009151251.53939-1-jeffrey.t.kirsher@intel.com>
Cc: Ding Tianhong <dingtianhong@huawei.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:14347 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751636AbdJIPNP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 11:13:15 -0400
In-Reply-To: <20171009151251.53939-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>

The ixgbe driver use the compile check to determine if it can
send TLPs to Root Port with the Relaxed Ordering Attribute set,
this is too inconvenient, now the new flag PCI_DEV_FLAGS_NO_RELAXED_ORDERING
has been added to the kernel and we could check the bit4 in the PCIe
Device Control register to determine whether we should use the Relaxed
Ordering Attributes or not, so use this new way in the ixgbe driver.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Acked-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  | 22 ----------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 19 -------------------
 2 files changed, 41 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 523f9d05a810..8a32eb7d47b9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -175,31 +175,9 @@ static s32 ixgbe_init_phy_ops_82598(struct ixgbe_hw *hw)
  **/
 static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
 {
-#ifndef CONFIG_SPARC
-	u32 regval;
-	u32 i;
-#endif
 	s32 ret_val;
 
 	ret_val = ixgbe_start_hw_generic(hw);
-
-#ifndef CONFIG_SPARC
-	/* Disable relaxed ordering */
-	for (i = 0; ((i < hw->mac.max_tx_queues) &&
-	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
-		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
-		regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
-	}
-
-	for (i = 0; ((i < hw->mac.max_rx_queues) &&
-	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
-		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
-		regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
-			    IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
-	}
-#endif
 	if (ret_val)
 		return ret_val;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index e8c1788aed1f..6e6ab6f6875e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -366,25 +366,6 @@ s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
 	}
 	IXGBE_WRITE_FLUSH(hw);
 
-#ifndef CONFIG_SPARC
-	/* Disable relaxed ordering */
-	for (i = 0; i < hw->mac.max_tx_queues; i++) {
-		u32 regval;
-
-		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(i));
-		regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(i), regval);
-	}
-
-	for (i = 0; i < hw->mac.max_rx_queues; i++) {
-		u32 regval;
-
-		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
-		regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
-			    IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
-	}
-#endif
 	return 0;
 }
 
-- 
2.14.2
