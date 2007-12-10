From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 4/5] ipv6:  make inet6_register_protosw to return an error code
Date: Mon, 10 Dec 2007 16:09:14 +0100
Message-ID: <20071210151437.362338020@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071210150910.440970057@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:24778 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbXLJPSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 10:18:18 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lBAFIH15105356
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:18:17 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBAFIGsm3682482
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:18:17 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBAFHxMa013721
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:18:00 GMT
Content-Disposition: inline; filename=make-inet6_register_protosw-return-an-error-code.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the inet6_register_protosw to return an error code.
The different protocols can be aware the registration was successful or
not and can pass the error to the initial caller, af_inet6.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/protocol.h |    2 +-
 net/ipv6/af_inet6.c    |   11 +++++++----
 2 files changed, 8 insertions(+), 5 deletions(-)

Index: net-2.6.25/include/net/protocol.h
===================================================================
--- net-2.6.25.orig/include/net/protocol.h
+++ net-2.6.25/include/net/protocol.h
@@ -102,7 +102,7 @@ extern void	inet_unregister_protosw(stru
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
 extern int	inet6_add_protocol(struct inet6_protocol *prot, unsigned char num);
 extern int	inet6_del_protocol(struct inet6_protocol *prot, unsigned char num);
-extern void	inet6_register_protosw(struct inet_protosw *p);
+extern int	inet6_register_protosw(struct inet_protosw *p);
 extern void	inet6_unregister_protosw(struct inet_protosw *p);
 #endif
 
Index: net-2.6.25/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/af_inet6.c
+++ net-2.6.25/net/ipv6/af_inet6.c
@@ -565,21 +565,23 @@ static struct inet_protosw rawv6_protosw
 	.flags		= INET_PROTOSW_REUSE,
 };
 
-void
-inet6_register_protosw(struct inet_protosw *p)
+int inet6_register_protosw(struct inet_protosw *p)
 {
 	struct list_head *lh;
 	struct inet_protosw *answer;
-	int protocol = p->protocol;
 	struct list_head *last_perm;
+	int protocol = p->protocol;
+	int ret;
 
 	spin_lock_bh(&inetsw6_lock);
 
+	ret = -EINVAL;
 	if (p->type >= SOCK_MAX)
 		goto out_illegal;
 
 	/* If we are trying to override a permanent protocol, bail. */
 	answer = NULL;
+	ret = -EPERM;
 	last_perm = &inetsw6[p->type];
 	list_for_each(lh, &inetsw6[p->type]) {
 		answer = list_entry(lh, struct inet_protosw, list);
@@ -603,9 +605,10 @@ inet6_register_protosw(struct inet_proto
 	 * system automatically returns to the old behavior.
 	 */
 	list_add_rcu(&p->list, last_perm);
+	ret = 0;
 out:
 	spin_unlock_bh(&inetsw6_lock);
-	return;
+	return ret;
 
 out_permanent:
 	printk(KERN_ERR "Attempt to override permanent protocol %d.\n",

-- 
