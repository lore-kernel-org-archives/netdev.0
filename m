From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 07/10] netxen: annotate register access functions
Date: Sun,  5 Apr 2009 23:27:57 -0700
Message-ID: <1238999280-8114-8-git-send-email-dhananjay@netxen.com>
References: <1238999280-8114-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:50789 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752610AbZDFG2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2009 02:28:06 -0400
In-Reply-To: <1238999280-8114-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o remove unnecessary length parameter since register access
  width is fixed 4 byte.
o remove superfluous pci_read_normalize and pci_write_normalize
  functions.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |   75 ++--------
 drivers/net/netxen/netxen_nic_ctx.c     |   18 +--
 drivers/net/netxen/netxen_nic_ethtool.c |   45 +++---
 drivers/net/netxen/netxen_nic_hw.c      |  229 ++++++++++++++-----------------
 drivers/net/netxen/netxen_nic_init.c    |   40 +++---
 drivers/net/netxen/netxen_nic_main.c    |   66 ++++-----
 drivers/net/netxen/netxen_nic_niu.c     |  110 ++++++---------
 7 files changed, 239 insertions(+), 344 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index e0f329f..1e4190d 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1258,14 +1258,12 @@ struct netxen_adapter {
 	int (*init_port) (struct netxen_adapter *, int);
 	int (*stop_port) (struct netxen_adapter *);
 
-	int (*hw_read_wx)(struct netxen_adapter *, ulong, void *, int);
-	int (*hw_write_wx)(struct netxen_adapter *, ulong, void *, int);
+	u32 (*hw_read_wx)(struct netxen_adapter *, ulong);
+	int (*hw_write_wx)(struct netxen_adapter *, ulong, u32);
 	int (*pci_mem_read)(struct netxen_adapter *, u64, void *, int);
 	int (*pci_mem_write)(struct netxen_adapter *, u64, void *, int);
 	int (*pci_write_immediate)(struct netxen_adapter *, u64, u32);
 	u32 (*pci_read_immediate)(struct netxen_adapter *, u64);
-	void (*pci_write_normalize)(struct netxen_adapter *, u64, u32);
-	u32 (*pci_read_normalize)(struct netxen_adapter *, u64);
 	unsigned long (*pci_set_window)(struct netxen_adapter *,
 			unsigned long long);
 
@@ -1302,46 +1300,6 @@ struct netxen_adapter {
 #define netxen_get_dma_watchdog_disabled(config_word) \
 	(((config_word) >> 1) & 0x1)
 
-/* Max number of xmit producer threads that can run simultaneously */
-#define	MAX_XMIT_PRODUCERS		16
-
-#define PCI_OFFSET_FIRST_RANGE(adapter, off)    \
-	((adapter)->ahw.pci_base0 + (off))
-#define PCI_OFFSET_SECOND_RANGE(adapter, off)   \
-	((adapter)->ahw.pci_base1 + (off) - SECOND_PAGE_GROUP_START)
-#define PCI_OFFSET_THIRD_RANGE(adapter, off)    \
-	((adapter)->ahw.pci_base2 + (off) - THIRD_PAGE_GROUP_START)
-
-static inline void __iomem *pci_base_offset(struct netxen_adapter *adapter,
-					    unsigned long off)
-{
-	if ((off < FIRST_PAGE_GROUP_END) && (off >= FIRST_PAGE_GROUP_START)) {
-		return (adapter->ahw.pci_base0 + off);
-	} else if ((off < SECOND_PAGE_GROUP_END) &&
-		   (off >= SECOND_PAGE_GROUP_START)) {
-		return (adapter->ahw.pci_base1 + off - SECOND_PAGE_GROUP_START);
-	} else if ((off < THIRD_PAGE_GROUP_END) &&
-		   (off >= THIRD_PAGE_GROUP_START)) {
-		return (adapter->ahw.pci_base2 + off - THIRD_PAGE_GROUP_START);
-	}
-	return NULL;
-}
-
-static inline void __iomem *pci_base(struct netxen_adapter *adapter,
-				     unsigned long off)
-{
-	if ((off < FIRST_PAGE_GROUP_END) && (off >= FIRST_PAGE_GROUP_START)) {
-		return adapter->ahw.pci_base0;
-	} else if ((off < SECOND_PAGE_GROUP_END) &&
-		   (off >= SECOND_PAGE_GROUP_START)) {
-		return adapter->ahw.pci_base1;
-	} else if ((off < THIRD_PAGE_GROUP_END) &&
-		   (off >= THIRD_PAGE_GROUP_START)) {
-		return adapter->ahw.pci_base2;
-	}
-	return NULL;
-}
-
 int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter);
 int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter);
 int netxen_niu_xgbe_disable_phy_interrupts(struct netxen_adapter *adapter);
@@ -1357,18 +1315,17 @@ int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu);
 void netxen_nic_reg_write(struct netxen_adapter *adapter, u64 off, u32 val);
 int netxen_nic_reg_read(struct netxen_adapter *adapter, u64 off);
 void netxen_nic_write_w0(struct netxen_adapter *adapter, u32 index, u32 value);
-void netxen_nic_read_w0(struct netxen_adapter *adapter, u32 index, u32 *value);
+u32 netxen_nic_read_w0(struct netxen_adapter *adapter, u32 index);
 void netxen_nic_write_w1(struct netxen_adapter *adapter, u32 index, u32 value);
-void netxen_nic_read_w1(struct netxen_adapter *adapter, u32 index, u32 *value);
+u32 netxen_nic_read_w1(struct netxen_adapter *adapter, u32 index);
 
 int netxen_nic_get_board_info(struct netxen_adapter *adapter);
 void netxen_nic_get_firmware_info(struct netxen_adapter *adapter);
 int netxen_nic_wol_supported(struct netxen_adapter *adapter);
 
-int netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter,
-		ulong off, void *data, int len);
+u32 netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter, ulong off);
 int netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter,
-		ulong off, void *data, int len);
+		ulong off, u32 data);
 int netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
 		u64 off, void *data, int size);
 int netxen_nic_pci_mem_write_128M(struct netxen_adapter *adapter,
@@ -1384,10 +1341,9 @@ unsigned long netxen_nic_pci_set_window_128M(struct netxen_adapter *adapter,
 void netxen_nic_pci_change_crbwindow_128M(struct netxen_adapter *adapter,
 		u32 wndw);
 
-int netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter,
-		ulong off, void *data, int len);
+u32 netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter, ulong off);
 int netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter,
-		ulong off, void *data, int len);
+		ulong off, u32 data);
 int netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 		u64 off, void *data, int size);
 int netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
@@ -1514,9 +1470,8 @@ dma_watchdog_shutdown_request(struct netxen_adapter *adapter)
 	u32 ctrl;
 
 	/* check if already inactive */
-	if (adapter->hw_read_wx(adapter,
-	    NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), &ctrl, 4))
-		printk(KERN_ERR "failed to read dma watchdog status\n");
+	ctrl = adapter->hw_read_wx(adapter,
+			NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL));
 
 	if (netxen_get_dma_watchdog_enabled(ctrl) == 0)
 		return 1;
@@ -1534,9 +1489,8 @@ dma_watchdog_shutdown_poll_result(struct netxen_adapter *adapter)
 {
 	u32 ctrl;
 
-	if (adapter->hw_read_wx(adapter,
-	    NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), &ctrl, 4))
-		printk(KERN_ERR "failed to read dma watchdog status\n");
+	ctrl = adapter->hw_read_wx(adapter,
+			NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL));
 
 	return (netxen_get_dma_watchdog_enabled(ctrl) == 0);
 }
@@ -1546,9 +1500,8 @@ dma_watchdog_wakeup(struct netxen_adapter *adapter)
 {
 	u32 ctrl;
 
-	if (adapter->hw_read_wx(adapter,
-		NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), &ctrl, 4))
-		printk(KERN_ERR "failed to read dma watchdog status\n");
+	ctrl = adapter->hw_read_wx(adapter,
+			NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL));
 
 	if (netxen_get_dma_watchdog_enabled(ctrl))
 		return 1;
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 7943351..7a13ee8 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -41,8 +41,8 @@ netxen_api_lock(struct netxen_adapter *adapter)
 
 	for (;;) {
 		/* Acquire PCIE HW semaphore5 */
-		netxen_nic_read_w0(adapter,
-			NETXEN_PCIE_REG(PCIE_SEM5_LOCK), &done);
+		done = netxen_nic_read_w0(adapter,
+			NETXEN_PCIE_REG(PCIE_SEM5_LOCK));
 
 		if (done == 1)
 			break;
@@ -65,11 +65,9 @@ netxen_api_lock(struct netxen_adapter *adapter)
 static int
 netxen_api_unlock(struct netxen_adapter *adapter)
 {
-	u32 val;
-
 	/* Release PCIE HW semaphore5 */
 	netxen_nic_read_w0(adapter,
-		NETXEN_PCIE_REG(PCIE_SEM5_UNLOCK), &val);
+		NETXEN_PCIE_REG(PCIE_SEM5_UNLOCK));
 	return 0;
 }
 
