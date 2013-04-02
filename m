From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH v2 net-next 7/8] r8169: adjust the flow of hw_start
Date: Tue, 2 Apr 2013 16:23:41 +0800
Message-ID: <1364891022-3220-7-git-send-email-hayeswang@realtek.com>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com>
 <1364891022-3220-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364891022-3220-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The suggestion as following:
- initial settings or default settings
- rtl_hw_start_xxx. rtl_hw_start_xxx may change some default settings.
- enable tx/rx. This has to be after the above two steps.
- rtl_set_rx_mode. AcceptXXXs have to be enabled after enabling tx/rx.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 573b693..85536bf 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5240,10 +5240,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
-	rtl_set_rx_mode(dev);
-
-	RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
-		(InterFrameGap << TxInterFrameGapShift));
+	rtl_set_rx_tx_config_registers(tp);
 
 	RTL_R8(IntrMask);
 
@@ -5330,9 +5327,11 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		break;
 	}
 
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
-	RTL_W8(Cfg9346, Cfg9346_Lock);
+	rtl_set_rx_mode(dev);
 
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 }
@@ -5490,6 +5489,17 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
+	RTL_W8(MaxTxPacketSize, TxPacketMax);
+
+	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
+
+	tp->cp_cmd &= ~R810X_CPCMD_QUIRK_MASK;
+	RTL_W16(CPlusCmd, tp->cp_cmd);
+
+	rtl_set_rx_tx_desc_registers(tp, ioaddr);
+
+	rtl_set_rx_tx_config_registers(tp);
+
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_07:
 		rtl_hw_start_8102e_1(tp);
@@ -5521,24 +5531,14 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	RTL_W8(MaxTxPacketSize, TxPacketMax);
-
-	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
-
-	tp->cp_cmd &= ~R810X_CPCMD_QUIRK_MASK;
-	RTL_W16(CPlusCmd, tp->cp_cmd);
-
 	RTL_W16(IntrMitigate, 0x0000);
 
-	rtl_set_rx_tx_desc_registers(tp, ioaddr);
-
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
-	rtl_set_rx_tx_config_registers(tp);
-
-	RTL_R8(IntrMask);
 
 	rtl_set_rx_mode(dev);
 
+	RTL_R8(IntrMask);
+
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xf000);
 }
 
-- 
1.8.1
