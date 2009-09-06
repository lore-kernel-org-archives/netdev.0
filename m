From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 4/6] netxen: pre calculate register addresses
Date: Sat,  5 Sep 2009 20:43:10 -0700
Message-ID: <1252208592-2240-5-git-send-email-dhananjay@netxen.com>
References: <1252208592-2240-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@netxen.com>
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:25071 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754047AbZIFDnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Sep 2009 23:43:13 -0400
In-Reply-To: <1252208592-2240-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@netxen.com>

For registers accessed in fast path (interrupt / softirq)
avoid expensive I/O address translation. These registers
are directly mapped in PCI bar 0 and do not require
any window checks.

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |   75 +++++---------
 drivers/net/netxen/netxen_nic_ctx.c     |   21 +++--
 drivers/net/netxen/netxen_nic_ethtool.c |    5 +-
 drivers/net/netxen/netxen_nic_hw.c      |  176 +++++++++++++++++++++----------
 drivers/net/netxen/netxen_nic_init.c    |   34 +-----
 drivers/net/netxen/netxen_nic_main.c    |   90 +++++++---------
 6 files changed, 210 insertions(+), 191 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 30a3816..5bbc40b 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -584,11 +584,11 @@ struct netxen_adapter_stats {
  */
 struct nx_host_rds_ring {
 	u32 producer;
-	u32 crb_rcv_producer;
 	u32 num_desc;
 	u32 dma_size;
 	u32 skb_size;
 	u32 flags;
+	void __iomem *crb_rcv_producer;
 	struct rcv_desc *desc_head;
 	struct netxen_rx_buffer *rx_buf_arr;
 	struct list_head free_list;
@@ -598,9 +598,9 @@ struct nx_host_rds_ring {
 
 struct nx_host_sds_ring {
 	u32 consumer;
-	u32 crb_sts_consumer;
-	u32 crb_intr_mask;
 	u32 num_desc;
+	void __iomem *crb_sts_consumer;
+	void __iomem *crb_intr_mask;
 
 	struct status_desc *desc_head;
 	struct netxen_adapter *adapter;
@@ -617,8 +617,8 @@ struct nx_host_tx_ring {
 	u32 producer;
 	__le32 *hw_consumer;
 	u32 sw_consumer;
-	u32 crb_cmd_producer;
-	u32 crb_cmd_consumer;
+	void __iomem *crb_cmd_producer;
+	void __iomem *crb_cmd_consumer;
 	u32 num_desc;
 
 	struct netdev_queue *txq;
@@ -1163,7 +1163,7 @@ struct netxen_adapter {
 	u32 irq;
 	u32 temp;
 
-	u32 msi_tgt_status;
+	u32 int_vec_bit;
 	u32 heartbit;
 
 	struct netxen_adapter_stats stats;
@@ -1180,16 +1180,23 @@ struct netxen_adapter {
 	int (*init_port) (struct netxen_adapter *, int);
 	int (*stop_port) (struct netxen_adapter *);
 
-	u32 (*hw_read_wx)(struct netxen_adapter *, ulong);
-	int (*hw_write_wx)(struct netxen_adapter *, ulong, u32);
+	u32 (*crb_read)(struct netxen_adapter *, ulong);
+	int (*crb_write)(struct netxen_adapter *, ulong, u32);
+
 	int (*pci_mem_read)(struct netxen_adapter *, u64, void *, int);
 	int (*pci_mem_write)(struct netxen_adapter *, u64, void *, int);
-	int (*pci_write_immediate)(struct netxen_adapter *, u64, u32);
-	u32 (*pci_read_immediate)(struct netxen_adapter *, u64);
+
 	unsigned long (*pci_set_window)(struct netxen_adapter *,
 			unsigned long long);
 
-	struct netxen_legacy_intr_set legacy_intr;
+	u32 (*io_read)(struct netxen_adapter *, void __iomem *);
+	void (*io_write)(struct netxen_adapter *, void __iomem *, u32);
+
+	void __iomem	*tgt_mask_reg;
+	void __iomem	*pci_int_reg;
+	void __iomem	*tgt_status_reg;
+	void __iomem	*crb_int_state_reg;
+	void __iomem	*isr_int_vec;
 
 	struct msix_entry msix_entries[MSIX_ENTRIES_PER_ADAPTER];
 
@@ -1223,9 +1230,13 @@ int netxen_p2_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr);
 int netxen_p3_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr);
 
 #define NXRD32(adapter, off) \
-	(adapter->hw_read_wx(adapter, off))
+	(adapter->crb_read(adapter, off))
 #define NXWR32(adapter, off, val) \
-	(adapter->hw_write_wx(adapter, off, val))
+	(adapter->crb_write(adapter, off, val))
+#define NXRDIO(adapter, addr) \
+	(adapter->io_read(adapter, addr))
+#define NXWRIO(adapter, addr, val) \
+	(adapter->io_write(adapter, addr, val))
 
 int netxen_pcie_sem_lock(struct netxen_adapter *, int, u32);
 void netxen_pcie_sem_unlock(struct netxen_adapter *, int);
@@ -1255,40 +1266,6 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter);
 void netxen_nic_get_firmware_info(struct netxen_adapter *adapter);
 int netxen_nic_wol_supported(struct netxen_adapter *adapter);
 
-u32 netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter, ulong off);
-int netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter,
-		ulong off, u32 data);
-int netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
-		u64 off, void *data, int size);
-int netxen_nic_pci_mem_write_128M(struct netxen_adapter *adapter,
-		u64 off, void *data, int size);
-int netxen_nic_pci_write_immediate_128M(struct netxen_adapter *adapter,
-		u64 off, u32 data);
-u32 netxen_nic_pci_read_immediate_128M(struct netxen_adapter *adapter, u64 off);
-void netxen_nic_pci_write_normalize_128M(struct netxen_adapter *adapter,
-		u64 off, u32 data);
-u32 netxen_nic_pci_read_normalize_128M(struct netxen_adapter *adapter, u64 off);
-unsigned long netxen_nic_pci_set_window_128M(struct netxen_adapter *adapter,
-		unsigned long long addr);
-void netxen_nic_pci_change_crbwindow_128M(struct netxen_adapter *adapter,
-		u32 wndw);
-
-u32 netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter, ulong off);
-int netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter,
-		ulong off, u32 data);
-int netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
-		u64 off, void *data, int size);
-int netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
-		u64 off, void *data, int size);
-int netxen_nic_pci_write_immediate_2M(struct netxen_adapter *adapter,
-		u64 off, u32 data);
-u32 netxen_nic_pci_read_immediate_2M(struct netxen_adapter *adapter, u64 off);
-void netxen_nic_pci_write_normalize_2M(struct netxen_adapter *adapter,
-		u64 off, u32 data);
-u32 netxen_nic_pci_read_normalize_2M(struct netxen_adapter *adapter, u64 off);
-unsigned long netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
-		unsigned long long addr);
-
 /* Functions from netxen_nic_init.c */
 int netxen_init_dummy_dma(struct netxen_adapter *adapter);
 void netxen_free_dummy_dma(struct netxen_adapter *adapter);
