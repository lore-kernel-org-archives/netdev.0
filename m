From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/2] net_sched: sfq: fix mem alloc error recovery
Date: Wed, 04 Jan 2012 17:22:24 +0100
Message-ID: <1325694144.2428.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:59286 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756103Ab2ADQW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 11:22:28 -0500
Received: by werm1 with SMTP id m1so8671043wer.19
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2012 08:22:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 817fb15dfd98 (net_sched: sfq: allow divisor to be a
parameter), we can leave perturbation timer armed if a memory allocation
error aborts sfq_init().

Memory containing active struct timer_list is freed and kernel can
crash.

Call sfq_destroy() from sfq_init() to properly dismantle qdisc.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_sfq.c |   52 ++++++++++++++++++++++++++----------------
 1 file changed, 33 insertions(+), 19 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index f7f62a5..465af66 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -544,10 +544,38 @@ static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
 	return 0;
 }
 
+static void *sfq_alloc(size_t sz)
+{
+	void *ptr = kmalloc(sz, GFP_KERNEL | __GFP_NOWARN);
+
+	if (!ptr)
+		ptr = vmalloc(sz);
+	return ptr;
+}
+
+static void sfq_free(void *addr)
+{
+	if (addr) {
+		if (is_vmalloc_addr(addr))
+			vfree(addr);
+		else
+			kfree(addr);
+	}
+}
+
+static void sfq_destroy(struct Qdisc *sch)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+
+	tcf_destroy_chain(&q->filter_list);
+	q->perturb_period = 0;
+	del_timer_sync(&q->perturb_timer);
+	sfq_free(q->ht);
+}
+
 static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	size_t sz;
 	int i;
 
 	q->perturb_timer.function = sfq_perturbation;
@@ -574,12 +602,11 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 			return err;
 	}
 
-	sz = sizeof(q->ht[0]) * q->divisor;
-	q->ht = kmalloc(sz, GFP_KERNEL);
-	if (!q->ht && sz > PAGE_SIZE)
-		q->ht = vmalloc(sz);
-	if (!q->ht)
+	q->ht = sfq_alloc(sizeof(q->ht[0]) * q->divisor);
+	if (!q->ht) {
+		sfq_destroy(sch);
 		return -ENOMEM;
+	}
 	for (i = 0; i < q->divisor; i++)
 		q->ht[i] = SFQ_EMPTY_SLOT;
 
@@ -594,19 +621,6 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	return 0;
 }
 
-static void sfq_destroy(struct Qdisc *sch)
-{
-	struct sfq_sched_data *q = qdisc_priv(sch);
-
-	tcf_destroy_chain(&q->filter_list);
-	q->perturb_period = 0;
-	del_timer_sync(&q->perturb_timer);
-	if (is_vmalloc_addr(q->ht))
-		vfree(q->ht);
-	else
-		kfree(q->ht);
-}
-
 static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
