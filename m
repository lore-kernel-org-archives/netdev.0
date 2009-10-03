From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH] TCPCT+1: initial SYN exchange with SYNACK data
Date: Sat, 03 Oct 2009 14:33:41 -0400
Message-ID: <4AC79905.1030904@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030207070908090802020206"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:6067 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584AbZJCSew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2009 14:34:52 -0400
Received: by qw-out-2122.google.com with SMTP id 3so726934qwe.37
        for <netdev@vger.kernel.org>; Sat, 03 Oct 2009 11:33:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030207070908090802020206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This is a straightforward re-implementation of an earlier (year-old) patch
that no longer applies cleanly, with permission of the original author
(Adam Langley).  The patch was previously reviewed:

   http://thread.gmane.org/gmane.linux.network/102586

The principle difference is using a TCP option to carry the cookie nonce,
instead of a user configured offset in the data.  This is more flexible and
less subject to user configuration error.  Such a cookie option has been
suggested for many years, and is also useful without SYN data, allowing
several related concepts to use the same extension option.

   "Re: SYN floods (was: does history repeat itself?)", September 9, 1996.
   http://www.merit.net/mail.archives/nanog/1996-09/msg00235.html

   "Re: what a new TCP header might look like", May 12, 1998.
   ftp://ftp.isi.edu/end2end/end2end-interest-1998.mail

As suggested, the CONFIG_ was replaced by a sysctl (tcp_cookie_size) to
turn on and off the cookie option default globally.

These functions will also be used in subsequent patches that implement
additional features.
---
  include/linux/tcp.h        |   92 +++++++++++++++++--
  include/net/tcp.h          |   48 +++++++++-
  net/ipv4/sysctl_net_ipv4.c |    8 ++
  net/ipv4/tcp.c             |   97 +++++++++++++++++++-
  net/ipv4/tcp_input.c       |   38 ++++++++-
  net/ipv4/tcp_ipv4.c        |   54 ++++++++++-
  net/ipv4/tcp_minisocks.c   |   32 +++++-
  net/ipv4/tcp_output.c      |  220 +++++++++++++++++++++++++++++++++++++++++---
  net/ipv6/tcp_ipv6.c        |   35 +++++++-
  9 files changed, 580 insertions(+), 44 deletions(-)


--------------030207070908090802020206
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="tcpct+1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcpct+1.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 61723a7..bdd1a7f 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -96,6 +96,7 @@ enum {
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
 #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
+#define TCP_COOKIE_DATA		15	/* TCP Cookie Transactions extension */
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -170,6 +171,33 @@ struct tcp_md5sig {
 	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
 };
 
+/* for TCP_COOKIE_DATA socket option */
+#define TCP_COOKIE_MAX		16		/* 128-bits */
+#define TCP_COOKIE_MIN		 8		/*  64-bits */
+#define TCP_COOKIE_PAIR_SIZE	(2*TCP_COOKIE_MAX)
+
+#define TCP_S_DATA_MAX		64U		/* after TCP+IP options */
+#define TCP_S_DATA_MSS_DEFAULT	536U		/* default MSS (RFC1122) */
+
+/* Flags for both getsockopt and setsockopt */
+#define TCP_COOKIE_IN_ALWAYS	(1 << 0)	/* Discard SYN without cookie */
+#define TCP_COOKIE_OUT_NEVER	(1 << 1)	/* Prohibit outgoing cookies.
+						   Supercedes the others. */
+
+/* Flags for getsockopt */
+#define TCP_S_DATA_IN		(1 << 2)	/* Was data received? */
+#define TCP_S_DATA_OUT		(1 << 3)	/* Was data sent? */
+
+/* TCP Cookie Transactions data */
+struct tcp_cookie_data {
+	__u16	tcpcd_flags;			/* see above */
+	__u8	__tcpcd_pad1;			/* zero */
+	__u8	tcpcd_cookie_desired;		/* bytes */
+	__u16	tcpcd_s_data_desired;		/* bytes of variable data */
+	__u16	tcpcd_used;			/* bytes in value */
+	__u8	tcpcd_value[TCP_S_DATA_MSS_DEFAULT];
+};
+
 #ifdef __KERNEL__
 
 #include <linux/skbuff.h>
@@ -210,33 +238,53 @@ struct tcp_options_received {
 	u32	ts_recent;	/* Time stamp to echo next		*/
 	u32	rcv_tsval;	/* Time stamp value             	*/
 	u32	rcv_tsecr;	/* Time stamp echo reply        	*/
-	u16 	saw_tstamp : 1,	/* Saw TIMESTAMP on last packet		*/
+	u32 	saw_tstamp : 1,	/* Saw TIMESTAMP on last packet		*/
 		tstamp_ok : 1,	/* TIMESTAMP seen on SYN packet		*/
 		dsack : 1,	/* D-SACK is scheduled			*/
 		wscale_ok : 1,	/* Wscale seen on SYN packet		*/
 		sack_ok : 4,	/* SACK seen on SYN packet		*/
 		snd_wscale : 4,	/* Window scaling received from sender	*/
-		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
-/*	SACKs data	*/
+		rcv_wscale : 4,	/* Window scaling to send to receiver	*/
+		extend_ok:1;	/* Cookie{less,pair} option seen	*/
+	u8	*cookie_copy;	/* temporary pointer			*/
+	u8	cookie_size;	/* bytes in copy			*/
 	u8	num_sacks;	/* Number of SACK blocks		*/
-	u16	user_mss;  	/* mss requested by user in ioctl */
+	u16	user_mss;	/* mss requested by user in ioctl	*/
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
 };
 
