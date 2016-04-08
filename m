From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/18] ixgbe: Read and parse NW_MNG_IF_SEL register
Date: Thu,  7 Apr 2016 20:21:08 -0700
Message-ID: <1460085673-87056-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5938 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932155AbcDHDVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 23:21:22 -0400
In-Reply-To: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Read the IXGBE_NW_MNG_IF_SEL register and use it to set interface
attributes.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  5 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 37 +++++++++++++++++++++++----
 2 files changed, 37 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index a5c789e..6b68e8b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3649,5 +3649,10 @@ struct ixgbe_info {
 #define IXGBE_SB_IOSF_TARGET_KX4_PCS1	3
 
 #define IXGBE_NW_MNG_IF_SEL		0x00011178
+#define IXGBE_NW_MNG_IF_SEL_MDIO_ACT		BIT(1)
+#define IXGBE_NW_MNG_IF_SEL_ENABLE_10_100M	BIT(23)
 #define IXGBE_NW_MNG_IF_SEL_INT_PHY_MODE	BIT(24)
+#define IXGBE_NW_MNG_IF_SEL_MDIO_PHY_ADD_SHIFT	3
+#define IXGBE_NW_MNG_IF_SEL_MDIO_PHY_ADD	\
+				(0x1F << IXGBE_NW_MNG_IF_SEL_MDIO_PHY_ADD_SHIFT)
 #endif /* _IXGBE_TYPE_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index ef1dc3b..3563b86 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2137,6 +2137,36 @@ static s32 ixgbe_enter_lplu_t_x550em(struct ixgbe_hw *hw)
 	return status;
 }
 
+/**
+ * ixgbe_read_mng_if_sel_x550em - Read NW_MNG_IF_SEL register
+ * @hw: pointer to hardware structure
+ *
+ * Read NW_MNG_IF_SEL register and save field values.
+ */
+static void ixgbe_read_mng_if_sel_x550em(struct ixgbe_hw *hw)
+{
+	/* Save NW management interface connected on board. This is used
+	 * to determine internal PHY mode.
+	 */
+	hw->phy.nw_mng_if_sel = IXGBE_READ_REG(hw, IXGBE_NW_MNG_IF_SEL);
+
+	/* If X552 (X550EM_a) and MDIO is connected to external PHY, then set
+	 * PHY address. This register field was has only been used for X552.
+	 */
+	if (!hw->phy.nw_mng_if_sel) {
+		if (hw->mac.type == ixgbe_mac_x550em_a) {
+			struct ixgbe_adapter *adapter = hw->back;
+
+			e_warn(drv, "nw_mng_if_sel not set\n");
+		}
+		return;
+	}
+
+	hw->phy.mdio.prtad = (hw->phy.nw_mng_if_sel &
+			      IXGBE_NW_MNG_IF_SEL_MDIO_PHY_ADD) >>
+			     IXGBE_NW_MNG_IF_SEL_MDIO_PHY_ADD_SHIFT;
+}
+
 /** ixgbe_init_phy_ops_X550em - PHY/SFP specific init
  *  @hw: pointer to hardware structure
  *
@@ -2151,14 +2181,11 @@ static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 
 	hw->mac.ops.set_lan_id(hw);
 
+	ixgbe_read_mng_if_sel_x550em(hw);
+
 	if (hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber) {
 		phy->phy_semaphore_mask = IXGBE_GSSR_SHARED_I2C_SM;
 		ixgbe_setup_mux_ctl(hw);
-
-		/* Save NW management interface connected on board. This is used
-		 * to determine internal PHY mode.
-		 */
-		phy->nw_mng_if_sel = IXGBE_READ_REG(hw, IXGBE_NW_MNG_IF_SEL);
 	}
 
 	/* Identify the PHY or SFP module */
-- 
2.5.5