@@ -1316,13 +1293,15 @@ int netxen_rom_se(struct netxen_adapter *adapter, int addr);
 int netxen_alloc_sw_resources(struct netxen_adapter *adapter);
 void netxen_free_sw_resources(struct netxen_adapter *adapter);
 
+void netxen_setup_hwops(struct netxen_adapter *adapter);
+void __iomem *netxen_get_ioaddr(struct netxen_adapter *, u32);
+
 int netxen_alloc_hw_resources(struct netxen_adapter *adapter);
 void netxen_free_hw_resources(struct netxen_adapter *adapter);
 
 void netxen_release_rx_buffers(struct netxen_adapter *adapter);
 void netxen_release_tx_buffers(struct netxen_adapter *adapter);
 
-void netxen_initialize_adapter_ops(struct netxen_adapter *adapter);
 int netxen_init_firmware(struct netxen_adapter *adapter);
 void netxen_nic_clear_stats(struct netxen_adapter *adapter);
 void netxen_watchdog_task(struct work_struct *work);
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 8ab5773..33f82db 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -229,7 +229,8 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 		rds_ring = &recv_ctx->rds_rings[i];
 
 		reg = le32_to_cpu(prsp_rds[i].host_producer_crb);
-		rds_ring->crb_rcv_producer = NETXEN_NIC_REG(reg - 0x200);
+		rds_ring->crb_rcv_producer = netxen_get_ioaddr(adapter,
+				NETXEN_NIC_REG(reg - 0x200));
 	}
 
 	prsp_sds = ((nx_cardrsp_sds_ring_t *)
@@ -239,10 +240,12 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 		sds_ring = &recv_ctx->sds_rings[i];
 
 		reg = le32_to_cpu(prsp_sds[i].host_consumer_crb);
-		sds_ring->crb_sts_consumer = NETXEN_NIC_REG(reg - 0x200);
+		sds_ring->crb_sts_consumer = netxen_get_ioaddr(adapter,
+				NETXEN_NIC_REG(reg - 0x200));
 
 		reg = le32_to_cpu(prsp_sds[i].interrupt_crb);
-		sds_ring->crb_intr_mask = NETXEN_NIC_REG(reg - 0x200);
+		sds_ring->crb_intr_mask = netxen_get_ioaddr(adapter,
+				NETXEN_NIC_REG(reg - 0x200));
 	}
 
 	recv_ctx->state = le32_to_cpu(prsp->host_ctx_state);
