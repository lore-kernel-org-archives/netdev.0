From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 03/13] r8169: convert bitfield to plain enum mask
Date: Thu, 18 Oct 2007 23:00:49 +0200
Message-ID: <20071018210049.GD31724@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36953 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759408AbXJRVHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 17:07:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9c11087..16ecba1 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -381,6 +381,10 @@ struct ring_info {
 	u8		__pad[sizeof(void *) - sizeof(u32)];
 };
 
+enum features {
+	RTL_FEATURE_WOL	= (1 << 0),
+};
+
 struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;	/* Index of PCI device */
@@ -421,7 +425,7 @@ struct rtl8169_private {
 	unsigned int (*phy_reset_pending)(void __iomem *);
 	unsigned int (*link_ok)(void __iomem *);
 	struct delayed_work task;
-	unsigned wol_enabled : 1;
+	unsigned features;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -627,7 +631,10 @@ static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	tp->wol_enabled = (wol->wolopts) ? 1 : 0;
+	if (wol->wolopts)
+		tp->features |= RTL_FEATURE_WOL;
+	else
+		tp->features &= ~RTL_FEATURE_WOL;
 
 	spin_unlock_irq(&tp->lock);
 
@@ -3045,7 +3052,8 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 
 out_pci_suspend:
 	pci_save_state(pdev);
-	pci_enable_wake(pdev, pci_choose_state(pdev, state), tp->wol_enabled);
+	pci_enable_wake(pdev, pci_choose_state(pdev, state),
+		(tp->features & RTL_FEATURE_WOL) ? 1 : 0);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
 	return 0;
-- 
1.5.2.4

