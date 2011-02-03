From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sfq: deadlock in error path
Date: Wed, 2 Feb 2011 17:19:51 -0800
Message-ID: <20110202171951.09b89d92@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50739 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753174Ab1BCBTy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 20:19:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The change to allow divisor to be a parameter (in 2.6.38-rc1)
 commit 817fb15dfd988d8dda916ee04fa506f0c466b9d6
introduced a possible deadlock caught by sparse.

The scheduler tree lock was left locked in the case of an incorrect
divisor value. Simplest fix is to move test outside of lock
which also solves problem of partial update.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/sch_sfq.c	2011-02-02 17:12:06.338204106 -0800
+++ b/net/sched/sch_sfq.c	2011-02-02 17:13:39.127205019 -0800
@@ -491,17 +491,18 @@ static int sfq_change(struct Qdisc *sch,
 	if (opt->nla_len < nla_attr_size(sizeof(*ctl)))
 		return -EINVAL;
 
+	if (ctl->divisor &&
+	    (!is_power_of_2(ctl->divisor) || ctl->divisor > 65536))
+		return -EINVAL;
+
 	sch_tree_lock(sch);
 	q->quantum = ctl->quantum ? : psched_mtu(qdisc_dev(sch));
 	q->scaled_quantum = SFQ_ALLOT_SIZE(q->quantum);
 	q->perturb_period = ctl->perturb_period * HZ;
 	if (ctl->limit)
 		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH - 1);
-	if (ctl->divisor) {
-		if (!is_power_of_2(ctl->divisor) || ctl->divisor > 65536)
-			return -EINVAL;
+	if (ctl->divisor)
 		q->divisor = ctl->divisor;
-	}
 	qlen = sch->q.qlen;
 	while (sch->q.qlen > q->limit)
 		sfq_drop(sch);
