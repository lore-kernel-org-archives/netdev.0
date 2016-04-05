From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 3/3] tipc: reduce transmission
	rate of reset messages when link is down
Date: Tue,  5 Apr 2016 12:20:55 -0400
Message-ID: <1459873255-32354-4-git-send-email-jon.maloy@ericsson.com>
References: <1459873255-32354-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1459873255-32354-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When a link is down, it will continuously try to re-establish contact
with the peer by sending out a RESET or and ACTIVATE message at each
timeout interval. The default value for this interval is currently
375 ms. This is wasteful, and may become a problem in very large
clusters with dozens or hundereds of nodes being down simultaneously.

We now introduce a simple backoff algorithm for these cases. The
first five messages are sent at default rate; thereafter a message
is sent only each 16't timer interval.

This will cover the vast majority of link recyling cases, since the
endpoint starting last will transmit at the higher speed, and the link
should normally be established well be before the rate needs to be
reduced.

The only case where we will see a degradation of link re-establishment
is when the endpoins remain intact, and a glitch in the transmission
media is causing the link reset. We will then experience a worst-case
re-establishing time of 6 seconds, something we deem acceptable.

Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 7d2bb3e..42cdbd1 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -140,6 +140,7 @@ struct tipc_link {
 	char if_name[TIPC_MAX_IF_NAME];
 	u32 priority;
 	char net_plane;
+	u16 rst_cnt;
 
 	/* Failover/synch */
 	u16 drop_point;
@@ -701,8 +702,6 @@ static void link_profile_stats(struct tipc_link *l)
 
 /* tipc_link_timeout - perform periodic task as instructed from node timeout
  */
-/* tipc_link_timeout - perform periodic task as instructed from node timeout
- */
 int tipc_link_timeout(struct tipc_link *l, struct sk_buff_head *xmitq)
 {
 	int rc = 0;
@@ -730,11 +729,13 @@ int tipc_link_timeout(struct tipc_link *l, struct sk_buff_head *xmitq)
 		l->silent_intv_cnt++;
 		break;
 	case LINK_RESET:
-		xmit = true;
+		if ((l->rst_cnt++ <= 4) || !(l->rst_cnt % 16))
+			xmit = true;
 		mtyp = RESET_MSG;
 		break;
 	case LINK_ESTABLISHING:
-		xmit = true;
+		if ((l->rst_cnt++ <= 4) || !(l->rst_cnt % 16))
+			xmit = true;
 		mtyp = ACTIVATE_MSG;
 		break;
 	case LINK_PEER_RESET:
@@ -833,6 +834,7 @@ void tipc_link_reset(struct tipc_link *l)
 	l->rcv_nxt = 1;
 	l->acked = 0;
 	l->silent_intv_cnt = 0;
+	l->rst_cnt = 0;
 	l->stats.recv_info = 0;
 	l->stale_count = 0;
 	l->bc_peer_is_up = false;
-- 
1.9.1


------------------------------------------------------------------------------
