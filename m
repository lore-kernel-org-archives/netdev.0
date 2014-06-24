From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 5/7] net-timestamp: ACK timestamp for bytestreams
Date: Tue, 24 Jun 2014 11:43:50 -0400
Message-ID: <1403624632-17327-6-git-send-email-willemb@google.com>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
Cc: eric.dumazet@gmail.com, richardcochran@gmail.com,
	davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f73.google.com ([209.85.160.73]:45943 "EHLO
	mail-pb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754371AbaFXPoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 11:44:00 -0400
Received: by mail-pb0-f73.google.com with SMTP id ma3so62513pbc.2
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 08:44:00 -0700 (PDT)
In-Reply-To: <1403624632-17327-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds send() flag MSG_TSTAMP_ACK, a request for a timestamp
when the last byte in the send buffer is acknowledged. It implements
the feature for TCP.

The timestamp is generated when the TCP socket cumulative ACK is
moved beyond the tracked seqno for the first time. This corresponds
to the other peer having received all data up until this byte. The
feature ignores SACK and FACK, because those acknowledge the
specific byte, but not necessarily the entire contents of the buffer
passed in send()

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h | 24 ++++++++++++++++++++----
 include/linux/socket.h |  2 ++
 include/net/sock.h     |  4 ++--
 net/core/skbuff.c      | 11 +++++++----
 net/ipv4/tcp.c         |  2 +-
 net/ipv4/tcp_input.c   |  3 +++
 net/socket.c           | 11 +++++++++--
 7 files changed, 44 insertions(+), 13 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bec3ded..ee86654 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -258,8 +258,12 @@ enum {
 	 * all frags to avoid possible bad checksum
 	 */
 	SKBTX_SHARED_FRAG = 1 << 5,
+
+	SKBTX_ACK_TSTAMP = 1 << 6,
 };
 
+#define SKBTX_ANY_SW_TSTAMP (SKBTX_SW_TSTAMP | SKBTX_ACK_TSTAMP)
+
 /*
  * The callback notifies userspace to release buffers when skb DMA is done in
  * lower device, the skb last reference should be 0 when calling this.
@@ -2697,6 +2701,10 @@ static inline bool skb_defer_rx_timestamp(struct sk_buff *skb)
 void skb_complete_tx_timestamp(struct sk_buff *skb,
 			       struct skb_shared_hwtstamps *hwtstamps);
 
+void __skb_tstamp_tx(struct sk_buff *orig_skb,
+		     struct skb_shared_hwtstamps *hwtstamps,
+		     struct sock *sk, int tstype);
+
 /**
  * skb_tstamp_tx - queue clone of skb with send time stamps
  * @orig_skb:	the original outgoing packet
@@ -2708,8 +2716,12 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
  * generates a software time stamp (otherwise), then queues the clone
  * to the error queue of the socket.  Errors are silently ignored.
  */
-void skb_tstamp_tx(struct sk_buff *orig_skb,
-		   struct skb_shared_hwtstamps *hwtstamps);
+static inline void skb_tstamp_tx(struct sk_buff *orig_skb,
+				 struct skb_shared_hwtstamps *hwtstamps)
+{
+	return __skb_tstamp_tx(orig_skb, hwtstamps, orig_skb->sk,
+			       hwtstamps ? 0 : SKBTX_SW_TSTAMP);
+}
 
 static inline void sw_tx_timestamp(struct sk_buff *skb)
 {
@@ -2740,8 +2752,12 @@ static inline u8 skbflags_tx_tstamp(int flags)
 {
 	u8 tx_flags = 0;
 
-	if (unlikely(flags & MSG_TSTAMP))
-		tx_flags |= SKBTX_SW_TSTAMP;
+	if (unlikely(flags & MSG_TSTAMP_MASK)) {
+		if (flags & MSG_TSTAMP)
+			tx_flags |= SKBTX_SW_TSTAMP;
+		if (flags & MSG_TSTAMP_ACK)
+			tx_flags |= SKBTX_ACK_TSTAMP;
+	}
 
 	return tx_flags;
 }
diff --git a/include/linux/socket.h b/include/linux/socket.h
index ce4101e..68d5f48 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -254,6 +254,8 @@ struct ucred {
 #define MSG_WAITFORONE	0x10000	/* recvmmsg(): block until 1+ packets avail */
 #define MSG_SENDPAGE_NOTLAST 0x20000 /* sendpage() internal : not the last page */
 #define MSG_TSTAMP	0x100000
+#define MSG_TSTAMP_ACK	0x200000
+#define MSG_TSTAMP_MASK	(MSG_TSTAMP | MSG_TSTAMP_ACK)
 #define MSG_EOF         MSG_FIN
 
 #define MSG_FASTOPEN	0x20000000	/* Send data in TCP SYN */
diff --git a/include/net/sock.h b/include/net/sock.h
index df7bde0..0fcd12e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2139,7 +2139,7 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 	 * - receive time stamping in software requested (SOCK_RCVTSTAMP
 	 *   or SOCK_TIMESTAMPING_RX_SOFTWARE)
 	 * - software time stamp available and wanted
-	 *   (SOCK_TIMESTAMPING_SOFTWARE || SKBTX_SW_TSTAMP)
+	 *   (SOCK_TIMESTAMPING_SOFTWARE || SKBTX_ANY_SW_TSTAMP)
 	 * - hardware time stamps available and wanted
 	 *   (SOCK_TIMESTAMPING_SYS_HARDWARE or
 	 *   SOCK_TIMESTAMPING_RAW_HARDWARE)
@@ -2147,7 +2147,7 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 	if (sock_flag(sk, SOCK_RCVTSTAMP) ||
 	    sock_flag(sk, SOCK_TIMESTAMPING_RX_SOFTWARE) ||
 	    (kt.tv64 && (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
-	     skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP)) ||
+	     skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP)) ||
 	    (hwtstamps->hwtstamp.tv64 &&
 	     sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE)) ||
 	    (hwtstamps->syststamp.tv64 &&
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 07ba98d..7b0823a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3491,10 +3491,10 @@ int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_queue_err_skb);
 
-void skb_tstamp_tx(struct sk_buff *orig_skb,
-		struct skb_shared_hwtstamps *hwtstamps)
+void __skb_tstamp_tx(struct sk_buff *orig_skb,
+		     struct skb_shared_hwtstamps *hwtstamps,
+		     struct sock *sk, int tstype)
 {
-	struct sock *sk = orig_skb->sk;
 	struct sock_exterr_skb *serr;
 	struct sk_buff *skb;
 	__u32 key = 0;
@@ -3534,6 +3534,8 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 			key = ntohl(tcp_hdr(skb)->seq) +
 			      ntohs(ip_hdr(skb)->tot_len) -
 			      ip_hdrlen(skb) - tcp_hdrlen(skb);
+	} else if (tstype == SKBTX_ACK_TSTAMP) {
+		key = TCP_SKB_CB(orig_skb)->end_seq;
 	}
 
 	serr = SKB_EXT_ERR(skb);
@@ -3541,13 +3543,14 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
 	serr->ee.ee_data = key;
+	serr->ee.ee_info = tstype;
 
 	err = sock_queue_err_skb(sk, skb);
 
 	if (err)
 		kfree_skb(skb);
 }
