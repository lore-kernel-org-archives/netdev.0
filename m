From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [RESENDv2 04/11] netxen: add 2MB PCI memory support
Date: Mon, 21 Jul 2008 19:44:03 -0700
Message-ID: <1216694650-23257-5-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:47588 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754647AbYGVCoM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 22:44:12 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New revision of netxen chip has 2MB PCI memory. Older chips
had 128MB addressable PCI memory. To retain compatibility,
this patch adds function pointers based on pci bar0 size.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |   70 ++-
 drivers/net/netxen/netxen_nic_ethtool.c |   31 +-
 drivers/net/netxen/netxen_nic_hw.c      | 1359 ++++++++++++++++++++++++++++---
 drivers/net/netxen/netxen_nic_hw.h      |   21 +-
 drivers/net/netxen/netxen_nic_init.c    |   54 +-
 drivers/net/netxen/netxen_nic_isr.c     |    4 +-
 drivers/net/netxen/netxen_nic_main.c    |  138 ++--
 drivers/net/netxen/netxen_nic_niu.c     |   87 +-
 8 files changed, 1492 insertions(+), 272 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index acc7d79..29ab2ce 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -799,6 +799,12 @@ struct netxen_hardware_context {
 	unsigned long first_page_group_start;
 	void __iomem *db_base;
 	unsigned long db_len;
+	unsigned long pci_len0;
+
+	int qdr_sn_window;
+	int ddr_mn_window;
+	unsigned long mn_win_crb;
+	unsigned long ms_win_crb;
 
 	u8 revision_id;
 	u16 board_type;
@@ -894,6 +900,8 @@ struct netxen_adapter {
 	struct work_struct  tx_timeout_task;
 
 	u32 curr_window;
+	u32 crb_win;
+	rwlock_t adapter_lock;
 
 	u32 cmd_producer;
 	__le32 *cmd_consumer;
@@ -947,6 +955,17 @@ struct netxen_adapter {
 	int (*init_port) (struct netxen_adapter *, int);
 	void (*init_niu) (struct netxen_adapter *);
 	int (*stop_port) (struct netxen_adapter *);
+
+	int (*hw_read_wx)(struct netxen_adapter *, ulong, void *, int);
+	int (*hw_write_wx)(struct netxen_adapter *, ulong, void *, int);
+	int (*pci_mem_read)(struct netxen_adapter *, u64, void *, int);
+	int (*pci_mem_write)(struct netxen_adapter *, u64, void *, int);
+	int (*pci_write_immediate)(struct netxen_adapter *, u64, u32);
+	u32 (*pci_read_immediate)(struct netxen_adapter *, u64);
+	void (*pci_write_normalize)(struct netxen_adapter *, u64, u32);
+	u32 (*pci_read_normalize)(struct netxen_adapter *, u64);
+	unsigned long (*pci_set_window)(struct netxen_adapter *,
+			unsigned long long);
 };				/* netxen_adapter structure */
 
 /*
@@ -1022,19 +1041,52 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
 int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu);
 int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu);
 void netxen_nic_init_niu_gb(struct netxen_adapter *adapter);
-void netxen_nic_pci_change_crbwindow(struct netxen_adapter *adapter, u32 wndw);
 void netxen_nic_reg_write(struct netxen_adapter *adapter, u64 off, u32 val);
 int netxen_nic_reg_read(struct netxen_adapter *adapter, u64 off);
 void netxen_nic_write_w0(struct netxen_adapter *adapter, u32 index, u32 value);
-void netxen_nic_read_w0(struct netxen_adapter *adapter, u32 index, u32 * value);
+void netxen_nic_read_w0(struct netxen_adapter *adapter, u32 index, u32 *value);
+void netxen_nic_write_w1(struct netxen_adapter *adapter, u32 index, u32 value);
+void netxen_nic_read_w1(struct netxen_adapter *adapter, u32 index, u32 *value);
 
 int netxen_nic_get_board_info(struct netxen_adapter *adapter);
-int netxen_nic_hw_read_wx(struct netxen_adapter *adapter, u64 off, void *data,
-			  int len);
-int netxen_nic_hw_write_wx(struct netxen_adapter *adapter, u64 off, void *data,
-			   int len);
+
+int netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter,
+		ulong off, void *data, int len);
+int netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter,
+		ulong off, void *data, int len);
+int netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
+		u64 off, void *data, int size);
+int netxen_nic_pci_mem_write_128M(struct netxen_adapter *adapter,
+		u64 off, void *data, int size);
+int netxen_nic_pci_write_immediate_128M(struct netxen_adapter *adapter,
+		u64 off, u32 data);
+u32 netxen_nic_pci_read_immediate_128M(struct netxen_adapter *adapter, u64 off);
+void netxen_nic_pci_write_normalize_128M(struct netxen_adapter *adapter,
+		u64 off, u32 data);
+u32 netxen_nic_pci_read_normalize_128M(struct netxen_adapter *adapter, u64 off);
+unsigned long netxen_nic_pci_set_window_128M(struct netxen_adapter *adapter,
+		unsigned long long addr);
+void netxen_nic_pci_change_crbwindow_128M(struct netxen_adapter *adapter,
+		u32 wndw);
+
+int netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter,
+		ulong off, void *data, int len);
+int netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter,
+		ulong off, void *data, int len);
+int netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
+		u64 off, void *data, int size);
+int netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
+		u64 off, void *data, int size);
 void netxen_crb_writelit_adapter(struct netxen_adapter *adapter,
 				 unsigned long off, int data);
+int netxen_nic_pci_write_immediate_2M(struct netxen_adapter *adapter,
+		u64 off, u32 data);
+u32 netxen_nic_pci_read_immediate_2M(struct netxen_adapter *adapter, u64 off);
+void netxen_nic_pci_write_normalize_2M(struct netxen_adapter *adapter,
+		u64 off, u32 data);
+u32 netxen_nic_pci_read_normalize_2M(struct netxen_adapter *adapter, u64 off);
+unsigned long netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
+		unsigned long long addr);
 
 /* Functions from netxen_nic_init.c */
 void netxen_free_adapter_offload(struct netxen_adapter *adapter);
@@ -1129,7 +1181,7 @@ dma_watchdog_shutdown_request(struct netxen_adapter *adapter)
 	u32 ctrl;
 
 	/* check if already inactive */
-	if (netxen_nic_hw_read_wx(adapter,
+	if (adapter->hw_read_wx(adapter,
 	    NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), &ctrl, 4))
 		printk(KERN_ERR "failed to read dma watchdog status\n");
 
@@ -1149,7 +1201,7 @@ dma_watchdog_shutdown_poll_result(struct netxen_adapter *adapter)
 {
 	u32 ctrl;
 
-	if (netxen_nic_hw_read_wx(adapter,
+	if (adapter->hw_read_wx(adapter,
 	    NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), &ctrl, 4))
 		printk(KERN_ERR "failed to read dma watchdog status\n");
 
@@ -1161,7 +1213,7 @@ dma_watchdog_wakeup(struct netxen_adapter *adapter)
 {
 	u32 ctrl;
 
-	if (netxen_nic_hw_read_wx(adapter,
+	if (adapter->hw_read_wx(adapter,
 		NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), &ctrl, 4))
 		printk(KERN_ERR "failed to read dma watchdog status\n");
 
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index cacc528..7e49e61 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -93,17 +93,21 @@ static void
 netxen_nic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
+	unsigned long flags;
 	u32 fw_major = 0;
 	u32 fw_minor = 0;
 	u32 fw_build = 0;
 
 	strncpy(drvinfo->driver, netxen_nic_driver_name, 32);
 	strncpy(drvinfo->version, NETXEN_NIC_LINUX_VERSIONID, 32);
-	fw_major = readl(NETXEN_CRB_NORMALIZE(adapter,
-					      NETXEN_FW_VERSION_MAJOR));
-	fw_minor = readl(NETXEN_CRB_NORMALIZE(adapter,
-					      NETXEN_FW_VERSION_MINOR));
-	fw_build = readl(NETXEN_CRB_NORMALIZE(adapter, NETXEN_FW_VERSION_SUB));
+	write_lock_irqsave(&adapter->adapter_lock, flags);
+	fw_major = adapter->pci_read_normalize(adapter,
+					NETXEN_FW_VERSION_MAJOR);
+	fw_minor = adapter->pci_read_normalize(adapter,
+					NETXEN_FW_VERSION_MINOR);
+	fw_build = adapter->pci_read_normalize(adapter,
+					NETXEN_FW_VERSION_SUB);
+	write_unlock_irqrestore(&adapter->adapter_lock, flags);
 	sprintf(drvinfo->fw_version, "%d.%d.%d", fw_major, fw_minor, fw_build);
 
 	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
@@ -361,19 +365,18 @@ netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
 	__u32 mode, *regs_buff = p;
-	void __iomem *addr;
 	int i, window;
 
 	memset(p, 0, NETXEN_NIC_REGS_LEN);
 	regs->version = (1 << 24) | (adapter->ahw.revision_id << 16) |
 	    (adapter->pdev)->device;
 	/* which mode */
-	NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_MODE, &regs_buff[0]);
+	adapter->hw_read_wx(adapter, NETXEN_NIU_MODE, &regs_buff[0], 4);
 	mode = regs_buff[0];
 
 	/* Common registers to all the modes */
-	NETXEN_NIC_LOCKED_READ_REG(NETXEN_NIU_STRAP_VALUE_SAVE_HIGHER,
-				   &regs_buff[2]);
+	adapter->hw_read_wx(adapter,
+			NETXEN_NIU_STRAP_VALUE_SAVE_HIGHER, &regs_buff[2], 4);
 	/* GB/XGB Mode */
 	mode = (mode / 2) - 1;
 	window = 0;
@@ -384,9 +387,9 @@ netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 				window = adapter->physical_port *
 					NETXEN_NIC_PORT_WINDOW;
 
-			NETXEN_NIC_LOCKED_READ_REG(niu_registers[mode].
-						   reg[i - 3] + window,
-						   &regs_buff[i]);
+			adapter->hw_read_wx(adapter,
+				niu_registers[mode].reg[i - 3] + window,
+				&regs_buff[i], 4);
 		}
 
 	}
@@ -410,7 +413,7 @@ static u32 netxen_nic_test_link(struct net_device *dev)
 			return !val;
 		}
 	} else if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
-		val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
+		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
 		return (val == XG_LINK_UP) ? 0 : 1;
 	}
 	return -EIO;
@@ -668,7 +671,7 @@ static int netxen_nic_reg_test(struct net_device *dev)
 	data_written = (u32)0xa5a5a5a5;
 
 	netxen_nic_reg_write(adapter, CRB_SCRATCHPAD_TEST, data_written);
-	data_read = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_SCRATCHPAD_TEST));
+	data_read = adapter->pci_read_normalize(adapter, CRB_SCRATCHPAD_TEST);
 	if (data_written != data_read)
 		return 1;
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index a472873..defbeea 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -38,6 +38,248 @@
 
 #include <net/ip.h>
 
