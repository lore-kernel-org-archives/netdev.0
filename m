From: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 3/5] NetXen: Fix the driver for reduced PCIE footprint cards
Date: Fri, 9 Mar 2007 00:09:15 -0800
Message-ID: <200703090809.l2989FgP011784@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:18096 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752048AbXCIIJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 03:09:16 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix the driver for reduced PCIE footprint cards.

Signed-off-by: Mithlesh Thukral <mithlesh@netxen.com>

---

 drivers/net/netxen/netxen_nic.h      |    8 +++++-
 drivers/net/netxen/netxen_nic_hdr.h  |    2 +
 drivers/net/netxen/netxen_nic_main.c |   30 ++++++++++++++++++++-----
 3 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index c85c2cb..d5e9d46 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -770,6 +770,8 @@ struct netxen_hardware_context {
 	void __iomem *pci_base2;
 	void __iomem *db_base;
 	unsigned long db_len;
+	unsigned long first_page_group_start;
+	unsigned long first_page_group_end;
 
 	u8 revision_id;
 	u16 board_type;
@@ -946,7 +948,8 @@ #define PCI_OFFSET_THIRD_RANGE(adapter, 
 static inline void __iomem *pci_base_offset(struct netxen_adapter *adapter,
 					    unsigned long off)
 {
-	if ((off < FIRST_PAGE_GROUP_END) && (off >= FIRST_PAGE_GROUP_START)) {
+	if ((off < adapter->ahw.first_page_group_end) && 
+		(off >= adapter->ahw.first_page_group_start)) {
 		return (adapter->ahw.pci_base0 + off);
 	} else if ((off < SECOND_PAGE_GROUP_END) &&
 		   (off >= SECOND_PAGE_GROUP_START)) {
@@ -961,7 +964,8 @@ static inline void __iomem *pci_base_off
 static inline void __iomem *pci_base(struct netxen_adapter *adapter,
 				     unsigned long off)
 {
-	if ((off < FIRST_PAGE_GROUP_END) && (off >= FIRST_PAGE_GROUP_START)) {
+	if ((off < adapter->ahw.first_page_group_end) && 
+		(off >= adapter->ahw.first_page_group_start)) {
 		return adapter->ahw.pci_base0;
 	} else if ((off < SECOND_PAGE_GROUP_END) &&
 		   (off >= SECOND_PAGE_GROUP_START)) {
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index b826bca..20dbebc 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -467,6 +467,8 @@ #define NETXEN_PCI_OCM0_MAX	(0x050fffffU
 #define NETXEN_PCI_OCM1		(0x05100000UL)
 #define NETXEN_PCI_OCM1_MAX	(0x051fffffUL)
 #define NETXEN_PCI_CRBSPACE	(0x06000000UL)
+#define NETXEN_PCI_128MB_SIZE	(0x08000000UL)
+#define NETXEN_PCI_32MB_SIZE	(0x02000000UL)
 
 #define NETXEN_CRB_CAM	NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_CAM)
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 5fbf6b0..121a5f9 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -174,6 +174,7 @@ netxen_nic_probe(struct pci_dev *pdev, c
 
 	u8 __iomem *db_ptr = NULL;
 	unsigned long mem_base, mem_len, db_base, db_len;
+	unsigned long first_page_group_start, first_page_group_end;
 	int pci_using_dac, i = 0, err;
 	int ring;
 	struct netxen_recv_context *recv_ctx = NULL;
@@ -237,13 +238,28 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	mem_len = pci_resource_len(pdev, 0);
 
 	/* 128 Meg of memory */
-	mem_ptr0 = ioremap(mem_base, FIRST_PAGE_GROUP_SIZE);
-	mem_ptr1 =
-	    ioremap(mem_base + SECOND_PAGE_GROUP_START, SECOND_PAGE_GROUP_SIZE);
-	mem_ptr2 =
-	    ioremap(mem_base + THIRD_PAGE_GROUP_START, THIRD_PAGE_GROUP_SIZE);
+	if (mem_len == NETXEN_PCI_128MB_SIZE) {
+		mem_ptr0 = ioremap(mem_base, FIRST_PAGE_GROUP_SIZE);
+		mem_ptr1 = ioremap(mem_base + SECOND_PAGE_GROUP_START,
+			SECOND_PAGE_GROUP_SIZE);
+		mem_ptr2 = ioremap(mem_base + THIRD_PAGE_GROUP_START,
+			THIRD_PAGE_GROUP_SIZE);
+		first_page_group_start = FIRST_PAGE_GROUP_START;
+		first_page_group_end   = FIRST_PAGE_GROUP_END;
+	} else if (mem_len == NETXEN_PCI_32MB_SIZE) {
+		mem_ptr1 = ioremap(mem_base, SECOND_PAGE_GROUP_SIZE);
+		mem_ptr2 = ioremap(mem_base + THIRD_PAGE_GROUP_START -
+			SECOND_PAGE_GROUP_START, THIRD_PAGE_GROUP_SIZE);
+		first_page_group_start = 0;
+		first_page_group_end   = 0;
+	} else {
+		DPRINTK(1, ERR, "Invalid PCI memory mapped length\n");
+		err = -EIO;
+		goto err_out_free_res;
+	}
 
-	if ((mem_ptr0 == 0UL) || (mem_ptr1 == 0UL) || (mem_ptr2 == 0UL)) {
+	if (((mem_ptr0 == 0UL) && (mem_len == NETXEN_PCI_128MB_SIZE))
+		|| (mem_ptr1 == 0UL) || (mem_ptr2 == 0UL)) {
 		DPRINTK(ERR,
 			"Cannot remap adapter memory aborting.:"
 			"0 -> %p, 1 -> %p, 2 -> %p\n",
@@ -379,6 +395,8 @@ #endif
 
 	adapter->cmd_buf_arr = cmd_buf_arr;
 	adapter->ahw.pci_base0 = mem_ptr0;
+	adapter->ahw.first_page_group_start = first_page_group_start;
+	adapter->ahw.first_page_group_end = first_page_group_end;
 	adapter->ahw.pci_base1 = mem_ptr1;
 	adapter->ahw.pci_base2 = mem_ptr2;
 	adapter->ahw.db_base = db_ptr;
