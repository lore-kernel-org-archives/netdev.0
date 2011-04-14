From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 09/24] e1000e: If ASPM L0s needs to be disabled, do it prior to enabling device
Date: Wed, 13 Apr 2011 18:02:05 -0700
Message-ID: <1302742940-22141-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Naga Chumbalkar <nagananda.chumbalkar@hp.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21314 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757895Ab1DNBCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:32 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Based on a patch from Naga Chumbalkar <nagananda.chumbalkar@hp.com>:

If ASPM L0s needs to be disabled due to HW errata, do it prior to
"enabling" the device. This way if the kernel ever defaults its
aspm_policy to POLICY_POWERSAVE, then the e1000e driver will get a
chance to disable ASPM on the misbehaving device *prior* to calling
pci_enable_device_mem(). This will be useful in situations
where the BIOS indicates ASPM support on the server by clearing the
ACPI FADT "ASPM Controls" bit.

Note:
The kernel (2.6.38) currently uses the BIOS "default" as its aspm_policy.
However, Linux distros can diverge from that and set the default to
"powersave".

v2: o cleanup namespace pollution of e1000e_disable_aspm(),
    o fix type and initialization of the new aspm_disable_flag in a few
      functions, and
    o redefine FLAG2_DISABLE_ASPM_L0S to the first unused bit in
      adapter->flags2.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Naga Chumbalkar <nagananda.chumbalkar@hp.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/82571.c  |   10 +++++-----
 drivers/net/e1000e/e1000.h  |    2 +-
 drivers/net/e1000e/netdev.c |   29 ++++++++++++++++++++++++-----
 3 files changed, 30 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 9fedbca..ae07d37 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -431,9 +431,6 @@ static s32 e1000_get_variants_82571(struct e1000_adapter *adapter)
 	case e1000_82573:
 	case e1000_82574:
 	case e1000_82583:
-		/* Disable ASPM L0s due to hardware errata */
-		e1000e_disable_aspm(adapter->pdev, PCIE_LINK_STATE_L0S);
-
 		if (pdev->device == E1000_DEV_ID_82573L) {
 			adapter->flags |= FLAG_HAS_JUMBO_FRAMES;
 			adapter->max_hw_frame_size = DEFAULT_JUMBO;
@@ -2066,7 +2063,8 @@ struct e1000_info e1000_82573_info = {
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_SWSM_ON_LOAD,
-	.flags2			= FLAG2_DISABLE_ASPM_L1,
+	.flags2			= FLAG2_DISABLE_ASPM_L1
+				  | FLAG2_DISABLE_ASPM_L0S,
 	.pba			= 20,
 	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
 	.get_variants		= e1000_get_variants_82571,
@@ -2086,7 +2084,8 @@ struct e1000_info e1000_82574_info = {
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
-	.flags2			  = FLAG2_CHECK_PHY_HANG,
+	.flags2			  = FLAG2_CHECK_PHY_HANG
+				  | FLAG2_DISABLE_ASPM_L0S,
 	.pba			= 32,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
@@ -2104,6 +2103,7 @@ struct e1000_info e1000_82583_info = {
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
+	.flags2			= FLAG2_DISABLE_ASPM_L0S,
 	.pba			= 32,
 	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
 	.get_variants		= e1000_get_variants_82571,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 500896e..3be5478 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -458,6 +458,7 @@ struct e1000_info {
 #define FLAG2_HAS_PHY_STATS               (1 << 4)
 #define FLAG2_HAS_EEE                     (1 << 5)
 #define FLAG2_DMA_BURST                   (1 << 6)
+#define FLAG2_DISABLE_ASPM_L0S            (1 << 7)
 #define FLAG2_DISABLE_AIM                 (1 << 8)
 #define FLAG2_CHECK_PHY_HANG              (1 << 9)
 
@@ -504,7 +505,6 @@ extern void e1000e_set_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_reset_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_get_hw_control(struct e1000_adapter *adapter);
 extern void e1000e_release_hw_control(struct e1000_adapter *adapter);
-extern void e1000e_disable_aspm(struct pci_dev *pdev, u16 state);
 
 extern unsigned int copybreak;
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 8a3145e..4deb67d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -58,6 +58,8 @@
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
+static void e1000e_disable_aspm(struct pci_dev *pdev, u16 state);
+
 static const struct e1000_info *e1000_info_tbl[] = {
 	[board_82571]		= &e1000_82571_info,
 	[board_82572]		= &e1000_82572_info,
@@ -5384,7 +5386,7 @@ static void __e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
 	pci_write_config_word(pdev->bus->self, pos + PCI_EXP_LNKCTL, reg16);
 }
 #endif
-void e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
+static void e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
 {
 	dev_info(&pdev->dev, "Disabling ASPM %s %s\n",
 		 (state & PCIE_LINK_STATE_L0S) ? "L0s" : "",
@@ -5404,13 +5406,19 @@ static int __e1000_resume(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	u16 aspm_disable_flag = 0;
 	u32 err;
 
+	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L0S)
+		aspm_disable_flag = PCIE_LINK_STATE_L0S;
+	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L1)
+		aspm_disable_flag |= PCIE_LINK_STATE_L1;
+	if (aspm_disable_flag)
+		e1000e_disable_aspm(pdev, aspm_disable_flag);
+
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	pci_save_state(pdev);
-	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L1)
-		e1000e_disable_aspm(pdev, PCIE_LINK_STATE_L1);
 
 	e1000e_set_interrupt_capability(adapter);
 	if (netif_running(netdev)) {
@@ -5654,11 +5662,17 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	u16 aspm_disable_flag = 0;
 	int err;
 	pci_ers_result_t result;
 
+	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L0S)
+		aspm_disable_flag = PCIE_LINK_STATE_L0S;
 	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L1)
-		e1000e_disable_aspm(pdev, PCIE_LINK_STATE_L1);
+		aspm_disable_flag |= PCIE_LINK_STATE_L1;
+	if (aspm_disable_flag)
+		e1000e_disable_aspm(pdev, aspm_disable_flag);
+
 	err = pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
@@ -5799,12 +5813,17 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	resource_size_t flash_start, flash_len;
 
 	static int cards_found;
+	u16 aspm_disable_flag = 0;
 	int i, err, pci_using_dac;
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
 
+	if (ei->flags2 & FLAG2_DISABLE_ASPM_L0S)
+		aspm_disable_flag = PCIE_LINK_STATE_L0S;
 	if (ei->flags2 & FLAG2_DISABLE_ASPM_L1)
-		e1000e_disable_aspm(pdev, PCIE_LINK_STATE_L1);
+		aspm_disable_flag |= PCIE_LINK_STATE_L1;
+	if (aspm_disable_flag)
+		e1000e_disable_aspm(pdev, aspm_disable_flag);
 
 	err = pci_enable_device_mem(pdev);
 	if (err)
-- 
1.7.4.2

