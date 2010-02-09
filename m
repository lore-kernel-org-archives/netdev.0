From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 2/4] C/R: Basic support for network namespaces and devices (v3)
Date: Tue,  9 Feb 2010 13:25:11 -0800
Message-ID: <1265750713-15749-3-git-send-email-danms@us.ibm.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
Cc: netdev@vger.kernel.org
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stein.danplanet.com ([71.245.107.83]:45116 "EHLO
	stein.danplanet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504Ab0BIV1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 16:27:04 -0500
In-Reply-To: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
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

Changes in v3:
 - Use dev->checkpoint() for per-device checkpoint operation
 - Use RTNL for veth pair creation on restart
 - Export some of the functions that will be needed by dev->ndo_checkpoint()

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
 checkpoint/checkpoint.c          |   21 ++++++++++++----
 checkpoint/objhash.c             |   48 +++++++++++++++++++++++++++++++++++++
 checkpoint/restart.c             |    4 +++
 include/linux/checkpoint.h       |   21 ++++++++++++++++
 include/linux/checkpoint_hdr.h   |   49 ++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint_types.h |    1 +
 kernel/nsproxy.c                 |   45 +++++++++++++++++++++++++++++++++-
 net/Kconfig                      |    4 +++
 net/Makefile                     |    1 +
 9 files changed, 187 insertions(+), 7 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index b4e0021..0b3da7c 100644
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
index 52827a4..17b6093 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -348,6 +348,36 @@ static void lsm_string_drop(void *ptr, int lastref)
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
@@ -550,6 +580,24 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
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
index fcd07fa..9375e62 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -690,6 +690,10 @@ static int restore_container(struct ckpt_ctx *ctx)
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
index 7101d6f..f6e144f 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -35,6 +35,7 @@
 #include <linux/checkpoint_types.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/err.h>
+#include <linux/inetdevice.h>
 #include <net/sock.h>
 
 /* sycall helpers */
@@ -119,6 +120,26 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
 extern struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx, struct sock *sk);
 extern void sock_listening_list_free(struct list_head *head);
 
+#ifdef CONFIG_CHECKPOINT_NETNS
+int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr);
+void *restore_netns(struct ckpt_ctx *ctx);
+int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr);
+void *restore_netdev(struct ckpt_ctx *ctx);
+
+int ckpt_netdev_in_init_netns(struct ckpt_ctx *ctx, struct net_device *dev);
+int ckpt_netdev_inet_addrs(struct in_device *indev,
+			   struct ckpt_netdev_addr *list[]);
+int ckpt_netdev_hwaddr(struct net_device *dev, struct ckpt_hdr_netdev *h);
+struct ckpt_hdr_netdev *ckpt_netdev_base(struct ckpt_ctx *ctx,
+					 struct net_device *dev,
+					 struct ckpt_netdev_addr *addrs[]);
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
index e591fd1..d78bd6f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -181,6 +181,12 @@ enum {
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
@@ -253,6 +259,10 @@ enum obj_type {
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
@@ -313,6 +323,7 @@ struct ckpt_hdr_tail {
 /* container configuration section header */
 struct ckpt_hdr_container {
 	struct ckpt_hdr h;
+	__s32 init_netns_ref;
 	/*
 	 * the header is followed by the string:
 	 *   char lsm_name[SECURITY_NAME_MAX + 1]
@@ -434,6 +445,7 @@ struct ckpt_hdr_ns {
 	struct ckpt_hdr h;
 	__s32 uts_objref;
 	__s32 ipc_objref;
+	__s32 net_objref;
 } __attribute__((aligned(8)));
 
 /* cannot include <linux/tty.h> from userspace, so define: */
@@ -758,6 +770,43 @@ struct ckpt_hdr_file_socket {
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
index 51efd5a..e646ec6 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -86,6 +86,7 @@ struct ckpt_ctx {
 	wait_queue_head_t ghostq;	/* waitqueue for ghost tasks */
 	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
 	struct list_head listen_sockets;/* listening parent sockets */
+	int init_netns_ref;             /* Objref of root net namespace */
 
 	struct ckpt_stats stats;	/* statistics */
 
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index b0e71f2..78f5615 100644
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
@@ -288,6 +293,12 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 	if (ret < 0)
 		goto out;
 	h->ipc_objref = ret;
+#ifdef CONFIG_CHECKPOINT_NETNS
+	ret = checkpoint_obj(ctx, nsproxy->net_ns, CKPT_OBJ_NET_NS);
+	if (ret < 0)
+		goto out;
+	h->net_objref = ret;
+#endif
 
 	/* FIXME: for now, only marked visited to pacify leaks */
 	ret = ckpt_obj_visit(ctx, nsproxy->mnt_ns, CKPT_OBJ_MNT_NS);
@@ -306,6 +317,34 @@ int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr)
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
@@ -349,8 +388,6 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
 	nsproxy->pid_ns = current->nsproxy->pid_ns;
 	get_mnt_ns(current->nsproxy->mnt_ns);
 	nsproxy->mnt_ns = current->nsproxy->mnt_ns;
-	get_net(current->nsproxy->net_ns);
-	nsproxy->net_ns = current->nsproxy->net_ns;
 #else
 	nsproxy = current->nsproxy;
 	get_nsproxy(nsproxy);
@@ -359,6 +396,10 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
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
-- 
1.6.2.5

