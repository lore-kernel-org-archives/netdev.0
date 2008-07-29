From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC][PATCH 1/1] net: support for hardware timestamping
Date: Tue, 29 Jul 2008 03:08:00 +0300
Message-ID: <1217290080-4251-2-git-send-email-opurdila@ixiacom.com>
References: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:8784 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752855AbYG2AKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 20:10:34 -0400
In-Reply-To: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the infrastructure which allows net devices to store
hardware timestamps in the skb tstamp field so that they can
eventually be passed to userspace.

A bit in skb->tstamp is used to mark the timestamp as hardware
timestamp and a new net_device method, get_tstamp, is added to do the
conversion from the hardware specific timestamp to a "gettimeofday
compatible" timestamp.

A new net device ioctl is added (SIOCHWTSQUERY) to allow the
applications to retrieve information about the timestamping unit
(timer frequency and bits).

New socket option and socket control message are added as well
(SO_TIMESTAMPHW and SCM_TIMESTAMPHW).

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/asm-powerpc/socket.h            |    3 +
 include/linux/if.h                      |    5 ++
 include/linux/netdevice.h               |    2 +
 include/linux/skbuff.h                  |   17 +-----
 include/linux/sockios.h                 |    3 +
 include/net/sock.h                      |   11 ++++-
 include/net/tstamps.h                   |   86 +++++++++++++++++++++++++++++++
 net/core/sock.c                         |   29 +++++++---
 net/decnet/dn_route.c                   |    2 +-
 net/econet/af_econet.c                  |    2 +-
 net/ipv4/ip_fragment.c                  |    4 +-
 net/ipv4/netfilter/ip_queue.c           |    2 +-
 net/ipv4/netfilter/ipt_ULOG.c           |    2 +-
 net/ipv4/tcp_input.c                    |    2 +-
 net/ipv4/tcp_ipv4.c                     |    2 +-
 net/ipv4/tcp_output.c                   |    2 +-
 net/ipv6/netfilter/ip6_queue.c          |    2 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c |    4 +-
 net/ipv6/reassembly.c                   |    4 +-
 net/ipv6/tcp_ipv6.c                     |    2 +-
 net/ipx/af_ipx.c                        |    2 +-
 net/netfilter/nfnetlink_log.c           |    2 +-
 net/netfilter/nfnetlink_queue.c         |    2 +-
 net/netfilter/xt_time.c                 |    2 +-
 net/packet/af_packet.c                  |    4 +-
 net/rxrpc/ar-input.c                    |    2 +-
 net/socket.c                            |   21 +++++---
 net/sunrpc/svcsock.c                    |    2 +-
 28 files changed, 168 insertions(+), 55 deletions(-)
 create mode 100644 include/net/tstamps.h

diff --git a/include/asm-powerpc/socket.h b/include/asm-powerpc/socket.h
index f5a4e16..be304b6 100644
--- a/include/asm-powerpc/socket.h
+++ b/include/asm-powerpc/socket.h
@@ -61,4 +61,7 @@
 
 #define SO_MARK			36
 
+#define SO_TIMESTAMPHW		37
+#define SCM_TIMESTAMPHW		SO_TIMESTAMPHW
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/include/linux/if.h b/include/linux/if.h
index 5c9d1fa..8264371 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -148,6 +148,11 @@ struct if_settings
 	} ifs_ifsu;
 };
 
+struct if_hwtstamps {
+	unsigned short freq;		/* timer frequency, in ns */
+	unsigned char bits;		/* how much can we count, in bits */
+};
+
 /*
  * Interface request structure used for socket
  * ioctl's.  All interface ioctl's must have parameter
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 25f8710..7ba9c1a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -727,6 +727,8 @@ struct net_device
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	void                    (*poll_controller)(struct net_device *dev);
 #endif
+	ktime_t			(*get_tstamp)(struct net_device *dev,
+					      const struct sk_buff *skb);
 
 #ifdef CONFIG_NET_NS
 	/* Network namespace this network device is inside */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 299ec4b..f19ed43 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -199,7 +199,8 @@ typedef unsigned char *sk_buff_data_t;
  *	@next: Next buffer in list
  *	@prev: Previous buffer in list
  *	@sk: Socket we are owned by
