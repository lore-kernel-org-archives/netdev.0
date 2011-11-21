From: AriesLee <AriesLee@jmicron.com>
Subject: [PATCH 1/1]   PHY configuration for compatible issue
Date: Tue, 22 Nov 2011 04:20:42 +0800
Message-ID: <1321906842-1476-1-git-send-email-AriesLee@jmicron.com>
Cc: AriesLee <AriesLee@jmicron.com>
To: Aries Lee <ariesleeILan@gmail.com>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spamfilter.jmicron.com ([220.130.51.235]:29378 "EHLO
	jmsspam.jmicron.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750903Ab1KUMWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 07:22:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To perform PHY calibration and set a different EA value by chip ID,
Whenever the NIC chip power on, ie booting or resuming, we need to
force HW to calibrate PHY parameter again, and also set a proper EA
value which gather from experiment.

Those procedures help to reduce compatible issues(NIC is unable to link
up in some special case) in giga speed.

Signed-off-by: AriesLee <AriesLee@jmicron.com>
---
 drivers/net/ethernet/jme.c |  113 ++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/ethernet/jme.h |   19 +++++++
 2 files changed, 129 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index df3ab83..8ebbb33 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -1745,6 +1745,112 @@ jme_phy_off(struct jme_adapter *jme)
 }
 
 static int
