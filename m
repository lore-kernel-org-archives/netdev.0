From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 15:59:52 -0700
Message-ID: <4702CD68.8090406@hp.com>
References: <20071002212608.GG29944@bitmover.com>	<20071002.144709.123999983.davem@davemloft.net>	<4702C37F.4030601@hp.com>	<20071002.153216.82129058.davem@davemloft.net> <20071002223644.GA14331@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	herbert@gondor.apana.org.au, wscott@bitmover.com,
	netdev@vger.kernel.org
To: Larry McVoy <lm@bitmover.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:41670 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753006AbXJBW7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 18:59:54 -0400
In-Reply-To: <20071002223644.GA14331@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry McVoy wrote:
> On Tue, Oct 02, 2007 at 03:32:16PM -0700, David Miller wrote:
> 
>>I'm starting to have a theory about what the bad case might
>>be.
>>
>>A strong sender going to an even stronger receiver which can
>>pull out packets into the process as fast as they arrive.
>>This might be part of what keeps the receive window from
>>growing.
> 
> 
> I can back you up on that.  When I straced the receiving side that goes
> slowly, all the reads were short, like 1-2K.  The way that works the 
> reads were a lot larger as I recall.

Indeed I was getting more like 8K on each recv() call per netperf's -v 2 stats, 
but the system was more than fast enough to stay ahead of the traffic.  On the 
hunch that it was the interrupt throttling which was keeping the recv's large 
rather than the speed of the system(s) I nuked the InterruptThrottleRate to 0 
and was able to get between 1900 and 2300 byte recvs on the TCP_STREAM and 
TCP_MAERTS tests and still had 940 Mbit/s in each direction.

hpcpc106:~# netperf -H 192.168.7.107 -t TCP_STREAM -v 2 -c -C
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.7.107 
(192.168.7.107) port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

  87380  87380  87380    10.02       940.95   10.75    21.65    3.743   7.540

Alignment      Offset         Bytes    Bytes       Sends   Bytes    Recvs
Local  Remote  Local  Remote  Xfered   Per                 Per
Send   Recv    Send   Recv             Send (avg)          Recv (avg)
     8       8      0       0 1.179e+09  87386.29     13491   1965.77 599729

Maximum
Segment
Size (bytes)
   1448
hpcpc106:~# netperf -H 192.168.7.107 -t TCP_MAERTS -v 2 -c -C
TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.7.107 
(192.168.7.107) port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

  87380  87380  87380    10.02       940.82   20.44    10.61    7.117   3.696

Alignment      Offset         Bytes    Bytes       Recvs   Bytes    Sends
Local  Remote  Local  Remote  Xfered   Per                 Per
Recv   Send    Recv   Send             Recv (avg)          Send (avg)
     8       8      0       0 1.178e+09  2352.26    500931   87380.00  13485

Maximum
Segment
Size (bytes)
   1448

the systems above had four 1.6 GHz cores, netperf reports CPU as 0 to 100% 
regardless of core count.

and then my systems with the 3.0 GHz cores:

[root@s9 netperf2_trunk]# netperf -H sweb20 -v 2 -t TCP_STREAM -c -C
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to sweb20.cup.hp.com 
(16.89.133.20) port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

  87380  16384  16384    10.03       941.37   6.40     13.26    2.229   4.615

Alignment      Offset         Bytes    Bytes       Sends   Bytes    Recvs
Local  Remote  Local  Remote  Xfered   Per                 Per
Send   Recv    Send   Recv             Send (avg)          Recv (avg)
     8       8      0       0 1.18e+09  16384.06     72035   1453.85 811793

Maximum
Segment
Size (bytes)
   1448
[root@s9 netperf2_trunk]# netperf -H sweb20 -v 2 -t TCP_MAERTS -c -C
TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to sweb20.cup.hp.com 
(16.89.133.20) port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

  87380  16384  16384    10.03       941.35   12.13    5.80     4.221   2.018

Alignment      Offset         Bytes    Bytes       Recvs   Bytes    Sends
Local  Remote  Local  Remote  Xfered   Per                 Per
Recv   Send    Recv   Send             Recv (avg)          Send (avg)
     8       8      0       0 1.181e+09  1452.38    812953   16384.00  72065

Maximum
Segment
Size (bytes)
   1448


rick jones
