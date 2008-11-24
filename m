From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 04/10] tcp: Make SACK code to split only at mss boundaries
Date: Mon, 24 Nov 2008 16:22:01 +0200
Message-ID: <1227536527-29713-5-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52976 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbYKXOWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:22:11 -0500
In-Reply-To: <1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sadly enough, this adds possible divide though we try to avoid
it by checking one mss as common case.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   27 +++++++++++++++++++++++----
 1 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 84ca4f7..5e1e121 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1247,20 +1247,39 @@ static int tcp_match_skb_to_sack(struct sock *s=
k, struct sk_buff *skb,
 {
 	int in_sack, err;
 	unsigned int pkt_len;
+	unsigned int mss;
=20
 	in_sack =3D !after(start_seq, TCP_SKB_CB(skb)->seq) &&
 		  !before(end_seq, TCP_SKB_CB(skb)->end_seq);
=20
 	if (tcp_skb_pcount(skb) > 1 && !in_sack &&
 	    after(TCP_SKB_CB(skb)->end_seq, start_seq)) {
-
+	    	mss =3D tcp_skb_mss(skb);
 		in_sack =3D !after(start_seq, TCP_SKB_CB(skb)->seq);
=20
-		if (!in_sack)
+		if (!in_sack) {
 			pkt_len =3D start_seq - TCP_SKB_CB(skb)->seq;
-		else
+			if (pkt_len < mss)
+				pkt_len =3D mss;
+		} else {
 			pkt_len =3D end_seq - TCP_SKB_CB(skb)->seq;
-		err =3D tcp_fragment(sk, skb, pkt_len, skb_shinfo(skb)->gso_size);
+			if (pkt_len < mss)
+				return -EINVAL;
+		}
+
+		/* Round if necessary so that SACKs cover only full MSSes
+		 * and/or the remaining small portion (if present)
+		 */
+		if (pkt_len > mss) {
+			unsigned int new_len =3D (pkt_len / mss) * mss;
+			if (!in_sack && new_len < pkt_len) {
+				new_len +=3D mss;
+				if (new_len > skb->len)
+					return 0;
+			}
+			pkt_len =3D new_len;
+		}
+		err =3D tcp_fragment(sk, skb, pkt_len, mss);
 		if (err < 0)
 			return err;
 	}
--=20
1.5.2.2

