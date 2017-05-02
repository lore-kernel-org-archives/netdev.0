From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH v2 net-next 6/7] net: allow simultaneous SW and HW transmit timestamping
Date: Tue,  2 May 2017 12:11:02 +0200
Message-ID: <20170502101103.30444-7-mlichvar@redhat.com>
References: <20170502101103.30444-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44204 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751184AbdEBKLb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 06:11:31 -0400
In-Reply-To: <20170502101103.30444-1-mlichvar@redhat.com>
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

While changing sw_tx_timestamp(), inline it in skb_tx_timestamp() as
there are no other users.

CC: Richard Cochran <richardcochran@gmail.com>
CC: Willem de Bruijn <willemb@google.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 Documentation/networking/timestamping.txt | 14 ++++++++++++--
 include/linux/skbuff.h                    | 10 ++--------
 include/uapi/linux/net_tstamp.h           |  3 ++-
 net/core/skbuff.c                         |  4 ++++
 net/socket.c                              | 11 +++++++++++
 5 files changed, 31 insertions(+), 11 deletions(-)

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
index bfe6ec3..3be2241 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3307,13 +3307,6 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 void skb_tstamp_tx(struct sk_buff *orig_skb,
 		   struct skb_shared_hwtstamps *hwtstamps);
 
-static inline void sw_tx_timestamp(struct sk_buff *skb)
-{
-	if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP &&
-	    !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
-		skb_tstamp_tx(skb, NULL);
-}
-
 /**
  * skb_tx_timestamp() - Driver hook for transmit timestamping
  *
@@ -3329,7 +3322,8 @@ static inline void sw_tx_timestamp(struct sk_buff *skb)
 static inline void skb_tx_timestamp(struct sk_buff *skb)
 {
 	skb_clone_tx_timestamp(skb);
-	sw_tx_timestamp(skb);
+	if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP)
+		skb_tstamp_tx(skb, NULL);
 }
 
 /**
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
index fe7e5bc..33827c4 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -662,6 +662,16 @@ static bool skb_is_err_queue(const struct sk_buff *skb)
 	return skb->pkt_type == PACKET_OUTGOING;
 }
 
+/* On transmit, software and hardware timestamps are returned independently.
+ * As the two skb clones share the hardware timestamp, which may be updated
+ * before the software timestamp is received, a hardware TX timestamp may be
+ * returned only if there is no software TX timestamp.
+ */
+static bool skb_is_swtx_tstamp(const struct sk_buff *skb)
+{
+	return skb->tstamp && skb_is_err_queue(skb);
+}
+
 static void put_ts_pktinfo(struct msghdr *msg, struct sk_buff *skb)
 {
 	struct scm_ts_pktinfo ts_pktinfo;
@@ -724,6 +734,7 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 		empty = 0;
 	if (shhwtstamps &&
 	    (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
+	    !skb_is_swtx_tstamp(skb) &&
 	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
 		empty = 0;
 		if ((sk->sk_tsflags & SOF_TIMESTAMPING_OPT_PKTINFO) &&
-- 
2.9.3
