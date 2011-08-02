From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169 : MAC address change fix for the 8168e-vl.
Date: Tue, 2 Aug 2011 15:53:43 +0200
Message-ID: <20110802135343.GA13908@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57652 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849Ab1HBOKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 10:10:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=39252

Hayes suggested that the usual MAC{0, 4} register writes be completed
with writes to extended GigaMAC registers :
- 0xe0 .. 0xe5
- 0xf2 .. 0xf7

Registers 0xf0 and 0xf1 should be set to 0.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7d9c650..851a488 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1091,6 +1091,21 @@ rtl_w1w0_eri(void __iomem *ioaddr, int addr, u32 mask, u32 p, u32 m, int type)
 	rtl_eri_write(ioaddr, addr, mask, (val & ~m) | p, type);
 }
 
+struct exgmac_reg {
+	u16 addr;
+	u16 mask;
+	u32 val;
+};
+
+static void rtl_write_exgmac_batch(void __iomem *ioaddr,
+				   const struct exgmac_reg *r, int len)
+{
+	while (len-- > 0) {
+		rtl_eri_write(ioaddr, r->addr, r->mask, r->val, ERIAR_EXGMAC);
+		r++;
+	}
+}
+
 static u8 rtl8168d_efuse_read(void __iomem *ioaddr, int reg_addr)
 {
 	u8 value = 0xff;
@@ -3116,6 +3131,18 @@ static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 	RTL_W32(MAC0, low);
 	RTL_R32(MAC0);
 
+	if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+		const struct exgmac_reg e[] = {
+			{ .addr = 0xe0, ERIAR_MASK_1111, .val = low },
+			{ .addr = 0xe4, ERIAR_MASK_1111, .val = high },
+			{ .addr = 0xf0, ERIAR_MASK_1111, .val = low << 16 },
+			{ .addr = 0xf4, ERIAR_MASK_1111, .val = high << 16 |
+								low  >> 16 },
+		};
+
+		rtl_write_exgmac_batch(ioaddr, e, ARRAY_SIZE(e));
+	}
+
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	spin_unlock_irq(&tp->lock);
-- 
1.7.6

