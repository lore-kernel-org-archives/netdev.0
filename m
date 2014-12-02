From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 2/2] r8169:disable rtl8168ep cmac engine
Date: Tue, 2 Dec 2014 16:48:31 +0800
Message-ID: <1417510111-3568-3-git-send-email-hau@realtek.com>
References: <1417510111-3568-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417510111-3568-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cmac engine is the bridge between driver and dash firmware.
Other os may not disable cmac when leave. And r8169 did not allocate any
resources for cmac engine. Disable it to prevent abnormal system behavior.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 30 ++++++++++++++++++++++--------
 1 file changed, 22 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7f4515f..56280c1 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1377,6 +1377,16 @@ DECLARE_RTL_COND(rtl_ocp_tx_cond)
 	return RTL_R8(IBISR0) & 0x02;
 }
 
+static void rtl8168ep_stop_cmac(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W8(IBCR2, RTL_R8(IBCR2) & ~0x01);
+	rtl_msleep_loop_wait_low(tp, &rtl_ocp_tx_cond, 50, 2000);
+	RTL_W8(IBISR0, RTL_R8(IBISR0) | 0x20);
+	RTL_W8(IBCR0, RTL_R8(IBCR0) & ~0x01);
+}
+
 static void rtl8168dp_driver_start(struct rtl8169_private *tp)
 {
 	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_START);
@@ -1417,12 +1427,7 @@ static void rtl8168dp_driver_stop(struct rtl8169_private *tp)
 
 static void rtl8168ep_driver_stop(struct rtl8169_private *tp)
 {
-	void __iomem *ioaddr = tp->mmio_addr;
-
-	RTL_W8(IBCR2, RTL_R8(IBCR2) & ~0x01);
-	rtl_msleep_loop_wait_low(tp, &rtl_ocp_tx_cond, 50, 2000);
-	RTL_W8(IBISR0, RTL_R8(IBISR0) | 0x20);
-	RTL_W8(IBCR0, RTL_R8(IBCR0) & ~0x01);
+	rtl8168ep_stop_cmac(tp);
 	ocp_write(tp, 0x01, 0x180, OOB_CMD_DRIVER_STOP);
 	ocp_write(tp, 0x01, 0x30, ocp_read(tp, 0x01, 0x30) | 0x01);
 	rtl_msleep_loop_wait_low(tp, &rtl_ep_ocp_read_cond, 10, 10);
@@ -6089,6 +6094,8 @@ static void rtl_hw_start_8168ep(struct rtl8169_private *tp)
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
 
+	rtl8168ep_stop_cmac(tp);
+
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 
 	rtl_eri_write(tp, 0xc8, ERIAR_MASK_0101, 0x00080002, ERIAR_EXGMAC);
@@ -8002,6 +8009,12 @@ static void rtl_hw_init_8168g(struct rtl8169_private *tp)
 		return;
 }
 
+static void rtl_hw_init_8168ep(struct rtl8169_private *tp)
+{
+	rtl8168ep_stop_cmac(tp);
+	rtl_hw_init_8168g(tp);
+}
+
 static void rtl_hw_initialize(struct rtl8169_private *tp)
 {
 	switch (tp->mac_version) {
@@ -8014,12 +8027,13 @@ static void rtl_hw_initialize(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_46:
 	case RTL_GIGA_MAC_VER_47:
 	case RTL_GIGA_MAC_VER_48:
+		rtl_hw_init_8168g(tp);
+		break;
 	case RTL_GIGA_MAC_VER_49:
 	case RTL_GIGA_MAC_VER_50:
 	case RTL_GIGA_MAC_VER_51:
-		rtl_hw_init_8168g(tp);
+		rtl_hw_init_8168ep(tp);
 		break;
-
 	default:
 		break;
 	}
-- 
1.9.1
