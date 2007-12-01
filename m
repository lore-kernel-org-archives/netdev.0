From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 02/21] [TCP]: Remove superflucious FLAG_DATA_SACKED
Date: Sun,  2 Dec 2007 00:47:57 +0200
Message-ID: <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59570 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbXLAWsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:19 -0500
In-Reply-To: <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

To get there, highest_sack must have advanced. When it advances,
a new skb is SACKed, which already sets that FLAG. Besides, the
original purpose of it has puzzled me, never understood why
LOST bit setting of retransmitted skb is marked with
=46LAG_DATA_SACKED.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ba05e16..6986a2d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1118,12 +1118,11 @@ static int tcp_is_sackblock_valid(struct tcp_so=
ck *tp, int is_dsack,
  * highest SACK block). Also calculate the lowest snd_nxt among the re=
maining
  * retransmitted skbs to avoid some costly processing per ACKs.
  */
-static int tcp_mark_lost_retrans(struct sock *sk)
+static void tcp_mark_lost_retrans(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
-	int flag =3D 0;
 	int cnt =3D 0;
 	u32 new_low_seq =3D tp->snd_nxt;
 	u32 received_upto =3D TCP_SKB_CB(tp->highest_sack)->end_seq;
@@ -1131,7 +1130,7 @@ static int tcp_mark_lost_retrans(struct sock *sk)
 	if (!tcp_is_fack(tp) || !tp->retrans_out ||
 	    !after(received_upto, tp->lost_retrans_low) ||
 	    icsk->icsk_ca_state !=3D TCP_CA_Recovery)
-		return flag;
+		return;
=20
 	tcp_for_write_queue(skb, sk) {
 		u32 ack_seq =3D TCP_SKB_CB(skb)->ack_seq;
@@ -1159,7 +1158,6 @@ static int tcp_mark_lost_retrans(struct sock *sk)
 			if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_LOST|TCPCB_SACKED_ACKED))) {
 				tp->lost_out +=3D tcp_skb_pcount(skb);
 				TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
-				flag |=3D FLAG_DATA_SACKED;
 			}
 			NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
 		} else {
@@ -1171,8 +1169,6 @@ static int tcp_mark_lost_retrans(struct sock *sk)
=20
 	if (tp->retrans_out)
 		tp->lost_retrans_low =3D new_low_seq;
-
-	return flag;
 }
=20
 static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_sk=
b,
@@ -1603,7 +1599,7 @@ advance_sp:
 	for (j =3D 0; j < used_sacks; j++)
 		tp->recv_sack_cache[i++] =3D sp[j];
=20
-	flag |=3D tcp_mark_lost_retrans(sk);
+	tcp_mark_lost_retrans(sk);
=20
 	tcp_verify_left_out(tp);
=20
--=20
1.5.0.6

