From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 28 Jul 2006 15:54:04 +1000
Message-ID: <1154066044.5159.130.camel@localhost.localdomain>
References: <1153966671.6904.71.camel@localhost.localdomain>
	 <20060726.221708.123400049.davem@davemloft.net>
	 <1153979173.6904.100.camel@localhost.localdomain>
	 <20060726.230028.00077989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.tip.net.au ([203.10.76.45]:47295 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1751975AbWG1FyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 01:54:07 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060726.230028.00077989.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-07-26 at 23:00 -0700, David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Thu, 27 Jul 2006 15:46:12 +1000
> 
> > Yes, my first thought back in January was how netfilter would interact
> > with this in a sane way.  One answer is "don't": once someone registers
> > on any hook we go into slow path.  Another is to run the hooks in socket
> > context, which is better, but precludes having the consumer in
> > userspace, which still appeals to me 8)
> 
> Small steps, small steps.  I have not ruled out userspace TCP just
> yet, but we are not prepared to go there right now anyways.  It is
> just the same kind of jump to go to kernel level netchannels as it is
> to go from kernel level netchannels to userspace netchannel based TCP.

I think I was unclear; the possibility of userspace netchannels adds
weight to the idea that we should rework netfilter hooks sooner rather
than later.

> > What would the tuple look like?  Off the top of my head:
> > SRCIP/DSTIP/PROTO/SPT/DPT/IN/OUT (where IN and OUT are boolean values
> > indicating whether the src/dest is local).
> > 
> > Of course, it means rewriting all the userspace tools, documentation,
> > and creating a complete new infrastructure for connection tracking and
> > NAT, but if that's what's required, then so be it.
> 
> I think we are able to finally talk seriously about revamping
> netfilter on this level because we finally have a good incentive to do
> so and some kind of model exists to work against.  Robert's trie might
> be able to handle your tuple very well, fwiw, perhaps even with
> prefixing.
> 
> But something occurs to me.  Socket has ID when it is created and
> goes to established state.  This means we have this tuple, and thus
> we can prelookup the netfilter rule and attach this cached lookup
> state on the socket.  Your tuple in this case is defined to be:
> 
> 	SRCIP/DSTIP/"TCP"/SPT/DPT/0/1
> 
> I do not know how practical this is, it is just some suggestion.
> 
> Would there be prefixing in these tuples?  That's where the trouble
> starts.  If you add prefixing, troubles and limitations of lookup of
> today reappear.  If you disallow prefixing, tables get very large
> but lookup becomes simpler and practical.

OK.  AFAICT, there are three ideas in play here (ignoring netchannels).
First, there should be a unified lookup for efficiency (Grand Unified
Cache).  Secondly, that netfilter hook users need to publish information
about what they are actually looking at if they are to use this lookup.
Thirdly, that smart cards can accelerate lookup.

(1) I am imagining some Grand Unified Flow Cache (Olsson trie?) that
holds (some subset of?) flows.  A successful lookup immediately after
packet comes off NIC gives destiny for packet: what route, (optionally)
what socket, what filtering, what connection tracking (& what NAT), etc?
I don't know if this should be a general array of fn & data ptrs, or
specialized fields for each one, or a mix.  Maybe there's a "too hard,
do slow path" bit, or maybe hard cases just never get put in the cache.
Perhaps we need a separate one for locally-generated packets, a-la
ip_route_output().  Anyway, we trade slightly more expensive flow setup
for faster packet processing within flows.

(2) To make this work sanely in the presence of netfilter hooks, we need
them to register the tuples they are interested in.  Not at the hook
level, but *in addition*.  For example, we need to know what flows each
packet filtering rule cares about.  Connection tracking wants to see the
first packet (and first reply packet), but then probably only want to
see packets with RST/SYN/FIN set.  (Erk, window tracking wants to see
every packet, but maybe we could do something).  NAT definitely needs to
see every packet on a connection which is natted.

One way to do this is to add a "have_interest" callback into the
hook_ops, which takes each about-to-be-inserted GUFC entry and adds any
destinies this hook cares about.  In the case of packet filtering this
would do a traversal and append a fn/data ptr to the entry for each rule
which could effect it.  

The other way is to have the hooks register what they are interested in
into a general data structure which GUFC entry creation then looks up
itself.  This general data structure will need to support wildcards
though.

We also need efficient ways of reflecting rule changes into the GUFC.
We can be pretty slack with conntrack timeouts, but we either need to
flush or handle callbacks from GUFC on timed-out entries.  Packet
filtering changes need to be synchronous, definitely.

(3) Smart NICs that do some flowid work themselves can accelerate lookup
implicitly (same flow goes to same CPU/thread) or explicitly (each
CPU/thread maintains only part of GUFC which it needs, or even NIC
returns flow cookie which is pointer to GUFC entry or subtree?).  AFAICT
this will magnify the payoff from the GUFC.

Sorry for the length,
Rusty.
-- 
Help! Save Australia from the worst of the DMCA: http://linux.org.au/law

