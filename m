From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 12/21] [TCP]: Introduce per skb fack_counts to retransmit queue
Date: Sun,  2 Dec 2007 00:48:07 +0200
Message-ID: <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi>
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
	with ESMTP id S1753176AbXLAWsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:22 -0500
In-Reply-To: <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

The fack count of any skb in the retransmit queue at any
given point in time is:

    (skb->fack_count - head_skb->fack_count)

And we'll use this in the SACK processing loops and possibly
elsewhere too.

Original idea came from David S. Miller, included couple of bug
fixes from Tom Quetchenbach <virtualphtn@gmail.com>.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5ec1cac..967f256 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -555,6 +555,7 @@ struct tcp_skb_cb {
 	__u32		seq;		/* Starting sequence number	*/
 	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
 	__u32		when;		/* used to compute rtt's	*/
+	unsigned int	fack_count;	/* speed up SACK processing	*/
 	__u8		flags;		/* TCP header flags.		*/
=20
 	/* NOTE: These must match up to the flags byte in a
@@ -1220,6 +1221,11 @@ static inline struct sk_buff *tcp_write_queue_ne=
xt(struct sock *sk, struct sk_bu
 	return skb->next;
 }
=20
+static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, st=
ruct sk_buff *skb)
+{
+	return skb->prev;
+}
+
 #define tcp_for_write_queue(skb, sk)					\
 		for (skb =3D (sk)->sk_write_queue.next;			\
 		     (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);	\
@@ -1241,6 +1247,11 @@ static inline struct sk_buff *tcp_send_head(stru=
ct sock *sk)
=20
 static inline void tcp_advance_send_head(struct sock *sk, struct sk_bu=
ff *skb)
 {
+	struct sk_buff *prev =3D tcp_write_queue_prev(sk, skb);
+
+	TCP_SKB_CB(skb)->fack_count =3D TCP_SKB_CB(prev)->fack_count +
+				      tcp_skb_pcount(prev);
+
 	sk->sk_send_head =3D skb->next;
 	if (sk->sk_send_head =3D=3D (struct sk_buff *)&sk->sk_write_queue)
 		sk->sk_send_head =3D NULL;
@@ -1259,6 +1270,7 @@ static inline void tcp_init_send_head(struct sock=
 *sk)
=20
 static inline void __tcp_add_write_queue_tail(struct sock *sk, struct =
sk_buff *skb)
 {
+	TCP_SKB_CB(skb)->fack_count =3D 0;
 	__skb_queue_tail(&sk->sk_write_queue, skb);
 }
=20
@@ -1275,9 +1287,36 @@ static inline void tcp_add_write_queue_tail(stru=
ct sock *sk, struct sk_buff *skb
 	}
 }
=20
+/* This is only used for tcp_send_synack(), so the write queue should
+ * be empty.  If that stops being true, the fack_count assignment
+ * will need to be more elaborate.
+ */
 static inline void __tcp_add_write_queue_head(struct sock *sk, struct =
sk_buff *skb)
 {
+	BUG_ON(!skb_queue_empty(&sk->sk_write_queue));
 	__skb_queue_head(&sk->sk_write_queue, skb);
+	TCP_SKB_CB(skb)->fack_count =3D 0;
+}
+
+/* An insert into the middle of the write queue causes the fack
+ * counts in subsequent packets to become invalid, fix them up.
+ */
+static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_bu=
ff *skb)
+{
+	struct sk_buff *prev =3D skb->prev;
+	unsigned int fc =3D 0;
+
+	if (prev !=3D (struct sk_buff *) &sk->sk_write_queue)
+		fc =3D TCP_SKB_CB(prev)->fack_count + tcp_skb_pcount(prev);
+
+	tcp_for_write_queue_from(skb, sk) {
+		if (!before(TCP_SKB_CB(skb)->seq, tcp_sk(sk)->snd_nxt) ||
+		    TCP_SKB_CB(skb)->fack_count =3D=3D fc)
+			break;
+
+		TCP_SKB_CB(skb)->fack_count =3D fc;
+		fc +=3D tcp_skb_pcount(skb);
+	}
 }
=20
 /* Insert buff after skb on the write queue of sk.  */
@@ -1286,6 +1325,7 @@ static inline void tcp_insert_write_queue_after(s=
truct sk_buff *skb,
 						struct sock *sk)
 {
 	__skb_append(skb, buff, &sk->sk_write_queue);
+	tcp_reset_fack_counts(sk, buff);
 }
=20
 /* Insert skb between prev and next on the write queue of sk.  */
@@ -1294,6 +1334,7 @@ static inline void tcp_insert_write_queue_before(=
struct sk_buff *new,
 						  struct sock *sk)
 {
 	__skb_insert(new, skb->prev, skb, &sk->sk_write_queue);
+	tcp_reset_fack_counts(sk, new);
=20
 	if (sk->sk_send_head =3D=3D skb)
 		sk->sk_send_head =3D new;
--=20
1.5.0.6

