From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 00/17] latest qdisc patch series
Date: Tue, 02 May 2017 08:36:03 -0700
Message-ID: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36852 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdEBPgS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:36:18 -0400
Received: by mail-pf0-f193.google.com with SMTP id v14so33763585pfd.3
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:36:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- v2 now hopefully with all patches and uncorrupted -

This is my latest series of patches to remove the locking requirement
from qdisc logic. 

I still have a couple issues to resolve main problem at the moment is
pfifo_fast qdisc without contention running under mq or mqprio is
actually slower by a few 100k pps with pktgen tests. I am trying to
sort out how to get the performance back now.

The main difference in these patches is to recognize that parking
packets on the gso slot and bad txq cases are really edge cases and
can be handled with locked queue operations. This simplifies the
patches and avoids racing with netif scheduler. If you hit these paths
it means either there is a driver overrun, should be very rare with
bql, or a TCP session has migrated cores with outstanding packets.

Patches 16, 17 were an attempt to resolve the performance degradation
in the uncontended case. The idea is to use the qdisc lock around the
dequeue operations so that we only need to take a single lock for the
entire bulk operation and can consume packets out of skb_array without
a spin_lock.

Another potential issue, I think, is if we have multiple packets
on the bad_txq we should bulk out of the bad_txq and not jump to
bulking out of the "normal" dequeue qdisc op.

I've mostly tested with pktgen at this point but have done some basic
netperf tests and both seem to be working.

I am not going to be able to work on this for a few days so I figured
it might be worth getting some feedback if there is any. Any thoughts
on how to squeeze a few extra pps out of this would be very useful. I
would like to avoid having a degradation in the micro-benchmark if
possible. Further, it should be possible best I can tell.

Thanks!
John

---

John Fastabend (17):
      net: sched: cleanup qdisc_run and __qdisc_run semantics
      net: sched: allow qdiscs to handle locking
      net: sched: remove remaining uses for qdisc_qlen in xmit path
      net: sched: provide per cpu qstat helpers
      net: sched: a dflt qdisc may be used with per cpu stats
      net: sched: explicit locking in gso_cpu fallback
      net: sched: drop qdisc_reset from dev_graft_qdisc
      net: sched: support skb_bad_tx with lockless qdisc
      net: sched: check for frozen queue before skb_bad_txq check
      net: sched: qdisc_qlen for per cpu logic
      net: sched: helper to sum qlen
      net: sched: add support for TCQ_F_NOLOCK subqueues to sch_mq
      net: sched: add support for TCQ_F_NOLOCK subqueues to sch_mqprio
      net: skb_array: expose peek API
      net: sched: pfifo_fast use skb_array
      net: skb_array additions for unlocked consumer
      net: sched: lock once per bulk dequeue


 include/linux/skb_array.h |   10 +
 include/net/gen_stats.h   |    3 
 include/net/pkt_sched.h   |   10 +
 include/net/sch_generic.h |   82 ++++++++-
 net/core/dev.c            |   31 +++
 net/core/gen_stats.c      |    9 +
 net/sched/sch_api.c       |    3 
 net/sched/sch_generic.c   |  400 +++++++++++++++++++++++++++++++++------------
 net/sched/sch_mq.c        |   25 ++-
 net/sched/sch_mqprio.c    |   61 ++++---
 10 files changed, 470 insertions(+), 164 deletions(-)
