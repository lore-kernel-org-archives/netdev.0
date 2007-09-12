From: Bill Fink <billfink@mindspring.com>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Wed, 12 Sep 2007 03:04:28 -0400
Message-ID: <20070912030428.16059af6.billfink@mindspring.com>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>
	<1189120020.4259.68.camel@localhost>
	<46E11A61.9030409@katalix.com>
	<1189171370.4234.38.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
	davem@davemloft.net, jeff@garzik.org, mandeep.baines@gmail.com,
	ossthema@de.ibm.com, Stephen Hemminger <shemminger@osdl.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:43893 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752085AbXILHFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 03:05:22 -0400
In-Reply-To: <1189171370.4234.38.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 07 Sep 2007, jamal wrote:

> On Fri, 2007-07-09 at 10:31 +0100, James Chapman wrote:
> > Not really. I used 3-year-old, single CPU x86 boxes with e100 
> > interfaces. 
> > The idle poll change keeps them in polled mode. Without idle 
> > poll, I get twice as many interrupts as packets, one for txdone and one 
> > for rx. NAPI is continuously scheduled in/out.
> 
> Certainly faster than the machine in the paper (which was about 2 years
> old in 2005).
> I could never get ping -f to do that for me - so things must be getting
> worse with newer machines then.
> 
> > No. Since I did a flood ping from the machine under test, the improved 
> > latency meant that the ping response was handled more quickly, causing 
> > the next packet to be sent sooner. So more packets were transmitted in 
> > the allotted time (10 seconds).
> 
> ok.
> 
> > With current NAPI:
> > rtt min/avg/max/mdev = 0.902/1.843/101.727/4.659 ms, pipe 9, ipg/ewma 
> > 1.611/1.421 ms
> > 
> > With idle poll changes:
> > rtt min/avg/max/mdev = 0.898/1.117/28.371/0.689 ms, pipe 3, ipg/ewma 
> > 1.175/1.236 ms
> 
> Not bad in terms of latency. The deviation certainly looks better.
> 
> > But the CPU has done more work. 
> 
> I am going to be the devil's advocate[1]:

So let me be the angel's advocate.  :-)

> If the problem i am trying to solve is "reduce cpu use at lower rate",
> then this is not the right answer because your cpu use has gone up.
> Your latency numbers have not improved that much (looking at the avg)
> and your throughput is not that much higher. Will i be willing to pay
> more cpu (of an already piggish cpu use by NAPI at that rate with 2
> interupts per packet)?

I view his results much more favorably.  With current NAPI, the average
RTT is 104% higher than the minimum, the deviation is 4.659 ms, and the
maximum RTT is 101.727 ms.  With his patch, the average RTT is only 24%
higher than the minimum, the deviation is only 0.689 ms, and the maximum
RTT is 28.371 ms.  The average RTT improved by 39%, the deviation was
6.8 times smaller, and the maximum RTT was 3.6 times smaller.  So in
every respect the latency was significantly better.

The throughput increased from 6200 packets to 8510 packets or an increase
of 37%.  The only negative is that the CPU utilization increased from
62% to 100% or an increase of 61%, so the CPU increase was greater than
the increase in the amount of work performed (17.6% greater than what
one would expect purely from the increased amount of work).

You can't always improve on all metrics of a workload.  Sometimes there
are tradeoffs to be made to be decided by the user based on what's most
important to that user and his specific workload.  And the suggested
ethtool option (defaulting to current behavior) would enable the user
to make that decision.

						-Bill

P.S.  I agree that some tests run in parallel with some CPU hogs also
      running might be beneficial and enlightening.
