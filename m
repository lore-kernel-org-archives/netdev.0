From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH v5 5/5 RFC] TCPCT part1e: initial SYN exchange
 with SYNACK data
Date: Mon, 09 Nov 2009 12:05:55 -0500
Message-ID: <4AF84BF3.5020302@gmail.com>
References: <4AF83E2D.1050401@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080602090006060509050400"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Joe Perches <joe@perches.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:49409 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753603AbZKIRF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 12:05:58 -0500
Received: by bwz27 with SMTP id 27so3675917bwz.21
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2009 09:06:01 -0800 (PST)
In-Reply-To: <4AF83E2D.1050401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080602090006060509050400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

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
tcp_request_sock, and only 1 pointer in tcp_sock.

Allocations have been rearranged to avoid requiring GFP_ATOMIC, with
only one unavoidable exception in tcp_create_openreq_child(), where the
tcp_sock itself is created GFP_ATOMIC.

These functions will also be used in subsequent patches that implement
additional features.

Requires:
   TCPCT part 1a: add request_values parameter for sending SYNACK
   TCPCT part 1b: TCP_MSS_DEFAULT, TCP_MSS_DESIRED
   TCPCT part 1c: sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS, functions
   TCPCT part 1d: generate Responder Cookie

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/linux/tcp.h      |   29 ++++-
  include/net/tcp.h        |   72 +++++++++++++
  net/ipv4/syncookies.c    |    5 +-
  net/ipv4/tcp.c           |  127 ++++++++++++++++++++++-
  net/ipv4/tcp_input.c     |   86 +++++++++++++--
  net/ipv4/tcp_ipv4.c      |   69 ++++++++++++-
  net/ipv4/tcp_minisocks.c |   59 ++++++++---
  net/ipv4/tcp_output.c    |  255 +++++++++++++++++++++++++++++++++++++++++-----
  net/ipv6/syncookies.c    |    5 +-
  net/ipv6/tcp_ipv6.c      |   65 +++++++++++-
  10 files changed, 701 insertions(+), 71 deletions(-)

--------------080602090006060509050400
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1e5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1e5.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 57921c1..80ebb52 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -258,31 +258,38 @@ struct tcp_options_received {
 		sack_ok : 4,	/* SACK seen on SYN packet		*/
 		snd_wscale : 4,	/* Window scaling received from sender	*/
 		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
-/*	SACKs data	*/
+	u8	cookie_plus:6,	/* bytes in authenticator/cookie option	*/
+		cookie_out_never:1,
+		cookie_in_always:1;
 	u8	num_sacks;	/* Number of SACK blocks		*/
-	u16	user_mss;  	/* mss requested by user in ioctl */
+	u16	user_mss;	/* mss requested by user in ioctl	*/
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
 };
 
 static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
 {
-	rx_opt->tstamp_ok = rx_opt->sack_ok = rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
+	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
+	rx_opt->cookie_plus = 0;
 }
 
 /* This is the max number of SACKS that we'll generate and process. It's safe
- * to increse this, although since:
+ * to increase this, although since:
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
@@ -452,6 +459,12 @@ struct tcp_sock {
 /* TCP MD5 Signature Option information */
 	struct tcp_md5sig_info	*md5sig_info;
 #endif
