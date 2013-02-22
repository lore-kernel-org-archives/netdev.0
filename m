From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 54231] r8169 driver regression caused by the commit
 aee77e4accbeb2c86b1d294cd84fec4a12dde3bd
Date: Fri, 22 Feb 2013 09:55:46 -0800
Message-ID: <20130222095546.396e63a8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:52212 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755845Ab3BVR4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 12:56:09 -0500
Received: by mail-pa0-f42.google.com with SMTP id kq12so594628pab.15
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 09:56:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 22 Feb 2013 08:41:04 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 54231] r8169 driver regression caused by the commit aee77e4accbeb2c86b1d294cd84fec4a12dde3bd


https://bugzilla.kernel.org/show_bug.cgi?id=54231





--- Comment #1 from Tomi Orava <tomimo@ncircle.nullnet.fi>  2013-02-22 16:40:49 ---
Although the r8169 has been working just fine on 3.4.31 for the past 5 days, it
seems that I missed the second DMA Burst setting in the previous patch that
should get fixed as well:

--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -77,6 +77,7 @@
 static const int multicast_filter_limit = 32;

 #define MAX_READ_REQUEST_SHIFT    12
+#define TX_DMA_BURST_512        5       /* Maximum PCI burst, limited to 512
*/
 #define TX_DMA_BURST    7    /* Maximum PCI burst, '7' is unlimited */
 #define InterFrameGap    0x03    /* 3 means InterFrameGap = the shortest one
*/

@@ -4406,8 +4407,14 @@ static void rtl_set_rx_tx_config_registers(struct
rtl8169_private *tp)
     void __iomem *ioaddr = tp->mmio_addr;

     /* Set DMA burst size and Interframe Gap Time */
-    RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
-        (InterFrameGap << TxInterFrameGapShift));
+
+    if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
+        RTL_W32(TxConfig, (TX_DMA_BURST_512 << TxDMAShift) |
+            (InterFrameGap << TxInterFrameGapShift));
+    } else {
+        RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
+            (InterFrameGap << TxInterFrameGapShift));
+    }
 }

 static void rtl_hw_start(struct net_device *dev)
@@ -5148,8 +5155,13 @@ static void rtl_hw_start_8168(struct net_device *dev)

     rtl_set_rx_mode(dev);

-    RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
-        (InterFrameGap << TxInterFrameGapShift));
+    if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
+        RTL_W32(TxConfig, (TX_DMA_BURST_512 << TxDMAShift) |
+            (InterFrameGap << TxInterFrameGapShift));
+    } else {
+        RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
+            (InterFrameGap << TxInterFrameGapShift));
+    }

     RTL_R8(IntrMask);

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
