From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/4] netxen: to fix onchip memory access.
Date: Wed, 12 May 2010 02:53:04 -0700
Message-ID: <1273657985-13405-4-git-send-email-amit.salecha@qlogic.com>
References: <1273657985-13405-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:20059 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755317Ab0ELJxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 05:53:08 -0400
In-Reply-To: <1273657985-13405-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Remove unnecessary remap of the region in bar 0 to access onhip memory
for NX3031.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_hw.c |   42 ++++++++++++++---------------------
 1 files changed, 17 insertions(+), 25 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 87bc910..be63988 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -32,7 +32,6 @@
 #define MASK(n) ((1ULL<<(n))-1)
 #define MN_WIN(addr) (((addr & 0x1fc0000) >> 1) | ((addr >> 25) & 0x3ff))
 #define OCM_WIN(addr) (((addr & 0x1ff0000) >> 1) | ((addr >> 25) & 0x3ff))
-#define OCM_WIN_P3P(addr) (addr & 0xffc0000)
 #define MS_WIN(addr) (addr & 0x0ffc0000)
 
 #define GET_MEM_OFFS_2M(addr) (addr & MASK(18))
@@ -1391,18 +1390,8 @@ netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 		u64 addr, u32 *start)
 {
 	u32 window;
-	struct pci_dev *pdev = adapter->pdev;
 
-	if ((addr & 0x00ff800) == 0xff800) {
-		if (printk_ratelimit())
-			dev_warn(&pdev->dev, "QM access not handled\n");
-		return -EIO;
-	}
-
-	if (NX_IS_REVISION_P3P(adapter->ahw.revision_id))
-		window = OCM_WIN_P3P(addr);
-	else
-		window = OCM_WIN(addr);
+	window = OCM_WIN(addr);
 
 	writel(window, adapter->ahw.ocm_win_crb);
 	/* read back to flush */
@@ -1419,7 +1408,7 @@ netxen_nic_pci_mem_access_direct(struct netxen_adapter *adapter, u64 off,
 {
 	void __iomem *addr, *mem_ptr = NULL;
 	resource_size_t mem_base;
-	int ret = -EIO;
+	int ret;
 	u32 start;
 
 	spin_lock(&adapter->ahw.mem_lock);
@@ -1428,20 +1417,23 @@ netxen_nic_pci_mem_access_direct(struct netxen_adapter *adapter, u64 off,
 	if (ret != 0)
 		goto unlock;
 
-	addr = pci_base_offset(adapter, start);
-	if (addr)
-		goto noremap;
-
-	mem_base = pci_resource_start(adapter->pdev, 0) + (start & PAGE_MASK);
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+		addr = adapter->ahw.pci_base0 + start;
+	} else {
+		addr = pci_base_offset(adapter, start);
+		if (addr)
+			goto noremap;
+
+		mem_base = pci_resource_start(adapter->pdev, 0) +
+					(start & PAGE_MASK);
+		mem_ptr = ioremap(mem_base, PAGE_SIZE);
+		if (mem_ptr == NULL) {
+			ret = -EIO;
+			goto unlock;
+		}
 
-	mem_ptr = ioremap(mem_base, PAGE_SIZE);
-	if (mem_ptr == NULL) {
-		ret = -EIO;
-		goto unlock;
+		addr = mem_ptr + (start & (PAGE_SIZE-1));
 	}
-
-	addr = mem_ptr + (start & (PAGE_SIZE - 1));
-
 noremap:
 	if (op == 0)	/* read */
 		*data = readq(addr);
-- 
1.6.0.2

