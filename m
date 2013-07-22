From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: TCP_NOSENT_LOWAT socket option
Date: Mon, 22 Jul 2013 16:08:59 -0700
Message-ID: <51EDBB8B.2000805@hp.com>
References: <1374520422.4990.33.camel@edumazet-glaptop> <51ED9957.9070107@hp.com> <1374533052.4990.89.camel@edumazet-glaptop>
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
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:20354 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649Ab3GVXJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 19:09:01 -0400
In-Reply-To: <1374533052.4990.89.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2013 03:44 PM, Eric Dumazet wrote:
> Hi Rick
>
>> Netperf is perhaps a "best case" for this as it has no think time and
>> will not itself build-up a queue of data internally.
>>
>> The 18% increase in service demand is troubling.
>
> Its not troubling at such high speed. (Note also I had better throughput
> in my (single) test)

Yes, you did, but that was only 5.4%, and it may be in an area where 
there is non-trivial run to run variation.

I would think an increase in service demand is even more troubling at 
high speeds than low speeds.  Particularly when I'm still not at link-rate.

In theory anyway, the service demand is independent of the transfer 
rate.  Of course, practice dictates that different algorithms have 
different behaviours at different speeds, but in slightly sweeping 
handwaving, if the service demand went up 18% that cut your maximum 
aggregate throughput for the "infinitely fast link" or collection of 
finitely fast links in the system by 18%.

I suppose that brings up the question of what the aggregate throughput 
and CPU utilization was for your 200 concurrent netperf TCP_STREAM sessions.

> Process scheduler cost is abysmal (Or more exactly when cpu enters idle
> mode I presume).
>
> Adding a context switch for every TSO packet is obviously not something
> you want if you want to pump 20Gbps on a single tcp socket.

You wouldn't want it if you were pumping 20 Gbit/s down multiple TCP 
sockets either I'd think.

> I guess that real application would not use 16KB send()s either.

You can use a larger send in netperf - the 16 KB is only because that is 
the default initial SO_SNDBUF size under Linux :)

> I chose extreme parameters to show that the patch had acceptable impact.
> (128KB are only 2 TSO packets)
>
> The main targets of this patch are servers handling hundred to million
> of sockets, or any machine with RAM constraints. This would also permit
> better autotuning in the future. Our current 4MB limit is a bit small in
> some cases.
>
> Allowing the socket write queue to queue more bytes is better for
> throughput/cpu cycles, as long as you have enough RAM.

So, netperf doesn't queue internally - what happens when the application 
does queue internally?  Admittedly, it will be user-space memory (I 
assume) rather than kernel memory, which I suppose is better since it 
can be paged and whatnot.  But if we drop the qualifiers, it is still 
the same quantity of memory overall right?

By the way, does this affect sendfile() or splice()?

>> It would be good to hit that with the confidence intervals (eg -i 30,3
>> and perhaps -i 99,<somthing other than the default of 5>) or do many
>> separate runs to get an idea of the variation.  Presumably remote
>> service demand is not of interest, so for the confidence intervals bit
>> you might drop the -C and keep only the -c in which case, netperf will
>> not be trying to hit the confidence interval remote CPU utilization
>> along with local CPU and throughput
>>
>
> Well, I am sure a lot of netperf tests can be done, thanks for the
> input ! I am removing the -C ;)
>
> The -i30,3 runs are usually very very very slow :(

Well, systems aren't as consistent as they once were.

Some of the additional strategies I employ with varying degrees of 
success in getting a single stream -i 30,3 (DON"T use that with 
aggregates) to complete closer to the 3 than the 30:

*) Bind all the IRQs of the NIC to a single CPU, which then makes it 
possible to:

*) Bind netperf (and/or netserver) to that CPU with the -T option or 
taskset.  Or you may want to bind to a peer CPU associated with the same 
L3 data cache if you have a NIC that needs more than a single CPU's 
worth of "oomph" to get (near to) link rate.

*) There may also be some value in setting the system into a 
fixed-frequency mode.

