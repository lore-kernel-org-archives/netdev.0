From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8168 is needed to enter P-state: Package State 6 (pc6)onHaswell
 hardware
Date: Tue, 7 Oct 2014 00:13:07 +0200
Message-ID: <20141006221307.GB10936@electric-eye.fr.zoreil.com>
References: <542B3829.3010108@crashplan.pro>
 <20141005165920.GA21926@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2526932@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ceriel Jacobs <linux-ide@crashplan.pro>,
	nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46726 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbaJFWNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 18:13:16 -0400
Content-Disposition: inline
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2526932@RTITMBSV03.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Wang <hayeswang@realtek.com> :
>  Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> I don't sure if the following information is helpful. Besides, I remember
> the rtl_init_one() would disable it.
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=d64ec841517a25f6d468bde9f67e5b4cffdc67c7
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=4521e1a94279ce610d3f9b7945c17d581f804242

Yes, I did not expect this stuff to stay in geostationary orbit for long :o/

Realtek's r8168 driver defaults to CONFIG_ASPM=1 but I guess some users
need to disable it and there's no known pattern / blacklist, right ?

Ceriel, does the patch below against current kernel make a difference ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 0921302..b4a3881 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -468,6 +468,7 @@ enum rtl8168_registers {
 #define PWM_EN				(1 << 22)
 #define RXDV_GATED_EN			(1 << 19)
 #define EARLY_TALLY_EN			(1 << 16)
+#define FORCE_CLK			(1 << 15) /* force clock request */
 };
 
 enum rtl_register_content {
@@ -5279,8 +5280,10 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 	rtl_eri_write(tp, 0x2f8, ERIAR_MASK_0011, 0x1d8f, ERIAR_EXGMAC);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
-	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
+	RTL_W32(MISC, (RTL_R32(MISC) | FORCE_CLK) & ~RXDV_GATED_EN);
 	RTL_W8(MaxTxPacketSize, EarlySize);
+	RTL_W8(Config5, RTL_R8(Config5) | ASPM_en);
+	RTL_W8(Config2, RTL_R8(Config2) | ClkReqEn);
 
 	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
