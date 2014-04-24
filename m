From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] vxlan: add x-netns support
Date: Thu, 24 Apr 2014 10:02:49 +0200
Message-ID: <1398326569-4934-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:52999 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbaDXIDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 04:03:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to switch the netns when packet is encapsulated or
decapsulated.
The vxlan socket is openned into the i/o netns, ie into the netns where
encapsulated packets are received. The socket lookup is done into this netns to
find the corresponding vxlan tunnel. After decapsulation, the packet is
injecting into the corresponding interface which may stand to another netns.

When one of the two netns is removed, the tunnel is destroyed.

Configuration example:
ip netns add netns1
ip netns exec netns1 ip link set lo up
ip link add vxlan10 type vxlan id 10 group 239.0.0.10 dev eth0 dstport 0
ip link set vxlan10 netns netns1
ip netns exec netns1 ip addr add 192.168.0.249/24 broadcast 192.168.0.255 dev vxlan10
ip netns exec netns1 ip link set vxlan10 up

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/vxlan.c           | 63 ++++++++++++++++++++++++++++++++-----------
 include/net/vxlan.h           |  2 +-
 net/openvswitch/vport-vxlan.c |  3 ++-
 3 files changed, 50 insertions(+), 18 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 82355d5d155a..0ac9015cea36 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -127,6 +127,7 @@ struct vxlan_dev {
 	struct list_head  next;		/* vxlan's per namespace list */
 	struct vxlan_sock *vn_sock;	/* listening socket */
 	struct net_device *dev;
+	struct net	  *net;		/* netns for packet i/o */
 	struct vxlan_rdst default_dst;	/* default destination */
 	union vxlan_addr  saddr;	/* source address */
 	__be16		  dst_port;
@@ -1199,6 +1200,7 @@ static void vxlan_rcv(struct vxlan_sock *vs,
 
 	remote_ip = &vxlan->default_dst.remote_ip;
 	skb_reset_mac_header(skb);
+	skb_scrub_packet(skb, !net_eq(vxlan->net, dev_net(vxlan->dev)));
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
 
 	/* Ignore packet loops (and multicast echo) */
@@ -1614,7 +1616,8 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 			   struct dst_entry *dst, struct sk_buff *skb,
 			   struct net_device *dev, struct in6_addr *saddr,
 			   struct in6_addr *daddr, __u8 prio, __u8 ttl,
-			   __be16 src_port, __be16 dst_port, __be32 vni)
+			   __be16 src_port, __be16 dst_port, __be32 vni,
+			   bool xnet)
 {
 	struct ipv6hdr *ip6h;
 	struct vxlanhdr *vxh;
@@ -1627,7 +1630,7 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 		skb->encapsulation = 1;
 	}
 
-	skb_scrub_packet(skb, false);
+	skb_scrub_packet(skb, xnet);
 
 	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
 			+ VXLAN_HLEN + sizeof(struct ipv6hdr)
@@ -1707,7 +1710,7 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 int vxlan_xmit_skb(struct vxlan_sock *vs,
 		   struct rtable *rt, struct sk_buff *skb,
 		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
-		   __be16 src_port, __be16 dst_port, __be32 vni)
+		   __be16 src_port, __be16 dst_port, __be32 vni, bool xnet)
 {
 	struct vxlanhdr *vxh;
 	struct udphdr *uh;
@@ -1756,7 +1759,7 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 		return err;
 
 	return iptunnel_xmit(vs->sock->sk, rt, skb, src, dst, IPPROTO_UDP,
-			     tos, ttl, df, false);
+			     tos, ttl, df, xnet);
 }
 EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
@@ -1849,7 +1852,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		fl4.daddr = dst->sin.sin_addr.s_addr;
 		fl4.saddr = vxlan->saddr.sin.sin_addr.s_addr;
 
-		rt = ip_route_output_key(dev_net(dev), &fl4);
+		rt = ip_route_output_key(vxlan->net, &fl4);
 		if (IS_ERR(rt)) {
 			netdev_dbg(dev, "no route to %pI4\n",
 				   &dst->sin.sin_addr.s_addr);
@@ -1870,7 +1873,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			struct vxlan_dev *dst_vxlan;
 
 			ip_rt_put(rt);
-			dst_vxlan = vxlan_find_vni(dev_net(dev), vni, dst_port);
+			dst_vxlan = vxlan_find_vni(vxlan->net, vni, dst_port);
 			if (!dst_vxlan)
 				goto tx_error;
 			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
@@ -1883,7 +1886,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		err = vxlan_xmit_skb(vxlan->vn_sock, rt, skb,
 				     fl4.saddr, dst->sin.sin_addr.s_addr,
 				     tos, ttl, df, src_port, dst_port,
-				     htonl(vni << 8));
+				     htonl(vni << 8),
+				     !net_eq(vxlan->net, dev_net(vxlan->dev)));
 
 		if (err < 0)
 			goto rt_tx_error;
@@ -1923,7 +1927,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			struct vxlan_dev *dst_vxlan;
 
 			dst_release(ndst);
-			dst_vxlan = vxlan_find_vni(dev_net(dev), vni, dst_port);
+			dst_vxlan = vxlan_find_vni(vxlan->net, vni, dst_port);
 			if (!dst_vxlan)
 				goto tx_error;
 			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
