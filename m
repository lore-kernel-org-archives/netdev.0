From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/3] netxen: fix sparse warnings
Date: Mon, 16 Feb 2009 01:18:50 -0800
Message-ID: <1234775931-18518-3-git-send-email-dhananjay@netxen.com>
References: <1234775931-18518-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:48981 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752287AbZBPJS5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2009 04:18:57 -0500
In-Reply-To: <1234775931-18518-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix following sparse warnings (multiple instances)

warning: restricted degrades to integer
warning: cast to restricted type
warning: incorrect type in argument 3 (different signedness)
warning: context imbalance in 'netxen_nic_hw_write_wx_2M' - different
lock contexts for basic block

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hw.c |  179 ++++++++++--------------------------
 drivers/net/netxen/netxen_nic_hw.h |   24 -----
 2 files changed, 47 insertions(+), 156 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 821cff6..81f55e1 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -936,13 +936,12 @@ netxen_nic_pci_set_crbwindow_2M(struct netxen_adapter *adapter, ulong *off)
 	u32 win_read;
 
 	adapter->crb_win = CRB_HI(*off);
-	writel(adapter->crb_win, (void *)(CRB_WINDOW_2M +
-		adapter->ahw.pci_base0));
+	writel(adapter->crb_win, (adapter->ahw.pci_base0 + CRB_WINDOW_2M));
 	/*
 	 * Read back value to make sure write has gone through before trying
 	 * to use it.
 	 */
-	win_read = readl((void *)(CRB_WINDOW_2M + adapter->ahw.pci_base0));
+	win_read = readl(adapter->ahw.pci_base0 + CRB_WINDOW_2M);
 	if (win_read != adapter->crb_win) {
 		printk(KERN_ERR "%s: Written crbwin (0x%x) != "
 				"Read crbwin (0x%x), off=0x%lx\n",
@@ -992,6 +991,8 @@ netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter,
 {
 	void __iomem *addr;
 
+	BUG_ON(len != 4);
+
 	if (ADDR_IN_WINDOW1(off)) {
 		addr = NETXEN_CRB_NORMALIZE(adapter, off);
 	} else {		/* Window 0 */
@@ -999,37 +1000,13 @@ netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter,
 		netxen_nic_pci_change_crbwindow_128M(adapter, 0);
 	}
 
-	DPRINTK(INFO, "writing to base %lx offset %llx addr %p"
-		" data %llx len %d\n",
-		pci_base(adapter, off), off, addr,
-		*(unsigned long long *)data, len);
 	if (!addr) {
 		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
 		return 1;
 	}
 
-	switch (len) {
-	case 1:
-		writeb(*(u8 *) data, addr);
-		break;
-	case 2:
-		writew(*(u16 *) data, addr);
-		break;
-	case 4:
-		writel(*(u32 *) data, addr);
-		break;
-	case 8:
-		writeq(*(u64 *) data, addr);
-		break;
-	default:
-		DPRINTK(INFO,
-			"writing data %lx to offset %llx, num words=%d\n",
-			*(unsigned long *)data, off, (len >> 3));
+	writel(*(u32 *) data, addr);
 
-		netxen_nic_hw_block_write64((u64 __iomem *) data, addr,
-					    (len >> 3));
-		break;
-	}
 	if (!ADDR_IN_WINDOW1(off))
 		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
 
@@ -1042,6 +1019,8 @@ netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter,
 {
 	void __iomem *addr;
 
+	BUG_ON(len != 4);
+
 	if (ADDR_IN_WINDOW1(off)) {	/* Window 1 */
 		addr = NETXEN_CRB_NORMALIZE(adapter, off);
 	} else {		/* Window 0 */
@@ -1049,31 +1028,12 @@ netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter,
 		netxen_nic_pci_change_crbwindow_128M(adapter, 0);
 	}
 
-	DPRINTK(INFO, "reading from base %lx offset %llx addr %p\n",
-		pci_base(adapter, off), off, addr);
 	if (!addr) {
 		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
 		return 1;
 	}
-	switch (len) {
-	case 1:
-		*(u8 *) data = readb(addr);
-		break;
-	case 2:
-		*(u16 *) data = readw(addr);
-		break;
-	case 4:
-		*(u32 *) data = readl(addr);
-		break;
-	case 8:
-		*(u64 *) data = readq(addr);
-		break;
-	default:
-		netxen_nic_hw_block_read64((u64 __iomem *) data, addr,
-					   (len >> 3));
-		break;
-	}
-	DPRINTK(INFO, "read %lx\n", *(unsigned long *)data);
+
+	*(u32 *)data = readl(addr);
 
 	if (!ADDR_IN_WINDOW1(off))
 		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
@@ -1088,6 +1048,8 @@ netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter,
 	unsigned long flags = 0;
 	int rv;
 
+	BUG_ON(len != 4);
+
 	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off, len);
 
 	if (rv == -1) {
@@ -1101,34 +1063,12 @@ netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter,
 		write_lock_irqsave(&adapter->adapter_lock, flags);
 		crb_win_lock(adapter);
 		netxen_nic_pci_set_crbwindow_2M(adapter, &off);
-	}
-
-	DPRINTK(1, INFO, "write data %lx to offset %llx, len=%d\n",
-			*(unsigned long *)data, off, len);
-
-	switch (len) {
-	case 1:
-		writeb(*(uint8_t *)data, (void *)off);
-		break;
-	case 2:
-		writew(*(uint16_t *)data, (void *)off);
-		break;
-	case 4:
-		writel(*(uint32_t *)data, (void *)off);
-		break;
-	case 8:
-		writeq(*(uint64_t *)data, (void *)off);
-		break;
-	default:
-		DPRINTK(1, INFO,
-			"writing data %lx to offset %llx, num words=%d\n",
-			*(unsigned long *)data, off, (len>>3));
-		break;
-	}
-	if (rv == 1) {
+		writel(*(uint32_t *)data, (void __iomem *)off);
 		crb_win_unlock(adapter);
 		write_unlock_irqrestore(&adapter->adapter_lock, flags);
-	}
+	} else
+		writel(*(uint32_t *)data, (void __iomem *)off);
+
 
 	return 0;
 }
@@ -1140,6 +1080,8 @@ netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter,
 	unsigned long flags = 0;
 	int rv;
 
+	BUG_ON(len != 4);
+
 	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off, len);
 
 	if (rv == -1) {
@@ -1153,33 +1095,11 @@ netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter,
 		write_lock_irqsave(&adapter->adapter_lock, flags);
 		crb_win_lock(adapter);
 		netxen_nic_pci_set_crbwindow_2M(adapter, &off);
-	}
-
-	DPRINTK(1, INFO, "read from offset %lx, len=%d\n", off, len);
-
-	switch (len) {
-	case 1:
-		*(uint8_t *)data = readb((void *)off);
-		break;
-	case 2:
-		*(uint16_t *)data = readw((void *)off);
-		break;
-	case 4:
-		*(uint32_t *)data = readl((void *)off);
-		break;
-	case 8:
-		*(uint64_t *)data = readq((void *)off);
-		break;
-	default:
-		break;
-	}
-
-	DPRINTK(1, INFO, "read %lx\n", *(unsigned long *)data);
-
-	if (rv == 1) {
+		*(uint32_t *)data = readl((void __iomem *)off);
 		crb_win_unlock(adapter);
 		write_unlock_irqrestore(&adapter->adapter_lock, flags);
-	}
+	} else
+		*(uint32_t *)data = readl((void __iomem *)off);
 
 	return 0;
 }
