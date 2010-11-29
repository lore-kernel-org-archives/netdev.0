From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net/r8169: Correct the ram code for RTL8111D(L)
Date: Tue, 30 Nov 2010 00:33:34 +0100
Message-ID: <20101129233334.GA2888@electric-eye.fr.zoreil.com>
References: <1290772470-23713-1-git-send-email-hayeswang@realtek.com> <1290779458.3051.45.camel@localhost> <20101126224914.GA12266@electric-eye.fr.zoreil.com> <1290813146.3051.58.camel@localhost> <CE0F8B12F31D4E82860F4CE06907E98B@realtek.com.tw>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Cc: "'Ben Hutchings'" <benh@debian.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"'David Miller'" <davem@davemloft.net>, 564628@bugs.debian.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CE0F8B12F31D4E82860F4CE06907E98B@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

hayeswang <hayeswang@realtek.com> :
> Excuse me, I have some questions about the firmware patch.
> 
> 1. I should convert the data into the binary files (.bin). Is it right?

You may do it.

Fwiw I have cooked something for it in the attached patch #9 this WE. Feel
free to take bits from it. I will not do more changes while you work on it.

> 2. Where should I update the firmware files? Is the path the
> linux-2.6/firmware?

! This directory is only here to contain firmware images extracted from old
! device drivers which predate the common use of request_firmware().

It is fine for the existing code.

> However, according to linux-2.6/firmeware/README.AddingFirmware, I
> should update they to another repository:
> 	
> git://git.kernel.org/pub/scm/linux/kernel/git/dwmw2/linux-firmware.git

/me scratches head.

Assuming Realtek does not intend to stand this code / data as GPLable, yes.
It will help people staying clear from non-free code, it will help packaging
something useful and it will remove some cruft from the code.

So everybody will end happy. Especially after an aspirin.

-- 
Ueimor

--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-Correct-the-binary-code-Low-pass-filter-DLY_CAP-fine.patch"

>From da437a4f6a2483589b9da6d3b96f6655699a6923 Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 27 Nov 2010 00:13:32 +0100
Subject: [PATCH 1/9] Correct the binary code (Low pass filter & DLY_CAP fine tune from uC).
 The incorrect ram code would make the nic working abnormally.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |  141 +++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 113 insertions(+), 28 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7d33ef4..114b9ce 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1718,6 +1718,7 @@ static void rtl8168c_4_hw_phy_config(void __iomem *ioaddr)
 static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
 {
 	static const struct phy_reg phy_reg_init_0[] = {
+		/* Channel Estimation */
 		{ 0x1f, 0x0001 },
 		{ 0x06, 0x4064 },
 		{ 0x07, 0x2863 },
@@ -1734,19 +1735,33 @@ static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
 		{ 0x12, 0xf49f },
 		{ 0x13, 0x070b },
 		{ 0x1a, 0x05ad },
-		{ 0x14, 0x94c0 }
-	};
-	static const struct phy_reg phy_reg_init_1[] = {
+		{ 0x14, 0x94c0 },
+
+		/*
+		 * Tx Error Issue
+		 * enhance line driver power
+		 */
 		{ 0x1f, 0x0002 },
 		{ 0x06, 0x5561 },
 		{ 0x1f, 0x0005 },
 		{ 0x05, 0x8332 },
-		{ 0x06, 0x5561 }
+		{ 0x06, 0x5561 },
+
+		/*
+		 * Can not link to 1Gbps with bad cable
+		 * Decrease SNR threshold form 21.07dB to 19.04dB
+		 */
+		{ 0x1f, 0x0001 },
+		{ 0x17, 0x0cc0 },
+
+		{ 0x1f, 0x0000 },
+		{ 0x0d, 0xf880 }
 	};
 	static const struct phy_reg phy_reg_init_2[] = {
+		/* Low pass filter & DLY_CAP fine tune from uC */
 		{ 0x1f, 0x0005 },
-		{ 0x05, 0xffc2 },
-		{ 0x1f, 0x0005 },
+		{ 0x05, 0xfff6 },
+		{ 0x06, 0x0080 },
 		{ 0x05, 0x8000 },
 		{ 0x06, 0xf8f9 },
 		{ 0x06, 0xfaef },
@@ -2084,29 +2099,51 @@ static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
 		{ 0x06, 0xff01 },
 		{ 0x06, 0x4edd },
 		{ 0x06, 0xff01 },
-		{ 0x05, 0x83d4 },
-		{ 0x06, 0x8000 },
+		{ 0x06, 0xf8fa },
+		{ 0x06, 0xfbef },
+		{ 0x06, 0x79bf },
+		{ 0x06, 0xf822 },
+		{ 0x06, 0xd819 },
+		{ 0x06, 0xd958 },
+		{ 0x06, 0x849f },
+		{ 0x06, 0x09bf },
+		{ 0x06, 0x82be },
+		{ 0x06, 0xd682 },
+		{ 0x06, 0xc602 },
+		{ 0x06, 0x014f },
+		{ 0x06, 0xef97 },
+		{ 0x06, 0xfffe },
+		{ 0x06, 0xfc05 },
+		{ 0x06, 0x17ff },
+		{ 0x06, 0xfe01 },
+		{ 0x06, 0x1700 },
+		{ 0x06, 0x0102 },
 		{ 0x05, 0x83d8 },
 		{ 0x06, 0x8051 },
-		{ 0x02, 0x6010 },
+		{ 0x05, 0x83d6 },
+		{ 0x06, 0x82a0 },
+		{ 0x05, 0x83d4 },
+		{ 0x06, 0x8000 },
+		{ 0x02, 0x2010 },
 		{ 0x03, 0xdc00 },
+		{ 0x1f, 0x0000 },
+		{ 0x0b, 0x0600 },
+		{ 0x1f, 0x0005 },
 		{ 0x05, 0xfff6 },
 		{ 0x06, 0x00fc },
-		{ 0x1f, 0x0000 },
-
-		{ 0x1f, 0x0000 },
-		{ 0x0d, 0xf880 },
 		{ 0x1f, 0x0000 }
 	};
 
 	rtl_phy_write(ioaddr, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
 
+	/*
+	 * Rx Error Issue
+	 * Fine Tune Switching regulator parameter
+	 */
 	mdio_write(ioaddr, 0x1f, 0x0002);
 	mdio_plus_minus(ioaddr, 0x0b, 0x0010, 0x00ef);
 	mdio_plus_minus(ioaddr, 0x0c, 0xa200, 0x5d00);
 
-	rtl_phy_write(ioaddr, phy_reg_init_1, ARRAY_SIZE(phy_reg_init_1));
-
 	if (rtl8168d_efuse_read(ioaddr, 0x01) == 0xb1) {
 		static const struct phy_reg phy_reg_init[] = {
 			{ 0x1f, 0x0002 },
@@ -2147,20 +2184,28 @@ static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
 		rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 	}
 
+	/* RSET couple improve */
 	mdio_write(ioaddr, 0x1f, 0x0002);
 	mdio_patch(ioaddr, 0x0d, 0x0300);
 	mdio_patch(ioaddr, 0x0f, 0x0010);
 
+	/* Fine tune PLL performance */
 	mdio_write(ioaddr, 0x1f, 0x0002);
 	mdio_plus_minus(ioaddr, 0x02, 0x0100, 0x0600);
 	mdio_plus_minus(ioaddr, 0x03, 0x0000, 0xe000);
 
-	rtl_phy_write(ioaddr, phy_reg_init_2, ARRAY_SIZE(phy_reg_init_2));
+	mdio_write(ioaddr, 0x1f, 0x0005);
+	mdio_write(ioaddr, 0x05, 0x001b);
+	if (mdio_read(ioaddr, 0x06) == 0xbf00)
+		rtl_phy_write(ioaddr, phy_reg_init_2, ARRAY_SIZE(phy_reg_init_2));
+
+	mdio_write(ioaddr, 0x1f, 0x0000);
 }
 
 static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
 {
 	static const struct phy_reg phy_reg_init_0[] = {
+		/* Channel Estimation */
 		{ 0x1f, 0x0001 },
 		{ 0x06, 0x4064 },
 		{ 0x07, 0x2863 },
@@ -2179,16 +2224,31 @@ static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1a, 0x05ad },
 		{ 0x14, 0x94c0 },
 
+		/*
+		 * Tx Error Issue
+		 * enhance line driver power
+		 */
 		{ 0x1f, 0x0002 },
 		{ 0x06, 0x5561 },
 		{ 0x1f, 0x0005 },
 		{ 0x05, 0x8332 },
-		{ 0x06, 0x5561 }
+		{ 0x06, 0x5561 },
+
+		/*
+		 * Can not link to 1Gbps with bad cable
+		 * Decrease SNR threshold form 21.07dB to 19.04dB
+		 */
+		{ 0x1f, 0x0001 },
+		{ 0x17, 0x0cc0 },
+
+		{ 0x1f, 0x0000 },
+		{ 0x0d, 0xf880 }
 	};
 	static const struct phy_reg phy_reg_init_1[] = {
+		/* Low pass filter & DLY_CAP fine tune from uC */
 		{ 0x1f, 0x0005 },
-		{ 0x05, 0xffc2 },
-		{ 0x1f, 0x0005 },
+		{ 0x05, 0xfff6 },
+		{ 0x06, 0x0080 },
 		{ 0x05, 0x8000 },
 		{ 0x06, 0xf8f9 },
 		{ 0x06, 0xfaee },
@@ -2485,16 +2545,37 @@ static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
 		{ 0x06, 0xdfff },
 		{ 0x06, 0x014e },
 		{ 0x06, 0xddff },
-		{ 0x06, 0x0100 },
+		{ 0x06, 0x01f8 },
+		{ 0x06, 0xfafb },
+		{ 0x06, 0xef79 },
+		{ 0x06, 0xbff8 },
+		{ 0x06, 0x22d8 },
+		{ 0x06, 0x19d9 },
+		{ 0x06, 0x5884 },
+		{ 0x06, 0x9f09 },
+		{ 0x06, 0xbf82 },
+		{ 0x06, 0x6dd6 },
+		{ 0x06, 0x8275 },
+		{ 0x06, 0x0201 },
+		{ 0x06, 0x4fef },
+		{ 0x06, 0x97ff },
+		{ 0x06, 0xfefc },
+		{ 0x06, 0x0517 },
+		{ 0x06, 0xfffe },
+		{ 0x06, 0x0117 },
+		{ 0x06, 0x0001 },
+		{ 0x06, 0x0200 },
 		{ 0x05, 0x83d8 },
 		{ 0x06, 0x8000 },
+		{ 0x05, 0x83d6 },
+		{ 0x06, 0x824f },
+		{ 0x02, 0x2010 },
 		{ 0x03, 0xdc00 },
+		{ 0x1f, 0x0000 },
+		{ 0x0b, 0x0600 },
+		{ 0x1f, 0x0005 },
 		{ 0x05, 0xfff6 },
 		{ 0x06, 0x00fc },
-		{ 0x1f, 0x0000 },
-
-		{ 0x1f, 0x0000 },
-		{ 0x0d, 0xf880 },
 		{ 0x1f, 0x0000 }
 	};
 
@@ -2540,17 +2621,21 @@ static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
 		rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 	}
 
+	/* Fine tune PLL performance */
 	mdio_write(ioaddr, 0x1f, 0x0002);
 	mdio_plus_minus(ioaddr, 0x02, 0x0100, 0x0600);
 	mdio_plus_minus(ioaddr, 0x03, 0x0000, 0xe000);
 
-	mdio_write(ioaddr, 0x1f, 0x0001);
-	mdio_write(ioaddr, 0x17, 0x0cc0);
-
+	/* Switching regulator Slew rate */
 	mdio_write(ioaddr, 0x1f, 0x0002);
 	mdio_patch(ioaddr, 0x0f, 0x0017);
 
-	rtl_phy_write(ioaddr, phy_reg_init_1, ARRAY_SIZE(phy_reg_init_1));
+	mdio_write(ioaddr, 0x1f, 0x0005);
+	mdio_write(ioaddr, 0x05, 0x001b);
+	if (mdio_read(ioaddr, 0x06) == 0xb300)
+		rtl_phy_write(ioaddr, phy_reg_init_1, ARRAY_SIZE(phy_reg_init_1));
+
+	mdio_write(ioaddr, 0x1f, 0x0000);
 }
 
 static void rtl8168d_3_hw_phy_config(void __iomem *ioaddr)
-- 
1.7.3.2


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0002-r8169-identify-different-registers.patch"

>From 673eb7bf34422ed0078af92d09dc66584cc29fa5 Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 23 Sep 2010 23:34:09 +0200
Subject: [PATCH 2/9] r8169: identify different registers.

Documentation.

The location are the same, the values are the same but it is
just accidental. Note that the 810x could cope with a smaller
value as it does not support jumbo frames.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 114b9ce..6e80df6 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -63,7 +63,6 @@ static const int multicast_filter_limit = 32;
 #define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer. */
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
-#define EarlyTxThld	0x3F	/* 0x3F means NO early transmit */
 #define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
@@ -227,7 +226,14 @@ enum rtl_registers {
 	IntrMitigate	= 0xe2,
 	RxDescAddrLow	= 0xe4,
 	RxDescAddrHigh	= 0xe8,
-	EarlyTxThres	= 0xec,
+	EarlyTxThres	= 0xec,	/* 8169. Unit of 32 bytes. */
+
+#define NoEarlyTx	0x3f	/* Max value : no early transmit. */
+
+	MaxTxPacketSize	= 0xec,	/* 8101/8168. Unit of 128 bytes. */
+
+#define TxPacketMax	(8064 >> 7)
+
 	FuncEvent	= 0xf0,
 	FuncEventMask	= 0xf4,
 	FuncPresetState	= 0xf8,
@@ -3522,7 +3528,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
 		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
-	RTL_W8(EarlyTxThres, EarlyTxThld);
+	RTL_W8(EarlyTxThres, NoEarlyTx);
 
 	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
@@ -3657,7 +3663,7 @@ static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
 {
 	rtl_hw_start_8168bb(ioaddr, pdev);
 
-	RTL_W8(EarlyTxThres, EarlyTxThld);
+	RTL_W8(MaxTxPacketSize, 0x3f);
 
 	RTL_W8(Config4, RTL_R8(Config4) & ~(1 << 0));
 }
@@ -3712,7 +3718,7 @@ static void rtl_hw_start_8168cp_3(void __iomem *ioaddr, struct pci_dev *pdev)
 	/* Magic. */
 	RTL_W8(DBG_REG, 0x20);
 
-	RTL_W8(EarlyTxThres, EarlyTxThld);
+	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -3768,7 +3774,7 @@ static void rtl_hw_start_8168d(void __iomem *ioaddr, struct pci_dev *pdev)
 
 	rtl_disable_clock_request(pdev);
 
-	RTL_W8(EarlyTxThres, EarlyTxThld);
+	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -3783,7 +3789,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
-	RTL_W8(EarlyTxThres, EarlyTxThld);
+	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
 	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
@@ -3963,7 +3969,7 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
-	RTL_W8(EarlyTxThres, EarlyTxThld);
+	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
 	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
-- 
1.7.3.2


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0003-r8169-use-device-dependent-methods-to-access-the-MII.patch"

>From b84eaf51494f6e46609f2fb0c8961bf99c6ea9ec Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 1 Oct 2010 00:28:16 +0200
Subject: [PATCH 3/9] r8169: use device dependent methods to access the MII registers.

Current mdio_{read/write} can not reach enough information to
work correctly with newer chipsets.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes <hayeswang@realtek.com>
---
 drivers/net/r8169.c |  309 ++++++++++++++++++++++++++-------------------------
 1 files changed, 160 insertions(+), 149 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 6e80df6..790d34a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -498,9 +498,9 @@ struct rtl8169_private {
 #endif
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
 	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
-	void (*phy_reset_enable)(void __iomem *);
+	void (*phy_reset_enable)(struct rtl8169_private *tp);
 	void (*hw_start)(struct net_device *);
-	unsigned int (*phy_reset_pending)(void __iomem *);
+	unsigned int (*phy_reset_pending)(struct rtl8169_private *tp);
 	unsigned int (*link_ok)(void __iomem *);
 	int (*do_ioctl)(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd);
 	int pcie_cap;
@@ -541,7 +541,7 @@ static int rtl8169_poll(struct napi_struct *napi, int budget);
 static const unsigned int rtl8169_rx_config =
 	(RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
 
-static void mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+static void r8169_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
 {
 	int i;
 
@@ -563,7 +563,7 @@ static void mdio_write(void __iomem *ioaddr, int reg_addr, int value)
 	udelay(20);
 }
 
-static int mdio_read(void __iomem *ioaddr, int reg_addr)
+static int r8169_mdio_read(void __iomem *ioaddr, int reg_addr)
 {
 	int i, value = -1;
 
@@ -589,34 +589,42 @@ static int mdio_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
-static void mdio_patch(void __iomem *ioaddr, int reg_addr, int value)
+static void rtl_writephy(struct rtl8169_private *tp, int location, u32 val)
 {
-	mdio_write(ioaddr, reg_addr, mdio_read(ioaddr, reg_addr) | value);
+	r8169_mdio_write(tp->mmio_addr, location, val);
 }
 
-static void mdio_plus_minus(void __iomem *ioaddr, int reg_addr, int p, int m)
+static int rtl_readphy(struct rtl8169_private *tp, int location)
+{
+	return r8169_mdio_read(tp->mmio_addr, location);
+}
+
+static void rtl_patchphy(struct rtl8169_private *tp, int reg_addr, int value)
+{
+	rtl_writephy(tp, reg_addr, rtl_readphy(tp, reg_addr) | value);
+}
+
+static void rtl_w1w0_phy(struct rtl8169_private *tp, int reg_addr, int p, int m)
 {
 	int val;
 
-	val = mdio_read(ioaddr, reg_addr);
-	mdio_write(ioaddr, reg_addr, (val | p) & ~m);
+	val = rtl_readphy(tp, reg_addr);
+	rtl_writephy(tp, reg_addr, (val | p) & ~m);
 }
 
 static void rtl_mdio_write(struct net_device *dev, int phy_id, int location,
 			   int val)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
 
-	mdio_write(ioaddr, location, val);
+	rtl_writephy(tp, location, val);
 }
 
 static int rtl_mdio_read(struct net_device *dev, int phy_id, int location)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
 
-	return mdio_read(ioaddr, location);
+	return rtl_readphy(tp, location);
 }
 
 static void rtl_ephy_write(void __iomem *ioaddr, int reg_addr, int value)
@@ -717,14 +725,16 @@ static void rtl8169_asic_down(void __iomem *ioaddr)
 	RTL_R16(CPlusCmd);
 }
 
-static unsigned int rtl8169_tbi_reset_pending(void __iomem *ioaddr)
+static unsigned int rtl8169_tbi_reset_pending(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	return RTL_R32(TBICSR) & TBIReset;
 }
 
-static unsigned int rtl8169_xmii_reset_pending(void __iomem *ioaddr)
+static unsigned int rtl8169_xmii_reset_pending(struct rtl8169_private *tp)
 {
-	return mdio_read(ioaddr, MII_BMCR) & BMCR_RESET;
+	return rtl_readphy(tp, MII_BMCR) & BMCR_RESET;
 }
 
 static unsigned int rtl8169_tbi_link_ok(void __iomem *ioaddr)
@@ -737,17 +747,19 @@ static unsigned int rtl8169_xmii_link_ok(void __iomem *ioaddr)
 	return RTL_R8(PHYstatus) & LinkStatus;
 }
 
-static void rtl8169_tbi_reset_enable(void __iomem *ioaddr)
+static void rtl8169_tbi_reset_enable(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	RTL_W32(TBICSR, RTL_R32(TBICSR) | TBIReset);
 }
 
-static void rtl8169_xmii_reset_enable(void __iomem *ioaddr)
+static void rtl8169_xmii_reset_enable(struct rtl8169_private *tp)
 {
 	unsigned int val;
 
-	val = mdio_read(ioaddr, MII_BMCR) | BMCR_RESET;
-	mdio_write(ioaddr, MII_BMCR, val & 0xffff);
+	val = rtl_readphy(tp, MII_BMCR) | BMCR_RESET;
+	rtl_writephy(tp, MII_BMCR, val & 0xffff);
 }
 
 static void rtl8169_check_link_status(struct net_device *dev,
@@ -901,18 +913,17 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 				  u8 autoneg, u16 speed, u8 duplex)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
 	int giga_ctrl, bmcr;
 
 	if (autoneg == AUTONEG_ENABLE) {
 		int auto_nego;
 
-		auto_nego = mdio_read(ioaddr, MII_ADVERTISE);
+		auto_nego = rtl_readphy(tp, MII_ADVERTISE);
 		auto_nego |= (ADVERTISE_10HALF | ADVERTISE_10FULL |
 			      ADVERTISE_100HALF | ADVERTISE_100FULL);
 		auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
-		giga_ctrl = mdio_read(ioaddr, MII_CTRL1000);
+		giga_ctrl = rtl_readphy(tp, MII_CTRL1000);
 		giga_ctrl &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
 
 		/* The 8100e/8101e/8102e do Fast Ethernet only. */
@@ -940,12 +951,12 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 			 * Vendor specific (0x1f) and reserved (0x0e) MII
 			 * registers.
 			 */
-			mdio_write(ioaddr, 0x1f, 0x0000);
-			mdio_write(ioaddr, 0x0e, 0x0000);
+			rtl_writephy(tp, 0x1f, 0x0000);
+			rtl_writephy(tp, 0x0e, 0x0000);
 		}
 
