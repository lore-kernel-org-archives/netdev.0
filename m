From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/4] net_sched: bulk dequeue and deferred drops
Date: Tue, 21 Jun 2016 23:16:48 -0700
Message-ID: <1466576212-15012-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34930 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbcFVGlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 02:41:18 -0400
Received: by mail-pf0-f181.google.com with SMTP id c2so14646562pfa.2
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 23:40:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch adds an additional parameter to ->enqueue() qdisc method
so that drops can be done outside of critical section
(after locks are released).

Then fq_codel can have a small optimization to reduce number of cache
lines misses during a drop event
(possibly accumulating hundreds of packets to be freed).

A small htb change exports the backlog in class dumps.

Final patch adds bulk dequeue to qdiscs that were lacking this feature.

This series brings a nice qdisc performance increase (more than 80 %
in some cases).

Eric Dumazet (4):
  net_sched: drop packets after root qdisc lock is released
  net_sched: fq_codel: cache skb->truesize into skb->cb
  net_sched: sch_htb: export class backlog in dumps
  net_sched: generalize bulk dequeue

 include/net/codel_qdisc.h |  1 +
 include/net/sch_generic.h | 48 ++++++++++++++++++++---------
 net/core/dev.c            |  7 +++--
 net/sched/sch_atm.c       |  9 +++---
 net/sched/sch_blackhole.c |  5 +--
 net/sched/sch_cbq.c       |  7 +++--
 net/sched/sch_choke.c     | 16 +++++-----
 net/sched/sch_codel.c     |  8 +++--
 net/sched/sch_drr.c       |  7 +++--
 net/sched/sch_dsmark.c    |  9 +++---
 net/sched/sch_fifo.c      | 15 +++++----
 net/sched/sch_fq.c        |  7 +++--
 net/sched/sch_fq_codel.c  | 22 +++++++------
 net/sched/sch_generic.c   | 78 ++++++++++++++++++++++++++++++++++++++---------
 net/sched/sch_gred.c      |  7 +++--
 net/sched/sch_hfsc.c      |  6 ++--
 net/sched/sch_hhf.c       | 10 +++---
 net/sched/sch_htb.c       | 24 ++++++++++-----
 net/sched/sch_multiq.c    |  7 +++--
 net/sched/sch_netem.c     | 25 +++++++++------
 net/sched/sch_pie.c       |  5 +--
 net/sched/sch_plug.c      |  5 +--
 net/sched/sch_prio.c      |  4 +--
 net/sched/sch_qfq.c       |  7 +++--
 net/sched/sch_red.c       |  7 +++--
 net/sched/sch_sfb.c       |  7 +++--
 net/sched/sch_sfq.c       |  8 ++---
 net/sched/sch_tbf.c       | 16 +++++-----
 net/sched/sch_teql.c      |  4 +--
 29 files changed, 247 insertions(+), 134 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