+jme_phy_specreg_read(struct jme_adapter *jme, u32 specreg)
+{
+	u32 phy_addr;
+
+	phy_addr = JM_PHY_SPEC_REG_READ | specreg;
+	jme_mdio_write(jme->dev, jme->mii_if.phy_id, JM_PHY_SPEC_ADDR_REG,
+			phy_addr);
+	return jme_mdio_read(jme->dev, jme->mii_if.phy_id,
+			JM_PHY_SPEC_DATA_REG);
+}
+
+static void
+jme_phy_specreg_write(struct jme_adapter *jme, u32 ext_reg, u32 phy_data)
+{
+	u32 phy_addr;
+
+	phy_addr = JM_PHY_SPEC_REG_WRITE | ext_reg;
+	jme_mdio_write(jme->dev, jme->mii_if.phy_id, JM_PHY_SPEC_DATA_REG,
+			phy_data);
+	jme_mdio_write(jme->dev, jme->mii_if.phy_id, JM_PHY_SPEC_ADDR_REG,
+			phy_addr);
+}
+
+static int
+jme_phy_calibration(struct jme_adapter *jme)
+{
+	u32 ctrl1000, phy_data;
+
+	jme_phy_off(jme);
+	jme_phy_on(jme);
+	/*  Enabel PHY test mode 1 */
+	ctrl1000 = jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_CTRL1000);
+	ctrl1000 &= ~PHY_GAD_TEST_MODE_MSK;
+	ctrl1000 |= PHY_GAD_TEST_MODE_1;
+	jme_mdio_write(jme->dev, jme->mii_if.phy_id, MII_CTRL1000, ctrl1000);
+
+	phy_data = jme_phy_specreg_read(jme, JM_PHY_EXT_COMM_2_REG);
+	phy_data &= ~JM_PHY_EXT_COMM_2_CALI_MODE_0;
+	phy_data |= JM_PHY_EXT_COMM_2_CALI_LATCH |
+			JM_PHY_EXT_COMM_2_CALI_ENABLE;
+	jme_phy_specreg_write(jme, JM_PHY_EXT_COMM_2_REG, phy_data);
+	msleep(20);
+	phy_data = jme_phy_specreg_read(jme, JM_PHY_EXT_COMM_2_REG);
+	phy_data &= ~(JM_PHY_EXT_COMM_2_CALI_ENABLE |
+			JM_PHY_EXT_COMM_2_CALI_MODE_0 |
+			JM_PHY_EXT_COMM_2_CALI_LATCH);
+	jme_phy_specreg_write(jme, JM_PHY_EXT_COMM_2_REG, phy_data);
+
+	/*  Disable PHY test mode */
+	ctrl1000 = jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_CTRL1000);
+	ctrl1000 &= ~PHY_GAD_TEST_MODE_MSK;
+	jme_mdio_write(jme->dev, jme->mii_if.phy_id, MII_CTRL1000, ctrl1000);
+	return 0;
+}
+
+static int
+jme_phy_setEA(struct jme_adapter *jme)
+{
+	u32 phy_comm0 = 0, phy_comm1 = 0;
+	u8 nic_ctrl;
+
+	pci_read_config_byte(jme->pdev, PCI_PRIV_SHARE_NICCTRL, &nic_ctrl);
+	if ((nic_ctrl & 0x3) == JME_FLAG_PHYEA_ENABLE)
+		return 0;
+
+	switch (jme->pdev->device) {
+	case PCI_DEVICE_ID_JMICRON_JMC250:
+		if (((jme->chip_main_rev == 5) &&
+			((jme->chip_sub_rev == 0) || (jme->chip_sub_rev == 1) ||
+			(jme->chip_sub_rev == 3))) ||
+			(jme->chip_main_rev >= 6)) {
+			phy_comm0 = 0x008A;
+			phy_comm1 = 0x4109;
+		}
+		if ((jme->chip_main_rev == 3) &&
+			((jme->chip_sub_rev == 1) || (jme->chip_sub_rev == 2)))
+			phy_comm0 = 0xE088;
+		break;
+	case PCI_DEVICE_ID_JMICRON_JMC260:
+		if (((jme->chip_main_rev == 5) &&
+			((jme->chip_sub_rev == 0) || (jme->chip_sub_rev == 1) ||
+			(jme->chip_sub_rev == 3))) ||
+			(jme->chip_main_rev >= 6)) {
+			phy_comm0 = 0x008A;
+			phy_comm1 = 0x4109;
+		}
+		if ((jme->chip_main_rev == 3) &&
+			((jme->chip_sub_rev == 1) || (jme->chip_sub_rev == 2)))
+			phy_comm0 = 0xE088;
+		if ((jme->chip_main_rev == 2) && (jme->chip_sub_rev == 0))
+			phy_comm0 = 0x608A;
+		if ((jme->chip_main_rev == 2) && (jme->chip_sub_rev == 2))
+			phy_comm0 = 0x408A;
+		break;
+	default:
+		return -ENODEV;
+	}
+	if (phy_comm0)
+		jme_phy_specreg_write(jme, JM_PHY_EXT_COMM_0_REG, phy_comm0);
+	if (phy_comm1)
+		jme_phy_specreg_write(jme, JM_PHY_EXT_COMM_1_REG, phy_comm1);
+
+	return 0;
+}
+
+static int
 jme_open(struct net_device *netdev)
 {
 	struct jme_adapter *jme = netdev_priv(netdev);
@@ -1769,7 +1875,8 @@ jme_open(struct net_device *netdev)
 		jme_set_settings(netdev, &jme->old_ecmd);
 	else
 		jme_reset_phy_processor(jme);
-
+	jme_phy_calibration(jme);
+	jme_phy_setEA(jme);
 	jme_reset_link(jme);
 
 	return 0;
@@ -3184,7 +3291,8 @@ jme_resume(struct device *dev)
 		jme_set_settings(netdev, &jme->old_ecmd);
 	else
 		jme_reset_phy_processor(jme);
-
+	jme_phy_calibration(jme);
+	jme_phy_setEA(jme);
 	jme_start_irq(jme);
 	netif_device_attach(netdev);
 
@@ -3239,4 +3347,3 @@ MODULE_DESCRIPTION("JMicron JMC2x0 PCI Express Ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 MODULE_DEVICE_TABLE(pci, jme_pci_tbl);
-
diff --git a/drivers/net/ethernet/jme.h b/drivers/net/ethernet/jme.h
index 02ea27c..4304072 100644
--- a/drivers/net/ethernet/jme.h
+++ b/drivers/net/ethernet/jme.h
@@ -760,6 +760,25 @@ enum jme_rxmcs_bits {
 				  RXMCS_CHECKSUM,
 };
 
+/*	Extern PHY common register 2	*/
+
+#define PHY_GAD_TEST_MODE_1			0x00002000
+#define PHY_GAD_TEST_MODE_MSK			0x0000E000
+#define JM_PHY_SPEC_REG_READ			0x00004000
+#define JM_PHY_SPEC_REG_WRITE			0x00008000
+#define PHY_CALIBRATION_DELAY			20
+#define JM_PHY_SPEC_ADDR_REG			0x1E
+#define JM_PHY_SPEC_DATA_REG			0x1F
+
+#define JM_PHY_EXT_COMM_0_REG			0x30
+#define JM_PHY_EXT_COMM_1_REG			0x31
+#define JM_PHY_EXT_COMM_2_REG			0x32
+#define JM_PHY_EXT_COMM_2_CALI_ENABLE		0x01
+#define JM_PHY_EXT_COMM_2_CALI_MODE_0		0x02
+#define JM_PHY_EXT_COMM_2_CALI_LATCH		0x10
+#define PCI_PRIV_SHARE_NICCTRL			0xF5
+#define JME_FLAG_PHYEA_ENABLE			0x2
+
 /*
  * Wakeup Frame setup interface registers
  */
-- 
1.7.4.4
