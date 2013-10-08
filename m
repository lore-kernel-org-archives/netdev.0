From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] pkt_sched: fq: fix non TCP flows pacing
Date: Tue, 08 Oct 2013 15:16:00 -0700
Message-ID: <1381270560.12191.64.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381182269.12191.27.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Steinar H. Gunderson" <sesse@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:43768 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057Ab3JHWQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 18:16:02 -0400
Received: by mail-pd0-f180.google.com with SMTP id y10so9280190pdj.39
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 15:16:01 -0700 (PDT)
In-Reply-To: <1381182269.12191.27.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Steinar reported FQ pacing was not working for UDP flows.

It looks like the initial sk->sk_pacing_rate value of 0 was
a wrong choice. We should init it to ~0U (unlimited)

Then, TCA_FQ_FLOW_DEFAULT_RATE should be removed because it makes
no real sense. The default rate is really unlimited, and we
need to avoid a zero divide.

Reported-by: Steinar H. Gunderson <sesse@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
I removed the ACCESS_ONCE() stuff, as it adds conflicts for
next (net / net-next) merge. I'll send a separate patch later.

 net/core/sock.c    |    1 +
 net/sched/sch_fq.c |   20 +++++++++-----------
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 5b6beba..0b39e7a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2319,6 +2319,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk->sk_ll_usec		=	sysctl_net_busy_read;
 #endif
 
+	sk->sk_pacing_rate = ~0U;
 	/*
 	 * Before updating sk_refcnt, we must commit prior changes to memory
 	 * (Documentation/RCU/rculist_nulls.txt for details)
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 48501a2..a9dfdda 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -472,20 +472,16 @@ begin:
 	if (f->credit > 0 || !q->rate_enable)
 		goto out;
 
-	if (skb->sk && skb->sk->sk_state != TCP_TIME_WAIT) {
-		rate = skb->sk->sk_pacing_rate ?: q->flow_default_rate;
+	rate = q->flow_max_rate;
+	if (skb->sk && skb->sk->sk_state != TCP_TIME_WAIT)
+		rate = min(skb->sk->sk_pacing_rate, rate);
 
-		rate = min(rate, q->flow_max_rate);
-	} else {
-		rate = q->flow_max_rate;
-		if (rate == ~0U)
-			goto out;
-	}
-	if (rate) {
+	if (rate != ~0U) {
 		u32 plen = max(qdisc_pkt_len(skb), q->quantum);
 		u64 len = (u64)plen * NSEC_PER_SEC;
 
-		do_div(len, rate);
+		if (likely(rate))
+			do_div(len, rate);
 		/* Since socket rate can change later,
 		 * clamp the delay to 125 ms.
 		 * TODO: maybe segment the too big skb, as in commit
@@ -735,12 +731,14 @@ static int fq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	if (opts == NULL)
 		goto nla_put_failure;
 
+	/* TCA_FQ_FLOW_DEFAULT_RATE is not used anymore,
+	 * do not bother giving its value
+	 */
 	if (nla_put_u32(skb, TCA_FQ_PLIMIT, sch->limit) ||
 	    nla_put_u32(skb, TCA_FQ_FLOW_PLIMIT, q->flow_plimit) ||
 	    nla_put_u32(skb, TCA_FQ_QUANTUM, q->quantum) ||
 	    nla_put_u32(skb, TCA_FQ_INITIAL_QUANTUM, q->initial_quantum) ||
 	    nla_put_u32(skb, TCA_FQ_RATE_ENABLE, q->rate_enable) ||
-	    nla_put_u32(skb, TCA_FQ_FLOW_DEFAULT_RATE, q->flow_default_rate) ||
 	    nla_put_u32(skb, TCA_FQ_FLOW_MAX_RATE, q->flow_max_rate) ||
 	    nla_put_u32(skb, TCA_FQ_BUCKETS_LOG, q->fq_trees_log))
 		goto nla_put_failure;
