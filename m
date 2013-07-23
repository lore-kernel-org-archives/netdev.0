From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v3 net-next 2/2] tcp: TCP_NOTSENT_LOWAT socket option
Date: Tue, 23 Jul 2013 08:26:01 -0700
Message-ID: <51EEA089.3040904@hp.com>
References: <1374550027.4990.141.camel@edumazet-glaptop>
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
Received: from g1t0027.austin.hp.com ([15.216.28.34]:48009 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757580Ab3GWP0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 11:26:04 -0400
In-Reply-To: <1374550027.4990.141.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2013 08:27 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Idea of this patch is to add optional limitation of number of
> unsent bytes in TCP sockets, to reduce usage of kernel memory.
>
> TCP receiver might announce a big window, and TCP sender autotuning
> might allow a large amount of bytes in write queue, but this has little
> performance impact if a large part of this buffering is wasted :
>
> Write queue needs to be large only to deal with large BDP, not
> necessarily to cope with scheduling delays (incoming ACKS make room
> for the application to queue more bytes)
>
> For most workloads, using a value of 128 KB or less is OK to give
> applications enough time to react to POLLOUT events in time
> (or being awaken in a blocking sendmsg())
>
> This patch adds two ways to set the limit :
>
> 1) Per socket option TCP_NOTSENT_LOWAT
>
> 2) A sysctl (/proc/sys/net/ipv4/tcp_notsent_lowat) for sockets
> not using TCP_NOTSENT_LOWAT socket option (or setting a zero value)
> Default value being UINT_MAX (0xFFFFFFFF), meaning this has no effect.
>
>
> This changes poll()/select()/epoll() to report POLLOUT
> only if number of unsent bytes is below tp->nosent_lowat
>
> Note this might increase number of sendmsg()/sendfile() calls
> when using non blocking sockets,
> and increase number of context switches for blocking sockets.
>
> Note this is not related to SO_SNDLOWAT (as SO_SNDLOWAT is
> defined as :
>   Specify the minimum number of bytes in the buffer until
>   the socket layer will pass the data to the protocol)
>
> Tested:
>
> netperf sessions, and watching /proc/net/protocols "memory" column for TCP
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
> Using 128KB has no bad effect on the throughput or cpu usage
> of a single flow, although there is an increase of context switches.
>
> A bonus is that we hold socket lock for a shorter amount
> of time and should improve latencies of ACK processing.
>
> lpq83:~# echo -1 >/proc/sys/net/ipv4/tcp_notsent_lowat
> lpq83:~# perf stat -e context-switches ./netperf -H 7.7.7.84 -t omni -l 20 -c -i10,3
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.7.84 () port 0 AF_INET : +/-2.500% @ 99% conf.
> Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service
> Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units
> Final       Final                                             %     Method %      Method
> 1651584     6291456     16384  20.00   17447.90   10^6bits/s  3.13  S      -1.00  U      0.353   -1.000  usec/KB
>
>   Performance counter stats for './netperf -H 7.7.7.84 -t omni -l 20 -c -i10,3':
>
>             412,514 context-switches
>
>       200.034645535 seconds time elapsed
>
> lpq83:~# echo 131072 >/proc/sys/net/ipv4/tcp_notsent_lowat
> lpq83:~# perf stat -e context-switches ./netperf -H 7.7.7.84 -t omni -l 20 -c -i10,3
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.7.84 () port 0 AF_INET : +/-2.500% @ 99% conf.
> Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service
> Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units
> Final       Final                                             %     Method %      Method
> 1593240     6291456     16384  20.00   17321.16   10^6bits/s  3.35  S      -1.00  U      0.381   -1.000  usec/KB
>
>   Performance counter stats for './netperf -H 7.7.7.84 -t omni -l 20 -c -i10,3':
>
>           2,675,818 context-switches
>
>       200.029651391 seconds time elapsed


I see that now the service demand increase is more like 8%, though there 
is no longer a throughput increase.  Whether an 8% increase is not a bad 
effect on the CPU usage of a single flow is probably in the eye of the 
beholder.

Anyway, on a more "how to use netperf" theme, while the final confidence 
interval width wasn't reported, given the combination of -l 20, -i 10,3 
and perf stat reporting an elapsed time of 200 seconds, we can conclude 
that the test went the full 10 iterations and so probably didn't 
actually hit the desired confidence interval of 5% wide at 99% probability.

17321.16 Mbit/s is ~132150 16 KB sends per second.  There were roughly 
13,379 context switches per second, so not quite 10 sends per context 
switch (~161831 bytes , that then is something like 161831 KB per 
context switch.  Does that then imply you could have achieved nearly the 
same performance with test-specific -s 160K -S 160K -m 16K ? (perhaps a 
bit more than that socket buffer size for contingencies and or what was 
"stored"/sent in the pipe?)  Or, given that the SO_SNDBUF grew to 
1593240 bytes, was there really a need for  ~ 1593240 - 131072 or 
~1462168 sent bytes in flight most of the time?

happy benchmarking,

rick jones