+
+	/* When the cookie options are generated and exchanged, then this
+	 * object holds a reference to them (cookie_values->kref).  Also
+	 * contains related tcp_cookie_transactions fields.
+	 */
+	struct tcp_cookie_values  	*cookie_values;
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
@@ -470,6 +483,10 @@ struct tcp_timewait_sock {
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
index 702fd0a..d992c35 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -30,6 +30,7 @@
 #include <linux/dmaengine.h>
 #include <linux/crypto.h>
 #include <linux/cryptohash.h>
+#include <linux/kref.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -164,6 +165,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOPT_SACK             5       /* SACK Block */
 #define TCPOPT_TIMESTAMP	8	/* Better RTT estimations/PAWS */
 #define TCPOPT_MD5SIG		19	/* MD5 Signature (RFC2385) */
+#define TCPOPT_COOKIE		253	/* Cookie extension (experimental) */
 
 /*
  *     TCP option lengths
@@ -174,6 +176,10 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERM      2
 #define TCPOLEN_TIMESTAMP      10
 #define TCPOLEN_MD5SIG         18
+#define TCPOLEN_COOKIE_BASE    2	/* Cookie-less header extension */
+#define TCPOLEN_COOKIE_PAIR    3	/* Cookie pair header extension */
+#define TCPOLEN_COOKIE_MAX     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MAX)
+#define TCPOLEN_COOKIE_MIN     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MIN)
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -401,6 +407,7 @@ extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
 
 extern void			tcp_parse_options(struct sk_buff *skb,
 						  struct tcp_options_received *opt_rx,
+						  u8 **cryptic,
 						  int estab,
 						  struct dst_entry *dst);
 
@@ -1482,6 +1489,71 @@ struct tcp_request_sock_ops {
 
 extern int tcp_cookie_generator(u32 *bakery);
 
+/**
+ * A tcp_sock contains a pointer to the current value, and this is cloned to
+ * the tcp_timewait_sock.
+ *
+ * @cookie_pair:	variable data from the option exchange.
+ *
+ * @cookie_desired:	user specified tcpct_cookie_desired.  Zero
+ *			indicates default (sysctl_tcp_cookie_size).
+ *			After cookie sent, remembers size of cookie.
+ *			Range 0, TCP_COOKIE_MIN to TCP_COOKIE_MAX.
+ *
+ * @s_data_desired:	user specified tcpct_s_data_desired.  When the
+ *			constant payload is specified (@s_data_constant),
+ *			holds its length instead.
+ *			Range 0 to TCP_MSS_DESIRED.
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
+	u16		s_data_desired:11,
+			s_data_constant:1,
+			s_data_in:1,
+			s_data_out:1;
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
+	return (tp->cookie_values != NULL && tp->cookie_values->s_data_constant)
+		? tp->cookie_values->s_data_desired
+		: 0;
+}
+
+/* As tcp_request_sock has already been extended in other places, the
+ * only remaining method is to pass stack values along as function
+ * parameters.  These parameters are not needed after sending SYNACK.
+ */
+struct tcp_extend_values {
+	struct request_values		rv;
+	u32				cookie_bakery[COOKIE_WORKSPACE_WORDS];
+	u8				cookie_plus:6,
+					cookie_out_never:1,
+					cookie_in_always:1;
+};
+
+static inline struct tcp_extend_values *tcp_xv(struct request_values *rvp)
+{
+	return (struct tcp_extend_values *)rvp;
+}
+
 extern void tcp_v4_init(void);
 extern void tcp_init(void);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 3146cc4..3503762 100644
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
@@ -341,7 +342,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, 0, &rt->u.dst);
+	tcp_parse_options(skb, &tcp_opt, &cryptic_value, 0, &rt->u.dst);
 
 	if (tcp_opt.saw_tstamp)
 		cookie_check_timestamp(&tcp_opt);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3ae01bf..b650e67 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2079,8 +2079,8 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	int val;
 	int err = 0;
 
-	/* This is a string value all the others are int's */
-	if (optname == TCP_CONGESTION) {
+	/* These are data/string values, all the others are ints */
+	if (TCP_CONGESTION == optname) {
 		char name[TCP_CA_NAME_MAX];
 
 		if (optlen < 1)
@@ -2096,6 +2096,88 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		err = tcp_set_congestion_control(sk, name);
 		release_sock(sk);
 		return err;
+	} else if (TCP_COOKIE_TRANSACTIONS == optname) {
+		struct tcp_cookie_transactions ctd;
+		struct tcp_cookie_values *cvp = NULL;
+
+		if (sizeof(ctd) > optlen)
+			return -EINVAL;
+		if (copy_from_user(&ctd, optval, sizeof(ctd)))
+			return -EFAULT;
+
+		if (sizeof(ctd.tcpct_value) < ctd.tcpct_used
+		 || TCP_MSS_DESIRED < ctd.tcpct_s_data_desired)
+			return -EINVAL;
+
+		if (ctd.tcpct_cookie_desired == 0) {
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
+			if (tp->cookie_values != NULL) {
+				kref_put(&tp->cookie_values->kref,
+					 tcp_cookie_values_release);
+				tp->cookie_values = NULL;
+			}
+			tp->rx_opt.cookie_in_always = 0; /* false */
+			tp->rx_opt.cookie_out_never = 1; /* true */
+			release_sock(sk);
+			return err;
+		}
+
+		/* Allocate ancillary memory before locking.
+		 */
+		if (ctd.tcpct_used > 0
+		 || (tp->cookie_values == NULL
+		  && (sysctl_tcp_cookie_size > 0
+		   || ctd.tcpct_cookie_desired > 0
+		   || ctd.tcpct_s_data_desired > 0))) {
+			cvp = kzalloc(sizeof(*cvp) + ctd.tcpct_used,
+				      GFP_KERNEL);
+			if (cvp == NULL)
+				return -ENOMEM;
+		}
+		lock_sock(sk);
+		tp->rx_opt.cookie_in_always =
+			(TCP_COOKIE_IN_ALWAYS & ctd.tcpct_flags);
+		tp->rx_opt.cookie_out_never = 0; /* false */
+
+		if (tp->cookie_values != NULL) {
+			if (cvp != NULL) {
+				/* Changed values are recorded by a changed
+				 * pointer, ensuring the cookie will differ,
+				 * without separately hashing each value later.
+				 */
+				kref_put(&tp->cookie_values->kref,
+					 tcp_cookie_values_release);
+				kref_init(&cvp->kref);
+				tp->cookie_values = cvp;
+			} else {
+				cvp = tp->cookie_values;
+			}
+		}
+		if (cvp != NULL) {
+			cvp->cookie_desired = ctd.tcpct_cookie_desired;
+
+			if (ctd.tcpct_used > 0) {
+				memcpy(cvp->s_data_payload, ctd.tcpct_value,
+				       ctd.tcpct_used);
+				cvp->s_data_desired = ctd.tcpct_used;
+				cvp->s_data_constant = 1; /* true */
+			} else {
+				/* No constant payload data. */
+				cvp->s_data_desired = ctd.tcpct_s_data_desired;
+				cvp->s_data_constant = 0; /* false */
+			}
+		}
+		release_sock(sk);
+		return err;
 	}
 
 	if (optlen < sizeof(int))
@@ -2421,6 +2503,47 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
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
+		ctd.tcpct_flags = (tp->rx_opt.cookie_in_always
+				   ? TCP_COOKIE_IN_ALWAYS : 0)
+				+ (tp->rx_opt.cookie_out_never
+				   ? TCP_COOKIE_OUT_NEVER : 0);
+
+		if (cvp != NULL) {
+			ctd.tcpct_flags += (cvp->s_data_in
+					    ? TCP_S_DATA_IN : 0)
+					 + (cvp->s_data_out
+					    ? TCP_S_DATA_OUT : 0);
+
+			ctd.tcpct_cookie_desired = cvp->cookie_desired;
+			ctd.tcpct_s_data_desired = cvp->s_data_desired;
+
+			/* Cookie(s) saved, return as nonce */
+			if (sizeof(ctd.tcpct_value) < cvp->cookie_pair_size) {
+				/* impossible? */
+				return -EINVAL;
+			}
+			memcpy(&ctd.tcpct_value[0], &cvp->cookie_pair[0],
+			       cvp->cookie_pair_size);
+			ctd.tcpct_used = cvp->cookie_pair_size;
+		}
+
+		if (put_user(sizeof(ctd), optlen))
+			return -EFAULT;
+		if (copy_to_user(optval, &ctd, sizeof(ctd)))
+			return -EFAULT;
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cc306ac..8fb50f0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3698,11 +3698,11 @@ old_ack:
  * the fast version below fails.
  */
 void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
-		       int estab,  struct dst_entry *dst)
+		       u8 **cryptic, int estab, struct dst_entry *dst)
 {
 	unsigned char *ptr;
 	struct tcphdr *th = tcp_hdr(skb);
-	int length = (th->doff * 4) - sizeof(struct tcphdr);
+	int length = tcp_option_len_th(th);
 
 	ptr = (unsigned char *)(th + 1);
 	opt_rx->saw_tstamp = 0;
@@ -3785,6 +3785,19 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
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
@@ -3813,17 +3826,21 @@ static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, struct tcphdr *th)
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
+	if (th->doff == (sizeof(*th) >> 2)) {
 		tp->rx_opt.saw_tstamp = 0;
 		return 0;
 	} else if (tp->rx_opt.tstamp_ok &&
-		   th->doff == (sizeof(struct tcphdr)>>2)+(TCPOLEN_TSTAMP_ALIGNED>>2)) {
+		   th->doff == ((sizeof(*th)+TCPOLEN_TSTAMP_ALIGNED)>>2)) {
 		if (tcp_parse_aligned_timestamp(tp, th))
 			return 1;
 	}
