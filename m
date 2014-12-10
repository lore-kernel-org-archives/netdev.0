From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next v2] r8169:update rtl8168g pcie ephy parameter
Date: Wed, 10 Dec 2014 21:28:38 +0800
Message-ID: <1418218118-15018-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add ephy parameter to rtl8168g.
Also change the common function of rtl8168g from "rtl_hw_start_8168g_1" to
 "rtl_hw_start_8168g". And function "rtl_hw_start_8168g_1" is used for
setting rtl8168g hardware parameters.

Following is the explanation of what hardware parameter change for.
rtl8168g may erroneous judge the PCIe signal quality and show the error bit
on PCI configuration space when in PCIe low power mode.
The following ephy parameters are for above issue.
{ 0x00, 0x0000,	0x0008 }
{ 0x0c, 0x37d0,	0x0820 }
{ 0x1e, 0x0000,	0x0001 }

rtl8168g may return to PCIe L0 from PCIe L0s low power mode too slow.
The following ephy parameter is for above issue.
{ 0x19, 0x8000,	0x0000 }

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b9c2f33..b77efcb 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5919,7 +5919,7 @@ static void rtl_hw_start_8411(struct rtl8169_private *tp)
 	rtl_w0w1_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0x0000, ERIAR_EXGMAC);
 }
 
-static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
+static void rtl_hw_start_8168g(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
@@ -5954,6 +5954,24 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 	rtl_pcie_state_l2l3_enable(tp, false);
 }
 
+static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct ephy_info e_info_8168g_1[] = {
+		{ 0x00, 0x0000,	0x0008 },
+		{ 0x0c, 0x37d0,	0x0820 },
+		{ 0x1e, 0x0000,	0x0001 },
+		{ 0x19, 0x8000,	0x0000 }
+	};
+
+	rtl_hw_start_8168g(tp);
+
+	/* disable aspm and clock request before access ephy */
+	RTL_W8(Config2, RTL_R8(Config2) & ~ClkReqEn);
+	RTL_W8(Config5, RTL_R8(Config5) & ~ASPM_en);
+	rtl_ephy_init(tp, e_info_8168g_1, ARRAY_SIZE(e_info_8168g_1));
+}
+
 static void rtl_hw_start_8168g_2(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -5964,7 +5982,7 @@ static void rtl_hw_start_8168g_2(struct rtl8169_private *tp)
 		{ 0x1e, 0xffff,	0x20eb }
 	};
 
-	rtl_hw_start_8168g_1(tp);
+	rtl_hw_start_8168g(tp);
 
 	/* disable aspm and clock request before access ephy */
 	RTL_W8(Config2, RTL_R8(Config2) & ~ClkReqEn);
@@ -5983,7 +6001,7 @@ static void rtl_hw_start_8411_2(struct rtl8169_private *tp)
 		{ 0x1e, 0x0000,	0x2000 }
 	};
 
-	rtl_hw_start_8168g_1(tp);
+	rtl_hw_start_8168g(tp);
 
 	/* disable aspm and clock request before access ephy */
 	RTL_W8(Config2, RTL_R8(Config2) & ~ClkReqEn);
-- 
1.9.1
