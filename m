From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 1/2] r8169: Correct settings of rtl8102e
Date: Thu, 17 Feb 2011 19:37:47 +0800
Message-ID: <1297942668-23274-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:52240 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716Ab1BQLkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 06:40:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adjust and remove certain settings of RTL8102E which are for previous chips.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   20 ++++++--------------
 1 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 59ccf0c..9eaf78f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3042,7 +3042,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_mwi_2;
 	}
 
-	tp->cp_cmd = PCIMulRW | RxChkSum;
+	tp->cp_cmd = RxChkSum;
 
 	if ((sizeof(dma_addr_t) > 4) &&
 	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) && use_dac) {
@@ -3845,8 +3845,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	Cxpl_dbg_sel | \
 	ASF | \
 	PktCntrDisable | \
-	PCIDAC | \
-	PCIMulRW)
+	Mac_dbgo_sel)
 
 static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 {
@@ -3876,8 +3875,6 @@ static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	if ((cfg1 & LEDS0) && (cfg1 & LEDS1))
 		RTL_W8(Config1, cfg1 & ~LEDS0);
 
-	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R810X_CPCMD_QUIRK_MASK);
-
 	rtl_ephy_init(ioaddr, e_info_8102e_1, ARRAY_SIZE(e_info_8102e_1));
 }
 
@@ -3889,8 +3886,6 @@ static void rtl_hw_start_8102e_2(void __iomem *ioaddr, struct pci_dev *pdev)
 
 	RTL_W8(Config1, MEMMAP | IOMAP | VPD | PMEnable);
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
-
-	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R810X_CPCMD_QUIRK_MASK);
 }
 
 static void rtl_hw_start_8102e_3(void __iomem *ioaddr, struct pci_dev *pdev)
@@ -3916,6 +3911,8 @@ static void rtl_hw_start_8101(struct net_device *dev)
 		}
 	}
 
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_07:
 		rtl_hw_start_8102e_1(ioaddr, pdev);
@@ -3930,14 +3927,13 @@ static void rtl_hw_start_8101(struct net_device *dev)
 		break;
 	}
 
-	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
 	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
-	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
-
+	tp->cp_cmd &= ~R810X_CPCMD_QUIRK_MASK;
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 
 	RTL_W16(IntrMitigate, 0x0000);
@@ -3947,14 +3943,10 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	rtl_set_rx_tx_config_registers(tp);
 
-	RTL_W8(Cfg9346, Cfg9346_Lock);
-
 	RTL_R8(IntrMask);
 
 	rtl_set_rx_mode(dev);
 
-	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
-
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xf000);
 
 	RTL_W16(IntrMask, tp->intr_event);
-- 
1.7.3.2

