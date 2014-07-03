From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2 5/8] net-timestamp: ACK timestamp for bytestreams
Date: Thu,  3 Jul 2014 15:39:37 -0400
Message-ID: <1404416380-3545-6-git-send-email-willemb@google.com>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gomail.com, stephen@networkplumber.org,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:52688 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbaGCTjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 15:39:51 -0400
Received: by mail-vc0-f202.google.com with SMTP id id10so87094vcb.1
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 12:39:50 -0700 (PDT)
In-Reply-To: <1404416380-3545-1-git-send-email-willemb@google.com>
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
 include/linux/skbuff.h | 17 ++++++++++++++---
 include/linux/socket.h |  2 ++
 include/net/sock.h     |  4 ++--
 net/core/skbuff.c      | 18 ++++++++++++++----
 net/ipv4/tcp.c         |  2 +-
 net/ipv4/tcp_input.c   |  4 ++++
 net/socket.c           |  2 +-
 7 files changed, 38 insertions(+), 11 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 977596d..0205184 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -258,9 +258,12 @@ enum {
 	 * all frags to avoid possible bad checksum
 	 */
 	SKBTX_SHARED_FRAG = 1 << 5,
+
+	SKBTX_ACK_TSTAMP = 1 << 6,
 };
 
-#define SKBTX_ANY_TSTAMP	(SKBTX_HW_TSTAMP | SKBTX_SW_TSTAMP)
+#define SKBTX_ANY_SW_TSTAMP 	(SKBTX_SW_TSTAMP | SKBTX_ACK_TSTAMP)
+#define SKBTX_ANY_TSTAMP	(SKBTX_HW_TSTAMP | SKBTX_ANY_SW_TSTAMP)
 
 /*
  * The callback notifies userspace to release buffers when skb DMA is done in
@@ -2699,6 +2702,10 @@ static inline bool skb_defer_rx_timestamp(struct sk_buff *skb)
 void skb_complete_tx_timestamp(struct sk_buff *skb,
 			       struct skb_shared_hwtstamps *hwtstamps);
 
+void __skb_tstamp_tx(struct sk_buff *orig_skb,
+		     struct skb_shared_hwtstamps *hwtstamps,
+		     struct sock *sk, int tstype);
+
 /**
  * skb_tstamp_tx - queue clone of skb with send time stamps
  * @orig_skb:	the original outgoing packet
@@ -2742,8 +2749,12 @@ static inline u8 skbflags_tx_tstamp(int flags)
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
index 7a97200..489143b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2141,7 +2141,7 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 	 * - receive time stamping in software requested (SOCK_RCVTSTAMP
 	 *   or SOCK_TIMESTAMPING_RX_SOFTWARE)
 	 * - software time stamp available and wanted
-	 *   (SOCK_TIMESTAMPING_SOFTWARE || SKBTX_SW_TSTAMP)
+	 *   (SOCK_TIMESTAMPING_SOFTWARE || SKBTX_ANY_SW_TSTAMP)
 	 * - hardware time stamps available and wanted
 	 *   (SOCK_TIMESTAMPING_SYS_HARDWARE or
 	 *   SOCK_TIMESTAMPING_RAW_HARDWARE)
@@ -2149,7 +2149,7 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 	if (sock_flag(sk, SOCK_RCVTSTAMP) ||
 	    sock_flag(sk, SOCK_TIMESTAMPING_RX_SOFTWARE) ||
 	    (kt.tv64 && (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
-	     skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP)) ||
+	     skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP)) ||
 	    (hwtstamps->hwtstamp.tv64 &&
 	     sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE)) ||
 	    (hwtstamps->syststamp.tv64 &&
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7657658..8c479df 100644
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
@@ -3534,13 +3534,15 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 			key = ntohl(tcp_hdr(skb)->seq) +
 			      ntohs(ip_hdr(skb)->tot_len) -
 			      ip_hdrlen(skb) - tcp_hdrlen(skb);
+	} else if (tstype == SCM_TSTAMP_ACK) {
+		key = TCP_SKB_CB(orig_skb)->end_seq;
 	}
 
 	serr = SKB_EXT_ERR(skb);
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
-	serr->ee.ee_info = hwtstamps ? 0 : SCM_TSTAMP_SND;
+	serr->ee.ee_info = tstype;
 	serr->ee.ee_data = key;
 
 	err = sock_queue_err_skb(sk, skb);
@@ -3548,6 +3550,14 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	if (err)
 		kfree_skb(skb);
 }
+EXPORT_SYMBOL_GPL(__skb_tstamp_tx);
+
+void skb_tstamp_tx(struct sk_buff *orig_skb,
+		   struct skb_shared_hwtstamps *hwtstamps)
+{
+	return __skb_tstamp_tx(orig_skb, hwtstamps, orig_skb->sk,
+			       hwtstamps ? 0 : SCM_TSTAMP_SND);
+}
 EXPORT_SYMBOL_GPL(skb_tstamp_tx);
 
 void skb_complete_wifi_ack(struct sk_buff *skb, bool acked)
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
index bb68496..cf3fb2c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -74,6 +74,7 @@
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <net/netdma.h>
+#include <linux/errqueue.h>
 
 int sysctl_tcp_timestamps __read_mostly = 1;
 int sysctl_tcp_window_scaling __read_mostly = 1;
@@ -3103,6 +3104,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		if (!fully_acked)
 			break;
 
+		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_ACK_TSTAMP))
+			__skb_tstamp_tx(skb, NULL, sk, SCM_TSTAMP_ACK);
+
 		tcp_unlink_write_queue(skb, sk);
 		sk_wmem_free_skb(sk, skb);
 		if (skb == tp->retransmit_skb_hint)
diff --git a/net/socket.c b/net/socket.c
index 9f69a25..ea807c8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -725,7 +725,7 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 
 	memset(&tss, 0, sizeof(tss));
 	if ((sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
-	     skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP) &&
+	     skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP) &&
 	    ktime_to_timespec_cond(skb->tstamp, tss.ts + 0))
 		tstype |= is_tx ? serr->ee.ee_info : SCM_TSTAMP_RCV;
 	if (shhwtstamps) {
-- 
2.0.0.526.g5318336
