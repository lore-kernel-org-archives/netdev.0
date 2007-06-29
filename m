From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 06/21] r8169: add helpers for per-device hw_start handler
Date: Fri, 29 Jun 2007 22:23:35 +0200
Message-ID: <20070629202335.GH3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41545 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753421AbXF2UYn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:24:43 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

They aim to limit the amount of moved code when the hw_start
handler gets more specialized.

No functional change.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   53 +++++++++++++++++++++++++++++++++-----------------
 1 files changed, 35 insertions(+), 18 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5e24a0c..f549f09 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1813,7 +1813,7 @@ static void rtl8169_hw_reset(void __iomem *ioaddr)
 	RTL_R8(ChipCmd);
 }
 
-static void rtl8169_set_rx_tx_config_registers(struct rtl8169_private *tp)
+static void rtl_set_rx_tx_config_registers(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 	u32 cfg = rtl8169_rx_config;
@@ -1851,6 +1851,35 @@ static void rtl_hw_start(struct net_device *dev)
 }
 
 
+static void rtl_set_rx_tx_desc_registers(struct rtl8169_private *tp,
+					 void __iomem *ioaddr)
+{
+	/*
+	 * Magic spell: some iop3xx ARM board needs the TxDescAddrHigh
+	 * register to be written before TxDescAddrLow to work.
+	 * Switching from MMIO to I/O access fixes the issue as well.
+	 */
+	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr) >> 32);
+	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr) & DMA_32BIT_MASK);
+	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr) >> 32);
+	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr) & DMA_32BIT_MASK);
+}
+
+static u16 rtl_rw_cpluscmd(void __iomem *ioaddr)
+{
+	u16 cmd;
+
+	cmd = RTL_R16(CPlusCmd);
+	RTL_W16(CPlusCmd, cmd);
+	return cmd;
+}
+
+static void rtl_set_rx_max_size(void __iomem *ioaddr)
+{
+	/* Low hurts. Let's disable the filtering. */
+	RTL_W16(RxMaxSize, 16383);
+}
+
 static void rtl_hw_start_8169(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1890,19 +1919,15 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
-	/* Low hurts. Let's disable the filtering. */
-	RTL_W16(RxMaxSize, 16383);
+	rtl_set_rx_max_size(ioaddr);
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
-		rtl8169_set_rx_tx_config_registers(tp);
+		rtl_set_rx_tx_config_registers(tp);
 
-	cmd = RTL_R16(CPlusCmd);
-	RTL_W16(CPlusCmd, cmd);
-
-	tp->cp_cmd |= cmd | PCIMulRW;
+	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
@@ -1919,22 +1944,14 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	 */
 	RTL_W16(IntrMitigate, 0x0000);
 
-	/*
-	 * Magic spell: some iop3xx ARM board needs the TxDescAddrHigh
-	 * register to be written before TxDescAddrLow to work.
-	 * Switching from MMIO to I/O access fixes the issue as well.
-	 */
-	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr >> 32));
-	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr & DMA_32BIT_MASK));
-	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr >> 32));
-	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr & DMA_32BIT_MASK));
+	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
 	if ((tp->mac_version != RTL_GIGA_MAC_VER_01) &&
 	    (tp->mac_version != RTL_GIGA_MAC_VER_02) &&
 	    (tp->mac_version != RTL_GIGA_MAC_VER_03) &&
 	    (tp->mac_version != RTL_GIGA_MAC_VER_04)) {
 		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
-		rtl8169_set_rx_tx_config_registers(tp);
+		rtl_set_rx_tx_config_registers(tp);
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
-- 
1.4.4.2

