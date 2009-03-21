From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 70/77] libertas: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:37 -0700
Message-ID: <20090321053717.913753155@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=libertas-ops.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

--- a/drivers/net/wireless/libertas/main.c	2009-03-20 22:26:09.128902494 -0700
+++ b/drivers/net/wireless/libertas/main.c	2009-03-20 22:26:10.923651732 -0700
@@ -1148,6 +1148,17 @@ static void lbs_free_adapter(struct lbs_
 	lbs_deb_leave(LBS_DEB_MAIN);
 }
 
+static const struct net_device_ops lbs_netdev_ops = {
+	.ndo_open 		= lbs_dev_open,
+	.ndo_stop		= lbs_eth_stop,
+	.ndo_start_xmit		= lbs_hard_start_xmit,
+	.ndo_set_mac_address	= lbs_set_mac_address,
+	.ndo_tx_timeout 	= lbs_tx_timeout,
+	.ndo_set_multicast_list = lbs_set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /**
  * @brief This function adds the card. it will probe the
  * card, allocate the lbs_priv and initialize the device.
@@ -1182,19 +1193,13 @@ struct lbs_private *lbs_add_card(void *c
 	priv->infra_open = 0;
 
 	/* Setup the OS Interface to our functions */
-	dev->open = lbs_dev_open;
-	dev->hard_start_xmit = lbs_hard_start_xmit;
-	dev->stop = lbs_eth_stop;
-	dev->set_mac_address = lbs_set_mac_address;
-	dev->tx_timeout = lbs_tx_timeout;
-
+ 	dev->netdev_ops = &lbs_netdev_ops;
 	dev->watchdog_timeo = 5 * HZ;
 	dev->ethtool_ops = &lbs_ethtool_ops;
 #ifdef	WIRELESS_EXT
-	dev->wireless_handlers = (struct iw_handler_def *)&lbs_handler_def;
+	dev->wireless_handlers = &lbs_handler_def;
 #endif
 	dev->flags |= IFF_BROADCAST | IFF_MULTICAST;
-	dev->set_multicast_list = lbs_set_multicast_list;
 
 	SET_NETDEV_DEV(dev, dmdev);
 
@@ -1404,6 +1409,14 @@ out:
 EXPORT_SYMBOL_GPL(lbs_stop_card);
 
 
+static const struct net_device_ops mesh_netdev_ops = {
+	.ndo_open		= lbs_dev_open,
+	.ndo_stop 		= lbs_mesh_stop,
+	.ndo_start_xmit		= lbs_hard_start_xmit,
+	.ndo_set_mac_address	= lbs_set_mac_address,
+	.ndo_set_multicast_list = lbs_set_multicast_list,
+};
+
 /**
  * @brief This function adds mshX interface
  *
@@ -1426,10 +1439,7 @@ static int lbs_add_mesh(struct lbs_priva
 	mesh_dev->ml_priv = priv;
 	priv->mesh_dev = mesh_dev;
 
-	mesh_dev->open = lbs_dev_open;
-	mesh_dev->hard_start_xmit = lbs_hard_start_xmit;
-	mesh_dev->stop = lbs_mesh_stop;
-	mesh_dev->set_mac_address = lbs_set_mac_address;
+	mesh_dev->netdev_ops = &mesh_netdev_ops;
 	mesh_dev->ethtool_ops = &lbs_ethtool_ops;
 	memcpy(mesh_dev->dev_addr, priv->dev->dev_addr,
 			sizeof(priv->dev->dev_addr));
@@ -1440,7 +1450,6 @@ static int lbs_add_mesh(struct lbs_priva
 	mesh_dev->wireless_handlers = (struct iw_handler_def *)&mesh_handler_def;
 #endif
 	mesh_dev->flags |= IFF_BROADCAST | IFF_MULTICAST;
-	mesh_dev->set_multicast_list = lbs_set_multicast_list;
 	/* Register virtual mesh interface */
 	ret = register_netdev(mesh_dev);
 	if (ret) {
@@ -1645,6 +1654,12 @@ out:
 	lbs_deb_leave(LBS_DEB_MAIN);
 }
 
+static const struct net_device_ops rtap_netdev_ops = {
+	.ndo_open = lbs_rtap_open,
+	.ndo_stop = lbs_rtap_stop,
+	.ndo_start_xmit = lbs_rtap_hard_start_xmit,
+};
+
 static int lbs_add_rtap(struct lbs_private *priv)
 {
 	int ret = 0;
@@ -1664,9 +1679,7 @@ static int lbs_add_rtap(struct lbs_priva
 
 	memcpy(rtap_dev->dev_addr, priv->current_addr, ETH_ALEN);
 	rtap_dev->type = ARPHRD_IEEE80211_RADIOTAP;
-	rtap_dev->open = lbs_rtap_open;
-	rtap_dev->stop = lbs_rtap_stop;
-	rtap_dev->hard_start_xmit = lbs_rtap_hard_start_xmit;
+	rtap_dev->netdev_ops = &rtap_netdev_ops;
 	rtap_dev->ml_priv = priv;
 	SET_NETDEV_DEV(rtap_dev, priv->dev->dev.parent);
 

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
