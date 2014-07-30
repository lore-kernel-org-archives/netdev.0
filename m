From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v4 3/5] net-timestamp: ENQ timestamp on enqueue to traffic shaping layer
Date: Wed, 30 Jul 2014 11:48:46 -0400
Message-ID: <1406735328-7520-4-git-send-email-willemb@google.com>
References: <1406735328-7520-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:54499 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575AbaG3Psv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 11:48:51 -0400
Received: by mail-ie0-f202.google.com with SMTP id rl12so406351iec.5
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 08:48:50 -0700 (PDT)
In-Reply-To: <1406735328-7520-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel transmit latency is often incurred in the traffic shaping
layer. This patch adds a new timestamp on transmission just before
entering traffic shaping. When data travels through multiple devices
(bonding, tunneling, ...) each device will export an individual
timestamp.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h          | 11 +++++++++--
 include/uapi/linux/errqueue.h   |  1 +
 include/uapi/linux/net_tstamp.h |  8 +++++---
 net/core/dev.c                  |  4 ++++
 net/core/skbuff.c               | 16 ++++++++++++----
 net/socket.c                    |  3 +++
 6 files changed, 34 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 477f0f6..faa7ebe 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -229,7 +229,7 @@ enum {
 	/* generate hardware time stamp */
 	SKBTX_HW_TSTAMP = 1 << 0,
 
-	/* generate software time stamp */
+	/* generate software time stamp when queueing packet to NIC */
 	SKBTX_SW_TSTAMP = 1 << 1,
 
 	/* device driver is going to provide hardware time stamp */
@@ -247,9 +247,12 @@ enum {
 	 * all frags to avoid possible bad checksum
 	 */
 	SKBTX_SHARED_FRAG = 1 << 5,
+
+	/* generate software time stamp when queueing packing in TC */
+	SKBTX_ENQ_TSTAMP = 1 << 6,
 };
 
-#define SKBTX_ANY_SW_TSTAMP	SKBTX_SW_TSTAMP
+#define SKBTX_ANY_SW_TSTAMP	(SKBTX_SW_TSTAMP | SKBTX_ENQ_TSTAMP)
 #define SKBTX_ANY_TSTAMP	(SKBTX_HW_TSTAMP | SKBTX_ANY_SW_TSTAMP)
 
 /*
@@ -2694,6 +2697,10 @@ static inline bool skb_defer_rx_timestamp(struct sk_buff *skb)
 void skb_complete_tx_timestamp(struct sk_buff *skb,
 			       struct skb_shared_hwtstamps *hwtstamps);
 
+void __skb_tstamp_tx(struct sk_buff *orig_skb,
+		     struct skb_shared_hwtstamps *hwtstamps,
+		     struct sock *sk, int tstype);
+
 /**
  * skb_tstamp_tx - queue clone of skb with send time stamps
  * @orig_skb:	the original outgoing packet
diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index 97e1872..d37e5c7 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -36,6 +36,7 @@ struct scm_timestamping {
 /* type of ts[0], passed in ee_info */
 enum {
 	SCM_TSTAMP_SND = 1,	/* driver passed skb to NIC */
+	SCM_TSTAMP_ENQ,		/* data enqueued in traffic shaping layer */
 };
 
 #endif /* _UAPI_LINUX_ERRQUEUE_H */
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index f53879c..99c2035 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -20,9 +20,11 @@ enum {
 	SOF_TIMESTAMPING_SOFTWARE = (1<<4),
 	SOF_TIMESTAMPING_SYS_HARDWARE = (1<<5),
 	SOF_TIMESTAMPING_RAW_HARDWARE = (1<<6),
-	SOF_TIMESTAMPING_MASK =
-	(SOF_TIMESTAMPING_RAW_HARDWARE - 1) |
-	SOF_TIMESTAMPING_RAW_HARDWARE
+	SOF_TIMESTAMPING_TX_ENQ = (1<<7),
+
+	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_TX_ENQ,
+	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
+				 SOF_TIMESTAMPING_LAST
 };
 
 /**
diff --git a/net/core/dev.c b/net/core/dev.c
index e1b7cfa..9854bdc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -132,6 +132,7 @@
 #include <linux/hashtable.h>
 #include <linux/vmalloc.h>
 #include <linux/if_macvlan.h>
+#include <linux/errqueue.h>
 
 #include "net-sysfs.h"
 
@@ -2876,6 +2877,9 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 
 	skb_reset_mac_header(skb);
 
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_ENQ_TSTAMP))
+		__skb_tstamp_tx(skb, NULL, skb->sk, SCM_TSTAMP_ENQ);
+
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1bcd05d..8f58faa 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3490,10 +3490,10 @@ int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
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
 	int err;
@@ -3521,13 +3521,21 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
-	serr->ee.ee_info = hwtstamps ? 0 : SCM_TSTAMP_SND;
+	serr->ee.ee_info = tstype;
 
 	err = sock_queue_err_skb(sk, skb);
 
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
diff --git a/net/socket.c b/net/socket.c
index 255d9b8..c2849ba 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -617,6 +617,9 @@ void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags)
 		*tx_flags |= SKBTX_HW_TSTAMP;
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_SOFTWARE)
 		*tx_flags |= SKBTX_SW_TSTAMP;
+	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_ENQ)
+		*tx_flags |= SKBTX_ENQ_TSTAMP;
+
 	if (sock_flag(sk, SOCK_WIFI_STATUS))
 		*tx_flags |= SKBTX_WIFI_STATUS;
 }
-- 
2.0.0.526.g5318336
