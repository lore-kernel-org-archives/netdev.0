From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 14/15] net: Remove deprecated tunnel specific UDP
 offload functions
Date: Mon, 13 Jun 2016 10:49:58 -0700
Message-ID: <20160613174958.15186.68608.stgit@localhost.localdomain>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, jbenc@redhat.com,
	alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	Dept-GELinuxNICDev@qlogic.com, davem@davemloft.net,
	eugenia@mellanox.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35071 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423279AbcFMRuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:50:04 -0400
Received: by mail-pf0-f180.google.com with SMTP id c2so48347286pfa.2
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:50:03 -0700 (PDT)
In-Reply-To: <20160613173750.15186.24381.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have all the drivers using udp_tunnel_get_rx_ports,
ndo_add_udp_enc_rx_port, and ndo_del_udp_enc_rx_port we can drop the
function calls that were specific to VXLAN and GENEVE.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/netdevice.h |   12 ------------
 include/net/geneve.h      |    5 -----
 include/net/vxlan.h       |    5 -----
 net/ipv4/udp_tunnel.c     |   41 ++---------------------------------------
 4 files changed, 2 insertions(+), 61 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e959b6348f91..ee3266d8aeaf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1257,18 +1257,6 @@ struct net_device_ops {
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
 	void			(*ndo_add_udp_enc_port)(struct  net_device *dev,
 						       sa_family_t sa_family,
 						       __be16 port,
diff --git a/include/net/geneve.h b/include/net/geneve.h
index 7638ec62c5e1..ec0327d4331b 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -59,11 +59,6 @@ struct genevehdr {
 	struct geneve_opt options[];
 };
 
-static inline void geneve_get_rx_port(struct net_device *netdev)
-{
-	udp_tunnel_get_rx_port(netdev);
-}
-
 #ifdef CONFIG_INET
 struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 					u8 name_assign_type, u16 dst_port);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 2c4f8fcd5a3b..a958cbea8676 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -393,11 +393,6 @@ static inline __be32 vxlan_compute_rco(unsigned int start, unsigned int offset)
 	return vni_field;
 }
 
-static inline void vxlan_get_rx_port(struct net_device *netdev)
-{
-	udp_tunnel_get_rx_port(netdev);
-}
-
 static inline unsigned short vxlan_get_sk_family(struct vxlan_sock *vs)
 {
 	return vs->sock->sk->sk_family;
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index a22677cd41d8..39dfe9e0e498 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -83,28 +83,10 @@ void udp_tunnel_push_rx_port(struct net_device *dev, struct socket *sock,
 	sa_family_t sa_family = sk->sk_family;
 	__be16 port = inet_sk(sk)->inet_sport;
 
-	if (dev->netdev_ops->ndo_add_udp_enc_port) {
+	if (dev->netdev_ops->ndo_add_udp_enc_port)
 		dev->netdev_ops->ndo_add_udp_enc_port(dev, sa_family,
 						      port, type);
-		return;
-	}
 
-	switch (type) {
-	case UDP_ENC_OFFLOAD_TYPE_VXLAN:
-		if (!dev->netdev_ops->ndo_add_vxlan_port)
-			break;
-
-		dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family, port);
-		break;
-	case UDP_ENC_OFFLOAD_TYPE_GENEVE:
-		if (!dev->netdev_ops->ndo_add_geneve_port)
-			break;
-
-		dev->netdev_ops->ndo_add_geneve_port(dev, sa_family, port);
-		break;
-	default:
-		break;
-	}
 }
 EXPORT_SYMBOL_GPL(udp_tunnel_push_rx_port);
 
@@ -128,28 +110,9 @@ static void udp_tunnel_pull_rx_port(struct net_device *dev,
 	sa_family_t sa_family = sk->sk_family;
 	__be16 port = inet_sk(sk)->inet_sport;
 
-	if (dev->netdev_ops->ndo_del_udp_enc_port) {
+	if (dev->netdev_ops->ndo_del_udp_enc_port)
 		dev->netdev_ops->ndo_del_udp_enc_port(dev, sa_family,
 						      port, type);
-		return;
-	}
-
-	switch (type) {
-	case UDP_ENC_OFFLOAD_TYPE_VXLAN:
-		if (!dev->netdev_ops->ndo_del_vxlan_port)
-			break;
-
-		dev->netdev_ops->ndo_del_vxlan_port(dev, sa_family, port);
-		break;
-	case UDP_ENC_OFFLOAD_TYPE_GENEVE:
-		if (!dev->netdev_ops->ndo_del_geneve_port)
-			break;
-
-		dev->netdev_ops->ndo_del_geneve_port(dev, sa_family, port);
-		break;
-	default:
-		break;
-	}
 }
 
 /* Notify netdevs that UDP port is no more listening */
