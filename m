From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 17:10:46 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409211652050.6668-100000@netcore.fi>
References: <20040921134918.GK1307@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Netdev List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040921134918.GK1307@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Sep 2004, Harald Welte wrote:
> > The situation with IPv6 is not much different than with IPv4.
> 
> I disagree (see below).

OK, I agree that there are more significant differentes wrt. router
DoS attacks because the number of routers which have /64 subnets,
vulnerable to an attack, is probably larger.

> > It's better in the sense that nobody will be portscanning the whole 
> > address space or subnets as a means to look for nodes.  
> 
> I agree, but people will do it as a means to DoS the routers...

OK, if we talk about this solely from the perspective of router DoS 
attack, then we have slightly different constraints as if we looked 
only at the "host" perspective, or both from the host and router 
perspective.

> > It's worse in the sense that there is more space in each subnet for
> > doing aggressive probing -- but this may not be a big issue with a
> > good algorithm and a threshold.
> 
> So what is that 'good algorithm'.  The current Linux algorithm is from
> my point of view (only tested with ipv4) not very good when it comes to
> high numbers of neighbours.

True.
 
> > In short, I don't think there needs to be anything special for IPv6.  
> > Just the same mechanisms as for IPv4 -- at some threshold, start 
> > garbage collecting more aggressively, using a "least-recently-used" 
> > algorithm (or the like). 
> 
> Yes, but let's assume somebody floods you with 100MBit wirespeed, that's
> 148kpps, meaning you will have to have a limit of at least 148.800 plus
> the number of 'real' hosts directly attached to your system in order to
> cope with this.  Otherwise you will end up having all your neighbour
> cache entries filled with INCOMPLETE entries, whose retrans_time of 1HZ
> is not reached yet.
> 
> To do some quick calculations, this would require some 23.8 MByte RAM on
> a 32bit platform(!)
> 
> Now what if you have multiple interfaces, or you start thinking about
> gigabit ethernet...

I may be in the minority, but I don't think 24 MB is a big deal. :)
Remember that the same box will need to be able to sustain 150 kpps in
any case -- and the low-end boxes probably can't do it.

If you get DoS'ed with that kind of flood, you're pretty much out of
luck, unless someone comes up with a nice algorithm to mitigate this
problem.  I don't know if such has been found yet. 

One possibility might be keeping track of the ingress interface, and
restricting ARP/ND messages to N (e.g., 100 or 1000/sec by default)  
per ingress interface.  That would allow "internal" ND lookups to work
even under an external attack.  

A more complex alternative might be purposefully delaying [at least on
untrusted interfaces] ARP/ND requests [e.g., by 1 or 2 seconds] which
request an address which does not already have any ARP/ND state at the
router, then check out how many new messages have arrived during that
delay period (and do some rate-limiting magic based on that). Read:
store the "known valid" ND state for as long as possible, and when you
get hit by the flood, you could de-prefer or ignore those requests
which pertain to addresses which haven't communicated with the router
in the last X [timevalue].

Another variation of the above might be two algorithms: just do every
lookup as normal until a "potential attack threshold" (e.g., 1000
entries, excluding those packets allowed by the restriction below).  
Then, restrict ARP/ND requests to X pps (e.g., 100 pps) which do not
relate to an address that already exists in the cache. This should
keep ND/ARP operational under an attack for the legitimate hosts,
while allowing some amount of ND traffic.

There are probably other ways of mitigating the problem in a way that
it does the least feasible amount of damage to the by-standers.

One might look at what (if anything) others do under these 
circumstances, e.g., BSD's.
 
> > To constraint remote resource exhaustion exploits please make sure 
> > that the algorithm is sufficiently can also deal with the threat 
> > described at RFC 3756 section 4.3.2.
> 
> Isn't that exactly what we're talking about?
> To quote from that RFC:
> 
>   In a way, this problem is fairly similar to the TCP SYN flooding
>   problem.  For example, rate limiting Neighbor Solicitations,
>   restricting the amount of state reserved for unresolved
>   solicitations, and clever cache management may be applied.
> 
> So they encourage limiting the number of unresolved solicitations.  We
> don't do that at this point, and allow all of the neighbour cache be
> filled with them...

Agreed, if we are restricting to this particular problem.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
