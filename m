From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/4] [TCP]: No fackets_out/highest_sack tuning when SACK isn't enabled
Date: Mon,  1 Oct 2007 15:29:41 +0300
Message-ID: <11912417843256-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11912417841620-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40945 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbXJAM3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 08:29:45 -0400
In-Reply-To: <11912417841620-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This was found due to bug report from Cedric Le Goater though
it turned this turned out to be unrelated bug.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 94c8011..6199abe 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -660,7 +660,7 @@ static void tcp_set_skb_tso_segs(struct sock *sk, s=
truct sk_buff *skb, unsigned
 static void tcp_adjust_fackets_out(struct tcp_sock *tp, struct sk_buff=
 *skb,
 				   int decr)
 {
-	if (!tp->sacked_out)
+	if (!tp->sacked_out || tcp_is_reno(tp))
 		return;
=20
 	if (!before(tp->highest_sack, TCP_SKB_CB(skb)->seq))
@@ -712,7 +712,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *s=
kb, u32 len, unsigned int mss
 	TCP_SKB_CB(buff)->end_seq =3D TCP_SKB_CB(skb)->end_seq;
 	TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(buff)->seq;
=20
-	if (tp->sacked_out && (TCP_SKB_CB(skb)->seq =3D=3D tp->highest_sack))
+	if (tcp_is_sack(tp) && tp->sacked_out &&
+	    (TCP_SKB_CB(skb)->seq =3D=3D tp->highest_sack))
 		tp->highest_sack =3D TCP_SKB_CB(buff)->seq;
=20
 	/* PSH and FIN should only be set in the second packet. */
@@ -1718,7 +1719,7 @@ static void tcp_retrans_try_collapse(struct sock =
*sk, struct sk_buff *skb, int m
 		BUG_ON(tcp_skb_pcount(skb) !=3D 1 ||
 		       tcp_skb_pcount(next_skb) !=3D 1);
=20
-		if (WARN_ON(tp->sacked_out &&
+		if (WARN_ON(tcp_is_sack(tp) && tp->sacked_out &&
 		    (TCP_SKB_CB(next_skb)->seq =3D=3D tp->highest_sack)))
 			return;
=20
--=20
1.5.0.6

