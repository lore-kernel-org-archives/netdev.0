From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH take 2] net_sched: Add qdisc __NET_XMIT_BYPASS flag
Date: Mon, 4 Aug 2008 06:28:13 +0000
Message-ID: <20080804062813.GA4570@ff.dom.local>
References: <20080731171431.GA9464@ami.dom.local> <4892AA16.40706@trash.net> <20080801101929.GA12735@ff.dom.local> <20080803.182524.240976246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:12651 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017AbYHDGWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 02:22:50 -0400
Received: by an-out-0708.google.com with SMTP id d40so295033and.103
        for <netdev@vger.kernel.org>; Sun, 03 Aug 2008 23:22:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080803.182524.240976246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 03, 2008 at 06:25:24PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 1 Aug 2008 10:19:29 +0000
> 
> > @@ -331,14 +331,14 @@ static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
> >  	return qdisc_skb_cb(skb)->pkt_len;
> >  }
> >  
> > -#ifdef CONFIG_NET_CLS_ACT
> >  /* additional qdisc xmit flags */
> >  enum net_xmit_qdisc_t {
> > -	__NET_XMIT_STOLEN = NET_XMIT_MASK + 1,
> > +	__NET_XMIT_STOLEN = NET_XMIT_MASK + 0x1,
> > +	__NET_XMIT_BYPASS = NET_XMIT_MASK + 0x2,
> >  };
> >  
> 
> NET_XMIT_MASK + 0x2 is (0xffff + 2) which is 0x10001 and this is very
> much not what you intended.

Thanks for spotting this!

> 
> Please just explicitly spell out the bit mask values instead of trying
> to create some false relationship with the mask and these values.
> 
> Next, these patches doesn't fix the while problem, in that htb and
> friends are still corrupting the enqueue return value so that TCP is
> going to do the wrong thing still.

These 2 patches aren't supposed to fix these problems:

- the __NET_XMIT_STOLEN patch fixes a problem when a qdiscs passed
  upwards NET_XMIT_SUCCESS when eg. an skb was stolen by an action,
  to prevent treating this as dropped; then the upper qdiscs couldn't
  tell it's not the full NET_XMIT_SUCCESS and counted it as queued,
  which was wrong. (BTW, I especially tried to do it with minimal
  changes in htb_enqueue() to let you apply your htb patch without
  much editing.)

- the __NET_XMIT_BYPASS actually doesn't fix any serious problem, but
  lets to remove the mapping from dev_queue_xmit(), and BTW it passes
  better information to upper qdiscs too.

Thanks,
Jarek P.

------------------> (take 2)

Subject: net_sched: Add qdisc __NET_XMIT_BYPASS flag

Patrick McHardy <kaber@trash.net> noticed that it would be nice to
handle NET_XMIT_BYPASS by NET_XMIT_SUCCESS with an internal qdisc flag
__NET_XMIT_BYPASS and to remove the mapping from dev_queue_xmit().

David Miller <davem@davemloft.net> spotted a serious bug in the first
version of this patch.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 (apply on top of [PATCH] net_sched: Add qdisc __NET_XMIT_STOLEN flag)

 include/net/sch_generic.h |    8 ++++----
 net/core/dev.c            |    1 -
 net/sched/sch_atm.c       |    2 +-
 net/sched/sch_cbq.c       |    4 ++--
 net/sched/sch_dsmark.c    |    2 +-
 net/sched/sch_hfsc.c      |    4 ++--
 net/sched/sch_htb.c       |    6 +++---
 net/sched/sch_netem.c     |    2 +-
 net/sched/sch_prio.c      |    6 +++---
 net/sched/sch_sfq.c       |    6 +++---
 10 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f139009..b2a1e8f 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -331,14 +331,14 @@ static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
 	return qdisc_skb_cb(skb)->pkt_len;
 }
 
-#ifdef CONFIG_NET_CLS_ACT
-/* additional qdisc xmit flags */
+/* additional qdisc xmit flags (NET_XMIT_MASK in linux/netdevice.h) */
 enum net_xmit_qdisc_t {
-	__NET_XMIT_STOLEN = NET_XMIT_MASK + 1,
+	__NET_XMIT_STOLEN = 0x0001FFFF,
+	__NET_XMIT_BYPASS = 0x0002FFFF,
 };
 
+#ifdef CONFIG_NET_CLS_ACT
 #define net_xmit_drop_count(e)	((e) & __NET_XMIT_STOLEN ? 0 : 1)
-
 #else
 #define net_xmit_drop_count(e)	(1)
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index 69320a5..e670504 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1805,7 +1805,6 @@ gso:
 
 		spin_unlock(root_lock);
 
-		rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
 		goto out;
 	}
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 27dd773..43d3725 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -457,7 +457,7 @@ drop: __maybe_unused
 		return 0;
 	}
 	tasklet_schedule(&p->task);
