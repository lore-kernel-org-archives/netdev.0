From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [RFC net-next 0/4] gianfar: Use separate NAPI for Tx
 confirmation processing
Date: Thu, 16 Aug 2012 11:36:39 -0400
Message-ID: <20120816153638.GA24993@windriver.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com>
 <20120808162423.GC11043@windriver.com>
 <1344444267.28967.225.camel@edumazet-glaptop>
 <CAOy7UX2AW2w8TE0=7HGqRDJnX3Te5XZmW8UfC8F6HZg1RdWCYw@mail.gmail.com>
 <5023D21E.1000008@freescale.com>
 <502929ED.2050703@freescale.com>
 <20120814011526.GB29337@windriver.com>
 <502A77EE.8040300@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tomas Hruby <thruby@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53796 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932820Ab2HPPgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 11:36:48 -0400
Content-Disposition: inline
In-Reply-To: <502A77EE.8040300@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [RFC net-next 0/4] gianfar: Use separate NAPI for Tx confirmation processing] On 14/08/2012 (Tue 19:08) Claudiu Manoil wrote:

> On 08/14/2012 04:15 AM, Paul Gortmaker wrote:
> >This is a lot lower variation than what you reported earlier (20
> >versus 200, I think). It was the variation that raised a red flag
> >for me...
> Hi Paul,
> The earlier variation, which is much bigger (indeed ~200), was
> observed on a p1020 (slow, 2 cores, MQ_MG_MODE).
> I did not collect however as detailed measurement results for that
> board, as I did for p1010 (previous email).
> The most important performance improvement I've noticed however was
> on the p1020 platform.
> 
> >>By changing the coalescing settings from default* (rx coalescing off,
> >>tx-usecs: 10, tx-frames: 16) to:
> >>"ethtool -C eth1 rx-frames 22 tx-frames 22 rx-usecs 32 tx-usecs 32"
> >>we get a throughput of ~710 Mbps.
> >>
> >>For *Image 2)*, using the default tcp_limit_output_bytes value
> >>(131072) - I've noticed
> >>that "tweaking" tcp_limit_output_bytes does not improve the
> >>throughput -, we get the
> >>following performance numbers:
> >>* default coalescing settings: ~650 Mbps
> >>* rx-frames tx-frames 22 rx-usecs 32 tx-usecs 32: ~860-880 Mbps
> >>
> >>For *Image 3)*, by disabling BQL (CONFIG_BQL = n), there's *no*
> >>relevant performance
> >>improvement compared to Image 1).
> >>(note:
> >>For all the measurements, rx and tx BD ring sizes have been set to
> >>64, for best performance.)
> >>
> >>So, I really tend to believe that the performance degradation comes
> >>primarily from the driver,
> >>and the napi poll processing turns out to be an important source for
> >>that. The proposed patches
> >This would make sense, if the CPU was slammed at 100% load in dealing
> >with the tx processing, and the change made the driver considerably more
> >efficient.  But is that really the case?  Is the p1010 really going flat
> >out just to handle the Tx processing?  Have you done any sort of
> >profiling to confirm/deny where the CPU is spending its time?
> The current gfar_poll implementation processes first the tx
> confirmation path exhaustively, without a budget/ work limit,
> and only then proceeds with the rx processing within the allotted
> budget. An this happens for both Rx and Tx confirmation
> interrupts. I find this unfair and out of balance. Maybe by letting
> rx processing to be triggered by rx interrupts only, and
> the tx conf path processing to be triggered by tx confirmation
> interrupts only, and, on top of that, by imposing a work limit
> on the tx confirmation path too, we get a more responsive driver
> that performs better. Indeed some profiling data to
> confirm this would be great, but I don't have it.
> 
> There's another issues that seems to be solved by this patchset, and
> I've noticed it only on p1020rdb (this time).
> And that is excessive Rx busy interrupts occurrence. Solving this
> issue may be another factor for the performance
> improvement on p1020. But maybe this is another discussion.
> 
> >
> >>show substantial improvement, especially for SMP systems where Tx
> >>and Rx processing may be
> >>done in parallel.
> >>What do you think?
> >>Is it ok to proceed by re-spinning the patches? Do you recommend
> >>additional measurements?
> >Unfortunately Eric is out this week, so we will be without his input for
> >a while.  However, we are only at 3.6-rc1 -- meaning net-next will be
> >open for quite some time, hence no need to rush to try and jam stuff in.
> >
> >Also, I have two targets I'm interested in testing your patches on.  The
> >1st is a 500MHz mpc8349 board -- which should replicate what you see on
> >your p1010 (slow, single core).  The other is an 8641D, which is
> >interesting since it will give us the SMP tx/rx as separate threads, but
> >without the MQ_MG_MODE support (is that a correct assumption?)
> >
> >I don't have any fundamental problem with your patches (although 4/4
> >might be better as two patches) -- the above targets/tests are only
> >of interest, since I'm not convinced we yet understand _why_ your
> >changes give a performance boost, and there might be something
> >interesting hiding in there.
> >
> >So, while Eric is out, let me see if I can collect some more data on
> >those two targets sometime this week.
>
> Great, I don't mean to rush.  The more data we get on this the better.
> It would be great if you could do some measurements on your platforms too.
> 8641D is indeed a dual core with etsec 1.x (so without the MQ_MG_MODE),
> but I did run some tests on a p2020, which has the same features. However
> I'm eager to see your results.

So, I've collected data on 8349 (520MHz single core) and 8641D (1GHz
dual core) and the results are kind of surprising (to me).  The SMP
target, which in theory should have benefited from the change, actually
saw about an 8% reduction in throughput.  And the slower single core saw
about a 5% increase.

I also retested the 8641D with just your 1st 3 patches (i.e. drop the
"Use separate NAPIs for Tx and Rx processing" patch) and it recovered
about 1/2 the lost throughput, but not all.

I've used your patches exactly as posted, and the same netperf cmdline.
I briefly experimented with disabling BQL on the 8349 but didn't see any
impact from doing that (consistent with what you'd reported).  I didn't
see any real large variations either (target and server on same switch),
but I'm thinking the scatter could be reduced further if I isolated
the switch entirely to just the target and server.  I'll do that if I
end up doing any more testing on this, since the averages seem to be
reproduceable to about +/- 2% at the moment...

Paul.

 --------------
Command: netperf -l 20 -cC -H 192.168.146.65 -t TCP_STREAM -- -m 1500
next-next baseline: commit 1f07b62f3205f6ed41759df2892eaf433bc051a1
fsl RFC:  http://patchwork.ozlabs.org/patch/175919/ applied to above.
Default queue sizes (256), BQL defaults.

8349 (528 MHz, single core):
   net-next 10 runs
   avg=123
   max=124
   min=121
   send utilization > 99%
   
   fsl RFC 13 runs:
   avg=129 (+ ~5%)
   max=131
   min=127
   send utilization > 99%
   
8641D: (1GHz, dual core) 
   net-next 10 runs
   avg=826
   max=839
   min=807
   send utilization ~ 70%

   fsl RFC 12 runs
   avg=762 (- ~8%)
   max=783
   min=698
   send utilization ~ 70%

   fsl RFC, _only_ 1st 3 of 4 patches, 13 runs
   avg=794 (- ~4%)
   max=816
   min=758
   send utilization ~ 70%
 --------------

> Thanks for helping.
> 
> Regards,
> Claudiu
> 
> 
