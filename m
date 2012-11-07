From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 4/7] be2net: re-factor bar mapping code
Date: Wed, 7 Nov 2012 09:18:58 +0530
Message-ID: <30263519-9995-41dd-8aa5-cdd329d699b9@CMEXHTCAS2.ad.emulex.com>
References: <1352260141-27725-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:25376 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876Ab2KGDqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 22:46:15 -0500
In-Reply-To: <1352260141-27725-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) separate NIC and roce bar mapping code
2) parse sli_intf::if_type inside be_map_pci_bars() as if_type must be
   used only to identify bars.
3) Use pci_iomap/unmap() routines

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |  137 ++++++++------------------
 1 files changed, 42 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 1767bab..95e279f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3620,79 +3620,69 @@ static void be_netdev_init(struct net_device *netdev)
 static void be_unmap_pci_bars(struct be_adapter *adapter)
 {
 	if (adapter->csr)
-		iounmap(adapter->csr);
+		pci_iounmap(adapter->pdev, adapter->csr);
 	if (adapter->db)
-		iounmap(adapter->db);
+		pci_iounmap(adapter->pdev, adapter->db);
 	if (adapter->roce_db.base)
 		pci_iounmap(adapter->pdev, adapter->roce_db.base);
 }
 
-static int lancer_roce_map_pci_bars(struct be_adapter *adapter)
+static int db_bar(struct be_adapter *adapter)
+{
+	if (lancer_chip(adapter) || !be_physfn(adapter))
+		return 0;
+	else
+		return 4;
+}
+
+static int be_roce_map_pci_bars(struct be_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	u8 __iomem *addr;
 
-	addr = pci_iomap(pdev, 2, 0);
-	if (addr == NULL)
-		return -ENOMEM;
+	if (lancer_chip(adapter) && adapter->if_type == SLI_INTF_TYPE_3) {
+		addr = pci_iomap(pdev, 2, 0);
+		if (addr == NULL)
+			return -ENOMEM;
 
-	adapter->roce_db.base = addr;
-	adapter->roce_db.io_addr = pci_resource_start(pdev, 2);
-	adapter->roce_db.size = 8192;
-	adapter->roce_db.total_size = pci_resource_len(pdev, 2);
+		adapter->roce_db.base = addr;
+		adapter->roce_db.io_addr = pci_resource_start(pdev, 2);
+		adapter->roce_db.size = 8192;
+		adapter->roce_db.total_size = pci_resource_len(pdev, 2);
+	} else if (skyhawk_chip(adapter)) {
+		adapter->roce_db.size = 4096;
+		adapter->roce_db.io_addr = pci_resource_start(adapter->pdev,
+							      db_bar(adapter));
+		adapter->roce_db.total_size = pci_resource_len(adapter->pdev,
+							       db_bar(adapter));
+	}
 	return 0;
 }
 
 static int be_map_pci_bars(struct be_adapter *adapter)
 {
 	u8 __iomem *addr;
-	int db_reg;
+	u32 sli_intf;
 
-	if (lancer_chip(adapter)) {
-		if (be_type_2_3(adapter)) {
-			addr = ioremap_nocache(
-					pci_resource_start(adapter->pdev, 0),
-					pci_resource_len(adapter->pdev, 0));
-			if (addr == NULL)
-				return -ENOMEM;
-			adapter->db = addr;
-		}
-		if (adapter->if_type == SLI_INTF_TYPE_3) {
-			if (lancer_roce_map_pci_bars(adapter))
-				goto pci_map_err;
-		}
-		return 0;
-	}
+	pci_read_config_dword(adapter->pdev, SLI_INTF_REG_OFFSET, &sli_intf);
+	adapter->if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
+				SLI_INTF_IF_TYPE_SHIFT;
 
-	if (be_physfn(adapter)) {
-		addr = ioremap_nocache(pci_resource_start(adapter->pdev, 2),
-				pci_resource_len(adapter->pdev, 2));
+	if (be_physfn(adapter) && !lancer_chip(adapter)) {
+		addr = pci_iomap(adapter->pdev, 2, 0);
 		if (addr == NULL)
 			return -ENOMEM;
 		adapter->csr = addr;
 	}
 
-	if (BE2_chip(adapter)) {
-		db_reg = 4;
-	} else {
-		if (be_physfn(adapter))
-			db_reg = 4;
-		else
-			db_reg = 0;
-	}
-	addr = ioremap_nocache(pci_resource_start(adapter->pdev, db_reg),
-				pci_resource_len(adapter->pdev, db_reg));
+	addr = pci_iomap(adapter->pdev, db_bar(adapter), 0);
 	if (addr == NULL)
 		goto pci_map_err;
 	adapter->db = addr;
-	if (skyhawk_chip(adapter)) {
-		adapter->roce_db.size = 4096;
-		adapter->roce_db.io_addr =
-				pci_resource_start(adapter->pdev, db_reg);
-		adapter->roce_db.total_size =
-				pci_resource_len(adapter->pdev, db_reg);
-	}
+
+	be_roce_map_pci_bars(adapter);
 	return 0;
+
 pci_map_err:
 	be_unmap_pci_bars(adapter);
 	return -ENOMEM;
@@ -3719,8 +3709,14 @@ static int be_ctrl_init(struct be_adapter *adapter)
 	struct be_dma_mem *mbox_mem_alloc = &adapter->mbox_mem_alloced;
 	struct be_dma_mem *mbox_mem_align = &adapter->mbox_mem;
 	struct be_dma_mem *rx_filter = &adapter->rx_filter;
+	u32 sli_intf;
 	int status;
 
+	pci_read_config_dword(adapter->pdev, SLI_INTF_REG_OFFSET, &sli_intf);
+	adapter->sli_family = (sli_intf & SLI_INTF_FAMILY_MASK) >>
+				 SLI_INTF_FAMILY_SHIFT;
+	adapter->virtfn = (sli_intf & SLI_INTF_FT_MASK) ? 1 : 0;
+
 	status = be_map_pci_bars(adapter);
 	if (status)
 		goto done;
@@ -3898,50 +3894,6 @@ static int be_get_initial_config(struct be_adapter *adapter)
 	return 0;
 }
 
-static int be_dev_type_check(struct be_adapter *adapter)
-{
-	struct pci_dev *pdev = adapter->pdev;
-	u32 sli_intf = 0, if_type;
-
-	switch (pdev->device) {
-	case BE_DEVICE_ID1:
-	case OC_DEVICE_ID1:
-		break;
-	case BE_DEVICE_ID2:
-	case OC_DEVICE_ID2:
-		break;
-	case OC_DEVICE_ID3:
-	case OC_DEVICE_ID4:
-		pci_read_config_dword(pdev, SLI_INTF_REG_OFFSET, &sli_intf);
-		adapter->if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
-						SLI_INTF_IF_TYPE_SHIFT;
-		if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
-						SLI_INTF_IF_TYPE_SHIFT;
-		if (((sli_intf & SLI_INTF_VALID_MASK) != SLI_INTF_VALID) ||
-			!be_type_2_3(adapter)) {
-			dev_err(&pdev->dev, "SLI_INTF reg val is not valid\n");
-			return -EINVAL;
-		}
-		adapter->sli_family = ((sli_intf & SLI_INTF_FAMILY_MASK) >>
-					 SLI_INTF_FAMILY_SHIFT);
-		break;
-	case OC_DEVICE_ID5:
-	case OC_DEVICE_ID6:
-		pci_read_config_dword(pdev, SLI_INTF_REG_OFFSET, &sli_intf);
-		if ((sli_intf & SLI_INTF_VALID_MASK) != SLI_INTF_VALID) {
-			dev_err(&pdev->dev, "SLI_INTF reg val is not valid\n");
-			return -EINVAL;
-		}
-		adapter->sli_family = ((sli_intf & SLI_INTF_FAMILY_MASK) >>
-					 SLI_INTF_FAMILY_SHIFT);
-		break;
-	}
-
-	pci_read_config_dword(adapter->pdev, SLI_INTF_REG_OFFSET, &sli_intf);
-	adapter->virtfn = (sli_intf & SLI_INTF_FT_MASK) ? 1 : 0;
-	return 0;
-}
-
 static int lancer_recover_func(struct be_adapter *adapter)
 {
 	int status;
@@ -4097,11 +4049,6 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	adapter = netdev_priv(netdev);
 	adapter->pdev = pdev;
 	pci_set_drvdata(pdev, adapter);
-
-	status = be_dev_type_check(adapter);
-	if (status)
-		goto free_netdev;
-
 	adapter->netdev = netdev;
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
-- 
1.7.1
