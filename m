From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 00/21] r8169: pull request for 'r8169-for-jeff-20070629' branch
Date: Fri, 29 Jun 2007 22:12:12 +0200
Message-ID: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55596 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585AbXF2UOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:14:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from branch 'r8169-for-jeff-20070629' in repository

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git r8169-for-jeff-20070629

to get the changes below.

Following mails on netdev describe each patch.

Distance from 'netdev-2.6-upstream' (c5322b6b7430c8d5ee059178e029d1fe173d3239)
------------------------------------------------------------------------------

f0b5caae6f80c3f986c75dbf0c295a727d37a8d3
aa08684e506cbb7c5523047975c9161c00098895
6f1bd622aa4f7578fb623c80d659fed5f1bc2a74
74e88f25c245439c6028aeefaf8817d0abffed07
ccb2c222b135b05031002428c7af37fbf104772b
0f9ca771566d60a47a0e8cac837bafa006fe25e5
dc0b8eabad0731ab5838b84b155813218463180a
7aae02eee1e97b40a28856f40a8ea5f421db53cf
7d015a20ef99893101e9c2d9eeacb95b84563ad8
cd8a6a538940d79173e5b5fc92c5d439201bb8ab
7b0004502e114172cbb7da75b66add1293c3af60
6d54a502eb244f05fe562296c069662b30f3e3de
3ce528c255d5807935ae538c7dfe9786a3d45a1c
7e41a2f1928b461e489e5256e13989a02b6c4409
607f00af1c998b2a15948f6616e766cbcc9885ae
39c51985b355331ff04c1286a474d8521573462a
e47e1700739025fb1f3111b92767e99778d838f8
6e3077d17f4a3c627f57ce4d347beb453ffa9a9e
6641a725feebe385179b993a6801e2b902362930
794e2548627e76fa5a4fc25ec6f26a01226b18eb
e7c39d0961889a4836091da87cb785d33fcc36e0

Diffstat
--------

 drivers/net/r8169.c |  944 ++++++++++++++++++++++++++++-----------------------
 1 files changed, 528 insertions(+), 416 deletions(-)

Shortlog
--------

David S. Miller (1):
      r8169: kill eth_copy_and_sum()

Francois Romieu (17):
      r8169: de-obfuscate modulo arithmetic
      r8169: add hooks for per-device hw_start handler
      r8169: add helpers for per-device hw_start handler
      r8169: populate the hw_start handler for the 8168
      r8169: populate the hw_start handler for the 8110
      r8169: prettify mac_version
      r8169: merge with version 6.001.00 of Realtek's r8169 driver
      r8169: merge with version 8.001.00 of Realtek's r8168 driver
      r8169: confusion between hardware and IP header alignment
      r8169: small 8101 comment
      r8169: remove the media option
      r8169: cleanup
      r8169: add bit description for the TxPoll register
      r8169: align the IP header when there is no DMA constraint
      r8169: display some extra debug information during startup
      r8169: mac address change support
      r8169: perform RX config change after mac filtering

Rolf Eike Beer (1):
      r8169: add endianess annotations to [RT]xDesc

Stephen Hemminger (2):
      r8169: use netdev_alloc_skb
      r8169: Rx path update

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5ec7752..982a901 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1,53 +1,11 @@
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
-  1. [DEPRECATED: use ethtool instead] The media can be forced in 5 modes.
-	 Command: 'insmod r8169 media = SET_MEDIA'
-	 Ex:	  'insmod r8169 media = 0x04' will force PHY to operate in 100Mpbs Half-duplex.
-
-	 SET_MEDIA can be:
- 		_10_Half	= 0x01
- 		_10_Full	= 0x02
- 		_100_Half	= 0x04
- 		_100_Full	= 0x08
- 		_1000_Full	= 0x10
-
-  2. Support TBI mode.
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
+ * See MAINTAINERS file for support contact information.
  */
 
 #include <linux/module.h>
@@ -108,11 +66,6 @@ VERSION 2.2LK	<2005/01/25>
 #define rtl8169_rx_quota(count, quota)	count
 #endif
 
-/* media options */
-#define MAX_UNITS 8
-static int media[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1 };
-static int num_media = 0;
-
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static const int max_interrupt_work = 20;
 
@@ -126,7 +79,7 @@ static const int multicast_filter_limit = 32;
 #define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer. */
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
-#define EarlyTxThld 	0x3F	/* 0x3F means NO early transmit */
+#define EarlyTxThld	0x3F	/* 0x3F means NO early transmit */
 #define RxPacketMaxSize	0x3FE8	/* 16K - 1 - ETH_HLEN - VLAN - CRC... */
 #define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
