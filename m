From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/5] vxlan: Only bind to sockets with correct extensions enabled
Date: Tue, 13 Jan 2015 17:20:43 +0100
Message-ID: <9d9d405f60ce51d184a51ea46b3656fb91cae5c5.1421165078.git.tgraf@suug.ch>
References: <cover.1421165078.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: davem@davemloft.net, jesse@nicira.com, stephen@networkplumber.org,
	pshelar@nicira.com, therbert@google.com,
	alexei.starovoitov@gmail.com, nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:36116 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676AbbAMQVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 11:21:01 -0500
In-Reply-To: <cover.1421165078.git.tgraf@suug.ch>
In-Reply-To: <cover.1421165078.git.tgraf@suug.ch>
References: <cover.1421165078.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A VXLAN net_device looking for an appropriate socket may only consider
a socket which has a matching set of extensions enabled. If the
extensions don't match, return a conflict to have the caller create a
distinct socket with distinct port.

The OVS VXLAN port is kept unaware of extensions at this point.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
v3->v4:
 - No change
v2->v3:
 - No change
v1->v2:
 - Improved commit message, reported by Jesse

 drivers/net/vxlan.c           | 35 +++++++++++++++++++++--------------
 include/net/vxlan.h           |  2 +-
 net/openvswitch/vport-vxlan.c |  2 +-
 3 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 72c4e30..f41eb91 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -265,14 +265,15 @@ static inline struct vxlan_rdst *first_remote_rtnl(struct vxlan_fdb *fdb)
 }
 
 /* Find VXLAN socket based on network namespace, address family and UDP port */
-static struct vxlan_sock *vxlan_find_sock(struct net *net,
-					  sa_family_t family, __be16 port)
+static struct vxlan_sock *vxlan_find_sock(struct net *net, sa_family_t family,
+					  __be16 port, u32 exts)
 {
 	struct vxlan_sock *vs;
 
 	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
 		if (inet_sk(vs->sock->sk)->inet_sport == port &&
-		    inet_sk(vs->sock->sk)->sk.sk_family == family)
+		    inet_sk(vs->sock->sk)->sk.sk_family == family &&
+		    vs->exts == exts)
 			return vs;
 	}
 	return NULL;
@@ -292,11 +293,12 @@ static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, u32 id)
 
 /* Look up VNI in a per net namespace table */
 static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id,
-					sa_family_t family, __be16 port)
+					sa_family_t family, __be16 port,
+					u32 exts)
 {
 	struct vxlan_sock *vs;
 
-	vs = vxlan_find_sock(net, family, port);
+	vs = vxlan_find_sock(net, family, port, exts);
 	if (!vs)
 		return NULL;
 
@@ -1790,7 +1792,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 			ip_rt_put(rt);
 			dst_vxlan = vxlan_find_vni(vxlan->net, vni,
-						   dst->sa.sa_family, dst_port);
+						   dst->sa.sa_family, dst_port,
+						   vxlan->exts);
 			if (!dst_vxlan)
 				goto tx_error;
 			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
@@ -1849,7 +1852,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 			dst_release(ndst);
 			dst_vxlan = vxlan_find_vni(vxlan->net, vni,
-						   dst->sa.sa_family, dst_port);
+						   dst->sa.sa_family, dst_port,
+						   vxlan->exts);
 			if (!dst_vxlan)
 				goto tx_error;
 			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
@@ -2019,7 +2023,7 @@ static int vxlan_init(struct net_device *dev)
 
 	spin_lock(&vn->sock_lock);
 	vs = vxlan_find_sock(vxlan->net, ipv6 ? AF_INET6 : AF_INET,
-			     vxlan->dst_port);
+			     vxlan->dst_port, vxlan->exts);
 	if (vs && atomic_add_unless(&vs->refcnt, 1, 0)) {
 		/* If we have a socket with same port already, reuse it */
 		vxlan_vs_add_dev(vs, vxlan);
@@ -2373,7 +2377,7 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
 /* Create new listen socket if needed */
 static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 					      vxlan_rcv_t *rcv, void *data,
-					      u32 flags)
+					      u32 flags, u32 exts)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
@@ -2401,6 +2405,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	atomic_set(&vs->refcnt, 1);
 	vs->rcv = rcv;
 	vs->data = data;
+	vs->exts = exts;
 
 	/* Initialize the vxlan udp offloads structure */
 	vs->udp_offloads.port = port;
@@ -2425,13 +2430,14 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
-				  bool no_share, u32 flags)
+				  bool no_share, u32 flags,
+				  u32 exts)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 	bool ipv6 = flags & VXLAN_F_IPV6;
 
-	vs = vxlan_socket_create(net, port, rcv, data, flags);
+	vs = vxlan_socket_create(net, port, rcv, data, flags, exts);
 	if (!IS_ERR(vs))
 		return vs;
 
@@ -2439,7 +2445,7 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 		return vs;
 
 	spin_lock(&vn->sock_lock);
-	vs = vxlan_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port);
+	vs = vxlan_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port, exts);
 	if (vs && ((vs->rcv != rcv) ||
 		   !atomic_add_unless(&vs->refcnt, 1, 0)))
 			vs = ERR_PTR(-EBUSY);
@@ -2461,7 +2467,8 @@ static void vxlan_sock_work(struct work_struct *work)
 	__be16 port = vxlan->dst_port;
 	struct vxlan_sock *nvs;
 
-	nvs = vxlan_sock_add(net, port, vxlan_rcv, NULL, false, vxlan->flags);
+	nvs = vxlan_sock_add(net, port, vxlan_rcv, NULL, false, vxlan->flags,
+			     vxlan->exts);
 	spin_lock(&vn->sock_lock);
 	if (!IS_ERR(nvs))
 		vxlan_vs_add_dev(nvs, vxlan);
@@ -2611,7 +2618,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 		configure_vxlan_exts(vxlan, data[IFLA_VXLAN_EXTENSION]);
 
 	if (vxlan_find_vni(net, vni, use_ipv6 ? AF_INET6 : AF_INET,
-			   vxlan->dst_port)) {
+			   vxlan->dst_port, vxlan->exts)) {
 		pr_info("duplicate VNI %u\n", vni);
 		return -EEXIST;
 	}
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 76a3aa2..4b6e794 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -121,7 +121,7 @@ struct vxlan_sock {
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
-				  bool no_share, u32 flags);
+				  bool no_share, u32 flags, u32 exts);
 
 void vxlan_sock_release(struct vxlan_sock *vs);
 
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index deed9e3..40a16fb 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -128,7 +128,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
 	vxlan_port = vxlan_vport(vport);
 	strncpy(vxlan_port->name, parms->name, IFNAMSIZ);
 
-	vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true, 0);
+	vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true, 0, 0);
 	if (IS_ERR(vs)) {
 		ovs_vport_free(vport);
 		return (void *)vs;
-- 
1.9.3