@@ -342,7 +345,8 @@ nx_fw_cmd_create_tx_ctx(struct netxen_adapter *adapter)
 
 	if (err == NX_RCODE_SUCCESS) {
 		temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
-		tx_ring->crb_cmd_producer = NETXEN_NIC_REG(temp - 0x200);
+		tx_ring->crb_cmd_producer = netxen_get_ioaddr(adapter,
+				NETXEN_NIC_REG(temp - 0x200));
 #if 0
 		adapter->tx_state =
 			le32_to_cpu(prsp->host_ctx_state);
@@ -651,7 +655,8 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 
 		if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
 			rds_ring->crb_rcv_producer =
-				recv_crb_registers[port].crb_rcv_producer[ring];
+				netxen_get_ioaddr(adapter,
+			recv_crb_registers[port].crb_rcv_producer[ring]);
 	}
 
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
@@ -670,10 +675,12 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 		sds_ring->desc_head = (struct status_desc *)addr;
 
 		sds_ring->crb_sts_consumer =
-			recv_crb_registers[port].crb_sts_consumer[ring];
+			netxen_get_ioaddr(adapter,
+			recv_crb_registers[port].crb_sts_consumer[ring]);
 
 		sds_ring->crb_intr_mask =
-			recv_crb_registers[port].sw_int_mask[ring];
+			netxen_get_ioaddr(adapter,
+			recv_crb_registers[port].sw_int_mask[ring]);
 	}
 
 
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index e376a1c..d18832c 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -84,18 +84,17 @@ static void
 netxen_nic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
-	unsigned long flags;
 	u32 fw_major = 0;
 	u32 fw_minor = 0;
 	u32 fw_build = 0;
 
 	strncpy(drvinfo->driver, netxen_nic_driver_name, 32);
 	strncpy(drvinfo->version, NETXEN_NIC_LINUX_VERSIONID, 32);
-	write_lock_irqsave(&adapter->adapter_lock, flags);
+	read_lock(&adapter->adapter_lock);
 	fw_major = NXRD32(adapter, NETXEN_FW_VERSION_MAJOR);
 	fw_minor = NXRD32(adapter, NETXEN_FW_VERSION_MINOR);
 	fw_build = NXRD32(adapter, NETXEN_FW_VERSION_SUB);
-	write_unlock_irqrestore(&adapter->adapter_lock, flags);
+	read_unlock(&adapter->adapter_lock);
 	sprintf(drvinfo->fw_version, "%d.%d.%d", fw_major, fw_minor, fw_build);
 
 	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index d0ac8fa..cbfd610 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1050,7 +1050,7 @@ int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
 /*
  * Changes the CRB window to the specified window.
  */
-void
+static void
 netxen_nic_pci_change_crbwindow_128M(struct netxen_adapter *adapter, u32 wndw)
 {
 	void __iomem *offset;
@@ -1163,61 +1163,68 @@ netxen_nic_pci_set_crbwindow_2M(struct netxen_adapter *adapter, ulong *off)
 		(ulong)adapter->ahw.pci_base0;
 }
 
