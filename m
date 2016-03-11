From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Sat, 12 Mar 2016 00:22:47 +0300
Message-ID: <20160311212247.GH1989@uranus.lan>
References: <20160310215959.GE1989@uranus.lan>
 <20160310.173630.525547775491939864.davem@davemloft.net>
 <20160310224056.GF1989@uranus.lan>
 <20160311.154046.890043899835986091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160311.154046.890043899835986091.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 11, 2016 at 03:40:46PM -0500, David Miller wrote:
> > Thanks a lot, David!
> 
> Cyrill please retest this final patch and let me know if it still works
> properly.
> 
> I looked at ipv6, and it's more complicated.  The problem is that ipv6
> doesn't mark the inet6dev object as dead in the NETDEV_DOWN case, in
> fact it keeps the object around.  It only releases it and marks it
> dead in the NETDEV_UNREGISTER case.
> 
> We pay a very large price for having allowed the behavior of ipv6 and
> ipv4 to diverge so greatly in these areas :-(
> 
> Nevertheless we should try to fix it somehow, maybe we can detect the
> situation in another way for the ipv6 side.

David, thanks a huge! But you forgot to merge your patch #2
(once I add it manually on top, it works quite well :)
---
 net/ipv4/fib_frontend.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux-ml.git/net/ipv4/fib_frontend.c
===================================================================
--- linux-ml.git.orig/net/ipv4/fib_frontend.c
+++ linux-ml.git/net/ipv4/fib_frontend.c
@@ -922,6 +922,9 @@ void fib_del_ifaddr(struct in_ifaddr *if
 		subnet = 1;
 	}
 
+	if (in_dev->dead)
+		goto no_promotions;
+
 	/* Deletion is more complicated than add.
 	 * We should take care of not to delete too much :-)
 	 *
@@ -997,6 +1000,7 @@ void fib_del_ifaddr(struct in_ifaddr *if
 		}
 	}
 
+no_promotions:
 	if (!(ok & BRD_OK))
 		fib_magic(RTM_DELROUTE, RTN_BROADCAST, ifa->ifa_broadcast, 32, prim);
 	if (subnet && ifa->ifa_prefixlen < 31) {
