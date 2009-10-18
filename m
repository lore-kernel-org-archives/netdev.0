From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH 4/4 resent] TCPCT part 1d: initial SYN exchange
 with SYNACK data
Date: Sun, 18 Oct 2009 12:28:02 -0400
Message-ID: <4ADB4212.8060607@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040808090108050503010801"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:55742 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310AbZJRQ2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 12:28:01 -0400
Received: by pzk26 with SMTP id 26so2725142pzk.4
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 09:28:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040808090108050503010801
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



-------- Original Message --------
Subject: [net-next-2.6 PATCH 4/4] TCPCT part 1: initial SYN exchange with SYNACK data
Date: Thu, 15 Oct 2009 01:36:48 -0400
From: William Allen Simpson <william.allen.simpson@gmail.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
References: <4AD6B31B.3060402@gmail.com> <4AD6B3E8.2050904@gmail.com> <4AD6B467.2080701@gmail.com>

This is a significantly revised implementation of an earlier (year-old)
patch that no longer applies cleanly, with permission of the original
author (Adam Langley).  That patch was previously reviewed:

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

Data structures are carefully composed to require minimal additions.
For example, the struct tcp_options_received cookie_plus variable fits
between existing 16-bit and 8-bit variables, requiring no additional
space (taking alignment into consideration).  There are no additions to
tcp_request_sock, and only 1 pointer and 1 flag byte in tcp_sock.

Allocations have been rearranged to avoid requiring GFP_ATOMIC, with
only one unavoidable exception in tcp_create_openreq_child(), where the
tcp_sock itself is created GFP_ATOMIC.

These functions will also be used in subsequent patches that implement
additional features.

Requires:
   TCPCT part 1a: add function parameter for sending SYNACK
   TCPCT part 1b: sysctl_tcp_cookie_size and TCP_COOKIE_TRANSACTIONS
   TCPCT part 1c: redefine TCP header functions *_len_th(), cleanup
---
   include/linux/tcp.h      |   35 +++++++-
   include/net/tcp.h        |   72 ++++++++++++++--
   net/ipv4/syncookies.c    |    5 +-
   net/ipv4/tcp.c           |  133 +++++++++++++++++++++++++++-
   net/ipv4/tcp_input.c     |   82 +++++++++++++++---
   net/ipv4/tcp_ipv4.c      |   62 +++++++++++--
   net/ipv4/tcp_minisocks.c |   43 +++++++---
   net/ipv4/tcp_output.c    |  223 ++++++++++++++++++++++++++++++++++++++++++---
   net/ipv6/syncookies.c    |    5 +-
   net/ipv6/tcp_ipv6.c      |   47 +++++++++-
   10 files changed, 641 insertions(+), 66 deletions(-)



--------------040808090108050503010801
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1-4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1-4.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index d304ba5..1c9a1d1 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -252,26 +252,36 @@ struct tcp_options_received {
 		sack_ok : 4,	/* SACK seen on SYN packet		*/
 		snd_wscale : 4,	/* Window scaling received from sender	*/
 		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
-/*	SACKs data	*/
+	u8	cookie_plus: 6;	/* bytes in authenticator/cookie option	*/
 	u8	num_sacks;	/* Number of SACK blocks		*/
-	u16	user_mss;  	/* mss requested by user in ioctl */
+	u16	user_mss;	/* mss requested by user in ioctl	*/
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
 };
 
+static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
+{
+	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
+	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+	rx_opt->cookie_plus = 0;
+}
+
 /* This is the max number of SACKS that we'll generate and process. It's safe
  * to increse this, although since:
  *   size = TCPOLEN_SACK_BASE_ALIGNED (4) + n * TCPOLEN_SACK_PERBLOCK (8)
  * only four options will fit in a standard TCP header */
 #define TCP_NUM_SACKS 4
 
+struct tcp_cookie_values;
+struct tcp_request_sock_ops;
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
 };
 
 static inline struct tcp_request_sock *tcp_rsk(const struct request_sock *req)
