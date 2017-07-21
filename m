From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next v2 2/6] net: check UDP tunnel RX port offload feature before calling tunnel ndo ndo
Date: Fri, 21 Jul 2017 12:49:29 +0200
Message-ID: <e45bddec27e013af696f60bd8a6bb8d2b7e90302.1500632570.git.sd@queasysnail.net>
References: <cover.1500632570.git.sd@queasysnail.net>
Cc: Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33682 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753611AbdGUKty (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Jul 2017 06:49:54 -0400
In-Reply-To: <cover.1500632570.git.sd@queasysnail.net>
In-Reply-To: <cover.1500632570.git.sd@queasysnail.net>
References: <cover.1500632570.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If NETIF_F_RX_UDP_TUNNEL_PORT was disabled on a given netdevice, skip
the tunnel offload ndo call during tunnel port creation and deletion.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/ipv4/udp_tunnel.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 58bd39fb14b4..0d3f14cdc524 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -82,7 +82,8 @@ void udp_tunnel_push_rx_port(struct net_device *dev, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct udp_tunnel_info ti;
 
-	if (!dev->netdev_ops->ndo_udp_tunnel_add)
+	if (!dev->netdev_ops->ndo_udp_tunnel_add ||
+	    !(dev->features & NETIF_F_RX_UDP_TUNNEL_PORT))
 		return;
 
 	ti.type = type;
@@ -109,6 +110,8 @@ void udp_tunnel_notify_add_rx_port(struct socket *sock, unsigned short type)
 	for_each_netdev_rcu(net, dev) {
 		if (!dev->netdev_ops->ndo_udp_tunnel_add)
 			continue;
+		if (!(dev->features & NETIF_F_RX_UDP_TUNNEL_PORT))
+			continue;
 		dev->netdev_ops->ndo_udp_tunnel_add(dev, &ti);
 	}
 	rcu_read_unlock();
@@ -131,6 +134,8 @@ void udp_tunnel_notify_del_rx_port(struct socket *sock, unsigned short type)
 	for_each_netdev_rcu(net, dev) {
 		if (!dev->netdev_ops->ndo_udp_tunnel_del)
 			continue;
+		if (!(dev->features & NETIF_F_RX_UDP_TUNNEL_PORT))
+			continue;
 		dev->netdev_ops->ndo_udp_tunnel_del(dev, &ti);
 	}
 	rcu_read_unlock();
-- 
2.13.2
