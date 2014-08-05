From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v4 1/6] net-timestamp: extend SCM_TIMESTAMPING ancillary data struct
Date: Mon,  4 Aug 2014 22:11:45 -0400
Message-ID: <1407204710-21778-2-git-send-email-willemb@google.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:49241 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454AbaHECLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 22:11:53 -0400
Received: by mail-yk0-f201.google.com with SMTP id 142so43789ykq.4
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 19:11:53 -0700 (PDT)
In-Reply-To: <1407204710-21778-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applications that request kernel tx timestamps with SO_TIMESTAMPING
read timestamps as recvmsg() ancillary data. The response is defined
implicitly as timespec[3].

1) define struct scm_timestamping explicitly and

2) add support for new tstamp types. On tx, scm_timestamping always
   accompanies a sock_extended_err. Define previously unused field
   ee_info to signal the type of ts[0]. Introduce SCM_TSTAMP_SND to
   define the existing behavior.

The reception path is not modified. On rx, no struct similar to
sock_extended_err is passed along with SCM_TIMESTAMPING.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h        |  3 +++
 include/net/sock.h            |  4 +++-
 include/uapi/linux/errqueue.h | 18 ++++++++++++++++++
 net/core/skbuff.c             |  1 +
 net/socket.c                  | 20 +++++++++++---------
 5 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 281dece..477f0f6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -249,6 +249,9 @@ enum {
 	SKBTX_SHARED_FRAG = 1 << 5,
 };
 
+#define SKBTX_ANY_SW_TSTAMP	SKBTX_SW_TSTAMP
+#define SKBTX_ANY_TSTAMP	(SKBTX_HW_TSTAMP | SKBTX_ANY_SW_TSTAMP)
+
 /*
  * The callback notifies userspace to release buffers when skb DMA is done in
  * lower device, the skb last reference should be 0 when calling this.
diff --git a/include/net/sock.h b/include/net/sock.h
index b91c886..02f5b35 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2169,7 +2169,9 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 	 */
 	if (sock_flag(sk, SOCK_RCVTSTAMP) ||
 	    sock_flag(sk, SOCK_TIMESTAMPING_RX_SOFTWARE) ||
-	    (kt.tv64 && sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE)) ||
+	    (kt.tv64 &&
+	     (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
+	      skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP)) ||
 	    (hwtstamps->hwtstamp.tv64 &&
 	     sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE)))
 		__sock_recv_timestamp(msg, sk, skb);
diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index aacd4fb..accee72 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -22,5 +22,23 @@ struct sock_extended_err {
 
 #define SO_EE_OFFENDER(ee)	((struct sockaddr*)((ee)+1))
 
+/**
+ *	struct scm_timestamping - timestamps exposed through cmsg
+ *
+ *	The timestamping interfaces SO_TIMESTAMPING, MSG_TSTAMP_*
+ *	communicate network timestamps by passing this struct in a cmsg with
+ *	recvmsg(). See Documentation/networking/timestamping.txt for details.
+ */
+struct scm_timestamping {
+	struct timespec ts[3];
+};
+
+/* The type of scm_timestamping, passed in sock_extended_err ee_info.
+ * This defines the type of ts[0]. For SCM_TSTAMP_SND only, if ts[0]
+ * is zero, then this is a hardware timestamp and recorded in ts[2].
+ */
+enum {
+	SCM_TSTAMP_SND,		/* driver passed skb to NIC, or HW */
+};
 
 #endif /* _UAPI_LINUX_ERRQUEUE_H */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c1a3303..c9f6880 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3521,6 +3521,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
+	serr->ee.ee_info = SCM_TSTAMP_SND;
 
 	err = sock_queue_err_skb(sk, skb);
 
diff --git a/net/socket.c b/net/socket.c
index d8222c0..dc0cc5d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -106,6 +106,7 @@
 #include <linux/sockios.h>
 #include <linux/atalk.h>
 #include <net/busy_poll.h>
+#include <linux/errqueue.h>
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
 unsigned int sysctl_net_busy_read __read_mostly;
@@ -697,7 +698,7 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	struct sk_buff *skb)
 {
 	int need_software_tstamp = sock_flag(sk, SOCK_RCVTSTAMP);
-	struct timespec ts[3];
+	struct scm_timestamping tss;
 	int empty = 1;
 	struct skb_shared_hwtstamps *shhwtstamps =
 		skb_hwtstamps(skb);
@@ -714,24 +715,25 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMP,
 				 sizeof(tv), &tv);
 		} else {
-			skb_get_timestampns(skb, &ts[0]);
+			struct timespec ts;
+			skb_get_timestampns(skb, &ts);
 			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPNS,
-				 sizeof(ts[0]), &ts[0]);
+				 sizeof(ts), &ts);
 		}
 	}
 
-
-	memset(ts, 0, sizeof(ts));
-	if (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) &&
-	    ktime_to_timespec_cond(skb->tstamp, ts + 0))
+	memset(&tss, 0, sizeof(tss));
+	if ((sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
+	     skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP) &&
+	    ktime_to_timespec_cond(skb->tstamp, tss.ts + 0))
 		empty = 0;
 	if (shhwtstamps &&
 	    sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE) &&
-	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts + 2))
+	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2))
 		empty = 0;
 	if (!empty)
 		put_cmsg(msg, SOL_SOCKET,
-			 SCM_TIMESTAMPING, sizeof(ts), &ts);
+			 SCM_TIMESTAMPING, sizeof(tss), &tss);
 }
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
 
-- 
2.0.0.526.g5318336
