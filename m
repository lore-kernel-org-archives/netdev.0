From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH] vxlan: move listen socket creation from workqueue to vxlan_open
Date: Thu, 20 Nov 2014 10:33:32 -0200
Message-ID: <a66c29751c354fe08acd459479f2eacf66e9b284.1416486751.git.mleitner@redhat.com>
Cc: stephen@networkplumber.org, pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41880 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751139AbaKTMd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 07:33:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With current code, after commits 1c51a9159dde ("vxlan: fix race caused
by dropping rtnl_unlock") and 9c2e24e16fbc ("vxlan: Restructure vxlan
socket apis.") (this last for removing log messages) any failure on
listening socket creation won't be reported, neither as a return value
or logged. This is very bad for user experience and also for
applications trying to manage vxlan interfaces.

A failure can be creating two vxlan interfaces using the same dst_port
but one using an AF_INET and the other an AF_INET6 peer/multicast. The
second vxlan created would silently fail and ip link set vxlanX up would
just return 'not connected' forever, until its recreated.

We cannot create the socket on vxlan_newlink() because, as Stephen
Hemminger had noted, we have to unlock/lock rtnl when creating the
socket (because igmp handling will acquire them in the other order) and
this may lead to a race that allows creating two vxlan interfaces with
the same name, commit 1c51a9159dde. But this doesn't apply to
vxlan_open() scenario. We can unlock/lock in there safely and, with
that, we can return a better error value to the user if that's the case.

This also allowed a simplification on reuse attempt/create/try reusing
again on vxlan_init() and old worker via vxlan_sock_add(). Now it just
tries reusing and try creating if not possible.

Note that the socket is not destroyed by vxlan_stop(). That's still left
to vxlan_uninit().

For example, with this patch:
   # ip link add vxlan4 type vxlan id 41 group 229.0.0.3 dev eth0
   # ip link add vxlan6 type vxlan id 42 group ff0e::110 dev eth0
   # ip link set vxlan4 up
   # ip link set vxlan6 up
   RTNETLINK answers: Address already in use
   # ip link set vxlan4 down
   # ip link set vxlan6 up
   RTNETLINK answers: Address already in use
   # ip link del vxlan4
   # ip link set vxlan6 up
   #

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
---
 drivers/net/vxlan.c | 89 ++++++++++++++++-------------------------------------
 1 file changed, 26 insertions(+), 63 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index fa9dc45b75a6f9f7fb04e25c61fa3eb732d10af6..e648a89814238a9b00ac0de020367fe6860a4dc2 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -139,7 +139,6 @@ struct vxlan_dev {
 	__u8		  ttl;
 	u32		  flags;	/* VXLAN_F_* in vxlan.h */
 
-	struct work_struct sock_work;
 	struct work_struct igmp_join;
 	struct work_struct igmp_leave;
 
@@ -156,8 +155,6 @@ struct vxlan_dev {
 static u32 vxlan_salt __read_mostly;
 static struct workqueue_struct *vxlan_wq;
 
-static void vxlan_sock_work(struct work_struct *work);
-
 #if IS_ENABLED(CONFIG_IPV6)
 static inline
 bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr *b)
@@ -1980,38 +1977,24 @@ static void vxlan_cleanup(unsigned long arg)
 
 static void vxlan_vs_add_dev(struct vxlan_sock *vs, struct vxlan_dev *vxlan)
 {
+	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
+
 	__u32 vni = vxlan->default_dst.remote_vni;
 
 	vxlan->vn_sock = vs;
+
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
-			     vxlan->dst_port);
-	if (vs) {
-		/* If we have a socket with same port already, reuse it */
-		atomic_inc(&vs->refcnt);
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
 
@@ -2042,11 +2025,17 @@ static void vxlan_uninit(struct net_device *dev)
 static int vxlan_open(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_sock *vs = vxlan->vn_sock;
+	struct vxlan_sock *vs;
 
-	/* socket hasn't been created */
-	if (!vs)
-		return -ENOTCONN;
+	/* ip_mc_join_group/leave will acquire these in inverse order */
+	rtnl_unlock();
+	vs = vxlan_sock_add(vxlan->net, vxlan->dst_port, vxlan_rcv, NULL,
+			    false, vxlan->flags);
+	rtnl_lock();
+	if (IS_ERR(vs))
+		return PTR_ERR(vs);
+
+	vxlan_vs_add_dev(vs, vxlan);
 
 	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip)) {
 		vxlan_sock_hold(vs);
@@ -2210,7 +2199,6 @@ static void vxlan_setup(struct net_device *dev)
 	spin_lock_init(&vxlan->hash_lock);
 	INIT_WORK(&vxlan->igmp_join, vxlan_igmp_join);
 	INIT_WORK(&vxlan->igmp_leave, vxlan_igmp_leave);
-	INIT_WORK(&vxlan->sock_work, vxlan_sock_work);
 
 	init_timer_deferrable(&vxlan->age_timer);
 	vxlan->age_timer.function = vxlan_cleanup;
@@ -2355,6 +2343,8 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 
 	sock = vxlan_create_sock(net, ipv6, port, flags);
 	if (IS_ERR(sock)) {
+		pr_info("Cannot bind port %d, err=%d\n", ntohs(port),
+			PTR_ERR(sock));
 		kfree(vs);
 		return ERR_CAST(sock);
 	}
@@ -2393,48 +2383,21 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
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
-	vs = vxlan_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port);
-	if (vs) {
-		if (vs->rcv == rcv)
+	if (!no_share) {
+		spin_lock(&vn->sock_lock);
+		vs = vxlan_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port);
+		if (vs && vs->rcv == rcv) {
 			atomic_inc(&vs->refcnt);
-		else
-			vs = ERR_PTR(-EBUSY);
+			spin_unlock(&vn->sock_lock);
+			return vs;
+		}
+		spin_unlock(&vn->sock_lock);
 	}
-	spin_unlock(&vn->sock_lock);
 
-	if (!vs)
-		vs = ERR_PTR(-EINVAL);
-
-	return vs;
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
 static int vxlan_newlink(struct net *net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
-- 
1.9.3