@@ -1934,7 +1938,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		err = vxlan6_xmit_skb(vxlan->vn_sock, ndst, skb,
 				      dev, &fl6.saddr, &fl6.daddr, 0, ttl,
-				      src_port, dst_port, htonl(vni << 8));
+				      src_port, dst_port, htonl(vni << 8),
+				      !net_eq(vxlan->net, dev_net(vxlan->dev)));
 #endif
 	}
 
@@ -2078,7 +2083,7 @@ static void vxlan_vs_add_dev(struct vxlan_sock *vs, struct vxlan_dev *vxlan)
 static int vxlan_init(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
+	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
 	struct vxlan_sock *vs;
 
 	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
@@ -2086,7 +2091,7 @@ static int vxlan_init(struct net_device *dev)
 		return -ENOMEM;
 
 	spin_lock(&vn->sock_lock);
-	vs = vxlan_find_sock(dev_net(dev), vxlan->dst_port);
+	vs = vxlan_find_sock(vxlan->net, vxlan->dst_port);
 	if (vs) {
 		/* If we have a socket with same port already, reuse it */
 		atomic_inc(&vs->refcnt);
@@ -2168,8 +2173,8 @@ static void vxlan_flush(struct vxlan_dev *vxlan)
 /* Cleanup timer and forwarding table on shutdown */
 static int vxlan_stop(struct net_device *dev)
 {
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 
 	if (vs && vxlan_addr_multicast(&vxlan->default_dst.remote_ip) &&
@@ -2198,7 +2203,7 @@ static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
 	struct net_device *lowerdev;
 	int max_mtu;
 
-	lowerdev = __dev_get_by_index(dev_net(dev), dst->remote_ifindex);
+	lowerdev = __dev_get_by_index(vxlan->net, dst->remote_ifindex);
 	if (lowerdev == NULL)
 		return eth_change_mtu(dev, new_mtu);
 
@@ -2281,7 +2286,6 @@ static void vxlan_setup(struct net_device *dev)
 
 	dev->tx_queue_len = 0;
 	dev->features	|= NETIF_F_LLTX;
-	dev->features	|= NETIF_F_NETNS_LOCAL;
 	dev->features	|= NETIF_F_SG | NETIF_F_HW_CSUM;
 	dev->features   |= NETIF_F_RXCSUM;
 	dev->features   |= NETIF_F_GSO_SOFTWARE;
@@ -2574,7 +2578,7 @@ EXPORT_SYMBOL_GPL(vxlan_sock_add);
 static void vxlan_sock_work(struct work_struct *work)
 {
 	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, sock_work);
-	struct net *net = dev_net(vxlan->dev);
+	struct net *net = vxlan->net;
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	__be16 port = vxlan->dst_port;
 	struct vxlan_sock *nvs;
@@ -2601,6 +2605,8 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	if (!data[IFLA_VXLAN_ID])
 		return -EINVAL;
 
+	vxlan->net = dev_net(dev);
+
 	vni = nla_get_u32(data[IFLA_VXLAN_ID]);
 	dst->remote_vni = vni;
 
@@ -2735,8 +2741,8 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 
 static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 {
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
 
 	spin_lock(&vn->sock_lock);
 	if (!hlist_unhashed(&vxlan->hlist))
@@ -2901,8 +2907,33 @@ static __net_init int vxlan_init_net(struct net *net)
 	return 0;
 }
 
+static void __net_exit vxlan_exit_net(struct net *net)
+{
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	struct vxlan_dev *vxlan, *next;
+	struct net_device *dev, *aux;
+	LIST_HEAD(list);
+
+	rtnl_lock();
+	for_each_netdev_safe(net, dev, aux)
+		if (dev->rtnl_link_ops == &vxlan_link_ops)
+			unregister_netdevice_queue(dev, &list);
+
+	list_for_each_entry_safe(vxlan, next, &vn->vxlan_list, next) {
+		/* If vxlan->dev is in the same netns, it has already been added
+		 * to the list by the previous loop.
+		 */
+		if (!net_eq(dev_net(vxlan->dev), net))
+			unregister_netdevice_queue(dev, &list);
+	}
+
+	unregister_netdevice_many(&list);
+	rtnl_unlock();
+}
+
 static struct pernet_operations vxlan_net_ops = {
 	.init = vxlan_init_net,
+	.exit = vxlan_exit_net,
 	.id   = &vxlan_net_id,
 	.size = sizeof(struct vxlan_net),
 };
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 5deef1ae78c9..7bb4084b1bd0 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -33,7 +33,7 @@ void vxlan_sock_release(struct vxlan_sock *vs);
 int vxlan_xmit_skb(struct vxlan_sock *vs,
 		   struct rtable *rt, struct sk_buff *skb,
 		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
-		   __be16 src_port, __be16 dst_port, __be32 vni);
+		   __be16 src_port, __be16 dst_port, __be32 vni, bool xnet);
 
 __be16 vxlan_src_port(__u16 port_min, __u16 port_max, struct sk_buff *skb);
 
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index e797a50ac2be..21cceb3bdf78 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -180,7 +180,8 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 			     OVS_CB(skb)->tun_key->ipv4_tos,
 			     OVS_CB(skb)->tun_key->ipv4_ttl, df,
 			     src_port, dst_port,
-			     htonl(be64_to_cpu(OVS_CB(skb)->tun_key->tun_id) << 8));
+			     htonl(be64_to_cpu(OVS_CB(skb)->tun_key->tun_id) << 8),
+			     false);
 	if (err < 0)
 		ip_rt_put(rt);
 error:
-- 
1.9.0
