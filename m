From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Mon, 2 Jul 2007 10:54:01 -0400
Message-ID: <20070702145401.GA10000@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:48914 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753370AbXGBOyE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 10:54:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Note, this includes libertas ioctl removal.

For the record, I do not object to keeping the mesh ioctls, since no
one even has a -proposal- for mesh infrastructure, much less code.

But whatever.  The current state is not a crime either.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 MAINTAINERS                              |    8 +-
 drivers/net/gianfar.c                    |    2 +-
 drivers/net/myri10ge/myri10ge.c          |    2 +
 drivers/net/netxen/netxen_nic.h          |  180 +++++-
 drivers/net/netxen/netxen_nic_hdr.h      |    2 +
 drivers/net/netxen/netxen_nic_hw.c       |   33 +-
 drivers/net/netxen/netxen_nic_init.c     |   51 +-
 drivers/net/netxen/netxen_nic_main.c     |  177 +++--
 drivers/net/netxen/netxen_nic_phan_reg.h |   14 +
 drivers/net/ns83820.c                    |    4 +-
 drivers/net/pcmcia/3c589_cs.c            |    2 +-
 drivers/net/starfire.c                   |    2 +-
 drivers/net/usb/cdc_ether.c              |    8 +-
 drivers/net/usb/dm9601.c                 |   11 +-
 drivers/net/usb/usbnet.c                 |    9 +-
 drivers/net/wireless/libertas/Makefile   |    2 +-
 drivers/net/wireless/libertas/README     |  275 --------
 drivers/net/wireless/libertas/assoc.c    |   28 +-
 drivers/net/wireless/libertas/cmd.c      |   12 +-
 drivers/net/wireless/libertas/cmdresp.c  |   21 +
 drivers/net/wireless/libertas/hostcmd.h  |    2 +-
 drivers/net/wireless/libertas/ioctl.c    | 1081 ------------------------------
 drivers/net/wireless/libertas/main.c     |    8 +-
 drivers/net/wireless/libertas/scan.c     |   51 +-
 drivers/net/wireless/libertas/wext.c     |  152 -----
 drivers/net/wireless/libertas/wext.h     |   45 +--
 26 files changed, 447 insertions(+), 1735 deletions(-)
 delete mode 100644 drivers/net/wireless/libertas/ioctl.c

Adrian Bunk (1):
      drivers/net/ns83820.c: fix a check-after-use

Dan Williams (4):
      libertas: style fixes
      libertas: kill wlan_scan_process_results
      libertas: fix WPA associations by handling ENABLE_RSN correctly
      libertas: remove private ioctls

David Brownell (1):
      net/usb/cdc_ether minor sparse cleanup

Dhananjay Phadke (1):
      RESEND [PATCH 3/3] NetXen: Graceful teardown of interface and hardware upon module unload

Kumar Gala (1):
      gianfar: Fix typo bug introduced by move to udp_hdr()

Maik Hampel (1):
      myri10ge: SET_NETDEV_DEV()

Patrick McHardy (1):
      3c589_cs: fix local_bh_enable warning

Peter Korsgaard (4):
      dm9601: HW header size shouldn't be included in packet length
      usbnet: Zero padding byte if there is tail room in skb
      Update MAINTAINERS for USB network devices
      dm9601: Return 0 from bind() on success

dhananjay.phadke@gmail.com (2):
      RESEND [PATCH 1/3] NetXen: Fix issue of MSI not working correctly
      RESEND [PATCH 2/3] NetXen: Support per PCI-function interrupt mask registers

maximilian attems (1):
      starfire list alpha as 64 bit arch

diff --git a/MAINTAINERS b/MAINTAINERS
index 4ce895a..23a04f4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3618,7 +3618,7 @@ W:	http://www.kroah.com/linux-usb/
 USB DAVICOM DM9601 DRIVER
 P:	Peter Korsgaard
 M:	jacmet@sunsite.dk
-L:	linux-usb-devel@lists.sourceforge.net
+L:	netdev@vger.kernel.org
 W:	http://www.linux-usb.org/usbnet
 S:	Maintained
 
@@ -3702,8 +3702,8 @@ S:	Maintained
 USB PEGASUS DRIVER
 P:	Petko Manolov
 M:	petkan@users.sourceforge.net
-L:	linux-usb-users@lists.sourceforge.net
 L:	linux-usb-devel@lists.sourceforge.net
+L:	netdev@vger.kernel.org
 W:	http://pegasus2.sourceforge.net/
 S:	Maintained
 
@@ -3717,8 +3717,8 @@ S:	Maintained
 USB RTL8150 DRIVER
 P:	Petko Manolov
 M:	petkan@users.sourceforge.net
-L:	linux-usb-users@lists.sourceforge.net
 L:	linux-usb-devel@lists.sourceforge.net
+L:	netdev@vger.kernel.org
 W:	http://pegasus2.sourceforge.net/
 S:	Maintained
 
@@ -3829,7 +3829,7 @@ S:	Maintained
 USB "USBNET" DRIVER FRAMEWORK
 P:	David Brownell
 M:	dbrownell@users.sourceforge.net
-L:	linux-usb-devel@lists.sourceforge.net
+L:	netdev@vger.kernel.org
 W:	http://www.linux-usb.org/usbnet
 S:	Maintained
 
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6822bf1..1b854bf 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -944,7 +944,7 @@ static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb)
 		flags |= TXFCB_UDP;
 		fcb->phcs = udp_hdr(skb)->check;
 	} else
-		fcb->phcs = udp_hdr(skb)->check;
+		fcb->phcs = tcp_hdr(skb)->check;
 
 	/* l3os is the distance between the start of the
 	 * frame (skb->data) and the start of the IP hdr.
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 0f9904f..d0cc122 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -2854,6 +2854,8 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		return -ENOMEM;
 	}
 
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
 	mgp = netdev_priv(netdev);
 	memset(mgp, 0, sizeof(*mgp));
 	mgp->dev = netdev;
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 91f25e0..6195037 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -937,6 +937,7 @@ struct netxen_adapter {
 	struct netxen_ring_ctx *ctx_desc;
 	struct pci_dev *ctx_desc_pdev;
 	dma_addr_t ctx_desc_phys_addr;
+	int intr_scheme;
 	int (*enable_phy_interrupts) (struct netxen_adapter *);
 	int (*disable_phy_interrupts) (struct netxen_adapter *);
 	void (*handle_phy_intr) (struct netxen_adapter *);
@@ -951,6 +952,24 @@ struct netxen_adapter {
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
 
@@ -1030,8 +1049,8 @@ int netxen_nic_erase_pxe(struct netxen_adapter *adapter);
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
@@ -1080,37 +1099,106 @@ struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev);
 
 static inline void netxen_nic_disable_int(struct netxen_adapter *adapter)
 {
-	/*
-	 * ISR_INT_MASK: Can be read from window 0 or 1.
-	 */
-	writel(0x7ff, PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
+	uint32_t	mask = 0x7ff;
+	int retries = 32;
+
+	DPRINTK(1, INFO, "Entered ISR Disable \n");
+
+	switch (adapter->portnum) {
+	case 0:
+		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
+		break;
+	case 1:
+		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
+		break;
+	case 2:
+		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
+		break;
+	case 3:
+		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
+		break;
+	}
 
+	if (adapter->intr_scheme != -1 &&
+		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
+		writel(mask,
+			(void *)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
+	}
+
+	/* Window = 0 or 1 */
+	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
+		do {
+			writel(0xffffffff, (void *)
+				(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_STATUS)));
+			mask = readl((void *)
+					(pci_base_offset(adapter, ISR_INT_VECTOR)));
+			if (!(mask & 0x80))
+				break;
+			udelay(10);
+		} while (--retries);
+
+		if (!retries) {
+			printk(KERN_NOTICE "%s: Failed to disable interrupt completely\n",
+					netxen_nic_driver_name);
+		}
+	}
+
+	DPRINTK(1, INFO, "Done with Disable Int\n");
+
+	return;
 }
 
 static inline void netxen_nic_enable_int(struct netxen_adapter *adapter)
 {
 	u32 mask;
 
-	switch (adapter->ahw.board_type) {
-	case NETXEN_NIC_GBE:
-		mask = 0x77b;
+	DPRINTK(1, INFO, "Entered ISR Enable \n");
+
+	if (adapter->intr_scheme != -1 &&
+		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
+		switch (adapter->ahw.board_type) {
+		case NETXEN_NIC_GBE:
+			mask  =  0x77b;
+			break;
+		case NETXEN_NIC_XGBE:
+			mask  =  0x77f;
+			break;
+		default:
+			mask  =  0x7ff;
+			break;
+		}
+
+		writel(mask,
+			(void *)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
+	}
+	switch (adapter->portnum) {
+	case 0:
+		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
+		break;
+	case 1:
+		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
 		break;
-	case NETXEN_NIC_XGBE:
-		mask = 0x77f;
+	case 2:
+		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
 		break;
-	default:
-		mask = 0x7ff;
+	case 3:
+		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
 		break;
 	}
 
-	writel(mask, PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
-
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		mask = 0xbff;
-		writel(0X0, NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
-		writel(mask, PCI_OFFSET_SECOND_RANGE(adapter,
-						     ISR_INT_TARGET_MASK));
+		if (adapter->intr_scheme != -1 &&
+			adapter->intr_scheme != INTR_SCHEME_PERPORT) {
+			writel(0X0, NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+		}
+		writel(mask,
+			(void *)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_MASK)));
 	}
+
+	DPRINTK(1, INFO, "Done with enable Int\n");
+
+	return;
 }
 
 /*
@@ -1164,6 +1252,62 @@ static inline void get_brd_name_by_type(u32 type, char *name)
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
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 608e37b..3276866 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -687,4 +687,6 @@ enum {
 
 #define PCIE_MAX_MASTER_SPLIT	(0x14048)
 
+#define NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL		(0x14)
+
 #endif				/* __NETXEN_NIC_HDR_H_ */
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index c012764..aac1542 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -377,7 +377,7 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 						   recv_crb_registers[ctx].
 						   crb_rcvpeg_state));
 		while (state != PHAN_PEG_RCV_INITIALIZED && loops < 20) {
-			udelay(100);
+			msleep(1);
 			/* Window 1 call */
 			state = readl(NETXEN_CRB_NORMALIZE(adapter,
 							   recv_crb_registers
@@ -392,7 +392,11 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 			return err;
 		}
 	}
-	DPRINTK(INFO, "Recieve Peg ready too. starting stuff\n");
+	adapter->intr_scheme = readl(
+		NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_FW));
+	printk(KERN_NOTICE "%s: FW capabilities:0x%x\n", netxen_nic_driver_name,
+			adapter->intr_scheme);
+	DPRINTK(INFO, "Receive Peg ready too. starting stuff\n");
 
 	addr = netxen_alloc(adapter->ahw.pdev,
 			    sizeof(struct netxen_ring_ctx) +
@@ -697,7 +701,7 @@ void netxen_nic_pci_change_crbwindow(struct netxen_adapter *adapter, u32 wndw)
 		adapter->curr_window = 0;
 }
 