+static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
+{
+	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
+	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+	rx_opt->cookie_size = rx_opt->extend_ok = 0;
+}
+
 /* This is the max number of SACKS that we'll generate and process. It's safe
  * to increse this, although since:
  *   size = TCPOLEN_SACK_BASE_ALIGNED (4) + n * TCPOLEN_SACK_PERBLOCK (8)
  * only four options will fit in a standard TCP header */
 #define TCP_NUM_SACKS 4
 
+struct tcp_cookie_pair;
+struct tcp_s_data_payload;
+
 struct tcp_request_sock {
 	struct inet_request_sock 	req;
 #ifdef CONFIG_TCP_MD5SIG
 	/* Only used by TCP MD5 Signature so far. */
 	const struct tcp_request_sock_ops *af_specific;
 #endif
-	u32			 	rcv_isn;
-	u32			 	snt_isn;
+	u32				rcv_isn;
+	u32				snt_isn;
+
+	/* Cookie Transactions */
+	u8				*cookie_copy;	/* temporary pointer */
+	u8				cookie_size;	/* bytes in copy */
+	u8				s_data_in:1,
+					s_data_out:1,
+					cookie_in_always:1,
+					cookie_out_never:1;
 };
 
 static inline struct tcp_request_sock *tcp_rsk(const struct request_sock *req)
@@ -406,6 +454,32 @@ struct tcp_sock {
 /* TCP MD5 Signature Option information */
 	struct tcp_md5sig_info	*md5sig_info;
 #endif
+
+	/* If s_data_desired > 0 and s_data_payload is non-NULL, then this
+	 * object holds a reference to it (s_data_payload->kref)
+	 */
+	struct tcp_s_data_payload	*s_data_payload;
+
+	/* When the cookie options are generated and exchanged, then this
+	 * object holds a reference to them (cookie_pair->kref)
+	 */
+	struct tcp_cookie_pair	  	*cookie_pair;
+
+	/* If s_data_payload is non-NULL, then this holds a copy of
+	 * s_data_payload->tsdpl_size.  Otherwise, this holds the user
+	 * specified tcpcd_s_data_desired (variable data).
+	 */
+	u16				s_data_desired;	/* bytes */
+
+	/* Initially, this holds the user specified tcpcd_cookie_desired.
+	 * Zero indicates default (sysctl_tcp_cookie_size).  After the
+	 * option has been exchanged, this holds the actual size.
+	 */
+	u8				cookie_desired;	/* bytes */
+	u8				s_data_in:1,
+					s_data_out:1,
+					cookie_in_always:1,
+					cookie_out_never:1;
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
@@ -424,6 +498,10 @@ struct tcp_timewait_sock {
 	u16			  tw_md5_keylen;
 	u8			  tw_md5_key[TCP_MD5SIG_MAXKEYLEN];
 #endif
+	/* Few sockets in timewait have cookies; in that case, then this
+	 * object holds a reference to it (tw_cookie_pair->kref)
+	 */
+	struct tcp_cookie_pair	  *tw_cookie_pair;
 };
 
 static inline struct tcp_timewait_sock *tcp_twsk(const struct sock *sk)
@@ -431,6 +509,6 @@ static inline struct tcp_timewait_sock *tcp_twsk(const struct sock *sk)
 	return (struct tcp_timewait_sock *)sk;
 }
 
-#endif
+#endif	/* __KERNEL__ */
 
 #endif	/* _LINUX_TCP_H */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..7fb2456 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -30,6 +30,7 @@
 #include <linux/dmaengine.h>
 #include <linux/crypto.h>
 #include <linux/cryptohash.h>
+#include <linux/kref.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -167,6 +168,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOPT_SACK             5       /* SACK Block */
 #define TCPOPT_TIMESTAMP	8	/* Better RTT estimations/PAWS */
 #define TCPOPT_MD5SIG		19	/* MD5 Signature (RFC2385) */
+#define TCPOPT_COOKIE		253	/* Cookie extension (experimental) */
 
 /*
  *     TCP option lengths
@@ -177,6 +179,10 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERM      2
 #define TCPOLEN_TIMESTAMP      10
 #define TCPOLEN_MD5SIG         18
+#define TCPOLEN_COOKIE_BASE    2	/* Cookie-less header extension */
+#define TCPOLEN_COOKIE_PAIR    3	/* Cookie pair header extension */
+#define TCPOLEN_COOKIE_MAX     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MAX)
+#define TCPOLEN_COOKIE_MIN     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MIN)
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -237,6 +243,7 @@ extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
+extern int sysctl_tcp_cookie_size;
 
 extern atomic_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
