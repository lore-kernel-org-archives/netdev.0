From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFC Patch net-next 0/4] net_sched: make ingress filters lockless
Date: Thu,  9 Jan 2014 10:19:49 -0800
Message-ID: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:60579 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbaAISUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 13:20:09 -0500
Received: by mail-pa0-f48.google.com with SMTP id lf10so1326324pab.35
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 10:20:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch tries to switch filter list to using struct
list_head, so that on the read side, the list can be traversed
with RCU read lock. Same for actions.

I hope either on egress or ingress classify is already protected by RCU
read lock, but I don't pretend I fully understanding qdisc locking.

Also, I am not sure I use RCU API's correctly at all. At least
I don't see any warning with CONFIG_PROVE_RCU=y.

Without this patch, the spin_lock easily appears on the top of
my perf top with 4 netperf sessions (4 is the number of CPU)
and with 1000 u32 filters on ingress.

Question 1:
Am I still missing something on qdisc locking?

Question 2:
Is it okay to call qdisc_bstats_update() without any lock?

Please comment.

Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Cong Wang (4):
  net_sched: switch filter list to list_head
  net_sched: avoid holding qdisc lock for filters
  net_sched: use RCU for tc actions traverse
  net_sched: make ingress qdisc lockless

 include/net/pkt_cls.h     | 25 ++++--------------------
 include/net/pkt_sched.h   |  4 ++--
 include/net/sch_generic.h | 14 +++++++++-----
 net/core/dev.c            |  2 --
 net/sched/act_api.c       | 12 +++++++-----
 net/sched/cls_api.c       | 48 ++++++++++++++++++++++++++++-------------------
 net/sched/sch_api.c       | 35 +++++++++++++++++++++-------------
 net/sched/sch_atm.c       | 14 +++++++-------
 net/sched/sch_cbq.c       |  9 +++++----
 net/sched/sch_choke.c     | 11 ++++++-----
 net/sched/sch_drr.c       |  7 ++++---
 net/sched/sch_dsmark.c    |  7 ++++---
 net/sched/sch_fq_codel.c  |  9 +++++----
 net/sched/sch_hfsc.c      | 15 +++++++++------
 net/sched/sch_htb.c       | 20 ++++++++++++--------
 net/sched/sch_ingress.c   | 14 +++++++++++---
 net/sched/sch_multiq.c    |  7 ++++---
 net/sched/sch_prio.c      |  9 +++++----
 net/sched/sch_qfq.c       |  7 ++++---
 net/sched/sch_sfb.c       |  9 +++++----
 net/sched/sch_sfq.c       | 11 ++++++-----
 21 files changed, 160 insertions(+), 129 deletions(-)

-- 
1.8.3.1
