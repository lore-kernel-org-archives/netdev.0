From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/2] [TCP] FRTO: work-around inorder receivers
Date: Tue, 13 May 2008 12:43:54 +0300
Message-ID: <1210671834-15406-2-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1210671834-15406-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "Damon L. Chesser" <damon@damtek.com>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48068 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbYEMJnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 05:43:55 -0400
In-Reply-To: <1210671834-15406-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If receiver consumes segments successfully only in-order, FRTO
fallback to conventional recovery produces RTO loop because
=46RTO's forward transmissions will always get dropped and need to
be resent, yet by default they're not marked as lost (which are
the only segments we will retransmit in CA_Loss).

Price to pay about this is occassionally unnecessarily
retransmitting the forward transmission(s). SACK blocks help
a bit to avoid this, so it's mainly a concern for NewReno case
though SACK is not fully immune either.

This change has a side-effect of fixing SACKFRTO problem where
it didn't have snd_nxt of the RTO time available anymore when
fallback become necessary (this problem would have only occured
when RTO would occur for two or more segments and ECE arrives
in step 3; no need to figure out how to fix that unless the
TODO item of selective behavior is considered in future).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Damon L. Chesser <damon@damtek.com>
Tested-by: Damon L. Chesser <damon@damtek.com>
---
 net/ipv4/tcp_input.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4c2255c..4ffd021 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1841,9 +1841,16 @@ static void tcp_enter_frto_loss(struct sock *sk,=
 int allowed_segments, int flag)
 			TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
 		}
=20
-		/* Don't lost mark skbs that were fwd transmitted after RTO */
-		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) &&
-		    !after(TCP_SKB_CB(skb)->end_seq, tp->frto_highmark)) {
+		/* Marking forward transmissions that were made after RTO lost
+		 * can cause unnecessary retransmissions in some scenarios,
+		 * SACK blocks will mitigate that in some but not in all cases.
+		 * We used to not mark them but it was causing break-ups with
+		 * receivers that do only in-order receival.
+		 *
+		 * TODO: we could detect presence of such receiver and select
+		 * different behavior per flow.
+		 */
+		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
 			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 			tp->lost_out +=3D tcp_skb_pcount(skb);
 		}
@@ -1859,7 +1866,7 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
 	tp->reordering =3D min_t(unsigned int, tp->reordering,
 			       sysctl_tcp_reordering);
 	tcp_set_ca_state(sk, TCP_CA_Loss);
-	tp->high_seq =3D tp->frto_highmark;
+	tp->high_seq =3D tp->snd_nxt;
 	TCP_ECN_queue_cwr(tp);
=20
 	tcp_clear_retrans_hints_partial(tp);
--=20
1.5.2.2

