From: David Miller <davem@davemloft.net>
Subject: Re: RDMA will be reverted
Date: Mon, 24 Jul 2006 15:06:13 -0700 (PDT)
Message-ID: <20060724.150613.54186472.davem@davemloft.net>
References: <1151708503.11835.8.camel@trinity.ogc.int>
	<200607011626.04539.ak@suse.de>
	<adasllh9kj0.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, tom@opengridcomputing.com, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45273
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932273AbWGXWGF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 18:06:05 -0400
To: rdreier@cisco.com
In-Reply-To: <adasllh9kj0.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 04 Jul 2006 13:34:27 -0700

> Well, here's a quick overview, leaving out some of the details.  The
> difference between TOE and iWARP/RDMA is really the interface that
> they present.

Thanks for the description Roland.  It helps me understand the
situation better.

> The real issues for netdev are things like Steve Wise's patch to add
> route change notifiers, which could be used to tell RNICs when to
> update the next hop for a connection they're handling.

I'll probably put Steve's patches in soon.

> More generally, it would be interesting to see if it's possible to
> tie an RNIC into the kernel's packet filtering, so that disallowed
> connections don't get set up.  This seems very similar in spirit to
> the problems around packet filtering that were raised for VJ
> netchannels.

Don't get too excited about VJ netchannels, more and more roadblocks
to their practicality are being found every day.

For example, my idea to allow ESTABLISHED TCP socket demux to be done
before netfilter is flawed.  Connection tracking and NAT can change
the packet ID and loop it back to us to hit exactly an ESTABLISHED TCP
socket, therefore we must always hit netfilter first.

All the original costs of route, netfilter, TCP socket lookup all
reappear as we make VJ netchannels fit all the rules of real practical
systems, eliminating their gains entirely.  I will also note in
passing that papers on related ideas, such as the Exokernel stuff, are
very careful to not address the issue of how practical 1) their demux
engine is and 2) the negative side effects of userspace TCP
implementations.  For an example of the latter, if you have some 1GB
JAVA process you do not want to wake that monster up just to do some
ACK processing or TCP window updates, yet if you don't you violate
TCP's rules and risk spurious unnecessary retransmits.

Furthermore, the VJ netchannel gains can be partially obtained from
generic stateless facilities that we are going to get anyways.
Networking chips supporting multiple MSI-X vectors, choosen by hashing
the flow ID, can move TCP processing to "end nodes" which are cpu
threads in this case, by having each such MSI-X vector target a
different cpu thread.

The good news is that we've survived a long time without revolutions
like VJ net channels, and the existing TCP stack can be improved
dramatically and in ways that people will see benefits from in a
shorter amount of time.  For example, Alexey Kuznetsov and I have some
ideas on how to make the most expensive TCP function for a sender,
tcp_ack(), more efficient by using different data structures for the
retransmit queue and the loss/recovery packet SACK state.