+#define MASK(n) ((1ULL<<(n))-1)
+#define MN_WIN(addr) (((addr & 0x1fc0000) >> 1) | ((addr >> 25) & 0x3ff))
+#define OCM_WIN(addr) (((addr & 0x1ff0000) >> 1) | ((addr >> 25) & 0x3ff))
+#define MS_WIN(addr) (addr & 0x0ffc0000)
+
+#define GET_MEM_OFFS_2M(addr) (addr & MASK(18))
+
+#define CRB_BLK(off)	((off >> 20) & 0x3f)
+#define CRB_SUBBLK(off)	((off >> 16) & 0xf)
+#define CRB_WINDOW_2M	(0x130060)
+#define CRB_HI(off)	((crb_hub_agt[CRB_BLK(off)] << 20) | ((off) & 0xf0000))
+#define CRB_INDIRECT_2M	(0x1e0000UL)
+
+#define CRB_WIN_LOCK_TIMEOUT 100000000
+static crb_128M_2M_block_map_t crb_128M_2M_map[64] = {
+    {{{0, 0,         0,         0} } },		/* 0: PCI */
+    {{{1, 0x0100000, 0x0102000, 0x120000},	/* 1: PCIE */
+	  {1, 0x0110000, 0x0120000, 0x130000},
+	  {1, 0x0120000, 0x0122000, 0x124000},
+	  {1, 0x0130000, 0x0132000, 0x126000},
+	  {1, 0x0140000, 0x0142000, 0x128000},
+	  {1, 0x0150000, 0x0152000, 0x12a000},
+	  {1, 0x0160000, 0x0170000, 0x110000},
+	  {1, 0x0170000, 0x0172000, 0x12e000},
+	  {0, 0x0000000, 0x0000000, 0x000000},
+	  {0, 0x0000000, 0x0000000, 0x000000},
+	  {0, 0x0000000, 0x0000000, 0x000000},
+	  {0, 0x0000000, 0x0000000, 0x000000},
+	  {0, 0x0000000, 0x0000000, 0x000000},
+	  {0, 0x0000000, 0x0000000, 0x000000},
+	  {1, 0x01e0000, 0x01e0800, 0x122000},
+	  {0, 0x0000000, 0x0000000, 0x000000} } },
+	{{{1, 0x0200000, 0x0210000, 0x180000} } },/* 2: MN */
+    {{{0, 0,         0,         0} } },	    /* 3: */
+    {{{1, 0x0400000, 0x0401000, 0x169000} } },/* 4: P2NR1 */
+    {{{1, 0x0500000, 0x0510000, 0x140000} } },/* 5: SRE   */
+    {{{1, 0x0600000, 0x0610000, 0x1c0000} } },/* 6: NIU   */
+    {{{1, 0x0700000, 0x0704000, 0x1b8000} } },/* 7: QM    */
+    {{{1, 0x0800000, 0x0802000, 0x170000},  /* 8: SQM0  */
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {1, 0x08f0000, 0x08f2000, 0x172000} } },
+    {{{1, 0x0900000, 0x0902000, 0x174000},	/* 9: SQM1*/
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {1, 0x09f0000, 0x09f2000, 0x176000} } },
+    {{{0, 0x0a00000, 0x0a02000, 0x178000},	/* 10: SQM2*/
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {1, 0x0af0000, 0x0af2000, 0x17a000} } },
+    {{{0, 0x0b00000, 0x0b02000, 0x17c000},	/* 11: SQM3*/
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {0, 0x0000000, 0x0000000, 0x000000},
+      {1, 0x0bf0000, 0x0bf2000, 0x17e000} } },
+	{{{1, 0x0c00000, 0x0c04000, 0x1d4000} } },/* 12: I2Q */
+	{{{1, 0x0d00000, 0x0d04000, 0x1a4000} } },/* 13: TMR */
+	{{{1, 0x0e00000, 0x0e04000, 0x1a0000} } },/* 14: ROMUSB */
+	{{{1, 0x0f00000, 0x0f01000, 0x164000} } },/* 15: PEG4 */
+	{{{0, 0x1000000, 0x1004000, 0x1a8000} } },/* 16: XDMA */
+	{{{1, 0x1100000, 0x1101000, 0x160000} } },/* 17: PEG0 */
+	{{{1, 0x1200000, 0x1201000, 0x161000} } },/* 18: PEG1 */
+	{{{1, 0x1300000, 0x1301000, 0x162000} } },/* 19: PEG2 */
+	{{{1, 0x1400000, 0x1401000, 0x163000} } },/* 20: PEG3 */
+	{{{1, 0x1500000, 0x1501000, 0x165000} } },/* 21: P2ND */
+	{{{1, 0x1600000, 0x1601000, 0x166000} } },/* 22: P2NI */
+	{{{0, 0,         0,         0} } },	/* 23: */
+	{{{0, 0,         0,         0} } },	/* 24: */
+	{{{0, 0,         0,         0} } },	/* 25: */
+	{{{0, 0,         0,         0} } },	/* 26: */
+	{{{0, 0,         0,         0} } },	/* 27: */
+	{{{0, 0,         0,         0} } },	/* 28: */
+	{{{1, 0x1d00000, 0x1d10000, 0x190000} } },/* 29: MS */
+    {{{1, 0x1e00000, 0x1e01000, 0x16a000} } },/* 30: P2NR2 */
+    {{{1, 0x1f00000, 0x1f10000, 0x150000} } },/* 31: EPG */
+	{{{0} } },				/* 32: PCI */
+	{{{1, 0x2100000, 0x2102000, 0x120000},	/* 33: PCIE */
+	  {1, 0x2110000, 0x2120000, 0x130000},
+	  {1, 0x2120000, 0x2122000, 0x124000},
+	  {1, 0x2130000, 0x2132000, 0x126000},
+	  {1, 0x2140000, 0x2142000, 0x128000},
+	  {1, 0x2150000, 0x2152000, 0x12a000},
+	  {1, 0x2160000, 0x2170000, 0x110000},
+	  {1, 0x2170000, 0x2172000, 0x12e000},
+	  {0, 0x0000000, 0x0000000, 0x000000},
+	  {0, 0x0000000, 0x0000000, 0x000000},
+	  {0, 0x0000000, 0x0000000, 0x000000},
+	  {0, 0x0000000, 0x0000000, 0x000000},
+	  {0, 0x0000000, 0x0000000, 0x000000},
+	  {0, 0x0000000, 0x0000000, 0x000000},
+	  {0, 0x0000000, 0x0000000, 0x000000},
+	  {0, 0x0000000, 0x0000000, 0x000000} } },
+	{{{1, 0x2200000, 0x2204000, 0x1b0000} } },/* 34: CAM */
+	{{{0} } },				/* 35: */
+	{{{0} } },				/* 36: */
+	{{{0} } },				/* 37: */
+	{{{0} } },				/* 38: */
+	{{{0} } },				/* 39: */
+	{{{1, 0x2800000, 0x2804000, 0x1a4000} } },/* 40: TMR */
+	{{{1, 0x2900000, 0x2901000, 0x16b000} } },/* 41: P2NR3 */
+	{{{1, 0x2a00000, 0x2a00400, 0x1ac400} } },/* 42: RPMX1 */
+	{{{1, 0x2b00000, 0x2b00400, 0x1ac800} } },/* 43: RPMX2 */
+	{{{1, 0x2c00000, 0x2c00400, 0x1acc00} } },/* 44: RPMX3 */
+	{{{1, 0x2d00000, 0x2d00400, 0x1ad000} } },/* 45: RPMX4 */
+	{{{1, 0x2e00000, 0x2e00400, 0x1ad400} } },/* 46: RPMX5 */
+	{{{1, 0x2f00000, 0x2f00400, 0x1ad800} } },/* 47: RPMX6 */
+	{{{1, 0x3000000, 0x3000400, 0x1adc00} } },/* 48: RPMX7 */
+	{{{0, 0x3100000, 0x3104000, 0x1a8000} } },/* 49: XDMA */
+	{{{1, 0x3200000, 0x3204000, 0x1d4000} } },/* 50: I2Q */
+	{{{1, 0x3300000, 0x3304000, 0x1a0000} } },/* 51: ROMUSB */
+	{{{0} } },				/* 52: */
+	{{{1, 0x3500000, 0x3500400, 0x1ac000} } },/* 53: RPMX0 */
+	{{{1, 0x3600000, 0x3600400, 0x1ae000} } },/* 54: RPMX8 */
+	{{{1, 0x3700000, 0x3700400, 0x1ae400} } },/* 55: RPMX9 */
+	{{{1, 0x3800000, 0x3804000, 0x1d0000} } },/* 56: OCM0 */
+	{{{1, 0x3900000, 0x3904000, 0x1b4000} } },/* 57: CRYPTO */
+	{{{1, 0x3a00000, 0x3a04000, 0x1d8000} } },/* 58: SMB */
+	{{{0} } },				/* 59: I2C0 */
+	{{{0} } },				/* 60: I2C1 */
+	{{{1, 0x3d00000, 0x3d04000, 0x1d8000} } },/* 61: LPC */
+	{{{1, 0x3e00000, 0x3e01000, 0x167000} } },/* 62: P2NC */
+	{{{1, 0x3f00000, 0x3f01000, 0x168000} } }	/* 63: P2NR0 */
+};
+
+/*
+ * top 12 bits of crb internal address (hub, agent)
+ */
+static unsigned crb_hub_agt[64] =
+{
+	0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PS,
+	NETXEN_HW_CRB_HUB_AGT_ADR_MN,
+	NETXEN_HW_CRB_HUB_AGT_ADR_MS,
+	0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_SRE,
+	NETXEN_HW_CRB_HUB_AGT_ADR_NIU,
+	NETXEN_HW_CRB_HUB_AGT_ADR_QMN,
+	NETXEN_HW_CRB_HUB_AGT_ADR_SQN0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_SQN1,
+	NETXEN_HW_CRB_HUB_AGT_ADR_SQN2,
+	NETXEN_HW_CRB_HUB_AGT_ADR_SQN3,
+	NETXEN_HW_CRB_HUB_AGT_ADR_I2Q,
+	NETXEN_HW_CRB_HUB_AGT_ADR_TIMR,
+	NETXEN_HW_CRB_HUB_AGT_ADR_ROMUSB,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PGN4,
+	NETXEN_HW_CRB_HUB_AGT_ADR_XDMA,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PGN0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PGN1,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PGN2,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PGN3,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PGND,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PGNI,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PGS0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PGS1,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PGS2,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PGS3,
+	0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PGSI,
+	NETXEN_HW_CRB_HUB_AGT_ADR_SN,
+	0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_EG,
+	0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PS,
+	NETXEN_HW_CRB_HUB_AGT_ADR_CAM,
+	0,
+	0,
+	0,
+	0,
+	0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_TIMR,
+	0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_RPMX1,
+	NETXEN_HW_CRB_HUB_AGT_ADR_RPMX2,
+	NETXEN_HW_CRB_HUB_AGT_ADR_RPMX3,
+	NETXEN_HW_CRB_HUB_AGT_ADR_RPMX4,
+	NETXEN_HW_CRB_HUB_AGT_ADR_RPMX5,
+	NETXEN_HW_CRB_HUB_AGT_ADR_RPMX6,
+	NETXEN_HW_CRB_HUB_AGT_ADR_RPMX7,
+	NETXEN_HW_CRB_HUB_AGT_ADR_XDMA,
+	NETXEN_HW_CRB_HUB_AGT_ADR_I2Q,
+	NETXEN_HW_CRB_HUB_AGT_ADR_ROMUSB,
+	0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_RPMX0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_RPMX8,
+	NETXEN_HW_CRB_HUB_AGT_ADR_RPMX9,
+	NETXEN_HW_CRB_HUB_AGT_ADR_OCM0,
+	0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_SMB,
+	NETXEN_HW_CRB_HUB_AGT_ADR_I2C0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_I2C1,
+	0,
+	NETXEN_HW_CRB_HUB_AGT_ADR_PGNC,
+	0,
+};
+
 struct netxen_recv_crb recv_crb_registers[] = {
 	/*
 	 * Instance 0.
@@ -123,7 +365,7 @@ static u64 ctx_addr_sig_regs[][3] = {
 #define NETXEN_MIN_MTU		64
 #define NETXEN_ETH_FCS_SIZE     4
 #define NETXEN_ENET_HEADER_SIZE 14
-#define NETXEN_WINDOW_ONE 	0x2000000	/*CRB Window: bit 25 of CRB address */
+#define NETXEN_WINDOW_ONE 	0x2000000 /*CRB Window: bit 25 of CRB address */
 #define NETXEN_FIRMWARE_LEN 	((16 * 1024) / 4)
 #define NETXEN_NIU_HDRSIZE	(0x1 << 6)
 #define NETXEN_NIU_TLRSIZE	(0x1 << 5)
@@ -139,8 +381,6 @@ static u64 ctx_addr_sig_regs[][3] = {
 
 #define NETXEN_NIC_WINDOW_MARGIN 0x100000
 
-static unsigned long netxen_nic_pci_set_window(struct netxen_adapter *adapter,
-					       unsigned long long addr);
 void netxen_free_hw_resources(struct netxen_adapter *adapter);
 
 int netxen_nic_set_mac(struct net_device *netdev, void *p)
@@ -181,9 +421,9 @@ netxen_nic_enable_mcast_filter(struct netxen_adapter *adapter)
 	if (adapter->mc_enabled)
 		return 0;
 
-	netxen_nic_hw_read_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
+	adapter->hw_read_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
 	val |= (1UL << (28+port));
-	netxen_nic_hw_write_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
+	adapter->hw_write_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
 
 	/* add broadcast addr to filter */
 	val = 0xffffff;
@@ -212,9 +452,9 @@ netxen_nic_disable_mcast_filter(struct netxen_adapter *adapter)
 	if (!adapter->mc_enabled)
 		return 0;
 
-	netxen_nic_hw_read_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
+	adapter->hw_read_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
 	val &= ~(1UL << (28+port));
-	netxen_nic_hw_write_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
+	adapter->hw_write_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
 
 	val = MAC_HI(addr);
 	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port, 0), val);
@@ -344,18 +584,15 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 
 
 	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
-		DPRINTK(INFO, "Command Peg ready..waiting for rcv peg\n");
 		loops = 0;
 		state = 0;
-		/* Window 1 call */
-		state = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_RCVPEG_STATE));
-		while (state != PHAN_PEG_RCV_INITIALIZED && loops < 20) {
-			msleep(1);
+		do {
 			/* Window 1 call */
-			state = readl(NETXEN_CRB_NORMALIZE(adapter,
-					CRB_RCVPEG_STATE));
+			state = adapter->pci_read_normalize(adapter,
+					CRB_RCVPEG_STATE);
+			msleep(1);
 			loops++;
-		}
+		} while (state != PHAN_PEG_RCV_INITIALIZED && loops < 20);
 		if (loops >= 20) {
 			printk(KERN_ERR "Rcv Peg initialization not complete:"
 			       "%x.\n", state);
@@ -363,10 +600,10 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 			return err;
 		}
 	}
