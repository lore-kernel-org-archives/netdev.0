From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 15/21] [TCP]: Use per skb fack count instead of function argument
Date: Sun,  2 Dec 2007 00:48:10 +0200
Message-ID: <1196549297779-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492973133-git-send-email-ilpo.ja
 rvinen@helsinki.fi> <11965492972855-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33125 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752405AbXLAWsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:25 -0500
In-Reply-To: <11965492972855-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8a02de2..cc61916 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1328,12 +1328,16 @@ static int tcp_sacktag_one(struct sk_buff *skb,=
 struct sock *sk,
 static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct so=
ck *sk,
 					struct tcp_sack_block *next_dup,
 					u32 start_seq, u32 end_seq,
-					int dup_sack_in, int *fack_count,
-					int *reord, int *flag)
+					int dup_sack_in, int *reord, int *flag)
 {
+	unsigned int fack_count_base;
+
+	fack_count_base =3D TCP_SKB_CB(tcp_write_queue_head(sk))->fack_count;
+
 	tcp_for_write_queue_from(skb, sk, 0) {
 		int in_sack =3D 0;
 		int dup_sack =3D dup_sack_in;
+		unsigned int fack_count;
=20
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
@@ -1356,10 +1360,10 @@ static struct sk_buff *tcp_sacktag_walk(struct =
sk_buff *skb, struct sock *sk,
 		if (unlikely(in_sack < 0))
 			break;
=20
-		if (in_sack)
-			*flag |=3D tcp_sacktag_one(skb, sk, reord, dup_sack, *fack_count);
-
-		*fack_count +=3D tcp_skb_pcount(skb);
+		if (in_sack) {
+			fack_count =3D TCP_SKB_CB(skb)->fack_count - fack_count_base;
+			*flag |=3D tcp_sacktag_one(skb, sk, reord, dup_sack, fack_count);
+		}
 	}
 	return skb;
 }
@@ -1384,7 +1388,7 @@ static struct sk_buff *tcp_maybe_skipping_dsack(s=
truct sk_buff *skb,
 						struct sock *sk,
 						struct tcp_sack_block *next_dup,
 						u32 skip_to_seq,
-						int *fack_count, int *reord,
+						int *reord,
 						int *flag)
 {
 	if (next_dup =3D=3D NULL)
@@ -1394,7 +1398,7 @@ static struct sk_buff *tcp_maybe_skipping_dsack(s=
truct sk_buff *skb,
 		skb =3D tcp_sacktag_skip(skb, sk, next_dup->start_seq);
 		tcp_sacktag_walk(skb, sk, NULL,
 				 next_dup->start_seq, next_dup->end_seq,
-				 1, fack_count, reord, flag);
+				 1, reord, flag);
 	}
=20
 	return skb;
@@ -1421,7 +1425,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	int reord =3D tp->packets_out;
 	int flag =3D 0;
 	int found_dup_sack =3D 0;
-	int fack_count;
 	int i, j;
 	int first_sack_index;
=20
@@ -1499,7 +1502,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	}
=20
 	skb =3D tcp_write_queue_head(sk);
-	fack_count =3D 0;
 	i =3D 0;
=20
 	if (!tp->sacked_out) {
@@ -1540,7 +1542,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 				skb =3D tcp_sacktag_skip(skb, sk, start_seq);
 				skb =3D tcp_sacktag_walk(skb, sk, next_dup, start_seq,
 						       cache->start_seq, dup_sack,
-						       &fack_count, &reord, &flag);
+						       &reord, &flag);
 			}
=20
 			/* Rest of the block already fully processed? */
@@ -1548,7 +1550,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 				goto advance_sp;
=20
 			skb =3D tcp_maybe_skipping_dsack(skb, sk, next_dup, cache->end_seq,
-						       &fack_count, &reord, &flag);
+						       &reord, &flag);
=20
 			/* ...tail remains todo... */
 			if (tcp_highest_sack_seq(tp) =3D=3D cache->end_seq) {
@@ -1556,7 +1558,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 				skb =3D tcp_highest_sack(sk);
 				if (skb =3D=3D NULL)
 					break;
-				fack_count =3D tp->fackets_out;
 				cache++;
 				goto walk;
 			}
@@ -1571,13 +1572,12 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 			skb =3D tcp_highest_sack(sk);
 			if (skb =3D=3D NULL)
 				break;
-			fack_count =3D tp->fackets_out;
 		}
 		skb =3D tcp_sacktag_skip(skb, sk, start_seq);
=20
 walk:
 		skb =3D tcp_sacktag_walk(skb, sk, next_dup, start_seq, end_seq,
-				       dup_sack, &fack_count, &reord, &flag);
+				       dup_sack, &reord, &flag);
=20
 advance_sp:
 		/* SACK enhanced FRTO (RFC4138, Appendix B): Clearing correct
--=20
1.5.0.6

