From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 2/2] sch_netem: Replace ->requeue() method with open code
Date: Fri, 31 Oct 2008 13:20:29 +0000
Message-ID: <20081031132029.GB18895@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:49657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbYJaNUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 09:20:35 -0400
Received: by ug-out-1314.google.com with SMTP id 39so1224393ugf.37
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2008 06:20:34 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After removing netem classful functionality we are sure its inner
qdisc is tfifo, so we can replace qdisc->ops->requeue() method with
open code. After this patch there are no more ops->requeue() users.

The idea of this patch is by Patrick McHardy.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 2ad0959..1aa4345 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -233,7 +233,11 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		 */
 		cb->time_to_send = psched_get_time();
 		q->counter = 0;
-		ret = q->qdisc->ops->requeue(skb, q->qdisc);
+
+		__skb_queue_head(&q->qdisc->q, skb);
+		q->qdisc->qstats.backlog += qdisc_pkt_len(skb);
+		q->qdisc->qstats.requeues++;
+		ret = NET_XMIT_SUCCESS;
 	}
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
-- 
1.5.6.5