>
>> Why are there more context switches with the lowat set to 128KB?  Is the
>> SO_SNDBUF growth in the first case the reason? Otherwise I would have
>> thought that netperf would have been context switching back and forth at
>> at "socket full" just as often as "at 128KB." You might then also
>> compare before and after with a fixed socket buffer size
>
> It seems to me normal to get one context switch per TSO packet, instead
> of _no_ context switches when the cpu is so busy it never has to put the
> netperf thread to sleep. softirq handling is removing packets from write
> queue at the same speed than application can add new ones ;)
>
>>
>> Anything interesting happen when the send size is larger than the lowat?
>
> Let's see ;)
>
> lpq83:~# echo -1 >/proc/sys/net/ipv4/tcp_notsent_lowat
> lpq83:~# perf stat ./netperf -t omni -l 20 -H 7.7.7.84 -c -i 10,3 -- -m 256K
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.7.84 () port 0 AF_INET : +/-2.500% @ 99% conf.
> Local       Remote      Local   Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service
> Send Socket Recv Socket Send    Time               Units       CPU   CPU    CPU    CPU    Service Service Demand
> Size        Size        Size    (sec)                          Util  Util   Util   Util   Demand  Demand  Units
> Final       Final                                              %     Method %      Method
> 3056328     6291456     262144  20.00   16311.69   10^6bits/s  2.97  S      -1.00  U      0.359   -1.000  usec/KB
>
>   Performance counter stats for './netperf -t omni -l 20 -H 7.7.7.84 -c -i 10,3 -- -m 256K':
>
>        89301.211847 task-clock                #    0.446 CPUs utilized
>             349,509 context-switches          #    0.004 M/sec
>                 179 CPU-migrations            #    0.002 K/sec
>                 453 page-faults               #    0.005 K/sec
>     242,819,453,514 cycles                    #    2.719 GHz                     [81.82%]
>     199,273,454,019 stalled-cycles-frontend   #   82.07% frontend cycles idle    [84.27%]
>      50,268,984,648 stalled-cycles-backend    #   20.70% backend  cycles idle    [67.76%]
>      53,781,450,212 instructions              #    0.22  insns per cycle
>                                               #    3.71  stalled cycles per insn [83.77%]
>       8,738,372,177 branches                  #   97.853 M/sec                   [82.99%]
>         119,158,960 branch-misses             #    1.36% of all branches         [83.17%]
>
>       200.032331409 seconds time elapsed
>
> lpq83:~# echo 131072 >/proc/sys/net/ipv4/tcp_notsent_lowat
> lpq83:~# perf stat ./netperf -t omni -l 20 -H 7.7.7.84 -c -i 10,3 -- -m 256K
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.7.84 () port 0 AF_INET : +/-2.500% @ 99% conf.
> Local       Remote      Local   Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service
> Send Socket Recv Socket Send    Time               Units       CPU   CPU    CPU    CPU    Service Service Demand
> Size        Size        Size    (sec)                          Util  Util   Util   Util   Demand  Demand  Units
> Final       Final                                              %     Method %      Method
> 1862520     6291456     262144  20.00   17464.08   10^6bits/s  3.98  S      -1.00  U      0.448   -1.000  usec/KB
>
>   Performance counter stats for './netperf -t omni -l 20 -H 7.7.7.84 -c -i 10,3 -- -m 256K':
>
>       111290.768845 task-clock                #    0.556 CPUs utilized
>           2,818,205 context-switches          #    0.025 M/sec
>                 201 CPU-migrations            #    0.002 K/sec
>                 453 page-faults               #    0.004 K/sec
>     297,763,550,604 cycles                    #    2.676 GHz                     [83.35%]
>     246,839,427,685 stalled-cycles-frontend   #   82.90% frontend cycles idle    [83.25%]
>      75,450,669,370 stalled-cycles-backend    #   25.34% backend  cycles idle    [66.69%]
>      63,464,955,178 instructions              #    0.21  insns per cycle
>                                               #    3.89  stalled cycles per insn [83.38%]
>      10,564,139,626 branches                  #   94.924 M/sec                   [83.39%]
>         248,015,797 branch-misses             #    2.35% of all branches         [83.32%]
>
>       200.028775802 seconds time elapsed

Side warning about the omni test path - it does not emit the "You didn't 
hit the confidence interval" warnings like the classic/migrated path 
did/does.  To see the actual width of the confidence interval you need 
to use the omni output selectors:

$ netperf -- -O ? | grep CONFID
CONFIDENCE_LEVEL
CONFIDENCE_INTERVAL
CONFIDENCE_ITERATION
THROUGHPUT_CONFID
LOCAL_CPU_CONFID
REMOTE_CPU_CONFID

You may want to see CONFIDENCE_ITERATION (how many times did it repeat 
the test) and then THROUGHPUT_CONFID and LOCAL_CPU_CONFID.  You may also 
find:

$ netperf -- -O ? | grep PEAK
LOCAL_CPU_PEAK_UTIL
LOCAL_CPU_PEAK_ID
REMOTE_CPU_PEAK_UTIL
REMOTE_CPU_PEAK_ID

interesting - those will the the utilizations and IDs of the most 
utilized CPUs on the system.

>
> 14.091 context switches per second...
>
> Interesting how it actually increases throughput !

And the service demand went up almost 20% this time :) (19.8)  That it 
has happened again lends credence to it being a real difference.

If it causes smaller-on-average TSO sends, perhaps it is triggering 
greater parallelism between the NIC(s) and the host(s)?

happy benchmarking,

rick