@@ -343,11 +350,6 @@ static inline void tcp_dec_quickack_mode(struct sock *sk,
 
 extern void tcp_enter_quickack_mode(struct sock *sk);
 
-static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
-{
- 	rx_opt->tstamp_ok = rx_opt->sack_ok = rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
-}
-
 #define	TCP_ECN_OK		1
 #define	TCP_ECN_QUEUE_CWR	2
 #define	TCP_ECN_DEMAND_CWR	4
@@ -1480,6 +1482,42 @@ struct tcp_request_sock_ops {
 #endif
 };
 
+/**
+ * This structure contains variable data that is to be included in the
+ * cookie option and compared with later incoming segments.
+ *
+ * A tcp_sock contains a pointer to the current value, and this is cloned to
+ * the tcp_timewait_sock.
+ */
+struct tcp_cookie_pair {
+	struct kref	kref;
+	/* 32-bit aligned for faster comparisons? */
+	u8		tcpcp_data[TCP_COOKIE_PAIR_SIZE];
+	u8		tcpcp_size;	/* of the cookie pair */
+};
+
+static inline void tcp_cookie_pair_release(struct kref *kref)
+{
+	kfree(container_of(kref, struct tcp_cookie_pair, kref));
+}
+
+/**
+ * This structure contains constant data that is to be included in the
+ * payload of SYN or SYNACK segments when the cookie option is present.
+ *
+ * This structure is immutable (save for the reference counter) once created.
+ */
+struct tcp_s_data_payload {
+	struct kref	kref;
+	u16		tsdpl_size;	/* of the trailing payload */
+	u8		tsdpl_data[0];	/* trailing payload */
+};
+
+static inline void tcp_s_data_payload_release(struct kref *kref)
+{
+	kfree(container_of(kref, struct tcp_s_data_payload, kref));
+}
+
 extern void tcp_v4_init(void);
 extern void tcp_init(void);
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 2dcf04d..3422c54 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -714,6 +714,14 @@ static struct ctl_table ipv4_table[] = {
 	},
 	{
 		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "tcp_cookie_size",
+		.data		= &sysctl_tcp_cookie_size,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
 		.maxlen		= sizeof(sysctl_udp_mem),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5a15e76..87f4939 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2039,8 +2039,8 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	int val;
 	int err = 0;
 
-	/* This is a string value all the others are int's */
-	if (optname == TCP_CONGESTION) {
+	/* These are data/string values, all the others are ints */
+	if (TCP_CONGESTION == optname) {
 		char name[TCP_CA_NAME_MAX];
 
 		if (optlen < 1)
@@ -2056,6 +2056,61 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		err = tcp_set_congestion_control(sk, name);
 		release_sock(sk);
 		return err;
+	} else if (TCP_COOKIE_DATA == optname) {
+		struct tcp_cookie_data tcd;
+		struct tcp_s_data_payload *tsdplp;
+
+		if (optlen < sizeof(tcd)) {
+			return -EINVAL;
+		}
+		if (copy_from_user(&tcd, optval, sizeof(tcd))) {
+			return -EFAULT;
+		}
+		if (0 == tcd.tcpcd_cookie_desired) {
+			/* default to global value */
+		} else if ((0x1 & tcd.tcpcd_cookie_desired)
+			|| TCP_COOKIE_MAX < tcd.tcpcd_cookie_desired
+			|| TCP_COOKIE_MIN > tcd.tcpcd_cookie_desired) {
+			return -EINVAL;
+		}
+
+		lock_sock(sk);
+		tp->cookie_in_always = (TCP_COOKIE_IN_ALWAYS & tcd.tcpcd_flags);
+		tp->cookie_out_never = (TCP_COOKIE_OUT_NEVER & tcd.tcpcd_flags);
+		tp->cookie_desired = tcd.tcpcd_cookie_desired;
+
+		/* If there's no constant data, save tcpcd_s_data_desired.
+		 * Otherwise, copy the length of the constant data instead.
+		 */
+		if (0 == tcd.tcpcd_used) {
+			if (NULL != tp->s_data_payload) {
+				kref_put(&tp->s_data_payload->kref,
+					 tcp_s_data_payload_release);
+				tp->s_data_payload = NULL;
+			}
+			tp->s_data_desired = tcd.tcpcd_s_data_desired;
+		} else if (sizeof(tcd.tcpcd_value) < tcd.tcpcd_used) {
+			err = -EINVAL;
+		} else if (NULL != (tsdplp =
+				    kmalloc(sizeof(struct tcp_s_data_payload)
+					    + tcd.tcpcd_used,
+					    GFP_ATOMIC))) {
+			if (unlikely(tp->s_data_payload)) {
+				kref_put(&tp->s_data_payload->kref,
+					 tcp_s_data_payload_release);
+			}
+			kref_init(&tsdplp->kref);
+			memcpy(tsdplp->tsdpl_data, tcd.tcpcd_value,
+			       tcd.tcpcd_used);
+			tsdplp->tsdpl_size =
+			tp->s_data_desired = tcd.tcpcd_used;
+			tp->s_data_payload = tsdplp;
+		} else {
+			err = -ENOMEM;
+		}
+
+		release_sock(sk);
+		return err;
 	}
 
 	if (optlen < sizeof(int))
@@ -2318,6 +2373,44 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	if (get_user(len, optlen))
 		return -EFAULT;
 
+	/* These are data/string values, all the others are ints */
+	if (TCP_COOKIE_DATA == optname) {
+		struct tcp_cookie_data tcd;
+		struct tcp_cookie_pair *tcpcpp = tp->cookie_pair;
+
+		if (len < sizeof(tcd)) {
+			return -EINVAL;
+		}
+
+		memset(&tcd, 0, sizeof(tcd));
+		tcd.tcpcd_flags = (tp->s_data_in ? TCP_S_DATA_IN : 0)
+				| (tp->s_data_out ? TCP_S_DATA_OUT : 0)
+				| (tp->cookie_in_always ? TCP_COOKIE_IN_ALWAYS : 0)
+				| (tp->cookie_out_never ? TCP_COOKIE_OUT_NEVER : 0);
+
+		tcd.tcpcd_cookie_desired = tp->cookie_desired;
+		tcd.tcpcd_s_data_desired = tp->s_data_desired;
+
+		if (NULL != tcpcpp) {
+			/* Cookie(s) saved, return as nonce */
+			if (sizeof(tcd.tcpcd_value) < tcpcpp->tcpcp_size) {
+				/* impossible? */
+				return -EINVAL;
+			}
+			memcpy(&tcd.tcpcd_value[0], &tcpcpp->tcpcp_data[0],
+			       tcpcpp->tcpcp_size);
+			tcd.tcpcd_used = tcpcpp->tcpcp_size;
+		}
+
+		if (copy_to_user(optval, &tcd, sizeof(tcd))) {
+			return -EFAULT;
+		}
+		if (put_user(sizeof(tcd), optlen)) {
+			return -EFAULT;
+		}
+		return 0;
+	}
+
 	len = min_t(unsigned int, len, sizeof(int));
 
 	if (len < 0)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d86784b..88ffca9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3782,6 +3782,21 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 				 */
 				break;
 #endif
+			case TCPOPT_COOKIE:
+				/* This option carries 3 different lengths.
+				 */
+				if (TCPOLEN_COOKIE_MAX >= opsize
+				 && TCPOLEN_COOKIE_MIN <= opsize) {
+					opt_rx->cookie_size =
+						opsize - TCPOLEN_COOKIE_BASE;
+					opt_rx->cookie_copy = ptr;
+					opt_rx->extend_ok = 1;
+				} else if (TCPOLEN_COOKIE_PAIR == opsize) {
+					/* not yet implemented */
+				} else if (TCPOLEN_COOKIE_BASE == opsize) {
+					/* not yet implemented */
+				}
+				break;
 			}
 
 			ptr += opsize-2;
@@ -5364,6 +5379,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int saved_clamp = tp->rx_opt.mss_clamp;
+	bool s_data_queued = false;
 
 	tcp_parse_options(skb, &tp->rx_opt, 0);
 
@@ -5462,6 +5478,23 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 * Change state from SYN-SENT only after copied_seq
 		 * is initialized. */
 		tp->copied_seq = tp->rcv_nxt;
+
+		/* If the cookie extension option is present, and there's
+		 * some incoming transaction data, queue it.
+		 */
+		if (tp->rx_opt.extend_ok
+		 && skb->len > (th->doff << 2)) {
+			__skb_pull(skb, th->doff << 2);
+			__skb_queue_tail(&sk->sk_receive_queue, skb);
+			skb_set_owner_r(skb, sk);
+			sk->sk_data_ready(sk, 0);
+			s_data_queued = true;
+			tp->s_data_in = 1; /* true */
+			tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+			tp->rcv_wup = TCP_SKB_CB(skb)->end_seq;
+			tp->copied_seq = TCP_SKB_CB(skb)->seq + 1;
+		}
+
 		smp_mb();
 		tcp_set_state(sk, TCP_ESTABLISHED);
 
@@ -5513,11 +5546,14 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 						  TCP_DELACK_MAX, TCP_RTO_MAX);
 
 discard:
-			__kfree_skb(skb);
+			if (!s_data_queued)
+				__kfree_skb(skb);
 			return 0;
 		} else {
 			tcp_send_ack(sk);
 		}
