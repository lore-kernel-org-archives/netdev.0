From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 2/6] ipv6 - make xfrm6_init to return an error code
Date: Thu, 06 Dec 2007 14:53:31 +0100
Message-ID: <20071206140254.504102655@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071206135329.598202596@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:30545 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbXLFOGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 09:06:53 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id lB6E6GTI049114
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:06:16 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB6E6CsZ4911340
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:06:13 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB6E5fJY004534
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:05:41 GMT
Content-Disposition: inline; filename=xfrm-handle-error-at-init.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xfrm initialization function does not return any error code, so
if there is an error, the caller can not be advise of that.
This patch checks the return code of the different called functions
in order to return a successful or failed initialization.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/xfrm.h      |    4 ++--
 net/ipv6/xfrm6_policy.c |   22 +++++++++++++++++-----
 net/ipv6/xfrm6_state.c  |    4 ++--
 3 files changed, 21 insertions(+), 9 deletions(-)

Index: net-2.6.25/include/net/xfrm.h
===================================================================
--- net-2.6.25.orig/include/net/xfrm.h
+++ net-2.6.25/include/net/xfrm.h
@@ -1066,11 +1066,11 @@ struct xfrm6_tunnel {
 
 extern void xfrm_init(void);
 extern void xfrm4_init(void);
-extern void xfrm6_init(void);
+extern int xfrm6_init(void);
 extern void xfrm6_fini(void);
 extern void xfrm_state_init(void);
 extern void xfrm4_state_init(void);
-extern void xfrm6_state_init(void);
+extern int xfrm6_state_init(void);
 extern void xfrm6_state_fini(void);
 
 extern int xfrm_state_walk(u8 proto, int (*func)(struct xfrm_state *, int, void*), void *);
Index: net-2.6.25/net/ipv6/xfrm6_policy.c
===================================================================
--- net-2.6.25.orig/net/ipv6/xfrm6_policy.c
+++ net-2.6.25/net/ipv6/xfrm6_policy.c
@@ -269,9 +269,9 @@ static struct xfrm_policy_afinfo xfrm6_p
 	.fill_dst =		xfrm6_fill_dst,
 };
 
-static void __init xfrm6_policy_init(void)
+static int __init xfrm6_policy_init(void)
 {
-	xfrm_policy_register_afinfo(&xfrm6_policy_afinfo);
+	return xfrm_policy_register_afinfo(&xfrm6_policy_afinfo);
 }
 
 static void xfrm6_policy_fini(void)
@@ -279,10 +279,22 @@ static void xfrm6_policy_fini(void)
 	xfrm_policy_unregister_afinfo(&xfrm6_policy_afinfo);
 }
 
-void __init xfrm6_init(void)
+int __init xfrm6_init(void)
 {
-	xfrm6_policy_init();
-	xfrm6_state_init();
+	int ret;
+
+	ret = xfrm6_policy_init();
+	if (ret)
+		goto out;
+
+	ret = xfrm6_state_init();
+	if (ret)
+		goto out_policy;
+out:
+	return ret;
+out_policy:
+	xfrm6_policy_fini();
+	goto out;
 }
 
 void xfrm6_fini(void)
Index: net-2.6.25/net/ipv6/xfrm6_state.c
===================================================================
--- net-2.6.25.orig/net/ipv6/xfrm6_state.c
+++ net-2.6.25/net/ipv6/xfrm6_state.c
@@ -198,9 +198,9 @@ static struct xfrm_state_afinfo xfrm6_st
 	.transport_finish	= xfrm6_transport_finish,
 };
 
-void __init xfrm6_state_init(void)
+int __init xfrm6_state_init(void)
 {
-	xfrm_state_register_afinfo(&xfrm6_state_afinfo);
+	return xfrm_state_register_afinfo(&xfrm6_state_afinfo);
 }
 
 void xfrm6_state_fini(void)

-- 
