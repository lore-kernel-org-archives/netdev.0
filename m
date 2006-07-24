From: David Miller <davem@davemloft.net>
Subject: Re: RDMA will be reverted
Date: Mon, 24 Jul 2006 16:22:50 -0700 (PDT)
Message-ID: <20060724.162250.55836503.davem@davemloft.net>
References: <adasllh9kj0.fsf@cisco.com>
	<20060724.150613.54186472.davem@davemloft.net>
	<200607250110.25844.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, tom@opengridcomputing.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58010
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932322AbWGXXWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 19:22:43 -0400
To: ak@suse.de
In-Reply-To: <200607250110.25844.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Tue, 25 Jul 2006 01:10:25 +0200

> > All the original costs of route, netfilter, TCP socket lookup all
> > reappear as we make VJ netchannels fit all the rules of real practical
> > systems, eliminating their gains entirely.
> 
> At least most of the optimizations from the early demux scheme could
> be probably gotten simpler by adding a fast path to iptables/conntrack/etc. 
> that checks if all rules only check SYN etc. packets and doesn't walk the
> full rules then (or more generalized a fast TCP flag mask check similar 
> to what TCP does). With that ESTABLISHED would hit TCP only with relatively
> small overhead.

Actually, all is not lost.  Alexey has a more clever idea which
is basically to run the netfilter hooks in the socket receive
path.

So we'd do the socket demux, wake net channel task on remote cpu,
and that thread of control would run the netfilter hooks.

> > I will also note in 
> > passing that papers on related ideas, such as the Exokernel stuff, are
> > very careful to not address the issue of how practical 1) their demux
> > engine is and 2) the negative side effects of userspace TCP
> > implementations.  For an example of the latter, if you have some 1GB
> > JAVA process you do not want to wake that monster up just to do some
> > ACK processing or TCP window updates, yet if you don't you violate
> > TCP's rules and risk spurious unnecessary retransmits.
> 
> I don't quite get why the size of the process matters here - if only
> some user space TCP library is called directly then it shouldn't
> really matter how big or small the rest of the process is.

Where does state live in such a huge process?  Usually, it is
scattered all over it's address space.  Let us say that java
application just did a lot of churning on it's own data
structure, swapping out TCP library state objects, we will
prematurely swap that stuff back in just to spit out an ACK
or similar.

> But on the other hand full user space TCP seems to me of little gain
> compared to a process context implementation.

I totally agree.

> > Furthermore, the VJ netchannel gains can be partially obtained from
> > generic stateless facilities that we are going to get anyways.
> > Networking chips supporting multiple MSI-X vectors, choosen by hashing
> > the flow ID, can move TCP processing to "end nodes" which are cpu
> > threads in this case, by having each such MSI-X vector target a
> > different cpu thread.
> 
> The problem with the scheme is that to do process context processing
> effectively you would need to teach the scheduler to aggressively
> migrate on wake up (so that the process ends up on the CPU that 
> was selected by the hash function in the NIC).

I don't see this as a big problem.  It's all in software, we can
control the behavior.

> But what do you do when you have lots of different connections
> with different target CPU hash values or when this would require
> you to move multiple compute intensive processes or a single core?

That is why we have scheduler :)  Even in a best effort scenerio, things
will be generally better than they are currently, plus there is nothing
precluding the flow demux MSI-X selection from getting more intelligent.

For example, the demuxer could "notice" that TCPdata transmits for
flow X tend to happen on cpu X, and update a flow table to record that
fact.  It could use the same flow table as the one used for LRO.

> But you still have relatively high cache line transfer costs in
> handing over these packet from the softirq CPUs to the final process
> consumer.

It is true, in order to get the full benefit we have to target
the MSI-X vectors intelligently.

For stateless things like routing and IPSEC gateways and firewalls,
none of this really matters.  But for local transports, it matters
a lot.
