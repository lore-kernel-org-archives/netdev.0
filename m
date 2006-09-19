From: Joy Latten <latten@austin.ibm.com>
Subject: ipsec acquire has security context although I am not using it.
Date: Tue, 19 Sep 2006 16:17:20 -0500
Message-ID: <200609192117.k8JLHKIC013043@faith.austin.ibm.com>
Cc: davem@davemloft.net, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:65408 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S1752082AbWISV24
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 17:28:56 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8JLSuU4029683
	for <netdev@vger.kernel.org>; Tue, 19 Sep 2006 17:28:56 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8JLSur9351366
	for <netdev@vger.kernel.org>; Tue, 19 Sep 2006 15:28:56 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8JLStXb027906
	for <netdev@vger.kernel.org>; Tue, 19 Sep 2006 15:28:55 -0600
To: netdev@vger.kernel.org, redhat-lspp@redhat.com,
	selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When using ipsec while selinux is enabled in my kernel, 
my racoon daemon fails to establish an SA. I believe the
ACQUIRE sent from kernel has a security context although I 
am not using this feature with ipsec. As a result, racoon
fails to establish the SA, because it is looking for a policy
with security context. I noticed the security context contains garbage. 

I am using a pseries, power5, ppc64 box, and it appears
that since policy->security structure is not really initialized
or zero'd out when not using, it is possible it may contain garbage
on my pseries and a call such as "if (policy->security)" may 
come back as true such that security context is included in
my acquire message although I believe it should not be. 

Hopefully, the below patch is acceptable. I have compiled and
tested it.

Regards,
Joy Latten


diff -urpN linux-2.6.17.orig/net/xfrm/xfrm_policy.c linux-2.6.17.patch/net/xfrm/xfrm_policy.c
--- linux-2.6.17.orig/net/xfrm/xfrm_policy.c	2006-09-19 02:11:33.000000000 -0500
+++ linux-2.6.17.patch/net/xfrm/xfrm_policy.c	2006-09-19 04:33:50.000000000 -0500
@@ -319,6 +319,7 @@ struct xfrm_policy *xfrm_policy_alloc(gf
 		init_timer(&policy->timer);
 		policy->timer.data = (unsigned long)policy;
 		policy->timer.function = xfrm_policy_timer;
+		policy->security = NULL;
 	}
 	return policy;
 }
