From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v3 2/6] vxlan: Extend vxlan handlers for openvswitch.
Date: Wed, 24 Jul 2013 11:00:37 -0700
Message-ID: <1374688837-14275-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:37982 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752646Ab3GXSAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 14:00:40 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so664966pdj.31
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 11:00:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch adds data and priority fields to vxlan handlers
and export vxlan handler api.

vh->data is required to store private data per vxlan handler.
vh->priority allows ovs to assign lower priority for ovs vxlan
handler. So that vxlan device modules gets to look at vxlan
packet before ovs.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   83 +++++++++++++++++++++++++--------------------------
 include/net/vxlan.h |   40 ++++++++++++++++++++++++
 2 files changed, 81 insertions(+), 42 deletions(-)
 create mode 100644 include/net/vxlan.h

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f351b7c..9deb86e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -41,13 +41,12 @@
 #include <net/inet_ecn.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/vxlan.h>
 
 #define VXLAN_VERSION	"0.1"
 
 #define PORT_HASH_BITS	8
 #define PORT_HASH_SIZE  (1<<PORT_HASH_BITS)
-#define VNI_HASH_BITS	10
-#define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
 #define FDB_HASH_BITS	8
 #define FDB_HASH_SIZE	(1<<FDB_HASH_BITS)
 #define FDB_AGE_DEFAULT 300 /* 5 min */
@@ -83,33 +82,14 @@ static int vxlan_net_id;
 
 static const u8 all_zeros_mac[ETH_ALEN];
 
-/* per UDP socket information */
-struct vxlan_sock {
-	struct hlist_node hlist;
-	struct rcu_head	  rcu;
-	struct socket	  *sock;
-	struct hlist_head vni_list[VNI_HASH_SIZE];
-	struct list_head  handler_list;
-};
-
-struct vxlan_handler;
-typedef int (vxlan_rcv_t)(struct vxlan_handler *vh,
-			  struct sk_buff *skb, __be32 key);
-
-struct vxlan_handler {
-	vxlan_rcv_t	  *rcv;
-	struct list_head   node;
-	struct vxlan_sock *vs;
-	atomic_t	   refcnt;
-	struct rcu_head    rcu;
-	struct work_struct del_work;
-};
-
 static struct vxlan_handler *vs_handler_add(struct vxlan_sock *vs,
 					    __be16 portno,
-					    vxlan_rcv_t *rcv);
+					    vxlan_rcv_t *rcv,
+					    void *data,
+					    int priority,
+					    bool force_create);
+
 static void vxlan_handler_hold(struct vxlan_handler *vh);
