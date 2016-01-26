From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net] tipc: fix connection abort during
	subscription cancel
Date: Tue, 26 Jan 2016 15:01:02 +0100
Message-ID: <1453816862-30289-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, anders.widell@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
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

Unfortunately, the same function tipc_subscrp_create() handles
subscription cancel request. For a subscription cancellation request,
the subscription pointer cannot be set. Thus if a subscriber has
several subscriptions and cancels any of them, the connection is
terminated.

In this commit, we terminate the connection based on the return value
of tipc_subscrp_create().
Fixes: commit 7fe8097cef5f ("tipc: fix nullpointer bug when subscribing to events")

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/subscr.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 350cca33ee0a..72bb7cdc85aa 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -293,11 +293,11 @@ static void tipc_subscrb_rcv_cb(struct net *net, int conid,
 	struct tipc_subscription *sub = NULL;
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
-	tipc_subscrp_create(net, (struct tipc_subscr *)buf, subscriber, &sub);
-	if (sub)
-		tipc_nametbl_subscribe(sub);
-	else
-		tipc_conn_terminate(tn->topsrv, subscriber->conid);
+	if (tipc_subscrp_create(net, (struct tipc_subscr *)buf, subscriber,
+				&sub))
+		return tipc_conn_terminate(tn->topsrv, subscriber->conid);
+
+	tipc_nametbl_subscribe(sub);
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