@@ -441,6 +451,19 @@ struct tcp_sock {
 /* TCP MD5 Signature Option information */
 	struct tcp_md5sig_info	*md5sig_info;
 #endif
+
+	/* When the cookie options are generated and exchanged, then this
+	 * object holds a reference to them (cookie_values->kref).  Also
+	 * contains related tcp_cookie_transactions fields.
+	 */
+	struct tcp_cookie_values  	*cookie_values;
+
+	u8				cookie_in_always:1,
+					cookie_out_never:1,
+					extend_timestamp:1,
+					s_data_constant:1,
+					s_data_in:1,
+					s_data_out:1;
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
@@ -459,6 +482,10 @@ struct tcp_timewait_sock {
 	u16			  tw_md5_keylen;
 	u8			  tw_md5_key[TCP_MD5SIG_MAXKEYLEN];
 #endif
+	/* Few sockets in timewait have cookies; in that case, then this
+	 * object holds a reference to it (tw_cookie_values->kref)
+	 */
+	struct tcp_cookie_values  *tw_cookie_values;
 };
 
 static inline struct tcp_timewait_sock *tcp_twsk(const struct sock *sk)
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 63d17fd..a2d2c0f 100644
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
@@ -344,11 +350,6 @@ static inline void tcp_dec_quickack_mode(struct sock *sk,
 
 extern void tcp_enter_quickack_mode(struct sock *sk);
 
-static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
-{
- 	rx_opt->tstamp_ok = rx_opt->sack_ok = rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
-}
-
 #define	TCP_ECN_OK		1
 #define	TCP_ECN_QUEUE_CWR	2
 #define	TCP_ECN_DEMAND_CWR	4
@@ -410,7 +411,7 @@ extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
 
 extern void			tcp_parse_options(struct sk_buff *skb,
 						  struct tcp_options_received *opt_rx,
-						  int estab);
+						  u8 **cryptic, int estab);
 
 extern u8			*tcp_parse_md5sig_option(struct tcphdr *th);
 
@@ -1482,6 +1483,65 @@ struct tcp_request_sock_ops {
 #endif
 };
 
+/**
+ * A tcp_sock contains a pointer to the current value, and this is cloned to
+ * the tcp_timewait_sock.
+ *
+ * @cookie_pair:	variable data from the option exchange.
+ *
+ * @cookie_desired:	user specified tcpct_cookie_desired.  Zero
+ *			indicates default (sysctl_tcp_cookie_size).
+ *			After cookie sent, remembers size of cookie.
+ *
+ * @s_data_desired:	user specified tcpct_s_data_desired.  When the
+ *			constant payload is specified (s_data_constant),
+ *			holds its length instead.
+ *
+ * @s_data_payload:	constant data that is to be included in the
+ *			payload of SYN or SYNACK segments when the
+ *			cookie option is present.
+ */
+struct tcp_cookie_values {
+	struct kref	kref;
+	u8		cookie_pair[TCP_COOKIE_PAIR_SIZE];
+	u8		cookie_pair_size;
+	u8		cookie_desired;
+	u16		s_data_desired;
+	u8		s_data_payload[0];
+};
+
+static inline void tcp_cookie_values_release(struct kref *kref)
+{
+	kfree(container_of(kref, struct tcp_cookie_values, kref));
+}
+
+/* The length of constant payload data.  Note that s_data_desired is
+ * overloaded, depending on s_data_constant: either the length of constant
+ * data (returned here) or the limit on variable data.
+ */
+static inline int tcp_s_data_size(const struct tcp_sock *tp)
+{
+	return (NULL != tp->cookie_values && tp->s_data_constant)
+		? tp->cookie_values->s_data_desired
+		: 0;
+}
+
+/* As tcp_request_sock has already been extended in other places, the
+ * only remaining method is to pass stack values along as function
+ * parameters.  These parameters are not needed after sending SYNACK.
+ */
+struct tcp_extend_values {
+	u8				cookie_bakery[TCP_COOKIE_MAX];
+	u8				cookie_plus;
+	u8				cookie_in_always:1,
+					cookie_out_never:1;
+};
+
+static inline struct tcp_extend_values *tcp_xv(const void *extend_values)
+{
+	return (struct tcp_extend_values *)extend_values;
+}
+
 extern void tcp_v4_init(void);
 extern void tcp_init(void);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 5ec678a..cdab491 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -253,6 +253,8 @@ EXPORT_SYMBOL(cookie_check_timestamp);
 struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 			     struct ip_options *opt)
 {
+	struct tcp_options_received tcp_opt;
+	u8 *cryptic_value;
 	struct inet_request_sock *ireq;
 	struct tcp_request_sock *treq;
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -263,7 +265,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	int mss;
 	struct rtable *rt;
 	__u8 rcv_wscale;
-	struct tcp_options_received tcp_opt;
 
 	if (!sysctl_tcp_syncookies || !th->ack)
 		goto out;
@@ -278,7 +279,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, 0);
+	tcp_parse_options(skb, &tcp_opt, &cryptic_value, 0);
 
 	if (tcp_opt.saw_tstamp)
 		cookie_check_timestamp(&tcp_opt);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index cf13726..0b47ffe 100644
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
@@ -2056,6 +2056,95 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		err = tcp_set_congestion_control(sk, name);
 		release_sock(sk);
 		return err;
