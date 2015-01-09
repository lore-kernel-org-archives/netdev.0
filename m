From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next v2 8/8] r8169:update rtl8168f rev.b pcie ephy parameter
Date: Fri, 9 Jan 2015 23:26:06 +0800
Message-ID: <1420817166-9868-9-git-send-email-hau@realtek.com>
References: <1420817166-9868-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420817166-9868-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RTL8168F rev.B does not have to set following two ephy parameters.
{ 0x06, 0x00c0,	0x0020 }
{ 0x08, 0x0001,	0x0002 }

Add function rtl_hw_start_8168f_2 to set RTL8168F rev.B ephy parameters,
instead of using function rtl_hw_start_8168f_1.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index aa12833..0c870f5 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5867,6 +5867,26 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
 }
 
+static void rtl_hw_start_8168f_2(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct ephy_info e_info_8168f_2[] = {
+		{ 0x09, 0x0000,	0x0080 },
+		{ 0x19, 0x0000,	0x0224 },
+		{ 0x00, 0x0000,	0x0008 },
+		{ 0x0c, 0x3df0,	0x0200 }
+	};
+
+	rtl_hw_start_8168f(tp);
+
+	rtl_ephy_init(tp, e_info_8168f_2, ARRAY_SIZE(e_info_8168f_2));
+
+	rtl_w0w1_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00, ERIAR_EXGMAC);
+
+	/* Adjust EEE LED frequency */
+	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
+}
+
 static void rtl_hw_start_8411(struct rtl8169_private *tp)
 {
 	static const struct ephy_info e_info_8411[] = {
@@ -6276,9 +6296,11 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		break;
 
 	case RTL_GIGA_MAC_VER_35:
-	case RTL_GIGA_MAC_VER_36:
 		rtl_hw_start_8168f_1(tp);
 		break;
+	case RTL_GIGA_MAC_VER_36:
+		rtl_hw_start_8168f_2(tp);
+		break;
 
 	case RTL_GIGA_MAC_VER_38:
 		rtl_hw_start_8411(tp);
-- 
1.9.1
