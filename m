From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH -net-2.6.19] net/*: don't panic
Date: Tue, 29 Aug 2006 07:50:43 +0400
Message-ID: <20060829034443.GB5192@martell.zuzino.mipt.ru>
References: <20060826230841.GA5204@martell.zuzino.mipt.ru> <20060828093651.GA31341@infradead.org> <20060828.133637.107685776.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:30043 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751076AbWH2Dv2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 23:51:28 -0400
Received: by nf-out-0910.google.com with SMTP id x30so92828nfb
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 20:51:17 -0700 (PDT)
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060828.133637.107685776.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPv6 can be modular and panicking on module loading is the last thing
you want.

Two SLAB_PANIC cases converted to error propagating as well as one
panic() call.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 I recall release is near, so error handling continues to suck. It needs
 big revamp anyway. init functions returning void. functions simply dropping
 -E... Partly shared with IPv4 :-(

 One more question: how can one unload ipv6? it seems to immediately get
 8 users here no matter what.

 include/net/ip6_fib.h   |    2 +-
 include/net/ip6_route.h |    2 +-
 include/net/transp_v6.h |    2 +-
 net/ipv6/af_inet6.c     |    6 +++++-
 net/ipv6/ip6_fib.c      |    8 +++++---
 net/ipv6/route.c        |   14 +++++++++++---
 net/ipv6/tcp_ipv6.c     |   19 ++++++++++++++-----
 7 files changed, 38 insertions(+), 15 deletions(-)

--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -210,7 +210,7 @@ extern void			fib6_run_gc(unsigned long 
 
 extern void			fib6_gc_cleanup(void);
 
-extern void			fib6_init(void);
+extern int			fib6_init(void);
 
 extern void			fib6_rules_init(void);
 extern void			fib6_rules_cleanup(void);
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -59,7 +59,7 @@ extern struct dst_entry *	ip6_route_outp
 
 extern int			ip6_route_me_harder(struct sk_buff *skb);
 
-extern void			ip6_route_init(void);
+extern int			ip6_route_init(void);
 extern void			ip6_route_cleanup(void);
 
 extern int			ipv6_route_ioctl(unsigned int cmd, void __user *arg);
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -24,7 +24,7 @@ extern void				ipv6_destopt_init(void);
 /* transport protocols */
 extern void				rawv6_init(void);
 extern void				udpv6_init(void);
-extern void				tcpv6_init(void);
+extern int				tcpv6_init(void);
 
 extern int				udpv6_connect(struct sock *sk,
 						      struct sockaddr *uaddr,
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -863,13 +863,17 @@ #endif
 
 	/* Init v6 transport protocols. */
 	udpv6_init();
-	tcpv6_init();
+	err = tcpv6_init();
+	if (err)
+		goto tcpv6_init_fail;
 
 	ipv6_packet_init();
 	err = 0;
 out:
 	return err;
 
+tcpv6_init_fail:
+	addrconf_cleanup();
 addrconf_fail:
 	ip6_flowlabel_cleanup();
 	ip6_route_cleanup();
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1468,14 +1468,16 @@ void fib6_run_gc(unsigned long dummy)
 	spin_unlock_bh(&fib6_gc_lock);
 }
 
-void __init fib6_init(void)
+int __init fib6_init(void)
 {
 	fib6_node_kmem = kmem_cache_create("fib6_nodes",
 					   sizeof(struct fib6_node),
-					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+					   0, SLAB_HWCACHE_ALIGN,
 					   NULL, NULL);
-
+	if (!fib6_node_kmem)
+		return -ENOMEM;
 	fib6_tables_init();
+	return 0;
 }
 
 void fib6_gc_cleanup(void)
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2411,14 +2411,21 @@ ctl_table ipv6_route_table[] = {
 
 #endif
 
-void __init ip6_route_init(void)
+int __init ip6_route_init(void)
 {
 	struct proc_dir_entry *p;
+	int rv;
 
 	ip6_dst_ops.kmem_cachep =
 		kmem_cache_create("ip6_dst_cache", sizeof(struct rt6_info), 0,
-				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
-	fib6_init();
+				  SLAB_HWCACHE_ALIGN, NULL, NULL);
+	if (!ip6_dst_ops.kmem_cachep)
+		return -ENOMEM;
+	rv = fib6_init();
+	if (rv < 0) {
+		kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
+		return rv;
+	}
 #ifdef 	CONFIG_PROC_FS
 	p = proc_net_create("ipv6_route", 0, rt6_proc_info);
 	if (p)
@@ -2432,6 +2439,7 @@ #endif
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	fib6_rules_init();
 #endif
+	return 0;
 }
 
 void ip6_route_cleanup(void)
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1644,14 +1644,23 @@ static struct inet_protosw tcpv6_protosw
 				INET_PROTOSW_ICSK,
 };
 
-void __init tcpv6_init(void)
+int __init tcpv6_init(void)
 {
+	int rv;
+
 	/* register inet6 protocol */
-	if (inet6_add_protocol(&tcpv6_protocol, IPPROTO_TCP) < 0)
+	rv = inet6_add_protocol(&tcpv6_protocol, IPPROTO_TCP);
+	if (rv < 0) {
 		printk(KERN_ERR "tcpv6_init: Could not register protocol\n");
+		return rv;
+	}
 	inet6_register_protosw(&tcpv6_protosw);
 
-	if (inet_csk_ctl_sock_create(&tcp6_socket, PF_INET6, SOCK_RAW,
-				     IPPROTO_TCP) < 0)
-		panic("Failed to create the TCPv6 control socket.\n");
+	rv = inet_csk_ctl_sock_create(&tcp6_socket, PF_INET6, SOCK_RAW,
+				      IPPROTO_TCP);
+	if (rv < 0) {
+		inet6_unregister_protosw(&tcpv6_protosw);
+		inet6_del_protocol(&tcpv6_protocol, IPPROTO_TCP);
+	}
+	return rv;
 }

