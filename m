From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] ixgbe: add device support for 82598AT (copper 10GbE)
	adapters
Date: Fri, 31 Oct 2008 00:46:40 -0700
Message-ID: <20081031074640.25760.45148.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:35371 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750914AbYJaHrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 03:47:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Intel is currently shipping support for adapters with a phy
that does 10GBase-T (copper), which is 10 Gigabit ethernet
over standard Category 6 cabling.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    1 +
 drivers/net/ixgbe/ixgbe_82598.c   |   12 +++++++
 drivers/net/ixgbe/ixgbe_ethtool.c |   27 +++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c    |   33 ++++++++++++++++++
 drivers/net/ixgbe/ixgbe_phy.c     |   68 +++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_phy.h     |    7 ++++
 drivers/net/ixgbe/ixgbe_type.h    |    6 +++
 7 files changed, 154 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index e116d34..132854f 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -267,6 +267,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_RSS_CAPABLE                  (u32)(1 << 17)
 #define IXGBE_FLAG_VMDQ_CAPABLE                 (u32)(1 << 18)
 #define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 19)
+#define IXGBE_FLAG_FAN_FAIL_CAPABLE             (u32)(1 << 20)
 #define IXGBE_FLAG_NEED_LINK_UPDATE             (u32)(1 << 22)
 #define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1 << 23)
 
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 7cddcfb..c2cdb04 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -59,6 +59,11 @@ static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 
 	/* PHY Init */
 	switch (phy->type) {
+	case ixgbe_phy_tn:
+		phy->ops.check_link = &ixgbe_check_phy_link_tnx;
+		phy->ops.get_firmware_version =
+		             &ixgbe_get_phy_firmware_version_tnx;
+		break;
 	default:
 		break;
 	}
@@ -189,6 +194,9 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82598EB_XF_LR:
 		media_type = ixgbe_media_type_fiber;
 		break;
+	case IXGBE_DEV_ID_82598AT:
+		media_type = ixgbe_media_type_copper;
+		break;
 	default:
 		media_type = ixgbe_media_type_unknown;
 		break;
@@ -872,6 +880,10 @@ s32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82598EB_XF_LR:
 		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_LR;
 		break;
+	case IXGBE_DEV_ID_82598AT:
+		physical_layer = (IXGBE_PHYSICAL_LAYER_10GBASE_T |
+		                  IXGBE_PHYSICAL_LAYER_1000BASE_T);
+		break;
 
 	default:
 		physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 81a9c4b..fee56a3 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -149,6 +149,8 @@ static int ixgbe_set_settings(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
+	u32 advertised, old;
+	s32 err;
 
 	switch (hw->phy.media_type) {
 	case ixgbe_media_type_fiber:
@@ -157,6 +159,31 @@ static int ixgbe_set_settings(struct net_device *netdev,
 			return -EINVAL;
 		/* in this case we currently only support 10Gb/FULL */
 		break;
+	case ixgbe_media_type_copper:
+		/* 10000/copper and 1000/copper must autoneg
+		 * this function does not support any duplex forcing, but can
+		 * limit the advertising of the adapter to only 10000 or 1000 */
+		if (ecmd->autoneg == AUTONEG_DISABLE)
+			return -EINVAL;
+
+		old = hw->phy.autoneg_advertised;
+		advertised = 0;
+		if (ecmd->advertising & ADVERTISED_10000baseT_Full)
+			advertised |= IXGBE_LINK_SPEED_10GB_FULL;
+
+		if (ecmd->advertising & ADVERTISED_1000baseT_Full)
+			advertised |= IXGBE_LINK_SPEED_1GB_FULL;
+
+		if (old == advertised)
+			break;
+		/* this sets the link speed and restarts auto-neg */
+		err = hw->mac.ops.setup_link_speed(hw, advertised, true, true);
+		if (err) {
+			DPRINTK(PROBE, INFO,
+			        "setup link failed with code %d\n", err);
+			hw->mac.ops.setup_link_speed(hw, old, true, true);
+		}
+		break;
 	default:
 		break;
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 028bfb2..2a12e97 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -68,6 +68,8 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_SINGLE_PORT),
 	 board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AT),
+	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_CX4),
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_CX4_DUAL_PORT),
@@ -904,6 +906,17 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 	return;
 }
 
