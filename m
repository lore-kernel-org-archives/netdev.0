From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH v3 net-next 3/3] tcp: Handle eor bit when fragmenting a skb
Date: Tue, 19 Apr 2016 23:24:57 -0700
Message-ID: <1461133497-1515104-4-git-send-email-kafai@fb.com>
References: <1461133497-1515104-1-git-send-email-kafai@fb.com>
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
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:13127 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752904AbcDTGZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 02:25:07 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3K6MBtZ008470
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 23:25:06 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22dt90b396-3
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 23:25:06 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 9ed1eb9006c011e68ea70002c9521c9e-a72c8c50 for <netdev@vger.kernel.org>;	Tue,
 19 Apr 2016 23:25:05 -0700
In-Reply-To: <1461133497-1515104-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When fragmenting a skb, the next_skb should carry
the eor from prev_skb.  The eor of prev_skb should
also be reset.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 96bdf98..95f419b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1128,6 +1128,12 @@ static void tcp_fragment_tstamp(struct sk_buff *skb, struct sk_buff *skb2)
 	}
 }
 
+static void tcp_skb_fragment_eor(struct sk_buff *skb, struct sk_buff *skb2)
+{
+	TCP_SKB_CB(skb2)->eor = TCP_SKB_CB(skb)->eor;
+	TCP_SKB_CB(skb)->eor = 0;
+}
+
 /* Function to create two new TCP segments.  Shrinks the given segment
  * to the specified size and appends a new segment with the rest of the
  * packet to the list.  This won't be called frequently, I hope.
@@ -1173,6 +1179,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 	TCP_SKB_CB(skb)->tcp_flags = flags & ~(TCPHDR_FIN | TCPHDR_PSH);
 	TCP_SKB_CB(buff)->tcp_flags = flags;
 	TCP_SKB_CB(buff)->sacked = TCP_SKB_CB(skb)->sacked;
+	tcp_skb_fragment_eor(skb, buff);
 
 	if (!skb_shinfo(skb)->nr_frags && skb->ip_summed != CHECKSUM_PARTIAL) {
 		/* Copy and checksum data tail into the new buffer. */
@@ -1733,6 +1740,8 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 	/* This packet was never sent out yet, so no SACK bits. */
 	TCP_SKB_CB(buff)->sacked = 0;
 
+	tcp_skb_fragment_eor(skb, buff);
+
 	buff->ip_summed = skb->ip_summed = CHECKSUM_PARTIAL;
 	skb_split(skb, buff, len);
 	tcp_fragment_tstamp(skb, buff);
-- 
2.5.1
