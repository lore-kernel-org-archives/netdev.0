From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [RFC PATCH 04/11] net: socket infrastructure for SO_TIMESTAMPING
Date: Wed, 19 Nov 2008 13:08:41 +0100
Message-ID: <1227096528-24150-5-git-send-email-patrick.ohly@intel.com>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
 <1227096528-24150-2-git-send-email-patrick.ohly@intel.com>
 <1227096528-24150-3-git-send-email-patrick.ohly@intel.com>
 <1227096528-24150-4-git-send-email-patrick.ohly@intel.com>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick Ohly <patrick.ohly@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53505 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752656AbYKSMJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 07:09:01 -0500
In-Reply-To: <1227096528-24150-4-git-send-email-patrick.ohly@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The overlap with the old SO_TIMESTAMP[NS] options is handled so
that time stamping in software (net_enable_timestamp()) is
enabled when SO_TIMESTAMP[NS] and/or SO_TIMESTAMPING_RX_SOFTWARE
is set.  It's disabled if all of these are off.
---
 include/net/sock.h |   37 ++++++++++++++++++++++--
 net/compat.c       |   19 ++++++++----
 net/core/sock.c    |   79 ++++++++++++++++++++++++++++++++++++++++++++--------
 net/socket.c       |   75 ++++++++++++++++++++++++++++++++++++-------------
 4 files changed, 168 insertions(+), 42 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 0a63894..0f71951 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -158,7 +158,7 @@ struct sock_common {
   *	@sk_allocation: allocation mode
   *	@sk_sndbuf: size of send buffer in bytes
   *	@sk_flags: %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE,
-  *		   %SO_OOBINLINE settings
+  *		   %SO_OOBINLINE settings, %SO_TIMESTAMPING settings
   *	@sk_no_check: %SO_NO_CHECK setting, wether or not checkup packets
   *	@sk_route_caps: route capabilities (e.g. %NETIF_F_TSO)
   *	@sk_gso_type: GSO type (e.g. %SKB_GSO_TCPV4)
@@ -488,6 +488,13 @@ enum sock_flags {
 	SOCK_RCVTSTAMPNS, /* %SO_TIMESTAMPNS setting */
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
+	SOCK_TIMESTAMPING_TX_HARDWARE, /* %SO_TIMESTAMPING %SOF_TIMESTAMPING_TX_HARDWARE */
+	SOCK_TIMESTAMPING_TX_SOFTWARE, /* %SO_TIMESTAMPING %SOF_TIMESTAMPING_TX_SOFTWARE */
+	SOCK_TIMESTAMPING_RX_HARDWARE, /* %SO_TIMESTAMPING %SOF_TIMESTAMPING_RX_HARDWARE */
+	SOCK_TIMESTAMPING_RX_SOFTWARE, /* %SO_TIMESTAMPING %SOF_TIMESTAMPING_RX_SOFTWARE */
+	SOCK_TIMESTAMPING_SOFTWARE,    /* %SO_TIMESTAMPING %SOF_TIMESTAMPING_SOFTWARE */
+	SOCK_TIMESTAMPING_RAW_HARDWARE, /* %SO_TIMESTAMPING %SOF_TIMESTAMPING_RAW_HARDWARE */
+	SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SO_TIMESTAMPING %SOF_TIMESTAMPING_SYS_HARDWARE */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
@@ -1342,13 +1349,37 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 {
 	ktime_t kt = skb->tstamp;
 
-	if (sock_flag(sk, SOCK_RCVTSTAMP))
+	/*
+	 * generate control messages if receive time stamping requested
+	 * or if time stamp available (RX hardware or TX software/hardware
+	 * case) and reporting via SO_TIMESTAMPING enabled
+	 */
+	if ((sock_flag(sk, SOCK_RCVTSTAMP) ||
+		sock_flag(sk, SOCK_TIMESTAMPING_RX_SOFTWARE)) ||
+		(kt.tv64 && sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE)) ||
+		(skb_hwtstamp_available(skb) &&
+			(sock_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE) ||
+				sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE))))
 		__sock_recv_timestamp(msg, sk, skb);
 	else
 		sk->sk_stamp = kt;
 }
 
 /**
+ * sock_tx_timestamp - checks whether the outgoing packet is to be time stamped
+ * @msg: outgoing packet
+ * @sk: socket sending this packet
+ * @stamp_tx: filled with instructions for time stamping
+ *
+ * Currently only depends on SOCK_TIMESTAMPING* flags. Returns error code if
+ * parameters are invalid.
+ */
+extern int sock_tx_timestamp(struct msghdr *msg,
+			struct sock *sk,
+			union sk_buff_hwtstamp *stamp_tx);
+
+
+/**
  * sk_eat_skb - Release a skb if it is no longer needed
  * @sk: socket to eat this skb from
  * @skb: socket buffer to eat
@@ -1416,7 +1447,7 @@ static inline struct sock *skb_steal_sock(struct sk_buff *skb)
 	return NULL;
 }
 
-extern void sock_enable_timestamp(struct sock *sk);
+extern void sock_enable_timestamp(struct sock *sk, int flag);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);
 extern int sock_get_timestampns(struct sock *, struct timespec __user *);
 
diff --git a/net/compat.c b/net/compat.c
index 6ce1a1c..954377e 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -216,7 +216,7 @@ Efault:
 int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *data)
 {
 	struct compat_timeval ctv;
-	struct compat_timespec cts;
+	struct compat_timespec cts[3];
 	struct compat_cmsghdr __user *cm = (struct compat_cmsghdr __user *) kmsg->msg_control;
 	struct compat_cmsghdr cmhdr;
 	int cmlen;
@@ -233,12 +233,17 @@ int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *dat
 		data = &ctv;
 		len = sizeof(ctv);
 	}
-	if (level == SOL_SOCKET && type == SCM_TIMESTAMPNS) {
+	if (level == SOL_SOCKET &&
+		(type == SCM_TIMESTAMPNS || type == SCM_TIMESTAMPING)) {
+		int count = type == SCM_TIMESTAMPNS ? 1 : 3;
+		int i;
 		struct timespec *ts = (struct timespec *)data;
-		cts.tv_sec = ts->tv_sec;
-		cts.tv_nsec = ts->tv_nsec;
+		for (i = 0; i < count; i++) {
+			cts[i].tv_sec = ts[i].tv_sec;
+			cts[i].tv_nsec = ts[i].tv_nsec;
+		}
 		data = &cts;
-		len = sizeof(cts);
+		len = sizeof(cts[0]) * count;
 	}
 
 	cmlen = CMSG_COMPAT_LEN(len);
@@ -455,7 +460,7 @@ int compat_sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
 	struct timeval tv;
 
 	if (!sock_flag(sk, SOCK_TIMESTAMP))
-		sock_enable_timestamp(sk);
+		sock_enable_timestamp(sk, SOCK_TIMESTAMP);
 	tv = ktime_to_timeval(sk->sk_stamp);
 	if (tv.tv_sec == -1)
 		return err;
@@ -479,7 +484,7 @@ int compat_sock_get_timestampns(struct sock *sk, struct timespec __user *usersta
 	struct timespec ts;
 
 	if (!sock_flag(sk, SOCK_TIMESTAMP))
-		sock_enable_timestamp(sk);
+		sock_enable_timestamp(sk, SOCK_TIMESTAMP);
 	ts = ktime_to_timespec(sk->sk_stamp);
 	if (ts.tv_sec == -1)
 		return err;
diff --git a/net/core/sock.c b/net/core/sock.c
index 38de9c3..1a4895a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -120,6 +120,7 @@
 #include <net/net_namespace.h>
 #include <net/request_sock.h>
 #include <net/sock.h>
+#include <net/timestamping.h>
 #include <net/xfrm.h>
 #include <linux/ipsec.h>
 
@@ -257,11 +258,14 @@ static void sock_warn_obsolete_bsdism(const char *name)
 	}
 }
 
-static void sock_disable_timestamp(struct sock *sk)
+static void sock_disable_timestamp(struct sock *sk, int flag)
 {
-	if (sock_flag(sk, SOCK_TIMESTAMP)) {
-		sock_reset_flag(sk, SOCK_TIMESTAMP);
-		net_disable_timestamp();
+	if (sock_flag(sk, flag)) {
+		sock_reset_flag(sk, flag);
+		if (!sock_flag(sk, SOCK_TIMESTAMP) &&
+			!sock_flag(sk, SOCK_TIMESTAMPING_RX_SOFTWARE)) {
+			net_disable_timestamp();
+		}
 	}
 }
 
@@ -616,13 +620,36 @@ set_rcvbuf:
 			else
 				sock_set_flag(sk, SOCK_RCVTSTAMPNS);
 			sock_set_flag(sk, SOCK_RCVTSTAMP);
-			sock_enable_timestamp(sk);
+			sock_enable_timestamp(sk, SOCK_TIMESTAMP);
 		} else {
 			sock_reset_flag(sk, SOCK_RCVTSTAMP);
 			sock_reset_flag(sk, SOCK_RCVTSTAMPNS);
 		}
 		break;
 
+	case SO_TIMESTAMPING:
+		if (val & ~SOF_TIMESTAMPING_MASK) {
+			ret = EINVAL;
+			break;
+		}
+		sock_valbool_flag(sk, SOCK_TIMESTAMPING_TX_HARDWARE,
+				val & SOF_TIMESTAMPING_TX_HARDWARE);
+		sock_valbool_flag(sk, SOCK_TIMESTAMPING_TX_SOFTWARE,
+				val & SOF_TIMESTAMPING_TX_SOFTWARE);
+		sock_valbool_flag(sk, SOCK_TIMESTAMPING_RX_HARDWARE,
+				val & SOF_TIMESTAMPING_RX_HARDWARE);
+		if (val & SOF_TIMESTAMPING_RX_SOFTWARE)
+			sock_enable_timestamp(sk, SOCK_TIMESTAMPING_RX_SOFTWARE);
+		else
+			sock_disable_timestamp(sk, SOCK_TIMESTAMPING_RX_SOFTWARE);
+		sock_valbool_flag(sk, SOCK_TIMESTAMPING_SOFTWARE,
+				val & SOF_TIMESTAMPING_SOFTWARE);
+		sock_valbool_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE,
+				val & SOF_TIMESTAMPING_SYS_HARDWARE);
+		sock_valbool_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE,
+				val & SOF_TIMESTAMPING_RAW_HARDWARE);
+		break;
+
 	case SO_RCVLOWAT:
 		if (val < 0)
 			val = INT_MAX;
@@ -768,6 +795,24 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sock_flag(sk, SOCK_RCVTSTAMPNS);
 		break;
 
+	case SO_TIMESTAMPING:
+		v.val = 0;
+		if (sock_flag(sk, SOCK_TIMESTAMPING_TX_HARDWARE))
+			v.val |= SOF_TIMESTAMPING_TX_HARDWARE;
+		if (sock_flag(sk, SOCK_TIMESTAMPING_TX_SOFTWARE))
+			v.val |= SOF_TIMESTAMPING_TX_SOFTWARE;
+		if (sock_flag(sk, SOCK_TIMESTAMPING_RX_HARDWARE))
+			v.val |= SOF_TIMESTAMPING_RX_HARDWARE;
+		if (sock_flag(sk, SOCK_TIMESTAMPING_RX_SOFTWARE))
+			v.val |= SOF_TIMESTAMPING_RX_SOFTWARE;
+		if (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE))
+			v.val |= SOF_TIMESTAMPING_SOFTWARE;
+		if (sock_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE))
+			v.val |= SOF_TIMESTAMPING_SYS_HARDWARE;
+		if (sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE))
+			v.val |= SOF_TIMESTAMPING_RAW_HARDWARE;
+		break;
+
 	case SO_RCVTIMEO:
 		lv=sizeof(struct timeval);
 		if (sk->sk_rcvtimeo == MAX_SCHEDULE_TIMEOUT) {
@@ -969,7 +1014,8 @@ void sk_free(struct sock *sk)
 		rcu_assign_pointer(sk->sk_filter, NULL);
 	}
 
-	sock_disable_timestamp(sk);
+	sock_disable_timestamp(sk, SOCK_TIMESTAMP);
+	sock_disable_timestamp(sk, SOCK_TIMESTAMPING_RX_SOFTWARE);
 
 	if (atomic_read(&sk->sk_omem_alloc))
 		printk(KERN_DEBUG "%s: optmem leakage (%d bytes) detected.\n",
@@ -1783,7 +1829,7 @@ int sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
 {
 	struct timeval tv;
 	if (!sock_flag(sk, SOCK_TIMESTAMP))
-		sock_enable_timestamp(sk);
+		sock_enable_timestamp(sk, SOCK_TIMESTAMP);
 	tv = ktime_to_timeval(sk->sk_stamp);
 	if (tv.tv_sec == -1)
 		return -ENOENT;
@@ -1799,7 +1845,7 @@ int sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
 {
 	struct timespec ts;
 	if (!sock_flag(sk, SOCK_TIMESTAMP))
-		sock_enable_timestamp(sk);
+		sock_enable_timestamp(sk, SOCK_TIMESTAMP);
 	ts = ktime_to_timespec(sk->sk_stamp);
 	if (ts.tv_sec == -1)
 		return -ENOENT;
@@ -1811,11 +1857,20 @@ int sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
 }
 EXPORT_SYMBOL(sock_get_timestampns);
 
-void sock_enable_timestamp(struct sock *sk)
+void sock_enable_timestamp(struct sock *sk, int flag)
 {
-	if (!sock_flag(sk, SOCK_TIMESTAMP)) {
-		sock_set_flag(sk, SOCK_TIMESTAMP);
-		net_enable_timestamp();
+	if (!sock_flag(sk, flag)) {
+		sock_set_flag(sk, flag);
+		/*
+		 * we just set one of the two flags which require net
+		 * time stamping, but time stamping might have been on
+		 * already because of the other one
+		 */
+		if (!sock_flag(sk,
+				flag == SOCK_TIMESTAMP ?
+				SOCK_TIMESTAMPING_RX_SOFTWARE :
+				SOCK_TIMESTAMP))
+			net_enable_timestamp();
 	}
 }
 
