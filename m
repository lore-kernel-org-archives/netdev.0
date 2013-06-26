From: Darren Hart <dvhart@linux.intel.com>
Subject: [PATCH 8/8] pch_gbe: Add MinnowBoard support
Date: Tue, 25 Jun 2013 18:53:28 -0700
Message-ID: <6c27e79870ec93f7a8c6692d4bcfebaee589fa6b.1372211451.git.dvhart@linux.intel.com>
References: <cover.1372211451.git.dvhart@linux.intel.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>, peter.p.waskiewicz.jr@intel.com,
	andriy.shevchenko@linux.intel.com, danders@circuitco.com,
	vishal.l.verma@intel.com, dvhart@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1372211451.git.dvhart@linux.intel.com>
In-Reply-To: <cover.1372211451.git.dvhart@linux.intel.com>
References: <cover.1372211451.git.dvhart@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MinnowBoard uses an AR803x PHY with the PCH GBE.

It does not implement the RGMII 2ns TX clock delay in the trace routing
nor via strapping. Add a detection method for the board and the PHY and
enable the tx clock delay via the registers.

This PHY will hibernate without link for 10 seconds. Ensure the PHY is
awake for probe and then disable hibernation. A future improvement would
be to convert pch_gbe to using PHYLIB and making sure we can wake the
PHY at the necessary times rather than permanently disabling it.

Use the MinnowBoard PCI subsystem ID to identify the board and setup the
appropriate callbacks in a new pci_id driver_data structure.

Signed-off-by: Darren Hart <dvhart@linux.intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig      |  1 +
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |  2 +
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 32 ++++++++
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    | 89 ++++++++++++++++++++++
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h    |  2 +
 5 files changed, 126 insertions(+)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index 34d05bf..a93fa6b 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -5,6 +5,7 @@
 config PCH_GBE
 	tristate "OKI SEMICONDUCTOR IOH(ML7223/ML7831) GbE"
 	depends on PCI