-	tcp_parse_options(skb, &tp->rx_opt, 1, NULL);
+	tcp_parse_options(skb, &tp->rx_opt, cryptic, 1, NULL);
 	return 1;
 }
 
@@ -3833,7 +3850,7 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
  */
 u8 *tcp_parse_md5sig_option(struct tcphdr *th)
 {
-	int length = (th->doff << 2) - sizeof (*th);
+	int length = tcp_option_len_th(th);
 	u8 *ptr = (u8*)(th + 1);
 
 	/* If the TCP option is too short, we can short cut */
@@ -5077,10 +5094,11 @@ out:
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
@@ -5368,12 +5386,15 @@ discard:
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 					 struct tcphdr *th, unsigned len)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	u8 *cryptic_value;
 	struct inet_connection_sock *icsk = inet_csk(sk);
-	int saved_clamp = tp->rx_opt.mss_clamp;
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
+	struct tcp_cookie_values *cvp = tp->cookie_values;
+	int saved_clamp = tp->rx_opt.mss_clamp;
+	int queued = 0;
 
-	tcp_parse_options(skb, &tp->rx_opt, 0, dst);
+	tcp_parse_options(skb, &tp->rx_opt, &cryptic_value, 0, dst);
 
 	if (th->ack) {
 		/* rfc793:
@@ -5470,6 +5491,44 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 * Change state from SYN-SENT only after copied_seq
 		 * is initialized. */
 		tp->copied_seq = tp->rcv_nxt;
+
+		if (cvp != NULL
+		 && cvp->cookie_pair_size > 0
+		 && tp->rx_opt.cookie_plus > 0) {
+			int cookie_size = tp->rx_opt.cookie_plus
+					- TCPOLEN_COOKIE_BASE;
+			int cookie_pair_size = cookie_size
+					     + cvp->cookie_desired;
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
+				cvp->s_data_in = 1; /* true */
+				queued = 1; /* should be amount? */
+				tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+				tp->rcv_wup = TCP_SKB_CB(skb)->end_seq;
+				tp->copied_seq = TCP_SKB_CB(skb)->seq + 1;
+			}
+		}
+
 		smp_mb();
 		tcp_set_state(sk, TCP_ESTABLISHED);
 
