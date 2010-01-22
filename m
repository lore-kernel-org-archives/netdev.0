From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH v2 2/3] igb: add registers etc. printout code just before
 resetting adapters
Date: Fri, 22 Jan 2010 17:49:24 +0900
Message-ID: <4B596694.1030604@jp.fujitsu.com>
References: <4B593B74.2020601@jp.fujitsu.com> <4B593C6E.5050405@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	chavey@google.com, joe@perches.com
To: netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:42892 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab0AVItl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 03:49:41 -0500
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0M8neUa018142
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Fri, 22 Jan 2010 17:49:40 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E2DE945DE54
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 17:49:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FA0F45DE52
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 17:49:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EC991DB805B
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 17:49:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D13AF1DB8040
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 17:49:37 +0900 (JST)
In-Reply-To: <4B593C6E.5050405@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds registers (,tx/rx rings' status and so on) printout
code just before resetting adapters. This will be helpful for detecting
the root cause of adapters reset.

The default output is netdevice status (transstart, last_rx), registers,
and tx/rx rings' simple information. TX/RX descriptors information and
buffer_info  can be output by changing the dump_flag module option, but,
of course, the amount of output becomes quite large.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 drivers/net/igb/e1000_hw.h   |    7 +
 drivers/net/igb/e1000_regs.h |   21 +++
 drivers/net/igb/igb_main.c   |  294 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 322 insertions(+)

Index: net-next-2.6/drivers/net/igb/igb_main.c
===================================================================
--- net-next-2.6.orig/drivers/net/igb/igb_main.c
+++ net-next-2.6/drivers/net/igb/igb_main.c
@@ -60,6 +60,14 @@ static const struct e1000_info *igb_info
 	[board_82575] = &e1000_82575_info,
 };

+static unsigned int dump_flag = 1;
+module_param(dump_flag, uint, 0644);
+MODULE_PARM_DESC(dump_flag, "Dump Flag");
+#define IGB_DUMP_REGS		(1 << 0)
+#define IGB_DUMP_TX_RINGS	(1 << 1)
+#define IGB_DUMP_RX_RINGS	(1 << 2)
+#define IGB_DUMP_BUFFERS	(1 << 3)
+
 static DEFINE_PCI_DEVICE_TABLE(igb_pci_tbl) = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_FIBER), board_82575 },
@@ -189,6 +197,291 @@ MODULE_DESCRIPTION("Intel(R) Gigabit Eth
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);

