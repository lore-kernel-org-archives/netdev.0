From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 01/13] netxen: fix sparse in warnings
Date: Mon, 12 Jan 2009 11:22:59 -0800
Message-ID: <1231788191-23794-2-git-send-email-dhananjay@netxen.com>
References: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:36351 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754991AbZALT3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 14:29:53 -0500
In-Reply-To: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix following sparse warnings (multiple instances)

warning: restricted degrades to integer
warning: cast to restricted type
warning: incorrect type in argument 3 (different signedness)

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    4 +-
 drivers/net/netxen/netxen_nic_hw.c   |  217 +++++++++++-----------------------
 drivers/net/netxen/netxen_nic_init.c |    2 +-
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 4 files changed, 73 insertions(+), 152 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index f8e601c..a434bae 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1614,8 +1614,8 @@ dma_watchdog_wakeup(struct netxen_adapter *adapter)
 
 
 int netxen_is_flash_supported(struct netxen_adapter *adapter);
-int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 *mac);
-int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac);
+int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, u64 *mac);
+int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, u64 *mac);
 extern void netxen_change_ringparam(struct netxen_adapter *adapter);
 extern int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr,
 				int *valp);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index aa6e603..b9cd6a7 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -706,12 +706,13 @@ int netxen_is_flash_supported(struct netxen_adapter *adapter)
 	return 0;
 }
 
+#if 0
 static int netxen_get_flash_block(struct netxen_adapter *adapter, int base,
 				  int size, __le32 * buf)
 {
 	int i, addr;
 	__le32 *ptr32;
-	u32 v;
+	int v;
 
 	addr = base;
 	ptr32 = buf;
@@ -732,38 +733,45 @@ static int netxen_get_flash_block(struct netxen_adapter *adapter, int base,
 
 	return 0;
 }
+#endif
 
-int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
+int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, u64 *mac)
 {
-	__le32 *pmac = (__le32 *) mac;
 	u32 offset;
+	u32 mac_hi, mac_lo;
+
+	*mac = 0ULL;
 
 	offset = NETXEN_USER_START +
 		offsetof(struct netxen_new_user_info, mac_addr) +
 		adapter->portnum * sizeof(u64);
 
-	if (netxen_get_flash_block(adapter, offset, sizeof(u64), pmac) == -1)
-		return -1;
-
-	if (*mac == cpu_to_le64(~0ULL)) {
+	if (netxen_rom_fast_read(adapter, offset, (int *)&mac_lo) != 0)
+		return -EIO;
+	if (netxen_rom_fast_read(adapter, offset+4, (int *)&mac_hi) !=0)
+		return -EIO;
 
+	if (mac_hi == 0) {
 		offset = NETXEN_USER_START_OLD +
 			offsetof(struct netxen_user_old_info, mac_addr) +
 			adapter->portnum * sizeof(u64);
 
-		if (netxen_get_flash_block(adapter,
-					offset, sizeof(u64), pmac) == -1)
-			return -1;
-
-		if (*mac == cpu_to_le64(~0ULL))
-			return -1;
+		if (netxen_rom_fast_read(adapter, offset, (int *)&mac_lo) != 0)
+			return -EIO;
+		if (netxen_rom_fast_read(adapter, offset+4, (int *)&mac_hi) !=0)
+			return -EIO;
+		if (mac_hi == 0)
+			return -EIO;
 	}
+
+	*mac = ((u64)mac_lo | ((u64)mac_hi << 32));
+
 	return 0;
 }
 
-int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
+int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, u64 *mac)
 {
-	uint32_t crbaddr, mac_hi, mac_lo;
+	u32 crbaddr, mac_hi, mac_lo;
 	int pci_func = adapter->ahw.pci_func;
 
 	crbaddr = CRB_MAC_BLOCK_START +
@@ -772,13 +780,13 @@ int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
 	adapter->hw_read_wx(adapter, crbaddr, &mac_lo, 4);
 	adapter->hw_read_wx(adapter, crbaddr+4, &mac_hi, 4);
 
-	mac_hi = cpu_to_le32(mac_hi);
-	mac_lo = cpu_to_le32(mac_lo);
+	mac_hi = (__force u32)cpu_to_le32(mac_hi);
+	mac_lo = (__force u32)cpu_to_le32(mac_lo);
 
 	if (pci_func & 1)
 		*mac = ((mac_lo >> 16) | ((u64)mac_hi << 16));
 	else
-		*mac = ((mac_lo) | ((u64)mac_hi << 32));
+		*mac = ((u64)mac_lo | ((u64)mac_hi << 32));
 
 	return 0;
 }
@@ -917,13 +925,12 @@ netxen_nic_pci_set_crbwindow_2M(struct netxen_adapter *adapter, ulong *off)
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
@@ -982,37 +989,15 @@ netxen_nic_hw_write_wx_128M(struct netxen_adapter *adapter,
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
+	BUG_ON(len != 4);
+
+	writel(*(u32 *) data, addr);
 
-		netxen_nic_hw_block_write64((u64 __iomem *) data, addr,
-					    (len >> 3));
-		break;
-	}
 	if (!ADDR_IN_WINDOW1(off))
 		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
 
