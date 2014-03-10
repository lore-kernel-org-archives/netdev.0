From: John Fastabend <john.fastabend@gmail.com>
Subject: [RCU PATCH 00/14] Remove qdisc lock around ingress Qdisc
Date: Mon, 10 Mar 2014 10:03:22 -0700
Message-ID: <20140310170008.3011.73599.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:43308 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847AbaCJRDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:03:40 -0400
Received: by mail-ob0-f169.google.com with SMTP id va2so7260060obc.0
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 10:03:39 -0700 (PDT)
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

In order to have working statistics patch 13 converts the bstats,
which do accounting for bytes and packets, into percpu variables
and the u64_stats_update_{begin|end} infrastructure is used to
maintain consistent statistics. Because these statistics are also
used by the estimators those function calls had to be udpated as
well. So that I didn't have to modify all qdiscs at this time many
of which don't have an easy path to make lockless the percpu
statistics are only used when the TCQ_F_LLQDISC flag is set. Its
worth noting that in the mq and mqprio case sub-qdisc's are already
mapped 1:1 with TX queues which tend to be equal to the number
of CPUs in the system so its not clear that removing locking in
these cases would provide any benefit. Most likely a new qdisc
written from scratch would be needed to implement a mq-htb or
mq-tbf qdisc.

As for some history I wrote what was basically these patches some
time ago and then got stalled working on other things. Cong Wang
made a proposal to remove the locking around the ingress qdisc
which then kicked me to get these patches working again.

I have started to test this series and do no see any immediate
splats or issues. I will continue doing some more testing for the
rest of the week before submitting without the RCU tag but any
feedback would be good. If someone has a better idea for the
percpu union of gnet_stats_basic_* in struct Qdisc or finds it
paticularly ugly that would be good to know.

The estimators also use pointer values to lookup the estimator
entry. Now that the pointer can be either a percpu bstat or
a single bstat entry I pushed the pointer type to void which
creates these warnings,

net/core/gen_estimator.c: In function =E2=80=98gen_get_bstats=E2=80=99:
net/core/gen_estimator.c:163:43: warning: pointer type mismatch in cond=
itional expression [enabled by default]
net/core/gen_estimator.c: In function =E2=80=98gen_find_node=E2=80=99:
net/core/gen_estimator.c:191:28: warning: pointer type mismatch in cond=
itional expression [enabled by default]

I'm looking for some way to resolve this now.

My test cases at this point cover all the filters with a
tight loop to add/remove an entry. Some basic estimator tests
where I add an estimator to the qdisc and verify the statistics
are accurate using pktgen. And finally I have a small script to
exercise the 'tc actions' interface. Feel free to send me more
tests off list and I can run them.

TODO:
  - fix up checkpatch warnings

=46uture work:
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

John Fastabend (14):
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
      net: sched: drop ingress qdisc lock


 include/linux/netdevice.h  |   41 +------
 include/linux/rtnetlink.h  |   10 ++
 include/net/act_api.h      |    1=20
 include/net/gen_stats.h    |   16 +++
 include/net/pkt_cls.h      |   12 ++
 include/net/sch_generic.h  |   74 +++++++++++--
 net/core/dev.c             |   56 +++++++++-
 net/core/gen_estimator.c   |   62 ++++++++---
 net/core/gen_stats.c       |   41 +++++++
 net/netfilter/xt_RATEEST.c |    4 -
 net/sched/act_api.c        |   22 ++--
 net/sched/act_police.c     |    4 -
 net/sched/cls_api.c        |   44 ++++----
 net/sched/cls_basic.c      |   80 ++++++++------
 net/sched/cls_bpf.c        |   79 +++++++-------
 net/sched/cls_cgroup.c     |   65 +++++++----
 net/sched/cls_flow.c       |  145 ++++++++++++++-----------
 net/sched/cls_fw.c         |  110 +++++++++++++------
 net/sched/cls_route.c      |  217 +++++++++++++++++++++---------------=
