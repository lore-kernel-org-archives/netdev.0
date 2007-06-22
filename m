From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 3/3] NetXen: Fix the rmmod error on PBlades due incorrect cleanup
Date: Fri, 22 Jun 2007 01:42:38 -0700
Message-ID: <200706220842.l5M8gcsD021825@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:13353 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753186AbXFVImj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 04:42:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Unload graceful unloading of NetXen driver.
To allow graceful handing of Netxen module load/unload sequences,
modified code allows driver close routine to be invoked via
unregister_netdev() call in driver remove routine to free the command
buffer list and flush queues. Next dummy dma buffer that the hardware
uses is released after disabling its functionality. Finally other
software resources are released and the hardware is left in a reset
state for future load/unload.
       
Signed-off-by: Milan Bag <mbag@netxen.com>
Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>
Signed-off-by: Mithlesh Thukral <mithlesh@netxen.com>

---

 drivers/net/netxen/netxen_nic.h      |   80 +++++++++++++++++
 drivers/net/netxen/netxen_nic_hdr.h  |    2 
 drivers/net/netxen/netxen_nic_hw.c   |   25 ++++-
 drivers/net/netxen/netxen_nic_init.c |   52 ++++++-----
 drivers/net/netxen/netxen_nic_main.c |  112 +++++++++++++++++--------
 5 files changed, 206 insertions(+), 65 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 62aeab9..0e3be92 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -952,6 +952,26 @@ struct netxen_adapter {
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
+typedef u32 dma_watchdog_ctrl_t;
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
 
@@ -1031,8 +1051,8 @@ int netxen_nic_erase_pxe(struct netxen_a
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
@@ -1230,6 +1250,62 @@ static inline void get_brd_name_by_type(
 		name = "Unknown";
 }
 
+static inline int
+dma_watchdog_shutdown_request(struct netxen_adapter *adapter)
+{
+	dma_watchdog_ctrl_t ctrl;
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
+	dma_watchdog_ctrl_t ctrl;
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
+	dma_watchdog_ctrl_t ctrl;
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
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 608e37b..3276866 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -687,4 +687,6 @@ #define PCIE_TGT_SPLIT_CHICKEN	(0x12080)
 
 #define PCIE_MAX_MASTER_SPLIT	(0x14048)
 
+#define NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL		(0x14)
+
 #endif				/* __NETXEN_NIC_HDR_H_ */
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 4e958c9..f0df6fb 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -378,6 +378,7 @@ int netxen_nic_hw_resources(struct netxe
 						   crb_rcvpeg_state));
 		while (state != PHAN_PEG_RCV_INITIALIZED && loops < 20) {
 			udelay(100);
+			schedule();
 			/* Window 1 call */
 			state = readl(NETXEN_CRB_NORMALIZE(adapter,
 							   recv_crb_registers
@@ -700,7 +701,7 @@ void netxen_nic_pci_change_crbwindow(str
 		adapter->curr_window = 0;
 }
 
-void netxen_load_firmware(struct netxen_adapter *adapter)
+int netxen_load_firmware(struct netxen_adapter *adapter)
 {
 	int i;
 	u32 data, size = 0;
@@ -712,15 +713,25 @@ void netxen_load_firmware(struct netxen_
 	writel(1, NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CAS_RST));
 
 	for (i = 0; i < size; i++) {
-		if (netxen_rom_fast_read(adapter, flashaddr, (int *)&data) != 0) {
-			DPRINTK(ERR,
-				"Error in netxen_rom_fast_read(). Will skip"
-				"loading flash image\n");
-			return;
+		while (netxen_rom_fast_read(adapter, flashaddr, (int *)&data) != 0) {
+			long timeout = 2 * HZ;
+			while (timeout) {
+			    if (signal_pending(current)) {
+				printk( "%s: Got a signal, exiting\n", __FUNCTION__ );
+				return -1;
+			    }
+			    set_current_state(TASK_INTERRUPTIBLE);
+			    timeout = schedule_timeout(timeout);
+			}
 		}
+
 		off = netxen_nic_pci_set_window(adapter, memaddr);
 		addr = pci_base_offset(adapter, off);
 		writel(data, addr);
+		while (readl(addr) != data) {
+			mdelay(100);
+			writel(data, addr);
+		}
 		flashaddr += 4;
 		memaddr += 4;
 	}
@@ -730,7 +741,7 @@ void netxen_load_firmware(struct netxen_
 	       NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CHIP_CLK_CTRL));
 	writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CAS_RST));
 
-	udelay(100);
+	return 0;
 }
 
 int
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 15f6dc5..8f5f4f8 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -408,8 +408,12 @@ static inline int
 do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
 {
 	if (jiffies > (last_schedule_time + (8 * HZ))) {
-		last_schedule_time = jiffies;
-		schedule();
+		if (last_schedule_time) {
+			last_schedule_time = jiffies;
+			schedule();
+		} else {
+			last_schedule_time = jiffies;
+		}
 	}
 
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
@@ -856,10 +860,10 @@ int netxen_pinit_from_rom(struct netxen_
 				netxen_nic_pci_change_crbwindow(adapter, 1);
 			}
 			if (init_delay == 1) {
-				ssleep(1);
+				ssleep(2);
 				init_delay = 0;
 			}
-			msleep(1);
+			msleep(20);
 		}
 		kfree(buf);
 
@@ -935,10 +939,6 @@ int netxen_initialize_adapter_offload(st
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
@@ -947,25 +947,31 @@ void netxen_free_adapter_offload(struct 
 	}
 }
 
-void netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
+int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
 {
 	u32 val = 0;
-	int loops = 0;
 
 	if (!pegtune_val) {
-		val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
-		while (val != PHAN_INITIALIZE_COMPLETE && 
-			val != PHAN_INITIALIZE_ACK && loops < 200000) {
-			udelay(100);
-			schedule();
-			val =
-			    readl(NETXEN_CRB_NORMALIZE
+		do {
+			long timeout = 10 * HZ;
+			while (timeout) {
+				if (signal_pending(current)) {
+					printk(KERN_INFO"%s: Got a signal, exiting\n", __FUNCTION__ );
+					printk(KERN_INFO"%s: val=0x%x, pegtune_val=0x%x\n", __FUNCTION__,
+						val, pegtune_val );
+					return -1;
+				}
+				set_current_state(TASK_INTERRUPTIBLE);
+				timeout = schedule_timeout(timeout);
+			}
+			val = readl(NETXEN_CRB_NORMALIZE
 				  (adapter, CRB_CMDPEG_STATE));
-			loops++;
-		}
-		if (val != PHAN_INITIALIZE_COMPLETE)
-			printk("WARNING: Initial boot wait loop failed...\n");
+			pegtune_val = readl(NETXEN_CRB_NORMALIZE
+				  (adapter, NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
+		} while ((val != PHAN_INITIALIZE_COMPLETE) && (val != PHAN_INITIALIZE_ACK));
 	}
+
+	return 0;
 }
 
 int netxen_nic_rx_has_work(struct netxen_adapter *adapter)
@@ -1226,6 +1232,7 @@ u32 netxen_process_rcv_ring(struct netxe
 		       NETXEN_CRB_NORMALIZE(adapter,
 					    recv_crb_registers[adapter->portnum].
 					    crb_rcv_status_consumer));
+		wmb();
 	}
 
 	return count;
@@ -1278,11 +1285,13 @@ int netxen_process_cmd_ring(unsigned lon
 		if (skb && (cmpxchg(&buffer->skb, skb, 0) == skb)) {
 			pci_unmap_single(pdev, frag->dma, frag->length,
 					 PCI_DMA_TODEVICE);
+			frag->dma = (u64) NULL;
 			for (i = 1; i < buffer->frag_count; i++) {
 				DPRINTK(INFO, "getting fragment no %d\n", i);
 				frag++;	/* Get the next frag */
 				pci_unmap_page(pdev, frag->dma, frag->length,
 					       PCI_DMA_TODEVICE);
+				frag->dma = (u64) NULL;
 			}
 
 			adapter->stats.skbfreed++;
@@ -1448,6 +1457,7 @@ #endif
 			writel(msg,
 			       DB_NORMALIZE(adapter,
 					    NETXEN_RCV_PRODUCER_OFFSET));
+			wmb();
 		}
 	}
 }
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 44a6fcd..2714f33 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -525,11 +525,10 @@ #endif
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
 
@@ -547,13 +546,7 @@ #endif
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
+		mdelay(2000);
 	}
 
 	/*
@@ -644,8 +637,8 @@ static void __devexit netxen_nic_remove(
 	struct netxen_rx_buffer *buffer;
 	struct netxen_recv_context *recv_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
-	int i;
-	int ctxid, ring;
+	int i, ctxid, ring;
+	static int init_firmware_done = 0;
 
 	adapter = pci_get_drvdata(pdev);
 	if (adapter == NULL)
@@ -653,30 +646,21 @@ static void __devexit netxen_nic_remove(
 
 	netdev = adapter->netdev;
 
-	netxen_nic_disable_int(adapter);
-	if (adapter->irq)
-		free_irq(adapter->irq, adapter);
-	
+	unregister_netdev(netdev);
+	mdelay(3000);
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
@@ -696,17 +680,73 @@ static void __devexit netxen_nic_remove(
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
+			mdelay(100);
+			i = 100;	
+			while ((dma_watchdog_shutdown_poll_result(adapter) != 1) && i) {
+				printk(KERN_INFO"dma_watchdog_shutdown_poll still in progress\n");
+				mdelay(100);
+				i--;
+		}
+		
+		if (i == 0) {
+			printk(KERN_ERR"dma_watchdog_shutdown_request failed\n");
+			return;
+		}
+
+		/* clear the register for future unloads/loads */
+		writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
+		printk(KERN_INFO "State: 0x%0x\n",
+			readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
+
+		/* leave the hw in the same state as reboot */
+		writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+		if (netxen_pinit_from_rom(adapter, 0))
+			return;
+		udelay(500);
+		if (netxen_load_firmware(adapter))
+			return;
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
+			printk(KERN_INFO"dma_watchdog_shutdown_poll still in progress\n");
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
@@ -821,8 +861,10 @@ static int netxen_nic_close(struct net_d
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
