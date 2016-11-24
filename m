From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: fix compatibility bug in
	link monitoring
Date: Wed, 23 Nov 2016 21:05:26 -0500
Message-ID: <1479953126-3552-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
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

commit 817298102b0b ("tipc: fix link priority propagation") introduced a
compatibility problem between TIPC versions newer than Linux 4.6 and
those older than Linux 4.4. In versions later than 4.4, link STATE
messages only contain a non-zero link priority value when the sender
wants the receiver to change its priority. This has the effect that the
receiver resets itself in order to apply the new priority. This works
well, and is consistent with the said commit.

However, in versions older than 4.4 a valid link priority is present in
all sent link STATE messages, leading to cyclic link establishment and
reset on the 4.6+ node.

We fix this by adding a test that the received value should not only
be valid, but also differ from the current value in order to cause the
receiving link endpoint to reset.

Reported-by: Amar Nv <amar.nv005@gmail.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 1055164..ecc12411 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1492,8 +1492,9 @@ static int tipc_link_proto_rcv(struct tipc_link *l, struct sk_buff *skb,
 		if (in_range(peers_tol, TIPC_MIN_LINK_TOL, TIPC_MAX_LINK_TOL))
 			l->tolerance = peers_tol;
 
-		if (peers_prio && in_range(peers_prio, TIPC_MIN_LINK_PRI,
-					   TIPC_MAX_LINK_PRI)) {
+		/* Update own prio if peer indicates a different value */
+		if ((peers_prio != l->priority) &&
+		    in_range(peers_prio, 1, TIPC_MAX_LINK_PRI)) {
 			l->priority = peers_prio;
 			rc = tipc_link_fsm_evt(l, LINK_FAILURE_EVT);
 		}
-- 
2.7.4


------------------------------------------------------------------------------
