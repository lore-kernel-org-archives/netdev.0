From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/2] vxlan: support both IPv4 and IPv6 sockets in a single vxlan device
Date: Thu, 24 Sep 2015 13:50:02 +0200
Message-ID: <341e55348c73866833ce2b8b4bc367452ea57203.1443094736.git.jbenc@redhat.com>
References: <cover.1443094736.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45125 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754454AbbIXLuR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 07:50:17 -0400
In-Reply-To: <cover.1443094736.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For metadata based vxlan interface, open both IPv4 and IPv6 socket. This is
much more user friendly: it's not necessary to create two vxlan interfaces
and pay attention to using the right one in routing rules.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c           | 128 +++++++++++++++++++++++++++++-------------
 include/net/vxlan.h           |  14 ++++-
 net/openvswitch/vport-vxlan.c |   3 +-
 3 files changed, 103 insertions(+), 42 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a86613011977..ce704df7681b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -993,19 +993,30 @@ static bool vxlan_snoop(struct net_device *dev,
 static bool vxlan_group_used(struct vxlan_net *vn, struct vxlan_dev *dev)
 {
 	struct vxlan_dev *vxlan;
+	unsigned short family = dev->default_dst.remote_ip.sa.sa_family;
 
 	/* The vxlan_sock is only used by dev, leaving group has
 	 * no effect on other vxlan devices.
 	 */
-	if (atomic_read(&dev->vn_sock->refcnt) == 1)
+	if (family == AF_INET && dev->vn4_sock &&
+	    atomic_read(&dev->vn4_sock->refcnt) == 1)
 		return false;
+#if IS_ENABLED(CONFIG_IPV6)
+	if (family == AF_INET6 && dev->vn6_sock &&
+	    atomic_read(&dev->vn6_sock->refcnt) == 1)
+		return false;
+#endif
 
 	list_for_each_entry(vxlan, &vn->vxlan_list, next) {
 		if (!netif_running(vxlan->dev) || vxlan == dev)
 			continue;
 
-		if (vxlan->vn_sock != dev->vn_sock)
+		if (family == AF_INET && vxlan->vn4_sock != dev->vn4_sock)
 			continue;
+#if IS_ENABLED(CONFIG_IPV6)
+		if (family == AF_INET6 && vxlan->vn6_sock != dev->vn6_sock)
+			continue;
+#endif
 
 		if (!vxlan_addr_equal(&vxlan->default_dst.remote_ip,
 				      &dev->default_dst.remote_ip))
@@ -1021,16 +1032,16 @@ static bool vxlan_group_used(struct vxlan_net *vn, struct vxlan_dev *dev)
 	return false;
 }
 
-static void vxlan_sock_release(struct vxlan_dev *vxlan)
+static void __vxlan_sock_release(struct vxlan_sock *vs)
 {
-	struct vxlan_sock *vs = vxlan->vn_sock;
-	struct sock *sk = vs->sock->sk;
-	struct net *net = sock_net(sk);
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	struct vxlan_net *vn;
 
+	if (!vs)
+		return;
 	if (!atomic_dec_and_test(&vs->refcnt))
 		return;
 
+	vn = net_generic(sock_net(vs->sock->sk), vxlan_net_id);
 	spin_lock(&vn->sock_lock);
 	hlist_del_rcu(&vs->hlist);
 	vxlan_notify_del_rx_port(vs);
@@ -1039,32 +1050,43 @@ static void vxlan_sock_release(struct vxlan_dev *vxlan)
 	queue_work(vxlan_wq, &vs->del_work);
 }
 
+static void vxlan_sock_release(struct vxlan_dev *vxlan)
+{
+	__vxlan_sock_release(vxlan->vn4_sock);
+#if IS_ENABLED(CONFIG_IPV6)
+	__vxlan_sock_release(vxlan->vn6_sock);
+#endif
+}
+
 /* Update multicast group membership when first VNI on
  * multicast address is brought up
  */
 static int vxlan_igmp_join(struct vxlan_dev *vxlan)
 {
-	struct vxlan_sock *vs = vxlan->vn_sock;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk;
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
 	int ret = -EINVAL;
 
-	lock_sock(sk);
 	if (ip->sa.sa_family == AF_INET) {
 		struct ip_mreqn mreq = {
 			.imr_multiaddr.s_addr	= ip->sin.sin_addr.s_addr,
 			.imr_ifindex		= ifindex,
 		};
 
+		sk = vxlan->vn4_sock->sock->sk;
+		lock_sock(sk);
 		ret = ip_mc_join_group(sk, &mreq);
+		release_sock(sk);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
+		sk = vxlan->vn6_sock->sock->sk;
+		lock_sock(sk);
 		ret = ipv6_stub->ipv6_sock_mc_join(sk, ifindex,
 						   &ip->sin6.sin6_addr);
+		release_sock(sk);
 #endif
 	}
-	release_sock(sk);
 
 	return ret;
 }
@@ -1072,27 +1094,30 @@ static int vxlan_igmp_join(struct vxlan_dev *vxlan)
 /* Inverse of vxlan_igmp_join when last VNI is brought down */
 static int vxlan_igmp_leave(struct vxlan_dev *vxlan)
 {
-	struct vxlan_sock *vs = vxlan->vn_sock;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk;
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
 	int ret = -EINVAL;
 
-	lock_sock(sk);
 	if (ip->sa.sa_family == AF_INET) {
 		struct ip_mreqn mreq = {
 			.imr_multiaddr.s_addr	= ip->sin.sin_addr.s_addr,
 			.imr_ifindex		= ifindex,
 		};
 
+		sk = vxlan->vn4_sock->sock->sk;
+		lock_sock(sk);
 		ret = ip_mc_leave_group(sk, &mreq);
+		release_sock(sk);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
+		sk = vxlan->vn6_sock->sock->sk;
+		lock_sock(sk);
 		ret = ipv6_stub->ipv6_sock_mc_drop(sk, ifindex,
 						   &ip->sin6.sin6_addr);
+		release_sock(sk);
 #endif
 	}
-	release_sock(sk);
 
 	return ret;
 }
@@ -1873,8 +1898,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 {
 	struct ip_tunnel_info *info;
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct sock *sk = vxlan->vn_sock->sock->sk;
-	unsigned short family = vxlan_get_sk_family(vxlan->vn_sock);
+	struct sock *sk;
 	struct rtable *rt = NULL;
 	const struct iphdr *old_iph;
 	struct flowi4 fl4;
@@ -1901,13 +1925,10 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				  dev->name);
 			goto drop;
 		}
-		if (family != ip_tunnel_info_af(info))
-			goto drop;
-
 		dst_port = info->key.tp_dst ? : vxlan->cfg.dst_port;
 		vni = be64_to_cpu(info->key.tun_id);
-		remote_ip.sa.sa_family = family;
-		if (family == AF_INET)
+		remote_ip.sa.sa_family = ip_tunnel_info_af(info);
+		if (remote_ip.sa.sa_family == AF_INET)
 			remote_ip.sin.sin_addr.s_addr = info->key.u.ipv4.dst;
 		else
 			remote_ip.sin6.sin6_addr = info->key.u.ipv6.dst;
@@ -1952,6 +1973,10 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	if (dst->sa.sa_family == AF_INET) {
+		if (!vxlan->vn4_sock)
+			goto drop;
+		sk = vxlan->vn4_sock->sock->sk;
+
 		if (info && (info->key.tun_flags & TUNNEL_DONT_FRAGMENT))
 			df = htons(IP_DF);
 
@@ -2013,6 +2038,10 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		struct flowi6 fl6;
 		u32 rt6i_flags;
 
+		if (!vxlan->vn6_sock)
+			goto drop;
+		sk = vxlan->vn6_sock->sock->sk;
+
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_oif = rdst ? rdst->remote_ifindex : 0;
 		fl6.daddr = dst->sin6.sin6_addr;
@@ -2204,7 +2233,6 @@ static void vxlan_vs_add_dev(struct vxlan_sock *vs, struct vxlan_dev *vxlan)
 	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
 	__u32 vni = vxlan->default_dst.remote_vni;
 
-	vxlan->vn_sock = vs;
 	spin_lock(&vn->sock_lock);
 	hlist_add_head_rcu(&vxlan->hlist, vni_head(vs, vni));
 	spin_unlock(&vn->sock_lock);
@@ -2535,14 +2563,13 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
 }
 
 /* Create new listen socket if needed */
-static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
-					      u32 flags)
+static struct vxlan_sock *vxlan_socket_create(struct net *net, bool ipv6,
+					      __be16 port, u32 flags)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 	struct socket *sock;
 	unsigned int h;
