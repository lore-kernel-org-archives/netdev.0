From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 04/10] tipc: introduce
	tipc_subscrb_subscribe() routine
Date: Mon, 1 Feb 2016 10:44:37 +0100
Message-ID: <1454319883-16031-5-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1454319883-16031-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1454319883-16031-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In this commit, we split tipc_subscrp_create() into two:
1. tipc_subscrp_create() creates a subscription
2. A new function tipc_subscrp_subscribe() adds the
   subscription to the subscriber subscription list,
   activates the subscription timer and subscribes to
   the nametable updates.

In future commits, the purpose of tipc_subscrb_rcv_cb() will
be to either subscribe or cancel a subscription.

There is no functional change in this commit.

Acked-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/subscr.c | 55 +++++++++++++++++++++++++++++++------------------------
 1 file changed, 31 insertions(+), 24 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 702a81d8dbb6..022a2f21be04 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -233,13 +233,13 @@ static void tipc_subscrp_cancel(struct tipc_subscr *s,
 	spin_unlock_bh(&subscriber->lock);
 }
 
-static int tipc_subscrp_create(struct net *net, struct tipc_subscr *s,
-			       struct tipc_subscriber *subscriber,
-			       struct tipc_subscription **sub_p)
+static struct tipc_subscription *tipc_subscrp_create(struct net *net,
+						     struct tipc_subscr *s,
+						     struct tipc_subscriber *subscriber)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_subscription *sub;
-	u32 timeout, filter;
+	u32 filter;
 	int swap;
 
 	/* Determine subscriber's endianness */
@@ -249,21 +249,21 @@ static int tipc_subscrp_create(struct net *net, struct tipc_subscr *s,
 	if (s->filter & htohl(TIPC_SUB_CANCEL, swap)) {
 		s->filter &= ~htohl(TIPC_SUB_CANCEL, swap);
 		tipc_subscrp_cancel(s, subscriber);
-		return 0;
+		return NULL;
 	}
 
 	/* Refuse subscription if global limit exceeded */
 	if (atomic_read(&tn->subscription_count) >= TIPC_MAX_SUBSCRIPTIONS) {
 		pr_warn("Subscription rejected, limit reached (%u)\n",
 			TIPC_MAX_SUBSCRIPTIONS);
-		return -EINVAL;
+		return NULL;
 	}
 
 	/* Allocate subscription object */
 	sub = kmalloc(sizeof(*sub), GFP_ATOMIC);
 	if (!sub) {
 		pr_warn("Subscription rejected, no memory\n");
-		return -ENOMEM;
+		return NULL;
 	}
 
 	/* Initialize subscription object */
@@ -273,22 +273,36 @@ static int tipc_subscrp_create(struct net *net, struct tipc_subscr *s,
 	    (htohl(s->seq.lower, swap) > htohl(s->seq.upper, swap))) {
 		pr_warn("Subscription rejected, illegal request\n");
 		kfree(sub);
-		return -EINVAL;
+		return NULL;
 	}
-	spin_lock_bh(&subscriber->lock);
-	list_add(&sub->subscrp_list, &subscriber->subscrp_list);
-	spin_unlock_bh(&subscriber->lock);
 
-	sub->subscriber = subscriber;
 	sub->swap = swap;
 	memcpy(&sub->evt.s, s, sizeof(*s));
 	atomic_inc(&tn->subscription_count);
 	setup_timer(&sub->timer, tipc_subscrp_timeout, (unsigned long)sub);
-	timeout = htohl(sub->evt.s.timeout, swap);
+	return sub;
+}
+
+static void tipc_subscrp_subscribe(struct net *net, struct tipc_subscr *s,
+				   struct tipc_subscriber *subscriber)
+{
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_subscription *sub = NULL;
+	u32 timeout;
+
+	sub = tipc_subscrp_create(net, s, subscriber);
+	if (!sub)
+		return tipc_conn_terminate(tn->topsrv, subscriber->conid);
+
+	spin_lock_bh(&subscriber->lock);
+	list_add(&sub->subscrp_list, &subscriber->subscrp_list);
+	spin_unlock_bh(&subscriber->lock);
+
+	sub->subscriber = subscriber;
+	timeout = htohl(sub->evt.s.timeout, sub->swap);
 	if (!mod_timer(&sub->timer, jiffies + msecs_to_jiffies(timeout)))
 		tipc_subscrb_get(subscriber);
-	*sub_p = sub;
-	return 0;
+	tipc_nametbl_subscribe(sub);
 }
 
 /* Handle one termination request for the subscriber */
@@ -302,15 +316,8 @@ static void tipc_subscrb_rcv_cb(struct net *net, int conid,
 				struct sockaddr_tipc *addr, void *usr_data,
 				void *buf, size_t len)
 {
-	struct tipc_subscriber *subscriber = usr_data;
-	struct tipc_subscription *sub = NULL;
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-
-	tipc_subscrp_create(net, (struct tipc_subscr *)buf, subscriber, &sub);
-	if (sub)
-		tipc_nametbl_subscribe(sub);
-	else
-		tipc_conn_terminate(tn->topsrv, subscriber->conid);
+	tipc_subscrp_subscribe(net, (struct tipc_subscr *)buf,
+			       (struct tipc_subscriber *)usr_data);
 }
 
 /* Handle one request to establish a new subscriber */
-- 
2.1.4


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=267308311&iu=/4140
