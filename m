From: Mandeep Singh Baines <mandeep.baines@gmail.com>
Subject: Re: [PATCH] [sis900] convert to NAPI, WAS Re: pktgen terminating
	condition
Date: Wed, 5 Sep 2007 22:06:29 -0700
Message-ID: <20070906050629.GA4262@ludhiana>
References: <20070904032036.GA11153@ludhiana> <1188925008-ced672f60b90353067426d0b9f74506a@brownhat.org> <20070905074411.GA4815@ludhiana> <46DE9B09.7060603@katalix.com> <1188995619.4238.5.camel@localhost> <46DEB545.3030509@katalix.com> <1189002087.4228.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
	Mandeep Singh Baines <mandeep.baines@gmail.com>,
	Daniele Venzano <venza@brownhat.org>, davem@davemloft.net,
	rick.jones2@hp.com, msb@google.com, netdev@vger.kernel.org,
	grundler@google.com, robert.olsson@its.uu.se, jeff@garzik.org,
	nhorman@tuxdriver.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:21415 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757956AbXIFFkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 01:40:51 -0400
Received: by rv-out-0910.google.com with SMTP id k20so53375rvb
        for <netdev@vger.kernel.org>; Wed, 05 Sep 2007 22:40:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1189002087.4228.26.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal (hadi@cyberus.ca) wrote:
> On Wed, 2007-05-09 at 14:55 +0100, James Chapman wrote:
> 
> > Thanks Jamal. Yes, I'd already read your paper. I think my idea is 
> > different to the ideas described in your paper 
> 
> I am hoping you can pick from the lessons of what has been tried and
> failed and the justification for critiqueing something as "Failed". 
> If you have - i feel i accomplished something useful writting the paper.
> 
> > and I'm in the process of 
> > writing it up as an RFC to post to netdev. 
> 
> Please cc me if you want my feedback - I am backlogged by about 3000
> messages on netdev.
> 
> > Briefly though, the driver's 
> > ->poll() holds off doing netif_rx_complete() for 1-2 jiffies and keeps 
> > itself in poll_on mode for that time, consuming no quota. 
> > The net_rx 
> > softirq processing loop is modified to detect the case when the only 
> > devices in its poll list are doing no work (consuming no quota). The 
> > driver's ->poll() samples jiffies while it is considering when to do the 
> > netif_rx_complete() like your Parked state - no timers are used.
> 
> Ok, so the difference seems to be you actually poll instead for those
> jiffies instead starting a timer in the parked state - is that right?
> 
> > If I missed that this approach has already been tried before and 
> > rejected, please let me know. I see better throughput and latency in my 
> > packet forwarding and LAN setups using it.
> 
> If you read the paper: There are no issues with high throughput - NAPI
> kicks in.
> The challenge to be overcome is at low traffic, if you have a real fast
> processor your cpu-cycles-used/bits-processed ratio is high....

I'm not sure cpu-cycles-used/bits-processed is the correct metric to use.
An alternative would be to look at cpu-cycles-used/unit-time (i.e.
CPU utilization or load) for a given bit-rate or packet-rate. This would
make an interesting graph.

At low packet-rate, CPU utilization is low so doing extra work per packet
is probably OK. Utilizing 2% of CPU vesus 1% is negligible. But at higher
rate, when there is more CPU utilization, using 40% of CPU versus 60% is
significant. I think the absolute different in CPU utilization is more
important than the relative difference. iow, 2% versus 1%, even though 
a 2x difference in cpu-cycles/packet, is negligible compared to 40% 
versus 60%.

> If you are polling (softirqs have high prio and depending on the cpu,
> there could be a few gazillion within those 1-2 jiffies), then isnt the
> end result still a high cpu-cycles used?
> Thats what the timer tries to avoid (do nothing until some deffered
> point).

Using a timer might also behave better in a tick-less (CONFIG_NO_HZ) 
configuration.

> If you waste cpu cycles and poll, I can see that (to emphasize: For
> FastCPU-LowTraffic scenario), you will end up _not_ having latency
> issues i pointed out, but you surely have digressed from the original
> goal which is to address the cpu abuse at low traffic (because you abuse
> more cpu).
> 
> One thing that may be valuable is to show that the timers and polls are
> not much different in terms of cpu abuse (It's theoretically not true,
> but reality may not match).
> The other thing is now hrestimers are on, can you try using a piece of
> hardware that can get those kicked and see if you see any useful results
> on latency.
> 
> cheers,
> jamal
> 
