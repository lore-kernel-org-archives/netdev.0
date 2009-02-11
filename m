From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netlink broadcast return value
Date: Wed, 11 Feb 2009 17:54:56 +0100
Message-ID: <499302E0.4070406@trash.net>
References: <4985A4C5.4050908@netfilter.org> <20090202.140533.121159038.davem@davemloft.net> <49903B03.2040302@trash.net> <4990B38A.3020207@netfilter.org> <4990BADA.7040309@trash.net> <4990C337.3040704@netfilter.org> <4991863F.3030800@trash.net> <4991CCC1.7080308@netfilter.org> <4992C827.20302@trash.net> <4992FF51.9010507@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4992FF51.9010507@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso wrote:
> First of all, sorry, this email is probably too long.

Indeed, I'm doing some trimminng :)

> Patrick McHardy wrote:
>> I'm aware of that. But you're adding a policy knob to control the
>> behaviour of a one-to-many interface based on what a single listener
>> (or maybe even two) want. Its not possible anymore to just listen to
>> events for debugging, since that might even lock you out.
> 
> Can you think of one example where one ctnetlink listener may not find
> useful reliable state-change reports? Still, this setting is optional
> (it will be disabled by default) and, if turned on, you can disable it
> for debugging purposes.

As I already said, "conntrack -E" used for debugging. Nobody cares
whether it misses a few events instead of causing dropped packets.
Whether its on or not by default is secondary to being the right
thing at all.

> Thinking more about it, reliable logging and monitoring would be even
> something interesting in terms of security.

I don't doubt that, I question the mechanism.

>> This seems very wrong to me. And I don't even see a reason to do
>> this since its easy to use unicast and per-listener state.
> 
> Netlink unicast would not be of any help either if you want reliable
> state-change reporting via ctnetlink. If one process receives the event
> and the other does not, you would also need to drop the packet to
> perform reliable logging.

Yes, and you don't need to if you don't want "reliable" logging.
The point is that you can choose per socket. Only if a socket that
really wants this doesn't get a copy you drop.

>>> Using unicast would not do any different from broadcast as you may have
>>> two listeners receiving state-changes from ctnetlink via unicast, so the
>>> problem would be basically the same as above if you want reliable
>>> state-change information at the cost of dropping packets.

No, its not the same. ctsync sets big receive buffers and requests
"reliable" delivery, "conntrack -E" does nothing special and doesn't
care whether messages are dropped because its receive queue is too
small.

>> Only the processes that actually care can specify this behaviour.
> 
> No, because this behaviour implies that the packet would be drop if the
> state-change is not delivered correctly to all. It has to be an on/off
> behaviour for all listeners.

You keep saying that, but its only the case because the way you
implemented it requires this. Why would ctsync care whether
conntrack -E missed a packet?

>> [...]
> I would have to tell sysadmins that conntrackd becomes unreliable under
> heavy load in full near real-time mode, that would be horrible!.
> Instead, with this option, I can tell them that, if they have selected
> full near real-time event-driven synchronization, that reduces performance.

Again, I'm not arguing about the option but about making it a
sysctl or something that affects all (ctnetlink) sockets whether
they care or not. You could even make it a per-broadcast listener
option, but the sysctl is effectively converting broadcast
operation to reliable unicast semantics and that seems wrong.