-void netxen_load_firmware(struct netxen_adapter *adapter)
+int netxen_load_firmware(struct netxen_adapter *adapter)
 {
 	int i;
 	u32 data, size = 0;
@@ -709,15 +713,24 @@ void netxen_load_firmware(struct netxen_adapter *adapter)
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
+			msleep(100);
+			writel(data, addr);
+		} while (--retries);
+		if (!retries) {
+			printk(KERN_ERR "%s: firmware load aborted, write failed at 0x%x\n",
+					netxen_nic_driver_name, memaddr);
+			return -EIO;
+		}
 		flashaddr += 4;
 		memaddr += 4;
 	}
@@ -727,7 +740,7 @@ void netxen_load_firmware(struct netxen_adapter *adapter)
 	       NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CHIP_CLK_CTRL));
 	writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CAS_RST));
 
-	udelay(100);
+	return 0;
 }
 
 int
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index bb23f4c..1811bcb 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -139,6 +139,8 @@ int netxen_init_firmware(struct netxen_adapter *adapter)
 		return err;
 	}
 	/* Window 1 call */
+	writel(INTR_SCHEME_PERPORT,
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_HOST));
 	writel(MPORT_MULTI_FUNCTION_MODE,
 	       NETXEN_CRB_NORMALIZE(adapter, CRB_MPORT_MODE));
 	writel(PHAN_INITIALIZE_ACK,
@@ -405,10 +407,7 @@ static inline int do_rom_fast_write(struct netxen_adapter *adapter, int addr,
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
@@ -854,10 +853,10 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 				netxen_nic_pci_change_crbwindow(adapter, 1);
 			}
 			if (init_delay == 1) {
-				ssleep(1);
+				msleep(2000);
 				init_delay = 0;
 			}
-			msleep(1);
+			msleep(20);
 		}
 		kfree(buf);
 
@@ -933,10 +932,6 @@ int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
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
@@ -945,25 +940,32 @@ void netxen_free_adapter_offload(struct netxen_adapter *adapter)
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
+			msleep(1000);
+		} while (--retries);
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
@@ -1120,6 +1122,7 @@ netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 		adapter->stats.csummed++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
+	skb->dev = netdev;
 	if (desc_ctx == RCV_DESC_LRO_CTXID) {
 		/* True length was only available on the last pkt */
 		skb_put(skb, buffer->lro_length);
@@ -1224,6 +1227,7 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 		       NETXEN_CRB_NORMALIZE(adapter,
 					    recv_crb_registers[adapter->portnum].
 					    crb_rcv_status_consumer));
+		wmb();
 	}
 
 	return count;
@@ -1276,11 +1280,13 @@ int netxen_process_cmd_ring(unsigned long data)
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
@@ -1446,6 +1452,7 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 			writel(msg,
 			       DB_NORMALIZE(adapter,
 					    NETXEN_RCV_PRODUCER_OFFSET));
+			wmb();
 		}
 	}
 }
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 6167b58..a66ff58 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -308,7 +308,13 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	adapter->netdev  = netdev;
 	adapter->pdev    = pdev;
+
+	/* this will be read from FW later */
+	adapter->intr_scheme = -1;
+
+	/* This will be reset for mezz cards  */
 	adapter->portnum = pci_func_id;
+	adapter->status   &= ~NETXEN_NETDEV_STATUS;
 
 	netdev->open		   = netxen_nic_open;
 	netdev->stop		   = netxen_nic_close;
@@ -336,11 +342,9 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
@@ -355,13 +359,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
@@ -509,22 +506,30 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 					NETXEN_CAM_RAM(0x1fc)));
 		if (val == 0x55555555) {
 		    /* This is the first boot after power up */
+		    netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(0x4), &val);
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
 
@@ -542,13 +547,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
@@ -639,8 +637,8 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 	struct netxen_rx_buffer *buffer;
 	struct netxen_recv_context *recv_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
-	int i;
-	int ctxid, ring;
+	int i, ctxid, ring;
+	static int init_firmware_done = 0;
 
 	adapter = pci_get_drvdata(pdev);
 	if (adapter == NULL)
@@ -648,30 +646,20 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
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
@@ -691,17 +679,73 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
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
+		msleep(100);
+		i = 100;
+		while ((dma_watchdog_shutdown_poll_result(adapter) != 1) && i) {
+			printk(KERN_INFO "dma_watchdog_shutdown_poll still in progress\n");
+			msleep(100);
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
@@ -798,7 +842,7 @@ static int netxen_nic_close(struct net_device *netdev)
 		if (buffrag->dma) {
 			pci_unmap_single(adapter->pdev, buffrag->dma,
 					 buffrag->length, PCI_DMA_TODEVICE);
-			buffrag->dma = (u64) NULL;
+			buffrag->dma = 0ULL;
 		}
 		for (j = 0; j < cmd_buff->frag_count; j++) {
 			buffrag++;
@@ -806,7 +850,7 @@ static int netxen_nic_close(struct net_device *netdev)
 				pci_unmap_page(adapter->pdev, buffrag->dma,
 					       buffrag->length, 
 					       PCI_DMA_TODEVICE);
-				buffrag->dma = (u64) NULL;
+				buffrag->dma = 0ULL;
 			}
 		}
 		/* Free the skb we received in netxen_nic_xmit_frame */
@@ -816,8 +860,10 @@ static int netxen_nic_close(struct net_device *netdev)
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
@@ -1103,28 +1149,26 @@ static int
 netxen_handle_int(struct netxen_adapter *adapter, struct net_device *netdev)
 {
 	u32 ret = 0;
+	u32 our_int = 0;
 
 	DPRINTK(INFO, "Entered handle ISR\n");
 	adapter->stats.ints++;
 
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
-		int count = 0;
-		u32 mask;
-		u32 our_int = 0;
 		our_int = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
 		/* not our interrupt */
 		if ((our_int & (0x80 << adapter->portnum)) == 0)
 			return ret;
-		netxen_nic_disable_int(adapter);
-		/* Window = 0 or 1 */
-		do {
-			writel(0xffffffff, PCI_OFFSET_SECOND_RANGE(adapter,
-						ISR_INT_TARGET_STATUS));
-			mask = readl(pci_base_offset(adapter, ISR_INT_VECTOR));
-		} while (((mask & 0x80) != 0) && (++count < 32));
-		if ((mask & 0x80) != 0)
-			printk("Could not disable interrupt completely\n");
+	}
 
+	netxen_nic_disable_int(adapter);
+
+	if (adapter->intr_scheme == INTR_SCHEME_PERPORT) {
+		/* claim interrupt */
+		if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
+			writel(our_int & ~((u32)(0x80 << adapter->portnum)),
+			NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+		}
 	}
 
 	if (netxen_nic_rx_has_work(adapter) || netxen_nic_tx_has_work(adapter)) {
@@ -1136,7 +1180,7 @@ netxen_handle_int(struct netxen_adapter *adapter, struct net_device *netdev)
 		} else {
 			static unsigned int intcount = 0;
 			if ((++intcount & 0xfff) == 0xfff)
-				printk(KERN_ERR
+				DPRINTK(KERN_ERR
 				       "%s: %s interrupt %d while in poll\n",
 				       netxen_nic_driver_name, netdev->name,
 				       intcount);
@@ -1258,6 +1302,7 @@ static void __exit netxen_exit_module(void)
 	/*
 	 * Wait for some time to allow the dma to drain, if any.
 	 */
+	msleep(100);
 	pci_unregister_driver(&netxen_driver);
 	destroy_workqueue(netxen_workq);
 }
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 9457fc7..10fe6fa 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -114,6 +114,20 @@
 #define CRB_V2P_3		    NETXEN_NIC_REG(0x29c)
 #define CRB_V2P(port)		    (CRB_V2P_0+((port)*4))
 #define CRB_DRIVER_VERSION	    NETXEN_NIC_REG(0x2a0)
+/* sw int status/mask registers */
+#define CRB_SW_INT_MASK_0	   NETXEN_NIC_REG(0x1d8)
+#define CRB_SW_INT_MASK_1	   NETXEN_NIC_REG(0x1e0)
+#define CRB_SW_INT_MASK_2	   NETXEN_NIC_REG(0x1e4)
+#define CRB_SW_INT_MASK_3	   NETXEN_NIC_REG(0x1e8)
+
+/*
+ * capabilities register, can be used to selectively enable/disable features
+ * for backward compability
+ */
+#define CRB_NIC_CAPABILITIES_HOST	NETXEN_NIC_REG(0x1a8)
+#define CRB_NIC_CAPABILITIES_FW	  	NETXEN_NIC_REG(0x1dc)
+
+#define INTR_SCHEME_PERPORT	      	0x1
 
 /* used for ethtool tests */
 #define CRB_SCRATCHPAD_TEST	    NETXEN_NIC_REG(0x280)
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 717d8e9..104aab3 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1831,11 +1831,13 @@ static int __devinit ns83820_init_one(struct pci_dev *pci_dev, const struct pci_
 
 	ndev = alloc_etherdev(sizeof(struct ns83820));
 	dev = PRIV(ndev);
-	dev->ndev = ndev;
+
 	err = -ENOMEM;
 	if (!dev)
 		goto out;
 
+	dev->ndev = ndev;
+
 	spin_lock_init(&dev->rx_info.lock);
 	spin_lock_init(&dev->tx_lock);
 	spin_lock_init(&dev->misc_lock);
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 143ae2f..503f268 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -629,9 +629,9 @@ static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	outw(SetTxThreshold + 1536, ioaddr + EL3_CMD);
     }
 
-    dev_kfree_skb(skb);
     pop_tx_status(dev);
     spin_unlock_irqrestore(&priv->lock, flags);    
+    dev_kfree_skb(skb);
     
     return 0;
 }
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 9d6e454..786d4b9 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -152,7 +152,7 @@ static int full_duplex[MAX_UNITS] = {0, };
  * This SUCKS.
  * We need a much better method to determine if dma_addr_t is 64-bit.
  */
