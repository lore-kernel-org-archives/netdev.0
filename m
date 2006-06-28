From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Wed, 28 Jun 2006 15:01:24 +0200
Message-ID: <20060628130124.GX1376@postel.suug.ch>
References: <20060626145446.948105000@postel.suug.ch> <20060626145515.769648000@postel.suug.ch> <44A0138F.8050208@trash.net> <20060626.104654.98552111.davem@davemloft.net> <20060626184424.GT1376@postel.suug.ch> <44A05FE0.7070203@trash.net> <20060627100309.GU1376@postel.suug.ch> <1151413670.6516.57.camel@jzny2> <20060628101832.GW1376@postel.suug.ch> <1151497363.5203.47.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:3814 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1423313AbWF1NBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 09:01:04 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151497363.5203.47.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-28 08:22
> Let me see if i understood correctly:
> you have a device from both vlan1 and vlan2 both being redirected to
> ifb1? and vlan 3, 4=> ifb2?
> And i take it to make it interesting vlan1,2 on eth0 and vlan3,4 ontop
> of eth1? note the iflink would/should reflect eth1/2. If you had bonding
> or bridging in between it gets more interesting. But you are saying
> you are no longer interested in the info that it came via eth1/2 at some
> point, correct? 
> Note, in such a case: iflink rewriting will do it just fine
> but then you loose the original info (I think it would be good to not
> loose such info to know the origin). I dont know if cmsg uses iflink at
> all - they probably look at the ifindex.

It's using rt_iif which is currently derived from skb->dev even
though it would make sense to use skb->iif once that is well
defined.

> Ok, now question: why are you binding on top of ifb? we could have
> redirected this to ipip, or tun0 or loopback or eql etc where it may
> equally not have made sense to bind to. I can see something like this
> making sense for bonding or bridging but not as a generic answer for all
> netdevices.

What's special about that? It seems a perfectly fine and simple way
to create namespaces for sockets without enforcing applications to
bind to the correct vlan devices directly.

> The concept is to use ifb as a transitionary device. Packets come into
> it from either the ingress side of the stack or egress and get returned
> on the same side/spot they were found - with ifb represented as the
> input device. What ifb does is independent of what mirred does (we could
> redirect to other devices other than ifb).

This is clear, my question was for you to explain when you intend
to update input_dev etc. By overwriting it in ifb you enforce that
valueable information is lost.

There is nothing wrong with updating iif to point to ifb under
certain circumstances but it's not required to strictly enforce
this. Having mirred do so conditionally is a lot more flexible
without losing any value.

> Now that i pay attention to your patch i think i see the complications
> it is introducing (i am not done yet)- and i did warn about this in the
> discussion _and_ didnt we agree to leave this stuff alone? Can we drop
> this change please?

This statement doesn't make sense, it merely transforms a device
reference to a reference by interface index because the current
method of handling it doesn't make sense at all since the region
where input_dev stays valid without the risk of the device
disappearing is very limited.


> It does work as it is right now (I only notice a pull - there is no
> push).

In order to pull in ifb you need to push in mirred, quite
obvious, no?  Why are you enforcing users of ifb to fake an
ethernet header that is of no use at all?