-int
+static int
 netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter, ulong off, u32 data)
 {
+	unsigned long flags;
 	void __iomem *addr;
 
-	if (ADDR_IN_WINDOW1(off)) {
+	if (ADDR_IN_WINDOW1(off))
 		addr = NETXEN_CRB_NORMALIZE(adapter, off);
+	else
+		addr = pci_base_offset(adapter, off);
+
+	BUG_ON(!addr);
+
+	if (ADDR_IN_WINDOW1(off)) {	/* Window 1 */
+		read_lock(&adapter->adapter_lock);
+		writel(data, addr);
+		read_unlock(&adapter->adapter_lock);
 	} else {		/* Window 0 */
+		write_lock_irqsave(&adapter->adapter_lock, flags);
 		addr = pci_base_offset(adapter, off);
 		netxen_nic_pci_change_crbwindow_128M(adapter, 0);
-	}
-
-	if (!addr) {
+		writel(data, addr);
 		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
-		return 1;
+		write_unlock_irqrestore(&adapter->adapter_lock, flags);
 	}
 
-	writel(data, addr);
-
-	if (!ADDR_IN_WINDOW1(off))
-		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
-
 	return 0;
 }
 
-u32
+static u32
 netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter, ulong off)
 {
+	unsigned long flags;
 	void __iomem *addr;
 	u32 data;
 
-	if (ADDR_IN_WINDOW1(off)) {	/* Window 1 */
+	if (ADDR_IN_WINDOW1(off))
 		addr = NETXEN_CRB_NORMALIZE(adapter, off);
-	} else {		/* Window 0 */
+	else
 		addr = pci_base_offset(adapter, off);
-		netxen_nic_pci_change_crbwindow_128M(adapter, 0);
-	}
-
-	if (!addr) {
-		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
-		return 1;
-	}
 
-	data = readl(addr);
+	BUG_ON(!addr);
 
-	if (!ADDR_IN_WINDOW1(off))
+	if (ADDR_IN_WINDOW1(off)) {	/* Window 1 */
+		read_lock(&adapter->adapter_lock);
+		data = readl(addr);
+		read_unlock(&adapter->adapter_lock);
+	} else {		/* Window 0 */
+		write_lock_irqsave(&adapter->adapter_lock, flags);
+		netxen_nic_pci_change_crbwindow_128M(adapter, 0);
+		data = readl(addr);
 		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
+		write_unlock_irqrestore(&adapter->adapter_lock, flags);
+	}
 
 	return data;
 }
 
-int
+static int
 netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter, ulong off, u32 data)
 {
-	unsigned long flags = 0;
+	unsigned long flags;
 	int rv;
 
 	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off);
@@ -1243,10 +1250,10 @@ netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter, ulong off, u32 data)
 	return 0;
 }
 
