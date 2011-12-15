From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: fix Config2 MSIEnable bit setting.
Date: Thu, 15 Dec 2011 19:37:43 +0100
Message-ID: <20111215183743.GA21677@electric-eye.fr.zoreil.com>
References: <CABJLtPHWfRLcbzDFR0ZXe4da3jv04eDZL2CabF1FTcaadoy0xQ@mail.gmail.com> <20111214213713.GA2907@electric-eye.fr.zoreil.com> <20111215.014359.1153990753442293322.davem@davemloft.net> <6678D92472CB4636B48A3D97ADE27BB9@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'David Miller'" <davem@davemloft.net>,
	"'nic_swsd'" <nic_swsd@realtek.com>, netdev@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45579 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756298Ab1LOSpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 13:45:19 -0500
Content-Disposition: inline
In-Reply-To: <6678D92472CB4636B48A3D97ADE27BB9@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MSIEnable bit is only available for the 8169.

Avoid Config2 writes for the post-8169 8168 and 810x.

Reported-by: Su Kang Yin <cantona@cantona.net>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 RTL_FEATURE_MSI has never been enabled for the 8169 itself. It could
 be -next material.

 drivers/net/ethernet/realtek/r8169.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 67bf078..c8f47f1 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -477,7 +477,6 @@ enum rtl_register_content {
 	/* Config1 register p.24 */
 	LEDS1		= (1 << 7),
 	LEDS0		= (1 << 6),
-	MSIEnable	= (1 << 5),	/* Enable Message Signaled Interrupt */
 	Speed_down	= (1 << 4),
 	MEMMAP		= (1 << 3),
 	IOMAP		= (1 << 2),
@@ -485,6 +484,7 @@ enum rtl_register_content {
 	PMEnable	= (1 << 0),	/* Power Management Enable */
 
 	/* Config2 register p. 25 */
+	MSIEnable	= (1 << 5),	/* 8169 only. Reserved in the 8168. */
 	PCI_Clock_66MHz = 0x01,
 	PCI_Clock_33MHz = 0x00,
 
@@ -3426,22 +3426,24 @@ static const struct rtl_cfg_info {
 };
 
 /* Cfg9346_Unlock assumed. */
-static unsigned rtl_try_msi(struct pci_dev *pdev, void __iomem *ioaddr,
+static unsigned rtl_try_msi(struct rtl8169_private *tp,
 			    const struct rtl_cfg_info *cfg)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned msi = 0;
 	u8 cfg2;
 
 	cfg2 = RTL_R8(Config2) & ~MSIEnable;
 	if (cfg->features & RTL_FEATURE_MSI) {
-		if (pci_enable_msi(pdev)) {
-			dev_info(&pdev->dev, "no MSI. Back to INTx.\n");
+		if (pci_enable_msi(tp->pci_dev)) {
+			netif_info(tp, hw, tp->dev, "no MSI. Back to INTx.\n");
 		} else {
 			cfg2 |= MSIEnable;
 			msi = RTL_FEATURE_MSI;
 		}
 	}
-	RTL_W8(Config2, cfg2);
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_06)
+		RTL_W8(Config2, cfg2);
 	return msi;
 }
 
@@ -4077,7 +4079,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		tp->features |= RTL_FEATURE_WOL;
 	if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0)
 		tp->features |= RTL_FEATURE_WOL;
-	tp->features |= rtl_try_msi(pdev, ioaddr, cfg);
+	tp->features |= rtl_try_msi(tp, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	if (rtl_tbi_enabled(tp)) {
-- 
1.7.6.4
