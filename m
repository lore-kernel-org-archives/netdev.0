From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/9] [TCP]: Move Reno SACKed_out counter functions earlier
Date: Sat, 26 May 2007 11:35:54 +0300
Message-ID: <11801685621267-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42982 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbXEZIgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 04:36:06 -0400
In-Reply-To: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   98 ++++++++++++++++++++++++------------------=
--------
 1 files changed, 47 insertions(+), 51 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cb81e31..925a26f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1319,6 +1319,53 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb,
 /* F-RTO can only be used if TCP has never retransmitted anything othe=
r than
  * head (SACK enhanced variant from Appendix B of RFC4138 is more robu=
st here)
  */
+static void tcp_check_reno_reordering(struct sock *sk, const int adden=
d)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	u32 holes;
+
+	holes =3D max(tp->lost_out, 1U);
+	holes =3D min(holes, tp->packets_out);
+
+	if ((tp->sacked_out + holes) > tp->packets_out) {
+		tp->sacked_out =3D tp->packets_out - holes;
+		tcp_update_reordering(sk, tp->packets_out + addend, 0);
+	}
+}
+
+/* Emulate SACKs for SACKless connection: account for a new dupack. */
+
+static void tcp_add_reno_sack(struct sock *sk)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	tp->sacked_out++;
+	tcp_check_reno_reordering(sk, 0);
+	tcp_sync_left_out(tp);
+}
+
+/* Account for ACK, ACKing some data in Reno Recovery phase. */
+
+static void tcp_remove_reno_sacks(struct sock *sk, int acked)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	if (acked > 0) {
+		/* One ACK acked hole. The rest eat duplicate ACKs. */
+		if (acked-1 >=3D tp->sacked_out)
+			tp->sacked_out =3D 0;
+		else
+			tp->sacked_out -=3D acked-1;
+	}
+	tcp_check_reno_reordering(sk, acked);
+	tcp_sync_left_out(tp);
+}
+
+static inline void tcp_reset_reno_sack(struct tcp_sock *tp)
+{
+	tp->sacked_out =3D 0;
+	tp->left_out =3D tp->lost_out;
+}
+
 int tcp_use_frto(struct sock *sk)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
@@ -1734,57 +1781,6 @@ static int tcp_time_to_recover(struct sock *sk)
 	return 0;
 }
=20
-/* If we receive more dupacks than we expected counting segments
- * in assumption of absent reordering, interpret this as reordering.
- * The only another reason could be bug in receiver TCP.
- */
-static void tcp_check_reno_reordering(struct sock *sk, const int adden=
d)
-{
-	struct tcp_sock *tp =3D tcp_sk(sk);
-	u32 holes;
-
-	holes =3D max(tp->lost_out, 1U);
-	holes =3D min(holes, tp->packets_out);
-
-	if ((tp->sacked_out + holes) > tp->packets_out) {
-		tp->sacked_out =3D tp->packets_out - holes;
-		tcp_update_reordering(sk, tp->packets_out + addend, 0);
-	}
-}
-
-/* Emulate SACKs for SACKless connection: account for a new dupack. */
-
-static void tcp_add_reno_sack(struct sock *sk)
-{
-	struct tcp_sock *tp =3D tcp_sk(sk);
-	tp->sacked_out++;
-	tcp_check_reno_reordering(sk, 0);
-	tcp_sync_left_out(tp);
-}
-
-/* Account for ACK, ACKing some data in Reno Recovery phase. */
-
-static void tcp_remove_reno_sacks(struct sock *sk, int acked)
-{
-	struct tcp_sock *tp =3D tcp_sk(sk);
-
-	if (acked > 0) {
-		/* One ACK acked hole. The rest eat duplicate ACKs. */
-		if (acked-1 >=3D tp->sacked_out)
-			tp->sacked_out =3D 0;
-		else
-			tp->sacked_out -=3D acked-1;
-	}
-	tcp_check_reno_reordering(sk, acked);
-	tcp_sync_left_out(tp);
-}
-
-static inline void tcp_reset_reno_sack(struct tcp_sock *tp)
-{
-	tp->sacked_out =3D 0;
-	tp->left_out =3D tp->lost_out;
-}
-
 /* RFC: This is from the original, I doubt that this is necessary at a=
ll:
  * clear xmit_retrans hint if seq of this skb is beyond hint. How coul=
d we
  * retransmitted past LOST markings in the first place? I'm not fully =
sure
--=20
1.5.0.6

