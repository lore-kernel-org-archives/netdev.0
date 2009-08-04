From: <jie.yang@atheros.com>
Subject: [PATCH]atl1c:update version from 1.0.0.0 to 1.0.1.0
Date: Tue, 4 Aug 2009 16:07:24 +0800
Message-ID: <12493732442221-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Angus.Huang@atheros.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, jie yang <jie.yang@atheros.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932664AbZHDIIh@vger.kernel.org>
Received: from mail.atheros.com ([10.10.20.108])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 01:08:34 -0700
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. update atl1c_suspend routine, just set speed to 10M Full when
   in suspend for power saving.
2. change atl1c_set_aspm routine for power saving.
3. add atl1c_pcie_patch routine just for refactoring.
4. update version to 1.0.1.0-NAPI.

Signed-off-by: jie yang <jie.yang@atheros.com>
---

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index 2a1120a..d838962 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -91,6 +91,7 @@
 
 #define AT_ASPM_L0S_TIMER  6
 #define AT_ASPM_L1_TIMER   12
+#define AT_LCKDET_TIMER         12
 
 #define ATL1C_PCIE_L0S_L1_DISABLE  0x01
 #define ATL1C_PCIE_PHY_RESET       0x02
diff --git a/drivers/net/atl1c/atl1c_hw.h b/drivers/net/atl1c/atl1c_hw.h
index c2c738d..58b58b4 100644
--- a/drivers/net/atl1c/atl1c_hw.h
+++ b/drivers/net/atl1c/atl1c_hw.h
@@ -149,13 +149,15 @@ int atl1c_restart_autoneg(struct atl1c_hw *hw);
 #define PM_CTRL_ASPM_L0S_EN        0x00001000
 #define PM_CTRL_CLK_SWH_L1     0x00002000
 #define PM_CTRL_CLK_PWM_VER1_1     0x00004000
-#define PM_CTRL_PCIE_RECV      0x00008000
+#define PM_CTRL_RCVR_WT_TIMER      0x00008000
 #define PM_CTRL_L1_ENTRY_TIMER_MASK    0xF
 #define PM_CTRL_L1_ENTRY_TIMER_SHIFT   16
 #define PM_CTRL_PM_REQ_TIMER_MASK  0xF
 #define PM_CTRL_PM_REQ_TIMER_SHIFT 20
-#define PM_CTRL_LCKDET_TIMER_MASK  0x3F
+#define PM_CTRL_LCKDET_TIMER_MASK  0xF
 #define PM_CTRL_LCKDET_TIMER_SHIFT 24
+#define PM_CTRL_EN_BUFS_RX_L0S     0x10000000
+#define PM_CTRL_SA_DLY_EN      0x20000000
 #define PM_CTRL_MAC_ASPM_CHK       0x40000000
 #define PM_CTRL_HOTRST         0x80000000
 
@@ -165,6 +167,7 @@ int atl1c_restart_autoneg(struct atl1c_hw *hw);
 #define MASTER_CTRL_TEST_MODE_MASK 0x3
 #define MASTER_CTRL_TEST_MODE_SHIFT    2
 #define MASTER_CTRL_BERT_START     0x10
+#define MASTER_CTRL_SA_TIMER_EN        0x80
 #define MASTER_CTRL_MTIMER_EN           0x100
 #define MASTER_CTRL_MANUAL_INT          0x200
 #define MASTER_CTRL_TX_ITIMER_EN   0x400
@@ -217,6 +220,12 @@ int atl1c_restart_autoneg(struct atl1c_hw *hw);
        GPHY_CTRL_PWDOWN_HW |\
        GPHY_CTRL_PHY_IDDQ)
 
+#define GPHY_CTRL_POWER_SAVING (   \
+       GPHY_CTRL_SEL_ANA_RST   |\
+       GPHY_CTRL_HIB_EN    |\
+       GPHY_CTRL_HIB_PULSE |\
+       GPHY_CTRL_PWDOWN_HW |\
+       GPHY_CTRL_PHY_IDDQ)
 /* Block IDLE Status Register */
 #define REG_IDLE_STATUS        0x1410
 #define IDLE_STATUS_MASK       0x00FF
