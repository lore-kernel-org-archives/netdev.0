From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 8/13] r8169: Tx performance tweak
Date: Tue, 1 Jul 2008 23:40:18 +0200
Message-ID: <20080701214017.GA26810@electric-eye.fr.zoreil.com>
References: <20080629143817.GA1540@electric-eye.fr.zoreil.com> <20080629144526.GI1540@electric-eye.fr.zoreil.com> <20080630105357.GH4050@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, akpm@linux-foundation.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Mario Limonciello <mario_limonciello@dell.com>,
	Kasper Sandberg <lkml@metanurb.dk>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42132 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752655AbYGAVku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 17:40:50 -0400
Content-Disposition: inline
In-Reply-To: <20080630105357.GH4050@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> :
[...]
> This would be a lot more understandable if you used pci_find_capability()
> and the named constants from <linux/pci_regs.h>:
> 
> #define PCI_EXP_DEVCTL          8       /* Device Control */
> #define  PCI_EXP_DEVCTL_NOSNOOP_EN 0x0800  /* Enable No Snoop */
> #define  PCI_EXP_DEVCTL_READRQ  0x7000  /* Max_Read_Request_Size */

Something like the patch below ?

Subject: [PATCH] r8169: use pci_find_capability for the PCI-E features

Remove the use of register 0x69 in the configuration space until
better informed.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   33 +++++++++++++++++++++++----------
 1 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 84e6fc4..8d18bb6 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2284,19 +2284,32 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	RTL_W16(IntrMask, tp->intr_event);
 }
 
-static void rtl8168_tx_performance_tweak(struct pci_dev *pdev,
-					 unsigned int reg, u8 force)
+static void rtl8168_tx_performance_tweak(struct pci_dev *pdev, u16 force)
 {
-	u8 ctl;
+	int cap;
 
-	pci_read_config_byte(pdev, reg, &ctl);
-	ctl = (ctl & ~0x70) | force;
-	pci_write_config_byte(pdev, reg, ctl);
+	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+	if (cap != 0) {
+		u16 ctl;
+
+		pci_read_config_word(pdev, cap + PCI_EXP_DEVCTL, &ctl);
+		ctl = (ctl & ~PCI_EXP_DEVCTL_READRQ) | force;
+		pci_write_config_word(pdev, cap + PCI_EXP_DEVCTL, ctl);
+	}
 }
 
 static void rtl8168_disable_clock_request(struct pci_dev *pdev)
 {
-	pci_write_config_byte(pdev, 0x81, 0x00);
+	int cap;
+
+	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+	if (cap != 0) {
+		u16 ctl;
+
+		pci_read_config_word(pdev, cap + PCI_EXP_LNKCTL, &ctl);
+		ctl &= ~PCI_EXP_LNKCTL_CLKREQ_EN;
+		pci_write_config_word(pdev, cap + PCI_EXP_LNKCTL, ctl);
+	}
 }
 
 /*
@@ -2346,7 +2359,7 @@ static void rtl_hw_start_8168bb(void __iomem *ioaddr, struct pci_dev *pdev)
 
 	rtl8168c_cpcmd_quirk(ioaddr);
 
-	rtl8168_tx_performance_tweak(pdev, 0x69, 0x58);
+	rtl8168_tx_performance_tweak(pdev, 0x5000 | PCI_EXP_DEVCTL_NOSNOOP_EN);
 }
 
 static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
@@ -2364,7 +2377,7 @@ static void __rtl_hw_start_8168cpx(void __iomem *ioaddr, struct pci_dev *pdev)
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
-	rtl8168_tx_performance_tweak(pdev, 0x79, 0x50);
+	rtl8168_tx_performance_tweak(pdev, 0x5000);
 
 	rtl8168_disable_clock_request(pdev);
 
@@ -2437,7 +2450,7 @@ static void rtl_hw_start_8168cy(void __iomem *ioaddr, struct pci_dev *pdev)
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
-	rtl8168_tx_performance_tweak(pdev, 0x79, 0x50);
+	rtl8168_tx_performance_tweak(pdev, 0x5000);
 
 	rtl8168c_cpcmd_quirk(ioaddr);
 }
-- 
1.5.3.3

