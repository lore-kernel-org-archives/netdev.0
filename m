From: dhananjay.phadke@gmail.com
Subject: RESEND [PATCH 3/3] NetXen: Graceful teardown of interface and hardware upon module unload
Date: Sun, 01 Jul 2007 08:13:28 +0530
Message-ID: <20070701024731.474916832@netxen.com>
References: <20070701024325.287283308@netxen.com>
Cc: rob@netxen.com, Milan Bag <mbag@netxen.com>,
	Wen Xiong <wenxiong@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.199.144.227] ([203.199.144.227]:1251 "EHLO
	stellar.unminc.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754706AbXGACuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 22:50:35 -0400
Content-Disposition: inline; filename=rmmod.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These changes allow driver close routine to be called during module unload,
to clean-up buffers and other software resources, flush queues etc. Also,
hardware is reset to pristine state. 

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
Signed-off-by: Milan Bag <mbag@netxen.com>
Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>

Index: netdev-2.6/drivers/net/netxen/netxen_nic.h
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic.h
+++ netdev-2.6/drivers/net/netxen/netxen_nic.h
@@ -952,6 +952,24 @@ struct netxen_adapter {
 	int (*stop_port) (struct netxen_adapter *);
 };				/* netxen_adapter structure */
 
+/*
+ * NetXen dma watchdog control structure
+ *
+ *	Bit 0		: enabled => R/O: 1 watchdog active, 0 inactive
+ *	Bit 1		: disable_request => 1 req disable dma watchdog
+ *	Bit 2		: enable_request =>  1 req enable dma watchdog
+ *	Bit 3-31	: unused
+ */
+
+#define netxen_set_dma_watchdog_disable_req(config_word) \
+	_netxen_set_bits(config_word, 1, 1, 1)
+#define netxen_set_dma_watchdog_enable_req(config_word) \
+	_netxen_set_bits(config_word, 2, 1, 1)
+#define netxen_get_dma_watchdog_enabled(config_word) \
+	((config_word) & 0x1)
+#define netxen_get_dma_watchdog_disabled(config_word) \
+	(((config_word) >> 1) & 0x1)
+
 /* Max number of xmit producer threads that can run simultaneously */
 #define	MAX_XMIT_PRODUCERS		16
 
@@ -1031,8 +1049,8 @@ int netxen_nic_erase_pxe(struct netxen_a
 /* Functions from netxen_nic_init.c */
 void netxen_free_adapter_offload(struct netxen_adapter *adapter);
 int netxen_initialize_adapter_offload(struct netxen_adapter *adapter);
-void netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val);
-void netxen_load_firmware(struct netxen_adapter *adapter);
+int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val);
+int netxen_load_firmware(struct netxen_adapter *adapter);
 int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose);
 int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp);
 int netxen_rom_fast_read_words(struct netxen_adapter *adapter, int addr, 
@@ -1231,6 +1249,62 @@ static inline void get_brd_name_by_type(
 		name = "Unknown";
 }
 
+static inline int
+dma_watchdog_shutdown_request(struct netxen_adapter *adapter)
+{
+	u32 ctrl;
+
+	/* check if already inactive */
+	if (netxen_nic_hw_read_wx(adapter,
+	    NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), &ctrl, 4))
+		printk(KERN_ERR "failed to read dma watchdog status\n");
+
+	if (netxen_get_dma_watchdog_enabled(ctrl) == 0)
+		return 1;
+
+	/* Send the disable request */
+	netxen_set_dma_watchdog_disable_req(ctrl);
+	netxen_crb_writelit_adapter(adapter,
+		NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), ctrl);
+
+	return 0;
+}
+
+static inline int
+dma_watchdog_shutdown_poll_result(struct netxen_adapter *adapter)
+{
+	u32 ctrl;
+
+	if (netxen_nic_hw_read_wx(adapter,
+	    NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), &ctrl, 4))
+		printk(KERN_ERR "failed to read dma watchdog status\n");
+
+	return ((netxen_get_dma_watchdog_enabled(ctrl) == 0) &&
+		(netxen_get_dma_watchdog_disabled(ctrl) == 0));
+}
+
+static inline int
+dma_watchdog_wakeup(struct netxen_adapter *adapter)
+{
+	u32 ctrl;
+
+	if (netxen_nic_hw_read_wx(adapter,
+		NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), &ctrl, 4))
+		printk(KERN_ERR "failed to read dma watchdog status\n");
+
+	if (netxen_get_dma_watchdog_enabled(ctrl))
+		return 1;
+
+	/* send the wakeup request */
+	netxen_set_dma_watchdog_enable_req(ctrl);
+
+	netxen_crb_writelit_adapter(adapter,
+		NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), ctrl);
+
+	return 0;
+}
+
+
 int netxen_is_flash_supported(struct netxen_adapter *adapter);
 int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, u64 mac[]);
 extern void netxen_change_ringparam(struct netxen_adapter *adapter);
