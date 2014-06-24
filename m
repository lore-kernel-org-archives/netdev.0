From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 1/7] net-timestamp: explicit SO_TIMESTAMPING ancillary data struct
Date: Tue, 24 Jun 2014 11:43:46 -0400
Message-ID: <1403624632-17327-2-git-send-email-willemb@google.com>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
Cc: eric.dumazet@gmail.com, richardcochran@gmail.com,
	davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f73.google.com ([209.85.213.73]:65196 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471AbaFXPoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 11:44:00 -0400
Received: by mail-yh0-f73.google.com with SMTP id f10so42017yha.0
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 08:43:59 -0700 (PDT)
In-Reply-To: <1403624632-17327-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applications that request kernel transmit timestamps with
SO_TIMESTAMPING read timestamps using recvmsg() ancillary data.
The existing timestamp types (hardware raw, hardware sys, software)
are not explicitly documented. Instead, an array of anonymous
timespecs is passed. With upcoming additional types, this becomes
fragile.

This patch replaces the array with a struct with explicit fields for
each timestamp type. It also extends it with two new fields for
upcoming features:
  @ts_type: the location in the kernel where the tstamp was taken
  @ts_key:  the location in the flow that a tstamp corresponds to

The code is backward compatible with legacy applications that treat
the ancillary data as an anonymous array 'struct timespec data[3]'.
It will break applications that test the size of the cmsg data.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/uapi/linux/errqueue.h | 32 ++++++++++++++++++++++++++++++++
 net/compat.c                  | 38 +++++++++++++++++++++++++++-----------
 net/socket.c                  | 24 +++++++++++++++---------
 3 files changed, 74 insertions(+), 20 deletions(-)

diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index aacd4fb..d80b866 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -22,5 +22,37 @@ struct sock_extended_err {
 
 #define SO_EE_OFFENDER(ee)	((struct sockaddr*)((ee)+1))
 
+/**
+ *	struct sock_errqueue_timestamping - timestamps exposed through cmsg
+ *
+ *	The timestamping interfaces SO_TIMESTAMPING, MSG_TSTAMP_*
+ *	communicate network timestamps to userspace by passing this struct
+ *	through a cmsg in recvmsg().
+ *
+ *	@ts_sw:     the sw timestamp: the contents depends on ts_type.
+ *	@ts_hw_sys: a hardware generated timestamp converted to system time.
+ *	@ts_hw_raw: a hardware generated timestamp converted in its raw format.
+ *	@ts_type:   the type of timestamp ts_sw. One of SCM_TSTAMP_*
+ *	@ts_key:    socket flow index that the timestamps correspond to
+ *		    (stream transport protocols only, e.g., TCP seqno)
+ *
+ *	The first three fields are dictated by historical use. The hardware
+ *	timestamps are empty unless hardware timestamping is enabled, but
+ *	they have to be present in each message.
+ */
+struct sock_errqueue_timestamping {
+	struct timespec ts_sw;
+	struct timespec ts_hw_sys;
+	struct timespec ts_hw_raw;
+	__u32 ts_key;
+	__u16 ts_type;
+	__u16 ts_padding;
+};
+
+enum {
+	SCM_TSTAMP_SND = 1,
+	SCM_TSTAMP_ACK = 2,
+	SCM_TSTAMP_ENQ = 3
+};
 
 #endif /* _UAPI_LINUX_ERRQUEUE_H */
diff --git a/net/compat.c b/net/compat.c
index 9a76eaf..fff6d76 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -23,6 +23,7 @@
 #include <linux/compat.h>
 #include <linux/security.h>
 #include <linux/export.h>
+#include <linux/errqueue.h>
 
 #include <net/scm.h>
 #include <net/sock.h>
@@ -225,7 +226,15 @@ int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *dat
 	struct compat_cmsghdr __user *cm = (struct compat_cmsghdr __user *) kmsg->msg_control;
 	struct compat_cmsghdr cmhdr;
 	struct compat_timeval ctv;
-	struct compat_timespec cts[3];
+	struct compat_timespec cts;
+	struct compat_errqueue_timestamping {
+		struct compat_timespec ts_sw;
+		struct compat_timespec ts_hw_sys;
+		struct compat_timespec ts_hw_raw;
+		__u32 ts_key;
+		__u16 ts_type;
+		__u16 ts_padding;
+	} ctss;
 	int cmlen;
 
 	if (cm == NULL || kmsg->msg_controllen < sizeof(*cm)) {
@@ -240,18 +249,25 @@ int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *dat
 			ctv.tv_usec = tv->tv_usec;
 			data = &ctv;
 			len = sizeof(ctv);
-		}
-		if (level == SOL_SOCKET &&
-		    (type == SCM_TIMESTAMPNS || type == SCM_TIMESTAMPING)) {
-			int count = type == SCM_TIMESTAMPNS ? 1 : 3;
-			int i;
+		} else if (level == SOL_SOCKET && type == SCM_TIMESTAMPNS) {
 			struct timespec *ts = (struct timespec *)data;
-			for (i = 0; i < count; i++) {
-				cts[i].tv_sec = ts[i].tv_sec;
-				cts[i].tv_nsec = ts[i].tv_nsec;
-			}
+			cts.tv_sec = ts->tv_sec;
+			cts.tv_nsec = ts->tv_nsec;
 			data = &cts;
-			len = sizeof(cts[0]) * count;
+			len = sizeof(cts);
+		} else if (level == SOL_SOCKET && type == SCM_TIMESTAMPING) {
+			struct sock_errqueue_timestamping *tss = data;
+			ctss.ts_sw.tv_sec = tss->ts_sw.tv_sec;
+			ctss.ts_sw.tv_nsec = tss->ts_sw.tv_nsec;
+			ctss.ts_hw_sys.tv_sec = tss->ts_hw_sys.tv_sec;
+			ctss.ts_hw_sys.tv_nsec = tss->ts_hw_sys.tv_nsec;
+			ctss.ts_hw_raw.tv_sec = tss->ts_hw_raw.tv_sec;
+			ctss.ts_hw_raw.tv_nsec = tss->ts_hw_raw.tv_nsec;
+			ctss.ts_type = tss->ts_type;
+			ctss.ts_key = tss->ts_key;
+			ctss.ts_padding = 0;
+			data = &ctss;
+			len = sizeof(ctss);
 		}
 	}
 
diff --git a/net/socket.c b/net/socket.c
index abf56b2..c001746 100644
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
+	struct sock_errqueue_timestamping tss;
 	int empty = 1;
 	struct skb_shared_hwtstamps *shhwtstamps =
 		skb_hwtstamps(skb);
@@ -714,28 +715,33 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
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
+	    ktime_to_timespec_cond(skb->tstamp, &tss.ts_sw)) {
 		empty = 0;
+		tss.ts_type = SCM_TSTAMP_SND;
+	}
 	if (shhwtstamps) {
 		if (sock_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE) &&
-		    ktime_to_timespec_cond(shhwtstamps->syststamp, ts + 1))
+		    ktime_to_timespec_cond(shhwtstamps->syststamp,
+					   &tss.ts_hw_sys))
 			empty = 0;
 		if (sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE) &&
-		    ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts + 2))
+		    ktime_to_timespec_cond(shhwtstamps->hwtstamp,
+					   &tss.ts_hw_raw))
 			empty = 0;
 	}
+
 	if (!empty)
 		put_cmsg(msg, SOL_SOCKET,
-			 SCM_TIMESTAMPING, sizeof(ts), &ts);
+			 SCM_TIMESTAMPING, sizeof(tss), &tss);
 }
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
 
-- 
2.0.0.526.g5318336
