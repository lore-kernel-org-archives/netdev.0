From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH v2 0/3] e1000e,igb,ixgbe: add registers etc. printout
 code just before resetting adapters
Date: Wed, 17 Feb 2010 11:32:23 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1002171126560.5328@jbrandeb-desk1.amr.corp.intel.com>
References: <4B593B74.2020601@jp.fujitsu.com> <alpine.WNT.2.00.1001221345580.6104@jbrandeb-desk1.amr.corp.intel.com> <4B5EC215.5090509@jp.fujitsu.com> <alpine.WNT.2.00.1002171043450.5328@jbrandeb-desk1.amr.corp.intel.com>
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
Received: from mga11.intel.com ([192.55.52.93]:38699 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750851Ab0BQTcY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 14:32:24 -0500
In-Reply-To: <alpine.WNT.2.00.1002171043450.5328@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 17 Feb 2010, Brandeburg, Jesse wrote:
> I also have another patch I made for ixgb to show the use of sysfs and a
> module parameter, I'll reply again with that next.

---

ixgb: debug dump patch

this patch helps us debug tx hangs and other issues by dumping
the transmit and receive descriptor rings in the host memory
upon a tx hang event.  debug code is enabled with
echo 1 > /sys/module/ixgb/parameters/debug_dump

and on the next tx hang you'll get a *massive* amount of data
dumped into the kernel log.  yeah debugfs would be perfect for this.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/ixgb/ixgb_ethtool.c |    6 ++
 drivers/net/ixgb/ixgb_hw.h      |   15 ++++
 drivers/net/ixgb/ixgb_main.c    |  140 ++++++++++++++++++++++++++++++++++++++-
 3 files changed, 159 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 288ee1d..607a71f 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -258,6 +258,9 @@ ixgb_get_regs_len(struct net_device *netdev)
 	return IXGB_REG_DUMP_LEN;
 }
 
+extern void ixgb_dump(struct ixgb_adapter *);
+extern int debug_dump;
+
 static void
 ixgb_get_regs(struct net_device *netdev,
 		   struct ethtool_regs *regs, void *p)
