From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: sched: deprecate enqueue_root()
Date: Mon, 11 May 2015 09:06:56 -0700
Message-ID: <1431360416.566.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36652 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbbEKQG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 12:06:58 -0400
Received: by igbpi8 with SMTP id pi8so73977335igb.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 09:06:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Only left enqueue_root() user is netem, and it looks not necessary :

qdisc_skb_cb(skb)->pkt_len is preserved after one skb_clone()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sch_generic.h |    6 ------
 net/sched/sch_netem.c     |    4 ++--
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 994b5a092f33f00812cb74e61e02bd96b52bad93..1b0a2e88ed2b47eeae0e01b6b9cda2893e15fcff 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -501,12 +501,6 @@ static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return sch->enqueue(skb, sch);
 }
 
-static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
-{
-	qdisc_skb_cb(skb)->pkt_len = skb->len;
-	return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
-}
-
 static inline bool qdisc_is_percpu_stats(const struct Qdisc *q)
 {
 	return q->flags & TCQ_F_CPUSTATS;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 956ead2cab9ad89f36835039a9b728d24a58ca41..5abd1d9de989e6c9777a225c03e42f8194ebda33 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -440,9 +440,9 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (count > 1 && (skb2 = skb_clone(skb, GFP_ATOMIC)) != NULL) {
 		struct Qdisc *rootq = qdisc_root(sch);
 		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
-		q->duplicate = 0;
 
-		qdisc_enqueue_root(skb2, rootq);
+		q->duplicate = 0;
+		rootq->enqueue(skb2, rootq);
 		q->duplicate = dupsave;
 	}
 
