From: Paolo Bonzini <pbonzini@redhat.com>
Subject: [PATCH] 8139cp: reject invalid MTU values
Date: Fri, 17 Feb 2012 13:33:15 +0100
Message-ID: <1329481995-28384-1-git-send-email-pbonzini@redhat.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 8139cp driver has a change_mtu function that has not been
enabled since the dawn of the git repository.  However, the
generic eth_change_mtu is not used in its place, so that
invalid MTU values can be set on the interface.

This patch salvages the broken code for the single case of
setting the MTU while the interface is down, which is safe
and also includes the range check.
---
 drivers/net/ethernet/realtek/8139cp.c |   21 +--------------------
 1 files changed, 1 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index cc6b391..c140b8c 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1188,12 +1188,9 @@ static void cp_tx_timeout(struct net_device *dev)
 	spin_unlock_irqrestore(&cp->lock, flags);
 }
 
-#ifdef BROKEN
 static int cp_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct cp_private *cp = netdev_priv(dev);
-	int rc;
-	unsigned long flags;
 
 	/* check for invalid MTU, according to hardware limits */
 	if (new_mtu < CP_MIN_MTU || new_mtu > CP_MAX_MTU)
@@ -1206,22 +1203,8 @@ static int cp_change_mtu(struct net_device *dev, int new_mtu)
 		return 0;
 	}
 
-	spin_lock_irqsave(&cp->lock, flags);
-
-	cp_stop_hw(cp);			/* stop h/w and free rings */
-	cp_clean_rings(cp);
-
-	dev->mtu = new_mtu;
-	cp_set_rxbufsize(cp);		/* set new rx buf size */
-
-	rc = cp_init_rings(cp);		/* realloc and restart h/w */
-	cp_start_hw(cp);
-
-	spin_unlock_irqrestore(&cp->lock, flags);
-
-	return rc;
+	return -EBUSY;
 }
-#endif /* BROKEN */
 
 static const char mii_2_8139_map[8] = {
 	BasicModeCtrl,
@@ -1797,9 +1780,7 @@ static const struct net_device_ops cp_netdev_ops = {
 	.ndo_start_xmit		= cp_start_xmit,
 	.ndo_tx_timeout		= cp_tx_timeout,
 	.ndo_set_features	= cp_set_features,
-#ifdef BROKEN
 	.ndo_change_mtu		= cp_change_mtu,
-#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= cp_poll_controller,
-- 
1.7.7.6
