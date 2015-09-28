From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 01/11] net: Rename IFF_VRF_MASTER to IFF_L3MDEV_MASTER
Date: Mon, 28 Sep 2015 10:16:51 -0700
Message-ID: <1443460621-24855-2-git-send-email-dsa@cumulusnetworks.com>
References: <1443460621-24855-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34104 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933540AbbI1RRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 13:17:13 -0400
Received: by padhy16 with SMTP id hy16so179667334pad.1
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 10:17:12 -0700 (PDT)
In-Reply-To: <1443460621-24855-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename IFF_VRF_MASTER to IFF_L3MDEV_MASTER and update the name of the
netif_is_vrf and netif_index_is_vrf macros.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c         |  6 +++---
 include/linux/netdevice.h | 14 +++++++-------
 include/net/route.h       |  2 +-
 include/net/vrf.h         |  4 ++--
 net/ipv4/ip_output.c      |  2 +-
 net/ipv4/route.c          |  2 +-
 net/ipv4/udp.c            |  2 +-
 7 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 4ecb3a3e516a..2d7418e0b908 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -438,7 +438,7 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 
 static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 {
-	if (netif_is_vrf(port_dev) || vrf_is_slave(port_dev))
+	if (netif_is_l3_master(port_dev) || vrf_is_slave(port_dev))
 		return -EINVAL;
 
 	return do_vrf_add_slave(dev, port_dev);
@@ -591,7 +591,7 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 
 	vrf->tb_id = nla_get_u32(data[IFLA_VRF_TABLE]);
 
-	dev->priv_flags |= IFF_VRF_MASTER;
+	dev->priv_flags |= IFF_L3MDEV_MASTER;
 
 	err = -ENOMEM;
 	vrf_ptr = kmalloc(sizeof(*dev->vrf_ptr), GFP_KERNEL);
@@ -657,7 +657,7 @@ static int vrf_device_event(struct notifier_block *unused,
 		struct net_vrf_dev *vrf_ptr = rtnl_dereference(dev->vrf_ptr);
 		struct net_device *vrf_dev;
 
-		if (!vrf_ptr || netif_is_vrf(dev))
+		if (!vrf_ptr || netif_is_l3_master(dev))
 			goto out;
 
 		vrf_dev = netdev_master_upper_dev_get(dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d2ffeafc9998..99c33e83822f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1258,7 +1258,7 @@ struct net_device_ops {
  * @IFF_LIVE_ADDR_CHANGE: device supports hardware address
  *	change when it's running
  * @IFF_MACVLAN: Macvlan device
- * @IFF_VRF_MASTER: device is a VRF master
+ * @IFF_L3MDEV_MASTER: device is an L3 master device
  * @IFF_NO_QUEUE: device can run without qdisc attached
  * @IFF_OPENVSWITCH: device is a Open vSwitch master
  */
@@ -1283,7 +1283,7 @@ enum netdev_priv_flags {
 	IFF_XMIT_DST_RELEASE_PERM	= 1<<17,
 	IFF_IPVLAN_MASTER		= 1<<18,
 	IFF_IPVLAN_SLAVE		= 1<<19,
-	IFF_VRF_MASTER			= 1<<20,
+	IFF_L3MDEV_MASTER		= 1<<20,
 	IFF_NO_QUEUE			= 1<<21,
 	IFF_OPENVSWITCH			= 1<<22,
 };
@@ -1308,7 +1308,7 @@ enum netdev_priv_flags {
 #define IFF_XMIT_DST_RELEASE_PERM	IFF_XMIT_DST_RELEASE_PERM
 #define IFF_IPVLAN_MASTER		IFF_IPVLAN_MASTER
 #define IFF_IPVLAN_SLAVE		IFF_IPVLAN_SLAVE
-#define IFF_VRF_MASTER			IFF_VRF_MASTER
+#define IFF_L3MDEV_MASTER		IFF_L3MDEV_MASTER
 #define IFF_NO_QUEUE			IFF_NO_QUEUE
 #define IFF_OPENVSWITCH			IFF_OPENVSWITCH
 
@@ -3824,9 +3824,9 @@ static inline bool netif_supports_nofcs(struct net_device *dev)
 	return dev->priv_flags & IFF_SUPP_NOFCS;
 }
 
-static inline bool netif_is_vrf(const struct net_device *dev)
+static inline bool netif_is_l3_master(const struct net_device *dev)
 {
-	return dev->priv_flags & IFF_VRF_MASTER;
+	return dev->priv_flags & IFF_L3MDEV_MASTER;
 }
 
 static inline bool netif_is_bridge_master(const struct net_device *dev)
@@ -3839,7 +3839,7 @@ static inline bool netif_is_ovs_master(const struct net_device *dev)
 	return dev->priv_flags & IFF_OPENVSWITCH;
 }
 
-static inline bool netif_index_is_vrf(struct net *net, int ifindex)
+static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 {
 	bool rc = false;
 
@@ -3853,7 +3853,7 @@ static inline bool netif_index_is_vrf(struct net *net, int ifindex)
 
 	dev = dev_get_by_index_rcu(net, ifindex);
 	if (dev)
-		rc = netif_is_vrf(dev);
+		rc = netif_is_l3_master(dev);
 
 	rcu_read_unlock();
 #endif
diff --git a/include/net/route.h b/include/net/route.h
index d1bd90bb3187..a565d0dad12c 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -256,7 +256,7 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 	if (inet_sk(sk)->transparent)
 		flow_flags |= FLOWI_FLAG_ANYSRC;
 
-	if (netif_index_is_vrf(sock_net(sk), oif))
+	if (netif_index_is_l3_master(sock_net(sk), oif))
 		flow_flags |= FLOWI_FLAG_VRFSRC | FLOWI_FLAG_SKIP_NH_OIF;
 
 	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
diff --git a/include/net/vrf.h b/include/net/vrf.h
index 593e6094ddd4..34bb3f69def2 100644
--- a/include/net/vrf.h
+++ b/include/net/vrf.h
@@ -43,7 +43,7 @@ static inline int vrf_master_ifindex_rcu(const struct net_device *dev)
 	if (!dev)
 		return 0;
 
-	if (netif_is_vrf(dev)) {
+	if (netif_is_l3_master(dev)) {
 		ifindex = dev->ifindex;
 	} else {
 		vrf_ptr = rcu_dereference(dev->vrf_ptr);
@@ -125,7 +125,7 @@ static inline u32 vrf_dev_table_rtnl(const struct net_device *dev)
 	return tb_id;
 }
 
-/* caller has already checked netif_is_vrf(dev) */
+/* caller has already checked netif_is_l3_master(dev) */
 static inline struct rtable *vrf_dev_get_rth(const struct net_device *dev)
 {
 	struct rtable *rth = ERR_PTR(-ENETUNREACH);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 06d2c87ed505..aff6766922e8 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1571,7 +1571,7 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 	}
 
 	oif = arg->bound_dev_if;
-	if (!oif && netif_index_is_vrf(net, skb->skb_iif))
+	if (!oif && netif_index_is_l3_master(net, skb->skb_iif))
 		oif = skb->skb_iif;
 
 	flowi4_init_output(&fl4, oif,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6bab84503cd9..c26227098672 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2127,7 +2127,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 				fl4->saddr = inet_select_addr(dev_out, 0,
 							      RT_SCOPE_HOST);
 		}
-		if (netif_is_vrf(dev_out) &&
+		if (netif_is_l3_master(dev_out) &&
 		    !(fl4->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
 			rth = vrf_dev_get_rth(dev_out);
 			goto out;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f7d1d5e19e95..156ba75b6000 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1021,7 +1021,7 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		 * device lookup source address from VRF table. This mimics
 		 * behavior of ip_route_connect{_init}.
 		 */
-		if (netif_index_is_vrf(net, ipc.oif)) {
+		if (netif_index_is_l3_master(net, ipc.oif)) {
 			flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
 					   RT_SCOPE_UNIVERSE, sk->sk_protocol,
 					   (flow_flags | FLOWI_FLAG_VRFSRC |
-- 
1.9.1
