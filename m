From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 00/12] net/sched rcu classifiers and tcf
Date: Fri, 12 Sep 2014 20:04:20 -0700
Message-ID: <20140913025925.6249.12537.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:36583 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbaIMDEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 23:04:45 -0400
Received: by mail-ob0-f170.google.com with SMTP id uy5so1083096obc.15
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 20:04:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series converts the tcf_proto usage to RCU. 

This requires updating each classifier individually to handle the
new copy/update requirement and also to update the core list
traversals. This makes the assumption that updates to the tables
are infrequent in comparison to the packet per second being
classified. On a 10Gbps running near line rate we can easily
produce 12+ million packets per second so IMO this is a reasonable
assumption. The updates are serialized by RTNL.

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

This is prep work to drop the qdisc lock with the first
target being the ingress qdisc. To be done is making the
tc actions RCU safe and statistics per cpu. These patches
are in the works.

Comments:
  - Checkpatch is still giving errors on some >80 char lines I know
    about this. IMO the way to fix this is to restructure the sched
    code to avoid being so heavily indented. But doing this here
    bloats the patchset and anyways there are already lots of >80
    chars in these files. I would prefer to keep the patches as is
    but let me know if others think I should fix these and I will.
    A follow up patch set could restructure the code and fix this
    throughout the code blocks.

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
      net: sched: make cls_u32 per cpu
      net: sched: make cls_u32 lockless
      net: sched: rcu'ify cls_rsvp
      net: sched: rcu'ify cls_bpf


 include/linux/netdevice.h |   29 +----
 include/linux/rtnetlink.h |   10 ++
 include/net/sch_generic.h |   30 +++--
 net/core/dev.c            |   51 +++++++++
 net/sched/cls_api.c       |   30 +++--
 net/sched/cls_basic.c     |   80 ++++++++------
 net/sched/cls_bpf.c       |   94 ++++++++--------
 net/sched/cls_cgroup.c    |   63 +++++++----
 net/sched/cls_flow.c      |  145 +++++++++++++++----------
 net/sched/cls_fw.c        |  111 +++++++++++++------
 net/sched/cls_route.c     |  226 +++++++++++++++++++++++----------------
 net/sched/cls_rsvp.h      |  160 ++++++++++++++++------------
 net/sched/cls_tcindex.c   |  248 +++++++++++++++++++++++++++----------------
 net/sched/cls_u32.c       |  258 +++++++++++++++++++++++++++++----------------
 net/sched/sch_api.c       |   10 +-
 net/sched/sch_atm.c       |   20 ++-
 net/sched/sch_cbq.c       |   11 +-
 net/sched/sch_choke.c     |   15 ++-
 net/sched/sch_drr.c       |    9 +-
 net/sched/sch_dsmark.c    |    9 +-
 net/sched/sch_fq_codel.c  |   11 +-
 net/sched/sch_generic.c   |    4 -
 net/sched/sch_hfsc.c      |    8 +
 net/sched/sch_htb.c       |   15 +--
 net/sched/sch_ingress.c   |    8 +
 net/sched/sch_mqprio.c    |    6 +
 net/sched/sch_multiq.c    |    8 +
 net/sched/sch_prio.c      |   11 +-
 net/sched/sch_qfq.c       |    9 +-
 net/sched/sch_sfb.c       |   15 ++-
 net/sched/sch_sfq.c       |   11 +-
 net/sched/sch_teql.c      |   13 +-
 32 files changed, 1050 insertions(+), 678 deletions(-)

-- 
Signature
