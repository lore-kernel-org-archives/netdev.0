From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 2/2] qlcnic: fix sparse warnings
Date: Sun, 18 Nov 2012 02:04:39 -0500
Message-ID: <1353222279-15736-3-git-send-email-sony.chacko@qlogic.com>
References: <1353222279-15736-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:25185 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751466Ab2KRHWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Nov 2012 02:22:45 -0500
In-Reply-To: <1353222279-15736-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

qlcnic_hw.c:1337:17: warning: cast removes address space of expression
qlcnic_hw.c:1337:17: warning: incorrect type in argument 2 (different address spaces)
qlcnic_hw.c:1337:17:    expected void volatile [noderef] <asn:2>*addr
qlcnic_hw.c:1337:17:    got void *<noident>
qlcnic_hw.c:1337:17: warning: cast removes address space of expression
qlcnic_hw.c:1337:17: warning: incorrect type in argument 1 (different address spaces)
qlcnic_hw.c:1337:17:    expected void const volatile [noderef] <asn:2>*addr
qlcnic_hw.c:1337:17:    got void *<noident>

The above warnings are originating from the macros QLCNIC_RD_DUMP_REG and
QLCNIC_WR_DUMP_REG.
The warnings are fixed and macros are replaced with equivalent functions
in the only file from where it is called.

The following warnings are fixed by making the functions static.

qlcnic_hw.c:543:5: warning: symbol 'qlcnic_set_fw_loopback' was not declared. Should it be static?
qlcnic_init.c:1853:6: warning: symbol 'qlcnic_process_rcv_diag' was not declared. Should it be static?

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h  | 16 ----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c   | 98 +++++++++++++++---------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c |  4 +-
 3 files changed, 65 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index 28a6b28..bd5030e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -792,22 +792,6 @@ static const u32 MIU_TEST_READ_DATA[] = {
 #define QLCNIC_FLASH_SEM2_ULK	0x0013C014
 #define QLCNIC_FLASH_LOCK_ID	0x001B2100
 
-#define QLCNIC_RD_DUMP_REG(addr, bar0, data) do {			\
-	writel((addr & 0xFFFF0000), (void *) (bar0 +			\
-		QLCNIC_FW_DUMP_REG1));					\
-	readl((void *) (bar0 + QLCNIC_FW_DUMP_REG1));			\
-	*data = readl((void *) (bar0 + QLCNIC_FW_DUMP_REG2 +		\
-		LSW(addr)));						\
-} while (0)
-
-#define QLCNIC_WR_DUMP_REG(addr, bar0, data) do {			\
-	writel((addr & 0xFFFF0000), (void *) (bar0 +			\
-		QLCNIC_FW_DUMP_REG1));					\
-	readl((void *) (bar0 + QLCNIC_FW_DUMP_REG1));			\
-	writel(data, (void *) (bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr)));\
-	readl((void *) (bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr)));	\
-} while (0)
-
 /* PCI function operational mode */
 enum {
 	QLCNIC_MGMT_FUNC	= 0,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index fc308c8..bd3e766 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -266,6 +266,33 @@ static const unsigned crb_hub_agt[64] = {
 	0,
 };
 
+static void qlcnic_read_dump_reg(u32 addr, void __iomem *bar0, u32 *data)
+{
+	u32 dest;
+	void __iomem *window_reg;
+
+	dest = addr & 0xFFFF0000;
+	window_reg = bar0 + QLCNIC_FW_DUMP_REG1;
+	writel(dest, window_reg);
+	readl(window_reg);
+	window_reg = bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr);
+	*data = readl(window_reg);
+}
+
+static void qlcnic_write_dump_reg(u32 addr, void __iomem *bar0, u32 data)
+{
+	u32 dest;
+	void __iomem *window_reg;
+
+	dest = addr & 0xFFFF0000;
+	window_reg = bar0 + QLCNIC_FW_DUMP_REG1;
+	writel(dest, window_reg);
+	readl(window_reg);
+	window_reg = bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr);
+	writel(data, window_reg);
+	readl(window_reg);
+}
+
 /*  PCI Windowing for DDR regions.  */
 
 #define QLCNIC_PCIE_SEM_TIMEOUT	10000
@@ -540,7 +567,7 @@ void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter)
 	}
 }
 
