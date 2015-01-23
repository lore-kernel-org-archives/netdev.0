From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 10:49:32 +0000
Message-ID: <20150123104932.GG25797@casper.infradead.org>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
 <20150122125246.GA4486@salvia>
 <20150122133713.GA25797@casper.infradead.org>
 <20150122140022.GA5674@salvia>
 <54C11094.2000807@mojatatu.com>
 <20150122151316.GB25797@casper.infradead.org>
 <54C12C1F.706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com, Jiri Pirko <jiri@resnulli.us>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46298 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbbAWKtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 05:49:33 -0500
Content-Disposition: inline
In-Reply-To: <54C12C1F.706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/15 at 08:58am, John Fastabend wrote:
> In response to Pablo's observation,
> 
> Correct this is fully exposed to user space, but it is also self
> contained inside the API meaning I can learn when to use it and what it
> does by looking at the other operations tables the table graph and
> supported headers. The assumption I am making that is not in the API
> explicitly yet. Is that actions named "set_field_name" perform the
> set operation on that field. We can and plan to extend the API to make
> this assumption explicit in the API.

OK. I think it's this assumption that is not explicitly in the API yet
that causes confusion. Making it explicit would definitely help. Do
we even need the driver to declare get/set operations at all? Can we
just have the driver expose the field and the API takes care of
providing get/set actions?

> Even though its a detail of the rocker world its easy enough for a
> program on top of the API to learn how it works.
> 
> So in the rocker switch case if I want to rewrite an eth_dst adress I
> have a  couple choices. I can set the group_id in one of the tables
> that support setting the group_id and then do the rewrite in one of the
> tables that supports matching on group_id and setting the eth_dst mac.
> The "choice" I make is a policy IMO and I don't want to hard code logic
> in the kernel that picks tables and decides things like what should I
> do if table x is full but table y could also be used should I overflow
> into table y? Or  is table y reserved for some other network function?
> etc.

Agreed. It might make sense to declare such fields as general purpose
metadata or have some kind of field class which describes the nature
of the field: { register, protocol-field, configuration, ... }

> There are some actions and metadata though that _need_ to be
> standardized. These are the metadata that is used outside the API. For
> example ingress_port is metadata that is set outside the tables.
> Similarly set_egress_port and set_egress_queue provide the forwarding
> and queueing fields. No matter how hard you look at the model from the
> API you can not learn how these are used.

Agreed. I assume we would implement a tun_dst the same standardized way.

> >What would a rocker group map to in the tc world?
> 
> In the 'tc' world I would guess the easiest thing to do is simply bind
> a 'tc' qdisc to the ACL table. It seems a good first approximation of
> how to make this work. But the rocker world doesn't yet have any QOS so
> it makes it difficult to "offload" anything but the fifo qdiscs.

Right. I was asking as tc will have the same difficulty if it wishes
to classify based on rocker groups or other general purpose hardware
metadata fields. We can either supoprt them by describing them and
allow learning of such fields or ignore them.

> >>I see this as a gaping hole
> >>for vendor SDKs with their own definitions of their own hardware that
> >>doesnt work with anyone else. i.e it seems to standardize proprietary
> >>interfaces. Maybe thats what Pablo is alluding to.
> >
> >I will be the first to root for rejection if such patches appear.
> >
> 
> Is it problematic if users define some unique header here and then
> provide actions to set/pop/push/get operations on it?

I have no problem with unique headers but we have to ensure that a
field with identical purpose or same logical meaning is represented in
the same way by all drivers. If a driver introduces a new field it
must consider that other drivers will need/want to use it as well.
I guess/hope this is obvious though ;-)

I agree that if chip A has 8 general purpose registers and chip B has
32 of them then it doesn't matter how they are called. What matters is
that they are declared as such to API users.

Actions must obviously be standardized as your proposal already does
by exposing push_vlan, pop_vlan, etc.
