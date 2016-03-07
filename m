From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 11/13] kcm: Add memory limit for receive message construction
Date: Mon, 7 Mar 2016 14:11:10 -0800
Message-ID: <1457388672-2600559-12-git-send-email-tom@herbertland.com>
References: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:32271 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753776AbcCGWMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 17:12:17 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u27MACOr003272
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2016 14:12:17 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21hgcygj9r-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 14:12:17 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 a646faaee4b111e599860002c9521c9e-b91d7420 for <netdev@vger.kernel.org>;	Mon,
 07 Mar 2016 14:12:15 -0800
In-Reply-To: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Message assembly is performed on the TCP socket. This is logically
equivalent of an application that performs a peek on the socket to find
out how much memory is needed for a receive buffer. The receive socket
buffer also provides the maximum message size which is checked.

The receive algorithm is something like:

   1) Receive the first skbuf for a message (or skbufs if multiple are
      needed to determine message length).
   2) Check the message length against the number of bytes in the TCP
      receive queue (tcp_inq()).
	- If all the bytes of the message are in the queue (incluing the
	  skbuf received), then proceed with message assembly (it should
	  complete with the tcp_read_sock)
        - Else, mark the psock with the number of bytes needed to
	  complete the message.
   3) In TCP data ready function, if the psock indicates that we are
      waiting for the rest of the bytes of a messages, check the number
      of queued bytes against that.
        - If there are still not enough bytes for the message, just
	  return
        - Else, clear the waiting bytes and proceed to receive the
	  skbufs.  The message should now be received in one
	  tcp_read_sock

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/kcm.h |  4 ++++
 net/kcm/kcmproc.c |  6 ++++--
 net/kcm/kcmsock.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/include/net/kcm.h b/include/net/kcm.h
