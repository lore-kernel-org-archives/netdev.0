From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 1/2] tcp: Carry txstamp_ack in tcp_fragment_tstamp
Date: Tue, 19 Apr 2016 22:50:47 -0700
Message-ID: <1461131448-1460418-2-git-send-email-kafai@fb.com>
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:61591 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751826AbcDTFv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 01:51:28 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3K5oMpX021251
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 22:51:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 22e1qurjbq-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 22:51:28 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 eaf9117406bb11e69ffa24be0593f280-d2fcfc50 for <netdev@vger.kernel.org>;	Tue,
 19 Apr 2016 22:51:25 -0700
In-Reply-To: <1461131448-1460418-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a tcp skb is sliced into two smaller skbs (e.g. in
tcp_fragment() and tso_fragment()),  it does not carry
the txstamp_ack bit to the newly created skb if it is needed.
The end result is a timestamping event (SCM_TSTAMP_ACK) will
be missing from the sk->sk_error_queue.

This patch carries this bit to the new skb2
in tcp_fragment_tstamp().

BPF Output Before:
~~~~~~
<No output due to missing SCM_TSTAMP_ACK timestamp>

BPF Output After:
~~~~~~
<...>-2050  [000] d.s.   100.928763: : ee_data:14599

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

+0 setsockopt(4, SOL_SOCKET, 37, [2688], 4) = 0
0.200 write(4, ..., 14600) = 14600
+0 setsockopt(4, SOL_SOCKET, 37, [2176], 4) = 0

0.200 > . 1:7301(7300) ack 1
0.200 > P. 7301:14601(7300) ack 1

0.300 < . 1:1(0) ack 14601 win 257

0.300 close(4) = 0
0.300 > F. 14601:14601(0) ack 1
0.400 < F. 1:1(0) ack 16062 win 257
0.400 > . 14602:14602(0) ack 2

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_output.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 96182a2..f7c3bc0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1123,6 +1123,8 @@ static void tcp_fragment_tstamp(struct sk_buff *skb, struct sk_buff *skb2)
 		shinfo->tx_flags &= ~tsflags;
 		shinfo2->tx_flags |= tsflags;
 		swap(shinfo->tskey, shinfo2->tskey);
+		TCP_SKB_CB(skb2)->txstamp_ack = TCP_SKB_CB(skb)->txstamp_ack;
+		TCP_SKB_CB(skb)->txstamp_ack = 0;
 	}
 }
 
-- 
2.5.1