@@ -268,6 +271,9 @@ ixgb_get_regs(struct net_device *netdev,
 	u32 *reg_start = reg;
 	u8 i;
 
+	if (debug_dump)
+		ixgb_dump(adapter);
+
 	/* the 1 (one) below indicates an attempt at versioning, if the
 	 * interface in ethtool or the driver changes, this 1 should be
 	 * incremented */
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index 831fe0c..ac0f895 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -243,6 +243,21 @@ typedef enum {
 #define IXGB_XOFFTXC 0x021D0	/* XOFF Transmitted Count */
 #define IXGB_RJC     0x021D8	/* Receive Jabber Count */
 
+/* Diagnostic */
+#define IXGB_RDFH    0x04000    /* RX Data FIFO Head - RO */
+#define IXGB_RDFT    0x04008    /* RX Data FIFO Tail - RO */
+#define IXGB_RDFTS   0x04018    /* RX Data FIFO Tail Saved - RO */
+#define IXGB_RDFPC   0x04020    /* RX Data Packet Count - RO */
+#define IXGB_TDFH    0x04028    /* TX Data FIFO Head - RO */
+#define IXGB_TDFT    0x04030    /* TX Data FIFO Tail - RO */
+#define IXGB_TDFTS   0x04040    /* TX Data FIFO Tail Saved - RO */
+#define IXGB_TDFPC   0x04048    /* TX Data FIFO Packet Count - RO */
+#define IXGB_TREG    0x04050    /* Test Register - RW */
+#define IXGB_RPR     0x04058    /* RX Page Register - RW */
+#define IXGB_TPR     0x04060    /* TX Page Register - RW */
+#define IXGB_RPDBM   0x05000    /* RX Packet or Descriptor Buffer Memory - RO */
+#define IXGB_TPDBM   0x06000    /* TX Packet or Descriptor Buffer Memory - RO */
+
 /* CTRL0 Bit Masks */
 #define IXGB_CTRL0_LRST     0x00000008
 #define IXGB_CTRL0_JFE      0x00000010
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index eee28d3..578832f 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -32,7 +32,7 @@ char ixgb_driver_name[] = "ixgb";
 static char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
 
 #define DRIVERNAPI "-NAPI"
-#define DRV_VERSION "1.0.135-k2" DRIVERNAPI
+#define DRV_VERSION "1.0.136-k2" DRIVERNAPI
 const char ixgb_driver_version[] = DRV_VERSION;
 static const char ixgb_copyright[] = "Copyright (c) 1999-2008 Intel Corporation.";
 
@@ -42,6 +42,11 @@ module_param(copybreak, uint, 0644);
 MODULE_PARM_DESC(copybreak,
 	"Maximum size of packet that is copied to a new buffer on receive");
 
+unsigned int debug_dump __read_mostly = 0;
+module_param(debug_dump, uint, 0644);
+MODULE_PARM_DESC(debug_dump, "[DEBUG OPTION] dump transmit and receive "
+                             "descriptor rings");
+
 /* ixgb_pci_tbl - PCI Device ID Table
  *
  * Wildcard entries (PCI_ANY_ID) should come last
@@ -1218,7 +1223,6 @@ ixgb_tso(struct ixgb_adapter *adapter, struct sk_buff *skb)
 						| IXGB_CONTEXT_DESC_CMD_IDE
 						| (skb->len - (hdr_len)));
 
-
 		if (++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
 
@@ -1490,6 +1494,133 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	return NETDEV_TX_OK;
 }
 
+void ixgb_dump(struct ixgb_adapter* adapter)
+{
+	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
+	struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
+	struct ixgb_hw *hw = &adapter->hw;
+	int i=0;
+#define NUM_REGS 20 // 1 based count
+	uint32_t regs[NUM_REGS];
+	uint32_t *regs_buff = regs;
+	
+	char *reg_name[] = {
+	"CTRL0",  "STATUS", 
+	"RCTL", "RDLEN", "RDH", "RDT", "RDTR",
+	"TCTL", "TDBAL", "TDBAH", "TDLEN", "TDH", "TDT",
+	"TIDV", "TXDCTL", "RXDCTL",
+	"TDFH", "TDFT", "TDFTS", "TDFPC",
+	};
+
+	regs_buff[0]  = IXGB_READ_REG(hw, CTRL0);
+	regs_buff[1]  = IXGB_READ_REG(hw, STATUS);
+
+	regs_buff[2]  = IXGB_READ_REG(hw, RCTL);
+	regs_buff[3]  = IXGB_READ_REG(hw, RDLEN);
+	regs_buff[4]  = IXGB_READ_REG(hw, RDH);
+	regs_buff[5]  = IXGB_READ_REG(hw, RDT);
+	regs_buff[6]  = IXGB_READ_REG(hw, RDTR);
+
+	regs_buff[7]  = IXGB_READ_REG(hw, TCTL);
+	regs_buff[8]  = IXGB_READ_REG(hw, TDBAL);
+	regs_buff[9]  = IXGB_READ_REG(hw, TDBAH);
+	regs_buff[10]  = IXGB_READ_REG(hw, TDLEN);
+	regs_buff[11]  = IXGB_READ_REG(hw, TDH);
+	regs_buff[12] = IXGB_READ_REG(hw, TDT);
+
+	regs_buff[13] = IXGB_READ_REG(hw, TIDV);
+	regs_buff[14] = IXGB_READ_REG(hw, TXDCTL);
+	regs_buff[15] = IXGB_READ_REG(hw, RXDCTL);
+	regs_buff[16] = IXGB_READ_REG(hw, TDFH);
+	regs_buff[17] = IXGB_READ_REG(hw, TDFT);
+	regs_buff[18] = IXGB_READ_REG(hw, TDFTS);
+	regs_buff[19] = IXGB_READ_REG(hw, TDFPC);
+	
+	printk(KERN_ERR"Register dump\n");
+	for (i = 0; i < NUM_REGS; i++) {
+		printk("%-15s  %08x\n", 
+		reg_name[i], regs_buff[i]);
+	}
+	
+	printk(KERN_ERR"TX Desc ring0 dump @ TDBAL: %08lX\n",
+	       (unsigned long)IXGB_READ_REG(hw, TDBAL));
+
+	printk(KERN_ERR"             dma              status  len      bidma            bilen ntw ts       skb             \n");
+
+	for (i = 0; tx_ring->desc && (i < tx_ring->count); i++ ) {
+		struct ixgb_tx_desc* tx_desc = IXGB_TX_DESC(*tx_ring, i);
+		struct ixgb_buffer *buffer_info = &tx_ring->buffer_info[i];
+		struct my_u { u64 a; u64 b;};
+		struct my_u *u = (struct my_u *)tx_desc;
+		printk("T[0x%3x]     %016llX %016llX %016llX %04X  %3X %08lX %p"
+			, i, le64_to_cpu(u->a),le64_to_cpu(u->b),
+			(u64)buffer_info->dma, buffer_info->length,
+			buffer_info->next_to_watch,
+			(unsigned long)buffer_info->time_stamp,
+			buffer_info->skb);
+
+		if (i == tx_ring->next_to_use && i == tx_ring->next_to_clean)
+			printk(" NTC/U\n");
+		else if (i == tx_ring->next_to_use)
+			printk(" NTU\n");
+		else if (i == tx_ring->next_to_clean)
+			printk(" NTC\n");
+		else
+			printk("\n");
+	}
+
+	msleep(5);
+
+#if 0
+	/* print the tx fifo all 32kB of it */
+	printk("\nTx fifo\n0x   0: ");
+	for (i=0; i<0x8000; ) {
+		IXGB_WRITE_REG(hw, TPR, i);
+		printk("%08X ", IXGB_READ_REG(hw, TPDBM+(i & 0xfff)));
+		i+=4;
+		if (i % 16 == 0) {
+			printk("\n 0x%4X: ", i);
+		}
+		if (i % 64 == 0) {
+			msleep(1);
+		}
+		
+	}
+	/* print the tx descriptor cache (only 2k)*/
+	printk("\nTx descriptor cache\n0x   0: ");
+	{
+		int j;
+		IXGB_WRITE_REG(hw, TPR, 1<<20);
+		for (j=0; j < 0x800; ) {
+			printk("%08X ", IXGB_READ_REG(hw, TPDBM+j+4));
+			printk("%08X ", IXGB_READ_REG(hw, TPDBM+j));
+			j+=8;
+			if (j % 16 == 0) {
+				printk("\n 0x%4X: ", j);
+			}
+			if (j % 64 == 0) {
+				msleep(1);
+			}
+		}
+	}
+#endif
+	printk(KERN_ERR"\nRX Desc ring0 dump\n");
+
+		printk("             dma              status  len\n");
+	for (i = 0; rx_ring->desc && (i < rx_ring->count); i++ ) {
+		struct ixgb_rx_desc* rx_desc = IXGB_RX_DESC(*rx_ring, i);
+		struct my_u { u64 a; u64 b;};
+		struct my_u *u = (struct my_u *)rx_desc;
+		printk("R[0x%3x]     %016llX %016llX", i, le64_to_cpu(u->a),le64_to_cpu(u->b));
+		if (i == rx_ring->next_to_use)
+			printk(" NTU\n");
+		else if (i == rx_ring->next_to_clean)
+			printk(" NTC\n");
+		else
+			printk("\n");
+	} /* for */
+}
+
 /**
  * ixgb_tx_timeout - Respond to a Tx Hang
  * @netdev: network interface device structure
@@ -1511,6 +1642,11 @@ ixgb_tx_timeout_task(struct work_struct *work)
 		container_of(work, struct ixgb_adapter, tx_timeout_task);
 
 	adapter->tx_timeout_count++;
+	if (debug_dump) {
+		ixgb_dump(adapter);
+		/* trigger an analyzer */
+		/* IXGB_WRITE_REG(&adapter->hw, WUS, 1); */
+	}
 	ixgb_down(adapter, true);
 	ixgb_up(adapter);
 }
