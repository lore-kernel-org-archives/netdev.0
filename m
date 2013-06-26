From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH vxlan v2 4/8] vxlan: Extend vxlan handlers for openvswitch.
Date: Wed, 26 Jun 2013 13:13:45 -0700
Message-ID: <1372277625-17584-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:59658 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752452Ab3FZUNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 16:13:49 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so1626491pdj.8
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 13:13:48 -0700 (PDT)
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
 drivers/net/vxlan.c |   57 ++++++++++++++++++++++++++------------------------
 include/net/vxlan.h |   28 +++++++++++++++++++++++++
 2 files changed, 58 insertions(+), 27 deletions(-)
 create mode 100644 include/net/vxlan.h

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3be6cda..e62fbc0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -41,6 +41,7 @@
 #include <net/inet_ecn.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/vxlan.h>
 
 #define VXLAN_VERSION	"0.1"
 
@@ -92,20 +93,7 @@ struct vxlan_sock {
 	struct list_head  handler_list;
 };
 
-struct vxlan_handler;
-typedef int (vxlan_rcv_t)(struct vxlan_handler *vh, struct sk_buff *skb, __be32 key);
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
 static void vxlan_handler_hold(struct vxlan_handler *vh);
-static void vxlan_handler_put(struct vxlan_handler *vh);
 
 /* per-network namespace private data for this module */
 struct vxlan_net {
@@ -1639,12 +1627,15 @@ static void vh_del_work(struct work_struct *work)
 	mutex_unlock(&vn->sock_lock);
 }
 
-static struct vxlan_handler *vxlan_handler_add(struct net *net,
-					       __be16 portno, vxlan_rcv_t *rcv)
+
+struct vxlan_handler *vxlan_handler_add(struct net *net,
+					__be16 portno, vxlan_rcv_t *rcv,
+					void *data, int priority)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 	struct vxlan_handler *vh;
+	struct vxlan_handler *new;
 
 	mutex_lock(&vn->sock_lock);
 	/* Look to see if can reuse socket */
@@ -1652,7 +1643,7 @@ static struct vxlan_handler *vxlan_handler_add(struct net *net,
 	if (!vs) {
 		vs = vxlan_socket_create(net, portno);
 		if (IS_ERR(vs)) {
-			vh = (void *) vs;
+			new = (void *) vs;
 			goto out;
 		}
 	}
@@ -1661,40 +1652,52 @@ static struct vxlan_handler *vxlan_handler_add(struct net *net,
 	list_for_each_entry(vh, &vs->handler_list, node) {
 		if (vh->rcv == rcv) {
 			atomic_inc(&vh->refcnt);
+			new = vh;
 			goto out;
 		}
 	}
 
-	vh = kzalloc(sizeof(*vh), GFP_KERNEL);
-	if (!vh) {
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (!new) {
 		vxlan_socket_del(vs);
-		vh = ERR_PTR(-ENOMEM);
+		new = ERR_PTR(-ENOMEM);
 		goto out;
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
+
+	list_for_each_entry(vh, &vs->handler_list, node) {
+		if (vh->priority > priority) {
+			list_add_tail_rcu(&new->node, &vh->node);
+			goto out;
+		}
+	}
 
-	list_add_rcu(&vh->node, &vs->handler_list);
+	list_add_tail_rcu(&new->node, &vs->handler_list);
 out:
 	mutex_unlock(&vn->sock_lock);
-	return vh;
+	return new;
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
 
 /* Scheduled at device creation to bind to a socket */
 static void vxlan_handler_work(struct work_struct *work)
@@ -1706,7 +1709,7 @@ static void vxlan_handler_work(struct work_struct *work)
 	__be16 port = vxlan->dst_port;
 	struct vxlan_handler *vh = NULL;
 
-	vh = vxlan_handler_add(net, port, vxlan_rcv);
+	vh = vxlan_handler_add(net, port, vxlan_rcv, NULL, 0);
 	if (IS_ERR(vh)) {
 		netdev_err(vxlan->dev, "Can not create UDP socket, %ld\n",
 			   PTR_ERR(vh));
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
new file mode 100644
index 0000000..cbafe52
--- /dev/null
+++ b/include/net/vxlan.h
@@ -0,0 +1,28 @@
+#ifndef __NET_VXLAN_H
+#define __NET_VXLAN_H 1
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/udp.h>
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
+					void *data, int priority);
+
+#endif
-- 
1.7.1
