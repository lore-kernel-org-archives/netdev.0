From: Kyle McMartin <kyle@mcmartin.ca>
Subject: [PATCH] staging: at76_usb convert to netdev_ops
Date: Tue, 31 Mar 2009 16:18:50 -0400
Message-ID: <20090331201850.GC25513@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:60289 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459AbZCaUS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 16:18:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle McMartin <kyle@redhat.com>

Didn't see this in your patch queue, fixes build on Fedora, though we'll
probably end up turning on CONFIG_COMPAT_NET_DEV_OPS for now anyway.

Signed-off-by: Kyle McMartin <kyle@redhat.com>

---
diff --git a/drivers/staging/at76_usb/at76_usb.c b/drivers/staging/at76_usb/at76_usb.c
index c8e4d31..59071e6 100644
--- a/drivers/staging/at76_usb/at76_usb.c
+++ b/drivers/staging/at76_usb/at76_usb.c
@@ -5259,6 +5259,18 @@ static int at76_alloc_urbs(struct at76_priv *priv,
 	return 0;
 }
 
+static const struct net_device_ops at76_netdev_ops = {
+	.ndo_open 		= at76_open,
+	.ndo_stop		= at76_stop,
+	.ndo_get_stats		= at76_get_stats,
+	.ndo_start_xmit		= at76_tx,
+	.ndo_tx_timeout		= at76_tx_timeout,
+	.ndo_set_multicast_list	= at76_set_multicast,
+	.ndo_set_mac_address	= at76_set_mac_address,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /* Register network device and initialize the hardware */
 static int at76_init_new_device(struct at76_priv *priv,
 				struct usb_interface *interface)
@@ -5303,22 +5315,18 @@ static int at76_init_new_device(struct at76_priv *priv,
 	priv->scan_mode = SCAN_TYPE_ACTIVE;
 
 	netdev->flags &= ~IFF_MULTICAST;	/* not yet or never */
-	netdev->open = at76_open;
-	netdev->stop = at76_stop;
-	netdev->get_stats = at76_get_stats;
+
+	netdev->netdev_ops = &at76_netdev_ops;
 	netdev->ethtool_ops = &at76_ethtool_ops;
 
+	dev_alloc_name(netdev, "wlan%d");
+
 	/* Add pointers to enable iwspy support. */
 	priv->wireless_data.spy_data = &priv->spy_data;
 	netdev->wireless_data = &priv->wireless_data;
 
-	netdev->hard_start_xmit = at76_tx;
-	netdev->tx_timeout = at76_tx_timeout;
 	netdev->watchdog_timeo = 2 * HZ;
 	netdev->wireless_handlers = &at76_handler_def;
-	netdev->set_multicast_list = at76_set_multicast;
-	netdev->set_mac_address = at76_set_mac_address;
-	dev_alloc_name(netdev, "wlan%d");
 
 	ret = register_netdev(priv->netdev);
 	if (ret) {
