From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v3 5/5] net-timestamp: ACK timestamp for bytestreams
Date: Mon, 21 Jul 2014 15:35:57 -0400
Message-ID: <1405971357-22830-6-git-send-email-willemb@google.com>
References: <1405971357-22830-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:62129 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755297AbaGUTgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 15:36:00 -0400
Received: by mail-qa0-f73.google.com with SMTP id s7so1056960qap.0
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 12:35:59 -0700 (PDT)
In-Reply-To: <1405971357-22830-1-git-send-email-willemb@google.com>
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
 include/linux/skbuff.h          | 7 ++++++-
 include/uapi/linux/errqueue.h   | 1 +
 include/uapi/linux/net_tstamp.h | 3 ++-
 net/ipv4/tcp_input.c            | 4 ++++
 net/socket.c                    | 2 ++
 5 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8c98dc9..13299db 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -263,9 +263,14 @@ enum {
 
 	/* generate software time stamp when queueing packing in TC */
 	SKBTX_ENQ_TSTAMP = 1 << 6,
+
+	/* generate software timestamp on peer data acknowledgment */
+	SKBTX_ACK_TSTAMP = 1 << 7,
 };
 
-#define SKBTX_ANY_SW_TSTAMP	(SKBTX_SW_TSTAMP | SKBTX_ENQ_TSTAMP)
+#define SKBTX_ANY_SW_TSTAMP	(SKBTX_SW_TSTAMP  | \
+				 SKBTX_ENQ_TSTAMP | \
+				 SKBTX_ACK_TSTAMP)
 #define SKBTX_ANY_TSTAMP	(SKBTX_HW_TSTAMP | SKBTX_ANY_SW_TSTAMP)
 
 /*
diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index d37e5c7..81639bc 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -37,6 +37,7 @@ struct scm_timestamping {
 enum {
 	SCM_TSTAMP_SND = 1,	/* driver passed skb to NIC */
 	SCM_TSTAMP_ENQ,		/* data enqueued in traffic shaping layer */
+	SCM_TSTAMP_ACK,		/* data acknowledged by peer */
 };
 
 #endif /* _UAPI_LINUX_ERRQUEUE_H */
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index 99c2035..bf9f338 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -21,8 +21,9 @@ enum {
 	SOF_TIMESTAMPING_SYS_HARDWARE = (1<<5),
 	SOF_TIMESTAMPING_RAW_HARDWARE = (1<<6),
 	SOF_TIMESTAMPING_TX_ENQ = (1<<7),
+	SOF_TIMESTAMPING_TX_ACK = (1<<8),
 
-	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_TX_ENQ,
+	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_TX_ACK,
 	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
 				 SOF_TIMESTAMPING_LAST
 };
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7832d94..f52f159 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -74,6 +74,7 @@
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <net/netdma.h>
+#include <linux/errqueue.h>
 
 int sysctl_tcp_timestamps __read_mostly = 1;
 int sysctl_tcp_window_scaling __read_mostly = 1;
@@ -3102,6 +3103,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		if (!fully_acked)
 			break;
 
+		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_ACK_TSTAMP))
+			__skb_tstamp_tx(skb, NULL, sk, SCM_TSTAMP_ACK);
+
 		tcp_unlink_write_queue(skb, sk);
 		sk_wmem_free_skb(sk, skb);
 		if (skb == tp->retransmit_skb_hint)
diff --git a/net/socket.c b/net/socket.c
index 22c7f55..7d3f171 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -619,6 +619,8 @@ void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags)
 		*tx_flags |= SKBTX_SW_TSTAMP;
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_ENQ)
 		*tx_flags |= SKBTX_ENQ_TSTAMP;
+	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_ACK)
+		*tx_flags |= SKBTX_ACK_TSTAMP;
 
 	if (sock_flag(sk, SOCK_WIFI_STATUS))
 		*tx_flags |= SKBTX_WIFI_STATUS;
-- 
2.0.0.526.g5318336
