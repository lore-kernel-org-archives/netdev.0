From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Tue, 05 Apr 2005 17:13:31 -0700
Message-ID: <1112746411.16753.29.camel@beastie>
References: <1112730889.16753.17.camel@beastie> <4253059C.1080000@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-sXHSrktl3TjxUojfEjC1"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
In-Reply-To: <4253059C.1080000@6wind.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-sXHSrktl3TjxUojfEjC1
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

resend.

On Tue, 2005-04-05 at 23:39 +0200, Jean-Mickael Guerin wrote:
> Dmitry Yusupov wrote:
> > This patch provides:
> > 
> > * new event for unicast connections NETLINK_UESTABLISHED.
> 
> Which kind of application takes benefit of this event ?
> 
> btw your diff is reversed ;-)
> 
> Jean-Mickael
> 

--=-sXHSrktl3TjxUojfEjC1
Content-Disposition: attachment; filename=netlink_uestablish_event.patch
Content-Type: text/x-patch; name=netlink_uestablish_event.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- linux-2.6.11.orig/net/netlink/af_netlink.c	2005-03-01 23:38:09.000000000 -0800
+++ linux-2.6.11-um/net/netlink/af_netlink.c	2005-04-05 12:40:33.000000000 -0700
@@ -467,8 +467,14 @@
 			return err;
 	}
 
-	if (!nladdr->nl_groups && !nlk->groups)
+	if (!nladdr->nl_groups && !nlk->groups) {
+		struct netlink_notify n = {
+						.protocol = sk->sk_protocol,
+						.pid = nladdr->nl_pid,
+					  };
+		notifier_call_chain(&netlink_chain, NETLINK_UESTABLISHED, &n);
 		return 0;
+	}
 
 	netlink_table_grab();
 	if (nlk->groups && !nladdr->nl_groups)
@@ -504,7 +510,6 @@
 
 	if (!nlk->pid)
 		err = netlink_autobind(sock);
-
 	if (err == 0) {
 		sk->sk_state	= NETLINK_CONNECTED;
 		nlk->dst_pid 	= nladdr->nl_pid;
@@ -542,7 +547,7 @@
 	}
 }
 
-static struct sock *netlink_getsockbypid(struct sock *ssk, u32 pid)
+struct sock *netlink_getsockbypid(struct sock *ssk, u32 pid)
 {
 	int protocol = ssk->sk_protocol;
 	struct sock *sock;
@@ -920,7 +925,7 @@
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
 	err = -ENOBUFS;
-	skb = alloc_skb(len, GFP_KERNEL);
+	skb = alloc_skb(len, sk->sk_allocation);
 	if (skb==NULL)
 		goto out;
 
@@ -1179,7 +1184,7 @@
 	else
 		size = NLMSG_SPACE(4 + NLMSG_ALIGN(nlh->nlmsg_len));
 
-	skb = alloc_skb(size, GFP_KERNEL);
+	skb = alloc_skb(size, in_skb->sk->sk_allocation);
 	if (!skb) {
 		struct sock *sk;
 
@@ -1465,4 +1470,5 @@
 EXPORT_SYMBOL(netlink_set_nonroot);
 EXPORT_SYMBOL(netlink_unicast);
 EXPORT_SYMBOL(netlink_unregister_notifier);
+EXPORT_SYMBOL(netlink_getsockbypid);
 
--- linux-2.6.11.orig/include/linux/notifier.h	2005-03-01 23:37:48.000000000 -0800
+++ linux-2.6.11-um/include/linux/notifier.h	2005-04-05 12:30:10.000000000 -0700
@@ -62,14 +62,15 @@
 #define SYS_HALT	0x0002	/* Notify of system halt */
 #define SYS_POWER_OFF	0x0003	/* Notify of system power off */
 
-#define NETLINK_URELEASE	0x0001	/* Unicast netlink socket released */
+#define NETLINK_UESTABLISHED	0x0001	/* Unicast netlink socket established */
+#define NETLINK_URELEASE	0x0002	/* Unicast netlink socket released */
 
-#define CPU_ONLINE		0x0002 /* CPU (unsigned)v is up */
-#define CPU_UP_PREPARE		0x0003 /* CPU (unsigned)v coming up */
-#define CPU_UP_CANCELED		0x0004 /* CPU (unsigned)v NOT coming up */
-#define CPU_DOWN_PREPARE	0x0005 /* CPU (unsigned)v going down */
-#define CPU_DOWN_FAILED		0x0006 /* CPU (unsigned)v NOT going down */
-#define CPU_DEAD		0x0007 /* CPU (unsigned)v dead */
+#define CPU_ONLINE		0x0003 /* CPU (unsigned)v is up */
+#define CPU_UP_PREPARE		0x0004 /* CPU (unsigned)v coming up */
+#define CPU_UP_CANCELED		0x0005 /* CPU (unsigned)v NOT coming up */
+#define CPU_DOWN_PREPARE	0x0006 /* CPU (unsigned)v going down */
+#define CPU_DOWN_FAILED		0x0007 /* CPU (unsigned)v NOT going down */
+#define CPU_DEAD		0x0008 /* CPU (unsigned)v dead */
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_NOTIFIER_H */
--- linux-2.6.11.orig/include/linux/netlink.h	2005-03-01 23:38:25.000000000 -0800
+++ linux-2.6.11-um/include/linux/netlink.h	2005-04-05 11:35:15.000000000 -0700
@@ -124,6 +124,7 @@
 extern void netlink_set_err(struct sock *ssk, __u32 pid, __u32 group, int code);
 extern int netlink_register_notifier(struct notifier_block *nb);
 extern int netlink_unregister_notifier(struct notifier_block *nb);
+extern struct sock *netlink_getsockbypid(struct sock *ssk, u32 pid);
 
 /* finegrained unicast helpers: */
 struct sock *netlink_getsockbyfilp(struct file *filp);

--=-sXHSrktl3TjxUojfEjC1--
