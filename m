From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 1/2] tcp: Merge tx_flags and tskey in tcp_collapse_retrans
Date: Tue, 19 Apr 2016 22:39:28 -0700
Message-ID: <1461130769-1442865-2-git-send-email-kafai@fb.com>
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
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56431 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751881AbcDTFj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 01:39:56 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3K5acXb017693
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 22:39:55 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22e2gs0axc-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 22:39:55 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 4df3791006ba11e688910002c9521c9e-a85cdc50 for <netdev@vger.kernel.org>;	Tue,
 19 Apr 2016 22:39:52 -0700
In-Reply-To: <1461130769-1442865-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If two skbs are merged/collapsed during retransmission, the current
logic does not merge the tx_flags and tskey.  The end result is
the SCM_TSTAMP_ACK timestamp could be missing for a packet.

The patch:
1. Merge the tx_flags
2. Overwrite the prev_skb's tskey with the next_skb's tskey

BPF Output Before:
~~~~~~
<no-output-due-to-missing-tstamp-event>

BPF Output After:
~~~~~~
packetdrill-2092  [001] d.s.   453.998486: : ee_data:1459

Packetdrill Script:
~~~~~~
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

0.200 write(4, ..., 730) = 730
+0 setsockopt(4, SOL_SOCKET, 37, [2688], 4) = 0
0.200 write(4, ..., 730) = 730
+0 setsockopt(4, SOL_SOCKET, 37, [2176], 4) = 0
0.200 write(4, ..., 11680) = 11680
+0 setsockopt(4, SOL_SOCKET, 37, [2688], 4) = 0

0.200 > P. 1:731(730) ack 1
0.200 > P. 731:1461(730) ack 1
0.200 > . 1461:8761(7300) ack 1
0.200 > P. 8761:13141(4380) ack 1

0.300 < . 1:1(0) ack 1 win 257 <sack 1461:2921,nop,nop>
0.300 < . 1:1(0) ack 1 win 257 <sack 1461:4381,nop,nop>
0.300 < . 1:1(0) ack 1 win 257 <sack 1461:5841,nop,nop>
0.300 > P. 1:1461(1460) ack 1
0.400 < . 1:1(0) ack 13141 win 257

0.400 close(4) = 0
0.400 > F. 13141:13141(0) ack 1
0.500 < F. 1:1(0) ack 13142 win 257
0.500 > . 13142:13142(0) ack 2

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7d2dc01..5bc3c30 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2441,6 +2441,20 @@ u32 __tcp_select_window(struct sock *sk)
 	return window;
 }
 
+static void tcp_skb_collapse_tstamp(struct sk_buff *skb,
+				    const struct sk_buff *next_skb)
+{
+	const struct skb_shared_info *next_shinfo = skb_shinfo(next_skb);
+	u8 tsflags = next_shinfo->tx_flags & SKBTX_ANY_TSTAMP;
+
+	if (unlikely(tsflags)) {
+		struct skb_shared_info *shinfo = skb_shinfo(skb);
+
+		shinfo->tx_flags |= tsflags;
+		shinfo->tskey = next_shinfo->tskey;
+	}
+}
+
 /* Collapses two adjacent SKB's during retransmission. */
 static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 {
@@ -2484,6 +2498,8 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 
 	tcp_adjust_pcount(sk, next_skb, tcp_skb_pcount(next_skb));
 
+	tcp_skb_collapse_tstamp(skb, next_skb);
+
 	sk_wmem_free_skb(sk, next_skb);
 }
 
-- 
2.5.1
