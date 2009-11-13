From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP cookie
 option, extend existing struct's
Date: Thu, 12 Nov 2009 23:53:48 -0500
Message-ID: <4AFCE65C.2010104@gmail.com>
References: <4AFCDA9E.8050003@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090102030605050805060205"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:45971 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755611AbZKMExv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 23:53:51 -0500
Received: by gxk26 with SMTP id 26so2754639gxk.1
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 20:53:57 -0800 (PST)
In-Reply-To: <4AFCDA9E.8050003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090102030605050805060205
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Data structures are carefully composed to require minimal additions.
For example, the struct tcp_options_received cookie_plus variable fits
between existing 16-bit and 8-bit variables, requiring no additional
space (taking alignment into consideration).  There are no additions to
tcp_request_sock, and only 1 pointer in tcp_sock.

This is a significantly revised implementation of an earlier (year-old)
patch that no longer applies cleanly, with permission of the original
author (Adam Langley):

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

These functions will also be used in subsequent patches that implement
additional features.

Requires:
   TCPCT part 1a: add request_values parameter for sending SYNACK
   TCPCT part 1b: generate Responder Cookie
   TCPCT part 1c: sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/linux/tcp.h |   29 ++++++++++++++++----
  include/net/tcp.h   |   72 +++++++++++++++++++++++++++++++++++++++++++++++++++
  2 files changed, 95 insertions(+), 6 deletions(-)

--------------090102030605050805060205
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1d6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1d6.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index eaa3113..6c5ff66 100644
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
+	struct tcp_cookie_values  	*cookie_values;
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
index 738b65f..3a4c840 100644
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
@@ -1482,6 +1488,72 @@ struct tcp_request_sock_ops {
 
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
 
-- 
1.6.3.3


--------------090102030605050805060205--
