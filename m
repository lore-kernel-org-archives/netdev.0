From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 13/17] tcp: kill eff_sacks "cache", the sole user can calculate itself
Date: Sat, 28 Feb 2009 16:44:38 +0200
Message-ID: <12358322832879-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322833102-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832711-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322834113-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832283214-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831599-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54623 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752779AbZB1Oox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:53 -0500
In-Reply-To: <12358322831599-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

Also fixes insignificant bug that would cause sending of stale
SACK block (would occur in some corner cases).

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h      |    1 -
 include/net/tcp.h        |    1 -
 net/ipv4/tcp_input.c     |   15 ++-------------
 net/ipv4/tcp_minisocks.c |    3 +--
 net/ipv4/tcp_output.c    |   12 ++++++------
 5 files changed, 9 insertions(+), 23 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 0cd99e6..4b86ad7 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -218,7 +218,6 @@ struct tcp_options_received {
 		snd_wscale : 4,	/* Window scaling received from sender	*/
 		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
 /*	SACKs data	*/
-	u8	eff_sacks;	/* Size of SACK array to send with next packet */
 	u8	num_sacks;	/* Number of SACK blocks		*/
 	u16	user_mss;  	/* mss requested by user in ioctl */
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0366a55..055e494 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -926,7 +926,6 @@ extern void tcp_done(struct sock *sk);
 static inline void tcp_sack_reset(struct tcp_options_received *rx_opt)
 {
 	rx_opt->dsack =3D 0;
-	rx_opt->eff_sacks =3D 0;
 	rx_opt->num_sacks =3D 0;
 }
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 03f5ede..e4442a2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4099,7 +4099,6 @@ static void tcp_dsack_set(struct sock *sk, u32 se=
q, u32 end_seq)
 		tp->rx_opt.dsack =3D 1;
 		tp->duplicate_sack[0].start_seq =3D seq;
 		tp->duplicate_sack[0].end_seq =3D end_seq;
-		tp->rx_opt.eff_sacks =3D tp->rx_opt.num_sacks + 1;
 	}
 }
=20
@@ -4154,8 +4153,6 @@ static void tcp_sack_maybe_coalesce(struct tcp_so=
ck *tp)
 			 * Decrease num_sacks.
 			 */
 			tp->rx_opt.num_sacks--;
-			tp->rx_opt.eff_sacks =3D tp->rx_opt.num_sacks +
-					       tp->rx_opt.dsack;
 			for (i =3D this_sack; i < tp->rx_opt.num_sacks; i++)
 				sp[i] =3D sp[i + 1];
 			continue;
@@ -4218,7 +4215,6 @@ new_sack:
 	sp->start_seq =3D seq;
 	sp->end_seq =3D end_seq;
 	tp->rx_opt.num_sacks++;
-	tp->rx_opt.eff_sacks =3D tp->rx_opt.num_sacks + tp->rx_opt.dsack;
 }
=20
 /* RCV.NXT advances, some SACKs should be eaten. */
@@ -4232,7 +4228,6 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 	/* Empty ofo queue, hence, all the SACKs are eaten. Clear. */
 	if (skb_queue_empty(&tp->out_of_order_queue)) {
 		tp->rx_opt.num_sacks =3D 0;
-		tp->rx_opt.eff_sacks =3D tp->rx_opt.dsack;
 		return;
 	}
=20
@@ -4253,11 +4248,8 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 		this_sack++;
 		sp++;
 	}
-	if (num_sacks !=3D tp->rx_opt.num_sacks) {
+	if (num_sacks !=3D tp->rx_opt.num_sacks)
 		tp->rx_opt.num_sacks =3D num_sacks;
-		tp->rx_opt.eff_sacks =3D tp->rx_opt.num_sacks +
-				       tp->rx_opt.dsack;
-	}
 }
