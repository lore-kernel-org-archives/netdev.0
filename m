From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2 net-next 01/15] tcp: Partial hint clearing has again become meaningless
Date: Sun, 21 Sep 2008 00:47:44 +0300
Message-ID: <1221947278-16715-2-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221947278-16715-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39570 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbYITVsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 17:48:01 -0400
In-Reply-To: <1221947278-16715-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ie., the difference between partial and all clearing doesn't
exists anymore since the SACK optimizations got dropped by
an sacktag rewrite.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    7 +------
 net/ipv4/tcp_input.c  |    5 ++---
 net/ipv4/tcp_output.c |    4 ++--
 3 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8983386..b716763 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1035,7 +1035,7 @@ static inline void tcp_mib_init(struct net *net)
 }
=20
 /* from STCP */
-static inline void tcp_clear_retrans_hints_partial(struct tcp_sock *tp=
)
+static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp)
 {
 	tp->lost_skb_hint =3D NULL;
 	tp->scoreboard_skb_hint =3D NULL;
@@ -1043,11 +1043,6 @@ static inline void tcp_clear_retrans_hints_parti=
al(struct tcp_sock *tp)
 	tp->forward_skb_hint =3D NULL;
 }
=20
-static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp)
-{
-	tcp_clear_retrans_hints_partial(tp);
-}
-
 /* MD5 Signature */
 struct crypto_hash;
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f79a516..7306bfb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1883,7 +1883,7 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
 	tp->high_seq =3D tp->snd_nxt;
 	TCP_ECN_queue_cwr(tp);
=20
-	tcp_clear_retrans_hints_partial(tp);
+	tcp_clear_all_retrans_hints(tp);
 }
=20
 static void tcp_clear_retrans_partial(struct tcp_sock *tp)
@@ -1934,12 +1934,11 @@ void tcp_enter_loss(struct sock *sk, int how)
 		/* Push undo marker, if it was plain RTO and nothing
 		 * was retransmitted. */
 		tp->undo_marker =3D tp->snd_una;
-		tcp_clear_retrans_hints_partial(tp);
 	} else {
 		tp->sacked_out =3D 0;
 		tp->fackets_out =3D 0;
-		tcp_clear_all_retrans_hints(tp);
 	}
+	tcp_clear_all_retrans_hints(tp);
=20
 	tcp_for_write_queue(skb, sk) {
 		if (skb =3D=3D tcp_send_head(sk))
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a00532d..2242c2c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -748,7 +748,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *s=
kb, u32 len,
=20
 	BUG_ON(len > skb->len);
=20
-	tcp_clear_retrans_hints_partial(tp);
+	tcp_clear_all_retrans_hints(tp);
 	nsize =3D skb_headlen(skb) - len;
 	if (nsize < 0)
 		nsize =3D 0;
@@ -1821,7 +1821,7 @@ static void tcp_retrans_try_collapse(struct sock =
*sk, struct sk_buff *skb,
 	tp->packets_out -=3D tcp_skb_pcount(next_skb);
=20
 	/* changed transmit queue under us so clear hints */
-	tcp_clear_retrans_hints_partial(tp);
+	tcp_clear_all_retrans_hints(tp);
=20
 	sk_wmem_free_skb(sk, next_skb);
 }
--=20
1.5.2.2

