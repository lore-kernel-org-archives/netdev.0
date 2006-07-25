From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: RDMA will be reverted
Date: Tue, 25 Jul 2006 14:59:30 -0500
Message-ID: <1153857570.19089.70.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, rdreier@cisco.com, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:3052 "EHLO
	dell3.ogc.int") by vger.kernel.org with ESMTP id S964831AbWGYT7I
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 15:59:08 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-24 at 15:23 -0700, David Miller wrote: 
> From: Tom Tucker <tom@opengridcomputing.com>
> Date: Wed, 05 Jul 2006 12:09:42 -0500
> 
> > "A TOE net stack is closed source firmware. Linux engineers have no way
> > to fix security issues that arise. As a result, only non-TOE users will
> > receive security updates, leaving random windows of vulnerability for
> > each TOE NIC's users."
> > 
> > - A Linux security update may or may not be relevant to a vendors
> > implementation. 
> > 
> > - If a vendor's implementation has a security issue then the customer
> > must rely on the vendor to fix it. This is no less true for iWARP than
> > for any adapter.
> 
> This isn't how things actually work.
> 
> Users have a computer, and they can rightly expect the community
> to help them solve problems that occur in the upstream kernel.
> 
> When a bug is found and the person is using NIC X, we don't
> necessarily forward the bug report to the vendor of NIC X.
> Instead we try to fix the bug.  Many chip drivers are maintained
> by people who do not work for the company that makes the chip,
> and this works just fine.
> 
> If only the chip vendor can fix a security problem, this makes Linux
> less agile to fix.  Even aspect of a problem on a Linux system that
> cannot be fixed entirely by the community is a net negative for Linux.
> 

All true. What I meant to say was that this is "no less true than for
any deep adapter". It is incontrovertible that a deep adapter is less
flexible, and more difficult to support than a shallow adapter.

> > - iWARP needs to do protocol processing in order to validate and
> > evaluate TCP payload in advance of direct data placement. This
> > requirement is independent of CPU speed. 
> 
> Yet, RDMA itself is just an optimization meant to deal with
> limitations of cpu and memory speed.  You can rephrase the
> situation in whatever way suits your argument, but it does not
> make the core issue go away :)

Yep.

> 
> > - I suspect that connection rates for RDMA adapters fall well-below the
> > rates attainable with a dumb device. That said, all of the RDMA
> > applications that I know of are not connection intensive. Even for TOE,
> > the later HTTP versions makes connection rates less of an issue.
> 
> This is a very naive evaluation of the situation.  Yes, newer
> versions of protocols such as HTTP make the per-client connection
> burdon lower, but the number of clients will increase in time to
> more than makeup for whatever gains are seen due to this.

Naive is being kind, my HTTP comment is irrelevant :).  

> And then you have protocols which by design are connection heavy,
> and rightly so, such as bittorrent.
> 
> Being able to handle enormous numbers of connections, with extreme
> scalability and low latency, is an absolute requirement of any modern
> day serious TCP stack.  And this requirement is not going away.
> Wishing this requirement away due to HTTP persistent connections is
> very unrealistic, at best.
> 
> > - This is the problem we're trying to solve...incrementally and
> > responsibly.
> 
> You can't.  See my email to Roland about why even VJ net channels
> are found to be impractical.  To support netfilter properly, you
> must traverse the whole netfilter stack, because NAT can rewrite
> packets, yet still make them destined for the local system, and
> thus they will have a different identity for connection demux
> by the time the TCP stack sees the packet.
> 

I'm not claiming that all the problems can be solved, I'm suggesting
that integration could be better and that partial integration is better
than none. 

> All of these tranformations occur between normal packet receive
> and the TCP stack.  You would therefore need to put your card
> between netfilter and TCP in the packet input path, and at that
> point why bother with the stateful card at all?
> 
> The fact is that stateless approaches will always be better than
> stateful things because you cannot replicate the functionality we
> have in the Linux stack without replicating 10 years of work into
> your chip's firmware.  At that point you should just run Linux
> on your NIC since that is what you are effectively doing :)
> 

I wish...I'd have a better stack. 

> In conversations such as these, it helps us a lot if you can be frank
> and honest about the true absolute limitations of your technology.  

I'm trying ... classifying these limitations as "core can't fix" and
"fixable with integration" is where we're getting crosswise. 

> I
> can see that your viewpoint is tainted when I hear things such as HTTP
> persistent connections being used as a reason why high TCP connection
> rates won't matter in the future.  Such assertions are understood to
> be patently false by anyone who understands TCP and how it is used in
> the real world.

Partial "Fixable with Integration" Summary

- ARP Resolution
- ICMP Redirect
- Path MTU Change
- Route Update
- Colliding TCP Port Spaces

Partial "Can't Fix" Issues Summary:

- Many devices cannot support more than tens of thousands of concurrent
connections (16-64k would be typical). The number of supported RDMA
connections does not scale with server resources. 

- Netfilter integration is busted. Some have suggested that devices that
do connection establishment in host software could honor netfilter rules
at startup. I'm concerned that this would be more confusing than
helpful (which rules work, which don't)

- NAT doesn't work when run on the same machine as the RDMA stack with
hardware assist. Post connection establishment adapter sees untranslated 
packet. 

- Connection rates will likely be lower for devices that do connection
establishment in the device vs. in the host.  

- The open source community cannot easily predict, diagnose or fix
problems in the hardware stack. It's a black box.

- Most hardware stacks lack the security features present in the native
stack and cannot be extended to handle new exploits.



