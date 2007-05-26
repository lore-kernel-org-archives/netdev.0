From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/9] [TCP]: Tighten tcp_sock's belt, drop left_out
Date: Sat, 26 May 2007 11:35:56 +0300
Message-ID: <11801685623173-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621267-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685626-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35531 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752840AbXEZIgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 04:36:06 -0400
In-Reply-To: <11801685626-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

It is easily calculable when needed and user are not that many
after all.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h      |    1 -
 include/net/tcp.h        |    4 ++--
 net/ipv4/tcp_input.c     |   11 ++---------
 net/ipv4/tcp_minisocks.c |    1 -
 net/ipv4/tcp_output.c    |   12 +++---------
 5 files changed, 7 insertions(+), 22 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 728321f..63e04f4 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -305,7 +305,6 @@ struct tcp_sock {
 	u32	rtt_seq;	/* sequence number to update rttvar	*/
=20
 	u32	packets_out;	/* Packets which are "in flight"	*/
-	u32	left_out;	/* Packets which leaved network	*/
 	u32	retrans_out;	/* Retransmitted packets out		*/
 /*
  *      Options received (usually on last packet, some only on SYN pac=
kets).
diff --git a/include/net/tcp.h b/include/net/tcp.h
index dd58cf2..5d866a4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -716,7 +716,8 @@ static inline void tcp_ca_event(struct sock *sk, co=
nst enum tcp_ca_event event)
  */
 static inline unsigned int tcp_packets_in_flight(const struct tcp_sock=
 *tp)
 {
-	return (tp->packets_out - tp->left_out + tp->retrans_out);
+	return tp->packets_out - (tp->sacked_out + tp->lost_out) +
+		tp->retrans_out;
 }
=20
 /* If cwnd > ssthresh, we may raise ssthresh to be half-way to cwnd.
@@ -738,7 +739,6 @@ static inline void tcp_sync_left_out(struct tcp_soc=
k *tp)
 {
 	BUG_ON(tp->rx_opt.sack_ok &&
 	       (tp->sacked_out + tp->lost_out > tp->packets_out));
-	tp->left_out =3D tp->sacked_out + tp->lost_out;
 }
=20
 extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4dab5d7..c17e077 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1301,8 +1301,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb,
 		}
 	}
=20
-	tp->left_out =3D tp->sacked_out + tp->lost_out;
-
 	if ((state.reord < tp->fackets_out) && icsk->icsk_ca_state !=3D TCP_C=
A_Loss &&
 	    (!tp->frto_highmark || after(tp->snd_una, tp->frto_highmark)))
 		tcp_update_reordering(sk, ((tp->fackets_out + 1) - state.reord), 0);
@@ -1363,7 +1361,6 @@ static void tcp_remove_reno_sacks(struct sock *sk=
, int acked)
 static inline void tcp_reset_reno_sack(struct tcp_sock *tp)
 {
 	tp->sacked_out =3D 0;
-	tp->left_out =3D tp->lost_out;
 }
=20
 int tcp_use_frto(struct sock *sk)
@@ -1526,7 +1523,6 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
=20
 void tcp_clear_retrans(struct tcp_sock *tp)
 {
-	tp->left_out =3D 0;
 	tp->retrans_out =3D 0;
=20
 	tp->fackets_out =3D 0;
@@ -2023,7 +2019,7 @@ static void DBGUNDO(struct sock *sk, const char *=
msg)
 	printk(KERN_DEBUG "Undo %s %u.%u.%u.%u/%u c%u l%u ss%u/%u p%u\n",
 	       msg,
 	       NIPQUAD(inet->daddr), ntohs(inet->dport),
-	       tp->snd_cwnd, tp->left_out,
+	       tp->snd_cwnd, tp->sacked_out + tp->lost_out,
 	       tp->snd_ssthresh, tp->prior_ssthresh,
 	       tp->packets_out);
 }
@@ -2152,7 +2148,6 @@ static int tcp_try_undo_loss(struct sock *sk)
=20
 		DBGUNDO(sk, "partial loss");
 		tp->lost_out =3D 0;
-		tp->left_out =3D tp->sacked_out;
 		tcp_undo_cwr(sk, 1);
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSSUNDO);
 		inet_csk(sk)->icsk_retransmits =3D 0;
@@ -2176,8 +2171,6 @@ static void tcp_try_to_open(struct sock *sk, int =
flag)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
-	tp->left_out =3D tp->sacked_out;
-
 	if (tp->retrans_out =3D=3D 0)
 		tp->retrans_stamp =3D 0;
=20
@@ -2187,7 +2180,7 @@ static void tcp_try_to_open(struct sock *sk, int =
flag)
 	if (inet_csk(sk)->icsk_ca_state !=3D TCP_CA_CWR) {
 		int state =3D TCP_CA_Open;
=20
-		if (tp->left_out || tp->retrans_out || tp->undo_marker)
+		if (tp->sacked_out || tp->retrans_out || tp->undo_marker)
 			state =3D TCP_CA_Disorder;
=20
 		if (inet_csk(sk)->icsk_ca_state !=3D state) {
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 42588eb..598ddec 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -399,7 +399,6 @@ struct sock *tcp_create_openreq_child(struct sock *=
sk, struct request_sock *req,
 		newicsk->icsk_rto =3D TCP_TIMEOUT_INIT;
=20
 		newtp->packets_out =3D 0;
-		newtp->left_out =3D 0;
 		newtp->retrans_out =3D 0;
 		newtp->sacked_out =3D 0;
 		newtp->fackets_out =3D 0;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8891775..d67fb3d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -682,10 +682,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *=
skb, u32 len, unsigned int mss
 		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
 			tp->retrans_out -=3D diff;
=20
-		if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST) {
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
 			tp->lost_out -=3D diff;
-			tp->left_out -=3D diff;
-		}
=20
 		if (diff > 0) {
 			/* Adjust Reno SACK estimate. */
@@ -1675,15 +1673,11 @@ static void tcp_retrans_try_collapse(struct soc=
k *sk, struct sk_buff *skb, int m
 		TCP_SKB_CB(skb)->sacked |=3D TCP_SKB_CB(next_skb)->sacked&(TCPCB_EVE=
R_RETRANS|TCPCB_AT_TAIL);
 		if (TCP_SKB_CB(next_skb)->sacked&TCPCB_SACKED_RETRANS)
 			tp->retrans_out -=3D tcp_skb_pcount(next_skb);
-		if (TCP_SKB_CB(next_skb)->sacked&TCPCB_LOST) {
+		if (TCP_SKB_CB(next_skb)->sacked&TCPCB_LOST)
 			tp->lost_out -=3D tcp_skb_pcount(next_skb);
-			tp->left_out -=3D tcp_skb_pcount(next_skb);
-		}
 		/* Reno case is special. Sigh... */
-		if (!tp->rx_opt.sack_ok && tp->sacked_out) {
+		if (!tp->rx_opt.sack_ok && tp->sacked_out)
 			tcp_dec_pcount_approx(&tp->sacked_out, next_skb);
-			tp->left_out -=3D tcp_skb_pcount(next_skb);
-		}
=20
 		/* Not quite right: it can be > snd.fack, but
 		 * it is better to underestimate fackets.
--=20
1.5.0.6