=20
 /* This one checks to see if we can put data from the
@@ -4333,10 +4325,8 @@ static void tcp_data_queue(struct sock *sk, stru=
ct sk_buff *skb)
=20
 	TCP_ECN_accept_cwr(tp, skb);
=20
-	if (tp->rx_opt.dsack) {
+	if (tp->rx_opt.dsack)
 		tp->rx_opt.dsack =3D 0;
-		tp->rx_opt.eff_sacks =3D tp->rx_opt.num_sacks;
-	}
=20
 	/*  Queue data for delivery to the user.
 	 *  Packets in sequence go to the receive queue.
@@ -4456,7 +4446,6 @@ drop:
 		if (tcp_is_sack(tp)) {
 			tp->rx_opt.num_sacks =3D 1;
 			tp->rx_opt.dsack     =3D 0;
-			tp->rx_opt.eff_sacks =3D 1;
 			tp->selective_acks[0].start_seq =3D TCP_SKB_CB(skb)->seq;
 			tp->selective_acks[0].end_seq =3D
 						TCP_SKB_CB(skb)->end_seq;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f67effb..bb3d8b3 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -434,9 +434,8 @@ struct sock *tcp_create_openreq_child(struct sock *=
sk, struct request_sock *req,
 		newtp->rx_opt.saw_tstamp =3D 0;
=20
 		newtp->rx_opt.dsack =3D 0;
-		newtp->rx_opt.eff_sacks =3D 0;
-
 		newtp->rx_opt.num_sacks =3D 0;
+
 		newtp->urg_data =3D 0;
=20
 		if (sock_flag(newsk, SOCK_KEEPOPEN))
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 61445b5..1555bb7 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -441,10 +441,8 @@ static void tcp_options_write(__be32 *ptr, struct =
tcp_sock *tp,
 			*ptr++ =3D htonl(sp[this_sack].end_seq);
 		}
=20
-		if (tp->rx_opt.dsack) {
+		if (tp->rx_opt.dsack)
 			tp->rx_opt.dsack =3D 0;
-			tp->rx_opt.eff_sacks =3D tp->rx_opt.num_sacks;
-		}
 	}
 }
=20
@@ -550,6 +548,7 @@ static unsigned tcp_established_options(struct sock=
 *sk, struct sk_buff *skb,
 	struct tcp_skb_cb *tcb =3D skb ? TCP_SKB_CB(skb) : NULL;
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	unsigned size =3D 0;
+	unsigned int eff_sacks;
=20
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 =3D tp->af_specific->md5_lookup(sk, sk);
@@ -568,10 +567,11 @@ static unsigned tcp_established_options(struct so=
ck *sk, struct sk_buff *skb,
 		size +=3D TCPOLEN_TSTAMP_ALIGNED;
 	}
=20
-	if (unlikely(tp->rx_opt.eff_sacks)) {
+	eff_sacks =3D tp->rx_opt.num_sacks + tp->rx_opt.dsack;
+	if (unlikely(eff_sacks)) {
 		const unsigned remaining =3D MAX_TCP_OPTION_SPACE - size;
 		opts->num_sack_blocks =3D
-			min_t(unsigned, tp->rx_opt.eff_sacks,
+			min_t(unsigned, eff_sacks,
 			      (remaining - TCPOLEN_SACK_BASE_ALIGNED) /
 			      TCPOLEN_SACK_PERBLOCK);
 		size +=3D TCPOLEN_SACK_BASE_ALIGNED +
@@ -1418,7 +1418,7 @@ static int tcp_mtu_probe(struct sock *sk)
 	    icsk->icsk_mtup.probe_size ||
 	    inet_csk(sk)->icsk_ca_state !=3D TCP_CA_Open ||
 	    tp->snd_cwnd < 11 ||
-	    tp->rx_opt.eff_sacks)
+	    tp->rx_opt.num_sacks || tp->rx_opt.dsack)
 		return -1;
=20
 	/* Very simple search strategy: just double the MSS. */
--=20
1.5.6.5