+	} else if (TCP_COOKIE_TRANSACTIONS == optname) {
+		struct tcp_cookie_transactions ctd;
+		struct tcp_cookie_values *cvp = NULL;
+
+		if (sizeof(ctd) > optlen) {
+			return -EINVAL;
+		}
+		if (copy_from_user(&ctd, optval, sizeof(ctd))) {
+			return -EFAULT;
+		}
+		if (sizeof(ctd.tcpct_value) < ctd.tcpct_used) {
+			return -EINVAL;
+		}
+		if (0 == ctd.tcpct_cookie_desired) {
+			/* default to global value */
+		} else if ((0x1 & ctd.tcpct_cookie_desired)
+			|| TCP_COOKIE_MAX < ctd.tcpct_cookie_desired
+			|| TCP_COOKIE_MIN > ctd.tcpct_cookie_desired) {
+			return -EINVAL;
+		}
+
+		if (TCP_COOKIE_OUT_NEVER & ctd.tcpct_flags) {
+			/* Supercedes all other values */
+			lock_sock(sk);
+			if (NULL != tp->cookie_values) {
+				kref_put(&tp->cookie_values->kref,
+					 tcp_cookie_values_release);
+				tp->cookie_values = NULL;
+			}
+			tp->cookie_in_always = 0; /* false */
+			tp->cookie_out_never = 1; /* true */
+			tp->extend_timestamp = 0; /* false */
+			tp->s_data_constant = 0; /* false */
+			tp->s_data_in = 0; /* false */
+			tp->s_data_out = 0; /* false */
+			release_sock(sk);
+			return err;
+		}
+
+		/* Allocate ancillary memory before locking.
+		 */
+		if (0 < ctd.tcpct_used
+		 || (NULL == tp->cookie_values
+		  && (0 < sysctl_tcp_cookie_size
+		   || 0 < ctd.tcpct_cookie_desired
+		   || 0 < ctd.tcpct_s_data_desired))) {
+			cvp = kmalloc(sizeof(*cvp) + ctd.tcpct_used,
+				      GFP_KERNEL);
+			if (NULL == cvp) {
+				return -ENOMEM;
+			}
+		}
+
+		lock_sock(sk);
+		tp->cookie_in_always = (TCP_COOKIE_IN_ALWAYS & ctd.tcpct_flags);
+		tp->cookie_out_never = 0; /* false */
+		tp->extend_timestamp = (TCP_EXTEND_TIMESTAMP & ctd.tcpct_flags);
+		tp->s_data_in = 0; /* false */
+		tp->s_data_out = 0; /* false */
+
+		if (NULL == cvp) {
+			/* No cookies by default. */
+			tp->s_data_constant = 0; /* false */
+		} else if (0 == ctd.tcpct_used) {
+			/* No constant payload data. */
+			cvp->cookie_desired = ctd.tcpct_cookie_desired;
+			cvp->s_data_desired = ctd.tcpct_s_data_desired;
+			tp->cookie_values = cvp;
+			tp->s_data_constant = 0; /* false */
+		} else {
+			/* Changes in values are recorded by a change in
+			 * pointer, ensuring that the cookie will differ,
+			 * without separately hashing each value later.
+			 */
+			if (unlikely(NULL != tp->cookie_values)) {
+				kref_put(&tp->cookie_values->kref,
+					 tcp_cookie_values_release);
+			}
+			kref_init(&cvp->kref);
+			memcpy(cvp->s_data_payload, ctd.tcpct_value,
+			       ctd.tcpct_used);
+			cvp->cookie_desired = ctd.tcpct_cookie_desired;
+			cvp->s_data_desired = ctd.tcpct_used;
+			tp->cookie_values = cvp;
+			tp->s_data_constant = 1; /* true */
+		}
+
+		release_sock(sk);
+		return err;
 	}
 
 	if (optlen < sizeof(int))
@@ -2387,6 +2476,46 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		if (copy_to_user(optval, icsk->icsk_ca_ops->name, len))
 			return -EFAULT;
 		return 0;
+
+	case TCP_COOKIE_TRANSACTIONS: {
+		struct tcp_cookie_transactions ctd;
+		struct tcp_cookie_values *cvp = tp->cookie_values;
+
+		if (get_user(len, optlen))
+			return -EFAULT;
+		if (len < sizeof(ctd))
+			return -EINVAL;
+
+		memset(&ctd, 0, sizeof(ctd));
+		ctd.tcpct_flags =
+			  (tp->cookie_in_always ? TCP_COOKIE_IN_ALWAYS : 0)
+			| (tp->cookie_out_never ? TCP_COOKIE_OUT_NEVER : 0)
+			| (tp->extend_timestamp ? TCP_EXTEND_TIMESTAMP : 0)
+			| (tp->s_data_in ? TCP_S_DATA_IN : 0)
+			| (tp->s_data_out ? TCP_S_DATA_OUT : 0);
+
+		if (NULL != cvp) {
+			/* Cookie(s) saved, return as nonce */
+			if (sizeof(ctd.tcpct_value) < cvp->cookie_pair_size) {
+				/* impossible? */
+				return -EINVAL;
+			}
+			memcpy(&ctd.tcpct_value[0], &cvp->cookie_pair[0],
+			       cvp->cookie_pair_size);
+			ctd.tcpct_used = cvp->cookie_pair_size;
+
+			ctd.tcpct_cookie_desired = cvp->cookie_desired;
+			ctd.tcpct_s_data_desired = cvp->s_data_desired;
+		}
+
+		if (copy_to_user(optval, &ctd, sizeof(ctd))) {
+			return -EFAULT;
+		}
+		if (put_user(sizeof(ctd), optlen)) {
+			return -EFAULT;
+		}
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d86784b..200afa8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3698,11 +3698,11 @@ old_ack:
  * the fast version below fails.
  */
 void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
-		       int estab)
+		       u8 **cryptic, int estab)
 {
 	unsigned char *ptr;
 	struct tcphdr *th = tcp_hdr(skb);
-	int length = (th->doff * 4) - sizeof(struct tcphdr);
+	int length = tcp_option_len_th(th);
 
 	ptr = (unsigned char *)(th + 1);
 	opt_rx->saw_tstamp = 0;
@@ -3782,6 +3782,19 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 				 */
 				break;
 #endif
+			case TCPOPT_COOKIE:
+				/* This option carries 3 different lengths.
+				 */
+				if (TCPOLEN_COOKIE_MAX >= opsize
+				 && TCPOLEN_COOKIE_MIN <= opsize) {
+					opt_rx->cookie_plus = opsize;
+					*cryptic = ptr;
+				} else if (TCPOLEN_COOKIE_PAIR == opsize) {
+					/* not yet implemented */
+				} else if (TCPOLEN_COOKIE_BASE == opsize) {
+					/* not yet implemented */
+				}
+				break;
 			}
 
 			ptr += opsize-2;
