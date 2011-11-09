From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2] net: add wireless TX status socket option
Date: Wed, 09 Nov 2011 10:15:42 +0100
Message-ID: <1320830142.3845.11.camel@jlt3.sipsolutions.net>
References: <1320317796.3950.43.camel@jlt3.sipsolutions.net>
	 (sfid-20111103_115649_112560_F2AE087E)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:37095 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab1KIJPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 04:15:47 -0500
In-Reply-To: <1320317796.3950.43.camel@jlt3.sipsolutions.net> (sfid-20111103_115649_112560_F2AE087E)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The 802.1X EAPOL handshake hostapd does requires
knowing whether the frame was ack'ed by the peer.
Currently, we fudge this pretty badly by not even
transmitting the frame as a normal data frame but
injecting it with radiotap and getting the status
out of radiotap monitor as well. This is rather
complex, confuses users (mon.wlan0 presence) and
doesn't work with all hardware.

To get rid of that hack, introduce a real wifi TX
status option for data frame transmissions.

This works similar to the existing TX timestamping
in that it reflects the SKB back to the socket's
error queue with a SCM_WIFI_STATUS cmsg that has
an int indicating ACK status (0/1).

Since it is possible that at some point we will
want to have TX timestamping and wifi status in a
single errqueue SKB (there's little point in not
doing that), redefine SO_EE_ORIGIN_TIMESTAMPING
to SO_EE_ORIGIN_TXSTATUS which can collect more
than just the timestamp; keep the old constant
as an alias of course. Currently the internal APIs
don't make that possible, but it wouldn't be hard
to split them up in a way that makes it possible.

Thanks to Neil Horman for helping me figure out
the functions that add the control messages.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
v2: rebase onto net-next coming into wireless-next

 arch/alpha/include/asm/socket.h   |    3 +++
 arch/arm/include/asm/socket.h     |    3 +++
 arch/avr32/include/asm/socket.h   |    3 +++
 arch/cris/include/asm/socket.h    |    3 +++
 arch/frv/include/asm/socket.h     |    3 +++
 arch/h8300/include/asm/socket.h   |    3 +++
 arch/ia64/include/asm/socket.h    |    3 +++
 arch/m32r/include/asm/socket.h    |    3 +++
 arch/m68k/include/asm/socket.h    |    3 +++
 arch/mips/include/asm/socket.h    |    3 +++
 arch/mn10300/include/asm/socket.h |    3 +++
 arch/parisc/include/asm/socket.h  |    3 +++
 arch/powerpc/include/asm/socket.h |    3 +++
 arch/s390/include/asm/socket.h    |    3 +++
 arch/sparc/include/asm/socket.h   |    3 +++
 arch/xtensa/include/asm/socket.h  |    3 +++
 include/asm-generic/socket.h      |    3 +++
 include/linux/errqueue.h          |    3 ++-
 include/linux/skbuff.h            |   19 +++++++++++++++++--
 include/net/sock.h                |    6 ++++++
 net/core/skbuff.c                 |   20 ++++++++++++++++++++
 net/core/sock.c                   |    9 +++++++++
 net/socket.c                      |   18 ++++++++++++++++++
 23 files changed, 123 insertions(+), 3 deletions(-)

--- a/include/asm-generic/socket.h	2011-11-08 22:32:30.000000000 +0100
+++ b/include/asm-generic/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -64,4 +64,7 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS	SO_WIFI_STATUS
 #endif /* __ASM_GENERIC_SOCKET_H */
--- a/net/core/sock.c	2011-11-09 10:07:34.000000000 +0100
+++ b/net/core/sock.c	2011-11-09 10:12:02.000000000 +0100
@@ -740,6 +740,11 @@ set_rcvbuf:
 	case SO_RXQ_OVFL:
 		sock_valbool_flag(sk, SOCK_RXQ_OVFL, valbool);
 		break;