-	return NET_XMIT_BYPASS;
+	return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 }
 
 /*
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 765ae56..4e261ce 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -230,7 +230,7 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	    (cl = cbq_class_lookup(q, prio)) != NULL)
 		return cl;
 
-	*qerr = NET_XMIT_BYPASS;
+	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	for (;;) {
 		int result = 0;
 		defmap = head->defaults;
@@ -377,7 +377,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	q->rx_class = cl;
 #endif
 	if (cl == NULL) {
-		if (ret == NET_XMIT_BYPASS)
+		if (ret & __NET_XMIT_BYPASS)
 			sch->qstats.drops++;
 		kfree_skb(skb);
 		return ret;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 7170275..edd1298 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -268,7 +268,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 drop:
 	kfree_skb(skb);
 	sch->qstats.drops++;
-	return NET_XMIT_BYPASS;
+	return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 }
 
 static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 5cf9ae7..c2b8d9c 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1159,7 +1159,7 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		if (cl->level == 0)
 			return cl;
 
-	*qerr = NET_XMIT_BYPASS;
+	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	tcf = q->root.filter_list;
 	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
@@ -1578,7 +1578,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	cl = hfsc_classify(skb, sch, &err);
 	if (cl == NULL) {
-		if (err == NET_XMIT_BYPASS)
+		if (err & __NET_XMIT_BYPASS)
 			sch->qstats.drops++;
 		kfree_skb(skb);
 		return err;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 538d79b..be35422 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -214,7 +214,7 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 	if ((cl = htb_find(skb->priority, sch)) != NULL && cl->level == 0)
 		return cl;
 
-	*qerr = NET_XMIT_BYPASS;
+	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	tcf = q->filter_list;
 	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
@@ -567,7 +567,7 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 #ifdef CONFIG_NET_CLS_ACT
 	} else if (!cl) {
-		if (ret == NET_XMIT_BYPASS)
+		if (ret & __NET_XMIT_BYPASS)
 			sch->qstats.drops++;
 		kfree_skb(skb);
 		return ret;
@@ -612,7 +612,7 @@ static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 #ifdef CONFIG_NET_CLS_ACT
 	} else if (!cl) {
-		if (ret == NET_XMIT_BYPASS)
+		if (ret & __NET_XMIT_BYPASS)
 			sch->qstats.drops++;
 		kfree_skb(skb);
 		return ret;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 6cd6f2b..fb0294d 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -176,7 +176,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (count == 0) {
 		sch->qstats.drops++;
 		kfree_skb(skb);
-		return NET_XMIT_BYPASS;
+		return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	}
 
 	skb_orphan(skb);
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index adb1a52..eac1976 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -38,7 +38,7 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	struct tcf_result res;
 	int err;
 
-	*qerr = NET_XMIT_BYPASS;
+	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	if (TC_H_MAJ(skb->priority) != sch->handle) {
 		err = tc_classify(skb, q->filter_list, &res);
 #ifdef CONFIG_NET_CLS_ACT
@@ -74,7 +74,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 #ifdef CONFIG_NET_CLS_ACT
 	if (qdisc == NULL) {
 
-		if (ret == NET_XMIT_BYPASS)
+		if (ret & __NET_XMIT_BYPASS)
 			sch->qstats.drops++;
 		kfree_skb(skb);
 		return ret;
@@ -103,7 +103,7 @@ prio_requeue(struct sk_buff *skb, struct Qdisc* sch)
 	qdisc = prio_classify(skb, sch, &ret);
 #ifdef CONFIG_NET_CLS_ACT
 	if (qdisc == NULL) {
-		if (ret == NET_XMIT_BYPASS)
+		if (ret & __NET_XMIT_BYPASS)
 			sch->qstats.drops++;
 		kfree_skb(skb);
 		return ret;
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 3a456e1..6e041d1 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -171,7 +171,7 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 	if (!q->filter_list)
 		return sfq_hash(q, skb) + 1;
 
-	*qerr = NET_XMIT_BYPASS;
+	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	result = tc_classify(skb, q->filter_list, &res);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
@@ -285,7 +285,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	hash = sfq_classify(skb, sch, &ret);
 	if (hash == 0) {
-		if (ret == NET_XMIT_BYPASS)
+		if (ret & __NET_XMIT_BYPASS)
 			sch->qstats.drops++;
 		kfree_skb(skb);
 		return ret;
@@ -339,7 +339,7 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 
 	hash = sfq_classify(skb, sch, &ret);
 	if (hash == 0) {
-		if (ret == NET_XMIT_BYPASS)
+		if (ret & __NET_XMIT_BYPASS)
 			sch->qstats.drops++;
 		kfree_skb(skb);
 		return ret;
