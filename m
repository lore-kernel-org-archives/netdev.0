From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch] 2.6.5-rc2 - r8169 DAC
Date: Sat, 3 Apr 2004 01:00:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040403010045.A12904@electric-eye.fr.zoreil.com>
References: <20040329193604.A4744@electric-eye.fr.zoreil.com> <20040329144034.3d943d12.ak@suse.de> <20040329223513.C4744@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="FL5UXtIhxfXey3p5"
Cc: jgarzik@pobox.com, netdev@oss.sgi.com,
        Srihari Vijayaraghavan <harisri@bigpond.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040329223513.C4744@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Mar 29, 2004 at 10:35:13PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

By popular request, patch for DAC on r8169 is available at:
http://www.fr.zoreil.com/people/francois/misc/20040403-2.6.5-rc2-r8169.c-test.patch

It applies against 2.6.5-rc2 (i.e. anything 2.6.5-rcX I guess).

The incremental patches against the latest serie of r8169 patches posted
on netdev is attached.

A tester on a x86-32 and a tester on something-64 bits would be _really_
welcome.

--
Ueimor

--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-dac-00.patch"


DMA_{32/64}BIT_MASK for all.


 include/linux/dma-mapping.h |    3 +++
 1 files changed, 3 insertions(+)

diff -puN include/linux/dma-mapping.h~r8169-dac-00 include/linux/dma-mapping.h
--- linux-2.6.5-rc2/include/linux/dma-mapping.h~r8169-dac-00	2004-04-03 00:29:17.000000000 +0200
+++ linux-2.6.5-rc2-fr/include/linux/dma-mapping.h	2004-04-03 00:29:17.000000000 +0200
@@ -10,6 +10,9 @@ enum dma_data_direction {
 	DMA_NONE = 3,
 };
 
+#define DMA_64BIT_MASK 0xffffffffffffffffULL
+#define DMA_32BIT_MASK 0x00000000ffffffffULL
+
 #include <asm/dma-mapping.h>
 
 /* Backwards compat, remove in 2.7.x */

_

--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-dac-10.patch"


DAC experience:
- Rx and Tx descriptors rings handled on 64 bit;
- enable DAC through use of CPlusCmd register (reserved bits apart, this is
  similar to the 8139cp driver);
- use the higher 32 bits of addresses for the Rx/Tx buffers.


 linux/dma-mapping.h |    0 
 drivers/net/r8169.c |   66 ++++++++++++++++++++++++++++++++++++----------------
 2 files changed, 46 insertions(+), 20 deletions(-)

diff -puN drivers/net/r8169.c~r8169-dac-10 drivers/net/r8169.c
--- linux-2.6.5-rc2/drivers/net/r8169.c~r8169-dac-10	2004-04-03 00:29:35.000000000 +0200
+++ linux-2.6.5-rc2-fr/drivers/net/r8169.c	2004-04-03 00:29:35.000000000 +0200
@@ -152,8 +152,10 @@ static int rx_copybreak = 200;
 enum RTL8169_registers {
 	MAC0 = 0,		/* Ethernet hardware address. */
 	MAR0 = 8,		/* Multicast filter. */
-	TxDescStartAddr = 0x20,
-	TxHDescStartAddr = 0x28,
+	TxDescStartAddrLow = 0x20,
+	TxDescStartAddrHigh = 0x24,
+	TxHDescStartAddrLow = 0x28,
+	TxHDescStartAddrHigh = 0x2c,
 	FLASH = 0x30,
 	ERSR = 0x36,
 	ChipCmd = 0x37,
@@ -178,7 +180,8 @@ enum RTL8169_registers {
 	PHYstatus = 0x6C,
 	RxMaxSize = 0xDA,
 	CPlusCmd = 0xE0,
-	RxDescStartAddr = 0xE4,
+	RxDescAddrLow = 0xE4,
+	RxDescAddrHigh = 0xE8,
 	EarlyTxThres = 0xEC,
 	FuncEvent = 0xF0,
 	FuncEventMask = 0xF4,
@@ -230,7 +233,13 @@ enum RTL8169_register_content {
 
 	/*TxConfigBits */
 	TxInterFrameGapShift = 24,
-	TxDMAShift = 8,		/* DMA burst value (0-7) is shift this many bits */
+	TxDMAShift = 8,	/* DMA burst value (0-7) is shift this many bits */
+
+	/* CPlusCmd p.31 */
+	RxVlan		= (1 << 6),
+	RxChkSum	= (1 << 5),
+	PCIDAC		= (1 << 4),
+	PCIMulRW	= (1 << 3),
 
 	/*rtl8169_PHYstatus */
 	TBI_Enable = 0x80,
@@ -289,15 +298,13 @@ enum _DescStatusBit {
 struct TxDesc {
 	u32 status;
 	u32 vlan_tag;
-	u32 buf_addr;
-	u32 buf_Haddr;
+	u64 addr;
 };
 
 struct RxDesc {
 	u32 status;
 	u32 vlan_tag;
-	u32 buf_addr;
-	u32 buf_Haddr;
+	u64 addr;
 };
 
 struct rtl8169_private {
@@ -320,6 +327,7 @@ struct rtl8169_private {
 	struct sk_buff *Tx_skbuff[NUM_TX_DESC];	/* Index of Transmit data buffer */
 	struct timer_list timer;
 	unsigned long phy_link_down_cnt;
+	u16 cp_cmd;
 };
 
 MODULE_AUTHOR("Realtek");
@@ -716,6 +724,20 @@ rtl8169_init_board(struct pci_dev *pdev,
 		goto err_out_disable;
 	}
 
+	tp->cp_cmd = PCIMulRW | RxChkSum;
+
+	if ((sizeof(dma_addr_t) > 32) &&
+	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK))
+		tp->cp_cmd |= PCIDAC;
+	else {
+		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		if (rc < 0) {
+			printk(KERN_ERR PFX "DMA configuration failed.\n");
+			goto err_out_free_res;
+		}
+	}
+
+
 	// enable PCI bus-mastering
 	pci_set_master(pdev);
 
@@ -1102,17 +1124,21 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W32(TxConfig,
 		(TX_DMA_BURST << TxDMAShift) | (InterFrameGap <<
 						TxInterFrameGapShift));
-	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd));
+	tp->cp_cmd |= RTL_R16(CPlusCmd);
+	RTL_W16(CPlusCmd, tp->cp_cmd);
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_D) {
 		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0: bit-3 and bit-14 MUST be 1\n");
-		RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | (1 << 14) | (1 << 3));
+		tp->cp_cmd |= (1 << 14) | PCIMulRW;
+		RTL_W16(CPlusCmd, tp->cp_cmd);
 	}
 
 	tp->cur_rx = 0;
 
