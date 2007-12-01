From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 18/21] [TCP]: Move tcp_advance_highest_sack call early enough
Date: Sun,  2 Dec 2007 00:48:13 +0200
Message-ID: <11965492971718-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492973133-git-send-email-ilpo.ja
 rvinen@helsinki.fi> <11965492972855-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549297779-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492971864-git-send-email-ilpo.jarvinen@helsinki.f
 i> <11965492972309-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46714 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753721AbXLAWsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:25 -0500
In-Reply-To: <11965492972309-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

The call must be done before any queue moves occur (done in
the later patch).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c33efc9..7d5d316 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1260,6 +1260,9 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
truct sock *sk,
 			}
 		}
=20
+		if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
+			tcp_advance_highest_sack(sk, skb);
+
 		TCP_SKB_CB(skb)->sacked |=3D TCPCB_SACKED_ACKED;
 		flag |=3D FLAG_DATA_SACKED;
 		tp->sacked_out +=3D tcp_skb_pcount(skb);
@@ -1274,9 +1277,6 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
truct sock *sk,
=20
 		if (fack_count > tp->fackets_out)
 			tp->fackets_out =3D fack_count;
-
-		if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
-			tcp_advance_highest_sack(sk, skb);
 	}
=20
 	/* D-SACK. We can detect redundant retransmission in S|R and plain R
--=20
1.5.0.6