index 39c7abe..d892956 100644
--- a/include/net/kcm.h
+++ b/include/net/kcm.h
@@ -28,6 +28,7 @@ struct kcm_psock_stats {
 	unsigned int rx_aborts;
 	unsigned int rx_mem_fail;
 	unsigned int rx_need_more_hdr;
+	unsigned int rx_msg_too_big;
 	unsigned int rx_bad_hdr_len;
 	unsigned long long reserved;
 	unsigned long long unreserved;
@@ -66,6 +67,7 @@ struct kcm_rx_msg {
 	int full_len;
 	int accum_len;
 	int offset;
+	int early_eaten;
 };
 
 /* Socket structure for KCM client sockets */
@@ -128,6 +130,7 @@ struct kcm_psock {
 	struct kcm_sock *rx_kcm;
 	unsigned long long saved_rx_bytes;
 	unsigned long long saved_rx_msgs;
+	unsigned int rx_need_bytes;
 
 	/* Transmit */
 	struct kcm_sock *tx_kcm;
@@ -190,6 +193,7 @@ static inline void aggregate_psock_stats(struct kcm_psock_stats *stats,
 	SAVE_PSOCK_STATS(rx_aborts);
 	SAVE_PSOCK_STATS(rx_mem_fail);
 	SAVE_PSOCK_STATS(rx_need_more_hdr);
+	SAVE_PSOCK_STATS(rx_msg_too_big);
 	SAVE_PSOCK_STATS(rx_bad_hdr_len);
 	SAVE_PSOCK_STATS(tx_msgs);
 	SAVE_PSOCK_STATS(tx_bytes);
diff --git a/net/kcm/kcmproc.c b/net/kcm/kcmproc.c
index 5eb9809..7638b35 100644
--- a/net/kcm/kcmproc.c
+++ b/net/kcm/kcmproc.c
@@ -331,7 +331,7 @@ static int kcm_stats_seq_show(struct seq_file *seq, void *v)
 		   mux_stats.rx_ready_drops);
 
 	seq_printf(seq,
-		   "%-8s %-10s %-16s %-10s %-16s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n",
+		   "%-8s %-10s %-16s %-10s %-16s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n",
 		   "Psock",
 		   "RX-Msgs",
 		   "RX-Bytes",
@@ -343,10 +343,11 @@ static int kcm_stats_seq_show(struct seq_file *seq, void *v)
 		   "RX-MemFail",
 		   "RX-NeedMor",
 		   "RX-BadLen",
+		   "RX-TooBig",
 		   "TX-Aborts");
 
 	seq_printf(seq,
-		   "%-8s %-10llu %-16llu %-10llu %-16llu %-10llu %-10llu %-10u %-10u %-10u %-10u %-10u\n",
+		   "%-8s %-10llu %-16llu %-10llu %-16llu %-10llu %-10llu %-10u %-10u %-10u %-10u %-10u %-10u\n",
 		   "",
 		   psock_stats.rx_msgs,
 		   psock_stats.rx_bytes,
@@ -358,6 +359,7 @@ static int kcm_stats_seq_show(struct seq_file *seq, void *v)
 		   psock_stats.rx_mem_fail,
 		   psock_stats.rx_need_more_hdr,
 		   psock_stats.rx_bad_hdr_len,
+		   psock_stats.rx_msg_too_big,
 		   psock_stats.tx_aborts);
 
 	return 0;
diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index 9ac2499..8bc38d3 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -375,6 +375,19 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 	if (head) {
 		/* Message already in progress */
 
+		rxm = kcm_rx_msg(head);
+		if (unlikely(rxm->early_eaten)) {
+			/* Already some number of bytes on the receive sock
+			 * data saved in rx_skb_head, just indicate they
+			 * are consumed.
+			 */
+			eaten = orig_len <= rxm->early_eaten ?
+				orig_len : rxm->early_eaten;
+			rxm->early_eaten -= eaten;
+
+			return eaten;
+		}
+
 		if (unlikely(orig_offset)) {
 			/* Getting data with a non-zero offset when a message is
 			 * in progress is not expected. If it does happen, we
@@ -492,6 +505,13 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 				KCM_STATS_INCR(psock->stats.rx_need_more_hdr);
 				WARN_ON(eaten != orig_len);
 				break;
+			} else if (len > psock->sk->sk_rcvbuf) {
+				/* Message length exceeds maximum allowed */
+				KCM_STATS_INCR(psock->stats.rx_msg_too_big);
+				desc->error = -EMSGSIZE;
+				psock->rx_skb_head = NULL;
+				kcm_abort_rx_psock(psock, EMSGSIZE, head);
+				break;
 			} else if (len <= (ssize_t)head->len -
 					  skb->len - rxm->offset) {
 				/* Length must be into new skb (and also
@@ -511,6 +531,23 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 
 		if (extra < 0) {
 			/* Message not complete yet. */
+			if (rxm->full_len - rxm->accum_len >
+			    tcp_inq(psock->sk)) {
+				/* Don't have the whole messages in the socket
+				 * buffer. Set psock->rx_need_bytes to wait for
+				 * the rest of the message. Also, set "early
+				 * eaten" since we've already buffered the skb
+				 * but don't consume yet per tcp_read_sock.
+				 */
+
+				psock->rx_need_bytes = rxm->full_len -
+						       rxm->accum_len;
+				rxm->accum_len += cand_len;
+				rxm->early_eaten = cand_len;
+				KCM_STATS_ADD(psock->stats.rx_bytes, cand_len);
+				desc->count = 0; /* Stop reading socket */
+				break;
+			}
 			rxm->accum_len += cand_len;
 			eaten += cand_len;
 			WARN_ON(eaten != orig_len);
@@ -582,6 +619,13 @@ static void psock_tcp_data_ready(struct sock *sk)
 	if (psock->ready_rx_msg)
 		goto out;
 
+	if (psock->rx_need_bytes) {
+		if (tcp_inq(sk) >= psock->rx_need_bytes)
+			psock->rx_need_bytes = 0;
+		else
+			goto out;
+	}
+
 	if (psock_tcp_read_sock(psock) == -ENOMEM)
 		queue_delayed_work(kcm_wq, &psock->rx_delayed_work, 0);
 
-- 
2.6.5
