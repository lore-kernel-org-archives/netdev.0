From: Dries De Winter <dries.dewinter@gmail.com>
Subject: Re: [PATCH] net: ICMPv6 packets transmitted on wrong interface if
 nfmark is mangled
Date: Mon, 3 Dec 2012 22:31:51 +0100
Message-ID: <CA+e04fjWMDE9xEApysFRprZDBdM3Ya2RHrxtoau7i+fxzGT8CQ@mail.gmail.com>
References: <20121130.122243.710720011890818822.davem@davemloft.net>
	<1354538763-2678-1-git-send-email-dries.dewinter@gmail.com>
	<20121203.141128.206409637987621093.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pablo@netfilter.org, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20121203.141128.206409637987621093.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/12/3 David Miller <davem@davemloft.net>:
> Thinking about this some more I can't see how this is correct.
>
> What if netfilter modified one of the keys that go into the route
> lookup such as the source or destination address?
That is a question I have as well. What if the destination address of
a neighbour solicitation is rewritten to some random unicast address
for example? You could say that in that case indeed the routing table
should be followed. But you could also say that ICMPv6 is a
fundamental part of IPv6 and sending out a neighbour solicitation for
instance on a different interface than the one it is intended for is
wrong. Or you could even say that it is a total non-issue because
rewriting the destination address of ICMPv6 is already wrong in the
first place.

Anyway, what if the source address is modified while there is no
source based routing or skb->mark is modified while there is no policy
based routing? In that case routing is not affected but still the
ICMPv6 packet will go out on a different interface than the one you
would expect. This is because the dst of such packet is special in the
sense that it is not referred to by the routing table, so when
rerouting the packet it is impossible to find back the original
destination.

Not fixing this means that skb->mark is unavailable for use on ICMPv6
packets because it will inevitably put those packets on the wrong
interface. I use skb->mark for QoS, not for routing so I don't expect
the outgoing interface to be affected by my markers. Now that I know
this issue, it is easy enough for me to work around, but I suspect
that I'm not the only one in the world that uses skb->mark for other
purposes than routing. Moreover, the road from seeing a neighbour
solicitation or MLD report going out on the wrong interface to finding
this limitation can be quite painful. Anyway, in the end it's up to
you to decide of course.

Kind regards,

Dries.
