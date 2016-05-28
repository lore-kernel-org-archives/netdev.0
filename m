From: ggarcia@abra.uab.cat
Subject: [RFC 1/3] vsockmon: Add tap functions.
Date: Sat, 28 May 2016 18:29:05 +0200
Message-ID: <20160528162907.14809-2-ggarcia@deic.uab.cat>
References: <20160528162907.14809-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: jhansen@vmware.com, stefanha@redhat.com,
	Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:19939 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750738AbcE1R3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 May 2016 13:29:21 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0O7W00JXHB4RF5R0@damascus.uab.es> for
 netdev@vger.kernel.org; Sat, 28 May 2016 18:29:15 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0O7W00JLMB4RXTO0@damascus.uab.es> for
 netdev@vger.kernel.org; Sat, 28 May 2016 18:29:15 +0200 (CEST)
In-reply-to: <20160528162907.14809-1-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
---
 include/net/af_vsock.h      |  13 ++++++
 include/uapi/linux/if_arp.h |   1 +
 net/vmw_vsock/af_vsock.c    | 105 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 119 insertions(+)

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index 15694c9..c4593d8 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -187,4 +187,17 @@ struct sock *vsock_find_connected_socket(struct sockaddr_vm *src,
 					 struct sockaddr_vm *dst);
 void vsock_for_each_connected_socket(void (*fn)(struct sock *sk));
 
+/**** TAP ****/
+
+struct vsock_tap {
+	struct net_device *dev;
+	struct module *module;
+	struct list_head list;
+};
+
+extern int vsock_init_tap(void);
+extern int vsock_add_tap(struct vsock_tap *vt);
+extern int vsock_remove_tap(struct vsock_tap *vt);
+extern void vsock_deliver_tap(struct sk_buff *skb);
+
 #endif /* __AF_VSOCK_H__ */
diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
index 4d024d7..869262a 100644
--- a/include/uapi/linux/if_arp.h
+++ b/include/uapi/linux/if_arp.h
@@ -95,6 +95,7 @@
 #define ARPHRD_IP6GRE	823		/* GRE over IPv6		*/
 #define ARPHRD_NETLINK	824		/* Netlink header		*/
 #define ARPHRD_6LOWPAN	825		/* IPv6 over LoWPAN             */
+#define ARPHRD_VSOCKMON 826		/* Vsock monitor header		*/
 
 #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
 #define ARPHRD_NONE	  0xFFFE	/* zero header length */
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 6b158ab..ec7a05d 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -96,6 +96,7 @@
 #include <linux/unistd.h>
 #include <linux/wait.h>
 #include <linux/workqueue.h>
+#include <linux/if_arp.h>
 #include <net/sock.h>
 #include <net/af_vsock.h>
 
@@ -2012,6 +2013,110 @@ const struct vsock_transport *vsock_core_get_transport(void)
 }
 EXPORT_SYMBOL_GPL(vsock_core_get_transport);
 
+/**** TAP ****/
+static DEFINE_SPINLOCK(vsock_tap_lock);
+static struct list_head vsock_tap_all __read_mostly;
+
+int vsock_init_tap(void) {
+	INIT_LIST_HEAD(&vsock_tap_all);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(vsock_init_tap);
+
+int vsock_add_tap(struct vsock_tap *vt) {
+	if (unlikely(vt->dev->type != ARPHRD_VSOCKMON))
+		return -EINVAL;
+
+	spin_lock(&vsock_tap_lock);
+	list_add_rcu(&vt->list, &vsock_tap_all);
+	spin_unlock(&vsock_tap_lock);
+
+	__module_get(vt->module);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(vsock_add_tap);
+
+int __vsock_remove_tap(struct vsock_tap *vt) {
+	bool found = false;
+	struct vsock_tap *tmp;
+
+	spin_lock(&vsock_tap_lock);
+
+	list_for_each_entry(tmp, &vsock_tap_all, list) {
+		if (vt == tmp) {
+			list_del_rcu(&vt->list);
+			found = true;
+			goto out;
+		}
+	}
+
+	pr_warn("__vsock_remove_tap: %p not found\n", vt);
+out:
+	spin_unlock(&vsock_tap_lock);
+
+	if (found)
+		module_put(vt->module);
+
+	return found ? 0 : -ENODEV;
+}
+
+int vsock_remove_tap(struct vsock_tap *vt)
+{
+	int ret;
+
+	ret = __vsock_remove_tap(vt);
+	synchronize_net();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(vsock_remove_tap);
+
+static int __vsock_deliver_tap_skb(struct sk_buff *skb,
+				     struct net_device *dev)
+{
+	struct sk_buff *vskb;
+	int ret = 0;
+
+	if (skb) {
+		dev_hold(dev);
+		vskb = skb_clone(skb, GFP_ATOMIC);
+		vskb->dev = dev;
+		vskb->pkt_type = PACKET_USER;
+		ret = dev_queue_xmit(vskb);
+		if (unlikely(ret > 0))
+			ret = net_xmit_errno(ret);
+
+		dev_put(dev);
+	}
+
+	return ret;
+}
+
+static void __vsock_deliver_tap(struct sk_buff *skb)
+{
+	int ret;
+	struct vsock_tap *tmp;
+
+	list_for_each_entry_rcu(tmp, &vsock_tap_all, list) {
+		ret = __vsock_deliver_tap_skb(skb, tmp->dev);
+		if (unlikely(ret))
+			break;
+	}
+}
+
+void vsock_deliver_tap(struct sk_buff *skb)
+{
+	rcu_read_lock();
+
+	if (unlikely(!list_empty(&vsock_tap_all)))
+		__vsock_deliver_tap(skb);
+
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(vsock_deliver_tap);
+
 MODULE_AUTHOR("VMware, Inc.");
 MODULE_DESCRIPTION("VMware Virtual Socket Family");
 MODULE_VERSION("1.0.1.0-k");
-- 
2.8.3
