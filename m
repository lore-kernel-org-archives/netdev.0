From: Darren Hart <dvhart@linux.intel.com>
Subject: [PATCH 3/3] pch_gbe: Add MinnowBoard support
Date: Fri, 12 Jul 2013 17:58:07 -0700
Message-ID: <ad20133699c36bd8d183dd685f1b35f6d6b99005.1373676797.git.dvhart@linux.intel.com>
References: <1373677087-7747-1-git-send-email-dvhart@linux.intel.com>
Cc: Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	netdev@vger.kernel.org, <stable@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43630 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758024Ab3GMA6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jul 2013 20:58:31 -0400
In-Reply-To: <1373677087-7747-1-git-send-email-dvhart@linux.intel.com>
In-Reply-To: <ce5dd365d05f8747d269aa74e0bb929935d9cdee.1373676797.git.dvhart@linux.intel.com>
References: <ce5dd365d05f8747d269aa74e0bb929935d9cdee.1373676797.git.dvhart@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MinnowBoard uses an AR803x PHY with the PCH GBE which requires
special handling. Use the MinnowBoard PCI Subsystem ID to detect this
and add a pci_device_id.driver_data structure and functions to handle
platform setup.

The AR803x does not implement the RGMII 2ns TX clock delay in the trace
routing nor via strapping. Add a detection method for the board and the
PHY and enable the TX clock delay via the registers.

This PHY will hibernate without link for 10 seconds. Ensure the PHY is
awake for probe and then disable hibernation. A future improvement would
be to convert pch_gbe to using PHYLIB and making sure we can wake the
PHY at the necessary times rather than permanently disabling it.

Signed-off-by: Darren Hart <dvhart@linux.intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: netdev@vger.kernel.org
Cc: <stable@vger.kernel.org> # 3.8.x: 5829e9b mfd: lpc_sch: Accomodate partial
Cc: <stable@vger.kernel.org> # 3.8.x: 3cbf182 gpio-sch: Allow for more than 8
Cc: <stable@vger.kernel.org> # 3.8.x: 91bbe92: PCI: Add CircuitCo vendor ID
Cc: <stable@vger.kernel.org> # 3.8.x: bd79680: pch_gbe: remove inline keyword
Cc: <stable@vger.kernel.org> # 3.8.x: 453ca93: pch_gbe: convert pr_* to
Cc: <stable@vger.kernel.org> # 3.8.x: 29cc436: pch_gbe: use managed functions
Cc: <stable@vger.kernel.org> # 3.8.x
Cc: <stable@vger.kernel.org> # 3.10.x: 91bbe92: PCI: Add CircuitCo vendor ID
Cc: <stable@vger.kernel.org> # 3.10.x: bd79680: pch_gbe: remove inline keyword
Cc: <stable@vger.kernel.org> # 3.10.x: 453ca93: pch_gbe: convert pr_* to
Cc: <stable@vger.kernel.org> # 3.10.x: 29cc436: pch_gbe: use managed functions
Cc: <stable@vger.kernel.org> # 3.10.x
Signed-off-by: Darren Hart <dvhart@linux.intel.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    | 15 ++++
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 48 +++++++++++
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    | 98 ++++++++++++++++++++++
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h    |  2 +
 4 files changed, 163 insertions(+)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index 7779036..d7d71cd 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -582,6 +582,19 @@ struct pch_gbe_hw_stats {
 };
 
 /**
+ * struct pch_gbe_privdata - PCI Device ID driver data
+ * @phy_tx_clk_delay:		Bool, configure the PHY TX delay in software
+ * @phy_disable_hibernate:	Bool, disable PHY hibernation
+ * @platform_init:		Platform initialization callback, called from
+ *				probe, prio to PHY initialization.
+ */
+struct pch_gbe_privdata {
+	bool phy_tx_clk_delay;
+	bool phy_disable_hibernate;
+	int(*platform_init)(struct pci_dev *pdev);
+};
+
+/**
  * struct pch_gbe_adapter - board specific private data structure
  * @stats_lock:	Spinlock structure for status
  * @ethtool_lock:	Spinlock structure for ethtool
@@ -604,6 +617,7 @@ struct pch_gbe_hw_stats {
  * @rx_buffer_len:	Receive buffer length
  * @tx_queue_len:	Transmit queue length
  * @have_msi:		PCI MSI mode flag
+ * @pch_gbe_privdata	PCI Device ID driver_data
  */
 
 struct pch_gbe_adapter {
@@ -631,6 +645,7 @@ struct pch_gbe_adapter {
 	int hwts_tx_en;
 	int hwts_rx_en;
 	struct pci_dev *ptp_pdev;
+	struct pch_gbe_privdata *pdata;
 };
 
 #define pch_gbe_hw_to_adapter(hw)	container_of(hw, struct pch_gbe_adapter, hw)
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 749ddd9..da83657 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -23,6 +23,7 @@
 #include <linux/module.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_classify.h>
+#include <linux/gpio.h>
 
 #define DRV_VERSION     "1.01"
 const char pch_driver_version[] = DRV_VERSION;
@@ -111,6 +112,8 @@ const char pch_driver_version[] = DRV_VERSION;
 #define PTP_L4_MULTICAST_SA "01:00:5e:00:01:81"
 #define PTP_L2_MULTICAST_SA "01:1b:19:00:00:00"
 
+#define MINNOW_PHY_RESET_GPIO		13
+
 static unsigned int copybreak __read_mostly = PCH_GBE_COPYBREAK_DEFAULT;
 
 static int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg);
