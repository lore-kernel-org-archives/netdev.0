From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH 04/29] fm10k: Add support for basic interaction
 with hardware
Date: Thu, 18 Sep 2014 18:36:11 -0400
Message-ID: <20140918223610.10373.94757.stgit@ahduyck-bv4.jf.intel.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46427 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756536AbaIRWo7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 18:44:59 -0400
In-Reply-To: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the basic read/write operations for accessing the hardware.

In addition to read read functionality the read functions also provide
surprise remove detection in the event that the device either loses power
or is removed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h        |    9 ++++-
 drivers/net/ethernet/intel/fm10k/fm10k_common.h |   44 +++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    |   30 ++++++++++++++++
 3 files changed, 82 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_common.h

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
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_common.h b/drivers/net/ethernet/intel/fm10k/fm10k_common.h
new file mode 100644
index 0000000..2b214a6
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_common.h
@@ -0,0 +1,44 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#ifndef _FM10K_COMMON_H_
+#define _FM10K_COMMON_H_
+
+#include "fm10k_type.h"
+
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
+
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
