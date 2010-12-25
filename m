From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 14/15] ixgbe: Add anti-spoofing feature support
Date: Fri, 24 Dec 2010 22:06:13 -0800
Message-ID: <1293257174-15498-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752388Ab0LYGHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:07:16 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Add support for the anti-spoofing feature in the HW.  Packets from
VF devices with spoofed MAC addresses or VLAN tags will be blocked
and a counter incremented.  During the watchdog timer the spoofed
packet dropped counter is read and if it is non-zero then a warning
message is displayed on the host VMM's console.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82599.c  |    2 +
 drivers/net/ixgbe/ixgbe_common.c |   64 ++++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_common.h |    2 +
 drivers/net/ixgbe/ixgbe_main.c   |   24 ++++++++++++++
 drivers/net/ixgbe/ixgbe_sriov.c  |   12 ++++++-
 drivers/net/ixgbe/ixgbe_type.h   |   13 +++++++-
 6 files changed, 114 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 6827ddd..bfd3c22 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -2165,6 +2165,8 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.fc_enable              = &ixgbe_fc_enable_generic,
 	.init_uta_tables        = &ixgbe_init_uta_tables_generic,
 	.setup_sfp              = &ixgbe_setup_sfp_modules_82599,
+	.set_mac_anti_spoofing  = &ixgbe_set_mac_anti_spoofing,
+	.set_vlan_anti_spoofing = &ixgbe_set_vlan_anti_spoofing,
 };
 
 static struct ixgbe_eeprom_operations eeprom_ops_82599 = {
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index cc11e42..d5ede2d 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -2809,3 +2809,67 @@ s32 ixgbe_get_wwn_prefix_generic(struct ixgbe_hw *hw, u16 *wwnn_prefix,
 wwn_prefix_out:
 	return 0;
 }
+
+/**
+ *  ixgbe_set_mac_anti_spoofing - Enable/Disable MAC anti-spoofing
+ *  @hw: pointer to hardware structure
+ *  @enable: enable or disable switch for anti-spoofing
+ *  @pf: Physical Function pool - do not enable anti-spoofing for the PF
+ *
+ **/
+void ixgbe_set_mac_anti_spoofing(struct ixgbe_hw *hw, bool enable, int pf)
+{
+	int j;
+	int pf_target_reg = pf >> 3;
+	int pf_target_shift = pf % 8;
+	u32 pfvfspoof = 0;
+
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		return;
+
+	if (enable)
+		pfvfspoof = IXGBE_SPOOF_MACAS_MASK;
+
+	/*
+	 * PFVFSPOOF register array is size 8 with 8 bits assigned to
+	 * MAC anti-spoof enables in each register array element.
+	 */
+	for (j = 0; j < IXGBE_PFVFSPOOF_REG_COUNT; j++)
+		IXGBE_WRITE_REG(hw, IXGBE_PFVFSPOOF(j), pfvfspoof);
+
+	/* If not enabling anti-spoofing then done */
+	if (!enable)
+		return;
+
+	/*
+	 * The PF should be allowed to spoof so that it can support
+	 * emulation mode NICs.  Reset the bit assigned to the PF
+	 */
+	pfvfspoof = IXGBE_READ_REG(hw, IXGBE_PFVFSPOOF(pf_target_reg));
+	pfvfspoof ^= (1 << pf_target_shift);
+	IXGBE_WRITE_REG(hw, IXGBE_PFVFSPOOF(pf_target_reg), pfvfspoof);
+}
+
+/**
+ *  ixgbe_set_vlan_anti_spoofing - Enable/Disable VLAN anti-spoofing
+ *  @hw: pointer to hardware structure
+ *  @enable: enable or disable switch for VLAN anti-spoofing
+ *  @pf: Virtual Function pool - VF Pool to set for VLAN anti-spoofing
+ *
+ **/
+void ixgbe_set_vlan_anti_spoofing(struct ixgbe_hw *hw, bool enable, int vf)
+{
+	int vf_target_reg = vf >> 3;
+	int vf_target_shift = vf % 8 + IXGBE_SPOOF_VLANAS_SHIFT;
+	u32 pfvfspoof;
+
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		return;
+
+	pfvfspoof = IXGBE_READ_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg));
+	if (enable)
+		pfvfspoof |= (1 << vf_target_shift);
+	else
+		pfvfspoof &= ~(1 << vf_target_shift);
+	IXGBE_WRITE_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg), pfvfspoof);
+}
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index e1f980a..66ed045 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -88,6 +88,8 @@ s32 ixgbe_get_wwn_prefix_generic(struct ixgbe_hw *hw, u16 *wwnn_prefix,
                                  u16 *wwpn_prefix);
 s32 ixgbe_blink_led_start_generic(struct ixgbe_hw *hw, u32 index);
 s32 ixgbe_blink_led_stop_generic(struct ixgbe_hw *hw, u32 index);
+void ixgbe_set_mac_anti_spoofing(struct ixgbe_hw *hw, bool enable, int pf);
+void ixgbe_set_vlan_anti_spoofing(struct ixgbe_hw *hw, bool enable, int vf);
 
 #define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c905625..38ab4f3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3132,6 +3132,9 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 
 	/* enable Tx loopback for VF/PF communication */
 	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
+	/* Enable MAC Anti-Spoofing */
+	hw->mac.ops.set_mac_anti_spoofing(hw, (adapter->num_vfs != 0),
+					  adapter->num_vfs);
 }
 
 static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
@@ -5960,6 +5963,26 @@ static void ixgbe_fdir_reinit_task(struct work_struct *work)
 	netif_tx_start_all_queues(adapter->netdev);
 }
 