@@ -151,16 +104,17 @@ static const int multicast_filter_limit = 32;
 #define RTL_R32(reg)		((unsigned long) readl (ioaddr + (reg)))
 
 enum mac_version {
-	RTL_GIGA_MAC_VER_01 = 0x00,
-	RTL_GIGA_MAC_VER_02 = 0x01,
-	RTL_GIGA_MAC_VER_03 = 0x02,
-	RTL_GIGA_MAC_VER_04 = 0x03,
-	RTL_GIGA_MAC_VER_05 = 0x04,
-	RTL_GIGA_MAC_VER_11 = 0x0b,
-	RTL_GIGA_MAC_VER_12 = 0x0c,
-	RTL_GIGA_MAC_VER_13 = 0x0d,
-	RTL_GIGA_MAC_VER_14 = 0x0e,
-	RTL_GIGA_MAC_VER_15 = 0x0f
+	RTL_GIGA_MAC_VER_01 = 0x01, // 8169
+	RTL_GIGA_MAC_VER_02 = 0x02, // 8169S
+	RTL_GIGA_MAC_VER_03 = 0x03, // 8110S
+	RTL_GIGA_MAC_VER_04 = 0x04, // 8169SB
+	RTL_GIGA_MAC_VER_05 = 0x05, // 8110SCd
+	RTL_GIGA_MAC_VER_06 = 0x06, // 8110SCe
+	RTL_GIGA_MAC_VER_11 = 0x0b, // 8168Bb
+	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be 8168Bf
+	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb 8101Ec
+	RTL_GIGA_MAC_VER_14 = 0x0e, // 8101
+	RTL_GIGA_MAC_VER_15 = 0x0f  // 8101
 };
 
 enum phy_version {
@@ -180,11 +134,12 @@ static const struct {
 	u8 mac_version;
 	u32 RxConfigMask;	/* Clears the bits supported by this chip */
 } rtl_chip_info[] = {
-	_R("RTL8169",		RTL_GIGA_MAC_VER_01, 0xff7e1880),
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_02, 0xff7e1880),
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_03, 0xff7e1880),
-	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, 0xff7e1880),
-	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, 0xff7e1880),
+	_R("RTL8169",		RTL_GIGA_MAC_VER_01, 0xff7e1880), // 8169
+	_R("RTL8169s",		RTL_GIGA_MAC_VER_02, 0xff7e1880), // 8169S
+	_R("RTL8110s",		RTL_GIGA_MAC_VER_03, 0xff7e1880), // 8110S
+	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, 0xff7e1880), // 8169SB
+	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, 0xff7e1880), // 8110SCd
+	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_06, 0xff7e1880), // 8110SCe
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_11, 0xff7e1880), // PCI-E
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, 0xff7e1880), // PCI-E
 	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, 0xff7e1880), // PCI-E 8139
@@ -199,20 +154,15 @@ enum cfg_version {
 	RTL_CFG_2
 };
 
-static const struct {
-	unsigned int region;
-	unsigned int align;
-} rtl_cfg_info[] = {
-	[RTL_CFG_0] = { 1, NET_IP_ALIGN },
-	[RTL_CFG_1] = { 2, NET_IP_ALIGN },
-	[RTL_CFG_2] = { 2, 8 }
-};
+static void rtl_hw_start_8169(struct net_device *);
+static void rtl_hw_start_8168(struct net_device *);
+static void rtl_hw_start_8101(struct net_device *);
 
 static struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8136), 0, 0, RTL_CFG_2 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8167), 0, 0, RTL_CFG_0 },
