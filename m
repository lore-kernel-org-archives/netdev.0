From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 00/13] Series short description
Date: Wed, 17 Aug 2016 12:33:04 -0700
Message-ID: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35854 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbcHQTqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 15:46:16 -0400
Received: by mail-oi0-f65.google.com with SMTP id b22so13061950oii.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 12:46:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been working on this for a bit now figured its time for a v2 RFC. As
usual any comments, suggestions, observations, musings, etc are appreciated.

Latest round of lockless qdisc patch set with performance metric primarily
using pktgen to inject pkts into the qdisc layer. Some simple netperf tests
below as well but those need to be done correctly.

This v2 RFC version fixes a couple flaws in the original series. The first
major one was that the per_cpu accounting of qlen is not correct with respect
to the qdisc bypass. Using per cpu counters for qlen allows a flow to be
enqueuing on the packets into the qdisc and then get scheduled on another
core and bypass the qdisc completely if that core is not in use. I've reworked
the logic to use an atomic which is _correct_ now but unfortunately costs
a lot in performance. With a single pfifo_fast and 12 threads of pktgen
I still see a ~200k pps improvement even with atomic accounting so it is
still a win but nothing like the +1Mpps without the atomic accounting.

On the mq tests it atomic vs per cpu seems to be in the noise I believe
because mq qdisc is already aligned with a pfifo_fast qdisc per core
with the XPS setup I'm running mapping 1:1.

Any thoughts around this would be interesting to hear. My general thinking
around this is to submit the atomic version for inclusion and then start
to improve it with a few items listed below.

Additionally I've added a __netif_schedule() to the bad_skb_tx path
otherwise I observed a pkt getting stuck on the bad_txq_cpu path on
the pointer and sitting in the qdisc structure until it was kicked again
from another pkt or netif_schedule. And on the netif_schedule() topic
to support per cpu handling of gso and bad_txq_cpu we have to allow
the netif_schedule() logic to fire on a per cpu model as well.

Otherwise a bunch of small stylistic changes were made and I still need
to do another pass to catch checkpatch warnings/errors and try to do a bit
more cleanup around the statistics if/else branching. This series also
has both the atomic qlen code and the per cpu qlen code as I continue
to think up some scheme around the atomic qlen issue.

But this series seems to be working.

Future work is the following,

	- convert all qdiscs over to per cpu handling and cleanup the
	  rather ugly if/else statistics handling. Although a bit of
	  work its mechanical and should help some.

	- I'm looking at fq_codel to see how to make it "lockless".

	- It seems we can drop the TX_HARD_LOCK on cases where the
	  nic exposes a queue per core now that we have enqueue/dequeue
	  decoupled. The idea being a bunch of threads enqueue and per
	  core dequeue logic runs. Requires XPS to be setup.

	- qlen improvements somehow

	- look at improvements to the skb_array structure. We can look
	  at drop in replacements and/or improving it.


Below is the data I took from pktgen,

./samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh -t $NUM -i eth3

I did a run of 4 each time and took the total summation of each
thread. There are four different runs for the mq and pfifo_fast
cases. "without qlen atomic" uses per queue qlen values and allows
bypassing the qdisc via bypass flag, this is incorrect but shows
the impact of having an atomic in the mix. "with qlen atomic" shows
the correct implementation with atomics and bypass enabled. And
finally "without qlen atomic and no bypass" uses per cpu qlen
values and disables bypass to ensure ooo packets are not created.
To be clear the submitted patches here are the "with qlen atomic"
metrics.

nolock pfifo_fast (without qlen atomic)

1:  1440293 1421602 1409553 1393469 1424543
2:  1754890 1819292 1727948 1797711 1743427
4:  3282665 3344095 3315220 3332777 3348972
8:  2940079 1644450 2950777 2922085 2946310
12: 2042084 2610060 2857581 3493162 3104611

nolock pfifo_fast (with qlen atomic)
1:  1425231 1417176 1402862 1432880
2:  1631437 1633398 1630867 1628816
4:  1704383 1709900 1706274 1710198
8:  1348672 1344343 1339072 1334288
12: 1262988 1280724 1262237 1262615 

nolock pfifo_fast (without qlen atomic and no bypass)
1:  1435796 1458522 1471855 1455658
2:  1880642 1876359 1872879 1884578
4:  1922935 1914589 1912832 1912116
8:  1585055 1576887 1577086 1570236
12: 1479273 1450706 1447056 1466330

