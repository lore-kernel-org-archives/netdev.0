From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
	length for qdiscs
Date: Wed, 30 Jul 2008 22:50:37 +0200
Message-ID: <20080730205037.GA9532@ami.dom.local>
References: <489055E1.1040100@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:50693 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbYG3UsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 16:48:11 -0400
Received: by ug-out-1314.google.com with SMTP id h2so307732ugf.16
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2008 13:48:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <489055E1.1040100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, On 07/30/2008 01:52 PM:

> David Miller wrote:
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Wed, 30 Jul 2008 13:40:22 +0200
>>
>>> The reason why it translates it at all seems to be to not increase
>>> the drops counter. Within a single qdisc this could be avoided by
>>> other means easily, upper qdiscs would still increase the counter
>>> when we return anything besides NET_XMIT_SUCCESS though.
>>>
>>> This means we need a new NET_XMIT return value to indicate this to
>>> the upper qdiscs. So I'd suggest to introduce NET_XMIT_STOLEN,
>>> return that to upper qdiscs and translate it to NET_XMIT_SUCCESS
>>> in dev_queue_xmit, similar to NET_XMIT_BYPASS.
>> Maybe these NET_XMIT_* values being passed around should be a set of
>> bits.
>>
>> They could be composed of base meanings, combined with specific
>> attributes.
>>
>> So you could say "NET_XMIT_DROP | __NET_XMIT_NO_DROP_COUNT"
>>
>> The attributes get masked out by the top-level ->enqueue() caller,
>> such that the base meanings are the only thing that make their
>> way up into the stack.
>>
>> If it's only about communication within the qdisc tree, let's
>> simply code it that way.
> 
> Thats a good suggestion. I think this should work.

I hope, I didn't misunderstood who is expected to do this, so here is
my preliminary proposal. I guess, I did misunderstood some details,
so it's not final...

BTW, htb_enqueue()/requeue() is unfinished because it will conflict
with David's patch... 

Any suggestions are welcome.

Thanks,
Jarek P.

---

 include/linux/netdevice.h |    1 +
 include/net/sch_generic.h |   15 ++++++++++++++-
 net/sched/sch_atm.c       |   12 +++++++-----
 net/sched/sch_cbq.c       |   16 ++++++++++------
 net/sched/sch_dsmark.c    |    8 +++++---
 net/sched/sch_hfsc.c      |    8 +++++---
 net/sched/sch_htb.c       |    2 +-
 net/sched/sch_prio.c      |    8 +++++---
 net/sched/sch_sfq.c       |    2 +-
 9 files changed, 49 insertions(+), 23 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b4d056c..188e4e4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -64,6 +64,7 @@ struct wireless_dev;
 #define NET_XMIT_BYPASS		4	/* packet does not leave via dequeue;
 					   (TC use only - dev_queue_xmit
 					   returns this as NET_XMIT_SUCCESS) */
+#define NET_XMIT_MASK		0xFFFF	/* qdisc flags in net/sch_generic.h */
 
 /* Backlog congestion levels */
 #define NET_RX_SUCCESS		0   /* keep 'em coming, baby */
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b5f40d7..b79bd04 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -331,6 +331,19 @@ static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
 	return qdisc_skb_cb(skb)->pkt_len;
 }
 
+#ifdef CONFIG_NET_CLS_ACT
+/* additional qdisc xmit flags */
+enum net_xmit_qdisc_t
+{
+	__NET_XMIT_STOLEN = NET_XMIT_MASK + 1,
+};
+
+#define net_xmit_drop_count(e)	((e) & __NET_XMIT_STOLEN ? 0 : 1)
+
+#else
+#define net_xmit_drop_count(e)	(1)
+#endif
+
 static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 #ifdef CONFIG_NET_SCHED
@@ -343,7 +356,7 @@ static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
 {
 	qdisc_skb_cb(skb)->pkt_len = skb->len;
-	return qdisc_enqueue(skb, sch);
+	return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
 }
 
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 6b517b9..27dd773 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -415,7 +415,7 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
 			kfree_skb(skb);
-			return NET_XMIT_SUCCESS;
+			return NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			kfree_skb(skb);
 			goto drop;
