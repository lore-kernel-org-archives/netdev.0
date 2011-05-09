From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 8/8] r8169: avoid late chip identifier initialisation.
Date: Mon, 9 May 2011 21:07:22 +0200
Message-ID: <20110509190722.GH20687@electric-eye.fr.zoreil.com>
References: <20110509190446.GA6053@electric-eye.fr.zoreil.com> <20110509190205.GA20677@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ciprian Docan <docan@eden.rutgers.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58773 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377Ab1EITRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:17:01 -0400
Content-Disposition: inline
In-Reply-To: <20110509190205.GA20677@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unknown 8168 chips did not have any PLL power method set as they
did not inherit a default family soon enough. Fix it.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
---
 drivers/net/r8169.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4f1d45b..04f4e60 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1606,8 +1606,9 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
 };
 
 static void rtl8169_get_mac_version(struct rtl8169_private *tp,
-				    void __iomem *ioaddr)
+				    struct net_device *dev, u8 default_version)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	/*
 	 * The driver currently handles the 8168Bf and the 8168Be identically
 	 * but they can be identified more specifically through the test below
@@ -1694,6 +1695,12 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 	while ((reg & p->mask) != p->val)
 		p++;
 	tp->mac_version = p->mac_version;
+
+	if (tp->mac_version == RTL_GIGA_MAC_NONE) {
+		netif_notice(tp, probe, dev,
+			     "unknown MAC, using family default\n");
+		tp->mac_version = default_version;
+	}
 }
 
 static void rtl8169_print_mac_version(struct rtl8169_private *tp)
@@ -3353,7 +3360,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_set_master(pdev);
 
 	/* Identify chip attached to board */
-	rtl8169_get_mac_version(tp, ioaddr);
+	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
 
 	/*
 	 * Pretend we are using VLANs; This bypasses a nasty bug where
@@ -3365,13 +3372,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	rtl_init_mdio_ops(tp);
 	rtl_init_pll_power_ops(tp);
 
-	/* Use appropriate default if unknown */
-	if (tp->mac_version == RTL_GIGA_MAC_NONE) {
-		netif_notice(tp, probe, dev,
-			     "unknown MAC, using family default\n");
-		tp->mac_version = cfg->default_ver;
-	}
-
 	rtl8169_print_mac_version(tp);
 
 	chipset = tp->mac_version;
-- 
1.7.4.4