-
 net/sched/cls_rsvp.h       |  152 +++++++++++++++-----------
 net/sched/cls_tcindex.c    |  240 ++++++++++++++++++++++++++----------=
-----
 net/sched/cls_u32.c        |  257 +++++++++++++++++++++++++++++-------=
--------
 net/sched/sch_api.c        |   57 ++++++++--
 net/sched/sch_atm.c        |   30 +++--
 net/sched/sch_cbq.c        |   29 +++--
 net/sched/sch_choke.c      |   18 ++-
 net/sched/sch_drr.c        |   18 ++-
 net/sched/sch_dsmark.c     |    8 +
 net/sched/sch_fq_codel.c   |   11 +-
 net/sched/sch_generic.c    |   16 ++-
 net/sched/sch_hfsc.c       |   30 +++--
 net/sched/sch_htb.c        |   33 +++---
 net/sched/sch_ingress.c    |   16 ++-
 net/sched/sch_mq.c         |    8 +
 net/sched/sch_mqprio.c     |   16 +--
 net/sched/sch_multiq.c     |   10 +-
 net/sched/sch_prio.c       |   13 +-
 net/sched/sch_qfq.c        |   21 ++--
 net/sched/sch_sfb.c        |   15 ++-
 net/sched/sch_sfq.c        |   11 +-
 net/sched/sch_teql.c       |    9 +-
 41 files changed, 1337 insertions(+), 764 deletions(-)

--=20
Signature

---

John Fastabend (14):
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
      net: sched: drop ingress qdisc lock


 include/linux/netdevice.h  |   41 +------
 include/linux/rtnetlink.h  |   10 ++
 include/net/act_api.h      |    1=20
 include/net/gen_stats.h    |   16 +++
 include/net/pkt_cls.h      |   12 ++
 include/net/sch_generic.h  |   74 +++++++++++--
 net/core/dev.c             |   56 +++++++++-
 net/core/gen_estimator.c   |   62 ++++++++---
 net/core/gen_stats.c       |   41 +++++++
 net/netfilter/xt_RATEEST.c |    4 -
 net/sched/act_api.c        |   22 ++--
 net/sched/act_police.c     |    4 -
 net/sched/cls_api.c        |   44 ++++----
 net/sched/cls_basic.c      |   80 ++++++++------
 net/sched/cls_bpf.c        |   79 +++++++-------
 net/sched/cls_cgroup.c     |   65 +++++++----
 net/sched/cls_flow.c       |  145 ++++++++++++++-----------
 net/sched/cls_fw.c         |  110 +++++++++++++------
 net/sched/cls_route.c      |  217 +++++++++++++++++++++---------------=
-
 net/sched/cls_rsvp.h       |  152 +++++++++++++++-----------
 net/sched/cls_tcindex.c    |  240 ++++++++++++++++++++++++++----------=
-----
 net/sched/cls_u32.c        |  257 +++++++++++++++++++++++++++++-------=
--------
 net/sched/sch_api.c        |   57 ++++++++--
 net/sched/sch_atm.c        |   30 +++--
 net/sched/sch_cbq.c        |   29 +++--
 net/sched/sch_choke.c      |   18 ++-
 net/sched/sch_drr.c        |   18 ++-
 net/sched/sch_dsmark.c     |    8 +
 net/sched/sch_fq_codel.c   |   11 +-
 net/sched/sch_generic.c    |   16 ++-
 net/sched/sch_hfsc.c       |   30 +++--
 net/sched/sch_htb.c        |   33 +++---
 net/sched/sch_ingress.c    |   16 ++-
 net/sched/sch_mq.c         |    8 +
 net/sched/sch_mqprio.c     |   16 +--
 net/sched/sch_multiq.c     |   10 +-
 net/sched/sch_prio.c       |   13 +-
 net/sched/sch_qfq.c        |   21 ++--
 net/sched/sch_sfb.c        |   15 ++-
 net/sched/sch_sfq.c        |   11 +-
 net/sched/sch_teql.c       |    9 +-
 41 files changed, 1337 insertions(+), 764 deletions(-)

--=20
Signature
