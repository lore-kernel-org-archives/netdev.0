From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 1/3 RFC] macvlan: Add support for unicast
	filtering in macvlan
Date: Tue, 06 Sep 2011 15:35:45 -0700
Message-ID: <20110906223545.6552.15879.stgit@savbu-pc100.cisco.com>
References: <20110906223536.6552.2062.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dragos.tatulea@gmail.com, arnd@arndb.de, mst@redhat.com,
	dwang2@cisco.com, benve@cisco.com, kaber@trash.net, sri@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-1.cisco.com ([173.36.130.12]:58644 "EHLO
	mtv-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754868Ab1IFWpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 18:45:08 -0400
In-Reply-To: <20110906223536.6552.2062.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds support for ndo_set_rx_mode and sets IFF_UNICAST_FLT to enable
unicast filtering in macvlan. This is to support unicast and multicast
address filtering when this device is used in PASSTHRU mode

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/macvlan.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)


diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 836e13f..528924f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -316,11 +316,19 @@ static int macvlan_open(struct net_device *dev)
 		if (err < 0)
 			goto del_unicast;
 	}
+	if (dev->flags & IFF_PROMISC) {
+		err = dev_set_promiscuity(lowerdev, 1);
+		if (err < 0)
+			goto unset_allmulti;
+	}
 
 hash_add:
 	macvlan_hash_add(vlan);
 	return 0;
 
+unset_allmulti:
+	dev_set_allmulti(lowerdev, -1);
+
 del_unicast:
 	dev_uc_del(lowerdev, dev->dev_addr);
 out:
@@ -337,9 +345,12 @@ static int macvlan_stop(struct net_device *dev)
 		goto hash_del;
 	}
 
+	dev_uc_unsync(lowerdev, dev);
 	dev_mc_unsync(lowerdev, dev);
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(lowerdev, -1);
+	if (dev->flags & IFF_PROMISC)
+		dev_set_promiscuity(lowerdev, -1);
 
 	dev_uc_del(lowerdev, dev->dev_addr);
 
@@ -384,12 +395,16 @@ static void macvlan_change_rx_flags(struct net_device *dev, int change)
 
 	if (change & IFF_ALLMULTI)
 		dev_set_allmulti(lowerdev, dev->flags & IFF_ALLMULTI ? 1 : -1);
+	if (change & IFF_PROMISC)
+		dev_set_promiscuity(lowerdev,
+			dev->flags & IFF_PROMISC ? 1 : -1);
 }
 
-static void macvlan_set_multicast_list(struct net_device *dev)
+static void macvlan_set_rx_mode(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
+	dev_uc_sync(vlan->lowerdev, dev);
 	dev_mc_sync(vlan->lowerdev, dev);
 }
 
@@ -561,7 +576,7 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_change_mtu		= macvlan_change_mtu,
 	.ndo_change_rx_flags	= macvlan_change_rx_flags,
 	.ndo_set_mac_address	= macvlan_set_mac_address,
-	.ndo_set_rx_mode	= macvlan_set_multicast_list,
+	.ndo_set_rx_mode	= macvlan_set_rx_mode,
 	.ndo_get_stats64	= macvlan_dev_get_stats64,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_vlan_rx_add_vid	= macvlan_vlan_rx_add_vid,
@@ -573,6 +588,7 @@ void macvlan_common_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->priv_flags	       &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
+	dev->priv_flags	       |= IFF_UNICAST_FLT;
 	dev->netdev_ops		= &macvlan_netdev_ops;
 	dev->destructor		= free_netdev;
 	dev->header_ops		= &macvlan_hard_header_ops,
