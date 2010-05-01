From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [PATCH v21 094/100] c/r: Basic support for network namespaces and devices (v6)
Date: Sat,  1 May 2010 10:16:16 -0400
Message-ID: <1272723382-19470-95-git-send-email-orenl@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Dan Smith <danms@us.ibm.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tarap.cc.columbia.edu ([128.59.29.7]:64442 "EHLO
	tarap.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932942Ab0EAOi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 10:38:56 -0400
In-Reply-To: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>

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

Changelog[v21]:
  - Do not include checkpoint_hdr.h explicitly
 - Fix acquiring socket lock before reading RTNETLINK response
 - Skip down interfaces (v2)
 - Export net checkpoint fns
 - Add CHECKPOINT_NETNS flag
 - Rename CONFIG_CHECKPOINT_NETNS -> CONFIG_NETNS_CHECKPOINT
 - Netdev restore function dispatching from a table
 - Added a comment about the controverial determination of "initial netns"
 - Simplify the E2BIG error handling
 - Remove a redundant check for checkpoint support per-device

Changes in v6:
 - Store addresses in network byte order, per Dave's recommendation

Changes in v5:
 - Rebase
 - Remove checkpoint_container() noise
 - Factor out some common bits of the RTNL newlink operations
 - Add macvlan support

Changes in v4:
 - Fix allocation under lock in ckpt_netdev_inet_addrs()
 - Add comment for case where there is no netns info in checkpoint image
 - Fix inner structure alignment in netdev_addr header
 - Fix instances of kfree(skb)
 - Remove init_netns_ref from container header and checkpoint context
 - Add 'extern' to checkpoint.h prototypes
 - Swizzle do_restore_netns() to handle netns more like the others
 - Return E2BIG for failure case when collecting inet addrs
 - Report case where device doesn't support checkpoint
 - Remove nested netns check from may_checkpoint_task()
 - Move veth-specific netdev attributes into unioned struct to set an
   example for specific attributes of additional device types
 - Add 'sit' device restore path that doesn't really do anything
 - Fail instead of skip when encountering a device with no checkpoint
   support

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

Cc: netdev@vger.kernel.org
Signed-off-by: Dan Smith <danms@us.ibm.com>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
---
 Documentation/checkpoint/usage.txt |    1 +
 include/linux/checkpoint.h         |   29 ++-
 include/linux/checkpoint_hdr.h     |   58 +++
 kernel/checkpoint/checkpoint.c     |    5 -
 kernel/nsproxy.c                   |   24 +-
 net/Kconfig                        |    4 +
 net/Makefile                       |    1 +
 net/checkpoint.c                   |   63 +++-
 net/checkpoint_dev.c               |  818 ++++++++++++++++++++++++++++++++++++
 9 files changed, 995 insertions(+), 8 deletions(-)
 create mode 100644 net/checkpoint_dev.c

diff --git a/Documentation/checkpoint/usage.txt b/Documentation/checkpoint/usage.txt
index d697ed1..5700448 100644
--- a/Documentation/checkpoint/usage.txt
+++ b/Documentation/checkpoint/usage.txt
@@ -15,6 +15,7 @@ The API consists of three new system calls:
  an open file to which error and debug messages are written. @flags
  may be one or more of:
    - CHECKPOINT_SUBTREE : allow checkpoint of sub-container
+   - CHECKPOINT_NETNS : include network namespaces and devices
  (other value are not allowed).
 
  Returns: a positive checkpoint identifier (ckptid) upon success, 0 if
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 43d67ce..84bb7a9 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -14,6 +14,7 @@
 
 /* checkpoint user flags */
 #define CHECKPOINT_SUBTREE	0x1
+#define CHECKPOINT_NETNS	0x2
 
 /* restart user flags */
 #define RESTART_TASKSELF	0x1
@@ -35,6 +36,7 @@
 #include <linux/checkpoint_types.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/err.h>
+#include <linux/inetdevice.h>
 #include <net/sock.h>
 
 /* sycall helpers */
@@ -55,7 +57,10 @@ extern long do_sys_restart(pid_t pid, int fd,
 #define CKPT_CTX_ERROR		(1 << CKPT_CTX_ERROR_BIT)
 
 /* ckpt_ctx: uflags */
-#define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
+#define CHECKPOINT_USER_FLAGS \
+	(CHECKPOINT_SUBTREE | \
+	 CHECKPOINT_NETNS)
+
 #define RESTART_USER_FLAGS  \
 	(RESTART_TASKSELF | \
 	 RESTART_FROZEN | \
@@ -119,6 +124,28 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
 extern struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx, struct sock *sk);
 extern void sock_listening_list_free(struct list_head *head);
 
+#ifdef CONFIG_NETNS_CHECKPOINT
+extern int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_netns(struct ckpt_ctx *ctx);
+extern int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_netdev(struct ckpt_ctx *ctx);
+
+extern int ckpt_netdev_in_init_netns(struct ckpt_ctx *ctx,
+				     struct net_device *dev);
+extern int ckpt_netdev_inet_addrs(struct in_device *indev,
+				  struct ckpt_netdev_addr *list[]);
+extern int ckpt_netdev_hwaddr(struct net_device *dev,
+			      struct ckpt_hdr_netdev *h);
+extern struct ckpt_hdr_netdev *ckpt_netdev_base(struct ckpt_ctx *ctx,
+					struct net_device *dev,
+					struct ckpt_netdev_addr *addrs[]);
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
index 1564726..eb5e1b4 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -189,6 +189,12 @@ enum {
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
@@ -261,6 +267,10 @@ enum obj_type {
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
@@ -444,6 +454,7 @@ struct ckpt_hdr_ns {
 	struct ckpt_hdr h;
 	__s32 uts_objref;
 	__s32 ipc_objref;
+	__s32 net_objref;
 } __attribute__((aligned(8)));
 
 /* cannot include <linux/tty.h> from userspace, so define: */
@@ -768,6 +779,53 @@ struct ckpt_hdr_file_socket {
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
+	CKPT_NETDEV_SIT,
+	CKPT_NETDEV_MACVLAN,
+	CKPT_NETDEV_MAX,
+};
+
+struct ckpt_hdr_netdev {
+	struct ckpt_hdr h;
+	__s32 netns_ref;
+	union {
+		struct {
+			__s32 this_ref;
+			__s32 peer_ref;
+		} veth;
+		struct {
+			__u32 mode;
+		} macvlan;
+	};
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
+			__be32 inet4_local;
+			__be32 inet4_address;
+			__be32 inet4_mask;
+			__be32 inet4_broadcast;
+		};
+	} __attribute__((aligned(8)));
+} __attribute__((aligned(8)));
+
 struct ckpt_hdr_eventpoll_items {
 	struct ckpt_hdr h;
 	__s32  epfile_objref;
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
index 7a4f1ce..4059c28 100644
--- a/kernel/checkpoint/checkpoint.c
+++ b/kernel/checkpoint/checkpoint.c
@@ -291,11 +291,6 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		_ckpt_err(ctx, -EPERM, "%(T)Nested mnt_ns unsupported\n");
 		ret = -EPERM;
 	}
-	/* no support for >1 private netns */
-	if (nsproxy->net_ns != ctx->root_nsproxy->net_ns) {
-		_ckpt_err(ctx, -EPERM, "%(T)Nested net_ns unsupported\n");
-		ret = -EPERM;
-	}
 	/* pidns must be descendent of root_nsproxy */
 	pidns = nsproxy->pid_ns;
 	while (pidns != ctx->root_nsproxy->pid_ns) {
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 7fb3cea..d4af91d 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -260,6 +260,12 @@ int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	ret = ckpt_obj_collect(ctx, nsproxy->uts_ns, CKPT_OBJ_UTS_NS);
 	if (ret < 0)
 		goto out;
+#ifdef CONFIG_NETNS_CHECKPOINT
+	if (ctx->uflags & CHECKPOINT_NETNS)
+		ret = ckpt_obj_collect(ctx, nsproxy->net_ns, CKPT_OBJ_NET_NS);
+	if (ret < 0)
+		goto out;
+#endif
 #ifdef CONFIG_IPC_NS
 	ret = ckpt_obj_collect(ctx, nsproxy->ipc_ns, CKPT_OBJ_IPC_NS);
 	if (ret < 0)
@@ -308,6 +314,15 @@ static int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr)
 #endif	/* CONFIG_IPC_NS */
 	h->ipc_objref = ret;
 
+#ifdef CONFIG_NETNS_CHECKPOINT
+	if (ctx->uflags & CHECKPOINT_NETNS)
+		ret = checkpoint_obj(ctx, nsproxy->net_ns, CKPT_OBJ_NET_NS);
+	else
+		ret = 0;
+	if (ret < 0)
+		goto out;
+	h->net_objref = ret;
+#endif
 	/* FIXME: for now, only marked visited to pacify leaks */
 	ret = ckpt_obj_visit(ctx, nsproxy->mnt_ns, CKPT_OBJ_MNT_NS);
 	if (ret < 0)
@@ -341,6 +356,14 @@ static void *restore_ns(struct ckpt_ctx *ctx)
 		ret = PTR_ERR(uts_ns);
 		goto out;
 	}
+	if (h->net_objref == 0)
+		net_ns = current->nsproxy->net_ns;
+	else
+		net_ns = ckpt_obj_fetch(ctx, h->net_objref, CKPT_OBJ_NET_NS);
+	if (IS_ERR(net_ns)) {
+		ret = PTR_ERR(net_ns);
+		goto out;
+	}
 
 	if (h->ipc_objref == 0)
 		ipc_ns = ctx->root_nsproxy->ipc_ns;
@@ -356,7 +379,6 @@ static void *restore_ns(struct ckpt_ctx *ctx)
 	}
 
 	mnt_ns = ctx->root_nsproxy->mnt_ns;
