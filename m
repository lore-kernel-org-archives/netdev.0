From: David Miller <davem@davemloft.net>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Wed, 06 Aug 2008 22:09:11 -0700 (PDT)
Message-ID: <20080806.220911.91192536.davem@davemloft.net>
References: <20080806224248.18266k9ahc5nkk8w@hayate.ip6>
	<20080806215258.GA3306@ami.dom.local>
	<20080806.202636.246995904.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33710
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751456AbYHGFJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 01:09:10 -0400
In-Reply-To: <20080806.202636.246995904.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 06 Aug 2008 20:26:36 -0700 (PDT)

> 
> I still haven't seen anyone suggest creating a __NET_XMIT_KFREE_SKB to
> fix this most rediculious problem.
> 
> I'm still waiting...

Here is what it might look like.  I haven't tried to boot this,
but the only non-trivial case was SFQ's congestion drop code.

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a7abfda..4bfee1b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -347,6 +347,7 @@ static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
 enum net_xmit_qdisc_t {
 	__NET_XMIT_STOLEN = 0x00010000,
 	__NET_XMIT_BYPASS = 0x00020000,
+	__NET_XMIT_KFREE  = 0x00040000,
 };
 
 #ifdef CONFIG_NET_CLS_ACT
@@ -366,8 +367,15 @@ static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
 {
+	int ret;
+
 	qdisc_skb_cb(skb)->pkt_len = skb->len;
-	return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
+	ret = qdisc_enqueue(skb, sch);
+
+	if (unlikely(ret & __NET_XMIT_KFREE))
+		kfree_skb(skb);
+
+	return ret & NET_XMIT_MASK;
 }
 
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
@@ -470,10 +478,9 @@ static inline unsigned int qdisc_queue_drop(struct Qdisc *sch)
 
 static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
 {
-	kfree_skb(skb);
 	sch->qstats.drops++;
 
-	return NET_XMIT_DROP;
+	return NET_XMIT_DROP | __NET_XMIT_KFREE;
 }
 
 static inline int qdisc_reshape_fail(struct sk_buff *skb, struct Qdisc *sch)
@@ -488,8 +495,7 @@ static inline int qdisc_reshape_fail(struct sk_buff *skb, struct Qdisc *sch)
 
 drop:
 #endif