-	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_2 },
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_1 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(0x1259,			0xc107), 0, 0, RTL_CFG_0 },
@@ -230,62 +180,63 @@ static struct {
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
+	MAC4		= 4,
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
@@ -295,26 +246,31 @@ enum RTL8169_register_content {
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
+
+	/* TXPoll register p.5 */
+	HPQ		= 0x80,		/* Poll cmd on the high prio queue */
+	NPQ		= 0x40,		/* Poll cmd on the low prio queue */
+	FSWInt		= 0x01,		/* Forced software interrupt */
 
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
@@ -323,6 +279,10 @@ enum RTL8169_register_content {
 	/* Config1 register p.24 */
 	PMEnable	= (1 << 0),	/* Power Management Enable */
 
+	/* Config2 register p. 25 */
+	PCI_Clock_66MHz = 0x01,
+	PCI_Clock_33MHz = 0x00,
+
 	/* Config3 register p.25 */
 	MagicPacket	= (1 << 5),	/* Wake up when receives a Magic Packet */
 	LinkUp		= (1 << 4),	/* Wake up when the cable connection is re-established */
@@ -343,36 +303,34 @@ enum RTL8169_register_content {
 	TBINwComplete	= 0x01000000,
 
 	/* CPlusCmd p.31 */
+	PktCntrDisable	= (1 << 7),	// 8168
 	RxVlan		= (1 << 6),
 	RxChkSum	= (1 << 5),
 	PCIDAC		= (1 << 4),
 	PCIMulRW	= (1 << 3),
+	INTT_0		= 0x0000,	// 8168
+	INTT_1		= 0x0001,	// 8168
+	INTT_2		= 0x0002,	// 8168
+	INTT_3		= 0x0003,	// 8168
 
 	/* rtl8169_PHYstatus */
-	TBI_Enable = 0x80,
-	TxFlowCtrl = 0x40,
-	RxFlowCtrl = 0x20,
-	_1000bpsF = 0x10,
-	_100bps = 0x08,
-	_10bps = 0x04,
-	LinkStatus = 0x02,
-	FullDup = 0x01,
-
-	/* _MediaType */
-	_10_Half = 0x01,
-	_10_Full = 0x02,
-	_100_Half = 0x04,
-	_100_Full = 0x08,
-	_1000_Full = 0x10,
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
@@ -405,15 +363,15 @@ enum _DescStatusBit {
 #define RsvdMask	0x3fffc000
 
 struct TxDesc {
-	u32 opts1;
-	u32 opts2;
-	u64 addr;
+	__le32 opts1;
+	__le32 opts2;
+	__le64 addr;
 };
 
 struct RxDesc {
-	u32 opts1;
-	u32 opts2;
-	u64 addr;
+	__le32 opts1;
+	__le32 opts2;
+	__le64 addr;
 };
 
 struct ring_info {
@@ -446,6 +404,8 @@ struct rtl8169_private {
 	unsigned rx_buf_sz;
 	struct timer_list timer;
 	u16 cp_cmd;
+	u16 intr_event;
+	u16 napi_event;
 	u16 intr_mask;
 	int phy_auto_nego_reg;
 	int phy_1000_ctrl_reg;
@@ -455,6 +415,7 @@ struct rtl8169_private {
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
 	void (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(void __iomem *);
+	void (*hw_start)(struct net_device *);
 	unsigned int (*phy_reset_pending)(void __iomem *);
 	unsigned int (*link_ok)(void __iomem *);
 	struct delayed_work task;
@@ -463,8 +424,6 @@ struct rtl8169_private {
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
-module_param_array(media, int, &num_media, 0);
-MODULE_PARM_DESC(media, "force phy operation. Deprecated by ethtool (8).");
 module_param(rx_copybreak, int, 0);
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 module_param(use_dac, int, 0);
@@ -478,9 +437,9 @@ static int rtl8169_open(struct net_device *dev);
 static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance);
 static int rtl8169_init_ring(struct net_device *dev);
-static void rtl8169_hw_start(struct net_device *dev);
+static void rtl_hw_start(struct net_device *dev);
 static int rtl8169_close(struct net_device *dev);
-static void rtl8169_set_rx_mode(struct net_device *dev);
+static void rtl_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
 static struct net_device_stats *rtl8169_get_stats(struct net_device *dev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
@@ -493,35 +452,37 @@ static void rtl8169_rx_clear(struct rtl8169_private *tp);
 static int rtl8169_poll(struct net_device *dev, int *budget);
 #endif
 
-static const u16 rtl8169_intr_mask =
-	SYSErr | LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
-static const u16 rtl8169_napi_event =
-	RxOK | RxOverflow | RxFIFOOver | TxOK | TxErr;
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
@@ -579,7 +540,8 @@ static void rtl8169_xmii_reset_enable(void __iomem *ioaddr)
 }
 
 static void rtl8169_check_link_status(struct net_device *dev,
-				      struct rtl8169_private *tp, void __iomem *ioaddr)
+				      struct rtl8169_private *tp,
+				      void __iomem *ioaddr)
 {
 	unsigned long flags;
 
@@ -596,38 +558,6 @@ static void rtl8169_check_link_status(struct net_device *dev,
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
-static void rtl8169_link_option(int idx, u8 *autoneg, u16 *speed, u8 *duplex)
-{
-	struct {
-		u16 speed;
-		u8 duplex;
-		u8 autoneg;
-		u8 media;
-	} link_settings[] = {
-		{ SPEED_10,	DUPLEX_HALF, AUTONEG_DISABLE,	_10_Half },
-		{ SPEED_10,	DUPLEX_FULL, AUTONEG_DISABLE,	_10_Full },
-		{ SPEED_100,	DUPLEX_HALF, AUTONEG_DISABLE,	_100_Half },
-		{ SPEED_100,	DUPLEX_FULL, AUTONEG_DISABLE,	_100_Full },
-		{ SPEED_1000,	DUPLEX_FULL, AUTONEG_DISABLE,	_1000_Full },
-		/* Make TBI happy */
-		{ SPEED_1000,	DUPLEX_FULL, AUTONEG_ENABLE,	0xff }
-	}, *p;
-	unsigned char option;
-
-	option = ((idx < MAX_UNITS) && (idx >= 0)) ? media[idx] : 0xff;
-
-	if ((option != 0xff) && !idx && netif_msg_drv(&debug))
-		printk(KERN_WARNING PFX "media option is deprecated.\n");
-
-	for (p = link_settings; p->media != 0xff; p++) {
-		if (p->media == option)
-			break;
-	}
-	*autoneg = p->autoneg;
-	*speed = p->speed;
-	*duplex = p->duplex;
-}
-
 static void rtl8169_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -667,7 +597,7 @@ static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
+	unsigned int i;
 	static struct {
 		u32 opt;
 		u16 reg;
@@ -893,8 +823,7 @@ static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
 	int ret;
 
 	if (tp->vlgrp && (opts2 & RxVlanTag)) {
-		rtl8169_rx_hwaccel_skb(skb, tp->vlgrp,
-				       swab16(opts2 & 0xffff));
+		rtl8169_rx_hwaccel_skb(skb, tp->vlgrp, swab16(opts2 & 0xffff));
 		ret = 0;
 	} else
 		ret = -1;
@@ -1115,7 +1044,6 @@ static void rtl8169_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 	}
 }
 
-
 static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
 	.get_regs_len		= rtl8169_get_regs_len,
@@ -1141,8 +1069,8 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_perm_addr		= ethtool_op_get_perm_addr,
 };
 
-static void rtl8169_write_gmii_reg_bit(void __iomem *ioaddr, int reg, int bitnum,
-				       int bitval)
+static void rtl8169_write_gmii_reg_bit(void __iomem *ioaddr, int reg,
+				       int bitnum, int bitval)
 {
 	int val;
 
@@ -1152,8 +1080,20 @@ static void rtl8169_write_gmii_reg_bit(void __iomem *ioaddr, int reg, int bitnum
 	mdio_write(ioaddr, reg, val & 0xffff);
 }
 
-static void rtl8169_get_mac_version(struct rtl8169_private *tp, void __iomem *ioaddr)
+static void rtl8169_get_mac_version(struct rtl8169_private *tp,
+				    void __iomem *ioaddr)
 {
+	/*
+	 * The driver currently handles the 8168Bf and the 8168Be identically
+	 * but they can be identified more specifically through the test below
+	 * if needed:
+	 *
+	 * (RTL_R32(TxConfig) & 0x700000) == 0x500000 ? 8168Bf : 8168Be
+	 *
+	 * Same thing for the 8101Eb and the 8101Ec:
+	 *
+	 * (RTL_R32(TxConfig) & 0x700000) == 0x200000 ? 8101Eb : 8101Ec
+	 */
 	const struct {
 		u32 mask;
 		int mac_version;
@@ -1163,6 +1103,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp, void __iomem *io
 		{ 0x34000000,	RTL_GIGA_MAC_VER_13 },
 		{ 0x30800000,	RTL_GIGA_MAC_VER_14 },
 		{ 0x30000000,	RTL_GIGA_MAC_VER_11 },
+		{ 0x98000000,	RTL_GIGA_MAC_VER_06 },
 		{ 0x18000000,	RTL_GIGA_MAC_VER_05 },
 		{ 0x10000000,	RTL_GIGA_MAC_VER_04 },
 		{ 0x04000000,	RTL_GIGA_MAC_VER_03 },
@@ -1171,7 +1112,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp, void __iomem *io
 	}, *p = mac_info;
 	u32 reg;
 
-	reg = RTL_R32(TxConfig) & 0x7c800000;
+	reg = RTL_R32(TxConfig) & 0xfc800000;
 	while ((reg & p->mask) != p->mask)
 		p++;
 	tp->mac_version = p->mac_version;
@@ -1182,7 +1123,8 @@ static void rtl8169_print_mac_version(struct rtl8169_private *tp)
 	dprintk("mac_version = 0x%02x\n", tp->mac_version);
 }
 
-static void rtl8169_get_phy_version(struct rtl8169_private *tp, void __iomem *ioaddr)
+static void rtl8169_get_phy_version(struct rtl8169_private *tp,
+				    void __iomem *ioaddr)
 {
 	const struct {
 		u16 mask;
@@ -1259,7 +1201,7 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
 		  0xbf00 }	//w 0 15 0 bf00
 		}
 	}, *p = phy_magic;
-	int i;
+	unsigned int i;
 
 	rtl8169_print_mac_version(tp);
 	rtl8169_print_phy_version(tp);
@@ -1393,7 +1335,7 @@ static void rtl8169_phy_reset(struct net_device *dev,
 			      struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	int i;
+	unsigned int i;
 
 	tp->phy_reset_enable(ioaddr);
 	for (i = 0; i < 100; i++) {
@@ -1408,21 +1350,16 @@ static void rtl8169_phy_reset(struct net_device *dev,
 static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	static int board_idx = -1;
-	u8 autoneg, duplex;
-	u16 speed;
-
-	board_idx++;
 
 	rtl8169_hw_phy_config(dev);
 
 	dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
 	RTL_W8(0x82, 0x01);
 
-	if (tp->mac_version < RTL_GIGA_MAC_VER_03) {
-		dprintk("Set PCI Latency=0x40\n");
-		pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
-	}
+	pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
+
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_06)
+		pci_write_config_byte(tp->pci_dev, PCI_CACHE_LINE_SIZE, 0x08);
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_02) {
 		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
@@ -1431,16 +1368,52 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 		mdio_write(ioaddr, 0x0b, 0x0000); //w 0x0b 15 0 0
 	}
 
-	rtl8169_link_option(board_idx, &autoneg, &speed, &duplex);
-
 	rtl8169_phy_reset(dev, tp);
 
-	rtl8169_set_speed(dev, autoneg, speed, duplex);
+	/*
+	 * rtl8169_set_speed_xmii takes good care of the Fast Ethernet
+	 * only 8101. Don't panic.
+	 */
+	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL);
 
 	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
 		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
 }
 
+static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 high;
+	u32 low;
+
+	low  = addr[0] | (addr[1] << 8) | (addr[2] << 16) | (addr[3] << 24);
+	high = addr[4] | (addr[5] << 8);
+
+	spin_lock_irq(&tp->lock);
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	RTL_W32(MAC0, low);
+	RTL_W32(MAC4, high);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
+	spin_unlock_irq(&tp->lock);
+}
+
+static int rtl_set_mac_address(struct net_device *dev, void *p)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	rtl_rar_set(tp, dev->dev_addr);
+
+	return 0;
+}
+
 static int rtl8169_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1467,15 +1440,49 @@ static int rtl8169_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
+static const struct rtl_cfg_info {
+	void (*hw_start)(struct net_device *);
+	unsigned int region;
+	unsigned int align;
+	u16 intr_event;
+	u16 napi_event;
+} rtl_cfg_infos [] = {
+	[RTL_CFG_0] = {
+		.hw_start	= rtl_hw_start_8169,
+		.region		= 1,
+		.align		= 0,
+		.intr_event	= SYSErr | LinkChg | RxOverflow |
+				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
+		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
+	},
+	[RTL_CFG_1] = {
+		.hw_start	= rtl_hw_start_8168,
+		.region		= 2,
+		.align		= 8,
+		.intr_event	= SYSErr | LinkChg | RxOverflow |
+				  TxErr | TxOK | RxOK | RxErr,
+		.napi_event	= TxErr | TxOK | RxOK | RxOverflow
+	},
+	[RTL_CFG_2] = {
+		.hw_start	= rtl_hw_start_8101,
+		.region		= 2,
+		.align		= 8,
+		.intr_event	= SYSErr | LinkChg | RxOverflow | PCSTimeout |
+				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
+		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
+	}
+};
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
-	const unsigned int region = rtl_cfg_info[ent->driver_data].region;
+	const struct rtl_cfg_info *cfg = rtl_cfg_infos + ent->driver_data;
+	const unsigned int region = cfg->region;
 	struct rtl8169_private *tp;
 	struct net_device *dev;
 	void __iomem *ioaddr;
-	unsigned int pm_cap;
-	int i, rc;
+	unsigned int i;
+	int rc;
 
 	if (netif_msg_drv(&debug)) {
 		printk(KERN_INFO "%s Gigabit Ethernet driver %s loaded\n",
@@ -1508,20 +1515,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc < 0)
 		goto err_out_disable_2;
 
-	/* save power state before pci_enable_device overwrites it */
-	pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
-	if (pm_cap) {
-		u16 pwr_command, acpi_idle_state;
-
-		pci_read_config_word(pdev, pm_cap + PCI_PM_CTRL, &pwr_command);
-		acpi_idle_state = pwr_command & PCI_PM_CTRL_STATE_MASK;
-	} else {
-		if (netif_msg_probe(tp)) {
-			dev_err(&pdev->dev,
-				"PowerManagement capability not found.\n");
-		}
-	}
-
 	/* make sure PCI base addr 1 is MMIO */
 	if (!(pci_resource_flags(pdev, region) & IORESOURCE_MEM)) {
 		if (netif_msg_probe(tp)) {
@@ -1585,7 +1578,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	RTL_W8(ChipCmd, CmdReset);
 
 	/* Check that the chip has finished the reset. */
-	for (i = 100; i > 0; i--) {
+	for (i = 0; i < 100; i++) {
 		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
 			break;
 		msleep_interruptible(1);
@@ -1647,11 +1640,12 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
 	dev->stop = rtl8169_close;
 	dev->tx_timeout = rtl8169_tx_timeout;
-	dev->set_multicast_list = rtl8169_set_rx_mode;
+	dev->set_multicast_list = rtl_set_rx_mode;
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
 	dev->change_mtu = rtl8169_change_mtu;
+	dev->set_mac_address = rtl_set_mac_address;
 
 #ifdef CONFIG_R8169_NAPI
 	dev->poll = rtl8169_poll;
@@ -1670,7 +1664,10 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->intr_mask = 0xffff;
 	tp->pci_dev = pdev;
 	tp->mmio_addr = ioaddr;
-	tp->align = rtl_cfg_info[ent->driver_data].align;
+	tp->align = cfg->align;
+	tp->hw_start = cfg->hw_start;
+	tp->intr_event = cfg->intr_event;
+	tp->napi_event = cfg->napi_event;
 
 	init_timer(&tp->timer);
 	tp->timer.data = (unsigned long) dev;
@@ -1685,15 +1682,17 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_set_drvdata(pdev, dev);
 
 	if (netif_msg_probe(tp)) {
+		u32 xid = RTL_R32(TxConfig) & 0x7cf0f8ff;
+
 		printk(KERN_INFO "%s: %s at 0x%lx, "
 		       "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
-		       "IRQ %d\n",
+		       "XID %08x IRQ %d\n",
 		       dev->name,
 		       rtl_chip_info[tp->chipset].name,
 		       dev->base_addr,
 		       dev->dev_addr[0], dev->dev_addr[1],
 		       dev->dev_addr[2], dev->dev_addr[3],
-		       dev->dev_addr[4], dev->dev_addr[5], dev->irq);
+		       dev->dev_addr[4], dev->dev_addr[5], xid, dev->irq);
 	}
 
 	rtl8169_init_phy(dev, tp);
@@ -1714,15 +1713,11 @@ err_out_free_dev_1:
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
@@ -1774,7 +1769,7 @@ static int rtl8169_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_release_ring_2;
 
-	rtl8169_hw_start(dev);
+	rtl_hw_start(dev);
 
 	rtl8169_request_timer(dev);
 
@@ -1805,7 +1800,7 @@ static void rtl8169_hw_reset(void __iomem *ioaddr)
 	RTL_R8(ChipCmd);
 }
 
-static void rtl8169_set_rx_tx_config_registers(struct rtl8169_private *tp)
+static void rtl_set_rx_tx_config_registers(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 	u32 cfg = rtl8169_rx_config;
@@ -1818,45 +1813,90 @@ static void rtl8169_set_rx_tx_config_registers(struct rtl8169_private *tp)
 		(InterFrameGap << TxInterFrameGapShift));
 }
 
-static void rtl8169_hw_start(struct net_device *dev)
+static void rtl_hw_start(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
-	u16 cmd;
-	u32 i;
+	unsigned int i;
 
 	/* Soft reset the chip. */
 	RTL_W8(ChipCmd, CmdReset);
 
 	/* Check that the chip has finished the reset. */
-	for (i = 100; i > 0; i--) {
+	for (i = 0; i < 100; i++) {
 		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
 			break;
 		msleep_interruptible(1);
 	}
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_05) {
-		RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | PCIMulRW);
-		pci_write_config_byte(pdev, PCI_CACHE_LINE_SIZE, 0x08);
-	}
+	tp->hw_start(dev);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_13) {
-		pci_write_config_word(pdev, 0x68, 0x00);
-		pci_write_config_word(pdev, 0x69, 0x08);
-	}
+	netif_start_queue(dev);
+}
 
-	/* Undocumented stuff. */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_05) {
-		/* Realtek's r1000_n.c driver uses '&& 0x01' here. Well... */
-		if ((RTL_R8(Config2) & 0x07) & 0x01)
-			RTL_W32(0x7c, 0x0007ffff);
 
-		RTL_W32(0x7c, 0x0007ff00);
+static void rtl_set_rx_tx_desc_registers(struct rtl8169_private *tp,
+					 void __iomem *ioaddr)
+{
+	/*
+	 * Magic spell: some iop3xx ARM board needs the TxDescAddrHigh
+	 * register to be written before TxDescAddrLow to work.
+	 * Switching from MMIO to I/O access fixes the issue as well.
+	 */
+	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr) >> 32);
+	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr) & DMA_32BIT_MASK);
+	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr) >> 32);
+	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr) & DMA_32BIT_MASK);
+}
+
+static u16 rtl_rw_cpluscmd(void __iomem *ioaddr)
+{
+	u16 cmd;
+
+	cmd = RTL_R16(CPlusCmd);
+	RTL_W16(CPlusCmd, cmd);
+	return cmd;
+}
+
+static void rtl_set_rx_max_size(void __iomem *ioaddr)
+{
+	/* Low hurts. Let's disable the filtering. */
+	RTL_W16(RxMaxSize, 16383);
+}
+
+static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
+{
+	struct {
+		u32 mac_version;
+		u32 clk;
+		u32 val;
+	} cfg2_info [] = {
+		{ RTL_GIGA_MAC_VER_05, PCI_Clock_33MHz, 0x000fff00 }, // 8110SCd
+		{ RTL_GIGA_MAC_VER_05, PCI_Clock_66MHz, 0x000fffff },
+		{ RTL_GIGA_MAC_VER_06, PCI_Clock_33MHz, 0x00ffff00 }, // 8110SCe
+		{ RTL_GIGA_MAC_VER_06, PCI_Clock_66MHz, 0x00ffffff }
+	}, *p = cfg2_info;
+	unsigned int i;
+	u32 clk;
 
-		pci_read_config_word(pdev, PCI_COMMAND, &cmd);
-		cmd = cmd & 0xef;
-		pci_write_config_word(pdev, PCI_COMMAND, cmd);
+	clk = RTL_R8(Config2) & PCI_Clock_66MHz;
+	for (i = 0; i < ARRAY_SIZE(cfg2_info); i++) {
+		if ((p->mac_version == mac_version) && (p->clk == clk)) {
+			RTL_W32(0x7c, p->val);
+			break;
+		}
+	}
+}
+
+static void rtl_hw_start_8169(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_05) {
+		RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | PCIMulRW);
+		pci_write_config_byte(pdev, PCI_CACHE_LINE_SIZE, 0x08);
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
@@ -1868,19 +1908,11 @@ static void rtl8169_hw_start(struct net_device *dev)
 
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
-	/* Low hurts. Let's disable the filtering. */
-	RTL_W16(RxMaxSize, 16383);
-
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
-		rtl8169_set_rx_tx_config_registers(tp);
+	rtl_set_rx_max_size(ioaddr);
 
