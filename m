From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 05/10] [TCP]: Make lost retrans detection more self-contained
Date: Thu, 15 Nov 2007 15:37:29 +0200
Message-ID: <1195133854614-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11951338542267-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338543953-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338542528-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338542967-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58227 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757456AbXKONhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 08:37:40 -0500
In-Reply-To: <11951338542967-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Highest_sack_end_seq is no longer calculated in the loop,
thus it can be pushed to the worker function altogether
making that function independent of the sacktag.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c25704f..b7af304 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1115,16 +1115,23 @@ static int tcp_is_sackblock_valid(struct tcp_so=
ck *tp, int is_dsack,
  *
  * Search retransmitted skbs from write_queue that were sent when snd_=
nxt was
  * less than what is now known to be received by the other end (derive=
d from
- * SACK blocks by the caller). Also calculate the lowest snd_nxt among=
 the
- * remaining retransmitted skbs to avoid some costly processing per AC=
Ks.
+ * highest SACK block). Also calculate the lowest snd_nxt among the re=
maining
+ * retransmitted skbs to avoid some costly processing per ACKs.
  */
-static int tcp_mark_lost_retrans(struct sock *sk, u32 received_upto)
+static int tcp_mark_lost_retrans(struct sock *sk)
 {
+	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
 	int flag =3D 0;
 	int cnt =3D 0;
 	u32 new_low_seq =3D tp->snd_nxt;
+	u32 received_upto =3D TCP_SKB_CB(tp->highest_sack)->end_seq;
+
+	if (!tcp_is_fack(tp) || !tp->retrans_out ||
+	    !after(received_upto, tp->lost_retrans_low) ||
+	    icsk->icsk_ca_state !=3D TCP_CA_Recovery)
+		return flag;
=20
 	tcp_for_write_queue(skb, sk) {
 		u32 ack_seq =3D TCP_SKB_CB(skb)->ack_seq;
@@ -1245,7 +1252,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	int num_sacks =3D (ptr[1] - TCPOLEN_SACK_BASE)>>3;
 	int reord =3D tp->packets_out;
 	int prior_fackets;
-	u32 highest_sack_end_seq;
 	int flag =3D 0;
 	int found_dup_sack =3D 0;
 	int cached_fack_count;
@@ -1513,11 +1519,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 			flag &=3D ~FLAG_ONLY_ORIG_SACKED;
 	}
=20
-	highest_sack_end_seq =3D TCP_SKB_CB(tp->highest_sack)->end_seq;
-	if (tcp_is_fack(tp) && tp->retrans_out &&
-	    after(highest_sack_end_seq, tp->lost_retrans_low) &&
-	    icsk->icsk_ca_state =3D=3D TCP_CA_Recovery)
-		flag |=3D tcp_mark_lost_retrans(sk, highest_sack_end_seq);
+	flag |=3D tcp_mark_lost_retrans(sk);
=20
 	tcp_verify_left_out(tp);
=20
--=20
1.5.0.6