@@ -86,7 +84,7 @@ netxen_poll_rsp(struct netxen_adapter *adapter)
 		if (++timeout > NX_OS_CRB_RETRY_COUNT)
 			return NX_CDRP_RSP_TIMEOUT;
 
-		netxen_nic_read_w1(adapter, NX_CDRP_CRB_OFFSET, &rsp);
+		rsp = netxen_nic_read_w1(adapter, NX_CDRP_CRB_OFFSET);
 	} while (!NX_CDRP_IS_RSP(rsp));
 
 	return rsp;
@@ -125,7 +123,7 @@ netxen_issue_cmd(struct netxen_adapter *adapter,
 
 		rcode = NX_RCODE_TIMEOUT;
 	} else if (rsp == NX_CDRP_RSP_FAIL) {
-		netxen_nic_read_w1(adapter, NX_ARG1_CRB_OFFSET, &rcode);
+		rcode = netxen_nic_read_w1(adapter, NX_ARG1_CRB_OFFSET);
 
 		printk(KERN_ERR "%s: failed card response code:0x%x\n",
 				netxen_nic_driver_name, rcode);
@@ -517,11 +515,11 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 	adapter->ctx_desc->sts_ring_addr = cpu_to_le64(sds_ring->phys_addr);
 	adapter->ctx_desc->sts_ring_size = cpu_to_le32(sds_ring->num_desc);
 
-	adapter->pci_write_normalize(adapter, CRB_CTX_ADDR_REG_LO(func_id),
+	adapter->hw_write_wx(adapter, CRB_CTX_ADDR_REG_LO(func_id),
 			lower32(adapter->ctx_desc_phys_addr));
-	adapter->pci_write_normalize(adapter, CRB_CTX_ADDR_REG_HI(func_id),
+	adapter->hw_write_wx(adapter, CRB_CTX_ADDR_REG_HI(func_id),
 			upper32(adapter->ctx_desc_phys_addr));
-	adapter->pci_write_normalize(adapter, CRB_CTX_SIGNATURE_REG(func_id),
+	adapter->hw_write_wx(adapter, CRB_CTX_SIGNATURE_REG(func_id),
 			NETXEN_CTX_SIGNATURE | func_id);
 	return 0;
 }
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 5fde9e0..6c5a111 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -92,11 +92,11 @@ netxen_nic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 	strncpy(drvinfo->driver, netxen_nic_driver_name, 32);
 	strncpy(drvinfo->version, NETXEN_NIC_LINUX_VERSIONID, 32);
 	write_lock_irqsave(&adapter->adapter_lock, flags);
-	fw_major = adapter->pci_read_normalize(adapter,
+	fw_major = adapter->hw_read_wx(adapter,
 					NETXEN_FW_VERSION_MAJOR);
-	fw_minor = adapter->pci_read_normalize(adapter,
+	fw_minor = adapter->hw_read_wx(adapter,
 					NETXEN_FW_VERSION_MINOR);
-	fw_build = adapter->pci_read_normalize(adapter,
+	fw_build = adapter->hw_read_wx(adapter,
 					NETXEN_FW_VERSION_SUB);
 	write_unlock_irqrestore(&adapter->adapter_lock, flags);
 	sprintf(drvinfo->fw_version, "%d.%d.%d", fw_major, fw_minor, fw_build);
@@ -135,7 +135,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
 		u32 val;
 
-		adapter->hw_read_wx(adapter, NETXEN_PORT_MODE_ADDR, &val, 4);
+		val = adapter->hw_read_wx(adapter, NETXEN_PORT_MODE_ADDR);
 		if (val == NETXEN_PORT_MODE_802_3_AP) {
 			ecmd->supported = SUPPORTED_1000baseT_Full;
 			ecmd->advertising = ADVERTISED_1000baseT_Full;
@@ -156,8 +156,8 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 			u16 pcifn = adapter->ahw.pci_func;
 
-			adapter->hw_read_wx(adapter,
-				P3_LINK_SPEED_REG(pcifn), &val, 4);
+			val = adapter->hw_read_wx(adapter,
+				P3_LINK_SPEED_REG(pcifn));
 			ecmd->speed = P3_LINK_SPEED_MHZ *
 					P3_LINK_SPEED_VAL(pcifn, val);
 		} else
@@ -423,12 +423,12 @@ netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 	regs->version = (1 << 24) | (adapter->ahw.revision_id << 16) |
 	    (adapter->pdev)->device;
 	/* which mode */
-	adapter->hw_read_wx(adapter, NETXEN_NIU_MODE, &regs_buff[0], 4);
+	regs_buff[0] = adapter->hw_read_wx(adapter, NETXEN_NIU_MODE);
 	mode = regs_buff[0];
 
 	/* Common registers to all the modes */
-	adapter->hw_read_wx(adapter,
-			NETXEN_NIU_STRAP_VALUE_SAVE_HIGHER, &regs_buff[2], 4);
+	regs_buff[2] = adapter->hw_read_wx(adapter,
+			NETXEN_NIU_STRAP_VALUE_SAVE_HIGHER);
 	/* GB/XGB Mode */
 	mode = (mode / 2) - 1;
 	window = 0;
@@ -439,9 +439,8 @@ netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 				window = adapter->physical_port *
 					NETXEN_NIC_PORT_WINDOW;
 
-			adapter->hw_read_wx(adapter,
-				niu_registers[mode].reg[i - 3] + window,
-				&regs_buff[i], 4);
+			regs_buff[i] = adapter->hw_read_wx(adapter,
+				niu_registers[mode].reg[i - 3] + window);
 		}
 
 	}
@@ -465,7 +464,7 @@ static u32 netxen_nic_test_link(struct net_device *dev)
 			return !val;
 		}
 	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
-		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
+		val = adapter->hw_read_wx(adapter, CRB_XG_STATE);
 		return (val == XG_LINK_UP) ? 0 : 1;
 	}
 	return -EIO;
@@ -529,10 +528,10 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 		if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
 			return;
 		/* get flow control settings */
-		netxen_nic_read_w0(adapter,NETXEN_NIU_GB_MAC_CONFIG_0(port),
-				&val);
+		val = netxen_nic_read_w0(adapter,
+				NETXEN_NIU_GB_MAC_CONFIG_0(port));
 		pause->rx_pause = netxen_gb_get_rx_flowctl(val);
-		netxen_nic_read_w0(adapter, NETXEN_NIU_GB_PAUSE_CTL, &val);
+		val = netxen_nic_read_w0(adapter, NETXEN_NIU_GB_PAUSE_CTL);
 		switch (port) {
 			case 0:
 				pause->tx_pause = !(netxen_gb_get_gb0_mask(val));
@@ -552,7 +551,7 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 		if ((port < 0) || (port > NETXEN_NIU_MAX_XG_PORTS))
 			return;
 		pause->rx_pause = 1;
-		netxen_nic_read_w0(adapter, NETXEN_NIU_XG_PAUSE_CTL, &val);
+		val = netxen_nic_read_w0(adapter, NETXEN_NIU_XG_PAUSE_CTL);
 		if (port == 0)
 			pause->tx_pause = !(netxen_xg_get_xg0_mask(val));
 		else
@@ -575,8 +574,8 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 		if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
 			return -EIO;
 		/* set flow control */
-		netxen_nic_read_w0(adapter,
-					NETXEN_NIU_GB_MAC_CONFIG_0(port), &val);
+		val = netxen_nic_read_w0(adapter,
+					NETXEN_NIU_GB_MAC_CONFIG_0(port));
 
 		if (pause->rx_pause)
 			netxen_gb_rx_flowctl(val);
@@ -586,7 +585,7 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 		netxen_nic_write_w0(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
 				val);
 		/* set autoneg */
-		netxen_nic_read_w0(adapter, NETXEN_NIU_GB_PAUSE_CTL, &val);
+		val = netxen_nic_read_w0(adapter, NETXEN_NIU_GB_PAUSE_CTL);
 		switch (port) {
 			case 0:
 				if (pause->tx_pause)
@@ -618,7 +617,7 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
 		if ((port < 0) || (port > NETXEN_NIU_MAX_XG_PORTS))
 			return -EIO;
-		netxen_nic_read_w0(adapter, NETXEN_NIU_XG_PAUSE_CTL, &val);
+		val = netxen_nic_read_w0(adapter, NETXEN_NIU_XG_PAUSE_CTL);
 		if (port == 0) {
 			if (pause->tx_pause)
 				netxen_xg_unset_xg0_mask(val);
@@ -644,14 +643,14 @@ static int netxen_nic_reg_test(struct net_device *dev)
 	struct netxen_adapter *adapter = netdev_priv(dev);
 	u32 data_read, data_written;
 
-	netxen_nic_read_w0(adapter, NETXEN_PCIX_PH_REG(0), &data_read);
+	data_read = netxen_nic_read_w0(adapter, NETXEN_PCIX_PH_REG(0));
 	if ((data_read & 0xffff) != PHAN_VENDOR_ID)
 	return 1;
 
 	data_written = (u32)0xa5a5a5a5;
 
 	netxen_nic_reg_write(adapter, CRB_SCRATCHPAD_TEST, data_written);
-	data_read = adapter->pci_read_normalize(adapter, CRB_SCRATCHPAD_TEST);
+	data_read = adapter->hw_read_wx(adapter, CRB_SCRATCHPAD_TEST);
 	if (data_written != data_read)
 		return 1;
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 33444a2..87cda65 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -63,6 +63,31 @@ static inline void writeq(u64 val, void __iomem *addr)
 }
 #endif
 
+#define ADDR_IN_RANGE(addr, low, high)	\
+	(((addr) < (high)) && ((addr) >= (low)))
+
+#define PCI_OFFSET_FIRST_RANGE(adapter, off)    \
+	((adapter)->ahw.pci_base0 + (off))
+#define PCI_OFFSET_SECOND_RANGE(adapter, off)   \
+	((adapter)->ahw.pci_base1 + (off) - SECOND_PAGE_GROUP_START)
+#define PCI_OFFSET_THIRD_RANGE(adapter, off)    \
+	((adapter)->ahw.pci_base2 + (off) - THIRD_PAGE_GROUP_START)
+
+static void __iomem *pci_base_offset(struct netxen_adapter *adapter,
+					    unsigned long off)
+{
+	if (ADDR_IN_RANGE(off, FIRST_PAGE_GROUP_START, FIRST_PAGE_GROUP_END))
+		return PCI_OFFSET_FIRST_RANGE(adapter, off);
+
+	if (ADDR_IN_RANGE(off, SECOND_PAGE_GROUP_START, SECOND_PAGE_GROUP_END))
+		return PCI_OFFSET_SECOND_RANGE(adapter, off);
+
+	if (ADDR_IN_RANGE(off, THIRD_PAGE_GROUP_START, THIRD_PAGE_GROUP_END))
+		return PCI_OFFSET_THIRD_RANGE(adapter, off);
+
+	return NULL;
+}
+
 #define CRB_WIN_LOCK_TIMEOUT 100000000
 static crb_128M_2M_block_map_t crb_128M_2M_map[64] = {
     {{{0, 0,         0,         0} } },		/* 0: PCI */
@@ -294,18 +319,8 @@ static unsigned crb_hub_agt[64] =
 
 /*  PCI Windowing for DDR regions.  */
 
-#define ADDR_IN_RANGE(addr, low, high)	\
-	(((addr) <= (high)) && ((addr) >= (low)))
-
 #define NETXEN_WINDOW_ONE 	0x2000000 /*CRB Window: bit 25 of CRB address */
 
-#define NETXEN_NIC_ZERO_PAUSE_ADDR     0ULL
-#define NETXEN_NIC_UNIT_PAUSE_ADDR     0x200ULL
-#define NETXEN_NIC_EPG_PAUSE_ADDR1     0x2200010000c28001ULL
-#define NETXEN_NIC_EPG_PAUSE_ADDR2     0x0100088866554433ULL
-
-#define NETXEN_NIC_WINDOW_MARGIN 0x100000
-
 int netxen_nic_set_mac(struct net_device *netdev, void *p)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
@@ -346,9 +361,9 @@ netxen_nic_enable_mcast_filter(struct netxen_adapter *adapter)
 	if (adapter->mc_enabled)
 		return 0;
 
-	adapter->hw_read_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
+	val = adapter->hw_read_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG);
 	val |= (1UL << (28+port));
-	adapter->hw_write_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
+	adapter->hw_write_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, val);
 
 	/* add broadcast addr to filter */
 	val = 0xffffff;
@@ -377,9 +392,9 @@ netxen_nic_disable_mcast_filter(struct netxen_adapter *adapter)
 	if (!adapter->mc_enabled)
 		return 0;
 
-	adapter->hw_read_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
+	val = adapter->hw_read_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG);
 	val &= ~(1UL << (28+port));
-	adapter->hw_write_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, &val, 4);
+	adapter->hw_write_wx(adapter, NETXEN_MAC_ADDR_CNTL_REG, val);
 
 	val = MAC_HI(addr);
 	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port, 0), val);
