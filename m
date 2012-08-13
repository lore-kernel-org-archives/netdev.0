From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [RFC net-next 0/4] gianfar: Use separate NAPI for Tx confirmation
 processing
Date: Mon, 13 Aug 2012 19:23:09 +0300
Message-ID: <502929ED.2050703@freescale.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com> <20120808162423.GC11043@windriver.com> <1344444267.28967.225.camel@edumazet-glaptop> <CAOy7UX2AW2w8TE0=7HGqRDJnX3Te5XZmW8UfC8F6HZg1RdWCYw@mail.gmail.com> <5023D21E.1000008@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Tomas Hruby <thruby@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe005.messaging.microsoft.com ([213.199.154.143]:1897
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752013Ab2HMQX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2012 12:23:26 -0400
In-Reply-To: <5023D21E.1000008@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2012 06:07 PM, Claudiu Manoil wrote:
> On 8/9/2012 2:06 AM, Tomas Hruby wrote:
>> On Wed, Aug 8, 2012 at 9:44 AM, Eric Dumazet <eric.dumazet@gmail.com> 
>> wrote:
>>> On Wed, 2012-08-08 at 12:24 -0400, Paul Gortmaker wrote:
>>>> [[RFC net-next 0/4] gianfar: Use separate NAPI for Tx confirmation 
>>>> processing] On 08/08/2012 (Wed 15:26) Claudiu Manoil wrote:
>>>>
>>>>> Hi all,
>>>>> This set of patches basically splits the existing napi poll 
>>>>> routine into
>>>>> two separate napi functions, one for Rx processing (triggered by 
>>>>> frame
>>>>> receive interrupts only) and one for the Tx confirmation path 
>>>>> processing
>>>>> (triggerred by Tx confirmation interrupts only). The polling 
>>>>> algorithm
>>>>> behind remains much the same.
>>>>>
>>>>> Important throughput improvements have been noted on low power 
>>>>> boards with
>>>>> this set of changes.
>>>>> For instance, for the following netperf test:
>>>>> netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
>>>>> yields a throughput gain from oscilating ~500-~700 Mbps to steady 
>>>>> ~940 Mbps,
>>>>> (if the Rx/Tx paths are processed on different cores), w/ no 
>>>>> increase in CPU%,
>>>>> on a p1020rdb - 2 core machine featuring etsec2.0 (Multi-Queue 
>>>>> Multi-Group
>>>>> driver mode).
>>>>
>>>> It would be interesting to know more about what was causing that large
>>>> an oscillation -- presumably you will have it reappear once one core
>>>> becomes 100% utilized.  Also, any thoughts on how the change will 
>>>> change
>>>> performance on an older low power single core gianfar system (e.g.  
>>>> 83xx)?
>>>
>>> I also was wondering if this low performance could be caused by BQL
>>>
>>> Since TCP stack is driven by incoming ACKS, a NAPI run could have to
>>> handle 10 TCP acks in a row, and resulting xmits could hit BQL and
>>> transit on qdisc (Because NAPI handler wont handle TX completions in 
>>> the
>>> middle of RX handler)
>>
>> Does disabling BQL help? Is the BQL limit stable? To what value is it
>> set? I would be very much interested in more data if the issue is BQL
>> related.
>>
>> .
>>
>
> I agree that more tests should be run to investigate why gianfar under-
> performs on the low power p1020rdb platform, and BQL seems to be
> a good starting point (thanks for the hint). What I can say now is that
> the issue is not apparent on p2020rdb, for instance, which is a more
> powerful platform: the CPUs - 1200 MHz instead of 800 MHz; twice the
> size of L2 cache (512 KB), greater bus (CCB) frequency ... On this
> board (p2020rdb) the netperf test reaches 940Mbps both w/ and w/o these
> patches.
>
> For a single core system I'm not expecting any performance degradation,
> simply because I don't see why the proposed napi poll implementation
> would be slower than the existing one. I'll do some measurements on a
> p1010rdb too (single core, CPU:800 MHz) and get back to you with the
> results.
>

Hi all,

Please find below the netperf measurements performed on a p1010rdb machine
(single core, low power).  Three kernel images were used:
1) Linux version 3.5.0-20970-gaae06bf  -- net-next commit aae06bf
2) Linux version 3.5.0-20974-g2920464 -- commit aae06bf + Tx NAPI patches
3) Linux version 3.5.0-20970-gaae06bf-dirty -- commit aae06bf + 
CONFIG_BQL set to 'n'