-	cmd = RTL_R16(CPlusCmd);
-	RTL_W16(CPlusCmd, cmd);
+	rtl_set_rx_tx_config_registers(tp);
 
-	tp->cp_cmd |= cmd | PCIMulRW;
+	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
@@ -1891,29 +1923,15 @@ static void rtl8169_hw_start(struct net_device *dev)
 
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 
+	rtl8169_set_magic_reg(ioaddr, tp->mac_version);
+
 	/*
 	 * Undocumented corner. Supposedly:
 	 * (TxTimer << 12) | (TxPackets << 8) | (RxTimer << 4) | RxPackets
 	 */
 	RTL_W16(IntrMitigate, 0x0000);
 
-	/*
-	 * Magic spell: some iop3xx ARM board needs the TxDescAddrHigh
-	 * register to be written before TxDescAddrLow to work.
-	 * Switching from MMIO to I/O access fixes the issue as well.
-	 */
-	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr >> 32));
-	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr & DMA_32BIT_MASK));
-	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr >> 32));
-	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr & DMA_32BIT_MASK));
-
-	if ((tp->mac_version != RTL_GIGA_MAC_VER_01) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_02) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_03) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_04)) {
-		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
-		rtl8169_set_rx_tx_config_registers(tp);
-	}
+	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
@@ -1922,15 +1940,107 @@ static void rtl8169_hw_start(struct net_device *dev)
 
 	RTL_W32(RxMissed, 0);
 