@@ -848,8 +863,8 @@ int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
 	crbaddr = CRB_MAC_BLOCK_START +
 		(4 * ((pci_func/2) * 3)) + (4 * (pci_func & 1));
 
-	adapter->hw_read_wx(adapter, crbaddr, &mac_lo, 4);
-	adapter->hw_read_wx(adapter, crbaddr+4, &mac_hi, 4);
+	mac_lo = adapter->hw_read_wx(adapter, crbaddr);
+	mac_hi = adapter->hw_read_wx(adapter, crbaddr+4);
 
 	if (pci_func & 1)
 		*mac = le64_to_cpu((mac_lo >> 16) | ((u64)mac_hi << 16));
@@ -867,8 +882,8 @@ static int crb_win_lock(struct netxen_adapter *adapter)
 
 	while (!done) {
 		/* acquire semaphore3 from PCI HW block */
-		adapter->hw_read_wx(adapter,
-				NETXEN_PCIE_REG(PCIE_SEM7_LOCK), &done, 4);
+		done = adapter->hw_read_wx(adapter,
+				NETXEN_PCIE_REG(PCIE_SEM7_LOCK));
 		if (done == 1)
 			break;
 		if (timeout >= CRB_WIN_LOCK_TIMEOUT)
@@ -885,8 +900,8 @@ static void crb_win_unlock(struct netxen_adapter *adapter)
 {
 	int val;
 
-	adapter->hw_read_wx(adapter,
-			NETXEN_PCIE_REG(PCIE_SEM7_UNLOCK), &val, 4);
+	val = adapter->hw_read_wx(adapter,
+			NETXEN_PCIE_REG(PCIE_SEM7_UNLOCK));
 }
 
 /*
@@ -1022,7 +1037,7 @@ netxen_do_load_firmware(struct netxen_adapter *adapter, const char *fwname,
 		dev_info(&pdev->dev, "loading firmware from flash\n");
 
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
-		adapter->pci_write_normalize(adapter,
+		adapter->hw_write_wx(adapter,
 				NETXEN_ROMUSB_GLB_CAS_RST, 1);
 
 	if (fw) {
@@ -1075,12 +1090,12 @@ netxen_do_load_firmware(struct netxen_adapter *adapter, const char *fwname,
 	msleep(1);
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		adapter->pci_write_normalize(adapter,
+		adapter->hw_write_wx(adapter,
 				NETXEN_ROMUSB_GLB_SW_RESET, 0x80001d);
 	else {
-		adapter->pci_write_normalize(adapter,
+		adapter->hw_write_wx(adapter,
 				NETXEN_ROMUSB_GLB_CHIP_CLK_CTRL, 0x3fff);
-		adapter->pci_write_normalize(adapter,
+		adapter->hw_write_wx(adapter,
 				NETXEN_ROMUSB_GLB_CAS_RST, 0);
 	}
 
@@ -1168,8 +1183,8 @@ request_mn:
 	netxen_rom_fast_read(adapter,
 			NX_FW_VERSION_OFFSET, (int *)&flashed_ver);
 	if (flashed_ver >= NETXEN_VERSION_CODE(4, 0, 220)) {
-		adapter->hw_read_wx(adapter,
-				NX_PEG_TUNE_CAPABILITY, &capability, 4);
+		capability = adapter->hw_read_wx(adapter,
+				NX_PEG_TUNE_CAPABILITY);
 		if (capability & NX_PEG_TUNE_MN_PRESENT) {
 			fw_type = NX_P3_MN_ROMIMAGE;
 			goto request_fw;
@@ -1209,13 +1224,10 @@ load_fw:
 }
 
 int
-netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter,
-		ulong off, void *data, int len)
+netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter, ulong off, u32 data)
 {
 	void __iomem *addr;
 
-	BUG_ON(len != 4);
-
 	if (ADDR_IN_WINDOW1(off)) {
 		addr = NETXEN_CRB_NORMALIZE(adapter, off);
 	} else {		/* Window 0 */
@@ -1228,7 +1240,7 @@ netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter,
 		return 1;
 	}
 
