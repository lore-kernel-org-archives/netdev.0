From: Darren Hart <dvhart@linux.intel.com>
Subject: [PATCH net-next 2/2] pch_gbe: Add MinnowBoard support
Date: Wed, 17 Jul 2013 13:10:43 -0700
Message-ID: <dfebe34003c2ac50efbca01a86b4b0085e8c1bfa.1374091736.git.dvhart@linux.intel.com>
References: <1374091843-1521-1-git-send-email-dvhart@linux.intel.com>
Cc: Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Joe Perches <joe@perches.com>
To: Linux Net Dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11129 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757177Ab3GQUKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jul 2013 16:10:46 -0400
In-Reply-To: <1374091843-1521-1-git-send-email-dvhart@linux.intel.com>
In-Reply-To: <001ee275d6df06f3bb84ee5d214f308a4f20d4be.1374091736.git.dvhart@linux.intel.com>
References: <001ee275d6df06f3bb84ee5d214f308a4f20d4be.1374091736.git.dvhart@linux.intel.com>
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

V3: Whitespace cleanup. Remove trailing period in messages.
    Comment formatting (added a colon).
    Use devm_gpio_request_one
    Fix missing adapter->pdata NULL check in PHY
    Use netdev style comment blocks

Signed-off-by: Darren Hart <dvhart@linux.intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Joe Perches <joe@perches.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    | 14 ++++
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 49 +++++++++++
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    | 96 ++++++++++++++++++++++
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h    |  2 +
 4 files changed, 161 insertions(+)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index 7779036..0d124d7 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -581,6 +581,18 @@ struct pch_gbe_hw_stats {
 	u32 intr_tcpip_err_count;
 };
 
+/* struct pch_gbe_privdata - PCI Device ID driver data
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
 /**
  * struct pch_gbe_adapter - board specific private data structure
  * @stats_lock:	Spinlock structure for status
@@ -604,6 +616,7 @@ struct pch_gbe_hw_stats {
  * @rx_buffer_len:	Receive buffer length
  * @tx_queue_len:	Transmit queue length
  * @have_msi:		PCI MSI mode flag
+ * @pch_gbe_privdata:	PCI Device ID driver_data
  */
 
 struct pch_gbe_adapter {
@@ -631,6 +644,7 @@ struct pch_gbe_adapter {
 	int hwts_tx_en;
 	int hwts_rx_en;
 	struct pci_dev *ptp_pdev;
+	struct pch_gbe_privdata *pdata;
 };
 
 #define pch_gbe_hw_to_adapter(hw)	container_of(hw, struct pch_gbe_adapter, hw)
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 749ddd9..d37b10f 100644
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
 
@@ -2720,9 +2730,48 @@ err_free_netdev:
 	return ret;
 }
 
+/* The AR803X PHY on the MinnowBoard requires a physical pin to be toggled to
+ * ensure it is awake for probe and init. Request the line and reset the PHY.
+ */
+static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
+{
+	int flags = GPIOF_DIR_OUT | GPIOF_INIT_HIGH | GPIOF_EXPORT;
+	int gpio = MINNOW_PHY_RESET_GPIO;
+	int ret;
+
+	ret = devm_gpio_request_one(&pdev->dev, gpio, flags,
+				    "minnow_phy_reset");
+	if (ret) {
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
index da07907..be513a9 100644
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
 
@@ -277,4 +286,91 @@ void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
 	pch_gbe_phy_read_reg_miic(hw, PHY_PHYSP_CONTROL, &mii_reg);
 	mii_reg |= PHYSP_CTRL_ASSERT_CRS_TX;
 	pch_gbe_phy_write_reg_miic(hw, PHY_PHYSP_CONTROL, mii_reg);
+
+	/* Setup a TX clock delay on certain platforms */
+	if (adapter->pdata && adapter->pdata->phy_tx_clk_delay)
+		pch_gbe_phy_tx_clk_delay(hw);
+}
+
+/* pch_gbe_phy_tx_clk_delay - Setup TX clock delay via the PHY
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
+			   "Unknown PHY (%x), could not set TX clock delay\n",
+			   hw->phy.id);
+		return -EINVAL;
+	}
+
+	if (ret)
+		netdev_err(adapter->netdev,
+			   "Could not configure tx clock delay for PHY\n");
+	return ret;
+}
+
+/* pch_gbe_phy_disable_hibernate - Disable the PHY low power state
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
+			   "Could not disable PHY hibernation\n");
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
