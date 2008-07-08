From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix race between ipv6_del_addr and DAD timer
Date: Tue, 08 Jul 2008 15:14:04 -0700 (PDT)
Message-ID: <20080708.151404.177911457.davem@davemloft.net>
References: <48732B7C.70802@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	avagin@parallels.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34931
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755521AbYGHWOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 18:14:04 -0400
In-Reply-To: <48732B7C.70802@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Jul 2008 12:55:24 +0400

> Consider the following scenario:
> 
> ipv6_del_addr(ifp)
>   ipv6_ifa_notify(RTM_DELADDR, ifp)
>     ip6_del_rt(ifp->rt)
> 
> after returning from the ipv6_ifa_notify and enabling BH-s
> back, but *before* calling the addrconf_del_timer the 
> ifp->timer fires and:
> 
> addrconf_dad_timer(ifp)
>   addrconf_dad_completed(ifp)
>     ipv6_ifa_notify(RTM_NEWADDR, ifp)
>       ip6_ins_rt(ifp->rt)
> 
> then return back to the ipv6_del_addr and:
> 
> in6_ifa_put(ifp)
>   inet6_ifa_finish_destroy(ifp)
>     dst_release(&ifp->rt->u.dst)
> 
> After this we have an ifp->rt inserted into fib6 lists, but 
> queued for gc, which in turn can result in oopses in the
> fib6_run_gc. Maybe some other nasty things, but we caught 
> only the oops in gc so far.
> 
> The solution is to disarm the ifp->timer before flushing the
> rt from it.
> 
> Signed-off-by: Andrey Vagin <avagin@parallels.com>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6, thanks a lot for this bug fix!
