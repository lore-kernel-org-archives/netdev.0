From: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 2/3]: Fix second rmmod failure observed on PowerPC machines.
Date: Wed, 28 Feb 2007 05:16:40 -0800
Message-ID: <200702281316.l1SDGevb004381@dut39.unminc.com>
Cc: jeff@garzik.org, mithlesh@netxen.com, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:15810 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932273AbXB1NQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 08:16:40 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix second rmmod failure observed on PowerPC machines.

Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>

---

 netxen_nic_hw.c   |    5 +++--
 netxen_nic_init.c |   23 +++++++++++++----------
 netxen_nic_main.c |    9 ++++-----
 3 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index deec796..a2877f3 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -508,8 +508,8 @@ void netxen_nic_pci_change_crbwindow(str
 void netxen_load_firmware(struct netxen_adapter *adapter)
 {
 	int i;
-	long data, size = 0;
-	long flashaddr = NETXEN_FLASH_BASE, memaddr = NETXEN_PHANTOM_MEM_BASE;
+	u32 data, size = 0;
+	u32 flashaddr = NETXEN_FLASH_BASE, memaddr = NETXEN_PHANTOM_MEM_BASE;
 	u64 off;
 	void __iomem *addr;
 
@@ -951,6 +951,7 @@ void netxen_nic_flash_print(struct netxe
 				       netxen_nic_driver_name);
 				return;
 			}
+			*ptr32 = le32_to_cpu(*ptr32);
 			ptr32++;
 			addr += sizeof(u32);
 		}
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 2f96570..586d32b 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -38,13 +38,13 @@ #include "netxen_nic_hw.h"
 #include "netxen_nic_phan_reg.h"
 
 struct crb_addr_pair {
-	long addr;
-	long data;
+	u32 addr;
+	u32 data;
 };
 
 #define NETXEN_MAX_CRB_XFORM 60
 static unsigned int crb_addr_xform[NETXEN_MAX_CRB_XFORM];
-#define NETXEN_ADDR_ERROR ((unsigned long ) 0xffffffff )
+#define NETXEN_ADDR_ERROR (0xffffffff)
 
 #define crb_addr_transform(name) \
 	crb_addr_xform[NETXEN_HW_PX_MAP_CRB_##name] = \
@@ -252,10 +252,10 @@ void netxen_initialize_adapter_ops(struc
  * netxen_decode_crb_addr(0 - utility to translate from internal Phantom CRB
  * address to external PCI CRB address.
  */
-unsigned long netxen_decode_crb_addr(unsigned long addr)
+u32 netxen_decode_crb_addr(u32 addr)
 {
 	int i;
-	unsigned long base_addr, offset, pci_base;
+	u32 base_addr, offset, pci_base;
 
 	crb_addr_transform_setup();
 
@@ -756,7 +756,7 @@ int netxen_pinit_from_rom(struct netxen_
 	int n, i;
 	int init_delay = 0;
 	struct crb_addr_pair *buf;
-	unsigned long off;
+	u32 off;
 
 	/* resetall */
 	status = netxen_nic_get_board_info(adapter);
@@ -813,14 +813,13 @@ int netxen_pinit_from_rom(struct netxen_
 			if (verbose)
 				printk("%s: PCI:     0x%08x == 0x%08x\n",
 				       netxen_nic_driver_name, (unsigned int)
-				       netxen_decode_crb_addr((unsigned long)
-							      addr), val);
+				       netxen_decode_crb_addr(addr), val);
 		}
 		for (i = 0; i < n; i++) {
 
-			off = netxen_decode_crb_addr((unsigned long)buf[i].addr);
+			off = netxen_decode_crb_addr(buf[i].addr);
 			if (off == NETXEN_ADDR_ERROR) {
-				printk(KERN_ERR"CRB init value out of range %lx\n",
+				printk(KERN_ERR"CRB init value out of range %x\n",
 					buf[i].addr);
 				continue;
 			}
@@ -927,6 +926,10 @@ int netxen_initialize_adapter_offload(st
 void netxen_free_adapter_offload(struct netxen_adapter *adapter)
 {
 	if (adapter->dummy_dma.addr) {
+		writel(0, NETXEN_CRB_NORMALIZE(adapter,
+			CRB_HOST_DUMMY_BUF_ADDR_HI));
+		writel(0, NETXEN_CRB_NORMALIZE(adapter,
+			CRB_HOST_DUMMY_BUF_ADDR_LO));
 		pci_free_consistent(adapter->ahw.pdev,
 				    NETXEN_HOST_DUMMY_DMA_SIZE,
 				    adapter->dummy_dma.addr,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 2227504..7d2525e 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -434,13 +434,11 @@ #endif
 		adapter->port_count++;
 		adapter->port[i] = port;
 	}
-#ifndef CONFIG_PPC64
 	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
 	netxen_pinit_from_rom(adapter, 0);
 	udelay(500);
 	netxen_load_firmware(adapter);
 	netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
-#endif
 	/*
 	 * delay a while to ensure that the Pegs are up & running.
 	 * Otherwise, we might see some flaky behaviour.
@@ -529,12 +527,13 @@ static void __devexit netxen_nic_remove(
 		free_irq(adapter->irq, adapter);
 	netxen_nic_stop_all_ports(adapter);
 	/* leave the hw in the same state as reboot */
-	netxen_pinit_from_rom(adapter, 0);
 	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+	netxen_pinit_from_rom(adapter, 0);
+	udelay(500);
 	netxen_load_firmware(adapter);
 	netxen_free_adapter_offload(adapter);
 
-	udelay(500);		/* Delay for a while to drain the DMA engines */
+	mdelay(1000);		/* Delay for a while to drain the DMA engines */
 	for (i = 0; i < adapter->port_count; i++) {
 		port = adapter->port[i];
 		if ((port) && (port->netdev)) {
@@ -545,7 +544,6 @@ static void __devexit netxen_nic_remove(
 
 	if ((adapter->flags & NETXEN_NIC_MSI_ENABLED))
 		pci_disable_msi(pdev);
-	pci_set_drvdata(pdev, NULL);
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC)
 		netxen_free_hw_resources(adapter);
 
@@ -556,6 +554,7 @@ static void __devexit netxen_nic_remove(
 
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
 
 	for (ctxid = 0; ctxid < MAX_RCV_CTX; ++ctxid) {
 		recv_ctx = &adapter->recv_ctx[ctxid];