-	kfree_skb(skb);
-	return NET_XMIT_DROP;
+	return NET_XMIT_DROP | __NET_XMIT_KFREE;
 }
 
 /* Length to Time (L2T) lookup in a qdisc_rate_table, to determine how
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 43d3725..696b4ee 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -414,10 +414,11 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
-			kfree_skb(skb);
-			return NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+			return (NET_XMIT_SUCCESS |
+				__NET_XMIT_STOLEN |
+				__NET_XMIT_KFREE);
 		case TC_ACT_SHOT:
-			kfree_skb(skb);
+			ret |= __NET_XMIT_KFREE;
 			goto drop;
 		case TC_POLICE_RECLASSIFY:
 			if (flow->excess)
diff --git a/net/sched/sch_blackhole.c b/net/sched/sch_blackhole.c
index 507fb48..7018675 100644
--- a/net/sched/sch_blackhole.c
+++ b/net/sched/sch_blackhole.c
@@ -20,7 +20,7 @@
 static int blackhole_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	qdisc_drop(skb, sch);
-	return NET_XMIT_SUCCESS;
+	return NET_XMIT_SUCCESS | __NET_XMIT_KFREE;
 }
 
 static struct sk_buff *blackhole_dequeue(struct Qdisc *sch)
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 4e261ce..27fc053 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -379,8 +379,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (cl == NULL) {
 		if (ret & __NET_XMIT_BYPASS)
 			sch->qstats.drops++;
-		kfree_skb(skb);
-		return ret;
+		return ret | __NET_XMIT_KFREE;
 	}
 
 #ifdef CONFIG_NET_CLS_ACT
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index edd1298..fbc318b 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -235,8 +235,9 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #ifdef CONFIG_NET_CLS_ACT
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
-			kfree_skb(skb);
-			return NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+			return (NET_XMIT_SUCCESS |
+				__NET_XMIT_STOLEN |
+				__NET_XMIT_KFREE);
 
 		case TC_ACT_SHOT:
 			goto drop;
@@ -266,9 +267,8 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 
 drop:
-	kfree_skb(skb);
 	sch->qstats.drops++;
-	return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+	return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS | __NET_XMIT_KFREE;
 }
 
 static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7cf83b3..753ee7f 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -291,8 +291,7 @@ EXPORT_SYMBOL(netif_carrier_off);
 
 static int noop_enqueue(struct sk_buff *skb, struct Qdisc * qdisc)
 {
-	kfree_skb(skb);
-	return NET_XMIT_CN;
+	return NET_XMIT_CN | __NET_XMIT_KFREE;
 }
 
 static struct sk_buff *noop_dequeue(struct Qdisc * qdisc)
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index c1ad6b8..70c2f58 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -237,7 +237,7 @@ drop:
 
 congestion_drop:
 	qdisc_drop(skb, sch);
-	return NET_XMIT_CN;
+	return NET_XMIT_CN | __NET_XMIT_KFREE;
 }
 
 static int gred_requeue(struct sk_buff *skb, struct Qdisc* sch)
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index c2b8d9c..9d2059f 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1580,8 +1580,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (cl == NULL) {
 		if (err & __NET_XMIT_BYPASS)
 			sch->qstats.drops++;
-		kfree_skb(skb);
-		return err;
+		return err | __NET_XMIT_KFREE;
 	}
 
 	err = qdisc_enqueue(skb, cl->qdisc);
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index be35422..3164500 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -561,16 +561,14 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			__skb_queue_tail(&q->direct_queue, skb);
 			q->direct_pkts++;
 		} else {
-			kfree_skb(skb);
 			sch->qstats.drops++;
-			return NET_XMIT_DROP;
+			return NET_XMIT_DROP | __NET_XMIT_KFREE;
 		}
 #ifdef CONFIG_NET_CLS_ACT
 	} else if (!cl) {
 		if (ret & __NET_XMIT_BYPASS)
 			sch->qstats.drops++;
-		kfree_skb(skb);
-		return ret;
+		return ret | __NET_XMIT_KFREE;
 #endif
 	} else if ((ret = qdisc_enqueue(skb, cl->un.leaf.q)) != NET_XMIT_SUCCESS) {
 		if (net_xmit_drop_count(ret)) {
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index fb0294d..928855d 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -175,8 +175,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	if (count == 0) {
 		sch->qstats.drops++;
-		kfree_skb(skb);
-		return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+		return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS | __NET_XMIT_KFREE;
 	}
 
 	skb_orphan(skb);
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index eac1976..3284555 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -76,8 +76,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 		if (ret & __NET_XMIT_BYPASS)
 			sch->qstats.drops++;
-		kfree_skb(skb);
-		return ret;
+		return ret | __NET_XMIT_KFREE;
 	}
 #endif
 
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 5da0583..adc71f6 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -105,7 +105,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 congestion_drop:
 	qdisc_drop(skb, sch);
-	return NET_XMIT_CN;
+	return NET_XMIT_CN | __NET_XMIT_KFREE;
 }
 
 static int red_requeue(struct sk_buff *skb, struct Qdisc* sch)
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 6e041d1..11b3098 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -232,7 +232,7 @@ static inline void sfq_inc(struct sfq_sched_data *q, sfq_index x)
 	sfq_link(q, x);
 }
 
-static unsigned int sfq_drop(struct Qdisc *sch)
+static struct sk_buff *__sfq_drop(struct Qdisc *sch, int *len_p)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	sfq_index d = q->max_depth;
@@ -247,12 +247,13 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 		skb = q->qs[x].prev;
 		len = qdisc_pkt_len(skb);
 		__skb_unlink(skb, &q->qs[x]);
-		kfree_skb(skb);
 		sfq_dec(q, x);
 		sch->q.qlen--;
 		sch->qstats.drops++;
 		sch->qstats.backlog -= len;
-		return len;
+		if (len_p)
+			*len_p = len;
+		return skb;
 	}
 
 	if (d == 1) {
@@ -263,22 +264,37 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 		skb = q->qs[d].prev;
 		len = qdisc_pkt_len(skb);
 		__skb_unlink(skb, &q->qs[d]);
-		kfree_skb(skb);
 		sfq_dec(q, d);
 		sch->q.qlen--;
 		q->ht[q->hash[d]] = SFQ_DEPTH;
 		sch->qstats.drops++;
 		sch->qstats.backlog -= len;
-		return len;
+		if (len_p)
+			*len_p = len;
+		return skb;
 	}
 
-	return 0;
+	if (len_p)
+		*len_p = 0;
+	return NULL;
+}
+
+static unsigned int sfq_drop(struct Qdisc *sch)
+{
+	struct sk_buff *skb;
+	int len;
+
+	skb = __sfq_drop(sch, &len);
+	if (skb)
+		kfree_skb(skb);
+	return len;
 }
 
 static int
 sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *drop_skb;
 	unsigned int hash;
 	sfq_index x;
 	int ret;
@@ -287,8 +303,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (hash == 0) {
 		if (ret & __NET_XMIT_BYPASS)
 			sch->qstats.drops++;
-		kfree_skb(skb);
-		return ret;
+		return ret | __NET_XMIT_KFREE;
 	}
 	hash--;
 
@@ -325,8 +340,13 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return 0;
 	}
 
-	sfq_drop(sch);
-	return NET_XMIT_CN;
+	drop_skb = __sfq_drop(sch, NULL);
+	if (drop_skb == skb) {
+		return NET_XMIT_CN | __NET_XMIT_KFREE;
+	} else {
+		kfree_skb(drop_skb);
+		return NET_XMIT_CN;
+	}
 }
 
 static int
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 7d3b7ff..4f84ea6 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -125,12 +125,13 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	if (qdisc_pkt_len(skb) > q->max_size) {
 		sch->qstats.drops++;
+		ret = NET_XMIT_DROP;
 #ifdef CONFIG_NET_CLS_ACT
 		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
 #endif
-			kfree_skb(skb);
+			ret |= __NET_XMIT_KFREE;
 
-		return NET_XMIT_DROP;
+		return ret;
 	}
 
 	ret = qdisc_enqueue(skb, q->qdisc);
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 2c35c67..befc919 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -88,9 +88,8 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		return 0;
 	}
 
-	kfree_skb(skb);
 	sch->qstats.drops++;
-	return NET_XMIT_DROP;
+	return NET_XMIT_DROP | __NET_XMIT_KFREE;
 }
 
 static int
