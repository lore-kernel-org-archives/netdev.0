From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 3/4] netxen: added sanity check for pci map
Date: Fri, 26 Mar 2010 03:30:09 -0700
Message-ID: <1269599410-17809-4-git-send-email-amit.salecha@qlogic.com>
References: <1269599410-17809-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:47165 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753295Ab0CZKaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Mar 2010 06:30:13 -0400
In-Reply-To: <1269599410-17809-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Return value of ioremap is not checked, NULL check added.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |   45 ++++++++++++++++++++-------------
 1 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9a7a0f3..01808b2 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -604,16 +604,14 @@ netxen_cleanup_pci_map(struct netxen_adapter *adapter)
 static int
 netxen_setup_pci_map(struct netxen_adapter *adapter)
 {
-	void __iomem *mem_ptr0 = NULL;
-	void __iomem *mem_ptr1 = NULL;
-	void __iomem *mem_ptr2 = NULL;
 	void __iomem *db_ptr = NULL;
 
 	resource_size_t mem_base, db_base;
-	unsigned long mem_len, db_len = 0, pci_len0 = 0;
+	unsigned long mem_len, db_len = 0;
 
 	struct pci_dev *pdev = adapter->pdev;
 	int pci_func = adapter->ahw.pci_func;
+	struct netxen_hardware_context *ahw = &adapter->ahw;
 
 	int err = 0;
 
@@ -630,24 +628,40 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 
 	/* 128 Meg of memory */
 	if (mem_len == NETXEN_PCI_128MB_SIZE) {
-		mem_ptr0 = ioremap(mem_base, FIRST_PAGE_GROUP_SIZE);
-		mem_ptr1 = ioremap(mem_base + SECOND_PAGE_GROUP_START,
+
+		ahw->pci_base0 = ioremap(mem_base, FIRST_PAGE_GROUP_SIZE);
+		ahw->pci_base1 = ioremap(mem_base + SECOND_PAGE_GROUP_START,
 				SECOND_PAGE_GROUP_SIZE);
-		mem_ptr2 = ioremap(mem_base + THIRD_PAGE_GROUP_START,
+		ahw->pci_base2 = ioremap(mem_base + THIRD_PAGE_GROUP_START,
 				THIRD_PAGE_GROUP_SIZE);
-		pci_len0 = FIRST_PAGE_GROUP_SIZE;
+		if (ahw->pci_base0 == NULL || ahw->pci_base1 == NULL ||
+						ahw->pci_base2 == NULL) {
+			dev_err(&pdev->dev, "failed to map PCI bar 0\n");
+			err = -EIO;
+			goto err_out;
+		}
+
+		ahw->pci_len0 = FIRST_PAGE_GROUP_SIZE;
+
 	} else if (mem_len == NETXEN_PCI_32MB_SIZE) {
-		mem_ptr1 = ioremap(mem_base, SECOND_PAGE_GROUP_SIZE);
-		mem_ptr2 = ioremap(mem_base + THIRD_PAGE_GROUP_START -
+
+		ahw->pci_base1 = ioremap(mem_base, SECOND_PAGE_GROUP_SIZE);
+		ahw->pci_base2 = ioremap(mem_base + THIRD_PAGE_GROUP_START -
 			SECOND_PAGE_GROUP_START, THIRD_PAGE_GROUP_SIZE);
+		if (ahw->pci_base1 == NULL || ahw->pci_base2 == NULL) {
+			dev_err(&pdev->dev, "failed to map PCI bar 0\n");
+			err = -EIO;
+			goto err_out;
+		}
+
 	} else if (mem_len == NETXEN_PCI_2MB_SIZE) {
 
-		mem_ptr0 = pci_ioremap_bar(pdev, 0);
-		if (mem_ptr0 == NULL) {
+		ahw->pci_base0 = pci_ioremap_bar(pdev, 0);
+		if (ahw->pci_base0 == NULL) {
 			dev_err(&pdev->dev, "failed to map PCI bar 0\n");
 			return -EIO;
 		}
-		pci_len0 = mem_len;
+		ahw->pci_len0 = mem_len;
 	} else {
 		return -EIO;
 	}
@@ -656,11 +670,6 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 
 	dev_info(&pdev->dev, "%dMB memory map\n", (int)(mem_len>>20));
 
-	adapter->ahw.pci_base0 = mem_ptr0;
-	adapter->ahw.pci_len0 = pci_len0;
-	adapter->ahw.pci_base1 = mem_ptr1;
-	adapter->ahw.pci_base2 = mem_ptr2;
-
 	if (NX_IS_REVISION_P3P(adapter->ahw.revision_id)) {
 		adapter->ahw.ocm_win_crb = netxen_get_ioaddr(adapter,
 			NETXEN_PCIX_PS_REG(PCIX_OCM_WINDOW_REG(pci_func)));
-- 
1.6.0.2

