From: Andi Kleen <ak@suse.de>
Subject: Re: RDMA will be reverted
Date: Tue, 25 Jul 2006 02:02:02 +0200
Message-ID: <200607250202.02913.ak@suse.de>
References: <adasllh9kj0.fsf@cisco.com> <200607250110.25844.ak@suse.de> <20060724.162250.55836503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, tom@opengridcomputing.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34208 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932333AbWGYAFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 20:05:09 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060724.162250.55836503.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 25 July 2006 01:22, David Miller wrote:
> From: Andi Kleen <ak@suse.de>
> Date: Tue, 25 Jul 2006 01:10:25 +0200
> 
> > > All the original costs of route, netfilter, TCP socket lookup all
> > > reappear as we make VJ netchannels fit all the rules of real practical
> > > systems, eliminating their gains entirely.
> > 
> > At least most of the optimizations from the early demux scheme could
> > be probably gotten simpler by adding a fast path to iptables/conntrack/etc. 
> > that checks if all rules only check SYN etc. packets and doesn't walk the
> > full rules then (or more generalized a fast TCP flag mask check similar 
> > to what TCP does). With that ESTABLISHED would hit TCP only with relatively
> > small overhead.
> 
> Actually, all is not lost.  Alexey has a more clever idea which
> is basically to run the netfilter hooks in the socket receive
> path.

The gain being that the target CPU does the work instead of 
the softirq one?

Some combined lookup and better handler of ESTABLISHED still
seems like a good idea.

One idea I had at some point was to separate conntrack for local
connection vs routed connections and attach the local conntrack
to the socket (and use its lookup tables). Then at least for
local connections conntrack should be nearly free.

It should also solve the issue we currently have that enabled 
conntrack makes local network performance significantly worse.

> Where does state live in such a huge process?  Usually, it is
> scattered all over it's address space.  Let us say that java
> application just did a lot of churning on it's own data
> structure, swapping out TCP library state objects, we will
> prematurely swap that stuff back in just to spit out an ACK
> or similar.

TCP state is usually multiple cache lines, so you would have
cache misses anyways. Do you worry about the TLBs? 

> > But what do you do when you have lots of different connections
> > with different target CPU hash values or when this would require
> > you to move multiple compute intensive processes or a single core?
> 
> That is why we have scheduler :)

It can't do well if it gets conflicting input.

> Even in a best effort scenerio, things 
> will be generally better than they are currently, plus there is nothing
> precluding the flow demux MSI-X selection from getting more intelligent.

Intelligent = statefull in this case.

AFAIK the only way to do it stateless is hashes and the output
of hashes tends to be unpredictible by definition.


> For example, the demuxer could "notice" that TCPdata transmits for
> flow X tend to happen on cpu X, and update a flow table to record that
> fact.  It could use the same flow table as the one used for LRO.

Hmm, i somewhat doubt that lower end NICs will ever have such flow tables.
Also the flow tables could always thrash (because the on NIC RAM is necessarily
limited) or they or require the NIC to look up state in memory which is 
probably not much faster than the CPUs doing it.

Using hash functions in the hardware to select the MSI-X seems 
more elegant, cheaper and much more scalable to me.

The drawback of hashes is that for processes with multiple
connections you have to move some work back into the softirqs
that run on the MSI-X target CPUs.

So basically doing process context TCP fully will require
much more complex and statefull hardware. 

Or you can keep it only as a fast path for specific situations
(single busy connection per thread) and stay with mostly-softirq
processing for the many connection cases.

-Andi
