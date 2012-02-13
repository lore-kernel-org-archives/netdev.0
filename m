From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/8] tg3: Move tg3_change_mtu to a better location
Date: Mon, 13 Feb 2012 12:20:07 -0800
Message-ID: <1329164412-24566-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4237 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757858Ab2BMUUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 15:20:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves tg3_change_mtu to a better location.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  159 +++++++++++++++++------------------
 1 files changed, 78 insertions(+), 81 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3ab1af6..7cf39b2 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6922,69 +6922,6 @@ static int tg3_set_features(struct net_device *dev, netdev_features_t features)
 	return 0;
 }
 
-static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
-			       int new_mtu)
-{
-	dev->mtu = new_mtu;
-
-	if (new_mtu > ETH_DATA_LEN) {
-		if (tg3_flag(tp, 5780_CLASS)) {
-			netdev_update_features(dev);
-			tg3_flag_clear(tp, TSO_CAPABLE);
-		} else {
-			tg3_flag_set(tp, JUMBO_RING_ENABLE);
-		}
-	} else {
-		if (tg3_flag(tp, 5780_CLASS)) {
-			tg3_flag_set(tp, TSO_CAPABLE);
-			netdev_update_features(dev);
-		}
-		tg3_flag_clear(tp, JUMBO_RING_ENABLE);
-	}
-}
-
-static int tg3_restart_hw(struct tg3 *tp, int reset_phy);
-static int tg3_halt(struct tg3 *, int, int);
-
-static int tg3_change_mtu(struct net_device *dev, int new_mtu)
-{
-	struct tg3 *tp = netdev_priv(dev);
-	int err;
-
-	if (new_mtu < TG3_MIN_MTU || new_mtu > TG3_MAX_MTU(tp))
-		return -EINVAL;
-
-	if (!netif_running(dev)) {
-		/* We'll just catch it later when the
-		 * device is up'd.
-		 */
-		tg3_set_mtu(dev, tp, new_mtu);
-		return 0;
-	}
-
-	tg3_phy_stop(tp);
-
-	tg3_netif_stop(tp);
-
-	tg3_full_lock(tp, 1);
-
-	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-
-	tg3_set_mtu(dev, tp, new_mtu);
-
-	err = tg3_restart_hw(tp, 0);
-
-	if (!err)
-		tg3_netif_start(tp);
-
-	tg3_full_unlock(tp);
-
-	if (!err)
-		tg3_phy_start(tp);
-
-	return err;
-}
-
 static void tg3_rx_prodring_free(struct tg3 *tp,
 				 struct tg3_rx_prodring_set *tpr)
 {
@@ -12040,6 +11977,84 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.set_rxfh_indir		= tg3_set_rxfh_indir,
 };
 
+static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
+			       int new_mtu)
+{
+	dev->mtu = new_mtu;
+
+	if (new_mtu > ETH_DATA_LEN) {
+		if (tg3_flag(tp, 5780_CLASS)) {
+			netdev_update_features(dev);
+			tg3_flag_clear(tp, TSO_CAPABLE);
+		} else {
+			tg3_flag_set(tp, JUMBO_RING_ENABLE);
+		}
+	} else {
+		if (tg3_flag(tp, 5780_CLASS)) {
+			tg3_flag_set(tp, TSO_CAPABLE);
+			netdev_update_features(dev);
+		}
+		tg3_flag_clear(tp, JUMBO_RING_ENABLE);
+	}
+}
+
+static int tg3_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	int err;
+
+	if (new_mtu < TG3_MIN_MTU || new_mtu > TG3_MAX_MTU(tp))
+		return -EINVAL;
+
+	if (!netif_running(dev)) {
+		/* We'll just catch it later when the
+		 * device is up'd.
+		 */
+		tg3_set_mtu(dev, tp, new_mtu);
+		return 0;
+	}
+
+	tg3_phy_stop(tp);
+
+	tg3_netif_stop(tp);
+
+	tg3_full_lock(tp, 1);
+
+	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
+
+	tg3_set_mtu(dev, tp, new_mtu);
+
+	err = tg3_restart_hw(tp, 0);
+
+	if (!err)
+		tg3_netif_start(tp);
+
+	tg3_full_unlock(tp);
+
+	if (!err)
+		tg3_phy_start(tp);
+
+	return err;
+}
+
+static const struct net_device_ops tg3_netdev_ops = {
+	.ndo_open		= tg3_open,
+	.ndo_stop		= tg3_close,
+	.ndo_start_xmit		= tg3_start_xmit,
+	.ndo_get_stats64	= tg3_get_stats64,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_rx_mode	= tg3_set_rx_mode,
+	.ndo_set_mac_address	= tg3_set_mac_addr,
+	.ndo_do_ioctl		= tg3_ioctl,
+	.ndo_tx_timeout		= tg3_tx_timeout,
+	.ndo_change_mtu		= tg3_change_mtu,
+	.ndo_fix_features	= tg3_fix_features,
+	.ndo_set_features	= tg3_set_features,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= tg3_poll_controller,
+#endif
+};
+
 static void __devinit tg3_get_eeprom_size(struct tg3 *tp)
 {
 	u32 cursize, val, magic;
@@ -15409,24 +15424,6 @@ static void __devinit tg3_init_coal(struct tg3 *tp)
 	}
 }
 
-static const struct net_device_ops tg3_netdev_ops = {
-	.ndo_open		= tg3_open,
-	.ndo_stop		= tg3_close,
-	.ndo_start_xmit		= tg3_start_xmit,
-	.ndo_get_stats64	= tg3_get_stats64,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_rx_mode	= tg3_set_rx_mode,
-	.ndo_set_mac_address	= tg3_set_mac_addr,
-	.ndo_do_ioctl		= tg3_ioctl,
-	.ndo_tx_timeout		= tg3_tx_timeout,
-	.ndo_change_mtu		= tg3_change_mtu,
-	.ndo_fix_features	= tg3_fix_features,
-	.ndo_set_features	= tg3_set_features,
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= tg3_poll_controller,
-#endif
-};
-
 static int __devinit tg3_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
-- 
1.7.3.4