-	adapter->intr_scheme = readl(
-		NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_FW));
-	adapter->msi_mode = readl(
-		NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_MSI_MODE_FW));
+	adapter->intr_scheme = adapter->pci_read_normalize(adapter,
+			CRB_NIC_CAPABILITIES_FW);
+	adapter->msi_mode = adapter->pci_read_normalize(adapter,
+			CRB_NIC_MSI_MODE_FW);
 
 	addr = pci_alloc_consistent(adapter->pdev,
 			    sizeof(struct netxen_ring_ctx) + sizeof(uint32_t),
@@ -449,12 +686,12 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 	}
 	/* Window = 1 */
 
-	writel(lower32(adapter->ctx_desc_phys_addr),
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_ADDR_REG_LO(func_id)));
-	writel(upper32(adapter->ctx_desc_phys_addr),
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_ADDR_REG_HI(func_id)));
-	writel(NETXEN_CTX_SIGNATURE | func_id,
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_SIGNATURE_REG(func_id)));
+	adapter->pci_write_normalize(adapter, CRB_CTX_ADDR_REG_LO(func_id),
+			lower32(adapter->ctx_desc_phys_addr));
+	adapter->pci_write_normalize(adapter, CRB_CTX_ADDR_REG_HI(func_id),
+			upper32(adapter->ctx_desc_phys_addr));
+	adapter->pci_write_normalize(adapter, CRB_CTX_SIGNATURE_REG(func_id),
+			NETXEN_CTX_SIGNATURE | func_id);
 	return err;
 }
 
@@ -601,10 +838,41 @@ int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 mac[])
 	return 0;
 }
 
+#define CRB_WIN_LOCK_TIMEOUT 100000000
+
+static int crb_win_lock(struct netxen_adapter *adapter)
+{
+	int done = 0, timeout = 0;
+
+	while (!done) {
+		/* acquire semaphore3 from PCI HW block */
+		adapter->hw_read_wx(adapter,
+				NETXEN_PCIE_REG(PCIE_SEM7_LOCK), &done, 4);
+		if (done == 1)
+			break;
+		if (timeout >= CRB_WIN_LOCK_TIMEOUT)
+			return -1;
+		timeout++;
+		udelay(1);
+	}
+	netxen_crb_writelit_adapter(adapter,
+			NETXEN_CRB_WIN_LOCK_ID, adapter->portnum);
+	return 0;
+}
+
+static void crb_win_unlock(struct netxen_adapter *adapter)
+{
+	int val;
+
+	adapter->hw_read_wx(adapter,
+			NETXEN_PCIE_REG(PCIE_SEM7_UNLOCK), &val, 4);
+}
+
 /*
  * Changes the CRB window to the specified window.
  */
-void netxen_nic_pci_change_crbwindow(struct netxen_adapter *adapter, u32 wndw)
+void
+netxen_nic_pci_change_crbwindow_128M(struct netxen_adapter *adapter, u32 wndw)
 {
 	void __iomem *offset;
 	u32 tmp;
@@ -633,7 +901,7 @@ void netxen_nic_pci_change_crbwindow(struct netxen_adapter *adapter, u32 wndw)
 	while ((tmp = readl(offset)) != wndw) {
 		printk(KERN_WARNING "%s: %s WARNING: CRB window value not "
 		       "registered properly: 0x%08x.\n",
-		       netxen_nic_driver_name, __FUNCTION__, tmp);
+		       netxen_nic_driver_name, __func__, tmp);
 		mdelay(1);
 		if (count >= 10)
 			break;
@@ -646,51 +914,112 @@ void netxen_nic_pci_change_crbwindow(struct netxen_adapter *adapter, u32 wndw)
 		adapter->curr_window = 0;
 }
 
+/*
+ * Return -1 if off is not valid,
+ *	 1 if window access is needed. 'off' is set to offset from
+ *	   CRB space in 128M pci map
+ *	 0 if no window access is needed. 'off' is set to 2M addr
+ * In: 'off' is offset from base in 128M pci map
+ */
+static int
+netxen_nic_pci_get_crb_addr_2M(struct netxen_adapter *adapter,
+		ulong *off, int len)
+{
+	unsigned long end = *off + len;
+	crb_128M_2M_sub_block_map_t *m;
+
+
+	if (*off >= NETXEN_CRB_MAX)
+		return -1;
+
+	if (*off >= NETXEN_PCI_CAMQM && (end <= NETXEN_PCI_CAMQM_2M_END)) {
+		*off = (*off - NETXEN_PCI_CAMQM) + NETXEN_PCI_CAMQM_2M_BASE +
+			(ulong)adapter->ahw.pci_base0;
+		return 0;
+	}
+
+	if (*off < NETXEN_PCI_CRBSPACE)
+		return -1;
+
+	*off -= NETXEN_PCI_CRBSPACE;
+	end = *off + len;
+
+	/*
+	 * Try direct map
+	 */
+	m = &crb_128M_2M_map[CRB_BLK(*off)].sub_block[CRB_SUBBLK(*off)];
+
+	if (m->valid && (m->start_128M <= *off) && (m->end_128M >= end)) {
+		*off = *off + m->start_2M - m->start_128M +
+			(ulong)adapter->ahw.pci_base0;
+		return 0;
+	}
+
+	/*
+	 * Not in direct map, use crb window
+	 */
+	return 1;
+}
+
+/*
+ * In: 'off' is offset from CRB space in 128M pci map
+ * Out: 'off' is 2M pci map addr
+ * side effect: lock crb window
+ */
+static void
+netxen_nic_pci_set_crbwindow_2M(struct netxen_adapter *adapter, ulong *off)
+{
+	u32 win_read;
+
+	adapter->crb_win = CRB_HI(*off);
+	writel(adapter->crb_win, (void *)(CRB_WINDOW_2M +
+		adapter->ahw.pci_base0));
+	/*
+	 * Read back value to make sure write has gone through before trying
+	 * to use it.
+	 */
+	win_read = readl((void *)(CRB_WINDOW_2M + adapter->ahw.pci_base0));
+	if (win_read != adapter->crb_win) {
+		printk(KERN_ERR "%s: Written crbwin (0x%x) != "
+				"Read crbwin (0x%x), off=0x%lx\n",
+				__func__, adapter->crb_win, win_read, *off);
+	}
+	*off = (*off & MASK(16)) + CRB_INDIRECT_2M +
+		(ulong)adapter->ahw.pci_base0;
+}
+
 int netxen_load_firmware(struct netxen_adapter *adapter)
 {
 	int i;
 	u32 data, size = 0;
 	u32 flashaddr = NETXEN_FLASH_BASE, memaddr = NETXEN_PHANTOM_MEM_BASE;
-	u64 off;
-	void __iomem *addr;
 
 	size = NETXEN_FIRMWARE_LEN;
-	writel(1, NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CAS_RST));
+	adapter->pci_write_normalize(adapter,
+				NETXEN_ROMUSB_GLB_CAS_RST, 1);
 
 	for (i = 0; i < size; i++) {
-		int retries = 10;
 		if (netxen_rom_fast_read(adapter, flashaddr, (int *)&data) != 0)
 			return -EIO;
 
-		off = netxen_nic_pci_set_window(adapter, memaddr);
-		addr = pci_base_offset(adapter, off);
-		writel(data, addr);
-		do {
-			if (readl(addr) == data)
-				break;
-			msleep(100);
-			writel(data, addr);
-		} while (--retries);
-		if (!retries) {
-			printk(KERN_ERR "%s: firmware load aborted, write failed at 0x%x\n",
-					netxen_nic_driver_name, memaddr);
-			return -EIO;
-		}
+		adapter->pci_mem_write(adapter, memaddr, &data, 4);
 		flashaddr += 4;
 		memaddr += 4;
+		cond_resched();
 	}
 	udelay(100);
 	/* make sure Casper is powered on */
-	writel(0x3fff,
-	       NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CHIP_CLK_CTRL));
-	writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CAS_RST));
+	adapter->pci_write_normalize(adapter,
+				NETXEN_ROMUSB_GLB_CHIP_CLK_CTRL, 0x3fff);
+	adapter->pci_write_normalize(adapter,
+				NETXEN_ROMUSB_GLB_CAS_RST, 0);
 
 	return 0;
 }
 
 int
-netxen_nic_hw_write_wx(struct netxen_adapter *adapter, u64 off, void *data,
-		       int len)
+netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter,
+		ulong off, void *data, int len)
 {
 	void __iomem *addr;
 
@@ -698,7 +1027,7 @@ netxen_nic_hw_write_wx(struct netxen_adapter *adapter, u64 off, void *data,
 		addr = NETXEN_CRB_NORMALIZE(adapter, off);
 	} else {		/* Window 0 */
 		addr = pci_base_offset(adapter, off);
-		netxen_nic_pci_change_crbwindow(adapter, 0);
+		netxen_nic_pci_change_crbwindow_128M(adapter, 0);
 	}
 
 	DPRINTK(INFO, "writing to base %lx offset %llx addr %p"
@@ -706,7 +1035,7 @@ netxen_nic_hw_write_wx(struct netxen_adapter *adapter, u64 off, void *data,
 		pci_base(adapter, off), off, addr,
 		*(unsigned long long *)data, len);
 	if (!addr) {
-		netxen_nic_pci_change_crbwindow(adapter, 1);
+		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
 		return 1;
 	}
 
@@ -733,14 +1062,14 @@ netxen_nic_hw_write_wx(struct netxen_adapter *adapter, u64 off, void *data,
 		break;
 	}
 	if (!ADDR_IN_WINDOW1(off))
-		netxen_nic_pci_change_crbwindow(adapter, 1);
+		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
 
 	return 0;
 }
 
 int
-netxen_nic_hw_read_wx(struct netxen_adapter *adapter, u64 off, void *data,
-		      int len)
+netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter,
+		ulong off, void *data, int len)
 {
 	void __iomem *addr;
 
@@ -748,13 +1077,13 @@ netxen_nic_hw_read_wx(struct netxen_adapter *adapter, u64 off, void *data,
 		addr = NETXEN_CRB_NORMALIZE(adapter, off);
 	} else {		/* Window 0 */
 		addr = pci_base_offset(adapter, off);
-		netxen_nic_pci_change_crbwindow(adapter, 0);
+		netxen_nic_pci_change_crbwindow_128M(adapter, 0);
 	}
 
 	DPRINTK(INFO, "reading from base %lx offset %llx addr %p\n",
 		pci_base(adapter, off), off, addr);
 	if (!addr) {
-		netxen_nic_pci_change_crbwindow(adapter, 1);
+		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
 		return 1;
 	}
 	switch (len) {
@@ -778,76 +1107,190 @@ netxen_nic_hw_read_wx(struct netxen_adapter *adapter, u64 off, void *data,
 	DPRINTK(INFO, "read %lx\n", *(unsigned long *)data);
 
 	if (!ADDR_IN_WINDOW1(off))
-		netxen_nic_pci_change_crbwindow(adapter, 1);
+		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
 
 	return 0;
 }
 
-void netxen_nic_reg_write(struct netxen_adapter *adapter, u64 off, u32 val)
-{				/* Only for window 1 */
-	void __iomem *addr;
+int
+netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter,
+		ulong off, void *data, int len)
+{
+	unsigned long flags = 0;
+	int rv;
 
-	addr = NETXEN_CRB_NORMALIZE(adapter, off);
-	DPRINTK(INFO, "writing to base %lx offset %llx addr %p data %x\n",
-		pci_base(adapter, off), off, addr, val);
-	writel(val, addr);
+	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off, len);
 
+	if (rv == -1) {
+		printk(KERN_ERR "%s: invalid offset: 0x%016lx\n",
+				__func__, off);
+		dump_stack();
+		return -1;
+	}
+
+	if (rv == 1) {
+		write_lock_irqsave(&adapter->adapter_lock, flags);
+		crb_win_lock(adapter);
+		netxen_nic_pci_set_crbwindow_2M(adapter, &off);
+	}
+
+	DPRINTK(1, INFO, "write data %lx to offset %llx, len=%d\n",
+			*(unsigned long *)data, off, len);
+
+	switch (len) {
+	case 1:
+		writeb(*(uint8_t *)data, (void *)off);
+		break;
+	case 2:
+		writew(*(uint16_t *)data, (void *)off);
+		break;
+	case 4:
+		writel(*(uint32_t *)data, (void *)off);
+		break;
+	case 8:
+		writeq(*(uint64_t *)data, (void *)off);
+		break;
+	default:
+		DPRINTK(1, INFO,
+			"writing data %lx to offset %llx, num words=%d\n",
+			*(unsigned long *)data, off, (len>>3));
+		break;
+	}
+	if (rv == 1) {
+		crb_win_unlock(adapter);
+		write_unlock_irqrestore(&adapter->adapter_lock, flags);
+	}
+
+	return 0;
 }
 
-int netxen_nic_reg_read(struct netxen_adapter *adapter, u64 off)
-{				/* Only for window 1 */
-	void __iomem *addr;
-	int val;
+int
+netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter,
+		ulong off, void *data, int len)
+{
+	unsigned long flags = 0;
+	int rv;
 
-	addr = NETXEN_CRB_NORMALIZE(adapter, off);
-	DPRINTK(INFO, "reading from base %lx offset %llx addr %p\n",
-		pci_base(adapter, off), off, addr);
-	val = readl(addr);
-	writel(val, addr);
+	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off, len);
+
+	if (rv == -1) {
+		printk(KERN_ERR "%s: invalid offset: 0x%016lx\n",
+				__func__, off);
+		dump_stack();
+		return -1;
+	}
+
+	if (rv == 1) {
+		write_lock_irqsave(&adapter->adapter_lock, flags);
+		crb_win_lock(adapter);
+		netxen_nic_pci_set_crbwindow_2M(adapter, &off);
+	}
+
+	DPRINTK(1, INFO, "read from offset %lx, len=%d\n", off, len);
+
+	switch (len) {
+	case 1:
+		*(uint8_t *)data = readb((void *)off);
+		break;
+	case 2:
+		*(uint16_t *)data = readw((void *)off);
+		break;
+	case 4:
+		*(uint32_t *)data = readl((void *)off);
+		break;
+	case 8:
+		*(uint64_t *)data = readq((void *)off);
+		break;
+	default:
+		break;
+	}
+
+	DPRINTK(1, INFO, "read %lx\n", *(unsigned long *)data);
 
+	if (rv == 1) {
+		crb_win_unlock(adapter);
+		write_unlock_irqrestore(&adapter->adapter_lock, flags);
+	}
+
+	return 0;
+}
+
+void netxen_nic_reg_write(struct netxen_adapter *adapter, u64 off, u32 val)
+{
+	adapter->hw_write_wx(adapter, off, &val, 4);
+}
+
+int netxen_nic_reg_read(struct netxen_adapter *adapter, u64 off)
+{
+	int val;
+	adapter->hw_read_wx(adapter, off, &val, 4);
 	return val;
 }
 
 /* Change the window to 0, write and change back to window 1. */
 void netxen_nic_write_w0(struct netxen_adapter *adapter, u32 index, u32 value)
 {
-	void __iomem *addr;
-
-	netxen_nic_pci_change_crbwindow(adapter, 0);
-	addr = pci_base_offset(adapter, index);
-	writel(value, addr);
-	netxen_nic_pci_change_crbwindow(adapter, 1);
+	adapter->hw_write_wx(adapter, index, &value, 4);
 }
 
 /* Change the window to 0, read and change back to window 1. */
