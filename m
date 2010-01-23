From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v3 5/7] TCPCT part 2e: accept SYNACK data
Date: Sat, 23 Jan 2010 01:09:53 -0500
Message-ID: <4B5A92B1.6030408@gmail.com>
References: <4B5A88C4.7050205@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080505080008000401030600"
Cc: Andrew Morton <akpm@linux-foundation.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754053Ab0AWGJ6@vger.kernel.org>
In-Reply-To: <4B5A88C4.7050205@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080505080008000401030600
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

When accompanied by cookie option, Initiator (client) queues incoming
SYNACK transaction data.

This is a straightforward re-implementation of an earlier (year-old)
patch that no longer applies cleanly, with permission of the original
author (Adam Langley).  The patch was previously reviewed:

    http://thread.gmane.org/gmane.linux.network/102586

This function will also be used in subsequent patches that implement
additional features.

Requires:
   TCPCT part 1g: Responder Cookie => Initiator
   net: tcp_header_len_th and tcp_option_len_th

Signed-off-by: William.Allen.Simpson@gmail.com
---
  net/ipv4/tcp_input.c |   26 +++++++++++++++++++++++++-
  1 files changed, 25 insertions(+), 1 deletions(-)

--------------080505080008000401030600
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+2e3+2.6.33-rc5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+2e3+2.6.33-rc5.patch"

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8e0f6ae..165040e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5395,6 +5395,12 @@ discard:
 	return 0;
 }
 
+/*
+ * Returns:
+ *	+1 on reset,
+ *	0 success and/or SYNACK data,
+ *	-1 on discard.
+ */
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 					 struct tcphdr *th)
 {
@@ -5403,6 +5409,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_cookie_values *cvp = tp->cookie_values;
 	int saved_clamp = tp->rx_opt.mss_clamp;
+	int queued = 0;
 
 	tcp_parse_options(skb, &tp->rx_opt, &hash_location, 0);
 
@@ -5509,6 +5516,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 					- TCPOLEN_COOKIE_BASE;
 			int cookie_pair_size = cookie_size
 					     + cvp->cookie_desired;
+			int tcp_header_len = tcp_header_len_th(th);
 
 			/* A cookie extension option was sent and returned.
 			 * Note that each incoming SYNACK replaces the
@@ -5524,6 +5532,19 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 				       hash_location, cookie_size);
 				cvp->cookie_pair_size = cookie_pair_size;
 			}
+
+			queued = skb->len - tcp_header_len;
+			if (queued > 0) {
+				/* Queue incoming transaction data. */
+				__skb_pull(skb, tcp_header_len);
+				__skb_queue_tail(&sk->sk_receive_queue, skb);
+				skb_set_owner_r(skb, sk);
+				sk->sk_data_ready(sk, 0);
+				cvp->s_data_in = 1; /* true */
+				tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+				tp->rcv_wup = TCP_SKB_CB(skb)->end_seq;
+				tp->copied_seq = TCP_SKB_CB(skb)->seq + 1;
+			}
 		}
 
 		smp_mb();
@@ -5577,11 +5598,14 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 						  TCP_DELACK_MAX, TCP_RTO_MAX);
 
 discard:
-			__kfree_skb(skb);
+			if (queued <= 0)
+				__kfree_skb(skb);
 			return 0;
 		} else {
 			tcp_send_ack(sk);
 		}
+		if (queued > 0)
+			return 0;
 		return -1;
 	}
 
-- 
1.6.3.3


--------------080505080008000401030600--
