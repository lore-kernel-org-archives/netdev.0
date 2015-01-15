From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/5] vxlan: Only bind to sockets with compatible flags enabled
Date: Thu, 15 Jan 2015 03:53:56 +0100
Message-ID: <f02c2207d280de6e3bb1d7ce97e734a695259750.1421290198.git.tgraf@suug.ch>
References: <cover.1421290198.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: davem@davemloft.net, jesse@nicira.com, stephen@networkplumber.org,
	pshelar@nicira.com, therbert@google.com,
	alexei.starovoitov@gmail.com, nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35206 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbbAOCyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 21:54:04 -0500
In-Reply-To: <cover.1421290198.git.tgraf@suug.ch>
In-Reply-To: <cover.1421290198.git.tgraf@suug.ch>
References: <cover.1421290198.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A VXLAN net_device looking for an appropriate socket may only consider
a socket which has a matching set of flags/extensions enabled. If
incompatible flags are enabled, return a conflict to have the caller
create a distinct socket with distinct port.

The OVS VXLAN port is kept unaware of extensions at this point.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
v5->v6:
 - Keep sharing logic but base it off unsharable flags instead of exts
   member as suggested by Tom
v4->v5:
 - No change
v3->v4:
 - No change
v2->v3:
 - No change
v1->v2:
 - Improved commit message, reported by Jesse

 drivers/net/vxlan.c | 29 ++++++++++++++++++-----------
 include/net/vxlan.h |  3 +++
 2 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6dbf8e0..6b6b456 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -263,15 +263,19 @@ static inline struct vxlan_rdst *first_remote_rtnl(struct vxlan_fdb *fdb)
 	return list_first_entry(&fdb->remotes, struct vxlan_rdst, list);
 }
 
-/* Find VXLAN socket based on network namespace, address family and UDP port */
-static struct vxlan_sock *vxlan_find_sock(struct net *net,
-					  sa_family_t family, __be16 port)
+/* Find VXLAN socket based on network namespace, address family and UDP port
+ * and enabled unshareable flags.
+ */
+static struct vxlan_sock *vxlan_find_sock(struct net *net, sa_family_t family,
+					  __be16 port, u32 flags)
 {
 	struct vxlan_sock *vs;
+	u32 match_flags = flags & VXLAN_F_UNSHAREABLE;
 
 	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
 		if (inet_sk(vs->sock->sk)->inet_sport == port &&
-		    inet_sk(vs->sock->sk)->sk.sk_family == family)
+		    inet_sk(vs->sock->sk)->sk.sk_family == family &&
+		    (vs->flags & VXLAN_F_UNSHAREABLE) == match_flags)
 			return vs;
 	}
 	return NULL;
@@ -291,11 +295,12 @@ static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, u32 id)
 
 /* Look up VNI in a per net namespace table */
 static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id,
-					sa_family_t family, __be16 port)
+					sa_family_t family, __be16 port,
+					u32 flags)
 {
 	struct vxlan_sock *vs;
 
-	vs = vxlan_find_sock(net, family, port);
+	vs = vxlan_find_sock(net, family, port, flags);
 	if (!vs)
 		return NULL;
 
@@ -1957,7 +1962,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 			ip_rt_put(rt);
 			dst_vxlan = vxlan_find_vni(vxlan->net, vni,
-						   dst->sa.sa_family, dst_port);
+						   dst->sa.sa_family, dst_port,
+						   vxlan->flags);
 			if (!dst_vxlan)
 				goto tx_error;
 			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
@@ -2016,7 +2022,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 			dst_release(ndst);
 			dst_vxlan = vxlan_find_vni(vxlan->net, vni,
-						   dst->sa.sa_family, dst_port);
+						   dst->sa.sa_family, dst_port,
+						   vxlan->flags);
 			if (!dst_vxlan)
 				goto tx_error;
 			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
@@ -2186,7 +2193,7 @@ static int vxlan_init(struct net_device *dev)
 
 	spin_lock(&vn->sock_lock);
 	vs = vxlan_find_sock(vxlan->net, ipv6 ? AF_INET6 : AF_INET,
-			     vxlan->dst_port);
+			     vxlan->dst_port, vxlan->flags);
 	if (vs && atomic_add_unless(&vs->refcnt, 1, 0)) {
 		/* If we have a socket with same port already, reuse it */
 		vxlan_vs_add_dev(vs, vxlan);
@@ -2593,7 +2600,7 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 		return vs;
 
 	spin_lock(&vn->sock_lock);
-	vs = vxlan_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port);
+	vs = vxlan_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port, flags);
 	if (vs && ((vs->rcv != rcv) ||
 		   !atomic_add_unless(&vs->refcnt, 1, 0)))
 			vs = ERR_PTR(-EBUSY);
@@ -2761,7 +2768,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 		vxlan->flags |= VXLAN_F_GBP;
 
 	if (vxlan_find_vni(net, vni, use_ipv6 ? AF_INET6 : AF_INET,
-			   vxlan->dst_port)) {
+			   vxlan->dst_port, vxlan->flags)) {
 		pr_info("duplicate VNI %u\n", vni);
 		return -EEXIST;
 	}
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index f4a3583..7be8c34 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -129,6 +129,9 @@ struct vxlan_sock {
 #define VXLAN_F_REMCSUM_RX		0x400
 #define VXLAN_F_GBP			0x800
 
+/* These flags must match in order for a socket to be shareable */
+#define VXLAN_F_UNSHAREABLE		VXLAN_F_GBP
+
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
 				  bool no_share, u32 flags);
-- 
1.9.3