lock (pfifo_fast)
1:  1471479 1469142 1458825 1456788 1453952
2:  1746231 1749490 1753176 1753780 1755959
4:  1119626 1120515 1121478 1119220 1121115
8:  1001471  999308 1000318 1000776 1000384
12:  989269  992122  991590  986581  990430

nolock (mq with per cpu qlen)
1:   1435952  1459523  1448860  1385451   1435031
2:   2850662  2855702  2859105  2855443   2843382
4:   5288135  5271192  5252242  5270192   5311642
8:  10042731 10018063  9891813  9968382   9956727
12: 13265277 13384199 13438955 13363771  13436198

nolock (mq with qlen atomic)
1:   1558253  1562285  1555037  1558422
2:   2917449  2952852  2921697  2892313
4:   5518243  5375300  5625724  5219599
8:  10183153 10169389 10163161 10202530
12: 13877976 13459987 13081520 13996757 

nolock (mq with !bypass and per cpu qlen)
1:   1369110  1379992  1359407  1397014
2:   2575546  2557471  2580782  2593226
4:   4632570  4871850  4830725  4968439
8:   8974135  8951107  9134641  9084347
12: 12982673 12737426 12808364 

lock (mq)
1:   1448374  1444208  1437459  1437088  1452453
2:   2687963  2679221  2651059  2691630  2667479
4:   5153884  4684153  5091728  4635261  4902381
8:   9292395  9625869  9681835  9711651  9660498
12: 13553918 13682410 14084055 13946138 13724726

######################################################

A few arbitrary netperf sessions... (TBD lots of sessions, etc).

nolock (mq with !bypass and per cpu qlen)

root@john-Precision-Tower-5810:~# netperf -H 22.1 -t TCP_RR -- -s 128K -S 128K -b 0   
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 22.1 () port 0 AF_INET : demo : first burst 0
q Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate         
bytes  Bytes  bytes    bytes   secs.    per sec   

262144 262144 1        1       10.00    19910.37   
262144 262144


nolock (pfifo_fast with !bypass and per cpu qlen)

root@john-Precision-Tower-5810:~# netperf -H 22.1 -t TCP_RR -- -s 128K -S 128K -b 0 
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 22.1 () port 0 AF_INET : demo : first burst 0
fgLocal /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate         
bytes  Bytes  bytes    bytes   secs.    per sec   

262144 262144 1        1       10.00    20358.90   
262144 262144

nolock (mq with qlen atomic)

root@john-Precision-Tower-5810:/home/john/git/kernel.org/master# netperf -H 22.1 -t TCP_RR -- -s 128K -S 128K -b 0 
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 22.1 () port 0 AF_INET : demo : first burst 0
kLocal /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate         
bytes  Bytes  bytes    bytes   secs.    per sec   

262144 262144 1        1       10.00    20202.38   
262144 262144

nolock (pfifo_fast with qlen_atomic)

root@john-Precision-Tower-5810:/home/john/git/kernel.org/master# netperf -H 22.1 -t TCP_RR -- -s 128K -S 128K -b 0 
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 22.1 () port 0 AF_INET : demo : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate         
bytes  Bytes  bytes    bytes   secs.    per sec   

262144 262144 1        1       10.00    20059.41   
262144 262144

lock (mq)

TBD


lock (pfifo_fast) 

TBD



---

John Fastabend (13):
      net: sched: allow qdiscs to handle locking
      net: sched: qdisc_qlen for per cpu logic
      net: sched: provide per cpu qstat helpers
      net: sched: provide atomic qlen helpers for bypass case
      net: sched: a dflt qdisc may be used with per cpu stats
      net: sched: per cpu gso handlers
      net: sched: support qdisc_reset on NOLOCK qdisc
      net: sched: support skb_bad_tx with lockless qdisc
      net: sched: helper to sum qlen
      net: sched: lockless support for netif_schedule
      net: sched: pfifo_fast use alf_queue
      net: sched: add support for TCQ_F_NOLOCK subqueues to sch_mq
      net: sched: add support for TCQ_F_NOLOCK subqueues to sch_mqprio


 include/net/gen_stats.h   |    3 
 include/net/pkt_sched.h   |    4 
 include/net/sch_generic.h |  127 ++++++++++++++
 net/core/dev.c            |   60 +++++--
 net/core/gen_stats.c      |    9 +
 net/sched/sch_api.c       |   21 ++
 net/sched/sch_generic.c   |  404 +++++++++++++++++++++++++++++++++++----------
 net/sched/sch_mq.c        |   25 ++-
 net/sched/sch_mqprio.c    |   61 ++++---
 9 files changed, 577 insertions(+), 137 deletions(-)
