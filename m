From: Daniele Lacamera <root@danielinux.net>
Subject: Re: TCP Pacing
Date: Tue, 19 Sep 2006 13:31:37 +0200
Message-ID: <200609191331.38960.root@danielinux.net>
References: <200609121958.22820.root@danielinux.net> <200609131746.03679.root@danielinux.net> <7335583a0609151741g68a29d22j48fd9f48642d4b8a@mail.gmail.com>
Reply-To: root@danielinux.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "Ian McDonald" <ian.mcdonald@jandi.co.nz>, netdev@vger.kernel.org,
	"Carlo Caini" <ccaini@deis.unibo.it>,
	"Rosario Firrincieli" <rfirrincieli@arces.unibo.it>,
	"Giovanni Pau" <gpau@cs.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from danielinux.vm.bytemark.co.uk ([80.68.95.85]:11525 "EHLO
	danielinux.vm.bytemark.co.uk") by vger.kernel.org with ESMTP
	id S1751907AbWISLa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 07:30:58 -0400
To: "Xiaoliang (David) Wei" <davidwei79@gmail.com>
In-Reply-To: <7335583a0609151741g68a29d22j48fd9f48642d4b8a@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 16 September 2006 02:41, Xiaoliang (David) Wei wrote:
> Hi Daniel,
>      Thank you very much for the patch and the reference summary. For
> the implementation and performance of pacing, I just have a few
> suggestion/clarification/support data:
> 
> First, in the implementation in the patch, it seems to me that the
> paced gap is set to RTT/cwnd in CA_Open state. This might leads to
> slower growth of congestion window. See our simulation results at
> http://www.cs.caltech.edu/~weixl/technical/ns2pacing/index.html

Hi David.
Thank you for having pointed this out. It's very interesting.
Actually, we already knew about delta calculation based on expected 
congestion window. Carlo and Rosario had studied this matter in deep, 
considered different options (VTC04), and came to the conclusion that 
thought rtt/cwnd solution slows down cwnd growth, the difference is not 
very relevant, so we have preferred to implement the most conservative 
one, which is sligthly simpler and fits all the congestion control 
algorithms.
	
> If this pacing algorithm is used in a network with non-paced flows, it
> is very likely to lose its fair share of bandwidth. So, I'd suggest to
> use a pacing gap of RTT/max{cwnd+1, min{ssthresh, cwnd*2}} where
> max{cwnd+1, min{ssthresh, cwnd*2}} is the expected congestion window
> in *next RTT*. As shown in the our simulation results, this
> modification will eliminate the slower growth problem.

The expected window value depends on the congestion control algorithm, 
the formula you suggests fits newreno increments, while other congstion 
control options may have different cwnd_expected. 
I don't exclude we may have an additional 'plug' in each congestion 
control module for pacing delta calculation, if this makes sense.

> > * Main reference:
> > -----------------
> This main reference (Infocom2000) does not say pacing is always
> improving. In fact, it says pacing might have poorer performance, in
> term of average throughput, than non-paced flows in many cases.

I have proposed to use this as main reference because it gives a general 
description and it is one of the most cited about the argument.

> For TCP Hybla, we do have some simulation results to show that Hybla
> introduces huge loss in start-up phase, if pacing is not deployed.
> (Look for the figures of "hybla" at
> http://www.cs.caltech.edu/~weixl/technical/ns2linux/index.html)

The initial overshoot in Hybla is a known issue. Cwnd increments are 
calculated on RTT, so the longer the RTT, the bigger the initial 
burstiness. 
The way to counteract overshoot is to use both pacing and an initial 
slow-start threshold estimation, like that one suggested in [1]. 
This is what we have been using for all our tests, in simulation (ns-2),  
emulation (linux+nistnet), and satellites. (See [2] and [3]).
As for pacing, I'd like to have bandwidth estimation feature included in 
future versions of hybla module as soon as we can consider it "stable".

HAND.

-- 
Daniele
 
[1] J. Hoe, "Improving the Start-up Behavior of a Congestion Control 
Scheme for TCP", ACM Sigcomm, Aug. 1996.

[2] C. Caini, R. Firrincieli and D. Lacamera, "TCP Performance 
Evaluation: Methodologies and Applications", SPECTS 2005, Philadelphia, 
July 2005.

[3] C. Caini, R. Firrincieli and D. Lacamera, "A Linux Based Multi TCP 
Implementation for Experimental Evaluation of TCP Enhancements", SPECTS 
2005, Philadelphia, July 2005.
