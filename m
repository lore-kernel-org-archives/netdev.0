From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/5] vxlan: move L2 mode initialization to a separate function
Date: Fri, 26 Feb 2016 08:48:38 +0100
Message-ID: <d584cd35c15c97edba9d80dc5fac0e69344f3ac8.1456472746.git.jbenc@redhat.com>
References: <cover.1456472746.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753383AbcBZHs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 02:48:58 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 3F4467EBAE
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 07:48:58 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-33.brq.redhat.com [10.40.204.33])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1Q7mrUv021506
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 02:48:57 -0500
In-Reply-To: <cover.1456472746.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will allow to initialize vxlan in L3 mode based on the passed rtnl
attributes.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index c7844bae339d..49fcca8d8a8e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2437,7 +2437,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 	return 0;
 }
 
-static const struct net_device_ops vxlan_netdev_ops = {
+static const struct net_device_ops vxlan_netdev_l2mode_ops = {
 	.ndo_init		= vxlan_init,
 	.ndo_uninit		= vxlan_uninit,
 	.ndo_open		= vxlan_open,
@@ -2491,10 +2491,6 @@ static void vxlan_setup(struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	unsigned int h;
 
-	eth_hw_addr_random(dev);
-	ether_setup(dev);
-
-	dev->netdev_ops = &vxlan_netdev_ops;
 	dev->destructor = free_netdev;
 	SET_NETDEV_DEVTYPE(dev, &vxlan_type);
 
@@ -2509,8 +2505,7 @@ static void vxlan_setup(struct net_device *dev)
 	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
 	dev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
 	netif_keep_dst(dev);
-	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
-	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
+	dev->priv_flags |= IFF_NO_QUEUE;
 
 	INIT_LIST_HEAD(&vxlan->next);
 	spin_lock_init(&vxlan->hash_lock);
@@ -2529,6 +2524,15 @@ static void vxlan_setup(struct net_device *dev)
 		INIT_HLIST_HEAD(&vxlan->fdb_head[h]);
 }
 
+static void vxlan_l2mode_setup(struct net_device *dev)
+{
+	eth_hw_addr_random(dev);
+	ether_setup(dev);
+	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	dev->netdev_ops = &vxlan_netdev_l2mode_ops;
+}
+
 static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_ID]		= { .type = NLA_U32 },
 	[IFLA_VXLAN_GROUP]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
@@ -2759,6 +2763,8 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	    ((conf->flags & VXLAN_F_GBP) && (conf->flags & VXLAN_F_GPE)))
 		return -EINVAL;
 
+	vxlan_l2mode_setup(dev);
+
 	vxlan->net = src_net;
 
 	dst->remote_vni = conf->vni;
-- 
1.8.3.1
