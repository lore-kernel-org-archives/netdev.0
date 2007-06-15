From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH tcp-2.6 1/3] [TCP]: Add tcp_dec_pcount_approx int variant
Date: Fri, 15 Jun 2007 14:10:28 +0300
Message-ID: <11819058303890-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11819058302343-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58679 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbXFOLKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 07:10:32 -0400
In-Reply-To: <11819058302343-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |   11 ++++++++---
 net/ipv4/tcp_output.c |    8 ++------
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6f88d13..d12154a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -593,16 +593,21 @@ static inline int tcp_skb_mss(const struct sk_buf=
f *skb)
 	return skb_shinfo(skb)->gso_size;
 }
=20
-static inline void tcp_dec_pcount_approx(__u32 *count,
-					 const struct sk_buff *skb)
+static inline void tcp_dec_pcount_approx_int(__u32 *count, const int d=
ecr)
 {
 	if (*count) {
-		*count -=3D tcp_skb_pcount(skb);
+		*count -=3D decr;
 		if ((int)*count < 0)
 			*count =3D 0;
 	}
 }
=20
+static inline void tcp_dec_pcount_approx(__u32 *count,
+					 const struct sk_buff *skb)
+{
+	tcp_dec_pcount_approx_int(count, tcp_skb_pcount(skb));
+}
+
 static inline void tcp_packets_out_inc(struct sock *sk,
 				       const struct sk_buff *skb)
 {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 23ee283..c8be1c8 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -738,15 +738,11 @@ int tcp_fragment(struct sock *sk, struct sk_buff =
*skb, u32 len, unsigned int mss
 		if (diff > 0) {
 			/* Adjust Reno SACK estimate. */
 			if (!tp->rx_opt.sack_ok) {
-				tp->sacked_out -=3D diff;
-				if ((int)tp->sacked_out < 0)
-					tp->sacked_out =3D 0;
+				tcp_dec_pcount_approx_int(&tp->sacked_out, diff);
 				tcp_sync_left_out(tp);
 			}
=20
-			tp->fackets_out -=3D diff;
-			if ((int)tp->fackets_out < 0)
-				tp->fackets_out =3D 0;
+			tcp_dec_pcount_approx_int(&tp->fackets_out, diff);
 		}
 	}
=20
--=20
1.5.0.6

