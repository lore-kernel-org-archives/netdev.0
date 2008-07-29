From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC][PATCH 1/2] net: support for TX timestamps
Date: Tue, 29 Jul 2008 03:35:52 +0300
Message-ID: <1217291753-5322-2-git-send-email-opurdila@ixiacom.com>
References: <1217291753-5322-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:25529 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752630AbYG2Ai2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 20:38:28 -0400
In-Reply-To: <1217291753-5322-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We make use of the first 16 MSB bits of the skb->tstamp to send
timestamping commands to low layers of the networking stack or network
device drivers.

When a TX timestamp operation is requested, the TX skb will be cloned
and the clone will be timestamped and added to the socket error queue
of the skb, if the skb has a socket associated.

The actual timestamp will reach userspace as a RX timestamp on the
cloned packet. If timestamping is requested and no timestamping is
done in the device driver (potentially this may use hardware
timestamping), it will be done in software after the device's
start_hard_xmit routine.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/asm-powerpc/socket.h |    3 +++
 include/linux/skbuff.h       |    3 +++
 include/net/sock.h           |    9 +++++++++
 include/net/tstamps.h        |   11 +++++++++++
 net/core/dev.c               |   17 +++++++++++++++--
 net/core/skbuff.c            |   33 +++++++++++++++++++++++++++++++++
 net/core/sock.c              |    6 ++++++
 net/socket.c                 |   23 +++++++++++++++++++++++
 8 files changed, 103 insertions(+), 2 deletions(-)

diff --git a/include/asm-powerpc/socket.h b/include/asm-powerpc/socket.h
index be304b6..26a232f 100644
--- a/include/asm-powerpc/socket.h
+++ b/include/asm-powerpc/socket.h
@@ -64,4 +64,7 @@
 #define SO_TIMESTAMPHW		37
 #define SCM_TIMESTAMPHW		SO_TIMESTAMPHW
 
+#define SO_TXTIMESTAMP		38
+#define SCM_TXTIMESTAMP		SO_TXTIMESTAMP
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f19ed43..39b3ffd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1697,5 +1697,8 @@ static inline void skb_forward_csum(struct sk_buff *skb)
 }
 
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
+
+int skb_tx_timestamp(struct sk_buff *orig_skb, ktime_t tstamp);
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 7ff1d02..784af54 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -415,6 +415,7 @@ enum sock_flags {
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
 	SOCK_RCVTSTAMPHW, /* %SO_TIMESTAMPHW setting */
+	SOCK_TXTSTAMP, /* %SO_TXTIMESTAMP setting */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
@@ -1157,6 +1158,11 @@ static inline int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
+static inline void __net_tx_timestamp(struct sk_buff *skb)
+{
+	skb_tx_timestamp(skb, ktime_get_real());
+}
+
 /*
  *	Recover an error report and clear atomically
  */
@@ -1263,6 +1269,9 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 		sk->sk_stamp = kt;
 }
 
+extern int sock_send_timestamp(ktime_t *tstamp, struct msghdr *msg,
+			       struct sock *sk);
+
 /**
  * sk_eat_skb - Release a skb if it is no longer needed
  * @sk: socket to eat this skb from
diff --git a/include/net/tstamps.h b/include/net/tstamps.h
index 9e02673..e2faced 100644
--- a/include/net/tstamps.h
+++ b/include/net/tstamps.h
@@ -1,6 +1,17 @@
 #ifndef _NET_TIMESTAMPS_H
 #define _NET_TIMESTAMPS_H
 
+/*
+ * Timestamps for outgoing skbs have special meaning:
+ *
+ * - MSB bits 0-15: command flags (take timestamp, embed timestamp, schedule
+ * packet, etc.)
+ * - other bits: command specific
+ */
+
+/* request TX timestamping */
+#define SKB_TSTAMP_TX_STAMP			(0x8000000000000000ULL)
+
 #ifdef __KERNEL__
 
 #include <linux/skbuff.h>
diff --git a/net/core/dev.c b/net/core/dev.c
index fca23a3..40fd301 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1243,6 +1243,14 @@ static inline void net_timestamp(struct sk_buff *skb)
 		skb->tstamp.tv64 = 0;
 }
 
