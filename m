From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 16/17] net: Remove deprecated tunnel specific
 UDP offload functions
Date: Thu, 16 Jun 2016 12:23:12 -0700
Message-ID: <20160616192312.20872.19285.stgit@localhost.localdomain>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, eugenia@mellanox.com,
	jbenc@redhat.com, alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com,
	davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34546 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754349AbcFPTXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 15:23:15 -0400
Received: by mail-pf0-f172.google.com with SMTP id h14so7533170pfe.1
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 12:23:15 -0700 (PDT)
In-Reply-To: <20160616191851.20872.67154.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have all the drivers using udp_tunnel_get_rx_ports,
ndo_add_udp_enc_rx_port, and ndo_del_udp_enc_rx_port we can drop the
function calls that were specific to VXLAN and GENEVE.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/netdevice.h |   38 ----------------------
 include/net/geneve.h      |    5 ---
 include/net/vxlan.h       |    5 ---
 net/ipv4/udp_tunnel.c     |   79 ++++++++-------------------------------------
 4 files changed, 14 insertions(+), 113 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 577d2a1814b1..e84d9d23c2d5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1026,32 +1026,6 @@ struct tc_to_netdev {
  *	not implement this, it is assumed that the hw is not able to have
  *	multiple net devices on single physical port.
  *
- * void (*ndo_add_vxlan_port)(struct  net_device *dev,
- *			      sa_family_t sa_family, __be16 port);
- *	Called by vxlan to notify a driver about the UDP port and socket
- *	address family that vxlan is listening to. It is called only when
- *	a new port starts listening. The operation is protected by the
- *	vxlan_net->sock_lock.
- *
- * void (*ndo_add_geneve_port)(struct net_device *dev,
- *			       sa_family_t sa_family, __be16 port);
- *	Called by geneve to notify a driver about the UDP port and socket
- *	address family that geneve is listnening to. It is called only when
- *	a new port starts listening. The operation is protected by the
- *	geneve_net->sock_lock.
- *
- * void (*ndo_del_geneve_port)(struct net_device *dev,
- *			       sa_family_t sa_family, __be16 port);
- *	Called by geneve to notify the driver about a UDP port and socket
- *	address family that geneve is not listening to anymore. The operation
- *	is protected by the geneve_net->sock_lock.
- *
- * void (*ndo_del_vxlan_port)(struct  net_device *dev,
- *			      sa_family_t sa_family, __be16 port);
- *	Called by vxlan to notify the driver about a UDP port and socket
- *	address family that vxlan is not listening to anymore. The operation
- *	is protected by the vxlan_net->sock_lock.
- *
  * void (*ndo_udp_tunnel_add)(struct net_device *dev,
  *			      struct udp_tunnel_info *ti);
  *	Called by UDP tunnel to notify a driver about the UDP port and socket
@@ -1272,18 +1246,6 @@ struct net_device_ops {
 							struct netdev_phys_item_id *ppid);
 	int			(*ndo_get_phys_port_name)(struct net_device *dev,
 							  char *name, size_t len);
-	void			(*ndo_add_vxlan_port)(struct  net_device *dev,
-						      sa_family_t sa_family,
-						      __be16 port);
-	void			(*ndo_del_vxlan_port)(struct  net_device *dev,
-						      sa_family_t sa_family,
-						      __be16 port);
-	void			(*ndo_add_geneve_port)(struct  net_device *dev,
-						       sa_family_t sa_family,
-						       __be16 port);
-	void			(*ndo_del_geneve_port)(struct  net_device *dev,
-						       sa_family_t sa_family,
-						       __be16 port);
 	void			(*ndo_udp_tunnel_add)(struct net_device *dev,
 						      struct udp_tunnel_info *ti);
 	void			(*ndo_udp_tunnel_del)(struct net_device *dev,
diff --git a/include/net/geneve.h b/include/net/geneve.h
index 3410c4b5a382..ec0327d4331b 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -59,11 +59,6 @@ struct genevehdr {
 	struct geneve_opt options[];
 };
 
-static inline void geneve_get_rx_port(struct net_device *netdev)
-{
-	udp_tunnel_get_rx_info(netdev);
-}
-
 #ifdef CONFIG_INET
 struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 					u8 name_assign_type, u16 dst_port);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index c62e2ed1c3af..b96d0360c095 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -389,11 +389,6 @@ static inline __be32 vxlan_compute_rco(unsigned int start, unsigned int offset)
 	return vni_field;
 }
 