diff --git a/net/socket.c b/net/socket.c
index d7128b7..1ad00e1 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -545,6 +545,18 @@ void sock_release(struct socket *sock)
 	sock->file = NULL;
 }
 
+int sock_tx_timestamp(struct msghdr *msg, struct sock *sk,
+		union sk_buff_hwtstamp *tstamp_tx)
+{
+	tstamp_tx->hwtstamp.tv64 = 0;
+	tstamp_tx->tstamp_tx_hardware =
+		sock_flag(sk, SOCK_TIMESTAMPING_TX_HARDWARE);
+	tstamp_tx->tstamp_tx_software =
+		sock_flag(sk, SOCK_TIMESTAMPING_TX_SOFTWARE);
+	return 0;
+}
+EXPORT_SYMBOL(sock_tx_timestamp);
+
 static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 				 struct msghdr *msg, size_t size)
 {
@@ -601,26 +613,49 @@ int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	struct sk_buff *skb)
 {
-	ktime_t kt = skb->tstamp;
-
-	if (!sock_flag(sk, SOCK_RCVTSTAMPNS)) {
-		struct timeval tv;
-		/* Race occurred between timestamp enabling and packet
-		   receiving.  Fill in the current time for now. */
-		if (kt.tv64 == 0)
-			kt = ktime_get_real();
-		skb->tstamp = kt;
-		tv = ktime_to_timeval(kt);
-		put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMP, sizeof(tv), &tv);
-	} else {
-		struct timespec ts;
-		/* Race occurred between timestamp enabling and packet
-		   receiving.  Fill in the current time for now. */
-		if (kt.tv64 == 0)
-			kt = ktime_get_real();
-		skb->tstamp = kt;
-		ts = ktime_to_timespec(kt);
-		put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPNS, sizeof(ts), &ts);
+	int need_software_tstamp = sock_flag(sk, SOCK_RCVTSTAMP);
+
+	/* Race occurred between timestamp enabling and packet
+	   receiving.  Fill in the current time for now. */
+	if (need_software_tstamp && skb->tstamp.tv64 == 0)
+		__net_timestamp(skb);
+
+	if (need_software_tstamp) {
+		if (!sock_flag(sk, SOCK_RCVTSTAMPNS)) {
+			struct timeval tv;
+			skb_get_timestamp(skb, &tv);
+			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMP,
+				sizeof(tv), &tv);
+		} else {
+			struct timespec ts;
+			skb_get_timestampns(skb, &ts);
+			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPNS,
+				sizeof(ts), &ts);
+		}
+	}
+
+	if (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
+		sock_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE) ||
+		sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE)) {
+		struct timespec ts[3];
+		int empty = 1;
+		memset(ts, 0, sizeof(ts));
+		if (skb->tstamp.tv64 &&
+			sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE)) {
+			skb_get_timestampns(skb, ts + 0);
+			empty = 0;
+		}
+		if (skb_hwtstamp_available(skb)) {
+			if (sock_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE) &&
+				skb_hwtstamp_transformed(skb, ts + 1))
+				empty = 0;
+			if (sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE) &&
+				skb_hwtstamp_raw(skb, ts + 2))
+				empty = 0;
+		}
+		if (!empty)
+			put_cmsg(msg, SOL_SOCKET,
+				SCM_TIMESTAMPING, sizeof(ts), &ts);
 	}
 }
 
-- 
1.6.0.4

