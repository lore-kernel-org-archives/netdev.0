From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v9 0/2] TCPCT part 1h: accept SYNACK data
Date: Thu, 03 Dec 2009 18:40:13 -0500
Message-ID: <4B184C5D.40707@gmail.com>
References: <4B184A20.4050005@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020403040705020006000408"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:40797 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755407AbZLCXkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 18:40:09 -0500
Received: by gxk26 with SMTP id 26so1730274gxk.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 15:40:16 -0800 (PST)
In-Reply-To: <4B184A20.4050005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020403040705020006000408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

When accompanied by cookie option, Initiator (client) queues incoming
SYNACK transaction data.

This is a straightforward re-implementation of an earlier (year-old)
patch that no longer applies cleanly, with permission of the original
author (Adam Langley).  The patch was previously reviewed:

    http://thread.gmane.org/gmane.linux.network/102586

Also, redefine two TCP header functions to accept TCP header pointer.
When subtracting, return signed int to allow error checking.

These functions will also be used in subsequent patches that implement
additional features.

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/linux/tcp.h  |   12 ++++++++++++
  net/ipv4/tcp_input.c |   25 ++++++++++++++++++++++++-
  2 files changed, 36 insertions(+), 1 deletions(-)

--------------020403040705020006000408
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1h9.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1h9.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7fee8a4..54ef984 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -223,6 +223,18 @@ static inline unsigned int tcp_optlen(const struct sk_buff *skb)
 	return (tcp_hdr(skb)->doff - 5) * 4;
 }
 
+/* Fixed portion plus standard options. */
+static inline unsigned int tcp_header_len_th(const struct tcphdr *th)
+{
+	return th->doff * 4;
+}
+
+/* Standard options only.  When doff is bad, this could be negative. */
+static inline int tcp_option_len_th(const struct tcphdr *th)
+{
+	return (int)(th->doff * 4) - sizeof(*th);
+}
+
 /* This defines a selective acknowledgement block. */
 struct tcp_sack_block_wire {
 	__be32	start_seq;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 57ae96a..8089424 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5393,6 +5393,12 @@ discard:
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
@@ -5402,6 +5408,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_cookie_values *cvp = tp->cookie_values;
 	int saved_clamp = tp->rx_opt.mss_clamp;
+	int queued = 0;
 
 	tcp_parse_options(skb, &tp->rx_opt, &hash_location, 0, dst);
 
@@ -5523,6 +5530,19 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
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
@@ -5576,11 +5596,14 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
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


--------------020403040705020006000408--