The results show that, on *Image 1)*, by adjusting 
tcp_limit_output_bytes no substantial
improvements are seen, as the throughput stays in the 580-60x Mbps range .
By changing the coalescing settings from default* (rx coalescing off,
tx-usecs: 10, tx-frames: 16) to:
"ethtool -C eth1 rx-frames 22 tx-frames 22 rx-usecs 32 tx-usecs 32"
we get a throughput of ~710 Mbps.

For *Image 2)*, using the default tcp_limit_output_bytes value (131072) 
- I've noticed
that "tweaking" tcp_limit_output_bytes does not improve the throughput 
-, we get the
following performance numbers:
* default coalescing settings: ~650 Mbps
* rx-frames tx-frames 22 rx-usecs 32 tx-usecs 32: ~860-880 Mbps

For *Image 3)*, by disabling BQL (CONFIG_BQL = n), there's *no* relevant 
performance
improvement compared to Image 1).
(note:
For all the measurements, rx and tx BD ring sizes have been set to 64, 
for best performance.)

So, I really tend to believe that the performance degradation comes 
primarily from the driver,
and the napi poll processing turns out to be an important source for 
that. The proposed patches
show substantial improvement, especially for SMP systems where Tx and Rx 
processing may be
done in parallel.
What do you think?
Is it ok to proceed by re-spinning the patches? Do you recommend 
additional measurements?

Regards,
Claudiu

//=Image 1)================
root@p1010rdb:~# cat /proc/version
Linux version 3.5.0-20970-gaae06bf [...]

root@p1010rdb:~# zcat /proc/config.gz | grep BQL
CONFIG_BQL=y
root@p1010rdb:~# cat /proc/sys/net/ipv4/tcp_limit_output_bytes
131072

root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       580.76   99.95    11.76 14.099  1.659
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       598.21   99.95    10.91 13.687  1.493
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       583.04   99.95    11.25 14.043  1.581


root@p1010rdb:~# cat /proc/sys/net/ipv4/tcp_limit_output_bytes
65536

root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       604.29   99.95    11.15 13.550  1.512
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       603.52   99.50    12.57 13.506  1.706
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       596.18   99.95    12.81 13.734  1.760



root@p1010rdb:~# cat /proc/sys/net/ipv4/tcp_limit_output_bytes
32768

root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       582.32   99.95    12.96 14.061  1.824
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       583.79   99.95    11.19 14.026  1.571
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       584.16   99.95    11.36 14.016  1.592



root@p1010rdb:~# ethtool -C eth1 rx-frames 22 tx-frames 22 rx-usecs 32 
tx-usecs 32

root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       708.77   99.85    13.32 11.541  1.540
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       710.50   99.95    12.46 11.524  1.437
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       709.95   99.95    14.15 11.533  1.633


//=Image 2)================

root@p1010rdb:~# cat /proc/version
Linux version 3.5.0-20974-g2920464 [...]

root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       652.60   99.95    13.05 12.547  1.638
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       657.47   99.95    11.81 12.454  1.471
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       655.77   99.95    11.80 12.486  1.474


root@p1010rdb:~# ethtool -C eth1 rx-frames 22 rx-usecs 32 tx-frames 22 
tx-usecs 32

root@p1010rdb:~# cat /proc/sys/net/ipv4/tcp_limit_output_bytes
131072
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.01       882.42   99.20    18.06 9.209   1.676
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       867.02   99.75    16.21 9.425   1.531
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.01       874.29   99.85    15.25 9.356   1.429


//=Image 3)================

Linux version 3.5.0-20970-gaae06bf-dirty [...] //CONFIG_BQL = n

root@p1010rdb:~# cat /proc/version
Linux version 3.5.0-20970-gaae06bf-dirty 
(b08782@zro04-ws574.ea.freescale.net) (gcc version 4.6.2 (GCC) ) #3 Mon 
Aug 13 13:58:25 EEST 2012
root@p1010rdb:~# zcat /proc/config.gz | grep BQL
# CONFIG_BQL is not set

root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       595.08   99.95    12.51 13.759  1.722
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       593.95   99.95    10.96 13.785  1.511
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       595.30   99.90    11.11 13.747  1.528

root@p1010rdb:~# ethtool -C eth1 rx-frames 22 rx-usecs 32 tx-frames 22 
tx-usecs 32
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       710.46   99.95    12.46 11.525  1.437
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       714.27   99.95    14.05 11.463  1.611
root@p1010rdb:~# netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.10.1 
(192.168.10.1) port 0 AF_INET
Recv   Send    Send                          Utilization Service Demand
Socket Socket  Message  Elapsed              Send     Recv Send    Recv
Size   Size    Size     Time     Throughput  local    remote local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S us/KB   us/KB

  87380  16384   1500    20.00       717.69   99.95    12.56 11.409  1.433
.
