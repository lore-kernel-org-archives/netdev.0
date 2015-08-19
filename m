From: Vincent Bernat <vincent@bernat.im>
Subject: [PATCH] veth: replace iflink by a dedicated symlink in sysfs
Date: Wed, 19 Aug 2015 08:44:08 +0200
Message-ID: <1439966648-26195-2-git-send-email-vincent@bernat.im>
References: <87fv3ier4s.fsf@zoro.exoscale.ch>
 <1439966648-26195-1-git-send-email-vincent@bernat.im>
Cc: Vincent Bernat <vincent@bernat.im>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:34405 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205AbbHSGxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 02:53:07 -0400
In-Reply-To: <1439966648-26195-1-git-send-email-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While the documentation doesn't say exactly what kind of relationship
iflink should represent, until a45253, only lower devices were
advertised this way. While veth cannot have a lower device, using iflink
to advertise the peer may create infinite loops in programs using iflink
to discover device topology.

Instead of advertising the peer link with iflink, a symbolic link "peer"
is added to each peer.

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 drivers/net/veth.c | 40 +++++++++++++++++++++++++---------------
 1 file changed, 25 insertions(+), 15 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index c8186ffda1a3..47f165bc3107 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -105,6 +105,17 @@ static const struct ethtool_ops veth_ethtool_ops = {
 	.get_ethtool_stats	= veth_get_ethtool_stats,
 };
 
+static int veth_peer_sysfs_add(struct net_device *dev,
+			      struct net_device *peer_dev)
+{
+	return sysfs_create_link(&(dev->dev.kobj), &(peer_dev->dev.kobj),
+				 "peer");
+}
+static void veth_peer_sysfs_del(struct net_device *dev)
+{
+	sysfs_remove_link(&(dev->dev.kobj), "peer");
+}
+
 static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct veth_priv *priv = netdev_priv(dev);
@@ -263,20 +274,6 @@ static void veth_poll_controller(struct net_device *dev)
 }
 #endif	/* CONFIG_NET_POLL_CONTROLLER */
 
-static int veth_get_iflink(const struct net_device *dev)
-{
-	struct veth_priv *priv = netdev_priv(dev);
-	struct net_device *peer;
-	int iflink;
-
-	rcu_read_lock();
-	peer = rcu_dereference(priv->peer);
-	iflink = peer ? peer->ifindex : 0;
-	rcu_read_unlock();
-
-	return iflink;
-}
-
 static const struct net_device_ops veth_netdev_ops = {
 	.ndo_init            = veth_dev_init,
 	.ndo_open            = veth_open,
@@ -289,7 +286,6 @@ static const struct net_device_ops veth_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= veth_poll_controller,
 #endif
-	.ndo_get_iflink		= veth_get_iflink,
 };
 
 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
@@ -436,6 +432,13 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 
 	netif_carrier_off(dev);
 
+	err = veth_peer_sysfs_add(dev, peer);
+	if (err < 0)
+		goto err_configure_dev;
+	err = veth_peer_sysfs_add(peer, dev);
+	if (err < 0)
+		goto err_configure_dev;
+
 	/*
 	 * tie the deviced together
 	 */
@@ -447,9 +450,13 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	rcu_assign_pointer(priv->peer, dev);
 	return 0;
 
+err_configure_dev:
+	veth_peer_sysfs_del(dev);
+	veth_peer_sysfs_del(peer);
 err_register_dev:
 	/* nothing to do */
 err_configure_peer:
+	veth_peer_sysfs_del(dev);
 	unregister_netdevice(peer);
 	return err;
 
@@ -466,6 +473,9 @@ static void veth_dellink(struct net_device *dev, struct list_head *head)
 	priv = netdev_priv(dev);
 	peer = rtnl_dereference(priv->peer);
 
+	veth_peer_sysfs_del(dev);
+	if (peer) veth_peer_sysfs_del(dev);
+
 	/* Note : dellink() is called from default_device_exit_batch(),
 	 * before a rcu_synchronize() point. The devices are guaranteed
 	 * not being freed before one RCU grace period.
-- 
2.5.0
