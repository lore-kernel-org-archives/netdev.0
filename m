From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 4/4] netxen: refactor pci probe
Date: Tue, 24 Feb 2009 11:39:10 -0800
Message-ID: <1235504350-31258-4-git-send-email-dhananjay@netxen.com>
References: <1235504350-31258-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:55346 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754440AbZBXTjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 14:39:13 -0500
In-Reply-To: <1235504350-31258-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split pci probe function into smaller logical blocks.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |  384 ++++++++++++++++++----------------
 1 files changed, 203 insertions(+), 181 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9d6e68f..c2b551f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -457,6 +457,202 @@ static const struct net_device_ops netxen_netdev_ops = {
 #endif
 };
 
+static void
+netxen_setup_intr(struct netxen_adapter *adapter)
+{
+	struct netxen_legacy_intr_set *legacy_intrp;
+	struct pci_dev *pdev = adapter->pdev;
+
+	adapter->flags &= ~(NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED);
+	adapter->intr_scheme = -1;
+	adapter->msi_mode = -1;
+
+	if (adapter->ahw.revision_id >= NX_P3_B0)
+		legacy_intrp = &legacy_intr[adapter->ahw.pci_func];
+	else
+		legacy_intrp = &legacy_intr[0];
+	adapter->legacy_intr.int_vec_bit = legacy_intrp->int_vec_bit;
+	adapter->legacy_intr.tgt_status_reg = legacy_intrp->tgt_status_reg;
+	adapter->legacy_intr.tgt_mask_reg = legacy_intrp->tgt_mask_reg;
+	adapter->legacy_intr.pci_int_reg = legacy_intrp->pci_int_reg;
+
+	netxen_set_msix_bit(pdev, 0);
+
+	if (adapter->msix_supported) {
+
+		netxen_init_msix_entries(adapter);
+		if (pci_enable_msix(pdev, adapter->msix_entries,
+					MSIX_ENTRIES_PER_ADAPTER))
+			goto request_msi;
+
+		adapter->flags |= NETXEN_NIC_MSIX_ENABLED;
+		netxen_set_msix_bit(pdev, 1);
+		dev_info(&pdev->dev, "using msi-x interrupts\n");
+
+	} else {
+request_msi:
+		if (use_msi && !pci_enable_msi(pdev)) {
+			adapter->flags |= NETXEN_NIC_MSI_ENABLED;
+			dev_info(&pdev->dev, "using msi interrupts\n");
+		} else
+			dev_info(&pdev->dev, "using legacy interrupts\n");
+	}
+}
+
+static void
+netxen_teardown_intr(struct netxen_adapter *adapter)
+{
+	if (adapter->flags & NETXEN_NIC_MSIX_ENABLED)
+		pci_disable_msix(adapter->pdev);
+	if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
+		pci_disable_msi(adapter->pdev);
+}
+
+static void
+netxen_cleanup_pci_map(struct netxen_adapter *adapter)
+{
+	if (adapter->ahw.db_base != NULL)
+		iounmap(adapter->ahw.db_base);
+	if (adapter->ahw.pci_base0 != NULL)
+		iounmap(adapter->ahw.pci_base0);
+	if (adapter->ahw.pci_base1 != NULL)
+		iounmap(adapter->ahw.pci_base1);
+	if (adapter->ahw.pci_base2 != NULL)
+		iounmap(adapter->ahw.pci_base2);
+}
+
+static int
+netxen_setup_pci_map(struct netxen_adapter *adapter)
+{
+	void __iomem *mem_ptr0 = NULL;
+	void __iomem *mem_ptr1 = NULL;
+	void __iomem *mem_ptr2 = NULL;
+	void __iomem *db_ptr = NULL;
+
+	unsigned long first_page_group_end;
+	unsigned long first_page_group_start;
+	unsigned long mem_base, mem_len, db_base, db_len = 0, pci_len0 = 0;
+
+	struct pci_dev *pdev = adapter->pdev;
+	int pci_func = adapter->ahw.pci_func;
+
+	int err = 0;
+
+	/*
+	 * Set the CRB window to invalid. If any register in window 0 is
+	 * accessed it should set the window to 0 and then reset it to 1.
+	 */
+	adapter->curr_window = 255;
+	adapter->ahw.qdr_sn_window = -1;
+	adapter->ahw.ddr_mn_window = -1;
+
+	/* remap phys address */
+	mem_base = pci_resource_start(pdev, 0);	/* 0 is for BAR 0 */
+	mem_len = pci_resource_len(pdev, 0);
+	pci_len0 = 0;
+
+	adapter->hw_write_wx = netxen_nic_hw_write_wx_128M;
+	adapter->hw_read_wx = netxen_nic_hw_read_wx_128M;
+	adapter->pci_read_immediate = netxen_nic_pci_read_immediate_128M;
+	adapter->pci_write_immediate = netxen_nic_pci_write_immediate_128M;
+	adapter->pci_read_normalize = netxen_nic_pci_read_normalize_128M;
+	adapter->pci_write_normalize = netxen_nic_pci_write_normalize_128M;
+	adapter->pci_set_window = netxen_nic_pci_set_window_128M;
+	adapter->pci_mem_read = netxen_nic_pci_mem_read_128M;
+	adapter->pci_mem_write = netxen_nic_pci_mem_write_128M;
+
+	/* 128 Meg of memory */
+	if (mem_len == NETXEN_PCI_128MB_SIZE) {
+		mem_ptr0 = ioremap(mem_base, FIRST_PAGE_GROUP_SIZE);
+		mem_ptr1 = ioremap(mem_base + SECOND_PAGE_GROUP_START,
+				SECOND_PAGE_GROUP_SIZE);
+		mem_ptr2 = ioremap(mem_base + THIRD_PAGE_GROUP_START,
+				THIRD_PAGE_GROUP_SIZE);
+		first_page_group_start = FIRST_PAGE_GROUP_START;
+		first_page_group_end   = FIRST_PAGE_GROUP_END;
+	} else if (mem_len == NETXEN_PCI_32MB_SIZE) {
+		mem_ptr1 = ioremap(mem_base, SECOND_PAGE_GROUP_SIZE);
+		mem_ptr2 = ioremap(mem_base + THIRD_PAGE_GROUP_START -
+			SECOND_PAGE_GROUP_START, THIRD_PAGE_GROUP_SIZE);
+		first_page_group_start = 0;
+		first_page_group_end   = 0;
+	} else if (mem_len == NETXEN_PCI_2MB_SIZE) {
+		adapter->hw_write_wx = netxen_nic_hw_write_wx_2M;
+		adapter->hw_read_wx = netxen_nic_hw_read_wx_2M;
+		adapter->pci_read_immediate = netxen_nic_pci_read_immediate_2M;
+		adapter->pci_write_immediate =
+			netxen_nic_pci_write_immediate_2M;
+		adapter->pci_read_normalize = netxen_nic_pci_read_normalize_2M;
+		adapter->pci_write_normalize =
+			netxen_nic_pci_write_normalize_2M;
+		adapter->pci_set_window = netxen_nic_pci_set_window_2M;
+		adapter->pci_mem_read = netxen_nic_pci_mem_read_2M;
+		adapter->pci_mem_write = netxen_nic_pci_mem_write_2M;
+
+		mem_ptr0 = pci_ioremap_bar(pdev, 0);
+		if (mem_ptr0 == NULL) {
+			dev_err(&pdev->dev, "failed to map PCI bar 0\n");
+			return -EIO;
+		}
+		pci_len0 = mem_len;
+		first_page_group_start = 0;
+		first_page_group_end   = 0;
+
+		adapter->ahw.ddr_mn_window = 0;
+		adapter->ahw.qdr_sn_window = 0;
+
+		adapter->ahw.mn_win_crb = 0x100000 + PCIX_MN_WINDOW +
+			(pci_func * 0x20);
+		adapter->ahw.ms_win_crb = 0x100000 + PCIX_SN_WINDOW;
+		if (pci_func < 4)
+			adapter->ahw.ms_win_crb += (pci_func * 0x20);
+		else
+			adapter->ahw.ms_win_crb +=
+					0xA0 + ((pci_func - 4) * 0x10);
+	} else {
+		return -EIO;
+	}
+
+	dev_info(&pdev->dev, "%dMB memory map\n", (int)(mem_len>>20));
+
+	adapter->ahw.pci_base0 = mem_ptr0;
+	adapter->ahw.pci_len0 = pci_len0;
+	adapter->ahw.first_page_group_start = first_page_group_start;
+	adapter->ahw.first_page_group_end   = first_page_group_end;
+	adapter->ahw.pci_base1 = mem_ptr1;
+	adapter->ahw.pci_base2 = mem_ptr2;
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		goto skip_doorbell;
+
+	db_base = pci_resource_start(pdev, 4);	/* doorbell is on bar 4 */
+	db_len = pci_resource_len(pdev, 4);
+
+	if (db_len == 0) {
+		printk(KERN_ERR "%s: doorbell is disabled\n",
+				netxen_nic_driver_name);
+		err = -EIO;
+		goto err_out;
+	}
+
+	db_ptr = ioremap(db_base, NETXEN_DB_MAPSIZE_BYTES);
+	if (!db_ptr) {
+		printk(KERN_ERR "%s: Failed to allocate doorbell map.",
+				netxen_nic_driver_name);
+		err = -EIO;
+		goto err_out;
+	}
+
+skip_doorbell:
+	adapter->ahw.db_base = db_ptr;
+	adapter->ahw.db_len = db_len;
+	return 0;
+
+err_out:
+	netxen_cleanup_pci_map(adapter);
+	return err;
+}
+
 static int
 netxen_start_firmware(struct netxen_adapter *adapter)
 {
@@ -521,20 +717,10 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev = NULL;
 	struct netxen_adapter *adapter = NULL;
-	void __iomem *mem_ptr0 = NULL;
-	void __iomem *mem_ptr1 = NULL;
-	void __iomem *mem_ptr2 = NULL;
-	unsigned long first_page_group_end;
-	unsigned long first_page_group_start;
-
-
-	u8 __iomem *db_ptr = NULL;
-	unsigned long mem_base, mem_len, db_base, db_len = 0, pci_len0 = 0;
 	int i = 0, err;
 	int first_driver;
 	u32 val;
 	int pci_func_id = PCI_FUNC(pdev->devfn);
-	struct netxen_legacy_intr_set *legacy_intrp;
 	uint8_t revision_id;
 
 	if (pci_func_id == 0)
@@ -589,128 +775,14 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_free_netdev;
 
 	rwlock_init(&adapter->adapter_lock);
-	adapter->ahw.qdr_sn_window = -1;
-	adapter->ahw.ddr_mn_window = -1;
-
-	/* remap phys address */
-	mem_base = pci_resource_start(pdev, 0);	/* 0 is for BAR 0 */
-	mem_len = pci_resource_len(pdev, 0);
-	pci_len0 = 0;
-
-	adapter->hw_write_wx = netxen_nic_hw_write_wx_128M;
-	adapter->hw_read_wx = netxen_nic_hw_read_wx_128M;
-	adapter->pci_read_immediate = netxen_nic_pci_read_immediate_128M;
-	adapter->pci_write_immediate = netxen_nic_pci_write_immediate_128M;
-	adapter->pci_read_normalize = netxen_nic_pci_read_normalize_128M;
-	adapter->pci_write_normalize = netxen_nic_pci_write_normalize_128M;
-	adapter->pci_set_window = netxen_nic_pci_set_window_128M;
-	adapter->pci_mem_read = netxen_nic_pci_mem_read_128M;
-	adapter->pci_mem_write = netxen_nic_pci_mem_write_128M;
-
-	/* 128 Meg of memory */
-	if (mem_len == NETXEN_PCI_128MB_SIZE) {
-		mem_ptr0 = ioremap(mem_base, FIRST_PAGE_GROUP_SIZE);
-		mem_ptr1 = ioremap(mem_base + SECOND_PAGE_GROUP_START,
-				SECOND_PAGE_GROUP_SIZE);
-		mem_ptr2 = ioremap(mem_base + THIRD_PAGE_GROUP_START,
-				THIRD_PAGE_GROUP_SIZE);
-		first_page_group_start = FIRST_PAGE_GROUP_START;
-		first_page_group_end   = FIRST_PAGE_GROUP_END;
-	} else if (mem_len == NETXEN_PCI_32MB_SIZE) {
-		mem_ptr1 = ioremap(mem_base, SECOND_PAGE_GROUP_SIZE);
-		mem_ptr2 = ioremap(mem_base + THIRD_PAGE_GROUP_START -
-			SECOND_PAGE_GROUP_START, THIRD_PAGE_GROUP_SIZE);
-		first_page_group_start = 0;
-		first_page_group_end   = 0;
-	} else if (mem_len == NETXEN_PCI_2MB_SIZE) {
-		adapter->hw_write_wx = netxen_nic_hw_write_wx_2M;
-		adapter->hw_read_wx = netxen_nic_hw_read_wx_2M;
-		adapter->pci_read_immediate = netxen_nic_pci_read_immediate_2M;
-		adapter->pci_write_immediate =
-			netxen_nic_pci_write_immediate_2M;
-		adapter->pci_read_normalize = netxen_nic_pci_read_normalize_2M;
-		adapter->pci_write_normalize =
-			netxen_nic_pci_write_normalize_2M;
-		adapter->pci_set_window = netxen_nic_pci_set_window_2M;
-		adapter->pci_mem_read = netxen_nic_pci_mem_read_2M;
-		adapter->pci_mem_write = netxen_nic_pci_mem_write_2M;
 
-		mem_ptr0 = pci_ioremap_bar(pdev, 0);
-		if (mem_ptr0 == NULL) {
-			dev_err(&pdev->dev, "failed to map PCI bar 0\n");
-			return -EIO;
-		}
-
-		pci_len0 = mem_len;
-		first_page_group_start = 0;
-		first_page_group_end   = 0;
-
-		adapter->ahw.ddr_mn_window = 0;
-		adapter->ahw.qdr_sn_window = 0;
-
-		adapter->ahw.mn_win_crb = 0x100000 + PCIX_MN_WINDOW +
-			(pci_func_id * 0x20);
-		adapter->ahw.ms_win_crb = 0x100000 + PCIX_SN_WINDOW;
-		if (pci_func_id < 4)
-			adapter->ahw.ms_win_crb += (pci_func_id * 0x20);
-		else
-			adapter->ahw.ms_win_crb +=
-					0xA0 + ((pci_func_id - 4) * 0x10);
-	} else {
-		err = -EIO;
+	err = netxen_setup_pci_map(adapter);
+	if (err)
 		goto err_out_free_netdev;
-	}
-
-	dev_info(&pdev->dev, "%dMB memory map\n", (int)(mem_len>>20));
-
-	if (NX_IS_REVISION_P3(revision_id))
-		goto skip_doorbell;
-
-	db_base = pci_resource_start(pdev, 4);	/* doorbell is on bar 4 */
-	db_len = pci_resource_len(pdev, 4);
-
-	if (db_len == 0) {
-		printk(KERN_ERR "%s: doorbell is disabled\n",
-				netxen_nic_driver_name);
-		err = -EIO;
-		goto err_out_iounmap;
-	}
-
-	db_ptr = ioremap(db_base, NETXEN_DB_MAPSIZE_BYTES);
-	if (!db_ptr) {
-		printk(KERN_ERR "%s: Failed to allocate doorbell map.",
-				netxen_nic_driver_name);
-		err = -EIO;
-		goto err_out_iounmap;
-	}
-
-skip_doorbell:
-	adapter->ahw.pci_base0 = mem_ptr0;
-	adapter->ahw.pci_len0 = pci_len0;
-	adapter->ahw.first_page_group_start = first_page_group_start;
-	adapter->ahw.first_page_group_end   = first_page_group_end;
-	adapter->ahw.pci_base1 = mem_ptr1;
-	adapter->ahw.pci_base2 = mem_ptr2;
-	adapter->ahw.db_base = db_ptr;
-	adapter->ahw.db_len = db_len;
 
 	netif_napi_add(netdev, &adapter->napi,
 			netxen_nic_poll, NETXEN_NETDEV_WEIGHT);
 
-	if (revision_id >= NX_P3_B0)
-		legacy_intrp = &legacy_intr[pci_func_id];
-	else
-		legacy_intrp = &legacy_intr[0];
-
-	adapter->legacy_intr.int_vec_bit = legacy_intrp->int_vec_bit;
-	adapter->legacy_intr.tgt_status_reg = legacy_intrp->tgt_status_reg;
-	adapter->legacy_intr.tgt_mask_reg = legacy_intrp->tgt_mask_reg;
-	adapter->legacy_intr.pci_int_reg = legacy_intrp->pci_int_reg;
-
-	/* this will be read from FW later */
-	adapter->intr_scheme = -1;
-	adapter->msi_mode = -1;
-
 	/* This will be reset for mezz cards  */
 	adapter->portnum = pci_func_id;
 	adapter->status   &= ~NETXEN_NETDEV_STATUS;
@@ -741,12 +813,6 @@ skip_doorbell:
 		netdev->vlan_features |= NETIF_F_HIGHDMA;
 	}
 
