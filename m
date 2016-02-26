From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v3 5/5] veth: implement ndo_set_rx_headroom
Date: Fri, 26 Feb 2016 10:45:41 +0100
Message-ID: <cd429db8d0dc5c981bdce7d282b0f351417a6e60.1456412101.git.pabeni@redhat.com>
References: <cover.1456412101.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33165 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752935AbcBZJqO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 04:46:14 -0500
In-Reply-To: <cover.1456412101.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rx headroom for veth dev is the peer device needed_headroom.
Avoid ping-pong updates setting the private flag IFF_PHONY_HEADROOM.

This avoids skb head reallocation when forwarding from a veth dev
towards a device adding some kind of encapsulation.

When transmitting frames below the MTU size towards a vxlan device,
this gives about 10% performance speed-up when OVS is used to connect
the veth and the vxlan device and a little more when using a
plain Linux bridge.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 drivers/net/veth.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index ba21d07..4f30a6a 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -35,6 +35,7 @@ struct pcpu_vstats {
 struct veth_priv {
 	struct net_device __rcu	*peer;
 	atomic64_t		dropped;
+	unsigned		requested_headroom;
 };
 
 /*
@@ -271,6 +272,29 @@ static int veth_get_iflink(const struct net_device *dev)
 	return iflink;
 }
 
+static void veth_set_rx_headroom(struct net_device *dev, int new_hr)
+{
+	struct veth_priv *peer_priv, *priv = netdev_priv(dev);
+	struct net_device *peer;
+
+	if (new_hr < 0)
+		new_hr = 0;
+
+	rcu_read_lock();
+	peer = rcu_dereference(priv->peer);
+	if (unlikely(!peer))
+		goto out;
+
+	peer_priv = netdev_priv(peer);
+	priv->requested_headroom = new_hr;
+	new_hr = max(priv->requested_headroom, peer_priv->requested_headroom);
+	dev->needed_headroom = new_hr;
+	peer->needed_headroom = new_hr;
+
+out:
+	rcu_read_unlock();
+}
+
 static const struct net_device_ops veth_netdev_ops = {
 	.ndo_init            = veth_dev_init,
 	.ndo_open            = veth_open,
@@ -285,6 +309,7 @@ static const struct net_device_ops veth_netdev_ops = {
 #endif
 	.ndo_get_iflink		= veth_get_iflink,
 	.ndo_features_check	= passthru_features_check,
+	.ndo_set_rx_headroom	= veth_set_rx_headroom,
 };
 
 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
@@ -301,6 +326,7 @@ static void veth_setup(struct net_device *dev)
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 	dev->priv_flags |= IFF_NO_QUEUE;
+	dev->priv_flags |= IFF_PHONY_HEADROOM;
 
 	dev->netdev_ops = &veth_netdev_ops;
 	dev->ethtool_ops = &veth_ethtool_ops;
-- 
1.8.3.1