- *	@tstamp: Time we arrived
+ *	@tstamp: Time we arrived; representation might be hardware specific, do
+ *	        not access directly but via skb_get_tstamp
  *	@dev: Device we arrived on/are leaving by
  *	@transport_header: Transport layer header
  *	@network_header: Network layer header
@@ -1515,20 +1516,6 @@ static inline void skb_copy_to_linear_data_offset(struct sk_buff *skb,
 
 extern void skb_init(void);
 
-/**
- *	skb_get_timestamp - get timestamp from a skb
- *	@skb: skb to get stamp from
- *	@stamp: pointer to struct timeval to store stamp in
- *
- *	Timestamps are stored in the skb as offsets to a base timestamp.
- *	This function converts the offset back to a struct timeval and stores
- *	it in stamp.
- */
-static inline void skb_get_timestamp(const struct sk_buff *skb, struct timeval *stamp)
-{
-	*stamp = ktime_to_timeval(skb->tstamp);
-}
-
 static inline void __net_timestamp(struct sk_buff *skb)
 {
 	skb->tstamp = ktime_get_real();
diff --git a/include/linux/sockios.h b/include/linux/sockios.h
index abef759..c7bd550 100644
--- a/include/linux/sockios.h
+++ b/include/linux/sockios.h
@@ -122,6 +122,9 @@
 #define SIOCBRADDIF	0x89a2		/* add interface to bridge      */
 #define SIOCBRDELIF	0x89a3		/* remove interface from bridge */
 
+/* hardware timestamps */
+#define SIOCHWTSQUERY	0x89b0		/* timer freq, bits, etc. */
+
 /* Device private ioctl calls */
 
 /*
diff --git a/include/net/sock.h b/include/net/sock.h
index dc42b44..7ff1d02 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -56,6 +56,7 @@
 #include <asm/atomic.h>
 #include <net/dst.h>
 #include <net/checksum.h>
+#include <net/tstamps.h>
 
 /*
  * This structure really needs to be cleaned up.
@@ -413,6 +414,7 @@ enum sock_flags {
 	SOCK_RCVTSTAMPNS, /* %SO_TIMESTAMPNS setting */
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
+	SOCK_RCVTSTAMPHW, /* %SO_TIMESTAMPHW setting */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
@@ -1253,7 +1255,7 @@ extern void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 static __inline__ void
 sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 {
-	ktime_t kt = skb->tstamp;
+	ktime_t kt = skb_get_tstamp(skb);
 
 	if (sock_flag(sk, SOCK_RCVTSTAMP))
 		__sock_recv_timestamp(msg, sk, skb);
@@ -1321,6 +1323,13 @@ extern void sock_enable_timestamp(struct sock *sk);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);
 extern int sock_get_timestampns(struct sock *, struct timespec __user *);
 
+static inline void skb_drop_dev(struct sock *sk, struct sk_buff *skb)
+{
+	if (!sk || !sock_flag(sk, SOCK_RCVTSTAMPHW))
+		skb->tstamp = skb_get_tstamp(skb);
+	skb->dev = NULL;
+}
+
 /* 
  *	Enable debug/info messages 
  */
diff --git a/include/net/tstamps.h b/include/net/tstamps.h
new file mode 100644
index 0000000..9e02673
--- /dev/null
+++ b/include/net/tstamps.h
@@ -0,0 +1,86 @@
+#ifndef _NET_TIMESTAMPS_H
+#define _NET_TIMESTAMPS_H
+
+#ifdef __KERNEL__
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+
+/*
+ * If the driver has timestamping capabilities, it will store its private
+ * formated timestamp in skb->tstamp and will set the high bit of the timestamp
+ * to announce this.
+ *
+ * The hardware timestamp can then reach userspace as it is (via
+ * SO_TIMESTAMPHW).
+ *
+ * When needed for in kernel or in userspace usage, it will be converted to a
+ * plain ktime_t timestamp via the driver's get_stamp method.
+ */
+#define SKB_TSTAMP_HW (0x8000000000000000ULL)
+
+static inline int __skb_has_hwtstamp(const struct sk_buff *skb)
+{
+	int hwstamp = (skb->tstamp.tv64 & SKB_TSTAMP_HW)?1:0;
+
+	BUG_ON(hwstamp && (!skb->dev || !skb->dev->get_tstamp));
+
+	return hwstamp;
+}
+
+static inline ktime_t mk_hwtstamp(__u64 value)
+{
+	ktime_t tstamp = {
+		.tv64 = value | SKB_TSTAMP_HW
+	};
+
+	return tstamp;
+}
+
+static inline ktime_t skb_get_tstamp(const struct sk_buff *skb)
+{
+	if (__skb_has_hwtstamp(skb))
+		return skb->dev->get_tstamp(skb->dev, skb);
+	else
+		return skb->tstamp;
+}
+
+/**
+ *	skb_get_timestamp - get timestamp (ms resolution) from a skb
+ *	@skb: skb to get stamp from
+ *	@stamp: pointer to struct timeval to store stamp in
+ */
+static inline void skb_get_timestamp(const struct sk_buff *skb,
+				     struct timeval *stamp)
+{
+	*stamp = ktime_to_timeval(skb_get_tstamp(skb));
+}
+
+/**
+ *	skb_get_timestamp - get timestamp (ns resolution) from a skb
+ *	@skb: skb to get stamp from
+ *	@stamp: pointer to struct timespec to store stamp in
+ */
+static inline void skb_get_timestamp_ns(const struct sk_buff *skb,
+					struct timespec *stamp)
+{
+	*stamp = ktime_to_timespec(skb_get_tstamp(skb));
+}
+
+/**
+ *	skb_get_hwtstamp - get the hardware timestamp from a skb
+ *	@skb: skb to get stamp from
+ *	@stamp: pointer to ktime_t where to store stamp in
+ */
+static inline int skb_get_timestamp_hw(const struct sk_buff *skb,
+				       ktime_t *stamp)
+{
+	if (!__skb_has_hwtstamp(skb))
+		return -EINVAL;
+
+	stamp->tv64 = skb->tstamp.tv64 & ~SKB_TSTAMP_HW;
+	return 0;
+}
+#endif /* __KERNEL__ */
+
+#endif
diff --git a/net/core/sock.c b/net/core/sock.c
index 88094cb..d6f05bb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -288,7 +288,7 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		goto out;
 	}
 
-	skb->dev = NULL;
+	skb_drop_dev(sk, skb);
 	skb_set_owner_r(skb, sk);
 
 	/* Cache the SKB length before we tack it onto the receive
@@ -314,7 +314,7 @@ int sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested)
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
-	skb->dev = NULL;
+	skb_drop_dev(sk, skb);
 
 	if (nested)
 		bh_lock_sock_nested(sk);
@@ -609,17 +609,23 @@ set_rcvbuf:
 
 	case SO_TIMESTAMP:
 	case SO_TIMESTAMPNS:
+	case SO_TIMESTAMPHW:
+		sock_reset_flag(sk, SOCK_RCVTSTAMPNS);
+		sock_reset_flag(sk, SOCK_RCVTSTAMPHW);
 		if (valbool)  {
-			if (optname == SO_TIMESTAMP)
-				sock_reset_flag(sk, SOCK_RCVTSTAMPNS);
-			else
+			switch (optname) {
+			case SO_TIMESTAMPNS:
 				sock_set_flag(sk, SOCK_RCVTSTAMPNS);
+				break;
+			case SO_TIMESTAMPHW:
+				sock_set_flag(sk, SOCK_RCVTSTAMPHW);
+				break;
+			}
 			sock_set_flag(sk, SOCK_RCVTSTAMP);
 			sock_enable_timestamp(sk);
-		} else {
+		} else
 			sock_reset_flag(sk, SOCK_RCVTSTAMP);
-			sock_reset_flag(sk, SOCK_RCVTSTAMPNS);
-		}
+
 		break;
 
 	case SO_RCVLOWAT:
@@ -760,13 +766,18 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 
 	case SO_TIMESTAMP:
 		v.val = sock_flag(sk, SOCK_RCVTSTAMP) &&
-				!sock_flag(sk, SOCK_RCVTSTAMPNS);
+			!sock_flag(sk, SOCK_RCVTSTAMPNS) &&
+			!sock_flag(sk, SOCK_RCVTSTAMPNS);
 		break;
 
 	case SO_TIMESTAMPNS:
 		v.val = sock_flag(sk, SOCK_RCVTSTAMPNS);
 		break;
 
+	case SO_TIMESTAMPHW:
+		v.val = sock_flag(sk, SOCK_RCVTSTAMPHW);
+		break;
+
 	case SO_RCVTIMEO:
 		lv=sizeof(struct timeval);
 		if (sk->sk_rcvtimeo == MAX_SCHEDULE_TIMEOUT) {
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index f50e88b..e718f90 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1572,7 +1572,7 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 
 	if (skb->dev)
 		dev_put(skb->dev);
-	skb->dev = NULL;
+	skb_drop_dev(init_net.rtnl, skb);
 	if (err)
 		goto out_free;
 	skb->dst = &rt->u.dst;
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 7c9bb13..430b0d7 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -162,7 +162,7 @@ static int econet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	err = memcpy_toiovec(msg->msg_iov, skb->data, copied);
 	if (err)
 		goto out_free;
-	sk->sk_stamp = skb->tstamp;
+	sk->sk_stamp = skb_get_tstamp(skb);
 
 	if (msg->msg_name)
 		memcpy(msg->msg_name, skb->cb, msg->msg_namelen);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 37221f6..b2ccc9c 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -434,9 +434,9 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	dev = skb->dev;
 	if (dev) {
 		qp->iif = dev->ifindex;
-		skb->dev = NULL;
+		skb_drop_dev(NULL, skb);
 	}
-	qp->q.stamp = skb->tstamp;
+	qp->q.stamp = skb_get_tstamp(skb);
 	qp->q.meat += skb->len;
 	atomic_add(skb->truesize, &qp->q.net->mem);
 	if (offset == 0)
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 26a37ce..86039d2 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -193,7 +193,7 @@ ipq_build_packet_message(struct nf_queue_entry *entry, int *errp)
 
 	pmsg->packet_id       = (unsigned long )entry;
 	pmsg->data_len        = data_len;
-	tv = ktime_to_timeval(entry->skb->tstamp);
+	tv = ktime_to_timeval(skb_get_tstamp(entry->skb));
 	pmsg->timestamp_sec   = tv.tv_sec;
 	pmsg->timestamp_usec  = tv.tv_usec;
 	pmsg->mark            = entry->skb->mark;
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index b192756..48c95b0 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -214,7 +214,7 @@ static void ipt_ulog_packet(unsigned int hooknum,
 
 	/* copy hook, prefix, timestamp, payload, etc. */
 	pm->data_len = copy_len;
-	tv = ktime_to_timeval(skb->tstamp);
+	tv = ktime_to_timeval(skb_get_tstamp(skb));
 	put_unaligned(tv.tv_sec, &pm->timestamp_sec);
 	put_unaligned(tv.tv_usec, &pm->timestamp_usec);
 	put_unaligned(skb->mark, &pm->mark);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cad73b7..be18bf1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2872,7 +2872,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets)
 				flag |= FLAG_NONHEAD_RETRANS_ACKED;
 		} else {
 			ca_seq_rtt = now - scb->when;
-			last_ackt = skb->tstamp;
+			last_ackt = skb_get_tstamp(skb);
 			if (seq_rtt < 0) {
 				seq_rtt = ca_seq_rtt;
 			}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ffe869a..e709adb 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1654,7 +1654,7 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
-	skb->dev = NULL;
+	skb_drop_dev(sk, skb);
 
 	bh_lock_sock_nested(sk);
 	ret = 0;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ad993ec..8d0f36d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -753,7 +753,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 	 * skbs, which it never sent before. --ANK
 	 */
 	TCP_SKB_CB(buff)->when = TCP_SKB_CB(skb)->when;
-	buff->tstamp = skb->tstamp;
+	buff->tstamp = skb_get_tstamp(skb);
 
 	old_factor = tcp_skb_pcount(skb);
 
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 2eff3ae..a2db96e 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -196,7 +196,7 @@ ipq_build_packet_message(struct nf_queue_entry *entry, int *errp)
 
 	pmsg->packet_id       = (unsigned long )entry;
 	pmsg->data_len        = data_len;
-	tv = ktime_to_timeval(entry->skb->tstamp);
+	tv = ktime_to_timeval(skb_get_tstamp(entry->skb));
 	pmsg->timestamp_sec   = tv.tv_sec;
 	pmsg->timestamp_usec  = tv.tv_usec;
 	pmsg->mark            = entry->skb->mark;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index cf20bc4..deabff0 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -378,8 +378,8 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 	else
 		fq->q.fragments = skb;
 
-	skb->dev = NULL;
-	fq->q.stamp = skb->tstamp;
+	skb_drop_dev(sk, skb);
+	fq->q.stamp = skb_get_tstamp(skb);
 	fq->q.meat += skb->len;
 	atomic_add(skb->truesize, &nf_init_frags.mem);
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index a60d7d1..8ea4f65 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -410,9 +410,9 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	dev = skb->dev;
 	if (dev) {
 		fq->iif = dev->ifindex;
-		skb->dev = NULL;
+		skb_drop_dev(NULL, skb);
 	}
-	fq->q.stamp = skb->tstamp;
+	fq->q.stamp = skb_get_tstamp(skb);
 	fq->q.meat += skb->len;
 	atomic_add(skb->truesize, &fq->q.net->mem);
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 40ea9c3..a0b2927 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1756,7 +1756,7 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
-	skb->dev = NULL;
+	skb_drop_dev(sk, skb);
 
 	bh_lock_sock_nested(sk);
 	ret = 0;
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 81ae873..d8393ac 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1805,7 +1805,7 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (rc)
 		goto out_free;
 	if (skb->tstamp.tv64)
-		sk->sk_stamp = skb->tstamp;
+		sk->sk_stamp = skb_get_tstamp(skb);
 
 	msg->msg_namelen = sizeof(*sipx);
 
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index b8173af..3ba837d 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -455,7 +455,7 @@ __build_packet_message(struct nfulnl_instance *inst,
 
 	if (skb->tstamp.tv64) {
 		struct nfulnl_msg_packet_timestamp ts;
-		struct timeval tv = ktime_to_timeval(skb->tstamp);
+		struct timeval tv = ktime_to_timeval(skb_get_tstamp(skb));
 		ts.sec = cpu_to_be64(tv.tv_sec);
 		ts.usec = cpu_to_be64(tv.tv_usec);
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 3447025..6069e07 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -351,7 +351,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 
 	if (entskb->tstamp.tv64) {
 		struct nfqnl_msg_packet_timestamp ts;
-		struct timeval tv = ktime_to_timeval(entskb->tstamp);
+		struct timeval tv = ktime_to_timeval(skb_get_tstamp(entskb));
 		ts.sec = cpu_to_be64(tv.tv_sec);
 		ts.usec = cpu_to_be64(tv.tv_usec);
 
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index ed76baa..3737d6e 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -172,7 +172,7 @@ time_mt(const struct sk_buff *skb, const struct net_device *in,
 	if (skb->tstamp.tv64 == 0)
 		__net_timestamp((struct sk_buff *)skb);
 
-	stamp = ktime_to_ns(skb->tstamp);
+	stamp = ktime_to_ns(skb_get_tstamp(skb));
 	do_div(stamp, NSEC_PER_SEC);
 
 	if (info->flags & XT_TIME_LOCAL_TZ)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2cee87d..c895e72 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -518,7 +518,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 		goto drop_n_acct;
 
 	skb_set_owner_r(skb, sk);
-	skb->dev = NULL;
+	skb_drop_dev(sk, skb);
 	dst_release(skb->dst);
 	skb->dst = NULL;
 
@@ -639,7 +639,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 	h->tp_mac = macoff;
 	h->tp_net = netoff;
 	if (skb->tstamp.tv64)
-		tv = ktime_to_timeval(skb->tstamp);
+		tv = ktime_to_timeval(skb_get_tstamp(skb));
 	else
 		do_gettimeofday(&tv);
 	h->tp_sec = tv.tv_sec;
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index f8a699e..2229edc 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -87,7 +87,7 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 	    !test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
 	    call->socket->sk.sk_state != RXRPC_CLOSE) {
 		skb->destructor = rxrpc_packet_destructor;
-		skb->dev = NULL;
+		skb_drop_dev(skb);
 		skb->sk = sk;
 		atomic_add(skb->truesize, &sk->sk_rmem_alloc);
 
diff --git a/net/socket.c b/net/socket.c
index 66c4a8c..40bc098 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -601,24 +601,31 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 {
 	ktime_t kt = skb->tstamp;
 
-	if (!sock_flag(sk, SOCK_RCVTSTAMPNS)) {
-		struct timeval tv;
+	// FIXME: I've tried to keep the same no jump path for the common
+	// SOCK_RCVTSTAMP as in orignal code, with the unlikely constructs;
+	// is it necessary?
+	if (unlikely(sock_flag(sk, SOCK_RCVTSTAMPHW))) {
+		if (!skb_get_timestamp_hw(skb, &kt))
+		    put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPHW, sizeof(kt), &kt);
+	} else if (unlikely(sock_flag(sk, SOCK_RCVTSTAMPNS))) {
+		struct timespec ts;
 		/* Race occurred between timestamp enabling and packet
 		   receiving.  Fill in the current time for now. */
 		if (kt.tv64 == 0)
 			kt = ktime_get_real();
 		skb->tstamp = kt;
-		tv = ktime_to_timeval(kt);
-		put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMP, sizeof(tv), &tv);
+		skb_get_timestamp_ns(skb, &ts);
+		put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPNS, sizeof(ts), &ts);
+
 	} else {
-		struct timespec ts;
+		struct timeval tv;
 		/* Race occurred between timestamp enabling and packet
 		   receiving.  Fill in the current time for now. */
 		if (kt.tv64 == 0)
 			kt = ktime_get_real();
 		skb->tstamp = kt;
-		ts = ktime_to_timespec(kt);
-		put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPNS, sizeof(ts), &ts);
+		skb_get_timestamp(skb, &tv);
+		put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMP, sizeof(tv), &tv);
 	}
 }
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 3e65719..0f2226a 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -477,7 +477,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 		/* Don't enable netstamp, sunrpc doesn't
 		   need that much accuracy */
 	}
-	svsk->sk_sk->sk_stamp = skb->tstamp;
+	svsk->sk_sk->sk_stamp = skb_get_tstamp(skb);
 	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* there may be more data... */
 
 	/*
-- 
1.5.6.2

