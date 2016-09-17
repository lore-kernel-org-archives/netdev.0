From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/5] sched: convert queues to single-linked list
Date: Sun, 18 Sep 2016 00:57:29 +0200
Message-ID: <1474153054-9059-1-git-send-email-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51380 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754719AbcIQW5Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 18:57:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During Netfilter Workshop 2016 Eric Dumazet pointed out that qdisc
schedulers use doubly-linked lists, even though single-linked list
would be enough.

The double-linked skb lists incur one extra write on enqueue/dequeue
operations (to change ->prev pointer of next list elem).

This series converts qdiscs to single-linked version, listhead
maintains pointers to first (for dequeue) and last skb (for enqueue).

Most qdiscs don't queue at all and instead use a leaf qdisc (typically
pfifo_fast) so only a few schedulers needed changes.

I briefly tested netem and htb and they seemed fine.

UDP_STREAM netperf with 64 byte packets via veth+pfifo_fast shows
a small (~2%) improvement.

Florian Westphal (5):
      pie: use qdisc_dequeue_head wrapper
      sched: don't use skb queue helpers
      sched: remove qdisc arg from __qdisc_dequeue_head
      sched: replace __skb_dequeue with __qdisc_dequeue_head
      sched: add and use qdisc_skb_head helpers

 include/net/sch_generic.h |   72 +++++++++++++++++++++++++++++++++++-----------
 net/sched/sch_codel.c     |    4 +-
 net/sched/sch_fifo.c      |    4 +-
 net/sched/sch_generic.c   |   30 +++++++++++--------
 net/sched/sch_htb.c       |   24 ++++++++++++---
 net/sched/sch_netem.c     |   20 +++++++++---
 net/sched/sch_pie.c       |    4 +-
 7 files changed, 115 insertions(+), 43 deletions(-)
