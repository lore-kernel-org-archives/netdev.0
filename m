From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 02/10] atl1c: add PHY link event(up/down) patch
Date: Tue, 1 May 2012 09:38:50 +0800
Message-ID: <1335836338-9425-3-git-send-email-xiong@qca.qualcomm.com>
References: <1335836338-9425-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335836338-9425-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On some platforms the PHY settings need to change depending on the
cable link status to get better stability.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h      |    1 +
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c   |   37 ++++++++++++++++
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |    1 +
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   53 +++++++++++++++++++++++
 4 files changed, 92 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index acc2956..b2bf324 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -436,6 +436,7 @@ struct atl1c_hw {
 	bool phy_configured;
 	bool re_autoneg;
 	bool emi_ca;
+	bool msi_lnkpatch;	/* link patch for specific platforms */
 };
 
 /*
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
index 07f017f..209c179 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
@@ -848,3 +848,40 @@ int atl1c_power_saving(struct atl1c_hw *hw, u32 wufc)
 
 	return 0;
 }
+
+
+/* configure phy after Link change Event */
+void atl1c_post_phy_linkchg(struct atl1c_hw *hw, u16 link_speed)
+{
+	u16 phy_val;
+	bool adj_thresh = false;
+
+	if (hw->nic_type == athr_l2c_b || hw->nic_type == athr_l2c_b2 ||
+	    hw->nic_type == athr_l1d || hw->nic_type == athr_l1d_2)
+		adj_thresh = true;
+
+	if (link_speed != SPEED_0) { /* link up */
+		/* az with brcm, half-amp */
+		if (hw->nic_type == athr_l1d_2) {
+			atl1c_read_phy_ext(hw, MIIEXT_PCS, MIIEXT_CLDCTRL6,
+				&phy_val);
+			phy_val = FIELD_GETX(phy_val, CLDCTRL6_CAB_LEN);
+			phy_val = phy_val > CLDCTRL6_CAB_LEN_SHORT ?
+				AZ_ANADECT_LONG : AZ_ANADECT_DEF;
+			atl1c_write_phy_dbg(hw, MIIDBG_AZ_ANADECT, phy_val);
+		}
+		/* threshold adjust */
+		if (adj_thresh && link_speed == SPEED_100 && hw->msi_lnkpatch) {
+			atl1c_write_phy_dbg(hw, MIIDBG_MSE16DB, L1D_MSE16DB_UP);
+			atl1c_write_phy_dbg(hw, MIIDBG_SYSMODCTRL,
+				L1D_SYSMODCTRL_IECHOADJ_DEF);
+		}
+	} else { /* link down */
+		if (adj_thresh && hw->msi_lnkpatch) {
+			atl1c_write_phy_dbg(hw, MIIDBG_SYSMODCTRL,
+				SYSMODCTRL_IECHOADJ_DEF);
+			atl1c_write_phy_dbg(hw, MIIDBG_MSE16DB,
+				L1D_MSE16DB_DOWN);
+		}
+	}
+}
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index 0adb341..ea3f520 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -63,6 +63,7 @@ int atl1c_write_phy_ext(struct atl1c_hw *hw, u8 dev_addr,
 			u16 reg_addr, u16 phy_data);
 int atl1c_read_phy_dbg(struct atl1c_hw *hw, u16 reg_addr, u16 *phy_data);
 int atl1c_write_phy_dbg(struct atl1c_hw *hw, u16 reg_addr, u16 phy_data);
+void atl1c_post_phy_linkchg(struct atl1c_hw *hw, u16 link_speed);
 
 /* hw-ids */
 #define PCI_DEVICE_ID_ATTANSIC_L2C      0x1062
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 25b7b00..6d5b374 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -258,6 +258,7 @@ static void atl1c_check_link_status(struct atl1c_adapter *adapter)
 			if (netif_msg_hw(adapter))
 				dev_warn(&pdev->dev, "stop mac failed\n");
 		atl1c_set_aspm(hw, SPEED_0);
