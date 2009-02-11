From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC] netlink broadcast return value
Date: Wed, 11 Feb 2009 17:39:45 +0100
Message-ID: <4992FF51.9010507@netfilter.org>
References: <4985A4C5.4050908@netfilter.org> <20090202.140533.121159038.davem@davemloft.net> <49903B03.2040302@trash.net> <4990B38A.3020207@netfilter.org> <4990BADA.7040309@trash.net> <4990C337.3040704@netfilter.org> <4991863F.3030800@trash.net> <4991CCC1.7080308@netfilter.org> <4992C827.20302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37294 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757536AbZBKQj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2009 11:39:56 -0500
In-Reply-To: <4992C827.20302@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First of all, sorry, this email is probably too long.

Patrick McHardy wrote:
> Pablo Neira Ayuso wrote:
>> Patrick McHardy wrote:
>>> I know, but in the mean time I think its wrong :) The delivery
>>> isn't reliable and what the admin is effectively expressing by
>>> setting your sysctl is "I don't have any listeners besides the
>>> synchronization daemon running". So it might as well use unicast.
>>
>> No :), this setting means "state-changes over ctnetlink will be reliable
>> at the cost of dropping packets (if needed)", it's an optional
>> trade-off. You may also have more listeners like a logging daemon
>> (ulogd), similarly this will be useful to ensure that ulogd doesn't leak
>> logging information which may happen under very heavy load. This option
>> is *not* only oriented to state-synchronization.
> 
> I'm aware of that. But you're adding a policy knob to control the
> behaviour of a one-to-many interface based on what a single listener
> (or maybe even two) want. Its not possible anymore to just listen to
> events for debugging, since that might even lock you out.

Can you think of one example where one ctnetlink listener may not find
useful reliable state-change reports? Still, this setting is optional
(it will be disabled by default) and, if turned on, you can disable it
for debugging purposes.

Thinking more about it, reliable logging and monitoring would be even
something interesting in terms of security.

> You also
> can't use ulogd and say that you *don't* care whether every last state
> change was delivered to it.
> 
> This seems very wrong to me. And I don't even see a reason to do
> this since its easy to use unicast and per-listener state.

Netlink unicast would not be of any help either if you want reliable
state-change reporting via ctnetlink. If one process receives the event
and the other does not, you would also need to drop the packet to
perform reliable logging.

>> Using unicast would not do any different from broadcast as you may have
>> two listeners receiving state-changes from ctnetlink via unicast, so the
>> problem would be basically the same as above if you want reliable
>> state-change information at the cost of dropping packets.
> 
> Only the processes that actually care can specify this behaviour.

No, because this behaviour implies that the packet would be drop if the
state-change is not delivered correctly to all. It has to be an on/off
behaviour for all listeners.

> They're likely to have more CPU time, better adjusted receive
> buffers etc than f.i. the conntrack tool when dumping events.
> 
>> BTW, the netlink_broadcast return value looked to me inconsistent before
>> the patch. It returned ENOBUFS if it could not clone the skb, but zero
>> when at least one message was delivered. How useful can be this return
>> value for the callers? I would expect to have a similar behaviour to the
>> one of netlink_unicast (reporting EAGAIN error when it could not deliver
>> the message), even if the return value for most callers should be
>> ignored as it is not of any help.
> 
> Its useless since you don't know how received it. It should return
> void IMO.
> 
>>> So you're dropping the packet if you can't manage to synchronize.
>>> Doesn't that defeat the entire purpose of synchronizing, which is
>>> *increasing* reliability? :)
>>
>> This reduces communications reliability a bit under very heavy load,
>> yes, because it may drop some packets but it adds reliable flow-based
>> logging accounting / state-synchronization in return. Both refers to
>> reliability in different contexts. In the end, it's a trade-off world.
>> There's some point at which you may want to choose which one you prefer,
>> reliable communications if the system is under heavy load or reliable
>> logging (no leaks in the logging) / state-synchronization (the backup
>> firewall is able to follow state-changes of the master under heavy load).
> 
> Logging yes, but I can't see the point in perfect synchronization if
> that leads to less throughput.

Indeed, (reactive) fault-tolerance force you to trade-off between the
synchronization degree and performance. Conntrackd is far from doing
"perfect synchronization", let me develop this idea a bit.

Perfect synchronization (or call it "synchronous" replication) indeed
implies *way* less performance. In the particular case of stateful
firewalls, synchronous replication means that each packet would have to
wait until one state-change is propagated to all backups.
Then, once the backups have confirmed that the state-change has been
propagated correctly, the packet continues its travel. Thus, packets
would be delayed and throughput would severely drop. This is what
fault-tolerant "erudite" people call a "correct fault-tolerant system"
since the status of the replication is known at any time and the backups
can successfully recover the stateful filtering at any time. However,
the cost in terms of performance is *crap*, of course :), think of the
delay in the packet delivery of that stateful firewall, like getting a
coke from the moon to be "correct".

It's clear that synchronous replication is not feasible in today's
Internet systems. So, let's consider asynchronous replication, in the
case of stateful firewalls, this means that the packet is not kept until
the state-change is delivered, instead the packet continues its travel
and the state-change event is delivered to the backups in a "do your
best" approach. This is indeed a trade-off, we relax replication by
allowing better performance to make fault-tolerant Internet systems
feasible. But, in return, the backups are ready to recover a sub-set of
state-changes while others may not be recovered (think of long-standing
TCP established connections and very short TCP connections, the first
sort can be recovered, the latter may not). Nevertheless, asynchronous
replication works fine in practise.

But asynchronous replication may become useless to achieve
fault-tolerance if the rate of state-changes is high enough not to allow
backup nodes follow the primary node. Going back to the problem, if
Netlink cannot deliver the state-change, the backup would be able to
recover the filtering if the primary fails. At some point you have to
set a boundary limit after which you can ensure an acceptable
synchronization and performance, and if the boundary is overpassed from
one side, the other gets harmed.

I would have to tell sysadmins that conntrackd becomes unreliable under
heavy load in full near real-time mode, that would be horrible!.
Instead, with this option, I can tell them that, if they have selected
full near real-time event-driven synchronization, that reduces performance.

BTW, conntrackd has one batch mode that relaxes synchronization *a lot*
(it sends to the backup nodes the states that have been living in the
kernel conntrack table between a range of time, say, [10-20) seconds,
this also is possible. But, with the option that I'm proposing, we could
allow the network designer choose what synchronization approach it
prefers according to the network requirements. That includes that he/she
understands that he/she assumes a performance drop (which I have
measured in ~30% less with full TCP state replication of very short
connections in event-driven near real-time fashion, which I think that
it is close to the worst case).

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
