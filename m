From: alex@pilosoft.com
Subject: NF/tc/routing thoughts
Date: Thu, 19 Feb 2004 13:05:11 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402191304530.22885-100000@paix.pilosoft.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've just completed an implementation of a interesting [to me :] tweak to
linux routing using tc/netfilter - limiting certain destinations [by realm
or nfmark] to certain amount of traffic and sending 'overflow' traffic to
different next-hops [by adjusting route-cache]. This is much useful in a
number of situations, such as if one has "paid-for" circuits
(traffic-insensitive) and additionally circuits where one pays for the
traffic. As an example, this allows me to saturate 100M link at 98Mbps
average utilization with 0.1% max packet loss and 10ms max latency
increase. 

This was implemented using Jamal's tc action, and tweaks to ipt_ROUTE and
ipv4/route.c to clean route-cache on demand.

Some thoughts that accumulated over time:

a) My changes to ipt_ROUTE and route.c allow for "reroute" based on
packet's current classification [nfmark, etc] (essentially, doing the
ip_route_output decision for a second time based on current packet state). 
This is somewhat ugly, but necessary due to chicken-and-egg problem:
To find proper next-hop (on a non-overloaded link), I need to find where 
the packet is about to go, and change it if that link is overloaded. 

Using tc alone does not suffice: tc on ingress is done prior to routing
decision, tc on egress is done after routing decision. Ideally, I would
like a hook into routing table to have a function called during fib/cache
lookup to determine next-hop, but I think that may be more gross than what
I've done.

At any case, should I submit the patches for this, or these are 
too-specific-purpose and not interesting to others?

b) tc filtering seems to have the same purpose as netfilter. Difference
is, tc is better implemented [optimizations-wise], less documented, but
has less features.

* For example, I can't do not/and/or operations on a packet using tc
classifiers [without additional qdiscs]. This doesn't seem to be very hard
to fix, but I'm wondering if this is intentional. [I.E. is tc intended to
be netfilter's faster, simpler little brother?]

* Jamal's "tc action" is great - however, it is only implemented for u32
classifier.  I added code for fw and route classifier to support this - 
but it just seems to me that this should be something generic, supported 
by all classifiers. Should it? ;)

c) If HiPAC was integrated as just another tc classifier, it would provide
all expressive power of netfilter in a tc rule, which would be quite 
useful - [current classifier list isn't good enough]

d) Thinking further about routing: routing itself is just an instance of
packet classification according to RPDB and routing table[s]. Current
hash-based route-cache and zone-based fib are not appropriate for router
handling internet traffic and DoS. [IOW, fn_hash_lookup takes forever on a
router with 125k routes]. There are better trie-based algorithms for route
lookups , and [IMVHO], once slow-path (ip_route_xxx_slow) is sufficiently
fast, there will be no need for route-cache itself.

The most interesting thing [to me, I am focused on attaining high pps
rates with random traffic :] would be to apply hipac fast classification
algorithms to the problem of ip routing [populate hipac classification
tree with information from rpdb and routing table]. Is anyone interested
in doing that? More importantly, would any scheme like that be considered
for kernel inclusion?

My own skills [and time available for coding] are very deficient to do the
above, but I would be willing to sponsor someone who has interest in it.

So, any takers?
