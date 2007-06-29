From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 08/21] r8169: populate the hw_start handler for the 8110
Date: Fri, 29 Jun 2007 22:24:25 +0200
Message-ID: <20070629202425.GJ3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46097 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754354AbXF2U2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:28:31 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Same thing as the previous change for rtl_hw_start_8168.

The 8101 related code in rtl_hw_start_8169 (see RTL_GIGA_MAC_VER_13)
goes away.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   47 ++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 38 insertions(+), 9 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 2478ece..56b9040 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -158,9 +158,9 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_05 = 0x04,
 	RTL_GIGA_MAC_VER_11 = 0x0b, // 8168Bb
 	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be 8168Bf
-	RTL_GIGA_MAC_VER_13 = 0x0d,
-	RTL_GIGA_MAC_VER_14 = 0x0e,
-	RTL_GIGA_MAC_VER_15 = 0x0f
+	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb 8101Ec
+	RTL_GIGA_MAC_VER_14 = 0x0e, // 8101
+	RTL_GIGA_MAC_VER_15 = 0x0f  // 8101
 };
 
 enum phy_version {
@@ -1892,11 +1892,6 @@ static void rtl_hw_start_8169(struct net_device *dev)
 		pci_write_config_byte(pdev, PCI_CACHE_LINE_SIZE, 0x08);
 	}
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_13) {
-		pci_write_config_word(pdev, 0x68, 0x00);
-		pci_write_config_word(pdev, 0x69, 0x08);
-	}
-
 	/* Undocumented stuff. */
 	if (tp->mac_version == RTL_GIGA_MAC_VER_05) {
 		/* Realtek's r1000_n.c driver uses '&& 0x01' here. Well... */
@@ -2002,7 +1997,41 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 static void rtl_hw_start_8101(struct net_device *dev)
 {
-	rtl_hw_start_8169(dev);
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_13) {
+		pci_write_config_word(pdev, 0x68, 0x00);
+		pci_write_config_word(pdev, 0x69, 0x08);
+	}
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
+	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xf000);
 }
 
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
-- 
1.4.4.2

