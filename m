From: Andi Kleen <ak@suse.de>
Subject: Re: RDMA will be reverted
Date: Tue, 25 Jul 2006 01:10:25 +0200
Message-ID: <200607250110.25844.ak@suse.de>
References: <1151708503.11835.8.camel@trinity.ogc.int> <adasllh9kj0.fsf@cisco.com> <20060724.150613.54186472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, tom@opengridcomputing.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34459 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932315AbWGXXLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 19:11:09 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060724.150613.54186472.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> For example, my idea to allow ESTABLISHED TCP socket demux to be done
> before netfilter is flawed.  Connection tracking and NAT can change
> the packet ID and loop it back to us to hit exactly an ESTABLISHED TCP
> socket, therefore we must always hit netfilter first.

Hmm, how does this happen?

I guess either when a connection is masqueraded and an application did a bind()
on a local port that is used by the masquerading engine.  That could be handled
by just disallowing it.

Or when you have a transparent proxy setup with the proxy on the local host.
Perhaps in that case netfilter could be taught to reinject packets
in a way that they hit another ESTABLISHED lookup.

Did I miss a case?

> All the original costs of route, netfilter, TCP socket lookup all
> reappear as we make VJ netchannels fit all the rules of real practical
> systems, eliminating their gains entirely.

At least most of the optimizations from the early demux scheme could
be probably gotten simpler by adding a fast path to iptables/conntrack/etc. 
that checks if all rules only check SYN etc. packets and doesn't walk the
full rules then (or more generalized a fast TCP flag mask check similar 
to what TCP does). With that ESTABLISHED would hit TCP only with relatively
small overhead.

> I will also note in 
> passing that papers on related ideas, such as the Exokernel stuff, are
> very careful to not address the issue of how practical 1) their demux
> engine is and 2) the negative side effects of userspace TCP
> implementations.  For an example of the latter, if you have some 1GB
> JAVA process you do not want to wake that monster up just to do some
> ACK processing or TCP window updates, yet if you don't you violate
> TCP's rules and risk spurious unnecessary retransmits.

I don't quite get why the size of the process matters here - if only
some user space TCP library is called directly then it shouldn't
really matter how big or small the rest of the process is.

Or did you mean migration costs as described below?

But on the other hand full user space TCP seems to me of little gain
compared to a process context implementation.

I somehow like it better to hide these implementation details in 
the kernel.
 
> Furthermore, the VJ netchannel gains can be partially obtained from
> generic stateless facilities that we are going to get anyways.
> Networking chips supporting multiple MSI-X vectors, choosen by hashing
> the flow ID, can move TCP processing to "end nodes" which are cpu
> threads in this case, by having each such MSI-X vector target a
> different cpu thread.

The problem with the scheme is that to do process context processing
effectively you would need to teach the scheduler to aggressively
migrate on wake up (so that the process ends up on the CPU that 
was selected by the hash function in the NIC).

But what do you do when you have lots of different connections
with different target CPU hash values or when this would require
you to move multiple compute intensive processes or a single core?

Without user context TCP, but using softirqs instead, it looks a bit better 
because you can at least use different CPUs to do the ACK processing etc.
and the hash function spreading out connections over your CPUs doesn't harm.

But you still have relatively high cache line transfer costs in handing
over these packet from the softirq CPUs to the final process consumer. I liked
VJ's idea of using arrays-of-something instead of lists for that to avoid
some cache line transfers.  Ok at least it sounds nice in theory - haven't seen any 
hard numbers on this scheme compared to a traditional double linked list.

-Andi
