From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 5/5] r8169: do not enable the TBI for anything but the original 8169.
Date: Sat, 17 Sep 2011 11:59:11 +0200
Message-ID: <20110917095911.GF21630@electric-eye.fr.zoreil.com>
References: <20110917095617.GA21630@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54306 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753721Ab1IQJ7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 05:59:48 -0400
Content-Disposition: inline
In-Reply-To: <20110917095617.GA21630@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TBI bit in PHYStatus is reserved on anything but the oldest 8169.

Nobody complained after I disabled it for the 8168 and the 810x (see
66ec5d4fb1ce6f0bd9df4bc4b758f0916d9f37ab).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index dff0bf0..c236670 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3080,6 +3080,14 @@ static void rtl8169_phy_reset(struct net_device *dev,
 	netif_err(tp, link, dev, "PHY reset failed\n");
 }
 
+static bool rtl_tbi_enabled(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	return (tp->mac_version == RTL_GIGA_MAC_VER_01) &&
+	    (RTL_R8(PHYstatus) & TBI_Enable);
+}
+
 static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -3112,7 +3120,7 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 			   ADVERTISED_1000baseT_Half |
 			   ADVERTISED_1000baseT_Full : 0));
 
-	if (RTL_R8(PHYstatus) & TBI_Enable)
+	if (rtl_tbi_enabled(tp))
 		netif_info(tp, link, dev, "TBI auto-negotiating\n");
 }
 
@@ -3738,8 +3746,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->features |= rtl_try_msi(pdev, ioaddr, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	if ((tp->mac_version <= RTL_GIGA_MAC_VER_06) &&
-	    (RTL_R8(PHYstatus) & TBI_Enable)) {
+	if (rtl_tbi_enabled(tp)) {
 		tp->set_speed = rtl8169_set_speed_tbi;
 		tp->get_settings = rtl8169_gset_tbi;
 		tp->phy_reset_enable = rtl8169_tbi_reset_enable;
-- 
1.7.6
