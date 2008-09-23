From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/3] e1000e: Useset_memory_ro()/set_memory_rw() to protect
	flash memory
Date: Tue, 23 Sep 2008 15:45:54 -0700
Message-ID: <20080923224535.6869.76210.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, mingo@elte.hu, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:54041 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbYIWWpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 18:45:49 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2390225rvb.1
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 15:45:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

A number of users have reported NVM corruption on various ICHx platform
LOMs.  One possible reasons for this could be unexpected and/or malicious
writes to the flash memory area mapped into kernel memory.  Once the
interface is up, there should be very few reads/writes of the mapped flash
memory.  This patch makes use of the x86 set_memory_*() functions to set
the mapped memory read-only and temporarily set it writable only when the
driver needs to write to it.  With the memory set read-only, any unexpected
write will be logged with a stack dump indicating the offending code.

Since these LOMs are only on x86 ICHx platforms, it does not matter that
this API is not yet available on other architectures, however it is
dependent on a previous patch that exports these function name symbols.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/hw.h      |    1 +
 drivers/net/e1000e/ich8lan.c |   16 ++++++++++++++++
 drivers/net/e1000e/netdev.c  |   11 +++++++----
 4 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index ac4e506..2786754 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -36,6 +36,7 @@
 #include <linux/workqueue.h>
 #include <linux/io.h>
 #include <linux/netdevice.h>
+#include <asm/cacheflush.h>
 
 #include "hw.h"
 
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 74f263a..dd25009 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -863,6 +863,7 @@ struct e1000_hw {
 
 	u8 __iomem *hw_addr;
 	u8 __iomem *flash_address;
+	resource_size_t flash_len;
 
 	struct e1000_mac_info  mac;
 	struct e1000_fc_info   fc;
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 9e38452..f47c60e 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -176,12 +176,28 @@ static inline u32 __er32flash(struct e1000_hw *hw, unsigned long reg)
 
 static inline void __ew16flash(struct e1000_hw *hw, unsigned long reg, u16 val)
 {
+#ifdef _ASM_X86_CACHEFLUSH_H
+	set_memory_rw((unsigned long)hw->flash_address,
+	              hw->flash_len >> PAGE_SHIFT);
+#endif
 	writew(val, hw->flash_address + reg);
+#ifdef _ASM_X86_CACHEFLUSH_H
+	set_memory_ro((unsigned long)hw->flash_address,
+	              hw->flash_len >> PAGE_SHIFT);
+#endif
 }
 
 static inline void __ew32flash(struct e1000_hw *hw, unsigned long reg, u32 val)
 {
+#ifdef _ASM_X86_CACHEFLUSH_H
+	set_memory_rw((unsigned long)hw->flash_address,
+	              hw->flash_len >> PAGE_SHIFT);
+#endif
 	writel(val, hw->flash_address + reg);
+#ifdef _ASM_X86_CACHEFLUSH_H
+	set_memory_ro((unsigned long)hw->flash_address,
+	              hw->flash_len >> PAGE_SHIFT);
+#endif
 }
 
 #define er16flash(reg)		__er16flash(hw, (reg))
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index d266510..0e51841 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4364,7 +4364,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	struct e1000_hw *hw;
 	const struct e1000_info *ei = e1000_info_tbl[ent->driver_data];
 	resource_size_t mmio_start, mmio_len;
-	resource_size_t flash_start, flash_len;
 
 	static int cards_found;
 	int i, err, pci_using_dac;
@@ -4434,11 +4433,15 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	if ((adapter->flags & FLAG_HAS_FLASH) &&
 	    (pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
-		flash_start = pci_resource_start(pdev, 1);
-		flash_len = pci_resource_len(pdev, 1);
-		adapter->hw.flash_address = ioremap(flash_start, flash_len);
+		adapter->hw.flash_len = pci_resource_len(pdev, 1);
+		adapter->hw.flash_address = ioremap(pci_resource_start(pdev, 1),
+		                                    adapter->hw.flash_len);
 		if (!adapter->hw.flash_address)
 			goto err_flashmap;
+#ifdef _ASM_X86_CACHEFLUSH_H
+		set_memory_ro((unsigned long)adapter->hw.flash_address,
+		              adapter->hw.flash_len >> PAGE_SHIFT);
+#endif
 	}
 
 	/* construct the net_device struct */

