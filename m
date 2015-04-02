From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 12/12] veth: set iflink to the peer veth
Date: Thu,  2 Apr 2015 17:07:11 +0200
Message-ID: <1427987231-3669-13-git-send-email-nicolas.dichtel@6wind.com>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56632 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbbDBPH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:07:27 -0400
In-Reply-To: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the peer netns is advertised in rtnl messages, we can set this property
so that IFLA_LINK will advertise the peer ifindex. It allows the userland to get
the full veth configuration.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/veth.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 4cca36ebc4fb..c8186ffda1a3 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -263,6 +263,20 @@ static void veth_poll_controller(struct net_device *dev)
 }
 #endif	/* CONFIG_NET_POLL_CONTROLLER */
 
+static int veth_get_iflink(const struct net_device *dev)
+{
+	struct veth_priv *priv = netdev_priv(dev);
+	struct net_device *peer;
+	int iflink;
+
+	rcu_read_lock();
+	peer = rcu_dereference(priv->peer);
+	iflink = peer ? peer->ifindex : 0;
+	rcu_read_unlock();
+
+	return iflink;
+}
+
 static const struct net_device_ops veth_netdev_ops = {
 	.ndo_init            = veth_dev_init,
 	.ndo_open            = veth_open,
@@ -275,6 +289,7 @@ static const struct net_device_ops veth_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= veth_poll_controller,
 #endif
+	.ndo_get_iflink		= veth_get_iflink,
 };
 
 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
-- 
2.2.2
