From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 02/15] net: Merge VXLAN and GENEVE push notifiers
 into a single notifier
Date: Mon, 13 Jun 2016 10:48:06 -0700
Message-ID: <20160613174806.15186.64702.stgit@localhost.localdomain>
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
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36063 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161277AbcFMRsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:48:11 -0400
Received: by mail-pf0-f174.google.com with SMTP id t190so48299328pfb.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:48:10 -0700 (PDT)
In-Reply-To: <20160613173750.15186.24381.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch merges the notifiers for VXLAN and GENEVE into a single UDP
encapsulation notifier.  The idea is that we will want to only have to make
one notifier call to receive the list of ports for VXLAN and GENEVE tunnels
that need to be offloaded.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/geneve.c      |    2 +-
 drivers/net/vxlan.c       |    2 +-
 include/linux/netdevice.h |   11 +++++++++--
 include/net/geneve.h      |    6 +-----
 include/net/udp_tunnel.h  |    6 ++++++
 include/net/vxlan.h       |    4 ++--
 net/ipv4/udp_tunnel.c     |   12 ++++++++++++
 7 files changed, 32 insertions(+), 11 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index f5ce41532cf4..f1d06bef1c55 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1508,7 +1508,7 @@ static int geneve_netdevice_event(struct notifier_block *unused,
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 
-	if (event == NETDEV_OFFLOAD_PUSH_GENEVE)
+	if (event == NETDEV_OFFLOAD_PUSH_UDP_ENC_OFFLOAD)
 		geneve_push_rx_ports(dev);
 
 	return NOTIFY_DONE;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 43f634282726..72da056abdf4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -3266,7 +3266,7 @@ static int vxlan_netdevice_event(struct notifier_block *unused,
 
 	if (event == NETDEV_UNREGISTER)
 		vxlan_handle_lowerdev_unregister(vn, dev);
-	else if (event == NETDEV_OFFLOAD_PUSH_VXLAN)
+	else if (event == NETDEV_OFFLOAD_PUSH_UDP_ENC_OFFLOAD)
 		vxlan_push_rx_ports(dev);
 
 	return NOTIFY_DONE;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d101e4d904ba..e959b6348f91 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1269,6 +1269,14 @@ struct net_device_ops {
 	void			(*ndo_del_geneve_port)(struct  net_device *dev,
 						       sa_family_t sa_family,
 						       __be16 port);
+	void			(*ndo_add_udp_enc_port)(struct  net_device *dev,
+						       sa_family_t sa_family,
+						       __be16 port,
+						       unsigned int type);
+	void			(*ndo_del_udp_enc_port)(struct  net_device *dev,
+						       sa_family_t sa_family,
+						       __be16 port,
+						       unsigned int type);
 	void*			(*ndo_dfwd_add_station)(struct net_device *pdev,
 							struct net_device *dev);
 	void			(*ndo_dfwd_del_station)(struct net_device *pdev,
@@ -2251,8 +2259,7 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_BONDING_INFO	0x0019
 #define NETDEV_PRECHANGEUPPER	0x001A
 #define NETDEV_CHANGELOWERSTATE	0x001B
-#define NETDEV_OFFLOAD_PUSH_VXLAN	0x001C
-#define NETDEV_OFFLOAD_PUSH_GENEVE	0x001D
+#define NETDEV_OFFLOAD_PUSH_UDP_ENC_OFFLOAD	0x001C
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/include/net/geneve.h b/include/net/geneve.h
index cb544a530146..7638ec62c5e1 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -1,10 +1,7 @@
 #ifndef __NET_GENEVE_H
 #define __NET_GENEVE_H  1
 
-#ifdef CONFIG_INET
 #include <net/udp_tunnel.h>
-#endif
-
 
 /* Geneve Header:
  *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@@ -64,8 +61,7 @@ struct genevehdr {
 
 static inline void geneve_get_rx_port(struct net_device *netdev)
 {
-	ASSERT_RTNL();
-	call_netdevice_notifiers(NETDEV_OFFLOAD_PUSH_GENEVE, netdev);
+	udp_tunnel_get_rx_port(netdev);
 }
 
 #ifdef CONFIG_INET
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 704f931fd9ad..9ea813740231 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -96,6 +96,12 @@ void udp_tunnel_push_rx_port(struct net_device *dev, struct socket *sock,
 void udp_tunnel_notify_add_rx_port(struct socket *sock, unsigned int type);
 void udp_tunnel_notify_del_rx_port(struct socket *sock, unsigned int type);
 
+static inline void udp_tunnel_get_rx_port(struct net_device *dev)
+{
+	ASSERT_RTNL();
+	call_netdevice_notifiers(NETDEV_OFFLOAD_PUSH_UDP_ENC_OFFLOAD, dev);
+}
+
 /* Transmit the skb using UDP encapsulation. */
 void udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 			 __be32 src, __be32 dst, __u8 tos, __u8 ttl,
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index b8803165df91..2c4f8fcd5a3b 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -8,6 +8,7 @@
 #include <linux/netdevice.h>
 #include <linux/udp.h>
 #include <net/dst_metadata.h>
+#include <net/udp_tunnel.h>
 
 /* VXLAN protocol (RFC 7348) header:
  * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@@ -394,8 +395,7 @@ static inline __be32 vxlan_compute_rco(unsigned int start, unsigned int offset)
 
 static inline void vxlan_get_rx_port(struct net_device *netdev)
 {
-	ASSERT_RTNL();
-	call_netdevice_notifiers(NETDEV_OFFLOAD_PUSH_VXLAN, netdev);
+	udp_tunnel_get_rx_port(netdev);
 }
 
 static inline unsigned short vxlan_get_sk_family(struct vxlan_sock *vs)
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index d575b70644e3..a22677cd41d8 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -83,6 +83,12 @@ void udp_tunnel_push_rx_port(struct net_device *dev, struct socket *sock,
 	sa_family_t sa_family = sk->sk_family;
 	__be16 port = inet_sk(sk)->inet_sport;
 
+	if (dev->netdev_ops->ndo_add_udp_enc_port) {
+		dev->netdev_ops->ndo_add_udp_enc_port(dev, sa_family,
+						      port, type);
+		return;
+	}
+
 	switch (type) {
 	case UDP_ENC_OFFLOAD_TYPE_VXLAN:
 		if (!dev->netdev_ops->ndo_add_vxlan_port)
@@ -122,6 +128,12 @@ static void udp_tunnel_pull_rx_port(struct net_device *dev,
 	sa_family_t sa_family = sk->sk_family;
 	__be16 port = inet_sk(sk)->inet_sport;
 
+	if (dev->netdev_ops->ndo_del_udp_enc_port) {
+		dev->netdev_ops->ndo_del_udp_enc_port(dev, sa_family,
+						      port, type);
+		return;
+	}
+
 	switch (type) {
 	case UDP_ENC_OFFLOAD_TYPE_VXLAN:
 		if (!dev->netdev_ops->ndo_del_vxlan_port)
