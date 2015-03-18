From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 3/3] vxlan: Move socket initialization to within rtnl scope
Date: Wed, 18 Mar 2015 14:50:44 -0300
Message-ID: <42176242983d6204ad39dfad98055e6cf7a1ca61.1426700794.git.marcelo.leitner@gmail.com>
References: <9605dd2faf9e0aae8c3f6ce9f255760dd4856c91.1426700794.git.marcelo.leitner@gmail.com>
Cc: hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755821AbbCRRvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 13:51:25 -0400
In-Reply-To: <9605dd2faf9e0aae8c3f6ce9f255760dd4856c91.1426700794.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if a multicast join operation fail, the vxlan interface will
be UP but not functional, without even a log message informing the user.

Now that we can grab socket lock after already having rntl, we don't
need to defer socket creation and multicast operations. By not deferring
we can do proper error reporting to the user through ip exit code.

This patch thus removes all deferred work that vxlan had and put it back
inline. Now the socket will only be created, bound and join multicast
group when one bring the interface up, and will undo all that as soon as
one put the interface down.

As vxlan_sock_hold() is not used after this patch, it was removed too.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 drivers/net/vxlan.c | 155 ++++++++++++++++++----------------------------------
 1 file changed, 52 insertions(+), 103 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 5ba58dda0e6240fbd108d268725a2185dd0bbadf..0533d32b2223521e5db76e7beef0f232f1272ce0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -127,10 +127,6 @@ struct vxlan_dev {
 	__u8		  ttl;
 	u32		  flags;	/* VXLAN_F_* in vxlan.h */
 
-	struct work_struct sock_work;
-	struct work_struct igmp_join;
-	struct work_struct igmp_leave;
-
 	unsigned long	  age_interval;
 	struct timer_list age_timer;
 	spinlock_t	  hash_lock;
@@ -144,8 +140,6 @@ struct vxlan_dev {
 static u32 vxlan_salt __read_mostly;
 static struct workqueue_struct *vxlan_wq;
 
-static void vxlan_sock_work(struct work_struct *work);
-
 #if IS_ENABLED(CONFIG_IPV6)
 static inline
 bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr *b)
@@ -1072,11 +1066,6 @@ static bool vxlan_group_used(struct vxlan_net *vn, struct vxlan_dev *dev)
 	return false;
 }
 
-static void vxlan_sock_hold(struct vxlan_sock *vs)
-{
-	atomic_inc(&vs->refcnt);
-}
-
 void vxlan_sock_release(struct vxlan_sock *vs)
 {
 	struct sock *sk = vs->sock->sk;
@@ -1095,18 +1084,17 @@ void vxlan_sock_release(struct vxlan_sock *vs)
 }
 EXPORT_SYMBOL_GPL(vxlan_sock_release);
 
-/* Callback to update multicast group membership when first VNI on
+/* Update multicast group membership when first VNI on
  * multicast asddress is brought up
  */
-static void vxlan_igmp_join(struct work_struct *work)
+static int vxlan_igmp_join(struct vxlan_dev *vxlan)
 {
-	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_join);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 	struct sock *sk = vs->sock->sk;
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
+	int ret;
 
-	rtnl_lock();
 	lock_sock(sk);
 	if (ip->sa.sa_family == AF_INET) {
 		struct ip_mreqn mreq = {
@@ -1114,30 +1102,27 @@ static void vxlan_igmp_join(struct work_struct *work)
 			.imr_ifindex		= ifindex,
 		};
 
-		ip_mc_join_group(sk, &mreq);
+		ret = ip_mc_join_group(sk, &mreq);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
-		ipv6_stub->ipv6_sock_mc_join(sk, ifindex,
-					     &ip->sin6.sin6_addr);
+		ret = ipv6_stub->ipv6_sock_mc_join(sk, ifindex,
+						   &ip->sin6.sin6_addr);
 #endif
 	}
 	release_sock(sk);
-	rtnl_unlock();
 
-	vxlan_sock_release(vs);
-	dev_put(vxlan->dev);
+	return ret;
 }
 
 /* Inverse of vxlan_igmp_join when last VNI is brought down */