+		atl1c_post_phy_linkchg(hw, SPEED_0);
 		netif_carrier_off(netdev);
 		netif_stop_queue(netdev);
 	} else {
@@ -274,6 +275,7 @@ static void atl1c_check_link_status(struct atl1c_adapter *adapter)
 			adapter->link_speed  = speed;
 			adapter->link_duplex = duplex;
 			atl1c_set_aspm(hw, speed);
+			atl1c_post_phy_linkchg(hw, speed);
 			atl1c_start_mac(adapter);
 			if (netif_msg_link(adapter))
 				dev_info(&pdev->dev,
@@ -697,6 +699,55 @@ static int atl1c_setup_mac_funcs(struct atl1c_hw *hw)
 		hw->link_cap_flags |= ATL1C_LINK_CAP_1000M;
 	return 0;
 }
+
+struct atl1c_platform_patch {
+	u16 pci_did;
+	u8  pci_revid;
+	u16 subsystem_vid;
+	u16 subsystem_did;
+	u32 patch_flag;
+#define ATL1C_LINK_PATCH	0x1
+};
+static const struct atl1c_platform_patch plats[] __devinitdata = {
+{0x2060, 0xC1, 0x1019, 0x8152, 0x1},
+{0x2060, 0xC1, 0x1019, 0x2060, 0x1},
+{0x2060, 0xC1, 0x1019, 0xE000, 0x1},
+{0x2062, 0xC0, 0x1019, 0x8152, 0x1},
+{0x2062, 0xC0, 0x1019, 0x2062, 0x1},
+{0x2062, 0xC0, 0x1458, 0xE000, 0x1},
+{0x2062, 0xC1, 0x1019, 0x8152, 0x1},
+{0x2062, 0xC1, 0x1019, 0x2062, 0x1},
+{0x2062, 0xC1, 0x1458, 0xE000, 0x1},
+{0x2062, 0xC1, 0x1565, 0x2802, 0x1},
+{0x2062, 0xC1, 0x1565, 0x2801, 0x1},
+{0x1073, 0xC0, 0x1019, 0x8151, 0x1},
+{0x1073, 0xC0, 0x1019, 0x1073, 0x1},
+{0x1073, 0xC0, 0x1458, 0xE000, 0x1},
+{0x1083, 0xC0, 0x1458, 0xE000, 0x1},
+{0x1083, 0xC0, 0x1019, 0x8151, 0x1},
+{0x1083, 0xC0, 0x1019, 0x1083, 0x1},
+{0x1083, 0xC0, 0x1462, 0x7680, 0x1},
+{0x1083, 0xC0, 0x1565, 0x2803, 0x1},
+{0},
+};
+
+static void __devinit atl1c_patch_assign(struct atl1c_hw *hw)
+{
+	int i = 0;
+
+	hw->msi_lnkpatch = false;
+
+	while (plats[i].pci_did != 0) {
+		if (plats[i].pci_did == hw->device_id &&
+		    plats[i].pci_revid == hw->revision_id &&
+		    plats[i].subsystem_vid == hw->subsystem_vendor_id &&
+		    plats[i].subsystem_did == hw->subsystem_id) {
+			if (plats[i].patch_flag & ATL1C_LINK_PATCH)
+				hw->msi_lnkpatch = true;
+		}
+		i++;
+	}
+}
 /*
  * atl1c_sw_init - Initialize general software structures (struct atl1c_adapter)
  * @adapter: board private structure to initialize
@@ -732,6 +783,8 @@ static int __devinit atl1c_sw_init(struct atl1c_adapter *adapter)
 		dev_err(&pdev->dev, "set mac function pointers failed\n");
 		return -1;
 	}
+	atl1c_patch_assign(hw);
+
 	hw->intr_mask = IMR_NORMAL_MASK;
 	hw->phy_configured = false;
 	hw->preamble_len = 7;
-- 
1.7.7
