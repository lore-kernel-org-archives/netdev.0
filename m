From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/5] netxen: improve pci memory access
Date: Fri, 11 Sep 2009 14:28:12 -0700
Message-ID: <1252704495-16118-3-git-send-email-dhananjay@netxen.com>
References: <1252704495-16118-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43921 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756912AbZIKV2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 17:28:13 -0400
In-Reply-To: <1252704495-16118-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Access on card memory through memory controller (agent)
  rather than moving small pci window around. Clean up the
  code for moving windows around.

o Restrict memory accesss to 64 bit, currently only firmware
  download uses this.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    4 +-
 drivers/net/netxen/netxen_nic_hw.c   |  348 +++++++++-------------------------
 drivers/net/netxen/netxen_nic_main.c |    7 +-
 3 files changed, 93 insertions(+), 266 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 2371888..7e3d2b9 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -552,8 +552,8 @@ struct netxen_hardware_context {
 
 	int qdr_sn_window;
 	int ddr_mn_window;
-	unsigned long mn_win_crb;
-	unsigned long ms_win_crb;
+	u32 mn_win_crb;
+	u32 ms_win_crb;
 
 	u8 cut_through;
 	u8 revision_id;
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 555bc4a..018cf42 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1279,25 +1279,6 @@ netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter, ulong off)
 	return data;
 }
 
-/*
- * check memory access boundary.
- * used by test agent. support ddr access only for now
- */
-static unsigned long
-netxen_nic_pci_mem_bound_check(struct netxen_adapter *adapter,
-		unsigned long long addr, int size)
-{
-	if (!ADDR_IN_RANGE(addr,
-			NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX) ||
-		!ADDR_IN_RANGE(addr+size-1,
-			NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX) ||
-		((size != 1) && (size != 2) && (size != 4) && (size != 8))) {
-		return 0;
-	}
-
-	return 1;
-}
-
 static int netxen_pci_set_window_warning_count;
 
 static unsigned long
@@ -1424,10 +1405,8 @@ netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 		/* DDR network side */
 		window = MN_WIN(addr);
 		adapter->ahw.ddr_mn_window = window;