-static void vxlan_igmp_leave(struct work_struct *work)
+static int vxlan_igmp_leave(struct vxlan_dev *vxlan)
 {
-	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_leave);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 	struct sock *sk = vs->sock->sk;
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
+	int ret;
 
-	rtnl_lock();
 	lock_sock(sk);
 	if (ip->sa.sa_family == AF_INET) {
 		struct ip_mreqn mreq = {
@@ -1145,19 +1130,16 @@ static void vxlan_igmp_leave(struct work_struct *work)
 			.imr_ifindex		= ifindex,
 		};
 
-		ip_mc_leave_group(sk, &mreq);
+		ret = ip_mc_leave_group(sk, &mreq);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
-		ipv6_stub->ipv6_sock_mc_drop(sk, ifindex,
-					     &ip->sin6.sin6_addr);
+		ret = ipv6_stub->ipv6_sock_mc_drop(sk, ifindex,
+						   &ip->sin6.sin6_addr);
 #endif
 	}
-
 	release_sock(sk);
-	rtnl_unlock();
 
-	vxlan_sock_release(vs);
-	dev_put(vxlan->dev);
+	return ret;
 }
 
 static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
@@ -2178,37 +2160,22 @@ static void vxlan_cleanup(unsigned long arg)
 
 static void vxlan_vs_add_dev(struct vxlan_sock *vs, struct vxlan_dev *vxlan)
 {
+	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
 	__u32 vni = vxlan->default_dst.remote_vni;
 
 	vxlan->vn_sock = vs;
+	spin_lock(&vn->sock_lock);
 	hlist_add_head_rcu(&vxlan->hlist, vni_head(vs, vni));
+	spin_unlock(&vn->sock_lock);
 }
 
 /* Setup stats when device is created */
 static int vxlan_init(struct net_device *dev)
 {
-	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
-	struct vxlan_sock *vs;
-	bool ipv6 = vxlan->flags & VXLAN_F_IPV6;
-
 	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	spin_lock(&vn->sock_lock);
-	vs = vxlan_find_sock(vxlan->net, ipv6 ? AF_INET6 : AF_INET,
-			     vxlan->dst_port, vxlan->flags);
-	if (vs && atomic_add_unless(&vs->refcnt, 1, 0)) {
-		/* If we have a socket with same port already, reuse it */
-		vxlan_vs_add_dev(vs, vxlan);
-	} else {
-		/* otherwise make new socket outside of RTNL */
-		dev_hold(dev);
-		queue_work(vxlan_wq, &vxlan->sock_work);
-	}
-	spin_unlock(&vn->sock_lock);
-
 	return 0;
 }
 
@@ -2226,12 +2193,9 @@ static void vxlan_fdb_delete_default(struct vxlan_dev *vxlan)
 static void vxlan_uninit(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_sock *vs = vxlan->vn_sock;
 
 	vxlan_fdb_delete_default(vxlan);
 
-	if (vs)
-		vxlan_sock_release(vs);
 	free_percpu(dev->tstats);
 }
 
@@ -2239,22 +2203,28 @@ static void vxlan_uninit(struct net_device *dev)
 static int vxlan_open(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_sock *vs = vxlan->vn_sock;
+	struct vxlan_sock *vs;
+	int ret = 0;
 
-	/* socket hasn't been created */
-	if (!vs)
-		return -ENOTCONN;
+	vs = vxlan_sock_add(vxlan->net, vxlan->dst_port, vxlan_rcv, NULL,
+			    false, vxlan->flags);
+	if (IS_ERR(vs))
+		return PTR_ERR(vs);
+
+	vxlan_vs_add_dev(vs, vxlan);
 
 	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip)) {
-		vxlan_sock_hold(vs);
-		dev_hold(dev);
-		queue_work(vxlan_wq, &vxlan->igmp_join);
+		ret = vxlan_igmp_join(vxlan);
+		if (ret) {
+			vxlan_sock_release(vs);
+			return ret;
+		}
 	}
 
 	if (vxlan->age_interval)
 		mod_timer(&vxlan->age_timer, jiffies + FDB_AGE_INTERVAL);
 
