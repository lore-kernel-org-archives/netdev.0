From: Dries De Winter <dries.dewinter@gmail.com>
Subject: Re: [PATCH] net: ICMPv6 packets transmitted on wrong interface if
 nfmark is mangled
Date: Wed, 5 Dec 2012 14:41:59 +0100
Message-ID: <CA+e04fgiMDoaCx0fpdK5F6YfJ_CSOZ13q1fn9xs7De4JO02c6g@mail.gmail.com>
References: <1354538763-2678-1-git-send-email-dries.dewinter@gmail.com>
	<20121203.141128.206409637987621093.davem@davemloft.net>
	<CA+e04fjWMDE9xEApysFRprZDBdM3Ya2RHrxtoau7i+fxzGT8CQ@mail.gmail.com>
	<20121203.170636.1325623456787407245.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pablo@netfilter.org, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35173 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab2LENmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 08:42:01 -0500
In-Reply-To: <20121203.170636.1325623456787407245.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/3 David Miller <davem@davemloft.net>:
> From: Dries De Winter <dries.dewinter@gmail.com>
> Date: Mon, 3 Dec 2012 22:31:51 +0100
>
>> Not fixing this means that skb->mark is unavailable for use on ICMPv6
>> packets because it will inevitably put those packets on the wrong
>> interface.
>
> Maybe this suggests that a better fix is to simply explicitly check
> for protocol ICMPV6 in ip6_route_me_harder().

Hmmm, maybe my subject line isn't very well chosen ... I don't really
mean all ICMPv6 traffic. ICMPv6 also includes Destination Unreachable,
Echo request/reply ... and lots of other types that are just regular
unicast packets that should follow the routing table like normal
packets. My concern is mainly about neighbour discovery and MLD. And
after having thought this over and over again, this discussion could
be extended to all link-local traffic in general, not to ICMPv6 in
general.

Routing doesn't make much sense for link-local traffic and typically
the sender specifies on what interface its data has to go out. In the
example of MLD and neighbour discovery this is done using those
special dst entries. But for userspace this can be done by specifying
a non-zero sin6_scope_id or by SO_BINDTODEVICE which sets
sk_bound_dev_if. When sending a message with a link-local destination,
these parameters are taken into account by routing.
ip6_route_me_harder() also takes sk_bound_dev_if into account, but it
has no access to the user supplied sin6_scope_id, so depending on the
method used, you may also hit this issue from user space.

My "noreroute" patch will not fix this. Therefore it's indeed maybe
better to add a simple check to ip6_route_me_harder(): not a check for
ICMPv6, but a check for (ipv6_addr_type(&iph->daddr) &
IPV6_ADDR_LINKLOCAL) instead. What do you think?

Dries.
