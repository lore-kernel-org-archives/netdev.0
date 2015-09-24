From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 1/2] vxlan: make vxlan_sock_add and vxlan_sock_release complementary
Date: Thu, 24 Sep 2015 13:50:01 +0200
Message-ID: <8ec6b1f3336530104efd71ccace365d01205596e.1443094736.git.jbenc@redhat.com>
References: <cover.1443094736.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36099 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752900AbbIXLuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 07:50:16 -0400
In-Reply-To: <cover.1443094736.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make vxlan_sock_add both alloc the socket and attach it to vxlan_dev. Let
vxlan_sock_release accept vxlan_dev as its parameter instead of vxlan_sock.

This makes vxlan_sock_add and vxlan_sock release complementary. It reduces
code duplication in the next patch.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 53 +++++++++++++++++++++++++----------------------------
 1 file changed, 25 insertions(+), 28 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bbac1d35ed4e..a86613011977 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -75,8 +75,7 @@ static struct rtnl_link_ops vxlan_link_ops;
 
 static const u8 all_zeros_mac[ETH_ALEN];
 
-static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-					 bool no_share, u32 flags);
+static int vxlan_sock_add(struct vxlan_dev *vxlan);
 
 /* per-network namespace private data for this module */
 struct vxlan_net {
@@ -1022,8 +1021,9 @@ static bool vxlan_group_used(struct vxlan_net *vn, struct vxlan_dev *dev)
 	return false;
 }
 
-static void vxlan_sock_release(struct vxlan_sock *vs)
+static void vxlan_sock_release(struct vxlan_dev *vxlan)
 {
+	struct vxlan_sock *vs = vxlan->vn_sock;
 	struct sock *sk = vs->sock->sk;
 	struct net *net = sock_net(sk);
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
@@ -2244,22 +2244,18 @@ static void vxlan_uninit(struct net_device *dev)
 static int vxlan_open(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_sock *vs;
-	int ret = 0;
-
-	vs = vxlan_sock_add(vxlan->net, vxlan->cfg.dst_port,
-			    vxlan->cfg.no_share, vxlan->flags);
-	if (IS_ERR(vs))
-		return PTR_ERR(vs);
+	int ret;
 
-	vxlan_vs_add_dev(vs, vxlan);
+	ret = vxlan_sock_add(vxlan);
+	if (ret < 0)
+		return ret;
 
 	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip)) {
 		ret = vxlan_igmp_join(vxlan);
 		if (ret == -EADDRINUSE)
 			ret = 0;
 		if (ret) {
-			vxlan_sock_release(vs);
+			vxlan_sock_release(vxlan);
 			return ret;
 		}
 	}
@@ -2294,7 +2290,6 @@ static int vxlan_stop(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
-	struct vxlan_sock *vs = vxlan->vn_sock;
 	int ret = 0;
 
 	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip) &&
@@ -2304,7 +2299,7 @@ static int vxlan_stop(struct net_device *dev)
 	del_timer_sync(&vxlan->age_timer);
 
 	vxlan_flush(vxlan);
-	vxlan_sock_release(vs);
+	vxlan_sock_release(vxlan);
 
 	return ret;
 }
@@ -2592,27 +2587,29 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	return vs;
 }
 
-static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-					 bool no_share, u32 flags)
+static int vxlan_sock_add(struct vxlan_dev *vxlan)
 {
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	struct vxlan_sock *vs;
-	bool ipv6 = flags & VXLAN_F_IPV6;
+	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
+	struct vxlan_sock *vs = NULL;
+	bool ipv6 = vxlan->flags & VXLAN_F_IPV6;
 
-	if (!no_share) {
+	if (!vxlan->cfg.no_share) {
 		spin_lock(&vn->sock_lock);
-		vs = vxlan_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port,
-				     flags);
-		if (vs) {
-			if (!atomic_add_unless(&vs->refcnt, 1, 0))
-				vs = ERR_PTR(-EBUSY);
+		vs = vxlan_find_sock(vxlan->net, ipv6 ? AF_INET6 : AF_INET,
+				     vxlan->cfg.dst_port, vxlan->flags);
+		if (vs && !atomic_add_unless(&vs->refcnt, 1, 0)) {
 			spin_unlock(&vn->sock_lock);
-			return vs;
+			return -EBUSY;
 		}
 		spin_unlock(&vn->sock_lock);
 	}
-
-	return vxlan_socket_create(net, port, flags);
+	if (!vs)
+		vs = vxlan_socket_create(vxlan->net, vxlan->cfg.dst_port,
+					 vxlan->flags);
+	if (IS_ERR(vs))
+		return PTR_ERR(vs);
+	vxlan_vs_add_dev(vs, vxlan);
+	return 0;
 }
 
 static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
-- 
1.8.3.1
