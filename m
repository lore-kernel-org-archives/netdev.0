From: jamal <hadi@cyberus.ca>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: 10 Feb 2004 05:48:10 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076410090.1039.578.camel@jzny.localdomain>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
	 <1076338874.1026.36.camel@jzny.localdomain>
	 <Pine.LNX.4.58.0402100008580.1251@u.domain.uli>
	 <1076367038.1037.15.camel@jzny.localdomain>
	 <Pine.LNX.4.58.0402100114020.1251@u.domain.uli>
	 <1076376094.1039.102.camel@jzny.localdomain>
	 <Pine.LNX.4.58.0402101028400.1158@u.domain.uli>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402101028400.1158@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-02-10 at 04:44, Julian Anastasov wrote:
> 	Hello,
> 
> On Tue, 9 Feb 2004, jamal wrote:
> 
> > Is this always guaranteed? Example "ip route get" will always create
> > a cache entry but not a neighbor.
> 
> 	rt_intern_hash shows that it is created and I also checked
> it by using printk, the entry is freed some time after the routing
> cache entry is deleted, later may be when dst is deleted and
> neigh_periodic_timer removes it.
> 

I believe it would work even if there is no neighbor resolved yet.
i.e it depends only on a route being resolvable not necessarily
having the next hop existing already in arp cache. Try get on some host
that doesnt exist in cache yet - try on some fake address on a directly
connected subnet (make sure you pick a host that doesnt exist and
therefore will never be reached).

> > This is true, but not in my setup where i guarantee there will be
> > no other authoritative response.
> > I think authoritative answer is the main reason for the race;
> > the fact that you can set proxy_delay to 0 when you need to (such as in
> > my case) is needed flexibility.
> 
> 	So, a device flag seems as the only alternative to say
> that you really want immediate answer no matter what the target
> state is.

nod.

> >
> > again back to my earlier question (and talking about ARP only):
> > A host would only send us a unicast probe to begin with if it is
> > NUD_PROBE state (iirc); which means given the exchanges the cache entry
> > we have would more than likely be valid still i.e if you want to
> > optimize this portion you will be mostly doing a useless call. Agreed?
> 
> 	Yes, requestor can be in PROBE state sending unicasts
> but for us the target can be already unreachable.

This is true; what i am saying is for this to happen more than likely
something odd must have happened ex: the cable towards the target may
have been pulled.i.e the chances of this happening just because the
arp cache expired are low. The arp cache would exist because the
initial states would have created it.

> > I suppose you are trying to shortcut this by not waiting until the arp
> > state machine takes effect - which is fine but i claim needs to be
> > configurable over current behavior.
> 
> 	Sometimes when delay is not 0 the immediate neigh_event_send
> has chance to learn the target's state before the request is
> dequeued for answer. But if delay is configured to 0 we have to
> drop the first request because we do not have real answer, we
> have to wait for 2nd request. The goal is not to give false answers
> even for unicast requests. 

But the above assumes there are false alarms in all cases ;->

> To avoid such one-second delay we can
> walk the proxy_queue when target answers and to propagate the
> answer to all queued requests but it will take too many CPU cycles,
> I think. So, we have three options when delay is set to 0:
> 
> 1. the first request is dropped if there is no valid entry for target
> 
> 2. we lie and send false answers to unicast probes, for long time
> after target becomes unreachable

This is current behavior; i wouldnt say we lie rather we send educated
response back. 

> 
> 3. we introduce intentional delay (the configured delay is 0),
> we queue this request and later probably reply to it
> 
> I can agree with you (for case 2) only if the requestor is
> not going to send unicast probes forever. 

Thats why i asked if you are trying to catch insane implementation.
In my case everything is Linux. Ok, theres some pollution with
a CISCO upstream, but that seems to have a sane arp too.
Leave #2 with a flag to ask for for neigh_event_send() to be used
when needed.

> But looking at the
> end of arp_process if Linux is the requestor it will enter
> NUD_REACHABLE state after receiving unicast reply. So, may
> be this is going to live forever? It seems the periodic timer
> is going to loop between
> NUD_REACHABLE -> NUD_STALE -> NUD_DELAY -> NUD_PROBE (sending
> unicasts) -> and then we receive false unicast reply -> loop

Well, yeah - an insane implementation will cause a lot of grief;

[..]

> > > 	You mean the delay? I add it for other purposes, even
> > > if target is valid in the cache.
> >
> > Just the extra call to check state before responding adds a little to
> > the overhead for no good reason.
> 
> 	The good news is that it is cached during the reachable_time :)
> 
> > If the arp cache is invalid when you respond, the principle of
> > conservation of work says that work will be done later, you just defered
> > it to route lookup time when an IP packet is sent.
> 
> 	The main thing is that I do not want the requestor to add
> routing cache entry for this dead path because such entries are going
> to flood us with IP [re]transmissions which is not needed. The best way
> is the requestor to avoid the failed target IP as gateway and to cache
> another (probably) reachable target. No other benefits, I think.
> For this, the requestor should switch from PROBE to FAILED.
> 

I dont question the validity of this portion of your patch.
i.e it is an improvement in certain cases - the cost is only an extra
neigh_event_send(). But because it is not needed 100% of the time given
the educated assumption being made right now, i think the behavior
should be configurable. For me #2 breaks only if the target dissapeares
(cable gone or target removed). 

> > > 	True, if the administrator is sure that our box is the
> > > only responder for such targets he can set the delay to 0 to
> > > speedup the answers.
> > >
> >
> > Exactly my setup. So in this case i think this feature should stay.
> 
> 	So, how are we going to support it? Additional flag?
> If we do not support it we are going to drop the first request
> and to answer the next one. Or may be we can introduce delay?

We should support it. It should just be turned off by default.
It seems to me it should be per device flag with ability to turn it off
for all devices too, no?

cheers,
jamal
