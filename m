From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH rfc 3/5] r8169: link speed selection timer rework.
Date: Wed, 27 Apr 2011 22:37:09 +0200
Message-ID: <20110427203709.GF19708@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39971 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759996Ab1D0Upt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 16:45:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The implementation was a bit krusty.

The 10s rtl8169_phy_timer timer has been (was ?) required with older
8169 for adequate phy operation when full gigabit is advertised in
autonegotiated mode. The timer does nothing if the link is up.
Otherwise it keeps resetting the phy until things improve.

- the device private data field phy_1000_ctrl_reg was used to
  schedule the timer. Avoid it and save a few bytes.

- rtl8169_set_settings
  pending timer is disabled before changing the link settings as
  rtl8169_phy_timer is not always needed (see the removed test in
  rtl8169_phy_timer).

- rtl8169_set_speed
  bail out early on failure.

- rtl8169_open
  Calling rtl8169_request_timer duplicates
  -> rtl8169_init_phy
     -> rtl8169_set_speed
        -> mod_timer
  NB : the latter does not care about RTL_GIGA_MAC_VER_01.

- rtl8169_request_timer : unused yet. Removed.

- rtl8169_delete_timer : useless. Bloat. Removed.

Side effect : the timer may kick in if the TBI is enabled. I do not
know if the TBI has ever been used inr eal life.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
---
 drivers/net/r8169.c |   44 +++++++++-----------------------------------
 1 files changed, 9 insertions(+), 35 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 006f0df..9acfd65 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -617,7 +617,6 @@ struct rtl8169_private {
 	u16 intr_event;
 	u16 napi_event;
 	u16 intr_mask;
-	int phy_1000_ctrl_reg;
 
 	struct mdio_ops {
 		void (*write)(void __iomem *, int, int);
@@ -1289,8 +1288,6 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 			bmcr |= BMCR_FULLDPLX;
 	}
 
-	tp->phy_1000_ctrl_reg = giga_ctrl;
-
 	rtl_writephy(tp, MII_BMCR, bmcr);
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
@@ -1316,10 +1313,14 @@ static int rtl8169_set_speed(struct net_device *dev,
 	int ret;
 
 	ret = tp->set_speed(dev, autoneg, speed, duplex, advertising);
+	if (ret < 0)
+		goto out;
 
-	if (netif_running(dev) && (tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL))
+	if (netif_running(dev) && (autoneg == AUTONEG_ENABLE) &&
+	    (advertising & ADVERTISED_1000baseT_Full)) {
 		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
-
+	}
+out:
 	return ret;
 }
 
@@ -1329,6 +1330,8 @@ static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	unsigned long flags;
 	int ret;
 
+	del_timer_sync(&tp->timer);
+
 	spin_lock_irqsave(&tp->lock, flags);
 	ret = rtl8169_set_speed(dev,
 		cmd->autoneg, cmd->speed, cmd->duplex, cmd->advertising);
@@ -2710,9 +2713,6 @@ static void rtl8169_phy_timer(unsigned long __opaque)
 
 	assert(tp->mac_version > RTL_GIGA_MAC_VER_01);
 
-	if (!(tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL))
-		return;
-
 	spin_lock_irq(&tp->lock);
 
 	if (tp->phy_reset_pending(tp)) {
@@ -2737,28 +2737,6 @@ out_unlock:
 	spin_unlock_irq(&tp->lock);
 }
 
-static inline void rtl8169_delete_timer(struct net_device *dev)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-	struct timer_list *timer = &tp->timer;
-
-	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
-		return;
-
-	del_timer_sync(timer);
-}
-
-static inline void rtl8169_request_timer(struct net_device *dev)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-	struct timer_list *timer = &tp->timer;
-
-	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
-		return;
-
-	mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
-}
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
  * Polling 'interrupt' - used by things like netconsole to send skbs
@@ -3405,8 +3383,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		tp->phy_reset_pending = rtl8169_tbi_reset_pending;
 		tp->link_ok = rtl8169_tbi_link_ok;
 		tp->do_ioctl = rtl_tbi_ioctl;
-
-		tp->phy_1000_ctrl_reg = ADVERTISE_1000FULL; /* Implied by TBI */
 	} else {
 		tp->set_speed = rtl8169_set_speed_xmii;
 		tp->get_settings = rtl8169_gset_xmii;
@@ -3604,8 +3580,6 @@ static int rtl8169_open(struct net_device *dev)
 
 	rtl_hw_start(dev);
 
-	rtl8169_request_timer(dev);
-
 	tp->saved_wolopts = 0;
 	pm_runtime_put_noidle(&pdev->dev);
 
@@ -5168,7 +5142,7 @@ static void rtl8169_down(struct net_device *dev)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	rtl8169_delete_timer(dev);
+	del_timer_sync(&tp->timer);
 
 	netif_stop_queue(dev);
 
-- 
1.7.4.4