-	net_ns = ctx->root_nsproxy->net_ns;
 
 	if (uts_ns == current->nsproxy->uts_ns &&
 	    ipc_ns == current->nsproxy->ipc_ns &&
diff --git a/net/Kconfig b/net/Kconfig
index 041c35e..c1cb774 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -276,4 +276,8 @@ source "net/wimax/Kconfig"
 source "net/rfkill/Kconfig"
 source "net/9p/Kconfig"
 
+config NETNS_CHECKPOINT
+       bool
+       default y if NET && NET_NS && CHECKPOINT
+
 endif   # if NET
diff --git a/net/Makefile b/net/Makefile
index 74b038f..b7d78f4 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -67,3 +67,4 @@ endif
 obj-$(CONFIG_WIMAX)		+= wimax/
 
 obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
+obj-$(CONFIG_NETNS_CHECKPOINT)	+= checkpoint_dev.o
diff --git a/net/checkpoint.c b/net/checkpoint.c
index 03c1224..b1f56bf 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -986,6 +986,56 @@ struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
  * sock-related checkpoint objects
  */
 
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
+/* netns object */
+static const struct ckpt_obj_ops ckpt_obj_netns_ops = {
+	.obj_name = "NET_NS",
+	.obj_type = CKPT_OBJ_NET_NS,
+	.ref_grab = netns_grab,
+	.ref_drop = netns_drop,
+	.checkpoint = checkpoint_netns,
+	.restore = restore_netns,
+};
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
+/* netdev object */
+static const struct ckpt_obj_ops ckpt_obj_netdev_ops = {
+	.obj_name = "NET_DEV",
+	.obj_type = CKPT_OBJ_NETDEV,
+	.ref_grab = netdev_grab,
+	.ref_drop = netdev_drop,
+	.checkpoint = checkpoint_netdev,
+	.restore = restore_netdev,
+};
+
 static int obj_sock_grab(void *ptr)
 {
 	sock_hold((struct sock *) ptr);
@@ -1033,6 +1083,17 @@ static const struct ckpt_obj_ops ckpt_obj_sock_ops = {
 
 static int __init checkpoint_register_sock(void)
 {
-	return register_checkpoint_obj(&ckpt_obj_sock_ops);
+	int ret;
+
+	ret = register_checkpoint_obj(&ckpt_obj_sock_ops);
+	if (ret < 0)
+		return ret;
+	ret = register_checkpoint_obj(&ckpt_obj_netns_ops);
+	if (ret < 0)
+		return ret;
+	ret = register_checkpoint_obj(&ckpt_obj_netdev_ops);
+	if (ret < 0)
+		return ret;
+	return 0;
 }
 module_init(checkpoint_register_sock);
diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
new file mode 100644
index 0000000..34a6bdb
--- /dev/null
+++ b/net/checkpoint_dev.c
@@ -0,0 +1,818 @@
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
+#include <linux/deferqueue.h>
+
+#include <net/net_namespace.h>
+#include <net/sch_generic.h>
+
+struct dq_netdev {
+	struct net_device *dev;
+	struct ckpt_ctx *ctx;
+};
+
+struct veth_newlink {
+	char *peer;
+};
+
+struct mvl_newlink {
+	char this[IFNAMSIZ+1];
+	char base[IFNAMSIZ+1];
+	int mode;
+	__u8 *hwaddr;
+};
+
+typedef int (*new_link_fn)(struct sk_buff *, void *);
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
+static struct socket *rtnl_open(void)
+{
+	struct socket *sock;
+	int ret;
+
+	ret = sock_create(AF_NETLINK, SOCK_DGRAM, NETLINK_ROUTE, &sock);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
+	return sock;
+}
+
+static int rtnl_close(struct socket *rtnl)
+{
+	if (rtnl)
+		return kernel_sock_shutdown(rtnl, SHUT_RDWR);
+	else
+		return 0;
+}
+
+static struct nlmsghdr *rtnl_get_response(struct socket *rtnl,
+					  struct sk_buff **skb)
+{
+	int ret;
+	long timeo = MAX_SCHEDULE_TIMEOUT;
+	struct nlmsghdr *nlh;
+
+	*skb = NULL;
+
+	lock_sock(rtnl->sk);
+	ret = sk_wait_data(rtnl->sk, &timeo);
+	if (ret)
+		*skb = skb_dequeue(&rtnl->sk->sk_receive_queue);
+	release_sock(rtnl->sk);
+
+	if (!*skb)
+		return ERR_PTR(-EPIPE);
+
+	ret = -EINVAL;
+	nlh = nlmsg_hdr(*skb);
+	if (!nlh)
+		goto err;
+
+	if (nlh->nlmsg_type == NLMSG_ERROR) {
+		struct nlmsgerr *errmsg = nlmsg_data(nlh);
+		ret = errmsg->error;
+		goto err;
+	}
+
+	return nlh;
+ err:
+	kfree_skb(*skb);
+	*skb = NULL;
+
+	return ERR_PTR(ret);
+}
+
+int ckpt_netdev_in_init_netns(struct ckpt_ctx *ctx, struct net_device *dev)
+{
+	/*
+	 * Currently, we treat the "initial network namespace" as that
+	 * of the process doing the checkpoint.  This gives us a
+	 * consistent view of the container and its layout from the
+	 * perspective of the "agent" doing the checkpoint and
+	 * restore.
+	 */
+	return dev->nd_net == current->nsproxy->net_ns;
+}
+EXPORT_SYMBOL_GPL(ckpt_netdev_in_init_netns);
+
+int ckpt_netdev_hwaddr(struct net_device *dev, struct ckpt_hdr_netdev *h)
+{
+	struct net *net = dev->nd_net;
+	struct ifreq req;
+	int ret;
+
+	memcpy(req.ifr_name, dev->name, IFNAMSIZ);
+	ret = __kern_dev_ioctl(net, SIOCGIFFLAGS, &req);
+	if (ret < 0)
+		return ret;
+	h->flags = req.ifr_flags;
+
+	ret = __kern_dev_ioctl(net, SIOCGIFHWADDR, &req);
+	if (ret < 0)
+		return ret;
+
+	memcpy(h->hwaddr, req.ifr_hwaddr.sa_data, sizeof(h->hwaddr));
+
+	return 0;
+}
+
+int ckpt_netdev_inet_addrs(struct in_device *indev,
+			   struct ckpt_netdev_addr *_abuf[])
+{
+	struct ckpt_netdev_addr *abuf = NULL;
+	struct in_ifaddr *addr = indev->ifa_list;
+	int addrs = 0;
+	int max = 32;
+
+ retry:
+	*_abuf = krealloc(abuf, max * sizeof(*abuf), GFP_KERNEL);
+	if (*_abuf == NULL) {
+		addrs = -ENOMEM;
+		goto out;
+	}
+	abuf = *_abuf;
+
+	read_lock(&dev_base_lock);
+
+	while (addr) {
+		abuf[addrs].type = CKPT_NETDEV_ADDR_IPV4; /* Only IPv4 now */
+		abuf[addrs].inet4_local = htonl(addr->ifa_local);
+		abuf[addrs].inet4_address = htonl(addr->ifa_address);
+		abuf[addrs].inet4_mask = htonl(addr->ifa_mask);
+		abuf[addrs].inet4_broadcast = htonl(addr->ifa_broadcast);
+
+		addr = addr->ifa_next;
+		if (++addrs >= max) {
+			read_unlock(&dev_base_lock);
+			max *= 2;
+			goto retry;
+		}
+	}
+
+	read_unlock(&dev_base_lock);
+ out:
+	if (addrs < 0) {
+		kfree(abuf);
+		*_abuf = NULL;
+	}
+
+	return addrs;
+}
+
+struct ckpt_hdr_netdev *ckpt_netdev_base(struct ckpt_ctx *ctx,
+					 struct net_device *dev,
+					 struct ckpt_netdev_addr *addrs[])
+{
+	struct ckpt_hdr_netdev *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NETDEV);
+	if (!h)
+		return ERR_PTR(-ENOMEM);
+
+	ret = ckpt_netdev_hwaddr(dev, h);
+	if (ret < 0)
+		goto out;
+
+	*addrs = NULL;
+	ret = h->inet_addrs = ckpt_netdev_inet_addrs(dev->ip_ptr, addrs);
+	if (ret < 0)
+		goto out;
+
+	if (ckpt_netdev_in_init_netns(ctx, dev))
+		ret = h->netns_ref = 0;
+	else
+		ret = h->netns_ref = checkpoint_obj(ctx, dev->nd_net,
+						    CKPT_OBJ_NET_NS);
+ out:
+	if (ret < 0) {
+		ckpt_hdr_put(ctx, h);
+		h = ERR_PTR(ret);
+		kfree(*addrs);
+	}
+
+	return h;
+}
+EXPORT_SYMBOL_GPL(ckpt_netdev_base);
+
+int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct net_device *dev = (struct net_device *)ptr;
+	int ret;
+
+	if (!dev->netdev_ops->ndo_checkpoint) {
+		ckpt_err(ctx, -ENOSYS,
+			 "Device %s does not support checkpoint\n", dev->name);
+		return -ENOSYS;
+	}
+
+	ckpt_debug("checkpointing netdev %s\n", dev->name);
+
+	ret = dev->netdev_ops->ndo_checkpoint(ctx, dev);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "Failed to checkpoint netdev %s: %i\n",
+			 dev->name, ret);
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
+	BUG_ON(h->this_ref <= 0);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	for_each_netdev(net, dev) {
+		if (dev->netdev_ops->ndo_checkpoint)
+			ret = checkpoint_obj(ctx, dev, CKPT_OBJ_NETDEV);
+		else if (dev->flags & IFF_UP)
+			ret = -ENOSYS;
+		else
+			/* TODO: There should be a flag to attempt a
+			 * checkpoint of downed interfaces, regardless
+			 * of whether they support checkpoint or not.
+			 */
+			ret = 0;
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
+	ret = ckpt_read_payload(ctx, (void **)&addrs, len, CKPT_HDR_BUFFER);
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
+		inaddr->sin_addr.s_addr = ntohl(addr->inet4_address);
+		inaddr->sin_family = AF_INET;
+		ret = __kern_devinet_ioctl(net, SIOCSIFADDR, &req);
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "Failed to set address\n");
+			break;
+		}
+
+		inaddr = (struct sockaddr_in *)&req.ifr_addr;
+		inaddr->sin_addr.s_addr = ntohl(addr->inet4_mask);
+		inaddr->sin_family = AF_INET;
+		ret = __kern_devinet_ioctl(net, SIOCSIFNETMASK, &req);
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "Failed to set netmask\n");
+			break;
+		}
+
+		inaddr = (struct sockaddr_in *)&req.ifr_addr;
+		inaddr->sin_addr.s_addr = ntohl(addr->inet4_broadcast);
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
+static int veth_new_link_msg(struct sk_buff *skb, void *data)
+{
+	struct nlattr *linkinfo;
+	struct nlattr *linkdata;
+	struct ifinfomsg ifm;
+	int ret = -ENOMEM;
+	struct veth_newlink *d = data;
+
+	linkinfo = nla_nest_start(skb, IFLA_LINKINFO);
+	if (!linkinfo)
+		goto out;
+
+	ret = nla_put_string(skb, IFLA_INFO_KIND, "veth");
+	if (ret)
+		goto out;
+
+	linkdata = nla_nest_start(skb, IFLA_INFO_DATA);
+	if (!linkdata) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = nla_put(skb, VETH_INFO_PEER, sizeof(ifm), &ifm);
+	if (!ret)
+		ret = nla_put_string(skb, IFLA_IFNAME, d->peer);
+
+	nla_nest_end(skb, linkdata);
+ out:
+	nla_nest_end(skb, linkinfo);
+
+	return ret;
+}
+
+static int mvl_new_link_msg(struct sk_buff *skb, void *data)
+{
+	struct mvl_newlink *d = data;
+	struct nlattr *linkinfo;
+	struct nlattr *linkdata;
+	struct net_device *lowerdev;
+	int ret;
+
+	lowerdev = dev_get_by_name(current->nsproxy->net_ns, d->base);
+	if (!lowerdev)
+		return -ENOENT;
+
+	ret = nla_put(skb, IFLA_ADDRESS, ETH_ALEN, d->hwaddr);
+	if (ret)
+		goto out_put;
+
+	ret = nla_put_u32(skb, IFLA_LINK, lowerdev->ifindex);
+	if (ret)
+		goto out_put;
+
+	linkinfo = nla_nest_start(skb, IFLA_LINKINFO);
+	if (!linkinfo) {
+		ret = -ENOMEM;
+		goto out_put;
+	}
+
+	ret = nla_put_string(skb, IFLA_INFO_KIND, "macvlan");
+	if (ret)
+		goto out;
+
+	linkdata = nla_nest_start(skb, IFLA_INFO_DATA);
+	if (!linkdata) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = nla_put_u32(skb, IFLA_MACVLAN_MODE, d->mode);
+	nla_nest_end(skb, linkdata);
+ out:
+	nla_nest_end(skb, linkinfo);
+ out_put:
+	dev_put(lowerdev);
+
+	return ret;
+}
+
+static struct sk_buff *new_link_msg(new_link_fn fn, void *data, char *name)
+{
+	int ret = -ENOMEM;
+	int flags = NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	struct ifinfomsg *ifm;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		goto out;
+
+	nlh = nlmsg_put(skb, 0, 0, RTM_NEWLINK, sizeof(*ifm), flags);
+	if (!nlh)
+		goto out;
+
+	ifm = nlmsg_data(nlh);
+	memset(ifm, 0, sizeof(*ifm));
+
+	ret = nla_put_string(skb, IFLA_IFNAME, name);
+	if (ret)
+		goto out;
+
+	ret = fn(skb, data);
+
+	nlmsg_end(skb, nlh);
+
+ out:
+	if (ret < 0) {
+		kfree_skb(skb);
+		skb = ERR_PTR(ret);
+	}
+
+	return skb;
+}
+
+static struct net_device *rtnl_newlink(new_link_fn fn, void *data, char *name)
+{
+	int ret = -ENOMEM;
+	struct socket *rtnl = NULL;
+	struct sk_buff *skb = NULL;
+	struct nlmsghdr *nlh;
+	struct msghdr msg;
+	struct kvec kvec;
+
+	skb = new_link_msg(fn, data, name);
+	if (IS_ERR(skb)) {
+		ckpt_debug("failed to create new link message: %li\n",
+			   PTR_ERR(skb));
+		return ERR_PTR(PTR_ERR(skb));
+	}
+
+	memset(&msg, 0, sizeof(msg));
+	kvec.iov_len = skb->len;
+	kvec.iov_base = skb->head;
+
+	rtnl = rtnl_open();
+	if (IS_ERR(rtnl)) {
+		ret = PTR_ERR(rtnl);
+		ckpt_debug("Unable to open rtnetlink socket: %i\n", ret);
+		goto out_noclose;
+	}
+
+	ret = kernel_sendmsg(rtnl, &msg, &kvec, 1, kvec.iov_len);
+	if (ret < 0)
+		goto out;
+	else if (ret != skb->len) {
+		ret = -EIO;
+		goto out;
+	}
+
+	/* Free the send skb to make room for the receive skb */
+	kfree_skb(skb);
+
+	nlh = rtnl_get_response(rtnl, &skb);
+	if (IS_ERR(nlh)) {
+		ret = PTR_ERR(nlh);
+		ckpt_debug("RTNETLINK said: %i\n", ret);
+	}
+ out:
+	rtnl_close(rtnl);
+ out_noclose:
+	kfree_skb(skb);
+
+	if (ret < 0)
+		return ERR_PTR(ret);
+	else
+		return dev_get_by_name(current->nsproxy->net_ns, name);
+}
+
+static int netdev_noop(void *data)
+{
+	return 0;
+}
+
+static int netdev_cleanup(void *data)
+{
+	struct dq_netdev *dq = data;
+
+	dev_put(dq->dev);
+
+	if (dq->ctx->errno) {
+		ckpt_debug("Unregistering netdev %s\n", dq->dev->name);
+		unregister_netdev(dq->dev);
+	}
+
+	return 0;
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
+	struct ifreq req;
+	struct dq_netdev dq;
+
+	dq.ctx = ctx;
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
+	peer = ckpt_obj_try_fetch(ctx, h->veth.peer_ref, CKPT_OBJ_NETDEV);
+	if (IS_ERR(peer)) {
+		struct veth_newlink veth = {
+			.peer = peer_name,
+		};
+
+		dev = rtnl_newlink(veth_new_link_msg, &veth, this_name);
+		if (IS_ERR(dev))
+			return dev;
+
+		peer = dev_get_by_name(current->nsproxy->net_ns, peer_name);
+		if (!peer) {
+			ret = -EINVAL;
+			goto err_dev;
+		}
+
+		dq.dev = peer;
+		ret = deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
+				     netdev_noop, netdev_cleanup);
+		if (ret)
+			goto err_peer;
+
+		ret = ckpt_obj_insert(ctx, peer, h->veth.peer_ref,
+				      CKPT_OBJ_NETDEV);
+		if (ret < 0)
+			/* Can't recall peer dq, so let it cleanup peer */
+			goto err_dev;
+		dev_put(peer);
+
+		dq.dev = dev;
+		ret = deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
+				     netdev_noop, netdev_cleanup);
+		if (ret)
+			/* Can't recall peer dq, so let it cleanup peer */
+			goto err_dev;
+
+	} else {
+		/* We're second: get our dev from the hash */
+		dev = ckpt_obj_fetch(ctx, h->veth.this_ref, CKPT_OBJ_NETDEV);
+		if (IS_ERR(dev))
+			return dev;
+	}
+
+	/* Move to our new netns */
+	rtnl_lock();
+	ret = dev_change_net_namespace(dev, net, dev->name);
+	rtnl_unlock();
+	if (ret < 0)
+		goto out;
+
+	/* Restore MAC address */
+	memcpy(req.ifr_name, dev->name, IFNAMSIZ);
+	memcpy(req.ifr_hwaddr.sa_data, h->hwaddr, sizeof(h->hwaddr));
+	req.ifr_hwaddr.sa_family = ARPHRD_ETHER;
+	ret = __kern_dev_ioctl(net, SIOCSIFHWADDR, &req);
+ out:
+	if (ret)
+		dev = ERR_PTR(ret);
+
+	return dev;
+
+ err_peer:
+	dev_put(peer);
+	unregister_netdev(peer);
+ err_dev:
+	dev_put(dev);
+	unregister_netdev(dev);
+
+	return ERR_PTR(ret);
+}
+
+static struct net_device *restore_lo(struct ckpt_ctx *ctx,
+				     struct ckpt_hdr_netdev *h,
+				     struct net *net)
+{
+	struct net_device *dev;
+	char name[IFNAMSIZ+1];
+	int ret;
+
+	dev = dev_get_by_name(net, "lo");
+	if (!dev)
+		return ERR_PTR(-EINVAL);
+
+	ret = _ckpt_read_buffer(ctx, name, IFNAMSIZ);
+	if (ret < 0)
+		goto err;
+
+	if (strncmp(dev->name, name, IFNAMSIZ) != 0) {
+		ret = dev_change_name(dev, name);
+		if (ret < 0)
+			goto err;
+	}
+
+	return dev;
+ err:
+	dev_put(dev);
+
+	return ERR_PTR(ret);
+}
+
+static struct net_device *restore_sit(struct ckpt_ctx *ctx,
+				      struct ckpt_hdr_netdev *h,
+				      struct net *net)
+{
+	/* Don't actually do anything for SIT devices yet */
+	return dev_get_by_name(net, "sit0");
+}
+
+static struct net_device *restore_macvlan(struct ckpt_ctx *ctx,
+					  struct ckpt_hdr_netdev *h,
+					  struct net *net)
+{
+	struct net_device *dev;
+	struct mvl_newlink mvl = {
+		.mode = h->macvlan.mode,
+		.hwaddr = h->hwaddr,
+	};
+	int ret;
+
+	ret = _ckpt_read_buffer(ctx, mvl.this, IFNAMSIZ);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
+	ret = _ckpt_read_buffer(ctx, mvl.base, IFNAMSIZ);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
+	dev = rtnl_newlink(mvl_new_link_msg, &mvl, mvl.this);
+	if (IS_ERR(dev)) {
+		ckpt_err(ctx, PTR_ERR(dev),
+			 "Failed to create macvlan device %s:%s",
+			 mvl.this, mvl.base);
+		goto out;
+	}
+
+	rtnl_lock();
+	ret = dev_change_net_namespace(dev, net, dev->name);
+	rtnl_unlock();
+
+	if (ret) {
+		ckpt_err(ctx, ret, "Failed to change netns of %s:%s\n",
+			 mvl.this, mvl.base);
+		dev_put(dev);
+		unregister_netdev(dev);
+		dev = ERR_PTR(ret);
+	}
+ out:
+	return dev;
+}
+
+typedef struct net_device *(*restore_netdev_fn)(struct ckpt_ctx *,
+						struct ckpt_hdr_netdev *,
+						struct net *);
+
+restore_netdev_fn restore_netdev_functions[] = {
+	restore_lo,		/* CKPT_NETDEV_LO */
+	restore_veth,		/* CKPT_NETDEV_VETH */
+	restore_sit,		/* CKPT_NETDEV_SIT */
+	restore_macvlan,	/* CKPT_NETDEV_MACVLAN */
+};
+
+void *restore_netdev(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_netdev *h;
+	struct net_device *dev = NULL;
+	struct ifreq req;
+	struct net *net;
+	int ret;
+	restore_netdev_fn restore_fn = NULL;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_NETDEV);
+	if (IS_ERR(h))
+		return h;
+
+	if (h->netns_ref != 0) {
+		net = ckpt_obj_try_fetch(ctx, h->netns_ref, CKPT_OBJ_NET_NS);
+		if (IS_ERR(net)) {
+			ckpt_debug("failed to get net for %i\n", h->netns_ref);
+			ret = PTR_ERR(net);
+			goto out;
+		}
+	} else
+		net = current->nsproxy->net_ns;
+
+	if (h->type >= CKPT_NETDEV_MAX) {
+		ret = -EINVAL;
+		ckpt_err(ctx, ret, "Invalid netdev type %i\n", h->type);
+		goto out;
+	}
+
+	restore_fn = restore_netdev_functions[h->type];
+
+	dev = restore_fn(ctx, h, net);
+	if (IS_ERR(dev)) {
+		ret = PTR_ERR(dev);
+		ckpt_err(ctx, ret, "Netdev type %i not supported\n", h->type);
+		goto out;
+	}
+
+	/* Restore flags (which will likely bring the interface up) */
+	memcpy(req.ifr_name, dev->name, IFNAMSIZ);
+	req.ifr_flags = h->flags;
+	ret = __kern_dev_ioctl(net, SIOCSIFFLAGS, &req);
+	if (ret < 0)
+		goto out;
+
+	if (h->inet_addrs > 0)
+		ret = restore_in_addrs(ctx, h->inet_addrs, net, dev);
+ out:
+	if (ret) {
+		ckpt_err(ctx, ret, "Failed to restore netdevice\n");
+		if ((h->type == CKPT_NETDEV_VETH) && !IS_ERR(dev))
+			dev_put(dev);
+		dev = ERR_PTR(ret);
+	} else
+		ckpt_debug("restored netdev %s\n", dev->name);
+
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
+	if (h->this_ref != 0) {
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
1.6.3.3

