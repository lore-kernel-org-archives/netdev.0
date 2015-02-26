From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 2/5] tipc: fix nullpointer bug
	when subscribing to events
Date: Thu, 26 Feb 2015 07:43:27 +0100
Message-ID: <1424933010-31003-3-git-send-email-erik.hugne@ericsson.com>
References: <1424933010-31003-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1424933010-31003-1-git-send-email-erik.hugne@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Erik Hugne <erik.hugne@ericsson.com>

If a subscription request is sent to a topology server
connection, and any error occurs (malformed request, oom
or limit reached) while processing this request, TIPC should
terminate the subscriber connection. While doing so, it tries
to access fields in an already freed (or never allocated)
subscription element leading to a nullpointer exception.
We fix this by removing the subscr_terminate function and
terminate the connection immediately upon any subscription
failure.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/subscr.c | 24 +++++-------------------
 1 file changed, 5 insertions(+), 19 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 72c339e..3c33c34 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -162,19 +162,6 @@ static void subscr_del(struct tipc_subscription *sub)
 	atomic_dec(&tn->subscription_count);
 }
 
-/**
- * subscr_terminate - terminate communication with a subscriber
- *
- * Note: Must call it in process context since it might sleep.
- */
-static void subscr_terminate(struct tipc_subscription *sub)
-{
-	struct tipc_subscriber *subscriber = sub->subscriber;
-	struct tipc_net *tn = net_generic(sub->net, tipc_net_id);
-
-	tipc_conn_terminate(tn->topsrv, subscriber->conid);
-}
-
 static void subscr_release(struct tipc_subscriber *subscriber)
 {
 	struct tipc_subscription *sub;
@@ -312,16 +299,15 @@ static void subscr_conn_msg_event(struct net *net, int conid,
 {
 	struct tipc_subscriber *subscriber = usr_data;
 	struct tipc_subscription *sub = NULL;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
 
 	spin_lock_bh(&subscriber->lock);
-	if (subscr_subscribe(net, (struct tipc_subscr *)buf, subscriber,
-			     &sub) < 0) {
-		spin_unlock_bh(&subscriber->lock);
-		subscr_terminate(sub);
-		return;
-	}
+	subscr_subscribe(net, (struct tipc_subscr *)buf, subscriber, &sub);
 	if (sub)
 		tipc_nametbl_subscribe(sub);
+	else
+		tipc_conn_terminate(tn->topsrv, subscriber->conid);
 	spin_unlock_bh(&subscriber->lock);
 }
 
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
