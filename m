From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 5/13] r8169: shuffle some registers handling around (8168
	operation only)
Date: Sun, 29 Jun 2008 16:43:12 +0200
Message-ID: <20080629144312.GF1540@electric-eye.fr.zoreil.com>
References: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, akpm@linux-foundation.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Mario Limonciello <mario_limonciello@dell.com>,
	Kasper Sandberg <lkml@metanurb.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38221 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759539AbYF2One (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 10:43:34 -0400
Content-Disposition: inline
In-Reply-To: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can not argue strongly for (or against) a specific ordering
on a purely technical ground but the patch avoids to swallow
Realtek's changes in one big, hard-to-read gulp.

Let aside the way the RxConfig register is written (see
rtl_set_rx_tx_config_registers / RxConfig / rtl_set_rx_mode),
this change brings the registers write ordering closer with
Realtek's driver one (version 8.006.00) for the 8168 chipsets.

The prototype of rtl8168_tx_performance_tweak illustrate the fact
that different 8168 chipsets will need to perform this sequence
of code at different addresses.

More 8168 specific code which touches the Configx registers will
be added in the section covered by Cfg9346_UnLock / Cfg9346_Lock.

This code should not be the cause of regression for 810x and
8110 users.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index d3c9db5..6394389 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2116,12 +2116,21 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	RTL_W16(IntrMask, tp->intr_event);
 }
 
+static void rtl8168_tx_performance_tweak(struct pci_dev *pdev, unsigned int reg
+)
+{
+	u8 ctl;
+
+	pci_read_config_byte(pdev, reg, &ctl);
+	ctl = (ctl & ~0x70) | 0x50;
+	pci_write_config_byte(pdev, reg, ctl);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
-	u8 ctl;
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
@@ -2129,17 +2138,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	rtl_set_rx_max_size(ioaddr);
 
-	rtl_set_rx_tx_config_registers(tp);
-
 	tp->cp_cmd |= RTL_R16(CPlusCmd) | PktCntrDisable | INTT_1;
 
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 
-	/* Tx performance tweak. */
-	pci_read_config_byte(pdev, 0x69, &ctl);
-	ctl = (ctl & ~0x70) | 0x50;
-	pci_write_config_byte(pdev, 0x69, ctl);
-
 	RTL_W16(IntrMitigate, 0x5151);
 
 	/* Work around for RxFIFO overflow. */
@@ -2150,16 +2152,21 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
-	RTL_W8(Cfg9346, Cfg9346_Lock);
+	rtl_set_rx_mode(dev);
 
-	RTL_R8(IntrMask);
+	RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
+		(InterFrameGap << TxInterFrameGapShift));
 
 	RTL_W32(RxMissed, 0);
 
-	rtl_set_rx_mode(dev);
+	RTL_R8(IntrMask);
+
+	rtl8168_tx_performance_tweak(pdev, 0x69);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 
 	RTL_W16(IntrMask, tp->intr_event);
-- 
1.5.3.3

