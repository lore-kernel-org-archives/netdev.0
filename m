From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 05/10] tipc: fix connection
	abort during subscription cancellation
Date: Mon, 1 Feb 2016 10:44:38 +0100
Message-ID: <1454319883-16031-6-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

In 'commit 7fe8097cef5f ("tipc: fix nullpointer bug when subscribing
to events")', we terminate the connection if the subscription
creation fails.
In the same commit, the subscription creation result was based on
the value of subscription pointer (set in the function) instead of
the return code.

Unfortunately, the same function also handles subscription
cancellation request. For a subscription cancellation request,
the subscription pointer cannot be set. Thus the connection is
terminated during cancellation request.

In this commit, we move the subcription cancel check outside
of tipc_subscrp_create(). Hence,
- tipc_subscrp_create() will create a subscripton
- tipc_subscrb_rcv_cb() will subscribe or cancel a subscription.

Fixes: 'commit 7fe8097cef5f ("tipc: fix nullpointer bug when subscribing to events")'

Acked-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/subscr.c | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 022a2f21be04..531227208ae2 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -235,22 +235,11 @@ static void tipc_subscrp_cancel(struct tipc_subscr *s,
 
 static struct tipc_subscription *tipc_subscrp_create(struct net *net,
 						     struct tipc_subscr *s,
-						     struct tipc_subscriber *subscriber)
+						     int swap)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_subscription *sub;
-	u32 filter;
-	int swap;
-
-	/* Determine subscriber's endianness */
-	swap = !(s->filter & (TIPC_SUB_PORTS | TIPC_SUB_SERVICE));
-
-	/* Detect & process a subscription cancellation request */
-	if (s->filter & htohl(TIPC_SUB_CANCEL, swap)) {
-		s->filter &= ~htohl(TIPC_SUB_CANCEL, swap);
-		tipc_subscrp_cancel(s, subscriber);
-		return NULL;
-	}
+	u32 filter = htohl(s->filter, swap);
 
 	/* Refuse subscription if global limit exceeded */
 	if (atomic_read(&tn->subscription_count) >= TIPC_MAX_SUBSCRIPTIONS) {
@@ -268,7 +257,6 @@ static struct tipc_subscription *tipc_subscrp_create(struct net *net,
 
 	/* Initialize subscription object */
 	sub->net = net;
-	filter = htohl(s->filter, swap);
 	if (((filter & TIPC_SUB_PORTS) && (filter & TIPC_SUB_SERVICE)) ||
 	    (htohl(s->seq.lower, swap) > htohl(s->seq.upper, swap))) {
 		pr_warn("Subscription rejected, illegal request\n");
@@ -284,13 +272,13 @@ static struct tipc_subscription *tipc_subscrp_create(struct net *net,
 }
 
 static void tipc_subscrp_subscribe(struct net *net, struct tipc_subscr *s,
-				   struct tipc_subscriber *subscriber)
+				   struct tipc_subscriber *subscriber, int swap)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_subscription *sub = NULL;
 	u32 timeout;
 
-	sub = tipc_subscrp_create(net, s, subscriber);
+	sub = tipc_subscrp_create(net, s, swap);
 	if (!sub)
 		return tipc_conn_terminate(tn->topsrv, subscriber->conid);
 
@@ -299,7 +287,7 @@ static void tipc_subscrp_subscribe(struct net *net, struct tipc_subscr *s,
 	spin_unlock_bh(&subscriber->lock);
 
 	sub->subscriber = subscriber;
-	timeout = htohl(sub->evt.s.timeout, sub->swap);
+	timeout = htohl(sub->evt.s.timeout, swap);
 	if (!mod_timer(&sub->timer, jiffies + msecs_to_jiffies(timeout)))
 		tipc_subscrb_get(subscriber);
 	tipc_nametbl_subscribe(sub);
@@ -316,8 +304,20 @@ static void tipc_subscrb_rcv_cb(struct net *net, int conid,
 				struct sockaddr_tipc *addr, void *usr_data,
 				void *buf, size_t len)
 {
-	tipc_subscrp_subscribe(net, (struct tipc_subscr *)buf,
-			       (struct tipc_subscriber *)usr_data);
+	struct tipc_subscriber *subscriber = usr_data;
+	struct tipc_subscr *s = (struct tipc_subscr *)buf;
+	int swap;
+
+	/* Determine subscriber's endianness */
+	swap = !(s->filter & (TIPC_SUB_PORTS | TIPC_SUB_SERVICE));
+
+	/* Detect & process a subscription cancellation request */
+	if (s->filter & htohl(TIPC_SUB_CANCEL, swap)) {
+		s->filter &= ~htohl(TIPC_SUB_CANCEL, swap);
+		return tipc_subscrp_cancel(s, subscriber);
+	}
+
+	tipc_subscrp_subscribe(net, s, subscriber, swap);
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