-void netxen_nic_read_w0(struct netxen_adapter *adapter, u32 index, u32 * value)
+void netxen_nic_read_w0(struct netxen_adapter *adapter, u32 index, u32 *value)
 {
-	void __iomem *addr;
+	adapter->hw_read_wx(adapter, index, value, 4);
+}
 
-	addr = pci_base_offset(adapter, index);
+void netxen_nic_write_w1(struct netxen_adapter *adapter, u32 index, u32 value)
+{
+	adapter->hw_write_wx(adapter, index, &value, 4);
+}
+
+void netxen_nic_read_w1(struct netxen_adapter *adapter, u32 index, u32 *value)
+{
+	adapter->hw_read_wx(adapter, index, value, 4);
+}
+
+/*
+ * check memory access boundary.
+ * used by test agent. support ddr access only for now
+ */
+static unsigned long
+netxen_nic_pci_mem_bound_check(struct netxen_adapter *adapter,
+		unsigned long long addr, int size)
+{
+	if (!ADDR_IN_RANGE(addr,
+			NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX) ||
+		!ADDR_IN_RANGE(addr+size-1,
+			NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX) ||
+		((size != 1) && (size != 2) && (size != 4) && (size != 8))) {
+		return 0;
+	}
 
-	netxen_nic_pci_change_crbwindow(adapter, 0);
-	*value = readl(addr);
-	netxen_nic_pci_change_crbwindow(adapter, 1);
+	return 1;
 }
 
 static int netxen_pci_set_window_warning_count;
 