+static void ixgbe_check_fan_failure(struct ixgbe_adapter *adapter, u32 eicr)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	if ((adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE) &&
+	    (eicr & IXGBE_EICR_GPI_SDP1)) {
+		DPRINTK(PROBE, CRIT, "Fan has stopped, replace the adapter\n");
+		/* write to clear the interrupt */
+		IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP1);
+	}
+}
 
 static void ixgbe_check_lsc(struct ixgbe_adapter *adapter)
 {
@@ -928,6 +941,8 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 	if (eicr & IXGBE_EICR_LSC)
 		ixgbe_check_lsc(adapter);
 
+	ixgbe_check_fan_failure(adapter, eicr);
+
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_OTHER);
 
@@ -1316,6 +1331,8 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	if (eicr & IXGBE_EICR_LSC)
 		ixgbe_check_lsc(adapter);
 
+	ixgbe_check_fan_failure(adapter, eicr);
+
 	if (netif_rx_schedule_prep(netdev, &adapter->q_vector[0].napi)) {
 		adapter->tx_ring[0].total_packets = 0;
 		adapter->tx_ring[0].total_bytes = 0;
@@ -1418,6 +1435,8 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
 {
 	u32 mask;
 	mask = IXGBE_EIMS_ENABLE_MASK;
+	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
+		mask |= IXGBE_EIMS_GPI_SDP1;
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 }
@@ -1927,6 +1946,13 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_EIAM, IXGBE_EICS_RTX_QUEUE);
 	}
 
+	/* Enable fan failure interrupt if media type is copper */
+	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE) {
+		gpie = IXGBE_READ_REG(hw, IXGBE_GPIE);
+		gpie |= IXGBE_SDP1_GPIEN;
+		IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
+	}
+
 	mhadd = IXGBE_READ_REG(hw, IXGBE_MHADD);
 	if (max_frame != (mhadd >> IXGBE_MHADD_MFS_SHIFT)) {
 		mhadd &= ~IXGBE_MHADD_MFS_MASK;
@@ -2564,6 +2590,9 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	rss = min(IXGBE_MAX_RSS_INDICES, (int)num_online_cpus());
 	adapter->ring_feature[RING_F_RSS].indices = rss;
 	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
+	if (hw->mac.ops.get_media_type &&
+	    (hw->mac.ops.get_media_type(hw) == ixgbe_media_type_copper))
+		adapter->flags |= IXGBE_FLAG_FAN_FAIL_CAPABLE;
 
 	/* default flow control settings */
 	hw->fc.original_type = ixgbe_fc_none;
@@ -3691,6 +3720,10 @@ static int ixgbe_link_config(struct ixgbe_hw *hw)
 	/* must always autoneg for both 1G and 10G link */
 	hw->mac.autoneg = true;
 
+	if ((hw->mac.type == ixgbe_mac_82598EB) &&
+	    (hw->phy.media_type == ixgbe_media_type_copper))
+		autoneg = IXGBE_LINK_SPEED_82598_AUTONEG;
+
 	return hw->mac.ops.setup_link_speed(hw, autoneg, true, true);
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 764035a..981e6d8 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -121,6 +121,9 @@ static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id)
 	enum ixgbe_phy_type phy_type;
 
 	switch (phy_id) {
+	case TN1010_PHY_ID:
+		phy_type = ixgbe_phy_tn;
+		break;
 	case QT2022_PHY_ID:
 		phy_type = ixgbe_phy_qt;
 		break;
@@ -426,3 +429,68 @@ s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
 	return 0;
 }
 