@@ -3810,17 +3823,21 @@ static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, struct tcphdr *th)
  * If it is wrong it falls back on tcp_parse_options().
  */
 static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
-				  struct tcp_sock *tp)
+				  struct tcp_sock *tp, u8 **cryptic)
 {
-	if (th->doff == sizeof(struct tcphdr) >> 2) {
+	/* In the spirit of fast parsing, compare doff directly to shifted
+	 * constant values.  Because equality is used, short doff can be
+	 * ignored here, and checked later.
+	 */
+	if ((sizeof(*th) >> 2) == th->doff) {
 		tp->rx_opt.saw_tstamp = 0;
 		return 0;
 	} else if (tp->rx_opt.tstamp_ok &&
-		   th->doff == (sizeof(struct tcphdr)>>2)+(TCPOLEN_TSTAMP_ALIGNED>>2)) {
+		   ((sizeof(*th)+TCPOLEN_TSTAMP_ALIGNED)>>2) == th->doff) {
 		if (tcp_parse_aligned_timestamp(tp, th))
 			return 1;
 	}
-	tcp_parse_options(skb, &tp->rx_opt, 1);
+	tcp_parse_options(skb, &tp->rx_opt, cryptic, 1);
 	return 1;
 }
 
@@ -3830,7 +3847,7 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
  */
 u8 *tcp_parse_md5sig_option(struct tcphdr *th)
 {
-	int length = (th->doff << 2) - sizeof (*th);
+	int length = tcp_option_len_th(th);
 	u8 *ptr = (u8*)(th + 1);
 
 	/* If the TCP option is too short, we can short cut */
@@ -5070,10 +5087,11 @@ out:
 static int tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 			      struct tcphdr *th, int syn_inerr)
 {
+	u8 *cv;
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* RFC1323: H1. Apply PAWS check first. */
-	if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstamp &&
+	if (tcp_fast_parse_options(skb, th, tp, &cv) && tp->rx_opt.saw_tstamp &&
 	    tcp_paws_discard(sk, skb)) {
 		if (!th->rst) {
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
@@ -5361,11 +5379,14 @@ discard:
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 					 struct tcphdr *th, unsigned len)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	u8 *cryptic_value;
 	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_cookie_values *cvp = tp->cookie_values;
 	int saved_clamp = tp->rx_opt.mss_clamp;
+	int queued = 0;
 
-	tcp_parse_options(skb, &tp->rx_opt, 0);
+	tcp_parse_options(skb, &tp->rx_opt, &cryptic_value, 0);
 
 	if (th->ack) {
 		/* rfc793:
@@ -5462,6 +5483,42 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 * Change state from SYN-SENT only after copied_seq
 		 * is initialized. */
 		tp->copied_seq = tp->rcv_nxt;
+
+		if (NULL != cvp
+		 && 0 < cvp->cookie_pair_size
+		 && 0 < tp->rx_opt.cookie_plus) {
+			int cookie_size = tp->rx_opt.cookie_plus - TCPOLEN_COOKIE_BASE;
+			int cookie_pair_size = cvp->cookie_desired + cookie_size;
+
+			/* A cookie extension option was sent and returned.
+			 * Note that each incoming SYNACK replaces the
+			 * Responder cookie.  The initial exchange is most
+			 * fragile, as protection against spoofing relies
+			 * entirely upon the sequence and timestamp (above).
+			 * This replacement strategy allows the correct pair to
+			 * pass through, while any others will be filtered via
+			 * Responder verification later.
+			 */
+			if (sizeof(cvp->cookie_pair) >= cookie_pair_size) {
+				memcpy(&cvp->cookie_pair[cvp->cookie_desired],
+				       cryptic_value, cookie_size);
+				cvp->cookie_pair_size = cookie_pair_size;
+			}
+
+			if (tcp_header_len_th(th) < skb->len) {
+				/* Queue incoming transaction data. */
+				__skb_pull(skb, tcp_header_len_th(th));
+				__skb_queue_tail(&sk->sk_receive_queue, skb);
+				skb_set_owner_r(skb, sk);
+				sk->sk_data_ready(sk, 0);
+				tp->s_data_in = 1; /* true */
+				queued = 1; /* should be amount? */
+				tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+				tp->rcv_wup = TCP_SKB_CB(skb)->end_seq;
+				tp->copied_seq = TCP_SKB_CB(skb)->seq + 1;
+			}
+		}
+
 		smp_mb();
 		tcp_set_state(sk, TCP_ESTABLISHED);
 
@@ -5513,11 +5570,14 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 						  TCP_DELACK_MAX, TCP_RTO_MAX);
 
 discard:
-			__kfree_skb(skb);
+			if (0 == queued)
+				__kfree_skb(skb);
 			return 0;
 		} else {
 			tcp_send_ack(sk);
 		}
+		if (0 < queued)
+			return 0; /* amount queued? */
 		return -1;
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2d25bd4..7d5fd4d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -217,7 +217,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (inet->opt)
 		inet_csk(sk)->icsk_ext_hdr_len = inet->opt->optlen;
 
-	tp->rx_opt.mss_clamp = 536;
+	tp->rx_opt.mss_clamp = TCP_MIN_RCVMSS;
 
 	/* Socket identity is still unknown (sport may be zero).
 	 * However we set state to SYN-SENT and not releasing socket
@@ -1211,9 +1211,12 @@ static struct timewait_sock_ops tcp_timewait_sock_ops = {
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
-	struct inet_request_sock *ireq;
+	struct tcp_extend_values tmp_ext;
 	struct tcp_options_received tmp_opt;
+	u8 *cryptic_value;
+	struct inet_request_sock *ireq;
 	struct request_sock *req;
+	struct tcp_sock *tp = tcp_sk(sk);
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
 	__u32 isn = TCP_SKB_CB(skb)->when;
@@ -1258,16 +1261,37 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 #endif
 
 	tcp_clear_options(&tmp_opt);
-	tmp_opt.mss_clamp = 536;
-	tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
+	tmp_opt.mss_clamp = TCP_MIN_RCVMSS;
+	tmp_opt.user_mss  = tp->rx_opt.user_mss;
 
-	tcp_parse_options(skb, &tmp_opt, 0);
+	tcp_parse_options(skb, &tmp_opt, &cryptic_value, 0);
+
+	if (0 < tmp_opt.cookie_plus
+	 && tmp_opt.saw_tstamp
+	 && !tp->cookie_out_never
+	 && (0 < sysctl_tcp_cookie_size
+	  || (NULL != tp->cookie_values
+	   && 0 < tp->cookie_values->cookie_desired))) {
+#ifdef CONFIG_SYN_COOKIES
+		want_cookie = 0;	/* not our kind of cookie */
+#endif
+		tmp_ext.cookie_out_never = 0; /* false */
+		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
+
+		/* secret recipe not yet implemented */
+	} else if (!tp->cookie_in_always) {
+		/* redundant indications, but ensure initialization. */
+		tmp_ext.cookie_out_never = 1; /* true */
+		tmp_ext.cookie_plus = 0;
+	} else {
+		goto drop_and_free;
+	}
+	tmp_ext.cookie_in_always = tp->cookie_in_always;
 
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
 
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
-
 	tcp_openreq_init(req, &tmp_opt, skb);
 
 	ireq = inet_rsk(req);
@@ -1334,7 +1358,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	}
 	tcp_rsk(req)->snt_isn = isn;
 
