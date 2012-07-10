From: Hayes Wang <hayeswang@realtek.com>
Subject: Re: [PATCH net-next 6/6] r8169: support RTL8168G
Date: Tue, 10 Jul 2012 15:12:49 +0800
Message-ID: <1341904369-5277-1-git-send-email-hayeswang@realtek.com>
References: <1341898590-1253-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341898590-1253-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. Remove rtl_ocpdr_cond. No waiting is needed for mac_ocp_{write / read}.
2. Set ocp_base to OCP_STD_PHY_BASE after rtl8168g_1_hw_phy_config.
---
 drivers/net/ethernet/realtek/r8169.c |   14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c29c5fb..7269175 100644
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
@@ -3417,6 +3407,8 @@ static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
 	rtl_w1w0_phy_ocp(tp, 0xa438, 0x8000, 0x0000);
 
 	rtl_w1w0_phy_ocp(tp, 0xc422, 0x4000, 0x2000);
+
+	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
-- 
1.7.10.4
