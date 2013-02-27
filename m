From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] r8169: honor jumbo settings when chipset is requested to start.
Date: Thu, 28 Feb 2013 00:01:57 +0100
Message-ID: <20130227230157.GA30053@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tomi Orava <tomimo@ncircle.nullnet.fi>,
	David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46892 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672Ab3B0Xek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 18:34:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some hardware start settings implicitely assume an usual 1500 bytes mtu
that can't be guaranteed because changes of mtu may be requested both
before and after the hardware is started.

Reported-by: Tomi Orava <tomimo@ncircle.nullnet.fi>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---

 Tomi, can you give this one a try ? It should be the "don't break non
 jumbo setup and fix similar problem on different chipsets" patch that
 my previous hack wasn't.

 drivers/net/ethernet/realtek/r8169.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 8900398..28fb50a 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4765,8 +4765,10 @@ static void rtl_hw_start_8168bb(struct rtl8169_private *tp)
 
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 
-	rtl_tx_performance_tweak(pdev,
-		(0x5 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
+	if (tp->dev->mtu <= ETH_DATA_LEN) {
+		rtl_tx_performance_tweak(pdev, (0x5 << MAX_READ_REQUEST_SHIFT) |
+					 PCI_EXP_DEVCTL_NOSNOOP_EN);
+	}
 }
 
 static void rtl_hw_start_8168bef(struct rtl8169_private *tp)
@@ -4789,7 +4791,8 @@ static void __rtl_hw_start_8168cp(struct rtl8169_private *tp)
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	rtl_disable_clock_request(pdev);
 
@@ -4822,7 +4825,8 @@ static void rtl_hw_start_8168cp_2(struct rtl8169_private *tp)
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
@@ -4841,7 +4845,8 @@ static void rtl_hw_start_8168cp_3(struct rtl8169_private *tp)
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
@@ -4901,7 +4906,8 @@ static void rtl_hw_start_8168d(struct rtl8169_private *tp)
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
@@ -4913,7 +4919,8 @@ static void rtl_hw_start_8168dp(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_1(tp);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
@@ -4972,7 +4979,8 @@ static void rtl_hw_start_8168e_1(struct rtl8169_private *tp)
 
 	rtl_ephy_init(tp, e_info_8168e_1, ARRAY_SIZE(e_info_8168e_1));
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
@@ -4998,7 +5006,8 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 
 	rtl_ephy_init(tp, e_info_8168e_2, ARRAY_SIZE(e_info_8168e_2));
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
-- 
1.8.1.2