-static  unsigned long netxen_nic_pci_set_window(struct netxen_adapter *adapter,
-						unsigned long long addr)
+unsigned long
+netxen_nic_pci_set_window_128M(struct netxen_adapter *adapter,
+		unsigned long long addr)
 {
 	void __iomem *offset;
-	static int ddr_mn_window = -1;
-	static int qdr_sn_window = -1;
 	int window;
+	unsigned long long	qdr_max;
 	uint8_t func = adapter->ahw.pci_func;
 
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+		qdr_max = NETXEN_ADDR_QDR_NET_MAX_P2;
+	} else {
+		qdr_max = NETXEN_ADDR_QDR_NET_MAX_P3;
+	}
+
 	if (ADDR_IN_RANGE(addr, NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX)) {
 		/* DDR network side */
 		addr -= NETXEN_ADDR_DDR_NET;
 		window = (addr >> 25) & 0x3ff;
-		if (ddr_mn_window != window) {
-			ddr_mn_window = window;
+		if (adapter->ahw.ddr_mn_window != window) {
+			adapter->ahw.ddr_mn_window = window;
 			offset = PCI_OFFSET_SECOND_RANGE(adapter,
 				NETXEN_PCIX_PH_REG(PCIE_MN_WINDOW_REG(func)));
 			writel(window, offset);
@@ -862,14 +1305,12 @@ static  unsigned long netxen_nic_pci_set_window(struct netxen_adapter *adapter,
 	} else if (ADDR_IN_RANGE(addr, NETXEN_ADDR_OCM1, NETXEN_ADDR_OCM1_MAX)) {
 		addr -= NETXEN_ADDR_OCM1;
 		addr += NETXEN_PCI_OCM1;
-	} else
-	    if (ADDR_IN_RANGE
-		(addr, NETXEN_ADDR_QDR_NET, NETXEN_ADDR_QDR_NET_MAX_P2)) {
+	} else if (ADDR_IN_RANGE(addr, NETXEN_ADDR_QDR_NET, qdr_max)) {
 		/* QDR network side */
 		addr -= NETXEN_ADDR_QDR_NET;
 		window = (addr >> 22) & 0x3f;
-		if (qdr_sn_window != window) {
-			qdr_sn_window = window;
+		if (adapter->ahw.qdr_sn_window != window) {
+			adapter->ahw.qdr_sn_window = window;
 			offset = PCI_OFFSET_SECOND_RANGE(adapter,
 				NETXEN_PCIX_PH_REG(PCIE_SN_WINDOW_REG(func)));
 			writel((window << 22), offset);
@@ -888,11 +1329,711 @@ static  unsigned long netxen_nic_pci_set_window(struct netxen_adapter *adapter,
 			printk("%s: Warning:netxen_nic_pci_set_window()"
 			       " Unknown address range!\n",
 			       netxen_nic_driver_name);
+		addr = -1UL;
+	}
+	return addr;
+}
+
+/*
+ * Note : only 32-bit writes!
+ */
+int netxen_nic_pci_write_immediate_128M(struct netxen_adapter *adapter,
+		u64 off, u32 data)
+{
+	writel(data, (void __iomem *)(PCI_OFFSET_SECOND_RANGE(adapter, off)));
+	return 0;
+}
+
+u32 netxen_nic_pci_read_immediate_128M(struct netxen_adapter *adapter, u64 off)
+{
+	return readl((void __iomem *)(pci_base_offset(adapter, off)));
+}
+
+void netxen_nic_pci_write_normalize_128M(struct netxen_adapter *adapter,
+		u64 off, u32 data)
+{
+	writel(data, NETXEN_CRB_NORMALIZE(adapter, off));
+}
+
+u32 netxen_nic_pci_read_normalize_128M(struct netxen_adapter *adapter, u64 off)
+{
+	return readl(NETXEN_CRB_NORMALIZE(adapter, off));
+}
+
+unsigned long
+netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
+		unsigned long long addr)
+{
+	int window;
+	u32 win_read;
 
+	if (ADDR_IN_RANGE(addr, NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX)) {
+		/* DDR network side */
+		window = MN_WIN(addr);
+		adapter->ahw.ddr_mn_window = window;
+		adapter->hw_write_wx(adapter,
+				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
+				&window, 4);
+		adapter->hw_read_wx(adapter,
+				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
+				&win_read, 4);
+		if ((win_read << 17) != window) {
+			printk(KERN_INFO "Written MNwin (0x%x) != "
+				"Read MNwin (0x%x)\n", window, win_read);
+		}
+		addr = GET_MEM_OFFS_2M(addr) + NETXEN_PCI_DDR_NET;
+	} else if (ADDR_IN_RANGE(addr,
+				NETXEN_ADDR_OCM0, NETXEN_ADDR_OCM0_MAX)) {
+		if ((addr & 0x00ff800) == 0xff800) {
+			printk("%s: QM access not handled.\n", __func__);
+			addr = -1UL;
+		}
+
+		window = OCM_WIN(addr);
+		adapter->ahw.ddr_mn_window = window;
+		adapter->hw_write_wx(adapter,
+				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
+				&window, 4);
+		adapter->hw_read_wx(adapter,
+				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
+				&win_read, 4);
+		if ((win_read >> 7) != window) {
+			printk(KERN_INFO "%s: Written OCMwin (0x%x) != "
+					"Read OCMwin (0x%x)\n",
+					__func__, window, win_read);
+		}
+		addr = GET_MEM_OFFS_2M(addr) + NETXEN_PCI_OCM0_2M;
+
+	} else if (ADDR_IN_RANGE(addr,
+			NETXEN_ADDR_QDR_NET, NETXEN_ADDR_QDR_NET_MAX_P3)) {
+		/* QDR network side */
+		window = MS_WIN(addr);
+		adapter->ahw.qdr_sn_window = window;
+		adapter->hw_write_wx(adapter,
+				adapter->ahw.ms_win_crb | NETXEN_PCI_CRBSPACE,
+				&window, 4);
+		adapter->hw_read_wx(adapter,
+				adapter->ahw.ms_win_crb | NETXEN_PCI_CRBSPACE,
+				&win_read, 4);
+		if (win_read != window) {
+			printk(KERN_INFO "%s: Written MSwin (0x%x) != "
+					"Read MSwin (0x%x)\n",
+					__func__, window, win_read);
+		}
+		addr = GET_MEM_OFFS_2M(addr) + NETXEN_PCI_QDR_NET;
+
+	} else {
+		/*
+		 * peg gdb frequently accesses memory that doesn't exist,
+		 * this limits the chit chat so debugging isn't slowed down.
+		 */
+		if ((netxen_pci_set_window_warning_count++ < 8)
+			|| (netxen_pci_set_window_warning_count%64 == 0)) {
+			printk("%s: Warning:%s Unknown address range!\n",
+					__func__, netxen_nic_driver_name);
+}
+		addr = -1UL;
 	}
 	return addr;
 }
 
+static int netxen_nic_pci_is_same_window(struct netxen_adapter *adapter,
+				      unsigned long long addr)
+{
+	int window;
+	unsigned long long qdr_max;
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		qdr_max = NETXEN_ADDR_QDR_NET_MAX_P2;
+	else
+		qdr_max = NETXEN_ADDR_QDR_NET_MAX_P3;
+
+	if (ADDR_IN_RANGE(addr,
+			NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX)) {
+		/* DDR network side */
+		BUG();	/* MN access can not come here */
+	} else if (ADDR_IN_RANGE(addr,
+			NETXEN_ADDR_OCM0, NETXEN_ADDR_OCM0_MAX)) {
+		return 1;
+	} else if (ADDR_IN_RANGE(addr,
+				NETXEN_ADDR_OCM1, NETXEN_ADDR_OCM1_MAX)) {
+		return 1;
+	} else if (ADDR_IN_RANGE(addr, NETXEN_ADDR_QDR_NET, qdr_max)) {
+		/* QDR network side */
+		window = ((addr - NETXEN_ADDR_QDR_NET) >> 22) & 0x3f;
+		if (adapter->ahw.qdr_sn_window == window)
+			return 1;
+	}
+
+	return 0;
+}
+
+static int netxen_nic_pci_mem_read_direct(struct netxen_adapter *adapter,
+			u64 off, void *data, int size)
+{
+	unsigned long flags;
+	void *addr;
+	int ret = 0;
+	u64 start;
+	uint8_t *mem_ptr = NULL;
+	unsigned long mem_base;
+	unsigned long mem_page;
+
+	write_lock_irqsave(&adapter->adapter_lock, flags);
+
+	/*
+	 * If attempting to access unknown address or straddle hw windows,
+	 * do not access.
+	 */
+	start = adapter->pci_set_window(adapter, off);
+	if ((start == -1UL) ||
+		(netxen_nic_pci_is_same_window(adapter, off+size-1) == 0)) {
+		write_unlock_irqrestore(&adapter->adapter_lock, flags);
+		printk(KERN_ERR "%s out of bound pci memory access. "
+			"offset is 0x%llx\n", netxen_nic_driver_name, off);
+		return -1;
+	}
+
+	addr = (void *)(pci_base_offset(adapter, start));
+	if (!addr) {
+		write_unlock_irqrestore(&adapter->adapter_lock, flags);
+		mem_base = pci_resource_start(adapter->pdev, 0);
+		mem_page = start & PAGE_MASK;
+		/* Map two pages whenever user tries to access addresses in two
+		consecutive pages.
+		*/
+		if (mem_page != ((start + size - 1) & PAGE_MASK))
+			mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE * 2);
+		else
+			mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE);
+		if (mem_ptr == 0UL) {
+			*(uint8_t  *)data = 0;
+			return -1;
+		}
+		addr = mem_ptr;
+		addr += start & (PAGE_SIZE - 1);
+		write_lock_irqsave(&adapter->adapter_lock, flags);
+	}
+
+	switch (size) {
+	case 1:
+		*(uint8_t  *)data = readb(addr);
+		break;
+	case 2:
+		*(uint16_t *)data = readw(addr);
+		break;
+	case 4:
+		*(uint32_t *)data = readl(addr);
+		break;
+	case 8:
+		*(uint64_t *)data = readq(addr);
+		break;
+	default:
+		ret = -1;
+		break;
+	}
+	write_unlock_irqrestore(&adapter->adapter_lock, flags);
+	DPRINTK(1, INFO, "read %llx\n", *(unsigned long long *)data);
+
+	if (mem_ptr)
+		iounmap(mem_ptr);
+	return ret;
+}
+
+static int
+netxen_nic_pci_mem_write_direct(struct netxen_adapter *adapter, u64 off,
+		void *data, int size)
+{
+	unsigned long flags;
+	void *addr;
+	int ret = 0;
+	u64 start;
+	uint8_t *mem_ptr = NULL;
+	unsigned long mem_base;
+	unsigned long mem_page;
+
+	write_lock_irqsave(&adapter->adapter_lock, flags);
+
+	/*
+	 * If attempting to access unknown address or straddle hw windows,
+	 * do not access.
+	 */
+	start = adapter->pci_set_window(adapter, off);
+	if ((start == -1UL) ||
+		(netxen_nic_pci_is_same_window(adapter, off+size-1) == 0)) {
+		write_unlock_irqrestore(&adapter->adapter_lock, flags);
+		printk(KERN_ERR "%s out of bound pci memory access. "
+			"offset is 0x%llx\n", netxen_nic_driver_name, off);
+		return -1;
+	}
+
+	addr = (void *)(pci_base_offset(adapter, start));
+	if (!addr) {
+		write_unlock_irqrestore(&adapter->adapter_lock, flags);
+		mem_base = pci_resource_start(adapter->pdev, 0);
+		mem_page = start & PAGE_MASK;
+		/* Map two pages whenever user tries to access addresses in two
+		 * consecutive pages.
+		 */
+		if (mem_page != ((start + size - 1) & PAGE_MASK))
+			mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE*2);
+		else
+			mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE);
+		if (mem_ptr == 0UL)
+			return -1;
+		addr = mem_ptr;
+		addr += start & (PAGE_SIZE - 1);
+		write_lock_irqsave(&adapter->adapter_lock, flags);
+	}
+
+	switch (size) {
+	case 1:
+		writeb(*(uint8_t *)data, addr);
+		break;
+	case 2:
+		writew(*(uint16_t *)data, addr);
+		break;
+	case 4:
+		writel(*(uint32_t *)data, addr);
+		break;
+	case 8:
+		writeq(*(uint64_t *)data, addr);
+		break;
+	default:
+		ret = -1;
+		break;
+	}
+	write_unlock_irqrestore(&adapter->adapter_lock, flags);
+	DPRINTK(1, INFO, "writing data %llx to offset %llx\n",
+			*(unsigned long long *)data, start);
+	if (mem_ptr)
+		iounmap(mem_ptr);
+	return ret;
+}
+
+#define MAX_CTL_CHECK   1000
+
+int
+netxen_nic_pci_mem_write_128M(struct netxen_adapter *adapter,
+		u64 off, void *data, int size)
+{
+	unsigned long   flags, mem_crb;
+	int	     i, j, ret = 0, loop, sz[2], off0;
+	uint32_t      temp;
+	uint64_t      off8, tmpw, word[2] = {0, 0};
+
+	/*
+	 * If not MN, go check for MS or invalid.
+	 */
+	if (netxen_nic_pci_mem_bound_check(adapter, off, size) == 0)
+		return netxen_nic_pci_mem_write_direct(adapter,
+				off, data, size);
+
+	off8 = off & 0xfffffff8;
+	off0 = off & 0x7;
+	sz[0] = (size < (8 - off0)) ? size : (8 - off0);
+	sz[1] = size - sz[0];
+	loop = ((off0 + size - 1) >> 3) + 1;
+	mem_crb = (unsigned long)pci_base_offset(adapter, NETXEN_CRB_DDR_NET);
+
+	if ((size != 8) || (off0 != 0))  {
+		for (i = 0; i < loop; i++) {
+			if (adapter->pci_mem_read(adapter,
+				off8 + (i << 3), &word[i], 8))
+				return -1;
+		}
+	}
+
+	switch (size) {
+	case 1:
+		tmpw = *((uint8_t *)data);
+		break;
+	case 2:
+		tmpw = *((uint16_t *)data);
+		break;
+	case 4:
+		tmpw = *((uint32_t *)data);
+		break;
+	case 8:
+	default:
+		tmpw = *((uint64_t *)data);
+		break;
+	}
+	word[0] &= ~((~(~0ULL << (sz[0] * 8))) << (off0 * 8));
+	word[0] |= tmpw << (off0 * 8);
+
+	if (loop == 2) {
+		word[1] &= ~(~0ULL << (sz[1] * 8));
+		word[1] |= tmpw >> (sz[0] * 8);
+	}
+
+	write_lock_irqsave(&adapter->adapter_lock, flags);
+	netxen_nic_pci_change_crbwindow_128M(adapter, 0);
+
+	for (i = 0; i < loop; i++) {
+		writel((uint32_t)(off8 + (i << 3)),
+			(void *)(mem_crb+MIU_TEST_AGT_ADDR_LO));
+		writel(0,
+			(void *)(mem_crb+MIU_TEST_AGT_ADDR_HI));
+		writel(word[i] & 0xffffffff,
+			(void *)(mem_crb+MIU_TEST_AGT_WRDATA_LO));
+		writel((word[i] >> 32) & 0xffffffff,
+			(void *)(mem_crb+MIU_TEST_AGT_WRDATA_HI));
+		writel(MIU_TA_CTL_ENABLE|MIU_TA_CTL_WRITE,
+			(void *)(mem_crb+MIU_TEST_AGT_CTRL));
+		writel(MIU_TA_CTL_START|MIU_TA_CTL_ENABLE|MIU_TA_CTL_WRITE,
+			(void *)(mem_crb+MIU_TEST_AGT_CTRL));
+
+		for (j = 0; j < MAX_CTL_CHECK; j++) {
+			temp = readl(
+			     (void *)(mem_crb+MIU_TEST_AGT_CTRL));
+			if ((temp & MIU_TA_CTL_BUSY) == 0)
+				break;
+		}
+
+		if (j >= MAX_CTL_CHECK) {
+			printk("%s: %s Fail to write through agent\n",
+					__func__, netxen_nic_driver_name);
+			ret = -1;
+			break;
+		}
+	}
+
+	netxen_nic_pci_change_crbwindow_128M(adapter, 1);
+	write_unlock_irqrestore(&adapter->adapter_lock, flags);
+	return ret;
+}
+
+int
+netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
+		u64 off, void *data, int size)
+{
+	unsigned long   flags, mem_crb;
+	int	     i, j = 0, k, start, end, loop, sz[2], off0[2];
+	uint32_t      temp;
+	uint64_t      off8, val, word[2] = {0, 0};
+
+
+	/*
+	 * If not MN, go check for MS or invalid.
+	 */
+	if (netxen_nic_pci_mem_bound_check(adapter, off, size) == 0)
+		return netxen_nic_pci_mem_read_direct(adapter, off, data, size);
+
+	off8 = off & 0xfffffff8;
+	off0[0] = off & 0x7;
+	off0[1] = 0;
+	sz[0] = (size < (8 - off0[0])) ? size : (8 - off0[0]);
+	sz[1] = size - sz[0];
+	loop = ((off0[0] + size - 1) >> 3) + 1;
+	mem_crb = (unsigned long)pci_base_offset(adapter, NETXEN_CRB_DDR_NET);
+
+	write_lock_irqsave(&adapter->adapter_lock, flags);
+	netxen_nic_pci_change_crbwindow_128M(adapter, 0);
+
+	for (i = 0; i < loop; i++) {
+		writel((uint32_t)(off8 + (i << 3)),
+			(void *)(mem_crb+MIU_TEST_AGT_ADDR_LO));
+		writel(0,
+			(void *)(mem_crb+MIU_TEST_AGT_ADDR_HI));
+		writel(MIU_TA_CTL_ENABLE,
+			(void *)(mem_crb+MIU_TEST_AGT_CTRL));
+		writel(MIU_TA_CTL_START|MIU_TA_CTL_ENABLE,
+			(void *)(mem_crb+MIU_TEST_AGT_CTRL));
+
+		for (j = 0; j < MAX_CTL_CHECK; j++) {
+			temp = readl(
+			      (void *)(mem_crb+MIU_TEST_AGT_CTRL));
+			if ((temp & MIU_TA_CTL_BUSY) == 0)
+				break;
+		}
+
+		if (j >= MAX_CTL_CHECK) {
+			printk(KERN_ERR "%s: %s Fail to read through agent\n",
+					__func__, netxen_nic_driver_name);
+			break;
+		}
+
+		start = off0[i] >> 2;
+		end   = (off0[i] + sz[i] - 1) >> 2;
+		for (k = start; k <= end; k++) {
+			word[i] |= ((uint64_t) readl(
+				    (void *)(mem_crb +
+				    MIU_TEST_AGT_RDDATA(k))) << (32*k));
+		}
+	}
+
+	netxen_nic_pci_change_crbwindow_128M(adapter, 1);
+	write_unlock_irqrestore(&adapter->adapter_lock, flags);
+
+	if (j >= MAX_CTL_CHECK)
+		return -1;
+
+	if (sz[0] == 8) {
+		val = word[0];
+	} else {
+		val = ((word[0] >> (off0[0] * 8)) & (~(~0ULL << (sz[0] * 8)))) |
+			((word[1] & (~(~0ULL << (sz[1] * 8)))) << (sz[0] * 8));
+	}
+
+	switch (size) {
+	case 1:
+		*(uint8_t  *)data = val;
+		break;
+	case 2:
+		*(uint16_t *)data = val;
+		break;
+	case 4:
+		*(uint32_t *)data = val;
+		break;
+	case 8:
+		*(uint64_t *)data = val;
+		break;
+	}
+	DPRINTK(1, INFO, "read %llx\n", *(unsigned long long *)data);
+	return 0;
+}
+
+int
+netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
+		u64 off, void *data, int size)
+{
+	int i, j, ret = 0, loop, sz[2], off0;
+	uint32_t temp;
+	uint64_t off8, mem_crb, tmpw, word[2] = {0, 0};
+
+	/*
+	 * If not MN, go check for MS or invalid.
+	 */
+	if (off >= NETXEN_ADDR_QDR_NET && off <= NETXEN_ADDR_QDR_NET_MAX_P3)
+		mem_crb = NETXEN_CRB_QDR_NET;
+	else {
+		mem_crb = NETXEN_CRB_DDR_NET;
+		if (netxen_nic_pci_mem_bound_check(adapter, off, size) == 0)
+			return netxen_nic_pci_mem_write_direct(adapter,
+					off, data, size);
+	}
+
+	off8 = off & 0xfffffff8;
+	off0 = off & 0x7;
+	sz[0] = (size < (8 - off0)) ? size : (8 - off0);
+	sz[1] = size - sz[0];
+	loop = ((off0 + size - 1) >> 3) + 1;
+
+	if ((size != 8) || (off0 != 0)) {
+		for (i = 0; i < loop; i++) {
+			if (adapter->pci_mem_read(adapter, off8 + (i << 3),
+						&word[i], 8))
+				return -1;
+		}
+	}
+
+	switch (size) {
+	case 1:
+		tmpw = *((uint8_t *)data);
+		break;
+	case 2:
+		tmpw = *((uint16_t *)data);
+		break;
+	case 4:
+		tmpw = *((uint32_t *)data);
+		break;
+	case 8:
+	default:
+		tmpw = *((uint64_t *)data);
+	break;
+	}
+
+	word[0] &= ~((~(~0ULL << (sz[0] * 8))) << (off0 * 8));
+	word[0] |= tmpw << (off0 * 8);
+
+	if (loop == 2) {
+		word[1] &= ~(~0ULL << (sz[1] * 8));
+		word[1] |= tmpw >> (sz[0] * 8);
+	}
+
+	/*
+	 * don't lock here - write_wx gets the lock if each time
+	 * write_lock_irqsave(&adapter->adapter_lock, flags);
+	 * netxen_nic_pci_change_crbwindow_128M(adapter, 0);
+	 */
+
+	for (i = 0; i < loop; i++) {
+		temp = off8 + (i << 3);
+		adapter->hw_write_wx(adapter,
+				mem_crb+MIU_TEST_AGT_ADDR_LO, &temp, 4);
+		temp = 0;
+		adapter->hw_write_wx(adapter,
+				mem_crb+MIU_TEST_AGT_ADDR_HI, &temp, 4);
+		temp = word[i] & 0xffffffff;
+		adapter->hw_write_wx(adapter,
+				mem_crb+MIU_TEST_AGT_WRDATA_LO, &temp, 4);
+		temp = (word[i] >> 32) & 0xffffffff;
+		adapter->hw_write_wx(adapter,
+				mem_crb+MIU_TEST_AGT_WRDATA_HI, &temp, 4);
+		temp = MIU_TA_CTL_ENABLE | MIU_TA_CTL_WRITE;
+		adapter->hw_write_wx(adapter,
+				mem_crb+MIU_TEST_AGT_CTRL, &temp, 4);
+		temp = MIU_TA_CTL_START | MIU_TA_CTL_ENABLE | MIU_TA_CTL_WRITE;
+		adapter->hw_write_wx(adapter,
+				mem_crb+MIU_TEST_AGT_CTRL, &temp, 4);
+
+		for (j = 0; j < MAX_CTL_CHECK; j++) {
+			adapter->hw_read_wx(adapter,
+					mem_crb + MIU_TEST_AGT_CTRL, &temp, 4);
+			if ((temp & MIU_TA_CTL_BUSY) == 0)
+				break;
+		}
+
+		if (j >= MAX_CTL_CHECK) {
+			printk(KERN_ERR "%s: Fail to write through agent\n",
+					netxen_nic_driver_name);
+			ret = -1;
+			break;
+		}
+	}
+
+	/*
+	 * netxen_nic_pci_change_crbwindow_128M(adapter, 1);
+	 * write_unlock_irqrestore(&adapter->adapter_lock, flags);
+	 */
+	return ret;
+}
+
+int
+netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
+		u64 off, void *data, int size)
+{
+	int i, j = 0, k, start, end, loop, sz[2], off0[2];
+	uint32_t      temp;
+	uint64_t      off8, val, mem_crb, word[2] = {0, 0};
+
+	/*
+	 * If not MN, go check for MS or invalid.
+	 */
+
+	if (off >= NETXEN_ADDR_QDR_NET && off <= NETXEN_ADDR_QDR_NET_MAX_P3)
+		mem_crb = NETXEN_CRB_QDR_NET;
+	else {
+		mem_crb = NETXEN_CRB_DDR_NET;
+		if (netxen_nic_pci_mem_bound_check(adapter, off, size) == 0)
+			return netxen_nic_pci_mem_read_direct(adapter,
+					off, data, size);
+	}
+
+	off8 = off & 0xfffffff8;
+	off0[0] = off & 0x7;
+	off0[1] = 0;
+	sz[0] = (size < (8 - off0[0])) ? size : (8 - off0[0]);
+	sz[1] = size - sz[0];
+	loop = ((off0[0] + size - 1) >> 3) + 1;
+
+	/*
+	 * don't lock here - write_wx gets the lock if each time
+	 * write_lock_irqsave(&adapter->adapter_lock, flags);
+	 * netxen_nic_pci_change_crbwindow_128M(adapter, 0);
+	 */
+
+	for (i = 0; i < loop; i++) {
+		temp = off8 + (i << 3);
+		adapter->hw_write_wx(adapter,
+				mem_crb + MIU_TEST_AGT_ADDR_LO, &temp, 4);
+		temp = 0;
+		adapter->hw_write_wx(adapter,
+				mem_crb + MIU_TEST_AGT_ADDR_HI, &temp, 4);
+		temp = MIU_TA_CTL_ENABLE;
+		adapter->hw_write_wx(adapter,
+				mem_crb + MIU_TEST_AGT_CTRL, &temp, 4);
+		temp = MIU_TA_CTL_START | MIU_TA_CTL_ENABLE;
+		adapter->hw_write_wx(adapter,
+				mem_crb + MIU_TEST_AGT_CTRL, &temp, 4);
+
+		for (j = 0; j < MAX_CTL_CHECK; j++) {
+			adapter->hw_read_wx(adapter,
+					mem_crb + MIU_TEST_AGT_CTRL, &temp, 4);
+			if ((temp & MIU_TA_CTL_BUSY) == 0)
+				break;
+		}
+
+		if (j >= MAX_CTL_CHECK) {
+			printk(KERN_ERR "%s: Fail to read through agent\n",
+					netxen_nic_driver_name);
+			break;
+		}
+
+		start = off0[i] >> 2;
+		end   = (off0[i] + sz[i] - 1) >> 2;
+		for (k = start; k <= end; k++) {
+			adapter->hw_read_wx(adapter,
+				mem_crb + MIU_TEST_AGT_RDDATA(k), &temp, 4);
+			word[i] |= ((uint64_t)temp << (32 * k));
+		}
+	}
+
+	/*
+	 * netxen_nic_pci_change_crbwindow_128M(adapter, 1);
+	 * write_unlock_irqrestore(&adapter->adapter_lock, flags);
+	 */
+
+	if (j >= MAX_CTL_CHECK)
+		return -1;
+
+	if (sz[0] == 8) {
+		val = word[0];
+	} else {
+		val = ((word[0] >> (off0[0] * 8)) & (~(~0ULL << (sz[0] * 8)))) |
+		((word[1] & (~(~0ULL << (sz[1] * 8)))) << (sz[0] * 8));
+	}
+
+	switch (size) {
+	case 1:
+		*(uint8_t  *)data = val;
+		break;
+	case 2:
+		*(uint16_t *)data = val;
+		break;
+	case 4:
+		*(uint32_t *)data = val;
+		break;
+	case 8:
+		*(uint64_t *)data = val;
+		break;
+	}
+	DPRINTK(1, INFO, "read %llx\n", *(unsigned long long *)data);
+	return 0;
+}
+
+/*
+ * Note : only 32-bit writes!
+ */
+int netxen_nic_pci_write_immediate_2M(struct netxen_adapter *adapter,
+		u64 off, u32 data)
+{
+	adapter->hw_write_wx(adapter, off, &data, 4);
+
+	return 0;
+}
+
+u32 netxen_nic_pci_read_immediate_2M(struct netxen_adapter *adapter, u64 off)
+{
+	u32 temp;
+	adapter->hw_read_wx(adapter, off, &temp, 4);
+	return temp;
+}
+
+void netxen_nic_pci_write_normalize_2M(struct netxen_adapter *adapter,
+		u64 off, u32 data)
+{
+	adapter->hw_write_wx(adapter, off, &data, 4);
+}
+
+u32 netxen_nic_pci_read_normalize_2M(struct netxen_adapter *adapter, u64 off)
+{
+	u32 temp;
+	adapter->hw_read_wx(adapter, off, &temp, 4);
+	return temp;
+}
+
 #if 0
 int
 netxen_nic_erase_pxe(struct netxen_adapter *adapter)