-EXPORT_SYMBOL_GPL(skb_tstamp_tx);
+EXPORT_SYMBOL_GPL(__skb_tstamp_tx);
 
 void skb_complete_wifi_ack(struct sk_buff *skb, bool acked)
 {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4ceecd9..b792642 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -880,7 +880,7 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 
 static bool tcp_skb_can_extend(struct sk_buff *skb)
 {
-	return !(skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP);
+	return !(skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP);
 }
 
 static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 40661fc..90fa2df 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3103,6 +3103,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		if (!fully_acked)
 			break;
 
+		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_ACK_TSTAMP))
+			__skb_tstamp_tx(skb, NULL, sk, SKBTX_ACK_TSTAMP);
+
 		tcp_unlink_write_queue(skb, sk);
 		sk_wmem_free_skb(sk, skb);
 		if (skb == tp->retransmit_skb_hint)
diff --git a/net/socket.c b/net/socket.c
index d01e323..b71001b 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -725,11 +725,18 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 
 	memset(&tss, 0, sizeof(tss));
 	if ((sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
-	     skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP) &&
+	     skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP) &&
 	    ktime_to_timespec_cond(skb->tstamp, &tss.ts_sw)) {
 		empty = 0;
 		tss.ts_key = serr->ee.ee_data;
-		tss.ts_type = SCM_TSTAMP_SND;
+		switch (serr->ee.ee_info) {
+		case SKBTX_SW_TSTAMP:
+			tss.ts_type = SCM_TSTAMP_SND;
+			break;
+		case SKBTX_ACK_TSTAMP:
+			tss.ts_type = SCM_TSTAMP_ACK;
+			break;
+		}
 	}
 	if (shhwtstamps) {
 		if (sock_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE) &&
-- 
2.0.0.526.g5318336
