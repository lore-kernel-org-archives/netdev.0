From: Rick Jones <rick.jones2@hp.com>
Subject: Re: >10% performance degradation since 2.6.18
Date: Mon, 06 Jul 2009 10:00:10 -0700
Message-ID: <4A522D9A.1090006@hp.com>
References: <20090705040137.GA7747@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, andi@firstfloor.org,
	arjan@infradead.org, matthew@wil.cx, jens.axboe@oracle.com,
	linux-kernel@vger.kernel.org, douglas.w.styner@intel.com,
	chinang.ma@intel.com, terry.o.prickett@intel.com,
	matthew.r.wilcox@intel.com, Eric.Moore@lsi.com,
	DL-MPTFusionLinux@lsi.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:22593 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbZGFRAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 13:00:11 -0400
In-Reply-To: <20090705040137.GA7747@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Jeff Garzik <jeff@garzik.org> wrote:
> 
>>What's the best setup for power usage?
>>What's the best setup for performance?
>>Are they the same?
> 
> 
> Yes.
> 
> 
>>Is it most optimal to have the interrupt for socket $X occur on the same 
>>CPU as where the app is running?
> 
> 
> Yes.

Well...  Yes, if the goal is lowest service demand/latency, but not always if 
the goal is to have highest throughput.  For example, basic netperf TCP_RR 
between a pair of systems with NIC interrupts pinned to CPU0 for my convenience :)

Pin netperf/netserver to CPU0 as well:
sbs133b15:~ # netperf -H sbs133b16 -t TCP_RR -T 0 -c -C
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
sbs133b16.west (10.208.1.50) port 0 AF_INET : first burst 0 : cpu bind
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

16384  87380  1       1      10.00   16396.22  0.39   0.55   3.846   5.364
16384  87380

Now pin it to the peer thread in that same core:

sbs133b15:~ # netperf -H sbs133b16 -t TCP_RR -T 8 -c -C
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
sbs133b16.west (10.208.1.50) port 0 AF_INET : first burst 0 : cpu bind
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

16384  87380  1       1      10.00   14078.23  0.67   0.87   7.604   9.863
16384  87380

Now pin it to another core in that same processor:

sbs133b15:~ # netperf -H sbs133b16 -t TCP_RR -T 2 -c -C
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
sbs133b16.west (10.208.1.50) port 0 AF_INET : first burst 0 : cpu bind
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

16384  87380  1       1      10.00   14649.57  1.76   0.64   19.213  7.036
16384  87380

Certainly seems to support "run on the same core as interrupts." Now though lets 
look at bulk throughput:

sbs133b15:~ # netperf -H sbs133b16 -T 0 -c -C
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to sbs133b16.west 
(10.208.1.50) port 0 AF_INET : cpu bind
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

  87380  16384  16384    10.00      9384.11   3.39     2.19     0.474   0.306

In this case, I'm running on Nehalems (two quad-cores with threads enabled) so I 
have enough "oomph" to hit link-rate on a classic throughput test so all these 
next two will show is the CPU hit and some of the run to run variablity:

sbs133b15:~ # for t in 8 2; do netperf -P 0 -H sbs133b16 -T $t -c -C -B "bind to 
core $t"; done
  87380  16384  16384    10.00      9383.67   4.23     5.21     0.591   0.728 
bind to core 8
  87380  16384  16384    10.00      9383.12   3.03     5.35     0.423   0.747 
bind to core 2

So apart from the thing on the top of my head what is my point?  Let's look at a 
less conventional but still important case - bulk small packet throughput. 
First, find the limit for a single connection when bound to the interrupt core:

sbs133b15:~ # for b in 0 4 16 64 128 256; do netperf -P 0 -t TCP_RR -T 0 -H 
sbs133b16 -c -C -B "$b added simultaneous trans" -- -D -b $b; done
16384  87380  1       1      10.00   16336.52  0.69   0.91   6.715   8.944  0 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   61324.84  2.23   2.27   5.825   5.910  4 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   152221.78  2.81   3.49   2.956   3.664  16 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   291247.72  4.86   5.07   2.670   2.788  64 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   292257.59  3.99   5.91   2.183   3.236  128 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   291734.00  5.55   5.32   3.043   2.920  256 
added simultaneous trans
16384  87380

Now, when bound to the peer thread:
sbs133b15:~ # for b in 0 4 16 64 128 256; do netperf -P 0 -t TCP_RR -T 8 -H 
sbs133b16 -c -C -B "$b added simultaneous trans" -- -D -b $b; done
16384  87380  1       1      10.00   14367.40  0.78   1.75   8.652   19.477 0 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   54820.22  2.73   4.78   7.956   13.948 4 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   159305.92  4.61   6.84   4.627   6.874  16 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   260227.55  6.26   8.36   3.851   5.140  64 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   256336.50  6.23   8.00   3.891   4.993  128 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   250543.92  6.24   6.29   3.985   4.014  256 
added simultaneous trans
16384  87380

Things still don't look good for running on another CPU, but wait :)  Bind to 
another core in the same processor:

sbs133b15:~ # for b in 0 4 16 64 128 256; do netperf -P 0 -t TCP_RR -T 2 -H 
sbs133b16 -c -C -B "$b added simultaneous trans" -- -D -b $b; done
16384  87380  1       1      10.00   14697.98  0.89   1.53   9.689   16.700 0 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   58201.08  2.11   4.21   5.804   11.585 4 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   158999.50  3.87   6.20   3.899   6.240  16 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   379243.72  6.24   9.04   2.634   3.815  64 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   384823.34  6.15   9.50   2.556   3.949  128 
added simultaneous trans
16384  87380
16384  87380  1       1      10.00   375001.50  6.07   9.63   2.588   4.109  256 
added simultaneous trans
16384  87380

When the CPU does not have enough "oomph" for link-rate 10G, then what we see 
above with the aggregate TCP_RR holds true for a plain TCP_STREAM test as well - 
getting the second core involved, while indeed increasing CPU util, also 
provides the additional cycles required to get higher thoughput.  So what is 
optimal depends on what one wishes to optimize.

> 
>>If yes, how to best handle when the scheduler moves app to another CPU?
>>Should we reprogram the NIC hardware flow steering mechanism at that point?
> 
> 
> Not really.  For now the best thing to do is to pin everything
> down and not move at all, because we can't afford to move.
> 
> The only way for moving to work is if we had the ability to get
> the sockets to follow the processes.  That means, we must have
> one RX queue per socket.

Well, or assign sockets to per-core RX queues and be able to move them around. 
If it weren't for all the smarts in the NICs getting in the way :), we'd 
probably do the "lookup where the socket was last accessed and run there" thing 
somewhere in the inbound path a la TOPS.

rick jones

> 
> Cheers,

