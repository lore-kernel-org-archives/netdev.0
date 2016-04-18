From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH v2 net-next 1/7] tcp: Carry txstamp_ack in tcp_fragment_tstamp
Date: Mon, 18 Apr 2016 15:46:03 -0700
Message-ID: <1461019569-3037369-2-git-send-email-kafai@fb.com>
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:54016 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751473AbcDRWqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 18:46:33 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3IMhxVN018838
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:32 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 22bh72rb8y-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:32 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 62d1fd7405b711e695410002c9521c9e-f93a16d0 for <netdev@vger.kernel.org>;	Mon,
 18 Apr 2016 15:46:27 -0700
In-Reply-To: <1461019569-3037369-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a tcp skb is sliced into two smaller skbs (e.g. in
tcp_fragment() and tso_fragment()),  it does not carry
the txstamp_ack bit to the newly created skb if it is needed.
The end result is a timestamping event (SCM_TSTAMP_ACK) will
be missing from the sk->sk_error_queue.

This patch carries this bit to the new skb2 (if needed)
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
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6451b83..0527ce9 100644
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
