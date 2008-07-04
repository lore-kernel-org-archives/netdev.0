From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [RFC patch 06/12] LTTng instrumentation net
Date: Fri, 04 Jul 2008 19:52:13 -0400
Message-ID: <20080704235426.289204789@polymtl.ca>
References: <20080704235207.147809973@polymtl.ca>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	netdev@vger.kernel.org, Hideo AOKI <haoki@redhat.com>,
	Takashi Nishiie <t-nishiie@np.css.fujitsu.com>,
	Masami Hiramatsu <mhiramat@redhat.com>
To: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	"Frank Ch. Eigler" <fche@redhat.com>,
	Steven Rostedt <ros
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757383AbYGDX6V@vger.kernel.org>
Content-Disposition: inline; filename=lttng-instrumentation-net.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Network core events.

Added tracepoints :

net_del_ifa_ipv4
net_dev_receive
net_dev_xmit
net_insert_ifa_ipv4
net_socket_call
net_socket_create
net_socket_recvmsg
net_socket_sendmsg

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: netdev@vger.kernel.org
CC: 'Peter Zijlstra' <peterz@infradead.org>
CC: "Frank Ch. Eigler" <fche@redhat.com>
CC: 'Ingo Molnar' <mingo@elte.hu>
CC: 'Hideo AOKI' <haoki@redhat.com>
CC: Takashi Nishiie <t-nishiie@np.css.fujitsu.com>
CC: 'Steven Rostedt' <rostedt@goodmis.org>
CC: Masami Hiramatsu <mhiramat@redhat.com>
---
 net/core/dev.c     |    4 ++++
 net/ipv4/devinet.c |    3 +++
 net/net-trace.h    |   40 ++++++++++++++++++++++++++++++++++++++++
 net/socket.c       |    7 +++++++
 4 files changed, 54 insertions(+)

Index: linux-2.6-lttng/net/core/dev.c
===================================================================
--- linux-2.6-lttng.orig/net/core/dev.c	2008-07-04 18:43:16.000000000 -0400
+++ linux-2.6-lttng/net/core/dev.c	2008-07-04 19:21:13.000000000 -0400
@@ -121,6 +121,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_vlan.h>
 
+#include "../net-trace.h"
 #include "net-sysfs.h"
 
 /*
@@ -1669,6 +1670,8 @@ int dev_queue_xmit(struct sk_buff *skb)
 	}
 
 gso:
+	trace_net_dev_xmit(skb);
+
 	spin_lock_prefetch(&dev->queue_lock);
 
 	/* Disable soft irqs for various locks below. Also
@@ -2069,6 +2072,7 @@ int netif_receive_skb(struct sk_buff *sk
 
 	__get_cpu_var(netdev_rx_stat).total++;
 
+	trace_net_dev_receive(skb);
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
 	skb->mac_len = skb->network_header - skb->mac_header;
Index: linux-2.6-lttng/net/ipv4/devinet.c
===================================================================
--- linux-2.6-lttng.orig/net/ipv4/devinet.c	2008-07-04 18:43:16.000000000 -0400
+++ linux-2.6-lttng/net/ipv4/devinet.c	2008-07-04 19:21:13.000000000 -0400
@@ -63,6 +63,7 @@
 #include <net/ip_fib.h>
 #include <net/rtnetlink.h>
 #include <net/net_namespace.h>
+#include "../net-trace.h"
 
 static struct ipv4_devconf ipv4_devconf = {
 	.data = {
@@ -257,6 +258,7 @@ static void __inet_del_ifa(struct in_dev
 		struct in_ifaddr **ifap1 = &ifa1->ifa_next;
 
 		while ((ifa = *ifap1) != NULL) {
+			trace_net_del_ifa_ipv4(ifa);
 			if (!(ifa->ifa_flags & IFA_F_SECONDARY) &&
 			    ifa1->ifa_scope <= ifa->ifa_scope)
 				last_prim = ifa;
@@ -363,6 +365,7 @@ static int __inet_insert_ifa(struct in_i
 			}
 			ifa->ifa_flags |= IFA_F_SECONDARY;
 		}
+		trace_net_insert_ifa_ipv4(ifa);
 	}
 
 	if (!(ifa->ifa_flags & IFA_F_SECONDARY)) {
Index: linux-2.6-lttng/net/socket.c
===================================================================
--- linux-2.6-lttng.orig/net/socket.c	2008-07-04 18:43:16.000000000 -0400
+++ linux-2.6-lttng/net/socket.c	2008-07-04 19:21:13.000000000 -0400
@@ -93,6 +93,7 @@
 
 #include <net/sock.h>
 #include <linux/netfilter.h>
+#include "net-trace.h"
 
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
@@ -572,6 +573,7 @@ int sock_sendmsg(struct socket *sock, st
 	ret = __sock_sendmsg(&iocb, sock, msg, size);
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&iocb);
+	trace_net_socket_sendmsg(sock, msg, size, ret);
 	return ret;
 }
 
@@ -651,10 +653,12 @@ int sock_recvmsg(struct socket *sock, st
 	int ret;
 
 	init_sync_kiocb(&iocb, NULL);
+
 	iocb.private = &siocb;
 	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&iocb);
+	trace_net_socket_recvmsg(sock, msg, size, flags, ret);
 	return ret;
 }
 
@@ -1226,6 +1230,7 @@ asmlinkage long sys_socket(int family, i
 	if (retval < 0)
 		goto out_release;
 
+	trace_net_socket_create(sock, retval);
 out:
 	/* It may be already another descriptor 8) Not kernel problem. */
 	return retval;
