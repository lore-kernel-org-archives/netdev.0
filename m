From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/2] [TCP]: Push fack_count calculation deeper into functions
Date: Tue, 11 Dec 2007 13:50:38 +0200
Message-ID: <11973738393633-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11973738391620-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44578 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbXLKLul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 06:50:41 -0500
In-Reply-To: <11973738391620-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This shouldn't have a significant impact because the call to
tcp_sacktag_one is typically made just once per ACK (this
doesn't hold if there were some ACK losses in between or the
receiver didn't generate all ACKs that it should have, but
those are not very likely events to occur).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 75a16b3..977c68c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1214,11 +1214,15 @@ static int tcp_match_skb_to_sack(struct sock *s=
k, struct sk_buff *skb,
 }
=20
 static int tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
-			   int *reord, int dup_sack, int fack_count)
+			   int *reord, int dup_sack)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	u8 sacked =3D TCP_SKB_CB(skb)->sacked;
 	int flag =3D 0;
+	int fack_count;
+=09
+	fack_count =3D TCP_SKB_CB(skb)->fack_count -
+			TCP_SKB_CB(tcp_write_queue_head(sk))->fack_count;
=20
 	/* Account D-SACK for retransmitted packet. */
 	if (dup_sack && (sacked & TCPCB_RETRANS)) {
@@ -1315,13 +1319,9 @@ static struct sk_buff *tcp_sacktag_walk(struct s=
k_buff *skb, struct sock *sk,
 					int queue)
 {
 	struct sk_buff *next;
-	unsigned int fack_count_base;
-
-	fack_count_base =3D TCP_SKB_CB(tcp_write_queue_head(sk))->fack_count;
=20
 	tcp_for_write_queue_from_safe(skb, next, sk, queue) {
 		int in_sack =3D 0;
-		unsigned int fack_count;
=20
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
@@ -1334,10 +1334,8 @@ static struct sk_buff *tcp_sacktag_walk(struct s=
k_buff *skb, struct sock *sk,
 		if (unlikely(in_sack < 0))
 			break;
=20
-		if (in_sack) {
-			fack_count =3D TCP_SKB_CB(skb)->fack_count - fack_count_base;
-			*flag |=3D tcp_sacktag_one(skb, sk, reord, dup_sack, fack_count);
-		}
+		if (in_sack)
+			*flag |=3D tcp_sacktag_one(skb, sk, reord, dup_sack);
 	}
 	return skb;
 }
--=20
1.5.0.6