@@ -1006,19 +2147,10 @@ void netxen_nic_init_niu_gb(struct netxen_adapter *adapter)
 }
 
 void
-netxen_crb_writelit_adapter(struct netxen_adapter *adapter, unsigned long off,
-			    int data)
+netxen_crb_writelit_adapter(struct netxen_adapter *adapter,
+		unsigned long off, int data)
 {
-	void __iomem *addr;
-
-	if (ADDR_IN_WINDOW1(off)) {
-		writel(data, NETXEN_CRB_NORMALIZE(adapter, off));
-	} else {
-		netxen_nic_pci_change_crbwindow(adapter, 0);
-		addr = pci_base_offset(adapter, off);
-		writel(data, addr);
-		netxen_nic_pci_change_crbwindow(adapter, 1);
-	}
+	adapter->hw_write_wx(adapter, off, &data, 4);
 }
 
 void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
@@ -1105,12 +2237,9 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
 		addr += sizeof(u32);
 	}
 
-	fw_major = readl(NETXEN_CRB_NORMALIZE(adapter,
-					      NETXEN_FW_VERSION_MAJOR));
-	fw_minor = readl(NETXEN_CRB_NORMALIZE(adapter,
-					      NETXEN_FW_VERSION_MINOR));
-	fw_build =
-	    readl(NETXEN_CRB_NORMALIZE(adapter, NETXEN_FW_VERSION_SUB));
+	adapter->hw_read_wx(adapter, NETXEN_FW_VERSION_MAJOR, &fw_major, 4);
+	adapter->hw_read_wx(adapter, NETXEN_FW_VERSION_MINOR, &fw_minor, 4);
+	adapter->hw_read_wx(adapter, NETXEN_FW_VERSION_SUB, &fw_build, 4);
 
 	if (adapter->portnum == 0) {
 		get_brd_name_by_type(board_info->board_type, brd_name);
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index 90dd057..b8e0030 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -82,19 +82,9 @@ struct netxen_adapter;
 
 #define NETXEN_PCI_MAPSIZE_BYTES  (NETXEN_PCI_MAPSIZE << 20)
 
-#define NETXEN_NIC_LOCKED_READ_REG(X, Y)	\
-	addr = pci_base_offset(adapter, X);	\
-	*(u32 *)Y = readl((void __iomem*) addr);
-
 struct netxen_port;
 void netxen_nic_set_link_parameters(struct netxen_adapter *adapter);
 void netxen_nic_flash_print(struct netxen_adapter *adapter);
-int netxen_nic_hw_write_wx(struct netxen_adapter *adapter, u64 off,
-			   void *data, int len);
-void netxen_crb_writelit_adapter(struct netxen_adapter *adapter,
-				 unsigned long off, int data);
-int netxen_nic_hw_read_wx(struct netxen_adapter *adapter, u64 off,
-			  void *data, int len);
 
 typedef u8 netxen_ethernet_macaddr_t[6];
 
@@ -503,4 +493,15 @@ int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter);
 
 int netxen_niu_disable_xg_port(struct netxen_adapter *adapter);
 
+typedef struct {
+	unsigned valid;
+	unsigned start_128M;
+	unsigned end_128M;
+	unsigned start_2M;
+} crb_128M_2M_sub_block_map_t;
+
+typedef struct {
+	crb_128M_2M_sub_block_map_t sub_block[16];
+} crb_128M_2M_block_map_t;
+
 #endif				/* __NETXEN_NIC_HW_H_ */
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index dfde590..7323cd7 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -124,7 +124,7 @@ int netxen_init_firmware(struct netxen_adapter *adapter)
 	u32 state = 0, loops = 0, err = 0;
 
 	/* Window 1 call */
-	state = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+	state = adapter->pci_read_normalize(adapter, CRB_CMDPEG_STATE);
 
 	if (state == PHAN_INITIALIZE_ACK)
 		return 0;
@@ -132,7 +132,7 @@ int netxen_init_firmware(struct netxen_adapter *adapter)
 	while (state != PHAN_INITIALIZE_COMPLETE && loops < 2000) {
 		udelay(100);
 		/* Window 1 call */
-		state = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+		state = adapter->pci_read_normalize(adapter, CRB_CMDPEG_STATE);
 
 		loops++;
 	}
@@ -143,14 +143,14 @@ int netxen_init_firmware(struct netxen_adapter *adapter)
 		return err;
 	}
 	/* Window 1 call */
-	writel(INTR_SCHEME_PERPORT,
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_HOST));
-	writel(MSI_MODE_MULTIFUNC,
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_MSI_MODE_HOST));
-	writel(MPORT_MULTI_FUNCTION_MODE,
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_MPORT_MODE));
-	writel(PHAN_INITIALIZE_ACK,
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+	adapter->pci_write_normalize(adapter,
+			CRB_NIC_CAPABILITIES_HOST, INTR_SCHEME_PERPORT);
+	adapter->pci_write_normalize(adapter,
+			CRB_NIC_MSI_MODE_HOST, MSI_MODE_MULTIFUNC);
+	adapter->pci_write_normalize(adapter,
+			CRB_MPORT_MODE, MPORT_MULTI_FUNCTION_MODE);
+	adapter->pci_write_normalize(adapter,
+			CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
 
 	return err;
 }
@@ -811,7 +811,7 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 				buf[i].data = NETXEN_NIC_XDMA_RESET;
 			}
 
-			netxen_nic_hw_write_wx(adapter, off, &buf[i].data, 4);
+			adapter->hw_write_wx(adapter, off, &buf[i].data, 4);
 
 			if (init_delay == 1) {
 				msleep(1000);
@@ -824,7 +824,7 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 		/* disable_peg_cache_all */
 
 		/* unreset_net_cache */
-		netxen_nic_hw_read_wx(adapter, NETXEN_ROMUSB_GLB_SW_RESET, &val,
+		adapter->hw_read_wx(adapter, NETXEN_ROMUSB_GLB_SW_RESET, &val,
 				      4);
 		netxen_crb_writelit_adapter(adapter, NETXEN_ROMUSB_GLB_SW_RESET,
 					    (val & 0xffffff0f));
@@ -884,8 +884,8 @@ int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
 	hi = (addr >> 32) & 0xffffffff;
 	lo = addr & 0xffffffff;
 
-	writel(hi, NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_DUMMY_BUF_ADDR_HI));
-	writel(lo, NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_DUMMY_BUF_ADDR_LO));
+	adapter->pci_write_normalize(adapter, CRB_HOST_DUMMY_BUF_ADDR_HI, hi);
+	adapter->pci_write_normalize(adapter, CRB_HOST_DUMMY_BUF_ADDR_LO, lo);
 
 	return 0;
 }
