From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 04/29] fm10k: Add support for basic interaction with hardware
Date: Tue, 23 Sep 2014 04:16:32 -0700
Message-ID: <1411471017-28213-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57365 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755254AbaIWLRH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:07 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds the basic read/write operations for accessing the hardware.

In addition to read read functionality the read functions also provide
surprise remove detection in the event that the device either loses power
or is removed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h           |  9 +++++-
 .../intel/fm10k/{fm10k.h => fm10k_common.h}        | 35 ++++++++++++----------
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c       | 30 +++++++++++++++++++
 3 files changed, 58 insertions(+), 16 deletions(-)
 copy drivers/net/ethernet/intel/fm10k/{fm10k.h => fm10k_common.h} (55%)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 2e27bd9..3da3a99 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -27,7 +27,14 @@
 #include <linux/if_vlan.h>
 #include <linux/pci.h>
 
-#include "fm10k_type.h"
+#include "fm10k_common.h"
+
+struct fm10k_intfc {
+	struct pci_dev *pdev;
+
+	struct fm10k_hw hw;
+	u32 __iomem *uc_addr;
+};
 
 /* main */
 extern char fm10k_driver_name[];
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k_common.h
similarity index 55%
copy from drivers/net/ethernet/intel/fm10k/fm10k.h
copy to drivers/net/ethernet/intel/fm10k/fm10k_common.h
index 2e27bd9..2b214a6 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_common.h
@@ -18,22 +18,27 @@
  * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
  */
 
-#ifndef _FM10K_H_
-#define _FM10K_H_
-
-#include <linux/types.h>
-#include <linux/etherdevice.h>
-#include <linux/rtnetlink.h>
-#include <linux/if_vlan.h>
-#include <linux/pci.h>
+#ifndef _FM10K_COMMON_H_
+#define _FM10K_COMMON_H_
 
 #include "fm10k_type.h"
 
-/* main */
-extern char fm10k_driver_name[];
-extern const char fm10k_driver_version[];
+#define FM10K_REMOVED(hw_addr) unlikely(!(hw_addr))
+
+/* PCI configuration read */
+u16 fm10k_read_pci_cfg_word(struct fm10k_hw *hw, u32 reg);
+
+/* read operations, indexed using DWORDS */
+u32 fm10k_read_reg(struct fm10k_hw *hw, int reg);
+
+/* write operations, indexed using DWORDS */
+#define fm10k_write_reg(hw, reg, val) \
+do { \
+	u32 __iomem *hw_addr = ACCESS_ONCE((hw)->hw_addr); \
+	if (!FM10K_REMOVED(hw_addr)) \
+		writel((val), &hw_addr[(reg)]); \
+} while (0)
 
-/* PCI */
-int fm10k_register_pci_driver(void);
-void fm10k_unregister_pci_driver(void);
-#endif /* _FM10K_H_ */
+/* read ctrl register which has no clear on read fields as PCIe flush */
+#define fm10k_write_flush(hw) fm10k_read_reg((hw), FM10K_CTRL)
+#endif /* _FM10K_COMMON_H_ */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 12089ce..6d5e33c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -38,6 +38,36 @@ static const struct pci_device_id fm10k_pci_tbl[] = {
 };
 MODULE_DEVICE_TABLE(pci, fm10k_pci_tbl);
 
+u16 fm10k_read_pci_cfg_word(struct fm10k_hw *hw, u32 reg)
+{
+	struct fm10k_intfc *interface = hw->back;
+	u16 value = 0;
+
+	if (FM10K_REMOVED(hw->hw_addr))
+		return ~value;
+
+	pci_read_config_word(interface->pdev, reg, &value);
+	if (value == 0xFFFF)
+		fm10k_write_flush(hw);
+
+	return value;
+}
+
+u32 fm10k_read_reg(struct fm10k_hw *hw, int reg)
+{
+	u32 __iomem *hw_addr = ACCESS_ONCE(hw->hw_addr);
+	u32 value = 0;
+
+	if (FM10K_REMOVED(hw_addr))
+		return ~value;
+
+	value = readl(&hw_addr[reg]);
+	if (!(~value) && (!reg || !(~readl(hw_addr))))
+		hw->hw_addr = NULL;
+
+	return value;
+}
+
 /**
  * fm10k_probe - Device Initialization Routine
  * @pdev: PCI device information struct
-- 
1.9.3