-	if (__tcp_v4_send_synack(sk, req, dst, NULL) ||
+	if (__tcp_v4_send_synack(sk, req, dst, (void *)&tmp_ext) ||
 	    want_cookie)
 		goto drop_and_free;
 
@@ -1812,7 +1836,7 @@ static int tcp_v4_init_sock(struct sock *sk)
 	 */
 	tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
 	tp->snd_cwnd_clamp = ~0;
-	tp->mss_cache = 536;
+	tp->mss_cache = TCP_MIN_RCVMSS;
 
 	tp->reordering = sysctl_tcp_reordering;
 	icsk->icsk_ca_ops = &tcp_init_congestion_ops;
@@ -1828,6 +1852,19 @@ static int tcp_v4_init_sock(struct sock *sk)
 	tp->af_specific = &tcp_sock_ipv4_specific;
 #endif
 
+	/* TCP Cookie Transactions */
+	if (0 < sysctl_tcp_cookie_size) {
+		/* Default, cookies without s_data. */
+		tp->cookie_values =
+			kzalloc(sizeof(*tp->cookie_values), sk->sk_allocation);
+		if (NULL != tp->cookie_values) {
+			kref_init(&tp->cookie_values->kref);
+		}
+	}
+	/* Presumed zeroed, in order of appearance:
+	 *	cookie_in_always, cookie_out_never, extend_timestamp,
+	 *	s_data_constant, s_data_in, s_data_out
+	 */
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
@@ -1881,6 +1918,15 @@ void tcp_v4_destroy_sock(struct sock *sk)
 		sk->sk_sndmsg_page = NULL;
 	}
 