@@ -924,10 +924,10 @@ int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
 
 	if (!pegtune_val) {
 		do {
-			val = readl(NETXEN_CRB_NORMALIZE
-				  (adapter, CRB_CMDPEG_STATE));
-			pegtune_val = readl(NETXEN_CRB_NORMALIZE
-				  (adapter, NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
+			val = adapter->pci_read_normalize(adapter,
+					CRB_CMDPEG_STATE);
+			pegtune_val = adapter->pci_read_normalize(adapter,
+					NETXEN_ROMUSB_GLB_PEGTUNE_DONE);
 
 			if (val == PHAN_INITIALIZE_COMPLETE ||
 				val == PHAN_INITIALIZE_ACK)
@@ -951,7 +951,7 @@ static int netxen_nic_check_temp(struct netxen_adapter *adapter)
 	uint32_t temp, temp_state, temp_val;
 	int rv = 0;
 
-	temp = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_TEMP_STATE));
+	temp = adapter->pci_read_normalize(adapter, CRB_TEMP_STATE);
 
 	temp_state = nx_get_temp_state(temp);
 	temp_val = nx_get_temp_val(temp);
@@ -1119,8 +1119,8 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 		recv_ctx->status_rx_consumer = consumer;
 
 		/* Window = 1 */
-		writel(consumer, NETXEN_CRB_NORMALIZE(adapter,
-					recv_ctx->crb_sts_consumer));
+		adapter->pci_write_normalize(adapter,
+				recv_ctx->crb_sts_consumer, consumer);
 	}
 
 	return count;
@@ -1264,9 +1264,9 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 		rcv_desc->begin_alloc = index;
 		rcv_desc->producer = producer;
 			/* Window = 1 */
-		writel((producer - 1) & (rcv_desc->max_rx_desc_count - 1),
-		       NETXEN_CRB_NORMALIZE(adapter,
-			       rcv_desc->crb_rcv_producer));
+		adapter->pci_write_normalize(adapter,
+				rcv_desc->crb_rcv_producer,
+				(producer-1) & (rcv_desc->max_rx_desc_count-1));
 			/*
 			 * Write a doorbell msg to tell phanmon of change in
 			 * receive ring producer
@@ -1344,9 +1344,9 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 		rcv_desc->begin_alloc = index;
 		rcv_desc->producer = producer;
 			/* Window = 1 */
-		writel((producer - 1) & (rcv_desc->max_rx_desc_count - 1),
-		       NETXEN_CRB_NORMALIZE(adapter,
-			       rcv_desc->crb_rcv_producer));
+		adapter->pci_write_normalize(adapter,
+			rcv_desc->crb_rcv_producer,
+				(producer-1) & (rcv_desc->max_rx_desc_count-1));
 			wmb();
 	}
 }
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index 96cec41..104c287 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -144,7 +144,7 @@ static void netxen_nic_isr_other(struct netxen_adapter *adapter)
 	u32 val, linkup, qg_linksup;
 
 	/* verify the offset */
-	val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
+	val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
 	val = val >> adapter->physical_port;
 	if (val == adapter->ahw.qg_linksup)
 		return;
@@ -198,7 +198,7 @@ void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter)
 	u32 val;
 
 	/* WINDOW = 1 */
-	val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
+	val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
 	val >>= (adapter->physical_port * 8);
 	val &= 0xff;
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 192a22f..72d9f48 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -114,11 +114,12 @@ static uint32_t crb_cmd_producer[4] = {
 	CRB_CMD_PRODUCER_OFFSET_2, CRB_CMD_PRODUCER_OFFSET_3
 };
 
-static void netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
-					   uint32_t crb_producer)
+static inline void
+netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
+		uint32_t crb_producer)
 {
-	writel(crb_producer, NETXEN_CRB_NORMALIZE(adapter,
-				adapter->crb_addr_cmd_producer));
+	adapter->pci_write_normalize(adapter,
+			adapter->crb_addr_cmd_producer, crb_producer);
 }
 
 static uint32_t crb_cmd_consumer[4] = {
@@ -126,11 +127,12 @@ static uint32_t crb_cmd_consumer[4] = {
 	CRB_CMD_CONSUMER_OFFSET_2, CRB_CMD_CONSUMER_OFFSET_3
 };
 
-static void netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter,
-					   u32 crb_consumer)
+static inline void
+netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter,
+		u32 crb_consumer)
 {
-	writel(crb_consumer, NETXEN_CRB_NORMALIZE(adapter,
-				adapter->crb_addr_cmd_consumer));
+	adapter->pci_write_normalize(adapter,
+			adapter->crb_addr_cmd_consumer, crb_consumer);
 }
 
 static uint32_t msi_tgt_status[4] = {
@@ -151,17 +153,18 @@ static void netxen_nic_disable_int(struct netxen_adapter *adapter)
 	int pci_fn = adapter->ahw.pci_func;
 
 	if (adapter->msi_mode != MSI_MODE_MULTIFUNC)
-		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, sw_int_mask[port]));
+		adapter->pci_write_normalize(adapter, sw_int_mask[port], 0);
 
 	if (adapter->intr_scheme != -1 &&
 	    adapter->intr_scheme != INTR_SCHEME_PERPORT)
-		writel(mask,PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
+		adapter->pci_write_immediate(adapter, ISR_INT_MASK, mask);
 
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		do {
-			writel(0xffffffff,
-			       PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_STATUS));
-			mask = readl(pci_base_offset(adapter, ISR_INT_VECTOR));
+			adapter->pci_write_immediate(adapter,
+					ISR_INT_TARGET_STATUS, 0xffffffff);
+			mask = adapter->pci_read_immediate(adapter,
+					ISR_INT_VECTOR);
 			if (!(mask & 0x80))
 				break;
 			udelay(10);
@@ -173,8 +176,8 @@ static void netxen_nic_disable_int(struct netxen_adapter *adapter)
 		}
 	} else {
 		if (adapter->msi_mode == MSI_MODE_MULTIFUNC) {
-			writel(0xffffffff, PCI_OFFSET_SECOND_RANGE(adapter,
-						msi_tgt_status[pci_fn]));
+			adapter->pci_write_immediate(adapter,
+					msi_tgt_status[pci_fn], 0xffffffff);
 		}
 	}
 }
@@ -200,19 +203,20 @@ static void netxen_nic_enable_int(struct netxen_adapter *adapter)
 			break;
 		}
 
-		writel(mask, PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
+		adapter->pci_write_immediate(adapter, ISR_INT_MASK, mask);
 	}
 
-	writel(0x1, NETXEN_CRB_NORMALIZE(adapter, sw_int_mask[port]));
+	adapter->pci_write_normalize(adapter, sw_int_mask[port], 0x1);
 
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		mask = 0xbff;
 		if (adapter->intr_scheme != -1 &&
 			adapter->intr_scheme != INTR_SCHEME_PERPORT) {
-			writel(0X0, NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+			adapter->pci_write_normalize(adapter,
+					CRB_INT_VECTOR, 0);
 		}
-		writel(mask,
-		       PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_MASK));
+		adapter->pci_write_immediate(adapter,
+				ISR_INT_TARGET_MASK, mask);
 	}
 
 	DPRINTK(1, INFO, "Done with enable Int\n");
@@ -243,7 +247,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 
 	u8 __iomem *db_ptr = NULL;
-	unsigned long mem_base, mem_len, db_base, db_len;
+	unsigned long mem_base, mem_len, db_base, db_len, pci_len0;
 	int pci_using_dac, i = 0, err;
 	int ring;
 	struct netxen_recv_context *recv_ctx = NULL;
@@ -300,10 +304,24 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter = netdev->priv;
 
 	adapter->ahw.pci_func  = pci_func_id;
+	rwlock_init(&adapter->adapter_lock);
+	adapter->ahw.qdr_sn_window = -1;
+	adapter->ahw.ddr_mn_window = -1;
 
 	/* remap phys address */
 	mem_base = pci_resource_start(pdev, 0);	/* 0 is for BAR 0 */
 	mem_len = pci_resource_len(pdev, 0);
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
 
 	/* 128 Meg of memory */
 	if (mem_len == NETXEN_PCI_128MB_SIZE) {
@@ -320,21 +338,42 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			SECOND_PAGE_GROUP_START, THIRD_PAGE_GROUP_SIZE);
 		first_page_group_start = 0;
 		first_page_group_end   = 0;
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
+		mem_ptr0 = ioremap(mem_base, mem_len);
+		pci_len0 = mem_len;
+		first_page_group_start = 0;
+		first_page_group_end   = 0;
+
+		adapter->ahw.ddr_mn_window = 0;
+		adapter->ahw.qdr_sn_window = 0;
+
+		adapter->ahw.mn_win_crb = 0x100000 + PCIX_MN_WINDOW +
+			(pci_func_id * 0x20);
+		adapter->ahw.ms_win_crb = 0x100000 + PCIX_SN_WINDOW;
+		if (pci_func_id < 4)
+			adapter->ahw.ms_win_crb += (pci_func_id * 0x20);
+		else
+			adapter->ahw.ms_win_crb +=
+					0xA0 + ((pci_func_id - 4) * 0x10);
 	} else {
 		err = -EIO;
 		goto err_out_free_netdev;
 	}
 
-	if ((!mem_ptr0 && mem_len == NETXEN_PCI_128MB_SIZE) ||
-			!mem_ptr1 || !mem_ptr2) {
-		DPRINTK(ERR,
-			"Cannot remap adapter memory aborting.:"
-			"0 -> %p, 1 -> %p, 2 -> %p\n",
-			mem_ptr0, mem_ptr1, mem_ptr2);
+	dev_info(&pdev->dev, "%dMB memory map\n", (int)(mem_len>>20));
 
-		err = -EIO;
-		goto err_out_iounmap;
-	}
 	db_base = pci_resource_start(pdev, 4);	/* doorbell is on bar 4 */
 	db_len = pci_resource_len(pdev, 4);
 
@@ -357,6 +396,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	DPRINTK(INFO, "doorbell ioremaped at %p\n", db_ptr);
 
 	adapter->ahw.pci_base0 = mem_ptr0;
+	adapter->ahw.pci_len0 = pci_len0;
 	adapter->ahw.first_page_group_start = first_page_group_start;
 	adapter->ahw.first_page_group_end   = first_page_group_end;
 	adapter->ahw.pci_base1 = mem_ptr1;
@@ -520,9 +560,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	INIT_WORK(&adapter->watchdog_task, netxen_watchdog_task);
 	adapter->ahw.revision_id = pdev->revision;
 
-	/* make sure Window == 1 */
-	netxen_nic_pci_change_crbwindow(adapter, 1);
-
 	adapter->crb_addr_cmd_producer = crb_cmd_producer[adapter->portnum];
 	adapter->crb_addr_cmd_consumer = crb_cmd_consumer[adapter->portnum];
 	netxen_nic_update_cmd_producer(adapter, 0);
@@ -560,8 +597,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		err = netxen_initialize_adapter_offload(adapter);
 		if (err)
 			goto err_out_free_rx_buffer;
-		val = readl(NETXEN_CRB_NORMALIZE(adapter,
-					NETXEN_CAM_RAM(0x1fc)));
+		val = adapter->pci_read_normalize(adapter,
+				NETXEN_CAM_RAM(0x1fc));
 		if (val == 0x55555555) {
 		    /* This is the first boot after power up */
 		    netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(0x4), &val);
@@ -573,20 +610,20 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 					printk(KERN_ERR "%s: failed to set MSI bit in PCI-e reg\n",
 							netxen_nic_driver_name);
 			}
-		    val = readl(NETXEN_CRB_NORMALIZE(adapter,
-					NETXEN_ROMUSB_GLB_SW_RESET));
+		    val = adapter->pci_read_normalize(adapter,
+					NETXEN_ROMUSB_GLB_SW_RESET);
 		    printk(KERN_INFO"NetXen: read 0x%08x for reset reg.\n",val);
 		    if (val != 0x80000f) {
 			/* clear the register for future unloads/loads */
-				writel(0, NETXEN_CRB_NORMALIZE(adapter,
-							NETXEN_CAM_RAM(0x1fc)));
+				adapter->pci_write_normalize(adapter,
+						NETXEN_CAM_RAM(0x1fc), 0);
 				printk(KERN_ERR "ERROR in NetXen HW init sequence.\n");
 				err = -ENODEV;
 				goto err_out_free_dev;
 		    }
 		} else {
-			writel(0, NETXEN_CRB_NORMALIZE(adapter,
-						CRB_CMDPEG_STATE));
+			adapter->pci_write_normalize(adapter,
+						CRB_CMDPEG_STATE, 0);
 			netxen_pinit_from_rom(adapter, 0);
 			msleep(1);
 			netxen_load_firmware(adapter);
@@ -602,9 +639,9 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 
 		/* clear the register for future unloads/loads */
-		writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
+		adapter->pci_write_normalize(adapter, NETXEN_CAM_RAM(0x1fc), 0);
 		dev_info(&pdev->dev, "cmdpeg state: 0x%0x\n",
-			readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
+			adapter->pci_read_normalize(adapter, CRB_CMDPEG_STATE));
 
 		/*
 		 * Tell the hardware our version number.
@@ -612,12 +649,11 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		i = (_NETXEN_NIC_LINUX_MAJOR << 16)
 			| ((_NETXEN_NIC_LINUX_MINOR << 8))
 			| (_NETXEN_NIC_LINUX_SUBVERSION);
-		writel(i, NETXEN_CRB_NORMALIZE(adapter, CRB_DRIVER_VERSION));
+		adapter->pci_write_normalize(adapter, CRB_DRIVER_VERSION, i);
 
 		/* Unlock the HW, prompting the boot sequence */
-		writel(1,
-			NETXEN_CRB_NORMALIZE(adapter,
-				NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
+		adapter->pci_write_normalize(adapter,
+				NETXEN_ROMUSB_GLB_PEGTUNE_DONE, 1);
 		/* Handshake with the card before we register the devices. */
 		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 	}
@@ -626,7 +662,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * See if the firmware gave us a virtual-physical port mapping.
 	 */
 	adapter->physical_port = adapter->portnum;
-	i = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_V2P(adapter->portnum)));
+	i = adapter->pci_read_normalize(adapter, CRB_V2P(adapter->portnum));
 	if (i != 0x55555555)
 		adapter->physical_port = i;
 
