From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Fri, 18 Apr 2008 01:32:28 -0700 (PDT)
Message-ID: <20080418.013228.155392171.davem@davemloft.net>
References: <20080410.161453.52032573.davem@davemloft.net>
	<1207870334.13150.11.camel@localhost>
	<20080410.164106.192045155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: vincent-perrier@club-internet.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54140
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752260AbYDRIc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 04:32:26 -0400
In-Reply-To: <20080410.164106.192045155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 10 Apr 2008 16:41:06 -0700 (PDT)

> From: vincent-perrier <vincent-perrier@club-internet.fr>
> Date: Fri, 11 Apr 2008 01:32:14 +0200
> 
> > Even if the patch is not good, the line dst_free(&rt->u.dst); 
> > when rt is still in tree leads to a crash, but when you do not
> > do the dst_free, when rt is in tree, then it may have hidden 
> > other bugs, but at least I can keep working.
> > 
> > 
> > I never said my patch was good, but it does the minimum to avoid my bug:
> > 
> > 
> >                 if (fn->leaf == NULL) {
> >                         bug_8895_clownix_provisional_workaround = 1;
> >                         fn->leaf = rt;
> >                         atomic_inc(&rt->rt6i_ref);
> >                 }
> > ...
> > 
> > ip6_fib.c, line 796:
> > 
> >                 if (!bug_8895_clownix_provisional_workaround)
> >                         dst_free(&rt->u.dst);
> > 
> > That way at least it does not crash.

I started looking actively at this.

There are a lot of complicated side effects here, especially when
subtrees are enabled as it is in your case.

The main issue is whether we added any references to 'rt' into
the routing tree.  If we get an error, we have to undo any
such added references.

And that's not being done when the "if (fn->leaf == NULL)" code
runs and fib6_add_rt2node() returns an error.

I think this patch will fix it, could you please test it out?

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index b3f6e03..50f3f8f 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -772,6 +772,10 @@ out:
 		 * If fib6_add_1 has cleared the old leaf pointer in the
 		 * super-tree leaf node we have to find a new one for it.
 		 */
+		if (pn != fn && pn->leaf == rt) {
+			pn->leaf = NULL;
+			atomic_dec(&rt->rt6i_ref);
+		}
 		if (pn != fn && !pn->leaf && !(pn->fn_flags & RTN_RTINFO)) {
 			pn->leaf = fib6_find_prefix(info->nl_net, pn);
 #if RT6_DEBUG >= 2