Index: netdev-2.6/drivers/net/netxen/netxen_nic_hdr.h
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_hdr.h
+++ netdev-2.6/drivers/net/netxen/netxen_nic_hdr.h
@@ -687,4 +687,6 @@ enum {
 
 #define PCIE_MAX_MASTER_SPLIT	(0x14048)
 
+#define NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL		(0x14)
+
 #endif				/* __NETXEN_NIC_HDR_H_ */
Index: netdev-2.6/drivers/net/netxen/netxen_nic_hw.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_hw.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_hw.c
@@ -377,7 +377,7 @@ int netxen_nic_hw_resources(struct netxe
 						   recv_crb_registers[ctx].
 						   crb_rcvpeg_state));
 		while (state != PHAN_PEG_RCV_INITIALIZED && loops < 20) {
-			udelay(100);
+			msleep(1);
 			/* Window 1 call */
 			state = readl(NETXEN_CRB_NORMALIZE(adapter,
 							   recv_crb_registers
@@ -394,7 +394,7 @@ int netxen_nic_hw_resources(struct netxe
 	}
 	adapter->intr_scheme = readl(
 		NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_FW));
-	printk(KERN_NOTICE "%s: FW capabilities:0x%x\n", netdev->name,
+	printk(KERN_NOTICE "%s: FW capabilities:0x%x\n", netxen_nic_driver_name,
 			adapter->intr_scheme);
 	DPRINTK(INFO, "Receive Peg ready too. starting stuff\n");
 
@@ -701,7 +701,7 @@ void netxen_nic_pci_change_crbwindow(str
 		adapter->curr_window = 0;
 }
 
-void netxen_load_firmware(struct netxen_adapter *adapter)
+int netxen_load_firmware(struct netxen_adapter *adapter)
 {
 	int i;
 	u32 data, size = 0;
@@ -713,15 +713,30 @@ void netxen_load_firmware(struct netxen_
 	writel(1, NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CAS_RST));
 
 	for (i = 0; i < size; i++) {
-		if (netxen_rom_fast_read(adapter, flashaddr, (int *)&data) != 0) {
-			DPRINTK(ERR,
-				"Error in netxen_rom_fast_read(). Will skip"
-				"loading flash image\n");
-			return;
-		}
+		int retries = 10;
+		if (netxen_rom_fast_read(adapter, flashaddr, (int *)&data) != 0)
+			return -EIO;
+
 		off = netxen_nic_pci_set_window(adapter, memaddr);
 		addr = pci_base_offset(adapter, off);
 		writel(data, addr);
+		do {
+			if (readl(addr) == data)
+				break;
+			if (msleep_interruptible(100))
+				break;
+			writel(data, addr);
+		} while (--retries);
+		if (signal_pending(current)) {
+			printk(KERN_WARNING "%s: aborting firmware load on signal\n",
+					netxen_nic_driver_name);
+			return -EINTR;
+		}
+		if (!retries) {
+			printk(KERN_ERR "%s: firmware load aborted, write failed at 0x%x\n",
+					netxen_nic_driver_name, memaddr);
+			return -EIO;
+		}
 		flashaddr += 4;
 		memaddr += 4;
 	}
@@ -731,7 +746,7 @@ void netxen_load_firmware(struct netxen_
 	       NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CHIP_CLK_CTRL));
 	writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CAS_RST));
 
-	udelay(100);
+	return 0;
 }
 
 int