+	/*
+	 * If cookie or s_data exists, remove it.
+	 */
+	if (NULL != tp->cookie_values) {
+		kref_put(&tp->cookie_values->kref,
+			 tcp_cookie_values_release);
+		tp->cookie_values = NULL;
+	}
+
 	percpu_counter_dec(&tcp_sockets_allocated);
 }
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 8819882..0d33f5c 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -96,13 +96,14 @@ enum tcp_tw_status
 tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 			   const struct tcphdr *th)
 {
-	struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 	struct tcp_options_received tmp_opt;
+	u8 *cryptic_value;
+	struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 	int paws_reject = 0;
 
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
-		tcp_parse_options(skb, &tmp_opt, 0);
+		tcp_parse_options(skb, &tmp_opt, &cryptic_value, 0);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent	= tcptw->tw_ts_recent;
@@ -394,9 +395,12 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
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
 
@@ -429,9 +433,24 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
 		skb_queue_head_init(&newtp->out_of_order_queue);
-		newtp->write_seq = treq->snt_isn + 1;
-		newtp->pushed_seq = newtp->write_seq;
+		newtp->write_seq = newtp->pushed_seq =
+			treq->snt_isn + 1 + tcp_s_data_size(tcp_sk(sk));
 
+		/* TCP Cookie Transactions */
+		if (NULL != tcp_sk(sk)->cookie_values) {
+			/* Instead of reusing the original, replace with
+			 * default, cookies without s_data.
+			 */
+			newtp->cookie_values =
+				kzalloc(sizeof(*newtp->cookie_values), GFP_ATOMIC);
+			if (NULL != newtp->cookie_values) {
+				kref_init(&newtp->cookie_values->kref);
+			}
+		}
+		/* Presumed copied, in order of appearance:
+		 *	cookie_in_always, cookie_out_never, extend_timestamp,
+		 *	s_data_constant, s_data_in, s_data_out
+		 */
 		newtp->rx_opt.saw_tstamp = 0;
 
 		newtp->rx_opt.dsack = 0;
@@ -495,15 +514,16 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 			   struct request_sock *req,
 			   struct request_sock **prev)
 {
+	struct tcp_options_received tmp_opt;
+	u8 *cryptic_value;
 	const struct tcphdr *th = tcp_hdr(skb);
 	__be32 flg = tcp_flag_word(th) & (TCP_FLAG_RST|TCP_FLAG_SYN|TCP_FLAG_ACK);
 	int paws_reject = 0;
-	struct tcp_options_received tmp_opt;
 	struct sock *child;
 
 	tmp_opt.saw_tstamp = 0;
-	if (th->doff > (sizeof(struct tcphdr)>>2)) {
-		tcp_parse_options(skb, &tmp_opt, 0);
+	if (th->doff > (sizeof(*th) >> 2)) {
+		tcp_parse_options(skb, &tmp_opt, &cryptic_value, 0);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent = req->ts_recent;
@@ -596,7 +616,8 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	 * Invalid ACK: reset will be sent by listening socket
 	 */
 	if ((flg & TCP_FLAG_ACK) &&
-	    (TCP_SKB_CB(skb)->ack_seq != tcp_rsk(req)->snt_isn + 1))
+	    (TCP_SKB_CB(skb)->ack_seq != tcp_rsk(req)->snt_isn + 1 +
+					 tcp_s_data_size(tcp_sk(sk))))
 		return sk;
 
 	/* Also, it would be not so bad idea to check rcv_tsecr, which
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c235196..0a04684 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -370,6 +370,7 @@ static inline int tcp_urg_mode(const struct tcp_sock *tp)
 #define OPTION_TS		(1 << 1)
 #define OPTION_MD5		(1 << 2)
 #define OPTION_WSCALE		(1 << 3)
+#define OPTION_COOKIE_EXTENSION	(1 << 4)
 
 struct tcp_out_options {
 	u8 options;		/* bit field of OPTION_* */
@@ -377,8 +378,35 @@ struct tcp_out_options {
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
+	if (0 >= sysctl_tcp_cookie_size) {
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
@@ -395,11 +423,22 @@ struct tcp_out_options {
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
@@ -412,12 +451,13 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
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
@@ -428,15 +468,48 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		*ptr++ = htonl(opts->tsecr);
 	}
 
-	if (unlikely(OPTION_SACK_ADVERTISE & opts->options &&
-		     !(OPTION_TS & opts->options))) {
+	/* Specification requires after timestamp, so do it now.
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
 
-	if (unlikely(OPTION_WSCALE & opts->options)) {
+	if (unlikely(OPTION_WSCALE & options)) {
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
 			       (TCPOPT_WINDOW << 16) |
 			       (TCPOLEN_WINDOW << 8) |
@@ -471,11 +544,18 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 				struct tcp_out_options *opts,
 				struct tcp_md5sig_key **md5) {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_cookie_values *cvp = tp->cookie_values;
 	unsigned size = 0;
+	u8 cookie_size = (!tp->cookie_out_never && NULL != cvp)
+			 ? tcp_cookie_size_check(cvp->cookie_desired)
+			 : 0;
 
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 = tp->af_specific->md5_lookup(sk, sk);
 	if (*md5) {
+		if (0 < cookie_size) {
+			opts->options |= OPTION_COOKIE_EXTENSION;
+		}
 		opts->options |= OPTION_MD5;
 		size += TCPOLEN_MD5SIG_ALIGNED;
 	}
@@ -512,6 +592,63 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
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
+	 && 0 < cookie_size) {
+		int need = TCPOLEN_COOKIE_BASE + cookie_size;
+		int remaining = MAX_TCP_OPTION_SPACE - size;
+
+		if (0x2 & need) {
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
+			opts->options |= OPTION_COOKIE_EXTENSION;
+			opts->cookie_copy = &cvp->cookie_pair[0];
+			opts->cookie_size = cookie_size;
+
+			/* Remember for future incarnations. */
+			cvp->cookie_desired = cookie_size;
+
+			if (cvp->cookie_desired != cvp->cookie_pair_size) {
+				/* Currently use random bytes as a nonce,
+				 * assuming these are completely unpredictable
+				 * by hostile users of the same system.
+				 */
+				get_random_bytes(opts->cookie_copy,
+						 cookie_size);
+				cvp->cookie_pair_size = cookie_size;
+			}
+
+			size += need;
+		}
+	}
 	return size;
 }
 
@@ -520,14 +657,22 @@ static unsigned tcp_synack_options(struct sock *sk,
 				   struct request_sock *req,
 				   unsigned mss, struct sk_buff *skb,
 				   struct tcp_out_options *opts,
-				   struct tcp_md5sig_key **md5) {
-	unsigned size = 0;
+				   struct tcp_md5sig_key **md5,
+				   struct tcp_extend_values *xvp)
+{
 	struct inet_request_sock *ireq = inet_rsk(req);
+	unsigned size = 0;
+	u8 cookie_plus = (NULL != xvp && !xvp->cookie_out_never)
+			 ? xvp->cookie_plus
+			 : 0;
 	char doing_ts;
 
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
 	if (*md5) {
+		if (0 < cookie_plus) {
+			opts->options |= OPTION_COOKIE_EXTENSION;
+		}
 		opts->options |= OPTION_MD5;
 		size += TCPOLEN_MD5SIG_ALIGNED;
 	}
@@ -561,6 +706,34 @@ static unsigned tcp_synack_options(struct sock *sk,
 			size += TCPOLEN_SACKPERM_ALIGNED;
 	}
 
+	/* Similar rationale to tcp_syn_options() applies here, too.
+	 * If the <SYN> options fit, the same options should fit now!
+	 */
+	if (NULL == *md5
+	 && doing_ts
+	 && 0 < cookie_plus) {
+		int need = cookie_plus; /* has TCPOLEN_COOKIE_BASE */
+		int remaining = MAX_TCP_OPTION_SPACE - size;
+
+		if (0x2 & need) {
+			/* 32-bit multiple */
+			need += 2; /* NOPs */
+		}
+		if (need <= remaining) {
+			opts->options |= OPTION_COOKIE_EXTENSION;
+			opts->cookie_copy = &xvp->cookie_bakery[0];
+			opts->cookie_size = cookie_plus - TCPOLEN_COOKIE_BASE;
+
+			/* secret recipe not yet implemented */
+			get_random_bytes(opts->cookie_copy,
+					 opts->cookie_size);
+
+			size += need;
+		} else {
+			/* There's no error return, so flag it. */
+			xvp->cookie_out_never = 1; /* true */
+		}
+	}
 	return size;
 }
 
@@ -2229,14 +2402,15 @@ int tcp_send_synack(struct sock *sk)
 struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 				struct request_sock *req, void *extend_values)
 {
+	struct tcp_out_options opts;
+	struct tcp_extend_values *xvp = tcp_xv(extend_values);
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcphdr *th;
-	int tcp_header_size;
-	struct tcp_out_options opts;
 	struct sk_buff *skb;
 	struct tcp_md5sig_key *md5;
 	__u8 *md5_hash_location;
+	int tcp_header_size;
 	int mss;
 
 	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
@@ -2274,7 +2448,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 #endif
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 	tcp_header_size = tcp_synack_options(sk, req, mss,
-					     skb, &opts, &md5) +
+					     skb, &opts, &md5, xvp) +
 			  sizeof(struct tcphdr);
 
 	skb_push(skb, tcp_header_size);
@@ -2292,6 +2466,25 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	 */
 	tcp_init_nondata_skb(skb, tcp_rsk(req)->snt_isn,
 			     TCPCB_FLAG_SYN | TCPCB_FLAG_ACK);
+
+	/* If cookies are active, and constant data is available, copy it
+	 * directly from the listening socket.
+	 */
+	if (NULL != xvp
+	 && !xvp->cookie_out_never
+	 && 0 < xvp->cookie_plus
+	 && tp->s_data_constant) {
+		const struct tcp_cookie_values *cvp = tp->cookie_values;
+
+		if (NULL != cvp
+		 && 0 < cvp->s_data_desired) {
+			u8 *buf = skb_put(skb, cvp->s_data_desired);
+
+			memcpy(buf, cvp->s_data_payload, cvp->s_data_desired);
+			TCP_SKB_CB(skb)->end_seq += cvp->s_data_desired;
+		}
+	}
+
 	th->seq = htonl(TCP_SKB_CB(skb)->seq);
 	th->ack_seq = htonl(tcp_rsk(req)->rcv_isn + 1);
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index cbe55e5..2839349 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -159,6 +159,8 @@ static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 
 struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_options_received tcp_opt;
+	u8 *cryptic_value;
 	struct inet_request_sock *ireq;
 	struct inet6_request_sock *ireq6;
 	struct tcp_request_sock *treq;
@@ -171,7 +173,6 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	int mss;
 	struct dst_entry *dst;
 	__u8 rcv_wscale;
-	struct tcp_options_received tcp_opt;
 
 	if (!sysctl_tcp_syncookies || !th->ack)
 		goto out;
@@ -186,7 +187,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, 0);
+	tcp_parse_options(skb, &tcp_opt, &cryptic_value, 0);
 
 	if (tcp_opt.saw_tstamp)
 		cookie_check_timestamp(&tcp_opt);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3b3d7b3..1320825 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1161,11 +1161,13 @@ static struct sock *tcp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
  */
 static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_extend_values tmp_ext;