-	writel(*(u32 *) data, addr);
+	writel(data, addr);
 
 	if (!ADDR_IN_WINDOW1(off))
 		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
@@ -1236,13 +1248,11 @@ netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter,
 	return 0;
 }
 
-int
-netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter,
-		ulong off, void *data, int len)
+u32
+netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter, ulong off)
 {
 	void __iomem *addr;
-
-	BUG_ON(len != 4);
+	u32 data;
 
 	if (ADDR_IN_WINDOW1(off)) {	/* Window 1 */
 		addr = NETXEN_CRB_NORMALIZE(adapter, off);
@@ -1256,24 +1266,21 @@ netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter,
 		return 1;
 	}
 
-	*(u32 *)data = readl(addr);
+	data = readl(addr);
 
 	if (!ADDR_IN_WINDOW1(off))
 		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
 
-	return 0;
+	return data;
 }
 
 int
-netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter,
-		ulong off, void *data, int len)
+netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter, ulong off, u32 data)
 {
 	unsigned long flags = 0;
 	int rv;
 
-	BUG_ON(len != 4);
-
-	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off, len);
+	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off, 4);
 
 	if (rv == -1) {
 		printk(KERN_ERR "%s: invalid offset: 0x%016lx\n",
@@ -1286,26 +1293,24 @@ netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter,
 		write_lock_irqsave(&adapter->adapter_lock, flags);
 		crb_win_lock(adapter);
 		netxen_nic_pci_set_crbwindow_2M(adapter, &off);
-		writel(*(uint32_t *)data, (void __iomem *)off);
+		writel(data, (void __iomem *)off);
 		crb_win_unlock(adapter);
 		write_unlock_irqrestore(&adapter->adapter_lock, flags);
 	} else
-		writel(*(uint32_t *)data, (void __iomem *)off);
+		writel(data, (void __iomem *)off);
 
 
 	return 0;
 }
 
-int
-netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter,
-		ulong off, void *data, int len)
+u32
+netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter, ulong off)
 {
 	unsigned long flags = 0;
 	int rv;
+	u32 data;
 
-	BUG_ON(len != 4);
-
-	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off, len);
+	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off, 4);
 
 	if (rv == -1) {
 		printk(KERN_ERR "%s: invalid offset: 0x%016lx\n",
@@ -1318,47 +1323,45 @@ netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter,
 		write_lock_irqsave(&adapter->adapter_lock, flags);
 		crb_win_lock(adapter);
 		netxen_nic_pci_set_crbwindow_2M(adapter, &off);
-		*(uint32_t *)data = readl((void __iomem *)off);
+		data = readl((void __iomem *)off);
 		crb_win_unlock(adapter);
 		write_unlock_irqrestore(&adapter->adapter_lock, flags);
 	} else
-		*(uint32_t *)data = readl((void __iomem *)off);
+		data = readl((void __iomem *)off);
 
-	return 0;
+	return data;
 }
 
 void netxen_nic_reg_write(struct netxen_adapter *adapter, u64 off, u32 val)
 {
-	adapter->hw_write_wx(adapter, off, &val, 4);
+	adapter->hw_write_wx(adapter, off, val);
 }
 
 int netxen_nic_reg_read(struct netxen_adapter *adapter, u64 off)
 {
-	int val;
-	adapter->hw_read_wx(adapter, off, &val, 4);
-	return val;
+	return adapter->hw_read_wx(adapter, off);
 }
 
 /* Change the window to 0, write and change back to window 1. */
 void netxen_nic_write_w0(struct netxen_adapter *adapter, u32 index, u32 value)
 {
-	adapter->hw_write_wx(adapter, index, &value, 4);
+	adapter->hw_write_wx(adapter, index, value);
 }
 
 /* Change the window to 0, read and change back to window 1. */
-void netxen_nic_read_w0(struct netxen_adapter *adapter, u32 index, u32 *value)
+u32 netxen_nic_read_w0(struct netxen_adapter *adapter, u32 index)
 {
-	adapter->hw_read_wx(adapter, index, value, 4);
+	return adapter->hw_read_wx(adapter, index);
 }
 
 void netxen_nic_write_w1(struct netxen_adapter *adapter, u32 index, u32 value)
 {
-	adapter->hw_write_wx(adapter, index, &value, 4);
+	adapter->hw_write_wx(adapter, index, value);
 }
 