-static inline void vxlan_get_rx_port(struct net_device *netdev)
-{
-	udp_tunnel_get_rx_info(netdev);
-}
-
 static inline unsigned short vxlan_get_sk_family(struct vxlan_sock *vs)
 {
 	return vs->sock->sk->sk_family;
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 683e494d9000..58bd39fb14b4 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -76,47 +76,20 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 }
 EXPORT_SYMBOL_GPL(setup_udp_tunnel_sock);
 
-static void __udp_tunnel_push_rx_port(struct net_device *dev,
-				      struct udp_tunnel_info *ti)
-{
-	if (dev->netdev_ops->ndo_udp_tunnel_add) {
-		dev->netdev_ops->ndo_udp_tunnel_add(dev, ti);
-		return;
-	}
-
-	switch (ti->type) {
-	case UDP_TUNNEL_TYPE_VXLAN:
-		if (!dev->netdev_ops->ndo_add_vxlan_port)
-			break;
-
-		dev->netdev_ops->ndo_add_vxlan_port(dev,
-						    ti->sa_family,
-						    ti->port);
-		break;
-	case UDP_TUNNEL_TYPE_GENEVE:
-		if (!dev->netdev_ops->ndo_add_geneve_port)
-			break;
-
-		dev->netdev_ops->ndo_add_geneve_port(dev,
-						     ti->sa_family,
-						     ti->port);
-		break;
-	default:
-		break;
-	}
-}
-
 void udp_tunnel_push_rx_port(struct net_device *dev, struct socket *sock,
 			     unsigned short type)
 {
 	struct sock *sk = sock->sk;
 	struct udp_tunnel_info ti;
 
+	if (!dev->netdev_ops->ndo_udp_tunnel_add)
+		return;
+
 	ti.type = type;
 	ti.sa_family = sk->sk_family;
 	ti.port = inet_sk(sk)->inet_sport;
 
-	__udp_tunnel_push_rx_port(dev, &ti);
+	dev->netdev_ops->ndo_udp_tunnel_add(dev, &ti);
 }
 EXPORT_SYMBOL_GPL(udp_tunnel_push_rx_port);
 
@@ -133,42 +106,15 @@ void udp_tunnel_notify_add_rx_port(struct socket *sock, unsigned short type)
 	ti.port = inet_sk(sk)->inet_sport;
 
 	rcu_read_lock();
-	for_each_netdev_rcu(net, dev)
-		__udp_tunnel_push_rx_port(dev, &ti);
+	for_each_netdev_rcu(net, dev) {
+		if (!dev->netdev_ops->ndo_udp_tunnel_add)
+			continue;
+		dev->netdev_ops->ndo_udp_tunnel_add(dev, &ti);
+	}
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(udp_tunnel_notify_add_rx_port);
 
-static void __udp_tunnel_pull_rx_port(struct net_device *dev,
-				      struct udp_tunnel_info *ti)
-{
-	if (dev->netdev_ops->ndo_udp_tunnel_del) {
-		dev->netdev_ops->ndo_udp_tunnel_del(dev, ti);
-		return;
-	}
-
-	switch (ti->type) {
-	case UDP_TUNNEL_TYPE_VXLAN:
-		if (!dev->netdev_ops->ndo_del_vxlan_port)
-			break;
-
-		dev->netdev_ops->ndo_del_vxlan_port(dev,
-						    ti->sa_family,
-						    ti->port);
-		break;
-	case UDP_TUNNEL_TYPE_GENEVE:
-		if (!dev->netdev_ops->ndo_del_geneve_port)
-			break;
-
-		dev->netdev_ops->ndo_del_geneve_port(dev,
-						     ti->sa_family,
-						     ti->port);
-		break;
-	default:
-		break;
-	}
-}
-
 /* Notify netdevs that UDP port is no more listening */
 void udp_tunnel_notify_del_rx_port(struct socket *sock, unsigned short type)
 {
@@ -182,8 +128,11 @@ void udp_tunnel_notify_del_rx_port(struct socket *sock, unsigned short type)
 	ti.port = inet_sk(sk)->inet_sport;
 
 	rcu_read_lock();
-	for_each_netdev_rcu(net, dev)
-		__udp_tunnel_pull_rx_port(dev, &ti);
+	for_each_netdev_rcu(net, dev) {
+		if (!dev->netdev_ops->ndo_udp_tunnel_del)
+			continue;
+		dev->netdev_ops->ndo_udp_tunnel_del(dev, &ti);
+	}
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(udp_tunnel_notify_del_rx_port);
