From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Mon, 31 Jul 2006 21:47:29 -0700 (PDT)
Message-ID: <20060731.214729.35358981.davem@davemloft.net>
References: <1153979173.6904.100.camel@localhost.localdomain>
	<20060726.230028.00077989.davem@davemloft.net>
	<1154066044.5159.130.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36549
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751565AbWHAEsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 00:48:12 -0400
To: rusty@rustcorp.com.au
In-Reply-To: <1154066044.5159.130.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 28 Jul 2006 15:54:04 +1000

> (1) I am imagining some Grand Unified Flow Cache (Olsson trie?) that
> holds (some subset of?) flows.  A successful lookup immediately after
> packet comes off NIC gives destiny for packet: what route, (optionally)
> what socket, what filtering, what connection tracking (& what NAT), etc?
> I don't know if this should be a general array of fn & data ptrs, or
> specialized fields for each one, or a mix.  Maybe there's a "too hard,
> do slow path" bit, or maybe hard cases just never get put in the cache.
> Perhaps we need a separate one for locally-generated packets, a-la
> ip_route_output().  Anyway, we trade slightly more expensive flow setup
> for faster packet processing within flows.

So, specifically, one of the methods you are thinking about might
be implemented by adding:

	void (*input)(struct sk_buff *, void *);
	void *input_data;

to "struct flow_cache_entry" or whatever replaces it?

This way we don't need some kind of "type" information in
the flow cache entry, since the input handler knows the type.

> One way to do this is to add a "have_interest" callback into the
> hook_ops, which takes each about-to-be-inserted GUFC entry and adds any
> destinies this hook cares about.  In the case of packet filtering this
> would do a traversal and append a fn/data ptr to the entry for each rule
> which could effect it.  

Can you give a concrete example of how the GUFC might make use
of this?  Just some small abstract code snippets will do.

> The other way is to have the hooks register what they are interested in
> into a general data structure which GUFC entry creation then looks up
> itself.  This general data structure will need to support wildcards
> though.

My gut reaction is that imposing a global data structure on all object
classes is not prudent.  When we take a GUFC miss, it seems better we
call into the subsystems to resolve things.  It can implement whatever
slow path lookup algorithm is most appropriate for it's data.

> We also need efficient ways of reflecting rule changes into the GUFC.
> We can be pretty slack with conntrack timeouts, but we either need to
> flush or handle callbacks from GUFC on timed-out entries.  Packet
> filtering changes need to be synchronous, definitely.

This, I will remind, is similar to the problem of doing RCU locking
of the TCP hash tables.

> (3) Smart NICs that do some flowid work themselves can accelerate lookup
> implicitly (same flow goes to same CPU/thread) or explicitly (each
> CPU/thread maintains only part of GUFC which it needs, or even NIC
> returns flow cookie which is pointer to GUFC entry or subtree?).  AFAICT
> this will magnify the payoff from the GUFC.

I want to warn you about HW issues that I mentioned to Alexey the
other week.  If we are not careful, we can run into the same issues
TOE cards run into, performance wise.

Namely, it is important to be careful about how the GUFC table entries
get updated in the card.  If you add them synchronously, your
connection rates will deteriorate dramatically.

I had the idea of a lazy scheme.  When we create a GUFC entry, we
tack it onto a DMA'able linked list the card uses.  We do not
notify the card, we just entail the update onto the list.

Then, if the card misses it's on-chip GUFC table on an incoming
packet, it checks the DMA update list by reading it in from memory.
It updates it's GUFC table with whatever entries are found on this
list, then it retries to classify the packet.

This seems like a possible good solution until we try to address GUFC
entry deletion, which unfortunately cannot be evaluated in a lazy
fashion.  It must be synchronous.  This is because if, for example, we
just killed off a TCP socket we must make sure we don't hit the GUFC
entry for the TCP identity of that socket any longer.

Just something to think about, when considering how to translate these
ideas into hardware.
