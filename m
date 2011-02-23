From: Francois Romieu <romieu@fr.zoreil.com>
Subject: pull request: r8169 driver fixes
Date: Wed, 23 Feb 2011 23:53:57 +0100
Message-ID: <20110223225357.GA12821@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49168 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460Ab1BWW5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 17:57:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'r8169-davem' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169-davem

to get the changes below.

Short pktgen regression test (45M 64 bytes packets incoming + ping -f -q ...
outgoing). No crash, link ok, system responsive with :
- RTL_GIGA_MAC_VER_09 (RTL8102E-VB-GR)
- RTL_GIGA_MAC_VER_09 (RTL8103E-GR)
- RTL_GIGA_MAC_VER_12
- RTL_GIGA_MAC_VER_25 (RTL8168D-GR)
- RTL_GIGA_MAC_VER_26 (RTL8111D-VB-GR)
  It does not crash but it resets a lot and slows the emitter.

RTL_GIGA_MAC_VER_06 does not recover the link very well when stressed but
it is unrelated.

Distance from 'davem' (d3bd1b4c89cceca42211cd5bd30508b903267229)
-----------------------------------------------------------------

5d2e19572a66be1e349faba289b7bd049b85bc98
d24e9aafe5d5dfdf6d114b29e67f8afd5fae5ef0
fac5b3caa1f5bc07ecfb4f5ce98f8112638dc8fb

Diffstat
--------

 drivers/net/r8169.c |   42 +++++++++++++++++++++++-------------------
 1 files changed, 23 insertions(+), 19 deletions(-)

Shortlog
--------

Hayes Wang (3):
      r8169: fix incorrect args to oob notify.
      r8169: correct settings of rtl8102e.
      r8169: fix RTL8168DP power off issue.

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 469ab0b..ef2133b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -617,8 +617,9 @@ static void ocp_write(struct rtl8169_private *tp, u8 mask, u16 reg, u32 data)
 	}
 }
 
-static void rtl8168_oob_notify(void __iomem *ioaddr, u8 cmd)
+static void rtl8168_oob_notify(struct rtl8169_private *tp, u8 cmd)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
 	RTL_W8(ERIDR, cmd);
@@ -630,7 +631,7 @@ static void rtl8168_oob_notify(void __iomem *ioaddr, u8 cmd)
 			break;
 	}
 
-	ocp_write(ioaddr, 0x1, 0x30, 0x00000001);
+	ocp_write(tp, 0x1, 0x30, 0x00000001);
 }
 
 #define OOB_CMD_RESET		0x00
@@ -2868,8 +2869,11 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27)
+	if (((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
+	     (tp->mac_version == RTL_GIGA_MAC_VER_28)) &&
+	    (ocp_read(tp, 0x0f, 0x0010) & 0x00008000)) {
 		return;
+	}
 
 	if (((tp->mac_version == RTL_GIGA_MAC_VER_23) ||
 	     (tp->mac_version == RTL_GIGA_MAC_VER_24)) &&
@@ -2891,6 +2895,8 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_25:
 	case RTL_GIGA_MAC_VER_26:
+	case RTL_GIGA_MAC_VER_27:
+	case RTL_GIGA_MAC_VER_28:
 		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
 		break;
 	}
@@ -2900,12 +2906,17 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27)
+	if (((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
+	     (tp->mac_version == RTL_GIGA_MAC_VER_28)) &&
+	    (ocp_read(tp, 0x0f, 0x0010) & 0x00008000)) {
 		return;
+	}
 
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_25:
 	case RTL_GIGA_MAC_VER_26:
+	case RTL_GIGA_MAC_VER_27:
+	case RTL_GIGA_MAC_VER_28:
 		RTL_W8(PMCH, RTL_R8(PMCH) | 0x80);
 		break;
 	}
@@ -3042,7 +3053,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_mwi_2;
 	}
 
-	tp->cp_cmd = PCIMulRW | RxChkSum;
+	tp->cp_cmd = RxChkSum;
 
 	if ((sizeof(dma_addr_t) > 4) &&
 	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) && use_dac) {
@@ -3318,7 +3329,8 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	/* Disable interrupts */
 	rtl8169_irq_mask_and_ack(ioaddr);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_28) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_28) {
 		while (RTL_R8(TxPoll) & NPQ)
 			udelay(20);
 
@@ -3847,8 +3859,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	Cxpl_dbg_sel | \
 	ASF | \
 	PktCntrDisable | \
-	PCIDAC | \
-	PCIMulRW)
+	Mac_dbgo_sel)
 
 static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 {
@@ -3878,8 +3889,6 @@ static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	if ((cfg1 & LEDS0) && (cfg1 & LEDS1))
 		RTL_W8(Config1, cfg1 & ~LEDS0);
 
-	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R810X_CPCMD_QUIRK_MASK);
-
 	rtl_ephy_init(ioaddr, e_info_8102e_1, ARRAY_SIZE(e_info_8102e_1));
 }
 
@@ -3891,8 +3900,6 @@ static void rtl_hw_start_8102e_2(void __iomem *ioaddr, struct pci_dev *pdev)
 
 	RTL_W8(Config1, MEMMAP | IOMAP | VPD | PMEnable);
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
-
-	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R810X_CPCMD_QUIRK_MASK);
 }
 
 static void rtl_hw_start_8102e_3(void __iomem *ioaddr, struct pci_dev *pdev)
@@ -3918,6 +3925,8 @@ static void rtl_hw_start_8101(struct net_device *dev)
 		}
 	}
 
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_07:
 		rtl_hw_start_8102e_1(ioaddr, pdev);
@@ -3932,14 +3941,13 @@ static void rtl_hw_start_8101(struct net_device *dev)
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
@@ -3949,14 +3957,10 @@ static void rtl_hw_start_8101(struct net_device *dev)
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
Ueimor
