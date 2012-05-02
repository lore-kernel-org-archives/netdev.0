From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Wed, 02 May 2012 10:16:23 -0700
Message-ID: <4FA16BE7.7030407@hp.com>
References: <1335523026.2775.236.camel@edumazet-glaptop> <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com> <1335835677.11396.5.camel@edumazet-glaptop> <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com> <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com> <1335891892.22133.23.camel@edumazet-glaptop>  <4FA03D69.6060907@intel.com> <1335947084.22133.134.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	=?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:28877 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753905Ab2EBRQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 13:16:32 -0400
In-Reply-To: <1335947084.22133.134.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2012 01:24 AM, Eric Dumazet wrote:
> On Tue, 2012-05-01 at 12:45 -0700, Alexander Duyck wrote:
>
>> I have a hacked together ixgbe up and running now with the new build_skb
>> logic and RSC/LRO disabled.  It looks like it is giving me a 5%
>> performance boost for small packet routing, but I am using more CPU for
>> netperf TCP receive tests and I was wondering if you had seen anything
>> similar on the tg3 driver?
>
> Really hard to say, numbers are so small on Gb link :
>
> what do you use to make your numbers ?
>
> netperf -H 172.30.42.23 -t OMNI -C -c
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.30.42.23 (172.30.42.23) port 0 AF_INET
> Local       Local       Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service
> Send Socket Send Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units
> Final       Final                                             %     Method %      Method
> 1700840     1700840     16384  10.01   931.60     10^6bits/s  4.50  S      1.32   S      1.582   2.783   usec/KB

If there is so little CPU consumed, I'm a bit surprised the throughput 
wasn't 940 Gbit/s.

It might be a good idea to fix the local and remote socket buffer sizes 
for these sorts of A-B comparisons to take the variability of the 
autotuning out.

And then, to see if the small differences are "real" one can light-up 
the confidence intervals.  For example (using kernels unrelated to the 
patch discussion):

raj@tardy:~/netperf2_trunk/src$ ./netperf -H 192.168.1.3 -t omni -c -C 
-I 99,1 -i 30,3 -- -s 256K -S 256K -m 16K -O 
throughput,local_cpu_util,local_sd,remote_cpu_util,remote_sd,throughput_confid,local_cpu_confid,remote_cpu_confid,confidence_iteration
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.3 () 
port 0 AF_INET : +/-0.500% @ 99% conf.  : interval : demo
Throughput Local Local   Remote Remote  Throughput Local      Remote 
  Confidence
            CPU   Service CPU    Service Confidence CPU        CPU 
   Iterations
            Util  Demand  Util   Demand  Width (%)  Confidence 
Confidence Run
            %             %                         Width (%)  Width (%) 

941.36     8.70  3.030   45.36  7.895   0.006      18.836     0.209 
  30

In this instance, I asked to be 99% confident the throughput and CPU 
util were within +/- 0.5% of the "real" mean.  The confidence intervals 
were hit for throughput and remote CPU util, but not for local CPU util 
- netperf was running on my personal workstation, which also receives 
email etc.  Presumably a more isolated and idle system would have hit 
the confidence intervals.

Other sources of variation to consider eliminating when looking for 
small differences in CPU utilization might be the multiqueue support in 
the NIC.  I'll often just terminate irqbalance and set all the IRQs to a 
single CPU (when doing single stream tests).  Or, one can fully specify 
the four-tuple for the netperf data connection.

rick jones
of course there is also the whole question of the effect of HW threading 
on the meaningfulness of OS-determined utilization...