-	rtl8169_set_rx_mode(dev);
+	rtl_set_rx_mode(dev);
 
 	/* no early-rx interrupts */
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 
 	/* Enable all known interrupts by setting the interrupt mask. */
-	RTL_W16(IntrMask, rtl8169_intr_mask);
+	RTL_W16(IntrMask, tp->intr_event);
 
-	netif_start_queue(dev);
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+}
+
+static void rtl_hw_start_8168(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+	u8 ctl;
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+
+	RTL_W8(EarlyTxThres, EarlyTxThld);
+
+	rtl_set_rx_max_size(ioaddr);
+
+	rtl_set_rx_tx_config_registers(tp);
+
+	tp->cp_cmd |= RTL_R16(CPlusCmd) | PktCntrDisable | INTT_1;
+
+	RTL_W16(CPlusCmd, tp->cp_cmd);
+
+	/* Tx performance tweak. */
+	pci_read_config_byte(pdev, 0x69, &ctl);
+	ctl = (ctl & ~0x70) | 0x50;
+	pci_write_config_byte(pdev, 0x69, ctl);
+
+	RTL_W16(IntrMitigate, 0x5151);
+
+	/* Work around for RxFIFO overflow. */
+	if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
+		tp->intr_event |= RxFIFOOver | PCSTimeout;
+		tp->intr_event &= ~RxOverflow;
+	}
+
+	rtl_set_rx_tx_desc_registers(tp, ioaddr);
+
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
+	RTL_R8(IntrMask);
+
+	RTL_W32(RxMissed, 0);
+
+	rtl_set_rx_mode(dev);
+
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+
+	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
+
+	RTL_W16(IntrMask, tp->intr_event);
+}
+
+static void rtl_hw_start_8101(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_13) {
+		pci_write_config_word(pdev, 0x68, 0x00);
+		pci_write_config_word(pdev, 0x69, 0x08);
+	}
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+
+	RTL_W8(EarlyTxThres, EarlyTxThld);
+
+	rtl_set_rx_max_size(ioaddr);
+
+	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
+
+	RTL_W16(CPlusCmd, tp->cp_cmd);
+
+	RTL_W16(IntrMitigate, 0x0000);
+
+	rtl_set_rx_tx_desc_registers(tp, ioaddr);
+
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+	rtl_set_rx_tx_config_registers(tp);
+
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
+	RTL_R8(IntrMask);
+
+	RTL_W32(RxMissed, 0);
+
+	rtl_set_rx_mode(dev);
+
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+
+	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xf000);
+
+	RTL_W16(IntrMask, tp->intr_event);
 }
 
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
@@ -1956,7 +2066,7 @@ static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
 
 	netif_poll_enable(dev);
 
