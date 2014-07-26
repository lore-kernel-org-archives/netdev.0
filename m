From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 00/15] RCU sched classifiers
Date: Fri, 25 Jul 2014 21:25:03 -0700
Message-ID: <20140726042439.21036.57721.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:64377 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbaGZEZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2014 00:25:24 -0400
Received: by mail-oa0-f49.google.com with SMTP id eb12so6506846oac.36
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 21:25:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A rather long description...

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
assumption. The updates are serialized by RTNL.

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
these cases would provide large benefits. Most likely a new qdisc
written from scratch would be needed to implement a mq-htb or
mq-tbf qdisc. It seems to me that one reasonably approach to do
this would be to use eventually consistent counters and accept
some imperfect rate limiting scheme.

As for some history I wrote what was basically these patches some
time ago and then got stalled working on other things. Cong Wang
made a proposal to remove the locking around the ingress qdisc
which then kicked me to get these patches working again. Some
time passed and am now submitting the patches.

I have done some basic testing on this series and do not see any
immediate splats or issues. The patch series has been running
on my dev systems for a month or so now and I've not seen any
issues. Although my configurations are not overly complicated.

My test cases at this point cover all the filters with a
tight loop to add/remove filters. Some basic estimator tests
where I add an estimator to the qdisc and verify the statistics
accurate using pktgen. And finally I have a small script to
exercise the 'tc actions' interface. Feel free to send me more
tests off list and I can run them.

Comments:
  - Checkpatch is still giving errors on some >80 char lines I know
    about this. IMO the way to fix this is to restructure the sched
    code to avoid being so heavily indented. But doing this here
    bloats the patchset and anyways there are already lots of >80
    chars in these files. I would prefer to keep the patches as is
    but let me know if others think I should fix these and I will.
    A follow up patch set could restructure the code and fix this
    throughout the code blocks.

 - Sparse is still throwing some warnings. I don't think they are
   harmful. I'm still working out the best way to fix these and
   might submit follow up patches for this.

   There is a sparse error in the return values for tcf_chain.

net/sched/cls_api.c:194:15: warning: incorrect type in assignment (different address spaces)
net/sched/cls_api.c:194:15:    expected struct tcf_proto [noderef] <asn:4>**chain
net/sched/cls_api.c:194:15:    got struct tcf_proto **

   Have a look at any of the cls_*.c tcf_chain functions and without
   creating really ugly code I've yet found a good way to fix this
   warning. Although because this is inside rtnl again I see no real
   issue. I've left it for now because I would rather have readable
   code and a sparse warning then ugly code and no sparse errors. I'm
   hoping someone knows how to resolve it for me.

  The use of cpu_{b|q}stats in the gnet calls also results in sparse
  warnings.

net/sched/sch_api.c:1048:56: warning: incorrect type in argument 2 (different address spaces)
net/sched/sch_api.c:1048:56:    expected struct gnet_stats_basic_cpu *cpu_bstats
net/sched/sch_api.c:1048:56:    got struct gnet_stats_basic_cpu [noderef] <asn:3>*cpu_bstats

Future work:
  - provide metadata such as current cpu for the classifier
    to match on. this would allow for a multiqueue ingress
    qdisc strategy.
  - provide filter hook on egress before queue is selected
    to allow a classifier/action to pick the tx queue. This
    generalizes mqprio and should remove the need for many
    drivers to implement select_queue() callbacks. I have
    a patch for this now but its not entirely clear to me
    its all that useful considering mqprio already allows
    queueing by skb->priority. I also have a patch to do
    hardware based queue rate limiting with this patch the
    egress filter is more interesting.
  - create a variant of tbf that does not require the qdisc
    lock using eventually consistent counters.
  - a lockless fifo ring may provide some wins for some use
    cases.

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
      net: sched: rcu'ify cls_bpf
      net: sched: make tc_action safe to walk under RCU
      net: sched: make bstats per cpu and estimator RCU safe
      net: sched: make qstats per cpu
      net: sched: drop ingress qdisc lock


 include/linux/netdevice.h  |   29 +----
 include/linux/rtnetlink.h  |   10 ++
 include/net/act_api.h      |    1 
 include/net/codel.h        |    4 -
 include/net/gen_stats.h    |   17 +++
 include/net/pkt_cls.h      |   10 ++
 include/net/sch_generic.h  |   93 +++++++++++++---
 net/core/dev.c             |   53 ++++++++-
 net/core/gen_estimator.c   |   60 ++++++++--
 net/core/gen_stats.c       |   76 +++++++++++++
 net/netfilter/xt_RATEEST.c |    4 -
 net/sched/act_api.c        |   23 ++--
 net/sched/act_police.c     |    4 -
 net/sched/cls_api.c        |   47 ++++----
 net/sched/cls_basic.c      |   80 ++++++++------
 net/sched/cls_bpf.c        |   93 ++++++++--------
 net/sched/cls_cgroup.c     |   63 +++++++----
 net/sched/cls_flow.c       |  145 ++++++++++++++-----------
 net/sched/cls_fw.c         |  111 +++++++++++++------
 net/sched/cls_route.c      |  224 ++++++++++++++++++++++----------------
 net/sched/cls_rsvp.h       |  155 +++++++++++++++-----------
 net/sched/cls_tcindex.c    |  246 ++++++++++++++++++++++++++----------------
 net/sched/cls_u32.c        |  258 +++++++++++++++++++++++++++++---------------
 net/sched/sch_api.c        |   79 +++++++++++--
 net/sched/sch_atm.c        |   32 +++--
 net/sched/sch_cbq.c        |   40 ++++---
 net/sched/sch_choke.c      |   33 ++++--
 net/sched/sch_codel.c      |    2 
 net/sched/sch_drr.c        |   27 +++--
 net/sched/sch_dsmark.c     |   10 +-
 net/sched/sch_fifo.c       |    6 +
 net/sched/sch_fq.c         |    4 -
 net/sched/sch_fq_codel.c   |   19 ++-
 net/sched/sch_generic.c    |   22 +++-
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
 net/sched/sch_teql.c       |   13 +-
 52 files changed, 1588 insertions(+), 897 deletions(-)

-- 
Signature
