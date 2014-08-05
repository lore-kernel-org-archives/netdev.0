From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v4 2/6] net-timestamp: move timestamp flags out of sk_flags
Date: Mon,  4 Aug 2014 22:11:46 -0400
Message-ID: <1407204710-21778-3-git-send-email-willemb@google.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:61302 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449AbaHECLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 22:11:53 -0400
Received: by mail-ig0-f202.google.com with SMTP id r2so103966igi.1
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 19:11:52 -0700 (PDT)
In-Reply-To: <1407204710-21778-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk_flags is reaching its limit. New timestamping options will not fit.
Move all of them into a new field sk->sk_tsflags.

Added benefit is that this removes boilerplate code to convert between
SOF_TIMESTAMPING_.. and SOCK_TIMESTAMPING_.. in getsockopt/setsockopt.

SOCK_TIMESTAMPING_RX_SOFTWARE is also used to toggle the receive
timestamp logic (netstamp_needed). That can be simplified and this
last key removed, but will leave that for a separate patch.

Signed-off-by: Willem de Bruijn <willemb@google.com>

----

The u16 in sock can be moved into a 16-bit hole below sk_gso_max_segs,
though that scatters tstamp fields throughout the struct.
---
 include/net/sock.h | 29 +++++++++++------------------
 net/core/sock.c    | 25 ++-----------------------
 net/socket.c       |  8 ++++----
 3 files changed, 17 insertions(+), 45 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 02f5b35..a211297 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -67,6 +67,7 @@
 #include <linux/atomic.h>
 #include <net/dst.h>
 #include <net/checksum.h>
+#include <linux/net_tstamp.h>
 
 struct cgroup;
 struct cgroup_subsys;
@@ -278,6 +279,7 @@ struct cg_proto;
   *	@sk_protinfo: private area, net family specific, when not using slab
   *	@sk_timer: sock cleanup timer
   *	@sk_stamp: time stamp of last packet received
+  *	@sk_tsflags: SO_TIMESTAMPING socket options
   *	@sk_socket: Identd and reporting IO signals
   *	@sk_user_data: RPC layer private data
   *	@sk_frag: cached page frag
@@ -411,6 +413,7 @@ struct sock {
 	void			*sk_protinfo;
 	struct timer_list	sk_timer;
 	ktime_t			sk_stamp;
+	u16			sk_tsflags;
 	struct socket		*sk_socket;
 	void			*sk_user_data;
 	struct page_frag	sk_frag;
@@ -701,12 +704,7 @@ enum sock_flags {
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
 	SOCK_MEMALLOC, /* VM depends on this socket for swapping */
-	SOCK_TIMESTAMPING_TX_HARDWARE,  /* %SOF_TIMESTAMPING_TX_HARDWARE */
-	SOCK_TIMESTAMPING_TX_SOFTWARE,  /* %SOF_TIMESTAMPING_TX_SOFTWARE */
-	SOCK_TIMESTAMPING_RX_HARDWARE,  /* %SOF_TIMESTAMPING_RX_HARDWARE */
 	SOCK_TIMESTAMPING_RX_SOFTWARE,  /* %SOF_TIMESTAMPING_RX_SOFTWARE */
-	SOCK_TIMESTAMPING_SOFTWARE,     /* %SOF_TIMESTAMPING_SOFTWARE */
-	SOCK_TIMESTAMPING_RAW_HARDWARE, /* %SOF_TIMESTAMPING_RAW_HARDWARE */
 	SOCK_FASYNC, /* fasync() active */
 	SOCK_RXQ_OVFL,
 	SOCK_ZEROCOPY, /* buffers from userspace */
@@ -2160,20 +2158,17 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 
 	/*
 	 * generate control messages if
-	 * - receive time stamping in software requested (SOCK_RCVTSTAMP
-	 *   or SOCK_TIMESTAMPING_RX_SOFTWARE)
+	 * - receive time stamping in software requested
 	 * - software time stamp available and wanted
-	 *   (SOCK_TIMESTAMPING_SOFTWARE)
 	 * - hardware time stamps available and wanted
-	 *   SOCK_TIMESTAMPING_RAW_HARDWARE
 	 */
 	if (sock_flag(sk, SOCK_RCVTSTAMP) ||
-	    sock_flag(sk, SOCK_TIMESTAMPING_RX_SOFTWARE) ||
+	    (sk->sk_tsflags & SOF_TIMESTAMPING_RX_SOFTWARE) ||
 	    (kt.tv64 &&
-	     (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
+	     (sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE ||
 	      skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP)) ||
 	    (hwtstamps->hwtstamp.tv64 &&
-	     sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE)))
+	     (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE)))
 		__sock_recv_timestamp(msg, sk, skb);
 	else
 		sk->sk_stamp = kt;
