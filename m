From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Tue, 20 Sep 2016 15:00:22 -0700
Message-ID: <1474408824-418864-2-git-send-email-tom@herbertland.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <tariqt@mellanox.com>,
        <bblanco@plumgrid.com>, <alexei.starovoitov@gmail.com>,
        <eric.dumazet@gmail.com>, <brouer@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55382 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754997AbcITWAh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 18:00:37 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8KM0ZtD005531
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 15:00:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25ka6gsj07-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 15:00:37 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 a6f5ca547f7d11e6a7980002c99331b0-c77fda50 for <netdev@vger.kernel.org>;        Tue,
 20 Sep 2016 15:00:33 -0700
In-Reply-To: <1474408824-418864-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates an infrastructure for registering and running code at
XDP hooks in drivers. This is based on the orignal XDP?BPF and borrows
heavily from the techniques used by netfilter to make generic nfhooks.

An XDP hook is defined by the  xdp_hook_ops. This structure contains the
ops of an XDP hook. A pointer to this structure is passed into the XDP
register function to set up a hook. The XDP register function mallocs
its own xdp_hook_ops structure and copies the values from the
xdp_hook_ops passed in. The register function also stores the pointer
value of the xdp_hook_ops argument; this pointer is used in subsequently
calls to XDP to identify the registered hook.

The interface is defined in net/xdp.h. This includes the definition of
xdp_hook_ops, functions to register and unregister hook ops on a device
or individual instances of napi, and xdp_hook_run that is called by
drivers to run the hooks.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/filter.h          |   6 +-
 include/linux/netdev_features.h |   3 +-
 include/linux/netdevice.h       |  11 ++
 include/net/xdp.h               | 218 ++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/bpf.h        |  20 ----
 include/uapi/linux/xdp.h        |  24 +++++
 net/core/Makefile               |   2 +-
 net/core/dev.c                  |   4 +
 net/core/xdp.c                  | 211 ++++++++++++++++++++++++++++++++++++++
 9 files changed, 472 insertions(+), 27 deletions(-)
 create mode 100644 include/net/xdp.h
 create mode 100644 include/uapi/linux/xdp.h
 create mode 100644 net/core/xdp.c

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 1f09c52..2a26133 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -16,6 +16,7 @@
 #include <linux/capability.h>
 
 #include <net/sch_generic.h>
+#include <net/xdp.h>
 
 #include <asm/cacheflush.h>
 
@@ -432,11 +433,6 @@ struct bpf_skb_data_end {
 	void *data_end;
 };
 
