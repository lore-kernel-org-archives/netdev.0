From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 2/5] r8169: Update PHY settings of RTL8111G
Date: Wed, 6 Feb 2013 22:46:24 +0800
Message-ID: <1360161987-3268-2-git-send-email-hayeswang@realtek.com>
References: <1360161987-3268-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360161987-3268-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Replace the current settings with rtl_writephy and rtl_readphy.
  For the hardware, the settings are same with previous ones. This
  make the setting method like the previous chips.
- Add new PHY settings.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 72 +++++++++++++++++++++++++-----------
 1 file changed, 51 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e811ab5..d1bee4c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1029,14 +1029,6 @@ static u16 r8168_phy_ocp_read(struct rtl8169_private *tp, u32 reg)
 		(RTL_R32(GPHY_OCP) & 0xffff) : ~0;
 }
 
-static void rtl_w1w0_phy_ocp(struct rtl8169_private *tp, int reg, int p, int m)
-{
-	int val;
-
-	val = r8168_phy_ocp_read(tp, reg);
-	r8168_phy_ocp_write(tp, reg, (val | p) & ~m);
-}
-
 static void r8168_mac_ocp_write(struct rtl8169_private *tp, u32 reg, u32 data)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -3410,23 +3402,61 @@ static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
 {
 	rtl_apply_firmware(tp);
 
-	if (r8168_phy_ocp_read(tp, 0xa460) & 0x0100)
-		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x0000, 0x8000);
-	else
-		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x8000, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0a46);
+	if (rtl_readphy(tp, 0x10) & 0x0100) {
+		rtl_writephy(tp, 0x1f, 0x0bcc);
+		rtl_w1w0_phy(tp, 0x12, 0x0000, 0x8000);
+	} else {
+		rtl_writephy(tp, 0x1f, 0x0bcc);
+		rtl_w1w0_phy(tp, 0x12, 0x8000, 0x0000);
+	}
 
-	if (r8168_phy_ocp_read(tp, 0xa466) & 0x0100)
-		rtl_w1w0_phy_ocp(tp, 0xc41a, 0x0002, 0x0000);
-	else
-		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x0000, 0x0002);
+	rtl_writephy(tp, 0x1f, 0x0a46);
+	if (rtl_readphy(tp, 0x13) & 0x0100) {
+		rtl_writephy(tp, 0x1f, 0x0c41);
+		rtl_w1w0_phy(tp, 0x15, 0x0002, 0x0000);
+	} else {
+		rtl_writephy(tp, 0x1f, 0x0c41);
+		rtl_w1w0_phy(tp, 0x15, 0x0000, 0x0002);
+	}
 
-	rtl_w1w0_phy_ocp(tp, 0xa442, 0x000c, 0x0000);
-	rtl_w1w0_phy_ocp(tp, 0xa4b2, 0x0004, 0x0000);
+	/* Enable PHY auto speed down */
+	rtl_writephy(tp, 0x1f, 0x0a44);
+	rtl_w1w0_phy(tp, 0x11, 0x000c, 0x0000);
+
+	rtl_writephy(tp, 0x1f, 0x0bcc);
+	rtl_w1w0_phy(tp, 0x14, 0x0100, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0a44);
+	rtl_w1w0_phy(tp, 0x11, 0x00c0, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0a43);
+	rtl_writephy(tp, 0x13, 0x8084);
+	rtl_w1w0_phy(tp, 0x14, 0x0000, 0x6000);
+	rtl_w1w0_phy(tp, 0x10, 0x1003, 0x0000);
+
+	/* EEE auto-fallback function */
+	rtl_writephy(tp, 0x1f, 0x0a4b);
+	rtl_w1w0_phy(tp, 0x11, 0x0004, 0x0000);
+
+	/* Enable UC LPF tune function */
+	rtl_writephy(tp, 0x1f, 0x0a43);
+	rtl_writephy(tp, 0x13, 0x8012);
+	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
+
+	rtl_writephy(tp, 0x1f, 0x0c42);
+	rtl_w1w0_phy(tp, 0x11, 0x4000, 0x2000);
 
-	r8168_phy_ocp_write(tp, 0xa436, 0x8012);
-	rtl_w1w0_phy_ocp(tp, 0xa438, 0x8000, 0x0000);
+	/* Improve SWR Efficiency */
+	rtl_writephy(tp, 0x1f, 0x0bcd);
+	rtl_writephy(tp, 0x14, 0x5065);
+	rtl_writephy(tp, 0x14, 0xd065);
+	rtl_writephy(tp, 0x1f, 0x0bc8);
+	rtl_writephy(tp, 0x11, 0x5655);
+	rtl_writephy(tp, 0x1f, 0x0bcd);
+	rtl_writephy(tp, 0x14, 0x1065);
+	rtl_writephy(tp, 0x14, 0x9065);
+	rtl_writephy(tp, 0x14, 0x1065);
 
-	rtl_w1w0_phy_ocp(tp, 0xc422, 0x4000, 0x2000);
+	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
-- 
1.8.1
