From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv1 NEXT 4/9] qlcnic: fix onchip memory access
Date: Thu,  1 Apr 2010 22:01:31 -0700
Message-ID: <1270184496-18985-5-git-send-email-amit.salecha@qlogic.com>
References: <1270184496-18985-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Dhananjay Phadke <dhananjay.phadke@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:22197 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754374Ab0DBFBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 01:01:38 -0400
In-Reply-To: <1270184496-18985-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>

Fix incorrect offset calculation and remove unnecessary remap
of the region in bar 0 to access onchip memory.

This was leading to read incorrect values by debug tools.

Signed-off-by: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_hw.c |   39 ++-------------------------------------
 1 files changed, 2 insertions(+), 37 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 419f46e..0933c2d 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -53,18 +53,6 @@ static inline void writeq(u64 val, void __iomem *addr)
 }
 #endif
 
-#define PCI_OFFSET_FIRST_RANGE(adapter, off)    \
-	((adapter)->ahw.pci_base0 + (off))
-
-static void __iomem *pci_base_offset(struct qlcnic_adapter *adapter,
-					    unsigned long off)
-{
-	if (ADDR_IN_RANGE(off, FIRST_PAGE_GROUP_START, FIRST_PAGE_GROUP_END))
-		return PCI_OFFSET_FIRST_RANGE(adapter, off);
-
-	return NULL;
-}
-
 static const struct crb_128M_2M_block_map
 crb_128M_2M_map[64] __cacheline_aligned_in_smp = {
     {{{0, 0,         0,         0} } },		/* 0: PCI */
@@ -871,13 +859,6 @@ qlcnic_pci_set_window_2M(struct qlcnic_adapter *adapter,
 		u64 addr, u32 *start)
 {
 	u32 window;
-	struct pci_dev *pdev = adapter->pdev;
-
-	if ((addr & 0x00ff800) == 0xff800) {
-		if (printk_ratelimit())
-			dev_warn(&pdev->dev, "QM access not handled\n");
-		return -EIO;
-	}
 
 	window = OCM_WIN_P3P(addr);
 
@@ -894,8 +875,7 @@ static int
 qlcnic_pci_mem_access_direct(struct qlcnic_adapter *adapter, u64 off,
 		u64 *data, int op)
 {
-	void __iomem *addr, *mem_ptr = NULL;
-	resource_size_t mem_base;
+	void __iomem *addr;
 	int ret;
 	u32 start;
 
@@ -905,21 +885,8 @@ qlcnic_pci_mem_access_direct(struct qlcnic_adapter *adapter, u64 off,
 	if (ret != 0)
 		goto unlock;
 
-	addr = pci_base_offset(adapter, start);
-	if (addr)
-		goto noremap;
-
-	mem_base = pci_resource_start(adapter->pdev, 0) + (start & PAGE_MASK);
-
-	mem_ptr = ioremap(mem_base, PAGE_SIZE);
-	if (mem_ptr == NULL) {
-		ret = -EIO;
-		goto unlock;
-	}
-
-	addr = mem_ptr + (start & (PAGE_SIZE - 1));
+	addr = adapter->ahw.pci_base0 + start;
 
-noremap:
 	if (op == 0)	/* read */
 		*data = readq(addr);
 	else		/* write */
@@ -928,8 +895,6 @@ noremap:
 unlock:
 	mutex_unlock(&adapter->ahw.mem_lock);
 
-	if (mem_ptr)
-		iounmap(mem_ptr);
 	return ret;
 }
 
-- 
1.6.0.2

