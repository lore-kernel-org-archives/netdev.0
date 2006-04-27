From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH] [IPV6]: Fix race in route selection.
Date: Fri, 28 Apr 2006 02:04:56 +0900 (JST)
Message-ID: <20060428.020456.35552581.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:24069 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S965141AbWD0RE4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 13:04:56 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

We eliminated rt6_dflt_lock (to protect default router pointer)
at 2.6.17-rc1, and introduced rt6_select() for general router selection.
The function is called in the context of rt6_lock read-lock held,
but this means, we have some race conditions when we do round-robin.

Am I correct?

If so, we should put some spin_lock for serialization.

Comments?

Signed-off-by; YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Or, should we run whole part of rt6_select() under some lock?

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7907874..0190e39 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -317,7 +317,7 @@ static struct rt6_info *rt6_select(struc
 		  __FUNCTION__, head, head ? *head : NULL, oif);
 
 	for (rt = rt0, metric = rt0->rt6i_metric;
-	     rt && rt->rt6i_metric == metric;
+	     rt && rt->rt6i_metric == metric && (!last || rt != rt0);
 	     rt = rt->u.next) {
 		int m;
 
@@ -343,9 +343,12 @@ static struct rt6_info *rt6_select(struc
 	    (strict & RT6_SELECT_F_REACHABLE) &&
 	    last && last != rt0) {
 		/* no entries matched; do round-robin */
+		static spinlock_t lock = SPIN_LOCK_UNLOCKED;
+		spin_lock(&lock);
 		*head = rt0->u.next;
 		rt0->u.next = last->u.next;
 		last->u.next = rt0;
+		spin_unlock(&lock);
 	}
 
 	RT6_TRACE("%s() => %p, score=%d\n",

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