+static void ixgbe_spoof_check(struct ixgbe_adapter *adapter)
+{
+	u32 ssvpc;
+
+	/* Do not perform spoof check for 82598 */
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+		return;
+
+	ssvpc = IXGBE_READ_REG(&adapter->hw, IXGBE_SSVPC);
+
+	/*
+	 * ssvpc register is cleared on read, if zero then no
+	 * spoofed packets in the last interval.
+	 */
+	if (!ssvpc)
+		return;
+
+	e_warn(drv, "%d Spoofed packets detected\n", ssvpc);
+}
+
 static DEFINE_MUTEX(ixgbe_watchdog_lock);
 
 /**
@@ -6080,6 +6103,7 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 		}
 	}
 
+	ixgbe_spoof_check(adapter);
 	ixgbe_update_stats(adapter);
 	mutex_unlock(&ixgbe_watchdog_lock);
 }
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index e01d0db..47b1573 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -215,6 +215,11 @@ static inline void ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
 	reg |= (reg | (1 << vf_shift));
 	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), reg);
 
+	/* Enable counting of spoofed packets in the SSVPC register */
+	reg = IXGBE_READ_REG(hw, IXGBE_VMECM(reg_offset));
+	reg |= (1 << vf_shift);
+	IXGBE_WRITE_REG(hw, IXGBE_VMECM(reg_offset), reg);
+
 	ixgbe_vf_reset_event(adapter, vf);
 }
 
@@ -412,6 +417,7 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 {
 	int err = 0;
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 
 	if ((vf >= adapter->num_vfs) || (vlan > 4095) || (qos > 7))
 		return -EINVAL;
@@ -420,7 +426,8 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 		if (err)
 			goto out;
 		ixgbe_set_vmvir(adapter, vlan | (qos << VLAN_PRIO_SHIFT), vf);
-		ixgbe_set_vmolr(&adapter->hw, vf, false);
+		ixgbe_set_vmolr(hw, vf, false);
+		hw->mac.ops.set_vlan_anti_spoofing(hw, true, vf);
 		adapter->vfinfo[vf].pf_vlan = vlan;
 		adapter->vfinfo[vf].pf_qos = qos;
 		dev_info(&adapter->pdev->dev,
@@ -437,7 +444,8 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 		err = ixgbe_set_vf_vlan(adapter, false,
 					adapter->vfinfo[vf].pf_vlan, vf);
 		ixgbe_set_vmvir(adapter, vlan, vf);
-		ixgbe_set_vmolr(&adapter->hw, vf, true);
+		ixgbe_set_vmolr(hw, vf, true);
+		hw->mac.ops.set_vlan_anti_spoofing(hw, false, vf);
 		adapter->vfinfo[vf].pf_vlan = 0;
 		adapter->vfinfo[vf].pf_qos = 0;
        }
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 59f6d0a..446f3467 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -230,6 +230,7 @@
 #define IXGBE_VT_CTL    0x051B0
 #define IXGBE_VFRE(_i)  (0x051E0 + ((_i) * 4))
 #define IXGBE_VFTE(_i)  (0x08110 + ((_i) * 4))
+#define IXGBE_VMECM(_i) (0x08790 + ((_i) * 4))
 #define IXGBE_QDE       0x2F04
 #define IXGBE_VMOLR(_i) (0x0F000 + ((_i) * 4)) /* 64 total */
 #define IXGBE_UTA(_i)   (0x0F400 + ((_i) * 4))
@@ -284,7 +285,8 @@
 #define IXGBE_TDWBAH(_i) (0x0603C + ((_i) * 0x40))
 #define IXGBE_DTXCTL    0x07E00
 
-#define IXGBE_DMATXCTL  0x04A80
+#define IXGBE_DMATXCTL      0x04A80
+#define IXGBE_PFVFSPOOF(_i) (0x08200 + ((_i) * 4)) /* 8 of these 0 - 7 */
 #define IXGBE_PFDTXGSWC     0x08220
 #define IXGBE_DTXMXSZRQ     0x08100
 #define IXGBE_DTXTCPFLGL    0x04A88
@@ -298,6 +300,13 @@
 #define IXGBE_DMATXCTL_VT_SHIFT 16  /* VLAN EtherType */
 
 #define IXGBE_PFDTXGSWC_VT_LBEN 0x1 /* Local L2 VT switch enable */
+
+/* Anti-spoofing defines */
+#define IXGBE_SPOOF_MACAS_MASK          0xFF
+#define IXGBE_SPOOF_VLANAS_MASK         0xFF00
+#define IXGBE_SPOOF_VLANAS_SHIFT        8
+#define IXGBE_PFVFSPOOF_REG_COUNT       8
+
 #define IXGBE_DCA_TXCTRL(_i)    (0x07200 + ((_i) * 4)) /* 16 of these (0-15) */
 /* Tx DCA Control register : 128 of these (0-127) */
 #define IXGBE_DCA_TXCTRL_82599(_i)  (0x0600C + ((_i) * 0x40))
@@ -2482,6 +2491,8 @@ struct ixgbe_mac_operations {
 	s32 (*clear_vfta)(struct ixgbe_hw *);
 	s32 (*set_vfta)(struct ixgbe_hw *, u32, u32, bool);
 	s32 (*init_uta_tables)(struct ixgbe_hw *);
+	void (*set_mac_anti_spoofing)(struct ixgbe_hw *, bool, int);
+	void (*set_vlan_anti_spoofing)(struct ixgbe_hw *, bool, int);
 
 	/* Flow Control */
 	s32 (*fc_enable)(struct ixgbe_hw *, s32);
-- 
1.7.3.4

