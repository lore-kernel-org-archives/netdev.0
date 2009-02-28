From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 06/17] tcp: fix corner case issue in segmentation during rexmitting
Date: Sat, 28 Feb 2009 16:44:31 +0200
Message-ID: <12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56777 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752623AbZB1Oor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:47 -0500
In-Reply-To: <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

If cur_mss grew very recently so that the previously G/TSOed skb
now fits well into a single segment it would get send up in
parts unless we calculate # of segments again. This corner-case
could happen eg. after mtu probe completes or less than
previously sack blocks are required for the opposite direction.

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3feab4d..77af7fa 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1921,6 +1921,8 @@ int tcp_retransmit_skb(struct sock *sk, struct sk=
_buff *skb)
 	if (skb->len > cur_mss) {
 		if (tcp_fragment(sk, skb, cur_mss, cur_mss))
 			return -ENOMEM; /* We'll try again later. */
+	} else {
+		tcp_init_tso_segs(sk, skb, cur_mss);
 	}
=20
 	tcp_retrans_try_collapse(sk, skb, cur_mss);
--=20
1.5.6.5

