From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next 3/7] openvswitch: Enable memory mapped Netlink i/o
Date: Sat, 30 Nov 2013 14:04:20 +0000
Message-ID: <20131130140420.GF4100@casper.infradead.org>
References: <cover.1385813891.git.tgraf@suug.ch>
 <9f7f05a726935c434d43d92c2908a997c403725b.1385813891.git.tgraf@suug.ch>
 <20131130123549.GH2067@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse@nicira.com, davem@davemloft.net, dev@openvswitch.org,
	netdev@vger.kernel.org, dborkman@redhat.com, ffusco@redhat.com,
	fleitner@redhat.com, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51605 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219Ab3K3OEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 09:04:23 -0500
Content-Disposition: inline
In-Reply-To: <20131130123549.GH2067@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/13 at 01:35pm, Florian Westphal wrote:
> Thomas Graf <tgraf@suug.ch> wrote:
> > Benchmark
> >   * pktgen -> ovs internal port
> >   * 5M pkts, 5M flows
> >   * 4 threads, 8 cores
> > 
> > Before:
> > Result: OK: 67418743(c67108212+d310530) usec, 5000000 (9000byte,0frags)
> >   74163pps 5339Mb/sec (5339736000bps) errors: 0
> [..]
> > After:
> > Result: OK: 24229690(c24127165+d102524) usec, 5000000 (9000byte,0frags)
> >   206358pps 14857Mb/sec (14857776000bps) errors: 0
> 
> I'm curious.  Is the 'old' value with skb_zerocopy() or without?
> Does ovs-vswitchd 'read-access' the entire packet or just e.g. the
> header?
> 
> I ask because in netfilter nfqueue tests I could not see any difference
> between 'zerocopy' vs. mmap in the receive-path tests I made a while
> back.

The numbers quoted do not involve any zerocopy at all. It's a pure
original vs. mmap comparison. I expect the numbers to grow even more
once we get rid of the immediate ofpbuf copy in user space.

Zerocopy as implemened right now does not provide much gains on
top of mmap. We have no way yet to inject the skb frags into the
ring so we are forced to copy the data. The mapped skb is simply a
buffer with a tremendous tailroom to the zerocopy code.

Eventually we can find a way to make the skb frags shared and link
them to the ring buffer and avoid the copy. This would especially
make sense if we add GSO support to openvswitch user space as nfqueue
provides and avoid the segmentation before the upcall.
