From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2 6/8] net-timestamp: ENQ timestamp on enqueue to traffic shaping layer
Date: Thu,  3 Jul 2014 15:39:38 -0400
Message-ID: <1404416380-3545-7-git-send-email-willemb@google.com>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gomail.com, stephen@networkplumber.org,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:59705 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbaGCTjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 15:39:51 -0400
Received: by mail-qc0-f201.google.com with SMTP id c9so87672qcz.4
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 12:39:50 -0700 (PDT)
In-Reply-To: <1404416380-3545-1-git-send-email-willemb@google.com>
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
 net/core/dev.c         | 4 ++++
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0205184..ec76556 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -260,9 +260,13 @@ enum {
 	SKBTX_SHARED_FRAG = 1 << 5,
 
 	SKBTX_ACK_TSTAMP = 1 << 6,
+
+	SKBTX_ENQ_TSTAMP = 1 << 7,
 };
 
-#define SKBTX_ANY_SW_TSTAMP 	(SKBTX_SW_TSTAMP | SKBTX_ACK_TSTAMP)
+#define SKBTX_ANY_SW_TSTAMP	(SKBTX_SW_TSTAMP  | \
+				 SKBTX_ACK_TSTAMP | \
+				 SKBTX_ENQ_TSTAMP)
 #define SKBTX_ANY_TSTAMP	(SKBTX_HW_TSTAMP | SKBTX_ANY_SW_TSTAMP)
 
 /*
@@ -2754,6 +2758,8 @@ static inline u8 skbflags_tx_tstamp(int flags)
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
index 6e2a2cd..b710213f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -132,6 +132,7 @@
 #include <linux/hashtable.h>
 #include <linux/vmalloc.h>
 #include <linux/if_macvlan.h>
+#include <linux/errqueue.h>
 
 #include "net-sysfs.h"
 
@@ -2859,6 +2860,9 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 
 	skb_reset_mac_header(skb);
 
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_ENQ_TSTAMP))
+		__skb_tstamp_tx(skb, NULL, skb->sk, SCM_TSTAMP_ENQ);
+
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
-- 
2.0.0.526.g5318336