-int qlcnic_set_fw_loopback(struct qlcnic_adapter *adapter, u8 flag)
+static int qlcnic_set_fw_loopback(struct qlcnic_adapter *adapter, u8 flag)
 {
 	struct qlcnic_nic_req req;
 	int rv;
@@ -1334,7 +1361,7 @@ qlcnic_dump_crb(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
 	addr = crb->addr;
 
 	for (i = 0; i < crb->no_ops; i++) {
-		QLCNIC_RD_DUMP_REG(addr, base, &data);
+		qlcnic_read_dump_reg(addr, base, &data);
 		*buffer++ = cpu_to_le32(addr);
 		*buffer++ = cpu_to_le32(data);
 		addr += crb->stride;
@@ -1364,25 +1391,25 @@ qlcnic_dump_ctrl(struct qlcnic_adapter *adapter,
 				continue;
 			switch (1 << k) {
 			case QLCNIC_DUMP_WCRB:
-				QLCNIC_WR_DUMP_REG(addr, base, ctr->val1);
+				qlcnic_write_dump_reg(addr, base, ctr->val1);
 				break;
 			case QLCNIC_DUMP_RWCRB:
-				QLCNIC_RD_DUMP_REG(addr, base, &data);
-				QLCNIC_WR_DUMP_REG(addr, base, data);
+				qlcnic_read_dump_reg(addr, base, &data);
+				qlcnic_write_dump_reg(addr, base, data);
 				break;
 			case QLCNIC_DUMP_ANDCRB:
-				QLCNIC_RD_DUMP_REG(addr, base, &data);
-				QLCNIC_WR_DUMP_REG(addr, base,
-					(data & ctr->val2));
+				qlcnic_read_dump_reg(addr, base, &data);
+				qlcnic_write_dump_reg(addr, base,
+						      data & ctr->val2);
 				break;
 			case QLCNIC_DUMP_ORCRB:
-				QLCNIC_RD_DUMP_REG(addr, base, &data);
-				QLCNIC_WR_DUMP_REG(addr, base,
-					(data | ctr->val3));
+				qlcnic_read_dump_reg(addr, base, &data);
+				qlcnic_write_dump_reg(addr, base,
+						      data | ctr->val3);
 				break;
 			case QLCNIC_DUMP_POLLCRB:
 				while (timeout <= ctr->timeout) {
-					QLCNIC_RD_DUMP_REG(addr, base, &data);
+					qlcnic_read_dump_reg(addr, base, &data);
 					if ((data & ctr->val2) == ctr->val1)
 						break;
 					msleep(1);
@@ -1397,7 +1424,7 @@ qlcnic_dump_ctrl(struct qlcnic_adapter *adapter,
 			case QLCNIC_DUMP_RD_SAVE:
 				if (ctr->index_a)
 					addr = t_hdr->saved_state[ctr->index_a];
-				QLCNIC_RD_DUMP_REG(addr, base, &data);
+				qlcnic_read_dump_reg(addr, base, &data);
 				t_hdr->saved_state[ctr->index_v] = data;
 				break;
 			case QLCNIC_DUMP_WRT_SAVED:
@@ -1407,7 +1434,7 @@ qlcnic_dump_ctrl(struct qlcnic_adapter *adapter,
 					data = ctr->val1;
 				if (ctr->index_a)
 					addr = t_hdr->saved_state[ctr->index_a];
-				QLCNIC_WR_DUMP_REG(addr, base, data);
+				qlcnic_write_dump_reg(addr, base, data);
 				break;
 			case QLCNIC_DUMP_MOD_SAVE_ST:
 				data = t_hdr->saved_state[ctr->index_v];
@@ -1441,8 +1468,8 @@ qlcnic_dump_mux(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
 
 	val = mux->val;
 	for (loop = 0; loop < mux->no_ops; loop++) {
-		QLCNIC_WR_DUMP_REG(mux->addr, base, val);
-		QLCNIC_RD_DUMP_REG(mux->read_addr, base, &data);
+		qlcnic_write_dump_reg(mux->addr, base, val);
+		qlcnic_read_dump_reg(mux->read_addr, base, &data);
 		*buffer++ = cpu_to_le32(val);
 		*buffer++ = cpu_to_le32(data);
 		val += mux->val_stride;
@@ -1463,10 +1490,10 @@ qlcnic_dump_que(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
 	cnt = que->read_addr_cnt;
 
 	for (loop = 0; loop < que->no_ops; loop++) {
-		QLCNIC_WR_DUMP_REG(que->sel_addr, base, que_id);
+		qlcnic_write_dump_reg(que->sel_addr, base, que_id);
 		addr = que->read_addr;
 		for (i = 0; i < cnt; i++) {
-			QLCNIC_RD_DUMP_REG(addr, base, &data);
+			qlcnic_read_dump_reg(addr, base, &data);
 			*buffer++ = cpu_to_le32(data);
 			addr += que->read_addr_stride;
 		}
@@ -1514,9 +1541,9 @@ lock_try:
 	writel(adapter->ahw->pci_func, (base + QLCNIC_FLASH_LOCK_ID));
 	for (i = 0; i < size; i++) {
 		addr = fl_addr & 0xFFFF0000;
-		QLCNIC_WR_DUMP_REG(FLASH_ROM_WINDOW, base, addr);
+		qlcnic_write_dump_reg(FLASH_ROM_WINDOW, base, addr);
 		addr = LSW(fl_addr) + FLASH_ROM_DATA;
-		QLCNIC_RD_DUMP_REG(addr, base, &val);
+		qlcnic_read_dump_reg(addr, base, &val);
 		fl_addr += 4;
 		*buffer++ = cpu_to_le32(val);
 	}
@@ -1536,12 +1563,12 @@ qlcnic_dump_l1_cache(struct qlcnic_adapter *adapter,
 	val = l1->init_tag_val;
 
 	for (i = 0; i < l1->no_ops; i++) {
-		QLCNIC_WR_DUMP_REG(l1->addr, base, val);
-		QLCNIC_WR_DUMP_REG(l1->ctrl_addr, base, LSW(l1->ctrl_val));
+		qlcnic_write_dump_reg(l1->addr, base, val);
+		qlcnic_write_dump_reg(l1->ctrl_addr, base, LSW(l1->ctrl_val));
 		addr = l1->read_addr;
 		cnt = l1->read_addr_num;
 		while (cnt) {
-			QLCNIC_RD_DUMP_REG(addr, base, &data);
+			qlcnic_read_dump_reg(addr, base, &data);
 			*buffer++ = cpu_to_le32(data);
 			addr += l1->read_addr_stride;
 			cnt--;
@@ -1566,14 +1593,14 @@ qlcnic_dump_l2_cache(struct qlcnic_adapter *adapter,
 	poll_to = MSB(MSW(l2->ctrl_val));
 
 	for (i = 0; i < l2->no_ops; i++) {
-		QLCNIC_WR_DUMP_REG(l2->addr, base, val);
+		qlcnic_write_dump_reg(l2->addr, base, val);
 		if (LSW(l2->ctrl_val))
-			QLCNIC_WR_DUMP_REG(l2->ctrl_addr, base,
-				LSW(l2->ctrl_val));
+			qlcnic_write_dump_reg(l2->ctrl_addr, base,
+					      LSW(l2->ctrl_val));
 		if (!poll_mask)
 			goto skip_poll;
 		do {
-			QLCNIC_RD_DUMP_REG(l2->ctrl_addr, base, &data);
+			qlcnic_read_dump_reg(l2->ctrl_addr, base, &data);
 			if (!(data & poll_mask))
 				break;
 			msleep(1);
@@ -1590,7 +1617,7 @@ skip_poll:
 		addr = l2->read_addr;
 		cnt = l2->read_addr_num;
 		while (cnt) {
-			QLCNIC_RD_DUMP_REG(addr, base, &data);
+			qlcnic_read_dump_reg(addr, base, &data);
 			*buffer++ = cpu_to_le32(data);
 			addr += l2->read_addr_stride;
 			cnt--;
@@ -1622,13 +1649,13 @@ qlcnic_read_memory(struct qlcnic_adapter *adapter,
 	mutex_lock(&adapter->ahw->mem_lock);
 
 	while (reg_read != 0) {
-		QLCNIC_WR_DUMP_REG(MIU_TEST_ADDR_LO, base, addr);
-		QLCNIC_WR_DUMP_REG(MIU_TEST_ADDR_HI, base, 0);
-		QLCNIC_WR_DUMP_REG(MIU_TEST_CTR, base,
-			TA_CTL_ENABLE | TA_CTL_START);
+		qlcnic_write_dump_reg(MIU_TEST_ADDR_LO, base, addr);
+		qlcnic_write_dump_reg(MIU_TEST_ADDR_HI, base, 0);
+		qlcnic_write_dump_reg(MIU_TEST_CTR, base,
+				      TA_CTL_ENABLE | TA_CTL_START);
 
 		for (i = 0; i < MAX_CTL_CHECK; i++) {
-			QLCNIC_RD_DUMP_REG(MIU_TEST_CTR, base, &test);
+			qlcnic_read_dump_reg(MIU_TEST_CTR, base, &test);
 			if (!(test & TA_CTL_BUSY))
 				break;
 		}
@@ -1641,7 +1668,8 @@ qlcnic_read_memory(struct qlcnic_adapter *adapter,
 			}
 		}
 		for (i = 0; i < 4; i++) {
-			QLCNIC_RD_DUMP_REG(MIU_TEST_READ_DATA[i], base, &data);
+			qlcnic_read_dump_reg(MIU_TEST_READ_DATA[i], base,
+					     &data);
 			*buffer++ = cpu_to_le32(data);
 		}
 		addr += 16;
@@ -1661,7 +1689,7 @@ qlcnic_dump_nop(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-struct qlcnic_dump_operations fw_dump_ops[] = {
+static const struct qlcnic_dump_operations fw_dump_ops[] = {
 	{ QLCNIC_DUMP_NOP, qlcnic_dump_nop },
 	{ QLCNIC_DUMP_READ_CRB, qlcnic_dump_crb },
 	{ QLCNIC_DUMP_READ_MUX, qlcnic_dump_mux },
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index faae9c5..a7f5bbe 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -1849,8 +1849,8 @@ static void dump_skb(struct sk_buff *skb, struct qlcnic_adapter *adapter)
 	}
 }
 
-void qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter, int ring,
-			     u64 sts_data0)
+static void qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter, int ring,
+				    u64 sts_data0)
 {
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct sk_buff *skb;
-- 
1.8.0
