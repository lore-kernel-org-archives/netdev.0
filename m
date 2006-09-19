From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 15/23] e1000: add PCI-E capability detection code
Date: Tue, 19 Sep 2006 10:29:07 -0700
Message-ID: <20060919172906.4605.73189.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:25357 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030348AbWISRUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:20:12 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add code to display the detected PCI-E bus width.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.c   |   17 +++++++++++++----
 drivers/net/e1000/e1000_hw.h   |    6 ++++++
 drivers/net/e1000/e1000_main.c |   16 ++++++++++++++++
 3 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index a143b49..9280c27 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -6543,6 +6543,8 @@ e1000_tbi_adjust_stats(struct e1000_hw *
 void
 e1000_get_bus_info(struct e1000_hw *hw)
 {
+    int32_t ret_val;
+    uint16_t pci_ex_link_status;
     uint32_t status;
 
     switch (hw->mac_type) {
@@ -6552,18 +6554,25 @@ e1000_get_bus_info(struct e1000_hw *hw)
         hw->bus_speed = e1000_bus_speed_unknown;
         hw->bus_width = e1000_bus_width_unknown;
         break;
+    case e1000_82571:
     case e1000_82572:
     case e1000_82573:
+    case e1000_80003es2lan:
         hw->bus_type = e1000_bus_type_pci_express;
         hw->bus_speed = e1000_bus_speed_2500;
-        hw->bus_width = e1000_bus_width_pciex_1;
+        ret_val = e1000_read_pcie_cap_reg(hw,
+                                      PCI_EX_LINK_STATUS,
+                                      &pci_ex_link_status);
+        if (ret_val)
+            hw->bus_width = e1000_bus_width_unknown;
+        else
+            hw->bus_width = (pci_ex_link_status & PCI_EX_LINK_WIDTH_MASK) >>
+                          PCI_EX_LINK_WIDTH_SHIFT;
         break;
-    case e1000_82571:
     case e1000_ich8lan:
-    case e1000_80003es2lan:
         hw->bus_type = e1000_bus_type_pci_express;
         hw->bus_speed = e1000_bus_speed_2500;
-        hw->bus_width = e1000_bus_width_pciex_4;
+        hw->bus_width = e1000_bus_width_pciex_1;
         break;
     default:
         status = E1000_READ_REG(hw, STATUS);
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 58b9221..ac013bf 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -409,6 +409,7 @@ void e1000_pci_set_mwi(struct e1000_hw *
 void e1000_pci_clear_mwi(struct e1000_hw *hw);
 void e1000_read_pci_cfg(struct e1000_hw *hw, uint32_t reg, uint16_t * value);
 void e1000_write_pci_cfg(struct e1000_hw *hw, uint32_t reg, uint16_t * value);
+int32_t e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, uint16_t *value);
 /* Port I/O is only supported on 82544 and newer */
 void e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value);
 int32_t e1000_disable_pciex_master(struct e1000_hw *hw);
@@ -2216,6 +2217,11 @@ struct e1000_host_command_info {
 #define E1000_FACTPS_LAN_FUNC_SEL                   0x40000000
 #define E1000_FACTPS_PM_STATE_CHANGED               0x80000000
 
+/* PCI-Ex Config Space */
+#define PCI_EX_LINK_STATUS           0x12
+#define PCI_EX_LINK_WIDTH_MASK       0x3F0
+#define PCI_EX_LINK_WIDTH_SHIFT      4
+
 /* EEPROM Commands - Microwire */
 #define EEPROM_READ_OPCODE_MICROWIRE  0x6  /* EEPROM read opcode */
 #define EEPROM_WRITE_OPCODE_MICROWIRE 0x5  /* EEPROM write opcode */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 9c41a44..07082e7 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4474,6 +4474,22 @@ e1000_write_pci_cfg(struct e1000_hw *hw,
 	pci_write_config_word(adapter->pdev, reg, *value);
 }
 
+int32_t
+e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, uint16_t *value)
+{
+    struct e1000_adapter *adapter = hw->back;
+    uint16_t cap_offset;
+
+    cap_offset = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
+    if (!cap_offset)
+        return -E1000_ERR_CONFIG;
+
+    pci_read_config_word(adapter->pdev, cap_offset + reg, value);
+
+    return E1000_SUCCESS;
+}
+
+
 void
 e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value)
 {



---
Auke Kok <auke-jan.h.kok@intel.com>
