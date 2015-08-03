From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH] r8169: Permit users to change transmit and receive max pachet size
Date: Mon,  3 Aug 2015 10:28:38 +0300
Message-ID: <1438586918-12689-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34568 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbbHCH2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 03:28:53 -0400
Received: by wibud3 with SMTP id ud3so123806185wib.1
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 00:28:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Realtek nic its very versatile and have more registers for
 optimise  and solve different issues.  I added 2 parameters rx_buf_sz and
 txpacketmax  1.Parameter rx_buf_sz represent Receive Packet Maximum size and
 on   this program is 16383 bytes, eg RTL 8101E use 16000 and user may use  
 alls values up to maximum but value great from zero.   If a received packet
 of packet length larger than the value set here, then it will set  both RWT
 and RES bits in the corresponding Rx Status Descriptor. If the packet,  which
 is larger than the RMS value, is received without CRC error, it is still a
 good  packet, although both RWT and RES bits are set in the corresponding Rx
 Status  Descriptor.  2. Parameter txpacketmax represent Max Transmit Packet
 Size value must be on  range 1-63.Do not put zero on any situation.Every
 field from range 1-63 have  128 bytes.  For regular LAN applications, i.e.,
 the max packet size is either 1518 or 1522 (VLAN) bytes, this field must be
 larger than the max packet size. E.g., 0x0C. On mee working good with
 txpacketmax=60 and rx_buf_sz=1600

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3df51fa..5a942c5 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -345,6 +345,7 @@ static const struct pci_device_id rtl8169_pci_tbl[] = {
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
 static int rx_buf_sz = 16383;
+static int txpacketmax = 63;
 static int use_dac;
 static struct {
 	u32 msg_enable;
@@ -406,7 +407,7 @@ enum rtl_registers {
 
 	MaxTxPacketSize	= 0xec,	/* 8101/8168. Unit of 128 bytes. */
 
-#define TxPacketMax	(8064 >> 7)
+//#define TxPacketMax	(8064 >> 7)
 #define EarlySize	0x27
 
 	FuncEvent	= 0xf0,
@@ -850,6 +851,10 @@ module_param(use_dac, int, 0);
 MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
 module_param_named(debug, debug.msg_enable, int, 0);
 MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 16=all)");
+module_param(rx_buf_sz, int, 0);
+MODULE_PARM_DESC(rx_buf_sz, "Receive Packet Maximum Size. ");
+module_param(txpacketmax, int, 0);
+MODULE_PARM_DESC(txpacketmax, "Max Transmit Packet Size. ");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(RTL8169_VERSION);
 MODULE_FIRMWARE(FIRMWARE_8168D_1);
@@ -5593,7 +5598,7 @@ static void rtl_hw_start_8168bef(struct rtl8169_private *tp)
 
 	rtl_hw_start_8168bb(tp);
 
-	RTL_W8(MaxTxPacketSize, TxPacketMax);
+	RTL_W8(MaxTxPacketSize, txpacketmax);
 
 	RTL_W8(Config4, RTL_R8(Config4) & ~(1 << 0));
 }
@@ -5659,7 +5664,7 @@ static void rtl_hw_start_8168cp_3(struct rtl8169_private *tp)
 	/* Magic. */
 	RTL_W8(DBG_REG, 0x20);
 
-	RTL_W8(MaxTxPacketSize, TxPacketMax);
+	RTL_W8(MaxTxPacketSize, txpacketmax);
 
 	if (tp->dev->mtu <= ETH_DATA_LEN)
 		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
@@ -5720,7 +5725,7 @@ static void rtl_hw_start_8168d(struct rtl8169_private *tp)
 
 	rtl_disable_clock_request(pdev);
 
-	RTL_W8(MaxTxPacketSize, TxPacketMax);
+	RTL_W8(MaxTxPacketSize, txpacketmax);
 
 	if (tp->dev->mtu <= ETH_DATA_LEN)
 		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
@@ -5738,7 +5743,7 @@ static void rtl_hw_start_8168dp(struct rtl8169_private *tp)
 	if (tp->dev->mtu <= ETH_DATA_LEN)
 		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
-	RTL_W8(MaxTxPacketSize, TxPacketMax);
+	RTL_W8(MaxTxPacketSize, txpacketmax);
 
 	rtl_disable_clock_request(pdev);
 }
@@ -5758,7 +5763,7 @@ static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
-	RTL_W8(MaxTxPacketSize, TxPacketMax);
+	RTL_W8(MaxTxPacketSize, txpacketmax);
 
 	for (i = 0; i < ARRAY_SIZE(e_info_8168d_4); i++) {
 		const struct ephy_info *e = e_info_8168d_4 + i;
@@ -5798,7 +5803,7 @@ static void rtl_hw_start_8168e_1(struct rtl8169_private *tp)
 	if (tp->dev->mtu <= ETH_DATA_LEN)
 		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
-	RTL_W8(MaxTxPacketSize, TxPacketMax);
+	RTL_W8(MaxTxPacketSize, txpacketmax);
 
 	rtl_disable_clock_request(pdev);
 
@@ -6227,7 +6232,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
-	RTL_W8(MaxTxPacketSize, TxPacketMax);
+	RTL_W8(MaxTxPacketSize, txpacketmax);
 
 	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
@@ -6521,7 +6526,7 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
-	RTL_W8(MaxTxPacketSize, TxPacketMax);
+	RTL_W8(MaxTxPacketSize, txpacketmax);
 
 	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
-- 
2.1.4
