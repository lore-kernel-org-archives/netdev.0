From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH v4 net-next 6/7] net: allow simultaneous SW and HW transmit timestamping
Date: Thu, 18 May 2017 15:06:55 +0200
Message-ID: <20170518130656.24163-7-mlichvar@redhat.com>
References: <20170518130656.24163-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32948 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756145AbdERNHG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 09:07:06 -0400
In-Reply-To: <20170518130656.24163-1-mlichvar@redhat.com>
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
 Documentation/networking/timestamping.txt |  8 ++++++++
 include/linux/skbuff.h                    | 10 ++--------
 include/uapi/linux/net_tstamp.h           |  3 ++-
 net/core/skbuff.c                         |  4 ++++
 net/socket.c                              | 23 +++++++++++++++++++++--
 5 files changed, 37 insertions(+), 11 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index 74b7c61..65be2d9 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -202,6 +202,14 @@ SOF_TIMESTAMPING_OPT_PKTINFO:
   interface index will be returned only if CONFIG_NET_RX_BUSY_POLL is
   enabled and the driver is using NAPI.
 
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
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 1f8028c..3b2e284 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3254,13 +3254,6 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
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
@@ -3276,7 +3269,8 @@ static inline void sw_tx_timestamp(struct sk_buff *skb)
 static inline void skb_tx_timestamp(struct sk_buff *skb)
 {
 	skb_clone_tx_timestamp(skb);
-	sw_tx_timestamp(skb);
+	if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP)
+		skb_tstamp_tx(skb, NULL);
 }
 
 /**
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index dee74d3..3d421d9 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -28,8 +28,9 @@ enum {
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
index 346d3e8..68c02df 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3875,6 +3875,10 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
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
index ee1f4ec..64705ae 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -662,6 +662,22 @@ static bool skb_is_err_queue(const struct sk_buff *skb)
 	return skb->pkt_type == PACKET_OUTGOING;
 }
 
+/* On transmit, software and hardware timestamps are returned independently.
+ * As the two skb clones share the hardware timestamp, which may be updated
+ * before the software timestamp is received, a hardware TX timestamp may be
+ * returned only if there is no software TX timestamp. A false software
+ * timestamp made for SOCK_RCVTSTAMP when a real timestamp is missing must
+ * be ignored.
+ */
+static bool skb_is_swtx_tstamp(const struct sk_buff *skb,
+			       const struct sock *sk, int false_tstamp)
+{
+	if (false_tstamp && sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TX_SWHW)
+		return 0;
+
+	return skb->tstamp && skb_is_err_queue(skb);
+}
+
 static void put_ts_pktinfo(struct msghdr *msg, struct sk_buff *skb)
 {
 	struct scm_ts_pktinfo ts_pktinfo;
@@ -691,14 +707,16 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 {
 	int need_software_tstamp = sock_flag(sk, SOCK_RCVTSTAMP);
 	struct scm_timestamping tss;
-	int empty = 1;
+	int empty = 1, false_tstamp = 0;
 	struct skb_shared_hwtstamps *shhwtstamps =
 		skb_hwtstamps(skb);
 
 	/* Race occurred between timestamp enabling and packet
 	   receiving.  Fill in the current time for now. */
-	if (need_software_tstamp && skb->tstamp == 0)
+	if (need_software_tstamp && skb->tstamp == 0) {
 		__net_timestamp(skb);
+		false_tstamp = 1;
+	}
 
 	if (need_software_tstamp) {
 		if (!sock_flag(sk, SOCK_RCVTSTAMPNS)) {
@@ -720,6 +738,7 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 		empty = 0;
 	if (shhwtstamps &&
 	    (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
+	    !skb_is_swtx_tstamp(skb, sk, false_tstamp) &&
 	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
 		empty = 0;
 		if ((sk->sk_tsflags & SOF_TIMESTAMPING_OPT_PKTINFO) &&
-- 
2.9.3
