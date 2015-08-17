From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH net-next]:r8169: Add and modify some parameters
Date: Mon, 17 Aug 2015 13:26:14 +0300
Message-ID: <1439807174-2702-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:34157 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbbHQK02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 06:26:28 -0400
Received: by wicne3 with SMTP id ne3so70886321wic.1
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 03:26:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set InterFrame Gap time as largest posible for comp.   Add
 InterFrameGap2 bit set on start.

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index eb2d2a4..ea0f327 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -86,7 +86,8 @@ static const int multicast_filter_limit = 32;
 
 #define MAX_READ_REQUEST_SHIFT	12
 #define TX_DMA_BURST	7	/* Maximum PCI burst, '7' is unlimited */
-#define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
+#define InterFrameGap	0x02	/* 2 means InterFrameGap = the largest one */
+#define InterFrameGap2	0x80000
 
 #define R8169_REGS_SIZE		256
 #define R8169_NAPI_WEIGHT	64
@@ -5180,7 +5181,7 @@ static void rtl_set_rx_tx_config_registers(struct rtl8169_private *tp)
 
 	/* Set DMA burst size and Interframe Gap Time */
 	RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
-		(InterFrameGap << TxInterFrameGapShift));
+		(InterFrameGap << TxInterFrameGapShift) | InterFrameGap2);
 }
 
 static void rtl_hw_start(struct net_device *dev)
@@ -7470,15 +7471,22 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 	u16 enable_mask = RTL_EVENT_NAPI | tp->event_slow;
 	int work_done= 0;
 	u16 status;
+        int tx_force = 1;
 
 	status = rtl_get_events(tp);
 	rtl_ack_events(tp, status & ~tp->event_slow);
-
+       if (netif_running(dev)) {
 	if (status & RTL_EVENT_NAPI_RX)
 		work_done = rtl_rx(dev, tp, (u32) budget);
+                
 
 	if (status & RTL_EVENT_NAPI_TX)
 		rtl_tx(dev, tp);
+         else if (tx_force == 1) {
+                mdelay(10);
+                rtl_tx(dev, tp);
+         }
+        }
 
 	if (status & tp->event_slow) {
 		enable_mask &= ~tp->event_slow;
-- 
2.1.4
