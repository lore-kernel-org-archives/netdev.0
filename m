From: akpm@linux-foundation.org
Subject: [patch 07/18] PCI-X/PCI-Express read control interfaces: use them in e1000
Date: Fri, 10 Aug 2007 14:05:18 -0700
Message-ID: <200708102105.l7AL5IVc008964@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	peter.oruba@amd.com, auke-jan.h.kok@intel.com,
	shemminger@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59150 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758720AbXHJVGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:06:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Peter Oruba" <peter.oruba@amd.com>

These driver changes incorporate the proposed PCI-X / PCI-Express read byte
count interface.  Reading and setting those valuse doesn't take place
"manually", instead wrapping functions are called to allow quirks for some
PCI bridges.

Signed-off by: Peter Oruba <peter.oruba@amd.com>
Based on work by Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/e1000/e1000_hw.c   |   25 +++----------------------
 drivers/net/e1000/e1000_hw.h   |    2 ++
 drivers/net/e1000/e1000_main.c |   14 ++++++++++++++
 3 files changed, 19 insertions(+), 22 deletions(-)

diff -puN drivers/net/e1000/e1000_hw.c~pci-x-pci-express-read-control-interfaces-e1000 drivers/net/e1000/e1000_hw.c
--- a/drivers/net/e1000/e1000_hw.c~pci-x-pci-express-read-control-interfaces-e1000
+++ a/drivers/net/e1000/e1000_hw.c
@@ -865,10 +865,6 @@ e1000_init_hw(struct e1000_hw *hw)
     uint32_t ctrl;
     uint32_t i;
     int32_t ret_val;
-    uint16_t pcix_cmd_word;
-    uint16_t pcix_stat_hi_word;
-    uint16_t cmd_mmrbc;
-    uint16_t stat_mmrbc;
     uint32_t mta_size;
     uint32_t reg_data;
     uint32_t ctrl_ext;
@@ -958,24 +954,9 @@ e1000_init_hw(struct e1000_hw *hw)
         break;
     default:
         /* Workaround for PCI-X problem when BIOS sets MMRBC incorrectly. */
-        if (hw->bus_type == e1000_bus_type_pcix) {
-            e1000_read_pci_cfg(hw, PCIX_COMMAND_REGISTER, &pcix_cmd_word);
-            e1000_read_pci_cfg(hw, PCIX_STATUS_REGISTER_HI,
-                &pcix_stat_hi_word);
-            cmd_mmrbc = (pcix_cmd_word & PCIX_COMMAND_MMRBC_MASK) >>
-                PCIX_COMMAND_MMRBC_SHIFT;
-            stat_mmrbc = (pcix_stat_hi_word & PCIX_STATUS_HI_MMRBC_MASK) >>
-                PCIX_STATUS_HI_MMRBC_SHIFT;
-            if (stat_mmrbc == PCIX_STATUS_HI_MMRBC_4K)
-                stat_mmrbc = PCIX_STATUS_HI_MMRBC_2K;
-            if (cmd_mmrbc > stat_mmrbc) {
-                pcix_cmd_word &= ~PCIX_COMMAND_MMRBC_MASK;
-                pcix_cmd_word |= stat_mmrbc << PCIX_COMMAND_MMRBC_SHIFT;
-                e1000_write_pci_cfg(hw, PCIX_COMMAND_REGISTER,
-                    &pcix_cmd_word);
-            }
-        }
-        break;
+	if (hw->bus_type == e1000_bus_type_pcix && e1000_pcix_get_mmrbc(hw) > 2048)
+		e1000_pcix_set_mmrbc(hw, 2048);
+	break;
     }
 
     /* More time needed for PHY to initialize */
diff -puN drivers/net/e1000/e1000_hw.h~pci-x-pci-express-read-control-interfaces-e1000 drivers/net/e1000/e1000_hw.h
--- a/drivers/net/e1000/e1000_hw.h~pci-x-pci-express-read-control-interfaces-e1000
+++ a/drivers/net/e1000/e1000_hw.h
@@ -424,6 +424,8 @@ void e1000_pci_clear_mwi(struct e1000_hw
 void e1000_read_pci_cfg(struct e1000_hw *hw, uint32_t reg, uint16_t * value);
 void e1000_write_pci_cfg(struct e1000_hw *hw, uint32_t reg, uint16_t * value);
 int32_t e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, uint16_t *value);
+void e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc);
+int e1000_pcix_get_mmrbc(struct e1000_hw *hw);
 /* Port I/O is only supported on 82544 and newer */
 void e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value);
 int32_t e1000_disable_pciex_master(struct e1000_hw *hw);
diff -puN drivers/net/e1000/e1000_main.c~pci-x-pci-express-read-control-interfaces-e1000 drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c~pci-x-pci-express-read-control-interfaces-e1000
+++ a/drivers/net/e1000/e1000_main.c
@@ -4906,6 +4906,20 @@ e1000_write_pci_cfg(struct e1000_hw *hw,
 	pci_write_config_word(adapter->pdev, reg, *value);
 }
 
+int
+e1000_pcix_get_mmrbc(struct e1000_hw *hw)
+{
+	struct e1000_adapter *adapter = hw->back;
+	return pcix_get_mmrbc(adapter->pdev);
+}
+
+void
+e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc)
+{
+	struct e1000_adapter *adapter = hw->back;
+	pcix_set_mmrbc(adapter->pdev, mmrbc);
+}
+
 int32_t
 e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, uint16_t *value)
 {
_
