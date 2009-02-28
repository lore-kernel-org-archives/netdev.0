From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 08/17] tcp: separate timeout marking loop to it's own function
Date: Sat, 28 Feb 2009 16:44:33 +0200
Message-ID: <12358322833102-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53706 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641AbZB1Oot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:49 -0500
In-Reply-To: <12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

Some comment about its current state added. So far I have
seen very few cases where the thing is actually useful,
usually just marginally (though admittedly I don't usually
see top of window losses where it seems possible that there
could be some gain), instead, more often the cases suffer
from L-marking spike which is certainly not desirable
(I'll bury improving it to my todo list, but on a low
prio position).

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   63 +++++++++++++++++++++++++++++++-----------=
--------
 1 files changed, 39 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 125b451..03f5ede 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2461,6 +2461,44 @@ static int tcp_time_to_recover(struct sock *sk)
 	return 0;
 }
=20
+/* New heuristics: it is possible only after we switched to restart ti=
mer
+ * each time when something is ACKed. Hence, we can detect timed out p=
ackets
+ * during fast retransmit without falling to slow start.
+ *
+ * Usefulness of this as is very questionable, since we should know wh=
ich of
+ * the segments is the next to timeout which is relatively expensive t=
o find
+ * in general case unless we add some data structure just for that. Th=
e
+ * current approach certainly won't find the right one too often and w=
hen it
+ * finally does find _something_ it usually marks large part of the wi=
ndow
+ * right away (because a retransmission with a larger timestamp blocks=
 the
+ * loop from advancing). -ij
+ */
+static void tcp_timeout_skbs(struct sock *sk)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct sk_buff *skb;
+
+	if (!tcp_is_fack(tp) || !tcp_head_timedout(sk))
+		return;
+
+	skb =3D tp->scoreboard_skb_hint;
+	if (tp->scoreboard_skb_hint =3D=3D NULL)
+		skb =3D tcp_write_queue_head(sk);
+
+	tcp_for_write_queue_from(skb, sk) {
+		if (skb =3D=3D tcp_send_head(sk))
+			break;
+		if (!tcp_skb_timedout(sk, skb))
+			break;
+
+		tcp_skb_mark_lost(tp, skb);
+	}
+
+	tp->scoreboard_skb_hint =3D skb;
+
+	tcp_verify_left_out(tp);
+}
+
 /* Mark head of queue up as lost. With RFC3517 SACK, the packets is
  * is against sacked "cnt", otherwise it's against facked "cnt"
  */
@@ -2533,30 +2571,7 @@ static void tcp_update_scoreboard(struct sock *s=
k, int fast_rexmit)
 		tcp_mark_head_lost(sk, sacked_upto);
 	}
=20
-	/* New heuristics: it is possible only after we switched
-	 * to restart timer each time when something is ACKed.
-	 * Hence, we can detect timed out packets during fast
-	 * retransmit without falling to slow start.
-	 */
-	if (tcp_is_fack(tp) && tcp_head_timedout(sk)) {
-		struct sk_buff *skb;
-
-		skb =3D tp->scoreboard_skb_hint ? tp->scoreboard_skb_hint
-			: tcp_write_queue_head(sk);
-
-		tcp_for_write_queue_from(skb, sk) {
-			if (skb =3D=3D tcp_send_head(sk))
-				break;
-			if (!tcp_skb_timedout(sk, skb))
-				break;
-
-			tcp_skb_mark_lost(tp, skb);
-		}
-
-		tp->scoreboard_skb_hint =3D skb;
-
-		tcp_verify_left_out(tp);
-	}
+	tcp_timeout_skbs(sk);
 }
=20
 /* CWND moderation, preventing bursts due to too big ACKs
--=20
1.5.6.5

