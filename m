From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000e: enable/disable ASPM L0s and L1 and ERT
	according to hardware errata
Date: Tue, 27 Apr 2010 06:33:04 -0700
Message-ID: <20100427133232.25490.92973.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Matthew Garret <mjg@redhat.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:35966
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755789Ab0D0NdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 09:33:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Prompted by a previous patch submitted by Matthew Garret <mjg@redhat.com>,
further digging into errata documentation reveals the current enabling or
disabling of ASPM L0s and L1 states for certain parts supported by this
driver are incorrect.  82571 and 82572 should always disable L1.  For
standard frames, 82573/82574/82583 can enable L1 but L0s must be disabled,
and for jumbo frames 82573/82574 must disable L1.  This allows for some
parts to enable L1 in certain configurations leading to better power
savings.

Also according to the same errata, Early Receive (ERT) should be disabled
on 82573 when using jumbo frames.

Cc: Matthew Garret <mjg@redhat.com>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c  |   20 ++++++------
 drivers/net/e1000e/e1000.h  |    5 ++-
 drivers/net/e1000e/netdev.c |   70 ++++++++++++++++++++++++++-----------------
 3 files changed, 55 insertions(+), 40 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 712ccc6..9015555 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -336,7 +336,6 @@ static s32 e1000_get_variants_82571(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	static int global_quad_port_a; /* global port a indication */
 	struct pci_dev *pdev = adapter->pdev;
-	u16 eeprom_data = 0;
 	int is_port_b = er32(STATUS) & E1000_STATUS_FUNC_1;
 	s32 rc;
 
@@ -387,16 +386,15 @@ static s32 e1000_get_variants_82571(struct e1000_adapter *adapter)
 		if (pdev->device == E1000_DEV_ID_82571EB_SERDES_QUAD)
 			adapter->flags &= ~FLAG_HAS_WOL;
 		break;
-
 	case e1000_82573:
+	case e1000_82574:
+	case e1000_82583:
+		/* Disable ASPM L0s due to hardware errata */
+		e1000e_disable_aspm(adapter->pdev, PCIE_LINK_STATE_L0S);
+
 		if (pdev->device == E1000_DEV_ID_82573L) {
-			if (e1000_read_nvm(&adapter->hw, NVM_INIT_3GIO_3, 1,
-				       &eeprom_data) < 0)
-				break;
-			if (!(eeprom_data & NVM_WORD1A_ASPM_MASK)) {
-				adapter->flags |= FLAG_HAS_JUMBO_FRAMES;
-				adapter->max_hw_frame_size = DEFAULT_JUMBO;
-			}
+			adapter->flags |= FLAG_HAS_JUMBO_FRAMES;
+			adapter->max_hw_frame_size = DEFAULT_JUMBO;
 		}
 		break;
 	default:
@@ -1792,6 +1790,7 @@ struct e1000_info e1000_82571_info = {
 				  | FLAG_RESET_OVERWRITES_LAA /* errata */
 				  | FLAG_TARC_SPEED_MODE_BIT /* errata */
 				  | FLAG_APME_CHECK_PORT_B,
+	.flags2			= FLAG2_DISABLE_ASPM_L1, /* errata 13 */
 	.pba			= 38,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
@@ -1809,6 +1808,7 @@ struct e1000_info e1000_82572_info = {
 				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_TARC_SPEED_MODE_BIT, /* errata */
+	.flags2			= FLAG2_DISABLE_ASPM_L1, /* errata 13 */
 	.pba			= 38,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
@@ -1820,13 +1820,11 @@ struct e1000_info e1000_82572_info = {
 struct e1000_info e1000_82573_info = {
 	.mac			= e1000_82573,
 	.flags			= FLAG_HAS_HW_VLAN_FILTER
-				  | FLAG_HAS_JUMBO_FRAMES
 				  | FLAG_HAS_WOL
 				  | FLAG_APME_IN_CTRL3
 				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
-				  | FLAG_HAS_ERT
 				  | FLAG_HAS_SWSM_ON_LOAD,
 	.pba			= 20,
 	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 118bdf4..ee32b9b 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -37,6 +37,7 @@
 #include <linux/io.h>
 #include <linux/netdevice.h>
 #include <linux/pci.h>
+#include <linux/pci-aspm.h>
 
 #include "hw.h"
 
@@ -374,7 +375,7 @@ struct e1000_adapter {
 struct e1000_info {
 	enum e1000_mac_type	mac;
 	unsigned int		flags;
-	unsigned int            flags2;
+	unsigned int		flags2;
 	u32			pba;
 	u32			max_hw_frame_size;
 	s32			(*get_variants)(struct e1000_adapter *);
@@ -421,6 +422,7 @@ struct e1000_info {
 #define FLAG2_CRC_STRIPPING               (1 << 0)
 #define FLAG2_HAS_PHY_WAKEUP              (1 << 1)
 #define FLAG2_IS_DISCARDING               (1 << 2)
+#define FLAG2_DISABLE_ASPM_L1             (1 << 3)
 
 #define E1000_RX_DESC_PS(R, i)	    \
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
@@ -461,6 +463,7 @@ extern void e1000e_update_stats(struct e1000_adapter *adapter);
 extern bool e1000e_has_link(struct e1000_adapter *adapter);
 extern void e1000e_set_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_reset_interrupt_capability(struct e1000_adapter *adapter);
+extern void e1000e_disable_aspm(struct pci_dev *pdev, u16 state);
 
 extern unsigned int copybreak;
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 73d43c5..fb8fc7d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4283,6 +4283,14 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 	}
 
+	/* 82573 Errata 17 */
+	if (((adapter->hw.mac.type == e1000_82573) ||
+	     (adapter->hw.mac.type == e1000_82574)) &&
+	    (max_frame > ETH_FRAME_LEN + ETH_FCS_LEN)) {
+		adapter->flags2 |= FLAG2_DISABLE_ASPM_L1;
+		e1000e_disable_aspm(adapter->pdev, PCIE_LINK_STATE_L1);
+	}
+
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
 		msleep(1);
 	/* e1000e_down -> e1000e_reset dependent on max_frame_size & mtu */
@@ -4605,29 +4613,39 @@ static void e1000_complete_shutdown(struct pci_dev *pdev, bool sleep,
 	}
 }
 
-static void e1000e_disable_l1aspm(struct pci_dev *pdev)
+#ifdef CONFIG_PCIEASPM
+static void __e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
+{
+	pci_disable_link_state(pdev, state);
+}
+#else
+static void __e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
 {
 	int pos;
-	u16 val;
+	u16 reg16;
 
 	/*
-	 * 82573 workaround - disable L1 ASPM on mobile chipsets
-	 *
-	 * L1 ASPM on various mobile (ich7) chipsets do not behave properly
-	 * resulting in lost data or garbage information on the pci-e link
-	 * level. This could result in (false) bad EEPROM checksum errors,
-	 * long ping times (up to 2s) or even a system freeze/hang.
-	 *
-	 * Unfortunately this feature saves about 1W power consumption when
-	 * active.
+	 * Both device and parent should have the same ASPM setting.
+	 * Disable ASPM in downstream component first and then upstream.
 	 */
-	pos = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	pci_read_config_word(pdev, pos + PCI_EXP_LNKCTL, &val);
-	if (val & 0x2) {
-		dev_warn(&pdev->dev, "Disabling L1 ASPM\n");
-		val &= ~0x2;
-		pci_write_config_word(pdev, pos + PCI_EXP_LNKCTL, val);
-	}
+	pos = pci_pcie_cap(pdev);
+	pci_read_config_word(pdev, pos + PCI_EXP_LNKCTL, &reg16);
+	reg16 &= ~state;
+	pci_write_config_word(pdev, pos + PCI_EXP_LNKCTL, reg16);
+
+	pos = pci_pcie_cap(pdev->bus->self);
+	pci_read_config_word(pdev->bus->self, pos + PCI_EXP_LNKCTL, &reg16);
+	reg16 &= ~state;
+	pci_write_config_word(pdev->bus->self, pos + PCI_EXP_LNKCTL, reg16);
+}
+#endif
+void e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
+{
+	dev_info(&pdev->dev, "Disabling ASPM %s %s\n",
+		 (state & PCIE_LINK_STATE_L0S) ? "L0s" : "",
+		 (state & PCIE_LINK_STATE_L1) ? "L1" : "");
+
+	__e1000e_disable_aspm(pdev, state);
 }
 
 #ifdef CONFIG_PM
@@ -4653,7 +4671,8 @@ static int e1000_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	pci_save_state(pdev);
-	e1000e_disable_l1aspm(pdev);
+	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L1)
+		e1000e_disable_aspm(pdev, PCIE_LINK_STATE_L1);
 
 	err = pci_enable_device_mem(pdev);
 	if (err) {
@@ -4795,7 +4814,8 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	int err;
 	pci_ers_result_t result;
 
-	e1000e_disable_l1aspm(pdev);
+	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L1)
+		e1000e_disable_aspm(pdev, PCIE_LINK_STATE_L1);
 	err = pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
@@ -4889,13 +4909,6 @@ static void e1000_eeprom_checks(struct e1000_adapter *adapter)
 		dev_warn(&adapter->pdev->dev,
 			 "Warning: detected DSPD enabled in EEPROM\n");
 	}
-
-	ret_val = e1000_read_nvm(hw, NVM_INIT_3GIO_3, 1, &buf);
-	if (!ret_val && (le16_to_cpu(buf) & (3 << 2))) {
-		/* ASPM enable */
-		dev_warn(&adapter->pdev->dev,
-			 "Warning: detected ASPM enabled in EEPROM\n");
-	}
 }
 
 static const struct net_device_ops e1000e_netdev_ops = {
@@ -4944,7 +4957,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
 
-	e1000e_disable_l1aspm(pdev);
+	if (ei->flags2 & FLAG2_DISABLE_ASPM_L1)
+		e1000e_disable_aspm(pdev, PCIE_LINK_STATE_L1);
 
 	err = pci_enable_device_mem(pdev);
 	if (err)

