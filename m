From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [GIT] Networking
Date: Fri, 8 Feb 2013 23:50:26 +0100
Message-ID: <20130208225026.GA24672@electric-eye.fr.zoreil.com>
References: <20130208.151713.1708597749091717933.davem@davemloft.net> <CA+55aFx81-GGEEXx+MqJvwJsDoBMMqSN80=J8LmN-Ufu4+kKcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>,
	=?utf-8?B?SsO2cmc=?= Otte <jrg.otte@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFx81-GGEEXx+MqJvwJsDoBMMqSN80=J8LmN-Ufu4+kKcw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> :
[...]
> However, there's still the r8169 regressions (see the emails with the
> subject "regression: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0
> timed out"). It's bisected, and a revert is reported to fix things.
> It's not in this pull request. Comments ?

J=C3=B6rg asked Hayes. Hayes suggested to revert. Francois reverts, fix=
es a
pair of rejects, builds, boot. Anyone should be able to pull from
branch 'davem.r8169' in repository

git://violet.fr.zoreil.com/romieu/linux davem.r8169

to get the changes below :

Distance from 'davem' (a1c83b054ebe1264ed9ae9d5c286f9eae68e60ea)
----------------------------------------------------------------

4521e1a94279ce610d3f9b7945c17d581f804242
eef63cc1c6ecf4898a973f870aec95d6e923ea77

Diffstat
--------

 drivers/net/ethernet/realtek/r8169.c | 86 ++++++++--------------------=
--------
 1 file changed, 19 insertions(+), 67 deletions(-)

Shortlog
--------

=46rancois Romieu (2):
      Revert "r8169: enable ALDPS for power saving".
      Revert "r8169: enable internal ASPM and clock request settings".

Patch
-----

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index 1170232..998974f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -450,7 +450,6 @@ enum rtl8168_registers {
 #define PWM_EN				(1 << 22)
 #define RXDV_GATED_EN			(1 << 19)
 #define EARLY_TALLY_EN			(1 << 16)
-#define FORCE_CLK			(1 << 15) /* force clock request */
 };