@@ -1441,10 +1361,9 @@ static int netxen_nic_pci_mem_read_direct(struct netxen_adapter *adapter,
 			u64 off, void *data, int size)
 {
 	unsigned long flags;
-	void *addr;
+	void __iomem *addr, *mem_ptr = NULL;
 	int ret = 0;
 	u64 start;
-	uint8_t *mem_ptr = NULL;
 	unsigned long mem_base;
 	unsigned long mem_page;
 
@@ -1464,7 +1383,7 @@ static int netxen_nic_pci_mem_read_direct(struct netxen_adapter *adapter,
 		return -1;
 	}
 
-	addr = (void *)(pci_base_offset(adapter, start));
+	addr = pci_base_offset(adapter, start);
 	if (!addr) {
 		write_unlock_irqrestore(&adapter->adapter_lock, flags);
 		mem_base = pci_resource_start(adapter->pdev, 0);
@@ -1503,7 +1422,6 @@ static int netxen_nic_pci_mem_read_direct(struct netxen_adapter *adapter,
 		break;
 	}
 	write_unlock_irqrestore(&adapter->adapter_lock, flags);
-	DPRINTK(1, INFO, "read %llx\n", *(unsigned long long *)data);
 
 	if (mem_ptr)
 		iounmap(mem_ptr);
@@ -1515,10 +1433,9 @@ netxen_nic_pci_mem_write_direct(struct netxen_adapter *adapter, u64 off,
 		void *data, int size)
 {
 	unsigned long flags;
-	void *addr;
+	void __iomem *addr, *mem_ptr = NULL;
 	int ret = 0;
 	u64 start;
-	uint8_t *mem_ptr = NULL;
 	unsigned long mem_base;
 	unsigned long mem_page;
 
@@ -1538,7 +1455,7 @@ netxen_nic_pci_mem_write_direct(struct netxen_adapter *adapter, u64 off,
 		return -1;
 	}
 
-	addr = (void *)(pci_base_offset(adapter, start));
+	addr = pci_base_offset(adapter, start);
 	if (!addr) {
 		write_unlock_irqrestore(&adapter->adapter_lock, flags);
 		mem_base = pci_resource_start(adapter->pdev, 0);
@@ -1575,8 +1492,6 @@ netxen_nic_pci_mem_write_direct(struct netxen_adapter *adapter, u64 off,
 		break;
 	}
 	write_unlock_irqrestore(&adapter->adapter_lock, flags);
-	DPRINTK(1, INFO, "writing data %llx to offset %llx\n",
-			*(unsigned long long *)data, start);
 	if (mem_ptr)
 		iounmap(mem_ptr);
 	return ret;
@@ -1588,10 +1503,11 @@ int
 netxen_nic_pci_mem_write_128M(struct netxen_adapter *adapter,
 		u64 off, void *data, int size)
 {
-	unsigned long   flags, mem_crb;
+	unsigned long   flags;
 	int	     i, j, ret = 0, loop, sz[2], off0;
 	uint32_t      temp;
 	uint64_t      off8, tmpw, word[2] = {0, 0};
+	void __iomem *mem_crb;
 
 	/*
 	 * If not MN, go check for MS or invalid.
@@ -1605,7 +1521,7 @@ netxen_nic_pci_mem_write_128M(struct netxen_adapter *adapter,
 	sz[0] = (size < (8 - off0)) ? size : (8 - off0);
 	sz[1] = size - sz[0];
 	loop = ((off0 + size - 1) >> 3) + 1;
-	mem_crb = (unsigned long)pci_base_offset(adapter, NETXEN_CRB_DDR_NET);
+	mem_crb = pci_base_offset(adapter, NETXEN_CRB_DDR_NET);
 
 	if ((size != 8) || (off0 != 0))  {
 		for (i = 0; i < loop; i++) {
@@ -1643,21 +1559,21 @@ netxen_nic_pci_mem_write_128M(struct netxen_adapter *adapter,
 
 	for (i = 0; i < loop; i++) {
 		writel((uint32_t)(off8 + (i << 3)),
-			(void *)(mem_crb+MIU_TEST_AGT_ADDR_LO));
+			(mem_crb+MIU_TEST_AGT_ADDR_LO));
 		writel(0,
-			(void *)(mem_crb+MIU_TEST_AGT_ADDR_HI));
+			(mem_crb+MIU_TEST_AGT_ADDR_HI));
 		writel(word[i] & 0xffffffff,
-			(void *)(mem_crb+MIU_TEST_AGT_WRDATA_LO));
+			(mem_crb+MIU_TEST_AGT_WRDATA_LO));
 		writel((word[i] >> 32) & 0xffffffff,
-			(void *)(mem_crb+MIU_TEST_AGT_WRDATA_HI));
+			(mem_crb+MIU_TEST_AGT_WRDATA_HI));
 		writel(MIU_TA_CTL_ENABLE|MIU_TA_CTL_WRITE,
-			(void *)(mem_crb+MIU_TEST_AGT_CTRL));
+			(mem_crb+MIU_TEST_AGT_CTRL));
 		writel(MIU_TA_CTL_START|MIU_TA_CTL_ENABLE|MIU_TA_CTL_WRITE,
-			(void *)(mem_crb+MIU_TEST_AGT_CTRL));
+			(mem_crb+MIU_TEST_AGT_CTRL));
 
 		for (j = 0; j < MAX_CTL_CHECK; j++) {
 			temp = readl(
-			     (void *)(mem_crb+MIU_TEST_AGT_CTRL));
+			     (mem_crb+MIU_TEST_AGT_CTRL));
 			if ((temp & MIU_TA_CTL_BUSY) == 0)
 				break;
 		}
@@ -1679,10 +1595,11 @@ int
 netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
 		u64 off, void *data, int size)
 {
-	unsigned long   flags, mem_crb;
+	unsigned long   flags;
 	int	     i, j = 0, k, start, end, loop, sz[2], off0[2];
 	uint32_t      temp;
 	uint64_t      off8, val, word[2] = {0, 0};
+	void __iomem *mem_crb;
 
 
 	/*
@@ -1697,24 +1614,24 @@ netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
 	sz[0] = (size < (8 - off0[0])) ? size : (8 - off0[0]);
 	sz[1] = size - sz[0];
 	loop = ((off0[0] + size - 1) >> 3) + 1;
-	mem_crb = (unsigned long)pci_base_offset(adapter, NETXEN_CRB_DDR_NET);
+	mem_crb = pci_base_offset(adapter, NETXEN_CRB_DDR_NET);
 
 	write_lock_irqsave(&adapter->adapter_lock, flags);
 	netxen_nic_pci_change_crbwindow_128M(adapter, 0);
 
 	for (i = 0; i < loop; i++) {
 		writel((uint32_t)(off8 + (i << 3)),
-			(void *)(mem_crb+MIU_TEST_AGT_ADDR_LO));
+			(mem_crb+MIU_TEST_AGT_ADDR_LO));
 		writel(0,
-			(void *)(mem_crb+MIU_TEST_AGT_ADDR_HI));
+			(mem_crb+MIU_TEST_AGT_ADDR_HI));
 		writel(MIU_TA_CTL_ENABLE,
-			(void *)(mem_crb+MIU_TEST_AGT_CTRL));
+			(mem_crb+MIU_TEST_AGT_CTRL));
 		writel(MIU_TA_CTL_START|MIU_TA_CTL_ENABLE,
-			(void *)(mem_crb+MIU_TEST_AGT_CTRL));
+			(mem_crb+MIU_TEST_AGT_CTRL));
 
 		for (j = 0; j < MAX_CTL_CHECK; j++) {
 			temp = readl(
-			      (void *)(mem_crb+MIU_TEST_AGT_CTRL));
+			      (mem_crb+MIU_TEST_AGT_CTRL));
 			if ((temp & MIU_TA_CTL_BUSY) == 0)
 				break;
 		}
@@ -1729,7 +1646,7 @@ netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
 		end   = (off0[i] + sz[i] - 1) >> 2;
 		for (k = start; k <= end; k++) {
 			word[i] |= ((uint64_t) readl(
-				    (void *)(mem_crb +
+				    (mem_crb +
 				    MIU_TEST_AGT_RDDATA(k))) << (32*k));
 		}
 	}
@@ -1761,7 +1678,6 @@ netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
 		*(uint64_t *)data = val;
 		break;
 	}
-	DPRINTK(1, INFO, "read %llx\n", *(unsigned long long *)data);
 	return 0;
 }
 
@@ -1970,7 +1886,6 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 		*(uint64_t *)data = val;
 		break;
 	}
-	DPRINTK(1, INFO, "read %llx\n", *(unsigned long long *)data);
 	return 0;
 }
 
@@ -2024,10 +1939,10 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 	int addr = NETXEN_BRDCFG_START;
 	struct netxen_board_info *boardinfo;
 	int index;
-	u32 *ptr32;
+	int *ptr32;
 
 	boardinfo = &adapter->ahw.boardcfg;
-	ptr32 = (u32 *) boardinfo;
+	ptr32 = (int *) boardinfo;
 
 	for (index = 0; index < sizeof(struct netxen_board_info) / sizeof(u32);
 	     index++) {
@@ -2207,13 +2122,13 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
 	char brd_name[NETXEN_MAX_SHORT_NAME];
 	char serial_num[32];
 	int i, addr;
-	__le32 *ptr32;
+	int *ptr32;
 
 	struct netxen_board_info *board_info = &(adapter->ahw.boardcfg);
 
 	adapter->driver_mismatch = 0;
 
-	ptr32 = (u32 *)&serial_num;
+	ptr32 = (int *)&serial_num;
 	addr = NETXEN_USER_START +
 	       offsetof(struct netxen_new_user_info, serial_num);
 	for (i = 0; i < 8; i++) {
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index aae737d..70238bf 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -54,30 +54,6 @@ static inline void writeq(u64 val, void __iomem * addr)
 }
 #endif
 
-static inline void netxen_nic_hw_block_write64(u64 __iomem * data_ptr,
-					       u64 __iomem * addr,
-					       int num_words)
-{
-	int num;
-	for (num = 0; num < num_words; num++) {
-		writeq(readq((void __iomem *)data_ptr), addr);
-		addr++;
-		data_ptr++;
-	}
-}
-
-static inline void netxen_nic_hw_block_read64(u64 __iomem * data_ptr,
-					      u64 __iomem * addr, int num_words)
-{
-	int num;
-	for (num = 0; num < num_words; num++) {
-		writeq(readq((void __iomem *)addr), data_ptr);
-		addr++;
-		data_ptr++;
-	}
-
-}
-
 struct netxen_adapter;
 
 #define NETXEN_PCI_MAPSIZE_BYTES  (NETXEN_PCI_MAPSIZE << 20)
-- 
1.6.0.2

