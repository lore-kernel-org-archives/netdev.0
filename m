From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/8] dsa: convert to net_device_ops
Date: Tue, 6 Jan 2009 14:51:43 -0800
Message-ID: <20090106145143.5f18ee5b@extreme>
References: <20090105201442.749889072@vyatta.com>
	<20090105201514.550766759@vyatta.com>
	<20090106060705.GG4414@server.marvell.com>
	<20090106.104344.130715147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: buytenh@marvell.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49740 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755584AbZAFWvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 17:51:44 -0500
In-Reply-To: <20090106.104344.130715147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: dsa: convert to net_device_ops (v2)

Convert this driver to use net_device_ops

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/dsa/slave.c	2009-01-06 14:16:05.760509806 -0800
+++ b/net/dsa/slave.c	2009-01-06 14:24:07.632360799 -0800
@@ -286,6 +286,42 @@ static const struct ethtool_ops dsa_slav
 	.get_sset_count		= dsa_slave_get_sset_count,
 };
 
+#ifdef CONFIG_NET_DSA_TAG_DSA
+static const struct net_device_ops dsa_netdev_ops = {
+	.ndo_open	 	= dsa_slave_open,
+	.ndo_stop		= dsa_slave_close,
+	.ndo_start_xmit		= dsa_xmit,
+	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
+	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
+	.ndo_set_multicast_list = dsa_slave_set_rx_mode,
+	.ndo_set_mac_address	= dsa_slave_set_mac_address,
+	.ndo_do_ioctl		= dsa_slave_ioctl,
+};
+#endif
+#ifdef CONFIG_NET_DSA_TAG_EDSA
+static const struct net_device_ops edsa_netdev_ops = {
+	.ndo_open	 	= dsa_slave_open,
+	.ndo_stop		= dsa_slave_close,
+	.ndo_start_xmit		= edsa_xmit,
+	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
+	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
+	.ndo_set_multicast_list = dsa_slave_set_rx_mode,
+	.ndo_set_mac_address	= dsa_slave_set_mac_address,
+	.ndo_do_ioctl		= dsa_slave_ioctl,
+};
+#endif
+#ifdef CONFIG_NET_DSA_TAG_TRAILER
+static const struct net_device_ops trailer_netdev_ops = {
+	.ndo_open	 	= dsa_slave_open,
+	.ndo_stop		= dsa_slave_close,
+	.ndo_start_xmit		= trailer_xmit,
+	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
+	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
+	.ndo_set_multicast_list = dsa_slave_set_rx_mode,
+	.ndo_set_mac_address	= dsa_slave_set_mac_address,
+	.ndo_do_ioctl		= dsa_slave_ioctl,
+};
+#endif
 
 /* slave device setup *******************************************************/
 struct net_device *
@@ -306,32 +342,27 @@ dsa_slave_create(struct dsa_switch *ds, 
 	SET_ETHTOOL_OPS(slave_dev, &dsa_slave_ethtool_ops);
 	memcpy(slave_dev->dev_addr, master->dev_addr, ETH_ALEN);
 	slave_dev->tx_queue_len = 0;
+
 	switch (ds->tag_protocol) {
 #ifdef CONFIG_NET_DSA_TAG_DSA
 	case htons(ETH_P_DSA):
-		slave_dev->hard_start_xmit = dsa_xmit;
+		slave_dev->netdev_ops = &dsa_netdev_ops;
 		break;
 #endif
 #ifdef CONFIG_NET_DSA_TAG_EDSA
 	case htons(ETH_P_EDSA):
-		slave_dev->hard_start_xmit = edsa_xmit;
+		slave_dev->netdev_ops = &edsa_netdev_ops;
 		break;
 #endif
 #ifdef CONFIG_NET_DSA_TAG_TRAILER
 	case htons(ETH_P_TRAILER):
-		slave_dev->hard_start_xmit = trailer_xmit;
+		slave_dev->netdev_ops = &trailer_netdev_ops;
 		break;
 #endif
 	default:
 		BUG();
 	}
-	slave_dev->open = dsa_slave_open;
-	slave_dev->stop = dsa_slave_close;
-	slave_dev->change_rx_flags = dsa_slave_change_rx_flags;
-	slave_dev->set_rx_mode = dsa_slave_set_rx_mode;
-	slave_dev->set_multicast_list = dsa_slave_set_rx_mode;
-	slave_dev->set_mac_address = dsa_slave_set_mac_address;
-	slave_dev->do_ioctl = dsa_slave_ioctl;
+
 	SET_NETDEV_DEV(slave_dev, parent);
 	slave_dev->vlan_features = master->vlan_features;
 