-		mdio_write(ioaddr, MII_ADVERTISE, auto_nego);
-		mdio_write(ioaddr, MII_CTRL1000, giga_ctrl);
+		rtl_writephy(tp, MII_ADVERTISE, auto_nego);
+		rtl_writephy(tp, MII_CTRL1000, giga_ctrl);
 	} else {
 		giga_ctrl = 0;
 
@@ -959,21 +970,21 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		if (duplex == DUPLEX_FULL)
 			bmcr |= BMCR_FULLDPLX;
 
-		mdio_write(ioaddr, 0x1f, 0x0000);
+		rtl_writephy(tp, 0x1f, 0x0000);
 	}
 
 	tp->phy_1000_ctrl_reg = giga_ctrl;
 
-	mdio_write(ioaddr, MII_BMCR, bmcr);
+	rtl_writephy(tp, MII_BMCR, bmcr);
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
 		if ((speed == SPEED_100) && (autoneg != AUTONEG_ENABLE)) {
-			mdio_write(ioaddr, 0x17, 0x2138);
-			mdio_write(ioaddr, 0x0e, 0x0260);
+			rtl_writephy(tp, 0x17, 0x2138);
+			rtl_writephy(tp, 0x0e, 0x0260);
 		} else {
-			mdio_write(ioaddr, 0x17, 0x2108);
-			mdio_write(ioaddr, 0x0e, 0x0000);
+			rtl_writephy(tp, 0x17, 0x2108);
+			rtl_writephy(tp, 0x0e, 0x0000);
 		}
 	}
 
@@ -1381,15 +1392,16 @@ struct phy_reg {
 	u16 val;
 };
 
-static void rtl_phy_write(void __iomem *ioaddr, const struct phy_reg *regs, int len)
+static void rtl_writephy_batch(struct rtl8169_private *tp,
+			       const struct phy_reg *regs, int len)
 {
 	while (len-- > 0) {
-		mdio_write(ioaddr, regs->reg, regs->val);
+		rtl_writephy(tp, regs->reg, regs->val);
 		regs++;
 	}
 }
 
-static void rtl8169s_hw_phy_config(void __iomem *ioaddr)
+static void rtl8169s_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
@@ -1453,10 +1465,10 @@ static void rtl8169s_hw_phy_config(void __iomem *ioaddr)
 		{ 0x00, 0x9200 }
 	};
 
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
-static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
+static void rtl8169sb_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0002 },
@@ -1464,11 +1476,10 @@ static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1f, 0x0000 }
 	};
 
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
-static void rtl8169scd_hw_phy_config_quirk(struct rtl8169_private *tp,
-					   void __iomem *ioaddr)
+static void rtl8169scd_hw_phy_config_quirk(struct rtl8169_private *tp)
 {
 	struct pci_dev *pdev = tp->pci_dev;
 	u16 vendor_id, device_id;
@@ -1479,13 +1490,12 @@ static void rtl8169scd_hw_phy_config_quirk(struct rtl8169_private *tp,
 	if ((vendor_id != PCI_VENDOR_ID_GIGABYTE) || (device_id != 0xe000))
 		return;
 
-	mdio_write(ioaddr, 0x1f, 0x0001);
-	mdio_write(ioaddr, 0x10, 0xf01b);
-	mdio_write(ioaddr, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0001);
+	rtl_writephy(tp, 0x10, 0xf01b);
+	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
-static void rtl8169scd_hw_phy_config(struct rtl8169_private *tp,
-				     void __iomem *ioaddr)
+static void rtl8169scd_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
@@ -1527,12 +1537,12 @@ static void rtl8169scd_hw_phy_config(struct rtl8169_private *tp,
 		{ 0x1f, 0x0000 }
 	};
 
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 
-	rtl8169scd_hw_phy_config_quirk(tp, ioaddr);
+	rtl8169scd_hw_phy_config_quirk(tp);
 }
 
-static void rtl8169sce_hw_phy_config(void __iomem *ioaddr)
+static void rtl8169sce_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
@@ -1582,23 +1592,23 @@ static void rtl8169sce_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1f, 0x0000 }
 	};
 
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
-static void rtl8168bb_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168bb_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x10, 0xf41b },
 		{ 0x1f, 0x0000 }
 	};
 
-	mdio_write(ioaddr, 0x1f, 0x0001);
-	mdio_patch(ioaddr, 0x16, 1 << 0);
+	rtl_writephy(tp, 0x1f, 0x0001);
+	rtl_patchphy(tp, 0x16, 1 << 0);
 
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
-static void rtl8168bef_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168bef_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
@@ -1606,10 +1616,10 @@ static void rtl8168bef_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1f, 0x0000 }
 	};
 
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
-static void rtl8168cp_1_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168cp_1_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0000 },
@@ -1619,10 +1629,10 @@ static void rtl8168cp_1_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1f, 0x0000 }
 	};
 
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
-static void rtl8168cp_2_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168cp_2_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
@@ -1630,14 +1640,14 @@ static void rtl8168cp_2_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1f, 0x0000 }
 	};
 
-	mdio_write(ioaddr, 0x1f, 0x0000);
-	mdio_patch(ioaddr, 0x14, 1 << 5);
-	mdio_patch(ioaddr, 0x0d, 1 << 5);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_patchphy(tp, 0x14, 1 << 5);
+	rtl_patchphy(tp, 0x0d, 1 << 5);
 
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
-static void rtl8168c_1_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168c_1_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
@@ -1659,14 +1669,14 @@ static void rtl8168c_1_hw_phy_config(void __iomem *ioaddr)
 		{ 0x09, 0x0000 }
 	};
 
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 
-	mdio_patch(ioaddr, 0x14, 1 << 5);
-	mdio_patch(ioaddr, 0x0d, 1 << 5);
-	mdio_write(ioaddr, 0x1f, 0x0000);
+	rtl_patchphy(tp, 0x14, 1 << 5);
+	rtl_patchphy(tp, 0x0d, 1 << 5);
+	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
-static void rtl8168c_2_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168c_2_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
@@ -1686,15 +1696,15 @@ static void rtl8168c_2_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1f, 0x0000 }
 	};
 
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 
-	mdio_patch(ioaddr, 0x16, 1 << 0);
-	mdio_patch(ioaddr, 0x14, 1 << 5);
-	mdio_patch(ioaddr, 0x0d, 1 << 5);
-	mdio_write(ioaddr, 0x1f, 0x0000);
+	rtl_patchphy(tp, 0x16, 1 << 0);
+	rtl_patchphy(tp, 0x14, 1 << 5);
+	rtl_patchphy(tp, 0x0d, 1 << 5);
+	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
-static void rtl8168c_3_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168c_3_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
@@ -1708,21 +1718,22 @@ static void rtl8168c_3_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1f, 0x0000 }
 	};
 
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 
-	mdio_patch(ioaddr, 0x16, 1 << 0);
-	mdio_patch(ioaddr, 0x14, 1 << 5);
-	mdio_patch(ioaddr, 0x0d, 1 << 5);
-	mdio_write(ioaddr, 0x1f, 0x0000);
+	rtl_patchphy(tp, 0x16, 1 << 0);
+	rtl_patchphy(tp, 0x14, 1 << 5);
+	rtl_patchphy(tp, 0x0d, 1 << 5);
+	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
-static void rtl8168c_4_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168c_4_hw_phy_config(struct rtl8169_private *tp)
 {
-	rtl8168c_3_hw_phy_config(ioaddr);
+	rtl8168c_3_hw_phy_config(tp);
 }
 
-static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	static const struct phy_reg phy_reg_init_0[] = {
 		/* Channel Estimation */
 		{ 0x1f, 0x0001 },
@@ -2140,15 +2151,15 @@ static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1f, 0x0000 }
 	};
 
-	rtl_phy_write(ioaddr, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
+	rtl_writephy_batch(tp, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
 
 	/*
 	 * Rx Error Issue
 	 * Fine Tune Switching regulator parameter
 	 */
-	mdio_write(ioaddr, 0x1f, 0x0002);
-	mdio_plus_minus(ioaddr, 0x0b, 0x0010, 0x00ef);
-	mdio_plus_minus(ioaddr, 0x0c, 0xa200, 0x5d00);
+	rtl_writephy(tp, 0x1f, 0x0002);
+	rtl_w1w0_phy(tp, 0x0b, 0x0010, 0x00ef);
+	rtl_w1w0_phy(tp, 0x0c, 0xa200, 0x5d00);
 
 	if (rtl8168d_efuse_read(ioaddr, 0x01) == 0xb1) {
 		static const struct phy_reg phy_reg_init[] = {
@@ -2161,9 +2172,9 @@ static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
 		};
 		int val;
 
-		rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+		rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 
-		val = mdio_read(ioaddr, 0x0d);
+		val = rtl_readphy(tp, 0x0d);
 
 		if ((val & 0x00ff) != 0x006c) {
 			static const u32 set[] = {
@@ -2172,11 +2183,11 @@ static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
 			};
 			int i;
 
-			mdio_write(ioaddr, 0x1f, 0x0002);
+			rtl_writephy(tp, 0x1f, 0x0002);
 
 			val &= 0xff00;
 			for (i = 0; i < ARRAY_SIZE(set); i++)
-				mdio_write(ioaddr, 0x0d, val | set[i]);
+				rtl_writephy(tp, 0x0d, val | set[i]);
 		}
 	} else {
 		static const struct phy_reg phy_reg_init[] = {
@@ -2187,28 +2198,28 @@ static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
 			{ 0x06, 0x6662 }
 		};
 
-		rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+		rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 	}
 
 	/* RSET couple improve */
-	mdio_write(ioaddr, 0x1f, 0x0002);
-	mdio_patch(ioaddr, 0x0d, 0x0300);
-	mdio_patch(ioaddr, 0x0f, 0x0010);
+	rtl_writephy(tp, 0x1f, 0x0002);
+	rtl_patchphy(tp, 0x0d, 0x0300);
+	rtl_patchphy(tp, 0x0f, 0x0010);
 
 	/* Fine tune PLL performance */
-	mdio_write(ioaddr, 0x1f, 0x0002);
-	mdio_plus_minus(ioaddr, 0x02, 0x0100, 0x0600);
-	mdio_plus_minus(ioaddr, 0x03, 0x0000, 0xe000);
+	rtl_writephy(tp, 0x1f, 0x0002);
+	rtl_w1w0_phy(tp, 0x02, 0x0100, 0x0600);
+	rtl_w1w0_phy(tp, 0x03, 0x0000, 0xe000);
 
-	mdio_write(ioaddr, 0x1f, 0x0005);
-	mdio_write(ioaddr, 0x05, 0x001b);
-	if (mdio_read(ioaddr, 0x06) == 0xbf00)
-		rtl_phy_write(ioaddr, phy_reg_init_2, ARRAY_SIZE(phy_reg_init_2));
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x001b);
+	if (rtl_readphy(tp, 0x06) == 0xbf00)
+		rtl_writephy_batch(tp, phy_reg_init_2, ARRAY_SIZE(phy_reg_init_2));
 
-	mdio_write(ioaddr, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
-static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168d_2_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init_0[] = {
 		/* Channel Estimation */
@@ -2584,8 +2595,9 @@ static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
 		{ 0x06, 0x00fc },
 		{ 0x1f, 0x0000 }
 	};
+	void __iomem *ioaddr = tp->mmio_addr;
 
-	rtl_phy_write(ioaddr, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
+	rtl_writephy_batch(tp, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
 
 	if (rtl8168d_efuse_read(ioaddr, 0x01) == 0xb1) {
 		static const struct phy_reg phy_reg_init[] = {
@@ -2599,9 +2611,9 @@ static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
 		};
 		int val;
 
-		rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+		rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 
-		val = mdio_read(ioaddr, 0x0d);
+		val = rtl_readphy(tp, 0x0d);
 		if ((val & 0x00ff) != 0x006c) {
 			u32 set[] = {
 				0x0065, 0x0066, 0x0067, 0x0068,
@@ -2609,11 +2621,11 @@ static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
 			};
 			int i;
 
-			mdio_write(ioaddr, 0x1f, 0x0002);
+			rtl_writephy(tp, 0x1f, 0x0002);
 
 			val &= 0xff00;
 			for (i = 0; i < ARRAY_SIZE(set); i++)
-				mdio_write(ioaddr, 0x0d, val | set[i]);
+				rtl_writephy(tp, 0x0d, val | set[i]);
 		}
 	} else {
 		static const struct phy_reg phy_reg_init[] = {
@@ -2624,27 +2636,27 @@ static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
 			{ 0x06, 0x2642 }
 		};
 
-		rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+		rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 	}
 
 	/* Fine tune PLL performance */
-	mdio_write(ioaddr, 0x1f, 0x0002);
-	mdio_plus_minus(ioaddr, 0x02, 0x0100, 0x0600);
-	mdio_plus_minus(ioaddr, 0x03, 0x0000, 0xe000);
+	rtl_writephy(tp, 0x1f, 0x0002);
+	rtl_w1w0_phy(tp, 0x02, 0x0100, 0x0600);
+	rtl_w1w0_phy(tp, 0x03, 0x0000, 0xe000);
 
 	/* Switching regulator Slew rate */
-	mdio_write(ioaddr, 0x1f, 0x0002);
-	mdio_patch(ioaddr, 0x0f, 0x0017);
+	rtl_writephy(tp, 0x1f, 0x0002);
+	rtl_patchphy(tp, 0x0f, 0x0017);
 
-	mdio_write(ioaddr, 0x1f, 0x0005);
-	mdio_write(ioaddr, 0x05, 0x001b);
-	if (mdio_read(ioaddr, 0x06) == 0xb300)
-		rtl_phy_write(ioaddr, phy_reg_init_1, ARRAY_SIZE(phy_reg_init_1));
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x001b);
+	if (rtl_readphy(tp, 0x06) == 0xb300)
+		rtl_writephy_batch(tp, phy_reg_init_1, ARRAY_SIZE(phy_reg_init_1));
 
-	mdio_write(ioaddr, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
-static void rtl8168d_3_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168d_3_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0002 },
@@ -2702,10 +2714,10 @@ static void rtl8168d_3_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1f, 0x0000 }
 	};
 
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
-static void rtl8102e_hw_phy_config(void __iomem *ioaddr)
+static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0003 },
@@ -2714,18 +2726,17 @@ static void rtl8102e_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1f, 0x0000 }
 	};
 
-	mdio_write(ioaddr, 0x1f, 0x0000);
-	mdio_patch(ioaddr, 0x11, 1 << 12);
-	mdio_patch(ioaddr, 0x19, 1 << 13);
-	mdio_patch(ioaddr, 0x10, 1 << 15);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_patchphy(tp, 0x11, 1 << 12);
+	rtl_patchphy(tp, 0x19, 1 << 13);
+	rtl_patchphy(tp, 0x10, 1 << 15);
 
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
 
 	rtl8169_print_mac_version(tp);
 
@@ -2734,58 +2745,58 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		break;
 	case RTL_GIGA_MAC_VER_02:
 	case RTL_GIGA_MAC_VER_03:
-		rtl8169s_hw_phy_config(ioaddr);
+		rtl8169s_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_04:
-		rtl8169sb_hw_phy_config(ioaddr);
+		rtl8169sb_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_05:
-		rtl8169scd_hw_phy_config(tp, ioaddr);
+		rtl8169scd_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_06:
-		rtl8169sce_hw_phy_config(ioaddr);
+		rtl8169sce_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_07:
 	case RTL_GIGA_MAC_VER_08:
 	case RTL_GIGA_MAC_VER_09:
-		rtl8102e_hw_phy_config(ioaddr);
+		rtl8102e_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_11:
-		rtl8168bb_hw_phy_config(ioaddr);
+		rtl8168bb_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_12:
-		rtl8168bef_hw_phy_config(ioaddr);
+		rtl8168bef_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_17:
-		rtl8168bef_hw_phy_config(ioaddr);
+		rtl8168bef_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_18:
-		rtl8168cp_1_hw_phy_config(ioaddr);
+		rtl8168cp_1_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_19:
-		rtl8168c_1_hw_phy_config(ioaddr);
+		rtl8168c_1_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_20:
-		rtl8168c_2_hw_phy_config(ioaddr);
+		rtl8168c_2_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_21:
-		rtl8168c_3_hw_phy_config(ioaddr);
+		rtl8168c_3_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_22:
-		rtl8168c_4_hw_phy_config(ioaddr);
+		rtl8168c_4_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_23:
 	case RTL_GIGA_MAC_VER_24:
-		rtl8168cp_2_hw_phy_config(ioaddr);
+		rtl8168cp_2_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_25:
-		rtl8168d_1_hw_phy_config(ioaddr);
+		rtl8168d_1_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_26:
-		rtl8168d_2_hw_phy_config(ioaddr);
+		rtl8168d_2_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_27:
-		rtl8168d_3_hw_phy_config(ioaddr);
+		rtl8168d_3_hw_phy_config(tp);
 		break;
 
 	default:
@@ -2914,7 +2925,7 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
 		RTL_W8(0x82, 0x01);
 		dprintk("Set PHY Reg 0x0bh = 0x00h\n");
-		mdio_write(ioaddr, 0x0b, 0x0000); //w 0x0b 15 0 0
+		rtl_writephy(tp, 0x0b, 0x0000); //w 0x0b 15 0 0
 	}
 
 	rtl8169_phy_reset(dev, tp);
@@ -2984,11 +2995,11 @@ static int rtl_xmii_ioctl(struct rtl8169_private *tp, struct mii_ioctl_data *dat
 		return 0;
 
 	case SIOCGMIIREG:
-		data->val_out = mdio_read(tp->mmio_addr, data->reg_num & 0x1f);
+		data->val_out = rtl_readphy(tp, data->reg_num & 0x1f);
 		return 0;
 
 	case SIOCSMIIREG:
-		mdio_write(tp->mmio_addr, data->reg_num & 0x1f, data->val_in);
+		rtl_writephy(tp, data->reg_num & 0x1f, data->val_in);
 		return 0;
 	}
 	return -EOPNOTSUPP;
-- 
1.7.3.2


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0004-r8169-8168DP-specific-MII-registers-access-methods.patch"

>From 2fec3ab72680867e74e89c8df86637e4114474ec Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 4 Nov 2010 23:07:46 +0100
Subject: [PATCH 4/9] r8169: 8168DP specific MII registers access methods.

Adapted from version 8.019.00 of Realtek's r8168 driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   83 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 81 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 790d34a..78e3999 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -273,6 +273,20 @@ enum rtl8168_8101_registers {
 #define	EFUSEAR_DATA_MASK		0xff
 };
 
+enum rtl8168_registers {
+	EPHY_RXER_NUM		= 0x7c,
+	OCPDR			= 0xb0,	/* OCP GPHY access */
+#define OCPDR_WRITE_CMD			0x80000000
+#define OCPDR_READ_CMD			0x00000000
+#define OCPDR_REG_MASK			0xff
+#define OCPDR_GPHY_REG_SHIFT		12
+#define OCPDR_DATA_MASK			0xffff
+	OCPAR			= 0xb4,
+#define OCPAR_FLAG			0x80000000
+#define OCPAR_GPHY_WRITE_CMD		0x8000f060
+#define OCPAR_GPHY_READ_CMD		0x0000f060
+};
+
 enum rtl_register_content {
 	/* InterruptStatusBits */
 	SYSErr		= 0x8000,
@@ -496,6 +510,12 @@ struct rtl8169_private {
 #ifdef CONFIG_R8169_VLAN
 	struct vlan_group *vlgrp;
 #endif
+
+	struct mdio_ops {
+		void (*write)(void __iomem *, int, int);
+		int (*read)(void __iomem *, int);
+	} mdio_ops;
+
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
 	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(struct rtl8169_private *tp);
@@ -589,14 +609,55 @@ static int r8169_mdio_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
+static void r8168dp_1_mdio_access(void __iomem *ioaddr, int reg_addr, u32 data)
+{
+	int i;
+
+	RTL_W32(OCPDR, data |
+		((reg_addr & OCPDR_REG_MASK) << OCPDR_GPHY_REG_SHIFT));
+	RTL_W32(OCPAR, OCPAR_GPHY_WRITE_CMD);
+	RTL_W32(EPHY_RXER_NUM, 0);
+
+	for (i = 0; i < 100; i++) {
+		mdelay(1);
+		if (!(RTL_R32(OCPAR) & OCPAR_FLAG))
+			break;
+	}
+}
+
+static void r8168dp_1_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+{
+	r8168dp_1_mdio_access(ioaddr, reg_addr, OCPDR_WRITE_CMD |
+		(value & OCPDR_DATA_MASK));
+}
+
+static int r8168dp_1_mdio_read(void __iomem *ioaddr, int reg_addr)
+{
+	int i;
+
+	r8168dp_1_mdio_access(ioaddr, reg_addr, OCPDR_READ_CMD);
+
+	mdelay(1);
+	RTL_W32(OCPAR, OCPAR_GPHY_READ_CMD);
+	RTL_W32(EPHY_RXER_NUM, 0);
+
+	for (i = 0; i < 100; i++) {
+		mdelay(1);
+		if (RTL_R32(OCPAR) & OCPAR_FLAG)
+			break;
+	}
+
+	return RTL_R32(OCPDR) & OCPDR_DATA_MASK;
+}
+
 static void rtl_writephy(struct rtl8169_private *tp, int location, u32 val)
 {
-	r8169_mdio_write(tp->mmio_addr, location, val);
+	tp->mdio_ops.write(tp->mmio_addr, location, val);
 }
 
 static int rtl_readphy(struct rtl8169_private *tp, int location)
 {
-	return r8169_mdio_read(tp->mmio_addr, location);
+	return tp->mdio_ops.read(tp->mmio_addr, location);
 }
 
 static void rtl_patchphy(struct rtl8169_private *tp, int reg_addr, int value)
@@ -3099,6 +3160,22 @@ static const struct net_device_ops rtl8169_netdev_ops = {
 
 };
 
+static void __devinit rtl_init_mdio_ops(struct rtl8169_private *tp)
+{
+	struct mdio_ops *ops = &tp->mdio_ops;
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_27:
+		ops->write	= r8168dp_1_mdio_write;
+		ops->read	= r8168dp_1_mdio_read;
+		break;
+	default:
+		ops->write	= r8169_mdio_write;
+		ops->read	= r8169_mdio_read;
+		break;
+	}
+}
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -3217,6 +3294,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, ioaddr);
 
