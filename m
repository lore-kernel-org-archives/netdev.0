From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 7/13] r8169: make room for more specific 8168 hardware
	start procedure
Date: Sun, 29 Jun 2008 16:44:44 +0200
Message-ID: <20080629144444.GH1540@electric-eye.fr.zoreil.com>
References: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, akpm@linux-foundation.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Mario Limonciello <mario_limonciello@dell.com>,
	Kasper Sandberg <lkml@metanurb.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38247 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760161AbYF2OpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 10:45:07 -0400
Content-Disposition: inline
In-Reply-To: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Broadly speaking the 8168c* share some common code which will
be factored in __rtl_hw_start_8168cpx. The 8168b* share some
code too but it will be a bit different.

Any change of behavior should be confined to the currently
unidentified 8168 chipsets. They will not be applied the Tx
performance tweak and will emit a warning instead.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   58 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 57 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5c7f23d..c2861a4 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2166,6 +2166,36 @@ static void rtl8168_tx_performance_tweak(struct pci_dev *pdev, unsigned int reg
 	pci_write_config_byte(pdev, reg, ctl);
 }
 
+static void rtl_hw_start_8168bb(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl8168_tx_performance_tweak(pdev, 0x69);
+}
+
+static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_hw_start_8168bb(ioaddr, pdev);
+}
+
+static void __rtl_hw_start_8168cpx(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl8168_tx_performance_tweak(pdev, 0x69);
+}
+
+static void rtl_hw_start_8168c(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	__rtl_hw_start_8168cpx(ioaddr, pdev);
+}
+
+static void rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	__rtl_hw_start_8168cpx(ioaddr, pdev);
+}
+
+static void rtl_hw_start_8168cx(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	__rtl_hw_start_8168cpx(ioaddr, pdev);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2201,7 +2231,33 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	RTL_R8(IntrMask);
 
-	rtl8168_tx_performance_tweak(pdev, 0x69);
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_11:
+		rtl_hw_start_8168bb(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_12:
+	case RTL_GIGA_MAC_VER_17:
+		rtl_hw_start_8168bef(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_18:
+		rtl_hw_start_8168cp(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_19:
+		rtl_hw_start_8168c(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_20:
+		rtl_hw_start_8168cx(ioaddr, pdev);
+	break;
+
+	default:
+		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
+			dev->name, tp->mac_version);
+	break;
+	}
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
-- 
1.5.3.3

