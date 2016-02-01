From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 09/10] tipc: donot create
	timers if subscription timeout = TIPC_WAIT_FOREVER
Date: Mon, 1 Feb 2016 10:44:42 +0100
Message-ID: <1454319883-16031-10-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

Until now, we create timers even for the subscription requests
with timeout = TIPC_WAIT_FOREVER.
This can be improved by avoiding timer creation when the timeout
is set to TIPC_WAIT_FOREVER.

In this commit, we introduce a check to creates timers only
when timeout != TIPC_WAIT_FOREVER.

Acked-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/subscr.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 7d226ecb0490..22963cafd5ed 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -188,12 +188,14 @@ static struct tipc_subscriber *tipc_subscrb_create(int conid)
 static void tipc_subscrb_delete(struct tipc_subscriber *subscriber)
 {
 	struct tipc_subscription *sub, *temp;
+	u32 timeout;
 
 	spin_lock_bh(&subscriber->lock);
 	/* Destroy any existing subscriptions for subscriber */
 	list_for_each_entry_safe(sub, temp, &subscriber->subscrp_list,
 				 subscrp_list) {
-		if (del_timer(&sub->timer)) {
+		timeout = htohl(sub->evt.s.timeout, sub->swap);
+		if ((timeout == TIPC_WAIT_FOREVER) || del_timer(&sub->timer)) {
 			tipc_subscrp_delete(sub);
 			tipc_subscrb_put(subscriber);
 		}
@@ -217,13 +219,16 @@ static void tipc_subscrp_cancel(struct tipc_subscr *s,
 				struct tipc_subscriber *subscriber)
 {
 	struct tipc_subscription *sub, *temp;
+	u32 timeout;
 
 	spin_lock_bh(&subscriber->lock);
 	/* Find first matching subscription, exit if not found */
 	list_for_each_entry_safe(sub, temp, &subscriber->subscrp_list,
 				 subscrp_list) {
 		if (!memcmp(s, &sub->evt.s, sizeof(struct tipc_subscr))) {
-			if (del_timer(&sub->timer)) {
+			timeout = htohl(sub->evt.s.timeout, sub->swap);
+			if ((timeout == TIPC_WAIT_FOREVER) ||
+			    del_timer(&sub->timer)) {
 				tipc_subscrp_delete(sub);
 				tipc_subscrb_put(subscriber);
 			}
@@ -267,7 +272,6 @@ static struct tipc_subscription *tipc_subscrp_create(struct net *net,
 	sub->swap = swap;
 	memcpy(&sub->evt.s, s, sizeof(*s));
 	atomic_inc(&tn->subscription_count);
-	setup_timer(&sub->timer, tipc_subscrp_timeout, (unsigned long)sub);
 	return sub;
 }
 
@@ -290,6 +294,10 @@ static void tipc_subscrp_subscribe(struct net *net, struct tipc_subscr *s,
 	spin_unlock_bh(&subscriber->lock);
 
 	timeout = htohl(sub->evt.s.timeout, swap);
+	if (timeout == TIPC_WAIT_FOREVER)
+		return;
+
+	setup_timer(&sub->timer, tipc_subscrp_timeout, (unsigned long)sub);
 	mod_timer(&sub->timer, jiffies + msecs_to_jiffies(timeout));
 }
 
-- 
2.1.4


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=267308311&iu=/4140
