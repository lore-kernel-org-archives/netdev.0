From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH v1 net-next 5/6] net: allow simultaneous SW and HW transmit timestamping
Date: Wed, 26 Apr 2017 16:50:34 +0200
Message-ID: <20170426145035.25846-6-mlichvar@redhat.com>
References: <20170426145035.25846-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10774 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S3001502AbdDZOut (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 10:50:49 -0400
In-Reply-To: <20170426145035.25846-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add SOF_TIMESTAMPING_OPT_TX_SWHW option to allow an outgoing packet to
be looped to the socket's error queue with a software timestamp even
when a hardware transmit timestamp is expected to be provided by the
driver.

Applications using this option will receive two separate messages from
the error queue, one with a software timestamp and the other with a
hardware timestamp. As the hardware timestamp is saved to the shared skb
info, which may happen before the first message with software timestamp
is received by the application, the hardware timestamp is copied to the
SCM_TIMESTAMPING control message only when the skb has no software
timestamp or it is an incoming packet.

CC: Richard Cochran <richardcochran@gmail.com>
CC: Willem de Bruijn <willemb@google.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 Documentation/networking/timestamping.txt | 14 ++++++++++++--
 include/linux/skbuff.h                    |  3 +--
 include/uapi/linux/net_tstamp.h           |  3 ++-
 net/core/skbuff.c                         |  4 ++++
 net/socket.c                              |  1 +
 5 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index 6c07e7c..ab29a6e 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -201,6 +201,14 @@ SOF_TIMESTAMPING_OPT_PKTINFO:
   which received the packet and its length at layer 2. This option
   works only if CONFIG_NET_RX_BUSY_POLL is enabled.
 
+SOF_TIMESTAMPING_OPT_TX_SWHW:
+
+  Request both hardware and software timestamps for outgoing packets
+  when SOF_TIMESTAMPING_TX_HARDWARE and SOF_TIMESTAMPING_TX_SOFTWARE
+  are enabled at the same time. If both timestamps are generated,
+  two separate messages will be looped to the socket's error queue,
+  each containing just one timestamp.
+
 New applications are encouraged to pass SOF_TIMESTAMPING_OPT_ID to
 disambiguate timestamps and SOF_TIMESTAMPING_OPT_TSONLY to operate
 regardless of the setting of sysctl net.core.tstamp_allow_data.
@@ -320,8 +328,10 @@ struct scm_timestamping {
 };
 
 The structure can return up to three timestamps. This is a legacy
-feature. Only one field is non-zero at any time. Most timestamps
-are passed in ts[0]. Hardware timestamps are passed in ts[2].
+feature. Most timestamps are passed in ts[0]. Hardware timestamps
+are passed in ts[2]. Incoming packets may have timestamps in both
+ts[0] and ts[2], but for outgoing packets only one field is non-zero
+at any time.
 
 ts[1] used to hold hardware timestamps converted to system time.
 Instead, expose the hardware clock device on the NIC directly as
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 81ef53f..42bff22 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3300,8 +3300,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 
 static inline void sw_tx_timestamp(struct sk_buff *skb)
 {
-	if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP &&
-	    !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
+	if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP)
 		skb_tstamp_tx(skb, NULL);
 }
 
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index 8fcae35..d251972 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -27,8 +27,9 @@ enum {
 	SOF_TIMESTAMPING_OPT_TSONLY = (1<<11),
 	SOF_TIMESTAMPING_OPT_STATS = (1<<12),
 	SOF_TIMESTAMPING_OPT_PKTINFO = (1<<13),
+	SOF_TIMESTAMPING_OPT_TX_SWHW = (1<<14),
 
-	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_PKTINFO,
+	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_TX_SWHW,
 	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
 				 SOF_TIMESTAMPING_LAST
 };
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 58604c1..db5aa19 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3874,6 +3874,10 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 	if (!sk)
 		return;
 
+	if (!hwtstamps && !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TX_SWHW) &&
+	    skb_shinfo(orig_skb)->tx_flags & SKBTX_IN_PROGRESS)
+		return;
+
 	tsonly = sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TSONLY;
 	if (!skb_may_tx_timestamp(sk, tsonly))
 		return;
diff --git a/net/socket.c b/net/socket.c
index 68b9304..14b7688 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -720,6 +720,7 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 		empty = 0;
 	if (shhwtstamps &&
 	    (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
+	    (empty || !skb_is_err_queue(skb)) &&
 	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
 		empty = 0;
 		if ((sk->sk_tsflags & SOF_TIMESTAMPING_OPT_PKTINFO) &&
-- 
2.9.3
