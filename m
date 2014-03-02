From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net-next] sch_tbf: Remove holes in struct tbf_sched_data.
Date: Sun, 2 Mar 2014 17:30:26 +0900
Message-ID: <20140302173026.ad5cd8c8447ddf8806b03651@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:57060 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbaCBIa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 03:30:29 -0500
Received: by mail-pd0-f175.google.com with SMTP id x10so2485052pdj.6
        for <netdev@vger.kernel.org>; Sun, 02 Mar 2014 00:30:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On x86_64 we have 3 holes in struct tbf_sched_data.

The member peak_present can be replaced with peak.rate_bytes_ps,
because peak.rate_bytes_ps is set only when peak is specified in
tbf_change(). tbf_peak_present() is introduced to test
peak.rate_bytes_ps.

The member max_size is moved to fill 32bit hole.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
 net/sched/sch_tbf.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 1cb413fead89..0893161b0262 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -101,12 +101,11 @@
 struct tbf_sched_data {
 /* Parameters */
 	u32		limit;		/* Maximal length of backlog: bytes */
+	u32		max_size;
 	s64		buffer;		/* Token bucket depth/rate: MUST BE >= MTU/B */
 	s64		mtu;
-	u32		max_size;
 	struct psched_ratecfg rate;
 	struct psched_ratecfg peak;
-	bool peak_present;
 
 /* Variables */
 	s64	tokens;			/* Current number of B tokens */
@@ -222,6 +221,11 @@ static unsigned int tbf_drop(struct Qdisc *sch)
 	return len;
 }
 
+static bool tbf_peak_present(const struct tbf_sched_data *q)
+{
+	return q->peak.rate_bytes_ps;
+}
+
 static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
@@ -238,7 +242,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 		now = ktime_to_ns(ktime_get());
 		toks = min_t(s64, now - q->t_c, q->buffer);
 
-		if (q->peak_present) {
+		if (tbf_peak_present(q)) {
 			ptoks = toks + q->ptokens;
 			if (ptoks > q->mtu)
 				ptoks = q->mtu;
@@ -378,6 +382,8 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 		} else {
 			max_size = min_t(u64, max_size, psched_ns_t2l(&peak, mtu));
 		}
+	} else {
+		memset(&peak, 0, sizeof(peak));
 	}
 
 	if (max_size < psched_mtu(qdisc_dev(sch)))
@@ -410,12 +416,7 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	q->ptokens = q->mtu;
 
 	memcpy(&q->rate, &rate, sizeof(struct psched_ratecfg));
-	if (qopt->peakrate.rate) {
-		memcpy(&q->peak, &peak, sizeof(struct psched_ratecfg));
-		q->peak_present = true;
-	} else {
-		q->peak_present = false;
-	}
+	memcpy(&q->peak, &peak, sizeof(struct psched_ratecfg));
 
 	sch_tree_unlock(sch);
 	err = 0;
@@ -458,7 +459,7 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 
 	opt.limit = q->limit;
 	psched_ratecfg_getrate(&opt.rate, &q->rate);
-	if (q->peak_present)
+	if (tbf_peak_present(q))
 		psched_ratecfg_getrate(&opt.peakrate, &q->peak);
 	else
 		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
@@ -469,7 +470,7 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 	if (q->rate.rate_bytes_ps >= (1ULL << 32) &&
 	    nla_put_u64(skb, TCA_TBF_RATE64, q->rate.rate_bytes_ps))
 		goto nla_put_failure;
-	if (q->peak_present &&
+	if (tbf_peak_present(q) &&
 	    q->peak.rate_bytes_ps >= (1ULL << 32) &&
 	    nla_put_u64(skb, TCA_TBF_PRATE64, q->peak.rate_bytes_ps))
 		goto nla_put_failure;
-- 
1.8.3.2
