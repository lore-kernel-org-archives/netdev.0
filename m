From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 7/9] [TCP]: Correct fastpath entrypoint below high_seq
Date: Sat, 26 May 2007 11:36:00 +0300
Message-ID: <11801685621830-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621267-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685626-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685623173-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621216-git-send-email-ilpo.jarvinen@helsinki.fi> <1180168562576-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621520-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47757 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480AbXEZIgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 04:36:10 -0400
In-Reply-To: <11801685621520-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

In addition, implemented find_below using minus one. Some
reorganization was necessary to make code efficient again.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   31 +++++++++++++++++++++----------
 1 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fbce87f..8c1e38a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1913,22 +1913,33 @@ struct sk_buff *tcp_update_scoreboard_fack(stru=
ct sock *sk, u32 entry_seq,
 	struct sk_buff *skb;
 	unsigned int holes_seen =3D 0;
=20
-	skb =3D tcp_write_queue_find(sk, entry_seq);
-	/* If this ever becomes expensive, it can be delayed */
-	timedout_continue =3D tcp_write_queue_next(sk, skb);
 	if (entry_seq !=3D tp->highest_sack) {
-		/* Not interested in "the last" SACKed one we got */
-		/* RFC: find_below could help here too */
-		skb =3D tcp_write_queue_prev(sk, skb);
+		/* Look for skb below min_seq(entry_seq, tp->high_seq) */
+		if (!after(entry_seq, tp->high_seq)) {
+			skb =3D tcp_write_queue_find(sk, entry_seq - 1);
+		} else {
+			BUG_ON(tp->snd_una =3D=3D tp->high_seq);
+			skb =3D tcp_write_queue_find(sk, tp->high_seq - 1);
+		}
+
+		timedout_continue =3D NULL;
 		if (IsFack(tp) && tcp_skb_timedout(sk, skb) &&
 		    (tp->fackets_out < tp->packets_out)) {
-			timedout_continue =3D tcp_write_queue_find(sk, tp->highest_sack);
-			timedout_continue =3D tcp_write_queue_next(sk, timedout_continue);
-		} else
-			timedout_continue =3D NULL;
+			timedout_continue =3D tcp_write_queue_next(sk, skb);
+		    	if (!after(entry_seq, tp->high_seq)) {
+				/* Use latest SACK info in skipping past skbs */
+				timedout_continue =3D tcp_write_queue_find(sk, tp->highest_sack);
+				timedout_continue =3D tcp_write_queue_next(sk, timedout_continue);
+			}
+		}
+
 	} else {
 		unsigned int reord_count =3D IsFack(tp) ? 0 : 1;
=20
+		skb =3D tcp_write_queue_find(sk, entry_seq);
+		/* If this ever becomes expensive, it can be delayed */
+		timedout_continue =3D tcp_write_queue_next(sk, skb);
+
 		/* Phase I: Search until TCP can mark */
 		tcp_for_write_queue_backwards_from(skb, sk) {
 			if ((tp->fackets_out <=3D tp->sacked_out + tp->lost_out +
--=20
1.5.0.6

