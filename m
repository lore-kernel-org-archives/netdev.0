From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 4/8] vxlan: Extend vxlan handlers for openvswitch.
Date: Thu, 20 Jun 2013 00:26:41 -0700
Message-ID: <1371713201-8193-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:54650 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S935028Ab3FTH0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 03:26:44 -0400
Received: by mail-pb0-f50.google.com with SMTP id wz7so5920764pbc.9
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 00:26:43 -0700 (PDT)
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
 drivers/net/vxlan.c |   50 ++++++++++++++++++++++++++------------------------
 include/net/vxlan.h |   26 ++++++++++++++++++++++++++
 2 files changed, 52 insertions(+), 24 deletions(-)
 create mode 100644 include/net/vxlan.h

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0830b71..6ca21c0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -41,6 +41,7 @@
 #include <net/inet_ecn.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/vxlan.h>
 
 #define VXLAN_VERSION	"0.1"
 
@@ -91,17 +92,6 @@ struct vxlan_sock {
 	struct list_head handler_list;
 };
 
-struct vxlan_handler;
-typedef int (vxlan_rcv_t)(struct vxlan_handler *vh, struct sk_buff *skb, __be32 key);
-
-struct vxlan_handler {
-	vxlan_rcv_t *rcv;
-	struct list_head node;
-	struct vxlan_sock *vs;
-	unsigned int refcnt;
-	struct rcu_head	  rcu;
-};
-
 /* per-network namespace private data for this module */
 struct vxlan_net {
 	struct list_head  vxlan_list;
@@ -1533,10 +1523,11 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 }
 
 
-static struct vxlan_handler *vxlan_add_handler(struct net *net,
-					       __be16 portno, vxlan_rcv_t *rcv)
+struct vxlan_handler *vxlan_add_handler(struct net *net,
+					__be16 portno, vxlan_rcv_t *rcv,
+					void *data, int priority)
 {
-	struct vxlan_handler *vh;
+	struct vxlan_handler *vh, *new;
 	struct vxlan_sock *vs;
 
 	ASSERT_RTNL();
@@ -1554,25 +1545,35 @@ static struct vxlan_handler *vxlan_add_handler(struct net *net,
 	}
 
 	list_for_each_entry_rcu(vh, &vs->handler_list, node) {
-		if (vh->rcv == rcv) {
+		if (vh->rcv == rcv) {	/* ignore prioroty here. */
 			vh->refcnt++;
 			return vh;
 		}
 	}
 
-	vh = kzalloc(sizeof(*vh), GFP_KERNEL);
-	if (!vh)
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
 		return ERR_PTR(-ENOMEM);
 
-	vh->rcv = rcv;
-	vh->vs = vs;
-	vh->refcnt = 1;
+	new->rcv = rcv;
+	new->vs = vs;
+	new->refcnt = 1;
+	new->data = data;
+	new->priority = priority;
+
+	list_for_each_entry_rcu(vh, &vs->handler_list, node) {
+		if (vh->priority > priority) {
+			list_add_tail_rcu(&new->node, &vh->node);
+			return vh;
+		}
+	}
 
-	list_add_rcu(&vh->node, &vs->handler_list);
-	return vh;
+	list_add_tail_rcu(&new->node, &vs->handler_list);
+	return new;
 }
+EXPORT_SYMBOL_GPL(vxlan_add_handler);
 
-static void vxlan_del_handler(struct vxlan_handler *vh)
+void vxlan_del_handler(struct vxlan_handler *vh)
 {
 	struct vxlan_sock *vs = vh->vs;
 
@@ -1591,6 +1592,7 @@ static void vxlan_del_handler(struct vxlan_handler *vh)
 		}
 	}
 }
+EXPORT_SYMBOL_GPL(vxlan_del_handler);
 
 static int vxlan_newlink(struct net *net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
@@ -1670,7 +1672,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	if (data[IFLA_VXLAN_PORT])
 		vxlan->dst_port = nla_get_be16(data[IFLA_VXLAN_PORT]);
 
-	vxlan->vh = vxlan_add_handler(net, vxlan->dst_port, vxlan_rcv);
+	vxlan->vh = vxlan_add_handler(net, vxlan->dst_port, vxlan_rcv, NULL, 0);
 	if (IS_ERR(vxlan->vh))
 		return PTR_ERR(vxlan->vh);
 
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
new file mode 100644
index 0000000..015588b
--- /dev/null
+++ b/include/net/vxlan.h
@@ -0,0 +1,26 @@
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
+	vxlan_rcv_t *rcv;
+	struct list_head node;
+	void *data;
+	struct vxlan_sock *vs;
+	unsigned int refcnt;
+	struct rcu_head	  rcu;
+	int priority;
+};
+
+struct vxlan_handler *vxlan_add_handler(struct net *net,
+					    __be16 portno, vxlan_rcv_t *rcv,
+					    void *data, int priority);
+
+void vxlan_del_handler(struct vxlan_handler *vh);
+#endif
-- 
1.7.1
