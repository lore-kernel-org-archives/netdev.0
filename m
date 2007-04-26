From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 08/12] r8169: cleanup
Date: Thu, 26 Apr 2007 23:48:56 +0200
Message-ID: <20070426214856.GI7344@electric-eye.fr.zoreil.com>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58570 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755168AbXDZVwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 17:52:03 -0400
Content-Disposition: inline
In-Reply-To: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No functionnal change:
- trim the old history log
- whitespace/indent/case police
- unsigned int where signedness does not matte
- removal of obsolete assert
- needless cast from void * (dev_instance)

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com>
---
 drivers/net/r8169.c |  311 ++++++++++++++++++++++-----------------------------
 1 files changed, 133 insertions(+), 178 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7a44de2..7a0c5e7 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1,40 +1,11 @@
 /*
-=========================================================================
- r8169.c: A RealTek RTL-8169 Gigabit Ethernet driver for Linux kernel 2.4.x.
- --------------------------------------------------------------------
-
- History:
- Feb  4 2002	- created initially by ShuChen <shuchen@realtek.com.tw>.
- May 20 2002	- Add link status force-mode and TBI mode support.
-	2004	- Massive updates. See kernel SCM system for details.
-=========================================================================
-VERSION 1.1	<2002/10/4>
-
-	The bit4:0 of MII register 4 is called "selector field", and have to be
-	00001b to indicate support of IEEE std 802.3 during NWay process of
-	exchanging Link Code Word (FLP).
-
-VERSION 1.2	<2002/11/30>
-
-	- Large style cleanup
-	- Use ether_crc in stock kernel (linux/crc32.h)
-	- Copy mc_filter setup code from 8139cp
-	  (includes an optimization, and avoids set_bit use)
-
-VERSION 1.6LK	<2004/04/14>
-
-	- Merge of Realtek's version 1.6
-	- Conversion to DMA API
-	- Suspend/resume
-	- Endianness
-	- Misc Rx/Tx bugs
-
-VERSION 2.2LK	<2005/01/25>
-
-	- RX csum, TX csum/SG, TSO
-	- VLAN
-	- baby (< 7200) Jumbo frames support
-	- Merge of Realtek's version 2.2 (new phy)
+ * r8169.c: RealTek 8169/8168/8101 ethernet driver.
+ *
+ * Copyright (c) 2002 ShuChen <shuchen@realtek.com.tw>
+ * Copyright (c) 2003 - 2007 Francois Romieu <romieu@fr.zoreil.com>
+ * Copyright (c) a lot of people too. Please respect their work.
+ *
+ * See MAINTAINERS file fro support contact information.
  */
 
 #include <linux/module.h>
@@ -108,7 +79,7 @@ static const int multicast_filter_limit = 32;
 #define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer. */
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
-#define EarlyTxThld 	0x3F	/* 0x3F means NO early transmit */
+#define EarlyTxThld	0x3F	/* 0x3F means NO early transmit */
 #define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC... */
 #define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
@@ -209,62 +180,62 @@ static struct {
 	u32 msg_enable;
 } debug = { -1 };
 