-		NXWR32(adapter, adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
-				window);
-		win_read = NXRD32(adapter,
-				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE);
+		NXWR32(adapter, adapter->ahw.mn_win_crb, window);
+		win_read = NXRD32(adapter, adapter->ahw.mn_win_crb);
 		if ((win_read << 17) != window) {
 			printk(KERN_INFO "Written MNwin (0x%x) != "
 				"Read MNwin (0x%x)\n", window, win_read);
@@ -1442,10 +1421,8 @@ netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 
 		window = OCM_WIN(addr);
 		adapter->ahw.ddr_mn_window = window;
-		NXWR32(adapter, adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE,
-				window);
-		win_read = NXRD32(adapter,
-				adapter->ahw.mn_win_crb | NETXEN_PCI_CRBSPACE);
+		NXWR32(adapter, adapter->ahw.mn_win_crb, window);
+		win_read = NXRD32(adapter, adapter->ahw.mn_win_crb);
 		if ((win_read >> 7) != window) {
 			printk(KERN_INFO "%s: Written OCMwin (0x%x) != "
 					"Read OCMwin (0x%x)\n",
@@ -1458,10 +1435,8 @@ netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 		/* QDR network side */
 		window = MS_WIN(addr);
 		adapter->ahw.qdr_sn_window = window;
-		NXWR32(adapter, adapter->ahw.ms_win_crb | NETXEN_PCI_CRBSPACE,
-				window);
-		win_read = NXRD32(adapter,
-				adapter->ahw.ms_win_crb | NETXEN_PCI_CRBSPACE);
+		NXWR32(adapter, adapter->ahw.ms_win_crb, window);
+		win_read = NXRD32(adapter, adapter->ahw.ms_win_crb);
 		if (win_read != window) {
 			printk(KERN_INFO "%s: Written MSwin (0x%x) != "
 					"Read MSwin (0x%x)\n",
@@ -1484,177 +1459,6 @@ netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 	return addr;
 }
 
-static int netxen_nic_pci_is_same_window(struct netxen_adapter *adapter,
-				      unsigned long long addr)
-{
-	int window;
-	unsigned long long qdr_max;
-
-	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
-		qdr_max = NETXEN_ADDR_QDR_NET_MAX_P2;
-	else
-		qdr_max = NETXEN_ADDR_QDR_NET_MAX_P3;
-
-	if (ADDR_IN_RANGE(addr,
-			NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX)) {
-		/* DDR network side */
-		BUG();	/* MN access can not come here */
-	} else if (ADDR_IN_RANGE(addr,
-			NETXEN_ADDR_OCM0, NETXEN_ADDR_OCM0_MAX)) {
-		return 1;
-	} else if (ADDR_IN_RANGE(addr,
-				NETXEN_ADDR_OCM1, NETXEN_ADDR_OCM1_MAX)) {
-		return 1;
-	} else if (ADDR_IN_RANGE(addr, NETXEN_ADDR_QDR_NET, qdr_max)) {
-		/* QDR network side */
-		window = ((addr - NETXEN_ADDR_QDR_NET) >> 22) & 0x3f;
-		if (adapter->ahw.qdr_sn_window == window)
-			return 1;
-	}
-
-	return 0;
-}
-
-static int netxen_nic_pci_mem_read_direct(struct netxen_adapter *adapter,
-			u64 off, void *data, int size)
-{
-	unsigned long flags;
-	void __iomem *addr, *mem_ptr = NULL;
-	int ret = 0;
-	u64 start;
-	unsigned long mem_base;
-	unsigned long mem_page;
-
-	write_lock_irqsave(&adapter->adapter_lock, flags);
-
-	/*
-	 * If attempting to access unknown address or straddle hw windows,
-	 * do not access.
-	 */
-	start = adapter->pci_set_window(adapter, off);
-	if ((start == -1UL) ||
-		(netxen_nic_pci_is_same_window(adapter, off+size-1) == 0)) {
-		write_unlock_irqrestore(&adapter->adapter_lock, flags);
-		printk(KERN_ERR "%s out of bound pci memory access. "
-			"offset is 0x%llx\n", netxen_nic_driver_name,
-			(unsigned long long)off);
-		return -1;
-	}
-
-	addr = pci_base_offset(adapter, start);
-	if (!addr) {
-		write_unlock_irqrestore(&adapter->adapter_lock, flags);
-		mem_base = pci_resource_start(adapter->pdev, 0);
-		mem_page = start & PAGE_MASK;
-		/* Map two pages whenever user tries to access addresses in two
-		consecutive pages.
-		*/
-		if (mem_page != ((start + size - 1) & PAGE_MASK))
-			mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE * 2);
-		else
-			mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE);
-		if (mem_ptr == NULL) {
-			*(uint8_t  *)data = 0;
-			return -1;
-		}
-		addr = mem_ptr;
-		addr += start & (PAGE_SIZE - 1);
-		write_lock_irqsave(&adapter->adapter_lock, flags);
-	}
-
-	switch (size) {
-	case 1:
-		*(uint8_t  *)data = readb(addr);
-		break;
-	case 2:
-		*(uint16_t *)data = readw(addr);
-		break;
-	case 4:
-		*(uint32_t *)data = readl(addr);
-		break;
-	case 8:
-		*(uint64_t *)data = readq(addr);
-		break;
-	default:
-		ret = -1;
-		break;
-	}
-	write_unlock_irqrestore(&adapter->adapter_lock, flags);
-
-	if (mem_ptr)
-		iounmap(mem_ptr);
-	return ret;
-}
-
-static int
-netxen_nic_pci_mem_write_direct(struct netxen_adapter *adapter, u64 off,
-		void *data, int size)
-{
-	unsigned long flags;
-	void __iomem *addr, *mem_ptr = NULL;
-	int ret = 0;
-	u64 start;
-	unsigned long mem_base;
-	unsigned long mem_page;
-
-	write_lock_irqsave(&adapter->adapter_lock, flags);
-
-	/*
-	 * If attempting to access unknown address or straddle hw windows,
-	 * do not access.
-	 */
-	start = adapter->pci_set_window(adapter, off);
-	if ((start == -1UL) ||
-		(netxen_nic_pci_is_same_window(adapter, off+size-1) == 0)) {
-		write_unlock_irqrestore(&adapter->adapter_lock, flags);
-		printk(KERN_ERR "%s out of bound pci memory access. "
-			"offset is 0x%llx\n", netxen_nic_driver_name,
-			(unsigned long long)off);
-		return -1;
-	}
-
-	addr = pci_base_offset(adapter, start);
-	if (!addr) {
-		write_unlock_irqrestore(&adapter->adapter_lock, flags);
-		mem_base = pci_resource_start(adapter->pdev, 0);
-		mem_page = start & PAGE_MASK;
-		/* Map two pages whenever user tries to access addresses in two
-		 * consecutive pages.
-		 */
-		if (mem_page != ((start + size - 1) & PAGE_MASK))
-			mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE*2);
-		else
-			mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE);
-		if (mem_ptr == NULL)
-			return -1;
-		addr = mem_ptr;
-		addr += start & (PAGE_SIZE - 1);
-		write_lock_irqsave(&adapter->adapter_lock, flags);
-	}
-
-	switch (size) {
-	case 1:
-		writeb(*(uint8_t *)data, addr);
-		break;
-	case 2:
-		writew(*(uint16_t *)data, addr);
-		break;
-	case 4:
-		writel(*(uint32_t *)data, addr);
-		break;
-	case 8:
-		writeq(*(uint64_t *)data, addr);
-		break;
-	default:
-		ret = -1;
-		break;
-	}
-	write_unlock_irqrestore(&adapter->adapter_lock, flags);
-	if (mem_ptr)
-		iounmap(mem_ptr);
-	return ret;
-}
-
 #define MAX_CTL_CHECK   1000
 
 static int
