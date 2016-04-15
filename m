From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/5] tipc: guarantee peer bearer
	id exchange after reboot
Date: Fri, 15 Apr 2016 13:33:03 -0400
Message-ID: <1460741587-13935-2-git-send-email-jon.maloy@ericsson.com>
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

When a link endpoint is going down locally, e.g., because its interface
is being stopped, it will spontaneously send out a RESET message to
its peer, informing it about this fact. This saves the peer from
detecting the failure via probing, and hence gives both speedier and
less resource consuming failure detection on the peer side.

According to the link FSM, a receiver of a RESET message, ignoring the
reason for it, must now consider the sender ready to come back up, and
starts periodically sending out ACTIVATE messages to the peer in order
to re-establish the link. Also, according to the FSM, the receiver of
an ACTIVATE message can now go directly to state ESTABLISHED and start
sending regular traffic packets. This is a well-proven and robust FSM.

However, in the case of a reboot, there is a small possibilty that link
endpoint on the rebooted node may have been re-created with a new bearer
identity between the moment it sent its (pre-boot) RESET and the moment
it receives the ACTIVATE from the peer. The new bearer identity cannot
be known by the peer according to this scenario, since traffic headers
don't convey such information. This is a problem, because both endpoints
need to know the correct value of the peer's bearer id at any moment in
time in order to be able to produce correct link events for their users.

The only way to guarantee this is to enforce a full setup message
exchange (RESET + ACTIVATE) even after the reboot, since those messages
carry the bearer idientity in their header.

In this commit we do this by introducing and setting a "stopping" bit in
the header of the spontaneously generated RESET messages, informing the
peer that the sender will not be immediately ready to re-establish the
link. A receiver seeing this bit must act as if this were a locally
detected connectivity failure, and hence has to go through a full two-
way setup message exchange before any link can be re-established.

Although never reported, this problem seems to have always been around.

This protocol addition is fully backwards compatible.

Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 10 +++++++++-
 net/tipc/msg.h  | 10 ++++++++++
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 7d2bb3e..8b98faf 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1140,11 +1140,17 @@ int tipc_link_build_ack_msg(struct tipc_link *l, struct sk_buff_head *xmitq)
 void tipc_link_build_reset_msg(struct tipc_link *l, struct sk_buff_head *xmitq)
 {
 	int mtyp = RESET_MSG;
+	struct sk_buff *skb;
 
 	if (l->state == LINK_ESTABLISHING)
 		mtyp = ACTIVATE_MSG;
 
 	tipc_link_build_proto_msg(l, mtyp, 0, 0, 0, 0, xmitq);
+
+	/* Inform peer that this endpoint is going down if applicable */
+	skb = skb_peek_tail(xmitq);
+	if (skb && (l->state == LINK_RESET))
+		msg_set_peer_stopping(buf_msg(skb), 1);
 }
 
 /* tipc_link_build_nack_msg: prepare link nack message for transmission
@@ -1411,7 +1417,9 @@ static int tipc_link_proto_rcv(struct tipc_link *l, struct sk_buff *skb,
 			l->priority = peers_prio;
 
 		/* ACTIVATE_MSG serves as PEER_RESET if link is already down */
-		if ((mtyp == RESET_MSG) || !link_is_up(l))
+		if (msg_peer_stopping(hdr))
+			rc = tipc_link_fsm_evt(l, LINK_FAILURE_EVT);
+		else if ((mtyp == RESET_MSG) || !link_is_up(l))
 			rc = tipc_link_fsm_evt(l, LINK_PEER_RESET_EVT);
 
 		/* ACTIVATE_MSG takes up link if it was already locally reset */
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index f34f639..58bf515 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -715,6 +715,16 @@ static inline void msg_set_redundant_link(struct tipc_msg *m, u32 r)
 	msg_set_bits(m, 5, 12, 0x1, r);
 }
 
+static inline u32 msg_peer_stopping(struct tipc_msg *m)
+{
+	return msg_bits(m, 5, 13, 0x1);
+}
+
+static inline void msg_set_peer_stopping(struct tipc_msg *m, u32 s)
+{
+	msg_set_bits(m, 5, 13, 0x1, s);
+}
+
 static inline char *msg_media_addr(struct tipc_msg *m)
 {
 	return (char *)&m->hdr[TIPC_MEDIA_INFO_OFFSET];
-- 
1.9.1


------------------------------------------------------------------------------
Find and fix application performance issues faster with Applications Manager
Applications Manager provides deep performance insights into multiple tiers of
your business applications. It resolves application problems quickly and
reduces your MTTR. Get your free trial!
https://ad.doubleclick.net/ddm/clk/302982198;130105516;z
