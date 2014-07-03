From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING ancillary data struct
Date: Thu,  3 Jul 2014 15:39:33 -0400
Message-ID: <1404416380-3545-2-git-send-email-willemb@google.com>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gomail.com, stephen@networkplumber.org,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:36114 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366AbaGCTju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 15:39:50 -0400
Received: by mail-ie0-f202.google.com with SMTP id tr6so138783ieb.3
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 12:39:50 -0700 (PDT)
In-Reply-To: <1404416380-3545-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applications that request kernel transmit timestamps with
SO_TIMESTAMPING read timestamps using recvmsg() ancillary data.
This patch explicitly defines the struct that applications read, and
the semantics of its fields.

The code is backward compatible with legacy applications that treat
the ancillary data as an anonymous array 'struct timespec data[3]'.

Beyond documenting existing use, it adds support for new timestamping
points in the kernel tx datapath. On tx, the scm_timestamping struct
is always accompanied with an error message of type sock_exterr_skb.

This patch defines the previously unused field ee_info in that struct
as an explicit type field, communicating the type of each timestamp
in the three struct timespec in scm_timestamping. This does not change
legacy expectations, but allows returning multiple timestamp types to
the calling process.

This patch does not modify the reception path. On rx, SO_TIMESTAMPING
csmgs are not accompanied by a struct similar to sock_exterr_skb. If
at some point rx timestamp points are added, a similar extension in a
new cmsg can be defined.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h        |  2 ++
 include/uapi/linux/errqueue.h | 19 +++++++++++++++++++
 net/core/skbuff.c             |  1 +
 net/socket.c                  | 33 +++++++++++++++++++--------------
 4 files changed, 41 insertions(+), 14 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ec89301..c74aab5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -260,6 +260,8 @@ enum {
 	SKBTX_SHARED_FRAG = 1 << 5,
 };
 
+#define SKBTX_ANY_TSTAMP	(SKBTX_HW_TSTAMP | SKBTX_SW_TSTAMP)
+
 /*
  * The callback notifies userspace to release buffers when skb DMA is done in
  * lower device, the skb last reference should be 0 when calling this.
diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index aacd4fb..5d93d0b 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -22,5 +22,24 @@ struct sock_extended_err {
 
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
+#define SCM_TSTAMP_SND		0x1	/* driver passed skb to NIC */
+#define SCM_TSTAMP_ACK		0x2	/* transport layer saw ACK */
+#define SCM_TSTAMP_ENQ		0x4	/* stack passed skb to TC layer */
+#define SCM_TSTAMP_RCV		0x8	/* stack received skb */
+#define SCM_TSTAMP_HWSYS	0x10	/* NIC tstamp in system format */
+#define SCM_TSTAMP_HWRAW	0x20	/* NIC tstamp in native format */
+
+#define SCM_TSTAMP_OFF(n, ts)	(ts << (10 * n))
 
 #endif /* _UAPI_LINUX_ERRQUEUE_H */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c1a3303..1bcd05d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3521,6 +3521,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
+	serr->ee.ee_info = hwtstamps ? 0 : SCM_TSTAMP_SND;
 
 	err = sock_queue_err_skb(sk, skb);
 
diff --git a/net/socket.c b/net/socket.c
index abf56b2..a31138d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -106,6 +106,7 @@
 #include <linux/sockios.h>
 #include <linux/atalk.h>
 #include <net/busy_poll.h>
+#include <linux/errqueue.h>
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
 unsigned int sysctl_net_busy_read __read_mostly;
@@ -696,9 +697,10 @@ EXPORT_SYMBOL(kernel_sendmsg);
 void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	struct sk_buff *skb)
 {
+	struct sock_exterr_skb *serr = SKB_EXT_ERR(skb);
 	int need_software_tstamp = sock_flag(sk, SOCK_RCVTSTAMP);
-	struct timespec ts[3];
-	int empty = 1;
+	struct scm_timestamping tss;
+	int tstype = 0, is_tx = skb_shinfo(skb)->tx_flags & SKBTX_ANY_TSTAMP;
 	struct skb_shared_hwtstamps *shhwtstamps =
 		skb_hwtstamps(skb);
 
@@ -714,28 +716,31 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
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
+	memset(&tss, 0, sizeof(tss));
 	if (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) &&
-	    ktime_to_timespec_cond(skb->tstamp, ts + 0))
-		empty = 0;
+	    ktime_to_timespec_cond(skb->tstamp, tss.ts + 0))
+		tstype |= is_tx ? serr->ee.ee_info : SCM_TSTAMP_RCV;
 	if (shhwtstamps) {
 		if (sock_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE) &&
-		    ktime_to_timespec_cond(shhwtstamps->syststamp, ts + 1))
-			empty = 0;
+		    ktime_to_timespec_cond(shhwtstamps->syststamp, tss.ts + 1))
+			tstype |= SCM_TSTAMP_OFF(1, SCM_TSTAMP_HWSYS);
 		if (sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE) &&
-		    ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts + 2))
-			empty = 0;
+		    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2))
+			tstype |= SCM_TSTAMP_OFF(2, SCM_TSTAMP_HWRAW);
 	}
-	if (!empty)
+	if (tstype) {
+		if (is_tx)
+			serr->ee.ee_info = tstype;
 		put_cmsg(msg, SOL_SOCKET,
-			 SCM_TIMESTAMPING, sizeof(ts), &ts);
+			 SCM_TIMESTAMPING, sizeof(tss), &tss);
+	}
 }
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
 
-- 
2.0.0.526.g5318336
