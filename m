From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH] tcp: bug fix Fast Open client retransmission
Date: Thu,  6 Dec 2012 10:45:32 -0800
Message-ID: <1354819532-15676-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, nanditad@google.com,
	edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:50638 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964860Ab2LFSpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 13:45:46 -0500
Received: by mail-yh0-f74.google.com with SMTP id 10so675637yhl.1
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 10:45:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If SYN-ACK partially acks SYN-data, the client retransmits the
remaining data by tcp_retransmit_skb(). This increments lost recovery
state variables like tp->retrans_out in Open state. If loss recovery
happens before the retransmission is acked, it triggers the WARN_ON
check in tcp_fastretrans_alert(). For example: the client sends
SYN-data, gets SYN-ACK acking only ISN, retransmits data, sends
another 4 data packets and get 3 dupacks.

Since the retransmission is not caused by network drop it should not
update the recovery state variables. Further the server may return a
smaller MSS than the cached MSS used for SYN-data, so the retranmission
needs a loop. Otherwise some data will not be retransmitted until timeout
or other loss recovery events.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h     |    1 +
 net/ipv4/tcp_input.c  |    6 +++++-
 net/ipv4/tcp_output.c |   15 ++++++++++-----
 3 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3202bde..aed42c7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -524,6 +524,7 @@ static inline __u32 cookie_v6_init_sequence(struct sock *sk,
 extern void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
 				      int nonagle);
 extern bool tcp_may_send_now(struct sock *sk);
+extern int __tcp_retransmit_skb(struct sock *, struct sk_buff *);
 extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
 extern void tcp_retransmit_timer(struct sock *sk);
 extern void tcp_xmit_retransmit_queue(struct sock *);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fc67831..a136925 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5652,7 +5652,11 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 	tcp_fastopen_cache_set(sk, mss, cookie, syn_drop);
 
 	if (data) { /* Retransmit unacked data in SYN */
-		tcp_retransmit_skb(sk, data);
+		tcp_for_write_queue_from(data, sk) {
+			if (data == tcp_send_head(sk) ||
+			    __tcp_retransmit_skb(sk, data))
+				break;
+		}
 		tcp_rearm_rto(sk);
 		return true;
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8ac0855..5d45159 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2309,12 +2309,11 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
  * state updates are done by the caller.  Returns non-zero if an
  * error occurred which prevented the send.
  */
-int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
+int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	unsigned int cur_mss;
-	int err;
 
 	/* Inconslusive MTU probe */
 	if (icsk->icsk_mtup.probe_size) {
@@ -2387,11 +2386,17 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(NET_IP_ALIGN && ((unsigned long)skb->data & 3))) {
 		struct sk_buff *nskb = __pskb_copy(skb, MAX_TCP_HEADER,
 						   GFP_ATOMIC);
-		err = nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
-			     -ENOBUFS;
+		return nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
+			      -ENOBUFS;
 	} else {
-		err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
+		return tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 	}
+}
+
+int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	int err = __tcp_retransmit_skb(sk, skb);
 
 	if (err == 0) {
 		/* Update global TCP statistics. */
-- 
1.7.7.3
