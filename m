From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 05/17] tcp: Don't clear hints when tcp_fragmenting
Date: Sat, 28 Feb 2009 16:44:30 +0200
Message-ID: <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58368 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612AbZB1Oor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:47 -0500
In-Reply-To: <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

1) We didn't remove any skbs, so no need to handle stale refs.

2) scoreboard_skb_hint is trivial, no timestamps were changed
   so no need to clear that one

3) lost_skb_hint needs tweaking similar to that of
   tcp_sacktag_one().

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fa3c81a..3feab4d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -771,7 +771,6 @@ int tcp_fragment(struct sock *sk, struct sk_buff *s=
kb, u32 len,
=20
 	BUG_ON(len > skb->len);
=20
-	tcp_clear_retrans_hints_partial(tp);
 	nsize =3D skb_headlen(skb) - len;
 	if (nsize < 0)
 		nsize =3D 0;
@@ -854,6 +853,12 @@ int tcp_fragment(struct sock *sk, struct sk_buff *=
skb, u32 len,
 			tcp_verify_left_out(tp);
 		}
 		tcp_adjust_fackets_out(sk, skb, diff);
+
+		if (tp->lost_skb_hint &&
+		    before(TCP_SKB_CB(skb)->seq,
+			   TCP_SKB_CB(tp->lost_skb_hint)->seq) &&
+		    (tcp_is_fack(tp) || TCP_SKB_CB(skb)->sacked))
+			tp->lost_cnt_hint -=3D diff;
 	}
=20
 	/* Link BUFF into the send queue. */
--=20
1.5.6.5

