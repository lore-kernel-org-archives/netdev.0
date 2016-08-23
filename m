From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 00/15] support lockless qdisc
Date: Tue, 23 Aug 2016 13:22:32 -0700
Message-ID: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: eric.dumazet@gmail.com, jhs@mojatatu.com, davem@davemloft.net,
        brouer@redhat.com, xiyou.wangcong@gmail.com,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36486 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753897AbcHWUWu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:22:50 -0400
Received: by mail-pa0-f66.google.com with SMTP id ez1so10421702pab.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:22:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Latest round of lockless qdisc patch set with performance metric
primarily using pktgen to inject pkts into the qdisc layer

This series introduces a flag to allow qdiscs to indicate they can run
without holding the qdisc lock. In order to set this bit most qdiscs
will need to be modified to use lockless data structures. This series
implements a lockless data structures for pfifo_fast by replacing the
skb list with an skb_array. This currently still uses spin locks to
protect the array which can be improved later.

Also its worth noting when the lockless bit is set we no longer use
the busy_lock in the tx qdisc path nor do we allow bypassing the
enqueue()/dequeue() operations. We can optimize this later as well
but I wanted to keep the initial series as straight forward as
possible. The benchmarks using pktgen do not indicate there is any
significant degradation from removing the bypass logic (see numbers
below).

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
	  at drop in replacements and/or improving it. For example the
	  dequeue spin locks are not needed in many cases.


Below is the data I took from pktgen,

./samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh -t $NUM -i eth3

I did a run of 4 each time and took the total summation of each
thread. I did this for 1, 2, 4, 8, and 12 threads on both mqprio and
pfifo_fast. Overall pfifo_fast shows a performance improvement as the
number of threads increases which was causing contention in the
original locked version of the code. And on mq because I'm using an
Intel 10G hardware running the ixgbe driver creates a descriptor ring
per core resulting in pfifo_fast queue per core there is no
contention. As a result I do not see any performance improvement in
the benchmarks but it doesn't appear to hurt either so this is good.

nolock pfifo_fast
1:  1417597 1407479 1418913 1439601 
2:  1882009 1867799 1864374 1855950
4:  1806736 1804261 1803697 1806994
8:  1354318 1358686 1353145 1356645
12: 1331928 1333079 1333476 1335544


locked pfifo_fast
1:  1471479 1469142 1458825 1456788 
2:  1746231 1749490 1753176 1753780
4:  1119626 1120515 1121478 1119220
8:  1001471  999308 1000318 1000776
12:  989269  992122  991590  986581

nolock mq
1:    1417768  1438712  1449092  1426775
2:    2644099  2634961  2628939  2712867
4:    4866133  4862802  4863396  4867423
8:    9422061  9464986  9457825  9467619
12:  13854470 13213735 13664498 13213292  

locked mq
1:   1448374  1444208  1437459  1437088 
2:   2687963  2679221  2651059  2691630
4:   5153884  4684153  5091728  4635261
8:   9292395  9625869  9681835  9711651
12: 13553918 13682410 14084055 13946138



---

John Fastabend (15):
      net: sched: cleanup qdisc_run and __qdisc_run semantics
      net: sched: allow qdiscs to handle locking
      net: sched: remove remaining uses for qdisc_qlen in xmit path
      net: sched: provide per cpu qstat helpers
      net: sched: a dflt qdisc may be used with per cpu stats
      net: sched: per cpu gso handlers
      net: sched: drop qdisc_reset from dev_graft_qdisc
      net: sched: support qdisc_reset on NOLOCK qdisc
      net: sched: support skb_bad_tx with lockless qdisc
      net: sched: qdisc_qlen for per cpu logic
      net: sched: helper to sum qlen
      net: sched: lockless support for netif_schedule
      net: sched: add support for TCQ_F_NOLOCK subqueues to sch_mq
      net: sched: add support for TCQ_F_NOLOCK subqueues to sch_mqprio
      net: sched: pfifo_fast use skb_array


 include/net/gen_stats.h   |    3 
 include/net/pkt_sched.h   |   10 +
 include/net/sch_generic.h |  108 +++++++++++
 net/core/dev.c            |   59 +++++-
 net/core/gen_stats.c      |    9 +
 net/sched/sch_api.c       |   21 ++
 net/sched/sch_generic.c   |  424 ++++++++++++++++++++++++++++++++++-----------
 net/sched/sch_mq.c        |   25 ++-
 net/sched/sch_mqprio.c    |   61 ++++--
 9 files changed, 567 insertions(+), 153 deletions(-)
