From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2 1/3] e1000e: add registers etc. printout code just before
 resetting adapters
Date: Fri, 22 Jan 2010 14:48:35 +0900
Message-ID: <4B593C33.5020208@jp.fujitsu.com>
References: <4B593B74.2020601@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	chavey@google.com
To: netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:34287 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab0AVFst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 00:48:49 -0500
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0M5mlaR006599
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Fri, 22 Jan 2010 14:48:47 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F51B45DE55
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 14:48:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0578F45DE52
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 14:48:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BDB371DB8049
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 14:48:46 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E5A71DB803E
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 14:48:46 +0900 (JST)
In-Reply-To: <4B593B74.2020601@jp.fujitsu.com>
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
 drivers/net/e1000e/hw.h     |   27 +++
 drivers/net/e1000e/netdev.c |  341 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 368 insertions(+)
Index: net-next-2.6/drivers/net/e1000e/netdev.c
===================================================================
--- net-next-2.6.orig/drivers/net/e1000e/netdev.c
+++ net-next-2.6/drivers/net/e1000e/netdev.c
@@ -52,6 +52,14 @@
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;

+static unsigned int dump_flag = 1;
+module_param(dump_flag, uint, 0644);
+MODULE_PARM_DESC(dump_flag, "Dump Flag");
+#define E1000_DUMP_REGS		(1 << 0)
+#define E1000_DUMP_TX_RINGS	(1 << 1)
+#define E1000_DUMP_RX_RINGS	(1 << 2)
+#define E1000_DUMP_BUFFERS	(1 << 3)
+
 static const struct e1000_info *e1000_info_tbl[] = {
 	[board_82571]		= &e1000_82571_info,
 	[board_82572]		= &e1000_82572_info,
@@ -65,6 +73,338 @@ static const struct e1000_info *e1000_in
 	[board_pchlan]		= &e1000_pch_info,
 };

