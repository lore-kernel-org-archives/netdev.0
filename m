From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 00/15] net_sched: remove RCU callbacks from TC
Date: Mon, 23 Oct 2017 15:02:49 -0700
Message-ID: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:54736 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751113AbdJWWDc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:32 -0400
Received: by mail-pf0-f194.google.com with SMTP id n89so18090687pfk.11
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently, the RCU callbacks used in TC filters and TC actions keep
drawing my attention, they introduce at least 4 race condition bugs:

1. A simple one fixed by Daniel:

commit c78e1746d3ad7d548bdf3fe491898cc453911a49
Author: Daniel Borkmann <daniel@iogearbox.net>
Date:   Wed May 20 17:13:33 2015 +0200

    net: sched: fix call_rcu() race on classifier module unloads

2. A very nasty one fixed by me:

commit 1697c4bb5245649a23f06a144cc38c06715e1b65
Author: Cong Wang <xiyou.wangcong@gmail.com>
Date:   Mon Sep 11 16:33:32 2017 -0700

    net_sched: carefully handle tcf_block_put()

3. Two more bugs found by Chris:
https://patchwork.ozlabs.org/patch/826696/
https://patchwork.ozlabs.org/patch/826695/

Usually RCU callbacks are simple, however for TC filters and actions,
they are complex because at least TC actions could be destroyed
together with the TC filter in one callback. And RCU callbacks are
invoked in BH context, without locking they are parallel too. All of
these contribute to the cause of these nasty bugs. It looks like they
bring us more troubles than benefits.

Alternatively, we could also:

a) Introduce a spinlock to serialize these RCU callbacks. But as I
said in commit 1697c4bb5245 ("net_sched: carefully handle
tcf_block_put()"), it is very hard to do because of tcf_chain_dump().
Potentially we need to do a lot of work to make it possible, if not
impossible.

b) As suggested by Paul, we could defer the work to a workqueue and
gain the permission of holding RTNL again without any performance
impact, however, this seems impossible too, because as lockdep
complains we have a deadlock when flushing workqueue while hodling
RTNL lock, see the rcu_barrier() in tcf_block_put().

Therefore, the simplest solution we have is probably just getting
rid of these RCU callbacks, because they are not necessary at all,
callers of these call_rcu() are all on slow paths and have RTNL
lock, so blocking is allowed in their contexts.

The downside is this could hurt the performance of deleting TC
filters, but again it is not a hot path and I already batch
synchronize_rcu() whenever needed.

Different filters have different data structures, so please also
see each patch for details.

Chris Mi (2):
  selftests: Introduce a new script to generate tc batch file
  selftests: Introduce a new test case to tc testsuite

Cong Wang (13):
  net_sched: remove RCU callbacks in basic filter
  net_sched: remove RCU callbacks in bpf filter
  net_sched: remove RCU callbacks in flower filter
  net_sched: remove RCU callbacks in matchall filter
  net_sched: remove RCU callbacks in cgroup filter
  net_sched: remove RCU callbacks in rsvp filter
  net_sched: remove RCU callbacks in flow filter
  net_sched: remove RCU callbacks in tcindex filter
  net_sched: remove RCU callbacks in u32 filter
  net_sched: remove RCU callbacks in fw filter
  net_sched: remove RCU callbacks in route filter
  net_sched: remove RCU callbacks in sample action
  net_sched: add rtnl assertion to tcf_exts_destroy()

 include/net/tc_act/tc_sample.h                     |  1 -
 net/sched/act_sample.c                             | 12 +---
 net/sched/cls_api.c                                |  1 +
 net/sched/cls_basic.c                              | 23 ++++----
 net/sched/cls_bpf.c                                | 22 ++++----
 net/sched/cls_cgroup.c                             | 18 +++---
 net/sched/cls_flow.c                               | 24 ++++----
 net/sched/cls_flower.c                             | 46 +++++-----------
 net/sched/cls_fw.c                                 | 18 +++---
 net/sched/cls_matchall.c                           |  9 +--
 net/sched/cls_route.c                              | 21 +++----
 net/sched/cls_rsvp.h                               | 13 +----
 net/sched/cls_tcindex.c                            | 35 +++++-------
 net/sched/cls_u32.c                                | 64 ++++++----------------
 .../tc-testing/tc-tests/filters/tests.json         | 23 +++++++-
 tools/testing/selftests/tc-testing/tdc.py          | 20 +++++--
 tools/testing/selftests/tc-testing/tdc_batch.py    | 62 +++++++++++++++++++++
 tools/testing/selftests/tc-testing/tdc_config.py   |  2 +
 18 files changed, 222 insertions(+), 192 deletions(-)
 create mode 100644 tools/testing/selftests/tc-testing/tdc_batch.py

-- 
2.13.0
