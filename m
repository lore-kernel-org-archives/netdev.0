From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2 3/3] ixgbe: add registers etc. printout code just before
 resetting adapters
Date: Fri, 22 Jan 2010 14:50:23 +0900
Message-ID: <4B593C9F.8010102@jp.fujitsu.com>
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
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:51633 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932146Ab0AVFuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 00:50:39 -0500
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0M5ocJ7024435
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Fri, 22 Jan 2010 14:50:38 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5506445DE4E
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 14:50:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C9DF45DD70
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 14:50:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 135451DB803A
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 14:50:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A1B13E38009
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 14:50:34 +0900 (JST)
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
 drivers/net/ixgbe/ixgbe_main.c |  293 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_type.h |   29 ++++
 2 files changed, 322 insertions(+)

Index: net-next-2.6/drivers/net/ixgbe/ixgbe_main.c
===================================================================
--- net-next-2.6.orig/drivers/net/ixgbe/ixgbe_main.c
+++ net-next-2.6/drivers/net/ixgbe/ixgbe_main.c
@@ -60,6 +60,15 @@ static const struct ixgbe_info *ixgbe_in
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
@@ -174,6 +183,289 @@ static inline void ixgbe_disable_sriov(s
 	adapter->flags &= ~IXGBE_FLAG_SRIOV_ENABLED;
 }