+	rtl_init_mdio_ops(tp);
+
 	/* Use appropriate default if unknown */
 	if (tp->mac_version == RTL_GIGA_MAC_NONE) {
 		netif_notice(tp, probe, dev,
-- 
1.7.3.2


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0005-r8169-phy-power-ops.patch"

>From 29f7bb17c47e79e9e55fe86358d2bfab59ae3f5f Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 15 Nov 2010 23:32:55 +0100
Subject: [PATCH 5/9] r8169: phy power ops

Bits from :
- version 8.019.00 of Realtek's 8168 driver
- version 1.019.00 of Realtek's 8101 driver

Plain old 8169 (PCI) devices do not seem to need anything akin to it.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |  167 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 166 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 78e3999..11519c8 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -254,7 +254,7 @@ enum rtl8168_8101_registers {
 #define	CSIAR_BYTE_ENABLE		0x0f
 #define	CSIAR_BYTE_ENABLE_SHIFT		12
 #define	CSIAR_ADDR_MASK			0x0fff
-
+	PMCH			= 0x6f,
 	EPHYAR			= 0x80,
 #define	EPHYAR_FLAG			0x80000000
 #define	EPHYAR_WRITE_CMD		0x80000000
@@ -516,6 +516,11 @@ struct rtl8169_private {
 		int (*read)(void __iomem *, int);
 	} mdio_ops;
 
+	struct pll_power_ops {
+		void (*down)(struct rtl8169_private *);
+		void (*up)(struct rtl8169_private *);
+	} pll_power_ops;
+
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
 	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(struct rtl8169_private *tp);
@@ -3176,6 +3181,152 @@ static void __devinit rtl_init_mdio_ops(struct rtl8169_private *tp)
 	}
 }
 
+static void r810x_phy_power_down(struct rtl8169_private *tp)
+{
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, MII_BMCR, BMCR_PDOWN);
+}
+
+static void r810x_phy_power_up(struct rtl8169_private *tp)
+{
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, MII_BMCR, BMCR_ANENABLE);
+}
+
+static void r810x_pll_power_down(struct rtl8169_private *tp)
+{
+	if (__rtl8169_get_wol(tp) & WAKE_ANY) {
+		rtl_writephy(tp, 0x1f, 0x0000);
+		rtl_writephy(tp, MII_BMCR, 0x0000);
+		return;
+	}
+
+	r810x_phy_power_down(tp);
+}
+
+static void r810x_pll_power_up(struct rtl8169_private *tp)
+{
+	r810x_phy_power_up(tp);
+}
+
+static void r8168_phy_power_up(struct rtl8169_private *tp)
+{
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x0e, 0x0000);
+	rtl_writephy(tp, MII_BMCR, BMCR_ANENABLE);
+}
+
+static void r8168_phy_power_down(struct rtl8169_private *tp)
+{
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x0e, 0x0200);
+	rtl_writephy(tp, MII_BMCR, BMCR_PDOWN);
+}
+
+static void r8168_pll_power_down(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27)
+		return;
+
+	if (((tp->mac_version == RTL_GIGA_MAC_VER_23) ||
+	     (tp->mac_version == RTL_GIGA_MAC_VER_24)) &&
+	    (RTL_R16(CPlusCmd) & ASF)) {
+		return;
+	}
+
+	if (__rtl8169_get_wol(tp) & WAKE_ANY) {
+		rtl_writephy(tp, 0x1f, 0x0000);
+		rtl_writephy(tp, MII_BMCR, 0x0000);
+
+		RTL_W32(RxConfig, RTL_R32(RxConfig) |
+			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
+		return;
+	}
+
+	r8168_phy_power_down(tp);
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_25:
+	case RTL_GIGA_MAC_VER_26:
+		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
+		break;
+	}
+}
+
+static void r8168_pll_power_up(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27)
+		return;
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_25:
+	case RTL_GIGA_MAC_VER_26:
+		RTL_W8(PMCH, RTL_R8(PMCH) | 0x80);
+		break;
+	}
+
+	r8168_phy_power_up(tp);
+}
+
+static void rtl_pll_power_op(struct rtl8169_private *tp,
+			     void (*op)(struct rtl8169_private *))
+{
+	if (op)
+		op(tp);
+}
+
+static void rtl_pll_power_down(struct rtl8169_private *tp)
+{
+	rtl_pll_power_op(tp, tp->pll_power_ops.down);
+}
+
+static void rtl_pll_power_up(struct rtl8169_private *tp)
+{
+	rtl_pll_power_op(tp, tp->pll_power_ops.up);
+}
+
+static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
+{
+	struct pll_power_ops *ops = &tp->pll_power_ops;
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_07:
+	case RTL_GIGA_MAC_VER_08:
+	case RTL_GIGA_MAC_VER_09:
+	case RTL_GIGA_MAC_VER_10:
+	case RTL_GIGA_MAC_VER_16:
+		ops->down	= r810x_pll_power_down;
+		ops->up		= r810x_pll_power_up;
+		break;
+
+	case RTL_GIGA_MAC_VER_11:
+	case RTL_GIGA_MAC_VER_12:
+	case RTL_GIGA_MAC_VER_17:
+	case RTL_GIGA_MAC_VER_18:
+	case RTL_GIGA_MAC_VER_19:
+	case RTL_GIGA_MAC_VER_20:
+	case RTL_GIGA_MAC_VER_21:
+	case RTL_GIGA_MAC_VER_22:
+	case RTL_GIGA_MAC_VER_23:
+	case RTL_GIGA_MAC_VER_24:
+	case RTL_GIGA_MAC_VER_25:
+	case RTL_GIGA_MAC_VER_26:
+	case RTL_GIGA_MAC_VER_27:
+		ops->down	= r8168_pll_power_down;
+		ops->up		= r8168_pll_power_up;
+		break;
+
+	default:
+		ops->down	= NULL;
+		ops->up		= NULL;
+		break;
+	}
+}
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -3295,6 +3446,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	rtl8169_get_mac_version(tp, ioaddr);
 
 	rtl_init_mdio_ops(tp);
+	rtl_init_pll_power_ops(tp);
 
 	/* Use appropriate default if unknown */
 	if (tp->mac_version == RTL_GIGA_MAC_NONE) {
@@ -3474,6 +3626,8 @@ static int rtl8169_open(struct net_device *dev)
 
 	napi_enable(&tp->napi);
 
+	rtl_pll_power_up(tp);
+
 	rtl_hw_start(dev);
 
 	rtl8169_request_timer(dev);
@@ -4882,6 +5036,8 @@ static void rtl8169_down(struct net_device *dev)
 	rtl8169_tx_clear(tp);
 
 	rtl8169_rx_clear(tp);
+
+	rtl_pll_power_down(tp);
 }
 
 static int rtl8169_close(struct net_device *dev)
@@ -4986,9 +5142,13 @@ static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 
 static void rtl8169_net_suspend(struct net_device *dev)
 {
+	struct rtl8169_private *tp = netdev_priv(dev);
+
 	if (!netif_running(dev))
 		return;
 
+	rtl_pll_power_down(tp);
+
 	netif_device_detach(dev);
 	netif_stop_queue(dev);
 }
@@ -5007,7 +5167,12 @@ static int rtl8169_suspend(struct device *device)
 
 static void __rtl8169_resume(struct net_device *dev)
 {
+	struct rtl8169_private *tp = netdev_priv(dev);
+
 	netif_device_attach(dev);
+
+	rtl_pll_power_up(tp);
+
 	rtl8169_schedule_work(dev, rtl8169_reset_task);
 }
 
-- 
1.7.3.2


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0006-r8169-rtl_csi_access_enable-rename.patch"

>From 545d1caeb4f23e0c1df58971a045e81f2359e612 Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 15 Nov 2010 23:41:02 +0100
Subject: [PATCH 6/9] r8169: rtl_csi_access_enable rename.

Newer 8168 needs a slightly different rtl_csi_access_enable.
This patch separates some noise from the real thing.

No functional change.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 11519c8..6ae08d9 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3842,12 +3842,17 @@ static void rtl_tx_performance_tweak(struct pci_dev *pdev, u16 force)
 	}
 }
 
-static void rtl_csi_access_enable(void __iomem *ioaddr)
+static void rtl_csi_access_enable(void __iomem *ioaddr, u32 bits)
 {
 	u32 csi;
 
 	csi = rtl_csi_read(ioaddr, 0x070c) & 0x00ffffff;
-	rtl_csi_write(ioaddr, 0x070c, csi | 0x27000000);
+	rtl_csi_write(ioaddr, 0x070c, csi | bits);
+}
+
+static void rtl_csi_access_enable_2(void __iomem *ioaddr)
+{
+	rtl_csi_access_enable(ioaddr, 0x27000000);
 }
 
 struct ephy_info {
@@ -3935,7 +3940,7 @@ static void rtl_hw_start_8168cp_1(void __iomem *ioaddr, struct pci_dev *pdev)
 		{ 0x07, 0,	0x2000 }
 	};
 
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	rtl_ephy_init(ioaddr, e_info_8168cp, ARRAY_SIZE(e_info_8168cp));
 
@@ -3944,7 +3949,7 @@ static void rtl_hw_start_8168cp_1(void __iomem *ioaddr, struct pci_dev *pdev)
 
 static void rtl_hw_start_8168cp_2(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
@@ -3955,7 +3960,7 @@ static void rtl_hw_start_8168cp_2(void __iomem *ioaddr, struct pci_dev *pdev)
 
 static void rtl_hw_start_8168cp_3(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
@@ -3977,7 +3982,7 @@ static void rtl_hw_start_8168c_1(void __iomem *ioaddr, struct pci_dev *pdev)
 		{ 0x06, 0x0080,	0x0000 }
 	};
 
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	RTL_W8(DBG_REG, 0x06 | FIX_NAK_1 | FIX_NAK_2);
 
@@ -3993,7 +3998,7 @@ static void rtl_hw_start_8168c_2(void __iomem *ioaddr, struct pci_dev *pdev)
 		{ 0x03, 0x0400,	0x0220 }
 	};
 
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	rtl_ephy_init(ioaddr, e_info_8168c_2, ARRAY_SIZE(e_info_8168c_2));
 
@@ -4007,14 +4012,14 @@ static void rtl_hw_start_8168c_3(void __iomem *ioaddr, struct pci_dev *pdev)
 
 static void rtl_hw_start_8168c_4(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	__rtl_hw_start_8168cp(ioaddr, pdev);
 }
 
 static void rtl_hw_start_8168d(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	rtl_disable_clock_request(pdev);
 
@@ -4143,7 +4148,7 @@ static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	};
 	u8 cfg1;
 
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	RTL_W8(DBG_REG, FIX_NAK_1);
 
@@ -4164,7 +4169,7 @@ static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 
 static void rtl_hw_start_8102e_2(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
-- 
1.7.3.2


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0007-r8169-magic.patch"

>From 9bc18cb4015df72e26f7a8df17b418fb593bc135 Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 15 Nov 2010 23:53:26 +0100
Subject: [PATCH 7/9] r8169: magic.

Adapted from version 8.019.00 of Realtek's r8168 driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   93 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 93 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 6ae08d9..949586c 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -274,6 +274,18 @@ enum rtl8168_8101_registers {
 };
 
 enum rtl8168_registers {
+	ERIDR			= 0x70,
+	ERIAR			= 0x74,
+#define ERIAR_FLAG			0x80000000
+#define ERIAR_WRITE_CMD			0x80000000
+#define ERIAR_READ_CMD			0x00000000
+#define ERIAR_ADDR_BYTE_ALIGN		4
+#define ERIAR_EXGMAC			0
+#define ERIAR_MSIX			1
+#define ERIAR_ASF			2
+#define ERIAR_TYPE_SHIFT		16
+#define ERIAR_BYTEEN			0x0f
+#define ERIAR_BYTEEN_SHIFT		12
 	EPHY_RXER_NUM		= 0x7c,
 	OCPDR			= 0xb0,	/* OCP GPHY access */
 #define OCPDR_WRITE_CMD			0x80000000
@@ -566,6 +578,81 @@ static int rtl8169_poll(struct napi_struct *napi, int budget);
 static const unsigned int rtl8169_rx_config =
 	(RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
 
+static u32 ocp_read(struct rtl8169_private *tp, u8 mask, u16 reg)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	int i;
+
+	RTL_W32(OCPAR, ((u32)mask & 0x0f) << 12 | (reg & 0x0fff));
+	for (i = 0; i < 20; i++) {
+		udelay(100);
+		if (RTL_R32(OCPAR) & OCPAR_FLAG)
+			break;
+	}
+	return RTL_R32(OCPDR);
+}
+
+static void ocp_write(struct rtl8169_private *tp, u8 mask, u16 reg, u32 data)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	int i;
+
+	RTL_W32(OCPDR, data);
+	RTL_W32(OCPAR, OCPAR_FLAG | ((u32)mask & 0x0f) << 12 | (reg & 0x0fff));
+	for (i = 0; i < 20; i++) {
+		udelay(100);
+		if ((RTL_R32(OCPAR) & OCPAR_FLAG) == 0)
+			break;
+	}
+}
+
+static void rtl8168_oob_notify(void __iomem *ioaddr, u8 cmd)
+{
+	int i;
+
+	RTL_W8(ERIDR, cmd);
+	RTL_W32(ERIAR, 0x800010e8);
+	msleep(2);
+	for (i = 0; i < 5; i++) {
+		udelay(100);
+		if (!(RTL_R32(ERIDR) & ERIAR_FLAG))
+			break;
+	}
+
+	ocp_write(ioaddr, 0x1, 0x30, 0x00000001);
+}
+
+#define OOB_CMD_RESET		0x00
+#define OOB_CMD_DRIVER_START	0x05
+#define OOB_CMD_DRIVER_STOP	0x06
+
+static void rtl8168_driver_start(struct rtl8169_private *tp)
+{
+	int i;
+
+	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_START);
+
+	for (i = 0; i < 10; i++) {
+		msleep(10);
+		if (ocp_read(tp, 0x0f, 0x0010) & 0x00000800)
+			break;
+	}
+}
+
+static void rtl8168_driver_stop(struct rtl8169_private *tp)
+{
+	int i;
+
+	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_STOP);
+
+	for (i = 0; i < 10; i++) {
+		msleep(10);
+		if ((ocp_read(tp, 0x0f, 0x0010) & 0x00000800) == 0)
+			break;
+	}
+}
+
+
 static void r8169_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
 {
 	int i;
@@ -3538,6 +3625,9 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		   dev->base_addr, dev->dev_addr,
 		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), dev->irq);
 
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27)
+		rtl8168_driver_start(tp);
+
 	rtl8169_init_phy(dev, tp);
 
 	/*
@@ -3573,6 +3663,9 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27)
+		rtl8168_driver_stop(tp);
+
 	flush_scheduled_work();
 
 	unregister_netdev(dev);
-- 
1.7.3.2


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0008-r8169-more-8168dp-support.patch"

>From e3aaef05f2acea88f23ec9498c142eaae7e36689 Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 15 Nov 2010 23:56:27 +0100
Subject: [PATCH 8/9] r8169: more 8168dp support.

Adapted from version 8.019.00 of Realtek's r8168 driver

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |  145 +++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 136 insertions(+), 9 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 949586c..fe93379 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -117,7 +117,8 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_24 = 0x18, // 8168CP
 	RTL_GIGA_MAC_VER_25 = 0x19, // 8168D
 	RTL_GIGA_MAC_VER_26 = 0x1a, // 8168D
-	RTL_GIGA_MAC_VER_27 = 0x1b  // 8168DP
+	RTL_GIGA_MAC_VER_27 = 0x1b, // 8168DP
+	RTL_GIGA_MAC_VER_28 = 0x1c, // 8168DP
 };
 
 #define _R(NAME,MAC,MASK) \
@@ -154,7 +155,8 @@ static const struct {
 	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_24, 0xff7e1880), // PCI-E
 	_R("RTL8168d/8111d",	RTL_GIGA_MAC_VER_25, 0xff7e1880), // PCI-E
 	_R("RTL8168d/8111d",	RTL_GIGA_MAC_VER_26, 0xff7e1880), // PCI-E
-	_R("RTL8168dp/8111dp",	RTL_GIGA_MAC_VER_27, 0xff7e1880)  // PCI-E
+	_R("RTL8168dp/8111dp",	RTL_GIGA_MAC_VER_27, 0xff7e1880), // PCI-E
+	_R("RTL8168dp/8111dp",	RTL_GIGA_MAC_VER_28, 0xff7e1880)  // PCI-E
 };
 #undef _R
 
@@ -297,6 +299,7 @@ enum rtl8168_registers {
 #define OCPAR_FLAG			0x80000000
 #define OCPAR_GPHY_WRITE_CMD		0x8000f060
 #define OCPAR_GPHY_READ_CMD		0x0000f060
+	RDSAR1			= 0xd0	/* 8168c only. Undocumented on 8168dp */
 };
 
 enum rtl_register_content {
@@ -742,6 +745,40 @@ static int r8168dp_1_mdio_read(void __iomem *ioaddr, int reg_addr)
 	return RTL_R32(OCPDR) & OCPDR_DATA_MASK;
 }
 
+#define R8168DP_1_MDIO_ACCESS_BIT	0x00020000
+
+static void r8168dp_2_mdio_start(void __iomem *ioaddr)
+{
+	RTL_W32(0xd0, RTL_R32(0xd0) & ~R8168DP_1_MDIO_ACCESS_BIT);
+}
+
+static void r8168dp_2_mdio_stop(void __iomem *ioaddr)
+{
+	RTL_W32(0xd0, RTL_R32(0xd0) | R8168DP_1_MDIO_ACCESS_BIT);
+}
+
+static void r8168dp_2_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+{
+	r8168dp_2_mdio_start(ioaddr);
+
+	r8169_mdio_write(ioaddr, reg_addr, value);
+
+	r8168dp_2_mdio_stop(ioaddr);
+}
+
+static int r8168dp_2_mdio_read(void __iomem *ioaddr, int reg_addr)
+{
+	int value;
+
+	r8168dp_2_mdio_start(ioaddr);
+
+	value = r8169_mdio_read(ioaddr, reg_addr);
+
+	r8168dp_2_mdio_stop(ioaddr);
+
+	return value;
+}
+
 static void rtl_writephy(struct rtl8169_private *tp, int location, u32 val)
 {
 	tp->mdio_ops.write(tp->mmio_addr, location, val);
@@ -1479,9 +1516,12 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		/* 8168D family. */
 		{ 0x7cf00000, 0x28300000,	RTL_GIGA_MAC_VER_26 },
 		{ 0x7cf00000, 0x28100000,	RTL_GIGA_MAC_VER_25 },
-		{ 0x7c800000, 0x28800000,	RTL_GIGA_MAC_VER_27 },
 		{ 0x7c800000, 0x28000000,	RTL_GIGA_MAC_VER_26 },
 
+		/* 8168DP family. */
+		{ 0x7cf00000, 0x28800000,	RTL_GIGA_MAC_VER_27 },
+		{ 0x7cf00000, 0x28a00000,	RTL_GIGA_MAC_VER_28 },
+
 		/* 8168C family. */
 		{ 0x7cf00000, 0x3cb00000,	RTL_GIGA_MAC_VER_24 },
 		{ 0x7cf00000, 0x3c900000,	RTL_GIGA_MAC_VER_23 },
@@ -2870,6 +2910,22 @@ static void rtl8168d_3_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
+static void rtl8168d_4_hw_phy_config(struct rtl8169_private *tp)
+{
+	static const struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x17, 0x0cc0 },
+
+		{ 0x1f, 0x0007 },
+		{ 0x1e, 0x002d },
+		{ 0x18, 0x0040 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rtl_patchphy(tp, 0x0d, 1 << 5);
+}
+
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -2951,6 +3007,9 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_27:
 		rtl8168d_3_hw_phy_config(tp);
 		break;
+	case RTL_GIGA_MAC_VER_28:
+		rtl8168d_4_hw_phy_config(tp);
+		break;
 
 	default:
 		break;
@@ -3261,6 +3320,10 @@ static void __devinit rtl_init_mdio_ops(struct rtl8169_private *tp)
 		ops->write	= r8168dp_1_mdio_write;
 		ops->read	= r8168dp_1_mdio_read;
 		break;
+	case RTL_GIGA_MAC_VER_28:
+		ops->write	= r8168dp_2_mdio_write;
+		ops->read	= r8168dp_2_mdio_read;
+		break;
 	default:
 		ops->write	= r8169_mdio_write;
 		ops->read	= r8169_mdio_read;
@@ -3403,6 +3466,7 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_25:
 	case RTL_GIGA_MAC_VER_26:
 	case RTL_GIGA_MAC_VER_27:
+	case RTL_GIGA_MAC_VER_28:
 		ops->down	= r8168_pll_power_down;
 		ops->up		= r8168_pll_power_up;
 		break;
@@ -3625,8 +3689,10 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		   dev->base_addr, dev->dev_addr,
 		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), dev->irq);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27)
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_28)) {
 		rtl8168_driver_start(tp);
+	}
 
 	rtl8169_init_phy(dev, tp);
 