+
+	case SO_WIFI_STATUS:
+		sock_valbool_flag(sk, SOCK_WIFI_STATUS, valbool);
+		break;
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -961,6 +966,10 @@ int sock_getsockopt(struct socket *sock,
 		v.val = !!sock_flag(sk, SOCK_RXQ_OVFL);
 		break;
 
+	case SO_WIFI_STATUS:
+		v.val = !!sock_flag(sk, SOCK_WIFI_STATUS);
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
--- a/include/net/sock.h	2011-11-09 10:07:30.000000000 +0100
+++ b/include/net/sock.h	2011-11-09 10:12:02.000000000 +0100
@@ -563,6 +563,7 @@ enum sock_flags {
 	SOCK_FASYNC, /* fasync() active */
 	SOCK_RXQ_OVFL,
 	SOCK_ZEROCOPY, /* buffers from userspace */
+	SOCK_WIFI_STATUS, /* push wifi status to userspace */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
@@ -1714,6 +1715,8 @@ static inline int sock_intr_errno(long t
 
 extern void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	struct sk_buff *skb);
+extern void __sock_recv_wifi_status(struct msghdr *msg, struct sock *sk,
+	struct sk_buff *skb);
 
 static __inline__ void
 sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
@@ -1741,6 +1744,9 @@ sock_recv_timestamp(struct msghdr *msg,
 		__sock_recv_timestamp(msg, sk, skb);
 	else
 		sk->sk_stamp = kt;
+
+	if (sock_flag(sk, SOCK_WIFI_STATUS) && skb->wifi_acked_valid)
+		__sock_recv_wifi_status(msg, sk, skb);
 }
 
 extern void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
--- a/arch/alpha/include/asm/socket.h	2011-11-08 22:32:30.000000000 +0100
+++ b/arch/alpha/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -69,6 +69,9 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
--- a/arch/arm/include/asm/socket.h	2011-11-08 22:32:30.000000000 +0100
+++ b/arch/arm/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
--- a/arch/avr32/include/asm/socket.h	2011-11-08 22:32:29.000000000 +0100
+++ b/arch/avr32/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* __ASM_AVR32_SOCKET_H */
--- a/arch/cris/include/asm/socket.h	2011-11-08 22:32:30.000000000 +0100
+++ b/arch/cris/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -64,6 +64,9 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
 
 
--- a/arch/frv/include/asm/socket.h	2011-11-08 22:32:29.000000000 +0100
+++ b/arch/frv/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -62,5 +62,8 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
 
--- a/arch/h8300/include/asm/socket.h	2011-11-08 22:32:29.000000000 +0100
+++ b/arch/h8300/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
--- a/arch/ia64/include/asm/socket.h	2011-11-08 22:32:30.000000000 +0100
+++ b/arch/ia64/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -71,4 +71,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_IA64_SOCKET_H */
--- a/arch/m32r/include/asm/socket.h	2011-11-08 22:32:30.000000000 +0100
+++ b/arch/m32r/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_M32R_SOCKET_H */
--- a/arch/m68k/include/asm/socket.h	2011-11-08 22:32:29.000000000 +0100
+++ b/arch/m68k/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
--- a/arch/mips/include/asm/socket.h	2011-11-08 22:32:29.000000000 +0100
+++ b/arch/mips/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -82,6 +82,9 @@ To add: #define SO_REUSEPORT 0x0200	/* A
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #ifdef __KERNEL__
 
 /** sock_type - Socket types
--- a/arch/mn10300/include/asm/socket.h	2011-11-08 22:32:29.000000000 +0100
+++ b/arch/mn10300/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
--- a/arch/parisc/include/asm/socket.h	2011-11-08 22:32:29.000000000 +0100
+++ b/arch/parisc/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -61,6 +61,9 @@
 
 #define SO_RXQ_OVFL             0x4021
 
+#define SO_WIFI_STATUS		0x4022
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
--- a/arch/powerpc/include/asm/socket.h	2011-11-08 22:32:29.000000000 +0100
+++ b/arch/powerpc/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -69,4 +69,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
--- a/arch/s390/include/asm/socket.h	2011-11-08 22:32:29.000000000 +0100
+++ b/arch/s390/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -70,4 +70,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
--- a/arch/sparc/include/asm/socket.h	2011-11-08 22:32:29.000000000 +0100
+++ b/arch/sparc/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -58,6 +58,9 @@
 
 #define SO_RXQ_OVFL             0x0024
 
+#define SO_WIFI_STATUS		0x0025
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
--- a/arch/xtensa/include/asm/socket.h	2011-11-08 22:32:29.000000000 +0100
+++ b/arch/xtensa/include/asm/socket.h	2011-11-09 10:12:02.000000000 +0100
@@ -73,4 +73,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif	/* _XTENSA_SOCKET_H */
--- a/include/linux/errqueue.h	2011-11-08 22:32:30.000000000 +0100
+++ b/include/linux/errqueue.h	2011-11-09 10:12:02.000000000 +0100
@@ -17,7 +17,8 @@ struct sock_extended_err {
 #define SO_EE_ORIGIN_LOCAL	1
 #define SO_EE_ORIGIN_ICMP	2
 #define SO_EE_ORIGIN_ICMP6	3
-#define SO_EE_ORIGIN_TIMESTAMPING 4
+#define SO_EE_ORIGIN_TXSTATUS	4
+#define SO_EE_ORIGIN_TIMESTAMPING SO_EE_ORIGIN_TXSTATUS
 
 #define SO_EE_OFFENDER(ee)	((struct sockaddr*)((ee)+1))
 
--- a/include/linux/skbuff.h	2011-11-09 10:07:30.000000000 +0100
+++ b/include/linux/skbuff.h	2011-11-09 10:12:41.000000000 +0100
@@ -218,6 +218,9 @@ enum {
 
 	/* device driver supports TX zero-copy buffers */
 	SKBTX_DEV_ZEROCOPY = 1 << 4,
+
+	/* generate wifi status information (where possible) */
+	SKBTX_WIFI_STATUS = 1 << 5,
 };
 
 /*
@@ -352,6 +355,8 @@ typedef unsigned char *sk_buff_data_t;
  *	@ooo_okay: allow the mapping of a socket to a queue to be changed
  *	@l4_rxhash: indicate rxhash is a canonical 4-tuple hash over transport
  *		ports.
+ *	@wifi_acked_valid: wifi_acked was set
+ *	@wifi_acked: whether frame was acked on wifi or not
  *	@dma_cookie: a cookie to one of several possible DMA operations
  *		done by skb DMA functions
  *	@secmark: security marking
@@ -445,10 +450,11 @@ struct sk_buff {
 #endif
 	__u8			ooo_okay:1;
 	__u8			l4_rxhash:1;
+	__u8			wifi_acked_valid:1;
+	__u8			wifi_acked:1;
+	/* 10/12 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
-	/* 0/13 bit hole */
-
 #ifdef CONFIG_NET_DMA
 	dma_cookie_t		dma_cookie;
 #endif
@@ -2263,6 +2269,15 @@ static inline void skb_tx_timestamp(stru
 	sw_tx_timestamp(skb);
 }
 
+/**
+ * skb_complete_wifi_ack - deliver skb with wifi status
+ *
+ * @skb: the original outgoing packet
+ * @acked: ack status
+ *
+ */
+void skb_complete_wifi_ack(struct sk_buff *skb, bool acked);
+
 extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
 extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
 
--- a/net/core/skbuff.c	2011-11-09 10:07:34.000000000 +0100
+++ b/net/core/skbuff.c	2011-11-09 10:12:02.000000000 +0100
@@ -3169,6 +3169,26 @@ void skb_tstamp_tx(struct sk_buff *orig_
 }
 EXPORT_SYMBOL_GPL(skb_tstamp_tx);
 
+void skb_complete_wifi_ack(struct sk_buff *skb, bool acked)
+{
+	struct sock *sk = skb->sk;
+	struct sock_exterr_skb *serr;
+	int err;
+
+	skb->wifi_acked_valid = 1;
+	skb->wifi_acked = acked;
+
+	serr = SKB_EXT_ERR(skb);
+	memset(serr, 0, sizeof(*serr));
+	serr->ee.ee_errno = ENOMSG;
+	serr->ee.ee_origin = SO_EE_ORIGIN_TXSTATUS;
+
+	err = sock_queue_err_skb(sk, skb);
+	if (err)
+		kfree_skb(skb);
+}
+EXPORT_SYMBOL_GPL(skb_complete_wifi_ack);
+
 
 /**
  * skb_partial_csum_set - set up and verify partial csum values for packet
--- a/net/socket.c	2011-11-09 10:07:34.000000000 +0100
+++ b/net/socket.c	2011-11-09 10:12:02.000000000 +0100
@@ -538,6 +538,8 @@ int sock_tx_timestamp(struct sock *sk, _
 		*tx_flags |= SKBTX_HW_TSTAMP;
 	if (sock_flag(sk, SOCK_TIMESTAMPING_TX_SOFTWARE))
 		*tx_flags |= SKBTX_SW_TSTAMP;
+	if (sock_flag(sk, SOCK_WIFI_STATUS))
+		*tx_flags |= SKBTX_WIFI_STATUS;
 	return 0;
 }
 EXPORT_SYMBOL(sock_tx_timestamp);
@@ -674,6 +676,22 @@ void __sock_recv_timestamp(struct msghdr
 }
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
 
+void __sock_recv_wifi_status(struct msghdr *msg, struct sock *sk,
+	struct sk_buff *skb)
+{
+	int ack;
+
+	if (!sock_flag(sk, SOCK_WIFI_STATUS))
+		return;
+	if (!skb->wifi_acked_valid)
+		return;
+
+	ack = skb->wifi_acked;
+
+	put_cmsg(msg, SOL_SOCKET, SCM_WIFI_STATUS, sizeof(ack), &ack);
+}
+EXPORT_SYMBOL_GPL(__sock_recv_wifi_status);
+
 static inline void sock_recv_drops(struct msghdr *msg, struct sock *sk,
 				   struct sk_buff *skb)
 {
