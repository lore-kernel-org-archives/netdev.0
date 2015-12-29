From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next] l2tp: rely on ppp layer for skb scrubbing
Date: Tue, 29 Dec 2015 13:06:59 +0100
Message-ID: <bdce354dbc9292208473f47486f7aa28f518b4fc.1451390671.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:35112 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177AbbL2MHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 07:07:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 79c441ae505c ("ppp: implement x-netns support"), the PPP layer
calls skb_scrub_packet() whenever the skb is received on the PPP
device. Manually resetting packet meta-data in the L2TP layer is thus
redundant.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ppp.c | 17 +----------------
 1 file changed, 1 insertion(+), 16 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index d93f113..652c250 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -230,26 +230,11 @@ static void pppol2tp_recv(struct l2tp_session *session, struct sk_buff *skb, int
 
 	if (sk->sk_state & PPPOX_BOUND) {
 		struct pppox_sock *po;
+
 		l2tp_dbg(session, PPPOL2TP_MSG_DATA,
 			 "%s: recv %d byte data frame, passing to ppp\n",
 			 session->name, data_len);
 
-		/* We need to forget all info related to the L2TP packet
-		 * gathered in the skb as we are going to reuse the same
-		 * skb for the inner packet.
-		 * Namely we need to:
-		 * - reset xfrm (IPSec) information as it applies to
-		 *   the outer L2TP packet and not to the inner one
-		 * - release the dst to force a route lookup on the inner
-		 *   IP packet since skb->dst currently points to the dst
-		 *   of the UDP tunnel
-		 * - reset netfilter information as it doesn't apply
-		 *   to the inner packet either
-		 */
-		secpath_reset(skb);
-		skb_dst_drop(skb);
-		nf_reset(skb);
-
 		po = pppox_sk(sk);
 		ppp_input(&po->chan, skb);
 	} else {
-- 
2.6.4