@@ -5521,11 +5580,14 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 						  TCP_DELACK_MAX, TCP_RTO_MAX);
 
 discard:
-			__kfree_skb(skb);
+			if (queued == 0)
+				__kfree_skb(skb);
 			return 0;
 		} else {
 			tcp_send_ack(sk);
 		}
+		if (queued > 0)
+			return 0; /* amount queued? */
 		return -1;
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0718fde..5992d0b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1213,9 +1213,12 @@ static struct timewait_sock_ops tcp_timewait_sock_ops = {
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_extend_values tmp_ext;
 	struct tcp_options_received tmp_opt;
+	u8 *cryptic_value;
 	struct request_sock *req;
 	struct inet_request_sock *ireq;
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = NULL;
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
@@ -1271,15 +1274,50 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
-	tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
+	tmp_opt.user_mss  = tp->rx_opt.user_mss;
+	tcp_parse_options(skb, &tmp_opt, &cryptic_value, 0, dst);
+
+	if (tmp_opt.cookie_plus > 0
+	 && tmp_opt.saw_tstamp
+	 && !tp->rx_opt.cookie_out_never
+	 && (sysctl_tcp_cookie_size > 0
+	  || (tp->cookie_values != NULL
+	   && tp->cookie_values->cookie_desired > 0))) {
+		u8 *c;
+		u32 *mess = &tmp_ext.cookie_bakery[COOKIE_DIGEST_WORDS];
+		int l = tmp_opt.cookie_plus - TCPOLEN_COOKIE_BASE;
+
+		if (tcp_cookie_generator(&tmp_ext.cookie_bakery[0]) != 0)
+			goto drop_and_release;
+
+		/* Secret recipe starts with IP addresses */
+		*mess++ ^= daddr;
+		*mess++ ^= saddr;
+
+		/* plus variable length Initiator Cookie */
+		c = (u8 *)mess;
+		while (l-- > 0) {
+			*c++ ^= *cryptic_value++;
+		}
 
-	tcp_parse_options(skb, &tmp_opt, 0, dst);
+#ifdef CONFIG_SYN_COOKIES
+		want_cookie = 0;	/* not our kind of cookie */
+#endif
+		tmp_ext.cookie_out_never = 0; /* false */
+		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
+	} else if (!tp->rx_opt.cookie_in_always) {
+		/* redundant indications, but ensure initialization. */
+		tmp_ext.cookie_out_never = 1; /* true */
+		tmp_ext.cookie_plus = 0;
+	} else {
+		goto drop_and_release;
+	}
+	tmp_ext.cookie_in_always = tp->rx_opt.cookie_in_always;
 
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
 
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
-
 	tcp_openreq_init(req, &tmp_opt, skb);
 
 	if (security_inet_conn_request(sk, skb, req))
@@ -1339,7 +1377,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	}
 	tcp_rsk(req)->snt_isn = isn;
 
-	if (__tcp_v4_send_synack(sk, req, dst, NULL)
+	if (__tcp_v4_send_synack(sk, req, dst,
+				 (struct request_values *)&tmp_ext)
 	 || want_cookie)
 		goto drop_and_free;
 
@@ -1834,6 +1873,19 @@ static int tcp_v4_init_sock(struct sock *sk)
 	tp->af_specific = &tcp_sock_ipv4_specific;
 #endif
 
+	/* TCP Cookie Transactions */
+	if (sysctl_tcp_cookie_size > 0) {
+		/* Default, cookies without s_data. */
+		tp->cookie_values =
+			kzalloc(sizeof(*tp->cookie_values),
+				sk->sk_allocation);
+		if (tp->cookie_values != NULL)
+			kref_init(&tp->cookie_values->kref);
+	}
+	/* Presumed zeroed, in order of appearance:
+	 *	cookie_in_always, cookie_out_never, extend_timestamp,
+	 *	s_data_constant, s_data_in, s_data_out
+	 */
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
@@ -1887,6 +1939,15 @@ void tcp_v4_destroy_sock(struct sock *sk)
 		sk->sk_sndmsg_page = NULL;
 	}
 
+	/*
+	 * If cookie or s_data exists, remove it.
+	 */
+	if (tp->cookie_values != NULL) {
+		kref_put(&tp->cookie_values->kref,
+			 tcp_cookie_values_release);
+		tp->cookie_values = NULL;
+	}
+
 	percpu_counter_dec(&tcp_sockets_allocated);
 }
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 7a42990..db46797 100644
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
 
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
 		tmp_opt.tstamp_ok = 1;
