From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 5/5] ipv6:  make the protocol initialization to return an error code
Date: Mon, 10 Dec 2007 16:09:15 +0100
Message-ID: <20071210151440.241406358@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071210150910.440970057@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:12817 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbXLJPRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 10:17:49 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id lBAFHmTh106936
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:17:48 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBAFHlLV2384060
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 16:17:47 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBAFHl5X001512
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 16:17:47 +0100
Content-Disposition: inline; filename=make-protocol-init-to-return-an-error-code.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset makes the different protocols to return an error code, so
the af_inet6 module can check the initialization was correct or not.

The raw6 was taken into account to be consistent with the rest of the
protocols, but the registration is at the same place.
Because the raw6 has its own init function, the proto and the ops structure
can be moved inside the raw6.c file.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ipv6.h       |    2 -
 include/net/transp_v6.h  |   12 ++++---
 net/ipv6/af_inet6.c      |   77 ++++++++++++++++++++---------------------------
 net/ipv6/ipv6_sockglue.c |    3 +
 net/ipv6/raw.c           |   52 +++++++++++++++++++++++++++++++
 net/ipv6/tcp_ipv6.c      |   38 ++++++++++++++++++-----
 net/ipv6/udp.c           |   26 +++++++++++++--
 net/ipv6/udplite.c       |   25 ++++++++++++---
 8 files changed, 169 insertions(+), 66 deletions(-)

Index: net-2.6.25/include/net/transp_v6.h
===================================================================
--- net-2.6.25.orig/include/net/transp_v6.h
+++ net-2.6.25/include/net/transp_v6.h
@@ -23,10 +23,14 @@ extern int				ipv6_frag_init(void);
 extern void				ipv6_frag_exit(void);
 
 /* transport protocols */
-extern void				rawv6_init(void);
-extern void				udpv6_init(void);
-extern void 				udplitev6_init(void);
-extern void				tcpv6_init(void);
+extern int				rawv6_init(void);
+extern void				rawv6_exit(void);
+extern int				udpv6_init(void);
+extern void				udpv6_exit(void);
+extern int 				udplitev6_init(void);
+extern void 				udplitev6_exit(void);
+extern int				tcpv6_init(void);
+extern void				tcpv6_exit(void);
 
 extern int				udpv6_connect(struct sock *sk,
 						      struct sockaddr *uaddr,
Index: net-2.6.25/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/af_inet6.c
+++ net-2.6.25/net/ipv6/af_inet6.c
@@ -529,42 +529,6 @@ static struct net_proto_family inet6_fam
 	.owner	= THIS_MODULE,
 };
 
