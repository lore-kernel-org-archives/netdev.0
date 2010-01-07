From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 3/3] ixgbe: add registers etc. printout code just before resetting
 adapters
Date: Thu, 07 Jan 2010 20:02:54 +0900
Message-ID: <4B45BF5E.9060605@jp.fujitsu.com>
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
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:60715 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040Ab0AGLDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 06:03:10 -0500
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o07B38TL007255
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Thu, 7 Jan 2010 20:03:08 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1402745DE4F
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 20:03:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E77BC45DE51
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 20:03:07 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CB45FE18002
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 20:03:07 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 809581DB805A
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 20:03:07 +0900 (JST)
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
 drivers/net/ixgbe/ixgbe_main.c |  436 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 436 insertions(+)

Index: net-next-2.6/drivers/net/ixgbe/ixgbe_main.c
===================================================================
--- net-next-2.6.orig/drivers/net/ixgbe/ixgbe_main.c
+++ net-next-2.6/drivers/net/ixgbe/ixgbe_main.c
@@ -59,6 +59,15 @@ static const struct ixgbe_info *ixgbe_in
 	[board_82599] = &ixgbe_82599_info,
 };

+
+static unsigned int dump_flag = 1;
+module_param(dump_flag, uint, 0644);
+MODULE_PARM_DESC(dump_flag, "Dump Flag");
+#define IXGBE_DUMP_REGS		(1 << 0)
+#define IXGBE_DUMP_TX_RINGS	(1 << 1)
+#define IXGBE_DUMP_RX_RINGS	(1 << 2)
+#define IXGBE_DUMP_BUFFERS	(1 << 3)
+
 /* ixgbe_pci_tbl - PCI Device ID Table
  *
  * Wildcard entries (PCI_ANY_ID) should come last
@@ -131,6 +140,432 @@ MODULE_VERSION(DRV_VERSION);

 #define DEFAULT_DEBUG_LEVEL_SHIFT 3

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
+					((unsigned char *)va)[offset + i]);
+			else
+				strcpy(byte, "   ");
+			strcat(str, byte);
+		}
+		printk(KERN_ERR "%s\n", str);
+	}
+}
+
+/*
+ * ixgbe_dump - Print registers, tx-rings and rx-rings
+ */
+static void ixgbe_dump(struct ixgbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	u32 reg;
+	char rname[32];
+	int n = 0;
+	int j = 0;
+	struct ixgbe_ring *tx_ring;
+	struct ixgbe_tx_buffer *tx_buffer_info;
+	union ixgbe_adv_tx_desc *tx_desc;
+	struct my_u0 { u64 a; u64 b; } *u0;
+	struct ixgbe_ring *rx_ring;
+	union ixgbe_adv_rx_desc *rx_desc;
+	struct ixgbe_rx_buffer *rx_buffer_info;
+	u32 staterr;
+	int i = 0;
+
+	/* Print netdevice Info */
+	dev_err(&adapter->pdev->dev, "Net device Info\n");
+	if (netdev) {
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
+	if ((dump_flag & IXGBE_DUMP_REGS) == 0)
+		goto tx_ring_summary;
+
+	dev_err(&adapter->pdev->dev, "Register Dump\n");
+
+	printk(KERN_ERR " Register Name   [value ]\n");
+	for (reg = 0; reg < 0x07000; reg += sizeof(u32)) {
+		switch (reg & 0xffffffff) {
+		/* General Registers */
+		case IXGBE_CTRL:
+			sprintf(rname, "CTRL"); break;
+		case IXGBE_STATUS:
+			sprintf(rname, "STATUS"); break;
+		case IXGBE_CTRL_EXT:
+			sprintf(rname, "CTRL_EXT"); break;
+
+		/* Interrupt Registers*/
+		case IXGBE_EICR:
+			sprintf(rname, "EICR"); break;
+
+		/* RX */
+		case IXGBE_SRRCTL(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "SRRCTL[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_SRRCTL(i*8+j)));
+				printk("\n");
+			}
+			continue;
+		case IXGBE_DCA_RXCTRL(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "DRXCTRL[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_DCA_RXCTRL(i*8+j)));
+				printk("\n");
+			}
+			continue;
+		case IXGBE_RDLEN(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "RDLEN[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_RDLEN(i*8+j)));
+				printk("\n");
+			}
+			continue;
+		case IXGBE_RDH(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "RDH[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_RDH(i*8+j)));
+				printk("\n");
+			}
+			continue;
+		case IXGBE_RDT(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "RDT[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_RDT(i*8+j)));
+				printk("\n");
+			}
+			continue;
+		case IXGBE_RXDCTL(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "RXDCTL[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_RXDCTL(i*8+j)));
+				printk("\n");
+			}
+			continue;
+		case IXGBE_RDBAL(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "RDBAL[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_RDBAL(i*8+j)));
+				printk("\n");
+			}
+			continue;
+		case IXGBE_RDBAH(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "RDBAH[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_RDBAH(i*8+j)));
+				printk("\n");
+			}
+			continue;
+
+		/* TX */
+		case IXGBE_TDBAL(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "TDBAL[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_TDBAL(i*8+j)));
+				printk("\n");
+			}
+			continue;
+		case IXGBE_TDBAH(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "TDBAH[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_TDBAH(i*8+j)));
+				printk("\n");
+			}
+			continue;
+		case IXGBE_TDLEN(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "TDLEN[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_TDLEN(i*8+j)));
+				printk("\n");
+			}
+			continue;
+		case IXGBE_TDH(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "TDH[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_TDH(i*8+j)));
+				printk("\n");
+			}
+			continue;
+		case IXGBE_TDT(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "TDT[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_TDT(i*8+j)));
+				printk("\n");
+			}
+			continue;
+		case IXGBE_TXDCTL(0):
+			for (i = 0; i < 8; i++) {
+				sprintf(rname, "TXDCTL[%d-%d]",
+					i*8, i*8+7);
+				printk(KERN_ERR "%-15s ", rname);
+				for (j = 0; j < 8; j++)
+					printk("%08x ",
+						IXGBE_READ_REG(hw,
+						  IXGBE_TXDCTL(i*8+j)));
+				printk("\n");
+			}
+			continue;
+
+		default:
+			continue;
+		}
+
+		printk(KERN_ERR "%-15s %08x\n", rname,
+			IXGBE_READ_REG(hw, (reg & 0xffffffff)));
+	}
+
+	/* Print TX Ring Summary */
+tx_ring_summary:
+	if (!netdev || !netif_running(netdev))
+		goto exit;
+
+	dev_err(&adapter->pdev->dev, "TX Rings Summary\n");
+	printk(KERN_ERR "Queue [NTU] [NTC] [bi(ntc)->dma  ] "
+		"leng ntw timestamp\n");
+	for (n = 0; n < adapter->num_tx_queues; n++) {
+		tx_ring = &adapter->tx_ring[n];
+		tx_buffer_info =
+			&tx_ring->tx_buffer_info[tx_ring->next_to_clean];
+		printk(KERN_ERR " %5d %5X %5X %016llX %04X %3X %016llX\n",
+			   n, tx_ring->next_to_use, tx_ring->next_to_clean,
+			   (u64)tx_buffer_info->dma,
+			   tx_buffer_info->length,
+			   tx_buffer_info->next_to_watch,
+			   (u64)tx_buffer_info->time_stamp);
+	}
+
+	/* Print TX Rings */
+	if ((dump_flag & IXGBE_DUMP_TX_RINGS) == 0)
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
+	 * 8 |  PAYLEN  | PORTS  | IDX | STA | DCMD  |DTYP |  RSV |  DTALEN |
+	 *   +--------------------------------------------------------------+
+	 *   63       46 45    40 39 36 35 32 31   24 23 20 19              0
+	 */
+
+	for (n = 0; n < adapter->num_tx_queues; n++) {
+		tx_ring = &adapter->tx_ring[n];
+		printk(KERN_ERR "------------------------------------\n");
+		printk(KERN_ERR "TX QUEUE INDEX = %d\n", tx_ring->queue_index);
+		printk(KERN_ERR "------------------------------------\n");
+		printk(KERN_ERR "T [desc]     [address 63:0  ] "
+			"[PlPOIdStDDt Ln] [bi->dma       ] "
+			"leng  ntw timestamp        bi->skb\n");
+
+		for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
+			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
+			tx_buffer_info = &tx_ring->tx_buffer_info[i];
+			u0 = (struct my_u0 *)tx_desc;
+			printk(KERN_ERR "T [0x%03X]    %016llX %016llX %016llX"
+				" %04X  %3X %016llX %p", i,
+				le64_to_cpu(u0->a),
+				le64_to_cpu(u0->b),
+				(u64)tx_buffer_info->dma,
+				tx_buffer_info->length,
+				tx_buffer_info->next_to_watch,
+				(u64)tx_buffer_info->time_stamp,
+				tx_buffer_info->skb);
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
+			if ((dump_flag & IXGBE_DUMP_BUFFERS) &&
+				tx_buffer_info->dma != 0)
+				hexdump(tx_buffer_info->dma,
+					tx_buffer_info->length);
+		}
+	}
+
+	/* Print RX Rings Summary */
+rx_ring_summary:
+	dev_err(&adapter->pdev->dev, "RX Rings Summary\n");
+	printk(KERN_ERR "Queue [NTU] [NTC]\n");
+	for (n = 0; n < adapter->num_rx_queues; n++) {
+		rx_ring = &adapter->rx_ring[n];
+		printk(KERN_ERR "%5d %5X %5X\n", n,
+			   rx_ring->next_to_use, rx_ring->next_to_clean);
+	}
+
+	/* Print RX Rings */
+	if ((dump_flag & IXGBE_DUMP_RX_RINGS) == 0)
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
+	 *   63       48 47    32 31  30      21 20 16 15   4 3     0
+	 *   +------------------------------------------------------+
+	 * 0 | Packet     IP     |SPH| HDR_LEN   | RSV|Packet|  RSS |
+	 *   | Checksum   Ident  |   |           |    | Type | Type |
+	 *   +------------------------------------------------------+
+	 * 8 | VLAN Tag | Length | Extended Error | Extended Status |
+	 *   +------------------------------------------------------+
+	 *   63       48 47    32 31            20 19               0
+	 */
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
+			rx_buffer_info = &rx_ring->rx_buffer_info[i];
+			rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
+			u0 = (struct my_u0 *)rx_desc;
+			staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
+			if (staterr & IXGBE_RXD_STAT_DD) {
+				/* Descriptor Done */
+				printk(KERN_ERR "RWB[0x%03X]     %016llX "
+					"%016llX ---------------- %p", i,
+					le64_to_cpu(u0->a),
+					le64_to_cpu(u0->b),
+					rx_buffer_info->skb);
+			} else {
+				printk(KERN_ERR "R  [0x%03X]     %016llX "
+					"%016llX %016llX %p", i,
+					le64_to_cpu(u0->a),
+					le64_to_cpu(u0->b),
+					(u64)rx_buffer_info->dma,
+					rx_buffer_info->skb);
+
+				if (dump_flag & IXGBE_DUMP_BUFFERS) {
+					hexdump(rx_buffer_info->dma,
+						rx_ring->rx_buf_len);
+					if (rx_ring->rx_buf_len
+						< IXGBE_RXBUFFER_2048)
+						hexdump(
+						  rx_buffer_info->page_dma +
+						  rx_buffer_info->page_offset,
+						  PAGE_SIZE/2);
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
 static void ixgbe_release_hw_control(struct ixgbe_adapter *adapter)
 {
 	u32 ctrl_ext;
@@ -3162,6 +3597,7 @@ static void ixgbe_reset_task(struct work

 	adapter->tx_timeout_count++;

+	ixgbe_dump(adapter);
 	ixgbe_reinit_locked(adapter);
 }



