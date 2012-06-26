From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: RxConfig hack for the 8168evl.
Date: Tue, 26 Jun 2012 11:22:51 +0200
Message-ID: <20120626092251.GA1854@electric-eye.fr.zoreil.com>
References: <20120620220918.GA2785@electric-eye.fr.zoreil.com> <DB5F775AE8124DDDAE4E1501A78AF7A3@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, thomas.pi@arcor.de
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58590 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161Ab2FZJdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 05:33:37 -0400
Content-Disposition: inline
In-Reply-To: <DB5F775AE8124DDDAE4E1501A78AF7A3@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> The definition of the IO 0x44 bit 14 is opposite for new chips.
> For 8111C, 0 means fetching one Rx descriptor, and 1 means fetching
> multi-descriptors.
> For 8111D and the later chips, 0 means fetching multi-descriptors, and 1 means
> fetching one Rx descriptor.

Ok. Is there much point fetching one Rx descriptor versus several ?

[...]
> The CFG_METHOD_16 is the internal test chip. We don't have mass production for
> it. Even it could be removed from driver. I don't think the kernel have to
> support it.

Ok.

There seem to be a few differences for the CFG_METHOD_16 chipset between
the kernel driver and Realtek's own. I have noticed the points below.
Should some of those be included ?

Thanks.

Subject: [PATCH] r8169: narrow 8168evl support.

Some bits taken from the comparison with Realtek's 8.031.00 8168 driver

- 0x7cf00000 / 0x2c900000 is a Realtek internal, test-only chipset
- rtl8168evl_reset_packet_filter is only there for documentation purpose
  (no change)
- TDFNR ?
- the Magic Packet feature should be set and read differently
- r8168_pll_power_up tweak
- what is the mysterious 0xf2 register for in rtl_hw_start_8168e_2 ?
- hardware checksum offloading fix for small packets

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   87 ++++++++++++++++++++++++----------
 1 file changed, 62 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7260aa7..ad6bcf6 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -364,6 +364,8 @@ enum rtl8110_registers {
 };
 
 enum rtl8168_8101_registers {
+	TDFNR			= 0x57,	/* Transmit descriptor fetch number. */
+#define TDFNR_MASK			0x3f
 	CSIDR			= 0x64,
 	CSIAR			= 0x68,
 #define	CSIAR_FLAG			0x80000000
@@ -1265,6 +1267,12 @@ static void rtl8169_xmii_reset_enable(struct rtl8169_private *tp)
 	rtl_writephy(tp, MII_BMCR, val & 0xffff);
 }
 
+static void rtl8168evl_reset_packet_filter(void __iomem *ioaddr)
+{
+	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+}
+
 static void rtl_link_chg_patch(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1291,11 +1299,7 @@ static void rtl_link_chg_patch(struct rtl8169_private *tp)
 			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
 				      0x0000003f, ERIAR_EXGMAC);
 		}
-		/* Reset packet filter */
-		rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x00, 0x01,
-			     ERIAR_EXGMAC);
-		rtl_w1w0_eri(ioaddr, 0xdc, ERIAR_MASK_0001, 0x01, 0x00,
-			     ERIAR_EXGMAC);
+		rtl8168evl_reset_packet_filter(ioaddr);
 	} else if (tp->mac_version == RTL_GIGA_MAC_VER_35 ||
 		   tp->mac_version == RTL_GIGA_MAC_VER_36) {
 		if (RTL_R8(PHYstatus) & _1000bpsF) {
@@ -1355,7 +1359,7 @@ static u32 __rtl8169_get_wol(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 	u8 options;
-	u32 wolopts = 0;
+	u32 wolopts = 0, csi;
 
 	options = RTL_R8(Config1);
 	if (!(options & PMEnable))
@@ -1364,8 +1368,18 @@ static u32 __rtl8169_get_wol(struct rtl8169_private *tp)
 	options = RTL_R8(Config3);
 	if (options & LinkUp)
 		wolopts |= WAKE_PHY;
-	if (options & MagicPacket)
-		wolopts |= WAKE_MAGIC;
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_34:
+		csi = rtl_eri_read(ioaddr, 0xde, ERIAR_EXGMAC);
+		if (csi & 0x01)
+			wolopts |= WAKE_MAGIC;
+		break;
+	default:
+		if (options & MagicPacket)
+			wolopts |= WAKE_MAGIC;
+		break;
+	}
 
 	options = RTL_R8(Config5);
 	if (options & UWF)
@@ -1399,24 +1413,19 @@ static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
 		u16 reg;
 		u8  mask;
 	} cfg[] = {
-		{ WAKE_PHY,   Config3, LinkUp },
 		{ WAKE_MAGIC, Config3, MagicPacket },
+		{ WAKE_PHY,   Config3, LinkUp },
 		{ WAKE_UCAST, Config5, UWF },
 		{ WAKE_BCAST, Config5, BWF },
 		{ WAKE_MCAST, Config5, MWF },
 		{ WAKE_ANY,   Config5, LanWake }
 	};
+	int start = 0;
 	u8 options;
+	u32 csi;
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
-	for (i = 0; i < ARRAY_SIZE(cfg); i++) {
-		options = RTL_R8(cfg[i].reg) & ~cfg[i].mask;
-		if (wolopts & cfg[i].opt)
-			options |= cfg[i].mask;
-		RTL_W8(cfg[i].reg, options);
-	}
-
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_01 ... RTL_GIGA_MAC_VER_17:
 		options = RTL_R8(Config1) & ~PMEnable;
@@ -1424,6 +1433,13 @@ static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
 			options |= PMEnable;
 		RTL_W8(Config1, options);
 		break;
+	case RTL_GIGA_MAC_VER_34:
+		csi = rtl_eri_read(ioaddr, 0xde, ERIAR_EXGMAC) & ~0x01;
+		if (wolopts & WAKE_MAGIC)
+			csi |= 0x01;
+		rtl_eri_write(ioaddr, 0xde, 4, csi, ERIAR_EXGMAC);
+
+		start++;
 	default:
 		options = RTL_R8(Config2) & ~PME_SIGNAL;
 		if (wolopts)
@@ -1432,6 +1448,13 @@ static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
 		break;
 	}
 
