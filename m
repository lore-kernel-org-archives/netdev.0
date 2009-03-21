From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 76/77] hostap: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:43 -0700
Message-ID: <20090321053718.374135383@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>, j@w1.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36733 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753651AbZCUFs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:27 -0400
Content-Disposition: inline; filename=hostap-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/wireless/hostap/hostap_hw.c   |    1 
 drivers/net/wireless/hostap/hostap_main.c |   69 ++++++++++++++++++++++--------
 2 files changed, 52 insertions(+), 18 deletions(-)

--- a/drivers/net/wireless/hostap/hostap_main.c	2009-03-20 22:31:48.333901386 -0700
+++ b/drivers/net/wireless/hostap/hostap_main.c	2009-03-20 22:31:48.342902082 -0700
@@ -815,6 +815,46 @@ const struct header_ops hostap_80211_ops
 };
 EXPORT_SYMBOL(hostap_80211_ops);
 
+
+static const struct net_device_ops hostap_netdev_ops = {
+	.ndo_start_xmit		= hostap_data_start_xmit,
+
+	.ndo_open		= prism2_open,
+	.ndo_stop		= prism2_close,
+	.ndo_do_ioctl		= hostap_ioctl,
+	.ndo_set_mac_address	= prism2_set_mac_address,
+	.ndo_set_multicast_list = hostap_set_multicast_list,
+	.ndo_change_mtu 	= prism2_change_mtu,
+	.ndo_tx_timeout 	= prism2_tx_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
+static const struct net_device_ops hostap_mgmt_netdev_ops = {
+	.ndo_start_xmit		= hostap_mgmt_start_xmit,
+
+	.ndo_open		= prism2_open,
+	.ndo_stop		= prism2_close,
+	.ndo_do_ioctl		= hostap_ioctl,
+	.ndo_set_mac_address	= prism2_set_mac_address,
+	.ndo_set_multicast_list = hostap_set_multicast_list,
+	.ndo_change_mtu 	= prism2_change_mtu,
+	.ndo_tx_timeout 	= prism2_tx_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
+static const struct net_device_ops hostap_master_ops = {
+	.ndo_start_xmit 	= hostap_master_start_xmit,
+
+	.ndo_open		= prism2_open,
+	.ndo_stop		= prism2_close,
+	.ndo_do_ioctl		= hostap_ioctl,
+	.ndo_set_mac_address	= prism2_set_mac_address,
+	.ndo_set_multicast_list = hostap_set_multicast_list,
+	.ndo_change_mtu 	= prism2_change_mtu,
+	.ndo_tx_timeout 	= prism2_tx_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 void hostap_setup_dev(struct net_device *dev, local_info_t *local,
 		      int type)
 {
@@ -830,30 +870,25 @@ void hostap_setup_dev(struct net_device 
 		iface->wireless_data.spy_data = &iface->spy_data;
 		dev->wireless_data = &iface->wireless_data;
 	}
-	dev->wireless_handlers =
-		(struct iw_handler_def *) &hostap_iw_handler_def;
-	dev->do_ioctl = hostap_ioctl;
-	dev->open = prism2_open;
-	dev->stop = prism2_close;
-	dev->set_mac_address = prism2_set_mac_address;
-	dev->set_multicast_list = hostap_set_multicast_list;
-	dev->change_mtu = prism2_change_mtu;
-	dev->tx_timeout = prism2_tx_timeout;
+	dev->wireless_handlers = &hostap_iw_handler_def;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-	if (type == HOSTAP_INTERFACE_AP) {
-		dev->hard_start_xmit = hostap_mgmt_start_xmit;
+	switch(type) {
+	case HOSTAP_INTERFACE_AP:
+		dev->netdev_ops = &hostap_mgmt_netdev_ops;
 		dev->type = ARPHRD_IEEE80211;
 		dev->header_ops = &hostap_80211_ops;
-	} else {
-		dev->hard_start_xmit = hostap_data_start_xmit;
+		break;
+	case HOSTAP_INTERFACE_MASTER:
+		dev->tx_queue_len = 0;	/* use main radio device queue */
+		dev->netdev_ops = &hostap_master_ops;
+		break;
+	default:
+		dev->netdev_ops = &hostap_netdev_ops;
 	}
 
 	dev->mtu = local->mtu;
-	if (type != HOSTAP_INTERFACE_MASTER) {
-		/* use main radio device queue */
-		dev->tx_queue_len = 0;
-	}
+
 
 	SET_ETHTOOL_OPS(dev, &prism2_ethtool_ops);
 
--- a/drivers/net/wireless/hostap/hostap_hw.c	2009-03-20 22:31:48.333901386 -0700
+++ b/drivers/net/wireless/hostap/hostap_hw.c	2009-03-20 22:31:48.343901481 -0700
@@ -3222,7 +3222,6 @@ while (0)
 
 	hostap_setup_dev(dev, local, HOSTAP_INTERFACE_MASTER);
 
-	dev->hard_start_xmit = hostap_master_start_xmit;
 	dev->type = ARPHRD_IEEE80211;
 	dev->header_ops = &hostap_80211_ops;
 

-- 