@@ -1032,31 +1017,13 @@ netxen_nic_hw_read_wx_128M(struct netxen_adapter *adapter,
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
+	BUG_ON(len != 4);
+	*(u32 *) data = readl(addr);
 
 	if (!ADDR_IN_WINDOW1(off))
 		netxen_nic_pci_change_crbwindow_128M(adapter, 1);
@@ -1071,6 +1038,7 @@ netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter,
 	unsigned long flags = 0;
 	int rv;
 
+	BUG_ON(len != 4);
 	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off, len);
 
 	if (rv == -1) {
@@ -1084,34 +1052,11 @@ netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter,
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
 
 	return 0;
 }
@@ -1123,6 +1068,7 @@ netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter,
 	unsigned long flags = 0;
 	int rv;
 
+	BUG_ON(len != 4);
 	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off, len);
 
 	if (rv == -1) {
@@ -1136,33 +1082,11 @@ netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter,
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
@@ -1424,10 +1348,9 @@ static int netxen_nic_pci_mem_read_direct(struct netxen_adapter *adapter,
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
 
@@ -1447,7 +1370,7 @@ static int netxen_nic_pci_mem_read_direct(struct netxen_adapter *adapter,
 		return -1;
 	}
 
-	addr = (void *)(pci_base_offset(adapter, start));
+	addr = pci_base_offset(adapter, start);
 	if (!addr) {
 		write_unlock_irqrestore(&adapter->adapter_lock, flags);
 		mem_base = pci_resource_start(adapter->pdev, 0);
@@ -1498,10 +1421,9 @@ netxen_nic_pci_mem_write_direct(struct netxen_adapter *adapter, u64 off,
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
 
@@ -1521,7 +1443,7 @@ netxen_nic_pci_mem_write_direct(struct netxen_adapter *adapter, u64 off,
 		return -1;
 	}
 
-	addr = (void *)(pci_base_offset(adapter, start));
+	addr = pci_base_offset(adapter, start);
 	if (!addr) {
 		write_unlock_irqrestore(&adapter->adapter_lock, flags);
 		mem_base = pci_resource_start(adapter->pdev, 0);
@@ -1571,10 +1493,11 @@ int
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
@@ -1588,7 +1511,7 @@ netxen_nic_pci_mem_write_128M(struct netxen_adapter *adapter,
 	sz[0] = (size < (8 - off0)) ? size : (8 - off0);
 	sz[1] = size - sz[0];
 	loop = ((off0 + size - 1) >> 3) + 1;
-	mem_crb = (unsigned long)pci_base_offset(adapter, NETXEN_CRB_DDR_NET);
+	mem_crb = pci_base_offset(adapter, NETXEN_CRB_DDR_NET);
 
 	if ((size != 8) || (off0 != 0))  {
 		for (i = 0; i < loop; i++) {
@@ -1626,21 +1549,20 @@ netxen_nic_pci_mem_write_128M(struct netxen_adapter *adapter,
 
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
-			temp = readl(
-			     (void *)(mem_crb+MIU_TEST_AGT_CTRL));
+			temp = readl(mem_crb+MIU_TEST_AGT_CTRL);
 			if ((temp & MIU_TA_CTL_BUSY) == 0)
 				break;
 		}
@@ -1662,11 +1584,11 @@ int
 netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
 		u64 off, void *data, int size)
 {
-	unsigned long   flags, mem_crb;
+	unsigned long   flags;
 	int	     i, j = 0, k, start, end, loop, sz[2], off0[2];
 	uint32_t      temp;
 	uint64_t      off8, val, word[2] = {0, 0};
-
+	void __iomem *mem_crb;
 
 	/*
 	 * If not MN, go check for MS or invalid.
@@ -1680,24 +1602,23 @@ netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
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
-			temp = readl(
-			      (void *)(mem_crb+MIU_TEST_AGT_CTRL));
+			temp = readl(mem_crb+MIU_TEST_AGT_CTRL);
 			if ((temp & MIU_TA_CTL_BUSY) == 0)
 				break;
 		}
@@ -1712,7 +1633,7 @@ netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
 		end   = (off0[i] + sz[i] - 1) >> 2;
 		for (k = start; k <= end; k++) {
 			word[i] |= ((uint64_t) readl(
-				    (void *)(mem_crb +
+				    (mem_crb +
 				    MIU_TEST_AGT_RDDATA(k))) << (32*k));
 		}
 	}
@@ -2007,10 +1928,10 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
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
@@ -2178,13 +2099,13 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
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
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index d924468..c0e06a6 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1277,7 +1277,7 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 
 		dev_kfree_skb_any(skb);
 		for (i = 0; i < nr_frags; i++) {
-			index = frag_desc->frag_handles[i];
+			index = le16_to_cpu(frag_desc->frag_handles[i]);
 			skb = netxen_process_rxbuf(adapter,
 					rds_ring, index, cksum);
 			if (skb)
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index ba01524..5fe697a 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -438,7 +438,7 @@ netxen_read_mac_addr(struct netxen_adapter *adapter)
 {
 	int i;
 	unsigned char *p;
-	__le64 mac_addr;
+	u64 mac_addr;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 
-- 
1.6.0.2