-void netxen_nic_read_w1(struct netxen_adapter *adapter, u32 index, u32 *value)
+u32 netxen_nic_read_w1(struct netxen_adapter *adapter, u32 index)
 {
-	adapter->hw_read_wx(adapter, index, value, 4);
+	return adapter->hw_read_wx(adapter, index);
 }
 
 /*
@@ -1461,17 +1464,6 @@ u32 netxen_nic_pci_read_immediate_128M(struct netxen_adapter *adapter, u64 off)
 	return readl((void __iomem *)(pci_base_offset(adapter, off)));
 }
 
-void netxen_nic_pci_write_normalize_128M(struct netxen_adapter *adapter,
-		u64 off, u32 data)
-{
-	writel(data, NETXEN_CRB_NORMALIZE(adapter, off));
-}
-
-u32 netxen_nic_pci_read_normalize_128M(struct netxen_adapter *adapter, u64 off)
-{
-	return readl(NETXEN_CRB_NORMALIZE(adapter, off));
-}
-
 unsigned long
 netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 		unsigned long long addr)
@@ -1485,10 +1477,9 @@ netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 		adapter->ahw.ddr_mn_window = window;
 		adapter->hw_write_wx(adapter,
 				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
-				&window, 4);
-		adapter->hw_read_wx(adapter,
-				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
-				&win_read, 4);
+				window);
+		win_read = adapter->hw_read_wx(adapter,
+				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE);
 		if ((win_read << 17) != window) {
 			printk(KERN_INFO "Written MNwin (0x%x) != "
 				"Read MNwin (0x%x)\n", window, win_read);
@@ -1505,10 +1496,9 @@ netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 		adapter->ahw.ddr_mn_window = window;
 		adapter->hw_write_wx(adapter,
 				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
-				&window, 4);
-		adapter->hw_read_wx(adapter,
-				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
-				&win_read, 4);
+				window);
+		win_read = adapter->hw_read_wx(adapter,
+				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE);
 		if ((win_read >> 7) != window) {
 			printk(KERN_INFO "%s: Written OCMwin (0x%x) != "
 					"Read OCMwin (0x%x)\n",
@@ -1523,10 +1513,9 @@ netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 		adapter->ahw.qdr_sn_window = window;
 		adapter->hw_write_wx(adapter,
 				adapter->ahw.ms_win_crb | NETXEN_PCI_CRBSPACE,
-				&window, 4);
-		adapter->hw_read_wx(adapter,
-				adapter->ahw.ms_win_crb | NETXEN_PCI_CRBSPACE,
-				&win_read, 4);
+				window);
+		win_read = adapter->hw_read_wx(adapter,
+				adapter->ahw.ms_win_crb | NETXEN_PCI_CRBSPACE);
 		if (win_read != window) {
 			printk(KERN_INFO "%s: Written MSwin (0x%x) != "
 					"Read MSwin (0x%x)\n",
@@ -1973,26 +1962,26 @@ netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
 	for (i = 0; i < loop; i++) {
 		temp = off8 + (i << 3);
 		adapter->hw_write_wx(adapter,
-				mem_crb+MIU_TEST_AGT_ADDR_LO, &temp, 4);
+				mem_crb+MIU_TEST_AGT_ADDR_LO, temp);
 		temp = 0;
 		adapter->hw_write_wx(adapter,
-				mem_crb+MIU_TEST_AGT_ADDR_HI, &temp, 4);
+				mem_crb+MIU_TEST_AGT_ADDR_HI, temp);
 		temp = word[i] & 0xffffffff;
 		adapter->hw_write_wx(adapter,
-				mem_crb+MIU_TEST_AGT_WRDATA_LO, &temp, 4);
+				mem_crb+MIU_TEST_AGT_WRDATA_LO, temp);
 		temp = (word[i] >> 32) & 0xffffffff;
 		adapter->hw_write_wx(adapter,
-				mem_crb+MIU_TEST_AGT_WRDATA_HI, &temp, 4);
+				mem_crb+MIU_TEST_AGT_WRDATA_HI, temp);
 		temp = MIU_TA_CTL_ENABLE | MIU_TA_CTL_WRITE;
 		adapter->hw_write_wx(adapter,
-				mem_crb+MIU_TEST_AGT_CTRL, &temp, 4);
+				mem_crb+MIU_TEST_AGT_CTRL, temp);
 		temp = MIU_TA_CTL_START | MIU_TA_CTL_ENABLE | MIU_TA_CTL_WRITE;
 		adapter->hw_write_wx(adapter,
-				mem_crb+MIU_TEST_AGT_CTRL, &temp, 4);
+				mem_crb+MIU_TEST_AGT_CTRL, temp);
 
 		for (j = 0; j < MAX_CTL_CHECK; j++) {
-			adapter->hw_read_wx(adapter,
-					mem_crb + MIU_TEST_AGT_CTRL, &temp, 4);
+			temp = adapter->hw_read_wx(adapter,
+					mem_crb + MIU_TEST_AGT_CTRL);
 			if ((temp & MIU_TA_CTL_BUSY) == 0)
 				break;
 		}
@@ -2050,20 +2039,20 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 	for (i = 0; i < loop; i++) {
 		temp = off8 + (i << 3);
 		adapter->hw_write_wx(adapter,
-				mem_crb + MIU_TEST_AGT_ADDR_LO, &temp, 4);
+				mem_crb + MIU_TEST_AGT_ADDR_LO, temp);
 		temp = 0;
 		adapter->hw_write_wx(adapter,
-				mem_crb + MIU_TEST_AGT_ADDR_HI, &temp, 4);
+				mem_crb + MIU_TEST_AGT_ADDR_HI, temp);
 		temp = MIU_TA_CTL_ENABLE;
 		adapter->hw_write_wx(adapter,
-				mem_crb + MIU_TEST_AGT_CTRL, &temp, 4);
+				mem_crb + MIU_TEST_AGT_CTRL, temp);
 		temp = MIU_TA_CTL_START | MIU_TA_CTL_ENABLE;
 		adapter->hw_write_wx(adapter,
-				mem_crb + MIU_TEST_AGT_CTRL, &temp, 4);
+				mem_crb + MIU_TEST_AGT_CTRL, temp);
 
 		for (j = 0; j < MAX_CTL_CHECK; j++) {
-			adapter->hw_read_wx(adapter,
-					mem_crb + MIU_TEST_AGT_CTRL, &temp, 4);
+			temp = adapter->hw_read_wx(adapter,
+					mem_crb + MIU_TEST_AGT_CTRL);
 			if ((temp & MIU_TA_CTL_BUSY) == 0)
 				break;
 		}
@@ -2078,8 +2067,8 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 		start = off0[i] >> 2;
 		end   = (off0[i] + sz[i] - 1) >> 2;
 		for (k = start; k <= end; k++) {
-			adapter->hw_read_wx(adapter,
-				mem_crb + MIU_TEST_AGT_RDDATA(k), &temp, 4);
+			temp = adapter->hw_read_wx(adapter,
+				mem_crb + MIU_TEST_AGT_RDDATA(k));
 			word[i] |= ((uint64_t)temp << (32 * k));
 		}
 	}
@@ -2122,29 +2111,14 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 int netxen_nic_pci_write_immediate_2M(struct netxen_adapter *adapter,
 		u64 off, u32 data)
 {
-	adapter->hw_write_wx(adapter, off, &data, 4);
+	adapter->hw_write_wx(adapter, off, data);
 
 	return 0;
 }
 
 u32 netxen_nic_pci_read_immediate_2M(struct netxen_adapter *adapter, u64 off)
 {
-	u32 temp;
-	adapter->hw_read_wx(adapter, off, &temp, 4);
-	return temp;
-}
-
-void netxen_nic_pci_write_normalize_2M(struct netxen_adapter *adapter,
-		u64 off, u32 data)
-{
-	adapter->hw_write_wx(adapter, off, &data, 4);
-}
-
-u32 netxen_nic_pci_read_normalize_2M(struct netxen_adapter *adapter, u64 off)
-{
-	u32 temp;
-	adapter->hw_read_wx(adapter, off, &temp, 4);
-	return temp;
+	return adapter->hw_read_wx(adapter, off);
 }
 
 int netxen_nic_get_board_info(struct netxen_adapter *adapter)
@@ -2253,7 +2227,7 @@ void
 netxen_crb_writelit_adapter(struct netxen_adapter *adapter,
 		unsigned long off, int data)
 {
-	adapter->hw_write_wx(adapter, off, &data, 4);
+	adapter->hw_write_wx(adapter, off, data);
 }
 
 void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
@@ -2270,8 +2244,8 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 	}
 
 	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
-		adapter->hw_read_wx(adapter,
-				NETXEN_PORT_MODE_ADDR, &port_mode, 4);
+		port_mode = adapter->hw_read_wx(adapter,
+				NETXEN_PORT_MODE_ADDR);
 		if (port_mode == NETXEN_PORT_MODE_802_3_AP) {
 			adapter->link_speed   = SPEED_1000;
 			adapter->link_duplex  = DUPLEX_FULL;
@@ -2348,9 +2322,9 @@ void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
 		addr += sizeof(u32);
 	}
 
-	adapter->hw_read_wx(adapter, NETXEN_FW_VERSION_MAJOR, &fw_major, 4);
-	adapter->hw_read_wx(adapter, NETXEN_FW_VERSION_MINOR, &fw_minor, 4);
-	adapter->hw_read_wx(adapter, NETXEN_FW_VERSION_SUB, &fw_build, 4);
+	fw_major = adapter->hw_read_wx(adapter, NETXEN_FW_VERSION_MAJOR);
+	fw_minor = adapter->hw_read_wx(adapter, NETXEN_FW_VERSION_MINOR);
+	fw_build = adapter->hw_read_wx(adapter, NETXEN_FW_VERSION_SUB);
 
 	adapter->fw_major = fw_major;
 	adapter->fw_version = NETXEN_VERSION_CODE(fw_major, fw_minor, fw_build);
@@ -2373,8 +2347,7 @@ void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
 			fw_major, fw_minor, fw_build);
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-		adapter->hw_read_wx(adapter,
-				NETXEN_MIU_MN_CONTROL, &i, 4);
+		i = adapter->hw_read_wx(adapter, NETXEN_MIU_MN_CONTROL);
 		adapter->ahw.cut_through = (i & 0x4) ? 1 : 0;
 		dev_info(&pdev->dev, "firmware running in %s mode\n",
 		adapter->ahw.cut_through ? "cut-through" : "legacy");
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 974783c..83116c2 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -368,8 +368,8 @@ static int rom_lock(struct netxen_adapter *adapter)
 
 	while (!done) {
 		/* acquire semaphore2 from PCI HW block */
-		netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(PCIE_SEM2_LOCK),
-				   &done);
+		done = netxen_nic_read_w0(adapter,
+				NETXEN_PCIE_REG(PCIE_SEM2_LOCK));
 		if (done == 1)
 			break;
 		if (timeout >= rom_lock_timeout)
@@ -411,10 +411,8 @@ static int netxen_wait_rom_done(struct netxen_adapter *adapter)
 
 static void netxen_rom_unlock(struct netxen_adapter *adapter)
 {
-	u32 val;
-
 	/* release semaphore2 */
-	netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(PCIE_SEM2_UNLOCK), &val);
+	netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(PCIE_SEM2_UNLOCK));
 
 }
 
@@ -623,7 +621,7 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 			}
 		}
 
-		adapter->hw_write_wx(adapter, off, &buf[i].data, 4);
+		adapter->hw_write_wx(adapter, off, buf[i].data);
 
 		msleep(init_delay);
 	}
