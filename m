From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v2 RFC 3/5] TCPCT part 2c: accept SYNACK data
Date: Thu, 31 Dec 2009 14:52:25 -0500
Message-ID: <4B3D00F9.7050808@gmail.com>
References: <4B3CFC73.3070204@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040401090002060406080602"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:49395 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbZLaTw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 14:52:29 -0500
Received: by ywh6 with SMTP id 6so13110653ywh.4
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2009 11:52:29 -0800 (PST)
In-Reply-To: <4B3CFC73.3070204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040401090002060406080602
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
   TCPCT part 2a: TCP header pointer functions

Signed-off-by: William.Allen.Simpson@gmail.com
---
  net/ipv4/tcp_input.c |   25 ++++++++++++++++++++++++-
  1 files changed, 24 insertions(+), 1 deletions(-)

--------------040401090002060406080602
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="522A6368";
 name="TCPCT+2c2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+2c2.patch"

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 28e0296..78604bd 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5415,6 +5415,12 @@ discard:
 	return 0;
 }
 
+/*
+ * Returns:
+ *	+1 on reset,
+ *	0 success and/or SYNACK data,
+ *	-1 on discard.
+ */
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 					 struct tcphdr *th, unsigned len)
 {
@@ -5423,6 +5429,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_cookie_values *cvp = tp->cookie_values;
 	int saved_clamp = tp->rx_opt.mss_clamp;
+	int queued = 0;
 
 	tcp_parse_options(skb, &tp->rx_opt, &hash_location, 0);
 
@@ -5544,6 +5551,19 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 				       hash_location, cookie_size);
 				cvp->cookie_pair_size = cookie_pair_size;
 			}
+
+			queued = skb->len - tcp_header_len_th(th);
+			if (queued > 0) {
+				/* Queue incoming transaction data. */
+				__skb_pull(skb, tcp_header_len_th(th));
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
@@ -5597,11 +5617,14 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
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

--------------040401090002060406080602--
