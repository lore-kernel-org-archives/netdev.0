From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 3/3] C/R: Basic support for network namespaces and devices (v2)
Date: Fri, 22 Jan 2010 13:09:52 -0800
Message-ID: <1264194592-7529-4-git-send-email-danms@us.ibm.com>
References: <1264194592-7529-1-git-send-email-danms@us.ibm.com>
Cc: netdev@vger.kernel.org, orenl@librato.com
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stein.danplanet.com ([71.245.107.83]:35731 "EHLO
	stein.danplanet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754479Ab0AVVLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 16:11:14 -0500
In-Reply-To: <1264194592-7529-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When checkpointing a task tree with network namespaces, we hook into
do_checkpoint_ns() along with the others.  Any devices in a given namespace
are checkpointed (including their peer, in the case of veth) sequentially.
Each network device stores a list of protocol addresses, as well as other
information, such as hardware address.

This patch supports veth pairs, as well as the loopback adapter.  The
loopback support is there to make sure that any additional addresses and
state (such as up/down) is copied to the loopback adapter that we are
given in the new network namespace.

On restart, we instantiate new network namespaces and veth pairs as
necessary.  Any device we encounter that isn't in a network namespace
that was checkpointed as part of a task is left in the namespace of the
restarting process.  This will be the case for a veth half that exists
in the init netns to provide network access to a container.

Still to do are:

  1. Routes
  2. Netfilter rules
  3. IPv6 addresses
  4. Other virtual device types (e.g. bridges)
  5. Multicast
  6. Device config info (ipv4_devconf)
  7. Additional ipv4 address attributes

Changes in v2:
 - Add CONFIG_CHECKPOINT_NETNS that is dependent on NET, NET_NS, and
   CHECKPOINT.  Conditionally compile the checkpoint_dev code based on it.
 - Updated comment on should_checkpoint_netdev()
 - Updated checkpoint_netdev() to explicitly check for "veth" in name
 - Changed checkpoint_netns() to use BUG() for impossible condition
 - Fixed a bug on restart with all devices in the init netns
 - Lock the dev_base_lock while traversing interface addresses
 - Collect all addresses for an interface before writing out in one
   single pass

Signed-off-by: Dan Smith <danms@us.ibm.com>
Cc: netdev@vger.kernel.org
---
 checkpoint/checkpoint.c          |   21 ++-
 checkpoint/objhash.c             |   48 ++++
 checkpoint/restart.c             |    4 +
 include/linux/checkpoint.h       |   12 +
 include/linux/checkpoint_hdr.h   |   49 ++++
 include/linux/checkpoint_types.h |    1 +
 kernel/nsproxy.c                 |   45 +++-
 net/Kconfig                      |    4 +
 net/Makefile                     |    1 +
 net/checkpoint_dev.c             |  533 ++++++++++++++++++++++++++++++++++++++
 10 files changed, 711 insertions(+), 7 deletions(-)
 create mode 100644 net/checkpoint_dev.c

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index c345773..eb3aba5 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -180,16 +180,23 @@ static int checkpoint_write_header(struct ckpt_ctx *ctx)
 static int checkpoint_container(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_container *h;
+	int new;
 	int ret;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CONTAINER);
 	if (!h)
 		return -ENOMEM;
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
 
+	ret = ckpt_obj_lookup_add(ctx, current->nsproxy->net_ns,
+				  CKPT_OBJ_NET_NS, &new);
 	if (ret < 0)
-		return ret;
+		goto out;
+
+	ctx->init_netns_ref = h->init_netns_ref = ret;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
 
 	memset(ctx->lsm_name, 0, CHECKPOINT_LSM_NAME_MAX + 1);
 	strlcpy(ctx->lsm_name, security_get_lsm_name(),
@@ -197,9 +204,13 @@ static int checkpoint_container(struct ckpt_ctx *ctx)
 	ret = ckpt_write_buffer(ctx, ctx->lsm_name,
 				CHECKPOINT_LSM_NAME_MAX + 1);
 	if (ret < 0)
-		return ret;
+		goto out;
 
-	return security_checkpoint_header(ctx);
+	ret = security_checkpoint_header(ctx);
+ out:
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
 }
 
 /* write the checkpoint trailer */
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 782661d..1c8be0f 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -307,6 +307,36 @@ static void lsm_string_drop(void *ptr, int lastref)
 	kref_put(&s->kref, lsm_string_free);
 }
 