+	for (i = start; i < ARRAY_SIZE(cfg); i++) {
+		options = RTL_R8(cfg[i].reg) & ~cfg[i].mask;
+		if (wolopts & cfg[i].opt)
+			options |= cfg[i].mask;
+		RTL_W8(cfg[i].reg, options);
+	}
+
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 }
 
@@ -1900,7 +1923,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		{ 0x7cf00000, 0x48000000,	RTL_GIGA_MAC_VER_35 },
 
 		/* 8168E family. */
-		{ 0x7c800000, 0x2c800000,	RTL_GIGA_MAC_VER_34 },
+		{ 0x7cf00000, 0x2c800000,	RTL_GIGA_MAC_VER_34 },
 		{ 0x7cf00000, 0x2c200000,	RTL_GIGA_MAC_VER_33 },
 		{ 0x7cf00000, 0x2c100000,	RTL_GIGA_MAC_VER_32 },
 		{ 0x7c800000, 0x2c000000,	RTL_GIGA_MAC_VER_33 },
@@ -3778,6 +3801,9 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_33:
 		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
 		break;
+	case RTL_GIGA_MAC_VER_34:
+		RTL_W8(PMCH, RTL_R8(PMCH) & ~0xc0);
+		break;
 	}
 }
 
@@ -3795,6 +3821,9 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_33:
 		RTL_W8(PMCH, RTL_R8(PMCH) | 0x80);
 		break;
+	case RTL_GIGA_MAC_VER_34:
+		RTL_W8(PMCH, RTL_R8(PMCH) | 0xc0);
+		break;
 	}
 
 	r8168_phy_power_up(tp);
@@ -4797,6 +4826,9 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
+	RTL_W8(0xf2, (RTL_R8(0xf2) & ~0x02) | 0x05);
+	RTL_W8(TDFNR, (RTL_R8(TDFNR) & ~TDFNR_MASK) | 0x8);
+
 	rtl_disable_clock_request(pdev);
 
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
@@ -5474,14 +5506,19 @@ static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
 		opts[0] |= TD_LSO;
 		opts[offset] |= min(mss, TD_MSS_MAX) << info->mss_shift;
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		const struct iphdr *ip = ip_hdr(skb);
-
-		if (ip->protocol == IPPROTO_TCP)
-			opts[offset] |= info->checksum.tcp;
-		else if (ip->protocol == IPPROTO_UDP)
-			opts[offset] |= info->checksum.udp;
-		else
-			WARN_ON_ONCE(1);
+		if (likely(skb-> len >= 60 ||
+		    (tp->mac_version != RTL_GIGA_MAC_VER_34))) {
+			const struct iphdr *ip = ip_hdr(skb);
+
+			if (ip->protocol == IPPROTO_TCP)
+				opts[offset] |= info->checksum.tcp;
+			else if (ip->protocol == IPPROTO_UDP)
+				opts[offset] |= info->checksum.udp;
+			else
+				WARN_ON_ONCE(1);
+		} else {
+			skb_checksum_help(skb);
+		}
 	}
 }
 
-- 
1.7.10.2
