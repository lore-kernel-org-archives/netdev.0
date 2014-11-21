From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 4/4] defxx: Clean up DEFEA resource management
Date: Fri, 21 Nov 2014 14:10:08 +0000 (GMT)
Message-ID: <alpine.LFD.2.11.1411211239290.4773@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1411211107150.4773@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:59728 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758498AbaKUOKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 09:10:09 -0500
Received: from localhost.localdomain ([127.0.0.1]:49963 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S27006529AbaKUOKInO4A3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:10:08 +0100
In-Reply-To: <alpine.LFD.2.11.1411211107150.4773@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reserve DEFEA resources according to actual use.  There are three
regions, for the ESIC ASIC's CSRs, for the discrete Burst Holdoff
register, and for the PDQ ASIC's CSRs.  The latter is mapped in the
memory or port I/O address space depending on configuration.  The two
formers are hardwired and always mapped in the port I/O address space.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
linux-defea-resource.patch
Index: linux-20141025-dolch/drivers/net/fddi/defxx.c
===================================================================
--- linux-20141025-dolch.orig/drivers/net/fddi/defxx.c
+++ linux-20141025-dolch/drivers/net/fddi/defxx.c
@@ -414,7 +414,7 @@ static void dfx_port_read_long(DFX_board
  * ================
  *
  * Overview:
- *   Retrieves the address range used to access control and status
+ *   Retrieves the address ranges used to access control and status
  *   registers.
  *
  * Returns:
@@ -422,8 +422,8 @@ static void dfx_port_read_long(DFX_board
  *
  * Arguments:
  *   bdev	- pointer to device information
- *   bar_start	- pointer to store the start address
- *   bar_len	- pointer to store the length of the area
+ *   bar_start	- pointer to store the start addresses
+ *   bar_len	- pointer to store the lengths of the areas
  *
  * Assumptions:
  *   I am sure there are some.
@@ -442,8 +442,10 @@ static void dfx_get_bars(struct device *
 	if (dfx_bus_pci) {
 		int num = dfx_use_mmio ? 0 : 1;
 
-		*bar_start = pci_resource_start(to_pci_dev(bdev), num);
-		*bar_len = pci_resource_len(to_pci_dev(bdev), num);
+		bar_start[0] = pci_resource_start(to_pci_dev(bdev), num);
+		bar_len[0] = pci_resource_len(to_pci_dev(bdev), num);
+		bar_start[2] = bar_start[1] = 0;
+		bar_len[2] = bar_len[1] = 0;
 	}
 	if (dfx_bus_eisa) {
 		unsigned long base_addr = to_eisa_device(bdev)->base_addr;
@@ -457,24 +459,30 @@ static void dfx_get_bars(struct device *
 			bar_lo <<= 8;
 			bar_lo |= inb(base_addr + PI_ESIC_K_MEM_ADD_LO_CMP_0);
 			bar_lo <<= 8;
-			*bar_start = bar_lo;
+			bar_start[0] = bar_lo;
 			bar_hi = inb(base_addr + PI_ESIC_K_MEM_ADD_HI_CMP_2);
 			bar_hi <<= 8;
 			bar_hi |= inb(base_addr + PI_ESIC_K_MEM_ADD_HI_CMP_1);
 			bar_hi <<= 8;
 			bar_hi |= inb(base_addr + PI_ESIC_K_MEM_ADD_HI_CMP_0);
 			bar_hi <<= 8;
-			*bar_len = ((bar_hi - bar_lo) | PI_MEM_ADD_MASK_M) + 1;
+			bar_len[0] = ((bar_hi - bar_lo) | PI_MEM_ADD_MASK_M) +
+				     1;
 		} else {
-			*bar_start = base_addr;
-			*bar_len = PI_ESIC_K_CSR_IO_LEN +
-				   PI_ESIC_K_BURST_HOLDOFF_LEN;
+			bar_start[0] = base_addr;
+			bar_len[0] = PI_ESIC_K_CSR_IO_LEN;
 		}
+		bar_start[1] = base_addr + PI_DEFEA_K_BURST_HOLDOFF;
+		bar_len[1] = PI_ESIC_K_BURST_HOLDOFF_LEN;
+		bar_start[2] = base_addr + PI_ESIC_K_ESIC_CSR;
+		bar_len[2] = PI_ESIC_K_ESIC_CSR_LEN;
 	}
 	if (dfx_bus_tc) {
-		*bar_start = to_tc_dev(bdev)->resource.start +
-			     PI_TC_K_CSR_OFFSET;
-		*bar_len = PI_TC_K_CSR_LEN;
+		bar_start[0] = to_tc_dev(bdev)->resource.start +
+			       PI_TC_K_CSR_OFFSET;
+		bar_len[0] = PI_TC_K_CSR_LEN;
+		bar_start[2] = bar_start[1] = 0;
+		bar_len[2] = bar_len[1] = 0;
 	}
 }
 
@@ -525,8 +533,8 @@ static int dfx_register(struct device *b
 	const char *print_name = dev_name(bdev);
 	struct net_device *dev;
 	DFX_board_t	  *bp;			/* board pointer */
-	resource_size_t bar_start = 0;		/* pointer to port */
-	resource_size_t bar_len = 0;		/* resource length */
+	resource_size_t bar_start[3];		/* pointers to ports */
+	resource_size_t bar_len[3];		/* resource length */
 	int alloc_size;				/* total buffer size used */
 	struct resource *region;
 	int err = 0;
@@ -559,8 +567,8 @@ static int dfx_register(struct device *b
 	bp->bus_dev = bdev;
 	dev_set_drvdata(bdev, dev);
 
-	dfx_get_bars(bdev, &bar_start, &bar_len);
-	if (dfx_bus_eisa && dfx_use_mmio && bar_start == 0) {
+	dfx_get_bars(bdev, bar_start, bar_len);
+	if (dfx_bus_eisa && dfx_use_mmio && bar_start[0] == 0) {
 		pr_err("%s: Cannot use MMIO, no address set, aborting\n",
 		       print_name);
 		pr_err("%s: Run ECU and set adapter's MMIO location\n",
@@ -572,28 +580,49 @@ static int dfx_register(struct device *b
 	}
 
 	if (dfx_use_mmio)
-		region = request_mem_region(bar_start, bar_len, print_name);
+		region = request_mem_region(bar_start[0], bar_len[0],
+					    print_name);
 	else
-		region = request_region(bar_start, bar_len, print_name);
+		region = request_region(bar_start[0], bar_len[0], print_name);
 	if (!region) {
-		printk(KERN_ERR "%s: Cannot reserve I/O resource "
-		       "0x%lx @ 0x%lx, aborting\n",
-		       print_name, (long)bar_len, (long)bar_start);
+		pr_err("%s: Cannot reserve %s resource 0x%lx @ 0x%lx, "
+		       "aborting\n", dfx_use_mmio ? "MMIO" : "I/O", print_name,
+		       (long)bar_len[0], (long)bar_start[0]);
 		err = -EBUSY;
 		goto err_out_disable;
 	}
+	if (bar_start[1] != 0) {
+		region = request_region(bar_start[1], bar_len[1], print_name);
+		if (!region) {
+			pr_err("%s: Cannot reserve I/O resource "
+			       "0x%lx @ 0x%lx, aborting\n", print_name,
+			       (long)bar_len[1], (long)bar_start[1]);
+			err = -EBUSY;
+			goto err_out_csr_region;
+		}
+	}
+	if (bar_start[2] != 0) {
+		region = request_region(bar_start[2], bar_len[2], print_name);
+		if (!region) {
+			pr_err("%s: Cannot reserve I/O resource "
+			       "0x%lx @ 0x%lx, aborting\n", print_name,
+			       (long)bar_len[2], (long)bar_start[2]);
+			err = -EBUSY;
+			goto err_out_bh_region;
+		}
+	}
 
 	/* Set up I/O base address. */
 	if (dfx_use_mmio) {
-		bp->base.mem = ioremap_nocache(bar_start, bar_len);
+		bp->base.mem = ioremap_nocache(bar_start[0], bar_len[0]);
 		if (!bp->base.mem) {
 			printk(KERN_ERR "%s: Cannot map MMIO\n", print_name);
 			err = -ENOMEM;
-			goto err_out_region;
+			goto err_out_esic_region;
 		}
 	} else {
-		bp->base.port = bar_start;
-		dev->base_addr = bar_start;
+		bp->base.port = bar_start[0];
+		dev->base_addr = bar_start[0];
 	}
 
 	/* Initialize new device structure */
@@ -602,7 +631,7 @@ static int dfx_register(struct device *b
 	if (dfx_bus_pci)
 		pci_set_master(to_pci_dev(bdev));
 
-	if (dfx_driver_init(dev, print_name, bar_start) != DFX_K_SUCCESS) {
+	if (dfx_driver_init(dev, print_name, bar_start[0]) != DFX_K_SUCCESS) {
 		err = -ENODEV;
 		goto err_out_unmap;
 	}
@@ -630,11 +659,19 @@ static int dfx_register(struct device *b
 	if (dfx_use_mmio)
 		iounmap(bp->base.mem);
 
-err_out_region:
+err_out_esic_region:
+	if (bar_start[2] != 0)
+		release_region(bar_start[2], bar_len[2]);
+
+err_out_bh_region:
+	if (bar_start[1] != 0)
+		release_region(bar_start[1], bar_len[1]);
+
+err_out_csr_region:
 	if (dfx_use_mmio)
-		release_mem_region(bar_start, bar_len);
+		release_mem_region(bar_start[0], bar_len[0]);
 	else
-		release_region(bar_start, bar_len);
+		release_region(bar_start[0], bar_len[0]);
 
 err_out_disable:
 	if (dfx_bus_pci)
@@ -1085,8 +1122,8 @@ static int dfx_driver_init(struct net_de
 		board_name = "DEFEA";
 	if (dfx_bus_pci)
 		board_name = "DEFPA";
-	pr_info("%s: %s at %saddr = 0x%llx, IRQ = %d, Hardware addr = %pMF\n",
-		print_name, board_name, dfx_use_mmio ? "" : "I/O ",
+	pr_info("%s: %s at %s addr = 0x%llx, IRQ = %d, Hardware addr = %pMF\n",
+		print_name, board_name, dfx_use_mmio ? "MMIO" : "I/O",
 		(long long)bar_start, dev->irq, dev->dev_addr);
 
 	/*
@@ -3660,8 +3697,8 @@ static void dfx_unregister(struct device
 	int dfx_bus_pci = dev_is_pci(bdev);
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
-	resource_size_t bar_start = 0;		/* pointer to port */
-	resource_size_t bar_len = 0;		/* resource length */
+	resource_size_t bar_start[3];		/* pointers to ports */
+	resource_size_t bar_len[3];		/* resource lengths */
 	int		alloc_size;		/* total buffer size used */
 
 	unregister_netdev(dev);
@@ -3679,12 +3716,16 @@ static void dfx_unregister(struct device
 
 	dfx_bus_uninit(dev);
 
-	dfx_get_bars(bdev, &bar_start, &bar_len);
+	dfx_get_bars(bdev, bar_start, bar_len);
+	if (bar_start[2] != 0)
+		release_region(bar_start[2], bar_len[2]);
+	if (bar_start[1] != 0)
+		release_region(bar_start[1], bar_len[1]);
 	if (dfx_use_mmio) {
 		iounmap(bp->base.mem);
-		release_mem_region(bar_start, bar_len);
+		release_mem_region(bar_start[0], bar_len[0]);
 	} else
-		release_region(bar_start, bar_len);
+		release_region(bar_start[0], bar_len[0]);
 
 	if (dfx_bus_pci)
 		pci_disable_device(to_pci_dev(bdev));
Index: linux-20141025-dolch/drivers/net/fddi/defxx.h
===================================================================
--- linux-20141025-dolch.orig/drivers/net/fddi/defxx.h
+++ linux-20141025-dolch/drivers/net/fddi/defxx.h
@@ -1481,9 +1481,11 @@ typedef union
 
 #define PI_ESIC_K_CSR_IO_LEN		0x40		/* 64 bytes */
 #define PI_ESIC_K_BURST_HOLDOFF_LEN	0x04		/* 4 bytes */
+#define PI_ESIC_K_ESIC_CSR_LEN		0x40		/* 64 bytes */
 
 #define PI_DEFEA_K_CSR_IO		0x000
 #define PI_DEFEA_K_BURST_HOLDOFF	0x040
+#define PI_ESIC_K_ESIC_CSR		0xC80
 
 #define PI_ESIC_K_SLOT_ID            	0xC80
 #define PI_ESIC_K_SLOT_CNTRL		0xC84