+/*
+ * e1000_regdump - register printout routine
+ */
+static void e1000_regdump(struct e1000_hw *hw, u32 reg,
+			  char *name, u32 (*get_regofs)(int))
+{
+	printk(KERN_ERR "%-15s %08x\n", name, __er32(hw, reg));
+}
+
+/*
+ * e1000_regdump_n - register printout routine
+ */
+static void e1000_regdump_n(struct e1000_hw *hw, u32 reg,
+			    char *name, u32 (*get_regofs)(int))
+{
+	int n = 0;
+	char rname[16];
+
+	if (!get_regofs)
+		return;
+
+	snprintf(rname, 16, "%s%s", name, "[0-1]");
+	printk(KERN_ERR "%-15s ", rname);
+	for (n = 0; n < 2; n++)
+		printk("%08x ", __er32(hw, get_regofs(n)));
+	printk("\n");
+}
+
+static const struct e1000_reg_info e1000_reg_info_tbl[] = {
+
+	/* General Registers */
+	{E1000_CTRL, "CTRL", NULL, e1000_regdump},
+	{E1000_STATUS, "STATUS", NULL, e1000_regdump},
+	{E1000_CTRL_EXT, "CTRL_EXT", NULL, e1000_regdump},
+
+	/* Interrupt Registers */
+	{E1000_ICR, "ICR", NULL, e1000_regdump},
+
+	/* RX Registers */
+	{E1000_RCTL, "RCTL", NULL, e1000_regdump},
+	{E1000_RDLEN, "RDLEN", NULL, e1000_regdump},
+	{E1000_RDH, "RDH", NULL, e1000_regdump},
+	{E1000_RDT, "RDT", NULL, e1000_regdump},
+	{E1000_RDTR, "RDTR", NULL, e1000_regdump},
+	{E1000_RXDCTL(0), "RXDCTL", get_regofs_RXDCTL, e1000_regdump_n},
+	{E1000_ERT, "ERT", NULL, e1000_regdump},
+	{E1000_RDBAL, "RDBAL", NULL, e1000_regdump},
+	{E1000_RDBAH, "RDBAH", NULL, e1000_regdump},
+	{E1000_RDFH, "RDFH", NULL, e1000_regdump},
+	{E1000_RDFT, "RDFT", NULL, e1000_regdump},
+	{E1000_RDFHS, "RDFHS", NULL, e1000_regdump},
+	{E1000_RDFTS, "RDFTS", NULL, e1000_regdump},
+	{E1000_RDFPC, "RDFPC", NULL, e1000_regdump},
+
+	/* TX Registers */
+	{E1000_TCTL, "TCTL", NULL, e1000_regdump},
+	{E1000_TDBAL, "TDBAL", NULL, e1000_regdump},
+	{E1000_TDBAH, "TDBAH", NULL, e1000_regdump},
+	{E1000_TDLEN, "TDLEN", NULL, e1000_regdump},
+	{E1000_TDH, "TDH", NULL, e1000_regdump},
+	{E1000_TDT, "TDT", NULL, e1000_regdump},
+	{E1000_TIDV, "TIDV", NULL, e1000_regdump},
+	{E1000_TXDCTL(0), "TXDCTL", get_regofs_TXDCTL, e1000_regdump_n},
+	{E1000_TADV, "TADV", NULL, e1000_regdump},
+	{E1000_TARC(0), "TARC", get_regofs_TARC, e1000_regdump_n},
+	{E1000_TDFH, "TDFH", NULL, e1000_regdump},
+	{E1000_TDFT, "TDFT", NULL, e1000_regdump},
+	{E1000_TDFHS, "TDFHS", NULL, e1000_regdump},
+	{E1000_TDFTS, "TDFTS", NULL, e1000_regdump},
+	{E1000_TDFPC, "TDFPC", NULL, e1000_regdump},
+
+	/* List Terminator */
+	{}
+};
+
+/*
+ * e1000e_dump - Print registers, tx-ring and rx-ring
+ */
+static void e1000e_dump(struct e1000_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct e1000_hw *hw = &adapter->hw;
+	struct e1000_reg_info *reginfo;
+	struct e1000_ring *tx_ring = adapter->tx_ring;
+	struct e1000_tx_desc *tx_desc;
+	struct my_u0 { u64 a; u64 b; } *u0;
+	struct e1000_buffer *buffer_info;
+	struct e1000_ring *rx_ring = adapter->rx_ring;
+	union e1000_rx_desc_packet_split *rx_desc_ps;
+	struct e1000_rx_desc *rx_desc;
+	struct my_u1 { u64 a; u64 b; u64 c; u64 d; } *u1;
+	u32 staterr;
+	int i = 0;
+
+	/* Print netdevice Info */
+	if (netdev) {
+		dev_err(&adapter->pdev->dev, "Net device Info\n");
+		printk(KERN_ERR "Device Name     state            "
+			"trans_start      last_rx\n");
+		printk(KERN_ERR "%-15s %016lX %016lX %016lX\n",
+			netdev->name,
+			netdev->state,
+			netdev->trans_start,
+			netdev->last_rx);
+	}
+
+	/* Print Registers */
+	if ((dump_flag & E1000_DUMP_REGS) == 0)
+		goto tx_ring_summary;
+
+	dev_err(&adapter->pdev->dev, "Register Dump\n");
+	printk(KERN_ERR " Register Name   Value\n");
+	for (reginfo = (struct e1000_reg_info *)e1000_reg_info_tbl;
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
+	buffer_info = &tx_ring->buffer_info[tx_ring->next_to_clean];
+	printk(KERN_ERR " %5d %5X %5X %016llX %04X %3X %016llX\n",
+		0, tx_ring->next_to_use, tx_ring->next_to_clean,
+		(u64)buffer_info->dma,
+		buffer_info->length,
+		buffer_info->next_to_watch,
+		(u64)buffer_info->time_stamp);
+
+	/* Print TX Rings */
+	if ((dump_flag & E1000_DUMP_TX_RINGS) == 0)
+		goto rx_ring_summary;
+
+	dev_err(&adapter->pdev->dev, "TX Rings Dump\n");
+
+	/* Transmit Descriptor Formats - DEXT[29] is 0 (Legacy) or 1 (Extended)
+	 *
+	 * Legacy Transmit Descriptor
+	 *   +--------------------------------------------------------------+
+	 * 0 |         Buffer Address [63:0] (Reserved on Write Back)       |
+	 *   +--------------------------------------------------------------+
+	 * 8 | Special  |    CSS     | Status |  CMD    |  CSO   |  Length  |
+	 *   +--------------------------------------------------------------+
+	 *   63       48 47        36 35    32 31     24 23    16 15        0
+	 *
+	 * Extended Context Descriptor (DTYP=0x0) for TSO or checksum offload
+	 *   63      48 47    40 39       32 31             16 15    8 7      0
+	 *   +----------------------------------------------------------------+
+	 * 0 |  TUCSE  | TUCS0  |   TUCSS   |     IPCSE       | IPCS0 | IPCSS |
+	 *   +----------------------------------------------------------------+
+	 * 8 |   MSS   | HDRLEN | RSV | STA | TUCMD | DTYP |      PAYLEN      |
+	 *   +----------------------------------------------------------------+
+	 *   63      48 47    40 39 36 35 32 31   24 23  20 19                0
+	 *
+	 * Extended Data Descriptor (DTYP=0x1)
+	 *   +----------------------------------------------------------------+
+	 * 0 |                     Buffer Address [63:0]                      |
+	 *   +----------------------------------------------------------------+
+	 * 8 | VLAN tag |  POPTS  | Rsvd | Status | Command | DTYP |  DTALEN  |
+	 *   +----------------------------------------------------------------+
+	 *   63       48 47     40 39  36 35    32 31     24 23  20 19        0
+	 */
+	printk(KERN_ERR "Tl[desc]     [address 63:0  ] [SpeCssSCmCsLen]"
+		" [bi->dma       ] leng  ntw timestamp        bi->skb "
+		"<-- Legacy format\n");
+	printk(KERN_ERR "Tc[desc]     [Ce CoCsIpceCoS] [MssHlRSCm0Plen]"
+		" [bi->dma       ] leng  ntw timestamp        bi->skb "
+		"<-- Ext Context format\n");
+	printk(KERN_ERR "Td[desc]     [address 63:0  ] [VlaPoRSCm1Dlen]"
+		" [bi->dma       ] leng  ntw timestamp        bi->skb "
+		"<-- Ext Data format\n");
+	for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
+		tx_desc = E1000_TX_DESC(*tx_ring, i);
+		buffer_info = &tx_ring->buffer_info[i];
+		u0 = (struct my_u0 *)tx_desc;
+		printk(KERN_ERR "T%c[0x%03X]    %016llX %016llX %016llX "
+			"%04X  %3X %016llX %p",
+		       (!(le64_to_cpu(u0->b) & (1<<29)) ? 'l' :
+			((le64_to_cpu(u0->b) & (1<<20)) ? 'd' : 'c')), i,
+		       le64_to_cpu(u0->a), le64_to_cpu(u0->b),
+		       (u64)buffer_info->dma, buffer_info->length,
+		       buffer_info->next_to_watch, (u64)buffer_info->time_stamp,
+		       buffer_info->skb);
+		if (i == tx_ring->next_to_use && i == tx_ring->next_to_clean)
+			printk(" NTC/U\n");
+		else if (i == tx_ring->next_to_use)
+			printk(" NTU\n");
+		else if (i == tx_ring->next_to_clean)
+			printk(" NTC\n");
+		else
+			printk("\n");
+
+		if ((dump_flag & E1000_DUMP_BUFFERS) && buffer_info->dma != 0)
+			print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS,
+					16, 1, phys_to_virt(buffer_info->dma),
+					buffer_info->length, true);
+	}
+
+	/* Print RX Rings Summary */
+rx_ring_summary:
+	dev_err(&adapter->pdev->dev, "RX Rings Summary\n");
+	printk(KERN_ERR "Queue [NTU] [NTC]\n");
+	printk(KERN_ERR " %5d %5X %5X\n", 0,
+		rx_ring->next_to_use, rx_ring->next_to_clean);
+
+	/* Print RX Rings */
+	if ((dump_flag & E1000_DUMP_RX_RINGS) == 0)
+		goto exit;
+
+	dev_err(&adapter->pdev->dev, "RX Rings Dump\n");
+	switch (adapter->rx_ps_pages) {
+	case 1:
+	case 2:
+	case 3:
+		/* [Extended] Packet Split Receive Descriptor Format
+		 *
+		 *    +-----------------------------------------------------+
+		 *  0 |                Buffer Address 0 [63:0]              |
+		 *    +-----------------------------------------------------+
+		 *  8 |                Buffer Address 1 [63:0]              |
+		 *    +-----------------------------------------------------+
+		 * 16 |                Buffer Address 2 [63:0]              |
+		 *    +-----------------------------------------------------+
+		 * 24 |                Buffer Address 3 [63:0]              |
+		 *    +-----------------------------------------------------+
+		 */
+		printk(KERN_ERR "R  [desc]      [buffer 0 63:0 ] "
+			"[buffer 1 63:0 ] "
+		       "[buffer 2 63:0 ] [buffer 3 63:0 ] [bi->dma       ] "
+		       "[bi->skb] <-- Ext Pkt Split format\n");
+		/* [Extended] Receive Descriptor (Write-Back) Format
+		 *
+		 *   63       48 47    32 31     13 12    8 7    4 3        0
+		 *   +------------------------------------------------------+
+		 * 0 | Packet   | IP     |  Rsvd   | MRQ   | Rsvd | MRQ RSS |
+		 *   | Checksum | Ident  |         | Queue |      |  Type   |
+		 *   +------------------------------------------------------+
+		 * 8 | VLAN Tag | Length | Extended Error | Extended Status |
+		 *   +------------------------------------------------------+
+		 *   63       48 47    32 31            20 19               0
+		 */
+		printk(KERN_ERR "RWB[desc]      [ck ipid mrqhsh] "
+			"[vl   l0 ee  es] "
+		       "[ l3  l2  l1 hs] [reserved      ] ---------------- "
+		       "[bi->skb] <-- Ext Rx Write-Back format\n");
+		for (i = 0; i < rx_ring->count; i++) {
+			buffer_info = &rx_ring->buffer_info[i];
+			rx_desc_ps = E1000_RX_DESC_PS(*rx_ring, i);
+			u1 = (struct my_u1 *)rx_desc_ps;
+			staterr =
+				le32_to_cpu(rx_desc_ps->wb.middle.status_error);
+			if (staterr & E1000_RXD_STAT_DD) {
+				/* Descriptor Done */
+				printk(KERN_ERR "RWB[0x%03X]     %016llX "
+					"%016llX %016llX %016llX "
+					"---------------- %p", i,
+					le64_to_cpu(u1->a),
+					le64_to_cpu(u1->b),
+					le64_to_cpu(u1->c),
+					le64_to_cpu(u1->d),
+					buffer_info->skb);
+			} else {
+				printk(KERN_ERR "R  [0x%03X]     %016llX "
+					"%016llX %016llX %016llX %016llX %p", i,
+					le64_to_cpu(u1->a),
+					le64_to_cpu(u1->b),
+					le64_to_cpu(u1->c),
+					le64_to_cpu(u1->d),
+					(u64)buffer_info->dma,
+					buffer_info->skb);
+
+				if (dump_flag & E1000_DUMP_BUFFERS)
+					print_hex_dump(KERN_ERR, "",
+						DUMP_PREFIX_ADDRESS, 16, 1,
+						phys_to_virt(buffer_info->dma),
+						adapter->rx_ps_bsize0, true);
+			}
+
+			if (i == rx_ring->next_to_use)
+				printk(" NTU\n");
+			else if (i == rx_ring->next_to_clean)
+				printk(" NTC\n");
+			else
+				printk("\n");
+		}
+		break;
+	default:
+	case 0:
+		/* Legacy Receive Descriptor Format
+		 *
+		 * +-----------------------------------------------------+
+		 * |                Buffer Address [63:0]                |
+		 * +-----------------------------------------------------+
+		 * | VLAN Tag | Errors | Status 0 | Packet csum | Length |
+		 * +-----------------------------------------------------+
+		 * 63       48 47    40 39      32 31         16 15      0
+		 */
+		printk(KERN_ERR "Rl[desc]     [address 63:0  ] "
+			"[vl er S cks ln] [bi->dma       ] [bi->skb] "
+			"<-- Legacy format\n");
+		for (i = 0; rx_ring->desc && (i < rx_ring->count); i++) {
+			rx_desc = E1000_RX_DESC(*rx_ring, i);
+			buffer_info = &rx_ring->buffer_info[i];
+			u0 = (struct my_u0 *)rx_desc;
+			printk(KERN_ERR "Rl[0x%03X]    %016llX %016llX "
+				"%016llX %p",
+				i, le64_to_cpu(u0->a), le64_to_cpu(u0->b),
+				(u64)buffer_info->dma, buffer_info->skb);
+			if (i == rx_ring->next_to_use)
+				printk(" NTU\n");
+			else if (i == rx_ring->next_to_clean)
+				printk(" NTC\n");
+			else
+				printk("\n");
+
+			if (dump_flag & E1000_DUMP_BUFFERS)
+				print_hex_dump(KERN_ERR, "",
+					DUMP_PREFIX_ADDRESS,
+					16, 1, phys_to_virt(buffer_info->dma),
+					adapter->rx_buffer_len, true);
+		}
+	}
+
+exit:
+	return;
+}
+
 /**
  * e1000_desc_unused - calculate if we have unused descriptors
  **/
