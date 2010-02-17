From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH v2 0/3] e1000e,igb,ixgbe: add registers etc. printout
 code just before resetting adapters
Date: Wed, 17 Feb 2010 11:10:01 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1002171043450.5328@jbrandeb-desk1.amr.corp.intel.com>
References: <4B593B74.2020601@jp.fujitsu.com> <alpine.WNT.2.00.1001221345580.6104@jbrandeb-desk1.amr.corp.intel.com> <4B5EC215.5090509@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	"chavey@google.com" <chavey@google.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16532 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750883Ab0BQTKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 14:10:04 -0500
In-Reply-To: <4B5EC215.5090509@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 26 Jan 2010, Taku Izumi wrote:
> (2010/01/23 6:54), Brandeburg, Jesse wrote:
> > Taku, thanks for these, we are talking the patches over and reviewing
> > them.  While I agree with the idea of these patches is good, I still don't
> > agree with the default being enabled.  Usually if someone is getting tx
> > hangs they are repeatable and we can work with them to get the debug
> > turned on.  I DO think it is useful to have the feature available by
> > default but NOT enabled.
> > 
> > If we wanted to enable something by default it might be useful to print
> > something that actually draws some conclusions from known failure modes,
> > like if TDH!=TDT after some amount of time.  I think one or two lines
> > maximum for default printing.
> > 
> > If you're working in this area I had an idea.  I had wanted to be able to
> > print the large amount of ring information (especially in the ixgbe case
> > with many rings) to the ftrace buffers in order to not overrun the syslog
> > daemon.  Not sure if you're interested in more new features, it certainly
> > is separate but related to this patch.
> 
> I thought similar things, that is, all information should be dumped to
> the private ring buffer to avoid filling syslog up with driver messages.
> But I didn't have any good idea to extract information from ring buffers,
> so as the first step, I decided to printout it by using printk().
> Is there the easy way to extract it from ring buffers?

First, I need to apologize for the delay, it's my fault.

I'm not sure about an easy way to use the private ring buffers yet, I know 
you can use the ftrace buffers directly, and then when someone read 
/sys/kernel/debug/tracing/trace they would get all the output.

Lets not do ftrace yet.

I have a counter proposal to make, here is a (incomplete) patch that we 
use all the time to debug tx hangs.  This example is for e1000e.  We are 
trying to avoid changes with other users' copyright to some of the files 
in our drivers so that we can ship them under multiple license.  We would 
much prefer something like this to be used, can you review?

I also have another patch I made for ixgb to show the use of sysfs and a 
module parameter, I'll reply again with that next.

---
From: Jesse Brandeburg <jesse.brandeburg@intel.com>

e1000e: dump code for descriptor rings

This is debug code for descriptor ring dumps, only enable if you really want a
lot of stuff in your syslog/dmesg when you get NETDEV WATCHDOG or tx hang
reports from the driver.

<not implemented> Code can be enabled at boot time with a module parameter or
via sysfs at runtime.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000e/ethtool.c |    4 +
 drivers/net/e1000e/hw.h      |   10 +
 drivers/net/e1000e/netdev.c  |  298 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 311 insertions(+), 1 deletions(-)


diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 0aa50c2..bbcf5c7 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -434,6 +434,8 @@ static int e1000_get_regs_len(struct net_device *netdev)
 	return E1000_REGS_LEN * sizeof(u32);
 }
 
