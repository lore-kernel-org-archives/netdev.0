From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] Re: rtnetlink interface state monitoring problems.
Date: Thu, 24 Oct 2002 13:41:36 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210241339420.12092-100000@blackbird.intercode.com.au>
References: <1035219674.4817.5.camel@rth.ninka.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Woodhouse <dwmw2@infradead.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@rth.ninka.net>
In-Reply-To: <1035219674.4817.5.camel@rth.ninka.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 21 Oct 2002, David S. Miller wrote:

> On Mon, 2002-10-21 at 06:48, James Morris wrote:
> > Forgot to add that it might be possible to get Andi's solution into 2.6.
> 
> Send me the patch for 2.5.x
> 

Patch below, for 2.5.44.

- James
-- 
James Morris
<jmorris@intercode.com.au>

diff -urN -X dontdiff linux-2.5.44.orig/include/linux/netlink.h linux-2.5.44.w1/include/linux/netlink.h
--- linux-2.5.44.orig/include/linux/netlink.h	Fri Aug  2 07:16:34 2002
+++ linux-2.5.44.w1/include/linux/netlink.h	Thu Oct 24 13:24:33 2002
@@ -162,6 +162,10 @@
 			      int (*done)(struct netlink_callback*));
 
 
+#define NL_NONROOT_RECV 0x1
+#define NL_NONROOT_SEND 0x2
+extern void netlink_set_nonroot(int protocol, unsigned flag);
+
 #endif /* __KERNEL__ */
 
 #endif	/* __LINUX_NETLINK_H */
diff -urN -X dontdiff linux-2.5.44.orig/net/core/rtnetlink.c linux-2.5.44.w1/net/core/rtnetlink.c
--- linux-2.5.44.orig/net/core/rtnetlink.c	Fri Aug  2 07:17:32 2002
+++ linux-2.5.44.w1/net/core/rtnetlink.c	Thu Oct 24 13:25:35 2002
@@ -523,6 +523,7 @@
 	rtnl = netlink_kernel_create(NETLINK_ROUTE, rtnetlink_rcv);
 	if (rtnl == NULL)
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");
+	netlink_set_nonroot(NETLINK_ROUTE, NL_NONROOT_RECV);
 	register_netdevice_notifier(&rtnetlink_dev_notifier);
 	rtnetlink_links[PF_UNSPEC] = link_rtnetlink_table;
 	rtnetlink_links[PF_PACKET] = link_rtnetlink_table;
diff -urN -X dontdiff linux-2.5.44.orig/net/netlink/af_netlink.c linux-2.5.44.w1/net/netlink/af_netlink.c
--- linux-2.5.44.orig/net/netlink/af_netlink.c	Wed Oct 16 17:45:49 2002
+++ linux-2.5.44.w1/net/netlink/af_netlink.c	Thu Oct 24 13:28:58 2002
@@ -69,6 +69,7 @@
 
 static struct sock *nl_table[MAX_LINKS];
 static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
+static unsigned nl_nonroot[MAX_LINKS];
 
 #ifdef NL_EMULATE_DEV
 static struct socket *netlink_kernel[MAX_LINKS];
@@ -317,6 +318,11 @@
 	return 0;
 }
 
+static inline int netlink_capable(struct socket *sock, unsigned flag) 
+{ 
+	return (nl_nonroot[sock->sk->protocol] & flag) || capable(CAP_NET_ADMIN);
+} 
+
 static int netlink_bind(struct socket *sock, struct sockaddr *addr, int addr_len)
 {
 	struct sock *sk = sock->sk;
@@ -328,7 +334,7 @@
 		return -EINVAL;
 
 	/* Only superuser is allowed to listen multicasts */
-	if (nladdr->nl_groups && !capable(CAP_NET_ADMIN))
+	if (nladdr->nl_groups && !netlink_capable(sock, NL_NONROOT_RECV))
 		return -EPERM;
 
 	if (nlk->pid) {
@@ -368,7 +374,7 @@
 		return -EINVAL;
 
 	/* Only superuser is allowed to send multicasts */
-	if (nladdr->nl_groups && !capable(CAP_NET_ADMIN))
+	if (nladdr->nl_groups && !netlink_capable(sock, NL_NONROOT_SEND))
 		return -EPERM;
 
 	if (!nlk->pid)
@@ -590,7 +596,7 @@
 			return -EINVAL;
 		dst_pid = addr->nl_pid;
 		dst_groups = addr->nl_groups;
-		if (dst_groups && !capable(CAP_NET_ADMIN))
+		if (dst_groups && !netlink_capable(sock, NL_NONROOT_SEND))
 			return -EPERM;
 	} else {
 		dst_pid = nlk->dst_pid;
@@ -743,6 +749,12 @@
 	return sk;
 }
 
+void netlink_set_nonroot(int protocol, unsigned flags)
+{ 
+	if ((unsigned)protocol < MAX_LINKS) 
+		nl_nonroot[protocol] = flags;
+} 
+
 static void netlink_destroy_callback(struct netlink_callback *cb)
 {
 	if (cb->skb)
diff -urN -X dontdiff linux-2.5.44.orig/net/netsyms.c linux-2.5.44.w1/net/netsyms.c
--- linux-2.5.44.orig/net/netsyms.c	Sat Oct 19 19:57:49 2002
+++ linux-2.5.44.w1/net/netsyms.c	Thu Oct 24 13:29:22 2002
@@ -411,6 +411,7 @@
 EXPORT_SYMBOL(netlink_kernel_create);
 EXPORT_SYMBOL(netlink_dump_start);
 EXPORT_SYMBOL(netlink_ack);
+EXPORT_SYMBOL(netlink_set_nonroot);
 EXPORT_SYMBOL(netlink_register_notifier);
 EXPORT_SYMBOL(netlink_unregister_notifier);
 #if defined(CONFIG_NETLINK_DEV) || defined(CONFIG_NETLINK_DEV_MODULE)
