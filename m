From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 00/10] net_sched: defer skb freeing while changing qdiscs
Date: Mon, 13 Jun 2016 20:21:49 -0700
Message-ID: <1465874519-25494-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36001 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423239AbcFNDWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 23:22:19 -0400
Received: by mail-pf0-f172.google.com with SMTP id t190so52470825pfb.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 20:22:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qdiscs/classes are changed under RTNL protection and often
while blocking BH and root qdisc spinlock.

When lots of skbs need to be dropped, we free
them under these locks causing TX/RX freezes,
and more generally latency spikes.

I saw spikes of 50+ ms on quite fast hardware...

This patch series adds a simple queue protected by RTNL
where skbs can be placed until RTNL is released.

Note that this might also serve in the future for optional
reinjection of packets when a qdisc is replaced.

Eric Dumazet (10):
  net_sched: add the ability to defer skb freeing
  net_sched: sch_choke: defer skb freeing
  net_sched: sch_codel: defer skb freeing in codel_change()
  net_sched: sch_fq: defer skb freeing
  net_sched: fq_codel: defer skb freeing
  net_sched: sch_hhf: defer skb freeing
  net_sched: sch_htb: defer skb freeing
  net_sched: sch_netem: defer skb freeing
  net_sched: sch_pie: defer skb freeing
  net_sched: sch_fq: defer skb freeing

 include/linux/rtnetlink.h |  5 +++--
 include/net/sch_generic.h | 16 ++++++++++++----
 net/core/rtnetlink.c      | 22 ++++++++++++++++++++++
 net/sched/sch_choke.c     |  8 ++++----
 net/sched/sch_codel.c     |  2 +-
 net/sched/sch_fq.c        | 19 +++++++++++++------
 net/sched/sch_fq_codel.c  | 17 +++++++++--------
 net/sched/sch_generic.c   |  2 +-
 net/sched/sch_hhf.c       |  4 ++--
 net/sched/sch_htb.c       |  4 ++--
 net/sched/sch_netem.c     |  4 +---
 net/sched/sch_pie.c       |  2 +-
 net/sched/sch_sfq.c       |  2 +-
 13 files changed, 72 insertions(+), 35 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