+static int netns_grab(void *ptr)
+{
+	struct net *net = ptr;
+
+	get_net(net);
+	return 0;
+}
+
+static void netns_drop(void *ptr, int lastref)
+{
+	struct net *net = ptr;
+
+	put_net(net);
+}
+
+static int netdev_grab(void *ptr)
+{
+	struct net_device *dev = ptr;
+
+	dev_hold(dev);
+	return 0;
+}
+
+static void netdev_drop(void *ptr, int lastref)
+{
+	struct net_device *dev = ptr;
+
+	dev_put(dev);
+}
+
 /* security context strings */
 static int checkpoint_lsm_string(struct ckpt_ctx *ctx, void *ptr);
 static struct ckpt_lsm_string *restore_lsm_string(struct ckpt_ctx *ctx);
@@ -491,6 +521,24 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_lsm_string,
 		.restore = restore_lsm_string_wrap,
 	},
+	/* Network Namespace Object */
+	{
+		.obj_name = "NET_NS",
+		.obj_type = CKPT_OBJ_NET_NS,
+		.ref_grab = netns_grab,
+		.ref_drop = netns_drop,
+		.checkpoint = checkpoint_netns,
+		.restore = restore_netns,
+	},
+	/* Network Device Object */
+	{
+		.obj_name = "NET_DEV",
+		.obj_type = CKPT_OBJ_NETDEV,
+		.ref_grab = netdev_grab,
+		.ref_drop = netdev_drop,
+		.checkpoint = checkpoint_netdev,
+		.restore = restore_netdev,
+	},
 };
 
 
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 88d791b..98356fc 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -689,6 +689,10 @@ static int restore_container(struct ckpt_ctx *ctx)
 		return PTR_ERR(h);
 	ckpt_hdr_put(ctx, h);
 
+	/* Store the ref of the init netns so we know to leave its
+	 * devices where they fall */
+	ctx->init_netns_ref = h->init_netns_ref;
+
 	/* read the LSM name and info which follow ("are a part of")
 	 * the ckpt_hdr_container */
 	ret = restore_lsm(ctx);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 1f85162..959fbf4 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -113,6 +113,18 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
 extern struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx, struct sock *sk);
 extern void sock_listening_list_free(struct list_head *head);
 
