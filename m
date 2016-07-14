From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 00/10] running qdiscs without qdisc_lock
Date: Wed, 13 Jul 2016 23:19:37 -0700
Message-ID: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de, jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33965 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbcGNGTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 02:19:51 -0400
Received: by mail-pf0-f176.google.com with SMTP id h14so26447193pfe.1
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 23:19:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I thought I should go ahead and send this series out for comments.
Here I allow qdiscs to be run without taking the qdisc lock. As a
result statistics, gso skb, tx bad skb and a few other things need
to be "safe" to run without locks. It _should_ all be covered here.
Although I just noticed I must be missing a dec on the backlog
counter somewhere as one of my tests just ended with 0packets but
a nonzero bytes counter.

Also of note in this series I used the skb_array implementation
already in net-next for the tun/tap devices. With this implementation
for cases where lots of threads are hitting the same qdisc I see
a modest improvement but for cases like mq with pktgen where
everything is lined up nicely I see a fairly unpleasant regression.

I have a few thoughts on how to resolve this. First if we support
bulk_dequeue as an operation on the skb_array this should help
vs getting the consumer lock repeatedly. Also we really don't need
the HARD_TX_LOCK if we have a core per queue and XPS setup like many
multiqueue nics default to. And I need to go back and look at the
original alf ring implementation as well to see how it compares I
don't recall seeing the mq regression there.

Also after the above it might be nice to make all qdiscs support
the per cpu statistics and drop non per cpu cases just to simplify
the code and all the if/else branching where its not needed.

As usual any thoughts, comments, etc are welcome.

And I wasn't going to add these numbers just because they come from
an untuned system but why not.

Here are some initial numbers from pktgen on my development which
is a reasonable system (E5-2695) but I didn't do any work to tweak
the config so there is still a bunch of debug/hacking options still
running.

The pktgen command is

./samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh -i eth3  -t X -s 64

pfifo_fast

        original pps        lockless        diff
1       1418168             1269450         -148718
2       1587390             1553408         -33982
4       1084961             1683639         +598678
8       989636              1522723         +533087
12      1014018             1348172         +334154

mq
       original pps        lockless        diff
1      1442018             1205180        -236838 
2      2646069             2266095        -379974
4      5136200             4269470        -866730
8      
12     13275671            10810909       -2464762

---

John Fastabend (10):
      net: sched: allow qdiscs to handle locking
      net: sched: qdisc_qlen for per cpu logic
      net: sched: provide per cpu qstat helpers
      net: sched: a dflt qdisc may be used with per cpu stats
      net: sched: per cpu gso handlers
      net: sched: support qdisc_reset on NOLOCK qdisc
      net: sched: support skb_bad_tx with lockless qdisc
      net: sched: pfifo_fast use alf_queue
      net: sched: helper to sum qlen
      net: sched: add support for TCQ_F_NOLOCK subqueues to sch_mq


 include/net/gen_stats.h   |    3 
 include/net/sch_generic.h |  105 ++++++++++++
 net/core/dev.c            |   32 +++-
 net/core/gen_stats.c      |    9 +
 net/sched/sch_api.c       |   12 +
 net/sched/sch_generic.c   |  385 +++++++++++++++++++++++++++++++++++----------
 net/sched/sch_mq.c        |   25 ++-
 7 files changed, 467 insertions(+), 104 deletions(-)
