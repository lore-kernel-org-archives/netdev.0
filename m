From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Tue, 10 Feb 2004 11:44:23 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402101028400.1158@u.domain.uli>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
 <1076338874.1026.36.camel@jzny.localdomain>  <Pine.LNX.4.58.0402100008580.1251@u.domain.uli>
  <1076367038.1037.15.camel@jzny.localdomain>  <Pine.LNX.4.58.0402100114020.1251@u.domain.uli>
 <1076376094.1039.102.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1076376094.1039.102.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 9 Feb 2004, jamal wrote:

> Is this always guaranteed? Example "ip route get" will always create
> a cache entry but not a neighbor.

	rt_intern_hash shows that it is created and I also checked
it by using printk, the entry is freed some time after the routing
cache entry is deleted, later may be when dst is deleted and
neigh_periodic_timer removes it.

> This is true, but not in my setup where i guarantee there will be
> no other authoritative response.
> I think authoritative answer is the main reason for the race;
> the fact that you can set proxy_delay to 0 when you need to (such as in
> my case) is needed flexibility.

	So, a device flag seems as the only alternative to say
that you really want immediate answer no matter what the target
state is.

> > 	With the new changes we will respond to unicast probe
> > immediately only if the target neighbour is marked valid in our
> > cache. For non-ARP target devices the behaviour is same - immediate
> > response.
> >
>
> again back to my earlier question (and talking about ARP only):
> A host would only send us a unicast probe to begin with if it is
> NUD_PROBE state (iirc); which means given the exchanges the cache entry
> we have would more than likely be valid still i.e if you want to
> optimize this portion you will be mostly doing a useless call. Agreed?

	Yes, requestor can be in PROBE state sending unicasts
but for us the target can be already unreachable.

> I suppose you are trying to shortcut this by not waiting until the arp
> state machine takes effect - which is fine but i claim needs to be
> configurable over current behavior.

	Sometimes when delay is not 0 the immediate neigh_event_send
has chance to learn the target's state before the request is
dequeued for answer. But if delay is configured to 0 we have to
drop the first request because we do not have real answer, we
have to wait for 2nd request. The goal is not to give false answers
even for unicast requests. To avoid such one-second delay we can
walk the proxy_queue when target answers and to propagate the
answer to all queued requests but it will take too many CPU cycles,
I think. So, we have three options when delay is set to 0:

1. the first request is dropped if there is no valid entry for target

2. we lie and send false answers to unicast probes, for long time
after target becomes unreachable

3. we introduce intentional delay (the configured delay is 0),
we queue this request and later probably reply to it

I can agree with you (for case 2) only if the requestor is
not going to send unicast probes forever. But looking at the
end of arp_process if Linux is the requestor it will enter
NUD_REACHABLE state after receiving unicast reply. So, may
be this is going to live forever? It seems the periodic timer
is going to loop between
NUD_REACHABLE -> NUD_STALE -> NUD_DELAY -> NUD_PROBE (sending
unicasts) -> and then we receive false unicast reply -> loop

> > You forgot the main reason I started this change: for
> > neighbour state detection reasons it is bad the requestor to receive
> > answer for target host when this host is down. The goal is to
> > stop any traffic to target if it is not reachable and to use
> > other paths.
>
> Ok, i wasnt aware of why you started this - its a neat hack which will
> improve failover times; the SCTP folks would probably like this.

	But it will drop first requests if delay is set to 0 :)

> > 	But in what I'm not sure yet is whether there is a
> > usage that relies on immediate answer no matter the state.
>
> I think that if you want fast discovery the way you are proposing it
> is the better way. Of course this comes at the expense of extra
> checks (even when they are unneeded as i have claimed so far in the
> case of unicast probes)

	It seems they are needed if we want to provide valid answers

> > If we do not want to ignore such usage we have to add flag
> > as you proposed. The question is: is it useful to provide
> > immediate response as before without knowing the neighbour
> > state, for the ARP cases.
>
> I think knowing the state before response in itself is useful when
> needed. This is the most useful thing in your patch; the other parts
> you are throwing in as gravy on fries and they are a little
> suspicious ;->
> The main thing is backward compatibility; for years this is the
> way it has worked. In my setup for example i have no need for
> your shortcut.

	Yes, it seems it serves only failover purposes

> > > In your case, you will amortize that cost at arp time. In the case of
> > > unicast probes (assuming a sane arp implementation on the other side)
> > > you will actually be adding cost since mostly that entry will be in the
> > > cache.
> >
> > 	You mean the delay? I add it for other purposes, even
> > if target is valid in the cache.
>
> Just the extra call to check state before responding adds a little to
> the overhead for no good reason.

	The good news is that it is cached during the reachable_time :)

> If the arp cache is invalid when you respond, the principle of
> conservation of work says that work will be done later, you just defered
> it to route lookup time when an IP packet is sent.

	The main thing is that I do not want the requestor to add
routing cache entry for this dead path because such entries are going
to flood us with IP [re]transmissions which is not needed. The best way
is the requestor to avoid the failed target IP as gateway and to cache
another (probably) reachable target. No other benefits, I think.
For this, the requestor should switch from PROBE to FAILED.

> > 	True, if the administrator is sure that our box is the
> > only responder for such targets he can set the delay to 0 to
> > speedup the answers.
> >
>
> Exactly my setup. So in this case i think this feature should stay.

	So, how are we going to support it? Additional flag?
If we do not support it we are going to drop the first request
and to answer the next one. Or may be we can introduce delay?

> I think i kept you busy and i am not really an parp expert, just a
> user ;->

	Thank you for your time :) We should check this issue
from all perspectives.

> cheers,
> jamal

Regards

--
Julian Anastasov <ja@ssi.bg>
