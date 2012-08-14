From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [RFC net-next 0/4] gianfar: Use separate NAPI for Tx confirmation
 processing
Date: Tue, 14 Aug 2012 19:08:14 +0300
Message-ID: <502A77EE.8040300@freescale.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com> <20120808162423.GC11043@windriver.com> <1344444267.28967.225.camel@edumazet-glaptop> <CAOy7UX2AW2w8TE0=7HGqRDJnX3Te5XZmW8UfC8F6HZg1RdWCYw@mail.gmail.com> <5023D21E.1000008@freescale.com> <502929ED.2050703@freescale.com> <20120814011526.GB29337@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tomas Hruby <thruby@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.181.185] ([216.32.181.185]:30678 "EHLO
	ch1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751976Ab2HNQJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 12:09:31 -0400
In-Reply-To: <20120814011526.GB29337@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2012 04:15 AM, Paul Gortmaker wrote:
> This is a lot lower variation than what you reported earlier (20 
> versus 200, I think). It was the variation that raised a red flag for 
> me... 
Hi Paul,
The earlier variation, which is much bigger (indeed ~200), was observed 
on a p1020 (slow, 2 cores, MQ_MG_MODE).
I did not collect however as detailed measurement results for that 
board, as I did for p1010 (previous email).
The most important performance improvement I've noticed however was on 
the p1020 platform.

>> By changing the coalescing settings from default* (rx coalescing off,
>> tx-usecs: 10, tx-frames: 16) to:
>> "ethtool -C eth1 rx-frames 22 tx-frames 22 rx-usecs 32 tx-usecs 32"
>> we get a throughput of ~710 Mbps.
>>
>> For *Image 2)*, using the default tcp_limit_output_bytes value
>> (131072) - I've noticed
>> that "tweaking" tcp_limit_output_bytes does not improve the
>> throughput -, we get the
>> following performance numbers:
>> * default coalescing settings: ~650 Mbps
>> * rx-frames tx-frames 22 rx-usecs 32 tx-usecs 32: ~860-880 Mbps
>>
>> For *Image 3)*, by disabling BQL (CONFIG_BQL = n), there's *no*
>> relevant performance
>> improvement compared to Image 1).
>> (note:
>> For all the measurements, rx and tx BD ring sizes have been set to
>> 64, for best performance.)
>>
>> So, I really tend to believe that the performance degradation comes
>> primarily from the driver,
>> and the napi poll processing turns out to be an important source for
>> that. The proposed patches
> This would make sense, if the CPU was slammed at 100% load in dealing
> with the tx processing, and the change made the driver considerably more
> efficient.  But is that really the case?  Is the p1010 really going flat
> out just to handle the Tx processing?  Have you done any sort of
> profiling to confirm/deny where the CPU is spending its time?
The current gfar_poll implementation processes first the tx confirmation 
path exhaustively, without a budget/ work limit,
and only then proceeds with the rx processing within the allotted 
budget. An this happens for both Rx and Tx confirmation
interrupts. I find this unfair and out of balance. Maybe by letting rx 
processing to be triggered by rx interrupts only, and
the tx conf path processing to be triggered by tx confirmation 
interrupts only, and, on top of that, by imposing a work limit
on the tx confirmation path too, we get a more responsive driver that 
performs better. Indeed some profiling data to
confirm this would be great, but I don't have it.

There's another issues that seems to be solved by this patchset, and 
I've noticed it only on p1020rdb (this time).
And that is excessive Rx busy interrupts occurrence. Solving this issue 
may be another factor for the performance
improvement on p1020. But maybe this is another discussion.

>
>> show substantial improvement, especially for SMP systems where Tx
>> and Rx processing may be
>> done in parallel.
>> What do you think?
>> Is it ok to proceed by re-spinning the patches? Do you recommend
>> additional measurements?
> Unfortunately Eric is out this week, so we will be without his input for
> a while.  However, we are only at 3.6-rc1 -- meaning net-next will be
> open for quite some time, hence no need to rush to try and jam stuff in.
>
> Also, I have two targets I'm interested in testing your patches on.  The
> 1st is a 500MHz mpc8349 board -- which should replicate what you see on
> your p1010 (slow, single core).  The other is an 8641D, which is
> interesting since it will give us the SMP tx/rx as separate threads, but
> without the MQ_MG_MODE support (is that a correct assumption?)
>
> I don't have any fundamental problem with your patches (although 4/4
> might be better as two patches) -- the above targets/tests are only
> of interest, since I'm not convinced we yet understand _why_ your
> changes give a performance boost, and there might be something
> interesting hiding in there.
>
> So, while Eric is out, let me see if I can collect some more data on
> those two targets sometime this week.
Great, I don't mean to rush.  The more data we get on this the better.
It would be great if you could do some measurements on your platforms too.
8641D is indeed a dual core with etsec 1.x (so without the MQ_MG_MODE),
but I did run some tests on a p2020, which has the same features. However
I'm eager to see your results.
Thanks for helping.

Regards,
Claudiu
