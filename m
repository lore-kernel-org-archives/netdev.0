From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next 3/6] net: add infrastructure to un-offload UDP tunnel port
Date: Fri, 30 Jun 2017 15:19:47 +0200
Message-ID: <0ec7cb16c0901bf3e9f97eaa93500bcc5f8b08cd.1498743778.git.sd@queasysnail.net>
References: <cover.1498743778.git.sd@queasysnail.net>
Cc: Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35330 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751899AbdF3NU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 09:20:27 -0400
In-Reply-To: <cover.1498743778.git.sd@queasysnail.net>
In-Reply-To: <cover.1498743778.git.sd@queasysnail.net>
References: <cover.1498743778.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a new NETDEV_UDP_TUNNEL_DROP_INFO event, similar to
NETDEV_UDP_TUNNEL_PUSH_INFO, to signal to un-offload ports.

This also adds udp_tunnel_drop_rx_port(), which calls
ndo_udp_tunnel_del.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 include/linux/netdevice.h |  1 +
 include/net/udp_tunnel.h  |  8 ++++++++
 net/ipv4/udp_tunnel.c     | 18 ++++++++++++++++++
 3 files changed, 27 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 85f01d673340..75cd0c31357d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2307,6 +2307,7 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_PRECHANGEUPPER	0x001A
 #define NETDEV_CHANGELOWERSTATE	0x001B
 #define NETDEV_UDP_TUNNEL_PUSH_INFO	0x001C
+#define NETDEV_UDP_TUNNEL_DROP_INFO	0x001D
 #define NETDEV_CHANGE_TX_QUEUE_LEN	0x001E
 
 int register_netdevice_notifier(struct notifier_block *nb);
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 02c5be037451..10cce0dd4450 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -115,6 +115,8 @@ struct udp_tunnel_info {
 /* Notify network devices of offloadable types */
 void udp_tunnel_push_rx_port(struct net_device *dev, struct socket *sock,
 			     unsigned short type);
+void udp_tunnel_drop_rx_port(struct net_device *dev, struct socket *sock,
+			     unsigned short type);
 void udp_tunnel_notify_add_rx_port(struct socket *sock, unsigned short type);
 void udp_tunnel_notify_del_rx_port(struct socket *sock, unsigned short type);
 
@@ -124,6 +126,12 @@ static inline void udp_tunnel_get_rx_info(struct net_device *dev)
 	call_netdevice_notifiers(NETDEV_UDP_TUNNEL_PUSH_INFO, dev);
 }
 
+static inline void udp_tunnel_drop_rx_info(struct net_device *dev)
+{
+	ASSERT_RTNL();
+	call_netdevice_notifiers(NETDEV_UDP_TUNNEL_DROP_INFO, dev);
+}
+
 /* Transmit the skb using UDP encapsulation. */
 void udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 			 __be32 src, __be32 dst, __u8 tos, __u8 ttl,
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index fc8336fddadf..c5fd4350251f 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -94,6 +94,24 @@ void udp_tunnel_push_rx_port(struct net_device *dev, struct socket *sock,
 }
 EXPORT_SYMBOL_GPL(udp_tunnel_push_rx_port);
 
+void udp_tunnel_drop_rx_port(struct net_device *dev, struct socket *sock,
+			     unsigned short type)
+{
+	struct sock *sk = sock->sk;
+	struct udp_tunnel_info ti;
+
+	if (!dev->netdev_ops->ndo_udp_tunnel_del ||
+	    !(dev->features & NETIF_F_TUNNEL_OFFLOAD))
+		return;
+
+	ti.type = type;
+	ti.sa_family = sk->sk_family;
+	ti.port = inet_sk(sk)->inet_sport;
+
+	dev->netdev_ops->ndo_udp_tunnel_del(dev, &ti);
+}
+EXPORT_SYMBOL_GPL(udp_tunnel_drop_rx_port);
+
 /* Notify netdevs that UDP port started listening */
 void udp_tunnel_notify_add_rx_port(struct socket *sock, unsigned short type)
 {
-- 
2.13.2
