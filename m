From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Fix ipv6_ifa_notify race (was: IPv6 "badness" in recent releases)
Date: Fri, 19 Nov 2004 20:49:24 +1100
Message-ID: <20041119094924.GA3726@gondor.apana.org.au>
References: <4197AC20.6020707@pobox.com> <E1CTR5h-0006ac-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="azLHFNyN32YCQGCU"
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, acme@conectiva.com.br,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <E1CTR5h-0006ac-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Nov 15, 2004 at 07:35:17AM +1100, Herbert Xu wrote:
> 
> Could you please apply this patch and see if the warning triggers
> before the underflows start coming in? We already know that if it
> does then it can cause underflows but I want to make sure that
> this is what's causing your problems.

Well I think it's time to fix this bug so that we don't release
2.6.10 with it.

This is only a temporary hack that should be rolled back once
the locking in addrconf.c is fixed properly.  At the moment
the locking is just too twisted to fix properly for 2.6.10 :(

This patch doesn't even fix all the races in ipv6_ifa_notify.
For example, the anycast/multicast addresses may be left
standing should the race strike.  However, they should have
a much milder effect compared to a dead route in the routing
table :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

May I ask this question again: Is it possible to move some of
this complexity to user-space?

addrconf.c is by far the biggest file in net/ipv6.  This is
also not the first time we've had a serious bug in this file.
I recall fixing another timer-related bug in this file a year
ago that left dangling references on devices.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/addrconf.c 1.120 vs edited =====
--- 1.120/net/ipv6/addrconf.c	2004-11-16 09:08:09 +11:00
+++ edited/net/ipv6/addrconf.c	2004-11-19 20:43:45 +11:00
@@ -2987,8 +2987,13 @@
 	switch (event) {
 	case RTM_NEWADDR:
 		dst_hold(&ifp->rt->u.dst);
-		if (ip6_ins_rt(ifp->rt, NULL, NULL))
+		spin_lock_bh(&ifp->lock);
+
+		if (ifp->dead || ip6_ins_rt(ifp->rt, NULL, NULL))
 			dst_release(&ifp->rt->u.dst);
+
+		spin_unlock_bh(&ifp->lock);
+
 		if (ifp->idev->cnf.forwarding)
 			addrconf_join_anycast(ifp);
 		break;
@@ -2996,11 +3001,16 @@
 		if (ifp->idev->cnf.forwarding)
 			addrconf_leave_anycast(ifp);
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
+
 		dst_hold(&ifp->rt->u.dst);
+		spin_lock_bh(&ifp->lock);
+
 		if (ip6_del_rt(ifp->rt, NULL, NULL))
 			dst_free(&ifp->rt->u.dst);
 		else
 			dst_release(&ifp->rt->u.dst);
+
+		spin_unlock_bh(&ifp->lock);
 		break;
 	}
 }

--azLHFNyN32YCQGCU--
