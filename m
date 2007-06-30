From: dhananjay.phadke@gmail.com
Subject: [PATCH 1/3] NetXen: Fix issue of MSI not working correctly
Date: Sun, 01 Jul 2007 02:08:45 +0530
Message-ID: <20070630204422.477168960@netxen.com>
References: <20070630203844.256007454@netxen.com>
Cc: rob@netxen.com, Milan Bag <mbag@netxen.com>,
	Wen Xiong <wenxiong@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.199.144.227] ([203.199.144.227]:1168 "EHLO
	stellar.unminc.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752607AbXF3VTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 17:19:06 -0400
Content-Disposition: inline; filename=msi.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen driver uses PCI function 0 to provide the functionality of MSI.
The patch makes driver check the bus master bit for function 0 and
enable it after the card initialization.

Signed-off-by: Dhananjay Phadke<dhananjay@netxen.com>
Signed-off-by: Milan Bag <mbag@netxen.com>
Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>

Index: netdev-2.6/drivers/net/netxen/netxen_nic_main.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_main.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_main.c
@@ -336,11 +336,9 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	if (pci_enable_msi(pdev)) {
+	if (pci_enable_msi(pdev))
 		adapter->flags &= ~NETXEN_NIC_MSI_ENABLED;
-		printk(KERN_WARNING "%s: unable to allocate MSI interrupt"
-		       " error\n", netxen_nic_driver_name);
-	} else
+	else
 		adapter->flags |= NETXEN_NIC_MSI_ENABLED;
 
 	netdev->irq = pdev->irq;
@@ -355,13 +353,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	/* initialize the adapter */
 	netxen_initialize_adapter_hw(adapter);
 
-#ifdef CONFIG_PPC
-	if ((adapter->ahw.boardcfg.board_type ==
-		NETXEN_BRDTYPE_P2_SB31_10G_IMEZ) &&
-			(pci_func_id == 2))
-		    goto err_out_free_adapter;
-#endif /* CONFIG_PPC */
-
 	/*
 	 *  Adapter in our case is quad port so initialize it before
 	 *  initializing the ports
@@ -509,16 +500,22 @@ netxen_nic_probe(struct pci_dev *pdev, c
 					NETXEN_CAM_RAM(0x1fc)));
 		if (val == 0x55555555) {
 		    /* This is the first boot after power up */
+		    netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(0x4), &val);
+		    if (!(val & 0x4)) {
+			val |= 0x4;
+			netxen_nic_write_w0(adapter, NETXEN_PCIE_REG(0x4), val);
+			netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(0x4), &val);
+		    }
 		    val = readl(NETXEN_CRB_NORMALIZE(adapter,
 					NETXEN_ROMUSB_GLB_SW_RESET));
 		    printk(KERN_INFO"NetXen: read 0x%08x for reset reg.\n",val);
 		    if (val != 0x80000f) {
 			/* clear the register for future unloads/loads */
-			writel(0, NETXEN_CRB_NORMALIZE(adapter,
-						NETXEN_CAM_RAM(0x1fc)));
-			printk(KERN_ERR "ERROR in NetXen HW init sequence.\n");
-			err = -ENODEV;
-			goto err_out_free_dev;
+				writel(0, NETXEN_CRB_NORMALIZE(adapter,
+							NETXEN_CAM_RAM(0x1fc)));
+				printk(KERN_ERR "ERROR in NetXen HW init sequence.\n");
+				err = -ENODEV;
+				goto err_out_free_dev;
 		    }
 
 		    /* clear the register for future unloads/loads */

-- 