-		tcp_parse_options(skb, &tmp_opt, 1, NULL);
+		tcp_parse_options(skb, &tmp_opt, &cryptic_value, 1, NULL);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent	= tcptw->tw_ts_recent;
@@ -389,14 +390,42 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		const struct inet_request_sock *ireq = inet_rsk(req);
 		struct tcp_request_sock *treq = tcp_rsk(req);
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
-		struct tcp_sock *newtp;
+		struct tcp_sock *newtp = tcp_sk(newsk);
+		struct tcp_sock *oldtp = tcp_sk(sk);
+		struct tcp_cookie_values *oldcvp = oldtp->cookie_values;
+
+		/* TCP Cookie Transactions require space for the cookie pair,
+		 * as it differs for each connection.  There is no need to
+		 * copy any s_data stored at the original socket.  Failure
+		 * will prevent resuming the connection.
+		 *
+		 * Presumed copied, in order of appearance:
+		 *	cookie_in_always, cookie_out_never
+		 */
+		if (oldcvp != NULL) {
+			struct tcp_cookie_values *newcvp =
+				kzalloc(sizeof(*newtp->cookie_values),
+					GFP_ATOMIC);
+
+			if (newcvp != NULL) {
+				kref_init(&newcvp->kref);
+				newcvp->cookie_desired =
+						oldcvp->cookie_desired;
+				newtp->cookie_values = newcvp;
+			} else {
+				/* Not Yet Implemented */
+				newtp->cookie_values = NULL;
+			}
+		}
 
 		/* Now setup tcp_sock */
-		newtp = tcp_sk(newsk);
 		newtp->pred_flags = 0;
-		newtp->rcv_wup = newtp->copied_seq = newtp->rcv_nxt = treq->rcv_isn + 1;
-		newtp->snd_sml = newtp->snd_una = newtp->snd_nxt = treq->snt_isn + 1;
-		newtp->snd_up = treq->snt_isn + 1;
+
+		newtp->rcv_wup = newtp->copied_seq =
+		newtp->rcv_nxt = treq->rcv_isn + 1;
+
+		newtp->snd_sml = newtp->snd_una = newtp->snd_nxt =
+		newtp->snd_up = treq->snt_isn + 1 + tcp_s_data_size(oldtp);
 
 		tcp_prequeue_init(newtp);
 
@@ -429,8 +458,8 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
 		skb_queue_head_init(&newtp->out_of_order_queue);
-		newtp->write_seq = treq->snt_isn + 1;
-		newtp->pushed_seq = newtp->write_seq;
+		newtp->write_seq = newtp->pushed_seq =
+			treq->snt_isn + 1 + tcp_s_data_size(oldtp);
 
 		newtp->rx_opt.saw_tstamp = 0;
 
