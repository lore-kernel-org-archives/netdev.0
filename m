From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 03/17] net: Merge VXLAN and GENEVE push
 notifiers into a single notifier
Date: Thu, 16 Jun 2016 12:21:00 -0700
Message-ID: <20160616192100.20872.88358.stgit@localhost.localdomain>
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
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33443 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbcFPTVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 15:21:06 -0400
Received: by mail-pa0-f41.google.com with SMTP id b13so20773148pat.0
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 12:21:05 -0700 (PDT)
In-Reply-To: <20160616191851.20872.67154.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch merges the notifiers for VXLAN and GENEVE into a single UDP
tunnel notifier.  The idea is that we will want to only have to make one
notifier call to receive the list of ports for VXLAN and GENEVE tunnels
that need to be offloaded.

In addition we add a new set of ndo functions named ndo_udp_tunnel_add and
ndo_udp_tunnel_del that are meant to allow us to track the tunnel meta-data
such as port and address family as tunnels are added and removed.  The
tunnel meta-data is now transported in a structure named udp_tunnel_info
which for now carries the type, address family, and port number.  In the
future this could be updated so that we can include a tuple of values
including things such as the destination IP address and other fields.

I also ended up going with a naming scheme that consisted of using the
prefix udp_tunnel on function names.  I applied this to the notifier and
ndo ops as well so that it hopefully points to the fact that these are
primarily used in the udp_tunnel functions.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/geneve.c      |    2 +-
 drivers/net/vxlan.c       |    2 +-
 include/linux/netdevice.h |   22 ++++++++++++++++++++--
 include/net/geneve.h      |    3 +--
 include/net/udp_tunnel.h  |    6 ++++++
 include/net/vxlan.h       |    4 ++--
 net/ipv4/udp_tunnel.c     |   10 ++++++++++
 7 files changed, 41 insertions(+), 8 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index af6f676ca444..aa61708bea69 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1497,7 +1497,7 @@ static int geneve_netdevice_event(struct notifier_block *unused,
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 
-	if (event == NETDEV_OFFLOAD_PUSH_GENEVE)
+	if (event == NETDEV_UDP_TUNNEL_PUSH_INFO)
 		geneve_push_rx_ports(dev);
 
 	return NOTIFY_DONE;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index adbd979da22d..31aeec967175 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -3239,7 +3239,7 @@ static int vxlan_netdevice_event(struct notifier_block *unused,
 
 	if (event == NETDEV_UNREGISTER)
 		vxlan_handle_lowerdev_unregister(vn, dev);
-	else if (event == NETDEV_OFFLOAD_PUSH_VXLAN)
+	else if (event == NETDEV_UDP_TUNNEL_PUSH_INFO)
 		vxlan_push_rx_ports(dev);
 
 	return NOTIFY_DONE;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 890158e99159..577d2a1814b1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -61,6 +61,8 @@ struct wireless_dev;
 /* 802.15.4 specific */
 struct wpan_dev;
 struct mpls_dev;
+/* UDP Tunnel offloads */
+struct udp_tunnel_info;
 
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops);
@@ -1050,6 +1052,19 @@ struct tc_to_netdev {
  *	address family that vxlan is not listening to anymore. The operation
  *	is protected by the vxlan_net->sock_lock.
  *
+ * void (*ndo_udp_tunnel_add)(struct net_device *dev,
+ *			      struct udp_tunnel_info *ti);
+ *	Called by UDP tunnel to notify a driver about the UDP port and socket
+ *	address family that a UDP tunnel is listnening to. It is called only
+ *	when a new port starts listening. The operation is protected by the
+ *	RTNL.
+ *
+ * void (*ndo_udp_tunnel_del)(struct net_device *dev,
+ *			      struct udp_tunnel_info *ti);
+ *	Called by UDP tunnel to notify the driver about a UDP port and socket
+ *	address family that the UDP tunnel is not listening to anymore. The
+ *	operation is protected by the RTNL.
+ *
  * void* (*ndo_dfwd_add_station)(struct net_device *pdev,
  *				 struct net_device *dev)
  *	Called by upper layer devices to accelerate switching or other
@@ -1269,6 +1284,10 @@ struct net_device_ops {
 	void			(*ndo_del_geneve_port)(struct  net_device *dev,
 						       sa_family_t sa_family,
 						       __be16 port);
+	void			(*ndo_udp_tunnel_add)(struct net_device *dev,
+						      struct udp_tunnel_info *ti);
+	void			(*ndo_udp_tunnel_del)(struct net_device *dev,
+						      struct udp_tunnel_info *ti);
 	void*			(*ndo_dfwd_add_station)(struct net_device *pdev,
 							struct net_device *dev);
 	void			(*ndo_dfwd_del_station)(struct net_device *pdev,
@@ -2255,8 +2274,7 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_BONDING_INFO	0x0019
 #define NETDEV_PRECHANGEUPPER	0x001A
 #define NETDEV_CHANGELOWERSTATE	0x001B
-#define NETDEV_OFFLOAD_PUSH_VXLAN	0x001C
-#define NETDEV_OFFLOAD_PUSH_GENEVE	0x001D
+#define NETDEV_UDP_TUNNEL_PUSH_INFO	0x001C
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/include/net/geneve.h b/include/net/geneve.h
index f8aff18d6702..3410c4b5a382 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -61,8 +61,7 @@ struct genevehdr {
 
 static inline void geneve_get_rx_port(struct net_device *netdev)
 {
-	ASSERT_RTNL();
-	call_netdevice_notifiers(NETDEV_OFFLOAD_PUSH_GENEVE, netdev);
+	udp_tunnel_get_rx_info(netdev);
 }
 
 #ifdef CONFIG_INET
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 71afbea873a0..1c9408a04213 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -117,6 +117,12 @@ void udp_tunnel_push_rx_port(struct net_device *dev, struct socket *sock,
 void udp_tunnel_notify_add_rx_port(struct socket *sock, unsigned short type);
 void udp_tunnel_notify_del_rx_port(struct socket *sock, unsigned short type);
 
+static inline void udp_tunnel_get_rx_info(struct net_device *dev)
+{
+	ASSERT_RTNL();
+	call_netdevice_notifiers(NETDEV_UDP_TUNNEL_PUSH_INFO, dev);
+}
+
 /* Transmit the skb using UDP encapsulation. */
 void udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 			 __be32 src, __be32 dst, __u8 tos, __u8 ttl,
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 7d944941f32f..c62e2ed1c3af 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -4,6 +4,7 @@
 #include <linux/if_vlan.h>
 #include <net/udp_tunnel.h>
 #include <net/dst_metadata.h>
+#include <net/udp_tunnel.h>
 
 /* VXLAN protocol (RFC 7348) header:
  * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@@ -390,8 +391,7 @@ static inline __be32 vxlan_compute_rco(unsigned int start, unsigned int offset)
 
 static inline void vxlan_get_rx_port(struct net_device *netdev)
 {
-	ASSERT_RTNL();
-	call_netdevice_notifiers(NETDEV_OFFLOAD_PUSH_VXLAN, netdev);
+	udp_tunnel_get_rx_info(netdev);
 }
 
 static inline unsigned short vxlan_get_sk_family(struct vxlan_sock *vs)
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 8174753e6494..683e494d9000 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -79,6 +79,11 @@ EXPORT_SYMBOL_GPL(setup_udp_tunnel_sock);
 static void __udp_tunnel_push_rx_port(struct net_device *dev,
 				      struct udp_tunnel_info *ti)
 {
+	if (dev->netdev_ops->ndo_udp_tunnel_add) {
+		dev->netdev_ops->ndo_udp_tunnel_add(dev, ti);
+		return;
+	}
+
 	switch (ti->type) {
 	case UDP_TUNNEL_TYPE_VXLAN:
 		if (!dev->netdev_ops->ndo_add_vxlan_port)
@@ -137,6 +142,11 @@ EXPORT_SYMBOL_GPL(udp_tunnel_notify_add_rx_port);
 static void __udp_tunnel_pull_rx_port(struct net_device *dev,
 				      struct udp_tunnel_info *ti)
 {
+	if (dev->netdev_ops->ndo_udp_tunnel_del) {
+		dev->netdev_ops->ndo_udp_tunnel_del(dev, ti);
+		return;
+	}
+
 	switch (ti->type) {
 	case UDP_TUNNEL_TYPE_VXLAN:
 		if (!dev->netdev_ops->ndo_del_vxlan_port)