@@ -4247,6 +4587,7 @@ static void e1000_reset_task(struct work
 	struct e1000_adapter *adapter;
 	adapter = container_of(work, struct e1000_adapter, reset_task);

+	e1000e_dump(adapter);
 	e1000e_reinit_locked(adapter);
 }

Index: net-next-2.6/drivers/net/e1000e/hw.h
===================================================================
--- net-next-2.6.orig/drivers/net/e1000e/hw.h
+++ net-next-2.6/drivers/net/e1000e/hw.h
@@ -92,6 +92,11 @@ enum e1e_registers {
 	E1000_FCRTL    = 0x02160, /* Flow Control Receive Threshold Low - RW */
 	E1000_FCRTH    = 0x02168, /* Flow Control Receive Threshold High - RW */
 	E1000_PSRCTL   = 0x02170, /* Packet Split Receive Control - RW */
+	E1000_RDFH     = 0x02410, /* Rx Data FIFO Head - RW */
+	E1000_RDFT     = 0x02418, /* Rx Data FIFO Tail - RW */
+	E1000_RDFHS    = 0x02420, /* Rx Data FIFO Head Saved - RW */
+	E1000_RDFTS    = 0x02428, /* Rx Data FIFO Tail Saved - RW */
+	E1000_RDFPC    = 0x02430, /* Rx Data FIFO Packet Count - RW */
 	E1000_RDBAL    = 0x02800, /* Rx Descriptor Base Address Low - RW */
 	E1000_RDBAH    = 0x02804, /* Rx Descriptor Base Address High - RW */
 	E1000_RDLEN    = 0x02808, /* Rx Descriptor Length - RW */
@@ -101,6 +106,11 @@ enum e1e_registers {
 	E1000_RXDCTL_BASE = 0x02828, /* Rx Descriptor Control - RW */
 #define E1000_RXDCTL(_n)   (E1000_RXDCTL_BASE + (_n << 8))
 	E1000_RADV     = 0x0282C, /* RX Interrupt Absolute Delay Timer - RW */
+	E1000_TDFH     = 0x03410, /* Tx Data FIFO Head - RW */
+	E1000_TDFT     = 0x03418, /* Tx Data FIFO Tail - RW */
+	E1000_TDFHS    = 0x03420, /* Tx Data FIFO Head Saved - RW */
+	E1000_TDFTS    = 0x03428, /* Tx Data FIFO Tail Saved - RW */
+	E1000_TDFPC    = 0x03430, /* Tx Data FIFO Packet Count - RW */

 /* Convenience macros
  *
@@ -219,6 +229,23 @@ enum e1e_registers {
 	E1000_HICR      = 0x08F00, /* Host Interface Control */
 };

+struct e1000_reg_info {
+	u32 reg;
+	char *name;
+	u32 (*get_regofs)(int);
+	void (*dump_reg)(struct e1000_hw *, u32, char *, u32 (*)(int));
+};
+
+#define E1000_GET_REGOFS_FUNC(name)				\
+static inline u32 get_regofs_##name(int n)			\
+{								\
+	return E1000_##name(n);						\
+}								\
+
+E1000_GET_REGOFS_FUNC(RXDCTL)
+E1000_GET_REGOFS_FUNC(TXDCTL)
+E1000_GET_REGOFS_FUNC(TARC)
+
 #define E1000_MAX_PHY_ADDR		4

 /* IGP01E1000 Specific Registers */

