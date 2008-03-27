From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch for 2.6.26 6/7] LTTng instrumentation net
Date: Thu, 27 Mar 2008 09:21:03 -0400
Message-ID: <20080327133014.691478740@polymtl.ca>
References: <20080327132057.449831367@polymtl.ca>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761465AbYC0Ncb@vger.kernel.org>
Content-Disposition: inline; filename=lttng-instrumentation-net.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Network core events.

Added markers :

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
---
 net/core/dev.c     |    6 ++++++
 net/ipv4/devinet.c |    6 ++++++
 net/socket.c       |   19 +++++++++++++++++++
 3 files changed, 31 insertions(+)

Index: linux-2.6-lttng/net/core/dev.c
===================================================================
--- linux-2.6-lttng.orig/net/core/dev.c	2008-03-27 07:26:26.000000000 -0400
+++ linux-2.6-lttng/net/core/dev.c	2008-03-27 07:31:44.000000000 -0400
@@ -119,6 +119,7 @@
 #include <linux/err.h>
 #include <linux/ctype.h>
 #include <linux/if_arp.h>
+#include <linux/marker.h>
 
 #include "net-sysfs.h"
 
@@ -1643,6 +1644,8 @@ int dev_queue_xmit(struct sk_buff *skb)
 	}
 
 gso:
+	trace_mark(net_dev_xmit, "skb %p protocol #2u%hu", skb, skb->protocol);
+
 	spin_lock_prefetch(&dev->queue_lock);
 
 	/* Disable soft irqs for various locks below. Also
@@ -2043,6 +2046,9 @@ int netif_receive_skb(struct sk_buff *sk
 
 	__get_cpu_var(netdev_rx_stat).total++;
 
+	trace_mark(net_dev_receive, "skb %p protocol #2u%hu",
+		skb, skb->protocol);
+
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
 	skb->mac_len = skb->network_header - skb->mac_header;
Index: linux-2.6-lttng/net/ipv4/devinet.c
===================================================================
--- linux-2.6-lttng.orig/net/ipv4/devinet.c	2008-03-27 07:26:26.000000000 -0400
+++ linux-2.6-lttng/net/ipv4/devinet.c	2008-03-27 07:31:49.000000000 -0400
@@ -56,6 +56,7 @@
 #include <linux/sysctl.h>
 #endif
 #include <linux/kmod.h>
+#include <linux/marker.h>
 
 #include <net/arp.h>
 #include <net/ip.h>
@@ -258,6 +259,8 @@ static void __inet_del_ifa(struct in_dev
 		struct in_ifaddr **ifap1 = &ifa1->ifa_next;
 
 		while ((ifa = *ifap1) != NULL) {
+			trace_mark(net_del_ifa_ipv4, "label %s",
+				ifa->ifa_label);
 			if (!(ifa->ifa_flags & IFA_F_SECONDARY) &&
 			    ifa1->ifa_scope <= ifa->ifa_scope)
 				last_prim = ifa;
@@ -364,6 +367,9 @@ static int __inet_insert_ifa(struct in_i
 			}
 			ifa->ifa_flags |= IFA_F_SECONDARY;
 		}
+		trace_mark(net_insert_ifa_ipv4, "label %s address #4u%lu",
+			ifa->ifa_label,
+			(unsigned long)ifa->ifa_address);
 	}
 
 	if (!(ifa->ifa_flags & IFA_F_SECONDARY)) {
Index: linux-2.6-lttng/net/socket.c
===================================================================
--- linux-2.6-lttng.orig/net/socket.c	2008-03-27 07:26:26.000000000 -0400
+++ linux-2.6-lttng/net/socket.c	2008-03-27 07:31:57.000000000 -0400
@@ -85,6 +85,7 @@
 #include <linux/audit.h>
 #include <linux/wireless.h>
 #include <linux/nsproxy.h>
+#include <linux/marker.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -567,6 +568,11 @@ int sock_sendmsg(struct socket *sock, st
 	struct sock_iocb siocb;
 	int ret;
 
+	trace_mark(net_socket_sendmsg,
+		"sock %p family %d type %d protocol %d size %zu",
+		sock, sock->sk->sk_family, sock->sk->sk_type,
+		sock->sk->sk_protocol, size);
+
 	init_sync_kiocb(&iocb, NULL);
 	iocb.private = &siocb;
 	ret = __sock_sendmsg(&iocb, sock, msg, size);
@@ -650,7 +656,13 @@ int sock_recvmsg(struct socket *sock, st
 	struct sock_iocb siocb;
 	int ret;
 
+	trace_mark(net_socket_recvmsg,
+		"sock %p family %d type %d protocol %d size %zu",
+		sock, sock->sk->sk_family, sock->sk->sk_type,
+		sock->sk->sk_protocol, size);
+
 	init_sync_kiocb(&iocb, NULL);
+
 	iocb.private = &siocb;
 	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
 	if (-EIOCBQUEUED == ret)
@@ -1226,6 +1238,11 @@ asmlinkage long sys_socket(int family, i
 	if (retval < 0)
 		goto out_release;
 
+	trace_mark(net_socket_create,
+		"sock %p family %d type %d protocol %d fd %d",
+		sock, sock->sk->sk_family, sock->sk->sk_type,
+		sock->sk->sk_protocol, retval);
+
 out:
 	/* It may be already another descriptor 8) Not kernel problem. */
 	return retval;
@@ -2024,6 +2041,8 @@ asmlinkage long sys_socketcall(int call,
 	a0 = a[0];
 	a1 = a[1];
 
+	trace_mark(net_socket_call, "call %d a0 %lu", call, a0);
+
 	switch (call) {
 	case SYS_SOCKET:
 		err = sys_socket(a0, a1, a[2]);

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