-/* Same as inet6_dgram_ops, sans udp_poll.  */
-static const struct proto_ops inet6_sockraw_ops = {
-	.family		   = PF_INET6,
-	.owner		   = THIS_MODULE,
-	.release	   = inet6_release,
-	.bind		   = inet6_bind,
-	.connect	   = inet_dgram_connect,	/* ok		*/
-	.socketpair	   = sock_no_socketpair,	/* a do nothing	*/
-	.accept		   = sock_no_accept,		/* a do nothing	*/
-	.getname	   = inet6_getname,
-	.poll		   = datagram_poll,		/* ok		*/
-	.ioctl		   = inet6_ioctl,		/* must change  */
-	.listen		   = sock_no_listen,		/* ok		*/
-	.shutdown	   = inet_shutdown,		/* ok		*/
-	.setsockopt	   = sock_common_setsockopt,	/* ok		*/
-	.getsockopt	   = sock_common_getsockopt,	/* ok		*/
-	.sendmsg	   = inet_sendmsg,		/* ok		*/
-	.recvmsg	   = sock_common_recvmsg,	/* ok		*/
-	.mmap		   = sock_no_mmap,
-	.sendpage	   = sock_no_sendpage,
-#ifdef CONFIG_COMPAT
-	.compat_setsockopt = compat_sock_common_setsockopt,
-	.compat_getsockopt = compat_sock_common_getsockopt,
-#endif
-};
-
-static struct inet_protosw rawv6_protosw = {
-	.type		= SOCK_RAW,
-	.protocol	= IPPROTO_IP,	/* wild card */
-	.prot		= &rawv6_prot,
-	.ops		= &inet6_sockraw_ops,
-	.capability	= CAP_NET_RAW,
-	.no_check	= UDP_CSUM_DEFAULT,
-	.flags		= INET_PROTOSW_REUSE,
-};
-
 int inet6_register_protosw(struct inet_protosw *p)
 {
 	struct list_head *lh;
@@ -771,7 +735,6 @@ static int __init inet6_init(void)
 	__this_module.can_unload = &ipv6_unload;
 #endif
 #endif
-
 	err = proto_register(&tcpv6_prot, 1);
 	if (err)
 		goto out;
@@ -796,14 +759,16 @@ static int __init inet6_init(void)
 	/* We MUST register RAW sockets before we create the ICMP6,
 	 * IGMP6, or NDISC control sockets.
 	 */
-	inet6_register_protosw(&rawv6_protosw);
+	err = rawv6_init();
+	if (err)
+		goto out_unregister_raw_proto;
 
 	/* Register the family here so that the init calls below will
 	 * be able to create sockets. (?? is this dangerous ??)
 	 */
 	err = sock_register(&inet6_family_ops);
 	if (err)
-		goto out_unregister_raw_proto;
+		goto out_sock_register_fail;
 
 	/* Initialise ipv6 mibs */
 	err = init_ipv6_mibs();
@@ -871,15 +836,32 @@ static int __init inet6_init(void)
 		goto ipv6_frag_fail;
 
 	/* Init v6 transport protocols. */
-	udpv6_init();
-	udplitev6_init();
-	tcpv6_init();
+	err = udpv6_init();
+	if (err)
+		goto udpv6_fail;
+
+	err = udplitev6_init();
+	if (err)
+		goto udplitev6_fail;
+
+	err = tcpv6_init();
+	if (err)
+		goto tcpv6_fail;
 
-	ipv6_packet_init();
-	err = 0;
+	err = ipv6_packet_init();
+	if (err)
+		goto ipv6_packet_fail;
 out:
 	return err;
 
+ipv6_packet_fail:
+	tcpv6_exit();
+tcpv6_fail:
+	udplitev6_exit();
+udplitev6_fail:
+	udpv6_exit();
+udpv6_fail:
+	ipv6_frag_exit();
 ipv6_frag_fail:
 	ipv6_exthdrs_exit();
 ipv6_exthdrs_fail:
@@ -920,6 +902,8 @@ icmp_fail:
 out_unregister_sock:
 	sock_unregister(PF_INET6);
 	rtnl_unregister_all(PF_INET6);
+out_sock_register_fail:
+	rawv6_exit();
 out_unregister_raw_proto:
 	proto_unregister(&rawv6_prot);
 out_unregister_udplite_proto:
@@ -939,6 +923,10 @@ static void __exit inet6_exit(void)
 	/* Disallow any further netlink messages */
 	rtnl_unregister_all(PF_INET6);
 
+	udpv6_exit();
+	udplitev6_exit();
+	tcpv6_exit();
+
 	/* Cleanup code parts. */
 	ipv6_packet_cleanup();
 	ipv6_frag_exit();
@@ -961,6 +949,7 @@ static void __exit inet6_exit(void)
 	igmp6_cleanup();
 	ndisc_cleanup();
 	icmpv6_cleanup();
+	rawv6_exit();
 #ifdef CONFIG_SYSCTL
 	ipv6_sysctl_unregister();
 #endif
Index: net-2.6.25/net/ipv6/udp.c
===================================================================
--- net-2.6.25.orig/net/ipv6/udp.c
+++ net-2.6.25/net/ipv6/udp.c
@@ -1016,9 +1016,27 @@ static struct inet_protosw udpv6_protosw
 };
 
 