-static void vxlan_handler_put(struct vxlan_handler *vh);
 
 /* per-network namespace private data for this module */
 struct vxlan_net {
@@ -1342,7 +1322,7 @@ static int vxlan_init(struct net_device *dev)
 		struct vxlan_handler *vh;
 
 		/* If we have a socket with same port already, reuse it */
-		vh = vs_handler_add(vs, vxlan->dst_port, vxlan_rcv);
+		vh = vs_handler_add(vs, vxlan->dst_port, vxlan_rcv, NULL, 0, false);
 		vxlan_vh_add_dev(vh, vxlan);
 	} else {
 		/* otherwise make new socket outside of RTNL */
@@ -1660,34 +1640,51 @@ static void vh_del_work(struct work_struct *work)
 
 static struct vxlan_handler *vs_handler_add(struct vxlan_sock *vs,
 					    __be16 portno,
-					    vxlan_rcv_t *rcv)
+					    vxlan_rcv_t *rcv,
+					    void *data,
+					    int priority,
+					    bool force_create)
 {
-	struct vxlan_handler *vh;
+	struct vxlan_handler *vh, *new;
 
 	/* Try existing vxlan hanlders for this socket. */
 	list_for_each_entry(vh, &vs->handler_list, node) {
 		if (vh->rcv == rcv) {
+			if (force_create)
+				return ERR_PTR(-EEXIST);
+
 			atomic_inc(&vh->refcnt);
 			return vh;
 		}
 	}
 
-	vh = kzalloc(sizeof(*vh), GFP_KERNEL);
-	if (!vh) {
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (!new) {
 		vxlan_socket_del(vs);
 		return ERR_PTR(-ENOMEM);
 	}
-	vh->rcv = rcv;
-	vh->vs = vs;
-	atomic_set(&vh->refcnt, 1);
-	INIT_WORK(&vh->del_work, vh_del_work);
+	new->rcv = rcv;
+	new->vs = vs;
+	atomic_set(&new->refcnt, 1);
+	INIT_WORK(&new->del_work, vh_del_work);
+	new->data = data;
+	new->priority = priority;
 
-	list_add_rcu(&vh->node, &vs->handler_list);
-	return vh;
+	list_for_each_entry(vh, &vs->handler_list, node) {
+		if (vh->priority > priority) {
+			list_add_tail_rcu(&new->node, &vh->node);
+			return new;
+		}
+	}
+
+	list_add_tail_rcu(&new->node, &vs->handler_list);
+
+	return new;
 }
 
-static struct vxlan_handler *vxlan_handler_add(struct net *net,
-					       __be16 portno, vxlan_rcv_t *rcv)
+struct vxlan_handler *vxlan_handler_add(struct net *net,
+					__be16 portno, vxlan_rcv_t *rcv,
+					void *data, int priority, bool force_create)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_handler *vh;
@@ -1704,25 +1701,27 @@ static struct vxlan_handler *vxlan_handler_add(struct net *net,
 		vh = ERR_PTR(-ENOENT);
 		goto out;
 	}
-	vh = vs_handler_add(vs, portno, rcv);
+	vh = vs_handler_add(vs, portno, rcv, data, priority, force_create);
 
 out:
 	mutex_unlock(&vn->sock_lock);
 	return vh;
 }
+EXPORT_SYMBOL_GPL(vxlan_handler_add);
 
 static void vxlan_handler_hold(struct vxlan_handler *vh)
 {
 	atomic_inc(&vh->refcnt);
 }
 
-static void vxlan_handler_put(struct vxlan_handler *vh)
+void vxlan_handler_put(struct vxlan_handler *vh)
 {
 	BUG_ON(!vh->vs);
 
 	if (atomic_dec_and_test(&vh->refcnt))
 		queue_work(vxlan_wq, &vh->del_work);
 }
+EXPORT_SYMBOL_GPL(vxlan_handler_put);
 
 static void vxlan_vh_add_dev(struct vxlan_handler *vh, struct vxlan_dev *vxlan)
 {
@@ -1746,7 +1745,7 @@ static void vxlan_handler_work(struct work_struct *work)
 	__be16 port = vxlan->dst_port;
 	struct vxlan_handler *vh = NULL;
 
-	vh = vxlan_handler_add(net, port, vxlan_rcv);
+	vh = vxlan_handler_add(net, port, vxlan_rcv, NULL, 0, false);
 	vxlan_vh_add_dev(vh, vxlan);
 	dev_put(dev);
 }
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
new file mode 100644
index 0000000..5794bf7
--- /dev/null
+++ b/include/net/vxlan.h
@@ -0,0 +1,40 @@
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
+/* per UDP socket information */
+struct vxlan_sock {
+	struct hlist_node hlist;
+	struct rcu_head	  rcu;
+	struct socket	  *sock;
+	struct hlist_head vni_list[VNI_HASH_SIZE];
+	struct list_head  handler_list;
+};
+
+struct vxlan_handler;
+typedef int (vxlan_rcv_t)(struct vxlan_handler *vh, struct sk_buff *skb, __be32 key);
+
+struct vxlan_handler {
+	vxlan_rcv_t	  *rcv;
+	struct list_head   node;
+	void		  *data;
+	struct vxlan_sock *vs;
+	atomic_t	   refcnt;
+	struct rcu_head    rcu;
+	struct work_struct del_work;
+	int		   priority;
+};
+
+void vxlan_handler_put(struct vxlan_handler *vh);
+
+struct vxlan_handler *vxlan_handler_add(struct net *net,
+					__be16 portno, vxlan_rcv_t *rcv,
+					void *data, int priority, bool force_create);
+
+#endif
-- 
1.7.1