-	bool ipv6 = !!(flags & VXLAN_F_IPV6);
 	struct udp_tunnel_sock_cfg tunnel_cfg;
 
 	vs = kzalloc(sizeof(*vs), GFP_KERNEL);
@@ -2587,11 +2614,10 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	return vs;
 }
 
-static int vxlan_sock_add(struct vxlan_dev *vxlan)
+static int __vxlan_sock_add(struct vxlan_dev *vxlan, bool ipv6)
 {
 	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
 	struct vxlan_sock *vs = NULL;
-	bool ipv6 = vxlan->flags & VXLAN_F_IPV6;
 
 	if (!vxlan->cfg.no_share) {
 		spin_lock(&vn->sock_lock);
@@ -2604,20 +2630,46 @@ static int vxlan_sock_add(struct vxlan_dev *vxlan)
 		spin_unlock(&vn->sock_lock);
 	}
 	if (!vs)
-		vs = vxlan_socket_create(vxlan->net, vxlan->cfg.dst_port,
-					 vxlan->flags);
+		vs = vxlan_socket_create(vxlan->net, ipv6,
+					 vxlan->cfg.dst_port, vxlan->flags);
 	if (IS_ERR(vs))
 		return PTR_ERR(vs);
+#if IS_ENABLED(CONFIG_IPV6)
+	if (ipv6)
+		vxlan->vn6_sock = vs;
+	else
+#endif
+		vxlan->vn4_sock = vs;
 	vxlan_vs_add_dev(vs, vxlan);
 	return 0;
 }
 
