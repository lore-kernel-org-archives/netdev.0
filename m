From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v7 4/8] vxlan: Extend vxlan handlers for openvswitch.
Date: Mon, 19 Aug 2013 11:23:07 -0700
Message-ID: <1376936587-25601-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:46237 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750941Ab3HSSXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 14:23:22 -0400
Received: by mail-pd0-f175.google.com with SMTP id q10so5556694pdj.20
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 11:23:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch adds data field to vxlan socket and export
vxlan handler api.
vh->data is required to store private data per vxlan handler.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   45 +++++++++++++++++++--------------------------
 include/net/vxlan.h |   31 +++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+), 26 deletions(-)
 create mode 100644 include/net/vxlan.h

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 236c445..aab927b 100644
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
 
 /* Callback to update multicast group membership when first VNI on
  * multicast asddress is brought up
@@ -832,7 +822,6 @@ static void vxlan_sock_release(struct vxlan_net *vn, struct vxlan_sock *vs)
 static void vxlan_igmp_join(struct work_struct *work)
 {
 	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_join);
-	struct vxlan_net *vn = net_generic(dev_net(vxlan->dev), vxlan_net_id);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 	struct sock *sk = vs->sock->sk;
 	struct ip_mreqn mreq = {
@@ -844,7 +833,7 @@ static void vxlan_igmp_join(struct work_struct *work)
 	ip_mc_join_group(sk, &mreq);
 	release_sock(sk);
 
-	vxlan_sock_release(vn, vs);
+	vxlan_sock_release(vs);
 	dev_put(vxlan->dev);
 }
 
@@ -852,7 +841,6 @@ static void vxlan_igmp_join(struct work_struct *work)
 static void vxlan_igmp_leave(struct work_struct *work)
 {
 	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_leave);
-	struct vxlan_net *vn = net_generic(dev_net(vxlan->dev), vxlan_net_id);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 	struct sock *sk = vs->sock->sk;
 	struct ip_mreqn mreq = {
@@ -864,7 +852,7 @@ static void vxlan_igmp_leave(struct work_struct *work)
 	ip_mc_leave_group(sk, &mreq);
 	release_sock(sk);
 
-	vxlan_sock_release(vn, vs);
+	vxlan_sock_release(vs);
 	dev_put(vxlan->dev);
 }
 
@@ -1429,13 +1417,12 @@ static void vxlan_fdb_delete_default(struct vxlan_dev *vxlan)
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
 
@@ -1653,7 +1640,7 @@ static void vxlan_del_work(struct work_struct *work)
 }
 
 static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
-					      vxlan_rcv_t *rcv)
+					      vxlan_rcv_t *rcv, void *data)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
@@ -1700,6 +1687,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	}
 	atomic_set(&vs->refcnt, 1);
 	vs->rcv = rcv;
+	vs->data = data;
 
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
@@ -1714,16 +1702,20 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	return vs;
 }
 
-static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-					 vxlan_rcv_t *rcv)
+struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
+				  vxlan_rcv_t *rcv, void *data,
+				  bool no_share)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 
-	vs = vxlan_socket_create(net, port, rcv);
+	vs = vxlan_socket_create(net, port, rcv, data);
 	if (!IS_ERR(vs))
 		return vs;
 
+	if (no_share)	/* Return error if sharing is not allowed. */
+		return vs;
+
 	spin_lock(&vn->sock_lock);
 	vs = vxlan_find_sock(net, port);
 	if (vs) {
@@ -1739,6 +1731,7 @@ static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 
 	return vs;
 }
+EXPORT_SYMBOL_GPL(vxlan_sock_add);
 
 /* Scheduled at device creation to bind to a socket */
 static void vxlan_sock_work(struct work_struct *work)
@@ -1749,7 +1742,7 @@ static void vxlan_sock_work(struct work_struct *work)
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