-#if (defined(__i386__) && defined(CONFIG_HIGHMEM64G)) || defined(__x86_64__) || defined (__ia64__) || defined(__mips64__) || (defined(__mips__) && defined(CONFIG_HIGHMEM) && defined(CONFIG_64BIT_PHYS_ADDR))
+#if (defined(__i386__) && defined(CONFIG_HIGHMEM64G)) || defined(__x86_64__) || defined (__ia64__) || defined(__alpha__) || defined(__mips64__) || (defined(__mips__) && defined(CONFIG_HIGHMEM) && defined(CONFIG_64BIT_PHYS_ADDR))
 /* 64-bit dma_addr_t */
 #define ADDR_64BITS	/* This chip uses 64 bit addresses. */
 #define netdrv_addr_t u64
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 675ac99..a42acc3 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -144,14 +144,14 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 			 * modem interface from an RNDIS non-modem.
 			 */
 			if (rndis) {
-				struct usb_cdc_acm_descriptor *d;
+				struct usb_cdc_acm_descriptor *acm;
 
-				d = (void *) buf;
-				if (d->bmCapabilities) {
+				acm = (void *) buf;
+				if (acm->bmCapabilities) {
 					dev_dbg(&intf->dev,
 						"ACM capabilities %02x, "
 						"not really RNDIS?\n",
-						d->bmCapabilities);
+						acm->bmCapabilities);
 					goto bad_desc;
 				}
 			}
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index a676386..16c7a0e 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -414,18 +414,16 @@ static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->mii.reg_num_mask = 0x1f;
 
 	/* reset */
-	ret = dm_write_reg(dev, DM_NET_CTRL, 1);
+	dm_write_reg(dev, DM_NET_CTRL, 1);
 	udelay(20);
 
 	/* read MAC */