-	return 0;
+	return ret;
 }
 
 /* Purge the forwarding table */
@@ -2282,19 +2252,21 @@ static int vxlan_stop(struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
 	struct vxlan_sock *vs = vxlan->vn_sock;
+	int ret = 0;
 
 	if (vs && vxlan_addr_multicast(&vxlan->default_dst.remote_ip) &&
 	    !vxlan_group_used(vn, vxlan)) {
-		vxlan_sock_hold(vs);
-		dev_hold(dev);
-		queue_work(vxlan_wq, &vxlan->igmp_leave);
+		ret = vxlan_igmp_leave(vxlan);
+		if (ret)
+			return ret;
 	}
 
 	del_timer_sync(&vxlan->age_timer);
 
 	vxlan_flush(vxlan);
+	vxlan_sock_release(vs);
 
-	return 0;
+	return ret;
 }
 
 /* Stub, nothing needs to be done. */
@@ -2405,9 +2377,6 @@ static void vxlan_setup(struct net_device *dev)
 
 	INIT_LIST_HEAD(&vxlan->next);
 	spin_lock_init(&vxlan->hash_lock);
-	INIT_WORK(&vxlan->igmp_join, vxlan_igmp_join);
-	INIT_WORK(&vxlan->igmp_leave, vxlan_igmp_leave);
-	INIT_WORK(&vxlan->sock_work, vxlan_sock_work);
 
 	init_timer_deferrable(&vxlan->age_timer);
 	vxlan->age_timer.function = vxlan_cleanup;
@@ -2555,6 +2524,8 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 
 	sock = vxlan_create_sock(net, ipv6, port, flags);
 	if (IS_ERR(sock)) {
+		pr_info("Cannot bind port %d, err=%ld\n", ntohs(port),
+			PTR_ERR(sock));
 		kfree(vs);
 		return ERR_CAST(sock);
 	}
@@ -2594,45 +2565,23 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 	struct vxlan_sock *vs;
 	bool ipv6 = flags & VXLAN_F_IPV6;
 
-	vs = vxlan_socket_create(net, port, rcv, data, flags);
-	if (!IS_ERR(vs))
-		return vs;
-
-	if (no_share)	/* Return error if sharing is not allowed. */
-		return vs;
-
-	spin_lock(&vn->sock_lock);
-	vs = vxlan_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port, flags);
-	if (vs && ((vs->rcv != rcv) ||
-		   !atomic_add_unless(&vs->refcnt, 1, 0)))
-			vs = ERR_PTR(-EBUSY);
-	spin_unlock(&vn->sock_lock);
-
-	if (!vs)
-		vs = ERR_PTR(-EINVAL);
-
-	return vs;
+	if (!no_share) {
+		spin_lock(&vn->sock_lock);
+		vs = vxlan_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port,
+				     flags);
+		if (vs && vs->rcv == rcv) {
+			if (!atomic_add_unless(&vs->refcnt, 1, 0))
+				vs = ERR_PTR(-EBUSY);
+			spin_unlock(&vn->sock_lock);
+			return vs;
+		}
+		spin_unlock(&vn->sock_lock);
+	}
+
+	return vxlan_socket_create(net, port, rcv, data, flags);
 }
 EXPORT_SYMBOL_GPL(vxlan_sock_add);
 
-/* Scheduled at device creation to bind to a socket */
-static void vxlan_sock_work(struct work_struct *work)
-{
-	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, sock_work);
-	struct net *net = vxlan->net;
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	__be16 port = vxlan->dst_port;
-	struct vxlan_sock *nvs;
-
-	nvs = vxlan_sock_add(net, port, vxlan_rcv, NULL, false, vxlan->flags);
-	spin_lock(&vn->sock_lock);
-	if (!IS_ERR(nvs))
-		vxlan_vs_add_dev(nvs, vxlan);
-	spin_unlock(&vn->sock_lock);
-
-	dev_put(vxlan->dev);
-}
-
 static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
-- 
1.9.3