@@ -495,15 +524,16 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 			   struct request_sock *req,
 			   struct request_sock **prev)
 {
+	struct tcp_options_received tmp_opt;
+	u8 *cryptic_value;
+	struct sock *child;
 	const struct tcphdr *th = tcp_hdr(skb);
 	__be32 flg = tcp_flag_word(th) & (TCP_FLAG_RST|TCP_FLAG_SYN|TCP_FLAG_ACK);
 	int paws_reject = 0;
-	struct tcp_options_received tmp_opt;
-	struct sock *child;
 
-	if ((th->doff > (sizeof(struct tcphdr)>>2)) && (req->ts_recent)) {
+	if ((th->doff > (sizeof(*th) >> 2)) && (req->ts_recent)) {
 		tmp_opt.tstamp_ok = 1;
-		tcp_parse_options(skb, &tmp_opt, 1, NULL);
+		tcp_parse_options(skb, &tmp_opt, &cryptic_value, 1, NULL);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent = req->ts_recent;
@@ -596,7 +626,8 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	 * Invalid ACK: reset will be sent by listening socket
 	 */
 	if ((flg & TCP_FLAG_ACK) &&
-	    (TCP_SKB_CB(skb)->ack_seq != tcp_rsk(req)->snt_isn + 1))
+	    (TCP_SKB_CB(skb)->ack_seq != tcp_rsk(req)->snt_isn + 1 +
+					 tcp_s_data_size(tcp_sk(sk))))
 		return sk;
 
 	/* Also, it would be not so bad idea to check rcv_tsecr, which
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 492ccdd..08dc649 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -370,15 +370,45 @@ static inline int tcp_urg_mode(const struct tcp_sock *tp)
 #define OPTION_TS		(1 << 1)
 #define OPTION_MD5		(1 << 2)
 #define OPTION_WSCALE		(1 << 3)
+#define OPTION_COOKIE_EXTENSION	(1 << 4)
 
 struct tcp_out_options {
 	u8 options;		/* bit field of OPTION_* */
 	u8 ws;			/* window scale, 0 to disable */
+	u8 hash_size;		/* bytes in hash */
 	u8 num_sack_blocks;	/* number of SACK blocks to include */
 	u16 mss;		/* 0 to disable */
 	__u32 tsval, tsecr;	/* need to include OPTION_TS */
+	__u8 *hash_location;	/* temporary pointer, overloaded */
 };
 
+/* The sysctl int routines are generic, so check consistency here.
+ */
+static u8 tcp_cookie_size_check(u8 desired)
+{
+	if (desired > 0) {
+		/* previously specified */
+		return desired;
+	}
+	if (sysctl_tcp_cookie_size <= 0) {
+		/* no default specified */
+		return 0;
+	}
+	if (sysctl_tcp_cookie_size < TCP_COOKIE_MIN) {
+		/* value too small, increase to minimum */
+		return TCP_COOKIE_MIN;
+	}
+	if (sysctl_tcp_cookie_size > TCP_COOKIE_MAX) {
+		/* value too large, decrease to maximum */
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
@@ -393,17 +423,34 @@ struct tcp_out_options {
  * (but it may well be that other scenarios fail similarly).
  */
 static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
-			      const struct tcp_out_options *opts,
-			      __u8 **md5_hash) {
-	if (unlikely(OPTION_MD5 & opts->options)) {
-		*ptr++ = htonl((TCPOPT_NOP << 24) |
-			       (TCPOPT_NOP << 16) |
-			       (TCPOPT_MD5SIG << 8) |
-			       TCPOLEN_MD5SIG);
-		*md5_hash = (__u8 *)ptr;
+			      struct tcp_out_options *opts)
+{
+	u8 options = opts->options;	/* mungable copy */
+
+	/* Having both authentication and cookies for security is redundant,
+	 * and there's certainly not enough room.  Instead, the cookie-less
+	 * extension variant is proposed.
+	 *
+	 * Consider the pessimal case with authentication.  The options
+	 * could look like:
+	 *   COOKIE|MD5(20) + MSS(4) + SACK|TS(12) + WSCALE(4) == 40
+	 */
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
+		options &= ~OPTION_COOKIE_EXTENSION;
+		/* overload cookie hash location */
+		opts->hash_location = (__u8 *)ptr;
 		ptr += 4;
-	} else {
-		*md5_hash = NULL;
 	}
 
 	if (unlikely(opts->mss)) {
@@ -412,12 +459,13 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
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
@@ -428,15 +476,52 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		*ptr++ = htonl(opts->tsecr);
 	}
 
-	if (unlikely(OPTION_SACK_ADVERTISE & opts->options &&
-		     !(OPTION_TS & opts->options))) {
+	/* Specification requires after timestamp, so do it now.
+	 *
+	 * Consider the pessimal case without authentication.  The options
+	 * could look like:
+	 *   MSS(4) + SACK|TS(12) + COOKIE(20) + WSCALE(4) == 40
+	 */
+	if (unlikely(OPTION_COOKIE_EXTENSION & options)) {
+		__u8 *cookie_copy = opts->hash_location;
+		u8 cookie_size = opts->hash_size;
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
+					(TCPOPT_NOP << 16) |
+					(TCPOPT_COOKIE << 8) |
+					TCPOLEN_COOKIE_BASE) +
+				       cookie_size);
+		}
+
+		if (cookie_size > 0) {
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
@@ -471,8 +556,12 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 				struct tcp_out_options *opts,
 				struct tcp_md5sig_key **md5) {
 	struct tcp_sock *tp = tcp_sk(sk);
-	unsigned size = 0;
+	struct tcp_cookie_values *cvp = tp->cookie_values;
 	struct dst_entry *dst = __sk_dst_get(sk);
+	unsigned size = 0;
+	u8 cookie_size = (!tp->rx_opt.cookie_out_never && cvp != NULL)
+			 ? tcp_cookie_size_check(cvp->cookie_desired)
+			 : 0;
 
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 = tp->af_specific->md5_lookup(sk, sk);
@@ -517,6 +606,53 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 			size += TCPOLEN_SACKPERM_ALIGNED;
 	}
 
+	/* Note that timestamps are required by the specification.
+	 *
+	 * Odd numbers of bytes are prohibited by the specification, ensuring
+	 * that the cookie is 16-bit aligned, and the resulting cookie pair is
+	 * 32-bit aligned.
+	 */
+	if (*md5 == NULL
+	 && (OPTION_TS & opts->options)
+	 && cookie_size > 0) {
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
+			opts->hash_location = (__u8 *)&cvp->cookie_pair[0];
+			opts->hash_size = cookie_size;
+
+			/* Remember for future incarnations. */
+			cvp->cookie_desired = cookie_size;
+
+			if (cvp->cookie_desired != cvp->cookie_pair_size) {
+				/* Currently use random bytes as a nonce,
+				 * assuming these are completely unpredictable
+				 * by hostile users of the same system.
+				 */
+				get_random_bytes(&cvp->cookie_pair[0],
+						 cookie_size);
+				cvp->cookie_pair_size = cookie_size;
+			}
+
+			size += need;
+		}
+	}
 	return size;
 }
 
@@ -525,9 +661,14 @@ static unsigned tcp_synack_options(struct sock *sk,
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
+	u8 cookie_plus = (xvp != NULL && !xvp->cookie_out_never)
+			 ? xvp->cookie_plus
+			 : 0;
 	char doing_ts;
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -566,6 +707,28 @@ static unsigned tcp_synack_options(struct sock *sk,
 			size += TCPOLEN_SACKPERM_ALIGNED;
 	}
 
+	/* Similar rationale to tcp_syn_options() applies here, too.
+	 * If the <SYN> options fit, the same options should fit now!
+	 */
+	if (*md5 == NULL
+	 && doing_ts
+	 && cookie_plus > TCPOLEN_COOKIE_BASE) {
+		int need = cookie_plus; /* has TCPOLEN_COOKIE_BASE */
+		int remaining = MAX_TCP_OPTION_SPACE - size;
+
+		if (0x2 & need) {
+			/* 32-bit multiple */
+			need += 2; /* NOPs */
+		}
+		if (need <= remaining) {
+			opts->options |= OPTION_COOKIE_EXTENSION;
+			opts->hash_size = cookie_plus - TCPOLEN_COOKIE_BASE;
+			size += need;
+		} else {
+			/* There's no error return, so flag it. */
+			xvp->cookie_out_never = 1; /* true */
+		}
+	}
 	return size;
 }
 
@@ -632,7 +795,6 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	struct tcp_out_options opts;
 	unsigned tcp_options_size, tcp_header_size;
 	struct tcp_md5sig_key *md5;
-	__u8 *md5_hash_location;
 	struct tcphdr *th;
 	int err;
 
@@ -703,7 +865,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		}
 	}
 
