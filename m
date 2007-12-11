From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/2] [TCP]: Include __tcp_reset_fack_counts to non-__ version
Date: Tue, 11 Dec 2007 13:50:39 +0200
Message-ID: <11973738392955-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11973738391620-git-send-email-ilpo.jarvinen@helsinki.fi> <11973738393633-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48949 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbXLKLul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 06:50:41 -0500
In-Reply-To: <11973738393633-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes flow more obvious in case of short-circuit and
removes need for prev double pointer & fc recount per queue
switch.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h |   54 ++++++++++++++++++---------------------------=
-------
 1 files changed, 19 insertions(+), 35 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2d9949e..5e6c433 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1467,38 +1467,6 @@ static inline void __tcp_add_write_queue_head(st=
ruct sock *sk, struct sk_buff *s
 	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
=20
-static inline struct sk_buff *__tcp_reset_fack_counts(struct sock *sk,
-						      struct sk_buff *skb,
-						      struct sk_buff **prev,
-						      int queue)
-{
-	unsigned int fc =3D 0;
-
-	if (*prev !=3D NULL)
-		fc =3D TCP_SKB_CB(*prev)->fack_count + tcp_skb_pcount(*prev);
-
-	BUG_ON((*prev !=3D NULL) && !tcp_skb_adjacent(sk, *prev, skb));
-
-	tcp_for_write_queue_from(skb, sk, queue) {
-		if ((*prev !=3D NULL) && !tcp_skb_adjacent(sk, *prev, skb))
-			break;
-
-		/* Terminate whole search? */
-		if (!before(TCP_SKB_CB(skb)->seq, tcp_sk(sk)->snd_nxt) ||
-		    TCP_SKB_CB(skb)->fack_count =3D=3D fc) {
-			*prev =3D NULL;
-			return NULL;
-		}
-
-		TCP_SKB_CB(skb)->fack_count =3D fc;
-		fc +=3D tcp_skb_pcount(skb);
-
-		*prev =3D skb;
-	}
-
-	return skb;
-}
-
 /* An insert into the middle of the write queue causes the fack
  * counts in subsequent packets to become invalid, fix them up.
  *
@@ -1509,6 +1477,7 @@ static inline void tcp_reset_fack_counts(struct s=
ock *sk, struct sk_buff *inskb)
 	struct sk_buff *prev;
 	struct sk_buff *skb[2] =3D {NULL, NULL};
 	int queue;
+	unsigned int fc =3D 0;
=20
 	if (!before(TCP_SKB_CB(inskb)->seq, tcp_sk(sk)->snd_nxt))
 		return;
@@ -1531,6 +1500,9 @@ static inline void tcp_reset_fack_counts(struct s=
ock *sk, struct sk_buff *inskb)
 		skb[otherq] =3D prev->next;
 	}
=20
+	if (prev !=3D NULL)
+		fc =3D TCP_SKB_CB(prev)->fack_count + tcp_skb_pcount(prev);
+
 	while (skb[queue] !=3D (struct sk_buff *)__tcp_list_select(sk, queue)=
) {
 		/* Lazy find for the other queue */
 		if (skb[queue] =3D=3D NULL) {
@@ -1540,9 +1512,21 @@ static inline void tcp_reset_fack_counts(struct =
sock *sk, struct sk_buff *inskb)
 				break;
 		}
=20
-		skb[queue] =3D __tcp_reset_fack_counts(sk, skb[queue], &prev, queue)=
;
-		if (skb[queue] =3D=3D NULL)
-			break;
+		BUG_ON((prev !=3D NULL) && !tcp_skb_adjacent(sk, prev, skb[queue]));
+
+		tcp_for_write_queue_from(skb[queue], sk, queue) {
+			if ((prev !=3D NULL) && !tcp_skb_adjacent(sk, prev, skb[queue]))
+				break;
+
+			if (!before(TCP_SKB_CB(skb[queue])->seq, tcp_sk(sk)->snd_nxt) ||
+			    TCP_SKB_CB(skb[queue])->fack_count =3D=3D fc)
+				return;
+
+			TCP_SKB_CB(skb[queue])->fack_count =3D fc;
+			fc +=3D tcp_skb_pcount(skb[queue]);
+
+			prev =3D skb[queue];
+		}
=20
 		queue ^=3D TCP_WQ_SACKED;
 	}
--=20
1.5.0.6