+	struct tcp_options_received tmp_opt;
+	u8 *cryptic_value;
 	struct inet6_request_sock *treq;
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct tcp_options_received tmp_opt;
-	struct tcp_sock *tp = tcp_sk(sk);
 	struct request_sock *req = NULL;
+	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 isn = TCP_SKB_CB(skb)->when;
 #ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
@@ -1205,7 +1207,29 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
 
-	tcp_parse_options(skb, &tmp_opt, 0);
+	tcp_parse_options(skb, &tmp_opt, &cryptic_value, 0);
+
+	if (0 < tmp_opt.cookie_plus
+	 && tmp_opt.saw_tstamp
+	 && !tp->cookie_out_never
+	 && (0 < sysctl_tcp_cookie_size
+	  || (NULL != tp->cookie_values
+	   && 0 < tp->cookie_values->cookie_desired))) {
+#ifdef CONFIG_SYN_COOKIES
+		want_cookie = 0;	/* not our kind of cookie */
+#endif
+		tmp_ext.cookie_out_never = 0; /* false */
+		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
+
+		/* secret recipe not yet implemented */
+	} else if (!tp->cookie_in_always) {
+		/* redundant indications, but ensure initialization. */
+		tmp_ext.cookie_out_never = 1; /* true */
+		tmp_ext.cookie_plus = 0;
+	} else {
+		goto drop;
+	}
+	tmp_ext.cookie_in_always = tp->cookie_in_always;
 
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
@@ -1243,7 +1267,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	security_inet_conn_request(sk, skb, req);
 
