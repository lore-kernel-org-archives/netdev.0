From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Thu, 22 May 2003 22:42:49 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030522.224249.52179344.davem@redhat.com>
References: <20030520074848.U40843@shell.cyberus.ca>
	<20030520.173607.88482742.davem@redhat.com>
	<20030521084023.Y43543@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: hadi@shell.cyberus.ca
In-Reply-To: <20030521084023.Y43543@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

   From: Jamal Hadi <hadi@shell.cyberus.ca>
   Date: Wed, 21 May 2003 09:03:19 -0400 (EDT)

   On Tue, 20 May 2003, David S. Miller wrote:
   
   > Forward looking, Alexey and myself plan to extend the per-cpu flow
   > cache we designed for IPSEC policy lookups to apply to routing
   > and socket lookup.  There are two reasons to make this:
   >
   > 1) Per-cpu'ness.
   
   IPIs to synchronize?
   
It is a good question.  IPIs are one way to coorindate a flush or
state synchronization.

But this method is perhaps overblown for things like netfilter and
IPSEC policy configuration changes.

One way we can deal with those is via a generation count.  Any time
you insert/delete a netfilter or IPSEC policy rule, it potentially
affects each and every flow cache entry.  So bumping the generation
cound and checking this at flow lookup time is how we solve that
problem.

It is the same thing to do to handle routing table changes as well.
Anyways, this is what net/core/flow.c supports now.

Where this model does not fit is for sockets.  They tend to change the
state of exactly one flow.  We will need mechanisms by which to handle
this.

But, there is a flaw with the generation count scheme... One thing
Alexey has reminded me is that you can't defer cache flushing to
lookup time, because if traffic stops then the whole engine deadlocks
since nothing will release the references inside of the flow cache.

This brings me to another topic which is attempting to even avoid
the reference counting.  This is a very difficult problem, but the
benefits are large, it means that all the data can be shared by
cpus read-only because no writes occur to grab the reference to the
object the flow cache entry points to (socket, route, netfilter rule,
IPSEC policy, etc.)

   > 2) Input route lookup turns into a "flow" lookup and thus may
   >    give you a TCP socket, for example.  It is the most exciting
   >    part of this work.
   
   For packets that are being forwarded or even host bound, why start at
   routing?

It is just how I describe where this occurs.  It has nothing to
do with routing.  Route lookups just so happen to be the first
thing we do when we receive an IPv4 packet :-)

   This should be done much further below.

I don't understand, what I have described is as far into tbe basement
as one can possibly go :-)  If you go any deeper, you do not know
how even to parse the packet.

   This also gives you opportunity to drop early. A flow index could be
   created there that could be used to index into the route table for
   example. Maybe routing by fwmark would then make sense.
   
Flow is made up of protocol specific details.  Please look to
include/net/flow.h:struct flowi, it is how we describe the identity of
what I am calling a flow.

   Also the structure itself had the grandiose view that routing is
   the mother of them all i.e you "fit everything around routing" not
   "fit routing around other things".

Routing describes the virtual path a packet takes within the
stack.  It tells us what to do with packet, therefore it in fact
is "mother of them all".  It is all that networking stack does. :-)
   
Show me some example where you are describing how the stack will
handle a packet and that this is not some form of routing :-)

   I think the flowi must be captured way before IP is hit and reused
   by IP and other sublayers. policy routing dropping or attempts to
   fib_validate_source() the packets should  utilize that scheme (i.e install
   filters below ip) and tag(fwmark) or drop them on the floor before they
   hit IP.

If you do not yet know packet is IP, you have no way to even parse
it into flowi.

Our wires are crossed...

Look, forget that I said that we will make flow determination where we
make input route lookups right now.  Replace this with "the first
thing we will do with an IP packet is build a flowi (by parsing it)
and then look up that flow matching this key".

   I think post 2.6 we should just rip apart the infrastructure
   and rethink things ;-> (should i go into hiding now?;->)
   
I think we suggest very similar things.  Look, for policy dropped
flows they will not make it much further than the first few lines of
ip_input.c:ip_rcv()  It must be called by netif_receive_skb() anyways,
and all calling it says is "this is ipv4 packet" and we must know this
to be able to parse it.

   Should be pretty easy to do with a filter framework at the lower
   layers such as the one i did with ingress qdisc.
   
Ok, publish this code so we can talk in a more precise language.
:-)

If it is some "if (proto == ETH_P_IP) { ... parse ipv4 header" I will
be very disappointed.

   > None of this means that slowpath should not be improved if necessary.
   > On the contrary, I would welcome good kernel profiling output from
   > someone such as sim@netnation during such stress tests.
   
   nod.
   
I note that we have aparently killed the worst of these daemons over
the past 24 hours :-)