+	depends on !MINNOWBOARD || (MINNOWBOARD=m && m) || MINNOWBOARD=y
 	select NET_CORE
 	select MII
 	select PTP_1588_CLOCK_PCH
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index 7fb7e17..feacf05 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -384,6 +384,7 @@ struct pch_gbe_mac_info {
  * @revision:		PHY's revision
  * @reset_delay_us:	HW reset delay time[us]
  * @autoneg_advertised:	Autoneg advertised
+ * @tx_clk_delay:	Setup TX clock delay in the PHY
  */
 struct pch_gbe_phy_info {
 	u32 addr;
@@ -391,6 +392,7 @@ struct pch_gbe_phy_info {
 	u32 revision;
 	u32 reset_delay_us;
 	u16 autoneg_advertised;
+	int(*tx_clk_delay)(struct pch_gbe_hw *);
 };
 
 /*!
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 6667a6b..6f0b9e3 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -23,6 +23,7 @@
 #include <linux/module.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_classify.h>
+#include <linux/minnowboard.h>
 
 #define DRV_VERSION     "1.01"
 const char pch_driver_version[] = DRV_VERSION;
@@ -111,6 +112,11 @@ const char pch_driver_version[] = DRV_VERSION;
 #define PTP_L4_MULTICAST_SA "01:00:5e:00:01:81"
 #define PTP_L2_MULTICAST_SA "01:1b:19:00:00:00"
 
+struct pch_gbe_privdata {
+	void(*phy_reset)(void);
+	int(*phy_tx_clk_delay)(struct pch_gbe_hw *hw);
+};
+
 static unsigned int copybreak __read_mostly = PCH_GBE_COPYBREAK_DEFAULT;
 
 static int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg);
@@ -2559,6 +2565,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 {
 	struct net_device *netdev;
 	struct pch_gbe_adapter *adapter;
+	struct pch_gbe_privdata *pdata = NULL;
 	int ret;
 
 	ret = pci_enable_device(pdev);
@@ -2596,6 +2603,15 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 
 	pci_set_drvdata(pdev, netdev);
 	adapter = netdev_priv(netdev);
+
+	adapter->hw.phy.tx_clk_delay = NULL;
+	if (pci_id->driver_data) {
+		pdata = (struct pch_gbe_privdata *)pci_id->driver_data;
+		adapter->hw.phy.tx_clk_delay = pdata->phy_tx_clk_delay;
+		if (pdata->phy_reset)
+			pdata->phy_reset();
+	}
+
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
@@ -2679,6 +2695,9 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 
 	dev_dbg(&pdev->dev, "PCH Network Connection\n");
 
+	/* Disable hibernation on certain PHYs */
+	pch_gbe_phy_disable_hibernate(&adapter->hw);
+
 	device_set_wakeup_enable(&pdev->dev, 1);
 	return 0;
 
@@ -2697,9 +2716,22 @@ err_disable_device:
 	return ret;
 }
 
+static struct pch_gbe_privdata pch_gbe_minnowboard_privdata = {
+	.phy_reset = minnow_phy_reset,
+	.phy_tx_clk_delay = pch_gbe_phy_tx_clk_delay,
+};
+
 static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
 	{.vendor = PCI_VENDOR_ID_INTEL,
 	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
+	 .subvendor = PCI_VENDOR_ID_CIRCUITCO,
+	 .subdevice = PCI_DEVICE_ID_CIRCUITCO_MINNOWBOARD,
+	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
+	 .class_mask = (0xFFFF00),
+	 .driver_data = (unsigned long) &pch_gbe_minnowboard_privdata
+	 },
+	{.vendor = PCI_VENDOR_ID_INTEL,
+	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
 	 .subvendor = PCI_ANY_ID,
 	 .subdevice = PCI_ANY_ID,
 	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
index 28bb960..ab0e0e7 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
@@ -20,6 +20,7 @@
 
 #include "pch_gbe.h"
 #include "pch_gbe_phy.h"
+#include <linux/gpio.h>
 
 #define PHY_MAX_REG_ADDRESS   0x1F	/* 5 bit address bus (0-0x1F) */
 
@@ -74,6 +75,15 @@
 #define MII_SR_100X_FD_CAPS      0x4000	/* 100X  Full Duplex Capable */
 #define MII_SR_100T4_CAPS        0x8000	/* 100T4 Capable */
 
+/* AR8031 PHY Debug Registers */
+#define PHY_AR803X_ID           0x00001374
+#define PHY_AR8031_DBG_OFF      0x1D
+#define PHY_AR8031_DBG_DAT      0x1E
+#define PHY_AR8031_SERDES       0x05
+#define PHY_AR8031_HIBERNATE    0x0B
+#define PHY_AR8031_SERDES_TX_CLK_DLY   0x0100 /* TX clock delay of 2.0ns */
+#define PHY_AR8031_PS_HIB_EN           0x8000 /* Hibernate enable */
+
 /* Phy Id Register (word 2) */
 #define PHY_REVISION_MASK        0x000F
 
@@ -271,4 +281,83 @@ void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
 	mii_reg |= PHYSP_CTRL_ASSERT_CRS_TX;
 	pch_gbe_phy_write_reg_miic(hw, PHY_PHYSP_CONTROL, mii_reg);
 
+	 /* Setup a TX clock delay for certain boards */
+	 if (hw->phy.tx_clk_delay)
+		hw->phy.tx_clk_delay(hw);
+}
+
+/**
+ * pch_gbe_phy_tx_clk_delay - Setup TX clock delay via the PHY
+ * @hw:	            Pointer to the HW structure
+ * Returns
+ *	0:		Successful.
+ *	-EINVAL:	Invalid argument.
+ */
+int pch_gbe_phy_tx_clk_delay(struct pch_gbe_hw *hw)
+{
+	/*
+	 * The RGMII interface requires a ~2ns TX clock delay. This is typically
+	 * done in layout with a longer trace or via PHY strapping, but can also
+	 * be done via PHY configuration registers.
+	 */
+	u16 mii_reg;
+	int ret = 0;
+
+	switch (hw->phy.id) {
+	case PHY_AR803X_ID:
+		pch_gbe_phy_read_reg_miic(hw, PHY_AR8031_DBG_OFF, &mii_reg);
+		ret = pch_gbe_phy_write_reg_miic(hw, PHY_AR8031_DBG_OFF,
+						 PHY_AR8031_SERDES);
+		if (ret)
+			break;
+
+		pch_gbe_phy_read_reg_miic(hw, PHY_AR8031_DBG_DAT, &mii_reg);
+		mii_reg |= PHY_AR8031_SERDES_TX_CLK_DLY;
+		ret = pch_gbe_phy_write_reg_miic(hw, PHY_AR8031_DBG_DAT,
+						 mii_reg);
+		break;
+	default:
+		pr_err("Unknown PHY (%x), could not set TX clock delay.\n",
+		       hw->phy.id);
+		return -EINVAL;
+	}
+
+	if (ret)
+		pr_err("Could not configure tx clock delay for PHY.\n");
+	return ret;
+}
+
+/**
+ * pch_gbe_phy_disable_hibernate - Disable the PHY low power state
+ * @hw:	            Pointer to the HW structure
+ * Returns
+ *	0:		Successful.
+ *	-EINVAL:	Invalid argument.
+ */
+int pch_gbe_phy_disable_hibernate(struct pch_gbe_hw *hw)
+{
+	u16 mii_reg;
+	int ret = 0;
+
+	switch (hw->phy.id) {
+	case PHY_AR803X_ID:
+		ret = pch_gbe_phy_write_reg_miic(hw, PHY_AR8031_DBG_OFF,
+						 PHY_AR8031_HIBERNATE);
+		if (ret)
+			break;
+
+		pch_gbe_phy_read_reg_miic(hw, PHY_AR8031_DBG_DAT, &mii_reg);
+		mii_reg &= ~PHY_AR8031_PS_HIB_EN;
+		ret = pch_gbe_phy_write_reg_miic(hw, PHY_AR8031_DBG_DAT,
+						 mii_reg);
+		break;
+	default:
+		pr_err("Unknown PHY (%x), could not disable hibernation\n",
+		       hw->phy.id);
+		return -EINVAL;
+	}
+
+	if (ret)
+		pr_err("Could not disable PHY hibernation.\n");
+	return ret;
 }
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
index 03264dc..e3e4bc9 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
@@ -33,5 +33,7 @@ void pch_gbe_phy_power_up(struct pch_gbe_hw *hw);
 void pch_gbe_phy_power_down(struct pch_gbe_hw *hw);
 void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw);
 void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw);
+int pch_gbe_phy_tx_clk_delay(struct pch_gbe_hw *hw);
+int pch_gbe_phy_disable_hibernate(struct pch_gbe_hw *hw);
 
 #endif /* _PCH_GBE_PHY_H_ */
-- 
1.8.1.2
