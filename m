From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pkt_sched: fq: fix non TCP flows pacing
Date: Mon, 07 Oct 2013 14:44:29 -0700
Message-ID: <1381182269.12191.27.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Steinar H. Gunderson" <sesse@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:63008 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab3JGVob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 17:44:31 -0400
Received: by mail-pa0-f52.google.com with SMTP id kl14so7800735pab.25
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 14:44:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Steinar reported FQ pacing was not working for UDP flows.

It looks like the initial sk->sk_pacing_rate value of 0 was
a wrong choice. We should init it to ~0U like sk_max_pacing_rate

Then, TCA_FQ_FLOW_DEFAULT_RATE should be removed because it makes
no real sense. (The default rate is really : ~0U)

While debugging this issue, I realized sk_pacing_rate is shared between
transport and packet scheduler without locking / barriers :

We should use ACCESS_ONCE() to make sure compiler wont perform
multiple loads or stores.

Reported-by: Steinar H. Gunderson <sesse@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c      |    1 +
 net/ipv4/tcp_input.c |    7 ++++++-
 net/sched/sch_fq.c   |   20 +++++++++-----------
 3 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 2bd9b3f..fd6afa2 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2331,6 +2331,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 #endif
 
 	sk->sk_max_pacing_rate = ~0U;
+	sk->sk_pacing_rate = ~0U;
 	/*
 	 * Before updating sk_refcnt, we must commit prior changes to memory
 	 * (Documentation/RCU/rculist_nulls.txt for details)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fa6cf1f..d95f875 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -755,7 +755,12 @@ static void tcp_update_pacing_rate(struct sock *sk)
 	if (tp->srtt > 8 + 2)
 		do_div(rate, tp->srtt);
 
-	sk->sk_pacing_rate = min_t(u64, rate, sk->sk_max_pacing_rate);
+	/* ACCESS_ONCE() is needed because FQ fetches sk_pacing_rate without
+	 * any lock. We want to make sure compiler wont use sk_pacing_rate
+	 * with intermediate values.
+	 */
+	ACCESS_ONCE(sk->sk_pacing_rate) = min_t(u64, rate,
+						sk->sk_max_pacing_rate);
 }
 
 /* Calculate rto without backoff.  This is the second half of Van Jacobson's
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index a2fef8b..46b2adb 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -472,20 +472,16 @@ begin:
 	if (f->credit > 0 || !q->rate_enable)
 		goto out;
 
-	if (skb->sk && skb->sk->sk_state != TCP_TIME_WAIT) {
-		rate = skb->sk->sk_pacing_rate ?: q->flow_default_rate;
+	rate = q->flow_max_rate;
+	if (skb->sk && skb->sk->sk_state != TCP_TIME_WAIT)
+		rate = min(ACCESS_ONCE(skb->sk->sk_pacing_rate), rate);
 
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
