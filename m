From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 20 May 2003 17:36:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520.173607.88482742.davem@redhat.com>
References: <20030519220409.V39658@shell.cyberus.ca>
	<20030519.234624.123976229.davem@redhat.com>
	<20030520074848.U40843@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@shell.cyberus.ca
In-Reply-To: <20030520074848.U40843@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jamal Hadi <hadi@shell.cyberus.ca>
   Date: Tue, 20 May 2003 08:04:00 -0400 (EDT)

   Note: It may make sense that we have options to totaly remove
   the cache lookups if necessary - noone has proved a need for it at
   this point.

There is a need, thinking otherwise is quite a narrow viewpoint :-)
Let me explain.

Forward looking, Alexey and myself plan to extend the per-cpu flow
cache we designed for IPSEC policy lookups to apply to routing
and socket lookup.  There are two reasons to make this:

1) Per-cpu'ness.
2) Input route lookup turns into a "flow" lookup and thus may
   give you a TCP socket, for example.  It is the most exciting
   part of this work.

It can even be applied to netfilter entries.  It really is the
grand unified theory of flow handling :-)  You can look to
net/core/flow.c, it is the initial prototype and it is working
and being used already for IPSEC policies.  There are only minor
adjustments necessary before we can begin trying to apply it to
other things, but Alexey and myself know how to make them.

So the real argument: Eliminating sourced based keying of input
routes is a flawed idea.  Firstly, independant of POLICY based routing
(which is what it was originally made for) being able to block by
source address on input is a useful feature.  Secondly, if one must
make "fib_validate_source()" on each input packet, it destroys all
the posibility to make per-cpu flow caching a reality.  This is
because fib_validate_source() must walk the inetdev list and thus
grab a shared SMP lock.

Note that any attempt to remove source based keying of routing cache
entries on input (or eliminating the cache entirely) has this problem.

It also becomes quite cumbersome to move all of this logic over to
ip_input() or similar.  And because it will always use a shared SMP
lock it is guarenteed to be slower than the cache especially for
well-behaved flows.  So keep in mind that not all traffic is DoS :-)

(As a side note, and interesting area of discourse would be to see
 if DoS traffic can be somehow patternized, either explicitly in
 the kernel or via descriptions from the user.  People do this today
 via netfilter, but I feel we might be able to do something more
 powerful at the flow caching level, ie. do not build cache entries
 for things looking like unary-packet DoS flow)

None of this means that slowpath should not be improved if necessary.
On the contrary, I would welcome good kernel profiling output from
someone such as sim@netnation during such stress tests.