+/**
+ *  ixgbe_check_phy_link_tnx - Determine link and speed status
+ *  @hw: pointer to hardware structure
+ *
+ *  Reads the VS1 register to determine if link is up and the current speed for
+ *  the PHY.
+ **/
+s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
+                             bool *link_up)
+{
+	s32 status = 0;
+	u32 time_out;
+	u32 max_time_out = 10;
+	u16 phy_link = 0;
+	u16 phy_speed = 0;
+	u16 phy_data = 0;
+
+	/* Initialize speed and link to default case */
+	*link_up = false;
+	*speed = IXGBE_LINK_SPEED_10GB_FULL;
+
+	/*
+	 * Check current speed and link status of the PHY register.
+	 * This is a vendor specific register and may have to
+	 * be changed for other copper PHYs.
+	 */
+	for (time_out = 0; time_out < max_time_out; time_out++) {
+		udelay(10);
+		status = hw->phy.ops.read_reg(hw,
+		                        IXGBE_MDIO_VENDOR_SPECIFIC_1_STATUS,
+		                        IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
+		                        &phy_data);
+		phy_link = phy_data &
+		           IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS;
+		phy_speed = phy_data &
+		            IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS;
+		if (phy_link == IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS) {
+			*link_up = true;
+			if (phy_speed ==
+			    IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS)
+				*speed = IXGBE_LINK_SPEED_1GB_FULL;
+			break;
+		}
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_get_phy_firmware_version_tnx - Gets the PHY Firmware Version
+ *  @hw: pointer to hardware structure
+ *  @firmware_version: pointer to the PHY Firmware Version
+ **/
+s32 ixgbe_get_phy_firmware_version_tnx(struct ixgbe_hw *hw,
+                                       u16 *firmware_version)
+{
+	s32 status = 0;
+
+	status = hw->phy.ops.read_reg(hw, TNX_FW_REV,
+	                              IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
+	                              firmware_version);
+
+	return status;
+}
+
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index 9bfe3f2..5cc063d 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -77,4 +77,11 @@ s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
                                        bool autoneg,
                                        bool autoneg_wait_to_complete);
 
+/* PHY specific */
+s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw,
+                             ixgbe_link_speed *speed,
+                             bool *link_up);
+s32 ixgbe_get_phy_firmware_version_tnx(struct ixgbe_hw *hw,
+                                       u16 *firmware_version);
+
 #endif /* _IXGBE_PHY_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index c6f8fa1..51df39d 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -36,6 +36,7 @@
 /* Device IDs */
 #define IXGBE_DEV_ID_82598AF_DUAL_PORT   0x10C6
 #define IXGBE_DEV_ID_82598AF_SINGLE_PORT 0x10C7
+#define IXGBE_DEV_ID_82598AT             0x10C8
 #define IXGBE_DEV_ID_82598EB_CX4         0x10DD
 #define IXGBE_DEV_ID_82598_CX4_DUAL_PORT 0x10EC
 #define IXGBE_DEV_ID_82598EB_XF_LR       0x10F4
@@ -488,6 +489,8 @@
 #define IXGBE_MAX_PHY_ADDR             32
 
 /* PHY IDs*/
+#define TN1010_PHY_ID    0x00A19410
+#define TNX_FW_REV       0xB
 #define QT2022_PHY_ID    0x0043A400
 
 /* PHY Types */
@@ -1202,6 +1205,7 @@ enum ixgbe_mac_type {
 
 enum ixgbe_phy_type {
 	ixgbe_phy_unknown = 0,
+	ixgbe_phy_tn,
 	ixgbe_phy_qt,
 	ixgbe_phy_xaui,
 	ixgbe_phy_tw_tyco,
@@ -1396,6 +1400,8 @@ struct ixgbe_phy_operations {
 	s32 (*setup_link)(struct ixgbe_hw *);
 	s32 (*setup_link_speed)(struct ixgbe_hw *, ixgbe_link_speed, bool,
 	                        bool);
+	s32 (*check_link)(struct ixgbe_hw *, ixgbe_link_speed *, bool *);
+	s32 (*get_firmware_version)(struct ixgbe_hw *, u16 *);
 	s32 (*read_i2c_byte)(struct ixgbe_hw *, u8, u8, u8 *);
 	s32 (*write_i2c_byte)(struct ixgbe_hw *, u8, u8, u8);
 	s32 (*read_i2c_eeprom)(struct ixgbe_hw *, u8 , u8 *);

