From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Wed, 8 Feb 2017 15:41:20 -0800
Message-ID: <20170208234127.3041579-2-tom@herbertland.com>
References: <20170208234127.3041579-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39870 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751440AbdBIA1w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 19:27:52 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v18NfWo9000926
        for <netdev@vger.kernel.org>; Wed, 8 Feb 2017 15:41:46 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 28g7qhh33b-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 15:41:46 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.222.219.45) with ESMTP id
 26aca530ee5811e6980324be05904660-46bcca50 for <netdev@vger.kernel.org>;        Wed,
 08 Feb 2017 15:41:45 -0800
In-Reply-To: <20170208234127.3041579-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates an infrastructure for registering and running code at
XDP hooks in drivers. This extends and generalizes the original XDP/BPF
interface. Specifically, it defines a generic xdp_hook structure and a
set of hooks that can be assigned to devices or napi instances.  These
hooks are also generic to allow for XDP/BPF programs as well as non-BPF
code (e.g. kernel code can be written in a module).

An XDP hook is defined by the xdp_hook structure. A pointer to this
structure is passed into the XDP register function to set up a hook.
The XDP register function mallocs its own xdp_hook structure and copies
the values from the xdp_hook passed in. The register function also saves
the pointer value of the xdp_hook argument; this pointer is used in
subsequently calls to XDP to identify the registered hook.

The interface is defined in net/xdp.h. This includes the definition of
xdp_hook, functions to register and unregister hooks on a device
or individual instances of napi, and xdp_hook_run that is called by
drivers to run the hooks.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c |   1 +
 include/linux/filter.h                           |  10 +-
 include/linux/netdev_features.h                  |   3 +-
 include/linux/netdevice.h                        |  16 ++
 include/net/xdp.h                                | 310 +++++++++++++++++++++++
 include/trace/events/xdp.h                       |  31 +++
 kernel/bpf/core.c                                |   1 +
 net/core/Makefile                                |   2 +-
 net/core/dev.c                                   |  53 ++--
 net/core/filter.c                                |   1 +
 net/core/rtnetlink.c                             |  14 +-
 net/core/xdp.c                                   | 304 ++++++++++++++++++++++
 12 files changed, 711 insertions(+), 35 deletions(-)
 create mode 100644 include/net/xdp.h
 create mode 100644 net/core/xdp.c

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
index 335beb8..d294fb2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
@@ -38,6 +38,7 @@
 #include <linux/filter.h>
 #include <linux/pkt_cls.h>
 #include <linux/unistd.h>
+#include <net/xdp.h>
 
 #include "nfp_asm.h"
 #include "nfp_bpf.h"
diff --git a/include/linux/filter.h b/include/linux/filter.h
index e4eb254..bb9f2f2 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -428,7 +428,7 @@ struct sk_filter {
 	struct bpf_prog	*prog;
 };
 
-#define BPF_PROG_RUN(filter, ctx)  (*filter->bpf_func)(ctx, filter->insnsi)
+#define BPF_PROG_RUN(filter, ctx)  (*(filter)->bpf_func)(ctx, (filter)->insnsi)
 
 #define BPF_SKB_CB_LEN QDISC_CB_PRIV_LEN
 
@@ -437,12 +437,6 @@ struct bpf_skb_data_end {
 	void *data_end;
 };
 
-struct xdp_buff {
-	void *data;
-	void *data_end;
-	void *data_hard_start;
-};
-
 /* compute the linear packet data range [data, data_end) which
  * will be accessed by cls_bpf, act_bpf and lwt programs
  */
@@ -504,6 +498,8 @@ static inline u32 bpf_prog_run_clear_cb(const struct bpf_prog *prog,
 	return BPF_PROG_RUN(prog, skb);
 }
 
