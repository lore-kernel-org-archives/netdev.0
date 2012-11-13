From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] ipv6: fix two typos in a comment in xfrm6_init()
Date: Tue, 13 Nov 2012 10:00:06 +0100
Message-ID: <20121113090006.GI22290@secunet.com>
References: <1352363888-14068-1-git-send-email-roy.qing.li@gmail.com>
 <20121108141936.GC22290@secunet.com>
 <20121108.145939.2274479010583117059.davem@davemloft.net>
 <20121109075726.GD22290@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46326 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646Ab2KMJAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 04:00:14 -0500
Content-Disposition: inline
In-Reply-To: <20121109075726.GD22290@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 09, 2012 at 08:57:26AM +0100, Steffen Klassert wrote:
> On Thu, Nov 08, 2012 at 02:59:39PM -0500, David Miller wrote:
> > From: Steffen Klassert <steffen.klassert@secunet.com>
> > > 
> > > The routing cache is removed, so this comment is obsolete. But it reminds
> > > me that we set the gc threshold to ip_rt_max_size/2 in ipv4. With the
> > > routing cache removal patch, ip_rt_max_size was set to INT_MAX. So the gc
> > > starts to remove entries when a threshold of INT_MAX/2 is reached.
> > > 
> > > cat /proc/sys/net/ipv4/xfrm4_gc_thresh
> > > 1073741823
> > > 
> > > I guess this was not intentional.
> > 
> > Do you mean for IPSEC routes?  For non-IPSEC routes on ipv4 there
> > is nothing to garbage collect.
> 
> Yes, I mean IPsec routes. We still cache them at the flow cache
> and at sockets, so we should do some garbage collecting.
> 
> We could either go back to a static threshold, as it was before
> 
> git commit a33bc5c15154c835aae26f16e6a3a7d9ad4acb45
> xfrm: select sane defaults for xfrm[4|6] gc_thresh
> 
> or do the same as ipv6 does. I'll take care of this.

Actually, the ipv6 side of the xfrm gc threshold is a bit confusing.
The calculation depends on FIB6_TABLE_HASHSZ which has nothing to
do with maximum number of routes. FIB6_TABLE_HASHSZ just reflects
how many different routing tables we can use. It depends on whether
policy routing is enabled and is either 1 or 256. The maximum number
of routes for ipv6 defaults to 4096. So maybe the xfrm gc threshold
should depend somehow on this value.

For the ipv4 side I plan to go back to a static xfrm gc threshold
as it was before we did this dynamically.

I'll apply the patch below to the ipsec tree if there no other
ideas on how to choose the xfrm gc threshold.


Subject: [PATCH] xfrm: Fix the gc threshold value for ipv4

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
