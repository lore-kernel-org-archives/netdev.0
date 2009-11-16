From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP cookie
 option, extend existing struct's
Date: Mon, 16 Nov 2009 15:50:59 -0500
Message-ID: <4B01BB33.7080702@gmail.com>
References: <4AFCDA9E.8050003@gmail.com> <4AFCE65C.2010104@gmail.com> <4AFCFD86.6020504@gmail.com> <4AFD8421.6090003@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010405080505030805010507"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:43324 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbZKPUu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 15:50:56 -0500
Received: by gxk26 with SMTP id 26so1183751gxk.1
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 12:51:02 -0800 (PST)
In-Reply-To: <4AFD8421.6090003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010405080505030805010507
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

William Allen Simpson wrote:
> Here's my revised attempt (untested).  Any technical corrections?
> 
Limited multiple (=) assignments to only 2 per line for readability
(that in existing code have 4 per line and run well beyond 80 characters,
triggering a warning in scripts/checkpatch.pl).

Still no technical corrections.  Seeking Acks.

--------------010405080505030805010507
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1d6++.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1d6++.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index eaa3113..7fee8a4 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -247,31 +247,38 @@ struct tcp_options_received {
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
@@ -441,6 +448,12 @@ struct tcp_sock {
 /* TCP MD5 Signature Option information */
 	struct tcp_md5sig_info	*md5sig_info;
 #endif
+
+	/* When the cookie options are generated and exchanged, then this
+	 * object holds a reference to them (cookie_values->kref).  Also
+	 * contains related tcp_cookie_transactions fields.
+	 */
+	struct tcp_cookie_values  *cookie_values;
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
@@ -459,6 +472,10 @@ struct tcp_timewait_sock {
 	u16			  tw_md5_keylen;
 	u8			  tw_md5_key[TCP_MD5SIG_MAXKEYLEN];
 #endif
+	/* Few sockets in timewait have cookies; in that case, then this
+	 * object holds a reference to them (tw_cookie_values->kref).
+	 */
+	struct tcp_cookie_values  *tw_cookie_values;
 };
 
 static inline struct tcp_timewait_sock *tcp_twsk(const struct sock *sk)
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 738b65f..f9abd9b 100644
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
+#define TCPOLEN_COOKIE_MIN     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MIN)
+#define TCPOLEN_COOKIE_MAX     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MAX)
 
 /* But this is what stacks really send out. */
 #define TCPOLEN_TSTAMP_ALIGNED		12
@@ -1482,6 +1488,83 @@ struct tcp_request_sock_ops {
 
 extern int tcp_cookie_generator(u32 *bakery);
 
+/**
+ *	struct tcp_cookie_values - each socket needs extra space for the
+ *	cookies, together with (optional) space for any SYN data.
+ *
+ *	A tcp_sock contains a pointer to the current value, and this is
+ *	cloned to the tcp_timewait_sock.
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
+			s_data_out:1,
+			s_data_unused:2;
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
+/**
+ *	struct tcp_extend_values - tcp_ipv?.c to tcp_output.c workspace.
+ *
+ *	As tcp_request_sock has already been extended in other places, the
+ *	only remaining method is to pass stack values along as function
+ *	parameters.  These parameters are not needed after sending SYNACK.
+ *
+ * @cookie_bakery:	cryptographic secret and message workspace.
+ *
+ * @cookie_plus:	bytes in authenticator/cookie option, copied from
+ *			struct tcp_options_received (above).
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
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 397ab8f..2bb7864 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1834,6 +1834,19 @@ static int tcp_v4_init_sock(struct sock *sk)
 	tp->af_specific = &tcp_sock_ipv4_specific;
 #endif
 
+	/* TCP Cookie Transactions */
+	if (sysctl_tcp_cookie_size > 0) {
+		/* Default, cookies without s_data_payload. */
+		tp->cookie_values =
+			kzalloc(sizeof(*tp->cookie_values),
+				sk->sk_allocation);
+		if (tp->cookie_values != NULL)
+			kref_init(&tp->cookie_values->kref);
+	}
+	/* Presumed zeroed, in order of appearance:
+	 *	cookie_in_always, cookie_out_never,
+	 *	s_data_constant, s_data_in, s_data_out
+	 */
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
@@ -1887,6 +1900,13 @@ void tcp_v4_destroy_sock(struct sock *sk)
 		sk->sk_sndmsg_page = NULL;
 	}
 
+	/* TCP Cookie Transactions */
+	if (tp->cookie_values != NULL) {
+		kref_put(&tp->cookie_values->kref,
+			 tcp_cookie_values_release);
+		tp->cookie_values = NULL;
+	}
+
 	percpu_counter_dec(&tcp_sockets_allocated);
 }
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 7a42990..53ef6d8 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -389,14 +389,43 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
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
+		 * copy any s_data_payload stored at the original socket.
+		 * Failure will prevent resuming the connection.
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
+		newtp->snd_sml = newtp->snd_una =
+		newtp->snd_nxt = newtp->snd_up =
+			treq->snt_isn + 1 + tcp_s_data_size(oldtp);
 
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
 
@@ -596,7 +625,8 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	 * Invalid ACK: reset will be sent by listening socket
 	 */
 	if ((flg & TCP_FLAG_ACK) &&
-	    (TCP_SKB_CB(skb)->ack_seq != tcp_rsk(req)->snt_isn + 1))
+	    (TCP_SKB_CB(skb)->ack_seq !=
+	     tcp_rsk(req)->snt_isn + 1 + tcp_s_data_size(tcp_sk(sk))))
 		return sk;
 
 	/* Also, it would be not so bad idea to check rcv_tsecr, which
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3e327bc..973096a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1865,6 +1865,19 @@ static int tcp_v6_init_sock(struct sock *sk)
 	tp->af_specific = &tcp_sock_ipv6_specific;
 #endif
 
+	/* TCP Cookie Transactions */
+	if (sysctl_tcp_cookie_size > 0) {
+		/* Default, cookies without s_data_payload. */
+		tp->cookie_values =
+			kzalloc(sizeof(*tp->cookie_values),
+				sk->sk_allocation);
+		if (tp->cookie_values != NULL)
+			kref_init(&tp->cookie_values->kref);
+	}
+	/* Presumed zeroed, in order of appearance:
+	 *	cookie_in_always, cookie_out_never,
+	 *	s_data_constant, s_data_in, s_data_out
+	 */
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 

--------------010405080505030805010507--
