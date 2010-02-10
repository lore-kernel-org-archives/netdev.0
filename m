From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and devices (v3)
Date: Wed, 10 Feb 2010 09:55:02 -0800
Message-ID: <87ljf1gemh.fsf@caffeine.danplanet.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
	<1265750713-15749-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:52593 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754556Ab0BJRzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 12:55:05 -0500
In-Reply-To: <1265750713-15749-3-git-send-email-danms@us.ibm.com> (Dan Smith's message of "Tue\,  9 Feb 2010 13\:25\:11 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guilt dropped the new checkpoint_dev.c file when I switched to the
newer branch.  Sorry about that.  Updated patch included below.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com

C/R: Basic support for network namespaces and devices (v3)

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
index 4ca7799..729fbe5 100644
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
diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
new file mode 100644
index 0000000..0dddd15
--- /dev/null
+++ b/net/checkpoint_dev.c
@@ -0,0 +1,673 @@
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
+	return kernel_sock_shutdown(rtnl, SHUT_RDWR);
+}
+
+static struct nlmsghdr *rtnl_get_response(struct socket *rtnl,
+					  struct sk_buff **skb)
+{
+	int ret;
+	long timeo = MAX_SCHEDULE_TIMEOUT;
+	struct nlmsghdr *nlh;
+
+	ret = sk_wait_data(rtnl->sk, &timeo);
+	if (!ret)
+		return ERR_PTR(-EPIPE);
+
+	*skb = skb_dequeue(&rtnl->sk->sk_receive_queue);
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
+	struct net *net = dev->nd_net;
+	int ref;
+
+	ref = ckpt_obj_lookup(ctx, net, CKPT_OBJ_NET_NS);
+	return ref == ctx->init_netns_ref;
+}
+
+int ckpt_netdev_hwaddr(struct net_device *dev, struct ckpt_hdr_netdev *h)
+{
+	struct net *net = dev->nd_net;
+	struct ifreq req;
+	int ret;
+
+	memcpy(req.ifr_name, dev->name, IFNAMSIZ);
+	ret = __kern_dev_ioctl(net, SIOCGIFFLAGS, &req);
+	h->flags = req.ifr_flags;
+	if (ret < 0)
+		return ret;
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
+	ret = h->netns_ref = checkpoint_obj(ctx, dev->nd_net, CKPT_OBJ_NET_NS);
+ out:
+	if (ret < 0) {
+		ckpt_hdr_put(ctx, h);
+		h = ERR_PTR(ret);
+		if (*addrs)
+			kfree(*addrs);
+	}
+
+	return h;
+}
+
+int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct net_device *dev = (struct net_device *)ptr;
+
+	if (!dev->netdev_ops->ndo_checkpoint)
+		return -EINVAL;
+
+	ckpt_debug("checkpointing netdev %s\n", dev->name);
+
+	return dev->netdev_ops->ndo_checkpoint(ctx, dev);
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
+		if (!dev->netdev_ops->ndo_checkpoint)
+			continue;
+		ret = checkpoint_obj(ctx, dev, CKPT_OBJ_NETDEV);
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
+static int veth_peer_data(struct sk_buff *skb, char *peer_name)
+{
+	struct nlattr *linkdata;
+	struct ifinfomsg ifm;
+
+	linkdata = nla_nest_start(skb, IFLA_INFO_DATA);
+	if (!linkdata)
+		return -ENOMEM;
+
+	nla_put(skb, VETH_INFO_PEER, sizeof(ifm), &ifm);
+	nla_put_string(skb, IFLA_IFNAME, peer_name);
+
+	nla_nest_end(skb, linkdata);
+
+	return 0;
+}
+
+static struct sk_buff *new_link_message(char *this_name, char *peer_name)
+{
+	int ret = -ENOMEM;
+	int flags = NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	struct ifinfomsg *ifm;
+	struct nlattr *linkinfo;
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
+	ret = nla_put_string(skb, IFLA_IFNAME, this_name);
+	if (ret)
+		goto out;
+
+	ret = -ENOMEM;
+
+	linkinfo = nla_nest_start(skb, IFLA_LINKINFO);
+	if (!linkinfo)
+		goto out;
+
+	if (nla_put_string(skb, IFLA_INFO_KIND, "veth") < 0)
+		goto out;
+
+	ret = veth_peer_data(skb, peer_name);
+	if (ret < 0)
+		goto out;
+
+	nla_nest_end(skb, linkinfo);
+	nlmsg_end(skb, nlh);
+
+ out:
+	if (ret < 0) {
+		kfree(skb);
+		skb = ERR_PTR(ret);
+	}
+
+	return skb;
+}
+
+static struct net_device *new_veth_pair(char *this_name, char *peer_name)
+{
+	int ret = -ENOMEM;
+	struct socket *rtnl;
+	struct sk_buff *skb = NULL;
+	struct nlmsghdr *nlh;
+	struct msghdr msg;
+	struct kvec kvec;
+
+	skb = new_link_message(this_name, peer_name);
+	if (IS_ERR(skb)) {
+		ret = PTR_ERR(skb);
+		ckpt_debug("failed to create new link message: %i\n", ret);
+		skb = NULL;
+		goto out;
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
+	kfree(skb);
+
+	nlh = rtnl_get_response(rtnl, &skb);
+	if (IS_ERR(nlh)) {
+		ret = PTR_ERR(nlh);
+		ckpt_debug("RTNETLINK said: %i\n", ret);
+	}
+ out:
+	rtnl_close(rtnl);
+ out_noclose:
+	kfree(skb);
+
+	if (ret < 0)
+		return ERR_PTR(ret);
+	else
+		return dev_get_by_name(current->nsproxy->net_ns, this_name);
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
+	int didreg = 0;
+
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
+	peer = ckpt_obj_try_fetch(ctx, h->peer_ref, CKPT_OBJ_NETDEV);
+	if (IS_ERR(peer)) {
+		/* We're first: allocate the veth pair */
+		didreg = 1;
+		dev = new_veth_pair(this_name, peer_name);
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
+		ret = ckpt_obj_insert(ctx, peer, h->peer_ref, CKPT_OBJ_NETDEV);
+		if (ret < 0)
+			/* Can't recall peer dq, so let it cleanup peer */
+			goto err_dev;
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
+		dev = ckpt_obj_fetch(ctx, h->this_ref, CKPT_OBJ_NETDEV);
+		if (IS_ERR(dev))
+			return dev;
+	}
+
+	/* Move to our new netns */
+	rtnl_lock();
+	ret = dev_change_net_namespace(dev, net, dev->name);
+	rtnl_unlock();
+
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
+			ckpt_debug("failed to get net for %i\n", h->netns_ref);
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
+		dev = restore_lo(ctx, h, net);
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
+		ckpt_err(ctx, ret, "Failed to restore netdevice\n");
+		if ((h->type == CKPT_NETDEV_VETH) && !IS_ERR(dev)) {
+			dev_put(dev);
+		}
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
