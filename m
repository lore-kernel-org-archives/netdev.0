From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Tue, 05 Apr 2005 12:54:49 -0700
Message-ID: <1112730889.16753.17.camel@beastie>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-wt3BO+/wnxxAUXk5BZ75"
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-wt3BO+/wnxxAUXk5BZ75
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This patch provides:

* new event for unicast connections NETLINK_UESTABLISHED.

* netlink alloc_skb() now uses sk_allocation instead of hard-coded
GFP_KERNEL

* since netlink event described via proto and pid,
netlink_getsockbypid() is exported, so netlink user can identify socket.

Signed-off-by: Dmitry Yusupov <dmitry_yus@yahoo.com>

--=-wt3BO+/wnxxAUXk5BZ75
Content-Disposition: attachment; filename=netlink_uestablish_event.patch
Content-Type: text/x-patch; name=netlink_uestablish_event.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- linux-2.6.11-um/net/netlink/af_netlink.c	2005-04-05 12:40:33.000000000 -0700
+++ linux-2.6.11.orig/net/netlink/af_netlink.c	2005-03-01 23:38:09.000000000 -0800
@@ -467,14 +467,8 @@
 			return err;
 	}
 
-	if (!nladdr->nl_groups && !nlk->groups) {
-		struct netlink_notify n = {
-						.protocol = sk->sk_protocol,
-						.pid = nladdr->nl_pid,
-					  };
-		notifier_call_chain(&netlink_chain, NETLINK_UESTABLISHED, &n);
+	if (!nladdr->nl_groups && !nlk->groups)
 		return 0;
-	}
 
 	netlink_table_grab();
 	if (nlk->groups && !nladdr->nl_groups)
@@ -510,6 +504,7 @@
 
 	if (!nlk->pid)
 		err = netlink_autobind(sock);
+
 	if (err == 0) {
 		sk->sk_state	= NETLINK_CONNECTED;
 		nlk->dst_pid 	= nladdr->nl_pid;
@@ -547,7 +542,7 @@
 	}
 }
 
-struct sock *netlink_getsockbypid(struct sock *ssk, u32 pid)
+static struct sock *netlink_getsockbypid(struct sock *ssk, u32 pid)
 {
 	int protocol = ssk->sk_protocol;
 	struct sock *sock;
@@ -925,7 +920,7 @@
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
 	err = -ENOBUFS;
-	skb = alloc_skb(len, sk->sk_allocation);
+	skb = alloc_skb(len, GFP_KERNEL);
 	if (skb==NULL)
 		goto out;
 
@@ -1184,7 +1179,7 @@
 	else
 		size = NLMSG_SPACE(4 + NLMSG_ALIGN(nlh->nlmsg_len));
 
-	skb = alloc_skb(size, in_skb->sk->sk_allocation);
+	skb = alloc_skb(size, GFP_KERNEL);
 	if (!skb) {
 		struct sock *sk;
 
@@ -1470,5 +1465,4 @@
 EXPORT_SYMBOL(netlink_set_nonroot);
 EXPORT_SYMBOL(netlink_unicast);
 EXPORT_SYMBOL(netlink_unregister_notifier);
-EXPORT_SYMBOL(netlink_getsockbypid);
 
--- linux-2.6.11-um/include/linux/notifier.h	2005-04-05 12:30:10.000000000 -0700
+++ linux-2.6.11.orig/include/linux/notifier.h	2005-03-01 23:37:48.000000000 -0800
@@ -62,15 +62,14 @@
 #define SYS_HALT	0x0002	/* Notify of system halt */
 #define SYS_POWER_OFF	0x0003	/* Notify of system power off */
 
-#define NETLINK_UESTABLISHED	0x0001	/* Unicast netlink socket established */
-#define NETLINK_URELEASE	0x0002	/* Unicast netlink socket released */
+#define NETLINK_URELEASE	0x0001	/* Unicast netlink socket released */
 
-#define CPU_ONLINE		0x0003 /* CPU (unsigned)v is up */
-#define CPU_UP_PREPARE		0x0004 /* CPU (unsigned)v coming up */
-#define CPU_UP_CANCELED		0x0005 /* CPU (unsigned)v NOT coming up */
-#define CPU_DOWN_PREPARE	0x0006 /* CPU (unsigned)v going down */
-#define CPU_DOWN_FAILED		0x0007 /* CPU (unsigned)v NOT going down */
-#define CPU_DEAD		0x0008 /* CPU (unsigned)v dead */
+#define CPU_ONLINE		0x0002 /* CPU (unsigned)v is up */
+#define CPU_UP_PREPARE		0x0003 /* CPU (unsigned)v coming up */
+#define CPU_UP_CANCELED		0x0004 /* CPU (unsigned)v NOT coming up */
+#define CPU_DOWN_PREPARE	0x0005 /* CPU (unsigned)v going down */
+#define CPU_DOWN_FAILED		0x0006 /* CPU (unsigned)v NOT going down */
+#define CPU_DEAD		0x0007 /* CPU (unsigned)v dead */
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_NOTIFIER_H */
--- linux-2.6.11-um/include/linux/netlink.h	2005-04-05 11:35:15.000000000 -0700
+++ linux-2.6.11.orig/include/linux/netlink.h	2005-03-01 23:38:25.000000000 -0800
@@ -124,7 +124,6 @@
 extern void netlink_set_err(struct sock *ssk, __u32 pid, __u32 group, int code);
 extern int netlink_register_notifier(struct notifier_block *nb);
 extern int netlink_unregister_notifier(struct notifier_block *nb);
-extern struct sock *netlink_getsockbypid(struct sock *ssk, u32 pid);
 
 /* finegrained unicast helpers: */
 struct sock *netlink_getsockbyfilp(struct file *filp);

--=-wt3BO+/wnxxAUXk5BZ75--
