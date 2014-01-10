From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 00/12] RCU'ify the net:sched classifier chains
Date: Fri, 10 Jan 2014 01:36:39 -0800
Message-ID: <20140110092041.7193.5952.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:55374 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbaAJJhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 04:37:01 -0500
Received: by mail-ob0-f181.google.com with SMTP id uy5so4586566obc.12
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 01:37:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There appears to be some interest in a few topics around the qdisc
layer which could benefit from having the ability to run the
filters and actions without holding the qdisc lock.

Recently Cong Wang proposed a patch series to drop the ingress
qdisc and asked for comments. This series I think gets closer to
that goal.

The ingress qdisc is a simple qdisc which doesn't maintain any
actual list of skb's and is primarily a hook to attach filters.
Further the only qdisc that can be attached to the ingress qdisc
is sch_ingress. The qdisc lock is currently serializing two
operations (1) tc_classify which is addressed here and (2)
statistics accounting. The second point is not solved here but
it could be a matter of making the bstats and qstats per cpu
stats.

This is an RFC for now and needs some more work. Some items
I know about are (a) an audit of the ematch code paths, (b) resolving
the checpatch errors mostly due to moving code around that
generates those errors, (c) run smatch, (d) audit u32 code
for correctness, (e) do a lot more testing so far only very
basic testing has been done. I tried to put some reasonable
comments in the commit logs but yes they need more work.

Cong, if its not too much to ask can we use this as a base
set of patches for this work? I think its reasonably close to
correct as is.

Thanks! John.

---

John Fastabend (12):
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


 include/linux/netdevice.h |   41 +-----
 include/linux/rtnetlink.h |   10 +
 include/net/act_api.h     |    1 
 include/net/pkt_cls.h     |   12 +-
 include/net/sch_generic.h |   34 ++++-
 net/core/dev.c            |   54 +++++++
 net/sched/act_api.c       |   18 +-
 net/sched/cls_api.c       |   44 +++---
 net/sched/cls_basic.c     |   82 ++++++-----
 net/sched/cls_bpf.c       |   79 ++++++-----
 net/sched/cls_cgroup.c    |   65 ++++++---
 net/sched/cls_flow.c      |  145 ++++++++++++--------
 net/sched/cls_fw.c        |  112 +++++++++++----
 net/sched/cls_route.c     |  218 +++++++++++++++++-------------
 net/sched/cls_rsvp.h      |  152 ++++++++++++---------
 net/sched/cls_tcindex.c   |  327 ++++++++++++++++++++++++++-------------------
 net/sched/cls_u32.c       |  258 +++++++++++++++++++++++-------------
 net/sched/sch_api.c       |    6 -
 net/sched/sch_atm.c       |   30 +++-
 net/sched/sch_cbq.c       |   21 ++-
 net/sched/sch_choke.c     |   18 ++
 net/sched/sch_drr.c       |   10 +
 net/sched/sch_dsmark.c    |    8 +
 net/sched/sch_fq_codel.c  |   11 +-
 net/sched/sch_generic.c   |    4 -
 net/sched/sch_hfsc.c      |   17 ++
 net/sched/sch_htb.c       |   23 ++-
 net/sched/sch_ingress.c   |    8 +
 net/sched/sch_mqprio.c    |    4 -
 net/sched/sch_multiq.c    |    8 +
 net/sched/sch_prio.c      |   11 +-
 net/sched/sch_qfq.c       |    9 +
 net/sched/sch_sfb.c       |   15 +-
 net/sched/sch_sfq.c       |   11 +-
 net/sched/sch_teql.c      |    9 +
 35 files changed, 1139 insertions(+), 736 deletions(-)

-- 
Signature
