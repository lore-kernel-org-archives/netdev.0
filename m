From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH v3 net-next 1/3] tcp: Make use of MSG_EOR in tcp_sendmsg and tcp_sendpage
Date: Tue, 19 Apr 2016 23:24:55 -0700
Message-ID: <1461133497-1515104-2-git-send-email-kafai@fb.com>
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:54838 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752940AbcDTGZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 02:25:08 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3K6Kw3k009132
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 23:25:07 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 22e1qurnek-3
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 23:25:07 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 9ecdedd806c011e689ec0002c95209d8-83dfc50 for <netdev@vger.kernel.org>;	Tue,
 19 Apr 2016 23:25:05 -0700
In-Reply-To: <1461133497-1515104-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an eor bit to the TCP_SKB_CB.  When MSG_EOR
is passed to tcp_sendmsg/tcp_sendpage, the eor bit will
be set at the skb containing the last byte of the userland's
msg.  The eor bit will prevent data from appending to that
skb in the future.

This patch handles the tcp_sendmsg and tcp_sendpage cases.

The followup patches will handle other skb coalescing
and fragment cases.

One potential use case is to use MSG_EOR with
SOF_TIMESTAMPING_TX_ACK to get a more accurate
TCP ack timestamping on application protocol with
multiple outgoing response messages (e.g. HTTP2).

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Suggested-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h | 3 ++-
 net/ipv4/tcp.c    | 7 +++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index c0ef054..ac31798 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -762,7 +762,8 @@ struct tcp_skb_cb {
 
 	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
 	__u8		txstamp_ack:1,	/* Record TX timestamp for ack? */
-			unused:7;
+			eor:1,		/* Is skb MSG_EOR marked */
+			unused:6;
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 	union {
 		struct inet_skb_parm	h4;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4d73858..7df0c1a88 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -908,7 +908,8 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 		int copy, i;
 		bool can_coalesce;
 
-		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0) {
+		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0 ||
+		    TCP_SKB_CB(skb)->eor) {
 new_segment:
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
@@ -960,6 +961,7 @@ new_segment:
 		size -= copy;
 		if (!size) {
 			tcp_tx_timestamp(sk, sk->sk_tsflags, skb);
+			TCP_SKB_CB(skb)->eor = !!(flags & MSG_EOR);
 			goto out;
 		}
 
@@ -1156,7 +1158,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 			copy = max - skb->len;
 		}
 
-		if (copy <= 0) {
+		if (copy <= 0 || TCP_SKB_CB(skb)->eor) {
 new_segment:
 			/* Allocate new segment. If the interface is SG,
 			 * allocate skb fitting to single page.
@@ -1250,6 +1252,7 @@ new_segment:
 		copied += copy;
 		if (!msg_data_left(msg)) {
 			tcp_tx_timestamp(sk, sockc.tsflags, skb);
+			TCP_SKB_CB(skb)->eor = !!(flags & MSG_EOR);
 			goto out;
 		}
 
-- 
2.5.1
