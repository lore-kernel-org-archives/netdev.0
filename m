From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 2/8] tipc: simplify link timer
	handling
Date: Thu, 14 May 2015 10:46:12 -0400
Message-ID: <1431614778-17582-3-git-send-email-jon.maloy@ericsson.com>
References: <1431614778-17582-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1431614778-17582-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Prior to this commit, the link timer has been running at a "continuity
interval" of configured link tolerance/4. When a timer wakes up and
discovers that there has been no sign of life from the peer during the
previous interval, it divides its own timer interval by another factor
four, and starts sending one probe per new interval. When the configured
link tolerance time has passed without answer, i.e. after 16 unacked
probes, the link is declared faulty and reset.

This is unnecessary complex. It is sufficient to continue with the
original continuity interval, and instead reset the link after four
missed probe responses. This makes the timer handling in the link
simpler, and opens up for some planned later changes in this area.
This commit implements this change.

Reviewed-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 266dbc6..d71e83d 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -528,7 +528,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			l_ptr->fsm_msg_cnt = 0;
 			tipc_link_proto_xmit(l_ptr, STATE_MSG, 1, 0, 0, 0);
 			l_ptr->fsm_msg_cnt++;
-			link_set_timer(l_ptr, cont_intv / 4);
+			link_set_timer(l_ptr, cont_intv);
 			break;
 		case RESET_MSG:
 			pr_debug("%s<%s>, requested by peer\n",
@@ -579,7 +579,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 				tipc_link_proto_xmit(l_ptr, STATE_MSG,
 						     1, 0, 0, 0);
 				l_ptr->fsm_msg_cnt++;
-				link_set_timer(l_ptr, cont_intv / 4);
+				link_set_timer(l_ptr, cont_intv);
 			} else {	/* Link has failed */
 				pr_debug("%s<%s>, peer not responding\n",
 					 link_rst_msg, l_ptr->name);
@@ -1725,7 +1725,7 @@ static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tol)
 
 	l_ptr->tolerance = tol;
 	l_ptr->cont_intv = msecs_to_jiffies(intv);
-	l_ptr->abort_limit = tol / (jiffies_to_msecs(l_ptr->cont_intv) / 4);
+	l_ptr->abort_limit = tol / (jiffies_to_msecs(l_ptr->cont_intv));
 }
 
 void tipc_link_set_queue_limits(struct tipc_link *l, u32 win)
-- 
1.9.1


------------------------------------------------------------------------------
One dashboard for servers and applications across Physical-Virtual-Cloud 
Widest out-of-the-box monitoring support with 50+ applications
Performance metrics, stats and reports that give you Actionable Insights
Deep dive visibility with transaction tracing using APM Insight.
http://ad.doubleclick.net/ddm/clk/290420510;117567292;y
