From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: NULL pointer dereference in veth_stats_one
Date: Fri, 04 Jan 2013 17:42:40 -0800
Message-ID: <1357350160.1678.3303.camel@edumazet-glaptop>
References: <20130104105955.GA3663@raven>
	 <1357314320.1678.1414.camel@edumazet-glaptop>
	 <1357316231.1678.1528.camel@edumazet-glaptop>
	 <1357323443.2693.9.camel@bwh-desktop.uk.solarflarecom.com>
	 <1357327406.1678.2139.camel@edumazet-glaptop>
	 <1357331112.2693.33.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Parkin <tparkin@katalix.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:55288 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755320Ab3AEBmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 20:42:45 -0500
Received: by mail-pb0-f52.google.com with SMTP id ro2so9427307pbb.11
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2013 17:42:44 -0800 (PST)
In-Reply-To: <1357331112.2693.33.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Fri, 2013-01-04 at 20:25 +0000, Ben Hutchings wrote:

> Anything calling dev_get_stats() must have a counted or RCU reference to
> the device, and netdev_run_todo() waits for those to go away.  For
> mutually referencing devices we want a kind of weak reference and we
> have no good way to implement those.

OK, so to be on the safe side I added RCU barriers/synchro everywhere.

Thanks !

[PATCH v2 net-next] veth: avoid a NULL deref in veth_stats_one

commit 2681128f0ced8a (veth: extend device features) added a NULL deref
in veth_stats_one(), as veth_get_stats64() was not testing if the peer
device was setup or not.

At init time, we call dev_get_stats() before veth pair is fully setup.

[  178.854758]  [<ffffffffa00f5677>] veth_get_stats64+0x47/0x70 [veth]
[  178.861013]  [<ffffffff814f0a2d>] dev_get_stats+0x6d/0x130
[  178.866486]  [<ffffffff81504efc>] rtnl_fill_ifinfo+0x47c/0x930
[  178.872299]  [<ffffffff81505b93>] rtmsg_ifinfo+0x83/0x100
[  178.877678]  [<ffffffff81505cc6>] rtnl_configure_link+0x76/0xa0
[  178.883580]  [<ffffffffa00f52fa>] veth_newlink+0x16a/0x350 [veth]
[  178.889654]  [<ffffffff815061cc>] rtnl_newlink+0x4dc/0x5e0
[  178.895128]  [<ffffffff81505e1e>] ? rtnl_newlink+0x12e/0x5e0
[  178.900769]  [<ffffffff8150587d>] rtnetlink_rcv_msg+0x11d/0x310
[  178.906669]  [<ffffffff81505760>] ? __rtnl_unlock+0x20/0x20
[  178.912225]  [<ffffffff81521f89>] netlink_rcv_skb+0xa9/0xd0
[  178.917779]  [<ffffffff81502d55>] rtnetlink_rcv+0x25/0x40
[  178.923159]  [<ffffffff815218d1>] netlink_unicast+0x1b1/0x230
[  178.928887]  [<ffffffff81521c4e>] netlink_sendmsg+0x2fe/0x3b0
[  178.934615]  [<ffffffff814dbe22>] sock_sendmsg+0xd2/0xf0

So we must check if peer was setup in veth_get_stats64()

As pointed out by Ben Hutchings, priv->peer is missing proper
synchronization. Adding RCU protection is a safe and well documented
way to make sure we don't access about to be freed or already
freed data.

Reported-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/veth.c |   58 +++++++++++++++++++++++++++++--------------
 1 file changed, 40 insertions(+), 18 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8b2e112..e778bff 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -32,7 +32,7 @@ struct pcpu_vstats {
 };
 
 struct veth_priv {
-	struct net_device	*peer;
+	struct net_device __rcu	*peer;
 	atomic64_t		dropped;
 };
 
