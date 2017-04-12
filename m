From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 1/3] VSOCK: Add vsockmon tap functions
Date: Wed, 12 Apr 2017 17:08:23 +0100
Message-ID: <20170412160825.21037-2-stefanha@redhat.com>
References: <20170412160825.21037-1-stefanha@redhat.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Gerard Garcia <ggarcia@abra.uab.cat>,
        Jorgen Hansen <jhansen@vmware.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58616 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753333AbdDLQJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 12:09:09 -0400
In-Reply-To: <20170412160825.21037-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

Add tap functions that can be used by the vsock transports to
deliver packets to vsockmon virtual network devices.

Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
v3:
 * Include missing <linux/module.h> header in af_vsock_tap.c
---
 net/vmw_vsock/Makefile       |   2 +-
 include/net/af_vsock.h       |  13 +++++
 include/uapi/linux/if_arp.h  |   1 +
 net/vmw_vsock/af_vsock_tap.c | 114 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 129 insertions(+), 1 deletion(-)
 create mode 100644 net/vmw_vsock/af_vsock_tap.c

diff --git a/net/vmw_vsock/Makefile b/net/vmw_vsock/Makefile
index bc27c70..09fc2eb 100644
--- a/net/vmw_vsock/Makefile
+++ b/net/vmw_vsock/Makefile
@@ -3,7 +3,7 @@ obj-$(CONFIG_VMWARE_VMCI_VSOCKETS) += vmw_vsock_vmci_transport.o
 obj-$(CONFIG_VIRTIO_VSOCKETS) += vmw_vsock_virtio_transport.o
 obj-$(CONFIG_VIRTIO_VSOCKETS_COMMON) += vmw_vsock_virtio_transport_common.o
 
-vsock-y += af_vsock.o vsock_addr.o
+vsock-y += af_vsock.o af_vsock_tap.o vsock_addr.o
 
 vmw_vsock_vmci_transport-y += vmci_transport.o vmci_transport_notify.o \
 	vmci_transport_notify_qstate.o
diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index f32ed9a..c526d4f 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -188,4 +188,17 @@ struct sock *vsock_find_connected_socket(struct sockaddr_vm *src,
 void vsock_remove_sock(struct vsock_sock *vsk);
 void vsock_for_each_connected_socket(void (*fn)(struct sock *sk));
 
+/**** TAP ****/
+
+struct vsock_tap {
+	struct net_device *dev;
+	struct module *module;
+	struct list_head list;
+};
+
+int vsock_init_tap(void);
+int vsock_add_tap(struct vsock_tap *vt);
+int vsock_remove_tap(struct vsock_tap *vt);
+void vsock_deliver_tap(struct sk_buff *skb);
+
 #endif /* __AF_VSOCK_H__ */
diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
index 4d024d7..cf73510 100644
--- a/include/uapi/linux/if_arp.h
+++ b/include/uapi/linux/if_arp.h
@@ -95,6 +95,7 @@
 #define ARPHRD_IP6GRE	823		/* GRE over IPv6		*/
 #define ARPHRD_NETLINK	824		/* Netlink header		*/
 #define ARPHRD_6LOWPAN	825		/* IPv6 over LoWPAN             */
+#define ARPHRD_VSOCKMON	826		/* Vsock monitor header		*/
 
 #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
 #define ARPHRD_NONE	  0xFFFE	/* zero header length */
diff --git a/net/vmw_vsock/af_vsock_tap.c b/net/vmw_vsock/af_vsock_tap.c
new file mode 100644
index 0000000..db3188e
--- /dev/null
+++ b/net/vmw_vsock/af_vsock_tap.c
@@ -0,0 +1,114 @@
+/*
+ * Tap functions for AF_VSOCK sockets.
+ *
+ * Code based on net/netlink/af_netlink.c tap functions.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <net/sock.h>
+#include <net/af_vsock.h>
+#include <linux/if_arp.h>
+
+static DEFINE_SPINLOCK(vsock_tap_lock);
+static struct list_head vsock_tap_all __read_mostly =
+				LIST_HEAD_INIT(vsock_tap_all);
+
+int vsock_add_tap(struct vsock_tap *vt) {
+	if (unlikely(vt->dev->type != ARPHRD_VSOCKMON))
+		return -EINVAL;
+
+	__module_get(vt->module);
+
+	spin_lock(&vsock_tap_lock);
+	list_add_rcu(&vt->list, &vsock_tap_all);
+	spin_unlock(&vsock_tap_lock);
+
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
+	int ret = 0;
+	struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
+
+	if (nskb) {
+		dev_hold(dev);
+
+		nskb->dev = dev;
+		ret = dev_queue_xmit(nskb);
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
+
+	consume_skb(skb);
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
-- 
2.9.3
