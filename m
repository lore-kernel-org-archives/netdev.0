From: Willem de Bruijn <willemb@google.com>
Subject: [net-next 4/4] net: remove deprecated syststamp timestamp
Date: Fri, 25 Jul 2014 18:01:32 -0400
Message-ID: <1406325692-616-5-git-send-email-willemb@google.com>
References: <1406325692-616-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	kreese@caviumnetworks.com, ddaney@caviumnetworks.com,
	dborkman@redhat.com, jdmason@kudzu.us,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:51882 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbaGYWBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 18:01:45 -0400
Received: by mail-vc0-f201.google.com with SMTP id hu12so826679vcb.4
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 15:01:44 -0700 (PDT)
In-Reply-To: <1406325692-616-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SO_TIMESTAMPING API defines three types of timestamps: software,
hardware in raw format (hwtstamp) and hardware converted to system
format (syststamp). The last has been deprecated in favor of combining
hwtstamp with a PTP clock driver. There are no active users in the
kernel.

The option was device driver dependent. If set, but without hardware
support, the correct behavior is to return zero in the relevant field
in the SCM_TIMESTAMPING ancillary message. Without device drivers
implementing the option, this field is effectively always zero.

Remove the internal plumbing to dissuage new drivers from implementing
the feature. Keep the SOF_TIMESTAMPING_SYS_HARDWARE flag, however, to
avoid breaking existing applications that request the timestamp.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 Documentation/networking/timestamping.txt            | 12 ++----------
 Documentation/networking/timestamping/timestamping.c |  7 +------
 include/linux/skbuff.h                               | 14 +-------------
 include/net/sock.h                                   | 11 +++--------
 net/core/sock.c                                      |  4 ----
 net/socket.c                                         | 12 ++++--------
 6 files changed, 11 insertions(+), 49 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index 8b4ad80..897f942 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -88,15 +88,8 @@ hwtimeraw is the original hardware time stamp. Filled in if
 SOF_TIMESTAMPING_RAW_HARDWARE is set. No assumptions about its
 relation to system time should be made.
 
-hwtimetrans is the hardware time stamp transformed so that it
-corresponds as good as possible to system time. This correlation is
-not perfect; as a consequence, sorting packets received via different
-NICs by their hwtimetrans may differ from the order in which they were
-received. hwtimetrans may be non-monotonic even for the same NIC.
-Filled in if SOF_TIMESTAMPING_SYS_HARDWARE is set. Requires support
-by the network device and will be empty without that support. This
-field is DEPRECATED. Only one driver computes this value. New device
-drivers must leave this zero. Instead, they can expose the hardware
+hwtimetrans is always zero. This field is deprecated. It used to hold
+hw timestamps converted to system time. Instead, expose the hardware
 clock device on the NIC directly as a HW PTP clock source, to allow
 time conversion in userspace and optionally synchronize system time
 with a userspace PTP stack such as linuxptp. For the PTP clock API,
@@ -191,7 +184,6 @@ struct skb_shared_hwtstamps {
 	 * since arbitrary point in time
 	 */
 	ktime_t	hwtstamp;
-	ktime_t	syststamp; /* hwtstamp transformed to system time base */
 };
 
 Time stamps for outgoing packets are to be generated as follows:
diff --git a/Documentation/networking/timestamping/timestamping.c b/Documentation/networking/timestamping/timestamping.c
index 8ba82bf..5cdfd74 100644
--- a/Documentation/networking/timestamping/timestamping.c
+++ b/Documentation/networking/timestamping/timestamping.c
@@ -76,7 +76,6 @@ static void usage(const char *error)
 	       "  SOF_TIMESTAMPING_RX_HARDWARE - hardware time stamping of incoming packets\n"
 	       "  SOF_TIMESTAMPING_RX_SOFTWARE - software fallback for incoming packets\n"
 	       "  SOF_TIMESTAMPING_SOFTWARE - request reporting of software time stamps\n"
-	       "  SOF_TIMESTAMPING_SYS_HARDWARE - request reporting of transformed HW time stamps\n"
 	       "  SOF_TIMESTAMPING_RAW_HARDWARE - request reporting of raw HW time stamps\n"
 	       "  SIOCGSTAMP - check last socket time stamp\n"
 	       "  SIOCGSTAMPNS - more accurate socket time stamp\n");
@@ -202,9 +201,7 @@ static void printpacket(struct msghdr *msg, int res,
 				       (long)stamp->tv_sec,
 				       (long)stamp->tv_nsec);
 				stamp++;
