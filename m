From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH v2 net-next 6/7] tcp: Carry eor_info in tcp_fragment_tstamp() and tcp_skb_collapse_tstamp()
Date: Mon, 18 Apr 2016 15:46:08 -0700
Message-ID: <1461019569-3037369-7-git-send-email-kafai@fb.com>
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
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46326 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751464AbcDRWqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 18:46:30 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3IMjSRE025861
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:29 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22d7r6r96r-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:29 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 63608a1205b711e683180002c95209d8-bef0c50 for <netdev@vger.kernel.org>;	Mon,
 18 Apr 2016 15:46:28 -0700
In-Reply-To: <1461019569-3037369-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like txstamp_ack bit, if needed, the eor_info bit should also be carried
to the new skb2 when splitting a skb
or
to the prev skb from the next_skb when collapsing skbs.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d21a78f..e71336c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1125,6 +1125,8 @@ static void tcp_fragment_tstamp(struct sk_buff *skb, struct sk_buff *skb2)
 		swap(shinfo->tskey, shinfo2->tskey);
 		TCP_SKB_CB(skb2)->txstamp_ack = TCP_SKB_CB(skb)->txstamp_ack;
 		TCP_SKB_CB(skb)->txstamp_ack = 0;
+		TCP_SKB_CB(skb2)->eor_info = TCP_SKB_CB(skb)->eor_info;
+		TCP_SKB_CB(skb)->eor_info = 0;
 	}
 }
 
@@ -2456,6 +2458,8 @@ void tcp_skb_collapse_tstamp(struct sk_buff *skb,
 		shinfo->tskey = next_shinfo->tskey;
 		TCP_SKB_CB(skb)->txstamp_ack =
 			!!(shinfo->tx_flags & SKBTX_ACK_TSTAMP);
+		if (TCP_SKB_CB(next_skb)->eor_info)
+			TCP_SKB_CB(skb)->eor_info = 1;
 	}
 }
 
-- 
2.5.1