=20
 enum rtl_register_content {
@@ -514,7 +513,6 @@ enum rtl_register_content {
 	PMEnable	=3D (1 << 0),	/* Power Management Enable */
=20
 	/* Config2 register p. 25 */
-	ClkReqEn	=3D (1 << 7),	/* Clock Request Enable */
 	MSIEnable	=3D (1 << 5),	/* 8169 only. Reserved in the 8168. */
 	PCI_Clock_66MHz =3D 0x01,
 	PCI_Clock_33MHz =3D 0x00,
@@ -535,7 +533,6 @@ enum rtl_register_content {
 	Spi_en		=3D (1 << 3),
 	LanWake		=3D (1 << 1),	/* LanWake enable/disable */
 	PMEStatus	=3D (1 << 0),	/* PME status can be reset by PCI RST# */
-	ASPM_en		=3D (1 << 0),	/* ASPM enable */
=20
 	/* TBICSR p.28 */
 	TBIReset	=3D 0x80000000,
@@ -684,7 +681,6 @@ enum features {
 	RTL_FEATURE_WOL		=3D (1 << 0),
 	RTL_FEATURE_MSI		=3D (1 << 1),
 	RTL_FEATURE_GMII	=3D (1 << 2),
-	RTL_FEATURE_FW_LOADED	=3D (1 << 3),
 };
=20
 struct rtl8169_counters {
@@ -2389,10 +2385,8 @@ static void rtl_apply_firmware(struct rtl8169_pr=
ivate *tp)
 	struct rtl_fw *rtl_fw =3D tp->rtl_fw;
=20
 	/* TODO: release firmware once rtl_phy_write_fw signals failures. */
-	if (!IS_ERR_OR_NULL(rtl_fw)) {
+	if (!IS_ERR_OR_NULL(rtl_fw))
 		rtl_phy_write_fw(tp, rtl_fw);
-		tp->features |=3D RTL_FEATURE_FW_LOADED;
-	}
 }
=20
 static void rtl_apply_firmware_cond(struct rtl8169_private *tp, u8 reg=
, u16 val)
@@ -2403,31 +2397,6 @@ static void rtl_apply_firmware_cond(struct rtl81=
69_private *tp, u8 reg, u16 val)
 		rtl_apply_firmware(tp);
 }
=20
-static void r810x_aldps_disable(struct rtl8169_private *tp)
-{
-	rtl_writephy(tp, 0x1f, 0x0000);
-	rtl_writephy(tp, 0x18, 0x0310);
-	msleep(100);
-}
-
-static void r810x_aldps_enable(struct rtl8169_private *tp)
-{
-	if (!(tp->features & RTL_FEATURE_FW_LOADED))
-		return;
-
-	rtl_writephy(tp, 0x1f, 0x0000);
-	rtl_writephy(tp, 0x18, 0x8310);
-}
-
-static void r8168_aldps_enable_1(struct rtl8169_private *tp)
-{
-	if (!(tp->features & RTL_FEATURE_FW_LOADED))
-		return;
-
-	rtl_writephy(tp, 0x1f, 0x0000);
-	rtl_w1w0_phy(tp, 0x15, 0x1000, 0x0000);
-}
-
 static void rtl8169s_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] =3D {
@@ -3218,8 +3187,6 @@ static void rtl8168e_2_hw_phy_config(struct rtl81=
69_private *tp)
 	rtl_w1w0_phy(tp, 0x10, 0x0000, 0x0400);
 	rtl_writephy(tp, 0x1f, 0x0000);
=20
-	r8168_aldps_enable_1(tp);
-
 	/* Broken BIOS workaround: feed GigaMAC registers with MAC address. *=
/
 	rtl_rar_exgmac_set(tp, tp->dev->dev_addr);
 }
@@ -3294,8 +3261,6 @@ static void rtl8168f_1_hw_phy_config(struct rtl81=
69_private *tp)
 	rtl_writephy(tp, 0x05, 0x8b85);
 	rtl_w1w0_phy(tp, 0x06, 0x4000, 0x0000);
 	rtl_writephy(tp, 0x1f, 0x0000);
-
-	r8168_aldps_enable_1(tp);
 }
=20
 static void rtl8168f_2_hw_phy_config(struct rtl8169_private *tp)
@@ -3303,8 +3268,6 @@ static void rtl8168f_2_hw_phy_config(struct rtl81=
69_private *tp)
 	rtl_apply_firmware(tp);
=20
 	rtl8168f_hw_phy_config(tp);
-
-	r8168_aldps_enable_1(tp);
 }
=20
 static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
@@ -3402,8 +3365,6 @@ static void rtl8411_hw_phy_config(struct rtl8169_=
private *tp)
 	rtl_w1w0_phy(tp, 0x19, 0x0000, 0x0001);
 	rtl_w1w0_phy(tp, 0x10, 0x0000, 0x0400);
 	rtl_writephy(tp, 0x1f, 0x0000);
-
-	r8168_aldps_enable_1(tp);
 }
=20
 static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
@@ -3489,19 +3450,21 @@ static void rtl8105e_hw_phy_config(struct rtl81=
69_private *tp)
 	};
=20
 	/* Disable ALDPS before ram code */
-	r810x_aldps_disable(tp);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x18, 0x0310);
+	msleep(100);
=20
 	rtl_apply_firmware(tp);
=20
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
-
-	r810x_aldps_enable(tp);
 }
=20
 static void rtl8402_hw_phy_config(struct rtl8169_private *tp)
 {
 	/* Disable ALDPS before setting firmware */
-	r810x_aldps_disable(tp);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x18, 0x0310);
+	msleep(20);
=20
 	rtl_apply_firmware(tp);
=20
@@ -3511,8 +3474,6 @@ static void rtl8402_hw_phy_config(struct rtl8169_=
private *tp)
 	rtl_writephy(tp, 0x10, 0x401f);
 	rtl_writephy(tp, 0x19, 0x7030);
 	rtl_writephy(tp, 0x1f, 0x0000);
