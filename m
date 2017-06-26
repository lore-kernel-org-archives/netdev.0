From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/6] ixgbe: Add malicious driver detection support
Date: Mon, 26 Jun 2017 14:39:33 -0700
Message-ID: <20170626213933.9635-7-jeffrey.t.kirsher@intel.com>
References: <20170626213933.9635-1-jeffrey.t.kirsher@intel.com>
Cc: Paul Greenwalt <paul.greenwalt@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:21725 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752096AbdFZVjn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 17:39:43 -0400
In-Reply-To: <20170626213933.9635-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Greenwalt <paul.greenwalt@intel.com>

Add malicious driver detection (MDD) support for X550, X550em_a,
and X550em_x devices.

MDD is a hardware SR-IOV security feature which the driver enables by
default, but can be controlled on|off by ethtool set-priv-flags
parameter. When enabled MDD disables a VF drivers transmit queue
when a malformed descriptor is detected. The PF will log the event
and re-enable the VF queue.

Signed-off-by: Paul Greenwalt <paul.greenwalt@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   3 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c  |  25 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  13 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   6 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   |  50 ++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |   8 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c    | 138 +++++++++++++++++++++++
 7 files changed, 241 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index dd5578756ae0..2e9df66f6e18 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -563,6 +563,8 @@ struct ixgbe_mac_addr {
 #define IXGBE_TRY_LINK_TIMEOUT (4 * HZ)
 #define IXGBE_SFP_POLL_JIFFIES (2 * HZ)	/* SFP poll every 2 seconds */
 
+#define IXGBE_MDD_Q_BITMAP_DEPTH 2
+
 /* board specific private data structure */
 struct ixgbe_adapter {
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
@@ -603,6 +605,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_RX_HWTSTAMP_IN_REGISTER	BIT(26)
 #define IXGBE_FLAG_DCB_CAPABLE			BIT(27)
 #define IXGBE_FLAG_GENEVE_OFFLOAD_CAPABLE	BIT(28)
+#define IXGBE_FLAG_MDD_ENABLED			BIT(29)
 
 	u32 flags2;
 #define IXGBE_FLAG2_RSC_CAPABLE			BIT(0)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 78c52375acc6..d37d2b077bbe 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -379,10 +379,22 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		} else {
 			hw->mac.ops.fc_enable(hw);
 		}
+		/* Disable MDD before updating SRRCTL, because modifying the
+		 * SRRCTL register while the queue is enabled will generate an
+		 * MDD event.
+		 */
+		if ((adapter->num_vfs) && (hw->mac.ops.disable_mdd) &&
+		    (adapter->flags & IXGBE_FLAG_MDD_ENABLED))
+			hw->mac.ops.disable_mdd(hw);
 
 		ixgbe_set_rx_drop_en(adapter);
 
-		ret = DCB_HW_CHG;
+		if ((adapter->num_vfs) && (hw->mac.ops.enable_mdd) &&
+		    (adapter->flags & IXGBE_FLAG_MDD_ENABLED))
+			hw->mac.ops.enable_mdd(hw);
+
+		if (ret != DCB_HW_CHG_RST)
+			ret = DCB_HW_CHG;
 	}
 
 #ifdef IXGBE_FCOE
