From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 7/9] fanotify: userspace socket
Date: Fri, 28 Aug 2009 14:56:26 -0400
Message-ID: <20090828185626.8014.13530.stgit@paris.rdu.redhat.com>
References: <20090828185542.8014.22791.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@zeniv.linux.org.uk, alan@linux.intel.com,
	hch@infradead.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752621AbZH1S4h@vger.kernel.org>
In-Reply-To: <20090828185542.8014.22791.stgit@paris.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements an userspace interface for the fanotify notification
system.  An fanotify socket is created in userspace and is 'bound' to an
address.  That bind call actually creates the new fanotify listener much like
inotify_init() creates an inotify instance.

Requests for notification of events on certain fs objects is done using a
setsockopt() call.  (not implemented in this patch)  This setsockopt() call is
largely analogous to inotify_add_watch()

Events are retrieved from the kernel calling read on the bound socket.
This interface is designed to be forward looking as the kernel/userspace
interaction can be changed simply by implementing a new getsockopt option.

Macros are provided much like the netlink macros in order to allow of the
messages from the kernel to userspace to change in length in the future while
maintaining backwards compatibility.

This patch only implements the socket registration and the bind call.  The
getsockopt() calls and data read call are implemented in later patches.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 fs/notify/fanotify/Makefile      |    2 -
 fs/notify/fanotify/af_fanotify.c |  152 ++++++++++++++++++++++++++++++++++++++
 fs/notify/fanotify/af_fanotify.h |   21 +++++
 fs/notify/fanotify/fanotify.h    |    2 +
 include/linux/fanotify.h         |   19 +++++
 5 files changed, 195 insertions(+), 1 deletions(-)
 create mode 100644 fs/notify/fanotify/af_fanotify.c
 create mode 100644 fs/notify/fanotify/af_fanotify.h

