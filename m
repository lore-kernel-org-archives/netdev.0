From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8169: Remove rtl_ocpdr_cond
Date: Wed, 11 Jul 2012 20:31:56 +0800
Message-ID: <1342009916-1519-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No waiting is needed for mac_ocp_{write / read}. And the bit 31 of
OCPDR would not change, so rtl_udelay_loop_wait_high always return
false. That is, the r8168_mac_ocp_read always retuen ~0.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c29c5fb..1f27318 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1043,13 +1043,6 @@ static void rtl_w1w0_phy_ocp(struct rtl8169_private *tp, int reg, int p, int m)
 	r8168_phy_ocp_write(tp, reg, (val | p) & ~m);
 }
 
-DECLARE_RTL_COND(rtl_ocpdr_cond)
-{
-	void __iomem *ioaddr = tp->mmio_addr;
-
-	return RTL_R32(OCPDR) & OCPAR_FLAG;
-}
-
 static void r8168_mac_ocp_write(struct rtl8169_private *tp, u32 reg, u32 data)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1058,8 +1051,6 @@ static void r8168_mac_ocp_write(struct rtl8169_private *tp, u32 reg, u32 data)
 		return;
 
 	RTL_W32(OCPDR, OCPAR_FLAG | (reg << 15) | data);
-
-	rtl_udelay_loop_wait_low(tp, &rtl_ocpdr_cond, 25, 10);
 }
 
 static u16 r8168_mac_ocp_read(struct rtl8169_private *tp, u32 reg)
@@ -1071,8 +1062,7 @@ static u16 r8168_mac_ocp_read(struct rtl8169_private *tp, u32 reg)
 
 	RTL_W32(OCPDR, reg << 15);
 
-	return rtl_udelay_loop_wait_high(tp, &rtl_ocpdr_cond, 25, 10) ?
-		RTL_R32(OCPDR) : ~0;
+	return RTL_R32(OCPDR);
 }
 
 #define OCP_STD_PHY_BASE	0xa400
-- 
1.7.10.4
