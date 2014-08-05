From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v4 4/6] net-timestamp: SCHED timestamp on entering packet scheduler
Date: Mon,  4 Aug 2014 22:11:48 -0400
Message-ID: <1407204710-21778-5-git-send-email-willemb@google.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:39391 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453AbaHECLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 22:11:53 -0400
Received: by mail-ig0-f202.google.com with SMTP id r2so103561igi.5
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 19:11:53 -0700 (PDT)
In-Reply-To: <1407204710-21778-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel transmit latency is often incurred in the packet scheduler.
Introduce a new timestamp on transmission just before entering the
scheduler. When data travels through multiple devices (bonding,
tunneling, ...) each device will export an individual timestamp.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h          | 11 +++++++++--
 include/uapi/linux/errqueue.h   |  1 +
 include/uapi/linux/net_tstamp.h |  3 ++-
 net/core/dev.c                  |  4 ++++
 net/core/skbuff.c               | 16 ++++++++++++----
 net/socket.c                    |  3 +++
 6 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0e35b3a..50e1e9b 100644
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
+	/* generate software time stamp when entering packet scheduling */
+	SKBTX_SCHED_TSTAMP = 1 << 6,
 };
 
-#define SKBTX_ANY_SW_TSTAMP	SKBTX_SW_TSTAMP
+#define SKBTX_ANY_SW_TSTAMP	(SKBTX_SW_TSTAMP | SKBTX_SCHED_TSTAMP)
 #define SKBTX_ANY_TSTAMP	(SKBTX_HW_TSTAMP | SKBTX_ANY_SW_TSTAMP)
 
 /*
@@ -2695,6 +2698,10 @@ static inline bool skb_defer_rx_timestamp(struct sk_buff *skb)
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
index accee72..17437cf 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -39,6 +39,7 @@ struct scm_timestamping {
  */
 enum {
 	SCM_TSTAMP_SND,		/* driver passed skb to NIC, or HW */
+	SCM_TSTAMP_SCHED,	/* data entered the packet scheduler */
 };
 
 #endif /* _UAPI_LINUX_ERRQUEUE_H */
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index 1e861d2..6073384 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -21,8 +21,9 @@ enum {
 	SOF_TIMESTAMPING_SYS_HARDWARE = (1<<5),
 	SOF_TIMESTAMPING_RAW_HARDWARE = (1<<6),
 	SOF_TIMESTAMPING_OPT_ID = (1<<7),
+	SOF_TIMESTAMPING_TX_SCHED = (1<<8),
 
-	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_ID,
+	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_TX_SCHED,
 	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
 				 SOF_TIMESTAMPING_LAST
 };
diff --git a/net/core/dev.c b/net/core/dev.c
index b370230..1c15b18 100644
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
 
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_SCHED_TSTAMP))
+		__skb_tstamp_tx(skb, NULL, skb->sk, SCM_TSTAMP_SCHED);
+
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0df4f1d..9705c07 100644
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
@@ -3521,7 +3521,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
-	serr->ee.ee_info = SCM_TSTAMP_SND;
+	serr->ee.ee_info = tstype;
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)
 		serr->ee.ee_data = skb_shinfo(skb)->tskey;
 
@@ -3530,6 +3530,14 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	if (err)
 		kfree_skb(skb);
 }
+EXPORT_SYMBOL_GPL(__skb_tstamp_tx);
+
+void skb_tstamp_tx(struct sk_buff *orig_skb,
+		   struct skb_shared_hwtstamps *hwtstamps)
+{
+	return __skb_tstamp_tx(orig_skb, hwtstamps, orig_skb->sk,
+			       SCM_TSTAMP_SND);
+}
 EXPORT_SYMBOL_GPL(skb_tstamp_tx);
 
 void skb_complete_wifi_ack(struct sk_buff *skb, bool acked)
diff --git a/net/socket.c b/net/socket.c
index 255d9b8..3a2778d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -617,6 +617,9 @@ void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags)
 		*tx_flags |= SKBTX_HW_TSTAMP;
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_SOFTWARE)
 		*tx_flags |= SKBTX_SW_TSTAMP;
+	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_SCHED)
+		*tx_flags |= SKBTX_SCHED_TSTAMP;
+
 	if (sock_flag(sk, SOCK_WIFI_STATUS))
 		*tx_flags |= SKBTX_WIFI_STATUS;
 }
-- 
2.0.0.526.g5318336
