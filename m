From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 13/19] r8169: remove unnecessary read of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 12:46:31 -0500
Message-ID: <1309196791-16157-1-git-send-email-jdmason@kudzu.us>
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:48728 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab1F0Rqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 13:46:36 -0400
Received: by pvg12 with SMTP id 12so2993071pvg.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 10:46:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCIE capability offset is saved during PCI bus walking.  Use the
value from pci_dev instead of checking in the driver and saving it off
the the driver specific structure.  Also, it will remove an unnecessary
search in the PCI configuration space if this value is referenced
instead of reacquiring it.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/r8169.c |   20 ++++++--------------
 1 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f8c4435..fbd6838 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -659,7 +659,6 @@ struct rtl8169_private {
 	unsigned int (*phy_reset_pending)(struct rtl8169_private *tp);
 	unsigned int (*link_ok)(void __iomem *);
 	int (*do_ioctl)(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd);
-	int pcie_cap;
 	struct delayed_work task;
 	unsigned features;
 
@@ -3444,9 +3443,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	tp->mmio_addr = ioaddr;
 
-	tp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	if (!tp->pcie_cap)
-		netif_info(tp, probe, dev, "no PCI Express capability\n");
+	if (!pci_is_pcie(pdev))
+		netif_info(tp, probe, dev, "not PCI Express\n");
 
 	RTL_W16(IntrMask, 0x0000);
 
@@ -3898,9 +3896,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 static void rtl_tx_performance_tweak(struct pci_dev *pdev, u16 force)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct rtl8169_private *tp = netdev_priv(dev);
-	int cap = tp->pcie_cap;
+	int cap = pci_pcie_cap(pdev);
 
 	if (cap) {
 		u16 ctl;
@@ -3948,9 +3944,7 @@ static void rtl_ephy_init(void __iomem *ioaddr, const struct ephy_info *e, int l
 
 static void rtl_disable_clock_request(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct rtl8169_private *tp = netdev_priv(dev);
-	int cap = tp->pcie_cap;
+	int cap = pci_pcie_cap(pdev);
 
 	if (cap) {
 		u16 ctl;
@@ -3963,9 +3957,7 @@ static void rtl_disable_clock_request(struct pci_dev *pdev)
 
 static void rtl_enable_clock_request(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct rtl8169_private *tp = netdev_priv(dev);
-	int cap = tp->pcie_cap;
+	int cap = pci_pcie_cap(pdev);
 
 	if (cap) {
 		u16 ctl;
@@ -4395,7 +4387,7 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_13 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_16) {
-		int cap = tp->pcie_cap;
+		int cap = pci_pcie_cap(pdev);
 
 		if (cap) {
 			pci_write_config_word(pdev, cap + PCI_EXP_DEVCTL,
-- 
1.7.5.4

