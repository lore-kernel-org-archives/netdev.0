From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH v2 3/6] net: pch_gbe: Pull PHY GPIO handling out of Minnow code
Date: Wed, 3 Feb 2016 12:02:41 +0000
Message-ID: <1454500964-6256-4-git-send-email-paul.burton@imgtec.com>
References: <1454500964-6256-1-git-send-email-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Burton <paul.burton@imgtec.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <linux-mips@linux-mips.org>, Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454500964-6256-1-git-send-email-paul.burton@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MIPS Boston development board uses the Intel EG20T Platform
Controller Hub, including its gigabit ethernet controller, and requires
that its RTL8211E PHY be reset much like the Minnow platform. Pull the
PHY reset GPIO handling out of Minnow-specific code such that it can be
shared by later patches.

Signed-off-by: Paul Burton <paul.burton@imgtec.com>
---

Changes in v2: None

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |  4 ++-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 33 +++++++++++++++-------
 2 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index 2a55d6d..884f90b 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -582,15 +582,17 @@ struct pch_gbe_hw_stats {
 
 /**
  * struct pch_gbe_privdata - PCI Device ID driver data
+ * @phy_reset_gpio:		PHY reset GPIO descriptor.
  * @phy_tx_clk_delay:		Bool, configure the PHY TX delay in software
  * @phy_disable_hibernate:	Bool, disable PHY hibernation
  * @platform_init:		Platform initialization callback, called from
  *				probe, prior to PHY initialization.
  */
 struct pch_gbe_privdata {
+	struct gpio_desc *phy_reset_gpio;
 	bool phy_tx_clk_delay;
 	bool phy_disable_hibernate;
-	int (*platform_init)(struct pci_dev *pdev);
+	int (*platform_init)(struct pci_dev *, struct pch_gbe_privdata *);
 };
 
 /**
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index fde4c11..23d28f0 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -360,6 +360,16 @@ static void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 * addr, u32 index)
 	pch_gbe_wait_clr_bit(&hw->reg->ADDR_MASK, PCH_GBE_BUSY);
 }
 
+static void pch_gbe_phy_set_reset(struct pch_gbe_hw *hw, int value)
+{
+	struct pch_gbe_adapter *adapter = pch_gbe_hw_to_adapter(hw);
+
+	if (!adapter->pdata || !adapter->pdata->phy_reset_gpio)
+		return;
+
+	gpiod_set_value(adapter->pdata->phy_reset_gpio, value);
+}
+
 /**
  * pch_gbe_mac_reset_hw - Reset hardware
  * @hw:	Pointer to the HW structure
@@ -2627,7 +2637,14 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	adapter->hw.reg = pcim_iomap_table(pdev)[PCH_GBE_PCI_BAR];
 	adapter->pdata = (struct pch_gbe_privdata *)pci_id->driver_data;
 	if (adapter->pdata && adapter->pdata->platform_init)
-		adapter->pdata->platform_init(pdev);
+		adapter->pdata->platform_init(pdev, pdata);
+
+	if (adapter->pdata && adapter->pdata->phy_reset_gpio) {
+		pch_gbe_phy_set_reset(&adapter->hw, 1);
+		usleep_range(1250, 1500);
+		pch_gbe_phy_set_reset(&adapter->hw, 0);
+		usleep_range(1250, 1500);
+	}
 
 	adapter->ptp_pdev = pci_get_bus_and_slot(adapter->pdev->bus->number,
 					       PCI_DEVFN(12, 4));
@@ -2715,7 +2732,8 @@ err_free_netdev:
 /* The AR803X PHY on the MinnowBoard requires a physical pin to be toggled to
  * ensure it is awake for probe and init. Request the line and reset the PHY.
  */
-static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
+static int pch_gbe_minnow_platform_init(struct pci_dev *pdev,
+					struct pch_gbe_privdata *pdata)
 {
 	unsigned long flags = GPIOF_DIR_OUT | GPIOF_INIT_LOW |
 		GPIOF_EXPORT | GPIOF_ACTIVE_LOW;
@@ -2724,16 +2742,11 @@ static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
 
 	ret = devm_gpio_request_one(&pdev->dev, gpio, flags,
 				    "minnow_phy_reset");
-	if (ret) {
+	if (!ret)
+		pdata->phy_reset_gpio = gpio_to_desc(gpio);
+	else
 		dev_err(&pdev->dev,
 			"ERR: Can't request PHY reset GPIO line '%d'\n", gpio);
-		return ret;
-	}
-
-	gpio_set_value(gpio, 1);
-	usleep_range(1250, 1500);
-	gpio_set_value(gpio, 0);
-	usleep_range(1250, 1500);
 
 	return ret;
 }
-- 
2.7.0