+/*
+ * igb_regdump - register printout routine
+ */
+static void igb_regdump(struct e1000_hw *hw, u32 reg,
+			char *name, u32 (*get_regofs)(int))
+{
+	printk(KERN_ERR "%-15s %08x\n", name, rd32(reg));
+}
+
+/*
+ * igb_regdump_n - register printout routine
+ */
+static void igb_regdump_n(struct e1000_hw *hw, u32 reg,
+			  char *name, u32 (*get_regofs)(int))
+{
+	int n = 0;
+	char rname[16];
+
+	if (!get_regofs)
+		return;
+
+	snprintf(rname, 16, "%s%s", name, "[0-3]");
+	printk(KERN_ERR "%-15s ", rname);
+	for (n = 0; n < 4; n++)
+		printk(KERN_CONT "%08x ", rd32(get_regofs(n)));
+	printk(KERN_CONT "\n");
+}
+
+static const struct igb_reg_info igb_reg_info_tbl[] = {
+
+	/* General Registers */
+	{E1000_CTRL, "CTRL", NULL, igb_regdump},
+	{E1000_STATUS, "STATUS", NULL, igb_regdump},
+	{E1000_CTRL_EXT, "CTRL_EXT", NULL, igb_regdump},
+
+	/* Interrupt Registers */
+	{E1000_ICR, "ICR", NULL, igb_regdump},
+
+	/* RX Registers */
+	{E1000_RCTL, "RCTL", NULL, igb_regdump},
+	{E1000_RDLEN(0), "RDLEN", get_regofs_RDLEN, igb_regdump_n},
+	{E1000_RDH(0), "RDH", get_regofs_RDH, igb_regdump_n},
+	{E1000_RDT(0), "RDT", get_regofs_RDT, igb_regdump_n},
+	{E1000_RXDCTL(0), "RXDCTL", get_regofs_RXDCTL, igb_regdump_n},
+	{E1000_RDBAL(0), "RDBAL", get_regofs_RDBAL, igb_regdump_n},
+	{E1000_RDBAH(0), "RDBAH", get_regofs_RDBAH, igb_regdump_n},
+
+	/* TX Registers */
+	{E1000_TCTL, "TCTL", NULL, igb_regdump},
+	{E1000_TDBAL(0), "TDBAL", get_regofs_TDBAL, igb_regdump_n},
+	{E1000_TDBAH(0), "TDBAH", get_regofs_TDBAH, igb_regdump_n},
+	{E1000_TDLEN(0), "TDLEN", get_regofs_TDLEN, igb_regdump_n},
+	{E1000_TDH(0), "TDH", get_regofs_TDH, igb_regdump_n},
+	{E1000_TDT(0), "TDT", get_regofs_TDT, igb_regdump_n},
+	{E1000_TXDCTL(0), "TXDCTL", get_regofs_TXDCTL, igb_regdump_n},
+	{E1000_TDFH, "TDFH", NULL, igb_regdump},
+	{E1000_TDFT, "TDFT", NULL, igb_regdump},
+	{E1000_TDFHS, "TDFHS", NULL, igb_regdump},
+	{E1000_TDFPC, "TDFPC", NULL, igb_regdump},
+
+	/* List Terminator */
+	{}
+};
+
+/*
+ * igb_dump - Print registers, tx-rings and rx-rings
+ */
+static void igb_dump(struct igb_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct e1000_hw *hw = &adapter->hw;
+	struct igb_reg_info *reginfo;
+	int n = 0;
+	struct igb_ring *tx_ring;
+	union e1000_adv_tx_desc *tx_desc;
+	struct my_u0 { u64 a; u64 b; } *u0;
+	struct igb_buffer *buffer_info;
+	struct igb_ring *rx_ring;
+	union e1000_adv_rx_desc *rx_desc;
+	u32 staterr;
+	int i = 0;
+
+	/* Print netdevice Info */
+	if (netdev) {
+		dev_err(&adapter->pdev->dev, "Net device Info\n");
+		printk(KERN_ERR "Device Name     state            "
+			"trans_start      last_rx\n");
+		printk(KERN_ERR "%-15s %016lX %016lX %016lX\n",
+		netdev->name,
+		netdev->state,
+		netdev->trans_start,
+		netdev->last_rx);
+	}
+
+	/* Print Registers */
+	if ((dump_flag & IGB_DUMP_REGS) == 0)
+		goto tx_ring_summary;
+
+	dev_err(&adapter->pdev->dev, "Register Dump\n");
+	printk(KERN_ERR " Register Name   Value \n");
+	for (reginfo = (struct igb_reg_info *)igb_reg_info_tbl;
+	     reginfo->name; reginfo++) {
+		reginfo->dump_reg(hw, reginfo->reg, reginfo->name,
+					reginfo->get_regofs);
+	}
+
+	/* Print TX Ring Summary */
+tx_ring_summary:
+	if (!netdev || !netif_running(netdev))
+		goto exit;
+
+	dev_err(&adapter->pdev->dev, "TX Rings Summary\n");
+	printk(KERN_ERR "Queue [NTU] [NTC] [bi(ntc)->dma  ]"
+		" leng ntw timestamp\n");
+	for (n = 0; n < adapter->num_tx_queues; n++) {
+		tx_ring = &adapter->tx_ring[n];
+		buffer_info = &tx_ring->buffer_info[tx_ring->next_to_clean];
+		printk(KERN_ERR " %5d %5X %5X %016llX %04X %3X %016llX\n",
+			   n, tx_ring->next_to_use, tx_ring->next_to_clean,
+			   (u64)buffer_info->dma,
+			   buffer_info->length,
+			   buffer_info->next_to_watch,
+			   (u64)buffer_info->time_stamp);
+	}
+
+	/* Print TX Rings */
+	if ((dump_flag & IGB_DUMP_TX_RINGS) == 0)
+		goto rx_ring_summary;
+
+	dev_err(&adapter->pdev->dev, "TX Rings Dump\n");
+
+	/* Transmit Descriptor Formats
+	 *
+	 * Advanced Transmit Descriptor
+	 *   +--------------------------------------------------------------+
+	 * 0 |         Buffer Address [63:0]                                |
+	 *   +--------------------------------------------------------------+
+	 * 8 | PAYLEN  | PORTS  |CC|IDX | STA | DCMD  |DTYP|MAC|RSV| DTALEN |
+	 *   +--------------------------------------------------------------+
+	 *   63      46 45    40 39 38 36 35 32 31   24             15       0
+	 */
+
+	for (n = 0; n < adapter->num_tx_queues; n++) {
+		tx_ring = &adapter->tx_ring[n];
+		printk(KERN_ERR "------------------------------------\n");
+		printk(KERN_ERR "TX QUEUE INDEX = %d\n", tx_ring->queue_index);
+		printk(KERN_ERR "------------------------------------\n");
+		printk(KERN_ERR "T [desc]     [address 63:0  ] "
+			"[PlPOCIStDDM Ln] [bi->dma       ] "
+			"leng  ntw timestamp        bi->skb\n");
+
+		for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
+			tx_desc = E1000_TX_DESC_ADV(*tx_ring, i);
+			buffer_info = &tx_ring->buffer_info[i];
+			u0 = (struct my_u0 *)tx_desc;
+			printk(KERN_ERR "T [0x%03X]    %016llX %016llX %016llX"
+				" %04X  %3X %016llX %p", i,
+				le64_to_cpu(u0->a),
+				le64_to_cpu(u0->b),
+				(u64)buffer_info->dma,
+				buffer_info->length,
+				buffer_info->next_to_watch,
+				(u64)buffer_info->time_stamp,
+				buffer_info->skb);
+			if (i == tx_ring->next_to_use &&
+				i == tx_ring->next_to_clean)
+				printk(KERN_CONT " NTC/U\n");
+			else if (i == tx_ring->next_to_use)
+				printk(KERN_CONT " NTU\n");
+			else if (i == tx_ring->next_to_clean)
+				printk(KERN_CONT " NTC\n");
+			else
+				printk(KERN_CONT "\n");
+
+			if ((dump_flag & IGB_DUMP_BUFFERS) &&
+				buffer_info->dma != 0)
+				print_hex_dump(KERN_ERR, "",
+					DUMP_PREFIX_ADDRESS,
+					16, 1, phys_to_virt(buffer_info->dma),
+					buffer_info->length, true);
+		}
+	}
+
+	/* Print RX Rings Summary */
+rx_ring_summary:
+	dev_err(&adapter->pdev->dev, "RX Rings Summary\n");
+	printk(KERN_ERR "Queue [NTU] [NTC]\n");
+	for (n = 0; n < adapter->num_rx_queues; n++) {
+		rx_ring = &adapter->rx_ring[n];
+		printk(KERN_ERR " %5d %5X %5X\n", n,
+			   rx_ring->next_to_use, rx_ring->next_to_clean);
+	}
+
+	/* Print RX Rings */
+	if ((dump_flag & IGB_DUMP_RX_RINGS) == 0)
+		goto exit;
+
+	dev_err(&adapter->pdev->dev, "RX Rings Dump\n");
+
+	/* Advanced Receive Descriptor (Read) Format
+	 *    63                                           1        0
+	 *    +-----------------------------------------------------+
+	 *  0 |       Packet Buffer Address [63:1]           |A0/NSE|
+	 *    +----------------------------------------------+------+
+	 *  8 |       Header Buffer Address [63:1]           |  DD  |
+	 *    +-----------------------------------------------------+
+	 *
+	 *
+	 * Advanced Receive Descriptor (Write-Back) Format
+	 *
+	 *   63       48 47    32 31  30      21 20 17 16   4 3     0
+	 *   +------------------------------------------------------+
+	 * 0 | Packet     IP     |SPH| HDR_LEN   | RSV|Packet|  RSS |
+	 *   | Checksum   Ident  |   |           |    | Type | Type |
+	 *   +------------------------------------------------------+
+	 * 8 | VLAN Tag | Length | Extended Error | Extended Status |
+	 *   +------------------------------------------------------+
+	 *   63       48 47    32 31            20 19               0
+	 */
+
+	for (n = 0; n < adapter->num_rx_queues; n++) {
+		rx_ring = &adapter->rx_ring[n];
+		printk(KERN_ERR "------------------------------------\n");
+		printk(KERN_ERR "RX QUEUE INDEX = %d\n", rx_ring->queue_index);
+		printk(KERN_ERR "------------------------------------\n");
+		printk(KERN_ERR "R  [desc]      [ PktBuf     A0] "
+			"[  HeadBuf   DD] [bi->dma       ] [bi->skb] "
+			"<-- Adv Rx Read format\n");
+		printk(KERN_ERR "RWB[desc]      [PcsmIpSHl PtRs] "
+			"[vl er S cks ln] ---------------- [bi->skb] "
+			"<-- Adv Rx Write-Back format\n");
+
+		for (i = 0; i < rx_ring->count; i++) {
+			buffer_info = &rx_ring->buffer_info[i];
+			rx_desc = E1000_RX_DESC_ADV(*rx_ring, i);
+			u0 = (struct my_u0 *)rx_desc;
+			staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
+			if (staterr & E1000_RXD_STAT_DD) {
+				/* Descriptor Done */
+				printk(KERN_ERR "RWB[0x%03X]     %016llX "
+					"%016llX ---------------- %p", i,
+					le64_to_cpu(u0->a),
+					le64_to_cpu(u0->b),
+					buffer_info->skb);
+			} else {
+				printk(KERN_ERR "R  [0x%03X]     %016llX "
+					"%016llX %016llX %p", i,
+					le64_to_cpu(u0->a),
+					le64_to_cpu(u0->b),
+					(u64)buffer_info->dma,
+					buffer_info->skb);
+
+				if (dump_flag & IGB_DUMP_BUFFERS) {
+					print_hex_dump(KERN_ERR, "",
+						DUMP_PREFIX_ADDRESS,
+						16, 1,
+						phys_to_virt(buffer_info->dma),
+						rx_ring->rx_buffer_len, true);
+					if (rx_ring->rx_buffer_len
+						< IGB_RXBUFFER_1024)
+						print_hex_dump(KERN_ERR, "",
+						  DUMP_PREFIX_ADDRESS,
+						  16, 1,
+						  phys_to_virt(
+						    buffer_info->page_dma +
+						    buffer_info->page_offset),
+						  PAGE_SIZE/2, true);
+				}
+			}
+
+			if (i == rx_ring->next_to_use)
+				printk(KERN_CONT " NTU\n");
+			else if (i == rx_ring->next_to_clean)
+				printk(KERN_CONT " NTC\n");
+			else
+				printk(KERN_CONT "\n");
+
+		}
+	}
+
+exit:
+	return;
+}
+
+
 /**
  * igb_read_clock - read raw cycle counter (to be used by time counter)
  */