@@ -2024,6 +2029,8 @@ asmlinkage long sys_socketcall(int call,
 	a0 = a[0];
 	a1 = a[1];
 
+	trace_net_socket_call(call, a0);
+
 	switch (call) {
 	case SYS_SOCKET:
 		err = sys_socket(a0, a1, a[2]);
Index: linux-2.6-lttng/net/net-trace.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6-lttng/net/net-trace.h	2008-07-04 19:21:13.000000000 -0400
@@ -0,0 +1,40 @@
+#ifndef _NET_TRACE_H
+#define _NET_TRACE_H
+
+#include <linux/net.h>
+#include <linux/inetdevice.h>
+#include <net/sock.h>
+#include <linux/tracepoint.h>
+
+DEFINE_TRACE(net_dev_xmit,
+	TPPROTO(struct sk_buff *skb),
+	TPARGS(skb));
+DEFINE_TRACE(net_dev_receive,
+	TPPROTO(struct sk_buff *skb),
+	TPARGS(skb));
+DEFINE_TRACE(net_del_ifa_ipv4,
+	TPPROTO(struct in_ifaddr *ifa),
+	TPARGS(ifa));
+DEFINE_TRACE(net_insert_ifa_ipv4,
+	TPPROTO(struct in_ifaddr *ifa),
+	TPARGS(ifa));
+DEFINE_TRACE(net_socket_sendmsg,
+	TPPROTO(struct socket *sock, struct msghdr *msg, size_t size, int ret),
+	TPARGS(sock, msg, size, ret));
+DEFINE_TRACE(net_socket_recvmsg,
+	TPPROTO(struct socket *sock, struct msghdr *msg, size_t size, int flags,
+		int ret),
+	TPARGS(sock, msg, size, flags, ret));
+DEFINE_TRACE(net_socket_create,
+	TPPROTO(struct socket *sock, int fd),
+	TPARGS(sock, fd));
+/*
+ * net_socket_call
+ *
+ * TODO : This tracepoint should be expanded to cover each element of the
+ * switch in sys_socketcall().
+ */
+DEFINE_TRACE(net_socket_call,
+	TPPROTO(int call, unsigned long a0),
+	TPARGS(call, a0));
+#endif

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
