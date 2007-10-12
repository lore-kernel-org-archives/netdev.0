From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: high_seq parameter removed (all callers use tp->high_seq)
Date: Fri, 12 Oct 2007 17:02:18 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710121640200.3767@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-794334162-1192197738=:3767"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35340 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbXJLOCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 10:02:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-794334162-1192197738=:3767
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---

Compile tested with 2.6.23 as current Linus' tree provides an
hilarious building failure to our net-2.6 sandbox... :-)

 net/ipv4/tcp_input.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0a42e93..0f00966 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1995,8 +1995,7 @@ static void tcp_verify_retransmit_hint(struct tcp_sock *tp,
 }
 
 /* Mark head of queue up as lost. */
-static void tcp_mark_head_lost(struct sock *sk,
-			       int packets, u32 high_seq)
+static void tcp_mark_head_lost(struct sock *sk, int packets)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
@@ -2019,7 +2018,7 @@ static void tcp_mark_head_lost(struct sock *sk,
 		tp->lost_skb_hint = skb;
 		tp->lost_cnt_hint = cnt;
 		cnt += tcp_skb_pcount(skb);
-		if (cnt > packets || after(TCP_SKB_CB(skb)->end_seq, high_seq))
+		if (cnt > packets || after(TCP_SKB_CB(skb)->end_seq, tp->high_seq))
 			break;
 		if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST))) {
 			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
@@ -2040,9 +2039,9 @@ static void tcp_update_scoreboard(struct sock *sk)
 		int lost = tp->fackets_out - tp->reordering;
 		if (lost <= 0)
 			lost = 1;
-		tcp_mark_head_lost(sk, lost, tp->high_seq);
+		tcp_mark_head_lost(sk, lost);
 	} else {
-		tcp_mark_head_lost(sk, 1, tp->high_seq);
+		tcp_mark_head_lost(sk, 1);
 	}
 
 	/* New heuristics: it is possible only after we switched
@@ -2381,7 +2380,7 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state != TCP_CA_Open &&
 	    tp->fackets_out > tp->reordering) {
-		tcp_mark_head_lost(sk, tp->fackets_out-tp->reordering, tp->high_seq);
+		tcp_mark_head_lost(sk, tp->fackets_out - tp->reordering);
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
 	}
 
-- 
1.5.0.6

---696243703-794334162-1192197738=:3767--
