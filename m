From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/7][TG3]: Add TG3_FLG2_IS_NIC flag.
Date: Wed, 06 Dec 2006 23:46:29 -0800
Message-ID: <1165477589.8488.29.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2162 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031752AbWLGG4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 01:56:22 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Add TG3_FLG2_IS_NIC flag.

Add Tg3_FLG2_IS_NIC flag to unambiguously determine whether the
device is NIC or onboard.  Previously, the EEPROM_WRITE_PROT flag was
overloaded to also mean onboard.  With the separation, we can
support some devices that are onboard but do not use eeprom write
protect.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index bfa7e3e..6a2f019 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1062,7 +1062,7 @@ static void tg3_frob_aux_power(struct tg
 {
 	struct tg3 *tp_peer = tp;
 
-	if ((tp->tg3_flags & TG3_FLAG_EEPROM_WRITE_PROT) != 0)
+	if ((tp->tg3_flags2 & TG3_FLG2_IS_NIC) == 0)
 		return;
 
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) ||
@@ -1213,8 +1213,8 @@ static int tg3_set_power_state(struct tg
 				      power_control);
 		udelay(100);	/* Delay after power state change */
 
-		/* Switch out of Vaux if it is not a LOM */
-		if (!(tp->tg3_flags & TG3_FLAG_EEPROM_WRITE_PROT))
+		/* Switch out of Vaux if it is a NIC */
+		if (tp->tg3_flags2 & TG3_FLG2_IS_NIC)
 			tw32_wait_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl, 100);
 
 		return 0;
@@ -6397,16 +6397,17 @@ static int tg3_reset_hw(struct tg3 *tp,
 	udelay(40);
 
 	/* tp->grc_local_ctrl is partially set up during tg3_get_invariants().
-	 * If TG3_FLAG_EEPROM_WRITE_PROT is set, we should read the
+	 * If TG3_FLG2_IS_NIC is zero, we should read the
 	 * register to preserve the GPIO settings for LOMs. The GPIOs,
 	 * whether used as inputs or outputs, are set by boot code after
 	 * reset.
 	 */
-	if (tp->tg3_flags & TG3_FLAG_EEPROM_WRITE_PROT) {
+	if (!(tp->tg3_flags2 & TG3_FLG2_IS_NIC)) {
 		u32 gpio_mask;
 
-		gpio_mask = GRC_LCLCTRL_GPIO_OE0 | GRC_LCLCTRL_GPIO_OE2 |
-			    GRC_LCLCTRL_GPIO_OUTPUT0 | GRC_LCLCTRL_GPIO_OUTPUT2;
+		gpio_mask = GRC_LCLCTRL_GPIO_OE0 | GRC_LCLCTRL_GPIO_OE1 |
+			    GRC_LCLCTRL_GPIO_OE2 | GRC_LCLCTRL_GPIO_OUTPUT0 |
+			    GRC_LCLCTRL_GPIO_OUTPUT1 | GRC_LCLCTRL_GPIO_OUTPUT2;
 
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752)
 			gpio_mask |= GRC_LCLCTRL_GPIO_OE3 |
@@ -6418,8 +6419,9 @@ static int tg3_reset_hw(struct tg3 *tp,
 		tp->grc_local_ctrl |= tr32(GRC_LOCAL_CTRL) & gpio_mask;
 
 		/* GPIO1 must be driven high for eeprom write protect */
-		tp->grc_local_ctrl |= (GRC_LCLCTRL_GPIO_OE1 |
-				       GRC_LCLCTRL_GPIO_OUTPUT1);
+		if (tp->tg3_flags & TG3_FLAG_EEPROM_WRITE_PROT)
+			tp->grc_local_ctrl |= (GRC_LCLCTRL_GPIO_OE1 |
+					       GRC_LCLCTRL_GPIO_OUTPUT1);
 	}
 	tw32_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl);
 	udelay(100);
@@ -9963,8 +9965,10 @@ static void __devinit tg3_get_eeprom_hw_
 	tp->tg3_flags |= TG3_FLAG_EEPROM_WRITE_PROT;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-		if (!(tr32(PCIE_TRANSACTION_CFG) & PCIE_TRANS_CFG_LOM))
+		if (!(tr32(PCIE_TRANSACTION_CFG) & PCIE_TRANS_CFG_LOM)) {
 			tp->tg3_flags &= ~TG3_FLAG_EEPROM_WRITE_PROT;
+			tp->tg3_flags2 |= TG3_FLG2_IS_NIC;
+		}
 		return;
 	}
 
@@ -10064,10 +10068,17 @@ static void __devinit tg3_get_eeprom_hw_
 		    tp->pdev->subsystem_vendor == PCI_VENDOR_ID_DELL)
 			tp->led_ctrl = LED_CTRL_MODE_PHY_2;
 
-		if (nic_cfg & NIC_SRAM_DATA_CFG_EEPROM_WP)
+		if (nic_cfg & NIC_SRAM_DATA_CFG_EEPROM_WP) {
 			tp->tg3_flags |= TG3_FLAG_EEPROM_WRITE_PROT;
-		else
+			if ((tp->pdev->subsystem_vendor ==
+			     PCI_VENDOR_ID_ARIMA) &&
+			    (tp->pdev->subsystem_device == 0x205a ||
+			     tp->pdev->subsystem_device == 0x2063))
+				tp->tg3_flags &= ~TG3_FLAG_EEPROM_WRITE_PROT;
+		} else {
 			tp->tg3_flags &= ~TG3_FLAG_EEPROM_WRITE_PROT;
+			tp->tg3_flags2 |= TG3_FLG2_IS_NIC;
+		}
 
 		if (nic_cfg & NIC_SRAM_DATA_CFG_ASF_ENABLE) {
 			tp->tg3_flags |= TG3_FLAG_ENABLE_ASF;
@@ -10693,7 +10704,7 @@ static int __devinit tg3_get_invariants(
 		tp->tg3_flags |= TG3_FLAG_SRAM_USE_CONFIG;
 
 	/* Get eeprom hw config before calling tg3_set_power_state().
-	 * In particular, the TG3_FLAG_EEPROM_WRITE_PROT flag must be
+	 * In particular, the TG3_FLG2_IS_NIC flag must be
 	 * determined before calling tg3_set_power_state() so that
 	 * we know whether or not to switch out of Vaux power.
 	 * When the flag is set, it means that GPIO1 is used for eeprom
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 92f5300..dfaf4ed 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2233,6 +2233,7 @@ struct tg3 {
 #define TG3_FLG2_PCI_EXPRESS		0x00000200
 #define TG3_FLG2_ASF_NEW_HANDSHAKE	0x00000400
 #define TG3_FLG2_HW_AUTONEG		0x00000800
+#define TG3_FLG2_IS_NIC			0x00001000
 #define TG3_FLG2_PHY_SERDES		0x00002000
 #define TG3_FLG2_CAPACITIVE_COUPLING	0x00004000
 #define TG3_FLG2_FLASH			0x00008000
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 55710b7..f9a5824 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1999,6 +1999,8 @@
 #define PCI_DEVICE_ID_FARSITE_TE1       0x1610
 #define PCI_DEVICE_ID_FARSITE_TE1C      0x1612
 
+#define PCI_VENDOR_ID_ARIMA		0x161f
+
 #define PCI_VENDOR_ID_SIBYTE		0x166d
 #define PCI_DEVICE_ID_BCM1250_PCI	0x0001
 #define PCI_DEVICE_ID_BCM1250_HT	0x0002