+static inline void net_tx_timestamp(struct sk_buff *skb)
+{
+	/* TX timestamps reach userspace only if RX timestamps are enabled */
+	if (atomic_read(&netstamp_needed) &&
+	    (skb->tstamp.tv64 & SKB_TSTAMP_TX_STAMP))
+		__net_tx_timestamp(skb);
+}
+
 /*
  *	Support routine. Sends outgoing frames to any network
  *	taps currently in use.
@@ -1568,6 +1576,8 @@ static int dev_gso_segment(struct sk_buff *skb)
 
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	int rc;
+
 	if (likely(!skb->next)) {
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
@@ -1579,13 +1589,15 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				goto gso;
 		}
 
-		return dev->hard_start_xmit(skb, dev);
+		rc = dev->hard_start_xmit(skb, dev);
+		if (likely(!rc))
+			net_tx_timestamp(skb);
+		return rc;
 	}
 
 gso:
 	do {
 		struct sk_buff *nskb = skb->next;
-		int rc;
 
 		skb->next = nskb->next;
 		nskb->next = NULL;
@@ -1595,6 +1607,7 @@ gso:
 			skb->next = nskb;
 			return rc;
 		}
+		net_tx_timestamp(skb);
 		if (unlikely((netif_queue_stopped(dev) ||
 			     netif_subqueue_stopped(dev, skb)) &&
 			     skb->next))
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3666216..0a5b49e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2565,6 +2565,39 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
 }
 
 /**
+ * skb_tx_timestamp - timestamp a transmitted skb
+ * @orig_skb: the skb to be timestamped
+ * @tstamp: the value of the timestamp
+ *
+ * This function will not actually timestamp the skb, but, if the skb has a
+ * socket associated, clone the skb, timestamp it, and queue it to the error
+ * queue of the socket.
+ */
+int skb_tx_timestamp(struct sk_buff *orig_skb, ktime_t tstamp)
+{
+	struct sock *sk = orig_skb->sk;
+	struct sk_buff *skb;
+	int err = -ENOMEM;
+
+	if (!sk)
+		return -ENOTSOCK;
+
+	skb = skb_clone(orig_skb, GFP_ATOMIC);
+	if (!skb)
+		return err;
+
+	skb->tstamp = tstamp;
+
+	err = sock_queue_err_skb(sk, skb);
+	if (err)
+		kfree_skb(skb);
+
+	return err;
+}
+EXPORT_SYMBOL(skb_tx_timestamp);
+
+
+/**
  * skb_partial_csum_set - set up and verify partial csum values for packet
  * @skb: the skb to set
  * @start: the number of bytes after skb->data to start checksumming.
diff --git a/net/core/sock.c b/net/core/sock.c
index d6f05bb..6fa8cbc 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -628,6 +628,12 @@ set_rcvbuf:
 
 		break;
 
+	case SO_TXTIMESTAMP:
+		if (valbool)
+			sock_set_flag(sk, SOCK_TXTSTAMP);
+		else
+			sock_reset_flag(sk, SOCK_TXTSTAMP);
+
 	case SO_RCVLOWAT:
 		if (val < 0)
 			val = INT_MAX;
diff --git a/net/socket.c b/net/socket.c
index 40bc098..4dbc7b6 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -543,6 +543,29 @@ void sock_release(struct socket *sock)
 	sock->file = NULL;
 }
 
+int sock_send_timestamp(ktime_t *tstamp, struct msghdr *msg, struct sock *sk)
+{
+	struct cmsghdr *cmsg;
+
+	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+		if (!CMSG_OK(msg, cmsg))
+			return -EINVAL;
+		if (cmsg->cmsg_level != SOL_SOCKET ||
+		    cmsg->cmsg_type != SCM_TXTIMESTAMP ||
+		    cmsg->cmsg_len != CMSG_LEN(sizeof(__u64)))
+			continue;
+
+		*tstamp = *((ktime_t *)CMSG_DATA(cmsg));
+		break;
+	}
+
+	if (sk && sock_flag(sk, SOCK_TXTSTAMP))
+		tstamp->tv64 |= SKB_TSTAMP_TX_STAMP;
+
+	return 0;
+}
+EXPORT_SYMBOL(sock_send_timestamp);
+
 static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 				 struct msghdr *msg, size_t size)
 {
-- 
1.5.6.2

