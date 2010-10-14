From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcp: sack lost marking fixes
Date: Thu, 14 Oct 2010 14:42:30 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1010141429150.26447@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-831579712-1287056550=:26447"
Cc: Yuchung Cheng <ycheng@google.com>,
	Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
To: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36194 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753354Ab0JNLmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 07:42:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-831579712-1287056550=:26447
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

When only fast rexmit should be done, tcp_mark_head_lost marks
L too far. Also, sacked_upto below 1 is perfectly valid number,
the packets == 0 then needs to be trapped elsewhere.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
I think 6830c25b7d08fbbd922959425193791bc42079f2 that added the
packets == 0 check is mostly wrong but I cc'ed Lennart if he has some 
particular case I'm missing that wouldn't work after this patch.

Dave, no particular "bad regression" fixed here, so no absolute need to 
have this in net-2.6 but I leave it up to you whether there or net-next.

 net/ipv4/tcp_input.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 548d575..9924cd1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2504,7 +2504,7 @@ static void tcp_timeout_skbs(struct sock *sk)
 /* Mark head of queue up as lost. With RFC3517 SACK, the packets is
  * is against sacked "cnt", otherwise it's against facked "cnt"
  */
-static void tcp_mark_head_lost(struct sock *sk, int packets)
+static void tcp_mark_head_lost(struct sock *sk, int packets, int mark_head)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
@@ -2512,13 +2512,13 @@ static void tcp_mark_head_lost(struct sock *sk, int packets)
 	int err;
 	unsigned int mss;
 
-	if (packets == 0)
-		return;
-
 	WARN_ON(packets > tp->packets_out);
 	if (tp->lost_skb_hint) {
 		skb = tp->lost_skb_hint;
 		cnt = tp->lost_cnt_hint;
+		/* Head already handled? */
+		if (mark_head && skb != tcp_write_queue_head(sk))
+			return;
 	} else {
 		skb = tcp_write_queue_head(sk);
 		cnt = 0;
@@ -2552,6 +2552,9 @@ static void tcp_mark_head_lost(struct sock *sk, int packets)
 		}
 
 		tcp_skb_mark_lost(tp, skb);
+
+		if (mark_head)
+			break;
 	}
 	tcp_verify_left_out(tp);
 }
@@ -2563,17 +2566,18 @@ static void tcp_update_scoreboard(struct sock *sk, int fast_rexmit)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (tcp_is_reno(tp)) {
-		tcp_mark_head_lost(sk, 1);
+		tcp_mark_head_lost(sk, 1, 1);
 	} else if (tcp_is_fack(tp)) {
 		int lost = tp->fackets_out - tp->reordering;
 		if (lost <= 0)
 			lost = 1;
-		tcp_mark_head_lost(sk, lost);
+		tcp_mark_head_lost(sk, lost, 0);
 	} else {
 		int sacked_upto = tp->sacked_out - tp->reordering;
-		if (sacked_upto < fast_rexmit)
-			sacked_upto = fast_rexmit;
-		tcp_mark_head_lost(sk, sacked_upto);
+		if (sacked_upto >= 0)
+			tcp_mark_head_lost(sk, sacked_upto, 0);
+		else if (fast_rexmit)
+			tcp_mark_head_lost(sk, 1, 1);
 	}
 
 	tcp_timeout_skbs(sk);
@@ -2978,7 +2982,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state != TCP_CA_Open &&
 	    tp->fackets_out > tp->reordering) {
-		tcp_mark_head_lost(sk, tp->fackets_out - tp->reordering);
+		tcp_mark_head_lost(sk, tp->fackets_out - tp->reordering, 0);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSS);
 	}
 
-- 
1.5.6.5

--8323329-831579712-1287056550=:26447--