@@ -633,8 +631,8 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 
 	/* unreset_net_cache */
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
-		adapter->hw_read_wx(adapter,
-				NETXEN_ROMUSB_GLB_SW_RESET, &val, 4);
+		val = adapter->hw_read_wx(adapter,
+				NETXEN_ROMUSB_GLB_SW_RESET);
 		netxen_crb_writelit_adapter(adapter,
 				NETXEN_ROMUSB_GLB_SW_RESET, (val & 0xffffff0f));
 	}
@@ -683,12 +681,12 @@ int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
 	hi = (addr >> 32) & 0xffffffff;
 	lo = addr & 0xffffffff;
 
-	adapter->pci_write_normalize(adapter, CRB_HOST_DUMMY_BUF_ADDR_HI, hi);
-	adapter->pci_write_normalize(adapter, CRB_HOST_DUMMY_BUF_ADDR_LO, lo);
+	adapter->hw_write_wx(adapter, CRB_HOST_DUMMY_BUF_ADDR_HI, hi);
+	adapter->hw_write_wx(adapter, CRB_HOST_DUMMY_BUF_ADDR_LO, lo);
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 		uint32_t temp = 0;
-		adapter->hw_write_wx(adapter, CRB_HOST_DUMMY_BUF, &temp, 4);
+		adapter->hw_write_wx(adapter, CRB_HOST_DUMMY_BUF, temp);
 	}
 
 	return 0;
