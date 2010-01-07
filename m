From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 2/3] igb: add registers etc. printout code just before resetting
 adapters
Date: Thu, 07 Jan 2010 20:01:58 +0900
Message-ID: <4B45BF26.3020600@jp.fujitsu.com>
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
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:46315 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab0AGLCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 06:02:15 -0500
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o07B2B5C006609
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Thu, 7 Jan 2010 20:02:11 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 78E5045DE4F
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 20:02:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F44445DE4E
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 20:02:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DCB8E38001
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 20:02:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C6F101DB803C
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 20:02:10 +0900 (JST)
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
 drivers/net/igb/igb_main.c |  360 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 360 insertions(+)

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
 static struct pci_device_id igb_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_FIBER), board_82575 },
@@ -189,6 +197,357 @@ MODULE_DESCRIPTION("Intel(R) Gigabit Eth
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);

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
+ * igb_dump - Print registers, tx-rings and rx-rings
+ */
+static void igb_dump(struct igb_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct e1000_hw *hw = &adapter->hw;
+	u32 reg;
+	char rname[16];
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
+
+	printk(KERN_ERR " Register Name   [value ]\n");
+	for (reg = 0; reg < 0x04000; reg += sizeof(u32)) {
+		switch (reg & 0xffffffff) {
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
+		case E1000_RDLEN(0):
+			sprintf(rname, "RDLEN[0-3]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 4; n++)
+				printk("%08x ", rd32(E1000_RDLEN(n)));
+			printk("\n");
+			continue;
+		case E1000_RDH(0):
+			sprintf(rname, "RDH[0-3]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 4; n++)
+				printk("%08x ", rd32(E1000_RDH(n)));
+			printk("\n");
+			continue;
+		case E1000_RDT(0):
+			sprintf(rname, "RDT[0-3]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 4; n++)
+				printk("%08x ", rd32(E1000_RDT(n)));
+			printk("\n");
+			continue;
+		case E1000_RXDCTL(0):
+			sprintf(rname, "RXDCTL[0-3]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 4; n++)
+				printk("%08x ", rd32(E1000_RXDCTL(n)));
+			printk("\n");
+			continue;
+		case E1000_RDBAL(0):
+			sprintf(rname, "RDBAL[0-3]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 4; n++)
+				printk("%08x ", rd32(E1000_RDBAL(n)));
+			printk("\n");
+			continue;
+		case E1000_RDBAH(0):
+			sprintf(rname, "RDBAH[0-3]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 4; n++)
+				printk("%08x ", rd32(E1000_RDBAH(n)));
+			printk("\n");
+			continue;
+
+		/* TX */
+		case E1000_TCTL:
+			sprintf(rname, "TCTL"); break;
+		case E1000_TDBAL(0):
+			sprintf(rname, "TDBAL[0-3]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 4; n++)
+				printk("%08x ", rd32(E1000_TDBAL(n)));
+			printk("\n");
+			continue;
+		case E1000_TDBAH(0):
+			sprintf(rname, "TDBAH[0-3]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 4; n++)
+				printk("%08x ", rd32(E1000_TDBAH(n)));
+			printk("\n");
+			continue;
+		case E1000_TDLEN(0):
+			sprintf(rname, "TDLEN[0-3]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 4; n++)
+				printk("%08x ", rd32(E1000_TDLEN(n)));
+			printk("\n");
+			continue;
+		case E1000_TDH(0):
+			sprintf(rname, "TDH[0-3]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 4; n++)
+				printk("%08x ", rd32(E1000_TDH(n)));
+			printk("\n");
+			continue;
+		case E1000_TDT(0):
+			sprintf(rname, "TDT[0-3]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 4; n++)
+				printk("%08x ", rd32(E1000_TDT(n)));
+			printk("\n");
+			continue;
+		case E1000_TXDCTL(0):
+			sprintf(rname, "TXDCTL[0-3]");
+			printk(KERN_ERR "%-15s ", rname);
+			for (n = 0; n < 4; n++)
+				printk("%08x ", rd32(E1000_TXDCTL(n)));
+			printk("\n");
+			continue;
+		case E1000_TDFH:
+			sprintf(rname, "TDFH"); break;
+		case E1000_TDFT:
+			sprintf(rname, "TDFT"); break;
+		case E1000_TDFHS:
+			sprintf(rname, "TDFHS"); break;
+		case E1000_TDFPC:
+			sprintf(rname, "TDFPC"); break;
+
+		default:
+			continue;
+		}
+
+		printk(KERN_ERR "%-15s %08x\n", rname,
+			rd32((reg & 0xffffffff)));
+
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
+				printk(" NTC/U\n");
+			else if (i == tx_ring->next_to_use)
+				printk(" NTU\n");
+			else if (i == tx_ring->next_to_clean)
+				printk(" NTC\n");
+			else
+				printk("\n");
+
+			if ((dump_flag & IGB_DUMP_BUFFERS) &&
+				buffer_info->dma != 0)
+				hexdump(buffer_info->dma, buffer_info->length);
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
+					hexdump(buffer_info->dma,
+						rx_ring->rx_buffer_len);
+					if (rx_ring->rx_buffer_len
+						< IGB_RXBUFFER_1024)
+						hexdump(buffer_info->page_dma +
+						 buffer_info->page_offset,
+						 PAGE_SIZE/2);
+				}
+			}
+
+			if (i == rx_ring->next_to_use)
+				printk(" NTU\n");
+			else if (i == rx_ring->next_to_clean)
+				printk(" NTC\n");
+			else
+				printk("\n");
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
@@ -3859,6 +4218,7 @@ static void igb_reset_task(struct work_s
 	struct igb_adapter *adapter;
 	adapter = container_of(work, struct igb_adapter, reset_task);

+	igb_dump(adapter);
 	igb_reinit_locked(adapter);
 }