-void __init udpv6_init(void)
+int __init udpv6_init(void)
 {
-	if (inet6_add_protocol(&udpv6_protocol, IPPROTO_UDP) < 0)
-		printk(KERN_ERR "udpv6_init: Could not register protocol\n");
-	inet6_register_protosw(&udpv6_protosw);
+	int ret;
+
+	ret = inet6_add_protocol(&udpv6_protocol, IPPROTO_UDP);
+	if (ret)
+		goto out;
+
+	ret = inet6_register_protosw(&udpv6_protosw);
+	if (ret)
+		goto out_udpv6_protocol;
+out:
+	return ret;
+
+out_udpv6_protocol:
+	inet6_del_protocol(&udpv6_protocol, IPPROTO_UDP);
+	goto out;
+}
+
+void __exit udpv6_exit(void)
+{
+	inet6_unregister_protosw(&udpv6_protosw);
+	inet6_del_protocol(&udpv6_protocol, IPPROTO_UDP);
 }
Index: net-2.6.25/include/net/ipv6.h
===================================================================
--- net-2.6.25.orig/include/net/ipv6.h
+++ net-2.6.25/include/net/ipv6.h
@@ -545,7 +545,7 @@ extern int			compat_ipv6_getsockopt(stru
 						char __user *optval,
 						int __user *optlen);
 
-extern void			ipv6_packet_init(void);
+extern int			ipv6_packet_init(void);
 
 extern void			ipv6_packet_cleanup(void);
 
Index: net-2.6.25/net/ipv6/ipv6_sockglue.c
===================================================================
--- net-2.6.25.orig/net/ipv6/ipv6_sockglue.c
+++ net-2.6.25/net/ipv6/ipv6_sockglue.c
@@ -1130,9 +1130,10 @@ int compat_ipv6_getsockopt(struct sock *
 EXPORT_SYMBOL(compat_ipv6_getsockopt);
 #endif
 
-void __init ipv6_packet_init(void)
+int __init ipv6_packet_init(void)
 {
 	dev_add_pack(&ipv6_packet_type);
+	return 0;
 }
 
 void ipv6_packet_cleanup(void)
Index: net-2.6.25/net/ipv6/raw.c
===================================================================
--- net-2.6.25.orig/net/ipv6/raw.c
+++ net-2.6.25/net/ipv6/raw.c
@@ -1273,3 +1273,55 @@ void raw6_proc_exit(void)
 	proc_net_remove(&init_net, "raw6");
 }
 #endif	/* CONFIG_PROC_FS */
+
+/* Same as inet6_dgram_ops, sans udp_poll.  */
+static const struct proto_ops inet6_sockraw_ops = {
+	.family		   = PF_INET6,
+	.owner		   = THIS_MODULE,
+	.release	   = inet6_release,
+	.bind		   = inet6_bind,
+	.connect	   = inet_dgram_connect,	/* ok		*/
+	.socketpair	   = sock_no_socketpair,	/* a do nothing	*/
+	.accept		   = sock_no_accept,		/* a do nothing	*/
+	.getname	   = inet6_getname,
+	.poll		   = datagram_poll,		/* ok		*/
+	.ioctl		   = inet6_ioctl,		/* must change  */
+	.listen		   = sock_no_listen,		/* ok		*/
+	.shutdown	   = inet_shutdown,		/* ok		*/
+	.setsockopt	   = sock_common_setsockopt,	/* ok		*/
+	.getsockopt	   = sock_common_getsockopt,	/* ok		*/
+	.sendmsg	   = inet_sendmsg,		/* ok		*/
+	.recvmsg	   = sock_common_recvmsg,	/* ok		*/
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = sock_no_sendpage,
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
+#endif
+};
+
+static struct inet_protosw rawv6_protosw = {
+	.type		= SOCK_RAW,
+	.protocol	= IPPROTO_IP,	/* wild card */
+	.prot		= &rawv6_prot,
+	.ops		= &inet6_sockraw_ops,
+	.capability	= CAP_NET_RAW,
+	.no_check	= UDP_CSUM_DEFAULT,
+	.flags		= INET_PROTOSW_REUSE,
+};
+
+int __init rawv6_init(void)
+{
+	int ret;
+
+	ret = inet6_register_protosw(&rawv6_protosw);
+	if (ret)
+		goto out;
+out:
+	return ret;
+}
+
+void __exit rawv6_exit(void)
+{
+	inet6_unregister_protosw(&rawv6_protosw);
+}
Index: net-2.6.25/net/ipv6/tcp_ipv6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/tcp_ipv6.c
+++ net-2.6.25/net/ipv6/tcp_ipv6.c
@@ -2167,14 +2167,36 @@ static struct inet_protosw tcpv6_protosw
 				INET_PROTOSW_ICSK,
 };
 
