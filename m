From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: [PATCH] Avoid extra calculation in ip_route_input_common
Date: Wed, 21 Dec 2011 13:12:03 +0800
Message-ID: <4EF16AA3.2070303@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Wang <wangyun@linux.vnet.ibm.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:53652 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab1LUFMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 00:12:14 -0500
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Wed, 21 Dec 2011 10:42:11 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pBL5C5eo3535076
	for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 10:42:06 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pBL5C5ko023586
	for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 16:12:05 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Wang <wangyun@linux.vnet.ibm.com>

If previous condition doesn't meet, the later check will be cancelled.
So we don't need to do all the calculation.

Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
---
 net/ipv4/route.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f30112f..2872bfb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2362,10 +2362,10 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
 	     rth = rcu_dereference(rth->dst.rt_next)) {
-		if ((((__force u32)rth->rt_key_dst ^ (__force u32)daddr) |
-		     ((__force u32)rth->rt_key_src ^ (__force u32)saddr) |
-		     (rth->rt_route_iif ^ iif) |
-		     (rth->rt_key_tos ^ tos)) == 0 &&
+		if (((__force u32)rth->rt_key_dst ^ (__force u32)daddr) == 0 &&
+		    ((__force u32)rth->rt_key_src ^ (__force u32)saddr) == 0 &&
+		    rth->rt_route_iif == iif &&
+		    rth->rt_key_tos == tos &&
 		    rth->rt_mark == skb->mark &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
-- 
1.7.4.1