@@ -730,7 +728,7 @@ int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
 
 	if (!pegtune_val) {
 		do {
-			val = adapter->pci_read_normalize(adapter,
+			val = adapter->hw_read_wx(adapter,
 					CRB_CMDPEG_STATE);
 
 			if (val == PHAN_INITIALIZE_COMPLETE ||
@@ -742,7 +740,7 @@ int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
 		} while (--retries);
 
 		if (!retries) {
-			pegtune_val = adapter->pci_read_normalize(adapter,
+			pegtune_val = adapter->hw_read_wx(adapter,
 					NETXEN_ROMUSB_GLB_PEGTUNE_DONE);
 			printk(KERN_WARNING "netxen_phantom_init: init failed, "
 					"pegtune_val=%x\n", pegtune_val);
@@ -760,7 +758,7 @@ netxen_receive_peg_ready(struct netxen_adapter *adapter)
 	int retries = 2000;
 
 	do {
-		val = adapter->pci_read_normalize(adapter, CRB_RCVPEG_STATE);
+		val = adapter->hw_read_wx(adapter, CRB_RCVPEG_STATE);
 
 		if (val == PHAN_PEG_RCV_INITIALIZED)
 			return 0;
@@ -786,13 +784,13 @@ int netxen_init_firmware(struct netxen_adapter *adapter)
 	if (err)
 		return err;
 
-	adapter->pci_write_normalize(adapter,
+	adapter->hw_write_wx(adapter,
 			CRB_NIC_CAPABILITIES_HOST, INTR_SCHEME_PERPORT);
-	adapter->pci_write_normalize(adapter,
+	adapter->hw_write_wx(adapter,
 			CRB_NIC_MSI_MODE_HOST, MSI_MODE_MULTIFUNC);
-	adapter->pci_write_normalize(adapter,
+	adapter->hw_write_wx(adapter,
 			CRB_MPORT_MODE, MPORT_MULTI_FUNCTION_MODE);
-	adapter->pci_write_normalize(adapter,
+	adapter->hw_write_wx(adapter,
 			CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
 
 	if (adapter->fw_version >= NETXEN_VERSION_CODE(4, 0, 222)) {
@@ -1059,7 +1057,7 @@ skip:
 
 	if (count) {
 		sds_ring->consumer = consumer;
-		adapter->pci_write_normalize(adapter,
+		adapter->hw_write_wx(adapter,
 				sds_ring->crb_sts_consumer, consumer);
 	}
 
@@ -1178,7 +1176,7 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid,
 
 	if (count) {
 		rds_ring->producer = producer;
-		adapter->pci_write_normalize(adapter,
+		adapter->hw_write_wx(adapter,
 				rds_ring->crb_rcv_producer,
 				(producer-1) & (rds_ring->num_desc-1));
 
@@ -1239,7 +1237,7 @@ netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 
 	if (count) {
 		rds_ring->producer = producer;
-		adapter->pci_write_normalize(adapter,
+		adapter->hw_write_wx(adapter,
 			rds_ring->crb_rcv_producer,
 				(producer - 1) & (rds_ring->num_desc - 1));
 			wmb();
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b1cec07..a79e265 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -109,7 +109,7 @@ void
 netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
 		struct nx_host_tx_ring *tx_ring, u32 producer)
 {
-	adapter->pci_write_normalize(adapter,
+	adapter->hw_write_wx(adapter,
 			tx_ring->crb_cmd_producer, producer);
 }
 
@@ -122,7 +122,7 @@ static inline void
 netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter,
 		struct nx_host_tx_ring *tx_ring, u32 consumer)
 {
-	adapter->pci_write_normalize(adapter,
+	adapter->hw_write_wx(adapter,
 			tx_ring->crb_cmd_consumer, consumer);
 }
 
@@ -139,14 +139,14 @@ static inline void netxen_nic_disable_int(struct nx_host_sds_ring *sds_ring)
 {
 	struct netxen_adapter *adapter = sds_ring->adapter;
 
-	adapter->pci_write_normalize(adapter, sds_ring->crb_intr_mask, 0);
+	adapter->hw_write_wx(adapter, sds_ring->crb_intr_mask, 0);
 }
 
 static inline void netxen_nic_enable_int(struct nx_host_sds_ring *sds_ring)
 {
 	struct netxen_adapter *adapter = sds_ring->adapter;
 
-	adapter->pci_write_normalize(adapter, sds_ring->crb_intr_mask, 0x1);
+	adapter->hw_write_wx(adapter, sds_ring->crb_intr_mask, 0x1);
 
 	if (!NETXEN_IS_MSI_FAMILY(adapter))
 		adapter->pci_write_immediate(adapter,
@@ -309,42 +309,41 @@ netxen_check_hw_init(struct netxen_adapter *adapter, int first_boot)
 
 	if (first_boot == 0x55555555) {
 		/* This is the first boot after power up */
-		adapter->pci_write_normalize(adapter,
+		adapter->hw_write_wx(adapter,
 			NETXEN_CAM_RAM(0x1fc), NETXEN_BDINFO_MAGIC);
 
 		if (!NX_IS_REVISION_P2(adapter->ahw.revision_id))
 			return 0;
 
 		/* PCI bus master workaround */
-		adapter->hw_read_wx(adapter,
-			NETXEN_PCIE_REG(0x4), &first_boot, 4);
+		first_boot = adapter->hw_read_wx(adapter, NETXEN_PCIE_REG(0x4));
 		if (!(first_boot & 0x4)) {
 			first_boot |= 0x4;
 			adapter->hw_write_wx(adapter,
-				NETXEN_PCIE_REG(0x4), &first_boot, 4);
-			adapter->hw_read_wx(adapter,
-				NETXEN_PCIE_REG(0x4), &first_boot, 4);
+				NETXEN_PCIE_REG(0x4), first_boot);
+			first_boot = adapter->hw_read_wx(adapter,
+				NETXEN_PCIE_REG(0x4));
 		}
 
 		/* This is the first boot after power up */
-		adapter->hw_read_wx(adapter,
-			NETXEN_ROMUSB_GLB_SW_RESET, &first_boot, 4);
+		first_boot = adapter->hw_read_wx(adapter,
+			NETXEN_ROMUSB_GLB_SW_RESET);
 		if (first_boot != 0x80000f) {
 			/* clear the register for future unloads/loads */
-			adapter->pci_write_normalize(adapter,
+			adapter->hw_write_wx(adapter,
 					NETXEN_CAM_RAM(0x1fc), 0);
 			return -EIO;
 		}
 
 		/* Start P2 boot loader */
-		val = adapter->pci_read_normalize(adapter,
+		val = adapter->hw_read_wx(adapter,
 				NETXEN_ROMUSB_GLB_PEGTUNE_DONE);
-		adapter->pci_write_normalize(adapter,
+		adapter->hw_write_wx(adapter,
 				NETXEN_ROMUSB_GLB_PEGTUNE_DONE, val | 0x1);
 		timeout = 0;
 		do {
 			msleep(1);
-			val = adapter->pci_read_normalize(adapter,
+			val = adapter->hw_read_wx(adapter,
 					NETXEN_CAM_RAM(0x1fc));
 
 			if (++timeout > 5000)
@@ -365,23 +364,23 @@ static void netxen_set_port_mode(struct netxen_adapter *adapter)
 		if (port_mode == NETXEN_PORT_MODE_802_3_AP) {
 			data = NETXEN_PORT_MODE_802_3_AP;
 			adapter->hw_write_wx(adapter,
-				NETXEN_PORT_MODE_ADDR, &data, 4);
+				NETXEN_PORT_MODE_ADDR, data);
 		} else if (port_mode == NETXEN_PORT_MODE_XG) {
 			data = NETXEN_PORT_MODE_XG;
 			adapter->hw_write_wx(adapter,
-				NETXEN_PORT_MODE_ADDR, &data, 4);
+				NETXEN_PORT_MODE_ADDR, data);
 		} else if (port_mode == NETXEN_PORT_MODE_AUTO_NEG_1G) {
 			data = NETXEN_PORT_MODE_AUTO_NEG_1G;
 			adapter->hw_write_wx(adapter,
-				NETXEN_PORT_MODE_ADDR, &data, 4);
+				NETXEN_PORT_MODE_ADDR, data);
 		} else if (port_mode == NETXEN_PORT_MODE_AUTO_NEG_XG) {
 			data = NETXEN_PORT_MODE_AUTO_NEG_XG;
 			adapter->hw_write_wx(adapter,
-				NETXEN_PORT_MODE_ADDR, &data, 4);
+				NETXEN_PORT_MODE_ADDR, data);
 		} else {
 			data = NETXEN_PORT_MODE_AUTO_NEG;
 			adapter->hw_write_wx(adapter,
-				NETXEN_PORT_MODE_ADDR, &data, 4);
+				NETXEN_PORT_MODE_ADDR, data);
 		}
 
 		if ((wol_port_mode != NETXEN_PORT_MODE_802_3_AP) &&
@@ -391,7 +390,7 @@ static void netxen_set_port_mode(struct netxen_adapter *adapter)
 			wol_port_mode = NETXEN_PORT_MODE_AUTO_NEG;
 		}
 		adapter->hw_write_wx(adapter, NETXEN_WOL_PORT_MODE,
-			&wol_port_mode, 4);
+			wol_port_mode);
 	}
 }
 
@@ -572,8 +571,6 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 	adapter->hw_read_wx = netxen_nic_hw_read_wx_128M;
 	adapter->pci_read_immediate = netxen_nic_pci_read_immediate_128M;
 	adapter->pci_write_immediate = netxen_nic_pci_write_immediate_128M;
-	adapter->pci_read_normalize = netxen_nic_pci_read_normalize_128M;
-	adapter->pci_write_normalize = netxen_nic_pci_write_normalize_128M;
 	adapter->pci_set_window = netxen_nic_pci_set_window_128M;
 	adapter->pci_mem_read = netxen_nic_pci_mem_read_128M;
 	adapter->pci_mem_write = netxen_nic_pci_mem_write_128M;
@@ -595,9 +592,6 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 		adapter->pci_read_immediate = netxen_nic_pci_read_immediate_2M;
 		adapter->pci_write_immediate =
 			netxen_nic_pci_write_immediate_2M;
-		adapter->pci_read_normalize = netxen_nic_pci_read_normalize_2M;
-		adapter->pci_write_normalize =
-			netxen_nic_pci_write_normalize_2M;
 		adapter->pci_set_window = netxen_nic_pci_set_window_2M;
 		adapter->pci_mem_read = netxen_nic_pci_mem_read_2M;
 		adapter->pci_mem_write = netxen_nic_pci_mem_write_2M;
@@ -680,7 +674,7 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 	if (!first_driver)
 		return 0;
 
-	first_boot = adapter->pci_read_normalize(adapter,
+	first_boot = adapter->hw_read_wx(adapter,
 			NETXEN_CAM_RAM(0x1fc));
 
 	err = netxen_check_hw_init(adapter, first_boot);
@@ -690,7 +684,7 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 	}
 
 	if (first_boot != 0x55555555) {
-		adapter->pci_write_normalize(adapter,
+		adapter->hw_write_wx(adapter,
 					CRB_CMDPEG_STATE, 0);
 		netxen_pinit_from_rom(adapter, 0);
 		msleep(1);
@@ -723,7 +717,7 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 	val = (_NETXEN_NIC_LINUX_MAJOR << 16)
 		| ((_NETXEN_NIC_LINUX_MINOR << 8))
 		| (_NETXEN_NIC_LINUX_SUBVERSION);
-	adapter->pci_write_normalize(adapter, CRB_DRIVER_VERSION, val);
+	adapter->hw_write_wx(adapter, CRB_DRIVER_VERSION, val);
 
 	/* Handshake with the card before we register the devices. */
 	err = netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
@@ -1038,7 +1032,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	adapter->physical_port = adapter->portnum;
 	if (adapter->fw_major < 4) {
-		i = adapter->pci_read_normalize(adapter,
+		i = adapter->hw_read_wx(adapter,
 				CRB_V2P(adapter->portnum));
 		if (i != 0x55555555)
 			adapter->physical_port = i;
@@ -1486,7 +1480,7 @@ static int netxen_nic_check_temp(struct netxen_adapter *adapter)
 	uint32_t temp, temp_state, temp_val;
 	int rv = 0;
 
-	temp = adapter->pci_read_normalize(adapter, CRB_TEMP_STATE);
+	temp = adapter->hw_read_wx(adapter, CRB_TEMP_STATE);
 
 	temp_state = nx_get_temp_state(temp);
 	temp_val = nx_get_temp_val(temp);
@@ -1557,11 +1551,11 @@ static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
 	port = adapter->physical_port;
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE_P3);
+		val = adapter->hw_read_wx(adapter, CRB_XG_STATE_P3);
 		val = XG_LINK_STATE_P3(adapter->ahw.pci_func, val);
 		linkup = (val == XG_LINK_UP_P3);
 	} else {
-		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
+		val = adapter->hw_read_wx(adapter, CRB_XG_STATE);
 		if (adapter->ahw.port_type == NETXEN_NIC_GBE)
 			linkup = (val >> port) & 1;
 		else {
@@ -1656,14 +1650,14 @@ static irqreturn_t netxen_intr(int irq, void *data)
 	} else {
 		unsigned long our_int = 0;
 
-		our_int = adapter->pci_read_normalize(adapter, CRB_INT_VECTOR);
+		our_int = adapter->hw_read_wx(adapter, CRB_INT_VECTOR);
 
 		/* not our interrupt */
 		if (!test_and_clear_bit((7 + adapter->portnum), &our_int))
 			return IRQ_NONE;
 
 		/* claim interrupt */
-		adapter->pci_write_normalize(adapter,
+		adapter->hw_write_wx(adapter,
 				CRB_INT_VECTOR, (our_int & 0xffffffff));
 	}
 
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 3310471..b54a63a 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -105,9 +105,7 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 	 * so it cannot be in reset
 	 */
 
-	if (adapter->hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0),
-				  &mac_cfg0, 4))
-		return -EIO;
+	mac_cfg0 = adapter->hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0));
 	if (netxen_gb_get_soft_reset(mac_cfg0)) {
 		__u32 temp;
 		temp = 0;
@@ -116,8 +114,7 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 		netxen_gb_tx_reset_mac(temp);
 		netxen_gb_rx_reset_mac(temp);
 		if (adapter->hw_write_wx(adapter,
-					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
-					   &temp, 4))
+				   NETXEN_NIU_GB_MAC_CONFIG_0(0), temp))
 			return -EIO;
 		restore = 1;
 	}
@@ -125,43 +122,38 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 	address = 0;
 	netxen_gb_mii_mgmt_reg_addr(address, reg);
 	netxen_gb_mii_mgmt_phy_addr(address, phy);
-	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0),
-				   &address, 4))
+	if (adapter->hw_write_wx(adapter,
+				NETXEN_NIU_GB_MII_MGMT_ADDR(0), address))
 		return -EIO;
 	command = 0;		/* turn off any prior activity */
-	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
-				   &command, 4))
+	if (adapter->hw_write_wx(adapter,
+				NETXEN_NIU_GB_MII_MGMT_COMMAND(0), command))
 		return -EIO;
 	/* send read command */
 	netxen_gb_mii_mgmt_set_read_cycle(command);
-	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
-				   &command, 4))
+	if (adapter->hw_write_wx(adapter,
+				NETXEN_NIU_GB_MII_MGMT_COMMAND(0), command))
 		return -EIO;
 
 	status = 0;
 	do {
-		if (adapter->hw_read_wx(adapter,
-					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0),
-					  &status, 4))
-			return -EIO;
+		status = adapter->hw_read_wx(adapter,
+					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0));
 		timeout++;
 	} while ((netxen_get_gb_mii_mgmt_busy(status)
 		  || netxen_get_gb_mii_mgmt_notvalid(status))
 		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
 
 	if (timeout < NETXEN_NIU_PHY_WAITMAX) {
-		if (adapter->hw_read_wx(adapter,
-					  NETXEN_NIU_GB_MII_MGMT_STATUS(0),
-					  readval, 4))
-			return -EIO;
+		*readval = adapter->hw_read_wx(adapter,
+					  NETXEN_NIU_GB_MII_MGMT_STATUS(0));
 		result = 0;
 	} else
 		result = -1;
 
 	if (restore)
 		if (adapter->hw_write_wx(adapter,
-					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
-					   &mac_cfg0, 4))
+				   NETXEN_NIU_GB_MAC_CONFIG_0(0), mac_cfg0))
 			return -EIO;
 	phy_unlock(adapter);
 	return result;
@@ -197,9 +189,7 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 	 * cannot be in reset
 	 */
 
-	if (adapter->hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0),
-				  &mac_cfg0, 4))
-		return -EIO;
+	mac_cfg0 = adapter->hw_read_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(0));
 	if (netxen_gb_get_soft_reset(mac_cfg0)) {
 		__u32 temp;
 		temp = 0;
@@ -209,34 +199,31 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 		netxen_gb_rx_reset_mac(temp);
 
 		if (adapter->hw_write_wx(adapter,
-					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
-					   &temp, 4))
+					NETXEN_NIU_GB_MAC_CONFIG_0(0), temp))
 			return -EIO;
 		restore = 1;
 	}
 
 	command = 0;		/* turn off any prior activity */