+/*
+ * ixgbe_regdump - register printout routine
+ */
+static void ixgbe_regdump(struct ixgbe_hw *hw, u32 reg,
+			  char *name, u32 (*get_regofs)(int))
+{
+	printk(KERN_ERR "%-15s %08x\n", name, IXGBE_READ_REG(hw, reg));
+}
+
+/*
+ * ixgbe_regdump_n - register printout routine
+ */
+static void ixgbe_regdump_n(struct ixgbe_hw *hw, u32 reg,
+			    char *name, u32 (*get_regofs)(int))
+{
+	int i = 0, j = 0;
+	char rname[16];
+
+	if (!get_regofs)
+		return;
+
+	for (i = 0; i < 8; i++) {
+		snprintf(rname, 16, "%s[%d-%d]", name, i*8, i*8+7);
+		printk(KERN_ERR "%-15s ", rname);
+		for (j = 0; j < 8; j++)
+			printk("%08x ", IXGBE_READ_REG(hw, get_regofs(i*8+j)));
+		printk("\n");
+	}
+}
+
+static const struct ixgbe_reg_info ixgbe_reg_info_tbl[] = {
+
+	/* General Registers */
+	{IXGBE_CTRL, "CTRL", NULL, ixgbe_regdump},
+	{IXGBE_STATUS, "STATUS", NULL, ixgbe_regdump},
+	{IXGBE_CTRL_EXT, "CTRL_EXT", NULL, ixgbe_regdump},
+
+	/* Interrupt Registers */
+	{IXGBE_EICR, "EICR", NULL, ixgbe_regdump},
+
+	/* RX Registers */
+	{IXGBE_SRRCTL(0), "SRRCTL", get_regofs_SRRCTL, ixgbe_regdump_n},
+	{IXGBE_DCA_RXCTRL(0), "DRXCTL", get_regofs_DCA_RXCTRL, ixgbe_regdump_n},
+	{IXGBE_RDLEN(0), "RDLEN", get_regofs_RDLEN, ixgbe_regdump_n},
+	{IXGBE_RDH(0), "RDH", get_regofs_RDH, ixgbe_regdump_n},
+	{IXGBE_RDT(0), "RDT", get_regofs_RDT, ixgbe_regdump_n},
+	{IXGBE_RXDCTL(0), "RXDCTL", get_regofs_RXDCTL, ixgbe_regdump_n},
+	{IXGBE_RDBAL(0), "RDBAL", get_regofs_RDBAL, ixgbe_regdump_n},
+	{IXGBE_RDBAH(0), "RDBAH", get_regofs_RDBAH, ixgbe_regdump_n},
+
+	/* TX Registers */
+	{IXGBE_TDBAL(0), "TDBAL", get_regofs_TDBAL, ixgbe_regdump_n},
+	{IXGBE_TDBAH(0), "TDBAH", get_regofs_TDBAH, ixgbe_regdump_n},
+	{IXGBE_TDLEN(0), "TDLEN", get_regofs_TDLEN, ixgbe_regdump_n},
+	{IXGBE_TDH(0), "TDH", get_regofs_TDH, ixgbe_regdump_n},
+	{IXGBE_TDT(0), "TDT", get_regofs_TDT, ixgbe_regdump_n},
+	{IXGBE_TXDCTL(0), "TXDCTL", get_regofs_TXDCTL, ixgbe_regdump_n},
+
+	/* List Terminator */
+	{}
+};
+
+/*
+ * ixgbe_dump - Print registers, tx-rings and rx-rings
+ */
+static void ixgbe_dump(struct ixgbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_reg_info *reginfo;
+	int n = 0;
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
+	printk(KERN_ERR " Register Name   [value ]\n");
+	for (reginfo = (struct ixgbe_reg_info *)ixgbe_reg_info_tbl;
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
+				print_hex_dump(KERN_ERR, "",
+					DUMP_PREFIX_ADDRESS, 16, 1,
+					phys_to_virt(tx_buffer_info->dma),
+					tx_buffer_info->length, true);
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
+					print_hex_dump(KERN_ERR, "",
+					   DUMP_PREFIX_ADDRESS, 16, 1,
+					   phys_to_virt(rx_buffer_info->dma),
+					   rx_ring->rx_buf_len, true);
+
+					if (rx_ring->rx_buf_len
+						< IXGBE_RXBUFFER_2048)
+						print_hex_dump(KERN_ERR, "",
+						  DUMP_PREFIX_ADDRESS, 16, 1,
+						  phys_to_virt(
+						    rx_buffer_info->page_dma +
+						    rx_buffer_info->page_offset
+						  ),
+						  PAGE_SIZE/2, true);
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
@@ -3306,6 +3598,7 @@ static void ixgbe_reset_task(struct work

 	adapter->tx_timeout_count++;

+	ixgbe_dump(adapter);
 	ixgbe_reinit_locked(adapter);
 }

Index: net-next-2.6/drivers/net/ixgbe/ixgbe_type.h
===================================================================
--- net-next-2.6.orig/drivers/net/ixgbe/ixgbe_type.h
+++ net-next-2.6/drivers/net/ixgbe/ixgbe_type.h
@@ -2568,4 +2568,33 @@ struct ixgbe_info {
 #define IXGBE_ERR_EEPROM_VERSION                -24
 #define IXGBE_NOT_IMPLEMENTED                   0x7FFFFFFF

+
+struct ixgbe_reg_info {
+	u32 reg;
+	char *name;
+	u32 (*get_regofs)(int);
+	void (*dump_reg)(struct ixgbe_hw *, u32, char *, u32 (*)(int));
+};
+
+#define IXGBE_GET_REGOFS_FUNC(name)				\
+static inline u32 get_regofs_##name(int n)			\
+{								\
+	return IXGBE_##name(n);					\
+}								\
+
+IXGBE_GET_REGOFS_FUNC(SRRCTL)
+IXGBE_GET_REGOFS_FUNC(DCA_RXCTRL)
+IXGBE_GET_REGOFS_FUNC(RDLEN)
+IXGBE_GET_REGOFS_FUNC(RDH)
+IXGBE_GET_REGOFS_FUNC(RDT)
+IXGBE_GET_REGOFS_FUNC(RXDCTL)
+IXGBE_GET_REGOFS_FUNC(RDBAL)
+IXGBE_GET_REGOFS_FUNC(RDBAH)
+IXGBE_GET_REGOFS_FUNC(TDBAL)
+IXGBE_GET_REGOFS_FUNC(TDBAH)
+IXGBE_GET_REGOFS_FUNC(TDLEN)
+IXGBE_GET_REGOFS_FUNC(TDH)
+IXGBE_GET_REGOFS_FUNC(TDT)
+IXGBE_GET_REGOFS_FUNC(TXDCTL)
+
 #endif /* _IXGBE_TYPE_H_ */

