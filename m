From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Thu, 21 Nov 2013 14:00:01 -0800
Message-ID: <1385071201.10637.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131119174323.GH913@1wt.eu>
	 <1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org>
	 <20131120191145.GP8581@1wt.eu> <87txf692zx.fsf@natisbad.org>
	 <20131120215435.GT8581@1wt.eu> <20131121004430.GX8581@1wt.eu>
	 <871u298lv6.fsf@natisbad.org> <20131121215259.GE18513@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnaud Ebalard <arno@natisbad.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, netdev@vger.kernel.org,
	edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:58503 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753742Ab3KUWAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 17:00:06 -0500
Received: by mail-yh0-f44.google.com with SMTP id f64so192648yha.3
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 14:00:05 -0800 (PST)
In-Reply-To: <20131121215259.GE18513@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-21 at 22:52 +0100, Willy Tarreau wrote:
> On Thu, Nov 21, 2013 at 10:51:09PM +0100, Arnaud Ebalard wrote:
> > Hi,
> > 
> > Willy Tarreau <w@1wt.eu> writes:
> > 
> > > OK it paid off. And very well :-)
> > >
> > > I did it at once and it worked immediately. I generally don't like this
> > > because I always fear that some bug was left there hidden in the code. I have
> > > only tested it on the Mirabox, so I'll have to try on the OpenBlocks AX3-4 and
> > > on the XP-GP board for some SMP stress tests.
> > >
> > > I upgraded my Mirabox to latest Linus' git (commit 5527d151) and compared
> > > with and without the patch.
> > >
> > >   without :
> > >       - need at least 12 streams to reach gigabit.
> > >       - 60% of idle CPU remains at 1 Gbps
> > >       - HTTP connection rate on empty objects is 9950 connections/s
> > >       - cumulated outgoing traffic on two ports reaches 1.3 Gbps
> > >
> > >   with the patch :
> > >       - a single stream easily saturates the gigabit
> > >       - 87% of idle CPU at 1 Gbps (12 streams, 90% idle at 1 stream)
> > >       - HTTP connection rate on empty objects is 10250 connections/s
> > >       - I saturate the two gig ports at 99% CPU, so 2 Gbps sustained output.
> > >
> > > BTW I must say I was impressed to see that big an improvement in CPU
> > > usage between 3.10 and 3.13, I suspect some of the Tx queue improvements
> > > that Eric has done in between account for this.
> > >
> > > I cut the patch in 3 parts :
> > >    - one which reintroduces the hidden bits of the driver
> > >    - one which replaces the timer with the IRQ
> > >    - one which changes the default Tx coalesce from 16 to 4 packets
> > >      (larger was preferred with the timer, but less is better now).
> > >
> > > I'm attaching them, please test them on your device.
> > 
> > Well, on the RN102 (Armada 370), I get the same results as with your
> > previous patch, i.e. netperf and nginx saturate the link. Apache still
> > lagging behind though.
> > 
> > > Note that this is *not* for inclusion at the moment as it has not been
> > > tested on the SMP CPUs.
> > 
> > I tested it on my RN2120 (2-core armada XP): I got no problem and the
> > link saturated w/ apache, nginx and netperf. Good work!
> 
> Great, thanks for your tests Arnaud. I forgot to mention that all my
> tests this evening involved this patch as well.

Now you might try to set a lower value
for /proc/sys/net/ipv4/tcp_limit_output_bytes

Ideally, a value of 8192 (instead of 131072) allows
to queue less data per tcp flow, and react faster to losses,
as retransmits don't have to wait that previous packets in Qdisc left
the host.

131072 bytes for a 80 Mbit flow means more than 11 ms of queueing :(
