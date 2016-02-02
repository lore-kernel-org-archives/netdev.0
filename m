From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 03/10] tipc: remove struct
	tipc_name_seq from struct tipc_subscription
Date: Tue, 2 Feb 2016 10:52:10 +0100
Message-ID: <1454406737-5806-4-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1454406737-5806-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1454406737-5806-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Until now, struct tipc_subscriber has duplicate fields for
type, upper and lower (as member of struct tipc_name_seq) at:
1. as member seq in struct tipc_subscription
2. as member seq in struct tipc_subscr, which is contained
   in struct tipc_event
The former structure contains the type, upper and lower
values in network byte order and the later contains the
intact copy of the request.
The struct tipc_subscription contains a field swap to
determine if request needs network byte order conversion.
Thus by using swap, we can convert the request when
required instead of duplicating it.

In this commit,
1. we remove the references to these elements as members of
   struct tipc_subscription and replace them with elements
   from struct tipc_subscr.
2. provide new functions to convert the user request into
   network byte order.

Acked-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/name_table.c | 14 ++++++++++----
 net/tipc/subscr.c     | 33 +++++++++++++++++++++++----------
 net/tipc/subscr.h     |  6 ++++--
 3 files changed, 37 insertions(+), 16 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 91fce70291a8..777b979b8463 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -418,6 +418,9 @@ static void tipc_nameseq_subscribe(struct name_seq *nseq,
 				   struct tipc_subscription *s)
 {
 	struct sub_seq *sseq = nseq->sseqs;
+	struct tipc_name_seq ns;
+
+	tipc_subscrp_convert_seq(&s->evt.s.seq, s->swap, &ns);
 
 	list_add(&s->nameseq_list, &nseq->subscriptions);
 
@@ -425,7 +428,7 @@ static void tipc_nameseq_subscribe(struct name_seq *nseq,
 		return;
 
 	while (sseq != &nseq->sseqs[nseq->first_free]) {
-		if (tipc_subscrp_check_overlap(s, sseq->lower, sseq->upper)) {
+		if (tipc_subscrp_check_overlap(&ns, sseq->lower, sseq->upper)) {
 			struct publication *crs;
 			struct name_info *info = sseq->info;
 			int must_report = 1;
@@ -722,9 +725,10 @@ int tipc_nametbl_withdraw(struct net *net, u32 type, u32 lower, u32 ref,
 void tipc_nametbl_subscribe(struct tipc_subscription *s)
 {
 	struct tipc_net *tn = net_generic(s->net, tipc_net_id);
-	u32 type = s->seq.type;
+	u32 type = tipc_subscrp_convert_seq_type(s->evt.s.seq.type, s->swap);
 	int index = hash(type);
 	struct name_seq *seq;
+	struct tipc_name_seq ns;
 
 	spin_lock_bh(&tn->nametbl_lock);
 	seq = nametbl_find_seq(s->net, type);
@@ -735,8 +739,9 @@ void tipc_nametbl_subscribe(struct tipc_subscription *s)
 		tipc_nameseq_subscribe(seq, s);
 		spin_unlock_bh(&seq->lock);
 	} else {
+		tipc_subscrp_convert_seq(&s->evt.s.seq, s->swap, &ns);
 		pr_warn("Failed to create subscription for {%u,%u,%u}\n",
-			s->seq.type, s->seq.lower, s->seq.upper);
+			ns.type, ns.lower, ns.upper);
 	}
 	spin_unlock_bh(&tn->nametbl_lock);
 }
@@ -748,9 +753,10 @@ void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 {
 	struct tipc_net *tn = net_generic(s->net, tipc_net_id);
 	struct name_seq *seq;
+	u32 type = tipc_subscrp_convert_seq_type(s->evt.s.seq.type, s->swap);
 
 	spin_lock_bh(&tn->nametbl_lock);
-	seq = nametbl_find_seq(s->net, s->seq.type);
+	seq = nametbl_find_seq(s->net, type);
 	if (seq != NULL) {
 		spin_lock_bh(&seq->lock);
 		list_del_init(&s->nameseq_list);
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index fb8406573f30..702a81d8dbb6 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -92,23 +92,39 @@ static void tipc_subscrp_send_event(struct tipc_subscription *sub,
  *
  * Returns 1 if there is overlap, otherwise 0.
  */
-int tipc_subscrp_check_overlap(struct tipc_subscription *sub, u32 found_lower,
+int tipc_subscrp_check_overlap(struct tipc_name_seq *seq, u32 found_lower,
 			       u32 found_upper)
 {
-	if (found_lower < sub->seq.lower)
-		found_lower = sub->seq.lower;
-	if (found_upper > sub->seq.upper)
-		found_upper = sub->seq.upper;
+	if (found_lower < seq->lower)
+		found_lower = seq->lower;
+	if (found_upper > seq->upper)
+		found_upper = seq->upper;
 	if (found_lower > found_upper)
 		return 0;
 	return 1;
 }
 
+u32 tipc_subscrp_convert_seq_type(u32 type, int swap)
+{
+	return htohl(type, swap);
+}
+
+void tipc_subscrp_convert_seq(struct tipc_name_seq *in, int swap,
+			      struct tipc_name_seq *out)
+{
+	out->type = htohl(in->type, swap);
+	out->lower = htohl(in->lower, swap);
+	out->upper = htohl(in->upper, swap);
+}
+
 void tipc_subscrp_report_overlap(struct tipc_subscription *sub, u32 found_lower,
 				 u32 found_upper, u32 event, u32 port_ref,
 				 u32 node, int must)
 {
-	if (!tipc_subscrp_check_overlap(sub, found_lower, found_upper))
+	struct tipc_name_seq seq;
+
+	tipc_subscrp_convert_seq(&sub->evt.s.seq, sub->swap, &seq);
+	if (!tipc_subscrp_check_overlap(&seq, found_lower, found_upper))
 		return;
 	if (!must &&
 	    !(htohl(sub->evt.s.filter, sub->swap) & TIPC_SUB_PORTS))
@@ -252,12 +268,9 @@ static int tipc_subscrp_create(struct net *net, struct tipc_subscr *s,
 
 	/* Initialize subscription object */
 	sub->net = net;
-	sub->seq.type = htohl(s->seq.type, swap);
-	sub->seq.lower = htohl(s->seq.lower, swap);
-	sub->seq.upper = htohl(s->seq.upper, swap);
 	filter = htohl(s->filter, swap);
 	if (((filter & TIPC_SUB_PORTS) && (filter & TIPC_SUB_SERVICE)) ||
-	    (sub->seq.lower > sub->seq.upper)) {
+	    (htohl(s->seq.lower, swap) > htohl(s->seq.upper, swap))) {
 		pr_warn("Subscription rejected, illegal request\n");
 		kfree(sub);
 		return -EINVAL;
diff --git a/net/tipc/subscr.h b/net/tipc/subscr.h
index 9e69dbf05626..be60103082c9 100644
--- a/net/tipc/subscr.h
+++ b/net/tipc/subscr.h
@@ -58,7 +58,6 @@ struct tipc_subscriber;
  */
 struct tipc_subscription {
 	struct tipc_subscriber *subscriber;
-	struct tipc_name_seq seq;
 	struct net *net;
 	struct timer_list timer;
 	struct list_head nameseq_list;
@@ -67,11 +66,14 @@ struct tipc_subscription {
 	struct tipc_event evt;
 };
 
-int tipc_subscrp_check_overlap(struct tipc_subscription *sub, u32 found_lower,
+int tipc_subscrp_check_overlap(struct tipc_name_seq *seq, u32 found_lower,
 			       u32 found_upper);
 void tipc_subscrp_report_overlap(struct tipc_subscription *sub,
 				 u32 found_lower, u32 found_upper, u32 event,
 				 u32 port_ref, u32 node, int must);
+void tipc_subscrp_convert_seq(struct tipc_name_seq *in, int swap,
+			      struct tipc_name_seq *out);
+u32 tipc_subscrp_convert_seq_type(u32 type, int swap);
 int tipc_topsrv_start(struct net *net);
 void tipc_topsrv_stop(struct net *net);
 
-- 
2.1.4


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=267308311&iu=/4140