@@ -432,9 +432,11 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	ret = qdisc_enqueue(skb, flow->q);
 	if (ret != 0) {
 drop: __maybe_unused
-		sch->qstats.drops++;
-		if (flow)
-			flow->qstats.drops++;
+		if (net_xmit_drop_count(ret)) {
+			sch->qstats.drops++;
+			if (flow)
+				flow->qstats.drops++;
+		}
 		return ret;
 	}
 	sch->bstats.bytes += qdisc_pkt_len(skb);
@@ -530,7 +532,7 @@ static int atm_tc_requeue(struct sk_buff *skb, struct Qdisc *sch)
 	if (!ret) {
 		sch->q.qlen++;
 		sch->qstats.requeues++;
-	} else {
+	} else if (net_xmit_drop_count(ret)) {
 		sch->qstats.drops++;
 		p->link.qstats.drops++;
 	}
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 14954bf..00a0af6 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -256,7 +256,7 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
-			*qerr = NET_XMIT_SUCCESS;
+			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
 		case TC_ACT_RECLASSIFY:
@@ -397,9 +397,11 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return ret;
 	}
 
-	sch->qstats.drops++;
-	cbq_mark_toplevel(q, cl);
-	cl->qstats.drops++;
+	if (net_xmit_drop_count(ret)) {
+		sch->qstats.drops++;
+		cbq_mark_toplevel(q, cl);
+		cl->qstats.drops++;
+	}
 	return ret;
 }
 
@@ -430,8 +432,10 @@ cbq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 			cbq_activate_class(cl);
 		return 0;
 	}
-	sch->qstats.drops++;
-	cl->qstats.drops++;
+	if (net_xmit_drop_count(ret)) {
+		sch->qstats.drops++;
+		cl->qstats.drops++;
+	}
 	return ret;
 }
 
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index a935676..7170275 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -236,7 +236,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
 			kfree_skb(skb);
-			return NET_XMIT_SUCCESS;
+			return NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 
 		case TC_ACT_SHOT:
 			goto drop;
@@ -254,7 +254,8 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	err = qdisc_enqueue(skb, p->q);
 	if (err != NET_XMIT_SUCCESS) {
-		sch->qstats.drops++;
+		if (net_xmit_drop_count(err))
+			sch->qstats.drops++;
 		return err;
 	}
 
@@ -321,7 +322,8 @@ static int dsmark_requeue(struct sk_buff *skb, struct Qdisc *sch)
 
 	err = p->q->ops->requeue(skb, p->q);
 	if (err != NET_XMIT_SUCCESS) {
-		sch->qstats.drops++;
+		if (net_xmit_drop_count(err))
+			sch->qstats.drops++;
 		return err;
 	}
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 0ae7d19..5cf9ae7 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1166,7 +1166,7 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
-			*qerr = NET_XMIT_SUCCESS;
+			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
 		}
@@ -1586,8 +1586,10 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	err = qdisc_enqueue(skb, cl->qdisc);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
-		cl->qstats.drops++;
-		sch->qstats.drops++;
+		if (net_xmit_drop_count(err)) {
+			cl->qstats.drops++;
+			sch->qstats.drops++;
+		}
 		return err;
 	}
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 75a4095..635e8ce 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -221,7 +221,7 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
-			*qerr = NET_XMIT_SUCCESS;
+			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
 		}
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index f849243..adb1a52 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -45,7 +45,7 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		switch (err) {
 		case TC_ACT_STOLEN:
 		case TC_ACT_QUEUED:
-			*qerr = NET_XMIT_SUCCESS;
+			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
 		}
@@ -88,7 +88,8 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
 	}
-	sch->qstats.drops++;
+	if (net_xmit_drop_count(ret))
+		sch->qstats.drops++;
 	return ret;
 }
 
@@ -114,7 +115,8 @@ prio_requeue(struct sk_buff *skb, struct Qdisc* sch)
 		sch->qstats.requeues++;
 		return 0;
 	}
-	sch->qstats.drops++;
+	if (net_xmit_drop_count(ret))
+		sch->qstats.drops++;
 	return NET_XMIT_DROP;
 }
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 8589da6..3a456e1 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -178,7 +178,7 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 		switch (result) {
 		case TC_ACT_STOLEN:
 		case TC_ACT_QUEUED:
-			*qerr = NET_XMIT_SUCCESS;
+			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return 0;
 		}
