From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v4 net-next 1/3] tcp: Make use of MSG_EOR in tcp_sendmsg
Date: Mon, 25 Apr 2016 14:44:48 -0700
Message-ID: <1461620690-1081063-2-git-send-email-kafai@fb.com>
References: <1461620690-1081063-1-git-send-email-kafai@fb.com>
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:29345 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965002AbcDYVpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 17:45:14 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3PLiW59015174
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 14:45:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 22gukm8u49-6
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 14:45:13 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 f80aa70c0b2e11e6bdce24be05956610-cfad86d0 for <netdev@vger.kernel.org>;	Mon,
 25 Apr 2016 14:45:04 -0700
In-Reply-To: <1461620690-1081063-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an eor bit to the TCP_SKB_CB.  When MSG_EOR
is passed to tcp_sendmsg, the eor bit will be set at the skb
containing the last byte of the userland's msg.  The eor bit
will prevent data from appending to that skb in the future.

The change in do_tcp_sendpages is to honor the eor set
during the previous tcp_sendmsg(MSG_EOR) call.

This patch handles the tcp_sendmsg case.  The followup patches
will handle other skb coalescing and fragment cases.

One potential use case is to use MSG_EOR with
SOF_TIMESTAMPING_TX_ACK to get a more accurate
TCP ack timestamping on application protocol with
multiple outgoing response messages (e.g. HTTP2).

Packetdrill script for testing:
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

0.200 write(4, ..., 14600) = 14600
0.200 sendto(4, ..., 730, MSG_EOR, ..., ...) = 730
0.200 sendto(4, ..., 730, MSG_EOR, ..., ...) = 730

0.200 > .  1:7301(7300) ack 1
0.200 > P. 7301:14601(7300) ack 1

0.300 < . 1:1(0) ack 14601 win 257
0.300 > P. 14601:15331(730) ack 1
0.300 > P. 15331:16061(730) ack 1

0.400 < . 1:1(0) ack 16061 win 257
0.400 close(4) = 0
0.400 > F. 16061:16061(0) ack 1
0.400 < F. 1:1(0) ack 16062 win 257
0.400 > . 16062:16062(0) ack 2

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Suggested-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h | 8 +++++++-
 net/ipv4/tcp.c    | 7 +++++--
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7f2553d..ce08038 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -762,7 +762,8 @@ struct tcp_skb_cb {
 
 	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
 	__u8		txstamp_ack:1,	/* Record TX timestamp for ack? */
-			unused:7;
+			eor:1,		/* Is skb MSG_EOR marked? */
+			unused:6;
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 	union {
 		struct inet_skb_parm	h4;
@@ -809,6 +810,11 @@ static inline int tcp_skb_mss(const struct sk_buff *skb)
 	return TCP_SKB_CB(skb)->tcp_gso_size;
 }
 
+static inline bool tcp_skb_can_collapse_to(const struct sk_buff *skb)
+{
+	return likely(!TCP_SKB_CB(skb)->eor);
+}
+
 /* Events passed to congestion control interface */
 enum tcp_ca_event {
 	CA_EVENT_TX_START,	/* first transmit when no packets in flight */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4d73858..ea5364b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -908,7 +908,8 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 		int copy, i;
 		bool can_coalesce;
 
-		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0) {
+		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0 ||
+		    !tcp_skb_can_collapse_to(skb)) {
 new_segment:
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
@@ -1156,7 +1157,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 			copy = max - skb->len;
 		}
 
-		if (copy <= 0) {
+		if (copy <= 0 || !tcp_skb_can_collapse_to(skb)) {
 new_segment:
 			/* Allocate new segment. If the interface is SG,
 			 * allocate skb fitting to single page.
@@ -1250,6 +1251,8 @@ new_segment:
 		copied += copy;
 		if (!msg_data_left(msg)) {
 			tcp_tx_timestamp(sk, sockc.tsflags, skb);
+			if (unlikely(flags & MSG_EOR))
+				TCP_SKB_CB(skb)->eor = 1;
 			goto out;
 		}
 
-- 
2.5.1
