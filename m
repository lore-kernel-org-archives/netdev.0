From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/3] [TCP]: Fix two off-by-one errors in fackets_out adjusting logic
Date: Wed,  3 Oct 2007 14:00:16 +0300
Message-ID: <11914092183725-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Cedric Le Goater <legoater@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45516 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625AbXJCLAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 07:00:20 -0400
In-Reply-To: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1) Passing wrong skb to tcp_adjust_fackets_out could corrupt
fastpath_cnt_hint as tcp_skb_pcount(next_skb) is not included
to it if hint points exactly to the next_skb (it's lagging
behind, see sacktag).

2) When fastpath_skb_hint is put backwards to avoid dangling
skb reference, the skb's pcount must also be removed from count
(not included like above).

Reported by Cedric Le Goater <legoater@free.fr>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6199abe..5329675 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1755,14 +1755,16 @@ static void tcp_retrans_try_collapse(struct soc=
k *sk, struct sk_buff *skb, int m
 		if (tcp_is_reno(tp) && tp->sacked_out)
 			tcp_dec_pcount_approx(&tp->sacked_out, next_skb);
=20
-		tcp_adjust_fackets_out(tp, skb, tcp_skb_pcount(next_skb));
+		tcp_adjust_fackets_out(tp, next_skb, tcp_skb_pcount(next_skb));
 		tp->packets_out -=3D tcp_skb_pcount(next_skb);
=20
 		/* changed transmit queue under us so clear hints */
 		tcp_clear_retrans_hints_partial(tp);
 		/* manually tune sacktag skb hint */
-		if (tp->fastpath_skb_hint =3D=3D next_skb)
+		if (tp->fastpath_skb_hint =3D=3D next_skb) {
 			tp->fastpath_skb_hint =3D skb;
+			tp->fastpath_cnt_hint -=3D tcp_skb_pcount(skb);
+		}
=20
 		sk_stream_free_skb(sk, next_skb);
 	}
--=20
1.5.0.6

