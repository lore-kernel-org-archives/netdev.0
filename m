From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/3] tipc: extend broadcast link
	initialization criteria
Date: Mon, 11 Jul 2016 16:08:35 -0400
Message-ID: <1468267717-518-2-git-send-email-jon.maloy@ericsson.com>
References: <1468267717-518-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1468267717-518-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

At first contact between two nodes, an endpoint might sometimes have
time to send out a LINK_PROTOCOL/STATE packet before it has received
the broadcast initialization packet from the peer, i.e., before it has
received a valid broadcast packet number to add to the 'bc_ack' field
of the protocol message.

This means that the peer endpoint will receive a protocol packet with an
invalid broadcast acknowledge value of 0. Under unlucky circumstances
this may lead to the original, already received acknowledge value being
overwritten, so that the whole broadcast link goes stale after a while.

We fix this by delaying the setting of the link field 'bc_peer_is_up'
until we know that the peer really has received our own broadcast
initialization message. The latter is always sent out as the first
unicast message on a link, and always with seqeunce number 1. Because
of this, we only need to look for a non-zero unicast acknowledge value
in the arriving STATE messages, and once that is confirmed we know we
are safe and can set the mentioned field. Before this moment, we must
ignore all broadcast acknowledges from the peer.

Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 67b6ab9..6483dc4 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1559,7 +1559,12 @@ void tipc_link_bc_sync_rcv(struct tipc_link *l, struct tipc_msg *hdr,
 	if (!msg_peer_node_is_up(hdr))
 		return;
 
-	l->bc_peer_is_up = true;
+	/* Open when peer ackowledges our bcast init msg (pkt #1) */
+	if (msg_ack(hdr))
+		l->bc_peer_is_up = true;
+
+	if (!l->bc_peer_is_up)
+		return;
 
 	/* Ignore if peers_snd_nxt goes beyond receive window */
 	if (more(peers_snd_nxt, l->rcv_nxt + l->window))
-- 
1.9.1


------------------------------------------------------------------------------
Attend Shape: An AT&T Tech Expo July 15-16. Meet us at AT&T Park in San
Francisco, CA to explore cutting-edge tech and listen to tech luminaries
present their vision of the future. This family event has something for
everyone, including kids. Get more information and register today.
http://sdm.link/attshape