@@ -3854,6 +4147,7 @@ static void igb_reset_task(struct work_s
 	struct igb_adapter *adapter;
 	adapter = container_of(work, struct igb_adapter, reset_task);

+	igb_dump(adapter);
 	igb_reinit_locked(adapter);
 }

Index: net-next-2.6/drivers/net/igb/e1000_regs.h
===================================================================
--- net-next-2.6.orig/drivers/net/igb/e1000_regs.h
+++ net-next-2.6/drivers/net/igb/e1000_regs.h
@@ -322,4 +322,25 @@

 /* DMA Coalescing registers */
 #define E1000_PCIEMISC          0x05BB8 /* PCIE misc config register */
+
+
+#define IGB_GET_REGOFS_FUNC(name)				\
+static inline u32 get_regofs_##name(int n)			\
+{								\
+	return E1000_##name(n);					\
+}								\
+
+IGB_GET_REGOFS_FUNC(RDLEN)
+IGB_GET_REGOFS_FUNC(RDH)
+IGB_GET_REGOFS_FUNC(RDT)
+IGB_GET_REGOFS_FUNC(RXDCTL)
+IGB_GET_REGOFS_FUNC(RDBAL)
+IGB_GET_REGOFS_FUNC(RDBAH)
+IGB_GET_REGOFS_FUNC(TDBAL)
+IGB_GET_REGOFS_FUNC(TDBAH)
+IGB_GET_REGOFS_FUNC(TDLEN)
+IGB_GET_REGOFS_FUNC(TDH)
+IGB_GET_REGOFS_FUNC(TDT)
+IGB_GET_REGOFS_FUNC(TXDCTL)
+
 #endif
Index: net-next-2.6/drivers/net/igb/e1000_hw.h
===================================================================
--- net-next-2.6.orig/drivers/net/igb/e1000_hw.h
+++ net-next-2.6/drivers/net/igb/e1000_hw.h
@@ -508,6 +508,13 @@ struct e1000_hw {
 	u8  revision_id;
 };

+struct igb_reg_info {
+	u32 reg;
+	char *name;
+	u32 (*get_regofs)(int);
+	void (*dump_reg)(struct e1000_hw *, u32, char *, u32 (*)(int));
+};
+
 #ifdef DEBUG
 extern char *igb_get_hw_dev_name(struct e1000_hw *hw);
 #define hw_dbg(format, arg...) \


