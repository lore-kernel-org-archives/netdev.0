From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v3 1/5] net-timestamp: extend SCM_TIMESTAMPING ancillary data struct
Date: Mon, 21 Jul 2014 15:35:53 -0400
Message-ID: <1405971357-22830-2-git-send-email-willemb@google.com>
References: <1405971357-22830-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:49194 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755291AbaGUTgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 15:36:00 -0400
Received: by mail-pa0-f74.google.com with SMTP id lj1so1937208pab.5
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 12:35:59 -0700 (PDT)
In-Reply-To: <1405971357-22830-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applications that request kernel tx timestamps with SO_TIMESTAMPING
read timestamps as recvmsg() ancillary data. The response is defined
implicitly as timespec[3]. Define the struct, and

1) Add support for new tstamp types. On tx, scm_timestamping always
accompanies a sock_extended_err. Define previously unused field
ee_info to signal the type of ts[0]. Introduce SCM_TSTAMP_SND.

2) Add support to discern timestamps. When multiple timestamped
packets are in flight concurrently, correlating a timestamp with
the right send() call is non-trivial. Define previously unused field
ee_data to communicate a send() specific key, skb->mark. It is
up to the application to optionally set this field to a unique
value for each send call.

The reception path is not modified. On rx, no struct similar to
sock_extended_err is passed along with SCM_TIMESTAMPING.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h        |  3 +++
 include/net/sock.h            |  3 ++-
 include/uapi/linux/errqueue.h | 15 +++++++++++++++
 net/core/skbuff.c             |  2 ++
 net/socket.c                  | 22 ++++++++++++----------
 5 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3694303..e71224a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -262,6 +262,9 @@ enum {
 	SKBTX_SHARED_FRAG = 1 << 5,
 };
 
+#define SKBTX_ANY_SW_TSTAMP	SKBTX_SW_TSTAMP
+#define SKBTX_ANY_TSTAMP	(SKBTX_HW_TSTAMP | SKBTX_ANY_SW_TSTAMP)
+
 /*
  * The callback notifies userspace to release buffers when skb DMA is done in
  * lower device, the skb last reference should be 0 when calling this.
diff --git a/include/net/sock.h b/include/net/sock.h
index 28f7346..00abc4c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2172,7 +2172,8 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 	 */
 	if (sock_flag(sk, SOCK_RCVTSTAMP) ||
 	    sock_flag(sk, SOCK_TIMESTAMPING_RX_SOFTWARE) ||
-	    (kt.tv64 && sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE)) ||
+	    (kt.tv64 && (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
+	     skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP)) ||
 	    (hwtstamps->hwtstamp.tv64 &&
 	     sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE)) ||
 	    (hwtstamps->syststamp.tv64 &&
diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index aacd4fb..97e1872 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -22,5 +22,20 @@ struct sock_extended_err {
 
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
+/* type of ts[0], passed in ee_info */
+enum {
+	SCM_TSTAMP_SND = 1,	/* driver passed skb to NIC */
+};
 
 #endif /* _UAPI_LINUX_ERRQUEUE_H */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c1a3303..d95b09d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3521,6 +3521,8 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
+	serr->ee.ee_info = hwtstamps ? 0 : SCM_TSTAMP_SND;
+	serr->ee.ee_data = skb->mark;
 
 	err = sock_queue_err_skb(sk, skb);
 
diff --git a/net/socket.c b/net/socket.c
index abf56b2..7fc2eef 100644
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
@@ -714,28 +715,29 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
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
 	if (shhwtstamps) {
 		if (sock_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE) &&
-		    ktime_to_timespec_cond(shhwtstamps->syststamp, ts + 1))
+		    ktime_to_timespec_cond(shhwtstamps->syststamp, tss.ts + 1))
 			empty = 0;
 		if (sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE) &&
-		    ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts + 2))
+		    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2))
 			empty = 0;
 	}
 	if (!empty)
 		put_cmsg(msg, SOL_SOCKET,
-			 SCM_TIMESTAMPING, sizeof(ts), &ts);
+			 SCM_TIMESTAMPING, sizeof(tss), &tss);
 }
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
 
-- 
2.0.0.526.g5318336