+static int vxlan_sock_add(struct vxlan_dev *vxlan)
+{
+	bool ipv6 = vxlan->flags & VXLAN_F_IPV6;
+	bool metadata = vxlan->flags & VXLAN_F_COLLECT_METADATA;
+	int ret = 0;
+
+	vxlan->vn4_sock = NULL;
+#if IS_ENABLED(CONFIG_IPV6)
+	vxlan->vn6_sock = NULL;
+	if (ipv6 || metadata)
+		ret = __vxlan_sock_add(vxlan, true);
+#endif
+	if (!ret && (!ipv6 || metadata))
+		ret = __vxlan_sock_add(vxlan, false);
+	if (ret < 0)
+		vxlan_sock_release(vxlan);
+	return ret;
+}
+
 static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 			       struct vxlan_config *conf)
 {
 	struct vxlan_net *vn = net_generic(src_net, vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_rdst *dst = &vxlan->default_dst;
+	unsigned short needed_headroom = ETH_HLEN;
 	int err;
 	bool use_ipv6 = false;
 	__be16 default_port = vxlan->cfg.dst_port;
@@ -2637,6 +2689,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		if (!IS_ENABLED(CONFIG_IPV6))
 			return -EPFNOSUPPORT;
 		use_ipv6 = true;
+		vxlan->flags |= VXLAN_F_IPV6;
 	}
 
 	if (conf->remote_ifindex) {
@@ -2657,22 +2710,21 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 				pr_info("IPv6 is disabled via sysctl\n");
 				return -EPERM;
 			}
-			vxlan->flags |= VXLAN_F_IPV6;
 		}
 #endif
 
 		if (!conf->mtu)
 			dev->mtu = lowerdev->mtu - (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
 
-		dev->needed_headroom = lowerdev->hard_header_len +
-				       (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
-	} else if (use_ipv6) {
-		vxlan->flags |= VXLAN_F_IPV6;
-		dev->needed_headroom = ETH_HLEN + VXLAN6_HEADROOM;
-	} else {
-		dev->needed_headroom = ETH_HLEN + VXLAN_HEADROOM;
+		needed_headroom = lowerdev->hard_header_len;
 	}
 
+	if (use_ipv6 || conf->flags & VXLAN_F_COLLECT_METADATA)
+		needed_headroom += VXLAN6_HEADROOM;
+	else
+		needed_headroom += VXLAN_HEADROOM;
+	dev->needed_headroom = needed_headroom;
+
 	memcpy(&vxlan->cfg, conf, sizeof(*conf));
 	if (!vxlan->cfg.dst_port)
 		vxlan->cfg.dst_port = default_port;
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 480a319b4c92..c1c899c3a51b 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -152,7 +152,10 @@ struct vxlan_config {
 struct vxlan_dev {
 	struct hlist_node hlist;	/* vni hash table */
 	struct list_head  next;		/* vxlan's per namespace list */
-	struct vxlan_sock *vn_sock;	/* listening socket */
+	struct vxlan_sock *vn4_sock;	/* listening socket for IPv4 */
+#if IS_ENABLED(CONFIG_IPV6)
+	struct vxlan_sock *vn6_sock;	/* listening socket for IPv6 */
+#endif
 	struct net_device *dev;
 	struct net	  *net;		/* netns for packet i/o */
 	struct vxlan_rdst default_dst;	/* default destination */
@@ -195,9 +198,14 @@ struct vxlan_dev {
 struct net_device *vxlan_dev_create(struct net *net, const char *name,
 				    u8 name_assign_type, struct vxlan_config *conf);
 
-static inline __be16 vxlan_dev_dst_port(struct vxlan_dev *vxlan)
+static inline __be16 vxlan_dev_dst_port(struct vxlan_dev *vxlan,
+					unsigned short family)
 {
-	return inet_sk(vxlan->vn_sock->sock->sk)->inet_sport;
+#if IS_ENABLED(CONFIG_IPV6)
+	if (family == AF_INET6)
+		return inet_sk(vxlan->vn6_sock->sock->sk)->inet_sport;
+#endif
+	return inet_sk(vxlan->vn4_sock->sock->sk)->inet_sport;
 }
 
 static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index c11413d5075f..fb3cdb85905d 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -151,7 +151,8 @@ static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 {
 	struct vxlan_dev *vxlan = netdev_priv(vport->dev);
 	struct net *net = ovs_dp_get_net(vport->dp);
-	__be16 dst_port = vxlan_dev_dst_port(vxlan);
+	unsigned short family = ip_tunnel_info_af(upcall->egress_tun_info);
+	__be16 dst_port = vxlan_dev_dst_port(vxlan, family);
 	__be16 src_port;
 	int port_min;
 	int port_max;
-- 
1.8.3.1