+#ifdef CONFIG_CHECKPOINT_NETNS
+int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr);
+void *restore_netns(struct ckpt_ctx *ctx);
+int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr);
+void *restore_netdev(struct ckpt_ctx *ctx);
+#else
+# define checkpoint_netns NULL
+# define restore_netns NULL
+# define checkpoint_netdev NULL
+# define restore_netdev NULL
+#endif
+
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
 	set_bit(__kflag##_BIT, &(__ctx)->kflags)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4e57d37..5a6ac25 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -176,6 +176,12 @@ enum {
 #define CKPT_HDR_SOCKET_UNIX CKPT_HDR_SOCKET_UNIX
 	CKPT_HDR_SOCKET_INET,
 #define CKPT_HDR_SOCKET_INET CKPT_HDR_SOCKET_INET
+	CKPT_HDR_NET_NS,
+#define CKPT_HDR_NET_NS CKPT_HDR_NET_NS
+	CKPT_HDR_NETDEV,
+#define CKPT_HDR_NETDEV CKPT_HDR_NETDEV
+	CKPT_HDR_NETDEV_ADDR,
+#define CKPT_HDR_NETDEV_ADDR CKPT_HDR_NETDEV_ADDR
 
 	CKPT_HDR_TAIL = 9001,
 #define CKPT_HDR_TAIL CKPT_HDR_TAIL
@@ -242,6 +248,10 @@ enum obj_type {
 #define CKPT_OBJ_SECURITY_PTR CKPT_OBJ_SECURITY_PTR
 	CKPT_OBJ_SECURITY,
 #define CKPT_OBJ_SECURITY CKPT_OBJ_SECURITY
+	CKPT_OBJ_NET_NS,
+#define CKPT_OBJ_NET_NS CKPT_OBJ_NET_NS
+	CKPT_OBJ_NETDEV,
+#define CKPT_OBJ_NETDEV CKPT_OBJ_NETDEV
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
@@ -302,6 +312,7 @@ struct ckpt_hdr_tail {
 /* container configuration section header */
 struct ckpt_hdr_container {
 	struct ckpt_hdr h;
+	__s32 init_netns_ref;
 	/*
 	 * the header is followed by the string:
 	 *   char lsm_name[SECURITY_NAME_MAX + 1]
@@ -423,6 +434,7 @@ struct ckpt_hdr_ns {
 	struct ckpt_hdr h;
 	__s32 uts_objref;
 	__u32 ipc_objref;
+	__s32 net_objref;
 } __attribute__((aligned(8)));
 
 /* cannot include <linux/tty.h> from userspace, so define: */
@@ -740,6 +752,43 @@ struct ckpt_hdr_file_socket {
 	__s32 sock_objref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_netns {
+	struct ckpt_hdr h;
+	__s32 this_ref;
+} __attribute__((aligned(8)));
+
+enum ckpt_netdev_types {
+	CKPT_NETDEV_LO,
+	CKPT_NETDEV_VETH,
+};
+
+struct ckpt_hdr_netdev {
+	struct ckpt_hdr h;
+ 	__s32 netns_ref;
+	__s32 this_ref;     /* veth only */
+	__s32 peer_ref;     /* veth only */
+	__u32 inet_addrs;
+	__u16 type;
+	__u16 flags;
+	__u8 hwaddr[6];
+} __attribute__((aligned(8)));
+
+enum ckpt_netdev_addr_types {
+	CKPT_NETDEV_ADDR_IPV4,
+};
+
+struct ckpt_netdev_addr {
+	__u16 type;
+	union {
+		struct {
+			__u32 inet4_local;
+			__u32 inet4_address;
+			__u32 inet4_mask;
+			__u32 inet4_broadcast;
+		};
+	};
+} __attribute__((aligned(8)));
+
 struct ckpt_hdr_eventpoll_items {
 	struct ckpt_hdr h;
 	__s32  epfile_objref;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index f95c3ff..9d2a4ca 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -85,6 +85,7 @@ struct ckpt_ctx {
 	wait_queue_head_t ghostq;	/* waitqueue for ghost tasks */
 	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
 	struct list_head listen_sockets;/* listening parent sockets */
+	int init_netns_ref;             /* Objref of root net namespace */
 
 	struct ckpt_stats stats;	/* statistics */
 
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index e7aaa00..d3e4d5b 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -248,6 +248,11 @@ int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	ret = ckpt_obj_collect(ctx, nsproxy->uts_ns, CKPT_OBJ_UTS_NS);
 	if (ret < 0)
 		goto out;
+#ifdef CONFIG_CHECKPOINT_NETNS
+	ret = ckpt_obj_collect(ctx, nsproxy->net_ns, CKPT_OBJ_NET_NS);
+	if (ret < 0)
+		goto out;
+#endif
 	ret = ckpt_obj_collect(ctx, nsproxy->ipc_ns, CKPT_OBJ_IPC_NS);
 	if (ret < 0)
 		goto out;
@@ -281,6 +286,12 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 	if (ret < 0)
 		goto out;
 	h->ipc_objref = ret;
+#ifdef CONFIG_CHECKPOINT_NETNS
+	ret = checkpoint_obj(ctx, nsproxy->net_ns, CKPT_OBJ_NET_NS);
+	if (ret < 0)
+		goto out;
+	h->net_objref = ret;
+#endif
 
 	/* TODO: Write other namespaces here */
 
@@ -296,6 +307,34 @@ int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr)
 	return do_checkpoint_ns(ctx, (struct nsproxy *) ptr);
 }
 
+static int do_restore_netns(struct ckpt_ctx *ctx,
+			    struct ckpt_hdr_ns *h,
+			    struct nsproxy *nsproxy)
+{
+#ifdef CONFIG_CHECKPOINT_NETNS
+	struct net *net_ns;
+
+	if (h->net_objref < 0)
+		return -EINVAL;
+	else if (h->net_objref == 0)
+		return 0;
+
+	net_ns = ckpt_obj_fetch(ctx, h->net_objref, CKPT_OBJ_NET_NS);
+	if (IS_ERR(net_ns))
+		return PTR_ERR(net_ns);
+
+	get_net(net_ns);
+	nsproxy->net_ns = net_ns;
+#else
+	if (h->net_objref > 0)
+		return -EINVAL;
+	get_net(current->nsproxy->net_ns);
+	nsproxy->net_ns = current->nsproxy->net_ns;
+#endif
+
+	return 0;
+}
+
 static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_ns *h;
@@ -339,8 +378,6 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
 	nsproxy->pid_ns = current->nsproxy->pid_ns;
 	get_mnt_ns(current->nsproxy->mnt_ns);
 	nsproxy->mnt_ns = current->nsproxy->mnt_ns;
-	get_net(current->nsproxy->net_ns);
-	nsproxy->net_ns = current->nsproxy->net_ns;
 #else
 	nsproxy = current->nsproxy;
 	get_nsproxy(nsproxy);
@@ -349,6 +386,10 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
 	BUG_ON(nsproxy->ipc_ns != ipc_ns);
 #endif
 
+	ret = do_restore_netns(ctx, h, nsproxy);
+	if (ret < 0)
+		goto out;
+
 	/* TODO: add more namespaces here */
 	ret = 0;
  out:
diff --git a/net/Kconfig b/net/Kconfig
index 041c35e..64dd3cd 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -276,4 +276,8 @@ source "net/wimax/Kconfig"
 source "net/rfkill/Kconfig"
 source "net/9p/Kconfig"
 
+config CHECKPOINT_NETNS
+       bool
+       default y if NET && NET_NS && CHECKPOINT
+
 endif   # if NET
diff --git a/net/Makefile b/net/Makefile
index 74b038f..570ee98 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -67,3 +67,4 @@ endif
 obj-$(CONFIG_WIMAX)		+= wimax/
 
 obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
+obj-$(CONFIG_CHECKPOINT_NETNS)	+= checkpoint_dev.o
diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
new file mode 100644
index 0000000..492a4c0
--- /dev/null
+++ b/net/checkpoint_dev.c
@@ -0,0 +1,533 @@
+/*
+ *  Copyright 2010 IBM Corporation
+ *
+ *  Author(s): Dan Smith <danms@us.ibm.com>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ */
+
+#include <linux/sched.h>
+#include <linux/if.h>
+#include <linux/if_arp.h>
+#include <linux/inetdevice.h>
+#include <linux/veth.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+#include <net/net_namespace.h>
+#include <net/sch_generic.h>
+
+static int __kern_devinet_ioctl(struct net *net, unsigned int cmd, void *arg)
+{
+	mm_segment_t fs;
+	int ret;
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = devinet_ioctl(net, cmd, arg);
+	set_fs(fs);
+
+	return ret;
+}
+
+static int __kern_dev_ioctl(struct net *net, unsigned int cmd, void *arg)
+{
+	mm_segment_t fs;
+	int ret;
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = dev_ioctl(net, cmd, arg);
+	set_fs(fs);
+
+	return ret;
+}
+
+/*
+ * Determine if an interface should be checkpointed, skipped, or if it
+ * makes us uncheckpointable.  This should probably be a list (either
+ * static, or supplied by the checkpointer) of interfaces to skip,
+ * fail, etc.  For now, skipping sit0 and failing on all but veth and
+ * lo is sufficient for most sitations.
+ *
+ * Return 1 for yes, 0 for skip, -ERRNO for error
+ */
+static int should_checkpoint_netdev(struct net_device *dev)
+{
+	struct ethtool_drvinfo drvinfo;
+
+	if (strcmp(dev->name, "sit0") == 0) {
+		return 0;                                    /* Skip sit0 */
+	} else if (dev->ethtool_ops && dev->ethtool_ops->get_drvinfo) {
+		dev->ethtool_ops->get_drvinfo(dev, &drvinfo);
+		if (strcmp(drvinfo.driver, "veth") == 0)
+			return 1;                            /* vethX is okay */
+	} else if (strcmp(dev->name, "lo") == 0)
+		return 1;                                    /* lo is okay */
+
+	return -EINVAL;
+}
+
+static int dev_in_init_netns(struct ckpt_ctx *ctx, struct net_device *dev)
+{
+	struct net *net = dev->nd_net;
+	int ref;
+
+	ref = ckpt_obj_lookup(ctx, net, CKPT_OBJ_NET_NS);
+	return ref == ctx->init_netns_ref;
+}
+
+static int checkpoint_addrs(struct in_device *indev,
+			    struct ckpt_netdev_addr *_abuf[])
+{
+	struct ckpt_netdev_addr *abuf = NULL;
+	struct in_ifaddr *addr = indev->ifa_list;
+	int pages = 0;
+	int addrs = 0;
+	int max;
+
+	read_lock(&dev_base_lock);
+ retry:
+	if (++pages > 4) {
+		addrs = -ENOMEM;
+		goto out;
+	}
+
+	*_abuf = krealloc(abuf, PAGE_SIZE * pages, GFP_KERNEL);
+	if (*_abuf == NULL) {
+		addrs = -ENOMEM;
+		goto out;
+	}
+	abuf = *_abuf;
+
+	max = (pages * PAGE_SIZE) / sizeof(*abuf);
+	while (addr) {
+		abuf[addrs].type = CKPT_NETDEV_ADDR_IPV4; /* Only IPv4 now */
+		abuf[addrs].inet4_local = addr->ifa_local;
+		abuf[addrs].inet4_address = addr->ifa_address;
+		abuf[addrs].inet4_mask = addr->ifa_mask;
+		abuf[addrs].inet4_broadcast = addr->ifa_broadcast;
+
+		addr = addr->ifa_next;
+		if (++addrs >= max)
+			goto retry;
+	}
+
+ out:
+	read_unlock(&dev_base_lock);
+
+	if (addrs < 0) {
+		kfree(abuf);
+		*_abuf = NULL;
+	}
+
+	return addrs;
+}
+
+static int add_veth_refs(struct ckpt_ctx *ctx, struct ckpt_hdr_netdev *h,
+			 struct net_device *dev, struct net_device *peer)
+{
+	int new;
+
+	h->this_ref = ckpt_obj_lookup_add(ctx, dev, CKPT_OBJ_NETDEV, &new);
+	if (h->this_ref < 0)
+		return h->this_ref;
+
+	h->peer_ref = ckpt_obj_lookup_add(ctx, peer, CKPT_OBJ_NETDEV, &new);
+	if (h->peer_ref < 0)
+		return h->peer_ref;
+
+	ckpt_debug("netdev %s has peer %i addrs %i\n",
+		   dev->name, h->peer_ref, h->inet_addrs);
+
+	return 0;
+}
+
+int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct ckpt_hdr_netdev *h;
+	struct net_device *dev = ptr;
+	struct net_device *peer = NULL;
+	struct net *net = dev->nd_net;
+	struct ifreq req;
+	struct ckpt_netdev_addr *addrs = NULL;
+	int ret = 0;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NETDEV);
+	if (!h)
+		return -ENOMEM;
+
+	if (strcmp(dev->name, "lo") == 0)
+		h->type = CKPT_NETDEV_LO;
+	else if (strncmp(dev->name, "veth", 4) == 0) {
+		h->type = CKPT_NETDEV_VETH;
+		peer = veth_get_peer(dev);
+	} else {
+		ret = -EINVAL;
+		ckpt_err(ctx, ret, "Unsupported type for %s\n", dev->name);
+		goto out;
+	}
+
+	memcpy(req.ifr_name, dev->name, IFNAMSIZ);
+	ret = __kern_dev_ioctl(net, SIOCGIFFLAGS, &req);
+	h->flags = req.ifr_flags;
+	if (ret < 0)
+		goto out;
+
+	ret = __kern_dev_ioctl(net, SIOCGIFHWADDR, &req);
+	if (ret < 0)
+		goto out;
+	memcpy(h->hwaddr, req.ifr_hwaddr.sa_data, sizeof(h->hwaddr));
+
+	h->netns_ref = ckpt_obj_lookup(ctx, net, CKPT_OBJ_NET_NS);
+	if (!h->netns_ref) {
+		ret = -EINVAL;
+		ckpt_err(ctx, ret, "Found netdev with no netns");
+		goto out;
+	}
+
+	if (h->type == CKPT_NETDEV_VETH) {
+		ret = add_veth_refs(ctx, h, dev, peer);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = h->inet_addrs = checkpoint_addrs(dev->ip_ptr, &addrs);
+	if (h->inet_addrs < 0) {
+		ckpt_err(ctx, ret, "Unable to write addresses\n");
+		goto out;
+	}
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	if (h->type == CKPT_NETDEV_VETH) {
+		ret = ckpt_write_buffer(ctx, dev->name, IFNAMSIZ);
+		if (ret < 0)
+			goto out;
+
+		ret = ckpt_write_buffer(ctx, peer->name, IFNAMSIZ);
+		if (ret < 0)
+			goto out;
+	}
+
+	if (h->inet_addrs > 0) {
+		int len = (sizeof(struct ckpt_netdev_addr) * h->inet_addrs);
+		ret = ckpt_write_buffer(ctx, addrs, len);
+		if (ret)
+			goto out;
+	}
+
+	if (peer && dev_in_init_netns(ctx, peer))
+		ret = checkpoint_obj(ctx, peer, CKPT_OBJ_NETDEV);
+ out:
+	ckpt_hdr_put(ctx, h);
+	kfree(addrs);
+
+	return ret;
+}
+
+int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct net *net = ptr;
+	struct net_device *dev;
+	struct ckpt_hdr_netns *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NET_NS);
+	if (!h)
+		return -ENOMEM;
+
+	h->this_ref = ckpt_obj_lookup(ctx, net, CKPT_OBJ_NET_NS);
+	BUG_ON(h->this_ref == 0);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	for_each_netdev(net, dev) {
+		ret = should_checkpoint_netdev(dev);
+		if (ret > 0)
+			ret = checkpoint_obj(ctx, dev, CKPT_OBJ_NETDEV);
+		if (ret < 0)
+			break;
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+static int restore_in_addrs(struct ckpt_ctx *ctx,
+			    __u32 naddrs,
+			    struct net *net,
+			    struct net_device *dev)
+{
+	__u32 i;
+	int ret = 0;
+	int len = naddrs * sizeof(struct ckpt_netdev_addr);
+	struct ckpt_netdev_addr *addrs = NULL;
+
+	addrs = kmalloc(len, GFP_KERNEL);
+	if (!addrs)
+		return -ENOMEM;
+
+	ret = _ckpt_read_buffer(ctx, addrs, len);
+	if (ret < 0)
+		goto out;
+
+	for (i = 0; i < naddrs; i++) {
+		struct ckpt_netdev_addr *addr = &addrs[i];
+		struct ifreq req;
+		struct sockaddr_in *inaddr;
+
+		if (addr->type != CKPT_NETDEV_ADDR_IPV4) {
+			ret = -EINVAL;
+			ckpt_err(ctx, ret, "Unsupported netdev addr type %i\n",
+				 addr->type);
+			break;
+		}
+
+		ckpt_debug("restoring %s: %x/%x/%x\n", dev->name,
+			   addr->inet4_address,
+			   addr->inet4_mask,
+			   addr->inet4_broadcast);
+
+		memcpy(req.ifr_name, dev->name, IFNAMSIZ);
+
+		inaddr = (struct sockaddr_in *)&req.ifr_addr;
+		inaddr->sin_addr.s_addr = addr->inet4_address;
+		inaddr->sin_family = AF_INET;
+		ret = __kern_devinet_ioctl(net, SIOCSIFADDR, &req);
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "Failed to set address\n");
+			break;
+		}
+
+		inaddr = (struct sockaddr_in *)&req.ifr_addr;
+		inaddr->sin_addr.s_addr = addr->inet4_mask;
+		inaddr->sin_family = AF_INET;
+		ret = __kern_devinet_ioctl(net, SIOCSIFNETMASK, &req);
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "Failed to set netmask\n");
+			break;
+		}
+
+		inaddr = (struct sockaddr_in *)&req.ifr_addr;
+		inaddr->sin_addr.s_addr = addr->inet4_broadcast;
+		inaddr->sin_family = AF_INET;
+		ret = __kern_devinet_ioctl(net, SIOCSIFBRDADDR, &req);
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "Failed to set broadcast\n");
+			break;
+		}
+	}
+
+ out:
+	kfree(addrs);
+
+	return ret;
+}
+
+static void cleanup_veth(struct net_device *dev)
+{
+	struct net_device *peer = veth_get_peer(dev);
+
+	unregister_netdev(peer);
+	free_netdev(peer);
+	unregister_netdev(dev);
+	free_netdev(dev);
+}
+
+static struct net_device *new_veth_pair(char *this_name, char *peer_name)
+{
+	int ret;
+	struct nlattr **tb;
+	struct net_device *this;
+	struct net_device *peer;
+	const struct rtnl_link_ops *ops = rtnl_link_ops_get("veth");
+
+	tb = kcalloc(IFLA_MAX+1, sizeof(struct nlattr *), GFP_KERNEL);
+	if (!tb)
+		return ERR_PTR(-ENOMEM);
+
+	this = rtnl_create_link(current->nsproxy->net_ns, this_name, ops, tb);
+	if (IS_ERR(this)) {
+		ret = PTR_ERR(this);
+		goto err1;
+	}
+
+	peer = rtnl_create_link(current->nsproxy->net_ns, peer_name, ops, tb);
+	if (IS_ERR(peer)) {
+		ret = PTR_ERR(peer);
+		goto err2;
+	}
+
+	ret = register_netdev(this);
+	if (ret < 0)
+		goto err3;
+
+	ret = register_netdev(peer);
+	if (ret < 0)
+		goto err4;
+
+	dev_hold(this);
+	dev_hold(peer);
+
+	veth_set_peer(this, peer);
+	veth_set_peer(peer, this);
+
+	netif_carrier_on(this);
+	netif_carrier_on(peer);
+
+	kfree(tb);
+
+	return this;
+ err4:
+	unregister_netdevice(this);
+ err3:
+	free_netdev(peer);
+ err2:
+	free_netdev(this);
+ err1:
+	kfree(tb);
+
+	return ERR_PTR(ret);
+}
+
+static struct net_device *restore_veth(struct ckpt_ctx *ctx,
+				       struct ckpt_hdr_netdev *h,
+				       struct net *net)
+{
+	int ret;
+	char this_name[IFNAMSIZ];
+	char peer_name[IFNAMSIZ];
+	struct net_device *dev;
+	struct net_device *peer;
+
+	ret = _ckpt_read_buffer(ctx, this_name, IFNAMSIZ);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
+	ret = _ckpt_read_buffer(ctx, peer_name, IFNAMSIZ);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
+	ckpt_debug("restored veth netdev %s:%s\n", this_name, peer_name);
+
+	peer = ckpt_obj_try_fetch(ctx, h->peer_ref, CKPT_OBJ_NETDEV);
+	if (IS_ERR(peer)) {       /* We're first: allocate the veth pair */
+		dev = new_veth_pair(this_name, peer_name);
+		if (IS_ERR(dev))
+			return dev;
+		peer = veth_get_peer(dev);
+	} else                    /* We're second: get our dev from our peer */
+		dev = veth_get_peer(peer);
+
+	/* Move to our new netns */
+	rtnl_lock();
+	ret = dev_change_net_namespace(dev, net, dev->name);
+	rtnl_unlock();
+	if (ret) {
+		cleanup_veth(dev);
+		dev = ERR_PTR(ret);
+	}
+
+	return dev;
+}
+
+void *restore_netdev(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_netdev *h;
+	struct net_device *dev = NULL;
+	struct ifreq req;
+	struct net *net;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_NETDEV);
+	if (IS_ERR(h)) {
+		ckpt_err(ctx, PTR_ERR(h), "failed to read netdev\n");
+		return h;
+	}
+
+	if (h->netns_ref != ctx->init_netns_ref) {
+		net = ckpt_obj_try_fetch(ctx, h->netns_ref, CKPT_OBJ_NET_NS);
+		if (IS_ERR(net)) {
+			net = current->nsproxy->net_ns;
+			ret = PTR_ERR(net);
+			goto out;
+		}
+	} else
+		net = current->nsproxy->net_ns;
+
+	if (h->type == CKPT_NETDEV_VETH)
+		dev = restore_veth(ctx, h, net);
+	else if (h->type == CKPT_NETDEV_LO)
+		dev = dev_get_by_name(net, "lo");
+	else
+		dev = ERR_PTR(-EINVAL);
+
+	if (IS_ERR(dev)) {
+		ret = PTR_ERR(dev);
+		ckpt_err(ctx, ret, "Netdev type %i not supported\n", h->type);
+		goto out;
+	}
+
+	memcpy(req.ifr_name, dev->name, IFNAMSIZ);
+
+	if (h->type != CKPT_NETDEV_LO) {
+		/* Restore MAC address */
+		memcpy(req.ifr_hwaddr.sa_data, h->hwaddr, sizeof(h->hwaddr));
+		req.ifr_hwaddr.sa_family = ARPHRD_ETHER;
+		ret = __kern_dev_ioctl(net, SIOCSIFHWADDR, &req);
+		if (ret < 0)
+			goto out;
+	}
+
+	/* Restore flags (which will likely bring the interface up) */
+	req.ifr_flags = h->flags;
+	ret = __kern_dev_ioctl(net, SIOCSIFFLAGS, &req);
+	if (ret < 0)
+		goto out;
+
+	if (h->inet_addrs > 0)
+		ret = restore_in_addrs(ctx, h->inet_addrs, net, dev);
+ out:
+	if (ret) {
+		ckpt_err(ctx, ret, "Failed to restore netdevice %s\n",
+			 dev->name);
+		if ((h->type == CKPT_NETDEV_VETH) && dev)
+			cleanup_veth(dev);
+		dev = ERR_PTR(ret);
+	}
+	ckpt_hdr_put(ctx, h);
+
+	return dev;
+}
+
+void *restore_netns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_netns *h;
+	struct net *net;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_NET_NS);
+	if (IS_ERR(h)) {
+		ckpt_err(ctx, PTR_ERR(h), "failed to read netns\n");
+		return h;
+	}
+
+	if (h->this_ref != ctx->init_netns_ref) {
+		net = copy_net_ns(CLONE_NEWNET, current->nsproxy->net_ns);
+		if (IS_ERR(net))
+			goto out;
+	} else
+		net = current->nsproxy->net_ns;
+ out:
+	ckpt_hdr_put(ctx, h);
+
+	return net;
+}
-- 
1.6.2.5

