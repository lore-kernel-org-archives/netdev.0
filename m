From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 3/8] tipc: don't record link
	RESET or ACTIVATE messages as traffic
Date: Wed, 14 May 2014 05:39:10 -0400
Message-ID: <1400060355-26308-4-git-send-email-jon.maloy@ericsson.com>
References: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In the current code, all incoming LINK_PROTOCOL messages, irrespective
of type, nudge the "last message received" checkpoint, informing the
link state machine that a message was received from the peer since last
supervision timeout event. This inhibits the link from starting probing
the peer unnecessarily.

However, not only STATE messages are recorded as legitimate incoming
traffic this way, but even RESET and ACTIVATE messages, which in
reality are there to inform the link that the peer endpoint has been
reset. At the same time, some RESET messages may be dropped instead
of causing a link reset. This happens when the link endpoint thinks
it is fully up and working, and the session number of the RESET is
lower than or equal to the current link session. In such cases the
RESET is perceived as a delayed remnant from an earlier session, or
the current one, and dropped.

Now, if a TIPC module is removed and then immediately reinserted, e.g.
when using a script, RESET messages may arrive at the peer link endpoint
before this one has had time to discover the failure. The RESET may be
dropped because of the session number, but only after it has been
recorded as a legitimate traffic event. Hence, the receiving link will
not start probing, and not discover that the peer endpoint is down, at
the same time ignoring the periodic RESET messages coming from that
endpoint. We have ended up in a stale state where a failed link cannot
be re-established.

In this commit, we remedy this by nudging the checkpoint only for
received STATE messages, not for RESET or ACTIVATE messages.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 2140837..6cf7938 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1831,9 +1831,6 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr, struct sk_buff *buf)
 	if (l_ptr->exp_msg_count)
 		goto exit;
 
-	/* record unnumbered packet arrival (force mismatch on next timeout) */
-	l_ptr->checkpoint--;
-
 	if (l_ptr->net_plane != msg_net_plane(msg))
 		if (tipc_own_addr > msg_prevnode(msg))
 			l_ptr->net_plane = msg_net_plane(msg);
@@ -1909,6 +1906,10 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr, struct sk_buff *buf)
 			tipc_link_reset(l_ptr); /* Enforce change to take effect */
 			break;
 		}
+
+		/* Record reception; force mismatch at next timeout: */
+		l_ptr->checkpoint--;
+
 		link_state_event(l_ptr, TRAFFIC_MSG_EVT);
 		l_ptr->stats.recv_states++;
 		if (link_reset_unknown(l_ptr))
-- 
1.7.9.5


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