-
-	r810x_aldps_enable(tp);
 }
=20
 static void rtl8106e_hw_phy_config(struct rtl8169_private *tp)
@@ -3525,7 +3486,9 @@ static void rtl8106e_hw_phy_config(struct rtl8169=
_private *tp)
 	};
=20
 	/* Disable ALDPS before ram code */
-	r810x_aldps_disable(tp);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_writephy(tp, 0x18, 0x0310);
+	msleep(100);
=20
 	rtl_apply_firmware(tp);
=20
@@ -3533,8 +3496,6 @@ static void rtl8106e_hw_phy_config(struct rtl8169=
_private *tp)
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
=20
 	rtl_eri_write(tp, 0x1d0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
-
-	r810x_aldps_enable(tp);
 }
=20
 static void rtl_hw_phy_config(struct net_device *dev)
@@ -5051,6 +5012,8 @@ static void rtl_hw_start_8168e_2(struct rtl8169_p=
rivate *tp)
=20
 	RTL_W8(MaxTxPacketSize, EarlySize);
=20
+	rtl_disable_clock_request(pdev);
+
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
=20
@@ -5059,8 +5022,7 @@ static void rtl_hw_start_8168e_2(struct rtl8169_p=
rivate *tp)
=20
 	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
 	RTL_W32(MISC, RTL_R32(MISC) | PWM_EN);
-	RTL_W8(Config5, (RTL_R8(Config5) & ~Spi_en) | ASPM_en);
-	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
=20
 static void rtl_hw_start_8168f(struct rtl8169_private *tp)
@@ -5085,12 +5047,13 @@ static void rtl_hw_start_8168f(struct rtl8169_p=
rivate *tp)
=20
 	RTL_W8(MaxTxPacketSize, EarlySize);
=20
+	rtl_disable_clock_request(pdev);
+
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
 	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
-	RTL_W32(MISC, RTL_R32(MISC) | PWM_EN | FORCE_CLK);
-	RTL_W8(Config5, (RTL_R8(Config5) & ~Spi_en) | ASPM_en);
-	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+	RTL_W32(MISC, RTL_R32(MISC) | PWM_EN);
+	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
=20
 static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
@@ -5147,10 +5110,8 @@ static void rtl_hw_start_8168g_1(struct rtl8169_=
private *tp)
 	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
=20
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
-	RTL_W32(MISC, (RTL_R32(MISC) | FORCE_CLK) & ~RXDV_GATED_EN);
+	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
 	RTL_W8(MaxTxPacketSize, EarlySize);
-	RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
-	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
=20
 	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
@@ -5366,9 +5327,6 @@ static void rtl_hw_start_8105e_1(struct rtl8169_p=
rivate *tp)
=20
 	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
 	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
-	RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
-	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
-	RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
=20
 	rtl_ephy_init(tp, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
 }
@@ -5394,9 +5352,6 @@ static void rtl_hw_start_8402(struct rtl8169_priv=
ate *tp)
=20
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
-	RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
-	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
-	RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);
=20
 	rtl_ephy_init(tp, e_info_8402, ARRAY_SIZE(e_info_8402));
=20
@@ -5418,10 +5373,7 @@ static void rtl_hw_start_8106(struct rtl8169_pri=
vate *tp)
 	/* Force LAN exit from ASPM if Rx/Tx are not idle */
 	RTL_W32(FuncEvent, RTL_R32(FuncEvent) | 0x002800);
=20
-	RTL_W32(MISC,
-		(RTL_R32(MISC) | DISABLE_LAN_EN | FORCE_CLK) & ~EARLY_TALLY_EN);
-	RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
-	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
+	RTL_W32(MISC, (RTL_R32(MISC) | DISABLE_LAN_EN) & ~EARLY_TALLY_EN);
 	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
 	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~PFM_EN);
 }
--=20
Ueimor
