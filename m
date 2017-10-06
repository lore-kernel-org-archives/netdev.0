From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 1/2] fq: support filtering a given tin
Date: Fri,  6 Oct 2017 11:53:32 +0200
Message-ID: <20171006095333.26335-1-johannes@sipsolutions.net>
Cc: =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke-LJ9M9ZcSy1A@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        =?UTF-8?q?Micha=C5=82=20Kazior?= <kazikcz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Add to the FQ API a way to filter a given tin, in order to
remove frames that fulfil certain criteria according to a
filter function.

This will be used by mac80211 to remove frames belonging to
an AP VLAN interface that's being removed.

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/net/fq.h      |  7 +++++
 include/net/fq_impl.h | 72 ++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 69 insertions(+), 10 deletions(-)

diff --git a/include/net/fq.h b/include/net/fq.h
index 6d8521a30c5c..ac944a686840 100644
--- a/include/net/fq.h
+++ b/include/net/fq.h
@@ -90,6 +90,13 @@ typedef void fq_skb_free_t(struct fq *,
 			   struct fq_flow *,
 			   struct sk_buff *);
 
+/* Return %true to filter (drop) the frame. */
+typedef bool fq_skb_filter_t(struct fq *,
+			     struct fq_tin *,
+			     struct fq_flow *,
+			     struct sk_buff *,
+			     void *);
+
 typedef struct fq_flow *fq_flow_get_default_t(struct fq *,
 					      struct fq_tin *,
 					      int idx,
diff --git a/include/net/fq_impl.h b/include/net/fq_impl.h
index 4e6131cd3f43..8b237e4afee6 100644
--- a/include/net/fq_impl.h
+++ b/include/net/fq_impl.h
@@ -12,24 +12,22 @@
 
 /* functions that are embedded into includer */
 
-static struct sk_buff *fq_flow_dequeue(struct fq *fq,
-				       struct fq_flow *flow)
+static void fq_adjust_removal(struct fq *fq,
+			      struct fq_flow *flow,
+			      struct sk_buff *skb)
 {
 	struct fq_tin *tin = flow->tin;
-	struct fq_flow *i;
-	struct sk_buff *skb;
-
-	lockdep_assert_held(&fq->lock);
-
-	skb = __skb_dequeue(&flow->queue);
-	if (!skb)
-		return NULL;
 
 	tin->backlog_bytes -= skb->len;
 	tin->backlog_packets--;
 	flow->backlog -= skb->len;
 	fq->backlog--;
 	fq->memory_usage -= skb->truesize;
+}
+
+static void fq_rejigger_backlog(struct fq *fq, struct fq_flow *flow)
+{
+	struct fq_flow *i;
 
 	if (flow->backlog == 0) {
 		list_del_init(&flow->backlogchain);
@@ -43,6 +41,21 @@ static struct sk_buff *fq_flow_dequeue(struct fq *fq,
 		list_move_tail(&flow->backlogchain,
 			       &i->backlogchain);
 	}
+}
+
+static struct sk_buff *fq_flow_dequeue(struct fq *fq,
+				       struct fq_flow *flow)
+{
+	struct sk_buff *skb;
+
+	lockdep_assert_held(&fq->lock);
+
+	skb = __skb_dequeue(&flow->queue);
+	if (!skb)
+		return NULL;
+
+	fq_adjust_removal(fq, flow, skb);
+	fq_rejigger_backlog(fq, flow);
 
 	return skb;
 }
@@ -188,6 +201,45 @@ static void fq_tin_enqueue(struct fq *fq,
 	}
 }
 
+static void fq_flow_filter(struct fq *fq,
+			   struct fq_flow *flow,
+			   fq_skb_filter_t filter_func,
+			   void *filter_data,
+			   fq_skb_free_t free_func)
+{
+	struct fq_tin *tin = flow->tin;
+	struct sk_buff *skb, *tmp;
+
+	lockdep_assert_held(&fq->lock);
+
+	skb_queue_walk_safe(&flow->queue, skb, tmp) {
+		if (!filter_func(fq, tin, flow, skb, filter_data))
+			continue;
+
+		__skb_unlink(skb, &flow->queue);
+		fq_adjust_removal(fq, flow, skb);
+		free_func(fq, tin, flow, skb);
+	}
+
+	fq_rejigger_backlog(fq, flow);
+}
+
+static void fq_tin_filter(struct fq *fq,
+			  struct fq_tin *tin,
+			  fq_skb_filter_t filter_func,
+			  void *filter_data,
+			  fq_skb_free_t free_func)
+{
+	struct fq_flow *flow;
+
+	lockdep_assert_held(&fq->lock);
+
+	list_for_each_entry(flow, &tin->new_flows, flowchain)
+		fq_flow_filter(fq, flow, filter_func, filter_data, free_func);
+	list_for_each_entry(flow, &tin->old_flows, flowchain)
+		fq_flow_filter(fq, flow, filter_func, filter_data, free_func);
+}
+
 static void fq_flow_reset(struct fq *fq,
 			  struct fq_flow *flow,
 			  fq_skb_free_t free_func)
-- 
2.14.2
