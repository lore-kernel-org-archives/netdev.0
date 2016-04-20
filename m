From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 2/2] tcp: Merge tx_flags and tskey in tcp_shifted_skb
Date: Tue, 19 Apr 2016 22:39:29 -0700
Message-ID: <1461130769-1442865-3-git-send-email-kafai@fb.com>
References: <1461130769-1442865-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56428 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750807AbcDTFjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 01:39:55 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3K5aU2q017674
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 22:39:54 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22e2gs0axg-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 22:39:54 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 4df2394c06ba11e695ad0002c991e86a-b27e8c50 for <netdev@vger.kernel.org>;	Tue,
 19 Apr 2016 22:39:52 -0700
In-Reply-To: <1461130769-1442865-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After receiving sacks, tcp_shifted_skb() will collapse
skbs if possible.  tx_flags and tskey also have to be
merged.

This patch reuses the tcp_skb_collapse_tstamp() to handle
them.

BPF Output Before:
~~~~~
<no-output-due-to-missing-tstamp-event>

BPF Output After:
~~~~~
<...>-2024  [007] d.s.    88.644374: : ee_data:14599

Packetdrill Script:
~~~~~
+0 `sysctl -q -w net.ipv4.tcp_min_tso_segs=10`
+0 `sysctl -q -w net.ipv4.tcp_no_metrics_save=1`
+0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0 bind(3, ..., ...) = 0
+0 listen(3, 1) = 0

0.100 < S 0:0(0) win 32792 <mss 1460,sackOK,nop,nop,nop,wscale 7>
0.100 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 7>
0.200 < . 1:1(0) ack 1 win 257
0.200 accept(3, ..., ...) = 4
+0 setsockopt(4, SOL_TCP, TCP_NODELAY, [1], 4) = 0

0.200 write(4, ..., 1460) = 1460
+0 setsockopt(4, SOL_SOCKET, 37, [2688], 4) = 0
0.200 write(4, ..., 13140) = 13140

0.200 > P. 1:1461(1460) ack 1
0.200 > . 1461:8761(7300) ack 1
0.200 > P. 8761:14601(5840) ack 1

0.300 < . 1:1(0) ack 1 win 257 <sack 1461:14601,nop,nop>
0.300 > P. 1:1461(1460) ack 1
0.400 < . 1:1(0) ack 14601 win 257

0.400 close(4) = 0
0.400 > F. 14601:14601(0) ack 1
0.500 < F. 1:1(0) ack 14602 win 257
0.500 > . 14602:14602(0) ack 2

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h     | 2 ++
 net/ipv4/tcp_input.c  | 1 +
 net/ipv4/tcp_output.c | 4 ++--
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b91370f..6db1022 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -552,6 +552,8 @@ void tcp_send_ack(struct sock *sk);
 void tcp_send_delayed_ack(struct sock *sk);
 void tcp_send_loss_probe(struct sock *sk);
 bool tcp_schedule_loss_probe(struct sock *sk);
+void tcp_skb_collapse_tstamp(struct sk_buff *skb,
+			     const struct sk_buff *next_skb);
 
 /* tcp_input.c */
 void tcp_resume_early_retransmit(struct sock *sk);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0edb071..c124c3c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1309,6 +1309,7 @@ static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 	if (skb == tcp_highest_sack(sk))
 		tcp_advance_highest_sack(sk, skb);
 
+	tcp_skb_collapse_tstamp(prev, skb);
 	tcp_unlink_write_queue(skb, sk);
 	sk_wmem_free_skb(sk, skb);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5bc3c30..441ae9d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2441,8 +2441,8 @@ u32 __tcp_select_window(struct sock *sk)
 	return window;
 }
 
-static void tcp_skb_collapse_tstamp(struct sk_buff *skb,
-				    const struct sk_buff *next_skb)
+void tcp_skb_collapse_tstamp(struct sk_buff *skb,
+			     const struct sk_buff *next_skb)
 {
 	const struct skb_shared_info *next_shinfo = skb_shinfo(next_skb);
 	u8 tsflags = next_shinfo->tx_flags & SKBTX_ANY_TSTAMP;
-- 
2.5.1
