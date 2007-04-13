From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/2] [TCP] FRTO: RFC4138 allows Nagle override when new
 data must be sent
Date: Fri, 13 Apr 2007 14:39:03 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704131435050.2963@kivilampi-30.cs.helsinki.fi>
References: <11762835513275-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1176283551509-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-889186248-1176464343=:2963"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42169 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753394AbXDMLjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 07:39:06 -0400
In-Reply-To: <1176283551509-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-889186248-1176464343=:2963
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Since you did update the abstraction part too (which I wasn't 
expecting). Here's the update version so that you don't have to resolve 
it.

[PATCH] [TCP] FRTO: RFC4138 allows Nagle override when new data must be sent

This is a corner case where less than MSS sized new data thingie
is awaiting in the send queue. For F-RTO to work correctly, a
new data segment must be sent at certain point or F-RTO cannot
be used at all. RFC4138 allows overriding of Nagle at that
point.

Implementation uses frto_counter states 2 and 3 to distinguish
when Nagle override is needed.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    5 +++++
 net/ipv4/tcp_input.c  |   13 ++++++++-----
 net/ipv4/tcp_output.c |    6 ++++--
 3 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 07f724e..55c2593 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1209,9 +1209,14 @@ static inline struct sk_buff *tcp_send_h
 
 static inline void tcp_advance_send_head(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	sk->sk_send_head = skb->next;
 	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
 		sk->sk_send_head = NULL;
+	/* Don't override Nagle indefinately with F-RTO */
+	if (tp->frto_counter == 2)
+		tp->frto_counter = 3;
 }
 
 static inline void tcp_check_send_head(struct sock *sk, struct sk_buff *skb_unlinked)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 43f5631..0384010 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2621,7 +2621,9 @@ static void tcp_undo_spur_to_response(st
  *                  algorithm is not part of the F-RTO detection algorithm
  *                  given in RFC4138 but can be selected separately).
  * Otherwise (basically on duplicate ACK), RTO was (likely) caused by a loss
- * and TCP falls back to conventional RTO recovery.
+ * and TCP falls back to conventional RTO recovery. F-RTO allows overriding
+ * of Nagle, this is done using frto_counter states 2 and 3, when a new data
+ * segment of any size sent during F-RTO, state 2 is upgraded to 3.
  *
  * Rationale: if the RTO was spurious, new ACKs should arrive from the
  * original window even after we transmit two new data segments.
@@ -2650,7 +2652,7 @@ static int tcp_process_frto(struct sock 
 		inet_csk(sk)->icsk_retransmits = 0;
 
 	if (!before(tp->snd_una, tp->frto_highmark)) {
-		tcp_enter_frto_loss(sk, tp->frto_counter + 1, flag);
+		tcp_enter_frto_loss(sk, (tp->frto_counter == 1 ? 2 : 3), flag);
 		return 1;
 	}
 
@@ -2676,7 +2678,7 @@ static int tcp_process_frto(struct sock 
 			return 1;
 		}
 
-		if ((tp->frto_counter == 2) &&
+		if ((tp->frto_counter >= 2) &&
 		    (!(flag&FLAG_FORWARD_PROGRESS) ||
 		     ((flag&FLAG_DATA_SACKED) && !(flag&FLAG_ONLY_ORIG_SACKED)))) {
 			/* RFC4138 shortcoming (see comment above) */
@@ -2693,14 +2695,15 @@ static int tcp_process_frto(struct sock 
 		if (!tcp_send_head(sk) ||
 		    after(TCP_SKB_CB(tcp_send_head(sk))->end_seq,
 				     tp->snd_una + tp->snd_wnd)) {
-			tcp_enter_frto_loss(sk, tp->frto_counter + 1, flag);
+			tcp_enter_frto_loss(sk, (tp->frto_counter == 1 ? 2 : 3),
+					    flag);
 			return 1;
 		}
 
 		tp->snd_cwnd = tcp_packets_in_flight(tp) + 2;
 		tp->frto_counter = 2;
 		return 1;
-	} else /* frto_counter == 2 */ {
+	} else {
 		switch (sysctl_tcp_frto_response) {
 		case 2:
 			tcp_undo_spur_to_response(sk, flag);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 94d9f0c..5394806 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1031,8 +1031,10 @@ static inline int tcp_nagle_test(struct 
 	if (nonagle & TCP_NAGLE_PUSH)
 		return 1;
 
-	/* Don't use the nagle rule for urgent data (or for the final FIN).  */
-	if (tp->urg_mode ||
+	/* Don't use the nagle rule for urgent data (or for the final FIN).
+	 * Nagle can be ignored during F-RTO too (see RFC4138).
+	 */
+	if (tp->urg_mode || (tp->frto_counter == 2) ||
 	    (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN))
 		return 1;
 
-- 
1.4.2

---696243703-889186248-1176464343=:2963--
