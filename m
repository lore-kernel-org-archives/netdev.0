From: Lauri Tarkkala <ltarkkala@safenet-inc.com>
Subject: Re: [PATCH] ip multicast, kernel 2.4.2*, 2.6.*
Date: Thu, 15 Apr 2004 05:45:35 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040415024535.GA28612@safenet-inc.com>
References: <20040414041731.GA2010@safenet-inc.com> <OF0F96BFF9.CF0962DF-ON88256E76.0030A322-88256E76.003206F4@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF0F96BFF9.CF0962DF-ON88256E76.0030A322-88256E76.003206F4@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 14, 2004 at 02:06:17AM -0700, David Stevens wrote:
> > The reason for this processing (my guess), is that the inbound
> > (duplicate) packet will not be sent, unless the original
> > passes the netfilter hooks. This has the side-effect that netfilter
> > hooks have no way of detecting whether packets are intended to or are
> > going to be looped back. The looped-back packet will of course still go
> > through the inbound hooks.
> 
> If a packet doesn't pass the outbound hooks, won't your patch still
> deliver it locally? Isn't that wrong?

This boils down to how one feels about the following questions.

A)
  Should it be possible to send multicast packets through a netfilter
  module in such a manner that a local listener receives them, but the
  packet does not enter the network?

B)
  Should A netfilter module know if the packet it is processing
  is destined for the network, or for the local stack?

Personally I feel that the answer to question "B" should be YES. I
do not feel so strongly about "A", but I think that should also be
a YES.

I do not see much breaking, if a multicast packet is sent to the local stack
even if it the network-bound packet was dropped by a packet filter. Note
that even after my proposed patch is applied, having this style of
behaviour is possible by putting proper processing in the inbound hooks
(drop similar multicast packets that have skb.type == PACKET_LOOPBACK set
 and that are not on the loopback interface).

> I think the reason it creates a duplicate is because there are two
> cases-- one to be sent to the interface and one to be delivered
> locally. The one going out the interface should pass the outbound
> checks (only) and the one delivered locally should pass (I think)
> first the outbound filter and then the inbound filter. Right?

This is my interpretation also.

> Under what circumstances does netfilter need to "detect whether packets
> are intended to or are going to be looped back?"

Well, for one thing a module can use (in the outbound case) in
a netfilter hook the "skb->dev->flags & IFF_LOOPBACK" case to detect
whether we are on the loopback stack. 

> > This is quite error-prone, both in terms of configuring policy for
> > netfilter modules, not to mention optimization and implementation. There
> > are also some cases that just can not be handled correctly.
> 
> What does it break? Can you give an example?

Trivial case:

+ Statistics counter in netfilter module counting amount of packets
  sent out via an interface through the module.

More complicated case:

+ Netfilter module has a policy of not allowing multicast packets to the
  network, but would like them to be received by a listener bound to the
  same interface. If the module is actively manipulating the packet
  instead of just passively filtering, this can be a serious problem.

Hypotethically:

+ Any case where the processing tries to factor into account
  the intended destination of the packet into the policy decision.

Lauri

-- 
Lauri Tarkkala
Safenet Inc. 
http://www.safenet-inc.com/