+extern void e1000e_dump(struct e1000_adapter *);
+
 static void e1000_get_regs(struct net_device *netdev,
 			   struct ethtool_regs *regs, void *p)
 {
@@ -443,6 +445,8 @@ static void e1000_get_regs(struct net_device *netdev,
 	u16 phy_data;
 	u8 revision_id;
 
+	e1000e_dump(adapter);
+
 	memset(p, 0, E1000_REGS_LEN * sizeof(u32));
 
 	pci_read_config_byte(adapter->pdev, PCI_REVISION_ID, &revision_id);
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index eccf29b..d23501d 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
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
@@ -112,6 +117,11 @@ enum e1e_registers {
  */
 #define E1000_RDBAL_REG(_n)   (E1000_RDBAL + (_n << 8))
 	E1000_KABGTXD  = 0x03004, /* AFE Band Gap Transmit Ref Data */
+	E1000_TDFH     = 0x03410, /* TX Data FIFO Head - RW */
+	E1000_TDFT     = 0x03418, /* TX Data FIFO Tail - RW */
+	E1000_TDFHS    = 0x03420, /* TX Data FIFO Head Saved - RW */
+	E1000_TDFTS    = 0x03428, /* Tx Data FIFO Tail Saved - RW */
+	E1000_TDFPC    = 0x03430, /* TX Data FIFO Packet Count - RW */
 	E1000_TDBAL    = 0x03800, /* Tx Descriptor Base Address Low - RW */
 	E1000_TDBAH    = 0x03804, /* Tx Descriptor Base Address High - RW */
 	E1000_TDLEN    = 0x03808, /* Tx Descriptor Length - RW */
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c45965a..c990341 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -48,7 +48,7 @@
 
 #include "e1000.h"
 
-#define DRV_VERSION "1.0.2-k2"
+#define DRV_VERSION "1.0.2-k4"
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
@@ -601,6 +601,301 @@ static void e1000_print_hw_hang(struct work_struct *work)
 	      pci_status);
 }
 
+#if 0
+static void hexdump(dma_addr_t dma, u16 len)
+{
+	u16 offset, i;
+	char str[80], byte[4];
+	void *va = phys_to_virt((unsigned long)dma);
+
+	printk("buffer at %016llX (%d)\n", (u64)dma, len);
+	for (offset = 0; offset < len; offset += 16) {
+		sprintf(str, "%04x: ", offset);
+		for (i = 0; i < 16; i++) {
+			if ((offset + i) < len)
+				sprintf(byte, "%02x ",
+				        ((unsigned char *)va)[offset + i]);
+			else
+				strcpy(byte, "   ");
+			strcat(str, byte);
+		}
+		printk("%s\n", str);
+	}
+}
+
+#endif
+void e1000e_dump(struct e1000_adapter *adapter)
+{
+	/* this code doesn't handle multiple rings */
+	struct e1000_ring *tx_ring = adapter->tx_ring;
+	struct e1000_ring *rx_ring = adapter->rx_ring;
+	struct e1000_hw *hw = &adapter->hw;
+	int i = 0;
+#define NUM_REGS 38 /* 1 based count */
+	u32 regs[NUM_REGS];
+	u32 *regs_buff = regs;
+
+	char *reg_name[] = {
+	"CTRL",  "STATUS",
+	"RCTL", "RDLEN", "RDH", "RDT", "RDTR",
+	"TCTL", "TDBAL", "TDBAH", "TDLEN", "TDH", "TDT",
+	"TIDV", "TXDCTL", "TADV", "TARC0",
+	"TDBAL1", "TDBAH1", "TDLEN1", "TDH1", "TDT1",
+	"TXDCTL1", "TARC1",
+	"CTRL_EXT", "ERT", "RDBAL", "RDBAH",
+	 "TDFH", "TDFT", "TDFHS", "TDFTS", "TDFPC",
+	 "RDFH", "RDFT", "RDFHS", "RDFTS", "RDFPC",
+	};
+
+	//if (!e1000e_debug_dump)
+		//return;
+
+	regs_buff[0]  = er32(CTRL);
+	regs_buff[1]  = er32(STATUS);
+
+	regs_buff[2]  = er32(RCTL);
+	regs_buff[3]  = er32(RDLEN);
+	regs_buff[4]  = er32(RDH);
+	regs_buff[5]  = er32(RDT);
+	regs_buff[6]  = er32(RDTR);
+
+	regs_buff[7]  = er32(TCTL);
+	regs_buff[8]  = er32(TDBAL);
+	regs_buff[9]  = er32(TDBAH);
+	regs_buff[10] = er32(TDLEN);
+	regs_buff[11] = er32(TDH);
+	regs_buff[12] = er32(TDT);
+	regs_buff[13] = er32(TIDV);
+	regs_buff[14] = er32(TXDCTL(0));
+	regs_buff[15] = er32(TADV);
+	regs_buff[16] = er32(TARC(0));
+
+	regs_buff[22] = er32(TXDCTL(1));
+	regs_buff[23] = er32(TARC(1));
+	regs_buff[24] = er32(CTRL_EXT);
+	regs_buff[25] = er32(ERT);
+	regs_buff[26] = er32(RDBAL);
+	regs_buff[27] = er32(RDBAH);
+	regs_buff[28] = er32(TDFH);
+	regs_buff[29] = er32(TDFT);
+	regs_buff[30] = er32(TDFHS);
+	regs_buff[31] = er32(TDFTS);
+	regs_buff[32] = er32(TDFPC);
+	regs_buff[33] = er32(RDFH);
+	regs_buff[34] = er32(RDFT);
+	regs_buff[35] = er32(RDFHS);
+	regs_buff[36] = er32(RDFTS);
+	regs_buff[37] = er32(RDFPC);
+
+	e_err("Register dump\n");
+	for (i = 0; i < NUM_REGS; i++) {
+		printk("%-15s  %08x\n",
+		reg_name[i], regs_buff[i]);
+	}
+
+	/*
+	 * transmit dump
+	 */
+	printk(KERN_ERR"TX Desc ring0 dump\n");
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
+	printk("Tl(Legacy)   [address 63:0  ] [SpeCssSCmCsLen] [buffer_info dma"
+	       " leng  ntw       time_stamp             skb]\n");
+	printk("Tc(ExtCont)  [Ce CoCsIpceCoS] [MssHlRSCm0Plen] [buffer_info dma"
+	       " leng  ntw       time_stamp             skb]\n");
+	printk("Td(ExtData)  [address 63:0  ] [VlaPoRSCm1Dlen] [buffer_info dma"
+	       " leng  ntw       time_stamp             skb]\n");
+	for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
+		struct e1000_tx_desc *tx_desc = E1000_TX_DESC(*tx_ring, i);
+		struct e1000_buffer *buffer_info = &tx_ring->buffer_info[i];
+		struct my_u { u64 a; u64 b; };
+		struct my_u *u = (struct my_u *)tx_desc;
+		printk("T%c[0x%03X]    %016llX %016llX %016llX %04X  %3X "
+		       "%016llX %p",
+		       (!(le64_to_cpu(u->b) & (1<<29)) ? 'l' :
+		         ((le64_to_cpu(u->b) & (1<<20)) ? 'd' : 'c')), i,
+		       le64_to_cpu(u->a), le64_to_cpu(u->b),
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
+#if 0
+		if (adapter->dump_buffers && (buffer_info->dma != 0))
+			hexdump(buffer_info->dma, buffer_info->length);
+#endif
+	}
+
+	/*
+	 * receive dump
+	 */
+	printk(KERN_ERR"\nRX Desc ring dump\n");
+
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
+		printk("R  [desc]      [buffer 0 63:0 ] [buffer 1 63:0 ] "
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
+		printk("RWB[desc]      [ck ipid mrqhsh] [vl   l0 ee  es] "
+		       "[ l3  l2  l1 hs] [reserved      ] ---------------- "
+		       "[bi->skb] <-- Ext Rx Write-Back format\n");
+		for (i = 0; i < rx_ring->count; i++) {
+			struct e1000_buffer *buffer_info =
+						&rx_ring->buffer_info[i];
+			union e1000_rx_desc_packet_split *rx_desc =
+						E1000_RX_DESC_PS(*rx_ring, i);
+			struct my_u { u64 a; u64 b; u64 c; u64 d; };
+			struct my_u *u = (struct my_u *)rx_desc;
+			u32 staterr;
+			staterr = le32_to_cpu(rx_desc->wb.middle.status_error);
+			if (staterr & E1000_RXD_STAT_DD) {
+				/* Descriptor Done */
+				printk("RWB[0x%03X]     %016llX %016llX %016llX"
+				       " %016llX ---------------- %p",
+				       i, le64_to_cpu(u->a), le64_to_cpu(u->b),
+				       le64_to_cpu(u->c), le64_to_cpu(u->d),
+				       buffer_info->skb);
+			} else {
+				printk("R  [0x%03X]     %016llX %016llX %016llX"
+				       " %016llX %016llX %p",
+				       i, le64_to_cpu(u->a), le64_to_cpu(u->b),
+				       le64_to_cpu(u->c), le64_to_cpu(u->d),
+				       (u64)buffer_info->dma, buffer_info->skb);
+
+#if 0
+				if (adapter->dump_buffers)
+					hexdump(buffer_info->dma,
+					        adapter->rx_ps_bsize0);
+#endif
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
+		printk("Rl[desc]     [address 63:0  ] [vl er S cks ln] "
+		       "[bi->dma       ] [bi->skb] <-- Legacy format\n");
+		for (i = 0; rx_ring->desc && (i < rx_ring->count); i++) {
+			struct e1000_rx_desc *rx_desc =
+						E1000_RX_DESC(*rx_ring, i);
+			struct e1000_buffer *buffer_info =
+						&rx_ring->buffer_info[i];
+			struct my_u { u64 a; u64 b; };
+			struct my_u *u = (struct my_u *)rx_desc;
+			printk("Rl[0x%03X]    %016llX %016llX %016llX %p",
+				i, le64_to_cpu(u->a), le64_to_cpu(u->b),
+				(u64)buffer_info->dma, buffer_info->skb);
+			if (i == rx_ring->next_to_use)
+				printk(" NTU\n");
+			else if (i == rx_ring->next_to_clean)
+				printk(" NTC\n");
+			else
+				printk("\n");
+
+#if 0
+			if (adapter->dump_buffers)
+				hexdump(buffer_info->dma,
+				        adapter->rx_buffer_len);
+#endif
+		} /* for */
+	} /* switch */
+
+	/* dump the descriptor caches */
+	/* rx */
+	printk("Rx descriptor cache in 64bit format\n");
+	for (i = 0x6000; i <= 0x63FF ; i += 0x10) {
+		printk("R%04X: %08X|%08X %08X|%08X\n",
+				i,
+				readl(adapter->hw.hw_addr + i+4),
+				readl(adapter->hw.hw_addr + i),
+				readl(adapter->hw.hw_addr + i+12),
+				readl(adapter->hw.hw_addr + i+8));
+	}
+	/* tx */
+	printk("Tx descriptor cache in 64bit format\n");
+	for (i = 0x7000; i <= 0x73FF ; i += 0x10) {
+		printk("T%04X: %08X|%08X %08X|%08X\n",
+				i,
+				readl(adapter->hw.hw_addr + i+4),
+				readl(adapter->hw.hw_addr + i),
+				readl(adapter->hw.hw_addr + i+12),
+				readl(adapter->hw.hw_addr + i+8));
+	}
+}
+
 /**
  * e1000_clean_tx_irq - Reclaim resources after transmit completes
  * @adapter: board private structure
@@ -682,6 +977,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 			       + (adapter->tx_timeout_factor * HZ)) &&
 		    !(er32(STATUS) & E1000_STATUS_TXOFF)) {
 			schedule_work(&adapter->print_hang_task);
+			e1000e_dump(adapter);
 			netif_stop_queue(netdev);
 		}
 	}
