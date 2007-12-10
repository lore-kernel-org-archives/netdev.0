From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 2/5] ipv6:  make extended headers to return an error at initialization
Date: Mon, 10 Dec 2007 16:09:12 +0100
Message-ID: <20071210151431.005904948@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071210150910.440970057@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:12809 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbXLJPRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 10:17:42 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id lBAFHcm2055334
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:17:38 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBAFHcTT905462
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 16:17:38 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBAFHcRb021303
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 16:17:38 +0100
Content-Disposition: inline; filename=make-ip6-exthdrs-init-return-an-error.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch factorize the code for the differents init functions for rthdr,
nodata, destopt in a single function exthdrs_init.
This function returns an error so the af_inet6 module can check correctly
the initialization.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/transp_v6.h |    5 +--
 net/ipv6/af_inet6.c     |   10 +++++--
 net/ipv6/exthdrs.c      |   64 +++++++++++++++++++++++++++++-------------------
 3 files changed, 48 insertions(+), 31 deletions(-)

Index: net-2.6.25/include/net/transp_v6.h
===================================================================
--- net-2.6.25.orig/include/net/transp_v6.h
+++ net-2.6.25/include/net/transp_v6.h
@@ -17,10 +17,9 @@ extern struct proto tcpv6_prot;
 struct flowi;
 
 /* extention headers */
-extern void				ipv6_rthdr_init(void);
+extern int				ipv6_exthdrs_init(void);
+extern void				ipv6_exthdrs_exit(void);
 extern void				ipv6_frag_init(void);
-extern void				ipv6_nodata_init(void);
-extern void				ipv6_destopt_init(void);
 
 /* transport protocols */
 extern void				rawv6_init(void);
Index: net-2.6.25/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/af_inet6.c
+++ net-2.6.25/net/ipv6/af_inet6.c
@@ -859,10 +859,11 @@ static int __init inet6_init(void)
 		goto addrconf_fail;
 
 	/* Init v6 extension headers. */
-	ipv6_rthdr_init();
+	err = ipv6_exthdrs_init();
+	if (err)
+		goto ipv6_exthdrs_fail;
+
 	ipv6_frag_init();
-	ipv6_nodata_init();
-	ipv6_destopt_init();
 
 	/* Init v6 transport protocols. */
 	udpv6_init();
@@ -874,6 +875,8 @@ static int __init inet6_init(void)
 out:
 	return err;
 
+ipv6_exthdrs_fail:
+	addrconf_cleanup();
 addrconf_fail:
 	ip6_flowlabel_cleanup();
 ip6_flowlabel_fail:
@@ -932,6 +935,7 @@ static void __exit inet6_exit(void)
 	/* Cleanup code parts. */
 	ipv6_packet_cleanup();
 
+	ipv6_exthdrs_exit();
 	addrconf_cleanup();
 	ip6_flowlabel_cleanup();
 	ip6_route_cleanup();
Index: net-2.6.25/net/ipv6/exthdrs.c
===================================================================
--- net-2.6.25.orig/net/ipv6/exthdrs.c
+++ net-2.6.25/net/ipv6/exthdrs.c
@@ -308,28 +308,6 @@ static int ipv6_destopt_rcv(struct sk_bu
 	return -1;
 }
 
-static struct inet6_protocol destopt_protocol = {
-	.handler	=	ipv6_destopt_rcv,
-	.flags		=	INET6_PROTO_NOPOLICY | INET6_PROTO_GSO_EXTHDR,
-};
-
-void __init ipv6_destopt_init(void)
-{
-	if (inet6_add_protocol(&destopt_protocol, IPPROTO_DSTOPTS) < 0)
-		printk(KERN_ERR "ipv6_destopt_init: Could not register protocol\n");
-}
-
-static struct inet6_protocol nodata_protocol = {
-	.handler	=	dst_discard,
-	.flags		=	INET6_PROTO_NOPOLICY,
-};
-
-void __init ipv6_nodata_init(void)
-{
-	if (inet6_add_protocol(&nodata_protocol, IPPROTO_NONE) < 0)
-		printk(KERN_ERR "ipv6_nodata_init: Could not register protocol\n");
-}
-
 /********************************
   Routing header.
  ********************************/
@@ -527,12 +505,48 @@ static struct inet6_protocol rthdr_proto
 	.flags		=	INET6_PROTO_NOPOLICY | INET6_PROTO_GSO_EXTHDR,
 };
 
-void __init ipv6_rthdr_init(void)
+static struct inet6_protocol destopt_protocol = {
+	.handler	=	ipv6_destopt_rcv,
+	.flags		=	INET6_PROTO_NOPOLICY | INET6_PROTO_GSO_EXTHDR,
+};
+
+static struct inet6_protocol nodata_protocol = {
+	.handler	=	dst_discard,
+	.flags		=	INET6_PROTO_NOPOLICY,
+};
+
+int __init ipv6_exthdrs_init(void)
 {
-	if (inet6_add_protocol(&rthdr_protocol, IPPROTO_ROUTING) < 0)
-		printk(KERN_ERR "ipv6_rthdr_init: Could not register protocol\n");
+	int ret;
+
+	ret = inet6_add_protocol(&rthdr_protocol, IPPROTO_ROUTING);
+	if (ret)
+		goto out;
+
+	ret = inet6_add_protocol(&destopt_protocol, IPPROTO_DSTOPTS);
+	if (ret)
+		goto out_rthdr;
+
+	ret = inet6_add_protocol(&nodata_protocol, IPPROTO_NONE);
+	if (ret)
+		goto out_destopt;
+
+out:
+	return ret;
+out_rthdr:
+	inet6_del_protocol(&rthdr_protocol, IPPROTO_ROUTING);
+out_destopt:
+	inet6_del_protocol(&destopt_protocol, IPPROTO_DSTOPTS);
+	goto out;
 };
 
+void ipv6_exthdrs_exit(void)
+{
+	inet6_del_protocol(&nodata_protocol, IPPROTO_NONE);
+	inet6_del_protocol(&destopt_protocol, IPPROTO_DSTOPTS);
+	inet6_del_protocol(&rthdr_protocol, IPPROTO_ROUTING);
+}
+
 /**********************************
   Hop-by-hop options.
  **********************************/

-- 
