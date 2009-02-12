From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netlink broadcast return value
Date: Thu, 12 Feb 2009 06:07:32 +0100
Message-ID: <4993AE94.1000104@trash.net>
References: <4985A4C5.4050908@netfilter.org> <20090202.140533.121159038.davem@davemloft.net> <49903B03.2040302@trash.net> <4990B38A.3020207@netfilter.org> <4990BADA.7040309@trash.net> <4990C337.3040704@netfilter.org> <4991863F.3030800@trash.net> <4991CCC1.7080308@netfilter.org> <4992C827.20302@trash.net> <4992FF51.9010507@netfilter.org> <499302E0.4070406@trash.net> <49933CBE.8010108@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49933CBE.8010108@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso wrote:
>>> Can you think of one example where one ctnetlink listener may not find
>>> useful reliable state-change reports? Still, this setting is optional
>>> (it will be disabled by default) and, if turned on, you can disable it
>>> for debugging purposes.
>> As I already said, "conntrack -E" used for debugging. Nobody cares
>> whether it misses a few events instead of causing dropped packets.
>> Whether its on or not by default is secondary to being the right
>> thing at all.
> 
> In particular, conntrack -E returns an error message when it hits
> ENOBUFS, so it's a bad example.

You're proposing to drop packets, I don't think an error message
after the fact makes up for that :)

> Indeed, I think that other programs in
> userspace should do this if they don't know what to do with ENOBUFS,
> otherwise increase the buffer up to a reasonable limit (set by the
> user), and then report that this limit has been reached telling that
> they have become unreliable (or depending on the sysctl value that I'm
> proposing, tell that they may drop packets).
> 
> And I think that there are tons of interfaces that userspace programs
> can abuse to do the wrong thing.

Thats true, in this case the userspace program doesn't need to
do anything wrong though.

>>> I would have to tell sysadmins that conntrackd becomes unreliable under
>>> heavy load in full near real-time mode, that would be horrible!.
>>> Instead, with this option, I can tell them that, if they have selected
>>> full near real-time event-driven synchronization, that reduces
>>> performance.
>> Again, I'm not arguing about the option but about making it a
>> sysctl or something that affects all (ctnetlink) sockets whether
>> they care or not. You could even make it a per-broadcast listener
>> option, but the sysctl is effectively converting broadcast
>> operation to reliable unicast semantics and that seems wrong.
> 
> And again, you point that this should be per-socket, but how can you
> make this option per-socket? The only way that I see to make
> state-change reporting reliable is to drop the packet to force the peer
> to retransmit the packet and trigger the same state-change, and that
> affect all ctnetlink listeners.

For unicast its obviously simple, for broadcast you'd need something
like this:

err = 0;
for (all netlink sockets; sk && !err; ...) {
	skb = skb_clone(...)
	if (skb == NULL) {
		if (sk->flags & NETLINK_HIGHLY_RELIABLE)
			err = -ENOBUFS;
		continue;
	}
	...
}

So you're returning an error when at least one of the "reliable"
sockets doesn't get its delivery.
