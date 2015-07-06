From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 1/7] net: sched: extend percpu stats helpers
Date: Mon,  6 Jul 2015 05:18:03 -0700
Message-ID: <1436185089-18268-2-git-send-email-edumazet@google.com>
References: <1436185089-18268-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:34268 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475AbbGFMSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 08:18:21 -0400
Received: by iebmu5 with SMTP id mu5so111545699ieb.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 05:18:20 -0700 (PDT)
In-Reply-To: <1436185089-18268-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qdisc_bstats_update_cpu() and other helpers were added to support
percpu stats for qdisc.

We want to add percpu stats for tc action, so this patch add common
helpers.

qdisc_bstats_update_cpu() is renamed to qdisc_bstats_cpu_update()
qdisc_qstats_drop_cpu() is renamed to qdisc_qstats_cpu_drop()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: John Fastabend <john.fastabend@gmail.com>
---
 include/net/sch_generic.h | 31 +++++++++++++++++++++----------
 net/core/dev.c            |  4 ++--
 2 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 2738f6f87908..2eab08c38e32 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -513,17 +513,20 @@ static inline void bstats_update(struct gnet_stats_basic_packed *bstats,
 	bstats->packets += skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs : 1;
 }
 
-static inline void qdisc_bstats_update_cpu(struct Qdisc *sch,
-					   const struct sk_buff *skb)
+static inline void bstats_cpu_update(struct gnet_stats_basic_cpu *bstats,
+				     const struct sk_buff *skb)
 {
-	struct gnet_stats_basic_cpu *bstats =
-				this_cpu_ptr(sch->cpu_bstats);
-
 	u64_stats_update_begin(&bstats->syncp);
 	bstats_update(&bstats->bstats, skb);
 	u64_stats_update_end(&bstats->syncp);
 }
 
+static inline void qdisc_bstats_cpu_update(struct Qdisc *sch,
+					   const struct sk_buff *skb)
+{
+	bstats_cpu_update(this_cpu_ptr(sch->cpu_bstats), skb);
+}
+
 static inline void qdisc_bstats_update(struct Qdisc *sch,
 				       const struct sk_buff *skb)
 {
@@ -547,16 +550,24 @@ static inline void __qdisc_qstats_drop(struct Qdisc *sch, int count)
 	sch->qstats.drops += count;
 }
 
-static inline void qdisc_qstats_drop(struct Qdisc *sch)
+static inline void qstats_drop_inc(struct gnet_stats_queue *qstats)
 {
-	sch->qstats.drops++;
+	qstats->drops++;
 }
 
-static inline void qdisc_qstats_drop_cpu(struct Qdisc *sch)
+static inline void qstats_overlimit_inc(struct gnet_stats_queue *qstats)
 {
-	struct gnet_stats_queue *qstats = this_cpu_ptr(sch->cpu_qstats);
+	qstats->overlimits++;
+}
 
-	qstats->drops++;
+static inline void qdisc_qstats_drop(struct Qdisc *sch)
+{
+	qstats_drop_inc(&sch->qstats);
+}
+
+static inline void qdisc_qstats_cpu_drop(struct Qdisc *sch)
+{
+	qstats_drop_inc(this_cpu_ptr(sch->cpu_qstats));
 }
 
 static inline void qdisc_qstats_overlimit(struct Qdisc *sch)
diff --git a/net/core/dev.c b/net/core/dev.c
index 6778a9999d52..e0d270143fc7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3646,7 +3646,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 
 	qdisc_skb_cb(skb)->pkt_len = skb->len;
 	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
-	qdisc_bstats_update_cpu(cl->q, skb);
+	qdisc_bstats_cpu_update(cl->q, skb);
 
 	switch (tc_classify(skb, cl, &cl_res)) {
 	case TC_ACT_OK:
@@ -3654,7 +3654,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 		skb->tc_index = TC_H_MIN(cl_res.classid);
 		break;
 	case TC_ACT_SHOT:
-		qdisc_qstats_drop_cpu(cl->q);
+		qdisc_qstats_cpu_drop(cl->q);
 	case TC_ACT_STOLEN:
 	case TC_ACT_QUEUED:
 		kfree_skb(skb);
-- 
2.4.3.573.g4eafbef
