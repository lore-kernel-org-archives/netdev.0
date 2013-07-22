From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: TCP_NOSENT_LOWAT socket option
Date: Mon, 22 Jul 2013 13:43:03 -0700
Message-ID: <51ED9957.9070107@hp.com>
References: <1374520422.4990.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:32203 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756014Ab3GVUnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 16:43:05 -0400
In-Reply-To: <1374520422.4990.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2013 12:13 PM, Eric Dumazet wrote:

>
> Tested:
>
> netperf sessions, and watching /proc/net/protocols "memory" column for TCP
>
> Even in the absence of shallow queues, we get a benefit.
>
> With 200 concurrent netperf -t TCP_STREAM sessions, amount of kernel memory
> used by TCP buffers shrinks by ~55 % (20567 pages instead of 45458)
>
> lpq83:~# echo -1 >/proc/sys/net/ipv4/tcp_notsent_lowat
> lpq83:~# (super_netperf 200 -t TCP_STREAM -H remote -l 90 &); sleep 60 ; grep TCP /proc/net/protocols
> TCPv6     1880      2   45458   no     208   yes  ipv6        y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
> TCP       1696    508   45458   no     208   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
>
> lpq83:~# echo 131072 >/proc/sys/net/ipv4/tcp_notsent_lowat
> lpq83:~# (super_netperf 200 -t TCP_STREAM -H remote -l 90 &); sleep 60 ; grep TCP /proc/net/protocols
> TCPv6     1880      2   20567   no     208   yes  ipv6        y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
> TCP       1696    508   20567   no     208   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
>
> Using 128KB has no bad effect on the throughput of a single flow, although
> there is an increase of cpu time as sendmsg() calls trigger more
> context switches. A bonus is that we hold socket lock for a shorter amount
> of time and should improve latencies.
>
> lpq83:~# echo -1 >/proc/sys/net/ipv4/tcp_notsent_lowat
> lpq83:~# perf stat -e context-switches ./netperf -H lpq84 -t omni -l 20 -Cc
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpq84 () port 0 AF_INET
> Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service
> Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units
> Final       Final                                             %     Method %      Method
> 2097152     6000000     16384  20.00   16509.68   10^6bits/s  3.05  S      4.50   S      0.363   0.536   usec/KB
>
>   Performance counter stats for './netperf -H lpq84 -t omni -l 20 -Cc':
>
>              30,141 context-switches
>
>        20.006308407 seconds time elapsed
>
> lpq83:~# echo 131072 >/proc/sys/net/ipv4/tcp_notsent_lowat
> lpq83:~# perf stat -e context-switches ./netperf -H lpq84 -t omni -l 20 -Cc
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpq84 () port 0 AF_INET
> Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service
> Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units
> Final       Final                                             %     Method %      Method
> 1911888     6000000     16384  20.00   17412.51   10^6bits/s  3.94  S      4.39   S      0.444   0.496   usec/KB
>
>   Performance counter stats for './netperf -H lpq84 -t omni -l 20 -Cc':
>
>             284,669 context-switches
>
>        20.005294656 seconds time elapsed

Netperf is perhaps a "best case" for this as it has no think time and 
will not itself build-up a queue of data internally.

The 18% increase in service demand is troubling.

It would be good to hit that with the confidence intervals (eg -i 30,3 
and perhaps -i 99,<somthing other than the default of 5>) or do many 
separate runs to get an idea of the variation.  Presumably remote 
service demand is not of interest, so for the confidence intervals bit 
you might drop the -C and keep only the -c in which case, netperf will 
not be trying to hit the confidence interval remote CPU utilization 
along with local CPU and throughput

Why are there more context switches with the lowat set to 128KB?  Is the 
SO_SNDBUF growth in the first case the reason? Otherwise I would have 
thought that netperf would have been context switching back and forth at 
at "socket full" just as often as "at 128KB." You might then also 
compare before and after with a fixed socket buffer size

Anything interesting happen when the send size is larger than the lowat?

rick jones