-	ret = dm_read(dev, DM_PHY_ADDR, ETH_ALEN, dev->net->dev_addr);
-	if (ret < 0) {
+	if (dm_read(dev, DM_PHY_ADDR, ETH_ALEN, dev->net->dev_addr) < 0) {
 		printk(KERN_ERR "Error reading MAC address\n");
 		ret = -ENODEV;
 		goto out;
 	}
 
-
 	/* power up phy */
 	dm_write_reg(dev, DM_GPR_CTRL, 1);
 	dm_write_reg(dev, DM_GPR_DATA, 0);
@@ -489,6 +487,8 @@ static struct sk_buff *dm9601_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 	   b3..n: packet data
 	*/
 
+	len = skb->len;
+
 	if (skb_headroom(skb) < DM_TX_OVERHEAD) {
 		struct sk_buff *skb2;
 
@@ -501,10 +501,9 @@ static struct sk_buff *dm9601_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 
 	__skb_push(skb, DM_TX_OVERHEAD);
 
-	len = skb->len;
 	/* usbnet adds padding if length is a multiple of packet size
 	   if so, adjust length value in header */
-	if ((len % dev->maxpacket) == 0)
+	if ((skb->len % dev->maxpacket) == 0)
 		len++;
 
 	skb->data[0] = len;
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 5b16d9a..a12f576 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -953,11 +953,14 @@ static int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
 	/* don't assume the hardware handles USB_ZERO_PACKET
 	 * NOTE:  strictly conforming cdc-ether devices should expect
 	 * the ZLP here, but ignore the one-byte packet.
-	 *
-	 * FIXME zero that byte, if it doesn't require a new skb.
 	 */
-	if ((length % dev->maxpacket) == 0)
+	if ((length % dev->maxpacket) == 0) {
 		urb->transfer_buffer_length++;
+		if (skb_tailroom(skb)) {
+			skb->data[skb->len] = 0;
+			__skb_put(skb, 1);
+		}
+	}
 
 	spin_lock_irqsave (&dev->txq.lock, flags);
 
diff --git a/drivers/net/wireless/libertas/Makefile b/drivers/net/wireless/libertas/Makefile
index a1097f5..32ed413 100644
--- a/drivers/net/wireless/libertas/Makefile
+++ b/drivers/net/wireless/libertas/Makefile
@@ -2,7 +2,7 @@ libertas-objs := main.o fw.o wext.o \
 		rx.o tx.o cmd.o 	  \
 		cmdresp.o scan.o	  \
 		join.o 11d.o 		  \
-		ioctl.o debugfs.o	  \
+		debugfs.o	  \
 		ethtool.o assoc.o
 
 usb8xxx-objs += if_bootcmd.o
diff --git a/drivers/net/wireless/libertas/README b/drivers/net/wireless/libertas/README
index 1f92f50..0b133ce 100644
--- a/drivers/net/wireless/libertas/README
+++ b/drivers/net/wireless/libertas/README
@@ -28,281 +28,6 @@ DRIVER LOADING
 
 		insmod usb8388.ko [fw_name=usb8388.bin]
 
-=====================
-IWPRIV COMMAND
-=====================
-
-NAME
-	This manual describes the usage of private commands used in Marvell WLAN
-	Linux Driver. All the commands available in Wlanconfig will not be available
-	in the iwpriv.
-
-SYNOPSIS
-	iwpriv <ethX> <command> [sub-command] ...
-
-	iwpriv ethX setregioncode <n>
-	iwpriv ethX getregioncode
-
-Version 5 Command:
-	iwpriv ethX ledgpio <n>
-
-BT Commands:
-	The blinding table (BT) contains a list of mac addresses that will be,
-	by default, ignored by the firmware. It is also possible to invert this
-	behavior so that we will ignore all traffic except for the portion
-	coming from mac addresess in the list. It is primarily used for
-	debugging and testing networks.  It can be edited and inspected with
-	the following commands:
-
-	iwpriv ethX bt_reset
-	iwpriv ethX bt_add <mac_address>
-	iwpriv ethX bt_del <mac_address>
-	iwpriv ethX bt_list <id>
-	iwpriv ethX bt_get_invert <n>
-	iwpriv ethX bt_set_invert <n>
-
-FWT Commands:
-	The forwarding table (FWT) is a feature used to manage mesh network
-	routing in the firmware.  The FWT is essentially a routing table that
-	associates a destination mac address (da) with a next hop receiver
-	address (ra).  The FWT can be inspected and edited with the following
-	iwpriv commands, which are described in greater detail below.
-	Eventually, the table will be automatically maintained by a custom
-	routing protocol.
-
-	NOTE: FWT commands replace the previous DFT commands.  What were the DFT
-	commands?, you might ask.  They were an earlier API to the firmware that
-	implemented a simple MAC-layer forwarding mechanism.  In the unlikely
-	event that you were using these commands, you must migrate to the new
-	FWT commands which can be used to achieve the same functionality.
-
-	iwpriv ethX fwt_add [parameters]
-	iwpriv ethX fwt_del [parameters]
-	iwpriv ethX fwt_lookup [parameters]
-	iwpriv ethX fwt_list [parameters]
-	iwpriv ethX fwt_list_route [parameters]
-	iwpriv ethX fwt_list_neigh [parameters]
-	iwpriv ethX fwt_reset [parameters]
-	iwpriv ethX fwt_cleanup
-	iwpriv ethX fwt_time
-
-MESH Commands:
-
-	The MESH commands are used to configure various features of the mesh
-	routing protocol.  The following commands are supported:
-
-	iwpriv ethX mesh_get_ttl
-	iwpriv ethX mesh_set_ttl ttl
-
-DESCRIPTION
-	Those commands are used to send additional commands to the Marvell WLAN
-	card via the Linux device driver.
-
-	The ethX parameter specifies the network device that is to be used to
-		perform this command on. it could be eth0, eth1 etc.
-
-setregioncode
-	This command is used to set the region code in the station.
-	where value is 'region code' for various regions like
-	USA FCC, Canada IC, Spain, France, Europe ETSI,	Japan ...
-
-	Usage:
-		iwpriv ethX setregioncode 0x10: set region code to USA (0x10).
-
-getregioncode
-	This command is used to get the region code information set in the
-	station.
-
-ledgpio
-	This command is used to set/get LEDs.
-
-	iwpriv ethX ledgpio <LEDs>
-		will set the corresponding LED for the GPIO Line.
-
-	iwpriv ethX ledgpio
-		will give u which LEDs are Enabled.
-
-	Usage:
-		iwpriv eth1 ledgpio 1 0 2 1 3 4
-			will enable
-			LED 1 -> GPIO 0
-			LED 2 -> GPIO 1
-			LED 3 -> GPIO 4
-
-		iwpriv eth1 ledgpio
-			shows LED information in the format as mentioned above.
-
-	Note: LED0 is invalid
-	Note: Maximum Number of LEDs are 16.
-
-fwt_add
-	This command is used to insert an entry into the FWT table. The list of
-	parameters must follow the following structure:
-
-	iwpriv ethX fwt_add da ra [metric dir rate ssn dsn hopcount ttl expiration sleepmode snr]
-
-	The parameters between brackets are optional, but they must appear in
-	the order specified.  For example, if you want to specify the metric,
-	you must also specify the dir, ssn, and dsn but you need not specify the
-	hopcount, expiration, sleepmode, or snr.  Any unspecified parameters
-	will be assigned the defaults specified below.
-
-	The different parameters are:-
-		da		-- DA MAC address in the form 00:11:22:33:44:55
-		ra		-- RA MAC address in the form 00:11:22:33:44:55
-		metric		-- route metric (cost: smaller-metric routes are
-				   preferred, default is 0)
-		dir		-- direction (1 for direct, 0 for reverse,
-				   default is 1)
-		rate		-- data rate used for transmission to the RA,
-				   as specified for the rateadapt command,
-				   default is 3 (11Mbps)
-		ssn		-- Source Sequence Number (time at the RA for
-				   reverse routes.  Default is 0)
-		dsn		-- Destination Sequence Number (time at the DA
-				   for direct routes.  Default is 0)
-		hopcount	-- hop count (currently unused, default is 0)
-		ttl		-- TTL (Only used in reverse entries)
-		expiration	-- entry expiration (in ticks, where a tick is
-				   1024us, or ~ 1ms. Use 0 for an indefinite
-				   entry, default is 0)
-		sleepmode	-- RA's sleep mode (currently unused, default is
-				   0)
-		snr		-- SNR in the link to RA (currently unused,
-				   default is 0)
-
-	The command does not return anything.
-
-fwt_del
-	This command is used to remove an entry to the FWT table. The list of
-	parameters must follow the following structure:
-
-		iwpriv ethX fwt_del da ra [dir]
-
-	where the different parameters are:-
-		da		-- DA MAC address (in the form "00:11:22:33:44:55")
-		ra		-- RA MAC address (in the form "00:11:22:33:44:55")
-		dir		-- direction (1 for direct, 0 for reverse,
-				   default is 1)
-
-	The command does not return anything.
-
-fwt_lookup
-	This command is used to get the best route in the FWT table to a given
-	host. The only parameter is the MAC address of the host that is being
-	looked for.
-
-		iwpriv ethX fwt_lookup da
-
-	where:-
-		da		-- DA MAC address (in the form "00:11:22:33:44:55")
-
-	The command returns an output string identical to the one returned by
-	fwt_list described below.
-
-
-fwt_list
-	This command is used to list a route from the FWT table. The only
-	parameter is the index into the table. If you want to list all the
-	routes in a table, start with index=0, and keep listing until you get a
-	"(null)" string.  Note that the indicies may change as the fwt is
-	updated.  It is expected that most users will not use fwt_list directly,
-	but that a utility similar to the traditional route command will be used
-	to invoke fwt_list over and over.
-
-		iwpriv ethX fwt_list index
-
-	The output is a string of the following form:
-
-		da ra valid metric dir rate ssn dsn hopcount ttl expiration
-		sleepmode snr precursor
-
-	where the different fields are:-
-		da		-- DA MAC address (in the form "00:11:22:33:44:55")
-		ra		-- RA MAC address (in the form "00:11:22:33:44:55")
-		valid		-- whether the route is valid (0 if not valid)
-		metric		-- route metric (cost: smaller-metric routes are preferred)
-		dir		-- direction (1 for direct, 0 for reverse)
-		rate		-- data rate used for transmission to the RA,
-				   as specified for the rateadapt command
-		ssn		-- Source Sequence Number (time at the RA for reverse routes)
-		dsn		-- Destination Sequence Number (time at the DA for direct routes)
-		hopcount	-- hop count (currently unused)
-		ttl		-- TTL (only used in reverse entries)
-		expiration	-- entry expiration (in ticks, where a tick is 1024us, or ~ 1ms. Use 0 for an indefinite entry)
-		sleepmode	-- RA's sleep mode (currently unused)
-		snr		-- SNR in the link to RA (currently unused)
-		precursor	-- predecessor in direct routes
-
-fwt_list_route
-	This command is equivalent to fwt_list.
-
-fwt_list_neigh
-	This command is used to list a neighbor from the FWT table. The only
-	parameter is the neighbor ID. If you want to list all the neighbors in a
-	table, start with nid=0, and keep incrementing nid until you get a
-	"(null)" string.  Note that the nid from a fwt_list_route command can be
-	used as an input to this command.  Also note that this command is meant
-	mostly for debugging.  It is expected that users will use fwt_lookup.
-	One important reason for this is that the neighbor id may change as the
-	neighbor table is altered.
-
-		iwpriv ethX fwt_list_neigh nid
-
-	The output is a string of the following form:
-
-		ra sleepmode snr references
-
-	where the different fields are:-
-		ra		-- RA MAC address (in the form "00:11:22:33:44:55")
-		sleepmode	-- RA's sleep mode (currently unused)
-		snr		-- SNR in the link to RA (currently unused)
-		references	-- RA's reference counter
-
-fwt_reset
-	This command is used to reset the FWT table, getting rid of all the
-	entries. There are no input parameters.
-
-		iwpriv ethX fwt_reset
-
-	The command does not return anything.
-
-fwt_cleanup
-	This command is used to perform user-based garbage recollection. The
-	FWT table is checked, and all the entries that are expired or invalid
-	are cleaned. Note that this is exported to the driver for debugging
-	purposes, as garbage collection is also fired by the firmware when in
-	space problems. There are no input parameters.
-
-		iwpriv ethX fwt_cleanup
-
-	The command does returns the number of invalid/expired routes deleted.
-
-fwt_time
-	This command returns a card's internal time representation.  It is this
-	time that is used to represent the expiration times of FWT entries.  The
-	number is not consistent from card to card; it is simply a timer count.
-	The fwt_time command is used to inspect the timer so that expiration
-	times reported by fwt_list can be properly interpreted.
-
-		iwpriv ethX fwt_time
-
-mesh_get_ttl
-
-	The mesh ttl is the number of hops a mesh packet can traverse before it
-	is dropped.  This parameter is used to prevent infinite loops in the
-	mesh network.  The value returned by this function is the ttl assigned
-	to all mesh packets.  Currently there is no way to control the ttl on a
-	per packet or per socket basis.
-
-	iwpriv ethX mesh_get_ttl
-
-mesh_set_ttl ttl
-
-	Set the ttl.  The argument must be between 0 and 255.
-
-	iwpriv ethX mesh_set_ttl <ttl>
-
 =========================
 ETHTOOL
 =========================
diff --git a/drivers/net/wireless/libertas/assoc.c b/drivers/net/wireless/libertas/assoc.c
index f67efa0..afd5617 100644
--- a/drivers/net/wireless/libertas/assoc.c
+++ b/drivers/net/wireless/libertas/assoc.c
@@ -323,6 +323,8 @@ static int assoc_helper_secinfo(wlan_private *priv,
 {
 	wlan_adapter *adapter = priv->adapter;
 	int ret = 0;
+	u32 do_wpa;
+	u32 rsn = 0;
 
 	lbs_deb_enter(LBS_DEB_ASSOC);
 
@@ -333,12 +335,34 @@ static int assoc_helper_secinfo(wlan_private *priv,
 	if (ret)
 		goto out;
 
-	/* enable/disable RSN */
+	/* If RSN is already enabled, don't try to enable it again, since
+	 * ENABLE_RSN resets internal state machines and will clobber the
+	 * 4-way WPA handshake.
+	 */
+
+	/* Get RSN enabled/disabled */
 	ret = libertas_prepare_and_send_command(priv,
 				    cmd_802_11_enable_rsn,
 				    cmd_act_set,
 				    cmd_option_waitforrsp,
-				    0, assoc_req);
+				    0, &rsn);
+	if (ret) {
+		lbs_deb_assoc("Failed to get RSN status: %d", ret);
+		goto out;
+	}
+
+	/* Don't re-enable RSN if it's already enabled */
+	do_wpa = (assoc_req->secinfo.WPAenabled || assoc_req->secinfo.WPA2enabled);
+	if (do_wpa == rsn)
+		goto out;
+
+	/* Set RSN enabled/disabled */
+	rsn = do_wpa;
+	ret = libertas_prepare_and_send_command(priv,
+				    cmd_802_11_enable_rsn,
+				    cmd_act_set,
+				    cmd_option_waitforrsp,
+				    0, &rsn);
 
 out:
 	lbs_deb_leave_args(LBS_DEB_ASSOC, "ret %d", ret);
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index 124e029..13f6528 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -228,17 +228,19 @@ static int wlan_cmd_802_11_enable_rsn(wlan_private * priv,
 				      void * pdata_buf)
 {
 	struct cmd_ds_802_11_enable_rsn *penableRSN = &cmd->params.enbrsn;
-	struct assoc_request * assoc_req = pdata_buf;
+	u32 * enable = pdata_buf;
 
 	lbs_deb_enter(LBS_DEB_CMD);
 
 	cmd->command = cpu_to_le16(cmd_802_11_enable_rsn);
 	cmd->size = cpu_to_le16(sizeof(*penableRSN) + S_DS_GEN);
 	penableRSN->action = cpu_to_le16(cmd_action);
-	if (assoc_req->secinfo.WPAenabled || assoc_req->secinfo.WPA2enabled) {
-		penableRSN->enable = cpu_to_le16(cmd_enable_rsn);
-	} else {
-		penableRSN->enable = cpu_to_le16(cmd_disable_rsn);
+
+	if (cmd_action == cmd_act_set) {
+		if (*enable)
+			penableRSN->enable = cpu_to_le16(cmd_enable_rsn);
+		else
+			penableRSN->enable = cpu_to_le16(cmd_enable_rsn);
 	}
 
 	lbs_deb_leave(LBS_DEB_CMD);
diff --git a/drivers/net/wireless/libertas/cmdresp.c b/drivers/net/wireless/libertas/cmdresp.c
index 0c3b9a5..6ac0d47 100644
--- a/drivers/net/wireless/libertas/cmdresp.c
+++ b/drivers/net/wireless/libertas/cmdresp.c
@@ -537,6 +537,24 @@ static int wlan_ret_get_log(wlan_private * priv,
 	return 0;
 }
 
+static int libertas_ret_802_11_enable_rsn(wlan_private * priv,
+                                          struct cmd_ds_command *resp)
+{
+	struct cmd_ds_802_11_enable_rsn *enable_rsn = &resp->params.enbrsn;
+	wlan_adapter *adapter = priv->adapter;
+	u32 * pdata_buf = adapter->cur_cmd->pdata_buf;
+
+	lbs_deb_enter(LBS_DEB_CMD);
+
+	if (enable_rsn->action == cpu_to_le16(cmd_act_get)) {
+		if (pdata_buf)
+			*pdata_buf = (u32) le16_to_cpu(enable_rsn->enable);
+	}
+
+	lbs_deb_enter(LBS_DEB_CMD);
+	return 0;
+}
+
 static inline int handle_cmd_response(u16 respcmd,
 				      struct cmd_ds_command *resp,
 				      wlan_private *priv)
@@ -610,7 +628,10 @@ static inline int handle_cmd_response(u16 respcmd,
 	case cmd_ret_802_11_authenticate:
 	case cmd_ret_802_11_radio_control:
 	case cmd_ret_802_11_beacon_stop:
+		break;
+
 	case cmd_ret_802_11_enable_rsn:
+		ret = libertas_ret_802_11_enable_rsn(priv, resp);
 		break;
 
 	case cmd_ret_802_11_data_rate:
diff --git a/drivers/net/wireless/libertas/hostcmd.h b/drivers/net/wireless/libertas/hostcmd.h
index 3acf939..09b898f 100644
--- a/drivers/net/wireless/libertas/hostcmd.h
+++ b/drivers/net/wireless/libertas/hostcmd.h
@@ -503,7 +503,7 @@ struct cmd_ds_802_11_ad_hoc_join {
 struct cmd_ds_802_11_enable_rsn {
 	__le16 action;
 	__le16 enable;
-};
+} __attribute__ ((packed));
 
 struct MrvlIEtype_keyParamSet {
 	/* type ID */
diff --git a/drivers/net/wireless/libertas/ioctl.c b/drivers/net/wireless/libertas/ioctl.c
deleted file mode 100644
index f410815..0000000
--- a/drivers/net/wireless/libertas/ioctl.c
+++ /dev/null
@@ -1,1081 +0,0 @@
-/**
-  * This file contains ioctl functions
-  */
-
-#include <linux/ctype.h>
-#include <linux/delay.h>
-#include <linux/if.h>
-#include <linux/if_arp.h>
-#include <linux/wireless.h>
-
-#include <net/iw_handler.h>
-#include <net/ieee80211.h>
-
-#include "host.h"
-#include "radiotap.h"
-#include "decl.h"
-#include "defs.h"
-#include "dev.h"
-#include "join.h"
-#include "wext.h"
-
-#define MAX_SCAN_CELL_SIZE      (IW_EV_ADDR_LEN + \
-				IW_ESSID_MAX_SIZE + \
-				IW_EV_UINT_LEN + IW_EV_FREQ_LEN + \
-				IW_EV_QUAL_LEN + IW_ESSID_MAX_SIZE + \
-				IW_EV_PARAM_LEN + 40)	/* 40 for WPAIE */
-
-#define WAIT_FOR_SCAN_RRESULT_MAX_TIME (10 * HZ)
-
-static int wlan_set_region(wlan_private * priv, u16 region_code)
-{
-	int i;
-	int ret = 0;
-
-	for (i = 0; i < MRVDRV_MAX_REGION_CODE; i++) {
-		// use the region code to search for the index
-		if (region_code == libertas_region_code_to_index[i]) {
-			priv->adapter->regiontableindex = (u16) i;
-			priv->adapter->regioncode = region_code;
-			break;
-		}
-	}
-
-	// if it's unidentified region code
-	if (i >= MRVDRV_MAX_REGION_CODE) {
-		lbs_deb_ioctl("region Code not identified\n");
-		ret = -1;
-		goto done;
-	}
-
-	if (libertas_set_regiontable(priv, priv->adapter->regioncode, 0)) {
-		ret = -EINVAL;
-	}
-
-done:
-	lbs_deb_leave_args(LBS_DEB_IOCTL, "ret %d", ret);
-	return ret;
-}
-
-static inline int hex2int(char c)
-{
-	if (c >= '0' && c <= '9')
-		return (c - '0');
-	if (c >= 'a' && c <= 'f')
-		return (c - 'a' + 10);
-	if (c >= 'A' && c <= 'F')
-		return (c - 'A' + 10);
-	return -1;
-}
-
-/* Convert a string representation of a MAC address ("xx:xx:xx:xx:xx:xx")
-   into binary format (6 bytes).
-
-   This function expects that each byte is represented with 2 characters
-   (e.g., 11:2:11:11:11:11 is invalid)
-
- */
-static char *eth_str2addr(char *ethstr, u8 * addr)
-{
-	int i, val, val2;
-	char *pos = ethstr;
-
-	/* get rid of initial blanks */
-	while (*pos == ' ' || *pos == '\t')
-		++pos;
-
-	for (i = 0; i < 6; i++) {
-		val = hex2int(*pos++);
-		if (val < 0)
-			return NULL;
-		val2 = hex2int(*pos++);
-		if (val2 < 0)
-			return NULL;
-		addr[i] = (val * 16 + val2) & 0xff;
-
-		if (i < 5 && *pos++ != ':')
-			return NULL;
-	}
-	return pos;
-}
-
-/* this writes xx:xx:xx:xx:xx:xx into ethstr
-   (ethstr must have space for 18 chars) */
-static int eth_addr2str(u8 * addr, char *ethstr)
-{
-	int i;
-	char *pos = ethstr;
-
-	for (i = 0; i < 6; i++) {
-		sprintf(pos, "%02x", addr[i] & 0xff);
-		pos += 2;
-		if (i < 5)
-			*pos++ = ':';
-	}
-	return 17;
-}
-
-/**
- *  @brief          Add an entry to the BT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_bt_add_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char ethaddrs_str[18];
-	char *pos;
-	u8 ethaddr[ETH_ALEN];
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(ethaddrs_str, wrq->u.data.pointer,
-			   sizeof(ethaddrs_str)))
-		return -EFAULT;
-
-	if ((pos = eth_str2addr(ethaddrs_str, ethaddr)) == NULL) {
-		lbs_pr_info("BT_ADD: Invalid MAC address\n");
-		return -EINVAL;
-	}
-
-	lbs_deb_ioctl("BT: adding %s\n", ethaddrs_str);
-	ret = libertas_prepare_and_send_command(priv, cmd_bt_access,
-				      cmd_act_bt_access_add,
-				      cmd_option_waitforrsp, 0, ethaddr);
-	lbs_deb_leave_args(LBS_DEB_IOCTL, "ret %d", ret);
-	return ret;
-}
-
-/**
- *  @brief          Delete an entry from the BT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_bt_del_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char ethaddrs_str[18];
-	u8 ethaddr[ETH_ALEN];
-	char *pos;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(ethaddrs_str, wrq->u.data.pointer,
-			   sizeof(ethaddrs_str)))
-		return -EFAULT;
-
-	if ((pos = eth_str2addr(ethaddrs_str, ethaddr)) == NULL) {
-		lbs_pr_info("Invalid MAC address\n");
-		return -EINVAL;
-	}
-
-	lbs_deb_ioctl("BT: deleting %s\n", ethaddrs_str);
-
-	return (libertas_prepare_and_send_command(priv,
-				      cmd_bt_access,
-				      cmd_act_bt_access_del,
-				      cmd_option_waitforrsp, 0, ethaddr));
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Reset all entries from the BT table
- *  @param priv     A pointer to wlan_private structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_bt_reset_ioctl(wlan_private * priv)
-{
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	lbs_pr_alert( "BT: resetting\n");
-
-	return (libertas_prepare_and_send_command(priv,
-				      cmd_bt_access,
-				      cmd_act_bt_access_reset,
-				      cmd_option_waitforrsp, 0, NULL));
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          List an entry from the BT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_bt_list_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	int pos;
-	char *addr1;
-	struct iwreq *wrq = (struct iwreq *)req;
-	/* used to pass id and store the bt entry returned by the FW */
-	union {
-		u32 id;
-		char addr1addr2[2 * ETH_ALEN];
-	} param;
-	static char outstr[64];
-	char *pbuf = outstr;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(outstr, wrq->u.data.pointer, sizeof(outstr))) {
-		lbs_deb_ioctl("Copy from user failed\n");
-		return -1;
-	}
-	param.id = simple_strtoul(outstr, NULL, 10);
-	pos = sprintf(pbuf, "%d: ", param.id);
-	pbuf += pos;
-
-	ret = libertas_prepare_and_send_command(priv, cmd_bt_access,
-				    cmd_act_bt_access_list,
-				    cmd_option_waitforrsp, 0,
-				    (char *)&param);
-
-	if (ret == 0) {
-		addr1 = param.addr1addr2;
-
-		pos = sprintf(pbuf, "BT includes node ");
-		pbuf += pos;
-		pos = eth_addr2str(addr1, pbuf);
-		pbuf += pos;
-	} else {
-		sprintf(pbuf, "(null)");
-		pbuf += pos;
-	}
-
-	wrq->u.data.length = strlen(outstr);
-	if (copy_to_user(wrq->u.data.pointer, (char *)outstr,
-			 wrq->u.data.length)) {
-		lbs_deb_ioctl("BT_LIST: Copy to user failed!\n");
-		return -EFAULT;
-	}
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0 ;
-}
-
-/**
- *  @brief          Sets inverted state of blacklist (non-zero if inverted)
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_bt_set_invert_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	int ret;
-	struct iwreq *wrq = (struct iwreq *)req;
-	union {
-		u32 id;
-		char addr1addr2[2 * ETH_ALEN];
-	} param;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	param.id = SUBCMD_DATA(wrq) ;
-	ret = libertas_prepare_and_send_command(priv, cmd_bt_access,
-				    cmd_act_bt_access_set_invert,
-				    cmd_option_waitforrsp, 0,
-				    (char *)&param);
-	if (ret != 0)
-		return -EFAULT;
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Gets inverted state of blacklist (non-zero if inverted)
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_bt_get_invert_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	int ret;
-	union {
-		u32 id;
-		char addr1addr2[2 * ETH_ALEN];
-	} param;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	ret = libertas_prepare_and_send_command(priv, cmd_bt_access,
-				    cmd_act_bt_access_get_invert,
-				    cmd_option_waitforrsp, 0,
-				    (char *)&param);
-
-	if (ret == 0)
-		wrq->u.param.value = le32_to_cpu(param.id);
-	else
-		return -EFAULT;
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Find the next parameter in an input string
- *  @param ptr      A pointer to the input parameter string
- *  @return         A pointer to the next parameter, or 0 if no parameters left.
- */
-static char * next_param(char * ptr)
-{
-	if (!ptr) return NULL;
-	while (*ptr == ' ' || *ptr == '\t') ++ptr;
-	return (*ptr == '\0') ? NULL : ptr;
-}
-
-/**
- *  @brief          Add an entry to the FWT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_add_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char in_str[128];
-	static struct cmd_ds_fwt_access fwt_access;
-	char *ptr;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(in_str, wrq->u.data.pointer, sizeof(in_str)))
-		return -EFAULT;
-
-	if ((ptr = eth_str2addr(in_str, fwt_access.da)) == NULL) {
-		lbs_pr_alert( "FWT_ADD: Invalid MAC address 1\n");
-		return -EINVAL;
-	}
-
-	if ((ptr = eth_str2addr(ptr, fwt_access.ra)) == NULL) {
-		lbs_pr_alert( "FWT_ADD: Invalid MAC address 2\n");
-		return -EINVAL;
-	}
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.metric =
-			cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-	else
-		fwt_access.metric = cpu_to_le32(FWT_DEFAULT_METRIC);
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.dir = (u8)simple_strtoul(ptr, &ptr, 10);
-	else
-		fwt_access.dir = FWT_DEFAULT_DIR;
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.rate = (u8) simple_strtoul(ptr, &ptr, 10);
-	else
-		fwt_access.rate = FWT_DEFAULT_RATE;
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.ssn =
-			cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-	else
-		fwt_access.ssn = cpu_to_le32(FWT_DEFAULT_SSN);
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.dsn =
-			cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-	else
-		fwt_access.dsn = cpu_to_le32(FWT_DEFAULT_DSN);
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.hopcount = simple_strtoul(ptr, &ptr, 10);
-	else
-		fwt_access.hopcount = FWT_DEFAULT_HOPCOUNT;
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.ttl = simple_strtoul(ptr, &ptr, 10);
-	else
-		fwt_access.ttl = FWT_DEFAULT_TTL;
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.expiration =
-			cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-	else
-		fwt_access.expiration = cpu_to_le32(FWT_DEFAULT_EXPIRATION);
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.sleepmode = (u8)simple_strtoul(ptr, &ptr, 10);
-	else
-		fwt_access.sleepmode = FWT_DEFAULT_SLEEPMODE;
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.snr =
-			cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-	else
-		fwt_access.snr = cpu_to_le32(FWT_DEFAULT_SNR);
-
-#ifdef DEBUG
-	{
-		char ethaddr1_str[18], ethaddr2_str[18];
-		eth_addr2str(fwt_access.da, ethaddr1_str);
-		eth_addr2str(fwt_access.ra, ethaddr2_str);
-		lbs_deb_ioctl("FWT_ADD: adding (da:%s,%i,ra:%s)\n", ethaddr1_str,
-		       fwt_access.dir, ethaddr2_str);
-		lbs_deb_ioctl("FWT_ADD: ssn:%u dsn:%u met:%u hop:%u ttl:%u exp:%u slp:%u snr:%u\n",
-		       fwt_access.ssn, fwt_access.dsn, fwt_access.metric,
-		       fwt_access.hopcount, fwt_access.ttl, fwt_access.expiration,
-		       fwt_access.sleepmode, fwt_access.snr);
-	}
-#endif
-
-	ret = libertas_prepare_and_send_command(priv, cmd_fwt_access,
-						cmd_act_fwt_access_add,
-						cmd_option_waitforrsp, 0,
-						(void *)&fwt_access);
-
-	lbs_deb_leave_args(LBS_DEB_IOCTL, "ret %d", ret);
-	return ret;
-}
-
-/**
- *  @brief          Delete an entry from the FWT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_del_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char in_str[64];
-	static struct cmd_ds_fwt_access fwt_access;
-	char *ptr;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(in_str, wrq->u.data.pointer, sizeof(in_str)))
-		return -EFAULT;
-
-	if ((ptr = eth_str2addr(in_str, fwt_access.da)) == NULL) {
-		lbs_pr_alert( "FWT_DEL: Invalid MAC address 1\n");
-		return -EINVAL;
-	}
-
-	if ((ptr = eth_str2addr(ptr, fwt_access.ra)) == NULL) {
-		lbs_pr_alert( "FWT_DEL: Invalid MAC address 2\n");
-		return -EINVAL;
-	}
-
-	if ((ptr = next_param(ptr)))
-		fwt_access.dir = (u8)simple_strtoul(ptr, &ptr, 10);
-	else
-		fwt_access.dir = FWT_DEFAULT_DIR;
-
-#ifdef DEBUG
-	{
-		char ethaddr1_str[18], ethaddr2_str[18];
-		lbs_deb_ioctl("FWT_DEL: line is %s\n", in_str);
-		eth_addr2str(fwt_access.da, ethaddr1_str);
-		eth_addr2str(fwt_access.ra, ethaddr2_str);
-		lbs_deb_ioctl("FWT_DEL: removing (da:%s,ra:%s,dir:%d)\n", ethaddr1_str,
-		       ethaddr2_str, fwt_access.dir);
-	}
-#endif
-
-	ret = libertas_prepare_and_send_command(priv,
-						cmd_fwt_access,
-						cmd_act_fwt_access_del,
-						cmd_option_waitforrsp, 0,
-						(void *)&fwt_access);
-	lbs_deb_leave_args(LBS_DEB_IOCTL, "ret %d", ret);
-	return ret;
-}
-
-
-/**
- *  @brief             Print route parameters
- *  @param fwt_access  struct cmd_ds_fwt_access with route info
- *  @param buf         destination buffer for route info
- */
-static void print_route(struct cmd_ds_fwt_access fwt_access, char *buf)
-{
-	buf += sprintf(buf, " ");
-	buf += eth_addr2str(fwt_access.da, buf);
-	buf += sprintf(buf, " ");
-	buf += eth_addr2str(fwt_access.ra, buf);
-	buf += sprintf(buf, " %u", fwt_access.valid);
-	buf += sprintf(buf, " %u", le32_to_cpu(fwt_access.metric));
-	buf += sprintf(buf, " %u", fwt_access.dir);
-	buf += sprintf(buf, " %u", fwt_access.rate);
-	buf += sprintf(buf, " %u", le32_to_cpu(fwt_access.ssn));
-	buf += sprintf(buf, " %u", le32_to_cpu(fwt_access.dsn));
-	buf += sprintf(buf, " %u", fwt_access.hopcount);
-	buf += sprintf(buf, " %u", fwt_access.ttl);
-	buf += sprintf(buf, " %u", le32_to_cpu(fwt_access.expiration));
-	buf += sprintf(buf, " %u", fwt_access.sleepmode);
-	buf += sprintf(buf, " %u ", le32_to_cpu(fwt_access.snr));
-	buf += eth_addr2str(fwt_access.prec, buf);
-}
-
-/**
- *  @brief          Lookup an entry in the FWT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_lookup_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char in_str[64];
-	char *ptr;
-	static struct cmd_ds_fwt_access fwt_access;
-	static char out_str[128];
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(in_str, wrq->u.data.pointer, sizeof(in_str)))
-		return -EFAULT;
-
-	if ((ptr = eth_str2addr(in_str, fwt_access.da)) == NULL) {
-		lbs_pr_alert( "FWT_LOOKUP: Invalid MAC address\n");
-		return -EINVAL;
-	}
-
-#ifdef DEBUG
-	{
-		char ethaddr1_str[18];
-		lbs_deb_ioctl("FWT_LOOKUP: line is %s\n", in_str);
-		eth_addr2str(fwt_access.da, ethaddr1_str);
-		lbs_deb_ioctl("FWT_LOOKUP: looking for (da:%s)\n", ethaddr1_str);
-	}
-#endif
-
-	ret = libertas_prepare_and_send_command(priv,
-						cmd_fwt_access,
-						cmd_act_fwt_access_lookup,
-						cmd_option_waitforrsp, 0,
-						(void *)&fwt_access);
-
-	if (ret == 0)
-		print_route(fwt_access, out_str);
-	else
-		sprintf(out_str, "(null)");
-
-	wrq->u.data.length = strlen(out_str);
-	if (copy_to_user(wrq->u.data.pointer, (char *)out_str,
-			 wrq->u.data.length)) {
-		lbs_deb_ioctl("FWT_LOOKUP: Copy to user failed!\n");
-		return -EFAULT;
-	}
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Reset all entries from the FWT table
- *  @param priv     A pointer to wlan_private structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_reset_ioctl(wlan_private * priv)
-{
-	lbs_deb_ioctl("FWT: resetting\n");
-
-	return (libertas_prepare_and_send_command(priv,
-				      cmd_fwt_access,
-				      cmd_act_fwt_access_reset,
-				      cmd_option_waitforrsp, 0, NULL));
-}
-
-/**
- *  @brief          List an entry from the FWT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_list_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char in_str[8];
-	static struct cmd_ds_fwt_access fwt_access;
-	char *ptr = in_str;
-	static char out_str[128];
-	char *pbuf = out_str;
-	int ret = 0;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(in_str, wrq->u.data.pointer, sizeof(in_str))) {
-		ret = -EFAULT;
-		goto out;
-	}
-
-	fwt_access.id = cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-
-#ifdef DEBUG
-	{
-		lbs_deb_ioctl("FWT_LIST: line is %s\n", in_str);
-		lbs_deb_ioctl("FWT_LIST: listing id:%i\n", le32_to_cpu(fwt_access.id));
-	}
-#endif
-
-	ret = libertas_prepare_and_send_command(priv, cmd_fwt_access,
-				    cmd_act_fwt_access_list,
-				    cmd_option_waitforrsp, 0, (void *)&fwt_access);
-
-	if (ret == 0)
-		print_route(fwt_access, pbuf);
-	else
-		pbuf += sprintf(pbuf, " (null)");
-
-	wrq->u.data.length = strlen(out_str);
-	if (copy_to_user(wrq->u.data.pointer, (char *)out_str,
-			 wrq->u.data.length)) {
-		lbs_deb_ioctl("FWT_LIST: Copy to user failed!\n");
-		ret = -EFAULT;
-		goto out;
-	}
-
-	ret = 0;
-
-out:
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return ret;
-}
-
-/**
- *  @brief          List an entry from the FRT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_list_route_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char in_str[64];
-	static struct cmd_ds_fwt_access fwt_access;
-	char *ptr = in_str;
-	static char out_str[128];
-	char *pbuf = out_str;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(in_str, wrq->u.data.pointer, sizeof(in_str)))
-		return -EFAULT;
-
-	fwt_access.id = cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-
-#ifdef DEBUG
-	{
-		lbs_deb_ioctl("FWT_LIST_ROUTE: line is %s\n", in_str);
-		lbs_deb_ioctl("FWT_LIST_ROUTE: listing id:%i\n", le32_to_cpu(fwt_access.id));
-	}
-#endif
-
-	ret = libertas_prepare_and_send_command(priv, cmd_fwt_access,
-				    cmd_act_fwt_access_list_route,
-				    cmd_option_waitforrsp, 0, (void *)&fwt_access);
-
-	if (ret == 0) {
-		print_route(fwt_access, pbuf);
-	} else
-		pbuf += sprintf(pbuf, " (null)");
-
-	wrq->u.data.length = strlen(out_str);
-	if (copy_to_user(wrq->u.data.pointer, (char *)out_str,
-			 wrq->u.data.length)) {
-		lbs_deb_ioctl("FWT_LIST_ROUTE: Copy to user failed!\n");
-		return -EFAULT;
-	}
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          List an entry from the FNT table
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_list_neighbor_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	char in_str[8];
-	static struct cmd_ds_fwt_access fwt_access;
-	char *ptr = in_str;
-	static char out_str[128];
-	char *pbuf = out_str;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if (copy_from_user(in_str, wrq->u.data.pointer, sizeof(in_str)))
-		return -EFAULT;
-
-	memset(&fwt_access, 0, sizeof(fwt_access));
-	fwt_access.id = cpu_to_le32(simple_strtoul(ptr, &ptr, 10));
-
-#ifdef DEBUG
-	{
-		lbs_deb_ioctl("FWT_LIST_NEIGHBOR: line is %s\n", in_str);
-		lbs_deb_ioctl("FWT_LIST_NEIGHBOR: listing id:%i\n", le32_to_cpu(fwt_access.id));
-	}
-#endif
-
-	ret = libertas_prepare_and_send_command(priv, cmd_fwt_access,
-				    cmd_act_fwt_access_list_neighbor,
-				    cmd_option_waitforrsp, 0,
-				    (void *)&fwt_access);
-
-	if (ret == 0) {
-		pbuf += sprintf(pbuf, " ra ");
-		pbuf += eth_addr2str(fwt_access.ra, pbuf);
-		pbuf += sprintf(pbuf, "  slp %u", fwt_access.sleepmode);
-		pbuf += sprintf(pbuf, "  snr %u", le32_to_cpu(fwt_access.snr));
-		pbuf += sprintf(pbuf, "  ref %u", le32_to_cpu(fwt_access.references));
-	} else
-		pbuf += sprintf(pbuf, " (null)");
-
-	wrq->u.data.length = strlen(out_str);
-	if (copy_to_user(wrq->u.data.pointer, (char *)out_str,
-			 wrq->u.data.length)) {
-		lbs_deb_ioctl("FWT_LIST_NEIGHBOR: Copy to user failed!\n");
-		return -EFAULT;
-	}
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Cleans up the route (FRT) and neighbor (FNT) tables
- *                  (Garbage Collection)
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_cleanup_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	static struct cmd_ds_fwt_access fwt_access;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	lbs_deb_ioctl("FWT: cleaning up\n");
-
-	memset(&fwt_access, 0, sizeof(fwt_access));
-
-	ret = libertas_prepare_and_send_command(priv, cmd_fwt_access,
-				    cmd_act_fwt_access_cleanup,
-				    cmd_option_waitforrsp, 0,
-				    (void *)&fwt_access);
-
-	if (ret == 0)
-		wrq->u.param.value = le32_to_cpu(fwt_access.references);
-	else
-		return -EFAULT;
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Gets firmware internal time (debug purposes)
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_fwt_time_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	static struct cmd_ds_fwt_access fwt_access;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	lbs_deb_ioctl("FWT: getting time\n");
-
-	memset(&fwt_access, 0, sizeof(fwt_access));
-
-	ret = libertas_prepare_and_send_command(priv, cmd_fwt_access,
-				    cmd_act_fwt_access_time,
-				    cmd_option_waitforrsp, 0,
-				    (void *)&fwt_access);
-
-	if (ret == 0)
-		wrq->u.param.value = le32_to_cpu(fwt_access.references);
-	else
-		return -EFAULT;
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Gets mesh ttl from firmware
- *  @param priv     A pointer to wlan_private structure
- *  @param req      A pointer to ifreq structure
- *  @return         0 --success, otherwise fail
- */
-static int wlan_mesh_get_ttl_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	struct cmd_ds_mesh_access mesh_access;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	memset(&mesh_access, 0, sizeof(mesh_access));
-
-	ret = libertas_prepare_and_send_command(priv, cmd_mesh_access,
-				    cmd_act_mesh_get_ttl,
-				    cmd_option_waitforrsp, 0,
-				    (void *)&mesh_access);
-
-	if (ret == 0)
-		wrq->u.param.value = le32_to_cpu(mesh_access.data[0]);
-	else
-		return -EFAULT;
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return 0;
-}
-
-/**
- *  @brief          Gets mesh ttl from firmware
- *  @param priv     A pointer to wlan_private structure
- *  @param ttl      New ttl value
- *  @return         0 --success, otherwise fail
- */
-static int wlan_mesh_set_ttl_ioctl(wlan_private * priv, int ttl)
-{
-	struct cmd_ds_mesh_access mesh_access;
-	int ret;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	if( (ttl > 0xff) || (ttl < 0) )
-		return -EINVAL;
-
-	memset(&mesh_access, 0, sizeof(mesh_access));
-	mesh_access.data[0] = cpu_to_le32(ttl);
-
-	ret = libertas_prepare_and_send_command(priv, cmd_mesh_access,
-						cmd_act_mesh_set_ttl,
-						cmd_option_waitforrsp, 0,
-						(void *)&mesh_access);
-
-	if (ret != 0)
-		ret = -EFAULT;
-
-	lbs_deb_leave(LBS_DEB_IOCTL);
-	return ret;
-}
-
-/**
- *  @brief ioctl function - entry point
- *
- *  @param dev		A pointer to net_device structure
- *  @param req	   	A pointer to ifreq structure
- *  @param cmd 		command
- *  @return 	   	0--success, otherwise fail
- */
-int libertas_do_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
-{
-	int subcmd = 0;
-	int idata = 0;
-	int *pdata;
-	int ret = 0;
-	wlan_private *priv = dev->priv;
-	wlan_adapter *adapter = priv->adapter;
-	struct iwreq *wrq = (struct iwreq *)req;
-
-	lbs_deb_enter(LBS_DEB_IOCTL);
-
-	lbs_deb_ioctl("libertas_do_ioctl: ioctl cmd = 0x%x\n", cmd);
-	switch (cmd) {
-	case WLAN_SETNONE_GETNONE:	/* set WPA mode on/off ioctl #20 */
-		switch (wrq->u.data.flags) {
-		case WLAN_SUBCMD_BT_RESET:	/* bt_reset */
-			wlan_bt_reset_ioctl(priv);
-			break;
-		case WLAN_SUBCMD_FWT_RESET:	/* fwt_reset */
-			wlan_fwt_reset_ioctl(priv);
-			break;
-		}		/* End of switch */
-		break;
-
-	case WLAN_SETONEINT_GETNONE:
-		/* The first 4 bytes of req->ifr_data is sub-ioctl number
-		 * after 4 bytes sits the payload.
-		 */
-		subcmd = wrq->u.data.flags;
-		if (!subcmd)
-			subcmd = (int)wrq->u.param.value;
-
-		switch (subcmd) {
-		case WLANSETREGION:
-			idata = SUBCMD_DATA(wrq);
-			ret = wlan_set_region(priv, (u16) idata);
-			break;
-		case WLAN_SUBCMD_MESH_SET_TTL:
-			idata = SUBCMD_DATA(wrq);
-			ret = wlan_mesh_set_ttl_ioctl(priv, idata);
-			break;
-
-		case WLAN_SUBCMD_BT_SET_INVERT:
-			ret = wlan_bt_set_invert_ioctl(priv, req);
-			break ;
-
-		default:
-			ret = -EOPNOTSUPP;
-			break;
-		}
-
-		break;
-
-	case WLAN_SET128CHAR_GET128CHAR:
-		switch ((int)wrq->u.data.flags) {
-		case WLAN_SUBCMD_BT_ADD:
-			ret = wlan_bt_add_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_BT_DEL:
-			ret = wlan_bt_del_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_BT_LIST:
-			ret = wlan_bt_list_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_FWT_ADD:
-			ret = wlan_fwt_add_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_FWT_DEL:
-			ret = wlan_fwt_del_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_FWT_LOOKUP:
-			ret = wlan_fwt_lookup_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_FWT_LIST_NEIGHBOR:
-			ret = wlan_fwt_list_neighbor_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_FWT_LIST:
-			ret = wlan_fwt_list_ioctl(priv, req);
-			break;
-		case WLAN_SUBCMD_FWT_LIST_ROUTE:
-			ret = wlan_fwt_list_route_ioctl(priv, req);
-			break;
-		}
-		break;
-
-	case WLAN_SETNONE_GETONEINT:
-		switch (wrq->u.param.value) {
-		case WLANGETREGION:
-			pdata = (int *)wrq->u.name;
-			*pdata = (int)adapter->regioncode;
-			break;
-		case WLAN_SUBCMD_FWT_CLEANUP:	/* fwt_cleanup */
-			ret = wlan_fwt_cleanup_ioctl(priv, req);
-			break;
-
-		case WLAN_SUBCMD_FWT_TIME:	/* fwt_time */
-			ret = wlan_fwt_time_ioctl(priv, req);
-			break;
-
-		case WLAN_SUBCMD_MESH_GET_TTL:
-			ret = wlan_mesh_get_ttl_ioctl(priv, req);
-			break;
-
-		case WLAN_SUBCMD_BT_GET_INVERT:
-			ret = wlan_bt_get_invert_ioctl(priv, req);
-			break ;
-
-		default:
-			ret = -EOPNOTSUPP;
-
-		}
-
-		break;
-
-	case WLAN_SET_GET_SIXTEEN_INT:
-		switch ((int)wrq->u.data.flags) {
-		case WLAN_LED_GPIO_CTRL:
-			{
-				int i;
-				int data[16];
-
-				struct cmd_ds_802_11_led_ctrl ctrl;
-				struct mrvlietypes_ledgpio *gpio =
-				    (struct mrvlietypes_ledgpio *) ctrl.data;
-
-				memset(&ctrl, 0, sizeof(ctrl));
-				if (wrq->u.data.length > MAX_LEDS * 2)
-					return -ENOTSUPP;
-				if ((wrq->u.data.length % 2) != 0)
-					return -ENOTSUPP;
-				if (wrq->u.data.length == 0) {
-					ctrl.action =
-					    cpu_to_le16
-					    (cmd_act_get);
-				} else {
-					if (copy_from_user
-					    (data, wrq->u.data.pointer,
-					     sizeof(int) *
-					     wrq->u.data.length)) {
-						lbs_deb_ioctl(
-						       "Copy from user failed\n");
-						return -EFAULT;
-					}
-
-					ctrl.action =
-					    cpu_to_le16
-					    (cmd_act_set);
-					ctrl.numled = cpu_to_le16(0);
-					gpio->header.type =
-					    cpu_to_le16(TLV_TYPE_LED_GPIO);
-					gpio->header.len = wrq->u.data.length;
-					for (i = 0; i < wrq->u.data.length;
-					     i += 2) {
-						gpio->ledpin[i / 2].led =
-						    data[i];
-						gpio->ledpin[i / 2].pin =
-						    data[i + 1];
-					}
-				}
-				ret =
-				    libertas_prepare_and_send_command(priv,
-							  cmd_802_11_led_gpio_ctrl,
-							  0,
-							  cmd_option_waitforrsp,
-							  0, (void *)&ctrl);
-				for (i = 0; i < gpio->header.len; i += 2) {
-					data[i] = gpio->ledpin[i / 2].led;
-					data[i + 1] = gpio->ledpin[i / 2].pin;
-				}
-				if (copy_to_user(wrq->u.data.pointer, data,
-						 sizeof(int) *
-						 gpio->header.len)) {
-					lbs_deb_ioctl("Copy to user failed\n");
-					return -EFAULT;
-				}
-
-				wrq->u.data.length = gpio->header.len;
-			}
-			break;
-		}
-		break;
-
-	default:
-		ret = -EINVAL;
-		break;
-	}
-
-	lbs_deb_leave_args(LBS_DEB_IOCTL, "ret %d", ret);
-	return ret;
-}
-
-
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 623ab4b..4a59306 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -181,7 +181,8 @@ u16 libertas_region_code_to_index[MRVDRV_MAX_REGION_CODE] =
  * @brief Get function for sysfs attribute anycast_mask
  */
 static ssize_t libertas_anycast_get(struct device * dev,
-		struct device_attribute *attr, char * buf) {
+		struct device_attribute *attr, char * buf)
+{
 	struct cmd_ds_mesh_access mesh_access;
 
 	memset(&mesh_access, 0, sizeof(mesh_access));
@@ -197,7 +198,8 @@ static ssize_t libertas_anycast_get(struct device * dev,
  * @brief Set function for sysfs attribute anycast_mask
  */
 static ssize_t libertas_anycast_set(struct device * dev,
-		struct device_attribute *attr, const char * buf, size_t count) {
+		struct device_attribute *attr, const char * buf, size_t count)
+{
 	struct cmd_ds_mesh_access mesh_access;
 	uint32_t datum;
 
@@ -799,7 +801,6 @@ wlan_private *libertas_add_card(void *card, struct device *dmdev)
 	dev->open = wlan_open;
 	dev->hard_start_xmit = wlan_pre_start_xmit;
 	dev->stop = wlan_close;
-	dev->do_ioctl = libertas_do_ioctl;
 	dev->set_mac_address = wlan_set_mac_address;
 	dev->tx_timeout = wlan_tx_timeout;
 	dev->get_stats = wlan_get_stats;
@@ -918,7 +919,6 @@ int libertas_add_mesh(wlan_private *priv, struct device *dev)
 	mesh_dev->open = mesh_open;
 	mesh_dev->hard_start_xmit = mesh_pre_start_xmit;
 	mesh_dev->stop = mesh_close;
-	mesh_dev->do_ioctl = libertas_do_ioctl;
 	mesh_dev->get_stats = wlan_get_stats;
 	mesh_dev->set_mac_address = wlan_set_mac_address;
 	mesh_dev->ethtool_ops = &libertas_ethtool_ops;
diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireless/libertas/scan.c
index 606af50..c3043dc 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -215,38 +215,6 @@ done:
 }
 
 /**
- *  @brief Post process the scan table after a new scan command has completed
- *
- *  Inspect each entry of the scan table and try to find an entry that
- *    matches our current associated/joined network from the scan.  If
- *    one is found, update the stored copy of the bssdescriptor for our
- *    current network.
- *
- *  Debug dump the current scan table contents if compiled accordingly.
- *
- *  @param priv   A pointer to wlan_private structure
- *
- *  @return       void
- */
-static void wlan_scan_process_results(wlan_private * priv)
-{
-	wlan_adapter *adapter = priv->adapter;
-	struct bss_descriptor * iter_bss;
-	int i = 0;
-
-	if (adapter->connect_status == libertas_connected)
-		return;
-
-	mutex_lock(&adapter->lock);
-	list_for_each_entry (iter_bss, &adapter->network_list, list) {
-		lbs_deb_scan("Scan:(%02d) " MAC_FMT ", RSSI[%03d], SSID[%s]\n",
-		       i++, MAC_ARG(iter_bss->bssid), (s32) iter_bss->rssi,
-		       escape_essid(iter_bss->ssid, iter_bss->ssid_len));
-	}
-	mutex_unlock(&adapter->lock);
-}
-
-/**
  *  @brief Create a channel list for the driver to scan based on region info
  *
  *  Use the driver region/band information to construct a comprehensive list
@@ -791,6 +759,10 @@ int wlan_scan_networks(wlan_private * priv,
 	u8 scancurrentchanonly;
 	int maxchanperscan;
 	int ret;
+#ifdef CONFIG_LIBERTAS_DEBUG
+	struct bss_descriptor * iter_bss;
+	int i = 0;
+#endif
 
 	lbs_deb_enter(LBS_DEB_ASSOC);
 
@@ -832,11 +804,16 @@ int wlan_scan_networks(wlan_private * priv,
 				     puserscanin,
 				     full_scan);
 
-	/*  Process the resulting scan table:
-	 *    - Remove any bad ssids
-	 *    - Update our current BSS information from scan data
-	 */
-	wlan_scan_process_results(priv);
+#ifdef CONFIG_LIBERTAS_DEBUG
+	/* Dump the scan table */
+	mutex_lock(&adapter->lock);
+	list_for_each_entry (iter_bss, &adapter->network_list, list) {
+		lbs_deb_scan("Scan:(%02d) " MAC_FMT ", RSSI[%03d], SSID[%s]\n",
+		       i++, MAC_ARG(iter_bss->bssid), (s32) iter_bss->rssi,
+		       escape_essid(iter_bss->ssid, iter_bss->ssid_len));
+	}
+	mutex_unlock(&adapter->lock);
+#endif
 
 	if (priv->adapter->connect_status == libertas_connected) {
 		netif_carrier_on(priv->dev);
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index 8939251..f42b796 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -913,148 +913,6 @@ out:
 	return 0;
 }
 
-/*
- * iwpriv settable callbacks
- */
-
-static const iw_handler wlan_private_handler[] = {
-	NULL,			/* SIOCIWFIRSTPRIV */
-};
-
-static const struct iw_priv_args wlan_private_args[] = {
-	/*
-	 * { cmd, set_args, get_args, name }
-	 */
-	/* Using iwpriv sub-command feature */
-	{
-	 WLAN_SETONEINT_GETNONE,	/* IOCTL: 24 */
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 ""},
-	{
-	 WLANSETREGION,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "setregioncode"},
-	{
-	 WLAN_SUBCMD_MESH_SET_TTL,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "mesh_set_ttl"},
-	{
-	 WLAN_SETNONE_GETONEINT,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 ""},
-	{
-	 WLANGETREGION,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "getregioncode"},
-	{
-	 WLAN_SUBCMD_FWT_CLEANUP,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "fwt_cleanup"},
-	{
-	 WLAN_SUBCMD_FWT_TIME,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "fwt_time"},
-	{
-	 WLAN_SUBCMD_MESH_GET_TTL,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "mesh_get_ttl"},
-	{
-	 WLAN_SETNONE_GETNONE,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_NONE,
-	 ""},
-	{
-	 WLAN_SUBCMD_FWT_RESET,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_NONE,
-	 "fwt_reset"},
-	{
-	 WLAN_SUBCMD_BT_RESET,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_NONE,
-	 "bt_reset"},
-	{
-	 WLAN_SET128CHAR_GET128CHAR,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 ""},
-	/* BT Management */
-	{
-	 WLAN_SUBCMD_BT_ADD,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "bt_add"},
-	{
-	 WLAN_SUBCMD_BT_DEL,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "bt_del"},
-	{
-	 WLAN_SUBCMD_BT_LIST,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "bt_list"},
-	{
-	 WLAN_SUBCMD_BT_SET_INVERT,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "bt_set_invert"},
-	{
-	 WLAN_SUBCMD_BT_GET_INVERT,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "bt_get_invert"},
-	/* FWT Management */
-	{
-	 WLAN_SUBCMD_FWT_ADD,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "fwt_add"},
-	{
-	 WLAN_SUBCMD_FWT_DEL,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "fwt_del"},
-	{
-	 WLAN_SUBCMD_FWT_LOOKUP,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "fwt_lookup"},
-	{
-	 WLAN_SUBCMD_FWT_LIST_NEIGHBOR,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "fwt_list_neigh"},
-	{
-	 WLAN_SUBCMD_FWT_LIST,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "fwt_list"},
-	{
-	 WLAN_SUBCMD_FWT_LIST_ROUTE,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "fwt_list_route"},
-	{
-	 WLAN_SET_GET_SIXTEEN_INT,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 ""},
-	{
-	 WLAN_LED_GPIO_CTRL,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 "ledgpio"},
-};
-
 static struct iw_statistics *wlan_get_wireless_stats(struct net_device *dev)
 {
 	enum {
@@ -2444,22 +2302,12 @@ static const iw_handler mesh_wlan_handler[] = {
 };
 struct iw_handler_def libertas_handler_def = {
 	.num_standard	= sizeof(wlan_handler) / sizeof(iw_handler),
-	.num_private	= sizeof(wlan_private_handler) / sizeof(iw_handler),
-	.num_private_args = sizeof(wlan_private_args) /
-		sizeof(struct iw_priv_args),
 	.standard	= (iw_handler *) wlan_handler,
-	.private	= (iw_handler *) wlan_private_handler,
-	.private_args	= (struct iw_priv_args *)wlan_private_args,
 	.get_wireless_stats = wlan_get_wireless_stats,
 };
 
 struct iw_handler_def mesh_handler_def = {
 	.num_standard	= sizeof(mesh_wlan_handler) / sizeof(iw_handler),
-	.num_private	= sizeof(wlan_private_handler) / sizeof(iw_handler),
-	.num_private_args = sizeof(wlan_private_args) /
-		sizeof(struct iw_priv_args),
 	.standard	= (iw_handler *) mesh_wlan_handler,
-	.private	= (iw_handler *) wlan_private_handler,
-	.private_args	= (struct iw_priv_args *)wlan_private_args,
 	.get_wireless_stats = wlan_get_wireless_stats,
 };
diff --git a/drivers/net/wireless/libertas/wext.h b/drivers/net/wireless/libertas/wext.h
index d555056..3d5196c 100644
--- a/drivers/net/wireless/libertas/wext.h
+++ b/drivers/net/wireless/libertas/wext.h
@@ -7,45 +7,6 @@
 #define SUBCMD_OFFSET			4
 #define SUBCMD_DATA(x)			*((int *)(x->u.name + SUBCMD_OFFSET))
 
-/** PRIVATE CMD ID */
-#define	WLANIOCTL			SIOCIWFIRSTPRIV
-
-#define WLAN_SETNONE_GETNONE	        (WLANIOCTL + 8)
-#define WLAN_SUBCMD_BT_RESET			13
-#define WLAN_SUBCMD_FWT_RESET			14
-
-#define WLAN_SETNONE_GETONEINT		(WLANIOCTL + 15)
-#define WLANGETREGION				1
-
-#define WLAN_SUBCMD_FWT_CLEANUP			15
-#define WLAN_SUBCMD_FWT_TIME			16
-#define WLAN_SUBCMD_MESH_GET_TTL		17
-#define WLAN_SUBCMD_BT_GET_INVERT		18
-
-#define WLAN_SETONEINT_GETNONE		(WLANIOCTL + 24)
-#define WLANSETREGION				8
-#define WLAN_SUBCMD_MESH_SET_TTL		18
-#define WLAN_SUBCMD_BT_SET_INVERT		19
-
-#define WLAN_SET128CHAR_GET128CHAR	(WLANIOCTL + 25)
-#define WLAN_SUBCMD_BT_ADD			18
-#define WLAN_SUBCMD_BT_DEL   			19
-#define WLAN_SUBCMD_BT_LIST			20
-#define WLAN_SUBCMD_FWT_ADD			21
-#define WLAN_SUBCMD_FWT_DEL   			22
-#define WLAN_SUBCMD_FWT_LOOKUP			23
-#define WLAN_SUBCMD_FWT_LIST_NEIGHBOR		24
-#define WLAN_SUBCMD_FWT_LIST			25
-#define WLAN_SUBCMD_FWT_LIST_ROUTE		26
-
-#define WLAN_SET_GET_SIXTEEN_INT       (WLANIOCTL + 29)
-#define WLAN_LED_GPIO_CTRL			5
-
-#define WLAN_LINKMODE_802_3			0
-#define WLAN_LINKMODE_802_11			2
-#define WLAN_RADIOMODE_NONE    			0
-#define WLAN_RADIOMODE_RADIOTAP			2
-
 /** wlan_ioctl_regrdwr */
 struct wlan_ioctl_regrdwr {
 	/** Which register to access */
@@ -57,9 +18,13 @@ struct wlan_ioctl_regrdwr {
 	u32 value;
 };
 
+#define WLAN_LINKMODE_802_3			0
+#define WLAN_LINKMODE_802_11			2
+#define WLAN_RADIOMODE_NONE			0
+#define WLAN_RADIOMODE_RADIOTAP			2
+
 extern struct iw_handler_def libertas_handler_def;
 extern struct iw_handler_def mesh_handler_def;
-int libertas_do_ioctl(struct net_device *dev, struct ifreq *req, int i);
 int wlan_radio_ioctl(wlan_private * priv, u8 option);
 
 #endif				/* _WLAN_WEXT_H_ */
