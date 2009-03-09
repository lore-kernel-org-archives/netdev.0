From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 0/4] netfilter conntrack sysctls pernet support
Date: Mon, 9 Mar 2009 22:07:44 +0300
Message-ID: <20090309190744.GA18357@localhost>
References: <20090309181628.109019157@gmail.com> <49B56440.2010404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, xemul@openvz.org, adobriyan@gmail.com,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49B56440.2010404@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Patrick McHardy - Mon, Mar 09, 2009 at 07:47:28PM +0100]
> First off, *please* CC netfilter-devel on patches relating to netfilter.
> I've said this a hundred times in direction of the container guys
> (not sure whether you specifically) and it keeps getting ignored.

Ugh... sorry Patrick, my fault, I've noticed this address in
MAINTEINERS but NETFILTER section contains 3 list so I messed
in which one I should choose. Sorry again.

>
> Cyrill Gorcunov wrote:
>> Hi here are a few patches to bring in per-net functionality
>> for several conntrack protocols: DCCP, SCTP, UDPlite.
>>
>> Since these protos could be built as modules I've put
>> per-net operations to module init/exit routines. The change
>> I would like you point the attention is that module static
>> variables being marked as __read_mostly become now as dynamically
>> allocated -- is it acceptable trade off?
>
> Well, there's no other choice I guess.

Actually, the possibility I see is to make some union on _all_
structures I put in pernet section so this union will contain
max possible size of structure allocated and then create one
global slab for this (HW cache aligned). But it would be ugly hack I
believe and until we have no other choise I would prefer to not
play with this idea :)

>
>> For protocols being built in (like TCP, UDP, ICMP) for which I made
>> patches too but they are in a bit 'rought' state: in original
>> code there some kind of reference counter to sysctl tables being
>> registered (and they don't have any kind of mb, didn't check if it
>> could be a problem for SMP since they are mostly __init functions)
>> so I need some kind of same functionality to count per-net calls.
>
> The tables are shared between IPv4 and IPv6, this keeps track of the
> number of current users to avoid unregistering it while the AF-specific
> module for either one is loaded. This would still be a global counter
> with containers I think since module loading is global and they should
> be visible in all containers if IPv4 or IPv6 conntrack is loaded.

Yes, I even thought about kref usage here but kref doesn't have a few
function I need.

>
>> Will send RFC for these protocols soon.
>>
>> So eventually I would like to hear some kind of feedback on this.
>> Ideas and any kind of comments are highly appreciated.
>
>> +	sn->sysctl_table[0].data = &sn->sctp_timeouts[SCTP_CONNTRACK_CLOSED];
>> +	sn->sysctl_table[1].data = &sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT];
>> +	sn->sysctl_table[2].data = &sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED];
>> +	sn->sysctl_table[3].data = &sn->sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED];
>> +	sn->sysctl_table[4].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
>> +	sn->sysctl_table[5].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
>> +	sn->sysctl_table[6].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
>
> Please use an iteration to avoid these repetitve overly long lines.
>

Ah, thanks a lot! Indeed.

	- Cyrill -