-	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_COMMAND(0),
-				   &command, 4))
+	if (adapter->hw_write_wx(adapter,
+				NETXEN_NIU_GB_MII_MGMT_COMMAND(0), command))
 		return -EIO;
 
 	address = 0;
 	netxen_gb_mii_mgmt_reg_addr(address, reg);
 	netxen_gb_mii_mgmt_phy_addr(address, phy);
-	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_ADDR(0),
-				   &address, 4))
+	if (adapter->hw_write_wx(adapter,
+				NETXEN_NIU_GB_MII_MGMT_ADDR(0), address))
 		return -EIO;
 
-	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CTRL(0),
-				   &val, 4))
+	if (adapter->hw_write_wx(adapter,
+				NETXEN_NIU_GB_MII_MGMT_CTRL(0), val))
 		return -EIO;
 
 	status = 0;
 	do {
-		if (adapter->hw_read_wx(adapter,
-					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0),
-					  &status, 4))
-			return -EIO;
+		status = adapter->hw_read_wx(adapter,
+					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0));
 		timeout++;
 	} while ((netxen_get_gb_mii_mgmt_busy(status))
 		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
@@ -249,8 +236,7 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
 	/* restore the state of port 0 MAC in case we tampered with it */
 	if (restore)
 		if (adapter->hw_write_wx(adapter,
-					   NETXEN_NIU_GB_MAC_CONFIG_0(0),
-					   &mac_cfg0, 4))
+				   NETXEN_NIU_GB_MAC_CONFIG_0(0), mac_cfg0))
 			return -EIO;
 
 	return result;
@@ -473,12 +459,10 @@ static int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
 	if ((phy < 0) || (phy > 3))
 		return -EINVAL;
 
-	if (adapter->hw_read_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy),
-				  &stationhigh, 4))
-		return -EIO;
-	if (adapter->hw_read_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy),
-				  &stationlow, 4))
-		return -EIO;
+	stationhigh = adapter->hw_read_wx(adapter,
+			NETXEN_NIU_GB_STATION_ADDR_0(phy));
+	stationlow = adapter->hw_read_wx(adapter,
+			NETXEN_NIU_GB_STATION_ADDR_1(phy));
 	((__le32 *)val)[1] = cpu_to_le32(stationhigh);
 	((__le32 *)val)[0] = cpu_to_le32(stationlow);
 
@@ -508,13 +492,13 @@ int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
 		memcpy(temp + 2, addr, 2);
 		val = le32_to_cpu(*(__le32 *)temp);
 		if (adapter->hw_write_wx(adapter,
-				NETXEN_NIU_GB_STATION_ADDR_1(phy), &val, 4))
+				NETXEN_NIU_GB_STATION_ADDR_1(phy), val))
 			return -EIO;
 
 		memcpy(temp, ((u8 *) addr) + 2, sizeof(__le32));
 		val = le32_to_cpu(*(__le32 *)temp);
 		if (adapter->hw_write_wx(adapter,
-				NETXEN_NIU_GB_STATION_ADDR_0(phy), &val, 4))
+				NETXEN_NIU_GB_STATION_ADDR_0(phy), val))
 			return -2;
 
 		netxen_niu_macaddr_get(adapter,
@@ -545,8 +529,8 @@ int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter)
 		return -EINVAL;
 	mac_cfg0 = 0;
 	netxen_gb_soft_reset(mac_cfg0);
-	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
-				   &mac_cfg0, 4))
+	if (adapter->hw_write_wx(adapter,
+				NETXEN_NIU_GB_MAC_CONFIG_0(port), mac_cfg0))
 		return -EIO;
 	return 0;
 }
@@ -565,7 +549,7 @@ int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
 
 	mac_cfg = 0;
 	if (adapter->hw_write_wx(adapter,
-		NETXEN_NIU_XGE_CONFIG_0 + (0x10000 * port), &mac_cfg, 4))
+		NETXEN_NIU_XGE_CONFIG_0 + (0x10000 * port), mac_cfg))
 		return -EIO;
 	return 0;
 }
@@ -581,9 +565,7 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
 		return -EINVAL;
 
 	/* save previous contents */
-	if (adapter->hw_read_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR,
-				  &reg, 4))
-		return -EIO;
+	reg = adapter->hw_read_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR);
 	if (mode == NETXEN_NIU_PROMISC_MODE) {
 		switch (port) {
 		case 0:
@@ -619,8 +601,7 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
 			return -EIO;
 		}
 	}
-	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR,
-				   &reg, 4))
+	if (adapter->hw_write_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR, reg))
 		return -EIO;
 	return 0;
 }
@@ -647,28 +628,28 @@ int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 	case 0:
 	    memcpy(temp + 2, addr, 2);
 	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (adapter->hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
-				&val, 4))
+	    if (adapter->hw_write_wx(adapter,
+				    NETXEN_NIU_XGE_STATION_ADDR_0_1, val))
 		return -EIO;
 
 	    memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
 	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (adapter->hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
-				&val, 4))
+	    if (adapter->hw_write_wx(adapter,
+				    NETXEN_NIU_XGE_STATION_ADDR_0_HI, val))
 		return -EIO;
 	    break;
 
 	case 1:
 	    memcpy(temp + 2, addr, 2);
 	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (adapter->hw_write_wx(adapter, NETXEN_NIU_XG1_STATION_ADDR_0_1,
-				&val, 4))
+	    if (adapter->hw_write_wx(adapter,
+				    NETXEN_NIU_XG1_STATION_ADDR_0_1, val))
 		return -EIO;
 
 	    memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
 	    val = le32_to_cpu(*(__le32 *)temp);
-	    if (adapter->hw_write_wx(adapter, NETXEN_NIU_XG1_STATION_ADDR_0_HI,
-				&val, 4))
+	    if (adapter->hw_write_wx(adapter,
+				    NETXEN_NIU_XG1_STATION_ADDR_0_HI, val))
 		return -EIO;
 	    break;
 
@@ -689,9 +670,8 @@ int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 	if (port > NETXEN_NIU_MAX_XG_PORTS)
 		return -EINVAL;
 
-	if (adapter->hw_read_wx(adapter,
-		NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port), &reg, 4))
-			return -EIO;
+	reg = adapter->hw_read_wx(adapter,
+		NETXEN_NIU_XGE_CONFIG_1 + (0x10000 * port));
 	if (mode == NETXEN_NIU_PROMISC_MODE)
 		reg = (reg | 0x2000UL);
 	else
-- 
1.6.0.2