-struct xdp_buff {
-	void *data;
-	void *data_end;
-};
-
 /* compute the linear packet data range [data, data_end) which
  * will be accessed by cls_bpf and act_bpf programs
  */
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 9c6c8ef..697fdea 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -72,8 +72,8 @@ enum {
 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
 	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
-
 	NETIF_F_HW_TC_BIT,		/* Offload TC infrastructure */
+	NETIF_F_XDP_BIT,		/* Support XDP interface */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -136,6 +136,7 @@ enum {
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
 #define NETIF_F_HW_TC		__NETIF_F(HW_TC)
+#define NETIF_F_XDP		__NETIF_F(XDP)
 
 #define for_each_netdev_feature(mask_addr, bit)	\
 	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a10d8d1..f2b7d1b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -324,6 +324,7 @@ struct napi_struct {
 	struct sk_buff		*skb;
 	struct hrtimer		timer;
 	struct list_head	dev_list;
+	struct list_head	xdp_hook_list;
 	struct hlist_node	napi_hash_node;
 	unsigned int		napi_id;
 };
@@ -819,6 +820,14 @@ enum xdp_netdev_command {
 	 * return true if a program is currently attached and running.
 	 */
 	XDP_QUERY_PROG,
+	/* Initialize XDP in the device. Called the first time an XDP hook
+	 * hook is being set on the device.
+	 */
+	XDP_DEV_INIT,
+	/* XDP is finished on the device. Called after the last XDP hook
+	 * has been removed from a device.
+	 */
+	XDP_DEV_FINISH,
 };
 
 struct netdev_xdp {
@@ -1663,6 +1672,8 @@ struct net_device {
 	struct list_head	close_list;
 	struct list_head	ptype_all;
 	struct list_head	ptype_specific;
+	struct list_head        xdp_hook_list;
+	unsigned int		xdp_hook_cnt;
 
 	struct {
 		struct list_head upper;
diff --git a/include/net/xdp.h b/include/net/xdp.h
new file mode 100644
index 0000000..c01a44e
--- /dev/null
+++ b/include/net/xdp.h
@@ -0,0 +1,218 @@
+/*
+ * eXpress Data Path (XDP)
+ *
+ * Copyright (c) 2016 Tom Herbert <tom@herbertland.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ */
+
+#ifndef __NET_XDP_H_
+#define __NET_XDP_H_
+
+#include <linux/netdevice.h>
+#include <linux/static_key.h>
+#include <uapi/linux/xdp.h>
+
+/* XDP data structure.
+ *
+ * Fields:
+ *   data - pointer to first byte of data
+ *   data_end - pointer to last byte
+ *
+ * Length is deduced by xdp->data_end - xdp->data.
+ */
+struct xdp_buff {
+	void *data;
+	void *data_end;
+};
+
+typedef unsigned int xdp_hookfn(const void *priv, struct xdp_buff *xdp);
+typedef void xdp_put_privfn(const void *priv);
+
+/* xdp_hook_ops struct
+ *
+ * This structure contains the ops of an XDP hook. A pointer to this structure
+ * is passed into the XDP register function to set up a hook. The XDP
+ * register function mallocs its own xdp_hook_ops structure and copies the
+ * values from the xdp_hook_ops passed in. The register function also stores
+ * the pointer value of the xdp_hook_ops argument; this pointer is used
+ * in subsequently calls to XDP to identify the registered hook.
+ *
+ * Fields:
+ *
+ *   list - list glue
+ *   priority - priority for insertion into list. List is ordered lowest to
+ *	greatest priority.
+ *   priv - private data associated with hook. This is passed as an argument
+ *	to the hook function
+ *   hook - function to call when hooks are run
+ *   put_priv - function call when XDP is done with private data
+ */
+struct xdp_hook_ops {
+	struct list_head list;
+	int priority;
+	void __rcu *priv;
+	xdp_hookfn *hook;
+	xdp_put_privfn *put_priv;
+};
+
+struct xdp_hook_entry {
+	const struct xdp_hook_ops *orig_ops;
+	struct xdp_hook_ops ops;
+};
+
+extern struct xdp_hook_ops xdp_bpf_hook_ops;
+
+extern struct static_key_false xdp_hooks_needed;
+
+/* Check if XDP hooks are set for a napi or its device */
+static inline bool xdp_hook_run_needed_check(struct napi_struct *napi)
+{
+	return (static_branch_unlikely(&xdp_hooks_needed) &&
+		(!(list_empty(&napi->dev->xdp_hook_list) &&
+		   list_empty(&napi->xdp_hook_list))));
+}
+
+static inline int __xdp_hook_run(struct list_head *list_head,
+				 struct xdp_buff *xdp)
+{
+	struct xdp_hook_ops *elem;
+	int ret = XDP_PASS;
+
+	list_for_each_entry(elem, list_head, list) {
+		ret = elem->hook(elem->priv, xdp);
+		if (ret != XDP_PASS)
+			break;
+	}
+
+	return ret;
+}
+
+/* Run the XDP hooks for a napi device. Called from a driver's receive
+ * routine
+ */
+static inline int xdp_hook_run(struct napi_struct *napi, struct xdp_buff *xdp)
+{
+	struct net_device *dev = napi->dev;
+	int ret = XDP_PASS;
+
+	if (static_branch_unlikely(&xdp_hooks_needed)) {
+		/* Run hooks in napi first */
+		ret = __xdp_hook_run(&napi->xdp_hook_list, xdp);
+		if (ret != XDP_PASS)
+			return ret;
+
+		/* Now run device hooks */
+		ret = __xdp_hook_run(&dev->xdp_hook_list, xdp);
+		if (ret != XDP_PASS)
+			return ret;
+	}
+
+	return ret;
+}
+
+int __xdp_register_hook(struct net_device *dev,
+			struct list_head *list,
+			const struct xdp_hook_ops *reg,
+			bool change);
+
+/* Register an XDP hook and a device */
+static inline int xdp_register_dev_hook(struct net_device *dev,
+					const struct xdp_hook_ops *reg)
+{
+	return __xdp_register_hook(dev, &dev->xdp_hook_list, reg, false);
+}
+
+/* Register an XDP hook and a napi instance */
+static inline int xdp_register_napi_hook(struct napi_struct *napi,
+					 const struct xdp_hook_ops *reg)
+{
+	return __xdp_register_hook(napi->dev, &napi->xdp_hook_list, reg, false);
+}
+
+/* Change an XDP hook.
+ *
+ *    - If the hook does not exist (xdp_hook_ops does not match a hook set on
+ *      the device), then attempt to register the hook.
+ *    - Else, change the private data (priv field in xdp_hook_ops) in the
+ *      existing hook to be the new one (in reg). All the other fields in
+ *      xdp_hook_ops are ignored in that case.
+ */
+
+/* Change a device XDP hook */
+static inline int xdp_change_dev_hook(struct net_device *dev,
+				      const struct xdp_hook_ops *reg)
+{
+	return __xdp_register_hook(dev, &dev->xdp_hook_list, reg, true);
+}
+
+/* Change a napi XDP hook */
+static inline int xdp_change_napi_hook(struct napi_struct *napi,
+				       const struct xdp_hook_ops *reg)
+{
+	return __xdp_register_hook(napi->dev, &napi->xdp_hook_list, reg, true);
+}
+
+void __xdp_unregister_hook(struct net_device *dev,
+			   struct list_head *list,
+			   const struct xdp_hook_ops *reg);
+
+/* Unregister device XDP hook */
+static inline void xdp_unregister_dev_hook(struct net_device *dev,
+					   const struct xdp_hook_ops *reg)
+{
+	return __xdp_unregister_hook(dev, &dev->xdp_hook_list, reg);
+}
+
+/* Unregister a napi XDP hook */
+static inline void xdp_unregister_napi_hook(struct napi_struct *napi,
+					    const struct xdp_hook_ops *reg)
+{
+	return __xdp_unregister_hook(napi->dev, &napi->xdp_hook_list, reg);
+}
+
+/* Unregister all XDP hooks associated with a device (both the device hooks
+ * and hooks on all napi instances. This function is called when the netdev
+ * is being freed.
+ */
+void xdp_unregister_all_hooks(struct net_device *dev);
+
+/* Unregister all XDP hooks for a given xdp_hook_ops in a net. This walks
+ * all devices in net and napis for each device to unregister matching hooks.
+ * This can be called when a module that had registered some number of hooks
+ * is being unloaded.
+ */
+void xdp_unregister_net_hooks(struct net *net, struct xdp_hook_ops *reg);
+
+/* Find a registered device hook.
+ *   - If hook is found *ret is set to the values in the registered hook and
+ *     true is returned.
+ *   - Else false is returned.
+ */
+bool __xdp_find_hook(struct list_head *list, const struct xdp_hook_ops *reg,
+		     struct xdp_hook_ops *ret);
+
+/* Find a device XDP hook */
+static inline bool xdp_find_dev_hook(struct net_device *dev,
+				     const struct xdp_hook_ops *reg,
+				     struct xdp_hook_ops *ret)
+{
+	return __xdp_find_hook(&dev->xdp_hook_list, reg, ret);
+}
+
+/* Find a napi XDP hook */
+static inline bool xdp_find_napi_hook(struct napi_struct *napi,
+				      const struct xdp_hook_ops *reg,
+				      struct xdp_hook_ops *ret)
+{
+	return __xdp_find_hook(&napi->xdp_hook_list, reg, ret);
+}
+
+static inline void xdp_warn_invalid_action(u32 act)
+{
+	WARN_ONCE(1, "Illegal XDP return value %u, expect packet loss\n", act);
+}
+
+#endif /* __NET_XDP_H_ */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f896dfa..1a143d3 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -473,24 +473,4 @@ struct bpf_tunnel_key {
 	__u32 tunnel_label;
 };
 
-/* User return codes for XDP prog type.
- * A valid XDP program must return one of these defined values. All other
- * return codes are reserved for future use. Unknown return codes will result
- * in packet drop.
- */
-enum xdp_action {
-	XDP_ABORTED = 0,
-	XDP_DROP,
-	XDP_PASS,
-	XDP_TX,
-};
-
-/* user accessible metadata for XDP packet hook
- * new fields must be added to the end of this structure
- */
-struct xdp_md {
-	__u32 data;
-	__u32 data_end;
-};
-
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/include/uapi/linux/xdp.h b/include/uapi/linux/xdp.h
new file mode 100644
index 0000000..f3002ca
--- /dev/null
+++ b/include/uapi/linux/xdp.h
@@ -0,0 +1,24 @@
+#ifndef _UAPI__LINUX_XDP_H__
+#define _UAPI__LINUX_XDP_H__
+
+/* User return codes for XDP prog type.
+ * A valid XDP program must return one of these defined values. All other
+ * return codes are reserved for future use. Unknown return codes will result
+ * in packet drop.
+ */
+enum xdp_action {
+	XDP_ABORTED = 0,
+	XDP_DROP,
+	XDP_PASS,
+	XDP_TX,
+};
+
+/* user accessible metadata for XDP packet hook
+ * new fields must be added to the end of this structure
+ */
+struct xdp_md {
+	__u32 data;
+	__u32 data_end;
+};
+
+#endif /* _UAPI__LINUX_XDP_H__ */
diff --git a/net/core/Makefile b/net/core/Makefile
index c0a0208..0d2d8ca 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -9,7 +9,7 @@ obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
 obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
-			sock_diag.o dev_ioctl.o tso.o sock_reuseport.o
+			sock_diag.o dev_ioctl.o tso.o sock_reuseport.o xdp.o
 
 obj-$(CONFIG_XFRM) += flow.o
 obj-y += net-sysfs.o
diff --git a/net/core/dev.c b/net/core/dev.c
index 9dbece2..0d2c826 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -141,6 +141,7 @@
 #include <linux/netfilter_ingress.h>
 #include <linux/sctp.h>
 #include <linux/crash_dump.h>
+#include <net/xdp.h>
 
 #include "net-sysfs.h"
 
@@ -5079,6 +5080,7 @@ void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 		    int (*poll)(struct napi_struct *, int), int weight)
 {
 	INIT_LIST_HEAD(&napi->poll_list);
+	INIT_LIST_HEAD(&napi->xdp_hook_list);
 	hrtimer_init(&napi->timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL_PINNED);
 	napi->timer.function = napi_watchdog;
 	napi->gro_count = 0;
@@ -7647,6 +7649,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	INIT_LIST_HEAD(&dev->all_adj_list.lower);
 	INIT_LIST_HEAD(&dev->ptype_all);
 	INIT_LIST_HEAD(&dev->ptype_specific);
+	INIT_LIST_HEAD(&dev->xdp_hook_list);
 #ifdef CONFIG_NET_SCHED
 	hash_init(dev->qdisc_hash);
 #endif
@@ -7706,6 +7709,7 @@ void free_netdev(struct net_device *dev)
 	struct napi_struct *p, *n;
 
 	might_sleep();
+	xdp_unregister_all_hooks(dev);
 	netif_free_tx_queues(dev);
 #ifdef CONFIG_SYSFS
 	kvfree(dev->_rx);
diff --git a/net/core/xdp.c b/net/core/xdp.c
new file mode 100644
index 0000000..815ead8
--- /dev/null
+++ b/net/core/xdp.c
@@ -0,0 +1,211 @@
+/*
+ * Kernel Connection Multiplexor
+ *
+ * Copyright (c) 2016 Tom Herbert <tom@herbertland.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ */
+#include <net/xdp.h>
+
+DEFINE_STATIC_KEY_FALSE(xdp_hooks_needed);
+EXPORT_SYMBOL(xdp_hooks_needed);
+
+static DEFINE_MUTEX(xdp_hook_mutex);
+
+/* Mutex xdp_hook_mutex must be held */
+static int __xdp_register_one_hook(struct net_device *dev,
+				   struct list_head *hook_list,
+				   struct xdp_hook_entry *entry,
+				   struct xdp_hook_ops *prev_elem)
+{
+	int err;
+
+	/* Check if we driver XDP needs initialization */
+	if (!dev->xdp_hook_cnt && dev->netdev_ops->ndo_xdp) {
+		struct netdev_xdp xdp_op = {};
+
+		xdp_op.command = XDP_DEV_INIT;
+		err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
+		if (err)
+			return err;
+	}
+
+	list_add_rcu(&entry->ops.list, prev_elem->list.prev);
+	static_branch_inc(&xdp_hooks_needed);
+	dev->xdp_hook_cnt++;
+
+	return 0;
+}
+
+int __xdp_register_hook(struct net_device *dev,
+			struct list_head *hook_list,
+			const struct xdp_hook_ops *reg,
+			bool change)
+{
+	struct xdp_hook_entry *entry;
+	struct xdp_hook_ops *elem, *prevelem = NULL;
+	int err;
+
+	mutex_lock(&xdp_hook_mutex);
+
+	/* Walk list, see if hook is already registered and determin insertion
+	 * point.
+	 */
+	list_for_each_entry(elem, hook_list, list) {
+		struct xdp_hook_entry *tent;
+
+		tent = container_of(elem, struct xdp_hook_entry, ops);
+		if (tent->orig_ops == reg) {
+			if (change) {
+				void *old_priv;
+
+				/* Only allow changing priv field in an existing
+				 * hook.
+				 */
+				old_priv = rcu_dereference_protected(elem->priv,
+					lockdep_is_held(&xdp_hook_mutex));
+				rcu_assign_pointer(elem->priv, reg->priv);
+				if (old_priv && elem->put_priv)
+					elem->put_priv(old_priv);
+				err = 0;
+				goto out;
+			} else {
+				/* Already registered */
+				err = -EALREADY;
+				goto out;
+			}
+		}
+		if (reg->priority < elem->priority)
+			prevelem = elem;
+	}
+
+	entry = kmalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry)
+		return -ENOMEM;
+
+	entry->orig_ops = reg;
+	entry->ops = *reg;
+
+	if (prevelem)
+		elem = prevelem;
+
+	err = __xdp_register_one_hook(dev, hook_list, entry, elem);
+	if (err)
+		goto err;
+
+out:
+	mutex_unlock(&xdp_hook_mutex);
+
+	return 0;
+
+err:
+	mutex_unlock(&xdp_hook_mutex);
+	kfree(entry);
+	return err;
+}
+EXPORT_SYMBOL_GPL(__xdp_register_hook);
+
+/* Mutext xdp_hook_mutex must be held */
+static void __xdp_unregister_one_hook(struct net_device *dev,
+				      struct list_head *hook_list,
+				      struct xdp_hook_ops *elem)
+{
+	struct xdp_hook_entry *entry =
+		container_of(elem, struct xdp_hook_entry, ops);
+
+	list_del_rcu(&entry->ops.list);
+	static_branch_dec(&xdp_hooks_needed);
+	dev->xdp_hook_cnt--;
+
+	if (elem->priv && elem->put_priv)
+		elem->put_priv(elem->priv);
+
+	if (!dev->xdp_hook_cnt && dev->netdev_ops->ndo_xdp) {
+		struct netdev_xdp xdp_op = {};
+
+		xdp_op.command = XDP_DEV_FINISH;
+		dev->netdev_ops->ndo_xdp(dev, &xdp_op);
+	}
+}
+
+void __xdp_unregister_hook(struct net_device *dev,
+			   struct list_head *hook_list,
+			   const struct xdp_hook_ops *reg)
+{
+	struct xdp_hook_entry *entry;
+	struct xdp_hook_ops *elem;
+
+	mutex_lock(&xdp_hook_mutex);
+	list_for_each_entry(elem, hook_list, list) {
+		entry = container_of(elem, struct xdp_hook_entry, ops);
+		if (entry->orig_ops == reg) {
+			__xdp_unregister_one_hook(dev, hook_list, elem);
+			break;
+		}
+	}
+	mutex_unlock(&xdp_hook_mutex);
+	if (&elem->list == hook_list) {
+		WARN(1, "xdp_unregister__hook: hook not found!\n");
+		return;
+	}
+	synchronize_net();
+
+	kfree(entry);
+}
+EXPORT_SYMBOL_GPL(__xdp_unregister_hook);
+
+static void __xdp_unregister_hooks(struct net_device *dev,
+				   struct list_head *hook_list)
+{
+	struct xdp_hook_ops *elem, *telem;
+
+	list_for_each_entry_safe(elem, telem, hook_list, list)
+		__xdp_unregister_one_hook(dev, hook_list, elem);
+}
+
+void xdp_unregister_all_hooks(struct net_device *dev)
+{
+	struct napi_struct *napi;
+
+	/* Unregister NAPI hooks for device */
+	list_for_each_entry(napi, &dev->napi_list, dev_list)
+		__xdp_unregister_hooks(dev, &napi->xdp_hook_list);
+
+	/* Unregister device hooks */
+	__xdp_unregister_hooks(dev, &dev->xdp_hook_list);
+}
+EXPORT_SYMBOL_GPL(xdp_unregister_all_hooks);
+
+void xdp_unregister_net_hooks(struct net *net, struct xdp_hook_ops *reg)
+{
+	struct net_device *dev;
+	struct napi_struct *napi;
+
+	list_for_each_entry_rcu(dev, &net->dev_base_head, dev_list) {
+		list_for_each_entry(napi, &dev->napi_list, dev_list)
+			xdp_unregister_napi_hook(napi, reg);
+
+		xdp_unregister_dev_hook(dev, reg);
+	}
+}
+EXPORT_SYMBOL_GPL(xdp_unregister_net_hooks);
+
+bool __xdp_find_hook(struct list_head *hook_list,
+		  const struct xdp_hook_ops *reg,
+		  struct xdp_hook_ops *ret)
+{
+	struct xdp_hook_entry *entry;
+	struct xdp_hook_ops *elem;
+
+	list_for_each_entry_rcu(elem, hook_list, list) {
+		entry = container_of(elem, struct xdp_hook_entry, ops);
+		if (entry->orig_ops == reg) {
+			*ret = *elem;
+			return true;
+		}
+	}
+	return false;
+}
+EXPORT_SYMBOL_GPL(__xdp_find_hook);
-- 
2.8.0.rc2
