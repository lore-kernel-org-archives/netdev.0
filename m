From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] sfq: use net_random
Date: Fri, 18 Jan 2008 16:12:46 -0800
Message-ID: <20080118161246.2a6a8979@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:55091 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758276AbYASAf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 19:35:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SFQ doesn't need true random numbers, it is only using them to salt
a hash. Therefore it is better to use net_random() and avoid any possible
problems with depleting the entropy pool.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/sch_sfq.c	2008-01-17 09:00:58.000000000 -0800
+++ b/net/sched/sch_sfq.c	2008-01-17 09:03:26.000000000 -0800
@@ -386,7 +386,7 @@ static void sfq_perturbation(unsigned lo
 	struct Qdisc *sch = (struct Qdisc*)arg;
 	struct sfq_sched_data *q = qdisc_priv(sch);
 
-	get_random_bytes(&q->perturbation, 4);
+	q->perturbation = net_random();
 
 	if (q->perturb_period)
 		mod_timer(&q->perturb_timer, jiffies + q->perturb_period);
@@ -415,7 +415,7 @@ static int sfq_change(struct Qdisc *sch,
 	del_timer(&q->perturb_timer);
 	if (q->perturb_period) {
 		mod_timer(&q->perturb_timer, jiffies + q->perturb_period);
-		get_random_bytes(&q->perturbation, 4);
+		q->perturbation = net_random();
 	}
 	sch_tree_unlock(sch);
 	return 0;
@@ -443,7 +443,7 @@ static int sfq_init(struct Qdisc *sch, s
 	if (opt == NULL) {
 		q->quantum = psched_mtu(sch->dev);
 		q->perturb_period = 0;
-		get_random_bytes(&q->perturbation, 4);
+		q->perturbation = net_random();
 	} else {
 		int err = sfq_change(sch, opt);
 		if (err)
