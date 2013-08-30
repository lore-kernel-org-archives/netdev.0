From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net-next] tcp: Change return value of tcp_rcv_established()
Date: Thu, 29 Aug 2013 23:03:37 -0700
Message-ID: <1377842617-663-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:38951 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752390Ab3H3GGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 02:06:30 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so1450914pbb.0
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 23:06:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_rcv_established() returns only one value namely 0. We change the return
value to void (as suggested by David Miller).

After commit 0c24604b (tcp: implement RFC 5961 4.2), we no longer send RSTs in
response to SYNs. We can remove the check and processing on the return value of
tcp_rcv_established().

We also fix jtcp_rcv_established() in tcp_probe.c to match that of
tcp_rcv_established().

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
Changes: Earlier patch titled "tcp: Remove needless check of return value"
fixed only the second issue above.

 include/net/tcp.h    |    2 +-
 net/ipv4/tcp_input.c |   12 ++++++------
 net/ipv4/tcp_ipv4.c  |    5 +----
 net/ipv4/tcp_probe.c |    4 ++--
 net/ipv6/tcp_ipv6.c  |    3 +--
 5 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6a6a88d..9fb1917 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -371,7 +371,7 @@ extern void tcp_delack_timer_handler(struct sock *sk);
 extern int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 				 const struct tcphdr *th, unsigned int len);
-extern int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
+extern void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			       const struct tcphdr *th, unsigned int len);
 extern void tcp_rcv_space_adjust(struct sock *sk);
 extern void tcp_cleanup_rbuf(struct sock *sk, int copied);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1a84fff..2711acb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5049,7 +5049,7 @@ discard:
  *	the rest is checked inline. Fast processing is turned on in
  *	tcp_data_queue when everything is OK.
  */
-int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
+void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			const struct tcphdr *th, unsigned int len)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -5127,7 +5127,7 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				tcp_ack(sk, skb, 0);
 				__kfree_skb(skb);
 				tcp_data_snd_check(sk);
-				return 0;
+				return;
 			} else { /* Header too small */
 				TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
 				goto discard;
@@ -5220,7 +5220,7 @@ no_ack:
 			if (eaten)
 				kfree_skb_partial(skb, fragstolen);
 			sk->sk_data_ready(sk, 0);
-			return 0;
+			return;
 		}
 	}
 
@@ -5236,7 +5236,7 @@ slow_path:
 	 */
 
 	if (!tcp_validate_incoming(sk, skb, th, 1))
-		return 0;
+		return;
 
 step5:
 	if (tcp_ack(sk, skb, FLAG_SLOWPATH | FLAG_UPDATE_TS_RECENT) < 0)
@@ -5252,7 +5252,7 @@ step5:
 
 	tcp_data_snd_check(sk);
 	tcp_ack_snd_check(sk);
-	return 0;
+	return;
 
 csum_error:
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_CSUMERRORS);
@@ -5260,7 +5260,7 @@ csum_error:
 
 discard:
 	__kfree_skb(skb);
-	return 0;
+	return;
 }
 EXPORT_SYMBOL(tcp_rcv_established);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 09d45d7..b14266b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1799,10 +1799,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 				sk->sk_rx_dst = NULL;
 			}
 		}
-		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
-			rsk = sk;
-			goto reset;
-		}
+		tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len);
 		return 0;
 	}
 
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 622a437..8b10379 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -122,7 +122,7 @@ static inline int tcp_probe_avail(void)
  * Hook inserted to be called before each receive packet.
  * Note: arguments must match tcp_rcv_established()!
  */
-static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
+static void jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				const struct tcphdr *th, unsigned int len)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
@@ -172,7 +172,7 @@ static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	}
 
 	jprobe_return();
-	return 0;
+	return;
 }
 
 static struct jprobe tcp_jprobe = {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5bcfadf..9acdced 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1360,8 +1360,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 			}
 		}
 
-		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len))
-			goto reset;
+		tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len);
 		if (opt_skb)
 			goto ipv6_pktoptions;
 		return 0;
-- 
1.7.9.5