@@ -1104,15 +1140,15 @@ static irqreturn_t netxen_intr(int irq, void *data)
 	struct netxen_adapter *adapter = data;
 	u32 our_int = 0;
 
-	our_int = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+	our_int = adapter->pci_read_normalize(adapter, CRB_INT_VECTOR);
 	/* not our interrupt */
 	if ((our_int & (0x80 << adapter->portnum)) == 0)
 		return IRQ_NONE;
 
 	if (adapter->intr_scheme == INTR_SCHEME_PERPORT) {
 		/* claim interrupt */
-		writel(our_int & ~((u32)(0x80 << adapter->portnum)),
-			NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+		adapter->pci_write_normalize(adapter, CRB_INT_VECTOR,
+				our_int & ~((u32)(0x80 << adapter->portnum)));
 	}
 
 	netxen_handle_int(adapter);
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index d9664a0..78905d9 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -46,9 +46,8 @@ static int phy_lock(struct netxen_adapter *adapter)
 	int done = 0, timeout = 0;
 
 	while (!done) {
-		done =
-		    readl(pci_base_offset
-			  (adapter, NETXEN_PCIE_REG(PCIE_SEM3_LOCK)));
+		done = netxen_nic_reg_read(adapter,
+				NETXEN_PCIE_REG(PCIE_SEM3_LOCK));
 		if (done == 1)
 			break;
 		if (timeout >= phy_lock_timeout) {
@@ -63,14 +62,14 @@ static int phy_lock(struct netxen_adapter *adapter)
 		}
 	}
 
-	writel(PHY_LOCK_DRIVER,
-	       NETXEN_CRB_NORMALIZE(adapter, NETXEN_PHY_LOCK_ID));
+	netxen_crb_writelit_adapter(adapter,
+			NETXEN_PHY_LOCK_ID, PHY_LOCK_DRIVER);
 	return 0;
 }
 
 static int phy_unlock(struct netxen_adapter *adapter)
 {
-	readl(pci_base_offset(adapter, NETXEN_PCIE_REG(PCIE_SEM3_UNLOCK)));
+	adapter->pci_read_immediate(adapter, NETXEN_PCIE_REG(PCIE_SEM3_UNLOCK));
 
 	return 0;
 }
@@ -109,7 +108,7 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 	 * so it cannot be in reset
 	 */
 
-	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0),
+	if (adapter->hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0),
 				  &mac_cfg0, 4))
 		return -EIO;
 	if (netxen_gb_get_soft_reset(mac_cfg0)) {
@@ -119,7 +118,7 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 		netxen_gb_rx_reset_pb(temp);
 		netxen_gb_tx_reset_mac(temp);
 		netxen_gb_rx_reset_mac(temp);
-		if (netxen_nic_hw_write_wx(adapter,
+		if (adapter->hw_write_wx(adapter,
 					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
 					   &temp, 4))
 			return -EIO;
@@ -129,22 +128,22 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 	address = 0;
 	netxen_gb_mii_mgmt_reg_addr(address, reg);
 	netxen_gb_mii_mgmt_phy_addr(address, phy);
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0),
+	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0),
 				   &address, 4))
 		return -EIO;
 	command = 0;		/* turn off any prior activity */
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
+	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
 				   &command, 4))
 		return -EIO;
 	/* send read command */
 	netxen_gb_mii_mgmt_set_read_cycle(command);
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
+	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
 				   &command, 4))
 		return -EIO;
 
 	status = 0;
 	do {
-		if (netxen_nic_hw_read_wx(adapter,
+		if (adapter->hw_read_wx(adapter,
 					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0),
 					  &status, 4))
 			return -EIO;
@@ -154,7 +153,7 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
 
 	if (timeout < NETXEN_NIU_PHY_WAITMAX) {
-		if (netxen_nic_hw_read_wx(adapter,
+		if (adapter->hw_read_wx(adapter,
 					  NETXEN_NIU_GB_MII_MGMT_STATUS(0),
 					  readval, 4))
 			return -EIO;
@@ -163,7 +162,7 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 		result = -1;
 
 	if (restore)
-		if (netxen_nic_hw_write_wx(adapter,
+		if (adapter->hw_write_wx(adapter,
 					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
 					   &mac_cfg0, 4))
 			return -EIO;
@@ -201,7 +200,7 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 	 * cannot be in reset
 	 */
 
-	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0),
+	if (adapter->hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0),
 				  &mac_cfg0, 4))
 		return -EIO;
 	if (netxen_gb_get_soft_reset(mac_cfg0)) {
@@ -212,7 +211,7 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 		netxen_gb_tx_reset_mac(temp);
 		netxen_gb_rx_reset_mac(temp);
 
-		if (netxen_nic_hw_write_wx(adapter,
+		if (adapter->hw_write_wx(adapter,
 					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
 					   &temp, 4))
 			return -EIO;
@@ -220,24 +219,24 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 	}
 
 	command = 0;		/* turn off any prior activity */
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
+	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
 				   &command, 4))
 		return -EIO;
 
 	address = 0;
 	netxen_gb_mii_mgmt_reg_addr(address, reg);
 	netxen_gb_mii_mgmt_phy_addr(address, phy);
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0),
+	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0),
 				   &address, 4))
 		return -EIO;
 
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CTRL(0),
+	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CTRL(0),
 				   &val, 4))
 		return -EIO;
 
 	status = 0;
 	do {
-		if (netxen_nic_hw_read_wx(adapter,
+		if (adapter->hw_read_wx(adapter,
 					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0),
 					  &status, 4))
 			return -EIO;
@@ -252,7 +251,7 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 
 	/* restore the state of port 0 MAC in case we tampered with it */
 	if (restore)
-		if (netxen_nic_hw_write_wx(adapter,
+		if (adapter->hw_write_wx(adapter,
 					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
 					   &mac_cfg0, 4))
 			return -EIO;
@@ -581,10 +580,10 @@ static int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
 	if ((phy < 0) || (phy > 3))
 		return -EINVAL;
 
-	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy),
+	if (adapter->hw_read_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy),
 				  &stationhigh, 4))
 		return -EIO;
-	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy),
+	if (adapter->hw_read_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy),
 				  &stationlow, 4))
 		return -EIO;
 	((__le32 *)val)[1] = cpu_to_le32(stationhigh);
@@ -613,14 +612,14 @@ int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
 		temp[0] = temp[1] = 0;
 		memcpy(temp + 2, addr, 2);
 		val = le32_to_cpu(*(__le32 *)temp);
-		if (netxen_nic_hw_write_wx
-		    (adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy), &val, 4))
+		if (adapter->hw_write_wx(adapter,
+				NETXEN_NIU_GB_STATION_ADDR_1(phy), &val, 4))
 			return -EIO;
 
 		memcpy(temp, ((u8 *) addr) + 2, sizeof(__le32));
 		val = le32_to_cpu(*(__le32 *)temp);
-		if (netxen_nic_hw_write_wx
-		    (adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy), &val, 4))
+		if (adapter->hw_write_wx(adapter,
+				NETXEN_NIU_GB_STATION_ADDR_0(phy), &val, 4))
 			return -2;
 
 		netxen_niu_macaddr_get(adapter,
@@ -654,7 +653,7 @@ int netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
 
 	mac_cfg0 = 0;
 	netxen_gb_soft_reset(mac_cfg0);
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
 				   &mac_cfg0, 4))
 		return -EIO;
 	mac_cfg0 = 0;
@@ -666,7 +665,7 @@ int netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
 	netxen_gb_tx_reset_mac(mac_cfg0);
 	netxen_gb_rx_reset_mac(mac_cfg0);
 
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
 				   &mac_cfg0, 4))
 		return -EIO;
 	mac_cfg1 = 0;
@@ -679,7 +678,7 @@ int netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
 
 	if (mode == NETXEN_NIU_10_100_MB) {
 		netxen_gb_set_intfmode(mac_cfg1, 1);
-		if (netxen_nic_hw_write_wx(adapter,
+		if (adapter->hw_write_wx(adapter,
 					   NETXEN_NIU_GB_MAC_CONFIG_1(port),
 					   &mac_cfg1, 4))
 			return -EIO;
@@ -692,7 +691,7 @@ int netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
 
 	} else if (mode == NETXEN_NIU_1000_MB) {
 		netxen_gb_set_intfmode(mac_cfg1, 2);
-		if (netxen_nic_hw_write_wx(adapter,
+		if (adapter->hw_write_wx(adapter,
 					   NETXEN_NIU_GB_MAC_CONFIG_1(port),
 					   &mac_cfg1, 4))
 			return -EIO;
@@ -704,7 +703,7 @@ int netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
 	}
 	mii_cfg = 0;
 	netxen_gb_set_mii_mgmt_clockselect(mii_cfg, 7);
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(port),
+	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(port),
 				   &mii_cfg, 4))
 		return -EIO;
 	mac_cfg0 = 0;
@@ -713,7 +712,7 @@ int netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
 	netxen_gb_unset_rx_flowctl(mac_cfg0);
 	netxen_gb_unset_tx_flowctl(mac_cfg0);
 
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
 				   &mac_cfg0, 4))
 		return -EIO;
 	return 0;
@@ -730,7 +729,7 @@ int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter)
 		return -EINVAL;
 	mac_cfg0 = 0;
 	netxen_gb_soft_reset(mac_cfg0);
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
 				   &mac_cfg0, 4))
 		return -EIO;
 	return 0;
@@ -746,7 +745,7 @@ int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
 		return -EINVAL;
 
 	mac_cfg = 0;
-	if (netxen_nic_hw_write_wx(adapter,
+	if (adapter->hw_write_wx(adapter,
 		NETXEN_NIU_XGE_CONFIG_0 + (0x10000 * port), &mac_cfg, 4))
 		return -EIO;
 	return 0;
@@ -763,7 +762,7 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
 		return -EINVAL;
 
 	/* save previous contents */
-	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR,
+	if (adapter->hw_read_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR,
 				  &reg, 4))
 		return -EIO;
 	if (mode == NETXEN_NIU_PROMISC_MODE) {
@@ -801,7 +800,7 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
 			return -EIO;
 		}
 	}
-	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR,
+	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR,
 				   &reg, 4))
 		return -EIO;
 	return 0;
@@ -826,13 +825,13 @@ int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 	case 0:
 	    memcpy(temp + 2, addr, 2);
 	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
+	    if (adapter->hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
 				&val, 4))
 		return -EIO;
 
 	    memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
 	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
+	    if (adapter->hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
 				&val, 4))
 		return -EIO;
 	    break;
@@ -840,13 +839,13 @@ int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 	case 1:
 	    memcpy(temp + 2, addr, 2);
 	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XG1_STATION_ADDR_0_1,
+	    if (adapter->hw_write_wx(adapter, NETXEN_NIU_XG1_STATION_ADDR_0_1,
 				&val, 4))
 		return -EIO;
 
 	    memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
 	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XG1_STATION_ADDR_0_HI,
+	    if (adapter->hw_write_wx(adapter, NETXEN_NIU_XG1_STATION_ADDR_0_HI,
 				&val, 4))
 		return -EIO;
 	    break;
@@ -877,10 +876,10 @@ int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter,
 	if (phy != 0)
 		return -EINVAL;
 
-	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
+	if (adapter->hw_read_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
 				  &stationhigh, 4))
 		return -EIO;
-	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
+	if (adapter->hw_read_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
 				  &stationlow, 4))
 		return -EIO;
 	((__le32 *)val)[1] = cpu_to_le32(stationhigh);
@@ -901,7 +900,7 @@ int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 	if (port > NETXEN_NIU_MAX_XG_PORTS)
 		return -EINVAL;
 
-	if (netxen_nic_hw_read_wx(adapter,
+	if (adapter->hw_read_wx(adapter,
 		NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port), &reg, 4))
 			return -EIO;
 	if (mode == NETXEN_NIU_PROMISC_MODE)
-- 
1.5.4.3

