From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 1/4] vxlan: move Ethernet initialization to a separate function
Date: Wed, 16 Mar 2016 17:51:09 +0100
Message-ID: <cc50f38e8736b2d1807879c8b0530360f1619f5a.1458146189.git.jbenc@redhat.com>
References: <cover.1458146189.git.jbenc@redhat.com>
Cc: Tom Herbert <tom@herbertland.com>, Jesse Gross <jesse@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39187 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933096AbcCPQvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 12:51:24 -0400
In-Reply-To: <cover.1458146189.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will allow to initialize vxlan in ARPHRD_NONE mode based on the passed
rtnl attributes.

v2: renamed "l2mode" to "ether".

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1eb8347f440c..bfa1e2a5ba9e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2405,7 +2405,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 	return 0;
 }
 
-static const struct net_device_ops vxlan_netdev_ops = {
+static const struct net_device_ops vxlan_netdev_ether_ops = {
 	.ndo_init		= vxlan_init,
 	.ndo_uninit		= vxlan_uninit,
 	.ndo_open		= vxlan_open,
@@ -2459,10 +2459,6 @@ static void vxlan_setup(struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	unsigned int h;
 
-	eth_hw_addr_random(dev);
-	ether_setup(dev);
-
-	dev->netdev_ops = &vxlan_netdev_ops;
 	dev->destructor = free_netdev;
 	SET_NETDEV_DEVTYPE(dev, &vxlan_type);
 
@@ -2477,8 +2473,7 @@ static void vxlan_setup(struct net_device *dev)
 	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
 	dev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
 	netif_keep_dst(dev);
-	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
-	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
+	dev->priv_flags |= IFF_NO_QUEUE;
 
 	INIT_LIST_HEAD(&vxlan->next);
 	spin_lock_init(&vxlan->hash_lock);
@@ -2497,6 +2492,15 @@ static void vxlan_setup(struct net_device *dev)
 		INIT_HLIST_HEAD(&vxlan->fdb_head[h]);
 }
 
+static void vxlan_ether_setup(struct net_device *dev)
+{
+	eth_hw_addr_random(dev);
+	ether_setup(dev);
+	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	dev->netdev_ops = &vxlan_netdev_ether_ops;
+}
+
 static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_ID]		= { .type = NLA_U32 },
 	[IFLA_VXLAN_GROUP]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
@@ -2723,6 +2727,8 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	__be16 default_port = vxlan->cfg.dst_port;
 	struct net_device *lowerdev = NULL;
 
+	vxlan_ether_setup(dev);
+
 	vxlan->net = src_net;
 
 	dst->remote_vni = conf->vni;
-- 
1.8.3.1
