From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH v2 net-next 2/7] tcp: Merge tx_flags/tskey/txstamp_ack in tcp_collapse_retrans
Date: Mon, 18 Apr 2016 15:46:04 -0700
Message-ID: <1461019569-3037369-3-git-send-email-kafai@fb.com>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:53986 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751497AbcDRWqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 18:46:31 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3IMgNuV025148
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:30 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22d1mut8we-3
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:30 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 62bbdf6c05b711e694e024be0595f910-3cbf5c50 for <netdev@vger.kernel.org>;	Mon,
 18 Apr 2016 15:46:28 -0700
In-Reply-To: <1461019569-3037369-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If two skbs are merged/collapsed during retransmission, the current
logic does not merge the tx_flags, tskey and txstamp_ack.  The end
result is the SCM_TSTAMP_ACK timestamp could be missing for a
packet that the end-user has specifically turned on
SOF_TIMESTAMPING_TX_ACK (e.g. by cmsg).

The patch:
1. Merge the tx_flags and txstamp_ack
2. Overwrite the tskey with the later skb (next_skb)

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
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0527ce9..889ed96 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2443,6 +2443,22 @@ u32 __tcp_select_window(struct sock *sk)
 	return window;
 }
 
+static void tcp_skb_collapse_tstamp(struct sk_buff *skb,
+				    const struct sk_buff *next_skb)
+{
+	const struct skb_shared_info *next_shinfo = skb_shinfo(next_skb);
+
+	if (unlikely(next_shinfo->tx_flags & SKBTX_ANY_TSTAMP)) {
+		struct skb_shared_info *shinfo = skb_shinfo(skb);
+		u8 tsflags = next_shinfo->tx_flags & SKBTX_ANY_TSTAMP;
+
+		shinfo->tx_flags |= tsflags;
+		shinfo->tskey = next_shinfo->tskey;
+		TCP_SKB_CB(skb)->txstamp_ack =
+			!!(shinfo->tx_flags & SKBTX_ACK_TSTAMP);
+	}
+}
+
 /* Collapses two adjacent SKB's during retransmission. */
 static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 {
@@ -2486,6 +2502,8 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 
 	tcp_adjust_pcount(sk, next_skb, tcp_skb_pcount(next_skb));
 
+	tcp_skb_collapse_tstamp(skb, next_skb);
+
 	sk_wmem_free_skb(sk, next_skb);
 }
 
-- 
2.5.1
