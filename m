From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: gso_skb is now a list, needs a proper
 destructor
Date: Tue, 02 Sep 2014 16:51:43 -0700
Message-ID: <1409701903.26422.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:49526 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbaIBXvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 19:51:45 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so9756336pdj.31
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 16:51:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

gso_skb can now be a list of skbs.

Qdisc destructors have to take care of it, or we can leak skbs.

Fixes: ce93718fb7cd ("net: Don't keep around original SKB when we software segment GSO frames.")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_generic.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5b261e91bdbd..19696ebe9ebc 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -621,7 +621,7 @@ void qdisc_reset(struct Qdisc *qdisc)
 		ops->reset(qdisc);
 
 	if (qdisc->gso_skb) {
-		kfree_skb(qdisc->gso_skb);
+		kfree_skb_list(qdisc->gso_skb);
 		qdisc->gso_skb = NULL;
 		qdisc->q.qlen = 0;
 	}
@@ -657,7 +657,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	module_put(ops->owner);
 	dev_put(qdisc_dev(qdisc));
 
-	kfree_skb(qdisc->gso_skb);
+	kfree_skb_list(qdisc->gso_skb);
 	/*
 	 * gen_estimator est_timer() might access qdisc->q.lock,
 	 * wait a RCU grace period before freeing qdisc.