-void __init tcpv6_init(void)
+int __init tcpv6_init(void)
 {
+	int ret;
+
+	ret = inet6_add_protocol(&tcpv6_protocol, IPPROTO_TCP);
+	if (ret)
+		goto out;
+
 	/* register inet6 protocol */
-	if (inet6_add_protocol(&tcpv6_protocol, IPPROTO_TCP) < 0)
-		printk(KERN_ERR "tcpv6_init: Could not register protocol\n");
-	inet6_register_protosw(&tcpv6_protosw);
-
-	if (inet_csk_ctl_sock_create(&tcp6_socket, PF_INET6, SOCK_RAW,
-				     IPPROTO_TCP) < 0)
-		panic("Failed to create the TCPv6 control socket.\n");
+	ret = inet6_register_protosw(&tcpv6_protosw);
+	if (ret)
+		goto out_tcpv6_protocol;
+
+	ret = inet_csk_ctl_sock_create(&tcp6_socket, PF_INET6,
+				       SOCK_RAW, IPPROTO_TCP);
+	if (ret)
+		goto out_tcpv6_protosw;
+out:
+	return ret;
+
+out_tcpv6_protocol:
+	inet6_del_protocol(&tcpv6_protocol, IPPROTO_TCP);
+out_tcpv6_protosw:
+	inet6_unregister_protosw(&tcpv6_protosw);
+	goto out;
+}
+
+void __exit tcpv6_exit(void)
+{
+	sock_release(tcp6_socket);
+	inet6_unregister_protosw(&tcpv6_protosw);
+	inet6_del_protocol(&tcpv6_protocol, IPPROTO_TCP);
 }
Index: net-2.6.25/net/ipv6/udplite.c
===================================================================
--- net-2.6.25.orig/net/ipv6/udplite.c
+++ net-2.6.25/net/ipv6/udplite.c
@@ -77,12 +77,29 @@ static struct inet_protosw udplite6_prot
 	.flags		= INET_PROTOSW_PERMANENT,
 };
 
-void __init udplitev6_init(void)
+int __init udplitev6_init(void)
 {
-	if (inet6_add_protocol(&udplitev6_protocol, IPPROTO_UDPLITE) < 0)
-		printk(KERN_ERR "%s: Could not register.\n", __FUNCTION__);
+	int ret;
 
-	inet6_register_protosw(&udplite6_protosw);
+	ret = inet6_add_protocol(&udplitev6_protocol, IPPROTO_UDPLITE);
+	if (ret)
+		goto out;
+
+	ret = inet6_register_protosw(&udplite6_protosw);
+	if (ret)
+		goto out_udplitev6_protocol;
+out:
+	return ret;
+
+out_udplitev6_protocol:
+	inet6_del_protocol(&udplitev6_protocol, IPPROTO_UDPLITE);
+	goto out;
+}
+
+void __exit udplitev6_exit(void)
+{
+	inet6_unregister_protosw(&udplite6_protosw);
+	inet6_del_protocol(&udplitev6_protocol, IPPROTO_UDPLITE);
 }
 
 #ifdef CONFIG_PROC_FS

-- 
