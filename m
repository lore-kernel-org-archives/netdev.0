From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 3/5] tipc: refactor function
	tipc_link_timeout()
Date: Fri, 15 Apr 2016 13:33:05 -0400
Message-ID: <1460741587-13935-4-git-send-email-jon.maloy@ericsson.com>
References: <1460741587-13935-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1460741587-13935-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The function tipc_link_timeout() is unnecessary complex, and can
easily be made more readable.

We do that with this commit. The only functional change is that we
remove a redundant test for whether the broadcast link is up or not.

Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 36 ++++++++++++++++--------------------
 1 file changed, 16 insertions(+), 20 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 238b125..774ad3c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -704,37 +704,33 @@ static void link_profile_stats(struct tipc_link *l)
  */
 int tipc_link_timeout(struct tipc_link *l, struct sk_buff_head *xmitq)
 {
-	int rc = 0;
-	int mtyp = STATE_MSG;
-	bool xmit = false;
-	bool prb = false;
+	int mtyp, rc = 0;
+	bool state = false;
+	bool probe = false;
+	bool setup = false;
 	u16 bc_snt = l->bc_sndlink->snd_nxt - 1;
 	u16 bc_acked = l->bc_rcvlink->acked;
-	bool bc_up = link_is_up(l->bc_rcvlink);
 
 	link_profile_stats(l);
 
 	switch (l->state) {
 	case LINK_ESTABLISHED:
 	case LINK_SYNCHING:
-		if (!l->silent_intv_cnt) {
-			if (bc_up && (bc_acked != bc_snt))
-				xmit = true;
-		} else if (l->silent_intv_cnt <= l->abort_limit) {
-			xmit = true;
-			prb = true;
-		} else {
-			rc |= tipc_link_fsm_evt(l, LINK_FAILURE_EVT);
-		}
-		l->silent_intv_cnt++;
+		if (l->silent_intv_cnt > l->abort_limit)
+			return tipc_link_fsm_evt(l, LINK_FAILURE_EVT);
+		mtyp = STATE_MSG;
+		state = bc_acked != bc_snt;
+		probe = l->silent_intv_cnt;
+		if (probe)
+			l->silent_intv_cnt++;
 		break;
 	case LINK_RESET:
-		xmit = l->rst_cnt++ <= 4;
-		xmit |= !(l->rst_cnt % 16);
+		setup = l->rst_cnt++ <= 4;
+		setup |= !(l->rst_cnt % 16);
 		mtyp = RESET_MSG;
 		break;
 	case LINK_ESTABLISHING:
-		xmit = true;
+		setup = true;
 		mtyp = ACTIVATE_MSG;
 		break;
 	case LINK_PEER_RESET:
@@ -745,8 +741,8 @@ int tipc_link_timeout(struct tipc_link *l, struct sk_buff_head *xmitq)
 		break;
 	}
 
-	if (xmit)
-		tipc_link_build_proto_msg(l, mtyp, prb, 0, 0, 0, xmitq);
+	if (state || probe || setup)
+		tipc_link_build_proto_msg(l, mtyp, probe, 0, 0, 0, xmitq);
 
 	return rc;
 }
-- 
1.9.1


------------------------------------------------------------------------------
Find and fix application performance issues faster with Applications Manager
Applications Manager provides deep performance insights into multiple tiers of
your business applications. It resolves application problems quickly and
reduces your MTTR. Get your free trial!
https://ad.doubleclick.net/ddm/clk/302982198;130105516;z