@@ -3663,8 +3729,10 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27)
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_28)) {
 		rtl8168_driver_stop(tp);
+	}
 
 	flush_scheduled_work();
 
@@ -3747,11 +3815,19 @@ err_pm_runtime_put:
 	goto out;
 }
 
-static void rtl8169_hw_reset(void __iomem *ioaddr)
+static void rtl8169_hw_reset(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	/* Disable interrupts */
 	rtl8169_irq_mask_and_ack(ioaddr);
 
+	if (tp->mac_version == RTL_GIGA_MAC_VER_28) {
+		while (RTL_R8(TxPoll) & NPQ)
+			udelay(20);
+
+	}
+
 	/* Reset the chipset */
 	RTL_W8(ChipCmd, CmdReset);
 
@@ -3943,6 +4019,11 @@ static void rtl_csi_access_enable(void __iomem *ioaddr, u32 bits)
 	rtl_csi_write(ioaddr, 0x070c, csi | bits);
 }
 
+static void rtl_csi_access_enable_1(void __iomem *ioaddr)
+{
+	rtl_csi_access_enable(ioaddr, 0x17000000);
+}
+
 static void rtl_csi_access_enable_2(void __iomem *ioaddr)
 {
 	rtl_csi_access_enable(ioaddr, 0x27000000);
@@ -3980,6 +4061,21 @@ static void rtl_disable_clock_request(struct pci_dev *pdev)
 	}
 }
 
+static void rtl_enable_clock_request(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct rtl8169_private *tp = netdev_priv(dev);
+	int cap = tp->pcie_cap;
+
+	if (cap) {
+		u16 ctl;
+
+		pci_read_config_word(pdev, cap + PCI_EXP_LNKCTL, &ctl);
+		ctl |= PCI_EXP_LNKCTL_CLKREQ_EN;
+		pci_write_config_word(pdev, cap + PCI_EXP_LNKCTL, ctl);
+	}
+}
+
 #define R8168_CPCMD_QUIRK_MASK (\
 	EnableBist | \
 	Mac_dbgo_oe | \
@@ -4123,6 +4219,32 @@ static void rtl_hw_start_8168d(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
 
+static void rtl_hw_start_8168d_4(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static const struct ephy_info e_info_8168d_4[] = {
+		{ 0x0b, ~0,	0x48 },
+		{ 0x19, 0x20,	0x50 },
+		{ 0x0c, ~0,	0x20 }
+	};
+	int i;
+
+	rtl_csi_access_enable_1(ioaddr);
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	RTL_W8(MaxTxPacketSize, TxPacketMax);
+
+	for (i = 0; i < ARRAY_SIZE(e_info_8168d_4); i++) {
+		const struct ephy_info *e = e_info_8168d_4 + i;
+		u16 w;
+
+		w = rtl_ephy_read(ioaddr, e->offset);
+		rtl_ephy_write(ioaddr, 0x03, (w & e->mask) | e->bits);
+	}
+
+	rtl_enable_clock_request(pdev);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -4200,6 +4322,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		rtl_hw_start_8168d(ioaddr, pdev);
 	break;
 
+	case RTL_GIGA_MAC_VER_28:
+		rtl_hw_start_8168d_4(ioaddr, pdev);
+	break;
+
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
 			dev->name, tp->mac_version);
@@ -4612,7 +4738,7 @@ static void rtl8169_tx_timeout(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	rtl8169_hw_reset(tp->mmio_addr);
+	rtl8169_hw_reset(tp);
 
 	/* Let's wait a bit while any (async) irq lands on */
 	rtl8169_schedule_work(dev, rtl8169_reset_task);
@@ -4770,7 +4896,6 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev = tp->pci_dev;
-	void __iomem *ioaddr = tp->mmio_addr;
 	u16 pci_status, pci_cmd;
 
 	pci_read_config_word(pdev, PCI_COMMAND, &pci_cmd);
@@ -4801,13 +4926,15 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 
 	/* The infamous DAC f*ckup only happens at boot time */
 	if ((tp->cp_cmd & PCIDAC) && !tp->dirty_rx && !tp->cur_rx) {
+		void __iomem *ioaddr = tp->mmio_addr;
+
 		netif_info(tp, intr, dev, "disabling PCI DAC\n");
 		tp->cp_cmd &= ~PCIDAC;
 		RTL_W16(CPlusCmd, tp->cp_cmd);
 		dev->features &= ~NETIF_F_HIGHDMA;
 	}
 
-	rtl8169_hw_reset(ioaddr);
+	rtl8169_hw_reset(tp);
 
 	rtl8169_schedule_work(dev, rtl8169_reinit_task);
 }
-- 
1.7.3.2


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0009-r8169-firmware-isolation-wip.patch"

>From 112e171c1532b2a340f1c9cfc634f0e050efb4b9 Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 29 Nov 2010 23:49:14 +0100
Subject: [PATCH 9/9] r8169: firmware isolation (wip)

Bits from Ben Hutchings. Some bits from me.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c        | 1198 +++++---------------------------------------
 firmware/r8169/8168c_1.h   |   19 +
 firmware/r8169/8168c_2.h   |   17 +
 firmware/r8169/8168c_3.h   |   11 +
 firmware/r8169/8168d_1_0.h |   40 ++
 firmware/r8169/8168d_1_1.h |  376 ++++++++++++++
 firmware/r8169/8168d_2_0.h |   40 ++
 firmware/r8169/8168d_2_1.h |  334 ++++++++++++
 firmware/r8169/8168d_3.h   |   55 ++
 firmware/r8169/8169s.h     |   61 +++
 firmware/r8169/8169scd.h   |   39 ++
 firmware/r8169/8169sce.h   |   47 ++
 firmware/r8169/main.c      |   79 +++
 13 files changed, 1239 insertions(+), 1077 deletions(-)
 create mode 100644 firmware/r8169/8168c_1.h
 create mode 100644 firmware/r8169/8168c_2.h
 create mode 100644 firmware/r8169/8168c_3.h
 create mode 100644 firmware/r8169/8168d_1_0.h
 create mode 100644 firmware/r8169/8168d_1_1.h
 create mode 100644 firmware/r8169/8168d_2_0.h
 create mode 100644 firmware/r8169/8168d_2_1.h
 create mode 100644 firmware/r8169/8168d_3.h
 create mode 100644 firmware/r8169/8169s.h
 create mode 100644 firmware/r8169/8169scd.h
 create mode 100644 firmware/r8169/8169sce.h
 create mode 100644 firmware/r8169/main.c

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index fe93379..f1c5d01 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -24,6 +24,7 @@
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
 #include <linux/pm_runtime.h>
+#include <linux/firmware.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
@@ -1594,71 +1595,36 @@ static void rtl_writephy_batch(struct rtl8169_private *tp,
 	}
 }
 
-static void rtl8169s_hw_phy_config(struct rtl8169_private *tp)
+static int rtl_writephy_fw(struct rtl8169_private *tp, const char * name)
 {
-	static const struct phy_reg phy_reg_init[] = {
-		{ 0x1f, 0x0001 },
-		{ 0x06, 0x006e },
-		{ 0x08, 0x0708 },
-		{ 0x15, 0x4000 },
-		{ 0x18, 0x65c7 },
+	const struct firmware *fw;
+	const __le16 *data;
+	int rc, i;
 
-		{ 0x1f, 0x0001 },
-		{ 0x03, 0x00a1 },
-		{ 0x02, 0x0008 },
-		{ 0x01, 0x0120 },
-		{ 0x00, 0x1000 },
-		{ 0x04, 0x0800 },
-		{ 0x04, 0x0000 },
-
-		{ 0x03, 0xff41 },
-		{ 0x02, 0xdf60 },
-		{ 0x01, 0x0140 },
-		{ 0x00, 0x0077 },
-		{ 0x04, 0x7800 },
-		{ 0x04, 0x7000 },
-
-		{ 0x03, 0x802f },
-		{ 0x02, 0x4f02 },
-		{ 0x01, 0x0409 },
-		{ 0x00, 0xf0f9 },
-		{ 0x04, 0x9800 },
-		{ 0x04, 0x9000 },
-
-		{ 0x03, 0xdf01 },
-		{ 0x02, 0xdf20 },
-		{ 0x01, 0xff95 },
-		{ 0x00, 0xba00 },
-		{ 0x04, 0xa800 },
-		{ 0x04, 0xa000 },
-
-		{ 0x03, 0xff41 },
-		{ 0x02, 0xdf20 },
-		{ 0x01, 0x0140 },
-		{ 0x00, 0x00bb },
-		{ 0x04, 0xb800 },
-		{ 0x04, 0xb000 },
-
-		{ 0x03, 0xdf41 },
-		{ 0x02, 0xdc60 },
-		{ 0x01, 0x6340 },
-		{ 0x00, 0x007d },
-		{ 0x04, 0xd800 },
-		{ 0x04, 0xd000 },
-
-		{ 0x03, 0xdf01 },
-		{ 0x02, 0xdf20 },
-		{ 0x01, 0x100a },
-		{ 0x00, 0xa0ff },
-		{ 0x04, 0xf800 },
-		{ 0x04, 0xf000 },
+	rc = request_firmware(&fw, name, &tp->pci_dev->dev);
+	if (rc < 0) {
+		netif_err(tp, drv, tp->dev, "phy firmware patch failure (%s\n)",
+			  name);
+		goto out;
+	}
 
-		{ 0x1f, 0x0000 },
-		{ 0x0b, 0x0000 },
-		{ 0x00, 0x9200 }
-	};
+	data = (const __le16 *)fw->data;
+	for (i = 0; i < (fw->size / sizeof(struct phy_reg)); i++) {
+		u16 reg = le16_to_cpu(*data++);
+		u16 val = le16_to_cpu(*data++);
 
-	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+		rtl_writephy(tp, reg, val);
+	}
+
+	release_firmware(fw);
+out:
+	return rc;
+}
+
+MODULE_FIRMWARE("rtl8169s_phy.fw");
+static int rtl8169s_hw_phy_config(struct rtl8169_private *tp)
+{
+	return rtl_writephy_fw(tp, "rtl8169s_phy.fw");
 }
 
 static void rtl8169sb_hw_phy_config(struct rtl8169_private *tp)
