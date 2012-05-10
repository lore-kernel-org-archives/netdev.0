From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: update bstats in dequeue()
Date: Thu, 10 May 2012 17:36:34 +0200
Message-ID: <1336664194.31653.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:39635 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab2EJPgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 11:36:38 -0400
Received: by eeit10 with SMTP id t10so631515eei.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 08:36:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Class bytes/packets stats can be misleading because they are updated in
enqueue() while packet might be dropped later.

We already fixed all qdiscs but sch_atm.

This patch makes the final cleanup.

class rate estimators can now match qdisc ones.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_atm.c  |    4 ++--
 net/sched/sch_drr.c  |    4 ++--
 net/sched/sch_hfsc.c |    2 +-
 net/sched/sch_htb.c  |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index a77a4fb..8522a47 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -423,8 +423,6 @@ drop: __maybe_unused
 		}
 		return ret;
 	}
-	qdisc_bstats_update(sch, skb);
-	bstats_update(&flow->bstats, skb);
 	/*
 	 * Okay, this may seem weird. We pretend we've dropped the packet if
 	 * it goes via ATM. The reason for this is that the outer qdisc
@@ -472,6 +470,8 @@ static void sch_atm_dequeue(unsigned long data)
 			if (unlikely(!skb))
 				break;
 
+			qdisc_bstats_update(sch, skb);
+			bstats_update(&flow->bstats, skb);
 			pr_debug("atm_tc_dequeue: sending on class %p\n", flow);
 			/* remove any LL header somebody else has attached */
 			skb_pull(skb, skb_network_offset(skb));
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index c218987..9ce0b4f 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -376,8 +376,6 @@ static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		cl->deficit = cl->quantum;
 	}
 
-	bstats_update(&cl->bstats, skb);
-
 	sch->q.qlen++;
 	return err;
 }
@@ -403,6 +401,8 @@ static struct sk_buff *drr_dequeue(struct Qdisc *sch)
 			skb = qdisc_dequeue_peeked(cl->qdisc);
 			if (cl->qdisc->q.qlen == 0)
 				list_del(&cl->alist);
+
+			bstats_update(&cl->bstats, skb);
 			qdisc_bstats_update(sch, skb);
 			sch->q.qlen--;
 			return skb;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 8db3e2c..6c2ec45 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1609,7 +1609,6 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (cl->qdisc->q.qlen == 1)
 		set_active(cl, qdisc_pkt_len(skb));
 
-	bstats_update(&cl->bstats, skb);
 	sch->q.qlen++;
 
 	return NET_XMIT_SUCCESS;
@@ -1657,6 +1656,7 @@ hfsc_dequeue(struct Qdisc *sch)
 		return NULL;
 	}
 
+	bstats_update(&cl->bstats, skb);
 	update_vf(cl, qdisc_pkt_len(skb), cur_time);
 	if (realtime)
 		cl->cl_cumul += qdisc_pkt_len(skb);
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index acae5b0..992ab3d 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -574,7 +574,6 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 		return ret;
 	} else {
-		bstats_update(&cl->bstats, skb);
 		htb_activate(q, cl);
 	}
 
@@ -835,6 +834,7 @@ next:
 	} while (cl != start);
 
 	if (likely(skb != NULL)) {
+		bstats_update(&cl->bstats, skb);
 		cl->un.leaf.deficit[level] -= qdisc_pkt_len(skb);
 		if (cl->un.leaf.deficit[level] < 0) {
 			cl->un.leaf.deficit[level] += cl->quantum;