@@ -284,6 +293,14 @@ int atl1c_restart_autoneg(struct atl1c_hw *hw);
 #define SERDES_LOCK_DETECT             0x1  /* SerDes lock detected. This signal
                          * comes from Analog SerDes */
 #define SERDES_LOCK_DETECT_EN          0x2  /* 1: Enable SerDes Lock detect function */
+#define SERDES_LOCK_STS_SELFB_PLL_SHIFT 0xE
+#define SERDES_LOCK_STS_SELFB_PLL_MASK  0x3
+#define SERDES_OVCLK_18_25     0x0
+#define SERDES_OVCLK_12_18     0x1
+#define SERDES_OVCLK_0_4       0x2
+#define SERDES_OVCLK_4_12      0x3
+#define SERDES_MAC_CLK_SLOWDOWN        0x20000
+#define SERDES_PYH_CLK_SLOWDOWN        0x40000
 
 /* MAC Control Register  */
 #define REG_MAC_CTRL               0x1480
@@ -688,6 +705,21 @@ int atl1c_restart_autoneg(struct atl1c_hw *hw);
 #define REG_MAC_TX_STATUS_BIN      0x1760
 #define REG_MAC_TX_STATUS_END      0x17c0
 
+#define REG_CLK_GATING_CTRL        0x1814
+#define CLK_GATING_DMAW_EN     0x0001
+#define CLK_GATING_DMAR_EN     0x0002
+#define CLK_GATING_TXQ_EN      0x0004
+#define CLK_GATING_RXQ_EN      0x0008
+#define CLK_GATING_TXMAC_EN        0x0010
+#define CLK_GATING_RXMAC_EN        0x0020
+
+#define CLK_GATING_EN_ALL  (CLK_GATING_DMAW_EN |\
+                CLK_GATING_DMAR_EN |\
+                CLK_GATING_TXQ_EN  |\
+                CLK_GATING_RXQ_EN  |\
+                CLK_GATING_TXMAC_EN|\
+                CLK_GATING_RXMAC_EN)
+
 /* DEBUG ADDR */
 #define REG_DEBUG_DATA0        0x1900
 #define REG_DEBUG_DATA1        0x1904
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 1d601ce..a3ed02a 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -21,7 +21,7 @@
 
 #include "atl1c.h"
 
-#define ATL1C_DRV_VERSION "1.0.0.1-NAPI"
+#define ATL1C_DRV_VERSION "1.0.1.0-NAPI"
 char atl1c_driver_name[] = "atl1c";
 char atl1c_driver_version[] = ATL1C_DRV_VERSION;
 #define PCI_DEVICE_ID_ATTANSIC_L2C      0x1062
@@ -85,6 +85,15 @@ static const u16 atl1c_rrd_addr_lo_regs[AT_MAX_RECEIVE_QUEUE] =
    REG_RRD3_HEAD_ADDR_LO
 };
 
+static void atl1c_pcie_patch(struct atl1c_hw *hw)
+{
+   u32 data;
+
+   AT_READ_REG(hw, REG_PCIE_PHYMISC, &data);
+   data |= PCIE_PHYMISC_FORCE_RCV_DET;
+   AT_WRITE_REG(hw, REG_PCIE_PHYMISC, data);
+
+}
 static const u32 atl1c_default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE |
    NETIF_MSG_LINK | NETIF_MSG_TIMER | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP;
 
@@ -117,6 +126,7 @@ static void atl1c_reset_pcie(struct atl1c_hw *hw, u32 flag)
    data &= ~PCIE_UC_SERVRITY_FCP;
    AT_WRITE_REG(hw, REG_PCIE_UC_SEVERITY, data);
 
