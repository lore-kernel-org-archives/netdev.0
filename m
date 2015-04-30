From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] codel: fix maxpacket/mtu confusion
Date: Thu, 30 Apr 2015 09:40:40 -0700
Message-ID: <1430412040.3711.94.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kathleen Nichols <nichols@pollere.com>,
	Van Jacobson <vanj@google.com>,
	Dave Taht <dave.taht@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:35881 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbbD3Qkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 12:40:49 -0400
Received: by iebrs15 with SMTP id rs15so71873085ieb.3
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 09:40:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Under presence of TSO/GSO/GRO packets, codel at low rates can be quite
useless. In following example, not a single packet was ever dropped,
while average delay in codel queue is ~100 ms !

qdisc codel 0: parent 1:12 limit 16000p target 5.0ms interval 100.0ms 
 Sent 134376498 bytes 88797 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 13626b 3p requeues 0 
  count 0 lastcount 0 ldelay 96.9ms drop_next 0us
  maxpacket 9084 ecn_mark 0 drop_overlimit 0

This comes from a confusion of what should be the minimal backlog. It is
pretty clear it is not 64KB or whatever max GSO packet ever reached the
qdisc.

codel intent was to use MTU of the device.

After the fix, we finally drop some packets, and rtt/cwnd of my single
TCP flow are meeting our expectations.

qdisc codel 0: parent 1:12 limit 16000p target 5.0ms interval 100.0ms 
 Sent 102798497 bytes 67912 pkt (dropped 1365, overlimits 0 requeues 0) 
 backlog 6056b 3p requeues 0 
  count 1 lastcount 1 ldelay 36.3ms drop_next 0us
  maxpacket 10598 ecn_mark 0 drop_overlimit 0

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Kathleen Nichols <nichols@pollere.com>
Cc: Dave Taht <dave.taht@gmail.com>
Cc: Van Jacobson <vanj@google.com>
---
 include/net/codel.h      |   10 +++++++---
 net/sched/sch_codel.c    |    2 +-
 net/sched/sch_fq_codel.c |    2 +-
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/net/codel.h b/include/net/codel.h
index aeee28081245c9215f10badd611f58ba0124fcd0..1e18005f7f65f061f6084ea1823a8d37368a57e4 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -120,11 +120,13 @@ static inline u32 codel_time_to_us(codel_time_t val)
  * struct codel_params - contains codel parameters
  * @target:	target queue size (in time units)
  * @interval:	width of moving time window
+ * @mtu:	device mtu, or minimal queue backlog in bytes.
  * @ecn:	is Explicit Congestion Notification enabled
  */
 struct codel_params {
 	codel_time_t	target;
 	codel_time_t	interval;
+	u32		mtu;
 	bool		ecn;
 };
 
@@ -166,10 +168,12 @@ struct codel_stats {
 	u32		ecn_mark;
 };
 
-static void codel_params_init(struct codel_params *params)
+static void codel_params_init(struct codel_params *params,
+			      const struct Qdisc *sch)
 {
 	params->interval = MS2TIME(100);
 	params->target = MS2TIME(5);
+	params->mtu = psched_mtu(qdisc_dev(sch));
 	params->ecn = false;
 }
 
@@ -180,7 +184,7 @@ static void codel_vars_init(struct codel_vars *vars)
 
 static void codel_stats_init(struct codel_stats *stats)
 {
-	stats->maxpacket = 256;
+	stats->maxpacket = 0;
 }
 
 /*
@@ -234,7 +238,7 @@ static bool codel_should_drop(const struct sk_buff *skb,
 		stats->maxpacket = qdisc_pkt_len(skb);
 
 	if (codel_time_before(vars->ldelay, params->target) ||
-	    sch->qstats.backlog <= stats->maxpacket) {
+	    sch->qstats.backlog <= params->mtu) {
 		/* went below - stay below for at least interval */
 		vars->first_above_time = 0;
 		return false;
diff --git a/net/sched/sch_codel.c b/net/sched/sch_codel.c
index de28f8e968e8176ac7630a1e6fcccb45ad295f5d..7a0bdb16ac92fd0a20f565295392bed8674c8d90 100644
--- a/net/sched/sch_codel.c
+++ b/net/sched/sch_codel.c
@@ -164,7 +164,7 @@ static int codel_init(struct Qdisc *sch, struct nlattr *opt)
 
 	sch->limit = DEFAULT_CODEL_LIMIT;
 
-	codel_params_init(&q->params);
+	codel_params_init(&q->params, sch);
 	codel_vars_init(&q->vars);
 	codel_stats_init(&q->stats);
 
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 1e52decb7b59cf0b4173d0f17efdab8fefee5f26..c244c45b78d7feca32fda3b925f7605aebf0a5b6 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -391,7 +391,7 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
 	q->perturbation = prandom_u32();
 	INIT_LIST_HEAD(&q->new_flows);
 	INIT_LIST_HEAD(&q->old_flows);
-	codel_params_init(&q->cparams);
+	codel_params_init(&q->cparams, sch);
 	codel_stats_init(&q->cstats);
 	q->cparams.ecn = true;
 
