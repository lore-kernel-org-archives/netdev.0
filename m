From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 1/2] [TCP]: Add highest_sack seqno, points to globally
 highest SACK
Date: Thu, 8 Mar 2007 07:02:40 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703080658180.27671@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1939387232-1173330160=:27671"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Baruch Even <baruch@ev-en.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35470 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbXCHFCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 00:02:42 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1939387232-1173330160=:27671
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

It is maintained only in during slowpath of tcp_ack(). In most
cases this seqno is available in the last ACK but there is no
guarantee for that. The new fast recovery loss marking algorithm
needs this as entry point.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---


Now rebased these two patches against the latest net-2.6.22 (no additional 
patches are needed as DaveM included RB-tree there).



 include/linux/tcp.h      |    2 ++
 net/ipv4/tcp_input.c     |   12 ++++++++++++
 net/ipv4/tcp_minisocks.c |    1 +
 3 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index b73687a..807fc96 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -320,6 +320,8 @@ #endif
 
 	struct tcp_sack_block_wire recv_sack_cache[4];
 
+	u32	highest_sack;	/* Start seq of globally highest revd SACK (valid only in slowpath) */
+
 	/* from STCP, retrans queue hinting */
 	struct sk_buff* lost_skb_hint;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 22d0bb0..d738f8e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1188,6 +1188,10 @@ tcp_sacktag_write_queue(struct sock *sk,
 
 				if (fack_count > tp->fackets_out)
 					tp->fackets_out = fack_count;
+
+				if (after(TCP_SKB_CB(skb)->seq,
+				    tp->highest_sack))
+					tp->highest_sack = TCP_SKB_CB(skb)->seq;
 			} else {
 				if (dup_sack && (sacked&TCPCB_RETRANS))
 					reord = min(fack_count, reord);
@@ -2762,10 +2766,18 @@ static int tcp_ack(struct sock *sk, stru
 		else
 			NET_INC_STATS_BH(LINUX_MIB_TCPPUREACKS);
 
+		/* RFC: Transition from fast to slow path, is this a correct
+		 * way to detect it?
+		 */
+		if (tp->pred_flags)
+			tp->highest_sack = tp->snd_una;
+
 		flag |= tcp_ack_update_window(sk, tp, skb, ack, ack_seq);
 
 		if (TCP_SKB_CB(skb)->sacked)
 			flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una);
+		else if (before(tp->highest_sack, tp->snd_una))
+			tp->highest_sack = tp->snd_una;
 
 		if (TCP_ECN_rcv_ecn_echo(tp, skb->h.th))
 			flag |= FLAG_ECE;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 0a57c36..68d0000 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -389,6 +389,7 @@ struct sock *tcp_create_openreq_child(st
 		newtp->pred_flags = 0;
 		newtp->rcv_wup = newtp->copied_seq = newtp->rcv_nxt = treq->rcv_isn + 1;
 		newtp->snd_sml = newtp->snd_una = newtp->snd_nxt = treq->snt_isn + 1;
+		newtp->highest_sack = treq->snt_isn + 1;
 
 		tcp_prequeue_init(newtp);
 
-- 
1.4.2

---696243703-1939387232-1173330160=:27671--
