From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH 2/2] net_sched/hfsc: opencode trivial set_active() and
 set_passive()
Date: Tue, 15 Aug 2017 16:40:03 +0300
Message-ID: <150280440342.717891.16424904669818880087.stgit@buzz>
References: <150280439968.717891.6476652519937001709.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jkosina@suse.cz>, Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1g.cmail.yandex.net ([87.250.241.190]:38428 "EHLO
        forwardcorp1g.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750827AbdHONrF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 09:47:05 -0400
In-Reply-To: <150280439968.717891.6476652519937001709.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any move comment abount update_vf() into right place.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 net/sched/sch_hfsc.c |   45 ++++++++++++++++-----------------------------
 1 file changed, 16 insertions(+), 29 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 14c99870cdb6..15f09cb9f1ff 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -829,28 +829,6 @@ update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
 	}
 }
 
-static void
-set_active(struct hfsc_class *cl, unsigned int len)
-{
-	if (cl->cl_flags & HFSC_RSC)
-		init_ed(cl, len);
-	if (cl->cl_flags & HFSC_FSC)
-		init_vf(cl, len);
-
-}
-
-static void
-set_passive(struct hfsc_class *cl)
-{
-	if (cl->cl_flags & HFSC_RSC)
-		eltree_remove(cl);
-
-	/*
-	 * vttree is now handled in update_vf() so that update_vf(cl, 0, 0)
-	 * needs to be called explicitly to remove a class from vttree.
-	 */
-}
-
 static unsigned int
 qdisc_peek_len(struct Qdisc *sch)
 {
@@ -1221,8 +1199,12 @@ hfsc_qlen_notify(struct Qdisc *sch, unsigned long arg)
 {
 	struct hfsc_class *cl = (struct hfsc_class *)arg;
 
+	/* vttree is now handled in update_vf() so that update_vf(cl, 0, 0)
+	 * needs to be called explicitly to remove a class from vttree.
+	 */
 	update_vf(cl, 0, 0);
-	set_passive(cl);
+	if (cl->cl_flags & HFSC_RSC)
+		eltree_remove(cl);
 }
 
 static unsigned long
@@ -1583,7 +1565,12 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch, struct sk_buff **to_free)
 	}
 
 	if (cl->qdisc->q.qlen == 1) {
-		set_active(cl, qdisc_pkt_len(skb));
+		unsigned int len = qdisc_pkt_len(skb);
+
+		if (cl->cl_flags & HFSC_RSC)
+			init_ed(cl, len);
+		if (cl->cl_flags & HFSC_FSC)
+			init_vf(cl, len);
 		/*
 		 * If this is the first packet, isolate the head so an eventual
 		 * head drop before the first dequeue operation has no chance
@@ -1647,18 +1634,18 @@ hfsc_dequeue(struct Qdisc *sch)
 	if (realtime)
 		cl->cl_cumul += qdisc_pkt_len(skb);
 
-	if (cl->qdisc->q.qlen != 0) {
-		if (cl->cl_flags & HFSC_RSC) {
+	if (cl->cl_flags & HFSC_RSC) {
+		if (cl->qdisc->q.qlen != 0) {
 			/* update ed */
 			next_len = qdisc_peek_len(cl->qdisc);
 			if (realtime)
 				update_ed(cl, next_len);
 			else
 				update_d(cl, next_len);
+		} else {
+			/* the class becomes passive */
+			eltree_remove(cl);
 		}
-	} else {
-		/* the class becomes passive */
-		set_passive(cl);
 	}
 
 	qdisc_bstats_update(sch, skb);
