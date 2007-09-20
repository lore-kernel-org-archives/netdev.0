From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/9] [TCP]: Maintain highest_sack accurately to the highest skb
Date: Thu, 20 Sep 2007 15:17:44 +0300
Message-ID: <11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11902906724088-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46855 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbXITMRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 08:17:54 -0400
In-Reply-To: <11902906724088-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In general, it should not be necessary to call tcp_fragment for
already SACKed skbs, but it's better to be safe than sorry. And
indeed, it can be called from sacktag when a DSACK arrives or
some ACK (with SACK) reordering occurs (sacktag could be made
to avoid the call in the latter case though I'm not sure if it's
worth of the trouble and added complexity to cover such marginal
case).

The collapse case has return for SACKED_ACKED case earlier, so
just WARN_ON if internal inconsistency is detected for some
reason.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d65d17b..9df5b2a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -692,6 +692,9 @@ int tcp_fragment(struct sock *sk, struct sk_buff *s=
kb, u32 len, unsigned int mss
 	TCP_SKB_CB(buff)->end_seq =3D TCP_SKB_CB(skb)->end_seq;
 	TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(buff)->seq;
=20
+	if (tp->sacked_out && (TCP_SKB_CB(skb)->seq =3D=3D tp->highest_sack))
+		tp->highest_sack =3D TCP_SKB_CB(buff)->seq;
+
 	/* PSH and FIN should only be set in the second packet. */
 	flags =3D TCP_SKB_CB(skb)->flags;
 	TCP_SKB_CB(skb)->flags =3D flags & ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
@@ -1723,6 +1726,10 @@ static void tcp_retrans_try_collapse(struct sock=
 *sk, struct sk_buff *skb, int m
 		/* Update sequence range on original skb. */
 		TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(next_skb)->end_seq;
=20
+		if (WARN_ON(tp->sacked_out &&
+		    (TCP_SKB_CB(next_skb)->seq =3D=3D tp->highest_sack)))
+			return;
+
 		/* Merge over control information. */
 		flags |=3D TCP_SKB_CB(next_skb)->flags; /* This moves PSH/FIN etc. o=
ver */
 		TCP_SKB_CB(skb)->flags =3D flags;
--=20
1.5.0.6