-	/*
-	 * Set the CRB window to invalid. If any register in window 0 is
-	 * accessed it should set the window to 0 and then reset it to 1.
-	 */
-	adapter->curr_window = 255;
-
 	if (netxen_nic_get_board_info(adapter) != 0) {
 		printk("%s: Error getting board config info.\n",
 				netxen_nic_driver_name);
@@ -813,32 +879,7 @@ skip_doorbell:
 
 	netxen_set_msix_bit(pdev, 0);
 
-	if (NX_IS_REVISION_P3(revision_id)) {
-		if ((mem_len != NETXEN_PCI_128MB_SIZE) &&
-			mem_len != NETXEN_PCI_2MB_SIZE)
-			adapter->msix_supported = 0;
-	}
-
-	if (adapter->msix_supported) {
-
-		netxen_init_msix_entries(adapter);
-
-		if (pci_enable_msix(pdev, adapter->msix_entries,
-					MSIX_ENTRIES_PER_ADAPTER))
-			goto request_msi;
-
-		adapter->flags |= NETXEN_NIC_MSIX_ENABLED;
-		netxen_set_msix_bit(pdev, 1);
-		dev_info(&pdev->dev, "using msi-x interrupts\n");
-
-	} else {
-request_msi:
-		if (use_msi && !pci_enable_msi(pdev)) {
-			adapter->flags |= NETXEN_NIC_MSI_ENABLED;
-			dev_info(&pdev->dev, "using msi interrupts\n");
-		} else
-			dev_info(&pdev->dev, "using legacy interrupts\n");
-	}
+	netxen_setup_intr(adapter);
 
 	if (adapter->flags & NETXEN_NIC_MSIX_ENABLED)
 		netdev->irq = adapter->msix_entries[0].vector;
@@ -886,23 +927,13 @@ request_msi:
 	return 0;
 
 err_out_disable_msi:
-	if (adapter->flags & NETXEN_NIC_MSIX_ENABLED)
-		pci_disable_msix(pdev);
-	if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
-		pci_disable_msi(pdev);
+	netxen_teardown_intr(adapter);
 
 	if (first_driver)
 		netxen_free_adapter_offload(adapter);
 
 err_out_iounmap:
-	if (db_ptr)
-		iounmap(db_ptr);
-	if (mem_ptr0)
-		iounmap(mem_ptr0);
-	if (mem_ptr1)
-		iounmap(mem_ptr1);
-	if (mem_ptr2)
-		iounmap(mem_ptr2);
+	netxen_cleanup_pci_map(adapter);
 
 err_out_free_netdev:
 	free_netdev(netdev);
@@ -944,18 +975,9 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 	if (adapter->irq)
 		free_irq(adapter->irq, adapter);
 
-	if (adapter->flags & NETXEN_NIC_MSIX_ENABLED)
-		pci_disable_msix(pdev);
-	if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
-		pci_disable_msi(pdev);
+	netxen_teardown_intr(adapter);
 
-	iounmap(adapter->ahw.pci_base0);
-	if (adapter->ahw.db_base != NULL)
-		iounmap(adapter->ahw.db_base);
-	if (adapter->ahw.pci_base1 != NULL)
-		iounmap(adapter->ahw.pci_base1);
-	if (adapter->ahw.pci_base2 != NULL)
-		iounmap(adapter->ahw.pci_base2);
+	netxen_cleanup_pci_map(adapter);
 
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-- 
1.6.0.2