@@ -2189,11 +2184,11 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 					  struct sk_buff *skb)
 {
 #define FLAGS_TS_OR_DROPS ((1UL << SOCK_RXQ_OVFL)			| \
-			   (1UL << SOCK_RCVTSTAMP)			| \
-			   (1UL << SOCK_TIMESTAMPING_SOFTWARE)		| \
-			   (1UL << SOCK_TIMESTAMPING_RAW_HARDWARE))
+			   (1UL << SOCK_RCVTSTAMP))
+#define TSFLAGS_ANY	  (SOF_TIMESTAMPING_SOFTWARE			| \
+			   SOF_TIMESTAMPING_RAW_HARDWARE)
 
-	if (sk->sk_flags & FLAGS_TS_OR_DROPS)
+	if (sk->sk_flags & FLAGS_TS_OR_DROPS || sk->sk_tsflags & TSFLAGS_ANY)
 		__sock_recv_ts_and_drops(msg, sk, skb);
 	else
 		sk->sk_stamp = skb->tstamp;
@@ -2203,8 +2198,6 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
  * sock_tx_timestamp - checks whether the outgoing packet is to be time stamped
  * @sk:		socket sending this packet
  * @tx_flags:	filled with instructions for time stamping
- *
- * Currently only depends on SOCK_TIMESTAMPING* flags.
  */
 void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags);
 
diff --git a/net/core/sock.c b/net/core/sock.c
index a741163..47c9377 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -848,22 +848,13 @@ set_rcvbuf:
 			ret = -EINVAL;
 			break;
 		}
-		sock_valbool_flag(sk, SOCK_TIMESTAMPING_TX_HARDWARE,
-				  val & SOF_TIMESTAMPING_TX_HARDWARE);
-		sock_valbool_flag(sk, SOCK_TIMESTAMPING_TX_SOFTWARE,
-				  val & SOF_TIMESTAMPING_TX_SOFTWARE);
-		sock_valbool_flag(sk, SOCK_TIMESTAMPING_RX_HARDWARE,
-				  val & SOF_TIMESTAMPING_RX_HARDWARE);
+		sk->sk_tsflags = val;
 		if (val & SOF_TIMESTAMPING_RX_SOFTWARE)
 			sock_enable_timestamp(sk,
 					      SOCK_TIMESTAMPING_RX_SOFTWARE);
 		else
 			sock_disable_timestamp(sk,
 					       (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE));
-		sock_valbool_flag(sk, SOCK_TIMESTAMPING_SOFTWARE,
-				  val & SOF_TIMESTAMPING_SOFTWARE);
-		sock_valbool_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE,
-				  val & SOF_TIMESTAMPING_RAW_HARDWARE);
 		break;
 
 	case SO_RCVLOWAT:
@@ -1089,19 +1080,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case SO_TIMESTAMPING:
-		v.val = 0;
-		if (sock_flag(sk, SOCK_TIMESTAMPING_TX_HARDWARE))
-			v.val |= SOF_TIMESTAMPING_TX_HARDWARE;
-		if (sock_flag(sk, SOCK_TIMESTAMPING_TX_SOFTWARE))
-			v.val |= SOF_TIMESTAMPING_TX_SOFTWARE;
-		if (sock_flag(sk, SOCK_TIMESTAMPING_RX_HARDWARE))
-			v.val |= SOF_TIMESTAMPING_RX_HARDWARE;
-		if (sock_flag(sk, SOCK_TIMESTAMPING_RX_SOFTWARE))
-			v.val |= SOF_TIMESTAMPING_RX_SOFTWARE;
-		if (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE))
-			v.val |= SOF_TIMESTAMPING_SOFTWARE;
-		if (sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE))
-			v.val |= SOF_TIMESTAMPING_RAW_HARDWARE;
+		v.val = sk->sk_tsflags;
 		break;
 
 	case SO_RCVTIMEO:
diff --git a/net/socket.c b/net/socket.c
index dc0cc5d..255d9b8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -613,9 +613,9 @@ EXPORT_SYMBOL(sock_release);
 void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags)
 {
 	*tx_flags = 0;
-	if (sock_flag(sk, SOCK_TIMESTAMPING_TX_HARDWARE))
+	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_HARDWARE)
 		*tx_flags |= SKBTX_HW_TSTAMP;
-	if (sock_flag(sk, SOCK_TIMESTAMPING_TX_SOFTWARE))
+	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_SOFTWARE)
 		*tx_flags |= SKBTX_SW_TSTAMP;
 	if (sock_flag(sk, SOCK_WIFI_STATUS))
 		*tx_flags |= SKBTX_WIFI_STATUS;
@@ -723,12 +723,12 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	}
 
 	memset(&tss, 0, sizeof(tss));
-	if ((sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
+	if ((sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE ||
 	     skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP) &&
 	    ktime_to_timespec_cond(skb->tstamp, tss.ts + 0))
 		empty = 0;
 	if (shhwtstamps &&
-	    sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE) &&
+	    (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
 	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2))
 		empty = 0;
 	if (!empty)
-- 
2.0.0.526.g5318336