+struct xdp_buff;
+
 static __always_inline u32 bpf_prog_run_xdp(const struct bpf_prog *prog,
 					    struct xdp_buff *xdp)
 {
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 9a04195..f22d379 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -71,8 +71,8 @@ enum {
 	NETIF_F_HW_VLAN_STAG_RX_BIT,	/* Receive VLAN STAG HW acceleration */
 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
-
 	NETIF_F_HW_TC_BIT,		/* Offload TC infrastructure */
+	NETIF_F_XDP_BIT,		/* Support XDP interface */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -134,6 +134,7 @@ enum {
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 #define NETIF_F_HW_TC		__NETIF_F(HW_TC)
+#define NETIF_F_XDP		__NETIF_F(XDP)
 
 #define for_each_netdev_feature(mask_addr, bit)	\
 	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 58afbd1..2404e76 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -324,6 +324,7 @@ struct napi_struct {
 	struct sk_buff		*skb;
 	struct hrtimer		timer;
 	struct list_head	dev_list;
+	struct xdp_hook_set __rcu *xdp_hooks;
 	struct hlist_node	napi_hash_node;
 	unsigned int		napi_id;
 };
@@ -821,12 +822,25 @@ enum xdp_netdev_command {
 	 * return true if a program is currently attached and running.
 	 */
 	XDP_QUERY_PROG,
+	/* Initialize device to use XDP. Called when first XDP program is
+	 * registered on a device (including on a NAPI instance).
+	 */
+	XDP_MODE_ON,
+	/* XDP is finished on the device. Called after the last XDP hook
+	 * has been removed from a device.
+	 */
+	XDP_MODE_OFF,
+	/* Check if device is okay with the proposed BPF program to be loaded */
+	XDP_CHECK_BPF_PROG,
+	/* Offload a BPF program to the device */
+	XDP_OFFLOAD_BPF,
 };
 
 struct netdev_xdp {
 	enum xdp_netdev_command command;
 	union {
 		/* XDP_SETUP_PROG */
+		/* XDP_CHECK_BPF_PROG */
 		struct bpf_prog *prog;
 		/* XDP_QUERY_PROG */
 		bool prog_attached;
@@ -1666,6 +1680,8 @@ struct net_device {
 	struct list_head	close_list;
 	struct list_head	ptype_all;
 	struct list_head	ptype_specific;
+	struct xdp_hook_set __rcu *xdp_hooks;
+	unsigned int		xdp_hook_cnt;
 
 	struct {
 		struct list_head upper;
diff --git a/include/net/xdp.h b/include/net/xdp.h
new file mode 100644
index 0000000..ba025d0
--- /dev/null
+++ b/include/net/xdp.h
@@ -0,0 +1,310 @@
+/*
+ * eXpress Data Path (XDP)
+ *
+ * Copyright (c) 2017 Tom Herbert <tom@herbertland.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ */
+
+#ifndef __NET_XDP_H_
+#define __NET_XDP_H_
+
+#include <linux/filter.h>
+#include <linux/netdevice.h>
+#include <linux/static_key.h>
+
+/* XDP data structure.
+ *
+ * Fields:
+ *   data - pointer to first byte of data
+ *   data_end - pointer to last byte
+ *   data_hard_start - point to first possible byte
+ *
+ * Length is deduced by xdp->data_end - xdp->data.
+ */
+struct xdp_buff {
+	void *data;
+	void *data_end;
+	void *data_hard_start;
+};
+
+typedef unsigned int xdp_hookfn(const void *priv, struct xdp_buff *xdp);
+typedef void xdp_put_privfn(const void *priv);
+
+#define XDP_TAG_SIZE	8 /* Should be at least BPF_TAG_SIZE */
+
+/* xdp_hook struct
+ *
+ * This structure contains the ops and data for an XDP hook. A pointer
+ * to this structure providing the definitiona of a hook is passed into
+ * the XDP register function to set up a hook. The XDP register function
+ * mallocs its own xdp_hook structure and copies the values from the
+ * xdp_hook definition. The register function also saves the pointer value
+ * of the xdp_hook definition argument; this pointer is used in subsequent
+ * calls to XDP to find or unregister the hook.
+ *
+ * Fields:
+ *
+ *   priority - priority for insertion into set. The set is ordered lowest to
+ *	highest priority.
+ *   is_bpf - indicates that the hook is a BPF program (priv refers to a
+ *	bpf_prog structure. This allows calling the BPF program directly
+ *	from xdp_run without a extra level of indirection.
+ *   hookfn - function to call when hook are run.
+ *   priv - private data associated with hook. This is passed as an argument
+ *	to the hook function (in the case of BPF this is a bpf_prog structure).
+ *   put_priv - function call when XDP is done with private data.
+ *   def - point to definitions of xdp_hook. The pointer value is saved as
+ *      a refernce the instance of hook loaded (used to find and unregister a
+ *      hook).
+ *   tag - readable tag for reporting purposes
+ */
+struct xdp_hook {
+	int priority;
+	bool is_bpf;
+	xdp_hookfn *hookfn;
+	void __rcu *priv;
+	xdp_put_privfn *put_priv;
+	const struct xdp_hook *template;
+	u8 tag[XDP_TAG_SIZE];
+};
+
+/* xdp_hook_set
+ *
+ * This structure holds a set of XDP hooks in an array of size num. This
+ * structure is used in netdevice to refer to the XDP hooks for a whole
+ * device or in the napi structure to contain the hooks for an individual
+ * RX queue.
+ */
+struct xdp_hook_set {
+	unsigned int num;
+	struct rcu_head rcu;
+	struct xdp_hook hooks[0];
+};
+
+#define XDP_SET_SIZE(_num) (sizeof(struct xdp_hook_set) + ((_num) * \
+	sizeof(struct xdp_hook)))
+
+extern struct xdp_hook xdp_bpf_hook;
+
+extern struct static_key_false xdp_napi_hooks_needed;
+extern struct static_key_false xdp_dev_hooks_needed;
+
+/* Check if XDP hooks are set for a napi or its device */
+static inline bool xdp_hook_run_needed_check(struct net_device *dev,
+					     struct napi_struct *napi)
+{
+	return ((static_branch_unlikely(&xdp_dev_hooks_needed) &&
+		dev->xdp_hooks) ||
+		(static_branch_unlikely(&xdp_napi_hooks_needed) &&
+		 napi->xdp_hooks));
+}
+
+static inline int __xdp_run_one_hook(struct xdp_hook *hook,
+				     struct xdp_buff *xdp)
+{
+	void *priv = rcu_dereference(hook->priv);
+
+	if (hook->is_bpf) {
+		/* Run BPF programs directly do avoid one layer of
+		 * indirection.
+		 */
+		return BPF_PROG_RUN((struct bpf_prog *)priv, (void *)xdp);
+	} else {
+		return hook->hookfn(priv, xdp);
+	}
+}
+
+/* Core function to run the XDP hooks. This must be as fast as possible */
+static inline int __xdp_hook_run(struct xdp_hook_set *hook_set,
+				 struct xdp_buff *xdp,
+				 struct xdp_hook **last_hook)
+{
+	struct xdp_hook *hook;
+	int i, ret;
+
+	if (unlikely(!hook_set))
+		return XDP_PASS;
+
+	hook = &hook_set->hooks[0];
+	ret = __xdp_run_one_hook(hook, xdp);
+	*last_hook = hook;
+
+	for (i = 1; i < hook_set->num; i++) {
+		if (ret != XDP_PASS)
+			break;
+		hook = &hook_set->hooks[i];
+		ret = __xdp_run_one_hook(hook, xdp);
+	}
+
+	return ret;
+}
+
+/* Run the XDP hooks for a napi device and return a reference to the last
+ * hook processed. Called from a driver's receive routine. RCU
+ * read lock must be held.
+ */
+static inline int xdp_hook_run_ret_last(struct napi_struct *napi,
+					struct xdp_buff *xdp,
+					struct xdp_hook **last_hook)
+{
+	struct net_device *dev = napi->dev;
+	struct xdp_hook_set *hook_set;
+	int ret = XDP_PASS;
+
+	if (static_branch_unlikely(&xdp_napi_hooks_needed)) {
+		/* Run hooks in napi first */
+		hook_set = rcu_dereference(napi->xdp_hooks);
+		ret = __xdp_hook_run(hook_set, xdp, last_hook);
+
+		/* Check for dev hooks now taking into account that
+		 * we need to check for XDP_PASS having been
+		 * returned only if they are need (this is why
+		 * we don't do a fall through).
+		 */
+		if (static_branch_unlikely(&xdp_dev_hooks_needed)) {
+			if (ret != XDP_PASS)
+				return ret;
+			hook_set = rcu_dereference(dev->xdp_hooks);
+			ret = __xdp_hook_run(hook_set, xdp, last_hook);
+		}
+	} else if (static_branch_unlikely(&xdp_dev_hooks_needed)) {
+		/* Now run device hooks */
+		hook_set = rcu_dereference(dev->xdp_hooks);
+		ret = __xdp_hook_run(hook_set, xdp, last_hook);
+	}
+
+	return ret;
+}
+
+/* Run the XDP hooks for a napi device. Called from a driver's receive
+ * routine. RCU read lock must be held.
+ */
+static inline int xdp_hook_run(struct napi_struct *napi,
+			       struct xdp_buff *xdp)
+{
+	struct xdp_hook *last_hook;
+
+	return xdp_hook_run_ret_last(napi, xdp, &last_hook);
+}
+
+/* Register an XDP hook
+ *    dev: Assoicated net_device
+ *    hook_set: Hook set
+ *    def: Definition of the hook. The values are copied from this to a
+ *	   malloc'ed structure. The base_def pointer is saved as a
+ *	   reference to the hook to manage it
+ *    change: Change hook if it exists
+ *    dev_hook: Is a hook on a net_device (as oppsed to a napi instance)
+ */
+int __xdp_register_hook(struct net_device *dev,
+			struct xdp_hook_set __rcu **hook_set,
+			const struct xdp_hook *base_def,
+			bool change, bool dev_hook);
+
+/* Register an XDP hook on a device */
+static inline int xdp_register_dev_hook(struct net_device *dev,
+					const struct xdp_hook *def)
+{
+	return __xdp_register_hook(dev, &dev->xdp_hooks, def, false, true);
+}
+
+/* Register an XDP hook on a napi instance */
+static inline int xdp_register_napi_hook(struct napi_struct *napi,
+					 const struct xdp_hook *def)
+{
+	return __xdp_register_hook(napi->dev, &napi->xdp_hooks, def, false,
+				   false);
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
+				      const struct xdp_hook *reg)
+{
+	return __xdp_register_hook(dev, &dev->xdp_hooks, reg, true, true);
+}
+
+/* Change a napi XDP hook */
+static inline int xdp_change_napi_hook(struct napi_struct *napi,
+				       const struct xdp_hook *reg)
+{
+	return __xdp_register_hook(napi->dev, &napi->xdp_hooks, reg, true,
+				   false);
+}
+
+int __xdp_unregister_hook(struct net_device *dev,
+			  struct xdp_hook_set __rcu **hook_set,
+			  const struct xdp_hook *template, bool dev_hook);
+
+/* Unregister device XDP hook */
+static inline int xdp_unregister_dev_hook(struct net_device *dev,
+					   const struct xdp_hook *template)
+{
+	return __xdp_unregister_hook(dev, &dev->xdp_hooks, template, true);
+}
+
+/* Unregister a napi XDP hook */
+static inline int xdp_unregister_napi_hook(struct napi_struct *napi,
+					    const struct xdp_hook *template)
+{
+	return __xdp_unregister_hook(napi->dev, &napi->xdp_hooks, template,
+				     false);
+}
+
+/* Unregister all XDP hooks associated with a device (both the device hooks
+ * and hooks on all napi instances). This function is called when the netdev
+ * is being freed.
+ */
+void xdp_unregister_all_hooks(struct net_device *dev);
+
+/* Unregister all XDP hooks for a given xdp_hook_ops in a net. This walks
+ * all devices in net and napis for each device to unregister matching hooks.
+ * This can be called when a module that had registered some number of hooks
+ * is being unloaded.
+ */
+void xdp_unregister_net_hooks(struct net *net, struct xdp_hook *template);
+
+/* Find a registered device hook.
+ *   - If hook is found *ret is set to the values in the registered hook and
+ *     true is returned.
+ *   - Else false is returned.
+ */
+bool __xdp_find_hook(struct xdp_hook_set **hook_set,
+		     const struct xdp_hook *template,
+		     struct xdp_hook *ret);
+
+/* Find a device XDP hook. */
+static inline bool xdp_find_dev_hook(struct net_device *dev,
+				     const struct xdp_hook *template,
+				     struct xdp_hook *ret)
+{
+	return __xdp_find_hook(&dev->xdp_hooks, template, ret);
+}
+
+/* Find a napi XDP hook. */
+static inline bool xdp_find_napi_hook(struct napi_struct *napi,
+				      const struct xdp_hook *template,
+				      struct xdp_hook *ret)
+{
+	return __xdp_find_hook(&napi->xdp_hooks, template, ret);
+}
+
+int xdp_bpf_check_prog(struct net_device *dev, struct bpf_prog *prog);
+
+static inline void xdp_warn_invalid_action(u32 act)
+{
+	WARN_ONCE(1, "Illegal XDP return value %u, expect packet loss\n", act);
+}
+
+#endif /* __NET_XDP_H_ */
diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index 1b61357..3a40c6e 100644
--- a/include/trace/events/xdp.h
+++ b/include/trace/events/xdp.h
@@ -7,6 +7,7 @@
 #include <linux/netdevice.h>
 #include <linux/filter.h>
 #include <linux/tracepoint.h>
+#include <net/xdp.h>
 
 #define __XDP_ACT_MAP(FN)	\
 	FN(ABORTED)		\
@@ -48,6 +49,36 @@ TRACE_EVENT(xdp_exception,
 		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB))
 );
 
+/* Temporaray trace function. This will be renamed to xdp_exception after all
+ * the calling drivers have been patched.
+ */
+TRACE_EVENT(xdp_hook_exception,
+
+	TP_PROTO(const struct net_device *dev,
+		 const struct xdp_hook *hook, u32 act),
+
+	TP_ARGS(dev, hook, act),
+
+	TP_STRUCT__entry(
+		__string(name, dev->name)
+		__array(u8, prog_tag, 8)
+		__field(u32, act)
+	),
+
+	TP_fast_assign(
+		BUILD_BUG_ON(sizeof(__entry->prog_tag) !=
+						sizeof(hook->tag));
+		memcpy(__entry->prog_tag, hook->tag, sizeof(hook->tag));
+			__assign_str(name, dev->name);
+			__entry->act = act;
+		),
+
+	TP_printk("prog=%s device=%s action=%s",
+		  __print_hex_str(__entry->prog_tag, 8),
+		  __get_str(name),
+		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB))
+);
+
 #endif /* _TRACE_XDP_H */
 
 #include <trace/define_trace.h>
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index fddd76b..b80a589 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1179,6 +1179,7 @@ int __weak skb_copy_bits(const struct sk_buff *skb, int offset, void *to,
 #include <linux/bpf_trace.h>
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(xdp_exception);
+EXPORT_TRACEPOINT_SYMBOL_GPL(xdp_hook_exception);
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(bpf_prog_get_type);
 EXPORT_TRACEPOINT_SYMBOL_GPL(bpf_prog_put_rcu);
diff --git a/net/core/Makefile b/net/core/Makefile
index f6761b6..64d98d4 100644
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
index 0921609..35549dd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -140,6 +140,8 @@
 #include <linux/hrtimer.h>
 #include <linux/netfilter_ingress.h>
 #include <linux/crash_dump.h>
+#include <linux/filter.h>
+#include <net/xdp.h>
 
 #include "net-sysfs.h"
 
@@ -6598,6 +6600,27 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 }
 EXPORT_SYMBOL(dev_change_proto_down);
 
+/* Run a BPF/XDP program. RCU read lock must be held */
+static u32 dev_bpf_prog_run_xdp(const void *priv,
+				struct xdp_buff *xdp)
+{
+	const struct bpf_prog *prog = (const struct bpf_prog *)priv;
+
+	return BPF_PROG_RUN(prog, (void *)xdp);
+}
+
+static void dev_bpf_prog_put_xdp(const void *priv)
+{
+	bpf_prog_put((struct bpf_prog *)priv);
+}
+
+struct xdp_hook xdp_bpf_hook = {
+	.hookfn = dev_bpf_prog_run_xdp,
+	.put_priv = dev_bpf_prog_put_xdp,
+	.priority = 0,
+	.is_bpf = true
+};
+
 /**
  *	dev_change_xdp_fd - set or clear a bpf program for a device rx path
  *	@dev: device
@@ -6610,7 +6633,6 @@ int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	struct bpf_prog *prog = NULL;
-	struct netdev_xdp xdp;
 	int err;
 
 	ASSERT_RTNL();
@@ -6618,29 +6640,25 @@ int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
 	if (!ops->ndo_xdp)
 		return -EOPNOTSUPP;
 	if (fd >= 0) {
-		if (flags & XDP_FLAGS_UPDATE_IF_NOEXIST) {
-			memset(&xdp, 0, sizeof(xdp));
-			xdp.command = XDP_QUERY_PROG;
-
-			err = ops->ndo_xdp(dev, &xdp);
-			if (err < 0)
-				return err;
-			if (xdp.prog_attached)
-				return -EBUSY;
-		}
+		if ((flags & XDP_FLAGS_UPDATE_IF_NOEXIST) &&
+		    xdp_find_dev_hook(dev, &xdp_bpf_hook, NULL))
+			return -EBUSY;
 
 		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
 		if (IS_ERR(prog))
 			return PTR_ERR(prog);
 	}
 
-	memset(&xdp, 0, sizeof(xdp));
-	xdp.command = XDP_SETUP_PROG;
-	xdp.prog = prog;
+	if (prog) {
+		err = xdp_bpf_check_prog(dev, prog);
+		if (err >= 0)
+			err = xdp_register_dev_hook(dev, &xdp_bpf_hook);
 
-	err = ops->ndo_xdp(dev, &xdp);
-	if (err < 0 && prog)
-		bpf_prog_put(prog);
+		if (err < 0)
+			bpf_prog_put(prog);
+	} else {
+		err = xdp_unregister_dev_hook(dev, &xdp_bpf_hook);
+	}
 
 	return err;
 }
@@ -7679,6 +7697,7 @@ void free_netdev(struct net_device *dev)
 	struct napi_struct *p, *n;
 
 	might_sleep();
+	xdp_unregister_all_hooks(dev);
 	netif_free_tx_queues(dev);
 #ifdef CONFIG_SYSFS
 	kvfree(dev->_rx);
diff --git a/net/core/filter.c b/net/core/filter.c
index 0b753cb..8c01157 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -52,6 +52,7 @@
 #include <net/dst_metadata.h>
 #include <net/dst.h>
 #include <net/sock_reuseport.h>
+#include <net/xdp.h>
 
 /**
  *	sk_filter_trim_cap - run a packet through a socket filter
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index adfb54b..8a697c60 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -56,6 +56,7 @@
 #include <net/fib_rules.h>
 #include <net/rtnetlink.h>
 #include <net/net_namespace.h>
+#include <net/xdp.h>
 
 struct rtnl_link {
 	rtnl_doit_func		doit;
@@ -903,7 +904,7 @@ static size_t rtnl_xdp_size(const struct net_device *dev)
 	size_t xdp_size = nla_total_size(0) +	/* nest IFLA_XDP */
 			  nla_total_size(1);	/* XDP_ATTACHED */
 
-	if (!dev->netdev_ops->ndo_xdp)
+	if (!(dev->features & NETIF_F_XDP))
 		return 0;
 	else
 		return xdp_size;
@@ -1253,20 +1254,15 @@ static int rtnl_fill_link_ifmap(struct sk_buff *skb, struct net_device *dev)
 
 static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
 {
-	struct netdev_xdp xdp_op = {};
 	struct nlattr *xdp;
 	int err;
 
-	if (!dev->netdev_ops->ndo_xdp)
-		return 0;
 	xdp = nla_nest_start(skb, IFLA_XDP);
 	if (!xdp)
 		return -EMSGSIZE;
-	xdp_op.command = XDP_QUERY_PROG;
-	err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
-	if (err)
-		goto err_cancel;
-	err = nla_put_u8(skb, IFLA_XDP_ATTACHED, xdp_op.prog_attached);
+
+	err = nla_put_u8(skb, IFLA_XDP_ATTACHED,
+			 xdp_find_dev_hook(dev, &xdp_bpf_hook, NULL));
 	if (err)
 		goto err_cancel;
 
diff --git a/net/core/xdp.c b/net/core/xdp.c
new file mode 100644
index 0000000..efe8826
--- /dev/null
+++ b/net/core/xdp.c
@@ -0,0 +1,304 @@
+/*
+ * eXpress Data Path
+ *
+ * Copyright (c) 2017 Tom Herbert <tom@herbertland.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ */
+#include <net/xdp.h>
+
+DEFINE_STATIC_KEY_FALSE(xdp_dev_hooks_needed);
+EXPORT_SYMBOL(xdp_dev_hooks_needed);
+
+DEFINE_STATIC_KEY_FALSE(xdp_napi_hooks_needed);
+EXPORT_SYMBOL(xdp_napi_hooks_needed);
+
+static DEFINE_MUTEX(xdp_hook_mutex);
+
+int __xdp_register_hook(struct net_device *dev,
+			struct xdp_hook_set __rcu **xdp_hooks,
+			const struct xdp_hook *template,
+			bool change, bool dev_hook)
+{
+	struct xdp_hook_set *new_hooks = NULL, *old_hooks;
+	struct xdp_hook *hook;
+	int index, targindex = 0;
+	int i, err;
+
+	mutex_lock(&xdp_hook_mutex);
+
+	old_hooks = rcu_dereference(*xdp_hooks);
+
+	if (old_hooks) {
+		/* Walk over hooks, see if hook is already registered and
+		 * determine insertion point.
+		 */
+
+		for (index = 0; index < old_hooks->num; index++) {
+			hook = &old_hooks->hooks[index];
+			if (hook->template != template) {
+				if (template->priority < hook->priority)
+					targindex = index;
+				continue;
+			}
+
+			if (change) {
+				void *old_priv;
+
+				/* Only allow changing priv field in an existing
+				 * hook.
+				 */
+				old_priv = rcu_dereference_protected(hook->priv,
+					lockdep_is_held(&xdp_hook_mutex));
+				rcu_assign_pointer(hook->priv, template->priv);
+				if (old_priv && hook->put_priv)
+					hook->put_priv(old_priv);
+				goto out;
+			} else {
+				/* Already registered */
+				err = -EALREADY;
+				goto err;
+			}
+		}
+	}
+
+	/* Need to add new hook set. index holds number of entries in hooks
+	 * set (zero if hooks set is NULL). targindex holds index to insert
+	 * new hook.
+	 */
+	new_hooks = kzalloc(XDP_SET_SIZE(index + 1), GFP_KERNEL);
+	if (!new_hooks) {
+		err = -ENOMEM;
+		goto err;
+	}
+
+	/* Initialize XDP in driver */
+	if (!dev->xdp_hook_cnt && dev->netdev_ops->ndo_xdp) {
+		struct netdev_xdp xdp_op = {};
+
+		xdp_op.command = XDP_MODE_ON;
+		err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
+		if (err)
+			goto err;
+	}
+
+	if (old_hooks) {
+		for (i = 0; i < targindex; i++)
+			new_hooks->hooks[i] = old_hooks->hooks[i];
+
+		for (i++; i < index + 1; i++)
+			new_hooks->hooks[i] = old_hooks->hooks[i - 1];
+	}
+
+	new_hooks->hooks[targindex] = *template;
+	new_hooks->num = index + 1;
+	rcu_assign_pointer(*xdp_hooks, new_hooks);
+
+	if (old_hooks)
+		kfree_rcu(old_hooks, rcu);
+
+	if (dev_hook)
+		static_branch_inc(&xdp_dev_hooks_needed);
+	else
+		static_branch_inc(&xdp_napi_hooks_needed);
+
+	dev->xdp_hook_cnt++;
+
+out:
+	mutex_unlock(&xdp_hook_mutex);
+
+	return 0;
+
+err:
+	mutex_unlock(&xdp_hook_mutex);
+	kfree(new_hooks);
+	return err;
+}
+EXPORT_SYMBOL_GPL(__xdp_register_hook);
+
+int __xdp_unregister_hook(struct net_device *dev,
+			  struct xdp_hook_set __rcu **xdp_hooks,
+			  const struct xdp_hook *template,
+			  bool dev_hook)
+{
+	struct xdp_hook_set *old_hooks, *new_hooks = NULL;
+	struct xdp_hook *hook;
+	int i, index;
+	int err = 0;
+
+	old_hooks = rcu_dereference(*xdp_hooks);
+
+	mutex_lock(&xdp_hook_mutex);
+
+	for (index = 0; index < old_hooks->num; index++) {
+		hook = &old_hooks->hooks[index];
+		if (hook->template != template)
+			continue;
+
+		if (old_hooks->num > 1) {
+			new_hooks = kzalloc(XDP_SET_SIZE(
+				old_hooks->num  - 1), GFP_KERNEL);
+
+			if (!new_hooks) {
+				err = -ENOMEM;
+				goto out;
+			}
+			for (i = 0; i < index; i++)
+				new_hooks->hooks[i] = old_hooks->hooks[i];
+			for (i++; i < index; i++)
+				new_hooks->hooks[i - 1] = old_hooks->hooks[i];
+
+			new_hooks->num = old_hooks->num - 1;
+		}
+
+		break;
+	}
+
+	if (index >= old_hooks->num)
+		goto out;
+
+	rcu_assign_pointer(*xdp_hooks, new_hooks);
+
+	if (old_hooks)
+		kfree_rcu(old_hooks, rcu);
+
+	dev->xdp_hook_cnt--;
+
+	if (dev_hook)
+		static_branch_dec(&xdp_dev_hooks_needed);
+	else
+		static_branch_dec(&xdp_napi_hooks_needed);
+
+	if (hook->priv && hook->put_priv)
+		hook->put_priv(hook->priv);
+
+	if (!dev->xdp_hook_cnt && dev->netdev_ops->ndo_xdp) {
+		struct netdev_xdp xdp_op = {};
+
+		xdp_op.command = XDP_MODE_OFF;
+		dev->netdev_ops->ndo_xdp(dev, &xdp_op);
+	}
+
+out:
+	mutex_unlock(&xdp_hook_mutex);
+	synchronize_net();
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(__xdp_unregister_hook);
+
+static void __xdp_unregister_hooks(struct net_device *dev,
+				   struct xdp_hook_set __rcu **xdp_hooks,
+				   bool dev_hook)
+{
+	struct xdp_hook_set *old_hooks;
+	int i;
+
+	mutex_lock(&xdp_hook_mutex);
+
+	old_hooks = rcu_dereference(*xdp_hooks);
+
+	if (!old_hooks) {
+		mutex_unlock(&xdp_hook_mutex);
+		return;
+	}
+
+	for (i = 0; i < old_hooks->num; i++) {
+		if (dev_hook)
+			static_branch_dec(&xdp_dev_hooks_needed);
+		else
+			static_branch_dec(&xdp_napi_hooks_needed);
+		dev->xdp_hook_cnt--;
+	}
+
+	rcu_assign_pointer(*xdp_hooks, NULL);
+
+	if (!dev->xdp_hook_cnt && dev->netdev_ops->ndo_xdp) {
+		struct netdev_xdp xdp_op = {};
+
+		xdp_op.command = XDP_MODE_OFF;
+		dev->netdev_ops->ndo_xdp(dev, &xdp_op);
+	}
+
+	mutex_unlock(&xdp_hook_mutex);
+
+	kfree_rcu(old_hooks, rcu);
+}
+
+void xdp_unregister_all_hooks(struct net_device *dev)
+{
+	struct napi_struct *napi;
+
+	/* Unregister NAPI hooks for device */
+	list_for_each_entry(napi, &dev->napi_list, dev_list)
+		__xdp_unregister_hooks(dev, &napi->xdp_hooks, false);
+
+	/* Unregister device hooks */
+	__xdp_unregister_hooks(dev, &dev->xdp_hooks, true);
+}
+EXPORT_SYMBOL_GPL(xdp_unregister_all_hooks);
+
+void xdp_unregister_net_hooks(struct net *net, struct xdp_hook *template)
+{
+	struct net_device *dev;
+	struct napi_struct *napi;
+
+	list_for_each_entry_rcu(dev, &net->dev_base_head, dev_list) {
+		list_for_each_entry(napi, &dev->napi_list, dev_list)
+			xdp_unregister_napi_hook(napi, template);
+
+		xdp_unregister_dev_hook(dev, template);
+	}
+}
+EXPORT_SYMBOL_GPL(xdp_unregister_net_hooks);
+
+bool __xdp_find_hook(struct xdp_hook_set __rcu **xdp_hooks,
+		     const struct xdp_hook *template,
+		     struct xdp_hook *ret)
+{
+	struct xdp_hook_set *old_hooks;
+	struct xdp_hook *hook;
+	bool retval = false;
+	int index;
+
+	rcu_read_lock();
+
+	old_hooks = rcu_dereference(*xdp_hooks);
+
+	if (!old_hooks)
+		goto out;
+
+	for (index = 0; index < old_hooks->num; index++) {
+		hook = &old_hooks->hooks[index];
+		if (hook->template != template)
+			continue;
+
+		if (ret)
+			*ret = *hook;
+		retval = true;
+		goto out;
+	}
+
+out:
+	rcu_read_unlock();
+
+	return retval;
+}
+EXPORT_SYMBOL_GPL(__xdp_find_hook);
+
+int xdp_bpf_check_prog(struct net_device *dev, struct bpf_prog *prog)
+{
+	if (dev->netdev_ops->ndo_xdp) {
+		struct netdev_xdp xdp_op = {};
+
+		xdp_op.command = XDP_CHECK_BPF_PROG;
+		xdp_op.prog = prog;
+
+		return dev->netdev_ops->ndo_xdp(dev, &xdp_op);
+	} else {
+		return -EOPNOTSUPP;
+	}
+}
+EXPORT_SYMBOL_GPL(xdp_bpf_check_prog);
-- 
2.9.3
