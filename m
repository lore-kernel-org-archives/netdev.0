From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ip_route_input panic fix
Date: Tue, 18 Apr 2006 20:53:17 -0700 (PDT)
Message-ID: <20060418.205317.18564378.davem@davemloft.net>
References: <20060417171253.4e988afc@localhost.localdomain>
	<E1FVk6q-0000Tf-00@gondolin.me.apana.org.au>
	<20060418235222.GA20504@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, shemminger@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21731
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750746AbWDSDyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 23:54:33 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060418235222.GA20504@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Wed, 19 Apr 2006 03:52:22 +0400

> Actually, this weird case in inet_get_route() is the only place, where
> a dummy skb is used and it is needed mostly to resolve multicast routes.
> In this case this fake skb really passes through all the engine, even
> delivered to user space in some sense, and when the route is resolved,
> the same skb is submitted to netlink socket. I remember, Dave found
> something very bad about this and this even deserved a place in TODO list,
> but franky speaking I did not understand what is so wrong with this trick.

Problem there is via rt_fill_info().  When multicast route cannot be
found by ipmr, it tries to use this netlink SKB to send out a probe.

ipmr_get_route() is the trouble maker.  If ipmr_cache_find() cannot
find an entry, it tries to use the netlink SKB to send out an ipv4
packet, completely mangling it, via ipmr_cache_unresolved().

Even worse it may even free the skb on us, or queue it to
mroute_socket.

It is pure disaster, this entire code path.
