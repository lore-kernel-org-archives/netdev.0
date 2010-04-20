From: Jiri Bohac <jbohac@suse.cz>
Subject: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Tue, 20 Apr 2010 19:44:01 +0200
Message-ID: <20100420174401.GB1334@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42913 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754928Ab0DTRoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 13:44:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I found what I believe is a race condition in __ipv6_ifa_notify(), in the call
to dst_free().

__ipv6_ifa_notify() contains:

        case RTM_DELADDR:
                if (ifp->idev->cnf.forwarding)
                        addrconf_leave_anycast(ifp);
                addrconf_leave_solict(ifp->idev, &ifp->addr);
                dst_hold(&ifp->rt->u.dst);
                if (ip6_del_rt(ifp->rt))
                        dst_free(&ifp->rt->u.dst);
                break;

AFAICT, ip6_del_rt() will call dst_free() itself if it finds and actually
deletes the route: 
	ip6_del_rt() -> __ip6_del_rt() -> fib6_del() -> fib6_del_route() ->
	-> rt6_release() -> dst_free()

If it fails (like when it races with another invocation of ip6_del_rt()), it
will return nonzero and this will cause the above code to call dst_free() on its own.

dst_free() has no protection against concurrent invocation and if
two invocations make it through the "if (dst->obsolete > 1)"
check before one of them calls __dst_free(), the same dst_entry
may end up either:
	1) dst_destroy()ed and put on the dst_garbage.list, or
	2) put on the dst_garbage.list twice
both resulting in trouble once the GC is run.

One possible code path leading to two invocations of __ipv6_ifa_notify() seems
to be when two bonding slaves receive a NS/NA with the bonds IPv6 address when
the bonding master is in the DAD phase with a tentative address:

netif_receive_skb() gets invoked on two CPUs and sets skb->dev to the bonding master ...
... ip6_mc_input() -> ip6_input_finish() -> icmpv6_rcv() -> ndisc_rcv() ->
 -> ndisc_recv_ns() -> addrconf_dad_failure() -> ipv6_del_addr() -> ipv6_ifa_notify() ->
 -> __ipv6_ifa_notify


What is the reason __ipv6_ifa_notify() calls dst_free() when
ip6_del_rt() fails? I don't see a way ip6_del_rt() could fail
with the dst still needing to be freed.

I am just testing whether the following will help:

--- a/net/ipv6/addrconf.c	2010-04-17 00:12:32.000000000 +0200
+++ b/net/ipv6/addrconf.c	2010-04-20 19:07:35.000000000 +0200
@@ -3974,8 +3974,7 @@ static void __ipv6_ifa_notify(int event,
 			addrconf_leave_anycast(ifp);
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
 		dst_hold(&ifp->rt->u.dst);
-		if (ip6_del_rt(ifp->rt))
-			dst_free(&ifp->rt->u.dst);
+		ip6_del_rt(ifp->rt);
 		break;
 	}
 }

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

