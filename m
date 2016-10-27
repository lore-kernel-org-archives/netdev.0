From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net 1/2] vxlan: avoid using stale vxlan socket.
Date: Thu, 27 Oct 2016 11:51:55 -0700
Message-ID: <1477594316-118234-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:56148 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754873AbcJ0SwC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 14:52:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When vxlan device is closed vxlan socket is freed. This
operation can race with vxlan-xmit function which
dereferences vxlan socket. Following patch uses RCU
mechanism to avoid this situation.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/vxlan.c | 80 +++++++++++++++++++++++++++++++++--------------------
 include/net/vxlan.h |  4 +--
 2 files changed, 52 insertions(+), 32 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index c1639a3..0bc1dcc 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -943,17 +943,20 @@ static bool vxlan_snoop(struct net_device *dev,
 static bool vxlan_group_used(struct vxlan_net *vn, struct vxlan_dev *dev)
 {
 	struct vxlan_dev *vxlan;
+	struct vxlan_sock *sock4;
+	struct vxlan_sock *sock6 = NULL;
 	unsigned short family = dev->default_dst.remote_ip.sa.sa_family;
 
+	sock4 = rtnl_dereference(dev->vn4_sock);
+
 	/* The vxlan_sock is only used by dev, leaving group has
 	 * no effect on other vxlan devices.
 	 */
-	if (family == AF_INET && dev->vn4_sock &&
-	    atomic_read(&dev->vn4_sock->refcnt) == 1)
+	if (family == AF_INET && sock4 && atomic_read(&sock4->refcnt) == 1)
 		return false;
 #if IS_ENABLED(CONFIG_IPV6)
-	if (family == AF_INET6 && dev->vn6_sock &&
-	    atomic_read(&dev->vn6_sock->refcnt) == 1)
+	sock6 = rtnl_dereference(dev->vn6_sock);
+	if (family == AF_INET6 && sock6 && atomic_read(&sock6->refcnt) == 1)
 		return false;
 #endif
 
@@ -961,10 +964,12 @@ static bool vxlan_group_used(struct vxlan_net *vn, struct vxlan_dev *dev)
 		if (!netif_running(vxlan->dev) || vxlan == dev)
 			continue;
 
-		if (family == AF_INET && vxlan->vn4_sock != dev->vn4_sock)
+		if (family == AF_INET &&
+		    rtnl_dereference(vxlan->vn4_sock) != sock4)
 			continue;
 #if IS_ENABLED(CONFIG_IPV6)
-		if (family == AF_INET6 && vxlan->vn6_sock != dev->vn6_sock)
+		if (family == AF_INET6 &&
+		    rtnl_dereference(vxlan->vn6_sock) != sock6)
 			continue;
 #endif
 
@@ -1005,22 +1010,25 @@ static bool __vxlan_sock_release_prep(struct vxlan_sock *vs)
 
 static void vxlan_sock_release(struct vxlan_dev *vxlan)
 {
-	bool ipv4 = __vxlan_sock_release_prep(vxlan->vn4_sock);
+	struct vxlan_sock *sock4 = rtnl_dereference(vxlan->vn4_sock);
 #if IS_ENABLED(CONFIG_IPV6)
-	bool ipv6 = __vxlan_sock_release_prep(vxlan->vn6_sock);
+	struct vxlan_sock *sock6 = rtnl_dereference(vxlan->vn6_sock);
+
+	rcu_assign_pointer(vxlan->vn6_sock, NULL);
 #endif
 
+	rcu_assign_pointer(vxlan->vn4_sock, NULL);
 	synchronize_net();
 
-	if (ipv4) {
-		udp_tunnel_sock_release(vxlan->vn4_sock->sock);
-		kfree(vxlan->vn4_sock);
+	if (__vxlan_sock_release_prep(sock4)) {
+		udp_tunnel_sock_release(sock4->sock);
+		kfree(sock4);
 	}
 
 #if IS_ENABLED(CONFIG_IPV6)
-	if (ipv6) {
-		udp_tunnel_sock_release(vxlan->vn6_sock->sock);
-		kfree(vxlan->vn6_sock);
+	if (__vxlan_sock_release_prep(sock6)) {
+		udp_tunnel_sock_release(sock6->sock);
+		kfree(sock6);
 	}
 #endif
 }
@@ -1036,18 +1044,21 @@ static int vxlan_igmp_join(struct vxlan_dev *vxlan)
 	int ret = -EINVAL;
 
 	if (ip->sa.sa_family == AF_INET) {
+		struct vxlan_sock *sock4 = rtnl_dereference(vxlan->vn4_sock);
 		struct ip_mreqn mreq = {
 			.imr_multiaddr.s_addr	= ip->sin.sin_addr.s_addr,
 			.imr_ifindex		= ifindex,
 		};
 
-		sk = vxlan->vn4_sock->sock->sk;
+		sk = sock4->sock->sk;
 		lock_sock(sk);
 		ret = ip_mc_join_group(sk, &mreq);
 		release_sock(sk);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
-		sk = vxlan->vn6_sock->sock->sk;
+		struct vxlan_sock *sock6 = rtnl_dereference(vxlan->vn6_sock);
+
+		sk = sock6->sock->sk;
 		lock_sock(sk);
 		ret = ipv6_stub->ipv6_sock_mc_join(sk, ifindex,
 						   &ip->sin6.sin6_addr);
@@ -1067,18 +1078,21 @@ static int vxlan_igmp_leave(struct vxlan_dev *vxlan)
 	int ret = -EINVAL;
 
 	if (ip->sa.sa_family == AF_INET) {
+		struct vxlan_sock *sock4 = rtnl_dereference(vxlan->vn4_sock);
 		struct ip_mreqn mreq = {
 			.imr_multiaddr.s_addr	= ip->sin.sin_addr.s_addr,
 			.imr_ifindex		= ifindex,
 		};
 
-		sk = vxlan->vn4_sock->sock->sk;
+		sk = sock4->sock->sk;
 		lock_sock(sk);
 		ret = ip_mc_leave_group(sk, &mreq);
 		release_sock(sk);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
-		sk = vxlan->vn6_sock->sock->sk;
+		struct vxlan_sock *sock6 = rtnl_dereference(vxlan->vn6_sock);
+
+		sk = sock6->sock->sk;
 		lock_sock(sk);
 		ret = ipv6_stub->ipv6_sock_mc_drop(sk, ifindex,
 						   &ip->sin6.sin6_addr);
@@ -1828,11 +1842,15 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 					  struct dst_cache *dst_cache,
 					  const struct ip_tunnel_info *info)
 {
+	struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
 	bool use_cache = ip_tunnel_dst_cache_usable(skb, info);
 	struct dst_entry *ndst;
 	struct flowi6 fl6;
 	int err;
 
+	if (!sock6)
+		return ERR_PTR(-EIO);
+
 	if (tos && !info)
 		use_cache = false;
 	if (use_cache) {
@@ -1850,7 +1868,7 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 	fl6.flowi6_proto = IPPROTO_UDP;
 
 	err = ipv6_stub->ipv6_dst_lookup(vxlan->net,
-					 vxlan->vn6_sock->sock->sk,
+					 sock6->sock->sk,
 					 &ndst, &fl6);
 	if (err < 0)
 		return ERR_PTR(err);
@@ -1995,9 +2013,11 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	if (dst->sa.sa_family == AF_INET) {
-		if (!vxlan->vn4_sock)
+		struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
+
+		if (!sock4)
 			goto drop;
-		sk = vxlan->vn4_sock->sock->sk;
+		sk = sock4->sock->sk;
 
 		rt = vxlan_get_route(vxlan, skb,
 				     rdst ? rdst->remote_ifindex : 0, tos,
@@ -2050,12 +2070,13 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				    src_port, dst_port, xnet, !udp_sum);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
+		struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
 		struct dst_entry *ndst;
 		u32 rt6i_flags;
 
-		if (!vxlan->vn6_sock)
+		if (!sock6)
 			goto drop;
-		sk = vxlan->vn6_sock->sock->sk;
+		sk = sock6->sock->sk;
 
 		ndst = vxlan6_get_route(vxlan, skb,
 					rdst ? rdst->remote_ifindex : 0, tos,
@@ -2415,9 +2436,10 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 	dport = info->key.tp_dst ? : vxlan->cfg.dst_port;
 
 	if (ip_tunnel_info_af(info) == AF_INET) {
+		struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
 		struct rtable *rt;
 
-		if (!vxlan->vn4_sock)
+		if (!sock4)
 			return -EINVAL;
 		rt = vxlan_get_route(vxlan, skb, 0, info->key.tos,
 				     info->key.u.ipv4.dst,
@@ -2429,8 +2451,6 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 #if IS_ENABLED(CONFIG_IPV6)
 		struct dst_entry *ndst;
 
-		if (!vxlan->vn6_sock)
-			return -EINVAL;
 		ndst = vxlan6_get_route(vxlan, skb, 0, info->key.tos,
 					info->key.label, &info->key.u.ipv6.dst,
 					&info->key.u.ipv6.src, NULL, info);
@@ -2740,10 +2760,10 @@ static int __vxlan_sock_add(struct vxlan_dev *vxlan, bool ipv6)
 		return PTR_ERR(vs);
 #if IS_ENABLED(CONFIG_IPV6)
 	if (ipv6)
-		vxlan->vn6_sock = vs;
+		rcu_assign_pointer(vxlan->vn6_sock, vs);
 	else
 #endif
-		vxlan->vn4_sock = vs;
+		rcu_assign_pointer(vxlan->vn4_sock, vs);
 	vxlan_vs_add_dev(vs, vxlan);
 	return 0;
 }
@@ -2754,9 +2774,9 @@ static int vxlan_sock_add(struct vxlan_dev *vxlan)
 	bool metadata = vxlan->flags & VXLAN_F_COLLECT_METADATA;
 	int ret = 0;
 
-	vxlan->vn4_sock = NULL;
+	rcu_assign_pointer(vxlan->vn4_sock, NULL);
 #if IS_ENABLED(CONFIG_IPV6)
-	vxlan->vn6_sock = NULL;
+	rcu_assign_pointer(vxlan->vn6_sock, NULL);
 	if (ipv6 || metadata)
 		ret = __vxlan_sock_add(vxlan, true);
 #endif
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 0255613..308adc4 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -225,9 +225,9 @@ struct vxlan_config {
 struct vxlan_dev {
 	struct hlist_node hlist;	/* vni hash table */
 	struct list_head  next;		/* vxlan's per namespace list */
-	struct vxlan_sock *vn4_sock;	/* listening socket for IPv4 */
+	struct vxlan_sock __rcu *vn4_sock;	/* listening socket for IPv4 */
 #if IS_ENABLED(CONFIG_IPV6)
-	struct vxlan_sock *vn6_sock;	/* listening socket for IPv6 */
+	struct vxlan_sock __rcu *vn6_sock;	/* listening socket for IPv6 */
 #endif
 	struct net_device *dev;
 	struct net	  *net;		/* netns for packet i/o */
-- 
1.9.1
