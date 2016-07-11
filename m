From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 2/3] tipc: ensure correct broadcast
	send buffer release when peer is lost
Date: Mon, 11 Jul 2016 16:08:36 -0400
Message-ID: <1468267717-518-3-git-send-email-jon.maloy@ericsson.com>
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

After a new receiver peer has been added to the broadcast transmission
link, we allow immediate transmission of new broadcast packets, trusting
that the new peer will not accept the packets until it has received the
previously sent unicast broadcast initialiation message. In the same
way, the sender must not accept any acknowledges until it has itself
received the broadcast initialization from the peer, as well as
confirmation of the reception of its own initialization message.

Furthermore, when a receiver peer goes down, the sender has to produce
the missing acknowledges from the lost peer locally, in order ensure
correct release of the buffers that were expected to be acknowledged by
the said peer.

In a highly stressed system we have observed that contact with a peer
may come up and be lost before the above mentioned broadcast initial-
ization and confirmation have been received. This leads to the locally
produced acknowledges being rejected, and the non-acknowledged buffers
to linger in the broadcast link transmission queue until it fills up
and the link goes into permanent congestion.

In this commit, we remedy this by temporarily setting the corresponding
broadcast receive link state to ESTABLISHED and the 'bc_peer_is_up'
state to true before we issue the local acknowledges. This ensures that
those acknowledges will always be accepted. The mentioned state values
are restored immediately afterwards when the link is reset.

Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 6483dc4..7d89f87 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -349,6 +349,8 @@ void tipc_link_remove_bc_peer(struct tipc_link *snd_l,
 	u16 ack = snd_l->snd_nxt - 1;
 
 	snd_l->ackers--;
+	rcv_l->bc_peer_is_up = true;
+	rcv_l->state = LINK_ESTABLISHED;
 	tipc_link_bc_ack_rcv(rcv_l, ack, xmitq);
 	tipc_link_reset(rcv_l);
 	rcv_l->state = LINK_RESET;
-- 
1.9.1


------------------------------------------------------------------------------
Attend Shape: An AT&T Tech Expo July 15-16. Meet us at AT&T Park in San
Francisco, CA to explore cutting-edge tech and listen to tech luminaries
present their vision of the future. This family event has something for
everyone, including kids. Get more information and register today.
http://sdm.link/attshape