@@ -1688,104 +1654,24 @@ static void rtl8169scd_hw_phy_config_quirk(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
-static void rtl8169scd_hw_phy_config(struct rtl8169_private *tp)
+MODULE_FIRMWARE("rtl8169scd_phy.fw");
+static int rtl8169scd_hw_phy_config(struct rtl8169_private *tp)
 {
-	static const struct phy_reg phy_reg_init[] = {
-		{ 0x1f, 0x0001 },
-		{ 0x04, 0x0000 },
-		{ 0x03, 0x00a1 },
-		{ 0x02, 0x0008 },
-		{ 0x01, 0x0120 },
-		{ 0x00, 0x1000 },
-		{ 0x04, 0x0800 },
-		{ 0x04, 0x9000 },
-		{ 0x03, 0x802f },
-		{ 0x02, 0x4f02 },
-		{ 0x01, 0x0409 },
-		{ 0x00, 0xf099 },
-		{ 0x04, 0x9800 },
-		{ 0x04, 0xa000 },
-		{ 0x03, 0xdf01 },
-		{ 0x02, 0xdf20 },
-		{ 0x01, 0xff95 },
-		{ 0x00, 0xba00 },
-		{ 0x04, 0xa800 },
-		{ 0x04, 0xf000 },
-		{ 0x03, 0xdf01 },
-		{ 0x02, 0xdf20 },
-		{ 0x01, 0x101a },
-		{ 0x00, 0xa0ff },
-		{ 0x04, 0xf800 },
-		{ 0x04, 0x0000 },
-		{ 0x1f, 0x0000 },
-
-		{ 0x1f, 0x0001 },
-		{ 0x10, 0xf41b },
-		{ 0x14, 0xfb54 },
-		{ 0x18, 0xf5c7 },
-		{ 0x1f, 0x0000 },
-
-		{ 0x1f, 0x0001 },
-		{ 0x17, 0x0cc0 },
-		{ 0x1f, 0x0000 }
-	};
+	int rc;
 
-	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rc = rtl_writephy_fw(tp, "rtl8169scd_phy.fw");
+	if (rc < 0)
+		goto out;
 
 	rtl8169scd_hw_phy_config_quirk(tp);
+out:
+	return rc;
 }
 
-static void rtl8169sce_hw_phy_config(struct rtl8169_private *tp)
+MODULE_FIRMWARE("rtl8169sce_phy.fw");
+static int rtl8169sce_hw_phy_config(struct rtl8169_private *tp)
 {
-	static const struct phy_reg phy_reg_init[] = {
-		{ 0x1f, 0x0001 },
-		{ 0x04, 0x0000 },
-		{ 0x03, 0x00a1 },
-		{ 0x02, 0x0008 },
-		{ 0x01, 0x0120 },
-		{ 0x00, 0x1000 },
-		{ 0x04, 0x0800 },
-		{ 0x04, 0x9000 },
-		{ 0x03, 0x802f },
-		{ 0x02, 0x4f02 },
-		{ 0x01, 0x0409 },
-		{ 0x00, 0xf099 },
-		{ 0x04, 0x9800 },
-		{ 0x04, 0xa000 },
-		{ 0x03, 0xdf01 },
-		{ 0x02, 0xdf20 },
-		{ 0x01, 0xff95 },
-		{ 0x00, 0xba00 },
-		{ 0x04, 0xa800 },
-		{ 0x04, 0xf000 },
-		{ 0x03, 0xdf01 },
-		{ 0x02, 0xdf20 },
-		{ 0x01, 0x101a },
-		{ 0x00, 0xa0ff },
-		{ 0x04, 0xf800 },
-		{ 0x04, 0x0000 },
-		{ 0x1f, 0x0000 },
-
-		{ 0x1f, 0x0001 },
-		{ 0x0b, 0x8480 },
-		{ 0x1f, 0x0000 },
-
-		{ 0x1f, 0x0001 },
-		{ 0x18, 0x67c7 },
-		{ 0x04, 0x2000 },
-		{ 0x03, 0x002f },
-		{ 0x02, 0x4360 },
-		{ 0x01, 0x0109 },
-		{ 0x00, 0x3022 },
-		{ 0x04, 0x2800 },
-		{ 0x1f, 0x0000 },
-
-		{ 0x1f, 0x0001 },
-		{ 0x17, 0x0cc0 },
-		{ 0x1f, 0x0000 }
-	};
-
-	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	return rtl_writephy_fw(tp, "rtl8169sce_phy.fw");
 }
 
 static void rtl8168bb_hw_phy_config(struct rtl8169_private *tp)
@@ -1840,511 +1726,71 @@ static void rtl8168cp_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
-static void rtl8168c_1_hw_phy_config(struct rtl8169_private *tp)
+MODULE_FIRMWARE("rtl8168c_1_phy.fw");
+static int rtl8168c_1_hw_phy_config(struct rtl8169_private *tp)
 {
-	static const struct phy_reg phy_reg_init[] = {
-		{ 0x1f, 0x0001 },
-		{ 0x12, 0x2300 },
-		{ 0x1f, 0x0002 },
-		{ 0x00, 0x88d4 },
-		{ 0x01, 0x82b1 },
-		{ 0x03, 0x7002 },
-		{ 0x08, 0x9e30 },
-		{ 0x09, 0x01f0 },
-		{ 0x0a, 0x5500 },
-		{ 0x0c, 0x00c8 },
-		{ 0x1f, 0x0003 },
-		{ 0x12, 0xc096 },
-		{ 0x16, 0x000a },
-		{ 0x1f, 0x0000 },
-		{ 0x1f, 0x0000 },
-		{ 0x09, 0x2000 },
-		{ 0x09, 0x0000 }
-	};
+	int rc;
 
-	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rc = rtl_writephy_fw(tp, "rtl8168c_1_phy.fw");
+	if (rc < 0)
+		goto out;
 
 	rtl_patchphy(tp, 0x14, 1 << 5);
 	rtl_patchphy(tp, 0x0d, 1 << 5);
 	rtl_writephy(tp, 0x1f, 0x0000);
+out:
+	return rc;
 }
 
-static void rtl8168c_2_hw_phy_config(struct rtl8169_private *tp)
+MODULE_FIRMWARE("rtl8168c_2_phy.fw");
+static int rtl8168c_2_hw_phy_config(struct rtl8169_private *tp)
 {
-	static const struct phy_reg phy_reg_init[] = {
-		{ 0x1f, 0x0001 },
-		{ 0x12, 0x2300 },
-		{ 0x03, 0x802f },
-		{ 0x02, 0x4f02 },
-		{ 0x01, 0x0409 },
-		{ 0x00, 0xf099 },
-		{ 0x04, 0x9800 },
-		{ 0x04, 0x9000 },
-		{ 0x1d, 0x3d98 },
-		{ 0x1f, 0x0002 },
-		{ 0x0c, 0x7eb8 },
-		{ 0x06, 0x0761 },
-		{ 0x1f, 0x0003 },
-		{ 0x16, 0x0f0a },
-		{ 0x1f, 0x0000 }
-	};
+	int rc;
 
-	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rc = rtl_writephy_fw(tp, "rtl8168c_2_phy.fw");
+	if (rc < 0)
+		goto out;
 
 	rtl_patchphy(tp, 0x16, 1 << 0);
 	rtl_patchphy(tp, 0x14, 1 << 5);
 	rtl_patchphy(tp, 0x0d, 1 << 5);
 	rtl_writephy(tp, 0x1f, 0x0000);
+out:
+	return rc;
 }
 
-static void rtl8168c_3_hw_phy_config(struct rtl8169_private *tp)
+MODULE_FIRMWARE("rtl8168c_3_phy.fw");
+static int rtl8168c_3_hw_phy_config(struct rtl8169_private *tp)
 {
-	static const struct phy_reg phy_reg_init[] = {
-		{ 0x1f, 0x0001 },
-		{ 0x12, 0x2300 },
-		{ 0x1d, 0x3d98 },
-		{ 0x1f, 0x0002 },
-		{ 0x0c, 0x7eb8 },
-		{ 0x06, 0x5461 },
-		{ 0x1f, 0x0003 },
-		{ 0x16, 0x0f0a },
-		{ 0x1f, 0x0000 }
-	};
+	int rc;
 
-	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	rc = rtl_writephy_fw(tp, "rtl8168c_3_phy.fw");
+	if (rc < 0)
+		goto out;
 
 	rtl_patchphy(tp, 0x16, 1 << 0);
 	rtl_patchphy(tp, 0x14, 1 << 5);
 	rtl_patchphy(tp, 0x0d, 1 << 5);
 	rtl_writephy(tp, 0x1f, 0x0000);
+out:
+	return rc;
 }
 
-static void rtl8168c_4_hw_phy_config(struct rtl8169_private *tp)
+static int rtl8168c_4_hw_phy_config(struct rtl8169_private *tp)
 {
-	rtl8168c_3_hw_phy_config(tp);
+	return rtl8168c_3_hw_phy_config(tp);
 }
 
-static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
+MODULE_FIRMWARE("rtl8168d_1_0_phy.fw");
+MODULE_FIRMWARE("rtl8168d_1_1_phy.fw");
+static int rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	static const struct phy_reg phy_reg_init_0[] = {
-		/* Channel Estimation */
-		{ 0x1f, 0x0001 },
-		{ 0x06, 0x4064 },
-		{ 0x07, 0x2863 },
-		{ 0x08, 0x059c },
-		{ 0x09, 0x26b4 },
-		{ 0x0a, 0x6a19 },
-		{ 0x0b, 0xdcc8 },
-		{ 0x10, 0xf06d },
-		{ 0x14, 0x7f68 },
-		{ 0x18, 0x7fd9 },
-		{ 0x1c, 0xf0ff },
-		{ 0x1d, 0x3d9c },
-		{ 0x1f, 0x0003 },
-		{ 0x12, 0xf49f },
-		{ 0x13, 0x070b },
-		{ 0x1a, 0x05ad },
-		{ 0x14, 0x94c0 },
-
-		/*
-		 * Tx Error Issue
-		 * enhance line driver power
-		 */
-		{ 0x1f, 0x0002 },
-		{ 0x06, 0x5561 },
-		{ 0x1f, 0x0005 },
-		{ 0x05, 0x8332 },
-		{ 0x06, 0x5561 },
-
-		/*
-		 * Can not link to 1Gbps with bad cable
-		 * Decrease SNR threshold form 21.07dB to 19.04dB
-		 */
-		{ 0x1f, 0x0001 },
-		{ 0x17, 0x0cc0 },
-
-		{ 0x1f, 0x0000 },
-		{ 0x0d, 0xf880 }
-	};
-	static const struct phy_reg phy_reg_init_2[] = {
-		/* Low pass filter & DLY_CAP fine tune from uC */
-		{ 0x1f, 0x0005 },
-		{ 0x05, 0xfff6 },
-		{ 0x06, 0x0080 },
-		{ 0x05, 0x8000 },
-		{ 0x06, 0xf8f9 },
-		{ 0x06, 0xfaef },
-		{ 0x06, 0x59ee },
-		{ 0x06, 0xf8ea },
-		{ 0x06, 0x00ee },
-		{ 0x06, 0xf8eb },
-		{ 0x06, 0x00e0 },
-		{ 0x06, 0xf87c },
-		{ 0x06, 0xe1f8 },
-		{ 0x06, 0x7d59 },
-		{ 0x06, 0x0fef },
-		{ 0x06, 0x0139 },
-		{ 0x06, 0x029e },
-		{ 0x06, 0x06ef },
-		{ 0x06, 0x1039 },
-		{ 0x06, 0x089f },
-		{ 0x06, 0x2aee },
-		{ 0x06, 0xf8ea },
-		{ 0x06, 0x00ee },
-		{ 0x06, 0xf8eb },
-		{ 0x06, 0x01e0 },
-		{ 0x06, 0xf87c },
-		{ 0x06, 0xe1f8 },
-		{ 0x06, 0x7d58 },
-		{ 0x06, 0x409e },
-		{ 0x06, 0x0f39 },
-		{ 0x06, 0x46aa },
-		{ 0x06, 0x0bbf },
-		{ 0x06, 0x8290 },
-		{ 0x06, 0xd682 },
-		{ 0x06, 0x9802 },
-		{ 0x06, 0x014f },
-		{ 0x06, 0xae09 },
-		{ 0x06, 0xbf82 },
-		{ 0x06, 0x98d6 },
-		{ 0x06, 0x82a0 },
-		{ 0x06, 0x0201 },
-		{ 0x06, 0x4fef },
-		{ 0x06, 0x95fe },
-		{ 0x06, 0xfdfc },
-		{ 0x06, 0x05f8 },
-		{ 0x06, 0xf9fa },
-		{ 0x06, 0xeef8 },
-		{ 0x06, 0xea00 },
-		{ 0x06, 0xeef8 },
-		{ 0x06, 0xeb00 },
-		{ 0x06, 0xe2f8 },
-		{ 0x06, 0x7ce3 },
-		{ 0x06, 0xf87d },
-		{ 0x06, 0xa511 },
-		{ 0x06, 0x1112 },
-		{ 0x06, 0xd240 },
-		{ 0x06, 0xd644 },
-		{ 0x06, 0x4402 },
-		{ 0x06, 0x8217 },
-		{ 0x06, 0xd2a0 },
-		{ 0x06, 0xd6aa },
-		{ 0x06, 0xaa02 },
-		{ 0x06, 0x8217 },
-		{ 0x06, 0xae0f },
-		{ 0x06, 0xa544 },
-		{ 0x06, 0x4402 },
-		{ 0x06, 0xae4d },
-		{ 0x06, 0xa5aa },
-		{ 0x06, 0xaa02 },
-		{ 0x06, 0xae47 },
-		{ 0x06, 0xaf82 },
-		{ 0x06, 0x13ee },
-		{ 0x06, 0x834e },
-		{ 0x06, 0x00ee },
-		{ 0x06, 0x834d },
-		{ 0x06, 0x0fee },
-		{ 0x06, 0x834c },
-		{ 0x06, 0x0fee },
-		{ 0x06, 0x834f },
-		{ 0x06, 0x00ee },
-		{ 0x06, 0x8351 },
-		{ 0x06, 0x00ee },
-		{ 0x06, 0x834a },
-		{ 0x06, 0xffee },
-		{ 0x06, 0x834b },
-		{ 0x06, 0xffe0 },
-		{ 0x06, 0x8330 },
-		{ 0x06, 0xe183 },
-		{ 0x06, 0x3158 },
-		{ 0x06, 0xfee4 },
-		{ 0x06, 0xf88a },
-		{ 0x06, 0xe5f8 },
-		{ 0x06, 0x8be0 },
-		{ 0x06, 0x8332 },
-		{ 0x06, 0xe183 },
-		{ 0x06, 0x3359 },
-		{ 0x06, 0x0fe2 },
-		{ 0x06, 0x834d },
-		{ 0x06, 0x0c24 },
-		{ 0x06, 0x5af0 },
-		{ 0x06, 0x1e12 },
-		{ 0x06, 0xe4f8 },
-		{ 0x06, 0x8ce5 },
-		{ 0x06, 0xf88d },
-		{ 0x06, 0xaf82 },
-		{ 0x06, 0x13e0 },
-		{ 0x06, 0x834f },
-		{ 0x06, 0x10e4 },
-		{ 0x06, 0x834f },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x4e78 },
-		{ 0x06, 0x009f },
-		{ 0x06, 0x0ae0 },
-		{ 0x06, 0x834f },
-		{ 0x06, 0xa010 },
-		{ 0x06, 0xa5ee },
-		{ 0x06, 0x834e },
-		{ 0x06, 0x01e0 },
-		{ 0x06, 0x834e },
-		{ 0x06, 0x7805 },
-		{ 0x06, 0x9e9a },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x4e78 },
-		{ 0x06, 0x049e },
-		{ 0x06, 0x10e0 },
-		{ 0x06, 0x834e },
-		{ 0x06, 0x7803 },
-		{ 0x06, 0x9e0f },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x4e78 },
-		{ 0x06, 0x019e },
-		{ 0x06, 0x05ae },
-		{ 0x06, 0x0caf },
-		{ 0x06, 0x81f8 },
-		{ 0x06, 0xaf81 },
-		{ 0x06, 0xa3af },
-		{ 0x06, 0x81dc },
-		{ 0x06, 0xaf82 },
-		{ 0x06, 0x13ee },
-		{ 0x06, 0x8348 },
-		{ 0x06, 0x00ee },
-		{ 0x06, 0x8349 },
-		{ 0x06, 0x00e0 },
-		{ 0x06, 0x8351 },
-		{ 0x06, 0x10e4 },
-		{ 0x06, 0x8351 },
-		{ 0x06, 0x5801 },
-		{ 0x06, 0x9fea },
-		{ 0x06, 0xd000 },
-		{ 0x06, 0xd180 },
-		{ 0x06, 0x1f66 },
-		{ 0x06, 0xe2f8 },
-		{ 0x06, 0xeae3 },
-		{ 0x06, 0xf8eb },
-		{ 0x06, 0x5af8 },
-		{ 0x06, 0x1e20 },
-		{ 0x06, 0xe6f8 },
-		{ 0x06, 0xeae5 },
-		{ 0x06, 0xf8eb },
-		{ 0x06, 0xd302 },
-		{ 0x06, 0xb3fe },
-		{ 0x06, 0xe2f8 },
-		{ 0x06, 0x7cef },
-		{ 0x06, 0x325b },
-		{ 0x06, 0x80e3 },
-		{ 0x06, 0xf87d },
-		{ 0x06, 0x9e03 },
-		{ 0x06, 0x7dff },
-		{ 0x06, 0xff0d },
-		{ 0x06, 0x581c },
-		{ 0x06, 0x551a },
-		{ 0x06, 0x6511 },
-		{ 0x06, 0xa190 },
-		{ 0x06, 0xd3e2 },
-		{ 0x06, 0x8348 },
-		{ 0x06, 0xe383 },
-		{ 0x06, 0x491b },
-		{ 0x06, 0x56ab },
-		{ 0x06, 0x08ef },
-		{ 0x06, 0x56e6 },
-		{ 0x06, 0x8348 },
-		{ 0x06, 0xe783 },
-		{ 0x06, 0x4910 },
-		{ 0x06, 0xd180 },
-		{ 0x06, 0x1f66 },
-		{ 0x06, 0xa004 },
-		{ 0x06, 0xb9e2 },
-		{ 0x06, 0x8348 },
-		{ 0x06, 0xe383 },
-		{ 0x06, 0x49ef },
-		{ 0x06, 0x65e2 },
-		{ 0x06, 0x834a },
-		{ 0x06, 0xe383 },
-		{ 0x06, 0x4b1b },
-		{ 0x06, 0x56aa },
-		{ 0x06, 0x0eef },
-		{ 0x06, 0x56e6 },
-		{ 0x06, 0x834a },
-		{ 0x06, 0xe783 },
-		{ 0x06, 0x4be2 },
-		{ 0x06, 0x834d },
-		{ 0x06, 0xe683 },
-		{ 0x06, 0x4ce0 },
-		{ 0x06, 0x834d },
-		{ 0x06, 0xa000 },
-		{ 0x06, 0x0caf },
-		{ 0x06, 0x81dc },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x4d10 },
-		{ 0x06, 0xe483 },
-		{ 0x06, 0x4dae },
-		{ 0x06, 0x0480 },
-		{ 0x06, 0xe483 },
-		{ 0x06, 0x4de0 },
-		{ 0x06, 0x834e },
-		{ 0x06, 0x7803 },
-		{ 0x06, 0x9e0b },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x4e78 },
-		{ 0x06, 0x049e },
-		{ 0x06, 0x04ee },
-		{ 0x06, 0x834e },
-		{ 0x06, 0x02e0 },
-		{ 0x06, 0x8332 },
-		{ 0x06, 0xe183 },
-		{ 0x06, 0x3359 },
-		{ 0x06, 0x0fe2 },
-		{ 0x06, 0x834d },
-		{ 0x06, 0x0c24 },
-		{ 0x06, 0x5af0 },
-		{ 0x06, 0x1e12 },
-		{ 0x06, 0xe4f8 },
-		{ 0x06, 0x8ce5 },
-		{ 0x06, 0xf88d },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x30e1 },
-		{ 0x06, 0x8331 },
-		{ 0x06, 0x6801 },
-		{ 0x06, 0xe4f8 },
-		{ 0x06, 0x8ae5 },
-		{ 0x06, 0xf88b },
-		{ 0x06, 0xae37 },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4e03 },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x4ce1 },
-		{ 0x06, 0x834d },
-		{ 0x06, 0x1b01 },
-		{ 0x06, 0x9e04 },
-		{ 0x06, 0xaaa1 },
-		{ 0x06, 0xaea8 },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4e04 },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4f00 },
-		{ 0x06, 0xaeab },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x4f78 },
-		{ 0x06, 0x039f },
-		{ 0x06, 0x14ee },
-		{ 0x06, 0x834e },
-		{ 0x06, 0x05d2 },
-		{ 0x06, 0x40d6 },
-		{ 0x06, 0x5554 },
-		{ 0x06, 0x0282 },
-		{ 0x06, 0x17d2 },
-		{ 0x06, 0xa0d6 },
-		{ 0x06, 0xba00 },
-		{ 0x06, 0x0282 },
-		{ 0x06, 0x17fe },
-		{ 0x06, 0xfdfc },
-		{ 0x06, 0x05f8 },
-		{ 0x06, 0xe0f8 },
-		{ 0x06, 0x60e1 },
-		{ 0x06, 0xf861 },
-		{ 0x06, 0x6802 },
-		{ 0x06, 0xe4f8 },
-		{ 0x06, 0x60e5 },
-		{ 0x06, 0xf861 },
-		{ 0x06, 0xe0f8 },
-		{ 0x06, 0x48e1 },
-		{ 0x06, 0xf849 },
-		{ 0x06, 0x580f },
-		{ 0x06, 0x1e02 },
-		{ 0x06, 0xe4f8 },
-		{ 0x06, 0x48e5 },
-		{ 0x06, 0xf849 },
-		{ 0x06, 0xd000 },
-		{ 0x06, 0x0282 },
-		{ 0x06, 0x5bbf },
-		{ 0x06, 0x8350 },
-		{ 0x06, 0xef46 },
-		{ 0x06, 0xdc19 },
-		{ 0x06, 0xddd0 },
-		{ 0x06, 0x0102 },
-		{ 0x06, 0x825b },
-		{ 0x06, 0x0282 },
-		{ 0x06, 0x77e0 },
-		{ 0x06, 0xf860 },
-		{ 0x06, 0xe1f8 },
-		{ 0x06, 0x6158 },
-		{ 0x06, 0xfde4 },
-		{ 0x06, 0xf860 },
-		{ 0x06, 0xe5f8 },
-		{ 0x06, 0x61fc },
-		{ 0x06, 0x04f9 },
-		{ 0x06, 0xfafb },
-		{ 0x06, 0xc6bf },
-		{ 0x06, 0xf840 },
-		{ 0x06, 0xbe83 },
-		{ 0x06, 0x50a0 },
-		{ 0x06, 0x0101 },
-		{ 0x06, 0x071b },
-		{ 0x06, 0x89cf },
-		{ 0x06, 0xd208 },
-		{ 0x06, 0xebdb },
-		{ 0x06, 0x19b2 },
-		{ 0x06, 0xfbff },
-		{ 0x06, 0xfefd },
-		{ 0x06, 0x04f8 },
-		{ 0x06, 0xe0f8 },
-		{ 0x06, 0x48e1 },
-		{ 0x06, 0xf849 },
-		{ 0x06, 0x6808 },
-		{ 0x06, 0xe4f8 },
-		{ 0x06, 0x48e5 },
-		{ 0x06, 0xf849 },
-		{ 0x06, 0x58f7 },
-		{ 0x06, 0xe4f8 },
-		{ 0x06, 0x48e5 },
-		{ 0x06, 0xf849 },
-		{ 0x06, 0xfc04 },
-		{ 0x06, 0x4d20 },
-		{ 0x06, 0x0002 },
-		{ 0x06, 0x4e22 },
-		{ 0x06, 0x0002 },
-		{ 0x06, 0x4ddf },
-		{ 0x06, 0xff01 },
-		{ 0x06, 0x4edd },
-		{ 0x06, 0xff01 },
-		{ 0x06, 0xf8fa },
-		{ 0x06, 0xfbef },
-		{ 0x06, 0x79bf },
-		{ 0x06, 0xf822 },
-		{ 0x06, 0xd819 },
-		{ 0x06, 0xd958 },
-		{ 0x06, 0x849f },
-		{ 0x06, 0x09bf },
-		{ 0x06, 0x82be },
-		{ 0x06, 0xd682 },
-		{ 0x06, 0xc602 },
-		{ 0x06, 0x014f },
-		{ 0x06, 0xef97 },
-		{ 0x06, 0xfffe },
-		{ 0x06, 0xfc05 },
-		{ 0x06, 0x17ff },
-		{ 0x06, 0xfe01 },
-		{ 0x06, 0x1700 },
-		{ 0x06, 0x0102 },
-		{ 0x05, 0x83d8 },
-		{ 0x06, 0x8051 },
-		{ 0x05, 0x83d6 },
-		{ 0x06, 0x82a0 },
-		{ 0x05, 0x83d4 },
-		{ 0x06, 0x8000 },
-		{ 0x02, 0x2010 },
-		{ 0x03, 0xdc00 },
-		{ 0x1f, 0x0000 },
-		{ 0x0b, 0x0600 },
-		{ 0x1f, 0x0005 },
-		{ 0x05, 0xfff6 },
-		{ 0x06, 0x00fc },
-		{ 0x1f, 0x0000 }
-	};
+	int rc;
 
