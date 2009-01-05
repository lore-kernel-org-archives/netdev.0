From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/8] dsa: convert to net_device_ops
Date: Mon, 05 Jan 2009 12:14:46 -0800
Message-ID: <20090105201514.550766759@vyatta.com>
References: <20090105201442.749889072@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35264 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752407AbZAEUYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 15:24:20 -0500
Content-Disposition: inline; filename=dsa.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to use net_device_ops

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/dsa/slave.c	2009-01-01 23:05:35.001587658 -0800
+++ b/net/dsa/slave.c	2009-01-01 23:11:20.485585998 -0800
@@ -286,6 +286,39 @@ static const struct ethtool_ops dsa_slav
 	.get_sset_count		= dsa_slave_get_sset_count,
 };
 
+static	int dsa_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	switch (ds->tag_protocol) {
+#ifdef CONFIG_NET_DSA_TAG_DSA
+	case htons(ETH_P_DSA):
+		return dsa_xmit(skb, dev);
+#endif
+#ifdef CONFIG_NET_DSA_TAG_EDSA
+	case htons(ETH_P_EDSA):
+		return edsa_xmit(skb, dev);
+#endif
+#ifdef CONFIG_NET_DSA_TAG_TRAILER
+	case htons(ETH_P_TRAILER):
+		return trailer_xmit(skb, dev);
+#endif
+	default:
+		BUG();
+	}
+}
+
+static const struct net_device_ops dsa_netdev_ops = {
+	.ndo_open	 	= dsa_slave_open,
+	.ndo_stop		= dsa_slave_close,
+	.ndo_start_xmit		= dsa_start_xmit,
+	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
+	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
+	.ndo_set_multicast_list = dsa_slave_set_rx_mode,
+	.ndo_set_mac_address	= dsa_slave_set_mac_address,
+	.ndo_do_ioctl		= dsa_slave_ioctl,
+};
 
 /* slave device setup *******************************************************/
 struct net_device *
@@ -306,32 +339,7 @@ dsa_slave_create(struct dsa_switch *ds, 
 	SET_ETHTOOL_OPS(slave_dev, &dsa_slave_ethtool_ops);
 	memcpy(slave_dev->dev_addr, master->dev_addr, ETH_ALEN);
 	slave_dev->tx_queue_len = 0;
-	switch (ds->tag_protocol) {
-#ifdef CONFIG_NET_DSA_TAG_DSA
-	case htons(ETH_P_DSA):
-		slave_dev->hard_start_xmit = dsa_xmit;
-		break;
-#endif
-#ifdef CONFIG_NET_DSA_TAG_EDSA
-	case htons(ETH_P_EDSA):
-		slave_dev->hard_start_xmit = edsa_xmit;
-		break;
-#endif
-#ifdef CONFIG_NET_DSA_TAG_TRAILER
-	case htons(ETH_P_TRAILER):
-		slave_dev->hard_start_xmit = trailer_xmit;
-		break;
-#endif
-	default:
-		BUG();
-	}
-	slave_dev->open = dsa_slave_open;
-	slave_dev->stop = dsa_slave_close;
-	slave_dev->change_rx_flags = dsa_slave_change_rx_flags;
-	slave_dev->set_rx_mode = dsa_slave_set_rx_mode;
-	slave_dev->set_multicast_list = dsa_slave_set_rx_mode;
-	slave_dev->set_mac_address = dsa_slave_set_mac_address;
-	slave_dev->do_ioctl = dsa_slave_ioctl;
+	slave_dev->netdev_ops = &dsa_netdev_ops;
 	SET_NETDEV_DEV(slave_dev, parent);
 	slave_dev->vlan_features = master->vlan_features;
 

-- 