-enum RTL8169_registers {
-	MAC0 = 0,		/* Ethernet hardware address. */
-	MAR0 = 8,		/* Multicast filter. */
-	CounterAddrLow = 0x10,
-	CounterAddrHigh = 0x14,
-	TxDescStartAddrLow = 0x20,
-	TxDescStartAddrHigh = 0x24,
-	TxHDescStartAddrLow = 0x28,
-	TxHDescStartAddrHigh = 0x2c,
-	FLASH = 0x30,
-	ERSR = 0x36,
-	ChipCmd = 0x37,
-	TxPoll = 0x38,
-	IntrMask = 0x3C,
-	IntrStatus = 0x3E,
-	TxConfig = 0x40,
-	RxConfig = 0x44,
-	RxMissed = 0x4C,
-	Cfg9346 = 0x50,
-	Config0 = 0x51,
-	Config1 = 0x52,
-	Config2 = 0x53,
-	Config3 = 0x54,
-	Config4 = 0x55,
-	Config5 = 0x56,
-	MultiIntr = 0x5C,
-	PHYAR = 0x60,
-	TBICSR = 0x64,
-	TBI_ANAR = 0x68,
-	TBI_LPAR = 0x6A,
-	PHYstatus = 0x6C,
-	RxMaxSize = 0xDA,
-	CPlusCmd = 0xE0,
-	IntrMitigate = 0xE2,
-	RxDescAddrLow = 0xE4,
-	RxDescAddrHigh = 0xE8,
-	EarlyTxThres = 0xEC,
-	FuncEvent = 0xF0,
-	FuncEventMask = 0xF4,
-	FuncPresetState = 0xF8,
-	FuncForceEvent = 0xFC,
+enum rtl_registers {
+	MAC0		= 0,	/* Ethernet hardware address. */
+	MAR0		= 8,	/* Multicast filter. */
+	CounterAddrLow		= 0x10,
+	CounterAddrHigh		= 0x14,
+	TxDescStartAddrLow	= 0x20,
+	TxDescStartAddrHigh	= 0x24,
+	TxHDescStartAddrLow	= 0x28,
+	TxHDescStartAddrHigh	= 0x2c,
+	FLASH		= 0x30,
+	ERSR		= 0x36,
+	ChipCmd		= 0x37,
+	TxPoll		= 0x38,
+	IntrMask	= 0x3c,
+	IntrStatus	= 0x3e,
+	TxConfig	= 0x40,
+	RxConfig	= 0x44,
+	RxMissed	= 0x4c,
+	Cfg9346		= 0x50,
+	Config0		= 0x51,
+	Config1		= 0x52,
+	Config2		= 0x53,
+	Config3		= 0x54,
+	Config4		= 0x55,
+	Config5		= 0x56,
+	MultiIntr	= 0x5c,
+	PHYAR		= 0x60,
+	TBICSR		= 0x64,
+	TBI_ANAR	= 0x68,
+	TBI_LPAR	= 0x6a,
+	PHYstatus	= 0x6c,
+	RxMaxSize	= 0xda,
+	CPlusCmd	= 0xe0,
+	IntrMitigate	= 0xe2,
+	RxDescAddrLow	= 0xe4,
+	RxDescAddrHigh	= 0xe8,
+	EarlyTxThres	= 0xec,
+	FuncEvent	= 0xf0,
+	FuncEventMask	= 0xf4,
+	FuncPresetState	= 0xf8,
+	FuncForceEvent	= 0xfc,
 };
 
-enum RTL8169_register_content {
+enum rtl_register_content {
 	/* InterruptStatusBits */
-	SYSErr = 0x8000,
-	PCSTimeout = 0x4000,
-	SWInt = 0x0100,
-	TxDescUnavail = 0x80,
-	RxFIFOOver = 0x40,
-	LinkChg = 0x20,
-	RxOverflow = 0x10,
-	TxErr = 0x08,
-	TxOK = 0x04,
-	RxErr = 0x02,
-	RxOK = 0x01,
+	SYSErr		= 0x8000,
+	PCSTimeout	= 0x4000,
+	SWInt		= 0x0100,
+	TxDescUnavail	= 0x0080,
+	RxFIFOOver	= 0x0040,
+	LinkChg		= 0x0020,
+	RxOverflow	= 0x0010,
+	TxErr		= 0x0008,
+	TxOK		= 0x0004,
+	RxErr		= 0x0002,
+	RxOK		= 0x0001,
 
 	/* RxStatusDesc */
 	RxFOVF	= (1 << 23),
@@ -274,26 +245,26 @@ enum RTL8169_register_content {
 	RxCRC	= (1 << 19),
 
 	/* ChipCmdBits */
-	CmdReset = 0x10,
-	CmdRxEnb = 0x08,
-	CmdTxEnb = 0x04,
-	RxBufEmpty = 0x01,
+	CmdReset	= 0x10,
+	CmdRxEnb	= 0x08,
+	CmdTxEnb	= 0x04,
+	RxBufEmpty	= 0x01,
 
 	/* Cfg9346Bits */
-	Cfg9346_Lock = 0x00,
-	Cfg9346_Unlock = 0xC0,
+	Cfg9346_Lock	= 0x00,
+	Cfg9346_Unlock	= 0xc0,
 
 	/* rx_mode_bits */
-	AcceptErr = 0x20,
-	AcceptRunt = 0x10,
-	AcceptBroadcast = 0x08,
-	AcceptMulticast = 0x04,
-	AcceptMyPhys = 0x02,
-	AcceptAllPhys = 0x01,
+	AcceptErr	= 0x20,
+	AcceptRunt	= 0x10,
+	AcceptBroadcast	= 0x08,
+	AcceptMulticast	= 0x04,
+	AcceptMyPhys	= 0x02,
+	AcceptAllPhys	= 0x01,
 
 	/* RxConfigBits */
-	RxCfgFIFOShift = 13,
-	RxCfgDMAShift = 8,
+	RxCfgFIFOShift	= 13,
+	RxCfgDMAShift	=  8,
 
 	/* TxConfigBits */
 	TxInterFrameGapShift = 24,
@@ -337,23 +308,23 @@ enum RTL8169_register_content {
 	INTT_3		= 0x0003,	// 8168
 
 	/* rtl8169_PHYstatus */
-	TBI_Enable = 0x80,
-	TxFlowCtrl = 0x40,
-	RxFlowCtrl = 0x20,
-	_1000bpsF = 0x10,
-	_100bps = 0x08,
-	_10bps = 0x04,
-	LinkStatus = 0x02,
-	FullDup = 0x01,
+	TBI_Enable	= 0x80,
+	TxFlowCtrl	= 0x40,
+	RxFlowCtrl	= 0x20,
+	_1000bpsF	= 0x10,
+	_100bps		= 0x08,
+	_10bps		= 0x04,
+	LinkStatus	= 0x02,
+	FullDup		= 0x01,
 
 	/* _TBICSRBit */
-	TBILinkOK = 0x02000000,
+	TBILinkOK	= 0x02000000,
 
 	/* DumpCounterCommand */
-	CounterDump = 0x8,
+	CounterDump	= 0x8,
 };
 
-enum _DescStatusBit {
+enum desc_status_bit {
 	DescOwn		= (1 << 31), /* Descriptor is owned by NIC */
 	RingEnd		= (1 << 30), /* End of descriptor ring */
 	FirstFrag	= (1 << 29), /* First segment of a packet */
@@ -478,28 +449,34 @@ static int rtl8169_poll(struct net_device *dev, int *budget);
 static const unsigned int rtl8169_rx_config =
 	(RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
 
-static void mdio_write(void __iomem *ioaddr, int RegAddr, int value)
+static void mdio_write(void __iomem *ioaddr, int reg_addr, int value)
 {
 	int i;
 
-	RTL_W32(PHYAR, 0x80000000 | (RegAddr & 0xFF) << 16 | value);
+	RTL_W32(PHYAR, 0x80000000 | (reg_addr & 0xFF) << 16 | value);
 
 	for (i = 20; i > 0; i--) {
-		/* Check if the RTL8169 has completed writing to the specified MII register */
+		/*
+		 * Check if the RTL8169 has completed writing to the specified
+		 * MII register.
+		 */
 		if (!(RTL_R32(PHYAR) & 0x80000000))
 			break;
 		udelay(25);
 	}
 }
 
-static int mdio_read(void __iomem *ioaddr, int RegAddr)
+static int mdio_read(void __iomem *ioaddr, int reg_addr)
 {
 	int i, value = -1;
 
-	RTL_W32(PHYAR, 0x0 | (RegAddr & 0xFF) << 16);
+	RTL_W32(PHYAR, 0x0 | (reg_addr & 0xFF) << 16);
 
 	for (i = 20; i > 0; i--) {
-		/* Check if the RTL8169 has completed retrieving data from the specified MII register */
+		/*
+		 * Check if the RTL8169 has completed retrieving data from
+		 * the specified MII register.
+		 */
 		if (RTL_R32(PHYAR) & 0x80000000) {
 			value = (int) (RTL_R32(PHYAR) & 0xFFFF);
 			break;
@@ -557,7 +534,8 @@ static void rtl8169_xmii_reset_enable(void __iomem *ioaddr)
 }
 
 static void rtl8169_check_link_status(struct net_device *dev,
-				      struct rtl8169_private *tp, void __iomem *ioaddr)
+				      struct rtl8169_private *tp,
+				      void __iomem *ioaddr)
 {
 	unsigned long flags;
 
@@ -613,7 +591,7 @@ static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
+	unsigned int i;
 	static struct {
 		u32 opt;
 		u16 reg;
@@ -849,8 +827,7 @@ static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
 	int ret;
 
 	if (tp->vlgrp && (opts2 & RxVlanTag)) {
-		rtl8169_rx_hwaccel_skb(skb, tp->vlgrp,
-				       swab16(opts2 & 0xffff));
+		rtl8169_rx_hwaccel_skb(skb, tp->vlgrp, swab16(opts2 & 0xffff));
 		ret = 0;
 	} else
 		ret = -1;
@@ -1071,7 +1048,6 @@ static void rtl8169_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 	}
 }
 
-
 static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
 	.get_regs_len		= rtl8169_get_regs_len,
@@ -1097,8 +1073,8 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_perm_addr		= ethtool_op_get_perm_addr,
 };
 
-static void rtl8169_write_gmii_reg_bit(void __iomem *ioaddr, int reg, int bitnum,
-				       int bitval)
+static void rtl8169_write_gmii_reg_bit(void __iomem *ioaddr, int reg,
+				       int bitnum, int bitval)
 {
 	int val;
 
@@ -1108,7 +1084,8 @@ static void rtl8169_write_gmii_reg_bit(void __iomem *ioaddr, int reg, int bitnum
 	mdio_write(ioaddr, reg, val & 0xffff);
 }
 
-static void rtl8169_get_mac_version(struct rtl8169_private *tp, void __iomem *ioaddr)
+static void rtl8169_get_mac_version(struct rtl8169_private *tp,
+				    void __iomem *ioaddr)
 {
 	/*
 	 * The driver currently handles the 8168Bf and the 8168Be identically
@@ -1150,7 +1127,8 @@ static void rtl8169_print_mac_version(struct rtl8169_private *tp)
 	dprintk("mac_version = 0x%02x\n", tp->mac_version);
 }
 
-static void rtl8169_get_phy_version(struct rtl8169_private *tp, void __iomem *ioaddr)
+static void rtl8169_get_phy_version(struct rtl8169_private *tp,
+				    void __iomem *ioaddr)
 {
 	const struct {
 		u16 mask;
@@ -1227,7 +1205,7 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
 		  0xbf00 }	//w 0 15 0 bf00
 		}
 	}, *p = phy_magic;
-	int i;
+	unsigned int i;
 
 	rtl8169_print_mac_version(tp);
 	rtl8169_print_phy_version(tp);
@@ -1361,7 +1339,7 @@ static void rtl8169_phy_reset(struct net_device *dev,
 			      struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
+	unsigned int i;
 
 	tp->phy_reset_enable(ioaddr);
 	for (i = 0; i < 100; i++) {
@@ -1717,15 +1695,11 @@ err_out_free_dev_1:
 	goto out;
 }
 
-static void __devexit
-rtl8169_remove_one(struct pci_dev *pdev)
+static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	assert(dev != NULL);
-	assert(tp != NULL);
-
 	flush_scheduled_work();
 
 	unregister_netdev(dev);
@@ -2146,7 +2120,7 @@ err_out:
 
 static void rtl8169_rx_clear(struct rtl8169_private *tp)
 {
-	int i;
+	unsigned int i;
 
 	for (i = 0; i < NUM_RX_DESC; i++) {
 		if (tp->Rx_skbuff[i]) {
@@ -2282,14 +2256,9 @@ static void rtl8169_reinit_task(struct work_struct *work)
 
 	ret = rtl8169_open(dev);
 	if (unlikely(ret < 0)) {
-		if (net_ratelimit()) {
-			struct rtl8169_private *tp = netdev_priv(dev);
-
-			if (netif_msg_drv(tp)) {
-				printk(PFX KERN_ERR
-				       "%s: reinit failure (status = %d)."
-				       " Rescheduling.\n", dev->name, ret);
-			}
+		if (net_ratelimit() && netif_msg_drv(tp)) {
+			printk(PFX KERN_ERR "%s: reinit failure (status = %d)."
+			       " Rescheduling.\n", dev->name, ret);
 		}
 		rtl8169_schedule_work(dev, rtl8169_reinit_task);
 	}
@@ -2319,13 +2288,9 @@ static void rtl8169_reset_task(struct work_struct *work)
 		rtl_hw_start(dev);
 		netif_wake_queue(dev);
 	} else {
-		if (net_ratelimit()) {
-			struct rtl8169_private *tp = netdev_priv(dev);
-
-			if (netif_msg_intr(tp)) {
-				printk(PFX KERN_EMERG
-				       "%s: Rx buffers shortage\n", dev->name);
-			}
+		if (net_ratelimit() && netif_msg_intr(tp)) {
+			printk(PFX KERN_EMERG "%s: Rx buffers shortage\n",
+			       dev->name);
 		}
 		rtl8169_schedule_work(dev, rtl8169_reset_task);
 	}
@@ -2532,16 +2497,12 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 	rtl8169_schedule_work(dev, rtl8169_reinit_task);
 }
 
-static void
-rtl8169_tx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
-		     void __iomem *ioaddr)
+static void rtl8169_tx_interrupt(struct net_device *dev,
+				 struct rtl8169_private *tp,
+				 void __iomem *ioaddr)
 {
 	unsigned int dirty_tx, tx_left;
 
-	assert(dev != NULL);
-	assert(tp != NULL);
-	assert(ioaddr != NULL);
-
 	dirty_tx = tp->dirty_tx;
 	smp_rmb();
 	tx_left = tp->cur_tx - dirty_tx;
@@ -2618,17 +2579,13 @@ static inline int rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
 	return ret;
 }
 
-static int
-rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
-		     void __iomem *ioaddr)
+static int rtl8169_rx_interrupt(struct net_device *dev,
+				struct rtl8169_private *tp,
+				void __iomem *ioaddr)
 {
 	unsigned int cur_rx, rx_left;
 	unsigned int delta, count;
 
-	assert(dev != NULL);
-	assert(tp != NULL);
-	assert(ioaddr != NULL);
-
 	cur_rx = tp->cur_rx;
 	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
 	rx_left = rtl8169_rx_quota(rx_left, (u32) dev->quota);
@@ -2733,11 +2690,9 @@ rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 	return count;
 }
 
-/* The interrupt handler does all of the Rx thread work and cleans up after the Tx thread. */
-static irqreturn_t
-rtl8169_interrupt(int irq, void *dev_instance)
+static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 {
-	struct net_device *dev = (struct net_device *) dev_instance;
+	struct net_device *dev = dev_instance;
 	struct rtl8169_private *tp = netdev_priv(dev);
 	int boguscnt = max_interrupt_work;
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -2794,9 +2749,9 @@ rtl8169_interrupt(int irq, void *dev_instance)
 		break;
 #else
 		/* Rx interrupt */
-		if (status & (RxOK | RxOverflow | RxFIFOOver)) {
+		if (status & (RxOK | RxOverflow | RxFIFOOver))
 			rtl8169_rx_interrupt(dev, tp, ioaddr);
-		}
+
 		/* Tx interrupt */
 		if (status & (TxOK | TxErr))
 			rtl8169_tx_interrupt(dev, tp, ioaddr);
@@ -2928,7 +2883,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 	u32 mc_filter[2];	/* Multicast hash filter */
-	int i, rx_mode;
+	int rx_mode;
 	u32 tmp = 0;
 
 	if (dev->flags & IFF_PROMISC) {
@@ -2948,6 +2903,8 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 	} else {
 		struct dev_mc_list *mclist;
+		unsigned int i;
+
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
 		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
@@ -3063,14 +3020,12 @@ static struct pci_driver rtl8169_pci_driver = {
 #endif
 };
 
-static int __init
-rtl8169_init_module(void)
+static int __init rtl8169_init_module(void)
 {
 	return pci_register_driver(&rtl8169_pci_driver);
 }
 
-static void __exit
-rtl8169_cleanup_module(void)
+static void __exit rtl8169_cleanup_module(void)
 {
 	pci_unregister_driver(&rtl8169_pci_driver);
 }
-- 
1.4.4.2


