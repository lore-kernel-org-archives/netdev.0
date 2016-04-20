From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 2/2] tcp: Merge txstamp_ack in tcp_skb_collapse_tstamp
Date: Tue, 19 Apr 2016 22:50:48 -0700
Message-ID: <1461131448-1460418-3-git-send-email-kafai@fb.com>
References: <1461131448-1460418-1-git-send-email-kafai@fb.com>
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
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57181 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751279AbcDTFv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 01:51:28 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3K5pNpI027777
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 22:51:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22e2gs0bv6-6
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 22:51:27 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 eaeba2a006bb11e6961324be0593f280-d0bc0c50 for <netdev@vger.kernel.org>;	Tue,
 19 Apr 2016 22:51:25 -0700
In-Reply-To: <1461131448-1460418-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When collapsing skbs, txstamp_ack also needs to be merged.

Retrans Collapse Test:
~~~~~~
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

BPF Output Before:
~~~~~
<No output due to missing SCM_TSTAMP_ACK timestamp>

BPF Output After:
~~~~~
<...>-2027  [007] d.s.    79.765921: : ee_data:1459

Sacks Collapse Test:
~~~~~
0.200 accept(3, ..., ...) = 4
+0 setsockopt(4, SOL_TCP, TCP_NODELAY, [1], 4) = 0

0.200 write(4, ..., 1460) = 1460
+0 setsockopt(4, SOL_SOCKET, 37, [2688], 4) = 0
0.200 write(4, ..., 13140) = 13140
+0 setsockopt(4, SOL_SOCKET, 37, [2176], 4) = 0

0.200 > P. 1:1461(1460) ack 1
0.200 > . 1461:8761(7300) ack 1
0.200 > P. 8761:14601(5840) ack 1

0.300 < . 1:1(0) ack 1 win 257 <sack 1461:14601,nop,nop>
0.300 > P. 1:1461(1460) ack 1
0.400 < . 1:1(0) ack 14601 win 257

BPF Output Before:
~~~~~
<No output due to missing SCM_TSTAMP_ACK timestamp>

BPF Output After:
~~~~~
<...>-2049  [007] d.s.    89.185538: : ee_data:14599

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f7c3bc0..a6e4a83 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2454,6 +2454,8 @@ void tcp_skb_collapse_tstamp(struct sk_buff *skb,
 
 		shinfo->tx_flags |= tsflags;
 		shinfo->tskey = next_shinfo->tskey;
+		TCP_SKB_CB(skb)->txstamp_ack |=
+			TCP_SKB_CB(next_skb)->txstamp_ack;
 	}
 }
 
-- 
2.5.1
