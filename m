From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Tue, 26 Aug 2014 09:43:48 -0700
Message-ID: <53FCB944.9060904@intel.com>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>	<20140826082815.18034199@redhat.com>	<20140826121347.0ec7f2ac@redhat.com> <20140826145225.6673ab3f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:29365 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751482AbaHZQs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 12:48:27 -0400
In-Reply-To: <20140826145225.6673ab3f@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2014 05:52 AM, Jesper Dangaard Brouer wrote:
> 
> On Tue, 26 Aug 2014 12:13:47 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
>> On Tue, 26 Aug 2014 08:28:15 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
>>> On Mon, 25 Aug 2014 16:34:58 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>>>
>>>> Given Jesper's performance numbers, it's not the way to go.
>>>>
>>>> Instead, go with a signalling scheme via new boolean skb->xmit_more.
>>>
>>> I'll do benchmarking based on this new API proposal today.
>>
>> While establish an accurate baseline for my measurements.  I'm
>> starting to see too much variation in my trafgen measurements.
>> Meaning that we unfortunately cannot use it to measure variations on
>> the nanosec scale.
> 
> Thus, we need to find a better more accurate measurement tool than
> trafgen/af_packet.
> 
> Changed my PPS monitor "ifpps-oneliner" to calculate the nanosec
> variation between the instant reading and the average.  For TX also
> record the "max" and "min" variation value seen.
> 
> This should give us a better (instant) picture of how accurate the
> measurement is.
> 
> ifpps -clod eth5 -t 1000 | \
>  awk 'BEGIN{txsum=0; rxsum=0; n=0; txvar=0; txvar_min=0; txvar_max=0; rxvar=0;} \
>  /[[:digit:]]/ {txsum+=$11;rxsum+=$3;n++; \
>    txvar=0; if (txsum/n>10 && $11>0) { \
>      txvar=((1/(txsum/n)*10^9)-(1/$11*10^9)); \
>      if (n>10 && txvar < txvar_min) {txvar_min=txvar}; \
>      if (n>10 && txvar > txvar_max) {txvar_max=txvar}; \
>    }; \
>    rxvar=0; if (rxsum/n>10 && $3>0 ) { rxvar=((1/(rxsum/n)*10^9)-(1/$3*10^9))}; \
>    printf "instant rx:%u tx:%u pps n:%u average: rx:%d tx:%d pps (instant variation TX %.3f ns (min:%.3f max:%.3f) RX %.3f ns)\n", $3, $11, n, rxsum/n, txsum/n, txvar, txvar_min, txvar_max, rxvar; \
>    if (txvar > 2) {printf "WARNING instant variation high\n" } }'
> 
> 
> Nanosec variation with trafgen:
> -------------------------------
> 
> As can be seen, the min and max nanosec variation with trafgen is
> higher than we would like:
> 
> Results: trafgen
>  (sudo ethtool -C eth5 rx-usecs 1)
>  instant rx:0 tx:1566064 pps n:152 average: rx:0 tx:1564534 pps
>  (instant variation TX 0.624 ns (min:-6.336 max:1.766) RX 0.000 ns)
> 
> Results: trafgen
>  (sudo ethtool -C eth5 rx-usecs 30)
>  instant rx:0 tx:1576452 pps n:121 average: rx:0 tx:1575652 pps
>  (instant variation TX 0.322 ns (min:-4.479 max:0.714) RX 0.000 ns)
> 
> 
> Switching to pktgen
> -------------------
> 
> I suspect a more accurate measurement tool will be "pktgen", because
> we can cut out most of the things that can cause these variations
> (like kmem_cache and cache-hot variations, and most sched variations).
> 
> The main problem with ixgbe is that, in this overload scenario, the
> performance is limited by the TX ring size and cleanup intervals, as
> described in:
>  http://netoptimizer.blogspot.dk/2014/06/pktgen-for-network-overload-testing.html
>  https://www.kernel.org/doc/Documentation/networking/pktgen.txt
> 
> Results below: Try to determine which ixgbe ethtool setting gives the
> most stable PPS readings.  Notice the TX "min" and "max" nanosec
> variations seen over the period.  Sampling over approx 120 sec.
> 
> The best setting seems to be:
>  sudo ethtool -C eth5 rx-usecs 30
>  sudo ethtool -G eth5 tx 512  #(default size)
> 
> Pktgen tests are single CPU performance numbers, script based on:
>  https://github.com/netoptimizer/network-testing/blob/master/pktgen/example01.sh
>  with CLONE_SKB="100000" (and single flow, const port number 9/discard)
> 
> Setting:
>  sudo ethtool -G eth5 tx 512 #(Default setting)
>  sudo ethtool -C eth5 rx-usecs 1 #(Default setting)
> Result pktgen:
>  * instant rx:1 tx:3933892 pps n:120 average: rx:1 tx:3934182 pps
>    (instant variation TX -0.019 ns (min:-0.047 max:0.016) RX 0.000 ns)
> 
> The variation very small, but the performance is limited by the TX
> ring buffer being full most of the time, TX cleanup being too slow.
> 
> Setting: (inc TX ring size)
>  sudo ethtool -G eth5 tx 1024
>  sudo ethtool -C eth5 rx-usecs 1 #(default setting)
> Result pktgen:
>  * instant rx:1 tx:5745632 pps n:118 average: rx:1 tx:5748818 pps
>    (instant variation TX -0.096 ns (min:-0.293 max:0.897) RX 0.000 ns)
> 
> Setting:
>  sudo ethtool -G eth5 tx 512
>  sudo ethtool -C eth5 rx-usecs 20
> Result pktgen:
>  * instant rx:1 tx:5765168 pps n:120 average: rx:0 tx:5782242 pps
>    (instant variation TX -0.512 ns (min:-1.008 max:1.599) RX 0.000 ns)
> 
> Setting:
>  sudo ethtool -G eth5 tx 512
>  sudo ethtool -C eth5 rx-usecs 30
> Result pktgen:
>  * instant rx:1 tx:5920856 pps n:114 average: rx:1 tx:5918350 pps
>    (instant variation TX 0.071 ns (min:-0.177 max:0.135) RX 0.000 ns)
> 
> Setting:
>  sudo ethtool -G eth5 tx 512
>  sudo ethtool -C eth5 rx-usecs 40
> Result pktgen:
>  * instant rx:1 tx:5958408 pps n:120 average: rx:0 tx:5947908 pps
>    (instant variation TX 0.296 ns (min:-1.410 max:0.595) RX 0.000 ns)
> 
> Setting:
>  sudo ethtool -G eth5 tx 512
>  sudo ethtool -C eth5 rx-usecs 50
> Result pktgen:
>  * instant rx:1 tx:5966964 pps n:120 average: rx:1 tx:5967306 pps
>    (instant variation TX -0.010 ns (min:-1.330 max:0.169) RX 0.000 ns)
> 
> Setting:
>  sudo ethtool -C eth5 rx-usecs 30
>  sudo ethtool -G eth5 tx 1024
> Result pktgen:
>  instant rx:0 tx:5846252 pps n:120 average: rx:1 tx:5852464 pps
>  (instant variation TX -0.182 ns (min:-0.467 max:2.249) RX 0.000 ns)
> 
> 

My advice would be to disable all C states and P states (including
turbo) if possible, and try using idle=poll.  Any processor frequency
and/or C state transitions will totally wreak havoc with trying to get
reliable results out of any performance test.

Thanks,

Alex
