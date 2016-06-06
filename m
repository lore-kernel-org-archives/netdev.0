From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] net: sched: faster stats gathering
Date: Mon,  6 Jun 2016 09:37:14 -0700
Message-ID: <1465231036-10674-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33863 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752410AbcFFQhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 12:37:20 -0400
Received: by mail-pf0-f175.google.com with SMTP id 62so68444786pfd.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 09:37:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A while back, I sent one RFC patch using lockless stats gathering
on 64bit arches.

This patch series does it more cleanly, using a seqcount.

Since qdisc/class stats are written at dequeue() time,
we can ask the dequeue to change the seqcount, so that
stats readers can avoid taking the root qdisc lock,
and instead the typical read_seqcount_{begin|retry} guarded
loop.

This does not change fast path costs, as the seqcount
increments are not more expensive than the bit manipulation,
and allows readers to not freeze the fast path anymore.

Eric Dumazet (2):
  net_sched: transform qdisc running bit into a seqcount
  net: sched: do not acquire qdisc spinlock in qdisc/class stats dump

 Documentation/networking/gen_stats.txt |  2 +-
 drivers/net/bonding/bond_main.c        |  2 ++
 drivers/net/ppp/ppp_generic.c          |  3 +++
 drivers/net/team/team.c                |  2 ++
 include/linux/netdevice.h              |  1 +
 include/net/gen_stats.h                | 12 ++++++++----
 include/net/sch_generic.h              | 23 ++++++++++++-----------
 net/bluetooth/6lowpan.c                |  2 ++
 net/core/dev.c                         |  2 +-
 net/core/gen_estimator.c               | 24 ++++++++++++++++--------
 net/core/gen_stats.c                   | 34 +++++++++++++++++++++++-----------
 net/ieee802154/6lowpan/core.c          |  3 +++
 net/l2tp/l2tp_eth.c                    |  4 ++++
 net/netfilter/xt_RATEEST.c             |  2 +-
 net/sched/act_api.c                    |  4 ++--
 net/sched/act_police.c                 |  3 ++-
 net/sched/sch_api.c                    | 21 +++++++++++----------
 net/sched/sch_atm.c                    |  3 ++-
 net/sched/sch_cbq.c                    |  9 ++++++---
 net/sched/sch_drr.c                    |  9 ++++++---
 net/sched/sch_fq_codel.c               | 15 +++++++++++----
 net/sched/sch_generic.c                | 14 ++++++++++----
 net/sched/sch_hfsc.c                   | 10 +++++-----
 net/sched/sch_htb.c                    | 11 ++++++-----
 net/sched/sch_mq.c                     |  2 +-
 net/sched/sch_mqprio.c                 | 11 +++++++----
 net/sched/sch_multiq.c                 |  3 ++-
 net/sched/sch_prio.c                   |  3 ++-
 net/sched/sch_qfq.c                    |  9 ++++++---
 29 files changed, 158 insertions(+), 85 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