-	rtl_writephy_batch(tp, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
+	rc = rtl_writephy_fw(tp, "rtl8168d_1_0_phy.fw");
+	if (rc < 0)
+		goto out;
 
 	/*
 	 * Rx Error Issue
@@ -2406,391 +1852,27 @@ static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x001b);
-	if (rtl_readphy(tp, 0x06) == 0xbf00)
-		rtl_writephy_batch(tp, phy_reg_init_2, ARRAY_SIZE(phy_reg_init_2));
+	if (rtl_readphy(tp, 0x06) == 0xbf00) {
+		rc = rtl_writephy_fw(tp, "rtl8168d_1_1_phy.fw");
+		if (rc < 0)
+			goto out;
+	}
 
 	rtl_writephy(tp, 0x1f, 0x0000);
+out:
+	return rc;
 }
 
-static void rtl8168d_2_hw_phy_config(struct rtl8169_private *tp)
+MODULE_FIRMWARE("rtl8168d_2_0-phy.fw");
+MODULE_FIRMWARE("rtl8168d_2_1-phy.fw");
+static int rtl8168d_2_hw_phy_config(struct rtl8169_private *tp)
 {
-	static const struct phy_reg phy_reg_init_0[] = {
-		/* Channel Estimation */
-		{ 0x1f, 0x0001 },
-		{ 0x06, 0x4064 },
-		{ 0x07, 0x2863 },
-		{ 0x08, 0x059c },
-		{ 0x09, 0x26b4 },
-		{ 0x0a, 0x6a19 },
-		{ 0x0b, 0xdcc8 },
-		{ 0x10, 0xf06d },
-		{ 0x14, 0x7f68 },
-		{ 0x18, 0x7fd9 },
-		{ 0x1c, 0xf0ff },
-		{ 0x1d, 0x3d9c },
-		{ 0x1f, 0x0003 },
-		{ 0x12, 0xf49f },
-		{ 0x13, 0x070b },
-		{ 0x1a, 0x05ad },
-		{ 0x14, 0x94c0 },
-
-		/*
-		 * Tx Error Issue
-		 * enhance line driver power
-		 */
-		{ 0x1f, 0x0002 },
-		{ 0x06, 0x5561 },
-		{ 0x1f, 0x0005 },
-		{ 0x05, 0x8332 },
-		{ 0x06, 0x5561 },
-
-		/*
-		 * Can not link to 1Gbps with bad cable
-		 * Decrease SNR threshold form 21.07dB to 19.04dB
-		 */
-		{ 0x1f, 0x0001 },
-		{ 0x17, 0x0cc0 },
-
-		{ 0x1f, 0x0000 },
-		{ 0x0d, 0xf880 }
-	};
-	static const struct phy_reg phy_reg_init_1[] = {
-		/* Low pass filter & DLY_CAP fine tune from uC */
-		{ 0x1f, 0x0005 },
-		{ 0x05, 0xfff6 },
-		{ 0x06, 0x0080 },
-		{ 0x05, 0x8000 },
-		{ 0x06, 0xf8f9 },
-		{ 0x06, 0xfaee },
-		{ 0x06, 0xf8ea },
-		{ 0x06, 0x00ee },
-		{ 0x06, 0xf8eb },
-		{ 0x06, 0x00e2 },
-		{ 0x06, 0xf87c },
-		{ 0x06, 0xe3f8 },
-		{ 0x06, 0x7da5 },
-		{ 0x06, 0x1111 },
-		{ 0x06, 0x12d2 },
-		{ 0x06, 0x40d6 },
-		{ 0x06, 0x4444 },
-		{ 0x06, 0x0281 },
-		{ 0x06, 0xc6d2 },
-		{ 0x06, 0xa0d6 },
-		{ 0x06, 0xaaaa },
-		{ 0x06, 0x0281 },
-		{ 0x06, 0xc6ae },
-		{ 0x06, 0x0fa5 },
-		{ 0x06, 0x4444 },
-		{ 0x06, 0x02ae },
-		{ 0x06, 0x4da5 },
-		{ 0x06, 0xaaaa },
-		{ 0x06, 0x02ae },
-		{ 0x06, 0x47af },
-		{ 0x06, 0x81c2 },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4e00 },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4d0f },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4c0f },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4f00 },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x5100 },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4aff },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4bff },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x30e1 },
-		{ 0x06, 0x8331 },
-		{ 0x06, 0x58fe },
-		{ 0x06, 0xe4f8 },
-		{ 0x06, 0x8ae5 },
-		{ 0x06, 0xf88b },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x32e1 },
-		{ 0x06, 0x8333 },
-		{ 0x06, 0x590f },
-		{ 0x06, 0xe283 },
-		{ 0x06, 0x4d0c },
-		{ 0x06, 0x245a },
-		{ 0x06, 0xf01e },
-		{ 0x06, 0x12e4 },
-		{ 0x06, 0xf88c },
-		{ 0x06, 0xe5f8 },
-		{ 0x06, 0x8daf },
-		{ 0x06, 0x81c2 },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x4f10 },
-		{ 0x06, 0xe483 },
-		{ 0x06, 0x4fe0 },
-		{ 0x06, 0x834e },
-		{ 0x06, 0x7800 },
-		{ 0x06, 0x9f0a },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x4fa0 },
-		{ 0x06, 0x10a5 },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4e01 },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x4e78 },
-		{ 0x06, 0x059e },
-		{ 0x06, 0x9ae0 },
-		{ 0x06, 0x834e },
-		{ 0x06, 0x7804 },
-		{ 0x06, 0x9e10 },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x4e78 },
-		{ 0x06, 0x039e },
-		{ 0x06, 0x0fe0 },
-		{ 0x06, 0x834e },
-		{ 0x06, 0x7801 },
-		{ 0x06, 0x9e05 },
-		{ 0x06, 0xae0c },
-		{ 0x06, 0xaf81 },
-		{ 0x06, 0xa7af },
-		{ 0x06, 0x8152 },
-		{ 0x06, 0xaf81 },
-		{ 0x06, 0x8baf },
-		{ 0x06, 0x81c2 },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4800 },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4900 },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x5110 },
-		{ 0x06, 0xe483 },
-		{ 0x06, 0x5158 },
-		{ 0x06, 0x019f },
-		{ 0x06, 0xead0 },
-		{ 0x06, 0x00d1 },
-		{ 0x06, 0x801f },
-		{ 0x06, 0x66e2 },
-		{ 0x06, 0xf8ea },
-		{ 0x06, 0xe3f8 },
-		{ 0x06, 0xeb5a },
-		{ 0x06, 0xf81e },
-		{ 0x06, 0x20e6 },
-		{ 0x06, 0xf8ea },
-		{ 0x06, 0xe5f8 },
-		{ 0x06, 0xebd3 },
-		{ 0x06, 0x02b3 },
-		{ 0x06, 0xfee2 },
-		{ 0x06, 0xf87c },
-		{ 0x06, 0xef32 },
-		{ 0x06, 0x5b80 },
-		{ 0x06, 0xe3f8 },
-		{ 0x06, 0x7d9e },
-		{ 0x06, 0x037d },
-		{ 0x06, 0xffff },
-		{ 0x06, 0x0d58 },
-		{ 0x06, 0x1c55 },
-		{ 0x06, 0x1a65 },
-		{ 0x06, 0x11a1 },
-		{ 0x06, 0x90d3 },
-		{ 0x06, 0xe283 },
-		{ 0x06, 0x48e3 },
-		{ 0x06, 0x8349 },
-		{ 0x06, 0x1b56 },
-		{ 0x06, 0xab08 },
-		{ 0x06, 0xef56 },
-		{ 0x06, 0xe683 },
-		{ 0x06, 0x48e7 },
-		{ 0x06, 0x8349 },
-		{ 0x06, 0x10d1 },
-		{ 0x06, 0x801f },
-		{ 0x06, 0x66a0 },
-		{ 0x06, 0x04b9 },
-		{ 0x06, 0xe283 },
-		{ 0x06, 0x48e3 },
-		{ 0x06, 0x8349 },
-		{ 0x06, 0xef65 },
-		{ 0x06, 0xe283 },
-		{ 0x06, 0x4ae3 },
-		{ 0x06, 0x834b },
-		{ 0x06, 0x1b56 },
-		{ 0x06, 0xaa0e },
-		{ 0x06, 0xef56 },
-		{ 0x06, 0xe683 },
-		{ 0x06, 0x4ae7 },
-		{ 0x06, 0x834b },
-		{ 0x06, 0xe283 },
-		{ 0x06, 0x4de6 },
-		{ 0x06, 0x834c },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x4da0 },
-		{ 0x06, 0x000c },
-		{ 0x06, 0xaf81 },
-		{ 0x06, 0x8be0 },
-		{ 0x06, 0x834d },
-		{ 0x06, 0x10e4 },
-		{ 0x06, 0x834d },
-		{ 0x06, 0xae04 },
-		{ 0x06, 0x80e4 },
-		{ 0x06, 0x834d },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x4e78 },
-		{ 0x06, 0x039e },
-		{ 0x06, 0x0be0 },
-		{ 0x06, 0x834e },
-		{ 0x06, 0x7804 },
-		{ 0x06, 0x9e04 },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4e02 },
-		{ 0x06, 0xe083 },
-		{ 0x06, 0x32e1 },
-		{ 0x06, 0x8333 },
-		{ 0x06, 0x590f },
-		{ 0x06, 0xe283 },
-		{ 0x06, 0x4d0c },
-		{ 0x06, 0x245a },
-		{ 0x06, 0xf01e },
-		{ 0x06, 0x12e4 },
-		{ 0x06, 0xf88c },
-		{ 0x06, 0xe5f8 },
-		{ 0x06, 0x8de0 },
-		{ 0x06, 0x8330 },
-		{ 0x06, 0xe183 },
-		{ 0x06, 0x3168 },
-		{ 0x06, 0x01e4 },
-		{ 0x06, 0xf88a },
-		{ 0x06, 0xe5f8 },
-		{ 0x06, 0x8bae },
-		{ 0x06, 0x37ee },
-		{ 0x06, 0x834e },
-		{ 0x06, 0x03e0 },
-		{ 0x06, 0x834c },
-		{ 0x06, 0xe183 },
-		{ 0x06, 0x4d1b },
-		{ 0x06, 0x019e },
-		{ 0x06, 0x04aa },
-		{ 0x06, 0xa1ae },
-		{ 0x06, 0xa8ee },
-		{ 0x06, 0x834e },
-		{ 0x06, 0x04ee },
-		{ 0x06, 0x834f },
-		{ 0x06, 0x00ae },
-		{ 0x06, 0xabe0 },
-		{ 0x06, 0x834f },
-		{ 0x06, 0x7803 },
-		{ 0x06, 0x9f14 },
-		{ 0x06, 0xee83 },
-		{ 0x06, 0x4e05 },
-		{ 0x06, 0xd240 },
-		{ 0x06, 0xd655 },
-		{ 0x06, 0x5402 },
-		{ 0x06, 0x81c6 },
-		{ 0x06, 0xd2a0 },
-		{ 0x06, 0xd6ba },
-		{ 0x06, 0x0002 },
-		{ 0x06, 0x81c6 },
-		{ 0x06, 0xfefd },
-		{ 0x06, 0xfc05 },
-		{ 0x06, 0xf8e0 },
-		{ 0x06, 0xf860 },
-		{ 0x06, 0xe1f8 },
-		{ 0x06, 0x6168 },
-		{ 0x06, 0x02e4 },
-		{ 0x06, 0xf860 },
-		{ 0x06, 0xe5f8 },
-		{ 0x06, 0x61e0 },
-		{ 0x06, 0xf848 },
-		{ 0x06, 0xe1f8 },
-		{ 0x06, 0x4958 },
-		{ 0x06, 0x0f1e },
-		{ 0x06, 0x02e4 },
-		{ 0x06, 0xf848 },
-		{ 0x06, 0xe5f8 },
-		{ 0x06, 0x49d0 },
-		{ 0x06, 0x0002 },
-		{ 0x06, 0x820a },
-		{ 0x06, 0xbf83 },
-		{ 0x06, 0x50ef },
-		{ 0x06, 0x46dc },
-		{ 0x06, 0x19dd },
-		{ 0x06, 0xd001 },
-		{ 0x06, 0x0282 },
-		{ 0x06, 0x0a02 },
-		{ 0x06, 0x8226 },
-		{ 0x06, 0xe0f8 },
-		{ 0x06, 0x60e1 },
-		{ 0x06, 0xf861 },
-		{ 0x06, 0x58fd },
-		{ 0x06, 0xe4f8 },
-		{ 0x06, 0x60e5 },
-		{ 0x06, 0xf861 },
-		{ 0x06, 0xfc04 },
-		{ 0x06, 0xf9fa },
-		{ 0x06, 0xfbc6 },
-		{ 0x06, 0xbff8 },
-		{ 0x06, 0x40be },
-		{ 0x06, 0x8350 },
-		{ 0x06, 0xa001 },
-		{ 0x06, 0x0107 },
-		{ 0x06, 0x1b89 },
-		{ 0x06, 0xcfd2 },
-		{ 0x06, 0x08eb },
-		{ 0x06, 0xdb19 },
-		{ 0x06, 0xb2fb },
-		{ 0x06, 0xfffe },
-		{ 0x06, 0xfd04 },
-		{ 0x06, 0xf8e0 },
-		{ 0x06, 0xf848 },
-		{ 0x06, 0xe1f8 },
-		{ 0x06, 0x4968 },
-		{ 0x06, 0x08e4 },
-		{ 0x06, 0xf848 },
-		{ 0x06, 0xe5f8 },
-		{ 0x06, 0x4958 },
-		{ 0x06, 0xf7e4 },
-		{ 0x06, 0xf848 },
-		{ 0x06, 0xe5f8 },
-		{ 0x06, 0x49fc },
-		{ 0x06, 0x044d },
-		{ 0x06, 0x2000 },
-		{ 0x06, 0x024e },
-		{ 0x06, 0x2200 },
-		{ 0x06, 0x024d },
-		{ 0x06, 0xdfff },
-		{ 0x06, 0x014e },
-		{ 0x06, 0xddff },
-		{ 0x06, 0x01f8 },
-		{ 0x06, 0xfafb },
-		{ 0x06, 0xef79 },
-		{ 0x06, 0xbff8 },
-		{ 0x06, 0x22d8 },
-		{ 0x06, 0x19d9 },
-		{ 0x06, 0x5884 },
-		{ 0x06, 0x9f09 },
-		{ 0x06, 0xbf82 },
-		{ 0x06, 0x6dd6 },
-		{ 0x06, 0x8275 },
-		{ 0x06, 0x0201 },
-		{ 0x06, 0x4fef },
-		{ 0x06, 0x97ff },
-		{ 0x06, 0xfefc },
-		{ 0x06, 0x0517 },
-		{ 0x06, 0xfffe },
-		{ 0x06, 0x0117 },
-		{ 0x06, 0x0001 },
-		{ 0x06, 0x0200 },
-		{ 0x05, 0x83d8 },
-		{ 0x06, 0x8000 },
-		{ 0x05, 0x83d6 },
-		{ 0x06, 0x824f },
-		{ 0x02, 0x2010 },
-		{ 0x03, 0xdc00 },
-		{ 0x1f, 0x0000 },
-		{ 0x0b, 0x0600 },
-		{ 0x1f, 0x0005 },
-		{ 0x05, 0xfff6 },
-		{ 0x06, 0x00fc },
-		{ 0x1f, 0x0000 }
-	};
 	void __iomem *ioaddr = tp->mmio_addr;
+	int rc;
 
-	rtl_writephy_batch(tp, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
+	rc = rtl_writephy_fw(tp, "rtl8168d_2_0-phy.fw");
+	if (rc < 0)
+		goto out;
 
 	if (rtl8168d_efuse_read(ioaddr, 0x01) == 0xb1) {
 		static const struct phy_reg phy_reg_init[] = {
@@ -2843,71 +1925,21 @@ static void rtl8168d_2_hw_phy_config(struct rtl8169_private *tp)
 
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x001b);
-	if (rtl_readphy(tp, 0x06) == 0xb300)
-		rtl_writephy_batch(tp, phy_reg_init_1, ARRAY_SIZE(phy_reg_init_1));
+	if (rtl_readphy(tp, 0x06) == 0xb300) {
+		rc = rtl_writephy_fw(tp, "rtl8168d_2_1_phy.fw");
+		if (rc < 0)
+			goto out;
+	}
 
 	rtl_writephy(tp, 0x1f, 0x0000);
+out:
+	return rc;
 }
 
-static void rtl8168d_3_hw_phy_config(struct rtl8169_private *tp)
+MODULE_FIRMWARE("rtl8168d_3_phy.fw");
+static int rtl8168d_3_hw_phy_config(struct rtl8169_private *tp)
 {
-	static const struct phy_reg phy_reg_init[] = {
-		{ 0x1f, 0x0002 },
-		{ 0x10, 0x0008 },
-		{ 0x0d, 0x006c },
-
-		{ 0x1f, 0x0000 },
-		{ 0x0d, 0xf880 },
-
-		{ 0x1f, 0x0001 },
-		{ 0x17, 0x0cc0 },
-
-		{ 0x1f, 0x0001 },
-		{ 0x0b, 0xa4d8 },
-		{ 0x09, 0x281c },
-		{ 0x07, 0x2883 },
-		{ 0x0a, 0x6b35 },
-		{ 0x1d, 0x3da4 },
-		{ 0x1c, 0xeffd },
-		{ 0x14, 0x7f52 },
-		{ 0x18, 0x7fc6 },
-		{ 0x08, 0x0601 },
-		{ 0x06, 0x4063 },
-		{ 0x10, 0xf074 },
-		{ 0x1f, 0x0003 },
-		{ 0x13, 0x0789 },
-		{ 0x12, 0xf4bd },
-		{ 0x1a, 0x04fd },
-		{ 0x14, 0x84b0 },
-		{ 0x1f, 0x0000 },
-		{ 0x00, 0x9200 },
-
-		{ 0x1f, 0x0005 },
-		{ 0x01, 0x0340 },
-		{ 0x1f, 0x0001 },
-		{ 0x04, 0x4000 },
-		{ 0x03, 0x1d21 },
-		{ 0x02, 0x0c32 },
-		{ 0x01, 0x0200 },
-		{ 0x00, 0x5554 },
-		{ 0x04, 0x4800 },
-		{ 0x04, 0x4000 },
-		{ 0x04, 0xf000 },
-		{ 0x03, 0xdf01 },
-		{ 0x02, 0xdf20 },
-		{ 0x01, 0x101a },
-		{ 0x00, 0xa0ff },
-		{ 0x04, 0xf800 },
-		{ 0x04, 0xf000 },
-		{ 0x1f, 0x0000 },
-
-		{ 0x1f, 0x0007 },
-		{ 0x1e, 0x0023 },
-		{ 0x16, 0x0000 },
-		{ 0x1f, 0x0000 }
-	};
-
-	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	return rtl_writephy_fw(tp, "rtl8168d_3_phy.fw");
 }
 
 static void rtl8168d_4_hw_phy_config(struct rtl8169_private *tp)
@@ -2943,9 +1975,10 @@ static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
-static void rtl_hw_phy_config(struct net_device *dev)
+static int rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	int rc = 0;
 
 	rtl8169_print_mac_version(tp);
 
@@ -2954,16 +1987,16 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		break;
 	case RTL_GIGA_MAC_VER_02:
 	case RTL_GIGA_MAC_VER_03:
-		rtl8169s_hw_phy_config(tp);
+		rc = rtl8169s_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_04:
 		rtl8169sb_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_05:
-		rtl8169scd_hw_phy_config(tp);
+		rc = rtl8169scd_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_06:
-		rtl8169sce_hw_phy_config(tp);
+		rc = rtl8169sce_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_07:
 	case RTL_GIGA_MAC_VER_08:
@@ -2983,29 +2016,29 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8168cp_1_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_19:
-		rtl8168c_1_hw_phy_config(tp);
+		rc = rtl8168c_1_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_20:
-		rtl8168c_2_hw_phy_config(tp);
+		rc = rtl8168c_2_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_21:
-		rtl8168c_3_hw_phy_config(tp);
+		rc = rtl8168c_3_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_22:
-		rtl8168c_4_hw_phy_config(tp);
+		rc = rtl8168c_4_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_23:
 	case RTL_GIGA_MAC_VER_24:
 		rtl8168cp_2_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_25:
-		rtl8168d_1_hw_phy_config(tp);
+		rc = rtl8168d_1_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_26:
-		rtl8168d_2_hw_phy_config(tp);
+		rc = rtl8168d_2_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_27:
-		rtl8168d_3_hw_phy_config(tp);
+		rc = rtl8168d_3_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_28:
 		rtl8168d_4_hw_phy_config(tp);
@@ -3014,6 +2047,8 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	default:
 		break;
 	}
+
+	return rc;
 }
 
 static void rtl8169_phy_timer(unsigned long __opaque)
@@ -3117,11 +2152,14 @@ static void rtl8169_phy_reset(struct net_device *dev,
 	netif_err(tp, link, dev, "PHY reset failed\n");
 }
 
-static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
+static int rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
+	int rc;
 
-	rtl_hw_phy_config(dev);
+	rc = rtl_hw_phy_config(dev);
+	if (rc < 0)
+		goto out;
 
 	if (tp->mac_version <= RTL_GIGA_MAC_VER_06) {
 		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
@@ -3150,6 +2188,8 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 
 	if (RTL_R8(PHYstatus) & TBI_Enable)
 		netif_info(tp, link, dev, "TBI auto-negotiating\n");
+out:
+	return rc;
 }
 
 static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
@@ -3694,7 +2734,9 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		rtl8168_driver_start(tp);
 	}
 
