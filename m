From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next 2/6] net: check tunnel offload feature before calling tunnel ndo ndo
Date: Fri, 30 Jun 2017 15:19:46 +0200
Message-ID: <b6bc58748346f4d0888227a9e682feb5706b5b50.1498743778.git.sd@queasysnail.net>
References: <cover.1498743778.git.sd@queasysnail.net>
Cc: Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49274 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751899AbdF3NUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 09:20:25 -0400
In-Reply-To: <cover.1498743778.git.sd@queasysnail.net>
In-Reply-To: <cover.1498743778.git.sd@queasysnail.net>
References: <cover.1498743778.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If NETIF_F_TUNNEL_OFFLOAD was disabled on a given netdevice, skip the
tunnel offload ndo call during tunnel port creation and deletion.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/ipv4/udp_tunnel.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 58bd39fb14b4..fc8336fddadf 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -82,7 +82,8 @@ void udp_tunnel_push_rx_port(struct net_device *dev, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct udp_tunnel_info ti;
 
-	if (!dev->netdev_ops->ndo_udp_tunnel_add)
+	if (!dev->netdev_ops->ndo_udp_tunnel_add ||
+	    !(dev->features & NETIF_F_TUNNEL_OFFLOAD))
 		return;
 
 	ti.type = type;
@@ -109,6 +110,8 @@ void udp_tunnel_notify_add_rx_port(struct socket *sock, unsigned short type)
 	for_each_netdev_rcu(net, dev) {
 		if (!dev->netdev_ops->ndo_udp_tunnel_add)
 			continue;
+		if (!(dev->features & NETIF_F_TUNNEL_OFFLOAD))
+			continue;
 		dev->netdev_ops->ndo_udp_tunnel_add(dev, &ti);
 	}
 	rcu_read_unlock();
@@ -131,6 +134,8 @@ void udp_tunnel_notify_del_rx_port(struct socket *sock, unsigned short type)
 	for_each_netdev_rcu(net, dev) {
 		if (!dev->netdev_ops->ndo_udp_tunnel_del)
 			continue;
+		if (!(dev->features & NETIF_F_TUNNEL_OFFLOAD))
+			continue;
 		dev->netdev_ops->ndo_udp_tunnel_del(dev, &ti);
 	}
 	rcu_read_unlock();
-- 
2.13.2
