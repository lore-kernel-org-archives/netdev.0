From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 1/3] e1000e: add registers etc. printout code just before
 resetting adapters
Date: Thu, 07 Jan 2010 20:01:10 +0900
Message-ID: <4B45BEF6.6000400@jp.fujitsu.com>
References: <4B45BBA5.8010407@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
To: netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:60640 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826Ab0AGLBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 06:01:25 -0500
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o07B1Nx2006558
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Thu, 7 Jan 2010 20:01:23 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A61D845DE4F
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 20:01:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 83C2A45DE4D
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 20:01:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DF501DB803B
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 20:01:23 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A03F1DB8037
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 20:01:23 +0900 (JST)
In-Reply-To: <4B45BBA5.8010407@jp.fujitsu.com>
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
 drivers/net/e1000e/netdev.c |  386 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 386 insertions(+)
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
@@ -65,6 +73,383 @@ static const struct e1000_info *e1000_in
 	[board_pchlan]		= &e1000_pch_info,
 };

+static void hexdump(dma_addr_t dma, u16 len)
+{
+	uint16_t offset, i;
+	char str[80], byte[4];
+	void *va = phys_to_virt((unsigned long)dma);
+
+	printk(KERN_ERR "buffer at %016llX (%d)\n", (u64)dma, len);
+	for (offset = 0; offset < len; offset += 16) {
+		sprintf(str, "%04x: ", offset);
+		for (i = 0; i < 16; i++) {
+			if ((offset + i) < len)
+				sprintf(byte, "%02x ",
+				((unsigned char *)va)[offset + i]);
+			else
+				strcpy(byte, "   ");
+			strcat(str, byte);
+		}
+		printk(KERN_ERR "%s\n", str);
+	}
+}
+
+/*
+ * e1000e_dump - Print registers, tx-ring and rx-ring
+ */
+static void e1000e_dump(struct e1000_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct e1000_hw *hw = &adapter->hw;
+	u32 reg;
+	char rname[16];
+	int n = 0;
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
+
+#define E1000_RDFH	0x02410
+#define E1000_RDFT	0x02418
+#define E1000_RDFHS	0x02420
+#define E1000_RDFTS	0x02428
+#define E1000_RDFPC	0x02430
+
+#define E1000_TDFH	0x03410
+#define E1000_TDFT	0x03418
+#define E1000_TDFHS	0x03420
+#define E1000_TDFTS	0x03428
+#define E1000_TDFPC	0x03430
+
+	printk(KERN_ERR " Register Name   [value ]\n");
+	for (reg = 0; reg < 0x04000; reg += sizeof(u32)) {
+		switch (reg & 0xffffffff) {
+
+		/* General Registers */
+		case E1000_CTRL:
+			sprintf(rname, "CTRL"); break;
+		case E1000_STATUS:
+			sprintf(rname, "STATUS"); break;
+		case E1000_CTRL_EXT:
+			sprintf(rname, "CTRL_EXT"); break;
+
+		/* Interrupt Registers*/
+		case E1000_ICR:
+			sprintf(rname, "ICR"); break;
+
+		/* RX */
+		case E1000_RCTL:
+			sprintf(rname, "RCTL"); break;
+		case E1000_RDLEN:
+			sprintf(rname, "RDLEN"); break;
+		case E1000_RDH:
+			sprintf(rname, "RDH"); break;
+		case E1000_RDT:
+			sprintf(rname, "RDT"); break;
+		case E1000_RDTR:
+			sprintf(rname, "RDTR"); break;
+		case E1000_RXDCTL(0):
+			sprintf(rname, "RXDCTL[0]"); break;
+		case E1000_ERT:
+			sprintf(rname, "ERT"); break;
+		case E1000_RDBAL:
+			sprintf(rname, "RDBAL"); break;
+		case E1000_RDBAH:
+			sprintf(rname, "RDBAH"); break;
+		case E1000_RDFH:
+			sprintf(rname, "RDFH"); break;
+		case E1000_RDFT:
+			sprintf(rname, "RDFT"); break;
+		case E1000_RDFHS:
+			sprintf(rname, "RDFHS"); break;
+		case E1000_RDFTS:
+			sprintf(rname, "RDFTS"); break;
+		case E1000_RDFPC:
+			sprintf(rname, "RDFPC"); break;
+
+		/* TX */
+		case E1000_TCTL:
+			sprintf(rname, "TCTL"); break;
+		case E1000_TDBAL:
+			sprintf(rname, "TDBAL"); break;
+		case E1000_TDBAH:
+			sprintf(rname, "TDBAH"); break;
+		case E1000_TDLEN:
+			sprintf(rname, "TDLEN"); break;
+		case E1000_TDH:
+			sprintf(rname, "TDH"); break;
+		case E1000_TDT:
+			sprintf(rname, "TDT"); break;
+		case E1000_TIDV:
+			sprintf(rname, "TIDV"); break;
+		case E1000_TXDCTL(0):
+			sprintf(rname, "TXDCTL[0-1]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 2; n++)
+				printk("%08x ", readl(hw->hw_addr +
+							(reg & 0xffffffff)));
+			printk("\n");
+			continue;
+		case E1000_TADV:
+			sprintf(rname, "TADV"); break;
+		case E1000_TARC(0):
+			sprintf(rname, "TARC[0-1]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 2; n++)
+				printk("%08x ", readl(hw->hw_addr +
+							(reg & 0xffffffff)));
+			printk("\n");
+			continue;
+		case E1000_TDFH:
+			sprintf(rname, "TDFH"); break;
+		case E1000_TDFT:
+			sprintf(rname, "TDFT"); break;
+		case E1000_TDFHS:
+			sprintf(rname, "TDFHS"); break;
+		case E1000_TDFTS:
+			sprintf(rname, "TDFTS"); break;
+		case E1000_TDFPC:
+			sprintf(rname, "TDFPC"); break;
+
+		default:
+			continue;
+		}
+		printk(KERN_ERR "%-15s %08x\n", rname,
+			readl(hw->hw_addr + (reg & 0xffffffff)));
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
+			hexdump(buffer_info->dma, buffer_info->length);
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
+					hexdump(buffer_info->dma,
+						adapter->rx_ps_bsize0);
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
+				hexdump(buffer_info->dma,
+					adapter->rx_buffer_len);
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
@@ -4257,6 +4642,7 @@ static void e1000_reset_task(struct work
 	struct e1000_adapter *adapter;
 	adapter = container_of(work, struct e1000_adapter, reset_task);

+	e1000e_dump(adapter);
 	e1000e_reinit_locked(adapter);
 }



