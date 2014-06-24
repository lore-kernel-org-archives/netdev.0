From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 6/7] net-timestamp: ENQ timestamp on enqueue to traffic shaping layer
Date: Tue, 24 Jun 2014 11:43:51 -0400
Message-ID: <1403624632-17327-7-git-send-email-willemb@google.com>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
Cc: eric.dumazet@gmail.com, richardcochran@gmail.com,
	davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:38935 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488AbaFXPoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 11:44:00 -0400
Received: by mail-oa0-f74.google.com with SMTP id i7so102031oag.1
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 08:44:00 -0700 (PDT)
In-Reply-To: <1403624632-17327-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel transmit latency is often incurred in the traffic shaping
layer. This patch adds a new timestamp on transmission just before
entering traffic shaping. When data travels through multiple devices
(bonding, tunneling, ...) each device will export an individual
timestamp.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h | 8 +++++++-
 include/linux/socket.h | 3 ++-
 net/core/dev.c         | 3 +++
 net/socket.c           | 3 +++
 4 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ee86654..b6c2926 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -260,9 +260,13 @@ enum {
 	SKBTX_SHARED_FRAG = 1 << 5,
 
 	SKBTX_ACK_TSTAMP = 1 << 6,
+
+	SKBTX_ENQ_TSTAMP = 1 << 7,
 };
 
-#define SKBTX_ANY_SW_TSTAMP (SKBTX_SW_TSTAMP | SKBTX_ACK_TSTAMP)
+#define SKBTX_ANY_SW_TSTAMP (SKBTX_SW_TSTAMP | \
+			     SKBTX_ACK_TSTAMP | \
+			     SKBTX_ENQ_TSTAMP)
 
 /*
  * The callback notifies userspace to release buffers when skb DMA is done in
@@ -2757,6 +2761,8 @@ static inline u8 skbflags_tx_tstamp(int flags)
 			tx_flags |= SKBTX_SW_TSTAMP;
 		if (flags & MSG_TSTAMP_ACK)
 			tx_flags |= SKBTX_ACK_TSTAMP;
+		if (flags & MSG_TSTAMP_ENQ)
+			tx_flags |= SKBTX_ENQ_TSTAMP;
 	}
 
 	return tx_flags;
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 68d5f48..6d21582 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -255,7 +255,8 @@ struct ucred {
 #define MSG_SENDPAGE_NOTLAST 0x20000 /* sendpage() internal : not the last page */
 #define MSG_TSTAMP	0x100000
 #define MSG_TSTAMP_ACK	0x200000
-#define MSG_TSTAMP_MASK	(MSG_TSTAMP | MSG_TSTAMP_ACK)
+#define MSG_TSTAMP_ENQ	0x400000
+#define MSG_TSTAMP_MASK	(MSG_TSTAMP | MSG_TSTAMP_ACK | MSG_TSTAMP_ENQ)
 #define MSG_EOF         MSG_FIN
 
 #define MSG_FASTOPEN	0x20000000	/* Send data in TCP SYN */
diff --git a/net/core/dev.c b/net/core/dev.c
index a04b12f..8df522b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2859,6 +2859,9 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 
 	skb_reset_mac_header(skb);
 
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_ENQ_TSTAMP))
+		__skb_tstamp_tx(skb, NULL, skb->sk, SKBTX_ENQ_TSTAMP);
+
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
diff --git a/net/socket.c b/net/socket.c
index b71001b..9b8deaf 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -736,6 +736,9 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 		case SKBTX_ACK_TSTAMP:
 			tss.ts_type = SCM_TSTAMP_ACK;
 			break;
+		case SKBTX_ENQ_TSTAMP:
+			tss.ts_type = SCM_TSTAMP_ENQ;
+			break;
 		}
 	}
 	if (shhwtstamps) {
-- 
2.0.0.526.g5318336