+		if (s_data_queued)
+			return 0;
 		return -1;
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7cda24b..67eb529 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -217,7 +217,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (inet->opt)
 		inet_csk(sk)->icsk_ext_hdr_len = inet->opt->optlen;
 
-	tp->rx_opt.mss_clamp = 536;
+	tp->rx_opt.mss_clamp = TCP_MIN_RCVMSS;
 
 	/* Socket identity is still unknown (sport may be zero).
 	 * However we set state to SYN-SENT and not releasing socket
@@ -1210,9 +1210,11 @@ static struct timewait_sock_ops tcp_timewait_sock_ops = {
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
-	struct inet_request_sock *ireq;
+	u8 bakery[TCP_COOKIE_MAX];
 	struct tcp_options_received tmp_opt;
+	struct inet_request_sock *ireq;
 	struct request_sock *req;
+	struct tcp_sock *tp = tcp_sk(sk);
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
 	__u32 isn = TCP_SKB_CB(skb)->when;
@@ -1257,16 +1259,37 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 #endif
 
 	tcp_clear_options(&tmp_opt);
-	tmp_opt.mss_clamp = 536;
-	tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
+	tmp_opt.mss_clamp = TCP_MIN_RCVMSS;
+	tmp_opt.user_mss  = tp->rx_opt.user_mss;
 
 	tcp_parse_options(skb, &tmp_opt, 0);
 
+	if (tmp_opt.extend_ok
+	 && tmp_opt.saw_tstamp
+	 && !tp->cookie_out_never
+	 && (0 < tp->cookie_desired || 0 < sysctl_tcp_cookie_size)) {
+#ifdef CONFIG_SYN_COOKIES
+		want_cookie = 0;	/* not our kind of cookie */
+#endif
+		tcp_rsk(req)->cookie_out_never = 0;
+		tcp_rsk(req)->cookie_copy = bakery;
+		tcp_rsk(req)->cookie_size = tmp_opt.cookie_size;
+
+		/* secret recipe not yet implemented */
+		get_random_bytes(bakery, tmp_opt.cookie_size);
+	} else if (!tp->cookie_in_always) {
+		/* redundant indications, but ensure initialization. */
+		tcp_rsk(req)->cookie_out_never = 1;
+		tcp_rsk(req)->cookie_size = 0;
+	} else {
+		goto drop_and_free;
+	}
+	tcp_rsk(req)->cookie_in_always = tp->cookie_in_always;
+
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
 
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
-
 	tcp_openreq_init(req, &tmp_opt, skb);
 
 	ireq = inet_rsk(req);