-	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);
+	tcp_options_write((__be32 *)(th + 1), tp, &opts);
 	if (likely((tcb->flags & TCPCB_FLAG_SYN) == 0))
 		TCP_ECN_send(sk, skb, tcp_header_size);
 
@@ -711,7 +873,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	/* Calculate the MD5 hash, as we have all we need now */
 	if (md5) {
 		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
-		tp->af_specific->calc_md5_hash(md5_hash_location,
+		tp->af_specific->calc_md5_hash(opts.hash_location,
 					       md5, sk, NULL, skb);
 	}
 #endif
@@ -2235,14 +2397,14 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 				struct request_values *rvp,
 				struct request_sock *req)
 {
+	struct tcp_out_options opts;
+	struct tcp_extend_values *xvp = tcp_xv(rvp);
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcphdr *th;
-	int tcp_header_size;
-	struct tcp_out_options opts;
 	struct sk_buff *skb;
 	struct tcp_md5sig_key *md5;
-	__u8 *md5_hash_location;
+	int tcp_header_size;
 	int mss;
 
 	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
@@ -2280,7 +2442,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 #endif
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 	tcp_header_size = tcp_synack_options(sk, req, mss,
-					     skb, &opts, &md5) +
+					     skb, &opts, &md5, xvp) +
 			  sizeof(struct tcphdr);
 
 	skb_push(skb, tcp_header_size);
@@ -2298,19 +2460,58 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	 */
 	tcp_init_nondata_skb(skb, tcp_rsk(req)->snt_isn,
 			     TCPCB_FLAG_SYN | TCPCB_FLAG_ACK);
+
+	if (OPTION_COOKIE_EXTENSION & opts.options) {
+		const struct tcp_cookie_values *cvp = tp->cookie_values;
+
+		if (cvp != NULL
+		 && cvp->s_data_constant
+		 && cvp->s_data_desired > 0) {
+			u8 *buf = skb_put(skb, cvp->s_data_desired);
+
+			/* copy data directly from the listening socket. */
+			memcpy(buf, cvp->s_data_payload, cvp->s_data_desired);
+			TCP_SKB_CB(skb)->end_seq += cvp->s_data_desired;
+		}
+
+		if (opts.hash_size > 0) {
+			__u32 workspace[SHA_WORKSPACE_WORDS];
+			u32 *mess = &xvp->cookie_bakery[COOKIE_DIGEST_WORDS];
+			u32 *tail = &mess[COOKIE_MESSAGE_WORDS-1];
+
+			/* Secret recipe depends on the Timestamp, (future)
+			 * Sequence and Acknowledgment Numbers, Initiator
+			 * Cookie, and others handled by IP variant caller.
+			 */
+			*tail-- ^= opts.tsval;
+			*tail-- ^= tcp_rsk(req)->rcv_isn + 1;
+			*tail-- ^= TCP_SKB_CB(skb)->seq + 1;
+
+			/* recommended */
+			*tail-- ^= ((th->dest << 16) | th->source);
+			*tail-- ^= (u32)cvp; /* per sockopt */
+
+			sha_transform((__u32 *)&xvp->cookie_bakery[0],
+				      (char *)mess,
+				      &workspace[0]);
+			opts.hash_location =
+				(__u8 *)&xvp->cookie_bakery[0];
+		}
+	}
+
 	th->seq = htonl(TCP_SKB_CB(skb)->seq);
 	th->ack_seq = htonl(tcp_rsk(req)->rcv_isn + 1);
 
 	/* RFC1323: The window in SYN & SYN/ACK segments is never scaled. */
 	th->window = htons(min(req->rcv_wnd, 65535U));