-u32
+static u32
 netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter, ulong off)
 {
-	unsigned long flags = 0;
+	unsigned long flags;
 	int rv;
 	u32 data;
 
@@ -1293,7 +1300,7 @@ netxen_nic_pci_mem_bound_check(struct netxen_adapter *adapter,
 
 static int netxen_pci_set_window_warning_count;
 
-unsigned long
+static unsigned long
 netxen_nic_pci_set_window_128M(struct netxen_adapter *adapter,
 		unsigned long long addr)
 {
@@ -1357,22 +1364,56 @@ netxen_nic_pci_set_window_128M(struct netxen_adapter *adapter,
 	return addr;
 }
 
-/*
- * Note : only 32-bit writes!
- */
-int netxen_nic_pci_write_immediate_128M(struct netxen_adapter *adapter,
-		u64 off, u32 data)
+/* window 1 registers only */
+static void netxen_nic_io_write_128M(struct netxen_adapter *adapter,
+		void __iomem *addr, u32 data)
 {
-	writel(data, (void __iomem *)(PCI_OFFSET_SECOND_RANGE(adapter, off)));
-	return 0;
+	read_lock(&adapter->adapter_lock);
+	writel(data, addr);
+	read_unlock(&adapter->adapter_lock);
+}
+
+static u32 netxen_nic_io_read_128M(struct netxen_adapter *adapter,
+		void __iomem *addr)
+{
+	u32 val;
+
+	read_lock(&adapter->adapter_lock);
+	val = readl(addr);
+	read_unlock(&adapter->adapter_lock);
+
+	return val;
 }
 
-u32 netxen_nic_pci_read_immediate_128M(struct netxen_adapter *adapter, u64 off)
+static void netxen_nic_io_write_2M(struct netxen_adapter *adapter,
+		void __iomem *addr, u32 data)
 {
-	return readl((void __iomem *)(pci_base_offset(adapter, off)));
+	writel(data, addr);
+}
+
+static u32 netxen_nic_io_read_2M(struct netxen_adapter *adapter,
+		void __iomem *addr)
+{
+	return readl(addr);
+}
+
+void __iomem *
+netxen_get_ioaddr(struct netxen_adapter *adapter, u32 offset)
+{
+	ulong off = offset;
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+		if (offset < NETXEN_CRB_PCIX_HOST2 &&
+				offset > NETXEN_CRB_PCIX_HOST)
+			return PCI_OFFSET_SECOND_RANGE(adapter, offset);
+		return NETXEN_CRB_NORMALIZE(adapter, offset);
+	}
+
+	BUG_ON(netxen_nic_pci_get_crb_addr_2M(adapter, &off));
+	return (void __iomem *)off;
 }
 
-unsigned long
+static unsigned long
 netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 		unsigned long long addr)
 {
@@ -1616,7 +1657,7 @@ netxen_nic_pci_mem_write_direct(struct netxen_adapter *adapter, u64 off,
 
 #define MAX_CTL_CHECK   1000
 
-int
+static int
 netxen_nic_pci_mem_write_128M(struct netxen_adapter *adapter,
 		u64 off, void *data, int size)
 {
@@ -1709,7 +1750,7 @@ netxen_nic_pci_mem_write_128M(struct netxen_adapter *adapter,
 	return ret;
 }
 
-int
+static int
 netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
 		u64 off, void *data, int size)
 {
@@ -1800,7 +1841,7 @@ netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
 	return 0;
 }
 
-int
+static int
 netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
 		u64 off, void *data, int size)
 {
@@ -1828,8 +1869,8 @@ netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
 
 	if ((size != 8) || (off0 != 0)) {
 		for (i = 0; i < loop; i++) {
-			if (adapter->pci_mem_read(adapter, off8 + (i << 3),
-						&word[i], 8))
+			if (adapter->pci_mem_read(adapter,
+					off8 + (i << 3), &word[i], 8))
 				return -1;
 		}
 	}
@@ -1900,7 +1941,7 @@ netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
 	return ret;
 }
 
-int
+static int
 netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 		u64 off, void *data, int size)
 {
@@ -1998,20 +2039,43 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 	return 0;
 }
 
-/*
- * Note : only 32-bit writes!
- */
-int netxen_nic_pci_write_immediate_2M(struct netxen_adapter *adapter,
-		u64 off, u32 data)
+void
+netxen_setup_hwops(struct netxen_adapter *adapter)
 {
-	NXWR32(adapter, off, data);
+	adapter->init_port = netxen_niu_xg_init_port;
+	adapter->stop_port = netxen_niu_disable_xg_port;
 
-	return 0;
-}
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+		adapter->crb_read = netxen_nic_hw_read_wx_128M,
+		adapter->crb_write = netxen_nic_hw_write_wx_128M,
+		adapter->pci_set_window = netxen_nic_pci_set_window_128M,
+		adapter->pci_mem_read = netxen_nic_pci_mem_read_128M,
+		adapter->pci_mem_write = netxen_nic_pci_mem_write_128M,
+		adapter->io_read = netxen_nic_io_read_128M,
+		adapter->io_write = netxen_nic_io_write_128M,
+
+		adapter->macaddr_set = netxen_p2_nic_set_mac_addr;
+		adapter->set_multi = netxen_p2_nic_set_multi;
+		adapter->set_mtu = netxen_nic_set_mtu_xgb;
+		adapter->set_promisc = netxen_p2_nic_set_promisc;
 
-u32 netxen_nic_pci_read_immediate_2M(struct netxen_adapter *adapter, u64 off)
-{
-	return NXRD32(adapter, off);
+	} else {
+		adapter->crb_read = netxen_nic_hw_read_wx_2M,
+		adapter->crb_write = netxen_nic_hw_write_wx_2M,
+		adapter->pci_set_window = netxen_nic_pci_set_window_2M,
+		adapter->pci_mem_read = netxen_nic_pci_mem_read_2M,
+		adapter->pci_mem_write = netxen_nic_pci_mem_write_2M,
+		adapter->io_read = netxen_nic_io_read_2M,
+		adapter->io_write = netxen_nic_io_write_2M,
+
+		adapter->set_mtu = nx_fw_cmd_set_mtu;
+		adapter->set_promisc = netxen_p3_nic_set_promisc;
+		adapter->macaddr_set = netxen_p3_nic_set_mac_addr;
+		adapter->set_multi = netxen_p3_nic_set_multi;
+
+		adapter->phy_read = nx_fw_cmd_query_phy;
+		adapter->phy_write = nx_fw_cmd_set_phy;
+	}
 }
 
 int netxen_nic_get_board_info(struct netxen_adapter *adapter)
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 534994d..485b947 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -323,29 +323,6 @@ err_out:
 	return -ENOMEM;
 }
 