@@ -1810,7 +1833,7 @@ static int tcp_v4_init_sock(struct sock *sk)
 	 */
 	tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
 	tp->snd_cwnd_clamp = ~0;
-	tp->mss_cache = 536;
+	tp->mss_cache = TCP_MIN_RCVMSS;
 
 	tp->reordering = sysctl_tcp_reordering;
 	icsk->icsk_ca_ops = &tcp_init_congestion_ops;
@@ -1826,6 +1849,14 @@ static int tcp_v4_init_sock(struct sock *sk)
 	tp->af_specific = &tcp_sock_ipv4_specific;
 #endif
 
+/* For grep, in order of appearance:
+ *	tp->s_data_payload = NULL;
+ *	tp->cookie_pair = NULL;
+ *	tp->s_data_desired = tp->cookie_desired = 0;
+ *	tp->s_data_in = tp->s_data_out = 0;
+ *	tp->cookie_in_always = tp->cookie_out_never = 0;
+ */
+
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
@@ -1879,6 +1910,17 @@ void tcp_v4_destroy_sock(struct sock *sk)
 		sk->sk_sndmsg_page = NULL;
 	}
 
+	if (NULL != tp->s_data_payload) {
+		kref_put(&tp->s_data_payload->kref,
+			 tcp_s_data_payload_release);
+		tp->s_data_payload = NULL;
+	}
+	if (NULL != tp->cookie_pair) {
+		kref_put(&tp->cookie_pair->kref,
+			 tcp_cookie_pair_release);
+		tp->cookie_pair = NULL;
+	}
+
 	percpu_counter_dec(&tcp_sockets_allocated);
 }
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 624c3c9..c38e901 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -375,6 +375,13 @@ static inline void TCP_ECN_openreq_child(struct tcp_sock *tp,
 	tp->ecn_flags = inet_rsk(req)->ecn_ok ? TCP_ECN_OK : 0;
 }
 
+static inline int tcp_s_data_size(const struct tcp_sock *tp)
+{
+	return (0 < tp->s_data_desired && NULL != tp->s_data_payload)
+		? tp->s_data_payload->tsdpl_size
+		: 0;
+}
+
 /* This is not only more efficient than what we used to do, it eliminates
  * a lot of code duplication between IPv4/IPv6 SYN recv processing. -DaveM
  *
@@ -394,9 +401,12 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		/* Now setup tcp_sock */
 		newtp = tcp_sk(newsk);
 		newtp->pred_flags = 0;
-		newtp->rcv_wup = newtp->copied_seq = newtp->rcv_nxt = treq->rcv_isn + 1;
-		newtp->snd_sml = newtp->snd_una = newtp->snd_nxt = treq->snt_isn + 1;
-		newtp->snd_up = treq->snt_isn + 1;
+
+		newtp->rcv_wup = newtp->copied_seq =
+		newtp->rcv_nxt = treq->rcv_isn + 1;
+
+		newtp->snd_sml = newtp->snd_una = newtp->snd_nxt =
+		newtp->snd_up = treq->snt_isn + 1 + tcp_s_data_size(tcp_sk(sk));
 
 		tcp_prequeue_init(newtp);
 
@@ -429,8 +439,17 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
 		skb_queue_head_init(&newtp->out_of_order_queue);
-		newtp->write_seq = treq->snt_isn + 1;
-		newtp->pushed_seq = newtp->write_seq;
+		newtp->write_seq = newtp->pushed_seq =
+			treq->snt_isn + 1 + tcp_s_data_size(tcp_sk(sk));
+
+		newtp->s_data_payload = NULL;
+		newtp->cookie_pair = NULL;
+		newtp->s_data_desired = 0;
+		newtp->cookie_desired = treq->cookie_size;
+		newtp->s_data_in = treq->s_data_in;
+		newtp->s_data_out = treq->s_data_out;
+		newtp->cookie_in_always = treq->cookie_in_always;
+		newtp->cookie_out_never = treq->cookie_out_never;
 
 		newtp->rx_opt.saw_tstamp = 0;
 