-	if (tcp_v6_send_synack(sk, req, NULL) ||
+	if (tcp_v6_send_synack(sk, req, (void *)&tmp_ext) ||
 	    want_cookie)
 		goto drop;
 
@@ -1848,7 +1872,7 @@ static int tcp_v6_init_sock(struct sock *sk)
 	 */
 	tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
 	tp->snd_cwnd_clamp = ~0;
-	tp->mss_cache = 536;
+	tp->mss_cache = TCP_MIN_RCVMSS;
 
 	tp->reordering = sysctl_tcp_reordering;
 
@@ -1864,6 +1888,19 @@ static int tcp_v6_init_sock(struct sock *sk)
 	tp->af_specific = &tcp_sock_ipv6_specific;
 #endif
 
+	/* TCP Cookie Transactions */
+	if (0 < sysctl_tcp_cookie_size) {
+		/* Default, cookies without s_data. */
+		tp->cookie_values =
+			kzalloc(sizeof(*tp->cookie_values), sk->sk_allocation);
+		if (NULL != tp->cookie_values) {
+			kref_init(&tp->cookie_values->kref);
+		}
+	}
+	/* Presumed zeroed, in order of appearance:
+	 *	cookie_in_always, cookie_out_never, extend_timestamp,
+	 *	s_data_constant, s_data_in, s_data_out
+	 */
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
-- 
1.6.0.4



--------------040808090108050503010801--