-void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
-{
-	adapter->init_port = netxen_niu_xg_init_port;
-	adapter->stop_port = netxen_niu_disable_xg_port;
-
-	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
-		adapter->macaddr_set = netxen_p2_nic_set_mac_addr;
-		adapter->set_multi = netxen_p2_nic_set_multi;
-		adapter->set_mtu = netxen_nic_set_mtu_xgb;
-		adapter->set_promisc = netxen_p2_nic_set_promisc;
-	} else {
-		adapter->set_mtu = nx_fw_cmd_set_mtu;
-		adapter->set_promisc = netxen_p3_nic_set_promisc;
-		adapter->macaddr_set = netxen_p3_nic_set_mac_addr;
-		adapter->set_multi = netxen_p3_nic_set_multi;
-
-		if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
-			adapter->phy_read = nx_fw_cmd_query_phy;
-			adapter->phy_write = nx_fw_cmd_set_phy;
-		}
-	}
-}
-
 /*
  * netxen_decode_crb_addr(0 - utility to translate from internal Phantom CRB
  * address to external PCI CRB address.
@@ -1395,7 +1372,7 @@ skip:
 
 	if (count) {
 		sds_ring->consumer = consumer;
-		NXWR32(adapter, sds_ring->crb_sts_consumer, consumer);
+		NXWRIO(adapter, sds_ring->crb_sts_consumer, consumer);
 	}
 
 	return count;
@@ -1513,7 +1490,7 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid,
 
 	if (count) {
 		rds_ring->producer = producer;
-		NXWR32(adapter, rds_ring->crb_rcv_producer,
+		NXWRIO(adapter, rds_ring->crb_rcv_producer,
 				(producer-1) & (rds_ring->num_desc-1));
 
 		if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
@@ -1529,9 +1506,10 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid,
 					      (rds_ring->num_desc - 1)));
 			netxen_set_msg_ctxid(msg, adapter->portnum);
 			netxen_set_msg_opcode(msg, NETXEN_RCV_PRODUCER(ringid));
-			writel(msg,
-			       DB_NORMALIZE(adapter,
+			read_lock(&adapter->adapter_lock);
+			writel(msg, DB_NORMALIZE(adapter,
 					    NETXEN_RCV_PRODUCER_OFFSET));
+			read_unlock(&adapter->adapter_lock);
 		}
 	}
 }
@@ -1573,7 +1551,7 @@ netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 
 	if (count) {
 		rds_ring->producer = producer;
-		NXWR32(adapter, rds_ring->crb_rcv_producer,
+		NXWRIO(adapter, rds_ring->crb_rcv_producer,
 				(producer - 1) & (rds_ring->num_desc - 1));
 	}
 	spin_unlock(&rds_ring->lock);
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 7038e1b..b2fd713 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -116,7 +116,7 @@ void
 netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
 		struct nx_host_tx_ring *tx_ring)
 {
-	NXWR32(adapter, tx_ring->crb_cmd_producer, tx_ring->producer);
+	NXWRIO(adapter, tx_ring->crb_cmd_producer, tx_ring->producer);
 
 	if (netxen_tx_avail(tx_ring) <= TX_STOP_THRESH) {
 		netif_stop_queue(adapter->netdev);
@@ -133,7 +133,7 @@ static inline void
 netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter,
 		struct nx_host_tx_ring *tx_ring)
 {
-	NXWR32(adapter, tx_ring->crb_cmd_consumer, tx_ring->sw_consumer);
+	NXWRIO(adapter, tx_ring->crb_cmd_consumer, tx_ring->sw_consumer);
 }
 
 static uint32_t msi_tgt_status[8] = {
@@ -149,18 +149,17 @@ static inline void netxen_nic_disable_int(struct nx_host_sds_ring *sds_ring)
 {
 	struct netxen_adapter *adapter = sds_ring->adapter;
 
-	NXWR32(adapter, sds_ring->crb_intr_mask, 0);
+	NXWRIO(adapter, sds_ring->crb_intr_mask, 0);
 }
 
 static inline void netxen_nic_enable_int(struct nx_host_sds_ring *sds_ring)
 {
 	struct netxen_adapter *adapter = sds_ring->adapter;
 
-	NXWR32(adapter, sds_ring->crb_intr_mask, 0x1);
+	NXWRIO(adapter, sds_ring->crb_intr_mask, 0x1);
 
 	if (!NETXEN_IS_MSI_FAMILY(adapter))
-		adapter->pci_write_immediate(adapter,
-				adapter->legacy_intr.tgt_mask_reg, 0xfbff);
+		NXWRIO(adapter, adapter->tgt_mask_reg, 0xfbff);
 }
 
 static int
@@ -556,10 +555,22 @@ netxen_setup_intr(struct netxen_adapter *adapter)
 		legacy_intrp = &legacy_intr[adapter->ahw.pci_func];
 	else
 		legacy_intrp = &legacy_intr[0];
-	adapter->legacy_intr.int_vec_bit = legacy_intrp->int_vec_bit;
-	adapter->legacy_intr.tgt_status_reg = legacy_intrp->tgt_status_reg;
-	adapter->legacy_intr.tgt_mask_reg = legacy_intrp->tgt_mask_reg;
-	adapter->legacy_intr.pci_int_reg = legacy_intrp->pci_int_reg;
+
+	adapter->int_vec_bit = legacy_intrp->int_vec_bit;
+	adapter->tgt_status_reg = netxen_get_ioaddr(adapter,
+			legacy_intrp->tgt_status_reg);
+	adapter->tgt_mask_reg = netxen_get_ioaddr(adapter,
+			legacy_intrp->tgt_mask_reg);
+	adapter->pci_int_reg = netxen_get_ioaddr(adapter,
+			legacy_intrp->pci_int_reg);
+	adapter->isr_int_vec = netxen_get_ioaddr(adapter, ISR_INT_VECTOR);
+
+	if (adapter->ahw.revision_id >= NX_P3_B1)
+		adapter->crb_int_state_reg = netxen_get_ioaddr(adapter,
+			ISR_INT_STATE_REG);
+	else
+		adapter->crb_int_state_reg = netxen_get_ioaddr(adapter,
+			CRB_INT_VECTOR);
 
 	netxen_set_msix_bit(pdev, 0);
 
@@ -586,8 +597,8 @@ netxen_setup_intr(struct netxen_adapter *adapter)
 
 	if (use_msi && !pci_enable_msi(pdev)) {
 		adapter->flags |= NETXEN_NIC_MSI_ENABLED;
-		adapter->msi_tgt_status =
-			msi_tgt_status[adapter->ahw.pci_func];
+		adapter->tgt_status_reg = netxen_get_ioaddr(adapter,
+				msi_tgt_status[adapter->ahw.pci_func]);
 		dev_info(&pdev->dev, "using msi interrupts\n");
 		adapter->msix_entries[0].vector = pdev->irq;
 		return;
@@ -647,14 +658,6 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 	mem_len = pci_resource_len(pdev, 0);
 	pci_len0 = 0;
 
-	adapter->hw_write_wx = netxen_nic_hw_write_wx_128M;
-	adapter->hw_read_wx = netxen_nic_hw_read_wx_128M;
-	adapter->pci_read_immediate = netxen_nic_pci_read_immediate_128M;
-	adapter->pci_write_immediate = netxen_nic_pci_write_immediate_128M;
-	adapter->pci_set_window = netxen_nic_pci_set_window_128M;
-	adapter->pci_mem_read = netxen_nic_pci_mem_read_128M;
-	adapter->pci_mem_write = netxen_nic_pci_mem_write_128M;
-
 	/* 128 Meg of memory */
 	if (mem_len == NETXEN_PCI_128MB_SIZE) {
 		mem_ptr0 = ioremap(mem_base, FIRST_PAGE_GROUP_SIZE);
@@ -667,14 +670,6 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 		mem_ptr2 = ioremap(mem_base + THIRD_PAGE_GROUP_START -
 			SECOND_PAGE_GROUP_START, THIRD_PAGE_GROUP_SIZE);
 	} else if (mem_len == NETXEN_PCI_2MB_SIZE) {
-		adapter->hw_write_wx = netxen_nic_hw_write_wx_2M;
-		adapter->hw_read_wx = netxen_nic_hw_read_wx_2M;
-		adapter->pci_read_immediate = netxen_nic_pci_read_immediate_2M;
-		adapter->pci_write_immediate =
-			netxen_nic_pci_write_immediate_2M;
-		adapter->pci_set_window = netxen_nic_pci_set_window_2M;
-		adapter->pci_mem_read = netxen_nic_pci_mem_read_2M;
-		adapter->pci_mem_write = netxen_nic_pci_mem_write_2M;
 
 		mem_ptr0 = pci_ioremap_bar(pdev, 0);
 		if (mem_ptr0 == NULL) {
@@ -698,6 +693,8 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 		return -EIO;
 	}
 
+	netxen_setup_hwops(adapter);
+
 	dev_info(&pdev->dev, "%dMB memory map\n", (int)(mem_len>>20));
 
 	adapter->ahw.pci_base0 = mem_ptr0;
@@ -990,8 +987,10 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 		tx_ring = adapter->tx_ring;
-		tx_ring->crb_cmd_producer = crb_cmd_producer[adapter->portnum];
-		tx_ring->crb_cmd_consumer = crb_cmd_consumer[adapter->portnum];
+		tx_ring->crb_cmd_producer = netxen_get_ioaddr(adapter,
+				crb_cmd_producer[adapter->portnum]);
+		tx_ring->crb_cmd_consumer = netxen_get_ioaddr(adapter,
+				crb_cmd_consumer[adapter->portnum]);
 
 		tx_ring->producer = 0;
 		tx_ring->sw_consumer = 0;
@@ -1213,8 +1212,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_iounmap;
 	}
 