@@ -596,7 +615,8 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	 * Invalid ACK: reset will be sent by listening socket
 	 */
 	if ((flg & TCP_FLAG_ACK) &&
-	    (TCP_SKB_CB(skb)->ack_seq != tcp_rsk(req)->snt_isn + 1))
+	    (TCP_SKB_CB(skb)->ack_seq != tcp_rsk(req)->snt_isn + 1 +
+					 tcp_s_data_size(tcp_sk(sk))))
 		return sk;
 
 	/* Also, it would be not so bad idea to check rcv_tsecr, which
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5200aab..cd6d388 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -59,6 +59,14 @@ int sysctl_tcp_base_mss __read_mostly = 512;
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
+#ifdef CONFIG_SYSCTL
+/* By default, let the user enable it. */
+int sysctl_tcp_cookie_size __read_mostly = 0;
+#else
+int sysctl_tcp_cookie_size __read_mostly = TCP_COOKIE_MAX;
+#endif
+
+
 /* Account for new data that has been sent to the network. */
 static void tcp_event_new_data_sent(struct sock *sk, struct sk_buff *skb)
 {
@@ -361,6 +369,8 @@ static inline int tcp_urg_mode(const struct tcp_sock *tp)
 #define OPTION_SACK_ADVERTISE	(1 << 0)
 #define OPTION_TS		(1 << 1)
 #define OPTION_MD5		(1 << 2)
+#define OPTION_WSCALE		(1 << 3)
+#define OPTION_COOKIE_EXTENSION	(1 << 4)
 
 struct tcp_out_options {
 	u8 options;		/* bit field of OPTION_* */
@@ -368,8 +378,35 @@ struct tcp_out_options {
 	u8 num_sack_blocks;	/* number of SACK blocks to include */
 	u16 mss;		/* 0 to disable */
 	__u32 tsval, tsecr;	/* need to include OPTION_TS */
+	u8	*cookie_copy;	/* temporary pointer */
+	u8	cookie_size;	/* bytes in copy */
 };
 
+/* The sysctl int routines are generic, so check consistency here.
+ */
+static u8 tcp_cookie_size_check(u8 desired)
+{
+	if (0 < desired) {
+		/* previously specified */
+		return desired;
+	}
+	if (0 == sysctl_tcp_cookie_size) {
+		/* no default specified */
+		return 0;
+	}
+	if (TCP_COOKIE_MIN > sysctl_tcp_cookie_size) {
+		return TCP_COOKIE_MIN;
+	}
+	if (TCP_COOKIE_MAX < sysctl_tcp_cookie_size) {
+		return TCP_COOKIE_MAX;
+	}
+	if (0x1 & sysctl_tcp_cookie_size) {
+		/* 8-bit multiple, illegal, fix it */
+		return (u8)(sysctl_tcp_cookie_size + 0x1);
+	}
+	return (u8)sysctl_tcp_cookie_size;
+}
+
 /* Write previously computed TCP options to the packet.
  *
  * Beware: Something in the Internet is very sensitive to the ordering of
@@ -386,11 +423,22 @@ struct tcp_out_options {
 static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 			      const struct tcp_out_options *opts,
 			      __u8 **md5_hash) {
-	if (unlikely(OPTION_MD5 & opts->options)) {
-		*ptr++ = htonl((TCPOPT_NOP << 24) |
-			       (TCPOPT_NOP << 16) |
-			       (TCPOPT_MD5SIG << 8) |
-			       TCPOLEN_MD5SIG);
+	u8 options = opts->options;	/* mungable copy */
+
+	if (unlikely(OPTION_MD5 & options)) {
+		if (unlikely(OPTION_COOKIE_EXTENSION & options)) {
+			*ptr++ = htonl((TCPOPT_COOKIE << 24) |
+				       (TCPOLEN_COOKIE_BASE << 16) |
+				       (TCPOPT_MD5SIG << 8) |
+				       TCPOLEN_MD5SIG);
+		} else {
+			*ptr++ = htonl((TCPOPT_NOP << 24) |
+				       (TCPOPT_NOP << 16) |
+				       (TCPOPT_MD5SIG << 8) |
+				       TCPOLEN_MD5SIG);
+		}
+		/* larger cookies are incompatible */
+		options &= ~OPTION_COOKIE_EXTENSION;
 		*md5_hash = (__u8 *)ptr;
 		ptr += 4;
 	} else {
@@ -403,12 +451,13 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 			       opts->mss);
 	}
 
-	if (likely(OPTION_TS & opts->options)) {
-		if (unlikely(OPTION_SACK_ADVERTISE & opts->options)) {
+	if (likely(OPTION_TS & options)) {
+		if (unlikely(OPTION_SACK_ADVERTISE & options)) {
 			*ptr++ = htonl((TCPOPT_SACK_PERM << 24) |
 				       (TCPOLEN_SACK_PERM << 16) |
 				       (TCPOPT_TIMESTAMP << 8) |
 				       TCPOLEN_TIMESTAMP);
+			options &= ~OPTION_SACK_ADVERTISE;
 		} else {
 			*ptr++ = htonl((TCPOPT_NOP << 24) |
 				       (TCPOPT_NOP << 16) |
@@ -419,15 +468,48 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		*ptr++ = htonl(opts->tsecr);
 	}
 
-	if (unlikely(OPTION_SACK_ADVERTISE & opts->options &&
-		     !(OPTION_TS & opts->options))) {
+	/* specification requires following timestamp, so do it now.
+	 */
+	if (unlikely(OPTION_COOKIE_EXTENSION & options)) {
+		u8 *cookie_copy = opts->cookie_copy;
+		u8 cookie_size = opts->cookie_size;
+
+		if (unlikely(0x1 & cookie_size)) {
+			/* 8-bit multiple, illegal, ignore */
+			cookie_size = 0;
+		} else if (likely(0x2 & cookie_size)) {
+			__u8 *p = (__u8 *)ptr;
+
+			/* 16-bit multiple */
+			*p++ = TCPOPT_COOKIE;
+			*p++ = TCPOLEN_COOKIE_BASE + cookie_size;
+			*p++ = *cookie_copy++;
+			*p++ = *cookie_copy++;
+			ptr++;
+			cookie_size -= 2;
+		} else {
+			/* 32-bit multiple */
+			*ptr++ = htonl(((TCPOPT_NOP << 24) |
+				        (TCPOPT_NOP << 16) |
+				        (TCPOPT_COOKIE << 8) |
+				        TCPOLEN_COOKIE_BASE) +
+				       cookie_size);
+		}
+
+		if (0 < cookie_size) {
+			memcpy(ptr, cookie_copy, cookie_size);
+			ptr += (cookie_size >> 2);
+		}
+	}
+
+	if (unlikely(OPTION_SACK_ADVERTISE & options)) {
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
 			       (TCPOPT_NOP << 16) |
 			       (TCPOPT_SACK_PERM << 8) |
 			       TCPOLEN_SACK_PERM);
 	}
 
-	if (unlikely(opts->ws)) {
+	if (unlikely(OPTION_WSCALE & options)) {
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
 			       (TCPOPT_WINDOW << 16) |
 			       (TCPOLEN_WINDOW << 8) |
@@ -463,10 +545,16 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 				struct tcp_md5sig_key **md5) {
 	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned size = 0;
+	u8 cookie_size = !tp->cookie_out_never
+			 ? tcp_cookie_size_check(tp->cookie_desired)
+			 : 0;
 
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 = tp->af_specific->md5_lookup(sk, sk);
 	if (*md5) {
+		if (0 != cookie_size) {
+			opts->options |= OPTION_COOKIE_EXTENSION;
+		}
 		opts->options |= OPTION_MD5;
 		size += TCPOLEN_MD5SIG_ALIGNED;
 	}
@@ -494,8 +582,8 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 	}
 	if (likely(sysctl_tcp_window_scaling)) {
 		opts->ws = tp->rx_opt.rcv_wscale;
-		if (likely(opts->ws))
-			size += TCPOLEN_WSCALE_ALIGNED;
+		opts->options |= OPTION_WSCALE;
+		size += TCPOLEN_WSCALE_ALIGNED;
 	}
 	if (likely(sysctl_tcp_sack)) {
 		opts->options |= OPTION_SACK_ADVERTISE;
@@ -503,6 +591,61 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 			size += TCPOLEN_SACKPERM_ALIGNED;
 	}
 
+	/* Having both authentication and cookies for security is redundant,
+	 * and there's certainly not enough room.  Instead, the cookie-less
+	 * variant is proposed above.
+	 *
+	 * Consider the pessimal case with authentication.  The options
+	 * could look like:
+	 *   COOKIE|MD5(20) + MSS(4) + WSCALE(4) + SACK|TS(12) == 40
+	 *
+	 * (Currently, the timestamps && *MD5 test above prevents this.)
+	 *
+	 * Note that timestamps are required by the specification.
+	 *
+	 * Odd numbers of bytes are prohibited by the specification, ensuring
+	 * that the cookie is 16-bit aligned, and the resulting cookie pair is
+	 * 32-bit aligned.
+	 */
+	if (NULL == *md5
+	 && (OPTION_TS & opts->options)
+	 && 0 != cookie_size) {
+		int need = TCPOLEN_COOKIE_BASE + cookie_size;
+		int remaining = MAX_TCP_OPTION_SPACE - size;
+
+		if (!(0x2 & cookie_size)) {
+			/* 32-bit multiple */
+			need += 2; /* NOPs */
+
+			if (need > remaining) {
+				/* try shrinking cookie to fit */
+				cookie_size -= 2;
+				need -= 4;
+			}
+		}
+		while (need > remaining && TCP_COOKIE_MIN <= cookie_size) {
+			cookie_size -= 4;
+			need -= 4;
+		}
+		if (TCP_COOKIE_MIN <= cookie_size) {
+			if (NULL == tp->cookie_pair
+			 && NULL != (tp->cookie_pair =
+				     kmalloc(sizeof(struct tcp_cookie_pair),
+					     GFP_ATOMIC))) {
+				kref_init(&tp->cookie_pair->kref);
+				tp->cookie_pair->tcpcp_size = cookie_size;
+				get_random_bytes(&tp->cookie_pair->tcpcp_data[0],
+						 cookie_size);
+			}
+			if (NULL != tp->cookie_pair) {
+				opts->options |= OPTION_COOKIE_EXTENSION;
+				opts->cookie_copy = &tp->cookie_pair->tcpcp_data[0];
+				opts->cookie_size = cookie_size;
+				tp->cookie_desired = cookie_size; /* remember */
+				size += need;
+			}
+		}
+	}
 	return size;
 }
 
@@ -512,13 +655,19 @@ static unsigned tcp_synack_options(struct sock *sk,
 				   unsigned mss, struct sk_buff *skb,
 				   struct tcp_out_options *opts,
 				   struct tcp_md5sig_key **md5) {
-	unsigned size = 0;
 	struct inet_request_sock *ireq = inet_rsk(req);
+	unsigned size = 0;
+	u8 cookie_size = !tcp_rsk(req)->cookie_out_never
+			 ? tcp_rsk(req)->cookie_size
+			 : 0;
 	char doing_ts;
 
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
 	if (*md5) {
+		if (0 != cookie_size) {
+			opts->options |= OPTION_COOKIE_EXTENSION;
+		}
 		opts->options |= OPTION_MD5;
 		size += TCPOLEN_MD5SIG_ALIGNED;
 	}
@@ -537,8 +686,8 @@ static unsigned tcp_synack_options(struct sock *sk,
 
 	if (likely(ireq->wscale_ok)) {
 		opts->ws = ireq->rcv_wscale;
-		if (likely(opts->ws))
-			size += TCPOLEN_WSCALE_ALIGNED;
+		opts->options |= OPTION_WSCALE;
+		size += TCPOLEN_WSCALE_ALIGNED;
 	}
 	if (likely(doing_ts)) {
 		opts->options |= OPTION_TS;
@@ -552,6 +701,29 @@ static unsigned tcp_synack_options(struct sock *sk,
 			size += TCPOLEN_SACKPERM_ALIGNED;
 	}
 
+	/* Similar rationale to tcp_syn_options() applies here, too.
+	 * If the <SYN> options fit, the same options should fit now!
+	 */
+	if (NULL == *md5
+	 && doing_ts
+	 && 0 != cookie_size) {
+		int need = TCPOLEN_COOKIE_BASE + cookie_size;
+		int remaining = MAX_TCP_OPTION_SPACE - size;
+
+		if (!(0x2 & cookie_size)) {
+			/* 32-bit multiple */
+			need += 2; /* NOPs */
+		}
+		if (need <= remaining) {
+			opts->options |= OPTION_COOKIE_EXTENSION;
+			opts->cookie_copy = tcp_rsk(req)->cookie_copy;
+			opts->cookie_size = cookie_size;
+			size += need;
+		} else {
+			/* There's no error return, so flag it. */
+			tcp_rsk(req)->cookie_out_never = 1;
+		}
+	}
 	return size;
 }
 
@@ -2283,6 +2455,24 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	 */
 	tcp_init_nondata_skb(skb, tcp_rsk(req)->snt_isn,
 			     TCPCB_FLAG_SYN | TCPCB_FLAG_ACK);
+
+	/* If cookies are active, and constant data is available, copy it
+	 * directly from the listening socket.
+	 */
+	if (!tcp_rsk(req)->cookie_out_never
+	 && 0 < tcp_rsk(req)->cookie_size
+	 && 0 < tp->s_data_desired) {
+		const struct tcp_s_data_payload *tsdplp =
+			tp->s_data_payload;
+
+		if (NULL != tsdplp) {
+			u8 *buf = skb_put(skb, tsdplp->tsdpl_size);
+
+			memcpy(buf, tsdplp->tsdpl_data, tsdplp->tsdpl_size);
+			TCP_SKB_CB(skb)->end_seq += tsdplp->tsdpl_size;
+		}
+	}
+
 	th->seq = htonl(TCP_SKB_CB(skb)->seq);
 	th->ack_seq = htonl(tcp_rsk(req)->rcv_isn + 1);
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 21d100b..af33758 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1159,11 +1159,12 @@ static struct sock *tcp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
  */
 static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
+	u8 bakery[TCP_COOKIE_MAX];
+	struct tcp_options_received tmp_opt;
 	struct inet6_request_sock *treq;
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct tcp_options_received tmp_opt;
-	struct tcp_sock *tp = tcp_sk(sk);
 	struct request_sock *req = NULL;
+	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 isn = TCP_SKB_CB(skb)->when;
 #ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
@@ -1205,6 +1206,28 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	tcp_parse_options(skb, &tmp_opt, 0);
 
+	if (tmp_opt.extend_ok
+	 && tmp_opt.saw_tstamp
+	 && !tp->cookie_out_never
+	 && (0 < tp->cookie_desired || 0 < sysctl_tcp_cookie_size)) {
+#ifdef CONFIG_SYN_COOKIES
+		want_cookie = 0;	/* not our kind of cookie */
+#endif
+		tcp_rsk(req)->cookie_out_never = 0;
+		tcp_rsk(req)->cookie_copy = bakery;
+		tcp_rsk(req)->cookie_size = tmp_opt.cookie_size;
+
+		/* secret recipe not yet implemented */
+		get_random_bytes(bakery, tmp_opt.cookie_size);
+	} else if (!tp->cookie_in_always) {
+		/* redundant indications, but ensure initialization. */
+		tcp_rsk(req)->cookie_out_never = 1;
+		tcp_rsk(req)->cookie_size = 0;
+	} else {
+		goto drop;
+	}
+	tcp_rsk(req)->cookie_in_always = tp->cookie_in_always;
+
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
 
@@ -1864,6 +1887,14 @@ static int tcp_v6_init_sock(struct sock *sk)
 	tp->af_specific = &tcp_sock_ipv6_specific;
 #endif
 
+/* For grep, in order of appearance:
+ *	tp->s_data_payload = NULL;
+ *	tp->cookie_pair = NULL;
+ *	tp->s_data_desired = tp->cookie_desired = 0;
+ *	tp->s_data_in = tp->s_data_out = 0;
+ *	tp->cookie_in_always = tp->cookie_out_never = 0;
+ */
+
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
-- 
1.6.0.4


--------------030207070908090802020206--
