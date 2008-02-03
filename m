From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][NET_SCHED] sch_tree_lock in cbq_put, hfsc_put_class and
	htb_put
Date: Sun, 3 Feb 2008 15:52:34 +0100
Message-ID: <20080203145234.GA3170@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	jamal <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.226]:43067 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762803AbYBCOt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 09:49:56 -0500
Received: by hu-out-0506.google.com with SMTP id 19so1660476hue.21
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2008 06:49:53 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED] sch_tree_lock in cbq_put, hfsc_put_class and htb_put

Qdisc_class_ops ->put() "methods" call xxx_destroy_class() functions
without sch_tree_lock(), which is needed at least for qdisc_destroy()
of a subqueue, but also for deactivating and list/rb_tree updates in
case of HTB. (Since errors caused by such a bug could be very hard to
reproduce the effectiveness of this patch wasn't confirmed by tests,
but IMHO the need of this lock is quite obvious here.)

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
 
---

 net/sched/sch_cbq.c  |   14 ++++++++------
 net/sched/sch_hfsc.c |    5 ++++-
 net/sched/sch_htb.c  |    5 ++++-
 3 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 09969c1..bbf47fe 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1748,16 +1748,18 @@ static void cbq_put(struct Qdisc *sch, unsigned long arg)
 	struct cbq_class *cl = (struct cbq_class*)arg;
 
 	if (--cl->refcnt == 0) {
+		sch_tree_lock(sch);
 #ifdef CONFIG_NET_CLS_ACT
-		struct cbq_sched_data *q = qdisc_priv(sch);
+		{
+			struct cbq_sched_data *q = qdisc_priv(sch);
 
-		spin_lock_bh(&sch->dev->queue_lock);
-		if (q->rx_class == cl)
-			q->rx_class = NULL;
-		spin_unlock_bh(&sch->dev->queue_lock);
+			if (q->rx_class == cl)
+				q->rx_class = NULL;
+		}
 #endif
 
 		cbq_destroy_class(sch, cl);
+		sch_tree_unlock(sch);
 	}
 }
 
@@ -1965,10 +1967,10 @@ static int cbq_delete(struct Qdisc *sch, unsigned long arg)
 	cbq_sync_defmap(cl);
 
 	cbq_rmprio(q, cl);
-	sch_tree_unlock(sch);
 
 	if (--cl->refcnt == 0)
 		cbq_destroy_class(sch, cl);
+	sch_tree_unlock(sch);
 
 	return 0;
 }
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 87293d0..494d042 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1262,8 +1262,11 @@ hfsc_put_class(struct Qdisc *sch, unsigned long arg)
 {
 	struct hfsc_class *cl = (struct hfsc_class *)arg;
 
-	if (--cl->refcnt == 0)
+	if (--cl->refcnt == 0) {
+		sch_tree_lock(sch);
 		hfsc_destroy_class(sch, cl);
+		sch_tree_unlock(sch);
+	}
 }
 
 static unsigned long
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index e1a579e..268a2d1 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1305,8 +1305,11 @@ static void htb_put(struct Qdisc *sch, unsigned long arg)
 {
 	struct htb_class *cl = (struct htb_class *)arg;
 
-	if (--cl->refcnt == 0)
+	if (--cl->refcnt == 0) {
+		sch_tree_lock(sch);
 		htb_destroy_class(sch, cl);
+		sch_tree_unlock(sch);
+	}
 }
 
 static int htb_change_class(struct Qdisc *sch, u32 classid,
