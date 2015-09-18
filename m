From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 02/11] net: Rename IFF_VRF_MASTER to IFF_L3MDEV
Date: Fri, 18 Sep 2015 10:06:16 -0700
Message-ID: <1442595985-7049-3-git-send-email-dsa@cumulusnetworks.com>
References: <1442595985-7049-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, gospo@cumulusnetworks.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36223 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890AbbIRRGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 13:06:40 -0400
Received: by padhk3 with SMTP id hk3so55833139pad.3
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 10:06:40 -0700 (PDT)
In-Reply-To: <1442595985-7049-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename IFF_VRF_MASTER to IFF_L3MDEV and update the name of the
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
index 637e9fd1e14c..86616e786413 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -437,7 +437,7 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 
 static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 {
-	if (netif_is_vrf(port_dev) || vrf_is_slave(port_dev))
+	if (netif_is_l3_master(port_dev) || vrf_is_slave(port_dev))
 		return -EINVAL;
 
 	return do_vrf_add_slave(dev, port_dev);
@@ -590,7 +590,7 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 
 	vrf->tb_id = nla_get_u32(data[IFLA_VRF_TABLE]);
 
-	dev->priv_flags |= IFF_VRF_MASTER;
+	dev->priv_flags |= IFF_L3MDEV;
 
 	err = -ENOMEM;
 	vrf_ptr = kmalloc(sizeof(*dev->vrf_ptr), GFP_KERNEL);
@@ -656,7 +656,7 @@ static int vrf_device_event(struct notifier_block *unused,
 		struct net_vrf_dev *vrf_ptr = rtnl_dereference(dev->vrf_ptr);
 		struct net_device *vrf_dev;
 
-		if (!vrf_ptr || netif_is_vrf(dev))
+		if (!vrf_ptr || netif_is_l3_master(dev))
 			goto out;
 
 		vrf_dev = netdev_master_upper_dev_get(dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 320625d181fd..dc944f431702 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1257,7 +1257,7 @@ struct net_device_ops {
  * @IFF_LIVE_ADDR_CHANGE: device supports hardware address
  *	change when it's running
  * @IFF_MACVLAN: Macvlan device
- * @IFF_VRF_MASTER: device is a VRF master
+ * @IFF_L3MDEV: device is associated with L3 master device
  * @IFF_NO_QUEUE: device can run without qdisc attached
  * @IFF_OPENVSWITCH: device is a Open vSwitch master
  */
@@ -1282,7 +1282,7 @@ enum netdev_priv_flags {
 	IFF_XMIT_DST_RELEASE_PERM	= 1<<17,
 	IFF_IPVLAN_MASTER		= 1<<18,
 	IFF_IPVLAN_SLAVE		= 1<<19,
-	IFF_VRF_MASTER			= 1<<20,
+	IFF_L3MDEV			= 1<<20,
 	IFF_NO_QUEUE			= 1<<21,
 	IFF_OPENVSWITCH			= 1<<22,
 };
@@ -1307,7 +1307,7 @@ enum netdev_priv_flags {
 #define IFF_XMIT_DST_RELEASE_PERM	IFF_XMIT_DST_RELEASE_PERM
 #define IFF_IPVLAN_MASTER		IFF_IPVLAN_MASTER
 #define IFF_IPVLAN_SLAVE		IFF_IPVLAN_SLAVE
-#define IFF_VRF_MASTER			IFF_VRF_MASTER
+#define IFF_L3MDEV			IFF_L3MDEV
 #define IFF_NO_QUEUE			IFF_NO_QUEUE
 #define IFF_OPENVSWITCH			IFF_OPENVSWITCH
 
@@ -3826,9 +3826,9 @@ static inline bool netif_supports_nofcs(struct net_device *dev)
 	return dev->priv_flags & IFF_SUPP_NOFCS;
 }
 
-static inline bool netif_is_vrf(const struct net_device *dev)
+static inline bool netif_is_l3_master(const struct net_device *dev)
 {
-	return dev->priv_flags & IFF_VRF_MASTER;
+	return dev->flags & IFF_MASTER && dev->priv_flags & IFF_L3MDEV;
 }
 
 static inline bool netif_is_bridge_master(const struct net_device *dev)
@@ -3841,7 +3841,7 @@ static inline bool netif_is_ovs_master(const struct net_device *dev)
 	return dev->priv_flags & IFF_OPENVSWITCH;
 }
 
-static inline bool netif_index_is_vrf(struct net *net, int ifindex)
+static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 {
 	bool rc = false;
 
@@ -3855,7 +3855,7 @@ static inline bool netif_index_is_vrf(struct net *net, int ifindex)
 
 	dev = dev_get_by_index_rcu(net, ifindex);
 	if (dev)
-		rc = netif_is_vrf(dev);
+		rc = netif_is_l3_master(dev);
 
 	rcu_read_unlock();
 #endif
diff --git a/include/net/route.h b/include/net/route.h
index 10a7d21a211c..49c93d8733d3 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -256,7 +256,7 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 	if (inet_sk(sk)->transparent)
 		flow_flags |= FLOWI_FLAG_ANYSRC;
 
-	if (netif_index_is_vrf(sock_net(sk), oif))
+	if (netif_index_is_l3_master(sock_net(sk), oif))
 		flow_flags |= FLOWI_FLAG_VRFSRC;
 
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
index 09a6b7bb7ea3..4b3c9645311e 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1569,7 +1569,7 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 	}
 
 	oif = arg->bound_dev_if;
-	if (!oif && netif_index_is_vrf(net, skb->skb_iif))
+	if (!oif && netif_index_is_l3_master(net, skb->skb_iif))
 		oif = skb->skb_iif;
 
 	flowi4_init_output(&fl4, oif,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 80f7c5b7b832..163bb955fdc5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2126,7 +2126,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 				fl4->saddr = inet_select_addr(dev_out, 0,
 							      RT_SCOPE_HOST);
 		}
-		if (netif_is_vrf(dev_out) &&
+		if (netif_is_l3_master(dev_out) &&
 		    !(fl4->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
 			rth = vrf_dev_get_rth(dev_out);
 			goto out;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c0a15e7f359f..225d849d611d 100644
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
 					   (flow_flags | FLOWI_FLAG_VRFSRC),
-- 
1.9.1