-	rtl8169_init_phy(dev, tp);
+	rc = rtl8169_init_phy(dev, tp);
+	if (rc < 0)
+		goto err_out_unregister_5;
 
 	/*
 	 * Pretend we are using VLANs; This bypasses a nasty bug where
@@ -3711,6 +2753,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 out:
 	return rc;
 
+err_out_unregister_5:
+	unregister_netdev(dev);
 err_out_msi_4:
 	rtl_disable_msi(pdev, tp);
 	iounmap(ioaddr);
diff --git a/firmware/r8169/8168c_1.h b/firmware/r8169/8168c_1.h
new file mode 100644
index 0000000..d944a85
--- /dev/null
+++ b/firmware/r8169/8168c_1.h
@@ -0,0 +1,19 @@
+static const struct phy_reg phy_reg_init_8168c_1[] = {
+	{ 0x1f, 0x0001 },
+	{ 0x12, 0x2300 },
+	{ 0x1f, 0x0002 },
+	{ 0x00, 0x88d4 },
+	{ 0x01, 0x82b1 },
+	{ 0x03, 0x7002 },
+	{ 0x08, 0x9e30 },
+	{ 0x09, 0x01f0 },
+	{ 0x0a, 0x5500 },
+	{ 0x0c, 0x00c8 },
+	{ 0x1f, 0x0003 },
+	{ 0x12, 0xc096 },
+	{ 0x16, 0x000a },
+	{ 0x1f, 0x0000 },
+	{ 0x1f, 0x0000 },
+	{ 0x09, 0x2000 },
+	{ 0x09, 0x0000 }
+};
diff --git a/firmware/r8169/8168c_2.h b/firmware/r8169/8168c_2.h
new file mode 100644
index 0000000..36e487e
--- /dev/null
+++ b/firmware/r8169/8168c_2.h
@@ -0,0 +1,17 @@
+static const struct phy_reg phy_reg_init_8168c_2[] = {
+	{ 0x1f, 0x0001 },
+	{ 0x12, 0x2300 },
+	{ 0x03, 0x802f },
+	{ 0x02, 0x4f02 },
+	{ 0x01, 0x0409 },
+	{ 0x00, 0xf099 },
+	{ 0x04, 0x9800 },
+	{ 0x04, 0x9000 },
+	{ 0x1d, 0x3d98 },
+	{ 0x1f, 0x0002 },
+	{ 0x0c, 0x7eb8 },
+	{ 0x06, 0x0761 },
+	{ 0x1f, 0x0003 },
+	{ 0x16, 0x0f0a },
+	{ 0x1f, 0x0000 }
+};
diff --git a/firmware/r8169/8168c_3.h b/firmware/r8169/8168c_3.h
new file mode 100644
index 0000000..83f13f7
--- /dev/null
+++ b/firmware/r8169/8168c_3.h
@@ -0,0 +1,11 @@
+static const struct phy_reg phy_reg_init_8168c_3[] = {
+	{ 0x1f, 0x0001 },
+	{ 0x12, 0x2300 },
+	{ 0x1d, 0x3d98 },
+	{ 0x1f, 0x0002 },
+	{ 0x0c, 0x7eb8 },
+	{ 0x06, 0x5461 },
+	{ 0x1f, 0x0003 },
+	{ 0x16, 0x0f0a },
+	{ 0x1f, 0x0000 }
+};
diff --git a/firmware/r8169/8168d_1_0.h b/firmware/r8169/8168d_1_0.h
new file mode 100644
index 0000000..2177a92
--- /dev/null
+++ b/firmware/r8169/8168d_1_0.h
@@ -0,0 +1,40 @@
+static const struct phy_reg phy_reg_init_8168d_1_0[] = {
+	/* Channel Estimation */
+	{ 0x1f, 0x0001 },
+	{ 0x06, 0x4064 },
+	{ 0x07, 0x2863 },
+	{ 0x08, 0x059c },
+	{ 0x09, 0x26b4 },
+	{ 0x0a, 0x6a19 },
+	{ 0x0b, 0xdcc8 },
+	{ 0x10, 0xf06d },
+	{ 0x14, 0x7f68 },
+	{ 0x18, 0x7fd9 },
+	{ 0x1c, 0xf0ff },
+	{ 0x1d, 0x3d9c },
+	{ 0x1f, 0x0003 },
+	{ 0x12, 0xf49f },
+	{ 0x13, 0x070b },
+	{ 0x1a, 0x05ad },
+	{ 0x14, 0x94c0 },
+
+	/*
+	 * Tx Error Issue
+	 * enhance line driver power
+	 */
+	{ 0x1f, 0x0002 },
+	{ 0x06, 0x5561 },
+	{ 0x1f, 0x0005 },
+	{ 0x05, 0x8332 },
+	{ 0x06, 0x5561 },
+
+	/*
+	 * Can not link to 1Gbps with bad cable
+	 * Decrease SNR threshold form 21.07dB to 19.04dB
+	 */
+	{ 0x1f, 0x0001 },
+	{ 0x17, 0x0cc0 },
+
+	{ 0x1f, 0x0000 },
+	{ 0x0d, 0xf880 }
+};
diff --git a/firmware/r8169/8168d_1_1.h b/firmware/r8169/8168d_1_1.h
new file mode 100644
index 0000000..cc20cb2
--- /dev/null
+++ b/firmware/r8169/8168d_1_1.h
@@ -0,0 +1,376 @@
+static const struct phy_reg phy_reg_init_8168d_1_1[] = {
+	/* Low pass filter & DLY_CAP fine tune from uC */
+	{ 0x1f, 0x0005 },
+	{ 0x05, 0xfff6 },
+	{ 0x06, 0x0080 },
+	{ 0x05, 0x8000 },
+	{ 0x06, 0xf8f9 },
+	{ 0x06, 0xfaef },
+	{ 0x06, 0x59ee },
+	{ 0x06, 0xf8ea },
+	{ 0x06, 0x00ee },
+	{ 0x06, 0xf8eb },
+	{ 0x06, 0x00e0 },
+	{ 0x06, 0xf87c },
+	{ 0x06, 0xe1f8 },
+	{ 0x06, 0x7d59 },
+	{ 0x06, 0x0fef },
+	{ 0x06, 0x0139 },
+	{ 0x06, 0x029e },
+	{ 0x06, 0x06ef },
+	{ 0x06, 0x1039 },
+	{ 0x06, 0x089f },
+	{ 0x06, 0x2aee },
+	{ 0x06, 0xf8ea },
+	{ 0x06, 0x00ee },
+	{ 0x06, 0xf8eb },
+	{ 0x06, 0x01e0 },
+	{ 0x06, 0xf87c },
+	{ 0x06, 0xe1f8 },
+	{ 0x06, 0x7d58 },
+	{ 0x06, 0x409e },
+	{ 0x06, 0x0f39 },
+	{ 0x06, 0x46aa },
+	{ 0x06, 0x0bbf },
+	{ 0x06, 0x8290 },
+	{ 0x06, 0xd682 },
+	{ 0x06, 0x9802 },
+	{ 0x06, 0x014f },
+	{ 0x06, 0xae09 },
+	{ 0x06, 0xbf82 },
+	{ 0x06, 0x98d6 },
+	{ 0x06, 0x82a0 },
+	{ 0x06, 0x0201 },
+	{ 0x06, 0x4fef },
+	{ 0x06, 0x95fe },
+	{ 0x06, 0xfdfc },
+	{ 0x06, 0x05f8 },
+	{ 0x06, 0xf9fa },
+	{ 0x06, 0xeef8 },
+	{ 0x06, 0xea00 },
+	{ 0x06, 0xeef8 },
+	{ 0x06, 0xeb00 },
+	{ 0x06, 0xe2f8 },
+	{ 0x06, 0x7ce3 },
+	{ 0x06, 0xf87d },
+	{ 0x06, 0xa511 },
+	{ 0x06, 0x1112 },
+	{ 0x06, 0xd240 },
+	{ 0x06, 0xd644 },
+	{ 0x06, 0x4402 },
+	{ 0x06, 0x8217 },
+	{ 0x06, 0xd2a0 },
+	{ 0x06, 0xd6aa },
+	{ 0x06, 0xaa02 },
+	{ 0x06, 0x8217 },
+	{ 0x06, 0xae0f },
+	{ 0x06, 0xa544 },
+	{ 0x06, 0x4402 },
+	{ 0x06, 0xae4d },
+	{ 0x06, 0xa5aa },
+	{ 0x06, 0xaa02 },
+	{ 0x06, 0xae47 },
+	{ 0x06, 0xaf82 },
+	{ 0x06, 0x13ee },
+	{ 0x06, 0x834e },
+	{ 0x06, 0x00ee },
+	{ 0x06, 0x834d },
+	{ 0x06, 0x0fee },
+	{ 0x06, 0x834c },
+	{ 0x06, 0x0fee },
+	{ 0x06, 0x834f },
+	{ 0x06, 0x00ee },
+	{ 0x06, 0x8351 },
+	{ 0x06, 0x00ee },
+	{ 0x06, 0x834a },
+	{ 0x06, 0xffee },
+	{ 0x06, 0x834b },
+	{ 0x06, 0xffe0 },
+	{ 0x06, 0x8330 },
+	{ 0x06, 0xe183 },
+	{ 0x06, 0x3158 },
+	{ 0x06, 0xfee4 },
+	{ 0x06, 0xf88a },
+	{ 0x06, 0xe5f8 },
+	{ 0x06, 0x8be0 },
+	{ 0x06, 0x8332 },
+	{ 0x06, 0xe183 },
+	{ 0x06, 0x3359 },
+	{ 0x06, 0x0fe2 },
+	{ 0x06, 0x834d },
+	{ 0x06, 0x0c24 },
+	{ 0x06, 0x5af0 },
+	{ 0x06, 0x1e12 },
+	{ 0x06, 0xe4f8 },
+	{ 0x06, 0x8ce5 },
+	{ 0x06, 0xf88d },
+	{ 0x06, 0xaf82 },
+	{ 0x06, 0x13e0 },
+	{ 0x06, 0x834f },
+	{ 0x06, 0x10e4 },
+	{ 0x06, 0x834f },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x4e78 },
+	{ 0x06, 0x009f },
+	{ 0x06, 0x0ae0 },
+	{ 0x06, 0x834f },
+	{ 0x06, 0xa010 },
+	{ 0x06, 0xa5ee },
+	{ 0x06, 0x834e },
+	{ 0x06, 0x01e0 },
+	{ 0x06, 0x834e },
+	{ 0x06, 0x7805 },
+	{ 0x06, 0x9e9a },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x4e78 },
+	{ 0x06, 0x049e },
+	{ 0x06, 0x10e0 },
+	{ 0x06, 0x834e },
+	{ 0x06, 0x7803 },
+	{ 0x06, 0x9e0f },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x4e78 },
+	{ 0x06, 0x019e },
+	{ 0x06, 0x05ae },
+	{ 0x06, 0x0caf },
+	{ 0x06, 0x81f8 },
+	{ 0x06, 0xaf81 },
+	{ 0x06, 0xa3af },
+	{ 0x06, 0x81dc },
+	{ 0x06, 0xaf82 },
+	{ 0x06, 0x13ee },
+	{ 0x06, 0x8348 },
+	{ 0x06, 0x00ee },
+	{ 0x06, 0x8349 },
+	{ 0x06, 0x00e0 },
+	{ 0x06, 0x8351 },
+	{ 0x06, 0x10e4 },
+	{ 0x06, 0x8351 },
+	{ 0x06, 0x5801 },
+	{ 0x06, 0x9fea },
+	{ 0x06, 0xd000 },
+	{ 0x06, 0xd180 },
+	{ 0x06, 0x1f66 },
+	{ 0x06, 0xe2f8 },
+	{ 0x06, 0xeae3 },
+	{ 0x06, 0xf8eb },
+	{ 0x06, 0x5af8 },
+	{ 0x06, 0x1e20 },
+	{ 0x06, 0xe6f8 },
+	{ 0x06, 0xeae5 },
+	{ 0x06, 0xf8eb },
+	{ 0x06, 0xd302 },
+	{ 0x06, 0xb3fe },
+	{ 0x06, 0xe2f8 },
+	{ 0x06, 0x7cef },
+	{ 0x06, 0x325b },
+	{ 0x06, 0x80e3 },
+	{ 0x06, 0xf87d },
+	{ 0x06, 0x9e03 },
+	{ 0x06, 0x7dff },
+	{ 0x06, 0xff0d },
+	{ 0x06, 0x581c },
+	{ 0x06, 0x551a },
+	{ 0x06, 0x6511 },
+	{ 0x06, 0xa190 },
+	{ 0x06, 0xd3e2 },
+	{ 0x06, 0x8348 },
+	{ 0x06, 0xe383 },
+	{ 0x06, 0x491b },
+	{ 0x06, 0x56ab },
+	{ 0x06, 0x08ef },
+	{ 0x06, 0x56e6 },
+	{ 0x06, 0x8348 },
+	{ 0x06, 0xe783 },
+	{ 0x06, 0x4910 },
+	{ 0x06, 0xd180 },
+	{ 0x06, 0x1f66 },
+	{ 0x06, 0xa004 },
+	{ 0x06, 0xb9e2 },
+	{ 0x06, 0x8348 },
+	{ 0x06, 0xe383 },
+	{ 0x06, 0x49ef },
+	{ 0x06, 0x65e2 },
+	{ 0x06, 0x834a },
+	{ 0x06, 0xe383 },
+	{ 0x06, 0x4b1b },
+	{ 0x06, 0x56aa },
+	{ 0x06, 0x0eef },
+	{ 0x06, 0x56e6 },
+	{ 0x06, 0x834a },
+	{ 0x06, 0xe783 },
+	{ 0x06, 0x4be2 },
+	{ 0x06, 0x834d },
+	{ 0x06, 0xe683 },
+	{ 0x06, 0x4ce0 },
+	{ 0x06, 0x834d },
+	{ 0x06, 0xa000 },
+	{ 0x06, 0x0caf },
+	{ 0x06, 0x81dc },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x4d10 },
+	{ 0x06, 0xe483 },
+	{ 0x06, 0x4dae },
+	{ 0x06, 0x0480 },
+	{ 0x06, 0xe483 },
+	{ 0x06, 0x4de0 },
+	{ 0x06, 0x834e },
+	{ 0x06, 0x7803 },
+	{ 0x06, 0x9e0b },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x4e78 },
+	{ 0x06, 0x049e },
+	{ 0x06, 0x04ee },
+	{ 0x06, 0x834e },
+	{ 0x06, 0x02e0 },
+	{ 0x06, 0x8332 },
+	{ 0x06, 0xe183 },
+	{ 0x06, 0x3359 },
+	{ 0x06, 0x0fe2 },
+	{ 0x06, 0x834d },
+	{ 0x06, 0x0c24 },
+	{ 0x06, 0x5af0 },
+	{ 0x06, 0x1e12 },
+	{ 0x06, 0xe4f8 },
+	{ 0x06, 0x8ce5 },
+	{ 0x06, 0xf88d },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x30e1 },
+	{ 0x06, 0x8331 },
+	{ 0x06, 0x6801 },
+	{ 0x06, 0xe4f8 },
+	{ 0x06, 0x8ae5 },
+	{ 0x06, 0xf88b },
+	{ 0x06, 0xae37 },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4e03 },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x4ce1 },
+	{ 0x06, 0x834d },
+	{ 0x06, 0x1b01 },
+	{ 0x06, 0x9e04 },
+	{ 0x06, 0xaaa1 },
+	{ 0x06, 0xaea8 },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4e04 },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4f00 },
+	{ 0x06, 0xaeab },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x4f78 },
+	{ 0x06, 0x039f },
+	{ 0x06, 0x14ee },
+	{ 0x06, 0x834e },
+	{ 0x06, 0x05d2 },
+	{ 0x06, 0x40d6 },
+	{ 0x06, 0x5554 },
+	{ 0x06, 0x0282 },
+	{ 0x06, 0x17d2 },
+	{ 0x06, 0xa0d6 },
+	{ 0x06, 0xba00 },
+	{ 0x06, 0x0282 },
+	{ 0x06, 0x17fe },
+	{ 0x06, 0xfdfc },
+	{ 0x06, 0x05f8 },
+	{ 0x06, 0xe0f8 },
+	{ 0x06, 0x60e1 },
+	{ 0x06, 0xf861 },
+	{ 0x06, 0x6802 },
+	{ 0x06, 0xe4f8 },
+	{ 0x06, 0x60e5 },
+	{ 0x06, 0xf861 },
+	{ 0x06, 0xe0f8 },
+	{ 0x06, 0x48e1 },
+	{ 0x06, 0xf849 },
+	{ 0x06, 0x580f },
+	{ 0x06, 0x1e02 },
+	{ 0x06, 0xe4f8 },
+	{ 0x06, 0x48e5 },
+	{ 0x06, 0xf849 },
+	{ 0x06, 0xd000 },
+	{ 0x06, 0x0282 },
+	{ 0x06, 0x5bbf },
+	{ 0x06, 0x8350 },
+	{ 0x06, 0xef46 },
+	{ 0x06, 0xdc19 },
+	{ 0x06, 0xddd0 },
+	{ 0x06, 0x0102 },
+	{ 0x06, 0x825b },
+	{ 0x06, 0x0282 },
+	{ 0x06, 0x77e0 },
+	{ 0x06, 0xf860 },
+	{ 0x06, 0xe1f8 },
+	{ 0x06, 0x6158 },
+	{ 0x06, 0xfde4 },
+	{ 0x06, 0xf860 },
+	{ 0x06, 0xe5f8 },
+	{ 0x06, 0x61fc },
+	{ 0x06, 0x04f9 },
+	{ 0x06, 0xfafb },
+	{ 0x06, 0xc6bf },
+	{ 0x06, 0xf840 },
+	{ 0x06, 0xbe83 },
+	{ 0x06, 0x50a0 },
+	{ 0x06, 0x0101 },
+	{ 0x06, 0x071b },
+	{ 0x06, 0x89cf },
+	{ 0x06, 0xd208 },
+	{ 0x06, 0xebdb },
+	{ 0x06, 0x19b2 },
+	{ 0x06, 0xfbff },
+	{ 0x06, 0xfefd },
+	{ 0x06, 0x04f8 },
+	{ 0x06, 0xe0f8 },
+	{ 0x06, 0x48e1 },
+	{ 0x06, 0xf849 },
+	{ 0x06, 0x6808 },
+	{ 0x06, 0xe4f8 },
+	{ 0x06, 0x48e5 },
+	{ 0x06, 0xf849 },
+	{ 0x06, 0x58f7 },
+	{ 0x06, 0xe4f8 },
+	{ 0x06, 0x48e5 },
+	{ 0x06, 0xf849 },
+	{ 0x06, 0xfc04 },
+	{ 0x06, 0x4d20 },
+	{ 0x06, 0x0002 },
+	{ 0x06, 0x4e22 },
+	{ 0x06, 0x0002 },
+	{ 0x06, 0x4ddf },
+	{ 0x06, 0xff01 },
+	{ 0x06, 0x4edd },
+	{ 0x06, 0xff01 },
+	{ 0x06, 0xf8fa },
+	{ 0x06, 0xfbef },
+	{ 0x06, 0x79bf },
+	{ 0x06, 0xf822 },
+	{ 0x06, 0xd819 },
+	{ 0x06, 0xd958 },
+	{ 0x06, 0x849f },
+	{ 0x06, 0x09bf },
+	{ 0x06, 0x82be },
+	{ 0x06, 0xd682 },
+	{ 0x06, 0xc602 },
+	{ 0x06, 0x014f },
+	{ 0x06, 0xef97 },
+	{ 0x06, 0xfffe },
+	{ 0x06, 0xfc05 },
+	{ 0x06, 0x17ff },
+	{ 0x06, 0xfe01 },
+	{ 0x06, 0x1700 },
+	{ 0x06, 0x0102 },
+	{ 0x05, 0x83d8 },
+	{ 0x06, 0x8051 },
+	{ 0x05, 0x83d6 },
+	{ 0x06, 0x82a0 },
+	{ 0x05, 0x83d4 },
+	{ 0x06, 0x8000 },
+	{ 0x02, 0x2010 },
+	{ 0x03, 0xdc00 },
+	{ 0x1f, 0x0000 },
+	{ 0x0b, 0x0600 },
+	{ 0x1f, 0x0005 },
+	{ 0x05, 0xfff6 },
+	{ 0x06, 0x00fc },
+	{ 0x1f, 0x0000 }
+};
diff --git a/firmware/r8169/8168d_2_0.h b/firmware/r8169/8168d_2_0.h
new file mode 100644
index 0000000..c7988c1
--- /dev/null
+++ b/firmware/r8169/8168d_2_0.h
@@ -0,0 +1,40 @@
+static const struct phy_reg phy_reg_init_8168d_2_0[] = {
+	/* Channel Estimation */
+	{ 0x1f, 0x0001 },
+	{ 0x06, 0x4064 },
+	{ 0x07, 0x2863 },
+	{ 0x08, 0x059c },
+	{ 0x09, 0x26b4 },
+	{ 0x0a, 0x6a19 },
+	{ 0x0b, 0xdcc8 },
+	{ 0x10, 0xf06d },
+	{ 0x14, 0x7f68 },
+	{ 0x18, 0x7fd9 },
+	{ 0x1c, 0xf0ff },
+	{ 0x1d, 0x3d9c },
+	{ 0x1f, 0x0003 },
+	{ 0x12, 0xf49f },
+	{ 0x13, 0x070b },
+	{ 0x1a, 0x05ad },
+	{ 0x14, 0x94c0 },
+
+	/*
+	 * Tx Error Issue
+	 * enhance line driver power
+	 */
+	{ 0x1f, 0x0002 },
+	{ 0x06, 0x5561 },
+	{ 0x1f, 0x0005 },
+	{ 0x05, 0x8332 },
+	{ 0x06, 0x5561 },
+
+	/*
+	 * Can not link to 1Gbps with bad cable
+	 * Decrease SNR threshold form 21.07dB to 19.04dB
+	 */
+	{ 0x1f, 0x0001 },
+	{ 0x17, 0x0cc0 },
+
+	{ 0x1f, 0x0000 },
+	{ 0x0d, 0xf880 }
+};
diff --git a/firmware/r8169/8168d_2_1.h b/firmware/r8169/8168d_2_1.h
new file mode 100644
index 0000000..8b0855a
--- /dev/null
+++ b/firmware/r8169/8168d_2_1.h
@@ -0,0 +1,334 @@
+static const struct phy_reg phy_reg_init_8168d_2_1[] = {
+	/* Low pass filter & DLY_CAP fine tune from uC */
+	{ 0x1f, 0x0005 },
+	{ 0x05, 0xfff6 },
+	{ 0x06, 0x0080 },
+	{ 0x05, 0x8000 },
+	{ 0x06, 0xf8f9 },
+	{ 0x06, 0xfaee },
+	{ 0x06, 0xf8ea },
+	{ 0x06, 0x00ee },
+	{ 0x06, 0xf8eb },
+	{ 0x06, 0x00e2 },
+	{ 0x06, 0xf87c },
+	{ 0x06, 0xe3f8 },
+	{ 0x06, 0x7da5 },
+	{ 0x06, 0x1111 },
+	{ 0x06, 0x12d2 },
+	{ 0x06, 0x40d6 },
+	{ 0x06, 0x4444 },
+	{ 0x06, 0x0281 },
+	{ 0x06, 0xc6d2 },
+	{ 0x06, 0xa0d6 },
+	{ 0x06, 0xaaaa },
+	{ 0x06, 0x0281 },
+	{ 0x06, 0xc6ae },
+	{ 0x06, 0x0fa5 },
+	{ 0x06, 0x4444 },
+	{ 0x06, 0x02ae },
+	{ 0x06, 0x4da5 },
+	{ 0x06, 0xaaaa },
+	{ 0x06, 0x02ae },
+	{ 0x06, 0x47af },
+	{ 0x06, 0x81c2 },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4e00 },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4d0f },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4c0f },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4f00 },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x5100 },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4aff },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4bff },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x30e1 },
+	{ 0x06, 0x8331 },
+	{ 0x06, 0x58fe },
+	{ 0x06, 0xe4f8 },
+	{ 0x06, 0x8ae5 },
+	{ 0x06, 0xf88b },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x32e1 },
+	{ 0x06, 0x8333 },
+	{ 0x06, 0x590f },
+	{ 0x06, 0xe283 },
+	{ 0x06, 0x4d0c },
+	{ 0x06, 0x245a },
+	{ 0x06, 0xf01e },
+	{ 0x06, 0x12e4 },
+	{ 0x06, 0xf88c },
+	{ 0x06, 0xe5f8 },
+	{ 0x06, 0x8daf },
+	{ 0x06, 0x81c2 },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x4f10 },
+	{ 0x06, 0xe483 },
+	{ 0x06, 0x4fe0 },
+	{ 0x06, 0x834e },
+	{ 0x06, 0x7800 },
+	{ 0x06, 0x9f0a },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x4fa0 },
+	{ 0x06, 0x10a5 },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4e01 },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x4e78 },
+	{ 0x06, 0x059e },
+	{ 0x06, 0x9ae0 },
+	{ 0x06, 0x834e },
+	{ 0x06, 0x7804 },
+	{ 0x06, 0x9e10 },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x4e78 },
+	{ 0x06, 0x039e },
+	{ 0x06, 0x0fe0 },
+	{ 0x06, 0x834e },
+	{ 0x06, 0x7801 },
+	{ 0x06, 0x9e05 },
+	{ 0x06, 0xae0c },
+	{ 0x06, 0xaf81 },
+	{ 0x06, 0xa7af },
+	{ 0x06, 0x8152 },
+	{ 0x06, 0xaf81 },
+	{ 0x06, 0x8baf },
+	{ 0x06, 0x81c2 },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4800 },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4900 },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x5110 },
+	{ 0x06, 0xe483 },
+	{ 0x06, 0x5158 },
+	{ 0x06, 0x019f },
+	{ 0x06, 0xead0 },
+	{ 0x06, 0x00d1 },
+	{ 0x06, 0x801f },
+	{ 0x06, 0x66e2 },
+	{ 0x06, 0xf8ea },
+	{ 0x06, 0xe3f8 },
+	{ 0x06, 0xeb5a },
+	{ 0x06, 0xf81e },
+	{ 0x06, 0x20e6 },
+	{ 0x06, 0xf8ea },
+	{ 0x06, 0xe5f8 },
+	{ 0x06, 0xebd3 },
+	{ 0x06, 0x02b3 },
+	{ 0x06, 0xfee2 },
+	{ 0x06, 0xf87c },
+	{ 0x06, 0xef32 },
+	{ 0x06, 0x5b80 },
+	{ 0x06, 0xe3f8 },
+	{ 0x06, 0x7d9e },
+	{ 0x06, 0x037d },
+	{ 0x06, 0xffff },
+	{ 0x06, 0x0d58 },
+	{ 0x06, 0x1c55 },
+	{ 0x06, 0x1a65 },
+	{ 0x06, 0x11a1 },
+	{ 0x06, 0x90d3 },
+	{ 0x06, 0xe283 },
+	{ 0x06, 0x48e3 },
+	{ 0x06, 0x8349 },
+	{ 0x06, 0x1b56 },
+	{ 0x06, 0xab08 },
+	{ 0x06, 0xef56 },
+	{ 0x06, 0xe683 },
+	{ 0x06, 0x48e7 },
+	{ 0x06, 0x8349 },
+	{ 0x06, 0x10d1 },
+	{ 0x06, 0x801f },
+	{ 0x06, 0x66a0 },
+	{ 0x06, 0x04b9 },
+	{ 0x06, 0xe283 },
+	{ 0x06, 0x48e3 },
+	{ 0x06, 0x8349 },
+	{ 0x06, 0xef65 },
+	{ 0x06, 0xe283 },
+	{ 0x06, 0x4ae3 },
+	{ 0x06, 0x834b },
+	{ 0x06, 0x1b56 },
+	{ 0x06, 0xaa0e },
+	{ 0x06, 0xef56 },
+	{ 0x06, 0xe683 },
+	{ 0x06, 0x4ae7 },
+	{ 0x06, 0x834b },
+	{ 0x06, 0xe283 },
+	{ 0x06, 0x4de6 },
+	{ 0x06, 0x834c },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x4da0 },
+	{ 0x06, 0x000c },
+	{ 0x06, 0xaf81 },
+	{ 0x06, 0x8be0 },
+	{ 0x06, 0x834d },
+	{ 0x06, 0x10e4 },
+	{ 0x06, 0x834d },
+	{ 0x06, 0xae04 },
+	{ 0x06, 0x80e4 },
+	{ 0x06, 0x834d },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x4e78 },
+	{ 0x06, 0x039e },
+	{ 0x06, 0x0be0 },
+	{ 0x06, 0x834e },
+	{ 0x06, 0x7804 },
+	{ 0x06, 0x9e04 },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4e02 },
+	{ 0x06, 0xe083 },
+	{ 0x06, 0x32e1 },
+	{ 0x06, 0x8333 },
+	{ 0x06, 0x590f },
+	{ 0x06, 0xe283 },
+	{ 0x06, 0x4d0c },
+	{ 0x06, 0x245a },
+	{ 0x06, 0xf01e },
+	{ 0x06, 0x12e4 },
+	{ 0x06, 0xf88c },
+	{ 0x06, 0xe5f8 },
+	{ 0x06, 0x8de0 },
+	{ 0x06, 0x8330 },
+	{ 0x06, 0xe183 },
+	{ 0x06, 0x3168 },
+	{ 0x06, 0x01e4 },
+	{ 0x06, 0xf88a },
+	{ 0x06, 0xe5f8 },
+	{ 0x06, 0x8bae },
+	{ 0x06, 0x37ee },
+	{ 0x06, 0x834e },
+	{ 0x06, 0x03e0 },
+	{ 0x06, 0x834c },
+	{ 0x06, 0xe183 },
+	{ 0x06, 0x4d1b },
+	{ 0x06, 0x019e },
+	{ 0x06, 0x04aa },
+	{ 0x06, 0xa1ae },
+	{ 0x06, 0xa8ee },
+	{ 0x06, 0x834e },
+	{ 0x06, 0x04ee },
+	{ 0x06, 0x834f },
+	{ 0x06, 0x00ae },
+	{ 0x06, 0xabe0 },
+	{ 0x06, 0x834f },
+	{ 0x06, 0x7803 },
+	{ 0x06, 0x9f14 },
+	{ 0x06, 0xee83 },
+	{ 0x06, 0x4e05 },
+	{ 0x06, 0xd240 },
+	{ 0x06, 0xd655 },
+	{ 0x06, 0x5402 },
+	{ 0x06, 0x81c6 },
+	{ 0x06, 0xd2a0 },
+	{ 0x06, 0xd6ba },
+	{ 0x06, 0x0002 },
+	{ 0x06, 0x81c6 },
+	{ 0x06, 0xfefd },
+	{ 0x06, 0xfc05 },
+	{ 0x06, 0xf8e0 },
+	{ 0x06, 0xf860 },
+	{ 0x06, 0xe1f8 },
+	{ 0x06, 0x6168 },
+	{ 0x06, 0x02e4 },
+	{ 0x06, 0xf860 },
+	{ 0x06, 0xe5f8 },
+	{ 0x06, 0x61e0 },
+	{ 0x06, 0xf848 },
+	{ 0x06, 0xe1f8 },
+	{ 0x06, 0x4958 },
+	{ 0x06, 0x0f1e },
+	{ 0x06, 0x02e4 },
+	{ 0x06, 0xf848 },
+	{ 0x06, 0xe5f8 },
+	{ 0x06, 0x49d0 },
+	{ 0x06, 0x0002 },
+	{ 0x06, 0x820a },
+	{ 0x06, 0xbf83 },
+	{ 0x06, 0x50ef },
+	{ 0x06, 0x46dc },
+	{ 0x06, 0x19dd },
+	{ 0x06, 0xd001 },
+	{ 0x06, 0x0282 },
+	{ 0x06, 0x0a02 },
+	{ 0x06, 0x8226 },
+	{ 0x06, 0xe0f8 },
+	{ 0x06, 0x60e1 },
+	{ 0x06, 0xf861 },
+	{ 0x06, 0x58fd },
+	{ 0x06, 0xe4f8 },
+	{ 0x06, 0x60e5 },
+	{ 0x06, 0xf861 },
+	{ 0x06, 0xfc04 },
+	{ 0x06, 0xf9fa },
+	{ 0x06, 0xfbc6 },
+	{ 0x06, 0xbff8 },
+	{ 0x06, 0x40be },
+	{ 0x06, 0x8350 },
+	{ 0x06, 0xa001 },
+	{ 0x06, 0x0107 },
+	{ 0x06, 0x1b89 },
+	{ 0x06, 0xcfd2 },
+	{ 0x06, 0x08eb },
+	{ 0x06, 0xdb19 },
+	{ 0x06, 0xb2fb },
+	{ 0x06, 0xfffe },
+	{ 0x06, 0xfd04 },
+	{ 0x06, 0xf8e0 },
+	{ 0x06, 0xf848 },
+	{ 0x06, 0xe1f8 },
+	{ 0x06, 0x4968 },
+	{ 0x06, 0x08e4 },
+	{ 0x06, 0xf848 },
+	{ 0x06, 0xe5f8 },
+	{ 0x06, 0x4958 },
+	{ 0x06, 0xf7e4 },
+	{ 0x06, 0xf848 },
+	{ 0x06, 0xe5f8 },
+	{ 0x06, 0x49fc },
+	{ 0x06, 0x044d },
+	{ 0x06, 0x2000 },
+	{ 0x06, 0x024e },
+	{ 0x06, 0x2200 },
+	{ 0x06, 0x024d },
+	{ 0x06, 0xdfff },
+	{ 0x06, 0x014e },
+	{ 0x06, 0xddff },
+	{ 0x06, 0x01f8 },
+	{ 0x06, 0xfafb },
+	{ 0x06, 0xef79 },
+	{ 0x06, 0xbff8 },
+	{ 0x06, 0x22d8 },
+	{ 0x06, 0x19d9 },
+	{ 0x06, 0x5884 },
+	{ 0x06, 0x9f09 },
+	{ 0x06, 0xbf82 },
+	{ 0x06, 0x6dd6 },
+	{ 0x06, 0x8275 },
+	{ 0x06, 0x0201 },
+	{ 0x06, 0x4fef },
+	{ 0x06, 0x97ff },
+	{ 0x06, 0xfefc },
+	{ 0x06, 0x0517 },
+	{ 0x06, 0xfffe },
+	{ 0x06, 0x0117 },
+	{ 0x06, 0x0001 },
+	{ 0x06, 0x0200 },
+	{ 0x05, 0x83d8 },
+	{ 0x06, 0x8000 },
+	{ 0x05, 0x83d6 },
+	{ 0x06, 0x824f },
+	{ 0x02, 0x2010 },
+	{ 0x03, 0xdc00 },
+	{ 0x1f, 0x0000 },
+	{ 0x0b, 0x0600 },
+	{ 0x1f, 0x0005 },
+	{ 0x05, 0xfff6 },
+	{ 0x06, 0x00fc },
+	{ 0x1f, 0x0000 }
+};
diff --git a/firmware/r8169/8168d_3.h b/firmware/r8169/8168d_3.h
new file mode 100644
index 0000000..b121976
--- /dev/null
+++ b/firmware/r8169/8168d_3.h
@@ -0,0 +1,55 @@
+static const struct phy_reg phy_reg_init_8168d_3[] = {
+	{ 0x1f, 0x0002 },
+	{ 0x10, 0x0008 },
+	{ 0x0d, 0x006c },
+
+	{ 0x1f, 0x0000 },
+	{ 0x0d, 0xf880 },
+
+	{ 0x1f, 0x0001 },
+	{ 0x17, 0x0cc0 },
+
+	{ 0x1f, 0x0001 },
+	{ 0x0b, 0xa4d8 },
+	{ 0x09, 0x281c },
+	{ 0x07, 0x2883 },
+	{ 0x0a, 0x6b35 },
+	{ 0x1d, 0x3da4 },
+	{ 0x1c, 0xeffd },
+	{ 0x14, 0x7f52 },
+	{ 0x18, 0x7fc6 },
+	{ 0x08, 0x0601 },
+	{ 0x06, 0x4063 },
+	{ 0x10, 0xf074 },
+	{ 0x1f, 0x0003 },
+	{ 0x13, 0x0789 },
+	{ 0x12, 0xf4bd },
+	{ 0x1a, 0x04fd },
+	{ 0x14, 0x84b0 },
+	{ 0x1f, 0x0000 },
+	{ 0x00, 0x9200 },
+
+	{ 0x1f, 0x0005 },
+	{ 0x01, 0x0340 },
+	{ 0x1f, 0x0001 },
+	{ 0x04, 0x4000 },
+	{ 0x03, 0x1d21 },
+	{ 0x02, 0x0c32 },
+	{ 0x01, 0x0200 },
+	{ 0x00, 0x5554 },
+	{ 0x04, 0x4800 },
+	{ 0x04, 0x4000 },
+	{ 0x04, 0xf000 },
+	{ 0x03, 0xdf01 },
+	{ 0x02, 0xdf20 },
+	{ 0x01, 0x101a },
+	{ 0x00, 0xa0ff },
+	{ 0x04, 0xf800 },
+	{ 0x04, 0xf000 },
+	{ 0x1f, 0x0000 },
+
+	{ 0x1f, 0x0007 },
+	{ 0x1e, 0x0023 },
+	{ 0x16, 0x0000 },
+	{ 0x1f, 0x0000 }
+};
diff --git a/firmware/r8169/8169s.h b/firmware/r8169/8169s.h
new file mode 100644
index 0000000..52c934b
--- /dev/null
+++ b/firmware/r8169/8169s.h
@@ -0,0 +1,61 @@
+static const struct phy_reg phy_reg_init_8169s[] = {
+	{ 0x1f, 0x0001 },
+	{ 0x06, 0x006e },
+	{ 0x08, 0x0708 },
+	{ 0x15, 0x4000 },
+	{ 0x18, 0x65c7 },
+
+	{ 0x1f, 0x0001 },
+	{ 0x03, 0x00a1 },
+	{ 0x02, 0x0008 },
+	{ 0x01, 0x0120 },
+	{ 0x00, 0x1000 },
+	{ 0x04, 0x0800 },
+	{ 0x04, 0x0000 },
+
+	{ 0x03, 0xff41 },
+	{ 0x02, 0xdf60 },
+	{ 0x01, 0x0140 },
+	{ 0x00, 0x0077 },
+	{ 0x04, 0x7800 },
+	{ 0x04, 0x7000 },
+
+	{ 0x03, 0x802f },
+	{ 0x02, 0x4f02 },
+	{ 0x01, 0x0409 },
+	{ 0x00, 0xf0f9 },
+	{ 0x04, 0x9800 },
+	{ 0x04, 0x9000 },
+
+	{ 0x03, 0xdf01 },
+	{ 0x02, 0xdf20 },
+	{ 0x01, 0xff95 },
+	{ 0x00, 0xba00 },
+	{ 0x04, 0xa800 },
+	{ 0x04, 0xa000 },
+
+	{ 0x03, 0xff41 },
+	{ 0x02, 0xdf20 },
+	{ 0x01, 0x0140 },
+	{ 0x00, 0x00bb },
+	{ 0x04, 0xb800 },
+	{ 0x04, 0xb000 },
+
+	{ 0x03, 0xdf41 },
+	{ 0x02, 0xdc60 },
+	{ 0x01, 0x6340 },
+	{ 0x00, 0x007d },
+	{ 0x04, 0xd800 },
+	{ 0x04, 0xd000 },
+
+	{ 0x03, 0xdf01 },
+	{ 0x02, 0xdf20 },
+	{ 0x01, 0x100a },
+	{ 0x00, 0xa0ff },
+	{ 0x04, 0xf800 },
+	{ 0x04, 0xf000 },
+
+	{ 0x1f, 0x0000 },
+	{ 0x0b, 0x0000 },
+	{ 0x00, 0x9200 }
+};
diff --git a/firmware/r8169/8169scd.h b/firmware/r8169/8169scd.h
new file mode 100644
index 0000000..8d5f007
--- /dev/null
+++ b/firmware/r8169/8169scd.h
@@ -0,0 +1,39 @@
+static const struct phy_reg phy_reg_init_8169scd[] = {
+	{ 0x1f, 0x0001 },
+	{ 0x04, 0x0000 },
+	{ 0x03, 0x00a1 },
+	{ 0x02, 0x0008 },
+	{ 0x01, 0x0120 },
+	{ 0x00, 0x1000 },
+	{ 0x04, 0x0800 },
+	{ 0x04, 0x9000 },
+	{ 0x03, 0x802f },
+	{ 0x02, 0x4f02 },
+	{ 0x01, 0x0409 },
+	{ 0x00, 0xf099 },
+	{ 0x04, 0x9800 },
+	{ 0x04, 0xa000 },
+	{ 0x03, 0xdf01 },
+	{ 0x02, 0xdf20 },
+	{ 0x01, 0xff95 },
+	{ 0x00, 0xba00 },
+	{ 0x04, 0xa800 },
+	{ 0x04, 0xf000 },
+	{ 0x03, 0xdf01 },
+	{ 0x02, 0xdf20 },
+	{ 0x01, 0x101a },
+	{ 0x00, 0xa0ff },
+	{ 0x04, 0xf800 },
+	{ 0x04, 0x0000 },
+	{ 0x1f, 0x0000 },
+
+	{ 0x1f, 0x0001 },
+	{ 0x10, 0xf41b },
+	{ 0x14, 0xfb54 },
+	{ 0x18, 0xf5c7 },
+	{ 0x1f, 0x0000 },
+
+	{ 0x1f, 0x0001 },
+	{ 0x17, 0x0cc0 },
+	{ 0x1f, 0x0000 }
+};
diff --git a/firmware/r8169/8169sce.h b/firmware/r8169/8169sce.h
new file mode 100644
index 0000000..ee610cf
--- /dev/null
+++ b/firmware/r8169/8169sce.h
@@ -0,0 +1,47 @@
+static const struct phy_reg phy_reg_init_8169sce[] = {
+	{ 0x1f, 0x0001 },
+	{ 0x04, 0x0000 },
+	{ 0x03, 0x00a1 },
+	{ 0x02, 0x0008 },
+	{ 0x01, 0x0120 },
+	{ 0x00, 0x1000 },
+	{ 0x04, 0x0800 },
+	{ 0x04, 0x9000 },
+	{ 0x03, 0x802f },
+	{ 0x02, 0x4f02 },
+	{ 0x01, 0x0409 },
+	{ 0x00, 0xf099 },
+	{ 0x04, 0x9800 },
+	{ 0x04, 0xa000 },
+	{ 0x03, 0xdf01 },
+	{ 0x02, 0xdf20 },
+	{ 0x01, 0xff95 },
+	{ 0x00, 0xba00 },
+	{ 0x04, 0xa800 },
+	{ 0x04, 0xf000 },
+	{ 0x03, 0xdf01 },
+	{ 0x02, 0xdf20 },
+	{ 0x01, 0x101a },
+	{ 0x00, 0xa0ff },
+	{ 0x04, 0xf800 },
+	{ 0x04, 0x0000 },
+	{ 0x1f, 0x0000 },
+
+	{ 0x1f, 0x0001 },
+	{ 0x0b, 0x8480 },
+	{ 0x1f, 0x0000 },
+
+	{ 0x1f, 0x0001 },
+	{ 0x18, 0x67c7 },
+	{ 0x04, 0x2000 },
+	{ 0x03, 0x002f },
+	{ 0x02, 0x4360 },
+	{ 0x01, 0x0109 },
+	{ 0x00, 0x3022 },
+	{ 0x04, 0x2800 },
+	{ 0x1f, 0x0000 },
+
+	{ 0x1f, 0x0001 },
+	{ 0x17, 0x0cc0 },
+	{ 0x1f, 0x0000 }
+};
diff --git a/firmware/r8169/main.c b/firmware/r8169/main.c
new file mode 100644
index 0000000..8f7c206
--- /dev/null
+++ b/firmware/r8169/main.c
@@ -0,0 +1,79 @@
+#include <stdio.h>
+#include <string.h>
+#include <errno.h>
+
+#define ARRAY_SIZE(A)	sizeof(A)/sizeof(A[0])
+
+#define _R(s) \
+	{ #s, phy_reg_init_##s, ARRAY_SIZE(phy_reg_init_##s) }
+
+struct phy_reg {
+	unsigned short reg;
+	unsigned short val;
+};
+
+#include "8168c_1.h"
+#include "8168c_2.h"
+#include "8168c_3.h"
+#include "8168d_1_0.h"
+#include "8168d_1_1.h"
+#include "8168d_2_0.h"
+#include "8168d_2_1.h"
+#include "8168d_3.h"
+#include "8169scd.h"
+#include "8169sce.h"
+#include "8169s.h"
+
+struct {
+	char name[16];
+	const struct phy_reg *phy_reg;
+	const size;
+} fws[] = {
+	_R(8168c_1),
+	_R(8168c_2),
+	_R(8168c_3),
+	_R(8168d_1_0),
+	_R(8168d_1_1),
+	_R(8168d_2_0),
+	_R(8168d_2_1),
+	_R(8168d_3),
+	_R(8169scd),
+	_R(8169sce),
+	_R(8169s)
+};
+
+int main(int argc, char *argv[])
+{
+	int rc = 0, i;
+
+	for (i = 0; (i < ARRAY_SIZE(fws)) && !rc; i++) {
+		char name[42];
+		FILE *f;
+		int j;
+
+		snprintf(name, 42, "%s.fw", fws[i].name);
+		f = fopen(name, "w");
+		if (!f) {
+			rc = errno;
+			perror(name);
+			break;
+		}
+
+		for (j = 0; j < fws[i].size; j++) {
+			struct phy_reg pr = fws[i].phy_reg[j];
+			char c[4];
+
+			c[0] = pr.reg;
+			c[1] = pr.reg >> 8;
+			c[2] = pr.val;
+			c[3] = pr.val >> 8;
+			if (fwrite(c, 4, 1, f) != 1) {
+				rc = -1;
+				break;
+			}
+		}
+		fclose(f);
+	}
+
+	return rc;
+}
-- 
1.7.3.2


--x+6KMIRAuhnl3hBn--