-	rtl8169_hw_start(dev);
+	rtl_hw_start(dev);
 
 	rtl8169_request_timer(dev);
 
@@ -1997,38 +2107,38 @@ static inline void rtl8169_map_to_asic(struct RxDesc *desc, dma_addr_t mapping,
 	rtl8169_mark_to_asic(desc, rx_buf_sz);
 }
 
-static int rtl8169_alloc_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
-				struct RxDesc *desc, int rx_buf_sz,
-				unsigned int align)
+static struct sk_buff *rtl8169_alloc_rx_skb(struct pci_dev *pdev,
+					    struct net_device *dev,
+					    struct RxDesc *desc, int rx_buf_sz,
+					    unsigned int align)
 {
 	struct sk_buff *skb;
 	dma_addr_t mapping;
-	int ret = 0;
+	unsigned int pad;
 
-	skb = dev_alloc_skb(rx_buf_sz + align);
+	pad = align ? align : NET_IP_ALIGN;
+
+	skb = netdev_alloc_skb(dev, rx_buf_sz + pad);
 	if (!skb)
 		goto err_out;
 
-	skb_reserve(skb, (align - 1) & (unsigned long)skb->data);
-	*sk_buff = skb;
+	skb_reserve(skb, align ? ((pad - 1) & (unsigned long)skb->data) : pad);
 
 	mapping = pci_map_single(pdev, skb->data, rx_buf_sz,
 				 PCI_DMA_FROMDEVICE);
 
 	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
-
 out:
-	return ret;
+	return skb;
 
 err_out:
-	ret = -ENOMEM;
 	rtl8169_make_unusable_by_asic(desc);
 	goto out;
 }
 
 static void rtl8169_rx_clear(struct rtl8169_private *tp)
 {
-	int i;
+	unsigned int i;
 
 	for (i = 0; i < NUM_RX_DESC; i++) {
 		if (tp->Rx_skbuff[i]) {
@@ -2043,16 +2153,22 @@ static u32 rtl8169_rx_fill(struct rtl8169_private *tp, struct net_device *dev,
 {
 	u32 cur;
 
-	for (cur = start; end - cur > 0; cur++) {
-		int ret, i = cur % NUM_RX_DESC;
+	for (cur = start; end - cur != 0; cur++) {
+		struct sk_buff *skb;
+		unsigned int i = cur % NUM_RX_DESC;
+
+		WARN_ON((s32)(end - cur) < 0);
 
 		if (tp->Rx_skbuff[i])
 			continue;
 
-		ret = rtl8169_alloc_rx_skb(tp->pci_dev, tp->Rx_skbuff + i,
-			tp->RxDescArray + i, tp->rx_buf_sz, tp->align);
-		if (ret < 0)
+		skb = rtl8169_alloc_rx_skb(tp->pci_dev, dev,
+					   tp->RxDescArray + i,
+					   tp->rx_buf_sz, tp->align);
+		if (!skb)
 			break;
+
+		tp->Rx_skbuff[i] = skb;
 	}
 	return cur - start;
 }
@@ -2164,14 +2280,9 @@ static void rtl8169_reinit_task(struct work_struct *work)
 
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
@@ -2198,16 +2309,12 @@ static void rtl8169_reset_task(struct work_struct *work)
 
 	if (tp->dirty_rx == tp->cur_rx) {
 		rtl8169_init_ring_indexes(tp);
-		rtl8169_hw_start(dev);
+		rtl_hw_start(dev);
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
@@ -2344,7 +2451,7 @@ static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	smp_wmb();
 
-	RTL_W8(TxPoll, 0x40);	/* set polling bit */
+	RTL_W8(TxPoll, NPQ);	/* set polling bit */
 
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
@@ -2414,16 +2521,12 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
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
@@ -2480,38 +2583,37 @@ static inline void rtl8169_rx_csum(struct sk_buff *skb, struct RxDesc *desc)
 		skb->ip_summed = CHECKSUM_NONE;
 }
 
-static inline int rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
-				      struct RxDesc *desc, int rx_buf_sz,
-				      unsigned int align)
+static inline bool rtl8169_try_rx_copy(struct sk_buff **sk_buff,
+				       struct rtl8169_private *tp, int pkt_size,
+				       dma_addr_t addr)
 {
-	int ret = -1;
+	struct sk_buff *skb;
+	bool done = false;
 
-	if (pkt_size < rx_copybreak) {
-		struct sk_buff *skb;
+	if (pkt_size >= rx_copybreak)
+		goto out;
 
-		skb = dev_alloc_skb(pkt_size + align);
-		if (skb) {
-			skb_reserve(skb, (align - 1) & (unsigned long)skb->data);
-			eth_copy_and_sum(skb, sk_buff[0]->data, pkt_size, 0);
-			*sk_buff = skb;
-			rtl8169_mark_to_asic(desc, rx_buf_sz);
-			ret = 0;
-		}
-	}
-	return ret;
+	skb = netdev_alloc_skb(tp->dev, pkt_size + NET_IP_ALIGN);
+	if (!skb)
+		goto out;
+
+	pci_dma_sync_single_for_cpu(tp->pci_dev, addr, pkt_size,
+				    PCI_DMA_FROMDEVICE);
+	skb_reserve(skb, NET_IP_ALIGN);
+	skb_copy_from_linear_data(*sk_buff, skb->data, pkt_size);
+	*sk_buff = skb;
+	done = true;
+out:
+	return done;
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
@@ -2544,9 +2646,9 @@ rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 			rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 		} else {
 			struct sk_buff *skb = tp->Rx_skbuff[entry];
+			dma_addr_t addr = le64_to_cpu(desc->addr);
 			int pkt_size = (status & 0x00001FFF) - 4;
-			void (*pci_action)(struct pci_dev *, dma_addr_t,
-				size_t, int) = pci_dma_sync_single_for_device;
+			struct pci_dev *pdev = tp->pci_dev;
 
 			/*
 			 * The driver does not support incoming fragmented
@@ -2562,19 +2664,16 @@ rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 
 			rtl8169_rx_csum(skb, desc);
 
-			pci_dma_sync_single_for_cpu(tp->pci_dev,
-				le64_to_cpu(desc->addr), tp->rx_buf_sz,
-				PCI_DMA_FROMDEVICE);
-
-			if (rtl8169_try_rx_copy(&skb, pkt_size, desc,
-						tp->rx_buf_sz, tp->align)) {
-				pci_action = pci_unmap_single;
+			if (rtl8169_try_rx_copy(&skb, tp, pkt_size, addr)) {
+				pci_dma_sync_single_for_device(pdev, addr,
+					pkt_size, PCI_DMA_FROMDEVICE);
+				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
+			} else {
+				pci_unmap_single(pdev, addr, pkt_size,
+						 PCI_DMA_FROMDEVICE);
 				tp->Rx_skbuff[entry] = NULL;
 			}
 
-			pci_action(tp->pci_dev, le64_to_cpu(desc->addr),
-				   tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 
@@ -2585,6 +2684,13 @@ rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 			tp->stats.rx_bytes += pkt_size;
 			tp->stats.rx_packets++;
 		}
+
+		/* Work around for AMD plateform. */
+		if ((desc->opts2 & 0xfffe000) &&
+		    (tp->mac_version == RTL_GIGA_MAC_VER_05)) {
+			desc->opts2 = 0;
+			cur_rx++;
+		}
 	}
 
 	count = cur_rx - tp->cur_rx;
@@ -2608,11 +2714,9 @@ rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
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
@@ -2637,9 +2741,17 @@ rtl8169_interrupt(int irq, void *dev_instance)
 		RTL_W16(IntrStatus,
 			(status & RxFIFOOver) ? (status | RxOverflow) : status);
 
-		if (!(status & rtl8169_intr_mask))
+		if (!(status & tp->intr_event))
 			break;
 
+                /* Work around for rx fifo overflow */
+                if (unlikely(status & RxFIFOOver) &&
+		    (tp->mac_version == RTL_GIGA_MAC_VER_11)) {
+			netif_stop_queue(dev);
+			rtl8169_tx_timeout(dev);
+			break;
+		}
+
 		if (unlikely(status & SYSErr)) {
 			rtl8169_pcierr_interrupt(dev);
 			break;
@@ -2649,8 +2761,8 @@ rtl8169_interrupt(int irq, void *dev_instance)
 			rtl8169_check_link_status(dev, tp, ioaddr);
 
 #ifdef CONFIG_R8169_NAPI
-		RTL_W16(IntrMask, rtl8169_intr_mask & ~rtl8169_napi_event);
-		tp->intr_mask = ~rtl8169_napi_event;
+		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
+		tp->intr_mask = ~tp->napi_event;
 
 		if (likely(netif_rx_schedule_prep(dev)))
 			__netif_rx_schedule(dev);
@@ -2661,9 +2773,9 @@ rtl8169_interrupt(int irq, void *dev_instance)
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
@@ -2707,7 +2819,7 @@ static int rtl8169_poll(struct net_device *dev, int *budget)
 		 * write is safe - FR
 		 */
 		smp_wmb();
-		RTL_W16(IntrMask, rtl8169_intr_mask);
+		RTL_W16(IntrMask, tp->intr_event);
 	}
 
 	return (work_done >= work_to_do);
@@ -2789,14 +2901,13 @@ static int rtl8169_close(struct net_device *dev)
 	return 0;
 }
 
-static void
-rtl8169_set_rx_mode(struct net_device *dev)
+static void rtl_set_rx_mode(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 	u32 mc_filter[2];	/* Multicast hash filter */
-	int i, rx_mode;
+	int rx_mode;
 	u32 tmp = 0;
 
 	if (dev->flags & IFF_PROMISC) {
@@ -2816,6 +2927,8 @@ rtl8169_set_rx_mode(struct net_device *dev)
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 	} else {
 		struct dev_mc_list *mclist;
+		unsigned int i;
+
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
 		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
@@ -2840,10 +2953,11 @@ rtl8169_set_rx_mode(struct net_device *dev)
 		mc_filter[1] = 0xffffffff;
 	}
 
-	RTL_W32(RxConfig, tmp);
 	RTL_W32(MAR0 + 0, mc_filter[0]);
 	RTL_W32(MAR0 + 4, mc_filter[1]);
 
+	RTL_W32(RxConfig, tmp);
+
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
@@ -2931,14 +3045,12 @@ static struct pci_driver rtl8169_pci_driver = {
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
Ueimor