@@ -634,8 +646,19 @@ static int ixgbe_dcbnl_ieee_setpfc(struct net_device *dev,
 	else
 		err = hw->mac.ops.fc_enable(hw);
 
+	/* Disable MDD before updating SRRCTL, because modifying the SRRCTL
+	 * register while the queue is enabled will generate an MDD event.
+	 */
+	if ((adapter->num_vfs) && (hw->mac.ops.disable_mdd) &&
+	    (adapter->flags & IXGBE_FLAG_MDD_ENABLED))
+		hw->mac.ops.disable_mdd(hw);
+
 	ixgbe_set_rx_drop_en(adapter);
 
+	if ((adapter->num_vfs) && (hw->mac.ops.enable_mdd) &&
+	    (adapter->flags & IXGBE_FLAG_MDD_ENABLED))
+		hw->mac.ops.enable_mdd(hw);
+
 	return err;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 72c565712a5f..e10a4d6d5391 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -157,6 +157,8 @@ static const char ixgbe_gstrings_test[][ETH_GSTRING_LEN] = {
 static const char ixgbe_priv_flags_strings[][ETH_GSTRING_LEN] = {
 #define IXGBE_PRIV_FLAGS_LEGACY_RX	BIT(0)
 	"legacy-rx",
+#define IXGBE_PRIV_FLAG_MDD_ENABLED	BIT(1)
+	"mdd",
 };
 
 #define IXGBE_PRIV_FLAGS_STR_LEN ARRAY_SIZE(ixgbe_priv_flags_strings)
@@ -3420,6 +3422,9 @@ static u32 ixgbe_get_priv_flags(struct net_device *netdev)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	u32 priv_flags = 0;
 
+	if (adapter->flags & IXGBE_FLAG_MDD_ENABLED)
+		priv_flags |= IXGBE_PRIV_FLAG_MDD_ENABLED;
+
 	if (adapter->flags2 & IXGBE_FLAG2_RX_LEGACY)
 		priv_flags |= IXGBE_PRIV_FLAGS_LEGACY_RX;
 
@@ -3430,13 +3435,19 @@ static int ixgbe_set_priv_flags(struct net_device *netdev, u32 priv_flags)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	unsigned int flags2 = adapter->flags2;
+	unsigned int flags = adapter->flags;
+
+	flags &= ~IXGBE_FLAG_MDD_ENABLED;
+	if (priv_flags & IXGBE_PRIV_FLAG_MDD_ENABLED)
+		flags |= IXGBE_FLAG_MDD_ENABLED;
 
 	flags2 &= ~IXGBE_FLAG2_RX_LEGACY;
 	if (priv_flags & IXGBE_PRIV_FLAGS_LEGACY_RX)
 		flags2 |= IXGBE_FLAG2_RX_LEGACY;
 
-	if (flags2 != adapter->flags2) {
+	if (flags2 != adapter->flags2 || flags != adapter->flags) {
 		adapter->flags2 = flags2;
+		adapter->flags = flags;
 
 		/* reset interface to repopulate queues */
 		if (netif_running(netdev))
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4df921f8a48c..706995ff5e4b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6101,6 +6101,7 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter,
 		adapter->flags &= ~IXGBE_FLAG_DCA_CAPABLE;
 #endif
 		adapter->flags |= IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE;
+		adapter->flags |= IXGBE_FLAG_MDD_ENABLED;
 		break;
 	default:
 		break;
@@ -7214,6 +7215,11 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 	netif_carrier_on(netdev);
 	ixgbe_check_vf_rate_limit(adapter);
 
+	/* Turn on malicious driver detection */
+	if ((adapter->num_vfs) && (hw->mac.ops.enable_mdd) &&
+	    (adapter->flags & IXGBE_FLAG_MDD_ENABLED))
+		hw->mac.ops.enable_mdd(hw);
+
 	/* enable transmits */
 	netif_tx_wake_all_queues(adapter->netdev);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index ca492876bd3d..df43c59210a9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -257,6 +257,10 @@ int ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
 	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
 		return 0;
 
+	/* Turn off malicious driver detection */
+	if ((hw->mac.ops.disable_mdd) &&
+	    (!(adapter->flags & IXGBE_FLAG_MDD_ENABLED)))
+		hw->mac.ops.disable_mdd(hw);
 #ifdef CONFIG_PCI_IOV
 	/*
 	 * If our VFs are assigned we cannot shut down SR-IOV
@@ -1294,11 +1298,57 @@ static void ixgbe_rcv_ack_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 		ixgbe_write_mbx(hw, &msg, 1, vf);
 }
 
+static void ixgbe_check_mdd_event(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 vf_bitmap[IXGBE_MDD_Q_BITMAP_DEPTH] = { 0 };
+	u32 j, i;
+	u32 ping;
+
+	if (!hw->mac.ops.mdd_event)
+		return;
+
+	/* Did we have a malicious event */
+	hw->mac.ops.mdd_event(hw, vf_bitmap);
+
+	/* Log any blocked queues and release lock */
+	for (i = 0; i < IXGBE_MDD_Q_BITMAP_DEPTH; i++) {
+		for (j = 0; j < 32 && vf_bitmap[i]; j++) {
+			u32 vf;
+
+			if (!(vf_bitmap[i] & (1 << j)))
+				continue;
+
+			/* The VF that malicious event occurred on */
+			vf = j + (i * 32);
+
+			dev_warn(&adapter->pdev->dev,
+				 "Malicious event on VF %d tx:%x rx:%x\n", vf,
+				 IXGBE_READ_REG(hw, IXGBE_LVMMC_TX),
+				 IXGBE_READ_REG(hw, IXGBE_LVMMC_RX));
+
+			/* restart the vf */
+			if (hw->mac.ops.restore_mdd_vf) {
+				hw->mac.ops.restore_mdd_vf(hw, vf);
+
+				/* get the VF to rebuild its queues */
+				adapter->vfinfo[vf].clear_to_send = 0;
+				ping = IXGBE_PF_CONTROL_MSG |
+				       IXGBE_VT_MSGTYPE_CTS;
+				ixgbe_write_mbx(hw, &ping, 1, vf);
+			}
+		}
+	}
+}
+
 void ixgbe_msg_task(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 vf;
 
+	if (adapter->flags & IXGBE_FLAG_MDD_ENABLED && adapter->vfinfo)
+		ixgbe_check_mdd_event(adapter);
+
 	for (vf = 0; vf < adapter->num_vfs; vf++) {
 		/* process any reset requests */
 		if (!ixgbe_check_for_rst(hw, vf))
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index ffa0ee5cd0f5..9c2f851ab3bd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -380,6 +380,8 @@ struct ixgbe_thermal_sensor_data {
 #define IXGBE_MRCTL(_i)      (0x0F600 + ((_i) * 4))
 #define IXGBE_VMRVLAN(_i)    (0x0F610 + ((_i) * 4))
 #define IXGBE_VMRVM(_i)      (0x0F630 + ((_i) * 4))
+#define IXGBE_LVMMC_RX		0x2FA8
+#define IXGBE_LVMMC_TX		0x8108
 #define IXGBE_WQBR_RX(_i)    (0x2FB0 + ((_i) * 4)) /* 4 total */
 #define IXGBE_WQBR_TX(_i)    (0x8130 + ((_i) * 4)) /* 4 total */
 #define IXGBE_L34T_IMIR(_i)  (0x0E800 + ((_i) * 4)) /*128 of these (0-127)*/
@@ -3462,6 +3464,12 @@ struct ixgbe_mac_operations {
 	s32 (*dmac_config_tcs)(struct ixgbe_hw *hw);
 	s32 (*read_iosf_sb_reg)(struct ixgbe_hw *, u32, u32, u32 *);
 	s32 (*write_iosf_sb_reg)(struct ixgbe_hw *, u32, u32, u32);
+
+	/* Malicious driver detection */
+	void (*disable_mdd)(struct ixgbe_hw *hw);
+	void (*enable_mdd)(struct ixgbe_hw *hw);
+	void (*mdd_event)(struct ixgbe_hw *hw, u32 *vf_bitmap);
+	void (*restore_mdd_vf)(struct ixgbe_hw *hw, u32 vf);
 };
 
 struct ixgbe_phy_operations {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 19fbb2f28ea4..323616fba9ea 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -3533,6 +3533,140 @@ static void ixgbe_set_source_address_pruning_X550(struct ixgbe_hw *hw,
 }
 
 /**
+ *  ixgbe_disable_mdd_X550
+ *  @hw: pointer to hardware structure
+ *
+ *  Disable malicious driver detection
+ **/
+static void ixgbe_disable_mdd_X550(struct ixgbe_hw *hw)
+{
+	u32 reg;
+
+	/* Disable MDD for TX DMA and interrupt */
+	reg = IXGBE_READ_REG(hw, IXGBE_DMATXCTL);
+	reg &= ~(IXGBE_DMATXCTL_MDP_EN | IXGBE_DMATXCTL_MBINTEN);
+	IXGBE_WRITE_REG(hw, IXGBE_DMATXCTL, reg);
+
+	/* Disable MDD for RX and interrupt */
+	reg = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
+	reg &= ~(IXGBE_RDRXCTL_MDP_EN | IXGBE_RDRXCTL_MBINTEN);
+	IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, reg);
+}
+
+/**
+ *  ixgbe_enable_mdd_X550
+ *  @hw: pointer to hardware structure
+ *
+ *  Enable malicious driver detection
+ **/
+static void ixgbe_enable_mdd_X550(struct ixgbe_hw *hw)
+{
+	u32 reg;
+
+	/* Enable MDD for TX DMA and interrupt */
+	reg = IXGBE_READ_REG(hw, IXGBE_DMATXCTL);
+	reg |= (IXGBE_DMATXCTL_MDP_EN | IXGBE_DMATXCTL_MBINTEN);
+	IXGBE_WRITE_REG(hw, IXGBE_DMATXCTL, reg);
+
+	/* Enable MDD for RX and interrupt */
+	reg = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
+	reg |= (IXGBE_RDRXCTL_MDP_EN | IXGBE_RDRXCTL_MBINTEN);
+	IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, reg);
+}
+
+/**
+ *  ixgbe_restore_mdd_vf_X550
+ *  @hw: pointer to hardware structure
+ *  @vf: vf index
+ *
+ *  Restore VF that was disabled during malicious driver detection event
+ **/
+static void ixgbe_restore_mdd_vf_X550(struct ixgbe_hw *hw, u32 vf)
+{
+	u32 idx, reg, num_qs, start_q, bitmask;
+
+	/* Map VF to queues */
+	reg = IXGBE_READ_REG(hw, IXGBE_MRQC);
+	switch (reg & IXGBE_MRQC_MRQE_MASK) {
+	case IXGBE_MRQC_VMDQRT8TCEN:
+		num_qs = 8;  /* 16 VFs / pools */
+		bitmask = 0x000000FF;
+		break;
+	case IXGBE_MRQC_VMDQRSS32EN:
+	case IXGBE_MRQC_VMDQRT4TCEN:
+		num_qs = 4;  /* 32 VFs / pools */
+		bitmask = 0x0000000F;
+		break;
+	default:            /* 64 VFs / pools */
+		num_qs = 2;
+		bitmask = 0x00000003;
+		break;
+	}
+	start_q = vf * num_qs;
+
+	/* Release vf's queues by clearing WQBR_TX and WQBR_RX (RW1C) */
+	idx = start_q / 32;
+	reg = 0;
+	reg |= (bitmask << (start_q % 32));
+	IXGBE_WRITE_REG(hw, IXGBE_WQBR_TX(idx), reg);
+	IXGBE_WRITE_REG(hw, IXGBE_WQBR_RX(idx), reg);
+}
+
+/**
+ *  ixgbe_mdd_event_X550
+ *  @hw: pointer to hardware structure
+ *  @vf_bitmap: vf bitmap of malicious vfs
+ *
+ *  Handle malicious driver detection event.
+ **/
+static void ixgbe_mdd_event_X550(struct ixgbe_hw *hw, u32 *vf_bitmap)
+{
+	u32 wqbr;
+	u32 i, j, reg, q, shift, vf, idx;
+
+	/* figure out pool size for mapping to vf's */
+	reg = IXGBE_READ_REG(hw, IXGBE_MRQC);
+	switch (reg & IXGBE_MRQC_MRQE_MASK) {
+	case IXGBE_MRQC_VMDQRT8TCEN:
+		shift = 3;  /* 16 VFs / pools */
+		break;
+	case IXGBE_MRQC_VMDQRSS32EN:
+	case IXGBE_MRQC_VMDQRT4TCEN:
+		shift = 2;  /* 32 VFs / pools */
+		break;
+	default:
+		shift = 1;  /* 64 VFs / pools */
+		break;
+	}
+
+	/* Read WQBR_TX and WQBR_RX and check for malicious queues */
+	for (i = 0; i < 4; i++) {
+		wqbr = IXGBE_READ_REG(hw, IXGBE_WQBR_TX(i));
+		wqbr |= IXGBE_READ_REG(hw, IXGBE_WQBR_RX(i));
+
+		if (!wqbr)
+			continue;
+
+		/* Get malicious queue */
+		for (j = 0; j < 32 && wqbr; j++) {
+			if (!(wqbr & (1 << j)))
+				continue;
+
+			/* Get queue from bitmask */
+			q = j + (i * 32);
+
+			/* Map queue to vf */
+			vf = (q >> shift);
+
+			/* Set vf bit in vf_bitmap */
+			idx = vf / 32;
+			vf_bitmap[idx] |= (1 << (vf % 32));
+			wqbr &= ~(1 << j);
+		}
+	}
+}
+
+/**
  *  ixgbe_setup_fc_backplane_x550em_a - Set up flow control
  *  @hw: pointer to hardware structure
  *
@@ -3817,6 +3951,10 @@ static s32 ixgbe_write_phy_reg_x550a(struct ixgbe_hw *hw, u32 reg_addr,
 	.init_thermal_sensor_thresh	= NULL, \
 	.enable_rx			= &ixgbe_enable_rx_generic, \
 	.disable_rx			= &ixgbe_disable_rx_x550, \
+	.enable_mdd			= &ixgbe_enable_mdd_X550, \
+	.disable_mdd			= &ixgbe_disable_mdd_X550, \
+	.mdd_event			= &ixgbe_mdd_event_X550, \
+	.restore_mdd_vf			= &ixgbe_restore_mdd_vf_X550, \
 
 static const struct ixgbe_mac_operations mac_ops_X550 = {
 	X550_COMMON_MAC
-- 
2.12.2