+   atl1c_pcie_patch(hw);
    if (flag & ATL1C_PCIE_L0S_L1_DISABLE)
        atl1c_disable_l0s_l1(hw);
    if (flag & ATL1C_PCIE_PHY_RESET)
@@ -626,9 +636,7 @@ static int atl1c_setup_mac_funcs(struct atl1c_hw *hw)
    AT_READ_REG(hw, REG_PHY_STATUS, &phy_status_data);
    AT_READ_REG(hw, REG_LINK_CTRL, &link_ctrl_data);
 
-   hw->ctrl_flags = ATL1C_INTR_CLEAR_ON_READ |
-            ATL1C_INTR_MODRT_ENABLE  |
-            ATL1C_RX_IPV6_CHKSUM     |
+   hw->ctrl_flags = ATL1C_INTR_MODRT_ENABLE  |
             ATL1C_TXQ_MODE_ENHANCE;
    if (link_ctrl_data & LINK_CTRL_L0S_EN)
        hw->ctrl_flags |= ATL1C_ASPM_L0S_SUPPORT;
@@ -1063,7 +1071,7 @@ static void atl1c_configure_rx(struct atl1c_adapter *adapter)
    rxq_ctrl_data |= (hw->rss_hash_bits & RSS_HASH_BITS_MASK) <<
            RSS_HASH_BITS_SHIFT;
    if (hw->ctrl_flags & ATL1C_ASPM_CTRL_MON)
-       rxq_ctrl_data |= (ASPM_THRUPUT_LIMIT_100M &
+       rxq_ctrl_data |= (ASPM_THRUPUT_LIMIT_1M &
            ASPM_THRUPUT_LIMIT_MASK) << ASPM_THRUPUT_LIMIT_SHIFT;
 
    AT_WRITE_REG(hw, REG_RXQ_CTRL, rxq_ctrl_data);
@@ -1241,17 +1249,43 @@ static void atl1c_set_aspm(struct atl1c_hw *hw, bool linkup)
    AT_READ_REG(hw, REG_PM_CTRL, &pm_ctrl_data);
 
    pm_ctrl_data &= ~PM_CTRL_SERDES_PD_EX_L1;
+#if 0
+   pm_ctrl_data |= PM_CTRL_SERDES_BUDS_RX_L1_EN;
+   pm_ctrl_data |= PM_CTRL_SERDES_L1_EN;
+#endif
    pm_ctrl_data &=  ~(PM_CTRL_L1_ENTRY_TIMER_MASK <<
            PM_CTRL_L1_ENTRY_TIMER_SHIFT);
+   pm_ctrl_data &= ~(PM_CTRL_LCKDET_TIMER_MASK <<
+           PM_CTRL_LCKDET_TIMER_SHIFT);
 
    pm_ctrl_data |= PM_CTRL_MAC_ASPM_CHK;
+   pm_ctrl_data &= ~PM_CTRL_ASPM_L1_EN;
+   pm_ctrl_data |= PM_CTRL_RBER_EN;
+   pm_ctrl_data |= PM_CTRL_SDES_EN;
 
    if (linkup) {
        pm_ctrl_data |= PM_CTRL_SERDES_PLL_L1_EN;
        pm_ctrl_data &= ~PM_CTRL_CLK_SWH_L1;
+       pm_ctrl_data |= AT_LCKDET_TIMER <<
+           PM_CTRL_LCKDET_TIMER_SHIFT;
 
        pm_ctrl_data |= PM_CTRL_SERDES_BUDS_RX_L1_EN;
        pm_ctrl_data |= PM_CTRL_SERDES_L1_EN;
+       pm_ctrl_data |= PM_CTRL_CLK_REQ_EN;
+       pm_ctrl_data &= ~PM_CTRL_ASPM_L0S_EN;
+#if 0 /* to disable L1/L0s when connected , required by AK */
+       if (hw->ctrl_flags & ATL1C_ASPM_L1_SUPPORT) {
+           pm_ctrl_data |= AT_ASPM_L1_TIMER <<
+               PM_CTRL_L1_ENTRY_TIMER_SHIFT;
+           pm_ctrl_data |= PM_CTRL_ASPM_L1_EN;
+       } else
+           pm_ctrl_data &= ~PM_CTRL_ASPM_L1_EN;
+
+       if (hw->ctrl_flags & ATL1C_ASPM_L0S_SUPPORT)
+           pm_ctrl_data |= PM_CTRL_ASPM_L0S_EN;
+       else
+           pm_ctrl_data &= ~PM_CTRL_ASPM_L0S_EN;
+#endif
    } else {
        pm_ctrl_data &= ~PM_CTRL_SERDES_BUDS_RX_L1_EN;
        pm_ctrl_data &= ~PM_CTRL_SERDES_L1_EN;
@@ -1259,13 +1293,12 @@ static void atl1c_set_aspm(struct atl1c_hw *hw, bool linkup)
        pm_ctrl_data &= ~PM_CTRL_SERDES_PLL_L1_EN;
 
        pm_ctrl_data |= PM_CTRL_CLK_SWH_L1;
-
+       pm_ctrl_data |= 0xF << PM_CTRL_LCKDET_TIMER_SHIFT;
        if (hw->ctrl_flags & ATL1C_ASPM_L1_SUPPORT)
            pm_ctrl_data |= PM_CTRL_ASPM_L1_EN;
        else
            pm_ctrl_data &= ~PM_CTRL_ASPM_L1_EN;
    }
-
    AT_WRITE_REG(hw, REG_PM_CTRL, pm_ctrl_data);
 }
 