@@ -2635,6 +2638,9 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
 	adapter->hw.reg = pcim_iomap_table(pdev)[PCH_GBE_PCI_BAR];
+	adapter->pdata = (struct pch_gbe_privdata *)pci_id->driver_data;
+	if (adapter->pdata && adapter->pdata->platform_init)
+		adapter->pdata->platform_init(pdev);
 
 	adapter->ptp_pdev = pci_get_bus_and_slot(adapter->pdev->bus->number,
 					       PCI_DEVFN(12, 4));
@@ -2710,6 +2716,10 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 
 	dev_dbg(&pdev->dev, "PCH Network Connection\n");
 
+	/* Disable hibernation on certain platforms */
+	if (adapter->pdata && adapter->pdata->phy_disable_hibernate)
+		pch_gbe_phy_disable_hibernate(&adapter->hw);
+
 	device_set_wakeup_enable(&pdev->dev, 1);
 	return 0;
 
@@ -2720,9 +2730,47 @@ err_free_netdev:
 	return ret;
 }
 
+/* The AR803X PHY on the MinnowBoard requires a physical pin to be toggled to
+ * ensure it is awake for probe and init. Request the line and reset the PHY.
+ */
+static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
+{
+	int ret = 0;
+	int flags = GPIOF_DIR_OUT | GPIOF_INIT_HIGH | GPIOF_EXPORT;
+	int gpio = MINNOW_PHY_RESET_GPIO;
+
+	ret = gpio_request_one(gpio, flags, "minnow_phy_reset");
+	if (ret){
+		dev_err(&pdev->dev,
+			"ERR: Can't request PHY reset GPIO line '%d'\n", gpio);
+		return ret;
+	}
+
+	gpio_set_value(gpio, 0);
+	usleep_range(1250, 1500);
+	gpio_set_value(gpio, 1);
+	usleep_range(1250, 1500);
+
+	return ret;
+}
+
+static struct pch_gbe_privdata pch_gbe_minnow_privdata = {
+	.phy_tx_clk_delay = true,
+	.phy_disable_hibernate = true,
+	.platform_init = pch_gbe_minnow_platform_init,
+};
+
 static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
 	{.vendor = PCI_VENDOR_ID_INTEL,
 	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
+	 .subvendor = PCI_VENDOR_ID_CIRCUITCO,
+	 .subdevice = PCI_SUBSYSTEM_ID_CIRCUITCO_MINNOWBOARD,
+	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
+	 .class_mask = (0xFFFF00),
+	 .driver_data = (unsigned long) &pch_gbe_minnow_privdata
+	 },
+	{.vendor = PCI_VENDOR_ID_INTEL,
+	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
 	 .subvendor = PCI_ANY_ID,
 	 .subdevice = PCI_ANY_ID,
 	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
index da07907..7de93cd 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
@@ -74,6 +74,15 @@
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
 
@@ -277,4 +286,93 @@ void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
 	pch_gbe_phy_read_reg_miic(hw, PHY_PHYSP_CONTROL, &mii_reg);
 	mii_reg |= PHYSP_CTRL_ASSERT_CRS_TX;
 	pch_gbe_phy_write_reg_miic(hw, PHY_PHYSP_CONTROL, mii_reg);
+
+	/* Setup a TX clock delay on certain platforms */
+	if (adapter->pdata->phy_tx_clk_delay)
+		pch_gbe_phy_tx_clk_delay(hw);
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
+	/* The RGMII interface requires a ~2ns TX clock delay. This is typically
+	 * done in layout with a longer trace or via PHY strapping, but can also
+	 * be done via PHY configuration registers.
+	 */
+	struct pch_gbe_adapter *adapter = pch_gbe_hw_to_adapter(hw);
+	u16 mii_reg;
+	int ret = 0;
+
+	switch (hw->phy.id) {
+	case PHY_AR803X_ID:
+		netdev_dbg(adapter->netdev,
+			   "Configuring AR803X PHY for 2ns TX clock delay\n"); 
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
+		netdev_err(adapter->netdev,
+			   "Unknown PHY (%x), could not set TX clock delay.\n",
+			   hw->phy.id);
+		return -EINVAL;
+	}
+
+	if (ret)
+		netdev_err(adapter->netdev,
+			   "Could not configure tx clock delay for PHY.\n");
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
+	struct pch_gbe_adapter *adapter = pch_gbe_hw_to_adapter(hw);
+	u16 mii_reg;
+	int ret = 0;
+
+	switch (hw->phy.id) {
+	case PHY_AR803X_ID:
+		netdev_dbg(adapter->netdev,
+			   "Disabling hibernation for AR803X PHY\n");
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
+		netdev_err(adapter->netdev,
+			   "Unknown PHY (%x), could not disable hibernation\n",
+			   hw->phy.id);
+		return -EINVAL;
+	}
+
+	if (ret)
+		netdev_err(adapter->netdev,
+			   "Could not disable PHY hibernation.\n");
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
1.8.3.1
