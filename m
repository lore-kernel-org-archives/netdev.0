From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 1/1] r8169: workaround for missing extended GigaMAC registers
Date: Fri, 7 Dec 2012 22:20:21 +0100
Message-ID: <20121207212021.GA8412@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Lee Chun-Yi <jlee@suse.com>,
	Wang YanQing <udknight@gmail.com>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50508 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655Ab2LGVpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 16:45:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GigaMAC registers have been reported left unitialized in several
situations:
- after cold boot from power-off state
- after S3 resume

Tweaking rtl_hw_phy_config takes care of both.

This patch removes an excess entry (",") at the end of the exgmac_reg
array as well.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Wang YanQing <udknight@gmail.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 42 ++++++++++++++++++++----------------
 1 file changed, 24 insertions(+), 18 deletions(-)

- Rebased against net-next with rtl8168e_2_hw_phy_config vs rtl8168f_hw_phy_config
  fixup as per davem's request.

- Removed a stealth "," after the last record of exgmac_reg. Not sure where it poked
  into...

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 891feee..1747256 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3120,6 +3120,23 @@ static void rtl8168e_1_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x0d, 0x0000);
 }
 
+static void rtl_rar_exgmac_set(struct rtl8169_private *tp, u8 *addr)
+{
+	const u16 w[] = {
+		addr[0] | (addr[1] << 8),
+		addr[2] | (addr[3] << 8),
+		addr[4] | (addr[5] << 8)
+	};
+	const struct exgmac_reg e[] = {
+		{ .addr = 0xe0, ERIAR_MASK_1111, .val = w[0] | (w[1] << 16) },
+		{ .addr = 0xe4, ERIAR_MASK_1111, .val = w[2] },
+		{ .addr = 0xf0, ERIAR_MASK_1111, .val = w[0] << 16 },
+		{ .addr = 0xf4, ERIAR_MASK_1111, .val = w[1] | (w[2] << 16) }
+	};
+
+	rtl_write_exgmac_batch(tp, e, ARRAY_SIZE(e));
+}
+
 static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -3204,6 +3221,9 @@ static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 
 	r8168_aldps_enable_1(tp);
+
+	/* Broken BIOS workaround: feed GigaMAC registers with MAC address. */
+	rtl_rar_exgmac_set(tp, tp->dev->dev_addr);
 }
 
 static void rtl8168f_hw_phy_config(struct rtl8169_private *tp)
@@ -3740,33 +3760,19 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	u32 high;
-	u32 low;
-
-	low  = addr[0] | (addr[1] << 8) | (addr[2] << 16) | (addr[3] << 24);
-	high = addr[4] | (addr[5] << 8);
 
 	rtl_lock_work(tp);
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
-	RTL_W32(MAC4, high);
+	RTL_W32(MAC4, addr[4] | addr[5] << 8);
 	RTL_R32(MAC4);
 
-	RTL_W32(MAC0, low);
+	RTL_W32(MAC0, addr[0] | addr[1] << 8 | addr[2] << 16 | addr[3] << 24);
 	RTL_R32(MAC0);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
-		const struct exgmac_reg e[] = {
-			{ .addr = 0xe0, ERIAR_MASK_1111, .val = low },
-			{ .addr = 0xe4, ERIAR_MASK_1111, .val = high },
-			{ .addr = 0xf0, ERIAR_MASK_1111, .val = low << 16 },
-			{ .addr = 0xf4, ERIAR_MASK_1111, .val = high << 16 |
-								low  >> 16 },
-		};
-
-		rtl_write_exgmac_batch(tp, e, ARRAY_SIZE(e));
-	}
+	if (tp->mac_version == RTL_GIGA_MAC_VER_34)
+		rtl_rar_exgmac_set(tp, addr);
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-- 
1.7.11.7