@@ -1667,19 +1471,28 @@ netxen_nic_pci_mem_write_128M(struct netxen_adapter *adapter,
 	uint64_t      off8, tmpw, word[2] = {0, 0};
 	void __iomem *mem_crb;
 
-	/*
-	 * If not MN, go check for MS or invalid.
-	 */
-	if (netxen_nic_pci_mem_bound_check(adapter, off, size) == 0)
-		return netxen_nic_pci_mem_write_direct(adapter,
-				off, data, size);
+	if (size != 8)
+		return -EIO;
+
+	if (ADDR_IN_RANGE(off, NETXEN_ADDR_QDR_NET,
+				NETXEN_ADDR_QDR_NET_MAX_P2)) {
+		mem_crb = pci_base_offset(adapter, NETXEN_CRB_QDR_NET);
+		goto correct;
+	}
+
+	if (ADDR_IN_RANGE(off, NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX)) {
+		mem_crb = pci_base_offset(adapter, NETXEN_CRB_DDR_NET);
+		goto correct;
+	}
+
+	return -EIO;
 
+correct:
 	off8 = off & 0xfffffff8;
 	off0 = off & 0x7;
 	sz[0] = (size < (8 - off0)) ? size : (8 - off0);
 	sz[1] = size - sz[0];
 	loop = ((off0 + size - 1) >> 3) + 1;
-	mem_crb = pci_base_offset(adapter, NETXEN_CRB_DDR_NET);
 
 	if ((size != 8) || (off0 != 0))  {
 		for (i = 0; i < loop; i++) {
@@ -1760,20 +1573,29 @@ netxen_nic_pci_mem_read_128M(struct netxen_adapter *adapter,
 	uint64_t      off8, val, word[2] = {0, 0};
 	void __iomem *mem_crb;
 
+	if (size != 8)
+		return -EIO;
 
-	/*
-	 * If not MN, go check for MS or invalid.
-	 */
-	if (netxen_nic_pci_mem_bound_check(adapter, off, size) == 0)
-		return netxen_nic_pci_mem_read_direct(adapter, off, data, size);
+	if (ADDR_IN_RANGE(off, NETXEN_ADDR_QDR_NET,
+				NETXEN_ADDR_QDR_NET_MAX_P2)) {
+		mem_crb = pci_base_offset(adapter, NETXEN_CRB_QDR_NET);
+		goto correct;
+	}
 
+	if (ADDR_IN_RANGE(off, NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX)) {
+		mem_crb = pci_base_offset(adapter, NETXEN_CRB_DDR_NET);
+		goto correct;
+	}
+
+	return -EIO;
+
+correct:
 	off8 = off & 0xfffffff8;
 	off0[0] = off & 0x7;
 	off0[1] = 0;
 	sz[0] = (size < (8 - off0[0])) ? size : (8 - off0[0]);
 	sz[1] = size - sz[0];
 	loop = ((off0[0] + size - 1) >> 3) + 1;
-	mem_crb = pci_base_offset(adapter, NETXEN_CRB_DDR_NET);
 
 	write_lock_irqsave(&adapter->adapter_lock, flags);
 	netxen_nic_pci_change_crbwindow_128M(adapter, 0);
@@ -1847,20 +1669,26 @@ netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
 {
 	int i, j, ret = 0, loop, sz[2], off0;
 	uint32_t temp;
-	uint64_t off8, mem_crb, tmpw, word[2] = {0, 0};
+	uint64_t off8, tmpw, word[2] = {0, 0};
+	void __iomem *mem_crb;
 
-	/*
-	 * If not MN, go check for MS or invalid.
-	 */
-	if (off >= NETXEN_ADDR_QDR_NET && off <= NETXEN_ADDR_QDR_NET_MAX_P3)
-		mem_crb = NETXEN_CRB_QDR_NET;
-	else {
-		mem_crb = NETXEN_CRB_DDR_NET;
-		if (netxen_nic_pci_mem_bound_check(adapter, off, size) == 0)
-			return netxen_nic_pci_mem_write_direct(adapter,
-					off, data, size);
+	if (size != 8)
+		return -EIO;
+
+	if (ADDR_IN_RANGE(off, NETXEN_ADDR_QDR_NET,
+				NETXEN_ADDR_QDR_NET_MAX_P3)) {
+		mem_crb = netxen_get_ioaddr(adapter, NETXEN_CRB_QDR_NET);
+		goto correct;
 	}
 
+	if (ADDR_IN_RANGE(off, NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX)) {
+		mem_crb = netxen_get_ioaddr(adapter, NETXEN_CRB_DDR_NET);
+		goto correct;
+	}
+
+	return -EIO;
+
+correct:
 	off8 = off & 0xfffffff8;
 	off0 = off & 0x7;
 	sz[0] = (size < (8 - off0)) ? size : (8 - off0);
@@ -1906,21 +1734,18 @@ netxen_nic_pci_mem_write_2M(struct netxen_adapter *adapter,
 	 */
 
 	for (i = 0; i < loop; i++) {
-		temp = off8 + (i << 3);
-		NXWR32(adapter, mem_crb+MIU_TEST_AGT_ADDR_LO, temp);
-		temp = 0;
-		NXWR32(adapter, mem_crb+MIU_TEST_AGT_ADDR_HI, temp);
-		temp = word[i] & 0xffffffff;
-		NXWR32(adapter, mem_crb+MIU_TEST_AGT_WRDATA_LO, temp);
-		temp = (word[i] >> 32) & 0xffffffff;
-		NXWR32(adapter, mem_crb+MIU_TEST_AGT_WRDATA_HI, temp);
-		temp = MIU_TA_CTL_ENABLE | MIU_TA_CTL_WRITE;
-		NXWR32(adapter, mem_crb+MIU_TEST_AGT_CTRL, temp);
-		temp = MIU_TA_CTL_START | MIU_TA_CTL_ENABLE | MIU_TA_CTL_WRITE;
-		NXWR32(adapter, mem_crb+MIU_TEST_AGT_CTRL, temp);
+		writel(off8 + (i << 3), mem_crb+MIU_TEST_AGT_ADDR_LO);
+		writel(0, mem_crb+MIU_TEST_AGT_ADDR_HI);
+		writel(word[i] & 0xffffffff, mem_crb+MIU_TEST_AGT_WRDATA_LO);
+		writel((word[i] >> 32) & 0xffffffff,
+				mem_crb+MIU_TEST_AGT_WRDATA_HI);
+		writel((MIU_TA_CTL_ENABLE | MIU_TA_CTL_WRITE),
+				mem_crb+MIU_TEST_AGT_CTRL);
+		writel(MIU_TA_CTL_START | MIU_TA_CTL_ENABLE | MIU_TA_CTL_WRITE,
+				mem_crb+MIU_TEST_AGT_CTRL);
 
 		for (j = 0; j < MAX_CTL_CHECK; j++) {
-			temp = NXRD32(adapter, mem_crb + MIU_TEST_AGT_CTRL);
+			temp = readl(mem_crb + MIU_TEST_AGT_CTRL);
 			if ((temp & MIU_TA_CTL_BUSY) == 0)
 				break;
 		}
@@ -1947,21 +1772,26 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 {
 	int i, j = 0, k, start, end, loop, sz[2], off0[2];
 	uint32_t      temp;
-	uint64_t      off8, val, mem_crb, word[2] = {0, 0};
+	uint64_t      off8, val, word[2] = {0, 0};
+	void __iomem *mem_crb;
 
-	/*
-	 * If not MN, go check for MS or invalid.
-	 */
+	if (size != 8)
+		return -EIO;
+
+	if (ADDR_IN_RANGE(off, NETXEN_ADDR_QDR_NET,
+				NETXEN_ADDR_QDR_NET_MAX_P3)) {
+		mem_crb = netxen_get_ioaddr(adapter, NETXEN_CRB_QDR_NET);
+		goto correct;
+	}
 
-	if (off >= NETXEN_ADDR_QDR_NET && off <= NETXEN_ADDR_QDR_NET_MAX_P3)
-		mem_crb = NETXEN_CRB_QDR_NET;
-	else {
-		mem_crb = NETXEN_CRB_DDR_NET;
-		if (netxen_nic_pci_mem_bound_check(adapter, off, size) == 0)
-			return netxen_nic_pci_mem_read_direct(adapter,
-					off, data, size);
+	if (ADDR_IN_RANGE(off, NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX)) {
+		mem_crb = netxen_get_ioaddr(adapter, NETXEN_CRB_DDR_NET);
+		goto correct;
 	}
 
+	return -EIO;
+
+correct:
 	off8 = off & 0xfffffff8;
 	off0[0] = off & 0x7;
 	off0[1] = 0;
@@ -1976,17 +1806,14 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 	 */
 
 	for (i = 0; i < loop; i++) {
-		temp = off8 + (i << 3);
-		NXWR32(adapter, mem_crb + MIU_TEST_AGT_ADDR_LO, temp);
-		temp = 0;
-		NXWR32(adapter, mem_crb + MIU_TEST_AGT_ADDR_HI, temp);
-		temp = MIU_TA_CTL_ENABLE;
-		NXWR32(adapter, mem_crb + MIU_TEST_AGT_CTRL, temp);
-		temp = MIU_TA_CTL_START | MIU_TA_CTL_ENABLE;
-		NXWR32(adapter, mem_crb + MIU_TEST_AGT_CTRL, temp);
+		writel(off8 + (i << 3), mem_crb + MIU_TEST_AGT_ADDR_LO);
+		writel(0, mem_crb + MIU_TEST_AGT_ADDR_HI);
+		writel(MIU_TA_CTL_ENABLE, mem_crb + MIU_TEST_AGT_CTRL);
+		writel(MIU_TA_CTL_START | MIU_TA_CTL_ENABLE,
+				mem_crb + MIU_TEST_AGT_CTRL);
 
 		for (j = 0; j < MAX_CTL_CHECK; j++) {
-			temp = NXRD32(adapter, mem_crb + MIU_TEST_AGT_CTRL);
+			temp = readl(mem_crb + MIU_TEST_AGT_CTRL);
 			if ((temp & MIU_TA_CTL_BUSY) == 0)
 				break;
 		}
@@ -2001,8 +1828,7 @@ netxen_nic_pci_mem_read_2M(struct netxen_adapter *adapter,
 		start = off0[i] >> 2;
 		end   = (off0[i] + sz[i] - 1) >> 2;
 		for (k = start; k <= end; k++) {
-			temp = NXRD32(adapter,
-				mem_crb + MIU_TEST_AGT_RDDATA(k));
+			temp = readl(mem_crb + MIU_TEST_AGT_RDDATA(k));
 			word[i] |= ((uint64_t)temp << (32 * k));
 		}
 	}
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 81c24a7..c6f32e5 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -643,9 +643,10 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 		adapter->ahw.ddr_mn_window = 0;
 		adapter->ahw.qdr_sn_window = 0;
 
-		adapter->ahw.mn_win_crb = 0x100000 + PCIX_MN_WINDOW +
-			(pci_func * 0x20);
-		adapter->ahw.ms_win_crb = 0x100000 + PCIX_SN_WINDOW;
+		adapter->ahw.mn_win_crb = NETXEN_PCI_CRBSPACE +
+			0x100000 + PCIX_MN_WINDOW + (pci_func * 0x20);
+		adapter->ahw.ms_win_crb = NETXEN_PCI_CRBSPACE +
+			0x100000 + PCIX_SN_WINDOW;
 		if (pci_func < 4)
 			adapter->ahw.ms_win_crb += (pci_func * 0x20);
 		else
-- 
1.6.0.2

