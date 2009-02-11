From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netlink broadcast return value
Date: Wed, 11 Feb 2009 13:44:23 +0100
Message-ID: <4992C827.20302@trash.net>
References: <4985A4C5.4050908@netfilter.org> <20090202.140533.121159038.davem@davemloft.net> <49903B03.2040302@trash.net> <4990B38A.3020207@netfilter.org> <4990BADA.7040309@trash.net> <4990C337.3040704@netfilter.org> <4991863F.3030800@trash.net> <4991CCC1.7080308@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48953 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbZBKMo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 07:44:27 -0500
In-Reply-To: <4991CCC1.7080308@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>> I know, but in the mean time I think its wrong :) The delivery
>> isn't reliable and what the admin is effectively expressing by
>> setting your sysctl is "I don't have any listeners besides the
>> synchronization daemon running". So it might as well use unicast.
> 
> No :), this setting means "state-changes over ctnetlink will be reliable
> at the cost of dropping packets (if needed)", it's an optional
> trade-off. You may also have more listeners like a logging daemon
> (ulogd), similarly this will be useful to ensure that ulogd doesn't leak
> logging information which may happen under very heavy load. This option
> is *not* only oriented to state-synchronization.

I'm aware of that. But you're adding a policy knob to control the
behaviour of a one-to-many interface based on what a single listener
(or maybe even two) want. Its not possible anymore to just listen to
events for debugging, since that might even lock you out. You also
can't use ulogd and say that you *don't* care whether every last state
change was delivered to it.

This seems very wrong to me. And I don't even see a reason to do
this since its easy to use unicast and per-listener state.

> Using unicast would not do any different from broadcast as you may have
> two listeners receiving state-changes from ctnetlink via unicast, so the
> problem would be basically the same as above if you want reliable
> state-change information at the cost of dropping packets.

Only the processes that actually care can specify this behaviour.
They're likely to have more CPU time, better adjusted receive
buffers etc than f.i. the conntrack tool when dumping events.

> BTW, the netlink_broadcast return value looked to me inconsistent before
> the patch. It returned ENOBUFS if it could not clone the skb, but zero
> when at least one message was delivered. How useful can be this return
> value for the callers? I would expect to have a similar behaviour to the
> one of netlink_unicast (reporting EAGAIN error when it could not deliver
> the message), even if the return value for most callers should be
> ignored as it is not of any help.

Its useless since you don't know how received it. It should return
void IMO.

>> So you're dropping the packet if you can't manage to synchronize.
>> Doesn't that defeat the entire purpose of synchronizing, which is
>> *increasing* reliability? :)
> 
> This reduces communications reliability a bit under very heavy load,
> yes, because it may drop some packets but it adds reliable flow-based
> logging accounting / state-synchronization in return. Both refers to
> reliability in different contexts. In the end, it's a trade-off world.
> There's some point at which you may want to choose which one you prefer,
> reliable communications if the system is under heavy load or reliable
> logging (no leaks in the logging) / state-synchronization (the backup
> firewall is able to follow state-changes of the master under heavy load).

Logging yes, but I can't see the point in perfect synchronization if
that leads to less throughput.