-	RTL_W32(TxDescStartAddr, tp->TxPhyAddr);
-	RTL_W32(RxDescStartAddr, tp->RxPhyAddr);
+	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr & DMA_32BIT_MASK));
+	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr >> 32));
+	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr & DMA_32BIT_MASK));
+	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr >> 32));
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 	udelay(10);
 
@@ -1132,14 +1158,14 @@ rtl8169_hw_start(struct net_device *dev)
 
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
-	desc->buf_addr = 0xdeadbeef;
+	desc->addr = 0x0badbadbadbadbad;
 	desc->status &= ~cpu_to_le32(OWNbit | RsvdMask);
 }
 
 static void rtl8169_free_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
 				struct RxDesc *desc)
 {
-	pci_unmap_single(pdev, le32_to_cpu(desc->buf_addr), RX_BUF_SIZE,
+	pci_unmap_single(pdev, le64_to_cpu(desc->addr), RX_BUF_SIZE,
 			 PCI_DMA_FROMDEVICE);
 	dev_kfree_skb(*sk_buff);
 	*sk_buff = NULL;
@@ -1153,7 +1179,7 @@ static inline void rtl8169_return_to_asi
 
 static inline void rtl8169_give_to_asic(struct RxDesc *desc, dma_addr_t mapping)
 {
-	desc->buf_addr = cpu_to_le32(mapping);
+	desc->addr = cpu_to_le64(mapping);
 	desc->status |= cpu_to_le32(OWNbit + RX_BUF_SIZE);
 }
 
@@ -1251,9 +1277,9 @@ static void rtl8169_unmap_tx_skb(struct 
 {
 	u32 len = sk_buff[0]->len;
 
-	pci_unmap_single(pdev, le32_to_cpu(desc->buf_addr),
+	pci_unmap_single(pdev, le64_to_cpu(desc->addr),
 			 len < ETH_ZLEN ? ETH_ZLEN : len, PCI_DMA_TODEVICE);
-	desc->buf_addr = 0x00;
+	desc->addr = 0x00;
 	*sk_buff = NULL;
 }
 
@@ -1325,7 +1351,7 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 					 PCI_DMA_TODEVICE);
 
 		tp->Tx_skbuff[entry] = skb;
-		tp->TxDescArray[entry].buf_addr = cpu_to_le32(mapping);
+		tp->TxDescArray[entry].addr = cpu_to_le64(mapping);
 
 		tp->TxDescArray[entry].status = cpu_to_le32(OWNbit | FSbit |
 			LSbit | len | (EORbit * !((entry + 1) % NUM_TX_DESC)));
@@ -1452,7 +1478,7 @@ rtl8169_rx_interrupt(struct net_device *
 
 
 			pci_dma_sync_single_for_cpu(tp->pci_dev,
-				le32_to_cpu(desc->buf_addr), RX_BUF_SIZE,
+				le64_to_cpu(desc->addr), RX_BUF_SIZE,
 				PCI_DMA_FROMDEVICE);
 
 			if (rtl8169_try_rx_copy(&skb, pkt_size, desc, dev)) {
@@ -1460,7 +1486,7 @@ rtl8169_rx_interrupt(struct net_device *
 				tp->Rx_skbuff[entry] = NULL;
 			}
 
-			pci_action(tp->pci_dev, le32_to_cpu(desc->buf_addr),
+			pci_action(tp->pci_dev, le64_to_cpu(desc->addr),
 				   RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 
 			skb_put(skb, pkt_size);
diff -puN include/linux/dma-mapping.h~r8169-dac-10 include/linux/dma-mapping.h

_

--FL5UXtIhxfXey3p5--
