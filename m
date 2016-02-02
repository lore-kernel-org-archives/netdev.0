From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 06/10] tipc: fix connection
	abort when receiving invalid cancel request
Date: Tue, 2 Feb 2016 10:52:13 +0100
Message-ID: <1454406737-5806-7-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

Until now, the subscribers endianness for a subscription
create/cancel request is determined as:
    swap = !(s->filter & (TIPC_SUB_PORTS | TIPC_SUB_SERVICE))
The checks are performed only for port/service subscriptions.

The swap calculation is incorrect if the filter in the subscription
cancellation request is set to TIPC_SUB_CANCEL (it's a malformed
cancel request, as the corresponding subscription create filter
is missing).
Thus, the check if the request is for cancellation fails and the
request is treated as a subscription create request. The
subscription creation fails as the request is illegal, which
terminates this connection.

In this commit we determine the endianness by including
TIPC_SUB_CANCEL, which will set swap correctly and the
request is processed as a cancellation request.

Acked-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/subscr.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 531227208ae2..24d2c8128bac 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -309,7 +309,8 @@ static void tipc_subscrb_rcv_cb(struct net *net, int conid,
 	int swap;
 
 	/* Determine subscriber's endianness */
-	swap = !(s->filter & (TIPC_SUB_PORTS | TIPC_SUB_SERVICE));
+	swap = !(s->filter & (TIPC_SUB_PORTS | TIPC_SUB_SERVICE |
+			      TIPC_SUB_CANCEL));
 
 	/* Detect & process a subscription cancellation request */
 	if (s->filter & htohl(TIPC_SUB_CANCEL, swap)) {
-- 
2.1.4


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=267308311&iu=/4140
