From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 9/9] [TCP]: Avoid clearing sacktag hint in trivial situations
Date: Thu, 20 Sep 2007 15:17:52 +0300
Message-ID: <11902906723220-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11902906724088-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723619-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723822-git-send-email-ilpo.jarvinen@helsinki.fi> <1190290672770-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906721671-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723159-git-send-email-ilpo.jarvinen@helsinki.fi> <1190290672980-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723907-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46855 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbXITMR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 08:17:57 -0400
In-Reply-To: <11902906723907-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no reason to clear the sacktag skb hint when small part
of the rexmit queue changes. Account changes (if any) instead when
fragmenting/collapsing. RTO/FRTO do not touch SACKED_ACKED bits so
no need to discard SACK tag hint at all.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    6 +++++-
 net/ipv4/tcp_input.c  |   14 ++++++++------
 net/ipv4/tcp_output.c |   12 ++++++++----
 3 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 16dfe3c..07b1faa 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1067,11 +1067,15 @@ static inline void tcp_mib_init(void)
 }
=20
 /* from STCP */
-static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp) {
+static inline void tcp_clear_retrans_hints_partial(struct tcp_sock *tp=
) {
 	tp->lost_skb_hint =3D NULL;
 	tp->scoreboard_skb_hint =3D NULL;
 	tp->retransmit_skb_hint =3D NULL;
 	tp->forward_skb_hint =3D NULL;
+}
+
+static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp) {
+	tcp_clear_retrans_hints_partial(tp);
 	tp->fastpath_skb_hint =3D NULL;
 }
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 02b549b..1092b5a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1674,7 +1674,7 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
 	tp->high_seq =3D tp->frto_highmark;
 	TCP_ECN_queue_cwr(tp);
=20
-	tcp_clear_all_retrans_hints(tp);
+	tcp_clear_retrans_hints_partial(tp);
 }
=20
 void tcp_clear_retrans(struct tcp_sock *tp)
@@ -1714,10 +1714,14 @@ void tcp_enter_loss(struct sock *sk, int how)
 	tp->bytes_acked =3D 0;
 	tcp_clear_retrans(tp);
=20
-	/* Push undo marker, if it was plain RTO and nothing
-	 * was retransmitted. */
-	if (!how)
+	if (!how) {
+		/* Push undo marker, if it was plain RTO and nothing
+		 * was retransmitted. */
 		tp->undo_marker =3D tp->snd_una;
+		tcp_clear_retrans_hints_partial(tp);
+	} else {
+		tcp_clear_all_retrans_hints(tp);
+	}
=20
 	tcp_for_write_queue(skb, sk) {
 		if (skb =3D=3D tcp_send_head(sk))
@@ -1744,8 +1748,6 @@ void tcp_enter_loss(struct sock *sk, int how)
 	TCP_ECN_queue_cwr(tp);
 	/* Abort FRTO algorithm if one is in progress */
 	tp->frto_counter =3D 0;
-
-	tcp_clear_all_retrans_hints(tp);
 }
=20
 static int tcp_check_sack_reneging(struct sock *sk)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f46d24b..cbb83ac 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -687,7 +687,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *s=
kb, u32 len, unsigned int mss
=20
 	BUG_ON(len > skb->len);
=20
-	tcp_clear_all_retrans_hints(tp);
+	tcp_clear_retrans_hints_partial(tp);
 	nsize =3D skb_headlen(skb) - len;
 	if (nsize < 0)
 		nsize =3D 0;
@@ -1718,9 +1718,6 @@ static void tcp_retrans_try_collapse(struct sock =
*sk, struct sk_buff *skb, int m
 		BUG_ON(tcp_skb_pcount(skb) !=3D 1 ||
 		       tcp_skb_pcount(next_skb) !=3D 1);
=20
-		/* changing transmit queue under us so clear hints */
-		tcp_clear_all_retrans_hints(tp);
-
 		/* Ok.	We will be able to collapse the packet. */
 		tcp_unlink_write_queue(next_skb, sk);
=20
@@ -1759,6 +1756,13 @@ static void tcp_retrans_try_collapse(struct sock=
 *sk, struct sk_buff *skb, int m
=20
 		tcp_adjust_fackets_out(tp, skb, tcp_skb_pcount(next_skb));
 		tp->packets_out -=3D tcp_skb_pcount(next_skb);
+
+		/* changed transmit queue under us so clear hints */
+		tcp_clear_retrans_hints_partial(tp);
+		/* manually tune sacktag skb hint */
+		if (tp->fastpath_skb_hint =3D=3D next_skb)
+			tp->fastpath_skb_hint =3D skb;
+
 		sk_stream_free_skb(sk, next_skb);
 	}
 }
--=20
1.5.0.6

