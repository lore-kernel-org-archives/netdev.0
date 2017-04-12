From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [RFC PATCH 6/7] net: allow simultaneous SW and HW transmit timestamping
Date: Wed, 12 Apr 2017 16:17:36 +0200
Message-ID: <20170412141737.5881-7-mlichvar@redhat.com>
References: <20170412141737.5881-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43904 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753239AbdDLOR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 10:17:59 -0400
In-Reply-To: <20170412141737.5881-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add SOF_TIMESTAMPING_OPT_MULTIMSG option to allow looping the outgoing
packet to the socket's error queue with a software timestamp even when
a hardware transmit timestamp is expected to be provided by the driver.

Applications using this option will receive two separate messages from
the error queue, one with a software timestamp and the other with a
hardware timestamp. As the hardware timestamp is saved to the shared skb
info, which may happen before the first message with software timestamp
is received by the application, the hardware timestamp is copied to the
SCM_TIMESTAMPING control message only when the skb has no software
timestamp.

CC: Richard Cochran <richardcochran@gmail.com>
CC: Willem de Bruijn <willemb@google.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 Documentation/networking/timestamping.txt | 12 ++++++++++--
 include/linux/skbuff.h                    |  3 +--
 include/uapi/linux/net_tstamp.h           |  3 ++-
 net/core/skbuff.c                         |  4 ++++
 net/socket.c                              |  6 ++++++
 5 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index ed04aaa..8f30385 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -201,6 +201,12 @@ SOF_TIMESTAMPING_OPT_PKTINFO:
   this information, it will be attached in struct scm_ts_pktinfo as
   a separate control message of type SCM_TIMESTAMPING_PKTINFO.
 
+SOF_TIMESTAMPING_OPT_MULTIMSG:
+
+  Allow outgoing packets to be looped multiple times to the socket's
+  error queue in order to receive both software and hardware transmit
+  timestamps.
+
 New applications are encouraged to pass SOF_TIMESTAMPING_OPT_ID to
 disambiguate timestamps and SOF_TIMESTAMPING_OPT_TSONLY to operate
 regardless of the setting of sysctl net.core.tstamp_allow_data.
@@ -320,8 +326,10 @@ struct scm_timestamping {
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
index e91685a..0387c4b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3302,8 +3302,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 
 static inline void sw_tx_timestamp(struct sk_buff *skb)
 {
-	if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP &&
-	    !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
+	if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP)
 		skb_tstamp_tx(skb, NULL);
 }
 
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index 8397ecd..887e3ff 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -27,8 +27,9 @@ enum {
 	SOF_TIMESTAMPING_OPT_TSONLY = (1<<11),
 	SOF_TIMESTAMPING_OPT_STATS = (1<<12),
 	SOF_TIMESTAMPING_OPT_PKTINFO = (1<<13),
+	SOF_TIMESTAMPING_OPT_MULTIMSG = (1<<14),
 
-	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_PKTINFO,
+	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_MULTIMSG,
 	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
 				 SOF_TIMESTAMPING_LAST
 };
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7ca251f..d3df8ff 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3863,6 +3863,10 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 	if (!sk)
 		return;
 
+	if (!hwtstamps && !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_MULTIMSG) &&
+	    skb_shinfo(orig_skb)->tx_flags & SKBTX_IN_PROGRESS)
+		return;
+
 	tsonly = sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TSONLY;
 	if (!skb_may_tx_timestamp(sk, tsonly))
 		return;
diff --git a/net/socket.c b/net/socket.c
index 32e78de..5c9f2eb 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -695,12 +695,18 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 		}
 	}
 
+	/* Received packets may have both SW and HW timestamps in one control
+	 * message.  Transmitted packets may have only one timestamp in the
+	 * control message, but there may be two separate messages in the error
+	 * queue if the SOF_TIMESTAMPING_OPT_MULTIMSG option is enabled.
+	 */
 	memset(&tss, 0, sizeof(tss));
 	if ((sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE) &&
 	    ktime_to_timespec_cond(skb->tstamp, tss.ts + 0))
 		empty = 0;
 	if (shhwtstamps &&
 	    (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
+	    (empty || !skb_is_err_queue(skb)) &&
 	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
 		if (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_PKTINFO &&
 		    shhwtstamps->if_index) {
-- 
2.9.3
