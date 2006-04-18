From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] ip_route_input panic fix
Date: Wed, 19 Apr 2006 03:52:22 +0400
Message-ID: <20060418235222.GA20504@ms2.inr.ac.ru>
References: <20060417171253.4e988afc@localhost.localdomain> <E1FVk6q-0000Tf-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:57482 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1750851AbWDRXwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2006 19:52:39 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1FVk6q-0000Tf-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Looking at this again, the root of this problem is the IGMPv3
> patch which started using the skb->nh.iph->protocol as a key.

No, root is that this fake skb was not properly initialized.
It should, it should be a good real IP skb.


> In fact I'm unsure as to whether all the other users of ip_route_input
> is safe as it is regarding the protocol.

ip_route_input takes skb as an argument exactly because it needs nothing
but skb and there is always an skb, when we "input".
ip_route_output would be happy to take an skb as well,
but unfortuntely it happens before we have an skb.

I do not see anything scary here: agree, when skb->nh happens to be undefined,
such skb would crash almost any place in IP stack. :-)


Actually, this weird case in inet_get_route() is the only place, where
a dummy skb is used and it is needed mostly to resolve multicast routes.
In this case this fake skb really passes through all the engine, even
delivered to user space in some sense, and when the route is resolved,
the same skb is submitted to netlink socket. I remember, Dave found
something very bad about this and this even deserved a place in TODO list,
but franky speaking I did not understand what is so wrong with this trick.

Alexey
