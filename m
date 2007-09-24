From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/3] [TCP]: Re-place highest_sack check to a more robust position
Date: Mon, 24 Sep 2007 12:04:06 +0300
Message-ID: <11906246483657-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11906246483472-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50398 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbXIXJEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 05:04:10 -0400
In-Reply-To: <11906246483472-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I previously added checking to position that is rather poor as
state has already been adjusted quite a bit. Re-placing it above
all state changes should be more robust though the return should
never ever get executed regardless of its place :-).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cbb83ac..94c8011 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1718,6 +1718,10 @@ static void tcp_retrans_try_collapse(struct sock=
 *sk, struct sk_buff *skb, int m
 		BUG_ON(tcp_skb_pcount(skb) !=3D 1 ||
 		       tcp_skb_pcount(next_skb) !=3D 1);
=20
+		if (WARN_ON(tp->sacked_out &&
+		    (TCP_SKB_CB(next_skb)->seq =3D=3D tp->highest_sack)))
+			return;
+
 		/* Ok.	We will be able to collapse the packet. */
 		tcp_unlink_write_queue(next_skb, sk);
=20
@@ -1734,10 +1738,6 @@ static void tcp_retrans_try_collapse(struct sock=
 *sk, struct sk_buff *skb, int m
 		/* Update sequence range on original skb. */
 		TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(next_skb)->end_seq;
=20
-		if (WARN_ON(tp->sacked_out &&
-		    (TCP_SKB_CB(next_skb)->seq =3D=3D tp->highest_sack)))
-			return;
-
 		/* Merge over control information. */
 		flags |=3D TCP_SKB_CB(next_skb)->flags; /* This moves PSH/FIN etc. o=
ver */
 		TCP_SKB_CB(skb)->flags =3D flags;
--=20
1.5.0.6

