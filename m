From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25] [TCP]: Create tcp_mark_head_lost_single for
 NewReno
Date: Wed, 5 Dec 2007 12:19:04 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712051217380.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-216939987-1196849944=:18529"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33021 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbXLEKTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 05:19:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-216939987-1196849944=:18529
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Fixes NewReno breakage that got introduced because reno ended up
into RFC3517 counting branch in tcp_mark_head_lost after the
split space tweaks. The fack branch would have worked, however,
coming lost marker updates would eventually add this anyway.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f1eee2d..e410c21 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2120,6 +2120,21 @@ static void tcp_verify_retransmit_hint(struct tcp_sock *tp,
 		tp->retransmit_skb_hint = NULL;
 }
 
+/* Simple NewReno thing: Mark head LOST if it wasn't yet and it's below
+ * high_seq, stop. That's all.
+ */
+static void tcp_mark_head_lost_single(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb = tcp_write_queue_head(sk);
+
+	if (!(TCP_SKB_CB(skb)->sacked & TCPCB_LOST) &&
+	    before(tp->snd_una, tp->high_seq)) {
+		TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
+		tp->lost_out += tcp_skb_pcount(skb);
+	}
+}
+
 /* Mark head of queue up as lost. With RFC3517 SACK, the packets is
  * is against sacked "cnt", otherwise it's against facked "cnt"
  */
@@ -2172,7 +2187,6 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_rexmit)
 			tcp_verify_retransmit_hint(tp, skb);
 		}
 	}
-	tcp_verify_left_out(tp);
 }
 
 /* Account newly detected lost packet(s) */
@@ -2182,7 +2196,7 @@ static void tcp_update_scoreboard(struct sock *sk, int fast_rexmit)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (tcp_is_reno(tp)) {
-		tcp_mark_head_lost(sk, 1, fast_rexmit);
+		tcp_mark_head_lost_single(sk);
 	} else if (tcp_is_fack(tp)) {
 		int lost = tp->fackets_out - tp->reordering;
 		if (lost <= 0)
@@ -2195,6 +2209,8 @@ static void tcp_update_scoreboard(struct sock *sk, int fast_rexmit)
 		tcp_mark_head_lost(sk, sacked_upto, fast_rexmit);
 	}
 
+	tcp_verify_left_out(tp);
+
 	/* New heuristics: it is possible only after we switched
 	 * to restart timer each time when something is ACKed.
 	 * Hence, we can detect timed out packets during fast
-- 
1.5.0.6

---696243703-216939987-1196849944=:18529--
