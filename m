From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 07/21] [TCP]: Add tcp_for_write_queue_from_safe and use it in mtu_probe
Date: Sun,  2 Dec 2007 00:48:02 +0200
Message-ID: <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi>
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
	with ESMTP id S1752897AbXLAWsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:20 -0500
In-Reply-To: <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    5 +++++
 net/ipv4/tcp_output.c |    8 ++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index cdd0050..6e392ba 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1229,6 +1229,11 @@ static inline struct sk_buff *tcp_write_queue_ne=
xt(struct sock *sk, struct sk_bu
 		for (; (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);\
 		     skb =3D skb->next)
=20
+#define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
+		for (tmp =3D skb->next;					\
+		     (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);	\
+		     skb =3D tmp, tmp =3D skb->next)
+
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
 {
 	return sk->sk_send_head;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 20365c0..4f2bd70 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1351,9 +1351,7 @@ static int tcp_mtu_probe(struct sock *sk)
 	tcp_insert_write_queue_before(nskb, skb, sk);
=20
 	len =3D 0;
-	while (len < probe_size) {
-		next =3D tcp_write_queue_next(sk, skb);
-
+	tcp_for_write_queue_from_safe(skb, next, sk) {
 		copy =3D min_t(int, skb->len, probe_size - len);
 		if (nskb->ip_summed)
 			skb_copy_bits(skb, 0, skb_put(nskb, copy), copy);
@@ -1382,7 +1380,9 @@ static int tcp_mtu_probe(struct sock *sk)
 		}
=20
 		len +=3D copy;
-		skb =3D next;
+
+		if (len >=3D probe_size)
+			break;
 	}
 	tcp_init_tso_segs(sk, nskb, nskb->len);
=20
--=20
1.5.0.6

