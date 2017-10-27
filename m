From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 00/16] net_sched: fix races with RCU callbacks
Date: Thu, 26 Oct 2017 18:24:27 -0700
Message-ID: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
Cc: Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:46864 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751932AbdJ0BY6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:24:58 -0400
Received: by mail-pf0-f193.google.com with SMTP id p87so3778772pfj.3
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:24:57 -0700 (PDT)
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
these contribute to the cause of these nasty bugs.

Alternatively, we could also:

a) Introduce a spinlock to serialize these RCU callbacks. But as I
said in commit 1697c4bb5245 ("net_sched: carefully handle
tcf_block_put()"), it is very hard to do because of tcf_chain_dump().
Potentially we need to do a lot of work to make it possible (if not
impossible).

b) Just get rid of these RCU callbacks, because they are not
necessary at all, callers of these call_rcu() are all on slow paths
and holding RTNL lock, so blocking is allowed in their contexts.
However, David and Eric dislike adding synchronize_rcu() here.

As suggested by Paul, we could defer the work to a workqueue and
gain the permission of holding RTNL again without any performance
impact, however, in tcf_block_put() we could have a deadlock when
flushing workqueue while hodling RTNL lock, the trick here is to
defer the work itself in workqueue and make it queued after all
other works so that we keep the same ordering to avoid any
use-after-free. Please see the first patch for details.

Patch 1 introduces the infrastructure, patch 2~12 move each
tc filter to the new tc filter workqueue, patch 13 adds
an assertion to catch potential bugs like this, patch 14
closes another rcu callback race, patch 15 and patch 16 add
new test cases.

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Chris Mi (2):
  selftests: Introduce a new script to generate tc batch file
  selftests: Introduce a new test case to tc testsuite

Cong Wang (14):
  net_sched: introduce a workqueue for RCU callbacks of tc filter
  net_sched: use tcf_queue_work() in basic filter
  net_sched: use tcf_queue_work() in bpf filter
  net_sched: use tcf_queue_work() in cgroup filter
  net_sched: use tcf_queue_work() in flow filter
  net_sched: use tcf_queue_work() in flower filter
  net_sched: use tcf_queue_work() in fw filter
  net_sched: use tcf_queue_work() in matchall filter
  net_sched: use tcf_queue_work() in u32 filter
  net_sched: use tcf_queue_work() in route filter
  net_sched: use tcf_queue_work() in rsvp filter
  net_sched: use tcf_queue_work() in tcindex filter
  net_sched: add rtnl assertion to tcf_exts_destroy()
  net_sched: fix call_rcu() race on act_sample module removal

 include/net/pkt_cls.h                              |  3 +
 include/net/sch_generic.h                          |  2 +
 net/sched/act_sample.c                             |  1 +
 net/sched/cls_api.c                                | 69 ++++++++++++++++------
 net/sched/cls_basic.c                              | 20 ++++++-
 net/sched/cls_bpf.c                                | 19 +++++-
 net/sched/cls_cgroup.c                             | 22 +++++--
 net/sched/cls_flow.c                               | 19 +++++-
 net/sched/cls_flower.c                             | 19 +++++-
 net/sched/cls_fw.c                                 | 19 +++++-
 net/sched/cls_matchall.c                           | 19 +++++-
 net/sched/cls_route.c                              | 19 +++++-
 net/sched/cls_rsvp.h                               | 19 +++++-
 net/sched/cls_tcindex.c                            | 38 ++++++++++--
 net/sched/cls_u32.c                                | 29 ++++++++-
 .../tc-testing/tc-tests/filters/tests.json         | 23 +++++++-
 tools/testing/selftests/tc-testing/tdc.py          | 20 +++++--
 tools/testing/selftests/tc-testing/tdc_batch.py    | 62 +++++++++++++++++++
 tools/testing/selftests/tc-testing/tdc_config.py   |  2 +
 19 files changed, 367 insertions(+), 57 deletions(-)
 create mode 100755 tools/testing/selftests/tc-testing/tdc_batch.py

-- 
2.13.0
