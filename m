From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH v2 net-next 7/7] tcp: Avoid losing eor_info when collapsing skbs
Date: Mon, 18 Apr 2016 15:46:09 -0700
Message-ID: <1461019569-3037369-8-git-send-email-kafai@fb.com>
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41627 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752041AbcDRWqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 18:46:35 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3IMhxVR018838
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:34 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 22bh72rb8y-3
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:34 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 6376b40e05b711e697a20002c9521c9e-aa5d8c50 for <netdev@vger.kernel.org>;	Mon,
 18 Apr 2016 15:46:28 -0700
In-Reply-To: <1461019569-3037369-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When collapsing skbs during tcp_collapse_retrans and tcp_shift_skb_data,
this patch is to avoid collapsing to a prev skb that has eor_info mark
and the next_skb also has the tskey set (i.e. the prev skb will lose
a eor marked tskey info).

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h     | 6 ++++++
 net/ipv4/tcp_input.c  | 3 +++
 net/ipv4/tcp_output.c | 7 +++++--
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f3c5dcb..56a287a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -812,6 +812,12 @@ static inline int tcp_skb_mss(const struct sk_buff *skb)
 	return TCP_SKB_CB(skb)->tcp_gso_size;
 }
 
+static inline bool  tcp_skb_can_collapse_eor(const struct sk_buff *skb,
+					     const struct sk_buff *next_skb)
+{
+	return !(TCP_SKB_CB(skb)->eor_info && skb_shinfo(next_skb)->tskey);
+}
+
 /* Events passed to congestion control interface */
 enum tcp_ca_event {
 	CA_EVENT_TX_START,	/* first transmit when no packets in flight */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 75e8336..e60922d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1368,6 +1368,9 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 	if ((TCP_SKB_CB(prev)->sacked & TCPCB_TAGBITS) != TCPCB_SACKED_ACKED)
 		goto fallback;
 
+	if (!tcp_skb_can_collapse_eor(prev, skb))
+		goto fallback;
+
 	in_sack = !after(start_seq, TCP_SKB_CB(skb)->seq) &&
 		  !before(end_seq, TCP_SKB_CB(skb)->end_seq);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e71336c..1ae21f1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2512,7 +2512,8 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 }
 
 /* Check if coalescing SKBs is legal. */
-static bool tcp_can_collapse(const struct sock *sk, const struct sk_buff *skb)
+static bool tcp_can_collapse(const struct sock *sk, const struct sk_buff *to,
+			     const struct sk_buff *skb)
 {
 	if (tcp_skb_pcount(skb) > 1)
 		return false;
@@ -2526,6 +2527,8 @@ static bool tcp_can_collapse(const struct sock *sk, const struct sk_buff *skb)
 	/* Some heurestics for collapsing over SACK'd could be invented */
 	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
 		return false;
+	if (!tcp_skb_can_collapse_eor(to, skb))
+		return false;
 
 	return true;
 }
@@ -2546,7 +2549,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 		return;
 
 	tcp_for_write_queue_from_safe(skb, tmp, sk) {
-		if (!tcp_can_collapse(sk, skb))
+		if (!tcp_can_collapse(sk, to, skb))
 			break;
 
 		space -= skb->len;
-- 
2.5.1