-	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);
+	tcp_options_write((__be32 *)(th + 1), tp, &opts);
 	th->doff = (tcp_header_size >> 2);
 	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTSEGS);
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Okay, we have all we need - do the md5 hash if needed */
 	if (md5) {
-		tcp_rsk(req)->af_specific->calc_md5_hash(md5_hash_location,
+		tcp_rsk(req)->af_specific->calc_md5_hash(opts.hash_location,
 					       md5, NULL, req, skb);
 	}
 #endif
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 612fc53..a60b934 100644
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
@@ -254,7 +255,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, 0, dst);
+	tcp_parse_options(skb, &tcp_opt, &cryptic_value, 0, dst);
 
 	if (tcp_opt.saw_tstamp)
 		cookie_check_timestamp(&tcp_opt);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b528f75..14b6a32 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1162,7 +1162,9 @@ static struct sock *tcp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
  */
 static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_extend_values tmp_ext;
 	struct tcp_options_received tmp_opt;
+	u8 *cryptic_value;
 	struct request_sock *req;
 	struct inet6_request_sock *treq;
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -1206,8 +1208,53 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
+	tcp_parse_options(skb, &tmp_opt, &cryptic_value, 0, dst);
+
+	if (tmp_opt.cookie_plus > 0
+	 && tmp_opt.saw_tstamp
+	 && !tp->rx_opt.cookie_out_never
+	 && (sysctl_tcp_cookie_size > 0
+	  || (tp->cookie_values != NULL
+	   && tp->cookie_values->cookie_desired > 0))) {
+		u8 *c;
+		u32 *d;
+		u32 *mess = &tmp_ext.cookie_bakery[COOKIE_DIGEST_WORDS];
+		int l = tmp_opt.cookie_plus - TCPOLEN_COOKIE_BASE;
+
+		if (tcp_cookie_generator(&tmp_ext.cookie_bakery[0]) != 0)
+			goto drop_and_free;
+
+		/* Secret recipe starts with IP addresses */
+		d = &ipv6_hdr(skb)->daddr.s6_addr32[0];
+		*mess++ ^= *d++;
+		*mess++ ^= *d++;
+		*mess++ ^= *d++;
+		*mess++ ^= *d++;
+		d = &ipv6_hdr(skb)->saddr.s6_addr32[0];
+		*mess++ ^= *d++;
+		*mess++ ^= *d++;
+		*mess++ ^= *d++;
+		*mess++ ^= *d++;
+
+		/* plus variable length Initiator Cookie */
+		c = (u8 *)mess;
+		while (l-- > 0) {
+			*c++ ^= *cryptic_value++;
+		}
 
-	tcp_parse_options(skb, &tmp_opt, 0, dst);
+#ifdef CONFIG_SYN_COOKIES
+		want_cookie = 0;	/* not our kind of cookie */
+#endif
+		tmp_ext.cookie_out_never = 0; /* false */
+		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
+	} else if (!tp->rx_opt.cookie_in_always) {
+		/* redundant indications, but ensure initialization. */
+		tmp_ext.cookie_out_never = 1; /* true */
+		tmp_ext.cookie_plus = 0;
+	} else {
+		goto drop_and_free;
+	}
+	tmp_ext.cookie_in_always = tp->rx_opt.cookie_in_always;
 
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
@@ -1244,7 +1291,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	security_inet_conn_request(sk, skb, req);
 
-	if (tcp_v6_send_synack(sk, req, NULL)
+	if (tcp_v6_send_synack(sk, req,
+			       (struct request_values *)&tmp_ext)
 	 || want_cookie)
 		goto drop_and_free;
 
@@ -1865,6 +1913,19 @@ static int tcp_v6_init_sock(struct sock *sk)
 	tp->af_specific = &tcp_sock_ipv6_specific;
 #endif
 
+	/* TCP Cookie Transactions */
+	if (sysctl_tcp_cookie_size > 0) {
+		/* Default, cookies without s_data. */
+		tp->cookie_values =
+			kzalloc(sizeof(*tp->cookie_values),
+				sk->sk_allocation);
+		if (tp->cookie_values != NULL)
+			kref_init(&tp->cookie_values->kref);
+	}
+	/* Presumed zeroed, in order of appearance:
+	 *	cookie_in_always, cookie_out_never, extend_timestamp,
+	 *	s_data_constant, s_data_in, s_data_out
+	 */
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
-- 
1.6.3.3


--------------080602090006060509050400--
