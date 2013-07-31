From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v5 3/7] vxlan: Extend vxlan handlers for openvswitch.
Date: Wed, 31 Jul 2013 16:14:34 -0700
Message-ID: <1375312474-18664-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:34540 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751075Ab3GaXOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 19:14:37 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so1427135pab.29
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 16:14:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch adds data field to vxlan socket and export
vxlan handler api.
vh->data is required to store private data per vxlan handler.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   50 ++++++++++++++++++++++++--------------------------
 include/net/vxlan.h |   31 +++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+), 26 deletions(-)
 create mode 100644 include/net/vxlan.h

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8efee59..831e276 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -41,6 +41,7 @@
 #include <net/inet_ecn.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/vxlan.h>
 
 #define VXLAN_VERSION	"0.1"
 
@@ -83,20 +84,6 @@ static int vxlan_net_id;
 
 static const u8 all_zeros_mac[ETH_ALEN];
 
-struct vxlan_sock;
-typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb, __be32 key);
-
-/* per UDP socket information */
-struct vxlan_sock {
-	vxlan_rcv_t	 *rcv;
-	struct hlist_node hlist;
-	struct rcu_head	  rcu;
-	struct work_struct del_work;
-	atomic_t	  refcnt;
-	struct socket	  *sock;
-	struct hlist_head vni_list[VNI_HASH_SIZE];
-};
-
 /* per-network namespace private data for this module */
 struct vxlan_net {
 	struct list_head  vxlan_list;
@@ -813,8 +800,10 @@ static void vxlan_sock_hold(struct vxlan_sock *vs)
 	atomic_inc(&vs->refcnt);
 }
 
-static void vxlan_sock_release(struct vxlan_net *vn, struct vxlan_sock *vs)
+void vxlan_sock_release(struct vxlan_sock *vs)
 {
+	struct vxlan_net *vn = net_generic(sock_net(vs->sock->sk), vxlan_net_id);
+
 	if (!atomic_dec_and_test(&vs->refcnt))
 		return;
 
@@ -824,6 +813,7 @@ static void vxlan_sock_release(struct vxlan_net *vn, struct vxlan_sock *vs)
 
 	queue_work(vxlan_wq, &vs->del_work);
 }
+EXPORT_SYMBOL_GPL(vxlan_sock_release);
 
 /* Callback to update multicast group membership.
  * Scheduled when vxlan goes up/down.
@@ -846,7 +836,7 @@ static void vxlan_igmp_work(struct work_struct *work)
 		ip_mc_leave_group(sk, &mreq);
 	release_sock(sk);
 
-	vxlan_sock_release(vn, vs);
+	vxlan_sock_release(vs);
 	dev_put(vxlan->dev);
 }
 
@@ -1411,13 +1401,12 @@ static void vxlan_fdb_delete_default(struct vxlan_dev *vxlan)
 static void vxlan_uninit(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 
 	vxlan_fdb_delete_default(vxlan);
 
 	if (vs)
-		vxlan_sock_release(vn, vs);
+		vxlan_sock_release(vs);
 	free_percpu(dev->tstats);
 }
 
@@ -1630,7 +1619,7 @@ static void vxlan_del_work(struct work_struct *work)
 }
 
 static void vxlan_socket_create(struct net *net, __be16 port,
-				vxlan_rcv_t *rcv)
+				vxlan_rcv_t *rcv, void *data)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
@@ -1679,6 +1668,7 @@ static void vxlan_socket_create(struct net *net, __be16 port,
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
 	vs->rcv = rcv;
+	vs->data = data;
 	spin_lock(&vn->sock_lock);
 	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
 	spin_unlock(&vn->sock_lock);
@@ -1691,21 +1681,28 @@ static void vxlan_socket_create(struct net *net, __be16 port,
 }
 
 /* Scheduled at device creation to bind to a socket */
-static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-					 vxlan_rcv_t *rcv)
+struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
+				  vxlan_rcv_t *rcv, void *data,
+				  bool no_share)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 
-	vxlan_socket_create(net, port, rcv);
+	vxlan_socket_create(net, port, rcv, data);
 
 	spin_lock(&vn->sock_lock);
 	vs = vxlan_find_sock(net, port);
 	if (vs) {
-		if (vs->rcv == rcv)
-			atomic_inc(&vs->refcnt);
-		else
+		if (vs->rcv == rcv) {
+
+			if (no_share && atomic_read(&vs->refcnt))
+				vs = ERR_PTR(-EEXIST);
+			else
+				atomic_inc(&vs->refcnt);
+
+		} else {
 			vs = ERR_PTR(-EBUSY);
+		}
 	}
 	spin_unlock(&vn->sock_lock);
 
@@ -1714,6 +1711,7 @@ static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 
 	return vs;
 }
+EXPORT_SYMBOL_GPL(vxlan_sock_add);
 
 static void vxlan_sock_work(struct work_struct *work)
 {
@@ -1723,7 +1721,7 @@ static void vxlan_sock_work(struct work_struct *work)
 	__be16 port = vxlan->dst_port;
 	struct vxlan_sock *nvs;
 
-	nvs = vxlan_sock_add(net, port, vxlan_rcv);
+	nvs = vxlan_sock_add(net, port, vxlan_rcv, NULL, false);
 	spin_lock(&vn->sock_lock);
 	if (!IS_ERR(nvs))
 		vxlan_vs_add_dev(nvs, vxlan);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
new file mode 100644
index 0000000..43de275
--- /dev/null
+++ b/include/net/vxlan.h
@@ -0,0 +1,31 @@
+#ifndef __NET_VXLAN_H
+#define __NET_VXLAN_H 1
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/udp.h>
+
+#define VNI_HASH_BITS	10
+#define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
+
+struct vxlan_sock;
+typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb, __be32 key);
+
+/* per UDP socket information */
+struct vxlan_sock {
+	struct hlist_node hlist;
+	vxlan_rcv_t	 *rcv;
+	void		 *data;
+	struct work_struct del_work;
+	struct socket	 *sock;
+	struct rcu_head	  rcu;
+	struct hlist_head vni_list[VNI_HASH_SIZE];
+	atomic_t	  refcnt;
+};
+
+struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
+				  vxlan_rcv_t *rcv, void *data,
+				  bool no_share);
+
+void vxlan_sock_release(struct vxlan_sock *vs);
+#endif
-- 
1.7.1
