From: jamal <hadi@cyberus.ca>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: 09 Feb 2004 20:21:34 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076376094.1039.102.camel@jzny.localdomain>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
	 <1076338874.1026.36.camel@jzny.localdomain>
	 <Pine.LNX.4.58.0402100008580.1251@u.domain.uli>
	 <1076367038.1037.15.camel@jzny.localdomain>
	 <Pine.LNX.4.58.0402100114020.1251@u.domain.uli>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402100114020.1251@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Julian,

On Mon, 2004-02-09 at 18:52, Julian Anastasov wrote:
> 	Hello,
> 
> On Tue, 9 Feb 2004, jamal wrote:
> 
> > > 	Then where is better such flag to exist, for indev or
> > > for outdev?
> >
> > parse error. Are you agreeing it should be a sysctl?
> 
> 	May be, if we found usage for this, because I see the
> handling in this way (I should put this info in doc file later):
> 
> - if the target is not an ARP neighbour then it is already validated
> from ip_route_input (for example, target is some IP on PPP device
> and this device exists and is UP, so there is route we are using).

Is this always guaranteed? Example "ip route get" will always create
a cache entry but not a neighbor.

> In such case we do not need a validation phase (but may be we still
> need to delay the answer)
> 
> - we need delay (if configured via dev/proxy_delay) not for target
> validation reasons but just to lose the game with other authoritative
> hosts. For this reason we do not want to delay answers to unicast
> probes if we have such answer. There is one bad case here:
> authoritative hosts running in promisc mode. In such case we
> risk to win the race.
> 

This is true, but not in my setup where i guarantee there will be
no other authoritative response.
I think authoritative answer is the main reason for the race;
the fact that you can set proxy_delay to 0 when you need to (such as in
my case) is needed flexibility.

> 	As for the static proxy entries may be we do not want
> to delay the answers for them, I assume they are something like
> local addresses at ARP level? So, do we need to delay the
> pneigh_lookup case (fwd_proxy=0)?
> 

i am indiferent but would think the current behavior is fine.

> > what i meant was i am happy with the slight delay in some cases i get
> 
> 	Ah, this delay will stay, if configured. But it is
> not needed for the unicast case.
> 

ok

> > now; example host we are parping for sends a unicast probe - we would
> > immediately respond. Host sends a resolved IP packet - we attempt to
> > route and worst case we find that we dont have the target entry in our
> > cache; we arp at that point.
> 
> 	With the new changes we will respond to unicast probe
> immediately only if the target neighbour is marked valid in our
> cache. For non-ARP target devices the behaviour is same - immediate
> response.
> 

again back to my earlier question (and talking about ARP only): 
A host would only send us a unicast probe to begin with if it is
NUD_PROBE state (iirc); which means given the exchanges the cache entry
we have would more than likely be valid still i.e if you want to
optimize this portion you will be mostly doing a useless call. Agreed?

I suppose you are trying to shortcut this by not waiting until the arp
state machine takes effect - which is fine but i claim needs to be 
configurable over current behavior.

> You forgot the main reason I started this change: for
> neighbour state detection reasons it is bad the requestor to receive
> answer for target host when this host is down. The goal is to
> stop any traffic to target if it is not reachable and to use
> other paths. 

Ok, i wasnt aware of why you started this - its a neat hack which will
improve failover times; the SCTP folks would probably like this.
 
> Note that you have exactly such behaviour if target
> is routed via non-ARP device, ip_route_input fails and there is no
> answer. Assume such setup:
> 
> - many end hosts/routers using TIP as gw IP
> 
> - TIP is proxied from other routers runing proxy_arp
> 
> - above these routers are the uplink routers (DSL?) that have
> TIP configured
> 
> 	We want the end host to know the real TIP state and
> to use alternative paths. So, we want to proxy the neighbour
> state.
> 
> 	But in what I'm not sure yet is whether there is a
> usage that relies on immediate answer no matter the state.

I think that if you want fast discovery the way you are proposing it
is the better way. Of course this comes at the expense of extra
checks (even when they are unneeded as i have claimed so far in the
case of unicast probes)

> If we do not want to ignore such usage we have to add flag
> as you proposed. The question is: is it useful to provide
> immediate response as before without knowing the neighbour
> state, for the ARP cases.

I think knowing the state before response in itself is useful when
needed. This is the most useful thing in your patch; the other parts
you are throwing in as gravy on fries and they are a little 
suspicious ;->
The main thing is backward compatibility; for years this is the
way it has worked. In my setup for example i have no need for
your shortcut.

> > In your case, you will amortize that cost at arp time. In the case of
> > unicast probes (assuming a sane arp implementation on the other side)
> > you will actually be adding cost since mostly that entry will be in the
> > cache.
> 
> 	You mean the delay? I add it for other purposes, even
> if target is valid in the cache.

Just the extra call to check state before responding adds a little to
the overhead for no good reason.
If the arp cache is invalid when you respond, the principle of
conservation of work says that work will be done later, you just defered
it to route lookup time when an IP packet is sent.

> > In the case of broadcasts you could achieve the same effect by setting
> > the proxy_delay in /proc to zero.
> 
> 	True, if the administrator is sure that our box is the
> only responder for such targets he can set the delay to 0 to
> speedup the answers.
> 

Exactly my setup. So in this case i think this feature should stay.

> > > 	You are right, if proxy_delay is large the requestor can
> > > disappear from our cache but it is not fatal for us to send reply,
> > > we do not need cache entry for this. I'm not sure what is better, is
> > > it right to confirm the requestor without receiving recent event
> > > from it? If will be visible for too large proxy_delay values.
> >
> > I guess you could look at one view as possibly doing 2 neigh_event_ns()
> > and correct whereas the other is doing 1 but with the above side effect.
> 
> 	Our replies are always unicast to the lladdr. Do you still
> prefer 2 calls to neigh_event_ns (sorry, my english is too limited
> to understand correctly the above two lines :)) ?

You used the word "fatal";-> so i was pointing that the other option is
not fatal and it happens only when you queue to the proxy q.

I think i kept you busy and i am not really an parp expert, just a 
user ;->
Now where is Alexey when you need him? ;->

cheers,
jamal
