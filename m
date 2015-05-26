From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: fix bug in link
	protocol message create function
Date: Tue, 26 May 2015 05:40:19 -0400
Message-ID: <1432633219-3354-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
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

In commit dd3f9e70f59f43a5712eba9cf3ee4f1e6999540c
("tipc: add packet sequence number at instant of transmission") we
made a change with the consequence that packets in the link backlog
queue don't contain valid sequence numbers.

However, when we create a link protocol message, we still use the
sequence number of the first packet in the backlog, if there is any,
as "next_sent" indicator in the message. This may entail unnecessary
retransissions or stale packet transmission when there is very low
traffic on the link.

This commit fixes this issue by only using the current value of
tipc_link::snd_nxt as indicator.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index fb2a003..ca8b8e0 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1320,8 +1320,6 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 
 		if (!tipc_link_is_up(l_ptr))
 			return;
-		if (skb_queue_len(&l_ptr->backlogq))
-			next_sent = buf_seqno(skb_peek(&l_ptr->backlogq));
 		msg_set_next_sent(msg, next_sent);
 		if (!skb_queue_empty(&l_ptr->deferdq)) {
 			last_rcv = buf_seqno(skb_peek(&l_ptr->deferdq));
-- 
1.9.1


------------------------------------------------------------------------------
One dashboard for servers and applications across Physical-Virtual-Cloud 
Widest out-of-the-box monitoring support with 50+ applications
Performance metrics, stats and reports that give you Actionable Insights
Deep dive visibility with transaction tracing using APM Insight.
http://ad.doubleclick.net/ddm/clk/290420510;117567292;y