diff --git a/fs/notify/fanotify/Makefile b/fs/notify/fanotify/Makefile
index e7d39c0..1196005 100644
--- a/fs/notify/fanotify/Makefile
+++ b/fs/notify/fanotify/Makefile
@@ -1 +1 @@
-obj-$(CONFIG_FANOTIFY)		+= fanotify.o
+obj-$(CONFIG_FANOTIFY)		+= fanotify.o af_fanotify.o
diff --git a/fs/notify/fanotify/af_fanotify.c b/fs/notify/fanotify/af_fanotify.c
new file mode 100644
index 0000000..d7bf658
--- /dev/null
+++ b/fs/notify/fanotify/af_fanotify.c
@@ -0,0 +1,152 @@
+#include <linux/errno.h>
+#include <linux/fdtable.h>
+#include <linux/file.h>
+#include <linux/fsnotify_backend.h>
+#include <linux/init.h>
+#include <linux/kernel.h> /* UINT_MAX */
+#include <linux/mount.h> /* mntget() */
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/socket.h>
+#include <linux/types.h>
+
+#include <net/net_namespace.h>
+#include <net/sock.h>
+
+#include "fanotify.h"
+#include "af_fanotify.h"
+
+static const struct proto_ops fanotify_proto_ops;
+
+static struct proto fanotify_proto = {
+	.name     = "FANOTIFY",
+	.owner    = THIS_MODULE,
+	.obj_size = sizeof(struct fanotify_sock),
+};
+
+static int fan_sock_create(struct net *net, struct socket *sock, int protocol)
+{
+	struct sock *sk;
+	struct fanotify_sock *fan_sock;
+
+	/* FIXME maybe a new LSM hook? */
+	if (!capable(CAP_NET_RAW))
+		return -EPERM;
+
+	if (protocol != 0)
+		return -ESOCKTNOSUPPORT;
+
+	if (sock->type != SOCK_RAW)
+		return -ESOCKTNOSUPPORT;
+
+	sock->state = SS_UNCONNECTED;
+
+	sk = sk_alloc(net, PF_FANOTIFY, GFP_KERNEL, &fanotify_proto);
+	if (sk == NULL)
+		return -ENOBUFS;
+
+	sock->ops = &fanotify_proto_ops;
+
+	sock_init_data(sock, sk);
+
+	sk->sk_family = PF_FANOTIFY;
+	sk_refcnt_debug_inc(sk);
+
+	fan_sock = fan_sk(sk);
+	fan_sock->group = NULL;
+
+	return 0;
+}
+
+static int fan_release(struct socket *sock)
+{
+	struct sock *sk;
+	struct fanotify_sock *fan_sock;
+
+	sk = sock->sk;
+	if (!sk)
+		return 0;
+
+	fan_sock = fan_sk(sk);
+
+	if (sock->state == SS_CONNECTED) {
+		sock->state = SS_UNCONNECTED;
+		fsnotify_put_group(fan_sock->group);
+	}
+
+	fan_sock->group = NULL;
+
+	sock_orphan(sk);
+	sock->sk = NULL;
+
+	sk_refcnt_debug_release(sk);
+
+	sock_put(sk);
+
+	return 0;
+}
+
+static int fan_bind(struct socket *sock, struct sockaddr *addr, int addr_len)
+{
+	struct fanotify_addr *fan_addr = (struct fanotify_addr *)addr;
+	struct fanotify_sock *fan_sock;
+
+	if (addr_len != sizeof(struct fanotify_addr))
+		return -EINVAL;
+
+	if (sock->state != SS_UNCONNECTED)
+		return -EINVAL;
+
+	if (!fanotify_is_mask_valid(fan_addr->mask))
+		return -EINVAL;
+
+	fan_sock = fan_sk(sock->sk);
+	fan_sock->group = fsnotify_obtain_group(fan_addr->mask, &fanotify_ops);
+
+	if (IS_ERR(fan_sock->group))
+		return PTR_ERR(fan_sock->group);
+
+	fan_sock->group->max_events = 16383;
+
+	sock->state = SS_CONNECTED;
+
+	return 0;
+}
+
+static const struct net_proto_family fanotify_family_ops = {
+	.family		=	PF_FANOTIFY,
+	.create		=	fan_sock_create,
+	.owner		=	THIS_MODULE,
+};
+
+static const struct proto_ops fanotify_proto_ops = {
+	.family =	PF_FANOTIFY,
+	.owner =	THIS_MODULE,
+	.release =	fan_release,
+	.bind =		fan_bind,
+	.connect =	sock_no_connect,
+	.socketpair =	sock_no_socketpair,
+	.accept =	sock_no_accept,
+	.getname =	sock_no_getname,
+	.poll =		sock_no_poll,
+	.ioctl =	sock_no_ioctl,
+	.listen =	sock_no_listen,
+	.shutdown =	sock_no_shutdown,
+	.setsockopt =	sock_no_setsockopt,
+	.getsockopt =	sock_no_getsockopt,
+	.sendmsg =	sock_no_sendmsg,
+	.recvmsg =	sock_no_recvmsg,
+	.mmap =		sock_no_mmap,
+	.sendpage =	sock_no_sendpage,
+};
+
+static int __init fanotify_init(void)
+{
+	if (proto_register(&fanotify_proto, 0))
+		panic("unable to register fanotify protocol with network stack\n");
+
+	sock_register(&fanotify_family_ops);
+
+	return 0;
+}
+device_initcall(fanotify_init);
diff --git a/fs/notify/fanotify/af_fanotify.h b/fs/notify/fanotify/af_fanotify.h
new file mode 100644
index 0000000..fff0e66
--- /dev/null
+++ b/fs/notify/fanotify/af_fanotify.h
@@ -0,0 +1,21 @@
+#ifndef _LINUX_AF_FANOTIFY_H
+#define _LINUX_AF_FANOTIFY_H
+
+#include <linux/fanotify.h>
+#include <net/sock.h>
+
+struct fanotify_sock {
+	struct sock		sock;
+	struct fsnotify_group	*group;
+};
+
+static inline struct fanotify_sock *fan_sk(struct sock *sock)
+{
+	struct fanotify_sock *fan_sock;
+
+	fan_sock = container_of(sock, struct fanotify_sock, sock);
+
+	return fan_sock;
+}
+
+#endif /* _LINUX_AF_NET_H */
diff --git a/fs/notify/fanotify/fanotify.h b/fs/notify/fanotify/fanotify.h
index a8785c1..6c7bf06 100644
--- a/fs/notify/fanotify/fanotify.h
+++ b/fs/notify/fanotify/fanotify.h
@@ -4,6 +4,8 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 
+extern const struct fsnotify_ops fanotify_ops;
+
 static inline bool fanotify_is_mask_valid(__u32 mask)
 {
 	if (mask & ~(FAN_ALL_INCOMING_EVENTS))
diff --git a/include/linux/fanotify.h b/include/linux/fanotify.h
index b560f86..31fa74d 100644
--- a/include/linux/fanotify.h
+++ b/include/linux/fanotify.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_FANOTIFY_H
 #define _LINUX_FANOTIFY_H
 
+#include <linux/socket.h>
 #include <linux/types.h>
 
 /* the following events that user-space can register for */
@@ -34,6 +35,24 @@
  */
 #define FAN_ALL_INCOMING_EVENTS	(FAN_ALL_EVENTS |\
 				 FAN_EVENT_ON_CHILD)
+#ifndef SOL_FANOTIFY
+#define SOL_FANOTIFY	278
+#endif
+
+#ifndef AF_FANOTIFY
+#define AF_FANOTIFY	37
+#define PF_FANOTIFY	AF_FANOTIFY
+#endif
+
+struct fanotify_addr {
+	sa_family_t family;
+	__u32 priority; /* unused */
+	__u32 mask_hi; /* unused */
+	__u32 mask;
+	__u32 f_flags; /* unused */
+	__u32 unused[16];
+}  __attribute__((packed));
+
 #ifdef __KERNEL__
 
 #endif /* __KERNEL__ */