Index: netdev-2.6/drivers/net/netxen/netxen_nic_init.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_init.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_init.c
@@ -407,10 +407,7 @@ static inline int do_rom_fast_write(stru
 static inline int
 do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
 {
-	if (jiffies > (last_schedule_time + (8 * HZ))) {
-		last_schedule_time = jiffies;
-		schedule();
-	}
+	cond_resched();
 
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
@@ -856,12 +853,20 @@ int netxen_pinit_from_rom(struct netxen_
 				netxen_nic_pci_change_crbwindow(adapter, 1);
 			}
 			if (init_delay == 1) {
-				ssleep(1);
+				if (msleep_interruptible(2000))
+					break;
 				init_delay = 0;
 			}
-			msleep(1);
+			if (msleep_interruptible(20))
+				break;
 		}
 		kfree(buf);
+		if (signal_pending(current)) {
+			printk(KERN_ERR "%s: aborting phantom init on signal\n",
+					netxen_nic_driver_name);
+			return -EINTR;
+		}
+
 
 		/* disable_peg_cache_all */
 
@@ -935,10 +940,6 @@ int netxen_initialize_adapter_offload(st
 void netxen_free_adapter_offload(struct netxen_adapter *adapter)
 {
 	if (adapter->dummy_dma.addr) {
-		writel(0, NETXEN_CRB_NORMALIZE(adapter,
-			CRB_HOST_DUMMY_BUF_ADDR_HI));
-		writel(0, NETXEN_CRB_NORMALIZE(adapter,
-			CRB_HOST_DUMMY_BUF_ADDR_LO));
 		pci_free_consistent(adapter->ahw.pdev,
 				    NETXEN_HOST_DUMMY_DMA_SIZE,
 				    adapter->dummy_dma.addr,
@@ -947,25 +948,37 @@ void netxen_free_adapter_offload(struct 
 	}
 }
 
-void netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
+int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
 {
 	u32 val = 0;
-	int loops = 0;
+	int retries = 30;
 
 	if (!pegtune_val) {
-		val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
-		while (val != PHAN_INITIALIZE_COMPLETE && 
-			val != PHAN_INITIALIZE_ACK && loops < 200000) {
-			udelay(100);
-			schedule();
-			val =
-			    readl(NETXEN_CRB_NORMALIZE
+		do {
+			val = readl(NETXEN_CRB_NORMALIZE
 				  (adapter, CRB_CMDPEG_STATE));
-			loops++;
+			pegtune_val = readl(NETXEN_CRB_NORMALIZE
+				  (adapter, NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
+
+			if (val == PHAN_INITIALIZE_COMPLETE ||
+				val == PHAN_INITIALIZE_ACK)
+				return 0;
+
+			if (msleep_interruptible(1000))
+				break;
+		} while (--retries);
+		if (signal_pending(current)) {
+			printk(KERN_WARNING "netxen_phantom_init: exiting on signal\n");
+			return -EINTR;
+		}
+		if (!retries) {
+			printk(KERN_WARNING "netxen_phantom_init: init failed, "
+					"pegtune_val=%x\n", pegtune_val);
+			return -1;
 		}
-		if (val != PHAN_INITIALIZE_COMPLETE)
-			printk("WARNING: Initial boot wait loop failed...\n");
 	}
+
+	return 0;
 }
 
 int netxen_nic_rx_has_work(struct netxen_adapter *adapter)
@@ -1122,6 +1135,7 @@ netxen_process_rcv(struct netxen_adapter
 		adapter->stats.csummed++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
+	skb->dev = netdev;
 	if (desc_ctx == RCV_DESC_LRO_CTXID) {
 		/* True length was only available on the last pkt */
 		skb_put(skb, buffer->lro_length);
@@ -1226,6 +1240,7 @@ u32 netxen_process_rcv_ring(struct netxe
 		       NETXEN_CRB_NORMALIZE(adapter,
 					    recv_crb_registers[adapter->portnum].
 					    crb_rcv_status_consumer));
+		wmb();
 	}
 
 	return count;
@@ -1278,11 +1293,13 @@ int netxen_process_cmd_ring(unsigned lon
 		if (skb && (cmpxchg(&buffer->skb, skb, 0) == skb)) {
 			pci_unmap_single(pdev, frag->dma, frag->length,
 					 PCI_DMA_TODEVICE);
+			frag->dma = 0ULL;
 			for (i = 1; i < buffer->frag_count; i++) {
 				DPRINTK(INFO, "getting fragment no %d\n", i);
 				frag++;	/* Get the next frag */
 				pci_unmap_page(pdev, frag->dma, frag->length,
 					       PCI_DMA_TODEVICE);
+				frag->dma = 0ULL;
 			}
 
 			adapter->stats.skbfreed++;
@@ -1448,6 +1465,7 @@ void netxen_post_rx_buffers(struct netxe
 			writel(msg,
 			       DB_NORMALIZE(adapter,
 					    NETXEN_RCV_PRODUCER_OFFSET));
+			wmb();
 		}
 	}
 }
Index: netdev-2.6/drivers/net/netxen/netxen_nic_main.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_main.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_main.c
@@ -507,11 +507,14 @@ netxen_nic_probe(struct pci_dev *pdev, c
 		if (val == 0x55555555) {
 		    /* This is the first boot after power up */
 		    netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(0x4), &val);
-		    if (!(val & 0x4)) {
-			val |= 0x4;
-			netxen_nic_write_w0(adapter, NETXEN_PCIE_REG(0x4), val);
-			netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(0x4), &val);
-		    }
+			if (!(val & 0x4)) {
+				val |= 0x4;
+				netxen_nic_write_w0(adapter, NETXEN_PCIE_REG(0x4), val);
+				netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(0x4), &val);
+				if (!(val & 0x4))
+					printk(KERN_ERR "%s: failed to set MSI bit in PCI-e reg\n",
+							netxen_nic_driver_name);
+			}
 		    val = readl(NETXEN_CRB_NORMALIZE(adapter,
 					NETXEN_ROMUSB_GLB_SW_RESET));
 		    printk(KERN_INFO"NetXen: read 0x%08x for reset reg.\n",val);
@@ -523,11 +526,10 @@ netxen_nic_probe(struct pci_dev *pdev, c
 				err = -ENODEV;
 				goto err_out_free_dev;
 		    }
-
-		    /* clear the register for future unloads/loads */
-		    writel(0, NETXEN_CRB_NORMALIZE(adapter, 
-					    NETXEN_CAM_RAM(0x1fc)));
 		}
+
+		/* clear the register for future unloads/loads */
+		writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
 		printk(KERN_INFO "State: 0x%0x\n",
 			readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
 
@@ -545,13 +547,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
 				NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
 		/* Handshake with the card before we register the devices. */
 		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
-
-	       /* leave the hw in the same state as reboot */
-	       writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
-	       netxen_pinit_from_rom(adapter, 0);
-	       udelay(500);
-	       netxen_load_firmware(adapter);
-	       netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 	}
 
 	/*
@@ -642,8 +637,8 @@ static void __devexit netxen_nic_remove(
 	struct netxen_rx_buffer *buffer;
 	struct netxen_recv_context *recv_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
-	int i;
-	int ctxid, ring;
+	int i, ctxid, ring;
+	static int init_firmware_done = 0;
 
 	adapter = pci_get_drvdata(pdev);
 	if (adapter == NULL)
@@ -651,30 +646,20 @@ static void __devexit netxen_nic_remove(
 
 	netdev = adapter->netdev;
 
-	netxen_nic_disable_int(adapter);
-	if (adapter->irq)
-		free_irq(adapter->irq, adapter);
-	
+	unregister_netdev(netdev);
+
 	if (adapter->stop_port)
 		adapter->stop_port(adapter);
 
-	if ((adapter->flags & NETXEN_NIC_MSI_ENABLED))
-		pci_disable_msi(pdev);
-
-	if (adapter->portnum == 0)
-		netxen_free_adapter_offload(adapter);
+	netxen_nic_disable_int(adapter);
 
-	if(adapter->portnum == 0) {
-		/* leave the hw in the same state as reboot */
-		writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
-		netxen_pinit_from_rom(adapter, 0);
-		udelay(500);
-		netxen_load_firmware(adapter);
-		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
-	}
+	if (adapter->irq)
+		free_irq(adapter->irq, adapter);
 
-	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC)
+	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
+		init_firmware_done++;
 		netxen_free_hw_resources(adapter);
+	}
 
 	for (ctxid = 0; ctxid < MAX_RCV_CTX; ++ctxid) {
 		recv_ctx = &adapter->recv_ctx[ctxid];
@@ -694,17 +679,73 @@ static void __devexit netxen_nic_remove(
 		}
 	}
 
-	unregister_netdev(netdev);
+	if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
+		pci_disable_msi(pdev);
 
 	vfree(adapter->cmd_buf_arr);
 
+	pci_disable_device(pdev);
+
+	if (adapter->portnum == 0) {
+		if (init_firmware_done) {
+			dma_watchdog_shutdown_request(adapter);
+			msleep(100);
+			i = 100;
+			while ((dma_watchdog_shutdown_poll_result(adapter) != 1) && i) {
+				printk(KERN_INFO "dma_watchdog_shutdown_poll still in progress\n");
+				msleep(100);
+				i--;
+			}
+
+			if (i == 0) {
+				printk(KERN_ERR "dma_watchdog_shutdown_request failed\n");
+				return;
+			}
+
+			/* clear the register for future unloads/loads */
+			writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
+			printk(KERN_INFO "State: 0x%0x\n",
+				readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
+
+			/* leave the hw in the same state as reboot */
+			writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+			if (netxen_pinit_from_rom(adapter, 0))
+				return;
+			msleep(1);
+			if (netxen_load_firmware(adapter))
+				return;
+			netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
+		}
+
+		/* clear the register for future unloads/loads */
+		writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
+		printk(KERN_INFO "State: 0x%0x\n",
+			readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
+
+		dma_watchdog_shutdown_request(adapter);
+		mdelay(100);
+		i = 100;
+		while ((dma_watchdog_shutdown_poll_result(adapter) != 1) && i) {
+			printk(KERN_INFO "dma_watchdog_shutdown_poll still in progress\n");
+			mdelay(100);
+			i--;
+		}
+
+		if (i) {
+			netxen_free_adapter_offload(adapter);
+		} else {
+			printk(KERN_ERR "failed to dma shutdown\n");
+			return;
+		}
+
+	}
+
 	iounmap(adapter->ahw.db_base);
 	iounmap(adapter->ahw.pci_base0);
 	iounmap(adapter->ahw.pci_base1);
 	iounmap(adapter->ahw.pci_base2);
 
 	pci_release_regions(pdev);
-	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 
 	free_netdev(netdev);
@@ -801,7 +842,7 @@ static int netxen_nic_close(struct net_d
 		if (buffrag->dma) {
 			pci_unmap_single(adapter->pdev, buffrag->dma,
 					 buffrag->length, PCI_DMA_TODEVICE);
-			buffrag->dma = (u64) NULL;
+			buffrag->dma = 0ULL;
 		}
 		for (j = 0; j < cmd_buff->frag_count; j++) {
 			buffrag++;
@@ -809,7 +850,7 @@ static int netxen_nic_close(struct net_d
 				pci_unmap_page(adapter->pdev, buffrag->dma,
 					       buffrag->length, 
 					       PCI_DMA_TODEVICE);
-				buffrag->dma = (u64) NULL;
+				buffrag->dma = 0ULL;
 			}
 		}
 		/* Free the skb we received in netxen_nic_xmit_frame */
@@ -819,8 +860,10 @@ static int netxen_nic_close(struct net_d
 		}
 		cmd_buff++;
 	}
-	FLUSH_SCHEDULED_WORK();
-	del_timer_sync(&adapter->watchdog_timer);
+	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
+		FLUSH_SCHEDULED_WORK();
+		del_timer_sync(&adapter->watchdog_timer);
+	}
 
 	return 0;
 }
@@ -1259,6 +1302,7 @@ static void __exit netxen_exit_module(vo
 	/*
 	 * Wait for some time to allow the dma to drain, if any.
 	 */
+	msleep(100);
 	pci_unregister_driver(&netxen_driver);
 	destroy_workqueue(netxen_workq);
 }

-- 
