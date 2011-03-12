From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 03/21] igb: Add Energy Efficient Ethernet (EEE) for i350 devices.
Date: Sat, 12 Mar 2011 04:20:10 -0800
Message-ID: <1299932428-3114-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39426 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753514Ab1CLMUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:37 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds the EEE feature for i350 devices, enabled by default.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/e1000_82575.c   |   46 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/igb/e1000_82575.h   |    1 +
 drivers/net/igb/e1000_defines.h |    7 ++++++
 drivers/net/igb/e1000_hw.h      |    1 +
 drivers/net/igb/e1000_regs.h    |    4 +++
 drivers/net/igb/igb_main.c      |    8 ++++++-
 6 files changed, 65 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 65c1833..20d172a 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -195,7 +195,11 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	mac->arc_subsystem_valid =
 		(rd32(E1000_FWSM) & E1000_FWSM_MODE_MASK)
 			? true : false;
-
+	/* enable EEE on i350 parts */
+	if (mac->type == e1000_i350)
+		dev_spec->eee_disable = false;
+	else
+		dev_spec->eee_disable = true;
 	/* physical interface link setup */
 	mac->ops.setup_physical_interface =
 		(hw->phy.media_type == e1000_media_type_copper)
@@ -1754,6 +1758,46 @@ u16 igb_rxpbs_adjust_82580(u32 data)
 	return ret_val;
 }
 
+/**
+ *  igb_set_eee_i350 - Enable/disable EEE support
+ *  @hw: pointer to the HW structure
+ *
+ *  Enable/disable EEE based on setting in dev_spec structure.
+ *
+ **/
+s32 igb_set_eee_i350(struct e1000_hw *hw)
+{
+	s32 ret_val = 0;
+	u32 ipcnfg, eeer, ctrl_ext;
+
+	ctrl_ext = rd32(E1000_CTRL_EXT);
+	if ((hw->mac.type != e1000_i350) ||
+	    (ctrl_ext & E1000_CTRL_EXT_LINK_MODE_MASK))
+		goto out;
+	ipcnfg = rd32(E1000_IPCNFG);
+	eeer = rd32(E1000_EEER);
+
+	/* enable or disable per user setting */
+	if (!(hw->dev_spec._82575.eee_disable)) {
+		ipcnfg |= (E1000_IPCNFG_EEE_1G_AN |
+			E1000_IPCNFG_EEE_100M_AN);
+		eeer |= (E1000_EEER_TX_LPI_EN |
+			E1000_EEER_RX_LPI_EN |
+			E1000_EEER_LPI_FC);
+
+	} else {
+		ipcnfg &= ~(E1000_IPCNFG_EEE_1G_AN |
+			E1000_IPCNFG_EEE_100M_AN);
+		eeer &= ~(E1000_EEER_TX_LPI_EN |
+			E1000_EEER_RX_LPI_EN |
+			E1000_EEER_LPI_FC);
+	}
+	wr32(E1000_IPCNFG, ipcnfg);
+	wr32(E1000_EEER, eeer);
+out:
+
+	return ret_val;
+}
 static struct e1000_mac_operations e1000_mac_ops_82575 = {
 	.init_hw              = igb_init_hw_82575,
 	.check_for_link       = igb_check_for_link_82575,
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index 1d01af2..dd6df34 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -251,5 +251,6 @@ void igb_vmdq_set_anti_spoofing_pf(struct e1000_hw *, bool, int);
 void igb_vmdq_set_loopback_pf(struct e1000_hw *, bool);
 void igb_vmdq_set_replication_pf(struct e1000_hw *, bool);
 u16 igb_rxpbs_adjust_82580(u32 data);
+s32 igb_set_eee_i350(struct e1000_hw *);
 
 #endif
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 92e11da..7926781 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -758,6 +758,13 @@
 #define E1000_MDIC_ERROR     0x40000000
 #define E1000_MDIC_DEST      0x80000000
 
+/* Energy Efficient Ethernet */
+#define E1000_IPCNFG_EEE_1G_AN       0x00000008  /* EEE Enable 1G AN */
+#define E1000_IPCNFG_EEE_100M_AN     0x00000004  /* EEE Enable 100M AN */
+#define E1000_EEER_TX_LPI_EN         0x00010000  /* EEE Tx LPI Enable */
+#define E1000_EEER_RX_LPI_EN         0x00020000  /* EEE Rx LPI Enable */
+#define E1000_EEER_LPI_FC            0x00040000  /* EEE Enable on FC */
+
 /* SerDes Control */
 #define E1000_GEN_CTL_READY             0x80000000
 #define E1000_GEN_CTL_ADDRESS_SHIFT     8
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index eec9ed7..17569bf 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -488,6 +488,7 @@ struct e1000_mbx_info {
 struct e1000_dev_spec_82575 {
 	bool sgmii_active;
 	bool global_device_reset;
+	bool eee_disable;
 };
 
 struct e1000_hw {
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 6171354..b2f8e59 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -329,6 +329,10 @@
 /* DMA Coalescing registers */
 #define E1000_PCIEMISC          0x05BB8 /* PCIE misc config register */
 
+/* Energy Efficient Ethernet "EEE" register */
+#define E1000_IPCNFG  0x0E38  /* Internal PHY Configuration */
+#define E1000_EEER    0x0E30  /* Energy Efficient Ethernet */
+
 /* OS2BMC Registers */
 #define E1000_B2OSPC    0x08FE0 /* BMC2OS packets sent by BMC */
 #define E1000_B2OGPRC   0x04158 /* BMC2OS packets received by host */
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3666b96..8643f8c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2014,7 +2014,13 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		adapter->msix_entries ? "MSI-X" :
 		(adapter->flags & IGB_FLAG_HAS_MSI) ? "MSI" : "legacy",
 		adapter->num_rx_queues, adapter->num_tx_queues);
-
+	switch (hw->mac.type) {
+	case e1000_i350:
+		igb_set_eee_i350(hw);
+		break;
+	default:
+		break;
+	}
 	return 0;
 
 err_register:
-- 
1.7.4

