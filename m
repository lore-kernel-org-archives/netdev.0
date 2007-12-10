From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 3/5] ipv6:  make frag to return an error at initialization
Date: Mon, 10 Dec 2007 16:09:13 +0100
Message-ID: <20071210151434.595423844@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071210150910.440970057@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:24775 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbXLJPSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 10:18:16 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lBAFIFIQ105716
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:18:15 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBAFIEOp4440246
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:18:14 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBAFHsMm011484
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:17:58 GMT
Content-Disposition: inline; filename=make-ip6-frag-init-return-an-error.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the frag_init to return an error code, so the af_inet6
module can handle the error.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/transp_v6.h |    3 ++-
 net/ipv6/af_inet6.c     |    8 ++++++--
 net/ipv6/reassembly.c   |   16 +++++++++++++---
 3 files changed, 21 insertions(+), 6 deletions(-)

Index: net-2.6.25/include/net/transp_v6.h
===================================================================
--- net-2.6.25.orig/include/net/transp_v6.h
+++ net-2.6.25/include/net/transp_v6.h
@@ -19,7 +19,8 @@ struct flowi;
 /* extention headers */
 extern int				ipv6_exthdrs_init(void);
 extern void				ipv6_exthdrs_exit(void);
-extern void				ipv6_frag_init(void);
+extern int				ipv6_frag_init(void);
+extern void				ipv6_frag_exit(void);
 
 /* transport protocols */
 extern void				rawv6_init(void);
Index: net-2.6.25/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/af_inet6.c
+++ net-2.6.25/net/ipv6/af_inet6.c
@@ -863,7 +863,9 @@ static int __init inet6_init(void)
 	if (err)
 		goto ipv6_exthdrs_fail;
 
-	ipv6_frag_init();
+	err = ipv6_frag_init();
+	if (err)
+		goto ipv6_frag_fail;
 
 	/* Init v6 transport protocols. */
 	udpv6_init();
@@ -875,6 +877,8 @@ static int __init inet6_init(void)
 out:
 	return err;
 
+ipv6_frag_fail:
+	ipv6_exthdrs_exit();
 ipv6_exthdrs_fail:
 	addrconf_cleanup();
 addrconf_fail:
@@ -934,7 +938,7 @@ static void __exit inet6_exit(void)
 
 	/* Cleanup code parts. */
 	ipv6_packet_cleanup();
-
+	ipv6_frag_exit();
 	ipv6_exthdrs_exit();
 	addrconf_cleanup();
 	ip6_flowlabel_cleanup();
Index: net-2.6.25/net/ipv6/reassembly.c
===================================================================
--- net-2.6.25.orig/net/ipv6/reassembly.c
+++ net-2.6.25/net/ipv6/reassembly.c
@@ -632,11 +632,13 @@ static struct inet6_protocol frag_protoc
 	.flags		=	INET6_PROTO_NOPOLICY,
 };
 
-void __init ipv6_frag_init(void)
+int __init ipv6_frag_init(void)
 {
-	if (inet6_add_protocol(&frag_protocol, IPPROTO_FRAGMENT) < 0)
-		printk(KERN_ERR "ipv6_frag_init: Could not register protocol\n");
+	int ret;
 
+	ret = inet6_add_protocol(&frag_protocol, IPPROTO_FRAGMENT);
+	if (ret)
+		goto out;
 	ip6_frags.ctl = &ip6_frags_ctl;
 	ip6_frags.hashfn = ip6_hashfn;
 	ip6_frags.constructor = ip6_frag_init;
@@ -646,4 +648,12 @@ void __init ipv6_frag_init(void)
 	ip6_frags.match = ip6_frag_match;
 	ip6_frags.frag_expire = ip6_frag_expire;
 	inet_frags_init(&ip6_frags);
+out:
+	return ret;
+}
+
+void ipv6_frag_exit(void)
+{
+	inet_frags_fini(&ip6_frags);
+	inet6_del_protocol(&frag_protocol, IPPROTO_FRAGMENT);
 }

-- 
