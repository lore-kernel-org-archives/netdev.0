From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: Route cache performance under stress
Date: Wed, 21 May 2003 09:03:19 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521084023.Y43543@shell.cyberus.ca>
References: <20030519220409.V39658@shell.cyberus.ca> <20030519.234624.123976229.davem@redhat.com>
 <20030520074848.U40843@shell.cyberus.ca> <20030520.173607.88482742.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sim@netnation.com, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030520.173607.88482742.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 20 May 2003, David S. Miller wrote:

>    From: Jamal Hadi <hadi@shell.cyberus.ca>
>    Date: Tue, 20 May 2003 08:04:00 -0400 (EDT)
>
>    Note: It may make sense that we have options to totaly remove
>    the cache lookups if necessary - noone has proved a need for it at
>    this point.
>
> There is a need, thinking otherwise is quite a narrow viewpoint :-)
> Let me explain.
>
> Forward looking, Alexey and myself plan to extend the per-cpu flow
> cache we designed for IPSEC policy lookups to apply to routing
> and socket lookup.  There are two reasons to make this:
>
> 1) Per-cpu'ness.

IPIs to synchronize?

> 2) Input route lookup turns into a "flow" lookup and thus may
>    give you a TCP socket, for example.  It is the most exciting
>    part of this work.
>

For packets that are being forwarded or even host bound, why start at
routing? This should be done much further below. Not sure how to deal
with packets originating from the host.
For example i moved the ingress qdisc to way down before IP is hit
(I can post the patch) and it works quiet well at the moment only with
the u32 classifier (you could use the route classifier for ip packets).
I have a packet editor action so i can do some form of ARP/MAC address
aliasing ;->
This also gives you opportunity to drop early. A flow index could be
created there that could be used to index into the route table for
example. Maybe routing by fwmark would then make sense.

> It can even be applied to netfilter entries.  It really is the
> grand unified theory of flow handling :-)  You can look to
> net/core/flow.c, it is the initial prototype and it is working
> and being used already for IPSEC policies.  There are only minor
> adjustments necessary before we can begin trying to apply it to
> other things, but Alexey and myself know how to make them.
>

I did look at the code initially when it showed up. It does look sane.
Infact i raised the issue about the same time whether pushing and popping
these structures was the best way to go. Another approach would
be to use a "hub and spoke" dispatch based scheme which i use in the
effort to get better traffic control actions. Also the structure itself
had the grandiose view that routing is the mother of them all
i.e you "fit everything around routing" not "fit routing around other
things". Note: routing aint the only sexy thing these days, so unified
theory based on one sexy thing may be unfair to other sexy things;->

> So the real argument: Eliminating sourced based keying of input
> routes is a flawed idea.  Firstly, independant of POLICY based routing
> (which is what it was originally made for) being able to block by
> source address on input is a useful feature.  Secondly, if one must
> make "fib_validate_source()" on each input packet, it destroys all
> the posibility to make per-cpu flow caching a reality.  This is
> because fib_validate_source() must walk the inetdev list and thus
> grab a shared SMP lock.
>

I think the flowi must be captured way before IP is hit and reused
by IP and other sublayers. policy routing dropping or attempts to
fib_validate_source() the packets should  utilize that scheme (i.e install
filters below ip) and tag(fwmark) or drop them on the floor before they
hit IP.

> Note that any attempt to remove source based keying of routing cache
> entries on input (or eliminating the cache entirely) has this problem.
>

nod.

> It also becomes quite cumbersome to move all of this logic over to
> ip_input() or similar.  And because it will always use a shared SMP
> lock it is guarenteed to be slower than the cache especially for
> well-behaved flows.  So keep in mind that not all traffic is DoS :-)
>

true. I think post 2.6 we should just rip apart the infrastructure
and rethink things ;-> (should i go into hiding now?;->)

> (As a side note, and interesting area of discourse would be to see
>  if DoS traffic can be somehow patternized, either explicitly in
>  the kernel or via descriptions from the user.  People do this today
>  via netfilter, but I feel we might be able to do something more
>  powerful at the flow caching level, ie. do not build cache entries
>  for things looking like unary-packet DoS flow)
>

Should be pretty easy to do with a filter framework at the lower
layers such as the one i did with ingress qdisc.

> None of this means that slowpath should not be improved if necessary.
> On the contrary, I would welcome good kernel profiling output from
> someone such as sim@netnation during such stress tests.
>

nod.

cheers,
jamal
