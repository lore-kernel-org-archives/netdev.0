From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Tue, 01 Aug 2006 16:36:24 +1000
Message-ID: <1154414184.31152.99.camel@localhost.localdomain>
References: <1153979173.6904.100.camel@localhost.localdomain>
	 <20060726.230028.00077989.davem@davemloft.net>
	 <1154066044.5159.130.camel@localhost.localdomain>
	 <20060731.214729.35358981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.tip.net.au ([203.10.76.45]:49626 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1160994AbWHAGg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 02:36:29 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060731.214729.35358981.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-31 at 21:47 -0700, David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Fri, 28 Jul 2006 15:54:04 +1000
> 
> > (1) I am imagining some Grand Unified Flow Cache (Olsson trie?) that
> > holds (some subset of?) flows.  A successful lookup immediately after
> > packet comes off NIC gives destiny for packet: what route, (optionally)
> > what socket, what filtering, what connection tracking (& what NAT), etc?
> > I don't know if this should be a general array of fn & data ptrs, or
> > specialized fields for each one, or a mix.  Maybe there's a "too hard,
> > do slow path" bit, or maybe hard cases just never get put in the cache.
> > Perhaps we need a separate one for locally-generated packets, a-la
> > ip_route_output().  Anyway, we trade slightly more expensive flow setup
> > for faster packet processing within flows.
> 
> So, specifically, one of the methods you are thinking about might
> be implemented by adding:
> 
> 	void (*input)(struct sk_buff *, void *);
> 	void *input_data;
> 
> to "struct flow_cache_entry" or whatever replaces it?

Probably needs a return value to indicate stop packet processing, and to
be completely general I think we'd want more than one, eg:

	#define MAX_GUFC_INPUTS 5
	unsigned int num_inputs;
	int (*input[MAX_GUFC_INPUTS])(struct sk_buff *, void *);
	void *input_data[MAX_GUFC_INPUTS];

> This way we don't need some kind of "type" information in
> the flow cache entry, since the input handler knows the type.

Some things may want to jam more than a pointer into the cache entry, so
we might do something clever later, but as a first cut this would seem
to work.

> > One way to do this is to add a "have_interest" callback into the
> > hook_ops, which takes each about-to-be-inserted GUFC entry and adds any
> > destinies this hook cares about.  In the case of packet filtering this
> > would do a traversal and append a fn/data ptr to the entry for each rule
> > which could effect it.  
> 
> Can you give a concrete example of how the GUFC might make use
> of this?  Just some small abstract code snippets will do.

OK, I take it back.  I was thinking that on a miss, the GUFC called into
each subsystem to populate the new GUFC entry.  That would be a radical
departure from the current code, so forget it.

So, on a GUFC miss, we could create a new GUFC entry (on stack?), hang
it off the skb, then as each subsystem adds to it as we go through.  At
some point (handwave?) we collect the skb->gufc and insert it into the
trie.

For iptables, as a first step we'd simply do (open-coded for now):

	/* FIXME: Do acceleration properly */
	struct gufc *gufc = skb->gufc;
	if (!gufc || gufc->num_inputs == MAX_INPUTS) {
		skb->gufc = NULL;
	} else {
		gufc->input[gufc->num_inputs] = traverse_entire_table;
		gufc->input_data[gufc->num_inputs++] = this_table;
	}

Later we'd get funky:

	/* Filtering code here */
	...

	if (num_rules_applied > 1 || !only_needed_flow_info) {
		gufc->input[gufc->num_inputs] = traverse_entire_table;
		gufc->input_data[gufc->num_inputs++] = this_table;
	} else if (num_rules_applied == 1) {
		gufc->input[gufc->num_inputs] = traverse_one_rule;
		gufc->input_data[gufc->num_inputs++] = last_rule;
	}

Note that this could be cleverer, too:

	if (result == NF_DROP && only_needed_flow_info) {
		// Who cares about other inputs, we're going to drop
		gufc->input[0] = drop_skb;
		gufc->num_inputs = 1;
	}

Two potential performance issues: 

1) When we change rules, iptables replaces entire table from userspace.
We need pkttables (which uses incremental rule updates) to flush
intelligently.

2) Every iptables rule currently keeps pkt/byte counters, meaning we
can't bypass rules even though they might have no effect on the packet
(eg. iptables -A INPUT -i eth0 -j ETH0_RULES).  We can address this by
having pkt/byte counters in the gufc entry and a method of pushing them
back to iptables when the gufc entry is pruned, and manually traversing
the trie to flush them when the user asks for counters.

> I had the idea of a lazy scheme.  When we create a GUFC entry, we
> tack it onto a DMA'able linked list the card uses.  We do not
> notify the card, we just entail the update onto the list.
> 
> Then, if the card misses it's on-chip GUFC table on an incoming
> packet, it checks the DMA update list by reading it in from memory.
> It updates it's GUFC table with whatever entries are found on this
> list, then it retries to classify the packet.

I had assumed we would simply do full lookup on non-hw-classified
packets, so async insertion is a non-issue.  Can we assume hardware will
cover entire GUFC trie?

> This seems like a possible good solution until we try to address GUFC
> entry deletion, which unfortunately cannot be evaluated in a lazy
> fashion.  It must be synchronous.  This is because if, for example, we
> just killed off a TCP socket we must make sure we don't hit the GUFC
> entry for the TCP identity of that socket any longer.

With RCU, we'll probably be marking the GUFC entry deleted and freeing
it in a callback sometime later.  This gives us a window in which we can
delete it from the card's cache.  If we hit the callback and the card
still hasn't been updated, we need to go synchronous, but maybe that
will be rare?

> Just something to think about, when considering how to translate these
> ideas into hardware.

Yes, it's easy to imagine a DoS pattern where we spend all our cycles
updating trie and hw table, and even less time processing packets.

Cheers,
Rusty.
-- 
Help! Save Australia from the worst of the DMCA: http://linux.org.au/law

