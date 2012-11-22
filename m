From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: Fix the gc threshold value for ipv4
Date: Thu, 22 Nov 2012 08:56:37 +0100
Message-ID: <1353570997-2571-2-git-send-email-steffen.klassert@secunet.com>
References: <1353570997-2571-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36439 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965185Ab2KVTej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 14:34:39 -0500
In-Reply-To: <1353570997-2571-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xfrm gc threshold value depends on ip_rt_max_size. This
value was set to INT_MAX with the routing cache removal patch,
so we start doing garbage collecting when we have INT_MAX/2
IPsec routes cached. Fix this by going back to the static
threshold of 1024 routes.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h      |    2 +-
 net/ipv4/route.c        |    2 +-
 net/ipv4/xfrm4_policy.c |   13 +------------
 3 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6f0ba01..63445ed 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1351,7 +1351,7 @@ struct xfrm6_tunnel {
 };
 
 extern void xfrm_init(void);
-extern void xfrm4_init(int rt_hash_size);
+extern void xfrm4_init(void);
 extern int xfrm_state_init(struct net *net);
 extern void xfrm_state_fini(struct net *net);
 extern void xfrm4_state_init(void);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a8c6512..200d287 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2597,7 +2597,7 @@ int __init ip_rt_init(void)
 		pr_err("Unable to create route proc files\n");
 #ifdef CONFIG_XFRM
 	xfrm_init();
-	xfrm4_init(ip_rt_max_size);
+	xfrm4_init();
 #endif
 	rtnl_register(PF_INET, RTM_GETROUTE, inet_rtm_getroute, NULL, NULL);
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 05c5ab8..3be0ac2 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -279,19 +279,8 @@ static void __exit xfrm4_policy_fini(void)
 	xfrm_policy_unregister_afinfo(&xfrm4_policy_afinfo);
 }
 
-void __init xfrm4_init(int rt_max_size)
+void __init xfrm4_init(void)
 {
-	/*
-	 * Select a default value for the gc_thresh based on the main route
-	 * table hash size.  It seems to me the worst case scenario is when
-	 * we have ipsec operating in transport mode, in which we create a
-	 * dst_entry per socket.  The xfrm gc algorithm starts trying to remove
-	 * entries at gc_thresh, and prevents new allocations as 2*gc_thresh
-	 * so lets set an initial xfrm gc_thresh value at the rt_max_size/2.
-	 * That will let us store an ipsec connection per route table entry,
-	 * and start cleaning when were 1/2 full
-	 */
-	xfrm4_dst_ops.gc_thresh = rt_max_size/2;
 	dst_entries_init(&xfrm4_dst_ops);
 
 	xfrm4_state_init();
-- 
1.7.9.5