@@ -89,10 +89,10 @@ static int veth_get_sset_count(struct net_device *dev, int sset)
 static void veth_get_ethtool_stats(struct net_device *dev,
 		struct ethtool_stats *stats, u64 *data)
 {
-	struct veth_priv *priv;
+	struct veth_priv *priv = netdev_priv(dev);
+	struct net_device *peer = rtnl_dereference(priv->peer);
 
-	priv = netdev_priv(dev);
-	data[0] = priv->peer->ifindex;
+	data[0] = peer ? peer->ifindex : 0;
 }
 
 static const struct ethtool_ops veth_ethtool_ops = {
@@ -107,9 +107,15 @@ static const struct ethtool_ops veth_ethtool_ops = {
 static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct veth_priv *priv = netdev_priv(dev);
-	struct net_device *rcv = priv->peer;
+	struct net_device *rcv;
 	int length = skb->len;
 
+	rcu_read_lock();
+	rcv = rcu_dereference(priv->peer);
+	if (unlikely(!rcv)) {
+		kfree_skb(skb);
+		goto drop;
+	}
 	/* don't change ip_summed == CHECKSUM_PARTIAL, as that
 	 * will cause bad checksum on forwarded packets
 	 */
@@ -125,9 +131,10 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 		stats->packets++;
 		u64_stats_update_end(&stats->syncp);
 	} else {
+drop:
 		atomic64_inc(&priv->dropped);
 	}
-
+	rcu_read_unlock();
 	return NETDEV_TX_OK;
 }
 
@@ -162,30 +169,36 @@ static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
 						  struct rtnl_link_stats64 *tot)
 {
 	struct veth_priv *priv = netdev_priv(dev);
+	struct net_device *peer;
 	struct pcpu_vstats one;
 
 	tot->tx_dropped = veth_stats_one(&one, dev);
 	tot->tx_bytes = one.bytes;
 	tot->tx_packets = one.packets;
 
-	tot->rx_dropped = veth_stats_one(&one, priv->peer);
-	tot->rx_bytes = one.bytes;
-	tot->rx_packets = one.packets;
+	rcu_read_lock();
+	peer = rcu_dereference(priv->peer);
+	if (peer) {
+		tot->rx_dropped = veth_stats_one(&one, peer);
+		tot->rx_bytes = one.bytes;
+		tot->rx_packets = one.packets;
+	}
+	rcu_read_unlock();
 
 	return tot;
 }
 
 static int veth_open(struct net_device *dev)
 {
-	struct veth_priv *priv;
+	struct veth_priv *priv = netdev_priv(dev);
+	struct net_device *peer = rtnl_dereference(priv->peer);
 
-	priv = netdev_priv(dev);
-	if (priv->peer == NULL)
+	if (!peer)
 		return -ENOTCONN;
 
-	if (priv->peer->flags & IFF_UP) {
+	if (peer->flags & IFF_UP) {
 		netif_carrier_on(dev);
-		netif_carrier_on(priv->peer);
+		netif_carrier_on(peer);
 	}
 	return 0;
 }
@@ -195,7 +208,7 @@ static int veth_close(struct net_device *dev)
 	struct veth_priv *priv = netdev_priv(dev);
 
 	netif_carrier_off(dev);
-	netif_carrier_off(priv->peer);
+	netif_carrier_off(rtnl_dereference(priv->peer));
 
 	return 0;
 }
@@ -380,10 +393,10 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	 */
 
 	priv = netdev_priv(dev);
-	priv->peer = peer;
+	rcu_assign_pointer(priv->peer, peer);
 
 	priv = netdev_priv(peer);
-	priv->peer = dev;
+	rcu_assign_pointer(priv->peer, dev);
 	return 0;
 
 err_register_dev:
@@ -404,7 +417,16 @@ static void veth_dellink(struct net_device *dev, struct list_head *head)
 	struct net_device *peer;
 
 	priv = netdev_priv(dev);
-	peer = priv->peer;
+	peer = rtnl_dereference(priv->peer);
+
+	/* Note : dellink() is called from default_device_exit_batch(),
+	 * before a rcu_synchronize() point. The devices are guaranteed
+	 * not being freed before one RCU grace period.
+	 */
+	RCU_INIT_POINTER(priv->peer, NULL);
+
+	priv = netdev_priv(peer);
+	RCU_INIT_POINTER(priv->peer, NULL);
 
 	unregister_netdevice_queue(dev, head);
 	unregister_netdevice_queue(peer, head);
