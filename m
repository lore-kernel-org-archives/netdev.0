From: David Miller <davem@davemloft.net>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Thu, 22 Apr 2010 18:54:00 -0700 (PDT)
Message-ID: <20100422.185400.71096585.davem@davemloft.net>
References: <20100422.004324.67422011.davem@davemloft.net>
	<20100422142506.GA15858@gondor.apana.org.au>
	<20100422154908.GA31568@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32843
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752760Ab0DWBxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 21:53:55 -0400
In-Reply-To: <20100422154908.GA31568@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Thu, 22 Apr 2010 17:49:08 +0200

> I still don't see why __ipv6_ifa_notify() needs to call
> dst_free(). Shouldn't that be dst_release() instead, to drop the
> reference obtained by dst_hold(&ifp->rt->u.dst)?

It likely wants to do both.

Just doing dst_release() doesn't mark the 'dst' object as obsolete,
and therefore it won't get force garbage collected.

That's why the dst_free() is necessary, to really get rid of it when
the refcount does hit zero.

Actually, what's really interesting is that at the top of the
linux-2.6-history tree this code reads:

		dst_hold(&ifp->rt->u.dst);
		if (ip6_del_rt(ifp->rt, NULL, NULL))
			dst_free(&ifp->rt->u.dst);
		else
			dst_release(&ifp->rt->u.dst);

and in Linus's initial GIT import, it reads this way too.

Where did it change to the current form that lacks the
else block?

Aha!  Here it is:

commit 4641e7a334adf6856300a98e7296dfc886c446af
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Thu Feb 2 16:55:45 2006 -0800

    [IPV6]: Don't hold extra ref count in ipv6_ifa_notify
    
    Currently the logic in ipv6_ifa_notify is to hold an extra reference
    count for addrconf dst's that get added to the routing table.  Thus,
    when addrconf dst entries are taken out of the routing table, we need
    to drop that dst.  However, addrconf dst entries may be removed from
    the routing table by means other than __ipv6_ifa_notify.
    
    So we're faced with the choice of either fixing up all places where
    addrconf dst entries are removed, or dropping the extra reference count
    altogether.
    
    I chose the latter because the ifp itself always holds a dst reference
    count of 1 while it's alive.  This is dropped just before we kfree the
    ifp object.  Therefore we know that in __ipv6_ifa_notify we will always
    hold that count.
    
    This bug was found by Eric W. Biederman.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d328d59..1db5048 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3321,9 +3321,7 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 
 	switch (event) {
 	case RTM_NEWADDR:
-		dst_hold(&ifp->rt->u.dst);
-		if (ip6_ins_rt(ifp->rt, NULL, NULL, NULL))
-			dst_release(&ifp->rt->u.dst);
+		ip6_ins_rt(ifp->rt, NULL, NULL, NULL);
 		if (ifp->idev->cnf.forwarding)
 			addrconf_join_anycast(ifp);
 		break;
@@ -3334,8 +3332,6 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 		dst_hold(&ifp->rt->u.dst);
 		if (ip6_del_rt(ifp->rt, NULL, NULL, NULL))
 			dst_free(&ifp->rt->u.dst);
-		else
-			dst_release(&ifp->rt->u.dst);
 		break;
 	}
 }
