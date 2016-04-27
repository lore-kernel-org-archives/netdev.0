From: Michal Kazior <michal.kazior@tieto.com>
Subject: [PATCH] fq: split out backlog update logic
Date: Wed, 27 Apr 2016 12:59:13 +0200
Message-ID: <1461754753-18051-1-git-send-email-michal.kazior@tieto.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
	Michal Kazior <michal.kazior@tieto.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34952 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753117AbcD0K5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 06:57:19 -0400
Received: by mail-lf0-f47.google.com with SMTP id c126so51764531lfb.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 03:57:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mac80211 (which will be the first user of the
fq.h) recently started to support software A-MSDU
aggregation. It glues skbuffs together into a
single one so the backlog accounting needs to be
more fine-grained.

To avoid backlog sorting logic duplication split
it up for re-use.

Signed-off-by: Michal Kazior <michal.kazior@tieto.com>
---

While preparing a re-spin of fq_codel for
mac80211-next/master I've noticed that it's
current head has the new software A-MSDU
aggregation.

I'm aware I just recently submitted fq.h.

Sorry for the noise!


 include/net/fq_impl.h | 30 +++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/include/net/fq_impl.h b/include/net/fq_impl.h
index 02eab7c51adb..163f3ed0f05a 100644
--- a/include/net/fq_impl.h
+++ b/include/net/fq_impl.h
@@ -120,6 +120,24 @@ static struct fq_flow *fq_flow_classify(struct fq *fq,
 	return flow;
 }
 
+static void fq_recalc_backlog(struct fq *fq,
+			      struct fq_tin *tin,
+			      struct fq_flow *flow)
+{
+	struct fq_flow *i;
+
+	if (list_empty(&flow->backlogchain))
+		list_add_tail(&flow->backlogchain, &fq->backlogs);
+
+	i = flow;
+	list_for_each_entry_continue_reverse(i, &fq->backlogs,
+					     backlogchain)
+		if (i->backlog > flow->backlog)
+			break;
+
+	list_move(&flow->backlogchain, &i->backlogchain);
+}
+
 static void fq_tin_enqueue(struct fq *fq,
 			   struct fq_tin *tin,
 			   struct sk_buff *skb,
@@ -127,7 +145,6 @@ static void fq_tin_enqueue(struct fq *fq,
 			   fq_flow_get_default_t get_default_func)
 {
 	struct fq_flow *flow;
-	struct fq_flow *i;
 
 	lockdep_assert_held(&fq->lock);
 
@@ -139,16 +156,7 @@ static void fq_tin_enqueue(struct fq *fq,
 	tin->backlog_packets++;
 	fq->backlog++;
 
-	if (list_empty(&flow->backlogchain))
-		list_add_tail(&flow->backlogchain, &fq->backlogs);
-
-	i = flow;
-	list_for_each_entry_continue_reverse(i, &fq->backlogs,
-					     backlogchain)
-		if (i->backlog > flow->backlog)
-			break;
-
-	list_move(&flow->backlogchain, &i->backlogchain);
+	fq_recalc_backlog(fq, tin, flow);
 
 	if (list_empty(&flow->flowchain)) {
 		flow->deficit = fq->quantum;
-- 
2.1.4
