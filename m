From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 07/21] r8169: populate the hw_start handler for the 8168
Date: Fri, 29 Jun 2007 22:23:58 +0200
Message-ID: <20070629202358.GI3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41539 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753407AbXF2UYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:24:25 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rtl_hw_start_8168 inherits the content of rtl_hw_start_8169 minus
the code which depends on RTL_GIGA_MAC_VER_XY (XY != {11/12}).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   34 +++++++++++++++++++++++++++++++---
 1 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f549f09..2478ece 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -156,8 +156,8 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_03 = 0x02,
 	RTL_GIGA_MAC_VER_04 = 0x03,
 	RTL_GIGA_MAC_VER_05 = 0x04,
-	RTL_GIGA_MAC_VER_11 = 0x0b,
-	RTL_GIGA_MAC_VER_12 = 0x0c,
+	RTL_GIGA_MAC_VER_11 = 0x0b, // 8168Bb
+	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be 8168Bf
 	RTL_GIGA_MAC_VER_13 = 0x0d,
 	RTL_GIGA_MAC_VER_14 = 0x0e,
 	RTL_GIGA_MAC_VER_15 = 0x0f
@@ -1969,7 +1969,35 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 static void rtl_hw_start_8168(struct net_device *dev)
 {
-	rtl_hw_start_8169(dev);
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+
+	RTL_W8(EarlyTxThres, EarlyTxThld);
+
+	rtl_set_rx_max_size(ioaddr);
+
+	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
+
+	RTL_W16(CPlusCmd, tp->cp_cmd);
+
+	RTL_W16(IntrMitigate, 0x0000);
+
+	rtl_set_rx_tx_desc_registers(tp, ioaddr);
+
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+	rtl_set_rx_tx_config_registers(tp);
+
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
+	RTL_R8(IntrMask);
+
+	RTL_W32(RxMissed, 0);
+
+	rtl_set_rx_mode(dev);
+
+	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 }
 
 static void rtl_hw_start_8101(struct net_device *dev)
-- 
1.4.4.2