-	netxen_initialize_adapter_ops(adapter);
-
 	/* Mezz cards have PCI function 0,2,3 enabled */
 	switch (adapter->ahw.board_type) {
 	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
@@ -1870,41 +1867,37 @@ static irqreturn_t netxen_intr(int irq, void *data)
 	struct netxen_adapter *adapter = sds_ring->adapter;
 	u32 status = 0;
 
-	status = adapter->pci_read_immediate(adapter, ISR_INT_VECTOR);
+	status = readl(adapter->isr_int_vec);
 
-	if (!(status & adapter->legacy_intr.int_vec_bit))
+	if (!(status & adapter->int_vec_bit))
 		return IRQ_NONE;
 
-	if (adapter->ahw.revision_id >= NX_P3_B1) {
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 		/* check interrupt state machine, to be sure */
-		status = adapter->pci_read_immediate(adapter,
-				ISR_INT_STATE_REG);
+		status = readl(adapter->crb_int_state_reg);
 		if (!ISR_LEGACY_INT_TRIGGERED(status))
 			return IRQ_NONE;
 
 	} else {
 		unsigned long our_int = 0;
 
-		our_int = NXRD32(adapter, CRB_INT_VECTOR);
+		our_int = readl(adapter->crb_int_state_reg);
 
 		/* not our interrupt */
 		if (!test_and_clear_bit((7 + adapter->portnum), &our_int))
 			return IRQ_NONE;
 
 		/* claim interrupt */
-		NXWR32(adapter, CRB_INT_VECTOR, (our_int & 0xffffffff));
-	}
+		writel((our_int & 0xffffffff), adapter->crb_int_state_reg);
 
-	/* clear interrupt */
-	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		/* clear interrupt */
 		netxen_nic_disable_int(sds_ring);
+	}
 
-	adapter->pci_write_immediate(adapter,
-			adapter->legacy_intr.tgt_status_reg,
-			0xffffffff);
+	writel(0xffffffff, adapter->tgt_status_reg);
 	/* read twice to ensure write is flushed */
-	adapter->pci_read_immediate(adapter, ISR_INT_VECTOR);
-	adapter->pci_read_immediate(adapter, ISR_INT_VECTOR);
+	readl(adapter->isr_int_vec);
+	readl(adapter->isr_int_vec);
 
 	napi_schedule(&sds_ring->napi);
 
@@ -1917,8 +1910,7 @@ static irqreturn_t netxen_msi_intr(int irq, void *data)
 	struct netxen_adapter *adapter = sds_ring->adapter;
 
 	/* clear interrupt */
-	adapter->pci_write_immediate(adapter,
-			adapter->msi_tgt_status, 0xffffffff);
+	writel(0xffffffff, adapter->tgt_status_reg);
 
 	napi_schedule(&sds_ring->napi);
 	return IRQ_HANDLED;
-- 
1.6.0.2

