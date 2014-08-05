From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v4 6/6] net-timestamp: ACK timestamp for bytestreams
Date: Mon,  4 Aug 2014 22:11:50 -0400
Message-ID: <1407204710-21778-7-git-send-email-willemb@google.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:55353 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753451AbaHECLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 22:11:53 -0400
Received: by mail-oa0-f73.google.com with SMTP id g18so66692oah.0
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 19:11:52 -0700 (PDT)
In-Reply-To: <1407204710-21778-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add SOF_TIMESTAMPING_TX_ACK, a request for a tstamp when the last byte
in the send() call is acknowledged. It implements the feature for TCP.

The timestamp is generated when the TCP socket cumulative ACK is moved
beyond the tracked seqno for the first time. The feature ignores SACK
and FACK, because those acknowledge the specific byte, but not
necessarily the entire contents of the buffer up to that byte.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h          | 7 ++++++-
 include/uapi/linux/errqueue.h   | 1 +
 include/uapi/linux/net_tstamp.h | 3 ++-
 net/ipv4/tcp_input.c            | 6 ++++++
 net/socket.c                    | 2 ++
 5 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 50e1e9b..11c2705 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -250,9 +250,14 @@ enum {
 
 	/* generate software time stamp when entering packet scheduling */
 	SKBTX_SCHED_TSTAMP = 1 << 6,
+
+	/* generate software timestamp on peer data acknowledgment */
+	SKBTX_ACK_TSTAMP = 1 << 7,
 };
 
-#define SKBTX_ANY_SW_TSTAMP	(SKBTX_SW_TSTAMP | SKBTX_SCHED_TSTAMP)
+#define SKBTX_ANY_SW_TSTAMP	(SKBTX_SW_TSTAMP    | \
+				 SKBTX_SCHED_TSTAMP | \
+				 SKBTX_ACK_TSTAMP)
 #define SKBTX_ANY_TSTAMP	(SKBTX_HW_TSTAMP | SKBTX_ANY_SW_TSTAMP)
 
 /*
diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index 17437cf..07bdce1 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -40,6 +40,7 @@ struct scm_timestamping {
 enum {
 	SCM_TSTAMP_SND,		/* driver passed skb to NIC, or HW */
 	SCM_TSTAMP_SCHED,	/* data entered the packet scheduler */
+	SCM_TSTAMP_ACK,		/* data acknowledged by peer */
 };
 
 #endif /* _UAPI_LINUX_ERRQUEUE_H */
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index 6073384..ff35402 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -22,8 +22,9 @@ enum {
 	SOF_TIMESTAMPING_RAW_HARDWARE = (1<<6),
 	SOF_TIMESTAMPING_OPT_ID = (1<<7),
 	SOF_TIMESTAMPING_TX_SCHED = (1<<8),
+	SOF_TIMESTAMPING_TX_ACK = (1<<9),
 
-	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_TX_SCHED,
+	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_TX_ACK,
 	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
 				 SOF_TIMESTAMPING_LAST
 };
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7832d94..1320602 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -74,6 +74,7 @@
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <net/netdma.h>
+#include <linux/errqueue.h>
 
 int sysctl_tcp_timestamps __read_mostly = 1;
 int sysctl_tcp_window_scaling __read_mostly = 1;
@@ -3099,6 +3100,11 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			tp->retrans_stamp = 0;
 		}
 
+		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_ACK_TSTAMP) &&
+		    between(skb_shinfo(skb)->tskey, prior_snd_una,
+			    tp->snd_una + 1))
+			__skb_tstamp_tx(skb, NULL, sk, SCM_TSTAMP_ACK);
+
 		if (!fully_acked)
 			break;
 
diff --git a/net/socket.c b/net/socket.c
index 3a2778d..ae89569 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -619,6 +619,8 @@ void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags)
 		*tx_flags |= SKBTX_SW_TSTAMP;
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_SCHED)
 		*tx_flags |= SKBTX_SCHED_TSTAMP;
+	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_ACK)
+		*tx_flags |= SKBTX_ACK_TSTAMP;
 
 	if (sock_flag(sk, SOCK_WIFI_STATUS))
 		*tx_flags |= SKBTX_WIFI_STATUS;
-- 
2.0.0.526.g5318336
