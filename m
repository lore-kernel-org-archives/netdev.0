From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 00/15] remove qdisc lock from ingress_qdisc
Date: Wed, 30 Apr 2014 09:34:41 -0700
Message-ID: <20140430163250.9021.21199.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36661 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945934AbaD3Qe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 12:34:58 -0400
Received: by mail-ob0-f175.google.com with SMTP id wp4so2278002obc.34
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 09:34:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series drops the qdisc lock that is currently protecting the
ingress qdisc. This can be done after the tcf filters are made
lockless and the statistic accounting is safe to run without locks.

To do this the classifiers are converted to use RCU. This requires
updating each classifier individually to handle the new copy/update
requirement and also to update the core list traversals. This is
done in patches 2-11. This also makes the assumption that updates
to the tables are infrequent in comparison to the packet per second
being classified. On a 10Gbps running near line rate we can easily
produce 12+ million packets per second so IMO this is a reasonable
assumption. And the updates are serialized by RTNL.

In order to have working statistics patch 13 and 14 convert the
bstats and qstats, which do accounting for bytes and packets, into
percpu variables and the u64_stats_update_{begin|end} infrastructure
is used to maintain consistent 64bit statistics. Because these
statistics are also used by the estimators those function calls had
to be udpated as well. So that I didn't have to modify all qdiscs at
this time many of which don't have an easy path to make lockless the
percpu statistics are only used when the TCQ_F_LLQDISC flag is set.
Its worth noting that in the mq and mqprio case sub-qdisc's are
already mapped 1:1 with TX queues which tend to be equal to the number
of CPUs in the system so its not clear that removing locking in
these cases would provide any benefit. Most likely a new qdisc
written from scratch would be needed to implement a mq-htb or
mq-tbf qdisc.

As for some history I wrote what was basically these patches some
time ago and then got stalled working on other things. Cong Wang
made a proposal to remove the locking around the ingress qdisc
which then kicked me to get these patches working again.

I have done some basic testing on this series and do no see any
immediate splats or issues. I will continue doing some more testing
for the rest of the week before submitting without the RCU tag but
any feedback would be good. If someone has a better idea for the
percpu union of gnet_stats_basic_* in struct Qdisc or finds it
paticularly ugly that would be good to know. At this point I
believe the patch set is complete.

My test cases at this point cover all the filters with a
tight loop to add/remove filters. Some basic estimator tests
where I add an estimator to the qdisc and verify the statistics
accurate using pktgen. And finally I have a small script to
exercise the 'tc actions' interface. Feel free to send me more
tests off list and I can run them.

Performance numbers TBD (working on this).

Also there are still a few checkpatch warnings I need to resolve.

Future work:
  - provide metadata such as current cpu for the classifier
    to match on. this would allow for a multiqueue ingress
    qdisc strategy.
  - provide filter hook on egress before queue is selected
    to allow a classifier/action to pick the tx queue. This
    generalizes mqprio and should remove the need for many
    drivers to implement select_queue() callbacks.
  - create a variant of tbf that does not require the qdisc
    lock using eventually consistent counters.

---

John Fastabend (15):
      net: qdisc: use rcu prefix and silence sparse warnings
      net: rcu-ify tcf_proto
      net: sched: cls_basic use RCU
      net: sched: cls_cgroup use RCU
      net: sched: cls_flow use RCU
      net: sched: fw use RCU
      net: sched: RCU cls_route
      net: sched: RCU cls_tcindex
      net: sched: make cls_u32 lockless
      net: sched: rcu'ify cls_rsvp
      net: make cls_bpf rcu safe
      net: sched: make tc_action safe to walk under RCU
      net: sched: make bstats per cpu and estimator RCU safe
      net: sched: make qstats per cpu
      net: sched: drop ingress qdisc lock


 include/linux/netdevice.h  |   29 +----
 include/linux/rtnetlink.h  |   10 ++
 include/net/act_api.h      |    1 
 include/net/codel.h        |    4 -
 include/net/gen_stats.h    |   17 +++
 include/net/pkt_cls.h      |   12 ++
 include/net/sch_generic.h  |   93 +++++++++++++---
 net/core/dev.c             |   47 +++++++-
 net/core/gen_estimator.c   |   60 ++++++++--
 net/core/gen_stats.c       |   76 +++++++++++++
 net/netfilter/xt_RATEEST.c |    4 -
 net/sched/act_api.c        |   23 ++--
 net/sched/act_police.c     |    4 -
 net/sched/cls_api.c        |   47 ++++----
 net/sched/cls_basic.c      |   80 ++++++++------
 net/sched/cls_bpf.c        |   79 +++++++------
 net/sched/cls_cgroup.c     |   63 +++++++----
 net/sched/cls_flow.c       |  145 ++++++++++++++-----------
 net/sched/cls_fw.c         |  108 +++++++++++++-----
 net/sched/cls_route.c      |  221 ++++++++++++++++++++++----------------
 net/sched/cls_rsvp.h       |  152 +++++++++++++++-----------
 net/sched/cls_tcindex.c    |  240 +++++++++++++++++++++++++----------------
 net/sched/cls_u32.c        |  258 +++++++++++++++++++++++++++++---------------
 net/sched/sch_api.c        |   71 ++++++++++--
 net/sched/sch_atm.c        |   32 +++--
 net/sched/sch_cbq.c        |   40 ++++---
 net/sched/sch_choke.c      |   33 ++++--
 net/sched/sch_codel.c      |    2 
 net/sched/sch_drr.c        |   27 +++--
 net/sched/sch_dsmark.c     |   10 +-
 net/sched/sch_fifo.c       |    6 +
 net/sched/sch_fq.c         |    4 -
 net/sched/sch_fq_codel.c   |   19 ++-
 net/sched/sch_generic.c    |   20 +++
 net/sched/sch_gred.c       |   10 +-
 net/sched/sch_hfsc.c       |   47 +++++---
 net/sched/sch_hhf.c        |    8 +
 net/sched/sch_htb.c        |   45 +++++---
 net/sched/sch_ingress.c    |   20 +++
 net/sched/sch_mq.c         |   31 +++--
 net/sched/sch_mqprio.c     |   54 ++++++---
 net/sched/sch_multiq.c     |   18 ++-
 net/sched/sch_netem.c      |   17 ++-
 net/sched/sch_pie.c        |    8 +
 net/sched/sch_plug.c       |    2 
 net/sched/sch_prio.c       |   21 ++--
 net/sched/sch_qfq.c        |   29 +++--
 net/sched/sch_red.c        |   13 +-
 net/sched/sch_sfb.c        |   28 +++--
 net/sched/sch_sfq.c        |   30 +++--
 net/sched/sch_tbf.c        |   11 +-
 net/sched/sch_teql.c       |    9 +-
 52 files changed, 1552 insertions(+), 886 deletions(-)

-- 
Signature