-				printf("HW transformed %ld.%09ld ",
-				       (long)stamp->tv_sec,
-				       (long)stamp->tv_nsec);
+				/* skip deprecated HW transformed */
 				stamp++;
 				printf("HW raw %ld.%09ld",
 				       (long)stamp->tv_sec,
@@ -361,8 +358,6 @@ int main(int argc, char **argv)
 			so_timestamping_flags |= SOF_TIMESTAMPING_RX_SOFTWARE;
 		else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_SOFTWARE"))
 			so_timestamping_flags |= SOF_TIMESTAMPING_SOFTWARE;
-		else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_SYS_HARDWARE"))
-			so_timestamping_flags |= SOF_TIMESTAMPING_SYS_HARDWARE;
 		else if (!strcasecmp(argv[i], "SOF_TIMESTAMPING_RAW_HARDWARE"))
 			so_timestamping_flags |= SOF_TIMESTAMPING_RAW_HARDWARE;
 		else
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b613557..281dece 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -210,20 +210,9 @@ static inline void skb_frag_size_sub(skb_frag_t *frag, int delta)
  * struct skb_shared_hwtstamps - hardware time stamps
  * @hwtstamp:	hardware time stamp transformed into duration
  *		since arbitrary point in time
- * @syststamp:	hwtstamp transformed to system time base (deprecated)
  *
  * Software time stamps generated by ktime_get_real() are stored in
- * skb->tstamp. The relation between the different kinds of time
- * stamps is as follows:
- *
- * syststamp and tstamp can be compared against each other in
- * arbitrary combinations.  The accuracy of a
- * syststamp/tstamp/"syststamp from other device" comparison is
- * limited by the accuracy of the transformation into system time
- * base. This depends on the device driver and its underlying
- * hardware. The syststamp implementation is deprecated in favor
- * of hwtstamps and hw PTP clock sources exposed directly to
- * userspace.
+ * skb->tstamp.
  *
  * hwtstamps can only be compared against other hwtstamps from
  * the same device.
@@ -233,7 +222,6 @@ static inline void skb_frag_size_sub(skb_frag_t *frag, int delta)
  */
 struct skb_shared_hwtstamps {
 	ktime_t	hwtstamp;
-	ktime_t	syststamp;
 };
 
 /* Definitions for tx_flags in struct skb_shared_info */
diff --git a/include/net/sock.h b/include/net/sock.h
index 7207733..b91c886 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -707,7 +707,6 @@ enum sock_flags {
 	SOCK_TIMESTAMPING_RX_SOFTWARE,  /* %SOF_TIMESTAMPING_RX_SOFTWARE */
 	SOCK_TIMESTAMPING_SOFTWARE,     /* %SOF_TIMESTAMPING_SOFTWARE */
 	SOCK_TIMESTAMPING_RAW_HARDWARE, /* %SOF_TIMESTAMPING_RAW_HARDWARE */
-	SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SOF_TIMESTAMPING_SYS_HARDWARE */
 	SOCK_FASYNC, /* fasync() active */
 	SOCK_RXQ_OVFL,
 	SOCK_ZEROCOPY, /* buffers from userspace */
@@ -2166,16 +2165,13 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 	 * - software time stamp available and wanted
 	 *   (SOCK_TIMESTAMPING_SOFTWARE)
 	 * - hardware time stamps available and wanted
-	 *   (SOCK_TIMESTAMPING_SYS_HARDWARE or
-	 *   SOCK_TIMESTAMPING_RAW_HARDWARE)
+	 *   SOCK_TIMESTAMPING_RAW_HARDWARE
 	 */
 	if (sock_flag(sk, SOCK_RCVTSTAMP) ||
 	    sock_flag(sk, SOCK_TIMESTAMPING_RX_SOFTWARE) ||
 	    (kt.tv64 && sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE)) ||
 	    (hwtstamps->hwtstamp.tv64 &&
-	     sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE)) ||
-	    (hwtstamps->syststamp.tv64 &&
-	     sock_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE)))
+	     sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE)))
 		__sock_recv_timestamp(msg, sk, skb);
 	else
 		sk->sk_stamp = kt;
@@ -2193,8 +2189,7 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 #define FLAGS_TS_OR_DROPS ((1UL << SOCK_RXQ_OVFL)			| \
 			   (1UL << SOCK_RCVTSTAMP)			| \
 			   (1UL << SOCK_TIMESTAMPING_SOFTWARE)		| \
-			   (1UL << SOCK_TIMESTAMPING_RAW_HARDWARE)	| \
-			   (1UL << SOCK_TIMESTAMPING_SYS_HARDWARE))
+			   (1UL << SOCK_TIMESTAMPING_RAW_HARDWARE))
 
 	if (sk->sk_flags & FLAGS_TS_OR_DROPS)
 		__sock_recv_ts_and_drops(msg, sk, skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index ca9b651..134291d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -862,8 +862,6 @@ set_rcvbuf:
 					       (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE));
 		sock_valbool_flag(sk, SOCK_TIMESTAMPING_SOFTWARE,
 				  val & SOF_TIMESTAMPING_SOFTWARE);
-		sock_valbool_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE,
-				  val & SOF_TIMESTAMPING_SYS_HARDWARE);
 		sock_valbool_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE,
 				  val & SOF_TIMESTAMPING_RAW_HARDWARE);
 		break;
@@ -1102,8 +1100,6 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 			v.val |= SOF_TIMESTAMPING_RX_SOFTWARE;
 		if (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE))
 			v.val |= SOF_TIMESTAMPING_SOFTWARE;
-		if (sock_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE))
-			v.val |= SOF_TIMESTAMPING_SYS_HARDWARE;
 		if (sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE))
 			v.val |= SOF_TIMESTAMPING_RAW_HARDWARE;
 		break;
diff --git a/net/socket.c b/net/socket.c
index abf56b2..d8222c0 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -725,14 +725,10 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	if (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) &&
 	    ktime_to_timespec_cond(skb->tstamp, ts + 0))
 		empty = 0;
-	if (shhwtstamps) {
-		if (sock_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE) &&
-		    ktime_to_timespec_cond(shhwtstamps->syststamp, ts + 1))
-			empty = 0;
-		if (sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE) &&
-		    ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts + 2))
-			empty = 0;
-	}
+	if (shhwtstamps &&
+	    sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE) &&
+	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts + 2))
+		empty = 0;
 	if (!empty)
 		put_cmsg(msg, SOL_SOCKET,
 			 SCM_TIMESTAMPING, sizeof(ts), &ts);
-- 
2.0.0.526.g5318336