@@ -2301,10 +2334,9 @@ static int atl1c_suspend(struct pci_dev *pdev, pm_message_t state)
    struct net_device *netdev = pci_get_drvdata(pdev);
    struct atl1c_adapter *adapter = netdev_priv(netdev);
    struct atl1c_hw *hw = &adapter->hw;
-   u32 ctrl;
    u32 mac_ctrl_data;
    u32 master_ctrl_data;
-   u32 wol_ctrl_data;
+   u32 wol_ctrl_data = 0;
    u16 mii_bmsr_data;
    u16 save_autoneg_advertised;
    u16 mii_intr_status_data;
@@ -2321,23 +2353,29 @@ static int atl1c_suspend(struct pci_dev *pdev, pm_message_t state)
    retval = pci_save_state(pdev);
    if (retval)
        return retval;
-   if (wufc) {
-       AT_READ_REG(hw, REG_MASTER_CTRL, &master_ctrl_data);
-       master_ctrl_data &= ~MASTER_CTRL_CLK_SEL_DIS;
 
        /* get link status */
-       atl1c_read_phy_reg(hw, MII_BMSR, (u16 *)&mii_bmsr_data);
-       atl1c_read_phy_reg(hw, MII_BMSR, (u16 *)&mii_bmsr_data);
-       save_autoneg_advertised = hw->autoneg_advertised;
-       hw->autoneg_advertised = ADVERTISED_10baseT_Half;
-       if (atl1c_restart_autoneg(hw) != 0)
-           if (netif_msg_link(adapter))
-               dev_warn(&pdev->dev, "phy autoneg failed\n");
-       hw->phy_configured = false; /* re-init PHY when resume */
-       hw->autoneg_advertised = save_autoneg_advertised;
+   atl1c_read_phy_reg(hw, MII_BMSR, (u16 *)&mii_bmsr_data);
+   atl1c_read_phy_reg(hw, MII_BMSR, (u16 *)&mii_bmsr_data);
+
+   save_autoneg_advertised = hw->autoneg_advertised;
+   hw->autoneg_advertised = ADVERTISED_10baseT_Full;
+   if (atl1c_restart_autoneg(hw) != 0)
+       dev_dbg(&pdev->dev, "phy autoneg failed\n");
+   hw->phy_configured = false; /* re-init PHY when resume */
+   hw->autoneg_advertised = save_autoneg_advertised;
+   AT_READ_REG(hw, REG_MASTER_CTRL, &master_ctrl_data);
+   AT_READ_REG(hw, REG_MAC_CTRL, &mac_ctrl_data);
+   mac_ctrl_data &= ~(MAC_CTRL_PRMLEN_MASK << MAC_CTRL_PRMLEN_SHIFT);
+   mac_ctrl_data |= (((u32)adapter->hw.preamble_len &
+           MAC_CTRL_PRMLEN_MASK) <<
+           MAC_CTRL_PRMLEN_SHIFT);
+
+   if (wufc) {
+       master_ctrl_data &= ~MASTER_CTRL_CLK_SEL_DIS;
        /* turn on magic packet wol */
        if (wufc & AT_WUFC_MAG)
-           wol_ctrl_data = WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
+           wol_ctrl_data |= WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
 
        if (wufc & AT_WUFC_LNKC) {
            for (i = 0; i < AT_SUSPEND_LINK_TIMEOUT; i++) {
@@ -2367,13 +2405,10 @@ static int atl1c_suspend(struct pci_dev *pdev, pm_message_t state)
        /* clear phy interrupt */
        atl1c_read_phy_reg(hw, MII_ISR, &mii_intr_status_data);
        /* Config MAC Ctrl register */
-       mac_ctrl_data = MAC_CTRL_RX_EN;
+       mac_ctrl_data |= MAC_CTRL_RX_EN;
        /* set to 10/100M halt duplex */
        mac_ctrl_data |= atl1c_mac_speed_10_100 << MAC_CTRL_SPEED_SHIFT;
-       mac_ctrl_data |= (((u32)adapter->hw.preamble_len &
-                MAC_CTRL_PRMLEN_MASK) <<
-                MAC_CTRL_PRMLEN_SHIFT);
-
+       mac_ctrl_data |= MAC_CTRL_DUPLX;
        if (adapter->vlgrp)
            mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
 
@@ -2390,23 +2425,29 @@ static int atl1c_suspend(struct pci_dev *pdev, pm_message_t state)
        AT_WRITE_REG(hw, REG_MAC_CTRL, mac_ctrl_data);
 
        /* pcie patch */
-       AT_READ_REG(hw, REG_PCIE_PHYMISC, &ctrl);
-       ctrl |= PCIE_PHYMISC_FORCE_RCV_DET;
-       AT_WRITE_REG(hw, REG_PCIE_PHYMISC, ctrl);
+       atl1c_pcie_patch(hw);
+       device_set_wakeup_enable(&pdev->dev, 1);
+
+       AT_WRITE_REG(hw, REG_GPHY_CTRL, GPHY_CTRL_DEFAULT |
+           GPHY_CTRL_EXT_RESET);
 
        pci_enable_wake(pdev, pci_choose_state(pdev, state), 1);
        goto suspend_exit;
    }
+   AT_WRITE_REG(hw, REG_GPHY_CTRL, GPHY_CTRL_POWER_SAVING);
+
+   master_ctrl_data |= MASTER_CTRL_CLK_SEL_DIS;
+   mac_ctrl_data |= atl1c_mac_speed_10_100 << MAC_CTRL_SPEED_SHIFT;
+   mac_ctrl_data |= MAC_CTRL_DUPLX;
+   AT_WRITE_REG(hw, REG_MASTER_CTRL, master_ctrl_data);
+   AT_WRITE_REG(hw, REG_MAC_CTRL, mac_ctrl_data);
 wol_dis:
 
    /* WOL disabled */
    AT_WRITE_REG(hw, REG_WOL_CTRL, 0);
 
    /* pcie patch */
-   AT_READ_REG(hw, REG_PCIE_PHYMISC, &ctrl);
-   ctrl |= PCIE_PHYMISC_FORCE_RCV_DET;
-   AT_WRITE_REG(hw, REG_PCIE_PHYMISC, ctrl);
-
+   atl1c_pcie_patch(hw);
    atl1c_phy_disable(hw);
    hw->phy_configured = false; /* re-init PHY when resume */
 
